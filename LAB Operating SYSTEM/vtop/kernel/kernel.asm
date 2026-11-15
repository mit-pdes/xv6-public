
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
    80000004:	33813103          	ld	sp,824(sp) # 8000a338 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000066:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb177>
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
    8000011c:	278020ef          	jal	80002394 <either_copyin>
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
    80000198:	1ec50513          	addi	a0,a0,492 # 80012380 <cons>
    8000019c:	28d000ef          	jal	80000c28 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    800001a0:	00012497          	auipc	s1,0x12
    800001a4:	1e048493          	addi	s1,s1,480 # 80012380 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a8:	00012917          	auipc	s2,0x12
    800001ac:	27090913          	addi	s2,s2,624 # 80012418 <cons+0x98>
  while (n > 0) {
    800001b0:	0d305263          	blez	s3,80000274 <consoleread+0xfc>
    while (cons.r == cons.w) {
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	0af71763          	bne	a4,a5,8000026a <consoleread+0xf2>
      if (killed(myproc())) {
    800001c0:	7ec010ef          	jal	800019ac <myproc>
    800001c4:	050020ef          	jal	80002214 <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	5eb010ef          	jal	80001fb6 <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	2df000ef          	jal	80000cb0 <release>
      sleep();
    800001d6:	61d010ef          	jal	80001ff2 <sleep>
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
    800001f2:	19270713          	addi	a4,a4,402 # 80012380 <cons>
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
    80000220:	128020ef          	jal	80002348 <either_copyout>
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
    8000023c:	14850513          	addi	a0,a0,328 # 80012380 <cons>
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
    80000262:	1af72d23          	sw	a5,442(a4) # 80012418 <cons+0x98>
    80000266:	7aa2                	ld	s5,40(sp)
    80000268:	a031                	j	80000274 <consoleread+0xfc>
    8000026a:	f456                	sd	s5,40(sp)
    8000026c:	b749                	j	800001ee <consoleread+0x76>
    8000026e:	7aa2                	ld	s5,40(sp)
    80000270:	a011                	j	80000274 <consoleread+0xfc>
    80000272:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000274:	00012517          	auipc	a0,0x12
    80000278:	10c50513          	addi	a0,a0,268 # 80012380 <cons>
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
    800002cc:	0b850513          	addi	a0,a0,184 # 80012380 <cons>
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
    800002ea:	0f6020ef          	jal	800023e0 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ee:	00012517          	auipc	a0,0x12
    800002f2:	09250513          	addi	a0,a0,146 # 80012380 <cons>
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
    80000310:	07470713          	addi	a4,a4,116 # 80012380 <cons>
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
    80000336:	04e70713          	addi	a4,a4,78 # 80012380 <cons>
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
    80000360:	0bc72703          	lw	a4,188(a4) # 80012418 <cons+0x98>
    80000364:	9f99                	subw	a5,a5,a4
    80000366:	08000713          	li	a4,128
    8000036a:	f8e792e3          	bne	a5,a4,800002ee <consoleintr+0x32>
    8000036e:	a075                	j	8000041a <consoleintr+0x15e>
    80000370:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000372:	00012717          	auipc	a4,0x12
    80000376:	00e70713          	addi	a4,a4,14 # 80012380 <cons>
    8000037a:	0a072783          	lw	a5,160(a4)
    8000037e:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000382:	00012497          	auipc	s1,0x12
    80000386:	ffe48493          	addi	s1,s1,-2 # 80012380 <cons>
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
    800003c8:	fbc70713          	addi	a4,a4,-68 # 80012380 <cons>
    800003cc:	0a072783          	lw	a5,160(a4)
    800003d0:	09c72703          	lw	a4,156(a4)
    800003d4:	f0f70de3          	beq	a4,a5,800002ee <consoleintr+0x32>
      cons.e--;
    800003d8:	37fd                	addiw	a5,a5,-1
    800003da:	00012717          	auipc	a4,0x12
    800003de:	04f72323          	sw	a5,70(a4) # 80012420 <cons+0xa0>
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
    800003fc:	f8878793          	addi	a5,a5,-120 # 80012380 <cons>
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
    8000041e:	00c7a123          	sw	a2,2(a5) # 8001241c <cons+0x9c>
        wakeup(&cons.r);
    80000422:	00012517          	auipc	a0,0x12
    80000426:	ff650513          	addi	a0,a0,-10 # 80012418 <cons+0x98>
    8000042a:	3f9010ef          	jal	80002022 <wakeup>
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
    80000444:	f4050513          	addi	a0,a0,-192 # 80012380 <cons>
    80000448:	760000ef          	jal	80000ba8 <initlock>

  uartinit();
    8000044c:	448000ef          	jal	80000894 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000450:	00022797          	auipc	a5,0x22
    80000454:	0a078793          	addi	a5,a5,160 # 800224f0 <devsw>
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
    8000052c:	e2c7a783          	lw	a5,-468(a5) # 8000a354 <panicking>
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
    80000572:	eba50513          	addi	a0,a0,-326 # 80012428 <pr>
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
    8000076e:	bea7a783          	lw	a5,-1046(a5) # 8000a354 <panicking>
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
    80000798:	c9450513          	addi	a0,a0,-876 # 80012428 <pr>
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
    80000848:	b097a823          	sw	s1,-1264(a5) # 8000a354 <panicking>
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
    8000086a:	ae97a523          	sw	s1,-1302(a5) # 8000a350 <panicked>
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
    80000884:	ba850513          	addi	a0,a0,-1112 # 80012428 <pr>
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
    800008da:	b6a50513          	addi	a0,a0,-1174 # 80012440 <tx_lock>
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
    800008fe:	b4650513          	addi	a0,a0,-1210 # 80012440 <tx_lock>
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
    8000091c:	a4490913          	addi	s2,s2,-1468 # 8000a35c <tx_busy>
      // wait for a UART interrupt to set tx_busy to 0.
      sleep_prepare(&tx_chan);
    80000920:	0000a997          	auipc	s3,0xa
    80000924:	a3898993          	addi	s3,s3,-1480 # 8000a358 <tx_chan>
      release(&tx_lock);
    80000928:	00012497          	auipc	s1,0x12
    8000092c:	b1848493          	addi	s1,s1,-1256 # 80012440 <tx_lock>
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
    8000093a:	67c010ef          	jal	80001fb6 <sleep_prepare>
      release(&tx_lock);
    8000093e:	8526                	mv	a0,s1
    80000940:	370000ef          	jal	80000cb0 <release>
      sleep();
    80000944:	6ae010ef          	jal	80001ff2 <sleep>
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
    8000097c:	ac850513          	addi	a0,a0,-1336 # 80012440 <tx_lock>
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
    800009a0:	9b87a783          	lw	a5,-1608(a5) # 8000a354 <panicking>
    800009a4:	cf95                	beqz	a5,800009e0 <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    800009a6:	0000a797          	auipc	a5,0xa
    800009aa:	9aa7a783          	lw	a5,-1622(a5) # 8000a350 <panicked>
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
    800009d0:	9887a783          	lw	a5,-1656(a5) # 8000a354 <panicking>
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
    80000a06:	a3e50513          	addi	a0,a0,-1474 # 80012440 <tx_lock>
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
    80000a20:	a2450513          	addi	a0,a0,-1500 # 80012440 <tx_lock>
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
    80000a48:	9007ac23          	sw	zero,-1768(a5) # 8000a35c <tx_busy>
    wakeup(&tx_chan);
    80000a4c:	0000a517          	auipc	a0,0xa
    80000a50:	90c50513          	addi	a0,a0,-1780 # 8000a358 <tx_chan>
    80000a54:	5ce010ef          	jal	80002022 <wakeup>
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
    80000a76:	c1678793          	addi	a5,a5,-1002 # 80023688 <end>
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
    80000aa0:	9bc90913          	addi	s2,s2,-1604 # 80012458 <kmem>
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
    80000b2e:	92e50513          	addi	a0,a0,-1746 # 80012458 <kmem>
    80000b32:	076000ef          	jal	80000ba8 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000b36:	45c5                	li	a1,17
    80000b38:	05ee                	slli	a1,a1,0x1b
    80000b3a:	00023517          	auipc	a0,0x23
    80000b3e:	b4e50513          	addi	a0,a0,-1202 # 80023688 <end>
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
    80000b5c:	90050513          	addi	a0,a0,-1792 # 80012458 <kmem>
    80000b60:	0c8000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b64:	00012497          	auipc	s1,0x12
    80000b68:	90c4b483          	ld	s1,-1780(s1) # 80012470 <kmem+0x18>
  if (r)
    80000b6c:	c49d                	beqz	s1,80000b9a <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b6e:	609c                	ld	a5,0(s1)
    80000b70:	00012717          	auipc	a4,0x12
    80000b74:	90f73023          	sd	a5,-1792(a4) # 80012470 <kmem+0x18>
  release(&kmem.lock);
    80000b78:	00012517          	auipc	a0,0x12
    80000b7c:	8e050513          	addi	a0,a0,-1824 # 80012458 <kmem>
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
    80000b9e:	8be50513          	addi	a0,a0,-1858 # 80012458 <kmem>
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
    80000bd8:	5b5000ef          	jal	8000198c <mycpu>
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
    80000bfe:	58f000ef          	jal	8000198c <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x2c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	587000ef          	jal	8000198c <mycpu>
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
    80000c1a:	573000ef          	jal	8000198c <mycpu>
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
    80000c4c:	541000ef          	jal	8000198c <mycpu>
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
    80000c70:	51d000ef          	jal	8000198c <mycpu>
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
    80000ea6:	2d3000ef          	jal	80001978 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();         // first user process

    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
  } else {
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000eaa:	00009717          	auipc	a4,0x9
    80000eae:	4b670713          	addi	a4,a4,1206 # 8000a360 <started>
  if (cpuid() == 0) {
    80000eb2:	c51d                	beqz	a0,80000ee0 <main+0x42>
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000eb4:	431c                	lw	a5,0(a4)
    80000eb6:	0230000f          	fence	r,rw
    80000eba:	2781                	sext.w	a5,a5
    80000ebc:	dfe5                	beqz	a5,80000eb4 <main+0x16>
      ;

    printk("hart %d starting\n", cpuid());
    80000ebe:	2bb000ef          	jal	80001978 <cpuid>
    80000ec2:	85aa                	mv	a1,a0
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	1d450513          	addi	a0,a0,468 # 80007098 <etext+0x98>
    80000ecc:	e3eff0ef          	jal	8000050a <printk>
    kvminithart();  // turn on paging
    80000ed0:	082000ef          	jal	80000f52 <kvminithart>
    trapinithart(); // install kernel trap vector
    80000ed4:	63e010ef          	jal	80002512 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ed8:	051040ef          	jal	80005728 <plicinithart>
  }

  scheduler();
    80000edc:	73f000ef          	jal	80001e1a <scheduler>
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
    80000f18:	1ab000ef          	jal	800018c2 <procinit>
    trapinit();         // trap vectors
    80000f1c:	5d2010ef          	jal	800024ee <trapinit>
    trapinithart();     // install kernel trap vector
    80000f20:	5f2010ef          	jal	80002512 <trapinithart>
    plicinit();         // set up interrupt controller
    80000f24:	7ea040ef          	jal	8000570e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f28:	001040ef          	jal	80005728 <plicinithart>
    binit();            // buffer cache
    80000f2c:	4a7010ef          	jal	80002bd2 <binit>
    iinit();            // inode table
    80000f30:	1f8020ef          	jal	80003128 <iinit>
    fileinit();         // file table
    80000f34:	226030ef          	jal	8000415a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f38:	0e7040ef          	jal	8000581e <virtio_disk_init>
    userinit();         // first user process
    80000f3c:	533000ef          	jal	80001c6e <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000f40:	00009797          	auipc	a5,0x9
    80000f44:	42078793          	addi	a5,a5,1056 # 8000a360 <started>
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
    80000f62:	40a7b783          	ld	a5,1034(a5) # 8000a368 <kernel_pagetable>
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
    800011ce:	650000ef          	jal	8000181e <proc_mapstacks>
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
    800011ee:	16a7bf23          	sd	a0,382(a5) # 8000a368 <kernel_pagetable>
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
    80001724:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb978>
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

00000000800017ba <walkpgdir>:

// walkpgdir exposes walk() to locate the corresponding page-table entry
pte_t *
walkpgdir(pagetable_t pagetable, uint64 va, int alloc)
{
    800017ba:	1141                	addi	sp,sp,-16
    800017bc:	e406                	sd	ra,8(sp)
    800017be:	e022                	sd	s0,0(sp)
    800017c0:	0800                	addi	s0,sp,16
  return walk(pagetable, va, alloc);
    800017c2:	fbcff0ef          	jal	80000f7e <walk>
}
    800017c6:	60a2                	ld	ra,8(sp)
    800017c8:	6402                	ld	s0,0(sp)
    800017ca:	0141                	addi	sp,sp,16
    800017cc:	8082                	ret

00000000800017ce <vtop>:

// vtop translates a virtual address to physical address
// Checks whether page-table entry is valid, present, and user-accessible.
uint64
vtop(uint64 va)
{
    800017ce:	1101                	addi	sp,sp,-32
    800017d0:	ec06                	sd	ra,24(sp)
    800017d2:	e822                	sd	s0,16(sp)
    800017d4:	e426                	sd	s1,8(sp)
    800017d6:	1000                	addi	s0,sp,32
    800017d8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800017da:	1d2000ef          	jal	800019ac <myproc>
  if (va >= MAXVA)
    800017de:	57fd                	li	a5,-1
    800017e0:	83e9                	srli	a5,a5,0x1a
    800017e2:	0297e663          	bltu	a5,s1,8000180e <vtop+0x40>
  return walk(pagetable, va, alloc);
    800017e6:	4601                	li	a2,0
    800017e8:	85a6                	mv	a1,s1
    800017ea:	6928                	ld	a0,80(a0)
    800017ec:	f92ff0ef          	jal	80000f7e <walk>
    return (uint64)-1;

  pte_t *pte = walkpgdir(p->pagetable, va, 0);
  if (pte == 0)
    800017f0:	c50d                	beqz	a0,8000181a <vtop+0x4c>
    return (uint64)-1;

  // Check valid/present (PTE_V) and user-accessible (PTE_U)
  if ((*pte & PTE_V) == 0 || (*pte & PTE_U) == 0)
    800017f2:	611c                	ld	a5,0(a0)
    800017f4:	0117f693          	andi	a3,a5,17
    800017f8:	4745                	li	a4,17
    return (uint64)-1;
    800017fa:	557d                	li	a0,-1
  if ((*pte & PTE_V) == 0 || (*pte & PTE_U) == 0)
    800017fc:	00e69a63          	bne	a3,a4,80001810 <vtop+0x42>

  uint64 pa = PTE2PA(*pte) | (va & 0xFFF);
    80001800:	83a9                	srli	a5,a5,0xa
    80001802:	07b2                	slli	a5,a5,0xc
    80001804:	14d2                	slli	s1,s1,0x34
    80001806:	90d1                	srli	s1,s1,0x34
    80001808:	0097e533          	or	a0,a5,s1
  return pa;
    8000180c:	a011                	j	80001810 <vtop+0x42>
    return (uint64)-1;
    8000180e:	557d                	li	a0,-1
}
    80001810:	60e2                	ld	ra,24(sp)
    80001812:	6442                	ld	s0,16(sp)
    80001814:	64a2                	ld	s1,8(sp)
    80001816:	6105                	addi	sp,sp,32
    80001818:	8082                	ret
    return (uint64)-1;
    8000181a:	557d                	li	a0,-1
    8000181c:	bfd5                	j	80001810 <vtop+0x42>

000000008000181e <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000181e:	715d                	addi	sp,sp,-80
    80001820:	e486                	sd	ra,72(sp)
    80001822:	e0a2                	sd	s0,64(sp)
    80001824:	fc26                	sd	s1,56(sp)
    80001826:	f84a                	sd	s2,48(sp)
    80001828:	f44e                	sd	s3,40(sp)
    8000182a:	f052                	sd	s4,32(sp)
    8000182c:	ec56                	sd	s5,24(sp)
    8000182e:	e85a                	sd	s6,16(sp)
    80001830:	e45e                	sd	s7,8(sp)
    80001832:	e062                	sd	s8,0(sp)
    80001834:	0880                	addi	s0,sp,80
    80001836:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001838:	00011497          	auipc	s1,0x11
    8000183c:	07048493          	addi	s1,s1,112 # 800128a8 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001840:	8c26                	mv	s8,s1
    80001842:	000a57b7          	lui	a5,0xa5
    80001846:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    8000184a:	07b2                	slli	a5,a5,0xc
    8000184c:	fa578793          	addi	a5,a5,-91
    80001850:	4fa50937          	lui	s2,0x4fa50
    80001854:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001858:	1902                	slli	s2,s2,0x20
    8000185a:	993e                	add	s2,s2,a5
    8000185c:	040009b7          	lui	s3,0x4000
    80001860:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001862:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001864:	4b99                	li	s7,6
    80001866:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    80001868:	00017a97          	auipc	s5,0x17
    8000186c:	a40a8a93          	addi	s5,s5,-1472 # 800182a8 <tickslock>
    char *pa = kalloc();
    80001870:	adeff0ef          	jal	80000b4e <kalloc>
    80001874:	862a                	mv	a2,a0
    if (pa == 0)
    80001876:	c121                	beqz	a0,800018b6 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    80001878:	418485b3          	sub	a1,s1,s8
    8000187c:	858d                	srai	a1,a1,0x3
    8000187e:	032585b3          	mul	a1,a1,s2
    80001882:	05b6                	slli	a1,a1,0xd
    80001884:	6789                	lui	a5,0x2
    80001886:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001888:	875e                	mv	a4,s7
    8000188a:	86da                	mv	a3,s6
    8000188c:	40b985b3          	sub	a1,s3,a1
    80001890:	8552                	mv	a0,s4
    80001892:	877ff0ef          	jal	80001108 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001896:	16848493          	addi	s1,s1,360
    8000189a:	fd549be3          	bne	s1,s5,80001870 <proc_mapstacks+0x52>
  }
}
    8000189e:	60a6                	ld	ra,72(sp)
    800018a0:	6406                	ld	s0,64(sp)
    800018a2:	74e2                	ld	s1,56(sp)
    800018a4:	7942                	ld	s2,48(sp)
    800018a6:	79a2                	ld	s3,40(sp)
    800018a8:	7a02                	ld	s4,32(sp)
    800018aa:	6ae2                	ld	s5,24(sp)
    800018ac:	6b42                	ld	s6,16(sp)
    800018ae:	6ba2                	ld	s7,8(sp)
    800018b0:	6c02                	ld	s8,0(sp)
    800018b2:	6161                	addi	sp,sp,80
    800018b4:	8082                	ret
      panic("kalloc");
    800018b6:	00006517          	auipc	a0,0x6
    800018ba:	8a250513          	addi	a0,a0,-1886 # 80007158 <etext+0x158>
    800018be:	f77fe0ef          	jal	80000834 <panic>

00000000800018c2 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018c2:	7139                	addi	sp,sp,-64
    800018c4:	fc06                	sd	ra,56(sp)
    800018c6:	f822                	sd	s0,48(sp)
    800018c8:	f426                	sd	s1,40(sp)
    800018ca:	f04a                	sd	s2,32(sp)
    800018cc:	ec4e                	sd	s3,24(sp)
    800018ce:	e852                	sd	s4,16(sp)
    800018d0:	e456                	sd	s5,8(sp)
    800018d2:	e05a                	sd	s6,0(sp)
    800018d4:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800018d6:	00006597          	auipc	a1,0x6
    800018da:	88a58593          	addi	a1,a1,-1910 # 80007160 <etext+0x160>
    800018de:	00011517          	auipc	a0,0x11
    800018e2:	b9a50513          	addi	a0,a0,-1126 # 80012478 <pid_lock>
    800018e6:	ac2ff0ef          	jal	80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018ea:	00006597          	auipc	a1,0x6
    800018ee:	87e58593          	addi	a1,a1,-1922 # 80007168 <etext+0x168>
    800018f2:	00011517          	auipc	a0,0x11
    800018f6:	b9e50513          	addi	a0,a0,-1122 # 80012490 <wait_lock>
    800018fa:	aaeff0ef          	jal	80000ba8 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    800018fe:	00011497          	auipc	s1,0x11
    80001902:	faa48493          	addi	s1,s1,-86 # 800128a8 <proc>
    initlock(&p->lock, "proc");
    80001906:	00006b17          	auipc	s6,0x6
    8000190a:	872b0b13          	addi	s6,s6,-1934 # 80007178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    8000190e:	8aa6                	mv	s5,s1
    80001910:	000a57b7          	lui	a5,0xa5
    80001914:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001918:	07b2                	slli	a5,a5,0xc
    8000191a:	fa578793          	addi	a5,a5,-91
    8000191e:	4fa50937          	lui	s2,0x4fa50
    80001922:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001926:	1902                	slli	s2,s2,0x20
    80001928:	993e                	add	s2,s2,a5
    8000192a:	040009b7          	lui	s3,0x4000
    8000192e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001930:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001932:	00017a17          	auipc	s4,0x17
    80001936:	976a0a13          	addi	s4,s4,-1674 # 800182a8 <tickslock>
    initlock(&p->lock, "proc");
    8000193a:	85da                	mv	a1,s6
    8000193c:	8526                	mv	a0,s1
    8000193e:	a6aff0ef          	jal	80000ba8 <initlock>
    p->state = UNUSED;
    80001942:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001946:	415487b3          	sub	a5,s1,s5
    8000194a:	878d                	srai	a5,a5,0x3
    8000194c:	032787b3          	mul	a5,a5,s2
    80001950:	07b6                	slli	a5,a5,0xd
    80001952:	6709                	lui	a4,0x2
    80001954:	9fb9                	addw	a5,a5,a4
    80001956:	40f987b3          	sub	a5,s3,a5
    8000195a:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    8000195c:	16848493          	addi	s1,s1,360
    80001960:	fd449de3          	bne	s1,s4,8000193a <procinit+0x78>
  }
}
    80001964:	70e2                	ld	ra,56(sp)
    80001966:	7442                	ld	s0,48(sp)
    80001968:	74a2                	ld	s1,40(sp)
    8000196a:	7902                	ld	s2,32(sp)
    8000196c:	69e2                	ld	s3,24(sp)
    8000196e:	6a42                	ld	s4,16(sp)
    80001970:	6aa2                	ld	s5,8(sp)
    80001972:	6b02                	ld	s6,0(sp)
    80001974:	6121                	addi	sp,sp,64
    80001976:	8082                	ret

0000000080001978 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001978:	1141                	addi	sp,sp,-16
    8000197a:	e406                	sd	ra,8(sp)
    8000197c:	e022                	sd	s0,0(sp)
    8000197e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    80001980:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001982:	2501                	sext.w	a0,a0
    80001984:	60a2                	ld	ra,8(sp)
    80001986:	6402                	ld	s0,0(sp)
    80001988:	0141                	addi	sp,sp,16
    8000198a:	8082                	ret

000000008000198c <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    8000198c:	1141                	addi	sp,sp,-16
    8000198e:	e406                	sd	ra,8(sp)
    80001990:	e022                	sd	s0,0(sp)
    80001992:	0800                	addi	s0,sp,16
    80001994:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001996:	2781                	sext.w	a5,a5
    80001998:	079e                	slli	a5,a5,0x7
  return c;
}
    8000199a:	00011517          	auipc	a0,0x11
    8000199e:	b0e50513          	addi	a0,a0,-1266 # 800124a8 <cpus>
    800019a2:	953e                	add	a0,a0,a5
    800019a4:	60a2                	ld	ra,8(sp)
    800019a6:	6402                	ld	s0,0(sp)
    800019a8:	0141                	addi	sp,sp,16
    800019aa:	8082                	ret

00000000800019ac <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800019ac:	1101                	addi	sp,sp,-32
    800019ae:	ec06                	sd	ra,24(sp)
    800019b0:	e822                	sd	s0,16(sp)
    800019b2:	e426                	sd	s1,8(sp)
    800019b4:	1000                	addi	s0,sp,32
  push_off();
    800019b6:	a38ff0ef          	jal	80000bee <push_off>
    800019ba:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019bc:	2781                	sext.w	a5,a5
    800019be:	079e                	slli	a5,a5,0x7
    800019c0:	00011717          	auipc	a4,0x11
    800019c4:	ab870713          	addi	a4,a4,-1352 # 80012478 <pid_lock>
    800019c8:	97ba                	add	a5,a5,a4
    800019ca:	7b9c                	ld	a5,48(a5)
    800019cc:	84be                	mv	s1,a5
  pop_off();
    800019ce:	a9aff0ef          	jal	80000c68 <pop_off>
  return p;
}
    800019d2:	8526                	mv	a0,s1
    800019d4:	60e2                	ld	ra,24(sp)
    800019d6:	6442                	ld	s0,16(sp)
    800019d8:	64a2                	ld	s1,8(sp)
    800019da:	6105                	addi	sp,sp,32
    800019dc:	8082                	ret

00000000800019de <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019de:	7179                	addi	sp,sp,-48
    800019e0:	f406                	sd	ra,40(sp)
    800019e2:	f022                	sd	s0,32(sp)
    800019e4:	ec26                	sd	s1,24(sp)
    800019e6:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    800019e8:	fc5ff0ef          	jal	800019ac <myproc>
    800019ec:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    800019ee:	ac2ff0ef          	jal	80000cb0 <release>

  if (first) {
    800019f2:	00009797          	auipc	a5,0x9
    800019f6:	92e7a783          	lw	a5,-1746(a5) # 8000a320 <first.1>
    800019fa:	cf85                	beqz	a5,80001a32 <forkret+0x54>
    first = 0;
    800019fc:	00009797          	auipc	a5,0x9
    80001a00:	9207a223          	sw	zero,-1756(a5) # 8000a320 <first.1>

    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001a04:	4505                	li	a0,1
    80001a06:	427010ef          	jal	8000362c <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001a0a:	00005797          	auipc	a5,0x5
    80001a0e:	77678793          	addi	a5,a5,1910 # 80007180 <etext+0x180>
    80001a12:	fcf43823          	sd	a5,-48(s0)
    80001a16:	fc043c23          	sd	zero,-40(s0)
    80001a1a:	fd040593          	addi	a1,s0,-48
    80001a1e:	853e                	mv	a0,a5
    80001a20:	6c1020ef          	jal	800048e0 <kexec>
    80001a24:	6cbc                	ld	a5,88(s1)
    80001a26:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001a28:	6cbc                	ld	a5,88(s1)
    80001a2a:	7bb8                	ld	a4,112(a5)
    80001a2c:	57fd                	li	a5,-1
    80001a2e:	02f70d63          	beq	a4,a5,80001a68 <forkret+0x8a>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001a32:	2fd000ef          	jal	8000252e <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001a36:	68a8                	ld	a0,80(s1)
    80001a38:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001a3a:	04000737          	lui	a4,0x4000
    80001a3e:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001a40:	0732                	slli	a4,a4,0xc
    80001a42:	00004797          	auipc	a5,0x4
    80001a46:	65a78793          	addi	a5,a5,1626 # 8000609c <userret>
    80001a4a:	00004697          	auipc	a3,0x4
    80001a4e:	5b668693          	addi	a3,a3,1462 # 80006000 <_trampoline>
    80001a52:	8f95                	sub	a5,a5,a3
    80001a54:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001a56:	577d                	li	a4,-1
    80001a58:	177e                	slli	a4,a4,0x3f
    80001a5a:	8d59                	or	a0,a0,a4
    80001a5c:	9782                	jalr	a5
}
    80001a5e:	70a2                	ld	ra,40(sp)
    80001a60:	7402                	ld	s0,32(sp)
    80001a62:	64e2                	ld	s1,24(sp)
    80001a64:	6145                	addi	sp,sp,48
    80001a66:	8082                	ret
      panic("exec");
    80001a68:	00005517          	auipc	a0,0x5
    80001a6c:	72050513          	addi	a0,a0,1824 # 80007188 <etext+0x188>
    80001a70:	dc5fe0ef          	jal	80000834 <panic>

0000000080001a74 <allocpid>:
{
    80001a74:	1101                	addi	sp,sp,-32
    80001a76:	ec06                	sd	ra,24(sp)
    80001a78:	e822                	sd	s0,16(sp)
    80001a7a:	e426                	sd	s1,8(sp)
    80001a7c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a7e:	00011517          	auipc	a0,0x11
    80001a82:	9fa50513          	addi	a0,a0,-1542 # 80012478 <pid_lock>
    80001a86:	9a2ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a8a:	00009797          	auipc	a5,0x9
    80001a8e:	89a78793          	addi	a5,a5,-1894 # 8000a324 <nextpid>
    80001a92:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a94:	0014871b          	addiw	a4,s1,1
    80001a98:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a9a:	00011517          	auipc	a0,0x11
    80001a9e:	9de50513          	addi	a0,a0,-1570 # 80012478 <pid_lock>
    80001aa2:	a0eff0ef          	jal	80000cb0 <release>
}
    80001aa6:	8526                	mv	a0,s1
    80001aa8:	60e2                	ld	ra,24(sp)
    80001aaa:	6442                	ld	s0,16(sp)
    80001aac:	64a2                	ld	s1,8(sp)
    80001aae:	6105                	addi	sp,sp,32
    80001ab0:	8082                	ret

0000000080001ab2 <proc_pagetable>:
{
    80001ab2:	1101                	addi	sp,sp,-32
    80001ab4:	ec06                	sd	ra,24(sp)
    80001ab6:	e822                	sd	s0,16(sp)
    80001ab8:	e426                	sd	s1,8(sp)
    80001aba:	e04a                	sd	s2,0(sp)
    80001abc:	1000                	addi	s0,sp,32
    80001abe:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ac0:	f3aff0ef          	jal	800011fa <uvmcreate>
    80001ac4:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001ac6:	cd05                	beqz	a0,80001afe <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001ac8:	4729                	li	a4,10
    80001aca:	00004697          	auipc	a3,0x4
    80001ace:	53668693          	addi	a3,a3,1334 # 80006000 <_trampoline>
    80001ad2:	6605                	lui	a2,0x1
    80001ad4:	040005b7          	lui	a1,0x4000
    80001ad8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ada:	05b2                	slli	a1,a1,0xc
    80001adc:	d76ff0ef          	jal	80001052 <mappages>
    80001ae0:	02054663          	bltz	a0,80001b0c <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001ae4:	4719                	li	a4,6
    80001ae6:	05893683          	ld	a3,88(s2)
    80001aea:	6605                	lui	a2,0x1
    80001aec:	020005b7          	lui	a1,0x2000
    80001af0:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001af2:	05b6                	slli	a1,a1,0xd
    80001af4:	8526                	mv	a0,s1
    80001af6:	d5cff0ef          	jal	80001052 <mappages>
    80001afa:	00054f63          	bltz	a0,80001b18 <proc_pagetable+0x66>
}
    80001afe:	8526                	mv	a0,s1
    80001b00:	60e2                	ld	ra,24(sp)
    80001b02:	6442                	ld	s0,16(sp)
    80001b04:	64a2                	ld	s1,8(sp)
    80001b06:	6902                	ld	s2,0(sp)
    80001b08:	6105                	addi	sp,sp,32
    80001b0a:	8082                	ret
    uvmfree(pagetable, 0);
    80001b0c:	4581                	li	a1,0
    80001b0e:	8526                	mv	a0,s1
    80001b10:	8e5ff0ef          	jal	800013f4 <uvmfree>
    return 0;
    80001b14:	4481                	li	s1,0
    80001b16:	b7e5                	j	80001afe <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b18:	4681                	li	a3,0
    80001b1a:	4605                	li	a2,1
    80001b1c:	040005b7          	lui	a1,0x4000
    80001b20:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b22:	05b2                	slli	a1,a1,0xc
    80001b24:	8526                	mv	a0,s1
    80001b26:	efaff0ef          	jal	80001220 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b2a:	4581                	li	a1,0
    80001b2c:	8526                	mv	a0,s1
    80001b2e:	8c7ff0ef          	jal	800013f4 <uvmfree>
    return 0;
    80001b32:	4481                	li	s1,0
    80001b34:	b7e9                	j	80001afe <proc_pagetable+0x4c>

0000000080001b36 <proc_freepagetable>:
{
    80001b36:	1101                	addi	sp,sp,-32
    80001b38:	ec06                	sd	ra,24(sp)
    80001b3a:	e822                	sd	s0,16(sp)
    80001b3c:	e426                	sd	s1,8(sp)
    80001b3e:	e04a                	sd	s2,0(sp)
    80001b40:	1000                	addi	s0,sp,32
    80001b42:	84aa                	mv	s1,a0
    80001b44:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b46:	4681                	li	a3,0
    80001b48:	4605                	li	a2,1
    80001b4a:	040005b7          	lui	a1,0x4000
    80001b4e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b50:	05b2                	slli	a1,a1,0xc
    80001b52:	eceff0ef          	jal	80001220 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b56:	4681                	li	a3,0
    80001b58:	4605                	li	a2,1
    80001b5a:	020005b7          	lui	a1,0x2000
    80001b5e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b60:	05b6                	slli	a1,a1,0xd
    80001b62:	8526                	mv	a0,s1
    80001b64:	ebcff0ef          	jal	80001220 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b68:	85ca                	mv	a1,s2
    80001b6a:	8526                	mv	a0,s1
    80001b6c:	889ff0ef          	jal	800013f4 <uvmfree>
}
    80001b70:	60e2                	ld	ra,24(sp)
    80001b72:	6442                	ld	s0,16(sp)
    80001b74:	64a2                	ld	s1,8(sp)
    80001b76:	6902                	ld	s2,0(sp)
    80001b78:	6105                	addi	sp,sp,32
    80001b7a:	8082                	ret

0000000080001b7c <freeproc>:
{
    80001b7c:	1101                	addi	sp,sp,-32
    80001b7e:	ec06                	sd	ra,24(sp)
    80001b80:	e822                	sd	s0,16(sp)
    80001b82:	e426                	sd	s1,8(sp)
    80001b84:	1000                	addi	s0,sp,32
    80001b86:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b88:	6d28                	ld	a0,88(a0)
    80001b8a:	c119                	beqz	a0,80001b90 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001b8c:	edbfe0ef          	jal	80000a66 <kfree>
  p->trapframe = 0;
    80001b90:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001b94:	68a8                	ld	a0,80(s1)
    80001b96:	c501                	beqz	a0,80001b9e <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b98:	64ac                	ld	a1,72(s1)
    80001b9a:	f9dff0ef          	jal	80001b36 <proc_freepagetable>
  p->pagetable = 0;
    80001b9e:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ba2:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ba6:	0204a823          	sw	zero,48(s1)
  p->name[0] = 0;
    80001baa:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bae:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bb2:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bb6:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bba:	0004ac23          	sw	zero,24(s1)
}
    80001bbe:	60e2                	ld	ra,24(sp)
    80001bc0:	6442                	ld	s0,16(sp)
    80001bc2:	64a2                	ld	s1,8(sp)
    80001bc4:	6105                	addi	sp,sp,32
    80001bc6:	8082                	ret

0000000080001bc8 <allocproc>:
{
    80001bc8:	1101                	addi	sp,sp,-32
    80001bca:	ec06                	sd	ra,24(sp)
    80001bcc:	e822                	sd	s0,16(sp)
    80001bce:	e426                	sd	s1,8(sp)
    80001bd0:	e04a                	sd	s2,0(sp)
    80001bd2:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001bd4:	00011497          	auipc	s1,0x11
    80001bd8:	cd448493          	addi	s1,s1,-812 # 800128a8 <proc>
    80001bdc:	00016917          	auipc	s2,0x16
    80001be0:	6cc90913          	addi	s2,s2,1740 # 800182a8 <tickslock>
    acquire(&p->lock);
    80001be4:	8526                	mv	a0,s1
    80001be6:	842ff0ef          	jal	80000c28 <acquire>
    if (p->state == UNUSED) {
    80001bea:	4c9c                	lw	a5,24(s1)
    80001bec:	cb91                	beqz	a5,80001c00 <allocproc+0x38>
      release(&p->lock);
    80001bee:	8526                	mv	a0,s1
    80001bf0:	8c0ff0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001bf4:	16848493          	addi	s1,s1,360
    80001bf8:	ff2496e3          	bne	s1,s2,80001be4 <allocproc+0x1c>
  return 0;
    80001bfc:	4481                	li	s1,0
    80001bfe:	a089                	j	80001c40 <allocproc+0x78>
  p->pid = allocpid();
    80001c00:	e75ff0ef          	jal	80001a74 <allocpid>
    80001c04:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c06:	4785                	li	a5,1
    80001c08:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001c0a:	f45fe0ef          	jal	80000b4e <kalloc>
    80001c0e:	892a                	mv	s2,a0
    80001c10:	eca8                	sd	a0,88(s1)
    80001c12:	cd15                	beqz	a0,80001c4e <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001c14:	8526                	mv	a0,s1
    80001c16:	e9dff0ef          	jal	80001ab2 <proc_pagetable>
    80001c1a:	892a                	mv	s2,a0
    80001c1c:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001c1e:	c121                	beqz	a0,80001c5e <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001c20:	07000613          	li	a2,112
    80001c24:	4581                	li	a1,0
    80001c26:	06048513          	addi	a0,s1,96
    80001c2a:	8beff0ef          	jal	80000ce8 <memset>
  p->context.ra = (uint64)forkret;
    80001c2e:	00000797          	auipc	a5,0x0
    80001c32:	db078793          	addi	a5,a5,-592 # 800019de <forkret>
    80001c36:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c38:	60bc                	ld	a5,64(s1)
    80001c3a:	6705                	lui	a4,0x1
    80001c3c:	97ba                	add	a5,a5,a4
    80001c3e:	f4bc                	sd	a5,104(s1)
}
    80001c40:	8526                	mv	a0,s1
    80001c42:	60e2                	ld	ra,24(sp)
    80001c44:	6442                	ld	s0,16(sp)
    80001c46:	64a2                	ld	s1,8(sp)
    80001c48:	6902                	ld	s2,0(sp)
    80001c4a:	6105                	addi	sp,sp,32
    80001c4c:	8082                	ret
    freeproc(p);
    80001c4e:	8526                	mv	a0,s1
    80001c50:	f2dff0ef          	jal	80001b7c <freeproc>
    release(&p->lock);
    80001c54:	8526                	mv	a0,s1
    80001c56:	85aff0ef          	jal	80000cb0 <release>
    return 0;
    80001c5a:	84ca                	mv	s1,s2
    80001c5c:	b7d5                	j	80001c40 <allocproc+0x78>
    freeproc(p);
    80001c5e:	8526                	mv	a0,s1
    80001c60:	f1dff0ef          	jal	80001b7c <freeproc>
    release(&p->lock);
    80001c64:	8526                	mv	a0,s1
    80001c66:	84aff0ef          	jal	80000cb0 <release>
    return 0;
    80001c6a:	84ca                	mv	s1,s2
    80001c6c:	bfd1                	j	80001c40 <allocproc+0x78>

0000000080001c6e <userinit>:
{
    80001c6e:	1101                	addi	sp,sp,-32
    80001c70:	ec06                	sd	ra,24(sp)
    80001c72:	e822                	sd	s0,16(sp)
    80001c74:	e426                	sd	s1,8(sp)
    80001c76:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c78:	f51ff0ef          	jal	80001bc8 <allocproc>
    80001c7c:	84aa                	mv	s1,a0
  initproc = p;
    80001c7e:	00008797          	auipc	a5,0x8
    80001c82:	6ea7b923          	sd	a0,1778(a5) # 8000a370 <initproc>
  p->cwd = namei("/");
    80001c86:	00005517          	auipc	a0,0x5
    80001c8a:	50a50513          	addi	a0,a0,1290 # 80007190 <etext+0x190>
    80001c8e:	6fd010ef          	jal	80003b8a <namei>
    80001c92:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c96:	478d                	li	a5,3
    80001c98:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c9a:	8526                	mv	a0,s1
    80001c9c:	814ff0ef          	jal	80000cb0 <release>
}
    80001ca0:	60e2                	ld	ra,24(sp)
    80001ca2:	6442                	ld	s0,16(sp)
    80001ca4:	64a2                	ld	s1,8(sp)
    80001ca6:	6105                	addi	sp,sp,32
    80001ca8:	8082                	ret

0000000080001caa <growproc>:
{
    80001caa:	1101                	addi	sp,sp,-32
    80001cac:	ec06                	sd	ra,24(sp)
    80001cae:	e822                	sd	s0,16(sp)
    80001cb0:	e426                	sd	s1,8(sp)
    80001cb2:	e04a                	sd	s2,0(sp)
    80001cb4:	1000                	addi	s0,sp,32
    80001cb6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001cb8:	cf5ff0ef          	jal	800019ac <myproc>
    80001cbc:	892a                	mv	s2,a0
  sz = p->sz;
    80001cbe:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001cc0:	02905963          	blez	s1,80001cf2 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001cc4:	00b48633          	add	a2,s1,a1
    80001cc8:	020007b7          	lui	a5,0x2000
    80001ccc:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001cce:	07b6                	slli	a5,a5,0xd
    80001cd0:	02c7ea63          	bltu	a5,a2,80001d04 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001cd4:	4691                	li	a3,4
    80001cd6:	6928                	ld	a0,80(a0)
    80001cd8:	e16ff0ef          	jal	800012ee <uvmalloc>
    80001cdc:	85aa                	mv	a1,a0
    80001cde:	c50d                	beqz	a0,80001d08 <growproc+0x5e>
  p->sz = sz;
    80001ce0:	04b93423          	sd	a1,72(s2)
  return 0;
    80001ce4:	4501                	li	a0,0
}
    80001ce6:	60e2                	ld	ra,24(sp)
    80001ce8:	6442                	ld	s0,16(sp)
    80001cea:	64a2                	ld	s1,8(sp)
    80001cec:	6902                	ld	s2,0(sp)
    80001cee:	6105                	addi	sp,sp,32
    80001cf0:	8082                	ret
  } else if (n < 0) {
    80001cf2:	fe04d7e3          	bgez	s1,80001ce0 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001cf6:	00b48633          	add	a2,s1,a1
    80001cfa:	6928                	ld	a0,80(a0)
    80001cfc:	daeff0ef          	jal	800012aa <uvmdealloc>
    80001d00:	85aa                	mv	a1,a0
    80001d02:	bff9                	j	80001ce0 <growproc+0x36>
      return -1;
    80001d04:	557d                	li	a0,-1
    80001d06:	b7c5                	j	80001ce6 <growproc+0x3c>
      return -1;
    80001d08:	557d                	li	a0,-1
    80001d0a:	bff1                	j	80001ce6 <growproc+0x3c>

0000000080001d0c <kfork>:
{
    80001d0c:	7139                	addi	sp,sp,-64
    80001d0e:	fc06                	sd	ra,56(sp)
    80001d10:	f822                	sd	s0,48(sp)
    80001d12:	f426                	sd	s1,40(sp)
    80001d14:	e456                	sd	s5,8(sp)
    80001d16:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d18:	c95ff0ef          	jal	800019ac <myproc>
    80001d1c:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001d1e:	eabff0ef          	jal	80001bc8 <allocproc>
    80001d22:	0e050a63          	beqz	a0,80001e16 <kfork+0x10a>
    80001d26:	e852                	sd	s4,16(sp)
    80001d28:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001d2a:	048ab603          	ld	a2,72(s5)
    80001d2e:	692c                	ld	a1,80(a0)
    80001d30:	050ab503          	ld	a0,80(s5)
    80001d34:	ef2ff0ef          	jal	80001426 <uvmcopy>
    80001d38:	04054863          	bltz	a0,80001d88 <kfork+0x7c>
    80001d3c:	f04a                	sd	s2,32(sp)
    80001d3e:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001d40:	048ab783          	ld	a5,72(s5)
    80001d44:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001d48:	058ab683          	ld	a3,88(s5)
    80001d4c:	87b6                	mv	a5,a3
    80001d4e:	058a3703          	ld	a4,88(s4)
    80001d52:	12068693          	addi	a3,a3,288
    80001d56:	6388                	ld	a0,0(a5)
    80001d58:	678c                	ld	a1,8(a5)
    80001d5a:	6b90                	ld	a2,16(a5)
    80001d5c:	e308                	sd	a0,0(a4)
    80001d5e:	e70c                	sd	a1,8(a4)
    80001d60:	eb10                	sd	a2,16(a4)
    80001d62:	6f90                	ld	a2,24(a5)
    80001d64:	ef10                	sd	a2,24(a4)
    80001d66:	02078793          	addi	a5,a5,32
    80001d6a:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d6e:	fed794e3          	bne	a5,a3,80001d56 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d72:	058a3783          	ld	a5,88(s4)
    80001d76:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001d7a:	0d0a8493          	addi	s1,s5,208
    80001d7e:	0d0a0913          	addi	s2,s4,208
    80001d82:	150a8993          	addi	s3,s5,336
    80001d86:	a831                	j	80001da2 <kfork+0x96>
    freeproc(np);
    80001d88:	8552                	mv	a0,s4
    80001d8a:	df3ff0ef          	jal	80001b7c <freeproc>
    release(&np->lock);
    80001d8e:	8552                	mv	a0,s4
    80001d90:	f21fe0ef          	jal	80000cb0 <release>
    return -1;
    80001d94:	54fd                	li	s1,-1
    80001d96:	6a42                	ld	s4,16(sp)
    80001d98:	a885                	j	80001e08 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001d9a:	04a1                	addi	s1,s1,8
    80001d9c:	0921                	addi	s2,s2,8
    80001d9e:	01348963          	beq	s1,s3,80001db0 <kfork+0xa4>
    if (p->ofile[i])
    80001da2:	6088                	ld	a0,0(s1)
    80001da4:	d97d                	beqz	a0,80001d9a <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001da6:	436020ef          	jal	800041dc <filedup>
    80001daa:	00a93023          	sd	a0,0(s2)
    80001dae:	b7f5                	j	80001d9a <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001db0:	150ab503          	ld	a0,336(s5)
    80001db4:	506010ef          	jal	800032ba <idup>
    80001db8:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001dbc:	4641                	li	a2,16
    80001dbe:	158a8593          	addi	a1,s5,344
    80001dc2:	158a0513          	addi	a0,s4,344
    80001dc6:	876ff0ef          	jal	80000e3c <safestrcpy>
  pid = np->pid;
    80001dca:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001dce:	8552                	mv	a0,s4
    80001dd0:	ee1fe0ef          	jal	80000cb0 <release>
  acquire(&wait_lock);
    80001dd4:	00010517          	auipc	a0,0x10
    80001dd8:	6bc50513          	addi	a0,a0,1724 # 80012490 <wait_lock>
    80001ddc:	e4dfe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001de0:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001de4:	00010517          	auipc	a0,0x10
    80001de8:	6ac50513          	addi	a0,a0,1708 # 80012490 <wait_lock>
    80001dec:	ec5fe0ef          	jal	80000cb0 <release>
  acquire(&np->lock);
    80001df0:	8552                	mv	a0,s4
    80001df2:	e37fe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001df6:	478d                	li	a5,3
    80001df8:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001dfc:	8552                	mv	a0,s4
    80001dfe:	eb3fe0ef          	jal	80000cb0 <release>
  return pid;
    80001e02:	7902                	ld	s2,32(sp)
    80001e04:	69e2                	ld	s3,24(sp)
    80001e06:	6a42                	ld	s4,16(sp)
}
    80001e08:	8526                	mv	a0,s1
    80001e0a:	70e2                	ld	ra,56(sp)
    80001e0c:	7442                	ld	s0,48(sp)
    80001e0e:	74a2                	ld	s1,40(sp)
    80001e10:	6aa2                	ld	s5,8(sp)
    80001e12:	6121                	addi	sp,sp,64
    80001e14:	8082                	ret
    return -1;
    80001e16:	54fd                	li	s1,-1
    80001e18:	bfc5                	j	80001e08 <kfork+0xfc>

0000000080001e1a <scheduler>:
{
    80001e1a:	711d                	addi	sp,sp,-96
    80001e1c:	ec86                	sd	ra,88(sp)
    80001e1e:	e8a2                	sd	s0,80(sp)
    80001e20:	e4a6                	sd	s1,72(sp)
    80001e22:	e0ca                	sd	s2,64(sp)
    80001e24:	fc4e                	sd	s3,56(sp)
    80001e26:	f852                	sd	s4,48(sp)
    80001e28:	f456                	sd	s5,40(sp)
    80001e2a:	f05a                	sd	s6,32(sp)
    80001e2c:	ec5e                	sd	s7,24(sp)
    80001e2e:	e862                	sd	s8,16(sp)
    80001e30:	e466                	sd	s9,8(sp)
    80001e32:	1080                	addi	s0,sp,96
    80001e34:	8792                	mv	a5,tp
  int id = r_tp();
    80001e36:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001e38:	00779a93          	slli	s5,a5,0x7
    80001e3c:	00010717          	auipc	a4,0x10
    80001e40:	63c70713          	addi	a4,a4,1596 # 80012478 <pid_lock>
    80001e44:	9756                	add	a4,a4,s5
    80001e46:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001e4a:	00010717          	auipc	a4,0x10
    80001e4e:	66670713          	addi	a4,a4,1638 # 800124b0 <cpus+0x8>
    80001e52:	9aba                	add	s5,s5,a4
        p->state = RUNNING;
    80001e54:	4c11                	li	s8,4
        c->proc = p;
    80001e56:	00010b17          	auipc	s6,0x10
    80001e5a:	622b0b13          	addi	s6,s6,1570 # 80012478 <pid_lock>
    80001e5e:	079e                	slli	a5,a5,0x7
    80001e60:	00fb0a33          	add	s4,s6,a5
        found = 1;
    80001e64:	4b85                	li	s7,1
    80001e66:	a0a9                	j	80001eb0 <scheduler+0x96>
      release(&p->lock);
    80001e68:	8526                	mv	a0,s1
    80001e6a:	e47fe0ef          	jal	80000cb0 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e6e:	16848493          	addi	s1,s1,360
    80001e72:	03248b63          	beq	s1,s2,80001ea8 <scheduler+0x8e>
      acquire(&p->lock);
    80001e76:	8526                	mv	a0,s1
    80001e78:	db1fe0ef          	jal	80000c28 <acquire>
      if (p->state == RUNNABLE) {
    80001e7c:	4c9c                	lw	a5,24(s1)
    80001e7e:	ff3795e3          	bne	a5,s3,80001e68 <scheduler+0x4e>
        p->state = RUNNING;
    80001e82:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001e86:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001e8a:	06048593          	addi	a1,s1,96
    80001e8e:	8556                	mv	a0,s5
    80001e90:	5f4000ef          	jal	80002484 <swtch>
    80001e94:	8792                	mv	a5,tp
        mycpu()->intena = 0;
    80001e96:	2781                	sext.w	a5,a5
    80001e98:	079e                	slli	a5,a5,0x7
    80001e9a:	97da                	add	a5,a5,s6
    80001e9c:	0a07a623          	sw	zero,172(a5)
        c->proc = 0;
    80001ea0:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001ea4:	8cde                	mv	s9,s7
    80001ea6:	b7c9                	j	80001e68 <scheduler+0x4e>
    if (found == 0) {
    80001ea8:	000c9463          	bnez	s9,80001eb0 <scheduler+0x96>
      asm volatile("wfi");
    80001eac:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001eb0:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001eb4:	10017073          	csrci	sstatus,2
    int found = 0;
    80001eb8:	4c81                	li	s9,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001eba:	00011497          	auipc	s1,0x11
    80001ebe:	9ee48493          	addi	s1,s1,-1554 # 800128a8 <proc>
      if (p->state == RUNNABLE) {
    80001ec2:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80001ec4:	00016917          	auipc	s2,0x16
    80001ec8:	3e490913          	addi	s2,s2,996 # 800182a8 <tickslock>
    80001ecc:	b76d                	j	80001e76 <scheduler+0x5c>

0000000080001ece <sched>:
{
    80001ece:	7179                	addi	sp,sp,-48
    80001ed0:	f406                	sd	ra,40(sp)
    80001ed2:	f022                	sd	s0,32(sp)
    80001ed4:	ec26                	sd	s1,24(sp)
    80001ed6:	e84a                	sd	s2,16(sp)
    80001ed8:	e44e                	sd	s3,8(sp)
    80001eda:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001edc:	ad1ff0ef          	jal	800019ac <myproc>
    80001ee0:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001ee2:	ce1fe0ef          	jal	80000bc2 <holding>
    80001ee6:	c935                	beqz	a0,80001f5a <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80001ee8:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001eea:	2781                	sext.w	a5,a5
    80001eec:	079e                	slli	a5,a5,0x7
    80001eee:	00010717          	auipc	a4,0x10
    80001ef2:	58a70713          	addi	a4,a4,1418 # 80012478 <pid_lock>
    80001ef6:	97ba                	add	a5,a5,a4
    80001ef8:	0a87a703          	lw	a4,168(a5)
    80001efc:	4785                	li	a5,1
    80001efe:	06f71463          	bne	a4,a5,80001f66 <sched+0x98>
  if (p->state == RUNNING)
    80001f02:	4c98                	lw	a4,24(s1)
    80001f04:	4791                	li	a5,4
    80001f06:	06f70663          	beq	a4,a5,80001f72 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001f0a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f0e:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001f10:	e7bd                	bnez	a5,80001f7e <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    80001f12:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f14:	00010917          	auipc	s2,0x10
    80001f18:	56490913          	addi	s2,s2,1380 # 80012478 <pid_lock>
    80001f1c:	2781                	sext.w	a5,a5
    80001f1e:	079e                	slli	a5,a5,0x7
    80001f20:	97ca                	add	a5,a5,s2
    80001f22:	0ac7a983          	lw	s3,172(a5)
    80001f26:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f28:	2781                	sext.w	a5,a5
    80001f2a:	079e                	slli	a5,a5,0x7
    80001f2c:	07a1                	addi	a5,a5,8
    80001f2e:	00010597          	auipc	a1,0x10
    80001f32:	57a58593          	addi	a1,a1,1402 # 800124a8 <cpus>
    80001f36:	95be                	add	a1,a1,a5
    80001f38:	06048513          	addi	a0,s1,96
    80001f3c:	548000ef          	jal	80002484 <swtch>
    80001f40:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f42:	2781                	sext.w	a5,a5
    80001f44:	079e                	slli	a5,a5,0x7
    80001f46:	993e                	add	s2,s2,a5
    80001f48:	0b392623          	sw	s3,172(s2)
}
    80001f4c:	70a2                	ld	ra,40(sp)
    80001f4e:	7402                	ld	s0,32(sp)
    80001f50:	64e2                	ld	s1,24(sp)
    80001f52:	6942                	ld	s2,16(sp)
    80001f54:	69a2                	ld	s3,8(sp)
    80001f56:	6145                	addi	sp,sp,48
    80001f58:	8082                	ret
    panic("sched p->lock");
    80001f5a:	00005517          	auipc	a0,0x5
    80001f5e:	23e50513          	addi	a0,a0,574 # 80007198 <etext+0x198>
    80001f62:	8d3fe0ef          	jal	80000834 <panic>
    panic("sched locks");
    80001f66:	00005517          	auipc	a0,0x5
    80001f6a:	24250513          	addi	a0,a0,578 # 800071a8 <etext+0x1a8>
    80001f6e:	8c7fe0ef          	jal	80000834 <panic>
    panic("sched RUNNING");
    80001f72:	00005517          	auipc	a0,0x5
    80001f76:	24650513          	addi	a0,a0,582 # 800071b8 <etext+0x1b8>
    80001f7a:	8bbfe0ef          	jal	80000834 <panic>
    panic("sched interruptible");
    80001f7e:	00005517          	auipc	a0,0x5
    80001f82:	24a50513          	addi	a0,a0,586 # 800071c8 <etext+0x1c8>
    80001f86:	8affe0ef          	jal	80000834 <panic>

0000000080001f8a <yield>:
{
    80001f8a:	1101                	addi	sp,sp,-32
    80001f8c:	ec06                	sd	ra,24(sp)
    80001f8e:	e822                	sd	s0,16(sp)
    80001f90:	e426                	sd	s1,8(sp)
    80001f92:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f94:	a19ff0ef          	jal	800019ac <myproc>
    80001f98:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f9a:	c8ffe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80001f9e:	478d                	li	a5,3
    80001fa0:	cc9c                	sw	a5,24(s1)
  sched();
    80001fa2:	f2dff0ef          	jal	80001ece <sched>
  release(&p->lock);
    80001fa6:	8526                	mv	a0,s1
    80001fa8:	d09fe0ef          	jal	80000cb0 <release>
}
    80001fac:	60e2                	ld	ra,24(sp)
    80001fae:	6442                	ld	s0,16(sp)
    80001fb0:	64a2                	ld	s1,8(sp)
    80001fb2:	6105                	addi	sp,sp,32
    80001fb4:	8082                	ret

0000000080001fb6 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80001fb6:	1101                	addi	sp,sp,-32
    80001fb8:	ec06                	sd	ra,24(sp)
    80001fba:	e822                	sd	s0,16(sp)
    80001fbc:	e426                	sd	s1,8(sp)
    80001fbe:	e04a                	sd	s2,0(sp)
    80001fc0:	1000                	addi	s0,sp,32
    80001fc2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001fc4:	9e9ff0ef          	jal	800019ac <myproc>
    80001fc8:	892a                	mv	s2,a0

  acquire(&p->lock);
    80001fca:	c5ffe0ef          	jal	80000c28 <acquire>
  if (chan == 0)
    80001fce:	cc81                	beqz	s1,80001fe6 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80001fd0:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80001fd4:	854a                	mv	a0,s2
    80001fd6:	cdbfe0ef          	jal	80000cb0 <release>
}
    80001fda:	60e2                	ld	ra,24(sp)
    80001fdc:	6442                	ld	s0,16(sp)
    80001fde:	64a2                	ld	s1,8(sp)
    80001fe0:	6902                	ld	s2,0(sp)
    80001fe2:	6105                	addi	sp,sp,32
    80001fe4:	8082                	ret
    panic("sleep_prepare: zero chan");
    80001fe6:	00005517          	auipc	a0,0x5
    80001fea:	1fa50513          	addi	a0,a0,506 # 800071e0 <etext+0x1e0>
    80001fee:	847fe0ef          	jal	80000834 <panic>

0000000080001ff2 <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    80001ff2:	1101                	addi	sp,sp,-32
    80001ff4:	ec06                	sd	ra,24(sp)
    80001ff6:	e822                	sd	s0,16(sp)
    80001ff8:	e426                	sd	s1,8(sp)
    80001ffa:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001ffc:	9b1ff0ef          	jal	800019ac <myproc>
    80002000:	84aa                	mv	s1,a0

  acquire(&p->lock);
    80002002:	c27fe0ef          	jal	80000c28 <acquire>
  if (p->chan != 0) {
    80002006:	709c                	ld	a5,32(s1)
    80002008:	c789                	beqz	a5,80002012 <sleep+0x20>
    p->state = SLEEPING;
    8000200a:	4789                	li	a5,2
    8000200c:	cc9c                	sw	a5,24(s1)
    sched();
    8000200e:	ec1ff0ef          	jal	80001ece <sched>
  }
  release(&p->lock);
    80002012:	8526                	mv	a0,s1
    80002014:	c9dfe0ef          	jal	80000cb0 <release>
}
    80002018:	60e2                	ld	ra,24(sp)
    8000201a:	6442                	ld	s0,16(sp)
    8000201c:	64a2                	ld	s1,8(sp)
    8000201e:	6105                	addi	sp,sp,32
    80002020:	8082                	ret

0000000080002022 <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    80002022:	7139                	addi	sp,sp,-64
    80002024:	fc06                	sd	ra,56(sp)
    80002026:	f822                	sd	s0,48(sp)
    80002028:	f426                	sd	s1,40(sp)
    8000202a:	f04a                	sd	s2,32(sp)
    8000202c:	ec4e                	sd	s3,24(sp)
    8000202e:	e852                	sd	s4,16(sp)
    80002030:	e456                	sd	s5,8(sp)
    80002032:	0080                	addi	s0,sp,64
    80002034:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002036:	00011497          	auipc	s1,0x11
    8000203a:	87248493          	addi	s1,s1,-1934 # 800128a8 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    8000203e:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80002040:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80002042:	00016997          	auipc	s3,0x16
    80002046:	26698993          	addi	s3,s3,614 # 800182a8 <tickslock>
    8000204a:	a801                	j	8000205a <wakeup+0x38>
      }
    }
    release(&p->lock);
    8000204c:	8526                	mv	a0,s1
    8000204e:	c63fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002052:	16848493          	addi	s1,s1,360
    80002056:	03348063          	beq	s1,s3,80002076 <wakeup+0x54>
    acquire(&p->lock);
    8000205a:	8526                	mv	a0,s1
    8000205c:	bcdfe0ef          	jal	80000c28 <acquire>
    if (p->chan == chan) {
    80002060:	709c                	ld	a5,32(s1)
    80002062:	ff2795e3          	bne	a5,s2,8000204c <wakeup+0x2a>
      p->chan = 0;
    80002066:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    8000206a:	4c9c                	lw	a5,24(s1)
    8000206c:	ff4790e3          	bne	a5,s4,8000204c <wakeup+0x2a>
        p->state = RUNNABLE;
    80002070:	0154ac23          	sw	s5,24(s1)
    80002074:	bfe1                	j	8000204c <wakeup+0x2a>
  }
}
    80002076:	70e2                	ld	ra,56(sp)
    80002078:	7442                	ld	s0,48(sp)
    8000207a:	74a2                	ld	s1,40(sp)
    8000207c:	7902                	ld	s2,32(sp)
    8000207e:	69e2                	ld	s3,24(sp)
    80002080:	6a42                	ld	s4,16(sp)
    80002082:	6aa2                	ld	s5,8(sp)
    80002084:	6121                	addi	sp,sp,64
    80002086:	8082                	ret

0000000080002088 <reparent>:
{
    80002088:	7179                	addi	sp,sp,-48
    8000208a:	f406                	sd	ra,40(sp)
    8000208c:	f022                	sd	s0,32(sp)
    8000208e:	ec26                	sd	s1,24(sp)
    80002090:	e84a                	sd	s2,16(sp)
    80002092:	e44e                	sd	s3,8(sp)
    80002094:	e052                	sd	s4,0(sp)
    80002096:	1800                	addi	s0,sp,48
    80002098:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000209a:	00011497          	auipc	s1,0x11
    8000209e:	80e48493          	addi	s1,s1,-2034 # 800128a8 <proc>
      pp->parent = initproc;
    800020a2:	00008a17          	auipc	s4,0x8
    800020a6:	2cea0a13          	addi	s4,s4,718 # 8000a370 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800020aa:	00016997          	auipc	s3,0x16
    800020ae:	1fe98993          	addi	s3,s3,510 # 800182a8 <tickslock>
    800020b2:	a029                	j	800020bc <reparent+0x34>
    800020b4:	16848493          	addi	s1,s1,360
    800020b8:	01348b63          	beq	s1,s3,800020ce <reparent+0x46>
    if (pp->parent == p) {
    800020bc:	7c9c                	ld	a5,56(s1)
    800020be:	ff279be3          	bne	a5,s2,800020b4 <reparent+0x2c>
      pp->parent = initproc;
    800020c2:	000a3503          	ld	a0,0(s4)
    800020c6:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800020c8:	f5bff0ef          	jal	80002022 <wakeup>
    800020cc:	b7e5                	j	800020b4 <reparent+0x2c>
}
    800020ce:	70a2                	ld	ra,40(sp)
    800020d0:	7402                	ld	s0,32(sp)
    800020d2:	64e2                	ld	s1,24(sp)
    800020d4:	6942                	ld	s2,16(sp)
    800020d6:	69a2                	ld	s3,8(sp)
    800020d8:	6a02                	ld	s4,0(sp)
    800020da:	6145                	addi	sp,sp,48
    800020dc:	8082                	ret

00000000800020de <kexit>:
{
    800020de:	7179                	addi	sp,sp,-48
    800020e0:	f406                	sd	ra,40(sp)
    800020e2:	f022                	sd	s0,32(sp)
    800020e4:	ec26                	sd	s1,24(sp)
    800020e6:	e84a                	sd	s2,16(sp)
    800020e8:	e44e                	sd	s3,8(sp)
    800020ea:	e052                	sd	s4,0(sp)
    800020ec:	1800                	addi	s0,sp,48
    800020ee:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800020f0:	8bdff0ef          	jal	800019ac <myproc>
    800020f4:	89aa                	mv	s3,a0
  if (p == initproc)
    800020f6:	00008797          	auipc	a5,0x8
    800020fa:	27a7b783          	ld	a5,634(a5) # 8000a370 <initproc>
    800020fe:	0d050493          	addi	s1,a0,208
    80002102:	15050913          	addi	s2,a0,336
    80002106:	00a79b63          	bne	a5,a0,8000211c <kexit+0x3e>
    panic("init exiting");
    8000210a:	00005517          	auipc	a0,0x5
    8000210e:	0f650513          	addi	a0,a0,246 # 80007200 <etext+0x200>
    80002112:	f22fe0ef          	jal	80000834 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    80002116:	04a1                	addi	s1,s1,8
    80002118:	01248963          	beq	s1,s2,8000212a <kexit+0x4c>
    if (p->ofile[fd]) {
    8000211c:	6088                	ld	a0,0(s1)
    8000211e:	dd65                	beqz	a0,80002116 <kexit+0x38>
      fileclose(f);
    80002120:	102020ef          	jal	80004222 <fileclose>
      p->ofile[fd] = 0;
    80002124:	0004b023          	sd	zero,0(s1)
    80002128:	b7fd                	j	80002116 <kexit+0x38>
  begin_op();
    8000212a:	43f010ef          	jal	80003d68 <begin_op>
  iput(p->cwd);
    8000212e:	1509b503          	ld	a0,336(s3)
    80002132:	340010ef          	jal	80003472 <iput>
  end_op();
    80002136:	4bf010ef          	jal	80003df4 <end_op>
  p->cwd = 0;
    8000213a:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000213e:	00010517          	auipc	a0,0x10
    80002142:	35250513          	addi	a0,a0,850 # 80012490 <wait_lock>
    80002146:	ae3fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    8000214a:	854e                	mv	a0,s3
    8000214c:	f3dff0ef          	jal	80002088 <reparent>
  wakeup(p->parent);
    80002150:	0389b503          	ld	a0,56(s3)
    80002154:	ecfff0ef          	jal	80002022 <wakeup>
  acquire(&p->lock);
    80002158:	854e                	mv	a0,s3
    8000215a:	acffe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    8000215e:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002162:	4795                	li	a5,5
    80002164:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002168:	00010517          	auipc	a0,0x10
    8000216c:	32850513          	addi	a0,a0,808 # 80012490 <wait_lock>
    80002170:	b41fe0ef          	jal	80000cb0 <release>
  sched();
    80002174:	d5bff0ef          	jal	80001ece <sched>
  panic("zombie exit");
    80002178:	00005517          	auipc	a0,0x5
    8000217c:	09850513          	addi	a0,a0,152 # 80007210 <etext+0x210>
    80002180:	eb4fe0ef          	jal	80000834 <panic>

0000000080002184 <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    80002184:	c525                	beqz	a0,800021ec <kkill+0x68>
{
    80002186:	7179                	addi	sp,sp,-48
    80002188:	f406                	sd	ra,40(sp)
    8000218a:	f022                	sd	s0,32(sp)
    8000218c:	ec26                	sd	s1,24(sp)
    8000218e:	e84a                	sd	s2,16(sp)
    80002190:	e44e                	sd	s3,8(sp)
    80002192:	1800                	addi	s0,sp,48
    80002194:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002196:	00010497          	auipc	s1,0x10
    8000219a:	71248493          	addi	s1,s1,1810 # 800128a8 <proc>
    8000219e:	00016997          	auipc	s3,0x16
    800021a2:	10a98993          	addi	s3,s3,266 # 800182a8 <tickslock>
    acquire(&p->lock);
    800021a6:	8526                	mv	a0,s1
    800021a8:	a81fe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid) {
    800021ac:	589c                	lw	a5,48(s1)
    800021ae:	01278b63          	beq	a5,s2,800021c4 <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800021b2:	8526                	mv	a0,s1
    800021b4:	afdfe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800021b8:	16848493          	addi	s1,s1,360
    800021bc:	ff3495e3          	bne	s1,s3,800021a6 <kkill+0x22>
  }
  return -1;
    800021c0:	557d                	li	a0,-1
    800021c2:	a819                	j	800021d8 <kkill+0x54>
      p->killed = 1;
    800021c4:	4785                	li	a5,1
    800021c6:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    800021c8:	4c98                	lw	a4,24(s1)
    800021ca:	4789                	li	a5,2
    800021cc:	00f70d63          	beq	a4,a5,800021e6 <kkill+0x62>
      release(&p->lock);
    800021d0:	8526                	mv	a0,s1
    800021d2:	adffe0ef          	jal	80000cb0 <release>
      return 0;
    800021d6:	4501                	li	a0,0
}
    800021d8:	70a2                	ld	ra,40(sp)
    800021da:	7402                	ld	s0,32(sp)
    800021dc:	64e2                	ld	s1,24(sp)
    800021de:	6942                	ld	s2,16(sp)
    800021e0:	69a2                	ld	s3,8(sp)
    800021e2:	6145                	addi	sp,sp,48
    800021e4:	8082                	ret
        p->state = RUNNABLE;
    800021e6:	478d                	li	a5,3
    800021e8:	cc9c                	sw	a5,24(s1)
    800021ea:	b7dd                	j	800021d0 <kkill+0x4c>
    return -1;
    800021ec:	557d                	li	a0,-1
}
    800021ee:	8082                	ret

00000000800021f0 <setkilled>:

void
setkilled(struct proc *p)
{
    800021f0:	1101                	addi	sp,sp,-32
    800021f2:	ec06                	sd	ra,24(sp)
    800021f4:	e822                	sd	s0,16(sp)
    800021f6:	e426                	sd	s1,8(sp)
    800021f8:	1000                	addi	s0,sp,32
    800021fa:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021fc:	a2dfe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    80002200:	4785                	li	a5,1
    80002202:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002204:	8526                	mv	a0,s1
    80002206:	aabfe0ef          	jal	80000cb0 <release>
}
    8000220a:	60e2                	ld	ra,24(sp)
    8000220c:	6442                	ld	s0,16(sp)
    8000220e:	64a2                	ld	s1,8(sp)
    80002210:	6105                	addi	sp,sp,32
    80002212:	8082                	ret

0000000080002214 <killed>:

int
killed(struct proc *p)
{
    80002214:	1101                	addi	sp,sp,-32
    80002216:	ec06                	sd	ra,24(sp)
    80002218:	e822                	sd	s0,16(sp)
    8000221a:	e426                	sd	s1,8(sp)
    8000221c:	e04a                	sd	s2,0(sp)
    8000221e:	1000                	addi	s0,sp,32
    80002220:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002222:	a07fe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    80002226:	549c                	lw	a5,40(s1)
    80002228:	893e                	mv	s2,a5
  release(&p->lock);
    8000222a:	8526                	mv	a0,s1
    8000222c:	a85fe0ef          	jal	80000cb0 <release>
  return k;
}
    80002230:	854a                	mv	a0,s2
    80002232:	60e2                	ld	ra,24(sp)
    80002234:	6442                	ld	s0,16(sp)
    80002236:	64a2                	ld	s1,8(sp)
    80002238:	6902                	ld	s2,0(sp)
    8000223a:	6105                	addi	sp,sp,32
    8000223c:	8082                	ret

000000008000223e <kwait>:
{
    8000223e:	715d                	addi	sp,sp,-80
    80002240:	e486                	sd	ra,72(sp)
    80002242:	e0a2                	sd	s0,64(sp)
    80002244:	fc26                	sd	s1,56(sp)
    80002246:	f84a                	sd	s2,48(sp)
    80002248:	f44e                	sd	s3,40(sp)
    8000224a:	f052                	sd	s4,32(sp)
    8000224c:	ec56                	sd	s5,24(sp)
    8000224e:	e85a                	sd	s6,16(sp)
    80002250:	e45e                	sd	s7,8(sp)
    80002252:	0880                	addi	s0,sp,80
    80002254:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002256:	f56ff0ef          	jal	800019ac <myproc>
    8000225a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000225c:	00010517          	auipc	a0,0x10
    80002260:	23450513          	addi	a0,a0,564 # 80012490 <wait_lock>
    80002264:	9c5fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    80002268:	4a15                	li	s4,5
        havekids = 1;
    8000226a:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000226c:	00016997          	auipc	s3,0x16
    80002270:	03c98993          	addi	s3,s3,60 # 800182a8 <tickslock>
    release(&wait_lock);
    80002274:	00010b17          	auipc	s6,0x10
    80002278:	21cb0b13          	addi	s6,s6,540 # 80012490 <wait_lock>
    8000227c:	a845                	j	8000232c <kwait+0xee>
          pid = pp->pid;
    8000227e:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    80002282:	000b8e63          	beqz	s7,8000229e <kwait+0x60>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    80002286:	4711                	li	a4,4
    80002288:	02c48693          	addi	a3,s1,44
    8000228c:	865e                	mv	a2,s7
    8000228e:	04893583          	ld	a1,72(s2)
    80002292:	05093503          	ld	a0,80(s2)
    80002296:	aecff0ef          	jal	80001582 <copyout>
          if (addr != 0 &&
    8000229a:	02054c63          	bltz	a0,800022d2 <kwait+0x94>
          pp->parent = 0;
    8000229e:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    800022a2:	8526                	mv	a0,s1
    800022a4:	8d9ff0ef          	jal	80001b7c <freeproc>
          release(&pp->lock);
    800022a8:	8526                	mv	a0,s1
    800022aa:	a07fe0ef          	jal	80000cb0 <release>
          release(&wait_lock);
    800022ae:	00010517          	auipc	a0,0x10
    800022b2:	1e250513          	addi	a0,a0,482 # 80012490 <wait_lock>
    800022b6:	9fbfe0ef          	jal	80000cb0 <release>
}
    800022ba:	854e                	mv	a0,s3
    800022bc:	60a6                	ld	ra,72(sp)
    800022be:	6406                	ld	s0,64(sp)
    800022c0:	74e2                	ld	s1,56(sp)
    800022c2:	7942                	ld	s2,48(sp)
    800022c4:	79a2                	ld	s3,40(sp)
    800022c6:	7a02                	ld	s4,32(sp)
    800022c8:	6ae2                	ld	s5,24(sp)
    800022ca:	6b42                	ld	s6,16(sp)
    800022cc:	6ba2                	ld	s7,8(sp)
    800022ce:	6161                	addi	sp,sp,80
    800022d0:	8082                	ret
            release(&pp->lock);
    800022d2:	8526                	mv	a0,s1
    800022d4:	9ddfe0ef          	jal	80000cb0 <release>
            release(&wait_lock);
    800022d8:	00010517          	auipc	a0,0x10
    800022dc:	1b850513          	addi	a0,a0,440 # 80012490 <wait_lock>
    800022e0:	9d1fe0ef          	jal	80000cb0 <release>
            return -1;
    800022e4:	59fd                	li	s3,-1
    800022e6:	bfd1                	j	800022ba <kwait+0x7c>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800022e8:	16848493          	addi	s1,s1,360
    800022ec:	03348063          	beq	s1,s3,8000230c <kwait+0xce>
      if (pp->parent == p) {
    800022f0:	7c9c                	ld	a5,56(s1)
    800022f2:	ff279be3          	bne	a5,s2,800022e8 <kwait+0xaa>
        acquire(&pp->lock);
    800022f6:	8526                	mv	a0,s1
    800022f8:	931fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    800022fc:	4c9c                	lw	a5,24(s1)
    800022fe:	f94780e3          	beq	a5,s4,8000227e <kwait+0x40>
        release(&pp->lock);
    80002302:	8526                	mv	a0,s1
    80002304:	9adfe0ef          	jal	80000cb0 <release>
        havekids = 1;
    80002308:	8756                	mv	a4,s5
    8000230a:	bff9                	j	800022e8 <kwait+0xaa>
    if (!havekids || killed(p)) {
    8000230c:	c715                	beqz	a4,80002338 <kwait+0xfa>
    8000230e:	854a                	mv	a0,s2
    80002310:	f05ff0ef          	jal	80002214 <killed>
    80002314:	e115                	bnez	a0,80002338 <kwait+0xfa>
    sleep_prepare(p); //DOC: wait-sleep
    80002316:	854a                	mv	a0,s2
    80002318:	c9fff0ef          	jal	80001fb6 <sleep_prepare>
    release(&wait_lock);
    8000231c:	855a                	mv	a0,s6
    8000231e:	993fe0ef          	jal	80000cb0 <release>
    sleep();
    80002322:	cd1ff0ef          	jal	80001ff2 <sleep>
    acquire(&wait_lock);
    80002326:	855a                	mv	a0,s6
    80002328:	901fe0ef          	jal	80000c28 <acquire>
    havekids = 0;
    8000232c:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000232e:	00010497          	auipc	s1,0x10
    80002332:	57a48493          	addi	s1,s1,1402 # 800128a8 <proc>
    80002336:	bf6d                	j	800022f0 <kwait+0xb2>
      release(&wait_lock);
    80002338:	00010517          	auipc	a0,0x10
    8000233c:	15850513          	addi	a0,a0,344 # 80012490 <wait_lock>
    80002340:	971fe0ef          	jal	80000cb0 <release>
      return -1;
    80002344:	59fd                	li	s3,-1
    80002346:	bf95                	j	800022ba <kwait+0x7c>

0000000080002348 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002348:	7179                	addi	sp,sp,-48
    8000234a:	f406                	sd	ra,40(sp)
    8000234c:	f022                	sd	s0,32(sp)
    8000234e:	ec26                	sd	s1,24(sp)
    80002350:	e84a                	sd	s2,16(sp)
    80002352:	e44e                	sd	s3,8(sp)
    80002354:	e052                	sd	s4,0(sp)
    80002356:	1800                	addi	s0,sp,48
    80002358:	84aa                	mv	s1,a0
    8000235a:	8a2e                	mv	s4,a1
    8000235c:	89b2                	mv	s3,a2
    8000235e:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002360:	e4cff0ef          	jal	800019ac <myproc>
  if (user_dst) {
    80002364:	c085                	beqz	s1,80002384 <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    80002366:	874a                	mv	a4,s2
    80002368:	86ce                	mv	a3,s3
    8000236a:	8652                	mv	a2,s4
    8000236c:	652c                	ld	a1,72(a0)
    8000236e:	6928                	ld	a0,80(a0)
    80002370:	a12ff0ef          	jal	80001582 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002374:	70a2                	ld	ra,40(sp)
    80002376:	7402                	ld	s0,32(sp)
    80002378:	64e2                	ld	s1,24(sp)
    8000237a:	6942                	ld	s2,16(sp)
    8000237c:	69a2                	ld	s3,8(sp)
    8000237e:	6a02                	ld	s4,0(sp)
    80002380:	6145                	addi	sp,sp,48
    80002382:	8082                	ret
    memmove((char *)dst, src, len);
    80002384:	0009061b          	sext.w	a2,s2
    80002388:	85ce                	mv	a1,s3
    8000238a:	8552                	mv	a0,s4
    8000238c:	9bdfe0ef          	jal	80000d48 <memmove>
    return 0;
    80002390:	8526                	mv	a0,s1
    80002392:	b7cd                	j	80002374 <either_copyout+0x2c>

0000000080002394 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002394:	7179                	addi	sp,sp,-48
    80002396:	f406                	sd	ra,40(sp)
    80002398:	f022                	sd	s0,32(sp)
    8000239a:	ec26                	sd	s1,24(sp)
    8000239c:	e84a                	sd	s2,16(sp)
    8000239e:	e44e                	sd	s3,8(sp)
    800023a0:	e052                	sd	s4,0(sp)
    800023a2:	1800                	addi	s0,sp,48
    800023a4:	8a2a                	mv	s4,a0
    800023a6:	84ae                	mv	s1,a1
    800023a8:	89b2                	mv	s3,a2
    800023aa:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800023ac:	e00ff0ef          	jal	800019ac <myproc>
  if (user_src) {
    800023b0:	c085                	beqz	s1,800023d0 <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    800023b2:	874a                	mv	a4,s2
    800023b4:	86ce                	mv	a3,s3
    800023b6:	8652                	mv	a2,s4
    800023b8:	652c                	ld	a1,72(a0)
    800023ba:	6928                	ld	a0,80(a0)
    800023bc:	a8cff0ef          	jal	80001648 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800023c0:	70a2                	ld	ra,40(sp)
    800023c2:	7402                	ld	s0,32(sp)
    800023c4:	64e2                	ld	s1,24(sp)
    800023c6:	6942                	ld	s2,16(sp)
    800023c8:	69a2                	ld	s3,8(sp)
    800023ca:	6a02                	ld	s4,0(sp)
    800023cc:	6145                	addi	sp,sp,48
    800023ce:	8082                	ret
    memmove(dst, (char *)src, len);
    800023d0:	0009061b          	sext.w	a2,s2
    800023d4:	85ce                	mv	a1,s3
    800023d6:	8552                	mv	a0,s4
    800023d8:	971fe0ef          	jal	80000d48 <memmove>
    return 0;
    800023dc:	8526                	mv	a0,s1
    800023de:	b7cd                	j	800023c0 <either_copyin+0x2c>

00000000800023e0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800023e0:	715d                	addi	sp,sp,-80
    800023e2:	e486                	sd	ra,72(sp)
    800023e4:	e0a2                	sd	s0,64(sp)
    800023e6:	fc26                	sd	s1,56(sp)
    800023e8:	f84a                	sd	s2,48(sp)
    800023ea:	f44e                	sd	s3,40(sp)
    800023ec:	f052                	sd	s4,32(sp)
    800023ee:	ec56                	sd	s5,24(sp)
    800023f0:	e85a                	sd	s6,16(sp)
    800023f2:	e45e                	sd	s7,8(sp)
    800023f4:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    800023f6:	00005517          	auipc	a0,0x5
    800023fa:	c8250513          	addi	a0,a0,-894 # 80007078 <etext+0x78>
    800023fe:	90cfe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002402:	00010497          	auipc	s1,0x10
    80002406:	5fe48493          	addi	s1,s1,1534 # 80012a00 <proc+0x158>
    8000240a:	00016917          	auipc	s2,0x16
    8000240e:	ff690913          	addi	s2,s2,-10 # 80018400 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002412:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002414:	00005997          	auipc	s3,0x5
    80002418:	e0c98993          	addi	s3,s3,-500 # 80007220 <etext+0x220>
    printk("%d %s %s", p->pid, state, p->name);
    8000241c:	00005a97          	auipc	s5,0x5
    80002420:	e0ca8a93          	addi	s5,s5,-500 # 80007228 <etext+0x228>
    printk("\n");
    80002424:	00005a17          	auipc	s4,0x5
    80002428:	c54a0a13          	addi	s4,s4,-940 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000242c:	00005b97          	auipc	s7,0x5
    80002430:	31cb8b93          	addi	s7,s7,796 # 80007748 <states.0>
    80002434:	a829                	j	8000244e <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    80002436:	ed86a583          	lw	a1,-296(a3)
    8000243a:	8556                	mv	a0,s5
    8000243c:	8cefe0ef          	jal	8000050a <printk>
    printk("\n");
    80002440:	8552                	mv	a0,s4
    80002442:	8c8fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002446:	16848493          	addi	s1,s1,360
    8000244a:	03248263          	beq	s1,s2,8000246e <procdump+0x8e>
    if (p->state == UNUSED)
    8000244e:	86a6                	mv	a3,s1
    80002450:	ec04a783          	lw	a5,-320(s1)
    80002454:	dbed                	beqz	a5,80002446 <procdump+0x66>
      state = "???";
    80002456:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002458:	fcfb6fe3          	bltu	s6,a5,80002436 <procdump+0x56>
    8000245c:	02079713          	slli	a4,a5,0x20
    80002460:	01d75793          	srli	a5,a4,0x1d
    80002464:	97de                	add	a5,a5,s7
    80002466:	6390                	ld	a2,0(a5)
    80002468:	f679                	bnez	a2,80002436 <procdump+0x56>
      state = "???";
    8000246a:	864e                	mv	a2,s3
    8000246c:	b7e9                	j	80002436 <procdump+0x56>
  }
}
    8000246e:	60a6                	ld	ra,72(sp)
    80002470:	6406                	ld	s0,64(sp)
    80002472:	74e2                	ld	s1,56(sp)
    80002474:	7942                	ld	s2,48(sp)
    80002476:	79a2                	ld	s3,40(sp)
    80002478:	7a02                	ld	s4,32(sp)
    8000247a:	6ae2                	ld	s5,24(sp)
    8000247c:	6b42                	ld	s6,16(sp)
    8000247e:	6ba2                	ld	s7,8(sp)
    80002480:	6161                	addi	sp,sp,80
    80002482:	8082                	ret

0000000080002484 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002484:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002488:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000248c:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000248e:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002490:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002494:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002498:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    8000249c:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800024a0:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800024a4:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800024a8:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800024ac:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800024b0:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800024b4:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800024b8:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800024bc:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800024c0:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800024c2:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800024c4:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800024c8:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800024cc:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800024d0:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800024d4:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800024d8:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800024dc:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800024e0:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800024e4:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800024e8:	0685bd83          	ld	s11,104(a1)
        
        ret
    800024ec:	8082                	ret

00000000800024ee <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800024ee:	1141                	addi	sp,sp,-16
    800024f0:	e406                	sd	ra,8(sp)
    800024f2:	e022                	sd	s0,0(sp)
    800024f4:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800024f6:	00005597          	auipc	a1,0x5
    800024fa:	d7258593          	addi	a1,a1,-654 # 80007268 <etext+0x268>
    800024fe:	00016517          	auipc	a0,0x16
    80002502:	daa50513          	addi	a0,a0,-598 # 800182a8 <tickslock>
    80002506:	ea2fe0ef          	jal	80000ba8 <initlock>
}
    8000250a:	60a2                	ld	ra,8(sp)
    8000250c:	6402                	ld	s0,0(sp)
    8000250e:	0141                	addi	sp,sp,16
    80002510:	8082                	ret

0000000080002512 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002512:	1141                	addi	sp,sp,-16
    80002514:	e406                	sd	ra,8(sp)
    80002516:	e022                	sd	s0,0(sp)
    80002518:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    8000251a:	00003797          	auipc	a5,0x3
    8000251e:	19678793          	addi	a5,a5,406 # 800056b0 <kernelvec>
    80002522:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002526:	60a2                	ld	ra,8(sp)
    80002528:	6402                	ld	s0,0(sp)
    8000252a:	0141                	addi	sp,sp,16
    8000252c:	8082                	ret

000000008000252e <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000252e:	1141                	addi	sp,sp,-16
    80002530:	e406                	sd	ra,8(sp)
    80002532:	e022                	sd	s0,0(sp)
    80002534:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002536:	c76ff0ef          	jal	800019ac <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    8000253a:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000253e:	04000737          	lui	a4,0x4000
    80002542:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002544:	0732                	slli	a4,a4,0xc
    80002546:	00004797          	auipc	a5,0x4
    8000254a:	aba78793          	addi	a5,a5,-1350 # 80006000 <_trampoline>
    8000254e:	00004697          	auipc	a3,0x4
    80002552:	ab268693          	addi	a3,a3,-1358 # 80006000 <_trampoline>
    80002556:	8f95                	sub	a5,a5,a3
    80002558:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    8000255a:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000255e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    80002560:	18002773          	csrr	a4,satp
    80002564:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002566:	6d38                	ld	a4,88(a0)
    80002568:	613c                	ld	a5,64(a0)
    8000256a:	6685                	lui	a3,0x1
    8000256c:	97b6                	add	a5,a5,a3
    8000256e:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002570:	6d3c                	ld	a5,88(a0)
    80002572:	00000717          	auipc	a4,0x0
    80002576:	0fc70713          	addi	a4,a4,252 # 8000266e <usertrap>
    8000257a:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    8000257c:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    8000257e:	8712                	mv	a4,tp
    80002580:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002582:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002586:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000258a:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    8000258e:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002592:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002594:	6f9c                	ld	a5,24(a5)
    80002596:	14179073          	csrw	sepc,a5
}
    8000259a:	60a2                	ld	ra,8(sp)
    8000259c:	6402                	ld	s0,0(sp)
    8000259e:	0141                	addi	sp,sp,16
    800025a0:	8082                	ret

00000000800025a2 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800025a2:	1141                	addi	sp,sp,-16
    800025a4:	e406                	sd	ra,8(sp)
    800025a6:	e022                	sd	s0,0(sp)
    800025a8:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    800025aa:	bceff0ef          	jal	80001978 <cpuid>
    800025ae:	cd11                	beqz	a0,800025ca <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    800025b0:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800025b4:	000f4737          	lui	a4,0xf4
    800025b8:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800025bc:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    800025be:	14d79073          	csrw	stimecmp,a5
}
    800025c2:	60a2                	ld	ra,8(sp)
    800025c4:	6402                	ld	s0,0(sp)
    800025c6:	0141                	addi	sp,sp,16
    800025c8:	8082                	ret
    acquire(&tickslock);
    800025ca:	00016517          	auipc	a0,0x16
    800025ce:	cde50513          	addi	a0,a0,-802 # 800182a8 <tickslock>
    800025d2:	e56fe0ef          	jal	80000c28 <acquire>
    ticks++;
    800025d6:	00008717          	auipc	a4,0x8
    800025da:	da270713          	addi	a4,a4,-606 # 8000a378 <ticks>
    800025de:	431c                	lw	a5,0(a4)
    800025e0:	2785                	addiw	a5,a5,1
    800025e2:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    800025e4:	853a                	mv	a0,a4
    800025e6:	a3dff0ef          	jal	80002022 <wakeup>
    release(&tickslock);
    800025ea:	00016517          	auipc	a0,0x16
    800025ee:	cbe50513          	addi	a0,a0,-834 # 800182a8 <tickslock>
    800025f2:	ebefe0ef          	jal	80000cb0 <release>
    800025f6:	bf6d                	j	800025b0 <clockintr+0xe>

00000000800025f8 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800025f8:	1101                	addi	sp,sp,-32
    800025fa:	ec06                	sd	ra,24(sp)
    800025fc:	e822                	sd	s0,16(sp)
    800025fe:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    80002600:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    80002604:	57fd                	li	a5,-1
    80002606:	17fe                	slli	a5,a5,0x3f
    80002608:	07a5                	addi	a5,a5,9
    8000260a:	00f70c63          	beq	a4,a5,80002622 <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    8000260e:	57fd                	li	a5,-1
    80002610:	17fe                	slli	a5,a5,0x3f
    80002612:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002614:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    80002616:	04f70863          	beq	a4,a5,80002666 <devintr+0x6e>
  }
}
    8000261a:	60e2                	ld	ra,24(sp)
    8000261c:	6442                	ld	s0,16(sp)
    8000261e:	6105                	addi	sp,sp,32
    80002620:	8082                	ret
    80002622:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002624:	13a030ef          	jal	8000575e <plic_claim>
    80002628:	872a                	mv	a4,a0
    8000262a:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    8000262c:	47a9                	li	a5,10
    8000262e:	00f50963          	beq	a0,a5,80002640 <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    80002632:	4785                	li	a5,1
    80002634:	00f50963          	beq	a0,a5,80002646 <devintr+0x4e>
    return 1;
    80002638:	4505                	li	a0,1
    } else if (irq) {
    8000263a:	eb09                	bnez	a4,8000264c <devintr+0x54>
    8000263c:	64a2                	ld	s1,8(sp)
    8000263e:	bff1                	j	8000261a <devintr+0x22>
      uartintr();
    80002640:	baefe0ef          	jal	800009ee <uartintr>
    if (irq)
    80002644:	a819                	j	8000265a <devintr+0x62>
      virtio_disk_intr();
    80002646:	5d4030ef          	jal	80005c1a <virtio_disk_intr>
    if (irq)
    8000264a:	a801                	j	8000265a <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    8000264c:	85ba                	mv	a1,a4
    8000264e:	00005517          	auipc	a0,0x5
    80002652:	c2250513          	addi	a0,a0,-990 # 80007270 <etext+0x270>
    80002656:	eb5fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    8000265a:	8526                	mv	a0,s1
    8000265c:	124030ef          	jal	80005780 <plic_complete>
    return 1;
    80002660:	4505                	li	a0,1
    80002662:	64a2                	ld	s1,8(sp)
    80002664:	bf5d                	j	8000261a <devintr+0x22>
    clockintr();
    80002666:	f3dff0ef          	jal	800025a2 <clockintr>
    return 2;
    8000266a:	4509                	li	a0,2
    8000266c:	b77d                	j	8000261a <devintr+0x22>

000000008000266e <usertrap>:
{
    8000266e:	1101                	addi	sp,sp,-32
    80002670:	ec06                	sd	ra,24(sp)
    80002672:	e822                	sd	s0,16(sp)
    80002674:	e426                	sd	s1,8(sp)
    80002676:	e04a                	sd	s2,0(sp)
    80002678:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000267a:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    8000267e:	1007f793          	andi	a5,a5,256
    80002682:	eba5                	bnez	a5,800026f2 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002684:	00003797          	auipc	a5,0x3
    80002688:	02c78793          	addi	a5,a5,44 # 800056b0 <kernelvec>
    8000268c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002690:	b1cff0ef          	jal	800019ac <myproc>
    80002694:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002696:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002698:	14102773          	csrr	a4,sepc
    8000269c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    8000269e:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    800026a2:	47a1                	li	a5,8
    800026a4:	04f70d63          	beq	a4,a5,800026fe <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    800026a8:	f51ff0ef          	jal	800025f8 <devintr>
    800026ac:	892a                	mv	s2,a0
    800026ae:	e54d                	bnez	a0,80002758 <usertrap+0xea>
    800026b0:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    800026b4:	47bd                	li	a5,15
    800026b6:	08f70463          	beq	a4,a5,8000273e <usertrap+0xd0>
    800026ba:	14202773          	csrr	a4,scause
    800026be:	47b5                	li	a5,13
    800026c0:	06f70f63          	beq	a4,a5,8000273e <usertrap+0xd0>
    800026c4:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800026c8:	5890                	lw	a2,48(s1)
    800026ca:	00005517          	auipc	a0,0x5
    800026ce:	be650513          	addi	a0,a0,-1050 # 800072b0 <etext+0x2b0>
    800026d2:	e39fd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800026d6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800026da:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800026de:	00005517          	auipc	a0,0x5
    800026e2:	c0250513          	addi	a0,a0,-1022 # 800072e0 <etext+0x2e0>
    800026e6:	e25fd0ef          	jal	8000050a <printk>
    setkilled(p);
    800026ea:	8526                	mv	a0,s1
    800026ec:	b05ff0ef          	jal	800021f0 <setkilled>
    800026f0:	a015                	j	80002714 <usertrap+0xa6>
    panic("usertrap: not from user mode");
    800026f2:	00005517          	auipc	a0,0x5
    800026f6:	b9e50513          	addi	a0,a0,-1122 # 80007290 <etext+0x290>
    800026fa:	93afe0ef          	jal	80000834 <panic>
    if (killed(p))
    800026fe:	b17ff0ef          	jal	80002214 <killed>
    80002702:	e915                	bnez	a0,80002736 <usertrap+0xc8>
    p->trapframe->epc += 4;
    80002704:	6cb8                	ld	a4,88(s1)
    80002706:	6f1c                	ld	a5,24(a4)
    80002708:	0791                	addi	a5,a5,4
    8000270a:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    8000270c:	10016073          	csrsi	sstatus,2
    syscall();
    80002710:	244000ef          	jal	80002954 <syscall>
  if (killed(p))
    80002714:	8526                	mv	a0,s1
    80002716:	affff0ef          	jal	80002214 <killed>
    8000271a:	e521                	bnez	a0,80002762 <usertrap+0xf4>
  prepare_return();
    8000271c:	e13ff0ef          	jal	8000252e <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002720:	68a8                	ld	a0,80(s1)
    80002722:	8131                	srli	a0,a0,0xc
    80002724:	57fd                	li	a5,-1
    80002726:	17fe                	slli	a5,a5,0x3f
    80002728:	8d5d                	or	a0,a0,a5
}
    8000272a:	60e2                	ld	ra,24(sp)
    8000272c:	6442                	ld	s0,16(sp)
    8000272e:	64a2                	ld	s1,8(sp)
    80002730:	6902                	ld	s2,0(sp)
    80002732:	6105                	addi	sp,sp,32
    80002734:	8082                	ret
      kexit(-1);
    80002736:	557d                	li	a0,-1
    80002738:	9a7ff0ef          	jal	800020de <kexit>
    8000273c:	b7e1                	j	80002704 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    8000273e:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    80002742:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    80002746:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    80002748:	0016b693          	seqz	a3,a3
    8000274c:	64ac                	ld	a1,72(s1)
    8000274e:	68a8                	ld	a0,80(s1)
    80002750:	db7fe0ef          	jal	80001506 <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002754:	f161                	bnez	a0,80002714 <usertrap+0xa6>
    80002756:	b7bd                	j	800026c4 <usertrap+0x56>
  if (killed(p))
    80002758:	8526                	mv	a0,s1
    8000275a:	abbff0ef          	jal	80002214 <killed>
    8000275e:	c511                	beqz	a0,8000276a <usertrap+0xfc>
    80002760:	a011                	j	80002764 <usertrap+0xf6>
    80002762:	4901                	li	s2,0
    kexit(-1);
    80002764:	557d                	li	a0,-1
    80002766:	979ff0ef          	jal	800020de <kexit>
  if (which_dev == 2)
    8000276a:	4789                	li	a5,2
    8000276c:	faf918e3          	bne	s2,a5,8000271c <usertrap+0xae>
    yield();
    80002770:	81bff0ef          	jal	80001f8a <yield>
    80002774:	b765                	j	8000271c <usertrap+0xae>

0000000080002776 <kerneltrap>:
{
    80002776:	7179                	addi	sp,sp,-48
    80002778:	f406                	sd	ra,40(sp)
    8000277a:	f022                	sd	s0,32(sp)
    8000277c:	ec26                	sd	s1,24(sp)
    8000277e:	e84a                	sd	s2,16(sp)
    80002780:	e44e                	sd	s3,8(sp)
    80002782:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002784:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002788:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    8000278c:	142027f3          	csrr	a5,scause
    80002790:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    80002792:	1004f793          	andi	a5,s1,256
    80002796:	c795                	beqz	a5,800027c2 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002798:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000279c:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    8000279e:	eb85                	bnez	a5,800027ce <kerneltrap+0x58>
  if ((which_dev = devintr()) == 0) {
    800027a0:	e59ff0ef          	jal	800025f8 <devintr>
    800027a4:	c91d                	beqz	a0,800027da <kerneltrap+0x64>
  if (which_dev == 2 && myproc() != 0)
    800027a6:	4789                	li	a5,2
    800027a8:	04f50a63          	beq	a0,a5,800027fc <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    800027ac:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800027b0:	10049073          	csrw	sstatus,s1
}
    800027b4:	70a2                	ld	ra,40(sp)
    800027b6:	7402                	ld	s0,32(sp)
    800027b8:	64e2                	ld	s1,24(sp)
    800027ba:	6942                	ld	s2,16(sp)
    800027bc:	69a2                	ld	s3,8(sp)
    800027be:	6145                	addi	sp,sp,48
    800027c0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800027c2:	00005517          	auipc	a0,0x5
    800027c6:	b4650513          	addi	a0,a0,-1210 # 80007308 <etext+0x308>
    800027ca:	86afe0ef          	jal	80000834 <panic>
    panic("kerneltrap: interrupts enabled");
    800027ce:	00005517          	auipc	a0,0x5
    800027d2:	b6250513          	addi	a0,a0,-1182 # 80007330 <etext+0x330>
    800027d6:	85efe0ef          	jal	80000834 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800027da:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800027de:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    800027e2:	85ce                	mv	a1,s3
    800027e4:	00005517          	auipc	a0,0x5
    800027e8:	b6c50513          	addi	a0,a0,-1172 # 80007350 <etext+0x350>
    800027ec:	d1ffd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    800027f0:	00005517          	auipc	a0,0x5
    800027f4:	b8850513          	addi	a0,a0,-1144 # 80007378 <etext+0x378>
    800027f8:	83cfe0ef          	jal	80000834 <panic>
  if (which_dev == 2 && myproc() != 0)
    800027fc:	9b0ff0ef          	jal	800019ac <myproc>
    80002800:	d555                	beqz	a0,800027ac <kerneltrap+0x36>
    yield();
    80002802:	f88ff0ef          	jal	80001f8a <yield>
    80002806:	b75d                	j	800027ac <kerneltrap+0x36>

0000000080002808 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002808:	1101                	addi	sp,sp,-32
    8000280a:	ec06                	sd	ra,24(sp)
    8000280c:	e822                	sd	s0,16(sp)
    8000280e:	e426                	sd	s1,8(sp)
    80002810:	1000                	addi	s0,sp,32
    80002812:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002814:	998ff0ef          	jal	800019ac <myproc>
  switch (n) {
    80002818:	4795                	li	a5,5
    8000281a:	0497e163          	bltu	a5,s1,8000285c <argraw+0x54>
    8000281e:	048a                	slli	s1,s1,0x2
    80002820:	00005717          	auipc	a4,0x5
    80002824:	f5870713          	addi	a4,a4,-168 # 80007778 <states.0+0x30>
    80002828:	94ba                	add	s1,s1,a4
    8000282a:	409c                	lw	a5,0(s1)
    8000282c:	97ba                	add	a5,a5,a4
    8000282e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002830:	6d3c                	ld	a5,88(a0)
    80002832:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002834:	60e2                	ld	ra,24(sp)
    80002836:	6442                	ld	s0,16(sp)
    80002838:	64a2                	ld	s1,8(sp)
    8000283a:	6105                	addi	sp,sp,32
    8000283c:	8082                	ret
    return p->trapframe->a1;
    8000283e:	6d3c                	ld	a5,88(a0)
    80002840:	7fa8                	ld	a0,120(a5)
    80002842:	bfcd                	j	80002834 <argraw+0x2c>
    return p->trapframe->a2;
    80002844:	6d3c                	ld	a5,88(a0)
    80002846:	63c8                	ld	a0,128(a5)
    80002848:	b7f5                	j	80002834 <argraw+0x2c>
    return p->trapframe->a3;
    8000284a:	6d3c                	ld	a5,88(a0)
    8000284c:	67c8                	ld	a0,136(a5)
    8000284e:	b7dd                	j	80002834 <argraw+0x2c>
    return p->trapframe->a4;
    80002850:	6d3c                	ld	a5,88(a0)
    80002852:	6bc8                	ld	a0,144(a5)
    80002854:	b7c5                	j	80002834 <argraw+0x2c>
    return p->trapframe->a5;
    80002856:	6d3c                	ld	a5,88(a0)
    80002858:	6fc8                	ld	a0,152(a5)
    8000285a:	bfe9                	j	80002834 <argraw+0x2c>
  panic("argraw");
    8000285c:	00005517          	auipc	a0,0x5
    80002860:	b2c50513          	addi	a0,a0,-1236 # 80007388 <etext+0x388>
    80002864:	fd1fd0ef          	jal	80000834 <panic>

0000000080002868 <fetchaddr>:
{
    80002868:	1101                	addi	sp,sp,-32
    8000286a:	ec06                	sd	ra,24(sp)
    8000286c:	e822                	sd	s0,16(sp)
    8000286e:	e426                	sd	s1,8(sp)
    80002870:	e04a                	sd	s2,0(sp)
    80002872:	1000                	addi	s0,sp,32
    80002874:	84aa                	mv	s1,a0
    80002876:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002878:	934ff0ef          	jal	800019ac <myproc>
  if (addr >= p->sz ||
    8000287c:	652c                	ld	a1,72(a0)
    8000287e:	02b4f663          	bgeu	s1,a1,800028aa <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002882:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    80002886:	02f5e463          	bltu	a1,a5,800028ae <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    8000288a:	4721                	li	a4,8
    8000288c:	86a6                	mv	a3,s1
    8000288e:	864a                	mv	a2,s2
    80002890:	6928                	ld	a0,80(a0)
    80002892:	db7fe0ef          	jal	80001648 <copyin>
    80002896:	00a03533          	snez	a0,a0
    8000289a:	40a0053b          	negw	a0,a0
}
    8000289e:	60e2                	ld	ra,24(sp)
    800028a0:	6442                	ld	s0,16(sp)
    800028a2:	64a2                	ld	s1,8(sp)
    800028a4:	6902                	ld	s2,0(sp)
    800028a6:	6105                	addi	sp,sp,32
    800028a8:	8082                	ret
    return -1;
    800028aa:	557d                	li	a0,-1
    800028ac:	bfcd                	j	8000289e <fetchaddr+0x36>
    800028ae:	557d                	li	a0,-1
    800028b0:	b7fd                	j	8000289e <fetchaddr+0x36>

00000000800028b2 <fetchstr>:
{
    800028b2:	7179                	addi	sp,sp,-48
    800028b4:	f406                	sd	ra,40(sp)
    800028b6:	f022                	sd	s0,32(sp)
    800028b8:	ec26                	sd	s1,24(sp)
    800028ba:	e84a                	sd	s2,16(sp)
    800028bc:	e44e                	sd	s3,8(sp)
    800028be:	1800                	addi	s0,sp,48
    800028c0:	89aa                	mv	s3,a0
    800028c2:	84ae                	mv	s1,a1
    800028c4:	8932                	mv	s2,a2
  struct proc *p = myproc();
    800028c6:	8e6ff0ef          	jal	800019ac <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    800028ca:	874a                	mv	a4,s2
    800028cc:	86ce                	mv	a3,s3
    800028ce:	8626                	mv	a2,s1
    800028d0:	652c                	ld	a1,72(a0)
    800028d2:	6928                	ld	a0,80(a0)
    800028d4:	e11fe0ef          	jal	800016e4 <copyinstr>
    800028d8:	00054c63          	bltz	a0,800028f0 <fetchstr+0x3e>
  return strlen(buf);
    800028dc:	8526                	mv	a0,s1
    800028de:	d94fe0ef          	jal	80000e72 <strlen>
}
    800028e2:	70a2                	ld	ra,40(sp)
    800028e4:	7402                	ld	s0,32(sp)
    800028e6:	64e2                	ld	s1,24(sp)
    800028e8:	6942                	ld	s2,16(sp)
    800028ea:	69a2                	ld	s3,8(sp)
    800028ec:	6145                	addi	sp,sp,48
    800028ee:	8082                	ret
    return -1;
    800028f0:	557d                	li	a0,-1
    800028f2:	bfc5                	j	800028e2 <fetchstr+0x30>

00000000800028f4 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800028f4:	1101                	addi	sp,sp,-32
    800028f6:	ec06                	sd	ra,24(sp)
    800028f8:	e822                	sd	s0,16(sp)
    800028fa:	e426                	sd	s1,8(sp)
    800028fc:	1000                	addi	s0,sp,32
    800028fe:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002900:	f09ff0ef          	jal	80002808 <argraw>
    80002904:	c088                	sw	a0,0(s1)
}
    80002906:	60e2                	ld	ra,24(sp)
    80002908:	6442                	ld	s0,16(sp)
    8000290a:	64a2                	ld	s1,8(sp)
    8000290c:	6105                	addi	sp,sp,32
    8000290e:	8082                	ret

0000000080002910 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002910:	1101                	addi	sp,sp,-32
    80002912:	ec06                	sd	ra,24(sp)
    80002914:	e822                	sd	s0,16(sp)
    80002916:	e426                	sd	s1,8(sp)
    80002918:	1000                	addi	s0,sp,32
    8000291a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000291c:	eedff0ef          	jal	80002808 <argraw>
    80002920:	e088                	sd	a0,0(s1)
}
    80002922:	60e2                	ld	ra,24(sp)
    80002924:	6442                	ld	s0,16(sp)
    80002926:	64a2                	ld	s1,8(sp)
    80002928:	6105                	addi	sp,sp,32
    8000292a:	8082                	ret

000000008000292c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000292c:	1101                	addi	sp,sp,-32
    8000292e:	ec06                	sd	ra,24(sp)
    80002930:	e822                	sd	s0,16(sp)
    80002932:	e426                	sd	s1,8(sp)
    80002934:	e04a                	sd	s2,0(sp)
    80002936:	1000                	addi	s0,sp,32
    80002938:	892e                	mv	s2,a1
    8000293a:	84b2                	mv	s1,a2
  *ip = argraw(n);
    8000293c:	ecdff0ef          	jal	80002808 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002940:	8626                	mv	a2,s1
    80002942:	85ca                	mv	a1,s2
    80002944:	f6fff0ef          	jal	800028b2 <fetchstr>
}
    80002948:	60e2                	ld	ra,24(sp)
    8000294a:	6442                	ld	s0,16(sp)
    8000294c:	64a2                	ld	s1,8(sp)
    8000294e:	6902                	ld	s2,0(sp)
    80002950:	6105                	addi	sp,sp,32
    80002952:	8082                	ret

0000000080002954 <syscall>:
  // clang-format on
};

void
syscall(void)
{
    80002954:	1101                	addi	sp,sp,-32
    80002956:	ec06                	sd	ra,24(sp)
    80002958:	e822                	sd	s0,16(sp)
    8000295a:	e426                	sd	s1,8(sp)
    8000295c:	e04a                	sd	s2,0(sp)
    8000295e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002960:	84cff0ef          	jal	800019ac <myproc>
    80002964:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002966:	05853903          	ld	s2,88(a0)
    8000296a:	0a893783          	ld	a5,168(s2)
    8000296e:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002972:	37fd                	addiw	a5,a5,-1
    80002974:	4759                	li	a4,22
    80002976:	00f76f63          	bltu	a4,a5,80002994 <syscall+0x40>
    8000297a:	00369713          	slli	a4,a3,0x3
    8000297e:	00005797          	auipc	a5,0x5
    80002982:	e1278793          	addi	a5,a5,-494 # 80007790 <syscalls>
    80002986:	97ba                	add	a5,a5,a4
    80002988:	639c                	ld	a5,0(a5)
    8000298a:	c789                	beqz	a5,80002994 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000298c:	9782                	jalr	a5
    8000298e:	06a93823          	sd	a0,112(s2)
    80002992:	a829                	j	800029ac <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    80002994:	15848613          	addi	a2,s1,344
    80002998:	588c                	lw	a1,48(s1)
    8000299a:	00005517          	auipc	a0,0x5
    8000299e:	9f650513          	addi	a0,a0,-1546 # 80007390 <etext+0x390>
    800029a2:	b69fd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    800029a6:	6cbc                	ld	a5,88(s1)
    800029a8:	577d                	li	a4,-1
    800029aa:	fbb8                	sd	a4,112(a5)
  }
}
    800029ac:	60e2                	ld	ra,24(sp)
    800029ae:	6442                	ld	s0,16(sp)
    800029b0:	64a2                	ld	s1,8(sp)
    800029b2:	6902                	ld	s2,0(sp)
    800029b4:	6105                	addi	sp,sp,32
    800029b6:	8082                	ret

00000000800029b8 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    800029b8:	1101                	addi	sp,sp,-32
    800029ba:	ec06                	sd	ra,24(sp)
    800029bc:	e822                	sd	s0,16(sp)
    800029be:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800029c0:	fec40593          	addi	a1,s0,-20
    800029c4:	4501                	li	a0,0
    800029c6:	f2fff0ef          	jal	800028f4 <argint>
  kexit(n);
    800029ca:	fec42503          	lw	a0,-20(s0)
    800029ce:	f10ff0ef          	jal	800020de <kexit>
  return 0; // not reached
}
    800029d2:	4501                	li	a0,0
    800029d4:	60e2                	ld	ra,24(sp)
    800029d6:	6442                	ld	s0,16(sp)
    800029d8:	6105                	addi	sp,sp,32
    800029da:	8082                	ret

00000000800029dc <sys_getpid>:

uint64
sys_getpid(void)
{
    800029dc:	1141                	addi	sp,sp,-16
    800029de:	e406                	sd	ra,8(sp)
    800029e0:	e022                	sd	s0,0(sp)
    800029e2:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800029e4:	fc9fe0ef          	jal	800019ac <myproc>
}
    800029e8:	5908                	lw	a0,48(a0)
    800029ea:	60a2                	ld	ra,8(sp)
    800029ec:	6402                	ld	s0,0(sp)
    800029ee:	0141                	addi	sp,sp,16
    800029f0:	8082                	ret

00000000800029f2 <sys_fork>:

uint64
sys_fork(void)
{
    800029f2:	1141                	addi	sp,sp,-16
    800029f4:	e406                	sd	ra,8(sp)
    800029f6:	e022                	sd	s0,0(sp)
    800029f8:	0800                	addi	s0,sp,16
  return kfork();
    800029fa:	b12ff0ef          	jal	80001d0c <kfork>
}
    800029fe:	60a2                	ld	ra,8(sp)
    80002a00:	6402                	ld	s0,0(sp)
    80002a02:	0141                	addi	sp,sp,16
    80002a04:	8082                	ret

0000000080002a06 <sys_wait>:

uint64
sys_wait(void)
{
    80002a06:	1101                	addi	sp,sp,-32
    80002a08:	ec06                	sd	ra,24(sp)
    80002a0a:	e822                	sd	s0,16(sp)
    80002a0c:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002a0e:	fe840593          	addi	a1,s0,-24
    80002a12:	4501                	li	a0,0
    80002a14:	efdff0ef          	jal	80002910 <argaddr>
  return kwait(p);
    80002a18:	fe843503          	ld	a0,-24(s0)
    80002a1c:	823ff0ef          	jal	8000223e <kwait>
}
    80002a20:	60e2                	ld	ra,24(sp)
    80002a22:	6442                	ld	s0,16(sp)
    80002a24:	6105                	addi	sp,sp,32
    80002a26:	8082                	ret

0000000080002a28 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002a28:	7179                	addi	sp,sp,-48
    80002a2a:	f406                	sd	ra,40(sp)
    80002a2c:	f022                	sd	s0,32(sp)
    80002a2e:	ec26                	sd	s1,24(sp)
    80002a30:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002a32:	fd840593          	addi	a1,s0,-40
    80002a36:	4501                	li	a0,0
    80002a38:	ebdff0ef          	jal	800028f4 <argint>
  argint(1, &t);
    80002a3c:	fdc40593          	addi	a1,s0,-36
    80002a40:	4505                	li	a0,1
    80002a42:	eb3ff0ef          	jal	800028f4 <argint>
  addr = myproc()->sz;
    80002a46:	f67fe0ef          	jal	800019ac <myproc>
    80002a4a:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002a4c:	fdc42703          	lw	a4,-36(s0)
    80002a50:	4785                	li	a5,1
    80002a52:	02f70763          	beq	a4,a5,80002a80 <sys_sbrk+0x58>
    80002a56:	fd842783          	lw	a5,-40(s0)
    80002a5a:	0207c363          	bltz	a5,80002a80 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002a5e:	97a6                	add	a5,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    80002a60:	02000737          	lui	a4,0x2000
    80002a64:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002a66:	0736                	slli	a4,a4,0xd
    80002a68:	02f76a63          	bltu	a4,a5,80002a9c <sys_sbrk+0x74>
    80002a6c:	0297e863          	bltu	a5,s1,80002a9c <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002a70:	f3dfe0ef          	jal	800019ac <myproc>
    80002a74:	fd842703          	lw	a4,-40(s0)
    80002a78:	653c                	ld	a5,72(a0)
    80002a7a:	97ba                	add	a5,a5,a4
    80002a7c:	e53c                	sd	a5,72(a0)
    80002a7e:	a039                	j	80002a8c <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002a80:	fd842503          	lw	a0,-40(s0)
    80002a84:	a26ff0ef          	jal	80001caa <growproc>
    80002a88:	00054863          	bltz	a0,80002a98 <sys_sbrk+0x70>
  }
  return addr;
}
    80002a8c:	8526                	mv	a0,s1
    80002a8e:	70a2                	ld	ra,40(sp)
    80002a90:	7402                	ld	s0,32(sp)
    80002a92:	64e2                	ld	s1,24(sp)
    80002a94:	6145                	addi	sp,sp,48
    80002a96:	8082                	ret
      return -1;
    80002a98:	54fd                	li	s1,-1
    80002a9a:	bfcd                	j	80002a8c <sys_sbrk+0x64>
      return -1;
    80002a9c:	54fd                	li	s1,-1
    80002a9e:	b7fd                	j	80002a8c <sys_sbrk+0x64>

0000000080002aa0 <sys_pause>:

uint64
sys_pause(void)
{
    80002aa0:	7139                	addi	sp,sp,-64
    80002aa2:	fc06                	sd	ra,56(sp)
    80002aa4:	f822                	sd	s0,48(sp)
    80002aa6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002aa8:	fcc40593          	addi	a1,s0,-52
    80002aac:	4501                	li	a0,0
    80002aae:	e47ff0ef          	jal	800028f4 <argint>
  if (n < 0)
    80002ab2:	fcc42783          	lw	a5,-52(s0)
    80002ab6:	0807c063          	bltz	a5,80002b36 <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002aba:	00015517          	auipc	a0,0x15
    80002abe:	7ee50513          	addi	a0,a0,2030 # 800182a8 <tickslock>
    80002ac2:	966fe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002ac6:	fcc42783          	lw	a5,-52(s0)
    80002aca:	cbb9                	beqz	a5,80002b20 <sys_pause+0x80>
    80002acc:	f426                	sd	s1,40(sp)
    80002ace:	f04a                	sd	s2,32(sp)
    80002ad0:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002ad2:	00008997          	auipc	s3,0x8
    80002ad6:	8a69a983          	lw	s3,-1882(s3) # 8000a378 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002ada:	00008917          	auipc	s2,0x8
    80002ade:	89e90913          	addi	s2,s2,-1890 # 8000a378 <ticks>
    release(&tickslock);
    80002ae2:	00015497          	auipc	s1,0x15
    80002ae6:	7c648493          	addi	s1,s1,1990 # 800182a8 <tickslock>
    if (killed(myproc())) {
    80002aea:	ec3fe0ef          	jal	800019ac <myproc>
    80002aee:	f26ff0ef          	jal	80002214 <killed>
    80002af2:	e529                	bnez	a0,80002b3c <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002af4:	854a                	mv	a0,s2
    80002af6:	cc0ff0ef          	jal	80001fb6 <sleep_prepare>
    release(&tickslock);
    80002afa:	8526                	mv	a0,s1
    80002afc:	9b4fe0ef          	jal	80000cb0 <release>
    sleep();
    80002b00:	cf2ff0ef          	jal	80001ff2 <sleep>
    acquire(&tickslock);
    80002b04:	8526                	mv	a0,s1
    80002b06:	922fe0ef          	jal	80000c28 <acquire>
  while (ticks - ticks0 < n) {
    80002b0a:	00092783          	lw	a5,0(s2)
    80002b0e:	413787bb          	subw	a5,a5,s3
    80002b12:	fcc42703          	lw	a4,-52(s0)
    80002b16:	fce7eae3          	bltu	a5,a4,80002aea <sys_pause+0x4a>
    80002b1a:	74a2                	ld	s1,40(sp)
    80002b1c:	7902                	ld	s2,32(sp)
    80002b1e:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002b20:	00015517          	auipc	a0,0x15
    80002b24:	78850513          	addi	a0,a0,1928 # 800182a8 <tickslock>
    80002b28:	988fe0ef          	jal	80000cb0 <release>
  return 0;
    80002b2c:	4501                	li	a0,0
}
    80002b2e:	70e2                	ld	ra,56(sp)
    80002b30:	7442                	ld	s0,48(sp)
    80002b32:	6121                	addi	sp,sp,64
    80002b34:	8082                	ret
    n = 0;
    80002b36:	fc042623          	sw	zero,-52(s0)
    80002b3a:	b741                	j	80002aba <sys_pause+0x1a>
      release(&tickslock);
    80002b3c:	00015517          	auipc	a0,0x15
    80002b40:	76c50513          	addi	a0,a0,1900 # 800182a8 <tickslock>
    80002b44:	96cfe0ef          	jal	80000cb0 <release>
      return -1;
    80002b48:	557d                	li	a0,-1
    80002b4a:	74a2                	ld	s1,40(sp)
    80002b4c:	7902                	ld	s2,32(sp)
    80002b4e:	69e2                	ld	s3,24(sp)
    80002b50:	bff9                	j	80002b2e <sys_pause+0x8e>

0000000080002b52 <sys_kill>:

uint64
sys_kill(void)
{
    80002b52:	1101                	addi	sp,sp,-32
    80002b54:	ec06                	sd	ra,24(sp)
    80002b56:	e822                	sd	s0,16(sp)
    80002b58:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002b5a:	fec40593          	addi	a1,s0,-20
    80002b5e:	4501                	li	a0,0
    80002b60:	d95ff0ef          	jal	800028f4 <argint>
  return kkill(pid);
    80002b64:	fec42503          	lw	a0,-20(s0)
    80002b68:	e1cff0ef          	jal	80002184 <kkill>
}
    80002b6c:	60e2                	ld	ra,24(sp)
    80002b6e:	6442                	ld	s0,16(sp)
    80002b70:	6105                	addi	sp,sp,32
    80002b72:	8082                	ret

0000000080002b74 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002b74:	1101                	addi	sp,sp,-32
    80002b76:	ec06                	sd	ra,24(sp)
    80002b78:	e822                	sd	s0,16(sp)
    80002b7a:	e426                	sd	s1,8(sp)
    80002b7c:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002b7e:	00015517          	auipc	a0,0x15
    80002b82:	72a50513          	addi	a0,a0,1834 # 800182a8 <tickslock>
    80002b86:	8a2fe0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002b8a:	00007797          	auipc	a5,0x7
    80002b8e:	7ee7a783          	lw	a5,2030(a5) # 8000a378 <ticks>
    80002b92:	84be                	mv	s1,a5
  release(&tickslock);
    80002b94:	00015517          	auipc	a0,0x15
    80002b98:	71450513          	addi	a0,a0,1812 # 800182a8 <tickslock>
    80002b9c:	914fe0ef          	jal	80000cb0 <release>
  return xticks;
}
    80002ba0:	02049513          	slli	a0,s1,0x20
    80002ba4:	9101                	srli	a0,a0,0x20
    80002ba6:	60e2                	ld	ra,24(sp)
    80002ba8:	6442                	ld	s0,16(sp)
    80002baa:	64a2                	ld	s1,8(sp)
    80002bac:	6105                	addi	sp,sp,32
    80002bae:	8082                	ret

0000000080002bb0 <sys_vtop>:

uint64
sys_vtop(void)
{
    80002bb0:	1101                	addi	sp,sp,-32
    80002bb2:	ec06                	sd	ra,24(sp)
    80002bb4:	e822                	sd	s0,16(sp)
    80002bb6:	1000                	addi	s0,sp,32
  uint64 va;
  argaddr(0, &va);
    80002bb8:	fe840593          	addi	a1,s0,-24
    80002bbc:	4501                	li	a0,0
    80002bbe:	d53ff0ef          	jal	80002910 <argaddr>
  return vtop(va);
    80002bc2:	fe843503          	ld	a0,-24(s0)
    80002bc6:	c09fe0ef          	jal	800017ce <vtop>
}
    80002bca:	60e2                	ld	ra,24(sp)
    80002bcc:	6442                	ld	s0,16(sp)
    80002bce:	6105                	addi	sp,sp,32
    80002bd0:	8082                	ret

0000000080002bd2 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002bd2:	7179                	addi	sp,sp,-48
    80002bd4:	f406                	sd	ra,40(sp)
    80002bd6:	f022                	sd	s0,32(sp)
    80002bd8:	ec26                	sd	s1,24(sp)
    80002bda:	e84a                	sd	s2,16(sp)
    80002bdc:	e44e                	sd	s3,8(sp)
    80002bde:	e052                	sd	s4,0(sp)
    80002be0:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002be2:	00004597          	auipc	a1,0x4
    80002be6:	7ce58593          	addi	a1,a1,1998 # 800073b0 <etext+0x3b0>
    80002bea:	00015517          	auipc	a0,0x15
    80002bee:	6d650513          	addi	a0,a0,1750 # 800182c0 <bcache>
    80002bf2:	fb7fd0ef          	jal	80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002bf6:	0001d797          	auipc	a5,0x1d
    80002bfa:	6ca78793          	addi	a5,a5,1738 # 800202c0 <bcache+0x8000>
    80002bfe:	0001e717          	auipc	a4,0x1e
    80002c02:	92a70713          	addi	a4,a4,-1750 # 80020528 <bcache+0x8268>
    80002c06:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002c0a:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002c0e:	00015497          	auipc	s1,0x15
    80002c12:	6ca48493          	addi	s1,s1,1738 # 800182d8 <bcache+0x18>
    b->next = bcache.head.next;
    80002c16:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002c18:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002c1a:	00004a17          	auipc	s4,0x4
    80002c1e:	79ea0a13          	addi	s4,s4,1950 # 800073b8 <etext+0x3b8>
    b->next = bcache.head.next;
    80002c22:	2b893783          	ld	a5,696(s2)
    80002c26:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002c28:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002c2c:	85d2                	mv	a1,s4
    80002c2e:	01048513          	addi	a0,s1,16
    80002c32:	41c010ef          	jal	8000404e <initsleeplock>
    bcache.head.next->prev = b;
    80002c36:	2b893783          	ld	a5,696(s2)
    80002c3a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002c3c:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002c40:	45848493          	addi	s1,s1,1112
    80002c44:	fd349fe3          	bne	s1,s3,80002c22 <binit+0x50>
  }
}
    80002c48:	70a2                	ld	ra,40(sp)
    80002c4a:	7402                	ld	s0,32(sp)
    80002c4c:	64e2                	ld	s1,24(sp)
    80002c4e:	6942                	ld	s2,16(sp)
    80002c50:	69a2                	ld	s3,8(sp)
    80002c52:	6a02                	ld	s4,0(sp)
    80002c54:	6145                	addi	sp,sp,48
    80002c56:	8082                	ret

0000000080002c58 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002c58:	7179                	addi	sp,sp,-48
    80002c5a:	f406                	sd	ra,40(sp)
    80002c5c:	f022                	sd	s0,32(sp)
    80002c5e:	ec26                	sd	s1,24(sp)
    80002c60:	e84a                	sd	s2,16(sp)
    80002c62:	e44e                	sd	s3,8(sp)
    80002c64:	1800                	addi	s0,sp,48
    80002c66:	892a                	mv	s2,a0
    80002c68:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002c6a:	00015517          	auipc	a0,0x15
    80002c6e:	65650513          	addi	a0,a0,1622 # 800182c0 <bcache>
    80002c72:	fb7fd0ef          	jal	80000c28 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002c76:	0001e497          	auipc	s1,0x1e
    80002c7a:	9024b483          	ld	s1,-1790(s1) # 80020578 <bcache+0x82b8>
    80002c7e:	0001e797          	auipc	a5,0x1e
    80002c82:	8aa78793          	addi	a5,a5,-1878 # 80020528 <bcache+0x8268>
    80002c86:	02f48b63          	beq	s1,a5,80002cbc <bread+0x64>
    80002c8a:	873e                	mv	a4,a5
    80002c8c:	a021                	j	80002c94 <bread+0x3c>
    80002c8e:	68a4                	ld	s1,80(s1)
    80002c90:	02e48663          	beq	s1,a4,80002cbc <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002c94:	449c                	lw	a5,8(s1)
    80002c96:	ff279ce3          	bne	a5,s2,80002c8e <bread+0x36>
    80002c9a:	44dc                	lw	a5,12(s1)
    80002c9c:	ff3799e3          	bne	a5,s3,80002c8e <bread+0x36>
      b->refcnt++;
    80002ca0:	40bc                	lw	a5,64(s1)
    80002ca2:	2785                	addiw	a5,a5,1
    80002ca4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ca6:	00015517          	auipc	a0,0x15
    80002caa:	61a50513          	addi	a0,a0,1562 # 800182c0 <bcache>
    80002cae:	802fe0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002cb2:	01048513          	addi	a0,s1,16
    80002cb6:	3ce010ef          	jal	80004084 <acquiresleep>
      return b;
    80002cba:	a889                	j	80002d0c <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002cbc:	0001e497          	auipc	s1,0x1e
    80002cc0:	8b44b483          	ld	s1,-1868(s1) # 80020570 <bcache+0x82b0>
    80002cc4:	0001e797          	auipc	a5,0x1e
    80002cc8:	86478793          	addi	a5,a5,-1948 # 80020528 <bcache+0x8268>
    80002ccc:	00f48863          	beq	s1,a5,80002cdc <bread+0x84>
    80002cd0:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002cd2:	40bc                	lw	a5,64(s1)
    80002cd4:	cb91                	beqz	a5,80002ce8 <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002cd6:	64a4                	ld	s1,72(s1)
    80002cd8:	fee49de3          	bne	s1,a4,80002cd2 <bread+0x7a>
  panic("bget: no buffers");
    80002cdc:	00004517          	auipc	a0,0x4
    80002ce0:	6e450513          	addi	a0,a0,1764 # 800073c0 <etext+0x3c0>
    80002ce4:	b51fd0ef          	jal	80000834 <panic>
      b->dev = dev;
    80002ce8:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002cec:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002cf0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002cf4:	4785                	li	a5,1
    80002cf6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002cf8:	00015517          	auipc	a0,0x15
    80002cfc:	5c850513          	addi	a0,a0,1480 # 800182c0 <bcache>
    80002d00:	fb1fd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002d04:	01048513          	addi	a0,s1,16
    80002d08:	37c010ef          	jal	80004084 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002d0c:	409c                	lw	a5,0(s1)
    80002d0e:	cb89                	beqz	a5,80002d20 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002d10:	8526                	mv	a0,s1
    80002d12:	70a2                	ld	ra,40(sp)
    80002d14:	7402                	ld	s0,32(sp)
    80002d16:	64e2                	ld	s1,24(sp)
    80002d18:	6942                	ld	s2,16(sp)
    80002d1a:	69a2                	ld	s3,8(sp)
    80002d1c:	6145                	addi	sp,sp,48
    80002d1e:	8082                	ret
    virtio_disk_rw(b, 0);
    80002d20:	4581                	li	a1,0
    80002d22:	8526                	mv	a0,s1
    80002d24:	4c3020ef          	jal	800059e6 <virtio_disk_rw>
    b->valid = 1;
    80002d28:	4785                	li	a5,1
    80002d2a:	c09c                	sw	a5,0(s1)
  return b;
    80002d2c:	b7d5                	j	80002d10 <bread+0xb8>

0000000080002d2e <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002d2e:	1101                	addi	sp,sp,-32
    80002d30:	ec06                	sd	ra,24(sp)
    80002d32:	e822                	sd	s0,16(sp)
    80002d34:	e426                	sd	s1,8(sp)
    80002d36:	1000                	addi	s0,sp,32
    80002d38:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002d3a:	0541                	addi	a0,a0,16
    80002d3c:	3d4010ef          	jal	80004110 <holdingsleep>
    80002d40:	c911                	beqz	a0,80002d54 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002d42:	4585                	li	a1,1
    80002d44:	8526                	mv	a0,s1
    80002d46:	4a1020ef          	jal	800059e6 <virtio_disk_rw>
}
    80002d4a:	60e2                	ld	ra,24(sp)
    80002d4c:	6442                	ld	s0,16(sp)
    80002d4e:	64a2                	ld	s1,8(sp)
    80002d50:	6105                	addi	sp,sp,32
    80002d52:	8082                	ret
    panic("bwrite");
    80002d54:	00004517          	auipc	a0,0x4
    80002d58:	68450513          	addi	a0,a0,1668 # 800073d8 <etext+0x3d8>
    80002d5c:	ad9fd0ef          	jal	80000834 <panic>

0000000080002d60 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002d60:	1101                	addi	sp,sp,-32
    80002d62:	ec06                	sd	ra,24(sp)
    80002d64:	e822                	sd	s0,16(sp)
    80002d66:	e426                	sd	s1,8(sp)
    80002d68:	e04a                	sd	s2,0(sp)
    80002d6a:	1000                	addi	s0,sp,32
    80002d6c:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002d6e:	01050913          	addi	s2,a0,16
    80002d72:	854a                	mv	a0,s2
    80002d74:	39c010ef          	jal	80004110 <holdingsleep>
    80002d78:	c125                	beqz	a0,80002dd8 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002d7a:	854a                	mv	a0,s2
    80002d7c:	35c010ef          	jal	800040d8 <releasesleep>

  acquire(&bcache.lock);
    80002d80:	00015517          	auipc	a0,0x15
    80002d84:	54050513          	addi	a0,a0,1344 # 800182c0 <bcache>
    80002d88:	ea1fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002d8c:	40bc                	lw	a5,64(s1)
    80002d8e:	37fd                	addiw	a5,a5,-1
    80002d90:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002d92:	e79d                	bnez	a5,80002dc0 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002d94:	68b8                	ld	a4,80(s1)
    80002d96:	64bc                	ld	a5,72(s1)
    80002d98:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002d9a:	68b8                	ld	a4,80(s1)
    80002d9c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002d9e:	0001d797          	auipc	a5,0x1d
    80002da2:	52278793          	addi	a5,a5,1314 # 800202c0 <bcache+0x8000>
    80002da6:	2b87b703          	ld	a4,696(a5)
    80002daa:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002dac:	0001d717          	auipc	a4,0x1d
    80002db0:	77c70713          	addi	a4,a4,1916 # 80020528 <bcache+0x8268>
    80002db4:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002db6:	2b87b703          	ld	a4,696(a5)
    80002dba:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002dbc:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002dc0:	00015517          	auipc	a0,0x15
    80002dc4:	50050513          	addi	a0,a0,1280 # 800182c0 <bcache>
    80002dc8:	ee9fd0ef          	jal	80000cb0 <release>
}
    80002dcc:	60e2                	ld	ra,24(sp)
    80002dce:	6442                	ld	s0,16(sp)
    80002dd0:	64a2                	ld	s1,8(sp)
    80002dd2:	6902                	ld	s2,0(sp)
    80002dd4:	6105                	addi	sp,sp,32
    80002dd6:	8082                	ret
    panic("brelse");
    80002dd8:	00004517          	auipc	a0,0x4
    80002ddc:	60850513          	addi	a0,a0,1544 # 800073e0 <etext+0x3e0>
    80002de0:	a55fd0ef          	jal	80000834 <panic>

0000000080002de4 <bpin>:

void
bpin(struct buf *b)
{
    80002de4:	1101                	addi	sp,sp,-32
    80002de6:	ec06                	sd	ra,24(sp)
    80002de8:	e822                	sd	s0,16(sp)
    80002dea:	e426                	sd	s1,8(sp)
    80002dec:	1000                	addi	s0,sp,32
    80002dee:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002df0:	00015517          	auipc	a0,0x15
    80002df4:	4d050513          	addi	a0,a0,1232 # 800182c0 <bcache>
    80002df8:	e31fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002dfc:	40bc                	lw	a5,64(s1)
    80002dfe:	2785                	addiw	a5,a5,1
    80002e00:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e02:	00015517          	auipc	a0,0x15
    80002e06:	4be50513          	addi	a0,a0,1214 # 800182c0 <bcache>
    80002e0a:	ea7fd0ef          	jal	80000cb0 <release>
}
    80002e0e:	60e2                	ld	ra,24(sp)
    80002e10:	6442                	ld	s0,16(sp)
    80002e12:	64a2                	ld	s1,8(sp)
    80002e14:	6105                	addi	sp,sp,32
    80002e16:	8082                	ret

0000000080002e18 <bunpin>:

void
bunpin(struct buf *b)
{
    80002e18:	1101                	addi	sp,sp,-32
    80002e1a:	ec06                	sd	ra,24(sp)
    80002e1c:	e822                	sd	s0,16(sp)
    80002e1e:	e426                	sd	s1,8(sp)
    80002e20:	1000                	addi	s0,sp,32
    80002e22:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e24:	00015517          	auipc	a0,0x15
    80002e28:	49c50513          	addi	a0,a0,1180 # 800182c0 <bcache>
    80002e2c:	dfdfd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002e30:	40bc                	lw	a5,64(s1)
    80002e32:	37fd                	addiw	a5,a5,-1
    80002e34:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e36:	00015517          	auipc	a0,0x15
    80002e3a:	48a50513          	addi	a0,a0,1162 # 800182c0 <bcache>
    80002e3e:	e73fd0ef          	jal	80000cb0 <release>
}
    80002e42:	60e2                	ld	ra,24(sp)
    80002e44:	6442                	ld	s0,16(sp)
    80002e46:	64a2                	ld	s1,8(sp)
    80002e48:	6105                	addi	sp,sp,32
    80002e4a:	8082                	ret

0000000080002e4c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002e4c:	1101                	addi	sp,sp,-32
    80002e4e:	ec06                	sd	ra,24(sp)
    80002e50:	e822                	sd	s0,16(sp)
    80002e52:	e426                	sd	s1,8(sp)
    80002e54:	e04a                	sd	s2,0(sp)
    80002e56:	1000                	addi	s0,sp,32
    80002e58:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002e5a:	00d5d79b          	srliw	a5,a1,0xd
    80002e5e:	0001e597          	auipc	a1,0x1e
    80002e62:	b3e5a583          	lw	a1,-1218(a1) # 8002099c <sb+0x1c>
    80002e66:	9dbd                	addw	a1,a1,a5
    80002e68:	df1ff0ef          	jal	80002c58 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002e6c:	0074f713          	andi	a4,s1,7
    80002e70:	4785                	li	a5,1
    80002e72:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002e76:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80002e78:	90d9                	srli	s1,s1,0x36
    80002e7a:	00950733          	add	a4,a0,s1
    80002e7e:	05874703          	lbu	a4,88(a4)
    80002e82:	00e7f6b3          	and	a3,a5,a4
    80002e86:	c29d                	beqz	a3,80002eac <bfree+0x60>
    80002e88:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002e8a:	94aa                	add	s1,s1,a0
    80002e8c:	fff7c793          	not	a5,a5
    80002e90:	8f7d                	and	a4,a4,a5
    80002e92:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002e96:	080010ef          	jal	80003f16 <log_write>
  brelse(bp);
    80002e9a:	854a                	mv	a0,s2
    80002e9c:	ec5ff0ef          	jal	80002d60 <brelse>
}
    80002ea0:	60e2                	ld	ra,24(sp)
    80002ea2:	6442                	ld	s0,16(sp)
    80002ea4:	64a2                	ld	s1,8(sp)
    80002ea6:	6902                	ld	s2,0(sp)
    80002ea8:	6105                	addi	sp,sp,32
    80002eaa:	8082                	ret
    panic("freeing free block");
    80002eac:	00004517          	auipc	a0,0x4
    80002eb0:	53c50513          	addi	a0,a0,1340 # 800073e8 <etext+0x3e8>
    80002eb4:	981fd0ef          	jal	80000834 <panic>

0000000080002eb8 <balloc>:
{
    80002eb8:	715d                	addi	sp,sp,-80
    80002eba:	e486                	sd	ra,72(sp)
    80002ebc:	e0a2                	sd	s0,64(sp)
    80002ebe:	fc26                	sd	s1,56(sp)
    80002ec0:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80002ec2:	0001e797          	auipc	a5,0x1e
    80002ec6:	ac27a783          	lw	a5,-1342(a5) # 80020984 <sb+0x4>
    80002eca:	0e078263          	beqz	a5,80002fae <balloc+0xf6>
    80002ece:	f84a                	sd	s2,48(sp)
    80002ed0:	f44e                	sd	s3,40(sp)
    80002ed2:	f052                	sd	s4,32(sp)
    80002ed4:	ec56                	sd	s5,24(sp)
    80002ed6:	e85a                	sd	s6,16(sp)
    80002ed8:	e45e                	sd	s7,8(sp)
    80002eda:	e062                	sd	s8,0(sp)
    80002edc:	8baa                	mv	s7,a0
    80002ede:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002ee0:	0001eb17          	auipc	s6,0x1e
    80002ee4:	aa0b0b13          	addi	s6,s6,-1376 # 80020980 <sb>
      m = 1 << (bi % 8);
    80002ee8:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002eea:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80002eec:	6c09                	lui	s8,0x2
    80002eee:	a09d                	j	80002f54 <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80002ef0:	97ca                	add	a5,a5,s2
    80002ef2:	8e55                	or	a2,a2,a3
    80002ef4:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002ef8:	854a                	mv	a0,s2
    80002efa:	01c010ef          	jal	80003f16 <log_write>
        brelse(bp);
    80002efe:	854a                	mv	a0,s2
    80002f00:	e61ff0ef          	jal	80002d60 <brelse>
  bp = bread(dev, bno);
    80002f04:	85a6                	mv	a1,s1
    80002f06:	855e                	mv	a0,s7
    80002f08:	d51ff0ef          	jal	80002c58 <bread>
    80002f0c:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002f0e:	40000613          	li	a2,1024
    80002f12:	4581                	li	a1,0
    80002f14:	05850513          	addi	a0,a0,88
    80002f18:	dd1fd0ef          	jal	80000ce8 <memset>
  log_write(bp);
    80002f1c:	854a                	mv	a0,s2
    80002f1e:	7f9000ef          	jal	80003f16 <log_write>
  brelse(bp);
    80002f22:	854a                	mv	a0,s2
    80002f24:	e3dff0ef          	jal	80002d60 <brelse>
}
    80002f28:	7942                	ld	s2,48(sp)
    80002f2a:	79a2                	ld	s3,40(sp)
    80002f2c:	7a02                	ld	s4,32(sp)
    80002f2e:	6ae2                	ld	s5,24(sp)
    80002f30:	6b42                	ld	s6,16(sp)
    80002f32:	6ba2                	ld	s7,8(sp)
    80002f34:	6c02                	ld	s8,0(sp)
}
    80002f36:	8526                	mv	a0,s1
    80002f38:	60a6                	ld	ra,72(sp)
    80002f3a:	6406                	ld	s0,64(sp)
    80002f3c:	74e2                	ld	s1,56(sp)
    80002f3e:	6161                	addi	sp,sp,80
    80002f40:	8082                	ret
    brelse(bp);
    80002f42:	854a                	mv	a0,s2
    80002f44:	e1dff0ef          	jal	80002d60 <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80002f48:	015c0abb          	addw	s5,s8,s5
    80002f4c:	004b2783          	lw	a5,4(s6)
    80002f50:	04faf863          	bgeu	s5,a5,80002fa0 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80002f54:	40dad59b          	sraiw	a1,s5,0xd
    80002f58:	01cb2783          	lw	a5,28(s6)
    80002f5c:	9dbd                	addw	a1,a1,a5
    80002f5e:	855e                	mv	a0,s7
    80002f60:	cf9ff0ef          	jal	80002c58 <bread>
    80002f64:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002f66:	004b2503          	lw	a0,4(s6)
    80002f6a:	84d6                	mv	s1,s5
    80002f6c:	4701                	li	a4,0
    80002f6e:	fca4fae3          	bgeu	s1,a0,80002f42 <balloc+0x8a>
      m = 1 << (bi % 8);
    80002f72:	00777693          	andi	a3,a4,7
    80002f76:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80002f7a:	41f7579b          	sraiw	a5,a4,0x1f
    80002f7e:	01d7d79b          	srliw	a5,a5,0x1d
    80002f82:	9fb9                	addw	a5,a5,a4
    80002f84:	4037d79b          	sraiw	a5,a5,0x3
    80002f88:	00f90633          	add	a2,s2,a5
    80002f8c:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80002f90:	00c6f5b3          	and	a1,a3,a2
    80002f94:	ddb1                	beqz	a1,80002ef0 <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002f96:	2705                	addiw	a4,a4,1
    80002f98:	2485                	addiw	s1,s1,1
    80002f9a:	fd471ae3          	bne	a4,s4,80002f6e <balloc+0xb6>
    80002f9e:	b755                	j	80002f42 <balloc+0x8a>
    80002fa0:	7942                	ld	s2,48(sp)
    80002fa2:	79a2                	ld	s3,40(sp)
    80002fa4:	7a02                	ld	s4,32(sp)
    80002fa6:	6ae2                	ld	s5,24(sp)
    80002fa8:	6b42                	ld	s6,16(sp)
    80002faa:	6ba2                	ld	s7,8(sp)
    80002fac:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    80002fae:	00004517          	auipc	a0,0x4
    80002fb2:	45250513          	addi	a0,a0,1106 # 80007400 <etext+0x400>
    80002fb6:	d54fd0ef          	jal	8000050a <printk>
  return 0;
    80002fba:	4481                	li	s1,0
    80002fbc:	bfad                	j	80002f36 <balloc+0x7e>

0000000080002fbe <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002fbe:	7179                	addi	sp,sp,-48
    80002fc0:	f406                	sd	ra,40(sp)
    80002fc2:	f022                	sd	s0,32(sp)
    80002fc4:	ec26                	sd	s1,24(sp)
    80002fc6:	e84a                	sd	s2,16(sp)
    80002fc8:	e44e                	sd	s3,8(sp)
    80002fca:	1800                	addi	s0,sp,48
    80002fcc:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    80002fce:	47ad                	li	a5,11
    80002fd0:	02b7e363          	bltu	a5,a1,80002ff6 <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    80002fd4:	02059793          	slli	a5,a1,0x20
    80002fd8:	01e7d593          	srli	a1,a5,0x1e
    80002fdc:	00b509b3          	add	s3,a0,a1
    80002fe0:	0509a483          	lw	s1,80(s3)
    80002fe4:	e0b5                	bnez	s1,80003048 <bmap+0x8a>
      addr = balloc(ip->dev);
    80002fe6:	4108                	lw	a0,0(a0)
    80002fe8:	ed1ff0ef          	jal	80002eb8 <balloc>
    80002fec:	84aa                	mv	s1,a0
      if (addr == 0)
    80002fee:	cd29                	beqz	a0,80003048 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80002ff0:	04a9a823          	sw	a0,80(s3)
    80002ff4:	a891                	j	80003048 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002ff6:	ff45879b          	addiw	a5,a1,-12
    80002ffa:	873e                	mv	a4,a5
    80002ffc:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    80002ffe:	0ff00793          	li	a5,255
    80003002:	06e7e763          	bltu	a5,a4,80003070 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    80003006:	08052483          	lw	s1,128(a0)
    8000300a:	e891                	bnez	s1,8000301e <bmap+0x60>
      addr = balloc(ip->dev);
    8000300c:	4108                	lw	a0,0(a0)
    8000300e:	eabff0ef          	jal	80002eb8 <balloc>
    80003012:	84aa                	mv	s1,a0
      if (addr == 0)
    80003014:	c915                	beqz	a0,80003048 <bmap+0x8a>
    80003016:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003018:	08a92023          	sw	a0,128(s2)
    8000301c:	a011                	j	80003020 <bmap+0x62>
    8000301e:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003020:	85a6                	mv	a1,s1
    80003022:	00092503          	lw	a0,0(s2)
    80003026:	c33ff0ef          	jal	80002c58 <bread>
    8000302a:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    8000302c:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    80003030:	02099713          	slli	a4,s3,0x20
    80003034:	01e75593          	srli	a1,a4,0x1e
    80003038:	97ae                	add	a5,a5,a1
    8000303a:	89be                	mv	s3,a5
    8000303c:	4384                	lw	s1,0(a5)
    8000303e:	cc89                	beqz	s1,80003058 <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003040:	8552                	mv	a0,s4
    80003042:	d1fff0ef          	jal	80002d60 <brelse>
    return addr;
    80003046:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003048:	8526                	mv	a0,s1
    8000304a:	70a2                	ld	ra,40(sp)
    8000304c:	7402                	ld	s0,32(sp)
    8000304e:	64e2                	ld	s1,24(sp)
    80003050:	6942                	ld	s2,16(sp)
    80003052:	69a2                	ld	s3,8(sp)
    80003054:	6145                	addi	sp,sp,48
    80003056:	8082                	ret
      addr = balloc(ip->dev);
    80003058:	00092503          	lw	a0,0(s2)
    8000305c:	e5dff0ef          	jal	80002eb8 <balloc>
    80003060:	84aa                	mv	s1,a0
      if (addr) {
    80003062:	dd79                	beqz	a0,80003040 <bmap+0x82>
        a[bn] = addr;
    80003064:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80003068:	8552                	mv	a0,s4
    8000306a:	6ad000ef          	jal	80003f16 <log_write>
    8000306e:	bfc9                	j	80003040 <bmap+0x82>
    80003070:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003072:	00004517          	auipc	a0,0x4
    80003076:	3a650513          	addi	a0,a0,934 # 80007418 <etext+0x418>
    8000307a:	fbafd0ef          	jal	80000834 <panic>

000000008000307e <iget>:
{
    8000307e:	7179                	addi	sp,sp,-48
    80003080:	f406                	sd	ra,40(sp)
    80003082:	f022                	sd	s0,32(sp)
    80003084:	ec26                	sd	s1,24(sp)
    80003086:	e84a                	sd	s2,16(sp)
    80003088:	e44e                	sd	s3,8(sp)
    8000308a:	e052                	sd	s4,0(sp)
    8000308c:	1800                	addi	s0,sp,48
    8000308e:	892a                	mv	s2,a0
    80003090:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003092:	0001e517          	auipc	a0,0x1e
    80003096:	90e50513          	addi	a0,a0,-1778 # 800209a0 <itable>
    8000309a:	b8ffd0ef          	jal	80000c28 <acquire>
  empty = 0;
    8000309e:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    800030a0:	0001e497          	auipc	s1,0x1e
    800030a4:	91848493          	addi	s1,s1,-1768 # 800209b8 <itable+0x18>
    800030a8:	0001f697          	auipc	a3,0x1f
    800030ac:	3a068693          	addi	a3,a3,928 # 80022448 <log>
    800030b0:	a809                	j	800030c2 <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    800030b2:	e781                	bnez	a5,800030ba <iget+0x3c>
    800030b4:	00099363          	bnez	s3,800030ba <iget+0x3c>
      empty = ip;
    800030b8:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    800030ba:	08848493          	addi	s1,s1,136
    800030be:	02d48563          	beq	s1,a3,800030e8 <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    800030c2:	449c                	lw	a5,8(s1)
    800030c4:	fef057e3          	blez	a5,800030b2 <iget+0x34>
    800030c8:	4098                	lw	a4,0(s1)
    800030ca:	ff2718e3          	bne	a4,s2,800030ba <iget+0x3c>
    800030ce:	40d8                	lw	a4,4(s1)
    800030d0:	ff4715e3          	bne	a4,s4,800030ba <iget+0x3c>
      ip->ref++;
    800030d4:	2785                	addiw	a5,a5,1
    800030d6:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800030d8:	0001e517          	auipc	a0,0x1e
    800030dc:	8c850513          	addi	a0,a0,-1848 # 800209a0 <itable>
    800030e0:	bd1fd0ef          	jal	80000cb0 <release>
      return ip;
    800030e4:	89a6                	mv	s3,s1
    800030e6:	a015                	j	8000310a <iget+0x8c>
  if (empty == 0)
    800030e8:	02098a63          	beqz	s3,8000311c <iget+0x9e>
  ip->dev = dev;
    800030ec:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    800030f0:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    800030f4:	4785                	li	a5,1
    800030f6:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    800030fa:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    800030fe:	0001e517          	auipc	a0,0x1e
    80003102:	8a250513          	addi	a0,a0,-1886 # 800209a0 <itable>
    80003106:	babfd0ef          	jal	80000cb0 <release>
}
    8000310a:	854e                	mv	a0,s3
    8000310c:	70a2                	ld	ra,40(sp)
    8000310e:	7402                	ld	s0,32(sp)
    80003110:	64e2                	ld	s1,24(sp)
    80003112:	6942                	ld	s2,16(sp)
    80003114:	69a2                	ld	s3,8(sp)
    80003116:	6a02                	ld	s4,0(sp)
    80003118:	6145                	addi	sp,sp,48
    8000311a:	8082                	ret
    panic("iget: no inodes");
    8000311c:	00004517          	auipc	a0,0x4
    80003120:	31450513          	addi	a0,a0,788 # 80007430 <etext+0x430>
    80003124:	f10fd0ef          	jal	80000834 <panic>

0000000080003128 <iinit>:
{
    80003128:	7179                	addi	sp,sp,-48
    8000312a:	f406                	sd	ra,40(sp)
    8000312c:	f022                	sd	s0,32(sp)
    8000312e:	ec26                	sd	s1,24(sp)
    80003130:	e84a                	sd	s2,16(sp)
    80003132:	e44e                	sd	s3,8(sp)
    80003134:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003136:	00004597          	auipc	a1,0x4
    8000313a:	30a58593          	addi	a1,a1,778 # 80007440 <etext+0x440>
    8000313e:	0001e517          	auipc	a0,0x1e
    80003142:	86250513          	addi	a0,a0,-1950 # 800209a0 <itable>
    80003146:	a63fd0ef          	jal	80000ba8 <initlock>
  for (i = 0; i < NINODE; i++) {
    8000314a:	0001e497          	auipc	s1,0x1e
    8000314e:	87e48493          	addi	s1,s1,-1922 # 800209c8 <itable+0x28>
    80003152:	0001f997          	auipc	s3,0x1f
    80003156:	30698993          	addi	s3,s3,774 # 80022458 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000315a:	00004917          	auipc	s2,0x4
    8000315e:	2ee90913          	addi	s2,s2,750 # 80007448 <etext+0x448>
    80003162:	85ca                	mv	a1,s2
    80003164:	8526                	mv	a0,s1
    80003166:	6e9000ef          	jal	8000404e <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    8000316a:	08848493          	addi	s1,s1,136
    8000316e:	ff349ae3          	bne	s1,s3,80003162 <iinit+0x3a>
}
    80003172:	70a2                	ld	ra,40(sp)
    80003174:	7402                	ld	s0,32(sp)
    80003176:	64e2                	ld	s1,24(sp)
    80003178:	6942                	ld	s2,16(sp)
    8000317a:	69a2                	ld	s3,8(sp)
    8000317c:	6145                	addi	sp,sp,48
    8000317e:	8082                	ret

0000000080003180 <ialloc>:
{
    80003180:	7139                	addi	sp,sp,-64
    80003182:	fc06                	sd	ra,56(sp)
    80003184:	f822                	sd	s0,48(sp)
    80003186:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003188:	0001e717          	auipc	a4,0x1e
    8000318c:	80472703          	lw	a4,-2044(a4) # 8002098c <sb+0xc>
    80003190:	4785                	li	a5,1
    80003192:	06e7f063          	bgeu	a5,a4,800031f2 <ialloc+0x72>
    80003196:	f426                	sd	s1,40(sp)
    80003198:	f04a                	sd	s2,32(sp)
    8000319a:	ec4e                	sd	s3,24(sp)
    8000319c:	e852                	sd	s4,16(sp)
    8000319e:	e456                	sd	s5,8(sp)
    800031a0:	e05a                	sd	s6,0(sp)
    800031a2:	8aaa                	mv	s5,a0
    800031a4:	8b2e                	mv	s6,a1
    800031a6:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800031a8:	0001da17          	auipc	s4,0x1d
    800031ac:	7d8a0a13          	addi	s4,s4,2008 # 80020980 <sb>
    800031b0:	00495593          	srli	a1,s2,0x4
    800031b4:	018a2783          	lw	a5,24(s4)
    800031b8:	9dbd                	addw	a1,a1,a5
    800031ba:	8556                	mv	a0,s5
    800031bc:	a9dff0ef          	jal	80002c58 <bread>
    800031c0:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    800031c2:	05850993          	addi	s3,a0,88
    800031c6:	00f97793          	andi	a5,s2,15
    800031ca:	079a                	slli	a5,a5,0x6
    800031cc:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    800031ce:	00099783          	lh	a5,0(s3)
    800031d2:	cb9d                	beqz	a5,80003208 <ialloc+0x88>
    brelse(bp);
    800031d4:	b8dff0ef          	jal	80002d60 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    800031d8:	0905                	addi	s2,s2,1
    800031da:	00ca2703          	lw	a4,12(s4)
    800031de:	0009079b          	sext.w	a5,s2
    800031e2:	fce7e7e3          	bltu	a5,a4,800031b0 <ialloc+0x30>
    800031e6:	74a2                	ld	s1,40(sp)
    800031e8:	7902                	ld	s2,32(sp)
    800031ea:	69e2                	ld	s3,24(sp)
    800031ec:	6a42                	ld	s4,16(sp)
    800031ee:	6aa2                	ld	s5,8(sp)
    800031f0:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    800031f2:	00004517          	auipc	a0,0x4
    800031f6:	25e50513          	addi	a0,a0,606 # 80007450 <etext+0x450>
    800031fa:	b10fd0ef          	jal	8000050a <printk>
  return 0;
    800031fe:	4501                	li	a0,0
}
    80003200:	70e2                	ld	ra,56(sp)
    80003202:	7442                	ld	s0,48(sp)
    80003204:	6121                	addi	sp,sp,64
    80003206:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003208:	04000613          	li	a2,64
    8000320c:	4581                	li	a1,0
    8000320e:	854e                	mv	a0,s3
    80003210:	ad9fd0ef          	jal	80000ce8 <memset>
      dip->type = type;
    80003214:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    80003218:	8526                	mv	a0,s1
    8000321a:	4fd000ef          	jal	80003f16 <log_write>
      brelse(bp);
    8000321e:	8526                	mv	a0,s1
    80003220:	b41ff0ef          	jal	80002d60 <brelse>
      return iget(dev, inum);
    80003224:	0009059b          	sext.w	a1,s2
    80003228:	8556                	mv	a0,s5
    8000322a:	e55ff0ef          	jal	8000307e <iget>
    8000322e:	74a2                	ld	s1,40(sp)
    80003230:	7902                	ld	s2,32(sp)
    80003232:	69e2                	ld	s3,24(sp)
    80003234:	6a42                	ld	s4,16(sp)
    80003236:	6aa2                	ld	s5,8(sp)
    80003238:	6b02                	ld	s6,0(sp)
    8000323a:	b7d9                	j	80003200 <ialloc+0x80>

000000008000323c <iupdate>:
{
    8000323c:	1101                	addi	sp,sp,-32
    8000323e:	ec06                	sd	ra,24(sp)
    80003240:	e822                	sd	s0,16(sp)
    80003242:	e426                	sd	s1,8(sp)
    80003244:	e04a                	sd	s2,0(sp)
    80003246:	1000                	addi	s0,sp,32
    80003248:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000324a:	415c                	lw	a5,4(a0)
    8000324c:	0047d79b          	srliw	a5,a5,0x4
    80003250:	0001d597          	auipc	a1,0x1d
    80003254:	7485a583          	lw	a1,1864(a1) # 80020998 <sb+0x18>
    80003258:	9dbd                	addw	a1,a1,a5
    8000325a:	4108                	lw	a0,0(a0)
    8000325c:	9fdff0ef          	jal	80002c58 <bread>
    80003260:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003262:	05850793          	addi	a5,a0,88
    80003266:	40d8                	lw	a4,4(s1)
    80003268:	8b3d                	andi	a4,a4,15
    8000326a:	071a                	slli	a4,a4,0x6
    8000326c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000326e:	04449703          	lh	a4,68(s1)
    80003272:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003276:	04649703          	lh	a4,70(s1)
    8000327a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000327e:	04849703          	lh	a4,72(s1)
    80003282:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003286:	04a49703          	lh	a4,74(s1)
    8000328a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000328e:	44f8                	lw	a4,76(s1)
    80003290:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003292:	03400613          	li	a2,52
    80003296:	05048593          	addi	a1,s1,80
    8000329a:	00c78513          	addi	a0,a5,12
    8000329e:	aabfd0ef          	jal	80000d48 <memmove>
  log_write(bp);
    800032a2:	854a                	mv	a0,s2
    800032a4:	473000ef          	jal	80003f16 <log_write>
  brelse(bp);
    800032a8:	854a                	mv	a0,s2
    800032aa:	ab7ff0ef          	jal	80002d60 <brelse>
}
    800032ae:	60e2                	ld	ra,24(sp)
    800032b0:	6442                	ld	s0,16(sp)
    800032b2:	64a2                	ld	s1,8(sp)
    800032b4:	6902                	ld	s2,0(sp)
    800032b6:	6105                	addi	sp,sp,32
    800032b8:	8082                	ret

00000000800032ba <idup>:
{
    800032ba:	1101                	addi	sp,sp,-32
    800032bc:	ec06                	sd	ra,24(sp)
    800032be:	e822                	sd	s0,16(sp)
    800032c0:	e426                	sd	s1,8(sp)
    800032c2:	1000                	addi	s0,sp,32
    800032c4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800032c6:	0001d517          	auipc	a0,0x1d
    800032ca:	6da50513          	addi	a0,a0,1754 # 800209a0 <itable>
    800032ce:	95bfd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    800032d2:	449c                	lw	a5,8(s1)
    800032d4:	2785                	addiw	a5,a5,1
    800032d6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800032d8:	0001d517          	auipc	a0,0x1d
    800032dc:	6c850513          	addi	a0,a0,1736 # 800209a0 <itable>
    800032e0:	9d1fd0ef          	jal	80000cb0 <release>
}
    800032e4:	8526                	mv	a0,s1
    800032e6:	60e2                	ld	ra,24(sp)
    800032e8:	6442                	ld	s0,16(sp)
    800032ea:	64a2                	ld	s1,8(sp)
    800032ec:	6105                	addi	sp,sp,32
    800032ee:	8082                	ret

00000000800032f0 <ilock>:
{
    800032f0:	1101                	addi	sp,sp,-32
    800032f2:	ec06                	sd	ra,24(sp)
    800032f4:	e822                	sd	s0,16(sp)
    800032f6:	e426                	sd	s1,8(sp)
    800032f8:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    800032fa:	cd19                	beqz	a0,80003318 <ilock+0x28>
    800032fc:	84aa                	mv	s1,a0
    800032fe:	451c                	lw	a5,8(a0)
    80003300:	00f05c63          	blez	a5,80003318 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003304:	0541                	addi	a0,a0,16
    80003306:	57f000ef          	jal	80004084 <acquiresleep>
  if (ip->valid == 0) {
    8000330a:	40bc                	lw	a5,64(s1)
    8000330c:	cf89                	beqz	a5,80003326 <ilock+0x36>
}
    8000330e:	60e2                	ld	ra,24(sp)
    80003310:	6442                	ld	s0,16(sp)
    80003312:	64a2                	ld	s1,8(sp)
    80003314:	6105                	addi	sp,sp,32
    80003316:	8082                	ret
    80003318:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000331a:	00004517          	auipc	a0,0x4
    8000331e:	14e50513          	addi	a0,a0,334 # 80007468 <etext+0x468>
    80003322:	d12fd0ef          	jal	80000834 <panic>
    80003326:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003328:	40dc                	lw	a5,4(s1)
    8000332a:	0047d79b          	srliw	a5,a5,0x4
    8000332e:	0001d597          	auipc	a1,0x1d
    80003332:	66a5a583          	lw	a1,1642(a1) # 80020998 <sb+0x18>
    80003336:	9dbd                	addw	a1,a1,a5
    80003338:	4088                	lw	a0,0(s1)
    8000333a:	91fff0ef          	jal	80002c58 <bread>
    8000333e:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003340:	05850593          	addi	a1,a0,88
    80003344:	40dc                	lw	a5,4(s1)
    80003346:	8bbd                	andi	a5,a5,15
    80003348:	079a                	slli	a5,a5,0x6
    8000334a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000334c:	00059783          	lh	a5,0(a1)
    80003350:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003354:	00259783          	lh	a5,2(a1)
    80003358:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000335c:	00459783          	lh	a5,4(a1)
    80003360:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003364:	00659783          	lh	a5,6(a1)
    80003368:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000336c:	459c                	lw	a5,8(a1)
    8000336e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003370:	03400613          	li	a2,52
    80003374:	05b1                	addi	a1,a1,12
    80003376:	05048513          	addi	a0,s1,80
    8000337a:	9cffd0ef          	jal	80000d48 <memmove>
    brelse(bp);
    8000337e:	854a                	mv	a0,s2
    80003380:	9e1ff0ef          	jal	80002d60 <brelse>
    ip->valid = 1;
    80003384:	4785                	li	a5,1
    80003386:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003388:	04449783          	lh	a5,68(s1)
    8000338c:	c399                	beqz	a5,80003392 <ilock+0xa2>
    8000338e:	6902                	ld	s2,0(sp)
    80003390:	bfbd                	j	8000330e <ilock+0x1e>
      panic("ilock: no type");
    80003392:	00004517          	auipc	a0,0x4
    80003396:	0de50513          	addi	a0,a0,222 # 80007470 <etext+0x470>
    8000339a:	c9afd0ef          	jal	80000834 <panic>

000000008000339e <iunlock>:
{
    8000339e:	1101                	addi	sp,sp,-32
    800033a0:	ec06                	sd	ra,24(sp)
    800033a2:	e822                	sd	s0,16(sp)
    800033a4:	e426                	sd	s1,8(sp)
    800033a6:	e04a                	sd	s2,0(sp)
    800033a8:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800033aa:	c505                	beqz	a0,800033d2 <iunlock+0x34>
    800033ac:	84aa                	mv	s1,a0
    800033ae:	01050913          	addi	s2,a0,16
    800033b2:	854a                	mv	a0,s2
    800033b4:	55d000ef          	jal	80004110 <holdingsleep>
    800033b8:	cd09                	beqz	a0,800033d2 <iunlock+0x34>
    800033ba:	449c                	lw	a5,8(s1)
    800033bc:	00f05b63          	blez	a5,800033d2 <iunlock+0x34>
  releasesleep(&ip->lock);
    800033c0:	854a                	mv	a0,s2
    800033c2:	517000ef          	jal	800040d8 <releasesleep>
}
    800033c6:	60e2                	ld	ra,24(sp)
    800033c8:	6442                	ld	s0,16(sp)
    800033ca:	64a2                	ld	s1,8(sp)
    800033cc:	6902                	ld	s2,0(sp)
    800033ce:	6105                	addi	sp,sp,32
    800033d0:	8082                	ret
    panic("iunlock");
    800033d2:	00004517          	auipc	a0,0x4
    800033d6:	0ae50513          	addi	a0,a0,174 # 80007480 <etext+0x480>
    800033da:	c5afd0ef          	jal	80000834 <panic>

00000000800033de <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800033de:	7179                	addi	sp,sp,-48
    800033e0:	f406                	sd	ra,40(sp)
    800033e2:	f022                	sd	s0,32(sp)
    800033e4:	ec26                	sd	s1,24(sp)
    800033e6:	e84a                	sd	s2,16(sp)
    800033e8:	e44e                	sd	s3,8(sp)
    800033ea:	1800                	addi	s0,sp,48
    800033ec:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    800033ee:	05050493          	addi	s1,a0,80
    800033f2:	08050913          	addi	s2,a0,128
    800033f6:	a021                	j	800033fe <itrunc+0x20>
    800033f8:	0491                	addi	s1,s1,4
    800033fa:	01248b63          	beq	s1,s2,80003410 <itrunc+0x32>
    if (ip->addrs[i]) {
    800033fe:	408c                	lw	a1,0(s1)
    80003400:	dde5                	beqz	a1,800033f8 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003402:	0009a503          	lw	a0,0(s3)
    80003406:	a47ff0ef          	jal	80002e4c <bfree>
      ip->addrs[i] = 0;
    8000340a:	0004a023          	sw	zero,0(s1)
    8000340e:	b7ed                	j	800033f8 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    80003410:	0809a583          	lw	a1,128(s3)
    80003414:	ed89                	bnez	a1,8000342e <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003416:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000341a:	854e                	mv	a0,s3
    8000341c:	e21ff0ef          	jal	8000323c <iupdate>
}
    80003420:	70a2                	ld	ra,40(sp)
    80003422:	7402                	ld	s0,32(sp)
    80003424:	64e2                	ld	s1,24(sp)
    80003426:	6942                	ld	s2,16(sp)
    80003428:	69a2                	ld	s3,8(sp)
    8000342a:	6145                	addi	sp,sp,48
    8000342c:	8082                	ret
    8000342e:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003430:	0009a503          	lw	a0,0(s3)
    80003434:	825ff0ef          	jal	80002c58 <bread>
    80003438:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    8000343a:	05850493          	addi	s1,a0,88
    8000343e:	45850913          	addi	s2,a0,1112
    80003442:	a021                	j	8000344a <itrunc+0x6c>
    80003444:	0491                	addi	s1,s1,4
    80003446:	01248963          	beq	s1,s2,80003458 <itrunc+0x7a>
      if (a[j])
    8000344a:	408c                	lw	a1,0(s1)
    8000344c:	dde5                	beqz	a1,80003444 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000344e:	0009a503          	lw	a0,0(s3)
    80003452:	9fbff0ef          	jal	80002e4c <bfree>
    80003456:	b7fd                	j	80003444 <itrunc+0x66>
    brelse(bp);
    80003458:	8552                	mv	a0,s4
    8000345a:	907ff0ef          	jal	80002d60 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000345e:	0809a583          	lw	a1,128(s3)
    80003462:	0009a503          	lw	a0,0(s3)
    80003466:	9e7ff0ef          	jal	80002e4c <bfree>
    ip->addrs[NDIRECT] = 0;
    8000346a:	0809a023          	sw	zero,128(s3)
    8000346e:	6a02                	ld	s4,0(sp)
    80003470:	b75d                	j	80003416 <itrunc+0x38>

0000000080003472 <iput>:
{
    80003472:	7179                	addi	sp,sp,-48
    80003474:	f406                	sd	ra,40(sp)
    80003476:	f022                	sd	s0,32(sp)
    80003478:	ec26                	sd	s1,24(sp)
    8000347a:	1800                	addi	s0,sp,48
    8000347c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000347e:	0001d517          	auipc	a0,0x1d
    80003482:	52250513          	addi	a0,a0,1314 # 800209a0 <itable>
    80003486:	fa2fd0ef          	jal	80000c28 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    8000348a:	449c                	lw	a5,8(s1)
    8000348c:	4705                	li	a4,1
    8000348e:	00e78f63          	beq	a5,a4,800034ac <iput+0x3a>
  ip->ref--;
    80003492:	37fd                	addiw	a5,a5,-1
    80003494:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003496:	0001d517          	auipc	a0,0x1d
    8000349a:	50a50513          	addi	a0,a0,1290 # 800209a0 <itable>
    8000349e:	813fd0ef          	jal	80000cb0 <release>
}
    800034a2:	70a2                	ld	ra,40(sp)
    800034a4:	7402                	ld	s0,32(sp)
    800034a6:	64e2                	ld	s1,24(sp)
    800034a8:	6145                	addi	sp,sp,48
    800034aa:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    800034ac:	40b8                	lw	a4,64(s1)
    800034ae:	d375                	beqz	a4,80003492 <iput+0x20>
    800034b0:	e84a                	sd	s2,16(sp)
    800034b2:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    800034b4:	0004aa03          	lw	s4,0(s1)
    800034b8:	0044a903          	lw	s2,4(s1)
  if (last) {
    800034bc:	04a49703          	lh	a4,74(s1)
    800034c0:	ef3d                	bnez	a4,8000353e <iput+0xcc>
    800034c2:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    800034c4:	01048793          	addi	a5,s1,16
    800034c8:	89be                	mv	s3,a5
    800034ca:	853e                	mv	a0,a5
    800034cc:	3b9000ef          	jal	80004084 <acquiresleep>
    release(&itable.lock);
    800034d0:	0001d517          	auipc	a0,0x1d
    800034d4:	4d050513          	addi	a0,a0,1232 # 800209a0 <itable>
    800034d8:	fd8fd0ef          	jal	80000cb0 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    800034dc:	8526                	mv	a0,s1
    800034de:	f01ff0ef          	jal	800033de <itrunc>
    ip->valid = 0;
    800034e2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800034e6:	854e                	mv	a0,s3
    800034e8:	3f1000ef          	jal	800040d8 <releasesleep>
    acquire(&itable.lock);
    800034ec:	0001d517          	auipc	a0,0x1d
    800034f0:	4b450513          	addi	a0,a0,1204 # 800209a0 <itable>
    800034f4:	f34fd0ef          	jal	80000c28 <acquire>
  ip->ref--;
    800034f8:	449c                	lw	a5,8(s1)
    800034fa:	37fd                	addiw	a5,a5,-1
    800034fc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800034fe:	0001d517          	auipc	a0,0x1d
    80003502:	4a250513          	addi	a0,a0,1186 # 800209a0 <itable>
    80003506:	faafd0ef          	jal	80000cb0 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000350a:	0049579b          	srliw	a5,s2,0x4
    8000350e:	0001d597          	auipc	a1,0x1d
    80003512:	48a5a583          	lw	a1,1162(a1) # 80020998 <sb+0x18>
    80003516:	9dbd                	addw	a1,a1,a5
    80003518:	8552                	mv	a0,s4
    8000351a:	f3eff0ef          	jal	80002c58 <bread>
    8000351e:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003520:	00f97793          	andi	a5,s2,15
  dip->type = 0;
    80003524:	079a                	slli	a5,a5,0x6
    80003526:	97aa                	add	a5,a5,a0
    80003528:	04079c23          	sh	zero,88(a5)
  log_write(bp);
    8000352c:	1eb000ef          	jal	80003f16 <log_write>
  brelse(bp);
    80003530:	8526                	mv	a0,s1
    80003532:	82fff0ef          	jal	80002d60 <brelse>
}
    80003536:	6942                	ld	s2,16(sp)
    80003538:	69a2                	ld	s3,8(sp)
    8000353a:	6a02                	ld	s4,0(sp)
    8000353c:	b79d                	j	800034a2 <iput+0x30>
    8000353e:	6942                	ld	s2,16(sp)
    80003540:	6a02                	ld	s4,0(sp)
    80003542:	bf81                	j	80003492 <iput+0x20>

0000000080003544 <iunlockput>:
{
    80003544:	1101                	addi	sp,sp,-32
    80003546:	ec06                	sd	ra,24(sp)
    80003548:	e822                	sd	s0,16(sp)
    8000354a:	e426                	sd	s1,8(sp)
    8000354c:	1000                	addi	s0,sp,32
    8000354e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003550:	e4fff0ef          	jal	8000339e <iunlock>
  iput(ip);
    80003554:	8526                	mv	a0,s1
    80003556:	f1dff0ef          	jal	80003472 <iput>
}
    8000355a:	60e2                	ld	ra,24(sp)
    8000355c:	6442                	ld	s0,16(sp)
    8000355e:	64a2                	ld	s1,8(sp)
    80003560:	6105                	addi	sp,sp,32
    80003562:	8082                	ret

0000000080003564 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003564:	0001d717          	auipc	a4,0x1d
    80003568:	42872703          	lw	a4,1064(a4) # 8002098c <sb+0xc>
    8000356c:	4785                	li	a5,1
    8000356e:	0ae7fe63          	bgeu	a5,a4,8000362a <ireclaim+0xc6>
{
    80003572:	7139                	addi	sp,sp,-64
    80003574:	fc06                	sd	ra,56(sp)
    80003576:	f822                	sd	s0,48(sp)
    80003578:	f426                	sd	s1,40(sp)
    8000357a:	f04a                	sd	s2,32(sp)
    8000357c:	ec4e                	sd	s3,24(sp)
    8000357e:	e852                	sd	s4,16(sp)
    80003580:	e456                	sd	s5,8(sp)
    80003582:	e05a                	sd	s6,0(sp)
    80003584:	0080                	addi	s0,sp,64
    80003586:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003588:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000358a:	0001da17          	auipc	s4,0x1d
    8000358e:	3f6a0a13          	addi	s4,s4,1014 # 80020980 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    80003592:	00004b17          	auipc	s6,0x4
    80003596:	ef6b0b13          	addi	s6,s6,-266 # 80007488 <etext+0x488>
    8000359a:	a099                	j	800035e0 <ireclaim+0x7c>
    8000359c:	85ce                	mv	a1,s3
    8000359e:	855a                	mv	a0,s6
    800035a0:	f6bfc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    800035a4:	85ce                	mv	a1,s3
    800035a6:	8556                	mv	a0,s5
    800035a8:	ad7ff0ef          	jal	8000307e <iget>
    800035ac:	89aa                	mv	s3,a0
    brelse(bp);
    800035ae:	854a                	mv	a0,s2
    800035b0:	fb0ff0ef          	jal	80002d60 <brelse>
    if (ip) {
    800035b4:	00098f63          	beqz	s3,800035d2 <ireclaim+0x6e>
      begin_op();
    800035b8:	7b0000ef          	jal	80003d68 <begin_op>
      ilock(ip);
    800035bc:	854e                	mv	a0,s3
    800035be:	d33ff0ef          	jal	800032f0 <ilock>
      iunlock(ip);
    800035c2:	854e                	mv	a0,s3
    800035c4:	ddbff0ef          	jal	8000339e <iunlock>
      iput(ip);
    800035c8:	854e                	mv	a0,s3
    800035ca:	ea9ff0ef          	jal	80003472 <iput>
      end_op();
    800035ce:	027000ef          	jal	80003df4 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800035d2:	0485                	addi	s1,s1,1
    800035d4:	00ca2703          	lw	a4,12(s4)
    800035d8:	0004879b          	sext.w	a5,s1
    800035dc:	02e7fd63          	bgeu	a5,a4,80003616 <ireclaim+0xb2>
    800035e0:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800035e4:	0044d593          	srli	a1,s1,0x4
    800035e8:	018a2783          	lw	a5,24(s4)
    800035ec:	9dbd                	addw	a1,a1,a5
    800035ee:	8556                	mv	a0,s5
    800035f0:	e68ff0ef          	jal	80002c58 <bread>
    800035f4:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800035f6:	05850793          	addi	a5,a0,88
    800035fa:	00f9f713          	andi	a4,s3,15
    800035fe:	071a                	slli	a4,a4,0x6
    80003600:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    80003602:	00079703          	lh	a4,0(a5)
    80003606:	c701                	beqz	a4,8000360e <ireclaim+0xaa>
    80003608:	00679783          	lh	a5,6(a5)
    8000360c:	dbc1                	beqz	a5,8000359c <ireclaim+0x38>
    brelse(bp);
    8000360e:	854a                	mv	a0,s2
    80003610:	f50ff0ef          	jal	80002d60 <brelse>
    if (ip) {
    80003614:	bf7d                	j	800035d2 <ireclaim+0x6e>
}
    80003616:	70e2                	ld	ra,56(sp)
    80003618:	7442                	ld	s0,48(sp)
    8000361a:	74a2                	ld	s1,40(sp)
    8000361c:	7902                	ld	s2,32(sp)
    8000361e:	69e2                	ld	s3,24(sp)
    80003620:	6a42                	ld	s4,16(sp)
    80003622:	6aa2                	ld	s5,8(sp)
    80003624:	6b02                	ld	s6,0(sp)
    80003626:	6121                	addi	sp,sp,64
    80003628:	8082                	ret
    8000362a:	8082                	ret

000000008000362c <fsinit>:
{
    8000362c:	1101                	addi	sp,sp,-32
    8000362e:	ec06                	sd	ra,24(sp)
    80003630:	e822                	sd	s0,16(sp)
    80003632:	e426                	sd	s1,8(sp)
    80003634:	e04a                	sd	s2,0(sp)
    80003636:	1000                	addi	s0,sp,32
    80003638:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000363a:	4585                	li	a1,1
    8000363c:	e1cff0ef          	jal	80002c58 <bread>
    80003640:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003642:	02000613          	li	a2,32
    80003646:	05850593          	addi	a1,a0,88
    8000364a:	0001d517          	auipc	a0,0x1d
    8000364e:	33650513          	addi	a0,a0,822 # 80020980 <sb>
    80003652:	ef6fd0ef          	jal	80000d48 <memmove>
  brelse(bp);
    80003656:	8526                	mv	a0,s1
    80003658:	f08ff0ef          	jal	80002d60 <brelse>
  if (sb.magic != FSMAGIC)
    8000365c:	0001d717          	auipc	a4,0x1d
    80003660:	32472703          	lw	a4,804(a4) # 80020980 <sb>
    80003664:	102037b7          	lui	a5,0x10203
    80003668:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000366c:	02f71263          	bne	a4,a5,80003690 <fsinit+0x64>
  initlog(dev, &sb);
    80003670:	0001d597          	auipc	a1,0x1d
    80003674:	31058593          	addi	a1,a1,784 # 80020980 <sb>
    80003678:	854a                	mv	a0,s2
    8000367a:	66c000ef          	jal	80003ce6 <initlog>
  ireclaim(dev);
    8000367e:	854a                	mv	a0,s2
    80003680:	ee5ff0ef          	jal	80003564 <ireclaim>
}
    80003684:	60e2                	ld	ra,24(sp)
    80003686:	6442                	ld	s0,16(sp)
    80003688:	64a2                	ld	s1,8(sp)
    8000368a:	6902                	ld	s2,0(sp)
    8000368c:	6105                	addi	sp,sp,32
    8000368e:	8082                	ret
    panic("invalid file system");
    80003690:	00004517          	auipc	a0,0x4
    80003694:	e1850513          	addi	a0,a0,-488 # 800074a8 <etext+0x4a8>
    80003698:	99cfd0ef          	jal	80000834 <panic>

000000008000369c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000369c:	1141                	addi	sp,sp,-16
    8000369e:	e406                	sd	ra,8(sp)
    800036a0:	e022                	sd	s0,0(sp)
    800036a2:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800036a4:	411c                	lw	a5,0(a0)
    800036a6:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800036a8:	415c                	lw	a5,4(a0)
    800036aa:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800036ac:	04451783          	lh	a5,68(a0)
    800036b0:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800036b4:	04a51783          	lh	a5,74(a0)
    800036b8:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800036bc:	04c56783          	lwu	a5,76(a0)
    800036c0:	e99c                	sd	a5,16(a1)
}
    800036c2:	60a2                	ld	ra,8(sp)
    800036c4:	6402                	ld	s0,0(sp)
    800036c6:	0141                	addi	sp,sp,16
    800036c8:	8082                	ret

00000000800036ca <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    800036ca:	457c                	lw	a5,76(a0)
    800036cc:	0ed7e663          	bltu	a5,a3,800037b8 <readi+0xee>
{
    800036d0:	7159                	addi	sp,sp,-112
    800036d2:	f486                	sd	ra,104(sp)
    800036d4:	f0a2                	sd	s0,96(sp)
    800036d6:	eca6                	sd	s1,88(sp)
    800036d8:	e0d2                	sd	s4,64(sp)
    800036da:	fc56                	sd	s5,56(sp)
    800036dc:	f85a                	sd	s6,48(sp)
    800036de:	f45e                	sd	s7,40(sp)
    800036e0:	1880                	addi	s0,sp,112
    800036e2:	8b2a                	mv	s6,a0
    800036e4:	8bae                	mv	s7,a1
    800036e6:	8a32                	mv	s4,a2
    800036e8:	84b6                	mv	s1,a3
    800036ea:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    800036ec:	9f35                	addw	a4,a4,a3
    return 0;
    800036ee:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    800036f0:	0ad76b63          	bltu	a4,a3,800037a6 <readi+0xdc>
    800036f4:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    800036f6:	00e7f463          	bgeu	a5,a4,800036fe <readi+0x34>
    n = ip->size - off;
    800036fa:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800036fe:	080a8b63          	beqz	s5,80003794 <readi+0xca>
    80003702:	e8ca                	sd	s2,80(sp)
    80003704:	f062                	sd	s8,32(sp)
    80003706:	ec66                	sd	s9,24(sp)
    80003708:	e86a                	sd	s10,16(sp)
    8000370a:	e46e                	sd	s11,8(sp)
    8000370c:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    8000370e:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003712:	5c7d                	li	s8,-1
    80003714:	a80d                	j	80003746 <readi+0x7c>
    80003716:	020d1d93          	slli	s11,s10,0x20
    8000371a:	020ddd93          	srli	s11,s11,0x20
    8000371e:	05890613          	addi	a2,s2,88
    80003722:	86ee                	mv	a3,s11
    80003724:	963e                	add	a2,a2,a5
    80003726:	85d2                	mv	a1,s4
    80003728:	855e                	mv	a0,s7
    8000372a:	c1ffe0ef          	jal	80002348 <either_copyout>
    8000372e:	05850363          	beq	a0,s8,80003774 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003732:	854a                	mv	a0,s2
    80003734:	e2cff0ef          	jal	80002d60 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003738:	013d09bb          	addw	s3,s10,s3
    8000373c:	009d04bb          	addw	s1,s10,s1
    80003740:	9a6e                	add	s4,s4,s11
    80003742:	0559f363          	bgeu	s3,s5,80003788 <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    80003746:	00a4d59b          	srliw	a1,s1,0xa
    8000374a:	855a                	mv	a0,s6
    8000374c:	873ff0ef          	jal	80002fbe <bmap>
    80003750:	85aa                	mv	a1,a0
    if (addr == 0)
    80003752:	c139                	beqz	a0,80003798 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003754:	000b2503          	lw	a0,0(s6)
    80003758:	d00ff0ef          	jal	80002c58 <bread>
    8000375c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    8000375e:	3ff4f793          	andi	a5,s1,1023
    80003762:	40fc873b          	subw	a4,s9,a5
    80003766:	413a86bb          	subw	a3,s5,s3
    8000376a:	8d3a                	mv	s10,a4
    8000376c:	fae6f5e3          	bgeu	a3,a4,80003716 <readi+0x4c>
    80003770:	8d36                	mv	s10,a3
    80003772:	b755                	j	80003716 <readi+0x4c>
      brelse(bp);
    80003774:	854a                	mv	a0,s2
    80003776:	deaff0ef          	jal	80002d60 <brelse>
      tot = -1;
    8000377a:	59fd                	li	s3,-1
      break;
    8000377c:	6946                	ld	s2,80(sp)
    8000377e:	7c02                	ld	s8,32(sp)
    80003780:	6ce2                	ld	s9,24(sp)
    80003782:	6d42                	ld	s10,16(sp)
    80003784:	6da2                	ld	s11,8(sp)
    80003786:	a831                	j	800037a2 <readi+0xd8>
    80003788:	6946                	ld	s2,80(sp)
    8000378a:	7c02                	ld	s8,32(sp)
    8000378c:	6ce2                	ld	s9,24(sp)
    8000378e:	6d42                	ld	s10,16(sp)
    80003790:	6da2                	ld	s11,8(sp)
    80003792:	a801                	j	800037a2 <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003794:	89d6                	mv	s3,s5
    80003796:	a031                	j	800037a2 <readi+0xd8>
    80003798:	6946                	ld	s2,80(sp)
    8000379a:	7c02                	ld	s8,32(sp)
    8000379c:	6ce2                	ld	s9,24(sp)
    8000379e:	6d42                	ld	s10,16(sp)
    800037a0:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800037a2:	854e                	mv	a0,s3
    800037a4:	69a6                	ld	s3,72(sp)
}
    800037a6:	70a6                	ld	ra,104(sp)
    800037a8:	7406                	ld	s0,96(sp)
    800037aa:	64e6                	ld	s1,88(sp)
    800037ac:	6a06                	ld	s4,64(sp)
    800037ae:	7ae2                	ld	s5,56(sp)
    800037b0:	7b42                	ld	s6,48(sp)
    800037b2:	7ba2                	ld	s7,40(sp)
    800037b4:	6165                	addi	sp,sp,112
    800037b6:	8082                	ret
    return 0;
    800037b8:	4501                	li	a0,0
}
    800037ba:	8082                	ret

00000000800037bc <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    800037bc:	457c                	lw	a5,76(a0)
    800037be:	0ed7ee63          	bltu	a5,a3,800038ba <writei+0xfe>
{
    800037c2:	7159                	addi	sp,sp,-112
    800037c4:	f486                	sd	ra,104(sp)
    800037c6:	f0a2                	sd	s0,96(sp)
    800037c8:	e8ca                	sd	s2,80(sp)
    800037ca:	e0d2                	sd	s4,64(sp)
    800037cc:	fc56                	sd	s5,56(sp)
    800037ce:	f85a                	sd	s6,48(sp)
    800037d0:	f45e                	sd	s7,40(sp)
    800037d2:	1880                	addi	s0,sp,112
    800037d4:	8aaa                	mv	s5,a0
    800037d6:	8bae                	mv	s7,a1
    800037d8:	8a32                	mv	s4,a2
    800037da:	8936                	mv	s2,a3
    800037dc:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    800037de:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    800037e2:	00043737          	lui	a4,0x43
    800037e6:	0cf76c63          	bltu	a4,a5,800038be <writei+0x102>
    800037ea:	0cd7ea63          	bltu	a5,a3,800038be <writei+0x102>
    800037ee:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800037f0:	0a0b0d63          	beqz	s6,800038aa <writei+0xee>
    800037f4:	eca6                	sd	s1,88(sp)
    800037f6:	f062                	sd	s8,32(sp)
    800037f8:	ec66                	sd	s9,24(sp)
    800037fa:	e86a                	sd	s10,16(sp)
    800037fc:	e46e                	sd	s11,8(sp)
    800037fe:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003800:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003804:	5c7d                	li	s8,-1
    80003806:	a825                	j	8000383e <writei+0x82>
    80003808:	020d1d93          	slli	s11,s10,0x20
    8000380c:	020ddd93          	srli	s11,s11,0x20
    80003810:	05848513          	addi	a0,s1,88
    80003814:	86ee                	mv	a3,s11
    80003816:	8652                	mv	a2,s4
    80003818:	85de                	mv	a1,s7
    8000381a:	953e                	add	a0,a0,a5
    8000381c:	b79fe0ef          	jal	80002394 <either_copyin>
    80003820:	05850663          	beq	a0,s8,8000386c <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    80003824:	8526                	mv	a0,s1
    80003826:	6f0000ef          	jal	80003f16 <log_write>
    brelse(bp);
    8000382a:	8526                	mv	a0,s1
    8000382c:	d34ff0ef          	jal	80002d60 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003830:	013d09bb          	addw	s3,s10,s3
    80003834:	012d093b          	addw	s2,s10,s2
    80003838:	9a6e                	add	s4,s4,s11
    8000383a:	0369ff63          	bgeu	s3,s6,80003878 <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    8000383e:	00a9559b          	srliw	a1,s2,0xa
    80003842:	8556                	mv	a0,s5
    80003844:	f7aff0ef          	jal	80002fbe <bmap>
    80003848:	85aa                	mv	a1,a0
    if (addr == 0)
    8000384a:	c51d                	beqz	a0,80003878 <writei+0xbc>
    bp = bread(ip->dev, addr);
    8000384c:	000aa503          	lw	a0,0(s5)
    80003850:	c08ff0ef          	jal	80002c58 <bread>
    80003854:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003856:	3ff97793          	andi	a5,s2,1023
    8000385a:	40fc873b          	subw	a4,s9,a5
    8000385e:	413b06bb          	subw	a3,s6,s3
    80003862:	8d3a                	mv	s10,a4
    80003864:	fae6f2e3          	bgeu	a3,a4,80003808 <writei+0x4c>
    80003868:	8d36                	mv	s10,a3
    8000386a:	bf79                	j	80003808 <writei+0x4c>
      log_write(bp);
    8000386c:	8526                	mv	a0,s1
    8000386e:	6a8000ef          	jal	80003f16 <log_write>
      brelse(bp);
    80003872:	8526                	mv	a0,s1
    80003874:	cecff0ef          	jal	80002d60 <brelse>
  }

  if (off > ip->size)
    80003878:	04caa783          	lw	a5,76(s5)
    8000387c:	0327f963          	bgeu	a5,s2,800038ae <writei+0xf2>
    ip->size = off;
    80003880:	052aa623          	sw	s2,76(s5)
    80003884:	64e6                	ld	s1,88(sp)
    80003886:	7c02                	ld	s8,32(sp)
    80003888:	6ce2                	ld	s9,24(sp)
    8000388a:	6d42                	ld	s10,16(sp)
    8000388c:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000388e:	8556                	mv	a0,s5
    80003890:	9adff0ef          	jal	8000323c <iupdate>

  return tot;
    80003894:	854e                	mv	a0,s3
    80003896:	69a6                	ld	s3,72(sp)
}
    80003898:	70a6                	ld	ra,104(sp)
    8000389a:	7406                	ld	s0,96(sp)
    8000389c:	6946                	ld	s2,80(sp)
    8000389e:	6a06                	ld	s4,64(sp)
    800038a0:	7ae2                	ld	s5,56(sp)
    800038a2:	7b42                	ld	s6,48(sp)
    800038a4:	7ba2                	ld	s7,40(sp)
    800038a6:	6165                	addi	sp,sp,112
    800038a8:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800038aa:	89da                	mv	s3,s6
    800038ac:	b7cd                	j	8000388e <writei+0xd2>
    800038ae:	64e6                	ld	s1,88(sp)
    800038b0:	7c02                	ld	s8,32(sp)
    800038b2:	6ce2                	ld	s9,24(sp)
    800038b4:	6d42                	ld	s10,16(sp)
    800038b6:	6da2                	ld	s11,8(sp)
    800038b8:	bfd9                	j	8000388e <writei+0xd2>
    return -1;
    800038ba:	557d                	li	a0,-1
}
    800038bc:	8082                	ret
    return -1;
    800038be:	557d                	li	a0,-1
    800038c0:	bfe1                	j	80003898 <writei+0xdc>

00000000800038c2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800038c2:	1141                	addi	sp,sp,-16
    800038c4:	e406                	sd	ra,8(sp)
    800038c6:	e022                	sd	s0,0(sp)
    800038c8:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800038ca:	4639                	li	a2,14
    800038cc:	cf0fd0ef          	jal	80000dbc <strncmp>
}
    800038d0:	60a2                	ld	ra,8(sp)
    800038d2:	6402                	ld	s0,0(sp)
    800038d4:	0141                	addi	sp,sp,16
    800038d6:	8082                	ret

00000000800038d8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800038d8:	711d                	addi	sp,sp,-96
    800038da:	ec86                	sd	ra,88(sp)
    800038dc:	e8a2                	sd	s0,80(sp)
    800038de:	e4a6                	sd	s1,72(sp)
    800038e0:	e0ca                	sd	s2,64(sp)
    800038e2:	fc4e                	sd	s3,56(sp)
    800038e4:	f852                	sd	s4,48(sp)
    800038e6:	f456                	sd	s5,40(sp)
    800038e8:	f05a                	sd	s6,32(sp)
    800038ea:	ec5e                	sd	s7,24(sp)
    800038ec:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    800038ee:	04451703          	lh	a4,68(a0)
    800038f2:	4785                	li	a5,1
    800038f4:	00f71f63          	bne	a4,a5,80003912 <dirlookup+0x3a>
    800038f8:	892a                	mv	s2,a0
    800038fa:	8aae                	mv	s5,a1
    800038fc:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    800038fe:	457c                	lw	a5,76(a0)
    80003900:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003902:	fa040a13          	addi	s4,s0,-96
    80003906:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    80003908:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000390c:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    8000390e:	e39d                	bnez	a5,80003934 <dirlookup+0x5c>
    80003910:	a8b9                	j	8000396e <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003912:	00004517          	auipc	a0,0x4
    80003916:	bae50513          	addi	a0,a0,-1106 # 800074c0 <etext+0x4c0>
    8000391a:	f1bfc0ef          	jal	80000834 <panic>
      panic("dirlookup read");
    8000391e:	00004517          	auipc	a0,0x4
    80003922:	bba50513          	addi	a0,a0,-1094 # 800074d8 <etext+0x4d8>
    80003926:	f0ffc0ef          	jal	80000834 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    8000392a:	24c1                	addiw	s1,s1,16
    8000392c:	04c92783          	lw	a5,76(s2)
    80003930:	02f4fe63          	bgeu	s1,a5,8000396c <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003934:	874e                	mv	a4,s3
    80003936:	86a6                	mv	a3,s1
    80003938:	8652                	mv	a2,s4
    8000393a:	4581                	li	a1,0
    8000393c:	854a                	mv	a0,s2
    8000393e:	d8dff0ef          	jal	800036ca <readi>
    80003942:	fd351ee3          	bne	a0,s3,8000391e <dirlookup+0x46>
    if (de.inum == 0)
    80003946:	fa045783          	lhu	a5,-96(s0)
    8000394a:	d3e5                	beqz	a5,8000392a <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    8000394c:	85da                	mv	a1,s6
    8000394e:	8556                	mv	a0,s5
    80003950:	f73ff0ef          	jal	800038c2 <namecmp>
    80003954:	f979                	bnez	a0,8000392a <dirlookup+0x52>
      if (poff)
    80003956:	000b8463          	beqz	s7,8000395e <dirlookup+0x86>
        *poff = off;
    8000395a:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    8000395e:	fa045583          	lhu	a1,-96(s0)
    80003962:	00092503          	lw	a0,0(s2)
    80003966:	f18ff0ef          	jal	8000307e <iget>
    8000396a:	a011                	j	8000396e <dirlookup+0x96>
  return 0;
    8000396c:	4501                	li	a0,0
}
    8000396e:	60e6                	ld	ra,88(sp)
    80003970:	6446                	ld	s0,80(sp)
    80003972:	64a6                	ld	s1,72(sp)
    80003974:	6906                	ld	s2,64(sp)
    80003976:	79e2                	ld	s3,56(sp)
    80003978:	7a42                	ld	s4,48(sp)
    8000397a:	7aa2                	ld	s5,40(sp)
    8000397c:	7b02                	ld	s6,32(sp)
    8000397e:	6be2                	ld	s7,24(sp)
    80003980:	6125                	addi	sp,sp,96
    80003982:	8082                	ret

0000000080003984 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003984:	711d                	addi	sp,sp,-96
    80003986:	ec86                	sd	ra,88(sp)
    80003988:	e8a2                	sd	s0,80(sp)
    8000398a:	e4a6                	sd	s1,72(sp)
    8000398c:	e0ca                	sd	s2,64(sp)
    8000398e:	fc4e                	sd	s3,56(sp)
    80003990:	f852                	sd	s4,48(sp)
    80003992:	f456                	sd	s5,40(sp)
    80003994:	f05a                	sd	s6,32(sp)
    80003996:	ec5e                	sd	s7,24(sp)
    80003998:	e862                	sd	s8,16(sp)
    8000399a:	e466                	sd	s9,8(sp)
    8000399c:	e06a                	sd	s10,0(sp)
    8000399e:	1080                	addi	s0,sp,96
    800039a0:	84aa                	mv	s1,a0
    800039a2:	8b2e                	mv	s6,a1
    800039a4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    800039a6:	00054703          	lbu	a4,0(a0)
    800039aa:	02f00793          	li	a5,47
    800039ae:	00f70f63          	beq	a4,a5,800039cc <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800039b2:	ffbfd0ef          	jal	800019ac <myproc>
    800039b6:	15053503          	ld	a0,336(a0)
    800039ba:	901ff0ef          	jal	800032ba <idup>
    800039be:	8a2a                	mv	s4,a0
  while (*path == '/')
    800039c0:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    800039c4:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    800039c6:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    800039c8:	4b85                	li	s7,1
    800039ca:	a07d                	j	80003a78 <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    800039cc:	4585                	li	a1,1
    800039ce:	852e                	mv	a0,a1
    800039d0:	eaeff0ef          	jal	8000307e <iget>
    800039d4:	8a2a                	mv	s4,a0
    800039d6:	b7ed                	j	800039c0 <namex+0x3c>
      iunlockput(ip);
    800039d8:	8552                	mv	a0,s4
    800039da:	b6bff0ef          	jal	80003544 <iunlockput>
      return 0;
    800039de:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    800039e0:	8552                	mv	a0,s4
    800039e2:	60e6                	ld	ra,88(sp)
    800039e4:	6446                	ld	s0,80(sp)
    800039e6:	64a6                	ld	s1,72(sp)
    800039e8:	6906                	ld	s2,64(sp)
    800039ea:	79e2                	ld	s3,56(sp)
    800039ec:	7a42                	ld	s4,48(sp)
    800039ee:	7aa2                	ld	s5,40(sp)
    800039f0:	7b02                	ld	s6,32(sp)
    800039f2:	6be2                	ld	s7,24(sp)
    800039f4:	6c42                	ld	s8,16(sp)
    800039f6:	6ca2                	ld	s9,8(sp)
    800039f8:	6d02                	ld	s10,0(sp)
    800039fa:	6125                	addi	sp,sp,96
    800039fc:	8082                	ret
      iunlockput(ip);
    800039fe:	8552                	mv	a0,s4
    80003a00:	b45ff0ef          	jal	80003544 <iunlockput>
      return 0;
    80003a04:	4a01                	li	s4,0
    80003a06:	bfe9                	j	800039e0 <namex+0x5c>
      iunlock(ip);
    80003a08:	8552                	mv	a0,s4
    80003a0a:	995ff0ef          	jal	8000339e <iunlock>
      return ip;
    80003a0e:	bfc9                	j	800039e0 <namex+0x5c>
      iunlockput(ip);
    80003a10:	8552                	mv	a0,s4
    80003a12:	b33ff0ef          	jal	80003544 <iunlockput>
      return 0;
    80003a16:	8a4a                	mv	s4,s2
    80003a18:	b7e1                	j	800039e0 <namex+0x5c>
  while (*path != '/' && *path != 0)
    80003a1a:	8926                	mv	s2,s1
  len = path - s;
    80003a1c:	4d01                	li	s10,0
    80003a1e:	4601                	li	a2,0
    memmove(name, s, len);
    80003a20:	2601                	sext.w	a2,a2
    80003a22:	85a6                	mv	a1,s1
    80003a24:	8556                	mv	a0,s5
    80003a26:	b22fd0ef          	jal	80000d48 <memmove>
    name[len] = 0;
    80003a2a:	9d56                	add	s10,s10,s5
    80003a2c:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffdb978>
  while (*path == '/')
    80003a30:	00094783          	lbu	a5,0(s2)
    80003a34:	09379b63          	bne	a5,s3,80003aca <namex+0x146>
    80003a38:	84ca                	mv	s1,s2
    path++;
    80003a3a:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003a3c:	0004c783          	lbu	a5,0(s1)
    80003a40:	ff378de3          	beq	a5,s3,80003a3a <namex+0xb6>
    ilock(ip);
    80003a44:	8552                	mv	a0,s4
    80003a46:	8abff0ef          	jal	800032f0 <ilock>
    if (ip->type != T_DIR) {
    80003a4a:	044a1783          	lh	a5,68(s4)
    80003a4e:	f97795e3          	bne	a5,s7,800039d8 <namex+0x54>
    if (ip->nlink == 0) {
    80003a52:	04aa1783          	lh	a5,74(s4)
    80003a56:	d7c5                	beqz	a5,800039fe <namex+0x7a>
    if (nameiparent && *path == '\0') {
    80003a58:	000b0563          	beqz	s6,80003a62 <namex+0xde>
    80003a5c:	0004c783          	lbu	a5,0(s1)
    80003a60:	d7c5                	beqz	a5,80003a08 <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003a62:	4601                	li	a2,0
    80003a64:	85d6                	mv	a1,s5
    80003a66:	8552                	mv	a0,s4
    80003a68:	e71ff0ef          	jal	800038d8 <dirlookup>
    80003a6c:	892a                	mv	s2,a0
    80003a6e:	d14d                	beqz	a0,80003a10 <namex+0x8c>
    iunlockput(ip);
    80003a70:	8552                	mv	a0,s4
    80003a72:	ad3ff0ef          	jal	80003544 <iunlockput>
    ip = next;
    80003a76:	8a4a                	mv	s4,s2
  while (*path == '/')
    80003a78:	0004c783          	lbu	a5,0(s1)
    80003a7c:	01379763          	bne	a5,s3,80003a8a <namex+0x106>
    path++;
    80003a80:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003a82:	0004c783          	lbu	a5,0(s1)
    80003a86:	ff378de3          	beq	a5,s3,80003a80 <namex+0xfc>
  if (*path == 0)
    80003a8a:	c7a1                	beqz	a5,80003ad2 <namex+0x14e>
  while (*path != '/' && *path != 0)
    80003a8c:	0004c783          	lbu	a5,0(s1)
    80003a90:	fd178713          	addi	a4,a5,-47
    80003a94:	d359                	beqz	a4,80003a1a <namex+0x96>
    80003a96:	d3d1                	beqz	a5,80003a1a <namex+0x96>
    80003a98:	8926                	mv	s2,s1
    path++;
    80003a9a:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    80003a9c:	00094783          	lbu	a5,0(s2)
    80003aa0:	fd178713          	addi	a4,a5,-47
    80003aa4:	c311                	beqz	a4,80003aa8 <namex+0x124>
    80003aa6:	fbf5                	bnez	a5,80003a9a <namex+0x116>
  len = path - s;
    80003aa8:	40990633          	sub	a2,s2,s1
    80003aac:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80003ab0:	f7ac58e3          	bge	s8,s10,80003a20 <namex+0x9c>
    memmove(name, s, DIRSIZ);
    80003ab4:	8666                	mv	a2,s9
    80003ab6:	85a6                	mv	a1,s1
    80003ab8:	8556                	mv	a0,s5
    80003aba:	a8efd0ef          	jal	80000d48 <memmove>
  while (*path == '/')
    80003abe:	00094783          	lbu	a5,0(s2)
    80003ac2:	84ca                	mv	s1,s2
    80003ac4:	f7378be3          	beq	a5,s3,80003a3a <namex+0xb6>
    80003ac8:	bfb5                	j	80003a44 <namex+0xc0>
  while ((path = skipelem(path, name)) != 0) {
    80003aca:	00090463          	beqz	s2,80003ad2 <namex+0x14e>
    80003ace:	84ca                	mv	s1,s2
    80003ad0:	bf95                	j	80003a44 <namex+0xc0>
  if (nameiparent) {
    80003ad2:	f00b07e3          	beqz	s6,800039e0 <namex+0x5c>
    iput(ip);
    80003ad6:	8552                	mv	a0,s4
    80003ad8:	99bff0ef          	jal	80003472 <iput>
    return 0;
    80003adc:	4a01                	li	s4,0
    80003ade:	b709                	j	800039e0 <namex+0x5c>

0000000080003ae0 <dirlink>:
{
    80003ae0:	715d                	addi	sp,sp,-80
    80003ae2:	e486                	sd	ra,72(sp)
    80003ae4:	e0a2                	sd	s0,64(sp)
    80003ae6:	f84a                	sd	s2,48(sp)
    80003ae8:	ec56                	sd	s5,24(sp)
    80003aea:	e85a                	sd	s6,16(sp)
    80003aec:	0880                	addi	s0,sp,80
    80003aee:	892a                	mv	s2,a0
    80003af0:	8aae                	mv	s5,a1
    80003af2:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003af4:	4601                	li	a2,0
    80003af6:	de3ff0ef          	jal	800038d8 <dirlookup>
    80003afa:	ed1d                	bnez	a0,80003b38 <dirlink+0x58>
    80003afc:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003afe:	04c92483          	lw	s1,76(s2)
    80003b02:	c4b9                	beqz	s1,80003b50 <dirlink+0x70>
    80003b04:	f44e                	sd	s3,40(sp)
    80003b06:	f052                	sd	s4,32(sp)
    80003b08:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b0a:	fb040a13          	addi	s4,s0,-80
    80003b0e:	49c1                	li	s3,16
    80003b10:	874e                	mv	a4,s3
    80003b12:	86a6                	mv	a3,s1
    80003b14:	8652                	mv	a2,s4
    80003b16:	4581                	li	a1,0
    80003b18:	854a                	mv	a0,s2
    80003b1a:	bb1ff0ef          	jal	800036ca <readi>
    80003b1e:	03351163          	bne	a0,s3,80003b40 <dirlink+0x60>
    if (de.inum == 0)
    80003b22:	fb045783          	lhu	a5,-80(s0)
    80003b26:	c39d                	beqz	a5,80003b4c <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003b28:	24c1                	addiw	s1,s1,16
    80003b2a:	04c92783          	lw	a5,76(s2)
    80003b2e:	fef4e1e3          	bltu	s1,a5,80003b10 <dirlink+0x30>
    80003b32:	79a2                	ld	s3,40(sp)
    80003b34:	7a02                	ld	s4,32(sp)
    80003b36:	a829                	j	80003b50 <dirlink+0x70>
    iput(ip);
    80003b38:	93bff0ef          	jal	80003472 <iput>
    return -1;
    80003b3c:	557d                	li	a0,-1
    80003b3e:	a83d                	j	80003b7c <dirlink+0x9c>
      panic("dirlink read");
    80003b40:	00004517          	auipc	a0,0x4
    80003b44:	9a850513          	addi	a0,a0,-1624 # 800074e8 <etext+0x4e8>
    80003b48:	cedfc0ef          	jal	80000834 <panic>
    80003b4c:	79a2                	ld	s3,40(sp)
    80003b4e:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003b50:	4639                	li	a2,14
    80003b52:	85d6                	mv	a1,s5
    80003b54:	fb240513          	addi	a0,s0,-78
    80003b58:	a9efd0ef          	jal	80000df6 <strncpy>
  de.inum = inum;
    80003b5c:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b60:	4741                	li	a4,16
    80003b62:	86a6                	mv	a3,s1
    80003b64:	fb040613          	addi	a2,s0,-80
    80003b68:	4581                	li	a1,0
    80003b6a:	854a                	mv	a0,s2
    80003b6c:	c51ff0ef          	jal	800037bc <writei>
    80003b70:	1541                	addi	a0,a0,-16
    80003b72:	00a03533          	snez	a0,a0
    80003b76:	40a0053b          	negw	a0,a0
    80003b7a:	74e2                	ld	s1,56(sp)
}
    80003b7c:	60a6                	ld	ra,72(sp)
    80003b7e:	6406                	ld	s0,64(sp)
    80003b80:	7942                	ld	s2,48(sp)
    80003b82:	6ae2                	ld	s5,24(sp)
    80003b84:	6b42                	ld	s6,16(sp)
    80003b86:	6161                	addi	sp,sp,80
    80003b88:	8082                	ret

0000000080003b8a <namei>:

struct inode *
namei(char *path)
{
    80003b8a:	1101                	addi	sp,sp,-32
    80003b8c:	ec06                	sd	ra,24(sp)
    80003b8e:	e822                	sd	s0,16(sp)
    80003b90:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003b92:	fe040613          	addi	a2,s0,-32
    80003b96:	4581                	li	a1,0
    80003b98:	dedff0ef          	jal	80003984 <namex>
}
    80003b9c:	60e2                	ld	ra,24(sp)
    80003b9e:	6442                	ld	s0,16(sp)
    80003ba0:	6105                	addi	sp,sp,32
    80003ba2:	8082                	ret

0000000080003ba4 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003ba4:	1141                	addi	sp,sp,-16
    80003ba6:	e406                	sd	ra,8(sp)
    80003ba8:	e022                	sd	s0,0(sp)
    80003baa:	0800                	addi	s0,sp,16
    80003bac:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003bae:	4585                	li	a1,1
    80003bb0:	dd5ff0ef          	jal	80003984 <namex>
}
    80003bb4:	60a2                	ld	ra,8(sp)
    80003bb6:	6402                	ld	s0,0(sp)
    80003bb8:	0141                	addi	sp,sp,16
    80003bba:	8082                	ret

0000000080003bbc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003bbc:	1101                	addi	sp,sp,-32
    80003bbe:	ec06                	sd	ra,24(sp)
    80003bc0:	e822                	sd	s0,16(sp)
    80003bc2:	e426                	sd	s1,8(sp)
    80003bc4:	e04a                	sd	s2,0(sp)
    80003bc6:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003bc8:	0001f917          	auipc	s2,0x1f
    80003bcc:	88090913          	addi	s2,s2,-1920 # 80022448 <log>
    80003bd0:	01892583          	lw	a1,24(s2)
    80003bd4:	02492503          	lw	a0,36(s2)
    80003bd8:	880ff0ef          	jal	80002c58 <bread>
    80003bdc:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003bde:	02c92603          	lw	a2,44(s2)
    80003be2:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003be4:	00c05f63          	blez	a2,80003c02 <write_head+0x46>
    80003be8:	0001f717          	auipc	a4,0x1f
    80003bec:	89070713          	addi	a4,a4,-1904 # 80022478 <log+0x30>
    80003bf0:	87aa                	mv	a5,a0
    80003bf2:	060a                	slli	a2,a2,0x2
    80003bf4:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003bf6:	4314                	lw	a3,0(a4)
    80003bf8:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003bfa:	0711                	addi	a4,a4,4
    80003bfc:	0791                	addi	a5,a5,4
    80003bfe:	fec79ce3          	bne	a5,a2,80003bf6 <write_head+0x3a>
  }
  bwrite(buf);
    80003c02:	8526                	mv	a0,s1
    80003c04:	92aff0ef          	jal	80002d2e <bwrite>
  brelse(buf);
    80003c08:	8526                	mv	a0,s1
    80003c0a:	956ff0ef          	jal	80002d60 <brelse>
}
    80003c0e:	60e2                	ld	ra,24(sp)
    80003c10:	6442                	ld	s0,16(sp)
    80003c12:	64a2                	ld	s1,8(sp)
    80003c14:	6902                	ld	s2,0(sp)
    80003c16:	6105                	addi	sp,sp,32
    80003c18:	8082                	ret

0000000080003c1a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c1a:	0001f797          	auipc	a5,0x1f
    80003c1e:	85a7a783          	lw	a5,-1958(a5) # 80022474 <log+0x2c>
    80003c22:	0cf05163          	blez	a5,80003ce4 <install_trans+0xca>
{
    80003c26:	715d                	addi	sp,sp,-80
    80003c28:	e486                	sd	ra,72(sp)
    80003c2a:	e0a2                	sd	s0,64(sp)
    80003c2c:	fc26                	sd	s1,56(sp)
    80003c2e:	f84a                	sd	s2,48(sp)
    80003c30:	f44e                	sd	s3,40(sp)
    80003c32:	f052                	sd	s4,32(sp)
    80003c34:	ec56                	sd	s5,24(sp)
    80003c36:	e85a                	sd	s6,16(sp)
    80003c38:	e45e                	sd	s7,8(sp)
    80003c3a:	e062                	sd	s8,0(sp)
    80003c3c:	0880                	addi	s0,sp,80
    80003c3e:	8b2a                	mv	s6,a0
    80003c40:	0001fa97          	auipc	s5,0x1f
    80003c44:	838a8a93          	addi	s5,s5,-1992 # 80022478 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c48:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c4a:	00004c17          	auipc	s8,0x4
    80003c4e:	8aec0c13          	addi	s8,s8,-1874 # 800074f8 <etext+0x4f8>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003c52:	0001ea17          	auipc	s4,0x1e
    80003c56:	7f6a0a13          	addi	s4,s4,2038 # 80022448 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003c5a:	40000b93          	li	s7,1024
    80003c5e:	a025                	j	80003c86 <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c60:	000aa603          	lw	a2,0(s5)
    80003c64:	85ce                	mv	a1,s3
    80003c66:	8562                	mv	a0,s8
    80003c68:	8a3fc0ef          	jal	8000050a <printk>
    80003c6c:	a839                	j	80003c8a <install_trans+0x70>
    brelse(lbuf);
    80003c6e:	854a                	mv	a0,s2
    80003c70:	8f0ff0ef          	jal	80002d60 <brelse>
    brelse(dbuf);
    80003c74:	8526                	mv	a0,s1
    80003c76:	8eaff0ef          	jal	80002d60 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c7a:	2985                	addiw	s3,s3,1
    80003c7c:	0a91                	addi	s5,s5,4
    80003c7e:	02ca2783          	lw	a5,44(s4)
    80003c82:	04f9d563          	bge	s3,a5,80003ccc <install_trans+0xb2>
    if (recovering) {
    80003c86:	fc0b1de3          	bnez	s6,80003c60 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003c8a:	018a2583          	lw	a1,24(s4)
    80003c8e:	013585bb          	addw	a1,a1,s3
    80003c92:	2585                	addiw	a1,a1,1
    80003c94:	024a2503          	lw	a0,36(s4)
    80003c98:	fc1fe0ef          	jal	80002c58 <bread>
    80003c9c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003c9e:	000aa583          	lw	a1,0(s5)
    80003ca2:	024a2503          	lw	a0,36(s4)
    80003ca6:	fb3fe0ef          	jal	80002c58 <bread>
    80003caa:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003cac:	865e                	mv	a2,s7
    80003cae:	05890593          	addi	a1,s2,88
    80003cb2:	05850513          	addi	a0,a0,88
    80003cb6:	892fd0ef          	jal	80000d48 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003cba:	8526                	mv	a0,s1
    80003cbc:	872ff0ef          	jal	80002d2e <bwrite>
    if (recovering == 0)
    80003cc0:	fa0b17e3          	bnez	s6,80003c6e <install_trans+0x54>
      bunpin(dbuf);
    80003cc4:	8526                	mv	a0,s1
    80003cc6:	952ff0ef          	jal	80002e18 <bunpin>
    80003cca:	b755                	j	80003c6e <install_trans+0x54>
}
    80003ccc:	60a6                	ld	ra,72(sp)
    80003cce:	6406                	ld	s0,64(sp)
    80003cd0:	74e2                	ld	s1,56(sp)
    80003cd2:	7942                	ld	s2,48(sp)
    80003cd4:	79a2                	ld	s3,40(sp)
    80003cd6:	7a02                	ld	s4,32(sp)
    80003cd8:	6ae2                	ld	s5,24(sp)
    80003cda:	6b42                	ld	s6,16(sp)
    80003cdc:	6ba2                	ld	s7,8(sp)
    80003cde:	6c02                	ld	s8,0(sp)
    80003ce0:	6161                	addi	sp,sp,80
    80003ce2:	8082                	ret
    80003ce4:	8082                	ret

0000000080003ce6 <initlog>:
{
    80003ce6:	7179                	addi	sp,sp,-48
    80003ce8:	f406                	sd	ra,40(sp)
    80003cea:	f022                	sd	s0,32(sp)
    80003cec:	ec26                	sd	s1,24(sp)
    80003cee:	e84a                	sd	s2,16(sp)
    80003cf0:	e44e                	sd	s3,8(sp)
    80003cf2:	1800                	addi	s0,sp,48
    80003cf4:	84aa                	mv	s1,a0
    80003cf6:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003cf8:	0001e917          	auipc	s2,0x1e
    80003cfc:	75090913          	addi	s2,s2,1872 # 80022448 <log>
    80003d00:	00004597          	auipc	a1,0x4
    80003d04:	81858593          	addi	a1,a1,-2024 # 80007518 <etext+0x518>
    80003d08:	854a                	mv	a0,s2
    80003d0a:	e9ffc0ef          	jal	80000ba8 <initlock>
  log.start = sb->logstart;
    80003d0e:	0149a583          	lw	a1,20(s3)
    80003d12:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003d16:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003d1a:	8526                	mv	a0,s1
    80003d1c:	f3dfe0ef          	jal	80002c58 <bread>
  log.lh.n = lh->n;
    80003d20:	4d30                	lw	a2,88(a0)
    80003d22:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003d26:	00c05f63          	blez	a2,80003d44 <initlog+0x5e>
    80003d2a:	87aa                	mv	a5,a0
    80003d2c:	0001e717          	auipc	a4,0x1e
    80003d30:	74c70713          	addi	a4,a4,1868 # 80022478 <log+0x30>
    80003d34:	060a                	slli	a2,a2,0x2
    80003d36:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003d38:	4ff4                	lw	a3,92(a5)
    80003d3a:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003d3c:	0791                	addi	a5,a5,4
    80003d3e:	0711                	addi	a4,a4,4
    80003d40:	fec79ce3          	bne	a5,a2,80003d38 <initlog+0x52>
  brelse(buf);
    80003d44:	81cff0ef          	jal	80002d60 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003d48:	4505                	li	a0,1
    80003d4a:	ed1ff0ef          	jal	80003c1a <install_trans>
  log.lh.n = 0;
    80003d4e:	0001e797          	auipc	a5,0x1e
    80003d52:	7207a323          	sw	zero,1830(a5) # 80022474 <log+0x2c>
  write_head(); // clear the log
    80003d56:	e67ff0ef          	jal	80003bbc <write_head>
}
    80003d5a:	70a2                	ld	ra,40(sp)
    80003d5c:	7402                	ld	s0,32(sp)
    80003d5e:	64e2                	ld	s1,24(sp)
    80003d60:	6942                	ld	s2,16(sp)
    80003d62:	69a2                	ld	s3,8(sp)
    80003d64:	6145                	addi	sp,sp,48
    80003d66:	8082                	ret

0000000080003d68 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003d68:	1101                	addi	sp,sp,-32
    80003d6a:	ec06                	sd	ra,24(sp)
    80003d6c:	e822                	sd	s0,16(sp)
    80003d6e:	e426                	sd	s1,8(sp)
    80003d70:	e04a                	sd	s2,0(sp)
    80003d72:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003d74:	0001e517          	auipc	a0,0x1e
    80003d78:	6d450513          	addi	a0,a0,1748 # 80022448 <log>
    80003d7c:	eadfc0ef          	jal	80000c28 <acquire>
  while (1) {
    if (log.committing) {
    80003d80:	0001e497          	auipc	s1,0x1e
    80003d84:	6c848493          	addi	s1,s1,1736 # 80022448 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003d88:	4979                	li	s2,30
    80003d8a:	a821                	j	80003da2 <begin_op+0x3a>
      sleep_prepare(&log);
    80003d8c:	8526                	mv	a0,s1
    80003d8e:	a28fe0ef          	jal	80001fb6 <sleep_prepare>
      release(&log.lock);
    80003d92:	8526                	mv	a0,s1
    80003d94:	f1dfc0ef          	jal	80000cb0 <release>
      sleep();
    80003d98:	a5afe0ef          	jal	80001ff2 <sleep>
      acquire(&log.lock);
    80003d9c:	8526                	mv	a0,s1
    80003d9e:	e8bfc0ef          	jal	80000c28 <acquire>
    if (log.committing) {
    80003da2:	509c                	lw	a5,32(s1)
    80003da4:	f7e5                	bnez	a5,80003d8c <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003da6:	4cd8                	lw	a4,28(s1)
    80003da8:	2705                	addiw	a4,a4,1
    80003daa:	0027179b          	slliw	a5,a4,0x2
    80003dae:	9fb9                	addw	a5,a5,a4
    80003db0:	0017979b          	slliw	a5,a5,0x1
    80003db4:	54d4                	lw	a3,44(s1)
    80003db6:	9fb5                	addw	a5,a5,a3
    80003db8:	00f95e63          	bge	s2,a5,80003dd4 <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003dbc:	8526                	mv	a0,s1
    80003dbe:	9f8fe0ef          	jal	80001fb6 <sleep_prepare>
      release(&log.lock);
    80003dc2:	8526                	mv	a0,s1
    80003dc4:	eedfc0ef          	jal	80000cb0 <release>
      sleep();
    80003dc8:	a2afe0ef          	jal	80001ff2 <sleep>
      acquire(&log.lock);
    80003dcc:	8526                	mv	a0,s1
    80003dce:	e5bfc0ef          	jal	80000c28 <acquire>
    80003dd2:	bfc1                	j	80003da2 <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003dd4:	0001e797          	auipc	a5,0x1e
    80003dd8:	68e7a823          	sw	a4,1680(a5) # 80022464 <log+0x1c>
      release(&log.lock);
    80003ddc:	0001e517          	auipc	a0,0x1e
    80003de0:	66c50513          	addi	a0,a0,1644 # 80022448 <log>
    80003de4:	ecdfc0ef          	jal	80000cb0 <release>
      break;
    }
  }
}
    80003de8:	60e2                	ld	ra,24(sp)
    80003dea:	6442                	ld	s0,16(sp)
    80003dec:	64a2                	ld	s1,8(sp)
    80003dee:	6902                	ld	s2,0(sp)
    80003df0:	6105                	addi	sp,sp,32
    80003df2:	8082                	ret

0000000080003df4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003df4:	7139                	addi	sp,sp,-64
    80003df6:	fc06                	sd	ra,56(sp)
    80003df8:	f822                	sd	s0,48(sp)
    80003dfa:	f426                	sd	s1,40(sp)
    80003dfc:	f04a                	sd	s2,32(sp)
    80003dfe:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003e00:	0001e497          	auipc	s1,0x1e
    80003e04:	64848493          	addi	s1,s1,1608 # 80022448 <log>
    80003e08:	8526                	mv	a0,s1
    80003e0a:	e1ffc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003e0e:	4cdc                	lw	a5,28(s1)
    80003e10:	37fd                	addiw	a5,a5,-1
    80003e12:	893e                	mv	s2,a5
    80003e14:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003e16:	509c                	lw	a5,32(s1)
    80003e18:	e3b1                	bnez	a5,80003e5c <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003e1a:	04091a63          	bnez	s2,80003e6e <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    80003e1e:	0001e497          	auipc	s1,0x1e
    80003e22:	62a48493          	addi	s1,s1,1578 # 80022448 <log>
    80003e26:	4785                	li	a5,1
    80003e28:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003e2a:	8526                	mv	a0,s1
    80003e2c:	e85fc0ef          	jal	80000cb0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003e30:	54dc                	lw	a5,44(s1)
    80003e32:	06f04063          	bgtz	a5,80003e92 <end_op+0x9e>
    acquire(&log.lock);
    80003e36:	0001e497          	auipc	s1,0x1e
    80003e3a:	61248493          	addi	s1,s1,1554 # 80022448 <log>
    80003e3e:	8526                	mv	a0,s1
    80003e40:	de9fc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003e44:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003e48:	549c                	lw	a5,40(s1)
    80003e4a:	2785                	addiw	a5,a5,1
    80003e4c:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003e4e:	8526                	mv	a0,s1
    80003e50:	9d2fe0ef          	jal	80002022 <wakeup>
    release(&log.lock);
    80003e54:	8526                	mv	a0,s1
    80003e56:	e5bfc0ef          	jal	80000cb0 <release>
}
    80003e5a:	a035                	j	80003e86 <end_op+0x92>
    80003e5c:	ec4e                	sd	s3,24(sp)
    80003e5e:	e852                	sd	s4,16(sp)
    80003e60:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003e62:	00003517          	auipc	a0,0x3
    80003e66:	6be50513          	addi	a0,a0,1726 # 80007520 <etext+0x520>
    80003e6a:	9cbfc0ef          	jal	80000834 <panic>
    wakeup(&log);
    80003e6e:	0001e517          	auipc	a0,0x1e
    80003e72:	5da50513          	addi	a0,a0,1498 # 80022448 <log>
    80003e76:	9acfe0ef          	jal	80002022 <wakeup>
  release(&log.lock);
    80003e7a:	0001e517          	auipc	a0,0x1e
    80003e7e:	5ce50513          	addi	a0,a0,1486 # 80022448 <log>
    80003e82:	e2ffc0ef          	jal	80000cb0 <release>
}
    80003e86:	70e2                	ld	ra,56(sp)
    80003e88:	7442                	ld	s0,48(sp)
    80003e8a:	74a2                	ld	s1,40(sp)
    80003e8c:	7902                	ld	s2,32(sp)
    80003e8e:	6121                	addi	sp,sp,64
    80003e90:	8082                	ret
    80003e92:	ec4e                	sd	s3,24(sp)
    80003e94:	e852                	sd	s4,16(sp)
    80003e96:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e98:	0001ea97          	auipc	s5,0x1e
    80003e9c:	5e0a8a93          	addi	s5,s5,1504 # 80022478 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003ea0:	0001ea17          	auipc	s4,0x1e
    80003ea4:	5a8a0a13          	addi	s4,s4,1448 # 80022448 <log>
    80003ea8:	018a2583          	lw	a1,24(s4)
    80003eac:	012585bb          	addw	a1,a1,s2
    80003eb0:	2585                	addiw	a1,a1,1
    80003eb2:	024a2503          	lw	a0,36(s4)
    80003eb6:	da3fe0ef          	jal	80002c58 <bread>
    80003eba:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003ebc:	000aa583          	lw	a1,0(s5)
    80003ec0:	024a2503          	lw	a0,36(s4)
    80003ec4:	d95fe0ef          	jal	80002c58 <bread>
    80003ec8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003eca:	40000613          	li	a2,1024
    80003ece:	05850593          	addi	a1,a0,88
    80003ed2:	05848513          	addi	a0,s1,88
    80003ed6:	e73fc0ef          	jal	80000d48 <memmove>
    bwrite(to); // write the log
    80003eda:	8526                	mv	a0,s1
    80003edc:	e53fe0ef          	jal	80002d2e <bwrite>
    brelse(from);
    80003ee0:	854e                	mv	a0,s3
    80003ee2:	e7ffe0ef          	jal	80002d60 <brelse>
    brelse(to);
    80003ee6:	8526                	mv	a0,s1
    80003ee8:	e79fe0ef          	jal	80002d60 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003eec:	2905                	addiw	s2,s2,1
    80003eee:	0a91                	addi	s5,s5,4
    80003ef0:	02ca2783          	lw	a5,44(s4)
    80003ef4:	faf94ae3          	blt	s2,a5,80003ea8 <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80003ef8:	cc5ff0ef          	jal	80003bbc <write_head>
    install_trans(0); // Now install writes to home locations
    80003efc:	4501                	li	a0,0
    80003efe:	d1dff0ef          	jal	80003c1a <install_trans>
    log.lh.n = 0;
    80003f02:	0001e797          	auipc	a5,0x1e
    80003f06:	5607a923          	sw	zero,1394(a5) # 80022474 <log+0x2c>
    write_head(); // Erase the transaction from the log
    80003f0a:	cb3ff0ef          	jal	80003bbc <write_head>
    80003f0e:	69e2                	ld	s3,24(sp)
    80003f10:	6a42                	ld	s4,16(sp)
    80003f12:	6aa2                	ld	s5,8(sp)
    80003f14:	b70d                	j	80003e36 <end_op+0x42>

0000000080003f16 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003f16:	1101                	addi	sp,sp,-32
    80003f18:	ec06                	sd	ra,24(sp)
    80003f1a:	e822                	sd	s0,16(sp)
    80003f1c:	e426                	sd	s1,8(sp)
    80003f1e:	1000                	addi	s0,sp,32
    80003f20:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003f22:	0001e517          	auipc	a0,0x1e
    80003f26:	52650513          	addi	a0,a0,1318 # 80022448 <log>
    80003f2a:	cfffc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003f2e:	0001e617          	auipc	a2,0x1e
    80003f32:	54662603          	lw	a2,1350(a2) # 80022474 <log+0x2c>
    80003f36:	47f5                	li	a5,29
    80003f38:	04c7cd63          	blt	a5,a2,80003f92 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003f3c:	0001e797          	auipc	a5,0x1e
    80003f40:	5287a783          	lw	a5,1320(a5) # 80022464 <log+0x1c>
    80003f44:	04f05d63          	blez	a5,80003f9e <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003f48:	4781                	li	a5,0
    80003f4a:	06c05063          	blez	a2,80003faa <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    80003f4e:	44cc                	lw	a1,12(s1)
    80003f50:	0001e717          	auipc	a4,0x1e
    80003f54:	52870713          	addi	a4,a4,1320 # 80022478 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003f58:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80003f5a:	4314                	lw	a3,0(a4)
    80003f5c:	04b68763          	beq	a3,a1,80003faa <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80003f60:	2785                	addiw	a5,a5,1
    80003f62:	0711                	addi	a4,a4,4
    80003f64:	fef61be3          	bne	a2,a5,80003f5a <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003f68:	060a                	slli	a2,a2,0x2
    80003f6a:	02060613          	addi	a2,a2,32
    80003f6e:	0001e797          	auipc	a5,0x1e
    80003f72:	4da78793          	addi	a5,a5,1242 # 80022448 <log>
    80003f76:	97b2                	add	a5,a5,a2
    80003f78:	44d8                	lw	a4,12(s1)
    80003f7a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80003f7c:	8526                	mv	a0,s1
    80003f7e:	e67fe0ef          	jal	80002de4 <bpin>
    log.lh.n++;
    80003f82:	0001e717          	auipc	a4,0x1e
    80003f86:	4c670713          	addi	a4,a4,1222 # 80022448 <log>
    80003f8a:	575c                	lw	a5,44(a4)
    80003f8c:	2785                	addiw	a5,a5,1
    80003f8e:	d75c                	sw	a5,44(a4)
    80003f90:	a815                	j	80003fc4 <log_write+0xae>
    panic("too big a transaction");
    80003f92:	00003517          	auipc	a0,0x3
    80003f96:	59e50513          	addi	a0,a0,1438 # 80007530 <etext+0x530>
    80003f9a:	89bfc0ef          	jal	80000834 <panic>
    panic("log_write outside of trans");
    80003f9e:	00003517          	auipc	a0,0x3
    80003fa2:	5aa50513          	addi	a0,a0,1450 # 80007548 <etext+0x548>
    80003fa6:	88ffc0ef          	jal	80000834 <panic>
  log.lh.block[i] = b->blockno;
    80003faa:	00279693          	slli	a3,a5,0x2
    80003fae:	02068693          	addi	a3,a3,32
    80003fb2:	0001e717          	auipc	a4,0x1e
    80003fb6:	49670713          	addi	a4,a4,1174 # 80022448 <log>
    80003fba:	9736                	add	a4,a4,a3
    80003fbc:	44d4                	lw	a3,12(s1)
    80003fbe:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    80003fc0:	faf60ee3          	beq	a2,a5,80003f7c <log_write+0x66>
  }
  release(&log.lock);
    80003fc4:	0001e517          	auipc	a0,0x1e
    80003fc8:	48450513          	addi	a0,a0,1156 # 80022448 <log>
    80003fcc:	ce5fc0ef          	jal	80000cb0 <release>
}
    80003fd0:	60e2                	ld	ra,24(sp)
    80003fd2:	6442                	ld	s0,16(sp)
    80003fd4:	64a2                	ld	s1,8(sp)
    80003fd6:	6105                	addi	sp,sp,32
    80003fd8:	8082                	ret

0000000080003fda <sys_sync>:

uint64
sys_sync(void)
{
    80003fda:	1101                	addi	sp,sp,-32
    80003fdc:	ec06                	sd	ra,24(sp)
    80003fde:	e822                	sd	s0,16(sp)
    80003fe0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003fe2:	0001e517          	auipc	a0,0x1e
    80003fe6:	46650513          	addi	a0,a0,1126 # 80022448 <log>
    80003fea:	c3ffc0ef          	jal	80000c28 <acquire>
  if (log.committing || log.outstanding > 0) {
    80003fee:	0001e797          	auipc	a5,0x1e
    80003ff2:	47a7a783          	lw	a5,1146(a5) # 80022468 <log+0x20>
    80003ff6:	e799                	bnez	a5,80004004 <sys_sync+0x2a>
    80003ff8:	0001e797          	auipc	a5,0x1e
    80003ffc:	46c7a783          	lw	a5,1132(a5) # 80022464 <log+0x1c>
    80004000:	02f05c63          	blez	a5,80004038 <sys_sync+0x5e>
    80004004:	e426                	sd	s1,8(sp)
    80004006:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    80004008:	0001e917          	auipc	s2,0x1e
    8000400c:	46892903          	lw	s2,1128(s2) # 80022470 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    80004010:	0001e497          	auipc	s1,0x1e
    80004014:	43848493          	addi	s1,s1,1080 # 80022448 <log>
    80004018:	8526                	mv	a0,s1
    8000401a:	f9dfd0ef          	jal	80001fb6 <sleep_prepare>
      release(&log.lock);
    8000401e:	8526                	mv	a0,s1
    80004020:	c91fc0ef          	jal	80000cb0 <release>
      sleep();
    80004024:	fcffd0ef          	jal	80001ff2 <sleep>
      acquire(&log.lock);
    80004028:	8526                	mv	a0,s1
    8000402a:	bfffc0ef          	jal	80000c28 <acquire>
    while (log.ncommit < n) {
    8000402e:	549c                	lw	a5,40(s1)
    80004030:	fef954e3          	bge	s2,a5,80004018 <sys_sync+0x3e>
    80004034:	64a2                	ld	s1,8(sp)
    80004036:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    80004038:	0001e517          	auipc	a0,0x1e
    8000403c:	41050513          	addi	a0,a0,1040 # 80022448 <log>
    80004040:	c71fc0ef          	jal	80000cb0 <release>
  return 0;
}
    80004044:	4501                	li	a0,0
    80004046:	60e2                	ld	ra,24(sp)
    80004048:	6442                	ld	s0,16(sp)
    8000404a:	6105                	addi	sp,sp,32
    8000404c:	8082                	ret

000000008000404e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000404e:	1101                	addi	sp,sp,-32
    80004050:	ec06                	sd	ra,24(sp)
    80004052:	e822                	sd	s0,16(sp)
    80004054:	e426                	sd	s1,8(sp)
    80004056:	e04a                	sd	s2,0(sp)
    80004058:	1000                	addi	s0,sp,32
    8000405a:	84aa                	mv	s1,a0
    8000405c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000405e:	00003597          	auipc	a1,0x3
    80004062:	50a58593          	addi	a1,a1,1290 # 80007568 <etext+0x568>
    80004066:	0521                	addi	a0,a0,8
    80004068:	b41fc0ef          	jal	80000ba8 <initlock>
  lk->name = name;
    8000406c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004070:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004074:	0204a423          	sw	zero,40(s1)
}
    80004078:	60e2                	ld	ra,24(sp)
    8000407a:	6442                	ld	s0,16(sp)
    8000407c:	64a2                	ld	s1,8(sp)
    8000407e:	6902                	ld	s2,0(sp)
    80004080:	6105                	addi	sp,sp,32
    80004082:	8082                	ret

0000000080004084 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004084:	1101                	addi	sp,sp,-32
    80004086:	ec06                	sd	ra,24(sp)
    80004088:	e822                	sd	s0,16(sp)
    8000408a:	e426                	sd	s1,8(sp)
    8000408c:	e04a                	sd	s2,0(sp)
    8000408e:	1000                	addi	s0,sp,32
    80004090:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004092:	00850913          	addi	s2,a0,8
    80004096:	854a                	mv	a0,s2
    80004098:	b91fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    8000409c:	409c                	lw	a5,0(s1)
    8000409e:	cf91                	beqz	a5,800040ba <acquiresleep+0x36>
    sleep_prepare(lk);
    800040a0:	8526                	mv	a0,s1
    800040a2:	f15fd0ef          	jal	80001fb6 <sleep_prepare>
    release(&lk->lk);
    800040a6:	854a                	mv	a0,s2
    800040a8:	c09fc0ef          	jal	80000cb0 <release>
    sleep();
    800040ac:	f47fd0ef          	jal	80001ff2 <sleep>
    acquire(&lk->lk);
    800040b0:	854a                	mv	a0,s2
    800040b2:	b77fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    800040b6:	409c                	lw	a5,0(s1)
    800040b8:	f7e5                	bnez	a5,800040a0 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800040ba:	4785                	li	a5,1
    800040bc:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800040be:	8effd0ef          	jal	800019ac <myproc>
    800040c2:	591c                	lw	a5,48(a0)
    800040c4:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800040c6:	854a                	mv	a0,s2
    800040c8:	be9fc0ef          	jal	80000cb0 <release>
}
    800040cc:	60e2                	ld	ra,24(sp)
    800040ce:	6442                	ld	s0,16(sp)
    800040d0:	64a2                	ld	s1,8(sp)
    800040d2:	6902                	ld	s2,0(sp)
    800040d4:	6105                	addi	sp,sp,32
    800040d6:	8082                	ret

00000000800040d8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800040d8:	1101                	addi	sp,sp,-32
    800040da:	ec06                	sd	ra,24(sp)
    800040dc:	e822                	sd	s0,16(sp)
    800040de:	e426                	sd	s1,8(sp)
    800040e0:	e04a                	sd	s2,0(sp)
    800040e2:	1000                	addi	s0,sp,32
    800040e4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800040e6:	00850913          	addi	s2,a0,8
    800040ea:	854a                	mv	a0,s2
    800040ec:	b3dfc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    800040f0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800040f4:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800040f8:	8526                	mv	a0,s1
    800040fa:	f29fd0ef          	jal	80002022 <wakeup>
  release(&lk->lk);
    800040fe:	854a                	mv	a0,s2
    80004100:	bb1fc0ef          	jal	80000cb0 <release>
}
    80004104:	60e2                	ld	ra,24(sp)
    80004106:	6442                	ld	s0,16(sp)
    80004108:	64a2                	ld	s1,8(sp)
    8000410a:	6902                	ld	s2,0(sp)
    8000410c:	6105                	addi	sp,sp,32
    8000410e:	8082                	ret

0000000080004110 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004110:	7179                	addi	sp,sp,-48
    80004112:	f406                	sd	ra,40(sp)
    80004114:	f022                	sd	s0,32(sp)
    80004116:	ec26                	sd	s1,24(sp)
    80004118:	e84a                	sd	s2,16(sp)
    8000411a:	1800                	addi	s0,sp,48
    8000411c:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    8000411e:	00850913          	addi	s2,a0,8
    80004122:	854a                	mv	a0,s2
    80004124:	b05fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004128:	409c                	lw	a5,0(s1)
    8000412a:	ef81                	bnez	a5,80004142 <holdingsleep+0x32>
    8000412c:	4481                	li	s1,0
  release(&lk->lk);
    8000412e:	854a                	mv	a0,s2
    80004130:	b81fc0ef          	jal	80000cb0 <release>
  return r;
}
    80004134:	8526                	mv	a0,s1
    80004136:	70a2                	ld	ra,40(sp)
    80004138:	7402                	ld	s0,32(sp)
    8000413a:	64e2                	ld	s1,24(sp)
    8000413c:	6942                	ld	s2,16(sp)
    8000413e:	6145                	addi	sp,sp,48
    80004140:	8082                	ret
    80004142:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004144:	0284a983          	lw	s3,40(s1)
    80004148:	865fd0ef          	jal	800019ac <myproc>
    8000414c:	5904                	lw	s1,48(a0)
    8000414e:	413484b3          	sub	s1,s1,s3
    80004152:	0014b493          	seqz	s1,s1
    80004156:	69a2                	ld	s3,8(sp)
    80004158:	bfd9                	j	8000412e <holdingsleep+0x1e>

000000008000415a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000415a:	1141                	addi	sp,sp,-16
    8000415c:	e406                	sd	ra,8(sp)
    8000415e:	e022                	sd	s0,0(sp)
    80004160:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004162:	00003597          	auipc	a1,0x3
    80004166:	41658593          	addi	a1,a1,1046 # 80007578 <etext+0x578>
    8000416a:	0001e517          	auipc	a0,0x1e
    8000416e:	42650513          	addi	a0,a0,1062 # 80022590 <ftable>
    80004172:	a37fc0ef          	jal	80000ba8 <initlock>
}
    80004176:	60a2                	ld	ra,8(sp)
    80004178:	6402                	ld	s0,0(sp)
    8000417a:	0141                	addi	sp,sp,16
    8000417c:	8082                	ret

000000008000417e <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    8000417e:	1101                	addi	sp,sp,-32
    80004180:	ec06                	sd	ra,24(sp)
    80004182:	e822                	sd	s0,16(sp)
    80004184:	e426                	sd	s1,8(sp)
    80004186:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004188:	0001e517          	auipc	a0,0x1e
    8000418c:	40850513          	addi	a0,a0,1032 # 80022590 <ftable>
    80004190:	a99fc0ef          	jal	80000c28 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004194:	0001e497          	auipc	s1,0x1e
    80004198:	41448493          	addi	s1,s1,1044 # 800225a8 <ftable+0x18>
    8000419c:	0001f717          	auipc	a4,0x1f
    800041a0:	3ac70713          	addi	a4,a4,940 # 80023548 <disk>
    if (f->ref == 0) {
    800041a4:	40dc                	lw	a5,4(s1)
    800041a6:	cf89                	beqz	a5,800041c0 <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    800041a8:	02848493          	addi	s1,s1,40
    800041ac:	fee49ce3          	bne	s1,a4,800041a4 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800041b0:	0001e517          	auipc	a0,0x1e
    800041b4:	3e050513          	addi	a0,a0,992 # 80022590 <ftable>
    800041b8:	af9fc0ef          	jal	80000cb0 <release>
  return 0;
    800041bc:	4481                	li	s1,0
    800041be:	a809                	j	800041d0 <filealloc+0x52>
      f->ref = 1;
    800041c0:	4785                	li	a5,1
    800041c2:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800041c4:	0001e517          	auipc	a0,0x1e
    800041c8:	3cc50513          	addi	a0,a0,972 # 80022590 <ftable>
    800041cc:	ae5fc0ef          	jal	80000cb0 <release>
}
    800041d0:	8526                	mv	a0,s1
    800041d2:	60e2                	ld	ra,24(sp)
    800041d4:	6442                	ld	s0,16(sp)
    800041d6:	64a2                	ld	s1,8(sp)
    800041d8:	6105                	addi	sp,sp,32
    800041da:	8082                	ret

00000000800041dc <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    800041dc:	1101                	addi	sp,sp,-32
    800041de:	ec06                	sd	ra,24(sp)
    800041e0:	e822                	sd	s0,16(sp)
    800041e2:	e426                	sd	s1,8(sp)
    800041e4:	1000                	addi	s0,sp,32
    800041e6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800041e8:	0001e517          	auipc	a0,0x1e
    800041ec:	3a850513          	addi	a0,a0,936 # 80022590 <ftable>
    800041f0:	a39fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    800041f4:	40dc                	lw	a5,4(s1)
    800041f6:	02f05063          	blez	a5,80004216 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800041fa:	2785                	addiw	a5,a5,1
    800041fc:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800041fe:	0001e517          	auipc	a0,0x1e
    80004202:	39250513          	addi	a0,a0,914 # 80022590 <ftable>
    80004206:	aabfc0ef          	jal	80000cb0 <release>
  return f;
}
    8000420a:	8526                	mv	a0,s1
    8000420c:	60e2                	ld	ra,24(sp)
    8000420e:	6442                	ld	s0,16(sp)
    80004210:	64a2                	ld	s1,8(sp)
    80004212:	6105                	addi	sp,sp,32
    80004214:	8082                	ret
    panic("filedup");
    80004216:	00003517          	auipc	a0,0x3
    8000421a:	36a50513          	addi	a0,a0,874 # 80007580 <etext+0x580>
    8000421e:	e16fc0ef          	jal	80000834 <panic>

0000000080004222 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004222:	7139                	addi	sp,sp,-64
    80004224:	fc06                	sd	ra,56(sp)
    80004226:	f822                	sd	s0,48(sp)
    80004228:	f426                	sd	s1,40(sp)
    8000422a:	0080                	addi	s0,sp,64
    8000422c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000422e:	0001e517          	auipc	a0,0x1e
    80004232:	36250513          	addi	a0,a0,866 # 80022590 <ftable>
    80004236:	9f3fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    8000423a:	40dc                	lw	a5,4(s1)
    8000423c:	04f05a63          	blez	a5,80004290 <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    80004240:	37fd                	addiw	a5,a5,-1
    80004242:	c0dc                	sw	a5,4(s1)
    80004244:	06f04063          	bgtz	a5,800042a4 <fileclose+0x82>
    80004248:	f04a                	sd	s2,32(sp)
    8000424a:	ec4e                	sd	s3,24(sp)
    8000424c:	e852                	sd	s4,16(sp)
    8000424e:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004250:	0004a903          	lw	s2,0(s1)
    80004254:	0094c783          	lbu	a5,9(s1)
    80004258:	89be                	mv	s3,a5
    8000425a:	689c                	ld	a5,16(s1)
    8000425c:	8a3e                	mv	s4,a5
    8000425e:	6c9c                	ld	a5,24(s1)
    80004260:	8abe                	mv	s5,a5
  f->ref = 0;
    80004262:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004266:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000426a:	0001e517          	auipc	a0,0x1e
    8000426e:	32650513          	addi	a0,a0,806 # 80022590 <ftable>
    80004272:	a3ffc0ef          	jal	80000cb0 <release>

  if (ff.type == FD_PIPE) {
    80004276:	4785                	li	a5,1
    80004278:	04f90163          	beq	s2,a5,800042ba <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    8000427c:	ffe9079b          	addiw	a5,s2,-2
    80004280:	4705                	li	a4,1
    80004282:	04f77563          	bgeu	a4,a5,800042cc <fileclose+0xaa>
    80004286:	7902                	ld	s2,32(sp)
    80004288:	69e2                	ld	s3,24(sp)
    8000428a:	6a42                	ld	s4,16(sp)
    8000428c:	6aa2                	ld	s5,8(sp)
    8000428e:	a00d                	j	800042b0 <fileclose+0x8e>
    80004290:	f04a                	sd	s2,32(sp)
    80004292:	ec4e                	sd	s3,24(sp)
    80004294:	e852                	sd	s4,16(sp)
    80004296:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004298:	00003517          	auipc	a0,0x3
    8000429c:	2f050513          	addi	a0,a0,752 # 80007588 <etext+0x588>
    800042a0:	d94fc0ef          	jal	80000834 <panic>
    release(&ftable.lock);
    800042a4:	0001e517          	auipc	a0,0x1e
    800042a8:	2ec50513          	addi	a0,a0,748 # 80022590 <ftable>
    800042ac:	a05fc0ef          	jal	80000cb0 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800042b0:	70e2                	ld	ra,56(sp)
    800042b2:	7442                	ld	s0,48(sp)
    800042b4:	74a2                	ld	s1,40(sp)
    800042b6:	6121                	addi	sp,sp,64
    800042b8:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800042ba:	85ce                	mv	a1,s3
    800042bc:	8552                	mv	a0,s4
    800042be:	36a000ef          	jal	80004628 <pipeclose>
    800042c2:	7902                	ld	s2,32(sp)
    800042c4:	69e2                	ld	s3,24(sp)
    800042c6:	6a42                	ld	s4,16(sp)
    800042c8:	6aa2                	ld	s5,8(sp)
    800042ca:	b7dd                	j	800042b0 <fileclose+0x8e>
    begin_op();
    800042cc:	a9dff0ef          	jal	80003d68 <begin_op>
    iput(ff.ip);
    800042d0:	8556                	mv	a0,s5
    800042d2:	9a0ff0ef          	jal	80003472 <iput>
    end_op();
    800042d6:	b1fff0ef          	jal	80003df4 <end_op>
    800042da:	7902                	ld	s2,32(sp)
    800042dc:	69e2                	ld	s3,24(sp)
    800042de:	6a42                	ld	s4,16(sp)
    800042e0:	6aa2                	ld	s5,8(sp)
    800042e2:	b7f9                	j	800042b0 <fileclose+0x8e>

00000000800042e4 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800042e4:	715d                	addi	sp,sp,-80
    800042e6:	e486                	sd	ra,72(sp)
    800042e8:	e0a2                	sd	s0,64(sp)
    800042ea:	fc26                	sd	s1,56(sp)
    800042ec:	f052                	sd	s4,32(sp)
    800042ee:	0880                	addi	s0,sp,80
    800042f0:	84aa                	mv	s1,a0
    800042f2:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    800042f4:	eb8fd0ef          	jal	800019ac <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    800042f8:	409c                	lw	a5,0(s1)
    800042fa:	37f9                	addiw	a5,a5,-2
    800042fc:	4705                	li	a4,1
    800042fe:	04f76963          	bltu	a4,a5,80004350 <filestat+0x6c>
    80004302:	f84a                	sd	s2,48(sp)
    80004304:	f44e                	sd	s3,40(sp)
    80004306:	892a                	mv	s2,a0
    memset(&st, 0, sizeof(st));
    80004308:	fb840993          	addi	s3,s0,-72
    8000430c:	4661                	li	a2,24
    8000430e:	4581                	li	a1,0
    80004310:	854e                	mv	a0,s3
    80004312:	9d7fc0ef          	jal	80000ce8 <memset>
    ilock(f->ip);
    80004316:	6c88                	ld	a0,24(s1)
    80004318:	fd9fe0ef          	jal	800032f0 <ilock>
    stati(f->ip, &st);
    8000431c:	85ce                	mv	a1,s3
    8000431e:	6c88                	ld	a0,24(s1)
    80004320:	b7cff0ef          	jal	8000369c <stati>
    iunlock(f->ip);
    80004324:	6c88                	ld	a0,24(s1)
    80004326:	878ff0ef          	jal	8000339e <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    8000432a:	4761                	li	a4,24
    8000432c:	86ce                	mv	a3,s3
    8000432e:	8652                	mv	a2,s4
    80004330:	04893583          	ld	a1,72(s2)
    80004334:	05093503          	ld	a0,80(s2)
    80004338:	a4afd0ef          	jal	80001582 <copyout>
    8000433c:	41f5551b          	sraiw	a0,a0,0x1f
    80004340:	7942                	ld	s2,48(sp)
    80004342:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004344:	60a6                	ld	ra,72(sp)
    80004346:	6406                	ld	s0,64(sp)
    80004348:	74e2                	ld	s1,56(sp)
    8000434a:	7a02                	ld	s4,32(sp)
    8000434c:	6161                	addi	sp,sp,80
    8000434e:	8082                	ret
  return -1;
    80004350:	557d                	li	a0,-1
    80004352:	bfcd                	j	80004344 <filestat+0x60>

0000000080004354 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004354:	7179                	addi	sp,sp,-48
    80004356:	f406                	sd	ra,40(sp)
    80004358:	f022                	sd	s0,32(sp)
    8000435a:	e84a                	sd	s2,16(sp)
    8000435c:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    8000435e:	00854783          	lbu	a5,8(a0)
    80004362:	c3dd                	beqz	a5,80004408 <fileread+0xb4>
    80004364:	ec26                	sd	s1,24(sp)
    80004366:	e44e                	sd	s3,8(sp)
    80004368:	84aa                	mv	s1,a0
    8000436a:	892e                	mv	s2,a1
    8000436c:	89b2                	mv	s3,a2
    8000436e:	01f6579b          	srliw	a5,a2,0x1f
    80004372:	ebc9                	bnez	a5,80004404 <fileread+0xb0>
    return -1;

  if (f->type == FD_PIPE) {
    80004374:	411c                	lw	a5,0(a0)
    80004376:	4705                	li	a4,1
    80004378:	04e78363          	beq	a5,a4,800043be <fileread+0x6a>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    8000437c:	470d                	li	a4,3
    8000437e:	04e78763          	beq	a5,a4,800043cc <fileread+0x78>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004382:	4709                	li	a4,2
    80004384:	06e79a63          	bne	a5,a4,800043f8 <fileread+0xa4>
    ilock(f->ip);
    80004388:	6d08                	ld	a0,24(a0)
    8000438a:	f67fe0ef          	jal	800032f0 <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000438e:	874e                	mv	a4,s3
    80004390:	5094                	lw	a3,32(s1)
    80004392:	864a                	mv	a2,s2
    80004394:	4585                	li	a1,1
    80004396:	6c88                	ld	a0,24(s1)
    80004398:	b32ff0ef          	jal	800036ca <readi>
    8000439c:	892a                	mv	s2,a0
    8000439e:	00a05563          	blez	a0,800043a8 <fileread+0x54>
      f->off += r;
    800043a2:	509c                	lw	a5,32(s1)
    800043a4:	9fa9                	addw	a5,a5,a0
    800043a6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800043a8:	6c88                	ld	a0,24(s1)
    800043aa:	ff5fe0ef          	jal	8000339e <iunlock>
    800043ae:	64e2                	ld	s1,24(sp)
    800043b0:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800043b2:	854a                	mv	a0,s2
    800043b4:	70a2                	ld	ra,40(sp)
    800043b6:	7402                	ld	s0,32(sp)
    800043b8:	6942                	ld	s2,16(sp)
    800043ba:	6145                	addi	sp,sp,48
    800043bc:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800043be:	6908                	ld	a0,16(a0)
    800043c0:	3e2000ef          	jal	800047a2 <piperead>
    800043c4:	892a                	mv	s2,a0
    800043c6:	64e2                	ld	s1,24(sp)
    800043c8:	69a2                	ld	s3,8(sp)
    800043ca:	b7e5                	j	800043b2 <fileread+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800043cc:	02451783          	lh	a5,36(a0)
    800043d0:	03079693          	slli	a3,a5,0x30
    800043d4:	92c1                	srli	a3,a3,0x30
    800043d6:	4725                	li	a4,9
    800043d8:	02d76b63          	bltu	a4,a3,8000440e <fileread+0xba>
    800043dc:	0792                	slli	a5,a5,0x4
    800043de:	0001e717          	auipc	a4,0x1e
    800043e2:	11270713          	addi	a4,a4,274 # 800224f0 <devsw>
    800043e6:	97ba                	add	a5,a5,a4
    800043e8:	639c                	ld	a5,0(a5)
    800043ea:	c79d                	beqz	a5,80004418 <fileread+0xc4>
    r = devsw[f->major].read(1, addr, n);
    800043ec:	4505                	li	a0,1
    800043ee:	9782                	jalr	a5
    800043f0:	892a                	mv	s2,a0
    800043f2:	64e2                	ld	s1,24(sp)
    800043f4:	69a2                	ld	s3,8(sp)
    800043f6:	bf75                	j	800043b2 <fileread+0x5e>
    panic("fileread");
    800043f8:	00003517          	auipc	a0,0x3
    800043fc:	1a050513          	addi	a0,a0,416 # 80007598 <etext+0x598>
    80004400:	c34fc0ef          	jal	80000834 <panic>
    80004404:	64e2                	ld	s1,24(sp)
    80004406:	69a2                	ld	s3,8(sp)
    return -1;
    80004408:	57fd                	li	a5,-1
    8000440a:	893e                	mv	s2,a5
    8000440c:	b75d                	j	800043b2 <fileread+0x5e>
      return -1;
    8000440e:	57fd                	li	a5,-1
    80004410:	893e                	mv	s2,a5
    80004412:	64e2                	ld	s1,24(sp)
    80004414:	69a2                	ld	s3,8(sp)
    80004416:	bf71                	j	800043b2 <fileread+0x5e>
    80004418:	57fd                	li	a5,-1
    8000441a:	893e                	mv	s2,a5
    8000441c:	64e2                	ld	s1,24(sp)
    8000441e:	69a2                	ld	s3,8(sp)
    80004420:	bf49                	j	800043b2 <fileread+0x5e>

0000000080004422 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    80004422:	00954783          	lbu	a5,9(a0)
    80004426:	12078b63          	beqz	a5,8000455c <filewrite+0x13a>
{
    8000442a:	711d                	addi	sp,sp,-96
    8000442c:	ec86                	sd	ra,88(sp)
    8000442e:	e8a2                	sd	s0,80(sp)
    80004430:	e0ca                	sd	s2,64(sp)
    80004432:	f456                	sd	s5,40(sp)
    80004434:	f05a                	sd	s6,32(sp)
    80004436:	1080                	addi	s0,sp,96
    80004438:	892a                	mv	s2,a0
    8000443a:	8b2e                	mv	s6,a1
    8000443c:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    8000443e:	01f6579b          	srliw	a5,a2,0x1f
    80004442:	0e079d63          	bnez	a5,8000453c <filewrite+0x11a>
    return -1;

  if (f->type == FD_PIPE) {
    80004446:	411c                	lw	a5,0(a0)
    80004448:	4705                	li	a4,1
    8000444a:	02e78a63          	beq	a5,a4,8000447e <filewrite+0x5c>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    8000444e:	470d                	li	a4,3
    80004450:	02e78b63          	beq	a5,a4,80004486 <filewrite+0x64>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004454:	4709                	li	a4,2
    80004456:	0ce79763          	bne	a5,a4,80004524 <filewrite+0x102>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    8000445a:	0ec05763          	blez	a2,80004548 <filewrite+0x126>
    8000445e:	e4a6                	sd	s1,72(sp)
    80004460:	fc4e                	sd	s3,56(sp)
    80004462:	f852                	sd	s4,48(sp)
    80004464:	ec5e                	sd	s7,24(sp)
    80004466:	e862                	sd	s8,16(sp)
    80004468:	e466                	sd	s9,8(sp)
    int i = 0;
    8000446a:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    8000446c:	6b85                	lui	s7,0x1
    8000446e:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004472:	6785                	lui	a5,0x1
    80004474:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004478:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000447a:	4c05                	li	s8,1
    8000447c:	a8ad                	j	800044f6 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    8000447e:	6908                	ld	a0,16(a0)
    80004480:	206000ef          	jal	80004686 <pipewrite>
    80004484:	a849                	j	80004516 <filewrite+0xf4>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004486:	02451783          	lh	a5,36(a0)
    8000448a:	03079693          	slli	a3,a5,0x30
    8000448e:	92c1                	srli	a3,a3,0x30
    80004490:	4725                	li	a4,9
    80004492:	0ad76763          	bltu	a4,a3,80004540 <filewrite+0x11e>
    80004496:	0792                	slli	a5,a5,0x4
    80004498:	0001e717          	auipc	a4,0x1e
    8000449c:	05870713          	addi	a4,a4,88 # 800224f0 <devsw>
    800044a0:	97ba                	add	a5,a5,a4
    800044a2:	679c                	ld	a5,8(a5)
    800044a4:	c3c5                	beqz	a5,80004544 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800044a6:	4505                	li	a0,1
    800044a8:	9782                	jalr	a5
    800044aa:	a0b5                	j	80004516 <filewrite+0xf4>
      if (n1 > max)
    800044ac:	2981                	sext.w	s3,s3
      begin_op();
    800044ae:	8bbff0ef          	jal	80003d68 <begin_op>
      ilock(f->ip);
    800044b2:	01893503          	ld	a0,24(s2)
    800044b6:	e3bfe0ef          	jal	800032f0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800044ba:	874e                	mv	a4,s3
    800044bc:	02092683          	lw	a3,32(s2)
    800044c0:	016a0633          	add	a2,s4,s6
    800044c4:	85e2                	mv	a1,s8
    800044c6:	01893503          	ld	a0,24(s2)
    800044ca:	af2ff0ef          	jal	800037bc <writei>
    800044ce:	84aa                	mv	s1,a0
    800044d0:	00a05763          	blez	a0,800044de <filewrite+0xbc>
        f->off += r;
    800044d4:	02092783          	lw	a5,32(s2)
    800044d8:	9fa9                	addw	a5,a5,a0
    800044da:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800044de:	01893503          	ld	a0,24(s2)
    800044e2:	ebdfe0ef          	jal	8000339e <iunlock>
      end_op();
    800044e6:	90fff0ef          	jal	80003df4 <end_op>

      if (r != n1) {
    800044ea:	00999d63          	bne	s3,s1,80004504 <filewrite+0xe2>
        // error from writei
        break;
      }
      i += r;
    800044ee:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    800044f2:	015a5963          	bge	s4,s5,80004504 <filewrite+0xe2>
      int n1 = n - i;
    800044f6:	414a87bb          	subw	a5,s5,s4
    800044fa:	89be                	mv	s3,a5
      if (n1 > max)
    800044fc:	fafbd8e3          	bge	s7,a5,800044ac <filewrite+0x8a>
    80004500:	89e6                	mv	s3,s9
    80004502:	b76d                	j	800044ac <filewrite+0x8a>
    }
    ret = (i == n ? n : -1);
    80004504:	054a9463          	bne	s5,s4,8000454c <filewrite+0x12a>
    80004508:	8556                	mv	a0,s5
    8000450a:	64a6                	ld	s1,72(sp)
    8000450c:	79e2                	ld	s3,56(sp)
    8000450e:	7a42                	ld	s4,48(sp)
    80004510:	6be2                	ld	s7,24(sp)
    80004512:	6c42                	ld	s8,16(sp)
    80004514:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004516:	60e6                	ld	ra,88(sp)
    80004518:	6446                	ld	s0,80(sp)
    8000451a:	6906                	ld	s2,64(sp)
    8000451c:	7aa2                	ld	s5,40(sp)
    8000451e:	7b02                	ld	s6,32(sp)
    80004520:	6125                	addi	sp,sp,96
    80004522:	8082                	ret
    80004524:	e4a6                	sd	s1,72(sp)
    80004526:	fc4e                	sd	s3,56(sp)
    80004528:	f852                	sd	s4,48(sp)
    8000452a:	ec5e                	sd	s7,24(sp)
    8000452c:	e862                	sd	s8,16(sp)
    8000452e:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004530:	00003517          	auipc	a0,0x3
    80004534:	07850513          	addi	a0,a0,120 # 800075a8 <etext+0x5a8>
    80004538:	afcfc0ef          	jal	80000834 <panic>
    return -1;
    8000453c:	557d                	li	a0,-1
    8000453e:	bfe1                	j	80004516 <filewrite+0xf4>
      return -1;
    80004540:	557d                	li	a0,-1
    80004542:	bfd1                	j	80004516 <filewrite+0xf4>
    80004544:	557d                	li	a0,-1
    80004546:	bfc1                	j	80004516 <filewrite+0xf4>
    ret = (i == n ? n : -1);
    80004548:	8532                	mv	a0,a2
    8000454a:	b7f1                	j	80004516 <filewrite+0xf4>
    8000454c:	557d                	li	a0,-1
    8000454e:	64a6                	ld	s1,72(sp)
    80004550:	79e2                	ld	s3,56(sp)
    80004552:	7a42                	ld	s4,48(sp)
    80004554:	6be2                	ld	s7,24(sp)
    80004556:	6c42                	ld	s8,16(sp)
    80004558:	6ca2                	ld	s9,8(sp)
    8000455a:	bf75                	j	80004516 <filewrite+0xf4>
    return -1;
    8000455c:	557d                	li	a0,-1
}
    8000455e:	8082                	ret

0000000080004560 <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004560:	7179                	addi	sp,sp,-48
    80004562:	f406                	sd	ra,40(sp)
    80004564:	f022                	sd	s0,32(sp)
    80004566:	ec26                	sd	s1,24(sp)
    80004568:	e052                	sd	s4,0(sp)
    8000456a:	1800                	addi	s0,sp,48
    8000456c:	84aa                	mv	s1,a0
    8000456e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004570:	0005b023          	sd	zero,0(a1)
    80004574:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004578:	c07ff0ef          	jal	8000417e <filealloc>
    8000457c:	e088                	sd	a0,0(s1)
    8000457e:	c549                	beqz	a0,80004608 <pipealloc+0xa8>
    80004580:	bffff0ef          	jal	8000417e <filealloc>
    80004584:	00aa3023          	sd	a0,0(s4)
    80004588:	cd25                	beqz	a0,80004600 <pipealloc+0xa0>
    8000458a:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    8000458c:	dc2fc0ef          	jal	80000b4e <kalloc>
    80004590:	892a                	mv	s2,a0
    80004592:	c12d                	beqz	a0,800045f4 <pipealloc+0x94>
    80004594:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004596:	4985                	li	s3,1
    80004598:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000459c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800045a0:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800045a4:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800045a8:	00003597          	auipc	a1,0x3
    800045ac:	01058593          	addi	a1,a1,16 # 800075b8 <etext+0x5b8>
    800045b0:	df8fc0ef          	jal	80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    800045b4:	609c                	ld	a5,0(s1)
    800045b6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800045ba:	609c                	ld	a5,0(s1)
    800045bc:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800045c0:	609c                	ld	a5,0(s1)
    800045c2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800045c6:	609c                	ld	a5,0(s1)
    800045c8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800045cc:	000a3783          	ld	a5,0(s4)
    800045d0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800045d4:	000a3783          	ld	a5,0(s4)
    800045d8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800045dc:	000a3783          	ld	a5,0(s4)
    800045e0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800045e4:	000a3783          	ld	a5,0(s4)
    800045e8:	0127b823          	sd	s2,16(a5)
  return 0;
    800045ec:	4501                	li	a0,0
    800045ee:	6942                	ld	s2,16(sp)
    800045f0:	69a2                	ld	s3,8(sp)
    800045f2:	a01d                	j	80004618 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    800045f4:	6088                	ld	a0,0(s1)
    800045f6:	c119                	beqz	a0,800045fc <pipealloc+0x9c>
    800045f8:	6942                	ld	s2,16(sp)
    800045fa:	a029                	j	80004604 <pipealloc+0xa4>
    800045fc:	6942                	ld	s2,16(sp)
    800045fe:	a029                	j	80004608 <pipealloc+0xa8>
    80004600:	6088                	ld	a0,0(s1)
    80004602:	c10d                	beqz	a0,80004624 <pipealloc+0xc4>
    fileclose(*f0);
    80004604:	c1fff0ef          	jal	80004222 <fileclose>
  if (*f1)
    80004608:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000460c:	557d                	li	a0,-1
  if (*f1)
    8000460e:	c789                	beqz	a5,80004618 <pipealloc+0xb8>
    fileclose(*f1);
    80004610:	853e                	mv	a0,a5
    80004612:	c11ff0ef          	jal	80004222 <fileclose>
  return -1;
    80004616:	557d                	li	a0,-1
}
    80004618:	70a2                	ld	ra,40(sp)
    8000461a:	7402                	ld	s0,32(sp)
    8000461c:	64e2                	ld	s1,24(sp)
    8000461e:	6a02                	ld	s4,0(sp)
    80004620:	6145                	addi	sp,sp,48
    80004622:	8082                	ret
  return -1;
    80004624:	557d                	li	a0,-1
    80004626:	bfcd                	j	80004618 <pipealloc+0xb8>

0000000080004628 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004628:	1101                	addi	sp,sp,-32
    8000462a:	ec06                	sd	ra,24(sp)
    8000462c:	e822                	sd	s0,16(sp)
    8000462e:	e426                	sd	s1,8(sp)
    80004630:	e04a                	sd	s2,0(sp)
    80004632:	1000                	addi	s0,sp,32
    80004634:	84aa                	mv	s1,a0
    80004636:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004638:	df0fc0ef          	jal	80000c28 <acquire>
  if (writable) {
    8000463c:	02090763          	beqz	s2,8000466a <pipeclose+0x42>
    pi->writeopen = 0;
    80004640:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004644:	21848513          	addi	a0,s1,536
    80004648:	9dbfd0ef          	jal	80002022 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    8000464c:	2204a783          	lw	a5,544(s1)
    80004650:	e781                	bnez	a5,80004658 <pipeclose+0x30>
    80004652:	2244a783          	lw	a5,548(s1)
    80004656:	c38d                	beqz	a5,80004678 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    80004658:	8526                	mv	a0,s1
    8000465a:	e56fc0ef          	jal	80000cb0 <release>
}
    8000465e:	60e2                	ld	ra,24(sp)
    80004660:	6442                	ld	s0,16(sp)
    80004662:	64a2                	ld	s1,8(sp)
    80004664:	6902                	ld	s2,0(sp)
    80004666:	6105                	addi	sp,sp,32
    80004668:	8082                	ret
    pi->readopen = 0;
    8000466a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000466e:	21c48513          	addi	a0,s1,540
    80004672:	9b1fd0ef          	jal	80002022 <wakeup>
    80004676:	bfd9                	j	8000464c <pipeclose+0x24>
    release(&pi->lock);
    80004678:	8526                	mv	a0,s1
    8000467a:	e36fc0ef          	jal	80000cb0 <release>
    kfree((char *)pi);
    8000467e:	8526                	mv	a0,s1
    80004680:	be6fc0ef          	jal	80000a66 <kfree>
    80004684:	bfe9                	j	8000465e <pipeclose+0x36>

0000000080004686 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004686:	7159                	addi	sp,sp,-112
    80004688:	f486                	sd	ra,104(sp)
    8000468a:	f0a2                	sd	s0,96(sp)
    8000468c:	eca6                	sd	s1,88(sp)
    8000468e:	e8ca                	sd	s2,80(sp)
    80004690:	e4ce                	sd	s3,72(sp)
    80004692:	e0d2                	sd	s4,64(sp)
    80004694:	fc56                	sd	s5,56(sp)
    80004696:	1880                	addi	s0,sp,112
    80004698:	84aa                	mv	s1,a0
    8000469a:	8aae                	mv	s5,a1
    8000469c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000469e:	b0efd0ef          	jal	800019ac <myproc>
    800046a2:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800046a4:	8526                	mv	a0,s1
    800046a6:	d82fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    800046aa:	0f405a63          	blez	s4,8000479e <pipewrite+0x118>
    800046ae:	f85a                	sd	s6,48(sp)
    800046b0:	f45e                	sd	s7,40(sp)
    800046b2:	f062                	sd	s8,32(sp)
    800046b4:	ec66                	sd	s9,24(sp)
    800046b6:	e86a                	sd	s10,16(sp)
  int i = 0;
    800046b8:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    800046ba:	f9f40c13          	addi	s8,s0,-97
    800046be:	4b85                	li	s7,1
    800046c0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800046c2:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    800046c6:	21c48c93          	addi	s9,s1,540
    800046ca:	a0a1                	j	80004712 <pipewrite+0x8c>
      release(&pi->lock);
    800046cc:	8526                	mv	a0,s1
    800046ce:	de2fc0ef          	jal	80000cb0 <release>
      return -1;
    800046d2:	597d                	li	s2,-1
    800046d4:	7b42                	ld	s6,48(sp)
    800046d6:	7ba2                	ld	s7,40(sp)
    800046d8:	7c02                	ld	s8,32(sp)
    800046da:	6ce2                	ld	s9,24(sp)
    800046dc:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800046de:	854a                	mv	a0,s2
    800046e0:	70a6                	ld	ra,104(sp)
    800046e2:	7406                	ld	s0,96(sp)
    800046e4:	64e6                	ld	s1,88(sp)
    800046e6:	6946                	ld	s2,80(sp)
    800046e8:	69a6                	ld	s3,72(sp)
    800046ea:	6a06                	ld	s4,64(sp)
    800046ec:	7ae2                	ld	s5,56(sp)
    800046ee:	6165                	addi	sp,sp,112
    800046f0:	8082                	ret
      wakeup(&pi->nread);
    800046f2:	856a                	mv	a0,s10
    800046f4:	92ffd0ef          	jal	80002022 <wakeup>
      sleep_prepare(&pi->nwrite);
    800046f8:	8566                	mv	a0,s9
    800046fa:	8bdfd0ef          	jal	80001fb6 <sleep_prepare>
      release(&pi->lock);
    800046fe:	8526                	mv	a0,s1
    80004700:	db0fc0ef          	jal	80000cb0 <release>
      sleep();
    80004704:	8effd0ef          	jal	80001ff2 <sleep>
      acquire(&pi->lock);
    80004708:	8526                	mv	a0,s1
    8000470a:	d1efc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    8000470e:	07495b63          	bge	s2,s4,80004784 <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    80004712:	2204a783          	lw	a5,544(s1)
    80004716:	dbdd                	beqz	a5,800046cc <pipewrite+0x46>
    80004718:	854e                	mv	a0,s3
    8000471a:	afbfd0ef          	jal	80002214 <killed>
    8000471e:	f55d                	bnez	a0,800046cc <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    80004720:	2184a783          	lw	a5,536(s1)
    80004724:	21c4a703          	lw	a4,540(s1)
    80004728:	2007879b          	addiw	a5,a5,512
    8000472c:	fcf703e3          	beq	a4,a5,800046f2 <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004730:	875e                	mv	a4,s7
    80004732:	015906b3          	add	a3,s2,s5
    80004736:	8662                	mv	a2,s8
    80004738:	0489b583          	ld	a1,72(s3)
    8000473c:	0509b503          	ld	a0,80(s3)
    80004740:	f09fc0ef          	jal	80001648 <copyin>
    80004744:	03650163          	beq	a0,s6,80004766 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004748:	21c4a783          	lw	a5,540(s1)
    8000474c:	0017871b          	addiw	a4,a5,1
    80004750:	20e4ae23          	sw	a4,540(s1)
    80004754:	1ff7f793          	andi	a5,a5,511
    80004758:	97a6                	add	a5,a5,s1
    8000475a:	f9f44703          	lbu	a4,-97(s0)
    8000475e:	00e78c23          	sb	a4,24(a5)
      i++;
    80004762:	2905                	addiw	s2,s2,1
    80004764:	b76d                	j	8000470e <pipewrite+0x88>
        if (i == 0)
    80004766:	00090863          	beqz	s2,80004776 <pipewrite+0xf0>
    8000476a:	7b42                	ld	s6,48(sp)
    8000476c:	7ba2                	ld	s7,40(sp)
    8000476e:	7c02                	ld	s8,32(sp)
    80004770:	6ce2                	ld	s9,24(sp)
    80004772:	6d42                	ld	s10,16(sp)
    80004774:	a829                	j	8000478e <pipewrite+0x108>
          i = -1;
    80004776:	892a                	mv	s2,a0
        break;
    80004778:	7b42                	ld	s6,48(sp)
    8000477a:	7ba2                	ld	s7,40(sp)
    8000477c:	7c02                	ld	s8,32(sp)
    8000477e:	6ce2                	ld	s9,24(sp)
    80004780:	6d42                	ld	s10,16(sp)
    80004782:	a031                	j	8000478e <pipewrite+0x108>
    80004784:	7b42                	ld	s6,48(sp)
    80004786:	7ba2                	ld	s7,40(sp)
    80004788:	7c02                	ld	s8,32(sp)
    8000478a:	6ce2                	ld	s9,24(sp)
    8000478c:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    8000478e:	21848513          	addi	a0,s1,536
    80004792:	891fd0ef          	jal	80002022 <wakeup>
  release(&pi->lock);
    80004796:	8526                	mv	a0,s1
    80004798:	d18fc0ef          	jal	80000cb0 <release>
  return i;
    8000479c:	b789                	j	800046de <pipewrite+0x58>
  int i = 0;
    8000479e:	4901                	li	s2,0
    800047a0:	b7fd                	j	8000478e <pipewrite+0x108>

00000000800047a2 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800047a2:	711d                	addi	sp,sp,-96
    800047a4:	ec86                	sd	ra,88(sp)
    800047a6:	e8a2                	sd	s0,80(sp)
    800047a8:	e4a6                	sd	s1,72(sp)
    800047aa:	e0ca                	sd	s2,64(sp)
    800047ac:	fc4e                	sd	s3,56(sp)
    800047ae:	f852                	sd	s4,48(sp)
    800047b0:	f456                	sd	s5,40(sp)
    800047b2:	1080                	addi	s0,sp,96
    800047b4:	84aa                	mv	s1,a0
    800047b6:	89ae                	mv	s3,a1
    800047b8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800047ba:	9f2fd0ef          	jal	800019ac <myproc>
    800047be:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    800047c0:	8526                	mv	a0,s1
    800047c2:	c66fc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800047c6:	0d505263          	blez	s5,8000488a <piperead+0xe8>
    800047ca:	2184a703          	lw	a4,536(s1)
    800047ce:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    800047d2:	21848a13          	addi	s4,s1,536
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800047d6:	02f71e63          	bne	a4,a5,80004812 <piperead+0x70>
    800047da:	2244a783          	lw	a5,548(s1)
    800047de:	c3b9                	beqz	a5,80004824 <piperead+0x82>
    if (killed(pr)) {
    800047e0:	854a                	mv	a0,s2
    800047e2:	a33fd0ef          	jal	80002214 <killed>
    800047e6:	e915                	bnez	a0,8000481a <piperead+0x78>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    800047e8:	8552                	mv	a0,s4
    800047ea:	fccfd0ef          	jal	80001fb6 <sleep_prepare>
    release(&pi->lock);
    800047ee:	8526                	mv	a0,s1
    800047f0:	cc0fc0ef          	jal	80000cb0 <release>
    sleep();
    800047f4:	ffefd0ef          	jal	80001ff2 <sleep>
    acquire(&pi->lock);
    800047f8:	8526                	mv	a0,s1
    800047fa:	c2efc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800047fe:	2184a703          	lw	a4,536(s1)
    80004802:	21c4a783          	lw	a5,540(s1)
    80004806:	fcf70ae3          	beq	a4,a5,800047da <piperead+0x38>
    8000480a:	f05a                	sd	s6,32(sp)
    8000480c:	ec5e                	sd	s7,24(sp)
    8000480e:	e862                	sd	s8,16(sp)
    80004810:	a829                	j	8000482a <piperead+0x88>
    80004812:	f05a                	sd	s6,32(sp)
    80004814:	ec5e                	sd	s7,24(sp)
    80004816:	e862                	sd	s8,16(sp)
    80004818:	a809                	j	8000482a <piperead+0x88>
      release(&pi->lock);
    8000481a:	8526                	mv	a0,s1
    8000481c:	c94fc0ef          	jal	80000cb0 <release>
      return -1;
    80004820:	5a7d                	li	s4,-1
    80004822:	a8a5                	j	8000489a <piperead+0xf8>
    80004824:	f05a                	sd	s6,32(sp)
    80004826:	ec5e                	sd	s7,24(sp)
    80004828:	e862                	sd	s8,16(sp)
{
    8000482a:	4a01                	li	s4,0
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    8000482c:	faf40c13          	addi	s8,s0,-81
    80004830:	4b85                	li	s7,1
    80004832:	5b7d                	li	s6,-1
    if (pi->nread == pi->nwrite)
    80004834:	2184a783          	lw	a5,536(s1)
    80004838:	21c4a703          	lw	a4,540(s1)
    8000483c:	06f70e63          	beq	a4,a5,800048b8 <piperead+0x116>
    ch = pi->data[pi->nread % PIPESIZE];
    80004840:	1ff7f793          	andi	a5,a5,511
    80004844:	97a6                	add	a5,a5,s1
    80004846:	0187c783          	lbu	a5,24(a5)
    8000484a:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    8000484e:	875e                	mv	a4,s7
    80004850:	86e2                	mv	a3,s8
    80004852:	864e                	mv	a2,s3
    80004854:	04893583          	ld	a1,72(s2)
    80004858:	05093503          	ld	a0,80(s2)
    8000485c:	d27fc0ef          	jal	80001582 <copyout>
    80004860:	01650f63          	beq	a0,s6,8000487e <piperead+0xdc>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004864:	2184a783          	lw	a5,536(s1)
    80004868:	2785                	addiw	a5,a5,1
    8000486a:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    8000486e:	2a05                	addiw	s4,s4,1
    80004870:	0985                	addi	s3,s3,1
    80004872:	fd4a91e3          	bne	s5,s4,80004834 <piperead+0x92>
    80004876:	7b02                	ld	s6,32(sp)
    80004878:	6be2                	ld	s7,24(sp)
    8000487a:	6c42                	ld	s8,16(sp)
    8000487c:	a801                	j	8000488c <piperead+0xea>
      if (i == 0)
    8000487e:	020a0863          	beqz	s4,800048ae <piperead+0x10c>
    80004882:	7b02                	ld	s6,32(sp)
    80004884:	6be2                	ld	s7,24(sp)
    80004886:	6c42                	ld	s8,16(sp)
    80004888:	a011                	j	8000488c <piperead+0xea>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    8000488a:	4a01                	li	s4,0
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    8000488c:	21c48513          	addi	a0,s1,540
    80004890:	f92fd0ef          	jal	80002022 <wakeup>
  release(&pi->lock);
    80004894:	8526                	mv	a0,s1
    80004896:	c1afc0ef          	jal	80000cb0 <release>
  return i;
}
    8000489a:	8552                	mv	a0,s4
    8000489c:	60e6                	ld	ra,88(sp)
    8000489e:	6446                	ld	s0,80(sp)
    800048a0:	64a6                	ld	s1,72(sp)
    800048a2:	6906                	ld	s2,64(sp)
    800048a4:	79e2                	ld	s3,56(sp)
    800048a6:	7a42                	ld	s4,48(sp)
    800048a8:	7aa2                	ld	s5,40(sp)
    800048aa:	6125                	addi	sp,sp,96
    800048ac:	8082                	ret
        i = -1;
    800048ae:	8a2a                	mv	s4,a0
    800048b0:	7b02                	ld	s6,32(sp)
    800048b2:	6be2                	ld	s7,24(sp)
    800048b4:	6c42                	ld	s8,16(sp)
    800048b6:	bfd9                	j	8000488c <piperead+0xea>
    800048b8:	7b02                	ld	s6,32(sp)
    800048ba:	6be2                	ld	s7,24(sp)
    800048bc:	6c42                	ld	s8,16(sp)
    800048be:	b7f9                	j	8000488c <piperead+0xea>

00000000800048c0 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    800048c0:	1141                	addi	sp,sp,-16
    800048c2:	e406                	sd	ra,8(sp)
    800048c4:	e022                	sd	s0,0(sp)
    800048c6:	0800                	addi	s0,sp,16
    800048c8:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    800048ca:	0035151b          	slliw	a0,a0,0x3
    800048ce:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    800048d0:	8b89                	andi	a5,a5,2
    800048d2:	c399                	beqz	a5,800048d8 <flags2perm+0x18>
    perm |= PTE_W;
    800048d4:	00456513          	ori	a0,a0,4
  return perm;
}
    800048d8:	60a2                	ld	ra,8(sp)
    800048da:	6402                	ld	s0,0(sp)
    800048dc:	0141                	addi	sp,sp,16
    800048de:	8082                	ret

00000000800048e0 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800048e0:	de010113          	addi	sp,sp,-544
    800048e4:	20113c23          	sd	ra,536(sp)
    800048e8:	20813823          	sd	s0,528(sp)
    800048ec:	20913423          	sd	s1,520(sp)
    800048f0:	21213023          	sd	s2,512(sp)
    800048f4:	1400                	addi	s0,sp,544
    800048f6:	892a                	mv	s2,a0
    800048f8:	dea43823          	sd	a0,-528(s0)
    800048fc:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004900:	8acfd0ef          	jal	800019ac <myproc>
    80004904:	84aa                	mv	s1,a0

  begin_op();
    80004906:	c62ff0ef          	jal	80003d68 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    8000490a:	854a                	mv	a0,s2
    8000490c:	a7eff0ef          	jal	80003b8a <namei>
    80004910:	cd21                	beqz	a0,80004968 <kexec+0x88>
    80004912:	fbd2                	sd	s4,496(sp)
    80004914:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004916:	9dbfe0ef          	jal	800032f0 <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000491a:	04000713          	li	a4,64
    8000491e:	4681                	li	a3,0
    80004920:	e5040613          	addi	a2,s0,-432
    80004924:	4581                	li	a1,0
    80004926:	8552                	mv	a0,s4
    80004928:	da3fe0ef          	jal	800036ca <readi>
    8000492c:	04000793          	li	a5,64
    80004930:	00f51a63          	bne	a0,a5,80004944 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004934:	e5042703          	lw	a4,-432(s0)
    80004938:	464c47b7          	lui	a5,0x464c4
    8000493c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004940:	02f70863          	beq	a4,a5,80004970 <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    80004944:	8552                	mv	a0,s4
    80004946:	bfffe0ef          	jal	80003544 <iunlockput>
    end_op();
    8000494a:	caaff0ef          	jal	80003df4 <end_op>
  }
  return -1;
    8000494e:	557d                	li	a0,-1
    80004950:	7a5e                	ld	s4,496(sp)
}
    80004952:	21813083          	ld	ra,536(sp)
    80004956:	21013403          	ld	s0,528(sp)
    8000495a:	20813483          	ld	s1,520(sp)
    8000495e:	20013903          	ld	s2,512(sp)
    80004962:	22010113          	addi	sp,sp,544
    80004966:	8082                	ret
    end_op();
    80004968:	c8cff0ef          	jal	80003df4 <end_op>
    return -1;
    8000496c:	557d                	li	a0,-1
    8000496e:	b7d5                	j	80004952 <kexec+0x72>
    80004970:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004972:	8526                	mv	a0,s1
    80004974:	93efd0ef          	jal	80001ab2 <proc_pagetable>
    80004978:	8b2a                	mv	s6,a0
    8000497a:	26050e63          	beqz	a0,80004bf6 <kexec+0x316>
    8000497e:	ffce                	sd	s3,504(sp)
    80004980:	f7d6                	sd	s5,488(sp)
    80004982:	efde                	sd	s7,472(sp)
    80004984:	ebe2                	sd	s8,464(sp)
    80004986:	e7e6                	sd	s9,456(sp)
    80004988:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    8000498a:	e8845783          	lhu	a5,-376(s0)
    8000498e:	14078263          	beqz	a5,80004ad2 <kexec+0x1f2>
    80004992:	ff6e                	sd	s11,440(sp)
    80004994:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004998:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    8000499a:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000499c:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    800049a0:	6c85                	lui	s9,0x1
    800049a2:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800049a6:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    800049aa:	6a85                	lui	s5,0x1
    800049ac:	a085                	j	80004a0c <kexec+0x12c>
      panic("loadseg: address should exist");
    800049ae:	00003517          	auipc	a0,0x3
    800049b2:	c1250513          	addi	a0,a0,-1006 # 800075c0 <etext+0x5c0>
    800049b6:	e7ffb0ef          	jal	80000834 <panic>
    if (sz - i < PGSIZE)
    800049ba:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    800049bc:	874a                	mv	a4,s2
    800049be:	009b86bb          	addw	a3,s7,s1
    800049c2:	4581                	li	a1,0
    800049c4:	8552                	mv	a0,s4
    800049c6:	d05fe0ef          	jal	800036ca <readi>
    800049ca:	22a91a63          	bne	s2,a0,80004bfe <kexec+0x31e>
  for (i = 0; i < sz; i += PGSIZE) {
    800049ce:	009a84bb          	addw	s1,s5,s1
    800049d2:	0334f263          	bgeu	s1,s3,800049f6 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    800049d6:	02049593          	slli	a1,s1,0x20
    800049da:	9181                	srli	a1,a1,0x20
    800049dc:	95e2                	add	a1,a1,s8
    800049de:	855a                	mv	a0,s6
    800049e0:	e38fc0ef          	jal	80001018 <walkaddr>
    800049e4:	862a                	mv	a2,a0
    if (pa == 0)
    800049e6:	d561                	beqz	a0,800049ae <kexec+0xce>
    if (sz - i < PGSIZE)
    800049e8:	409987bb          	subw	a5,s3,s1
    800049ec:	893e                	mv	s2,a5
    800049ee:	fcfcf6e3          	bgeu	s9,a5,800049ba <kexec+0xda>
    800049f2:	8956                	mv	s2,s5
    800049f4:	b7d9                	j	800049ba <kexec+0xda>
    sz = sz1;
    800049f6:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    800049fa:	2d05                	addiw	s10,s10,1
    800049fc:	e0843783          	ld	a5,-504(s0)
    80004a00:	0387869b          	addiw	a3,a5,56
    80004a04:	e8845783          	lhu	a5,-376(s0)
    80004a08:	06fd5d63          	bge	s10,a5,80004a82 <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a0c:	e0d43423          	sd	a3,-504(s0)
    80004a10:	876e                	mv	a4,s11
    80004a12:	e1840613          	addi	a2,s0,-488
    80004a16:	4581                	li	a1,0
    80004a18:	8552                	mv	a0,s4
    80004a1a:	cb1fe0ef          	jal	800036ca <readi>
    80004a1e:	1db51e63          	bne	a0,s11,80004bfa <kexec+0x31a>
    if (ph.type != ELF_PROG_LOAD)
    80004a22:	e1842783          	lw	a5,-488(s0)
    80004a26:	4705                	li	a4,1
    80004a28:	fce799e3          	bne	a5,a4,800049fa <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    80004a2c:	e4043483          	ld	s1,-448(s0)
    80004a30:	e3843783          	ld	a5,-456(s0)
    80004a34:	1ef4e363          	bltu	s1,a5,80004c1a <kexec+0x33a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004a38:	e2843783          	ld	a5,-472(s0)
    80004a3c:	94be                	add	s1,s1,a5
    80004a3e:	1ef4e163          	bltu	s1,a5,80004c20 <kexec+0x340>
    if (ph.vaddr % PGSIZE != 0)
    80004a42:	de843703          	ld	a4,-536(s0)
    80004a46:	8ff9                	and	a5,a5,a4
    80004a48:	1c079f63          	bnez	a5,80004c26 <kexec+0x346>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004a4c:	e1c42503          	lw	a0,-484(s0)
    80004a50:	e71ff0ef          	jal	800048c0 <flags2perm>
    80004a54:	86aa                	mv	a3,a0
    80004a56:	8626                	mv	a2,s1
    80004a58:	85ca                	mv	a1,s2
    80004a5a:	855a                	mv	a0,s6
    80004a5c:	893fc0ef          	jal	800012ee <uvmalloc>
    80004a60:	dea43c23          	sd	a0,-520(s0)
    80004a64:	1c050463          	beqz	a0,80004c2c <kexec+0x34c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004a68:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004a6c:	00098863          	beqz	s3,80004a7c <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004a70:	e2843c03          	ld	s8,-472(s0)
    80004a74:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004a78:	4481                	li	s1,0
    80004a7a:	bfb1                	j	800049d6 <kexec+0xf6>
    sz = sz1;
    80004a7c:	df843903          	ld	s2,-520(s0)
    80004a80:	bfad                	j	800049fa <kexec+0x11a>
    80004a82:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    80004a84:	8552                	mv	a0,s4
    80004a86:	abffe0ef          	jal	80003544 <iunlockput>
  end_op();
    80004a8a:	b6aff0ef          	jal	80003df4 <end_op>
  p = myproc();
    80004a8e:	f1ffc0ef          	jal	800019ac <myproc>
    80004a92:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004a94:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    80004a98:	6c05                	lui	s8,0x1
    80004a9a:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    80004a9c:	9c4a                	add	s8,s8,s2
    80004a9e:	77fd                	lui	a5,0xfffff
    80004aa0:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004aa4:	4691                	li	a3,4
    80004aa6:	6609                	lui	a2,0x2
    80004aa8:	9662                	add	a2,a2,s8
    80004aaa:	85e2                	mv	a1,s8
    80004aac:	855a                	mv	a0,s6
    80004aae:	841fc0ef          	jal	800012ee <uvmalloc>
    80004ab2:	892a                	mv	s2,a0
    80004ab4:	e10d                	bnez	a0,80004ad6 <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    80004ab6:	85e2                	mv	a1,s8
    80004ab8:	855a                	mv	a0,s6
    80004aba:	87cfd0ef          	jal	80001b36 <proc_freepagetable>
  return -1;
    80004abe:	557d                	li	a0,-1
    80004ac0:	79fe                	ld	s3,504(sp)
    80004ac2:	7a5e                	ld	s4,496(sp)
    80004ac4:	7abe                	ld	s5,488(sp)
    80004ac6:	7b1e                	ld	s6,480(sp)
    80004ac8:	6bfe                	ld	s7,472(sp)
    80004aca:	6c5e                	ld	s8,464(sp)
    80004acc:	6cbe                	ld	s9,456(sp)
    80004ace:	6d1e                	ld	s10,448(sp)
    80004ad0:	b549                	j	80004952 <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ad2:	4901                	li	s2,0
    80004ad4:	bf45                	j	80004a84 <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004ad6:	75f9                	lui	a1,0xffffe
    80004ad8:	95aa                	add	a1,a1,a0
    80004ada:	855a                	mv	a0,s6
    80004adc:	9e5fc0ef          	jal	800014c0 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004ae0:	80090a13          	addi	s4,s2,-2048
    80004ae4:	800a0a13          	addi	s4,s4,-2048
  for (argc = 0; argv[argc]; argc++) {
    80004ae8:	e0043783          	ld	a5,-512(s0)
    80004aec:	6388                	ld	a0,0(a5)
    80004aee:	c545                	beqz	a0,80004b96 <kexec+0x2b6>
  sp = sz;
    80004af0:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004af2:	4481                	li	s1,0
    ustack[argc] = sp;
    80004af4:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004af8:	b7afc0ef          	jal	80000e72 <strlen>
    80004afc:	0015079b          	addiw	a5,a0,1
    80004b00:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004b04:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004b08:	134c6563          	bltu	s8,s4,80004c32 <kexec+0x352>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004b0c:	e0043d03          	ld	s10,-512(s0)
    80004b10:	000d3c83          	ld	s9,0(s10)
    80004b14:	8566                	mv	a0,s9
    80004b16:	b5cfc0ef          	jal	80000e72 <strlen>
    80004b1a:	0015071b          	addiw	a4,a0,1
    80004b1e:	86e6                	mv	a3,s9
    80004b20:	8662                	mv	a2,s8
    80004b22:	85ca                	mv	a1,s2
    80004b24:	855a                	mv	a0,s6
    80004b26:	a5dfc0ef          	jal	80001582 <copyout>
    80004b2a:	10054663          	bltz	a0,80004c36 <kexec+0x356>
    ustack[argc] = sp;
    80004b2e:	00349793          	slli	a5,s1,0x3
    80004b32:	97de                	add	a5,a5,s7
    80004b34:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb978>
  for (argc = 0; argv[argc]; argc++) {
    80004b38:	0485                	addi	s1,s1,1
    80004b3a:	008d0793          	addi	a5,s10,8
    80004b3e:	e0f43023          	sd	a5,-512(s0)
    80004b42:	008d3503          	ld	a0,8(s10)
    80004b46:	f94d                	bnez	a0,80004af8 <kexec+0x218>
  ustack[argc] = 0;
    80004b48:	00349793          	slli	a5,s1,0x3
    80004b4c:	f9078793          	addi	a5,a5,-112
    80004b50:	97a2                	add	a5,a5,s0
    80004b52:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004b56:	00349713          	slli	a4,s1,0x3
    80004b5a:	0721                	addi	a4,a4,8
    80004b5c:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004b60:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004b64:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004b66:	f54be8e3          	bltu	s7,s4,80004ab6 <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004b6a:	e9040693          	addi	a3,s0,-368
    80004b6e:	865e                	mv	a2,s7
    80004b70:	85ca                	mv	a1,s2
    80004b72:	855a                	mv	a0,s6
    80004b74:	a0ffc0ef          	jal	80001582 <copyout>
    80004b78:	f2054fe3          	bltz	a0,80004ab6 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004b7c:	0589b783          	ld	a5,88(s3)
    80004b80:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004b84:	df043783          	ld	a5,-528(s0)
    80004b88:	0007c703          	lbu	a4,0(a5)
    80004b8c:	c30d                	beqz	a4,80004bae <kexec+0x2ce>
    80004b8e:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004b90:	02f00693          	li	a3,47
    80004b94:	a801                	j	80004ba4 <kexec+0x2c4>
  sp = sz;
    80004b96:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004b98:	4481                	li	s1,0
    80004b9a:	b77d                	j	80004b48 <kexec+0x268>
  for (last = s = path; *s; s++)
    80004b9c:	0785                	addi	a5,a5,1
    80004b9e:	fff7c703          	lbu	a4,-1(a5)
    80004ba2:	c711                	beqz	a4,80004bae <kexec+0x2ce>
    if (*s == '/')
    80004ba4:	fed71ce3          	bne	a4,a3,80004b9c <kexec+0x2bc>
      last = s + 1;
    80004ba8:	def43823          	sd	a5,-528(s0)
    80004bac:	bfc5                	j	80004b9c <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004bae:	4641                	li	a2,16
    80004bb0:	df043583          	ld	a1,-528(s0)
    80004bb4:	15898513          	addi	a0,s3,344
    80004bb8:	a84fc0ef          	jal	80000e3c <safestrcpy>
  oldpagetable = p->pagetable;
    80004bbc:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004bc0:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004bc4:	0529b423          	sd	s2,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004bc8:	0589b783          	ld	a5,88(s3)
    80004bcc:	e6843703          	ld	a4,-408(s0)
    80004bd0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004bd2:	0589b783          	ld	a5,88(s3)
    80004bd6:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004bda:	85d6                	mv	a1,s5
    80004bdc:	f5bfc0ef          	jal	80001b36 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004be0:	0004851b          	sext.w	a0,s1
    80004be4:	79fe                	ld	s3,504(sp)
    80004be6:	7a5e                	ld	s4,496(sp)
    80004be8:	7abe                	ld	s5,488(sp)
    80004bea:	7b1e                	ld	s6,480(sp)
    80004bec:	6bfe                	ld	s7,472(sp)
    80004bee:	6c5e                	ld	s8,464(sp)
    80004bf0:	6cbe                	ld	s9,456(sp)
    80004bf2:	6d1e                	ld	s10,448(sp)
    80004bf4:	bbb9                	j	80004952 <kexec+0x72>
    80004bf6:	7b1e                	ld	s6,480(sp)
    80004bf8:	b3b1                	j	80004944 <kexec+0x64>
    80004bfa:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004bfe:	df843583          	ld	a1,-520(s0)
    80004c02:	855a                	mv	a0,s6
    80004c04:	f33fc0ef          	jal	80001b36 <proc_freepagetable>
  if (ip) {
    80004c08:	79fe                	ld	s3,504(sp)
    80004c0a:	7abe                	ld	s5,488(sp)
    80004c0c:	7b1e                	ld	s6,480(sp)
    80004c0e:	6bfe                	ld	s7,472(sp)
    80004c10:	6c5e                	ld	s8,464(sp)
    80004c12:	6cbe                	ld	s9,456(sp)
    80004c14:	6d1e                	ld	s10,448(sp)
    80004c16:	7dfa                	ld	s11,440(sp)
    80004c18:	b335                	j	80004944 <kexec+0x64>
    80004c1a:	df243c23          	sd	s2,-520(s0)
    80004c1e:	b7c5                	j	80004bfe <kexec+0x31e>
    80004c20:	df243c23          	sd	s2,-520(s0)
    80004c24:	bfe9                	j	80004bfe <kexec+0x31e>
    80004c26:	df243c23          	sd	s2,-520(s0)
    80004c2a:	bfd1                	j	80004bfe <kexec+0x31e>
    80004c2c:	df243c23          	sd	s2,-520(s0)
    80004c30:	b7f9                	j	80004bfe <kexec+0x31e>
  sz = sz1;
    80004c32:	8c4a                	mv	s8,s2
    80004c34:	b549                	j	80004ab6 <kexec+0x1d6>
    80004c36:	8c4a                	mv	s8,s2
    80004c38:	bdbd                	j	80004ab6 <kexec+0x1d6>

0000000080004c3a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004c3a:	7179                	addi	sp,sp,-48
    80004c3c:	f406                	sd	ra,40(sp)
    80004c3e:	f022                	sd	s0,32(sp)
    80004c40:	ec26                	sd	s1,24(sp)
    80004c42:	e84a                	sd	s2,16(sp)
    80004c44:	1800                	addi	s0,sp,48
    80004c46:	892e                	mv	s2,a1
    80004c48:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004c4a:	fdc40593          	addi	a1,s0,-36
    80004c4e:	ca7fd0ef          	jal	800028f4 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004c52:	fdc42703          	lw	a4,-36(s0)
    80004c56:	47bd                	li	a5,15
    80004c58:	02e7ea63          	bltu	a5,a4,80004c8c <argfd+0x52>
    80004c5c:	d51fc0ef          	jal	800019ac <myproc>
    80004c60:	fdc42703          	lw	a4,-36(s0)
    80004c64:	00371793          	slli	a5,a4,0x3
    80004c68:	0d078793          	addi	a5,a5,208
    80004c6c:	953e                	add	a0,a0,a5
    80004c6e:	611c                	ld	a5,0(a0)
    80004c70:	c385                	beqz	a5,80004c90 <argfd+0x56>
    return -1;
  if (pfd)
    80004c72:	00090463          	beqz	s2,80004c7a <argfd+0x40>
    *pfd = fd;
    80004c76:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004c7a:	4501                	li	a0,0
  if (pf)
    80004c7c:	c091                	beqz	s1,80004c80 <argfd+0x46>
    *pf = f;
    80004c7e:	e09c                	sd	a5,0(s1)
}
    80004c80:	70a2                	ld	ra,40(sp)
    80004c82:	7402                	ld	s0,32(sp)
    80004c84:	64e2                	ld	s1,24(sp)
    80004c86:	6942                	ld	s2,16(sp)
    80004c88:	6145                	addi	sp,sp,48
    80004c8a:	8082                	ret
    return -1;
    80004c8c:	557d                	li	a0,-1
    80004c8e:	bfcd                	j	80004c80 <argfd+0x46>
    80004c90:	557d                	li	a0,-1
    80004c92:	b7fd                	j	80004c80 <argfd+0x46>

0000000080004c94 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004c94:	1101                	addi	sp,sp,-32
    80004c96:	ec06                	sd	ra,24(sp)
    80004c98:	e822                	sd	s0,16(sp)
    80004c9a:	e426                	sd	s1,8(sp)
    80004c9c:	1000                	addi	s0,sp,32
    80004c9e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004ca0:	d0dfc0ef          	jal	800019ac <myproc>
    80004ca4:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004ca6:	0d050793          	addi	a5,a0,208
    80004caa:	4501                	li	a0,0
    80004cac:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004cae:	6398                	ld	a4,0(a5)
    80004cb0:	cb19                	beqz	a4,80004cc6 <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004cb2:	2505                	addiw	a0,a0,1
    80004cb4:	07a1                	addi	a5,a5,8
    80004cb6:	fed51ce3          	bne	a0,a3,80004cae <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004cba:	557d                	li	a0,-1
}
    80004cbc:	60e2                	ld	ra,24(sp)
    80004cbe:	6442                	ld	s0,16(sp)
    80004cc0:	64a2                	ld	s1,8(sp)
    80004cc2:	6105                	addi	sp,sp,32
    80004cc4:	8082                	ret
      p->ofile[fd] = f;
    80004cc6:	00351793          	slli	a5,a0,0x3
    80004cca:	0d078793          	addi	a5,a5,208
    80004cce:	963e                	add	a2,a2,a5
    80004cd0:	e204                	sd	s1,0(a2)
      return fd;
    80004cd2:	b7ed                	j	80004cbc <fdalloc+0x28>

0000000080004cd4 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004cd4:	715d                	addi	sp,sp,-80
    80004cd6:	e486                	sd	ra,72(sp)
    80004cd8:	e0a2                	sd	s0,64(sp)
    80004cda:	fc26                	sd	s1,56(sp)
    80004cdc:	f84a                	sd	s2,48(sp)
    80004cde:	f052                	sd	s4,32(sp)
    80004ce0:	ec56                	sd	s5,24(sp)
    80004ce2:	e85a                	sd	s6,16(sp)
    80004ce4:	0880                	addi	s0,sp,80
    80004ce6:	8a2e                	mv	s4,a1
    80004ce8:	8ab2                	mv	s5,a2
    80004cea:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004cec:	fb040593          	addi	a1,s0,-80
    80004cf0:	eb5fe0ef          	jal	80003ba4 <nameiparent>
    80004cf4:	84aa                	mv	s1,a0
    80004cf6:	12050f63          	beqz	a0,80004e34 <create+0x160>
    return 0;

  ilock(dp);
    80004cfa:	df6fe0ef          	jal	800032f0 <ilock>

  if (dp->nlink == 0) {
    80004cfe:	04a49783          	lh	a5,74(s1)
    80004d02:	cbb9                	beqz	a5,80004d58 <create+0x84>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004d04:	7761                	lui	a4,0xffff8
    80004d06:	0705                	addi	a4,a4,1 # ffffffffffff8001 <end+0xffffffff7ffd4979>
    80004d08:	97ba                	add	a5,a5,a4
    80004d0a:	e781                	bnez	a5,80004d12 <create+0x3e>
    80004d0c:	fffa0793          	addi	a5,s4,-1
    80004d10:	cba9                	beqz	a5,80004d62 <create+0x8e>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004d12:	4601                	li	a2,0
    80004d14:	fb040593          	addi	a1,s0,-80
    80004d18:	8526                	mv	a0,s1
    80004d1a:	bbffe0ef          	jal	800038d8 <dirlookup>
    80004d1e:	892a                	mv	s2,a0
    80004d20:	c939                	beqz	a0,80004d76 <create+0xa2>
    iunlockput(dp);
    80004d22:	8526                	mv	a0,s1
    80004d24:	821fe0ef          	jal	80003544 <iunlockput>
    ilock(ip);
    80004d28:	854a                	mv	a0,s2
    80004d2a:	dc6fe0ef          	jal	800032f0 <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004d2e:	4789                	li	a5,2
    80004d30:	02fa1e63          	bne	s4,a5,80004d6c <create+0x98>
    80004d34:	04495783          	lhu	a5,68(s2)
    80004d38:	37f9                	addiw	a5,a5,-2
    80004d3a:	17c2                	slli	a5,a5,0x30
    80004d3c:	93c1                	srli	a5,a5,0x30
    80004d3e:	4705                	li	a4,1
    80004d40:	02f76663          	bltu	a4,a5,80004d6c <create+0x98>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004d44:	854a                	mv	a0,s2
    80004d46:	60a6                	ld	ra,72(sp)
    80004d48:	6406                	ld	s0,64(sp)
    80004d4a:	74e2                	ld	s1,56(sp)
    80004d4c:	7942                	ld	s2,48(sp)
    80004d4e:	7a02                	ld	s4,32(sp)
    80004d50:	6ae2                	ld	s5,24(sp)
    80004d52:	6b42                	ld	s6,16(sp)
    80004d54:	6161                	addi	sp,sp,80
    80004d56:	8082                	ret
    iunlockput(dp);
    80004d58:	8526                	mv	a0,s1
    80004d5a:	feafe0ef          	jal	80003544 <iunlockput>
    return 0;
    80004d5e:	4901                	li	s2,0
    80004d60:	b7d5                	j	80004d44 <create+0x70>
    iunlockput(dp);
    80004d62:	8526                	mv	a0,s1
    80004d64:	fe0fe0ef          	jal	80003544 <iunlockput>
    return 0;
    80004d68:	4901                	li	s2,0
    80004d6a:	bfe9                	j	80004d44 <create+0x70>
    iunlockput(ip);
    80004d6c:	854a                	mv	a0,s2
    80004d6e:	fd6fe0ef          	jal	80003544 <iunlockput>
    return 0;
    80004d72:	4901                	li	s2,0
    80004d74:	bfc1                	j	80004d44 <create+0x70>
    80004d76:	f44e                	sd	s3,40(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004d78:	85d2                	mv	a1,s4
    80004d7a:	4088                	lw	a0,0(s1)
    80004d7c:	c04fe0ef          	jal	80003180 <ialloc>
    80004d80:	89aa                	mv	s3,a0
    80004d82:	cd1d                	beqz	a0,80004dc0 <create+0xec>
  ilock(ip);
    80004d84:	d6cfe0ef          	jal	800032f0 <ilock>
  ip->major = major;
    80004d88:	05599323          	sh	s5,70(s3)
  ip->minor = minor;
    80004d8c:	05699423          	sh	s6,72(s3)
  ip->nlink = 1;
    80004d90:	4705                	li	a4,1
    80004d92:	04e99523          	sh	a4,74(s3)
  iupdate(ip);
    80004d96:	854e                	mv	a0,s3
    80004d98:	ca4fe0ef          	jal	8000323c <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80004d9c:	4705                	li	a4,1
    80004d9e:	02ea0763          	beq	s4,a4,80004dcc <create+0xf8>
  if (dirlink(dp, name, ip->inum) < 0)
    80004da2:	0049a603          	lw	a2,4(s3)
    80004da6:	fb040593          	addi	a1,s0,-80
    80004daa:	8526                	mv	a0,s1
    80004dac:	d35fe0ef          	jal	80003ae0 <dirlink>
    80004db0:	06054563          	bltz	a0,80004e1a <create+0x146>
  iunlockput(dp);
    80004db4:	8526                	mv	a0,s1
    80004db6:	f8efe0ef          	jal	80003544 <iunlockput>
  return ip;
    80004dba:	894e                	mv	s2,s3
    80004dbc:	79a2                	ld	s3,40(sp)
    80004dbe:	b759                	j	80004d44 <create+0x70>
    iunlockput(dp);
    80004dc0:	8526                	mv	a0,s1
    80004dc2:	f82fe0ef          	jal	80003544 <iunlockput>
    return 0;
    80004dc6:	894e                	mv	s2,s3
    80004dc8:	79a2                	ld	s3,40(sp)
    80004dca:	bfad                	j	80004d44 <create+0x70>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004dcc:	0049a603          	lw	a2,4(s3)
    80004dd0:	00003597          	auipc	a1,0x3
    80004dd4:	81058593          	addi	a1,a1,-2032 # 800075e0 <etext+0x5e0>
    80004dd8:	854e                	mv	a0,s3
    80004dda:	d07fe0ef          	jal	80003ae0 <dirlink>
    80004dde:	02054e63          	bltz	a0,80004e1a <create+0x146>
    80004de2:	40d0                	lw	a2,4(s1)
    80004de4:	00003597          	auipc	a1,0x3
    80004de8:	80458593          	addi	a1,a1,-2044 # 800075e8 <etext+0x5e8>
    80004dec:	854e                	mv	a0,s3
    80004dee:	cf3fe0ef          	jal	80003ae0 <dirlink>
    80004df2:	02054463          	bltz	a0,80004e1a <create+0x146>
  if (dirlink(dp, name, ip->inum) < 0)
    80004df6:	0049a603          	lw	a2,4(s3)
    80004dfa:	fb040593          	addi	a1,s0,-80
    80004dfe:	8526                	mv	a0,s1
    80004e00:	ce1fe0ef          	jal	80003ae0 <dirlink>
    80004e04:	00054b63          	bltz	a0,80004e1a <create+0x146>
    dp->nlink++; // for ".."
    80004e08:	04a4d783          	lhu	a5,74(s1)
    80004e0c:	2785                	addiw	a5,a5,1
    80004e0e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004e12:	8526                	mv	a0,s1
    80004e14:	c28fe0ef          	jal	8000323c <iupdate>
    80004e18:	bf71                	j	80004db4 <create+0xe0>
  ip->nlink = 0;
    80004e1a:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    80004e1e:	854e                	mv	a0,s3
    80004e20:	c1cfe0ef          	jal	8000323c <iupdate>
  iunlockput(ip);
    80004e24:	854e                	mv	a0,s3
    80004e26:	f1efe0ef          	jal	80003544 <iunlockput>
  iunlockput(dp);
    80004e2a:	8526                	mv	a0,s1
    80004e2c:	f18fe0ef          	jal	80003544 <iunlockput>
  return 0;
    80004e30:	79a2                	ld	s3,40(sp)
    80004e32:	bf09                	j	80004d44 <create+0x70>
    return 0;
    80004e34:	892a                	mv	s2,a0
    80004e36:	b739                	j	80004d44 <create+0x70>

0000000080004e38 <sys_dup>:
{
    80004e38:	7179                	addi	sp,sp,-48
    80004e3a:	f406                	sd	ra,40(sp)
    80004e3c:	f022                	sd	s0,32(sp)
    80004e3e:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004e40:	fd840613          	addi	a2,s0,-40
    80004e44:	4581                	li	a1,0
    80004e46:	4501                	li	a0,0
    80004e48:	df3ff0ef          	jal	80004c3a <argfd>
    return -1;
    80004e4c:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004e4e:	02054363          	bltz	a0,80004e74 <sys_dup+0x3c>
    80004e52:	ec26                	sd	s1,24(sp)
    80004e54:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004e56:	fd843483          	ld	s1,-40(s0)
    80004e5a:	8526                	mv	a0,s1
    80004e5c:	e39ff0ef          	jal	80004c94 <fdalloc>
    80004e60:	892a                	mv	s2,a0
    return -1;
    80004e62:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004e64:	00054d63          	bltz	a0,80004e7e <sys_dup+0x46>
  filedup(f);
    80004e68:	8526                	mv	a0,s1
    80004e6a:	b72ff0ef          	jal	800041dc <filedup>
  return fd;
    80004e6e:	87ca                	mv	a5,s2
    80004e70:	64e2                	ld	s1,24(sp)
    80004e72:	6942                	ld	s2,16(sp)
}
    80004e74:	853e                	mv	a0,a5
    80004e76:	70a2                	ld	ra,40(sp)
    80004e78:	7402                	ld	s0,32(sp)
    80004e7a:	6145                	addi	sp,sp,48
    80004e7c:	8082                	ret
    80004e7e:	64e2                	ld	s1,24(sp)
    80004e80:	6942                	ld	s2,16(sp)
    80004e82:	bfcd                	j	80004e74 <sys_dup+0x3c>

0000000080004e84 <sys_read>:
{
    80004e84:	7179                	addi	sp,sp,-48
    80004e86:	f406                	sd	ra,40(sp)
    80004e88:	f022                	sd	s0,32(sp)
    80004e8a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e8c:	fd840593          	addi	a1,s0,-40
    80004e90:	4505                	li	a0,1
    80004e92:	a7ffd0ef          	jal	80002910 <argaddr>
  argint(2, &n);
    80004e96:	fe440593          	addi	a1,s0,-28
    80004e9a:	4509                	li	a0,2
    80004e9c:	a59fd0ef          	jal	800028f4 <argint>
  if (argfd(0, 0, &f) < 0)
    80004ea0:	fe840613          	addi	a2,s0,-24
    80004ea4:	4581                	li	a1,0
    80004ea6:	4501                	li	a0,0
    80004ea8:	d93ff0ef          	jal	80004c3a <argfd>
    80004eac:	87aa                	mv	a5,a0
    return -1;
    80004eae:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004eb0:	0007ca63          	bltz	a5,80004ec4 <sys_read+0x40>
  return fileread(f, p, n);
    80004eb4:	fe442603          	lw	a2,-28(s0)
    80004eb8:	fd843583          	ld	a1,-40(s0)
    80004ebc:	fe843503          	ld	a0,-24(s0)
    80004ec0:	c94ff0ef          	jal	80004354 <fileread>
}
    80004ec4:	70a2                	ld	ra,40(sp)
    80004ec6:	7402                	ld	s0,32(sp)
    80004ec8:	6145                	addi	sp,sp,48
    80004eca:	8082                	ret

0000000080004ecc <sys_write>:
{
    80004ecc:	7179                	addi	sp,sp,-48
    80004ece:	f406                	sd	ra,40(sp)
    80004ed0:	f022                	sd	s0,32(sp)
    80004ed2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004ed4:	fd840593          	addi	a1,s0,-40
    80004ed8:	4505                	li	a0,1
    80004eda:	a37fd0ef          	jal	80002910 <argaddr>
  argint(2, &n);
    80004ede:	fe440593          	addi	a1,s0,-28
    80004ee2:	4509                	li	a0,2
    80004ee4:	a11fd0ef          	jal	800028f4 <argint>
  if (argfd(0, 0, &f) < 0)
    80004ee8:	fe840613          	addi	a2,s0,-24
    80004eec:	4581                	li	a1,0
    80004eee:	4501                	li	a0,0
    80004ef0:	d4bff0ef          	jal	80004c3a <argfd>
    80004ef4:	87aa                	mv	a5,a0
    return -1;
    80004ef6:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004ef8:	0007ca63          	bltz	a5,80004f0c <sys_write+0x40>
  return filewrite(f, p, n);
    80004efc:	fe442603          	lw	a2,-28(s0)
    80004f00:	fd843583          	ld	a1,-40(s0)
    80004f04:	fe843503          	ld	a0,-24(s0)
    80004f08:	d1aff0ef          	jal	80004422 <filewrite>
}
    80004f0c:	70a2                	ld	ra,40(sp)
    80004f0e:	7402                	ld	s0,32(sp)
    80004f10:	6145                	addi	sp,sp,48
    80004f12:	8082                	ret

0000000080004f14 <sys_close>:
{
    80004f14:	1101                	addi	sp,sp,-32
    80004f16:	ec06                	sd	ra,24(sp)
    80004f18:	e822                	sd	s0,16(sp)
    80004f1a:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80004f1c:	fe040613          	addi	a2,s0,-32
    80004f20:	fec40593          	addi	a1,s0,-20
    80004f24:	4501                	li	a0,0
    80004f26:	d15ff0ef          	jal	80004c3a <argfd>
    return -1;
    80004f2a:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80004f2c:	02054163          	bltz	a0,80004f4e <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004f30:	a7dfc0ef          	jal	800019ac <myproc>
    80004f34:	fec42783          	lw	a5,-20(s0)
    80004f38:	078e                	slli	a5,a5,0x3
    80004f3a:	0d078793          	addi	a5,a5,208
    80004f3e:	953e                	add	a0,a0,a5
    80004f40:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004f44:	fe043503          	ld	a0,-32(s0)
    80004f48:	adaff0ef          	jal	80004222 <fileclose>
  return 0;
    80004f4c:	4781                	li	a5,0
}
    80004f4e:	853e                	mv	a0,a5
    80004f50:	60e2                	ld	ra,24(sp)
    80004f52:	6442                	ld	s0,16(sp)
    80004f54:	6105                	addi	sp,sp,32
    80004f56:	8082                	ret

0000000080004f58 <sys_fstat>:
{
    80004f58:	1101                	addi	sp,sp,-32
    80004f5a:	ec06                	sd	ra,24(sp)
    80004f5c:	e822                	sd	s0,16(sp)
    80004f5e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004f60:	fe040593          	addi	a1,s0,-32
    80004f64:	4505                	li	a0,1
    80004f66:	9abfd0ef          	jal	80002910 <argaddr>
  if (argfd(0, 0, &f) < 0)
    80004f6a:	fe840613          	addi	a2,s0,-24
    80004f6e:	4581                	li	a1,0
    80004f70:	4501                	li	a0,0
    80004f72:	cc9ff0ef          	jal	80004c3a <argfd>
    80004f76:	87aa                	mv	a5,a0
    return -1;
    80004f78:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004f7a:	0007c863          	bltz	a5,80004f8a <sys_fstat+0x32>
  return filestat(f, st);
    80004f7e:	fe043583          	ld	a1,-32(s0)
    80004f82:	fe843503          	ld	a0,-24(s0)
    80004f86:	b5eff0ef          	jal	800042e4 <filestat>
}
    80004f8a:	60e2                	ld	ra,24(sp)
    80004f8c:	6442                	ld	s0,16(sp)
    80004f8e:	6105                	addi	sp,sp,32
    80004f90:	8082                	ret

0000000080004f92 <sys_link>:
{
    80004f92:	7169                	addi	sp,sp,-304
    80004f94:	f606                	sd	ra,296(sp)
    80004f96:	f222                	sd	s0,288(sp)
    80004f98:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f9a:	08000613          	li	a2,128
    80004f9e:	ed040593          	addi	a1,s0,-304
    80004fa2:	4501                	li	a0,0
    80004fa4:	989fd0ef          	jal	8000292c <argstr>
    return -1;
    80004fa8:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004faa:	10054163          	bltz	a0,800050ac <sys_link+0x11a>
    80004fae:	08000613          	li	a2,128
    80004fb2:	f5040593          	addi	a1,s0,-176
    80004fb6:	4505                	li	a0,1
    80004fb8:	975fd0ef          	jal	8000292c <argstr>
    return -1;
    80004fbc:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004fbe:	0e054763          	bltz	a0,800050ac <sys_link+0x11a>
    80004fc2:	ee26                	sd	s1,280(sp)
  begin_op();
    80004fc4:	da5fe0ef          	jal	80003d68 <begin_op>
  if ((ip = namei(old)) == 0) {
    80004fc8:	ed040513          	addi	a0,s0,-304
    80004fcc:	bbffe0ef          	jal	80003b8a <namei>
    80004fd0:	84aa                	mv	s1,a0
    80004fd2:	cd35                	beqz	a0,8000504e <sys_link+0xbc>
  ilock(ip);
    80004fd4:	b1cfe0ef          	jal	800032f0 <ilock>
  if (ip->type == T_DIR) {
    80004fd8:	04449703          	lh	a4,68(s1)
    80004fdc:	4785                	li	a5,1
    80004fde:	06f70d63          	beq	a4,a5,80005058 <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    80004fe2:	04a49783          	lh	a5,74(s1)
    80004fe6:	6721                	lui	a4,0x8
    80004fe8:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80004fea:	06e78f63          	beq	a5,a4,80005068 <sys_link+0xd6>
    80004fee:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004ff0:	2785                	addiw	a5,a5,1
    80004ff2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004ff6:	8526                	mv	a0,s1
    80004ff8:	a44fe0ef          	jal	8000323c <iupdate>
  iunlock(ip);
    80004ffc:	8526                	mv	a0,s1
    80004ffe:	ba0fe0ef          	jal	8000339e <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80005002:	fd040593          	addi	a1,s0,-48
    80005006:	f5040513          	addi	a0,s0,-176
    8000500a:	b9bfe0ef          	jal	80003ba4 <nameiparent>
    8000500e:	892a                	mv	s2,a0
    80005010:	c93d                	beqz	a0,80005086 <sys_link+0xf4>
  ilock(dp);
    80005012:	adefe0ef          	jal	800032f0 <ilock>
  if (dp->nlink == 0) {
    80005016:	04a91783          	lh	a5,74(s2)
    8000501a:	cfb9                	beqz	a5,80005078 <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    8000501c:	854a                	mv	a0,s2
    8000501e:	00092703          	lw	a4,0(s2)
    80005022:	409c                	lw	a5,0(s1)
    80005024:	04f71e63          	bne	a4,a5,80005080 <sys_link+0xee>
    80005028:	40d0                	lw	a2,4(s1)
    8000502a:	fd040593          	addi	a1,s0,-48
    8000502e:	ab3fe0ef          	jal	80003ae0 <dirlink>
    80005032:	04054763          	bltz	a0,80005080 <sys_link+0xee>
  iunlockput(dp);
    80005036:	854a                	mv	a0,s2
    80005038:	d0cfe0ef          	jal	80003544 <iunlockput>
  iput(ip);
    8000503c:	8526                	mv	a0,s1
    8000503e:	c34fe0ef          	jal	80003472 <iput>
  end_op();
    80005042:	db3fe0ef          	jal	80003df4 <end_op>
  return 0;
    80005046:	4781                	li	a5,0
    80005048:	64f2                	ld	s1,280(sp)
    8000504a:	6952                	ld	s2,272(sp)
    8000504c:	a085                	j	800050ac <sys_link+0x11a>
    end_op();
    8000504e:	da7fe0ef          	jal	80003df4 <end_op>
    return -1;
    80005052:	57fd                	li	a5,-1
    80005054:	64f2                	ld	s1,280(sp)
    80005056:	a899                	j	800050ac <sys_link+0x11a>
    iunlockput(ip);
    80005058:	8526                	mv	a0,s1
    8000505a:	ceafe0ef          	jal	80003544 <iunlockput>
    end_op();
    8000505e:	d97fe0ef          	jal	80003df4 <end_op>
    return -1;
    80005062:	57fd                	li	a5,-1
    80005064:	64f2                	ld	s1,280(sp)
    80005066:	a099                	j	800050ac <sys_link+0x11a>
    iunlockput(ip);
    80005068:	8526                	mv	a0,s1
    8000506a:	cdafe0ef          	jal	80003544 <iunlockput>
    end_op();
    8000506e:	d87fe0ef          	jal	80003df4 <end_op>
    return -1;
    80005072:	57fd                	li	a5,-1
    80005074:	64f2                	ld	s1,280(sp)
    80005076:	a81d                	j	800050ac <sys_link+0x11a>
    iunlockput(dp);
    80005078:	854a                	mv	a0,s2
    8000507a:	ccafe0ef          	jal	80003544 <iunlockput>
    goto bad;
    8000507e:	a021                	j	80005086 <sys_link+0xf4>
    iunlockput(dp);
    80005080:	854a                	mv	a0,s2
    80005082:	cc2fe0ef          	jal	80003544 <iunlockput>
  ilock(ip);
    80005086:	8526                	mv	a0,s1
    80005088:	a68fe0ef          	jal	800032f0 <ilock>
  ip->nlink--;
    8000508c:	04a4d783          	lhu	a5,74(s1)
    80005090:	37fd                	addiw	a5,a5,-1
    80005092:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005096:	8526                	mv	a0,s1
    80005098:	9a4fe0ef          	jal	8000323c <iupdate>
  iunlockput(ip);
    8000509c:	8526                	mv	a0,s1
    8000509e:	ca6fe0ef          	jal	80003544 <iunlockput>
  end_op();
    800050a2:	d53fe0ef          	jal	80003df4 <end_op>
  return -1;
    800050a6:	57fd                	li	a5,-1
    800050a8:	64f2                	ld	s1,280(sp)
    800050aa:	6952                	ld	s2,272(sp)
}
    800050ac:	853e                	mv	a0,a5
    800050ae:	70b2                	ld	ra,296(sp)
    800050b0:	7412                	ld	s0,288(sp)
    800050b2:	6155                	addi	sp,sp,304
    800050b4:	8082                	ret

00000000800050b6 <sys_unlink>:
{
    800050b6:	7151                	addi	sp,sp,-240
    800050b8:	f586                	sd	ra,232(sp)
    800050ba:	f1a2                	sd	s0,224(sp)
    800050bc:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    800050be:	08000613          	li	a2,128
    800050c2:	f3040593          	addi	a1,s0,-208
    800050c6:	4501                	li	a0,0
    800050c8:	865fd0ef          	jal	8000292c <argstr>
    800050cc:	14054d63          	bltz	a0,80005226 <sys_unlink+0x170>
    800050d0:	eda6                	sd	s1,216(sp)
  begin_op();
    800050d2:	c97fe0ef          	jal	80003d68 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    800050d6:	fb040593          	addi	a1,s0,-80
    800050da:	f3040513          	addi	a0,s0,-208
    800050de:	ac7fe0ef          	jal	80003ba4 <nameiparent>
    800050e2:	84aa                	mv	s1,a0
    800050e4:	c955                	beqz	a0,80005198 <sys_unlink+0xe2>
  ilock(dp);
    800050e6:	a0afe0ef          	jal	800032f0 <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800050ea:	00002597          	auipc	a1,0x2
    800050ee:	4f658593          	addi	a1,a1,1270 # 800075e0 <etext+0x5e0>
    800050f2:	fb040513          	addi	a0,s0,-80
    800050f6:	fccfe0ef          	jal	800038c2 <namecmp>
    800050fa:	10050b63          	beqz	a0,80005210 <sys_unlink+0x15a>
    800050fe:	00002597          	auipc	a1,0x2
    80005102:	4ea58593          	addi	a1,a1,1258 # 800075e8 <etext+0x5e8>
    80005106:	fb040513          	addi	a0,s0,-80
    8000510a:	fb8fe0ef          	jal	800038c2 <namecmp>
    8000510e:	10050163          	beqz	a0,80005210 <sys_unlink+0x15a>
    80005112:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    80005114:	f2c40613          	addi	a2,s0,-212
    80005118:	fb040593          	addi	a1,s0,-80
    8000511c:	8526                	mv	a0,s1
    8000511e:	fbafe0ef          	jal	800038d8 <dirlookup>
    80005122:	892a                	mv	s2,a0
    80005124:	0e050563          	beqz	a0,8000520e <sys_unlink+0x158>
    80005128:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    8000512a:	9c6fe0ef          	jal	800032f0 <ilock>
  if (ip->nlink < 1)
    8000512e:	04a91783          	lh	a5,74(s2)
    80005132:	06f05863          	blez	a5,800051a2 <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    80005136:	04491703          	lh	a4,68(s2)
    8000513a:	4785                	li	a5,1
    8000513c:	06f70963          	beq	a4,a5,800051ae <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005140:	fc040993          	addi	s3,s0,-64
    80005144:	4641                	li	a2,16
    80005146:	4581                	li	a1,0
    80005148:	854e                	mv	a0,s3
    8000514a:	b9ffb0ef          	jal	80000ce8 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000514e:	4741                	li	a4,16
    80005150:	f2c42683          	lw	a3,-212(s0)
    80005154:	864e                	mv	a2,s3
    80005156:	4581                	li	a1,0
    80005158:	8526                	mv	a0,s1
    8000515a:	e62fe0ef          	jal	800037bc <writei>
    8000515e:	47c1                	li	a5,16
    80005160:	08f51863          	bne	a0,a5,800051f0 <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    80005164:	04491703          	lh	a4,68(s2)
    80005168:	4785                	li	a5,1
    8000516a:	08f70963          	beq	a4,a5,800051fc <sys_unlink+0x146>
  iunlockput(dp);
    8000516e:	8526                	mv	a0,s1
    80005170:	bd4fe0ef          	jal	80003544 <iunlockput>
  ip->nlink--;
    80005174:	04a95783          	lhu	a5,74(s2)
    80005178:	37fd                	addiw	a5,a5,-1
    8000517a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000517e:	854a                	mv	a0,s2
    80005180:	8bcfe0ef          	jal	8000323c <iupdate>
  iunlockput(ip);
    80005184:	854a                	mv	a0,s2
    80005186:	bbefe0ef          	jal	80003544 <iunlockput>
  end_op();
    8000518a:	c6bfe0ef          	jal	80003df4 <end_op>
  return 0;
    8000518e:	4501                	li	a0,0
    80005190:	64ee                	ld	s1,216(sp)
    80005192:	694e                	ld	s2,208(sp)
    80005194:	69ae                	ld	s3,200(sp)
    80005196:	a061                	j	8000521e <sys_unlink+0x168>
    end_op();
    80005198:	c5dfe0ef          	jal	80003df4 <end_op>
    return -1;
    8000519c:	557d                	li	a0,-1
    8000519e:	64ee                	ld	s1,216(sp)
    800051a0:	a8bd                	j	8000521e <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800051a2:	00002517          	auipc	a0,0x2
    800051a6:	44e50513          	addi	a0,a0,1102 # 800075f0 <etext+0x5f0>
    800051aa:	e8afb0ef          	jal	80000834 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    800051ae:	04c92703          	lw	a4,76(s2)
    800051b2:	02000793          	li	a5,32
    800051b6:	f8e7f5e3          	bgeu	a5,a4,80005140 <sys_unlink+0x8a>
    800051ba:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800051bc:	4741                	li	a4,16
    800051be:	86ce                	mv	a3,s3
    800051c0:	f1840613          	addi	a2,s0,-232
    800051c4:	4581                	li	a1,0
    800051c6:	854a                	mv	a0,s2
    800051c8:	d02fe0ef          	jal	800036ca <readi>
    800051cc:	47c1                	li	a5,16
    800051ce:	00f51b63          	bne	a0,a5,800051e4 <sys_unlink+0x12e>
    if (de.inum != 0)
    800051d2:	f1845783          	lhu	a5,-232(s0)
    800051d6:	ebb1                	bnez	a5,8000522a <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    800051d8:	29c1                	addiw	s3,s3,16
    800051da:	04c92783          	lw	a5,76(s2)
    800051de:	fcf9efe3          	bltu	s3,a5,800051bc <sys_unlink+0x106>
    800051e2:	bfb9                	j	80005140 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800051e4:	00002517          	auipc	a0,0x2
    800051e8:	42450513          	addi	a0,a0,1060 # 80007608 <etext+0x608>
    800051ec:	e48fb0ef          	jal	80000834 <panic>
    panic("unlink: writei");
    800051f0:	00002517          	auipc	a0,0x2
    800051f4:	43050513          	addi	a0,a0,1072 # 80007620 <etext+0x620>
    800051f8:	e3cfb0ef          	jal	80000834 <panic>
    dp->nlink--;
    800051fc:	04a4d783          	lhu	a5,74(s1)
    80005200:	37fd                	addiw	a5,a5,-1
    80005202:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005206:	8526                	mv	a0,s1
    80005208:	834fe0ef          	jal	8000323c <iupdate>
    8000520c:	b78d                	j	8000516e <sys_unlink+0xb8>
    8000520e:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005210:	8526                	mv	a0,s1
    80005212:	b32fe0ef          	jal	80003544 <iunlockput>
  end_op();
    80005216:	bdffe0ef          	jal	80003df4 <end_op>
  return -1;
    8000521a:	557d                	li	a0,-1
    8000521c:	64ee                	ld	s1,216(sp)
}
    8000521e:	70ae                	ld	ra,232(sp)
    80005220:	740e                	ld	s0,224(sp)
    80005222:	616d                	addi	sp,sp,240
    80005224:	8082                	ret
    return -1;
    80005226:	557d                	li	a0,-1
    80005228:	bfdd                	j	8000521e <sys_unlink+0x168>
    iunlockput(ip);
    8000522a:	854a                	mv	a0,s2
    8000522c:	b18fe0ef          	jal	80003544 <iunlockput>
    goto bad;
    80005230:	694e                	ld	s2,208(sp)
    80005232:	69ae                	ld	s3,200(sp)
    80005234:	bff1                	j	80005210 <sys_unlink+0x15a>

0000000080005236 <sys_open>:

uint64
sys_open(void)
{
    80005236:	7131                	addi	sp,sp,-192
    80005238:	fd06                	sd	ra,184(sp)
    8000523a:	f922                	sd	s0,176(sp)
    8000523c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000523e:	f4c40593          	addi	a1,s0,-180
    80005242:	4505                	li	a0,1
    80005244:	eb0fd0ef          	jal	800028f4 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005248:	08000613          	li	a2,128
    8000524c:	f5040593          	addi	a1,s0,-176
    80005250:	4501                	li	a0,0
    80005252:	edafd0ef          	jal	8000292c <argstr>
    80005256:	87aa                	mv	a5,a0
    return -1;
    80005258:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    8000525a:	0a07c363          	bltz	a5,80005300 <sys_open+0xca>
    8000525e:	f526                	sd	s1,168(sp)

  begin_op();
    80005260:	b09fe0ef          	jal	80003d68 <begin_op>

  if (omode & O_CREATE) {
    80005264:	f4c42783          	lw	a5,-180(s0)
    80005268:	2007f793          	andi	a5,a5,512
    8000526c:	c3dd                	beqz	a5,80005312 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    8000526e:	4681                	li	a3,0
    80005270:	4601                	li	a2,0
    80005272:	4589                	li	a1,2
    80005274:	f5040513          	addi	a0,s0,-176
    80005278:	a5dff0ef          	jal	80004cd4 <create>
    8000527c:	84aa                	mv	s1,a0
    if (ip == 0) {
    8000527e:	c549                	beqz	a0,80005308 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    80005280:	04449703          	lh	a4,68(s1)
    80005284:	478d                	li	a5,3
    80005286:	00f71763          	bne	a4,a5,80005294 <sys_open+0x5e>
    8000528a:	0464d703          	lhu	a4,70(s1)
    8000528e:	47a5                	li	a5,9
    80005290:	0ae7ee63          	bltu	a5,a4,8000534c <sys_open+0x116>
    80005294:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    80005296:	ee9fe0ef          	jal	8000417e <filealloc>
    8000529a:	892a                	mv	s2,a0
    8000529c:	c561                	beqz	a0,80005364 <sys_open+0x12e>
    8000529e:	ed4e                	sd	s3,152(sp)
    800052a0:	9f5ff0ef          	jal	80004c94 <fdalloc>
    800052a4:	89aa                	mv	s3,a0
    800052a6:	0a054b63          	bltz	a0,8000535c <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    800052aa:	04449703          	lh	a4,68(s1)
    800052ae:	478d                	li	a5,3
    800052b0:	0cf70363          	beq	a4,a5,80005376 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800052b4:	4789                	li	a5,2
    800052b6:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800052ba:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800052be:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800052c2:	f4c42783          	lw	a5,-180(s0)
    800052c6:	0017f713          	andi	a4,a5,1
    800052ca:	00174713          	xori	a4,a4,1
    800052ce:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800052d2:	0037f713          	andi	a4,a5,3
    800052d6:	00e03733          	snez	a4,a4
    800052da:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    800052de:	4007f793          	andi	a5,a5,1024
    800052e2:	c791                	beqz	a5,800052ee <sys_open+0xb8>
    800052e4:	04449703          	lh	a4,68(s1)
    800052e8:	4789                	li	a5,2
    800052ea:	08f70d63          	beq	a4,a5,80005384 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800052ee:	8526                	mv	a0,s1
    800052f0:	8aefe0ef          	jal	8000339e <iunlock>
  end_op();
    800052f4:	b01fe0ef          	jal	80003df4 <end_op>

  return fd;
    800052f8:	854e                	mv	a0,s3
    800052fa:	74aa                	ld	s1,168(sp)
    800052fc:	790a                	ld	s2,160(sp)
    800052fe:	69ea                	ld	s3,152(sp)
}
    80005300:	70ea                	ld	ra,184(sp)
    80005302:	744a                	ld	s0,176(sp)
    80005304:	6129                	addi	sp,sp,192
    80005306:	8082                	ret
      end_op();
    80005308:	aedfe0ef          	jal	80003df4 <end_op>
      return -1;
    8000530c:	557d                	li	a0,-1
    8000530e:	74aa                	ld	s1,168(sp)
    80005310:	bfc5                	j	80005300 <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    80005312:	f5040513          	addi	a0,s0,-176
    80005316:	875fe0ef          	jal	80003b8a <namei>
    8000531a:	84aa                	mv	s1,a0
    8000531c:	c11d                	beqz	a0,80005342 <sys_open+0x10c>
    ilock(ip);
    8000531e:	fd3fd0ef          	jal	800032f0 <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    80005322:	04449703          	lh	a4,68(s1)
    80005326:	4785                	li	a5,1
    80005328:	f4f71ce3          	bne	a4,a5,80005280 <sys_open+0x4a>
    8000532c:	f4c42783          	lw	a5,-180(s0)
    80005330:	d3b5                	beqz	a5,80005294 <sys_open+0x5e>
      iunlockput(ip);
    80005332:	8526                	mv	a0,s1
    80005334:	a10fe0ef          	jal	80003544 <iunlockput>
      end_op();
    80005338:	abdfe0ef          	jal	80003df4 <end_op>
      return -1;
    8000533c:	557d                	li	a0,-1
    8000533e:	74aa                	ld	s1,168(sp)
    80005340:	b7c1                	j	80005300 <sys_open+0xca>
      end_op();
    80005342:	ab3fe0ef          	jal	80003df4 <end_op>
      return -1;
    80005346:	557d                	li	a0,-1
    80005348:	74aa                	ld	s1,168(sp)
    8000534a:	bf5d                	j	80005300 <sys_open+0xca>
    iunlockput(ip);
    8000534c:	8526                	mv	a0,s1
    8000534e:	9f6fe0ef          	jal	80003544 <iunlockput>
    end_op();
    80005352:	aa3fe0ef          	jal	80003df4 <end_op>
    return -1;
    80005356:	557d                	li	a0,-1
    80005358:	74aa                	ld	s1,168(sp)
    8000535a:	b75d                	j	80005300 <sys_open+0xca>
      fileclose(f);
    8000535c:	854a                	mv	a0,s2
    8000535e:	ec5fe0ef          	jal	80004222 <fileclose>
    80005362:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005364:	8526                	mv	a0,s1
    80005366:	9defe0ef          	jal	80003544 <iunlockput>
    end_op();
    8000536a:	a8bfe0ef          	jal	80003df4 <end_op>
    return -1;
    8000536e:	557d                	li	a0,-1
    80005370:	74aa                	ld	s1,168(sp)
    80005372:	790a                	ld	s2,160(sp)
    80005374:	b771                	j	80005300 <sys_open+0xca>
    f->type = FD_DEVICE;
    80005376:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    8000537a:	04649783          	lh	a5,70(s1)
    8000537e:	02f91223          	sh	a5,36(s2)
    80005382:	bf35                	j	800052be <sys_open+0x88>
    itrunc(ip);
    80005384:	8526                	mv	a0,s1
    80005386:	858fe0ef          	jal	800033de <itrunc>
    8000538a:	b795                	j	800052ee <sys_open+0xb8>

000000008000538c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000538c:	7175                	addi	sp,sp,-144
    8000538e:	e506                	sd	ra,136(sp)
    80005390:	e122                	sd	s0,128(sp)
    80005392:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005394:	9d5fe0ef          	jal	80003d68 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    80005398:	08000613          	li	a2,128
    8000539c:	f7040593          	addi	a1,s0,-144
    800053a0:	4501                	li	a0,0
    800053a2:	d8afd0ef          	jal	8000292c <argstr>
    800053a6:	02054363          	bltz	a0,800053cc <sys_mkdir+0x40>
    800053aa:	4681                	li	a3,0
    800053ac:	4601                	li	a2,0
    800053ae:	4585                	li	a1,1
    800053b0:	f7040513          	addi	a0,s0,-144
    800053b4:	921ff0ef          	jal	80004cd4 <create>
    800053b8:	c911                	beqz	a0,800053cc <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800053ba:	98afe0ef          	jal	80003544 <iunlockput>
  end_op();
    800053be:	a37fe0ef          	jal	80003df4 <end_op>
  return 0;
    800053c2:	4501                	li	a0,0
}
    800053c4:	60aa                	ld	ra,136(sp)
    800053c6:	640a                	ld	s0,128(sp)
    800053c8:	6149                	addi	sp,sp,144
    800053ca:	8082                	ret
    end_op();
    800053cc:	a29fe0ef          	jal	80003df4 <end_op>
    return -1;
    800053d0:	557d                	li	a0,-1
    800053d2:	bfcd                	j	800053c4 <sys_mkdir+0x38>

00000000800053d4 <sys_mknod>:

uint64
sys_mknod(void)
{
    800053d4:	7135                	addi	sp,sp,-160
    800053d6:	ed06                	sd	ra,152(sp)
    800053d8:	e922                	sd	s0,144(sp)
    800053da:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800053dc:	98dfe0ef          	jal	80003d68 <begin_op>
  argint(1, &major);
    800053e0:	f6c40593          	addi	a1,s0,-148
    800053e4:	4505                	li	a0,1
    800053e6:	d0efd0ef          	jal	800028f4 <argint>
  argint(2, &minor);
    800053ea:	f6840593          	addi	a1,s0,-152
    800053ee:	4509                	li	a0,2
    800053f0:	d04fd0ef          	jal	800028f4 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800053f4:	08000613          	li	a2,128
    800053f8:	f7040593          	addi	a1,s0,-144
    800053fc:	4501                	li	a0,0
    800053fe:	d2efd0ef          	jal	8000292c <argstr>
    80005402:	02054563          	bltz	a0,8000542c <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    80005406:	f6841683          	lh	a3,-152(s0)
    8000540a:	f6c41603          	lh	a2,-148(s0)
    8000540e:	458d                	li	a1,3
    80005410:	f7040513          	addi	a0,s0,-144
    80005414:	8c1ff0ef          	jal	80004cd4 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005418:	c911                	beqz	a0,8000542c <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000541a:	92afe0ef          	jal	80003544 <iunlockput>
  end_op();
    8000541e:	9d7fe0ef          	jal	80003df4 <end_op>
  return 0;
    80005422:	4501                	li	a0,0
}
    80005424:	60ea                	ld	ra,152(sp)
    80005426:	644a                	ld	s0,144(sp)
    80005428:	610d                	addi	sp,sp,160
    8000542a:	8082                	ret
    end_op();
    8000542c:	9c9fe0ef          	jal	80003df4 <end_op>
    return -1;
    80005430:	557d                	li	a0,-1
    80005432:	bfcd                	j	80005424 <sys_mknod+0x50>

0000000080005434 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005434:	7135                	addi	sp,sp,-160
    80005436:	ed06                	sd	ra,152(sp)
    80005438:	e922                	sd	s0,144(sp)
    8000543a:	e14a                	sd	s2,128(sp)
    8000543c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000543e:	d6efc0ef          	jal	800019ac <myproc>
    80005442:	892a                	mv	s2,a0

  begin_op();
    80005444:	925fe0ef          	jal	80003d68 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    80005448:	08000613          	li	a2,128
    8000544c:	f6040593          	addi	a1,s0,-160
    80005450:	4501                	li	a0,0
    80005452:	cdafd0ef          	jal	8000292c <argstr>
    80005456:	04054363          	bltz	a0,8000549c <sys_chdir+0x68>
    8000545a:	e526                	sd	s1,136(sp)
    8000545c:	f6040513          	addi	a0,s0,-160
    80005460:	f2afe0ef          	jal	80003b8a <namei>
    80005464:	84aa                	mv	s1,a0
    80005466:	c915                	beqz	a0,8000549a <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005468:	e89fd0ef          	jal	800032f0 <ilock>
  if (ip->type != T_DIR) {
    8000546c:	04449703          	lh	a4,68(s1)
    80005470:	4785                	li	a5,1
    80005472:	02f71963          	bne	a4,a5,800054a4 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005476:	8526                	mv	a0,s1
    80005478:	f27fd0ef          	jal	8000339e <iunlock>
  iput(p->cwd);
    8000547c:	15093503          	ld	a0,336(s2)
    80005480:	ff3fd0ef          	jal	80003472 <iput>
  end_op();
    80005484:	971fe0ef          	jal	80003df4 <end_op>
  p->cwd = ip;
    80005488:	14993823          	sd	s1,336(s2)
  return 0;
    8000548c:	4501                	li	a0,0
    8000548e:	64aa                	ld	s1,136(sp)
}
    80005490:	60ea                	ld	ra,152(sp)
    80005492:	644a                	ld	s0,144(sp)
    80005494:	690a                	ld	s2,128(sp)
    80005496:	610d                	addi	sp,sp,160
    80005498:	8082                	ret
    8000549a:	64aa                	ld	s1,136(sp)
    end_op();
    8000549c:	959fe0ef          	jal	80003df4 <end_op>
    return -1;
    800054a0:	557d                	li	a0,-1
    800054a2:	b7fd                	j	80005490 <sys_chdir+0x5c>
    iunlockput(ip);
    800054a4:	8526                	mv	a0,s1
    800054a6:	89efe0ef          	jal	80003544 <iunlockput>
    end_op();
    800054aa:	94bfe0ef          	jal	80003df4 <end_op>
    return -1;
    800054ae:	557d                	li	a0,-1
    800054b0:	64aa                	ld	s1,136(sp)
    800054b2:	bff9                	j	80005490 <sys_chdir+0x5c>

00000000800054b4 <sys_exec>:

uint64
sys_exec(void)
{
    800054b4:	7105                	addi	sp,sp,-480
    800054b6:	ef86                	sd	ra,472(sp)
    800054b8:	eba2                	sd	s0,464(sp)
    800054ba:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800054bc:	e2840593          	addi	a1,s0,-472
    800054c0:	4505                	li	a0,1
    800054c2:	c4efd0ef          	jal	80002910 <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    800054c6:	08000613          	li	a2,128
    800054ca:	f3040593          	addi	a1,s0,-208
    800054ce:	4501                	li	a0,0
    800054d0:	c5cfd0ef          	jal	8000292c <argstr>
    800054d4:	87aa                	mv	a5,a0
    return -1;
    800054d6:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    800054d8:	0e07c063          	bltz	a5,800055b8 <sys_exec+0x104>
    800054dc:	e7a6                	sd	s1,456(sp)
    800054de:	e3ca                	sd	s2,448(sp)
    800054e0:	ff4e                	sd	s3,440(sp)
    800054e2:	fb52                	sd	s4,432(sp)
    800054e4:	f756                	sd	s5,424(sp)
    800054e6:	f35a                	sd	s6,416(sp)
    800054e8:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800054ea:	e3040a13          	addi	s4,s0,-464
    800054ee:	10000613          	li	a2,256
    800054f2:	4581                	li	a1,0
    800054f4:	8552                	mv	a0,s4
    800054f6:	ff2fb0ef          	jal	80000ce8 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    800054fa:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800054fc:	89d2                	mv	s3,s4
    800054fe:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005500:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005504:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    80005506:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    8000550a:	00391513          	slli	a0,s2,0x3
    8000550e:	85d6                	mv	a1,s5
    80005510:	e2843783          	ld	a5,-472(s0)
    80005514:	953e                	add	a0,a0,a5
    80005516:	b52fd0ef          	jal	80002868 <fetchaddr>
    8000551a:	02054663          	bltz	a0,80005546 <sys_exec+0x92>
    if (uarg == 0) {
    8000551e:	e2043783          	ld	a5,-480(s0)
    80005522:	c7a1                	beqz	a5,8000556a <sys_exec+0xb6>
    argv[i] = kalloc();
    80005524:	e2afb0ef          	jal	80000b4e <kalloc>
    80005528:	85aa                	mv	a1,a0
    8000552a:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    8000552e:	cd01                	beqz	a0,80005546 <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005530:	865a                	mv	a2,s6
    80005532:	e2043503          	ld	a0,-480(s0)
    80005536:	b7cfd0ef          	jal	800028b2 <fetchstr>
    8000553a:	00054663          	bltz	a0,80005546 <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    8000553e:	0905                	addi	s2,s2,1
    80005540:	09a1                	addi	s3,s3,8
    80005542:	fd7914e3          	bne	s2,s7,8000550a <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005546:	100a0a13          	addi	s4,s4,256
    8000554a:	6088                	ld	a0,0(s1)
    8000554c:	cd31                	beqz	a0,800055a8 <sys_exec+0xf4>
    kfree(argv[i]);
    8000554e:	d18fb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005552:	04a1                	addi	s1,s1,8
    80005554:	ff449be3          	bne	s1,s4,8000554a <sys_exec+0x96>
  return -1;
    80005558:	557d                	li	a0,-1
    8000555a:	64be                	ld	s1,456(sp)
    8000555c:	691e                	ld	s2,448(sp)
    8000555e:	79fa                	ld	s3,440(sp)
    80005560:	7a5a                	ld	s4,432(sp)
    80005562:	7aba                	ld	s5,424(sp)
    80005564:	7b1a                	ld	s6,416(sp)
    80005566:	6bfa                	ld	s7,408(sp)
    80005568:	a881                	j	800055b8 <sys_exec+0x104>
      argv[i] = 0;
    8000556a:	0009079b          	sext.w	a5,s2
    8000556e:	e3040593          	addi	a1,s0,-464
    80005572:	078e                	slli	a5,a5,0x3
    80005574:	97ae                	add	a5,a5,a1
    80005576:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    8000557a:	f3040513          	addi	a0,s0,-208
    8000557e:	b62ff0ef          	jal	800048e0 <kexec>
    80005582:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005584:	100a0a13          	addi	s4,s4,256
    80005588:	6088                	ld	a0,0(s1)
    8000558a:	c511                	beqz	a0,80005596 <sys_exec+0xe2>
    kfree(argv[i]);
    8000558c:	cdafb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005590:	04a1                	addi	s1,s1,8
    80005592:	ff449be3          	bne	s1,s4,80005588 <sys_exec+0xd4>
  return ret;
    80005596:	854a                	mv	a0,s2
    80005598:	64be                	ld	s1,456(sp)
    8000559a:	691e                	ld	s2,448(sp)
    8000559c:	79fa                	ld	s3,440(sp)
    8000559e:	7a5a                	ld	s4,432(sp)
    800055a0:	7aba                	ld	s5,424(sp)
    800055a2:	7b1a                	ld	s6,416(sp)
    800055a4:	6bfa                	ld	s7,408(sp)
    800055a6:	a809                	j	800055b8 <sys_exec+0x104>
  return -1;
    800055a8:	557d                	li	a0,-1
    800055aa:	64be                	ld	s1,456(sp)
    800055ac:	691e                	ld	s2,448(sp)
    800055ae:	79fa                	ld	s3,440(sp)
    800055b0:	7a5a                	ld	s4,432(sp)
    800055b2:	7aba                	ld	s5,424(sp)
    800055b4:	7b1a                	ld	s6,416(sp)
    800055b6:	6bfa                	ld	s7,408(sp)
}
    800055b8:	60fe                	ld	ra,472(sp)
    800055ba:	645e                	ld	s0,464(sp)
    800055bc:	613d                	addi	sp,sp,480
    800055be:	8082                	ret

00000000800055c0 <sys_pipe>:

uint64
sys_pipe(void)
{
    800055c0:	7139                	addi	sp,sp,-64
    800055c2:	fc06                	sd	ra,56(sp)
    800055c4:	f822                	sd	s0,48(sp)
    800055c6:	f426                	sd	s1,40(sp)
    800055c8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800055ca:	be2fc0ef          	jal	800019ac <myproc>
    800055ce:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800055d0:	fd840593          	addi	a1,s0,-40
    800055d4:	4501                	li	a0,0
    800055d6:	b3afd0ef          	jal	80002910 <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    800055da:	fc840593          	addi	a1,s0,-56
    800055de:	fd040513          	addi	a0,s0,-48
    800055e2:	f7ffe0ef          	jal	80004560 <pipealloc>
    return -1;
    800055e6:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    800055e8:	0a054963          	bltz	a0,8000569a <sys_pipe+0xda>
  fd0 = -1;
    800055ec:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    800055f0:	fd043503          	ld	a0,-48(s0)
    800055f4:	ea0ff0ef          	jal	80004c94 <fdalloc>
    800055f8:	fca42223          	sw	a0,-60(s0)
    800055fc:	08054663          	bltz	a0,80005688 <sys_pipe+0xc8>
    80005600:	fc843503          	ld	a0,-56(s0)
    80005604:	e90ff0ef          	jal	80004c94 <fdalloc>
    80005608:	fca42023          	sw	a0,-64(s0)
    8000560c:	06054463          	bltz	a0,80005674 <sys_pipe+0xb4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005610:	4711                	li	a4,4
    80005612:	fc440693          	addi	a3,s0,-60
    80005616:	fd843603          	ld	a2,-40(s0)
    8000561a:	64ac                	ld	a1,72(s1)
    8000561c:	68a8                	ld	a0,80(s1)
    8000561e:	f65fb0ef          	jal	80001582 <copyout>
    80005622:	00054f63          	bltz	a0,80005640 <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    80005626:	4711                	li	a4,4
    80005628:	fc040693          	addi	a3,s0,-64
    8000562c:	fd843603          	ld	a2,-40(s0)
    80005630:	963a                	add	a2,a2,a4
    80005632:	64ac                	ld	a1,72(s1)
    80005634:	68a8                	ld	a0,80(s1)
    80005636:	f4dfb0ef          	jal	80001582 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000563a:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    8000563c:	04055f63          	bgez	a0,8000569a <sys_pipe+0xda>
    p->ofile[fd0] = 0;
    80005640:	fc442783          	lw	a5,-60(s0)
    80005644:	078e                	slli	a5,a5,0x3
    80005646:	0d078793          	addi	a5,a5,208
    8000564a:	97a6                	add	a5,a5,s1
    8000564c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005650:	fc042783          	lw	a5,-64(s0)
    80005654:	078e                	slli	a5,a5,0x3
    80005656:	0d078793          	addi	a5,a5,208
    8000565a:	94be                	add	s1,s1,a5
    8000565c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005660:	fd043503          	ld	a0,-48(s0)
    80005664:	bbffe0ef          	jal	80004222 <fileclose>
    fileclose(wf);
    80005668:	fc843503          	ld	a0,-56(s0)
    8000566c:	bb7fe0ef          	jal	80004222 <fileclose>
    return -1;
    80005670:	57fd                	li	a5,-1
    80005672:	a025                	j	8000569a <sys_pipe+0xda>
    if (fd0 >= 0)
    80005674:	fc442783          	lw	a5,-60(s0)
    80005678:	0007c863          	bltz	a5,80005688 <sys_pipe+0xc8>
      p->ofile[fd0] = 0;
    8000567c:	078e                	slli	a5,a5,0x3
    8000567e:	0d078793          	addi	a5,a5,208
    80005682:	97a6                	add	a5,a5,s1
    80005684:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005688:	fd043503          	ld	a0,-48(s0)
    8000568c:	b97fe0ef          	jal	80004222 <fileclose>
    fileclose(wf);
    80005690:	fc843503          	ld	a0,-56(s0)
    80005694:	b8ffe0ef          	jal	80004222 <fileclose>
    return -1;
    80005698:	57fd                	li	a5,-1
}
    8000569a:	853e                	mv	a0,a5
    8000569c:	70e2                	ld	ra,56(sp)
    8000569e:	7442                	ld	s0,48(sp)
    800056a0:	74a2                	ld	s1,40(sp)
    800056a2:	6121                	addi	sp,sp,64
    800056a4:	8082                	ret
	...

00000000800056b0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800056b0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800056b2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800056b4:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    800056b6:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800056b8:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800056ba:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800056bc:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800056be:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800056c0:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800056c2:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800056c4:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800056c6:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800056c8:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800056ca:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800056cc:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800056ce:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800056d0:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800056d2:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800056d4:	8a2fd0ef          	jal	80002776 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800056d8:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800056da:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800056dc:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800056de:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800056e0:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800056e2:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800056e4:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800056e6:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800056e8:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800056ea:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800056ec:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800056ee:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800056f0:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800056f2:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800056f4:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800056f6:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800056f8:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800056fa:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800056fc:	10200073          	sret
    80005700:	0001                	nop
    80005702:	00000013          	nop
    80005706:	00000013          	nop
    8000570a:	00000013          	nop

000000008000570e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000570e:	1141                	addi	sp,sp,-16
    80005710:	e406                	sd	ra,8(sp)
    80005712:	e022                	sd	s0,0(sp)
    80005714:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(volatile uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80005716:	0c000737          	lui	a4,0xc000
    8000571a:	4785                	li	a5,1
    8000571c:	d71c                	sw	a5,40(a4)
  *(volatile uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    8000571e:	c35c                	sw	a5,4(a4)
}
    80005720:	60a2                	ld	ra,8(sp)
    80005722:	6402                	ld	s0,0(sp)
    80005724:	0141                	addi	sp,sp,16
    80005726:	8082                	ret

0000000080005728 <plicinithart>:

void
plicinithart(void)
{
    80005728:	1141                	addi	sp,sp,-16
    8000572a:	e406                	sd	ra,8(sp)
    8000572c:	e022                	sd	s0,0(sp)
    8000572e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005730:	a48fc0ef          	jal	80001978 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(volatile uint32 *)PLIC_SENABLE(hart) =
    80005734:	0085179b          	slliw	a5,a0,0x8
    80005738:	0c002737          	lui	a4,0xc002
    8000573c:	08070713          	addi	a4,a4,128 # c002080 <_entry-0x73ffdf80>
    80005740:	97ba                	add	a5,a5,a4
    80005742:	40200713          	li	a4,1026
    80005746:	c398                	sw	a4,0(a5)
    (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);

  // set this hart's S-mode priority threshold to 0.
  *(volatile uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005748:	00d5151b          	slliw	a0,a0,0xd
    8000574c:	0c2017b7          	lui	a5,0xc201
    80005750:	953e                	add	a0,a0,a5
    80005752:	00052023          	sw	zero,0(a0)
}
    80005756:	60a2                	ld	ra,8(sp)
    80005758:	6402                	ld	s0,0(sp)
    8000575a:	0141                	addi	sp,sp,16
    8000575c:	8082                	ret

000000008000575e <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000575e:	1141                	addi	sp,sp,-16
    80005760:	e406                	sd	ra,8(sp)
    80005762:	e022                	sd	s0,0(sp)
    80005764:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005766:	a12fc0ef          	jal	80001978 <cpuid>
  int irq = *(volatile uint32 *)PLIC_SCLAIM(hart);
    8000576a:	00d5151b          	slliw	a0,a0,0xd
    8000576e:	0c2017b7          	lui	a5,0xc201
    80005772:	0791                	addi	a5,a5,4 # c201004 <_entry-0x73dfeffc>
    80005774:	953e                	add	a0,a0,a5
    80005776:	4108                	lw	a0,0(a0)
  return irq;
}
    80005778:	60a2                	ld	ra,8(sp)
    8000577a:	6402                	ld	s0,0(sp)
    8000577c:	0141                	addi	sp,sp,16
    8000577e:	8082                	ret

0000000080005780 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005780:	1101                	addi	sp,sp,-32
    80005782:	ec06                	sd	ra,24(sp)
    80005784:	e822                	sd	s0,16(sp)
    80005786:	e426                	sd	s1,8(sp)
    80005788:	1000                	addi	s0,sp,32
    8000578a:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000578c:	9ecfc0ef          	jal	80001978 <cpuid>
  *(volatile uint32 *)PLIC_SCLAIM(hart) = irq;
    80005790:	00d5179b          	slliw	a5,a0,0xd
    80005794:	0c201737          	lui	a4,0xc201
    80005798:	0711                	addi	a4,a4,4 # c201004 <_entry-0x73dfeffc>
    8000579a:	97ba                	add	a5,a5,a4
    8000579c:	c384                	sw	s1,0(a5)
}
    8000579e:	60e2                	ld	ra,24(sp)
    800057a0:	6442                	ld	s0,16(sp)
    800057a2:	64a2                	ld	s1,8(sp)
    800057a4:	6105                	addi	sp,sp,32
    800057a6:	8082                	ret

00000000800057a8 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800057a8:	1141                	addi	sp,sp,-16
    800057aa:	e406                	sd	ra,8(sp)
    800057ac:	e022                	sd	s0,0(sp)
    800057ae:	0800                	addi	s0,sp,16
  if (i >= NUM)
    800057b0:	479d                	li	a5,7
    800057b2:	04a7ca63          	blt	a5,a0,80005806 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    800057b6:	0001e797          	auipc	a5,0x1e
    800057ba:	d9278793          	addi	a5,a5,-622 # 80023548 <disk>
    800057be:	97aa                	add	a5,a5,a0
    800057c0:	0187c783          	lbu	a5,24(a5)
    800057c4:	e7b9                	bnez	a5,80005812 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800057c6:	00451693          	slli	a3,a0,0x4
    800057ca:	0001e797          	auipc	a5,0x1e
    800057ce:	d7e78793          	addi	a5,a5,-642 # 80023548 <disk>
    800057d2:	6398                	ld	a4,0(a5)
    800057d4:	9736                	add	a4,a4,a3
    800057d6:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800057da:	6398                	ld	a4,0(a5)
    800057dc:	9736                	add	a4,a4,a3
    800057de:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800057e2:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800057e6:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800057ea:	97aa                	add	a5,a5,a0
    800057ec:	4705                	li	a4,1
    800057ee:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800057f2:	0001e517          	auipc	a0,0x1e
    800057f6:	d6e50513          	addi	a0,a0,-658 # 80023560 <disk+0x18>
    800057fa:	829fc0ef          	jal	80002022 <wakeup>
}
    800057fe:	60a2                	ld	ra,8(sp)
    80005800:	6402                	ld	s0,0(sp)
    80005802:	0141                	addi	sp,sp,16
    80005804:	8082                	ret
    panic("free_desc 1");
    80005806:	00002517          	auipc	a0,0x2
    8000580a:	e2a50513          	addi	a0,a0,-470 # 80007630 <etext+0x630>
    8000580e:	826fb0ef          	jal	80000834 <panic>
    panic("free_desc 2");
    80005812:	00002517          	auipc	a0,0x2
    80005816:	e2e50513          	addi	a0,a0,-466 # 80007640 <etext+0x640>
    8000581a:	81afb0ef          	jal	80000834 <panic>

000000008000581e <virtio_disk_init>:
{
    8000581e:	1101                	addi	sp,sp,-32
    80005820:	ec06                	sd	ra,24(sp)
    80005822:	e822                	sd	s0,16(sp)
    80005824:	e426                	sd	s1,8(sp)
    80005826:	e04a                	sd	s2,0(sp)
    80005828:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000582a:	00002597          	auipc	a1,0x2
    8000582e:	e2658593          	addi	a1,a1,-474 # 80007650 <etext+0x650>
    80005832:	0001e517          	auipc	a0,0x1e
    80005836:	e3e50513          	addi	a0,a0,-450 # 80023670 <disk+0x128>
    8000583a:	b6efb0ef          	jal	80000ba8 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000583e:	100017b7          	lui	a5,0x10001
    80005842:	4398                	lw	a4,0(a5)
    80005844:	2701                	sext.w	a4,a4
    80005846:	747277b7          	lui	a5,0x74727
    8000584a:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000584e:	14f71863          	bne	a4,a5,8000599e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005852:	100017b7          	lui	a5,0x10001
    80005856:	43dc                	lw	a5,4(a5)
    80005858:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000585a:	4709                	li	a4,2
    8000585c:	14e79163          	bne	a5,a4,8000599e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005860:	100017b7          	lui	a5,0x10001
    80005864:	479c                	lw	a5,8(a5)
    80005866:	2781                	sext.w	a5,a5
    80005868:	12e79b63          	bne	a5,a4,8000599e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    8000586c:	100017b7          	lui	a5,0x10001
    80005870:	47d8                	lw	a4,12(a5)
    80005872:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005874:	554d47b7          	lui	a5,0x554d4
    80005878:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000587c:	12f71163          	bne	a4,a5,8000599e <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005880:	100017b7          	lui	a5,0x10001
    80005884:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005888:	4705                	li	a4,1
    8000588a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000588c:	470d                	li	a4,3
    8000588e:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005890:	10001737          	lui	a4,0x10001
    80005894:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005896:	c7ffe6b7          	lui	a3,0xc7ffe
    8000589a:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fdaed7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000589e:	8f75                	and	a4,a4,a3
    800058a0:	100016b7          	lui	a3,0x10001
    800058a4:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800058a6:	472d                	li	a4,11
    800058a8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800058aa:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800058ae:	439c                	lw	a5,0(a5)
    800058b0:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800058b4:	8ba1                	andi	a5,a5,8
    800058b6:	0e078a63          	beqz	a5,800059aa <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800058ba:	100017b7          	lui	a5,0x10001
    800058be:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    800058c2:	43fc                	lw	a5,68(a5)
    800058c4:	2781                	sext.w	a5,a5
    800058c6:	0e079863          	bnez	a5,800059b6 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800058ca:	100017b7          	lui	a5,0x10001
    800058ce:	5bdc                	lw	a5,52(a5)
    800058d0:	2781                	sext.w	a5,a5
  if (max == 0)
    800058d2:	0e078863          	beqz	a5,800059c2 <virtio_disk_init+0x1a4>
  if (max < NUM)
    800058d6:	471d                	li	a4,7
    800058d8:	0ef77b63          	bgeu	a4,a5,800059ce <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    800058dc:	a72fb0ef          	jal	80000b4e <kalloc>
    800058e0:	0001e497          	auipc	s1,0x1e
    800058e4:	c6848493          	addi	s1,s1,-920 # 80023548 <disk>
    800058e8:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800058ea:	a64fb0ef          	jal	80000b4e <kalloc>
    800058ee:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800058f0:	a5efb0ef          	jal	80000b4e <kalloc>
    800058f4:	87aa                	mv	a5,a0
    800058f6:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    800058f8:	6088                	ld	a0,0(s1)
    800058fa:	0e050063          	beqz	a0,800059da <virtio_disk_init+0x1bc>
    800058fe:	0001e717          	auipc	a4,0x1e
    80005902:	c5273703          	ld	a4,-942(a4) # 80023550 <disk+0x8>
    80005906:	cb71                	beqz	a4,800059da <virtio_disk_init+0x1bc>
    80005908:	cbe9                	beqz	a5,800059da <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    8000590a:	6605                	lui	a2,0x1
    8000590c:	4581                	li	a1,0
    8000590e:	bdafb0ef          	jal	80000ce8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005912:	0001e497          	auipc	s1,0x1e
    80005916:	c3648493          	addi	s1,s1,-970 # 80023548 <disk>
    8000591a:	6605                	lui	a2,0x1
    8000591c:	4581                	li	a1,0
    8000591e:	6488                	ld	a0,8(s1)
    80005920:	bc8fb0ef          	jal	80000ce8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005924:	6605                	lui	a2,0x1
    80005926:	4581                	li	a1,0
    80005928:	6888                	ld	a0,16(s1)
    8000592a:	bbefb0ef          	jal	80000ce8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000592e:	100017b7          	lui	a5,0x10001
    80005932:	4721                	li	a4,8
    80005934:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005936:	4098                	lw	a4,0(s1)
    80005938:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000593c:	40d8                	lw	a4,4(s1)
    8000593e:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005942:	649c                	ld	a5,8(s1)
    80005944:	0007869b          	sext.w	a3,a5
    80005948:	10001737          	lui	a4,0x10001
    8000594c:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005950:	9781                	srai	a5,a5,0x20
    80005952:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005956:	689c                	ld	a5,16(s1)
    80005958:	0007869b          	sext.w	a3,a5
    8000595c:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005960:	9781                	srai	a5,a5,0x20
    80005962:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005966:	4785                	li	a5,1
    80005968:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    8000596a:	00f48c23          	sb	a5,24(s1)
    8000596e:	00f48ca3          	sb	a5,25(s1)
    80005972:	00f48d23          	sb	a5,26(s1)
    80005976:	00f48da3          	sb	a5,27(s1)
    8000597a:	00f48e23          	sb	a5,28(s1)
    8000597e:	00f48ea3          	sb	a5,29(s1)
    80005982:	00f48f23          	sb	a5,30(s1)
    80005986:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000598a:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    8000598e:	07272823          	sw	s2,112(a4)
}
    80005992:	60e2                	ld	ra,24(sp)
    80005994:	6442                	ld	s0,16(sp)
    80005996:	64a2                	ld	s1,8(sp)
    80005998:	6902                	ld	s2,0(sp)
    8000599a:	6105                	addi	sp,sp,32
    8000599c:	8082                	ret
    panic("could not find virtio disk");
    8000599e:	00002517          	auipc	a0,0x2
    800059a2:	cc250513          	addi	a0,a0,-830 # 80007660 <etext+0x660>
    800059a6:	e8ffa0ef          	jal	80000834 <panic>
    panic("virtio disk FEATURES_OK unset");
    800059aa:	00002517          	auipc	a0,0x2
    800059ae:	cd650513          	addi	a0,a0,-810 # 80007680 <etext+0x680>
    800059b2:	e83fa0ef          	jal	80000834 <panic>
    panic("virtio disk should not be ready");
    800059b6:	00002517          	auipc	a0,0x2
    800059ba:	cea50513          	addi	a0,a0,-790 # 800076a0 <etext+0x6a0>
    800059be:	e77fa0ef          	jal	80000834 <panic>
    panic("virtio disk has no queue 0");
    800059c2:	00002517          	auipc	a0,0x2
    800059c6:	cfe50513          	addi	a0,a0,-770 # 800076c0 <etext+0x6c0>
    800059ca:	e6bfa0ef          	jal	80000834 <panic>
    panic("virtio disk max queue too short");
    800059ce:	00002517          	auipc	a0,0x2
    800059d2:	d1250513          	addi	a0,a0,-750 # 800076e0 <etext+0x6e0>
    800059d6:	e5ffa0ef          	jal	80000834 <panic>
    panic("virtio disk kalloc");
    800059da:	00002517          	auipc	a0,0x2
    800059de:	d2650513          	addi	a0,a0,-730 # 80007700 <etext+0x700>
    800059e2:	e53fa0ef          	jal	80000834 <panic>

00000000800059e6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800059e6:	711d                	addi	sp,sp,-96
    800059e8:	ec86                	sd	ra,88(sp)
    800059ea:	e8a2                	sd	s0,80(sp)
    800059ec:	e4a6                	sd	s1,72(sp)
    800059ee:	e0ca                	sd	s2,64(sp)
    800059f0:	fc4e                	sd	s3,56(sp)
    800059f2:	f852                	sd	s4,48(sp)
    800059f4:	f456                	sd	s5,40(sp)
    800059f6:	f05a                	sd	s6,32(sp)
    800059f8:	ec5e                	sd	s7,24(sp)
    800059fa:	e862                	sd	s8,16(sp)
    800059fc:	1080                	addi	s0,sp,96
    800059fe:	89aa                	mv	s3,a0
    80005a00:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005a02:	00c52b83          	lw	s7,12(a0)
    80005a06:	001b9b9b          	slliw	s7,s7,0x1
    80005a0a:	1b82                	slli	s7,s7,0x20
    80005a0c:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005a10:	0001e517          	auipc	a0,0x1e
    80005a14:	c6050513          	addi	a0,a0,-928 # 80023670 <disk+0x128>
    80005a18:	a10fb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < NUM; i++) {
    80005a1c:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005a1e:	0001ea97          	auipc	s5,0x1e
    80005a22:	b2aa8a93          	addi	s5,s5,-1238 # 80023548 <disk>
  for (int i = 0; i < 3; i++) {
    80005a26:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005a28:	5c7d                	li	s8,-1
    80005a2a:	a8a5                	j	80005aa2 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80005a2c:	00fa8733          	add	a4,s5,a5
    80005a30:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005a34:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005a36:	0207c563          	bltz	a5,80005a60 <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    80005a3a:	2905                	addiw	s2,s2,1
    80005a3c:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005a3e:	07490663          	beq	s2,s4,80005aaa <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80005a42:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005a44:	0001e717          	auipc	a4,0x1e
    80005a48:	b0470713          	addi	a4,a4,-1276 # 80023548 <disk>
    80005a4c:	4781                	li	a5,0
    if (disk.free[i]) {
    80005a4e:	01874683          	lbu	a3,24(a4)
    80005a52:	fee9                	bnez	a3,80005a2c <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    80005a54:	2785                	addiw	a5,a5,1
    80005a56:	0705                	addi	a4,a4,1
    80005a58:	fe979be3          	bne	a5,s1,80005a4e <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005a5c:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    80005a60:	01205d63          	blez	s2,80005a7a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005a64:	fa042503          	lw	a0,-96(s0)
    80005a68:	d41ff0ef          	jal	800057a8 <free_desc>
      for (int j = 0; j < i; j++)
    80005a6c:	4785                	li	a5,1
    80005a6e:	0127d663          	bge	a5,s2,80005a7a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005a72:	fa442503          	lw	a0,-92(s0)
    80005a76:	d33ff0ef          	jal	800057a8 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005a7a:	0001e517          	auipc	a0,0x1e
    80005a7e:	ae650513          	addi	a0,a0,-1306 # 80023560 <disk+0x18>
    80005a82:	d34fc0ef          	jal	80001fb6 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005a86:	0001e517          	auipc	a0,0x1e
    80005a8a:	bea50513          	addi	a0,a0,-1046 # 80023670 <disk+0x128>
    80005a8e:	a22fb0ef          	jal	80000cb0 <release>
    sleep();
    80005a92:	d60fc0ef          	jal	80001ff2 <sleep>
    acquire(&disk.vdisk_lock);
    80005a96:	0001e517          	auipc	a0,0x1e
    80005a9a:	bda50513          	addi	a0,a0,-1062 # 80023670 <disk+0x128>
    80005a9e:	98afb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < 3; i++) {
    80005aa2:	fa040613          	addi	a2,s0,-96
    80005aa6:	4901                	li	s2,0
    80005aa8:	bf69                	j	80005a42 <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005aaa:	fa042503          	lw	a0,-96(s0)
    80005aae:	00451693          	slli	a3,a0,0x4

  if (write)
    80005ab2:	0001e797          	auipc	a5,0x1e
    80005ab6:	a9678793          	addi	a5,a5,-1386 # 80023548 <disk>
    80005aba:	00451713          	slli	a4,a0,0x4
    80005abe:	0a070713          	addi	a4,a4,160
    80005ac2:	973e                	add	a4,a4,a5
    80005ac4:	01603633          	snez	a2,s6
    80005ac8:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005aca:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005ace:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005ad2:	6398                	ld	a4,0(a5)
    80005ad4:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005ad6:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005ada:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005adc:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005ade:	6390                	ld	a2,0(a5)
    80005ae0:	00d60833          	add	a6,a2,a3
    80005ae4:	4741                	li	a4,16
    80005ae6:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005aea:	4585                	li	a1,1
    80005aec:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005af0:	fa442703          	lw	a4,-92(s0)
    80005af4:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005af8:	0712                	slli	a4,a4,0x4
    80005afa:	963a                	add	a2,a2,a4
    80005afc:	05898813          	addi	a6,s3,88
    80005b00:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005b04:	0007b883          	ld	a7,0(a5)
    80005b08:	9746                	add	a4,a4,a7
    80005b0a:	40000613          	li	a2,1024
    80005b0e:	c710                	sw	a2,8(a4)
  if (write)
    80005b10:	001b3613          	seqz	a2,s6
    80005b14:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005b18:	8e4d                	or	a2,a2,a1
    80005b1a:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005b1e:	fa842603          	lw	a2,-88(s0)
    80005b22:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005b26:	00451813          	slli	a6,a0,0x4
    80005b2a:	02080813          	addi	a6,a6,32
    80005b2e:	983e                	add	a6,a6,a5
    80005b30:	577d                	li	a4,-1
    80005b32:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005b36:	0612                	slli	a2,a2,0x4
    80005b38:	98b2                	add	a7,a7,a2
    80005b3a:	03068713          	addi	a4,a3,48
    80005b3e:	973e                	add	a4,a4,a5
    80005b40:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005b44:	6398                	ld	a4,0(a5)
    80005b46:	9732                	add	a4,a4,a2
    80005b48:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005b4a:	4689                	li	a3,2
    80005b4c:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005b50:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005b54:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005b58:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005b5c:	6794                	ld	a3,8(a5)
    80005b5e:	0026d703          	lhu	a4,2(a3)
    80005b62:	8b1d                	andi	a4,a4,7
    80005b64:	0706                	slli	a4,a4,0x1
    80005b66:	96ba                	add	a3,a3,a4
    80005b68:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005b6c:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005b70:	6798                	ld	a4,8(a5)
    80005b72:	00275783          	lhu	a5,2(a4)
    80005b76:	2785                	addiw	a5,a5,1
    80005b78:	00f71123          	sh	a5,2(a4)
    80005b7c:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005b80:	100017b7          	lui	a5,0x10001
    80005b84:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005b88:	0049a783          	lw	a5,4(s3)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005b8c:	0001e497          	auipc	s1,0x1e
    80005b90:	ae448493          	addi	s1,s1,-1308 # 80023670 <disk+0x128>
  while (b->disk == 1) {
    80005b94:	892e                	mv	s2,a1
    80005b96:	02b79163          	bne	a5,a1,80005bb8 <virtio_disk_rw+0x1d2>
    sleep_prepare(b);
    80005b9a:	854e                	mv	a0,s3
    80005b9c:	c1afc0ef          	jal	80001fb6 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005ba0:	8526                	mv	a0,s1
    80005ba2:	90efb0ef          	jal	80000cb0 <release>
    sleep();
    80005ba6:	c4cfc0ef          	jal	80001ff2 <sleep>
    acquire(&disk.vdisk_lock);
    80005baa:	8526                	mv	a0,s1
    80005bac:	87cfb0ef          	jal	80000c28 <acquire>
  while (b->disk == 1) {
    80005bb0:	0049a783          	lw	a5,4(s3)
    80005bb4:	ff2783e3          	beq	a5,s2,80005b9a <virtio_disk_rw+0x1b4>
  }

  disk.info[idx[0]].b = 0;
    80005bb8:	fa042903          	lw	s2,-96(s0)
    80005bbc:	00491713          	slli	a4,s2,0x4
    80005bc0:	02070713          	addi	a4,a4,32
    80005bc4:	0001e797          	auipc	a5,0x1e
    80005bc8:	98478793          	addi	a5,a5,-1660 # 80023548 <disk>
    80005bcc:	97ba                	add	a5,a5,a4
    80005bce:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005bd2:	0001e997          	auipc	s3,0x1e
    80005bd6:	97698993          	addi	s3,s3,-1674 # 80023548 <disk>
    80005bda:	00491713          	slli	a4,s2,0x4
    80005bde:	0009b783          	ld	a5,0(s3)
    80005be2:	97ba                	add	a5,a5,a4
    80005be4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005be8:	854a                	mv	a0,s2
    80005bea:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005bee:	bbbff0ef          	jal	800057a8 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005bf2:	8885                	andi	s1,s1,1
    80005bf4:	f0fd                	bnez	s1,80005bda <virtio_disk_rw+0x1f4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005bf6:	0001e517          	auipc	a0,0x1e
    80005bfa:	a7a50513          	addi	a0,a0,-1414 # 80023670 <disk+0x128>
    80005bfe:	8b2fb0ef          	jal	80000cb0 <release>
}
    80005c02:	60e6                	ld	ra,88(sp)
    80005c04:	6446                	ld	s0,80(sp)
    80005c06:	64a6                	ld	s1,72(sp)
    80005c08:	6906                	ld	s2,64(sp)
    80005c0a:	79e2                	ld	s3,56(sp)
    80005c0c:	7a42                	ld	s4,48(sp)
    80005c0e:	7aa2                	ld	s5,40(sp)
    80005c10:	7b02                	ld	s6,32(sp)
    80005c12:	6be2                	ld	s7,24(sp)
    80005c14:	6c42                	ld	s8,16(sp)
    80005c16:	6125                	addi	sp,sp,96
    80005c18:	8082                	ret

0000000080005c1a <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005c1a:	1101                	addi	sp,sp,-32
    80005c1c:	ec06                	sd	ra,24(sp)
    80005c1e:	e822                	sd	s0,16(sp)
    80005c20:	e426                	sd	s1,8(sp)
    80005c22:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005c24:	0001e497          	auipc	s1,0x1e
    80005c28:	92448493          	addi	s1,s1,-1756 # 80023548 <disk>
    80005c2c:	0001e517          	auipc	a0,0x1e
    80005c30:	a4450513          	addi	a0,a0,-1468 # 80023670 <disk+0x128>
    80005c34:	ff5fa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005c38:	100017b7          	lui	a5,0x10001
    80005c3c:	53bc                	lw	a5,96(a5)
    80005c3e:	8b8d                	andi	a5,a5,3
    80005c40:	10001737          	lui	a4,0x10001
    80005c44:	d37c                	sw	a5,100(a4)
    80005c46:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005c4a:	689c                	ld	a5,16(s1)
    80005c4c:	0204d703          	lhu	a4,32(s1)
    80005c50:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005c54:	04f70863          	beq	a4,a5,80005ca4 <virtio_disk_intr+0x8a>
    80005c58:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005c5c:	6898                	ld	a4,16(s1)
    80005c5e:	0204d783          	lhu	a5,32(s1)
    80005c62:	8b9d                	andi	a5,a5,7
    80005c64:	078e                	slli	a5,a5,0x3
    80005c66:	97ba                	add	a5,a5,a4
    80005c68:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005c6a:	00479713          	slli	a4,a5,0x4
    80005c6e:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005c72:	9726                	add	a4,a4,s1
    80005c74:	01074703          	lbu	a4,16(a4)
    80005c78:	e329                	bnez	a4,80005cba <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005c7a:	0792                	slli	a5,a5,0x4
    80005c7c:	02078793          	addi	a5,a5,32
    80005c80:	97a6                	add	a5,a5,s1
    80005c82:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005c84:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005c88:	b9afc0ef          	jal	80002022 <wakeup>

    disk.used_idx += 1;
    80005c8c:	0204d783          	lhu	a5,32(s1)
    80005c90:	2785                	addiw	a5,a5,1
    80005c92:	17c2                	slli	a5,a5,0x30
    80005c94:	93c1                	srli	a5,a5,0x30
    80005c96:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005c9a:	6898                	ld	a4,16(s1)
    80005c9c:	00275703          	lhu	a4,2(a4)
    80005ca0:	faf71ce3          	bne	a4,a5,80005c58 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005ca4:	0001e517          	auipc	a0,0x1e
    80005ca8:	9cc50513          	addi	a0,a0,-1588 # 80023670 <disk+0x128>
    80005cac:	804fb0ef          	jal	80000cb0 <release>
}
    80005cb0:	60e2                	ld	ra,24(sp)
    80005cb2:	6442                	ld	s0,16(sp)
    80005cb4:	64a2                	ld	s1,8(sp)
    80005cb6:	6105                	addi	sp,sp,32
    80005cb8:	8082                	ret
      panic("virtio_disk_intr status");
    80005cba:	00002517          	auipc	a0,0x2
    80005cbe:	a5e50513          	addi	a0,a0,-1442 # 80007718 <etext+0x718>
    80005cc2:	b73fa0ef          	jal	80000834 <panic>
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
