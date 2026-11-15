
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
    8000011c:	2c8020ef          	jal	800023e4 <either_copyin>
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
    800001c4:	0a0020ef          	jal	80002264 <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	63b010ef          	jal	80002006 <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	2df000ef          	jal	80000cb0 <release>
      sleep();
    800001d6:	66d010ef          	jal	80002042 <sleep>
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
    80000220:	178020ef          	jal	80002398 <either_copyout>
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
    800002ea:	146020ef          	jal	80002430 <procdump>
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
    8000042a:	449010ef          	jal	80002072 <wakeup>
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
    8000093a:	6cc010ef          	jal	80002006 <sleep_prepare>
      release(&tx_lock);
    8000093e:	8526                	mv	a0,s1
    80000940:	370000ef          	jal	80000cb0 <release>
      sleep();
    80000944:	6fe010ef          	jal	80002042 <sleep>
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
    80000a54:	61e010ef          	jal	80002072 <wakeup>
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
    80000ed4:	68e010ef          	jal	80002562 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ed8:	081040ef          	jal	80005758 <plicinithart>
  }

  scheduler();
    80000edc:	757000ef          	jal	80001e32 <scheduler>
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
    80000f1c:	622010ef          	jal	8000253e <trapinit>
    trapinithart();     // install kernel trap vector
    80000f20:	642010ef          	jal	80002562 <trapinithart>
    plicinit();         // set up interrupt controller
    80000f24:	01b040ef          	jal	8000573e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f28:	031040ef          	jal	80005758 <plicinithart>
    binit();            // buffer cache
    80000f2c:	4d7010ef          	jal	80002c02 <binit>
    iinit();            // inode table
    80000f30:	228020ef          	jal	80003158 <iinit>
    fileinit();         // file table
    80000f34:	256030ef          	jal	8000418a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f38:	117040ef          	jal	8000584e <virtio_disk_init>
    userinit();         // first user process
    80000f3c:	4d7000ef          	jal	80001c12 <userinit>
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
    800019a2:	4bb010ef          	jal	8000365c <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    800019a6:	00005797          	auipc	a5,0x5
    800019aa:	7da78793          	addi	a5,a5,2010 # 80007180 <etext+0x180>
    800019ae:	fcf43823          	sd	a5,-48(s0)
    800019b2:	fc043c23          	sd	zero,-40(s0)
    800019b6:	fd040593          	addi	a1,s0,-48
    800019ba:	853e                	mv	a0,a5
    800019bc:	755020ef          	jal	80004910 <kexec>
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
    800019ce:	3b1000ef          	jal	8000257e <prepare_return>
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
  p->burst_time = 0;
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
    80001b78:	d2448493          	addi	s1,s1,-732 # 80012898 <proc>
    80001b7c:	00017917          	auipc	s2,0x17
    80001b80:	91c90913          	addi	s2,s2,-1764 # 80018498 <tickslock>
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
    80001b9e:	a099                	j	80001be4 <allocproc+0x7c>
  p->pid = allocpid();
    80001ba0:	e71ff0ef          	jal	80001a10 <allocpid>
    80001ba4:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ba6:	4785                	li	a5,1
    80001ba8:	cc9c                	sw	a5,24(s1)
  p->burst_time = 0;
    80001baa:	1604a423          	sw	zero,360(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001bae:	fa1fe0ef          	jal	80000b4e <kalloc>
    80001bb2:	892a                	mv	s2,a0
    80001bb4:	eca8                	sd	a0,88(s1)
    80001bb6:	cd15                	beqz	a0,80001bf2 <allocproc+0x8a>
  p->pagetable = proc_pagetable(p);
    80001bb8:	8526                	mv	a0,s1
    80001bba:	e95ff0ef          	jal	80001a4e <proc_pagetable>
    80001bbe:	892a                	mv	s2,a0
    80001bc0:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001bc2:	c121                	beqz	a0,80001c02 <allocproc+0x9a>
  memset(&p->context, 0, sizeof(p->context));
    80001bc4:	07000613          	li	a2,112
    80001bc8:	4581                	li	a1,0
    80001bca:	06048513          	addi	a0,s1,96
    80001bce:	91aff0ef          	jal	80000ce8 <memset>
  p->context.ra = (uint64)forkret;
    80001bd2:	00000797          	auipc	a5,0x0
    80001bd6:	da878793          	addi	a5,a5,-600 # 8000197a <forkret>
    80001bda:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001bdc:	60bc                	ld	a5,64(s1)
    80001bde:	6705                	lui	a4,0x1
    80001be0:	97ba                	add	a5,a5,a4
    80001be2:	f4bc                	sd	a5,104(s1)
}
    80001be4:	8526                	mv	a0,s1
    80001be6:	60e2                	ld	ra,24(sp)
    80001be8:	6442                	ld	s0,16(sp)
    80001bea:	64a2                	ld	s1,8(sp)
    80001bec:	6902                	ld	s2,0(sp)
    80001bee:	6105                	addi	sp,sp,32
    80001bf0:	8082                	ret
    freeproc(p);
    80001bf2:	8526                	mv	a0,s1
    80001bf4:	f25ff0ef          	jal	80001b18 <freeproc>
    release(&p->lock);
    80001bf8:	8526                	mv	a0,s1
    80001bfa:	8b6ff0ef          	jal	80000cb0 <release>
    return 0;
    80001bfe:	84ca                	mv	s1,s2
    80001c00:	b7d5                	j	80001be4 <allocproc+0x7c>
    freeproc(p);
    80001c02:	8526                	mv	a0,s1
    80001c04:	f15ff0ef          	jal	80001b18 <freeproc>
    release(&p->lock);
    80001c08:	8526                	mv	a0,s1
    80001c0a:	8a6ff0ef          	jal	80000cb0 <release>
    return 0;
    80001c0e:	84ca                	mv	s1,s2
    80001c10:	bfd1                	j	80001be4 <allocproc+0x7c>

0000000080001c12 <userinit>:
{
    80001c12:	1101                	addi	sp,sp,-32
    80001c14:	ec06                	sd	ra,24(sp)
    80001c16:	e822                	sd	s0,16(sp)
    80001c18:	e426                	sd	s1,8(sp)
    80001c1a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c1c:	f4dff0ef          	jal	80001b68 <allocproc>
    80001c20:	84aa                	mv	s1,a0
  initproc = p;
    80001c22:	00008797          	auipc	a5,0x8
    80001c26:	72a7bf23          	sd	a0,1854(a5) # 8000a360 <initproc>
  p->cwd = namei("/");
    80001c2a:	00005517          	auipc	a0,0x5
    80001c2e:	56650513          	addi	a0,a0,1382 # 80007190 <etext+0x190>
    80001c32:	789010ef          	jal	80003bba <namei>
    80001c36:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c3a:	478d                	li	a5,3
    80001c3c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c3e:	8526                	mv	a0,s1
    80001c40:	870ff0ef          	jal	80000cb0 <release>
}
    80001c44:	60e2                	ld	ra,24(sp)
    80001c46:	6442                	ld	s0,16(sp)
    80001c48:	64a2                	ld	s1,8(sp)
    80001c4a:	6105                	addi	sp,sp,32
    80001c4c:	8082                	ret

0000000080001c4e <growproc>:
{
    80001c4e:	1101                	addi	sp,sp,-32
    80001c50:	ec06                	sd	ra,24(sp)
    80001c52:	e822                	sd	s0,16(sp)
    80001c54:	e426                	sd	s1,8(sp)
    80001c56:	e04a                	sd	s2,0(sp)
    80001c58:	1000                	addi	s0,sp,32
    80001c5a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c5c:	cedff0ef          	jal	80001948 <myproc>
    80001c60:	892a                	mv	s2,a0
  sz = p->sz;
    80001c62:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001c64:	02905963          	blez	s1,80001c96 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001c68:	00b48633          	add	a2,s1,a1
    80001c6c:	020007b7          	lui	a5,0x2000
    80001c70:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c72:	07b6                	slli	a5,a5,0xd
    80001c74:	02c7ea63          	bltu	a5,a2,80001ca8 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c78:	4691                	li	a3,4
    80001c7a:	6928                	ld	a0,80(a0)
    80001c7c:	e72ff0ef          	jal	800012ee <uvmalloc>
    80001c80:	85aa                	mv	a1,a0
    80001c82:	c50d                	beqz	a0,80001cac <growproc+0x5e>
  p->sz = sz;
    80001c84:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c88:	4501                	li	a0,0
}
    80001c8a:	60e2                	ld	ra,24(sp)
    80001c8c:	6442                	ld	s0,16(sp)
    80001c8e:	64a2                	ld	s1,8(sp)
    80001c90:	6902                	ld	s2,0(sp)
    80001c92:	6105                	addi	sp,sp,32
    80001c94:	8082                	ret
  } else if (n < 0) {
    80001c96:	fe04d7e3          	bgez	s1,80001c84 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c9a:	00b48633          	add	a2,s1,a1
    80001c9e:	6928                	ld	a0,80(a0)
    80001ca0:	e0aff0ef          	jal	800012aa <uvmdealloc>
    80001ca4:	85aa                	mv	a1,a0
    80001ca6:	bff9                	j	80001c84 <growproc+0x36>
      return -1;
    80001ca8:	557d                	li	a0,-1
    80001caa:	b7c5                	j	80001c8a <growproc+0x3c>
      return -1;
    80001cac:	557d                	li	a0,-1
    80001cae:	bff1                	j	80001c8a <growproc+0x3c>

0000000080001cb0 <kfork>:
{
    80001cb0:	7139                	addi	sp,sp,-64
    80001cb2:	fc06                	sd	ra,56(sp)
    80001cb4:	f822                	sd	s0,48(sp)
    80001cb6:	f426                	sd	s1,40(sp)
    80001cb8:	e456                	sd	s5,8(sp)
    80001cba:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001cbc:	c8dff0ef          	jal	80001948 <myproc>
    80001cc0:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001cc2:	ea7ff0ef          	jal	80001b68 <allocproc>
    80001cc6:	0e050a63          	beqz	a0,80001dba <kfork+0x10a>
    80001cca:	e852                	sd	s4,16(sp)
    80001ccc:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001cce:	048ab603          	ld	a2,72(s5)
    80001cd2:	692c                	ld	a1,80(a0)
    80001cd4:	050ab503          	ld	a0,80(s5)
    80001cd8:	f4eff0ef          	jal	80001426 <uvmcopy>
    80001cdc:	04054863          	bltz	a0,80001d2c <kfork+0x7c>
    80001ce0:	f04a                	sd	s2,32(sp)
    80001ce2:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001ce4:	048ab783          	ld	a5,72(s5)
    80001ce8:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001cec:	058ab683          	ld	a3,88(s5)
    80001cf0:	87b6                	mv	a5,a3
    80001cf2:	058a3703          	ld	a4,88(s4)
    80001cf6:	12068693          	addi	a3,a3,288
    80001cfa:	6388                	ld	a0,0(a5)
    80001cfc:	678c                	ld	a1,8(a5)
    80001cfe:	6b90                	ld	a2,16(a5)
    80001d00:	e308                	sd	a0,0(a4)
    80001d02:	e70c                	sd	a1,8(a4)
    80001d04:	eb10                	sd	a2,16(a4)
    80001d06:	6f90                	ld	a2,24(a5)
    80001d08:	ef10                	sd	a2,24(a4)
    80001d0a:	02078793          	addi	a5,a5,32
    80001d0e:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d12:	fed794e3          	bne	a5,a3,80001cfa <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d16:	058a3783          	ld	a5,88(s4)
    80001d1a:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001d1e:	0d0a8493          	addi	s1,s5,208
    80001d22:	0d0a0913          	addi	s2,s4,208
    80001d26:	150a8993          	addi	s3,s5,336
    80001d2a:	a831                	j	80001d46 <kfork+0x96>
    freeproc(np);
    80001d2c:	8552                	mv	a0,s4
    80001d2e:	debff0ef          	jal	80001b18 <freeproc>
    release(&np->lock);
    80001d32:	8552                	mv	a0,s4
    80001d34:	f7dfe0ef          	jal	80000cb0 <release>
    return -1;
    80001d38:	54fd                	li	s1,-1
    80001d3a:	6a42                	ld	s4,16(sp)
    80001d3c:	a885                	j	80001dac <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001d3e:	04a1                	addi	s1,s1,8
    80001d40:	0921                	addi	s2,s2,8
    80001d42:	01348963          	beq	s1,s3,80001d54 <kfork+0xa4>
    if (p->ofile[i])
    80001d46:	6088                	ld	a0,0(s1)
    80001d48:	d97d                	beqz	a0,80001d3e <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d4a:	4c2020ef          	jal	8000420c <filedup>
    80001d4e:	00a93023          	sd	a0,0(s2)
    80001d52:	b7f5                	j	80001d3e <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d54:	150ab503          	ld	a0,336(s5)
    80001d58:	592010ef          	jal	800032ea <idup>
    80001d5c:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d60:	4641                	li	a2,16
    80001d62:	158a8593          	addi	a1,s5,344
    80001d66:	158a0513          	addi	a0,s4,344
    80001d6a:	8d2ff0ef          	jal	80000e3c <safestrcpy>
  pid = np->pid;
    80001d6e:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001d72:	8552                	mv	a0,s4
    80001d74:	f3dfe0ef          	jal	80000cb0 <release>
  acquire(&wait_lock);
    80001d78:	00010517          	auipc	a0,0x10
    80001d7c:	70850513          	addi	a0,a0,1800 # 80012480 <wait_lock>
    80001d80:	ea9fe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001d84:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d88:	00010517          	auipc	a0,0x10
    80001d8c:	6f850513          	addi	a0,a0,1784 # 80012480 <wait_lock>
    80001d90:	f21fe0ef          	jal	80000cb0 <release>
  acquire(&np->lock);
    80001d94:	8552                	mv	a0,s4
    80001d96:	e93fe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001d9a:	478d                	li	a5,3
    80001d9c:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001da0:	8552                	mv	a0,s4
    80001da2:	f0ffe0ef          	jal	80000cb0 <release>
  return pid;
    80001da6:	7902                	ld	s2,32(sp)
    80001da8:	69e2                	ld	s3,24(sp)
    80001daa:	6a42                	ld	s4,16(sp)
}
    80001dac:	8526                	mv	a0,s1
    80001dae:	70e2                	ld	ra,56(sp)
    80001db0:	7442                	ld	s0,48(sp)
    80001db2:	74a2                	ld	s1,40(sp)
    80001db4:	6aa2                	ld	s5,8(sp)
    80001db6:	6121                	addi	sp,sp,64
    80001db8:	8082                	ret
    return -1;
    80001dba:	54fd                	li	s1,-1
    80001dbc:	bfc5                	j	80001dac <kfork+0xfc>

0000000080001dbe <set_burst>:
  if (bt < 0)
    80001dbe:	0605c863          	bltz	a1,80001e2e <set_burst+0x70>
{
    80001dc2:	7179                	addi	sp,sp,-48
    80001dc4:	f406                	sd	ra,40(sp)
    80001dc6:	f022                	sd	s0,32(sp)
    80001dc8:	ec26                	sd	s1,24(sp)
    80001dca:	e84a                	sd	s2,16(sp)
    80001dcc:	e44e                	sd	s3,8(sp)
    80001dce:	e052                	sd	s4,0(sp)
    80001dd0:	1800                	addi	s0,sp,48
    80001dd2:	892a                	mv	s2,a0
    80001dd4:	8a2e                	mv	s4,a1
  for (p = proc; p < &proc[NPROC]; p++) {
    80001dd6:	00011497          	auipc	s1,0x11
    80001dda:	ac248493          	addi	s1,s1,-1342 # 80012898 <proc>
    80001dde:	00016997          	auipc	s3,0x16
    80001de2:	6ba98993          	addi	s3,s3,1722 # 80018498 <tickslock>
    80001de6:	a801                	j	80001df6 <set_burst+0x38>
    release(&p->lock);
    80001de8:	8526                	mv	a0,s1
    80001dea:	ec7fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001dee:	17048493          	addi	s1,s1,368
    80001df2:	03348c63          	beq	s1,s3,80001e2a <set_burst+0x6c>
    acquire(&p->lock);
    80001df6:	8526                	mv	a0,s1
    80001df8:	e31fe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid || (pid == 0 && p == myproc())) {
    80001dfc:	589c                	lw	a5,48(s1)
    80001dfe:	01278863          	beq	a5,s2,80001e0e <set_burst+0x50>
    80001e02:	fe0913e3          	bnez	s2,80001de8 <set_burst+0x2a>
    80001e06:	b43ff0ef          	jal	80001948 <myproc>
    80001e0a:	fc951fe3          	bne	a0,s1,80001de8 <set_burst+0x2a>
      p->burst_time = bt;
    80001e0e:	1744a423          	sw	s4,360(s1)
      release(&p->lock);
    80001e12:	8526                	mv	a0,s1
    80001e14:	e9dfe0ef          	jal	80000cb0 <release>
      return 0;
    80001e18:	4501                	li	a0,0
}
    80001e1a:	70a2                	ld	ra,40(sp)
    80001e1c:	7402                	ld	s0,32(sp)
    80001e1e:	64e2                	ld	s1,24(sp)
    80001e20:	6942                	ld	s2,16(sp)
    80001e22:	69a2                	ld	s3,8(sp)
    80001e24:	6a02                	ld	s4,0(sp)
    80001e26:	6145                	addi	sp,sp,48
    80001e28:	8082                	ret
  return -1;
    80001e2a:	557d                	li	a0,-1
    80001e2c:	b7fd                	j	80001e1a <set_burst+0x5c>
    return -1;
    80001e2e:	557d                	li	a0,-1
}
    80001e30:	8082                	ret

0000000080001e32 <scheduler>:
{
    80001e32:	711d                	addi	sp,sp,-96
    80001e34:	ec86                	sd	ra,88(sp)
    80001e36:	e8a2                	sd	s0,80(sp)
    80001e38:	e4a6                	sd	s1,72(sp)
    80001e3a:	e0ca                	sd	s2,64(sp)
    80001e3c:	fc4e                	sd	s3,56(sp)
    80001e3e:	f852                	sd	s4,48(sp)
    80001e40:	f456                	sd	s5,40(sp)
    80001e42:	f05a                	sd	s6,32(sp)
    80001e44:	ec5e                	sd	s7,24(sp)
    80001e46:	e862                	sd	s8,16(sp)
    80001e48:	e466                	sd	s9,8(sp)
    80001e4a:	e06a                	sd	s10,0(sp)
    80001e4c:	1080                	addi	s0,sp,96
    80001e4e:	8792                	mv	a5,tp
  int id = r_tp();
    80001e50:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001e52:	00779c93          	slli	s9,a5,0x7
    80001e56:	00010717          	auipc	a4,0x10
    80001e5a:	61270713          	addi	a4,a4,1554 # 80012468 <pid_lock>
    80001e5e:	9766                	add	a4,a4,s9
    80001e60:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &shortest_p->context);
    80001e64:	00010717          	auipc	a4,0x10
    80001e68:	63c70713          	addi	a4,a4,1596 # 800124a0 <cpus+0x8>
    80001e6c:	9cba                	add	s9,s9,a4
    int min_bt = 0x7fffffff;
    80001e6e:	80000bb7          	lui	s7,0x80000
    80001e72:	fffbcb93          	not	s7,s7
      if (p->state == RUNNABLE) {
    80001e76:	4a8d                	li	s5,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e78:	00016a17          	auipc	s4,0x16
    80001e7c:	620a0a13          	addi	s4,s4,1568 # 80018498 <tickslock>
      c->proc = shortest_p;
    80001e80:	00010d17          	auipc	s10,0x10
    80001e84:	5e8d0d13          	addi	s10,s10,1512 # 80012468 <pid_lock>
    80001e88:	079e                	slli	a5,a5,0x7
    80001e8a:	00fd0c33          	add	s8,s10,a5
    80001e8e:	a895                	j	80001f02 <scheduler+0xd0>
        if (shortest_p == 0 || eff_bt < min_bt) {
    80001e90:	02098763          	beqz	s3,80001ebe <scheduler+0x8c>
    80001e94:	03694563          	blt	s2,s6,80001ebe <scheduler+0x8c>
      release(&p->lock);
    80001e98:	8526                	mv	a0,s1
    80001e9a:	e17fe0ef          	jal	80000cb0 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e9e:	17048493          	addi	s1,s1,368
    80001ea2:	03448963          	beq	s1,s4,80001ed4 <scheduler+0xa2>
      acquire(&p->lock);
    80001ea6:	8526                	mv	a0,s1
    80001ea8:	d81fe0ef          	jal	80000c28 <acquire>
      if (p->state == RUNNABLE) {
    80001eac:	4c9c                	lw	a5,24(s1)
    80001eae:	ff5795e3          	bne	a5,s5,80001e98 <scheduler+0x66>
        int eff_bt = (p->burst_time > 0) ? p->burst_time : 0x7fffffff;
    80001eb2:	1684a903          	lw	s2,360(s1)
    80001eb6:	fd204de3          	bgtz	s2,80001e90 <scheduler+0x5e>
    80001eba:	895e                	mv	s2,s7
    80001ebc:	bfd1                	j	80001e90 <scheduler+0x5e>
          if (shortest_p)
    80001ebe:	00098863          	beqz	s3,80001ece <scheduler+0x9c>
            release(&shortest_p->lock);
    80001ec2:	854e                	mv	a0,s3
    80001ec4:	dedfe0ef          	jal	80000cb0 <release>
          min_bt = eff_bt;
    80001ec8:	8b4a                	mv	s6,s2
          shortest_p = p;
    80001eca:	89a6                	mv	s3,s1
    80001ecc:	bfc9                	j	80001e9e <scheduler+0x6c>
          min_bt = eff_bt;
    80001ece:	8b4a                	mv	s6,s2
          shortest_p = p;
    80001ed0:	89a6                	mv	s3,s1
    80001ed2:	b7f1                	j	80001e9e <scheduler+0x6c>
    if (shortest_p) {
    80001ed4:	04098263          	beqz	s3,80001f18 <scheduler+0xe6>
      shortest_p->state = RUNNING;
    80001ed8:	4791                	li	a5,4
    80001eda:	00f9ac23          	sw	a5,24(s3)
      c->proc = shortest_p;
    80001ede:	033c3823          	sd	s3,48(s8) # fffffffffffff030 <end+0xffffffff7ffdb7b8>
      swtch(&c->context, &shortest_p->context);
    80001ee2:	06098593          	addi	a1,s3,96
    80001ee6:	8566                	mv	a0,s9
    80001ee8:	5ec000ef          	jal	800024d4 <swtch>
    80001eec:	8792                	mv	a5,tp
      mycpu()->intena = 0;
    80001eee:	2781                	sext.w	a5,a5
    80001ef0:	079e                	slli	a5,a5,0x7
    80001ef2:	97ea                	add	a5,a5,s10
    80001ef4:	0a07a623          	sw	zero,172(a5)
      c->proc = 0;
    80001ef8:	020c3823          	sd	zero,48(s8)
      release(&shortest_p->lock);
    80001efc:	854e                	mv	a0,s3
    80001efe:	db3fe0ef          	jal	80000cb0 <release>
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001f02:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001f06:	10017073          	csrci	sstatus,2
    int min_bt = 0x7fffffff;
    80001f0a:	8b5e                	mv	s6,s7
    struct proc *shortest_p = 0;
    80001f0c:	4981                	li	s3,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f0e:	00011497          	auipc	s1,0x11
    80001f12:	98a48493          	addi	s1,s1,-1654 # 80012898 <proc>
    80001f16:	bf41                	j	80001ea6 <scheduler+0x74>
      asm volatile("wfi");
    80001f18:	10500073          	wfi
    80001f1c:	b7dd                	j	80001f02 <scheduler+0xd0>

0000000080001f1e <sched>:
{
    80001f1e:	7179                	addi	sp,sp,-48
    80001f20:	f406                	sd	ra,40(sp)
    80001f22:	f022                	sd	s0,32(sp)
    80001f24:	ec26                	sd	s1,24(sp)
    80001f26:	e84a                	sd	s2,16(sp)
    80001f28:	e44e                	sd	s3,8(sp)
    80001f2a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f2c:	a1dff0ef          	jal	80001948 <myproc>
    80001f30:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001f32:	c91fe0ef          	jal	80000bc2 <holding>
    80001f36:	c935                	beqz	a0,80001faa <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80001f38:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001f3a:	2781                	sext.w	a5,a5
    80001f3c:	079e                	slli	a5,a5,0x7
    80001f3e:	00010717          	auipc	a4,0x10
    80001f42:	52a70713          	addi	a4,a4,1322 # 80012468 <pid_lock>
    80001f46:	97ba                	add	a5,a5,a4
    80001f48:	0a87a703          	lw	a4,168(a5)
    80001f4c:	4785                	li	a5,1
    80001f4e:	06f71463          	bne	a4,a5,80001fb6 <sched+0x98>
  if (p->state == RUNNING)
    80001f52:	4c98                	lw	a4,24(s1)
    80001f54:	4791                	li	a5,4
    80001f56:	06f70663          	beq	a4,a5,80001fc2 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001f5a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f5e:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001f60:	e7bd                	bnez	a5,80001fce <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    80001f62:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f64:	00010917          	auipc	s2,0x10
    80001f68:	50490913          	addi	s2,s2,1284 # 80012468 <pid_lock>
    80001f6c:	2781                	sext.w	a5,a5
    80001f6e:	079e                	slli	a5,a5,0x7
    80001f70:	97ca                	add	a5,a5,s2
    80001f72:	0ac7a983          	lw	s3,172(a5)
    80001f76:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f78:	2781                	sext.w	a5,a5
    80001f7a:	079e                	slli	a5,a5,0x7
    80001f7c:	07a1                	addi	a5,a5,8
    80001f7e:	00010597          	auipc	a1,0x10
    80001f82:	51a58593          	addi	a1,a1,1306 # 80012498 <cpus>
    80001f86:	95be                	add	a1,a1,a5
    80001f88:	06048513          	addi	a0,s1,96
    80001f8c:	548000ef          	jal	800024d4 <swtch>
    80001f90:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f92:	2781                	sext.w	a5,a5
    80001f94:	079e                	slli	a5,a5,0x7
    80001f96:	993e                	add	s2,s2,a5
    80001f98:	0b392623          	sw	s3,172(s2)
}
    80001f9c:	70a2                	ld	ra,40(sp)
    80001f9e:	7402                	ld	s0,32(sp)
    80001fa0:	64e2                	ld	s1,24(sp)
    80001fa2:	6942                	ld	s2,16(sp)
    80001fa4:	69a2                	ld	s3,8(sp)
    80001fa6:	6145                	addi	sp,sp,48
    80001fa8:	8082                	ret
    panic("sched p->lock");
    80001faa:	00005517          	auipc	a0,0x5
    80001fae:	1ee50513          	addi	a0,a0,494 # 80007198 <etext+0x198>
    80001fb2:	883fe0ef          	jal	80000834 <panic>
    panic("sched locks");
    80001fb6:	00005517          	auipc	a0,0x5
    80001fba:	1f250513          	addi	a0,a0,498 # 800071a8 <etext+0x1a8>
    80001fbe:	877fe0ef          	jal	80000834 <panic>
    panic("sched RUNNING");
    80001fc2:	00005517          	auipc	a0,0x5
    80001fc6:	1f650513          	addi	a0,a0,502 # 800071b8 <etext+0x1b8>
    80001fca:	86bfe0ef          	jal	80000834 <panic>
    panic("sched interruptible");
    80001fce:	00005517          	auipc	a0,0x5
    80001fd2:	1fa50513          	addi	a0,a0,506 # 800071c8 <etext+0x1c8>
    80001fd6:	85ffe0ef          	jal	80000834 <panic>

0000000080001fda <yield>:
{
    80001fda:	1101                	addi	sp,sp,-32
    80001fdc:	ec06                	sd	ra,24(sp)
    80001fde:	e822                	sd	s0,16(sp)
    80001fe0:	e426                	sd	s1,8(sp)
    80001fe2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001fe4:	965ff0ef          	jal	80001948 <myproc>
    80001fe8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001fea:	c3ffe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80001fee:	478d                	li	a5,3
    80001ff0:	cc9c                	sw	a5,24(s1)
  sched();
    80001ff2:	f2dff0ef          	jal	80001f1e <sched>
  release(&p->lock);
    80001ff6:	8526                	mv	a0,s1
    80001ff8:	cb9fe0ef          	jal	80000cb0 <release>
}
    80001ffc:	60e2                	ld	ra,24(sp)
    80001ffe:	6442                	ld	s0,16(sp)
    80002000:	64a2                	ld	s1,8(sp)
    80002002:	6105                	addi	sp,sp,32
    80002004:	8082                	ret

0000000080002006 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80002006:	1101                	addi	sp,sp,-32
    80002008:	ec06                	sd	ra,24(sp)
    8000200a:	e822                	sd	s0,16(sp)
    8000200c:	e426                	sd	s1,8(sp)
    8000200e:	e04a                	sd	s2,0(sp)
    80002010:	1000                	addi	s0,sp,32
    80002012:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002014:	935ff0ef          	jal	80001948 <myproc>
    80002018:	892a                	mv	s2,a0

  acquire(&p->lock);
    8000201a:	c0ffe0ef          	jal	80000c28 <acquire>
  if (chan == 0)
    8000201e:	cc81                	beqz	s1,80002036 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80002020:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80002024:	854a                	mv	a0,s2
    80002026:	c8bfe0ef          	jal	80000cb0 <release>
}
    8000202a:	60e2                	ld	ra,24(sp)
    8000202c:	6442                	ld	s0,16(sp)
    8000202e:	64a2                	ld	s1,8(sp)
    80002030:	6902                	ld	s2,0(sp)
    80002032:	6105                	addi	sp,sp,32
    80002034:	8082                	ret
    panic("sleep_prepare: zero chan");
    80002036:	00005517          	auipc	a0,0x5
    8000203a:	1aa50513          	addi	a0,a0,426 # 800071e0 <etext+0x1e0>
    8000203e:	ff6fe0ef          	jal	80000834 <panic>

0000000080002042 <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    80002042:	1101                	addi	sp,sp,-32
    80002044:	ec06                	sd	ra,24(sp)
    80002046:	e822                	sd	s0,16(sp)
    80002048:	e426                	sd	s1,8(sp)
    8000204a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000204c:	8fdff0ef          	jal	80001948 <myproc>
    80002050:	84aa                	mv	s1,a0

  acquire(&p->lock);
    80002052:	bd7fe0ef          	jal	80000c28 <acquire>
  if (p->chan != 0) {
    80002056:	709c                	ld	a5,32(s1)
    80002058:	c789                	beqz	a5,80002062 <sleep+0x20>
    p->state = SLEEPING;
    8000205a:	4789                	li	a5,2
    8000205c:	cc9c                	sw	a5,24(s1)
    sched();
    8000205e:	ec1ff0ef          	jal	80001f1e <sched>
  }
  release(&p->lock);
    80002062:	8526                	mv	a0,s1
    80002064:	c4dfe0ef          	jal	80000cb0 <release>
}
    80002068:	60e2                	ld	ra,24(sp)
    8000206a:	6442                	ld	s0,16(sp)
    8000206c:	64a2                	ld	s1,8(sp)
    8000206e:	6105                	addi	sp,sp,32
    80002070:	8082                	ret

0000000080002072 <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    80002072:	7139                	addi	sp,sp,-64
    80002074:	fc06                	sd	ra,56(sp)
    80002076:	f822                	sd	s0,48(sp)
    80002078:	f426                	sd	s1,40(sp)
    8000207a:	f04a                	sd	s2,32(sp)
    8000207c:	ec4e                	sd	s3,24(sp)
    8000207e:	e852                	sd	s4,16(sp)
    80002080:	e456                	sd	s5,8(sp)
    80002082:	0080                	addi	s0,sp,64
    80002084:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002086:	00011497          	auipc	s1,0x11
    8000208a:	81248493          	addi	s1,s1,-2030 # 80012898 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    8000208e:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80002090:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80002092:	00016997          	auipc	s3,0x16
    80002096:	40698993          	addi	s3,s3,1030 # 80018498 <tickslock>
    8000209a:	a801                	j	800020aa <wakeup+0x38>
      }
    }
    release(&p->lock);
    8000209c:	8526                	mv	a0,s1
    8000209e:	c13fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800020a2:	17048493          	addi	s1,s1,368
    800020a6:	03348063          	beq	s1,s3,800020c6 <wakeup+0x54>
    acquire(&p->lock);
    800020aa:	8526                	mv	a0,s1
    800020ac:	b7dfe0ef          	jal	80000c28 <acquire>
    if (p->chan == chan) {
    800020b0:	709c                	ld	a5,32(s1)
    800020b2:	ff2795e3          	bne	a5,s2,8000209c <wakeup+0x2a>
      p->chan = 0;
    800020b6:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    800020ba:	4c9c                	lw	a5,24(s1)
    800020bc:	ff4790e3          	bne	a5,s4,8000209c <wakeup+0x2a>
        p->state = RUNNABLE;
    800020c0:	0154ac23          	sw	s5,24(s1)
    800020c4:	bfe1                	j	8000209c <wakeup+0x2a>
  }
}
    800020c6:	70e2                	ld	ra,56(sp)
    800020c8:	7442                	ld	s0,48(sp)
    800020ca:	74a2                	ld	s1,40(sp)
    800020cc:	7902                	ld	s2,32(sp)
    800020ce:	69e2                	ld	s3,24(sp)
    800020d0:	6a42                	ld	s4,16(sp)
    800020d2:	6aa2                	ld	s5,8(sp)
    800020d4:	6121                	addi	sp,sp,64
    800020d6:	8082                	ret

00000000800020d8 <reparent>:
{
    800020d8:	7179                	addi	sp,sp,-48
    800020da:	f406                	sd	ra,40(sp)
    800020dc:	f022                	sd	s0,32(sp)
    800020de:	ec26                	sd	s1,24(sp)
    800020e0:	e84a                	sd	s2,16(sp)
    800020e2:	e44e                	sd	s3,8(sp)
    800020e4:	e052                	sd	s4,0(sp)
    800020e6:	1800                	addi	s0,sp,48
    800020e8:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800020ea:	00010497          	auipc	s1,0x10
    800020ee:	7ae48493          	addi	s1,s1,1966 # 80012898 <proc>
      pp->parent = initproc;
    800020f2:	00008a17          	auipc	s4,0x8
    800020f6:	26ea0a13          	addi	s4,s4,622 # 8000a360 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800020fa:	00016997          	auipc	s3,0x16
    800020fe:	39e98993          	addi	s3,s3,926 # 80018498 <tickslock>
    80002102:	a029                	j	8000210c <reparent+0x34>
    80002104:	17048493          	addi	s1,s1,368
    80002108:	01348b63          	beq	s1,s3,8000211e <reparent+0x46>
    if (pp->parent == p) {
    8000210c:	7c9c                	ld	a5,56(s1)
    8000210e:	ff279be3          	bne	a5,s2,80002104 <reparent+0x2c>
      pp->parent = initproc;
    80002112:	000a3503          	ld	a0,0(s4)
    80002116:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002118:	f5bff0ef          	jal	80002072 <wakeup>
    8000211c:	b7e5                	j	80002104 <reparent+0x2c>
}
    8000211e:	70a2                	ld	ra,40(sp)
    80002120:	7402                	ld	s0,32(sp)
    80002122:	64e2                	ld	s1,24(sp)
    80002124:	6942                	ld	s2,16(sp)
    80002126:	69a2                	ld	s3,8(sp)
    80002128:	6a02                	ld	s4,0(sp)
    8000212a:	6145                	addi	sp,sp,48
    8000212c:	8082                	ret

000000008000212e <kexit>:
{
    8000212e:	7179                	addi	sp,sp,-48
    80002130:	f406                	sd	ra,40(sp)
    80002132:	f022                	sd	s0,32(sp)
    80002134:	ec26                	sd	s1,24(sp)
    80002136:	e84a                	sd	s2,16(sp)
    80002138:	e44e                	sd	s3,8(sp)
    8000213a:	e052                	sd	s4,0(sp)
    8000213c:	1800                	addi	s0,sp,48
    8000213e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002140:	809ff0ef          	jal	80001948 <myproc>
    80002144:	89aa                	mv	s3,a0
  if (p == initproc)
    80002146:	00008797          	auipc	a5,0x8
    8000214a:	21a7b783          	ld	a5,538(a5) # 8000a360 <initproc>
    8000214e:	0d050493          	addi	s1,a0,208
    80002152:	15050913          	addi	s2,a0,336
    80002156:	00a79b63          	bne	a5,a0,8000216c <kexit+0x3e>
    panic("init exiting");
    8000215a:	00005517          	auipc	a0,0x5
    8000215e:	0a650513          	addi	a0,a0,166 # 80007200 <etext+0x200>
    80002162:	ed2fe0ef          	jal	80000834 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    80002166:	04a1                	addi	s1,s1,8
    80002168:	01248963          	beq	s1,s2,8000217a <kexit+0x4c>
    if (p->ofile[fd]) {
    8000216c:	6088                	ld	a0,0(s1)
    8000216e:	dd65                	beqz	a0,80002166 <kexit+0x38>
      fileclose(f);
    80002170:	0e2020ef          	jal	80004252 <fileclose>
      p->ofile[fd] = 0;
    80002174:	0004b023          	sd	zero,0(s1)
    80002178:	b7fd                	j	80002166 <kexit+0x38>
  begin_op();
    8000217a:	41f010ef          	jal	80003d98 <begin_op>
  iput(p->cwd);
    8000217e:	1509b503          	ld	a0,336(s3)
    80002182:	320010ef          	jal	800034a2 <iput>
  end_op();
    80002186:	49f010ef          	jal	80003e24 <end_op>
  p->cwd = 0;
    8000218a:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000218e:	00010517          	auipc	a0,0x10
    80002192:	2f250513          	addi	a0,a0,754 # 80012480 <wait_lock>
    80002196:	a93fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    8000219a:	854e                	mv	a0,s3
    8000219c:	f3dff0ef          	jal	800020d8 <reparent>
  wakeup(p->parent);
    800021a0:	0389b503          	ld	a0,56(s3)
    800021a4:	ecfff0ef          	jal	80002072 <wakeup>
  acquire(&p->lock);
    800021a8:	854e                	mv	a0,s3
    800021aa:	a7ffe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    800021ae:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800021b2:	4795                	li	a5,5
    800021b4:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800021b8:	00010517          	auipc	a0,0x10
    800021bc:	2c850513          	addi	a0,a0,712 # 80012480 <wait_lock>
    800021c0:	af1fe0ef          	jal	80000cb0 <release>
  sched();
    800021c4:	d5bff0ef          	jal	80001f1e <sched>
  panic("zombie exit");
    800021c8:	00005517          	auipc	a0,0x5
    800021cc:	04850513          	addi	a0,a0,72 # 80007210 <etext+0x210>
    800021d0:	e64fe0ef          	jal	80000834 <panic>

00000000800021d4 <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    800021d4:	c525                	beqz	a0,8000223c <kkill+0x68>
{
    800021d6:	7179                	addi	sp,sp,-48
    800021d8:	f406                	sd	ra,40(sp)
    800021da:	f022                	sd	s0,32(sp)
    800021dc:	ec26                	sd	s1,24(sp)
    800021de:	e84a                	sd	s2,16(sp)
    800021e0:	e44e                	sd	s3,8(sp)
    800021e2:	1800                	addi	s0,sp,48
    800021e4:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    800021e6:	00010497          	auipc	s1,0x10
    800021ea:	6b248493          	addi	s1,s1,1714 # 80012898 <proc>
    800021ee:	00016997          	auipc	s3,0x16
    800021f2:	2aa98993          	addi	s3,s3,682 # 80018498 <tickslock>
    acquire(&p->lock);
    800021f6:	8526                	mv	a0,s1
    800021f8:	a31fe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid) {
    800021fc:	589c                	lw	a5,48(s1)
    800021fe:	01278b63          	beq	a5,s2,80002214 <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002202:	8526                	mv	a0,s1
    80002204:	aadfe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002208:	17048493          	addi	s1,s1,368
    8000220c:	ff3495e3          	bne	s1,s3,800021f6 <kkill+0x22>
  }
  return -1;
    80002210:	557d                	li	a0,-1
    80002212:	a819                	j	80002228 <kkill+0x54>
      p->killed = 1;
    80002214:	4785                	li	a5,1
    80002216:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    80002218:	4c98                	lw	a4,24(s1)
    8000221a:	4789                	li	a5,2
    8000221c:	00f70d63          	beq	a4,a5,80002236 <kkill+0x62>
      release(&p->lock);
    80002220:	8526                	mv	a0,s1
    80002222:	a8ffe0ef          	jal	80000cb0 <release>
      return 0;
    80002226:	4501                	li	a0,0
}
    80002228:	70a2                	ld	ra,40(sp)
    8000222a:	7402                	ld	s0,32(sp)
    8000222c:	64e2                	ld	s1,24(sp)
    8000222e:	6942                	ld	s2,16(sp)
    80002230:	69a2                	ld	s3,8(sp)
    80002232:	6145                	addi	sp,sp,48
    80002234:	8082                	ret
        p->state = RUNNABLE;
    80002236:	478d                	li	a5,3
    80002238:	cc9c                	sw	a5,24(s1)
    8000223a:	b7dd                	j	80002220 <kkill+0x4c>
    return -1;
    8000223c:	557d                	li	a0,-1
}
    8000223e:	8082                	ret

0000000080002240 <setkilled>:

void
setkilled(struct proc *p)
{
    80002240:	1101                	addi	sp,sp,-32
    80002242:	ec06                	sd	ra,24(sp)
    80002244:	e822                	sd	s0,16(sp)
    80002246:	e426                	sd	s1,8(sp)
    80002248:	1000                	addi	s0,sp,32
    8000224a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000224c:	9ddfe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    80002250:	4785                	li	a5,1
    80002252:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002254:	8526                	mv	a0,s1
    80002256:	a5bfe0ef          	jal	80000cb0 <release>
}
    8000225a:	60e2                	ld	ra,24(sp)
    8000225c:	6442                	ld	s0,16(sp)
    8000225e:	64a2                	ld	s1,8(sp)
    80002260:	6105                	addi	sp,sp,32
    80002262:	8082                	ret

0000000080002264 <killed>:

int
killed(struct proc *p)
{
    80002264:	1101                	addi	sp,sp,-32
    80002266:	ec06                	sd	ra,24(sp)
    80002268:	e822                	sd	s0,16(sp)
    8000226a:	e426                	sd	s1,8(sp)
    8000226c:	e04a                	sd	s2,0(sp)
    8000226e:	1000                	addi	s0,sp,32
    80002270:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002272:	9b7fe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    80002276:	549c                	lw	a5,40(s1)
    80002278:	893e                	mv	s2,a5
  release(&p->lock);
    8000227a:	8526                	mv	a0,s1
    8000227c:	a35fe0ef          	jal	80000cb0 <release>
  return k;
}
    80002280:	854a                	mv	a0,s2
    80002282:	60e2                	ld	ra,24(sp)
    80002284:	6442                	ld	s0,16(sp)
    80002286:	64a2                	ld	s1,8(sp)
    80002288:	6902                	ld	s2,0(sp)
    8000228a:	6105                	addi	sp,sp,32
    8000228c:	8082                	ret

000000008000228e <kwait>:
{
    8000228e:	715d                	addi	sp,sp,-80
    80002290:	e486                	sd	ra,72(sp)
    80002292:	e0a2                	sd	s0,64(sp)
    80002294:	fc26                	sd	s1,56(sp)
    80002296:	f84a                	sd	s2,48(sp)
    80002298:	f44e                	sd	s3,40(sp)
    8000229a:	f052                	sd	s4,32(sp)
    8000229c:	ec56                	sd	s5,24(sp)
    8000229e:	e85a                	sd	s6,16(sp)
    800022a0:	e45e                	sd	s7,8(sp)
    800022a2:	0880                	addi	s0,sp,80
    800022a4:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800022a6:	ea2ff0ef          	jal	80001948 <myproc>
    800022aa:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800022ac:	00010517          	auipc	a0,0x10
    800022b0:	1d450513          	addi	a0,a0,468 # 80012480 <wait_lock>
    800022b4:	975fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    800022b8:	4a15                	li	s4,5
        havekids = 1;
    800022ba:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800022bc:	00016997          	auipc	s3,0x16
    800022c0:	1dc98993          	addi	s3,s3,476 # 80018498 <tickslock>
    release(&wait_lock);
    800022c4:	00010b17          	auipc	s6,0x10
    800022c8:	1bcb0b13          	addi	s6,s6,444 # 80012480 <wait_lock>
    800022cc:	a845                	j	8000237c <kwait+0xee>
          pid = pp->pid;
    800022ce:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    800022d2:	000b8e63          	beqz	s7,800022ee <kwait+0x60>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    800022d6:	4711                	li	a4,4
    800022d8:	02c48693          	addi	a3,s1,44
    800022dc:	865e                	mv	a2,s7
    800022de:	04893583          	ld	a1,72(s2)
    800022e2:	05093503          	ld	a0,80(s2)
    800022e6:	a9cff0ef          	jal	80001582 <copyout>
          if (addr != 0 &&
    800022ea:	02054c63          	bltz	a0,80002322 <kwait+0x94>
          pp->parent = 0;
    800022ee:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    800022f2:	8526                	mv	a0,s1
    800022f4:	825ff0ef          	jal	80001b18 <freeproc>
          release(&pp->lock);
    800022f8:	8526                	mv	a0,s1
    800022fa:	9b7fe0ef          	jal	80000cb0 <release>
          release(&wait_lock);
    800022fe:	00010517          	auipc	a0,0x10
    80002302:	18250513          	addi	a0,a0,386 # 80012480 <wait_lock>
    80002306:	9abfe0ef          	jal	80000cb0 <release>
}
    8000230a:	854e                	mv	a0,s3
    8000230c:	60a6                	ld	ra,72(sp)
    8000230e:	6406                	ld	s0,64(sp)
    80002310:	74e2                	ld	s1,56(sp)
    80002312:	7942                	ld	s2,48(sp)
    80002314:	79a2                	ld	s3,40(sp)
    80002316:	7a02                	ld	s4,32(sp)
    80002318:	6ae2                	ld	s5,24(sp)
    8000231a:	6b42                	ld	s6,16(sp)
    8000231c:	6ba2                	ld	s7,8(sp)
    8000231e:	6161                	addi	sp,sp,80
    80002320:	8082                	ret
            release(&pp->lock);
    80002322:	8526                	mv	a0,s1
    80002324:	98dfe0ef          	jal	80000cb0 <release>
            release(&wait_lock);
    80002328:	00010517          	auipc	a0,0x10
    8000232c:	15850513          	addi	a0,a0,344 # 80012480 <wait_lock>
    80002330:	981fe0ef          	jal	80000cb0 <release>
            return -1;
    80002334:	59fd                	li	s3,-1
    80002336:	bfd1                	j	8000230a <kwait+0x7c>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002338:	17048493          	addi	s1,s1,368
    8000233c:	03348063          	beq	s1,s3,8000235c <kwait+0xce>
      if (pp->parent == p) {
    80002340:	7c9c                	ld	a5,56(s1)
    80002342:	ff279be3          	bne	a5,s2,80002338 <kwait+0xaa>
        acquire(&pp->lock);
    80002346:	8526                	mv	a0,s1
    80002348:	8e1fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    8000234c:	4c9c                	lw	a5,24(s1)
    8000234e:	f94780e3          	beq	a5,s4,800022ce <kwait+0x40>
        release(&pp->lock);
    80002352:	8526                	mv	a0,s1
    80002354:	95dfe0ef          	jal	80000cb0 <release>
        havekids = 1;
    80002358:	8756                	mv	a4,s5
    8000235a:	bff9                	j	80002338 <kwait+0xaa>
    if (!havekids || killed(p)) {
    8000235c:	c715                	beqz	a4,80002388 <kwait+0xfa>
    8000235e:	854a                	mv	a0,s2
    80002360:	f05ff0ef          	jal	80002264 <killed>
    80002364:	e115                	bnez	a0,80002388 <kwait+0xfa>
    sleep_prepare(p); //DOC: wait-sleep
    80002366:	854a                	mv	a0,s2
    80002368:	c9fff0ef          	jal	80002006 <sleep_prepare>
    release(&wait_lock);
    8000236c:	855a                	mv	a0,s6
    8000236e:	943fe0ef          	jal	80000cb0 <release>
    sleep();
    80002372:	cd1ff0ef          	jal	80002042 <sleep>
    acquire(&wait_lock);
    80002376:	855a                	mv	a0,s6
    80002378:	8b1fe0ef          	jal	80000c28 <acquire>
    havekids = 0;
    8000237c:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000237e:	00010497          	auipc	s1,0x10
    80002382:	51a48493          	addi	s1,s1,1306 # 80012898 <proc>
    80002386:	bf6d                	j	80002340 <kwait+0xb2>
      release(&wait_lock);
    80002388:	00010517          	auipc	a0,0x10
    8000238c:	0f850513          	addi	a0,a0,248 # 80012480 <wait_lock>
    80002390:	921fe0ef          	jal	80000cb0 <release>
      return -1;
    80002394:	59fd                	li	s3,-1
    80002396:	bf95                	j	8000230a <kwait+0x7c>

0000000080002398 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002398:	7179                	addi	sp,sp,-48
    8000239a:	f406                	sd	ra,40(sp)
    8000239c:	f022                	sd	s0,32(sp)
    8000239e:	ec26                	sd	s1,24(sp)
    800023a0:	e84a                	sd	s2,16(sp)
    800023a2:	e44e                	sd	s3,8(sp)
    800023a4:	e052                	sd	s4,0(sp)
    800023a6:	1800                	addi	s0,sp,48
    800023a8:	84aa                	mv	s1,a0
    800023aa:	8a2e                	mv	s4,a1
    800023ac:	89b2                	mv	s3,a2
    800023ae:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800023b0:	d98ff0ef          	jal	80001948 <myproc>
  if (user_dst) {
    800023b4:	c085                	beqz	s1,800023d4 <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    800023b6:	874a                	mv	a4,s2
    800023b8:	86ce                	mv	a3,s3
    800023ba:	8652                	mv	a2,s4
    800023bc:	652c                	ld	a1,72(a0)
    800023be:	6928                	ld	a0,80(a0)
    800023c0:	9c2ff0ef          	jal	80001582 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800023c4:	70a2                	ld	ra,40(sp)
    800023c6:	7402                	ld	s0,32(sp)
    800023c8:	64e2                	ld	s1,24(sp)
    800023ca:	6942                	ld	s2,16(sp)
    800023cc:	69a2                	ld	s3,8(sp)
    800023ce:	6a02                	ld	s4,0(sp)
    800023d0:	6145                	addi	sp,sp,48
    800023d2:	8082                	ret
    memmove((char *)dst, src, len);
    800023d4:	0009061b          	sext.w	a2,s2
    800023d8:	85ce                	mv	a1,s3
    800023da:	8552                	mv	a0,s4
    800023dc:	96dfe0ef          	jal	80000d48 <memmove>
    return 0;
    800023e0:	8526                	mv	a0,s1
    800023e2:	b7cd                	j	800023c4 <either_copyout+0x2c>

00000000800023e4 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800023e4:	7179                	addi	sp,sp,-48
    800023e6:	f406                	sd	ra,40(sp)
    800023e8:	f022                	sd	s0,32(sp)
    800023ea:	ec26                	sd	s1,24(sp)
    800023ec:	e84a                	sd	s2,16(sp)
    800023ee:	e44e                	sd	s3,8(sp)
    800023f0:	e052                	sd	s4,0(sp)
    800023f2:	1800                	addi	s0,sp,48
    800023f4:	8a2a                	mv	s4,a0
    800023f6:	84ae                	mv	s1,a1
    800023f8:	89b2                	mv	s3,a2
    800023fa:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800023fc:	d4cff0ef          	jal	80001948 <myproc>
  if (user_src) {
    80002400:	c085                	beqz	s1,80002420 <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    80002402:	874a                	mv	a4,s2
    80002404:	86ce                	mv	a3,s3
    80002406:	8652                	mv	a2,s4
    80002408:	652c                	ld	a1,72(a0)
    8000240a:	6928                	ld	a0,80(a0)
    8000240c:	a3cff0ef          	jal	80001648 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002410:	70a2                	ld	ra,40(sp)
    80002412:	7402                	ld	s0,32(sp)
    80002414:	64e2                	ld	s1,24(sp)
    80002416:	6942                	ld	s2,16(sp)
    80002418:	69a2                	ld	s3,8(sp)
    8000241a:	6a02                	ld	s4,0(sp)
    8000241c:	6145                	addi	sp,sp,48
    8000241e:	8082                	ret
    memmove(dst, (char *)src, len);
    80002420:	0009061b          	sext.w	a2,s2
    80002424:	85ce                	mv	a1,s3
    80002426:	8552                	mv	a0,s4
    80002428:	921fe0ef          	jal	80000d48 <memmove>
    return 0;
    8000242c:	8526                	mv	a0,s1
    8000242e:	b7cd                	j	80002410 <either_copyin+0x2c>

0000000080002430 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002430:	715d                	addi	sp,sp,-80
    80002432:	e486                	sd	ra,72(sp)
    80002434:	e0a2                	sd	s0,64(sp)
    80002436:	fc26                	sd	s1,56(sp)
    80002438:	f84a                	sd	s2,48(sp)
    8000243a:	f44e                	sd	s3,40(sp)
    8000243c:	f052                	sd	s4,32(sp)
    8000243e:	ec56                	sd	s5,24(sp)
    80002440:	e85a                	sd	s6,16(sp)
    80002442:	e45e                	sd	s7,8(sp)
    80002444:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    80002446:	00005517          	auipc	a0,0x5
    8000244a:	c3250513          	addi	a0,a0,-974 # 80007078 <etext+0x78>
    8000244e:	8bcfe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002452:	00010497          	auipc	s1,0x10
    80002456:	59e48493          	addi	s1,s1,1438 # 800129f0 <proc+0x158>
    8000245a:	00016917          	auipc	s2,0x16
    8000245e:	19690913          	addi	s2,s2,406 # 800185f0 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002462:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002464:	00005997          	auipc	s3,0x5
    80002468:	dbc98993          	addi	s3,s3,-580 # 80007220 <etext+0x220>
    printk("%d %s %s", p->pid, state, p->name);
    8000246c:	00005a97          	auipc	s5,0x5
    80002470:	dbca8a93          	addi	s5,s5,-580 # 80007228 <etext+0x228>
    printk("\n");
    80002474:	00005a17          	auipc	s4,0x5
    80002478:	c04a0a13          	addi	s4,s4,-1020 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000247c:	00005b97          	auipc	s7,0x5
    80002480:	2ccb8b93          	addi	s7,s7,716 # 80007748 <states.0>
    80002484:	a829                	j	8000249e <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    80002486:	ed86a583          	lw	a1,-296(a3)
    8000248a:	8556                	mv	a0,s5
    8000248c:	87efe0ef          	jal	8000050a <printk>
    printk("\n");
    80002490:	8552                	mv	a0,s4
    80002492:	878fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002496:	17048493          	addi	s1,s1,368
    8000249a:	03248263          	beq	s1,s2,800024be <procdump+0x8e>
    if (p->state == UNUSED)
    8000249e:	86a6                	mv	a3,s1
    800024a0:	ec04a783          	lw	a5,-320(s1)
    800024a4:	dbed                	beqz	a5,80002496 <procdump+0x66>
      state = "???";
    800024a6:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024a8:	fcfb6fe3          	bltu	s6,a5,80002486 <procdump+0x56>
    800024ac:	02079713          	slli	a4,a5,0x20
    800024b0:	01d75793          	srli	a5,a4,0x1d
    800024b4:	97de                	add	a5,a5,s7
    800024b6:	6390                	ld	a2,0(a5)
    800024b8:	f679                	bnez	a2,80002486 <procdump+0x56>
      state = "???";
    800024ba:	864e                	mv	a2,s3
    800024bc:	b7e9                	j	80002486 <procdump+0x56>
  }
}
    800024be:	60a6                	ld	ra,72(sp)
    800024c0:	6406                	ld	s0,64(sp)
    800024c2:	74e2                	ld	s1,56(sp)
    800024c4:	7942                	ld	s2,48(sp)
    800024c6:	79a2                	ld	s3,40(sp)
    800024c8:	7a02                	ld	s4,32(sp)
    800024ca:	6ae2                	ld	s5,24(sp)
    800024cc:	6b42                	ld	s6,16(sp)
    800024ce:	6ba2                	ld	s7,8(sp)
    800024d0:	6161                	addi	sp,sp,80
    800024d2:	8082                	ret

00000000800024d4 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800024d4:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800024d8:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800024dc:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800024de:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800024e0:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800024e4:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800024e8:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800024ec:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800024f0:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800024f4:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800024f8:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800024fc:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002500:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002504:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002508:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000250c:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002510:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002512:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002514:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002518:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000251c:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002520:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002524:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002528:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000252c:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002530:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002534:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002538:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000253c:	8082                	ret

000000008000253e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000253e:	1141                	addi	sp,sp,-16
    80002540:	e406                	sd	ra,8(sp)
    80002542:	e022                	sd	s0,0(sp)
    80002544:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002546:	00005597          	auipc	a1,0x5
    8000254a:	d2258593          	addi	a1,a1,-734 # 80007268 <etext+0x268>
    8000254e:	00016517          	auipc	a0,0x16
    80002552:	f4a50513          	addi	a0,a0,-182 # 80018498 <tickslock>
    80002556:	e52fe0ef          	jal	80000ba8 <initlock>
}
    8000255a:	60a2                	ld	ra,8(sp)
    8000255c:	6402                	ld	s0,0(sp)
    8000255e:	0141                	addi	sp,sp,16
    80002560:	8082                	ret

0000000080002562 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002562:	1141                	addi	sp,sp,-16
    80002564:	e406                	sd	ra,8(sp)
    80002566:	e022                	sd	s0,0(sp)
    80002568:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    8000256a:	00003797          	auipc	a5,0x3
    8000256e:	17678793          	addi	a5,a5,374 # 800056e0 <kernelvec>
    80002572:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002576:	60a2                	ld	ra,8(sp)
    80002578:	6402                	ld	s0,0(sp)
    8000257a:	0141                	addi	sp,sp,16
    8000257c:	8082                	ret

000000008000257e <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000257e:	1141                	addi	sp,sp,-16
    80002580:	e406                	sd	ra,8(sp)
    80002582:	e022                	sd	s0,0(sp)
    80002584:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002586:	bc2ff0ef          	jal	80001948 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    8000258a:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000258e:	04000737          	lui	a4,0x4000
    80002592:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002594:	0732                	slli	a4,a4,0xc
    80002596:	00004797          	auipc	a5,0x4
    8000259a:	a6a78793          	addi	a5,a5,-1430 # 80006000 <_trampoline>
    8000259e:	00004697          	auipc	a3,0x4
    800025a2:	a6268693          	addi	a3,a3,-1438 # 80006000 <_trampoline>
    800025a6:	8f95                	sub	a5,a5,a3
    800025a8:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    800025aa:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800025ae:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    800025b0:	18002773          	csrr	a4,satp
    800025b4:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800025b6:	6d38                	ld	a4,88(a0)
    800025b8:	613c                	ld	a5,64(a0)
    800025ba:	6685                	lui	a3,0x1
    800025bc:	97b6                	add	a5,a5,a3
    800025be:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800025c0:	6d3c                	ld	a5,88(a0)
    800025c2:	00000717          	auipc	a4,0x0
    800025c6:	0fc70713          	addi	a4,a4,252 # 800026be <usertrap>
    800025ca:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800025cc:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    800025ce:	8712                	mv	a4,tp
    800025d0:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800025d2:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800025d6:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800025da:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800025de:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800025e2:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    800025e4:	6f9c                	ld	a5,24(a5)
    800025e6:	14179073          	csrw	sepc,a5
}
    800025ea:	60a2                	ld	ra,8(sp)
    800025ec:	6402                	ld	s0,0(sp)
    800025ee:	0141                	addi	sp,sp,16
    800025f0:	8082                	ret

00000000800025f2 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800025f2:	1141                	addi	sp,sp,-16
    800025f4:	e406                	sd	ra,8(sp)
    800025f6:	e022                	sd	s0,0(sp)
    800025f8:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    800025fa:	b1aff0ef          	jal	80001914 <cpuid>
    800025fe:	cd11                	beqz	a0,8000261a <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    80002600:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002604:	000f4737          	lui	a4,0xf4
    80002608:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000260c:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000260e:	14d79073          	csrw	stimecmp,a5
}
    80002612:	60a2                	ld	ra,8(sp)
    80002614:	6402                	ld	s0,0(sp)
    80002616:	0141                	addi	sp,sp,16
    80002618:	8082                	ret
    acquire(&tickslock);
    8000261a:	00016517          	auipc	a0,0x16
    8000261e:	e7e50513          	addi	a0,a0,-386 # 80018498 <tickslock>
    80002622:	e06fe0ef          	jal	80000c28 <acquire>
    ticks++;
    80002626:	00008717          	auipc	a4,0x8
    8000262a:	d4270713          	addi	a4,a4,-702 # 8000a368 <ticks>
    8000262e:	431c                	lw	a5,0(a4)
    80002630:	2785                	addiw	a5,a5,1
    80002632:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002634:	853a                	mv	a0,a4
    80002636:	a3dff0ef          	jal	80002072 <wakeup>
    release(&tickslock);
    8000263a:	00016517          	auipc	a0,0x16
    8000263e:	e5e50513          	addi	a0,a0,-418 # 80018498 <tickslock>
    80002642:	e6efe0ef          	jal	80000cb0 <release>
    80002646:	bf6d                	j	80002600 <clockintr+0xe>

0000000080002648 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002648:	1101                	addi	sp,sp,-32
    8000264a:	ec06                	sd	ra,24(sp)
    8000264c:	e822                	sd	s0,16(sp)
    8000264e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    80002650:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    80002654:	57fd                	li	a5,-1
    80002656:	17fe                	slli	a5,a5,0x3f
    80002658:	07a5                	addi	a5,a5,9
    8000265a:	00f70c63          	beq	a4,a5,80002672 <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    8000265e:	57fd                	li	a5,-1
    80002660:	17fe                	slli	a5,a5,0x3f
    80002662:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002664:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    80002666:	04f70863          	beq	a4,a5,800026b6 <devintr+0x6e>
  }
}
    8000266a:	60e2                	ld	ra,24(sp)
    8000266c:	6442                	ld	s0,16(sp)
    8000266e:	6105                	addi	sp,sp,32
    80002670:	8082                	ret
    80002672:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002674:	11a030ef          	jal	8000578e <plic_claim>
    80002678:	872a                	mv	a4,a0
    8000267a:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    8000267c:	47a9                	li	a5,10
    8000267e:	00f50963          	beq	a0,a5,80002690 <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    80002682:	4785                	li	a5,1
    80002684:	00f50963          	beq	a0,a5,80002696 <devintr+0x4e>
    return 1;
    80002688:	4505                	li	a0,1
    } else if (irq) {
    8000268a:	eb09                	bnez	a4,8000269c <devintr+0x54>
    8000268c:	64a2                	ld	s1,8(sp)
    8000268e:	bff1                	j	8000266a <devintr+0x22>
      uartintr();
    80002690:	b5efe0ef          	jal	800009ee <uartintr>
    if (irq)
    80002694:	a819                	j	800026aa <devintr+0x62>
      virtio_disk_intr();
    80002696:	5b4030ef          	jal	80005c4a <virtio_disk_intr>
    if (irq)
    8000269a:	a801                	j	800026aa <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    8000269c:	85ba                	mv	a1,a4
    8000269e:	00005517          	auipc	a0,0x5
    800026a2:	bd250513          	addi	a0,a0,-1070 # 80007270 <etext+0x270>
    800026a6:	e65fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    800026aa:	8526                	mv	a0,s1
    800026ac:	104030ef          	jal	800057b0 <plic_complete>
    return 1;
    800026b0:	4505                	li	a0,1
    800026b2:	64a2                	ld	s1,8(sp)
    800026b4:	bf5d                	j	8000266a <devintr+0x22>
    clockintr();
    800026b6:	f3dff0ef          	jal	800025f2 <clockintr>
    return 2;
    800026ba:	4509                	li	a0,2
    800026bc:	b77d                	j	8000266a <devintr+0x22>

00000000800026be <usertrap>:
{
    800026be:	1101                	addi	sp,sp,-32
    800026c0:	ec06                	sd	ra,24(sp)
    800026c2:	e822                	sd	s0,16(sp)
    800026c4:	e426                	sd	s1,8(sp)
    800026c6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800026c8:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    800026cc:	1007f793          	andi	a5,a5,256
    800026d0:	e7bd                	bnez	a5,8000273e <usertrap+0x80>
  asm volatile("csrw stvec, %0" : : "r"(x));
    800026d2:	00003797          	auipc	a5,0x3
    800026d6:	00e78793          	addi	a5,a5,14 # 800056e0 <kernelvec>
    800026da:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800026de:	a6aff0ef          	jal	80001948 <myproc>
    800026e2:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800026e4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    800026e6:	14102773          	csrr	a4,sepc
    800026ea:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    800026ec:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    800026f0:	47a1                	li	a5,8
    800026f2:	04f70c63          	beq	a4,a5,8000274a <usertrap+0x8c>
  } else if ((which_dev = devintr()) != 0) {
    800026f6:	f53ff0ef          	jal	80002648 <devintr>
    800026fa:	e13d                	bnez	a0,80002760 <usertrap+0xa2>
    800026fc:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002700:	47bd                	li	a5,15
    80002702:	08f70363          	beq	a4,a5,80002788 <usertrap+0xca>
    80002706:	14202773          	csrr	a4,scause
    8000270a:	47b5                	li	a5,13
    8000270c:	06f70e63          	beq	a4,a5,80002788 <usertrap+0xca>
    80002710:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002714:	5890                	lw	a2,48(s1)
    80002716:	00005517          	auipc	a0,0x5
    8000271a:	b9a50513          	addi	a0,a0,-1126 # 800072b0 <etext+0x2b0>
    8000271e:	dedfd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002722:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002726:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000272a:	00005517          	auipc	a0,0x5
    8000272e:	bb650513          	addi	a0,a0,-1098 # 800072e0 <etext+0x2e0>
    80002732:	dd9fd0ef          	jal	8000050a <printk>
    setkilled(p);
    80002736:	8526                	mv	a0,s1
    80002738:	b09ff0ef          	jal	80002240 <setkilled>
    8000273c:	a015                	j	80002760 <usertrap+0xa2>
    panic("usertrap: not from user mode");
    8000273e:	00005517          	auipc	a0,0x5
    80002742:	b5250513          	addi	a0,a0,-1198 # 80007290 <etext+0x290>
    80002746:	8eefe0ef          	jal	80000834 <panic>
    if (killed(p))
    8000274a:	b1bff0ef          	jal	80002264 <killed>
    8000274e:	e90d                	bnez	a0,80002780 <usertrap+0xc2>
    p->trapframe->epc += 4;
    80002750:	6cb8                	ld	a4,88(s1)
    80002752:	6f1c                	ld	a5,24(a4)
    80002754:	0791                	addi	a5,a5,4
    80002756:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80002758:	10016073          	csrsi	sstatus,2
    syscall();
    8000275c:	21a000ef          	jal	80002976 <syscall>
  if (killed(p))
    80002760:	8526                	mv	a0,s1
    80002762:	b03ff0ef          	jal	80002264 <killed>
    80002766:	ed15                	bnez	a0,800027a2 <usertrap+0xe4>
  prepare_return();
    80002768:	e17ff0ef          	jal	8000257e <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000276c:	68a8                	ld	a0,80(s1)
    8000276e:	8131                	srli	a0,a0,0xc
}
    80002770:	57fd                	li	a5,-1
    80002772:	17fe                	slli	a5,a5,0x3f
    80002774:	8d5d                	or	a0,a0,a5
    80002776:	60e2                	ld	ra,24(sp)
    80002778:	6442                	ld	s0,16(sp)
    8000277a:	64a2                	ld	s1,8(sp)
    8000277c:	6105                	addi	sp,sp,32
    8000277e:	8082                	ret
      kexit(-1);
    80002780:	557d                	li	a0,-1
    80002782:	9adff0ef          	jal	8000212e <kexit>
    80002786:	b7e9                	j	80002750 <usertrap+0x92>
  asm volatile("csrr %0, stval" : "=r"(x));
    80002788:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    8000278c:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    80002790:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    80002792:	0016b693          	seqz	a3,a3
    80002796:	64ac                	ld	a1,72(s1)
    80002798:	68a8                	ld	a0,80(s1)
    8000279a:	d6dfe0ef          	jal	80001506 <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    8000279e:	f169                	bnez	a0,80002760 <usertrap+0xa2>
    800027a0:	bf85                	j	80002710 <usertrap+0x52>
    kexit(-1);
    800027a2:	557d                	li	a0,-1
    800027a4:	98bff0ef          	jal	8000212e <kexit>
    800027a8:	b7c1                	j	80002768 <usertrap+0xaa>

00000000800027aa <kerneltrap>:
{
    800027aa:	7179                	addi	sp,sp,-48
    800027ac:	f406                	sd	ra,40(sp)
    800027ae:	f022                	sd	s0,32(sp)
    800027b0:	ec26                	sd	s1,24(sp)
    800027b2:	e84a                	sd	s2,16(sp)
    800027b4:	e44e                	sd	s3,8(sp)
    800027b6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    800027b8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800027bc:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    800027c0:	142027f3          	csrr	a5,scause
    800027c4:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    800027c6:	1004f793          	andi	a5,s1,256
    800027ca:	c39d                	beqz	a5,800027f0 <kerneltrap+0x46>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800027cc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800027d0:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    800027d2:	e78d                	bnez	a5,800027fc <kerneltrap+0x52>
  if ((which_dev = devintr()) == 0) {
    800027d4:	e75ff0ef          	jal	80002648 <devintr>
    800027d8:	c905                	beqz	a0,80002808 <kerneltrap+0x5e>
  asm volatile("csrw sepc, %0" : : "r"(x));
    800027da:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800027de:	10049073          	csrw	sstatus,s1
}
    800027e2:	70a2                	ld	ra,40(sp)
    800027e4:	7402                	ld	s0,32(sp)
    800027e6:	64e2                	ld	s1,24(sp)
    800027e8:	6942                	ld	s2,16(sp)
    800027ea:	69a2                	ld	s3,8(sp)
    800027ec:	6145                	addi	sp,sp,48
    800027ee:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800027f0:	00005517          	auipc	a0,0x5
    800027f4:	b1850513          	addi	a0,a0,-1256 # 80007308 <etext+0x308>
    800027f8:	83cfe0ef          	jal	80000834 <panic>
    panic("kerneltrap: interrupts enabled");
    800027fc:	00005517          	auipc	a0,0x5
    80002800:	b3450513          	addi	a0,a0,-1228 # 80007330 <etext+0x330>
    80002804:	830fe0ef          	jal	80000834 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002808:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    8000280c:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    80002810:	85ce                	mv	a1,s3
    80002812:	00005517          	auipc	a0,0x5
    80002816:	b3e50513          	addi	a0,a0,-1218 # 80007350 <etext+0x350>
    8000281a:	cf1fd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    8000281e:	00005517          	auipc	a0,0x5
    80002822:	b5a50513          	addi	a0,a0,-1190 # 80007378 <etext+0x378>
    80002826:	80efe0ef          	jal	80000834 <panic>

000000008000282a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000282a:	1101                	addi	sp,sp,-32
    8000282c:	ec06                	sd	ra,24(sp)
    8000282e:	e822                	sd	s0,16(sp)
    80002830:	e426                	sd	s1,8(sp)
    80002832:	1000                	addi	s0,sp,32
    80002834:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002836:	912ff0ef          	jal	80001948 <myproc>
  switch (n) {
    8000283a:	4795                	li	a5,5
    8000283c:	0497e163          	bltu	a5,s1,8000287e <argraw+0x54>
    80002840:	048a                	slli	s1,s1,0x2
    80002842:	00005717          	auipc	a4,0x5
    80002846:	f3670713          	addi	a4,a4,-202 # 80007778 <states.0+0x30>
    8000284a:	94ba                	add	s1,s1,a4
    8000284c:	409c                	lw	a5,0(s1)
    8000284e:	97ba                	add	a5,a5,a4
    80002850:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002852:	6d3c                	ld	a5,88(a0)
    80002854:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002856:	60e2                	ld	ra,24(sp)
    80002858:	6442                	ld	s0,16(sp)
    8000285a:	64a2                	ld	s1,8(sp)
    8000285c:	6105                	addi	sp,sp,32
    8000285e:	8082                	ret
    return p->trapframe->a1;
    80002860:	6d3c                	ld	a5,88(a0)
    80002862:	7fa8                	ld	a0,120(a5)
    80002864:	bfcd                	j	80002856 <argraw+0x2c>
    return p->trapframe->a2;
    80002866:	6d3c                	ld	a5,88(a0)
    80002868:	63c8                	ld	a0,128(a5)
    8000286a:	b7f5                	j	80002856 <argraw+0x2c>
    return p->trapframe->a3;
    8000286c:	6d3c                	ld	a5,88(a0)
    8000286e:	67c8                	ld	a0,136(a5)
    80002870:	b7dd                	j	80002856 <argraw+0x2c>
    return p->trapframe->a4;
    80002872:	6d3c                	ld	a5,88(a0)
    80002874:	6bc8                	ld	a0,144(a5)
    80002876:	b7c5                	j	80002856 <argraw+0x2c>
    return p->trapframe->a5;
    80002878:	6d3c                	ld	a5,88(a0)
    8000287a:	6fc8                	ld	a0,152(a5)
    8000287c:	bfe9                	j	80002856 <argraw+0x2c>
  panic("argraw");
    8000287e:	00005517          	auipc	a0,0x5
    80002882:	b0a50513          	addi	a0,a0,-1270 # 80007388 <etext+0x388>
    80002886:	faffd0ef          	jal	80000834 <panic>

000000008000288a <fetchaddr>:
{
    8000288a:	1101                	addi	sp,sp,-32
    8000288c:	ec06                	sd	ra,24(sp)
    8000288e:	e822                	sd	s0,16(sp)
    80002890:	e426                	sd	s1,8(sp)
    80002892:	e04a                	sd	s2,0(sp)
    80002894:	1000                	addi	s0,sp,32
    80002896:	84aa                	mv	s1,a0
    80002898:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000289a:	8aeff0ef          	jal	80001948 <myproc>
  if (addr >= p->sz ||
    8000289e:	652c                	ld	a1,72(a0)
    800028a0:	02b4f663          	bgeu	s1,a1,800028cc <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800028a4:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    800028a8:	02f5e463          	bltu	a1,a5,800028d0 <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    800028ac:	4721                	li	a4,8
    800028ae:	86a6                	mv	a3,s1
    800028b0:	864a                	mv	a2,s2
    800028b2:	6928                	ld	a0,80(a0)
    800028b4:	d95fe0ef          	jal	80001648 <copyin>
    800028b8:	00a03533          	snez	a0,a0
    800028bc:	40a0053b          	negw	a0,a0
}
    800028c0:	60e2                	ld	ra,24(sp)
    800028c2:	6442                	ld	s0,16(sp)
    800028c4:	64a2                	ld	s1,8(sp)
    800028c6:	6902                	ld	s2,0(sp)
    800028c8:	6105                	addi	sp,sp,32
    800028ca:	8082                	ret
    return -1;
    800028cc:	557d                	li	a0,-1
    800028ce:	bfcd                	j	800028c0 <fetchaddr+0x36>
    800028d0:	557d                	li	a0,-1
    800028d2:	b7fd                	j	800028c0 <fetchaddr+0x36>

00000000800028d4 <fetchstr>:
{
    800028d4:	7179                	addi	sp,sp,-48
    800028d6:	f406                	sd	ra,40(sp)
    800028d8:	f022                	sd	s0,32(sp)
    800028da:	ec26                	sd	s1,24(sp)
    800028dc:	e84a                	sd	s2,16(sp)
    800028de:	e44e                	sd	s3,8(sp)
    800028e0:	1800                	addi	s0,sp,48
    800028e2:	89aa                	mv	s3,a0
    800028e4:	84ae                	mv	s1,a1
    800028e6:	8932                	mv	s2,a2
  struct proc *p = myproc();
    800028e8:	860ff0ef          	jal	80001948 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    800028ec:	874a                	mv	a4,s2
    800028ee:	86ce                	mv	a3,s3
    800028f0:	8626                	mv	a2,s1
    800028f2:	652c                	ld	a1,72(a0)
    800028f4:	6928                	ld	a0,80(a0)
    800028f6:	deffe0ef          	jal	800016e4 <copyinstr>
    800028fa:	00054c63          	bltz	a0,80002912 <fetchstr+0x3e>
  return strlen(buf);
    800028fe:	8526                	mv	a0,s1
    80002900:	d72fe0ef          	jal	80000e72 <strlen>
}
    80002904:	70a2                	ld	ra,40(sp)
    80002906:	7402                	ld	s0,32(sp)
    80002908:	64e2                	ld	s1,24(sp)
    8000290a:	6942                	ld	s2,16(sp)
    8000290c:	69a2                	ld	s3,8(sp)
    8000290e:	6145                	addi	sp,sp,48
    80002910:	8082                	ret
    return -1;
    80002912:	557d                	li	a0,-1
    80002914:	bfc5                	j	80002904 <fetchstr+0x30>

0000000080002916 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002916:	1101                	addi	sp,sp,-32
    80002918:	ec06                	sd	ra,24(sp)
    8000291a:	e822                	sd	s0,16(sp)
    8000291c:	e426                	sd	s1,8(sp)
    8000291e:	1000                	addi	s0,sp,32
    80002920:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002922:	f09ff0ef          	jal	8000282a <argraw>
    80002926:	c088                	sw	a0,0(s1)
}
    80002928:	60e2                	ld	ra,24(sp)
    8000292a:	6442                	ld	s0,16(sp)
    8000292c:	64a2                	ld	s1,8(sp)
    8000292e:	6105                	addi	sp,sp,32
    80002930:	8082                	ret

0000000080002932 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002932:	1101                	addi	sp,sp,-32
    80002934:	ec06                	sd	ra,24(sp)
    80002936:	e822                	sd	s0,16(sp)
    80002938:	e426                	sd	s1,8(sp)
    8000293a:	1000                	addi	s0,sp,32
    8000293c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000293e:	eedff0ef          	jal	8000282a <argraw>
    80002942:	e088                	sd	a0,0(s1)
}
    80002944:	60e2                	ld	ra,24(sp)
    80002946:	6442                	ld	s0,16(sp)
    80002948:	64a2                	ld	s1,8(sp)
    8000294a:	6105                	addi	sp,sp,32
    8000294c:	8082                	ret

000000008000294e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000294e:	1101                	addi	sp,sp,-32
    80002950:	ec06                	sd	ra,24(sp)
    80002952:	e822                	sd	s0,16(sp)
    80002954:	e426                	sd	s1,8(sp)
    80002956:	e04a                	sd	s2,0(sp)
    80002958:	1000                	addi	s0,sp,32
    8000295a:	892e                	mv	s2,a1
    8000295c:	84b2                	mv	s1,a2
  *ip = argraw(n);
    8000295e:	ecdff0ef          	jal	8000282a <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002962:	8626                	mv	a2,s1
    80002964:	85ca                	mv	a1,s2
    80002966:	f6fff0ef          	jal	800028d4 <fetchstr>
}
    8000296a:	60e2                	ld	ra,24(sp)
    8000296c:	6442                	ld	s0,16(sp)
    8000296e:	64a2                	ld	s1,8(sp)
    80002970:	6902                	ld	s2,0(sp)
    80002972:	6105                	addi	sp,sp,32
    80002974:	8082                	ret

0000000080002976 <syscall>:
  // clang-format on
};

void
syscall(void)
{
    80002976:	1101                	addi	sp,sp,-32
    80002978:	ec06                	sd	ra,24(sp)
    8000297a:	e822                	sd	s0,16(sp)
    8000297c:	e426                	sd	s1,8(sp)
    8000297e:	e04a                	sd	s2,0(sp)
    80002980:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002982:	fc7fe0ef          	jal	80001948 <myproc>
    80002986:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002988:	05853903          	ld	s2,88(a0)
    8000298c:	0a893783          	ld	a5,168(s2)
    80002990:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002994:	37fd                	addiw	a5,a5,-1
    80002996:	4759                	li	a4,22
    80002998:	00f76f63          	bltu	a4,a5,800029b6 <syscall+0x40>
    8000299c:	00369713          	slli	a4,a3,0x3
    800029a0:	00005797          	auipc	a5,0x5
    800029a4:	df078793          	addi	a5,a5,-528 # 80007790 <syscalls>
    800029a8:	97ba                	add	a5,a5,a4
    800029aa:	639c                	ld	a5,0(a5)
    800029ac:	c789                	beqz	a5,800029b6 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800029ae:	9782                	jalr	a5
    800029b0:	06a93823          	sd	a0,112(s2)
    800029b4:	a829                	j	800029ce <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    800029b6:	15848613          	addi	a2,s1,344
    800029ba:	588c                	lw	a1,48(s1)
    800029bc:	00005517          	auipc	a0,0x5
    800029c0:	9d450513          	addi	a0,a0,-1580 # 80007390 <etext+0x390>
    800029c4:	b47fd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    800029c8:	6cbc                	ld	a5,88(s1)
    800029ca:	577d                	li	a4,-1
    800029cc:	fbb8                	sd	a4,112(a5)
  }
}
    800029ce:	60e2                	ld	ra,24(sp)
    800029d0:	6442                	ld	s0,16(sp)
    800029d2:	64a2                	ld	s1,8(sp)
    800029d4:	6902                	ld	s2,0(sp)
    800029d6:	6105                	addi	sp,sp,32
    800029d8:	8082                	ret

00000000800029da <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    800029da:	1101                	addi	sp,sp,-32
    800029dc:	ec06                	sd	ra,24(sp)
    800029de:	e822                	sd	s0,16(sp)
    800029e0:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800029e2:	fec40593          	addi	a1,s0,-20
    800029e6:	4501                	li	a0,0
    800029e8:	f2fff0ef          	jal	80002916 <argint>
  kexit(n);
    800029ec:	fec42503          	lw	a0,-20(s0)
    800029f0:	f3eff0ef          	jal	8000212e <kexit>
  return 0; // not reached
}
    800029f4:	4501                	li	a0,0
    800029f6:	60e2                	ld	ra,24(sp)
    800029f8:	6442                	ld	s0,16(sp)
    800029fa:	6105                	addi	sp,sp,32
    800029fc:	8082                	ret

00000000800029fe <sys_getpid>:

uint64
sys_getpid(void)
{
    800029fe:	1141                	addi	sp,sp,-16
    80002a00:	e406                	sd	ra,8(sp)
    80002a02:	e022                	sd	s0,0(sp)
    80002a04:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002a06:	f43fe0ef          	jal	80001948 <myproc>
}
    80002a0a:	5908                	lw	a0,48(a0)
    80002a0c:	60a2                	ld	ra,8(sp)
    80002a0e:	6402                	ld	s0,0(sp)
    80002a10:	0141                	addi	sp,sp,16
    80002a12:	8082                	ret

0000000080002a14 <sys_fork>:

uint64
sys_fork(void)
{
    80002a14:	1141                	addi	sp,sp,-16
    80002a16:	e406                	sd	ra,8(sp)
    80002a18:	e022                	sd	s0,0(sp)
    80002a1a:	0800                	addi	s0,sp,16
  return kfork();
    80002a1c:	a94ff0ef          	jal	80001cb0 <kfork>
}
    80002a20:	60a2                	ld	ra,8(sp)
    80002a22:	6402                	ld	s0,0(sp)
    80002a24:	0141                	addi	sp,sp,16
    80002a26:	8082                	ret

0000000080002a28 <sys_wait>:

uint64
sys_wait(void)
{
    80002a28:	1101                	addi	sp,sp,-32
    80002a2a:	ec06                	sd	ra,24(sp)
    80002a2c:	e822                	sd	s0,16(sp)
    80002a2e:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002a30:	fe840593          	addi	a1,s0,-24
    80002a34:	4501                	li	a0,0
    80002a36:	efdff0ef          	jal	80002932 <argaddr>
  return kwait(p);
    80002a3a:	fe843503          	ld	a0,-24(s0)
    80002a3e:	851ff0ef          	jal	8000228e <kwait>
}
    80002a42:	60e2                	ld	ra,24(sp)
    80002a44:	6442                	ld	s0,16(sp)
    80002a46:	6105                	addi	sp,sp,32
    80002a48:	8082                	ret

0000000080002a4a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002a4a:	7179                	addi	sp,sp,-48
    80002a4c:	f406                	sd	ra,40(sp)
    80002a4e:	f022                	sd	s0,32(sp)
    80002a50:	ec26                	sd	s1,24(sp)
    80002a52:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002a54:	fd840593          	addi	a1,s0,-40
    80002a58:	4501                	li	a0,0
    80002a5a:	ebdff0ef          	jal	80002916 <argint>
  argint(1, &t);
    80002a5e:	fdc40593          	addi	a1,s0,-36
    80002a62:	4505                	li	a0,1
    80002a64:	eb3ff0ef          	jal	80002916 <argint>
  addr = myproc()->sz;
    80002a68:	ee1fe0ef          	jal	80001948 <myproc>
    80002a6c:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002a6e:	fdc42703          	lw	a4,-36(s0)
    80002a72:	4785                	li	a5,1
    80002a74:	02f70763          	beq	a4,a5,80002aa2 <sys_sbrk+0x58>
    80002a78:	fd842783          	lw	a5,-40(s0)
    80002a7c:	0207c363          	bltz	a5,80002aa2 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002a80:	97a6                	add	a5,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    80002a82:	02000737          	lui	a4,0x2000
    80002a86:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002a88:	0736                	slli	a4,a4,0xd
    80002a8a:	02f76a63          	bltu	a4,a5,80002abe <sys_sbrk+0x74>
    80002a8e:	0297e863          	bltu	a5,s1,80002abe <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002a92:	eb7fe0ef          	jal	80001948 <myproc>
    80002a96:	fd842703          	lw	a4,-40(s0)
    80002a9a:	653c                	ld	a5,72(a0)
    80002a9c:	97ba                	add	a5,a5,a4
    80002a9e:	e53c                	sd	a5,72(a0)
    80002aa0:	a039                	j	80002aae <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002aa2:	fd842503          	lw	a0,-40(s0)
    80002aa6:	9a8ff0ef          	jal	80001c4e <growproc>
    80002aaa:	00054863          	bltz	a0,80002aba <sys_sbrk+0x70>
  }
  return addr;
}
    80002aae:	8526                	mv	a0,s1
    80002ab0:	70a2                	ld	ra,40(sp)
    80002ab2:	7402                	ld	s0,32(sp)
    80002ab4:	64e2                	ld	s1,24(sp)
    80002ab6:	6145                	addi	sp,sp,48
    80002ab8:	8082                	ret
      return -1;
    80002aba:	54fd                	li	s1,-1
    80002abc:	bfcd                	j	80002aae <sys_sbrk+0x64>
      return -1;
    80002abe:	54fd                	li	s1,-1
    80002ac0:	b7fd                	j	80002aae <sys_sbrk+0x64>

0000000080002ac2 <sys_pause>:

uint64
sys_pause(void)
{
    80002ac2:	7139                	addi	sp,sp,-64
    80002ac4:	fc06                	sd	ra,56(sp)
    80002ac6:	f822                	sd	s0,48(sp)
    80002ac8:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002aca:	fcc40593          	addi	a1,s0,-52
    80002ace:	4501                	li	a0,0
    80002ad0:	e47ff0ef          	jal	80002916 <argint>
  if (n < 0)
    80002ad4:	fcc42783          	lw	a5,-52(s0)
    80002ad8:	0807c063          	bltz	a5,80002b58 <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002adc:	00016517          	auipc	a0,0x16
    80002ae0:	9bc50513          	addi	a0,a0,-1604 # 80018498 <tickslock>
    80002ae4:	944fe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002ae8:	fcc42783          	lw	a5,-52(s0)
    80002aec:	cbb9                	beqz	a5,80002b42 <sys_pause+0x80>
    80002aee:	f426                	sd	s1,40(sp)
    80002af0:	f04a                	sd	s2,32(sp)
    80002af2:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002af4:	00008997          	auipc	s3,0x8
    80002af8:	8749a983          	lw	s3,-1932(s3) # 8000a368 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002afc:	00008917          	auipc	s2,0x8
    80002b00:	86c90913          	addi	s2,s2,-1940 # 8000a368 <ticks>
    release(&tickslock);
    80002b04:	00016497          	auipc	s1,0x16
    80002b08:	99448493          	addi	s1,s1,-1644 # 80018498 <tickslock>
    if (killed(myproc())) {
    80002b0c:	e3dfe0ef          	jal	80001948 <myproc>
    80002b10:	f54ff0ef          	jal	80002264 <killed>
    80002b14:	e529                	bnez	a0,80002b5e <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002b16:	854a                	mv	a0,s2
    80002b18:	ceeff0ef          	jal	80002006 <sleep_prepare>
    release(&tickslock);
    80002b1c:	8526                	mv	a0,s1
    80002b1e:	992fe0ef          	jal	80000cb0 <release>
    sleep();
    80002b22:	d20ff0ef          	jal	80002042 <sleep>
    acquire(&tickslock);
    80002b26:	8526                	mv	a0,s1
    80002b28:	900fe0ef          	jal	80000c28 <acquire>
  while (ticks - ticks0 < n) {
    80002b2c:	00092783          	lw	a5,0(s2)
    80002b30:	413787bb          	subw	a5,a5,s3
    80002b34:	fcc42703          	lw	a4,-52(s0)
    80002b38:	fce7eae3          	bltu	a5,a4,80002b0c <sys_pause+0x4a>
    80002b3c:	74a2                	ld	s1,40(sp)
    80002b3e:	7902                	ld	s2,32(sp)
    80002b40:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002b42:	00016517          	auipc	a0,0x16
    80002b46:	95650513          	addi	a0,a0,-1706 # 80018498 <tickslock>
    80002b4a:	966fe0ef          	jal	80000cb0 <release>
  return 0;
    80002b4e:	4501                	li	a0,0
}
    80002b50:	70e2                	ld	ra,56(sp)
    80002b52:	7442                	ld	s0,48(sp)
    80002b54:	6121                	addi	sp,sp,64
    80002b56:	8082                	ret
    n = 0;
    80002b58:	fc042623          	sw	zero,-52(s0)
    80002b5c:	b741                	j	80002adc <sys_pause+0x1a>
      release(&tickslock);
    80002b5e:	00016517          	auipc	a0,0x16
    80002b62:	93a50513          	addi	a0,a0,-1734 # 80018498 <tickslock>
    80002b66:	94afe0ef          	jal	80000cb0 <release>
      return -1;
    80002b6a:	557d                	li	a0,-1
    80002b6c:	74a2                	ld	s1,40(sp)
    80002b6e:	7902                	ld	s2,32(sp)
    80002b70:	69e2                	ld	s3,24(sp)
    80002b72:	bff9                	j	80002b50 <sys_pause+0x8e>

0000000080002b74 <sys_kill>:

uint64
sys_kill(void)
{
    80002b74:	1101                	addi	sp,sp,-32
    80002b76:	ec06                	sd	ra,24(sp)
    80002b78:	e822                	sd	s0,16(sp)
    80002b7a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002b7c:	fec40593          	addi	a1,s0,-20
    80002b80:	4501                	li	a0,0
    80002b82:	d95ff0ef          	jal	80002916 <argint>
  return kkill(pid);
    80002b86:	fec42503          	lw	a0,-20(s0)
    80002b8a:	e4aff0ef          	jal	800021d4 <kkill>
}
    80002b8e:	60e2                	ld	ra,24(sp)
    80002b90:	6442                	ld	s0,16(sp)
    80002b92:	6105                	addi	sp,sp,32
    80002b94:	8082                	ret

0000000080002b96 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002b96:	1101                	addi	sp,sp,-32
    80002b98:	ec06                	sd	ra,24(sp)
    80002b9a:	e822                	sd	s0,16(sp)
    80002b9c:	e426                	sd	s1,8(sp)
    80002b9e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ba0:	00016517          	auipc	a0,0x16
    80002ba4:	8f850513          	addi	a0,a0,-1800 # 80018498 <tickslock>
    80002ba8:	880fe0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002bac:	00007797          	auipc	a5,0x7
    80002bb0:	7bc7a783          	lw	a5,1980(a5) # 8000a368 <ticks>
    80002bb4:	84be                	mv	s1,a5
  release(&tickslock);
    80002bb6:	00016517          	auipc	a0,0x16
    80002bba:	8e250513          	addi	a0,a0,-1822 # 80018498 <tickslock>
    80002bbe:	8f2fe0ef          	jal	80000cb0 <release>
  return xticks;
}
    80002bc2:	02049513          	slli	a0,s1,0x20
    80002bc6:	9101                	srli	a0,a0,0x20
    80002bc8:	60e2                	ld	ra,24(sp)
    80002bca:	6442                	ld	s0,16(sp)
    80002bcc:	64a2                	ld	s1,8(sp)
    80002bce:	6105                	addi	sp,sp,32
    80002bd0:	8082                	ret

0000000080002bd2 <sys_set_burst>:

// Question 3: System call to set process burst time for SJF
uint64
sys_set_burst(void)
{
    80002bd2:	1101                	addi	sp,sp,-32
    80002bd4:	ec06                	sd	ra,24(sp)
    80002bd6:	e822                	sd	s0,16(sp)
    80002bd8:	1000                	addi	s0,sp,32
  int pid;
  int bt;

  argint(0, &pid);
    80002bda:	fec40593          	addi	a1,s0,-20
    80002bde:	4501                	li	a0,0
    80002be0:	d37ff0ef          	jal	80002916 <argint>
  argint(1, &bt);
    80002be4:	fe840593          	addi	a1,s0,-24
    80002be8:	4505                	li	a0,1
    80002bea:	d2dff0ef          	jal	80002916 <argint>
  return set_burst(pid, bt);
    80002bee:	fe842583          	lw	a1,-24(s0)
    80002bf2:	fec42503          	lw	a0,-20(s0)
    80002bf6:	9c8ff0ef          	jal	80001dbe <set_burst>
}
    80002bfa:	60e2                	ld	ra,24(sp)
    80002bfc:	6442                	ld	s0,16(sp)
    80002bfe:	6105                	addi	sp,sp,32
    80002c00:	8082                	ret

0000000080002c02 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002c02:	7179                	addi	sp,sp,-48
    80002c04:	f406                	sd	ra,40(sp)
    80002c06:	f022                	sd	s0,32(sp)
    80002c08:	ec26                	sd	s1,24(sp)
    80002c0a:	e84a                	sd	s2,16(sp)
    80002c0c:	e44e                	sd	s3,8(sp)
    80002c0e:	e052                	sd	s4,0(sp)
    80002c10:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002c12:	00004597          	auipc	a1,0x4
    80002c16:	79e58593          	addi	a1,a1,1950 # 800073b0 <etext+0x3b0>
    80002c1a:	00016517          	auipc	a0,0x16
    80002c1e:	89650513          	addi	a0,a0,-1898 # 800184b0 <bcache>
    80002c22:	f87fd0ef          	jal	80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002c26:	0001e797          	auipc	a5,0x1e
    80002c2a:	88a78793          	addi	a5,a5,-1910 # 800204b0 <bcache+0x8000>
    80002c2e:	0001e717          	auipc	a4,0x1e
    80002c32:	aea70713          	addi	a4,a4,-1302 # 80020718 <bcache+0x8268>
    80002c36:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002c3a:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002c3e:	00016497          	auipc	s1,0x16
    80002c42:	88a48493          	addi	s1,s1,-1910 # 800184c8 <bcache+0x18>
    b->next = bcache.head.next;
    80002c46:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002c48:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002c4a:	00004a17          	auipc	s4,0x4
    80002c4e:	76ea0a13          	addi	s4,s4,1902 # 800073b8 <etext+0x3b8>
    b->next = bcache.head.next;
    80002c52:	2b893783          	ld	a5,696(s2)
    80002c56:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002c58:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002c5c:	85d2                	mv	a1,s4
    80002c5e:	01048513          	addi	a0,s1,16
    80002c62:	41c010ef          	jal	8000407e <initsleeplock>
    bcache.head.next->prev = b;
    80002c66:	2b893783          	ld	a5,696(s2)
    80002c6a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002c6c:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002c70:	45848493          	addi	s1,s1,1112
    80002c74:	fd349fe3          	bne	s1,s3,80002c52 <binit+0x50>
  }
}
    80002c78:	70a2                	ld	ra,40(sp)
    80002c7a:	7402                	ld	s0,32(sp)
    80002c7c:	64e2                	ld	s1,24(sp)
    80002c7e:	6942                	ld	s2,16(sp)
    80002c80:	69a2                	ld	s3,8(sp)
    80002c82:	6a02                	ld	s4,0(sp)
    80002c84:	6145                	addi	sp,sp,48
    80002c86:	8082                	ret

0000000080002c88 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002c88:	7179                	addi	sp,sp,-48
    80002c8a:	f406                	sd	ra,40(sp)
    80002c8c:	f022                	sd	s0,32(sp)
    80002c8e:	ec26                	sd	s1,24(sp)
    80002c90:	e84a                	sd	s2,16(sp)
    80002c92:	e44e                	sd	s3,8(sp)
    80002c94:	1800                	addi	s0,sp,48
    80002c96:	892a                	mv	s2,a0
    80002c98:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002c9a:	00016517          	auipc	a0,0x16
    80002c9e:	81650513          	addi	a0,a0,-2026 # 800184b0 <bcache>
    80002ca2:	f87fd0ef          	jal	80000c28 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002ca6:	0001e497          	auipc	s1,0x1e
    80002caa:	ac24b483          	ld	s1,-1342(s1) # 80020768 <bcache+0x82b8>
    80002cae:	0001e797          	auipc	a5,0x1e
    80002cb2:	a6a78793          	addi	a5,a5,-1430 # 80020718 <bcache+0x8268>
    80002cb6:	02f48b63          	beq	s1,a5,80002cec <bread+0x64>
    80002cba:	873e                	mv	a4,a5
    80002cbc:	a021                	j	80002cc4 <bread+0x3c>
    80002cbe:	68a4                	ld	s1,80(s1)
    80002cc0:	02e48663          	beq	s1,a4,80002cec <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002cc4:	449c                	lw	a5,8(s1)
    80002cc6:	ff279ce3          	bne	a5,s2,80002cbe <bread+0x36>
    80002cca:	44dc                	lw	a5,12(s1)
    80002ccc:	ff3799e3          	bne	a5,s3,80002cbe <bread+0x36>
      b->refcnt++;
    80002cd0:	40bc                	lw	a5,64(s1)
    80002cd2:	2785                	addiw	a5,a5,1
    80002cd4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002cd6:	00015517          	auipc	a0,0x15
    80002cda:	7da50513          	addi	a0,a0,2010 # 800184b0 <bcache>
    80002cde:	fd3fd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002ce2:	01048513          	addi	a0,s1,16
    80002ce6:	3ce010ef          	jal	800040b4 <acquiresleep>
      return b;
    80002cea:	a889                	j	80002d3c <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002cec:	0001e497          	auipc	s1,0x1e
    80002cf0:	a744b483          	ld	s1,-1420(s1) # 80020760 <bcache+0x82b0>
    80002cf4:	0001e797          	auipc	a5,0x1e
    80002cf8:	a2478793          	addi	a5,a5,-1500 # 80020718 <bcache+0x8268>
    80002cfc:	00f48863          	beq	s1,a5,80002d0c <bread+0x84>
    80002d00:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002d02:	40bc                	lw	a5,64(s1)
    80002d04:	cb91                	beqz	a5,80002d18 <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002d06:	64a4                	ld	s1,72(s1)
    80002d08:	fee49de3          	bne	s1,a4,80002d02 <bread+0x7a>
  panic("bget: no buffers");
    80002d0c:	00004517          	auipc	a0,0x4
    80002d10:	6b450513          	addi	a0,a0,1716 # 800073c0 <etext+0x3c0>
    80002d14:	b21fd0ef          	jal	80000834 <panic>
      b->dev = dev;
    80002d18:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002d1c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002d20:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002d24:	4785                	li	a5,1
    80002d26:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d28:	00015517          	auipc	a0,0x15
    80002d2c:	78850513          	addi	a0,a0,1928 # 800184b0 <bcache>
    80002d30:	f81fd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002d34:	01048513          	addi	a0,s1,16
    80002d38:	37c010ef          	jal	800040b4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002d3c:	409c                	lw	a5,0(s1)
    80002d3e:	cb89                	beqz	a5,80002d50 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002d40:	8526                	mv	a0,s1
    80002d42:	70a2                	ld	ra,40(sp)
    80002d44:	7402                	ld	s0,32(sp)
    80002d46:	64e2                	ld	s1,24(sp)
    80002d48:	6942                	ld	s2,16(sp)
    80002d4a:	69a2                	ld	s3,8(sp)
    80002d4c:	6145                	addi	sp,sp,48
    80002d4e:	8082                	ret
    virtio_disk_rw(b, 0);
    80002d50:	4581                	li	a1,0
    80002d52:	8526                	mv	a0,s1
    80002d54:	4c3020ef          	jal	80005a16 <virtio_disk_rw>
    b->valid = 1;
    80002d58:	4785                	li	a5,1
    80002d5a:	c09c                	sw	a5,0(s1)
  return b;
    80002d5c:	b7d5                	j	80002d40 <bread+0xb8>

0000000080002d5e <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002d5e:	1101                	addi	sp,sp,-32
    80002d60:	ec06                	sd	ra,24(sp)
    80002d62:	e822                	sd	s0,16(sp)
    80002d64:	e426                	sd	s1,8(sp)
    80002d66:	1000                	addi	s0,sp,32
    80002d68:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002d6a:	0541                	addi	a0,a0,16
    80002d6c:	3d4010ef          	jal	80004140 <holdingsleep>
    80002d70:	c911                	beqz	a0,80002d84 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002d72:	4585                	li	a1,1
    80002d74:	8526                	mv	a0,s1
    80002d76:	4a1020ef          	jal	80005a16 <virtio_disk_rw>
}
    80002d7a:	60e2                	ld	ra,24(sp)
    80002d7c:	6442                	ld	s0,16(sp)
    80002d7e:	64a2                	ld	s1,8(sp)
    80002d80:	6105                	addi	sp,sp,32
    80002d82:	8082                	ret
    panic("bwrite");
    80002d84:	00004517          	auipc	a0,0x4
    80002d88:	65450513          	addi	a0,a0,1620 # 800073d8 <etext+0x3d8>
    80002d8c:	aa9fd0ef          	jal	80000834 <panic>

0000000080002d90 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002d90:	1101                	addi	sp,sp,-32
    80002d92:	ec06                	sd	ra,24(sp)
    80002d94:	e822                	sd	s0,16(sp)
    80002d96:	e426                	sd	s1,8(sp)
    80002d98:	e04a                	sd	s2,0(sp)
    80002d9a:	1000                	addi	s0,sp,32
    80002d9c:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002d9e:	01050913          	addi	s2,a0,16
    80002da2:	854a                	mv	a0,s2
    80002da4:	39c010ef          	jal	80004140 <holdingsleep>
    80002da8:	c125                	beqz	a0,80002e08 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002daa:	854a                	mv	a0,s2
    80002dac:	35c010ef          	jal	80004108 <releasesleep>

  acquire(&bcache.lock);
    80002db0:	00015517          	auipc	a0,0x15
    80002db4:	70050513          	addi	a0,a0,1792 # 800184b0 <bcache>
    80002db8:	e71fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002dbc:	40bc                	lw	a5,64(s1)
    80002dbe:	37fd                	addiw	a5,a5,-1
    80002dc0:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002dc2:	e79d                	bnez	a5,80002df0 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002dc4:	68b8                	ld	a4,80(s1)
    80002dc6:	64bc                	ld	a5,72(s1)
    80002dc8:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002dca:	68b8                	ld	a4,80(s1)
    80002dcc:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002dce:	0001d797          	auipc	a5,0x1d
    80002dd2:	6e278793          	addi	a5,a5,1762 # 800204b0 <bcache+0x8000>
    80002dd6:	2b87b703          	ld	a4,696(a5)
    80002dda:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002ddc:	0001e717          	auipc	a4,0x1e
    80002de0:	93c70713          	addi	a4,a4,-1732 # 80020718 <bcache+0x8268>
    80002de4:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002de6:	2b87b703          	ld	a4,696(a5)
    80002dea:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002dec:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002df0:	00015517          	auipc	a0,0x15
    80002df4:	6c050513          	addi	a0,a0,1728 # 800184b0 <bcache>
    80002df8:	eb9fd0ef          	jal	80000cb0 <release>
}
    80002dfc:	60e2                	ld	ra,24(sp)
    80002dfe:	6442                	ld	s0,16(sp)
    80002e00:	64a2                	ld	s1,8(sp)
    80002e02:	6902                	ld	s2,0(sp)
    80002e04:	6105                	addi	sp,sp,32
    80002e06:	8082                	ret
    panic("brelse");
    80002e08:	00004517          	auipc	a0,0x4
    80002e0c:	5d850513          	addi	a0,a0,1496 # 800073e0 <etext+0x3e0>
    80002e10:	a25fd0ef          	jal	80000834 <panic>

0000000080002e14 <bpin>:

void
bpin(struct buf *b)
{
    80002e14:	1101                	addi	sp,sp,-32
    80002e16:	ec06                	sd	ra,24(sp)
    80002e18:	e822                	sd	s0,16(sp)
    80002e1a:	e426                	sd	s1,8(sp)
    80002e1c:	1000                	addi	s0,sp,32
    80002e1e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e20:	00015517          	auipc	a0,0x15
    80002e24:	69050513          	addi	a0,a0,1680 # 800184b0 <bcache>
    80002e28:	e01fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002e2c:	40bc                	lw	a5,64(s1)
    80002e2e:	2785                	addiw	a5,a5,1
    80002e30:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e32:	00015517          	auipc	a0,0x15
    80002e36:	67e50513          	addi	a0,a0,1662 # 800184b0 <bcache>
    80002e3a:	e77fd0ef          	jal	80000cb0 <release>
}
    80002e3e:	60e2                	ld	ra,24(sp)
    80002e40:	6442                	ld	s0,16(sp)
    80002e42:	64a2                	ld	s1,8(sp)
    80002e44:	6105                	addi	sp,sp,32
    80002e46:	8082                	ret

0000000080002e48 <bunpin>:

void
bunpin(struct buf *b)
{
    80002e48:	1101                	addi	sp,sp,-32
    80002e4a:	ec06                	sd	ra,24(sp)
    80002e4c:	e822                	sd	s0,16(sp)
    80002e4e:	e426                	sd	s1,8(sp)
    80002e50:	1000                	addi	s0,sp,32
    80002e52:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e54:	00015517          	auipc	a0,0x15
    80002e58:	65c50513          	addi	a0,a0,1628 # 800184b0 <bcache>
    80002e5c:	dcdfd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002e60:	40bc                	lw	a5,64(s1)
    80002e62:	37fd                	addiw	a5,a5,-1
    80002e64:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e66:	00015517          	auipc	a0,0x15
    80002e6a:	64a50513          	addi	a0,a0,1610 # 800184b0 <bcache>
    80002e6e:	e43fd0ef          	jal	80000cb0 <release>
}
    80002e72:	60e2                	ld	ra,24(sp)
    80002e74:	6442                	ld	s0,16(sp)
    80002e76:	64a2                	ld	s1,8(sp)
    80002e78:	6105                	addi	sp,sp,32
    80002e7a:	8082                	ret

0000000080002e7c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002e7c:	1101                	addi	sp,sp,-32
    80002e7e:	ec06                	sd	ra,24(sp)
    80002e80:	e822                	sd	s0,16(sp)
    80002e82:	e426                	sd	s1,8(sp)
    80002e84:	e04a                	sd	s2,0(sp)
    80002e86:	1000                	addi	s0,sp,32
    80002e88:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002e8a:	00d5d79b          	srliw	a5,a1,0xd
    80002e8e:	0001e597          	auipc	a1,0x1e
    80002e92:	cfe5a583          	lw	a1,-770(a1) # 80020b8c <sb+0x1c>
    80002e96:	9dbd                	addw	a1,a1,a5
    80002e98:	df1ff0ef          	jal	80002c88 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002e9c:	0074f713          	andi	a4,s1,7
    80002ea0:	4785                	li	a5,1
    80002ea2:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002ea6:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80002ea8:	90d9                	srli	s1,s1,0x36
    80002eaa:	00950733          	add	a4,a0,s1
    80002eae:	05874703          	lbu	a4,88(a4)
    80002eb2:	00e7f6b3          	and	a3,a5,a4
    80002eb6:	c29d                	beqz	a3,80002edc <bfree+0x60>
    80002eb8:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002eba:	94aa                	add	s1,s1,a0
    80002ebc:	fff7c793          	not	a5,a5
    80002ec0:	8f7d                	and	a4,a4,a5
    80002ec2:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002ec6:	080010ef          	jal	80003f46 <log_write>
  brelse(bp);
    80002eca:	854a                	mv	a0,s2
    80002ecc:	ec5ff0ef          	jal	80002d90 <brelse>
}
    80002ed0:	60e2                	ld	ra,24(sp)
    80002ed2:	6442                	ld	s0,16(sp)
    80002ed4:	64a2                	ld	s1,8(sp)
    80002ed6:	6902                	ld	s2,0(sp)
    80002ed8:	6105                	addi	sp,sp,32
    80002eda:	8082                	ret
    panic("freeing free block");
    80002edc:	00004517          	auipc	a0,0x4
    80002ee0:	50c50513          	addi	a0,a0,1292 # 800073e8 <etext+0x3e8>
    80002ee4:	951fd0ef          	jal	80000834 <panic>

0000000080002ee8 <balloc>:
{
    80002ee8:	715d                	addi	sp,sp,-80
    80002eea:	e486                	sd	ra,72(sp)
    80002eec:	e0a2                	sd	s0,64(sp)
    80002eee:	fc26                	sd	s1,56(sp)
    80002ef0:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80002ef2:	0001e797          	auipc	a5,0x1e
    80002ef6:	c827a783          	lw	a5,-894(a5) # 80020b74 <sb+0x4>
    80002efa:	0e078263          	beqz	a5,80002fde <balloc+0xf6>
    80002efe:	f84a                	sd	s2,48(sp)
    80002f00:	f44e                	sd	s3,40(sp)
    80002f02:	f052                	sd	s4,32(sp)
    80002f04:	ec56                	sd	s5,24(sp)
    80002f06:	e85a                	sd	s6,16(sp)
    80002f08:	e45e                	sd	s7,8(sp)
    80002f0a:	e062                	sd	s8,0(sp)
    80002f0c:	8baa                	mv	s7,a0
    80002f0e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002f10:	0001eb17          	auipc	s6,0x1e
    80002f14:	c60b0b13          	addi	s6,s6,-928 # 80020b70 <sb>
      m = 1 << (bi % 8);
    80002f18:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002f1a:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80002f1c:	6c09                	lui	s8,0x2
    80002f1e:	a09d                	j	80002f84 <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80002f20:	97ca                	add	a5,a5,s2
    80002f22:	8e55                	or	a2,a2,a3
    80002f24:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002f28:	854a                	mv	a0,s2
    80002f2a:	01c010ef          	jal	80003f46 <log_write>
        brelse(bp);
    80002f2e:	854a                	mv	a0,s2
    80002f30:	e61ff0ef          	jal	80002d90 <brelse>
  bp = bread(dev, bno);
    80002f34:	85a6                	mv	a1,s1
    80002f36:	855e                	mv	a0,s7
    80002f38:	d51ff0ef          	jal	80002c88 <bread>
    80002f3c:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002f3e:	40000613          	li	a2,1024
    80002f42:	4581                	li	a1,0
    80002f44:	05850513          	addi	a0,a0,88
    80002f48:	da1fd0ef          	jal	80000ce8 <memset>
  log_write(bp);
    80002f4c:	854a                	mv	a0,s2
    80002f4e:	7f9000ef          	jal	80003f46 <log_write>
  brelse(bp);
    80002f52:	854a                	mv	a0,s2
    80002f54:	e3dff0ef          	jal	80002d90 <brelse>
}
    80002f58:	7942                	ld	s2,48(sp)
    80002f5a:	79a2                	ld	s3,40(sp)
    80002f5c:	7a02                	ld	s4,32(sp)
    80002f5e:	6ae2                	ld	s5,24(sp)
    80002f60:	6b42                	ld	s6,16(sp)
    80002f62:	6ba2                	ld	s7,8(sp)
    80002f64:	6c02                	ld	s8,0(sp)
}
    80002f66:	8526                	mv	a0,s1
    80002f68:	60a6                	ld	ra,72(sp)
    80002f6a:	6406                	ld	s0,64(sp)
    80002f6c:	74e2                	ld	s1,56(sp)
    80002f6e:	6161                	addi	sp,sp,80
    80002f70:	8082                	ret
    brelse(bp);
    80002f72:	854a                	mv	a0,s2
    80002f74:	e1dff0ef          	jal	80002d90 <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80002f78:	015c0abb          	addw	s5,s8,s5
    80002f7c:	004b2783          	lw	a5,4(s6)
    80002f80:	04faf863          	bgeu	s5,a5,80002fd0 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80002f84:	40dad59b          	sraiw	a1,s5,0xd
    80002f88:	01cb2783          	lw	a5,28(s6)
    80002f8c:	9dbd                	addw	a1,a1,a5
    80002f8e:	855e                	mv	a0,s7
    80002f90:	cf9ff0ef          	jal	80002c88 <bread>
    80002f94:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002f96:	004b2503          	lw	a0,4(s6)
    80002f9a:	84d6                	mv	s1,s5
    80002f9c:	4701                	li	a4,0
    80002f9e:	fca4fae3          	bgeu	s1,a0,80002f72 <balloc+0x8a>
      m = 1 << (bi % 8);
    80002fa2:	00777693          	andi	a3,a4,7
    80002fa6:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80002faa:	41f7579b          	sraiw	a5,a4,0x1f
    80002fae:	01d7d79b          	srliw	a5,a5,0x1d
    80002fb2:	9fb9                	addw	a5,a5,a4
    80002fb4:	4037d79b          	sraiw	a5,a5,0x3
    80002fb8:	00f90633          	add	a2,s2,a5
    80002fbc:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80002fc0:	00c6f5b3          	and	a1,a3,a2
    80002fc4:	ddb1                	beqz	a1,80002f20 <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002fc6:	2705                	addiw	a4,a4,1
    80002fc8:	2485                	addiw	s1,s1,1
    80002fca:	fd471ae3          	bne	a4,s4,80002f9e <balloc+0xb6>
    80002fce:	b755                	j	80002f72 <balloc+0x8a>
    80002fd0:	7942                	ld	s2,48(sp)
    80002fd2:	79a2                	ld	s3,40(sp)
    80002fd4:	7a02                	ld	s4,32(sp)
    80002fd6:	6ae2                	ld	s5,24(sp)
    80002fd8:	6b42                	ld	s6,16(sp)
    80002fda:	6ba2                	ld	s7,8(sp)
    80002fdc:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    80002fde:	00004517          	auipc	a0,0x4
    80002fe2:	42250513          	addi	a0,a0,1058 # 80007400 <etext+0x400>
    80002fe6:	d24fd0ef          	jal	8000050a <printk>
  return 0;
    80002fea:	4481                	li	s1,0
    80002fec:	bfad                	j	80002f66 <balloc+0x7e>

0000000080002fee <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002fee:	7179                	addi	sp,sp,-48
    80002ff0:	f406                	sd	ra,40(sp)
    80002ff2:	f022                	sd	s0,32(sp)
    80002ff4:	ec26                	sd	s1,24(sp)
    80002ff6:	e84a                	sd	s2,16(sp)
    80002ff8:	e44e                	sd	s3,8(sp)
    80002ffa:	1800                	addi	s0,sp,48
    80002ffc:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    80002ffe:	47ad                	li	a5,11
    80003000:	02b7e363          	bltu	a5,a1,80003026 <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    80003004:	02059793          	slli	a5,a1,0x20
    80003008:	01e7d593          	srli	a1,a5,0x1e
    8000300c:	00b509b3          	add	s3,a0,a1
    80003010:	0509a483          	lw	s1,80(s3)
    80003014:	e0b5                	bnez	s1,80003078 <bmap+0x8a>
      addr = balloc(ip->dev);
    80003016:	4108                	lw	a0,0(a0)
    80003018:	ed1ff0ef          	jal	80002ee8 <balloc>
    8000301c:	84aa                	mv	s1,a0
      if (addr == 0)
    8000301e:	cd29                	beqz	a0,80003078 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80003020:	04a9a823          	sw	a0,80(s3)
    80003024:	a891                	j	80003078 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003026:	ff45879b          	addiw	a5,a1,-12
    8000302a:	873e                	mv	a4,a5
    8000302c:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    8000302e:	0ff00793          	li	a5,255
    80003032:	06e7e763          	bltu	a5,a4,800030a0 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    80003036:	08052483          	lw	s1,128(a0)
    8000303a:	e891                	bnez	s1,8000304e <bmap+0x60>
      addr = balloc(ip->dev);
    8000303c:	4108                	lw	a0,0(a0)
    8000303e:	eabff0ef          	jal	80002ee8 <balloc>
    80003042:	84aa                	mv	s1,a0
      if (addr == 0)
    80003044:	c915                	beqz	a0,80003078 <bmap+0x8a>
    80003046:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003048:	08a92023          	sw	a0,128(s2)
    8000304c:	a011                	j	80003050 <bmap+0x62>
    8000304e:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003050:	85a6                	mv	a1,s1
    80003052:	00092503          	lw	a0,0(s2)
    80003056:	c33ff0ef          	jal	80002c88 <bread>
    8000305a:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    8000305c:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    80003060:	02099713          	slli	a4,s3,0x20
    80003064:	01e75593          	srli	a1,a4,0x1e
    80003068:	97ae                	add	a5,a5,a1
    8000306a:	89be                	mv	s3,a5
    8000306c:	4384                	lw	s1,0(a5)
    8000306e:	cc89                	beqz	s1,80003088 <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003070:	8552                	mv	a0,s4
    80003072:	d1fff0ef          	jal	80002d90 <brelse>
    return addr;
    80003076:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003078:	8526                	mv	a0,s1
    8000307a:	70a2                	ld	ra,40(sp)
    8000307c:	7402                	ld	s0,32(sp)
    8000307e:	64e2                	ld	s1,24(sp)
    80003080:	6942                	ld	s2,16(sp)
    80003082:	69a2                	ld	s3,8(sp)
    80003084:	6145                	addi	sp,sp,48
    80003086:	8082                	ret
      addr = balloc(ip->dev);
    80003088:	00092503          	lw	a0,0(s2)
    8000308c:	e5dff0ef          	jal	80002ee8 <balloc>
    80003090:	84aa                	mv	s1,a0
      if (addr) {
    80003092:	dd79                	beqz	a0,80003070 <bmap+0x82>
        a[bn] = addr;
    80003094:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80003098:	8552                	mv	a0,s4
    8000309a:	6ad000ef          	jal	80003f46 <log_write>
    8000309e:	bfc9                	j	80003070 <bmap+0x82>
    800030a0:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800030a2:	00004517          	auipc	a0,0x4
    800030a6:	37650513          	addi	a0,a0,886 # 80007418 <etext+0x418>
    800030aa:	f8afd0ef          	jal	80000834 <panic>

00000000800030ae <iget>:
{
    800030ae:	7179                	addi	sp,sp,-48
    800030b0:	f406                	sd	ra,40(sp)
    800030b2:	f022                	sd	s0,32(sp)
    800030b4:	ec26                	sd	s1,24(sp)
    800030b6:	e84a                	sd	s2,16(sp)
    800030b8:	e44e                	sd	s3,8(sp)
    800030ba:	e052                	sd	s4,0(sp)
    800030bc:	1800                	addi	s0,sp,48
    800030be:	892a                	mv	s2,a0
    800030c0:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800030c2:	0001e517          	auipc	a0,0x1e
    800030c6:	ace50513          	addi	a0,a0,-1330 # 80020b90 <itable>
    800030ca:	b5ffd0ef          	jal	80000c28 <acquire>
  empty = 0;
    800030ce:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    800030d0:	0001e497          	auipc	s1,0x1e
    800030d4:	ad848493          	addi	s1,s1,-1320 # 80020ba8 <itable+0x18>
    800030d8:	0001f697          	auipc	a3,0x1f
    800030dc:	56068693          	addi	a3,a3,1376 # 80022638 <log>
    800030e0:	a809                	j	800030f2 <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    800030e2:	e781                	bnez	a5,800030ea <iget+0x3c>
    800030e4:	00099363          	bnez	s3,800030ea <iget+0x3c>
      empty = ip;
    800030e8:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    800030ea:	08848493          	addi	s1,s1,136
    800030ee:	02d48563          	beq	s1,a3,80003118 <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    800030f2:	449c                	lw	a5,8(s1)
    800030f4:	fef057e3          	blez	a5,800030e2 <iget+0x34>
    800030f8:	4098                	lw	a4,0(s1)
    800030fa:	ff2718e3          	bne	a4,s2,800030ea <iget+0x3c>
    800030fe:	40d8                	lw	a4,4(s1)
    80003100:	ff4715e3          	bne	a4,s4,800030ea <iget+0x3c>
      ip->ref++;
    80003104:	2785                	addiw	a5,a5,1
    80003106:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003108:	0001e517          	auipc	a0,0x1e
    8000310c:	a8850513          	addi	a0,a0,-1400 # 80020b90 <itable>
    80003110:	ba1fd0ef          	jal	80000cb0 <release>
      return ip;
    80003114:	89a6                	mv	s3,s1
    80003116:	a015                	j	8000313a <iget+0x8c>
  if (empty == 0)
    80003118:	02098a63          	beqz	s3,8000314c <iget+0x9e>
  ip->dev = dev;
    8000311c:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    80003120:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003124:	4785                	li	a5,1
    80003126:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    8000312a:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    8000312e:	0001e517          	auipc	a0,0x1e
    80003132:	a6250513          	addi	a0,a0,-1438 # 80020b90 <itable>
    80003136:	b7bfd0ef          	jal	80000cb0 <release>
}
    8000313a:	854e                	mv	a0,s3
    8000313c:	70a2                	ld	ra,40(sp)
    8000313e:	7402                	ld	s0,32(sp)
    80003140:	64e2                	ld	s1,24(sp)
    80003142:	6942                	ld	s2,16(sp)
    80003144:	69a2                	ld	s3,8(sp)
    80003146:	6a02                	ld	s4,0(sp)
    80003148:	6145                	addi	sp,sp,48
    8000314a:	8082                	ret
    panic("iget: no inodes");
    8000314c:	00004517          	auipc	a0,0x4
    80003150:	2e450513          	addi	a0,a0,740 # 80007430 <etext+0x430>
    80003154:	ee0fd0ef          	jal	80000834 <panic>

0000000080003158 <iinit>:
{
    80003158:	7179                	addi	sp,sp,-48
    8000315a:	f406                	sd	ra,40(sp)
    8000315c:	f022                	sd	s0,32(sp)
    8000315e:	ec26                	sd	s1,24(sp)
    80003160:	e84a                	sd	s2,16(sp)
    80003162:	e44e                	sd	s3,8(sp)
    80003164:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003166:	00004597          	auipc	a1,0x4
    8000316a:	2da58593          	addi	a1,a1,730 # 80007440 <etext+0x440>
    8000316e:	0001e517          	auipc	a0,0x1e
    80003172:	a2250513          	addi	a0,a0,-1502 # 80020b90 <itable>
    80003176:	a33fd0ef          	jal	80000ba8 <initlock>
  for (i = 0; i < NINODE; i++) {
    8000317a:	0001e497          	auipc	s1,0x1e
    8000317e:	a3e48493          	addi	s1,s1,-1474 # 80020bb8 <itable+0x28>
    80003182:	0001f997          	auipc	s3,0x1f
    80003186:	4c698993          	addi	s3,s3,1222 # 80022648 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000318a:	00004917          	auipc	s2,0x4
    8000318e:	2be90913          	addi	s2,s2,702 # 80007448 <etext+0x448>
    80003192:	85ca                	mv	a1,s2
    80003194:	8526                	mv	a0,s1
    80003196:	6e9000ef          	jal	8000407e <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    8000319a:	08848493          	addi	s1,s1,136
    8000319e:	ff349ae3          	bne	s1,s3,80003192 <iinit+0x3a>
}
    800031a2:	70a2                	ld	ra,40(sp)
    800031a4:	7402                	ld	s0,32(sp)
    800031a6:	64e2                	ld	s1,24(sp)
    800031a8:	6942                	ld	s2,16(sp)
    800031aa:	69a2                	ld	s3,8(sp)
    800031ac:	6145                	addi	sp,sp,48
    800031ae:	8082                	ret

00000000800031b0 <ialloc>:
{
    800031b0:	7139                	addi	sp,sp,-64
    800031b2:	fc06                	sd	ra,56(sp)
    800031b4:	f822                	sd	s0,48(sp)
    800031b6:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    800031b8:	0001e717          	auipc	a4,0x1e
    800031bc:	9c472703          	lw	a4,-1596(a4) # 80020b7c <sb+0xc>
    800031c0:	4785                	li	a5,1
    800031c2:	06e7f063          	bgeu	a5,a4,80003222 <ialloc+0x72>
    800031c6:	f426                	sd	s1,40(sp)
    800031c8:	f04a                	sd	s2,32(sp)
    800031ca:	ec4e                	sd	s3,24(sp)
    800031cc:	e852                	sd	s4,16(sp)
    800031ce:	e456                	sd	s5,8(sp)
    800031d0:	e05a                	sd	s6,0(sp)
    800031d2:	8aaa                	mv	s5,a0
    800031d4:	8b2e                	mv	s6,a1
    800031d6:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800031d8:	0001ea17          	auipc	s4,0x1e
    800031dc:	998a0a13          	addi	s4,s4,-1640 # 80020b70 <sb>
    800031e0:	00495593          	srli	a1,s2,0x4
    800031e4:	018a2783          	lw	a5,24(s4)
    800031e8:	9dbd                	addw	a1,a1,a5
    800031ea:	8556                	mv	a0,s5
    800031ec:	a9dff0ef          	jal	80002c88 <bread>
    800031f0:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    800031f2:	05850993          	addi	s3,a0,88
    800031f6:	00f97793          	andi	a5,s2,15
    800031fa:	079a                	slli	a5,a5,0x6
    800031fc:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    800031fe:	00099783          	lh	a5,0(s3)
    80003202:	cb9d                	beqz	a5,80003238 <ialloc+0x88>
    brelse(bp);
    80003204:	b8dff0ef          	jal	80002d90 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003208:	0905                	addi	s2,s2,1
    8000320a:	00ca2703          	lw	a4,12(s4)
    8000320e:	0009079b          	sext.w	a5,s2
    80003212:	fce7e7e3          	bltu	a5,a4,800031e0 <ialloc+0x30>
    80003216:	74a2                	ld	s1,40(sp)
    80003218:	7902                	ld	s2,32(sp)
    8000321a:	69e2                	ld	s3,24(sp)
    8000321c:	6a42                	ld	s4,16(sp)
    8000321e:	6aa2                	ld	s5,8(sp)
    80003220:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    80003222:	00004517          	auipc	a0,0x4
    80003226:	22e50513          	addi	a0,a0,558 # 80007450 <etext+0x450>
    8000322a:	ae0fd0ef          	jal	8000050a <printk>
  return 0;
    8000322e:	4501                	li	a0,0
}
    80003230:	70e2                	ld	ra,56(sp)
    80003232:	7442                	ld	s0,48(sp)
    80003234:	6121                	addi	sp,sp,64
    80003236:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003238:	04000613          	li	a2,64
    8000323c:	4581                	li	a1,0
    8000323e:	854e                	mv	a0,s3
    80003240:	aa9fd0ef          	jal	80000ce8 <memset>
      dip->type = type;
    80003244:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    80003248:	8526                	mv	a0,s1
    8000324a:	4fd000ef          	jal	80003f46 <log_write>
      brelse(bp);
    8000324e:	8526                	mv	a0,s1
    80003250:	b41ff0ef          	jal	80002d90 <brelse>
      return iget(dev, inum);
    80003254:	0009059b          	sext.w	a1,s2
    80003258:	8556                	mv	a0,s5
    8000325a:	e55ff0ef          	jal	800030ae <iget>
    8000325e:	74a2                	ld	s1,40(sp)
    80003260:	7902                	ld	s2,32(sp)
    80003262:	69e2                	ld	s3,24(sp)
    80003264:	6a42                	ld	s4,16(sp)
    80003266:	6aa2                	ld	s5,8(sp)
    80003268:	6b02                	ld	s6,0(sp)
    8000326a:	b7d9                	j	80003230 <ialloc+0x80>

000000008000326c <iupdate>:
{
    8000326c:	1101                	addi	sp,sp,-32
    8000326e:	ec06                	sd	ra,24(sp)
    80003270:	e822                	sd	s0,16(sp)
    80003272:	e426                	sd	s1,8(sp)
    80003274:	e04a                	sd	s2,0(sp)
    80003276:	1000                	addi	s0,sp,32
    80003278:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000327a:	415c                	lw	a5,4(a0)
    8000327c:	0047d79b          	srliw	a5,a5,0x4
    80003280:	0001e597          	auipc	a1,0x1e
    80003284:	9085a583          	lw	a1,-1784(a1) # 80020b88 <sb+0x18>
    80003288:	9dbd                	addw	a1,a1,a5
    8000328a:	4108                	lw	a0,0(a0)
    8000328c:	9fdff0ef          	jal	80002c88 <bread>
    80003290:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003292:	05850793          	addi	a5,a0,88
    80003296:	40d8                	lw	a4,4(s1)
    80003298:	8b3d                	andi	a4,a4,15
    8000329a:	071a                	slli	a4,a4,0x6
    8000329c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000329e:	04449703          	lh	a4,68(s1)
    800032a2:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800032a6:	04649703          	lh	a4,70(s1)
    800032aa:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800032ae:	04849703          	lh	a4,72(s1)
    800032b2:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800032b6:	04a49703          	lh	a4,74(s1)
    800032ba:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800032be:	44f8                	lw	a4,76(s1)
    800032c0:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800032c2:	03400613          	li	a2,52
    800032c6:	05048593          	addi	a1,s1,80
    800032ca:	00c78513          	addi	a0,a5,12
    800032ce:	a7bfd0ef          	jal	80000d48 <memmove>
  log_write(bp);
    800032d2:	854a                	mv	a0,s2
    800032d4:	473000ef          	jal	80003f46 <log_write>
  brelse(bp);
    800032d8:	854a                	mv	a0,s2
    800032da:	ab7ff0ef          	jal	80002d90 <brelse>
}
    800032de:	60e2                	ld	ra,24(sp)
    800032e0:	6442                	ld	s0,16(sp)
    800032e2:	64a2                	ld	s1,8(sp)
    800032e4:	6902                	ld	s2,0(sp)
    800032e6:	6105                	addi	sp,sp,32
    800032e8:	8082                	ret

00000000800032ea <idup>:
{
    800032ea:	1101                	addi	sp,sp,-32
    800032ec:	ec06                	sd	ra,24(sp)
    800032ee:	e822                	sd	s0,16(sp)
    800032f0:	e426                	sd	s1,8(sp)
    800032f2:	1000                	addi	s0,sp,32
    800032f4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800032f6:	0001e517          	auipc	a0,0x1e
    800032fa:	89a50513          	addi	a0,a0,-1894 # 80020b90 <itable>
    800032fe:	92bfd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    80003302:	449c                	lw	a5,8(s1)
    80003304:	2785                	addiw	a5,a5,1
    80003306:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003308:	0001e517          	auipc	a0,0x1e
    8000330c:	88850513          	addi	a0,a0,-1912 # 80020b90 <itable>
    80003310:	9a1fd0ef          	jal	80000cb0 <release>
}
    80003314:	8526                	mv	a0,s1
    80003316:	60e2                	ld	ra,24(sp)
    80003318:	6442                	ld	s0,16(sp)
    8000331a:	64a2                	ld	s1,8(sp)
    8000331c:	6105                	addi	sp,sp,32
    8000331e:	8082                	ret

0000000080003320 <ilock>:
{
    80003320:	1101                	addi	sp,sp,-32
    80003322:	ec06                	sd	ra,24(sp)
    80003324:	e822                	sd	s0,16(sp)
    80003326:	e426                	sd	s1,8(sp)
    80003328:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    8000332a:	cd19                	beqz	a0,80003348 <ilock+0x28>
    8000332c:	84aa                	mv	s1,a0
    8000332e:	451c                	lw	a5,8(a0)
    80003330:	00f05c63          	blez	a5,80003348 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003334:	0541                	addi	a0,a0,16
    80003336:	57f000ef          	jal	800040b4 <acquiresleep>
  if (ip->valid == 0) {
    8000333a:	40bc                	lw	a5,64(s1)
    8000333c:	cf89                	beqz	a5,80003356 <ilock+0x36>
}
    8000333e:	60e2                	ld	ra,24(sp)
    80003340:	6442                	ld	s0,16(sp)
    80003342:	64a2                	ld	s1,8(sp)
    80003344:	6105                	addi	sp,sp,32
    80003346:	8082                	ret
    80003348:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000334a:	00004517          	auipc	a0,0x4
    8000334e:	11e50513          	addi	a0,a0,286 # 80007468 <etext+0x468>
    80003352:	ce2fd0ef          	jal	80000834 <panic>
    80003356:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003358:	40dc                	lw	a5,4(s1)
    8000335a:	0047d79b          	srliw	a5,a5,0x4
    8000335e:	0001e597          	auipc	a1,0x1e
    80003362:	82a5a583          	lw	a1,-2006(a1) # 80020b88 <sb+0x18>
    80003366:	9dbd                	addw	a1,a1,a5
    80003368:	4088                	lw	a0,0(s1)
    8000336a:	91fff0ef          	jal	80002c88 <bread>
    8000336e:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003370:	05850593          	addi	a1,a0,88
    80003374:	40dc                	lw	a5,4(s1)
    80003376:	8bbd                	andi	a5,a5,15
    80003378:	079a                	slli	a5,a5,0x6
    8000337a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000337c:	00059783          	lh	a5,0(a1)
    80003380:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003384:	00259783          	lh	a5,2(a1)
    80003388:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000338c:	00459783          	lh	a5,4(a1)
    80003390:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003394:	00659783          	lh	a5,6(a1)
    80003398:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000339c:	459c                	lw	a5,8(a1)
    8000339e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800033a0:	03400613          	li	a2,52
    800033a4:	05b1                	addi	a1,a1,12
    800033a6:	05048513          	addi	a0,s1,80
    800033aa:	99ffd0ef          	jal	80000d48 <memmove>
    brelse(bp);
    800033ae:	854a                	mv	a0,s2
    800033b0:	9e1ff0ef          	jal	80002d90 <brelse>
    ip->valid = 1;
    800033b4:	4785                	li	a5,1
    800033b6:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    800033b8:	04449783          	lh	a5,68(s1)
    800033bc:	c399                	beqz	a5,800033c2 <ilock+0xa2>
    800033be:	6902                	ld	s2,0(sp)
    800033c0:	bfbd                	j	8000333e <ilock+0x1e>
      panic("ilock: no type");
    800033c2:	00004517          	auipc	a0,0x4
    800033c6:	0ae50513          	addi	a0,a0,174 # 80007470 <etext+0x470>
    800033ca:	c6afd0ef          	jal	80000834 <panic>

00000000800033ce <iunlock>:
{
    800033ce:	1101                	addi	sp,sp,-32
    800033d0:	ec06                	sd	ra,24(sp)
    800033d2:	e822                	sd	s0,16(sp)
    800033d4:	e426                	sd	s1,8(sp)
    800033d6:	e04a                	sd	s2,0(sp)
    800033d8:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800033da:	c505                	beqz	a0,80003402 <iunlock+0x34>
    800033dc:	84aa                	mv	s1,a0
    800033de:	01050913          	addi	s2,a0,16
    800033e2:	854a                	mv	a0,s2
    800033e4:	55d000ef          	jal	80004140 <holdingsleep>
    800033e8:	cd09                	beqz	a0,80003402 <iunlock+0x34>
    800033ea:	449c                	lw	a5,8(s1)
    800033ec:	00f05b63          	blez	a5,80003402 <iunlock+0x34>
  releasesleep(&ip->lock);
    800033f0:	854a                	mv	a0,s2
    800033f2:	517000ef          	jal	80004108 <releasesleep>
}
    800033f6:	60e2                	ld	ra,24(sp)
    800033f8:	6442                	ld	s0,16(sp)
    800033fa:	64a2                	ld	s1,8(sp)
    800033fc:	6902                	ld	s2,0(sp)
    800033fe:	6105                	addi	sp,sp,32
    80003400:	8082                	ret
    panic("iunlock");
    80003402:	00004517          	auipc	a0,0x4
    80003406:	07e50513          	addi	a0,a0,126 # 80007480 <etext+0x480>
    8000340a:	c2afd0ef          	jal	80000834 <panic>

000000008000340e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000340e:	7179                	addi	sp,sp,-48
    80003410:	f406                	sd	ra,40(sp)
    80003412:	f022                	sd	s0,32(sp)
    80003414:	ec26                	sd	s1,24(sp)
    80003416:	e84a                	sd	s2,16(sp)
    80003418:	e44e                	sd	s3,8(sp)
    8000341a:	1800                	addi	s0,sp,48
    8000341c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    8000341e:	05050493          	addi	s1,a0,80
    80003422:	08050913          	addi	s2,a0,128
    80003426:	a021                	j	8000342e <itrunc+0x20>
    80003428:	0491                	addi	s1,s1,4
    8000342a:	01248b63          	beq	s1,s2,80003440 <itrunc+0x32>
    if (ip->addrs[i]) {
    8000342e:	408c                	lw	a1,0(s1)
    80003430:	dde5                	beqz	a1,80003428 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003432:	0009a503          	lw	a0,0(s3)
    80003436:	a47ff0ef          	jal	80002e7c <bfree>
      ip->addrs[i] = 0;
    8000343a:	0004a023          	sw	zero,0(s1)
    8000343e:	b7ed                	j	80003428 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    80003440:	0809a583          	lw	a1,128(s3)
    80003444:	ed89                	bnez	a1,8000345e <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003446:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000344a:	854e                	mv	a0,s3
    8000344c:	e21ff0ef          	jal	8000326c <iupdate>
}
    80003450:	70a2                	ld	ra,40(sp)
    80003452:	7402                	ld	s0,32(sp)
    80003454:	64e2                	ld	s1,24(sp)
    80003456:	6942                	ld	s2,16(sp)
    80003458:	69a2                	ld	s3,8(sp)
    8000345a:	6145                	addi	sp,sp,48
    8000345c:	8082                	ret
    8000345e:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003460:	0009a503          	lw	a0,0(s3)
    80003464:	825ff0ef          	jal	80002c88 <bread>
    80003468:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    8000346a:	05850493          	addi	s1,a0,88
    8000346e:	45850913          	addi	s2,a0,1112
    80003472:	a021                	j	8000347a <itrunc+0x6c>
    80003474:	0491                	addi	s1,s1,4
    80003476:	01248963          	beq	s1,s2,80003488 <itrunc+0x7a>
      if (a[j])
    8000347a:	408c                	lw	a1,0(s1)
    8000347c:	dde5                	beqz	a1,80003474 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000347e:	0009a503          	lw	a0,0(s3)
    80003482:	9fbff0ef          	jal	80002e7c <bfree>
    80003486:	b7fd                	j	80003474 <itrunc+0x66>
    brelse(bp);
    80003488:	8552                	mv	a0,s4
    8000348a:	907ff0ef          	jal	80002d90 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000348e:	0809a583          	lw	a1,128(s3)
    80003492:	0009a503          	lw	a0,0(s3)
    80003496:	9e7ff0ef          	jal	80002e7c <bfree>
    ip->addrs[NDIRECT] = 0;
    8000349a:	0809a023          	sw	zero,128(s3)
    8000349e:	6a02                	ld	s4,0(sp)
    800034a0:	b75d                	j	80003446 <itrunc+0x38>

00000000800034a2 <iput>:
{
    800034a2:	7179                	addi	sp,sp,-48
    800034a4:	f406                	sd	ra,40(sp)
    800034a6:	f022                	sd	s0,32(sp)
    800034a8:	ec26                	sd	s1,24(sp)
    800034aa:	1800                	addi	s0,sp,48
    800034ac:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800034ae:	0001d517          	auipc	a0,0x1d
    800034b2:	6e250513          	addi	a0,a0,1762 # 80020b90 <itable>
    800034b6:	f72fd0ef          	jal	80000c28 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    800034ba:	449c                	lw	a5,8(s1)
    800034bc:	4705                	li	a4,1
    800034be:	00e78f63          	beq	a5,a4,800034dc <iput+0x3a>
  ip->ref--;
    800034c2:	37fd                	addiw	a5,a5,-1
    800034c4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800034c6:	0001d517          	auipc	a0,0x1d
    800034ca:	6ca50513          	addi	a0,a0,1738 # 80020b90 <itable>
    800034ce:	fe2fd0ef          	jal	80000cb0 <release>
}
    800034d2:	70a2                	ld	ra,40(sp)
    800034d4:	7402                	ld	s0,32(sp)
    800034d6:	64e2                	ld	s1,24(sp)
    800034d8:	6145                	addi	sp,sp,48
    800034da:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    800034dc:	40b8                	lw	a4,64(s1)
    800034de:	d375                	beqz	a4,800034c2 <iput+0x20>
    800034e0:	e84a                	sd	s2,16(sp)
    800034e2:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    800034e4:	0004aa03          	lw	s4,0(s1)
    800034e8:	0044a903          	lw	s2,4(s1)
  if (last) {
    800034ec:	04a49703          	lh	a4,74(s1)
    800034f0:	ef3d                	bnez	a4,8000356e <iput+0xcc>
    800034f2:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    800034f4:	01048793          	addi	a5,s1,16
    800034f8:	89be                	mv	s3,a5
    800034fa:	853e                	mv	a0,a5
    800034fc:	3b9000ef          	jal	800040b4 <acquiresleep>
    release(&itable.lock);
    80003500:	0001d517          	auipc	a0,0x1d
    80003504:	69050513          	addi	a0,a0,1680 # 80020b90 <itable>
    80003508:	fa8fd0ef          	jal	80000cb0 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    8000350c:	8526                	mv	a0,s1
    8000350e:	f01ff0ef          	jal	8000340e <itrunc>
    ip->valid = 0;
    80003512:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003516:	854e                	mv	a0,s3
    80003518:	3f1000ef          	jal	80004108 <releasesleep>
    acquire(&itable.lock);
    8000351c:	0001d517          	auipc	a0,0x1d
    80003520:	67450513          	addi	a0,a0,1652 # 80020b90 <itable>
    80003524:	f04fd0ef          	jal	80000c28 <acquire>
  ip->ref--;
    80003528:	449c                	lw	a5,8(s1)
    8000352a:	37fd                	addiw	a5,a5,-1
    8000352c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000352e:	0001d517          	auipc	a0,0x1d
    80003532:	66250513          	addi	a0,a0,1634 # 80020b90 <itable>
    80003536:	f7afd0ef          	jal	80000cb0 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000353a:	0049579b          	srliw	a5,s2,0x4
    8000353e:	0001d597          	auipc	a1,0x1d
    80003542:	64a5a583          	lw	a1,1610(a1) # 80020b88 <sb+0x18>
    80003546:	9dbd                	addw	a1,a1,a5
    80003548:	8552                	mv	a0,s4
    8000354a:	f3eff0ef          	jal	80002c88 <bread>
    8000354e:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003550:	00f97793          	andi	a5,s2,15
  dip->type = 0;
    80003554:	079a                	slli	a5,a5,0x6
    80003556:	97aa                	add	a5,a5,a0
    80003558:	04079c23          	sh	zero,88(a5)
  log_write(bp);
    8000355c:	1eb000ef          	jal	80003f46 <log_write>
  brelse(bp);
    80003560:	8526                	mv	a0,s1
    80003562:	82fff0ef          	jal	80002d90 <brelse>
}
    80003566:	6942                	ld	s2,16(sp)
    80003568:	69a2                	ld	s3,8(sp)
    8000356a:	6a02                	ld	s4,0(sp)
    8000356c:	b79d                	j	800034d2 <iput+0x30>
    8000356e:	6942                	ld	s2,16(sp)
    80003570:	6a02                	ld	s4,0(sp)
    80003572:	bf81                	j	800034c2 <iput+0x20>

0000000080003574 <iunlockput>:
{
    80003574:	1101                	addi	sp,sp,-32
    80003576:	ec06                	sd	ra,24(sp)
    80003578:	e822                	sd	s0,16(sp)
    8000357a:	e426                	sd	s1,8(sp)
    8000357c:	1000                	addi	s0,sp,32
    8000357e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003580:	e4fff0ef          	jal	800033ce <iunlock>
  iput(ip);
    80003584:	8526                	mv	a0,s1
    80003586:	f1dff0ef          	jal	800034a2 <iput>
}
    8000358a:	60e2                	ld	ra,24(sp)
    8000358c:	6442                	ld	s0,16(sp)
    8000358e:	64a2                	ld	s1,8(sp)
    80003590:	6105                	addi	sp,sp,32
    80003592:	8082                	ret

0000000080003594 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003594:	0001d717          	auipc	a4,0x1d
    80003598:	5e872703          	lw	a4,1512(a4) # 80020b7c <sb+0xc>
    8000359c:	4785                	li	a5,1
    8000359e:	0ae7fe63          	bgeu	a5,a4,8000365a <ireclaim+0xc6>
{
    800035a2:	7139                	addi	sp,sp,-64
    800035a4:	fc06                	sd	ra,56(sp)
    800035a6:	f822                	sd	s0,48(sp)
    800035a8:	f426                	sd	s1,40(sp)
    800035aa:	f04a                	sd	s2,32(sp)
    800035ac:	ec4e                	sd	s3,24(sp)
    800035ae:	e852                	sd	s4,16(sp)
    800035b0:	e456                	sd	s5,8(sp)
    800035b2:	e05a                	sd	s6,0(sp)
    800035b4:	0080                	addi	s0,sp,64
    800035b6:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800035b8:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800035ba:	0001da17          	auipc	s4,0x1d
    800035be:	5b6a0a13          	addi	s4,s4,1462 # 80020b70 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    800035c2:	00004b17          	auipc	s6,0x4
    800035c6:	ec6b0b13          	addi	s6,s6,-314 # 80007488 <etext+0x488>
    800035ca:	a099                	j	80003610 <ireclaim+0x7c>
    800035cc:	85ce                	mv	a1,s3
    800035ce:	855a                	mv	a0,s6
    800035d0:	f3bfc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    800035d4:	85ce                	mv	a1,s3
    800035d6:	8556                	mv	a0,s5
    800035d8:	ad7ff0ef          	jal	800030ae <iget>
    800035dc:	89aa                	mv	s3,a0
    brelse(bp);
    800035de:	854a                	mv	a0,s2
    800035e0:	fb0ff0ef          	jal	80002d90 <brelse>
    if (ip) {
    800035e4:	00098f63          	beqz	s3,80003602 <ireclaim+0x6e>
      begin_op();
    800035e8:	7b0000ef          	jal	80003d98 <begin_op>
      ilock(ip);
    800035ec:	854e                	mv	a0,s3
    800035ee:	d33ff0ef          	jal	80003320 <ilock>
      iunlock(ip);
    800035f2:	854e                	mv	a0,s3
    800035f4:	ddbff0ef          	jal	800033ce <iunlock>
      iput(ip);
    800035f8:	854e                	mv	a0,s3
    800035fa:	ea9ff0ef          	jal	800034a2 <iput>
      end_op();
    800035fe:	027000ef          	jal	80003e24 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003602:	0485                	addi	s1,s1,1
    80003604:	00ca2703          	lw	a4,12(s4)
    80003608:	0004879b          	sext.w	a5,s1
    8000360c:	02e7fd63          	bgeu	a5,a4,80003646 <ireclaim+0xb2>
    80003610:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003614:	0044d593          	srli	a1,s1,0x4
    80003618:	018a2783          	lw	a5,24(s4)
    8000361c:	9dbd                	addw	a1,a1,a5
    8000361e:	8556                	mv	a0,s5
    80003620:	e68ff0ef          	jal	80002c88 <bread>
    80003624:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003626:	05850793          	addi	a5,a0,88
    8000362a:	00f9f713          	andi	a4,s3,15
    8000362e:	071a                	slli	a4,a4,0x6
    80003630:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    80003632:	00079703          	lh	a4,0(a5)
    80003636:	c701                	beqz	a4,8000363e <ireclaim+0xaa>
    80003638:	00679783          	lh	a5,6(a5)
    8000363c:	dbc1                	beqz	a5,800035cc <ireclaim+0x38>
    brelse(bp);
    8000363e:	854a                	mv	a0,s2
    80003640:	f50ff0ef          	jal	80002d90 <brelse>
    if (ip) {
    80003644:	bf7d                	j	80003602 <ireclaim+0x6e>
}
    80003646:	70e2                	ld	ra,56(sp)
    80003648:	7442                	ld	s0,48(sp)
    8000364a:	74a2                	ld	s1,40(sp)
    8000364c:	7902                	ld	s2,32(sp)
    8000364e:	69e2                	ld	s3,24(sp)
    80003650:	6a42                	ld	s4,16(sp)
    80003652:	6aa2                	ld	s5,8(sp)
    80003654:	6b02                	ld	s6,0(sp)
    80003656:	6121                	addi	sp,sp,64
    80003658:	8082                	ret
    8000365a:	8082                	ret

000000008000365c <fsinit>:
{
    8000365c:	1101                	addi	sp,sp,-32
    8000365e:	ec06                	sd	ra,24(sp)
    80003660:	e822                	sd	s0,16(sp)
    80003662:	e426                	sd	s1,8(sp)
    80003664:	e04a                	sd	s2,0(sp)
    80003666:	1000                	addi	s0,sp,32
    80003668:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000366a:	4585                	li	a1,1
    8000366c:	e1cff0ef          	jal	80002c88 <bread>
    80003670:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003672:	02000613          	li	a2,32
    80003676:	05850593          	addi	a1,a0,88
    8000367a:	0001d517          	auipc	a0,0x1d
    8000367e:	4f650513          	addi	a0,a0,1270 # 80020b70 <sb>
    80003682:	ec6fd0ef          	jal	80000d48 <memmove>
  brelse(bp);
    80003686:	8526                	mv	a0,s1
    80003688:	f08ff0ef          	jal	80002d90 <brelse>
  if (sb.magic != FSMAGIC)
    8000368c:	0001d717          	auipc	a4,0x1d
    80003690:	4e472703          	lw	a4,1252(a4) # 80020b70 <sb>
    80003694:	102037b7          	lui	a5,0x10203
    80003698:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000369c:	02f71263          	bne	a4,a5,800036c0 <fsinit+0x64>
  initlog(dev, &sb);
    800036a0:	0001d597          	auipc	a1,0x1d
    800036a4:	4d058593          	addi	a1,a1,1232 # 80020b70 <sb>
    800036a8:	854a                	mv	a0,s2
    800036aa:	66c000ef          	jal	80003d16 <initlog>
  ireclaim(dev);
    800036ae:	854a                	mv	a0,s2
    800036b0:	ee5ff0ef          	jal	80003594 <ireclaim>
}
    800036b4:	60e2                	ld	ra,24(sp)
    800036b6:	6442                	ld	s0,16(sp)
    800036b8:	64a2                	ld	s1,8(sp)
    800036ba:	6902                	ld	s2,0(sp)
    800036bc:	6105                	addi	sp,sp,32
    800036be:	8082                	ret
    panic("invalid file system");
    800036c0:	00004517          	auipc	a0,0x4
    800036c4:	de850513          	addi	a0,a0,-536 # 800074a8 <etext+0x4a8>
    800036c8:	96cfd0ef          	jal	80000834 <panic>

00000000800036cc <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800036cc:	1141                	addi	sp,sp,-16
    800036ce:	e406                	sd	ra,8(sp)
    800036d0:	e022                	sd	s0,0(sp)
    800036d2:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800036d4:	411c                	lw	a5,0(a0)
    800036d6:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800036d8:	415c                	lw	a5,4(a0)
    800036da:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800036dc:	04451783          	lh	a5,68(a0)
    800036e0:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800036e4:	04a51783          	lh	a5,74(a0)
    800036e8:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800036ec:	04c56783          	lwu	a5,76(a0)
    800036f0:	e99c                	sd	a5,16(a1)
}
    800036f2:	60a2                	ld	ra,8(sp)
    800036f4:	6402                	ld	s0,0(sp)
    800036f6:	0141                	addi	sp,sp,16
    800036f8:	8082                	ret

00000000800036fa <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    800036fa:	457c                	lw	a5,76(a0)
    800036fc:	0ed7e663          	bltu	a5,a3,800037e8 <readi+0xee>
{
    80003700:	7159                	addi	sp,sp,-112
    80003702:	f486                	sd	ra,104(sp)
    80003704:	f0a2                	sd	s0,96(sp)
    80003706:	eca6                	sd	s1,88(sp)
    80003708:	e0d2                	sd	s4,64(sp)
    8000370a:	fc56                	sd	s5,56(sp)
    8000370c:	f85a                	sd	s6,48(sp)
    8000370e:	f45e                	sd	s7,40(sp)
    80003710:	1880                	addi	s0,sp,112
    80003712:	8b2a                	mv	s6,a0
    80003714:	8bae                	mv	s7,a1
    80003716:	8a32                	mv	s4,a2
    80003718:	84b6                	mv	s1,a3
    8000371a:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    8000371c:	9f35                	addw	a4,a4,a3
    return 0;
    8000371e:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    80003720:	0ad76b63          	bltu	a4,a3,800037d6 <readi+0xdc>
    80003724:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    80003726:	00e7f463          	bgeu	a5,a4,8000372e <readi+0x34>
    n = ip->size - off;
    8000372a:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    8000372e:	080a8b63          	beqz	s5,800037c4 <readi+0xca>
    80003732:	e8ca                	sd	s2,80(sp)
    80003734:	f062                	sd	s8,32(sp)
    80003736:	ec66                	sd	s9,24(sp)
    80003738:	e86a                	sd	s10,16(sp)
    8000373a:	e46e                	sd	s11,8(sp)
    8000373c:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    8000373e:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003742:	5c7d                	li	s8,-1
    80003744:	a80d                	j	80003776 <readi+0x7c>
    80003746:	020d1d93          	slli	s11,s10,0x20
    8000374a:	020ddd93          	srli	s11,s11,0x20
    8000374e:	05890613          	addi	a2,s2,88
    80003752:	86ee                	mv	a3,s11
    80003754:	963e                	add	a2,a2,a5
    80003756:	85d2                	mv	a1,s4
    80003758:	855e                	mv	a0,s7
    8000375a:	c3ffe0ef          	jal	80002398 <either_copyout>
    8000375e:	05850363          	beq	a0,s8,800037a4 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003762:	854a                	mv	a0,s2
    80003764:	e2cff0ef          	jal	80002d90 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003768:	013d09bb          	addw	s3,s10,s3
    8000376c:	009d04bb          	addw	s1,s10,s1
    80003770:	9a6e                	add	s4,s4,s11
    80003772:	0559f363          	bgeu	s3,s5,800037b8 <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    80003776:	00a4d59b          	srliw	a1,s1,0xa
    8000377a:	855a                	mv	a0,s6
    8000377c:	873ff0ef          	jal	80002fee <bmap>
    80003780:	85aa                	mv	a1,a0
    if (addr == 0)
    80003782:	c139                	beqz	a0,800037c8 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003784:	000b2503          	lw	a0,0(s6)
    80003788:	d00ff0ef          	jal	80002c88 <bread>
    8000378c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    8000378e:	3ff4f793          	andi	a5,s1,1023
    80003792:	40fc873b          	subw	a4,s9,a5
    80003796:	413a86bb          	subw	a3,s5,s3
    8000379a:	8d3a                	mv	s10,a4
    8000379c:	fae6f5e3          	bgeu	a3,a4,80003746 <readi+0x4c>
    800037a0:	8d36                	mv	s10,a3
    800037a2:	b755                	j	80003746 <readi+0x4c>
      brelse(bp);
    800037a4:	854a                	mv	a0,s2
    800037a6:	deaff0ef          	jal	80002d90 <brelse>
      tot = -1;
    800037aa:	59fd                	li	s3,-1
      break;
    800037ac:	6946                	ld	s2,80(sp)
    800037ae:	7c02                	ld	s8,32(sp)
    800037b0:	6ce2                	ld	s9,24(sp)
    800037b2:	6d42                	ld	s10,16(sp)
    800037b4:	6da2                	ld	s11,8(sp)
    800037b6:	a831                	j	800037d2 <readi+0xd8>
    800037b8:	6946                	ld	s2,80(sp)
    800037ba:	7c02                	ld	s8,32(sp)
    800037bc:	6ce2                	ld	s9,24(sp)
    800037be:	6d42                	ld	s10,16(sp)
    800037c0:	6da2                	ld	s11,8(sp)
    800037c2:	a801                	j	800037d2 <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800037c4:	89d6                	mv	s3,s5
    800037c6:	a031                	j	800037d2 <readi+0xd8>
    800037c8:	6946                	ld	s2,80(sp)
    800037ca:	7c02                	ld	s8,32(sp)
    800037cc:	6ce2                	ld	s9,24(sp)
    800037ce:	6d42                	ld	s10,16(sp)
    800037d0:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800037d2:	854e                	mv	a0,s3
    800037d4:	69a6                	ld	s3,72(sp)
}
    800037d6:	70a6                	ld	ra,104(sp)
    800037d8:	7406                	ld	s0,96(sp)
    800037da:	64e6                	ld	s1,88(sp)
    800037dc:	6a06                	ld	s4,64(sp)
    800037de:	7ae2                	ld	s5,56(sp)
    800037e0:	7b42                	ld	s6,48(sp)
    800037e2:	7ba2                	ld	s7,40(sp)
    800037e4:	6165                	addi	sp,sp,112
    800037e6:	8082                	ret
    return 0;
    800037e8:	4501                	li	a0,0
}
    800037ea:	8082                	ret

00000000800037ec <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    800037ec:	457c                	lw	a5,76(a0)
    800037ee:	0ed7ee63          	bltu	a5,a3,800038ea <writei+0xfe>
{
    800037f2:	7159                	addi	sp,sp,-112
    800037f4:	f486                	sd	ra,104(sp)
    800037f6:	f0a2                	sd	s0,96(sp)
    800037f8:	e8ca                	sd	s2,80(sp)
    800037fa:	e0d2                	sd	s4,64(sp)
    800037fc:	fc56                	sd	s5,56(sp)
    800037fe:	f85a                	sd	s6,48(sp)
    80003800:	f45e                	sd	s7,40(sp)
    80003802:	1880                	addi	s0,sp,112
    80003804:	8aaa                	mv	s5,a0
    80003806:	8bae                	mv	s7,a1
    80003808:	8a32                	mv	s4,a2
    8000380a:	8936                	mv	s2,a3
    8000380c:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    8000380e:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    80003812:	00043737          	lui	a4,0x43
    80003816:	0cf76c63          	bltu	a4,a5,800038ee <writei+0x102>
    8000381a:	0cd7ea63          	bltu	a5,a3,800038ee <writei+0x102>
    8000381e:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003820:	0a0b0d63          	beqz	s6,800038da <writei+0xee>
    80003824:	eca6                	sd	s1,88(sp)
    80003826:	f062                	sd	s8,32(sp)
    80003828:	ec66                	sd	s9,24(sp)
    8000382a:	e86a                	sd	s10,16(sp)
    8000382c:	e46e                	sd	s11,8(sp)
    8000382e:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003830:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003834:	5c7d                	li	s8,-1
    80003836:	a825                	j	8000386e <writei+0x82>
    80003838:	020d1d93          	slli	s11,s10,0x20
    8000383c:	020ddd93          	srli	s11,s11,0x20
    80003840:	05848513          	addi	a0,s1,88
    80003844:	86ee                	mv	a3,s11
    80003846:	8652                	mv	a2,s4
    80003848:	85de                	mv	a1,s7
    8000384a:	953e                	add	a0,a0,a5
    8000384c:	b99fe0ef          	jal	800023e4 <either_copyin>
    80003850:	05850663          	beq	a0,s8,8000389c <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    80003854:	8526                	mv	a0,s1
    80003856:	6f0000ef          	jal	80003f46 <log_write>
    brelse(bp);
    8000385a:	8526                	mv	a0,s1
    8000385c:	d34ff0ef          	jal	80002d90 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003860:	013d09bb          	addw	s3,s10,s3
    80003864:	012d093b          	addw	s2,s10,s2
    80003868:	9a6e                	add	s4,s4,s11
    8000386a:	0369ff63          	bgeu	s3,s6,800038a8 <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    8000386e:	00a9559b          	srliw	a1,s2,0xa
    80003872:	8556                	mv	a0,s5
    80003874:	f7aff0ef          	jal	80002fee <bmap>
    80003878:	85aa                	mv	a1,a0
    if (addr == 0)
    8000387a:	c51d                	beqz	a0,800038a8 <writei+0xbc>
    bp = bread(ip->dev, addr);
    8000387c:	000aa503          	lw	a0,0(s5)
    80003880:	c08ff0ef          	jal	80002c88 <bread>
    80003884:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003886:	3ff97793          	andi	a5,s2,1023
    8000388a:	40fc873b          	subw	a4,s9,a5
    8000388e:	413b06bb          	subw	a3,s6,s3
    80003892:	8d3a                	mv	s10,a4
    80003894:	fae6f2e3          	bgeu	a3,a4,80003838 <writei+0x4c>
    80003898:	8d36                	mv	s10,a3
    8000389a:	bf79                	j	80003838 <writei+0x4c>
      log_write(bp);
    8000389c:	8526                	mv	a0,s1
    8000389e:	6a8000ef          	jal	80003f46 <log_write>
      brelse(bp);
    800038a2:	8526                	mv	a0,s1
    800038a4:	cecff0ef          	jal	80002d90 <brelse>
  }

  if (off > ip->size)
    800038a8:	04caa783          	lw	a5,76(s5)
    800038ac:	0327f963          	bgeu	a5,s2,800038de <writei+0xf2>
    ip->size = off;
    800038b0:	052aa623          	sw	s2,76(s5)
    800038b4:	64e6                	ld	s1,88(sp)
    800038b6:	7c02                	ld	s8,32(sp)
    800038b8:	6ce2                	ld	s9,24(sp)
    800038ba:	6d42                	ld	s10,16(sp)
    800038bc:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800038be:	8556                	mv	a0,s5
    800038c0:	9adff0ef          	jal	8000326c <iupdate>

  return tot;
    800038c4:	854e                	mv	a0,s3
    800038c6:	69a6                	ld	s3,72(sp)
}
    800038c8:	70a6                	ld	ra,104(sp)
    800038ca:	7406                	ld	s0,96(sp)
    800038cc:	6946                	ld	s2,80(sp)
    800038ce:	6a06                	ld	s4,64(sp)
    800038d0:	7ae2                	ld	s5,56(sp)
    800038d2:	7b42                	ld	s6,48(sp)
    800038d4:	7ba2                	ld	s7,40(sp)
    800038d6:	6165                	addi	sp,sp,112
    800038d8:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800038da:	89da                	mv	s3,s6
    800038dc:	b7cd                	j	800038be <writei+0xd2>
    800038de:	64e6                	ld	s1,88(sp)
    800038e0:	7c02                	ld	s8,32(sp)
    800038e2:	6ce2                	ld	s9,24(sp)
    800038e4:	6d42                	ld	s10,16(sp)
    800038e6:	6da2                	ld	s11,8(sp)
    800038e8:	bfd9                	j	800038be <writei+0xd2>
    return -1;
    800038ea:	557d                	li	a0,-1
}
    800038ec:	8082                	ret
    return -1;
    800038ee:	557d                	li	a0,-1
    800038f0:	bfe1                	j	800038c8 <writei+0xdc>

00000000800038f2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800038f2:	1141                	addi	sp,sp,-16
    800038f4:	e406                	sd	ra,8(sp)
    800038f6:	e022                	sd	s0,0(sp)
    800038f8:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800038fa:	4639                	li	a2,14
    800038fc:	cc0fd0ef          	jal	80000dbc <strncmp>
}
    80003900:	60a2                	ld	ra,8(sp)
    80003902:	6402                	ld	s0,0(sp)
    80003904:	0141                	addi	sp,sp,16
    80003906:	8082                	ret

0000000080003908 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003908:	711d                	addi	sp,sp,-96
    8000390a:	ec86                	sd	ra,88(sp)
    8000390c:	e8a2                	sd	s0,80(sp)
    8000390e:	e4a6                	sd	s1,72(sp)
    80003910:	e0ca                	sd	s2,64(sp)
    80003912:	fc4e                	sd	s3,56(sp)
    80003914:	f852                	sd	s4,48(sp)
    80003916:	f456                	sd	s5,40(sp)
    80003918:	f05a                	sd	s6,32(sp)
    8000391a:	ec5e                	sd	s7,24(sp)
    8000391c:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    8000391e:	04451703          	lh	a4,68(a0)
    80003922:	4785                	li	a5,1
    80003924:	00f71f63          	bne	a4,a5,80003942 <dirlookup+0x3a>
    80003928:	892a                	mv	s2,a0
    8000392a:	8aae                	mv	s5,a1
    8000392c:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    8000392e:	457c                	lw	a5,76(a0)
    80003930:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003932:	fa040a13          	addi	s4,s0,-96
    80003936:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    80003938:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000393c:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    8000393e:	e39d                	bnez	a5,80003964 <dirlookup+0x5c>
    80003940:	a8b9                	j	8000399e <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003942:	00004517          	auipc	a0,0x4
    80003946:	b7e50513          	addi	a0,a0,-1154 # 800074c0 <etext+0x4c0>
    8000394a:	eebfc0ef          	jal	80000834 <panic>
      panic("dirlookup read");
    8000394e:	00004517          	auipc	a0,0x4
    80003952:	b8a50513          	addi	a0,a0,-1142 # 800074d8 <etext+0x4d8>
    80003956:	edffc0ef          	jal	80000834 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    8000395a:	24c1                	addiw	s1,s1,16
    8000395c:	04c92783          	lw	a5,76(s2)
    80003960:	02f4fe63          	bgeu	s1,a5,8000399c <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003964:	874e                	mv	a4,s3
    80003966:	86a6                	mv	a3,s1
    80003968:	8652                	mv	a2,s4
    8000396a:	4581                	li	a1,0
    8000396c:	854a                	mv	a0,s2
    8000396e:	d8dff0ef          	jal	800036fa <readi>
    80003972:	fd351ee3          	bne	a0,s3,8000394e <dirlookup+0x46>
    if (de.inum == 0)
    80003976:	fa045783          	lhu	a5,-96(s0)
    8000397a:	d3e5                	beqz	a5,8000395a <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    8000397c:	85da                	mv	a1,s6
    8000397e:	8556                	mv	a0,s5
    80003980:	f73ff0ef          	jal	800038f2 <namecmp>
    80003984:	f979                	bnez	a0,8000395a <dirlookup+0x52>
      if (poff)
    80003986:	000b8463          	beqz	s7,8000398e <dirlookup+0x86>
        *poff = off;
    8000398a:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    8000398e:	fa045583          	lhu	a1,-96(s0)
    80003992:	00092503          	lw	a0,0(s2)
    80003996:	f18ff0ef          	jal	800030ae <iget>
    8000399a:	a011                	j	8000399e <dirlookup+0x96>
  return 0;
    8000399c:	4501                	li	a0,0
}
    8000399e:	60e6                	ld	ra,88(sp)
    800039a0:	6446                	ld	s0,80(sp)
    800039a2:	64a6                	ld	s1,72(sp)
    800039a4:	6906                	ld	s2,64(sp)
    800039a6:	79e2                	ld	s3,56(sp)
    800039a8:	7a42                	ld	s4,48(sp)
    800039aa:	7aa2                	ld	s5,40(sp)
    800039ac:	7b02                	ld	s6,32(sp)
    800039ae:	6be2                	ld	s7,24(sp)
    800039b0:	6125                	addi	sp,sp,96
    800039b2:	8082                	ret

00000000800039b4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    800039b4:	711d                	addi	sp,sp,-96
    800039b6:	ec86                	sd	ra,88(sp)
    800039b8:	e8a2                	sd	s0,80(sp)
    800039ba:	e4a6                	sd	s1,72(sp)
    800039bc:	e0ca                	sd	s2,64(sp)
    800039be:	fc4e                	sd	s3,56(sp)
    800039c0:	f852                	sd	s4,48(sp)
    800039c2:	f456                	sd	s5,40(sp)
    800039c4:	f05a                	sd	s6,32(sp)
    800039c6:	ec5e                	sd	s7,24(sp)
    800039c8:	e862                	sd	s8,16(sp)
    800039ca:	e466                	sd	s9,8(sp)
    800039cc:	e06a                	sd	s10,0(sp)
    800039ce:	1080                	addi	s0,sp,96
    800039d0:	84aa                	mv	s1,a0
    800039d2:	8b2e                	mv	s6,a1
    800039d4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    800039d6:	00054703          	lbu	a4,0(a0)
    800039da:	02f00793          	li	a5,47
    800039de:	00f70f63          	beq	a4,a5,800039fc <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800039e2:	f67fd0ef          	jal	80001948 <myproc>
    800039e6:	15053503          	ld	a0,336(a0)
    800039ea:	901ff0ef          	jal	800032ea <idup>
    800039ee:	8a2a                	mv	s4,a0
  while (*path == '/')
    800039f0:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    800039f4:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    800039f6:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    800039f8:	4b85                	li	s7,1
    800039fa:	a07d                	j	80003aa8 <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    800039fc:	4585                	li	a1,1
    800039fe:	852e                	mv	a0,a1
    80003a00:	eaeff0ef          	jal	800030ae <iget>
    80003a04:	8a2a                	mv	s4,a0
    80003a06:	b7ed                	j	800039f0 <namex+0x3c>
      iunlockput(ip);
    80003a08:	8552                	mv	a0,s4
    80003a0a:	b6bff0ef          	jal	80003574 <iunlockput>
      return 0;
    80003a0e:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003a10:	8552                	mv	a0,s4
    80003a12:	60e6                	ld	ra,88(sp)
    80003a14:	6446                	ld	s0,80(sp)
    80003a16:	64a6                	ld	s1,72(sp)
    80003a18:	6906                	ld	s2,64(sp)
    80003a1a:	79e2                	ld	s3,56(sp)
    80003a1c:	7a42                	ld	s4,48(sp)
    80003a1e:	7aa2                	ld	s5,40(sp)
    80003a20:	7b02                	ld	s6,32(sp)
    80003a22:	6be2                	ld	s7,24(sp)
    80003a24:	6c42                	ld	s8,16(sp)
    80003a26:	6ca2                	ld	s9,8(sp)
    80003a28:	6d02                	ld	s10,0(sp)
    80003a2a:	6125                	addi	sp,sp,96
    80003a2c:	8082                	ret
      iunlockput(ip);
    80003a2e:	8552                	mv	a0,s4
    80003a30:	b45ff0ef          	jal	80003574 <iunlockput>
      return 0;
    80003a34:	4a01                	li	s4,0
    80003a36:	bfe9                	j	80003a10 <namex+0x5c>
      iunlock(ip);
    80003a38:	8552                	mv	a0,s4
    80003a3a:	995ff0ef          	jal	800033ce <iunlock>
      return ip;
    80003a3e:	bfc9                	j	80003a10 <namex+0x5c>
      iunlockput(ip);
    80003a40:	8552                	mv	a0,s4
    80003a42:	b33ff0ef          	jal	80003574 <iunlockput>
      return 0;
    80003a46:	8a4a                	mv	s4,s2
    80003a48:	b7e1                	j	80003a10 <namex+0x5c>
  while (*path != '/' && *path != 0)
    80003a4a:	8926                	mv	s2,s1
  len = path - s;
    80003a4c:	4d01                	li	s10,0
    80003a4e:	4601                	li	a2,0
    memmove(name, s, len);
    80003a50:	2601                	sext.w	a2,a2
    80003a52:	85a6                	mv	a1,s1
    80003a54:	8556                	mv	a0,s5
    80003a56:	af2fd0ef          	jal	80000d48 <memmove>
    name[len] = 0;
    80003a5a:	9d56                	add	s10,s10,s5
    80003a5c:	000d0023          	sb	zero,0(s10)
  while (*path == '/')
    80003a60:	00094783          	lbu	a5,0(s2)
    80003a64:	09379b63          	bne	a5,s3,80003afa <namex+0x146>
    80003a68:	84ca                	mv	s1,s2
    path++;
    80003a6a:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003a6c:	0004c783          	lbu	a5,0(s1)
    80003a70:	ff378de3          	beq	a5,s3,80003a6a <namex+0xb6>
    ilock(ip);
    80003a74:	8552                	mv	a0,s4
    80003a76:	8abff0ef          	jal	80003320 <ilock>
    if (ip->type != T_DIR) {
    80003a7a:	044a1783          	lh	a5,68(s4)
    80003a7e:	f97795e3          	bne	a5,s7,80003a08 <namex+0x54>
    if (ip->nlink == 0) {
    80003a82:	04aa1783          	lh	a5,74(s4)
    80003a86:	d7c5                	beqz	a5,80003a2e <namex+0x7a>
    if (nameiparent && *path == '\0') {
    80003a88:	000b0563          	beqz	s6,80003a92 <namex+0xde>
    80003a8c:	0004c783          	lbu	a5,0(s1)
    80003a90:	d7c5                	beqz	a5,80003a38 <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003a92:	4601                	li	a2,0
    80003a94:	85d6                	mv	a1,s5
    80003a96:	8552                	mv	a0,s4
    80003a98:	e71ff0ef          	jal	80003908 <dirlookup>
    80003a9c:	892a                	mv	s2,a0
    80003a9e:	d14d                	beqz	a0,80003a40 <namex+0x8c>
    iunlockput(ip);
    80003aa0:	8552                	mv	a0,s4
    80003aa2:	ad3ff0ef          	jal	80003574 <iunlockput>
    ip = next;
    80003aa6:	8a4a                	mv	s4,s2
  while (*path == '/')
    80003aa8:	0004c783          	lbu	a5,0(s1)
    80003aac:	01379763          	bne	a5,s3,80003aba <namex+0x106>
    path++;
    80003ab0:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003ab2:	0004c783          	lbu	a5,0(s1)
    80003ab6:	ff378de3          	beq	a5,s3,80003ab0 <namex+0xfc>
  if (*path == 0)
    80003aba:	c7a1                	beqz	a5,80003b02 <namex+0x14e>
  while (*path != '/' && *path != 0)
    80003abc:	0004c783          	lbu	a5,0(s1)
    80003ac0:	fd178713          	addi	a4,a5,-47
    80003ac4:	d359                	beqz	a4,80003a4a <namex+0x96>
    80003ac6:	d3d1                	beqz	a5,80003a4a <namex+0x96>
    80003ac8:	8926                	mv	s2,s1
    path++;
    80003aca:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    80003acc:	00094783          	lbu	a5,0(s2)
    80003ad0:	fd178713          	addi	a4,a5,-47
    80003ad4:	c311                	beqz	a4,80003ad8 <namex+0x124>
    80003ad6:	fbf5                	bnez	a5,80003aca <namex+0x116>
  len = path - s;
    80003ad8:	40990633          	sub	a2,s2,s1
    80003adc:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80003ae0:	f7ac58e3          	bge	s8,s10,80003a50 <namex+0x9c>
    memmove(name, s, DIRSIZ);
    80003ae4:	8666                	mv	a2,s9
    80003ae6:	85a6                	mv	a1,s1
    80003ae8:	8556                	mv	a0,s5
    80003aea:	a5efd0ef          	jal	80000d48 <memmove>
  while (*path == '/')
    80003aee:	00094783          	lbu	a5,0(s2)
    80003af2:	84ca                	mv	s1,s2
    80003af4:	f7378be3          	beq	a5,s3,80003a6a <namex+0xb6>
    80003af8:	bfb5                	j	80003a74 <namex+0xc0>
  while ((path = skipelem(path, name)) != 0) {
    80003afa:	00090463          	beqz	s2,80003b02 <namex+0x14e>
    80003afe:	84ca                	mv	s1,s2
    80003b00:	bf95                	j	80003a74 <namex+0xc0>
  if (nameiparent) {
    80003b02:	f00b07e3          	beqz	s6,80003a10 <namex+0x5c>
    iput(ip);
    80003b06:	8552                	mv	a0,s4
    80003b08:	99bff0ef          	jal	800034a2 <iput>
    return 0;
    80003b0c:	4a01                	li	s4,0
    80003b0e:	b709                	j	80003a10 <namex+0x5c>

0000000080003b10 <dirlink>:
{
    80003b10:	715d                	addi	sp,sp,-80
    80003b12:	e486                	sd	ra,72(sp)
    80003b14:	e0a2                	sd	s0,64(sp)
    80003b16:	f84a                	sd	s2,48(sp)
    80003b18:	ec56                	sd	s5,24(sp)
    80003b1a:	e85a                	sd	s6,16(sp)
    80003b1c:	0880                	addi	s0,sp,80
    80003b1e:	892a                	mv	s2,a0
    80003b20:	8aae                	mv	s5,a1
    80003b22:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003b24:	4601                	li	a2,0
    80003b26:	de3ff0ef          	jal	80003908 <dirlookup>
    80003b2a:	ed1d                	bnez	a0,80003b68 <dirlink+0x58>
    80003b2c:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003b2e:	04c92483          	lw	s1,76(s2)
    80003b32:	c4b9                	beqz	s1,80003b80 <dirlink+0x70>
    80003b34:	f44e                	sd	s3,40(sp)
    80003b36:	f052                	sd	s4,32(sp)
    80003b38:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b3a:	fb040a13          	addi	s4,s0,-80
    80003b3e:	49c1                	li	s3,16
    80003b40:	874e                	mv	a4,s3
    80003b42:	86a6                	mv	a3,s1
    80003b44:	8652                	mv	a2,s4
    80003b46:	4581                	li	a1,0
    80003b48:	854a                	mv	a0,s2
    80003b4a:	bb1ff0ef          	jal	800036fa <readi>
    80003b4e:	03351163          	bne	a0,s3,80003b70 <dirlink+0x60>
    if (de.inum == 0)
    80003b52:	fb045783          	lhu	a5,-80(s0)
    80003b56:	c39d                	beqz	a5,80003b7c <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003b58:	24c1                	addiw	s1,s1,16
    80003b5a:	04c92783          	lw	a5,76(s2)
    80003b5e:	fef4e1e3          	bltu	s1,a5,80003b40 <dirlink+0x30>
    80003b62:	79a2                	ld	s3,40(sp)
    80003b64:	7a02                	ld	s4,32(sp)
    80003b66:	a829                	j	80003b80 <dirlink+0x70>
    iput(ip);
    80003b68:	93bff0ef          	jal	800034a2 <iput>
    return -1;
    80003b6c:	557d                	li	a0,-1
    80003b6e:	a83d                	j	80003bac <dirlink+0x9c>
      panic("dirlink read");
    80003b70:	00004517          	auipc	a0,0x4
    80003b74:	97850513          	addi	a0,a0,-1672 # 800074e8 <etext+0x4e8>
    80003b78:	cbdfc0ef          	jal	80000834 <panic>
    80003b7c:	79a2                	ld	s3,40(sp)
    80003b7e:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003b80:	4639                	li	a2,14
    80003b82:	85d6                	mv	a1,s5
    80003b84:	fb240513          	addi	a0,s0,-78
    80003b88:	a6efd0ef          	jal	80000df6 <strncpy>
  de.inum = inum;
    80003b8c:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b90:	4741                	li	a4,16
    80003b92:	86a6                	mv	a3,s1
    80003b94:	fb040613          	addi	a2,s0,-80
    80003b98:	4581                	li	a1,0
    80003b9a:	854a                	mv	a0,s2
    80003b9c:	c51ff0ef          	jal	800037ec <writei>
    80003ba0:	1541                	addi	a0,a0,-16
    80003ba2:	00a03533          	snez	a0,a0
    80003ba6:	40a0053b          	negw	a0,a0
    80003baa:	74e2                	ld	s1,56(sp)
}
    80003bac:	60a6                	ld	ra,72(sp)
    80003bae:	6406                	ld	s0,64(sp)
    80003bb0:	7942                	ld	s2,48(sp)
    80003bb2:	6ae2                	ld	s5,24(sp)
    80003bb4:	6b42                	ld	s6,16(sp)
    80003bb6:	6161                	addi	sp,sp,80
    80003bb8:	8082                	ret

0000000080003bba <namei>:

struct inode *
namei(char *path)
{
    80003bba:	1101                	addi	sp,sp,-32
    80003bbc:	ec06                	sd	ra,24(sp)
    80003bbe:	e822                	sd	s0,16(sp)
    80003bc0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003bc2:	fe040613          	addi	a2,s0,-32
    80003bc6:	4581                	li	a1,0
    80003bc8:	dedff0ef          	jal	800039b4 <namex>
}
    80003bcc:	60e2                	ld	ra,24(sp)
    80003bce:	6442                	ld	s0,16(sp)
    80003bd0:	6105                	addi	sp,sp,32
    80003bd2:	8082                	ret

0000000080003bd4 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003bd4:	1141                	addi	sp,sp,-16
    80003bd6:	e406                	sd	ra,8(sp)
    80003bd8:	e022                	sd	s0,0(sp)
    80003bda:	0800                	addi	s0,sp,16
    80003bdc:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003bde:	4585                	li	a1,1
    80003be0:	dd5ff0ef          	jal	800039b4 <namex>
}
    80003be4:	60a2                	ld	ra,8(sp)
    80003be6:	6402                	ld	s0,0(sp)
    80003be8:	0141                	addi	sp,sp,16
    80003bea:	8082                	ret

0000000080003bec <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003bec:	1101                	addi	sp,sp,-32
    80003bee:	ec06                	sd	ra,24(sp)
    80003bf0:	e822                	sd	s0,16(sp)
    80003bf2:	e426                	sd	s1,8(sp)
    80003bf4:	e04a                	sd	s2,0(sp)
    80003bf6:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003bf8:	0001f917          	auipc	s2,0x1f
    80003bfc:	a4090913          	addi	s2,s2,-1472 # 80022638 <log>
    80003c00:	01892583          	lw	a1,24(s2)
    80003c04:	02492503          	lw	a0,36(s2)
    80003c08:	880ff0ef          	jal	80002c88 <bread>
    80003c0c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003c0e:	02c92603          	lw	a2,44(s2)
    80003c12:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003c14:	00c05f63          	blez	a2,80003c32 <write_head+0x46>
    80003c18:	0001f717          	auipc	a4,0x1f
    80003c1c:	a5070713          	addi	a4,a4,-1456 # 80022668 <log+0x30>
    80003c20:	87aa                	mv	a5,a0
    80003c22:	060a                	slli	a2,a2,0x2
    80003c24:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003c26:	4314                	lw	a3,0(a4)
    80003c28:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003c2a:	0711                	addi	a4,a4,4
    80003c2c:	0791                	addi	a5,a5,4
    80003c2e:	fec79ce3          	bne	a5,a2,80003c26 <write_head+0x3a>
  }
  bwrite(buf);
    80003c32:	8526                	mv	a0,s1
    80003c34:	92aff0ef          	jal	80002d5e <bwrite>
  brelse(buf);
    80003c38:	8526                	mv	a0,s1
    80003c3a:	956ff0ef          	jal	80002d90 <brelse>
}
    80003c3e:	60e2                	ld	ra,24(sp)
    80003c40:	6442                	ld	s0,16(sp)
    80003c42:	64a2                	ld	s1,8(sp)
    80003c44:	6902                	ld	s2,0(sp)
    80003c46:	6105                	addi	sp,sp,32
    80003c48:	8082                	ret

0000000080003c4a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c4a:	0001f797          	auipc	a5,0x1f
    80003c4e:	a1a7a783          	lw	a5,-1510(a5) # 80022664 <log+0x2c>
    80003c52:	0cf05163          	blez	a5,80003d14 <install_trans+0xca>
{
    80003c56:	715d                	addi	sp,sp,-80
    80003c58:	e486                	sd	ra,72(sp)
    80003c5a:	e0a2                	sd	s0,64(sp)
    80003c5c:	fc26                	sd	s1,56(sp)
    80003c5e:	f84a                	sd	s2,48(sp)
    80003c60:	f44e                	sd	s3,40(sp)
    80003c62:	f052                	sd	s4,32(sp)
    80003c64:	ec56                	sd	s5,24(sp)
    80003c66:	e85a                	sd	s6,16(sp)
    80003c68:	e45e                	sd	s7,8(sp)
    80003c6a:	e062                	sd	s8,0(sp)
    80003c6c:	0880                	addi	s0,sp,80
    80003c6e:	8b2a                	mv	s6,a0
    80003c70:	0001fa97          	auipc	s5,0x1f
    80003c74:	9f8a8a93          	addi	s5,s5,-1544 # 80022668 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c78:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c7a:	00004c17          	auipc	s8,0x4
    80003c7e:	87ec0c13          	addi	s8,s8,-1922 # 800074f8 <etext+0x4f8>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003c82:	0001fa17          	auipc	s4,0x1f
    80003c86:	9b6a0a13          	addi	s4,s4,-1610 # 80022638 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003c8a:	40000b93          	li	s7,1024
    80003c8e:	a025                	j	80003cb6 <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c90:	000aa603          	lw	a2,0(s5)
    80003c94:	85ce                	mv	a1,s3
    80003c96:	8562                	mv	a0,s8
    80003c98:	873fc0ef          	jal	8000050a <printk>
    80003c9c:	a839                	j	80003cba <install_trans+0x70>
    brelse(lbuf);
    80003c9e:	854a                	mv	a0,s2
    80003ca0:	8f0ff0ef          	jal	80002d90 <brelse>
    brelse(dbuf);
    80003ca4:	8526                	mv	a0,s1
    80003ca6:	8eaff0ef          	jal	80002d90 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003caa:	2985                	addiw	s3,s3,1
    80003cac:	0a91                	addi	s5,s5,4
    80003cae:	02ca2783          	lw	a5,44(s4)
    80003cb2:	04f9d563          	bge	s3,a5,80003cfc <install_trans+0xb2>
    if (recovering) {
    80003cb6:	fc0b1de3          	bnez	s6,80003c90 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003cba:	018a2583          	lw	a1,24(s4)
    80003cbe:	013585bb          	addw	a1,a1,s3
    80003cc2:	2585                	addiw	a1,a1,1
    80003cc4:	024a2503          	lw	a0,36(s4)
    80003cc8:	fc1fe0ef          	jal	80002c88 <bread>
    80003ccc:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003cce:	000aa583          	lw	a1,0(s5)
    80003cd2:	024a2503          	lw	a0,36(s4)
    80003cd6:	fb3fe0ef          	jal	80002c88 <bread>
    80003cda:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003cdc:	865e                	mv	a2,s7
    80003cde:	05890593          	addi	a1,s2,88
    80003ce2:	05850513          	addi	a0,a0,88
    80003ce6:	862fd0ef          	jal	80000d48 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003cea:	8526                	mv	a0,s1
    80003cec:	872ff0ef          	jal	80002d5e <bwrite>
    if (recovering == 0)
    80003cf0:	fa0b17e3          	bnez	s6,80003c9e <install_trans+0x54>
      bunpin(dbuf);
    80003cf4:	8526                	mv	a0,s1
    80003cf6:	952ff0ef          	jal	80002e48 <bunpin>
    80003cfa:	b755                	j	80003c9e <install_trans+0x54>
}
    80003cfc:	60a6                	ld	ra,72(sp)
    80003cfe:	6406                	ld	s0,64(sp)
    80003d00:	74e2                	ld	s1,56(sp)
    80003d02:	7942                	ld	s2,48(sp)
    80003d04:	79a2                	ld	s3,40(sp)
    80003d06:	7a02                	ld	s4,32(sp)
    80003d08:	6ae2                	ld	s5,24(sp)
    80003d0a:	6b42                	ld	s6,16(sp)
    80003d0c:	6ba2                	ld	s7,8(sp)
    80003d0e:	6c02                	ld	s8,0(sp)
    80003d10:	6161                	addi	sp,sp,80
    80003d12:	8082                	ret
    80003d14:	8082                	ret

0000000080003d16 <initlog>:
{
    80003d16:	7179                	addi	sp,sp,-48
    80003d18:	f406                	sd	ra,40(sp)
    80003d1a:	f022                	sd	s0,32(sp)
    80003d1c:	ec26                	sd	s1,24(sp)
    80003d1e:	e84a                	sd	s2,16(sp)
    80003d20:	e44e                	sd	s3,8(sp)
    80003d22:	1800                	addi	s0,sp,48
    80003d24:	84aa                	mv	s1,a0
    80003d26:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003d28:	0001f917          	auipc	s2,0x1f
    80003d2c:	91090913          	addi	s2,s2,-1776 # 80022638 <log>
    80003d30:	00003597          	auipc	a1,0x3
    80003d34:	7e858593          	addi	a1,a1,2024 # 80007518 <etext+0x518>
    80003d38:	854a                	mv	a0,s2
    80003d3a:	e6ffc0ef          	jal	80000ba8 <initlock>
  log.start = sb->logstart;
    80003d3e:	0149a583          	lw	a1,20(s3)
    80003d42:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003d46:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003d4a:	8526                	mv	a0,s1
    80003d4c:	f3dfe0ef          	jal	80002c88 <bread>
  log.lh.n = lh->n;
    80003d50:	4d30                	lw	a2,88(a0)
    80003d52:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003d56:	00c05f63          	blez	a2,80003d74 <initlog+0x5e>
    80003d5a:	87aa                	mv	a5,a0
    80003d5c:	0001f717          	auipc	a4,0x1f
    80003d60:	90c70713          	addi	a4,a4,-1780 # 80022668 <log+0x30>
    80003d64:	060a                	slli	a2,a2,0x2
    80003d66:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003d68:	4ff4                	lw	a3,92(a5)
    80003d6a:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003d6c:	0791                	addi	a5,a5,4
    80003d6e:	0711                	addi	a4,a4,4
    80003d70:	fec79ce3          	bne	a5,a2,80003d68 <initlog+0x52>
  brelse(buf);
    80003d74:	81cff0ef          	jal	80002d90 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003d78:	4505                	li	a0,1
    80003d7a:	ed1ff0ef          	jal	80003c4a <install_trans>
  log.lh.n = 0;
    80003d7e:	0001f797          	auipc	a5,0x1f
    80003d82:	8e07a323          	sw	zero,-1818(a5) # 80022664 <log+0x2c>
  write_head(); // clear the log
    80003d86:	e67ff0ef          	jal	80003bec <write_head>
}
    80003d8a:	70a2                	ld	ra,40(sp)
    80003d8c:	7402                	ld	s0,32(sp)
    80003d8e:	64e2                	ld	s1,24(sp)
    80003d90:	6942                	ld	s2,16(sp)
    80003d92:	69a2                	ld	s3,8(sp)
    80003d94:	6145                	addi	sp,sp,48
    80003d96:	8082                	ret

0000000080003d98 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003d98:	1101                	addi	sp,sp,-32
    80003d9a:	ec06                	sd	ra,24(sp)
    80003d9c:	e822                	sd	s0,16(sp)
    80003d9e:	e426                	sd	s1,8(sp)
    80003da0:	e04a                	sd	s2,0(sp)
    80003da2:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003da4:	0001f517          	auipc	a0,0x1f
    80003da8:	89450513          	addi	a0,a0,-1900 # 80022638 <log>
    80003dac:	e7dfc0ef          	jal	80000c28 <acquire>
  while (1) {
    if (log.committing) {
    80003db0:	0001f497          	auipc	s1,0x1f
    80003db4:	88848493          	addi	s1,s1,-1912 # 80022638 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003db8:	4979                	li	s2,30
    80003dba:	a821                	j	80003dd2 <begin_op+0x3a>
      sleep_prepare(&log);
    80003dbc:	8526                	mv	a0,s1
    80003dbe:	a48fe0ef          	jal	80002006 <sleep_prepare>
      release(&log.lock);
    80003dc2:	8526                	mv	a0,s1
    80003dc4:	eedfc0ef          	jal	80000cb0 <release>
      sleep();
    80003dc8:	a7afe0ef          	jal	80002042 <sleep>
      acquire(&log.lock);
    80003dcc:	8526                	mv	a0,s1
    80003dce:	e5bfc0ef          	jal	80000c28 <acquire>
    if (log.committing) {
    80003dd2:	509c                	lw	a5,32(s1)
    80003dd4:	f7e5                	bnez	a5,80003dbc <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003dd6:	4cd8                	lw	a4,28(s1)
    80003dd8:	2705                	addiw	a4,a4,1
    80003dda:	0027179b          	slliw	a5,a4,0x2
    80003dde:	9fb9                	addw	a5,a5,a4
    80003de0:	0017979b          	slliw	a5,a5,0x1
    80003de4:	54d4                	lw	a3,44(s1)
    80003de6:	9fb5                	addw	a5,a5,a3
    80003de8:	00f95e63          	bge	s2,a5,80003e04 <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003dec:	8526                	mv	a0,s1
    80003dee:	a18fe0ef          	jal	80002006 <sleep_prepare>
      release(&log.lock);
    80003df2:	8526                	mv	a0,s1
    80003df4:	ebdfc0ef          	jal	80000cb0 <release>
      sleep();
    80003df8:	a4afe0ef          	jal	80002042 <sleep>
      acquire(&log.lock);
    80003dfc:	8526                	mv	a0,s1
    80003dfe:	e2bfc0ef          	jal	80000c28 <acquire>
    80003e02:	bfc1                	j	80003dd2 <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003e04:	0001f797          	auipc	a5,0x1f
    80003e08:	84e7a823          	sw	a4,-1968(a5) # 80022654 <log+0x1c>
      release(&log.lock);
    80003e0c:	0001f517          	auipc	a0,0x1f
    80003e10:	82c50513          	addi	a0,a0,-2004 # 80022638 <log>
    80003e14:	e9dfc0ef          	jal	80000cb0 <release>
      break;
    }
  }
}
    80003e18:	60e2                	ld	ra,24(sp)
    80003e1a:	6442                	ld	s0,16(sp)
    80003e1c:	64a2                	ld	s1,8(sp)
    80003e1e:	6902                	ld	s2,0(sp)
    80003e20:	6105                	addi	sp,sp,32
    80003e22:	8082                	ret

0000000080003e24 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003e24:	7139                	addi	sp,sp,-64
    80003e26:	fc06                	sd	ra,56(sp)
    80003e28:	f822                	sd	s0,48(sp)
    80003e2a:	f426                	sd	s1,40(sp)
    80003e2c:	f04a                	sd	s2,32(sp)
    80003e2e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003e30:	0001f497          	auipc	s1,0x1f
    80003e34:	80848493          	addi	s1,s1,-2040 # 80022638 <log>
    80003e38:	8526                	mv	a0,s1
    80003e3a:	deffc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003e3e:	4cdc                	lw	a5,28(s1)
    80003e40:	37fd                	addiw	a5,a5,-1
    80003e42:	893e                	mv	s2,a5
    80003e44:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003e46:	509c                	lw	a5,32(s1)
    80003e48:	e3b1                	bnez	a5,80003e8c <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003e4a:	04091a63          	bnez	s2,80003e9e <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    80003e4e:	0001e497          	auipc	s1,0x1e
    80003e52:	7ea48493          	addi	s1,s1,2026 # 80022638 <log>
    80003e56:	4785                	li	a5,1
    80003e58:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003e5a:	8526                	mv	a0,s1
    80003e5c:	e55fc0ef          	jal	80000cb0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003e60:	54dc                	lw	a5,44(s1)
    80003e62:	06f04063          	bgtz	a5,80003ec2 <end_op+0x9e>
    acquire(&log.lock);
    80003e66:	0001e497          	auipc	s1,0x1e
    80003e6a:	7d248493          	addi	s1,s1,2002 # 80022638 <log>
    80003e6e:	8526                	mv	a0,s1
    80003e70:	db9fc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003e74:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003e78:	549c                	lw	a5,40(s1)
    80003e7a:	2785                	addiw	a5,a5,1
    80003e7c:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003e7e:	8526                	mv	a0,s1
    80003e80:	9f2fe0ef          	jal	80002072 <wakeup>
    release(&log.lock);
    80003e84:	8526                	mv	a0,s1
    80003e86:	e2bfc0ef          	jal	80000cb0 <release>
}
    80003e8a:	a035                	j	80003eb6 <end_op+0x92>
    80003e8c:	ec4e                	sd	s3,24(sp)
    80003e8e:	e852                	sd	s4,16(sp)
    80003e90:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003e92:	00003517          	auipc	a0,0x3
    80003e96:	68e50513          	addi	a0,a0,1678 # 80007520 <etext+0x520>
    80003e9a:	99bfc0ef          	jal	80000834 <panic>
    wakeup(&log);
    80003e9e:	0001e517          	auipc	a0,0x1e
    80003ea2:	79a50513          	addi	a0,a0,1946 # 80022638 <log>
    80003ea6:	9ccfe0ef          	jal	80002072 <wakeup>
  release(&log.lock);
    80003eaa:	0001e517          	auipc	a0,0x1e
    80003eae:	78e50513          	addi	a0,a0,1934 # 80022638 <log>
    80003eb2:	dfffc0ef          	jal	80000cb0 <release>
}
    80003eb6:	70e2                	ld	ra,56(sp)
    80003eb8:	7442                	ld	s0,48(sp)
    80003eba:	74a2                	ld	s1,40(sp)
    80003ebc:	7902                	ld	s2,32(sp)
    80003ebe:	6121                	addi	sp,sp,64
    80003ec0:	8082                	ret
    80003ec2:	ec4e                	sd	s3,24(sp)
    80003ec4:	e852                	sd	s4,16(sp)
    80003ec6:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ec8:	0001ea97          	auipc	s5,0x1e
    80003ecc:	7a0a8a93          	addi	s5,s5,1952 # 80022668 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003ed0:	0001ea17          	auipc	s4,0x1e
    80003ed4:	768a0a13          	addi	s4,s4,1896 # 80022638 <log>
    80003ed8:	018a2583          	lw	a1,24(s4)
    80003edc:	012585bb          	addw	a1,a1,s2
    80003ee0:	2585                	addiw	a1,a1,1
    80003ee2:	024a2503          	lw	a0,36(s4)
    80003ee6:	da3fe0ef          	jal	80002c88 <bread>
    80003eea:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003eec:	000aa583          	lw	a1,0(s5)
    80003ef0:	024a2503          	lw	a0,36(s4)
    80003ef4:	d95fe0ef          	jal	80002c88 <bread>
    80003ef8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003efa:	40000613          	li	a2,1024
    80003efe:	05850593          	addi	a1,a0,88
    80003f02:	05848513          	addi	a0,s1,88
    80003f06:	e43fc0ef          	jal	80000d48 <memmove>
    bwrite(to); // write the log
    80003f0a:	8526                	mv	a0,s1
    80003f0c:	e53fe0ef          	jal	80002d5e <bwrite>
    brelse(from);
    80003f10:	854e                	mv	a0,s3
    80003f12:	e7ffe0ef          	jal	80002d90 <brelse>
    brelse(to);
    80003f16:	8526                	mv	a0,s1
    80003f18:	e79fe0ef          	jal	80002d90 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f1c:	2905                	addiw	s2,s2,1
    80003f1e:	0a91                	addi	s5,s5,4
    80003f20:	02ca2783          	lw	a5,44(s4)
    80003f24:	faf94ae3          	blt	s2,a5,80003ed8 <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80003f28:	cc5ff0ef          	jal	80003bec <write_head>
    install_trans(0); // Now install writes to home locations
    80003f2c:	4501                	li	a0,0
    80003f2e:	d1dff0ef          	jal	80003c4a <install_trans>
    log.lh.n = 0;
    80003f32:	0001e797          	auipc	a5,0x1e
    80003f36:	7207a923          	sw	zero,1842(a5) # 80022664 <log+0x2c>
    write_head(); // Erase the transaction from the log
    80003f3a:	cb3ff0ef          	jal	80003bec <write_head>
    80003f3e:	69e2                	ld	s3,24(sp)
    80003f40:	6a42                	ld	s4,16(sp)
    80003f42:	6aa2                	ld	s5,8(sp)
    80003f44:	b70d                	j	80003e66 <end_op+0x42>

0000000080003f46 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003f46:	1101                	addi	sp,sp,-32
    80003f48:	ec06                	sd	ra,24(sp)
    80003f4a:	e822                	sd	s0,16(sp)
    80003f4c:	e426                	sd	s1,8(sp)
    80003f4e:	1000                	addi	s0,sp,32
    80003f50:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003f52:	0001e517          	auipc	a0,0x1e
    80003f56:	6e650513          	addi	a0,a0,1766 # 80022638 <log>
    80003f5a:	ccffc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003f5e:	0001e617          	auipc	a2,0x1e
    80003f62:	70662603          	lw	a2,1798(a2) # 80022664 <log+0x2c>
    80003f66:	47f5                	li	a5,29
    80003f68:	04c7cd63          	blt	a5,a2,80003fc2 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003f6c:	0001e797          	auipc	a5,0x1e
    80003f70:	6e87a783          	lw	a5,1768(a5) # 80022654 <log+0x1c>
    80003f74:	04f05d63          	blez	a5,80003fce <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003f78:	4781                	li	a5,0
    80003f7a:	06c05063          	blez	a2,80003fda <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    80003f7e:	44cc                	lw	a1,12(s1)
    80003f80:	0001e717          	auipc	a4,0x1e
    80003f84:	6e870713          	addi	a4,a4,1768 # 80022668 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003f88:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80003f8a:	4314                	lw	a3,0(a4)
    80003f8c:	04b68763          	beq	a3,a1,80003fda <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80003f90:	2785                	addiw	a5,a5,1
    80003f92:	0711                	addi	a4,a4,4
    80003f94:	fef61be3          	bne	a2,a5,80003f8a <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003f98:	060a                	slli	a2,a2,0x2
    80003f9a:	02060613          	addi	a2,a2,32
    80003f9e:	0001e797          	auipc	a5,0x1e
    80003fa2:	69a78793          	addi	a5,a5,1690 # 80022638 <log>
    80003fa6:	97b2                	add	a5,a5,a2
    80003fa8:	44d8                	lw	a4,12(s1)
    80003faa:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80003fac:	8526                	mv	a0,s1
    80003fae:	e67fe0ef          	jal	80002e14 <bpin>
    log.lh.n++;
    80003fb2:	0001e717          	auipc	a4,0x1e
    80003fb6:	68670713          	addi	a4,a4,1670 # 80022638 <log>
    80003fba:	575c                	lw	a5,44(a4)
    80003fbc:	2785                	addiw	a5,a5,1
    80003fbe:	d75c                	sw	a5,44(a4)
    80003fc0:	a815                	j	80003ff4 <log_write+0xae>
    panic("too big a transaction");
    80003fc2:	00003517          	auipc	a0,0x3
    80003fc6:	56e50513          	addi	a0,a0,1390 # 80007530 <etext+0x530>
    80003fca:	86bfc0ef          	jal	80000834 <panic>
    panic("log_write outside of trans");
    80003fce:	00003517          	auipc	a0,0x3
    80003fd2:	57a50513          	addi	a0,a0,1402 # 80007548 <etext+0x548>
    80003fd6:	85ffc0ef          	jal	80000834 <panic>
  log.lh.block[i] = b->blockno;
    80003fda:	00279693          	slli	a3,a5,0x2
    80003fde:	02068693          	addi	a3,a3,32
    80003fe2:	0001e717          	auipc	a4,0x1e
    80003fe6:	65670713          	addi	a4,a4,1622 # 80022638 <log>
    80003fea:	9736                	add	a4,a4,a3
    80003fec:	44d4                	lw	a3,12(s1)
    80003fee:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    80003ff0:	faf60ee3          	beq	a2,a5,80003fac <log_write+0x66>
  }
  release(&log.lock);
    80003ff4:	0001e517          	auipc	a0,0x1e
    80003ff8:	64450513          	addi	a0,a0,1604 # 80022638 <log>
    80003ffc:	cb5fc0ef          	jal	80000cb0 <release>
}
    80004000:	60e2                	ld	ra,24(sp)
    80004002:	6442                	ld	s0,16(sp)
    80004004:	64a2                	ld	s1,8(sp)
    80004006:	6105                	addi	sp,sp,32
    80004008:	8082                	ret

000000008000400a <sys_sync>:

uint64
sys_sync(void)
{
    8000400a:	1101                	addi	sp,sp,-32
    8000400c:	ec06                	sd	ra,24(sp)
    8000400e:	e822                	sd	s0,16(sp)
    80004010:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004012:	0001e517          	auipc	a0,0x1e
    80004016:	62650513          	addi	a0,a0,1574 # 80022638 <log>
    8000401a:	c0ffc0ef          	jal	80000c28 <acquire>
  if (log.committing || log.outstanding > 0) {
    8000401e:	0001e797          	auipc	a5,0x1e
    80004022:	63a7a783          	lw	a5,1594(a5) # 80022658 <log+0x20>
    80004026:	e799                	bnez	a5,80004034 <sys_sync+0x2a>
    80004028:	0001e797          	auipc	a5,0x1e
    8000402c:	62c7a783          	lw	a5,1580(a5) # 80022654 <log+0x1c>
    80004030:	02f05c63          	blez	a5,80004068 <sys_sync+0x5e>
    80004034:	e426                	sd	s1,8(sp)
    80004036:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    80004038:	0001e917          	auipc	s2,0x1e
    8000403c:	62892903          	lw	s2,1576(s2) # 80022660 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    80004040:	0001e497          	auipc	s1,0x1e
    80004044:	5f848493          	addi	s1,s1,1528 # 80022638 <log>
    80004048:	8526                	mv	a0,s1
    8000404a:	fbdfd0ef          	jal	80002006 <sleep_prepare>
      release(&log.lock);
    8000404e:	8526                	mv	a0,s1
    80004050:	c61fc0ef          	jal	80000cb0 <release>
      sleep();
    80004054:	feffd0ef          	jal	80002042 <sleep>
      acquire(&log.lock);
    80004058:	8526                	mv	a0,s1
    8000405a:	bcffc0ef          	jal	80000c28 <acquire>
    while (log.ncommit < n) {
    8000405e:	549c                	lw	a5,40(s1)
    80004060:	fef954e3          	bge	s2,a5,80004048 <sys_sync+0x3e>
    80004064:	64a2                	ld	s1,8(sp)
    80004066:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    80004068:	0001e517          	auipc	a0,0x1e
    8000406c:	5d050513          	addi	a0,a0,1488 # 80022638 <log>
    80004070:	c41fc0ef          	jal	80000cb0 <release>
  return 0;
}
    80004074:	4501                	li	a0,0
    80004076:	60e2                	ld	ra,24(sp)
    80004078:	6442                	ld	s0,16(sp)
    8000407a:	6105                	addi	sp,sp,32
    8000407c:	8082                	ret

000000008000407e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000407e:	1101                	addi	sp,sp,-32
    80004080:	ec06                	sd	ra,24(sp)
    80004082:	e822                	sd	s0,16(sp)
    80004084:	e426                	sd	s1,8(sp)
    80004086:	e04a                	sd	s2,0(sp)
    80004088:	1000                	addi	s0,sp,32
    8000408a:	84aa                	mv	s1,a0
    8000408c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000408e:	00003597          	auipc	a1,0x3
    80004092:	4da58593          	addi	a1,a1,1242 # 80007568 <etext+0x568>
    80004096:	0521                	addi	a0,a0,8
    80004098:	b11fc0ef          	jal	80000ba8 <initlock>
  lk->name = name;
    8000409c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800040a0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800040a4:	0204a423          	sw	zero,40(s1)
}
    800040a8:	60e2                	ld	ra,24(sp)
    800040aa:	6442                	ld	s0,16(sp)
    800040ac:	64a2                	ld	s1,8(sp)
    800040ae:	6902                	ld	s2,0(sp)
    800040b0:	6105                	addi	sp,sp,32
    800040b2:	8082                	ret

00000000800040b4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800040b4:	1101                	addi	sp,sp,-32
    800040b6:	ec06                	sd	ra,24(sp)
    800040b8:	e822                	sd	s0,16(sp)
    800040ba:	e426                	sd	s1,8(sp)
    800040bc:	e04a                	sd	s2,0(sp)
    800040be:	1000                	addi	s0,sp,32
    800040c0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800040c2:	00850913          	addi	s2,a0,8
    800040c6:	854a                	mv	a0,s2
    800040c8:	b61fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    800040cc:	409c                	lw	a5,0(s1)
    800040ce:	cf91                	beqz	a5,800040ea <acquiresleep+0x36>
    sleep_prepare(lk);
    800040d0:	8526                	mv	a0,s1
    800040d2:	f35fd0ef          	jal	80002006 <sleep_prepare>
    release(&lk->lk);
    800040d6:	854a                	mv	a0,s2
    800040d8:	bd9fc0ef          	jal	80000cb0 <release>
    sleep();
    800040dc:	f67fd0ef          	jal	80002042 <sleep>
    acquire(&lk->lk);
    800040e0:	854a                	mv	a0,s2
    800040e2:	b47fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    800040e6:	409c                	lw	a5,0(s1)
    800040e8:	f7e5                	bnez	a5,800040d0 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800040ea:	4785                	li	a5,1
    800040ec:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800040ee:	85bfd0ef          	jal	80001948 <myproc>
    800040f2:	591c                	lw	a5,48(a0)
    800040f4:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800040f6:	854a                	mv	a0,s2
    800040f8:	bb9fc0ef          	jal	80000cb0 <release>
}
    800040fc:	60e2                	ld	ra,24(sp)
    800040fe:	6442                	ld	s0,16(sp)
    80004100:	64a2                	ld	s1,8(sp)
    80004102:	6902                	ld	s2,0(sp)
    80004104:	6105                	addi	sp,sp,32
    80004106:	8082                	ret

0000000080004108 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004108:	1101                	addi	sp,sp,-32
    8000410a:	ec06                	sd	ra,24(sp)
    8000410c:	e822                	sd	s0,16(sp)
    8000410e:	e426                	sd	s1,8(sp)
    80004110:	e04a                	sd	s2,0(sp)
    80004112:	1000                	addi	s0,sp,32
    80004114:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004116:	00850913          	addi	s2,a0,8
    8000411a:	854a                	mv	a0,s2
    8000411c:	b0dfc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    80004120:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004124:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004128:	8526                	mv	a0,s1
    8000412a:	f49fd0ef          	jal	80002072 <wakeup>
  release(&lk->lk);
    8000412e:	854a                	mv	a0,s2
    80004130:	b81fc0ef          	jal	80000cb0 <release>
}
    80004134:	60e2                	ld	ra,24(sp)
    80004136:	6442                	ld	s0,16(sp)
    80004138:	64a2                	ld	s1,8(sp)
    8000413a:	6902                	ld	s2,0(sp)
    8000413c:	6105                	addi	sp,sp,32
    8000413e:	8082                	ret

0000000080004140 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004140:	7179                	addi	sp,sp,-48
    80004142:	f406                	sd	ra,40(sp)
    80004144:	f022                	sd	s0,32(sp)
    80004146:	ec26                	sd	s1,24(sp)
    80004148:	e84a                	sd	s2,16(sp)
    8000414a:	1800                	addi	s0,sp,48
    8000414c:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    8000414e:	00850913          	addi	s2,a0,8
    80004152:	854a                	mv	a0,s2
    80004154:	ad5fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004158:	409c                	lw	a5,0(s1)
    8000415a:	ef81                	bnez	a5,80004172 <holdingsleep+0x32>
    8000415c:	4481                	li	s1,0
  release(&lk->lk);
    8000415e:	854a                	mv	a0,s2
    80004160:	b51fc0ef          	jal	80000cb0 <release>
  return r;
}
    80004164:	8526                	mv	a0,s1
    80004166:	70a2                	ld	ra,40(sp)
    80004168:	7402                	ld	s0,32(sp)
    8000416a:	64e2                	ld	s1,24(sp)
    8000416c:	6942                	ld	s2,16(sp)
    8000416e:	6145                	addi	sp,sp,48
    80004170:	8082                	ret
    80004172:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004174:	0284a983          	lw	s3,40(s1)
    80004178:	fd0fd0ef          	jal	80001948 <myproc>
    8000417c:	5904                	lw	s1,48(a0)
    8000417e:	413484b3          	sub	s1,s1,s3
    80004182:	0014b493          	seqz	s1,s1
    80004186:	69a2                	ld	s3,8(sp)
    80004188:	bfd9                	j	8000415e <holdingsleep+0x1e>

000000008000418a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000418a:	1141                	addi	sp,sp,-16
    8000418c:	e406                	sd	ra,8(sp)
    8000418e:	e022                	sd	s0,0(sp)
    80004190:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004192:	00003597          	auipc	a1,0x3
    80004196:	3e658593          	addi	a1,a1,998 # 80007578 <etext+0x578>
    8000419a:	0001e517          	auipc	a0,0x1e
    8000419e:	5e650513          	addi	a0,a0,1510 # 80022780 <ftable>
    800041a2:	a07fc0ef          	jal	80000ba8 <initlock>
}
    800041a6:	60a2                	ld	ra,8(sp)
    800041a8:	6402                	ld	s0,0(sp)
    800041aa:	0141                	addi	sp,sp,16
    800041ac:	8082                	ret

00000000800041ae <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    800041ae:	1101                	addi	sp,sp,-32
    800041b0:	ec06                	sd	ra,24(sp)
    800041b2:	e822                	sd	s0,16(sp)
    800041b4:	e426                	sd	s1,8(sp)
    800041b6:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800041b8:	0001e517          	auipc	a0,0x1e
    800041bc:	5c850513          	addi	a0,a0,1480 # 80022780 <ftable>
    800041c0:	a69fc0ef          	jal	80000c28 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    800041c4:	0001e497          	auipc	s1,0x1e
    800041c8:	5d448493          	addi	s1,s1,1492 # 80022798 <ftable+0x18>
    800041cc:	0001f717          	auipc	a4,0x1f
    800041d0:	56c70713          	addi	a4,a4,1388 # 80023738 <disk>
    if (f->ref == 0) {
    800041d4:	40dc                	lw	a5,4(s1)
    800041d6:	cf89                	beqz	a5,800041f0 <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    800041d8:	02848493          	addi	s1,s1,40
    800041dc:	fee49ce3          	bne	s1,a4,800041d4 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800041e0:	0001e517          	auipc	a0,0x1e
    800041e4:	5a050513          	addi	a0,a0,1440 # 80022780 <ftable>
    800041e8:	ac9fc0ef          	jal	80000cb0 <release>
  return 0;
    800041ec:	4481                	li	s1,0
    800041ee:	a809                	j	80004200 <filealloc+0x52>
      f->ref = 1;
    800041f0:	4785                	li	a5,1
    800041f2:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800041f4:	0001e517          	auipc	a0,0x1e
    800041f8:	58c50513          	addi	a0,a0,1420 # 80022780 <ftable>
    800041fc:	ab5fc0ef          	jal	80000cb0 <release>
}
    80004200:	8526                	mv	a0,s1
    80004202:	60e2                	ld	ra,24(sp)
    80004204:	6442                	ld	s0,16(sp)
    80004206:	64a2                	ld	s1,8(sp)
    80004208:	6105                	addi	sp,sp,32
    8000420a:	8082                	ret

000000008000420c <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    8000420c:	1101                	addi	sp,sp,-32
    8000420e:	ec06                	sd	ra,24(sp)
    80004210:	e822                	sd	s0,16(sp)
    80004212:	e426                	sd	s1,8(sp)
    80004214:	1000                	addi	s0,sp,32
    80004216:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004218:	0001e517          	auipc	a0,0x1e
    8000421c:	56850513          	addi	a0,a0,1384 # 80022780 <ftable>
    80004220:	a09fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    80004224:	40dc                	lw	a5,4(s1)
    80004226:	02f05063          	blez	a5,80004246 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000422a:	2785                	addiw	a5,a5,1
    8000422c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000422e:	0001e517          	auipc	a0,0x1e
    80004232:	55250513          	addi	a0,a0,1362 # 80022780 <ftable>
    80004236:	a7bfc0ef          	jal	80000cb0 <release>
  return f;
}
    8000423a:	8526                	mv	a0,s1
    8000423c:	60e2                	ld	ra,24(sp)
    8000423e:	6442                	ld	s0,16(sp)
    80004240:	64a2                	ld	s1,8(sp)
    80004242:	6105                	addi	sp,sp,32
    80004244:	8082                	ret
    panic("filedup");
    80004246:	00003517          	auipc	a0,0x3
    8000424a:	33a50513          	addi	a0,a0,826 # 80007580 <etext+0x580>
    8000424e:	de6fc0ef          	jal	80000834 <panic>

0000000080004252 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004252:	7139                	addi	sp,sp,-64
    80004254:	fc06                	sd	ra,56(sp)
    80004256:	f822                	sd	s0,48(sp)
    80004258:	f426                	sd	s1,40(sp)
    8000425a:	0080                	addi	s0,sp,64
    8000425c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000425e:	0001e517          	auipc	a0,0x1e
    80004262:	52250513          	addi	a0,a0,1314 # 80022780 <ftable>
    80004266:	9c3fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    8000426a:	40dc                	lw	a5,4(s1)
    8000426c:	04f05a63          	blez	a5,800042c0 <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    80004270:	37fd                	addiw	a5,a5,-1
    80004272:	c0dc                	sw	a5,4(s1)
    80004274:	06f04063          	bgtz	a5,800042d4 <fileclose+0x82>
    80004278:	f04a                	sd	s2,32(sp)
    8000427a:	ec4e                	sd	s3,24(sp)
    8000427c:	e852                	sd	s4,16(sp)
    8000427e:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004280:	0004a903          	lw	s2,0(s1)
    80004284:	0094c783          	lbu	a5,9(s1)
    80004288:	89be                	mv	s3,a5
    8000428a:	689c                	ld	a5,16(s1)
    8000428c:	8a3e                	mv	s4,a5
    8000428e:	6c9c                	ld	a5,24(s1)
    80004290:	8abe                	mv	s5,a5
  f->ref = 0;
    80004292:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004296:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000429a:	0001e517          	auipc	a0,0x1e
    8000429e:	4e650513          	addi	a0,a0,1254 # 80022780 <ftable>
    800042a2:	a0ffc0ef          	jal	80000cb0 <release>

  if (ff.type == FD_PIPE) {
    800042a6:	4785                	li	a5,1
    800042a8:	04f90163          	beq	s2,a5,800042ea <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    800042ac:	ffe9079b          	addiw	a5,s2,-2
    800042b0:	4705                	li	a4,1
    800042b2:	04f77563          	bgeu	a4,a5,800042fc <fileclose+0xaa>
    800042b6:	7902                	ld	s2,32(sp)
    800042b8:	69e2                	ld	s3,24(sp)
    800042ba:	6a42                	ld	s4,16(sp)
    800042bc:	6aa2                	ld	s5,8(sp)
    800042be:	a00d                	j	800042e0 <fileclose+0x8e>
    800042c0:	f04a                	sd	s2,32(sp)
    800042c2:	ec4e                	sd	s3,24(sp)
    800042c4:	e852                	sd	s4,16(sp)
    800042c6:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800042c8:	00003517          	auipc	a0,0x3
    800042cc:	2c050513          	addi	a0,a0,704 # 80007588 <etext+0x588>
    800042d0:	d64fc0ef          	jal	80000834 <panic>
    release(&ftable.lock);
    800042d4:	0001e517          	auipc	a0,0x1e
    800042d8:	4ac50513          	addi	a0,a0,1196 # 80022780 <ftable>
    800042dc:	9d5fc0ef          	jal	80000cb0 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800042e0:	70e2                	ld	ra,56(sp)
    800042e2:	7442                	ld	s0,48(sp)
    800042e4:	74a2                	ld	s1,40(sp)
    800042e6:	6121                	addi	sp,sp,64
    800042e8:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800042ea:	85ce                	mv	a1,s3
    800042ec:	8552                	mv	a0,s4
    800042ee:	36a000ef          	jal	80004658 <pipeclose>
    800042f2:	7902                	ld	s2,32(sp)
    800042f4:	69e2                	ld	s3,24(sp)
    800042f6:	6a42                	ld	s4,16(sp)
    800042f8:	6aa2                	ld	s5,8(sp)
    800042fa:	b7dd                	j	800042e0 <fileclose+0x8e>
    begin_op();
    800042fc:	a9dff0ef          	jal	80003d98 <begin_op>
    iput(ff.ip);
    80004300:	8556                	mv	a0,s5
    80004302:	9a0ff0ef          	jal	800034a2 <iput>
    end_op();
    80004306:	b1fff0ef          	jal	80003e24 <end_op>
    8000430a:	7902                	ld	s2,32(sp)
    8000430c:	69e2                	ld	s3,24(sp)
    8000430e:	6a42                	ld	s4,16(sp)
    80004310:	6aa2                	ld	s5,8(sp)
    80004312:	b7f9                	j	800042e0 <fileclose+0x8e>

0000000080004314 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004314:	715d                	addi	sp,sp,-80
    80004316:	e486                	sd	ra,72(sp)
    80004318:	e0a2                	sd	s0,64(sp)
    8000431a:	fc26                	sd	s1,56(sp)
    8000431c:	f052                	sd	s4,32(sp)
    8000431e:	0880                	addi	s0,sp,80
    80004320:	84aa                	mv	s1,a0
    80004322:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004324:	e24fd0ef          	jal	80001948 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    80004328:	409c                	lw	a5,0(s1)
    8000432a:	37f9                	addiw	a5,a5,-2
    8000432c:	4705                	li	a4,1
    8000432e:	04f76963          	bltu	a4,a5,80004380 <filestat+0x6c>
    80004332:	f84a                	sd	s2,48(sp)
    80004334:	f44e                	sd	s3,40(sp)
    80004336:	892a                	mv	s2,a0
    memset(&st, 0, sizeof(st));
    80004338:	fb840993          	addi	s3,s0,-72
    8000433c:	4661                	li	a2,24
    8000433e:	4581                	li	a1,0
    80004340:	854e                	mv	a0,s3
    80004342:	9a7fc0ef          	jal	80000ce8 <memset>
    ilock(f->ip);
    80004346:	6c88                	ld	a0,24(s1)
    80004348:	fd9fe0ef          	jal	80003320 <ilock>
    stati(f->ip, &st);
    8000434c:	85ce                	mv	a1,s3
    8000434e:	6c88                	ld	a0,24(s1)
    80004350:	b7cff0ef          	jal	800036cc <stati>
    iunlock(f->ip);
    80004354:	6c88                	ld	a0,24(s1)
    80004356:	878ff0ef          	jal	800033ce <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    8000435a:	4761                	li	a4,24
    8000435c:	86ce                	mv	a3,s3
    8000435e:	8652                	mv	a2,s4
    80004360:	04893583          	ld	a1,72(s2)
    80004364:	05093503          	ld	a0,80(s2)
    80004368:	a1afd0ef          	jal	80001582 <copyout>
    8000436c:	41f5551b          	sraiw	a0,a0,0x1f
    80004370:	7942                	ld	s2,48(sp)
    80004372:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004374:	60a6                	ld	ra,72(sp)
    80004376:	6406                	ld	s0,64(sp)
    80004378:	74e2                	ld	s1,56(sp)
    8000437a:	7a02                	ld	s4,32(sp)
    8000437c:	6161                	addi	sp,sp,80
    8000437e:	8082                	ret
  return -1;
    80004380:	557d                	li	a0,-1
    80004382:	bfcd                	j	80004374 <filestat+0x60>

0000000080004384 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004384:	7179                	addi	sp,sp,-48
    80004386:	f406                	sd	ra,40(sp)
    80004388:	f022                	sd	s0,32(sp)
    8000438a:	e84a                	sd	s2,16(sp)
    8000438c:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    8000438e:	00854783          	lbu	a5,8(a0)
    80004392:	c3dd                	beqz	a5,80004438 <fileread+0xb4>
    80004394:	ec26                	sd	s1,24(sp)
    80004396:	e44e                	sd	s3,8(sp)
    80004398:	84aa                	mv	s1,a0
    8000439a:	892e                	mv	s2,a1
    8000439c:	89b2                	mv	s3,a2
    8000439e:	01f6579b          	srliw	a5,a2,0x1f
    800043a2:	ebc9                	bnez	a5,80004434 <fileread+0xb0>
    return -1;

  if (f->type == FD_PIPE) {
    800043a4:	411c                	lw	a5,0(a0)
    800043a6:	4705                	li	a4,1
    800043a8:	04e78363          	beq	a5,a4,800043ee <fileread+0x6a>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800043ac:	470d                	li	a4,3
    800043ae:	04e78763          	beq	a5,a4,800043fc <fileread+0x78>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    800043b2:	4709                	li	a4,2
    800043b4:	06e79a63          	bne	a5,a4,80004428 <fileread+0xa4>
    ilock(f->ip);
    800043b8:	6d08                	ld	a0,24(a0)
    800043ba:	f67fe0ef          	jal	80003320 <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800043be:	874e                	mv	a4,s3
    800043c0:	5094                	lw	a3,32(s1)
    800043c2:	864a                	mv	a2,s2
    800043c4:	4585                	li	a1,1
    800043c6:	6c88                	ld	a0,24(s1)
    800043c8:	b32ff0ef          	jal	800036fa <readi>
    800043cc:	892a                	mv	s2,a0
    800043ce:	00a05563          	blez	a0,800043d8 <fileread+0x54>
      f->off += r;
    800043d2:	509c                	lw	a5,32(s1)
    800043d4:	9fa9                	addw	a5,a5,a0
    800043d6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800043d8:	6c88                	ld	a0,24(s1)
    800043da:	ff5fe0ef          	jal	800033ce <iunlock>
    800043de:	64e2                	ld	s1,24(sp)
    800043e0:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800043e2:	854a                	mv	a0,s2
    800043e4:	70a2                	ld	ra,40(sp)
    800043e6:	7402                	ld	s0,32(sp)
    800043e8:	6942                	ld	s2,16(sp)
    800043ea:	6145                	addi	sp,sp,48
    800043ec:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800043ee:	6908                	ld	a0,16(a0)
    800043f0:	3e2000ef          	jal	800047d2 <piperead>
    800043f4:	892a                	mv	s2,a0
    800043f6:	64e2                	ld	s1,24(sp)
    800043f8:	69a2                	ld	s3,8(sp)
    800043fa:	b7e5                	j	800043e2 <fileread+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800043fc:	02451783          	lh	a5,36(a0)
    80004400:	03079693          	slli	a3,a5,0x30
    80004404:	92c1                	srli	a3,a3,0x30
    80004406:	4725                	li	a4,9
    80004408:	02d76b63          	bltu	a4,a3,8000443e <fileread+0xba>
    8000440c:	0792                	slli	a5,a5,0x4
    8000440e:	0001e717          	auipc	a4,0x1e
    80004412:	2d270713          	addi	a4,a4,722 # 800226e0 <devsw>
    80004416:	97ba                	add	a5,a5,a4
    80004418:	639c                	ld	a5,0(a5)
    8000441a:	c79d                	beqz	a5,80004448 <fileread+0xc4>
    r = devsw[f->major].read(1, addr, n);
    8000441c:	4505                	li	a0,1
    8000441e:	9782                	jalr	a5
    80004420:	892a                	mv	s2,a0
    80004422:	64e2                	ld	s1,24(sp)
    80004424:	69a2                	ld	s3,8(sp)
    80004426:	bf75                	j	800043e2 <fileread+0x5e>
    panic("fileread");
    80004428:	00003517          	auipc	a0,0x3
    8000442c:	17050513          	addi	a0,a0,368 # 80007598 <etext+0x598>
    80004430:	c04fc0ef          	jal	80000834 <panic>
    80004434:	64e2                	ld	s1,24(sp)
    80004436:	69a2                	ld	s3,8(sp)
    return -1;
    80004438:	57fd                	li	a5,-1
    8000443a:	893e                	mv	s2,a5
    8000443c:	b75d                	j	800043e2 <fileread+0x5e>
      return -1;
    8000443e:	57fd                	li	a5,-1
    80004440:	893e                	mv	s2,a5
    80004442:	64e2                	ld	s1,24(sp)
    80004444:	69a2                	ld	s3,8(sp)
    80004446:	bf71                	j	800043e2 <fileread+0x5e>
    80004448:	57fd                	li	a5,-1
    8000444a:	893e                	mv	s2,a5
    8000444c:	64e2                	ld	s1,24(sp)
    8000444e:	69a2                	ld	s3,8(sp)
    80004450:	bf49                	j	800043e2 <fileread+0x5e>

0000000080004452 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    80004452:	00954783          	lbu	a5,9(a0)
    80004456:	12078b63          	beqz	a5,8000458c <filewrite+0x13a>
{
    8000445a:	711d                	addi	sp,sp,-96
    8000445c:	ec86                	sd	ra,88(sp)
    8000445e:	e8a2                	sd	s0,80(sp)
    80004460:	e0ca                	sd	s2,64(sp)
    80004462:	f456                	sd	s5,40(sp)
    80004464:	f05a                	sd	s6,32(sp)
    80004466:	1080                	addi	s0,sp,96
    80004468:	892a                	mv	s2,a0
    8000446a:	8b2e                	mv	s6,a1
    8000446c:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    8000446e:	01f6579b          	srliw	a5,a2,0x1f
    80004472:	0e079d63          	bnez	a5,8000456c <filewrite+0x11a>
    return -1;

  if (f->type == FD_PIPE) {
    80004476:	411c                	lw	a5,0(a0)
    80004478:	4705                	li	a4,1
    8000447a:	02e78a63          	beq	a5,a4,800044ae <filewrite+0x5c>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    8000447e:	470d                	li	a4,3
    80004480:	02e78b63          	beq	a5,a4,800044b6 <filewrite+0x64>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004484:	4709                	li	a4,2
    80004486:	0ce79763          	bne	a5,a4,80004554 <filewrite+0x102>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    8000448a:	0ec05763          	blez	a2,80004578 <filewrite+0x126>
    8000448e:	e4a6                	sd	s1,72(sp)
    80004490:	fc4e                	sd	s3,56(sp)
    80004492:	f852                	sd	s4,48(sp)
    80004494:	ec5e                	sd	s7,24(sp)
    80004496:	e862                	sd	s8,16(sp)
    80004498:	e466                	sd	s9,8(sp)
    int i = 0;
    8000449a:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    8000449c:	6b85                	lui	s7,0x1
    8000449e:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800044a2:	6785                	lui	a5,0x1
    800044a4:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800044a8:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800044aa:	4c05                	li	s8,1
    800044ac:	a8ad                	j	80004526 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    800044ae:	6908                	ld	a0,16(a0)
    800044b0:	206000ef          	jal	800046b6 <pipewrite>
    800044b4:	a849                	j	80004546 <filewrite+0xf4>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800044b6:	02451783          	lh	a5,36(a0)
    800044ba:	03079693          	slli	a3,a5,0x30
    800044be:	92c1                	srli	a3,a3,0x30
    800044c0:	4725                	li	a4,9
    800044c2:	0ad76763          	bltu	a4,a3,80004570 <filewrite+0x11e>
    800044c6:	0792                	slli	a5,a5,0x4
    800044c8:	0001e717          	auipc	a4,0x1e
    800044cc:	21870713          	addi	a4,a4,536 # 800226e0 <devsw>
    800044d0:	97ba                	add	a5,a5,a4
    800044d2:	679c                	ld	a5,8(a5)
    800044d4:	c3c5                	beqz	a5,80004574 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800044d6:	4505                	li	a0,1
    800044d8:	9782                	jalr	a5
    800044da:	a0b5                	j	80004546 <filewrite+0xf4>
      if (n1 > max)
    800044dc:	2981                	sext.w	s3,s3
      begin_op();
    800044de:	8bbff0ef          	jal	80003d98 <begin_op>
      ilock(f->ip);
    800044e2:	01893503          	ld	a0,24(s2)
    800044e6:	e3bfe0ef          	jal	80003320 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800044ea:	874e                	mv	a4,s3
    800044ec:	02092683          	lw	a3,32(s2)
    800044f0:	016a0633          	add	a2,s4,s6
    800044f4:	85e2                	mv	a1,s8
    800044f6:	01893503          	ld	a0,24(s2)
    800044fa:	af2ff0ef          	jal	800037ec <writei>
    800044fe:	84aa                	mv	s1,a0
    80004500:	00a05763          	blez	a0,8000450e <filewrite+0xbc>
        f->off += r;
    80004504:	02092783          	lw	a5,32(s2)
    80004508:	9fa9                	addw	a5,a5,a0
    8000450a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000450e:	01893503          	ld	a0,24(s2)
    80004512:	ebdfe0ef          	jal	800033ce <iunlock>
      end_op();
    80004516:	90fff0ef          	jal	80003e24 <end_op>

      if (r != n1) {
    8000451a:	00999d63          	bne	s3,s1,80004534 <filewrite+0xe2>
        // error from writei
        break;
      }
      i += r;
    8000451e:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    80004522:	015a5963          	bge	s4,s5,80004534 <filewrite+0xe2>
      int n1 = n - i;
    80004526:	414a87bb          	subw	a5,s5,s4
    8000452a:	89be                	mv	s3,a5
      if (n1 > max)
    8000452c:	fafbd8e3          	bge	s7,a5,800044dc <filewrite+0x8a>
    80004530:	89e6                	mv	s3,s9
    80004532:	b76d                	j	800044dc <filewrite+0x8a>
    }
    ret = (i == n ? n : -1);
    80004534:	054a9463          	bne	s5,s4,8000457c <filewrite+0x12a>
    80004538:	8556                	mv	a0,s5
    8000453a:	64a6                	ld	s1,72(sp)
    8000453c:	79e2                	ld	s3,56(sp)
    8000453e:	7a42                	ld	s4,48(sp)
    80004540:	6be2                	ld	s7,24(sp)
    80004542:	6c42                	ld	s8,16(sp)
    80004544:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004546:	60e6                	ld	ra,88(sp)
    80004548:	6446                	ld	s0,80(sp)
    8000454a:	6906                	ld	s2,64(sp)
    8000454c:	7aa2                	ld	s5,40(sp)
    8000454e:	7b02                	ld	s6,32(sp)
    80004550:	6125                	addi	sp,sp,96
    80004552:	8082                	ret
    80004554:	e4a6                	sd	s1,72(sp)
    80004556:	fc4e                	sd	s3,56(sp)
    80004558:	f852                	sd	s4,48(sp)
    8000455a:	ec5e                	sd	s7,24(sp)
    8000455c:	e862                	sd	s8,16(sp)
    8000455e:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004560:	00003517          	auipc	a0,0x3
    80004564:	04850513          	addi	a0,a0,72 # 800075a8 <etext+0x5a8>
    80004568:	accfc0ef          	jal	80000834 <panic>
    return -1;
    8000456c:	557d                	li	a0,-1
    8000456e:	bfe1                	j	80004546 <filewrite+0xf4>
      return -1;
    80004570:	557d                	li	a0,-1
    80004572:	bfd1                	j	80004546 <filewrite+0xf4>
    80004574:	557d                	li	a0,-1
    80004576:	bfc1                	j	80004546 <filewrite+0xf4>
    ret = (i == n ? n : -1);
    80004578:	8532                	mv	a0,a2
    8000457a:	b7f1                	j	80004546 <filewrite+0xf4>
    8000457c:	557d                	li	a0,-1
    8000457e:	64a6                	ld	s1,72(sp)
    80004580:	79e2                	ld	s3,56(sp)
    80004582:	7a42                	ld	s4,48(sp)
    80004584:	6be2                	ld	s7,24(sp)
    80004586:	6c42                	ld	s8,16(sp)
    80004588:	6ca2                	ld	s9,8(sp)
    8000458a:	bf75                	j	80004546 <filewrite+0xf4>
    return -1;
    8000458c:	557d                	li	a0,-1
}
    8000458e:	8082                	ret

0000000080004590 <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004590:	7179                	addi	sp,sp,-48
    80004592:	f406                	sd	ra,40(sp)
    80004594:	f022                	sd	s0,32(sp)
    80004596:	ec26                	sd	s1,24(sp)
    80004598:	e052                	sd	s4,0(sp)
    8000459a:	1800                	addi	s0,sp,48
    8000459c:	84aa                	mv	s1,a0
    8000459e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800045a0:	0005b023          	sd	zero,0(a1)
    800045a4:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800045a8:	c07ff0ef          	jal	800041ae <filealloc>
    800045ac:	e088                	sd	a0,0(s1)
    800045ae:	c549                	beqz	a0,80004638 <pipealloc+0xa8>
    800045b0:	bffff0ef          	jal	800041ae <filealloc>
    800045b4:	00aa3023          	sd	a0,0(s4)
    800045b8:	cd25                	beqz	a0,80004630 <pipealloc+0xa0>
    800045ba:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    800045bc:	d92fc0ef          	jal	80000b4e <kalloc>
    800045c0:	892a                	mv	s2,a0
    800045c2:	c12d                	beqz	a0,80004624 <pipealloc+0x94>
    800045c4:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800045c6:	4985                	li	s3,1
    800045c8:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800045cc:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800045d0:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800045d4:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800045d8:	00003597          	auipc	a1,0x3
    800045dc:	fe058593          	addi	a1,a1,-32 # 800075b8 <etext+0x5b8>
    800045e0:	dc8fc0ef          	jal	80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    800045e4:	609c                	ld	a5,0(s1)
    800045e6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800045ea:	609c                	ld	a5,0(s1)
    800045ec:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800045f0:	609c                	ld	a5,0(s1)
    800045f2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800045f6:	609c                	ld	a5,0(s1)
    800045f8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800045fc:	000a3783          	ld	a5,0(s4)
    80004600:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004604:	000a3783          	ld	a5,0(s4)
    80004608:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000460c:	000a3783          	ld	a5,0(s4)
    80004610:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004614:	000a3783          	ld	a5,0(s4)
    80004618:	0127b823          	sd	s2,16(a5)
  return 0;
    8000461c:	4501                	li	a0,0
    8000461e:	6942                	ld	s2,16(sp)
    80004620:	69a2                	ld	s3,8(sp)
    80004622:	a01d                	j	80004648 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80004624:	6088                	ld	a0,0(s1)
    80004626:	c119                	beqz	a0,8000462c <pipealloc+0x9c>
    80004628:	6942                	ld	s2,16(sp)
    8000462a:	a029                	j	80004634 <pipealloc+0xa4>
    8000462c:	6942                	ld	s2,16(sp)
    8000462e:	a029                	j	80004638 <pipealloc+0xa8>
    80004630:	6088                	ld	a0,0(s1)
    80004632:	c10d                	beqz	a0,80004654 <pipealloc+0xc4>
    fileclose(*f0);
    80004634:	c1fff0ef          	jal	80004252 <fileclose>
  if (*f1)
    80004638:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000463c:	557d                	li	a0,-1
  if (*f1)
    8000463e:	c789                	beqz	a5,80004648 <pipealloc+0xb8>
    fileclose(*f1);
    80004640:	853e                	mv	a0,a5
    80004642:	c11ff0ef          	jal	80004252 <fileclose>
  return -1;
    80004646:	557d                	li	a0,-1
}
    80004648:	70a2                	ld	ra,40(sp)
    8000464a:	7402                	ld	s0,32(sp)
    8000464c:	64e2                	ld	s1,24(sp)
    8000464e:	6a02                	ld	s4,0(sp)
    80004650:	6145                	addi	sp,sp,48
    80004652:	8082                	ret
  return -1;
    80004654:	557d                	li	a0,-1
    80004656:	bfcd                	j	80004648 <pipealloc+0xb8>

0000000080004658 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004658:	1101                	addi	sp,sp,-32
    8000465a:	ec06                	sd	ra,24(sp)
    8000465c:	e822                	sd	s0,16(sp)
    8000465e:	e426                	sd	s1,8(sp)
    80004660:	e04a                	sd	s2,0(sp)
    80004662:	1000                	addi	s0,sp,32
    80004664:	84aa                	mv	s1,a0
    80004666:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004668:	dc0fc0ef          	jal	80000c28 <acquire>
  if (writable) {
    8000466c:	02090763          	beqz	s2,8000469a <pipeclose+0x42>
    pi->writeopen = 0;
    80004670:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004674:	21848513          	addi	a0,s1,536
    80004678:	9fbfd0ef          	jal	80002072 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    8000467c:	2204a783          	lw	a5,544(s1)
    80004680:	e781                	bnez	a5,80004688 <pipeclose+0x30>
    80004682:	2244a783          	lw	a5,548(s1)
    80004686:	c38d                	beqz	a5,800046a8 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    80004688:	8526                	mv	a0,s1
    8000468a:	e26fc0ef          	jal	80000cb0 <release>
}
    8000468e:	60e2                	ld	ra,24(sp)
    80004690:	6442                	ld	s0,16(sp)
    80004692:	64a2                	ld	s1,8(sp)
    80004694:	6902                	ld	s2,0(sp)
    80004696:	6105                	addi	sp,sp,32
    80004698:	8082                	ret
    pi->readopen = 0;
    8000469a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000469e:	21c48513          	addi	a0,s1,540
    800046a2:	9d1fd0ef          	jal	80002072 <wakeup>
    800046a6:	bfd9                	j	8000467c <pipeclose+0x24>
    release(&pi->lock);
    800046a8:	8526                	mv	a0,s1
    800046aa:	e06fc0ef          	jal	80000cb0 <release>
    kfree((char *)pi);
    800046ae:	8526                	mv	a0,s1
    800046b0:	bb6fc0ef          	jal	80000a66 <kfree>
    800046b4:	bfe9                	j	8000468e <pipeclose+0x36>

00000000800046b6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800046b6:	7159                	addi	sp,sp,-112
    800046b8:	f486                	sd	ra,104(sp)
    800046ba:	f0a2                	sd	s0,96(sp)
    800046bc:	eca6                	sd	s1,88(sp)
    800046be:	e8ca                	sd	s2,80(sp)
    800046c0:	e4ce                	sd	s3,72(sp)
    800046c2:	e0d2                	sd	s4,64(sp)
    800046c4:	fc56                	sd	s5,56(sp)
    800046c6:	1880                	addi	s0,sp,112
    800046c8:	84aa                	mv	s1,a0
    800046ca:	8aae                	mv	s5,a1
    800046cc:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800046ce:	a7afd0ef          	jal	80001948 <myproc>
    800046d2:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800046d4:	8526                	mv	a0,s1
    800046d6:	d52fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    800046da:	0f405a63          	blez	s4,800047ce <pipewrite+0x118>
    800046de:	f85a                	sd	s6,48(sp)
    800046e0:	f45e                	sd	s7,40(sp)
    800046e2:	f062                	sd	s8,32(sp)
    800046e4:	ec66                	sd	s9,24(sp)
    800046e6:	e86a                	sd	s10,16(sp)
  int i = 0;
    800046e8:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    800046ea:	f9f40c13          	addi	s8,s0,-97
    800046ee:	4b85                	li	s7,1
    800046f0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800046f2:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    800046f6:	21c48c93          	addi	s9,s1,540
    800046fa:	a0a1                	j	80004742 <pipewrite+0x8c>
      release(&pi->lock);
    800046fc:	8526                	mv	a0,s1
    800046fe:	db2fc0ef          	jal	80000cb0 <release>
      return -1;
    80004702:	597d                	li	s2,-1
    80004704:	7b42                	ld	s6,48(sp)
    80004706:	7ba2                	ld	s7,40(sp)
    80004708:	7c02                	ld	s8,32(sp)
    8000470a:	6ce2                	ld	s9,24(sp)
    8000470c:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000470e:	854a                	mv	a0,s2
    80004710:	70a6                	ld	ra,104(sp)
    80004712:	7406                	ld	s0,96(sp)
    80004714:	64e6                	ld	s1,88(sp)
    80004716:	6946                	ld	s2,80(sp)
    80004718:	69a6                	ld	s3,72(sp)
    8000471a:	6a06                	ld	s4,64(sp)
    8000471c:	7ae2                	ld	s5,56(sp)
    8000471e:	6165                	addi	sp,sp,112
    80004720:	8082                	ret
      wakeup(&pi->nread);
    80004722:	856a                	mv	a0,s10
    80004724:	94ffd0ef          	jal	80002072 <wakeup>
      sleep_prepare(&pi->nwrite);
    80004728:	8566                	mv	a0,s9
    8000472a:	8ddfd0ef          	jal	80002006 <sleep_prepare>
      release(&pi->lock);
    8000472e:	8526                	mv	a0,s1
    80004730:	d80fc0ef          	jal	80000cb0 <release>
      sleep();
    80004734:	90ffd0ef          	jal	80002042 <sleep>
      acquire(&pi->lock);
    80004738:	8526                	mv	a0,s1
    8000473a:	ceefc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    8000473e:	07495b63          	bge	s2,s4,800047b4 <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    80004742:	2204a783          	lw	a5,544(s1)
    80004746:	dbdd                	beqz	a5,800046fc <pipewrite+0x46>
    80004748:	854e                	mv	a0,s3
    8000474a:	b1bfd0ef          	jal	80002264 <killed>
    8000474e:	f55d                	bnez	a0,800046fc <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    80004750:	2184a783          	lw	a5,536(s1)
    80004754:	21c4a703          	lw	a4,540(s1)
    80004758:	2007879b          	addiw	a5,a5,512
    8000475c:	fcf703e3          	beq	a4,a5,80004722 <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004760:	875e                	mv	a4,s7
    80004762:	015906b3          	add	a3,s2,s5
    80004766:	8662                	mv	a2,s8
    80004768:	0489b583          	ld	a1,72(s3)
    8000476c:	0509b503          	ld	a0,80(s3)
    80004770:	ed9fc0ef          	jal	80001648 <copyin>
    80004774:	03650163          	beq	a0,s6,80004796 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004778:	21c4a783          	lw	a5,540(s1)
    8000477c:	0017871b          	addiw	a4,a5,1
    80004780:	20e4ae23          	sw	a4,540(s1)
    80004784:	1ff7f793          	andi	a5,a5,511
    80004788:	97a6                	add	a5,a5,s1
    8000478a:	f9f44703          	lbu	a4,-97(s0)
    8000478e:	00e78c23          	sb	a4,24(a5)
      i++;
    80004792:	2905                	addiw	s2,s2,1
    80004794:	b76d                	j	8000473e <pipewrite+0x88>
        if (i == 0)
    80004796:	00090863          	beqz	s2,800047a6 <pipewrite+0xf0>
    8000479a:	7b42                	ld	s6,48(sp)
    8000479c:	7ba2                	ld	s7,40(sp)
    8000479e:	7c02                	ld	s8,32(sp)
    800047a0:	6ce2                	ld	s9,24(sp)
    800047a2:	6d42                	ld	s10,16(sp)
    800047a4:	a829                	j	800047be <pipewrite+0x108>
          i = -1;
    800047a6:	892a                	mv	s2,a0
        break;
    800047a8:	7b42                	ld	s6,48(sp)
    800047aa:	7ba2                	ld	s7,40(sp)
    800047ac:	7c02                	ld	s8,32(sp)
    800047ae:	6ce2                	ld	s9,24(sp)
    800047b0:	6d42                	ld	s10,16(sp)
    800047b2:	a031                	j	800047be <pipewrite+0x108>
    800047b4:	7b42                	ld	s6,48(sp)
    800047b6:	7ba2                	ld	s7,40(sp)
    800047b8:	7c02                	ld	s8,32(sp)
    800047ba:	6ce2                	ld	s9,24(sp)
    800047bc:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    800047be:	21848513          	addi	a0,s1,536
    800047c2:	8b1fd0ef          	jal	80002072 <wakeup>
  release(&pi->lock);
    800047c6:	8526                	mv	a0,s1
    800047c8:	ce8fc0ef          	jal	80000cb0 <release>
  return i;
    800047cc:	b789                	j	8000470e <pipewrite+0x58>
  int i = 0;
    800047ce:	4901                	li	s2,0
    800047d0:	b7fd                	j	800047be <pipewrite+0x108>

00000000800047d2 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800047d2:	711d                	addi	sp,sp,-96
    800047d4:	ec86                	sd	ra,88(sp)
    800047d6:	e8a2                	sd	s0,80(sp)
    800047d8:	e4a6                	sd	s1,72(sp)
    800047da:	e0ca                	sd	s2,64(sp)
    800047dc:	fc4e                	sd	s3,56(sp)
    800047de:	f852                	sd	s4,48(sp)
    800047e0:	f456                	sd	s5,40(sp)
    800047e2:	1080                	addi	s0,sp,96
    800047e4:	84aa                	mv	s1,a0
    800047e6:	89ae                	mv	s3,a1
    800047e8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800047ea:	95efd0ef          	jal	80001948 <myproc>
    800047ee:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    800047f0:	8526                	mv	a0,s1
    800047f2:	c36fc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800047f6:	0d505263          	blez	s5,800048ba <piperead+0xe8>
    800047fa:	2184a703          	lw	a4,536(s1)
    800047fe:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004802:	21848a13          	addi	s4,s1,536
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004806:	02f71e63          	bne	a4,a5,80004842 <piperead+0x70>
    8000480a:	2244a783          	lw	a5,548(s1)
    8000480e:	c3b9                	beqz	a5,80004854 <piperead+0x82>
    if (killed(pr)) {
    80004810:	854a                	mv	a0,s2
    80004812:	a53fd0ef          	jal	80002264 <killed>
    80004816:	e915                	bnez	a0,8000484a <piperead+0x78>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004818:	8552                	mv	a0,s4
    8000481a:	fecfd0ef          	jal	80002006 <sleep_prepare>
    release(&pi->lock);
    8000481e:	8526                	mv	a0,s1
    80004820:	c90fc0ef          	jal	80000cb0 <release>
    sleep();
    80004824:	81ffd0ef          	jal	80002042 <sleep>
    acquire(&pi->lock);
    80004828:	8526                	mv	a0,s1
    8000482a:	bfefc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    8000482e:	2184a703          	lw	a4,536(s1)
    80004832:	21c4a783          	lw	a5,540(s1)
    80004836:	fcf70ae3          	beq	a4,a5,8000480a <piperead+0x38>
    8000483a:	f05a                	sd	s6,32(sp)
    8000483c:	ec5e                	sd	s7,24(sp)
    8000483e:	e862                	sd	s8,16(sp)
    80004840:	a829                	j	8000485a <piperead+0x88>
    80004842:	f05a                	sd	s6,32(sp)
    80004844:	ec5e                	sd	s7,24(sp)
    80004846:	e862                	sd	s8,16(sp)
    80004848:	a809                	j	8000485a <piperead+0x88>
      release(&pi->lock);
    8000484a:	8526                	mv	a0,s1
    8000484c:	c64fc0ef          	jal	80000cb0 <release>
      return -1;
    80004850:	5a7d                	li	s4,-1
    80004852:	a8a5                	j	800048ca <piperead+0xf8>
    80004854:	f05a                	sd	s6,32(sp)
    80004856:	ec5e                	sd	s7,24(sp)
    80004858:	e862                	sd	s8,16(sp)
{
    8000485a:	4a01                	li	s4,0
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    8000485c:	faf40c13          	addi	s8,s0,-81
    80004860:	4b85                	li	s7,1
    80004862:	5b7d                	li	s6,-1
    if (pi->nread == pi->nwrite)
    80004864:	2184a783          	lw	a5,536(s1)
    80004868:	21c4a703          	lw	a4,540(s1)
    8000486c:	06f70e63          	beq	a4,a5,800048e8 <piperead+0x116>
    ch = pi->data[pi->nread % PIPESIZE];
    80004870:	1ff7f793          	andi	a5,a5,511
    80004874:	97a6                	add	a5,a5,s1
    80004876:	0187c783          	lbu	a5,24(a5)
    8000487a:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    8000487e:	875e                	mv	a4,s7
    80004880:	86e2                	mv	a3,s8
    80004882:	864e                	mv	a2,s3
    80004884:	04893583          	ld	a1,72(s2)
    80004888:	05093503          	ld	a0,80(s2)
    8000488c:	cf7fc0ef          	jal	80001582 <copyout>
    80004890:	01650f63          	beq	a0,s6,800048ae <piperead+0xdc>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004894:	2184a783          	lw	a5,536(s1)
    80004898:	2785                	addiw	a5,a5,1
    8000489a:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    8000489e:	2a05                	addiw	s4,s4,1
    800048a0:	0985                	addi	s3,s3,1
    800048a2:	fd4a91e3          	bne	s5,s4,80004864 <piperead+0x92>
    800048a6:	7b02                	ld	s6,32(sp)
    800048a8:	6be2                	ld	s7,24(sp)
    800048aa:	6c42                	ld	s8,16(sp)
    800048ac:	a801                	j	800048bc <piperead+0xea>
      if (i == 0)
    800048ae:	020a0863          	beqz	s4,800048de <piperead+0x10c>
    800048b2:	7b02                	ld	s6,32(sp)
    800048b4:	6be2                	ld	s7,24(sp)
    800048b6:	6c42                	ld	s8,16(sp)
    800048b8:	a011                	j	800048bc <piperead+0xea>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800048ba:	4a01                	li	s4,0
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    800048bc:	21c48513          	addi	a0,s1,540
    800048c0:	fb2fd0ef          	jal	80002072 <wakeup>
  release(&pi->lock);
    800048c4:	8526                	mv	a0,s1
    800048c6:	beafc0ef          	jal	80000cb0 <release>
  return i;
}
    800048ca:	8552                	mv	a0,s4
    800048cc:	60e6                	ld	ra,88(sp)
    800048ce:	6446                	ld	s0,80(sp)
    800048d0:	64a6                	ld	s1,72(sp)
    800048d2:	6906                	ld	s2,64(sp)
    800048d4:	79e2                	ld	s3,56(sp)
    800048d6:	7a42                	ld	s4,48(sp)
    800048d8:	7aa2                	ld	s5,40(sp)
    800048da:	6125                	addi	sp,sp,96
    800048dc:	8082                	ret
        i = -1;
    800048de:	8a2a                	mv	s4,a0
    800048e0:	7b02                	ld	s6,32(sp)
    800048e2:	6be2                	ld	s7,24(sp)
    800048e4:	6c42                	ld	s8,16(sp)
    800048e6:	bfd9                	j	800048bc <piperead+0xea>
    800048e8:	7b02                	ld	s6,32(sp)
    800048ea:	6be2                	ld	s7,24(sp)
    800048ec:	6c42                	ld	s8,16(sp)
    800048ee:	b7f9                	j	800048bc <piperead+0xea>

00000000800048f0 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    800048f0:	1141                	addi	sp,sp,-16
    800048f2:	e406                	sd	ra,8(sp)
    800048f4:	e022                	sd	s0,0(sp)
    800048f6:	0800                	addi	s0,sp,16
    800048f8:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    800048fa:	0035151b          	slliw	a0,a0,0x3
    800048fe:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    80004900:	8b89                	andi	a5,a5,2
    80004902:	c399                	beqz	a5,80004908 <flags2perm+0x18>
    perm |= PTE_W;
    80004904:	00456513          	ori	a0,a0,4
  return perm;
}
    80004908:	60a2                	ld	ra,8(sp)
    8000490a:	6402                	ld	s0,0(sp)
    8000490c:	0141                	addi	sp,sp,16
    8000490e:	8082                	ret

0000000080004910 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004910:	de010113          	addi	sp,sp,-544
    80004914:	20113c23          	sd	ra,536(sp)
    80004918:	20813823          	sd	s0,528(sp)
    8000491c:	20913423          	sd	s1,520(sp)
    80004920:	21213023          	sd	s2,512(sp)
    80004924:	1400                	addi	s0,sp,544
    80004926:	892a                	mv	s2,a0
    80004928:	dea43823          	sd	a0,-528(s0)
    8000492c:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004930:	818fd0ef          	jal	80001948 <myproc>
    80004934:	84aa                	mv	s1,a0

  begin_op();
    80004936:	c62ff0ef          	jal	80003d98 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    8000493a:	854a                	mv	a0,s2
    8000493c:	a7eff0ef          	jal	80003bba <namei>
    80004940:	cd21                	beqz	a0,80004998 <kexec+0x88>
    80004942:	fbd2                	sd	s4,496(sp)
    80004944:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004946:	9dbfe0ef          	jal	80003320 <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000494a:	04000713          	li	a4,64
    8000494e:	4681                	li	a3,0
    80004950:	e5040613          	addi	a2,s0,-432
    80004954:	4581                	li	a1,0
    80004956:	8552                	mv	a0,s4
    80004958:	da3fe0ef          	jal	800036fa <readi>
    8000495c:	04000793          	li	a5,64
    80004960:	00f51a63          	bne	a0,a5,80004974 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004964:	e5042703          	lw	a4,-432(s0)
    80004968:	464c47b7          	lui	a5,0x464c4
    8000496c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004970:	02f70863          	beq	a4,a5,800049a0 <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    80004974:	8552                	mv	a0,s4
    80004976:	bfffe0ef          	jal	80003574 <iunlockput>
    end_op();
    8000497a:	caaff0ef          	jal	80003e24 <end_op>
  }
  return -1;
    8000497e:	557d                	li	a0,-1
    80004980:	7a5e                	ld	s4,496(sp)
}
    80004982:	21813083          	ld	ra,536(sp)
    80004986:	21013403          	ld	s0,528(sp)
    8000498a:	20813483          	ld	s1,520(sp)
    8000498e:	20013903          	ld	s2,512(sp)
    80004992:	22010113          	addi	sp,sp,544
    80004996:	8082                	ret
    end_op();
    80004998:	c8cff0ef          	jal	80003e24 <end_op>
    return -1;
    8000499c:	557d                	li	a0,-1
    8000499e:	b7d5                	j	80004982 <kexec+0x72>
    800049a0:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    800049a2:	8526                	mv	a0,s1
    800049a4:	8aafd0ef          	jal	80001a4e <proc_pagetable>
    800049a8:	8b2a                	mv	s6,a0
    800049aa:	26050e63          	beqz	a0,80004c26 <kexec+0x316>
    800049ae:	ffce                	sd	s3,504(sp)
    800049b0:	f7d6                	sd	s5,488(sp)
    800049b2:	efde                	sd	s7,472(sp)
    800049b4:	ebe2                	sd	s8,464(sp)
    800049b6:	e7e6                	sd	s9,456(sp)
    800049b8:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    800049ba:	e8845783          	lhu	a5,-376(s0)
    800049be:	14078263          	beqz	a5,80004b02 <kexec+0x1f2>
    800049c2:	ff6e                	sd	s11,440(sp)
    800049c4:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800049c8:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    800049ca:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800049cc:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    800049d0:	6c85                	lui	s9,0x1
    800049d2:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800049d6:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    800049da:	6a85                	lui	s5,0x1
    800049dc:	a085                	j	80004a3c <kexec+0x12c>
      panic("loadseg: address should exist");
    800049de:	00003517          	auipc	a0,0x3
    800049e2:	be250513          	addi	a0,a0,-1054 # 800075c0 <etext+0x5c0>
    800049e6:	e4ffb0ef          	jal	80000834 <panic>
    if (sz - i < PGSIZE)
    800049ea:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    800049ec:	874a                	mv	a4,s2
    800049ee:	009b86bb          	addw	a3,s7,s1
    800049f2:	4581                	li	a1,0
    800049f4:	8552                	mv	a0,s4
    800049f6:	d05fe0ef          	jal	800036fa <readi>
    800049fa:	22a91a63          	bne	s2,a0,80004c2e <kexec+0x31e>
  for (i = 0; i < sz; i += PGSIZE) {
    800049fe:	009a84bb          	addw	s1,s5,s1
    80004a02:	0334f263          	bgeu	s1,s3,80004a26 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004a06:	02049593          	slli	a1,s1,0x20
    80004a0a:	9181                	srli	a1,a1,0x20
    80004a0c:	95e2                	add	a1,a1,s8
    80004a0e:	855a                	mv	a0,s6
    80004a10:	e08fc0ef          	jal	80001018 <walkaddr>
    80004a14:	862a                	mv	a2,a0
    if (pa == 0)
    80004a16:	d561                	beqz	a0,800049de <kexec+0xce>
    if (sz - i < PGSIZE)
    80004a18:	409987bb          	subw	a5,s3,s1
    80004a1c:	893e                	mv	s2,a5
    80004a1e:	fcfcf6e3          	bgeu	s9,a5,800049ea <kexec+0xda>
    80004a22:	8956                	mv	s2,s5
    80004a24:	b7d9                	j	800049ea <kexec+0xda>
    sz = sz1;
    80004a26:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004a2a:	2d05                	addiw	s10,s10,1
    80004a2c:	e0843783          	ld	a5,-504(s0)
    80004a30:	0387869b          	addiw	a3,a5,56
    80004a34:	e8845783          	lhu	a5,-376(s0)
    80004a38:	06fd5d63          	bge	s10,a5,80004ab2 <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a3c:	e0d43423          	sd	a3,-504(s0)
    80004a40:	876e                	mv	a4,s11
    80004a42:	e1840613          	addi	a2,s0,-488
    80004a46:	4581                	li	a1,0
    80004a48:	8552                	mv	a0,s4
    80004a4a:	cb1fe0ef          	jal	800036fa <readi>
    80004a4e:	1db51e63          	bne	a0,s11,80004c2a <kexec+0x31a>
    if (ph.type != ELF_PROG_LOAD)
    80004a52:	e1842783          	lw	a5,-488(s0)
    80004a56:	4705                	li	a4,1
    80004a58:	fce799e3          	bne	a5,a4,80004a2a <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    80004a5c:	e4043483          	ld	s1,-448(s0)
    80004a60:	e3843783          	ld	a5,-456(s0)
    80004a64:	1ef4e363          	bltu	s1,a5,80004c4a <kexec+0x33a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004a68:	e2843783          	ld	a5,-472(s0)
    80004a6c:	94be                	add	s1,s1,a5
    80004a6e:	1ef4e163          	bltu	s1,a5,80004c50 <kexec+0x340>
    if (ph.vaddr % PGSIZE != 0)
    80004a72:	de843703          	ld	a4,-536(s0)
    80004a76:	8ff9                	and	a5,a5,a4
    80004a78:	1c079f63          	bnez	a5,80004c56 <kexec+0x346>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004a7c:	e1c42503          	lw	a0,-484(s0)
    80004a80:	e71ff0ef          	jal	800048f0 <flags2perm>
    80004a84:	86aa                	mv	a3,a0
    80004a86:	8626                	mv	a2,s1
    80004a88:	85ca                	mv	a1,s2
    80004a8a:	855a                	mv	a0,s6
    80004a8c:	863fc0ef          	jal	800012ee <uvmalloc>
    80004a90:	dea43c23          	sd	a0,-520(s0)
    80004a94:	1c050463          	beqz	a0,80004c5c <kexec+0x34c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004a98:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004a9c:	00098863          	beqz	s3,80004aac <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004aa0:	e2843c03          	ld	s8,-472(s0)
    80004aa4:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004aa8:	4481                	li	s1,0
    80004aaa:	bfb1                	j	80004a06 <kexec+0xf6>
    sz = sz1;
    80004aac:	df843903          	ld	s2,-520(s0)
    80004ab0:	bfad                	j	80004a2a <kexec+0x11a>
    80004ab2:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    80004ab4:	8552                	mv	a0,s4
    80004ab6:	abffe0ef          	jal	80003574 <iunlockput>
  end_op();
    80004aba:	b6aff0ef          	jal	80003e24 <end_op>
  p = myproc();
    80004abe:	e8bfc0ef          	jal	80001948 <myproc>
    80004ac2:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004ac4:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    80004ac8:	6c05                	lui	s8,0x1
    80004aca:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    80004acc:	9c4a                	add	s8,s8,s2
    80004ace:	77fd                	lui	a5,0xfffff
    80004ad0:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004ad4:	4691                	li	a3,4
    80004ad6:	6609                	lui	a2,0x2
    80004ad8:	9662                	add	a2,a2,s8
    80004ada:	85e2                	mv	a1,s8
    80004adc:	855a                	mv	a0,s6
    80004ade:	811fc0ef          	jal	800012ee <uvmalloc>
    80004ae2:	892a                	mv	s2,a0
    80004ae4:	e10d                	bnez	a0,80004b06 <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    80004ae6:	85e2                	mv	a1,s8
    80004ae8:	855a                	mv	a0,s6
    80004aea:	fe9fc0ef          	jal	80001ad2 <proc_freepagetable>
  return -1;
    80004aee:	557d                	li	a0,-1
    80004af0:	79fe                	ld	s3,504(sp)
    80004af2:	7a5e                	ld	s4,496(sp)
    80004af4:	7abe                	ld	s5,488(sp)
    80004af6:	7b1e                	ld	s6,480(sp)
    80004af8:	6bfe                	ld	s7,472(sp)
    80004afa:	6c5e                	ld	s8,464(sp)
    80004afc:	6cbe                	ld	s9,456(sp)
    80004afe:	6d1e                	ld	s10,448(sp)
    80004b00:	b549                	j	80004982 <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004b02:	4901                	li	s2,0
    80004b04:	bf45                	j	80004ab4 <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004b06:	75f9                	lui	a1,0xffffe
    80004b08:	95aa                	add	a1,a1,a0
    80004b0a:	855a                	mv	a0,s6
    80004b0c:	9b5fc0ef          	jal	800014c0 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004b10:	80090a13          	addi	s4,s2,-2048
    80004b14:	800a0a13          	addi	s4,s4,-2048
  for (argc = 0; argv[argc]; argc++) {
    80004b18:	e0043783          	ld	a5,-512(s0)
    80004b1c:	6388                	ld	a0,0(a5)
    80004b1e:	c545                	beqz	a0,80004bc6 <kexec+0x2b6>
  sp = sz;
    80004b20:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004b22:	4481                	li	s1,0
    ustack[argc] = sp;
    80004b24:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004b28:	b4afc0ef          	jal	80000e72 <strlen>
    80004b2c:	0015079b          	addiw	a5,a0,1
    80004b30:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004b34:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004b38:	134c6563          	bltu	s8,s4,80004c62 <kexec+0x352>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004b3c:	e0043d03          	ld	s10,-512(s0)
    80004b40:	000d3c83          	ld	s9,0(s10)
    80004b44:	8566                	mv	a0,s9
    80004b46:	b2cfc0ef          	jal	80000e72 <strlen>
    80004b4a:	0015071b          	addiw	a4,a0,1
    80004b4e:	86e6                	mv	a3,s9
    80004b50:	8662                	mv	a2,s8
    80004b52:	85ca                	mv	a1,s2
    80004b54:	855a                	mv	a0,s6
    80004b56:	a2dfc0ef          	jal	80001582 <copyout>
    80004b5a:	10054663          	bltz	a0,80004c66 <kexec+0x356>
    ustack[argc] = sp;
    80004b5e:	00349793          	slli	a5,s1,0x3
    80004b62:	97de                	add	a5,a5,s7
    80004b64:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb788>
  for (argc = 0; argv[argc]; argc++) {
    80004b68:	0485                	addi	s1,s1,1
    80004b6a:	008d0793          	addi	a5,s10,8
    80004b6e:	e0f43023          	sd	a5,-512(s0)
    80004b72:	008d3503          	ld	a0,8(s10)
    80004b76:	f94d                	bnez	a0,80004b28 <kexec+0x218>
  ustack[argc] = 0;
    80004b78:	00349793          	slli	a5,s1,0x3
    80004b7c:	f9078793          	addi	a5,a5,-112
    80004b80:	97a2                	add	a5,a5,s0
    80004b82:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004b86:	00349713          	slli	a4,s1,0x3
    80004b8a:	0721                	addi	a4,a4,8
    80004b8c:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004b90:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004b94:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004b96:	f54be8e3          	bltu	s7,s4,80004ae6 <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004b9a:	e9040693          	addi	a3,s0,-368
    80004b9e:	865e                	mv	a2,s7
    80004ba0:	85ca                	mv	a1,s2
    80004ba2:	855a                	mv	a0,s6
    80004ba4:	9dffc0ef          	jal	80001582 <copyout>
    80004ba8:	f2054fe3          	bltz	a0,80004ae6 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004bac:	0589b783          	ld	a5,88(s3)
    80004bb0:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004bb4:	df043783          	ld	a5,-528(s0)
    80004bb8:	0007c703          	lbu	a4,0(a5)
    80004bbc:	c30d                	beqz	a4,80004bde <kexec+0x2ce>
    80004bbe:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004bc0:	02f00693          	li	a3,47
    80004bc4:	a801                	j	80004bd4 <kexec+0x2c4>
  sp = sz;
    80004bc6:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004bc8:	4481                	li	s1,0
    80004bca:	b77d                	j	80004b78 <kexec+0x268>
  for (last = s = path; *s; s++)
    80004bcc:	0785                	addi	a5,a5,1
    80004bce:	fff7c703          	lbu	a4,-1(a5)
    80004bd2:	c711                	beqz	a4,80004bde <kexec+0x2ce>
    if (*s == '/')
    80004bd4:	fed71ce3          	bne	a4,a3,80004bcc <kexec+0x2bc>
      last = s + 1;
    80004bd8:	def43823          	sd	a5,-528(s0)
    80004bdc:	bfc5                	j	80004bcc <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004bde:	4641                	li	a2,16
    80004be0:	df043583          	ld	a1,-528(s0)
    80004be4:	15898513          	addi	a0,s3,344
    80004be8:	a54fc0ef          	jal	80000e3c <safestrcpy>
  oldpagetable = p->pagetable;
    80004bec:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004bf0:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004bf4:	0529b423          	sd	s2,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004bf8:	0589b783          	ld	a5,88(s3)
    80004bfc:	e6843703          	ld	a4,-408(s0)
    80004c00:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004c02:	0589b783          	ld	a5,88(s3)
    80004c06:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004c0a:	85d6                	mv	a1,s5
    80004c0c:	ec7fc0ef          	jal	80001ad2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004c10:	0004851b          	sext.w	a0,s1
    80004c14:	79fe                	ld	s3,504(sp)
    80004c16:	7a5e                	ld	s4,496(sp)
    80004c18:	7abe                	ld	s5,488(sp)
    80004c1a:	7b1e                	ld	s6,480(sp)
    80004c1c:	6bfe                	ld	s7,472(sp)
    80004c1e:	6c5e                	ld	s8,464(sp)
    80004c20:	6cbe                	ld	s9,456(sp)
    80004c22:	6d1e                	ld	s10,448(sp)
    80004c24:	bbb9                	j	80004982 <kexec+0x72>
    80004c26:	7b1e                	ld	s6,480(sp)
    80004c28:	b3b1                	j	80004974 <kexec+0x64>
    80004c2a:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004c2e:	df843583          	ld	a1,-520(s0)
    80004c32:	855a                	mv	a0,s6
    80004c34:	e9ffc0ef          	jal	80001ad2 <proc_freepagetable>
  if (ip) {
    80004c38:	79fe                	ld	s3,504(sp)
    80004c3a:	7abe                	ld	s5,488(sp)
    80004c3c:	7b1e                	ld	s6,480(sp)
    80004c3e:	6bfe                	ld	s7,472(sp)
    80004c40:	6c5e                	ld	s8,464(sp)
    80004c42:	6cbe                	ld	s9,456(sp)
    80004c44:	6d1e                	ld	s10,448(sp)
    80004c46:	7dfa                	ld	s11,440(sp)
    80004c48:	b335                	j	80004974 <kexec+0x64>
    80004c4a:	df243c23          	sd	s2,-520(s0)
    80004c4e:	b7c5                	j	80004c2e <kexec+0x31e>
    80004c50:	df243c23          	sd	s2,-520(s0)
    80004c54:	bfe9                	j	80004c2e <kexec+0x31e>
    80004c56:	df243c23          	sd	s2,-520(s0)
    80004c5a:	bfd1                	j	80004c2e <kexec+0x31e>
    80004c5c:	df243c23          	sd	s2,-520(s0)
    80004c60:	b7f9                	j	80004c2e <kexec+0x31e>
  sz = sz1;
    80004c62:	8c4a                	mv	s8,s2
    80004c64:	b549                	j	80004ae6 <kexec+0x1d6>
    80004c66:	8c4a                	mv	s8,s2
    80004c68:	bdbd                	j	80004ae6 <kexec+0x1d6>

0000000080004c6a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004c6a:	7179                	addi	sp,sp,-48
    80004c6c:	f406                	sd	ra,40(sp)
    80004c6e:	f022                	sd	s0,32(sp)
    80004c70:	ec26                	sd	s1,24(sp)
    80004c72:	e84a                	sd	s2,16(sp)
    80004c74:	1800                	addi	s0,sp,48
    80004c76:	892e                	mv	s2,a1
    80004c78:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004c7a:	fdc40593          	addi	a1,s0,-36
    80004c7e:	c99fd0ef          	jal	80002916 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004c82:	fdc42703          	lw	a4,-36(s0)
    80004c86:	47bd                	li	a5,15
    80004c88:	02e7ea63          	bltu	a5,a4,80004cbc <argfd+0x52>
    80004c8c:	cbdfc0ef          	jal	80001948 <myproc>
    80004c90:	fdc42703          	lw	a4,-36(s0)
    80004c94:	00371793          	slli	a5,a4,0x3
    80004c98:	0d078793          	addi	a5,a5,208
    80004c9c:	953e                	add	a0,a0,a5
    80004c9e:	611c                	ld	a5,0(a0)
    80004ca0:	c385                	beqz	a5,80004cc0 <argfd+0x56>
    return -1;
  if (pfd)
    80004ca2:	00090463          	beqz	s2,80004caa <argfd+0x40>
    *pfd = fd;
    80004ca6:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004caa:	4501                	li	a0,0
  if (pf)
    80004cac:	c091                	beqz	s1,80004cb0 <argfd+0x46>
    *pf = f;
    80004cae:	e09c                	sd	a5,0(s1)
}
    80004cb0:	70a2                	ld	ra,40(sp)
    80004cb2:	7402                	ld	s0,32(sp)
    80004cb4:	64e2                	ld	s1,24(sp)
    80004cb6:	6942                	ld	s2,16(sp)
    80004cb8:	6145                	addi	sp,sp,48
    80004cba:	8082                	ret
    return -1;
    80004cbc:	557d                	li	a0,-1
    80004cbe:	bfcd                	j	80004cb0 <argfd+0x46>
    80004cc0:	557d                	li	a0,-1
    80004cc2:	b7fd                	j	80004cb0 <argfd+0x46>

0000000080004cc4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004cc4:	1101                	addi	sp,sp,-32
    80004cc6:	ec06                	sd	ra,24(sp)
    80004cc8:	e822                	sd	s0,16(sp)
    80004cca:	e426                	sd	s1,8(sp)
    80004ccc:	1000                	addi	s0,sp,32
    80004cce:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004cd0:	c79fc0ef          	jal	80001948 <myproc>
    80004cd4:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004cd6:	0d050793          	addi	a5,a0,208
    80004cda:	4501                	li	a0,0
    80004cdc:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004cde:	6398                	ld	a4,0(a5)
    80004ce0:	cb19                	beqz	a4,80004cf6 <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004ce2:	2505                	addiw	a0,a0,1
    80004ce4:	07a1                	addi	a5,a5,8
    80004ce6:	fed51ce3          	bne	a0,a3,80004cde <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004cea:	557d                	li	a0,-1
}
    80004cec:	60e2                	ld	ra,24(sp)
    80004cee:	6442                	ld	s0,16(sp)
    80004cf0:	64a2                	ld	s1,8(sp)
    80004cf2:	6105                	addi	sp,sp,32
    80004cf4:	8082                	ret
      p->ofile[fd] = f;
    80004cf6:	00351793          	slli	a5,a0,0x3
    80004cfa:	0d078793          	addi	a5,a5,208
    80004cfe:	963e                	add	a2,a2,a5
    80004d00:	e204                	sd	s1,0(a2)
      return fd;
    80004d02:	b7ed                	j	80004cec <fdalloc+0x28>

0000000080004d04 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004d04:	715d                	addi	sp,sp,-80
    80004d06:	e486                	sd	ra,72(sp)
    80004d08:	e0a2                	sd	s0,64(sp)
    80004d0a:	fc26                	sd	s1,56(sp)
    80004d0c:	f84a                	sd	s2,48(sp)
    80004d0e:	f052                	sd	s4,32(sp)
    80004d10:	ec56                	sd	s5,24(sp)
    80004d12:	e85a                	sd	s6,16(sp)
    80004d14:	0880                	addi	s0,sp,80
    80004d16:	8a2e                	mv	s4,a1
    80004d18:	8ab2                	mv	s5,a2
    80004d1a:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004d1c:	fb040593          	addi	a1,s0,-80
    80004d20:	eb5fe0ef          	jal	80003bd4 <nameiparent>
    80004d24:	84aa                	mv	s1,a0
    80004d26:	12050f63          	beqz	a0,80004e64 <create+0x160>
    return 0;

  ilock(dp);
    80004d2a:	df6fe0ef          	jal	80003320 <ilock>

  if (dp->nlink == 0) {
    80004d2e:	04a49783          	lh	a5,74(s1)
    80004d32:	cbb9                	beqz	a5,80004d88 <create+0x84>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004d34:	7761                	lui	a4,0xffff8
    80004d36:	0705                	addi	a4,a4,1 # ffffffffffff8001 <end+0xffffffff7ffd4789>
    80004d38:	97ba                	add	a5,a5,a4
    80004d3a:	e781                	bnez	a5,80004d42 <create+0x3e>
    80004d3c:	fffa0793          	addi	a5,s4,-1
    80004d40:	cba9                	beqz	a5,80004d92 <create+0x8e>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004d42:	4601                	li	a2,0
    80004d44:	fb040593          	addi	a1,s0,-80
    80004d48:	8526                	mv	a0,s1
    80004d4a:	bbffe0ef          	jal	80003908 <dirlookup>
    80004d4e:	892a                	mv	s2,a0
    80004d50:	c939                	beqz	a0,80004da6 <create+0xa2>
    iunlockput(dp);
    80004d52:	8526                	mv	a0,s1
    80004d54:	821fe0ef          	jal	80003574 <iunlockput>
    ilock(ip);
    80004d58:	854a                	mv	a0,s2
    80004d5a:	dc6fe0ef          	jal	80003320 <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004d5e:	4789                	li	a5,2
    80004d60:	02fa1e63          	bne	s4,a5,80004d9c <create+0x98>
    80004d64:	04495783          	lhu	a5,68(s2)
    80004d68:	37f9                	addiw	a5,a5,-2
    80004d6a:	17c2                	slli	a5,a5,0x30
    80004d6c:	93c1                	srli	a5,a5,0x30
    80004d6e:	4705                	li	a4,1
    80004d70:	02f76663          	bltu	a4,a5,80004d9c <create+0x98>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004d74:	854a                	mv	a0,s2
    80004d76:	60a6                	ld	ra,72(sp)
    80004d78:	6406                	ld	s0,64(sp)
    80004d7a:	74e2                	ld	s1,56(sp)
    80004d7c:	7942                	ld	s2,48(sp)
    80004d7e:	7a02                	ld	s4,32(sp)
    80004d80:	6ae2                	ld	s5,24(sp)
    80004d82:	6b42                	ld	s6,16(sp)
    80004d84:	6161                	addi	sp,sp,80
    80004d86:	8082                	ret
    iunlockput(dp);
    80004d88:	8526                	mv	a0,s1
    80004d8a:	feafe0ef          	jal	80003574 <iunlockput>
    return 0;
    80004d8e:	4901                	li	s2,0
    80004d90:	b7d5                	j	80004d74 <create+0x70>
    iunlockput(dp);
    80004d92:	8526                	mv	a0,s1
    80004d94:	fe0fe0ef          	jal	80003574 <iunlockput>
    return 0;
    80004d98:	4901                	li	s2,0
    80004d9a:	bfe9                	j	80004d74 <create+0x70>
    iunlockput(ip);
    80004d9c:	854a                	mv	a0,s2
    80004d9e:	fd6fe0ef          	jal	80003574 <iunlockput>
    return 0;
    80004da2:	4901                	li	s2,0
    80004da4:	bfc1                	j	80004d74 <create+0x70>
    80004da6:	f44e                	sd	s3,40(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004da8:	85d2                	mv	a1,s4
    80004daa:	4088                	lw	a0,0(s1)
    80004dac:	c04fe0ef          	jal	800031b0 <ialloc>
    80004db0:	89aa                	mv	s3,a0
    80004db2:	cd1d                	beqz	a0,80004df0 <create+0xec>
  ilock(ip);
    80004db4:	d6cfe0ef          	jal	80003320 <ilock>
  ip->major = major;
    80004db8:	05599323          	sh	s5,70(s3)
  ip->minor = minor;
    80004dbc:	05699423          	sh	s6,72(s3)
  ip->nlink = 1;
    80004dc0:	4705                	li	a4,1
    80004dc2:	04e99523          	sh	a4,74(s3)
  iupdate(ip);
    80004dc6:	854e                	mv	a0,s3
    80004dc8:	ca4fe0ef          	jal	8000326c <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80004dcc:	4705                	li	a4,1
    80004dce:	02ea0763          	beq	s4,a4,80004dfc <create+0xf8>
  if (dirlink(dp, name, ip->inum) < 0)
    80004dd2:	0049a603          	lw	a2,4(s3)
    80004dd6:	fb040593          	addi	a1,s0,-80
    80004dda:	8526                	mv	a0,s1
    80004ddc:	d35fe0ef          	jal	80003b10 <dirlink>
    80004de0:	06054563          	bltz	a0,80004e4a <create+0x146>
  iunlockput(dp);
    80004de4:	8526                	mv	a0,s1
    80004de6:	f8efe0ef          	jal	80003574 <iunlockput>
  return ip;
    80004dea:	894e                	mv	s2,s3
    80004dec:	79a2                	ld	s3,40(sp)
    80004dee:	b759                	j	80004d74 <create+0x70>
    iunlockput(dp);
    80004df0:	8526                	mv	a0,s1
    80004df2:	f82fe0ef          	jal	80003574 <iunlockput>
    return 0;
    80004df6:	894e                	mv	s2,s3
    80004df8:	79a2                	ld	s3,40(sp)
    80004dfa:	bfad                	j	80004d74 <create+0x70>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004dfc:	0049a603          	lw	a2,4(s3)
    80004e00:	00002597          	auipc	a1,0x2
    80004e04:	7e058593          	addi	a1,a1,2016 # 800075e0 <etext+0x5e0>
    80004e08:	854e                	mv	a0,s3
    80004e0a:	d07fe0ef          	jal	80003b10 <dirlink>
    80004e0e:	02054e63          	bltz	a0,80004e4a <create+0x146>
    80004e12:	40d0                	lw	a2,4(s1)
    80004e14:	00002597          	auipc	a1,0x2
    80004e18:	7d458593          	addi	a1,a1,2004 # 800075e8 <etext+0x5e8>
    80004e1c:	854e                	mv	a0,s3
    80004e1e:	cf3fe0ef          	jal	80003b10 <dirlink>
    80004e22:	02054463          	bltz	a0,80004e4a <create+0x146>
  if (dirlink(dp, name, ip->inum) < 0)
    80004e26:	0049a603          	lw	a2,4(s3)
    80004e2a:	fb040593          	addi	a1,s0,-80
    80004e2e:	8526                	mv	a0,s1
    80004e30:	ce1fe0ef          	jal	80003b10 <dirlink>
    80004e34:	00054b63          	bltz	a0,80004e4a <create+0x146>
    dp->nlink++; // for ".."
    80004e38:	04a4d783          	lhu	a5,74(s1)
    80004e3c:	2785                	addiw	a5,a5,1
    80004e3e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004e42:	8526                	mv	a0,s1
    80004e44:	c28fe0ef          	jal	8000326c <iupdate>
    80004e48:	bf71                	j	80004de4 <create+0xe0>
  ip->nlink = 0;
    80004e4a:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    80004e4e:	854e                	mv	a0,s3
    80004e50:	c1cfe0ef          	jal	8000326c <iupdate>
  iunlockput(ip);
    80004e54:	854e                	mv	a0,s3
    80004e56:	f1efe0ef          	jal	80003574 <iunlockput>
  iunlockput(dp);
    80004e5a:	8526                	mv	a0,s1
    80004e5c:	f18fe0ef          	jal	80003574 <iunlockput>
  return 0;
    80004e60:	79a2                	ld	s3,40(sp)
    80004e62:	bf09                	j	80004d74 <create+0x70>
    return 0;
    80004e64:	892a                	mv	s2,a0
    80004e66:	b739                	j	80004d74 <create+0x70>

0000000080004e68 <sys_dup>:
{
    80004e68:	7179                	addi	sp,sp,-48
    80004e6a:	f406                	sd	ra,40(sp)
    80004e6c:	f022                	sd	s0,32(sp)
    80004e6e:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004e70:	fd840613          	addi	a2,s0,-40
    80004e74:	4581                	li	a1,0
    80004e76:	4501                	li	a0,0
    80004e78:	df3ff0ef          	jal	80004c6a <argfd>
    return -1;
    80004e7c:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004e7e:	02054363          	bltz	a0,80004ea4 <sys_dup+0x3c>
    80004e82:	ec26                	sd	s1,24(sp)
    80004e84:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004e86:	fd843483          	ld	s1,-40(s0)
    80004e8a:	8526                	mv	a0,s1
    80004e8c:	e39ff0ef          	jal	80004cc4 <fdalloc>
    80004e90:	892a                	mv	s2,a0
    return -1;
    80004e92:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004e94:	00054d63          	bltz	a0,80004eae <sys_dup+0x46>
  filedup(f);
    80004e98:	8526                	mv	a0,s1
    80004e9a:	b72ff0ef          	jal	8000420c <filedup>
  return fd;
    80004e9e:	87ca                	mv	a5,s2
    80004ea0:	64e2                	ld	s1,24(sp)
    80004ea2:	6942                	ld	s2,16(sp)
}
    80004ea4:	853e                	mv	a0,a5
    80004ea6:	70a2                	ld	ra,40(sp)
    80004ea8:	7402                	ld	s0,32(sp)
    80004eaa:	6145                	addi	sp,sp,48
    80004eac:	8082                	ret
    80004eae:	64e2                	ld	s1,24(sp)
    80004eb0:	6942                	ld	s2,16(sp)
    80004eb2:	bfcd                	j	80004ea4 <sys_dup+0x3c>

0000000080004eb4 <sys_read>:
{
    80004eb4:	7179                	addi	sp,sp,-48
    80004eb6:	f406                	sd	ra,40(sp)
    80004eb8:	f022                	sd	s0,32(sp)
    80004eba:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004ebc:	fd840593          	addi	a1,s0,-40
    80004ec0:	4505                	li	a0,1
    80004ec2:	a71fd0ef          	jal	80002932 <argaddr>
  argint(2, &n);
    80004ec6:	fe440593          	addi	a1,s0,-28
    80004eca:	4509                	li	a0,2
    80004ecc:	a4bfd0ef          	jal	80002916 <argint>
  if (argfd(0, 0, &f) < 0)
    80004ed0:	fe840613          	addi	a2,s0,-24
    80004ed4:	4581                	li	a1,0
    80004ed6:	4501                	li	a0,0
    80004ed8:	d93ff0ef          	jal	80004c6a <argfd>
    80004edc:	87aa                	mv	a5,a0
    return -1;
    80004ede:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004ee0:	0007ca63          	bltz	a5,80004ef4 <sys_read+0x40>
  return fileread(f, p, n);
    80004ee4:	fe442603          	lw	a2,-28(s0)
    80004ee8:	fd843583          	ld	a1,-40(s0)
    80004eec:	fe843503          	ld	a0,-24(s0)
    80004ef0:	c94ff0ef          	jal	80004384 <fileread>
}
    80004ef4:	70a2                	ld	ra,40(sp)
    80004ef6:	7402                	ld	s0,32(sp)
    80004ef8:	6145                	addi	sp,sp,48
    80004efa:	8082                	ret

0000000080004efc <sys_write>:
{
    80004efc:	7179                	addi	sp,sp,-48
    80004efe:	f406                	sd	ra,40(sp)
    80004f00:	f022                	sd	s0,32(sp)
    80004f02:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f04:	fd840593          	addi	a1,s0,-40
    80004f08:	4505                	li	a0,1
    80004f0a:	a29fd0ef          	jal	80002932 <argaddr>
  argint(2, &n);
    80004f0e:	fe440593          	addi	a1,s0,-28
    80004f12:	4509                	li	a0,2
    80004f14:	a03fd0ef          	jal	80002916 <argint>
  if (argfd(0, 0, &f) < 0)
    80004f18:	fe840613          	addi	a2,s0,-24
    80004f1c:	4581                	li	a1,0
    80004f1e:	4501                	li	a0,0
    80004f20:	d4bff0ef          	jal	80004c6a <argfd>
    80004f24:	87aa                	mv	a5,a0
    return -1;
    80004f26:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004f28:	0007ca63          	bltz	a5,80004f3c <sys_write+0x40>
  return filewrite(f, p, n);
    80004f2c:	fe442603          	lw	a2,-28(s0)
    80004f30:	fd843583          	ld	a1,-40(s0)
    80004f34:	fe843503          	ld	a0,-24(s0)
    80004f38:	d1aff0ef          	jal	80004452 <filewrite>
}
    80004f3c:	70a2                	ld	ra,40(sp)
    80004f3e:	7402                	ld	s0,32(sp)
    80004f40:	6145                	addi	sp,sp,48
    80004f42:	8082                	ret

0000000080004f44 <sys_close>:
{
    80004f44:	1101                	addi	sp,sp,-32
    80004f46:	ec06                	sd	ra,24(sp)
    80004f48:	e822                	sd	s0,16(sp)
    80004f4a:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80004f4c:	fe040613          	addi	a2,s0,-32
    80004f50:	fec40593          	addi	a1,s0,-20
    80004f54:	4501                	li	a0,0
    80004f56:	d15ff0ef          	jal	80004c6a <argfd>
    return -1;
    80004f5a:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80004f5c:	02054163          	bltz	a0,80004f7e <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004f60:	9e9fc0ef          	jal	80001948 <myproc>
    80004f64:	fec42783          	lw	a5,-20(s0)
    80004f68:	078e                	slli	a5,a5,0x3
    80004f6a:	0d078793          	addi	a5,a5,208
    80004f6e:	953e                	add	a0,a0,a5
    80004f70:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004f74:	fe043503          	ld	a0,-32(s0)
    80004f78:	adaff0ef          	jal	80004252 <fileclose>
  return 0;
    80004f7c:	4781                	li	a5,0
}
    80004f7e:	853e                	mv	a0,a5
    80004f80:	60e2                	ld	ra,24(sp)
    80004f82:	6442                	ld	s0,16(sp)
    80004f84:	6105                	addi	sp,sp,32
    80004f86:	8082                	ret

0000000080004f88 <sys_fstat>:
{
    80004f88:	1101                	addi	sp,sp,-32
    80004f8a:	ec06                	sd	ra,24(sp)
    80004f8c:	e822                	sd	s0,16(sp)
    80004f8e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004f90:	fe040593          	addi	a1,s0,-32
    80004f94:	4505                	li	a0,1
    80004f96:	99dfd0ef          	jal	80002932 <argaddr>
  if (argfd(0, 0, &f) < 0)
    80004f9a:	fe840613          	addi	a2,s0,-24
    80004f9e:	4581                	li	a1,0
    80004fa0:	4501                	li	a0,0
    80004fa2:	cc9ff0ef          	jal	80004c6a <argfd>
    80004fa6:	87aa                	mv	a5,a0
    return -1;
    80004fa8:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004faa:	0007c863          	bltz	a5,80004fba <sys_fstat+0x32>
  return filestat(f, st);
    80004fae:	fe043583          	ld	a1,-32(s0)
    80004fb2:	fe843503          	ld	a0,-24(s0)
    80004fb6:	b5eff0ef          	jal	80004314 <filestat>
}
    80004fba:	60e2                	ld	ra,24(sp)
    80004fbc:	6442                	ld	s0,16(sp)
    80004fbe:	6105                	addi	sp,sp,32
    80004fc0:	8082                	ret

0000000080004fc2 <sys_link>:
{
    80004fc2:	7169                	addi	sp,sp,-304
    80004fc4:	f606                	sd	ra,296(sp)
    80004fc6:	f222                	sd	s0,288(sp)
    80004fc8:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004fca:	08000613          	li	a2,128
    80004fce:	ed040593          	addi	a1,s0,-304
    80004fd2:	4501                	li	a0,0
    80004fd4:	97bfd0ef          	jal	8000294e <argstr>
    return -1;
    80004fd8:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004fda:	10054163          	bltz	a0,800050dc <sys_link+0x11a>
    80004fde:	08000613          	li	a2,128
    80004fe2:	f5040593          	addi	a1,s0,-176
    80004fe6:	4505                	li	a0,1
    80004fe8:	967fd0ef          	jal	8000294e <argstr>
    return -1;
    80004fec:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004fee:	0e054763          	bltz	a0,800050dc <sys_link+0x11a>
    80004ff2:	ee26                	sd	s1,280(sp)
  begin_op();
    80004ff4:	da5fe0ef          	jal	80003d98 <begin_op>
  if ((ip = namei(old)) == 0) {
    80004ff8:	ed040513          	addi	a0,s0,-304
    80004ffc:	bbffe0ef          	jal	80003bba <namei>
    80005000:	84aa                	mv	s1,a0
    80005002:	cd35                	beqz	a0,8000507e <sys_link+0xbc>
  ilock(ip);
    80005004:	b1cfe0ef          	jal	80003320 <ilock>
  if (ip->type == T_DIR) {
    80005008:	04449703          	lh	a4,68(s1)
    8000500c:	4785                	li	a5,1
    8000500e:	06f70d63          	beq	a4,a5,80005088 <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    80005012:	04a49783          	lh	a5,74(s1)
    80005016:	6721                	lui	a4,0x8
    80005018:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    8000501a:	06e78f63          	beq	a5,a4,80005098 <sys_link+0xd6>
    8000501e:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005020:	2785                	addiw	a5,a5,1
    80005022:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005026:	8526                	mv	a0,s1
    80005028:	a44fe0ef          	jal	8000326c <iupdate>
  iunlock(ip);
    8000502c:	8526                	mv	a0,s1
    8000502e:	ba0fe0ef          	jal	800033ce <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80005032:	fd040593          	addi	a1,s0,-48
    80005036:	f5040513          	addi	a0,s0,-176
    8000503a:	b9bfe0ef          	jal	80003bd4 <nameiparent>
    8000503e:	892a                	mv	s2,a0
    80005040:	c93d                	beqz	a0,800050b6 <sys_link+0xf4>
  ilock(dp);
    80005042:	adefe0ef          	jal	80003320 <ilock>
  if (dp->nlink == 0) {
    80005046:	04a91783          	lh	a5,74(s2)
    8000504a:	cfb9                	beqz	a5,800050a8 <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    8000504c:	854a                	mv	a0,s2
    8000504e:	00092703          	lw	a4,0(s2)
    80005052:	409c                	lw	a5,0(s1)
    80005054:	04f71e63          	bne	a4,a5,800050b0 <sys_link+0xee>
    80005058:	40d0                	lw	a2,4(s1)
    8000505a:	fd040593          	addi	a1,s0,-48
    8000505e:	ab3fe0ef          	jal	80003b10 <dirlink>
    80005062:	04054763          	bltz	a0,800050b0 <sys_link+0xee>
  iunlockput(dp);
    80005066:	854a                	mv	a0,s2
    80005068:	d0cfe0ef          	jal	80003574 <iunlockput>
  iput(ip);
    8000506c:	8526                	mv	a0,s1
    8000506e:	c34fe0ef          	jal	800034a2 <iput>
  end_op();
    80005072:	db3fe0ef          	jal	80003e24 <end_op>
  return 0;
    80005076:	4781                	li	a5,0
    80005078:	64f2                	ld	s1,280(sp)
    8000507a:	6952                	ld	s2,272(sp)
    8000507c:	a085                	j	800050dc <sys_link+0x11a>
    end_op();
    8000507e:	da7fe0ef          	jal	80003e24 <end_op>
    return -1;
    80005082:	57fd                	li	a5,-1
    80005084:	64f2                	ld	s1,280(sp)
    80005086:	a899                	j	800050dc <sys_link+0x11a>
    iunlockput(ip);
    80005088:	8526                	mv	a0,s1
    8000508a:	ceafe0ef          	jal	80003574 <iunlockput>
    end_op();
    8000508e:	d97fe0ef          	jal	80003e24 <end_op>
    return -1;
    80005092:	57fd                	li	a5,-1
    80005094:	64f2                	ld	s1,280(sp)
    80005096:	a099                	j	800050dc <sys_link+0x11a>
    iunlockput(ip);
    80005098:	8526                	mv	a0,s1
    8000509a:	cdafe0ef          	jal	80003574 <iunlockput>
    end_op();
    8000509e:	d87fe0ef          	jal	80003e24 <end_op>
    return -1;
    800050a2:	57fd                	li	a5,-1
    800050a4:	64f2                	ld	s1,280(sp)
    800050a6:	a81d                	j	800050dc <sys_link+0x11a>
    iunlockput(dp);
    800050a8:	854a                	mv	a0,s2
    800050aa:	ccafe0ef          	jal	80003574 <iunlockput>
    goto bad;
    800050ae:	a021                	j	800050b6 <sys_link+0xf4>
    iunlockput(dp);
    800050b0:	854a                	mv	a0,s2
    800050b2:	cc2fe0ef          	jal	80003574 <iunlockput>
  ilock(ip);
    800050b6:	8526                	mv	a0,s1
    800050b8:	a68fe0ef          	jal	80003320 <ilock>
  ip->nlink--;
    800050bc:	04a4d783          	lhu	a5,74(s1)
    800050c0:	37fd                	addiw	a5,a5,-1
    800050c2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800050c6:	8526                	mv	a0,s1
    800050c8:	9a4fe0ef          	jal	8000326c <iupdate>
  iunlockput(ip);
    800050cc:	8526                	mv	a0,s1
    800050ce:	ca6fe0ef          	jal	80003574 <iunlockput>
  end_op();
    800050d2:	d53fe0ef          	jal	80003e24 <end_op>
  return -1;
    800050d6:	57fd                	li	a5,-1
    800050d8:	64f2                	ld	s1,280(sp)
    800050da:	6952                	ld	s2,272(sp)
}
    800050dc:	853e                	mv	a0,a5
    800050de:	70b2                	ld	ra,296(sp)
    800050e0:	7412                	ld	s0,288(sp)
    800050e2:	6155                	addi	sp,sp,304
    800050e4:	8082                	ret

00000000800050e6 <sys_unlink>:
{
    800050e6:	7151                	addi	sp,sp,-240
    800050e8:	f586                	sd	ra,232(sp)
    800050ea:	f1a2                	sd	s0,224(sp)
    800050ec:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    800050ee:	08000613          	li	a2,128
    800050f2:	f3040593          	addi	a1,s0,-208
    800050f6:	4501                	li	a0,0
    800050f8:	857fd0ef          	jal	8000294e <argstr>
    800050fc:	14054d63          	bltz	a0,80005256 <sys_unlink+0x170>
    80005100:	eda6                	sd	s1,216(sp)
  begin_op();
    80005102:	c97fe0ef          	jal	80003d98 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    80005106:	fb040593          	addi	a1,s0,-80
    8000510a:	f3040513          	addi	a0,s0,-208
    8000510e:	ac7fe0ef          	jal	80003bd4 <nameiparent>
    80005112:	84aa                	mv	s1,a0
    80005114:	c955                	beqz	a0,800051c8 <sys_unlink+0xe2>
  ilock(dp);
    80005116:	a0afe0ef          	jal	80003320 <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000511a:	00002597          	auipc	a1,0x2
    8000511e:	4c658593          	addi	a1,a1,1222 # 800075e0 <etext+0x5e0>
    80005122:	fb040513          	addi	a0,s0,-80
    80005126:	fccfe0ef          	jal	800038f2 <namecmp>
    8000512a:	10050b63          	beqz	a0,80005240 <sys_unlink+0x15a>
    8000512e:	00002597          	auipc	a1,0x2
    80005132:	4ba58593          	addi	a1,a1,1210 # 800075e8 <etext+0x5e8>
    80005136:	fb040513          	addi	a0,s0,-80
    8000513a:	fb8fe0ef          	jal	800038f2 <namecmp>
    8000513e:	10050163          	beqz	a0,80005240 <sys_unlink+0x15a>
    80005142:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    80005144:	f2c40613          	addi	a2,s0,-212
    80005148:	fb040593          	addi	a1,s0,-80
    8000514c:	8526                	mv	a0,s1
    8000514e:	fbafe0ef          	jal	80003908 <dirlookup>
    80005152:	892a                	mv	s2,a0
    80005154:	0e050563          	beqz	a0,8000523e <sys_unlink+0x158>
    80005158:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    8000515a:	9c6fe0ef          	jal	80003320 <ilock>
  if (ip->nlink < 1)
    8000515e:	04a91783          	lh	a5,74(s2)
    80005162:	06f05863          	blez	a5,800051d2 <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    80005166:	04491703          	lh	a4,68(s2)
    8000516a:	4785                	li	a5,1
    8000516c:	06f70963          	beq	a4,a5,800051de <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005170:	fc040993          	addi	s3,s0,-64
    80005174:	4641                	li	a2,16
    80005176:	4581                	li	a1,0
    80005178:	854e                	mv	a0,s3
    8000517a:	b6ffb0ef          	jal	80000ce8 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000517e:	4741                	li	a4,16
    80005180:	f2c42683          	lw	a3,-212(s0)
    80005184:	864e                	mv	a2,s3
    80005186:	4581                	li	a1,0
    80005188:	8526                	mv	a0,s1
    8000518a:	e62fe0ef          	jal	800037ec <writei>
    8000518e:	47c1                	li	a5,16
    80005190:	08f51863          	bne	a0,a5,80005220 <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    80005194:	04491703          	lh	a4,68(s2)
    80005198:	4785                	li	a5,1
    8000519a:	08f70963          	beq	a4,a5,8000522c <sys_unlink+0x146>
  iunlockput(dp);
    8000519e:	8526                	mv	a0,s1
    800051a0:	bd4fe0ef          	jal	80003574 <iunlockput>
  ip->nlink--;
    800051a4:	04a95783          	lhu	a5,74(s2)
    800051a8:	37fd                	addiw	a5,a5,-1
    800051aa:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800051ae:	854a                	mv	a0,s2
    800051b0:	8bcfe0ef          	jal	8000326c <iupdate>
  iunlockput(ip);
    800051b4:	854a                	mv	a0,s2
    800051b6:	bbefe0ef          	jal	80003574 <iunlockput>
  end_op();
    800051ba:	c6bfe0ef          	jal	80003e24 <end_op>
  return 0;
    800051be:	4501                	li	a0,0
    800051c0:	64ee                	ld	s1,216(sp)
    800051c2:	694e                	ld	s2,208(sp)
    800051c4:	69ae                	ld	s3,200(sp)
    800051c6:	a061                	j	8000524e <sys_unlink+0x168>
    end_op();
    800051c8:	c5dfe0ef          	jal	80003e24 <end_op>
    return -1;
    800051cc:	557d                	li	a0,-1
    800051ce:	64ee                	ld	s1,216(sp)
    800051d0:	a8bd                	j	8000524e <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800051d2:	00002517          	auipc	a0,0x2
    800051d6:	41e50513          	addi	a0,a0,1054 # 800075f0 <etext+0x5f0>
    800051da:	e5afb0ef          	jal	80000834 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    800051de:	04c92703          	lw	a4,76(s2)
    800051e2:	02000793          	li	a5,32
    800051e6:	f8e7f5e3          	bgeu	a5,a4,80005170 <sys_unlink+0x8a>
    800051ea:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800051ec:	4741                	li	a4,16
    800051ee:	86ce                	mv	a3,s3
    800051f0:	f1840613          	addi	a2,s0,-232
    800051f4:	4581                	li	a1,0
    800051f6:	854a                	mv	a0,s2
    800051f8:	d02fe0ef          	jal	800036fa <readi>
    800051fc:	47c1                	li	a5,16
    800051fe:	00f51b63          	bne	a0,a5,80005214 <sys_unlink+0x12e>
    if (de.inum != 0)
    80005202:	f1845783          	lhu	a5,-232(s0)
    80005206:	ebb1                	bnez	a5,8000525a <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80005208:	29c1                	addiw	s3,s3,16
    8000520a:	04c92783          	lw	a5,76(s2)
    8000520e:	fcf9efe3          	bltu	s3,a5,800051ec <sys_unlink+0x106>
    80005212:	bfb9                	j	80005170 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005214:	00002517          	auipc	a0,0x2
    80005218:	3f450513          	addi	a0,a0,1012 # 80007608 <etext+0x608>
    8000521c:	e18fb0ef          	jal	80000834 <panic>
    panic("unlink: writei");
    80005220:	00002517          	auipc	a0,0x2
    80005224:	40050513          	addi	a0,a0,1024 # 80007620 <etext+0x620>
    80005228:	e0cfb0ef          	jal	80000834 <panic>
    dp->nlink--;
    8000522c:	04a4d783          	lhu	a5,74(s1)
    80005230:	37fd                	addiw	a5,a5,-1
    80005232:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005236:	8526                	mv	a0,s1
    80005238:	834fe0ef          	jal	8000326c <iupdate>
    8000523c:	b78d                	j	8000519e <sys_unlink+0xb8>
    8000523e:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005240:	8526                	mv	a0,s1
    80005242:	b32fe0ef          	jal	80003574 <iunlockput>
  end_op();
    80005246:	bdffe0ef          	jal	80003e24 <end_op>
  return -1;
    8000524a:	557d                	li	a0,-1
    8000524c:	64ee                	ld	s1,216(sp)
}
    8000524e:	70ae                	ld	ra,232(sp)
    80005250:	740e                	ld	s0,224(sp)
    80005252:	616d                	addi	sp,sp,240
    80005254:	8082                	ret
    return -1;
    80005256:	557d                	li	a0,-1
    80005258:	bfdd                	j	8000524e <sys_unlink+0x168>
    iunlockput(ip);
    8000525a:	854a                	mv	a0,s2
    8000525c:	b18fe0ef          	jal	80003574 <iunlockput>
    goto bad;
    80005260:	694e                	ld	s2,208(sp)
    80005262:	69ae                	ld	s3,200(sp)
    80005264:	bff1                	j	80005240 <sys_unlink+0x15a>

0000000080005266 <sys_open>:

uint64
sys_open(void)
{
    80005266:	7131                	addi	sp,sp,-192
    80005268:	fd06                	sd	ra,184(sp)
    8000526a:	f922                	sd	s0,176(sp)
    8000526c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000526e:	f4c40593          	addi	a1,s0,-180
    80005272:	4505                	li	a0,1
    80005274:	ea2fd0ef          	jal	80002916 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005278:	08000613          	li	a2,128
    8000527c:	f5040593          	addi	a1,s0,-176
    80005280:	4501                	li	a0,0
    80005282:	eccfd0ef          	jal	8000294e <argstr>
    80005286:	87aa                	mv	a5,a0
    return -1;
    80005288:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    8000528a:	0a07c363          	bltz	a5,80005330 <sys_open+0xca>
    8000528e:	f526                	sd	s1,168(sp)

  begin_op();
    80005290:	b09fe0ef          	jal	80003d98 <begin_op>

  if (omode & O_CREATE) {
    80005294:	f4c42783          	lw	a5,-180(s0)
    80005298:	2007f793          	andi	a5,a5,512
    8000529c:	c3dd                	beqz	a5,80005342 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    8000529e:	4681                	li	a3,0
    800052a0:	4601                	li	a2,0
    800052a2:	4589                	li	a1,2
    800052a4:	f5040513          	addi	a0,s0,-176
    800052a8:	a5dff0ef          	jal	80004d04 <create>
    800052ac:	84aa                	mv	s1,a0
    if (ip == 0) {
    800052ae:	c549                	beqz	a0,80005338 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    800052b0:	04449703          	lh	a4,68(s1)
    800052b4:	478d                	li	a5,3
    800052b6:	00f71763          	bne	a4,a5,800052c4 <sys_open+0x5e>
    800052ba:	0464d703          	lhu	a4,70(s1)
    800052be:	47a5                	li	a5,9
    800052c0:	0ae7ee63          	bltu	a5,a4,8000537c <sys_open+0x116>
    800052c4:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    800052c6:	ee9fe0ef          	jal	800041ae <filealloc>
    800052ca:	892a                	mv	s2,a0
    800052cc:	c561                	beqz	a0,80005394 <sys_open+0x12e>
    800052ce:	ed4e                	sd	s3,152(sp)
    800052d0:	9f5ff0ef          	jal	80004cc4 <fdalloc>
    800052d4:	89aa                	mv	s3,a0
    800052d6:	0a054b63          	bltz	a0,8000538c <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    800052da:	04449703          	lh	a4,68(s1)
    800052de:	478d                	li	a5,3
    800052e0:	0cf70363          	beq	a4,a5,800053a6 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800052e4:	4789                	li	a5,2
    800052e6:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800052ea:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800052ee:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800052f2:	f4c42783          	lw	a5,-180(s0)
    800052f6:	0017f713          	andi	a4,a5,1
    800052fa:	00174713          	xori	a4,a4,1
    800052fe:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005302:	0037f713          	andi	a4,a5,3
    80005306:	00e03733          	snez	a4,a4
    8000530a:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    8000530e:	4007f793          	andi	a5,a5,1024
    80005312:	c791                	beqz	a5,8000531e <sys_open+0xb8>
    80005314:	04449703          	lh	a4,68(s1)
    80005318:	4789                	li	a5,2
    8000531a:	08f70d63          	beq	a4,a5,800053b4 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    8000531e:	8526                	mv	a0,s1
    80005320:	8aefe0ef          	jal	800033ce <iunlock>
  end_op();
    80005324:	b01fe0ef          	jal	80003e24 <end_op>

  return fd;
    80005328:	854e                	mv	a0,s3
    8000532a:	74aa                	ld	s1,168(sp)
    8000532c:	790a                	ld	s2,160(sp)
    8000532e:	69ea                	ld	s3,152(sp)
}
    80005330:	70ea                	ld	ra,184(sp)
    80005332:	744a                	ld	s0,176(sp)
    80005334:	6129                	addi	sp,sp,192
    80005336:	8082                	ret
      end_op();
    80005338:	aedfe0ef          	jal	80003e24 <end_op>
      return -1;
    8000533c:	557d                	li	a0,-1
    8000533e:	74aa                	ld	s1,168(sp)
    80005340:	bfc5                	j	80005330 <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    80005342:	f5040513          	addi	a0,s0,-176
    80005346:	875fe0ef          	jal	80003bba <namei>
    8000534a:	84aa                	mv	s1,a0
    8000534c:	c11d                	beqz	a0,80005372 <sys_open+0x10c>
    ilock(ip);
    8000534e:	fd3fd0ef          	jal	80003320 <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    80005352:	04449703          	lh	a4,68(s1)
    80005356:	4785                	li	a5,1
    80005358:	f4f71ce3          	bne	a4,a5,800052b0 <sys_open+0x4a>
    8000535c:	f4c42783          	lw	a5,-180(s0)
    80005360:	d3b5                	beqz	a5,800052c4 <sys_open+0x5e>
      iunlockput(ip);
    80005362:	8526                	mv	a0,s1
    80005364:	a10fe0ef          	jal	80003574 <iunlockput>
      end_op();
    80005368:	abdfe0ef          	jal	80003e24 <end_op>
      return -1;
    8000536c:	557d                	li	a0,-1
    8000536e:	74aa                	ld	s1,168(sp)
    80005370:	b7c1                	j	80005330 <sys_open+0xca>
      end_op();
    80005372:	ab3fe0ef          	jal	80003e24 <end_op>
      return -1;
    80005376:	557d                	li	a0,-1
    80005378:	74aa                	ld	s1,168(sp)
    8000537a:	bf5d                	j	80005330 <sys_open+0xca>
    iunlockput(ip);
    8000537c:	8526                	mv	a0,s1
    8000537e:	9f6fe0ef          	jal	80003574 <iunlockput>
    end_op();
    80005382:	aa3fe0ef          	jal	80003e24 <end_op>
    return -1;
    80005386:	557d                	li	a0,-1
    80005388:	74aa                	ld	s1,168(sp)
    8000538a:	b75d                	j	80005330 <sys_open+0xca>
      fileclose(f);
    8000538c:	854a                	mv	a0,s2
    8000538e:	ec5fe0ef          	jal	80004252 <fileclose>
    80005392:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005394:	8526                	mv	a0,s1
    80005396:	9defe0ef          	jal	80003574 <iunlockput>
    end_op();
    8000539a:	a8bfe0ef          	jal	80003e24 <end_op>
    return -1;
    8000539e:	557d                	li	a0,-1
    800053a0:	74aa                	ld	s1,168(sp)
    800053a2:	790a                	ld	s2,160(sp)
    800053a4:	b771                	j	80005330 <sys_open+0xca>
    f->type = FD_DEVICE;
    800053a6:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    800053aa:	04649783          	lh	a5,70(s1)
    800053ae:	02f91223          	sh	a5,36(s2)
    800053b2:	bf35                	j	800052ee <sys_open+0x88>
    itrunc(ip);
    800053b4:	8526                	mv	a0,s1
    800053b6:	858fe0ef          	jal	8000340e <itrunc>
    800053ba:	b795                	j	8000531e <sys_open+0xb8>

00000000800053bc <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800053bc:	7175                	addi	sp,sp,-144
    800053be:	e506                	sd	ra,136(sp)
    800053c0:	e122                	sd	s0,128(sp)
    800053c2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800053c4:	9d5fe0ef          	jal	80003d98 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    800053c8:	08000613          	li	a2,128
    800053cc:	f7040593          	addi	a1,s0,-144
    800053d0:	4501                	li	a0,0
    800053d2:	d7cfd0ef          	jal	8000294e <argstr>
    800053d6:	02054363          	bltz	a0,800053fc <sys_mkdir+0x40>
    800053da:	4681                	li	a3,0
    800053dc:	4601                	li	a2,0
    800053de:	4585                	li	a1,1
    800053e0:	f7040513          	addi	a0,s0,-144
    800053e4:	921ff0ef          	jal	80004d04 <create>
    800053e8:	c911                	beqz	a0,800053fc <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800053ea:	98afe0ef          	jal	80003574 <iunlockput>
  end_op();
    800053ee:	a37fe0ef          	jal	80003e24 <end_op>
  return 0;
    800053f2:	4501                	li	a0,0
}
    800053f4:	60aa                	ld	ra,136(sp)
    800053f6:	640a                	ld	s0,128(sp)
    800053f8:	6149                	addi	sp,sp,144
    800053fa:	8082                	ret
    end_op();
    800053fc:	a29fe0ef          	jal	80003e24 <end_op>
    return -1;
    80005400:	557d                	li	a0,-1
    80005402:	bfcd                	j	800053f4 <sys_mkdir+0x38>

0000000080005404 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005404:	7135                	addi	sp,sp,-160
    80005406:	ed06                	sd	ra,152(sp)
    80005408:	e922                	sd	s0,144(sp)
    8000540a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000540c:	98dfe0ef          	jal	80003d98 <begin_op>
  argint(1, &major);
    80005410:	f6c40593          	addi	a1,s0,-148
    80005414:	4505                	li	a0,1
    80005416:	d00fd0ef          	jal	80002916 <argint>
  argint(2, &minor);
    8000541a:	f6840593          	addi	a1,s0,-152
    8000541e:	4509                	li	a0,2
    80005420:	cf6fd0ef          	jal	80002916 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005424:	08000613          	li	a2,128
    80005428:	f7040593          	addi	a1,s0,-144
    8000542c:	4501                	li	a0,0
    8000542e:	d20fd0ef          	jal	8000294e <argstr>
    80005432:	02054563          	bltz	a0,8000545c <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    80005436:	f6841683          	lh	a3,-152(s0)
    8000543a:	f6c41603          	lh	a2,-148(s0)
    8000543e:	458d                	li	a1,3
    80005440:	f7040513          	addi	a0,s0,-144
    80005444:	8c1ff0ef          	jal	80004d04 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005448:	c911                	beqz	a0,8000545c <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000544a:	92afe0ef          	jal	80003574 <iunlockput>
  end_op();
    8000544e:	9d7fe0ef          	jal	80003e24 <end_op>
  return 0;
    80005452:	4501                	li	a0,0
}
    80005454:	60ea                	ld	ra,152(sp)
    80005456:	644a                	ld	s0,144(sp)
    80005458:	610d                	addi	sp,sp,160
    8000545a:	8082                	ret
    end_op();
    8000545c:	9c9fe0ef          	jal	80003e24 <end_op>
    return -1;
    80005460:	557d                	li	a0,-1
    80005462:	bfcd                	j	80005454 <sys_mknod+0x50>

0000000080005464 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005464:	7135                	addi	sp,sp,-160
    80005466:	ed06                	sd	ra,152(sp)
    80005468:	e922                	sd	s0,144(sp)
    8000546a:	e14a                	sd	s2,128(sp)
    8000546c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000546e:	cdafc0ef          	jal	80001948 <myproc>
    80005472:	892a                	mv	s2,a0

  begin_op();
    80005474:	925fe0ef          	jal	80003d98 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    80005478:	08000613          	li	a2,128
    8000547c:	f6040593          	addi	a1,s0,-160
    80005480:	4501                	li	a0,0
    80005482:	cccfd0ef          	jal	8000294e <argstr>
    80005486:	04054363          	bltz	a0,800054cc <sys_chdir+0x68>
    8000548a:	e526                	sd	s1,136(sp)
    8000548c:	f6040513          	addi	a0,s0,-160
    80005490:	f2afe0ef          	jal	80003bba <namei>
    80005494:	84aa                	mv	s1,a0
    80005496:	c915                	beqz	a0,800054ca <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005498:	e89fd0ef          	jal	80003320 <ilock>
  if (ip->type != T_DIR) {
    8000549c:	04449703          	lh	a4,68(s1)
    800054a0:	4785                	li	a5,1
    800054a2:	02f71963          	bne	a4,a5,800054d4 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800054a6:	8526                	mv	a0,s1
    800054a8:	f27fd0ef          	jal	800033ce <iunlock>
  iput(p->cwd);
    800054ac:	15093503          	ld	a0,336(s2)
    800054b0:	ff3fd0ef          	jal	800034a2 <iput>
  end_op();
    800054b4:	971fe0ef          	jal	80003e24 <end_op>
  p->cwd = ip;
    800054b8:	14993823          	sd	s1,336(s2)
  return 0;
    800054bc:	4501                	li	a0,0
    800054be:	64aa                	ld	s1,136(sp)
}
    800054c0:	60ea                	ld	ra,152(sp)
    800054c2:	644a                	ld	s0,144(sp)
    800054c4:	690a                	ld	s2,128(sp)
    800054c6:	610d                	addi	sp,sp,160
    800054c8:	8082                	ret
    800054ca:	64aa                	ld	s1,136(sp)
    end_op();
    800054cc:	959fe0ef          	jal	80003e24 <end_op>
    return -1;
    800054d0:	557d                	li	a0,-1
    800054d2:	b7fd                	j	800054c0 <sys_chdir+0x5c>
    iunlockput(ip);
    800054d4:	8526                	mv	a0,s1
    800054d6:	89efe0ef          	jal	80003574 <iunlockput>
    end_op();
    800054da:	94bfe0ef          	jal	80003e24 <end_op>
    return -1;
    800054de:	557d                	li	a0,-1
    800054e0:	64aa                	ld	s1,136(sp)
    800054e2:	bff9                	j	800054c0 <sys_chdir+0x5c>

00000000800054e4 <sys_exec>:

uint64
sys_exec(void)
{
    800054e4:	7105                	addi	sp,sp,-480
    800054e6:	ef86                	sd	ra,472(sp)
    800054e8:	eba2                	sd	s0,464(sp)
    800054ea:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800054ec:	e2840593          	addi	a1,s0,-472
    800054f0:	4505                	li	a0,1
    800054f2:	c40fd0ef          	jal	80002932 <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    800054f6:	08000613          	li	a2,128
    800054fa:	f3040593          	addi	a1,s0,-208
    800054fe:	4501                	li	a0,0
    80005500:	c4efd0ef          	jal	8000294e <argstr>
    80005504:	87aa                	mv	a5,a0
    return -1;
    80005506:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    80005508:	0e07c063          	bltz	a5,800055e8 <sys_exec+0x104>
    8000550c:	e7a6                	sd	s1,456(sp)
    8000550e:	e3ca                	sd	s2,448(sp)
    80005510:	ff4e                	sd	s3,440(sp)
    80005512:	fb52                	sd	s4,432(sp)
    80005514:	f756                	sd	s5,424(sp)
    80005516:	f35a                	sd	s6,416(sp)
    80005518:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000551a:	e3040a13          	addi	s4,s0,-464
    8000551e:	10000613          	li	a2,256
    80005522:	4581                	li	a1,0
    80005524:	8552                	mv	a0,s4
    80005526:	fc2fb0ef          	jal	80000ce8 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    8000552a:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    8000552c:	89d2                	mv	s3,s4
    8000552e:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005530:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005534:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    80005536:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    8000553a:	00391513          	slli	a0,s2,0x3
    8000553e:	85d6                	mv	a1,s5
    80005540:	e2843783          	ld	a5,-472(s0)
    80005544:	953e                	add	a0,a0,a5
    80005546:	b44fd0ef          	jal	8000288a <fetchaddr>
    8000554a:	02054663          	bltz	a0,80005576 <sys_exec+0x92>
    if (uarg == 0) {
    8000554e:	e2043783          	ld	a5,-480(s0)
    80005552:	c7a1                	beqz	a5,8000559a <sys_exec+0xb6>
    argv[i] = kalloc();
    80005554:	dfafb0ef          	jal	80000b4e <kalloc>
    80005558:	85aa                	mv	a1,a0
    8000555a:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    8000555e:	cd01                	beqz	a0,80005576 <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005560:	865a                	mv	a2,s6
    80005562:	e2043503          	ld	a0,-480(s0)
    80005566:	b6efd0ef          	jal	800028d4 <fetchstr>
    8000556a:	00054663          	bltz	a0,80005576 <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    8000556e:	0905                	addi	s2,s2,1
    80005570:	09a1                	addi	s3,s3,8
    80005572:	fd7914e3          	bne	s2,s7,8000553a <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005576:	100a0a13          	addi	s4,s4,256
    8000557a:	6088                	ld	a0,0(s1)
    8000557c:	cd31                	beqz	a0,800055d8 <sys_exec+0xf4>
    kfree(argv[i]);
    8000557e:	ce8fb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005582:	04a1                	addi	s1,s1,8
    80005584:	ff449be3          	bne	s1,s4,8000557a <sys_exec+0x96>
  return -1;
    80005588:	557d                	li	a0,-1
    8000558a:	64be                	ld	s1,456(sp)
    8000558c:	691e                	ld	s2,448(sp)
    8000558e:	79fa                	ld	s3,440(sp)
    80005590:	7a5a                	ld	s4,432(sp)
    80005592:	7aba                	ld	s5,424(sp)
    80005594:	7b1a                	ld	s6,416(sp)
    80005596:	6bfa                	ld	s7,408(sp)
    80005598:	a881                	j	800055e8 <sys_exec+0x104>
      argv[i] = 0;
    8000559a:	0009079b          	sext.w	a5,s2
    8000559e:	e3040593          	addi	a1,s0,-464
    800055a2:	078e                	slli	a5,a5,0x3
    800055a4:	97ae                	add	a5,a5,a1
    800055a6:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    800055aa:	f3040513          	addi	a0,s0,-208
    800055ae:	b62ff0ef          	jal	80004910 <kexec>
    800055b2:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055b4:	100a0a13          	addi	s4,s4,256
    800055b8:	6088                	ld	a0,0(s1)
    800055ba:	c511                	beqz	a0,800055c6 <sys_exec+0xe2>
    kfree(argv[i]);
    800055bc:	caafb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055c0:	04a1                	addi	s1,s1,8
    800055c2:	ff449be3          	bne	s1,s4,800055b8 <sys_exec+0xd4>
  return ret;
    800055c6:	854a                	mv	a0,s2
    800055c8:	64be                	ld	s1,456(sp)
    800055ca:	691e                	ld	s2,448(sp)
    800055cc:	79fa                	ld	s3,440(sp)
    800055ce:	7a5a                	ld	s4,432(sp)
    800055d0:	7aba                	ld	s5,424(sp)
    800055d2:	7b1a                	ld	s6,416(sp)
    800055d4:	6bfa                	ld	s7,408(sp)
    800055d6:	a809                	j	800055e8 <sys_exec+0x104>
  return -1;
    800055d8:	557d                	li	a0,-1
    800055da:	64be                	ld	s1,456(sp)
    800055dc:	691e                	ld	s2,448(sp)
    800055de:	79fa                	ld	s3,440(sp)
    800055e0:	7a5a                	ld	s4,432(sp)
    800055e2:	7aba                	ld	s5,424(sp)
    800055e4:	7b1a                	ld	s6,416(sp)
    800055e6:	6bfa                	ld	s7,408(sp)
}
    800055e8:	60fe                	ld	ra,472(sp)
    800055ea:	645e                	ld	s0,464(sp)
    800055ec:	613d                	addi	sp,sp,480
    800055ee:	8082                	ret

00000000800055f0 <sys_pipe>:

uint64
sys_pipe(void)
{
    800055f0:	7139                	addi	sp,sp,-64
    800055f2:	fc06                	sd	ra,56(sp)
    800055f4:	f822                	sd	s0,48(sp)
    800055f6:	f426                	sd	s1,40(sp)
    800055f8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800055fa:	b4efc0ef          	jal	80001948 <myproc>
    800055fe:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005600:	fd840593          	addi	a1,s0,-40
    80005604:	4501                	li	a0,0
    80005606:	b2cfd0ef          	jal	80002932 <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    8000560a:	fc840593          	addi	a1,s0,-56
    8000560e:	fd040513          	addi	a0,s0,-48
    80005612:	f7ffe0ef          	jal	80004590 <pipealloc>
    return -1;
    80005616:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    80005618:	0a054963          	bltz	a0,800056ca <sys_pipe+0xda>
  fd0 = -1;
    8000561c:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    80005620:	fd043503          	ld	a0,-48(s0)
    80005624:	ea0ff0ef          	jal	80004cc4 <fdalloc>
    80005628:	fca42223          	sw	a0,-60(s0)
    8000562c:	08054663          	bltz	a0,800056b8 <sys_pipe+0xc8>
    80005630:	fc843503          	ld	a0,-56(s0)
    80005634:	e90ff0ef          	jal	80004cc4 <fdalloc>
    80005638:	fca42023          	sw	a0,-64(s0)
    8000563c:	06054463          	bltz	a0,800056a4 <sys_pipe+0xb4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005640:	4711                	li	a4,4
    80005642:	fc440693          	addi	a3,s0,-60
    80005646:	fd843603          	ld	a2,-40(s0)
    8000564a:	64ac                	ld	a1,72(s1)
    8000564c:	68a8                	ld	a0,80(s1)
    8000564e:	f35fb0ef          	jal	80001582 <copyout>
    80005652:	00054f63          	bltz	a0,80005670 <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    80005656:	4711                	li	a4,4
    80005658:	fc040693          	addi	a3,s0,-64
    8000565c:	fd843603          	ld	a2,-40(s0)
    80005660:	963a                	add	a2,a2,a4
    80005662:	64ac                	ld	a1,72(s1)
    80005664:	68a8                	ld	a0,80(s1)
    80005666:	f1dfb0ef          	jal	80001582 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000566a:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    8000566c:	04055f63          	bgez	a0,800056ca <sys_pipe+0xda>
    p->ofile[fd0] = 0;
    80005670:	fc442783          	lw	a5,-60(s0)
    80005674:	078e                	slli	a5,a5,0x3
    80005676:	0d078793          	addi	a5,a5,208
    8000567a:	97a6                	add	a5,a5,s1
    8000567c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005680:	fc042783          	lw	a5,-64(s0)
    80005684:	078e                	slli	a5,a5,0x3
    80005686:	0d078793          	addi	a5,a5,208
    8000568a:	94be                	add	s1,s1,a5
    8000568c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005690:	fd043503          	ld	a0,-48(s0)
    80005694:	bbffe0ef          	jal	80004252 <fileclose>
    fileclose(wf);
    80005698:	fc843503          	ld	a0,-56(s0)
    8000569c:	bb7fe0ef          	jal	80004252 <fileclose>
    return -1;
    800056a0:	57fd                	li	a5,-1
    800056a2:	a025                	j	800056ca <sys_pipe+0xda>
    if (fd0 >= 0)
    800056a4:	fc442783          	lw	a5,-60(s0)
    800056a8:	0007c863          	bltz	a5,800056b8 <sys_pipe+0xc8>
      p->ofile[fd0] = 0;
    800056ac:	078e                	slli	a5,a5,0x3
    800056ae:	0d078793          	addi	a5,a5,208
    800056b2:	97a6                	add	a5,a5,s1
    800056b4:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800056b8:	fd043503          	ld	a0,-48(s0)
    800056bc:	b97fe0ef          	jal	80004252 <fileclose>
    fileclose(wf);
    800056c0:	fc843503          	ld	a0,-56(s0)
    800056c4:	b8ffe0ef          	jal	80004252 <fileclose>
    return -1;
    800056c8:	57fd                	li	a5,-1
}
    800056ca:	853e                	mv	a0,a5
    800056cc:	70e2                	ld	ra,56(sp)
    800056ce:	7442                	ld	s0,48(sp)
    800056d0:	74a2                	ld	s1,40(sp)
    800056d2:	6121                	addi	sp,sp,64
    800056d4:	8082                	ret
	...

00000000800056e0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800056e0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800056e2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800056e4:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    800056e6:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800056e8:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800056ea:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800056ec:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800056ee:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800056f0:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800056f2:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800056f4:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800056f6:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800056f8:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800056fa:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800056fc:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800056fe:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005700:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005702:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005704:	8a6fd0ef          	jal	800027aa <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005708:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000570a:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000570c:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    8000570e:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005710:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005712:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005714:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005716:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005718:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000571a:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000571c:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    8000571e:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005720:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005722:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005724:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005726:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005728:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000572a:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000572c:	10200073          	sret
    80005730:	0001                	nop
    80005732:	00000013          	nop
    80005736:	00000013          	nop
    8000573a:	00000013          	nop

000000008000573e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000573e:	1141                	addi	sp,sp,-16
    80005740:	e406                	sd	ra,8(sp)
    80005742:	e022                	sd	s0,0(sp)
    80005744:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(volatile uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80005746:	0c000737          	lui	a4,0xc000
    8000574a:	4785                	li	a5,1
    8000574c:	d71c                	sw	a5,40(a4)
  *(volatile uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    8000574e:	c35c                	sw	a5,4(a4)
}
    80005750:	60a2                	ld	ra,8(sp)
    80005752:	6402                	ld	s0,0(sp)
    80005754:	0141                	addi	sp,sp,16
    80005756:	8082                	ret

0000000080005758 <plicinithart>:

void
plicinithart(void)
{
    80005758:	1141                	addi	sp,sp,-16
    8000575a:	e406                	sd	ra,8(sp)
    8000575c:	e022                	sd	s0,0(sp)
    8000575e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005760:	9b4fc0ef          	jal	80001914 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(volatile uint32 *)PLIC_SENABLE(hart) =
    80005764:	0085179b          	slliw	a5,a0,0x8
    80005768:	0c002737          	lui	a4,0xc002
    8000576c:	08070713          	addi	a4,a4,128 # c002080 <_entry-0x73ffdf80>
    80005770:	97ba                	add	a5,a5,a4
    80005772:	40200713          	li	a4,1026
    80005776:	c398                	sw	a4,0(a5)
    (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);

  // set this hart's S-mode priority threshold to 0.
  *(volatile uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005778:	00d5151b          	slliw	a0,a0,0xd
    8000577c:	0c2017b7          	lui	a5,0xc201
    80005780:	953e                	add	a0,a0,a5
    80005782:	00052023          	sw	zero,0(a0)
}
    80005786:	60a2                	ld	ra,8(sp)
    80005788:	6402                	ld	s0,0(sp)
    8000578a:	0141                	addi	sp,sp,16
    8000578c:	8082                	ret

000000008000578e <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000578e:	1141                	addi	sp,sp,-16
    80005790:	e406                	sd	ra,8(sp)
    80005792:	e022                	sd	s0,0(sp)
    80005794:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005796:	97efc0ef          	jal	80001914 <cpuid>
  int irq = *(volatile uint32 *)PLIC_SCLAIM(hart);
    8000579a:	00d5151b          	slliw	a0,a0,0xd
    8000579e:	0c2017b7          	lui	a5,0xc201
    800057a2:	0791                	addi	a5,a5,4 # c201004 <_entry-0x73dfeffc>
    800057a4:	953e                	add	a0,a0,a5
    800057a6:	4108                	lw	a0,0(a0)
  return irq;
}
    800057a8:	60a2                	ld	ra,8(sp)
    800057aa:	6402                	ld	s0,0(sp)
    800057ac:	0141                	addi	sp,sp,16
    800057ae:	8082                	ret

00000000800057b0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800057b0:	1101                	addi	sp,sp,-32
    800057b2:	ec06                	sd	ra,24(sp)
    800057b4:	e822                	sd	s0,16(sp)
    800057b6:	e426                	sd	s1,8(sp)
    800057b8:	1000                	addi	s0,sp,32
    800057ba:	84aa                	mv	s1,a0
  int hart = cpuid();
    800057bc:	958fc0ef          	jal	80001914 <cpuid>
  *(volatile uint32 *)PLIC_SCLAIM(hart) = irq;
    800057c0:	00d5179b          	slliw	a5,a0,0xd
    800057c4:	0c201737          	lui	a4,0xc201
    800057c8:	0711                	addi	a4,a4,4 # c201004 <_entry-0x73dfeffc>
    800057ca:	97ba                	add	a5,a5,a4
    800057cc:	c384                	sw	s1,0(a5)
}
    800057ce:	60e2                	ld	ra,24(sp)
    800057d0:	6442                	ld	s0,16(sp)
    800057d2:	64a2                	ld	s1,8(sp)
    800057d4:	6105                	addi	sp,sp,32
    800057d6:	8082                	ret

00000000800057d8 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800057d8:	1141                	addi	sp,sp,-16
    800057da:	e406                	sd	ra,8(sp)
    800057dc:	e022                	sd	s0,0(sp)
    800057de:	0800                	addi	s0,sp,16
  if (i >= NUM)
    800057e0:	479d                	li	a5,7
    800057e2:	04a7ca63          	blt	a5,a0,80005836 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    800057e6:	0001e797          	auipc	a5,0x1e
    800057ea:	f5278793          	addi	a5,a5,-174 # 80023738 <disk>
    800057ee:	97aa                	add	a5,a5,a0
    800057f0:	0187c783          	lbu	a5,24(a5)
    800057f4:	e7b9                	bnez	a5,80005842 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800057f6:	00451693          	slli	a3,a0,0x4
    800057fa:	0001e797          	auipc	a5,0x1e
    800057fe:	f3e78793          	addi	a5,a5,-194 # 80023738 <disk>
    80005802:	6398                	ld	a4,0(a5)
    80005804:	9736                	add	a4,a4,a3
    80005806:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000580a:	6398                	ld	a4,0(a5)
    8000580c:	9736                	add	a4,a4,a3
    8000580e:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005812:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005816:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000581a:	97aa                	add	a5,a5,a0
    8000581c:	4705                	li	a4,1
    8000581e:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005822:	0001e517          	auipc	a0,0x1e
    80005826:	f2e50513          	addi	a0,a0,-210 # 80023750 <disk+0x18>
    8000582a:	849fc0ef          	jal	80002072 <wakeup>
}
    8000582e:	60a2                	ld	ra,8(sp)
    80005830:	6402                	ld	s0,0(sp)
    80005832:	0141                	addi	sp,sp,16
    80005834:	8082                	ret
    panic("free_desc 1");
    80005836:	00002517          	auipc	a0,0x2
    8000583a:	dfa50513          	addi	a0,a0,-518 # 80007630 <etext+0x630>
    8000583e:	ff7fa0ef          	jal	80000834 <panic>
    panic("free_desc 2");
    80005842:	00002517          	auipc	a0,0x2
    80005846:	dfe50513          	addi	a0,a0,-514 # 80007640 <etext+0x640>
    8000584a:	febfa0ef          	jal	80000834 <panic>

000000008000584e <virtio_disk_init>:
{
    8000584e:	1101                	addi	sp,sp,-32
    80005850:	ec06                	sd	ra,24(sp)
    80005852:	e822                	sd	s0,16(sp)
    80005854:	e426                	sd	s1,8(sp)
    80005856:	e04a                	sd	s2,0(sp)
    80005858:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000585a:	00002597          	auipc	a1,0x2
    8000585e:	df658593          	addi	a1,a1,-522 # 80007650 <etext+0x650>
    80005862:	0001e517          	auipc	a0,0x1e
    80005866:	ffe50513          	addi	a0,a0,-2 # 80023860 <disk+0x128>
    8000586a:	b3efb0ef          	jal	80000ba8 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000586e:	100017b7          	lui	a5,0x10001
    80005872:	4398                	lw	a4,0(a5)
    80005874:	2701                	sext.w	a4,a4
    80005876:	747277b7          	lui	a5,0x74727
    8000587a:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000587e:	14f71863          	bne	a4,a5,800059ce <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005882:	100017b7          	lui	a5,0x10001
    80005886:	43dc                	lw	a5,4(a5)
    80005888:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000588a:	4709                	li	a4,2
    8000588c:	14e79163          	bne	a5,a4,800059ce <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005890:	100017b7          	lui	a5,0x10001
    80005894:	479c                	lw	a5,8(a5)
    80005896:	2781                	sext.w	a5,a5
    80005898:	12e79b63          	bne	a5,a4,800059ce <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    8000589c:	100017b7          	lui	a5,0x10001
    800058a0:	47d8                	lw	a4,12(a5)
    800058a2:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800058a4:	554d47b7          	lui	a5,0x554d4
    800058a8:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800058ac:	12f71163          	bne	a4,a5,800059ce <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    800058b0:	100017b7          	lui	a5,0x10001
    800058b4:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800058b8:	4705                	li	a4,1
    800058ba:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800058bc:	470d                	li	a4,3
    800058be:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800058c0:	10001737          	lui	a4,0x10001
    800058c4:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800058c6:	c7ffe6b7          	lui	a3,0xc7ffe
    800058ca:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fdace7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800058ce:	8f75                	and	a4,a4,a3
    800058d0:	100016b7          	lui	a3,0x10001
    800058d4:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800058d6:	472d                	li	a4,11
    800058d8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800058da:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800058de:	439c                	lw	a5,0(a5)
    800058e0:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800058e4:	8ba1                	andi	a5,a5,8
    800058e6:	0e078a63          	beqz	a5,800059da <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800058ea:	100017b7          	lui	a5,0x10001
    800058ee:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    800058f2:	43fc                	lw	a5,68(a5)
    800058f4:	2781                	sext.w	a5,a5
    800058f6:	0e079863          	bnez	a5,800059e6 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800058fa:	100017b7          	lui	a5,0x10001
    800058fe:	5bdc                	lw	a5,52(a5)
    80005900:	2781                	sext.w	a5,a5
  if (max == 0)
    80005902:	0e078863          	beqz	a5,800059f2 <virtio_disk_init+0x1a4>
  if (max < NUM)
    80005906:	471d                	li	a4,7
    80005908:	0ef77b63          	bgeu	a4,a5,800059fe <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    8000590c:	a42fb0ef          	jal	80000b4e <kalloc>
    80005910:	0001e497          	auipc	s1,0x1e
    80005914:	e2848493          	addi	s1,s1,-472 # 80023738 <disk>
    80005918:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    8000591a:	a34fb0ef          	jal	80000b4e <kalloc>
    8000591e:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005920:	a2efb0ef          	jal	80000b4e <kalloc>
    80005924:	87aa                	mv	a5,a0
    80005926:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005928:	6088                	ld	a0,0(s1)
    8000592a:	0e050063          	beqz	a0,80005a0a <virtio_disk_init+0x1bc>
    8000592e:	0001e717          	auipc	a4,0x1e
    80005932:	e1273703          	ld	a4,-494(a4) # 80023740 <disk+0x8>
    80005936:	cb71                	beqz	a4,80005a0a <virtio_disk_init+0x1bc>
    80005938:	cbe9                	beqz	a5,80005a0a <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    8000593a:	6605                	lui	a2,0x1
    8000593c:	4581                	li	a1,0
    8000593e:	baafb0ef          	jal	80000ce8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005942:	0001e497          	auipc	s1,0x1e
    80005946:	df648493          	addi	s1,s1,-522 # 80023738 <disk>
    8000594a:	6605                	lui	a2,0x1
    8000594c:	4581                	li	a1,0
    8000594e:	6488                	ld	a0,8(s1)
    80005950:	b98fb0ef          	jal	80000ce8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005954:	6605                	lui	a2,0x1
    80005956:	4581                	li	a1,0
    80005958:	6888                	ld	a0,16(s1)
    8000595a:	b8efb0ef          	jal	80000ce8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000595e:	100017b7          	lui	a5,0x10001
    80005962:	4721                	li	a4,8
    80005964:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005966:	4098                	lw	a4,0(s1)
    80005968:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000596c:	40d8                	lw	a4,4(s1)
    8000596e:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005972:	649c                	ld	a5,8(s1)
    80005974:	0007869b          	sext.w	a3,a5
    80005978:	10001737          	lui	a4,0x10001
    8000597c:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005980:	9781                	srai	a5,a5,0x20
    80005982:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005986:	689c                	ld	a5,16(s1)
    80005988:	0007869b          	sext.w	a3,a5
    8000598c:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005990:	9781                	srai	a5,a5,0x20
    80005992:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005996:	4785                	li	a5,1
    80005998:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    8000599a:	00f48c23          	sb	a5,24(s1)
    8000599e:	00f48ca3          	sb	a5,25(s1)
    800059a2:	00f48d23          	sb	a5,26(s1)
    800059a6:	00f48da3          	sb	a5,27(s1)
    800059aa:	00f48e23          	sb	a5,28(s1)
    800059ae:	00f48ea3          	sb	a5,29(s1)
    800059b2:	00f48f23          	sb	a5,30(s1)
    800059b6:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800059ba:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800059be:	07272823          	sw	s2,112(a4)
}
    800059c2:	60e2                	ld	ra,24(sp)
    800059c4:	6442                	ld	s0,16(sp)
    800059c6:	64a2                	ld	s1,8(sp)
    800059c8:	6902                	ld	s2,0(sp)
    800059ca:	6105                	addi	sp,sp,32
    800059cc:	8082                	ret
    panic("could not find virtio disk");
    800059ce:	00002517          	auipc	a0,0x2
    800059d2:	c9250513          	addi	a0,a0,-878 # 80007660 <etext+0x660>
    800059d6:	e5ffa0ef          	jal	80000834 <panic>
    panic("virtio disk FEATURES_OK unset");
    800059da:	00002517          	auipc	a0,0x2
    800059de:	ca650513          	addi	a0,a0,-858 # 80007680 <etext+0x680>
    800059e2:	e53fa0ef          	jal	80000834 <panic>
    panic("virtio disk should not be ready");
    800059e6:	00002517          	auipc	a0,0x2
    800059ea:	cba50513          	addi	a0,a0,-838 # 800076a0 <etext+0x6a0>
    800059ee:	e47fa0ef          	jal	80000834 <panic>
    panic("virtio disk has no queue 0");
    800059f2:	00002517          	auipc	a0,0x2
    800059f6:	cce50513          	addi	a0,a0,-818 # 800076c0 <etext+0x6c0>
    800059fa:	e3bfa0ef          	jal	80000834 <panic>
    panic("virtio disk max queue too short");
    800059fe:	00002517          	auipc	a0,0x2
    80005a02:	ce250513          	addi	a0,a0,-798 # 800076e0 <etext+0x6e0>
    80005a06:	e2ffa0ef          	jal	80000834 <panic>
    panic("virtio disk kalloc");
    80005a0a:	00002517          	auipc	a0,0x2
    80005a0e:	cf650513          	addi	a0,a0,-778 # 80007700 <etext+0x700>
    80005a12:	e23fa0ef          	jal	80000834 <panic>

0000000080005a16 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005a16:	711d                	addi	sp,sp,-96
    80005a18:	ec86                	sd	ra,88(sp)
    80005a1a:	e8a2                	sd	s0,80(sp)
    80005a1c:	e4a6                	sd	s1,72(sp)
    80005a1e:	e0ca                	sd	s2,64(sp)
    80005a20:	fc4e                	sd	s3,56(sp)
    80005a22:	f852                	sd	s4,48(sp)
    80005a24:	f456                	sd	s5,40(sp)
    80005a26:	f05a                	sd	s6,32(sp)
    80005a28:	ec5e                	sd	s7,24(sp)
    80005a2a:	e862                	sd	s8,16(sp)
    80005a2c:	1080                	addi	s0,sp,96
    80005a2e:	89aa                	mv	s3,a0
    80005a30:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005a32:	00c52b83          	lw	s7,12(a0)
    80005a36:	001b9b9b          	slliw	s7,s7,0x1
    80005a3a:	1b82                	slli	s7,s7,0x20
    80005a3c:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005a40:	0001e517          	auipc	a0,0x1e
    80005a44:	e2050513          	addi	a0,a0,-480 # 80023860 <disk+0x128>
    80005a48:	9e0fb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < NUM; i++) {
    80005a4c:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005a4e:	0001ea97          	auipc	s5,0x1e
    80005a52:	ceaa8a93          	addi	s5,s5,-790 # 80023738 <disk>
  for (int i = 0; i < 3; i++) {
    80005a56:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005a58:	5c7d                	li	s8,-1
    80005a5a:	a8a5                	j	80005ad2 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80005a5c:	00fa8733          	add	a4,s5,a5
    80005a60:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005a64:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005a66:	0207c563          	bltz	a5,80005a90 <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    80005a6a:	2905                	addiw	s2,s2,1
    80005a6c:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005a6e:	07490663          	beq	s2,s4,80005ada <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80005a72:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005a74:	0001e717          	auipc	a4,0x1e
    80005a78:	cc470713          	addi	a4,a4,-828 # 80023738 <disk>
    80005a7c:	4781                	li	a5,0
    if (disk.free[i]) {
    80005a7e:	01874683          	lbu	a3,24(a4)
    80005a82:	fee9                	bnez	a3,80005a5c <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    80005a84:	2785                	addiw	a5,a5,1
    80005a86:	0705                	addi	a4,a4,1
    80005a88:	fe979be3          	bne	a5,s1,80005a7e <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005a8c:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    80005a90:	01205d63          	blez	s2,80005aaa <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005a94:	fa042503          	lw	a0,-96(s0)
    80005a98:	d41ff0ef          	jal	800057d8 <free_desc>
      for (int j = 0; j < i; j++)
    80005a9c:	4785                	li	a5,1
    80005a9e:	0127d663          	bge	a5,s2,80005aaa <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005aa2:	fa442503          	lw	a0,-92(s0)
    80005aa6:	d33ff0ef          	jal	800057d8 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005aaa:	0001e517          	auipc	a0,0x1e
    80005aae:	ca650513          	addi	a0,a0,-858 # 80023750 <disk+0x18>
    80005ab2:	d54fc0ef          	jal	80002006 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005ab6:	0001e517          	auipc	a0,0x1e
    80005aba:	daa50513          	addi	a0,a0,-598 # 80023860 <disk+0x128>
    80005abe:	9f2fb0ef          	jal	80000cb0 <release>
    sleep();
    80005ac2:	d80fc0ef          	jal	80002042 <sleep>
    acquire(&disk.vdisk_lock);
    80005ac6:	0001e517          	auipc	a0,0x1e
    80005aca:	d9a50513          	addi	a0,a0,-614 # 80023860 <disk+0x128>
    80005ace:	95afb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < 3; i++) {
    80005ad2:	fa040613          	addi	a2,s0,-96
    80005ad6:	4901                	li	s2,0
    80005ad8:	bf69                	j	80005a72 <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005ada:	fa042503          	lw	a0,-96(s0)
    80005ade:	00451693          	slli	a3,a0,0x4

  if (write)
    80005ae2:	0001e797          	auipc	a5,0x1e
    80005ae6:	c5678793          	addi	a5,a5,-938 # 80023738 <disk>
    80005aea:	00451713          	slli	a4,a0,0x4
    80005aee:	0a070713          	addi	a4,a4,160
    80005af2:	973e                	add	a4,a4,a5
    80005af4:	01603633          	snez	a2,s6
    80005af8:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005afa:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005afe:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005b02:	6398                	ld	a4,0(a5)
    80005b04:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b06:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005b0a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005b0c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005b0e:	6390                	ld	a2,0(a5)
    80005b10:	00d60833          	add	a6,a2,a3
    80005b14:	4741                	li	a4,16
    80005b16:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005b1a:	4585                	li	a1,1
    80005b1c:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005b20:	fa442703          	lw	a4,-92(s0)
    80005b24:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005b28:	0712                	slli	a4,a4,0x4
    80005b2a:	963a                	add	a2,a2,a4
    80005b2c:	05898813          	addi	a6,s3,88
    80005b30:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005b34:	0007b883          	ld	a7,0(a5)
    80005b38:	9746                	add	a4,a4,a7
    80005b3a:	40000613          	li	a2,1024
    80005b3e:	c710                	sw	a2,8(a4)
  if (write)
    80005b40:	001b3613          	seqz	a2,s6
    80005b44:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005b48:	8e4d                	or	a2,a2,a1
    80005b4a:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005b4e:	fa842603          	lw	a2,-88(s0)
    80005b52:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005b56:	00451813          	slli	a6,a0,0x4
    80005b5a:	02080813          	addi	a6,a6,32
    80005b5e:	983e                	add	a6,a6,a5
    80005b60:	577d                	li	a4,-1
    80005b62:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005b66:	0612                	slli	a2,a2,0x4
    80005b68:	98b2                	add	a7,a7,a2
    80005b6a:	03068713          	addi	a4,a3,48
    80005b6e:	973e                	add	a4,a4,a5
    80005b70:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005b74:	6398                	ld	a4,0(a5)
    80005b76:	9732                	add	a4,a4,a2
    80005b78:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005b7a:	4689                	li	a3,2
    80005b7c:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005b80:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005b84:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005b88:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005b8c:	6794                	ld	a3,8(a5)
    80005b8e:	0026d703          	lhu	a4,2(a3)
    80005b92:	8b1d                	andi	a4,a4,7
    80005b94:	0706                	slli	a4,a4,0x1
    80005b96:	96ba                	add	a3,a3,a4
    80005b98:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005b9c:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005ba0:	6798                	ld	a4,8(a5)
    80005ba2:	00275783          	lhu	a5,2(a4)
    80005ba6:	2785                	addiw	a5,a5,1
    80005ba8:	00f71123          	sh	a5,2(a4)
    80005bac:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005bb0:	100017b7          	lui	a5,0x10001
    80005bb4:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005bb8:	0049a783          	lw	a5,4(s3)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005bbc:	0001e497          	auipc	s1,0x1e
    80005bc0:	ca448493          	addi	s1,s1,-860 # 80023860 <disk+0x128>
  while (b->disk == 1) {
    80005bc4:	892e                	mv	s2,a1
    80005bc6:	02b79163          	bne	a5,a1,80005be8 <virtio_disk_rw+0x1d2>
    sleep_prepare(b);
    80005bca:	854e                	mv	a0,s3
    80005bcc:	c3afc0ef          	jal	80002006 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005bd0:	8526                	mv	a0,s1
    80005bd2:	8defb0ef          	jal	80000cb0 <release>
    sleep();
    80005bd6:	c6cfc0ef          	jal	80002042 <sleep>
    acquire(&disk.vdisk_lock);
    80005bda:	8526                	mv	a0,s1
    80005bdc:	84cfb0ef          	jal	80000c28 <acquire>
  while (b->disk == 1) {
    80005be0:	0049a783          	lw	a5,4(s3)
    80005be4:	ff2783e3          	beq	a5,s2,80005bca <virtio_disk_rw+0x1b4>
  }

  disk.info[idx[0]].b = 0;
    80005be8:	fa042903          	lw	s2,-96(s0)
    80005bec:	00491713          	slli	a4,s2,0x4
    80005bf0:	02070713          	addi	a4,a4,32
    80005bf4:	0001e797          	auipc	a5,0x1e
    80005bf8:	b4478793          	addi	a5,a5,-1212 # 80023738 <disk>
    80005bfc:	97ba                	add	a5,a5,a4
    80005bfe:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005c02:	0001e997          	auipc	s3,0x1e
    80005c06:	b3698993          	addi	s3,s3,-1226 # 80023738 <disk>
    80005c0a:	00491713          	slli	a4,s2,0x4
    80005c0e:	0009b783          	ld	a5,0(s3)
    80005c12:	97ba                	add	a5,a5,a4
    80005c14:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005c18:	854a                	mv	a0,s2
    80005c1a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005c1e:	bbbff0ef          	jal	800057d8 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005c22:	8885                	andi	s1,s1,1
    80005c24:	f0fd                	bnez	s1,80005c0a <virtio_disk_rw+0x1f4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005c26:	0001e517          	auipc	a0,0x1e
    80005c2a:	c3a50513          	addi	a0,a0,-966 # 80023860 <disk+0x128>
    80005c2e:	882fb0ef          	jal	80000cb0 <release>
}
    80005c32:	60e6                	ld	ra,88(sp)
    80005c34:	6446                	ld	s0,80(sp)
    80005c36:	64a6                	ld	s1,72(sp)
    80005c38:	6906                	ld	s2,64(sp)
    80005c3a:	79e2                	ld	s3,56(sp)
    80005c3c:	7a42                	ld	s4,48(sp)
    80005c3e:	7aa2                	ld	s5,40(sp)
    80005c40:	7b02                	ld	s6,32(sp)
    80005c42:	6be2                	ld	s7,24(sp)
    80005c44:	6c42                	ld	s8,16(sp)
    80005c46:	6125                	addi	sp,sp,96
    80005c48:	8082                	ret

0000000080005c4a <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005c4a:	1101                	addi	sp,sp,-32
    80005c4c:	ec06                	sd	ra,24(sp)
    80005c4e:	e822                	sd	s0,16(sp)
    80005c50:	e426                	sd	s1,8(sp)
    80005c52:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005c54:	0001e497          	auipc	s1,0x1e
    80005c58:	ae448493          	addi	s1,s1,-1308 # 80023738 <disk>
    80005c5c:	0001e517          	auipc	a0,0x1e
    80005c60:	c0450513          	addi	a0,a0,-1020 # 80023860 <disk+0x128>
    80005c64:	fc5fa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005c68:	100017b7          	lui	a5,0x10001
    80005c6c:	53bc                	lw	a5,96(a5)
    80005c6e:	8b8d                	andi	a5,a5,3
    80005c70:	10001737          	lui	a4,0x10001
    80005c74:	d37c                	sw	a5,100(a4)
    80005c76:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005c7a:	689c                	ld	a5,16(s1)
    80005c7c:	0204d703          	lhu	a4,32(s1)
    80005c80:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005c84:	04f70863          	beq	a4,a5,80005cd4 <virtio_disk_intr+0x8a>
    80005c88:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005c8c:	6898                	ld	a4,16(s1)
    80005c8e:	0204d783          	lhu	a5,32(s1)
    80005c92:	8b9d                	andi	a5,a5,7
    80005c94:	078e                	slli	a5,a5,0x3
    80005c96:	97ba                	add	a5,a5,a4
    80005c98:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005c9a:	00479713          	slli	a4,a5,0x4
    80005c9e:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005ca2:	9726                	add	a4,a4,s1
    80005ca4:	01074703          	lbu	a4,16(a4)
    80005ca8:	e329                	bnez	a4,80005cea <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005caa:	0792                	slli	a5,a5,0x4
    80005cac:	02078793          	addi	a5,a5,32
    80005cb0:	97a6                	add	a5,a5,s1
    80005cb2:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005cb4:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005cb8:	bbafc0ef          	jal	80002072 <wakeup>

    disk.used_idx += 1;
    80005cbc:	0204d783          	lhu	a5,32(s1)
    80005cc0:	2785                	addiw	a5,a5,1
    80005cc2:	17c2                	slli	a5,a5,0x30
    80005cc4:	93c1                	srli	a5,a5,0x30
    80005cc6:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005cca:	6898                	ld	a4,16(s1)
    80005ccc:	00275703          	lhu	a4,2(a4)
    80005cd0:	faf71ce3          	bne	a4,a5,80005c88 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005cd4:	0001e517          	auipc	a0,0x1e
    80005cd8:	b8c50513          	addi	a0,a0,-1140 # 80023860 <disk+0x128>
    80005cdc:	fd5fa0ef          	jal	80000cb0 <release>
}
    80005ce0:	60e2                	ld	ra,24(sp)
    80005ce2:	6442                	ld	s0,16(sp)
    80005ce4:	64a2                	ld	s1,8(sp)
    80005ce6:	6105                	addi	sp,sp,32
    80005ce8:	8082                	ret
      panic("virtio_disk_intr status");
    80005cea:	00002517          	auipc	a0,0x2
    80005cee:	a2e50513          	addi	a0,a0,-1490 # 80007718 <etext+0x718>
    80005cf2:	b43fa0ef          	jal	80000834 <panic>
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
