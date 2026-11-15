
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
    80000004:	34813103          	ld	sp,840(sp) # 8000a348 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000066:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb13f>
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
    8000011c:	28e020ef          	jal	800023aa <either_copyin>
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
    80000198:	20c50513          	addi	a0,a0,524 # 800123a0 <cons>
    8000019c:	28d000ef          	jal	80000c28 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    800001a0:	00012497          	auipc	s1,0x12
    800001a4:	20048493          	addi	s1,s1,512 # 800123a0 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a8:	00012917          	auipc	s2,0x12
    800001ac:	29090913          	addi	s2,s2,656 # 80012438 <cons+0x98>
  while (n > 0) {
    800001b0:	0d305263          	blez	s3,80000274 <consoleread+0xfc>
    while (cons.r == cons.w) {
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	0af71763          	bne	a4,a5,8000026a <consoleread+0xf2>
      if (killed(myproc())) {
    800001c0:	78c010ef          	jal	8000194c <myproc>
    800001c4:	066020ef          	jal	8000222a <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	601010ef          	jal	80001fcc <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	2df000ef          	jal	80000cb0 <release>
      sleep();
    800001d6:	633010ef          	jal	80002008 <sleep>
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
    800001f2:	1b270713          	addi	a4,a4,434 # 800123a0 <cons>
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
    80000220:	13e020ef          	jal	8000235e <either_copyout>
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
    8000023c:	16850513          	addi	a0,a0,360 # 800123a0 <cons>
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
    80000262:	1cf72d23          	sw	a5,474(a4) # 80012438 <cons+0x98>
    80000266:	7aa2                	ld	s5,40(sp)
    80000268:	a031                	j	80000274 <consoleread+0xfc>
    8000026a:	f456                	sd	s5,40(sp)
    8000026c:	b749                	j	800001ee <consoleread+0x76>
    8000026e:	7aa2                	ld	s5,40(sp)
    80000270:	a011                	j	80000274 <consoleread+0xfc>
    80000272:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000274:	00012517          	auipc	a0,0x12
    80000278:	12c50513          	addi	a0,a0,300 # 800123a0 <cons>
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
    800002cc:	0d850513          	addi	a0,a0,216 # 800123a0 <cons>
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
    800002ea:	10c020ef          	jal	800023f6 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ee:	00012517          	auipc	a0,0x12
    800002f2:	0b250513          	addi	a0,a0,178 # 800123a0 <cons>
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
    80000310:	09470713          	addi	a4,a4,148 # 800123a0 <cons>
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
    80000336:	06e70713          	addi	a4,a4,110 # 800123a0 <cons>
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
    80000360:	0dc72703          	lw	a4,220(a4) # 80012438 <cons+0x98>
    80000364:	9f99                	subw	a5,a5,a4
    80000366:	08000713          	li	a4,128
    8000036a:	f8e792e3          	bne	a5,a4,800002ee <consoleintr+0x32>
    8000036e:	a075                	j	8000041a <consoleintr+0x15e>
    80000370:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000372:	00012717          	auipc	a4,0x12
    80000376:	02e70713          	addi	a4,a4,46 # 800123a0 <cons>
    8000037a:	0a072783          	lw	a5,160(a4)
    8000037e:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000382:	00012497          	auipc	s1,0x12
    80000386:	01e48493          	addi	s1,s1,30 # 800123a0 <cons>
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
    800003c8:	fdc70713          	addi	a4,a4,-36 # 800123a0 <cons>
    800003cc:	0a072783          	lw	a5,160(a4)
    800003d0:	09c72703          	lw	a4,156(a4)
    800003d4:	f0f70de3          	beq	a4,a5,800002ee <consoleintr+0x32>
      cons.e--;
    800003d8:	37fd                	addiw	a5,a5,-1
    800003da:	00012717          	auipc	a4,0x12
    800003de:	06f72323          	sw	a5,102(a4) # 80012440 <cons+0xa0>
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
    800003fc:	fa878793          	addi	a5,a5,-88 # 800123a0 <cons>
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
    8000041e:	02c7a123          	sw	a2,34(a5) # 8001243c <cons+0x9c>
        wakeup(&cons.r);
    80000422:	00012517          	auipc	a0,0x12
    80000426:	01650513          	addi	a0,a0,22 # 80012438 <cons+0x98>
    8000042a:	40f010ef          	jal	80002038 <wakeup>
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
    80000444:	f6050513          	addi	a0,a0,-160 # 800123a0 <cons>
    80000448:	760000ef          	jal	80000ba8 <initlock>

  uartinit();
    8000044c:	448000ef          	jal	80000894 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000450:	00022797          	auipc	a5,0x22
    80000454:	0d878793          	addi	a5,a5,216 # 80022528 <devsw>
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
    80000492:	2aa80813          	addi	a6,a6,682 # 80007738 <digits>
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
    8000052c:	e3c7a783          	lw	a5,-452(a5) # 8000a364 <panicking>
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
    80000572:	eda50513          	addi	a0,a0,-294 # 80012448 <pr>
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
    800006e6:	056c8c93          	addi	s9,s9,86 # 80007738 <digits>
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
    8000076e:	bfa7a783          	lw	a5,-1030(a5) # 8000a364 <panicking>
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
    80000798:	cb450513          	addi	a0,a0,-844 # 80012448 <pr>
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
    80000848:	b297a023          	sw	s1,-1248(a5) # 8000a364 <panicking>
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
    8000086a:	ae97ad23          	sw	s1,-1286(a5) # 8000a360 <panicked>
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
    80000884:	bc850513          	addi	a0,a0,-1080 # 80012448 <pr>
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
    800008da:	b8a50513          	addi	a0,a0,-1142 # 80012460 <tx_lock>
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
    800008fe:	b6650513          	addi	a0,a0,-1178 # 80012460 <tx_lock>
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
    8000091c:	a5490913          	addi	s2,s2,-1452 # 8000a36c <tx_busy>
      // wait for a UART interrupt to set tx_busy to 0.
      sleep_prepare(&tx_chan);
    80000920:	0000a997          	auipc	s3,0xa
    80000924:	a4898993          	addi	s3,s3,-1464 # 8000a368 <tx_chan>
      release(&tx_lock);
    80000928:	00012497          	auipc	s1,0x12
    8000092c:	b3848493          	addi	s1,s1,-1224 # 80012460 <tx_lock>
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
    8000093a:	692010ef          	jal	80001fcc <sleep_prepare>
      release(&tx_lock);
    8000093e:	8526                	mv	a0,s1
    80000940:	370000ef          	jal	80000cb0 <release>
      sleep();
    80000944:	6c4010ef          	jal	80002008 <sleep>
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
    8000097c:	ae850513          	addi	a0,a0,-1304 # 80012460 <tx_lock>
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
    800009a0:	9c87a783          	lw	a5,-1592(a5) # 8000a364 <panicking>
    800009a4:	cf95                	beqz	a5,800009e0 <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    800009a6:	0000a797          	auipc	a5,0xa
    800009aa:	9ba7a783          	lw	a5,-1606(a5) # 8000a360 <panicked>
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
    800009d0:	9987a783          	lw	a5,-1640(a5) # 8000a364 <panicking>
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
    80000a06:	a5e50513          	addi	a0,a0,-1442 # 80012460 <tx_lock>
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
    80000a20:	a4450513          	addi	a0,a0,-1468 # 80012460 <tx_lock>
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
    80000a48:	9207a423          	sw	zero,-1752(a5) # 8000a36c <tx_busy>
    wakeup(&tx_chan);
    80000a4c:	0000a517          	auipc	a0,0xa
    80000a50:	91c50513          	addi	a0,a0,-1764 # 8000a368 <tx_chan>
    80000a54:	5e4010ef          	jal	80002038 <wakeup>
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
    80000a76:	c4e78793          	addi	a5,a5,-946 # 800236c0 <end>
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
    80000aa0:	9dc90913          	addi	s2,s2,-1572 # 80012478 <kmem>
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
    80000b2e:	94e50513          	addi	a0,a0,-1714 # 80012478 <kmem>
    80000b32:	076000ef          	jal	80000ba8 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000b36:	45c5                	li	a1,17
    80000b38:	05ee                	slli	a1,a1,0x1b
    80000b3a:	00023517          	auipc	a0,0x23
    80000b3e:	b8650513          	addi	a0,a0,-1146 # 800236c0 <end>
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
    80000b5c:	92050513          	addi	a0,a0,-1760 # 80012478 <kmem>
    80000b60:	0c8000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b64:	00012497          	auipc	s1,0x12
    80000b68:	92c4b483          	ld	s1,-1748(s1) # 80012490 <kmem+0x18>
  if (r)
    80000b6c:	c49d                	beqz	s1,80000b9a <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b6e:	609c                	ld	a5,0(s1)
    80000b70:	00012717          	auipc	a4,0x12
    80000b74:	92f73023          	sd	a5,-1760(a4) # 80012490 <kmem+0x18>
  release(&kmem.lock);
    80000b78:	00012517          	auipc	a0,0x12
    80000b7c:	90050513          	addi	a0,a0,-1792 # 80012478 <kmem>
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
    80000b9e:	8de50513          	addi	a0,a0,-1826 # 80012478 <kmem>
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
    80000ea6:	273000ef          	jal	80001918 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();         // first user process

    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
  } else {
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000eaa:	00009717          	auipc	a4,0x9
    80000eae:	4c670713          	addi	a4,a4,1222 # 8000a370 <started>
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
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	1d450513          	addi	a0,a0,468 # 80007098 <etext+0x98>
    80000ecc:	e3eff0ef          	jal	8000050a <printk>
    kvminithart();  // turn on paging
    80000ed0:	086000ef          	jal	80000f56 <kvminithart>
    trapinithart(); // install kernel trap vector
    80000ed4:	654010ef          	jal	80002528 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ed8:	131040ef          	jal	80005808 <plicinithart>
  }

  scheduler();
    80000edc:	755000ef          	jal	80001e30 <scheduler>
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
    80000f10:	2d2000ef          	jal	800011e2 <kvminit>
    kvminithart();      // turn on paging
    80000f14:	042000ef          	jal	80000f56 <kvminithart>
    procinit();         // process table
    80000f18:	14b000ef          	jal	80001862 <procinit>
    shminit();          // shared memory initialization
    80000f1c:	4ab010ef          	jal	80002bc6 <shminit>
    trapinit();         // trap vectors
    80000f20:	5e4010ef          	jal	80002504 <trapinit>
    trapinithart();     // install kernel trap vector
    80000f24:	604010ef          	jal	80002528 <trapinithart>
    plicinit();         // set up interrupt controller
    80000f28:	0c7040ef          	jal	800057ee <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f2c:	0dd040ef          	jal	80005808 <plicinithart>
    binit();            // buffer cache
    80000f30:	57f010ef          	jal	80002cae <binit>
    iinit();            // inode table
    80000f34:	2d0020ef          	jal	80003204 <iinit>
    fileinit();         // file table
    80000f38:	2fe030ef          	jal	80004236 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f3c:	1c3040ef          	jal	800058fe <virtio_disk_init>
    userinit();         // first user process
    80000f40:	4fb000ef          	jal	80001c3a <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000f44:	00009797          	auipc	a5,0x9
    80000f48:	42c78793          	addi	a5,a5,1068 # 8000a370 <started>
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
    80000f62:	00009797          	auipc	a5,0x9
    80000f66:	4167b783          	ld	a5,1046(a5) # 8000a378 <kernel_pagetable>
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
    80000fe8:	00006517          	auipc	a0,0x6
    80000fec:	0c850513          	addi	a0,a0,200 # 800070b0 <etext+0xb0>
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
    800010c0:	00006517          	auipc	a0,0x6
    800010c4:	ff850513          	addi	a0,a0,-8 # 800070b8 <etext+0xb8>
    800010c8:	f6cff0ef          	jal	80000834 <panic>
    panic("mappages: size not aligned");
    800010cc:	00006517          	auipc	a0,0x6
    800010d0:	00c50513          	addi	a0,a0,12 # 800070d8 <etext+0xd8>
    800010d4:	f60ff0ef          	jal	80000834 <panic>
    panic("mappages: size");
    800010d8:	00006517          	auipc	a0,0x6
    800010dc:	02050513          	addi	a0,a0,32 # 800070f8 <etext+0xf8>
    800010e0:	f54ff0ef          	jal	80000834 <panic>
      panic("mappages: remap");
    800010e4:	00006517          	auipc	a0,0x6
    800010e8:	02450513          	addi	a0,a0,36 # 80007108 <etext+0x108>
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
    80001128:	00006517          	auipc	a0,0x6
    8000112c:	ff050513          	addi	a0,a0,-16 # 80007118 <etext+0x118>
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
    80001180:	80006697          	auipc	a3,0x80006
    80001184:	e8068693          	addi	a3,a3,-384 # 7000 <_entry-0x7fff9000>
    80001188:	4605                	li	a2,1
    8000118a:	067e                	slli	a2,a2,0x1f
    8000118c:	85b2                	mv	a1,a2
    8000118e:	8526                	mv	a0,s1
    80001190:	f7dff0ef          	jal	8000110c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext,
    80001194:	4719                	li	a4,6
    80001196:	00006697          	auipc	a3,0x6
    8000119a:	e6a68693          	addi	a3,a3,-406 # 80007000 <etext>
    8000119e:	47c5                	li	a5,17
    800011a0:	07ee                	slli	a5,a5,0x1b
    800011a2:	40d786b3          	sub	a3,a5,a3
    800011a6:	00006617          	auipc	a2,0x6
    800011aa:	e5a60613          	addi	a2,a2,-422 # 80007000 <etext>
    800011ae:	85b2                	mv	a1,a2
    800011b0:	8526                	mv	a0,s1
    800011b2:	f5bff0ef          	jal	8000110c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011b6:	4729                	li	a4,10
    800011b8:	6685                	lui	a3,0x1
    800011ba:	00005617          	auipc	a2,0x5
    800011be:	e4660613          	addi	a2,a2,-442 # 80006000 <_trampoline>
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
    800011ee:	00009797          	auipc	a5,0x9
    800011f2:	18a7b523          	sd	a0,394(a5) # 8000a378 <kernel_pagetable>
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
    8000125e:	00006517          	auipc	a0,0x6
    80001262:	ec250513          	addi	a0,a0,-318 # 80007120 <etext+0x120>
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
    800013b4:	00006517          	auipc	a0,0x6
    800013b8:	d8450513          	addi	a0,a0,-636 # 80007138 <etext+0x138>
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
    800014e2:	00006517          	auipc	a0,0x6
    800014e6:	c6650513          	addi	a0,a0,-922 # 80007148 <etext+0x148>
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
    80001728:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb940>
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
    800017d8:	00011497          	auipc	s1,0x11
    800017dc:	0f048493          	addi	s1,s1,240 # 800128c8 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800017e0:	8c26                	mv	s8,s1
    800017e2:	000a57b7          	lui	a5,0xa5
    800017e6:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    800017ea:	07b2                	slli	a5,a5,0xc
    800017ec:	fa578793          	addi	a5,a5,-91
    800017f0:	4fa50937          	lui	s2,0x4fa50
    800017f4:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    800017f8:	1902                	slli	s2,s2,0x20
    800017fa:	993e                	add	s2,s2,a5
    800017fc:	040009b7          	lui	s3,0x4000
    80001800:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001802:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001804:	4b99                	li	s7,6
    80001806:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    80001808:	00017a97          	auipc	s5,0x17
    8000180c:	ac0a8a93          	addi	s5,s5,-1344 # 800182c8 <tickslock>
    char *pa = kalloc();
    80001810:	b3eff0ef          	jal	80000b4e <kalloc>
    80001814:	862a                	mv	a2,a0
    if (pa == 0)
    80001816:	c121                	beqz	a0,80001856 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    80001818:	418485b3          	sub	a1,s1,s8
    8000181c:	858d                	srai	a1,a1,0x3
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
    80001836:	16848493          	addi	s1,s1,360
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
    80001856:	00006517          	auipc	a0,0x6
    8000185a:	90250513          	addi	a0,a0,-1790 # 80007158 <etext+0x158>
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
    80001876:	00006597          	auipc	a1,0x6
    8000187a:	8ea58593          	addi	a1,a1,-1814 # 80007160 <etext+0x160>
    8000187e:	00011517          	auipc	a0,0x11
    80001882:	c1a50513          	addi	a0,a0,-998 # 80012498 <pid_lock>
    80001886:	b22ff0ef          	jal	80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    8000188a:	00006597          	auipc	a1,0x6
    8000188e:	8de58593          	addi	a1,a1,-1826 # 80007168 <etext+0x168>
    80001892:	00011517          	auipc	a0,0x11
    80001896:	c1e50513          	addi	a0,a0,-994 # 800124b0 <wait_lock>
    8000189a:	b0eff0ef          	jal	80000ba8 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000189e:	00011497          	auipc	s1,0x11
    800018a2:	02a48493          	addi	s1,s1,42 # 800128c8 <proc>
    initlock(&p->lock, "proc");
    800018a6:	00006b17          	auipc	s6,0x6
    800018aa:	8d2b0b13          	addi	s6,s6,-1838 # 80007178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    800018ae:	8aa6                	mv	s5,s1
    800018b0:	000a57b7          	lui	a5,0xa5
    800018b4:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    800018b8:	07b2                	slli	a5,a5,0xc
    800018ba:	fa578793          	addi	a5,a5,-91
    800018be:	4fa50937          	lui	s2,0x4fa50
    800018c2:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    800018c6:	1902                	slli	s2,s2,0x20
    800018c8:	993e                	add	s2,s2,a5
    800018ca:	040009b7          	lui	s3,0x4000
    800018ce:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018d0:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    800018d2:	00017a17          	auipc	s4,0x17
    800018d6:	9f6a0a13          	addi	s4,s4,-1546 # 800182c8 <tickslock>
    initlock(&p->lock, "proc");
    800018da:	85da                	mv	a1,s6
    800018dc:	8526                	mv	a0,s1
    800018de:	acaff0ef          	jal	80000ba8 <initlock>
    p->state = UNUSED;
    800018e2:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    800018e6:	415487b3          	sub	a5,s1,s5
    800018ea:	878d                	srai	a5,a5,0x3
    800018ec:	032787b3          	mul	a5,a5,s2
    800018f0:	07b6                	slli	a5,a5,0xd
    800018f2:	6709                	lui	a4,0x2
    800018f4:	9fb9                	addw	a5,a5,a4
    800018f6:	40f987b3          	sub	a5,s3,a5
    800018fa:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    800018fc:	16848493          	addi	s1,s1,360
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
    8000193a:	00011517          	auipc	a0,0x11
    8000193e:	b8e50513          	addi	a0,a0,-1138 # 800124c8 <cpus>
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
    80001960:	00011717          	auipc	a4,0x11
    80001964:	b3870713          	addi	a4,a4,-1224 # 80012498 <pid_lock>
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
    80001992:	00009797          	auipc	a5,0x9
    80001996:	99e7a783          	lw	a5,-1634(a5) # 8000a330 <first.1>
    8000199a:	cf85                	beqz	a5,800019d2 <forkret+0x54>
    first = 0;
    8000199c:	00009797          	auipc	a5,0x9
    800019a0:	9807aa23          	sw	zero,-1644(a5) # 8000a330 <first.1>

    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800019a4:	4505                	li	a0,1
    800019a6:	563010ef          	jal	80003708 <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    800019aa:	00005797          	auipc	a5,0x5
    800019ae:	7d678793          	addi	a5,a5,2006 # 80007180 <etext+0x180>
    800019b2:	fcf43823          	sd	a5,-48(s0)
    800019b6:	fc043c23          	sd	zero,-40(s0)
    800019ba:	fd040593          	addi	a1,s0,-48
    800019be:	853e                	mv	a0,a5
    800019c0:	7fd020ef          	jal	800049bc <kexec>
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
    800019d2:	373000ef          	jal	80002544 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800019d6:	68a8                	ld	a0,80(s1)
    800019d8:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800019da:	04000737          	lui	a4,0x4000
    800019de:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800019e0:	0732                	slli	a4,a4,0xc
    800019e2:	00004797          	auipc	a5,0x4
    800019e6:	6ba78793          	addi	a5,a5,1722 # 8000609c <userret>
    800019ea:	00004697          	auipc	a3,0x4
    800019ee:	61668693          	addi	a3,a3,1558 # 80006000 <_trampoline>
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
    80001a08:	00005517          	auipc	a0,0x5
    80001a0c:	78050513          	addi	a0,a0,1920 # 80007188 <etext+0x188>
    80001a10:	e25fe0ef          	jal	80000834 <panic>

0000000080001a14 <allocpid>:
{
    80001a14:	1101                	addi	sp,sp,-32
    80001a16:	ec06                	sd	ra,24(sp)
    80001a18:	e822                	sd	s0,16(sp)
    80001a1a:	e426                	sd	s1,8(sp)
    80001a1c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a1e:	00011517          	auipc	a0,0x11
    80001a22:	a7a50513          	addi	a0,a0,-1414 # 80012498 <pid_lock>
    80001a26:	a02ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a2a:	00009797          	auipc	a5,0x9
    80001a2e:	90a78793          	addi	a5,a5,-1782 # 8000a334 <nextpid>
    80001a32:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a34:	0014871b          	addiw	a4,s1,1
    80001a38:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a3a:	00011517          	auipc	a0,0x11
    80001a3e:	a5e50513          	addi	a0,a0,-1442 # 80012498 <pid_lock>
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
    80001a6a:	00004697          	auipc	a3,0x4
    80001a6e:	59668693          	addi	a3,a3,1430 # 80006000 <_trampoline>
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
  pte_t *pte = walk(pagetable, SHM_VA, 0);
    80001ae6:	4601                	li	a2,0
    80001ae8:	040005b7          	lui	a1,0x4000
    80001aec:	15f5                	addi	a1,a1,-3 # 3fffffd <_entry-0x7c000003>
    80001aee:	05b2                	slli	a1,a1,0xc
    80001af0:	c92ff0ef          	jal	80000f82 <walk>
  if (pte && (*pte & PTE_V))
    80001af4:	c501                	beqz	a0,80001afc <proc_freepagetable+0x26>
    80001af6:	611c                	ld	a5,0(a0)
    80001af8:	8b85                	andi	a5,a5,1
    80001afa:	ef8d                	bnez	a5,80001b34 <proc_freepagetable+0x5e>
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001afc:	4681                	li	a3,0
    80001afe:	4605                	li	a2,1
    80001b00:	040005b7          	lui	a1,0x4000
    80001b04:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b06:	05b2                	slli	a1,a1,0xc
    80001b08:	8526                	mv	a0,s1
    80001b0a:	f1aff0ef          	jal	80001224 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b0e:	4681                	li	a3,0
    80001b10:	4605                	li	a2,1
    80001b12:	020005b7          	lui	a1,0x2000
    80001b16:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b18:	05b6                	slli	a1,a1,0xd
    80001b1a:	8526                	mv	a0,s1
    80001b1c:	f08ff0ef          	jal	80001224 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b20:	85ca                	mv	a1,s2
    80001b22:	8526                	mv	a0,s1
    80001b24:	8d5ff0ef          	jal	800013f8 <uvmfree>
}
    80001b28:	60e2                	ld	ra,24(sp)
    80001b2a:	6442                	ld	s0,16(sp)
    80001b2c:	64a2                	ld	s1,8(sp)
    80001b2e:	6902                	ld	s2,0(sp)
    80001b30:	6105                	addi	sp,sp,32
    80001b32:	8082                	ret
    uvmunmap(pagetable, SHM_VA, 1, 0);
    80001b34:	4681                	li	a3,0
    80001b36:	4605                	li	a2,1
    80001b38:	040005b7          	lui	a1,0x4000
    80001b3c:	15f5                	addi	a1,a1,-3 # 3fffffd <_entry-0x7c000003>
    80001b3e:	05b2                	slli	a1,a1,0xc
    80001b40:	8526                	mv	a0,s1
    80001b42:	ee2ff0ef          	jal	80001224 <uvmunmap>
    80001b46:	bf5d                	j	80001afc <proc_freepagetable+0x26>

0000000080001b48 <freeproc>:
{
    80001b48:	1101                	addi	sp,sp,-32
    80001b4a:	ec06                	sd	ra,24(sp)
    80001b4c:	e822                	sd	s0,16(sp)
    80001b4e:	e426                	sd	s1,8(sp)
    80001b50:	1000                	addi	s0,sp,32
    80001b52:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b54:	6d28                	ld	a0,88(a0)
    80001b56:	c119                	beqz	a0,80001b5c <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001b58:	f0ffe0ef          	jal	80000a66 <kfree>
  p->trapframe = 0;
    80001b5c:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001b60:	68a8                	ld	a0,80(s1)
    80001b62:	c501                	beqz	a0,80001b6a <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b64:	64ac                	ld	a1,72(s1)
    80001b66:	f71ff0ef          	jal	80001ad6 <proc_freepagetable>
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
  p->state = UNUSED;
    80001b86:	0004ac23          	sw	zero,24(s1)
}
    80001b8a:	60e2                	ld	ra,24(sp)
    80001b8c:	6442                	ld	s0,16(sp)
    80001b8e:	64a2                	ld	s1,8(sp)
    80001b90:	6105                	addi	sp,sp,32
    80001b92:	8082                	ret

0000000080001b94 <allocproc>:
{
    80001b94:	1101                	addi	sp,sp,-32
    80001b96:	ec06                	sd	ra,24(sp)
    80001b98:	e822                	sd	s0,16(sp)
    80001b9a:	e426                	sd	s1,8(sp)
    80001b9c:	e04a                	sd	s2,0(sp)
    80001b9e:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001ba0:	00011497          	auipc	s1,0x11
    80001ba4:	d2848493          	addi	s1,s1,-728 # 800128c8 <proc>
    80001ba8:	00016917          	auipc	s2,0x16
    80001bac:	72090913          	addi	s2,s2,1824 # 800182c8 <tickslock>
    acquire(&p->lock);
    80001bb0:	8526                	mv	a0,s1
    80001bb2:	876ff0ef          	jal	80000c28 <acquire>
    if (p->state == UNUSED) {
    80001bb6:	4c9c                	lw	a5,24(s1)
    80001bb8:	cb91                	beqz	a5,80001bcc <allocproc+0x38>
      release(&p->lock);
    80001bba:	8526                	mv	a0,s1
    80001bbc:	8f4ff0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001bc0:	16848493          	addi	s1,s1,360
    80001bc4:	ff2496e3          	bne	s1,s2,80001bb0 <allocproc+0x1c>
  return 0;
    80001bc8:	4481                	li	s1,0
    80001bca:	a089                	j	80001c0c <allocproc+0x78>
  p->pid = allocpid();
    80001bcc:	e49ff0ef          	jal	80001a14 <allocpid>
    80001bd0:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bd2:	4785                	li	a5,1
    80001bd4:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001bd6:	f79fe0ef          	jal	80000b4e <kalloc>
    80001bda:	892a                	mv	s2,a0
    80001bdc:	eca8                	sd	a0,88(s1)
    80001bde:	cd15                	beqz	a0,80001c1a <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001be0:	8526                	mv	a0,s1
    80001be2:	e71ff0ef          	jal	80001a52 <proc_pagetable>
    80001be6:	892a                	mv	s2,a0
    80001be8:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001bea:	c121                	beqz	a0,80001c2a <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001bec:	07000613          	li	a2,112
    80001bf0:	4581                	li	a1,0
    80001bf2:	06048513          	addi	a0,s1,96
    80001bf6:	8f2ff0ef          	jal	80000ce8 <memset>
  p->context.ra = (uint64)forkret;
    80001bfa:	00000797          	auipc	a5,0x0
    80001bfe:	d8478793          	addi	a5,a5,-636 # 8000197e <forkret>
    80001c02:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c04:	60bc                	ld	a5,64(s1)
    80001c06:	6705                	lui	a4,0x1
    80001c08:	97ba                	add	a5,a5,a4
    80001c0a:	f4bc                	sd	a5,104(s1)
}
    80001c0c:	8526                	mv	a0,s1
    80001c0e:	60e2                	ld	ra,24(sp)
    80001c10:	6442                	ld	s0,16(sp)
    80001c12:	64a2                	ld	s1,8(sp)
    80001c14:	6902                	ld	s2,0(sp)
    80001c16:	6105                	addi	sp,sp,32
    80001c18:	8082                	ret
    freeproc(p);
    80001c1a:	8526                	mv	a0,s1
    80001c1c:	f2dff0ef          	jal	80001b48 <freeproc>
    release(&p->lock);
    80001c20:	8526                	mv	a0,s1
    80001c22:	88eff0ef          	jal	80000cb0 <release>
    return 0;
    80001c26:	84ca                	mv	s1,s2
    80001c28:	b7d5                	j	80001c0c <allocproc+0x78>
    freeproc(p);
    80001c2a:	8526                	mv	a0,s1
    80001c2c:	f1dff0ef          	jal	80001b48 <freeproc>
    release(&p->lock);
    80001c30:	8526                	mv	a0,s1
    80001c32:	87eff0ef          	jal	80000cb0 <release>
    return 0;
    80001c36:	84ca                	mv	s1,s2
    80001c38:	bfd1                	j	80001c0c <allocproc+0x78>

0000000080001c3a <userinit>:
{
    80001c3a:	1101                	addi	sp,sp,-32
    80001c3c:	ec06                	sd	ra,24(sp)
    80001c3e:	e822                	sd	s0,16(sp)
    80001c40:	e426                	sd	s1,8(sp)
    80001c42:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c44:	f51ff0ef          	jal	80001b94 <allocproc>
    80001c48:	84aa                	mv	s1,a0
  initproc = p;
    80001c4a:	00008797          	auipc	a5,0x8
    80001c4e:	72a7bb23          	sd	a0,1846(a5) # 8000a380 <initproc>
  p->cwd = namei("/");
    80001c52:	00005517          	auipc	a0,0x5
    80001c56:	53e50513          	addi	a0,a0,1342 # 80007190 <etext+0x190>
    80001c5a:	00c020ef          	jal	80003c66 <namei>
    80001c5e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c62:	478d                	li	a5,3
    80001c64:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c66:	8526                	mv	a0,s1
    80001c68:	848ff0ef          	jal	80000cb0 <release>
}
    80001c6c:	60e2                	ld	ra,24(sp)
    80001c6e:	6442                	ld	s0,16(sp)
    80001c70:	64a2                	ld	s1,8(sp)
    80001c72:	6105                	addi	sp,sp,32
    80001c74:	8082                	ret

0000000080001c76 <growproc>:
{
    80001c76:	1101                	addi	sp,sp,-32
    80001c78:	ec06                	sd	ra,24(sp)
    80001c7a:	e822                	sd	s0,16(sp)
    80001c7c:	e426                	sd	s1,8(sp)
    80001c7e:	e04a                	sd	s2,0(sp)
    80001c80:	1000                	addi	s0,sp,32
    80001c82:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c84:	cc9ff0ef          	jal	8000194c <myproc>
    80001c88:	892a                	mv	s2,a0
  sz = p->sz;
    80001c8a:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001c8c:	02905963          	blez	s1,80001cbe <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001c90:	00b48633          	add	a2,s1,a1
    80001c94:	020007b7          	lui	a5,0x2000
    80001c98:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c9a:	07b6                	slli	a5,a5,0xd
    80001c9c:	02c7ea63          	bltu	a5,a2,80001cd0 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001ca0:	4691                	li	a3,4
    80001ca2:	6928                	ld	a0,80(a0)
    80001ca4:	e4eff0ef          	jal	800012f2 <uvmalloc>
    80001ca8:	85aa                	mv	a1,a0
    80001caa:	c50d                	beqz	a0,80001cd4 <growproc+0x5e>
  p->sz = sz;
    80001cac:	04b93423          	sd	a1,72(s2)
  return 0;
    80001cb0:	4501                	li	a0,0
}
    80001cb2:	60e2                	ld	ra,24(sp)
    80001cb4:	6442                	ld	s0,16(sp)
    80001cb6:	64a2                	ld	s1,8(sp)
    80001cb8:	6902                	ld	s2,0(sp)
    80001cba:	6105                	addi	sp,sp,32
    80001cbc:	8082                	ret
  } else if (n < 0) {
    80001cbe:	fe04d7e3          	bgez	s1,80001cac <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001cc2:	00b48633          	add	a2,s1,a1
    80001cc6:	6928                	ld	a0,80(a0)
    80001cc8:	de6ff0ef          	jal	800012ae <uvmdealloc>
    80001ccc:	85aa                	mv	a1,a0
    80001cce:	bff9                	j	80001cac <growproc+0x36>
      return -1;
    80001cd0:	557d                	li	a0,-1
    80001cd2:	b7c5                	j	80001cb2 <growproc+0x3c>
      return -1;
    80001cd4:	557d                	li	a0,-1
    80001cd6:	bff1                	j	80001cb2 <growproc+0x3c>

0000000080001cd8 <kfork>:
{
    80001cd8:	7139                	addi	sp,sp,-64
    80001cda:	fc06                	sd	ra,56(sp)
    80001cdc:	f822                	sd	s0,48(sp)
    80001cde:	f426                	sd	s1,40(sp)
    80001ce0:	e456                	sd	s5,8(sp)
    80001ce2:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001ce4:	c69ff0ef          	jal	8000194c <myproc>
    80001ce8:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001cea:	eabff0ef          	jal	80001b94 <allocproc>
    80001cee:	12050f63          	beqz	a0,80001e2c <kfork+0x154>
    80001cf2:	e852                	sd	s4,16(sp)
    80001cf4:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001cf6:	048ab603          	ld	a2,72(s5)
    80001cfa:	692c                	ld	a1,80(a0)
    80001cfc:	050ab503          	ld	a0,80(s5)
    80001d00:	f2aff0ef          	jal	8000142a <uvmcopy>
    80001d04:	06054663          	bltz	a0,80001d70 <kfork+0x98>
  np->sz = p->sz;
    80001d08:	048ab783          	ld	a5,72(s5)
    80001d0c:	04fa3423          	sd	a5,72(s4)
  pte_t *shm_pte = walk(p->pagetable, SHM_VA, 0);
    80001d10:	4601                	li	a2,0
    80001d12:	040005b7          	lui	a1,0x4000
    80001d16:	15f5                	addi	a1,a1,-3 # 3fffffd <_entry-0x7c000003>
    80001d18:	05b2                	slli	a1,a1,0xc
    80001d1a:	050ab503          	ld	a0,80(s5)
    80001d1e:	a64ff0ef          	jal	80000f82 <walk>
  if (shm_pte && (*shm_pte & PTE_V)) {
    80001d22:	c509                	beqz	a0,80001d2c <kfork+0x54>
    80001d24:	611c                	ld	a5,0(a0)
    80001d26:	0017f713          	andi	a4,a5,1
    80001d2a:	ef21                	bnez	a4,80001d82 <kfork+0xaa>
    80001d2c:	f04a                	sd	s2,32(sp)
    80001d2e:	ec4e                	sd	s3,24(sp)
  *(np->trapframe) = *(p->trapframe);
    80001d30:	058ab683          	ld	a3,88(s5)
    80001d34:	87b6                	mv	a5,a3
    80001d36:	058a3703          	ld	a4,88(s4)
    80001d3a:	12068693          	addi	a3,a3,288
    80001d3e:	6388                	ld	a0,0(a5)
    80001d40:	678c                	ld	a1,8(a5)
    80001d42:	6b90                	ld	a2,16(a5)
    80001d44:	e308                	sd	a0,0(a4)
    80001d46:	e70c                	sd	a1,8(a4)
    80001d48:	eb10                	sd	a2,16(a4)
    80001d4a:	6f90                	ld	a2,24(a5)
    80001d4c:	ef10                	sd	a2,24(a4)
    80001d4e:	02078793          	addi	a5,a5,32
    80001d52:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d56:	fed794e3          	bne	a5,a3,80001d3e <kfork+0x66>
  np->trapframe->a0 = 0;
    80001d5a:	058a3783          	ld	a5,88(s4)
    80001d5e:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001d62:	0d0a8493          	addi	s1,s5,208
    80001d66:	0d0a0913          	addi	s2,s4,208
    80001d6a:	150a8993          	addi	s3,s5,336
    80001d6e:	a0a9                	j	80001db8 <kfork+0xe0>
    freeproc(np);
    80001d70:	8552                	mv	a0,s4
    80001d72:	dd7ff0ef          	jal	80001b48 <freeproc>
    release(&np->lock);
    80001d76:	8552                	mv	a0,s4
    80001d78:	f39fe0ef          	jal	80000cb0 <release>
    return -1;
    80001d7c:	54fd                	li	s1,-1
    80001d7e:	6a42                	ld	s4,16(sp)
    80001d80:	a879                	j	80001e1e <kfork+0x146>
    uint64 pa = PTE2PA(*shm_pte);
    80001d82:	83a9                	srli	a5,a5,0xa
    if (mappages(np->pagetable, SHM_VA, PGSIZE, pa, PTE_R | PTE_W | PTE_U) != 0) {
    80001d84:	4759                	li	a4,22
    80001d86:	00c79693          	slli	a3,a5,0xc
    80001d8a:	6605                	lui	a2,0x1
    80001d8c:	040005b7          	lui	a1,0x4000
    80001d90:	15f5                	addi	a1,a1,-3 # 3fffffd <_entry-0x7c000003>
    80001d92:	05b2                	slli	a1,a1,0xc
    80001d94:	050a3503          	ld	a0,80(s4)
    80001d98:	abeff0ef          	jal	80001056 <mappages>
    80001d9c:	d941                	beqz	a0,80001d2c <kfork+0x54>
      freeproc(np);
    80001d9e:	8552                	mv	a0,s4
    80001da0:	da9ff0ef          	jal	80001b48 <freeproc>
      release(&np->lock);
    80001da4:	8552                	mv	a0,s4
    80001da6:	f0bfe0ef          	jal	80000cb0 <release>
      return -1;
    80001daa:	54fd                	li	s1,-1
    80001dac:	6a42                	ld	s4,16(sp)
    80001dae:	a885                	j	80001e1e <kfork+0x146>
  for (i = 0; i < NOFILE; i++)
    80001db0:	04a1                	addi	s1,s1,8
    80001db2:	0921                	addi	s2,s2,8
    80001db4:	01348963          	beq	s1,s3,80001dc6 <kfork+0xee>
    if (p->ofile[i])
    80001db8:	6088                	ld	a0,0(s1)
    80001dba:	d97d                	beqz	a0,80001db0 <kfork+0xd8>
      np->ofile[i] = filedup(p->ofile[i]);
    80001dbc:	4fc020ef          	jal	800042b8 <filedup>
    80001dc0:	00a93023          	sd	a0,0(s2)
    80001dc4:	b7f5                	j	80001db0 <kfork+0xd8>
  np->cwd = idup(p->cwd);
    80001dc6:	150ab503          	ld	a0,336(s5)
    80001dca:	5cc010ef          	jal	80003396 <idup>
    80001dce:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001dd2:	4641                	li	a2,16
    80001dd4:	158a8593          	addi	a1,s5,344
    80001dd8:	158a0513          	addi	a0,s4,344
    80001ddc:	860ff0ef          	jal	80000e3c <safestrcpy>
  pid = np->pid;
    80001de0:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001de4:	8552                	mv	a0,s4
    80001de6:	ecbfe0ef          	jal	80000cb0 <release>
  acquire(&wait_lock);
    80001dea:	00010517          	auipc	a0,0x10
    80001dee:	6c650513          	addi	a0,a0,1734 # 800124b0 <wait_lock>
    80001df2:	e37fe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001df6:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001dfa:	00010517          	auipc	a0,0x10
    80001dfe:	6b650513          	addi	a0,a0,1718 # 800124b0 <wait_lock>
    80001e02:	eaffe0ef          	jal	80000cb0 <release>
  acquire(&np->lock);
    80001e06:	8552                	mv	a0,s4
    80001e08:	e21fe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001e0c:	478d                	li	a5,3
    80001e0e:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e12:	8552                	mv	a0,s4
    80001e14:	e9dfe0ef          	jal	80000cb0 <release>
  return pid;
    80001e18:	7902                	ld	s2,32(sp)
    80001e1a:	69e2                	ld	s3,24(sp)
    80001e1c:	6a42                	ld	s4,16(sp)
}
    80001e1e:	8526                	mv	a0,s1
    80001e20:	70e2                	ld	ra,56(sp)
    80001e22:	7442                	ld	s0,48(sp)
    80001e24:	74a2                	ld	s1,40(sp)
    80001e26:	6aa2                	ld	s5,8(sp)
    80001e28:	6121                	addi	sp,sp,64
    80001e2a:	8082                	ret
    return -1;
    80001e2c:	54fd                	li	s1,-1
    80001e2e:	bfc5                	j	80001e1e <kfork+0x146>

0000000080001e30 <scheduler>:
{
    80001e30:	711d                	addi	sp,sp,-96
    80001e32:	ec86                	sd	ra,88(sp)
    80001e34:	e8a2                	sd	s0,80(sp)
    80001e36:	e4a6                	sd	s1,72(sp)
    80001e38:	e0ca                	sd	s2,64(sp)
    80001e3a:	fc4e                	sd	s3,56(sp)
    80001e3c:	f852                	sd	s4,48(sp)
    80001e3e:	f456                	sd	s5,40(sp)
    80001e40:	f05a                	sd	s6,32(sp)
    80001e42:	ec5e                	sd	s7,24(sp)
    80001e44:	e862                	sd	s8,16(sp)
    80001e46:	e466                	sd	s9,8(sp)
    80001e48:	1080                	addi	s0,sp,96
    80001e4a:	8792                	mv	a5,tp
  int id = r_tp();
    80001e4c:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001e4e:	00779a93          	slli	s5,a5,0x7
    80001e52:	00010717          	auipc	a4,0x10
    80001e56:	64670713          	addi	a4,a4,1606 # 80012498 <pid_lock>
    80001e5a:	9756                	add	a4,a4,s5
    80001e5c:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001e60:	00010717          	auipc	a4,0x10
    80001e64:	67070713          	addi	a4,a4,1648 # 800124d0 <cpus+0x8>
    80001e68:	9aba                	add	s5,s5,a4
        p->state = RUNNING;
    80001e6a:	4c11                	li	s8,4
        c->proc = p;
    80001e6c:	00010b17          	auipc	s6,0x10
    80001e70:	62cb0b13          	addi	s6,s6,1580 # 80012498 <pid_lock>
    80001e74:	079e                	slli	a5,a5,0x7
    80001e76:	00fb0a33          	add	s4,s6,a5
        found = 1;
    80001e7a:	4b85                	li	s7,1
    80001e7c:	a0a9                	j	80001ec6 <scheduler+0x96>
      release(&p->lock);
    80001e7e:	8526                	mv	a0,s1
    80001e80:	e31fe0ef          	jal	80000cb0 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e84:	16848493          	addi	s1,s1,360
    80001e88:	03248b63          	beq	s1,s2,80001ebe <scheduler+0x8e>
      acquire(&p->lock);
    80001e8c:	8526                	mv	a0,s1
    80001e8e:	d9bfe0ef          	jal	80000c28 <acquire>
      if (p->state == RUNNABLE) {
    80001e92:	4c9c                	lw	a5,24(s1)
    80001e94:	ff3795e3          	bne	a5,s3,80001e7e <scheduler+0x4e>
        p->state = RUNNING;
    80001e98:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001e9c:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001ea0:	06048593          	addi	a1,s1,96
    80001ea4:	8556                	mv	a0,s5
    80001ea6:	5f4000ef          	jal	8000249a <swtch>
    80001eaa:	8792                	mv	a5,tp
        mycpu()->intena = 0;
    80001eac:	2781                	sext.w	a5,a5
    80001eae:	079e                	slli	a5,a5,0x7
    80001eb0:	97da                	add	a5,a5,s6
    80001eb2:	0a07a623          	sw	zero,172(a5)
        c->proc = 0;
    80001eb6:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001eba:	8cde                	mv	s9,s7
    80001ebc:	b7c9                	j	80001e7e <scheduler+0x4e>
    if (found == 0) {
    80001ebe:	000c9463          	bnez	s9,80001ec6 <scheduler+0x96>
      asm volatile("wfi");
    80001ec2:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001ec6:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001eca:	10017073          	csrci	sstatus,2
    int found = 0;
    80001ece:	4c81                	li	s9,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001ed0:	00011497          	auipc	s1,0x11
    80001ed4:	9f848493          	addi	s1,s1,-1544 # 800128c8 <proc>
      if (p->state == RUNNABLE) {
    80001ed8:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80001eda:	00016917          	auipc	s2,0x16
    80001ede:	3ee90913          	addi	s2,s2,1006 # 800182c8 <tickslock>
    80001ee2:	b76d                	j	80001e8c <scheduler+0x5c>

0000000080001ee4 <sched>:
{
    80001ee4:	7179                	addi	sp,sp,-48
    80001ee6:	f406                	sd	ra,40(sp)
    80001ee8:	f022                	sd	s0,32(sp)
    80001eea:	ec26                	sd	s1,24(sp)
    80001eec:	e84a                	sd	s2,16(sp)
    80001eee:	e44e                	sd	s3,8(sp)
    80001ef0:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001ef2:	a5bff0ef          	jal	8000194c <myproc>
    80001ef6:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001ef8:	ccbfe0ef          	jal	80000bc2 <holding>
    80001efc:	c935                	beqz	a0,80001f70 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80001efe:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001f00:	2781                	sext.w	a5,a5
    80001f02:	079e                	slli	a5,a5,0x7
    80001f04:	00010717          	auipc	a4,0x10
    80001f08:	59470713          	addi	a4,a4,1428 # 80012498 <pid_lock>
    80001f0c:	97ba                	add	a5,a5,a4
    80001f0e:	0a87a703          	lw	a4,168(a5)
    80001f12:	4785                	li	a5,1
    80001f14:	06f71463          	bne	a4,a5,80001f7c <sched+0x98>
  if (p->state == RUNNING)
    80001f18:	4c98                	lw	a4,24(s1)
    80001f1a:	4791                	li	a5,4
    80001f1c:	06f70663          	beq	a4,a5,80001f88 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001f20:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f24:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001f26:	e7bd                	bnez	a5,80001f94 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    80001f28:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f2a:	00010917          	auipc	s2,0x10
    80001f2e:	56e90913          	addi	s2,s2,1390 # 80012498 <pid_lock>
    80001f32:	2781                	sext.w	a5,a5
    80001f34:	079e                	slli	a5,a5,0x7
    80001f36:	97ca                	add	a5,a5,s2
    80001f38:	0ac7a983          	lw	s3,172(a5)
    80001f3c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f3e:	2781                	sext.w	a5,a5
    80001f40:	079e                	slli	a5,a5,0x7
    80001f42:	07a1                	addi	a5,a5,8
    80001f44:	00010597          	auipc	a1,0x10
    80001f48:	58458593          	addi	a1,a1,1412 # 800124c8 <cpus>
    80001f4c:	95be                	add	a1,a1,a5
    80001f4e:	06048513          	addi	a0,s1,96
    80001f52:	548000ef          	jal	8000249a <swtch>
    80001f56:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f58:	2781                	sext.w	a5,a5
    80001f5a:	079e                	slli	a5,a5,0x7
    80001f5c:	993e                	add	s2,s2,a5
    80001f5e:	0b392623          	sw	s3,172(s2)
}
    80001f62:	70a2                	ld	ra,40(sp)
    80001f64:	7402                	ld	s0,32(sp)
    80001f66:	64e2                	ld	s1,24(sp)
    80001f68:	6942                	ld	s2,16(sp)
    80001f6a:	69a2                	ld	s3,8(sp)
    80001f6c:	6145                	addi	sp,sp,48
    80001f6e:	8082                	ret
    panic("sched p->lock");
    80001f70:	00005517          	auipc	a0,0x5
    80001f74:	22850513          	addi	a0,a0,552 # 80007198 <etext+0x198>
    80001f78:	8bdfe0ef          	jal	80000834 <panic>
    panic("sched locks");
    80001f7c:	00005517          	auipc	a0,0x5
    80001f80:	22c50513          	addi	a0,a0,556 # 800071a8 <etext+0x1a8>
    80001f84:	8b1fe0ef          	jal	80000834 <panic>
    panic("sched RUNNING");
    80001f88:	00005517          	auipc	a0,0x5
    80001f8c:	23050513          	addi	a0,a0,560 # 800071b8 <etext+0x1b8>
    80001f90:	8a5fe0ef          	jal	80000834 <panic>
    panic("sched interruptible");
    80001f94:	00005517          	auipc	a0,0x5
    80001f98:	23450513          	addi	a0,a0,564 # 800071c8 <etext+0x1c8>
    80001f9c:	899fe0ef          	jal	80000834 <panic>

0000000080001fa0 <yield>:
{
    80001fa0:	1101                	addi	sp,sp,-32
    80001fa2:	ec06                	sd	ra,24(sp)
    80001fa4:	e822                	sd	s0,16(sp)
    80001fa6:	e426                	sd	s1,8(sp)
    80001fa8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001faa:	9a3ff0ef          	jal	8000194c <myproc>
    80001fae:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001fb0:	c79fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80001fb4:	478d                	li	a5,3
    80001fb6:	cc9c                	sw	a5,24(s1)
  sched();
    80001fb8:	f2dff0ef          	jal	80001ee4 <sched>
  release(&p->lock);
    80001fbc:	8526                	mv	a0,s1
    80001fbe:	cf3fe0ef          	jal	80000cb0 <release>
}
    80001fc2:	60e2                	ld	ra,24(sp)
    80001fc4:	6442                	ld	s0,16(sp)
    80001fc6:	64a2                	ld	s1,8(sp)
    80001fc8:	6105                	addi	sp,sp,32
    80001fca:	8082                	ret

0000000080001fcc <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80001fcc:	1101                	addi	sp,sp,-32
    80001fce:	ec06                	sd	ra,24(sp)
    80001fd0:	e822                	sd	s0,16(sp)
    80001fd2:	e426                	sd	s1,8(sp)
    80001fd4:	e04a                	sd	s2,0(sp)
    80001fd6:	1000                	addi	s0,sp,32
    80001fd8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001fda:	973ff0ef          	jal	8000194c <myproc>
    80001fde:	892a                	mv	s2,a0

  acquire(&p->lock);
    80001fe0:	c49fe0ef          	jal	80000c28 <acquire>
  if (chan == 0)
    80001fe4:	cc81                	beqz	s1,80001ffc <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80001fe6:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80001fea:	854a                	mv	a0,s2
    80001fec:	cc5fe0ef          	jal	80000cb0 <release>
}
    80001ff0:	60e2                	ld	ra,24(sp)
    80001ff2:	6442                	ld	s0,16(sp)
    80001ff4:	64a2                	ld	s1,8(sp)
    80001ff6:	6902                	ld	s2,0(sp)
    80001ff8:	6105                	addi	sp,sp,32
    80001ffa:	8082                	ret
    panic("sleep_prepare: zero chan");
    80001ffc:	00005517          	auipc	a0,0x5
    80002000:	1e450513          	addi	a0,a0,484 # 800071e0 <etext+0x1e0>
    80002004:	831fe0ef          	jal	80000834 <panic>

0000000080002008 <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    80002008:	1101                	addi	sp,sp,-32
    8000200a:	ec06                	sd	ra,24(sp)
    8000200c:	e822                	sd	s0,16(sp)
    8000200e:	e426                	sd	s1,8(sp)
    80002010:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002012:	93bff0ef          	jal	8000194c <myproc>
    80002016:	84aa                	mv	s1,a0

  acquire(&p->lock);
    80002018:	c11fe0ef          	jal	80000c28 <acquire>
  if (p->chan != 0) {
    8000201c:	709c                	ld	a5,32(s1)
    8000201e:	c789                	beqz	a5,80002028 <sleep+0x20>
    p->state = SLEEPING;
    80002020:	4789                	li	a5,2
    80002022:	cc9c                	sw	a5,24(s1)
    sched();
    80002024:	ec1ff0ef          	jal	80001ee4 <sched>
  }
  release(&p->lock);
    80002028:	8526                	mv	a0,s1
    8000202a:	c87fe0ef          	jal	80000cb0 <release>
}
    8000202e:	60e2                	ld	ra,24(sp)
    80002030:	6442                	ld	s0,16(sp)
    80002032:	64a2                	ld	s1,8(sp)
    80002034:	6105                	addi	sp,sp,32
    80002036:	8082                	ret

0000000080002038 <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    80002038:	7139                	addi	sp,sp,-64
    8000203a:	fc06                	sd	ra,56(sp)
    8000203c:	f822                	sd	s0,48(sp)
    8000203e:	f426                	sd	s1,40(sp)
    80002040:	f04a                	sd	s2,32(sp)
    80002042:	ec4e                	sd	s3,24(sp)
    80002044:	e852                	sd	s4,16(sp)
    80002046:	e456                	sd	s5,8(sp)
    80002048:	0080                	addi	s0,sp,64
    8000204a:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    8000204c:	00011497          	auipc	s1,0x11
    80002050:	87c48493          	addi	s1,s1,-1924 # 800128c8 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    80002054:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80002056:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80002058:	00016997          	auipc	s3,0x16
    8000205c:	27098993          	addi	s3,s3,624 # 800182c8 <tickslock>
    80002060:	a801                	j	80002070 <wakeup+0x38>
      }
    }
    release(&p->lock);
    80002062:	8526                	mv	a0,s1
    80002064:	c4dfe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002068:	16848493          	addi	s1,s1,360
    8000206c:	03348063          	beq	s1,s3,8000208c <wakeup+0x54>
    acquire(&p->lock);
    80002070:	8526                	mv	a0,s1
    80002072:	bb7fe0ef          	jal	80000c28 <acquire>
    if (p->chan == chan) {
    80002076:	709c                	ld	a5,32(s1)
    80002078:	ff2795e3          	bne	a5,s2,80002062 <wakeup+0x2a>
      p->chan = 0;
    8000207c:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    80002080:	4c9c                	lw	a5,24(s1)
    80002082:	ff4790e3          	bne	a5,s4,80002062 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002086:	0154ac23          	sw	s5,24(s1)
    8000208a:	bfe1                	j	80002062 <wakeup+0x2a>
  }
}
    8000208c:	70e2                	ld	ra,56(sp)
    8000208e:	7442                	ld	s0,48(sp)
    80002090:	74a2                	ld	s1,40(sp)
    80002092:	7902                	ld	s2,32(sp)
    80002094:	69e2                	ld	s3,24(sp)
    80002096:	6a42                	ld	s4,16(sp)
    80002098:	6aa2                	ld	s5,8(sp)
    8000209a:	6121                	addi	sp,sp,64
    8000209c:	8082                	ret

000000008000209e <reparent>:
{
    8000209e:	7179                	addi	sp,sp,-48
    800020a0:	f406                	sd	ra,40(sp)
    800020a2:	f022                	sd	s0,32(sp)
    800020a4:	ec26                	sd	s1,24(sp)
    800020a6:	e84a                	sd	s2,16(sp)
    800020a8:	e44e                	sd	s3,8(sp)
    800020aa:	e052                	sd	s4,0(sp)
    800020ac:	1800                	addi	s0,sp,48
    800020ae:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800020b0:	00011497          	auipc	s1,0x11
    800020b4:	81848493          	addi	s1,s1,-2024 # 800128c8 <proc>
      pp->parent = initproc;
    800020b8:	00008a17          	auipc	s4,0x8
    800020bc:	2c8a0a13          	addi	s4,s4,712 # 8000a380 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800020c0:	00016997          	auipc	s3,0x16
    800020c4:	20898993          	addi	s3,s3,520 # 800182c8 <tickslock>
    800020c8:	a029                	j	800020d2 <reparent+0x34>
    800020ca:	16848493          	addi	s1,s1,360
    800020ce:	01348b63          	beq	s1,s3,800020e4 <reparent+0x46>
    if (pp->parent == p) {
    800020d2:	7c9c                	ld	a5,56(s1)
    800020d4:	ff279be3          	bne	a5,s2,800020ca <reparent+0x2c>
      pp->parent = initproc;
    800020d8:	000a3503          	ld	a0,0(s4)
    800020dc:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800020de:	f5bff0ef          	jal	80002038 <wakeup>
    800020e2:	b7e5                	j	800020ca <reparent+0x2c>
}
    800020e4:	70a2                	ld	ra,40(sp)
    800020e6:	7402                	ld	s0,32(sp)
    800020e8:	64e2                	ld	s1,24(sp)
    800020ea:	6942                	ld	s2,16(sp)
    800020ec:	69a2                	ld	s3,8(sp)
    800020ee:	6a02                	ld	s4,0(sp)
    800020f0:	6145                	addi	sp,sp,48
    800020f2:	8082                	ret

00000000800020f4 <kexit>:
{
    800020f4:	7179                	addi	sp,sp,-48
    800020f6:	f406                	sd	ra,40(sp)
    800020f8:	f022                	sd	s0,32(sp)
    800020fa:	ec26                	sd	s1,24(sp)
    800020fc:	e84a                	sd	s2,16(sp)
    800020fe:	e44e                	sd	s3,8(sp)
    80002100:	e052                	sd	s4,0(sp)
    80002102:	1800                	addi	s0,sp,48
    80002104:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002106:	847ff0ef          	jal	8000194c <myproc>
    8000210a:	89aa                	mv	s3,a0
  if (p == initproc)
    8000210c:	00008797          	auipc	a5,0x8
    80002110:	2747b783          	ld	a5,628(a5) # 8000a380 <initproc>
    80002114:	0d050493          	addi	s1,a0,208
    80002118:	15050913          	addi	s2,a0,336
    8000211c:	00a79b63          	bne	a5,a0,80002132 <kexit+0x3e>
    panic("init exiting");
    80002120:	00005517          	auipc	a0,0x5
    80002124:	0e050513          	addi	a0,a0,224 # 80007200 <etext+0x200>
    80002128:	f0cfe0ef          	jal	80000834 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    8000212c:	04a1                	addi	s1,s1,8
    8000212e:	01248963          	beq	s1,s2,80002140 <kexit+0x4c>
    if (p->ofile[fd]) {
    80002132:	6088                	ld	a0,0(s1)
    80002134:	dd65                	beqz	a0,8000212c <kexit+0x38>
      fileclose(f);
    80002136:	1c8020ef          	jal	800042fe <fileclose>
      p->ofile[fd] = 0;
    8000213a:	0004b023          	sd	zero,0(s1)
    8000213e:	b7fd                	j	8000212c <kexit+0x38>
  begin_op();
    80002140:	505010ef          	jal	80003e44 <begin_op>
  iput(p->cwd);
    80002144:	1509b503          	ld	a0,336(s3)
    80002148:	406010ef          	jal	8000354e <iput>
  end_op();
    8000214c:	585010ef          	jal	80003ed0 <end_op>
  p->cwd = 0;
    80002150:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002154:	00010517          	auipc	a0,0x10
    80002158:	35c50513          	addi	a0,a0,860 # 800124b0 <wait_lock>
    8000215c:	acdfe0ef          	jal	80000c28 <acquire>
  reparent(p);
    80002160:	854e                	mv	a0,s3
    80002162:	f3dff0ef          	jal	8000209e <reparent>
  wakeup(p->parent);
    80002166:	0389b503          	ld	a0,56(s3)
    8000216a:	ecfff0ef          	jal	80002038 <wakeup>
  acquire(&p->lock);
    8000216e:	854e                	mv	a0,s3
    80002170:	ab9fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    80002174:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002178:	4795                	li	a5,5
    8000217a:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000217e:	00010517          	auipc	a0,0x10
    80002182:	33250513          	addi	a0,a0,818 # 800124b0 <wait_lock>
    80002186:	b2bfe0ef          	jal	80000cb0 <release>
  sched();
    8000218a:	d5bff0ef          	jal	80001ee4 <sched>
  panic("zombie exit");
    8000218e:	00005517          	auipc	a0,0x5
    80002192:	08250513          	addi	a0,a0,130 # 80007210 <etext+0x210>
    80002196:	e9efe0ef          	jal	80000834 <panic>

000000008000219a <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    8000219a:	c525                	beqz	a0,80002202 <kkill+0x68>
{
    8000219c:	7179                	addi	sp,sp,-48
    8000219e:	f406                	sd	ra,40(sp)
    800021a0:	f022                	sd	s0,32(sp)
    800021a2:	ec26                	sd	s1,24(sp)
    800021a4:	e84a                	sd	s2,16(sp)
    800021a6:	e44e                	sd	s3,8(sp)
    800021a8:	1800                	addi	s0,sp,48
    800021aa:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    800021ac:	00010497          	auipc	s1,0x10
    800021b0:	71c48493          	addi	s1,s1,1820 # 800128c8 <proc>
    800021b4:	00016997          	auipc	s3,0x16
    800021b8:	11498993          	addi	s3,s3,276 # 800182c8 <tickslock>
    acquire(&p->lock);
    800021bc:	8526                	mv	a0,s1
    800021be:	a6bfe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid) {
    800021c2:	589c                	lw	a5,48(s1)
    800021c4:	01278b63          	beq	a5,s2,800021da <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800021c8:	8526                	mv	a0,s1
    800021ca:	ae7fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800021ce:	16848493          	addi	s1,s1,360
    800021d2:	ff3495e3          	bne	s1,s3,800021bc <kkill+0x22>
  }
  return -1;
    800021d6:	557d                	li	a0,-1
    800021d8:	a819                	j	800021ee <kkill+0x54>
      p->killed = 1;
    800021da:	4785                	li	a5,1
    800021dc:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    800021de:	4c98                	lw	a4,24(s1)
    800021e0:	4789                	li	a5,2
    800021e2:	00f70d63          	beq	a4,a5,800021fc <kkill+0x62>
      release(&p->lock);
    800021e6:	8526                	mv	a0,s1
    800021e8:	ac9fe0ef          	jal	80000cb0 <release>
      return 0;
    800021ec:	4501                	li	a0,0
}
    800021ee:	70a2                	ld	ra,40(sp)
    800021f0:	7402                	ld	s0,32(sp)
    800021f2:	64e2                	ld	s1,24(sp)
    800021f4:	6942                	ld	s2,16(sp)
    800021f6:	69a2                	ld	s3,8(sp)
    800021f8:	6145                	addi	sp,sp,48
    800021fa:	8082                	ret
        p->state = RUNNABLE;
    800021fc:	478d                	li	a5,3
    800021fe:	cc9c                	sw	a5,24(s1)
    80002200:	b7dd                	j	800021e6 <kkill+0x4c>
    return -1;
    80002202:	557d                	li	a0,-1
}
    80002204:	8082                	ret

0000000080002206 <setkilled>:

void
setkilled(struct proc *p)
{
    80002206:	1101                	addi	sp,sp,-32
    80002208:	ec06                	sd	ra,24(sp)
    8000220a:	e822                	sd	s0,16(sp)
    8000220c:	e426                	sd	s1,8(sp)
    8000220e:	1000                	addi	s0,sp,32
    80002210:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002212:	a17fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    80002216:	4785                	li	a5,1
    80002218:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000221a:	8526                	mv	a0,s1
    8000221c:	a95fe0ef          	jal	80000cb0 <release>
}
    80002220:	60e2                	ld	ra,24(sp)
    80002222:	6442                	ld	s0,16(sp)
    80002224:	64a2                	ld	s1,8(sp)
    80002226:	6105                	addi	sp,sp,32
    80002228:	8082                	ret

000000008000222a <killed>:

int
killed(struct proc *p)
{
    8000222a:	1101                	addi	sp,sp,-32
    8000222c:	ec06                	sd	ra,24(sp)
    8000222e:	e822                	sd	s0,16(sp)
    80002230:	e426                	sd	s1,8(sp)
    80002232:	e04a                	sd	s2,0(sp)
    80002234:	1000                	addi	s0,sp,32
    80002236:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002238:	9f1fe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    8000223c:	549c                	lw	a5,40(s1)
    8000223e:	893e                	mv	s2,a5
  release(&p->lock);
    80002240:	8526                	mv	a0,s1
    80002242:	a6ffe0ef          	jal	80000cb0 <release>
  return k;
}
    80002246:	854a                	mv	a0,s2
    80002248:	60e2                	ld	ra,24(sp)
    8000224a:	6442                	ld	s0,16(sp)
    8000224c:	64a2                	ld	s1,8(sp)
    8000224e:	6902                	ld	s2,0(sp)
    80002250:	6105                	addi	sp,sp,32
    80002252:	8082                	ret

0000000080002254 <kwait>:
{
    80002254:	715d                	addi	sp,sp,-80
    80002256:	e486                	sd	ra,72(sp)
    80002258:	e0a2                	sd	s0,64(sp)
    8000225a:	fc26                	sd	s1,56(sp)
    8000225c:	f84a                	sd	s2,48(sp)
    8000225e:	f44e                	sd	s3,40(sp)
    80002260:	f052                	sd	s4,32(sp)
    80002262:	ec56                	sd	s5,24(sp)
    80002264:	e85a                	sd	s6,16(sp)
    80002266:	e45e                	sd	s7,8(sp)
    80002268:	0880                	addi	s0,sp,80
    8000226a:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    8000226c:	ee0ff0ef          	jal	8000194c <myproc>
    80002270:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002272:	00010517          	auipc	a0,0x10
    80002276:	23e50513          	addi	a0,a0,574 # 800124b0 <wait_lock>
    8000227a:	9affe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    8000227e:	4a15                	li	s4,5
        havekids = 1;
    80002280:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002282:	00016997          	auipc	s3,0x16
    80002286:	04698993          	addi	s3,s3,70 # 800182c8 <tickslock>
    release(&wait_lock);
    8000228a:	00010b17          	auipc	s6,0x10
    8000228e:	226b0b13          	addi	s6,s6,550 # 800124b0 <wait_lock>
    80002292:	a845                	j	80002342 <kwait+0xee>
          pid = pp->pid;
    80002294:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    80002298:	000b8e63          	beqz	s7,800022b4 <kwait+0x60>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    8000229c:	4711                	li	a4,4
    8000229e:	02c48693          	addi	a3,s1,44
    800022a2:	865e                	mv	a2,s7
    800022a4:	04893583          	ld	a1,72(s2)
    800022a8:	05093503          	ld	a0,80(s2)
    800022ac:	adaff0ef          	jal	80001586 <copyout>
          if (addr != 0 &&
    800022b0:	02054c63          	bltz	a0,800022e8 <kwait+0x94>
          pp->parent = 0;
    800022b4:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    800022b8:	8526                	mv	a0,s1
    800022ba:	88fff0ef          	jal	80001b48 <freeproc>
          release(&pp->lock);
    800022be:	8526                	mv	a0,s1
    800022c0:	9f1fe0ef          	jal	80000cb0 <release>
          release(&wait_lock);
    800022c4:	00010517          	auipc	a0,0x10
    800022c8:	1ec50513          	addi	a0,a0,492 # 800124b0 <wait_lock>
    800022cc:	9e5fe0ef          	jal	80000cb0 <release>
}
    800022d0:	854e                	mv	a0,s3
    800022d2:	60a6                	ld	ra,72(sp)
    800022d4:	6406                	ld	s0,64(sp)
    800022d6:	74e2                	ld	s1,56(sp)
    800022d8:	7942                	ld	s2,48(sp)
    800022da:	79a2                	ld	s3,40(sp)
    800022dc:	7a02                	ld	s4,32(sp)
    800022de:	6ae2                	ld	s5,24(sp)
    800022e0:	6b42                	ld	s6,16(sp)
    800022e2:	6ba2                	ld	s7,8(sp)
    800022e4:	6161                	addi	sp,sp,80
    800022e6:	8082                	ret
            release(&pp->lock);
    800022e8:	8526                	mv	a0,s1
    800022ea:	9c7fe0ef          	jal	80000cb0 <release>
            release(&wait_lock);
    800022ee:	00010517          	auipc	a0,0x10
    800022f2:	1c250513          	addi	a0,a0,450 # 800124b0 <wait_lock>
    800022f6:	9bbfe0ef          	jal	80000cb0 <release>
            return -1;
    800022fa:	59fd                	li	s3,-1
    800022fc:	bfd1                	j	800022d0 <kwait+0x7c>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800022fe:	16848493          	addi	s1,s1,360
    80002302:	03348063          	beq	s1,s3,80002322 <kwait+0xce>
      if (pp->parent == p) {
    80002306:	7c9c                	ld	a5,56(s1)
    80002308:	ff279be3          	bne	a5,s2,800022fe <kwait+0xaa>
        acquire(&pp->lock);
    8000230c:	8526                	mv	a0,s1
    8000230e:	91bfe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    80002312:	4c9c                	lw	a5,24(s1)
    80002314:	f94780e3          	beq	a5,s4,80002294 <kwait+0x40>
        release(&pp->lock);
    80002318:	8526                	mv	a0,s1
    8000231a:	997fe0ef          	jal	80000cb0 <release>
        havekids = 1;
    8000231e:	8756                	mv	a4,s5
    80002320:	bff9                	j	800022fe <kwait+0xaa>
    if (!havekids || killed(p)) {
    80002322:	c715                	beqz	a4,8000234e <kwait+0xfa>
    80002324:	854a                	mv	a0,s2
    80002326:	f05ff0ef          	jal	8000222a <killed>
    8000232a:	e115                	bnez	a0,8000234e <kwait+0xfa>
    sleep_prepare(p); //DOC: wait-sleep
    8000232c:	854a                	mv	a0,s2
    8000232e:	c9fff0ef          	jal	80001fcc <sleep_prepare>
    release(&wait_lock);
    80002332:	855a                	mv	a0,s6
    80002334:	97dfe0ef          	jal	80000cb0 <release>
    sleep();
    80002338:	cd1ff0ef          	jal	80002008 <sleep>
    acquire(&wait_lock);
    8000233c:	855a                	mv	a0,s6
    8000233e:	8ebfe0ef          	jal	80000c28 <acquire>
    havekids = 0;
    80002342:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002344:	00010497          	auipc	s1,0x10
    80002348:	58448493          	addi	s1,s1,1412 # 800128c8 <proc>
    8000234c:	bf6d                	j	80002306 <kwait+0xb2>
      release(&wait_lock);
    8000234e:	00010517          	auipc	a0,0x10
    80002352:	16250513          	addi	a0,a0,354 # 800124b0 <wait_lock>
    80002356:	95bfe0ef          	jal	80000cb0 <release>
      return -1;
    8000235a:	59fd                	li	s3,-1
    8000235c:	bf95                	j	800022d0 <kwait+0x7c>

000000008000235e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000235e:	7179                	addi	sp,sp,-48
    80002360:	f406                	sd	ra,40(sp)
    80002362:	f022                	sd	s0,32(sp)
    80002364:	ec26                	sd	s1,24(sp)
    80002366:	e84a                	sd	s2,16(sp)
    80002368:	e44e                	sd	s3,8(sp)
    8000236a:	e052                	sd	s4,0(sp)
    8000236c:	1800                	addi	s0,sp,48
    8000236e:	84aa                	mv	s1,a0
    80002370:	8a2e                	mv	s4,a1
    80002372:	89b2                	mv	s3,a2
    80002374:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002376:	dd6ff0ef          	jal	8000194c <myproc>
  if (user_dst) {
    8000237a:	c085                	beqz	s1,8000239a <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    8000237c:	874a                	mv	a4,s2
    8000237e:	86ce                	mv	a3,s3
    80002380:	8652                	mv	a2,s4
    80002382:	652c                	ld	a1,72(a0)
    80002384:	6928                	ld	a0,80(a0)
    80002386:	a00ff0ef          	jal	80001586 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000238a:	70a2                	ld	ra,40(sp)
    8000238c:	7402                	ld	s0,32(sp)
    8000238e:	64e2                	ld	s1,24(sp)
    80002390:	6942                	ld	s2,16(sp)
    80002392:	69a2                	ld	s3,8(sp)
    80002394:	6a02                	ld	s4,0(sp)
    80002396:	6145                	addi	sp,sp,48
    80002398:	8082                	ret
    memmove((char *)dst, src, len);
    8000239a:	0009061b          	sext.w	a2,s2
    8000239e:	85ce                	mv	a1,s3
    800023a0:	8552                	mv	a0,s4
    800023a2:	9a7fe0ef          	jal	80000d48 <memmove>
    return 0;
    800023a6:	8526                	mv	a0,s1
    800023a8:	b7cd                	j	8000238a <either_copyout+0x2c>

00000000800023aa <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800023aa:	7179                	addi	sp,sp,-48
    800023ac:	f406                	sd	ra,40(sp)
    800023ae:	f022                	sd	s0,32(sp)
    800023b0:	ec26                	sd	s1,24(sp)
    800023b2:	e84a                	sd	s2,16(sp)
    800023b4:	e44e                	sd	s3,8(sp)
    800023b6:	e052                	sd	s4,0(sp)
    800023b8:	1800                	addi	s0,sp,48
    800023ba:	8a2a                	mv	s4,a0
    800023bc:	84ae                	mv	s1,a1
    800023be:	89b2                	mv	s3,a2
    800023c0:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800023c2:	d8aff0ef          	jal	8000194c <myproc>
  if (user_src) {
    800023c6:	c085                	beqz	s1,800023e6 <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    800023c8:	874a                	mv	a4,s2
    800023ca:	86ce                	mv	a3,s3
    800023cc:	8652                	mv	a2,s4
    800023ce:	652c                	ld	a1,72(a0)
    800023d0:	6928                	ld	a0,80(a0)
    800023d2:	a7aff0ef          	jal	8000164c <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800023d6:	70a2                	ld	ra,40(sp)
    800023d8:	7402                	ld	s0,32(sp)
    800023da:	64e2                	ld	s1,24(sp)
    800023dc:	6942                	ld	s2,16(sp)
    800023de:	69a2                	ld	s3,8(sp)
    800023e0:	6a02                	ld	s4,0(sp)
    800023e2:	6145                	addi	sp,sp,48
    800023e4:	8082                	ret
    memmove(dst, (char *)src, len);
    800023e6:	0009061b          	sext.w	a2,s2
    800023ea:	85ce                	mv	a1,s3
    800023ec:	8552                	mv	a0,s4
    800023ee:	95bfe0ef          	jal	80000d48 <memmove>
    return 0;
    800023f2:	8526                	mv	a0,s1
    800023f4:	b7cd                	j	800023d6 <either_copyin+0x2c>

00000000800023f6 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800023f6:	715d                	addi	sp,sp,-80
    800023f8:	e486                	sd	ra,72(sp)
    800023fa:	e0a2                	sd	s0,64(sp)
    800023fc:	fc26                	sd	s1,56(sp)
    800023fe:	f84a                	sd	s2,48(sp)
    80002400:	f44e                	sd	s3,40(sp)
    80002402:	f052                	sd	s4,32(sp)
    80002404:	ec56                	sd	s5,24(sp)
    80002406:	e85a                	sd	s6,16(sp)
    80002408:	e45e                	sd	s7,8(sp)
    8000240a:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    8000240c:	00005517          	auipc	a0,0x5
    80002410:	c6c50513          	addi	a0,a0,-916 # 80007078 <etext+0x78>
    80002414:	8f6fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002418:	00010497          	auipc	s1,0x10
    8000241c:	60848493          	addi	s1,s1,1544 # 80012a20 <proc+0x158>
    80002420:	00016917          	auipc	s2,0x16
    80002424:	00090913          	mv	s2,s2
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002428:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000242a:	00005997          	auipc	s3,0x5
    8000242e:	df698993          	addi	s3,s3,-522 # 80007220 <etext+0x220>
    printk("%d %s %s", p->pid, state, p->name);
    80002432:	00005a97          	auipc	s5,0x5
    80002436:	df6a8a93          	addi	s5,s5,-522 # 80007228 <etext+0x228>
    printk("\n");
    8000243a:	00005a17          	auipc	s4,0x5
    8000243e:	c3ea0a13          	addi	s4,s4,-962 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002442:	00005b97          	auipc	s7,0x5
    80002446:	30eb8b93          	addi	s7,s7,782 # 80007750 <states.0>
    8000244a:	a829                	j	80002464 <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    8000244c:	ed86a583          	lw	a1,-296(a3)
    80002450:	8556                	mv	a0,s5
    80002452:	8b8fe0ef          	jal	8000050a <printk>
    printk("\n");
    80002456:	8552                	mv	a0,s4
    80002458:	8b2fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000245c:	16848493          	addi	s1,s1,360
    80002460:	03248263          	beq	s1,s2,80002484 <procdump+0x8e>
    if (p->state == UNUSED)
    80002464:	86a6                	mv	a3,s1
    80002466:	ec04a783          	lw	a5,-320(s1)
    8000246a:	dbed                	beqz	a5,8000245c <procdump+0x66>
      state = "???";
    8000246c:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000246e:	fcfb6fe3          	bltu	s6,a5,8000244c <procdump+0x56>
    80002472:	02079713          	slli	a4,a5,0x20
    80002476:	01d75793          	srli	a5,a4,0x1d
    8000247a:	97de                	add	a5,a5,s7
    8000247c:	6390                	ld	a2,0(a5)
    8000247e:	f679                	bnez	a2,8000244c <procdump+0x56>
      state = "???";
    80002480:	864e                	mv	a2,s3
    80002482:	b7e9                	j	8000244c <procdump+0x56>
  }
}
    80002484:	60a6                	ld	ra,72(sp)
    80002486:	6406                	ld	s0,64(sp)
    80002488:	74e2                	ld	s1,56(sp)
    8000248a:	7942                	ld	s2,48(sp)
    8000248c:	79a2                	ld	s3,40(sp)
    8000248e:	7a02                	ld	s4,32(sp)
    80002490:	6ae2                	ld	s5,24(sp)
    80002492:	6b42                	ld	s6,16(sp)
    80002494:	6ba2                	ld	s7,8(sp)
    80002496:	6161                	addi	sp,sp,80
    80002498:	8082                	ret

000000008000249a <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000249a:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    8000249e:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800024a2:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800024a4:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800024a6:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800024aa:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800024ae:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800024b2:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800024b6:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800024ba:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800024be:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800024c2:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800024c6:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800024ca:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800024ce:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800024d2:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800024d6:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800024d8:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800024da:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800024de:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800024e2:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800024e6:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800024ea:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800024ee:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800024f2:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800024f6:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800024fa:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800024fe:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002502:	8082                	ret

0000000080002504 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002504:	1141                	addi	sp,sp,-16
    80002506:	e406                	sd	ra,8(sp)
    80002508:	e022                	sd	s0,0(sp)
    8000250a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000250c:	00005597          	auipc	a1,0x5
    80002510:	d5c58593          	addi	a1,a1,-676 # 80007268 <etext+0x268>
    80002514:	00016517          	auipc	a0,0x16
    80002518:	db450513          	addi	a0,a0,-588 # 800182c8 <tickslock>
    8000251c:	e8cfe0ef          	jal	80000ba8 <initlock>
}
    80002520:	60a2                	ld	ra,8(sp)
    80002522:	6402                	ld	s0,0(sp)
    80002524:	0141                	addi	sp,sp,16
    80002526:	8082                	ret

0000000080002528 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002528:	1141                	addi	sp,sp,-16
    8000252a:	e406                	sd	ra,8(sp)
    8000252c:	e022                	sd	s0,0(sp)
    8000252e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002530:	00003797          	auipc	a5,0x3
    80002534:	26078793          	addi	a5,a5,608 # 80005790 <kernelvec>
    80002538:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000253c:	60a2                	ld	ra,8(sp)
    8000253e:	6402                	ld	s0,0(sp)
    80002540:	0141                	addi	sp,sp,16
    80002542:	8082                	ret

0000000080002544 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002544:	1141                	addi	sp,sp,-16
    80002546:	e406                	sd	ra,8(sp)
    80002548:	e022                	sd	s0,0(sp)
    8000254a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000254c:	c00ff0ef          	jal	8000194c <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80002550:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002554:	04000737          	lui	a4,0x4000
    80002558:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000255a:	0732                	slli	a4,a4,0xc
    8000255c:	00004797          	auipc	a5,0x4
    80002560:	aa478793          	addi	a5,a5,-1372 # 80006000 <_trampoline>
    80002564:	00004697          	auipc	a3,0x4
    80002568:	a9c68693          	addi	a3,a3,-1380 # 80006000 <_trampoline>
    8000256c:	8f95                	sub	a5,a5,a3
    8000256e:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002570:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002574:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    80002576:	18002773          	csrr	a4,satp
    8000257a:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000257c:	6d38                	ld	a4,88(a0)
    8000257e:	613c                	ld	a5,64(a0)
    80002580:	6685                	lui	a3,0x1
    80002582:	97b6                	add	a5,a5,a3
    80002584:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002586:	6d3c                	ld	a5,88(a0)
    80002588:	00000717          	auipc	a4,0x0
    8000258c:	0fc70713          	addi	a4,a4,252 # 80002684 <usertrap>
    80002590:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002592:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    80002594:	8712                	mv	a4,tp
    80002596:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002598:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000259c:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800025a0:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800025a4:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800025a8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    800025aa:	6f9c                	ld	a5,24(a5)
    800025ac:	14179073          	csrw	sepc,a5
}
    800025b0:	60a2                	ld	ra,8(sp)
    800025b2:	6402                	ld	s0,0(sp)
    800025b4:	0141                	addi	sp,sp,16
    800025b6:	8082                	ret

00000000800025b8 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800025b8:	1141                	addi	sp,sp,-16
    800025ba:	e406                	sd	ra,8(sp)
    800025bc:	e022                	sd	s0,0(sp)
    800025be:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    800025c0:	b58ff0ef          	jal	80001918 <cpuid>
    800025c4:	cd11                	beqz	a0,800025e0 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    800025c6:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800025ca:	000f4737          	lui	a4,0xf4
    800025ce:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800025d2:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    800025d4:	14d79073          	csrw	stimecmp,a5
}
    800025d8:	60a2                	ld	ra,8(sp)
    800025da:	6402                	ld	s0,0(sp)
    800025dc:	0141                	addi	sp,sp,16
    800025de:	8082                	ret
    acquire(&tickslock);
    800025e0:	00016517          	auipc	a0,0x16
    800025e4:	ce850513          	addi	a0,a0,-792 # 800182c8 <tickslock>
    800025e8:	e40fe0ef          	jal	80000c28 <acquire>
    ticks++;
    800025ec:	00008717          	auipc	a4,0x8
    800025f0:	d9c70713          	addi	a4,a4,-612 # 8000a388 <ticks>
    800025f4:	431c                	lw	a5,0(a4)
    800025f6:	2785                	addiw	a5,a5,1
    800025f8:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    800025fa:	853a                	mv	a0,a4
    800025fc:	a3dff0ef          	jal	80002038 <wakeup>
    release(&tickslock);
    80002600:	00016517          	auipc	a0,0x16
    80002604:	cc850513          	addi	a0,a0,-824 # 800182c8 <tickslock>
    80002608:	ea8fe0ef          	jal	80000cb0 <release>
    8000260c:	bf6d                	j	800025c6 <clockintr+0xe>

000000008000260e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000260e:	1101                	addi	sp,sp,-32
    80002610:	ec06                	sd	ra,24(sp)
    80002612:	e822                	sd	s0,16(sp)
    80002614:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    80002616:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    8000261a:	57fd                	li	a5,-1
    8000261c:	17fe                	slli	a5,a5,0x3f
    8000261e:	07a5                	addi	a5,a5,9
    80002620:	00f70c63          	beq	a4,a5,80002638 <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    80002624:	57fd                	li	a5,-1
    80002626:	17fe                	slli	a5,a5,0x3f
    80002628:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000262a:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    8000262c:	04f70863          	beq	a4,a5,8000267c <devintr+0x6e>
  }
}
    80002630:	60e2                	ld	ra,24(sp)
    80002632:	6442                	ld	s0,16(sp)
    80002634:	6105                	addi	sp,sp,32
    80002636:	8082                	ret
    80002638:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000263a:	204030ef          	jal	8000583e <plic_claim>
    8000263e:	872a                	mv	a4,a0
    80002640:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    80002642:	47a9                	li	a5,10
    80002644:	00f50963          	beq	a0,a5,80002656 <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    80002648:	4785                	li	a5,1
    8000264a:	00f50963          	beq	a0,a5,8000265c <devintr+0x4e>
    return 1;
    8000264e:	4505                	li	a0,1
    } else if (irq) {
    80002650:	eb09                	bnez	a4,80002662 <devintr+0x54>
    80002652:	64a2                	ld	s1,8(sp)
    80002654:	bff1                	j	80002630 <devintr+0x22>
      uartintr();
    80002656:	b98fe0ef          	jal	800009ee <uartintr>
    if (irq)
    8000265a:	a819                	j	80002670 <devintr+0x62>
      virtio_disk_intr();
    8000265c:	69e030ef          	jal	80005cfa <virtio_disk_intr>
    if (irq)
    80002660:	a801                	j	80002670 <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    80002662:	85ba                	mv	a1,a4
    80002664:	00005517          	auipc	a0,0x5
    80002668:	c0c50513          	addi	a0,a0,-1012 # 80007270 <etext+0x270>
    8000266c:	e9ffd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    80002670:	8526                	mv	a0,s1
    80002672:	1ee030ef          	jal	80005860 <plic_complete>
    return 1;
    80002676:	4505                	li	a0,1
    80002678:	64a2                	ld	s1,8(sp)
    8000267a:	bf5d                	j	80002630 <devintr+0x22>
    clockintr();
    8000267c:	f3dff0ef          	jal	800025b8 <clockintr>
    return 2;
    80002680:	4509                	li	a0,2
    80002682:	b77d                	j	80002630 <devintr+0x22>

0000000080002684 <usertrap>:
{
    80002684:	1101                	addi	sp,sp,-32
    80002686:	ec06                	sd	ra,24(sp)
    80002688:	e822                	sd	s0,16(sp)
    8000268a:	e426                	sd	s1,8(sp)
    8000268c:	e04a                	sd	s2,0(sp)
    8000268e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002690:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002694:	1007f793          	andi	a5,a5,256
    80002698:	eba5                	bnez	a5,80002708 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    8000269a:	00003797          	auipc	a5,0x3
    8000269e:	0f678793          	addi	a5,a5,246 # 80005790 <kernelvec>
    800026a2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800026a6:	aa6ff0ef          	jal	8000194c <myproc>
    800026aa:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800026ac:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    800026ae:	14102773          	csrr	a4,sepc
    800026b2:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    800026b4:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    800026b8:	47a1                	li	a5,8
    800026ba:	04f70d63          	beq	a4,a5,80002714 <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    800026be:	f51ff0ef          	jal	8000260e <devintr>
    800026c2:	892a                	mv	s2,a0
    800026c4:	e54d                	bnez	a0,8000276e <usertrap+0xea>
    800026c6:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    800026ca:	47bd                	li	a5,15
    800026cc:	08f70463          	beq	a4,a5,80002754 <usertrap+0xd0>
    800026d0:	14202773          	csrr	a4,scause
    800026d4:	47b5                	li	a5,13
    800026d6:	06f70f63          	beq	a4,a5,80002754 <usertrap+0xd0>
    800026da:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800026de:	5890                	lw	a2,48(s1)
    800026e0:	00005517          	auipc	a0,0x5
    800026e4:	bd050513          	addi	a0,a0,-1072 # 800072b0 <etext+0x2b0>
    800026e8:	e23fd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800026ec:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800026f0:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800026f4:	00005517          	auipc	a0,0x5
    800026f8:	bec50513          	addi	a0,a0,-1044 # 800072e0 <etext+0x2e0>
    800026fc:	e0ffd0ef          	jal	8000050a <printk>
    setkilled(p);
    80002700:	8526                	mv	a0,s1
    80002702:	b05ff0ef          	jal	80002206 <setkilled>
    80002706:	a015                	j	8000272a <usertrap+0xa6>
    panic("usertrap: not from user mode");
    80002708:	00005517          	auipc	a0,0x5
    8000270c:	b8850513          	addi	a0,a0,-1144 # 80007290 <etext+0x290>
    80002710:	924fe0ef          	jal	80000834 <panic>
    if (killed(p))
    80002714:	b17ff0ef          	jal	8000222a <killed>
    80002718:	e915                	bnez	a0,8000274c <usertrap+0xc8>
    p->trapframe->epc += 4;
    8000271a:	6cb8                	ld	a4,88(s1)
    8000271c:	6f1c                	ld	a5,24(a4)
    8000271e:	0791                	addi	a5,a5,4
    80002720:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80002722:	10016073          	csrsi	sstatus,2
    syscall();
    80002726:	244000ef          	jal	8000296a <syscall>
  if (killed(p))
    8000272a:	8526                	mv	a0,s1
    8000272c:	affff0ef          	jal	8000222a <killed>
    80002730:	e521                	bnez	a0,80002778 <usertrap+0xf4>
  prepare_return();
    80002732:	e13ff0ef          	jal	80002544 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002736:	68a8                	ld	a0,80(s1)
    80002738:	8131                	srli	a0,a0,0xc
    8000273a:	57fd                	li	a5,-1
    8000273c:	17fe                	slli	a5,a5,0x3f
    8000273e:	8d5d                	or	a0,a0,a5
}
    80002740:	60e2                	ld	ra,24(sp)
    80002742:	6442                	ld	s0,16(sp)
    80002744:	64a2                	ld	s1,8(sp)
    80002746:	6902                	ld	s2,0(sp)
    80002748:	6105                	addi	sp,sp,32
    8000274a:	8082                	ret
      kexit(-1);
    8000274c:	557d                	li	a0,-1
    8000274e:	9a7ff0ef          	jal	800020f4 <kexit>
    80002752:	b7e1                	j	8000271a <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    80002754:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    80002758:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    8000275c:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    8000275e:	0016b693          	seqz	a3,a3
    80002762:	64ac                	ld	a1,72(s1)
    80002764:	68a8                	ld	a0,80(s1)
    80002766:	da5fe0ef          	jal	8000150a <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    8000276a:	f161                	bnez	a0,8000272a <usertrap+0xa6>
    8000276c:	b7bd                	j	800026da <usertrap+0x56>
  if (killed(p))
    8000276e:	8526                	mv	a0,s1
    80002770:	abbff0ef          	jal	8000222a <killed>
    80002774:	c511                	beqz	a0,80002780 <usertrap+0xfc>
    80002776:	a011                	j	8000277a <usertrap+0xf6>
    80002778:	4901                	li	s2,0
    kexit(-1);
    8000277a:	557d                	li	a0,-1
    8000277c:	979ff0ef          	jal	800020f4 <kexit>
  if (which_dev == 2)
    80002780:	4789                	li	a5,2
    80002782:	faf918e3          	bne	s2,a5,80002732 <usertrap+0xae>
    yield();
    80002786:	81bff0ef          	jal	80001fa0 <yield>
    8000278a:	b765                	j	80002732 <usertrap+0xae>

000000008000278c <kerneltrap>:
{
    8000278c:	7179                	addi	sp,sp,-48
    8000278e:	f406                	sd	ra,40(sp)
    80002790:	f022                	sd	s0,32(sp)
    80002792:	ec26                	sd	s1,24(sp)
    80002794:	e84a                	sd	s2,16(sp)
    80002796:	e44e                	sd	s3,8(sp)
    80002798:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    8000279a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000279e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    800027a2:	142027f3          	csrr	a5,scause
    800027a6:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    800027a8:	1004f793          	andi	a5,s1,256
    800027ac:	c795                	beqz	a5,800027d8 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800027ae:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800027b2:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    800027b4:	eb85                	bnez	a5,800027e4 <kerneltrap+0x58>
  if ((which_dev = devintr()) == 0) {
    800027b6:	e59ff0ef          	jal	8000260e <devintr>
    800027ba:	c91d                	beqz	a0,800027f0 <kerneltrap+0x64>
  if (which_dev == 2 && myproc() != 0)
    800027bc:	4789                	li	a5,2
    800027be:	04f50a63          	beq	a0,a5,80002812 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    800027c2:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800027c6:	10049073          	csrw	sstatus,s1
}
    800027ca:	70a2                	ld	ra,40(sp)
    800027cc:	7402                	ld	s0,32(sp)
    800027ce:	64e2                	ld	s1,24(sp)
    800027d0:	6942                	ld	s2,16(sp)
    800027d2:	69a2                	ld	s3,8(sp)
    800027d4:	6145                	addi	sp,sp,48
    800027d6:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800027d8:	00005517          	auipc	a0,0x5
    800027dc:	b3050513          	addi	a0,a0,-1232 # 80007308 <etext+0x308>
    800027e0:	854fe0ef          	jal	80000834 <panic>
    panic("kerneltrap: interrupts enabled");
    800027e4:	00005517          	auipc	a0,0x5
    800027e8:	b4c50513          	addi	a0,a0,-1204 # 80007330 <etext+0x330>
    800027ec:	848fe0ef          	jal	80000834 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800027f0:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800027f4:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    800027f8:	85ce                	mv	a1,s3
    800027fa:	00005517          	auipc	a0,0x5
    800027fe:	b5650513          	addi	a0,a0,-1194 # 80007350 <etext+0x350>
    80002802:	d09fd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    80002806:	00005517          	auipc	a0,0x5
    8000280a:	b7250513          	addi	a0,a0,-1166 # 80007378 <etext+0x378>
    8000280e:	826fe0ef          	jal	80000834 <panic>
  if (which_dev == 2 && myproc() != 0)
    80002812:	93aff0ef          	jal	8000194c <myproc>
    80002816:	d555                	beqz	a0,800027c2 <kerneltrap+0x36>
    yield();
    80002818:	f88ff0ef          	jal	80001fa0 <yield>
    8000281c:	b75d                	j	800027c2 <kerneltrap+0x36>

000000008000281e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000281e:	1101                	addi	sp,sp,-32
    80002820:	ec06                	sd	ra,24(sp)
    80002822:	e822                	sd	s0,16(sp)
    80002824:	e426                	sd	s1,8(sp)
    80002826:	1000                	addi	s0,sp,32
    80002828:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000282a:	922ff0ef          	jal	8000194c <myproc>
  switch (n) {
    8000282e:	4795                	li	a5,5
    80002830:	0497e163          	bltu	a5,s1,80002872 <argraw+0x54>
    80002834:	048a                	slli	s1,s1,0x2
    80002836:	00005717          	auipc	a4,0x5
    8000283a:	f4a70713          	addi	a4,a4,-182 # 80007780 <states.0+0x30>
    8000283e:	94ba                	add	s1,s1,a4
    80002840:	409c                	lw	a5,0(s1)
    80002842:	97ba                	add	a5,a5,a4
    80002844:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002846:	6d3c                	ld	a5,88(a0)
    80002848:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000284a:	60e2                	ld	ra,24(sp)
    8000284c:	6442                	ld	s0,16(sp)
    8000284e:	64a2                	ld	s1,8(sp)
    80002850:	6105                	addi	sp,sp,32
    80002852:	8082                	ret
    return p->trapframe->a1;
    80002854:	6d3c                	ld	a5,88(a0)
    80002856:	7fa8                	ld	a0,120(a5)
    80002858:	bfcd                	j	8000284a <argraw+0x2c>
    return p->trapframe->a2;
    8000285a:	6d3c                	ld	a5,88(a0)
    8000285c:	63c8                	ld	a0,128(a5)
    8000285e:	b7f5                	j	8000284a <argraw+0x2c>
    return p->trapframe->a3;
    80002860:	6d3c                	ld	a5,88(a0)
    80002862:	67c8                	ld	a0,136(a5)
    80002864:	b7dd                	j	8000284a <argraw+0x2c>
    return p->trapframe->a4;
    80002866:	6d3c                	ld	a5,88(a0)
    80002868:	6bc8                	ld	a0,144(a5)
    8000286a:	b7c5                	j	8000284a <argraw+0x2c>
    return p->trapframe->a5;
    8000286c:	6d3c                	ld	a5,88(a0)
    8000286e:	6fc8                	ld	a0,152(a5)
    80002870:	bfe9                	j	8000284a <argraw+0x2c>
  panic("argraw");
    80002872:	00005517          	auipc	a0,0x5
    80002876:	b1650513          	addi	a0,a0,-1258 # 80007388 <etext+0x388>
    8000287a:	fbbfd0ef          	jal	80000834 <panic>

000000008000287e <fetchaddr>:
{
    8000287e:	1101                	addi	sp,sp,-32
    80002880:	ec06                	sd	ra,24(sp)
    80002882:	e822                	sd	s0,16(sp)
    80002884:	e426                	sd	s1,8(sp)
    80002886:	e04a                	sd	s2,0(sp)
    80002888:	1000                	addi	s0,sp,32
    8000288a:	84aa                	mv	s1,a0
    8000288c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000288e:	8beff0ef          	jal	8000194c <myproc>
  if (addr >= p->sz ||
    80002892:	652c                	ld	a1,72(a0)
    80002894:	02b4f663          	bgeu	s1,a1,800028c0 <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002898:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    8000289c:	02f5e463          	bltu	a1,a5,800028c4 <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    800028a0:	4721                	li	a4,8
    800028a2:	86a6                	mv	a3,s1
    800028a4:	864a                	mv	a2,s2
    800028a6:	6928                	ld	a0,80(a0)
    800028a8:	da5fe0ef          	jal	8000164c <copyin>
    800028ac:	00a03533          	snez	a0,a0
    800028b0:	40a0053b          	negw	a0,a0
}
    800028b4:	60e2                	ld	ra,24(sp)
    800028b6:	6442                	ld	s0,16(sp)
    800028b8:	64a2                	ld	s1,8(sp)
    800028ba:	6902                	ld	s2,0(sp)
    800028bc:	6105                	addi	sp,sp,32
    800028be:	8082                	ret
    return -1;
    800028c0:	557d                	li	a0,-1
    800028c2:	bfcd                	j	800028b4 <fetchaddr+0x36>
    800028c4:	557d                	li	a0,-1
    800028c6:	b7fd                	j	800028b4 <fetchaddr+0x36>

00000000800028c8 <fetchstr>:
{
    800028c8:	7179                	addi	sp,sp,-48
    800028ca:	f406                	sd	ra,40(sp)
    800028cc:	f022                	sd	s0,32(sp)
    800028ce:	ec26                	sd	s1,24(sp)
    800028d0:	e84a                	sd	s2,16(sp)
    800028d2:	e44e                	sd	s3,8(sp)
    800028d4:	1800                	addi	s0,sp,48
    800028d6:	89aa                	mv	s3,a0
    800028d8:	84ae                	mv	s1,a1
    800028da:	8932                	mv	s2,a2
  struct proc *p = myproc();
    800028dc:	870ff0ef          	jal	8000194c <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    800028e0:	874a                	mv	a4,s2
    800028e2:	86ce                	mv	a3,s3
    800028e4:	8626                	mv	a2,s1
    800028e6:	652c                	ld	a1,72(a0)
    800028e8:	6928                	ld	a0,80(a0)
    800028ea:	dfffe0ef          	jal	800016e8 <copyinstr>
    800028ee:	00054c63          	bltz	a0,80002906 <fetchstr+0x3e>
  return strlen(buf);
    800028f2:	8526                	mv	a0,s1
    800028f4:	d7efe0ef          	jal	80000e72 <strlen>
}
    800028f8:	70a2                	ld	ra,40(sp)
    800028fa:	7402                	ld	s0,32(sp)
    800028fc:	64e2                	ld	s1,24(sp)
    800028fe:	6942                	ld	s2,16(sp)
    80002900:	69a2                	ld	s3,8(sp)
    80002902:	6145                	addi	sp,sp,48
    80002904:	8082                	ret
    return -1;
    80002906:	557d                	li	a0,-1
    80002908:	bfc5                	j	800028f8 <fetchstr+0x30>

000000008000290a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000290a:	1101                	addi	sp,sp,-32
    8000290c:	ec06                	sd	ra,24(sp)
    8000290e:	e822                	sd	s0,16(sp)
    80002910:	e426                	sd	s1,8(sp)
    80002912:	1000                	addi	s0,sp,32
    80002914:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002916:	f09ff0ef          	jal	8000281e <argraw>
    8000291a:	c088                	sw	a0,0(s1)
}
    8000291c:	60e2                	ld	ra,24(sp)
    8000291e:	6442                	ld	s0,16(sp)
    80002920:	64a2                	ld	s1,8(sp)
    80002922:	6105                	addi	sp,sp,32
    80002924:	8082                	ret

0000000080002926 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002926:	1101                	addi	sp,sp,-32
    80002928:	ec06                	sd	ra,24(sp)
    8000292a:	e822                	sd	s0,16(sp)
    8000292c:	e426                	sd	s1,8(sp)
    8000292e:	1000                	addi	s0,sp,32
    80002930:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002932:	eedff0ef          	jal	8000281e <argraw>
    80002936:	e088                	sd	a0,0(s1)
}
    80002938:	60e2                	ld	ra,24(sp)
    8000293a:	6442                	ld	s0,16(sp)
    8000293c:	64a2                	ld	s1,8(sp)
    8000293e:	6105                	addi	sp,sp,32
    80002940:	8082                	ret

0000000080002942 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002942:	1101                	addi	sp,sp,-32
    80002944:	ec06                	sd	ra,24(sp)
    80002946:	e822                	sd	s0,16(sp)
    80002948:	e426                	sd	s1,8(sp)
    8000294a:	e04a                	sd	s2,0(sp)
    8000294c:	1000                	addi	s0,sp,32
    8000294e:	892e                	mv	s2,a1
    80002950:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002952:	ecdff0ef          	jal	8000281e <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002956:	8626                	mv	a2,s1
    80002958:	85ca                	mv	a1,s2
    8000295a:	f6fff0ef          	jal	800028c8 <fetchstr>
}
    8000295e:	60e2                	ld	ra,24(sp)
    80002960:	6442                	ld	s0,16(sp)
    80002962:	64a2                	ld	s1,8(sp)
    80002964:	6902                	ld	s2,0(sp)
    80002966:	6105                	addi	sp,sp,32
    80002968:	8082                	ret

000000008000296a <syscall>:
  // clang-format on
};

void
syscall(void)
{
    8000296a:	1101                	addi	sp,sp,-32
    8000296c:	ec06                	sd	ra,24(sp)
    8000296e:	e822                	sd	s0,16(sp)
    80002970:	e426                	sd	s1,8(sp)
    80002972:	e04a                	sd	s2,0(sp)
    80002974:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002976:	fd7fe0ef          	jal	8000194c <myproc>
    8000297a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000297c:	05853903          	ld	s2,88(a0)
    80002980:	0a893783          	ld	a5,168(s2) # 800184c8 <bcache+0x1d0>
    80002984:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002988:	37fd                	addiw	a5,a5,-1
    8000298a:	4759                	li	a4,22
    8000298c:	00f76f63          	bltu	a4,a5,800029aa <syscall+0x40>
    80002990:	00369713          	slli	a4,a3,0x3
    80002994:	00005797          	auipc	a5,0x5
    80002998:	e0478793          	addi	a5,a5,-508 # 80007798 <syscalls>
    8000299c:	97ba                	add	a5,a5,a4
    8000299e:	639c                	ld	a5,0(a5)
    800029a0:	c789                	beqz	a5,800029aa <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800029a2:	9782                	jalr	a5
    800029a4:	06a93823          	sd	a0,112(s2)
    800029a8:	a829                	j	800029c2 <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    800029aa:	15848613          	addi	a2,s1,344
    800029ae:	588c                	lw	a1,48(s1)
    800029b0:	00005517          	auipc	a0,0x5
    800029b4:	9e050513          	addi	a0,a0,-1568 # 80007390 <etext+0x390>
    800029b8:	b53fd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    800029bc:	6cbc                	ld	a5,88(s1)
    800029be:	577d                	li	a4,-1
    800029c0:	fbb8                	sd	a4,112(a5)
  }
}
    800029c2:	60e2                	ld	ra,24(sp)
    800029c4:	6442                	ld	s0,16(sp)
    800029c6:	64a2                	ld	s1,8(sp)
    800029c8:	6902                	ld	s2,0(sp)
    800029ca:	6105                	addi	sp,sp,32
    800029cc:	8082                	ret

00000000800029ce <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    800029ce:	1101                	addi	sp,sp,-32
    800029d0:	ec06                	sd	ra,24(sp)
    800029d2:	e822                	sd	s0,16(sp)
    800029d4:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800029d6:	fec40593          	addi	a1,s0,-20
    800029da:	4501                	li	a0,0
    800029dc:	f2fff0ef          	jal	8000290a <argint>
  kexit(n);
    800029e0:	fec42503          	lw	a0,-20(s0)
    800029e4:	f10ff0ef          	jal	800020f4 <kexit>
  return 0; // not reached
}
    800029e8:	4501                	li	a0,0
    800029ea:	60e2                	ld	ra,24(sp)
    800029ec:	6442                	ld	s0,16(sp)
    800029ee:	6105                	addi	sp,sp,32
    800029f0:	8082                	ret

00000000800029f2 <sys_getpid>:

uint64
sys_getpid(void)
{
    800029f2:	1141                	addi	sp,sp,-16
    800029f4:	e406                	sd	ra,8(sp)
    800029f6:	e022                	sd	s0,0(sp)
    800029f8:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800029fa:	f53fe0ef          	jal	8000194c <myproc>
}
    800029fe:	5908                	lw	a0,48(a0)
    80002a00:	60a2                	ld	ra,8(sp)
    80002a02:	6402                	ld	s0,0(sp)
    80002a04:	0141                	addi	sp,sp,16
    80002a06:	8082                	ret

0000000080002a08 <sys_fork>:

uint64
sys_fork(void)
{
    80002a08:	1141                	addi	sp,sp,-16
    80002a0a:	e406                	sd	ra,8(sp)
    80002a0c:	e022                	sd	s0,0(sp)
    80002a0e:	0800                	addi	s0,sp,16
  return kfork();
    80002a10:	ac8ff0ef          	jal	80001cd8 <kfork>
}
    80002a14:	60a2                	ld	ra,8(sp)
    80002a16:	6402                	ld	s0,0(sp)
    80002a18:	0141                	addi	sp,sp,16
    80002a1a:	8082                	ret

0000000080002a1c <sys_wait>:

uint64
sys_wait(void)
{
    80002a1c:	1101                	addi	sp,sp,-32
    80002a1e:	ec06                	sd	ra,24(sp)
    80002a20:	e822                	sd	s0,16(sp)
    80002a22:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002a24:	fe840593          	addi	a1,s0,-24
    80002a28:	4501                	li	a0,0
    80002a2a:	efdff0ef          	jal	80002926 <argaddr>
  return kwait(p);
    80002a2e:	fe843503          	ld	a0,-24(s0)
    80002a32:	823ff0ef          	jal	80002254 <kwait>
}
    80002a36:	60e2                	ld	ra,24(sp)
    80002a38:	6442                	ld	s0,16(sp)
    80002a3a:	6105                	addi	sp,sp,32
    80002a3c:	8082                	ret

0000000080002a3e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002a3e:	7179                	addi	sp,sp,-48
    80002a40:	f406                	sd	ra,40(sp)
    80002a42:	f022                	sd	s0,32(sp)
    80002a44:	ec26                	sd	s1,24(sp)
    80002a46:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002a48:	fd840593          	addi	a1,s0,-40
    80002a4c:	4501                	li	a0,0
    80002a4e:	ebdff0ef          	jal	8000290a <argint>
  argint(1, &t);
    80002a52:	fdc40593          	addi	a1,s0,-36
    80002a56:	4505                	li	a0,1
    80002a58:	eb3ff0ef          	jal	8000290a <argint>
  addr = myproc()->sz;
    80002a5c:	ef1fe0ef          	jal	8000194c <myproc>
    80002a60:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002a62:	fdc42703          	lw	a4,-36(s0)
    80002a66:	4785                	li	a5,1
    80002a68:	02f70763          	beq	a4,a5,80002a96 <sys_sbrk+0x58>
    80002a6c:	fd842783          	lw	a5,-40(s0)
    80002a70:	0207c363          	bltz	a5,80002a96 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002a74:	97a6                	add	a5,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    80002a76:	02000737          	lui	a4,0x2000
    80002a7a:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002a7c:	0736                	slli	a4,a4,0xd
    80002a7e:	02f76a63          	bltu	a4,a5,80002ab2 <sys_sbrk+0x74>
    80002a82:	0297e863          	bltu	a5,s1,80002ab2 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002a86:	ec7fe0ef          	jal	8000194c <myproc>
    80002a8a:	fd842703          	lw	a4,-40(s0)
    80002a8e:	653c                	ld	a5,72(a0)
    80002a90:	97ba                	add	a5,a5,a4
    80002a92:	e53c                	sd	a5,72(a0)
    80002a94:	a039                	j	80002aa2 <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002a96:	fd842503          	lw	a0,-40(s0)
    80002a9a:	9dcff0ef          	jal	80001c76 <growproc>
    80002a9e:	00054863          	bltz	a0,80002aae <sys_sbrk+0x70>
  }
  return addr;
}
    80002aa2:	8526                	mv	a0,s1
    80002aa4:	70a2                	ld	ra,40(sp)
    80002aa6:	7402                	ld	s0,32(sp)
    80002aa8:	64e2                	ld	s1,24(sp)
    80002aaa:	6145                	addi	sp,sp,48
    80002aac:	8082                	ret
      return -1;
    80002aae:	54fd                	li	s1,-1
    80002ab0:	bfcd                	j	80002aa2 <sys_sbrk+0x64>
      return -1;
    80002ab2:	54fd                	li	s1,-1
    80002ab4:	b7fd                	j	80002aa2 <sys_sbrk+0x64>

0000000080002ab6 <sys_pause>:

uint64
sys_pause(void)
{
    80002ab6:	7139                	addi	sp,sp,-64
    80002ab8:	fc06                	sd	ra,56(sp)
    80002aba:	f822                	sd	s0,48(sp)
    80002abc:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002abe:	fcc40593          	addi	a1,s0,-52
    80002ac2:	4501                	li	a0,0
    80002ac4:	e47ff0ef          	jal	8000290a <argint>
  if (n < 0)
    80002ac8:	fcc42783          	lw	a5,-52(s0)
    80002acc:	0807c063          	bltz	a5,80002b4c <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002ad0:	00015517          	auipc	a0,0x15
    80002ad4:	7f850513          	addi	a0,a0,2040 # 800182c8 <tickslock>
    80002ad8:	950fe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002adc:	fcc42783          	lw	a5,-52(s0)
    80002ae0:	cbb9                	beqz	a5,80002b36 <sys_pause+0x80>
    80002ae2:	f426                	sd	s1,40(sp)
    80002ae4:	f04a                	sd	s2,32(sp)
    80002ae6:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002ae8:	00008997          	auipc	s3,0x8
    80002aec:	8a09a983          	lw	s3,-1888(s3) # 8000a388 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002af0:	00008917          	auipc	s2,0x8
    80002af4:	89890913          	addi	s2,s2,-1896 # 8000a388 <ticks>
    release(&tickslock);
    80002af8:	00015497          	auipc	s1,0x15
    80002afc:	7d048493          	addi	s1,s1,2000 # 800182c8 <tickslock>
    if (killed(myproc())) {
    80002b00:	e4dfe0ef          	jal	8000194c <myproc>
    80002b04:	f26ff0ef          	jal	8000222a <killed>
    80002b08:	e529                	bnez	a0,80002b52 <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002b0a:	854a                	mv	a0,s2
    80002b0c:	cc0ff0ef          	jal	80001fcc <sleep_prepare>
    release(&tickslock);
    80002b10:	8526                	mv	a0,s1
    80002b12:	99efe0ef          	jal	80000cb0 <release>
    sleep();
    80002b16:	cf2ff0ef          	jal	80002008 <sleep>
    acquire(&tickslock);
    80002b1a:	8526                	mv	a0,s1
    80002b1c:	90cfe0ef          	jal	80000c28 <acquire>
  while (ticks - ticks0 < n) {
    80002b20:	00092783          	lw	a5,0(s2)
    80002b24:	413787bb          	subw	a5,a5,s3
    80002b28:	fcc42703          	lw	a4,-52(s0)
    80002b2c:	fce7eae3          	bltu	a5,a4,80002b00 <sys_pause+0x4a>
    80002b30:	74a2                	ld	s1,40(sp)
    80002b32:	7902                	ld	s2,32(sp)
    80002b34:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002b36:	00015517          	auipc	a0,0x15
    80002b3a:	79250513          	addi	a0,a0,1938 # 800182c8 <tickslock>
    80002b3e:	972fe0ef          	jal	80000cb0 <release>
  return 0;
    80002b42:	4501                	li	a0,0
}
    80002b44:	70e2                	ld	ra,56(sp)
    80002b46:	7442                	ld	s0,48(sp)
    80002b48:	6121                	addi	sp,sp,64
    80002b4a:	8082                	ret
    n = 0;
    80002b4c:	fc042623          	sw	zero,-52(s0)
    80002b50:	b741                	j	80002ad0 <sys_pause+0x1a>
      release(&tickslock);
    80002b52:	00015517          	auipc	a0,0x15
    80002b56:	77650513          	addi	a0,a0,1910 # 800182c8 <tickslock>
    80002b5a:	956fe0ef          	jal	80000cb0 <release>
      return -1;
    80002b5e:	557d                	li	a0,-1
    80002b60:	74a2                	ld	s1,40(sp)
    80002b62:	7902                	ld	s2,32(sp)
    80002b64:	69e2                	ld	s3,24(sp)
    80002b66:	bff9                	j	80002b44 <sys_pause+0x8e>

0000000080002b68 <sys_kill>:

uint64
sys_kill(void)
{
    80002b68:	1101                	addi	sp,sp,-32
    80002b6a:	ec06                	sd	ra,24(sp)
    80002b6c:	e822                	sd	s0,16(sp)
    80002b6e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002b70:	fec40593          	addi	a1,s0,-20
    80002b74:	4501                	li	a0,0
    80002b76:	d95ff0ef          	jal	8000290a <argint>
  return kkill(pid);
    80002b7a:	fec42503          	lw	a0,-20(s0)
    80002b7e:	e1cff0ef          	jal	8000219a <kkill>
}
    80002b82:	60e2                	ld	ra,24(sp)
    80002b84:	6442                	ld	s0,16(sp)
    80002b86:	6105                	addi	sp,sp,32
    80002b88:	8082                	ret

0000000080002b8a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002b8a:	1101                	addi	sp,sp,-32
    80002b8c:	ec06                	sd	ra,24(sp)
    80002b8e:	e822                	sd	s0,16(sp)
    80002b90:	e426                	sd	s1,8(sp)
    80002b92:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002b94:	00015517          	auipc	a0,0x15
    80002b98:	73450513          	addi	a0,a0,1844 # 800182c8 <tickslock>
    80002b9c:	88cfe0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002ba0:	00007797          	auipc	a5,0x7
    80002ba4:	7e87a783          	lw	a5,2024(a5) # 8000a388 <ticks>
    80002ba8:	84be                	mv	s1,a5
  release(&tickslock);
    80002baa:	00015517          	auipc	a0,0x15
    80002bae:	71e50513          	addi	a0,a0,1822 # 800182c8 <tickslock>
    80002bb2:	8fefe0ef          	jal	80000cb0 <release>
  return xticks;
}
    80002bb6:	02049513          	slli	a0,s1,0x20
    80002bba:	9101                	srli	a0,a0,0x20
    80002bbc:	60e2                	ld	ra,24(sp)
    80002bbe:	6442                	ld	s0,16(sp)
    80002bc0:	64a2                	ld	s1,8(sp)
    80002bc2:	6105                	addi	sp,sp,32
    80002bc4:	8082                	ret

0000000080002bc6 <shminit>:
static char *global_shm_page = 0;
static struct spinlock global_shm_lock;

void
shminit(void)
{
    80002bc6:	1141                	addi	sp,sp,-16
    80002bc8:	e406                	sd	ra,8(sp)
    80002bca:	e022                	sd	s0,0(sp)
    80002bcc:	0800                	addi	s0,sp,16
  initlock(&global_shm_lock, "shm");
    80002bce:	00004597          	auipc	a1,0x4
    80002bd2:	7e258593          	addi	a1,a1,2018 # 800073b0 <etext+0x3b0>
    80002bd6:	00015517          	auipc	a0,0x15
    80002bda:	70a50513          	addi	a0,a0,1802 # 800182e0 <global_shm_lock>
    80002bde:	fcbfd0ef          	jal	80000ba8 <initlock>
}
    80002be2:	60a2                	ld	ra,8(sp)
    80002be4:	6402                	ld	s0,0(sp)
    80002be6:	0141                	addi	sp,sp,16
    80002be8:	8082                	ret

0000000080002bea <shm_get>:

uint64
shm_get(void)
{
    80002bea:	1101                	addi	sp,sp,-32
    80002bec:	ec06                	sd	ra,24(sp)
    80002bee:	e822                	sd	s0,16(sp)
    80002bf0:	e426                	sd	s1,8(sp)
    80002bf2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002bf4:	d59fe0ef          	jal	8000194c <myproc>
    80002bf8:	84aa                	mv	s1,a0

  acquire(&global_shm_lock);
    80002bfa:	00015517          	auipc	a0,0x15
    80002bfe:	6e650513          	addi	a0,a0,1766 # 800182e0 <global_shm_lock>
    80002c02:	826fe0ef          	jal	80000c28 <acquire>
  if (global_shm_page == 0) {
    80002c06:	00007797          	auipc	a5,0x7
    80002c0a:	78a7b783          	ld	a5,1930(a5) # 8000a390 <global_shm_page>
    80002c0e:	cbb1                	beqz	a5,80002c62 <shm_get+0x78>
      return 0;
    }
    memset(global_shm_page, 0, PGSIZE);
  }

  pte_t *pte = walk(p->pagetable, SHM_VA, 0);
    80002c10:	4601                	li	a2,0
    80002c12:	040005b7          	lui	a1,0x4000
    80002c16:	15f5                	addi	a1,a1,-3 # 3fffffd <_entry-0x7c000003>
    80002c18:	05b2                	slli	a1,a1,0xc
    80002c1a:	68a8                	ld	a0,80(s1)
    80002c1c:	b66fe0ef          	jal	80000f82 <walk>
  if (pte == 0 || (*pte & PTE_V) == 0) {
    80002c20:	c501                	beqz	a0,80002c28 <shm_get+0x3e>
    80002c22:	611c                	ld	a5,0(a0)
    80002c24:	8b85                	andi	a5,a5,1
    80002c26:	ef99                	bnez	a5,80002c44 <shm_get+0x5a>
    if (mappages(p->pagetable, SHM_VA, PGSIZE, (uint64)global_shm_page, PTE_R | PTE_W | PTE_U) != 0) {
    80002c28:	4759                	li	a4,22
    80002c2a:	00007697          	auipc	a3,0x7
    80002c2e:	7666b683          	ld	a3,1894(a3) # 8000a390 <global_shm_page>
    80002c32:	6605                	lui	a2,0x1
    80002c34:	040005b7          	lui	a1,0x4000
    80002c38:	15f5                	addi	a1,a1,-3 # 3fffffd <_entry-0x7c000003>
    80002c3a:	05b2                	slli	a1,a1,0xc
    80002c3c:	68a8                	ld	a0,80(s1)
    80002c3e:	c18fe0ef          	jal	80001056 <mappages>
    80002c42:	e521                	bnez	a0,80002c8a <shm_get+0xa0>
      release(&global_shm_lock);
      return 0;
    }
  }
  release(&global_shm_lock);
    80002c44:	00015517          	auipc	a0,0x15
    80002c48:	69c50513          	addi	a0,a0,1692 # 800182e0 <global_shm_lock>
    80002c4c:	864fe0ef          	jal	80000cb0 <release>
  return SHM_VA;
    80002c50:	04000537          	lui	a0,0x4000
    80002c54:	1575                	addi	a0,a0,-3 # 3fffffd <_entry-0x7c000003>
    80002c56:	0532                	slli	a0,a0,0xc
}
    80002c58:	60e2                	ld	ra,24(sp)
    80002c5a:	6442                	ld	s0,16(sp)
    80002c5c:	64a2                	ld	s1,8(sp)
    80002c5e:	6105                	addi	sp,sp,32
    80002c60:	8082                	ret
    global_shm_page = kalloc();
    80002c62:	eedfd0ef          	jal	80000b4e <kalloc>
    80002c66:	00007797          	auipc	a5,0x7
    80002c6a:	72a7b523          	sd	a0,1834(a5) # 8000a390 <global_shm_page>
    if (global_shm_page == 0) {
    80002c6e:	c511                	beqz	a0,80002c7a <shm_get+0x90>
    memset(global_shm_page, 0, PGSIZE);
    80002c70:	6605                	lui	a2,0x1
    80002c72:	4581                	li	a1,0
    80002c74:	874fe0ef          	jal	80000ce8 <memset>
    80002c78:	bf61                	j	80002c10 <shm_get+0x26>
      release(&global_shm_lock);
    80002c7a:	00015517          	auipc	a0,0x15
    80002c7e:	66650513          	addi	a0,a0,1638 # 800182e0 <global_shm_lock>
    80002c82:	82efe0ef          	jal	80000cb0 <release>
      return 0;
    80002c86:	4501                	li	a0,0
    80002c88:	bfc1                	j	80002c58 <shm_get+0x6e>
      release(&global_shm_lock);
    80002c8a:	00015517          	auipc	a0,0x15
    80002c8e:	65650513          	addi	a0,a0,1622 # 800182e0 <global_shm_lock>
    80002c92:	81efe0ef          	jal	80000cb0 <release>
      return 0;
    80002c96:	4501                	li	a0,0
    80002c98:	b7c1                	j	80002c58 <shm_get+0x6e>

0000000080002c9a <sys_shm_get>:

uint64
sys_shm_get(void)
{
    80002c9a:	1141                	addi	sp,sp,-16
    80002c9c:	e406                	sd	ra,8(sp)
    80002c9e:	e022                	sd	s0,0(sp)
    80002ca0:	0800                	addi	s0,sp,16
  return shm_get();
    80002ca2:	f49ff0ef          	jal	80002bea <shm_get>
}
    80002ca6:	60a2                	ld	ra,8(sp)
    80002ca8:	6402                	ld	s0,0(sp)
    80002caa:	0141                	addi	sp,sp,16
    80002cac:	8082                	ret

0000000080002cae <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002cae:	7179                	addi	sp,sp,-48
    80002cb0:	f406                	sd	ra,40(sp)
    80002cb2:	f022                	sd	s0,32(sp)
    80002cb4:	ec26                	sd	s1,24(sp)
    80002cb6:	e84a                	sd	s2,16(sp)
    80002cb8:	e44e                	sd	s3,8(sp)
    80002cba:	e052                	sd	s4,0(sp)
    80002cbc:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002cbe:	00004597          	auipc	a1,0x4
    80002cc2:	6fa58593          	addi	a1,a1,1786 # 800073b8 <etext+0x3b8>
    80002cc6:	00015517          	auipc	a0,0x15
    80002cca:	63250513          	addi	a0,a0,1586 # 800182f8 <bcache>
    80002cce:	edbfd0ef          	jal	80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002cd2:	0001d797          	auipc	a5,0x1d
    80002cd6:	62678793          	addi	a5,a5,1574 # 800202f8 <bcache+0x8000>
    80002cda:	0001e717          	auipc	a4,0x1e
    80002cde:	88670713          	addi	a4,a4,-1914 # 80020560 <bcache+0x8268>
    80002ce2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002ce6:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002cea:	00015497          	auipc	s1,0x15
    80002cee:	62648493          	addi	s1,s1,1574 # 80018310 <bcache+0x18>
    b->next = bcache.head.next;
    80002cf2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002cf4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002cf6:	00004a17          	auipc	s4,0x4
    80002cfa:	6caa0a13          	addi	s4,s4,1738 # 800073c0 <etext+0x3c0>
    b->next = bcache.head.next;
    80002cfe:	2b893783          	ld	a5,696(s2)
    80002d02:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002d04:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002d08:	85d2                	mv	a1,s4
    80002d0a:	01048513          	addi	a0,s1,16
    80002d0e:	41c010ef          	jal	8000412a <initsleeplock>
    bcache.head.next->prev = b;
    80002d12:	2b893783          	ld	a5,696(s2)
    80002d16:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002d18:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002d1c:	45848493          	addi	s1,s1,1112
    80002d20:	fd349fe3          	bne	s1,s3,80002cfe <binit+0x50>
  }
}
    80002d24:	70a2                	ld	ra,40(sp)
    80002d26:	7402                	ld	s0,32(sp)
    80002d28:	64e2                	ld	s1,24(sp)
    80002d2a:	6942                	ld	s2,16(sp)
    80002d2c:	69a2                	ld	s3,8(sp)
    80002d2e:	6a02                	ld	s4,0(sp)
    80002d30:	6145                	addi	sp,sp,48
    80002d32:	8082                	ret

0000000080002d34 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002d34:	7179                	addi	sp,sp,-48
    80002d36:	f406                	sd	ra,40(sp)
    80002d38:	f022                	sd	s0,32(sp)
    80002d3a:	ec26                	sd	s1,24(sp)
    80002d3c:	e84a                	sd	s2,16(sp)
    80002d3e:	e44e                	sd	s3,8(sp)
    80002d40:	1800                	addi	s0,sp,48
    80002d42:	892a                	mv	s2,a0
    80002d44:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002d46:	00015517          	auipc	a0,0x15
    80002d4a:	5b250513          	addi	a0,a0,1458 # 800182f8 <bcache>
    80002d4e:	edbfd0ef          	jal	80000c28 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002d52:	0001e497          	auipc	s1,0x1e
    80002d56:	85e4b483          	ld	s1,-1954(s1) # 800205b0 <bcache+0x82b8>
    80002d5a:	0001e797          	auipc	a5,0x1e
    80002d5e:	80678793          	addi	a5,a5,-2042 # 80020560 <bcache+0x8268>
    80002d62:	02f48b63          	beq	s1,a5,80002d98 <bread+0x64>
    80002d66:	873e                	mv	a4,a5
    80002d68:	a021                	j	80002d70 <bread+0x3c>
    80002d6a:	68a4                	ld	s1,80(s1)
    80002d6c:	02e48663          	beq	s1,a4,80002d98 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002d70:	449c                	lw	a5,8(s1)
    80002d72:	ff279ce3          	bne	a5,s2,80002d6a <bread+0x36>
    80002d76:	44dc                	lw	a5,12(s1)
    80002d78:	ff3799e3          	bne	a5,s3,80002d6a <bread+0x36>
      b->refcnt++;
    80002d7c:	40bc                	lw	a5,64(s1)
    80002d7e:	2785                	addiw	a5,a5,1
    80002d80:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d82:	00015517          	auipc	a0,0x15
    80002d86:	57650513          	addi	a0,a0,1398 # 800182f8 <bcache>
    80002d8a:	f27fd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002d8e:	01048513          	addi	a0,s1,16
    80002d92:	3ce010ef          	jal	80004160 <acquiresleep>
      return b;
    80002d96:	a889                	j	80002de8 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002d98:	0001e497          	auipc	s1,0x1e
    80002d9c:	8104b483          	ld	s1,-2032(s1) # 800205a8 <bcache+0x82b0>
    80002da0:	0001d797          	auipc	a5,0x1d
    80002da4:	7c078793          	addi	a5,a5,1984 # 80020560 <bcache+0x8268>
    80002da8:	00f48863          	beq	s1,a5,80002db8 <bread+0x84>
    80002dac:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002dae:	40bc                	lw	a5,64(s1)
    80002db0:	cb91                	beqz	a5,80002dc4 <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002db2:	64a4                	ld	s1,72(s1)
    80002db4:	fee49de3          	bne	s1,a4,80002dae <bread+0x7a>
  panic("bget: no buffers");
    80002db8:	00004517          	auipc	a0,0x4
    80002dbc:	61050513          	addi	a0,a0,1552 # 800073c8 <etext+0x3c8>
    80002dc0:	a75fd0ef          	jal	80000834 <panic>
      b->dev = dev;
    80002dc4:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002dc8:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002dcc:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002dd0:	4785                	li	a5,1
    80002dd2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002dd4:	00015517          	auipc	a0,0x15
    80002dd8:	52450513          	addi	a0,a0,1316 # 800182f8 <bcache>
    80002ddc:	ed5fd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002de0:	01048513          	addi	a0,s1,16
    80002de4:	37c010ef          	jal	80004160 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002de8:	409c                	lw	a5,0(s1)
    80002dea:	cb89                	beqz	a5,80002dfc <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002dec:	8526                	mv	a0,s1
    80002dee:	70a2                	ld	ra,40(sp)
    80002df0:	7402                	ld	s0,32(sp)
    80002df2:	64e2                	ld	s1,24(sp)
    80002df4:	6942                	ld	s2,16(sp)
    80002df6:	69a2                	ld	s3,8(sp)
    80002df8:	6145                	addi	sp,sp,48
    80002dfa:	8082                	ret
    virtio_disk_rw(b, 0);
    80002dfc:	4581                	li	a1,0
    80002dfe:	8526                	mv	a0,s1
    80002e00:	4c7020ef          	jal	80005ac6 <virtio_disk_rw>
    b->valid = 1;
    80002e04:	4785                	li	a5,1
    80002e06:	c09c                	sw	a5,0(s1)
  return b;
    80002e08:	b7d5                	j	80002dec <bread+0xb8>

0000000080002e0a <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002e0a:	1101                	addi	sp,sp,-32
    80002e0c:	ec06                	sd	ra,24(sp)
    80002e0e:	e822                	sd	s0,16(sp)
    80002e10:	e426                	sd	s1,8(sp)
    80002e12:	1000                	addi	s0,sp,32
    80002e14:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002e16:	0541                	addi	a0,a0,16
    80002e18:	3d4010ef          	jal	800041ec <holdingsleep>
    80002e1c:	c911                	beqz	a0,80002e30 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002e1e:	4585                	li	a1,1
    80002e20:	8526                	mv	a0,s1
    80002e22:	4a5020ef          	jal	80005ac6 <virtio_disk_rw>
}
    80002e26:	60e2                	ld	ra,24(sp)
    80002e28:	6442                	ld	s0,16(sp)
    80002e2a:	64a2                	ld	s1,8(sp)
    80002e2c:	6105                	addi	sp,sp,32
    80002e2e:	8082                	ret
    panic("bwrite");
    80002e30:	00004517          	auipc	a0,0x4
    80002e34:	5b050513          	addi	a0,a0,1456 # 800073e0 <etext+0x3e0>
    80002e38:	9fdfd0ef          	jal	80000834 <panic>

0000000080002e3c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002e3c:	1101                	addi	sp,sp,-32
    80002e3e:	ec06                	sd	ra,24(sp)
    80002e40:	e822                	sd	s0,16(sp)
    80002e42:	e426                	sd	s1,8(sp)
    80002e44:	e04a                	sd	s2,0(sp)
    80002e46:	1000                	addi	s0,sp,32
    80002e48:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002e4a:	01050913          	addi	s2,a0,16
    80002e4e:	854a                	mv	a0,s2
    80002e50:	39c010ef          	jal	800041ec <holdingsleep>
    80002e54:	c125                	beqz	a0,80002eb4 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002e56:	854a                	mv	a0,s2
    80002e58:	35c010ef          	jal	800041b4 <releasesleep>

  acquire(&bcache.lock);
    80002e5c:	00015517          	auipc	a0,0x15
    80002e60:	49c50513          	addi	a0,a0,1180 # 800182f8 <bcache>
    80002e64:	dc5fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002e68:	40bc                	lw	a5,64(s1)
    80002e6a:	37fd                	addiw	a5,a5,-1
    80002e6c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002e6e:	e79d                	bnez	a5,80002e9c <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002e70:	68b8                	ld	a4,80(s1)
    80002e72:	64bc                	ld	a5,72(s1)
    80002e74:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002e76:	68b8                	ld	a4,80(s1)
    80002e78:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002e7a:	0001d797          	auipc	a5,0x1d
    80002e7e:	47e78793          	addi	a5,a5,1150 # 800202f8 <bcache+0x8000>
    80002e82:	2b87b703          	ld	a4,696(a5)
    80002e86:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002e88:	0001d717          	auipc	a4,0x1d
    80002e8c:	6d870713          	addi	a4,a4,1752 # 80020560 <bcache+0x8268>
    80002e90:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002e92:	2b87b703          	ld	a4,696(a5)
    80002e96:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002e98:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002e9c:	00015517          	auipc	a0,0x15
    80002ea0:	45c50513          	addi	a0,a0,1116 # 800182f8 <bcache>
    80002ea4:	e0dfd0ef          	jal	80000cb0 <release>
}
    80002ea8:	60e2                	ld	ra,24(sp)
    80002eaa:	6442                	ld	s0,16(sp)
    80002eac:	64a2                	ld	s1,8(sp)
    80002eae:	6902                	ld	s2,0(sp)
    80002eb0:	6105                	addi	sp,sp,32
    80002eb2:	8082                	ret
    panic("brelse");
    80002eb4:	00004517          	auipc	a0,0x4
    80002eb8:	53450513          	addi	a0,a0,1332 # 800073e8 <etext+0x3e8>
    80002ebc:	979fd0ef          	jal	80000834 <panic>

0000000080002ec0 <bpin>:

void
bpin(struct buf *b)
{
    80002ec0:	1101                	addi	sp,sp,-32
    80002ec2:	ec06                	sd	ra,24(sp)
    80002ec4:	e822                	sd	s0,16(sp)
    80002ec6:	e426                	sd	s1,8(sp)
    80002ec8:	1000                	addi	s0,sp,32
    80002eca:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ecc:	00015517          	auipc	a0,0x15
    80002ed0:	42c50513          	addi	a0,a0,1068 # 800182f8 <bcache>
    80002ed4:	d55fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002ed8:	40bc                	lw	a5,64(s1)
    80002eda:	2785                	addiw	a5,a5,1
    80002edc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002ede:	00015517          	auipc	a0,0x15
    80002ee2:	41a50513          	addi	a0,a0,1050 # 800182f8 <bcache>
    80002ee6:	dcbfd0ef          	jal	80000cb0 <release>
}
    80002eea:	60e2                	ld	ra,24(sp)
    80002eec:	6442                	ld	s0,16(sp)
    80002eee:	64a2                	ld	s1,8(sp)
    80002ef0:	6105                	addi	sp,sp,32
    80002ef2:	8082                	ret

0000000080002ef4 <bunpin>:

void
bunpin(struct buf *b)
{
    80002ef4:	1101                	addi	sp,sp,-32
    80002ef6:	ec06                	sd	ra,24(sp)
    80002ef8:	e822                	sd	s0,16(sp)
    80002efa:	e426                	sd	s1,8(sp)
    80002efc:	1000                	addi	s0,sp,32
    80002efe:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f00:	00015517          	auipc	a0,0x15
    80002f04:	3f850513          	addi	a0,a0,1016 # 800182f8 <bcache>
    80002f08:	d21fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002f0c:	40bc                	lw	a5,64(s1)
    80002f0e:	37fd                	addiw	a5,a5,-1
    80002f10:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f12:	00015517          	auipc	a0,0x15
    80002f16:	3e650513          	addi	a0,a0,998 # 800182f8 <bcache>
    80002f1a:	d97fd0ef          	jal	80000cb0 <release>
}
    80002f1e:	60e2                	ld	ra,24(sp)
    80002f20:	6442                	ld	s0,16(sp)
    80002f22:	64a2                	ld	s1,8(sp)
    80002f24:	6105                	addi	sp,sp,32
    80002f26:	8082                	ret

0000000080002f28 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002f28:	1101                	addi	sp,sp,-32
    80002f2a:	ec06                	sd	ra,24(sp)
    80002f2c:	e822                	sd	s0,16(sp)
    80002f2e:	e426                	sd	s1,8(sp)
    80002f30:	e04a                	sd	s2,0(sp)
    80002f32:	1000                	addi	s0,sp,32
    80002f34:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002f36:	00d5d79b          	srliw	a5,a1,0xd
    80002f3a:	0001e597          	auipc	a1,0x1e
    80002f3e:	a9a5a583          	lw	a1,-1382(a1) # 800209d4 <sb+0x1c>
    80002f42:	9dbd                	addw	a1,a1,a5
    80002f44:	df1ff0ef          	jal	80002d34 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002f48:	0074f713          	andi	a4,s1,7
    80002f4c:	4785                	li	a5,1
    80002f4e:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002f52:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80002f54:	90d9                	srli	s1,s1,0x36
    80002f56:	00950733          	add	a4,a0,s1
    80002f5a:	05874703          	lbu	a4,88(a4)
    80002f5e:	00e7f6b3          	and	a3,a5,a4
    80002f62:	c29d                	beqz	a3,80002f88 <bfree+0x60>
    80002f64:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002f66:	94aa                	add	s1,s1,a0
    80002f68:	fff7c793          	not	a5,a5
    80002f6c:	8f7d                	and	a4,a4,a5
    80002f6e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002f72:	080010ef          	jal	80003ff2 <log_write>
  brelse(bp);
    80002f76:	854a                	mv	a0,s2
    80002f78:	ec5ff0ef          	jal	80002e3c <brelse>
}
    80002f7c:	60e2                	ld	ra,24(sp)
    80002f7e:	6442                	ld	s0,16(sp)
    80002f80:	64a2                	ld	s1,8(sp)
    80002f82:	6902                	ld	s2,0(sp)
    80002f84:	6105                	addi	sp,sp,32
    80002f86:	8082                	ret
    panic("freeing free block");
    80002f88:	00004517          	auipc	a0,0x4
    80002f8c:	46850513          	addi	a0,a0,1128 # 800073f0 <etext+0x3f0>
    80002f90:	8a5fd0ef          	jal	80000834 <panic>

0000000080002f94 <balloc>:
{
    80002f94:	715d                	addi	sp,sp,-80
    80002f96:	e486                	sd	ra,72(sp)
    80002f98:	e0a2                	sd	s0,64(sp)
    80002f9a:	fc26                	sd	s1,56(sp)
    80002f9c:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80002f9e:	0001e797          	auipc	a5,0x1e
    80002fa2:	a1e7a783          	lw	a5,-1506(a5) # 800209bc <sb+0x4>
    80002fa6:	0e078263          	beqz	a5,8000308a <balloc+0xf6>
    80002faa:	f84a                	sd	s2,48(sp)
    80002fac:	f44e                	sd	s3,40(sp)
    80002fae:	f052                	sd	s4,32(sp)
    80002fb0:	ec56                	sd	s5,24(sp)
    80002fb2:	e85a                	sd	s6,16(sp)
    80002fb4:	e45e                	sd	s7,8(sp)
    80002fb6:	e062                	sd	s8,0(sp)
    80002fb8:	8baa                	mv	s7,a0
    80002fba:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002fbc:	0001eb17          	auipc	s6,0x1e
    80002fc0:	9fcb0b13          	addi	s6,s6,-1540 # 800209b8 <sb>
      m = 1 << (bi % 8);
    80002fc4:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002fc6:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80002fc8:	6c09                	lui	s8,0x2
    80002fca:	a09d                	j	80003030 <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80002fcc:	97ca                	add	a5,a5,s2
    80002fce:	8e55                	or	a2,a2,a3
    80002fd0:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002fd4:	854a                	mv	a0,s2
    80002fd6:	01c010ef          	jal	80003ff2 <log_write>
        brelse(bp);
    80002fda:	854a                	mv	a0,s2
    80002fdc:	e61ff0ef          	jal	80002e3c <brelse>
  bp = bread(dev, bno);
    80002fe0:	85a6                	mv	a1,s1
    80002fe2:	855e                	mv	a0,s7
    80002fe4:	d51ff0ef          	jal	80002d34 <bread>
    80002fe8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002fea:	40000613          	li	a2,1024
    80002fee:	4581                	li	a1,0
    80002ff0:	05850513          	addi	a0,a0,88
    80002ff4:	cf5fd0ef          	jal	80000ce8 <memset>
  log_write(bp);
    80002ff8:	854a                	mv	a0,s2
    80002ffa:	7f9000ef          	jal	80003ff2 <log_write>
  brelse(bp);
    80002ffe:	854a                	mv	a0,s2
    80003000:	e3dff0ef          	jal	80002e3c <brelse>
}
    80003004:	7942                	ld	s2,48(sp)
    80003006:	79a2                	ld	s3,40(sp)
    80003008:	7a02                	ld	s4,32(sp)
    8000300a:	6ae2                	ld	s5,24(sp)
    8000300c:	6b42                	ld	s6,16(sp)
    8000300e:	6ba2                	ld	s7,8(sp)
    80003010:	6c02                	ld	s8,0(sp)
}
    80003012:	8526                	mv	a0,s1
    80003014:	60a6                	ld	ra,72(sp)
    80003016:	6406                	ld	s0,64(sp)
    80003018:	74e2                	ld	s1,56(sp)
    8000301a:	6161                	addi	sp,sp,80
    8000301c:	8082                	ret
    brelse(bp);
    8000301e:	854a                	mv	a0,s2
    80003020:	e1dff0ef          	jal	80002e3c <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80003024:	015c0abb          	addw	s5,s8,s5
    80003028:	004b2783          	lw	a5,4(s6)
    8000302c:	04faf863          	bgeu	s5,a5,8000307c <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80003030:	40dad59b          	sraiw	a1,s5,0xd
    80003034:	01cb2783          	lw	a5,28(s6)
    80003038:	9dbd                	addw	a1,a1,a5
    8000303a:	855e                	mv	a0,s7
    8000303c:	cf9ff0ef          	jal	80002d34 <bread>
    80003040:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003042:	004b2503          	lw	a0,4(s6)
    80003046:	84d6                	mv	s1,s5
    80003048:	4701                	li	a4,0
    8000304a:	fca4fae3          	bgeu	s1,a0,8000301e <balloc+0x8a>
      m = 1 << (bi % 8);
    8000304e:	00777693          	andi	a3,a4,7
    80003052:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80003056:	41f7579b          	sraiw	a5,a4,0x1f
    8000305a:	01d7d79b          	srliw	a5,a5,0x1d
    8000305e:	9fb9                	addw	a5,a5,a4
    80003060:	4037d79b          	sraiw	a5,a5,0x3
    80003064:	00f90633          	add	a2,s2,a5
    80003068:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    8000306c:	00c6f5b3          	and	a1,a3,a2
    80003070:	ddb1                	beqz	a1,80002fcc <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003072:	2705                	addiw	a4,a4,1
    80003074:	2485                	addiw	s1,s1,1
    80003076:	fd471ae3          	bne	a4,s4,8000304a <balloc+0xb6>
    8000307a:	b755                	j	8000301e <balloc+0x8a>
    8000307c:	7942                	ld	s2,48(sp)
    8000307e:	79a2                	ld	s3,40(sp)
    80003080:	7a02                	ld	s4,32(sp)
    80003082:	6ae2                	ld	s5,24(sp)
    80003084:	6b42                	ld	s6,16(sp)
    80003086:	6ba2                	ld	s7,8(sp)
    80003088:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    8000308a:	00004517          	auipc	a0,0x4
    8000308e:	37e50513          	addi	a0,a0,894 # 80007408 <etext+0x408>
    80003092:	c78fd0ef          	jal	8000050a <printk>
  return 0;
    80003096:	4481                	li	s1,0
    80003098:	bfad                	j	80003012 <balloc+0x7e>

000000008000309a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000309a:	7179                	addi	sp,sp,-48
    8000309c:	f406                	sd	ra,40(sp)
    8000309e:	f022                	sd	s0,32(sp)
    800030a0:	ec26                	sd	s1,24(sp)
    800030a2:	e84a                	sd	s2,16(sp)
    800030a4:	e44e                	sd	s3,8(sp)
    800030a6:	1800                	addi	s0,sp,48
    800030a8:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    800030aa:	47ad                	li	a5,11
    800030ac:	02b7e363          	bltu	a5,a1,800030d2 <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    800030b0:	02059793          	slli	a5,a1,0x20
    800030b4:	01e7d593          	srli	a1,a5,0x1e
    800030b8:	00b509b3          	add	s3,a0,a1
    800030bc:	0509a483          	lw	s1,80(s3)
    800030c0:	e0b5                	bnez	s1,80003124 <bmap+0x8a>
      addr = balloc(ip->dev);
    800030c2:	4108                	lw	a0,0(a0)
    800030c4:	ed1ff0ef          	jal	80002f94 <balloc>
    800030c8:	84aa                	mv	s1,a0
      if (addr == 0)
    800030ca:	cd29                	beqz	a0,80003124 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    800030cc:	04a9a823          	sw	a0,80(s3)
    800030d0:	a891                	j	80003124 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800030d2:	ff45879b          	addiw	a5,a1,-12
    800030d6:	873e                	mv	a4,a5
    800030d8:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    800030da:	0ff00793          	li	a5,255
    800030de:	06e7e763          	bltu	a5,a4,8000314c <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    800030e2:	08052483          	lw	s1,128(a0)
    800030e6:	e891                	bnez	s1,800030fa <bmap+0x60>
      addr = balloc(ip->dev);
    800030e8:	4108                	lw	a0,0(a0)
    800030ea:	eabff0ef          	jal	80002f94 <balloc>
    800030ee:	84aa                	mv	s1,a0
      if (addr == 0)
    800030f0:	c915                	beqz	a0,80003124 <bmap+0x8a>
    800030f2:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800030f4:	08a92023          	sw	a0,128(s2)
    800030f8:	a011                	j	800030fc <bmap+0x62>
    800030fa:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800030fc:	85a6                	mv	a1,s1
    800030fe:	00092503          	lw	a0,0(s2)
    80003102:	c33ff0ef          	jal	80002d34 <bread>
    80003106:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80003108:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    8000310c:	02099713          	slli	a4,s3,0x20
    80003110:	01e75593          	srli	a1,a4,0x1e
    80003114:	97ae                	add	a5,a5,a1
    80003116:	89be                	mv	s3,a5
    80003118:	4384                	lw	s1,0(a5)
    8000311a:	cc89                	beqz	s1,80003134 <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000311c:	8552                	mv	a0,s4
    8000311e:	d1fff0ef          	jal	80002e3c <brelse>
    return addr;
    80003122:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003124:	8526                	mv	a0,s1
    80003126:	70a2                	ld	ra,40(sp)
    80003128:	7402                	ld	s0,32(sp)
    8000312a:	64e2                	ld	s1,24(sp)
    8000312c:	6942                	ld	s2,16(sp)
    8000312e:	69a2                	ld	s3,8(sp)
    80003130:	6145                	addi	sp,sp,48
    80003132:	8082                	ret
      addr = balloc(ip->dev);
    80003134:	00092503          	lw	a0,0(s2)
    80003138:	e5dff0ef          	jal	80002f94 <balloc>
    8000313c:	84aa                	mv	s1,a0
      if (addr) {
    8000313e:	dd79                	beqz	a0,8000311c <bmap+0x82>
        a[bn] = addr;
    80003140:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80003144:	8552                	mv	a0,s4
    80003146:	6ad000ef          	jal	80003ff2 <log_write>
    8000314a:	bfc9                	j	8000311c <bmap+0x82>
    8000314c:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000314e:	00004517          	auipc	a0,0x4
    80003152:	2d250513          	addi	a0,a0,722 # 80007420 <etext+0x420>
    80003156:	edefd0ef          	jal	80000834 <panic>

000000008000315a <iget>:
{
    8000315a:	7179                	addi	sp,sp,-48
    8000315c:	f406                	sd	ra,40(sp)
    8000315e:	f022                	sd	s0,32(sp)
    80003160:	ec26                	sd	s1,24(sp)
    80003162:	e84a                	sd	s2,16(sp)
    80003164:	e44e                	sd	s3,8(sp)
    80003166:	e052                	sd	s4,0(sp)
    80003168:	1800                	addi	s0,sp,48
    8000316a:	892a                	mv	s2,a0
    8000316c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000316e:	0001e517          	auipc	a0,0x1e
    80003172:	86a50513          	addi	a0,a0,-1942 # 800209d8 <itable>
    80003176:	ab3fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    8000317a:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    8000317c:	0001e497          	auipc	s1,0x1e
    80003180:	87448493          	addi	s1,s1,-1932 # 800209f0 <itable+0x18>
    80003184:	0001f697          	auipc	a3,0x1f
    80003188:	2fc68693          	addi	a3,a3,764 # 80022480 <log>
    8000318c:	a809                	j	8000319e <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    8000318e:	e781                	bnez	a5,80003196 <iget+0x3c>
    80003190:	00099363          	bnez	s3,80003196 <iget+0x3c>
      empty = ip;
    80003194:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80003196:	08848493          	addi	s1,s1,136
    8000319a:	02d48563          	beq	s1,a3,800031c4 <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    8000319e:	449c                	lw	a5,8(s1)
    800031a0:	fef057e3          	blez	a5,8000318e <iget+0x34>
    800031a4:	4098                	lw	a4,0(s1)
    800031a6:	ff2718e3          	bne	a4,s2,80003196 <iget+0x3c>
    800031aa:	40d8                	lw	a4,4(s1)
    800031ac:	ff4715e3          	bne	a4,s4,80003196 <iget+0x3c>
      ip->ref++;
    800031b0:	2785                	addiw	a5,a5,1
    800031b2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800031b4:	0001e517          	auipc	a0,0x1e
    800031b8:	82450513          	addi	a0,a0,-2012 # 800209d8 <itable>
    800031bc:	af5fd0ef          	jal	80000cb0 <release>
      return ip;
    800031c0:	89a6                	mv	s3,s1
    800031c2:	a015                	j	800031e6 <iget+0x8c>
  if (empty == 0)
    800031c4:	02098a63          	beqz	s3,800031f8 <iget+0x9e>
  ip->dev = dev;
    800031c8:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    800031cc:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    800031d0:	4785                	li	a5,1
    800031d2:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    800031d6:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    800031da:	0001d517          	auipc	a0,0x1d
    800031de:	7fe50513          	addi	a0,a0,2046 # 800209d8 <itable>
    800031e2:	acffd0ef          	jal	80000cb0 <release>
}
    800031e6:	854e                	mv	a0,s3
    800031e8:	70a2                	ld	ra,40(sp)
    800031ea:	7402                	ld	s0,32(sp)
    800031ec:	64e2                	ld	s1,24(sp)
    800031ee:	6942                	ld	s2,16(sp)
    800031f0:	69a2                	ld	s3,8(sp)
    800031f2:	6a02                	ld	s4,0(sp)
    800031f4:	6145                	addi	sp,sp,48
    800031f6:	8082                	ret
    panic("iget: no inodes");
    800031f8:	00004517          	auipc	a0,0x4
    800031fc:	24050513          	addi	a0,a0,576 # 80007438 <etext+0x438>
    80003200:	e34fd0ef          	jal	80000834 <panic>

0000000080003204 <iinit>:
{
    80003204:	7179                	addi	sp,sp,-48
    80003206:	f406                	sd	ra,40(sp)
    80003208:	f022                	sd	s0,32(sp)
    8000320a:	ec26                	sd	s1,24(sp)
    8000320c:	e84a                	sd	s2,16(sp)
    8000320e:	e44e                	sd	s3,8(sp)
    80003210:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003212:	00004597          	auipc	a1,0x4
    80003216:	23658593          	addi	a1,a1,566 # 80007448 <etext+0x448>
    8000321a:	0001d517          	auipc	a0,0x1d
    8000321e:	7be50513          	addi	a0,a0,1982 # 800209d8 <itable>
    80003222:	987fd0ef          	jal	80000ba8 <initlock>
  for (i = 0; i < NINODE; i++) {
    80003226:	0001d497          	auipc	s1,0x1d
    8000322a:	7da48493          	addi	s1,s1,2010 # 80020a00 <itable+0x28>
    8000322e:	0001f997          	auipc	s3,0x1f
    80003232:	26298993          	addi	s3,s3,610 # 80022490 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003236:	00004917          	auipc	s2,0x4
    8000323a:	21a90913          	addi	s2,s2,538 # 80007450 <etext+0x450>
    8000323e:	85ca                	mv	a1,s2
    80003240:	8526                	mv	a0,s1
    80003242:	6e9000ef          	jal	8000412a <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    80003246:	08848493          	addi	s1,s1,136
    8000324a:	ff349ae3          	bne	s1,s3,8000323e <iinit+0x3a>
}
    8000324e:	70a2                	ld	ra,40(sp)
    80003250:	7402                	ld	s0,32(sp)
    80003252:	64e2                	ld	s1,24(sp)
    80003254:	6942                	ld	s2,16(sp)
    80003256:	69a2                	ld	s3,8(sp)
    80003258:	6145                	addi	sp,sp,48
    8000325a:	8082                	ret

000000008000325c <ialloc>:
{
    8000325c:	7139                	addi	sp,sp,-64
    8000325e:	fc06                	sd	ra,56(sp)
    80003260:	f822                	sd	s0,48(sp)
    80003262:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003264:	0001d717          	auipc	a4,0x1d
    80003268:	76072703          	lw	a4,1888(a4) # 800209c4 <sb+0xc>
    8000326c:	4785                	li	a5,1
    8000326e:	06e7f063          	bgeu	a5,a4,800032ce <ialloc+0x72>
    80003272:	f426                	sd	s1,40(sp)
    80003274:	f04a                	sd	s2,32(sp)
    80003276:	ec4e                	sd	s3,24(sp)
    80003278:	e852                	sd	s4,16(sp)
    8000327a:	e456                	sd	s5,8(sp)
    8000327c:	e05a                	sd	s6,0(sp)
    8000327e:	8aaa                	mv	s5,a0
    80003280:	8b2e                	mv	s6,a1
    80003282:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003284:	0001da17          	auipc	s4,0x1d
    80003288:	734a0a13          	addi	s4,s4,1844 # 800209b8 <sb>
    8000328c:	00495593          	srli	a1,s2,0x4
    80003290:	018a2783          	lw	a5,24(s4)
    80003294:	9dbd                	addw	a1,a1,a5
    80003296:	8556                	mv	a0,s5
    80003298:	a9dff0ef          	jal	80002d34 <bread>
    8000329c:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    8000329e:	05850993          	addi	s3,a0,88
    800032a2:	00f97793          	andi	a5,s2,15
    800032a6:	079a                	slli	a5,a5,0x6
    800032a8:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    800032aa:	00099783          	lh	a5,0(s3)
    800032ae:	cb9d                	beqz	a5,800032e4 <ialloc+0x88>
    brelse(bp);
    800032b0:	b8dff0ef          	jal	80002e3c <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    800032b4:	0905                	addi	s2,s2,1
    800032b6:	00ca2703          	lw	a4,12(s4)
    800032ba:	0009079b          	sext.w	a5,s2
    800032be:	fce7e7e3          	bltu	a5,a4,8000328c <ialloc+0x30>
    800032c2:	74a2                	ld	s1,40(sp)
    800032c4:	7902                	ld	s2,32(sp)
    800032c6:	69e2                	ld	s3,24(sp)
    800032c8:	6a42                	ld	s4,16(sp)
    800032ca:	6aa2                	ld	s5,8(sp)
    800032cc:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    800032ce:	00004517          	auipc	a0,0x4
    800032d2:	18a50513          	addi	a0,a0,394 # 80007458 <etext+0x458>
    800032d6:	a34fd0ef          	jal	8000050a <printk>
  return 0;
    800032da:	4501                	li	a0,0
}
    800032dc:	70e2                	ld	ra,56(sp)
    800032de:	7442                	ld	s0,48(sp)
    800032e0:	6121                	addi	sp,sp,64
    800032e2:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800032e4:	04000613          	li	a2,64
    800032e8:	4581                	li	a1,0
    800032ea:	854e                	mv	a0,s3
    800032ec:	9fdfd0ef          	jal	80000ce8 <memset>
      dip->type = type;
    800032f0:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    800032f4:	8526                	mv	a0,s1
    800032f6:	4fd000ef          	jal	80003ff2 <log_write>
      brelse(bp);
    800032fa:	8526                	mv	a0,s1
    800032fc:	b41ff0ef          	jal	80002e3c <brelse>
      return iget(dev, inum);
    80003300:	0009059b          	sext.w	a1,s2
    80003304:	8556                	mv	a0,s5
    80003306:	e55ff0ef          	jal	8000315a <iget>
    8000330a:	74a2                	ld	s1,40(sp)
    8000330c:	7902                	ld	s2,32(sp)
    8000330e:	69e2                	ld	s3,24(sp)
    80003310:	6a42                	ld	s4,16(sp)
    80003312:	6aa2                	ld	s5,8(sp)
    80003314:	6b02                	ld	s6,0(sp)
    80003316:	b7d9                	j	800032dc <ialloc+0x80>

0000000080003318 <iupdate>:
{
    80003318:	1101                	addi	sp,sp,-32
    8000331a:	ec06                	sd	ra,24(sp)
    8000331c:	e822                	sd	s0,16(sp)
    8000331e:	e426                	sd	s1,8(sp)
    80003320:	e04a                	sd	s2,0(sp)
    80003322:	1000                	addi	s0,sp,32
    80003324:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003326:	415c                	lw	a5,4(a0)
    80003328:	0047d79b          	srliw	a5,a5,0x4
    8000332c:	0001d597          	auipc	a1,0x1d
    80003330:	6a45a583          	lw	a1,1700(a1) # 800209d0 <sb+0x18>
    80003334:	9dbd                	addw	a1,a1,a5
    80003336:	4108                	lw	a0,0(a0)
    80003338:	9fdff0ef          	jal	80002d34 <bread>
    8000333c:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000333e:	05850793          	addi	a5,a0,88
    80003342:	40d8                	lw	a4,4(s1)
    80003344:	8b3d                	andi	a4,a4,15
    80003346:	071a                	slli	a4,a4,0x6
    80003348:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000334a:	04449703          	lh	a4,68(s1)
    8000334e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003352:	04649703          	lh	a4,70(s1)
    80003356:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000335a:	04849703          	lh	a4,72(s1)
    8000335e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003362:	04a49703          	lh	a4,74(s1)
    80003366:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000336a:	44f8                	lw	a4,76(s1)
    8000336c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000336e:	03400613          	li	a2,52
    80003372:	05048593          	addi	a1,s1,80
    80003376:	00c78513          	addi	a0,a5,12
    8000337a:	9cffd0ef          	jal	80000d48 <memmove>
  log_write(bp);
    8000337e:	854a                	mv	a0,s2
    80003380:	473000ef          	jal	80003ff2 <log_write>
  brelse(bp);
    80003384:	854a                	mv	a0,s2
    80003386:	ab7ff0ef          	jal	80002e3c <brelse>
}
    8000338a:	60e2                	ld	ra,24(sp)
    8000338c:	6442                	ld	s0,16(sp)
    8000338e:	64a2                	ld	s1,8(sp)
    80003390:	6902                	ld	s2,0(sp)
    80003392:	6105                	addi	sp,sp,32
    80003394:	8082                	ret

0000000080003396 <idup>:
{
    80003396:	1101                	addi	sp,sp,-32
    80003398:	ec06                	sd	ra,24(sp)
    8000339a:	e822                	sd	s0,16(sp)
    8000339c:	e426                	sd	s1,8(sp)
    8000339e:	1000                	addi	s0,sp,32
    800033a0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800033a2:	0001d517          	auipc	a0,0x1d
    800033a6:	63650513          	addi	a0,a0,1590 # 800209d8 <itable>
    800033aa:	87ffd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    800033ae:	449c                	lw	a5,8(s1)
    800033b0:	2785                	addiw	a5,a5,1
    800033b2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033b4:	0001d517          	auipc	a0,0x1d
    800033b8:	62450513          	addi	a0,a0,1572 # 800209d8 <itable>
    800033bc:	8f5fd0ef          	jal	80000cb0 <release>
}
    800033c0:	8526                	mv	a0,s1
    800033c2:	60e2                	ld	ra,24(sp)
    800033c4:	6442                	ld	s0,16(sp)
    800033c6:	64a2                	ld	s1,8(sp)
    800033c8:	6105                	addi	sp,sp,32
    800033ca:	8082                	ret

00000000800033cc <ilock>:
{
    800033cc:	1101                	addi	sp,sp,-32
    800033ce:	ec06                	sd	ra,24(sp)
    800033d0:	e822                	sd	s0,16(sp)
    800033d2:	e426                	sd	s1,8(sp)
    800033d4:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    800033d6:	cd19                	beqz	a0,800033f4 <ilock+0x28>
    800033d8:	84aa                	mv	s1,a0
    800033da:	451c                	lw	a5,8(a0)
    800033dc:	00f05c63          	blez	a5,800033f4 <ilock+0x28>
  acquiresleep(&ip->lock);
    800033e0:	0541                	addi	a0,a0,16
    800033e2:	57f000ef          	jal	80004160 <acquiresleep>
  if (ip->valid == 0) {
    800033e6:	40bc                	lw	a5,64(s1)
    800033e8:	cf89                	beqz	a5,80003402 <ilock+0x36>
}
    800033ea:	60e2                	ld	ra,24(sp)
    800033ec:	6442                	ld	s0,16(sp)
    800033ee:	64a2                	ld	s1,8(sp)
    800033f0:	6105                	addi	sp,sp,32
    800033f2:	8082                	ret
    800033f4:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800033f6:	00004517          	auipc	a0,0x4
    800033fa:	07a50513          	addi	a0,a0,122 # 80007470 <etext+0x470>
    800033fe:	c36fd0ef          	jal	80000834 <panic>
    80003402:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003404:	40dc                	lw	a5,4(s1)
    80003406:	0047d79b          	srliw	a5,a5,0x4
    8000340a:	0001d597          	auipc	a1,0x1d
    8000340e:	5c65a583          	lw	a1,1478(a1) # 800209d0 <sb+0x18>
    80003412:	9dbd                	addw	a1,a1,a5
    80003414:	4088                	lw	a0,0(s1)
    80003416:	91fff0ef          	jal	80002d34 <bread>
    8000341a:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000341c:	05850593          	addi	a1,a0,88
    80003420:	40dc                	lw	a5,4(s1)
    80003422:	8bbd                	andi	a5,a5,15
    80003424:	079a                	slli	a5,a5,0x6
    80003426:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003428:	00059783          	lh	a5,0(a1)
    8000342c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003430:	00259783          	lh	a5,2(a1)
    80003434:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003438:	00459783          	lh	a5,4(a1)
    8000343c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003440:	00659783          	lh	a5,6(a1)
    80003444:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003448:	459c                	lw	a5,8(a1)
    8000344a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000344c:	03400613          	li	a2,52
    80003450:	05b1                	addi	a1,a1,12
    80003452:	05048513          	addi	a0,s1,80
    80003456:	8f3fd0ef          	jal	80000d48 <memmove>
    brelse(bp);
    8000345a:	854a                	mv	a0,s2
    8000345c:	9e1ff0ef          	jal	80002e3c <brelse>
    ip->valid = 1;
    80003460:	4785                	li	a5,1
    80003462:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003464:	04449783          	lh	a5,68(s1)
    80003468:	c399                	beqz	a5,8000346e <ilock+0xa2>
    8000346a:	6902                	ld	s2,0(sp)
    8000346c:	bfbd                	j	800033ea <ilock+0x1e>
      panic("ilock: no type");
    8000346e:	00004517          	auipc	a0,0x4
    80003472:	00a50513          	addi	a0,a0,10 # 80007478 <etext+0x478>
    80003476:	bbefd0ef          	jal	80000834 <panic>

000000008000347a <iunlock>:
{
    8000347a:	1101                	addi	sp,sp,-32
    8000347c:	ec06                	sd	ra,24(sp)
    8000347e:	e822                	sd	s0,16(sp)
    80003480:	e426                	sd	s1,8(sp)
    80003482:	e04a                	sd	s2,0(sp)
    80003484:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003486:	c505                	beqz	a0,800034ae <iunlock+0x34>
    80003488:	84aa                	mv	s1,a0
    8000348a:	01050913          	addi	s2,a0,16
    8000348e:	854a                	mv	a0,s2
    80003490:	55d000ef          	jal	800041ec <holdingsleep>
    80003494:	cd09                	beqz	a0,800034ae <iunlock+0x34>
    80003496:	449c                	lw	a5,8(s1)
    80003498:	00f05b63          	blez	a5,800034ae <iunlock+0x34>
  releasesleep(&ip->lock);
    8000349c:	854a                	mv	a0,s2
    8000349e:	517000ef          	jal	800041b4 <releasesleep>
}
    800034a2:	60e2                	ld	ra,24(sp)
    800034a4:	6442                	ld	s0,16(sp)
    800034a6:	64a2                	ld	s1,8(sp)
    800034a8:	6902                	ld	s2,0(sp)
    800034aa:	6105                	addi	sp,sp,32
    800034ac:	8082                	ret
    panic("iunlock");
    800034ae:	00004517          	auipc	a0,0x4
    800034b2:	fda50513          	addi	a0,a0,-38 # 80007488 <etext+0x488>
    800034b6:	b7efd0ef          	jal	80000834 <panic>

00000000800034ba <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800034ba:	7179                	addi	sp,sp,-48
    800034bc:	f406                	sd	ra,40(sp)
    800034be:	f022                	sd	s0,32(sp)
    800034c0:	ec26                	sd	s1,24(sp)
    800034c2:	e84a                	sd	s2,16(sp)
    800034c4:	e44e                	sd	s3,8(sp)
    800034c6:	1800                	addi	s0,sp,48
    800034c8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    800034ca:	05050493          	addi	s1,a0,80
    800034ce:	08050913          	addi	s2,a0,128
    800034d2:	a021                	j	800034da <itrunc+0x20>
    800034d4:	0491                	addi	s1,s1,4
    800034d6:	01248b63          	beq	s1,s2,800034ec <itrunc+0x32>
    if (ip->addrs[i]) {
    800034da:	408c                	lw	a1,0(s1)
    800034dc:	dde5                	beqz	a1,800034d4 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800034de:	0009a503          	lw	a0,0(s3)
    800034e2:	a47ff0ef          	jal	80002f28 <bfree>
      ip->addrs[i] = 0;
    800034e6:	0004a023          	sw	zero,0(s1)
    800034ea:	b7ed                	j	800034d4 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    800034ec:	0809a583          	lw	a1,128(s3)
    800034f0:	ed89                	bnez	a1,8000350a <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800034f2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800034f6:	854e                	mv	a0,s3
    800034f8:	e21ff0ef          	jal	80003318 <iupdate>
}
    800034fc:	70a2                	ld	ra,40(sp)
    800034fe:	7402                	ld	s0,32(sp)
    80003500:	64e2                	ld	s1,24(sp)
    80003502:	6942                	ld	s2,16(sp)
    80003504:	69a2                	ld	s3,8(sp)
    80003506:	6145                	addi	sp,sp,48
    80003508:	8082                	ret
    8000350a:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000350c:	0009a503          	lw	a0,0(s3)
    80003510:	825ff0ef          	jal	80002d34 <bread>
    80003514:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    80003516:	05850493          	addi	s1,a0,88
    8000351a:	45850913          	addi	s2,a0,1112
    8000351e:	a021                	j	80003526 <itrunc+0x6c>
    80003520:	0491                	addi	s1,s1,4
    80003522:	01248963          	beq	s1,s2,80003534 <itrunc+0x7a>
      if (a[j])
    80003526:	408c                	lw	a1,0(s1)
    80003528:	dde5                	beqz	a1,80003520 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000352a:	0009a503          	lw	a0,0(s3)
    8000352e:	9fbff0ef          	jal	80002f28 <bfree>
    80003532:	b7fd                	j	80003520 <itrunc+0x66>
    brelse(bp);
    80003534:	8552                	mv	a0,s4
    80003536:	907ff0ef          	jal	80002e3c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000353a:	0809a583          	lw	a1,128(s3)
    8000353e:	0009a503          	lw	a0,0(s3)
    80003542:	9e7ff0ef          	jal	80002f28 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003546:	0809a023          	sw	zero,128(s3)
    8000354a:	6a02                	ld	s4,0(sp)
    8000354c:	b75d                	j	800034f2 <itrunc+0x38>

000000008000354e <iput>:
{
    8000354e:	7179                	addi	sp,sp,-48
    80003550:	f406                	sd	ra,40(sp)
    80003552:	f022                	sd	s0,32(sp)
    80003554:	ec26                	sd	s1,24(sp)
    80003556:	1800                	addi	s0,sp,48
    80003558:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000355a:	0001d517          	auipc	a0,0x1d
    8000355e:	47e50513          	addi	a0,a0,1150 # 800209d8 <itable>
    80003562:	ec6fd0ef          	jal	80000c28 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003566:	449c                	lw	a5,8(s1)
    80003568:	4705                	li	a4,1
    8000356a:	00e78f63          	beq	a5,a4,80003588 <iput+0x3a>
  ip->ref--;
    8000356e:	37fd                	addiw	a5,a5,-1
    80003570:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003572:	0001d517          	auipc	a0,0x1d
    80003576:	46650513          	addi	a0,a0,1126 # 800209d8 <itable>
    8000357a:	f36fd0ef          	jal	80000cb0 <release>
}
    8000357e:	70a2                	ld	ra,40(sp)
    80003580:	7402                	ld	s0,32(sp)
    80003582:	64e2                	ld	s1,24(sp)
    80003584:	6145                	addi	sp,sp,48
    80003586:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003588:	40b8                	lw	a4,64(s1)
    8000358a:	d375                	beqz	a4,8000356e <iput+0x20>
    8000358c:	e84a                	sd	s2,16(sp)
    8000358e:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    80003590:	0004aa03          	lw	s4,0(s1)
    80003594:	0044a903          	lw	s2,4(s1)
  if (last) {
    80003598:	04a49703          	lh	a4,74(s1)
    8000359c:	ef3d                	bnez	a4,8000361a <iput+0xcc>
    8000359e:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    800035a0:	01048793          	addi	a5,s1,16
    800035a4:	89be                	mv	s3,a5
    800035a6:	853e                	mv	a0,a5
    800035a8:	3b9000ef          	jal	80004160 <acquiresleep>
    release(&itable.lock);
    800035ac:	0001d517          	auipc	a0,0x1d
    800035b0:	42c50513          	addi	a0,a0,1068 # 800209d8 <itable>
    800035b4:	efcfd0ef          	jal	80000cb0 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    800035b8:	8526                	mv	a0,s1
    800035ba:	f01ff0ef          	jal	800034ba <itrunc>
    ip->valid = 0;
    800035be:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800035c2:	854e                	mv	a0,s3
    800035c4:	3f1000ef          	jal	800041b4 <releasesleep>
    acquire(&itable.lock);
    800035c8:	0001d517          	auipc	a0,0x1d
    800035cc:	41050513          	addi	a0,a0,1040 # 800209d8 <itable>
    800035d0:	e58fd0ef          	jal	80000c28 <acquire>
  ip->ref--;
    800035d4:	449c                	lw	a5,8(s1)
    800035d6:	37fd                	addiw	a5,a5,-1
    800035d8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800035da:	0001d517          	auipc	a0,0x1d
    800035de:	3fe50513          	addi	a0,a0,1022 # 800209d8 <itable>
    800035e2:	ecefd0ef          	jal	80000cb0 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800035e6:	0049579b          	srliw	a5,s2,0x4
    800035ea:	0001d597          	auipc	a1,0x1d
    800035ee:	3e65a583          	lw	a1,998(a1) # 800209d0 <sb+0x18>
    800035f2:	9dbd                	addw	a1,a1,a5
    800035f4:	8552                	mv	a0,s4
    800035f6:	f3eff0ef          	jal	80002d34 <bread>
    800035fa:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800035fc:	00f97793          	andi	a5,s2,15
  dip->type = 0;
    80003600:	079a                	slli	a5,a5,0x6
    80003602:	97aa                	add	a5,a5,a0
    80003604:	04079c23          	sh	zero,88(a5)
  log_write(bp);
    80003608:	1eb000ef          	jal	80003ff2 <log_write>
  brelse(bp);
    8000360c:	8526                	mv	a0,s1
    8000360e:	82fff0ef          	jal	80002e3c <brelse>
}
    80003612:	6942                	ld	s2,16(sp)
    80003614:	69a2                	ld	s3,8(sp)
    80003616:	6a02                	ld	s4,0(sp)
    80003618:	b79d                	j	8000357e <iput+0x30>
    8000361a:	6942                	ld	s2,16(sp)
    8000361c:	6a02                	ld	s4,0(sp)
    8000361e:	bf81                	j	8000356e <iput+0x20>

0000000080003620 <iunlockput>:
{
    80003620:	1101                	addi	sp,sp,-32
    80003622:	ec06                	sd	ra,24(sp)
    80003624:	e822                	sd	s0,16(sp)
    80003626:	e426                	sd	s1,8(sp)
    80003628:	1000                	addi	s0,sp,32
    8000362a:	84aa                	mv	s1,a0
  iunlock(ip);
    8000362c:	e4fff0ef          	jal	8000347a <iunlock>
  iput(ip);
    80003630:	8526                	mv	a0,s1
    80003632:	f1dff0ef          	jal	8000354e <iput>
}
    80003636:	60e2                	ld	ra,24(sp)
    80003638:	6442                	ld	s0,16(sp)
    8000363a:	64a2                	ld	s1,8(sp)
    8000363c:	6105                	addi	sp,sp,32
    8000363e:	8082                	ret

0000000080003640 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003640:	0001d717          	auipc	a4,0x1d
    80003644:	38472703          	lw	a4,900(a4) # 800209c4 <sb+0xc>
    80003648:	4785                	li	a5,1
    8000364a:	0ae7fe63          	bgeu	a5,a4,80003706 <ireclaim+0xc6>
{
    8000364e:	7139                	addi	sp,sp,-64
    80003650:	fc06                	sd	ra,56(sp)
    80003652:	f822                	sd	s0,48(sp)
    80003654:	f426                	sd	s1,40(sp)
    80003656:	f04a                	sd	s2,32(sp)
    80003658:	ec4e                	sd	s3,24(sp)
    8000365a:	e852                	sd	s4,16(sp)
    8000365c:	e456                	sd	s5,8(sp)
    8000365e:	e05a                	sd	s6,0(sp)
    80003660:	0080                	addi	s0,sp,64
    80003662:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003664:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003666:	0001da17          	auipc	s4,0x1d
    8000366a:	352a0a13          	addi	s4,s4,850 # 800209b8 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    8000366e:	00004b17          	auipc	s6,0x4
    80003672:	e22b0b13          	addi	s6,s6,-478 # 80007490 <etext+0x490>
    80003676:	a099                	j	800036bc <ireclaim+0x7c>
    80003678:	85ce                	mv	a1,s3
    8000367a:	855a                	mv	a0,s6
    8000367c:	e8ffc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    80003680:	85ce                	mv	a1,s3
    80003682:	8556                	mv	a0,s5
    80003684:	ad7ff0ef          	jal	8000315a <iget>
    80003688:	89aa                	mv	s3,a0
    brelse(bp);
    8000368a:	854a                	mv	a0,s2
    8000368c:	fb0ff0ef          	jal	80002e3c <brelse>
    if (ip) {
    80003690:	00098f63          	beqz	s3,800036ae <ireclaim+0x6e>
      begin_op();
    80003694:	7b0000ef          	jal	80003e44 <begin_op>
      ilock(ip);
    80003698:	854e                	mv	a0,s3
    8000369a:	d33ff0ef          	jal	800033cc <ilock>
      iunlock(ip);
    8000369e:	854e                	mv	a0,s3
    800036a0:	ddbff0ef          	jal	8000347a <iunlock>
      iput(ip);
    800036a4:	854e                	mv	a0,s3
    800036a6:	ea9ff0ef          	jal	8000354e <iput>
      end_op();
    800036aa:	027000ef          	jal	80003ed0 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800036ae:	0485                	addi	s1,s1,1
    800036b0:	00ca2703          	lw	a4,12(s4)
    800036b4:	0004879b          	sext.w	a5,s1
    800036b8:	02e7fd63          	bgeu	a5,a4,800036f2 <ireclaim+0xb2>
    800036bc:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800036c0:	0044d593          	srli	a1,s1,0x4
    800036c4:	018a2783          	lw	a5,24(s4)
    800036c8:	9dbd                	addw	a1,a1,a5
    800036ca:	8556                	mv	a0,s5
    800036cc:	e68ff0ef          	jal	80002d34 <bread>
    800036d0:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800036d2:	05850793          	addi	a5,a0,88
    800036d6:	00f9f713          	andi	a4,s3,15
    800036da:	071a                	slli	a4,a4,0x6
    800036dc:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    800036de:	00079703          	lh	a4,0(a5)
    800036e2:	c701                	beqz	a4,800036ea <ireclaim+0xaa>
    800036e4:	00679783          	lh	a5,6(a5)
    800036e8:	dbc1                	beqz	a5,80003678 <ireclaim+0x38>
    brelse(bp);
    800036ea:	854a                	mv	a0,s2
    800036ec:	f50ff0ef          	jal	80002e3c <brelse>
    if (ip) {
    800036f0:	bf7d                	j	800036ae <ireclaim+0x6e>
}
    800036f2:	70e2                	ld	ra,56(sp)
    800036f4:	7442                	ld	s0,48(sp)
    800036f6:	74a2                	ld	s1,40(sp)
    800036f8:	7902                	ld	s2,32(sp)
    800036fa:	69e2                	ld	s3,24(sp)
    800036fc:	6a42                	ld	s4,16(sp)
    800036fe:	6aa2                	ld	s5,8(sp)
    80003700:	6b02                	ld	s6,0(sp)
    80003702:	6121                	addi	sp,sp,64
    80003704:	8082                	ret
    80003706:	8082                	ret

0000000080003708 <fsinit>:
{
    80003708:	1101                	addi	sp,sp,-32
    8000370a:	ec06                	sd	ra,24(sp)
    8000370c:	e822                	sd	s0,16(sp)
    8000370e:	e426                	sd	s1,8(sp)
    80003710:	e04a                	sd	s2,0(sp)
    80003712:	1000                	addi	s0,sp,32
    80003714:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003716:	4585                	li	a1,1
    80003718:	e1cff0ef          	jal	80002d34 <bread>
    8000371c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000371e:	02000613          	li	a2,32
    80003722:	05850593          	addi	a1,a0,88
    80003726:	0001d517          	auipc	a0,0x1d
    8000372a:	29250513          	addi	a0,a0,658 # 800209b8 <sb>
    8000372e:	e1afd0ef          	jal	80000d48 <memmove>
  brelse(bp);
    80003732:	8526                	mv	a0,s1
    80003734:	f08ff0ef          	jal	80002e3c <brelse>
  if (sb.magic != FSMAGIC)
    80003738:	0001d717          	auipc	a4,0x1d
    8000373c:	28072703          	lw	a4,640(a4) # 800209b8 <sb>
    80003740:	102037b7          	lui	a5,0x10203
    80003744:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003748:	02f71263          	bne	a4,a5,8000376c <fsinit+0x64>
  initlog(dev, &sb);
    8000374c:	0001d597          	auipc	a1,0x1d
    80003750:	26c58593          	addi	a1,a1,620 # 800209b8 <sb>
    80003754:	854a                	mv	a0,s2
    80003756:	66c000ef          	jal	80003dc2 <initlog>
  ireclaim(dev);
    8000375a:	854a                	mv	a0,s2
    8000375c:	ee5ff0ef          	jal	80003640 <ireclaim>
}
    80003760:	60e2                	ld	ra,24(sp)
    80003762:	6442                	ld	s0,16(sp)
    80003764:	64a2                	ld	s1,8(sp)
    80003766:	6902                	ld	s2,0(sp)
    80003768:	6105                	addi	sp,sp,32
    8000376a:	8082                	ret
    panic("invalid file system");
    8000376c:	00004517          	auipc	a0,0x4
    80003770:	d4450513          	addi	a0,a0,-700 # 800074b0 <etext+0x4b0>
    80003774:	8c0fd0ef          	jal	80000834 <panic>

0000000080003778 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003778:	1141                	addi	sp,sp,-16
    8000377a:	e406                	sd	ra,8(sp)
    8000377c:	e022                	sd	s0,0(sp)
    8000377e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003780:	411c                	lw	a5,0(a0)
    80003782:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003784:	415c                	lw	a5,4(a0)
    80003786:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003788:	04451783          	lh	a5,68(a0)
    8000378c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003790:	04a51783          	lh	a5,74(a0)
    80003794:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003798:	04c56783          	lwu	a5,76(a0)
    8000379c:	e99c                	sd	a5,16(a1)
}
    8000379e:	60a2                	ld	ra,8(sp)
    800037a0:	6402                	ld	s0,0(sp)
    800037a2:	0141                	addi	sp,sp,16
    800037a4:	8082                	ret

00000000800037a6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    800037a6:	457c                	lw	a5,76(a0)
    800037a8:	0ed7e663          	bltu	a5,a3,80003894 <readi+0xee>
{
    800037ac:	7159                	addi	sp,sp,-112
    800037ae:	f486                	sd	ra,104(sp)
    800037b0:	f0a2                	sd	s0,96(sp)
    800037b2:	eca6                	sd	s1,88(sp)
    800037b4:	e0d2                	sd	s4,64(sp)
    800037b6:	fc56                	sd	s5,56(sp)
    800037b8:	f85a                	sd	s6,48(sp)
    800037ba:	f45e                	sd	s7,40(sp)
    800037bc:	1880                	addi	s0,sp,112
    800037be:	8b2a                	mv	s6,a0
    800037c0:	8bae                	mv	s7,a1
    800037c2:	8a32                	mv	s4,a2
    800037c4:	84b6                	mv	s1,a3
    800037c6:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    800037c8:	9f35                	addw	a4,a4,a3
    return 0;
    800037ca:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    800037cc:	0ad76b63          	bltu	a4,a3,80003882 <readi+0xdc>
    800037d0:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    800037d2:	00e7f463          	bgeu	a5,a4,800037da <readi+0x34>
    n = ip->size - off;
    800037d6:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800037da:	080a8b63          	beqz	s5,80003870 <readi+0xca>
    800037de:	e8ca                	sd	s2,80(sp)
    800037e0:	f062                	sd	s8,32(sp)
    800037e2:	ec66                	sd	s9,24(sp)
    800037e4:	e86a                	sd	s10,16(sp)
    800037e6:	e46e                	sd	s11,8(sp)
    800037e8:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800037ea:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800037ee:	5c7d                	li	s8,-1
    800037f0:	a80d                	j	80003822 <readi+0x7c>
    800037f2:	020d1d93          	slli	s11,s10,0x20
    800037f6:	020ddd93          	srli	s11,s11,0x20
    800037fa:	05890613          	addi	a2,s2,88
    800037fe:	86ee                	mv	a3,s11
    80003800:	963e                	add	a2,a2,a5
    80003802:	85d2                	mv	a1,s4
    80003804:	855e                	mv	a0,s7
    80003806:	b59fe0ef          	jal	8000235e <either_copyout>
    8000380a:	05850363          	beq	a0,s8,80003850 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000380e:	854a                	mv	a0,s2
    80003810:	e2cff0ef          	jal	80002e3c <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003814:	013d09bb          	addw	s3,s10,s3
    80003818:	009d04bb          	addw	s1,s10,s1
    8000381c:	9a6e                	add	s4,s4,s11
    8000381e:	0559f363          	bgeu	s3,s5,80003864 <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    80003822:	00a4d59b          	srliw	a1,s1,0xa
    80003826:	855a                	mv	a0,s6
    80003828:	873ff0ef          	jal	8000309a <bmap>
    8000382c:	85aa                	mv	a1,a0
    if (addr == 0)
    8000382e:	c139                	beqz	a0,80003874 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003830:	000b2503          	lw	a0,0(s6)
    80003834:	d00ff0ef          	jal	80002d34 <bread>
    80003838:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    8000383a:	3ff4f793          	andi	a5,s1,1023
    8000383e:	40fc873b          	subw	a4,s9,a5
    80003842:	413a86bb          	subw	a3,s5,s3
    80003846:	8d3a                	mv	s10,a4
    80003848:	fae6f5e3          	bgeu	a3,a4,800037f2 <readi+0x4c>
    8000384c:	8d36                	mv	s10,a3
    8000384e:	b755                	j	800037f2 <readi+0x4c>
      brelse(bp);
    80003850:	854a                	mv	a0,s2
    80003852:	deaff0ef          	jal	80002e3c <brelse>
      tot = -1;
    80003856:	59fd                	li	s3,-1
      break;
    80003858:	6946                	ld	s2,80(sp)
    8000385a:	7c02                	ld	s8,32(sp)
    8000385c:	6ce2                	ld	s9,24(sp)
    8000385e:	6d42                	ld	s10,16(sp)
    80003860:	6da2                	ld	s11,8(sp)
    80003862:	a831                	j	8000387e <readi+0xd8>
    80003864:	6946                	ld	s2,80(sp)
    80003866:	7c02                	ld	s8,32(sp)
    80003868:	6ce2                	ld	s9,24(sp)
    8000386a:	6d42                	ld	s10,16(sp)
    8000386c:	6da2                	ld	s11,8(sp)
    8000386e:	a801                	j	8000387e <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003870:	89d6                	mv	s3,s5
    80003872:	a031                	j	8000387e <readi+0xd8>
    80003874:	6946                	ld	s2,80(sp)
    80003876:	7c02                	ld	s8,32(sp)
    80003878:	6ce2                	ld	s9,24(sp)
    8000387a:	6d42                	ld	s10,16(sp)
    8000387c:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000387e:	854e                	mv	a0,s3
    80003880:	69a6                	ld	s3,72(sp)
}
    80003882:	70a6                	ld	ra,104(sp)
    80003884:	7406                	ld	s0,96(sp)
    80003886:	64e6                	ld	s1,88(sp)
    80003888:	6a06                	ld	s4,64(sp)
    8000388a:	7ae2                	ld	s5,56(sp)
    8000388c:	7b42                	ld	s6,48(sp)
    8000388e:	7ba2                	ld	s7,40(sp)
    80003890:	6165                	addi	sp,sp,112
    80003892:	8082                	ret
    return 0;
    80003894:	4501                	li	a0,0
}
    80003896:	8082                	ret

0000000080003898 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003898:	457c                	lw	a5,76(a0)
    8000389a:	0ed7ee63          	bltu	a5,a3,80003996 <writei+0xfe>
{
    8000389e:	7159                	addi	sp,sp,-112
    800038a0:	f486                	sd	ra,104(sp)
    800038a2:	f0a2                	sd	s0,96(sp)
    800038a4:	e8ca                	sd	s2,80(sp)
    800038a6:	e0d2                	sd	s4,64(sp)
    800038a8:	fc56                	sd	s5,56(sp)
    800038aa:	f85a                	sd	s6,48(sp)
    800038ac:	f45e                	sd	s7,40(sp)
    800038ae:	1880                	addi	s0,sp,112
    800038b0:	8aaa                	mv	s5,a0
    800038b2:	8bae                	mv	s7,a1
    800038b4:	8a32                	mv	s4,a2
    800038b6:	8936                	mv	s2,a3
    800038b8:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    800038ba:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    800038be:	00043737          	lui	a4,0x43
    800038c2:	0cf76c63          	bltu	a4,a5,8000399a <writei+0x102>
    800038c6:	0cd7ea63          	bltu	a5,a3,8000399a <writei+0x102>
    800038ca:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800038cc:	0a0b0d63          	beqz	s6,80003986 <writei+0xee>
    800038d0:	eca6                	sd	s1,88(sp)
    800038d2:	f062                	sd	s8,32(sp)
    800038d4:	ec66                	sd	s9,24(sp)
    800038d6:	e86a                	sd	s10,16(sp)
    800038d8:	e46e                	sd	s11,8(sp)
    800038da:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800038dc:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800038e0:	5c7d                	li	s8,-1
    800038e2:	a825                	j	8000391a <writei+0x82>
    800038e4:	020d1d93          	slli	s11,s10,0x20
    800038e8:	020ddd93          	srli	s11,s11,0x20
    800038ec:	05848513          	addi	a0,s1,88
    800038f0:	86ee                	mv	a3,s11
    800038f2:	8652                	mv	a2,s4
    800038f4:	85de                	mv	a1,s7
    800038f6:	953e                	add	a0,a0,a5
    800038f8:	ab3fe0ef          	jal	800023aa <either_copyin>
    800038fc:	05850663          	beq	a0,s8,80003948 <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    80003900:	8526                	mv	a0,s1
    80003902:	6f0000ef          	jal	80003ff2 <log_write>
    brelse(bp);
    80003906:	8526                	mv	a0,s1
    80003908:	d34ff0ef          	jal	80002e3c <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    8000390c:	013d09bb          	addw	s3,s10,s3
    80003910:	012d093b          	addw	s2,s10,s2
    80003914:	9a6e                	add	s4,s4,s11
    80003916:	0369ff63          	bgeu	s3,s6,80003954 <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    8000391a:	00a9559b          	srliw	a1,s2,0xa
    8000391e:	8556                	mv	a0,s5
    80003920:	f7aff0ef          	jal	8000309a <bmap>
    80003924:	85aa                	mv	a1,a0
    if (addr == 0)
    80003926:	c51d                	beqz	a0,80003954 <writei+0xbc>
    bp = bread(ip->dev, addr);
    80003928:	000aa503          	lw	a0,0(s5)
    8000392c:	c08ff0ef          	jal	80002d34 <bread>
    80003930:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003932:	3ff97793          	andi	a5,s2,1023
    80003936:	40fc873b          	subw	a4,s9,a5
    8000393a:	413b06bb          	subw	a3,s6,s3
    8000393e:	8d3a                	mv	s10,a4
    80003940:	fae6f2e3          	bgeu	a3,a4,800038e4 <writei+0x4c>
    80003944:	8d36                	mv	s10,a3
    80003946:	bf79                	j	800038e4 <writei+0x4c>
      log_write(bp);
    80003948:	8526                	mv	a0,s1
    8000394a:	6a8000ef          	jal	80003ff2 <log_write>
      brelse(bp);
    8000394e:	8526                	mv	a0,s1
    80003950:	cecff0ef          	jal	80002e3c <brelse>
  }

  if (off > ip->size)
    80003954:	04caa783          	lw	a5,76(s5)
    80003958:	0327f963          	bgeu	a5,s2,8000398a <writei+0xf2>
    ip->size = off;
    8000395c:	052aa623          	sw	s2,76(s5)
    80003960:	64e6                	ld	s1,88(sp)
    80003962:	7c02                	ld	s8,32(sp)
    80003964:	6ce2                	ld	s9,24(sp)
    80003966:	6d42                	ld	s10,16(sp)
    80003968:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000396a:	8556                	mv	a0,s5
    8000396c:	9adff0ef          	jal	80003318 <iupdate>

  return tot;
    80003970:	854e                	mv	a0,s3
    80003972:	69a6                	ld	s3,72(sp)
}
    80003974:	70a6                	ld	ra,104(sp)
    80003976:	7406                	ld	s0,96(sp)
    80003978:	6946                	ld	s2,80(sp)
    8000397a:	6a06                	ld	s4,64(sp)
    8000397c:	7ae2                	ld	s5,56(sp)
    8000397e:	7b42                	ld	s6,48(sp)
    80003980:	7ba2                	ld	s7,40(sp)
    80003982:	6165                	addi	sp,sp,112
    80003984:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003986:	89da                	mv	s3,s6
    80003988:	b7cd                	j	8000396a <writei+0xd2>
    8000398a:	64e6                	ld	s1,88(sp)
    8000398c:	7c02                	ld	s8,32(sp)
    8000398e:	6ce2                	ld	s9,24(sp)
    80003990:	6d42                	ld	s10,16(sp)
    80003992:	6da2                	ld	s11,8(sp)
    80003994:	bfd9                	j	8000396a <writei+0xd2>
    return -1;
    80003996:	557d                	li	a0,-1
}
    80003998:	8082                	ret
    return -1;
    8000399a:	557d                	li	a0,-1
    8000399c:	bfe1                	j	80003974 <writei+0xdc>

000000008000399e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000399e:	1141                	addi	sp,sp,-16
    800039a0:	e406                	sd	ra,8(sp)
    800039a2:	e022                	sd	s0,0(sp)
    800039a4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800039a6:	4639                	li	a2,14
    800039a8:	c14fd0ef          	jal	80000dbc <strncmp>
}
    800039ac:	60a2                	ld	ra,8(sp)
    800039ae:	6402                	ld	s0,0(sp)
    800039b0:	0141                	addi	sp,sp,16
    800039b2:	8082                	ret

00000000800039b4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
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
    800039c8:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    800039ca:	04451703          	lh	a4,68(a0)
    800039ce:	4785                	li	a5,1
    800039d0:	00f71f63          	bne	a4,a5,800039ee <dirlookup+0x3a>
    800039d4:	892a                	mv	s2,a0
    800039d6:	8aae                	mv	s5,a1
    800039d8:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    800039da:	457c                	lw	a5,76(a0)
    800039dc:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039de:	fa040a13          	addi	s4,s0,-96
    800039e2:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    800039e4:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800039e8:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800039ea:	e39d                	bnez	a5,80003a10 <dirlookup+0x5c>
    800039ec:	a8b9                	j	80003a4a <dirlookup+0x96>
    panic("dirlookup not DIR");
    800039ee:	00004517          	auipc	a0,0x4
    800039f2:	ada50513          	addi	a0,a0,-1318 # 800074c8 <etext+0x4c8>
    800039f6:	e3ffc0ef          	jal	80000834 <panic>
      panic("dirlookup read");
    800039fa:	00004517          	auipc	a0,0x4
    800039fe:	ae650513          	addi	a0,a0,-1306 # 800074e0 <etext+0x4e0>
    80003a02:	e33fc0ef          	jal	80000834 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a06:	24c1                	addiw	s1,s1,16
    80003a08:	04c92783          	lw	a5,76(s2)
    80003a0c:	02f4fe63          	bgeu	s1,a5,80003a48 <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a10:	874e                	mv	a4,s3
    80003a12:	86a6                	mv	a3,s1
    80003a14:	8652                	mv	a2,s4
    80003a16:	4581                	li	a1,0
    80003a18:	854a                	mv	a0,s2
    80003a1a:	d8dff0ef          	jal	800037a6 <readi>
    80003a1e:	fd351ee3          	bne	a0,s3,800039fa <dirlookup+0x46>
    if (de.inum == 0)
    80003a22:	fa045783          	lhu	a5,-96(s0)
    80003a26:	d3e5                	beqz	a5,80003a06 <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    80003a28:	85da                	mv	a1,s6
    80003a2a:	8556                	mv	a0,s5
    80003a2c:	f73ff0ef          	jal	8000399e <namecmp>
    80003a30:	f979                	bnez	a0,80003a06 <dirlookup+0x52>
      if (poff)
    80003a32:	000b8463          	beqz	s7,80003a3a <dirlookup+0x86>
        *poff = off;
    80003a36:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003a3a:	fa045583          	lhu	a1,-96(s0)
    80003a3e:	00092503          	lw	a0,0(s2)
    80003a42:	f18ff0ef          	jal	8000315a <iget>
    80003a46:	a011                	j	80003a4a <dirlookup+0x96>
  return 0;
    80003a48:	4501                	li	a0,0
}
    80003a4a:	60e6                	ld	ra,88(sp)
    80003a4c:	6446                	ld	s0,80(sp)
    80003a4e:	64a6                	ld	s1,72(sp)
    80003a50:	6906                	ld	s2,64(sp)
    80003a52:	79e2                	ld	s3,56(sp)
    80003a54:	7a42                	ld	s4,48(sp)
    80003a56:	7aa2                	ld	s5,40(sp)
    80003a58:	7b02                	ld	s6,32(sp)
    80003a5a:	6be2                	ld	s7,24(sp)
    80003a5c:	6125                	addi	sp,sp,96
    80003a5e:	8082                	ret

0000000080003a60 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003a60:	711d                	addi	sp,sp,-96
    80003a62:	ec86                	sd	ra,88(sp)
    80003a64:	e8a2                	sd	s0,80(sp)
    80003a66:	e4a6                	sd	s1,72(sp)
    80003a68:	e0ca                	sd	s2,64(sp)
    80003a6a:	fc4e                	sd	s3,56(sp)
    80003a6c:	f852                	sd	s4,48(sp)
    80003a6e:	f456                	sd	s5,40(sp)
    80003a70:	f05a                	sd	s6,32(sp)
    80003a72:	ec5e                	sd	s7,24(sp)
    80003a74:	e862                	sd	s8,16(sp)
    80003a76:	e466                	sd	s9,8(sp)
    80003a78:	e06a                	sd	s10,0(sp)
    80003a7a:	1080                	addi	s0,sp,96
    80003a7c:	84aa                	mv	s1,a0
    80003a7e:	8b2e                	mv	s6,a1
    80003a80:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003a82:	00054703          	lbu	a4,0(a0)
    80003a86:	02f00793          	li	a5,47
    80003a8a:	00f70f63          	beq	a4,a5,80003aa8 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003a8e:	ebffd0ef          	jal	8000194c <myproc>
    80003a92:	15053503          	ld	a0,336(a0)
    80003a96:	901ff0ef          	jal	80003396 <idup>
    80003a9a:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003a9c:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    80003aa0:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003aa2:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003aa4:	4b85                	li	s7,1
    80003aa6:	a07d                	j	80003b54 <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    80003aa8:	4585                	li	a1,1
    80003aaa:	852e                	mv	a0,a1
    80003aac:	eaeff0ef          	jal	8000315a <iget>
    80003ab0:	8a2a                	mv	s4,a0
    80003ab2:	b7ed                	j	80003a9c <namex+0x3c>
      iunlockput(ip);
    80003ab4:	8552                	mv	a0,s4
    80003ab6:	b6bff0ef          	jal	80003620 <iunlockput>
      return 0;
    80003aba:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003abc:	8552                	mv	a0,s4
    80003abe:	60e6                	ld	ra,88(sp)
    80003ac0:	6446                	ld	s0,80(sp)
    80003ac2:	64a6                	ld	s1,72(sp)
    80003ac4:	6906                	ld	s2,64(sp)
    80003ac6:	79e2                	ld	s3,56(sp)
    80003ac8:	7a42                	ld	s4,48(sp)
    80003aca:	7aa2                	ld	s5,40(sp)
    80003acc:	7b02                	ld	s6,32(sp)
    80003ace:	6be2                	ld	s7,24(sp)
    80003ad0:	6c42                	ld	s8,16(sp)
    80003ad2:	6ca2                	ld	s9,8(sp)
    80003ad4:	6d02                	ld	s10,0(sp)
    80003ad6:	6125                	addi	sp,sp,96
    80003ad8:	8082                	ret
      iunlockput(ip);
    80003ada:	8552                	mv	a0,s4
    80003adc:	b45ff0ef          	jal	80003620 <iunlockput>
      return 0;
    80003ae0:	4a01                	li	s4,0
    80003ae2:	bfe9                	j	80003abc <namex+0x5c>
      iunlock(ip);
    80003ae4:	8552                	mv	a0,s4
    80003ae6:	995ff0ef          	jal	8000347a <iunlock>
      return ip;
    80003aea:	bfc9                	j	80003abc <namex+0x5c>
      iunlockput(ip);
    80003aec:	8552                	mv	a0,s4
    80003aee:	b33ff0ef          	jal	80003620 <iunlockput>
      return 0;
    80003af2:	8a4a                	mv	s4,s2
    80003af4:	b7e1                	j	80003abc <namex+0x5c>
  while (*path != '/' && *path != 0)
    80003af6:	8926                	mv	s2,s1
  len = path - s;
    80003af8:	4d01                	li	s10,0
    80003afa:	4601                	li	a2,0
    memmove(name, s, len);
    80003afc:	2601                	sext.w	a2,a2
    80003afe:	85a6                	mv	a1,s1
    80003b00:	8556                	mv	a0,s5
    80003b02:	a46fd0ef          	jal	80000d48 <memmove>
    name[len] = 0;
    80003b06:	9d56                	add	s10,s10,s5
    80003b08:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffdb940>
  while (*path == '/')
    80003b0c:	00094783          	lbu	a5,0(s2)
    80003b10:	09379b63          	bne	a5,s3,80003ba6 <namex+0x146>
    80003b14:	84ca                	mv	s1,s2
    path++;
    80003b16:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003b18:	0004c783          	lbu	a5,0(s1)
    80003b1c:	ff378de3          	beq	a5,s3,80003b16 <namex+0xb6>
    ilock(ip);
    80003b20:	8552                	mv	a0,s4
    80003b22:	8abff0ef          	jal	800033cc <ilock>
    if (ip->type != T_DIR) {
    80003b26:	044a1783          	lh	a5,68(s4)
    80003b2a:	f97795e3          	bne	a5,s7,80003ab4 <namex+0x54>
    if (ip->nlink == 0) {
    80003b2e:	04aa1783          	lh	a5,74(s4)
    80003b32:	d7c5                	beqz	a5,80003ada <namex+0x7a>
    if (nameiparent && *path == '\0') {
    80003b34:	000b0563          	beqz	s6,80003b3e <namex+0xde>
    80003b38:	0004c783          	lbu	a5,0(s1)
    80003b3c:	d7c5                	beqz	a5,80003ae4 <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003b3e:	4601                	li	a2,0
    80003b40:	85d6                	mv	a1,s5
    80003b42:	8552                	mv	a0,s4
    80003b44:	e71ff0ef          	jal	800039b4 <dirlookup>
    80003b48:	892a                	mv	s2,a0
    80003b4a:	d14d                	beqz	a0,80003aec <namex+0x8c>
    iunlockput(ip);
    80003b4c:	8552                	mv	a0,s4
    80003b4e:	ad3ff0ef          	jal	80003620 <iunlockput>
    ip = next;
    80003b52:	8a4a                	mv	s4,s2
  while (*path == '/')
    80003b54:	0004c783          	lbu	a5,0(s1)
    80003b58:	01379763          	bne	a5,s3,80003b66 <namex+0x106>
    path++;
    80003b5c:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003b5e:	0004c783          	lbu	a5,0(s1)
    80003b62:	ff378de3          	beq	a5,s3,80003b5c <namex+0xfc>
  if (*path == 0)
    80003b66:	c7a1                	beqz	a5,80003bae <namex+0x14e>
  while (*path != '/' && *path != 0)
    80003b68:	0004c783          	lbu	a5,0(s1)
    80003b6c:	fd178713          	addi	a4,a5,-47
    80003b70:	d359                	beqz	a4,80003af6 <namex+0x96>
    80003b72:	d3d1                	beqz	a5,80003af6 <namex+0x96>
    80003b74:	8926                	mv	s2,s1
    path++;
    80003b76:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    80003b78:	00094783          	lbu	a5,0(s2)
    80003b7c:	fd178713          	addi	a4,a5,-47
    80003b80:	c311                	beqz	a4,80003b84 <namex+0x124>
    80003b82:	fbf5                	bnez	a5,80003b76 <namex+0x116>
  len = path - s;
    80003b84:	40990633          	sub	a2,s2,s1
    80003b88:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80003b8c:	f7ac58e3          	bge	s8,s10,80003afc <namex+0x9c>
    memmove(name, s, DIRSIZ);
    80003b90:	8666                	mv	a2,s9
    80003b92:	85a6                	mv	a1,s1
    80003b94:	8556                	mv	a0,s5
    80003b96:	9b2fd0ef          	jal	80000d48 <memmove>
  while (*path == '/')
    80003b9a:	00094783          	lbu	a5,0(s2)
    80003b9e:	84ca                	mv	s1,s2
    80003ba0:	f7378be3          	beq	a5,s3,80003b16 <namex+0xb6>
    80003ba4:	bfb5                	j	80003b20 <namex+0xc0>
  while ((path = skipelem(path, name)) != 0) {
    80003ba6:	00090463          	beqz	s2,80003bae <namex+0x14e>
    80003baa:	84ca                	mv	s1,s2
    80003bac:	bf95                	j	80003b20 <namex+0xc0>
  if (nameiparent) {
    80003bae:	f00b07e3          	beqz	s6,80003abc <namex+0x5c>
    iput(ip);
    80003bb2:	8552                	mv	a0,s4
    80003bb4:	99bff0ef          	jal	8000354e <iput>
    return 0;
    80003bb8:	4a01                	li	s4,0
    80003bba:	b709                	j	80003abc <namex+0x5c>

0000000080003bbc <dirlink>:
{
    80003bbc:	715d                	addi	sp,sp,-80
    80003bbe:	e486                	sd	ra,72(sp)
    80003bc0:	e0a2                	sd	s0,64(sp)
    80003bc2:	f84a                	sd	s2,48(sp)
    80003bc4:	ec56                	sd	s5,24(sp)
    80003bc6:	e85a                	sd	s6,16(sp)
    80003bc8:	0880                	addi	s0,sp,80
    80003bca:	892a                	mv	s2,a0
    80003bcc:	8aae                	mv	s5,a1
    80003bce:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003bd0:	4601                	li	a2,0
    80003bd2:	de3ff0ef          	jal	800039b4 <dirlookup>
    80003bd6:	ed1d                	bnez	a0,80003c14 <dirlink+0x58>
    80003bd8:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003bda:	04c92483          	lw	s1,76(s2)
    80003bde:	c4b9                	beqz	s1,80003c2c <dirlink+0x70>
    80003be0:	f44e                	sd	s3,40(sp)
    80003be2:	f052                	sd	s4,32(sp)
    80003be4:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003be6:	fb040a13          	addi	s4,s0,-80
    80003bea:	49c1                	li	s3,16
    80003bec:	874e                	mv	a4,s3
    80003bee:	86a6                	mv	a3,s1
    80003bf0:	8652                	mv	a2,s4
    80003bf2:	4581                	li	a1,0
    80003bf4:	854a                	mv	a0,s2
    80003bf6:	bb1ff0ef          	jal	800037a6 <readi>
    80003bfa:	03351163          	bne	a0,s3,80003c1c <dirlink+0x60>
    if (de.inum == 0)
    80003bfe:	fb045783          	lhu	a5,-80(s0)
    80003c02:	c39d                	beqz	a5,80003c28 <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003c04:	24c1                	addiw	s1,s1,16
    80003c06:	04c92783          	lw	a5,76(s2)
    80003c0a:	fef4e1e3          	bltu	s1,a5,80003bec <dirlink+0x30>
    80003c0e:	79a2                	ld	s3,40(sp)
    80003c10:	7a02                	ld	s4,32(sp)
    80003c12:	a829                	j	80003c2c <dirlink+0x70>
    iput(ip);
    80003c14:	93bff0ef          	jal	8000354e <iput>
    return -1;
    80003c18:	557d                	li	a0,-1
    80003c1a:	a83d                	j	80003c58 <dirlink+0x9c>
      panic("dirlink read");
    80003c1c:	00004517          	auipc	a0,0x4
    80003c20:	8d450513          	addi	a0,a0,-1836 # 800074f0 <etext+0x4f0>
    80003c24:	c11fc0ef          	jal	80000834 <panic>
    80003c28:	79a2                	ld	s3,40(sp)
    80003c2a:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003c2c:	4639                	li	a2,14
    80003c2e:	85d6                	mv	a1,s5
    80003c30:	fb240513          	addi	a0,s0,-78
    80003c34:	9c2fd0ef          	jal	80000df6 <strncpy>
  de.inum = inum;
    80003c38:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c3c:	4741                	li	a4,16
    80003c3e:	86a6                	mv	a3,s1
    80003c40:	fb040613          	addi	a2,s0,-80
    80003c44:	4581                	li	a1,0
    80003c46:	854a                	mv	a0,s2
    80003c48:	c51ff0ef          	jal	80003898 <writei>
    80003c4c:	1541                	addi	a0,a0,-16
    80003c4e:	00a03533          	snez	a0,a0
    80003c52:	40a0053b          	negw	a0,a0
    80003c56:	74e2                	ld	s1,56(sp)
}
    80003c58:	60a6                	ld	ra,72(sp)
    80003c5a:	6406                	ld	s0,64(sp)
    80003c5c:	7942                	ld	s2,48(sp)
    80003c5e:	6ae2                	ld	s5,24(sp)
    80003c60:	6b42                	ld	s6,16(sp)
    80003c62:	6161                	addi	sp,sp,80
    80003c64:	8082                	ret

0000000080003c66 <namei>:

struct inode *
namei(char *path)
{
    80003c66:	1101                	addi	sp,sp,-32
    80003c68:	ec06                	sd	ra,24(sp)
    80003c6a:	e822                	sd	s0,16(sp)
    80003c6c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003c6e:	fe040613          	addi	a2,s0,-32
    80003c72:	4581                	li	a1,0
    80003c74:	dedff0ef          	jal	80003a60 <namex>
}
    80003c78:	60e2                	ld	ra,24(sp)
    80003c7a:	6442                	ld	s0,16(sp)
    80003c7c:	6105                	addi	sp,sp,32
    80003c7e:	8082                	ret

0000000080003c80 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003c80:	1141                	addi	sp,sp,-16
    80003c82:	e406                	sd	ra,8(sp)
    80003c84:	e022                	sd	s0,0(sp)
    80003c86:	0800                	addi	s0,sp,16
    80003c88:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003c8a:	4585                	li	a1,1
    80003c8c:	dd5ff0ef          	jal	80003a60 <namex>
}
    80003c90:	60a2                	ld	ra,8(sp)
    80003c92:	6402                	ld	s0,0(sp)
    80003c94:	0141                	addi	sp,sp,16
    80003c96:	8082                	ret

0000000080003c98 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003c98:	1101                	addi	sp,sp,-32
    80003c9a:	ec06                	sd	ra,24(sp)
    80003c9c:	e822                	sd	s0,16(sp)
    80003c9e:	e426                	sd	s1,8(sp)
    80003ca0:	e04a                	sd	s2,0(sp)
    80003ca2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003ca4:	0001e917          	auipc	s2,0x1e
    80003ca8:	7dc90913          	addi	s2,s2,2012 # 80022480 <log>
    80003cac:	01892583          	lw	a1,24(s2)
    80003cb0:	02492503          	lw	a0,36(s2)
    80003cb4:	880ff0ef          	jal	80002d34 <bread>
    80003cb8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003cba:	02c92603          	lw	a2,44(s2)
    80003cbe:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003cc0:	00c05f63          	blez	a2,80003cde <write_head+0x46>
    80003cc4:	0001e717          	auipc	a4,0x1e
    80003cc8:	7ec70713          	addi	a4,a4,2028 # 800224b0 <log+0x30>
    80003ccc:	87aa                	mv	a5,a0
    80003cce:	060a                	slli	a2,a2,0x2
    80003cd0:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003cd2:	4314                	lw	a3,0(a4)
    80003cd4:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003cd6:	0711                	addi	a4,a4,4
    80003cd8:	0791                	addi	a5,a5,4
    80003cda:	fec79ce3          	bne	a5,a2,80003cd2 <write_head+0x3a>
  }
  bwrite(buf);
    80003cde:	8526                	mv	a0,s1
    80003ce0:	92aff0ef          	jal	80002e0a <bwrite>
  brelse(buf);
    80003ce4:	8526                	mv	a0,s1
    80003ce6:	956ff0ef          	jal	80002e3c <brelse>
}
    80003cea:	60e2                	ld	ra,24(sp)
    80003cec:	6442                	ld	s0,16(sp)
    80003cee:	64a2                	ld	s1,8(sp)
    80003cf0:	6902                	ld	s2,0(sp)
    80003cf2:	6105                	addi	sp,sp,32
    80003cf4:	8082                	ret

0000000080003cf6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cf6:	0001e797          	auipc	a5,0x1e
    80003cfa:	7b67a783          	lw	a5,1974(a5) # 800224ac <log+0x2c>
    80003cfe:	0cf05163          	blez	a5,80003dc0 <install_trans+0xca>
{
    80003d02:	715d                	addi	sp,sp,-80
    80003d04:	e486                	sd	ra,72(sp)
    80003d06:	e0a2                	sd	s0,64(sp)
    80003d08:	fc26                	sd	s1,56(sp)
    80003d0a:	f84a                	sd	s2,48(sp)
    80003d0c:	f44e                	sd	s3,40(sp)
    80003d0e:	f052                	sd	s4,32(sp)
    80003d10:	ec56                	sd	s5,24(sp)
    80003d12:	e85a                	sd	s6,16(sp)
    80003d14:	e45e                	sd	s7,8(sp)
    80003d16:	e062                	sd	s8,0(sp)
    80003d18:	0880                	addi	s0,sp,80
    80003d1a:	8b2a                	mv	s6,a0
    80003d1c:	0001ea97          	auipc	s5,0x1e
    80003d20:	794a8a93          	addi	s5,s5,1940 # 800224b0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d24:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d26:	00003c17          	auipc	s8,0x3
    80003d2a:	7dac0c13          	addi	s8,s8,2010 # 80007500 <etext+0x500>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003d2e:	0001ea17          	auipc	s4,0x1e
    80003d32:	752a0a13          	addi	s4,s4,1874 # 80022480 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003d36:	40000b93          	li	s7,1024
    80003d3a:	a025                	j	80003d62 <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d3c:	000aa603          	lw	a2,0(s5)
    80003d40:	85ce                	mv	a1,s3
    80003d42:	8562                	mv	a0,s8
    80003d44:	fc6fc0ef          	jal	8000050a <printk>
    80003d48:	a839                	j	80003d66 <install_trans+0x70>
    brelse(lbuf);
    80003d4a:	854a                	mv	a0,s2
    80003d4c:	8f0ff0ef          	jal	80002e3c <brelse>
    brelse(dbuf);
    80003d50:	8526                	mv	a0,s1
    80003d52:	8eaff0ef          	jal	80002e3c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d56:	2985                	addiw	s3,s3,1
    80003d58:	0a91                	addi	s5,s5,4
    80003d5a:	02ca2783          	lw	a5,44(s4)
    80003d5e:	04f9d563          	bge	s3,a5,80003da8 <install_trans+0xb2>
    if (recovering) {
    80003d62:	fc0b1de3          	bnez	s6,80003d3c <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003d66:	018a2583          	lw	a1,24(s4)
    80003d6a:	013585bb          	addw	a1,a1,s3
    80003d6e:	2585                	addiw	a1,a1,1
    80003d70:	024a2503          	lw	a0,36(s4)
    80003d74:	fc1fe0ef          	jal	80002d34 <bread>
    80003d78:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003d7a:	000aa583          	lw	a1,0(s5)
    80003d7e:	024a2503          	lw	a0,36(s4)
    80003d82:	fb3fe0ef          	jal	80002d34 <bread>
    80003d86:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003d88:	865e                	mv	a2,s7
    80003d8a:	05890593          	addi	a1,s2,88
    80003d8e:	05850513          	addi	a0,a0,88
    80003d92:	fb7fc0ef          	jal	80000d48 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003d96:	8526                	mv	a0,s1
    80003d98:	872ff0ef          	jal	80002e0a <bwrite>
    if (recovering == 0)
    80003d9c:	fa0b17e3          	bnez	s6,80003d4a <install_trans+0x54>
      bunpin(dbuf);
    80003da0:	8526                	mv	a0,s1
    80003da2:	952ff0ef          	jal	80002ef4 <bunpin>
    80003da6:	b755                	j	80003d4a <install_trans+0x54>
}
    80003da8:	60a6                	ld	ra,72(sp)
    80003daa:	6406                	ld	s0,64(sp)
    80003dac:	74e2                	ld	s1,56(sp)
    80003dae:	7942                	ld	s2,48(sp)
    80003db0:	79a2                	ld	s3,40(sp)
    80003db2:	7a02                	ld	s4,32(sp)
    80003db4:	6ae2                	ld	s5,24(sp)
    80003db6:	6b42                	ld	s6,16(sp)
    80003db8:	6ba2                	ld	s7,8(sp)
    80003dba:	6c02                	ld	s8,0(sp)
    80003dbc:	6161                	addi	sp,sp,80
    80003dbe:	8082                	ret
    80003dc0:	8082                	ret

0000000080003dc2 <initlog>:
{
    80003dc2:	7179                	addi	sp,sp,-48
    80003dc4:	f406                	sd	ra,40(sp)
    80003dc6:	f022                	sd	s0,32(sp)
    80003dc8:	ec26                	sd	s1,24(sp)
    80003dca:	e84a                	sd	s2,16(sp)
    80003dcc:	e44e                	sd	s3,8(sp)
    80003dce:	1800                	addi	s0,sp,48
    80003dd0:	84aa                	mv	s1,a0
    80003dd2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003dd4:	0001e917          	auipc	s2,0x1e
    80003dd8:	6ac90913          	addi	s2,s2,1708 # 80022480 <log>
    80003ddc:	00003597          	auipc	a1,0x3
    80003de0:	74458593          	addi	a1,a1,1860 # 80007520 <etext+0x520>
    80003de4:	854a                	mv	a0,s2
    80003de6:	dc3fc0ef          	jal	80000ba8 <initlock>
  log.start = sb->logstart;
    80003dea:	0149a583          	lw	a1,20(s3)
    80003dee:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003df2:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003df6:	8526                	mv	a0,s1
    80003df8:	f3dfe0ef          	jal	80002d34 <bread>
  log.lh.n = lh->n;
    80003dfc:	4d30                	lw	a2,88(a0)
    80003dfe:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003e02:	00c05f63          	blez	a2,80003e20 <initlog+0x5e>
    80003e06:	87aa                	mv	a5,a0
    80003e08:	0001e717          	auipc	a4,0x1e
    80003e0c:	6a870713          	addi	a4,a4,1704 # 800224b0 <log+0x30>
    80003e10:	060a                	slli	a2,a2,0x2
    80003e12:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003e14:	4ff4                	lw	a3,92(a5)
    80003e16:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e18:	0791                	addi	a5,a5,4
    80003e1a:	0711                	addi	a4,a4,4
    80003e1c:	fec79ce3          	bne	a5,a2,80003e14 <initlog+0x52>
  brelse(buf);
    80003e20:	81cff0ef          	jal	80002e3c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003e24:	4505                	li	a0,1
    80003e26:	ed1ff0ef          	jal	80003cf6 <install_trans>
  log.lh.n = 0;
    80003e2a:	0001e797          	auipc	a5,0x1e
    80003e2e:	6807a123          	sw	zero,1666(a5) # 800224ac <log+0x2c>
  write_head(); // clear the log
    80003e32:	e67ff0ef          	jal	80003c98 <write_head>
}
    80003e36:	70a2                	ld	ra,40(sp)
    80003e38:	7402                	ld	s0,32(sp)
    80003e3a:	64e2                	ld	s1,24(sp)
    80003e3c:	6942                	ld	s2,16(sp)
    80003e3e:	69a2                	ld	s3,8(sp)
    80003e40:	6145                	addi	sp,sp,48
    80003e42:	8082                	ret

0000000080003e44 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003e44:	1101                	addi	sp,sp,-32
    80003e46:	ec06                	sd	ra,24(sp)
    80003e48:	e822                	sd	s0,16(sp)
    80003e4a:	e426                	sd	s1,8(sp)
    80003e4c:	e04a                	sd	s2,0(sp)
    80003e4e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003e50:	0001e517          	auipc	a0,0x1e
    80003e54:	63050513          	addi	a0,a0,1584 # 80022480 <log>
    80003e58:	dd1fc0ef          	jal	80000c28 <acquire>
  while (1) {
    if (log.committing) {
    80003e5c:	0001e497          	auipc	s1,0x1e
    80003e60:	62448493          	addi	s1,s1,1572 # 80022480 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003e64:	4979                	li	s2,30
    80003e66:	a821                	j	80003e7e <begin_op+0x3a>
      sleep_prepare(&log);
    80003e68:	8526                	mv	a0,s1
    80003e6a:	962fe0ef          	jal	80001fcc <sleep_prepare>
      release(&log.lock);
    80003e6e:	8526                	mv	a0,s1
    80003e70:	e41fc0ef          	jal	80000cb0 <release>
      sleep();
    80003e74:	994fe0ef          	jal	80002008 <sleep>
      acquire(&log.lock);
    80003e78:	8526                	mv	a0,s1
    80003e7a:	daffc0ef          	jal	80000c28 <acquire>
    if (log.committing) {
    80003e7e:	509c                	lw	a5,32(s1)
    80003e80:	f7e5                	bnez	a5,80003e68 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003e82:	4cd8                	lw	a4,28(s1)
    80003e84:	2705                	addiw	a4,a4,1
    80003e86:	0027179b          	slliw	a5,a4,0x2
    80003e8a:	9fb9                	addw	a5,a5,a4
    80003e8c:	0017979b          	slliw	a5,a5,0x1
    80003e90:	54d4                	lw	a3,44(s1)
    80003e92:	9fb5                	addw	a5,a5,a3
    80003e94:	00f95e63          	bge	s2,a5,80003eb0 <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003e98:	8526                	mv	a0,s1
    80003e9a:	932fe0ef          	jal	80001fcc <sleep_prepare>
      release(&log.lock);
    80003e9e:	8526                	mv	a0,s1
    80003ea0:	e11fc0ef          	jal	80000cb0 <release>
      sleep();
    80003ea4:	964fe0ef          	jal	80002008 <sleep>
      acquire(&log.lock);
    80003ea8:	8526                	mv	a0,s1
    80003eaa:	d7ffc0ef          	jal	80000c28 <acquire>
    80003eae:	bfc1                	j	80003e7e <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003eb0:	0001e797          	auipc	a5,0x1e
    80003eb4:	5ee7a623          	sw	a4,1516(a5) # 8002249c <log+0x1c>
      release(&log.lock);
    80003eb8:	0001e517          	auipc	a0,0x1e
    80003ebc:	5c850513          	addi	a0,a0,1480 # 80022480 <log>
    80003ec0:	df1fc0ef          	jal	80000cb0 <release>
      break;
    }
  }
}
    80003ec4:	60e2                	ld	ra,24(sp)
    80003ec6:	6442                	ld	s0,16(sp)
    80003ec8:	64a2                	ld	s1,8(sp)
    80003eca:	6902                	ld	s2,0(sp)
    80003ecc:	6105                	addi	sp,sp,32
    80003ece:	8082                	ret

0000000080003ed0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003ed0:	7139                	addi	sp,sp,-64
    80003ed2:	fc06                	sd	ra,56(sp)
    80003ed4:	f822                	sd	s0,48(sp)
    80003ed6:	f426                	sd	s1,40(sp)
    80003ed8:	f04a                	sd	s2,32(sp)
    80003eda:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003edc:	0001e497          	auipc	s1,0x1e
    80003ee0:	5a448493          	addi	s1,s1,1444 # 80022480 <log>
    80003ee4:	8526                	mv	a0,s1
    80003ee6:	d43fc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003eea:	4cdc                	lw	a5,28(s1)
    80003eec:	37fd                	addiw	a5,a5,-1
    80003eee:	893e                	mv	s2,a5
    80003ef0:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003ef2:	509c                	lw	a5,32(s1)
    80003ef4:	e3b1                	bnez	a5,80003f38 <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003ef6:	04091a63          	bnez	s2,80003f4a <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    80003efa:	0001e497          	auipc	s1,0x1e
    80003efe:	58648493          	addi	s1,s1,1414 # 80022480 <log>
    80003f02:	4785                	li	a5,1
    80003f04:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003f06:	8526                	mv	a0,s1
    80003f08:	da9fc0ef          	jal	80000cb0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003f0c:	54dc                	lw	a5,44(s1)
    80003f0e:	06f04063          	bgtz	a5,80003f6e <end_op+0x9e>
    acquire(&log.lock);
    80003f12:	0001e497          	auipc	s1,0x1e
    80003f16:	56e48493          	addi	s1,s1,1390 # 80022480 <log>
    80003f1a:	8526                	mv	a0,s1
    80003f1c:	d0dfc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003f20:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003f24:	549c                	lw	a5,40(s1)
    80003f26:	2785                	addiw	a5,a5,1
    80003f28:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003f2a:	8526                	mv	a0,s1
    80003f2c:	90cfe0ef          	jal	80002038 <wakeup>
    release(&log.lock);
    80003f30:	8526                	mv	a0,s1
    80003f32:	d7ffc0ef          	jal	80000cb0 <release>
}
    80003f36:	a035                	j	80003f62 <end_op+0x92>
    80003f38:	ec4e                	sd	s3,24(sp)
    80003f3a:	e852                	sd	s4,16(sp)
    80003f3c:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003f3e:	00003517          	auipc	a0,0x3
    80003f42:	5ea50513          	addi	a0,a0,1514 # 80007528 <etext+0x528>
    80003f46:	8effc0ef          	jal	80000834 <panic>
    wakeup(&log);
    80003f4a:	0001e517          	auipc	a0,0x1e
    80003f4e:	53650513          	addi	a0,a0,1334 # 80022480 <log>
    80003f52:	8e6fe0ef          	jal	80002038 <wakeup>
  release(&log.lock);
    80003f56:	0001e517          	auipc	a0,0x1e
    80003f5a:	52a50513          	addi	a0,a0,1322 # 80022480 <log>
    80003f5e:	d53fc0ef          	jal	80000cb0 <release>
}
    80003f62:	70e2                	ld	ra,56(sp)
    80003f64:	7442                	ld	s0,48(sp)
    80003f66:	74a2                	ld	s1,40(sp)
    80003f68:	7902                	ld	s2,32(sp)
    80003f6a:	6121                	addi	sp,sp,64
    80003f6c:	8082                	ret
    80003f6e:	ec4e                	sd	s3,24(sp)
    80003f70:	e852                	sd	s4,16(sp)
    80003f72:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f74:	0001ea97          	auipc	s5,0x1e
    80003f78:	53ca8a93          	addi	s5,s5,1340 # 800224b0 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003f7c:	0001ea17          	auipc	s4,0x1e
    80003f80:	504a0a13          	addi	s4,s4,1284 # 80022480 <log>
    80003f84:	018a2583          	lw	a1,24(s4)
    80003f88:	012585bb          	addw	a1,a1,s2
    80003f8c:	2585                	addiw	a1,a1,1
    80003f8e:	024a2503          	lw	a0,36(s4)
    80003f92:	da3fe0ef          	jal	80002d34 <bread>
    80003f96:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003f98:	000aa583          	lw	a1,0(s5)
    80003f9c:	024a2503          	lw	a0,36(s4)
    80003fa0:	d95fe0ef          	jal	80002d34 <bread>
    80003fa4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003fa6:	40000613          	li	a2,1024
    80003faa:	05850593          	addi	a1,a0,88
    80003fae:	05848513          	addi	a0,s1,88
    80003fb2:	d97fc0ef          	jal	80000d48 <memmove>
    bwrite(to); // write the log
    80003fb6:	8526                	mv	a0,s1
    80003fb8:	e53fe0ef          	jal	80002e0a <bwrite>
    brelse(from);
    80003fbc:	854e                	mv	a0,s3
    80003fbe:	e7ffe0ef          	jal	80002e3c <brelse>
    brelse(to);
    80003fc2:	8526                	mv	a0,s1
    80003fc4:	e79fe0ef          	jal	80002e3c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fc8:	2905                	addiw	s2,s2,1
    80003fca:	0a91                	addi	s5,s5,4
    80003fcc:	02ca2783          	lw	a5,44(s4)
    80003fd0:	faf94ae3          	blt	s2,a5,80003f84 <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80003fd4:	cc5ff0ef          	jal	80003c98 <write_head>
    install_trans(0); // Now install writes to home locations
    80003fd8:	4501                	li	a0,0
    80003fda:	d1dff0ef          	jal	80003cf6 <install_trans>
    log.lh.n = 0;
    80003fde:	0001e797          	auipc	a5,0x1e
    80003fe2:	4c07a723          	sw	zero,1230(a5) # 800224ac <log+0x2c>
    write_head(); // Erase the transaction from the log
    80003fe6:	cb3ff0ef          	jal	80003c98 <write_head>
    80003fea:	69e2                	ld	s3,24(sp)
    80003fec:	6a42                	ld	s4,16(sp)
    80003fee:	6aa2                	ld	s5,8(sp)
    80003ff0:	b70d                	j	80003f12 <end_op+0x42>

0000000080003ff2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003ff2:	1101                	addi	sp,sp,-32
    80003ff4:	ec06                	sd	ra,24(sp)
    80003ff6:	e822                	sd	s0,16(sp)
    80003ff8:	e426                	sd	s1,8(sp)
    80003ffa:	1000                	addi	s0,sp,32
    80003ffc:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003ffe:	0001e517          	auipc	a0,0x1e
    80004002:	48250513          	addi	a0,a0,1154 # 80022480 <log>
    80004006:	c23fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    8000400a:	0001e617          	auipc	a2,0x1e
    8000400e:	4a262603          	lw	a2,1186(a2) # 800224ac <log+0x2c>
    80004012:	47f5                	li	a5,29
    80004014:	04c7cd63          	blt	a5,a2,8000406e <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004018:	0001e797          	auipc	a5,0x1e
    8000401c:	4847a783          	lw	a5,1156(a5) # 8002249c <log+0x1c>
    80004020:	04f05d63          	blez	a5,8000407a <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004024:	4781                	li	a5,0
    80004026:	06c05063          	blez	a2,80004086 <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    8000402a:	44cc                	lw	a1,12(s1)
    8000402c:	0001e717          	auipc	a4,0x1e
    80004030:	48470713          	addi	a4,a4,1156 # 800224b0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004034:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80004036:	4314                	lw	a3,0(a4)
    80004038:	04b68763          	beq	a3,a1,80004086 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    8000403c:	2785                	addiw	a5,a5,1
    8000403e:	0711                	addi	a4,a4,4
    80004040:	fef61be3          	bne	a2,a5,80004036 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004044:	060a                	slli	a2,a2,0x2
    80004046:	02060613          	addi	a2,a2,32
    8000404a:	0001e797          	auipc	a5,0x1e
    8000404e:	43678793          	addi	a5,a5,1078 # 80022480 <log>
    80004052:	97b2                	add	a5,a5,a2
    80004054:	44d8                	lw	a4,12(s1)
    80004056:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80004058:	8526                	mv	a0,s1
    8000405a:	e67fe0ef          	jal	80002ec0 <bpin>
    log.lh.n++;
    8000405e:	0001e717          	auipc	a4,0x1e
    80004062:	42270713          	addi	a4,a4,1058 # 80022480 <log>
    80004066:	575c                	lw	a5,44(a4)
    80004068:	2785                	addiw	a5,a5,1
    8000406a:	d75c                	sw	a5,44(a4)
    8000406c:	a815                	j	800040a0 <log_write+0xae>
    panic("too big a transaction");
    8000406e:	00003517          	auipc	a0,0x3
    80004072:	4ca50513          	addi	a0,a0,1226 # 80007538 <etext+0x538>
    80004076:	fbefc0ef          	jal	80000834 <panic>
    panic("log_write outside of trans");
    8000407a:	00003517          	auipc	a0,0x3
    8000407e:	4d650513          	addi	a0,a0,1238 # 80007550 <etext+0x550>
    80004082:	fb2fc0ef          	jal	80000834 <panic>
  log.lh.block[i] = b->blockno;
    80004086:	00279693          	slli	a3,a5,0x2
    8000408a:	02068693          	addi	a3,a3,32
    8000408e:	0001e717          	auipc	a4,0x1e
    80004092:	3f270713          	addi	a4,a4,1010 # 80022480 <log>
    80004096:	9736                	add	a4,a4,a3
    80004098:	44d4                	lw	a3,12(s1)
    8000409a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    8000409c:	faf60ee3          	beq	a2,a5,80004058 <log_write+0x66>
  }
  release(&log.lock);
    800040a0:	0001e517          	auipc	a0,0x1e
    800040a4:	3e050513          	addi	a0,a0,992 # 80022480 <log>
    800040a8:	c09fc0ef          	jal	80000cb0 <release>
}
    800040ac:	60e2                	ld	ra,24(sp)
    800040ae:	6442                	ld	s0,16(sp)
    800040b0:	64a2                	ld	s1,8(sp)
    800040b2:	6105                	addi	sp,sp,32
    800040b4:	8082                	ret

00000000800040b6 <sys_sync>:

uint64
sys_sync(void)
{
    800040b6:	1101                	addi	sp,sp,-32
    800040b8:	ec06                	sd	ra,24(sp)
    800040ba:	e822                	sd	s0,16(sp)
    800040bc:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800040be:	0001e517          	auipc	a0,0x1e
    800040c2:	3c250513          	addi	a0,a0,962 # 80022480 <log>
    800040c6:	b63fc0ef          	jal	80000c28 <acquire>
  if (log.committing || log.outstanding > 0) {
    800040ca:	0001e797          	auipc	a5,0x1e
    800040ce:	3d67a783          	lw	a5,982(a5) # 800224a0 <log+0x20>
    800040d2:	e799                	bnez	a5,800040e0 <sys_sync+0x2a>
    800040d4:	0001e797          	auipc	a5,0x1e
    800040d8:	3c87a783          	lw	a5,968(a5) # 8002249c <log+0x1c>
    800040dc:	02f05c63          	blez	a5,80004114 <sys_sync+0x5e>
    800040e0:	e426                	sd	s1,8(sp)
    800040e2:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    800040e4:	0001e917          	auipc	s2,0x1e
    800040e8:	3c492903          	lw	s2,964(s2) # 800224a8 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    800040ec:	0001e497          	auipc	s1,0x1e
    800040f0:	39448493          	addi	s1,s1,916 # 80022480 <log>
    800040f4:	8526                	mv	a0,s1
    800040f6:	ed7fd0ef          	jal	80001fcc <sleep_prepare>
      release(&log.lock);
    800040fa:	8526                	mv	a0,s1
    800040fc:	bb5fc0ef          	jal	80000cb0 <release>
      sleep();
    80004100:	f09fd0ef          	jal	80002008 <sleep>
      acquire(&log.lock);
    80004104:	8526                	mv	a0,s1
    80004106:	b23fc0ef          	jal	80000c28 <acquire>
    while (log.ncommit < n) {
    8000410a:	549c                	lw	a5,40(s1)
    8000410c:	fef954e3          	bge	s2,a5,800040f4 <sys_sync+0x3e>
    80004110:	64a2                	ld	s1,8(sp)
    80004112:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    80004114:	0001e517          	auipc	a0,0x1e
    80004118:	36c50513          	addi	a0,a0,876 # 80022480 <log>
    8000411c:	b95fc0ef          	jal	80000cb0 <release>
  return 0;
}
    80004120:	4501                	li	a0,0
    80004122:	60e2                	ld	ra,24(sp)
    80004124:	6442                	ld	s0,16(sp)
    80004126:	6105                	addi	sp,sp,32
    80004128:	8082                	ret

000000008000412a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000412a:	1101                	addi	sp,sp,-32
    8000412c:	ec06                	sd	ra,24(sp)
    8000412e:	e822                	sd	s0,16(sp)
    80004130:	e426                	sd	s1,8(sp)
    80004132:	e04a                	sd	s2,0(sp)
    80004134:	1000                	addi	s0,sp,32
    80004136:	84aa                	mv	s1,a0
    80004138:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000413a:	00003597          	auipc	a1,0x3
    8000413e:	43658593          	addi	a1,a1,1078 # 80007570 <etext+0x570>
    80004142:	0521                	addi	a0,a0,8
    80004144:	a65fc0ef          	jal	80000ba8 <initlock>
  lk->name = name;
    80004148:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000414c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004150:	0204a423          	sw	zero,40(s1)
}
    80004154:	60e2                	ld	ra,24(sp)
    80004156:	6442                	ld	s0,16(sp)
    80004158:	64a2                	ld	s1,8(sp)
    8000415a:	6902                	ld	s2,0(sp)
    8000415c:	6105                	addi	sp,sp,32
    8000415e:	8082                	ret

0000000080004160 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004160:	1101                	addi	sp,sp,-32
    80004162:	ec06                	sd	ra,24(sp)
    80004164:	e822                	sd	s0,16(sp)
    80004166:	e426                	sd	s1,8(sp)
    80004168:	e04a                	sd	s2,0(sp)
    8000416a:	1000                	addi	s0,sp,32
    8000416c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000416e:	00850913          	addi	s2,a0,8
    80004172:	854a                	mv	a0,s2
    80004174:	ab5fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80004178:	409c                	lw	a5,0(s1)
    8000417a:	cf91                	beqz	a5,80004196 <acquiresleep+0x36>
    sleep_prepare(lk);
    8000417c:	8526                	mv	a0,s1
    8000417e:	e4ffd0ef          	jal	80001fcc <sleep_prepare>
    release(&lk->lk);
    80004182:	854a                	mv	a0,s2
    80004184:	b2dfc0ef          	jal	80000cb0 <release>
    sleep();
    80004188:	e81fd0ef          	jal	80002008 <sleep>
    acquire(&lk->lk);
    8000418c:	854a                	mv	a0,s2
    8000418e:	a9bfc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80004192:	409c                	lw	a5,0(s1)
    80004194:	f7e5                	bnez	a5,8000417c <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004196:	4785                	li	a5,1
    80004198:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000419a:	fb2fd0ef          	jal	8000194c <myproc>
    8000419e:	591c                	lw	a5,48(a0)
    800041a0:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800041a2:	854a                	mv	a0,s2
    800041a4:	b0dfc0ef          	jal	80000cb0 <release>
}
    800041a8:	60e2                	ld	ra,24(sp)
    800041aa:	6442                	ld	s0,16(sp)
    800041ac:	64a2                	ld	s1,8(sp)
    800041ae:	6902                	ld	s2,0(sp)
    800041b0:	6105                	addi	sp,sp,32
    800041b2:	8082                	ret

00000000800041b4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800041b4:	1101                	addi	sp,sp,-32
    800041b6:	ec06                	sd	ra,24(sp)
    800041b8:	e822                	sd	s0,16(sp)
    800041ba:	e426                	sd	s1,8(sp)
    800041bc:	e04a                	sd	s2,0(sp)
    800041be:	1000                	addi	s0,sp,32
    800041c0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800041c2:	00850913          	addi	s2,a0,8
    800041c6:	854a                	mv	a0,s2
    800041c8:	a61fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    800041cc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800041d0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800041d4:	8526                	mv	a0,s1
    800041d6:	e63fd0ef          	jal	80002038 <wakeup>
  release(&lk->lk);
    800041da:	854a                	mv	a0,s2
    800041dc:	ad5fc0ef          	jal	80000cb0 <release>
}
    800041e0:	60e2                	ld	ra,24(sp)
    800041e2:	6442                	ld	s0,16(sp)
    800041e4:	64a2                	ld	s1,8(sp)
    800041e6:	6902                	ld	s2,0(sp)
    800041e8:	6105                	addi	sp,sp,32
    800041ea:	8082                	ret

00000000800041ec <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800041ec:	7179                	addi	sp,sp,-48
    800041ee:	f406                	sd	ra,40(sp)
    800041f0:	f022                	sd	s0,32(sp)
    800041f2:	ec26                	sd	s1,24(sp)
    800041f4:	e84a                	sd	s2,16(sp)
    800041f6:	1800                	addi	s0,sp,48
    800041f8:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    800041fa:	00850913          	addi	s2,a0,8
    800041fe:	854a                	mv	a0,s2
    80004200:	a29fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004204:	409c                	lw	a5,0(s1)
    80004206:	ef81                	bnez	a5,8000421e <holdingsleep+0x32>
    80004208:	4481                	li	s1,0
  release(&lk->lk);
    8000420a:	854a                	mv	a0,s2
    8000420c:	aa5fc0ef          	jal	80000cb0 <release>
  return r;
}
    80004210:	8526                	mv	a0,s1
    80004212:	70a2                	ld	ra,40(sp)
    80004214:	7402                	ld	s0,32(sp)
    80004216:	64e2                	ld	s1,24(sp)
    80004218:	6942                	ld	s2,16(sp)
    8000421a:	6145                	addi	sp,sp,48
    8000421c:	8082                	ret
    8000421e:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004220:	0284a983          	lw	s3,40(s1)
    80004224:	f28fd0ef          	jal	8000194c <myproc>
    80004228:	5904                	lw	s1,48(a0)
    8000422a:	413484b3          	sub	s1,s1,s3
    8000422e:	0014b493          	seqz	s1,s1
    80004232:	69a2                	ld	s3,8(sp)
    80004234:	bfd9                	j	8000420a <holdingsleep+0x1e>

0000000080004236 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004236:	1141                	addi	sp,sp,-16
    80004238:	e406                	sd	ra,8(sp)
    8000423a:	e022                	sd	s0,0(sp)
    8000423c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000423e:	00003597          	auipc	a1,0x3
    80004242:	34258593          	addi	a1,a1,834 # 80007580 <etext+0x580>
    80004246:	0001e517          	auipc	a0,0x1e
    8000424a:	38250513          	addi	a0,a0,898 # 800225c8 <ftable>
    8000424e:	95bfc0ef          	jal	80000ba8 <initlock>
}
    80004252:	60a2                	ld	ra,8(sp)
    80004254:	6402                	ld	s0,0(sp)
    80004256:	0141                	addi	sp,sp,16
    80004258:	8082                	ret

000000008000425a <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    8000425a:	1101                	addi	sp,sp,-32
    8000425c:	ec06                	sd	ra,24(sp)
    8000425e:	e822                	sd	s0,16(sp)
    80004260:	e426                	sd	s1,8(sp)
    80004262:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004264:	0001e517          	auipc	a0,0x1e
    80004268:	36450513          	addi	a0,a0,868 # 800225c8 <ftable>
    8000426c:	9bdfc0ef          	jal	80000c28 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004270:	0001e497          	auipc	s1,0x1e
    80004274:	37048493          	addi	s1,s1,880 # 800225e0 <ftable+0x18>
    80004278:	0001f717          	auipc	a4,0x1f
    8000427c:	30870713          	addi	a4,a4,776 # 80023580 <disk>
    if (f->ref == 0) {
    80004280:	40dc                	lw	a5,4(s1)
    80004282:	cf89                	beqz	a5,8000429c <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004284:	02848493          	addi	s1,s1,40
    80004288:	fee49ce3          	bne	s1,a4,80004280 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000428c:	0001e517          	auipc	a0,0x1e
    80004290:	33c50513          	addi	a0,a0,828 # 800225c8 <ftable>
    80004294:	a1dfc0ef          	jal	80000cb0 <release>
  return 0;
    80004298:	4481                	li	s1,0
    8000429a:	a809                	j	800042ac <filealloc+0x52>
      f->ref = 1;
    8000429c:	4785                	li	a5,1
    8000429e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800042a0:	0001e517          	auipc	a0,0x1e
    800042a4:	32850513          	addi	a0,a0,808 # 800225c8 <ftable>
    800042a8:	a09fc0ef          	jal	80000cb0 <release>
}
    800042ac:	8526                	mv	a0,s1
    800042ae:	60e2                	ld	ra,24(sp)
    800042b0:	6442                	ld	s0,16(sp)
    800042b2:	64a2                	ld	s1,8(sp)
    800042b4:	6105                	addi	sp,sp,32
    800042b6:	8082                	ret

00000000800042b8 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    800042b8:	1101                	addi	sp,sp,-32
    800042ba:	ec06                	sd	ra,24(sp)
    800042bc:	e822                	sd	s0,16(sp)
    800042be:	e426                	sd	s1,8(sp)
    800042c0:	1000                	addi	s0,sp,32
    800042c2:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800042c4:	0001e517          	auipc	a0,0x1e
    800042c8:	30450513          	addi	a0,a0,772 # 800225c8 <ftable>
    800042cc:	95dfc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    800042d0:	40dc                	lw	a5,4(s1)
    800042d2:	02f05063          	blez	a5,800042f2 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800042d6:	2785                	addiw	a5,a5,1
    800042d8:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800042da:	0001e517          	auipc	a0,0x1e
    800042de:	2ee50513          	addi	a0,a0,750 # 800225c8 <ftable>
    800042e2:	9cffc0ef          	jal	80000cb0 <release>
  return f;
}
    800042e6:	8526                	mv	a0,s1
    800042e8:	60e2                	ld	ra,24(sp)
    800042ea:	6442                	ld	s0,16(sp)
    800042ec:	64a2                	ld	s1,8(sp)
    800042ee:	6105                	addi	sp,sp,32
    800042f0:	8082                	ret
    panic("filedup");
    800042f2:	00003517          	auipc	a0,0x3
    800042f6:	29650513          	addi	a0,a0,662 # 80007588 <etext+0x588>
    800042fa:	d3afc0ef          	jal	80000834 <panic>

00000000800042fe <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800042fe:	7139                	addi	sp,sp,-64
    80004300:	fc06                	sd	ra,56(sp)
    80004302:	f822                	sd	s0,48(sp)
    80004304:	f426                	sd	s1,40(sp)
    80004306:	0080                	addi	s0,sp,64
    80004308:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000430a:	0001e517          	auipc	a0,0x1e
    8000430e:	2be50513          	addi	a0,a0,702 # 800225c8 <ftable>
    80004312:	917fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    80004316:	40dc                	lw	a5,4(s1)
    80004318:	04f05a63          	blez	a5,8000436c <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    8000431c:	37fd                	addiw	a5,a5,-1
    8000431e:	c0dc                	sw	a5,4(s1)
    80004320:	06f04063          	bgtz	a5,80004380 <fileclose+0x82>
    80004324:	f04a                	sd	s2,32(sp)
    80004326:	ec4e                	sd	s3,24(sp)
    80004328:	e852                	sd	s4,16(sp)
    8000432a:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000432c:	0004a903          	lw	s2,0(s1)
    80004330:	0094c783          	lbu	a5,9(s1)
    80004334:	89be                	mv	s3,a5
    80004336:	689c                	ld	a5,16(s1)
    80004338:	8a3e                	mv	s4,a5
    8000433a:	6c9c                	ld	a5,24(s1)
    8000433c:	8abe                	mv	s5,a5
  f->ref = 0;
    8000433e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004342:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004346:	0001e517          	auipc	a0,0x1e
    8000434a:	28250513          	addi	a0,a0,642 # 800225c8 <ftable>
    8000434e:	963fc0ef          	jal	80000cb0 <release>

  if (ff.type == FD_PIPE) {
    80004352:	4785                	li	a5,1
    80004354:	04f90163          	beq	s2,a5,80004396 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    80004358:	ffe9079b          	addiw	a5,s2,-2
    8000435c:	4705                	li	a4,1
    8000435e:	04f77563          	bgeu	a4,a5,800043a8 <fileclose+0xaa>
    80004362:	7902                	ld	s2,32(sp)
    80004364:	69e2                	ld	s3,24(sp)
    80004366:	6a42                	ld	s4,16(sp)
    80004368:	6aa2                	ld	s5,8(sp)
    8000436a:	a00d                	j	8000438c <fileclose+0x8e>
    8000436c:	f04a                	sd	s2,32(sp)
    8000436e:	ec4e                	sd	s3,24(sp)
    80004370:	e852                	sd	s4,16(sp)
    80004372:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004374:	00003517          	auipc	a0,0x3
    80004378:	21c50513          	addi	a0,a0,540 # 80007590 <etext+0x590>
    8000437c:	cb8fc0ef          	jal	80000834 <panic>
    release(&ftable.lock);
    80004380:	0001e517          	auipc	a0,0x1e
    80004384:	24850513          	addi	a0,a0,584 # 800225c8 <ftable>
    80004388:	929fc0ef          	jal	80000cb0 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000438c:	70e2                	ld	ra,56(sp)
    8000438e:	7442                	ld	s0,48(sp)
    80004390:	74a2                	ld	s1,40(sp)
    80004392:	6121                	addi	sp,sp,64
    80004394:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004396:	85ce                	mv	a1,s3
    80004398:	8552                	mv	a0,s4
    8000439a:	36a000ef          	jal	80004704 <pipeclose>
    8000439e:	7902                	ld	s2,32(sp)
    800043a0:	69e2                	ld	s3,24(sp)
    800043a2:	6a42                	ld	s4,16(sp)
    800043a4:	6aa2                	ld	s5,8(sp)
    800043a6:	b7dd                	j	8000438c <fileclose+0x8e>
    begin_op();
    800043a8:	a9dff0ef          	jal	80003e44 <begin_op>
    iput(ff.ip);
    800043ac:	8556                	mv	a0,s5
    800043ae:	9a0ff0ef          	jal	8000354e <iput>
    end_op();
    800043b2:	b1fff0ef          	jal	80003ed0 <end_op>
    800043b6:	7902                	ld	s2,32(sp)
    800043b8:	69e2                	ld	s3,24(sp)
    800043ba:	6a42                	ld	s4,16(sp)
    800043bc:	6aa2                	ld	s5,8(sp)
    800043be:	b7f9                	j	8000438c <fileclose+0x8e>

00000000800043c0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800043c0:	715d                	addi	sp,sp,-80
    800043c2:	e486                	sd	ra,72(sp)
    800043c4:	e0a2                	sd	s0,64(sp)
    800043c6:	fc26                	sd	s1,56(sp)
    800043c8:	f052                	sd	s4,32(sp)
    800043ca:	0880                	addi	s0,sp,80
    800043cc:	84aa                	mv	s1,a0
    800043ce:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    800043d0:	d7cfd0ef          	jal	8000194c <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    800043d4:	409c                	lw	a5,0(s1)
    800043d6:	37f9                	addiw	a5,a5,-2
    800043d8:	4705                	li	a4,1
    800043da:	04f76963          	bltu	a4,a5,8000442c <filestat+0x6c>
    800043de:	f84a                	sd	s2,48(sp)
    800043e0:	f44e                	sd	s3,40(sp)
    800043e2:	892a                	mv	s2,a0
    memset(&st, 0, sizeof(st));
    800043e4:	fb840993          	addi	s3,s0,-72
    800043e8:	4661                	li	a2,24
    800043ea:	4581                	li	a1,0
    800043ec:	854e                	mv	a0,s3
    800043ee:	8fbfc0ef          	jal	80000ce8 <memset>
    ilock(f->ip);
    800043f2:	6c88                	ld	a0,24(s1)
    800043f4:	fd9fe0ef          	jal	800033cc <ilock>
    stati(f->ip, &st);
    800043f8:	85ce                	mv	a1,s3
    800043fa:	6c88                	ld	a0,24(s1)
    800043fc:	b7cff0ef          	jal	80003778 <stati>
    iunlock(f->ip);
    80004400:	6c88                	ld	a0,24(s1)
    80004402:	878ff0ef          	jal	8000347a <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    80004406:	4761                	li	a4,24
    80004408:	86ce                	mv	a3,s3
    8000440a:	8652                	mv	a2,s4
    8000440c:	04893583          	ld	a1,72(s2)
    80004410:	05093503          	ld	a0,80(s2)
    80004414:	972fd0ef          	jal	80001586 <copyout>
    80004418:	41f5551b          	sraiw	a0,a0,0x1f
    8000441c:	7942                	ld	s2,48(sp)
    8000441e:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004420:	60a6                	ld	ra,72(sp)
    80004422:	6406                	ld	s0,64(sp)
    80004424:	74e2                	ld	s1,56(sp)
    80004426:	7a02                	ld	s4,32(sp)
    80004428:	6161                	addi	sp,sp,80
    8000442a:	8082                	ret
  return -1;
    8000442c:	557d                	li	a0,-1
    8000442e:	bfcd                	j	80004420 <filestat+0x60>

0000000080004430 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004430:	7179                	addi	sp,sp,-48
    80004432:	f406                	sd	ra,40(sp)
    80004434:	f022                	sd	s0,32(sp)
    80004436:	e84a                	sd	s2,16(sp)
    80004438:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    8000443a:	00854783          	lbu	a5,8(a0)
    8000443e:	c3dd                	beqz	a5,800044e4 <fileread+0xb4>
    80004440:	ec26                	sd	s1,24(sp)
    80004442:	e44e                	sd	s3,8(sp)
    80004444:	84aa                	mv	s1,a0
    80004446:	892e                	mv	s2,a1
    80004448:	89b2                	mv	s3,a2
    8000444a:	01f6579b          	srliw	a5,a2,0x1f
    8000444e:	ebc9                	bnez	a5,800044e0 <fileread+0xb0>
    return -1;

  if (f->type == FD_PIPE) {
    80004450:	411c                	lw	a5,0(a0)
    80004452:	4705                	li	a4,1
    80004454:	04e78363          	beq	a5,a4,8000449a <fileread+0x6a>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    80004458:	470d                	li	a4,3
    8000445a:	04e78763          	beq	a5,a4,800044a8 <fileread+0x78>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    8000445e:	4709                	li	a4,2
    80004460:	06e79a63          	bne	a5,a4,800044d4 <fileread+0xa4>
    ilock(f->ip);
    80004464:	6d08                	ld	a0,24(a0)
    80004466:	f67fe0ef          	jal	800033cc <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000446a:	874e                	mv	a4,s3
    8000446c:	5094                	lw	a3,32(s1)
    8000446e:	864a                	mv	a2,s2
    80004470:	4585                	li	a1,1
    80004472:	6c88                	ld	a0,24(s1)
    80004474:	b32ff0ef          	jal	800037a6 <readi>
    80004478:	892a                	mv	s2,a0
    8000447a:	00a05563          	blez	a0,80004484 <fileread+0x54>
      f->off += r;
    8000447e:	509c                	lw	a5,32(s1)
    80004480:	9fa9                	addw	a5,a5,a0
    80004482:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004484:	6c88                	ld	a0,24(s1)
    80004486:	ff5fe0ef          	jal	8000347a <iunlock>
    8000448a:	64e2                	ld	s1,24(sp)
    8000448c:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000448e:	854a                	mv	a0,s2
    80004490:	70a2                	ld	ra,40(sp)
    80004492:	7402                	ld	s0,32(sp)
    80004494:	6942                	ld	s2,16(sp)
    80004496:	6145                	addi	sp,sp,48
    80004498:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000449a:	6908                	ld	a0,16(a0)
    8000449c:	3e2000ef          	jal	8000487e <piperead>
    800044a0:	892a                	mv	s2,a0
    800044a2:	64e2                	ld	s1,24(sp)
    800044a4:	69a2                	ld	s3,8(sp)
    800044a6:	b7e5                	j	8000448e <fileread+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800044a8:	02451783          	lh	a5,36(a0)
    800044ac:	03079693          	slli	a3,a5,0x30
    800044b0:	92c1                	srli	a3,a3,0x30
    800044b2:	4725                	li	a4,9
    800044b4:	02d76b63          	bltu	a4,a3,800044ea <fileread+0xba>
    800044b8:	0792                	slli	a5,a5,0x4
    800044ba:	0001e717          	auipc	a4,0x1e
    800044be:	06e70713          	addi	a4,a4,110 # 80022528 <devsw>
    800044c2:	97ba                	add	a5,a5,a4
    800044c4:	639c                	ld	a5,0(a5)
    800044c6:	c79d                	beqz	a5,800044f4 <fileread+0xc4>
    r = devsw[f->major].read(1, addr, n);
    800044c8:	4505                	li	a0,1
    800044ca:	9782                	jalr	a5
    800044cc:	892a                	mv	s2,a0
    800044ce:	64e2                	ld	s1,24(sp)
    800044d0:	69a2                	ld	s3,8(sp)
    800044d2:	bf75                	j	8000448e <fileread+0x5e>
    panic("fileread");
    800044d4:	00003517          	auipc	a0,0x3
    800044d8:	0cc50513          	addi	a0,a0,204 # 800075a0 <etext+0x5a0>
    800044dc:	b58fc0ef          	jal	80000834 <panic>
    800044e0:	64e2                	ld	s1,24(sp)
    800044e2:	69a2                	ld	s3,8(sp)
    return -1;
    800044e4:	57fd                	li	a5,-1
    800044e6:	893e                	mv	s2,a5
    800044e8:	b75d                	j	8000448e <fileread+0x5e>
      return -1;
    800044ea:	57fd                	li	a5,-1
    800044ec:	893e                	mv	s2,a5
    800044ee:	64e2                	ld	s1,24(sp)
    800044f0:	69a2                	ld	s3,8(sp)
    800044f2:	bf71                	j	8000448e <fileread+0x5e>
    800044f4:	57fd                	li	a5,-1
    800044f6:	893e                	mv	s2,a5
    800044f8:	64e2                	ld	s1,24(sp)
    800044fa:	69a2                	ld	s3,8(sp)
    800044fc:	bf49                	j	8000448e <fileread+0x5e>

00000000800044fe <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    800044fe:	00954783          	lbu	a5,9(a0)
    80004502:	12078b63          	beqz	a5,80004638 <filewrite+0x13a>
{
    80004506:	711d                	addi	sp,sp,-96
    80004508:	ec86                	sd	ra,88(sp)
    8000450a:	e8a2                	sd	s0,80(sp)
    8000450c:	e0ca                	sd	s2,64(sp)
    8000450e:	f456                	sd	s5,40(sp)
    80004510:	f05a                	sd	s6,32(sp)
    80004512:	1080                	addi	s0,sp,96
    80004514:	892a                	mv	s2,a0
    80004516:	8b2e                	mv	s6,a1
    80004518:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    8000451a:	01f6579b          	srliw	a5,a2,0x1f
    8000451e:	0e079d63          	bnez	a5,80004618 <filewrite+0x11a>
    return -1;

  if (f->type == FD_PIPE) {
    80004522:	411c                	lw	a5,0(a0)
    80004524:	4705                	li	a4,1
    80004526:	02e78a63          	beq	a5,a4,8000455a <filewrite+0x5c>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    8000452a:	470d                	li	a4,3
    8000452c:	02e78b63          	beq	a5,a4,80004562 <filewrite+0x64>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004530:	4709                	li	a4,2
    80004532:	0ce79763          	bne	a5,a4,80004600 <filewrite+0x102>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    80004536:	0ec05763          	blez	a2,80004624 <filewrite+0x126>
    8000453a:	e4a6                	sd	s1,72(sp)
    8000453c:	fc4e                	sd	s3,56(sp)
    8000453e:	f852                	sd	s4,48(sp)
    80004540:	ec5e                	sd	s7,24(sp)
    80004542:	e862                	sd	s8,16(sp)
    80004544:	e466                	sd	s9,8(sp)
    int i = 0;
    80004546:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    80004548:	6b85                	lui	s7,0x1
    8000454a:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000454e:	6785                	lui	a5,0x1
    80004550:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004554:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004556:	4c05                	li	s8,1
    80004558:	a8ad                	j	800045d2 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    8000455a:	6908                	ld	a0,16(a0)
    8000455c:	206000ef          	jal	80004762 <pipewrite>
    80004560:	a849                	j	800045f2 <filewrite+0xf4>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004562:	02451783          	lh	a5,36(a0)
    80004566:	03079693          	slli	a3,a5,0x30
    8000456a:	92c1                	srli	a3,a3,0x30
    8000456c:	4725                	li	a4,9
    8000456e:	0ad76763          	bltu	a4,a3,8000461c <filewrite+0x11e>
    80004572:	0792                	slli	a5,a5,0x4
    80004574:	0001e717          	auipc	a4,0x1e
    80004578:	fb470713          	addi	a4,a4,-76 # 80022528 <devsw>
    8000457c:	97ba                	add	a5,a5,a4
    8000457e:	679c                	ld	a5,8(a5)
    80004580:	c3c5                	beqz	a5,80004620 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004582:	4505                	li	a0,1
    80004584:	9782                	jalr	a5
    80004586:	a0b5                	j	800045f2 <filewrite+0xf4>
      if (n1 > max)
    80004588:	2981                	sext.w	s3,s3
      begin_op();
    8000458a:	8bbff0ef          	jal	80003e44 <begin_op>
      ilock(f->ip);
    8000458e:	01893503          	ld	a0,24(s2)
    80004592:	e3bfe0ef          	jal	800033cc <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004596:	874e                	mv	a4,s3
    80004598:	02092683          	lw	a3,32(s2)
    8000459c:	016a0633          	add	a2,s4,s6
    800045a0:	85e2                	mv	a1,s8
    800045a2:	01893503          	ld	a0,24(s2)
    800045a6:	af2ff0ef          	jal	80003898 <writei>
    800045aa:	84aa                	mv	s1,a0
    800045ac:	00a05763          	blez	a0,800045ba <filewrite+0xbc>
        f->off += r;
    800045b0:	02092783          	lw	a5,32(s2)
    800045b4:	9fa9                	addw	a5,a5,a0
    800045b6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800045ba:	01893503          	ld	a0,24(s2)
    800045be:	ebdfe0ef          	jal	8000347a <iunlock>
      end_op();
    800045c2:	90fff0ef          	jal	80003ed0 <end_op>

      if (r != n1) {
    800045c6:	00999d63          	bne	s3,s1,800045e0 <filewrite+0xe2>
        // error from writei
        break;
      }
      i += r;
    800045ca:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    800045ce:	015a5963          	bge	s4,s5,800045e0 <filewrite+0xe2>
      int n1 = n - i;
    800045d2:	414a87bb          	subw	a5,s5,s4
    800045d6:	89be                	mv	s3,a5
      if (n1 > max)
    800045d8:	fafbd8e3          	bge	s7,a5,80004588 <filewrite+0x8a>
    800045dc:	89e6                	mv	s3,s9
    800045de:	b76d                	j	80004588 <filewrite+0x8a>
    }
    ret = (i == n ? n : -1);
    800045e0:	054a9463          	bne	s5,s4,80004628 <filewrite+0x12a>
    800045e4:	8556                	mv	a0,s5
    800045e6:	64a6                	ld	s1,72(sp)
    800045e8:	79e2                	ld	s3,56(sp)
    800045ea:	7a42                	ld	s4,48(sp)
    800045ec:	6be2                	ld	s7,24(sp)
    800045ee:	6c42                	ld	s8,16(sp)
    800045f0:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800045f2:	60e6                	ld	ra,88(sp)
    800045f4:	6446                	ld	s0,80(sp)
    800045f6:	6906                	ld	s2,64(sp)
    800045f8:	7aa2                	ld	s5,40(sp)
    800045fa:	7b02                	ld	s6,32(sp)
    800045fc:	6125                	addi	sp,sp,96
    800045fe:	8082                	ret
    80004600:	e4a6                	sd	s1,72(sp)
    80004602:	fc4e                	sd	s3,56(sp)
    80004604:	f852                	sd	s4,48(sp)
    80004606:	ec5e                	sd	s7,24(sp)
    80004608:	e862                	sd	s8,16(sp)
    8000460a:	e466                	sd	s9,8(sp)
    panic("filewrite");
    8000460c:	00003517          	auipc	a0,0x3
    80004610:	fa450513          	addi	a0,a0,-92 # 800075b0 <etext+0x5b0>
    80004614:	a20fc0ef          	jal	80000834 <panic>
    return -1;
    80004618:	557d                	li	a0,-1
    8000461a:	bfe1                	j	800045f2 <filewrite+0xf4>
      return -1;
    8000461c:	557d                	li	a0,-1
    8000461e:	bfd1                	j	800045f2 <filewrite+0xf4>
    80004620:	557d                	li	a0,-1
    80004622:	bfc1                	j	800045f2 <filewrite+0xf4>
    ret = (i == n ? n : -1);
    80004624:	8532                	mv	a0,a2
    80004626:	b7f1                	j	800045f2 <filewrite+0xf4>
    80004628:	557d                	li	a0,-1
    8000462a:	64a6                	ld	s1,72(sp)
    8000462c:	79e2                	ld	s3,56(sp)
    8000462e:	7a42                	ld	s4,48(sp)
    80004630:	6be2                	ld	s7,24(sp)
    80004632:	6c42                	ld	s8,16(sp)
    80004634:	6ca2                	ld	s9,8(sp)
    80004636:	bf75                	j	800045f2 <filewrite+0xf4>
    return -1;
    80004638:	557d                	li	a0,-1
}
    8000463a:	8082                	ret

000000008000463c <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000463c:	7179                	addi	sp,sp,-48
    8000463e:	f406                	sd	ra,40(sp)
    80004640:	f022                	sd	s0,32(sp)
    80004642:	ec26                	sd	s1,24(sp)
    80004644:	e052                	sd	s4,0(sp)
    80004646:	1800                	addi	s0,sp,48
    80004648:	84aa                	mv	s1,a0
    8000464a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000464c:	0005b023          	sd	zero,0(a1)
    80004650:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004654:	c07ff0ef          	jal	8000425a <filealloc>
    80004658:	e088                	sd	a0,0(s1)
    8000465a:	c549                	beqz	a0,800046e4 <pipealloc+0xa8>
    8000465c:	bffff0ef          	jal	8000425a <filealloc>
    80004660:	00aa3023          	sd	a0,0(s4)
    80004664:	cd25                	beqz	a0,800046dc <pipealloc+0xa0>
    80004666:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    80004668:	ce6fc0ef          	jal	80000b4e <kalloc>
    8000466c:	892a                	mv	s2,a0
    8000466e:	c12d                	beqz	a0,800046d0 <pipealloc+0x94>
    80004670:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004672:	4985                	li	s3,1
    80004674:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004678:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000467c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004680:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004684:	00003597          	auipc	a1,0x3
    80004688:	f3c58593          	addi	a1,a1,-196 # 800075c0 <etext+0x5c0>
    8000468c:	d1cfc0ef          	jal	80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    80004690:	609c                	ld	a5,0(s1)
    80004692:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004696:	609c                	ld	a5,0(s1)
    80004698:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000469c:	609c                	ld	a5,0(s1)
    8000469e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800046a2:	609c                	ld	a5,0(s1)
    800046a4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800046a8:	000a3783          	ld	a5,0(s4)
    800046ac:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800046b0:	000a3783          	ld	a5,0(s4)
    800046b4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800046b8:	000a3783          	ld	a5,0(s4)
    800046bc:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800046c0:	000a3783          	ld	a5,0(s4)
    800046c4:	0127b823          	sd	s2,16(a5)
  return 0;
    800046c8:	4501                	li	a0,0
    800046ca:	6942                	ld	s2,16(sp)
    800046cc:	69a2                	ld	s3,8(sp)
    800046ce:	a01d                	j	800046f4 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    800046d0:	6088                	ld	a0,0(s1)
    800046d2:	c119                	beqz	a0,800046d8 <pipealloc+0x9c>
    800046d4:	6942                	ld	s2,16(sp)
    800046d6:	a029                	j	800046e0 <pipealloc+0xa4>
    800046d8:	6942                	ld	s2,16(sp)
    800046da:	a029                	j	800046e4 <pipealloc+0xa8>
    800046dc:	6088                	ld	a0,0(s1)
    800046de:	c10d                	beqz	a0,80004700 <pipealloc+0xc4>
    fileclose(*f0);
    800046e0:	c1fff0ef          	jal	800042fe <fileclose>
  if (*f1)
    800046e4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800046e8:	557d                	li	a0,-1
  if (*f1)
    800046ea:	c789                	beqz	a5,800046f4 <pipealloc+0xb8>
    fileclose(*f1);
    800046ec:	853e                	mv	a0,a5
    800046ee:	c11ff0ef          	jal	800042fe <fileclose>
  return -1;
    800046f2:	557d                	li	a0,-1
}
    800046f4:	70a2                	ld	ra,40(sp)
    800046f6:	7402                	ld	s0,32(sp)
    800046f8:	64e2                	ld	s1,24(sp)
    800046fa:	6a02                	ld	s4,0(sp)
    800046fc:	6145                	addi	sp,sp,48
    800046fe:	8082                	ret
  return -1;
    80004700:	557d                	li	a0,-1
    80004702:	bfcd                	j	800046f4 <pipealloc+0xb8>

0000000080004704 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004704:	1101                	addi	sp,sp,-32
    80004706:	ec06                	sd	ra,24(sp)
    80004708:	e822                	sd	s0,16(sp)
    8000470a:	e426                	sd	s1,8(sp)
    8000470c:	e04a                	sd	s2,0(sp)
    8000470e:	1000                	addi	s0,sp,32
    80004710:	84aa                	mv	s1,a0
    80004712:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004714:	d14fc0ef          	jal	80000c28 <acquire>
  if (writable) {
    80004718:	02090763          	beqz	s2,80004746 <pipeclose+0x42>
    pi->writeopen = 0;
    8000471c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004720:	21848513          	addi	a0,s1,536
    80004724:	915fd0ef          	jal	80002038 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    80004728:	2204a783          	lw	a5,544(s1)
    8000472c:	e781                	bnez	a5,80004734 <pipeclose+0x30>
    8000472e:	2244a783          	lw	a5,548(s1)
    80004732:	c38d                	beqz	a5,80004754 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    80004734:	8526                	mv	a0,s1
    80004736:	d7afc0ef          	jal	80000cb0 <release>
}
    8000473a:	60e2                	ld	ra,24(sp)
    8000473c:	6442                	ld	s0,16(sp)
    8000473e:	64a2                	ld	s1,8(sp)
    80004740:	6902                	ld	s2,0(sp)
    80004742:	6105                	addi	sp,sp,32
    80004744:	8082                	ret
    pi->readopen = 0;
    80004746:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000474a:	21c48513          	addi	a0,s1,540
    8000474e:	8ebfd0ef          	jal	80002038 <wakeup>
    80004752:	bfd9                	j	80004728 <pipeclose+0x24>
    release(&pi->lock);
    80004754:	8526                	mv	a0,s1
    80004756:	d5afc0ef          	jal	80000cb0 <release>
    kfree((char *)pi);
    8000475a:	8526                	mv	a0,s1
    8000475c:	b0afc0ef          	jal	80000a66 <kfree>
    80004760:	bfe9                	j	8000473a <pipeclose+0x36>

0000000080004762 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004762:	7159                	addi	sp,sp,-112
    80004764:	f486                	sd	ra,104(sp)
    80004766:	f0a2                	sd	s0,96(sp)
    80004768:	eca6                	sd	s1,88(sp)
    8000476a:	e8ca                	sd	s2,80(sp)
    8000476c:	e4ce                	sd	s3,72(sp)
    8000476e:	e0d2                	sd	s4,64(sp)
    80004770:	fc56                	sd	s5,56(sp)
    80004772:	1880                	addi	s0,sp,112
    80004774:	84aa                	mv	s1,a0
    80004776:	8aae                	mv	s5,a1
    80004778:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000477a:	9d2fd0ef          	jal	8000194c <myproc>
    8000477e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004780:	8526                	mv	a0,s1
    80004782:	ca6fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    80004786:	0f405a63          	blez	s4,8000487a <pipewrite+0x118>
    8000478a:	f85a                	sd	s6,48(sp)
    8000478c:	f45e                	sd	s7,40(sp)
    8000478e:	f062                	sd	s8,32(sp)
    80004790:	ec66                	sd	s9,24(sp)
    80004792:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004794:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004796:	f9f40c13          	addi	s8,s0,-97
    8000479a:	4b85                	li	s7,1
    8000479c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000479e:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    800047a2:	21c48c93          	addi	s9,s1,540
    800047a6:	a0a1                	j	800047ee <pipewrite+0x8c>
      release(&pi->lock);
    800047a8:	8526                	mv	a0,s1
    800047aa:	d06fc0ef          	jal	80000cb0 <release>
      return -1;
    800047ae:	597d                	li	s2,-1
    800047b0:	7b42                	ld	s6,48(sp)
    800047b2:	7ba2                	ld	s7,40(sp)
    800047b4:	7c02                	ld	s8,32(sp)
    800047b6:	6ce2                	ld	s9,24(sp)
    800047b8:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800047ba:	854a                	mv	a0,s2
    800047bc:	70a6                	ld	ra,104(sp)
    800047be:	7406                	ld	s0,96(sp)
    800047c0:	64e6                	ld	s1,88(sp)
    800047c2:	6946                	ld	s2,80(sp)
    800047c4:	69a6                	ld	s3,72(sp)
    800047c6:	6a06                	ld	s4,64(sp)
    800047c8:	7ae2                	ld	s5,56(sp)
    800047ca:	6165                	addi	sp,sp,112
    800047cc:	8082                	ret
      wakeup(&pi->nread);
    800047ce:	856a                	mv	a0,s10
    800047d0:	869fd0ef          	jal	80002038 <wakeup>
      sleep_prepare(&pi->nwrite);
    800047d4:	8566                	mv	a0,s9
    800047d6:	ff6fd0ef          	jal	80001fcc <sleep_prepare>
      release(&pi->lock);
    800047da:	8526                	mv	a0,s1
    800047dc:	cd4fc0ef          	jal	80000cb0 <release>
      sleep();
    800047e0:	829fd0ef          	jal	80002008 <sleep>
      acquire(&pi->lock);
    800047e4:	8526                	mv	a0,s1
    800047e6:	c42fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    800047ea:	07495b63          	bge	s2,s4,80004860 <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    800047ee:	2204a783          	lw	a5,544(s1)
    800047f2:	dbdd                	beqz	a5,800047a8 <pipewrite+0x46>
    800047f4:	854e                	mv	a0,s3
    800047f6:	a35fd0ef          	jal	8000222a <killed>
    800047fa:	f55d                	bnez	a0,800047a8 <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    800047fc:	2184a783          	lw	a5,536(s1)
    80004800:	21c4a703          	lw	a4,540(s1)
    80004804:	2007879b          	addiw	a5,a5,512
    80004808:	fcf703e3          	beq	a4,a5,800047ce <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    8000480c:	875e                	mv	a4,s7
    8000480e:	015906b3          	add	a3,s2,s5
    80004812:	8662                	mv	a2,s8
    80004814:	0489b583          	ld	a1,72(s3)
    80004818:	0509b503          	ld	a0,80(s3)
    8000481c:	e31fc0ef          	jal	8000164c <copyin>
    80004820:	03650163          	beq	a0,s6,80004842 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004824:	21c4a783          	lw	a5,540(s1)
    80004828:	0017871b          	addiw	a4,a5,1
    8000482c:	20e4ae23          	sw	a4,540(s1)
    80004830:	1ff7f793          	andi	a5,a5,511
    80004834:	97a6                	add	a5,a5,s1
    80004836:	f9f44703          	lbu	a4,-97(s0)
    8000483a:	00e78c23          	sb	a4,24(a5)
      i++;
    8000483e:	2905                	addiw	s2,s2,1
    80004840:	b76d                	j	800047ea <pipewrite+0x88>
        if (i == 0)
    80004842:	00090863          	beqz	s2,80004852 <pipewrite+0xf0>
    80004846:	7b42                	ld	s6,48(sp)
    80004848:	7ba2                	ld	s7,40(sp)
    8000484a:	7c02                	ld	s8,32(sp)
    8000484c:	6ce2                	ld	s9,24(sp)
    8000484e:	6d42                	ld	s10,16(sp)
    80004850:	a829                	j	8000486a <pipewrite+0x108>
          i = -1;
    80004852:	892a                	mv	s2,a0
        break;
    80004854:	7b42                	ld	s6,48(sp)
    80004856:	7ba2                	ld	s7,40(sp)
    80004858:	7c02                	ld	s8,32(sp)
    8000485a:	6ce2                	ld	s9,24(sp)
    8000485c:	6d42                	ld	s10,16(sp)
    8000485e:	a031                	j	8000486a <pipewrite+0x108>
    80004860:	7b42                	ld	s6,48(sp)
    80004862:	7ba2                	ld	s7,40(sp)
    80004864:	7c02                	ld	s8,32(sp)
    80004866:	6ce2                	ld	s9,24(sp)
    80004868:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    8000486a:	21848513          	addi	a0,s1,536
    8000486e:	fcafd0ef          	jal	80002038 <wakeup>
  release(&pi->lock);
    80004872:	8526                	mv	a0,s1
    80004874:	c3cfc0ef          	jal	80000cb0 <release>
  return i;
    80004878:	b789                	j	800047ba <pipewrite+0x58>
  int i = 0;
    8000487a:	4901                	li	s2,0
    8000487c:	b7fd                	j	8000486a <pipewrite+0x108>

000000008000487e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000487e:	711d                	addi	sp,sp,-96
    80004880:	ec86                	sd	ra,88(sp)
    80004882:	e8a2                	sd	s0,80(sp)
    80004884:	e4a6                	sd	s1,72(sp)
    80004886:	e0ca                	sd	s2,64(sp)
    80004888:	fc4e                	sd	s3,56(sp)
    8000488a:	f852                	sd	s4,48(sp)
    8000488c:	f456                	sd	s5,40(sp)
    8000488e:	1080                	addi	s0,sp,96
    80004890:	84aa                	mv	s1,a0
    80004892:	89ae                	mv	s3,a1
    80004894:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004896:	8b6fd0ef          	jal	8000194c <myproc>
    8000489a:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    8000489c:	8526                	mv	a0,s1
    8000489e:	b8afc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800048a2:	0d505263          	blez	s5,80004966 <piperead+0xe8>
    800048a6:	2184a703          	lw	a4,536(s1)
    800048aa:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    800048ae:	21848a13          	addi	s4,s1,536
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800048b2:	02f71e63          	bne	a4,a5,800048ee <piperead+0x70>
    800048b6:	2244a783          	lw	a5,548(s1)
    800048ba:	c3b9                	beqz	a5,80004900 <piperead+0x82>
    if (killed(pr)) {
    800048bc:	854a                	mv	a0,s2
    800048be:	96dfd0ef          	jal	8000222a <killed>
    800048c2:	e915                	bnez	a0,800048f6 <piperead+0x78>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    800048c4:	8552                	mv	a0,s4
    800048c6:	f06fd0ef          	jal	80001fcc <sleep_prepare>
    release(&pi->lock);
    800048ca:	8526                	mv	a0,s1
    800048cc:	be4fc0ef          	jal	80000cb0 <release>
    sleep();
    800048d0:	f38fd0ef          	jal	80002008 <sleep>
    acquire(&pi->lock);
    800048d4:	8526                	mv	a0,s1
    800048d6:	b52fc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800048da:	2184a703          	lw	a4,536(s1)
    800048de:	21c4a783          	lw	a5,540(s1)
    800048e2:	fcf70ae3          	beq	a4,a5,800048b6 <piperead+0x38>
    800048e6:	f05a                	sd	s6,32(sp)
    800048e8:	ec5e                	sd	s7,24(sp)
    800048ea:	e862                	sd	s8,16(sp)
    800048ec:	a829                	j	80004906 <piperead+0x88>
    800048ee:	f05a                	sd	s6,32(sp)
    800048f0:	ec5e                	sd	s7,24(sp)
    800048f2:	e862                	sd	s8,16(sp)
    800048f4:	a809                	j	80004906 <piperead+0x88>
      release(&pi->lock);
    800048f6:	8526                	mv	a0,s1
    800048f8:	bb8fc0ef          	jal	80000cb0 <release>
      return -1;
    800048fc:	5a7d                	li	s4,-1
    800048fe:	a8a5                	j	80004976 <piperead+0xf8>
    80004900:	f05a                	sd	s6,32(sp)
    80004902:	ec5e                	sd	s7,24(sp)
    80004904:	e862                	sd	s8,16(sp)
{
    80004906:	4a01                	li	s4,0
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004908:	faf40c13          	addi	s8,s0,-81
    8000490c:	4b85                	li	s7,1
    8000490e:	5b7d                	li	s6,-1
    if (pi->nread == pi->nwrite)
    80004910:	2184a783          	lw	a5,536(s1)
    80004914:	21c4a703          	lw	a4,540(s1)
    80004918:	06f70e63          	beq	a4,a5,80004994 <piperead+0x116>
    ch = pi->data[pi->nread % PIPESIZE];
    8000491c:	1ff7f793          	andi	a5,a5,511
    80004920:	97a6                	add	a5,a5,s1
    80004922:	0187c783          	lbu	a5,24(a5)
    80004926:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    8000492a:	875e                	mv	a4,s7
    8000492c:	86e2                	mv	a3,s8
    8000492e:	864e                	mv	a2,s3
    80004930:	04893583          	ld	a1,72(s2)
    80004934:	05093503          	ld	a0,80(s2)
    80004938:	c4ffc0ef          	jal	80001586 <copyout>
    8000493c:	01650f63          	beq	a0,s6,8000495a <piperead+0xdc>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004940:	2184a783          	lw	a5,536(s1)
    80004944:	2785                	addiw	a5,a5,1
    80004946:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    8000494a:	2a05                	addiw	s4,s4,1
    8000494c:	0985                	addi	s3,s3,1
    8000494e:	fd4a91e3          	bne	s5,s4,80004910 <piperead+0x92>
    80004952:	7b02                	ld	s6,32(sp)
    80004954:	6be2                	ld	s7,24(sp)
    80004956:	6c42                	ld	s8,16(sp)
    80004958:	a801                	j	80004968 <piperead+0xea>
      if (i == 0)
    8000495a:	020a0863          	beqz	s4,8000498a <piperead+0x10c>
    8000495e:	7b02                	ld	s6,32(sp)
    80004960:	6be2                	ld	s7,24(sp)
    80004962:	6c42                	ld	s8,16(sp)
    80004964:	a011                	j	80004968 <piperead+0xea>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004966:	4a01                	li	s4,0
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    80004968:	21c48513          	addi	a0,s1,540
    8000496c:	eccfd0ef          	jal	80002038 <wakeup>
  release(&pi->lock);
    80004970:	8526                	mv	a0,s1
    80004972:	b3efc0ef          	jal	80000cb0 <release>
  return i;
}
    80004976:	8552                	mv	a0,s4
    80004978:	60e6                	ld	ra,88(sp)
    8000497a:	6446                	ld	s0,80(sp)
    8000497c:	64a6                	ld	s1,72(sp)
    8000497e:	6906                	ld	s2,64(sp)
    80004980:	79e2                	ld	s3,56(sp)
    80004982:	7a42                	ld	s4,48(sp)
    80004984:	7aa2                	ld	s5,40(sp)
    80004986:	6125                	addi	sp,sp,96
    80004988:	8082                	ret
        i = -1;
    8000498a:	8a2a                	mv	s4,a0
    8000498c:	7b02                	ld	s6,32(sp)
    8000498e:	6be2                	ld	s7,24(sp)
    80004990:	6c42                	ld	s8,16(sp)
    80004992:	bfd9                	j	80004968 <piperead+0xea>
    80004994:	7b02                	ld	s6,32(sp)
    80004996:	6be2                	ld	s7,24(sp)
    80004998:	6c42                	ld	s8,16(sp)
    8000499a:	b7f9                	j	80004968 <piperead+0xea>

000000008000499c <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    8000499c:	1141                	addi	sp,sp,-16
    8000499e:	e406                	sd	ra,8(sp)
    800049a0:	e022                	sd	s0,0(sp)
    800049a2:	0800                	addi	s0,sp,16
    800049a4:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    800049a6:	0035151b          	slliw	a0,a0,0x3
    800049aa:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    800049ac:	8b89                	andi	a5,a5,2
    800049ae:	c399                	beqz	a5,800049b4 <flags2perm+0x18>
    perm |= PTE_W;
    800049b0:	00456513          	ori	a0,a0,4
  return perm;
}
    800049b4:	60a2                	ld	ra,8(sp)
    800049b6:	6402                	ld	s0,0(sp)
    800049b8:	0141                	addi	sp,sp,16
    800049ba:	8082                	ret

00000000800049bc <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800049bc:	de010113          	addi	sp,sp,-544
    800049c0:	20113c23          	sd	ra,536(sp)
    800049c4:	20813823          	sd	s0,528(sp)
    800049c8:	20913423          	sd	s1,520(sp)
    800049cc:	21213023          	sd	s2,512(sp)
    800049d0:	1400                	addi	s0,sp,544
    800049d2:	892a                	mv	s2,a0
    800049d4:	dea43823          	sd	a0,-528(s0)
    800049d8:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800049dc:	f71fc0ef          	jal	8000194c <myproc>
    800049e0:	84aa                	mv	s1,a0

  begin_op();
    800049e2:	c62ff0ef          	jal	80003e44 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    800049e6:	854a                	mv	a0,s2
    800049e8:	a7eff0ef          	jal	80003c66 <namei>
    800049ec:	cd21                	beqz	a0,80004a44 <kexec+0x88>
    800049ee:	fbd2                	sd	s4,496(sp)
    800049f0:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800049f2:	9dbfe0ef          	jal	800033cc <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800049f6:	04000713          	li	a4,64
    800049fa:	4681                	li	a3,0
    800049fc:	e5040613          	addi	a2,s0,-432
    80004a00:	4581                	li	a1,0
    80004a02:	8552                	mv	a0,s4
    80004a04:	da3fe0ef          	jal	800037a6 <readi>
    80004a08:	04000793          	li	a5,64
    80004a0c:	00f51a63          	bne	a0,a5,80004a20 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004a10:	e5042703          	lw	a4,-432(s0)
    80004a14:	464c47b7          	lui	a5,0x464c4
    80004a18:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004a1c:	02f70863          	beq	a4,a5,80004a4c <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    80004a20:	8552                	mv	a0,s4
    80004a22:	bfffe0ef          	jal	80003620 <iunlockput>
    end_op();
    80004a26:	caaff0ef          	jal	80003ed0 <end_op>
  }
  return -1;
    80004a2a:	557d                	li	a0,-1
    80004a2c:	7a5e                	ld	s4,496(sp)
}
    80004a2e:	21813083          	ld	ra,536(sp)
    80004a32:	21013403          	ld	s0,528(sp)
    80004a36:	20813483          	ld	s1,520(sp)
    80004a3a:	20013903          	ld	s2,512(sp)
    80004a3e:	22010113          	addi	sp,sp,544
    80004a42:	8082                	ret
    end_op();
    80004a44:	c8cff0ef          	jal	80003ed0 <end_op>
    return -1;
    80004a48:	557d                	li	a0,-1
    80004a4a:	b7d5                	j	80004a2e <kexec+0x72>
    80004a4c:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004a4e:	8526                	mv	a0,s1
    80004a50:	802fd0ef          	jal	80001a52 <proc_pagetable>
    80004a54:	8b2a                	mv	s6,a0
    80004a56:	26050e63          	beqz	a0,80004cd2 <kexec+0x316>
    80004a5a:	ffce                	sd	s3,504(sp)
    80004a5c:	f7d6                	sd	s5,488(sp)
    80004a5e:	efde                	sd	s7,472(sp)
    80004a60:	ebe2                	sd	s8,464(sp)
    80004a62:	e7e6                	sd	s9,456(sp)
    80004a64:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004a66:	e8845783          	lhu	a5,-376(s0)
    80004a6a:	14078263          	beqz	a5,80004bae <kexec+0x1f2>
    80004a6e:	ff6e                	sd	s11,440(sp)
    80004a70:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a74:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004a76:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a78:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    80004a7c:	6c85                	lui	s9,0x1
    80004a7e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004a82:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    80004a86:	6a85                	lui	s5,0x1
    80004a88:	a085                	j	80004ae8 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004a8a:	00003517          	auipc	a0,0x3
    80004a8e:	b3e50513          	addi	a0,a0,-1218 # 800075c8 <etext+0x5c8>
    80004a92:	da3fb0ef          	jal	80000834 <panic>
    if (sz - i < PGSIZE)
    80004a96:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004a98:	874a                	mv	a4,s2
    80004a9a:	009b86bb          	addw	a3,s7,s1
    80004a9e:	4581                	li	a1,0
    80004aa0:	8552                	mv	a0,s4
    80004aa2:	d05fe0ef          	jal	800037a6 <readi>
    80004aa6:	22a91a63          	bne	s2,a0,80004cda <kexec+0x31e>
  for (i = 0; i < sz; i += PGSIZE) {
    80004aaa:	009a84bb          	addw	s1,s5,s1
    80004aae:	0334f263          	bgeu	s1,s3,80004ad2 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004ab2:	02049593          	slli	a1,s1,0x20
    80004ab6:	9181                	srli	a1,a1,0x20
    80004ab8:	95e2                	add	a1,a1,s8
    80004aba:	855a                	mv	a0,s6
    80004abc:	d60fc0ef          	jal	8000101c <walkaddr>
    80004ac0:	862a                	mv	a2,a0
    if (pa == 0)
    80004ac2:	d561                	beqz	a0,80004a8a <kexec+0xce>
    if (sz - i < PGSIZE)
    80004ac4:	409987bb          	subw	a5,s3,s1
    80004ac8:	893e                	mv	s2,a5
    80004aca:	fcfcf6e3          	bgeu	s9,a5,80004a96 <kexec+0xda>
    80004ace:	8956                	mv	s2,s5
    80004ad0:	b7d9                	j	80004a96 <kexec+0xda>
    sz = sz1;
    80004ad2:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004ad6:	2d05                	addiw	s10,s10,1
    80004ad8:	e0843783          	ld	a5,-504(s0)
    80004adc:	0387869b          	addiw	a3,a5,56
    80004ae0:	e8845783          	lhu	a5,-376(s0)
    80004ae4:	06fd5d63          	bge	s10,a5,80004b5e <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ae8:	e0d43423          	sd	a3,-504(s0)
    80004aec:	876e                	mv	a4,s11
    80004aee:	e1840613          	addi	a2,s0,-488
    80004af2:	4581                	li	a1,0
    80004af4:	8552                	mv	a0,s4
    80004af6:	cb1fe0ef          	jal	800037a6 <readi>
    80004afa:	1db51e63          	bne	a0,s11,80004cd6 <kexec+0x31a>
    if (ph.type != ELF_PROG_LOAD)
    80004afe:	e1842783          	lw	a5,-488(s0)
    80004b02:	4705                	li	a4,1
    80004b04:	fce799e3          	bne	a5,a4,80004ad6 <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    80004b08:	e4043483          	ld	s1,-448(s0)
    80004b0c:	e3843783          	ld	a5,-456(s0)
    80004b10:	1ef4e363          	bltu	s1,a5,80004cf6 <kexec+0x33a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004b14:	e2843783          	ld	a5,-472(s0)
    80004b18:	94be                	add	s1,s1,a5
    80004b1a:	1ef4e163          	bltu	s1,a5,80004cfc <kexec+0x340>
    if (ph.vaddr % PGSIZE != 0)
    80004b1e:	de843703          	ld	a4,-536(s0)
    80004b22:	8ff9                	and	a5,a5,a4
    80004b24:	1c079f63          	bnez	a5,80004d02 <kexec+0x346>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004b28:	e1c42503          	lw	a0,-484(s0)
    80004b2c:	e71ff0ef          	jal	8000499c <flags2perm>
    80004b30:	86aa                	mv	a3,a0
    80004b32:	8626                	mv	a2,s1
    80004b34:	85ca                	mv	a1,s2
    80004b36:	855a                	mv	a0,s6
    80004b38:	fbafc0ef          	jal	800012f2 <uvmalloc>
    80004b3c:	dea43c23          	sd	a0,-520(s0)
    80004b40:	1c050463          	beqz	a0,80004d08 <kexec+0x34c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004b44:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004b48:	00098863          	beqz	s3,80004b58 <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004b4c:	e2843c03          	ld	s8,-472(s0)
    80004b50:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004b54:	4481                	li	s1,0
    80004b56:	bfb1                	j	80004ab2 <kexec+0xf6>
    sz = sz1;
    80004b58:	df843903          	ld	s2,-520(s0)
    80004b5c:	bfad                	j	80004ad6 <kexec+0x11a>
    80004b5e:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    80004b60:	8552                	mv	a0,s4
    80004b62:	abffe0ef          	jal	80003620 <iunlockput>
  end_op();
    80004b66:	b6aff0ef          	jal	80003ed0 <end_op>
  p = myproc();
    80004b6a:	de3fc0ef          	jal	8000194c <myproc>
    80004b6e:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004b70:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    80004b74:	6c05                	lui	s8,0x1
    80004b76:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    80004b78:	9c4a                	add	s8,s8,s2
    80004b7a:	77fd                	lui	a5,0xfffff
    80004b7c:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004b80:	4691                	li	a3,4
    80004b82:	6609                	lui	a2,0x2
    80004b84:	9662                	add	a2,a2,s8
    80004b86:	85e2                	mv	a1,s8
    80004b88:	855a                	mv	a0,s6
    80004b8a:	f68fc0ef          	jal	800012f2 <uvmalloc>
    80004b8e:	892a                	mv	s2,a0
    80004b90:	e10d                	bnez	a0,80004bb2 <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    80004b92:	85e2                	mv	a1,s8
    80004b94:	855a                	mv	a0,s6
    80004b96:	f41fc0ef          	jal	80001ad6 <proc_freepagetable>
  return -1;
    80004b9a:	557d                	li	a0,-1
    80004b9c:	79fe                	ld	s3,504(sp)
    80004b9e:	7a5e                	ld	s4,496(sp)
    80004ba0:	7abe                	ld	s5,488(sp)
    80004ba2:	7b1e                	ld	s6,480(sp)
    80004ba4:	6bfe                	ld	s7,472(sp)
    80004ba6:	6c5e                	ld	s8,464(sp)
    80004ba8:	6cbe                	ld	s9,456(sp)
    80004baa:	6d1e                	ld	s10,448(sp)
    80004bac:	b549                	j	80004a2e <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004bae:	4901                	li	s2,0
    80004bb0:	bf45                	j	80004b60 <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004bb2:	75f9                	lui	a1,0xffffe
    80004bb4:	95aa                	add	a1,a1,a0
    80004bb6:	855a                	mv	a0,s6
    80004bb8:	90dfc0ef          	jal	800014c4 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004bbc:	80090a13          	addi	s4,s2,-2048
    80004bc0:	800a0a13          	addi	s4,s4,-2048
  for (argc = 0; argv[argc]; argc++) {
    80004bc4:	e0043783          	ld	a5,-512(s0)
    80004bc8:	6388                	ld	a0,0(a5)
    80004bca:	c545                	beqz	a0,80004c72 <kexec+0x2b6>
  sp = sz;
    80004bcc:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004bce:	4481                	li	s1,0
    ustack[argc] = sp;
    80004bd0:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004bd4:	a9efc0ef          	jal	80000e72 <strlen>
    80004bd8:	0015079b          	addiw	a5,a0,1
    80004bdc:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004be0:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004be4:	134c6563          	bltu	s8,s4,80004d0e <kexec+0x352>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004be8:	e0043d03          	ld	s10,-512(s0)
    80004bec:	000d3c83          	ld	s9,0(s10)
    80004bf0:	8566                	mv	a0,s9
    80004bf2:	a80fc0ef          	jal	80000e72 <strlen>
    80004bf6:	0015071b          	addiw	a4,a0,1
    80004bfa:	86e6                	mv	a3,s9
    80004bfc:	8662                	mv	a2,s8
    80004bfe:	85ca                	mv	a1,s2
    80004c00:	855a                	mv	a0,s6
    80004c02:	985fc0ef          	jal	80001586 <copyout>
    80004c06:	10054663          	bltz	a0,80004d12 <kexec+0x356>
    ustack[argc] = sp;
    80004c0a:	00349793          	slli	a5,s1,0x3
    80004c0e:	97de                	add	a5,a5,s7
    80004c10:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb940>
  for (argc = 0; argv[argc]; argc++) {
    80004c14:	0485                	addi	s1,s1,1
    80004c16:	008d0793          	addi	a5,s10,8
    80004c1a:	e0f43023          	sd	a5,-512(s0)
    80004c1e:	008d3503          	ld	a0,8(s10)
    80004c22:	f94d                	bnez	a0,80004bd4 <kexec+0x218>
  ustack[argc] = 0;
    80004c24:	00349793          	slli	a5,s1,0x3
    80004c28:	f9078793          	addi	a5,a5,-112
    80004c2c:	97a2                	add	a5,a5,s0
    80004c2e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004c32:	00349713          	slli	a4,s1,0x3
    80004c36:	0721                	addi	a4,a4,8
    80004c38:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004c3c:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004c40:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004c42:	f54be8e3          	bltu	s7,s4,80004b92 <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004c46:	e9040693          	addi	a3,s0,-368
    80004c4a:	865e                	mv	a2,s7
    80004c4c:	85ca                	mv	a1,s2
    80004c4e:	855a                	mv	a0,s6
    80004c50:	937fc0ef          	jal	80001586 <copyout>
    80004c54:	f2054fe3          	bltz	a0,80004b92 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004c58:	0589b783          	ld	a5,88(s3)
    80004c5c:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004c60:	df043783          	ld	a5,-528(s0)
    80004c64:	0007c703          	lbu	a4,0(a5)
    80004c68:	c30d                	beqz	a4,80004c8a <kexec+0x2ce>
    80004c6a:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004c6c:	02f00693          	li	a3,47
    80004c70:	a801                	j	80004c80 <kexec+0x2c4>
  sp = sz;
    80004c72:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004c74:	4481                	li	s1,0
    80004c76:	b77d                	j	80004c24 <kexec+0x268>
  for (last = s = path; *s; s++)
    80004c78:	0785                	addi	a5,a5,1
    80004c7a:	fff7c703          	lbu	a4,-1(a5)
    80004c7e:	c711                	beqz	a4,80004c8a <kexec+0x2ce>
    if (*s == '/')
    80004c80:	fed71ce3          	bne	a4,a3,80004c78 <kexec+0x2bc>
      last = s + 1;
    80004c84:	def43823          	sd	a5,-528(s0)
    80004c88:	bfc5                	j	80004c78 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004c8a:	4641                	li	a2,16
    80004c8c:	df043583          	ld	a1,-528(s0)
    80004c90:	15898513          	addi	a0,s3,344
    80004c94:	9a8fc0ef          	jal	80000e3c <safestrcpy>
  oldpagetable = p->pagetable;
    80004c98:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004c9c:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004ca0:	0529b423          	sd	s2,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004ca4:	0589b783          	ld	a5,88(s3)
    80004ca8:	e6843703          	ld	a4,-408(s0)
    80004cac:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004cae:	0589b783          	ld	a5,88(s3)
    80004cb2:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004cb6:	85d6                	mv	a1,s5
    80004cb8:	e1ffc0ef          	jal	80001ad6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004cbc:	0004851b          	sext.w	a0,s1
    80004cc0:	79fe                	ld	s3,504(sp)
    80004cc2:	7a5e                	ld	s4,496(sp)
    80004cc4:	7abe                	ld	s5,488(sp)
    80004cc6:	7b1e                	ld	s6,480(sp)
    80004cc8:	6bfe                	ld	s7,472(sp)
    80004cca:	6c5e                	ld	s8,464(sp)
    80004ccc:	6cbe                	ld	s9,456(sp)
    80004cce:	6d1e                	ld	s10,448(sp)
    80004cd0:	bbb9                	j	80004a2e <kexec+0x72>
    80004cd2:	7b1e                	ld	s6,480(sp)
    80004cd4:	b3b1                	j	80004a20 <kexec+0x64>
    80004cd6:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004cda:	df843583          	ld	a1,-520(s0)
    80004cde:	855a                	mv	a0,s6
    80004ce0:	df7fc0ef          	jal	80001ad6 <proc_freepagetable>
  if (ip) {
    80004ce4:	79fe                	ld	s3,504(sp)
    80004ce6:	7abe                	ld	s5,488(sp)
    80004ce8:	7b1e                	ld	s6,480(sp)
    80004cea:	6bfe                	ld	s7,472(sp)
    80004cec:	6c5e                	ld	s8,464(sp)
    80004cee:	6cbe                	ld	s9,456(sp)
    80004cf0:	6d1e                	ld	s10,448(sp)
    80004cf2:	7dfa                	ld	s11,440(sp)
    80004cf4:	b335                	j	80004a20 <kexec+0x64>
    80004cf6:	df243c23          	sd	s2,-520(s0)
    80004cfa:	b7c5                	j	80004cda <kexec+0x31e>
    80004cfc:	df243c23          	sd	s2,-520(s0)
    80004d00:	bfe9                	j	80004cda <kexec+0x31e>
    80004d02:	df243c23          	sd	s2,-520(s0)
    80004d06:	bfd1                	j	80004cda <kexec+0x31e>
    80004d08:	df243c23          	sd	s2,-520(s0)
    80004d0c:	b7f9                	j	80004cda <kexec+0x31e>
  sz = sz1;
    80004d0e:	8c4a                	mv	s8,s2
    80004d10:	b549                	j	80004b92 <kexec+0x1d6>
    80004d12:	8c4a                	mv	s8,s2
    80004d14:	bdbd                	j	80004b92 <kexec+0x1d6>

0000000080004d16 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004d16:	7179                	addi	sp,sp,-48
    80004d18:	f406                	sd	ra,40(sp)
    80004d1a:	f022                	sd	s0,32(sp)
    80004d1c:	ec26                	sd	s1,24(sp)
    80004d1e:	e84a                	sd	s2,16(sp)
    80004d20:	1800                	addi	s0,sp,48
    80004d22:	892e                	mv	s2,a1
    80004d24:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004d26:	fdc40593          	addi	a1,s0,-36
    80004d2a:	be1fd0ef          	jal	8000290a <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004d2e:	fdc42703          	lw	a4,-36(s0)
    80004d32:	47bd                	li	a5,15
    80004d34:	02e7ea63          	bltu	a5,a4,80004d68 <argfd+0x52>
    80004d38:	c15fc0ef          	jal	8000194c <myproc>
    80004d3c:	fdc42703          	lw	a4,-36(s0)
    80004d40:	00371793          	slli	a5,a4,0x3
    80004d44:	0d078793          	addi	a5,a5,208
    80004d48:	953e                	add	a0,a0,a5
    80004d4a:	611c                	ld	a5,0(a0)
    80004d4c:	c385                	beqz	a5,80004d6c <argfd+0x56>
    return -1;
  if (pfd)
    80004d4e:	00090463          	beqz	s2,80004d56 <argfd+0x40>
    *pfd = fd;
    80004d52:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004d56:	4501                	li	a0,0
  if (pf)
    80004d58:	c091                	beqz	s1,80004d5c <argfd+0x46>
    *pf = f;
    80004d5a:	e09c                	sd	a5,0(s1)
}
    80004d5c:	70a2                	ld	ra,40(sp)
    80004d5e:	7402                	ld	s0,32(sp)
    80004d60:	64e2                	ld	s1,24(sp)
    80004d62:	6942                	ld	s2,16(sp)
    80004d64:	6145                	addi	sp,sp,48
    80004d66:	8082                	ret
    return -1;
    80004d68:	557d                	li	a0,-1
    80004d6a:	bfcd                	j	80004d5c <argfd+0x46>
    80004d6c:	557d                	li	a0,-1
    80004d6e:	b7fd                	j	80004d5c <argfd+0x46>

0000000080004d70 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004d70:	1101                	addi	sp,sp,-32
    80004d72:	ec06                	sd	ra,24(sp)
    80004d74:	e822                	sd	s0,16(sp)
    80004d76:	e426                	sd	s1,8(sp)
    80004d78:	1000                	addi	s0,sp,32
    80004d7a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004d7c:	bd1fc0ef          	jal	8000194c <myproc>
    80004d80:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004d82:	0d050793          	addi	a5,a0,208
    80004d86:	4501                	li	a0,0
    80004d88:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004d8a:	6398                	ld	a4,0(a5)
    80004d8c:	cb19                	beqz	a4,80004da2 <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004d8e:	2505                	addiw	a0,a0,1
    80004d90:	07a1                	addi	a5,a5,8
    80004d92:	fed51ce3          	bne	a0,a3,80004d8a <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004d96:	557d                	li	a0,-1
}
    80004d98:	60e2                	ld	ra,24(sp)
    80004d9a:	6442                	ld	s0,16(sp)
    80004d9c:	64a2                	ld	s1,8(sp)
    80004d9e:	6105                	addi	sp,sp,32
    80004da0:	8082                	ret
      p->ofile[fd] = f;
    80004da2:	00351793          	slli	a5,a0,0x3
    80004da6:	0d078793          	addi	a5,a5,208
    80004daa:	963e                	add	a2,a2,a5
    80004dac:	e204                	sd	s1,0(a2)
      return fd;
    80004dae:	b7ed                	j	80004d98 <fdalloc+0x28>

0000000080004db0 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004db0:	715d                	addi	sp,sp,-80
    80004db2:	e486                	sd	ra,72(sp)
    80004db4:	e0a2                	sd	s0,64(sp)
    80004db6:	fc26                	sd	s1,56(sp)
    80004db8:	f84a                	sd	s2,48(sp)
    80004dba:	f052                	sd	s4,32(sp)
    80004dbc:	ec56                	sd	s5,24(sp)
    80004dbe:	e85a                	sd	s6,16(sp)
    80004dc0:	0880                	addi	s0,sp,80
    80004dc2:	8a2e                	mv	s4,a1
    80004dc4:	8ab2                	mv	s5,a2
    80004dc6:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004dc8:	fb040593          	addi	a1,s0,-80
    80004dcc:	eb5fe0ef          	jal	80003c80 <nameiparent>
    80004dd0:	84aa                	mv	s1,a0
    80004dd2:	12050f63          	beqz	a0,80004f10 <create+0x160>
    return 0;

  ilock(dp);
    80004dd6:	df6fe0ef          	jal	800033cc <ilock>

  if (dp->nlink == 0) {
    80004dda:	04a49783          	lh	a5,74(s1)
    80004dde:	cbb9                	beqz	a5,80004e34 <create+0x84>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004de0:	7761                	lui	a4,0xffff8
    80004de2:	0705                	addi	a4,a4,1 # ffffffffffff8001 <end+0xffffffff7ffd4941>
    80004de4:	97ba                	add	a5,a5,a4
    80004de6:	e781                	bnez	a5,80004dee <create+0x3e>
    80004de8:	fffa0793          	addi	a5,s4,-1
    80004dec:	cba9                	beqz	a5,80004e3e <create+0x8e>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004dee:	4601                	li	a2,0
    80004df0:	fb040593          	addi	a1,s0,-80
    80004df4:	8526                	mv	a0,s1
    80004df6:	bbffe0ef          	jal	800039b4 <dirlookup>
    80004dfa:	892a                	mv	s2,a0
    80004dfc:	c939                	beqz	a0,80004e52 <create+0xa2>
    iunlockput(dp);
    80004dfe:	8526                	mv	a0,s1
    80004e00:	821fe0ef          	jal	80003620 <iunlockput>
    ilock(ip);
    80004e04:	854a                	mv	a0,s2
    80004e06:	dc6fe0ef          	jal	800033cc <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004e0a:	4789                	li	a5,2
    80004e0c:	02fa1e63          	bne	s4,a5,80004e48 <create+0x98>
    80004e10:	04495783          	lhu	a5,68(s2)
    80004e14:	37f9                	addiw	a5,a5,-2
    80004e16:	17c2                	slli	a5,a5,0x30
    80004e18:	93c1                	srli	a5,a5,0x30
    80004e1a:	4705                	li	a4,1
    80004e1c:	02f76663          	bltu	a4,a5,80004e48 <create+0x98>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004e20:	854a                	mv	a0,s2
    80004e22:	60a6                	ld	ra,72(sp)
    80004e24:	6406                	ld	s0,64(sp)
    80004e26:	74e2                	ld	s1,56(sp)
    80004e28:	7942                	ld	s2,48(sp)
    80004e2a:	7a02                	ld	s4,32(sp)
    80004e2c:	6ae2                	ld	s5,24(sp)
    80004e2e:	6b42                	ld	s6,16(sp)
    80004e30:	6161                	addi	sp,sp,80
    80004e32:	8082                	ret
    iunlockput(dp);
    80004e34:	8526                	mv	a0,s1
    80004e36:	feafe0ef          	jal	80003620 <iunlockput>
    return 0;
    80004e3a:	4901                	li	s2,0
    80004e3c:	b7d5                	j	80004e20 <create+0x70>
    iunlockput(dp);
    80004e3e:	8526                	mv	a0,s1
    80004e40:	fe0fe0ef          	jal	80003620 <iunlockput>
    return 0;
    80004e44:	4901                	li	s2,0
    80004e46:	bfe9                	j	80004e20 <create+0x70>
    iunlockput(ip);
    80004e48:	854a                	mv	a0,s2
    80004e4a:	fd6fe0ef          	jal	80003620 <iunlockput>
    return 0;
    80004e4e:	4901                	li	s2,0
    80004e50:	bfc1                	j	80004e20 <create+0x70>
    80004e52:	f44e                	sd	s3,40(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004e54:	85d2                	mv	a1,s4
    80004e56:	4088                	lw	a0,0(s1)
    80004e58:	c04fe0ef          	jal	8000325c <ialloc>
    80004e5c:	89aa                	mv	s3,a0
    80004e5e:	cd1d                	beqz	a0,80004e9c <create+0xec>
  ilock(ip);
    80004e60:	d6cfe0ef          	jal	800033cc <ilock>
  ip->major = major;
    80004e64:	05599323          	sh	s5,70(s3)
  ip->minor = minor;
    80004e68:	05699423          	sh	s6,72(s3)
  ip->nlink = 1;
    80004e6c:	4705                	li	a4,1
    80004e6e:	04e99523          	sh	a4,74(s3)
  iupdate(ip);
    80004e72:	854e                	mv	a0,s3
    80004e74:	ca4fe0ef          	jal	80003318 <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80004e78:	4705                	li	a4,1
    80004e7a:	02ea0763          	beq	s4,a4,80004ea8 <create+0xf8>
  if (dirlink(dp, name, ip->inum) < 0)
    80004e7e:	0049a603          	lw	a2,4(s3)
    80004e82:	fb040593          	addi	a1,s0,-80
    80004e86:	8526                	mv	a0,s1
    80004e88:	d35fe0ef          	jal	80003bbc <dirlink>
    80004e8c:	06054563          	bltz	a0,80004ef6 <create+0x146>
  iunlockput(dp);
    80004e90:	8526                	mv	a0,s1
    80004e92:	f8efe0ef          	jal	80003620 <iunlockput>
  return ip;
    80004e96:	894e                	mv	s2,s3
    80004e98:	79a2                	ld	s3,40(sp)
    80004e9a:	b759                	j	80004e20 <create+0x70>
    iunlockput(dp);
    80004e9c:	8526                	mv	a0,s1
    80004e9e:	f82fe0ef          	jal	80003620 <iunlockput>
    return 0;
    80004ea2:	894e                	mv	s2,s3
    80004ea4:	79a2                	ld	s3,40(sp)
    80004ea6:	bfad                	j	80004e20 <create+0x70>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004ea8:	0049a603          	lw	a2,4(s3)
    80004eac:	00002597          	auipc	a1,0x2
    80004eb0:	73c58593          	addi	a1,a1,1852 # 800075e8 <etext+0x5e8>
    80004eb4:	854e                	mv	a0,s3
    80004eb6:	d07fe0ef          	jal	80003bbc <dirlink>
    80004eba:	02054e63          	bltz	a0,80004ef6 <create+0x146>
    80004ebe:	40d0                	lw	a2,4(s1)
    80004ec0:	00002597          	auipc	a1,0x2
    80004ec4:	73058593          	addi	a1,a1,1840 # 800075f0 <etext+0x5f0>
    80004ec8:	854e                	mv	a0,s3
    80004eca:	cf3fe0ef          	jal	80003bbc <dirlink>
    80004ece:	02054463          	bltz	a0,80004ef6 <create+0x146>
  if (dirlink(dp, name, ip->inum) < 0)
    80004ed2:	0049a603          	lw	a2,4(s3)
    80004ed6:	fb040593          	addi	a1,s0,-80
    80004eda:	8526                	mv	a0,s1
    80004edc:	ce1fe0ef          	jal	80003bbc <dirlink>
    80004ee0:	00054b63          	bltz	a0,80004ef6 <create+0x146>
    dp->nlink++; // for ".."
    80004ee4:	04a4d783          	lhu	a5,74(s1)
    80004ee8:	2785                	addiw	a5,a5,1
    80004eea:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004eee:	8526                	mv	a0,s1
    80004ef0:	c28fe0ef          	jal	80003318 <iupdate>
    80004ef4:	bf71                	j	80004e90 <create+0xe0>
  ip->nlink = 0;
    80004ef6:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    80004efa:	854e                	mv	a0,s3
    80004efc:	c1cfe0ef          	jal	80003318 <iupdate>
  iunlockput(ip);
    80004f00:	854e                	mv	a0,s3
    80004f02:	f1efe0ef          	jal	80003620 <iunlockput>
  iunlockput(dp);
    80004f06:	8526                	mv	a0,s1
    80004f08:	f18fe0ef          	jal	80003620 <iunlockput>
  return 0;
    80004f0c:	79a2                	ld	s3,40(sp)
    80004f0e:	bf09                	j	80004e20 <create+0x70>
    return 0;
    80004f10:	892a                	mv	s2,a0
    80004f12:	b739                	j	80004e20 <create+0x70>

0000000080004f14 <sys_dup>:
{
    80004f14:	7179                	addi	sp,sp,-48
    80004f16:	f406                	sd	ra,40(sp)
    80004f18:	f022                	sd	s0,32(sp)
    80004f1a:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004f1c:	fd840613          	addi	a2,s0,-40
    80004f20:	4581                	li	a1,0
    80004f22:	4501                	li	a0,0
    80004f24:	df3ff0ef          	jal	80004d16 <argfd>
    return -1;
    80004f28:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004f2a:	02054363          	bltz	a0,80004f50 <sys_dup+0x3c>
    80004f2e:	ec26                	sd	s1,24(sp)
    80004f30:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004f32:	fd843483          	ld	s1,-40(s0)
    80004f36:	8526                	mv	a0,s1
    80004f38:	e39ff0ef          	jal	80004d70 <fdalloc>
    80004f3c:	892a                	mv	s2,a0
    return -1;
    80004f3e:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004f40:	00054d63          	bltz	a0,80004f5a <sys_dup+0x46>
  filedup(f);
    80004f44:	8526                	mv	a0,s1
    80004f46:	b72ff0ef          	jal	800042b8 <filedup>
  return fd;
    80004f4a:	87ca                	mv	a5,s2
    80004f4c:	64e2                	ld	s1,24(sp)
    80004f4e:	6942                	ld	s2,16(sp)
}
    80004f50:	853e                	mv	a0,a5
    80004f52:	70a2                	ld	ra,40(sp)
    80004f54:	7402                	ld	s0,32(sp)
    80004f56:	6145                	addi	sp,sp,48
    80004f58:	8082                	ret
    80004f5a:	64e2                	ld	s1,24(sp)
    80004f5c:	6942                	ld	s2,16(sp)
    80004f5e:	bfcd                	j	80004f50 <sys_dup+0x3c>

0000000080004f60 <sys_read>:
{
    80004f60:	7179                	addi	sp,sp,-48
    80004f62:	f406                	sd	ra,40(sp)
    80004f64:	f022                	sd	s0,32(sp)
    80004f66:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f68:	fd840593          	addi	a1,s0,-40
    80004f6c:	4505                	li	a0,1
    80004f6e:	9b9fd0ef          	jal	80002926 <argaddr>
  argint(2, &n);
    80004f72:	fe440593          	addi	a1,s0,-28
    80004f76:	4509                	li	a0,2
    80004f78:	993fd0ef          	jal	8000290a <argint>
  if (argfd(0, 0, &f) < 0)
    80004f7c:	fe840613          	addi	a2,s0,-24
    80004f80:	4581                	li	a1,0
    80004f82:	4501                	li	a0,0
    80004f84:	d93ff0ef          	jal	80004d16 <argfd>
    80004f88:	87aa                	mv	a5,a0
    return -1;
    80004f8a:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004f8c:	0007ca63          	bltz	a5,80004fa0 <sys_read+0x40>
  return fileread(f, p, n);
    80004f90:	fe442603          	lw	a2,-28(s0)
    80004f94:	fd843583          	ld	a1,-40(s0)
    80004f98:	fe843503          	ld	a0,-24(s0)
    80004f9c:	c94ff0ef          	jal	80004430 <fileread>
}
    80004fa0:	70a2                	ld	ra,40(sp)
    80004fa2:	7402                	ld	s0,32(sp)
    80004fa4:	6145                	addi	sp,sp,48
    80004fa6:	8082                	ret

0000000080004fa8 <sys_write>:
{
    80004fa8:	7179                	addi	sp,sp,-48
    80004faa:	f406                	sd	ra,40(sp)
    80004fac:	f022                	sd	s0,32(sp)
    80004fae:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004fb0:	fd840593          	addi	a1,s0,-40
    80004fb4:	4505                	li	a0,1
    80004fb6:	971fd0ef          	jal	80002926 <argaddr>
  argint(2, &n);
    80004fba:	fe440593          	addi	a1,s0,-28
    80004fbe:	4509                	li	a0,2
    80004fc0:	94bfd0ef          	jal	8000290a <argint>
  if (argfd(0, 0, &f) < 0)
    80004fc4:	fe840613          	addi	a2,s0,-24
    80004fc8:	4581                	li	a1,0
    80004fca:	4501                	li	a0,0
    80004fcc:	d4bff0ef          	jal	80004d16 <argfd>
    80004fd0:	87aa                	mv	a5,a0
    return -1;
    80004fd2:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004fd4:	0007ca63          	bltz	a5,80004fe8 <sys_write+0x40>
  return filewrite(f, p, n);
    80004fd8:	fe442603          	lw	a2,-28(s0)
    80004fdc:	fd843583          	ld	a1,-40(s0)
    80004fe0:	fe843503          	ld	a0,-24(s0)
    80004fe4:	d1aff0ef          	jal	800044fe <filewrite>
}
    80004fe8:	70a2                	ld	ra,40(sp)
    80004fea:	7402                	ld	s0,32(sp)
    80004fec:	6145                	addi	sp,sp,48
    80004fee:	8082                	ret

0000000080004ff0 <sys_close>:
{
    80004ff0:	1101                	addi	sp,sp,-32
    80004ff2:	ec06                	sd	ra,24(sp)
    80004ff4:	e822                	sd	s0,16(sp)
    80004ff6:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80004ff8:	fe040613          	addi	a2,s0,-32
    80004ffc:	fec40593          	addi	a1,s0,-20
    80005000:	4501                	li	a0,0
    80005002:	d15ff0ef          	jal	80004d16 <argfd>
    return -1;
    80005006:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80005008:	02054163          	bltz	a0,8000502a <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    8000500c:	941fc0ef          	jal	8000194c <myproc>
    80005010:	fec42783          	lw	a5,-20(s0)
    80005014:	078e                	slli	a5,a5,0x3
    80005016:	0d078793          	addi	a5,a5,208
    8000501a:	953e                	add	a0,a0,a5
    8000501c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005020:	fe043503          	ld	a0,-32(s0)
    80005024:	adaff0ef          	jal	800042fe <fileclose>
  return 0;
    80005028:	4781                	li	a5,0
}
    8000502a:	853e                	mv	a0,a5
    8000502c:	60e2                	ld	ra,24(sp)
    8000502e:	6442                	ld	s0,16(sp)
    80005030:	6105                	addi	sp,sp,32
    80005032:	8082                	ret

0000000080005034 <sys_fstat>:
{
    80005034:	1101                	addi	sp,sp,-32
    80005036:	ec06                	sd	ra,24(sp)
    80005038:	e822                	sd	s0,16(sp)
    8000503a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000503c:	fe040593          	addi	a1,s0,-32
    80005040:	4505                	li	a0,1
    80005042:	8e5fd0ef          	jal	80002926 <argaddr>
  if (argfd(0, 0, &f) < 0)
    80005046:	fe840613          	addi	a2,s0,-24
    8000504a:	4581                	li	a1,0
    8000504c:	4501                	li	a0,0
    8000504e:	cc9ff0ef          	jal	80004d16 <argfd>
    80005052:	87aa                	mv	a5,a0
    return -1;
    80005054:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005056:	0007c863          	bltz	a5,80005066 <sys_fstat+0x32>
  return filestat(f, st);
    8000505a:	fe043583          	ld	a1,-32(s0)
    8000505e:	fe843503          	ld	a0,-24(s0)
    80005062:	b5eff0ef          	jal	800043c0 <filestat>
}
    80005066:	60e2                	ld	ra,24(sp)
    80005068:	6442                	ld	s0,16(sp)
    8000506a:	6105                	addi	sp,sp,32
    8000506c:	8082                	ret

000000008000506e <sys_link>:
{
    8000506e:	7169                	addi	sp,sp,-304
    80005070:	f606                	sd	ra,296(sp)
    80005072:	f222                	sd	s0,288(sp)
    80005074:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005076:	08000613          	li	a2,128
    8000507a:	ed040593          	addi	a1,s0,-304
    8000507e:	4501                	li	a0,0
    80005080:	8c3fd0ef          	jal	80002942 <argstr>
    return -1;
    80005084:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005086:	10054163          	bltz	a0,80005188 <sys_link+0x11a>
    8000508a:	08000613          	li	a2,128
    8000508e:	f5040593          	addi	a1,s0,-176
    80005092:	4505                	li	a0,1
    80005094:	8affd0ef          	jal	80002942 <argstr>
    return -1;
    80005098:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000509a:	0e054763          	bltz	a0,80005188 <sys_link+0x11a>
    8000509e:	ee26                	sd	s1,280(sp)
  begin_op();
    800050a0:	da5fe0ef          	jal	80003e44 <begin_op>
  if ((ip = namei(old)) == 0) {
    800050a4:	ed040513          	addi	a0,s0,-304
    800050a8:	bbffe0ef          	jal	80003c66 <namei>
    800050ac:	84aa                	mv	s1,a0
    800050ae:	cd35                	beqz	a0,8000512a <sys_link+0xbc>
  ilock(ip);
    800050b0:	b1cfe0ef          	jal	800033cc <ilock>
  if (ip->type == T_DIR) {
    800050b4:	04449703          	lh	a4,68(s1)
    800050b8:	4785                	li	a5,1
    800050ba:	06f70d63          	beq	a4,a5,80005134 <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    800050be:	04a49783          	lh	a5,74(s1)
    800050c2:	6721                	lui	a4,0x8
    800050c4:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    800050c6:	06e78f63          	beq	a5,a4,80005144 <sys_link+0xd6>
    800050ca:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800050cc:	2785                	addiw	a5,a5,1
    800050ce:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800050d2:	8526                	mv	a0,s1
    800050d4:	a44fe0ef          	jal	80003318 <iupdate>
  iunlock(ip);
    800050d8:	8526                	mv	a0,s1
    800050da:	ba0fe0ef          	jal	8000347a <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    800050de:	fd040593          	addi	a1,s0,-48
    800050e2:	f5040513          	addi	a0,s0,-176
    800050e6:	b9bfe0ef          	jal	80003c80 <nameiparent>
    800050ea:	892a                	mv	s2,a0
    800050ec:	c93d                	beqz	a0,80005162 <sys_link+0xf4>
  ilock(dp);
    800050ee:	adefe0ef          	jal	800033cc <ilock>
  if (dp->nlink == 0) {
    800050f2:	04a91783          	lh	a5,74(s2)
    800050f6:	cfb9                	beqz	a5,80005154 <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    800050f8:	854a                	mv	a0,s2
    800050fa:	00092703          	lw	a4,0(s2)
    800050fe:	409c                	lw	a5,0(s1)
    80005100:	04f71e63          	bne	a4,a5,8000515c <sys_link+0xee>
    80005104:	40d0                	lw	a2,4(s1)
    80005106:	fd040593          	addi	a1,s0,-48
    8000510a:	ab3fe0ef          	jal	80003bbc <dirlink>
    8000510e:	04054763          	bltz	a0,8000515c <sys_link+0xee>
  iunlockput(dp);
    80005112:	854a                	mv	a0,s2
    80005114:	d0cfe0ef          	jal	80003620 <iunlockput>
  iput(ip);
    80005118:	8526                	mv	a0,s1
    8000511a:	c34fe0ef          	jal	8000354e <iput>
  end_op();
    8000511e:	db3fe0ef          	jal	80003ed0 <end_op>
  return 0;
    80005122:	4781                	li	a5,0
    80005124:	64f2                	ld	s1,280(sp)
    80005126:	6952                	ld	s2,272(sp)
    80005128:	a085                	j	80005188 <sys_link+0x11a>
    end_op();
    8000512a:	da7fe0ef          	jal	80003ed0 <end_op>
    return -1;
    8000512e:	57fd                	li	a5,-1
    80005130:	64f2                	ld	s1,280(sp)
    80005132:	a899                	j	80005188 <sys_link+0x11a>
    iunlockput(ip);
    80005134:	8526                	mv	a0,s1
    80005136:	ceafe0ef          	jal	80003620 <iunlockput>
    end_op();
    8000513a:	d97fe0ef          	jal	80003ed0 <end_op>
    return -1;
    8000513e:	57fd                	li	a5,-1
    80005140:	64f2                	ld	s1,280(sp)
    80005142:	a099                	j	80005188 <sys_link+0x11a>
    iunlockput(ip);
    80005144:	8526                	mv	a0,s1
    80005146:	cdafe0ef          	jal	80003620 <iunlockput>
    end_op();
    8000514a:	d87fe0ef          	jal	80003ed0 <end_op>
    return -1;
    8000514e:	57fd                	li	a5,-1
    80005150:	64f2                	ld	s1,280(sp)
    80005152:	a81d                	j	80005188 <sys_link+0x11a>
    iunlockput(dp);
    80005154:	854a                	mv	a0,s2
    80005156:	ccafe0ef          	jal	80003620 <iunlockput>
    goto bad;
    8000515a:	a021                	j	80005162 <sys_link+0xf4>
    iunlockput(dp);
    8000515c:	854a                	mv	a0,s2
    8000515e:	cc2fe0ef          	jal	80003620 <iunlockput>
  ilock(ip);
    80005162:	8526                	mv	a0,s1
    80005164:	a68fe0ef          	jal	800033cc <ilock>
  ip->nlink--;
    80005168:	04a4d783          	lhu	a5,74(s1)
    8000516c:	37fd                	addiw	a5,a5,-1
    8000516e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005172:	8526                	mv	a0,s1
    80005174:	9a4fe0ef          	jal	80003318 <iupdate>
  iunlockput(ip);
    80005178:	8526                	mv	a0,s1
    8000517a:	ca6fe0ef          	jal	80003620 <iunlockput>
  end_op();
    8000517e:	d53fe0ef          	jal	80003ed0 <end_op>
  return -1;
    80005182:	57fd                	li	a5,-1
    80005184:	64f2                	ld	s1,280(sp)
    80005186:	6952                	ld	s2,272(sp)
}
    80005188:	853e                	mv	a0,a5
    8000518a:	70b2                	ld	ra,296(sp)
    8000518c:	7412                	ld	s0,288(sp)
    8000518e:	6155                	addi	sp,sp,304
    80005190:	8082                	ret

0000000080005192 <sys_unlink>:
{
    80005192:	7151                	addi	sp,sp,-240
    80005194:	f586                	sd	ra,232(sp)
    80005196:	f1a2                	sd	s0,224(sp)
    80005198:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    8000519a:	08000613          	li	a2,128
    8000519e:	f3040593          	addi	a1,s0,-208
    800051a2:	4501                	li	a0,0
    800051a4:	f9efd0ef          	jal	80002942 <argstr>
    800051a8:	14054d63          	bltz	a0,80005302 <sys_unlink+0x170>
    800051ac:	eda6                	sd	s1,216(sp)
  begin_op();
    800051ae:	c97fe0ef          	jal	80003e44 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    800051b2:	fb040593          	addi	a1,s0,-80
    800051b6:	f3040513          	addi	a0,s0,-208
    800051ba:	ac7fe0ef          	jal	80003c80 <nameiparent>
    800051be:	84aa                	mv	s1,a0
    800051c0:	c955                	beqz	a0,80005274 <sys_unlink+0xe2>
  ilock(dp);
    800051c2:	a0afe0ef          	jal	800033cc <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800051c6:	00002597          	auipc	a1,0x2
    800051ca:	42258593          	addi	a1,a1,1058 # 800075e8 <etext+0x5e8>
    800051ce:	fb040513          	addi	a0,s0,-80
    800051d2:	fccfe0ef          	jal	8000399e <namecmp>
    800051d6:	10050b63          	beqz	a0,800052ec <sys_unlink+0x15a>
    800051da:	00002597          	auipc	a1,0x2
    800051de:	41658593          	addi	a1,a1,1046 # 800075f0 <etext+0x5f0>
    800051e2:	fb040513          	addi	a0,s0,-80
    800051e6:	fb8fe0ef          	jal	8000399e <namecmp>
    800051ea:	10050163          	beqz	a0,800052ec <sys_unlink+0x15a>
    800051ee:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    800051f0:	f2c40613          	addi	a2,s0,-212
    800051f4:	fb040593          	addi	a1,s0,-80
    800051f8:	8526                	mv	a0,s1
    800051fa:	fbafe0ef          	jal	800039b4 <dirlookup>
    800051fe:	892a                	mv	s2,a0
    80005200:	0e050563          	beqz	a0,800052ea <sys_unlink+0x158>
    80005204:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80005206:	9c6fe0ef          	jal	800033cc <ilock>
  if (ip->nlink < 1)
    8000520a:	04a91783          	lh	a5,74(s2)
    8000520e:	06f05863          	blez	a5,8000527e <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    80005212:	04491703          	lh	a4,68(s2)
    80005216:	4785                	li	a5,1
    80005218:	06f70963          	beq	a4,a5,8000528a <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    8000521c:	fc040993          	addi	s3,s0,-64
    80005220:	4641                	li	a2,16
    80005222:	4581                	li	a1,0
    80005224:	854e                	mv	a0,s3
    80005226:	ac3fb0ef          	jal	80000ce8 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000522a:	4741                	li	a4,16
    8000522c:	f2c42683          	lw	a3,-212(s0)
    80005230:	864e                	mv	a2,s3
    80005232:	4581                	li	a1,0
    80005234:	8526                	mv	a0,s1
    80005236:	e62fe0ef          	jal	80003898 <writei>
    8000523a:	47c1                	li	a5,16
    8000523c:	08f51863          	bne	a0,a5,800052cc <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    80005240:	04491703          	lh	a4,68(s2)
    80005244:	4785                	li	a5,1
    80005246:	08f70963          	beq	a4,a5,800052d8 <sys_unlink+0x146>
  iunlockput(dp);
    8000524a:	8526                	mv	a0,s1
    8000524c:	bd4fe0ef          	jal	80003620 <iunlockput>
  ip->nlink--;
    80005250:	04a95783          	lhu	a5,74(s2)
    80005254:	37fd                	addiw	a5,a5,-1
    80005256:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000525a:	854a                	mv	a0,s2
    8000525c:	8bcfe0ef          	jal	80003318 <iupdate>
  iunlockput(ip);
    80005260:	854a                	mv	a0,s2
    80005262:	bbefe0ef          	jal	80003620 <iunlockput>
  end_op();
    80005266:	c6bfe0ef          	jal	80003ed0 <end_op>
  return 0;
    8000526a:	4501                	li	a0,0
    8000526c:	64ee                	ld	s1,216(sp)
    8000526e:	694e                	ld	s2,208(sp)
    80005270:	69ae                	ld	s3,200(sp)
    80005272:	a061                	j	800052fa <sys_unlink+0x168>
    end_op();
    80005274:	c5dfe0ef          	jal	80003ed0 <end_op>
    return -1;
    80005278:	557d                	li	a0,-1
    8000527a:	64ee                	ld	s1,216(sp)
    8000527c:	a8bd                	j	800052fa <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    8000527e:	00002517          	auipc	a0,0x2
    80005282:	37a50513          	addi	a0,a0,890 # 800075f8 <etext+0x5f8>
    80005286:	daefb0ef          	jal	80000834 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    8000528a:	04c92703          	lw	a4,76(s2)
    8000528e:	02000793          	li	a5,32
    80005292:	f8e7f5e3          	bgeu	a5,a4,8000521c <sys_unlink+0x8a>
    80005296:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005298:	4741                	li	a4,16
    8000529a:	86ce                	mv	a3,s3
    8000529c:	f1840613          	addi	a2,s0,-232
    800052a0:	4581                	li	a1,0
    800052a2:	854a                	mv	a0,s2
    800052a4:	d02fe0ef          	jal	800037a6 <readi>
    800052a8:	47c1                	li	a5,16
    800052aa:	00f51b63          	bne	a0,a5,800052c0 <sys_unlink+0x12e>
    if (de.inum != 0)
    800052ae:	f1845783          	lhu	a5,-232(s0)
    800052b2:	ebb1                	bnez	a5,80005306 <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    800052b4:	29c1                	addiw	s3,s3,16
    800052b6:	04c92783          	lw	a5,76(s2)
    800052ba:	fcf9efe3          	bltu	s3,a5,80005298 <sys_unlink+0x106>
    800052be:	bfb9                	j	8000521c <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800052c0:	00002517          	auipc	a0,0x2
    800052c4:	35050513          	addi	a0,a0,848 # 80007610 <etext+0x610>
    800052c8:	d6cfb0ef          	jal	80000834 <panic>
    panic("unlink: writei");
    800052cc:	00002517          	auipc	a0,0x2
    800052d0:	35c50513          	addi	a0,a0,860 # 80007628 <etext+0x628>
    800052d4:	d60fb0ef          	jal	80000834 <panic>
    dp->nlink--;
    800052d8:	04a4d783          	lhu	a5,74(s1)
    800052dc:	37fd                	addiw	a5,a5,-1
    800052de:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800052e2:	8526                	mv	a0,s1
    800052e4:	834fe0ef          	jal	80003318 <iupdate>
    800052e8:	b78d                	j	8000524a <sys_unlink+0xb8>
    800052ea:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800052ec:	8526                	mv	a0,s1
    800052ee:	b32fe0ef          	jal	80003620 <iunlockput>
  end_op();
    800052f2:	bdffe0ef          	jal	80003ed0 <end_op>
  return -1;
    800052f6:	557d                	li	a0,-1
    800052f8:	64ee                	ld	s1,216(sp)
}
    800052fa:	70ae                	ld	ra,232(sp)
    800052fc:	740e                	ld	s0,224(sp)
    800052fe:	616d                	addi	sp,sp,240
    80005300:	8082                	ret
    return -1;
    80005302:	557d                	li	a0,-1
    80005304:	bfdd                	j	800052fa <sys_unlink+0x168>
    iunlockput(ip);
    80005306:	854a                	mv	a0,s2
    80005308:	b18fe0ef          	jal	80003620 <iunlockput>
    goto bad;
    8000530c:	694e                	ld	s2,208(sp)
    8000530e:	69ae                	ld	s3,200(sp)
    80005310:	bff1                	j	800052ec <sys_unlink+0x15a>

0000000080005312 <sys_open>:

uint64
sys_open(void)
{
    80005312:	7131                	addi	sp,sp,-192
    80005314:	fd06                	sd	ra,184(sp)
    80005316:	f922                	sd	s0,176(sp)
    80005318:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000531a:	f4c40593          	addi	a1,s0,-180
    8000531e:	4505                	li	a0,1
    80005320:	deafd0ef          	jal	8000290a <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005324:	08000613          	li	a2,128
    80005328:	f5040593          	addi	a1,s0,-176
    8000532c:	4501                	li	a0,0
    8000532e:	e14fd0ef          	jal	80002942 <argstr>
    80005332:	87aa                	mv	a5,a0
    return -1;
    80005334:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005336:	0a07c363          	bltz	a5,800053dc <sys_open+0xca>
    8000533a:	f526                	sd	s1,168(sp)

  begin_op();
    8000533c:	b09fe0ef          	jal	80003e44 <begin_op>

  if (omode & O_CREATE) {
    80005340:	f4c42783          	lw	a5,-180(s0)
    80005344:	2007f793          	andi	a5,a5,512
    80005348:	c3dd                	beqz	a5,800053ee <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    8000534a:	4681                	li	a3,0
    8000534c:	4601                	li	a2,0
    8000534e:	4589                	li	a1,2
    80005350:	f5040513          	addi	a0,s0,-176
    80005354:	a5dff0ef          	jal	80004db0 <create>
    80005358:	84aa                	mv	s1,a0
    if (ip == 0) {
    8000535a:	c549                	beqz	a0,800053e4 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    8000535c:	04449703          	lh	a4,68(s1)
    80005360:	478d                	li	a5,3
    80005362:	00f71763          	bne	a4,a5,80005370 <sys_open+0x5e>
    80005366:	0464d703          	lhu	a4,70(s1)
    8000536a:	47a5                	li	a5,9
    8000536c:	0ae7ee63          	bltu	a5,a4,80005428 <sys_open+0x116>
    80005370:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    80005372:	ee9fe0ef          	jal	8000425a <filealloc>
    80005376:	892a                	mv	s2,a0
    80005378:	c561                	beqz	a0,80005440 <sys_open+0x12e>
    8000537a:	ed4e                	sd	s3,152(sp)
    8000537c:	9f5ff0ef          	jal	80004d70 <fdalloc>
    80005380:	89aa                	mv	s3,a0
    80005382:	0a054b63          	bltz	a0,80005438 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    80005386:	04449703          	lh	a4,68(s1)
    8000538a:	478d                	li	a5,3
    8000538c:	0cf70363          	beq	a4,a5,80005452 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005390:	4789                	li	a5,2
    80005392:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005396:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000539a:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000539e:	f4c42783          	lw	a5,-180(s0)
    800053a2:	0017f713          	andi	a4,a5,1
    800053a6:	00174713          	xori	a4,a4,1
    800053aa:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800053ae:	0037f713          	andi	a4,a5,3
    800053b2:	00e03733          	snez	a4,a4
    800053b6:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    800053ba:	4007f793          	andi	a5,a5,1024
    800053be:	c791                	beqz	a5,800053ca <sys_open+0xb8>
    800053c0:	04449703          	lh	a4,68(s1)
    800053c4:	4789                	li	a5,2
    800053c6:	08f70d63          	beq	a4,a5,80005460 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800053ca:	8526                	mv	a0,s1
    800053cc:	8aefe0ef          	jal	8000347a <iunlock>
  end_op();
    800053d0:	b01fe0ef          	jal	80003ed0 <end_op>

  return fd;
    800053d4:	854e                	mv	a0,s3
    800053d6:	74aa                	ld	s1,168(sp)
    800053d8:	790a                	ld	s2,160(sp)
    800053da:	69ea                	ld	s3,152(sp)
}
    800053dc:	70ea                	ld	ra,184(sp)
    800053de:	744a                	ld	s0,176(sp)
    800053e0:	6129                	addi	sp,sp,192
    800053e2:	8082                	ret
      end_op();
    800053e4:	aedfe0ef          	jal	80003ed0 <end_op>
      return -1;
    800053e8:	557d                	li	a0,-1
    800053ea:	74aa                	ld	s1,168(sp)
    800053ec:	bfc5                	j	800053dc <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    800053ee:	f5040513          	addi	a0,s0,-176
    800053f2:	875fe0ef          	jal	80003c66 <namei>
    800053f6:	84aa                	mv	s1,a0
    800053f8:	c11d                	beqz	a0,8000541e <sys_open+0x10c>
    ilock(ip);
    800053fa:	fd3fd0ef          	jal	800033cc <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    800053fe:	04449703          	lh	a4,68(s1)
    80005402:	4785                	li	a5,1
    80005404:	f4f71ce3          	bne	a4,a5,8000535c <sys_open+0x4a>
    80005408:	f4c42783          	lw	a5,-180(s0)
    8000540c:	d3b5                	beqz	a5,80005370 <sys_open+0x5e>
      iunlockput(ip);
    8000540e:	8526                	mv	a0,s1
    80005410:	a10fe0ef          	jal	80003620 <iunlockput>
      end_op();
    80005414:	abdfe0ef          	jal	80003ed0 <end_op>
      return -1;
    80005418:	557d                	li	a0,-1
    8000541a:	74aa                	ld	s1,168(sp)
    8000541c:	b7c1                	j	800053dc <sys_open+0xca>
      end_op();
    8000541e:	ab3fe0ef          	jal	80003ed0 <end_op>
      return -1;
    80005422:	557d                	li	a0,-1
    80005424:	74aa                	ld	s1,168(sp)
    80005426:	bf5d                	j	800053dc <sys_open+0xca>
    iunlockput(ip);
    80005428:	8526                	mv	a0,s1
    8000542a:	9f6fe0ef          	jal	80003620 <iunlockput>
    end_op();
    8000542e:	aa3fe0ef          	jal	80003ed0 <end_op>
    return -1;
    80005432:	557d                	li	a0,-1
    80005434:	74aa                	ld	s1,168(sp)
    80005436:	b75d                	j	800053dc <sys_open+0xca>
      fileclose(f);
    80005438:	854a                	mv	a0,s2
    8000543a:	ec5fe0ef          	jal	800042fe <fileclose>
    8000543e:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005440:	8526                	mv	a0,s1
    80005442:	9defe0ef          	jal	80003620 <iunlockput>
    end_op();
    80005446:	a8bfe0ef          	jal	80003ed0 <end_op>
    return -1;
    8000544a:	557d                	li	a0,-1
    8000544c:	74aa                	ld	s1,168(sp)
    8000544e:	790a                	ld	s2,160(sp)
    80005450:	b771                	j	800053dc <sys_open+0xca>
    f->type = FD_DEVICE;
    80005452:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005456:	04649783          	lh	a5,70(s1)
    8000545a:	02f91223          	sh	a5,36(s2)
    8000545e:	bf35                	j	8000539a <sys_open+0x88>
    itrunc(ip);
    80005460:	8526                	mv	a0,s1
    80005462:	858fe0ef          	jal	800034ba <itrunc>
    80005466:	b795                	j	800053ca <sys_open+0xb8>

0000000080005468 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005468:	7175                	addi	sp,sp,-144
    8000546a:	e506                	sd	ra,136(sp)
    8000546c:	e122                	sd	s0,128(sp)
    8000546e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005470:	9d5fe0ef          	jal	80003e44 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    80005474:	08000613          	li	a2,128
    80005478:	f7040593          	addi	a1,s0,-144
    8000547c:	4501                	li	a0,0
    8000547e:	cc4fd0ef          	jal	80002942 <argstr>
    80005482:	02054363          	bltz	a0,800054a8 <sys_mkdir+0x40>
    80005486:	4681                	li	a3,0
    80005488:	4601                	li	a2,0
    8000548a:	4585                	li	a1,1
    8000548c:	f7040513          	addi	a0,s0,-144
    80005490:	921ff0ef          	jal	80004db0 <create>
    80005494:	c911                	beqz	a0,800054a8 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005496:	98afe0ef          	jal	80003620 <iunlockput>
  end_op();
    8000549a:	a37fe0ef          	jal	80003ed0 <end_op>
  return 0;
    8000549e:	4501                	li	a0,0
}
    800054a0:	60aa                	ld	ra,136(sp)
    800054a2:	640a                	ld	s0,128(sp)
    800054a4:	6149                	addi	sp,sp,144
    800054a6:	8082                	ret
    end_op();
    800054a8:	a29fe0ef          	jal	80003ed0 <end_op>
    return -1;
    800054ac:	557d                	li	a0,-1
    800054ae:	bfcd                	j	800054a0 <sys_mkdir+0x38>

00000000800054b0 <sys_mknod>:

uint64
sys_mknod(void)
{
    800054b0:	7135                	addi	sp,sp,-160
    800054b2:	ed06                	sd	ra,152(sp)
    800054b4:	e922                	sd	s0,144(sp)
    800054b6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800054b8:	98dfe0ef          	jal	80003e44 <begin_op>
  argint(1, &major);
    800054bc:	f6c40593          	addi	a1,s0,-148
    800054c0:	4505                	li	a0,1
    800054c2:	c48fd0ef          	jal	8000290a <argint>
  argint(2, &minor);
    800054c6:	f6840593          	addi	a1,s0,-152
    800054ca:	4509                	li	a0,2
    800054cc:	c3efd0ef          	jal	8000290a <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800054d0:	08000613          	li	a2,128
    800054d4:	f7040593          	addi	a1,s0,-144
    800054d8:	4501                	li	a0,0
    800054da:	c68fd0ef          	jal	80002942 <argstr>
    800054de:	02054563          	bltz	a0,80005508 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    800054e2:	f6841683          	lh	a3,-152(s0)
    800054e6:	f6c41603          	lh	a2,-148(s0)
    800054ea:	458d                	li	a1,3
    800054ec:	f7040513          	addi	a0,s0,-144
    800054f0:	8c1ff0ef          	jal	80004db0 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800054f4:	c911                	beqz	a0,80005508 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800054f6:	92afe0ef          	jal	80003620 <iunlockput>
  end_op();
    800054fa:	9d7fe0ef          	jal	80003ed0 <end_op>
  return 0;
    800054fe:	4501                	li	a0,0
}
    80005500:	60ea                	ld	ra,152(sp)
    80005502:	644a                	ld	s0,144(sp)
    80005504:	610d                	addi	sp,sp,160
    80005506:	8082                	ret
    end_op();
    80005508:	9c9fe0ef          	jal	80003ed0 <end_op>
    return -1;
    8000550c:	557d                	li	a0,-1
    8000550e:	bfcd                	j	80005500 <sys_mknod+0x50>

0000000080005510 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005510:	7135                	addi	sp,sp,-160
    80005512:	ed06                	sd	ra,152(sp)
    80005514:	e922                	sd	s0,144(sp)
    80005516:	e14a                	sd	s2,128(sp)
    80005518:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000551a:	c32fc0ef          	jal	8000194c <myproc>
    8000551e:	892a                	mv	s2,a0

  begin_op();
    80005520:	925fe0ef          	jal	80003e44 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    80005524:	08000613          	li	a2,128
    80005528:	f6040593          	addi	a1,s0,-160
    8000552c:	4501                	li	a0,0
    8000552e:	c14fd0ef          	jal	80002942 <argstr>
    80005532:	04054363          	bltz	a0,80005578 <sys_chdir+0x68>
    80005536:	e526                	sd	s1,136(sp)
    80005538:	f6040513          	addi	a0,s0,-160
    8000553c:	f2afe0ef          	jal	80003c66 <namei>
    80005540:	84aa                	mv	s1,a0
    80005542:	c915                	beqz	a0,80005576 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005544:	e89fd0ef          	jal	800033cc <ilock>
  if (ip->type != T_DIR) {
    80005548:	04449703          	lh	a4,68(s1)
    8000554c:	4785                	li	a5,1
    8000554e:	02f71963          	bne	a4,a5,80005580 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005552:	8526                	mv	a0,s1
    80005554:	f27fd0ef          	jal	8000347a <iunlock>
  iput(p->cwd);
    80005558:	15093503          	ld	a0,336(s2)
    8000555c:	ff3fd0ef          	jal	8000354e <iput>
  end_op();
    80005560:	971fe0ef          	jal	80003ed0 <end_op>
  p->cwd = ip;
    80005564:	14993823          	sd	s1,336(s2)
  return 0;
    80005568:	4501                	li	a0,0
    8000556a:	64aa                	ld	s1,136(sp)
}
    8000556c:	60ea                	ld	ra,152(sp)
    8000556e:	644a                	ld	s0,144(sp)
    80005570:	690a                	ld	s2,128(sp)
    80005572:	610d                	addi	sp,sp,160
    80005574:	8082                	ret
    80005576:	64aa                	ld	s1,136(sp)
    end_op();
    80005578:	959fe0ef          	jal	80003ed0 <end_op>
    return -1;
    8000557c:	557d                	li	a0,-1
    8000557e:	b7fd                	j	8000556c <sys_chdir+0x5c>
    iunlockput(ip);
    80005580:	8526                	mv	a0,s1
    80005582:	89efe0ef          	jal	80003620 <iunlockput>
    end_op();
    80005586:	94bfe0ef          	jal	80003ed0 <end_op>
    return -1;
    8000558a:	557d                	li	a0,-1
    8000558c:	64aa                	ld	s1,136(sp)
    8000558e:	bff9                	j	8000556c <sys_chdir+0x5c>

0000000080005590 <sys_exec>:

uint64
sys_exec(void)
{
    80005590:	7105                	addi	sp,sp,-480
    80005592:	ef86                	sd	ra,472(sp)
    80005594:	eba2                	sd	s0,464(sp)
    80005596:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005598:	e2840593          	addi	a1,s0,-472
    8000559c:	4505                	li	a0,1
    8000559e:	b88fd0ef          	jal	80002926 <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    800055a2:	08000613          	li	a2,128
    800055a6:	f3040593          	addi	a1,s0,-208
    800055aa:	4501                	li	a0,0
    800055ac:	b96fd0ef          	jal	80002942 <argstr>
    800055b0:	87aa                	mv	a5,a0
    return -1;
    800055b2:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    800055b4:	0e07c063          	bltz	a5,80005694 <sys_exec+0x104>
    800055b8:	e7a6                	sd	s1,456(sp)
    800055ba:	e3ca                	sd	s2,448(sp)
    800055bc:	ff4e                	sd	s3,440(sp)
    800055be:	fb52                	sd	s4,432(sp)
    800055c0:	f756                	sd	s5,424(sp)
    800055c2:	f35a                	sd	s6,416(sp)
    800055c4:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800055c6:	e3040a13          	addi	s4,s0,-464
    800055ca:	10000613          	li	a2,256
    800055ce:	4581                	li	a1,0
    800055d0:	8552                	mv	a0,s4
    800055d2:	f16fb0ef          	jal	80000ce8 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    800055d6:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800055d8:	89d2                	mv	s3,s4
    800055da:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    800055dc:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800055e0:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    800055e2:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    800055e6:	00391513          	slli	a0,s2,0x3
    800055ea:	85d6                	mv	a1,s5
    800055ec:	e2843783          	ld	a5,-472(s0)
    800055f0:	953e                	add	a0,a0,a5
    800055f2:	a8cfd0ef          	jal	8000287e <fetchaddr>
    800055f6:	02054663          	bltz	a0,80005622 <sys_exec+0x92>
    if (uarg == 0) {
    800055fa:	e2043783          	ld	a5,-480(s0)
    800055fe:	c7a1                	beqz	a5,80005646 <sys_exec+0xb6>
    argv[i] = kalloc();
    80005600:	d4efb0ef          	jal	80000b4e <kalloc>
    80005604:	85aa                	mv	a1,a0
    80005606:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    8000560a:	cd01                	beqz	a0,80005622 <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000560c:	865a                	mv	a2,s6
    8000560e:	e2043503          	ld	a0,-480(s0)
    80005612:	ab6fd0ef          	jal	800028c8 <fetchstr>
    80005616:	00054663          	bltz	a0,80005622 <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    8000561a:	0905                	addi	s2,s2,1
    8000561c:	09a1                	addi	s3,s3,8
    8000561e:	fd7914e3          	bne	s2,s7,800055e6 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005622:	100a0a13          	addi	s4,s4,256
    80005626:	6088                	ld	a0,0(s1)
    80005628:	cd31                	beqz	a0,80005684 <sys_exec+0xf4>
    kfree(argv[i]);
    8000562a:	c3cfb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000562e:	04a1                	addi	s1,s1,8
    80005630:	ff449be3          	bne	s1,s4,80005626 <sys_exec+0x96>
  return -1;
    80005634:	557d                	li	a0,-1
    80005636:	64be                	ld	s1,456(sp)
    80005638:	691e                	ld	s2,448(sp)
    8000563a:	79fa                	ld	s3,440(sp)
    8000563c:	7a5a                	ld	s4,432(sp)
    8000563e:	7aba                	ld	s5,424(sp)
    80005640:	7b1a                	ld	s6,416(sp)
    80005642:	6bfa                	ld	s7,408(sp)
    80005644:	a881                	j	80005694 <sys_exec+0x104>
      argv[i] = 0;
    80005646:	0009079b          	sext.w	a5,s2
    8000564a:	e3040593          	addi	a1,s0,-464
    8000564e:	078e                	slli	a5,a5,0x3
    80005650:	97ae                	add	a5,a5,a1
    80005652:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    80005656:	f3040513          	addi	a0,s0,-208
    8000565a:	b62ff0ef          	jal	800049bc <kexec>
    8000565e:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005660:	100a0a13          	addi	s4,s4,256
    80005664:	6088                	ld	a0,0(s1)
    80005666:	c511                	beqz	a0,80005672 <sys_exec+0xe2>
    kfree(argv[i]);
    80005668:	bfefb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000566c:	04a1                	addi	s1,s1,8
    8000566e:	ff449be3          	bne	s1,s4,80005664 <sys_exec+0xd4>
  return ret;
    80005672:	854a                	mv	a0,s2
    80005674:	64be                	ld	s1,456(sp)
    80005676:	691e                	ld	s2,448(sp)
    80005678:	79fa                	ld	s3,440(sp)
    8000567a:	7a5a                	ld	s4,432(sp)
    8000567c:	7aba                	ld	s5,424(sp)
    8000567e:	7b1a                	ld	s6,416(sp)
    80005680:	6bfa                	ld	s7,408(sp)
    80005682:	a809                	j	80005694 <sys_exec+0x104>
  return -1;
    80005684:	557d                	li	a0,-1
    80005686:	64be                	ld	s1,456(sp)
    80005688:	691e                	ld	s2,448(sp)
    8000568a:	79fa                	ld	s3,440(sp)
    8000568c:	7a5a                	ld	s4,432(sp)
    8000568e:	7aba                	ld	s5,424(sp)
    80005690:	7b1a                	ld	s6,416(sp)
    80005692:	6bfa                	ld	s7,408(sp)
}
    80005694:	60fe                	ld	ra,472(sp)
    80005696:	645e                	ld	s0,464(sp)
    80005698:	613d                	addi	sp,sp,480
    8000569a:	8082                	ret

000000008000569c <sys_pipe>:

uint64
sys_pipe(void)
{
    8000569c:	7139                	addi	sp,sp,-64
    8000569e:	fc06                	sd	ra,56(sp)
    800056a0:	f822                	sd	s0,48(sp)
    800056a2:	f426                	sd	s1,40(sp)
    800056a4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800056a6:	aa6fc0ef          	jal	8000194c <myproc>
    800056aa:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800056ac:	fd840593          	addi	a1,s0,-40
    800056b0:	4501                	li	a0,0
    800056b2:	a74fd0ef          	jal	80002926 <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    800056b6:	fc840593          	addi	a1,s0,-56
    800056ba:	fd040513          	addi	a0,s0,-48
    800056be:	f7ffe0ef          	jal	8000463c <pipealloc>
    return -1;
    800056c2:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    800056c4:	0a054963          	bltz	a0,80005776 <sys_pipe+0xda>
  fd0 = -1;
    800056c8:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    800056cc:	fd043503          	ld	a0,-48(s0)
    800056d0:	ea0ff0ef          	jal	80004d70 <fdalloc>
    800056d4:	fca42223          	sw	a0,-60(s0)
    800056d8:	08054663          	bltz	a0,80005764 <sys_pipe+0xc8>
    800056dc:	fc843503          	ld	a0,-56(s0)
    800056e0:	e90ff0ef          	jal	80004d70 <fdalloc>
    800056e4:	fca42023          	sw	a0,-64(s0)
    800056e8:	06054463          	bltz	a0,80005750 <sys_pipe+0xb4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800056ec:	4711                	li	a4,4
    800056ee:	fc440693          	addi	a3,s0,-60
    800056f2:	fd843603          	ld	a2,-40(s0)
    800056f6:	64ac                	ld	a1,72(s1)
    800056f8:	68a8                	ld	a0,80(s1)
    800056fa:	e8dfb0ef          	jal	80001586 <copyout>
    800056fe:	00054f63          	bltz	a0,8000571c <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    80005702:	4711                	li	a4,4
    80005704:	fc040693          	addi	a3,s0,-64
    80005708:	fd843603          	ld	a2,-40(s0)
    8000570c:	963a                	add	a2,a2,a4
    8000570e:	64ac                	ld	a1,72(s1)
    80005710:	68a8                	ld	a0,80(s1)
    80005712:	e75fb0ef          	jal	80001586 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005716:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005718:	04055f63          	bgez	a0,80005776 <sys_pipe+0xda>
    p->ofile[fd0] = 0;
    8000571c:	fc442783          	lw	a5,-60(s0)
    80005720:	078e                	slli	a5,a5,0x3
    80005722:	0d078793          	addi	a5,a5,208
    80005726:	97a6                	add	a5,a5,s1
    80005728:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000572c:	fc042783          	lw	a5,-64(s0)
    80005730:	078e                	slli	a5,a5,0x3
    80005732:	0d078793          	addi	a5,a5,208
    80005736:	94be                	add	s1,s1,a5
    80005738:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000573c:	fd043503          	ld	a0,-48(s0)
    80005740:	bbffe0ef          	jal	800042fe <fileclose>
    fileclose(wf);
    80005744:	fc843503          	ld	a0,-56(s0)
    80005748:	bb7fe0ef          	jal	800042fe <fileclose>
    return -1;
    8000574c:	57fd                	li	a5,-1
    8000574e:	a025                	j	80005776 <sys_pipe+0xda>
    if (fd0 >= 0)
    80005750:	fc442783          	lw	a5,-60(s0)
    80005754:	0007c863          	bltz	a5,80005764 <sys_pipe+0xc8>
      p->ofile[fd0] = 0;
    80005758:	078e                	slli	a5,a5,0x3
    8000575a:	0d078793          	addi	a5,a5,208
    8000575e:	97a6                	add	a5,a5,s1
    80005760:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005764:	fd043503          	ld	a0,-48(s0)
    80005768:	b97fe0ef          	jal	800042fe <fileclose>
    fileclose(wf);
    8000576c:	fc843503          	ld	a0,-56(s0)
    80005770:	b8ffe0ef          	jal	800042fe <fileclose>
    return -1;
    80005774:	57fd                	li	a5,-1
}
    80005776:	853e                	mv	a0,a5
    80005778:	70e2                	ld	ra,56(sp)
    8000577a:	7442                	ld	s0,48(sp)
    8000577c:	74a2                	ld	s1,40(sp)
    8000577e:	6121                	addi	sp,sp,64
    80005780:	8082                	ret
	...

0000000080005790 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005790:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005792:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005794:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    80005796:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005798:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000579a:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000579c:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    8000579e:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800057a0:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800057a2:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800057a4:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800057a6:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800057a8:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800057aa:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800057ac:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800057ae:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800057b0:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800057b2:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800057b4:	fd9fc0ef          	jal	8000278c <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800057b8:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800057ba:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800057bc:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800057be:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800057c0:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800057c2:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800057c4:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800057c6:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800057c8:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800057ca:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800057cc:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800057ce:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800057d0:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800057d2:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800057d4:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800057d6:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800057d8:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800057da:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800057dc:	10200073          	sret
    800057e0:	0001                	nop
    800057e2:	00000013          	nop
    800057e6:	00000013          	nop
    800057ea:	00000013          	nop

00000000800057ee <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800057ee:	1141                	addi	sp,sp,-16
    800057f0:	e406                	sd	ra,8(sp)
    800057f2:	e022                	sd	s0,0(sp)
    800057f4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(volatile uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    800057f6:	0c000737          	lui	a4,0xc000
    800057fa:	4785                	li	a5,1
    800057fc:	d71c                	sw	a5,40(a4)
  *(volatile uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    800057fe:	c35c                	sw	a5,4(a4)
}
    80005800:	60a2                	ld	ra,8(sp)
    80005802:	6402                	ld	s0,0(sp)
    80005804:	0141                	addi	sp,sp,16
    80005806:	8082                	ret

0000000080005808 <plicinithart>:

void
plicinithart(void)
{
    80005808:	1141                	addi	sp,sp,-16
    8000580a:	e406                	sd	ra,8(sp)
    8000580c:	e022                	sd	s0,0(sp)
    8000580e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005810:	908fc0ef          	jal	80001918 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(volatile uint32 *)PLIC_SENABLE(hart) =
    80005814:	0085179b          	slliw	a5,a0,0x8
    80005818:	0c002737          	lui	a4,0xc002
    8000581c:	08070713          	addi	a4,a4,128 # c002080 <_entry-0x73ffdf80>
    80005820:	97ba                	add	a5,a5,a4
    80005822:	40200713          	li	a4,1026
    80005826:	c398                	sw	a4,0(a5)
    (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);

  // set this hart's S-mode priority threshold to 0.
  *(volatile uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005828:	00d5151b          	slliw	a0,a0,0xd
    8000582c:	0c2017b7          	lui	a5,0xc201
    80005830:	953e                	add	a0,a0,a5
    80005832:	00052023          	sw	zero,0(a0)
}
    80005836:	60a2                	ld	ra,8(sp)
    80005838:	6402                	ld	s0,0(sp)
    8000583a:	0141                	addi	sp,sp,16
    8000583c:	8082                	ret

000000008000583e <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000583e:	1141                	addi	sp,sp,-16
    80005840:	e406                	sd	ra,8(sp)
    80005842:	e022                	sd	s0,0(sp)
    80005844:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005846:	8d2fc0ef          	jal	80001918 <cpuid>
  int irq = *(volatile uint32 *)PLIC_SCLAIM(hart);
    8000584a:	00d5151b          	slliw	a0,a0,0xd
    8000584e:	0c2017b7          	lui	a5,0xc201
    80005852:	0791                	addi	a5,a5,4 # c201004 <_entry-0x73dfeffc>
    80005854:	953e                	add	a0,a0,a5
    80005856:	4108                	lw	a0,0(a0)
  return irq;
}
    80005858:	60a2                	ld	ra,8(sp)
    8000585a:	6402                	ld	s0,0(sp)
    8000585c:	0141                	addi	sp,sp,16
    8000585e:	8082                	ret

0000000080005860 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005860:	1101                	addi	sp,sp,-32
    80005862:	ec06                	sd	ra,24(sp)
    80005864:	e822                	sd	s0,16(sp)
    80005866:	e426                	sd	s1,8(sp)
    80005868:	1000                	addi	s0,sp,32
    8000586a:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000586c:	8acfc0ef          	jal	80001918 <cpuid>
  *(volatile uint32 *)PLIC_SCLAIM(hart) = irq;
    80005870:	00d5179b          	slliw	a5,a0,0xd
    80005874:	0c201737          	lui	a4,0xc201
    80005878:	0711                	addi	a4,a4,4 # c201004 <_entry-0x73dfeffc>
    8000587a:	97ba                	add	a5,a5,a4
    8000587c:	c384                	sw	s1,0(a5)
}
    8000587e:	60e2                	ld	ra,24(sp)
    80005880:	6442                	ld	s0,16(sp)
    80005882:	64a2                	ld	s1,8(sp)
    80005884:	6105                	addi	sp,sp,32
    80005886:	8082                	ret

0000000080005888 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005888:	1141                	addi	sp,sp,-16
    8000588a:	e406                	sd	ra,8(sp)
    8000588c:	e022                	sd	s0,0(sp)
    8000588e:	0800                	addi	s0,sp,16
  if (i >= NUM)
    80005890:	479d                	li	a5,7
    80005892:	04a7ca63          	blt	a5,a0,800058e6 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    80005896:	0001e797          	auipc	a5,0x1e
    8000589a:	cea78793          	addi	a5,a5,-790 # 80023580 <disk>
    8000589e:	97aa                	add	a5,a5,a0
    800058a0:	0187c783          	lbu	a5,24(a5)
    800058a4:	e7b9                	bnez	a5,800058f2 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800058a6:	00451693          	slli	a3,a0,0x4
    800058aa:	0001e797          	auipc	a5,0x1e
    800058ae:	cd678793          	addi	a5,a5,-810 # 80023580 <disk>
    800058b2:	6398                	ld	a4,0(a5)
    800058b4:	9736                	add	a4,a4,a3
    800058b6:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800058ba:	6398                	ld	a4,0(a5)
    800058bc:	9736                	add	a4,a4,a3
    800058be:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800058c2:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800058c6:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800058ca:	97aa                	add	a5,a5,a0
    800058cc:	4705                	li	a4,1
    800058ce:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800058d2:	0001e517          	auipc	a0,0x1e
    800058d6:	cc650513          	addi	a0,a0,-826 # 80023598 <disk+0x18>
    800058da:	f5efc0ef          	jal	80002038 <wakeup>
}
    800058de:	60a2                	ld	ra,8(sp)
    800058e0:	6402                	ld	s0,0(sp)
    800058e2:	0141                	addi	sp,sp,16
    800058e4:	8082                	ret
    panic("free_desc 1");
    800058e6:	00002517          	auipc	a0,0x2
    800058ea:	d5250513          	addi	a0,a0,-686 # 80007638 <etext+0x638>
    800058ee:	f47fa0ef          	jal	80000834 <panic>
    panic("free_desc 2");
    800058f2:	00002517          	auipc	a0,0x2
    800058f6:	d5650513          	addi	a0,a0,-682 # 80007648 <etext+0x648>
    800058fa:	f3bfa0ef          	jal	80000834 <panic>

00000000800058fe <virtio_disk_init>:
{
    800058fe:	1101                	addi	sp,sp,-32
    80005900:	ec06                	sd	ra,24(sp)
    80005902:	e822                	sd	s0,16(sp)
    80005904:	e426                	sd	s1,8(sp)
    80005906:	e04a                	sd	s2,0(sp)
    80005908:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000590a:	00002597          	auipc	a1,0x2
    8000590e:	d4e58593          	addi	a1,a1,-690 # 80007658 <etext+0x658>
    80005912:	0001e517          	auipc	a0,0x1e
    80005916:	d9650513          	addi	a0,a0,-618 # 800236a8 <disk+0x128>
    8000591a:	a8efb0ef          	jal	80000ba8 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000591e:	100017b7          	lui	a5,0x10001
    80005922:	4398                	lw	a4,0(a5)
    80005924:	2701                	sext.w	a4,a4
    80005926:	747277b7          	lui	a5,0x74727
    8000592a:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000592e:	14f71863          	bne	a4,a5,80005a7e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005932:	100017b7          	lui	a5,0x10001
    80005936:	43dc                	lw	a5,4(a5)
    80005938:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000593a:	4709                	li	a4,2
    8000593c:	14e79163          	bne	a5,a4,80005a7e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005940:	100017b7          	lui	a5,0x10001
    80005944:	479c                	lw	a5,8(a5)
    80005946:	2781                	sext.w	a5,a5
    80005948:	12e79b63          	bne	a5,a4,80005a7e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    8000594c:	100017b7          	lui	a5,0x10001
    80005950:	47d8                	lw	a4,12(a5)
    80005952:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005954:	554d47b7          	lui	a5,0x554d4
    80005958:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000595c:	12f71163          	bne	a4,a5,80005a7e <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005960:	100017b7          	lui	a5,0x10001
    80005964:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005968:	4705                	li	a4,1
    8000596a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000596c:	470d                	li	a4,3
    8000596e:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005970:	10001737          	lui	a4,0x10001
    80005974:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005976:	c7ffe6b7          	lui	a3,0xc7ffe
    8000597a:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fdae9f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000597e:	8f75                	and	a4,a4,a3
    80005980:	100016b7          	lui	a3,0x10001
    80005984:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005986:	472d                	li	a4,11
    80005988:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000598a:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000598e:	439c                	lw	a5,0(a5)
    80005990:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005994:	8ba1                	andi	a5,a5,8
    80005996:	0e078a63          	beqz	a5,80005a8a <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000599a:	100017b7          	lui	a5,0x10001
    8000599e:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    800059a2:	43fc                	lw	a5,68(a5)
    800059a4:	2781                	sext.w	a5,a5
    800059a6:	0e079863          	bnez	a5,80005a96 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800059aa:	100017b7          	lui	a5,0x10001
    800059ae:	5bdc                	lw	a5,52(a5)
    800059b0:	2781                	sext.w	a5,a5
  if (max == 0)
    800059b2:	0e078863          	beqz	a5,80005aa2 <virtio_disk_init+0x1a4>
  if (max < NUM)
    800059b6:	471d                	li	a4,7
    800059b8:	0ef77b63          	bgeu	a4,a5,80005aae <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    800059bc:	992fb0ef          	jal	80000b4e <kalloc>
    800059c0:	0001e497          	auipc	s1,0x1e
    800059c4:	bc048493          	addi	s1,s1,-1088 # 80023580 <disk>
    800059c8:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800059ca:	984fb0ef          	jal	80000b4e <kalloc>
    800059ce:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800059d0:	97efb0ef          	jal	80000b4e <kalloc>
    800059d4:	87aa                	mv	a5,a0
    800059d6:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    800059d8:	6088                	ld	a0,0(s1)
    800059da:	0e050063          	beqz	a0,80005aba <virtio_disk_init+0x1bc>
    800059de:	0001e717          	auipc	a4,0x1e
    800059e2:	baa73703          	ld	a4,-1110(a4) # 80023588 <disk+0x8>
    800059e6:	cb71                	beqz	a4,80005aba <virtio_disk_init+0x1bc>
    800059e8:	cbe9                	beqz	a5,80005aba <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    800059ea:	6605                	lui	a2,0x1
    800059ec:	4581                	li	a1,0
    800059ee:	afafb0ef          	jal	80000ce8 <memset>
  memset(disk.avail, 0, PGSIZE);
    800059f2:	0001e497          	auipc	s1,0x1e
    800059f6:	b8e48493          	addi	s1,s1,-1138 # 80023580 <disk>
    800059fa:	6605                	lui	a2,0x1
    800059fc:	4581                	li	a1,0
    800059fe:	6488                	ld	a0,8(s1)
    80005a00:	ae8fb0ef          	jal	80000ce8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005a04:	6605                	lui	a2,0x1
    80005a06:	4581                	li	a1,0
    80005a08:	6888                	ld	a0,16(s1)
    80005a0a:	adefb0ef          	jal	80000ce8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005a0e:	100017b7          	lui	a5,0x10001
    80005a12:	4721                	li	a4,8
    80005a14:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005a16:	4098                	lw	a4,0(s1)
    80005a18:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005a1c:	40d8                	lw	a4,4(s1)
    80005a1e:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005a22:	649c                	ld	a5,8(s1)
    80005a24:	0007869b          	sext.w	a3,a5
    80005a28:	10001737          	lui	a4,0x10001
    80005a2c:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005a30:	9781                	srai	a5,a5,0x20
    80005a32:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005a36:	689c                	ld	a5,16(s1)
    80005a38:	0007869b          	sext.w	a3,a5
    80005a3c:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005a40:	9781                	srai	a5,a5,0x20
    80005a42:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005a46:	4785                	li	a5,1
    80005a48:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005a4a:	00f48c23          	sb	a5,24(s1)
    80005a4e:	00f48ca3          	sb	a5,25(s1)
    80005a52:	00f48d23          	sb	a5,26(s1)
    80005a56:	00f48da3          	sb	a5,27(s1)
    80005a5a:	00f48e23          	sb	a5,28(s1)
    80005a5e:	00f48ea3          	sb	a5,29(s1)
    80005a62:	00f48f23          	sb	a5,30(s1)
    80005a66:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005a6a:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a6e:	07272823          	sw	s2,112(a4)
}
    80005a72:	60e2                	ld	ra,24(sp)
    80005a74:	6442                	ld	s0,16(sp)
    80005a76:	64a2                	ld	s1,8(sp)
    80005a78:	6902                	ld	s2,0(sp)
    80005a7a:	6105                	addi	sp,sp,32
    80005a7c:	8082                	ret
    panic("could not find virtio disk");
    80005a7e:	00002517          	auipc	a0,0x2
    80005a82:	bea50513          	addi	a0,a0,-1046 # 80007668 <etext+0x668>
    80005a86:	daffa0ef          	jal	80000834 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005a8a:	00002517          	auipc	a0,0x2
    80005a8e:	bfe50513          	addi	a0,a0,-1026 # 80007688 <etext+0x688>
    80005a92:	da3fa0ef          	jal	80000834 <panic>
    panic("virtio disk should not be ready");
    80005a96:	00002517          	auipc	a0,0x2
    80005a9a:	c1250513          	addi	a0,a0,-1006 # 800076a8 <etext+0x6a8>
    80005a9e:	d97fa0ef          	jal	80000834 <panic>
    panic("virtio disk has no queue 0");
    80005aa2:	00002517          	auipc	a0,0x2
    80005aa6:	c2650513          	addi	a0,a0,-986 # 800076c8 <etext+0x6c8>
    80005aaa:	d8bfa0ef          	jal	80000834 <panic>
    panic("virtio disk max queue too short");
    80005aae:	00002517          	auipc	a0,0x2
    80005ab2:	c3a50513          	addi	a0,a0,-966 # 800076e8 <etext+0x6e8>
    80005ab6:	d7ffa0ef          	jal	80000834 <panic>
    panic("virtio disk kalloc");
    80005aba:	00002517          	auipc	a0,0x2
    80005abe:	c4e50513          	addi	a0,a0,-946 # 80007708 <etext+0x708>
    80005ac2:	d73fa0ef          	jal	80000834 <panic>

0000000080005ac6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005ac6:	711d                	addi	sp,sp,-96
    80005ac8:	ec86                	sd	ra,88(sp)
    80005aca:	e8a2                	sd	s0,80(sp)
    80005acc:	e4a6                	sd	s1,72(sp)
    80005ace:	e0ca                	sd	s2,64(sp)
    80005ad0:	fc4e                	sd	s3,56(sp)
    80005ad2:	f852                	sd	s4,48(sp)
    80005ad4:	f456                	sd	s5,40(sp)
    80005ad6:	f05a                	sd	s6,32(sp)
    80005ad8:	ec5e                	sd	s7,24(sp)
    80005ada:	e862                	sd	s8,16(sp)
    80005adc:	1080                	addi	s0,sp,96
    80005ade:	89aa                	mv	s3,a0
    80005ae0:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005ae2:	00c52b83          	lw	s7,12(a0)
    80005ae6:	001b9b9b          	slliw	s7,s7,0x1
    80005aea:	1b82                	slli	s7,s7,0x20
    80005aec:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005af0:	0001e517          	auipc	a0,0x1e
    80005af4:	bb850513          	addi	a0,a0,-1096 # 800236a8 <disk+0x128>
    80005af8:	930fb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < NUM; i++) {
    80005afc:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005afe:	0001ea97          	auipc	s5,0x1e
    80005b02:	a82a8a93          	addi	s5,s5,-1406 # 80023580 <disk>
  for (int i = 0; i < 3; i++) {
    80005b06:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005b08:	5c7d                	li	s8,-1
    80005b0a:	a8a5                	j	80005b82 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80005b0c:	00fa8733          	add	a4,s5,a5
    80005b10:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005b14:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005b16:	0207c563          	bltz	a5,80005b40 <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    80005b1a:	2905                	addiw	s2,s2,1
    80005b1c:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005b1e:	07490663          	beq	s2,s4,80005b8a <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80005b22:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005b24:	0001e717          	auipc	a4,0x1e
    80005b28:	a5c70713          	addi	a4,a4,-1444 # 80023580 <disk>
    80005b2c:	4781                	li	a5,0
    if (disk.free[i]) {
    80005b2e:	01874683          	lbu	a3,24(a4)
    80005b32:	fee9                	bnez	a3,80005b0c <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    80005b34:	2785                	addiw	a5,a5,1
    80005b36:	0705                	addi	a4,a4,1
    80005b38:	fe979be3          	bne	a5,s1,80005b2e <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005b3c:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    80005b40:	01205d63          	blez	s2,80005b5a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005b44:	fa042503          	lw	a0,-96(s0)
    80005b48:	d41ff0ef          	jal	80005888 <free_desc>
      for (int j = 0; j < i; j++)
    80005b4c:	4785                	li	a5,1
    80005b4e:	0127d663          	bge	a5,s2,80005b5a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005b52:	fa442503          	lw	a0,-92(s0)
    80005b56:	d33ff0ef          	jal	80005888 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005b5a:	0001e517          	auipc	a0,0x1e
    80005b5e:	a3e50513          	addi	a0,a0,-1474 # 80023598 <disk+0x18>
    80005b62:	c6afc0ef          	jal	80001fcc <sleep_prepare>
    release(&disk.vdisk_lock);
    80005b66:	0001e517          	auipc	a0,0x1e
    80005b6a:	b4250513          	addi	a0,a0,-1214 # 800236a8 <disk+0x128>
    80005b6e:	942fb0ef          	jal	80000cb0 <release>
    sleep();
    80005b72:	c96fc0ef          	jal	80002008 <sleep>
    acquire(&disk.vdisk_lock);
    80005b76:	0001e517          	auipc	a0,0x1e
    80005b7a:	b3250513          	addi	a0,a0,-1230 # 800236a8 <disk+0x128>
    80005b7e:	8aafb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < 3; i++) {
    80005b82:	fa040613          	addi	a2,s0,-96
    80005b86:	4901                	li	s2,0
    80005b88:	bf69                	j	80005b22 <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b8a:	fa042503          	lw	a0,-96(s0)
    80005b8e:	00451693          	slli	a3,a0,0x4

  if (write)
    80005b92:	0001e797          	auipc	a5,0x1e
    80005b96:	9ee78793          	addi	a5,a5,-1554 # 80023580 <disk>
    80005b9a:	00451713          	slli	a4,a0,0x4
    80005b9e:	0a070713          	addi	a4,a4,160
    80005ba2:	973e                	add	a4,a4,a5
    80005ba4:	01603633          	snez	a2,s6
    80005ba8:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005baa:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005bae:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005bb2:	6398                	ld	a4,0(a5)
    80005bb4:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005bb6:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005bba:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005bbc:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005bbe:	6390                	ld	a2,0(a5)
    80005bc0:	00d60833          	add	a6,a2,a3
    80005bc4:	4741                	li	a4,16
    80005bc6:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005bca:	4585                	li	a1,1
    80005bcc:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005bd0:	fa442703          	lw	a4,-92(s0)
    80005bd4:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005bd8:	0712                	slli	a4,a4,0x4
    80005bda:	963a                	add	a2,a2,a4
    80005bdc:	05898813          	addi	a6,s3,88
    80005be0:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005be4:	0007b883          	ld	a7,0(a5)
    80005be8:	9746                	add	a4,a4,a7
    80005bea:	40000613          	li	a2,1024
    80005bee:	c710                	sw	a2,8(a4)
  if (write)
    80005bf0:	001b3613          	seqz	a2,s6
    80005bf4:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005bf8:	8e4d                	or	a2,a2,a1
    80005bfa:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005bfe:	fa842603          	lw	a2,-88(s0)
    80005c02:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005c06:	00451813          	slli	a6,a0,0x4
    80005c0a:	02080813          	addi	a6,a6,32
    80005c0e:	983e                	add	a6,a6,a5
    80005c10:	577d                	li	a4,-1
    80005c12:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005c16:	0612                	slli	a2,a2,0x4
    80005c18:	98b2                	add	a7,a7,a2
    80005c1a:	03068713          	addi	a4,a3,48
    80005c1e:	973e                	add	a4,a4,a5
    80005c20:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005c24:	6398                	ld	a4,0(a5)
    80005c26:	9732                	add	a4,a4,a2
    80005c28:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005c2a:	4689                	li	a3,2
    80005c2c:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005c30:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005c34:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005c38:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005c3c:	6794                	ld	a3,8(a5)
    80005c3e:	0026d703          	lhu	a4,2(a3)
    80005c42:	8b1d                	andi	a4,a4,7
    80005c44:	0706                	slli	a4,a4,0x1
    80005c46:	96ba                	add	a3,a3,a4
    80005c48:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005c4c:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005c50:	6798                	ld	a4,8(a5)
    80005c52:	00275783          	lhu	a5,2(a4)
    80005c56:	2785                	addiw	a5,a5,1
    80005c58:	00f71123          	sh	a5,2(a4)
    80005c5c:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005c60:	100017b7          	lui	a5,0x10001
    80005c64:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005c68:	0049a783          	lw	a5,4(s3)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005c6c:	0001e497          	auipc	s1,0x1e
    80005c70:	a3c48493          	addi	s1,s1,-1476 # 800236a8 <disk+0x128>
  while (b->disk == 1) {
    80005c74:	892e                	mv	s2,a1
    80005c76:	02b79163          	bne	a5,a1,80005c98 <virtio_disk_rw+0x1d2>
    sleep_prepare(b);
    80005c7a:	854e                	mv	a0,s3
    80005c7c:	b50fc0ef          	jal	80001fcc <sleep_prepare>
    release(&disk.vdisk_lock);
    80005c80:	8526                	mv	a0,s1
    80005c82:	82efb0ef          	jal	80000cb0 <release>
    sleep();
    80005c86:	b82fc0ef          	jal	80002008 <sleep>
    acquire(&disk.vdisk_lock);
    80005c8a:	8526                	mv	a0,s1
    80005c8c:	f9dfa0ef          	jal	80000c28 <acquire>
  while (b->disk == 1) {
    80005c90:	0049a783          	lw	a5,4(s3)
    80005c94:	ff2783e3          	beq	a5,s2,80005c7a <virtio_disk_rw+0x1b4>
  }

  disk.info[idx[0]].b = 0;
    80005c98:	fa042903          	lw	s2,-96(s0)
    80005c9c:	00491713          	slli	a4,s2,0x4
    80005ca0:	02070713          	addi	a4,a4,32
    80005ca4:	0001e797          	auipc	a5,0x1e
    80005ca8:	8dc78793          	addi	a5,a5,-1828 # 80023580 <disk>
    80005cac:	97ba                	add	a5,a5,a4
    80005cae:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005cb2:	0001e997          	auipc	s3,0x1e
    80005cb6:	8ce98993          	addi	s3,s3,-1842 # 80023580 <disk>
    80005cba:	00491713          	slli	a4,s2,0x4
    80005cbe:	0009b783          	ld	a5,0(s3)
    80005cc2:	97ba                	add	a5,a5,a4
    80005cc4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005cc8:	854a                	mv	a0,s2
    80005cca:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005cce:	bbbff0ef          	jal	80005888 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005cd2:	8885                	andi	s1,s1,1
    80005cd4:	f0fd                	bnez	s1,80005cba <virtio_disk_rw+0x1f4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005cd6:	0001e517          	auipc	a0,0x1e
    80005cda:	9d250513          	addi	a0,a0,-1582 # 800236a8 <disk+0x128>
    80005cde:	fd3fa0ef          	jal	80000cb0 <release>
}
    80005ce2:	60e6                	ld	ra,88(sp)
    80005ce4:	6446                	ld	s0,80(sp)
    80005ce6:	64a6                	ld	s1,72(sp)
    80005ce8:	6906                	ld	s2,64(sp)
    80005cea:	79e2                	ld	s3,56(sp)
    80005cec:	7a42                	ld	s4,48(sp)
    80005cee:	7aa2                	ld	s5,40(sp)
    80005cf0:	7b02                	ld	s6,32(sp)
    80005cf2:	6be2                	ld	s7,24(sp)
    80005cf4:	6c42                	ld	s8,16(sp)
    80005cf6:	6125                	addi	sp,sp,96
    80005cf8:	8082                	ret

0000000080005cfa <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005cfa:	1101                	addi	sp,sp,-32
    80005cfc:	ec06                	sd	ra,24(sp)
    80005cfe:	e822                	sd	s0,16(sp)
    80005d00:	e426                	sd	s1,8(sp)
    80005d02:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005d04:	0001e497          	auipc	s1,0x1e
    80005d08:	87c48493          	addi	s1,s1,-1924 # 80023580 <disk>
    80005d0c:	0001e517          	auipc	a0,0x1e
    80005d10:	99c50513          	addi	a0,a0,-1636 # 800236a8 <disk+0x128>
    80005d14:	f15fa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005d18:	100017b7          	lui	a5,0x10001
    80005d1c:	53bc                	lw	a5,96(a5)
    80005d1e:	8b8d                	andi	a5,a5,3
    80005d20:	10001737          	lui	a4,0x10001
    80005d24:	d37c                	sw	a5,100(a4)
    80005d26:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005d2a:	689c                	ld	a5,16(s1)
    80005d2c:	0204d703          	lhu	a4,32(s1)
    80005d30:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005d34:	04f70863          	beq	a4,a5,80005d84 <virtio_disk_intr+0x8a>
    80005d38:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005d3c:	6898                	ld	a4,16(s1)
    80005d3e:	0204d783          	lhu	a5,32(s1)
    80005d42:	8b9d                	andi	a5,a5,7
    80005d44:	078e                	slli	a5,a5,0x3
    80005d46:	97ba                	add	a5,a5,a4
    80005d48:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005d4a:	00479713          	slli	a4,a5,0x4
    80005d4e:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005d52:	9726                	add	a4,a4,s1
    80005d54:	01074703          	lbu	a4,16(a4)
    80005d58:	e329                	bnez	a4,80005d9a <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005d5a:	0792                	slli	a5,a5,0x4
    80005d5c:	02078793          	addi	a5,a5,32
    80005d60:	97a6                	add	a5,a5,s1
    80005d62:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005d64:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005d68:	ad0fc0ef          	jal	80002038 <wakeup>

    disk.used_idx += 1;
    80005d6c:	0204d783          	lhu	a5,32(s1)
    80005d70:	2785                	addiw	a5,a5,1
    80005d72:	17c2                	slli	a5,a5,0x30
    80005d74:	93c1                	srli	a5,a5,0x30
    80005d76:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005d7a:	6898                	ld	a4,16(s1)
    80005d7c:	00275703          	lhu	a4,2(a4)
    80005d80:	faf71ce3          	bne	a4,a5,80005d38 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005d84:	0001e517          	auipc	a0,0x1e
    80005d88:	92450513          	addi	a0,a0,-1756 # 800236a8 <disk+0x128>
    80005d8c:	f25fa0ef          	jal	80000cb0 <release>
}
    80005d90:	60e2                	ld	ra,24(sp)
    80005d92:	6442                	ld	s0,16(sp)
    80005d94:	64a2                	ld	s1,8(sp)
    80005d96:	6105                	addi	sp,sp,32
    80005d98:	8082                	ret
      panic("virtio_disk_intr status");
    80005d9a:	00002517          	auipc	a0,0x2
    80005d9e:	98650513          	addi	a0,a0,-1658 # 80007720 <etext+0x720>
    80005da2:	a93fa0ef          	jal	80000834 <panic>
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
