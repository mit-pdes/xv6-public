
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
    80000004:	32813103          	ld	sp,808(sp) # 8000a328 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000066:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdaf87>
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
    8000011c:	218020ef          	jal	80002334 <either_copyin>
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
    80000198:	1dc50513          	addi	a0,a0,476 # 80012370 <cons>
    8000019c:	28d000ef          	jal	80000c28 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    800001a0:	00012497          	auipc	s1,0x12
    800001a4:	1d048493          	addi	s1,s1,464 # 80012370 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a8:	00012917          	auipc	s2,0x12
    800001ac:	26090913          	addi	s2,s2,608 # 80012408 <cons+0x98>
  while (n > 0) {
    800001b0:	0d305263          	blez	s3,80000274 <consoleread+0xfc>
    while (cons.r == cons.w) {
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	0af71763          	bne	a4,a5,8000026a <consoleread+0xf2>
      if (killed(myproc())) {
    800001c0:	788010ef          	jal	80001948 <myproc>
    800001c4:	7f1010ef          	jal	800021b4 <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	58b010ef          	jal	80001f56 <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	2df000ef          	jal	80000cb0 <release>
      sleep();
    800001d6:	5bd010ef          	jal	80001f92 <sleep>
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
    800001f2:	18270713          	addi	a4,a4,386 # 80012370 <cons>
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
    80000220:	0c8020ef          	jal	800022e8 <either_copyout>
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
    8000023c:	13850513          	addi	a0,a0,312 # 80012370 <cons>
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
    80000262:	1af72523          	sw	a5,426(a4) # 80012408 <cons+0x98>
    80000266:	7aa2                	ld	s5,40(sp)
    80000268:	a031                	j	80000274 <consoleread+0xfc>
    8000026a:	f456                	sd	s5,40(sp)
    8000026c:	b749                	j	800001ee <consoleread+0x76>
    8000026e:	7aa2                	ld	s5,40(sp)
    80000270:	a011                	j	80000274 <consoleread+0xfc>
    80000272:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000274:	00012517          	auipc	a0,0x12
    80000278:	0fc50513          	addi	a0,a0,252 # 80012370 <cons>
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
    800002cc:	0a850513          	addi	a0,a0,168 # 80012370 <cons>
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
    800002ea:	096020ef          	jal	80002380 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ee:	00012517          	auipc	a0,0x12
    800002f2:	08250513          	addi	a0,a0,130 # 80012370 <cons>
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
    80000310:	06470713          	addi	a4,a4,100 # 80012370 <cons>
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
    80000336:	03e70713          	addi	a4,a4,62 # 80012370 <cons>
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
    80000360:	0ac72703          	lw	a4,172(a4) # 80012408 <cons+0x98>
    80000364:	9f99                	subw	a5,a5,a4
    80000366:	08000713          	li	a4,128
    8000036a:	f8e792e3          	bne	a5,a4,800002ee <consoleintr+0x32>
    8000036e:	a075                	j	8000041a <consoleintr+0x15e>
    80000370:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000372:	00012717          	auipc	a4,0x12
    80000376:	ffe70713          	addi	a4,a4,-2 # 80012370 <cons>
    8000037a:	0a072783          	lw	a5,160(a4)
    8000037e:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000382:	00012497          	auipc	s1,0x12
    80000386:	fee48493          	addi	s1,s1,-18 # 80012370 <cons>
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
    800003c8:	fac70713          	addi	a4,a4,-84 # 80012370 <cons>
    800003cc:	0a072783          	lw	a5,160(a4)
    800003d0:	09c72703          	lw	a4,156(a4)
    800003d4:	f0f70de3          	beq	a4,a5,800002ee <consoleintr+0x32>
      cons.e--;
    800003d8:	37fd                	addiw	a5,a5,-1
    800003da:	00012717          	auipc	a4,0x12
    800003de:	02f72b23          	sw	a5,54(a4) # 80012410 <cons+0xa0>
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
    800003fc:	f7878793          	addi	a5,a5,-136 # 80012370 <cons>
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
    8000041e:	fec7a923          	sw	a2,-14(a5) # 8001240c <cons+0x9c>
        wakeup(&cons.r);
    80000422:	00012517          	auipc	a0,0x12
    80000426:	fe650513          	addi	a0,a0,-26 # 80012408 <cons+0x98>
    8000042a:	399010ef          	jal	80001fc2 <wakeup>
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
    80000444:	f3050513          	addi	a0,a0,-208 # 80012370 <cons>
    80000448:	760000ef          	jal	80000ba8 <initlock>

  uartinit();
    8000044c:	448000ef          	jal	80000894 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000450:	00022797          	auipc	a5,0x22
    80000454:	29078793          	addi	a5,a5,656 # 800226e0 <devsw>
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
    80000492:	2e280813          	addi	a6,a6,738 # 80007770 <digits>
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
    8000052c:	e1c7a783          	lw	a5,-484(a5) # 8000a344 <panicking>
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
    80000572:	eaa50513          	addi	a0,a0,-342 # 80012418 <pr>
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
    800006e6:	08ec8c93          	addi	s9,s9,142 # 80007770 <digits>
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
    8000076e:	bda7a783          	lw	a5,-1062(a5) # 8000a344 <panicking>
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
    80000798:	c8450513          	addi	a0,a0,-892 # 80012418 <pr>
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
    80000848:	b097a023          	sw	s1,-1280(a5) # 8000a344 <panicking>
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
    8000086a:	ac97ad23          	sw	s1,-1318(a5) # 8000a340 <panicked>
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
    80000884:	b9850513          	addi	a0,a0,-1128 # 80012418 <pr>
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
    800008da:	b5a50513          	addi	a0,a0,-1190 # 80012430 <tx_lock>
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
    800008fe:	b3650513          	addi	a0,a0,-1226 # 80012430 <tx_lock>
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
    8000091c:	a3490913          	addi	s2,s2,-1484 # 8000a34c <tx_busy>
      // wait for a UART interrupt to set tx_busy to 0.
      sleep_prepare(&tx_chan);
    80000920:	0000a997          	auipc	s3,0xa
    80000924:	a2898993          	addi	s3,s3,-1496 # 8000a348 <tx_chan>
      release(&tx_lock);
    80000928:	00012497          	auipc	s1,0x12
    8000092c:	b0848493          	addi	s1,s1,-1272 # 80012430 <tx_lock>
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
    8000093a:	61c010ef          	jal	80001f56 <sleep_prepare>
      release(&tx_lock);
    8000093e:	8526                	mv	a0,s1
    80000940:	370000ef          	jal	80000cb0 <release>
      sleep();
    80000944:	64e010ef          	jal	80001f92 <sleep>
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
    8000097c:	ab850513          	addi	a0,a0,-1352 # 80012430 <tx_lock>
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
    800009a0:	9a87a783          	lw	a5,-1624(a5) # 8000a344 <panicking>
    800009a4:	cf95                	beqz	a5,800009e0 <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    800009a6:	0000a797          	auipc	a5,0xa
    800009aa:	99a7a783          	lw	a5,-1638(a5) # 8000a340 <panicked>
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
    800009d0:	9787a783          	lw	a5,-1672(a5) # 8000a344 <panicking>
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
    80000a06:	a2e50513          	addi	a0,a0,-1490 # 80012430 <tx_lock>
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
    80000a20:	a1450513          	addi	a0,a0,-1516 # 80012430 <tx_lock>
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
    80000a48:	9007a423          	sw	zero,-1784(a5) # 8000a34c <tx_busy>
    wakeup(&tx_chan);
    80000a4c:	0000a517          	auipc	a0,0xa
    80000a50:	8fc50513          	addi	a0,a0,-1796 # 8000a348 <tx_chan>
    80000a54:	56e010ef          	jal	80001fc2 <wakeup>
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
    80000a76:	e0678793          	addi	a5,a5,-506 # 80023878 <end>
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
    80000aa0:	9ac90913          	addi	s2,s2,-1620 # 80012448 <kmem>
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
    80000b2e:	91e50513          	addi	a0,a0,-1762 # 80012448 <kmem>
    80000b32:	076000ef          	jal	80000ba8 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000b36:	45c5                	li	a1,17
    80000b38:	05ee                	slli	a1,a1,0x1b
    80000b3a:	00023517          	auipc	a0,0x23
    80000b3e:	d3e50513          	addi	a0,a0,-706 # 80023878 <end>
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
    80000b5c:	8f050513          	addi	a0,a0,-1808 # 80012448 <kmem>
    80000b60:	0c8000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b64:	00012497          	auipc	s1,0x12
    80000b68:	8fc4b483          	ld	s1,-1796(s1) # 80012460 <kmem+0x18>
  if (r)
    80000b6c:	c49d                	beqz	s1,80000b9a <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b6e:	609c                	ld	a5,0(s1)
    80000b70:	00012717          	auipc	a4,0x12
    80000b74:	8ef73823          	sd	a5,-1808(a4) # 80012460 <kmem+0x18>
  release(&kmem.lock);
    80000b78:	00012517          	auipc	a0,0x12
    80000b7c:	8d050513          	addi	a0,a0,-1840 # 80012448 <kmem>
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
    80000b9e:	8ae50513          	addi	a0,a0,-1874 # 80012448 <kmem>
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
    80000eae:	4a670713          	addi	a4,a4,1190 # 8000a350 <started>
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
    80000ed4:	5de010ef          	jal	800024b2 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ed8:	011040ef          	jal	800056e8 <plicinithart>
  }

  scheduler();
    80000edc:	6df000ef          	jal	80001dba <scheduler>
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
    80000f1c:	572010ef          	jal	8000248e <trapinit>
    trapinithart();     // install kernel trap vector
    80000f20:	592010ef          	jal	800024b2 <trapinithart>
    plicinit();         // set up interrupt controller
    80000f24:	7aa040ef          	jal	800056ce <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f28:	7c0040ef          	jal	800056e8 <plicinithart>
    binit();            // buffer cache
    80000f2c:	467010ef          	jal	80002b92 <binit>
    iinit();            // inode table
    80000f30:	1b8020ef          	jal	800030e8 <iinit>
    fileinit();         // file table
    80000f34:	1e6030ef          	jal	8000411a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f38:	0a7040ef          	jal	800057de <virtio_disk_init>
    userinit();         // first user process
    80000f3c:	4d3000ef          	jal	80001c0e <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000f40:	00009797          	auipc	a5,0x9
    80000f44:	41078793          	addi	a5,a5,1040 # 8000a350 <started>
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
    80000f62:	3fa7b783          	ld	a5,1018(a5) # 8000a358 <kernel_pagetable>
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
    800011ee:	16a7b723          	sd	a0,366(a5) # 8000a358 <kernel_pagetable>
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
    80001724:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb788>
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
    800017d8:	0c448493          	addi	s1,s1,196 # 80012898 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800017dc:	8c26                	mv	s8,s1
    800017de:	ff4df937          	lui	s2,0xff4df
    800017e2:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bb145>
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
    80001808:	c94a8a93          	addi	s5,s5,-876 # 80018498 <tickslock>
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
    8000187e:	bee50513          	addi	a0,a0,-1042 # 80012468 <pid_lock>
    80001882:	b26ff0ef          	jal	80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001886:	00006597          	auipc	a1,0x6
    8000188a:	8e258593          	addi	a1,a1,-1822 # 80007168 <etext+0x168>
    8000188e:	00011517          	auipc	a0,0x11
    80001892:	bf250513          	addi	a0,a0,-1038 # 80012480 <wait_lock>
    80001896:	b12ff0ef          	jal	80000ba8 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000189a:	00011497          	auipc	s1,0x11
    8000189e:	ffe48493          	addi	s1,s1,-2 # 80012898 <proc>
    initlock(&p->lock, "proc");
    800018a2:	00006b17          	auipc	s6,0x6
    800018a6:	8d6b0b13          	addi	s6,s6,-1834 # 80007178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    800018aa:	8aa6                	mv	s5,s1
    800018ac:	ff4df937          	lui	s2,0xff4df
    800018b0:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bb145>
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
    800018d2:	bcaa0a13          	addi	s4,s4,-1078 # 80018498 <tickslock>
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
    8000193a:	b6250513          	addi	a0,a0,-1182 # 80012498 <cpus>
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
    80001960:	b0c70713          	addi	a4,a4,-1268 # 80012468 <pid_lock>
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
    80001992:	9827a783          	lw	a5,-1662(a5) # 8000a310 <first.1>
    80001996:	cf85                	beqz	a5,800019ce <forkret+0x54>
    first = 0;
    80001998:	00009797          	auipc	a5,0x9
    8000199c:	9607ac23          	sw	zero,-1672(a5) # 8000a310 <first.1>

    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800019a0:	4505                	li	a0,1
    800019a2:	44b010ef          	jal	800035ec <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    800019a6:	00005797          	auipc	a5,0x5
    800019aa:	7da78793          	addi	a5,a5,2010 # 80007180 <etext+0x180>
    800019ae:	fcf43823          	sd	a5,-48(s0)
    800019b2:	fc043c23          	sd	zero,-40(s0)
    800019b6:	fd040593          	addi	a1,s0,-48
    800019ba:	853e                	mv	a0,a5
    800019bc:	6e5020ef          	jal	800048a0 <kexec>
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
    800019ce:	301000ef          	jal	800024ce <prepare_return>
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
    80001a1e:	a4e50513          	addi	a0,a0,-1458 # 80012468 <pid_lock>
    80001a22:	a06ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a26:	00009797          	auipc	a5,0x9
    80001a2a:	8ee78793          	addi	a5,a5,-1810 # 8000a314 <nextpid>
    80001a2e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a30:	0014871b          	addiw	a4,s1,1
    80001a34:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a36:	00011517          	auipc	a0,0x11
    80001a3a:	a3250513          	addi	a0,a0,-1486 # 80012468 <pid_lock>
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
    80001b74:	d2848493          	addi	s1,s1,-728 # 80012898 <proc>
    80001b78:	00017917          	auipc	s2,0x17
    80001b7c:	92090913          	addi	s2,s2,-1760 # 80018498 <tickslock>
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
    80001b90:	17048493          	addi	s1,s1,368
    80001b94:	ff2496e3          	bne	s1,s2,80001b80 <allocproc+0x1c>
  return 0;
    80001b98:	4481                	li	s1,0
    80001b9a:	a099                	j	80001be0 <allocproc+0x7c>
  p->pid = allocpid();
    80001b9c:	e75ff0ef          	jal	80001a10 <allocpid>
    80001ba0:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ba2:	4785                	li	a5,1
    80001ba4:	cc9c                	sw	a5,24(s1)
  p->page_faults = 0;
    80001ba6:	1604b423          	sd	zero,360(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001baa:	fa5fe0ef          	jal	80000b4e <kalloc>
    80001bae:	892a                	mv	s2,a0
    80001bb0:	eca8                	sd	a0,88(s1)
    80001bb2:	cd15                	beqz	a0,80001bee <allocproc+0x8a>
  p->pagetable = proc_pagetable(p);
    80001bb4:	8526                	mv	a0,s1
    80001bb6:	e99ff0ef          	jal	80001a4e <proc_pagetable>
    80001bba:	892a                	mv	s2,a0
    80001bbc:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001bbe:	c121                	beqz	a0,80001bfe <allocproc+0x9a>
  memset(&p->context, 0, sizeof(p->context));
    80001bc0:	07000613          	li	a2,112
    80001bc4:	4581                	li	a1,0
    80001bc6:	06048513          	addi	a0,s1,96
    80001bca:	91eff0ef          	jal	80000ce8 <memset>
  p->context.ra = (uint64)forkret;
    80001bce:	00000797          	auipc	a5,0x0
    80001bd2:	dac78793          	addi	a5,a5,-596 # 8000197a <forkret>
    80001bd6:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001bd8:	60bc                	ld	a5,64(s1)
    80001bda:	6705                	lui	a4,0x1
    80001bdc:	97ba                	add	a5,a5,a4
    80001bde:	f4bc                	sd	a5,104(s1)
}
    80001be0:	8526                	mv	a0,s1
    80001be2:	60e2                	ld	ra,24(sp)
    80001be4:	6442                	ld	s0,16(sp)
    80001be6:	64a2                	ld	s1,8(sp)
    80001be8:	6902                	ld	s2,0(sp)
    80001bea:	6105                	addi	sp,sp,32
    80001bec:	8082                	ret
    freeproc(p);
    80001bee:	8526                	mv	a0,s1
    80001bf0:	f29ff0ef          	jal	80001b18 <freeproc>
    release(&p->lock);
    80001bf4:	8526                	mv	a0,s1
    80001bf6:	8baff0ef          	jal	80000cb0 <release>
    return 0;
    80001bfa:	84ca                	mv	s1,s2
    80001bfc:	b7d5                	j	80001be0 <allocproc+0x7c>
    freeproc(p);
    80001bfe:	8526                	mv	a0,s1
    80001c00:	f19ff0ef          	jal	80001b18 <freeproc>
    release(&p->lock);
    80001c04:	8526                	mv	a0,s1
    80001c06:	8aaff0ef          	jal	80000cb0 <release>
    return 0;
    80001c0a:	84ca                	mv	s1,s2
    80001c0c:	bfd1                	j	80001be0 <allocproc+0x7c>

0000000080001c0e <userinit>:
{
    80001c0e:	1101                	addi	sp,sp,-32
    80001c10:	ec06                	sd	ra,24(sp)
    80001c12:	e822                	sd	s0,16(sp)
    80001c14:	e426                	sd	s1,8(sp)
    80001c16:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c18:	f4dff0ef          	jal	80001b64 <allocproc>
    80001c1c:	84aa                	mv	s1,a0
  initproc = p;
    80001c1e:	00008797          	auipc	a5,0x8
    80001c22:	74a7b123          	sd	a0,1858(a5) # 8000a360 <initproc>
  p->cwd = namei("/");
    80001c26:	00005517          	auipc	a0,0x5
    80001c2a:	56a50513          	addi	a0,a0,1386 # 80007190 <etext+0x190>
    80001c2e:	71d010ef          	jal	80003b4a <namei>
    80001c32:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c36:	478d                	li	a5,3
    80001c38:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c3a:	8526                	mv	a0,s1
    80001c3c:	874ff0ef          	jal	80000cb0 <release>
}
    80001c40:	60e2                	ld	ra,24(sp)
    80001c42:	6442                	ld	s0,16(sp)
    80001c44:	64a2                	ld	s1,8(sp)
    80001c46:	6105                	addi	sp,sp,32
    80001c48:	8082                	ret

0000000080001c4a <growproc>:
{
    80001c4a:	1101                	addi	sp,sp,-32
    80001c4c:	ec06                	sd	ra,24(sp)
    80001c4e:	e822                	sd	s0,16(sp)
    80001c50:	e426                	sd	s1,8(sp)
    80001c52:	e04a                	sd	s2,0(sp)
    80001c54:	1000                	addi	s0,sp,32
    80001c56:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c58:	cf1ff0ef          	jal	80001948 <myproc>
    80001c5c:	892a                	mv	s2,a0
  sz = p->sz;
    80001c5e:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001c60:	02905963          	blez	s1,80001c92 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001c64:	00b48633          	add	a2,s1,a1
    80001c68:	020007b7          	lui	a5,0x2000
    80001c6c:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c6e:	07b6                	slli	a5,a5,0xd
    80001c70:	02c7ea63          	bltu	a5,a2,80001ca4 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c74:	4691                	li	a3,4
    80001c76:	6928                	ld	a0,80(a0)
    80001c78:	e76ff0ef          	jal	800012ee <uvmalloc>
    80001c7c:	85aa                	mv	a1,a0
    80001c7e:	c50d                	beqz	a0,80001ca8 <growproc+0x5e>
  p->sz = sz;
    80001c80:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c84:	4501                	li	a0,0
}
    80001c86:	60e2                	ld	ra,24(sp)
    80001c88:	6442                	ld	s0,16(sp)
    80001c8a:	64a2                	ld	s1,8(sp)
    80001c8c:	6902                	ld	s2,0(sp)
    80001c8e:	6105                	addi	sp,sp,32
    80001c90:	8082                	ret
  } else if (n < 0) {
    80001c92:	fe04d7e3          	bgez	s1,80001c80 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c96:	00b48633          	add	a2,s1,a1
    80001c9a:	6928                	ld	a0,80(a0)
    80001c9c:	e0eff0ef          	jal	800012aa <uvmdealloc>
    80001ca0:	85aa                	mv	a1,a0
    80001ca2:	bff9                	j	80001c80 <growproc+0x36>
      return -1;
    80001ca4:	557d                	li	a0,-1
    80001ca6:	b7c5                	j	80001c86 <growproc+0x3c>
      return -1;
    80001ca8:	557d                	li	a0,-1
    80001caa:	bff1                	j	80001c86 <growproc+0x3c>

0000000080001cac <kfork>:
{
    80001cac:	7139                	addi	sp,sp,-64
    80001cae:	fc06                	sd	ra,56(sp)
    80001cb0:	f822                	sd	s0,48(sp)
    80001cb2:	f426                	sd	s1,40(sp)
    80001cb4:	e456                	sd	s5,8(sp)
    80001cb6:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001cb8:	c91ff0ef          	jal	80001948 <myproc>
    80001cbc:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001cbe:	ea7ff0ef          	jal	80001b64 <allocproc>
    80001cc2:	0e050a63          	beqz	a0,80001db6 <kfork+0x10a>
    80001cc6:	e852                	sd	s4,16(sp)
    80001cc8:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001cca:	048ab603          	ld	a2,72(s5)
    80001cce:	692c                	ld	a1,80(a0)
    80001cd0:	050ab503          	ld	a0,80(s5)
    80001cd4:	f52ff0ef          	jal	80001426 <uvmcopy>
    80001cd8:	04054863          	bltz	a0,80001d28 <kfork+0x7c>
    80001cdc:	f04a                	sd	s2,32(sp)
    80001cde:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001ce0:	048ab783          	ld	a5,72(s5)
    80001ce4:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001ce8:	058ab683          	ld	a3,88(s5)
    80001cec:	87b6                	mv	a5,a3
    80001cee:	058a3703          	ld	a4,88(s4)
    80001cf2:	12068693          	addi	a3,a3,288
    80001cf6:	6388                	ld	a0,0(a5)
    80001cf8:	678c                	ld	a1,8(a5)
    80001cfa:	6b90                	ld	a2,16(a5)
    80001cfc:	e308                	sd	a0,0(a4)
    80001cfe:	e70c                	sd	a1,8(a4)
    80001d00:	eb10                	sd	a2,16(a4)
    80001d02:	6f90                	ld	a2,24(a5)
    80001d04:	ef10                	sd	a2,24(a4)
    80001d06:	02078793          	addi	a5,a5,32
    80001d0a:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d0e:	fed794e3          	bne	a5,a3,80001cf6 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d12:	058a3783          	ld	a5,88(s4)
    80001d16:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001d1a:	0d0a8493          	addi	s1,s5,208
    80001d1e:	0d0a0913          	addi	s2,s4,208
    80001d22:	150a8993          	addi	s3,s5,336
    80001d26:	a831                	j	80001d42 <kfork+0x96>
    freeproc(np);
    80001d28:	8552                	mv	a0,s4
    80001d2a:	defff0ef          	jal	80001b18 <freeproc>
    release(&np->lock);
    80001d2e:	8552                	mv	a0,s4
    80001d30:	f81fe0ef          	jal	80000cb0 <release>
    return -1;
    80001d34:	54fd                	li	s1,-1
    80001d36:	6a42                	ld	s4,16(sp)
    80001d38:	a885                	j	80001da8 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001d3a:	04a1                	addi	s1,s1,8
    80001d3c:	0921                	addi	s2,s2,8
    80001d3e:	01348963          	beq	s1,s3,80001d50 <kfork+0xa4>
    if (p->ofile[i])
    80001d42:	6088                	ld	a0,0(s1)
    80001d44:	d97d                	beqz	a0,80001d3a <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d46:	456020ef          	jal	8000419c <filedup>
    80001d4a:	00a93023          	sd	a0,0(s2)
    80001d4e:	b7f5                	j	80001d3a <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d50:	150ab503          	ld	a0,336(s5)
    80001d54:	526010ef          	jal	8000327a <idup>
    80001d58:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d5c:	4641                	li	a2,16
    80001d5e:	158a8593          	addi	a1,s5,344
    80001d62:	158a0513          	addi	a0,s4,344
    80001d66:	8d6ff0ef          	jal	80000e3c <safestrcpy>
  pid = np->pid;
    80001d6a:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001d6e:	8552                	mv	a0,s4
    80001d70:	f41fe0ef          	jal	80000cb0 <release>
  acquire(&wait_lock);
    80001d74:	00010517          	auipc	a0,0x10
    80001d78:	70c50513          	addi	a0,a0,1804 # 80012480 <wait_lock>
    80001d7c:	eadfe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001d80:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d84:	00010517          	auipc	a0,0x10
    80001d88:	6fc50513          	addi	a0,a0,1788 # 80012480 <wait_lock>
    80001d8c:	f25fe0ef          	jal	80000cb0 <release>
  acquire(&np->lock);
    80001d90:	8552                	mv	a0,s4
    80001d92:	e97fe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001d96:	478d                	li	a5,3
    80001d98:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d9c:	8552                	mv	a0,s4
    80001d9e:	f13fe0ef          	jal	80000cb0 <release>
  return pid;
    80001da2:	7902                	ld	s2,32(sp)
    80001da4:	69e2                	ld	s3,24(sp)
    80001da6:	6a42                	ld	s4,16(sp)
}
    80001da8:	8526                	mv	a0,s1
    80001daa:	70e2                	ld	ra,56(sp)
    80001dac:	7442                	ld	s0,48(sp)
    80001dae:	74a2                	ld	s1,40(sp)
    80001db0:	6aa2                	ld	s5,8(sp)
    80001db2:	6121                	addi	sp,sp,64
    80001db4:	8082                	ret
    return -1;
    80001db6:	54fd                	li	s1,-1
    80001db8:	bfc5                	j	80001da8 <kfork+0xfc>

0000000080001dba <scheduler>:
{
    80001dba:	711d                	addi	sp,sp,-96
    80001dbc:	ec86                	sd	ra,88(sp)
    80001dbe:	e8a2                	sd	s0,80(sp)
    80001dc0:	e4a6                	sd	s1,72(sp)
    80001dc2:	e0ca                	sd	s2,64(sp)
    80001dc4:	fc4e                	sd	s3,56(sp)
    80001dc6:	f852                	sd	s4,48(sp)
    80001dc8:	f456                	sd	s5,40(sp)
    80001dca:	f05a                	sd	s6,32(sp)
    80001dcc:	ec5e                	sd	s7,24(sp)
    80001dce:	e862                	sd	s8,16(sp)
    80001dd0:	e466                	sd	s9,8(sp)
    80001dd2:	1080                	addi	s0,sp,96
    80001dd4:	8792                	mv	a5,tp
  int id = r_tp();
    80001dd6:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001dd8:	00779a93          	slli	s5,a5,0x7
    80001ddc:	00010717          	auipc	a4,0x10
    80001de0:	68c70713          	addi	a4,a4,1676 # 80012468 <pid_lock>
    80001de4:	9756                	add	a4,a4,s5
    80001de6:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001dea:	00010717          	auipc	a4,0x10
    80001dee:	6b670713          	addi	a4,a4,1718 # 800124a0 <cpus+0x8>
    80001df2:	9aba                	add	s5,s5,a4
        p->state = RUNNING;
    80001df4:	4c11                	li	s8,4
        c->proc = p;
    80001df6:	00010b17          	auipc	s6,0x10
    80001dfa:	672b0b13          	addi	s6,s6,1650 # 80012468 <pid_lock>
    80001dfe:	079e                	slli	a5,a5,0x7
    80001e00:	00fb0a33          	add	s4,s6,a5
        found = 1;
    80001e04:	4b85                	li	s7,1
    80001e06:	a0a9                	j	80001e50 <scheduler+0x96>
      release(&p->lock);
    80001e08:	8526                	mv	a0,s1
    80001e0a:	ea7fe0ef          	jal	80000cb0 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e0e:	17048493          	addi	s1,s1,368
    80001e12:	03248b63          	beq	s1,s2,80001e48 <scheduler+0x8e>
      acquire(&p->lock);
    80001e16:	8526                	mv	a0,s1
    80001e18:	e11fe0ef          	jal	80000c28 <acquire>
      if (p->state == RUNNABLE) {
    80001e1c:	4c9c                	lw	a5,24(s1)
    80001e1e:	ff3795e3          	bne	a5,s3,80001e08 <scheduler+0x4e>
        p->state = RUNNING;
    80001e22:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001e26:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001e2a:	06048593          	addi	a1,s1,96
    80001e2e:	8556                	mv	a0,s5
    80001e30:	5f4000ef          	jal	80002424 <swtch>
    80001e34:	8792                	mv	a5,tp
        mycpu()->intena = 0;
    80001e36:	2781                	sext.w	a5,a5
    80001e38:	079e                	slli	a5,a5,0x7
    80001e3a:	97da                	add	a5,a5,s6
    80001e3c:	0a07a623          	sw	zero,172(a5)
        c->proc = 0;
    80001e40:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001e44:	8cde                	mv	s9,s7
    80001e46:	b7c9                	j	80001e08 <scheduler+0x4e>
    if (found == 0) {
    80001e48:	000c9463          	bnez	s9,80001e50 <scheduler+0x96>
      asm volatile("wfi");
    80001e4c:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001e50:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001e54:	10017073          	csrci	sstatus,2
    int found = 0;
    80001e58:	4c81                	li	s9,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e5a:	00011497          	auipc	s1,0x11
    80001e5e:	a3e48493          	addi	s1,s1,-1474 # 80012898 <proc>
      if (p->state == RUNNABLE) {
    80001e62:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e64:	00016917          	auipc	s2,0x16
    80001e68:	63490913          	addi	s2,s2,1588 # 80018498 <tickslock>
    80001e6c:	b76d                	j	80001e16 <scheduler+0x5c>

0000000080001e6e <sched>:
{
    80001e6e:	7179                	addi	sp,sp,-48
    80001e70:	f406                	sd	ra,40(sp)
    80001e72:	f022                	sd	s0,32(sp)
    80001e74:	ec26                	sd	s1,24(sp)
    80001e76:	e84a                	sd	s2,16(sp)
    80001e78:	e44e                	sd	s3,8(sp)
    80001e7a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e7c:	acdff0ef          	jal	80001948 <myproc>
    80001e80:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001e82:	d41fe0ef          	jal	80000bc2 <holding>
    80001e86:	c935                	beqz	a0,80001efa <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80001e88:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001e8a:	2781                	sext.w	a5,a5
    80001e8c:	079e                	slli	a5,a5,0x7
    80001e8e:	00010717          	auipc	a4,0x10
    80001e92:	5da70713          	addi	a4,a4,1498 # 80012468 <pid_lock>
    80001e96:	97ba                	add	a5,a5,a4
    80001e98:	0a87a703          	lw	a4,168(a5)
    80001e9c:	4785                	li	a5,1
    80001e9e:	06f71463          	bne	a4,a5,80001f06 <sched+0x98>
  if (p->state == RUNNING)
    80001ea2:	4c98                	lw	a4,24(s1)
    80001ea4:	4791                	li	a5,4
    80001ea6:	06f70663          	beq	a4,a5,80001f12 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001eaa:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001eae:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001eb0:	e7bd                	bnez	a5,80001f1e <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    80001eb2:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001eb4:	00010917          	auipc	s2,0x10
    80001eb8:	5b490913          	addi	s2,s2,1460 # 80012468 <pid_lock>
    80001ebc:	2781                	sext.w	a5,a5
    80001ebe:	079e                	slli	a5,a5,0x7
    80001ec0:	97ca                	add	a5,a5,s2
    80001ec2:	0ac7a983          	lw	s3,172(a5)
    80001ec6:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001ec8:	2781                	sext.w	a5,a5
    80001eca:	079e                	slli	a5,a5,0x7
    80001ecc:	07a1                	addi	a5,a5,8
    80001ece:	00010597          	auipc	a1,0x10
    80001ed2:	5ca58593          	addi	a1,a1,1482 # 80012498 <cpus>
    80001ed6:	95be                	add	a1,a1,a5
    80001ed8:	06048513          	addi	a0,s1,96
    80001edc:	548000ef          	jal	80002424 <swtch>
    80001ee0:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001ee2:	2781                	sext.w	a5,a5
    80001ee4:	079e                	slli	a5,a5,0x7
    80001ee6:	993e                	add	s2,s2,a5
    80001ee8:	0b392623          	sw	s3,172(s2)
}
    80001eec:	70a2                	ld	ra,40(sp)
    80001eee:	7402                	ld	s0,32(sp)
    80001ef0:	64e2                	ld	s1,24(sp)
    80001ef2:	6942                	ld	s2,16(sp)
    80001ef4:	69a2                	ld	s3,8(sp)
    80001ef6:	6145                	addi	sp,sp,48
    80001ef8:	8082                	ret
    panic("sched p->lock");
    80001efa:	00005517          	auipc	a0,0x5
    80001efe:	29e50513          	addi	a0,a0,670 # 80007198 <etext+0x198>
    80001f02:	933fe0ef          	jal	80000834 <panic>
    panic("sched locks");
    80001f06:	00005517          	auipc	a0,0x5
    80001f0a:	2a250513          	addi	a0,a0,674 # 800071a8 <etext+0x1a8>
    80001f0e:	927fe0ef          	jal	80000834 <panic>
    panic("sched RUNNING");
    80001f12:	00005517          	auipc	a0,0x5
    80001f16:	2a650513          	addi	a0,a0,678 # 800071b8 <etext+0x1b8>
    80001f1a:	91bfe0ef          	jal	80000834 <panic>
    panic("sched interruptible");
    80001f1e:	00005517          	auipc	a0,0x5
    80001f22:	2aa50513          	addi	a0,a0,682 # 800071c8 <etext+0x1c8>
    80001f26:	90ffe0ef          	jal	80000834 <panic>

0000000080001f2a <yield>:
{
    80001f2a:	1101                	addi	sp,sp,-32
    80001f2c:	ec06                	sd	ra,24(sp)
    80001f2e:	e822                	sd	s0,16(sp)
    80001f30:	e426                	sd	s1,8(sp)
    80001f32:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f34:	a15ff0ef          	jal	80001948 <myproc>
    80001f38:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f3a:	ceffe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80001f3e:	478d                	li	a5,3
    80001f40:	cc9c                	sw	a5,24(s1)
  sched();
    80001f42:	f2dff0ef          	jal	80001e6e <sched>
  release(&p->lock);
    80001f46:	8526                	mv	a0,s1
    80001f48:	d69fe0ef          	jal	80000cb0 <release>
}
    80001f4c:	60e2                	ld	ra,24(sp)
    80001f4e:	6442                	ld	s0,16(sp)
    80001f50:	64a2                	ld	s1,8(sp)
    80001f52:	6105                	addi	sp,sp,32
    80001f54:	8082                	ret

0000000080001f56 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80001f56:	1101                	addi	sp,sp,-32
    80001f58:	ec06                	sd	ra,24(sp)
    80001f5a:	e822                	sd	s0,16(sp)
    80001f5c:	e426                	sd	s1,8(sp)
    80001f5e:	e04a                	sd	s2,0(sp)
    80001f60:	1000                	addi	s0,sp,32
    80001f62:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f64:	9e5ff0ef          	jal	80001948 <myproc>
    80001f68:	892a                	mv	s2,a0

  acquire(&p->lock);
    80001f6a:	cbffe0ef          	jal	80000c28 <acquire>
  if (chan == 0)
    80001f6e:	cc81                	beqz	s1,80001f86 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80001f70:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80001f74:	854a                	mv	a0,s2
    80001f76:	d3bfe0ef          	jal	80000cb0 <release>
}
    80001f7a:	60e2                	ld	ra,24(sp)
    80001f7c:	6442                	ld	s0,16(sp)
    80001f7e:	64a2                	ld	s1,8(sp)
    80001f80:	6902                	ld	s2,0(sp)
    80001f82:	6105                	addi	sp,sp,32
    80001f84:	8082                	ret
    panic("sleep_prepare: zero chan");
    80001f86:	00005517          	auipc	a0,0x5
    80001f8a:	25a50513          	addi	a0,a0,602 # 800071e0 <etext+0x1e0>
    80001f8e:	8a7fe0ef          	jal	80000834 <panic>

0000000080001f92 <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    80001f92:	1101                	addi	sp,sp,-32
    80001f94:	ec06                	sd	ra,24(sp)
    80001f96:	e822                	sd	s0,16(sp)
    80001f98:	e426                	sd	s1,8(sp)
    80001f9a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f9c:	9adff0ef          	jal	80001948 <myproc>
    80001fa0:	84aa                	mv	s1,a0

  acquire(&p->lock);
    80001fa2:	c87fe0ef          	jal	80000c28 <acquire>
  if (p->chan != 0) {
    80001fa6:	709c                	ld	a5,32(s1)
    80001fa8:	c789                	beqz	a5,80001fb2 <sleep+0x20>
    p->state = SLEEPING;
    80001faa:	4789                	li	a5,2
    80001fac:	cc9c                	sw	a5,24(s1)
    sched();
    80001fae:	ec1ff0ef          	jal	80001e6e <sched>
  }
  release(&p->lock);
    80001fb2:	8526                	mv	a0,s1
    80001fb4:	cfdfe0ef          	jal	80000cb0 <release>
}
    80001fb8:	60e2                	ld	ra,24(sp)
    80001fba:	6442                	ld	s0,16(sp)
    80001fbc:	64a2                	ld	s1,8(sp)
    80001fbe:	6105                	addi	sp,sp,32
    80001fc0:	8082                	ret

0000000080001fc2 <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    80001fc2:	7139                	addi	sp,sp,-64
    80001fc4:	fc06                	sd	ra,56(sp)
    80001fc6:	f822                	sd	s0,48(sp)
    80001fc8:	f426                	sd	s1,40(sp)
    80001fca:	f04a                	sd	s2,32(sp)
    80001fcc:	ec4e                	sd	s3,24(sp)
    80001fce:	e852                	sd	s4,16(sp)
    80001fd0:	e456                	sd	s5,8(sp)
    80001fd2:	0080                	addi	s0,sp,64
    80001fd4:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001fd6:	00011497          	auipc	s1,0x11
    80001fda:	8c248493          	addi	s1,s1,-1854 # 80012898 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    80001fde:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80001fe0:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80001fe2:	00016997          	auipc	s3,0x16
    80001fe6:	4b698993          	addi	s3,s3,1206 # 80018498 <tickslock>
    80001fea:	a801                	j	80001ffa <wakeup+0x38>
      }
    }
    release(&p->lock);
    80001fec:	8526                	mv	a0,s1
    80001fee:	cc3fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001ff2:	17048493          	addi	s1,s1,368
    80001ff6:	03348063          	beq	s1,s3,80002016 <wakeup+0x54>
    acquire(&p->lock);
    80001ffa:	8526                	mv	a0,s1
    80001ffc:	c2dfe0ef          	jal	80000c28 <acquire>
    if (p->chan == chan) {
    80002000:	709c                	ld	a5,32(s1)
    80002002:	ff2795e3          	bne	a5,s2,80001fec <wakeup+0x2a>
      p->chan = 0;
    80002006:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    8000200a:	4c9c                	lw	a5,24(s1)
    8000200c:	ff4790e3          	bne	a5,s4,80001fec <wakeup+0x2a>
        p->state = RUNNABLE;
    80002010:	0154ac23          	sw	s5,24(s1)
    80002014:	bfe1                	j	80001fec <wakeup+0x2a>
  }
}
    80002016:	70e2                	ld	ra,56(sp)
    80002018:	7442                	ld	s0,48(sp)
    8000201a:	74a2                	ld	s1,40(sp)
    8000201c:	7902                	ld	s2,32(sp)
    8000201e:	69e2                	ld	s3,24(sp)
    80002020:	6a42                	ld	s4,16(sp)
    80002022:	6aa2                	ld	s5,8(sp)
    80002024:	6121                	addi	sp,sp,64
    80002026:	8082                	ret

0000000080002028 <reparent>:
{
    80002028:	7179                	addi	sp,sp,-48
    8000202a:	f406                	sd	ra,40(sp)
    8000202c:	f022                	sd	s0,32(sp)
    8000202e:	ec26                	sd	s1,24(sp)
    80002030:	e84a                	sd	s2,16(sp)
    80002032:	e44e                	sd	s3,8(sp)
    80002034:	e052                	sd	s4,0(sp)
    80002036:	1800                	addi	s0,sp,48
    80002038:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000203a:	00011497          	auipc	s1,0x11
    8000203e:	85e48493          	addi	s1,s1,-1954 # 80012898 <proc>
      pp->parent = initproc;
    80002042:	00008a17          	auipc	s4,0x8
    80002046:	31ea0a13          	addi	s4,s4,798 # 8000a360 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000204a:	00016997          	auipc	s3,0x16
    8000204e:	44e98993          	addi	s3,s3,1102 # 80018498 <tickslock>
    80002052:	a029                	j	8000205c <reparent+0x34>
    80002054:	17048493          	addi	s1,s1,368
    80002058:	01348b63          	beq	s1,s3,8000206e <reparent+0x46>
    if (pp->parent == p) {
    8000205c:	7c9c                	ld	a5,56(s1)
    8000205e:	ff279be3          	bne	a5,s2,80002054 <reparent+0x2c>
      pp->parent = initproc;
    80002062:	000a3503          	ld	a0,0(s4)
    80002066:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002068:	f5bff0ef          	jal	80001fc2 <wakeup>
    8000206c:	b7e5                	j	80002054 <reparent+0x2c>
}
    8000206e:	70a2                	ld	ra,40(sp)
    80002070:	7402                	ld	s0,32(sp)
    80002072:	64e2                	ld	s1,24(sp)
    80002074:	6942                	ld	s2,16(sp)
    80002076:	69a2                	ld	s3,8(sp)
    80002078:	6a02                	ld	s4,0(sp)
    8000207a:	6145                	addi	sp,sp,48
    8000207c:	8082                	ret

000000008000207e <kexit>:
{
    8000207e:	7179                	addi	sp,sp,-48
    80002080:	f406                	sd	ra,40(sp)
    80002082:	f022                	sd	s0,32(sp)
    80002084:	ec26                	sd	s1,24(sp)
    80002086:	e84a                	sd	s2,16(sp)
    80002088:	e44e                	sd	s3,8(sp)
    8000208a:	e052                	sd	s4,0(sp)
    8000208c:	1800                	addi	s0,sp,48
    8000208e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002090:	8b9ff0ef          	jal	80001948 <myproc>
    80002094:	89aa                	mv	s3,a0
  if (p == initproc)
    80002096:	00008797          	auipc	a5,0x8
    8000209a:	2ca7b783          	ld	a5,714(a5) # 8000a360 <initproc>
    8000209e:	0d050493          	addi	s1,a0,208
    800020a2:	15050913          	addi	s2,a0,336
    800020a6:	00a79b63          	bne	a5,a0,800020bc <kexit+0x3e>
    panic("init exiting");
    800020aa:	00005517          	auipc	a0,0x5
    800020ae:	15650513          	addi	a0,a0,342 # 80007200 <etext+0x200>
    800020b2:	f82fe0ef          	jal	80000834 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    800020b6:	04a1                	addi	s1,s1,8
    800020b8:	01248963          	beq	s1,s2,800020ca <kexit+0x4c>
    if (p->ofile[fd]) {
    800020bc:	6088                	ld	a0,0(s1)
    800020be:	dd65                	beqz	a0,800020b6 <kexit+0x38>
      fileclose(f);
    800020c0:	122020ef          	jal	800041e2 <fileclose>
      p->ofile[fd] = 0;
    800020c4:	0004b023          	sd	zero,0(s1)
    800020c8:	b7fd                	j	800020b6 <kexit+0x38>
  begin_op();
    800020ca:	45f010ef          	jal	80003d28 <begin_op>
  iput(p->cwd);
    800020ce:	1509b503          	ld	a0,336(s3)
    800020d2:	360010ef          	jal	80003432 <iput>
  end_op();
    800020d6:	4df010ef          	jal	80003db4 <end_op>
  p->cwd = 0;
    800020da:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800020de:	00010517          	auipc	a0,0x10
    800020e2:	3a250513          	addi	a0,a0,930 # 80012480 <wait_lock>
    800020e6:	b43fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    800020ea:	854e                	mv	a0,s3
    800020ec:	f3dff0ef          	jal	80002028 <reparent>
  wakeup(p->parent);
    800020f0:	0389b503          	ld	a0,56(s3)
    800020f4:	ecfff0ef          	jal	80001fc2 <wakeup>
  acquire(&p->lock);
    800020f8:	854e                	mv	a0,s3
    800020fa:	b2ffe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    800020fe:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002102:	4795                	li	a5,5
    80002104:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002108:	00010517          	auipc	a0,0x10
    8000210c:	37850513          	addi	a0,a0,888 # 80012480 <wait_lock>
    80002110:	ba1fe0ef          	jal	80000cb0 <release>
  sched();
    80002114:	d5bff0ef          	jal	80001e6e <sched>
  panic("zombie exit");
    80002118:	00005517          	auipc	a0,0x5
    8000211c:	0f850513          	addi	a0,a0,248 # 80007210 <etext+0x210>
    80002120:	f14fe0ef          	jal	80000834 <panic>

0000000080002124 <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    80002124:	c525                	beqz	a0,8000218c <kkill+0x68>
{
    80002126:	7179                	addi	sp,sp,-48
    80002128:	f406                	sd	ra,40(sp)
    8000212a:	f022                	sd	s0,32(sp)
    8000212c:	ec26                	sd	s1,24(sp)
    8000212e:	e84a                	sd	s2,16(sp)
    80002130:	e44e                	sd	s3,8(sp)
    80002132:	1800                	addi	s0,sp,48
    80002134:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002136:	00010497          	auipc	s1,0x10
    8000213a:	76248493          	addi	s1,s1,1890 # 80012898 <proc>
    8000213e:	00016997          	auipc	s3,0x16
    80002142:	35a98993          	addi	s3,s3,858 # 80018498 <tickslock>
    acquire(&p->lock);
    80002146:	8526                	mv	a0,s1
    80002148:	ae1fe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid) {
    8000214c:	589c                	lw	a5,48(s1)
    8000214e:	01278b63          	beq	a5,s2,80002164 <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002152:	8526                	mv	a0,s1
    80002154:	b5dfe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002158:	17048493          	addi	s1,s1,368
    8000215c:	ff3495e3          	bne	s1,s3,80002146 <kkill+0x22>
  }
  return -1;
    80002160:	557d                	li	a0,-1
    80002162:	a819                	j	80002178 <kkill+0x54>
      p->killed = 1;
    80002164:	4785                	li	a5,1
    80002166:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    80002168:	4c98                	lw	a4,24(s1)
    8000216a:	4789                	li	a5,2
    8000216c:	00f70d63          	beq	a4,a5,80002186 <kkill+0x62>
      release(&p->lock);
    80002170:	8526                	mv	a0,s1
    80002172:	b3ffe0ef          	jal	80000cb0 <release>
      return 0;
    80002176:	4501                	li	a0,0
}
    80002178:	70a2                	ld	ra,40(sp)
    8000217a:	7402                	ld	s0,32(sp)
    8000217c:	64e2                	ld	s1,24(sp)
    8000217e:	6942                	ld	s2,16(sp)
    80002180:	69a2                	ld	s3,8(sp)
    80002182:	6145                	addi	sp,sp,48
    80002184:	8082                	ret
        p->state = RUNNABLE;
    80002186:	478d                	li	a5,3
    80002188:	cc9c                	sw	a5,24(s1)
    8000218a:	b7dd                	j	80002170 <kkill+0x4c>
    return -1;
    8000218c:	557d                	li	a0,-1
}
    8000218e:	8082                	ret

0000000080002190 <setkilled>:

void
setkilled(struct proc *p)
{
    80002190:	1101                	addi	sp,sp,-32
    80002192:	ec06                	sd	ra,24(sp)
    80002194:	e822                	sd	s0,16(sp)
    80002196:	e426                	sd	s1,8(sp)
    80002198:	1000                	addi	s0,sp,32
    8000219a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000219c:	a8dfe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    800021a0:	4785                	li	a5,1
    800021a2:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800021a4:	8526                	mv	a0,s1
    800021a6:	b0bfe0ef          	jal	80000cb0 <release>
}
    800021aa:	60e2                	ld	ra,24(sp)
    800021ac:	6442                	ld	s0,16(sp)
    800021ae:	64a2                	ld	s1,8(sp)
    800021b0:	6105                	addi	sp,sp,32
    800021b2:	8082                	ret

00000000800021b4 <killed>:

int
killed(struct proc *p)
{
    800021b4:	1101                	addi	sp,sp,-32
    800021b6:	ec06                	sd	ra,24(sp)
    800021b8:	e822                	sd	s0,16(sp)
    800021ba:	e426                	sd	s1,8(sp)
    800021bc:	e04a                	sd	s2,0(sp)
    800021be:	1000                	addi	s0,sp,32
    800021c0:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800021c2:	a67fe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    800021c6:	549c                	lw	a5,40(s1)
    800021c8:	893e                	mv	s2,a5
  release(&p->lock);
    800021ca:	8526                	mv	a0,s1
    800021cc:	ae5fe0ef          	jal	80000cb0 <release>
  return k;
}
    800021d0:	854a                	mv	a0,s2
    800021d2:	60e2                	ld	ra,24(sp)
    800021d4:	6442                	ld	s0,16(sp)
    800021d6:	64a2                	ld	s1,8(sp)
    800021d8:	6902                	ld	s2,0(sp)
    800021da:	6105                	addi	sp,sp,32
    800021dc:	8082                	ret

00000000800021de <kwait>:
{
    800021de:	715d                	addi	sp,sp,-80
    800021e0:	e486                	sd	ra,72(sp)
    800021e2:	e0a2                	sd	s0,64(sp)
    800021e4:	fc26                	sd	s1,56(sp)
    800021e6:	f84a                	sd	s2,48(sp)
    800021e8:	f44e                	sd	s3,40(sp)
    800021ea:	f052                	sd	s4,32(sp)
    800021ec:	ec56                	sd	s5,24(sp)
    800021ee:	e85a                	sd	s6,16(sp)
    800021f0:	e45e                	sd	s7,8(sp)
    800021f2:	0880                	addi	s0,sp,80
    800021f4:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800021f6:	f52ff0ef          	jal	80001948 <myproc>
    800021fa:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800021fc:	00010517          	auipc	a0,0x10
    80002200:	28450513          	addi	a0,a0,644 # 80012480 <wait_lock>
    80002204:	a25fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    80002208:	4a15                	li	s4,5
        havekids = 1;
    8000220a:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000220c:	00016997          	auipc	s3,0x16
    80002210:	28c98993          	addi	s3,s3,652 # 80018498 <tickslock>
    release(&wait_lock);
    80002214:	00010b17          	auipc	s6,0x10
    80002218:	26cb0b13          	addi	s6,s6,620 # 80012480 <wait_lock>
    8000221c:	a845                	j	800022cc <kwait+0xee>
          pid = pp->pid;
    8000221e:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    80002222:	000b8e63          	beqz	s7,8000223e <kwait+0x60>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    80002226:	4711                	li	a4,4
    80002228:	02c48693          	addi	a3,s1,44
    8000222c:	865e                	mv	a2,s7
    8000222e:	04893583          	ld	a1,72(s2)
    80002232:	05093503          	ld	a0,80(s2)
    80002236:	b4cff0ef          	jal	80001582 <copyout>
          if (addr != 0 &&
    8000223a:	02054c63          	bltz	a0,80002272 <kwait+0x94>
          pp->parent = 0;
    8000223e:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    80002242:	8526                	mv	a0,s1
    80002244:	8d5ff0ef          	jal	80001b18 <freeproc>
          release(&pp->lock);
    80002248:	8526                	mv	a0,s1
    8000224a:	a67fe0ef          	jal	80000cb0 <release>
          release(&wait_lock);
    8000224e:	00010517          	auipc	a0,0x10
    80002252:	23250513          	addi	a0,a0,562 # 80012480 <wait_lock>
    80002256:	a5bfe0ef          	jal	80000cb0 <release>
}
    8000225a:	854e                	mv	a0,s3
    8000225c:	60a6                	ld	ra,72(sp)
    8000225e:	6406                	ld	s0,64(sp)
    80002260:	74e2                	ld	s1,56(sp)
    80002262:	7942                	ld	s2,48(sp)
    80002264:	79a2                	ld	s3,40(sp)
    80002266:	7a02                	ld	s4,32(sp)
    80002268:	6ae2                	ld	s5,24(sp)
    8000226a:	6b42                	ld	s6,16(sp)
    8000226c:	6ba2                	ld	s7,8(sp)
    8000226e:	6161                	addi	sp,sp,80
    80002270:	8082                	ret
            release(&pp->lock);
    80002272:	8526                	mv	a0,s1
    80002274:	a3dfe0ef          	jal	80000cb0 <release>
            release(&wait_lock);
    80002278:	00010517          	auipc	a0,0x10
    8000227c:	20850513          	addi	a0,a0,520 # 80012480 <wait_lock>
    80002280:	a31fe0ef          	jal	80000cb0 <release>
            return -1;
    80002284:	59fd                	li	s3,-1
    80002286:	bfd1                	j	8000225a <kwait+0x7c>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002288:	17048493          	addi	s1,s1,368
    8000228c:	03348063          	beq	s1,s3,800022ac <kwait+0xce>
      if (pp->parent == p) {
    80002290:	7c9c                	ld	a5,56(s1)
    80002292:	ff279be3          	bne	a5,s2,80002288 <kwait+0xaa>
        acquire(&pp->lock);
    80002296:	8526                	mv	a0,s1
    80002298:	991fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    8000229c:	4c9c                	lw	a5,24(s1)
    8000229e:	f94780e3          	beq	a5,s4,8000221e <kwait+0x40>
        release(&pp->lock);
    800022a2:	8526                	mv	a0,s1
    800022a4:	a0dfe0ef          	jal	80000cb0 <release>
        havekids = 1;
    800022a8:	8756                	mv	a4,s5
    800022aa:	bff9                	j	80002288 <kwait+0xaa>
    if (!havekids || killed(p)) {
    800022ac:	c715                	beqz	a4,800022d8 <kwait+0xfa>
    800022ae:	854a                	mv	a0,s2
    800022b0:	f05ff0ef          	jal	800021b4 <killed>
    800022b4:	e115                	bnez	a0,800022d8 <kwait+0xfa>
    sleep_prepare(p); //DOC: wait-sleep
    800022b6:	854a                	mv	a0,s2
    800022b8:	c9fff0ef          	jal	80001f56 <sleep_prepare>
    release(&wait_lock);
    800022bc:	855a                	mv	a0,s6
    800022be:	9f3fe0ef          	jal	80000cb0 <release>
    sleep();
    800022c2:	cd1ff0ef          	jal	80001f92 <sleep>
    acquire(&wait_lock);
    800022c6:	855a                	mv	a0,s6
    800022c8:	961fe0ef          	jal	80000c28 <acquire>
    havekids = 0;
    800022cc:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800022ce:	00010497          	auipc	s1,0x10
    800022d2:	5ca48493          	addi	s1,s1,1482 # 80012898 <proc>
    800022d6:	bf6d                	j	80002290 <kwait+0xb2>
      release(&wait_lock);
    800022d8:	00010517          	auipc	a0,0x10
    800022dc:	1a850513          	addi	a0,a0,424 # 80012480 <wait_lock>
    800022e0:	9d1fe0ef          	jal	80000cb0 <release>
      return -1;
    800022e4:	59fd                	li	s3,-1
    800022e6:	bf95                	j	8000225a <kwait+0x7c>

00000000800022e8 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800022e8:	7179                	addi	sp,sp,-48
    800022ea:	f406                	sd	ra,40(sp)
    800022ec:	f022                	sd	s0,32(sp)
    800022ee:	ec26                	sd	s1,24(sp)
    800022f0:	e84a                	sd	s2,16(sp)
    800022f2:	e44e                	sd	s3,8(sp)
    800022f4:	e052                	sd	s4,0(sp)
    800022f6:	1800                	addi	s0,sp,48
    800022f8:	84aa                	mv	s1,a0
    800022fa:	8a2e                	mv	s4,a1
    800022fc:	89b2                	mv	s3,a2
    800022fe:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002300:	e48ff0ef          	jal	80001948 <myproc>
  if (user_dst) {
    80002304:	c085                	beqz	s1,80002324 <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    80002306:	874a                	mv	a4,s2
    80002308:	86ce                	mv	a3,s3
    8000230a:	8652                	mv	a2,s4
    8000230c:	652c                	ld	a1,72(a0)
    8000230e:	6928                	ld	a0,80(a0)
    80002310:	a72ff0ef          	jal	80001582 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002314:	70a2                	ld	ra,40(sp)
    80002316:	7402                	ld	s0,32(sp)
    80002318:	64e2                	ld	s1,24(sp)
    8000231a:	6942                	ld	s2,16(sp)
    8000231c:	69a2                	ld	s3,8(sp)
    8000231e:	6a02                	ld	s4,0(sp)
    80002320:	6145                	addi	sp,sp,48
    80002322:	8082                	ret
    memmove((char *)dst, src, len);
    80002324:	0009061b          	sext.w	a2,s2
    80002328:	85ce                	mv	a1,s3
    8000232a:	8552                	mv	a0,s4
    8000232c:	a1dfe0ef          	jal	80000d48 <memmove>
    return 0;
    80002330:	8526                	mv	a0,s1
    80002332:	b7cd                	j	80002314 <either_copyout+0x2c>

0000000080002334 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002334:	7179                	addi	sp,sp,-48
    80002336:	f406                	sd	ra,40(sp)
    80002338:	f022                	sd	s0,32(sp)
    8000233a:	ec26                	sd	s1,24(sp)
    8000233c:	e84a                	sd	s2,16(sp)
    8000233e:	e44e                	sd	s3,8(sp)
    80002340:	e052                	sd	s4,0(sp)
    80002342:	1800                	addi	s0,sp,48
    80002344:	8a2a                	mv	s4,a0
    80002346:	84ae                	mv	s1,a1
    80002348:	89b2                	mv	s3,a2
    8000234a:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000234c:	dfcff0ef          	jal	80001948 <myproc>
  if (user_src) {
    80002350:	c085                	beqz	s1,80002370 <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    80002352:	874a                	mv	a4,s2
    80002354:	86ce                	mv	a3,s3
    80002356:	8652                	mv	a2,s4
    80002358:	652c                	ld	a1,72(a0)
    8000235a:	6928                	ld	a0,80(a0)
    8000235c:	aecff0ef          	jal	80001648 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002360:	70a2                	ld	ra,40(sp)
    80002362:	7402                	ld	s0,32(sp)
    80002364:	64e2                	ld	s1,24(sp)
    80002366:	6942                	ld	s2,16(sp)
    80002368:	69a2                	ld	s3,8(sp)
    8000236a:	6a02                	ld	s4,0(sp)
    8000236c:	6145                	addi	sp,sp,48
    8000236e:	8082                	ret
    memmove(dst, (char *)src, len);
    80002370:	0009061b          	sext.w	a2,s2
    80002374:	85ce                	mv	a1,s3
    80002376:	8552                	mv	a0,s4
    80002378:	9d1fe0ef          	jal	80000d48 <memmove>
    return 0;
    8000237c:	8526                	mv	a0,s1
    8000237e:	b7cd                	j	80002360 <either_copyin+0x2c>

0000000080002380 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002380:	715d                	addi	sp,sp,-80
    80002382:	e486                	sd	ra,72(sp)
    80002384:	e0a2                	sd	s0,64(sp)
    80002386:	fc26                	sd	s1,56(sp)
    80002388:	f84a                	sd	s2,48(sp)
    8000238a:	f44e                	sd	s3,40(sp)
    8000238c:	f052                	sd	s4,32(sp)
    8000238e:	ec56                	sd	s5,24(sp)
    80002390:	e85a                	sd	s6,16(sp)
    80002392:	e45e                	sd	s7,8(sp)
    80002394:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    80002396:	00005517          	auipc	a0,0x5
    8000239a:	ce250513          	addi	a0,a0,-798 # 80007078 <etext+0x78>
    8000239e:	96cfe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800023a2:	00010497          	auipc	s1,0x10
    800023a6:	64e48493          	addi	s1,s1,1614 # 800129f0 <proc+0x158>
    800023aa:	00016917          	auipc	s2,0x16
    800023ae:	24690913          	addi	s2,s2,582 # 800185f0 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023b2:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800023b4:	00005997          	auipc	s3,0x5
    800023b8:	e6c98993          	addi	s3,s3,-404 # 80007220 <etext+0x220>
    printk("%d %s %s", p->pid, state, p->name);
    800023bc:	00005a97          	auipc	s5,0x5
    800023c0:	e6ca8a93          	addi	s5,s5,-404 # 80007228 <etext+0x228>
    printk("\n");
    800023c4:	00005a17          	auipc	s4,0x5
    800023c8:	cb4a0a13          	addi	s4,s4,-844 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023cc:	00005b97          	auipc	s7,0x5
    800023d0:	3bcb8b93          	addi	s7,s7,956 # 80007788 <states.0>
    800023d4:	a829                	j	800023ee <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    800023d6:	ed86a583          	lw	a1,-296(a3)
    800023da:	8556                	mv	a0,s5
    800023dc:	92efe0ef          	jal	8000050a <printk>
    printk("\n");
    800023e0:	8552                	mv	a0,s4
    800023e2:	928fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800023e6:	17048493          	addi	s1,s1,368
    800023ea:	03248263          	beq	s1,s2,8000240e <procdump+0x8e>
    if (p->state == UNUSED)
    800023ee:	86a6                	mv	a3,s1
    800023f0:	ec04a783          	lw	a5,-320(s1)
    800023f4:	dbed                	beqz	a5,800023e6 <procdump+0x66>
      state = "???";
    800023f6:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023f8:	fcfb6fe3          	bltu	s6,a5,800023d6 <procdump+0x56>
    800023fc:	02079713          	slli	a4,a5,0x20
    80002400:	01d75793          	srli	a5,a4,0x1d
    80002404:	97de                	add	a5,a5,s7
    80002406:	6390                	ld	a2,0(a5)
    80002408:	f679                	bnez	a2,800023d6 <procdump+0x56>
      state = "???";
    8000240a:	864e                	mv	a2,s3
    8000240c:	b7e9                	j	800023d6 <procdump+0x56>
  }
}
    8000240e:	60a6                	ld	ra,72(sp)
    80002410:	6406                	ld	s0,64(sp)
    80002412:	74e2                	ld	s1,56(sp)
    80002414:	7942                	ld	s2,48(sp)
    80002416:	79a2                	ld	s3,40(sp)
    80002418:	7a02                	ld	s4,32(sp)
    8000241a:	6ae2                	ld	s5,24(sp)
    8000241c:	6b42                	ld	s6,16(sp)
    8000241e:	6ba2                	ld	s7,8(sp)
    80002420:	6161                	addi	sp,sp,80
    80002422:	8082                	ret

0000000080002424 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002424:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002428:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000242c:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000242e:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002430:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002434:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002438:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    8000243c:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002440:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002444:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002448:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000244c:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002450:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002454:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002458:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000245c:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002460:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002462:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002464:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002468:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000246c:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002470:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002474:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002478:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000247c:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002480:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002484:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002488:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000248c:	8082                	ret

000000008000248e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000248e:	1141                	addi	sp,sp,-16
    80002490:	e406                	sd	ra,8(sp)
    80002492:	e022                	sd	s0,0(sp)
    80002494:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002496:	00005597          	auipc	a1,0x5
    8000249a:	dd258593          	addi	a1,a1,-558 # 80007268 <etext+0x268>
    8000249e:	00016517          	auipc	a0,0x16
    800024a2:	ffa50513          	addi	a0,a0,-6 # 80018498 <tickslock>
    800024a6:	f02fe0ef          	jal	80000ba8 <initlock>
}
    800024aa:	60a2                	ld	ra,8(sp)
    800024ac:	6402                	ld	s0,0(sp)
    800024ae:	0141                	addi	sp,sp,16
    800024b0:	8082                	ret

00000000800024b2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800024b2:	1141                	addi	sp,sp,-16
    800024b4:	e406                	sd	ra,8(sp)
    800024b6:	e022                	sd	s0,0(sp)
    800024b8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    800024ba:	00003797          	auipc	a5,0x3
    800024be:	1b678793          	addi	a5,a5,438 # 80005670 <kernelvec>
    800024c2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800024c6:	60a2                	ld	ra,8(sp)
    800024c8:	6402                	ld	s0,0(sp)
    800024ca:	0141                	addi	sp,sp,16
    800024cc:	8082                	ret

00000000800024ce <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800024ce:	1141                	addi	sp,sp,-16
    800024d0:	e406                	sd	ra,8(sp)
    800024d2:	e022                	sd	s0,0(sp)
    800024d4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800024d6:	c72ff0ef          	jal	80001948 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    800024da:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800024de:	04000737          	lui	a4,0x4000
    800024e2:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800024e4:	0732                	slli	a4,a4,0xc
    800024e6:	00004797          	auipc	a5,0x4
    800024ea:	b1a78793          	addi	a5,a5,-1254 # 80006000 <_trampoline>
    800024ee:	00004697          	auipc	a3,0x4
    800024f2:	b1268693          	addi	a3,a3,-1262 # 80006000 <_trampoline>
    800024f6:	8f95                	sub	a5,a5,a3
    800024f8:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    800024fa:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800024fe:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    80002500:	18002773          	csrr	a4,satp
    80002504:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002506:	6d38                	ld	a4,88(a0)
    80002508:	613c                	ld	a5,64(a0)
    8000250a:	6685                	lui	a3,0x1
    8000250c:	97b6                	add	a5,a5,a3
    8000250e:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002510:	6d3c                	ld	a5,88(a0)
    80002512:	00000717          	auipc	a4,0x0
    80002516:	0fc70713          	addi	a4,a4,252 # 8000260e <usertrap>
    8000251a:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    8000251c:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    8000251e:	8712                	mv	a4,tp
    80002520:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002522:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002526:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000252a:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    8000252e:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002532:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002534:	6f9c                	ld	a5,24(a5)
    80002536:	14179073          	csrw	sepc,a5
}
    8000253a:	60a2                	ld	ra,8(sp)
    8000253c:	6402                	ld	s0,0(sp)
    8000253e:	0141                	addi	sp,sp,16
    80002540:	8082                	ret

0000000080002542 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002542:	1141                	addi	sp,sp,-16
    80002544:	e406                	sd	ra,8(sp)
    80002546:	e022                	sd	s0,0(sp)
    80002548:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    8000254a:	bcaff0ef          	jal	80001914 <cpuid>
    8000254e:	cd11                	beqz	a0,8000256a <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    80002550:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002554:	000f4737          	lui	a4,0xf4
    80002558:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000255c:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000255e:	14d79073          	csrw	stimecmp,a5
}
    80002562:	60a2                	ld	ra,8(sp)
    80002564:	6402                	ld	s0,0(sp)
    80002566:	0141                	addi	sp,sp,16
    80002568:	8082                	ret
    acquire(&tickslock);
    8000256a:	00016517          	auipc	a0,0x16
    8000256e:	f2e50513          	addi	a0,a0,-210 # 80018498 <tickslock>
    80002572:	eb6fe0ef          	jal	80000c28 <acquire>
    ticks++;
    80002576:	00008717          	auipc	a4,0x8
    8000257a:	df270713          	addi	a4,a4,-526 # 8000a368 <ticks>
    8000257e:	431c                	lw	a5,0(a4)
    80002580:	2785                	addiw	a5,a5,1
    80002582:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002584:	853a                	mv	a0,a4
    80002586:	a3dff0ef          	jal	80001fc2 <wakeup>
    release(&tickslock);
    8000258a:	00016517          	auipc	a0,0x16
    8000258e:	f0e50513          	addi	a0,a0,-242 # 80018498 <tickslock>
    80002592:	f1efe0ef          	jal	80000cb0 <release>
    80002596:	bf6d                	j	80002550 <clockintr+0xe>

0000000080002598 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002598:	1101                	addi	sp,sp,-32
    8000259a:	ec06                	sd	ra,24(sp)
    8000259c:	e822                	sd	s0,16(sp)
    8000259e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    800025a0:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    800025a4:	57fd                	li	a5,-1
    800025a6:	17fe                	slli	a5,a5,0x3f
    800025a8:	07a5                	addi	a5,a5,9
    800025aa:	00f70c63          	beq	a4,a5,800025c2 <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    800025ae:	57fd                	li	a5,-1
    800025b0:	17fe                	slli	a5,a5,0x3f
    800025b2:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800025b4:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    800025b6:	04f70863          	beq	a4,a5,80002606 <devintr+0x6e>
  }
}
    800025ba:	60e2                	ld	ra,24(sp)
    800025bc:	6442                	ld	s0,16(sp)
    800025be:	6105                	addi	sp,sp,32
    800025c0:	8082                	ret
    800025c2:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800025c4:	15a030ef          	jal	8000571e <plic_claim>
    800025c8:	872a                	mv	a4,a0
    800025ca:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    800025cc:	47a9                	li	a5,10
    800025ce:	00f50963          	beq	a0,a5,800025e0 <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    800025d2:	4785                	li	a5,1
    800025d4:	00f50963          	beq	a0,a5,800025e6 <devintr+0x4e>
    return 1;
    800025d8:	4505                	li	a0,1
    } else if (irq) {
    800025da:	eb09                	bnez	a4,800025ec <devintr+0x54>
    800025dc:	64a2                	ld	s1,8(sp)
    800025de:	bff1                	j	800025ba <devintr+0x22>
      uartintr();
    800025e0:	c0efe0ef          	jal	800009ee <uartintr>
    if (irq)
    800025e4:	a819                	j	800025fa <devintr+0x62>
      virtio_disk_intr();
    800025e6:	5f4030ef          	jal	80005bda <virtio_disk_intr>
    if (irq)
    800025ea:	a801                	j	800025fa <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    800025ec:	85ba                	mv	a1,a4
    800025ee:	00005517          	auipc	a0,0x5
    800025f2:	c8250513          	addi	a0,a0,-894 # 80007270 <etext+0x270>
    800025f6:	f15fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    800025fa:	8526                	mv	a0,s1
    800025fc:	144030ef          	jal	80005740 <plic_complete>
    return 1;
    80002600:	4505                	li	a0,1
    80002602:	64a2                	ld	s1,8(sp)
    80002604:	bf5d                	j	800025ba <devintr+0x22>
    clockintr();
    80002606:	f3dff0ef          	jal	80002542 <clockintr>
    return 2;
    8000260a:	4509                	li	a0,2
    8000260c:	b77d                	j	800025ba <devintr+0x22>

000000008000260e <usertrap>:
{
    8000260e:	1101                	addi	sp,sp,-32
    80002610:	ec06                	sd	ra,24(sp)
    80002612:	e822                	sd	s0,16(sp)
    80002614:	e426                	sd	s1,8(sp)
    80002616:	e04a                	sd	s2,0(sp)
    80002618:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000261a:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    8000261e:	1007f793          	andi	a5,a5,256
    80002622:	efbd                	bnez	a5,800026a0 <usertrap+0x92>
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002624:	00003797          	auipc	a5,0x3
    80002628:	04c78793          	addi	a5,a5,76 # 80005670 <kernelvec>
    8000262c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002630:	b18ff0ef          	jal	80001948 <myproc>
    80002634:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002636:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002638:	14102773          	csrr	a4,sepc
    8000263c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    8000263e:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    80002642:	47a1                	li	a5,8
    80002644:	06f70463          	beq	a4,a5,800026ac <usertrap+0x9e>
  } else if ((which_dev = devintr()) != 0) {
    80002648:	f51ff0ef          	jal	80002598 <devintr>
    8000264c:	892a                	mv	s2,a0
    8000264e:	0e051563          	bnez	a0,80002738 <usertrap+0x12a>
    80002652:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002656:	47bd                	li	a5,15
    80002658:	08f70a63          	beq	a4,a5,800026ec <usertrap+0xde>
    8000265c:	14202773          	csrr	a4,scause
    80002660:	47b5                	li	a5,13
    80002662:	08f70563          	beq	a4,a5,800026ec <usertrap+0xde>
    80002666:	14202773          	csrr	a4,scause
    if (r_scause() == 15 || r_scause() == 13 || r_scause() == 12) {
    8000266a:	47bd                	li	a5,15
    8000266c:	00f70c63          	beq	a4,a5,80002684 <usertrap+0x76>
    80002670:	14202773          	csrr	a4,scause
    80002674:	47b5                	li	a5,13
    80002676:	00f70763          	beq	a4,a5,80002684 <usertrap+0x76>
    8000267a:	14202773          	csrr	a4,scause
    8000267e:	47b1                	li	a5,12
    80002680:	08f71863          	bne	a4,a5,80002710 <usertrap+0x102>
  asm volatile("csrr %0, stval" : "=r"(x));
    80002684:	14302673          	csrr	a2,stval
      printk("Page fault: pid=%d address=0x%lx exceeds size=0x%lx (killed)\n",
    80002688:	64b4                	ld	a3,72(s1)
    8000268a:	588c                	lw	a1,48(s1)
    8000268c:	00005517          	auipc	a0,0x5
    80002690:	c2450513          	addi	a0,a0,-988 # 800072b0 <etext+0x2b0>
    80002694:	e77fd0ef          	jal	8000050a <printk>
    setkilled(p);
    80002698:	8526                	mv	a0,s1
    8000269a:	af7ff0ef          	jal	80002190 <setkilled>
    8000269e:	a015                	j	800026c2 <usertrap+0xb4>
    panic("usertrap: not from user mode");
    800026a0:	00005517          	auipc	a0,0x5
    800026a4:	bf050513          	addi	a0,a0,-1040 # 80007290 <etext+0x290>
    800026a8:	98cfe0ef          	jal	80000834 <panic>
    if (killed(p))
    800026ac:	b09ff0ef          	jal	800021b4 <killed>
    800026b0:	e915                	bnez	a0,800026e4 <usertrap+0xd6>
    p->trapframe->epc += 4;
    800026b2:	6cb8                	ld	a4,88(s1)
    800026b4:	6f1c                	ld	a5,24(a4)
    800026b6:	0791                	addi	a5,a5,4
    800026b8:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    800026ba:	10016073          	csrsi	sstatus,2
    syscall();
    800026be:	276000ef          	jal	80002934 <syscall>
  if (killed(p))
    800026c2:	8526                	mv	a0,s1
    800026c4:	af1ff0ef          	jal	800021b4 <killed>
    800026c8:	ed2d                	bnez	a0,80002742 <usertrap+0x134>
  prepare_return();
    800026ca:	e05ff0ef          	jal	800024ce <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800026ce:	68a8                	ld	a0,80(s1)
    800026d0:	8131                	srli	a0,a0,0xc
    800026d2:	57fd                	li	a5,-1
    800026d4:	17fe                	slli	a5,a5,0x3f
    800026d6:	8d5d                	or	a0,a0,a5
}
    800026d8:	60e2                	ld	ra,24(sp)
    800026da:	6442                	ld	s0,16(sp)
    800026dc:	64a2                	ld	s1,8(sp)
    800026de:	6902                	ld	s2,0(sp)
    800026e0:	6105                	addi	sp,sp,32
    800026e2:	8082                	ret
      kexit(-1);
    800026e4:	557d                	li	a0,-1
    800026e6:	999ff0ef          	jal	8000207e <kexit>
    800026ea:	b7e1                	j	800026b2 <usertrap+0xa4>
  asm volatile("csrr %0, stval" : "=r"(x));
    800026ec:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    800026f0:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    800026f4:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    800026f6:	0016b693          	seqz	a3,a3
    800026fa:	64ac                	ld	a1,72(s1)
    800026fc:	68a8                	ld	a0,80(s1)
    800026fe:	e09fe0ef          	jal	80001506 <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002702:	d135                	beqz	a0,80002666 <usertrap+0x58>
    p->page_faults++;
    80002704:	1684b783          	ld	a5,360(s1)
    80002708:	0785                	addi	a5,a5,1
    8000270a:	16f4b423          	sd	a5,360(s1)
    8000270e:	bf55                	j	800026c2 <usertrap+0xb4>
    80002710:	142025f3          	csrr	a1,scause
      printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002714:	5890                	lw	a2,48(s1)
    80002716:	00005517          	auipc	a0,0x5
    8000271a:	bda50513          	addi	a0,a0,-1062 # 800072f0 <etext+0x2f0>
    8000271e:	dedfd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002722:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002726:	14302673          	csrr	a2,stval
      printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000272a:	00005517          	auipc	a0,0x5
    8000272e:	bf650513          	addi	a0,a0,-1034 # 80007320 <etext+0x320>
    80002732:	dd9fd0ef          	jal	8000050a <printk>
    80002736:	b78d                	j	80002698 <usertrap+0x8a>
  if (killed(p))
    80002738:	8526                	mv	a0,s1
    8000273a:	a7bff0ef          	jal	800021b4 <killed>
    8000273e:	c511                	beqz	a0,8000274a <usertrap+0x13c>
    80002740:	a011                	j	80002744 <usertrap+0x136>
    80002742:	4901                	li	s2,0
    kexit(-1);
    80002744:	557d                	li	a0,-1
    80002746:	939ff0ef          	jal	8000207e <kexit>
  if (which_dev == 2)
    8000274a:	4789                	li	a5,2
    8000274c:	f6f91fe3          	bne	s2,a5,800026ca <usertrap+0xbc>
    yield();
    80002750:	fdaff0ef          	jal	80001f2a <yield>
    80002754:	bf9d                	j	800026ca <usertrap+0xbc>

0000000080002756 <kerneltrap>:
{
    80002756:	7179                	addi	sp,sp,-48
    80002758:	f406                	sd	ra,40(sp)
    8000275a:	f022                	sd	s0,32(sp)
    8000275c:	ec26                	sd	s1,24(sp)
    8000275e:	e84a                	sd	s2,16(sp)
    80002760:	e44e                	sd	s3,8(sp)
    80002762:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002764:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002768:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    8000276c:	142027f3          	csrr	a5,scause
    80002770:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    80002772:	1004f793          	andi	a5,s1,256
    80002776:	c795                	beqz	a5,800027a2 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002778:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000277c:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    8000277e:	eb85                	bnez	a5,800027ae <kerneltrap+0x58>
  if ((which_dev = devintr()) == 0) {
    80002780:	e19ff0ef          	jal	80002598 <devintr>
    80002784:	c91d                	beqz	a0,800027ba <kerneltrap+0x64>
  if (which_dev == 2 && myproc() != 0)
    80002786:	4789                	li	a5,2
    80002788:	04f50a63          	beq	a0,a5,800027dc <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    8000278c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002790:	10049073          	csrw	sstatus,s1
}
    80002794:	70a2                	ld	ra,40(sp)
    80002796:	7402                	ld	s0,32(sp)
    80002798:	64e2                	ld	s1,24(sp)
    8000279a:	6942                	ld	s2,16(sp)
    8000279c:	69a2                	ld	s3,8(sp)
    8000279e:	6145                	addi	sp,sp,48
    800027a0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800027a2:	00005517          	auipc	a0,0x5
    800027a6:	ba650513          	addi	a0,a0,-1114 # 80007348 <etext+0x348>
    800027aa:	88afe0ef          	jal	80000834 <panic>
    panic("kerneltrap: interrupts enabled");
    800027ae:	00005517          	auipc	a0,0x5
    800027b2:	bc250513          	addi	a0,a0,-1086 # 80007370 <etext+0x370>
    800027b6:	87efe0ef          	jal	80000834 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800027ba:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800027be:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    800027c2:	85ce                	mv	a1,s3
    800027c4:	00005517          	auipc	a0,0x5
    800027c8:	bcc50513          	addi	a0,a0,-1076 # 80007390 <etext+0x390>
    800027cc:	d3ffd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    800027d0:	00005517          	auipc	a0,0x5
    800027d4:	be850513          	addi	a0,a0,-1048 # 800073b8 <etext+0x3b8>
    800027d8:	85cfe0ef          	jal	80000834 <panic>
  if (which_dev == 2 && myproc() != 0)
    800027dc:	96cff0ef          	jal	80001948 <myproc>
    800027e0:	d555                	beqz	a0,8000278c <kerneltrap+0x36>
    yield();
    800027e2:	f48ff0ef          	jal	80001f2a <yield>
    800027e6:	b75d                	j	8000278c <kerneltrap+0x36>

00000000800027e8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800027e8:	1101                	addi	sp,sp,-32
    800027ea:	ec06                	sd	ra,24(sp)
    800027ec:	e822                	sd	s0,16(sp)
    800027ee:	e426                	sd	s1,8(sp)
    800027f0:	1000                	addi	s0,sp,32
    800027f2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800027f4:	954ff0ef          	jal	80001948 <myproc>
  switch (n) {
    800027f8:	4795                	li	a5,5
    800027fa:	0497e163          	bltu	a5,s1,8000283c <argraw+0x54>
    800027fe:	048a                	slli	s1,s1,0x2
    80002800:	00005717          	auipc	a4,0x5
    80002804:	fb870713          	addi	a4,a4,-72 # 800077b8 <states.0+0x30>
    80002808:	94ba                	add	s1,s1,a4
    8000280a:	409c                	lw	a5,0(s1)
    8000280c:	97ba                	add	a5,a5,a4
    8000280e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002810:	6d3c                	ld	a5,88(a0)
    80002812:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002814:	60e2                	ld	ra,24(sp)
    80002816:	6442                	ld	s0,16(sp)
    80002818:	64a2                	ld	s1,8(sp)
    8000281a:	6105                	addi	sp,sp,32
    8000281c:	8082                	ret
    return p->trapframe->a1;
    8000281e:	6d3c                	ld	a5,88(a0)
    80002820:	7fa8                	ld	a0,120(a5)
    80002822:	bfcd                	j	80002814 <argraw+0x2c>
    return p->trapframe->a2;
    80002824:	6d3c                	ld	a5,88(a0)
    80002826:	63c8                	ld	a0,128(a5)
    80002828:	b7f5                	j	80002814 <argraw+0x2c>
    return p->trapframe->a3;
    8000282a:	6d3c                	ld	a5,88(a0)
    8000282c:	67c8                	ld	a0,136(a5)
    8000282e:	b7dd                	j	80002814 <argraw+0x2c>
    return p->trapframe->a4;
    80002830:	6d3c                	ld	a5,88(a0)
    80002832:	6bc8                	ld	a0,144(a5)
    80002834:	b7c5                	j	80002814 <argraw+0x2c>
    return p->trapframe->a5;
    80002836:	6d3c                	ld	a5,88(a0)
    80002838:	6fc8                	ld	a0,152(a5)
    8000283a:	bfe9                	j	80002814 <argraw+0x2c>
  panic("argraw");
    8000283c:	00005517          	auipc	a0,0x5
    80002840:	b8c50513          	addi	a0,a0,-1140 # 800073c8 <etext+0x3c8>
    80002844:	ff1fd0ef          	jal	80000834 <panic>

0000000080002848 <fetchaddr>:
{
    80002848:	1101                	addi	sp,sp,-32
    8000284a:	ec06                	sd	ra,24(sp)
    8000284c:	e822                	sd	s0,16(sp)
    8000284e:	e426                	sd	s1,8(sp)
    80002850:	e04a                	sd	s2,0(sp)
    80002852:	1000                	addi	s0,sp,32
    80002854:	84aa                	mv	s1,a0
    80002856:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002858:	8f0ff0ef          	jal	80001948 <myproc>
  if (addr >= p->sz ||
    8000285c:	652c                	ld	a1,72(a0)
    8000285e:	02b4f663          	bgeu	s1,a1,8000288a <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002862:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    80002866:	02f5e463          	bltu	a1,a5,8000288e <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    8000286a:	4721                	li	a4,8
    8000286c:	86a6                	mv	a3,s1
    8000286e:	864a                	mv	a2,s2
    80002870:	6928                	ld	a0,80(a0)
    80002872:	dd7fe0ef          	jal	80001648 <copyin>
    80002876:	00a03533          	snez	a0,a0
    8000287a:	40a0053b          	negw	a0,a0
}
    8000287e:	60e2                	ld	ra,24(sp)
    80002880:	6442                	ld	s0,16(sp)
    80002882:	64a2                	ld	s1,8(sp)
    80002884:	6902                	ld	s2,0(sp)
    80002886:	6105                	addi	sp,sp,32
    80002888:	8082                	ret
    return -1;
    8000288a:	557d                	li	a0,-1
    8000288c:	bfcd                	j	8000287e <fetchaddr+0x36>
    8000288e:	557d                	li	a0,-1
    80002890:	b7fd                	j	8000287e <fetchaddr+0x36>

0000000080002892 <fetchstr>:
{
    80002892:	7179                	addi	sp,sp,-48
    80002894:	f406                	sd	ra,40(sp)
    80002896:	f022                	sd	s0,32(sp)
    80002898:	ec26                	sd	s1,24(sp)
    8000289a:	e84a                	sd	s2,16(sp)
    8000289c:	e44e                	sd	s3,8(sp)
    8000289e:	1800                	addi	s0,sp,48
    800028a0:	89aa                	mv	s3,a0
    800028a2:	84ae                	mv	s1,a1
    800028a4:	8932                	mv	s2,a2
  struct proc *p = myproc();
    800028a6:	8a2ff0ef          	jal	80001948 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    800028aa:	874a                	mv	a4,s2
    800028ac:	86ce                	mv	a3,s3
    800028ae:	8626                	mv	a2,s1
    800028b0:	652c                	ld	a1,72(a0)
    800028b2:	6928                	ld	a0,80(a0)
    800028b4:	e31fe0ef          	jal	800016e4 <copyinstr>
    800028b8:	00054c63          	bltz	a0,800028d0 <fetchstr+0x3e>
  return strlen(buf);
    800028bc:	8526                	mv	a0,s1
    800028be:	db4fe0ef          	jal	80000e72 <strlen>
}
    800028c2:	70a2                	ld	ra,40(sp)
    800028c4:	7402                	ld	s0,32(sp)
    800028c6:	64e2                	ld	s1,24(sp)
    800028c8:	6942                	ld	s2,16(sp)
    800028ca:	69a2                	ld	s3,8(sp)
    800028cc:	6145                	addi	sp,sp,48
    800028ce:	8082                	ret
    return -1;
    800028d0:	557d                	li	a0,-1
    800028d2:	bfc5                	j	800028c2 <fetchstr+0x30>

00000000800028d4 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800028d4:	1101                	addi	sp,sp,-32
    800028d6:	ec06                	sd	ra,24(sp)
    800028d8:	e822                	sd	s0,16(sp)
    800028da:	e426                	sd	s1,8(sp)
    800028dc:	1000                	addi	s0,sp,32
    800028de:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028e0:	f09ff0ef          	jal	800027e8 <argraw>
    800028e4:	c088                	sw	a0,0(s1)
}
    800028e6:	60e2                	ld	ra,24(sp)
    800028e8:	6442                	ld	s0,16(sp)
    800028ea:	64a2                	ld	s1,8(sp)
    800028ec:	6105                	addi	sp,sp,32
    800028ee:	8082                	ret

00000000800028f0 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800028f0:	1101                	addi	sp,sp,-32
    800028f2:	ec06                	sd	ra,24(sp)
    800028f4:	e822                	sd	s0,16(sp)
    800028f6:	e426                	sd	s1,8(sp)
    800028f8:	1000                	addi	s0,sp,32
    800028fa:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028fc:	eedff0ef          	jal	800027e8 <argraw>
    80002900:	e088                	sd	a0,0(s1)
}
    80002902:	60e2                	ld	ra,24(sp)
    80002904:	6442                	ld	s0,16(sp)
    80002906:	64a2                	ld	s1,8(sp)
    80002908:	6105                	addi	sp,sp,32
    8000290a:	8082                	ret

000000008000290c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000290c:	1101                	addi	sp,sp,-32
    8000290e:	ec06                	sd	ra,24(sp)
    80002910:	e822                	sd	s0,16(sp)
    80002912:	e426                	sd	s1,8(sp)
    80002914:	e04a                	sd	s2,0(sp)
    80002916:	1000                	addi	s0,sp,32
    80002918:	892e                	mv	s2,a1
    8000291a:	84b2                	mv	s1,a2
  *ip = argraw(n);
    8000291c:	ecdff0ef          	jal	800027e8 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002920:	8626                	mv	a2,s1
    80002922:	85ca                	mv	a1,s2
    80002924:	f6fff0ef          	jal	80002892 <fetchstr>
}
    80002928:	60e2                	ld	ra,24(sp)
    8000292a:	6442                	ld	s0,16(sp)
    8000292c:	64a2                	ld	s1,8(sp)
    8000292e:	6902                	ld	s2,0(sp)
    80002930:	6105                	addi	sp,sp,32
    80002932:	8082                	ret

0000000080002934 <syscall>:
  // clang-format on
};

void
syscall(void)
{
    80002934:	1101                	addi	sp,sp,-32
    80002936:	ec06                	sd	ra,24(sp)
    80002938:	e822                	sd	s0,16(sp)
    8000293a:	e426                	sd	s1,8(sp)
    8000293c:	e04a                	sd	s2,0(sp)
    8000293e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002940:	808ff0ef          	jal	80001948 <myproc>
    80002944:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002946:	05853903          	ld	s2,88(a0)
    8000294a:	0a893783          	ld	a5,168(s2)
    8000294e:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002952:	37fd                	addiw	a5,a5,-1
    80002954:	4759                	li	a4,22
    80002956:	00f76f63          	bltu	a4,a5,80002974 <syscall+0x40>
    8000295a:	00369713          	slli	a4,a3,0x3
    8000295e:	00005797          	auipc	a5,0x5
    80002962:	e7278793          	addi	a5,a5,-398 # 800077d0 <syscalls>
    80002966:	97ba                	add	a5,a5,a4
    80002968:	639c                	ld	a5,0(a5)
    8000296a:	c789                	beqz	a5,80002974 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000296c:	9782                	jalr	a5
    8000296e:	06a93823          	sd	a0,112(s2)
    80002972:	a829                	j	8000298c <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    80002974:	15848613          	addi	a2,s1,344
    80002978:	588c                	lw	a1,48(s1)
    8000297a:	00005517          	auipc	a0,0x5
    8000297e:	a5650513          	addi	a0,a0,-1450 # 800073d0 <etext+0x3d0>
    80002982:	b89fd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    80002986:	6cbc                	ld	a5,88(s1)
    80002988:	577d                	li	a4,-1
    8000298a:	fbb8                	sd	a4,112(a5)
  }
}
    8000298c:	60e2                	ld	ra,24(sp)
    8000298e:	6442                	ld	s0,16(sp)
    80002990:	64a2                	ld	s1,8(sp)
    80002992:	6902                	ld	s2,0(sp)
    80002994:	6105                	addi	sp,sp,32
    80002996:	8082                	ret

0000000080002998 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002998:	1101                	addi	sp,sp,-32
    8000299a:	ec06                	sd	ra,24(sp)
    8000299c:	e822                	sd	s0,16(sp)
    8000299e:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800029a0:	fec40593          	addi	a1,s0,-20
    800029a4:	4501                	li	a0,0
    800029a6:	f2fff0ef          	jal	800028d4 <argint>
  kexit(n);
    800029aa:	fec42503          	lw	a0,-20(s0)
    800029ae:	ed0ff0ef          	jal	8000207e <kexit>
  return 0; // not reached
}
    800029b2:	4501                	li	a0,0
    800029b4:	60e2                	ld	ra,24(sp)
    800029b6:	6442                	ld	s0,16(sp)
    800029b8:	6105                	addi	sp,sp,32
    800029ba:	8082                	ret

00000000800029bc <sys_getpid>:

uint64
sys_getpid(void)
{
    800029bc:	1141                	addi	sp,sp,-16
    800029be:	e406                	sd	ra,8(sp)
    800029c0:	e022                	sd	s0,0(sp)
    800029c2:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800029c4:	f85fe0ef          	jal	80001948 <myproc>
}
    800029c8:	5908                	lw	a0,48(a0)
    800029ca:	60a2                	ld	ra,8(sp)
    800029cc:	6402                	ld	s0,0(sp)
    800029ce:	0141                	addi	sp,sp,16
    800029d0:	8082                	ret

00000000800029d2 <sys_fork>:

uint64
sys_fork(void)
{
    800029d2:	1141                	addi	sp,sp,-16
    800029d4:	e406                	sd	ra,8(sp)
    800029d6:	e022                	sd	s0,0(sp)
    800029d8:	0800                	addi	s0,sp,16
  return kfork();
    800029da:	ad2ff0ef          	jal	80001cac <kfork>
}
    800029de:	60a2                	ld	ra,8(sp)
    800029e0:	6402                	ld	s0,0(sp)
    800029e2:	0141                	addi	sp,sp,16
    800029e4:	8082                	ret

00000000800029e6 <sys_wait>:

uint64
sys_wait(void)
{
    800029e6:	1101                	addi	sp,sp,-32
    800029e8:	ec06                	sd	ra,24(sp)
    800029ea:	e822                	sd	s0,16(sp)
    800029ec:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800029ee:	fe840593          	addi	a1,s0,-24
    800029f2:	4501                	li	a0,0
    800029f4:	efdff0ef          	jal	800028f0 <argaddr>
  return kwait(p);
    800029f8:	fe843503          	ld	a0,-24(s0)
    800029fc:	fe2ff0ef          	jal	800021de <kwait>
}
    80002a00:	60e2                	ld	ra,24(sp)
    80002a02:	6442                	ld	s0,16(sp)
    80002a04:	6105                	addi	sp,sp,32
    80002a06:	8082                	ret

0000000080002a08 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002a08:	7179                	addi	sp,sp,-48
    80002a0a:	f406                	sd	ra,40(sp)
    80002a0c:	f022                	sd	s0,32(sp)
    80002a0e:	ec26                	sd	s1,24(sp)
    80002a10:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002a12:	fdc40593          	addi	a1,s0,-36
    80002a16:	4501                	li	a0,0
    80002a18:	ebdff0ef          	jal	800028d4 <argint>
  addr = myproc()->sz;
    80002a1c:	f2dfe0ef          	jal	80001948 <myproc>
    80002a20:	6524                	ld	s1,72(a0)

  if (n < 0) {
    80002a22:	fdc42503          	lw	a0,-36(s0)
    80002a26:	02054a63          	bltz	a0,80002a5a <sys_sbrk+0x52>
    if (growproc(n) < 0) {
      return -1;
    }
  } else if (n > 0) {
    80002a2a:	02a05263          	blez	a0,80002a4e <sys_sbrk+0x46>
    // Lazily allocate: increase memory size without allocating physical pages.
    // When the process touches the page, page fault handler allocates it.
    if (addr + n < addr || addr + n > TRAPFRAME)
    80002a2e:	9526                	add	a0,a0,s1
    80002a30:	020007b7          	lui	a5,0x2000
    80002a34:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80002a36:	07b6                	slli	a5,a5,0xd
    80002a38:	02a7e763          	bltu	a5,a0,80002a66 <sys_sbrk+0x5e>
    80002a3c:	02956563          	bltu	a0,s1,80002a66 <sys_sbrk+0x5e>
      return -1;
    myproc()->sz += n;
    80002a40:	f09fe0ef          	jal	80001948 <myproc>
    80002a44:	fdc42703          	lw	a4,-36(s0)
    80002a48:	653c                	ld	a5,72(a0)
    80002a4a:	97ba                	add	a5,a5,a4
    80002a4c:	e53c                	sd	a5,72(a0)
  }
  return addr;
}
    80002a4e:	8526                	mv	a0,s1
    80002a50:	70a2                	ld	ra,40(sp)
    80002a52:	7402                	ld	s0,32(sp)
    80002a54:	64e2                	ld	s1,24(sp)
    80002a56:	6145                	addi	sp,sp,48
    80002a58:	8082                	ret
    if (growproc(n) < 0) {
    80002a5a:	9f0ff0ef          	jal	80001c4a <growproc>
    80002a5e:	fe0558e3          	bgez	a0,80002a4e <sys_sbrk+0x46>
      return -1;
    80002a62:	54fd                	li	s1,-1
    80002a64:	b7ed                	j	80002a4e <sys_sbrk+0x46>
      return -1;
    80002a66:	54fd                	li	s1,-1
    80002a68:	b7dd                	j	80002a4e <sys_sbrk+0x46>

0000000080002a6a <sys_pause>:


uint64
sys_pause(void)
{
    80002a6a:	7139                	addi	sp,sp,-64
    80002a6c:	fc06                	sd	ra,56(sp)
    80002a6e:	f822                	sd	s0,48(sp)
    80002a70:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002a72:	fcc40593          	addi	a1,s0,-52
    80002a76:	4501                	li	a0,0
    80002a78:	e5dff0ef          	jal	800028d4 <argint>
  if (n < 0)
    80002a7c:	fcc42783          	lw	a5,-52(s0)
    80002a80:	0807c063          	bltz	a5,80002b00 <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002a84:	00016517          	auipc	a0,0x16
    80002a88:	a1450513          	addi	a0,a0,-1516 # 80018498 <tickslock>
    80002a8c:	99cfe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002a90:	fcc42783          	lw	a5,-52(s0)
    80002a94:	cbb9                	beqz	a5,80002aea <sys_pause+0x80>
    80002a96:	f426                	sd	s1,40(sp)
    80002a98:	f04a                	sd	s2,32(sp)
    80002a9a:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002a9c:	00008997          	auipc	s3,0x8
    80002aa0:	8cc9a983          	lw	s3,-1844(s3) # 8000a368 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002aa4:	00008917          	auipc	s2,0x8
    80002aa8:	8c490913          	addi	s2,s2,-1852 # 8000a368 <ticks>
    release(&tickslock);
    80002aac:	00016497          	auipc	s1,0x16
    80002ab0:	9ec48493          	addi	s1,s1,-1556 # 80018498 <tickslock>
    if (killed(myproc())) {
    80002ab4:	e95fe0ef          	jal	80001948 <myproc>
    80002ab8:	efcff0ef          	jal	800021b4 <killed>
    80002abc:	e529                	bnez	a0,80002b06 <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002abe:	854a                	mv	a0,s2
    80002ac0:	c96ff0ef          	jal	80001f56 <sleep_prepare>
    release(&tickslock);
    80002ac4:	8526                	mv	a0,s1
    80002ac6:	9eafe0ef          	jal	80000cb0 <release>
    sleep();
    80002aca:	cc8ff0ef          	jal	80001f92 <sleep>
    acquire(&tickslock);
    80002ace:	8526                	mv	a0,s1
    80002ad0:	958fe0ef          	jal	80000c28 <acquire>
  while (ticks - ticks0 < n) {
    80002ad4:	00092783          	lw	a5,0(s2)
    80002ad8:	413787bb          	subw	a5,a5,s3
    80002adc:	fcc42703          	lw	a4,-52(s0)
    80002ae0:	fce7eae3          	bltu	a5,a4,80002ab4 <sys_pause+0x4a>
    80002ae4:	74a2                	ld	s1,40(sp)
    80002ae6:	7902                	ld	s2,32(sp)
    80002ae8:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002aea:	00016517          	auipc	a0,0x16
    80002aee:	9ae50513          	addi	a0,a0,-1618 # 80018498 <tickslock>
    80002af2:	9befe0ef          	jal	80000cb0 <release>
  return 0;
    80002af6:	4501                	li	a0,0
}
    80002af8:	70e2                	ld	ra,56(sp)
    80002afa:	7442                	ld	s0,48(sp)
    80002afc:	6121                	addi	sp,sp,64
    80002afe:	8082                	ret
    n = 0;
    80002b00:	fc042623          	sw	zero,-52(s0)
    80002b04:	b741                	j	80002a84 <sys_pause+0x1a>
      release(&tickslock);
    80002b06:	00016517          	auipc	a0,0x16
    80002b0a:	99250513          	addi	a0,a0,-1646 # 80018498 <tickslock>
    80002b0e:	9a2fe0ef          	jal	80000cb0 <release>
      return -1;
    80002b12:	557d                	li	a0,-1
    80002b14:	74a2                	ld	s1,40(sp)
    80002b16:	7902                	ld	s2,32(sp)
    80002b18:	69e2                	ld	s3,24(sp)
    80002b1a:	bff9                	j	80002af8 <sys_pause+0x8e>

0000000080002b1c <sys_kill>:

uint64
sys_kill(void)
{
    80002b1c:	1101                	addi	sp,sp,-32
    80002b1e:	ec06                	sd	ra,24(sp)
    80002b20:	e822                	sd	s0,16(sp)
    80002b22:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002b24:	fec40593          	addi	a1,s0,-20
    80002b28:	4501                	li	a0,0
    80002b2a:	dabff0ef          	jal	800028d4 <argint>
  return kkill(pid);
    80002b2e:	fec42503          	lw	a0,-20(s0)
    80002b32:	df2ff0ef          	jal	80002124 <kkill>
}
    80002b36:	60e2                	ld	ra,24(sp)
    80002b38:	6442                	ld	s0,16(sp)
    80002b3a:	6105                	addi	sp,sp,32
    80002b3c:	8082                	ret

0000000080002b3e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002b3e:	1101                	addi	sp,sp,-32
    80002b40:	ec06                	sd	ra,24(sp)
    80002b42:	e822                	sd	s0,16(sp)
    80002b44:	e426                	sd	s1,8(sp)
    80002b46:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002b48:	00016517          	auipc	a0,0x16
    80002b4c:	95050513          	addi	a0,a0,-1712 # 80018498 <tickslock>
    80002b50:	8d8fe0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002b54:	00008797          	auipc	a5,0x8
    80002b58:	8147a783          	lw	a5,-2028(a5) # 8000a368 <ticks>
    80002b5c:	84be                	mv	s1,a5
  release(&tickslock);
    80002b5e:	00016517          	auipc	a0,0x16
    80002b62:	93a50513          	addi	a0,a0,-1734 # 80018498 <tickslock>
    80002b66:	94afe0ef          	jal	80000cb0 <release>
  return xticks;
}
    80002b6a:	02049513          	slli	a0,s1,0x20
    80002b6e:	9101                	srli	a0,a0,0x20
    80002b70:	60e2                	ld	ra,24(sp)
    80002b72:	6442                	ld	s0,16(sp)
    80002b74:	64a2                	ld	s1,8(sp)
    80002b76:	6105                	addi	sp,sp,32
    80002b78:	8082                	ret

0000000080002b7a <sys_getfaults>:

uint64
sys_getfaults(void)
{
    80002b7a:	1141                	addi	sp,sp,-16
    80002b7c:	e406                	sd	ra,8(sp)
    80002b7e:	e022                	sd	s0,0(sp)
    80002b80:	0800                	addi	s0,sp,16
  return myproc()->page_faults;
    80002b82:	dc7fe0ef          	jal	80001948 <myproc>
}
    80002b86:	16853503          	ld	a0,360(a0)
    80002b8a:	60a2                	ld	ra,8(sp)
    80002b8c:	6402                	ld	s0,0(sp)
    80002b8e:	0141                	addi	sp,sp,16
    80002b90:	8082                	ret

0000000080002b92 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b92:	7179                	addi	sp,sp,-48
    80002b94:	f406                	sd	ra,40(sp)
    80002b96:	f022                	sd	s0,32(sp)
    80002b98:	ec26                	sd	s1,24(sp)
    80002b9a:	e84a                	sd	s2,16(sp)
    80002b9c:	e44e                	sd	s3,8(sp)
    80002b9e:	e052                	sd	s4,0(sp)
    80002ba0:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ba2:	00005597          	auipc	a1,0x5
    80002ba6:	84e58593          	addi	a1,a1,-1970 # 800073f0 <etext+0x3f0>
    80002baa:	00016517          	auipc	a0,0x16
    80002bae:	90650513          	addi	a0,a0,-1786 # 800184b0 <bcache>
    80002bb2:	ff7fd0ef          	jal	80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002bb6:	0001e797          	auipc	a5,0x1e
    80002bba:	8fa78793          	addi	a5,a5,-1798 # 800204b0 <bcache+0x8000>
    80002bbe:	0001e717          	auipc	a4,0x1e
    80002bc2:	b5a70713          	addi	a4,a4,-1190 # 80020718 <bcache+0x8268>
    80002bc6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002bca:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002bce:	00016497          	auipc	s1,0x16
    80002bd2:	8fa48493          	addi	s1,s1,-1798 # 800184c8 <bcache+0x18>
    b->next = bcache.head.next;
    80002bd6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002bd8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002bda:	00005a17          	auipc	s4,0x5
    80002bde:	81ea0a13          	addi	s4,s4,-2018 # 800073f8 <etext+0x3f8>
    b->next = bcache.head.next;
    80002be2:	2b893783          	ld	a5,696(s2)
    80002be6:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002be8:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002bec:	85d2                	mv	a1,s4
    80002bee:	01048513          	addi	a0,s1,16
    80002bf2:	41c010ef          	jal	8000400e <initsleeplock>
    bcache.head.next->prev = b;
    80002bf6:	2b893783          	ld	a5,696(s2)
    80002bfa:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002bfc:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002c00:	45848493          	addi	s1,s1,1112
    80002c04:	fd349fe3          	bne	s1,s3,80002be2 <binit+0x50>
  }
}
    80002c08:	70a2                	ld	ra,40(sp)
    80002c0a:	7402                	ld	s0,32(sp)
    80002c0c:	64e2                	ld	s1,24(sp)
    80002c0e:	6942                	ld	s2,16(sp)
    80002c10:	69a2                	ld	s3,8(sp)
    80002c12:	6a02                	ld	s4,0(sp)
    80002c14:	6145                	addi	sp,sp,48
    80002c16:	8082                	ret

0000000080002c18 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002c18:	7179                	addi	sp,sp,-48
    80002c1a:	f406                	sd	ra,40(sp)
    80002c1c:	f022                	sd	s0,32(sp)
    80002c1e:	ec26                	sd	s1,24(sp)
    80002c20:	e84a                	sd	s2,16(sp)
    80002c22:	e44e                	sd	s3,8(sp)
    80002c24:	1800                	addi	s0,sp,48
    80002c26:	892a                	mv	s2,a0
    80002c28:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002c2a:	00016517          	auipc	a0,0x16
    80002c2e:	88650513          	addi	a0,a0,-1914 # 800184b0 <bcache>
    80002c32:	ff7fd0ef          	jal	80000c28 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002c36:	0001e497          	auipc	s1,0x1e
    80002c3a:	b324b483          	ld	s1,-1230(s1) # 80020768 <bcache+0x82b8>
    80002c3e:	0001e797          	auipc	a5,0x1e
    80002c42:	ada78793          	addi	a5,a5,-1318 # 80020718 <bcache+0x8268>
    80002c46:	02f48b63          	beq	s1,a5,80002c7c <bread+0x64>
    80002c4a:	873e                	mv	a4,a5
    80002c4c:	a021                	j	80002c54 <bread+0x3c>
    80002c4e:	68a4                	ld	s1,80(s1)
    80002c50:	02e48663          	beq	s1,a4,80002c7c <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002c54:	449c                	lw	a5,8(s1)
    80002c56:	ff279ce3          	bne	a5,s2,80002c4e <bread+0x36>
    80002c5a:	44dc                	lw	a5,12(s1)
    80002c5c:	ff3799e3          	bne	a5,s3,80002c4e <bread+0x36>
      b->refcnt++;
    80002c60:	40bc                	lw	a5,64(s1)
    80002c62:	2785                	addiw	a5,a5,1
    80002c64:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c66:	00016517          	auipc	a0,0x16
    80002c6a:	84a50513          	addi	a0,a0,-1974 # 800184b0 <bcache>
    80002c6e:	842fe0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002c72:	01048513          	addi	a0,s1,16
    80002c76:	3ce010ef          	jal	80004044 <acquiresleep>
      return b;
    80002c7a:	a889                	j	80002ccc <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002c7c:	0001e497          	auipc	s1,0x1e
    80002c80:	ae44b483          	ld	s1,-1308(s1) # 80020760 <bcache+0x82b0>
    80002c84:	0001e797          	auipc	a5,0x1e
    80002c88:	a9478793          	addi	a5,a5,-1388 # 80020718 <bcache+0x8268>
    80002c8c:	00f48863          	beq	s1,a5,80002c9c <bread+0x84>
    80002c90:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002c92:	40bc                	lw	a5,64(s1)
    80002c94:	cb91                	beqz	a5,80002ca8 <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002c96:	64a4                	ld	s1,72(s1)
    80002c98:	fee49de3          	bne	s1,a4,80002c92 <bread+0x7a>
  panic("bget: no buffers");
    80002c9c:	00004517          	auipc	a0,0x4
    80002ca0:	76450513          	addi	a0,a0,1892 # 80007400 <etext+0x400>
    80002ca4:	b91fd0ef          	jal	80000834 <panic>
      b->dev = dev;
    80002ca8:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002cac:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002cb0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002cb4:	4785                	li	a5,1
    80002cb6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002cb8:	00015517          	auipc	a0,0x15
    80002cbc:	7f850513          	addi	a0,a0,2040 # 800184b0 <bcache>
    80002cc0:	ff1fd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002cc4:	01048513          	addi	a0,s1,16
    80002cc8:	37c010ef          	jal	80004044 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002ccc:	409c                	lw	a5,0(s1)
    80002cce:	cb89                	beqz	a5,80002ce0 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002cd0:	8526                	mv	a0,s1
    80002cd2:	70a2                	ld	ra,40(sp)
    80002cd4:	7402                	ld	s0,32(sp)
    80002cd6:	64e2                	ld	s1,24(sp)
    80002cd8:	6942                	ld	s2,16(sp)
    80002cda:	69a2                	ld	s3,8(sp)
    80002cdc:	6145                	addi	sp,sp,48
    80002cde:	8082                	ret
    virtio_disk_rw(b, 0);
    80002ce0:	4581                	li	a1,0
    80002ce2:	8526                	mv	a0,s1
    80002ce4:	4c3020ef          	jal	800059a6 <virtio_disk_rw>
    b->valid = 1;
    80002ce8:	4785                	li	a5,1
    80002cea:	c09c                	sw	a5,0(s1)
  return b;
    80002cec:	b7d5                	j	80002cd0 <bread+0xb8>

0000000080002cee <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002cee:	1101                	addi	sp,sp,-32
    80002cf0:	ec06                	sd	ra,24(sp)
    80002cf2:	e822                	sd	s0,16(sp)
    80002cf4:	e426                	sd	s1,8(sp)
    80002cf6:	1000                	addi	s0,sp,32
    80002cf8:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002cfa:	0541                	addi	a0,a0,16
    80002cfc:	3d4010ef          	jal	800040d0 <holdingsleep>
    80002d00:	c911                	beqz	a0,80002d14 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002d02:	4585                	li	a1,1
    80002d04:	8526                	mv	a0,s1
    80002d06:	4a1020ef          	jal	800059a6 <virtio_disk_rw>
}
    80002d0a:	60e2                	ld	ra,24(sp)
    80002d0c:	6442                	ld	s0,16(sp)
    80002d0e:	64a2                	ld	s1,8(sp)
    80002d10:	6105                	addi	sp,sp,32
    80002d12:	8082                	ret
    panic("bwrite");
    80002d14:	00004517          	auipc	a0,0x4
    80002d18:	70450513          	addi	a0,a0,1796 # 80007418 <etext+0x418>
    80002d1c:	b19fd0ef          	jal	80000834 <panic>

0000000080002d20 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002d20:	1101                	addi	sp,sp,-32
    80002d22:	ec06                	sd	ra,24(sp)
    80002d24:	e822                	sd	s0,16(sp)
    80002d26:	e426                	sd	s1,8(sp)
    80002d28:	e04a                	sd	s2,0(sp)
    80002d2a:	1000                	addi	s0,sp,32
    80002d2c:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002d2e:	01050913          	addi	s2,a0,16
    80002d32:	854a                	mv	a0,s2
    80002d34:	39c010ef          	jal	800040d0 <holdingsleep>
    80002d38:	c125                	beqz	a0,80002d98 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002d3a:	854a                	mv	a0,s2
    80002d3c:	35c010ef          	jal	80004098 <releasesleep>

  acquire(&bcache.lock);
    80002d40:	00015517          	auipc	a0,0x15
    80002d44:	77050513          	addi	a0,a0,1904 # 800184b0 <bcache>
    80002d48:	ee1fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002d4c:	40bc                	lw	a5,64(s1)
    80002d4e:	37fd                	addiw	a5,a5,-1
    80002d50:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002d52:	e79d                	bnez	a5,80002d80 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002d54:	68b8                	ld	a4,80(s1)
    80002d56:	64bc                	ld	a5,72(s1)
    80002d58:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002d5a:	68b8                	ld	a4,80(s1)
    80002d5c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002d5e:	0001d797          	auipc	a5,0x1d
    80002d62:	75278793          	addi	a5,a5,1874 # 800204b0 <bcache+0x8000>
    80002d66:	2b87b703          	ld	a4,696(a5)
    80002d6a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002d6c:	0001e717          	auipc	a4,0x1e
    80002d70:	9ac70713          	addi	a4,a4,-1620 # 80020718 <bcache+0x8268>
    80002d74:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002d76:	2b87b703          	ld	a4,696(a5)
    80002d7a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002d7c:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002d80:	00015517          	auipc	a0,0x15
    80002d84:	73050513          	addi	a0,a0,1840 # 800184b0 <bcache>
    80002d88:	f29fd0ef          	jal	80000cb0 <release>
}
    80002d8c:	60e2                	ld	ra,24(sp)
    80002d8e:	6442                	ld	s0,16(sp)
    80002d90:	64a2                	ld	s1,8(sp)
    80002d92:	6902                	ld	s2,0(sp)
    80002d94:	6105                	addi	sp,sp,32
    80002d96:	8082                	ret
    panic("brelse");
    80002d98:	00004517          	auipc	a0,0x4
    80002d9c:	68850513          	addi	a0,a0,1672 # 80007420 <etext+0x420>
    80002da0:	a95fd0ef          	jal	80000834 <panic>

0000000080002da4 <bpin>:

void
bpin(struct buf *b)
{
    80002da4:	1101                	addi	sp,sp,-32
    80002da6:	ec06                	sd	ra,24(sp)
    80002da8:	e822                	sd	s0,16(sp)
    80002daa:	e426                	sd	s1,8(sp)
    80002dac:	1000                	addi	s0,sp,32
    80002dae:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002db0:	00015517          	auipc	a0,0x15
    80002db4:	70050513          	addi	a0,a0,1792 # 800184b0 <bcache>
    80002db8:	e71fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002dbc:	40bc                	lw	a5,64(s1)
    80002dbe:	2785                	addiw	a5,a5,1
    80002dc0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002dc2:	00015517          	auipc	a0,0x15
    80002dc6:	6ee50513          	addi	a0,a0,1774 # 800184b0 <bcache>
    80002dca:	ee7fd0ef          	jal	80000cb0 <release>
}
    80002dce:	60e2                	ld	ra,24(sp)
    80002dd0:	6442                	ld	s0,16(sp)
    80002dd2:	64a2                	ld	s1,8(sp)
    80002dd4:	6105                	addi	sp,sp,32
    80002dd6:	8082                	ret

0000000080002dd8 <bunpin>:

void
bunpin(struct buf *b)
{
    80002dd8:	1101                	addi	sp,sp,-32
    80002dda:	ec06                	sd	ra,24(sp)
    80002ddc:	e822                	sd	s0,16(sp)
    80002dde:	e426                	sd	s1,8(sp)
    80002de0:	1000                	addi	s0,sp,32
    80002de2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002de4:	00015517          	auipc	a0,0x15
    80002de8:	6cc50513          	addi	a0,a0,1740 # 800184b0 <bcache>
    80002dec:	e3dfd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002df0:	40bc                	lw	a5,64(s1)
    80002df2:	37fd                	addiw	a5,a5,-1
    80002df4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002df6:	00015517          	auipc	a0,0x15
    80002dfa:	6ba50513          	addi	a0,a0,1722 # 800184b0 <bcache>
    80002dfe:	eb3fd0ef          	jal	80000cb0 <release>
}
    80002e02:	60e2                	ld	ra,24(sp)
    80002e04:	6442                	ld	s0,16(sp)
    80002e06:	64a2                	ld	s1,8(sp)
    80002e08:	6105                	addi	sp,sp,32
    80002e0a:	8082                	ret

0000000080002e0c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002e0c:	1101                	addi	sp,sp,-32
    80002e0e:	ec06                	sd	ra,24(sp)
    80002e10:	e822                	sd	s0,16(sp)
    80002e12:	e426                	sd	s1,8(sp)
    80002e14:	e04a                	sd	s2,0(sp)
    80002e16:	1000                	addi	s0,sp,32
    80002e18:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002e1a:	00d5d79b          	srliw	a5,a1,0xd
    80002e1e:	0001e597          	auipc	a1,0x1e
    80002e22:	d6e5a583          	lw	a1,-658(a1) # 80020b8c <sb+0x1c>
    80002e26:	9dbd                	addw	a1,a1,a5
    80002e28:	df1ff0ef          	jal	80002c18 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002e2c:	0074f713          	andi	a4,s1,7
    80002e30:	4785                	li	a5,1
    80002e32:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002e36:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80002e38:	90d9                	srli	s1,s1,0x36
    80002e3a:	00950733          	add	a4,a0,s1
    80002e3e:	05874703          	lbu	a4,88(a4)
    80002e42:	00e7f6b3          	and	a3,a5,a4
    80002e46:	c29d                	beqz	a3,80002e6c <bfree+0x60>
    80002e48:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002e4a:	94aa                	add	s1,s1,a0
    80002e4c:	fff7c793          	not	a5,a5
    80002e50:	8f7d                	and	a4,a4,a5
    80002e52:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002e56:	080010ef          	jal	80003ed6 <log_write>
  brelse(bp);
    80002e5a:	854a                	mv	a0,s2
    80002e5c:	ec5ff0ef          	jal	80002d20 <brelse>
}
    80002e60:	60e2                	ld	ra,24(sp)
    80002e62:	6442                	ld	s0,16(sp)
    80002e64:	64a2                	ld	s1,8(sp)
    80002e66:	6902                	ld	s2,0(sp)
    80002e68:	6105                	addi	sp,sp,32
    80002e6a:	8082                	ret
    panic("freeing free block");
    80002e6c:	00004517          	auipc	a0,0x4
    80002e70:	5bc50513          	addi	a0,a0,1468 # 80007428 <etext+0x428>
    80002e74:	9c1fd0ef          	jal	80000834 <panic>

0000000080002e78 <balloc>:
{
    80002e78:	715d                	addi	sp,sp,-80
    80002e7a:	e486                	sd	ra,72(sp)
    80002e7c:	e0a2                	sd	s0,64(sp)
    80002e7e:	fc26                	sd	s1,56(sp)
    80002e80:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80002e82:	0001e797          	auipc	a5,0x1e
    80002e86:	cf27a783          	lw	a5,-782(a5) # 80020b74 <sb+0x4>
    80002e8a:	0e078263          	beqz	a5,80002f6e <balloc+0xf6>
    80002e8e:	f84a                	sd	s2,48(sp)
    80002e90:	f44e                	sd	s3,40(sp)
    80002e92:	f052                	sd	s4,32(sp)
    80002e94:	ec56                	sd	s5,24(sp)
    80002e96:	e85a                	sd	s6,16(sp)
    80002e98:	e45e                	sd	s7,8(sp)
    80002e9a:	e062                	sd	s8,0(sp)
    80002e9c:	8baa                	mv	s7,a0
    80002e9e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002ea0:	0001eb17          	auipc	s6,0x1e
    80002ea4:	cd0b0b13          	addi	s6,s6,-816 # 80020b70 <sb>
      m = 1 << (bi % 8);
    80002ea8:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002eaa:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80002eac:	6c09                	lui	s8,0x2
    80002eae:	a09d                	j	80002f14 <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80002eb0:	97ca                	add	a5,a5,s2
    80002eb2:	8e55                	or	a2,a2,a3
    80002eb4:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002eb8:	854a                	mv	a0,s2
    80002eba:	01c010ef          	jal	80003ed6 <log_write>
        brelse(bp);
    80002ebe:	854a                	mv	a0,s2
    80002ec0:	e61ff0ef          	jal	80002d20 <brelse>
  bp = bread(dev, bno);
    80002ec4:	85a6                	mv	a1,s1
    80002ec6:	855e                	mv	a0,s7
    80002ec8:	d51ff0ef          	jal	80002c18 <bread>
    80002ecc:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002ece:	40000613          	li	a2,1024
    80002ed2:	4581                	li	a1,0
    80002ed4:	05850513          	addi	a0,a0,88
    80002ed8:	e11fd0ef          	jal	80000ce8 <memset>
  log_write(bp);
    80002edc:	854a                	mv	a0,s2
    80002ede:	7f9000ef          	jal	80003ed6 <log_write>
  brelse(bp);
    80002ee2:	854a                	mv	a0,s2
    80002ee4:	e3dff0ef          	jal	80002d20 <brelse>
}
    80002ee8:	7942                	ld	s2,48(sp)
    80002eea:	79a2                	ld	s3,40(sp)
    80002eec:	7a02                	ld	s4,32(sp)
    80002eee:	6ae2                	ld	s5,24(sp)
    80002ef0:	6b42                	ld	s6,16(sp)
    80002ef2:	6ba2                	ld	s7,8(sp)
    80002ef4:	6c02                	ld	s8,0(sp)
}
    80002ef6:	8526                	mv	a0,s1
    80002ef8:	60a6                	ld	ra,72(sp)
    80002efa:	6406                	ld	s0,64(sp)
    80002efc:	74e2                	ld	s1,56(sp)
    80002efe:	6161                	addi	sp,sp,80
    80002f00:	8082                	ret
    brelse(bp);
    80002f02:	854a                	mv	a0,s2
    80002f04:	e1dff0ef          	jal	80002d20 <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80002f08:	015c0abb          	addw	s5,s8,s5
    80002f0c:	004b2783          	lw	a5,4(s6)
    80002f10:	04faf863          	bgeu	s5,a5,80002f60 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80002f14:	40dad59b          	sraiw	a1,s5,0xd
    80002f18:	01cb2783          	lw	a5,28(s6)
    80002f1c:	9dbd                	addw	a1,a1,a5
    80002f1e:	855e                	mv	a0,s7
    80002f20:	cf9ff0ef          	jal	80002c18 <bread>
    80002f24:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002f26:	004b2503          	lw	a0,4(s6)
    80002f2a:	84d6                	mv	s1,s5
    80002f2c:	4701                	li	a4,0
    80002f2e:	fca4fae3          	bgeu	s1,a0,80002f02 <balloc+0x8a>
      m = 1 << (bi % 8);
    80002f32:	00777693          	andi	a3,a4,7
    80002f36:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80002f3a:	41f7579b          	sraiw	a5,a4,0x1f
    80002f3e:	01d7d79b          	srliw	a5,a5,0x1d
    80002f42:	9fb9                	addw	a5,a5,a4
    80002f44:	4037d79b          	sraiw	a5,a5,0x3
    80002f48:	00f90633          	add	a2,s2,a5
    80002f4c:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80002f50:	00c6f5b3          	and	a1,a3,a2
    80002f54:	ddb1                	beqz	a1,80002eb0 <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002f56:	2705                	addiw	a4,a4,1
    80002f58:	2485                	addiw	s1,s1,1
    80002f5a:	fd471ae3          	bne	a4,s4,80002f2e <balloc+0xb6>
    80002f5e:	b755                	j	80002f02 <balloc+0x8a>
    80002f60:	7942                	ld	s2,48(sp)
    80002f62:	79a2                	ld	s3,40(sp)
    80002f64:	7a02                	ld	s4,32(sp)
    80002f66:	6ae2                	ld	s5,24(sp)
    80002f68:	6b42                	ld	s6,16(sp)
    80002f6a:	6ba2                	ld	s7,8(sp)
    80002f6c:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    80002f6e:	00004517          	auipc	a0,0x4
    80002f72:	4d250513          	addi	a0,a0,1234 # 80007440 <etext+0x440>
    80002f76:	d94fd0ef          	jal	8000050a <printk>
  return 0;
    80002f7a:	4481                	li	s1,0
    80002f7c:	bfad                	j	80002ef6 <balloc+0x7e>

0000000080002f7e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002f7e:	7179                	addi	sp,sp,-48
    80002f80:	f406                	sd	ra,40(sp)
    80002f82:	f022                	sd	s0,32(sp)
    80002f84:	ec26                	sd	s1,24(sp)
    80002f86:	e84a                	sd	s2,16(sp)
    80002f88:	e44e                	sd	s3,8(sp)
    80002f8a:	1800                	addi	s0,sp,48
    80002f8c:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    80002f8e:	47ad                	li	a5,11
    80002f90:	02b7e363          	bltu	a5,a1,80002fb6 <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    80002f94:	02059793          	slli	a5,a1,0x20
    80002f98:	01e7d593          	srli	a1,a5,0x1e
    80002f9c:	00b509b3          	add	s3,a0,a1
    80002fa0:	0509a483          	lw	s1,80(s3)
    80002fa4:	e0b5                	bnez	s1,80003008 <bmap+0x8a>
      addr = balloc(ip->dev);
    80002fa6:	4108                	lw	a0,0(a0)
    80002fa8:	ed1ff0ef          	jal	80002e78 <balloc>
    80002fac:	84aa                	mv	s1,a0
      if (addr == 0)
    80002fae:	cd29                	beqz	a0,80003008 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80002fb0:	04a9a823          	sw	a0,80(s3)
    80002fb4:	a891                	j	80003008 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002fb6:	ff45879b          	addiw	a5,a1,-12
    80002fba:	873e                	mv	a4,a5
    80002fbc:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    80002fbe:	0ff00793          	li	a5,255
    80002fc2:	06e7e763          	bltu	a5,a4,80003030 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    80002fc6:	08052483          	lw	s1,128(a0)
    80002fca:	e891                	bnez	s1,80002fde <bmap+0x60>
      addr = balloc(ip->dev);
    80002fcc:	4108                	lw	a0,0(a0)
    80002fce:	eabff0ef          	jal	80002e78 <balloc>
    80002fd2:	84aa                	mv	s1,a0
      if (addr == 0)
    80002fd4:	c915                	beqz	a0,80003008 <bmap+0x8a>
    80002fd6:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002fd8:	08a92023          	sw	a0,128(s2)
    80002fdc:	a011                	j	80002fe0 <bmap+0x62>
    80002fde:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002fe0:	85a6                	mv	a1,s1
    80002fe2:	00092503          	lw	a0,0(s2)
    80002fe6:	c33ff0ef          	jal	80002c18 <bread>
    80002fea:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80002fec:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    80002ff0:	02099713          	slli	a4,s3,0x20
    80002ff4:	01e75593          	srli	a1,a4,0x1e
    80002ff8:	97ae                	add	a5,a5,a1
    80002ffa:	89be                	mv	s3,a5
    80002ffc:	4384                	lw	s1,0(a5)
    80002ffe:	cc89                	beqz	s1,80003018 <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003000:	8552                	mv	a0,s4
    80003002:	d1fff0ef          	jal	80002d20 <brelse>
    return addr;
    80003006:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003008:	8526                	mv	a0,s1
    8000300a:	70a2                	ld	ra,40(sp)
    8000300c:	7402                	ld	s0,32(sp)
    8000300e:	64e2                	ld	s1,24(sp)
    80003010:	6942                	ld	s2,16(sp)
    80003012:	69a2                	ld	s3,8(sp)
    80003014:	6145                	addi	sp,sp,48
    80003016:	8082                	ret
      addr = balloc(ip->dev);
    80003018:	00092503          	lw	a0,0(s2)
    8000301c:	e5dff0ef          	jal	80002e78 <balloc>
    80003020:	84aa                	mv	s1,a0
      if (addr) {
    80003022:	dd79                	beqz	a0,80003000 <bmap+0x82>
        a[bn] = addr;
    80003024:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80003028:	8552                	mv	a0,s4
    8000302a:	6ad000ef          	jal	80003ed6 <log_write>
    8000302e:	bfc9                	j	80003000 <bmap+0x82>
    80003030:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003032:	00004517          	auipc	a0,0x4
    80003036:	42650513          	addi	a0,a0,1062 # 80007458 <etext+0x458>
    8000303a:	ffafd0ef          	jal	80000834 <panic>

000000008000303e <iget>:
{
    8000303e:	7179                	addi	sp,sp,-48
    80003040:	f406                	sd	ra,40(sp)
    80003042:	f022                	sd	s0,32(sp)
    80003044:	ec26                	sd	s1,24(sp)
    80003046:	e84a                	sd	s2,16(sp)
    80003048:	e44e                	sd	s3,8(sp)
    8000304a:	e052                	sd	s4,0(sp)
    8000304c:	1800                	addi	s0,sp,48
    8000304e:	892a                	mv	s2,a0
    80003050:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003052:	0001e517          	auipc	a0,0x1e
    80003056:	b3e50513          	addi	a0,a0,-1218 # 80020b90 <itable>
    8000305a:	bcffd0ef          	jal	80000c28 <acquire>
  empty = 0;
    8000305e:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80003060:	0001e497          	auipc	s1,0x1e
    80003064:	b4848493          	addi	s1,s1,-1208 # 80020ba8 <itable+0x18>
    80003068:	0001f697          	auipc	a3,0x1f
    8000306c:	5d068693          	addi	a3,a3,1488 # 80022638 <log>
    80003070:	a809                	j	80003082 <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003072:	e781                	bnez	a5,8000307a <iget+0x3c>
    80003074:	00099363          	bnez	s3,8000307a <iget+0x3c>
      empty = ip;
    80003078:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    8000307a:	08848493          	addi	s1,s1,136
    8000307e:	02d48563          	beq	s1,a3,800030a8 <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    80003082:	449c                	lw	a5,8(s1)
    80003084:	fef057e3          	blez	a5,80003072 <iget+0x34>
    80003088:	4098                	lw	a4,0(s1)
    8000308a:	ff2718e3          	bne	a4,s2,8000307a <iget+0x3c>
    8000308e:	40d8                	lw	a4,4(s1)
    80003090:	ff4715e3          	bne	a4,s4,8000307a <iget+0x3c>
      ip->ref++;
    80003094:	2785                	addiw	a5,a5,1
    80003096:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003098:	0001e517          	auipc	a0,0x1e
    8000309c:	af850513          	addi	a0,a0,-1288 # 80020b90 <itable>
    800030a0:	c11fd0ef          	jal	80000cb0 <release>
      return ip;
    800030a4:	89a6                	mv	s3,s1
    800030a6:	a015                	j	800030ca <iget+0x8c>
  if (empty == 0)
    800030a8:	02098a63          	beqz	s3,800030dc <iget+0x9e>
  ip->dev = dev;
    800030ac:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    800030b0:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    800030b4:	4785                	li	a5,1
    800030b6:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    800030ba:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    800030be:	0001e517          	auipc	a0,0x1e
    800030c2:	ad250513          	addi	a0,a0,-1326 # 80020b90 <itable>
    800030c6:	bebfd0ef          	jal	80000cb0 <release>
}
    800030ca:	854e                	mv	a0,s3
    800030cc:	70a2                	ld	ra,40(sp)
    800030ce:	7402                	ld	s0,32(sp)
    800030d0:	64e2                	ld	s1,24(sp)
    800030d2:	6942                	ld	s2,16(sp)
    800030d4:	69a2                	ld	s3,8(sp)
    800030d6:	6a02                	ld	s4,0(sp)
    800030d8:	6145                	addi	sp,sp,48
    800030da:	8082                	ret
    panic("iget: no inodes");
    800030dc:	00004517          	auipc	a0,0x4
    800030e0:	39450513          	addi	a0,a0,916 # 80007470 <etext+0x470>
    800030e4:	f50fd0ef          	jal	80000834 <panic>

00000000800030e8 <iinit>:
{
    800030e8:	7179                	addi	sp,sp,-48
    800030ea:	f406                	sd	ra,40(sp)
    800030ec:	f022                	sd	s0,32(sp)
    800030ee:	ec26                	sd	s1,24(sp)
    800030f0:	e84a                	sd	s2,16(sp)
    800030f2:	e44e                	sd	s3,8(sp)
    800030f4:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800030f6:	00004597          	auipc	a1,0x4
    800030fa:	38a58593          	addi	a1,a1,906 # 80007480 <etext+0x480>
    800030fe:	0001e517          	auipc	a0,0x1e
    80003102:	a9250513          	addi	a0,a0,-1390 # 80020b90 <itable>
    80003106:	aa3fd0ef          	jal	80000ba8 <initlock>
  for (i = 0; i < NINODE; i++) {
    8000310a:	0001e497          	auipc	s1,0x1e
    8000310e:	aae48493          	addi	s1,s1,-1362 # 80020bb8 <itable+0x28>
    80003112:	0001f997          	auipc	s3,0x1f
    80003116:	53698993          	addi	s3,s3,1334 # 80022648 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000311a:	00004917          	auipc	s2,0x4
    8000311e:	36e90913          	addi	s2,s2,878 # 80007488 <etext+0x488>
    80003122:	85ca                	mv	a1,s2
    80003124:	8526                	mv	a0,s1
    80003126:	6e9000ef          	jal	8000400e <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    8000312a:	08848493          	addi	s1,s1,136
    8000312e:	ff349ae3          	bne	s1,s3,80003122 <iinit+0x3a>
}
    80003132:	70a2                	ld	ra,40(sp)
    80003134:	7402                	ld	s0,32(sp)
    80003136:	64e2                	ld	s1,24(sp)
    80003138:	6942                	ld	s2,16(sp)
    8000313a:	69a2                	ld	s3,8(sp)
    8000313c:	6145                	addi	sp,sp,48
    8000313e:	8082                	ret

0000000080003140 <ialloc>:
{
    80003140:	7139                	addi	sp,sp,-64
    80003142:	fc06                	sd	ra,56(sp)
    80003144:	f822                	sd	s0,48(sp)
    80003146:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003148:	0001e717          	auipc	a4,0x1e
    8000314c:	a3472703          	lw	a4,-1484(a4) # 80020b7c <sb+0xc>
    80003150:	4785                	li	a5,1
    80003152:	06e7f063          	bgeu	a5,a4,800031b2 <ialloc+0x72>
    80003156:	f426                	sd	s1,40(sp)
    80003158:	f04a                	sd	s2,32(sp)
    8000315a:	ec4e                	sd	s3,24(sp)
    8000315c:	e852                	sd	s4,16(sp)
    8000315e:	e456                	sd	s5,8(sp)
    80003160:	e05a                	sd	s6,0(sp)
    80003162:	8aaa                	mv	s5,a0
    80003164:	8b2e                	mv	s6,a1
    80003166:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003168:	0001ea17          	auipc	s4,0x1e
    8000316c:	a08a0a13          	addi	s4,s4,-1528 # 80020b70 <sb>
    80003170:	00495593          	srli	a1,s2,0x4
    80003174:	018a2783          	lw	a5,24(s4)
    80003178:	9dbd                	addw	a1,a1,a5
    8000317a:	8556                	mv	a0,s5
    8000317c:	a9dff0ef          	jal	80002c18 <bread>
    80003180:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    80003182:	05850993          	addi	s3,a0,88
    80003186:	00f97793          	andi	a5,s2,15
    8000318a:	079a                	slli	a5,a5,0x6
    8000318c:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    8000318e:	00099783          	lh	a5,0(s3)
    80003192:	cb9d                	beqz	a5,800031c8 <ialloc+0x88>
    brelse(bp);
    80003194:	b8dff0ef          	jal	80002d20 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003198:	0905                	addi	s2,s2,1
    8000319a:	00ca2703          	lw	a4,12(s4)
    8000319e:	0009079b          	sext.w	a5,s2
    800031a2:	fce7e7e3          	bltu	a5,a4,80003170 <ialloc+0x30>
    800031a6:	74a2                	ld	s1,40(sp)
    800031a8:	7902                	ld	s2,32(sp)
    800031aa:	69e2                	ld	s3,24(sp)
    800031ac:	6a42                	ld	s4,16(sp)
    800031ae:	6aa2                	ld	s5,8(sp)
    800031b0:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    800031b2:	00004517          	auipc	a0,0x4
    800031b6:	2de50513          	addi	a0,a0,734 # 80007490 <etext+0x490>
    800031ba:	b50fd0ef          	jal	8000050a <printk>
  return 0;
    800031be:	4501                	li	a0,0
}
    800031c0:	70e2                	ld	ra,56(sp)
    800031c2:	7442                	ld	s0,48(sp)
    800031c4:	6121                	addi	sp,sp,64
    800031c6:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800031c8:	04000613          	li	a2,64
    800031cc:	4581                	li	a1,0
    800031ce:	854e                	mv	a0,s3
    800031d0:	b19fd0ef          	jal	80000ce8 <memset>
      dip->type = type;
    800031d4:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    800031d8:	8526                	mv	a0,s1
    800031da:	4fd000ef          	jal	80003ed6 <log_write>
      brelse(bp);
    800031de:	8526                	mv	a0,s1
    800031e0:	b41ff0ef          	jal	80002d20 <brelse>
      return iget(dev, inum);
    800031e4:	0009059b          	sext.w	a1,s2
    800031e8:	8556                	mv	a0,s5
    800031ea:	e55ff0ef          	jal	8000303e <iget>
    800031ee:	74a2                	ld	s1,40(sp)
    800031f0:	7902                	ld	s2,32(sp)
    800031f2:	69e2                	ld	s3,24(sp)
    800031f4:	6a42                	ld	s4,16(sp)
    800031f6:	6aa2                	ld	s5,8(sp)
    800031f8:	6b02                	ld	s6,0(sp)
    800031fa:	b7d9                	j	800031c0 <ialloc+0x80>

00000000800031fc <iupdate>:
{
    800031fc:	1101                	addi	sp,sp,-32
    800031fe:	ec06                	sd	ra,24(sp)
    80003200:	e822                	sd	s0,16(sp)
    80003202:	e426                	sd	s1,8(sp)
    80003204:	e04a                	sd	s2,0(sp)
    80003206:	1000                	addi	s0,sp,32
    80003208:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000320a:	415c                	lw	a5,4(a0)
    8000320c:	0047d79b          	srliw	a5,a5,0x4
    80003210:	0001e597          	auipc	a1,0x1e
    80003214:	9785a583          	lw	a1,-1672(a1) # 80020b88 <sb+0x18>
    80003218:	9dbd                	addw	a1,a1,a5
    8000321a:	4108                	lw	a0,0(a0)
    8000321c:	9fdff0ef          	jal	80002c18 <bread>
    80003220:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003222:	05850793          	addi	a5,a0,88
    80003226:	40d8                	lw	a4,4(s1)
    80003228:	8b3d                	andi	a4,a4,15
    8000322a:	071a                	slli	a4,a4,0x6
    8000322c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000322e:	04449703          	lh	a4,68(s1)
    80003232:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003236:	04649703          	lh	a4,70(s1)
    8000323a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000323e:	04849703          	lh	a4,72(s1)
    80003242:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003246:	04a49703          	lh	a4,74(s1)
    8000324a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000324e:	44f8                	lw	a4,76(s1)
    80003250:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003252:	03400613          	li	a2,52
    80003256:	05048593          	addi	a1,s1,80
    8000325a:	00c78513          	addi	a0,a5,12
    8000325e:	aebfd0ef          	jal	80000d48 <memmove>
  log_write(bp);
    80003262:	854a                	mv	a0,s2
    80003264:	473000ef          	jal	80003ed6 <log_write>
  brelse(bp);
    80003268:	854a                	mv	a0,s2
    8000326a:	ab7ff0ef          	jal	80002d20 <brelse>
}
    8000326e:	60e2                	ld	ra,24(sp)
    80003270:	6442                	ld	s0,16(sp)
    80003272:	64a2                	ld	s1,8(sp)
    80003274:	6902                	ld	s2,0(sp)
    80003276:	6105                	addi	sp,sp,32
    80003278:	8082                	ret

000000008000327a <idup>:
{
    8000327a:	1101                	addi	sp,sp,-32
    8000327c:	ec06                	sd	ra,24(sp)
    8000327e:	e822                	sd	s0,16(sp)
    80003280:	e426                	sd	s1,8(sp)
    80003282:	1000                	addi	s0,sp,32
    80003284:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003286:	0001e517          	auipc	a0,0x1e
    8000328a:	90a50513          	addi	a0,a0,-1782 # 80020b90 <itable>
    8000328e:	99bfd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    80003292:	449c                	lw	a5,8(s1)
    80003294:	2785                	addiw	a5,a5,1
    80003296:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003298:	0001e517          	auipc	a0,0x1e
    8000329c:	8f850513          	addi	a0,a0,-1800 # 80020b90 <itable>
    800032a0:	a11fd0ef          	jal	80000cb0 <release>
}
    800032a4:	8526                	mv	a0,s1
    800032a6:	60e2                	ld	ra,24(sp)
    800032a8:	6442                	ld	s0,16(sp)
    800032aa:	64a2                	ld	s1,8(sp)
    800032ac:	6105                	addi	sp,sp,32
    800032ae:	8082                	ret

00000000800032b0 <ilock>:
{
    800032b0:	1101                	addi	sp,sp,-32
    800032b2:	ec06                	sd	ra,24(sp)
    800032b4:	e822                	sd	s0,16(sp)
    800032b6:	e426                	sd	s1,8(sp)
    800032b8:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    800032ba:	cd19                	beqz	a0,800032d8 <ilock+0x28>
    800032bc:	84aa                	mv	s1,a0
    800032be:	451c                	lw	a5,8(a0)
    800032c0:	00f05c63          	blez	a5,800032d8 <ilock+0x28>
  acquiresleep(&ip->lock);
    800032c4:	0541                	addi	a0,a0,16
    800032c6:	57f000ef          	jal	80004044 <acquiresleep>
  if (ip->valid == 0) {
    800032ca:	40bc                	lw	a5,64(s1)
    800032cc:	cf89                	beqz	a5,800032e6 <ilock+0x36>
}
    800032ce:	60e2                	ld	ra,24(sp)
    800032d0:	6442                	ld	s0,16(sp)
    800032d2:	64a2                	ld	s1,8(sp)
    800032d4:	6105                	addi	sp,sp,32
    800032d6:	8082                	ret
    800032d8:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800032da:	00004517          	auipc	a0,0x4
    800032de:	1ce50513          	addi	a0,a0,462 # 800074a8 <etext+0x4a8>
    800032e2:	d52fd0ef          	jal	80000834 <panic>
    800032e6:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032e8:	40dc                	lw	a5,4(s1)
    800032ea:	0047d79b          	srliw	a5,a5,0x4
    800032ee:	0001e597          	auipc	a1,0x1e
    800032f2:	89a5a583          	lw	a1,-1894(a1) # 80020b88 <sb+0x18>
    800032f6:	9dbd                	addw	a1,a1,a5
    800032f8:	4088                	lw	a0,0(s1)
    800032fa:	91fff0ef          	jal	80002c18 <bread>
    800032fe:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003300:	05850593          	addi	a1,a0,88
    80003304:	40dc                	lw	a5,4(s1)
    80003306:	8bbd                	andi	a5,a5,15
    80003308:	079a                	slli	a5,a5,0x6
    8000330a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000330c:	00059783          	lh	a5,0(a1)
    80003310:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003314:	00259783          	lh	a5,2(a1)
    80003318:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000331c:	00459783          	lh	a5,4(a1)
    80003320:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003324:	00659783          	lh	a5,6(a1)
    80003328:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000332c:	459c                	lw	a5,8(a1)
    8000332e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003330:	03400613          	li	a2,52
    80003334:	05b1                	addi	a1,a1,12
    80003336:	05048513          	addi	a0,s1,80
    8000333a:	a0ffd0ef          	jal	80000d48 <memmove>
    brelse(bp);
    8000333e:	854a                	mv	a0,s2
    80003340:	9e1ff0ef          	jal	80002d20 <brelse>
    ip->valid = 1;
    80003344:	4785                	li	a5,1
    80003346:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003348:	04449783          	lh	a5,68(s1)
    8000334c:	c399                	beqz	a5,80003352 <ilock+0xa2>
    8000334e:	6902                	ld	s2,0(sp)
    80003350:	bfbd                	j	800032ce <ilock+0x1e>
      panic("ilock: no type");
    80003352:	00004517          	auipc	a0,0x4
    80003356:	15e50513          	addi	a0,a0,350 # 800074b0 <etext+0x4b0>
    8000335a:	cdafd0ef          	jal	80000834 <panic>

000000008000335e <iunlock>:
{
    8000335e:	1101                	addi	sp,sp,-32
    80003360:	ec06                	sd	ra,24(sp)
    80003362:	e822                	sd	s0,16(sp)
    80003364:	e426                	sd	s1,8(sp)
    80003366:	e04a                	sd	s2,0(sp)
    80003368:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000336a:	c505                	beqz	a0,80003392 <iunlock+0x34>
    8000336c:	84aa                	mv	s1,a0
    8000336e:	01050913          	addi	s2,a0,16
    80003372:	854a                	mv	a0,s2
    80003374:	55d000ef          	jal	800040d0 <holdingsleep>
    80003378:	cd09                	beqz	a0,80003392 <iunlock+0x34>
    8000337a:	449c                	lw	a5,8(s1)
    8000337c:	00f05b63          	blez	a5,80003392 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003380:	854a                	mv	a0,s2
    80003382:	517000ef          	jal	80004098 <releasesleep>
}
    80003386:	60e2                	ld	ra,24(sp)
    80003388:	6442                	ld	s0,16(sp)
    8000338a:	64a2                	ld	s1,8(sp)
    8000338c:	6902                	ld	s2,0(sp)
    8000338e:	6105                	addi	sp,sp,32
    80003390:	8082                	ret
    panic("iunlock");
    80003392:	00004517          	auipc	a0,0x4
    80003396:	12e50513          	addi	a0,a0,302 # 800074c0 <etext+0x4c0>
    8000339a:	c9afd0ef          	jal	80000834 <panic>

000000008000339e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000339e:	7179                	addi	sp,sp,-48
    800033a0:	f406                	sd	ra,40(sp)
    800033a2:	f022                	sd	s0,32(sp)
    800033a4:	ec26                	sd	s1,24(sp)
    800033a6:	e84a                	sd	s2,16(sp)
    800033a8:	e44e                	sd	s3,8(sp)
    800033aa:	1800                	addi	s0,sp,48
    800033ac:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    800033ae:	05050493          	addi	s1,a0,80
    800033b2:	08050913          	addi	s2,a0,128
    800033b6:	a021                	j	800033be <itrunc+0x20>
    800033b8:	0491                	addi	s1,s1,4
    800033ba:	01248b63          	beq	s1,s2,800033d0 <itrunc+0x32>
    if (ip->addrs[i]) {
    800033be:	408c                	lw	a1,0(s1)
    800033c0:	dde5                	beqz	a1,800033b8 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800033c2:	0009a503          	lw	a0,0(s3)
    800033c6:	a47ff0ef          	jal	80002e0c <bfree>
      ip->addrs[i] = 0;
    800033ca:	0004a023          	sw	zero,0(s1)
    800033ce:	b7ed                	j	800033b8 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    800033d0:	0809a583          	lw	a1,128(s3)
    800033d4:	ed89                	bnez	a1,800033ee <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800033d6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800033da:	854e                	mv	a0,s3
    800033dc:	e21ff0ef          	jal	800031fc <iupdate>
}
    800033e0:	70a2                	ld	ra,40(sp)
    800033e2:	7402                	ld	s0,32(sp)
    800033e4:	64e2                	ld	s1,24(sp)
    800033e6:	6942                	ld	s2,16(sp)
    800033e8:	69a2                	ld	s3,8(sp)
    800033ea:	6145                	addi	sp,sp,48
    800033ec:	8082                	ret
    800033ee:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800033f0:	0009a503          	lw	a0,0(s3)
    800033f4:	825ff0ef          	jal	80002c18 <bread>
    800033f8:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    800033fa:	05850493          	addi	s1,a0,88
    800033fe:	45850913          	addi	s2,a0,1112
    80003402:	a021                	j	8000340a <itrunc+0x6c>
    80003404:	0491                	addi	s1,s1,4
    80003406:	01248963          	beq	s1,s2,80003418 <itrunc+0x7a>
      if (a[j])
    8000340a:	408c                	lw	a1,0(s1)
    8000340c:	dde5                	beqz	a1,80003404 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000340e:	0009a503          	lw	a0,0(s3)
    80003412:	9fbff0ef          	jal	80002e0c <bfree>
    80003416:	b7fd                	j	80003404 <itrunc+0x66>
    brelse(bp);
    80003418:	8552                	mv	a0,s4
    8000341a:	907ff0ef          	jal	80002d20 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000341e:	0809a583          	lw	a1,128(s3)
    80003422:	0009a503          	lw	a0,0(s3)
    80003426:	9e7ff0ef          	jal	80002e0c <bfree>
    ip->addrs[NDIRECT] = 0;
    8000342a:	0809a023          	sw	zero,128(s3)
    8000342e:	6a02                	ld	s4,0(sp)
    80003430:	b75d                	j	800033d6 <itrunc+0x38>

0000000080003432 <iput>:
{
    80003432:	7179                	addi	sp,sp,-48
    80003434:	f406                	sd	ra,40(sp)
    80003436:	f022                	sd	s0,32(sp)
    80003438:	ec26                	sd	s1,24(sp)
    8000343a:	1800                	addi	s0,sp,48
    8000343c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000343e:	0001d517          	auipc	a0,0x1d
    80003442:	75250513          	addi	a0,a0,1874 # 80020b90 <itable>
    80003446:	fe2fd0ef          	jal	80000c28 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    8000344a:	449c                	lw	a5,8(s1)
    8000344c:	4705                	li	a4,1
    8000344e:	00e78f63          	beq	a5,a4,8000346c <iput+0x3a>
  ip->ref--;
    80003452:	37fd                	addiw	a5,a5,-1
    80003454:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003456:	0001d517          	auipc	a0,0x1d
    8000345a:	73a50513          	addi	a0,a0,1850 # 80020b90 <itable>
    8000345e:	853fd0ef          	jal	80000cb0 <release>
}
    80003462:	70a2                	ld	ra,40(sp)
    80003464:	7402                	ld	s0,32(sp)
    80003466:	64e2                	ld	s1,24(sp)
    80003468:	6145                	addi	sp,sp,48
    8000346a:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    8000346c:	40b8                	lw	a4,64(s1)
    8000346e:	d375                	beqz	a4,80003452 <iput+0x20>
    80003470:	e84a                	sd	s2,16(sp)
    80003472:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    80003474:	0004aa03          	lw	s4,0(s1)
    80003478:	0044a903          	lw	s2,4(s1)
  if (last) {
    8000347c:	04a49703          	lh	a4,74(s1)
    80003480:	ef3d                	bnez	a4,800034fe <iput+0xcc>
    80003482:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    80003484:	01048793          	addi	a5,s1,16
    80003488:	89be                	mv	s3,a5
    8000348a:	853e                	mv	a0,a5
    8000348c:	3b9000ef          	jal	80004044 <acquiresleep>
    release(&itable.lock);
    80003490:	0001d517          	auipc	a0,0x1d
    80003494:	70050513          	addi	a0,a0,1792 # 80020b90 <itable>
    80003498:	819fd0ef          	jal	80000cb0 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    8000349c:	8526                	mv	a0,s1
    8000349e:	f01ff0ef          	jal	8000339e <itrunc>
    ip->valid = 0;
    800034a2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800034a6:	854e                	mv	a0,s3
    800034a8:	3f1000ef          	jal	80004098 <releasesleep>
    acquire(&itable.lock);
    800034ac:	0001d517          	auipc	a0,0x1d
    800034b0:	6e450513          	addi	a0,a0,1764 # 80020b90 <itable>
    800034b4:	f74fd0ef          	jal	80000c28 <acquire>
  ip->ref--;
    800034b8:	449c                	lw	a5,8(s1)
    800034ba:	37fd                	addiw	a5,a5,-1
    800034bc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800034be:	0001d517          	auipc	a0,0x1d
    800034c2:	6d250513          	addi	a0,a0,1746 # 80020b90 <itable>
    800034c6:	feafd0ef          	jal	80000cb0 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800034ca:	0049579b          	srliw	a5,s2,0x4
    800034ce:	0001d597          	auipc	a1,0x1d
    800034d2:	6ba5a583          	lw	a1,1722(a1) # 80020b88 <sb+0x18>
    800034d6:	9dbd                	addw	a1,a1,a5
    800034d8:	8552                	mv	a0,s4
    800034da:	f3eff0ef          	jal	80002c18 <bread>
    800034de:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800034e0:	00f97793          	andi	a5,s2,15
  dip->type = 0;
    800034e4:	079a                	slli	a5,a5,0x6
    800034e6:	97aa                	add	a5,a5,a0
    800034e8:	04079c23          	sh	zero,88(a5)
  log_write(bp);
    800034ec:	1eb000ef          	jal	80003ed6 <log_write>
  brelse(bp);
    800034f0:	8526                	mv	a0,s1
    800034f2:	82fff0ef          	jal	80002d20 <brelse>
}
    800034f6:	6942                	ld	s2,16(sp)
    800034f8:	69a2                	ld	s3,8(sp)
    800034fa:	6a02                	ld	s4,0(sp)
    800034fc:	b79d                	j	80003462 <iput+0x30>
    800034fe:	6942                	ld	s2,16(sp)
    80003500:	6a02                	ld	s4,0(sp)
    80003502:	bf81                	j	80003452 <iput+0x20>

0000000080003504 <iunlockput>:
{
    80003504:	1101                	addi	sp,sp,-32
    80003506:	ec06                	sd	ra,24(sp)
    80003508:	e822                	sd	s0,16(sp)
    8000350a:	e426                	sd	s1,8(sp)
    8000350c:	1000                	addi	s0,sp,32
    8000350e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003510:	e4fff0ef          	jal	8000335e <iunlock>
  iput(ip);
    80003514:	8526                	mv	a0,s1
    80003516:	f1dff0ef          	jal	80003432 <iput>
}
    8000351a:	60e2                	ld	ra,24(sp)
    8000351c:	6442                	ld	s0,16(sp)
    8000351e:	64a2                	ld	s1,8(sp)
    80003520:	6105                	addi	sp,sp,32
    80003522:	8082                	ret

0000000080003524 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003524:	0001d717          	auipc	a4,0x1d
    80003528:	65872703          	lw	a4,1624(a4) # 80020b7c <sb+0xc>
    8000352c:	4785                	li	a5,1
    8000352e:	0ae7fe63          	bgeu	a5,a4,800035ea <ireclaim+0xc6>
{
    80003532:	7139                	addi	sp,sp,-64
    80003534:	fc06                	sd	ra,56(sp)
    80003536:	f822                	sd	s0,48(sp)
    80003538:	f426                	sd	s1,40(sp)
    8000353a:	f04a                	sd	s2,32(sp)
    8000353c:	ec4e                	sd	s3,24(sp)
    8000353e:	e852                	sd	s4,16(sp)
    80003540:	e456                	sd	s5,8(sp)
    80003542:	e05a                	sd	s6,0(sp)
    80003544:	0080                	addi	s0,sp,64
    80003546:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003548:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000354a:	0001da17          	auipc	s4,0x1d
    8000354e:	626a0a13          	addi	s4,s4,1574 # 80020b70 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    80003552:	00004b17          	auipc	s6,0x4
    80003556:	f76b0b13          	addi	s6,s6,-138 # 800074c8 <etext+0x4c8>
    8000355a:	a099                	j	800035a0 <ireclaim+0x7c>
    8000355c:	85ce                	mv	a1,s3
    8000355e:	855a                	mv	a0,s6
    80003560:	fabfc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    80003564:	85ce                	mv	a1,s3
    80003566:	8556                	mv	a0,s5
    80003568:	ad7ff0ef          	jal	8000303e <iget>
    8000356c:	89aa                	mv	s3,a0
    brelse(bp);
    8000356e:	854a                	mv	a0,s2
    80003570:	fb0ff0ef          	jal	80002d20 <brelse>
    if (ip) {
    80003574:	00098f63          	beqz	s3,80003592 <ireclaim+0x6e>
      begin_op();
    80003578:	7b0000ef          	jal	80003d28 <begin_op>
      ilock(ip);
    8000357c:	854e                	mv	a0,s3
    8000357e:	d33ff0ef          	jal	800032b0 <ilock>
      iunlock(ip);
    80003582:	854e                	mv	a0,s3
    80003584:	ddbff0ef          	jal	8000335e <iunlock>
      iput(ip);
    80003588:	854e                	mv	a0,s3
    8000358a:	ea9ff0ef          	jal	80003432 <iput>
      end_op();
    8000358e:	027000ef          	jal	80003db4 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003592:	0485                	addi	s1,s1,1
    80003594:	00ca2703          	lw	a4,12(s4)
    80003598:	0004879b          	sext.w	a5,s1
    8000359c:	02e7fd63          	bgeu	a5,a4,800035d6 <ireclaim+0xb2>
    800035a0:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800035a4:	0044d593          	srli	a1,s1,0x4
    800035a8:	018a2783          	lw	a5,24(s4)
    800035ac:	9dbd                	addw	a1,a1,a5
    800035ae:	8556                	mv	a0,s5
    800035b0:	e68ff0ef          	jal	80002c18 <bread>
    800035b4:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800035b6:	05850793          	addi	a5,a0,88
    800035ba:	00f9f713          	andi	a4,s3,15
    800035be:	071a                	slli	a4,a4,0x6
    800035c0:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    800035c2:	00079703          	lh	a4,0(a5)
    800035c6:	c701                	beqz	a4,800035ce <ireclaim+0xaa>
    800035c8:	00679783          	lh	a5,6(a5)
    800035cc:	dbc1                	beqz	a5,8000355c <ireclaim+0x38>
    brelse(bp);
    800035ce:	854a                	mv	a0,s2
    800035d0:	f50ff0ef          	jal	80002d20 <brelse>
    if (ip) {
    800035d4:	bf7d                	j	80003592 <ireclaim+0x6e>
}
    800035d6:	70e2                	ld	ra,56(sp)
    800035d8:	7442                	ld	s0,48(sp)
    800035da:	74a2                	ld	s1,40(sp)
    800035dc:	7902                	ld	s2,32(sp)
    800035de:	69e2                	ld	s3,24(sp)
    800035e0:	6a42                	ld	s4,16(sp)
    800035e2:	6aa2                	ld	s5,8(sp)
    800035e4:	6b02                	ld	s6,0(sp)
    800035e6:	6121                	addi	sp,sp,64
    800035e8:	8082                	ret
    800035ea:	8082                	ret

00000000800035ec <fsinit>:
{
    800035ec:	1101                	addi	sp,sp,-32
    800035ee:	ec06                	sd	ra,24(sp)
    800035f0:	e822                	sd	s0,16(sp)
    800035f2:	e426                	sd	s1,8(sp)
    800035f4:	e04a                	sd	s2,0(sp)
    800035f6:	1000                	addi	s0,sp,32
    800035f8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800035fa:	4585                	li	a1,1
    800035fc:	e1cff0ef          	jal	80002c18 <bread>
    80003600:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003602:	02000613          	li	a2,32
    80003606:	05850593          	addi	a1,a0,88
    8000360a:	0001d517          	auipc	a0,0x1d
    8000360e:	56650513          	addi	a0,a0,1382 # 80020b70 <sb>
    80003612:	f36fd0ef          	jal	80000d48 <memmove>
  brelse(bp);
    80003616:	8526                	mv	a0,s1
    80003618:	f08ff0ef          	jal	80002d20 <brelse>
  if (sb.magic != FSMAGIC)
    8000361c:	0001d717          	auipc	a4,0x1d
    80003620:	55472703          	lw	a4,1364(a4) # 80020b70 <sb>
    80003624:	102037b7          	lui	a5,0x10203
    80003628:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000362c:	02f71263          	bne	a4,a5,80003650 <fsinit+0x64>
  initlog(dev, &sb);
    80003630:	0001d597          	auipc	a1,0x1d
    80003634:	54058593          	addi	a1,a1,1344 # 80020b70 <sb>
    80003638:	854a                	mv	a0,s2
    8000363a:	66c000ef          	jal	80003ca6 <initlog>
  ireclaim(dev);
    8000363e:	854a                	mv	a0,s2
    80003640:	ee5ff0ef          	jal	80003524 <ireclaim>
}
    80003644:	60e2                	ld	ra,24(sp)
    80003646:	6442                	ld	s0,16(sp)
    80003648:	64a2                	ld	s1,8(sp)
    8000364a:	6902                	ld	s2,0(sp)
    8000364c:	6105                	addi	sp,sp,32
    8000364e:	8082                	ret
    panic("invalid file system");
    80003650:	00004517          	auipc	a0,0x4
    80003654:	e9850513          	addi	a0,a0,-360 # 800074e8 <etext+0x4e8>
    80003658:	9dcfd0ef          	jal	80000834 <panic>

000000008000365c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000365c:	1141                	addi	sp,sp,-16
    8000365e:	e406                	sd	ra,8(sp)
    80003660:	e022                	sd	s0,0(sp)
    80003662:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003664:	411c                	lw	a5,0(a0)
    80003666:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003668:	415c                	lw	a5,4(a0)
    8000366a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000366c:	04451783          	lh	a5,68(a0)
    80003670:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003674:	04a51783          	lh	a5,74(a0)
    80003678:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000367c:	04c56783          	lwu	a5,76(a0)
    80003680:	e99c                	sd	a5,16(a1)
}
    80003682:	60a2                	ld	ra,8(sp)
    80003684:	6402                	ld	s0,0(sp)
    80003686:	0141                	addi	sp,sp,16
    80003688:	8082                	ret

000000008000368a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    8000368a:	457c                	lw	a5,76(a0)
    8000368c:	0ed7e663          	bltu	a5,a3,80003778 <readi+0xee>
{
    80003690:	7159                	addi	sp,sp,-112
    80003692:	f486                	sd	ra,104(sp)
    80003694:	f0a2                	sd	s0,96(sp)
    80003696:	eca6                	sd	s1,88(sp)
    80003698:	e0d2                	sd	s4,64(sp)
    8000369a:	fc56                	sd	s5,56(sp)
    8000369c:	f85a                	sd	s6,48(sp)
    8000369e:	f45e                	sd	s7,40(sp)
    800036a0:	1880                	addi	s0,sp,112
    800036a2:	8b2a                	mv	s6,a0
    800036a4:	8bae                	mv	s7,a1
    800036a6:	8a32                	mv	s4,a2
    800036a8:	84b6                	mv	s1,a3
    800036aa:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    800036ac:	9f35                	addw	a4,a4,a3
    return 0;
    800036ae:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    800036b0:	0ad76b63          	bltu	a4,a3,80003766 <readi+0xdc>
    800036b4:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    800036b6:	00e7f463          	bgeu	a5,a4,800036be <readi+0x34>
    n = ip->size - off;
    800036ba:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800036be:	080a8b63          	beqz	s5,80003754 <readi+0xca>
    800036c2:	e8ca                	sd	s2,80(sp)
    800036c4:	f062                	sd	s8,32(sp)
    800036c6:	ec66                	sd	s9,24(sp)
    800036c8:	e86a                	sd	s10,16(sp)
    800036ca:	e46e                	sd	s11,8(sp)
    800036cc:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800036ce:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800036d2:	5c7d                	li	s8,-1
    800036d4:	a80d                	j	80003706 <readi+0x7c>
    800036d6:	020d1d93          	slli	s11,s10,0x20
    800036da:	020ddd93          	srli	s11,s11,0x20
    800036de:	05890613          	addi	a2,s2,88
    800036e2:	86ee                	mv	a3,s11
    800036e4:	963e                	add	a2,a2,a5
    800036e6:	85d2                	mv	a1,s4
    800036e8:	855e                	mv	a0,s7
    800036ea:	bfffe0ef          	jal	800022e8 <either_copyout>
    800036ee:	05850363          	beq	a0,s8,80003734 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800036f2:	854a                	mv	a0,s2
    800036f4:	e2cff0ef          	jal	80002d20 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800036f8:	013d09bb          	addw	s3,s10,s3
    800036fc:	009d04bb          	addw	s1,s10,s1
    80003700:	9a6e                	add	s4,s4,s11
    80003702:	0559f363          	bgeu	s3,s5,80003748 <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    80003706:	00a4d59b          	srliw	a1,s1,0xa
    8000370a:	855a                	mv	a0,s6
    8000370c:	873ff0ef          	jal	80002f7e <bmap>
    80003710:	85aa                	mv	a1,a0
    if (addr == 0)
    80003712:	c139                	beqz	a0,80003758 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003714:	000b2503          	lw	a0,0(s6)
    80003718:	d00ff0ef          	jal	80002c18 <bread>
    8000371c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    8000371e:	3ff4f793          	andi	a5,s1,1023
    80003722:	40fc873b          	subw	a4,s9,a5
    80003726:	413a86bb          	subw	a3,s5,s3
    8000372a:	8d3a                	mv	s10,a4
    8000372c:	fae6f5e3          	bgeu	a3,a4,800036d6 <readi+0x4c>
    80003730:	8d36                	mv	s10,a3
    80003732:	b755                	j	800036d6 <readi+0x4c>
      brelse(bp);
    80003734:	854a                	mv	a0,s2
    80003736:	deaff0ef          	jal	80002d20 <brelse>
      tot = -1;
    8000373a:	59fd                	li	s3,-1
      break;
    8000373c:	6946                	ld	s2,80(sp)
    8000373e:	7c02                	ld	s8,32(sp)
    80003740:	6ce2                	ld	s9,24(sp)
    80003742:	6d42                	ld	s10,16(sp)
    80003744:	6da2                	ld	s11,8(sp)
    80003746:	a831                	j	80003762 <readi+0xd8>
    80003748:	6946                	ld	s2,80(sp)
    8000374a:	7c02                	ld	s8,32(sp)
    8000374c:	6ce2                	ld	s9,24(sp)
    8000374e:	6d42                	ld	s10,16(sp)
    80003750:	6da2                	ld	s11,8(sp)
    80003752:	a801                	j	80003762 <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003754:	89d6                	mv	s3,s5
    80003756:	a031                	j	80003762 <readi+0xd8>
    80003758:	6946                	ld	s2,80(sp)
    8000375a:	7c02                	ld	s8,32(sp)
    8000375c:	6ce2                	ld	s9,24(sp)
    8000375e:	6d42                	ld	s10,16(sp)
    80003760:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003762:	854e                	mv	a0,s3
    80003764:	69a6                	ld	s3,72(sp)
}
    80003766:	70a6                	ld	ra,104(sp)
    80003768:	7406                	ld	s0,96(sp)
    8000376a:	64e6                	ld	s1,88(sp)
    8000376c:	6a06                	ld	s4,64(sp)
    8000376e:	7ae2                	ld	s5,56(sp)
    80003770:	7b42                	ld	s6,48(sp)
    80003772:	7ba2                	ld	s7,40(sp)
    80003774:	6165                	addi	sp,sp,112
    80003776:	8082                	ret
    return 0;
    80003778:	4501                	li	a0,0
}
    8000377a:	8082                	ret

000000008000377c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    8000377c:	457c                	lw	a5,76(a0)
    8000377e:	0ed7ee63          	bltu	a5,a3,8000387a <writei+0xfe>
{
    80003782:	7159                	addi	sp,sp,-112
    80003784:	f486                	sd	ra,104(sp)
    80003786:	f0a2                	sd	s0,96(sp)
    80003788:	e8ca                	sd	s2,80(sp)
    8000378a:	e0d2                	sd	s4,64(sp)
    8000378c:	fc56                	sd	s5,56(sp)
    8000378e:	f85a                	sd	s6,48(sp)
    80003790:	f45e                	sd	s7,40(sp)
    80003792:	1880                	addi	s0,sp,112
    80003794:	8aaa                	mv	s5,a0
    80003796:	8bae                	mv	s7,a1
    80003798:	8a32                	mv	s4,a2
    8000379a:	8936                	mv	s2,a3
    8000379c:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    8000379e:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    800037a2:	00043737          	lui	a4,0x43
    800037a6:	0cf76c63          	bltu	a4,a5,8000387e <writei+0x102>
    800037aa:	0cd7ea63          	bltu	a5,a3,8000387e <writei+0x102>
    800037ae:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800037b0:	0a0b0d63          	beqz	s6,8000386a <writei+0xee>
    800037b4:	eca6                	sd	s1,88(sp)
    800037b6:	f062                	sd	s8,32(sp)
    800037b8:	ec66                	sd	s9,24(sp)
    800037ba:	e86a                	sd	s10,16(sp)
    800037bc:	e46e                	sd	s11,8(sp)
    800037be:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800037c0:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800037c4:	5c7d                	li	s8,-1
    800037c6:	a825                	j	800037fe <writei+0x82>
    800037c8:	020d1d93          	slli	s11,s10,0x20
    800037cc:	020ddd93          	srli	s11,s11,0x20
    800037d0:	05848513          	addi	a0,s1,88
    800037d4:	86ee                	mv	a3,s11
    800037d6:	8652                	mv	a2,s4
    800037d8:	85de                	mv	a1,s7
    800037da:	953e                	add	a0,a0,a5
    800037dc:	b59fe0ef          	jal	80002334 <either_copyin>
    800037e0:	05850663          	beq	a0,s8,8000382c <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    800037e4:	8526                	mv	a0,s1
    800037e6:	6f0000ef          	jal	80003ed6 <log_write>
    brelse(bp);
    800037ea:	8526                	mv	a0,s1
    800037ec:	d34ff0ef          	jal	80002d20 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800037f0:	013d09bb          	addw	s3,s10,s3
    800037f4:	012d093b          	addw	s2,s10,s2
    800037f8:	9a6e                	add	s4,s4,s11
    800037fa:	0369ff63          	bgeu	s3,s6,80003838 <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    800037fe:	00a9559b          	srliw	a1,s2,0xa
    80003802:	8556                	mv	a0,s5
    80003804:	f7aff0ef          	jal	80002f7e <bmap>
    80003808:	85aa                	mv	a1,a0
    if (addr == 0)
    8000380a:	c51d                	beqz	a0,80003838 <writei+0xbc>
    bp = bread(ip->dev, addr);
    8000380c:	000aa503          	lw	a0,0(s5)
    80003810:	c08ff0ef          	jal	80002c18 <bread>
    80003814:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003816:	3ff97793          	andi	a5,s2,1023
    8000381a:	40fc873b          	subw	a4,s9,a5
    8000381e:	413b06bb          	subw	a3,s6,s3
    80003822:	8d3a                	mv	s10,a4
    80003824:	fae6f2e3          	bgeu	a3,a4,800037c8 <writei+0x4c>
    80003828:	8d36                	mv	s10,a3
    8000382a:	bf79                	j	800037c8 <writei+0x4c>
      log_write(bp);
    8000382c:	8526                	mv	a0,s1
    8000382e:	6a8000ef          	jal	80003ed6 <log_write>
      brelse(bp);
    80003832:	8526                	mv	a0,s1
    80003834:	cecff0ef          	jal	80002d20 <brelse>
  }

  if (off > ip->size)
    80003838:	04caa783          	lw	a5,76(s5)
    8000383c:	0327f963          	bgeu	a5,s2,8000386e <writei+0xf2>
    ip->size = off;
    80003840:	052aa623          	sw	s2,76(s5)
    80003844:	64e6                	ld	s1,88(sp)
    80003846:	7c02                	ld	s8,32(sp)
    80003848:	6ce2                	ld	s9,24(sp)
    8000384a:	6d42                	ld	s10,16(sp)
    8000384c:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000384e:	8556                	mv	a0,s5
    80003850:	9adff0ef          	jal	800031fc <iupdate>

  return tot;
    80003854:	854e                	mv	a0,s3
    80003856:	69a6                	ld	s3,72(sp)
}
    80003858:	70a6                	ld	ra,104(sp)
    8000385a:	7406                	ld	s0,96(sp)
    8000385c:	6946                	ld	s2,80(sp)
    8000385e:	6a06                	ld	s4,64(sp)
    80003860:	7ae2                	ld	s5,56(sp)
    80003862:	7b42                	ld	s6,48(sp)
    80003864:	7ba2                	ld	s7,40(sp)
    80003866:	6165                	addi	sp,sp,112
    80003868:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    8000386a:	89da                	mv	s3,s6
    8000386c:	b7cd                	j	8000384e <writei+0xd2>
    8000386e:	64e6                	ld	s1,88(sp)
    80003870:	7c02                	ld	s8,32(sp)
    80003872:	6ce2                	ld	s9,24(sp)
    80003874:	6d42                	ld	s10,16(sp)
    80003876:	6da2                	ld	s11,8(sp)
    80003878:	bfd9                	j	8000384e <writei+0xd2>
    return -1;
    8000387a:	557d                	li	a0,-1
}
    8000387c:	8082                	ret
    return -1;
    8000387e:	557d                	li	a0,-1
    80003880:	bfe1                	j	80003858 <writei+0xdc>

0000000080003882 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003882:	1141                	addi	sp,sp,-16
    80003884:	e406                	sd	ra,8(sp)
    80003886:	e022                	sd	s0,0(sp)
    80003888:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000388a:	4639                	li	a2,14
    8000388c:	d30fd0ef          	jal	80000dbc <strncmp>
}
    80003890:	60a2                	ld	ra,8(sp)
    80003892:	6402                	ld	s0,0(sp)
    80003894:	0141                	addi	sp,sp,16
    80003896:	8082                	ret

0000000080003898 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003898:	711d                	addi	sp,sp,-96
    8000389a:	ec86                	sd	ra,88(sp)
    8000389c:	e8a2                	sd	s0,80(sp)
    8000389e:	e4a6                	sd	s1,72(sp)
    800038a0:	e0ca                	sd	s2,64(sp)
    800038a2:	fc4e                	sd	s3,56(sp)
    800038a4:	f852                	sd	s4,48(sp)
    800038a6:	f456                	sd	s5,40(sp)
    800038a8:	f05a                	sd	s6,32(sp)
    800038aa:	ec5e                	sd	s7,24(sp)
    800038ac:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    800038ae:	04451703          	lh	a4,68(a0)
    800038b2:	4785                	li	a5,1
    800038b4:	00f71f63          	bne	a4,a5,800038d2 <dirlookup+0x3a>
    800038b8:	892a                	mv	s2,a0
    800038ba:	8aae                	mv	s5,a1
    800038bc:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    800038be:	457c                	lw	a5,76(a0)
    800038c0:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038c2:	fa040a13          	addi	s4,s0,-96
    800038c6:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    800038c8:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800038cc:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800038ce:	e39d                	bnez	a5,800038f4 <dirlookup+0x5c>
    800038d0:	a8b9                	j	8000392e <dirlookup+0x96>
    panic("dirlookup not DIR");
    800038d2:	00004517          	auipc	a0,0x4
    800038d6:	c2e50513          	addi	a0,a0,-978 # 80007500 <etext+0x500>
    800038da:	f5bfc0ef          	jal	80000834 <panic>
      panic("dirlookup read");
    800038de:	00004517          	auipc	a0,0x4
    800038e2:	c3a50513          	addi	a0,a0,-966 # 80007518 <etext+0x518>
    800038e6:	f4ffc0ef          	jal	80000834 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800038ea:	24c1                	addiw	s1,s1,16
    800038ec:	04c92783          	lw	a5,76(s2)
    800038f0:	02f4fe63          	bgeu	s1,a5,8000392c <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038f4:	874e                	mv	a4,s3
    800038f6:	86a6                	mv	a3,s1
    800038f8:	8652                	mv	a2,s4
    800038fa:	4581                	li	a1,0
    800038fc:	854a                	mv	a0,s2
    800038fe:	d8dff0ef          	jal	8000368a <readi>
    80003902:	fd351ee3          	bne	a0,s3,800038de <dirlookup+0x46>
    if (de.inum == 0)
    80003906:	fa045783          	lhu	a5,-96(s0)
    8000390a:	d3e5                	beqz	a5,800038ea <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    8000390c:	85da                	mv	a1,s6
    8000390e:	8556                	mv	a0,s5
    80003910:	f73ff0ef          	jal	80003882 <namecmp>
    80003914:	f979                	bnez	a0,800038ea <dirlookup+0x52>
      if (poff)
    80003916:	000b8463          	beqz	s7,8000391e <dirlookup+0x86>
        *poff = off;
    8000391a:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    8000391e:	fa045583          	lhu	a1,-96(s0)
    80003922:	00092503          	lw	a0,0(s2)
    80003926:	f18ff0ef          	jal	8000303e <iget>
    8000392a:	a011                	j	8000392e <dirlookup+0x96>
  return 0;
    8000392c:	4501                	li	a0,0
}
    8000392e:	60e6                	ld	ra,88(sp)
    80003930:	6446                	ld	s0,80(sp)
    80003932:	64a6                	ld	s1,72(sp)
    80003934:	6906                	ld	s2,64(sp)
    80003936:	79e2                	ld	s3,56(sp)
    80003938:	7a42                	ld	s4,48(sp)
    8000393a:	7aa2                	ld	s5,40(sp)
    8000393c:	7b02                	ld	s6,32(sp)
    8000393e:	6be2                	ld	s7,24(sp)
    80003940:	6125                	addi	sp,sp,96
    80003942:	8082                	ret

0000000080003944 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003944:	711d                	addi	sp,sp,-96
    80003946:	ec86                	sd	ra,88(sp)
    80003948:	e8a2                	sd	s0,80(sp)
    8000394a:	e4a6                	sd	s1,72(sp)
    8000394c:	e0ca                	sd	s2,64(sp)
    8000394e:	fc4e                	sd	s3,56(sp)
    80003950:	f852                	sd	s4,48(sp)
    80003952:	f456                	sd	s5,40(sp)
    80003954:	f05a                	sd	s6,32(sp)
    80003956:	ec5e                	sd	s7,24(sp)
    80003958:	e862                	sd	s8,16(sp)
    8000395a:	e466                	sd	s9,8(sp)
    8000395c:	e06a                	sd	s10,0(sp)
    8000395e:	1080                	addi	s0,sp,96
    80003960:	84aa                	mv	s1,a0
    80003962:	8b2e                	mv	s6,a1
    80003964:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003966:	00054703          	lbu	a4,0(a0)
    8000396a:	02f00793          	li	a5,47
    8000396e:	00f70f63          	beq	a4,a5,8000398c <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003972:	fd7fd0ef          	jal	80001948 <myproc>
    80003976:	15053503          	ld	a0,336(a0)
    8000397a:	901ff0ef          	jal	8000327a <idup>
    8000397e:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003980:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    80003984:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003986:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003988:	4b85                	li	s7,1
    8000398a:	a07d                	j	80003a38 <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    8000398c:	4585                	li	a1,1
    8000398e:	852e                	mv	a0,a1
    80003990:	eaeff0ef          	jal	8000303e <iget>
    80003994:	8a2a                	mv	s4,a0
    80003996:	b7ed                	j	80003980 <namex+0x3c>
      iunlockput(ip);
    80003998:	8552                	mv	a0,s4
    8000399a:	b6bff0ef          	jal	80003504 <iunlockput>
      return 0;
    8000399e:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    800039a0:	8552                	mv	a0,s4
    800039a2:	60e6                	ld	ra,88(sp)
    800039a4:	6446                	ld	s0,80(sp)
    800039a6:	64a6                	ld	s1,72(sp)
    800039a8:	6906                	ld	s2,64(sp)
    800039aa:	79e2                	ld	s3,56(sp)
    800039ac:	7a42                	ld	s4,48(sp)
    800039ae:	7aa2                	ld	s5,40(sp)
    800039b0:	7b02                	ld	s6,32(sp)
    800039b2:	6be2                	ld	s7,24(sp)
    800039b4:	6c42                	ld	s8,16(sp)
    800039b6:	6ca2                	ld	s9,8(sp)
    800039b8:	6d02                	ld	s10,0(sp)
    800039ba:	6125                	addi	sp,sp,96
    800039bc:	8082                	ret
      iunlockput(ip);
    800039be:	8552                	mv	a0,s4
    800039c0:	b45ff0ef          	jal	80003504 <iunlockput>
      return 0;
    800039c4:	4a01                	li	s4,0
    800039c6:	bfe9                	j	800039a0 <namex+0x5c>
      iunlock(ip);
    800039c8:	8552                	mv	a0,s4
    800039ca:	995ff0ef          	jal	8000335e <iunlock>
      return ip;
    800039ce:	bfc9                	j	800039a0 <namex+0x5c>
      iunlockput(ip);
    800039d0:	8552                	mv	a0,s4
    800039d2:	b33ff0ef          	jal	80003504 <iunlockput>
      return 0;
    800039d6:	8a4a                	mv	s4,s2
    800039d8:	b7e1                	j	800039a0 <namex+0x5c>
  while (*path != '/' && *path != 0)
    800039da:	8926                	mv	s2,s1
  len = path - s;
    800039dc:	4d01                	li	s10,0
    800039de:	4601                	li	a2,0
    memmove(name, s, len);
    800039e0:	2601                	sext.w	a2,a2
    800039e2:	85a6                	mv	a1,s1
    800039e4:	8556                	mv	a0,s5
    800039e6:	b62fd0ef          	jal	80000d48 <memmove>
    name[len] = 0;
    800039ea:	9d56                	add	s10,s10,s5
    800039ec:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffdb788>
  while (*path == '/')
    800039f0:	00094783          	lbu	a5,0(s2)
    800039f4:	09379b63          	bne	a5,s3,80003a8a <namex+0x146>
    800039f8:	84ca                	mv	s1,s2
    path++;
    800039fa:	0485                	addi	s1,s1,1
  while (*path == '/')
    800039fc:	0004c783          	lbu	a5,0(s1)
    80003a00:	ff378de3          	beq	a5,s3,800039fa <namex+0xb6>
    ilock(ip);
    80003a04:	8552                	mv	a0,s4
    80003a06:	8abff0ef          	jal	800032b0 <ilock>
    if (ip->type != T_DIR) {
    80003a0a:	044a1783          	lh	a5,68(s4)
    80003a0e:	f97795e3          	bne	a5,s7,80003998 <namex+0x54>
    if (ip->nlink == 0) {
    80003a12:	04aa1783          	lh	a5,74(s4)
    80003a16:	d7c5                	beqz	a5,800039be <namex+0x7a>
    if (nameiparent && *path == '\0') {
    80003a18:	000b0563          	beqz	s6,80003a22 <namex+0xde>
    80003a1c:	0004c783          	lbu	a5,0(s1)
    80003a20:	d7c5                	beqz	a5,800039c8 <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003a22:	4601                	li	a2,0
    80003a24:	85d6                	mv	a1,s5
    80003a26:	8552                	mv	a0,s4
    80003a28:	e71ff0ef          	jal	80003898 <dirlookup>
    80003a2c:	892a                	mv	s2,a0
    80003a2e:	d14d                	beqz	a0,800039d0 <namex+0x8c>
    iunlockput(ip);
    80003a30:	8552                	mv	a0,s4
    80003a32:	ad3ff0ef          	jal	80003504 <iunlockput>
    ip = next;
    80003a36:	8a4a                	mv	s4,s2
  while (*path == '/')
    80003a38:	0004c783          	lbu	a5,0(s1)
    80003a3c:	01379763          	bne	a5,s3,80003a4a <namex+0x106>
    path++;
    80003a40:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003a42:	0004c783          	lbu	a5,0(s1)
    80003a46:	ff378de3          	beq	a5,s3,80003a40 <namex+0xfc>
  if (*path == 0)
    80003a4a:	c7a1                	beqz	a5,80003a92 <namex+0x14e>
  while (*path != '/' && *path != 0)
    80003a4c:	0004c783          	lbu	a5,0(s1)
    80003a50:	fd178713          	addi	a4,a5,-47
    80003a54:	d359                	beqz	a4,800039da <namex+0x96>
    80003a56:	d3d1                	beqz	a5,800039da <namex+0x96>
    80003a58:	8926                	mv	s2,s1
    path++;
    80003a5a:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    80003a5c:	00094783          	lbu	a5,0(s2)
    80003a60:	fd178713          	addi	a4,a5,-47
    80003a64:	c311                	beqz	a4,80003a68 <namex+0x124>
    80003a66:	fbf5                	bnez	a5,80003a5a <namex+0x116>
  len = path - s;
    80003a68:	40990633          	sub	a2,s2,s1
    80003a6c:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80003a70:	f7ac58e3          	bge	s8,s10,800039e0 <namex+0x9c>
    memmove(name, s, DIRSIZ);
    80003a74:	8666                	mv	a2,s9
    80003a76:	85a6                	mv	a1,s1
    80003a78:	8556                	mv	a0,s5
    80003a7a:	acefd0ef          	jal	80000d48 <memmove>
  while (*path == '/')
    80003a7e:	00094783          	lbu	a5,0(s2)
    80003a82:	84ca                	mv	s1,s2
    80003a84:	f7378be3          	beq	a5,s3,800039fa <namex+0xb6>
    80003a88:	bfb5                	j	80003a04 <namex+0xc0>
  while ((path = skipelem(path, name)) != 0) {
    80003a8a:	00090463          	beqz	s2,80003a92 <namex+0x14e>
    80003a8e:	84ca                	mv	s1,s2
    80003a90:	bf95                	j	80003a04 <namex+0xc0>
  if (nameiparent) {
    80003a92:	f00b07e3          	beqz	s6,800039a0 <namex+0x5c>
    iput(ip);
    80003a96:	8552                	mv	a0,s4
    80003a98:	99bff0ef          	jal	80003432 <iput>
    return 0;
    80003a9c:	4a01                	li	s4,0
    80003a9e:	b709                	j	800039a0 <namex+0x5c>

0000000080003aa0 <dirlink>:
{
    80003aa0:	715d                	addi	sp,sp,-80
    80003aa2:	e486                	sd	ra,72(sp)
    80003aa4:	e0a2                	sd	s0,64(sp)
    80003aa6:	f84a                	sd	s2,48(sp)
    80003aa8:	ec56                	sd	s5,24(sp)
    80003aaa:	e85a                	sd	s6,16(sp)
    80003aac:	0880                	addi	s0,sp,80
    80003aae:	892a                	mv	s2,a0
    80003ab0:	8aae                	mv	s5,a1
    80003ab2:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003ab4:	4601                	li	a2,0
    80003ab6:	de3ff0ef          	jal	80003898 <dirlookup>
    80003aba:	ed1d                	bnez	a0,80003af8 <dirlink+0x58>
    80003abc:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003abe:	04c92483          	lw	s1,76(s2)
    80003ac2:	c4b9                	beqz	s1,80003b10 <dirlink+0x70>
    80003ac4:	f44e                	sd	s3,40(sp)
    80003ac6:	f052                	sd	s4,32(sp)
    80003ac8:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003aca:	fb040a13          	addi	s4,s0,-80
    80003ace:	49c1                	li	s3,16
    80003ad0:	874e                	mv	a4,s3
    80003ad2:	86a6                	mv	a3,s1
    80003ad4:	8652                	mv	a2,s4
    80003ad6:	4581                	li	a1,0
    80003ad8:	854a                	mv	a0,s2
    80003ada:	bb1ff0ef          	jal	8000368a <readi>
    80003ade:	03351163          	bne	a0,s3,80003b00 <dirlink+0x60>
    if (de.inum == 0)
    80003ae2:	fb045783          	lhu	a5,-80(s0)
    80003ae6:	c39d                	beqz	a5,80003b0c <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003ae8:	24c1                	addiw	s1,s1,16
    80003aea:	04c92783          	lw	a5,76(s2)
    80003aee:	fef4e1e3          	bltu	s1,a5,80003ad0 <dirlink+0x30>
    80003af2:	79a2                	ld	s3,40(sp)
    80003af4:	7a02                	ld	s4,32(sp)
    80003af6:	a829                	j	80003b10 <dirlink+0x70>
    iput(ip);
    80003af8:	93bff0ef          	jal	80003432 <iput>
    return -1;
    80003afc:	557d                	li	a0,-1
    80003afe:	a83d                	j	80003b3c <dirlink+0x9c>
      panic("dirlink read");
    80003b00:	00004517          	auipc	a0,0x4
    80003b04:	a2850513          	addi	a0,a0,-1496 # 80007528 <etext+0x528>
    80003b08:	d2dfc0ef          	jal	80000834 <panic>
    80003b0c:	79a2                	ld	s3,40(sp)
    80003b0e:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003b10:	4639                	li	a2,14
    80003b12:	85d6                	mv	a1,s5
    80003b14:	fb240513          	addi	a0,s0,-78
    80003b18:	adefd0ef          	jal	80000df6 <strncpy>
  de.inum = inum;
    80003b1c:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b20:	4741                	li	a4,16
    80003b22:	86a6                	mv	a3,s1
    80003b24:	fb040613          	addi	a2,s0,-80
    80003b28:	4581                	li	a1,0
    80003b2a:	854a                	mv	a0,s2
    80003b2c:	c51ff0ef          	jal	8000377c <writei>
    80003b30:	1541                	addi	a0,a0,-16
    80003b32:	00a03533          	snez	a0,a0
    80003b36:	40a0053b          	negw	a0,a0
    80003b3a:	74e2                	ld	s1,56(sp)
}
    80003b3c:	60a6                	ld	ra,72(sp)
    80003b3e:	6406                	ld	s0,64(sp)
    80003b40:	7942                	ld	s2,48(sp)
    80003b42:	6ae2                	ld	s5,24(sp)
    80003b44:	6b42                	ld	s6,16(sp)
    80003b46:	6161                	addi	sp,sp,80
    80003b48:	8082                	ret

0000000080003b4a <namei>:

struct inode *
namei(char *path)
{
    80003b4a:	1101                	addi	sp,sp,-32
    80003b4c:	ec06                	sd	ra,24(sp)
    80003b4e:	e822                	sd	s0,16(sp)
    80003b50:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003b52:	fe040613          	addi	a2,s0,-32
    80003b56:	4581                	li	a1,0
    80003b58:	dedff0ef          	jal	80003944 <namex>
}
    80003b5c:	60e2                	ld	ra,24(sp)
    80003b5e:	6442                	ld	s0,16(sp)
    80003b60:	6105                	addi	sp,sp,32
    80003b62:	8082                	ret

0000000080003b64 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003b64:	1141                	addi	sp,sp,-16
    80003b66:	e406                	sd	ra,8(sp)
    80003b68:	e022                	sd	s0,0(sp)
    80003b6a:	0800                	addi	s0,sp,16
    80003b6c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003b6e:	4585                	li	a1,1
    80003b70:	dd5ff0ef          	jal	80003944 <namex>
}
    80003b74:	60a2                	ld	ra,8(sp)
    80003b76:	6402                	ld	s0,0(sp)
    80003b78:	0141                	addi	sp,sp,16
    80003b7a:	8082                	ret

0000000080003b7c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003b7c:	1101                	addi	sp,sp,-32
    80003b7e:	ec06                	sd	ra,24(sp)
    80003b80:	e822                	sd	s0,16(sp)
    80003b82:	e426                	sd	s1,8(sp)
    80003b84:	e04a                	sd	s2,0(sp)
    80003b86:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003b88:	0001f917          	auipc	s2,0x1f
    80003b8c:	ab090913          	addi	s2,s2,-1360 # 80022638 <log>
    80003b90:	01892583          	lw	a1,24(s2)
    80003b94:	02492503          	lw	a0,36(s2)
    80003b98:	880ff0ef          	jal	80002c18 <bread>
    80003b9c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003b9e:	02c92603          	lw	a2,44(s2)
    80003ba2:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003ba4:	00c05f63          	blez	a2,80003bc2 <write_head+0x46>
    80003ba8:	0001f717          	auipc	a4,0x1f
    80003bac:	ac070713          	addi	a4,a4,-1344 # 80022668 <log+0x30>
    80003bb0:	87aa                	mv	a5,a0
    80003bb2:	060a                	slli	a2,a2,0x2
    80003bb4:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003bb6:	4314                	lw	a3,0(a4)
    80003bb8:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003bba:	0711                	addi	a4,a4,4
    80003bbc:	0791                	addi	a5,a5,4
    80003bbe:	fec79ce3          	bne	a5,a2,80003bb6 <write_head+0x3a>
  }
  bwrite(buf);
    80003bc2:	8526                	mv	a0,s1
    80003bc4:	92aff0ef          	jal	80002cee <bwrite>
  brelse(buf);
    80003bc8:	8526                	mv	a0,s1
    80003bca:	956ff0ef          	jal	80002d20 <brelse>
}
    80003bce:	60e2                	ld	ra,24(sp)
    80003bd0:	6442                	ld	s0,16(sp)
    80003bd2:	64a2                	ld	s1,8(sp)
    80003bd4:	6902                	ld	s2,0(sp)
    80003bd6:	6105                	addi	sp,sp,32
    80003bd8:	8082                	ret

0000000080003bda <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bda:	0001f797          	auipc	a5,0x1f
    80003bde:	a8a7a783          	lw	a5,-1398(a5) # 80022664 <log+0x2c>
    80003be2:	0cf05163          	blez	a5,80003ca4 <install_trans+0xca>
{
    80003be6:	715d                	addi	sp,sp,-80
    80003be8:	e486                	sd	ra,72(sp)
    80003bea:	e0a2                	sd	s0,64(sp)
    80003bec:	fc26                	sd	s1,56(sp)
    80003bee:	f84a                	sd	s2,48(sp)
    80003bf0:	f44e                	sd	s3,40(sp)
    80003bf2:	f052                	sd	s4,32(sp)
    80003bf4:	ec56                	sd	s5,24(sp)
    80003bf6:	e85a                	sd	s6,16(sp)
    80003bf8:	e45e                	sd	s7,8(sp)
    80003bfa:	e062                	sd	s8,0(sp)
    80003bfc:	0880                	addi	s0,sp,80
    80003bfe:	8b2a                	mv	s6,a0
    80003c00:	0001fa97          	auipc	s5,0x1f
    80003c04:	a68a8a93          	addi	s5,s5,-1432 # 80022668 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c08:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c0a:	00004c17          	auipc	s8,0x4
    80003c0e:	92ec0c13          	addi	s8,s8,-1746 # 80007538 <etext+0x538>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003c12:	0001fa17          	auipc	s4,0x1f
    80003c16:	a26a0a13          	addi	s4,s4,-1498 # 80022638 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003c1a:	40000b93          	li	s7,1024
    80003c1e:	a025                	j	80003c46 <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c20:	000aa603          	lw	a2,0(s5)
    80003c24:	85ce                	mv	a1,s3
    80003c26:	8562                	mv	a0,s8
    80003c28:	8e3fc0ef          	jal	8000050a <printk>
    80003c2c:	a839                	j	80003c4a <install_trans+0x70>
    brelse(lbuf);
    80003c2e:	854a                	mv	a0,s2
    80003c30:	8f0ff0ef          	jal	80002d20 <brelse>
    brelse(dbuf);
    80003c34:	8526                	mv	a0,s1
    80003c36:	8eaff0ef          	jal	80002d20 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c3a:	2985                	addiw	s3,s3,1
    80003c3c:	0a91                	addi	s5,s5,4
    80003c3e:	02ca2783          	lw	a5,44(s4)
    80003c42:	04f9d563          	bge	s3,a5,80003c8c <install_trans+0xb2>
    if (recovering) {
    80003c46:	fc0b1de3          	bnez	s6,80003c20 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003c4a:	018a2583          	lw	a1,24(s4)
    80003c4e:	013585bb          	addw	a1,a1,s3
    80003c52:	2585                	addiw	a1,a1,1
    80003c54:	024a2503          	lw	a0,36(s4)
    80003c58:	fc1fe0ef          	jal	80002c18 <bread>
    80003c5c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003c5e:	000aa583          	lw	a1,0(s5)
    80003c62:	024a2503          	lw	a0,36(s4)
    80003c66:	fb3fe0ef          	jal	80002c18 <bread>
    80003c6a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003c6c:	865e                	mv	a2,s7
    80003c6e:	05890593          	addi	a1,s2,88
    80003c72:	05850513          	addi	a0,a0,88
    80003c76:	8d2fd0ef          	jal	80000d48 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003c7a:	8526                	mv	a0,s1
    80003c7c:	872ff0ef          	jal	80002cee <bwrite>
    if (recovering == 0)
    80003c80:	fa0b17e3          	bnez	s6,80003c2e <install_trans+0x54>
      bunpin(dbuf);
    80003c84:	8526                	mv	a0,s1
    80003c86:	952ff0ef          	jal	80002dd8 <bunpin>
    80003c8a:	b755                	j	80003c2e <install_trans+0x54>
}
    80003c8c:	60a6                	ld	ra,72(sp)
    80003c8e:	6406                	ld	s0,64(sp)
    80003c90:	74e2                	ld	s1,56(sp)
    80003c92:	7942                	ld	s2,48(sp)
    80003c94:	79a2                	ld	s3,40(sp)
    80003c96:	7a02                	ld	s4,32(sp)
    80003c98:	6ae2                	ld	s5,24(sp)
    80003c9a:	6b42                	ld	s6,16(sp)
    80003c9c:	6ba2                	ld	s7,8(sp)
    80003c9e:	6c02                	ld	s8,0(sp)
    80003ca0:	6161                	addi	sp,sp,80
    80003ca2:	8082                	ret
    80003ca4:	8082                	ret

0000000080003ca6 <initlog>:
{
    80003ca6:	7179                	addi	sp,sp,-48
    80003ca8:	f406                	sd	ra,40(sp)
    80003caa:	f022                	sd	s0,32(sp)
    80003cac:	ec26                	sd	s1,24(sp)
    80003cae:	e84a                	sd	s2,16(sp)
    80003cb0:	e44e                	sd	s3,8(sp)
    80003cb2:	1800                	addi	s0,sp,48
    80003cb4:	84aa                	mv	s1,a0
    80003cb6:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003cb8:	0001f917          	auipc	s2,0x1f
    80003cbc:	98090913          	addi	s2,s2,-1664 # 80022638 <log>
    80003cc0:	00004597          	auipc	a1,0x4
    80003cc4:	89858593          	addi	a1,a1,-1896 # 80007558 <etext+0x558>
    80003cc8:	854a                	mv	a0,s2
    80003cca:	edffc0ef          	jal	80000ba8 <initlock>
  log.start = sb->logstart;
    80003cce:	0149a583          	lw	a1,20(s3)
    80003cd2:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003cd6:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003cda:	8526                	mv	a0,s1
    80003cdc:	f3dfe0ef          	jal	80002c18 <bread>
  log.lh.n = lh->n;
    80003ce0:	4d30                	lw	a2,88(a0)
    80003ce2:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003ce6:	00c05f63          	blez	a2,80003d04 <initlog+0x5e>
    80003cea:	87aa                	mv	a5,a0
    80003cec:	0001f717          	auipc	a4,0x1f
    80003cf0:	97c70713          	addi	a4,a4,-1668 # 80022668 <log+0x30>
    80003cf4:	060a                	slli	a2,a2,0x2
    80003cf6:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003cf8:	4ff4                	lw	a3,92(a5)
    80003cfa:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003cfc:	0791                	addi	a5,a5,4
    80003cfe:	0711                	addi	a4,a4,4
    80003d00:	fec79ce3          	bne	a5,a2,80003cf8 <initlog+0x52>
  brelse(buf);
    80003d04:	81cff0ef          	jal	80002d20 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003d08:	4505                	li	a0,1
    80003d0a:	ed1ff0ef          	jal	80003bda <install_trans>
  log.lh.n = 0;
    80003d0e:	0001f797          	auipc	a5,0x1f
    80003d12:	9407ab23          	sw	zero,-1706(a5) # 80022664 <log+0x2c>
  write_head(); // clear the log
    80003d16:	e67ff0ef          	jal	80003b7c <write_head>
}
    80003d1a:	70a2                	ld	ra,40(sp)
    80003d1c:	7402                	ld	s0,32(sp)
    80003d1e:	64e2                	ld	s1,24(sp)
    80003d20:	6942                	ld	s2,16(sp)
    80003d22:	69a2                	ld	s3,8(sp)
    80003d24:	6145                	addi	sp,sp,48
    80003d26:	8082                	ret

0000000080003d28 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003d28:	1101                	addi	sp,sp,-32
    80003d2a:	ec06                	sd	ra,24(sp)
    80003d2c:	e822                	sd	s0,16(sp)
    80003d2e:	e426                	sd	s1,8(sp)
    80003d30:	e04a                	sd	s2,0(sp)
    80003d32:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003d34:	0001f517          	auipc	a0,0x1f
    80003d38:	90450513          	addi	a0,a0,-1788 # 80022638 <log>
    80003d3c:	eedfc0ef          	jal	80000c28 <acquire>
  while (1) {
    if (log.committing) {
    80003d40:	0001f497          	auipc	s1,0x1f
    80003d44:	8f848493          	addi	s1,s1,-1800 # 80022638 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003d48:	4979                	li	s2,30
    80003d4a:	a821                	j	80003d62 <begin_op+0x3a>
      sleep_prepare(&log);
    80003d4c:	8526                	mv	a0,s1
    80003d4e:	a08fe0ef          	jal	80001f56 <sleep_prepare>
      release(&log.lock);
    80003d52:	8526                	mv	a0,s1
    80003d54:	f5dfc0ef          	jal	80000cb0 <release>
      sleep();
    80003d58:	a3afe0ef          	jal	80001f92 <sleep>
      acquire(&log.lock);
    80003d5c:	8526                	mv	a0,s1
    80003d5e:	ecbfc0ef          	jal	80000c28 <acquire>
    if (log.committing) {
    80003d62:	509c                	lw	a5,32(s1)
    80003d64:	f7e5                	bnez	a5,80003d4c <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003d66:	4cd8                	lw	a4,28(s1)
    80003d68:	2705                	addiw	a4,a4,1
    80003d6a:	0027179b          	slliw	a5,a4,0x2
    80003d6e:	9fb9                	addw	a5,a5,a4
    80003d70:	0017979b          	slliw	a5,a5,0x1
    80003d74:	54d4                	lw	a3,44(s1)
    80003d76:	9fb5                	addw	a5,a5,a3
    80003d78:	00f95e63          	bge	s2,a5,80003d94 <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003d7c:	8526                	mv	a0,s1
    80003d7e:	9d8fe0ef          	jal	80001f56 <sleep_prepare>
      release(&log.lock);
    80003d82:	8526                	mv	a0,s1
    80003d84:	f2dfc0ef          	jal	80000cb0 <release>
      sleep();
    80003d88:	a0afe0ef          	jal	80001f92 <sleep>
      acquire(&log.lock);
    80003d8c:	8526                	mv	a0,s1
    80003d8e:	e9bfc0ef          	jal	80000c28 <acquire>
    80003d92:	bfc1                	j	80003d62 <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003d94:	0001f797          	auipc	a5,0x1f
    80003d98:	8ce7a023          	sw	a4,-1856(a5) # 80022654 <log+0x1c>
      release(&log.lock);
    80003d9c:	0001f517          	auipc	a0,0x1f
    80003da0:	89c50513          	addi	a0,a0,-1892 # 80022638 <log>
    80003da4:	f0dfc0ef          	jal	80000cb0 <release>
      break;
    }
  }
}
    80003da8:	60e2                	ld	ra,24(sp)
    80003daa:	6442                	ld	s0,16(sp)
    80003dac:	64a2                	ld	s1,8(sp)
    80003dae:	6902                	ld	s2,0(sp)
    80003db0:	6105                	addi	sp,sp,32
    80003db2:	8082                	ret

0000000080003db4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003db4:	7139                	addi	sp,sp,-64
    80003db6:	fc06                	sd	ra,56(sp)
    80003db8:	f822                	sd	s0,48(sp)
    80003dba:	f426                	sd	s1,40(sp)
    80003dbc:	f04a                	sd	s2,32(sp)
    80003dbe:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003dc0:	0001f497          	auipc	s1,0x1f
    80003dc4:	87848493          	addi	s1,s1,-1928 # 80022638 <log>
    80003dc8:	8526                	mv	a0,s1
    80003dca:	e5ffc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003dce:	4cdc                	lw	a5,28(s1)
    80003dd0:	37fd                	addiw	a5,a5,-1
    80003dd2:	893e                	mv	s2,a5
    80003dd4:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003dd6:	509c                	lw	a5,32(s1)
    80003dd8:	e3b1                	bnez	a5,80003e1c <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003dda:	04091a63          	bnez	s2,80003e2e <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    80003dde:	0001f497          	auipc	s1,0x1f
    80003de2:	85a48493          	addi	s1,s1,-1958 # 80022638 <log>
    80003de6:	4785                	li	a5,1
    80003de8:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003dea:	8526                	mv	a0,s1
    80003dec:	ec5fc0ef          	jal	80000cb0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003df0:	54dc                	lw	a5,44(s1)
    80003df2:	06f04063          	bgtz	a5,80003e52 <end_op+0x9e>
    acquire(&log.lock);
    80003df6:	0001f497          	auipc	s1,0x1f
    80003dfa:	84248493          	addi	s1,s1,-1982 # 80022638 <log>
    80003dfe:	8526                	mv	a0,s1
    80003e00:	e29fc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003e04:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003e08:	549c                	lw	a5,40(s1)
    80003e0a:	2785                	addiw	a5,a5,1
    80003e0c:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003e0e:	8526                	mv	a0,s1
    80003e10:	9b2fe0ef          	jal	80001fc2 <wakeup>
    release(&log.lock);
    80003e14:	8526                	mv	a0,s1
    80003e16:	e9bfc0ef          	jal	80000cb0 <release>
}
    80003e1a:	a035                	j	80003e46 <end_op+0x92>
    80003e1c:	ec4e                	sd	s3,24(sp)
    80003e1e:	e852                	sd	s4,16(sp)
    80003e20:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003e22:	00003517          	auipc	a0,0x3
    80003e26:	73e50513          	addi	a0,a0,1854 # 80007560 <etext+0x560>
    80003e2a:	a0bfc0ef          	jal	80000834 <panic>
    wakeup(&log);
    80003e2e:	0001f517          	auipc	a0,0x1f
    80003e32:	80a50513          	addi	a0,a0,-2038 # 80022638 <log>
    80003e36:	98cfe0ef          	jal	80001fc2 <wakeup>
  release(&log.lock);
    80003e3a:	0001e517          	auipc	a0,0x1e
    80003e3e:	7fe50513          	addi	a0,a0,2046 # 80022638 <log>
    80003e42:	e6ffc0ef          	jal	80000cb0 <release>
}
    80003e46:	70e2                	ld	ra,56(sp)
    80003e48:	7442                	ld	s0,48(sp)
    80003e4a:	74a2                	ld	s1,40(sp)
    80003e4c:	7902                	ld	s2,32(sp)
    80003e4e:	6121                	addi	sp,sp,64
    80003e50:	8082                	ret
    80003e52:	ec4e                	sd	s3,24(sp)
    80003e54:	e852                	sd	s4,16(sp)
    80003e56:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e58:	0001fa97          	auipc	s5,0x1f
    80003e5c:	810a8a93          	addi	s5,s5,-2032 # 80022668 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003e60:	0001ea17          	auipc	s4,0x1e
    80003e64:	7d8a0a13          	addi	s4,s4,2008 # 80022638 <log>
    80003e68:	018a2583          	lw	a1,24(s4)
    80003e6c:	012585bb          	addw	a1,a1,s2
    80003e70:	2585                	addiw	a1,a1,1
    80003e72:	024a2503          	lw	a0,36(s4)
    80003e76:	da3fe0ef          	jal	80002c18 <bread>
    80003e7a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003e7c:	000aa583          	lw	a1,0(s5)
    80003e80:	024a2503          	lw	a0,36(s4)
    80003e84:	d95fe0ef          	jal	80002c18 <bread>
    80003e88:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003e8a:	40000613          	li	a2,1024
    80003e8e:	05850593          	addi	a1,a0,88
    80003e92:	05848513          	addi	a0,s1,88
    80003e96:	eb3fc0ef          	jal	80000d48 <memmove>
    bwrite(to); // write the log
    80003e9a:	8526                	mv	a0,s1
    80003e9c:	e53fe0ef          	jal	80002cee <bwrite>
    brelse(from);
    80003ea0:	854e                	mv	a0,s3
    80003ea2:	e7ffe0ef          	jal	80002d20 <brelse>
    brelse(to);
    80003ea6:	8526                	mv	a0,s1
    80003ea8:	e79fe0ef          	jal	80002d20 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003eac:	2905                	addiw	s2,s2,1
    80003eae:	0a91                	addi	s5,s5,4
    80003eb0:	02ca2783          	lw	a5,44(s4)
    80003eb4:	faf94ae3          	blt	s2,a5,80003e68 <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80003eb8:	cc5ff0ef          	jal	80003b7c <write_head>
    install_trans(0); // Now install writes to home locations
    80003ebc:	4501                	li	a0,0
    80003ebe:	d1dff0ef          	jal	80003bda <install_trans>
    log.lh.n = 0;
    80003ec2:	0001e797          	auipc	a5,0x1e
    80003ec6:	7a07a123          	sw	zero,1954(a5) # 80022664 <log+0x2c>
    write_head(); // Erase the transaction from the log
    80003eca:	cb3ff0ef          	jal	80003b7c <write_head>
    80003ece:	69e2                	ld	s3,24(sp)
    80003ed0:	6a42                	ld	s4,16(sp)
    80003ed2:	6aa2                	ld	s5,8(sp)
    80003ed4:	b70d                	j	80003df6 <end_op+0x42>

0000000080003ed6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003ed6:	1101                	addi	sp,sp,-32
    80003ed8:	ec06                	sd	ra,24(sp)
    80003eda:	e822                	sd	s0,16(sp)
    80003edc:	e426                	sd	s1,8(sp)
    80003ede:	1000                	addi	s0,sp,32
    80003ee0:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003ee2:	0001e517          	auipc	a0,0x1e
    80003ee6:	75650513          	addi	a0,a0,1878 # 80022638 <log>
    80003eea:	d3ffc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003eee:	0001e617          	auipc	a2,0x1e
    80003ef2:	77662603          	lw	a2,1910(a2) # 80022664 <log+0x2c>
    80003ef6:	47f5                	li	a5,29
    80003ef8:	04c7cd63          	blt	a5,a2,80003f52 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003efc:	0001e797          	auipc	a5,0x1e
    80003f00:	7587a783          	lw	a5,1880(a5) # 80022654 <log+0x1c>
    80003f04:	04f05d63          	blez	a5,80003f5e <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003f08:	4781                	li	a5,0
    80003f0a:	06c05063          	blez	a2,80003f6a <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    80003f0e:	44cc                	lw	a1,12(s1)
    80003f10:	0001e717          	auipc	a4,0x1e
    80003f14:	75870713          	addi	a4,a4,1880 # 80022668 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003f18:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80003f1a:	4314                	lw	a3,0(a4)
    80003f1c:	04b68763          	beq	a3,a1,80003f6a <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80003f20:	2785                	addiw	a5,a5,1
    80003f22:	0711                	addi	a4,a4,4
    80003f24:	fef61be3          	bne	a2,a5,80003f1a <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003f28:	060a                	slli	a2,a2,0x2
    80003f2a:	02060613          	addi	a2,a2,32
    80003f2e:	0001e797          	auipc	a5,0x1e
    80003f32:	70a78793          	addi	a5,a5,1802 # 80022638 <log>
    80003f36:	97b2                	add	a5,a5,a2
    80003f38:	44d8                	lw	a4,12(s1)
    80003f3a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80003f3c:	8526                	mv	a0,s1
    80003f3e:	e67fe0ef          	jal	80002da4 <bpin>
    log.lh.n++;
    80003f42:	0001e717          	auipc	a4,0x1e
    80003f46:	6f670713          	addi	a4,a4,1782 # 80022638 <log>
    80003f4a:	575c                	lw	a5,44(a4)
    80003f4c:	2785                	addiw	a5,a5,1
    80003f4e:	d75c                	sw	a5,44(a4)
    80003f50:	a815                	j	80003f84 <log_write+0xae>
    panic("too big a transaction");
    80003f52:	00003517          	auipc	a0,0x3
    80003f56:	61e50513          	addi	a0,a0,1566 # 80007570 <etext+0x570>
    80003f5a:	8dbfc0ef          	jal	80000834 <panic>
    panic("log_write outside of trans");
    80003f5e:	00003517          	auipc	a0,0x3
    80003f62:	62a50513          	addi	a0,a0,1578 # 80007588 <etext+0x588>
    80003f66:	8cffc0ef          	jal	80000834 <panic>
  log.lh.block[i] = b->blockno;
    80003f6a:	00279693          	slli	a3,a5,0x2
    80003f6e:	02068693          	addi	a3,a3,32
    80003f72:	0001e717          	auipc	a4,0x1e
    80003f76:	6c670713          	addi	a4,a4,1734 # 80022638 <log>
    80003f7a:	9736                	add	a4,a4,a3
    80003f7c:	44d4                	lw	a3,12(s1)
    80003f7e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    80003f80:	faf60ee3          	beq	a2,a5,80003f3c <log_write+0x66>
  }
  release(&log.lock);
    80003f84:	0001e517          	auipc	a0,0x1e
    80003f88:	6b450513          	addi	a0,a0,1716 # 80022638 <log>
    80003f8c:	d25fc0ef          	jal	80000cb0 <release>
}
    80003f90:	60e2                	ld	ra,24(sp)
    80003f92:	6442                	ld	s0,16(sp)
    80003f94:	64a2                	ld	s1,8(sp)
    80003f96:	6105                	addi	sp,sp,32
    80003f98:	8082                	ret

0000000080003f9a <sys_sync>:

uint64
sys_sync(void)
{
    80003f9a:	1101                	addi	sp,sp,-32
    80003f9c:	ec06                	sd	ra,24(sp)
    80003f9e:	e822                	sd	s0,16(sp)
    80003fa0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003fa2:	0001e517          	auipc	a0,0x1e
    80003fa6:	69650513          	addi	a0,a0,1686 # 80022638 <log>
    80003faa:	c7ffc0ef          	jal	80000c28 <acquire>
  if (log.committing || log.outstanding > 0) {
    80003fae:	0001e797          	auipc	a5,0x1e
    80003fb2:	6aa7a783          	lw	a5,1706(a5) # 80022658 <log+0x20>
    80003fb6:	e799                	bnez	a5,80003fc4 <sys_sync+0x2a>
    80003fb8:	0001e797          	auipc	a5,0x1e
    80003fbc:	69c7a783          	lw	a5,1692(a5) # 80022654 <log+0x1c>
    80003fc0:	02f05c63          	blez	a5,80003ff8 <sys_sync+0x5e>
    80003fc4:	e426                	sd	s1,8(sp)
    80003fc6:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    80003fc8:	0001e917          	auipc	s2,0x1e
    80003fcc:	69892903          	lw	s2,1688(s2) # 80022660 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    80003fd0:	0001e497          	auipc	s1,0x1e
    80003fd4:	66848493          	addi	s1,s1,1640 # 80022638 <log>
    80003fd8:	8526                	mv	a0,s1
    80003fda:	f7dfd0ef          	jal	80001f56 <sleep_prepare>
      release(&log.lock);
    80003fde:	8526                	mv	a0,s1
    80003fe0:	cd1fc0ef          	jal	80000cb0 <release>
      sleep();
    80003fe4:	faffd0ef          	jal	80001f92 <sleep>
      acquire(&log.lock);
    80003fe8:	8526                	mv	a0,s1
    80003fea:	c3ffc0ef          	jal	80000c28 <acquire>
    while (log.ncommit < n) {
    80003fee:	549c                	lw	a5,40(s1)
    80003ff0:	fef954e3          	bge	s2,a5,80003fd8 <sys_sync+0x3e>
    80003ff4:	64a2                	ld	s1,8(sp)
    80003ff6:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    80003ff8:	0001e517          	auipc	a0,0x1e
    80003ffc:	64050513          	addi	a0,a0,1600 # 80022638 <log>
    80004000:	cb1fc0ef          	jal	80000cb0 <release>
  return 0;
}
    80004004:	4501                	li	a0,0
    80004006:	60e2                	ld	ra,24(sp)
    80004008:	6442                	ld	s0,16(sp)
    8000400a:	6105                	addi	sp,sp,32
    8000400c:	8082                	ret

000000008000400e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000400e:	1101                	addi	sp,sp,-32
    80004010:	ec06                	sd	ra,24(sp)
    80004012:	e822                	sd	s0,16(sp)
    80004014:	e426                	sd	s1,8(sp)
    80004016:	e04a                	sd	s2,0(sp)
    80004018:	1000                	addi	s0,sp,32
    8000401a:	84aa                	mv	s1,a0
    8000401c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000401e:	00003597          	auipc	a1,0x3
    80004022:	58a58593          	addi	a1,a1,1418 # 800075a8 <etext+0x5a8>
    80004026:	0521                	addi	a0,a0,8
    80004028:	b81fc0ef          	jal	80000ba8 <initlock>
  lk->name = name;
    8000402c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004030:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004034:	0204a423          	sw	zero,40(s1)
}
    80004038:	60e2                	ld	ra,24(sp)
    8000403a:	6442                	ld	s0,16(sp)
    8000403c:	64a2                	ld	s1,8(sp)
    8000403e:	6902                	ld	s2,0(sp)
    80004040:	6105                	addi	sp,sp,32
    80004042:	8082                	ret

0000000080004044 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004044:	1101                	addi	sp,sp,-32
    80004046:	ec06                	sd	ra,24(sp)
    80004048:	e822                	sd	s0,16(sp)
    8000404a:	e426                	sd	s1,8(sp)
    8000404c:	e04a                	sd	s2,0(sp)
    8000404e:	1000                	addi	s0,sp,32
    80004050:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004052:	00850913          	addi	s2,a0,8
    80004056:	854a                	mv	a0,s2
    80004058:	bd1fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    8000405c:	409c                	lw	a5,0(s1)
    8000405e:	cf91                	beqz	a5,8000407a <acquiresleep+0x36>
    sleep_prepare(lk);
    80004060:	8526                	mv	a0,s1
    80004062:	ef5fd0ef          	jal	80001f56 <sleep_prepare>
    release(&lk->lk);
    80004066:	854a                	mv	a0,s2
    80004068:	c49fc0ef          	jal	80000cb0 <release>
    sleep();
    8000406c:	f27fd0ef          	jal	80001f92 <sleep>
    acquire(&lk->lk);
    80004070:	854a                	mv	a0,s2
    80004072:	bb7fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80004076:	409c                	lw	a5,0(s1)
    80004078:	f7e5                	bnez	a5,80004060 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000407a:	4785                	li	a5,1
    8000407c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000407e:	8cbfd0ef          	jal	80001948 <myproc>
    80004082:	591c                	lw	a5,48(a0)
    80004084:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004086:	854a                	mv	a0,s2
    80004088:	c29fc0ef          	jal	80000cb0 <release>
}
    8000408c:	60e2                	ld	ra,24(sp)
    8000408e:	6442                	ld	s0,16(sp)
    80004090:	64a2                	ld	s1,8(sp)
    80004092:	6902                	ld	s2,0(sp)
    80004094:	6105                	addi	sp,sp,32
    80004096:	8082                	ret

0000000080004098 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004098:	1101                	addi	sp,sp,-32
    8000409a:	ec06                	sd	ra,24(sp)
    8000409c:	e822                	sd	s0,16(sp)
    8000409e:	e426                	sd	s1,8(sp)
    800040a0:	e04a                	sd	s2,0(sp)
    800040a2:	1000                	addi	s0,sp,32
    800040a4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800040a6:	00850913          	addi	s2,a0,8
    800040aa:	854a                	mv	a0,s2
    800040ac:	b7dfc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    800040b0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800040b4:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800040b8:	8526                	mv	a0,s1
    800040ba:	f09fd0ef          	jal	80001fc2 <wakeup>
  release(&lk->lk);
    800040be:	854a                	mv	a0,s2
    800040c0:	bf1fc0ef          	jal	80000cb0 <release>
}
    800040c4:	60e2                	ld	ra,24(sp)
    800040c6:	6442                	ld	s0,16(sp)
    800040c8:	64a2                	ld	s1,8(sp)
    800040ca:	6902                	ld	s2,0(sp)
    800040cc:	6105                	addi	sp,sp,32
    800040ce:	8082                	ret

00000000800040d0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800040d0:	7179                	addi	sp,sp,-48
    800040d2:	f406                	sd	ra,40(sp)
    800040d4:	f022                	sd	s0,32(sp)
    800040d6:	ec26                	sd	s1,24(sp)
    800040d8:	e84a                	sd	s2,16(sp)
    800040da:	1800                	addi	s0,sp,48
    800040dc:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    800040de:	00850913          	addi	s2,a0,8
    800040e2:	854a                	mv	a0,s2
    800040e4:	b45fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800040e8:	409c                	lw	a5,0(s1)
    800040ea:	ef81                	bnez	a5,80004102 <holdingsleep+0x32>
    800040ec:	4481                	li	s1,0
  release(&lk->lk);
    800040ee:	854a                	mv	a0,s2
    800040f0:	bc1fc0ef          	jal	80000cb0 <release>
  return r;
}
    800040f4:	8526                	mv	a0,s1
    800040f6:	70a2                	ld	ra,40(sp)
    800040f8:	7402                	ld	s0,32(sp)
    800040fa:	64e2                	ld	s1,24(sp)
    800040fc:	6942                	ld	s2,16(sp)
    800040fe:	6145                	addi	sp,sp,48
    80004100:	8082                	ret
    80004102:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004104:	0284a983          	lw	s3,40(s1)
    80004108:	841fd0ef          	jal	80001948 <myproc>
    8000410c:	5904                	lw	s1,48(a0)
    8000410e:	413484b3          	sub	s1,s1,s3
    80004112:	0014b493          	seqz	s1,s1
    80004116:	69a2                	ld	s3,8(sp)
    80004118:	bfd9                	j	800040ee <holdingsleep+0x1e>

000000008000411a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000411a:	1141                	addi	sp,sp,-16
    8000411c:	e406                	sd	ra,8(sp)
    8000411e:	e022                	sd	s0,0(sp)
    80004120:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004122:	00003597          	auipc	a1,0x3
    80004126:	49658593          	addi	a1,a1,1174 # 800075b8 <etext+0x5b8>
    8000412a:	0001e517          	auipc	a0,0x1e
    8000412e:	65650513          	addi	a0,a0,1622 # 80022780 <ftable>
    80004132:	a77fc0ef          	jal	80000ba8 <initlock>
}
    80004136:	60a2                	ld	ra,8(sp)
    80004138:	6402                	ld	s0,0(sp)
    8000413a:	0141                	addi	sp,sp,16
    8000413c:	8082                	ret

000000008000413e <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    8000413e:	1101                	addi	sp,sp,-32
    80004140:	ec06                	sd	ra,24(sp)
    80004142:	e822                	sd	s0,16(sp)
    80004144:	e426                	sd	s1,8(sp)
    80004146:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004148:	0001e517          	auipc	a0,0x1e
    8000414c:	63850513          	addi	a0,a0,1592 # 80022780 <ftable>
    80004150:	ad9fc0ef          	jal	80000c28 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004154:	0001e497          	auipc	s1,0x1e
    80004158:	64448493          	addi	s1,s1,1604 # 80022798 <ftable+0x18>
    8000415c:	0001f717          	auipc	a4,0x1f
    80004160:	5dc70713          	addi	a4,a4,1500 # 80023738 <disk>
    if (f->ref == 0) {
    80004164:	40dc                	lw	a5,4(s1)
    80004166:	cf89                	beqz	a5,80004180 <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004168:	02848493          	addi	s1,s1,40
    8000416c:	fee49ce3          	bne	s1,a4,80004164 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004170:	0001e517          	auipc	a0,0x1e
    80004174:	61050513          	addi	a0,a0,1552 # 80022780 <ftable>
    80004178:	b39fc0ef          	jal	80000cb0 <release>
  return 0;
    8000417c:	4481                	li	s1,0
    8000417e:	a809                	j	80004190 <filealloc+0x52>
      f->ref = 1;
    80004180:	4785                	li	a5,1
    80004182:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004184:	0001e517          	auipc	a0,0x1e
    80004188:	5fc50513          	addi	a0,a0,1532 # 80022780 <ftable>
    8000418c:	b25fc0ef          	jal	80000cb0 <release>
}
    80004190:	8526                	mv	a0,s1
    80004192:	60e2                	ld	ra,24(sp)
    80004194:	6442                	ld	s0,16(sp)
    80004196:	64a2                	ld	s1,8(sp)
    80004198:	6105                	addi	sp,sp,32
    8000419a:	8082                	ret

000000008000419c <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    8000419c:	1101                	addi	sp,sp,-32
    8000419e:	ec06                	sd	ra,24(sp)
    800041a0:	e822                	sd	s0,16(sp)
    800041a2:	e426                	sd	s1,8(sp)
    800041a4:	1000                	addi	s0,sp,32
    800041a6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800041a8:	0001e517          	auipc	a0,0x1e
    800041ac:	5d850513          	addi	a0,a0,1496 # 80022780 <ftable>
    800041b0:	a79fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    800041b4:	40dc                	lw	a5,4(s1)
    800041b6:	02f05063          	blez	a5,800041d6 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800041ba:	2785                	addiw	a5,a5,1
    800041bc:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800041be:	0001e517          	auipc	a0,0x1e
    800041c2:	5c250513          	addi	a0,a0,1474 # 80022780 <ftable>
    800041c6:	aebfc0ef          	jal	80000cb0 <release>
  return f;
}
    800041ca:	8526                	mv	a0,s1
    800041cc:	60e2                	ld	ra,24(sp)
    800041ce:	6442                	ld	s0,16(sp)
    800041d0:	64a2                	ld	s1,8(sp)
    800041d2:	6105                	addi	sp,sp,32
    800041d4:	8082                	ret
    panic("filedup");
    800041d6:	00003517          	auipc	a0,0x3
    800041da:	3ea50513          	addi	a0,a0,1002 # 800075c0 <etext+0x5c0>
    800041de:	e56fc0ef          	jal	80000834 <panic>

00000000800041e2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800041e2:	7139                	addi	sp,sp,-64
    800041e4:	fc06                	sd	ra,56(sp)
    800041e6:	f822                	sd	s0,48(sp)
    800041e8:	f426                	sd	s1,40(sp)
    800041ea:	0080                	addi	s0,sp,64
    800041ec:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800041ee:	0001e517          	auipc	a0,0x1e
    800041f2:	59250513          	addi	a0,a0,1426 # 80022780 <ftable>
    800041f6:	a33fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    800041fa:	40dc                	lw	a5,4(s1)
    800041fc:	04f05a63          	blez	a5,80004250 <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    80004200:	37fd                	addiw	a5,a5,-1
    80004202:	c0dc                	sw	a5,4(s1)
    80004204:	06f04063          	bgtz	a5,80004264 <fileclose+0x82>
    80004208:	f04a                	sd	s2,32(sp)
    8000420a:	ec4e                	sd	s3,24(sp)
    8000420c:	e852                	sd	s4,16(sp)
    8000420e:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004210:	0004a903          	lw	s2,0(s1)
    80004214:	0094c783          	lbu	a5,9(s1)
    80004218:	89be                	mv	s3,a5
    8000421a:	689c                	ld	a5,16(s1)
    8000421c:	8a3e                	mv	s4,a5
    8000421e:	6c9c                	ld	a5,24(s1)
    80004220:	8abe                	mv	s5,a5
  f->ref = 0;
    80004222:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004226:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000422a:	0001e517          	auipc	a0,0x1e
    8000422e:	55650513          	addi	a0,a0,1366 # 80022780 <ftable>
    80004232:	a7ffc0ef          	jal	80000cb0 <release>

  if (ff.type == FD_PIPE) {
    80004236:	4785                	li	a5,1
    80004238:	04f90163          	beq	s2,a5,8000427a <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    8000423c:	ffe9079b          	addiw	a5,s2,-2
    80004240:	4705                	li	a4,1
    80004242:	04f77563          	bgeu	a4,a5,8000428c <fileclose+0xaa>
    80004246:	7902                	ld	s2,32(sp)
    80004248:	69e2                	ld	s3,24(sp)
    8000424a:	6a42                	ld	s4,16(sp)
    8000424c:	6aa2                	ld	s5,8(sp)
    8000424e:	a00d                	j	80004270 <fileclose+0x8e>
    80004250:	f04a                	sd	s2,32(sp)
    80004252:	ec4e                	sd	s3,24(sp)
    80004254:	e852                	sd	s4,16(sp)
    80004256:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004258:	00003517          	auipc	a0,0x3
    8000425c:	37050513          	addi	a0,a0,880 # 800075c8 <etext+0x5c8>
    80004260:	dd4fc0ef          	jal	80000834 <panic>
    release(&ftable.lock);
    80004264:	0001e517          	auipc	a0,0x1e
    80004268:	51c50513          	addi	a0,a0,1308 # 80022780 <ftable>
    8000426c:	a45fc0ef          	jal	80000cb0 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004270:	70e2                	ld	ra,56(sp)
    80004272:	7442                	ld	s0,48(sp)
    80004274:	74a2                	ld	s1,40(sp)
    80004276:	6121                	addi	sp,sp,64
    80004278:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000427a:	85ce                	mv	a1,s3
    8000427c:	8552                	mv	a0,s4
    8000427e:	36a000ef          	jal	800045e8 <pipeclose>
    80004282:	7902                	ld	s2,32(sp)
    80004284:	69e2                	ld	s3,24(sp)
    80004286:	6a42                	ld	s4,16(sp)
    80004288:	6aa2                	ld	s5,8(sp)
    8000428a:	b7dd                	j	80004270 <fileclose+0x8e>
    begin_op();
    8000428c:	a9dff0ef          	jal	80003d28 <begin_op>
    iput(ff.ip);
    80004290:	8556                	mv	a0,s5
    80004292:	9a0ff0ef          	jal	80003432 <iput>
    end_op();
    80004296:	b1fff0ef          	jal	80003db4 <end_op>
    8000429a:	7902                	ld	s2,32(sp)
    8000429c:	69e2                	ld	s3,24(sp)
    8000429e:	6a42                	ld	s4,16(sp)
    800042a0:	6aa2                	ld	s5,8(sp)
    800042a2:	b7f9                	j	80004270 <fileclose+0x8e>

00000000800042a4 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800042a4:	715d                	addi	sp,sp,-80
    800042a6:	e486                	sd	ra,72(sp)
    800042a8:	e0a2                	sd	s0,64(sp)
    800042aa:	fc26                	sd	s1,56(sp)
    800042ac:	f052                	sd	s4,32(sp)
    800042ae:	0880                	addi	s0,sp,80
    800042b0:	84aa                	mv	s1,a0
    800042b2:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    800042b4:	e94fd0ef          	jal	80001948 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    800042b8:	409c                	lw	a5,0(s1)
    800042ba:	37f9                	addiw	a5,a5,-2
    800042bc:	4705                	li	a4,1
    800042be:	04f76963          	bltu	a4,a5,80004310 <filestat+0x6c>
    800042c2:	f84a                	sd	s2,48(sp)
    800042c4:	f44e                	sd	s3,40(sp)
    800042c6:	892a                	mv	s2,a0
    memset(&st, 0, sizeof(st));
    800042c8:	fb840993          	addi	s3,s0,-72
    800042cc:	4661                	li	a2,24
    800042ce:	4581                	li	a1,0
    800042d0:	854e                	mv	a0,s3
    800042d2:	a17fc0ef          	jal	80000ce8 <memset>
    ilock(f->ip);
    800042d6:	6c88                	ld	a0,24(s1)
    800042d8:	fd9fe0ef          	jal	800032b0 <ilock>
    stati(f->ip, &st);
    800042dc:	85ce                	mv	a1,s3
    800042de:	6c88                	ld	a0,24(s1)
    800042e0:	b7cff0ef          	jal	8000365c <stati>
    iunlock(f->ip);
    800042e4:	6c88                	ld	a0,24(s1)
    800042e6:	878ff0ef          	jal	8000335e <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    800042ea:	4761                	li	a4,24
    800042ec:	86ce                	mv	a3,s3
    800042ee:	8652                	mv	a2,s4
    800042f0:	04893583          	ld	a1,72(s2)
    800042f4:	05093503          	ld	a0,80(s2)
    800042f8:	a8afd0ef          	jal	80001582 <copyout>
    800042fc:	41f5551b          	sraiw	a0,a0,0x1f
    80004300:	7942                	ld	s2,48(sp)
    80004302:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004304:	60a6                	ld	ra,72(sp)
    80004306:	6406                	ld	s0,64(sp)
    80004308:	74e2                	ld	s1,56(sp)
    8000430a:	7a02                	ld	s4,32(sp)
    8000430c:	6161                	addi	sp,sp,80
    8000430e:	8082                	ret
  return -1;
    80004310:	557d                	li	a0,-1
    80004312:	bfcd                	j	80004304 <filestat+0x60>

0000000080004314 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004314:	7179                	addi	sp,sp,-48
    80004316:	f406                	sd	ra,40(sp)
    80004318:	f022                	sd	s0,32(sp)
    8000431a:	e84a                	sd	s2,16(sp)
    8000431c:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    8000431e:	00854783          	lbu	a5,8(a0)
    80004322:	c3dd                	beqz	a5,800043c8 <fileread+0xb4>
    80004324:	ec26                	sd	s1,24(sp)
    80004326:	e44e                	sd	s3,8(sp)
    80004328:	84aa                	mv	s1,a0
    8000432a:	892e                	mv	s2,a1
    8000432c:	89b2                	mv	s3,a2
    8000432e:	01f6579b          	srliw	a5,a2,0x1f
    80004332:	ebc9                	bnez	a5,800043c4 <fileread+0xb0>
    return -1;

  if (f->type == FD_PIPE) {
    80004334:	411c                	lw	a5,0(a0)
    80004336:	4705                	li	a4,1
    80004338:	04e78363          	beq	a5,a4,8000437e <fileread+0x6a>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    8000433c:	470d                	li	a4,3
    8000433e:	04e78763          	beq	a5,a4,8000438c <fileread+0x78>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004342:	4709                	li	a4,2
    80004344:	06e79a63          	bne	a5,a4,800043b8 <fileread+0xa4>
    ilock(f->ip);
    80004348:	6d08                	ld	a0,24(a0)
    8000434a:	f67fe0ef          	jal	800032b0 <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000434e:	874e                	mv	a4,s3
    80004350:	5094                	lw	a3,32(s1)
    80004352:	864a                	mv	a2,s2
    80004354:	4585                	li	a1,1
    80004356:	6c88                	ld	a0,24(s1)
    80004358:	b32ff0ef          	jal	8000368a <readi>
    8000435c:	892a                	mv	s2,a0
    8000435e:	00a05563          	blez	a0,80004368 <fileread+0x54>
      f->off += r;
    80004362:	509c                	lw	a5,32(s1)
    80004364:	9fa9                	addw	a5,a5,a0
    80004366:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004368:	6c88                	ld	a0,24(s1)
    8000436a:	ff5fe0ef          	jal	8000335e <iunlock>
    8000436e:	64e2                	ld	s1,24(sp)
    80004370:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004372:	854a                	mv	a0,s2
    80004374:	70a2                	ld	ra,40(sp)
    80004376:	7402                	ld	s0,32(sp)
    80004378:	6942                	ld	s2,16(sp)
    8000437a:	6145                	addi	sp,sp,48
    8000437c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000437e:	6908                	ld	a0,16(a0)
    80004380:	3e2000ef          	jal	80004762 <piperead>
    80004384:	892a                	mv	s2,a0
    80004386:	64e2                	ld	s1,24(sp)
    80004388:	69a2                	ld	s3,8(sp)
    8000438a:	b7e5                	j	80004372 <fileread+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000438c:	02451783          	lh	a5,36(a0)
    80004390:	03079693          	slli	a3,a5,0x30
    80004394:	92c1                	srli	a3,a3,0x30
    80004396:	4725                	li	a4,9
    80004398:	02d76b63          	bltu	a4,a3,800043ce <fileread+0xba>
    8000439c:	0792                	slli	a5,a5,0x4
    8000439e:	0001e717          	auipc	a4,0x1e
    800043a2:	34270713          	addi	a4,a4,834 # 800226e0 <devsw>
    800043a6:	97ba                	add	a5,a5,a4
    800043a8:	639c                	ld	a5,0(a5)
    800043aa:	c79d                	beqz	a5,800043d8 <fileread+0xc4>
    r = devsw[f->major].read(1, addr, n);
    800043ac:	4505                	li	a0,1
    800043ae:	9782                	jalr	a5
    800043b0:	892a                	mv	s2,a0
    800043b2:	64e2                	ld	s1,24(sp)
    800043b4:	69a2                	ld	s3,8(sp)
    800043b6:	bf75                	j	80004372 <fileread+0x5e>
    panic("fileread");
    800043b8:	00003517          	auipc	a0,0x3
    800043bc:	22050513          	addi	a0,a0,544 # 800075d8 <etext+0x5d8>
    800043c0:	c74fc0ef          	jal	80000834 <panic>
    800043c4:	64e2                	ld	s1,24(sp)
    800043c6:	69a2                	ld	s3,8(sp)
    return -1;
    800043c8:	57fd                	li	a5,-1
    800043ca:	893e                	mv	s2,a5
    800043cc:	b75d                	j	80004372 <fileread+0x5e>
      return -1;
    800043ce:	57fd                	li	a5,-1
    800043d0:	893e                	mv	s2,a5
    800043d2:	64e2                	ld	s1,24(sp)
    800043d4:	69a2                	ld	s3,8(sp)
    800043d6:	bf71                	j	80004372 <fileread+0x5e>
    800043d8:	57fd                	li	a5,-1
    800043da:	893e                	mv	s2,a5
    800043dc:	64e2                	ld	s1,24(sp)
    800043de:	69a2                	ld	s3,8(sp)
    800043e0:	bf49                	j	80004372 <fileread+0x5e>

00000000800043e2 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    800043e2:	00954783          	lbu	a5,9(a0)
    800043e6:	12078b63          	beqz	a5,8000451c <filewrite+0x13a>
{
    800043ea:	711d                	addi	sp,sp,-96
    800043ec:	ec86                	sd	ra,88(sp)
    800043ee:	e8a2                	sd	s0,80(sp)
    800043f0:	e0ca                	sd	s2,64(sp)
    800043f2:	f456                	sd	s5,40(sp)
    800043f4:	f05a                	sd	s6,32(sp)
    800043f6:	1080                	addi	s0,sp,96
    800043f8:	892a                	mv	s2,a0
    800043fa:	8b2e                	mv	s6,a1
    800043fc:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    800043fe:	01f6579b          	srliw	a5,a2,0x1f
    80004402:	0e079d63          	bnez	a5,800044fc <filewrite+0x11a>
    return -1;

  if (f->type == FD_PIPE) {
    80004406:	411c                	lw	a5,0(a0)
    80004408:	4705                	li	a4,1
    8000440a:	02e78a63          	beq	a5,a4,8000443e <filewrite+0x5c>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    8000440e:	470d                	li	a4,3
    80004410:	02e78b63          	beq	a5,a4,80004446 <filewrite+0x64>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004414:	4709                	li	a4,2
    80004416:	0ce79763          	bne	a5,a4,800044e4 <filewrite+0x102>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    8000441a:	0ec05763          	blez	a2,80004508 <filewrite+0x126>
    8000441e:	e4a6                	sd	s1,72(sp)
    80004420:	fc4e                	sd	s3,56(sp)
    80004422:	f852                	sd	s4,48(sp)
    80004424:	ec5e                	sd	s7,24(sp)
    80004426:	e862                	sd	s8,16(sp)
    80004428:	e466                	sd	s9,8(sp)
    int i = 0;
    8000442a:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    8000442c:	6b85                	lui	s7,0x1
    8000442e:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004432:	6785                	lui	a5,0x1
    80004434:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004438:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000443a:	4c05                	li	s8,1
    8000443c:	a8ad                	j	800044b6 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    8000443e:	6908                	ld	a0,16(a0)
    80004440:	206000ef          	jal	80004646 <pipewrite>
    80004444:	a849                	j	800044d6 <filewrite+0xf4>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004446:	02451783          	lh	a5,36(a0)
    8000444a:	03079693          	slli	a3,a5,0x30
    8000444e:	92c1                	srli	a3,a3,0x30
    80004450:	4725                	li	a4,9
    80004452:	0ad76763          	bltu	a4,a3,80004500 <filewrite+0x11e>
    80004456:	0792                	slli	a5,a5,0x4
    80004458:	0001e717          	auipc	a4,0x1e
    8000445c:	28870713          	addi	a4,a4,648 # 800226e0 <devsw>
    80004460:	97ba                	add	a5,a5,a4
    80004462:	679c                	ld	a5,8(a5)
    80004464:	c3c5                	beqz	a5,80004504 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004466:	4505                	li	a0,1
    80004468:	9782                	jalr	a5
    8000446a:	a0b5                	j	800044d6 <filewrite+0xf4>
      if (n1 > max)
    8000446c:	2981                	sext.w	s3,s3
      begin_op();
    8000446e:	8bbff0ef          	jal	80003d28 <begin_op>
      ilock(f->ip);
    80004472:	01893503          	ld	a0,24(s2)
    80004476:	e3bfe0ef          	jal	800032b0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000447a:	874e                	mv	a4,s3
    8000447c:	02092683          	lw	a3,32(s2)
    80004480:	016a0633          	add	a2,s4,s6
    80004484:	85e2                	mv	a1,s8
    80004486:	01893503          	ld	a0,24(s2)
    8000448a:	af2ff0ef          	jal	8000377c <writei>
    8000448e:	84aa                	mv	s1,a0
    80004490:	00a05763          	blez	a0,8000449e <filewrite+0xbc>
        f->off += r;
    80004494:	02092783          	lw	a5,32(s2)
    80004498:	9fa9                	addw	a5,a5,a0
    8000449a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000449e:	01893503          	ld	a0,24(s2)
    800044a2:	ebdfe0ef          	jal	8000335e <iunlock>
      end_op();
    800044a6:	90fff0ef          	jal	80003db4 <end_op>

      if (r != n1) {
    800044aa:	00999d63          	bne	s3,s1,800044c4 <filewrite+0xe2>
        // error from writei
        break;
      }
      i += r;
    800044ae:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    800044b2:	015a5963          	bge	s4,s5,800044c4 <filewrite+0xe2>
      int n1 = n - i;
    800044b6:	414a87bb          	subw	a5,s5,s4
    800044ba:	89be                	mv	s3,a5
      if (n1 > max)
    800044bc:	fafbd8e3          	bge	s7,a5,8000446c <filewrite+0x8a>
    800044c0:	89e6                	mv	s3,s9
    800044c2:	b76d                	j	8000446c <filewrite+0x8a>
    }
    ret = (i == n ? n : -1);
    800044c4:	054a9463          	bne	s5,s4,8000450c <filewrite+0x12a>
    800044c8:	8556                	mv	a0,s5
    800044ca:	64a6                	ld	s1,72(sp)
    800044cc:	79e2                	ld	s3,56(sp)
    800044ce:	7a42                	ld	s4,48(sp)
    800044d0:	6be2                	ld	s7,24(sp)
    800044d2:	6c42                	ld	s8,16(sp)
    800044d4:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800044d6:	60e6                	ld	ra,88(sp)
    800044d8:	6446                	ld	s0,80(sp)
    800044da:	6906                	ld	s2,64(sp)
    800044dc:	7aa2                	ld	s5,40(sp)
    800044de:	7b02                	ld	s6,32(sp)
    800044e0:	6125                	addi	sp,sp,96
    800044e2:	8082                	ret
    800044e4:	e4a6                	sd	s1,72(sp)
    800044e6:	fc4e                	sd	s3,56(sp)
    800044e8:	f852                	sd	s4,48(sp)
    800044ea:	ec5e                	sd	s7,24(sp)
    800044ec:	e862                	sd	s8,16(sp)
    800044ee:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800044f0:	00003517          	auipc	a0,0x3
    800044f4:	0f850513          	addi	a0,a0,248 # 800075e8 <etext+0x5e8>
    800044f8:	b3cfc0ef          	jal	80000834 <panic>
    return -1;
    800044fc:	557d                	li	a0,-1
    800044fe:	bfe1                	j	800044d6 <filewrite+0xf4>
      return -1;
    80004500:	557d                	li	a0,-1
    80004502:	bfd1                	j	800044d6 <filewrite+0xf4>
    80004504:	557d                	li	a0,-1
    80004506:	bfc1                	j	800044d6 <filewrite+0xf4>
    ret = (i == n ? n : -1);
    80004508:	8532                	mv	a0,a2
    8000450a:	b7f1                	j	800044d6 <filewrite+0xf4>
    8000450c:	557d                	li	a0,-1
    8000450e:	64a6                	ld	s1,72(sp)
    80004510:	79e2                	ld	s3,56(sp)
    80004512:	7a42                	ld	s4,48(sp)
    80004514:	6be2                	ld	s7,24(sp)
    80004516:	6c42                	ld	s8,16(sp)
    80004518:	6ca2                	ld	s9,8(sp)
    8000451a:	bf75                	j	800044d6 <filewrite+0xf4>
    return -1;
    8000451c:	557d                	li	a0,-1
}
    8000451e:	8082                	ret

0000000080004520 <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004520:	7179                	addi	sp,sp,-48
    80004522:	f406                	sd	ra,40(sp)
    80004524:	f022                	sd	s0,32(sp)
    80004526:	ec26                	sd	s1,24(sp)
    80004528:	e052                	sd	s4,0(sp)
    8000452a:	1800                	addi	s0,sp,48
    8000452c:	84aa                	mv	s1,a0
    8000452e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004530:	0005b023          	sd	zero,0(a1)
    80004534:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004538:	c07ff0ef          	jal	8000413e <filealloc>
    8000453c:	e088                	sd	a0,0(s1)
    8000453e:	c549                	beqz	a0,800045c8 <pipealloc+0xa8>
    80004540:	bffff0ef          	jal	8000413e <filealloc>
    80004544:	00aa3023          	sd	a0,0(s4)
    80004548:	cd25                	beqz	a0,800045c0 <pipealloc+0xa0>
    8000454a:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    8000454c:	e02fc0ef          	jal	80000b4e <kalloc>
    80004550:	892a                	mv	s2,a0
    80004552:	c12d                	beqz	a0,800045b4 <pipealloc+0x94>
    80004554:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004556:	4985                	li	s3,1
    80004558:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000455c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004560:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004564:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004568:	00003597          	auipc	a1,0x3
    8000456c:	09058593          	addi	a1,a1,144 # 800075f8 <etext+0x5f8>
    80004570:	e38fc0ef          	jal	80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    80004574:	609c                	ld	a5,0(s1)
    80004576:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000457a:	609c                	ld	a5,0(s1)
    8000457c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004580:	609c                	ld	a5,0(s1)
    80004582:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004586:	609c                	ld	a5,0(s1)
    80004588:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000458c:	000a3783          	ld	a5,0(s4)
    80004590:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004594:	000a3783          	ld	a5,0(s4)
    80004598:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000459c:	000a3783          	ld	a5,0(s4)
    800045a0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800045a4:	000a3783          	ld	a5,0(s4)
    800045a8:	0127b823          	sd	s2,16(a5)
  return 0;
    800045ac:	4501                	li	a0,0
    800045ae:	6942                	ld	s2,16(sp)
    800045b0:	69a2                	ld	s3,8(sp)
    800045b2:	a01d                	j	800045d8 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    800045b4:	6088                	ld	a0,0(s1)
    800045b6:	c119                	beqz	a0,800045bc <pipealloc+0x9c>
    800045b8:	6942                	ld	s2,16(sp)
    800045ba:	a029                	j	800045c4 <pipealloc+0xa4>
    800045bc:	6942                	ld	s2,16(sp)
    800045be:	a029                	j	800045c8 <pipealloc+0xa8>
    800045c0:	6088                	ld	a0,0(s1)
    800045c2:	c10d                	beqz	a0,800045e4 <pipealloc+0xc4>
    fileclose(*f0);
    800045c4:	c1fff0ef          	jal	800041e2 <fileclose>
  if (*f1)
    800045c8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800045cc:	557d                	li	a0,-1
  if (*f1)
    800045ce:	c789                	beqz	a5,800045d8 <pipealloc+0xb8>
    fileclose(*f1);
    800045d0:	853e                	mv	a0,a5
    800045d2:	c11ff0ef          	jal	800041e2 <fileclose>
  return -1;
    800045d6:	557d                	li	a0,-1
}
    800045d8:	70a2                	ld	ra,40(sp)
    800045da:	7402                	ld	s0,32(sp)
    800045dc:	64e2                	ld	s1,24(sp)
    800045de:	6a02                	ld	s4,0(sp)
    800045e0:	6145                	addi	sp,sp,48
    800045e2:	8082                	ret
  return -1;
    800045e4:	557d                	li	a0,-1
    800045e6:	bfcd                	j	800045d8 <pipealloc+0xb8>

00000000800045e8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800045e8:	1101                	addi	sp,sp,-32
    800045ea:	ec06                	sd	ra,24(sp)
    800045ec:	e822                	sd	s0,16(sp)
    800045ee:	e426                	sd	s1,8(sp)
    800045f0:	e04a                	sd	s2,0(sp)
    800045f2:	1000                	addi	s0,sp,32
    800045f4:	84aa                	mv	s1,a0
    800045f6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800045f8:	e30fc0ef          	jal	80000c28 <acquire>
  if (writable) {
    800045fc:	02090763          	beqz	s2,8000462a <pipeclose+0x42>
    pi->writeopen = 0;
    80004600:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004604:	21848513          	addi	a0,s1,536
    80004608:	9bbfd0ef          	jal	80001fc2 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    8000460c:	2204a783          	lw	a5,544(s1)
    80004610:	e781                	bnez	a5,80004618 <pipeclose+0x30>
    80004612:	2244a783          	lw	a5,548(s1)
    80004616:	c38d                	beqz	a5,80004638 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    80004618:	8526                	mv	a0,s1
    8000461a:	e96fc0ef          	jal	80000cb0 <release>
}
    8000461e:	60e2                	ld	ra,24(sp)
    80004620:	6442                	ld	s0,16(sp)
    80004622:	64a2                	ld	s1,8(sp)
    80004624:	6902                	ld	s2,0(sp)
    80004626:	6105                	addi	sp,sp,32
    80004628:	8082                	ret
    pi->readopen = 0;
    8000462a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000462e:	21c48513          	addi	a0,s1,540
    80004632:	991fd0ef          	jal	80001fc2 <wakeup>
    80004636:	bfd9                	j	8000460c <pipeclose+0x24>
    release(&pi->lock);
    80004638:	8526                	mv	a0,s1
    8000463a:	e76fc0ef          	jal	80000cb0 <release>
    kfree((char *)pi);
    8000463e:	8526                	mv	a0,s1
    80004640:	c26fc0ef          	jal	80000a66 <kfree>
    80004644:	bfe9                	j	8000461e <pipeclose+0x36>

0000000080004646 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004646:	7159                	addi	sp,sp,-112
    80004648:	f486                	sd	ra,104(sp)
    8000464a:	f0a2                	sd	s0,96(sp)
    8000464c:	eca6                	sd	s1,88(sp)
    8000464e:	e8ca                	sd	s2,80(sp)
    80004650:	e4ce                	sd	s3,72(sp)
    80004652:	e0d2                	sd	s4,64(sp)
    80004654:	fc56                	sd	s5,56(sp)
    80004656:	1880                	addi	s0,sp,112
    80004658:	84aa                	mv	s1,a0
    8000465a:	8aae                	mv	s5,a1
    8000465c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000465e:	aeafd0ef          	jal	80001948 <myproc>
    80004662:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004664:	8526                	mv	a0,s1
    80004666:	dc2fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    8000466a:	0f405a63          	blez	s4,8000475e <pipewrite+0x118>
    8000466e:	f85a                	sd	s6,48(sp)
    80004670:	f45e                	sd	s7,40(sp)
    80004672:	f062                	sd	s8,32(sp)
    80004674:	ec66                	sd	s9,24(sp)
    80004676:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004678:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    8000467a:	f9f40c13          	addi	s8,s0,-97
    8000467e:	4b85                	li	s7,1
    80004680:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004682:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    80004686:	21c48c93          	addi	s9,s1,540
    8000468a:	a0a1                	j	800046d2 <pipewrite+0x8c>
      release(&pi->lock);
    8000468c:	8526                	mv	a0,s1
    8000468e:	e22fc0ef          	jal	80000cb0 <release>
      return -1;
    80004692:	597d                	li	s2,-1
    80004694:	7b42                	ld	s6,48(sp)
    80004696:	7ba2                	ld	s7,40(sp)
    80004698:	7c02                	ld	s8,32(sp)
    8000469a:	6ce2                	ld	s9,24(sp)
    8000469c:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000469e:	854a                	mv	a0,s2
    800046a0:	70a6                	ld	ra,104(sp)
    800046a2:	7406                	ld	s0,96(sp)
    800046a4:	64e6                	ld	s1,88(sp)
    800046a6:	6946                	ld	s2,80(sp)
    800046a8:	69a6                	ld	s3,72(sp)
    800046aa:	6a06                	ld	s4,64(sp)
    800046ac:	7ae2                	ld	s5,56(sp)
    800046ae:	6165                	addi	sp,sp,112
    800046b0:	8082                	ret
      wakeup(&pi->nread);
    800046b2:	856a                	mv	a0,s10
    800046b4:	90ffd0ef          	jal	80001fc2 <wakeup>
      sleep_prepare(&pi->nwrite);
    800046b8:	8566                	mv	a0,s9
    800046ba:	89dfd0ef          	jal	80001f56 <sleep_prepare>
      release(&pi->lock);
    800046be:	8526                	mv	a0,s1
    800046c0:	df0fc0ef          	jal	80000cb0 <release>
      sleep();
    800046c4:	8cffd0ef          	jal	80001f92 <sleep>
      acquire(&pi->lock);
    800046c8:	8526                	mv	a0,s1
    800046ca:	d5efc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    800046ce:	07495b63          	bge	s2,s4,80004744 <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    800046d2:	2204a783          	lw	a5,544(s1)
    800046d6:	dbdd                	beqz	a5,8000468c <pipewrite+0x46>
    800046d8:	854e                	mv	a0,s3
    800046da:	adbfd0ef          	jal	800021b4 <killed>
    800046de:	f55d                	bnez	a0,8000468c <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    800046e0:	2184a783          	lw	a5,536(s1)
    800046e4:	21c4a703          	lw	a4,540(s1)
    800046e8:	2007879b          	addiw	a5,a5,512
    800046ec:	fcf703e3          	beq	a4,a5,800046b2 <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    800046f0:	875e                	mv	a4,s7
    800046f2:	015906b3          	add	a3,s2,s5
    800046f6:	8662                	mv	a2,s8
    800046f8:	0489b583          	ld	a1,72(s3)
    800046fc:	0509b503          	ld	a0,80(s3)
    80004700:	f49fc0ef          	jal	80001648 <copyin>
    80004704:	03650163          	beq	a0,s6,80004726 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004708:	21c4a783          	lw	a5,540(s1)
    8000470c:	0017871b          	addiw	a4,a5,1
    80004710:	20e4ae23          	sw	a4,540(s1)
    80004714:	1ff7f793          	andi	a5,a5,511
    80004718:	97a6                	add	a5,a5,s1
    8000471a:	f9f44703          	lbu	a4,-97(s0)
    8000471e:	00e78c23          	sb	a4,24(a5)
      i++;
    80004722:	2905                	addiw	s2,s2,1
    80004724:	b76d                	j	800046ce <pipewrite+0x88>
        if (i == 0)
    80004726:	00090863          	beqz	s2,80004736 <pipewrite+0xf0>
    8000472a:	7b42                	ld	s6,48(sp)
    8000472c:	7ba2                	ld	s7,40(sp)
    8000472e:	7c02                	ld	s8,32(sp)
    80004730:	6ce2                	ld	s9,24(sp)
    80004732:	6d42                	ld	s10,16(sp)
    80004734:	a829                	j	8000474e <pipewrite+0x108>
          i = -1;
    80004736:	892a                	mv	s2,a0
        break;
    80004738:	7b42                	ld	s6,48(sp)
    8000473a:	7ba2                	ld	s7,40(sp)
    8000473c:	7c02                	ld	s8,32(sp)
    8000473e:	6ce2                	ld	s9,24(sp)
    80004740:	6d42                	ld	s10,16(sp)
    80004742:	a031                	j	8000474e <pipewrite+0x108>
    80004744:	7b42                	ld	s6,48(sp)
    80004746:	7ba2                	ld	s7,40(sp)
    80004748:	7c02                	ld	s8,32(sp)
    8000474a:	6ce2                	ld	s9,24(sp)
    8000474c:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    8000474e:	21848513          	addi	a0,s1,536
    80004752:	871fd0ef          	jal	80001fc2 <wakeup>
  release(&pi->lock);
    80004756:	8526                	mv	a0,s1
    80004758:	d58fc0ef          	jal	80000cb0 <release>
  return i;
    8000475c:	b789                	j	8000469e <pipewrite+0x58>
  int i = 0;
    8000475e:	4901                	li	s2,0
    80004760:	b7fd                	j	8000474e <pipewrite+0x108>

0000000080004762 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004762:	711d                	addi	sp,sp,-96
    80004764:	ec86                	sd	ra,88(sp)
    80004766:	e8a2                	sd	s0,80(sp)
    80004768:	e4a6                	sd	s1,72(sp)
    8000476a:	e0ca                	sd	s2,64(sp)
    8000476c:	fc4e                	sd	s3,56(sp)
    8000476e:	f852                	sd	s4,48(sp)
    80004770:	f456                	sd	s5,40(sp)
    80004772:	1080                	addi	s0,sp,96
    80004774:	84aa                	mv	s1,a0
    80004776:	89ae                	mv	s3,a1
    80004778:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000477a:	9cefd0ef          	jal	80001948 <myproc>
    8000477e:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    80004780:	8526                	mv	a0,s1
    80004782:	ca6fc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004786:	0d505263          	blez	s5,8000484a <piperead+0xe8>
    8000478a:	2184a703          	lw	a4,536(s1)
    8000478e:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004792:	21848a13          	addi	s4,s1,536
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004796:	02f71e63          	bne	a4,a5,800047d2 <piperead+0x70>
    8000479a:	2244a783          	lw	a5,548(s1)
    8000479e:	c3b9                	beqz	a5,800047e4 <piperead+0x82>
    if (killed(pr)) {
    800047a0:	854a                	mv	a0,s2
    800047a2:	a13fd0ef          	jal	800021b4 <killed>
    800047a6:	e915                	bnez	a0,800047da <piperead+0x78>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    800047a8:	8552                	mv	a0,s4
    800047aa:	facfd0ef          	jal	80001f56 <sleep_prepare>
    release(&pi->lock);
    800047ae:	8526                	mv	a0,s1
    800047b0:	d00fc0ef          	jal	80000cb0 <release>
    sleep();
    800047b4:	fdefd0ef          	jal	80001f92 <sleep>
    acquire(&pi->lock);
    800047b8:	8526                	mv	a0,s1
    800047ba:	c6efc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800047be:	2184a703          	lw	a4,536(s1)
    800047c2:	21c4a783          	lw	a5,540(s1)
    800047c6:	fcf70ae3          	beq	a4,a5,8000479a <piperead+0x38>
    800047ca:	f05a                	sd	s6,32(sp)
    800047cc:	ec5e                	sd	s7,24(sp)
    800047ce:	e862                	sd	s8,16(sp)
    800047d0:	a829                	j	800047ea <piperead+0x88>
    800047d2:	f05a                	sd	s6,32(sp)
    800047d4:	ec5e                	sd	s7,24(sp)
    800047d6:	e862                	sd	s8,16(sp)
    800047d8:	a809                	j	800047ea <piperead+0x88>
      release(&pi->lock);
    800047da:	8526                	mv	a0,s1
    800047dc:	cd4fc0ef          	jal	80000cb0 <release>
      return -1;
    800047e0:	5a7d                	li	s4,-1
    800047e2:	a8a5                	j	8000485a <piperead+0xf8>
    800047e4:	f05a                	sd	s6,32(sp)
    800047e6:	ec5e                	sd	s7,24(sp)
    800047e8:	e862                	sd	s8,16(sp)
{
    800047ea:	4a01                	li	s4,0
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    800047ec:	faf40c13          	addi	s8,s0,-81
    800047f0:	4b85                	li	s7,1
    800047f2:	5b7d                	li	s6,-1
    if (pi->nread == pi->nwrite)
    800047f4:	2184a783          	lw	a5,536(s1)
    800047f8:	21c4a703          	lw	a4,540(s1)
    800047fc:	06f70e63          	beq	a4,a5,80004878 <piperead+0x116>
    ch = pi->data[pi->nread % PIPESIZE];
    80004800:	1ff7f793          	andi	a5,a5,511
    80004804:	97a6                	add	a5,a5,s1
    80004806:	0187c783          	lbu	a5,24(a5)
    8000480a:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    8000480e:	875e                	mv	a4,s7
    80004810:	86e2                	mv	a3,s8
    80004812:	864e                	mv	a2,s3
    80004814:	04893583          	ld	a1,72(s2)
    80004818:	05093503          	ld	a0,80(s2)
    8000481c:	d67fc0ef          	jal	80001582 <copyout>
    80004820:	01650f63          	beq	a0,s6,8000483e <piperead+0xdc>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004824:	2184a783          	lw	a5,536(s1)
    80004828:	2785                	addiw	a5,a5,1
    8000482a:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    8000482e:	2a05                	addiw	s4,s4,1
    80004830:	0985                	addi	s3,s3,1
    80004832:	fd4a91e3          	bne	s5,s4,800047f4 <piperead+0x92>
    80004836:	7b02                	ld	s6,32(sp)
    80004838:	6be2                	ld	s7,24(sp)
    8000483a:	6c42                	ld	s8,16(sp)
    8000483c:	a801                	j	8000484c <piperead+0xea>
      if (i == 0)
    8000483e:	020a0863          	beqz	s4,8000486e <piperead+0x10c>
    80004842:	7b02                	ld	s6,32(sp)
    80004844:	6be2                	ld	s7,24(sp)
    80004846:	6c42                	ld	s8,16(sp)
    80004848:	a011                	j	8000484c <piperead+0xea>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    8000484a:	4a01                	li	s4,0
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    8000484c:	21c48513          	addi	a0,s1,540
    80004850:	f72fd0ef          	jal	80001fc2 <wakeup>
  release(&pi->lock);
    80004854:	8526                	mv	a0,s1
    80004856:	c5afc0ef          	jal	80000cb0 <release>
  return i;
}
    8000485a:	8552                	mv	a0,s4
    8000485c:	60e6                	ld	ra,88(sp)
    8000485e:	6446                	ld	s0,80(sp)
    80004860:	64a6                	ld	s1,72(sp)
    80004862:	6906                	ld	s2,64(sp)
    80004864:	79e2                	ld	s3,56(sp)
    80004866:	7a42                	ld	s4,48(sp)
    80004868:	7aa2                	ld	s5,40(sp)
    8000486a:	6125                	addi	sp,sp,96
    8000486c:	8082                	ret
        i = -1;
    8000486e:	8a2a                	mv	s4,a0
    80004870:	7b02                	ld	s6,32(sp)
    80004872:	6be2                	ld	s7,24(sp)
    80004874:	6c42                	ld	s8,16(sp)
    80004876:	bfd9                	j	8000484c <piperead+0xea>
    80004878:	7b02                	ld	s6,32(sp)
    8000487a:	6be2                	ld	s7,24(sp)
    8000487c:	6c42                	ld	s8,16(sp)
    8000487e:	b7f9                	j	8000484c <piperead+0xea>

0000000080004880 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    80004880:	1141                	addi	sp,sp,-16
    80004882:	e406                	sd	ra,8(sp)
    80004884:	e022                	sd	s0,0(sp)
    80004886:	0800                	addi	s0,sp,16
    80004888:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    8000488a:	0035151b          	slliw	a0,a0,0x3
    8000488e:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    80004890:	8b89                	andi	a5,a5,2
    80004892:	c399                	beqz	a5,80004898 <flags2perm+0x18>
    perm |= PTE_W;
    80004894:	00456513          	ori	a0,a0,4
  return perm;
}
    80004898:	60a2                	ld	ra,8(sp)
    8000489a:	6402                	ld	s0,0(sp)
    8000489c:	0141                	addi	sp,sp,16
    8000489e:	8082                	ret

00000000800048a0 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800048a0:	de010113          	addi	sp,sp,-544
    800048a4:	20113c23          	sd	ra,536(sp)
    800048a8:	20813823          	sd	s0,528(sp)
    800048ac:	20913423          	sd	s1,520(sp)
    800048b0:	21213023          	sd	s2,512(sp)
    800048b4:	1400                	addi	s0,sp,544
    800048b6:	892a                	mv	s2,a0
    800048b8:	dea43823          	sd	a0,-528(s0)
    800048bc:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800048c0:	888fd0ef          	jal	80001948 <myproc>
    800048c4:	84aa                	mv	s1,a0

  begin_op();
    800048c6:	c62ff0ef          	jal	80003d28 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    800048ca:	854a                	mv	a0,s2
    800048cc:	a7eff0ef          	jal	80003b4a <namei>
    800048d0:	cd21                	beqz	a0,80004928 <kexec+0x88>
    800048d2:	fbd2                	sd	s4,496(sp)
    800048d4:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800048d6:	9dbfe0ef          	jal	800032b0 <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800048da:	04000713          	li	a4,64
    800048de:	4681                	li	a3,0
    800048e0:	e5040613          	addi	a2,s0,-432
    800048e4:	4581                	li	a1,0
    800048e6:	8552                	mv	a0,s4
    800048e8:	da3fe0ef          	jal	8000368a <readi>
    800048ec:	04000793          	li	a5,64
    800048f0:	00f51a63          	bne	a0,a5,80004904 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    800048f4:	e5042703          	lw	a4,-432(s0)
    800048f8:	464c47b7          	lui	a5,0x464c4
    800048fc:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004900:	02f70863          	beq	a4,a5,80004930 <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    80004904:	8552                	mv	a0,s4
    80004906:	bfffe0ef          	jal	80003504 <iunlockput>
    end_op();
    8000490a:	caaff0ef          	jal	80003db4 <end_op>
  }
  return -1;
    8000490e:	557d                	li	a0,-1
    80004910:	7a5e                	ld	s4,496(sp)
}
    80004912:	21813083          	ld	ra,536(sp)
    80004916:	21013403          	ld	s0,528(sp)
    8000491a:	20813483          	ld	s1,520(sp)
    8000491e:	20013903          	ld	s2,512(sp)
    80004922:	22010113          	addi	sp,sp,544
    80004926:	8082                	ret
    end_op();
    80004928:	c8cff0ef          	jal	80003db4 <end_op>
    return -1;
    8000492c:	557d                	li	a0,-1
    8000492e:	b7d5                	j	80004912 <kexec+0x72>
    80004930:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004932:	8526                	mv	a0,s1
    80004934:	91afd0ef          	jal	80001a4e <proc_pagetable>
    80004938:	8b2a                	mv	s6,a0
    8000493a:	26050e63          	beqz	a0,80004bb6 <kexec+0x316>
    8000493e:	ffce                	sd	s3,504(sp)
    80004940:	f7d6                	sd	s5,488(sp)
    80004942:	efde                	sd	s7,472(sp)
    80004944:	ebe2                	sd	s8,464(sp)
    80004946:	e7e6                	sd	s9,456(sp)
    80004948:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    8000494a:	e8845783          	lhu	a5,-376(s0)
    8000494e:	14078263          	beqz	a5,80004a92 <kexec+0x1f2>
    80004952:	ff6e                	sd	s11,440(sp)
    80004954:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004958:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    8000495a:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000495c:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    80004960:	6c85                	lui	s9,0x1
    80004962:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004966:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    8000496a:	6a85                	lui	s5,0x1
    8000496c:	a085                	j	800049cc <kexec+0x12c>
      panic("loadseg: address should exist");
    8000496e:	00003517          	auipc	a0,0x3
    80004972:	c9250513          	addi	a0,a0,-878 # 80007600 <etext+0x600>
    80004976:	ebffb0ef          	jal	80000834 <panic>
    if (sz - i < PGSIZE)
    8000497a:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    8000497c:	874a                	mv	a4,s2
    8000497e:	009b86bb          	addw	a3,s7,s1
    80004982:	4581                	li	a1,0
    80004984:	8552                	mv	a0,s4
    80004986:	d05fe0ef          	jal	8000368a <readi>
    8000498a:	22a91a63          	bne	s2,a0,80004bbe <kexec+0x31e>
  for (i = 0; i < sz; i += PGSIZE) {
    8000498e:	009a84bb          	addw	s1,s5,s1
    80004992:	0334f263          	bgeu	s1,s3,800049b6 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004996:	02049593          	slli	a1,s1,0x20
    8000499a:	9181                	srli	a1,a1,0x20
    8000499c:	95e2                	add	a1,a1,s8
    8000499e:	855a                	mv	a0,s6
    800049a0:	e78fc0ef          	jal	80001018 <walkaddr>
    800049a4:	862a                	mv	a2,a0
    if (pa == 0)
    800049a6:	d561                	beqz	a0,8000496e <kexec+0xce>
    if (sz - i < PGSIZE)
    800049a8:	409987bb          	subw	a5,s3,s1
    800049ac:	893e                	mv	s2,a5
    800049ae:	fcfcf6e3          	bgeu	s9,a5,8000497a <kexec+0xda>
    800049b2:	8956                	mv	s2,s5
    800049b4:	b7d9                	j	8000497a <kexec+0xda>
    sz = sz1;
    800049b6:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    800049ba:	2d05                	addiw	s10,s10,1
    800049bc:	e0843783          	ld	a5,-504(s0)
    800049c0:	0387869b          	addiw	a3,a5,56
    800049c4:	e8845783          	lhu	a5,-376(s0)
    800049c8:	06fd5d63          	bge	s10,a5,80004a42 <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800049cc:	e0d43423          	sd	a3,-504(s0)
    800049d0:	876e                	mv	a4,s11
    800049d2:	e1840613          	addi	a2,s0,-488
    800049d6:	4581                	li	a1,0
    800049d8:	8552                	mv	a0,s4
    800049da:	cb1fe0ef          	jal	8000368a <readi>
    800049de:	1db51e63          	bne	a0,s11,80004bba <kexec+0x31a>
    if (ph.type != ELF_PROG_LOAD)
    800049e2:	e1842783          	lw	a5,-488(s0)
    800049e6:	4705                	li	a4,1
    800049e8:	fce799e3          	bne	a5,a4,800049ba <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    800049ec:	e4043483          	ld	s1,-448(s0)
    800049f0:	e3843783          	ld	a5,-456(s0)
    800049f4:	1ef4e363          	bltu	s1,a5,80004bda <kexec+0x33a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    800049f8:	e2843783          	ld	a5,-472(s0)
    800049fc:	94be                	add	s1,s1,a5
    800049fe:	1ef4e163          	bltu	s1,a5,80004be0 <kexec+0x340>
    if (ph.vaddr % PGSIZE != 0)
    80004a02:	de843703          	ld	a4,-536(s0)
    80004a06:	8ff9                	and	a5,a5,a4
    80004a08:	1c079f63          	bnez	a5,80004be6 <kexec+0x346>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004a0c:	e1c42503          	lw	a0,-484(s0)
    80004a10:	e71ff0ef          	jal	80004880 <flags2perm>
    80004a14:	86aa                	mv	a3,a0
    80004a16:	8626                	mv	a2,s1
    80004a18:	85ca                	mv	a1,s2
    80004a1a:	855a                	mv	a0,s6
    80004a1c:	8d3fc0ef          	jal	800012ee <uvmalloc>
    80004a20:	dea43c23          	sd	a0,-520(s0)
    80004a24:	1c050463          	beqz	a0,80004bec <kexec+0x34c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004a28:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004a2c:	00098863          	beqz	s3,80004a3c <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004a30:	e2843c03          	ld	s8,-472(s0)
    80004a34:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004a38:	4481                	li	s1,0
    80004a3a:	bfb1                	j	80004996 <kexec+0xf6>
    sz = sz1;
    80004a3c:	df843903          	ld	s2,-520(s0)
    80004a40:	bfad                	j	800049ba <kexec+0x11a>
    80004a42:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    80004a44:	8552                	mv	a0,s4
    80004a46:	abffe0ef          	jal	80003504 <iunlockput>
  end_op();
    80004a4a:	b6aff0ef          	jal	80003db4 <end_op>
  p = myproc();
    80004a4e:	efbfc0ef          	jal	80001948 <myproc>
    80004a52:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004a54:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    80004a58:	6c05                	lui	s8,0x1
    80004a5a:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    80004a5c:	9c4a                	add	s8,s8,s2
    80004a5e:	77fd                	lui	a5,0xfffff
    80004a60:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004a64:	4691                	li	a3,4
    80004a66:	6609                	lui	a2,0x2
    80004a68:	9662                	add	a2,a2,s8
    80004a6a:	85e2                	mv	a1,s8
    80004a6c:	855a                	mv	a0,s6
    80004a6e:	881fc0ef          	jal	800012ee <uvmalloc>
    80004a72:	892a                	mv	s2,a0
    80004a74:	e10d                	bnez	a0,80004a96 <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    80004a76:	85e2                	mv	a1,s8
    80004a78:	855a                	mv	a0,s6
    80004a7a:	858fd0ef          	jal	80001ad2 <proc_freepagetable>
  return -1;
    80004a7e:	557d                	li	a0,-1
    80004a80:	79fe                	ld	s3,504(sp)
    80004a82:	7a5e                	ld	s4,496(sp)
    80004a84:	7abe                	ld	s5,488(sp)
    80004a86:	7b1e                	ld	s6,480(sp)
    80004a88:	6bfe                	ld	s7,472(sp)
    80004a8a:	6c5e                	ld	s8,464(sp)
    80004a8c:	6cbe                	ld	s9,456(sp)
    80004a8e:	6d1e                	ld	s10,448(sp)
    80004a90:	b549                	j	80004912 <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a92:	4901                	li	s2,0
    80004a94:	bf45                	j	80004a44 <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004a96:	75f9                	lui	a1,0xffffe
    80004a98:	95aa                	add	a1,a1,a0
    80004a9a:	855a                	mv	a0,s6
    80004a9c:	a25fc0ef          	jal	800014c0 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004aa0:	80090a13          	addi	s4,s2,-2048
    80004aa4:	800a0a13          	addi	s4,s4,-2048
  for (argc = 0; argv[argc]; argc++) {
    80004aa8:	e0043783          	ld	a5,-512(s0)
    80004aac:	6388                	ld	a0,0(a5)
    80004aae:	c545                	beqz	a0,80004b56 <kexec+0x2b6>
  sp = sz;
    80004ab0:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004ab2:	4481                	li	s1,0
    ustack[argc] = sp;
    80004ab4:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004ab8:	bbafc0ef          	jal	80000e72 <strlen>
    80004abc:	0015079b          	addiw	a5,a0,1
    80004ac0:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004ac4:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004ac8:	134c6563          	bltu	s8,s4,80004bf2 <kexec+0x352>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004acc:	e0043d03          	ld	s10,-512(s0)
    80004ad0:	000d3c83          	ld	s9,0(s10)
    80004ad4:	8566                	mv	a0,s9
    80004ad6:	b9cfc0ef          	jal	80000e72 <strlen>
    80004ada:	0015071b          	addiw	a4,a0,1
    80004ade:	86e6                	mv	a3,s9
    80004ae0:	8662                	mv	a2,s8
    80004ae2:	85ca                	mv	a1,s2
    80004ae4:	855a                	mv	a0,s6
    80004ae6:	a9dfc0ef          	jal	80001582 <copyout>
    80004aea:	10054663          	bltz	a0,80004bf6 <kexec+0x356>
    ustack[argc] = sp;
    80004aee:	00349793          	slli	a5,s1,0x3
    80004af2:	97de                	add	a5,a5,s7
    80004af4:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb788>
  for (argc = 0; argv[argc]; argc++) {
    80004af8:	0485                	addi	s1,s1,1
    80004afa:	008d0793          	addi	a5,s10,8
    80004afe:	e0f43023          	sd	a5,-512(s0)
    80004b02:	008d3503          	ld	a0,8(s10)
    80004b06:	f94d                	bnez	a0,80004ab8 <kexec+0x218>
  ustack[argc] = 0;
    80004b08:	00349793          	slli	a5,s1,0x3
    80004b0c:	f9078793          	addi	a5,a5,-112
    80004b10:	97a2                	add	a5,a5,s0
    80004b12:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004b16:	00349713          	slli	a4,s1,0x3
    80004b1a:	0721                	addi	a4,a4,8
    80004b1c:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004b20:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004b24:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004b26:	f54be8e3          	bltu	s7,s4,80004a76 <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004b2a:	e9040693          	addi	a3,s0,-368
    80004b2e:	865e                	mv	a2,s7
    80004b30:	85ca                	mv	a1,s2
    80004b32:	855a                	mv	a0,s6
    80004b34:	a4ffc0ef          	jal	80001582 <copyout>
    80004b38:	f2054fe3          	bltz	a0,80004a76 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004b3c:	0589b783          	ld	a5,88(s3)
    80004b40:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004b44:	df043783          	ld	a5,-528(s0)
    80004b48:	0007c703          	lbu	a4,0(a5)
    80004b4c:	c30d                	beqz	a4,80004b6e <kexec+0x2ce>
    80004b4e:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004b50:	02f00693          	li	a3,47
    80004b54:	a801                	j	80004b64 <kexec+0x2c4>
  sp = sz;
    80004b56:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004b58:	4481                	li	s1,0
    80004b5a:	b77d                	j	80004b08 <kexec+0x268>
  for (last = s = path; *s; s++)
    80004b5c:	0785                	addi	a5,a5,1
    80004b5e:	fff7c703          	lbu	a4,-1(a5)
    80004b62:	c711                	beqz	a4,80004b6e <kexec+0x2ce>
    if (*s == '/')
    80004b64:	fed71ce3          	bne	a4,a3,80004b5c <kexec+0x2bc>
      last = s + 1;
    80004b68:	def43823          	sd	a5,-528(s0)
    80004b6c:	bfc5                	j	80004b5c <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004b6e:	4641                	li	a2,16
    80004b70:	df043583          	ld	a1,-528(s0)
    80004b74:	15898513          	addi	a0,s3,344
    80004b78:	ac4fc0ef          	jal	80000e3c <safestrcpy>
  oldpagetable = p->pagetable;
    80004b7c:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004b80:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004b84:	0529b423          	sd	s2,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004b88:	0589b783          	ld	a5,88(s3)
    80004b8c:	e6843703          	ld	a4,-408(s0)
    80004b90:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004b92:	0589b783          	ld	a5,88(s3)
    80004b96:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004b9a:	85d6                	mv	a1,s5
    80004b9c:	f37fc0ef          	jal	80001ad2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004ba0:	0004851b          	sext.w	a0,s1
    80004ba4:	79fe                	ld	s3,504(sp)
    80004ba6:	7a5e                	ld	s4,496(sp)
    80004ba8:	7abe                	ld	s5,488(sp)
    80004baa:	7b1e                	ld	s6,480(sp)
    80004bac:	6bfe                	ld	s7,472(sp)
    80004bae:	6c5e                	ld	s8,464(sp)
    80004bb0:	6cbe                	ld	s9,456(sp)
    80004bb2:	6d1e                	ld	s10,448(sp)
    80004bb4:	bbb9                	j	80004912 <kexec+0x72>
    80004bb6:	7b1e                	ld	s6,480(sp)
    80004bb8:	b3b1                	j	80004904 <kexec+0x64>
    80004bba:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004bbe:	df843583          	ld	a1,-520(s0)
    80004bc2:	855a                	mv	a0,s6
    80004bc4:	f0ffc0ef          	jal	80001ad2 <proc_freepagetable>
  if (ip) {
    80004bc8:	79fe                	ld	s3,504(sp)
    80004bca:	7abe                	ld	s5,488(sp)
    80004bcc:	7b1e                	ld	s6,480(sp)
    80004bce:	6bfe                	ld	s7,472(sp)
    80004bd0:	6c5e                	ld	s8,464(sp)
    80004bd2:	6cbe                	ld	s9,456(sp)
    80004bd4:	6d1e                	ld	s10,448(sp)
    80004bd6:	7dfa                	ld	s11,440(sp)
    80004bd8:	b335                	j	80004904 <kexec+0x64>
    80004bda:	df243c23          	sd	s2,-520(s0)
    80004bde:	b7c5                	j	80004bbe <kexec+0x31e>
    80004be0:	df243c23          	sd	s2,-520(s0)
    80004be4:	bfe9                	j	80004bbe <kexec+0x31e>
    80004be6:	df243c23          	sd	s2,-520(s0)
    80004bea:	bfd1                	j	80004bbe <kexec+0x31e>
    80004bec:	df243c23          	sd	s2,-520(s0)
    80004bf0:	b7f9                	j	80004bbe <kexec+0x31e>
  sz = sz1;
    80004bf2:	8c4a                	mv	s8,s2
    80004bf4:	b549                	j	80004a76 <kexec+0x1d6>
    80004bf6:	8c4a                	mv	s8,s2
    80004bf8:	bdbd                	j	80004a76 <kexec+0x1d6>

0000000080004bfa <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004bfa:	7179                	addi	sp,sp,-48
    80004bfc:	f406                	sd	ra,40(sp)
    80004bfe:	f022                	sd	s0,32(sp)
    80004c00:	ec26                	sd	s1,24(sp)
    80004c02:	e84a                	sd	s2,16(sp)
    80004c04:	1800                	addi	s0,sp,48
    80004c06:	892e                	mv	s2,a1
    80004c08:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004c0a:	fdc40593          	addi	a1,s0,-36
    80004c0e:	cc7fd0ef          	jal	800028d4 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004c12:	fdc42703          	lw	a4,-36(s0)
    80004c16:	47bd                	li	a5,15
    80004c18:	02e7ea63          	bltu	a5,a4,80004c4c <argfd+0x52>
    80004c1c:	d2dfc0ef          	jal	80001948 <myproc>
    80004c20:	fdc42703          	lw	a4,-36(s0)
    80004c24:	00371793          	slli	a5,a4,0x3
    80004c28:	0d078793          	addi	a5,a5,208
    80004c2c:	953e                	add	a0,a0,a5
    80004c2e:	611c                	ld	a5,0(a0)
    80004c30:	c385                	beqz	a5,80004c50 <argfd+0x56>
    return -1;
  if (pfd)
    80004c32:	00090463          	beqz	s2,80004c3a <argfd+0x40>
    *pfd = fd;
    80004c36:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004c3a:	4501                	li	a0,0
  if (pf)
    80004c3c:	c091                	beqz	s1,80004c40 <argfd+0x46>
    *pf = f;
    80004c3e:	e09c                	sd	a5,0(s1)
}
    80004c40:	70a2                	ld	ra,40(sp)
    80004c42:	7402                	ld	s0,32(sp)
    80004c44:	64e2                	ld	s1,24(sp)
    80004c46:	6942                	ld	s2,16(sp)
    80004c48:	6145                	addi	sp,sp,48
    80004c4a:	8082                	ret
    return -1;
    80004c4c:	557d                	li	a0,-1
    80004c4e:	bfcd                	j	80004c40 <argfd+0x46>
    80004c50:	557d                	li	a0,-1
    80004c52:	b7fd                	j	80004c40 <argfd+0x46>

0000000080004c54 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004c54:	1101                	addi	sp,sp,-32
    80004c56:	ec06                	sd	ra,24(sp)
    80004c58:	e822                	sd	s0,16(sp)
    80004c5a:	e426                	sd	s1,8(sp)
    80004c5c:	1000                	addi	s0,sp,32
    80004c5e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004c60:	ce9fc0ef          	jal	80001948 <myproc>
    80004c64:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004c66:	0d050793          	addi	a5,a0,208
    80004c6a:	4501                	li	a0,0
    80004c6c:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004c6e:	6398                	ld	a4,0(a5)
    80004c70:	cb19                	beqz	a4,80004c86 <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004c72:	2505                	addiw	a0,a0,1
    80004c74:	07a1                	addi	a5,a5,8
    80004c76:	fed51ce3          	bne	a0,a3,80004c6e <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004c7a:	557d                	li	a0,-1
}
    80004c7c:	60e2                	ld	ra,24(sp)
    80004c7e:	6442                	ld	s0,16(sp)
    80004c80:	64a2                	ld	s1,8(sp)
    80004c82:	6105                	addi	sp,sp,32
    80004c84:	8082                	ret
      p->ofile[fd] = f;
    80004c86:	00351793          	slli	a5,a0,0x3
    80004c8a:	0d078793          	addi	a5,a5,208
    80004c8e:	963e                	add	a2,a2,a5
    80004c90:	e204                	sd	s1,0(a2)
      return fd;
    80004c92:	b7ed                	j	80004c7c <fdalloc+0x28>

0000000080004c94 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004c94:	715d                	addi	sp,sp,-80
    80004c96:	e486                	sd	ra,72(sp)
    80004c98:	e0a2                	sd	s0,64(sp)
    80004c9a:	fc26                	sd	s1,56(sp)
    80004c9c:	f84a                	sd	s2,48(sp)
    80004c9e:	f052                	sd	s4,32(sp)
    80004ca0:	ec56                	sd	s5,24(sp)
    80004ca2:	e85a                	sd	s6,16(sp)
    80004ca4:	0880                	addi	s0,sp,80
    80004ca6:	8a2e                	mv	s4,a1
    80004ca8:	8ab2                	mv	s5,a2
    80004caa:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004cac:	fb040593          	addi	a1,s0,-80
    80004cb0:	eb5fe0ef          	jal	80003b64 <nameiparent>
    80004cb4:	84aa                	mv	s1,a0
    80004cb6:	12050f63          	beqz	a0,80004df4 <create+0x160>
    return 0;

  ilock(dp);
    80004cba:	df6fe0ef          	jal	800032b0 <ilock>

  if (dp->nlink == 0) {
    80004cbe:	04a49783          	lh	a5,74(s1)
    80004cc2:	cbb9                	beqz	a5,80004d18 <create+0x84>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004cc4:	7761                	lui	a4,0xffff8
    80004cc6:	0705                	addi	a4,a4,1 # ffffffffffff8001 <end+0xffffffff7ffd4789>
    80004cc8:	97ba                	add	a5,a5,a4
    80004cca:	e781                	bnez	a5,80004cd2 <create+0x3e>
    80004ccc:	fffa0793          	addi	a5,s4,-1
    80004cd0:	cba9                	beqz	a5,80004d22 <create+0x8e>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004cd2:	4601                	li	a2,0
    80004cd4:	fb040593          	addi	a1,s0,-80
    80004cd8:	8526                	mv	a0,s1
    80004cda:	bbffe0ef          	jal	80003898 <dirlookup>
    80004cde:	892a                	mv	s2,a0
    80004ce0:	c939                	beqz	a0,80004d36 <create+0xa2>
    iunlockput(dp);
    80004ce2:	8526                	mv	a0,s1
    80004ce4:	821fe0ef          	jal	80003504 <iunlockput>
    ilock(ip);
    80004ce8:	854a                	mv	a0,s2
    80004cea:	dc6fe0ef          	jal	800032b0 <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004cee:	4789                	li	a5,2
    80004cf0:	02fa1e63          	bne	s4,a5,80004d2c <create+0x98>
    80004cf4:	04495783          	lhu	a5,68(s2)
    80004cf8:	37f9                	addiw	a5,a5,-2
    80004cfa:	17c2                	slli	a5,a5,0x30
    80004cfc:	93c1                	srli	a5,a5,0x30
    80004cfe:	4705                	li	a4,1
    80004d00:	02f76663          	bltu	a4,a5,80004d2c <create+0x98>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004d04:	854a                	mv	a0,s2
    80004d06:	60a6                	ld	ra,72(sp)
    80004d08:	6406                	ld	s0,64(sp)
    80004d0a:	74e2                	ld	s1,56(sp)
    80004d0c:	7942                	ld	s2,48(sp)
    80004d0e:	7a02                	ld	s4,32(sp)
    80004d10:	6ae2                	ld	s5,24(sp)
    80004d12:	6b42                	ld	s6,16(sp)
    80004d14:	6161                	addi	sp,sp,80
    80004d16:	8082                	ret
    iunlockput(dp);
    80004d18:	8526                	mv	a0,s1
    80004d1a:	feafe0ef          	jal	80003504 <iunlockput>
    return 0;
    80004d1e:	4901                	li	s2,0
    80004d20:	b7d5                	j	80004d04 <create+0x70>
    iunlockput(dp);
    80004d22:	8526                	mv	a0,s1
    80004d24:	fe0fe0ef          	jal	80003504 <iunlockput>
    return 0;
    80004d28:	4901                	li	s2,0
    80004d2a:	bfe9                	j	80004d04 <create+0x70>
    iunlockput(ip);
    80004d2c:	854a                	mv	a0,s2
    80004d2e:	fd6fe0ef          	jal	80003504 <iunlockput>
    return 0;
    80004d32:	4901                	li	s2,0
    80004d34:	bfc1                	j	80004d04 <create+0x70>
    80004d36:	f44e                	sd	s3,40(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004d38:	85d2                	mv	a1,s4
    80004d3a:	4088                	lw	a0,0(s1)
    80004d3c:	c04fe0ef          	jal	80003140 <ialloc>
    80004d40:	89aa                	mv	s3,a0
    80004d42:	cd1d                	beqz	a0,80004d80 <create+0xec>
  ilock(ip);
    80004d44:	d6cfe0ef          	jal	800032b0 <ilock>
  ip->major = major;
    80004d48:	05599323          	sh	s5,70(s3)
  ip->minor = minor;
    80004d4c:	05699423          	sh	s6,72(s3)
  ip->nlink = 1;
    80004d50:	4705                	li	a4,1
    80004d52:	04e99523          	sh	a4,74(s3)
  iupdate(ip);
    80004d56:	854e                	mv	a0,s3
    80004d58:	ca4fe0ef          	jal	800031fc <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80004d5c:	4705                	li	a4,1
    80004d5e:	02ea0763          	beq	s4,a4,80004d8c <create+0xf8>
  if (dirlink(dp, name, ip->inum) < 0)
    80004d62:	0049a603          	lw	a2,4(s3)
    80004d66:	fb040593          	addi	a1,s0,-80
    80004d6a:	8526                	mv	a0,s1
    80004d6c:	d35fe0ef          	jal	80003aa0 <dirlink>
    80004d70:	06054563          	bltz	a0,80004dda <create+0x146>
  iunlockput(dp);
    80004d74:	8526                	mv	a0,s1
    80004d76:	f8efe0ef          	jal	80003504 <iunlockput>
  return ip;
    80004d7a:	894e                	mv	s2,s3
    80004d7c:	79a2                	ld	s3,40(sp)
    80004d7e:	b759                	j	80004d04 <create+0x70>
    iunlockput(dp);
    80004d80:	8526                	mv	a0,s1
    80004d82:	f82fe0ef          	jal	80003504 <iunlockput>
    return 0;
    80004d86:	894e                	mv	s2,s3
    80004d88:	79a2                	ld	s3,40(sp)
    80004d8a:	bfad                	j	80004d04 <create+0x70>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004d8c:	0049a603          	lw	a2,4(s3)
    80004d90:	00003597          	auipc	a1,0x3
    80004d94:	89058593          	addi	a1,a1,-1904 # 80007620 <etext+0x620>
    80004d98:	854e                	mv	a0,s3
    80004d9a:	d07fe0ef          	jal	80003aa0 <dirlink>
    80004d9e:	02054e63          	bltz	a0,80004dda <create+0x146>
    80004da2:	40d0                	lw	a2,4(s1)
    80004da4:	00003597          	auipc	a1,0x3
    80004da8:	88458593          	addi	a1,a1,-1916 # 80007628 <etext+0x628>
    80004dac:	854e                	mv	a0,s3
    80004dae:	cf3fe0ef          	jal	80003aa0 <dirlink>
    80004db2:	02054463          	bltz	a0,80004dda <create+0x146>
  if (dirlink(dp, name, ip->inum) < 0)
    80004db6:	0049a603          	lw	a2,4(s3)
    80004dba:	fb040593          	addi	a1,s0,-80
    80004dbe:	8526                	mv	a0,s1
    80004dc0:	ce1fe0ef          	jal	80003aa0 <dirlink>
    80004dc4:	00054b63          	bltz	a0,80004dda <create+0x146>
    dp->nlink++; // for ".."
    80004dc8:	04a4d783          	lhu	a5,74(s1)
    80004dcc:	2785                	addiw	a5,a5,1
    80004dce:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004dd2:	8526                	mv	a0,s1
    80004dd4:	c28fe0ef          	jal	800031fc <iupdate>
    80004dd8:	bf71                	j	80004d74 <create+0xe0>
  ip->nlink = 0;
    80004dda:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    80004dde:	854e                	mv	a0,s3
    80004de0:	c1cfe0ef          	jal	800031fc <iupdate>
  iunlockput(ip);
    80004de4:	854e                	mv	a0,s3
    80004de6:	f1efe0ef          	jal	80003504 <iunlockput>
  iunlockput(dp);
    80004dea:	8526                	mv	a0,s1
    80004dec:	f18fe0ef          	jal	80003504 <iunlockput>
  return 0;
    80004df0:	79a2                	ld	s3,40(sp)
    80004df2:	bf09                	j	80004d04 <create+0x70>
    return 0;
    80004df4:	892a                	mv	s2,a0
    80004df6:	b739                	j	80004d04 <create+0x70>

0000000080004df8 <sys_dup>:
{
    80004df8:	7179                	addi	sp,sp,-48
    80004dfa:	f406                	sd	ra,40(sp)
    80004dfc:	f022                	sd	s0,32(sp)
    80004dfe:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004e00:	fd840613          	addi	a2,s0,-40
    80004e04:	4581                	li	a1,0
    80004e06:	4501                	li	a0,0
    80004e08:	df3ff0ef          	jal	80004bfa <argfd>
    return -1;
    80004e0c:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004e0e:	02054363          	bltz	a0,80004e34 <sys_dup+0x3c>
    80004e12:	ec26                	sd	s1,24(sp)
    80004e14:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004e16:	fd843483          	ld	s1,-40(s0)
    80004e1a:	8526                	mv	a0,s1
    80004e1c:	e39ff0ef          	jal	80004c54 <fdalloc>
    80004e20:	892a                	mv	s2,a0
    return -1;
    80004e22:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004e24:	00054d63          	bltz	a0,80004e3e <sys_dup+0x46>
  filedup(f);
    80004e28:	8526                	mv	a0,s1
    80004e2a:	b72ff0ef          	jal	8000419c <filedup>
  return fd;
    80004e2e:	87ca                	mv	a5,s2
    80004e30:	64e2                	ld	s1,24(sp)
    80004e32:	6942                	ld	s2,16(sp)
}
    80004e34:	853e                	mv	a0,a5
    80004e36:	70a2                	ld	ra,40(sp)
    80004e38:	7402                	ld	s0,32(sp)
    80004e3a:	6145                	addi	sp,sp,48
    80004e3c:	8082                	ret
    80004e3e:	64e2                	ld	s1,24(sp)
    80004e40:	6942                	ld	s2,16(sp)
    80004e42:	bfcd                	j	80004e34 <sys_dup+0x3c>

0000000080004e44 <sys_read>:
{
    80004e44:	7179                	addi	sp,sp,-48
    80004e46:	f406                	sd	ra,40(sp)
    80004e48:	f022                	sd	s0,32(sp)
    80004e4a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e4c:	fd840593          	addi	a1,s0,-40
    80004e50:	4505                	li	a0,1
    80004e52:	a9ffd0ef          	jal	800028f0 <argaddr>
  argint(2, &n);
    80004e56:	fe440593          	addi	a1,s0,-28
    80004e5a:	4509                	li	a0,2
    80004e5c:	a79fd0ef          	jal	800028d4 <argint>
  if (argfd(0, 0, &f) < 0)
    80004e60:	fe840613          	addi	a2,s0,-24
    80004e64:	4581                	li	a1,0
    80004e66:	4501                	li	a0,0
    80004e68:	d93ff0ef          	jal	80004bfa <argfd>
    80004e6c:	87aa                	mv	a5,a0
    return -1;
    80004e6e:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004e70:	0007ca63          	bltz	a5,80004e84 <sys_read+0x40>
  return fileread(f, p, n);
    80004e74:	fe442603          	lw	a2,-28(s0)
    80004e78:	fd843583          	ld	a1,-40(s0)
    80004e7c:	fe843503          	ld	a0,-24(s0)
    80004e80:	c94ff0ef          	jal	80004314 <fileread>
}
    80004e84:	70a2                	ld	ra,40(sp)
    80004e86:	7402                	ld	s0,32(sp)
    80004e88:	6145                	addi	sp,sp,48
    80004e8a:	8082                	ret

0000000080004e8c <sys_write>:
{
    80004e8c:	7179                	addi	sp,sp,-48
    80004e8e:	f406                	sd	ra,40(sp)
    80004e90:	f022                	sd	s0,32(sp)
    80004e92:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e94:	fd840593          	addi	a1,s0,-40
    80004e98:	4505                	li	a0,1
    80004e9a:	a57fd0ef          	jal	800028f0 <argaddr>
  argint(2, &n);
    80004e9e:	fe440593          	addi	a1,s0,-28
    80004ea2:	4509                	li	a0,2
    80004ea4:	a31fd0ef          	jal	800028d4 <argint>
  if (argfd(0, 0, &f) < 0)
    80004ea8:	fe840613          	addi	a2,s0,-24
    80004eac:	4581                	li	a1,0
    80004eae:	4501                	li	a0,0
    80004eb0:	d4bff0ef          	jal	80004bfa <argfd>
    80004eb4:	87aa                	mv	a5,a0
    return -1;
    80004eb6:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004eb8:	0007ca63          	bltz	a5,80004ecc <sys_write+0x40>
  return filewrite(f, p, n);
    80004ebc:	fe442603          	lw	a2,-28(s0)
    80004ec0:	fd843583          	ld	a1,-40(s0)
    80004ec4:	fe843503          	ld	a0,-24(s0)
    80004ec8:	d1aff0ef          	jal	800043e2 <filewrite>
}
    80004ecc:	70a2                	ld	ra,40(sp)
    80004ece:	7402                	ld	s0,32(sp)
    80004ed0:	6145                	addi	sp,sp,48
    80004ed2:	8082                	ret

0000000080004ed4 <sys_close>:
{
    80004ed4:	1101                	addi	sp,sp,-32
    80004ed6:	ec06                	sd	ra,24(sp)
    80004ed8:	e822                	sd	s0,16(sp)
    80004eda:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80004edc:	fe040613          	addi	a2,s0,-32
    80004ee0:	fec40593          	addi	a1,s0,-20
    80004ee4:	4501                	li	a0,0
    80004ee6:	d15ff0ef          	jal	80004bfa <argfd>
    return -1;
    80004eea:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80004eec:	02054163          	bltz	a0,80004f0e <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004ef0:	a59fc0ef          	jal	80001948 <myproc>
    80004ef4:	fec42783          	lw	a5,-20(s0)
    80004ef8:	078e                	slli	a5,a5,0x3
    80004efa:	0d078793          	addi	a5,a5,208
    80004efe:	953e                	add	a0,a0,a5
    80004f00:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004f04:	fe043503          	ld	a0,-32(s0)
    80004f08:	adaff0ef          	jal	800041e2 <fileclose>
  return 0;
    80004f0c:	4781                	li	a5,0
}
    80004f0e:	853e                	mv	a0,a5
    80004f10:	60e2                	ld	ra,24(sp)
    80004f12:	6442                	ld	s0,16(sp)
    80004f14:	6105                	addi	sp,sp,32
    80004f16:	8082                	ret

0000000080004f18 <sys_fstat>:
{
    80004f18:	1101                	addi	sp,sp,-32
    80004f1a:	ec06                	sd	ra,24(sp)
    80004f1c:	e822                	sd	s0,16(sp)
    80004f1e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004f20:	fe040593          	addi	a1,s0,-32
    80004f24:	4505                	li	a0,1
    80004f26:	9cbfd0ef          	jal	800028f0 <argaddr>
  if (argfd(0, 0, &f) < 0)
    80004f2a:	fe840613          	addi	a2,s0,-24
    80004f2e:	4581                	li	a1,0
    80004f30:	4501                	li	a0,0
    80004f32:	cc9ff0ef          	jal	80004bfa <argfd>
    80004f36:	87aa                	mv	a5,a0
    return -1;
    80004f38:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004f3a:	0007c863          	bltz	a5,80004f4a <sys_fstat+0x32>
  return filestat(f, st);
    80004f3e:	fe043583          	ld	a1,-32(s0)
    80004f42:	fe843503          	ld	a0,-24(s0)
    80004f46:	b5eff0ef          	jal	800042a4 <filestat>
}
    80004f4a:	60e2                	ld	ra,24(sp)
    80004f4c:	6442                	ld	s0,16(sp)
    80004f4e:	6105                	addi	sp,sp,32
    80004f50:	8082                	ret

0000000080004f52 <sys_link>:
{
    80004f52:	7169                	addi	sp,sp,-304
    80004f54:	f606                	sd	ra,296(sp)
    80004f56:	f222                	sd	s0,288(sp)
    80004f58:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f5a:	08000613          	li	a2,128
    80004f5e:	ed040593          	addi	a1,s0,-304
    80004f62:	4501                	li	a0,0
    80004f64:	9a9fd0ef          	jal	8000290c <argstr>
    return -1;
    80004f68:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f6a:	10054163          	bltz	a0,8000506c <sys_link+0x11a>
    80004f6e:	08000613          	li	a2,128
    80004f72:	f5040593          	addi	a1,s0,-176
    80004f76:	4505                	li	a0,1
    80004f78:	995fd0ef          	jal	8000290c <argstr>
    return -1;
    80004f7c:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f7e:	0e054763          	bltz	a0,8000506c <sys_link+0x11a>
    80004f82:	ee26                	sd	s1,280(sp)
  begin_op();
    80004f84:	da5fe0ef          	jal	80003d28 <begin_op>
  if ((ip = namei(old)) == 0) {
    80004f88:	ed040513          	addi	a0,s0,-304
    80004f8c:	bbffe0ef          	jal	80003b4a <namei>
    80004f90:	84aa                	mv	s1,a0
    80004f92:	cd35                	beqz	a0,8000500e <sys_link+0xbc>
  ilock(ip);
    80004f94:	b1cfe0ef          	jal	800032b0 <ilock>
  if (ip->type == T_DIR) {
    80004f98:	04449703          	lh	a4,68(s1)
    80004f9c:	4785                	li	a5,1
    80004f9e:	06f70d63          	beq	a4,a5,80005018 <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    80004fa2:	04a49783          	lh	a5,74(s1)
    80004fa6:	6721                	lui	a4,0x8
    80004fa8:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80004faa:	06e78f63          	beq	a5,a4,80005028 <sys_link+0xd6>
    80004fae:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004fb0:	2785                	addiw	a5,a5,1
    80004fb2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004fb6:	8526                	mv	a0,s1
    80004fb8:	a44fe0ef          	jal	800031fc <iupdate>
  iunlock(ip);
    80004fbc:	8526                	mv	a0,s1
    80004fbe:	ba0fe0ef          	jal	8000335e <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80004fc2:	fd040593          	addi	a1,s0,-48
    80004fc6:	f5040513          	addi	a0,s0,-176
    80004fca:	b9bfe0ef          	jal	80003b64 <nameiparent>
    80004fce:	892a                	mv	s2,a0
    80004fd0:	c93d                	beqz	a0,80005046 <sys_link+0xf4>
  ilock(dp);
    80004fd2:	adefe0ef          	jal	800032b0 <ilock>
  if (dp->nlink == 0) {
    80004fd6:	04a91783          	lh	a5,74(s2)
    80004fda:	cfb9                	beqz	a5,80005038 <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    80004fdc:	854a                	mv	a0,s2
    80004fde:	00092703          	lw	a4,0(s2)
    80004fe2:	409c                	lw	a5,0(s1)
    80004fe4:	04f71e63          	bne	a4,a5,80005040 <sys_link+0xee>
    80004fe8:	40d0                	lw	a2,4(s1)
    80004fea:	fd040593          	addi	a1,s0,-48
    80004fee:	ab3fe0ef          	jal	80003aa0 <dirlink>
    80004ff2:	04054763          	bltz	a0,80005040 <sys_link+0xee>
  iunlockput(dp);
    80004ff6:	854a                	mv	a0,s2
    80004ff8:	d0cfe0ef          	jal	80003504 <iunlockput>
  iput(ip);
    80004ffc:	8526                	mv	a0,s1
    80004ffe:	c34fe0ef          	jal	80003432 <iput>
  end_op();
    80005002:	db3fe0ef          	jal	80003db4 <end_op>
  return 0;
    80005006:	4781                	li	a5,0
    80005008:	64f2                	ld	s1,280(sp)
    8000500a:	6952                	ld	s2,272(sp)
    8000500c:	a085                	j	8000506c <sys_link+0x11a>
    end_op();
    8000500e:	da7fe0ef          	jal	80003db4 <end_op>
    return -1;
    80005012:	57fd                	li	a5,-1
    80005014:	64f2                	ld	s1,280(sp)
    80005016:	a899                	j	8000506c <sys_link+0x11a>
    iunlockput(ip);
    80005018:	8526                	mv	a0,s1
    8000501a:	ceafe0ef          	jal	80003504 <iunlockput>
    end_op();
    8000501e:	d97fe0ef          	jal	80003db4 <end_op>
    return -1;
    80005022:	57fd                	li	a5,-1
    80005024:	64f2                	ld	s1,280(sp)
    80005026:	a099                	j	8000506c <sys_link+0x11a>
    iunlockput(ip);
    80005028:	8526                	mv	a0,s1
    8000502a:	cdafe0ef          	jal	80003504 <iunlockput>
    end_op();
    8000502e:	d87fe0ef          	jal	80003db4 <end_op>
    return -1;
    80005032:	57fd                	li	a5,-1
    80005034:	64f2                	ld	s1,280(sp)
    80005036:	a81d                	j	8000506c <sys_link+0x11a>
    iunlockput(dp);
    80005038:	854a                	mv	a0,s2
    8000503a:	ccafe0ef          	jal	80003504 <iunlockput>
    goto bad;
    8000503e:	a021                	j	80005046 <sys_link+0xf4>
    iunlockput(dp);
    80005040:	854a                	mv	a0,s2
    80005042:	cc2fe0ef          	jal	80003504 <iunlockput>
  ilock(ip);
    80005046:	8526                	mv	a0,s1
    80005048:	a68fe0ef          	jal	800032b0 <ilock>
  ip->nlink--;
    8000504c:	04a4d783          	lhu	a5,74(s1)
    80005050:	37fd                	addiw	a5,a5,-1
    80005052:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005056:	8526                	mv	a0,s1
    80005058:	9a4fe0ef          	jal	800031fc <iupdate>
  iunlockput(ip);
    8000505c:	8526                	mv	a0,s1
    8000505e:	ca6fe0ef          	jal	80003504 <iunlockput>
  end_op();
    80005062:	d53fe0ef          	jal	80003db4 <end_op>
  return -1;
    80005066:	57fd                	li	a5,-1
    80005068:	64f2                	ld	s1,280(sp)
    8000506a:	6952                	ld	s2,272(sp)
}
    8000506c:	853e                	mv	a0,a5
    8000506e:	70b2                	ld	ra,296(sp)
    80005070:	7412                	ld	s0,288(sp)
    80005072:	6155                	addi	sp,sp,304
    80005074:	8082                	ret

0000000080005076 <sys_unlink>:
{
    80005076:	7151                	addi	sp,sp,-240
    80005078:	f586                	sd	ra,232(sp)
    8000507a:	f1a2                	sd	s0,224(sp)
    8000507c:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    8000507e:	08000613          	li	a2,128
    80005082:	f3040593          	addi	a1,s0,-208
    80005086:	4501                	li	a0,0
    80005088:	885fd0ef          	jal	8000290c <argstr>
    8000508c:	14054d63          	bltz	a0,800051e6 <sys_unlink+0x170>
    80005090:	eda6                	sd	s1,216(sp)
  begin_op();
    80005092:	c97fe0ef          	jal	80003d28 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    80005096:	fb040593          	addi	a1,s0,-80
    8000509a:	f3040513          	addi	a0,s0,-208
    8000509e:	ac7fe0ef          	jal	80003b64 <nameiparent>
    800050a2:	84aa                	mv	s1,a0
    800050a4:	c955                	beqz	a0,80005158 <sys_unlink+0xe2>
  ilock(dp);
    800050a6:	a0afe0ef          	jal	800032b0 <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800050aa:	00002597          	auipc	a1,0x2
    800050ae:	57658593          	addi	a1,a1,1398 # 80007620 <etext+0x620>
    800050b2:	fb040513          	addi	a0,s0,-80
    800050b6:	fccfe0ef          	jal	80003882 <namecmp>
    800050ba:	10050b63          	beqz	a0,800051d0 <sys_unlink+0x15a>
    800050be:	00002597          	auipc	a1,0x2
    800050c2:	56a58593          	addi	a1,a1,1386 # 80007628 <etext+0x628>
    800050c6:	fb040513          	addi	a0,s0,-80
    800050ca:	fb8fe0ef          	jal	80003882 <namecmp>
    800050ce:	10050163          	beqz	a0,800051d0 <sys_unlink+0x15a>
    800050d2:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    800050d4:	f2c40613          	addi	a2,s0,-212
    800050d8:	fb040593          	addi	a1,s0,-80
    800050dc:	8526                	mv	a0,s1
    800050de:	fbafe0ef          	jal	80003898 <dirlookup>
    800050e2:	892a                	mv	s2,a0
    800050e4:	0e050563          	beqz	a0,800051ce <sys_unlink+0x158>
    800050e8:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    800050ea:	9c6fe0ef          	jal	800032b0 <ilock>
  if (ip->nlink < 1)
    800050ee:	04a91783          	lh	a5,74(s2)
    800050f2:	06f05863          	blez	a5,80005162 <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    800050f6:	04491703          	lh	a4,68(s2)
    800050fa:	4785                	li	a5,1
    800050fc:	06f70963          	beq	a4,a5,8000516e <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005100:	fc040993          	addi	s3,s0,-64
    80005104:	4641                	li	a2,16
    80005106:	4581                	li	a1,0
    80005108:	854e                	mv	a0,s3
    8000510a:	bdffb0ef          	jal	80000ce8 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000510e:	4741                	li	a4,16
    80005110:	f2c42683          	lw	a3,-212(s0)
    80005114:	864e                	mv	a2,s3
    80005116:	4581                	li	a1,0
    80005118:	8526                	mv	a0,s1
    8000511a:	e62fe0ef          	jal	8000377c <writei>
    8000511e:	47c1                	li	a5,16
    80005120:	08f51863          	bne	a0,a5,800051b0 <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    80005124:	04491703          	lh	a4,68(s2)
    80005128:	4785                	li	a5,1
    8000512a:	08f70963          	beq	a4,a5,800051bc <sys_unlink+0x146>
  iunlockput(dp);
    8000512e:	8526                	mv	a0,s1
    80005130:	bd4fe0ef          	jal	80003504 <iunlockput>
  ip->nlink--;
    80005134:	04a95783          	lhu	a5,74(s2)
    80005138:	37fd                	addiw	a5,a5,-1
    8000513a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000513e:	854a                	mv	a0,s2
    80005140:	8bcfe0ef          	jal	800031fc <iupdate>
  iunlockput(ip);
    80005144:	854a                	mv	a0,s2
    80005146:	bbefe0ef          	jal	80003504 <iunlockput>
  end_op();
    8000514a:	c6bfe0ef          	jal	80003db4 <end_op>
  return 0;
    8000514e:	4501                	li	a0,0
    80005150:	64ee                	ld	s1,216(sp)
    80005152:	694e                	ld	s2,208(sp)
    80005154:	69ae                	ld	s3,200(sp)
    80005156:	a061                	j	800051de <sys_unlink+0x168>
    end_op();
    80005158:	c5dfe0ef          	jal	80003db4 <end_op>
    return -1;
    8000515c:	557d                	li	a0,-1
    8000515e:	64ee                	ld	s1,216(sp)
    80005160:	a8bd                	j	800051de <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005162:	00002517          	auipc	a0,0x2
    80005166:	4ce50513          	addi	a0,a0,1230 # 80007630 <etext+0x630>
    8000516a:	ecafb0ef          	jal	80000834 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    8000516e:	04c92703          	lw	a4,76(s2)
    80005172:	02000793          	li	a5,32
    80005176:	f8e7f5e3          	bgeu	a5,a4,80005100 <sys_unlink+0x8a>
    8000517a:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000517c:	4741                	li	a4,16
    8000517e:	86ce                	mv	a3,s3
    80005180:	f1840613          	addi	a2,s0,-232
    80005184:	4581                	li	a1,0
    80005186:	854a                	mv	a0,s2
    80005188:	d02fe0ef          	jal	8000368a <readi>
    8000518c:	47c1                	li	a5,16
    8000518e:	00f51b63          	bne	a0,a5,800051a4 <sys_unlink+0x12e>
    if (de.inum != 0)
    80005192:	f1845783          	lhu	a5,-232(s0)
    80005196:	ebb1                	bnez	a5,800051ea <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80005198:	29c1                	addiw	s3,s3,16
    8000519a:	04c92783          	lw	a5,76(s2)
    8000519e:	fcf9efe3          	bltu	s3,a5,8000517c <sys_unlink+0x106>
    800051a2:	bfb9                	j	80005100 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800051a4:	00002517          	auipc	a0,0x2
    800051a8:	4a450513          	addi	a0,a0,1188 # 80007648 <etext+0x648>
    800051ac:	e88fb0ef          	jal	80000834 <panic>
    panic("unlink: writei");
    800051b0:	00002517          	auipc	a0,0x2
    800051b4:	4b050513          	addi	a0,a0,1200 # 80007660 <etext+0x660>
    800051b8:	e7cfb0ef          	jal	80000834 <panic>
    dp->nlink--;
    800051bc:	04a4d783          	lhu	a5,74(s1)
    800051c0:	37fd                	addiw	a5,a5,-1
    800051c2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800051c6:	8526                	mv	a0,s1
    800051c8:	834fe0ef          	jal	800031fc <iupdate>
    800051cc:	b78d                	j	8000512e <sys_unlink+0xb8>
    800051ce:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800051d0:	8526                	mv	a0,s1
    800051d2:	b32fe0ef          	jal	80003504 <iunlockput>
  end_op();
    800051d6:	bdffe0ef          	jal	80003db4 <end_op>
  return -1;
    800051da:	557d                	li	a0,-1
    800051dc:	64ee                	ld	s1,216(sp)
}
    800051de:	70ae                	ld	ra,232(sp)
    800051e0:	740e                	ld	s0,224(sp)
    800051e2:	616d                	addi	sp,sp,240
    800051e4:	8082                	ret
    return -1;
    800051e6:	557d                	li	a0,-1
    800051e8:	bfdd                	j	800051de <sys_unlink+0x168>
    iunlockput(ip);
    800051ea:	854a                	mv	a0,s2
    800051ec:	b18fe0ef          	jal	80003504 <iunlockput>
    goto bad;
    800051f0:	694e                	ld	s2,208(sp)
    800051f2:	69ae                	ld	s3,200(sp)
    800051f4:	bff1                	j	800051d0 <sys_unlink+0x15a>

00000000800051f6 <sys_open>:

uint64
sys_open(void)
{
    800051f6:	7131                	addi	sp,sp,-192
    800051f8:	fd06                	sd	ra,184(sp)
    800051fa:	f922                	sd	s0,176(sp)
    800051fc:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800051fe:	f4c40593          	addi	a1,s0,-180
    80005202:	4505                	li	a0,1
    80005204:	ed0fd0ef          	jal	800028d4 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005208:	08000613          	li	a2,128
    8000520c:	f5040593          	addi	a1,s0,-176
    80005210:	4501                	li	a0,0
    80005212:	efafd0ef          	jal	8000290c <argstr>
    80005216:	87aa                	mv	a5,a0
    return -1;
    80005218:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    8000521a:	0a07c363          	bltz	a5,800052c0 <sys_open+0xca>
    8000521e:	f526                	sd	s1,168(sp)

  begin_op();
    80005220:	b09fe0ef          	jal	80003d28 <begin_op>

  if (omode & O_CREATE) {
    80005224:	f4c42783          	lw	a5,-180(s0)
    80005228:	2007f793          	andi	a5,a5,512
    8000522c:	c3dd                	beqz	a5,800052d2 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    8000522e:	4681                	li	a3,0
    80005230:	4601                	li	a2,0
    80005232:	4589                	li	a1,2
    80005234:	f5040513          	addi	a0,s0,-176
    80005238:	a5dff0ef          	jal	80004c94 <create>
    8000523c:	84aa                	mv	s1,a0
    if (ip == 0) {
    8000523e:	c549                	beqz	a0,800052c8 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    80005240:	04449703          	lh	a4,68(s1)
    80005244:	478d                	li	a5,3
    80005246:	00f71763          	bne	a4,a5,80005254 <sys_open+0x5e>
    8000524a:	0464d703          	lhu	a4,70(s1)
    8000524e:	47a5                	li	a5,9
    80005250:	0ae7ee63          	bltu	a5,a4,8000530c <sys_open+0x116>
    80005254:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    80005256:	ee9fe0ef          	jal	8000413e <filealloc>
    8000525a:	892a                	mv	s2,a0
    8000525c:	c561                	beqz	a0,80005324 <sys_open+0x12e>
    8000525e:	ed4e                	sd	s3,152(sp)
    80005260:	9f5ff0ef          	jal	80004c54 <fdalloc>
    80005264:	89aa                	mv	s3,a0
    80005266:	0a054b63          	bltz	a0,8000531c <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    8000526a:	04449703          	lh	a4,68(s1)
    8000526e:	478d                	li	a5,3
    80005270:	0cf70363          	beq	a4,a5,80005336 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005274:	4789                	li	a5,2
    80005276:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000527a:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000527e:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005282:	f4c42783          	lw	a5,-180(s0)
    80005286:	0017f713          	andi	a4,a5,1
    8000528a:	00174713          	xori	a4,a4,1
    8000528e:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005292:	0037f713          	andi	a4,a5,3
    80005296:	00e03733          	snez	a4,a4
    8000529a:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    8000529e:	4007f793          	andi	a5,a5,1024
    800052a2:	c791                	beqz	a5,800052ae <sys_open+0xb8>
    800052a4:	04449703          	lh	a4,68(s1)
    800052a8:	4789                	li	a5,2
    800052aa:	08f70d63          	beq	a4,a5,80005344 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800052ae:	8526                	mv	a0,s1
    800052b0:	8aefe0ef          	jal	8000335e <iunlock>
  end_op();
    800052b4:	b01fe0ef          	jal	80003db4 <end_op>

  return fd;
    800052b8:	854e                	mv	a0,s3
    800052ba:	74aa                	ld	s1,168(sp)
    800052bc:	790a                	ld	s2,160(sp)
    800052be:	69ea                	ld	s3,152(sp)
}
    800052c0:	70ea                	ld	ra,184(sp)
    800052c2:	744a                	ld	s0,176(sp)
    800052c4:	6129                	addi	sp,sp,192
    800052c6:	8082                	ret
      end_op();
    800052c8:	aedfe0ef          	jal	80003db4 <end_op>
      return -1;
    800052cc:	557d                	li	a0,-1
    800052ce:	74aa                	ld	s1,168(sp)
    800052d0:	bfc5                	j	800052c0 <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    800052d2:	f5040513          	addi	a0,s0,-176
    800052d6:	875fe0ef          	jal	80003b4a <namei>
    800052da:	84aa                	mv	s1,a0
    800052dc:	c11d                	beqz	a0,80005302 <sys_open+0x10c>
    ilock(ip);
    800052de:	fd3fd0ef          	jal	800032b0 <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    800052e2:	04449703          	lh	a4,68(s1)
    800052e6:	4785                	li	a5,1
    800052e8:	f4f71ce3          	bne	a4,a5,80005240 <sys_open+0x4a>
    800052ec:	f4c42783          	lw	a5,-180(s0)
    800052f0:	d3b5                	beqz	a5,80005254 <sys_open+0x5e>
      iunlockput(ip);
    800052f2:	8526                	mv	a0,s1
    800052f4:	a10fe0ef          	jal	80003504 <iunlockput>
      end_op();
    800052f8:	abdfe0ef          	jal	80003db4 <end_op>
      return -1;
    800052fc:	557d                	li	a0,-1
    800052fe:	74aa                	ld	s1,168(sp)
    80005300:	b7c1                	j	800052c0 <sys_open+0xca>
      end_op();
    80005302:	ab3fe0ef          	jal	80003db4 <end_op>
      return -1;
    80005306:	557d                	li	a0,-1
    80005308:	74aa                	ld	s1,168(sp)
    8000530a:	bf5d                	j	800052c0 <sys_open+0xca>
    iunlockput(ip);
    8000530c:	8526                	mv	a0,s1
    8000530e:	9f6fe0ef          	jal	80003504 <iunlockput>
    end_op();
    80005312:	aa3fe0ef          	jal	80003db4 <end_op>
    return -1;
    80005316:	557d                	li	a0,-1
    80005318:	74aa                	ld	s1,168(sp)
    8000531a:	b75d                	j	800052c0 <sys_open+0xca>
      fileclose(f);
    8000531c:	854a                	mv	a0,s2
    8000531e:	ec5fe0ef          	jal	800041e2 <fileclose>
    80005322:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005324:	8526                	mv	a0,s1
    80005326:	9defe0ef          	jal	80003504 <iunlockput>
    end_op();
    8000532a:	a8bfe0ef          	jal	80003db4 <end_op>
    return -1;
    8000532e:	557d                	li	a0,-1
    80005330:	74aa                	ld	s1,168(sp)
    80005332:	790a                	ld	s2,160(sp)
    80005334:	b771                	j	800052c0 <sys_open+0xca>
    f->type = FD_DEVICE;
    80005336:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    8000533a:	04649783          	lh	a5,70(s1)
    8000533e:	02f91223          	sh	a5,36(s2)
    80005342:	bf35                	j	8000527e <sys_open+0x88>
    itrunc(ip);
    80005344:	8526                	mv	a0,s1
    80005346:	858fe0ef          	jal	8000339e <itrunc>
    8000534a:	b795                	j	800052ae <sys_open+0xb8>

000000008000534c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000534c:	7175                	addi	sp,sp,-144
    8000534e:	e506                	sd	ra,136(sp)
    80005350:	e122                	sd	s0,128(sp)
    80005352:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005354:	9d5fe0ef          	jal	80003d28 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    80005358:	08000613          	li	a2,128
    8000535c:	f7040593          	addi	a1,s0,-144
    80005360:	4501                	li	a0,0
    80005362:	daafd0ef          	jal	8000290c <argstr>
    80005366:	02054363          	bltz	a0,8000538c <sys_mkdir+0x40>
    8000536a:	4681                	li	a3,0
    8000536c:	4601                	li	a2,0
    8000536e:	4585                	li	a1,1
    80005370:	f7040513          	addi	a0,s0,-144
    80005374:	921ff0ef          	jal	80004c94 <create>
    80005378:	c911                	beqz	a0,8000538c <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000537a:	98afe0ef          	jal	80003504 <iunlockput>
  end_op();
    8000537e:	a37fe0ef          	jal	80003db4 <end_op>
  return 0;
    80005382:	4501                	li	a0,0
}
    80005384:	60aa                	ld	ra,136(sp)
    80005386:	640a                	ld	s0,128(sp)
    80005388:	6149                	addi	sp,sp,144
    8000538a:	8082                	ret
    end_op();
    8000538c:	a29fe0ef          	jal	80003db4 <end_op>
    return -1;
    80005390:	557d                	li	a0,-1
    80005392:	bfcd                	j	80005384 <sys_mkdir+0x38>

0000000080005394 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005394:	7135                	addi	sp,sp,-160
    80005396:	ed06                	sd	ra,152(sp)
    80005398:	e922                	sd	s0,144(sp)
    8000539a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000539c:	98dfe0ef          	jal	80003d28 <begin_op>
  argint(1, &major);
    800053a0:	f6c40593          	addi	a1,s0,-148
    800053a4:	4505                	li	a0,1
    800053a6:	d2efd0ef          	jal	800028d4 <argint>
  argint(2, &minor);
    800053aa:	f6840593          	addi	a1,s0,-152
    800053ae:	4509                	li	a0,2
    800053b0:	d24fd0ef          	jal	800028d4 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800053b4:	08000613          	li	a2,128
    800053b8:	f7040593          	addi	a1,s0,-144
    800053bc:	4501                	li	a0,0
    800053be:	d4efd0ef          	jal	8000290c <argstr>
    800053c2:	02054563          	bltz	a0,800053ec <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    800053c6:	f6841683          	lh	a3,-152(s0)
    800053ca:	f6c41603          	lh	a2,-148(s0)
    800053ce:	458d                	li	a1,3
    800053d0:	f7040513          	addi	a0,s0,-144
    800053d4:	8c1ff0ef          	jal	80004c94 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800053d8:	c911                	beqz	a0,800053ec <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800053da:	92afe0ef          	jal	80003504 <iunlockput>
  end_op();
    800053de:	9d7fe0ef          	jal	80003db4 <end_op>
  return 0;
    800053e2:	4501                	li	a0,0
}
    800053e4:	60ea                	ld	ra,152(sp)
    800053e6:	644a                	ld	s0,144(sp)
    800053e8:	610d                	addi	sp,sp,160
    800053ea:	8082                	ret
    end_op();
    800053ec:	9c9fe0ef          	jal	80003db4 <end_op>
    return -1;
    800053f0:	557d                	li	a0,-1
    800053f2:	bfcd                	j	800053e4 <sys_mknod+0x50>

00000000800053f4 <sys_chdir>:

uint64
sys_chdir(void)
{
    800053f4:	7135                	addi	sp,sp,-160
    800053f6:	ed06                	sd	ra,152(sp)
    800053f8:	e922                	sd	s0,144(sp)
    800053fa:	e14a                	sd	s2,128(sp)
    800053fc:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800053fe:	d4afc0ef          	jal	80001948 <myproc>
    80005402:	892a                	mv	s2,a0

  begin_op();
    80005404:	925fe0ef          	jal	80003d28 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    80005408:	08000613          	li	a2,128
    8000540c:	f6040593          	addi	a1,s0,-160
    80005410:	4501                	li	a0,0
    80005412:	cfafd0ef          	jal	8000290c <argstr>
    80005416:	04054363          	bltz	a0,8000545c <sys_chdir+0x68>
    8000541a:	e526                	sd	s1,136(sp)
    8000541c:	f6040513          	addi	a0,s0,-160
    80005420:	f2afe0ef          	jal	80003b4a <namei>
    80005424:	84aa                	mv	s1,a0
    80005426:	c915                	beqz	a0,8000545a <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005428:	e89fd0ef          	jal	800032b0 <ilock>
  if (ip->type != T_DIR) {
    8000542c:	04449703          	lh	a4,68(s1)
    80005430:	4785                	li	a5,1
    80005432:	02f71963          	bne	a4,a5,80005464 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005436:	8526                	mv	a0,s1
    80005438:	f27fd0ef          	jal	8000335e <iunlock>
  iput(p->cwd);
    8000543c:	15093503          	ld	a0,336(s2)
    80005440:	ff3fd0ef          	jal	80003432 <iput>
  end_op();
    80005444:	971fe0ef          	jal	80003db4 <end_op>
  p->cwd = ip;
    80005448:	14993823          	sd	s1,336(s2)
  return 0;
    8000544c:	4501                	li	a0,0
    8000544e:	64aa                	ld	s1,136(sp)
}
    80005450:	60ea                	ld	ra,152(sp)
    80005452:	644a                	ld	s0,144(sp)
    80005454:	690a                	ld	s2,128(sp)
    80005456:	610d                	addi	sp,sp,160
    80005458:	8082                	ret
    8000545a:	64aa                	ld	s1,136(sp)
    end_op();
    8000545c:	959fe0ef          	jal	80003db4 <end_op>
    return -1;
    80005460:	557d                	li	a0,-1
    80005462:	b7fd                	j	80005450 <sys_chdir+0x5c>
    iunlockput(ip);
    80005464:	8526                	mv	a0,s1
    80005466:	89efe0ef          	jal	80003504 <iunlockput>
    end_op();
    8000546a:	94bfe0ef          	jal	80003db4 <end_op>
    return -1;
    8000546e:	557d                	li	a0,-1
    80005470:	64aa                	ld	s1,136(sp)
    80005472:	bff9                	j	80005450 <sys_chdir+0x5c>

0000000080005474 <sys_exec>:

uint64
sys_exec(void)
{
    80005474:	7105                	addi	sp,sp,-480
    80005476:	ef86                	sd	ra,472(sp)
    80005478:	eba2                	sd	s0,464(sp)
    8000547a:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000547c:	e2840593          	addi	a1,s0,-472
    80005480:	4505                	li	a0,1
    80005482:	c6efd0ef          	jal	800028f0 <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    80005486:	08000613          	li	a2,128
    8000548a:	f3040593          	addi	a1,s0,-208
    8000548e:	4501                	li	a0,0
    80005490:	c7cfd0ef          	jal	8000290c <argstr>
    80005494:	87aa                	mv	a5,a0
    return -1;
    80005496:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    80005498:	0e07c063          	bltz	a5,80005578 <sys_exec+0x104>
    8000549c:	e7a6                	sd	s1,456(sp)
    8000549e:	e3ca                	sd	s2,448(sp)
    800054a0:	ff4e                	sd	s3,440(sp)
    800054a2:	fb52                	sd	s4,432(sp)
    800054a4:	f756                	sd	s5,424(sp)
    800054a6:	f35a                	sd	s6,416(sp)
    800054a8:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800054aa:	e3040a13          	addi	s4,s0,-464
    800054ae:	10000613          	li	a2,256
    800054b2:	4581                	li	a1,0
    800054b4:	8552                	mv	a0,s4
    800054b6:	833fb0ef          	jal	80000ce8 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    800054ba:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800054bc:	89d2                	mv	s3,s4
    800054be:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    800054c0:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800054c4:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    800054c6:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    800054ca:	00391513          	slli	a0,s2,0x3
    800054ce:	85d6                	mv	a1,s5
    800054d0:	e2843783          	ld	a5,-472(s0)
    800054d4:	953e                	add	a0,a0,a5
    800054d6:	b72fd0ef          	jal	80002848 <fetchaddr>
    800054da:	02054663          	bltz	a0,80005506 <sys_exec+0x92>
    if (uarg == 0) {
    800054de:	e2043783          	ld	a5,-480(s0)
    800054e2:	c7a1                	beqz	a5,8000552a <sys_exec+0xb6>
    argv[i] = kalloc();
    800054e4:	e6afb0ef          	jal	80000b4e <kalloc>
    800054e8:	85aa                	mv	a1,a0
    800054ea:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    800054ee:	cd01                	beqz	a0,80005506 <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800054f0:	865a                	mv	a2,s6
    800054f2:	e2043503          	ld	a0,-480(s0)
    800054f6:	b9cfd0ef          	jal	80002892 <fetchstr>
    800054fa:	00054663          	bltz	a0,80005506 <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    800054fe:	0905                	addi	s2,s2,1
    80005500:	09a1                	addi	s3,s3,8
    80005502:	fd7914e3          	bne	s2,s7,800054ca <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005506:	100a0a13          	addi	s4,s4,256
    8000550a:	6088                	ld	a0,0(s1)
    8000550c:	cd31                	beqz	a0,80005568 <sys_exec+0xf4>
    kfree(argv[i]);
    8000550e:	d58fb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005512:	04a1                	addi	s1,s1,8
    80005514:	ff449be3          	bne	s1,s4,8000550a <sys_exec+0x96>
  return -1;
    80005518:	557d                	li	a0,-1
    8000551a:	64be                	ld	s1,456(sp)
    8000551c:	691e                	ld	s2,448(sp)
    8000551e:	79fa                	ld	s3,440(sp)
    80005520:	7a5a                	ld	s4,432(sp)
    80005522:	7aba                	ld	s5,424(sp)
    80005524:	7b1a                	ld	s6,416(sp)
    80005526:	6bfa                	ld	s7,408(sp)
    80005528:	a881                	j	80005578 <sys_exec+0x104>
      argv[i] = 0;
    8000552a:	0009079b          	sext.w	a5,s2
    8000552e:	e3040593          	addi	a1,s0,-464
    80005532:	078e                	slli	a5,a5,0x3
    80005534:	97ae                	add	a5,a5,a1
    80005536:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    8000553a:	f3040513          	addi	a0,s0,-208
    8000553e:	b62ff0ef          	jal	800048a0 <kexec>
    80005542:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005544:	100a0a13          	addi	s4,s4,256
    80005548:	6088                	ld	a0,0(s1)
    8000554a:	c511                	beqz	a0,80005556 <sys_exec+0xe2>
    kfree(argv[i]);
    8000554c:	d1afb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005550:	04a1                	addi	s1,s1,8
    80005552:	ff449be3          	bne	s1,s4,80005548 <sys_exec+0xd4>
  return ret;
    80005556:	854a                	mv	a0,s2
    80005558:	64be                	ld	s1,456(sp)
    8000555a:	691e                	ld	s2,448(sp)
    8000555c:	79fa                	ld	s3,440(sp)
    8000555e:	7a5a                	ld	s4,432(sp)
    80005560:	7aba                	ld	s5,424(sp)
    80005562:	7b1a                	ld	s6,416(sp)
    80005564:	6bfa                	ld	s7,408(sp)
    80005566:	a809                	j	80005578 <sys_exec+0x104>
  return -1;
    80005568:	557d                	li	a0,-1
    8000556a:	64be                	ld	s1,456(sp)
    8000556c:	691e                	ld	s2,448(sp)
    8000556e:	79fa                	ld	s3,440(sp)
    80005570:	7a5a                	ld	s4,432(sp)
    80005572:	7aba                	ld	s5,424(sp)
    80005574:	7b1a                	ld	s6,416(sp)
    80005576:	6bfa                	ld	s7,408(sp)
}
    80005578:	60fe                	ld	ra,472(sp)
    8000557a:	645e                	ld	s0,464(sp)
    8000557c:	613d                	addi	sp,sp,480
    8000557e:	8082                	ret

0000000080005580 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005580:	7139                	addi	sp,sp,-64
    80005582:	fc06                	sd	ra,56(sp)
    80005584:	f822                	sd	s0,48(sp)
    80005586:	f426                	sd	s1,40(sp)
    80005588:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000558a:	bbefc0ef          	jal	80001948 <myproc>
    8000558e:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005590:	fd840593          	addi	a1,s0,-40
    80005594:	4501                	li	a0,0
    80005596:	b5afd0ef          	jal	800028f0 <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    8000559a:	fc840593          	addi	a1,s0,-56
    8000559e:	fd040513          	addi	a0,s0,-48
    800055a2:	f7ffe0ef          	jal	80004520 <pipealloc>
    return -1;
    800055a6:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    800055a8:	0a054963          	bltz	a0,8000565a <sys_pipe+0xda>
  fd0 = -1;
    800055ac:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    800055b0:	fd043503          	ld	a0,-48(s0)
    800055b4:	ea0ff0ef          	jal	80004c54 <fdalloc>
    800055b8:	fca42223          	sw	a0,-60(s0)
    800055bc:	08054663          	bltz	a0,80005648 <sys_pipe+0xc8>
    800055c0:	fc843503          	ld	a0,-56(s0)
    800055c4:	e90ff0ef          	jal	80004c54 <fdalloc>
    800055c8:	fca42023          	sw	a0,-64(s0)
    800055cc:	06054463          	bltz	a0,80005634 <sys_pipe+0xb4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800055d0:	4711                	li	a4,4
    800055d2:	fc440693          	addi	a3,s0,-60
    800055d6:	fd843603          	ld	a2,-40(s0)
    800055da:	64ac                	ld	a1,72(s1)
    800055dc:	68a8                	ld	a0,80(s1)
    800055de:	fa5fb0ef          	jal	80001582 <copyout>
    800055e2:	00054f63          	bltz	a0,80005600 <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    800055e6:	4711                	li	a4,4
    800055e8:	fc040693          	addi	a3,s0,-64
    800055ec:	fd843603          	ld	a2,-40(s0)
    800055f0:	963a                	add	a2,a2,a4
    800055f2:	64ac                	ld	a1,72(s1)
    800055f4:	68a8                	ld	a0,80(s1)
    800055f6:	f8dfb0ef          	jal	80001582 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800055fa:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800055fc:	04055f63          	bgez	a0,8000565a <sys_pipe+0xda>
    p->ofile[fd0] = 0;
    80005600:	fc442783          	lw	a5,-60(s0)
    80005604:	078e                	slli	a5,a5,0x3
    80005606:	0d078793          	addi	a5,a5,208
    8000560a:	97a6                	add	a5,a5,s1
    8000560c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005610:	fc042783          	lw	a5,-64(s0)
    80005614:	078e                	slli	a5,a5,0x3
    80005616:	0d078793          	addi	a5,a5,208
    8000561a:	94be                	add	s1,s1,a5
    8000561c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005620:	fd043503          	ld	a0,-48(s0)
    80005624:	bbffe0ef          	jal	800041e2 <fileclose>
    fileclose(wf);
    80005628:	fc843503          	ld	a0,-56(s0)
    8000562c:	bb7fe0ef          	jal	800041e2 <fileclose>
    return -1;
    80005630:	57fd                	li	a5,-1
    80005632:	a025                	j	8000565a <sys_pipe+0xda>
    if (fd0 >= 0)
    80005634:	fc442783          	lw	a5,-60(s0)
    80005638:	0007c863          	bltz	a5,80005648 <sys_pipe+0xc8>
      p->ofile[fd0] = 0;
    8000563c:	078e                	slli	a5,a5,0x3
    8000563e:	0d078793          	addi	a5,a5,208
    80005642:	97a6                	add	a5,a5,s1
    80005644:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005648:	fd043503          	ld	a0,-48(s0)
    8000564c:	b97fe0ef          	jal	800041e2 <fileclose>
    fileclose(wf);
    80005650:	fc843503          	ld	a0,-56(s0)
    80005654:	b8ffe0ef          	jal	800041e2 <fileclose>
    return -1;
    80005658:	57fd                	li	a5,-1
}
    8000565a:	853e                	mv	a0,a5
    8000565c:	70e2                	ld	ra,56(sp)
    8000565e:	7442                	ld	s0,48(sp)
    80005660:	74a2                	ld	s1,40(sp)
    80005662:	6121                	addi	sp,sp,64
    80005664:	8082                	ret
	...

0000000080005670 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005670:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005672:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005674:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    80005676:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005678:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000567a:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000567c:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    8000567e:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005680:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005682:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005684:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005686:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005688:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000568a:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000568c:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    8000568e:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005690:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005692:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005694:	8c2fd0ef          	jal	80002756 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005698:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000569a:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000569c:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    8000569e:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800056a0:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800056a2:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800056a4:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800056a6:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800056a8:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800056aa:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800056ac:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800056ae:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800056b0:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800056b2:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800056b4:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800056b6:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800056b8:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800056ba:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800056bc:	10200073          	sret
    800056c0:	0001                	nop
    800056c2:	00000013          	nop
    800056c6:	00000013          	nop
    800056ca:	00000013          	nop

00000000800056ce <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800056ce:	1141                	addi	sp,sp,-16
    800056d0:	e406                	sd	ra,8(sp)
    800056d2:	e022                	sd	s0,0(sp)
    800056d4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(volatile uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    800056d6:	0c000737          	lui	a4,0xc000
    800056da:	4785                	li	a5,1
    800056dc:	d71c                	sw	a5,40(a4)
  *(volatile uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    800056de:	c35c                	sw	a5,4(a4)
}
    800056e0:	60a2                	ld	ra,8(sp)
    800056e2:	6402                	ld	s0,0(sp)
    800056e4:	0141                	addi	sp,sp,16
    800056e6:	8082                	ret

00000000800056e8 <plicinithart>:

void
plicinithart(void)
{
    800056e8:	1141                	addi	sp,sp,-16
    800056ea:	e406                	sd	ra,8(sp)
    800056ec:	e022                	sd	s0,0(sp)
    800056ee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800056f0:	a24fc0ef          	jal	80001914 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(volatile uint32 *)PLIC_SENABLE(hart) =
    800056f4:	0085179b          	slliw	a5,a0,0x8
    800056f8:	0c002737          	lui	a4,0xc002
    800056fc:	08070713          	addi	a4,a4,128 # c002080 <_entry-0x73ffdf80>
    80005700:	97ba                	add	a5,a5,a4
    80005702:	40200713          	li	a4,1026
    80005706:	c398                	sw	a4,0(a5)
    (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);

  // set this hart's S-mode priority threshold to 0.
  *(volatile uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005708:	00d5151b          	slliw	a0,a0,0xd
    8000570c:	0c2017b7          	lui	a5,0xc201
    80005710:	953e                	add	a0,a0,a5
    80005712:	00052023          	sw	zero,0(a0)
}
    80005716:	60a2                	ld	ra,8(sp)
    80005718:	6402                	ld	s0,0(sp)
    8000571a:	0141                	addi	sp,sp,16
    8000571c:	8082                	ret

000000008000571e <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000571e:	1141                	addi	sp,sp,-16
    80005720:	e406                	sd	ra,8(sp)
    80005722:	e022                	sd	s0,0(sp)
    80005724:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005726:	9eefc0ef          	jal	80001914 <cpuid>
  int irq = *(volatile uint32 *)PLIC_SCLAIM(hart);
    8000572a:	00d5151b          	slliw	a0,a0,0xd
    8000572e:	0c2017b7          	lui	a5,0xc201
    80005732:	0791                	addi	a5,a5,4 # c201004 <_entry-0x73dfeffc>
    80005734:	953e                	add	a0,a0,a5
    80005736:	4108                	lw	a0,0(a0)
  return irq;
}
    80005738:	60a2                	ld	ra,8(sp)
    8000573a:	6402                	ld	s0,0(sp)
    8000573c:	0141                	addi	sp,sp,16
    8000573e:	8082                	ret

0000000080005740 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005740:	1101                	addi	sp,sp,-32
    80005742:	ec06                	sd	ra,24(sp)
    80005744:	e822                	sd	s0,16(sp)
    80005746:	e426                	sd	s1,8(sp)
    80005748:	1000                	addi	s0,sp,32
    8000574a:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000574c:	9c8fc0ef          	jal	80001914 <cpuid>
  *(volatile uint32 *)PLIC_SCLAIM(hart) = irq;
    80005750:	00d5179b          	slliw	a5,a0,0xd
    80005754:	0c201737          	lui	a4,0xc201
    80005758:	0711                	addi	a4,a4,4 # c201004 <_entry-0x73dfeffc>
    8000575a:	97ba                	add	a5,a5,a4
    8000575c:	c384                	sw	s1,0(a5)
}
    8000575e:	60e2                	ld	ra,24(sp)
    80005760:	6442                	ld	s0,16(sp)
    80005762:	64a2                	ld	s1,8(sp)
    80005764:	6105                	addi	sp,sp,32
    80005766:	8082                	ret

0000000080005768 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005768:	1141                	addi	sp,sp,-16
    8000576a:	e406                	sd	ra,8(sp)
    8000576c:	e022                	sd	s0,0(sp)
    8000576e:	0800                	addi	s0,sp,16
  if (i >= NUM)
    80005770:	479d                	li	a5,7
    80005772:	04a7ca63          	blt	a5,a0,800057c6 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    80005776:	0001e797          	auipc	a5,0x1e
    8000577a:	fc278793          	addi	a5,a5,-62 # 80023738 <disk>
    8000577e:	97aa                	add	a5,a5,a0
    80005780:	0187c783          	lbu	a5,24(a5)
    80005784:	e7b9                	bnez	a5,800057d2 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005786:	00451693          	slli	a3,a0,0x4
    8000578a:	0001e797          	auipc	a5,0x1e
    8000578e:	fae78793          	addi	a5,a5,-82 # 80023738 <disk>
    80005792:	6398                	ld	a4,0(a5)
    80005794:	9736                	add	a4,a4,a3
    80005796:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000579a:	6398                	ld	a4,0(a5)
    8000579c:	9736                	add	a4,a4,a3
    8000579e:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800057a2:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800057a6:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800057aa:	97aa                	add	a5,a5,a0
    800057ac:	4705                	li	a4,1
    800057ae:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800057b2:	0001e517          	auipc	a0,0x1e
    800057b6:	f9e50513          	addi	a0,a0,-98 # 80023750 <disk+0x18>
    800057ba:	809fc0ef          	jal	80001fc2 <wakeup>
}
    800057be:	60a2                	ld	ra,8(sp)
    800057c0:	6402                	ld	s0,0(sp)
    800057c2:	0141                	addi	sp,sp,16
    800057c4:	8082                	ret
    panic("free_desc 1");
    800057c6:	00002517          	auipc	a0,0x2
    800057ca:	eaa50513          	addi	a0,a0,-342 # 80007670 <etext+0x670>
    800057ce:	866fb0ef          	jal	80000834 <panic>
    panic("free_desc 2");
    800057d2:	00002517          	auipc	a0,0x2
    800057d6:	eae50513          	addi	a0,a0,-338 # 80007680 <etext+0x680>
    800057da:	85afb0ef          	jal	80000834 <panic>

00000000800057de <virtio_disk_init>:
{
    800057de:	1101                	addi	sp,sp,-32
    800057e0:	ec06                	sd	ra,24(sp)
    800057e2:	e822                	sd	s0,16(sp)
    800057e4:	e426                	sd	s1,8(sp)
    800057e6:	e04a                	sd	s2,0(sp)
    800057e8:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800057ea:	00002597          	auipc	a1,0x2
    800057ee:	ea658593          	addi	a1,a1,-346 # 80007690 <etext+0x690>
    800057f2:	0001e517          	auipc	a0,0x1e
    800057f6:	06e50513          	addi	a0,a0,110 # 80023860 <disk+0x128>
    800057fa:	baefb0ef          	jal	80000ba8 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800057fe:	100017b7          	lui	a5,0x10001
    80005802:	4398                	lw	a4,0(a5)
    80005804:	2701                	sext.w	a4,a4
    80005806:	747277b7          	lui	a5,0x74727
    8000580a:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000580e:	14f71863          	bne	a4,a5,8000595e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005812:	100017b7          	lui	a5,0x10001
    80005816:	43dc                	lw	a5,4(a5)
    80005818:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000581a:	4709                	li	a4,2
    8000581c:	14e79163          	bne	a5,a4,8000595e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005820:	100017b7          	lui	a5,0x10001
    80005824:	479c                	lw	a5,8(a5)
    80005826:	2781                	sext.w	a5,a5
    80005828:	12e79b63          	bne	a5,a4,8000595e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    8000582c:	100017b7          	lui	a5,0x10001
    80005830:	47d8                	lw	a4,12(a5)
    80005832:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005834:	554d47b7          	lui	a5,0x554d4
    80005838:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000583c:	12f71163          	bne	a4,a5,8000595e <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005840:	100017b7          	lui	a5,0x10001
    80005844:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005848:	4705                	li	a4,1
    8000584a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000584c:	470d                	li	a4,3
    8000584e:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005850:	10001737          	lui	a4,0x10001
    80005854:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005856:	c7ffe6b7          	lui	a3,0xc7ffe
    8000585a:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fdace7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000585e:	8f75                	and	a4,a4,a3
    80005860:	100016b7          	lui	a3,0x10001
    80005864:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005866:	472d                	li	a4,11
    80005868:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000586a:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000586e:	439c                	lw	a5,0(a5)
    80005870:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005874:	8ba1                	andi	a5,a5,8
    80005876:	0e078a63          	beqz	a5,8000596a <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000587a:	100017b7          	lui	a5,0x10001
    8000587e:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80005882:	43fc                	lw	a5,68(a5)
    80005884:	2781                	sext.w	a5,a5
    80005886:	0e079863          	bnez	a5,80005976 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000588a:	100017b7          	lui	a5,0x10001
    8000588e:	5bdc                	lw	a5,52(a5)
    80005890:	2781                	sext.w	a5,a5
  if (max == 0)
    80005892:	0e078863          	beqz	a5,80005982 <virtio_disk_init+0x1a4>
  if (max < NUM)
    80005896:	471d                	li	a4,7
    80005898:	0ef77b63          	bgeu	a4,a5,8000598e <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    8000589c:	ab2fb0ef          	jal	80000b4e <kalloc>
    800058a0:	0001e497          	auipc	s1,0x1e
    800058a4:	e9848493          	addi	s1,s1,-360 # 80023738 <disk>
    800058a8:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800058aa:	aa4fb0ef          	jal	80000b4e <kalloc>
    800058ae:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800058b0:	a9efb0ef          	jal	80000b4e <kalloc>
    800058b4:	87aa                	mv	a5,a0
    800058b6:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    800058b8:	6088                	ld	a0,0(s1)
    800058ba:	0e050063          	beqz	a0,8000599a <virtio_disk_init+0x1bc>
    800058be:	0001e717          	auipc	a4,0x1e
    800058c2:	e8273703          	ld	a4,-382(a4) # 80023740 <disk+0x8>
    800058c6:	cb71                	beqz	a4,8000599a <virtio_disk_init+0x1bc>
    800058c8:	cbe9                	beqz	a5,8000599a <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    800058ca:	6605                	lui	a2,0x1
    800058cc:	4581                	li	a1,0
    800058ce:	c1afb0ef          	jal	80000ce8 <memset>
  memset(disk.avail, 0, PGSIZE);
    800058d2:	0001e497          	auipc	s1,0x1e
    800058d6:	e6648493          	addi	s1,s1,-410 # 80023738 <disk>
    800058da:	6605                	lui	a2,0x1
    800058dc:	4581                	li	a1,0
    800058de:	6488                	ld	a0,8(s1)
    800058e0:	c08fb0ef          	jal	80000ce8 <memset>
  memset(disk.used, 0, PGSIZE);
    800058e4:	6605                	lui	a2,0x1
    800058e6:	4581                	li	a1,0
    800058e8:	6888                	ld	a0,16(s1)
    800058ea:	bfefb0ef          	jal	80000ce8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800058ee:	100017b7          	lui	a5,0x10001
    800058f2:	4721                	li	a4,8
    800058f4:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800058f6:	4098                	lw	a4,0(s1)
    800058f8:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800058fc:	40d8                	lw	a4,4(s1)
    800058fe:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005902:	649c                	ld	a5,8(s1)
    80005904:	0007869b          	sext.w	a3,a5
    80005908:	10001737          	lui	a4,0x10001
    8000590c:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005910:	9781                	srai	a5,a5,0x20
    80005912:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005916:	689c                	ld	a5,16(s1)
    80005918:	0007869b          	sext.w	a3,a5
    8000591c:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005920:	9781                	srai	a5,a5,0x20
    80005922:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005926:	4785                	li	a5,1
    80005928:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    8000592a:	00f48c23          	sb	a5,24(s1)
    8000592e:	00f48ca3          	sb	a5,25(s1)
    80005932:	00f48d23          	sb	a5,26(s1)
    80005936:	00f48da3          	sb	a5,27(s1)
    8000593a:	00f48e23          	sb	a5,28(s1)
    8000593e:	00f48ea3          	sb	a5,29(s1)
    80005942:	00f48f23          	sb	a5,30(s1)
    80005946:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000594a:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    8000594e:	07272823          	sw	s2,112(a4)
}
    80005952:	60e2                	ld	ra,24(sp)
    80005954:	6442                	ld	s0,16(sp)
    80005956:	64a2                	ld	s1,8(sp)
    80005958:	6902                	ld	s2,0(sp)
    8000595a:	6105                	addi	sp,sp,32
    8000595c:	8082                	ret
    panic("could not find virtio disk");
    8000595e:	00002517          	auipc	a0,0x2
    80005962:	d4250513          	addi	a0,a0,-702 # 800076a0 <etext+0x6a0>
    80005966:	ecffa0ef          	jal	80000834 <panic>
    panic("virtio disk FEATURES_OK unset");
    8000596a:	00002517          	auipc	a0,0x2
    8000596e:	d5650513          	addi	a0,a0,-682 # 800076c0 <etext+0x6c0>
    80005972:	ec3fa0ef          	jal	80000834 <panic>
    panic("virtio disk should not be ready");
    80005976:	00002517          	auipc	a0,0x2
    8000597a:	d6a50513          	addi	a0,a0,-662 # 800076e0 <etext+0x6e0>
    8000597e:	eb7fa0ef          	jal	80000834 <panic>
    panic("virtio disk has no queue 0");
    80005982:	00002517          	auipc	a0,0x2
    80005986:	d7e50513          	addi	a0,a0,-642 # 80007700 <etext+0x700>
    8000598a:	eabfa0ef          	jal	80000834 <panic>
    panic("virtio disk max queue too short");
    8000598e:	00002517          	auipc	a0,0x2
    80005992:	d9250513          	addi	a0,a0,-622 # 80007720 <etext+0x720>
    80005996:	e9ffa0ef          	jal	80000834 <panic>
    panic("virtio disk kalloc");
    8000599a:	00002517          	auipc	a0,0x2
    8000599e:	da650513          	addi	a0,a0,-602 # 80007740 <etext+0x740>
    800059a2:	e93fa0ef          	jal	80000834 <panic>

00000000800059a6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800059a6:	711d                	addi	sp,sp,-96
    800059a8:	ec86                	sd	ra,88(sp)
    800059aa:	e8a2                	sd	s0,80(sp)
    800059ac:	e4a6                	sd	s1,72(sp)
    800059ae:	e0ca                	sd	s2,64(sp)
    800059b0:	fc4e                	sd	s3,56(sp)
    800059b2:	f852                	sd	s4,48(sp)
    800059b4:	f456                	sd	s5,40(sp)
    800059b6:	f05a                	sd	s6,32(sp)
    800059b8:	ec5e                	sd	s7,24(sp)
    800059ba:	e862                	sd	s8,16(sp)
    800059bc:	1080                	addi	s0,sp,96
    800059be:	89aa                	mv	s3,a0
    800059c0:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800059c2:	00c52b83          	lw	s7,12(a0)
    800059c6:	001b9b9b          	slliw	s7,s7,0x1
    800059ca:	1b82                	slli	s7,s7,0x20
    800059cc:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    800059d0:	0001e517          	auipc	a0,0x1e
    800059d4:	e9050513          	addi	a0,a0,-368 # 80023860 <disk+0x128>
    800059d8:	a50fb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < NUM; i++) {
    800059dc:	44a1                	li	s1,8
      disk.free[i] = 0;
    800059de:	0001ea97          	auipc	s5,0x1e
    800059e2:	d5aa8a93          	addi	s5,s5,-678 # 80023738 <disk>
  for (int i = 0; i < 3; i++) {
    800059e6:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    800059e8:	5c7d                	li	s8,-1
    800059ea:	a8a5                	j	80005a62 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    800059ec:	00fa8733          	add	a4,s5,a5
    800059f0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800059f4:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    800059f6:	0207c563          	bltz	a5,80005a20 <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    800059fa:	2905                	addiw	s2,s2,1
    800059fc:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800059fe:	07490663          	beq	s2,s4,80005a6a <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80005a02:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005a04:	0001e717          	auipc	a4,0x1e
    80005a08:	d3470713          	addi	a4,a4,-716 # 80023738 <disk>
    80005a0c:	4781                	li	a5,0
    if (disk.free[i]) {
    80005a0e:	01874683          	lbu	a3,24(a4)
    80005a12:	fee9                	bnez	a3,800059ec <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    80005a14:	2785                	addiw	a5,a5,1
    80005a16:	0705                	addi	a4,a4,1
    80005a18:	fe979be3          	bne	a5,s1,80005a0e <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005a1c:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    80005a20:	01205d63          	blez	s2,80005a3a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005a24:	fa042503          	lw	a0,-96(s0)
    80005a28:	d41ff0ef          	jal	80005768 <free_desc>
      for (int j = 0; j < i; j++)
    80005a2c:	4785                	li	a5,1
    80005a2e:	0127d663          	bge	a5,s2,80005a3a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005a32:	fa442503          	lw	a0,-92(s0)
    80005a36:	d33ff0ef          	jal	80005768 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005a3a:	0001e517          	auipc	a0,0x1e
    80005a3e:	d1650513          	addi	a0,a0,-746 # 80023750 <disk+0x18>
    80005a42:	d14fc0ef          	jal	80001f56 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005a46:	0001e517          	auipc	a0,0x1e
    80005a4a:	e1a50513          	addi	a0,a0,-486 # 80023860 <disk+0x128>
    80005a4e:	a62fb0ef          	jal	80000cb0 <release>
    sleep();
    80005a52:	d40fc0ef          	jal	80001f92 <sleep>
    acquire(&disk.vdisk_lock);
    80005a56:	0001e517          	auipc	a0,0x1e
    80005a5a:	e0a50513          	addi	a0,a0,-502 # 80023860 <disk+0x128>
    80005a5e:	9cafb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < 3; i++) {
    80005a62:	fa040613          	addi	a2,s0,-96
    80005a66:	4901                	li	s2,0
    80005a68:	bf69                	j	80005a02 <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a6a:	fa042503          	lw	a0,-96(s0)
    80005a6e:	00451693          	slli	a3,a0,0x4

  if (write)
    80005a72:	0001e797          	auipc	a5,0x1e
    80005a76:	cc678793          	addi	a5,a5,-826 # 80023738 <disk>
    80005a7a:	00451713          	slli	a4,a0,0x4
    80005a7e:	0a070713          	addi	a4,a4,160
    80005a82:	973e                	add	a4,a4,a5
    80005a84:	01603633          	snez	a2,s6
    80005a88:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005a8a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005a8e:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005a92:	6398                	ld	a4,0(a5)
    80005a94:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a96:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005a9a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005a9c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005a9e:	6390                	ld	a2,0(a5)
    80005aa0:	00d60833          	add	a6,a2,a3
    80005aa4:	4741                	li	a4,16
    80005aa6:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005aaa:	4585                	li	a1,1
    80005aac:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005ab0:	fa442703          	lw	a4,-92(s0)
    80005ab4:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005ab8:	0712                	slli	a4,a4,0x4
    80005aba:	963a                	add	a2,a2,a4
    80005abc:	05898813          	addi	a6,s3,88
    80005ac0:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005ac4:	0007b883          	ld	a7,0(a5)
    80005ac8:	9746                	add	a4,a4,a7
    80005aca:	40000613          	li	a2,1024
    80005ace:	c710                	sw	a2,8(a4)
  if (write)
    80005ad0:	001b3613          	seqz	a2,s6
    80005ad4:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005ad8:	8e4d                	or	a2,a2,a1
    80005ada:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005ade:	fa842603          	lw	a2,-88(s0)
    80005ae2:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005ae6:	00451813          	slli	a6,a0,0x4
    80005aea:	02080813          	addi	a6,a6,32
    80005aee:	983e                	add	a6,a6,a5
    80005af0:	577d                	li	a4,-1
    80005af2:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005af6:	0612                	slli	a2,a2,0x4
    80005af8:	98b2                	add	a7,a7,a2
    80005afa:	03068713          	addi	a4,a3,48
    80005afe:	973e                	add	a4,a4,a5
    80005b00:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005b04:	6398                	ld	a4,0(a5)
    80005b06:	9732                	add	a4,a4,a2
    80005b08:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005b0a:	4689                	li	a3,2
    80005b0c:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005b10:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005b14:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005b18:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005b1c:	6794                	ld	a3,8(a5)
    80005b1e:	0026d703          	lhu	a4,2(a3)
    80005b22:	8b1d                	andi	a4,a4,7
    80005b24:	0706                	slli	a4,a4,0x1
    80005b26:	96ba                	add	a3,a3,a4
    80005b28:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005b2c:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005b30:	6798                	ld	a4,8(a5)
    80005b32:	00275783          	lhu	a5,2(a4)
    80005b36:	2785                	addiw	a5,a5,1
    80005b38:	00f71123          	sh	a5,2(a4)
    80005b3c:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005b40:	100017b7          	lui	a5,0x10001
    80005b44:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005b48:	0049a783          	lw	a5,4(s3)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005b4c:	0001e497          	auipc	s1,0x1e
    80005b50:	d1448493          	addi	s1,s1,-748 # 80023860 <disk+0x128>
  while (b->disk == 1) {
    80005b54:	892e                	mv	s2,a1
    80005b56:	02b79163          	bne	a5,a1,80005b78 <virtio_disk_rw+0x1d2>
    sleep_prepare(b);
    80005b5a:	854e                	mv	a0,s3
    80005b5c:	bfafc0ef          	jal	80001f56 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005b60:	8526                	mv	a0,s1
    80005b62:	94efb0ef          	jal	80000cb0 <release>
    sleep();
    80005b66:	c2cfc0ef          	jal	80001f92 <sleep>
    acquire(&disk.vdisk_lock);
    80005b6a:	8526                	mv	a0,s1
    80005b6c:	8bcfb0ef          	jal	80000c28 <acquire>
  while (b->disk == 1) {
    80005b70:	0049a783          	lw	a5,4(s3)
    80005b74:	ff2783e3          	beq	a5,s2,80005b5a <virtio_disk_rw+0x1b4>
  }

  disk.info[idx[0]].b = 0;
    80005b78:	fa042903          	lw	s2,-96(s0)
    80005b7c:	00491713          	slli	a4,s2,0x4
    80005b80:	02070713          	addi	a4,a4,32
    80005b84:	0001e797          	auipc	a5,0x1e
    80005b88:	bb478793          	addi	a5,a5,-1100 # 80023738 <disk>
    80005b8c:	97ba                	add	a5,a5,a4
    80005b8e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005b92:	0001e997          	auipc	s3,0x1e
    80005b96:	ba698993          	addi	s3,s3,-1114 # 80023738 <disk>
    80005b9a:	00491713          	slli	a4,s2,0x4
    80005b9e:	0009b783          	ld	a5,0(s3)
    80005ba2:	97ba                	add	a5,a5,a4
    80005ba4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005ba8:	854a                	mv	a0,s2
    80005baa:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005bae:	bbbff0ef          	jal	80005768 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005bb2:	8885                	andi	s1,s1,1
    80005bb4:	f0fd                	bnez	s1,80005b9a <virtio_disk_rw+0x1f4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005bb6:	0001e517          	auipc	a0,0x1e
    80005bba:	caa50513          	addi	a0,a0,-854 # 80023860 <disk+0x128>
    80005bbe:	8f2fb0ef          	jal	80000cb0 <release>
}
    80005bc2:	60e6                	ld	ra,88(sp)
    80005bc4:	6446                	ld	s0,80(sp)
    80005bc6:	64a6                	ld	s1,72(sp)
    80005bc8:	6906                	ld	s2,64(sp)
    80005bca:	79e2                	ld	s3,56(sp)
    80005bcc:	7a42                	ld	s4,48(sp)
    80005bce:	7aa2                	ld	s5,40(sp)
    80005bd0:	7b02                	ld	s6,32(sp)
    80005bd2:	6be2                	ld	s7,24(sp)
    80005bd4:	6c42                	ld	s8,16(sp)
    80005bd6:	6125                	addi	sp,sp,96
    80005bd8:	8082                	ret

0000000080005bda <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005bda:	1101                	addi	sp,sp,-32
    80005bdc:	ec06                	sd	ra,24(sp)
    80005bde:	e822                	sd	s0,16(sp)
    80005be0:	e426                	sd	s1,8(sp)
    80005be2:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005be4:	0001e497          	auipc	s1,0x1e
    80005be8:	b5448493          	addi	s1,s1,-1196 # 80023738 <disk>
    80005bec:	0001e517          	auipc	a0,0x1e
    80005bf0:	c7450513          	addi	a0,a0,-908 # 80023860 <disk+0x128>
    80005bf4:	834fb0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005bf8:	100017b7          	lui	a5,0x10001
    80005bfc:	53bc                	lw	a5,96(a5)
    80005bfe:	8b8d                	andi	a5,a5,3
    80005c00:	10001737          	lui	a4,0x10001
    80005c04:	d37c                	sw	a5,100(a4)
    80005c06:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005c0a:	689c                	ld	a5,16(s1)
    80005c0c:	0204d703          	lhu	a4,32(s1)
    80005c10:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005c14:	04f70863          	beq	a4,a5,80005c64 <virtio_disk_intr+0x8a>
    80005c18:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005c1c:	6898                	ld	a4,16(s1)
    80005c1e:	0204d783          	lhu	a5,32(s1)
    80005c22:	8b9d                	andi	a5,a5,7
    80005c24:	078e                	slli	a5,a5,0x3
    80005c26:	97ba                	add	a5,a5,a4
    80005c28:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005c2a:	00479713          	slli	a4,a5,0x4
    80005c2e:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005c32:	9726                	add	a4,a4,s1
    80005c34:	01074703          	lbu	a4,16(a4)
    80005c38:	e329                	bnez	a4,80005c7a <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005c3a:	0792                	slli	a5,a5,0x4
    80005c3c:	02078793          	addi	a5,a5,32
    80005c40:	97a6                	add	a5,a5,s1
    80005c42:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005c44:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005c48:	b7afc0ef          	jal	80001fc2 <wakeup>

    disk.used_idx += 1;
    80005c4c:	0204d783          	lhu	a5,32(s1)
    80005c50:	2785                	addiw	a5,a5,1
    80005c52:	17c2                	slli	a5,a5,0x30
    80005c54:	93c1                	srli	a5,a5,0x30
    80005c56:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005c5a:	6898                	ld	a4,16(s1)
    80005c5c:	00275703          	lhu	a4,2(a4)
    80005c60:	faf71ce3          	bne	a4,a5,80005c18 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005c64:	0001e517          	auipc	a0,0x1e
    80005c68:	bfc50513          	addi	a0,a0,-1028 # 80023860 <disk+0x128>
    80005c6c:	844fb0ef          	jal	80000cb0 <release>
}
    80005c70:	60e2                	ld	ra,24(sp)
    80005c72:	6442                	ld	s0,16(sp)
    80005c74:	64a2                	ld	s1,8(sp)
    80005c76:	6105                	addi	sp,sp,32
    80005c78:	8082                	ret
      panic("virtio_disk_intr status");
    80005c7a:	00002517          	auipc	a0,0x2
    80005c7e:	ade50513          	addi	a0,a0,-1314 # 80007758 <etext+0x758>
    80005c82:	bb3fa0ef          	jal	80000834 <panic>
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
