
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
    80000004:	49813103          	ld	sp,1176(sp) # 8000a498 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000066:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb017>
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
    8000011c:	382020ef          	jal	8000249e <either_copyin>
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
    80000198:	34c50513          	addi	a0,a0,844 # 800124e0 <cons>
    8000019c:	28d000ef          	jal	80000c28 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    800001a0:	00012497          	auipc	s1,0x12
    800001a4:	34048493          	addi	s1,s1,832 # 800124e0 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a8:	00012917          	auipc	s2,0x12
    800001ac:	3d090913          	addi	s2,s2,976 # 80012578 <cons+0x98>
  while (n > 0) {
    800001b0:	0d305263          	blez	s3,80000274 <consoleread+0xfc>
    while (cons.r == cons.w) {
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	0af71763          	bne	a4,a5,8000026a <consoleread+0xf2>
      if (killed(myproc())) {
    800001c0:	0f7010ef          	jal	80001ab6 <myproc>
    800001c4:	15a020ef          	jal	8000231e <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	6f5010ef          	jal	800020c0 <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	2df000ef          	jal	80000cb0 <release>
      sleep();
    800001d6:	727010ef          	jal	800020fc <sleep>
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
    800001f2:	2f270713          	addi	a4,a4,754 # 800124e0 <cons>
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
    80000220:	232020ef          	jal	80002452 <either_copyout>
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
    8000023c:	2a850513          	addi	a0,a0,680 # 800124e0 <cons>
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
    80000262:	30f72d23          	sw	a5,794(a4) # 80012578 <cons+0x98>
    80000266:	7aa2                	ld	s5,40(sp)
    80000268:	a031                	j	80000274 <consoleread+0xfc>
    8000026a:	f456                	sd	s5,40(sp)
    8000026c:	b749                	j	800001ee <consoleread+0x76>
    8000026e:	7aa2                	ld	s5,40(sp)
    80000270:	a011                	j	80000274 <consoleread+0xfc>
    80000272:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000274:	00012517          	auipc	a0,0x12
    80000278:	26c50513          	addi	a0,a0,620 # 800124e0 <cons>
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
    800002cc:	21850513          	addi	a0,a0,536 # 800124e0 <cons>
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
    800002ea:	200020ef          	jal	800024ea <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ee:	00012517          	auipc	a0,0x12
    800002f2:	1f250513          	addi	a0,a0,498 # 800124e0 <cons>
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
    80000310:	1d470713          	addi	a4,a4,468 # 800124e0 <cons>
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
    80000336:	1ae70713          	addi	a4,a4,430 # 800124e0 <cons>
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
    80000360:	21c72703          	lw	a4,540(a4) # 80012578 <cons+0x98>
    80000364:	9f99                	subw	a5,a5,a4
    80000366:	08000713          	li	a4,128
    8000036a:	f8e792e3          	bne	a5,a4,800002ee <consoleintr+0x32>
    8000036e:	a075                	j	8000041a <consoleintr+0x15e>
    80000370:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000372:	00012717          	auipc	a4,0x12
    80000376:	16e70713          	addi	a4,a4,366 # 800124e0 <cons>
    8000037a:	0a072783          	lw	a5,160(a4)
    8000037e:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000382:	00012497          	auipc	s1,0x12
    80000386:	15e48493          	addi	s1,s1,350 # 800124e0 <cons>
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
    800003c8:	11c70713          	addi	a4,a4,284 # 800124e0 <cons>
    800003cc:	0a072783          	lw	a5,160(a4)
    800003d0:	09c72703          	lw	a4,156(a4)
    800003d4:	f0f70de3          	beq	a4,a5,800002ee <consoleintr+0x32>
      cons.e--;
    800003d8:	37fd                	addiw	a5,a5,-1
    800003da:	00012717          	auipc	a4,0x12
    800003de:	1af72323          	sw	a5,422(a4) # 80012580 <cons+0xa0>
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
    800003fc:	0e878793          	addi	a5,a5,232 # 800124e0 <cons>
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
    8000041e:	16c7a123          	sw	a2,354(a5) # 8001257c <cons+0x9c>
        wakeup(&cons.r);
    80000422:	00012517          	auipc	a0,0x12
    80000426:	15650513          	addi	a0,a0,342 # 80012578 <cons+0x98>
    8000042a:	503010ef          	jal	8000212c <wakeup>
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
    80000444:	0a050513          	addi	a0,a0,160 # 800124e0 <cons>
    80000448:	760000ef          	jal	80000ba8 <initlock>

  uartinit();
    8000044c:	448000ef          	jal	80000894 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000450:	00022797          	auipc	a5,0x22
    80000454:	20078793          	addi	a5,a5,512 # 80022650 <devsw>
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
    80000492:	3fa80813          	addi	a6,a6,1018 # 80007888 <digits>
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
    8000052c:	f8c7a783          	lw	a5,-116(a5) # 8000a4b4 <panicking>
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
    80000572:	01a50513          	addi	a0,a0,26 # 80012588 <pr>
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
    800006e6:	1a6c8c93          	addi	s9,s9,422 # 80007888 <digits>
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
    8000076e:	d4a7a783          	lw	a5,-694(a5) # 8000a4b4 <panicking>
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
    80000798:	df450513          	addi	a0,a0,-524 # 80012588 <pr>
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
    80000848:	c697a823          	sw	s1,-912(a5) # 8000a4b4 <panicking>
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
    8000086a:	c497a523          	sw	s1,-950(a5) # 8000a4b0 <panicked>
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
    80000884:	d0850513          	addi	a0,a0,-760 # 80012588 <pr>
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
    800008da:	cca50513          	addi	a0,a0,-822 # 800125a0 <tx_lock>
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
    800008fe:	ca650513          	addi	a0,a0,-858 # 800125a0 <tx_lock>
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
    8000091c:	ba490913          	addi	s2,s2,-1116 # 8000a4bc <tx_busy>
      // wait for a UART interrupt to set tx_busy to 0.
      sleep_prepare(&tx_chan);
    80000920:	0000a997          	auipc	s3,0xa
    80000924:	b9898993          	addi	s3,s3,-1128 # 8000a4b8 <tx_chan>
      release(&tx_lock);
    80000928:	00012497          	auipc	s1,0x12
    8000092c:	c7848493          	addi	s1,s1,-904 # 800125a0 <tx_lock>
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
    8000093a:	786010ef          	jal	800020c0 <sleep_prepare>
      release(&tx_lock);
    8000093e:	8526                	mv	a0,s1
    80000940:	370000ef          	jal	80000cb0 <release>
      sleep();
    80000944:	7b8010ef          	jal	800020fc <sleep>
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
    8000097c:	c2850513          	addi	a0,a0,-984 # 800125a0 <tx_lock>
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
    800009a0:	b187a783          	lw	a5,-1256(a5) # 8000a4b4 <panicking>
    800009a4:	cf95                	beqz	a5,800009e0 <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    800009a6:	0000a797          	auipc	a5,0xa
    800009aa:	b0a7a783          	lw	a5,-1270(a5) # 8000a4b0 <panicked>
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
    800009d0:	ae87a783          	lw	a5,-1304(a5) # 8000a4b4 <panicking>
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
    80000a06:	b9e50513          	addi	a0,a0,-1122 # 800125a0 <tx_lock>
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
    80000a20:	b8450513          	addi	a0,a0,-1148 # 800125a0 <tx_lock>
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
    80000a48:	a607ac23          	sw	zero,-1416(a5) # 8000a4bc <tx_busy>
    wakeup(&tx_chan);
    80000a4c:	0000a517          	auipc	a0,0xa
    80000a50:	a6c50513          	addi	a0,a0,-1428 # 8000a4b8 <tx_chan>
    80000a54:	6d8010ef          	jal	8000212c <wakeup>
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
    80000a76:	d7678793          	addi	a5,a5,-650 # 800237e8 <end>
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
    80000aa0:	b1c90913          	addi	s2,s2,-1252 # 800125b8 <kmem>
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
    80000b2e:	a8e50513          	addi	a0,a0,-1394 # 800125b8 <kmem>
    80000b32:	076000ef          	jal	80000ba8 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000b36:	45c5                	li	a1,17
    80000b38:	05ee                	slli	a1,a1,0x1b
    80000b3a:	00023517          	auipc	a0,0x23
    80000b3e:	cae50513          	addi	a0,a0,-850 # 800237e8 <end>
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
    80000b5c:	a6050513          	addi	a0,a0,-1440 # 800125b8 <kmem>
    80000b60:	0c8000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b64:	00012497          	auipc	s1,0x12
    80000b68:	a6c4b483          	ld	s1,-1428(s1) # 800125d0 <kmem+0x18>
  if (r)
    80000b6c:	c49d                	beqz	s1,80000b9a <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b6e:	609c                	ld	a5,0(s1)
    80000b70:	00012717          	auipc	a4,0x12
    80000b74:	a6f73023          	sd	a5,-1440(a4) # 800125d0 <kmem+0x18>
  release(&kmem.lock);
    80000b78:	00012517          	auipc	a0,0x12
    80000b7c:	a4050513          	addi	a0,a0,-1472 # 800125b8 <kmem>
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
    80000b9e:	a1e50513          	addi	a0,a0,-1506 # 800125b8 <kmem>
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
    80000bd8:	6bf000ef          	jal	80001a96 <mycpu>
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
    80000bfe:	699000ef          	jal	80001a96 <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x2c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	691000ef          	jal	80001a96 <mycpu>
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
    80000c1a:	67d000ef          	jal	80001a96 <mycpu>
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
    80000c4c:	64b000ef          	jal	80001a96 <mycpu>
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
    80000c70:	627000ef          	jal	80001a96 <mycpu>
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
    80000ea6:	3dd000ef          	jal	80001a82 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();         // first user process

    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
  } else {
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000eaa:	00009717          	auipc	a4,0x9
    80000eae:	61670713          	addi	a4,a4,1558 # 8000a4c0 <started>
  if (cpuid() == 0) {
    80000eb2:	c51d                	beqz	a0,80000ee0 <main+0x42>
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000eb4:	431c                	lw	a5,0(a4)
    80000eb6:	0230000f          	fence	r,rw
    80000eba:	2781                	sext.w	a5,a5
    80000ebc:	dfe5                	beqz	a5,80000eb4 <main+0x16>
      ;

    printk("hart %d starting\n", cpuid());
    80000ebe:	3c5000ef          	jal	80001a82 <cpuid>
    80000ec2:	85aa                	mv	a1,a0
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	1d450513          	addi	a0,a0,468 # 80007098 <etext+0x98>
    80000ecc:	e3eff0ef          	jal	8000050a <printk>
    kvminithart();  // turn on paging
    80000ed0:	082000ef          	jal	80000f52 <kvminithart>
    trapinithart(); // install kernel trap vector
    80000ed4:	748010ef          	jal	8000261c <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ed8:	151040ef          	jal	80005828 <plicinithart>
  }

  scheduler();
    80000edc:	048010ef          	jal	80001f24 <scheduler>
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
    80000f18:	2b5000ef          	jal	800019cc <procinit>
    trapinit();         // trap vectors
    80000f1c:	6dc010ef          	jal	800025f8 <trapinit>
    trapinithart();     // install kernel trap vector
    80000f20:	6fc010ef          	jal	8000261c <trapinithart>
    plicinit();         // set up interrupt controller
    80000f24:	0eb040ef          	jal	8000580e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f28:	101040ef          	jal	80005828 <plicinithart>
    binit();            // buffer cache
    80000f2c:	5a3010ef          	jal	80002cce <binit>
    iinit();            // inode table
    80000f30:	2f4020ef          	jal	80003224 <iinit>
    fileinit();         // file table
    80000f34:	322030ef          	jal	80004256 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f38:	1e7040ef          	jal	8000591e <virtio_disk_init>
    userinit();         // first user process
    80000f3c:	63d000ef          	jal	80001d78 <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000f40:	00009797          	auipc	a5,0x9
    80000f44:	58078793          	addi	a5,a5,1408 # 8000a4c0 <started>
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
    80000f62:	56a7b783          	ld	a5,1386(a5) # 8000a4c8 <kernel_pagetable>
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
    800011ce:	75a000ef          	jal	80001928 <proc_mapstacks>
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
    800011ee:	2ca7bf23          	sd	a0,734(a5) # 8000a4c8 <kernel_pagetable>
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
    80001724:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb818>
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

00000000800017ba <vmprint>:
// vmprint walks the page table of the calling process,
// prints all valid user pages (VA, PA, P, W, U flags),
// and outputs the total count of valid user pages and page-table pages.
int
vmprint(void)
{
    800017ba:	7175                	addi	sp,sp,-144
    800017bc:	e506                	sd	ra,136(sp)
    800017be:	e122                	sd	s0,128(sp)
    800017c0:	fca6                	sd	s1,120(sp)
    800017c2:	f8ca                	sd	s2,112(sp)
    800017c4:	f4ce                	sd	s3,104(sp)
    800017c6:	f0d2                	sd	s4,96(sp)
    800017c8:	ecd6                	sd	s5,88(sp)
    800017ca:	e8da                	sd	s6,80(sp)
    800017cc:	e4de                	sd	s7,72(sp)
    800017ce:	e0e2                	sd	s8,64(sp)
    800017d0:	fc66                	sd	s9,56(sp)
    800017d2:	f86a                	sd	s10,48(sp)
    800017d4:	f46e                	sd	s11,40(sp)
    800017d6:	0900                	addi	s0,sp,144
  struct proc *p = myproc();
    800017d8:	2de000ef          	jal	80001ab6 <myproc>
  pagetable_t pagetable = p->pagetable;
    800017dc:	6924                	ld	s1,80(a0)
  int valid_pages = 0;
  int pt_pages = 1; // Level-2 (root) page table page

  printk("=== Page Table Dump for PID %d (%s) ===\n", p->pid, p->name);
    800017de:	15850613          	addi	a2,a0,344
    800017e2:	590c                	lw	a1,48(a0)
    800017e4:	00006517          	auipc	a0,0x6
    800017e8:	97450513          	addi	a0,a0,-1676 # 80007158 <etext+0x158>
    800017ec:	d1ffe0ef          	jal	8000050a <printk>
  printk("  Virtual Addr       Physical Addr      Flags [P, W, U]\n");
    800017f0:	00006517          	auipc	a0,0x6
    800017f4:	99850513          	addi	a0,a0,-1640 # 80007188 <etext+0x188>
    800017f8:	d13fe0ef          	jal	8000050a <printk>
  printk("  -----------------------------------------------------\n");
    800017fc:	00006517          	auipc	a0,0x6
    80001800:	9cc50513          	addi	a0,a0,-1588 # 800071c8 <etext+0x1c8>
    80001804:	d07fe0ef          	jal	8000050a <printk>

  for (int i = 0; i < 512; i++) {
    80001808:	f6943c23          	sd	s1,-136(s0)
  printk("  -----------------------------------------------------\n");
    8000180c:	f8043023          	sd	zero,-128(s0)
  int pt_pages = 1; // Level-2 (root) page table page
    80001810:	4785                	li	a5,1
    80001812:	f8f43423          	sd	a5,-120(s0)
  int valid_pages = 0;
    80001816:	4b81                	li	s7,0
    pte_t pte2 = pagetable[i];
    if ((pte2 & PTE_V) && (pte2 & (PTE_R | PTE_W | PTE_X)) == 0) {
    80001818:	8b3e                	mv	s6,a5
          pt_pages++;
          pagetable_t pt0 = (pagetable_t)PTE2PA(pte1);
          for (int k = 0; k < 512; k++) {
            pte_t pte0 = pt0[k];
            // Only user pages (PTE_V and PTE_U)
            if ((pte0 & PTE_V) && (pte0 & PTE_U)) {
    8000181a:	4a45                	li	s4,17
              uint64 va = ((uint64)i << 30) | ((uint64)j << 21) | ((uint64)k << 12);
              uint64 pa = PTE2PA(pte0);
              int p_bit = (pte0 & PTE_V) ? 1 : 0;
              int w_bit = (pte0 & PTE_W) ? 1 : 0;
              int u_bit = (pte0 & PTE_U) ? 1 : 0;
              printk("  0x%lx  ->  0x%lx    [P: %d, W: %d, U: %d]\n",
    8000181c:	00006d97          	auipc	s11,0x6
    80001820:	9ecd8d93          	addi	s11,s11,-1556 # 80007208 <etext+0x208>
          for (int k = 0; k < 512; k++) {
    80001824:	002009b7          	lui	s3,0x200
    80001828:	a059                	j	800018ae <vmprint+0xf4>
    8000182a:	04a1                	addi	s1,s1,8 # 1008 <_entry-0x7fffeff8>
    8000182c:	9956                	add	s2,s2,s5
    8000182e:	03390563          	beq	s2,s3,80001858 <vmprint+0x9e>
            pte_t pte0 = pt0[k];
    80001832:	6090                	ld	a2,0(s1)
            if ((pte0 & PTE_V) && (pte0 & PTE_U)) {
    80001834:	01167793          	andi	a5,a2,17
    80001838:	ff4799e3          	bne	a5,s4,8000182a <vmprint+0x70>
              int w_bit = (pte0 & PTE_W) ? 1 : 0;
    8000183c:	00265713          	srli	a4,a2,0x2
              uint64 pa = PTE2PA(pte0);
    80001840:	8229                	srli	a2,a2,0xa
              printk("  0x%lx  ->  0x%lx    [P: %d, W: %d, U: %d]\n",
    80001842:	87da                	mv	a5,s6
    80001844:	8b05                	andi	a4,a4,1
    80001846:	86da                	mv	a3,s6
    80001848:	0632                	slli	a2,a2,0xc
    8000184a:	012d65b3          	or	a1,s10,s2
    8000184e:	856e                	mv	a0,s11
    80001850:	cbbfe0ef          	jal	8000050a <printk>
                     va, pa, p_bit, w_bit, u_bit);
              valid_pages++;
    80001854:	2b85                	addiw	s7,s7,1 # fffffffffffff001 <end+0xffffffff7ffdb819>
    80001856:	bfd1                	j	8000182a <vmprint+0x70>
      for (int j = 0; j < 512; j++) {
    80001858:	0c21                	addi	s8,s8,8 # fffffffffffff008 <end+0xffffffff7ffdb820>
    8000185a:	9cce                	add	s9,s9,s3
    8000185c:	400007b7          	lui	a5,0x40000
    80001860:	02fc8663          	beq	s9,a5,8000188c <vmprint+0xd2>
        pte_t pte1 = pt1[j];
    80001864:	000c3783          	ld	a5,0(s8)
        if ((pte1 & PTE_V) && (pte1 & (PTE_R | PTE_W | PTE_X)) == 0) {
    80001868:	00f7f713          	andi	a4,a5,15
    8000186c:	ff6716e3          	bne	a4,s6,80001858 <vmprint+0x9e>
          pt_pages++;
    80001870:	f8843703          	ld	a4,-120(s0)
    80001874:	2705                	addiw	a4,a4,1
    80001876:	f8e43423          	sd	a4,-120(s0)
          pagetable_t pt0 = (pagetable_t)PTE2PA(pte1);
    8000187a:	83a9                	srli	a5,a5,0xa
    8000187c:	00c79493          	slli	s1,a5,0xc
    80001880:	4901                	li	s2,0
              uint64 va = ((uint64)i << 30) | ((uint64)j << 21) | ((uint64)k << 12);
    80001882:	f8043783          	ld	a5,-128(s0)
    80001886:	00fced33          	or	s10,s9,a5
    8000188a:	b765                	j	80001832 <vmprint+0x78>
  for (int i = 0; i < 512; i++) {
    8000188c:	f7843783          	ld	a5,-136(s0)
    80001890:	07a1                	addi	a5,a5,8 # 40000008 <_entry-0x3ffffff8>
    80001892:	f6f43c23          	sd	a5,-136(s0)
    80001896:	400007b7          	lui	a5,0x40000
    8000189a:	f8043703          	ld	a4,-128(s0)
    8000189e:	97ba                	add	a5,a5,a4
    800018a0:	873e                	mv	a4,a5
    800018a2:	f8f43023          	sd	a5,-128(s0)
    800018a6:	027b1793          	slli	a5,s6,0x27
    800018aa:	02f70463          	beq	a4,a5,800018d2 <vmprint+0x118>
    pte_t pte2 = pagetable[i];
    800018ae:	f7843783          	ld	a5,-136(s0)
    800018b2:	639c                	ld	a5,0(a5)
    if ((pte2 & PTE_V) && (pte2 & (PTE_R | PTE_W | PTE_X)) == 0) {
    800018b4:	00f7f713          	andi	a4,a5,15
    800018b8:	fd671ae3          	bne	a4,s6,8000188c <vmprint+0xd2>
      pt_pages++;
    800018bc:	f8843703          	ld	a4,-120(s0)
    800018c0:	2705                	addiw	a4,a4,1
    800018c2:	f8e43423          	sd	a4,-120(s0)
      pagetable_t pt1 = (pagetable_t)PTE2PA(pte2);
    800018c6:	83a9                	srli	a5,a5,0xa
    800018c8:	00c79c13          	slli	s8,a5,0xc
    800018cc:	4c81                	li	s9,0
          for (int k = 0; k < 512; k++) {
    800018ce:	6a85                	lui	s5,0x1
    800018d0:	bf51                	j	80001864 <vmprint+0xaa>
        }
      }
    }
  }

  printk("  -----------------------------------------------------\n");
    800018d2:	00006517          	auipc	a0,0x6
    800018d6:	8f650513          	addi	a0,a0,-1802 # 800071c8 <etext+0x1c8>
    800018da:	c31fe0ef          	jal	8000050a <printk>
  printk("  Total valid user pages : %d\n", valid_pages);
    800018de:	85de                	mv	a1,s7
    800018e0:	00006517          	auipc	a0,0x6
    800018e4:	95850513          	addi	a0,a0,-1704 # 80007238 <etext+0x238>
    800018e8:	c23fe0ef          	jal	8000050a <printk>
  printk("  Total page-table pages : %d\n", pt_pages);
    800018ec:	f8843583          	ld	a1,-120(s0)
    800018f0:	00006517          	auipc	a0,0x6
    800018f4:	96850513          	addi	a0,a0,-1688 # 80007258 <etext+0x258>
    800018f8:	c13fe0ef          	jal	8000050a <printk>
  printk("=====================================================\n");
    800018fc:	00006517          	auipc	a0,0x6
    80001900:	97c50513          	addi	a0,a0,-1668 # 80007278 <etext+0x278>
    80001904:	c07fe0ef          	jal	8000050a <printk>
  return valid_pages;
}
    80001908:	855e                	mv	a0,s7
    8000190a:	60aa                	ld	ra,136(sp)
    8000190c:	640a                	ld	s0,128(sp)
    8000190e:	74e6                	ld	s1,120(sp)
    80001910:	7946                	ld	s2,112(sp)
    80001912:	79a6                	ld	s3,104(sp)
    80001914:	7a06                	ld	s4,96(sp)
    80001916:	6ae6                	ld	s5,88(sp)
    80001918:	6b46                	ld	s6,80(sp)
    8000191a:	6ba6                	ld	s7,72(sp)
    8000191c:	6c06                	ld	s8,64(sp)
    8000191e:	7ce2                	ld	s9,56(sp)
    80001920:	7d42                	ld	s10,48(sp)
    80001922:	7da2                	ld	s11,40(sp)
    80001924:	6149                	addi	sp,sp,144
    80001926:	8082                	ret

0000000080001928 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001928:	715d                	addi	sp,sp,-80
    8000192a:	e486                	sd	ra,72(sp)
    8000192c:	e0a2                	sd	s0,64(sp)
    8000192e:	fc26                	sd	s1,56(sp)
    80001930:	f84a                	sd	s2,48(sp)
    80001932:	f44e                	sd	s3,40(sp)
    80001934:	f052                	sd	s4,32(sp)
    80001936:	ec56                	sd	s5,24(sp)
    80001938:	e85a                	sd	s6,16(sp)
    8000193a:	e45e                	sd	s7,8(sp)
    8000193c:	e062                	sd	s8,0(sp)
    8000193e:	0880                	addi	s0,sp,80
    80001940:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001942:	00011497          	auipc	s1,0x11
    80001946:	0c648493          	addi	s1,s1,198 # 80012a08 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    8000194a:	8c26                	mv	s8,s1
    8000194c:	000a57b7          	lui	a5,0xa5
    80001950:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001954:	07b2                	slli	a5,a5,0xc
    80001956:	fa578793          	addi	a5,a5,-91
    8000195a:	4fa50937          	lui	s2,0x4fa50
    8000195e:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001962:	1902                	slli	s2,s2,0x20
    80001964:	993e                	add	s2,s2,a5
    80001966:	040009b7          	lui	s3,0x4000
    8000196a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000196c:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000196e:	4b99                	li	s7,6
    80001970:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    80001972:	00017a97          	auipc	s5,0x17
    80001976:	a96a8a93          	addi	s5,s5,-1386 # 80018408 <tickslock>
    char *pa = kalloc();
    8000197a:	9d4ff0ef          	jal	80000b4e <kalloc>
    8000197e:	862a                	mv	a2,a0
    if (pa == 0)
    80001980:	c121                	beqz	a0,800019c0 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    80001982:	418485b3          	sub	a1,s1,s8
    80001986:	858d                	srai	a1,a1,0x3
    80001988:	032585b3          	mul	a1,a1,s2
    8000198c:	05b6                	slli	a1,a1,0xd
    8000198e:	6789                	lui	a5,0x2
    80001990:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001992:	875e                	mv	a4,s7
    80001994:	86da                	mv	a3,s6
    80001996:	40b985b3          	sub	a1,s3,a1
    8000199a:	8552                	mv	a0,s4
    8000199c:	f6cff0ef          	jal	80001108 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    800019a0:	16848493          	addi	s1,s1,360
    800019a4:	fd549be3          	bne	s1,s5,8000197a <proc_mapstacks+0x52>
  }
}
    800019a8:	60a6                	ld	ra,72(sp)
    800019aa:	6406                	ld	s0,64(sp)
    800019ac:	74e2                	ld	s1,56(sp)
    800019ae:	7942                	ld	s2,48(sp)
    800019b0:	79a2                	ld	s3,40(sp)
    800019b2:	7a02                	ld	s4,32(sp)
    800019b4:	6ae2                	ld	s5,24(sp)
    800019b6:	6b42                	ld	s6,16(sp)
    800019b8:	6ba2                	ld	s7,8(sp)
    800019ba:	6c02                	ld	s8,0(sp)
    800019bc:	6161                	addi	sp,sp,80
    800019be:	8082                	ret
      panic("kalloc");
    800019c0:	00006517          	auipc	a0,0x6
    800019c4:	8f050513          	addi	a0,a0,-1808 # 800072b0 <etext+0x2b0>
    800019c8:	e6dfe0ef          	jal	80000834 <panic>

00000000800019cc <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800019cc:	7139                	addi	sp,sp,-64
    800019ce:	fc06                	sd	ra,56(sp)
    800019d0:	f822                	sd	s0,48(sp)
    800019d2:	f426                	sd	s1,40(sp)
    800019d4:	f04a                	sd	s2,32(sp)
    800019d6:	ec4e                	sd	s3,24(sp)
    800019d8:	e852                	sd	s4,16(sp)
    800019da:	e456                	sd	s5,8(sp)
    800019dc:	e05a                	sd	s6,0(sp)
    800019de:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800019e0:	00006597          	auipc	a1,0x6
    800019e4:	8d858593          	addi	a1,a1,-1832 # 800072b8 <etext+0x2b8>
    800019e8:	00011517          	auipc	a0,0x11
    800019ec:	bf050513          	addi	a0,a0,-1040 # 800125d8 <pid_lock>
    800019f0:	9b8ff0ef          	jal	80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    800019f4:	00006597          	auipc	a1,0x6
    800019f8:	8cc58593          	addi	a1,a1,-1844 # 800072c0 <etext+0x2c0>
    800019fc:	00011517          	auipc	a0,0x11
    80001a00:	bf450513          	addi	a0,a0,-1036 # 800125f0 <wait_lock>
    80001a04:	9a4ff0ef          	jal	80000ba8 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001a08:	00011497          	auipc	s1,0x11
    80001a0c:	00048493          	mv	s1,s1
    initlock(&p->lock, "proc");
    80001a10:	00006b17          	auipc	s6,0x6
    80001a14:	8c0b0b13          	addi	s6,s6,-1856 # 800072d0 <etext+0x2d0>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001a18:	8aa6                	mv	s5,s1
    80001a1a:	000a57b7          	lui	a5,0xa5
    80001a1e:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001a22:	07b2                	slli	a5,a5,0xc
    80001a24:	fa578793          	addi	a5,a5,-91
    80001a28:	4fa50937          	lui	s2,0x4fa50
    80001a2c:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001a30:	1902                	slli	s2,s2,0x20
    80001a32:	993e                	add	s2,s2,a5
    80001a34:	040009b7          	lui	s3,0x4000
    80001a38:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001a3a:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001a3c:	00017a17          	auipc	s4,0x17
    80001a40:	9cca0a13          	addi	s4,s4,-1588 # 80018408 <tickslock>
    initlock(&p->lock, "proc");
    80001a44:	85da                	mv	a1,s6
    80001a46:	8526                	mv	a0,s1
    80001a48:	960ff0ef          	jal	80000ba8 <initlock>
    p->state = UNUSED;
    80001a4c:	0004ac23          	sw	zero,24(s1) # 80012a20 <proc+0x18>
    p->kstack = KSTACK((int)(p - proc));
    80001a50:	415487b3          	sub	a5,s1,s5
    80001a54:	878d                	srai	a5,a5,0x3
    80001a56:	032787b3          	mul	a5,a5,s2
    80001a5a:	07b6                	slli	a5,a5,0xd
    80001a5c:	6709                	lui	a4,0x2
    80001a5e:	9fb9                	addw	a5,a5,a4
    80001a60:	40f987b3          	sub	a5,s3,a5
    80001a64:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    80001a66:	16848493          	addi	s1,s1,360
    80001a6a:	fd449de3          	bne	s1,s4,80001a44 <procinit+0x78>
  }
}
    80001a6e:	70e2                	ld	ra,56(sp)
    80001a70:	7442                	ld	s0,48(sp)
    80001a72:	74a2                	ld	s1,40(sp)
    80001a74:	7902                	ld	s2,32(sp)
    80001a76:	69e2                	ld	s3,24(sp)
    80001a78:	6a42                	ld	s4,16(sp)
    80001a7a:	6aa2                	ld	s5,8(sp)
    80001a7c:	6b02                	ld	s6,0(sp)
    80001a7e:	6121                	addi	sp,sp,64
    80001a80:	8082                	ret

0000000080001a82 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001a82:	1141                	addi	sp,sp,-16
    80001a84:	e406                	sd	ra,8(sp)
    80001a86:	e022                	sd	s0,0(sp)
    80001a88:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    80001a8a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a8c:	2501                	sext.w	a0,a0
    80001a8e:	60a2                	ld	ra,8(sp)
    80001a90:	6402                	ld	s0,0(sp)
    80001a92:	0141                	addi	sp,sp,16
    80001a94:	8082                	ret

0000000080001a96 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001a96:	1141                	addi	sp,sp,-16
    80001a98:	e406                	sd	ra,8(sp)
    80001a9a:	e022                	sd	s0,0(sp)
    80001a9c:	0800                	addi	s0,sp,16
    80001a9e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001aa0:	2781                	sext.w	a5,a5
    80001aa2:	079e                	slli	a5,a5,0x7
  return c;
}
    80001aa4:	00011517          	auipc	a0,0x11
    80001aa8:	b6450513          	addi	a0,a0,-1180 # 80012608 <cpus>
    80001aac:	953e                	add	a0,a0,a5
    80001aae:	60a2                	ld	ra,8(sp)
    80001ab0:	6402                	ld	s0,0(sp)
    80001ab2:	0141                	addi	sp,sp,16
    80001ab4:	8082                	ret

0000000080001ab6 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001ab6:	1101                	addi	sp,sp,-32
    80001ab8:	ec06                	sd	ra,24(sp)
    80001aba:	e822                	sd	s0,16(sp)
    80001abc:	e426                	sd	s1,8(sp)
    80001abe:	1000                	addi	s0,sp,32
  push_off();
    80001ac0:	92eff0ef          	jal	80000bee <push_off>
    80001ac4:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001ac6:	2781                	sext.w	a5,a5
    80001ac8:	079e                	slli	a5,a5,0x7
    80001aca:	00011717          	auipc	a4,0x11
    80001ace:	b0e70713          	addi	a4,a4,-1266 # 800125d8 <pid_lock>
    80001ad2:	97ba                	add	a5,a5,a4
    80001ad4:	7b9c                	ld	a5,48(a5)
    80001ad6:	84be                	mv	s1,a5
  pop_off();
    80001ad8:	990ff0ef          	jal	80000c68 <pop_off>
  return p;
}
    80001adc:	8526                	mv	a0,s1
    80001ade:	60e2                	ld	ra,24(sp)
    80001ae0:	6442                	ld	s0,16(sp)
    80001ae2:	64a2                	ld	s1,8(sp)
    80001ae4:	6105                	addi	sp,sp,32
    80001ae6:	8082                	ret

0000000080001ae8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001ae8:	7179                	addi	sp,sp,-48
    80001aea:	f406                	sd	ra,40(sp)
    80001aec:	f022                	sd	s0,32(sp)
    80001aee:	ec26                	sd	s1,24(sp)
    80001af0:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001af2:	fc5ff0ef          	jal	80001ab6 <myproc>
    80001af6:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001af8:	9b8ff0ef          	jal	80000cb0 <release>

  if (first) {
    80001afc:	00009797          	auipc	a5,0x9
    80001b00:	9847a783          	lw	a5,-1660(a5) # 8000a480 <first.1>
    80001b04:	cf85                	beqz	a5,80001b3c <forkret+0x54>
    first = 0;
    80001b06:	00009797          	auipc	a5,0x9
    80001b0a:	9607ad23          	sw	zero,-1670(a5) # 8000a480 <first.1>

    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001b0e:	4505                	li	a0,1
    80001b10:	419010ef          	jal	80003728 <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001b14:	00005797          	auipc	a5,0x5
    80001b18:	7c478793          	addi	a5,a5,1988 # 800072d8 <etext+0x2d8>
    80001b1c:	fcf43823          	sd	a5,-48(s0)
    80001b20:	fc043c23          	sd	zero,-40(s0)
    80001b24:	fd040593          	addi	a1,s0,-48
    80001b28:	853e                	mv	a0,a5
    80001b2a:	6b3020ef          	jal	800049dc <kexec>
    80001b2e:	6cbc                	ld	a5,88(s1)
    80001b30:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001b32:	6cbc                	ld	a5,88(s1)
    80001b34:	7bb8                	ld	a4,112(a5)
    80001b36:	57fd                	li	a5,-1
    80001b38:	02f70d63          	beq	a4,a5,80001b72 <forkret+0x8a>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001b3c:	2fd000ef          	jal	80002638 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001b40:	68a8                	ld	a0,80(s1)
    80001b42:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001b44:	04000737          	lui	a4,0x4000
    80001b48:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001b4a:	0732                	slli	a4,a4,0xc
    80001b4c:	00004797          	auipc	a5,0x4
    80001b50:	55078793          	addi	a5,a5,1360 # 8000609c <userret>
    80001b54:	00004697          	auipc	a3,0x4
    80001b58:	4ac68693          	addi	a3,a3,1196 # 80006000 <_trampoline>
    80001b5c:	8f95                	sub	a5,a5,a3
    80001b5e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001b60:	577d                	li	a4,-1
    80001b62:	177e                	slli	a4,a4,0x3f
    80001b64:	8d59                	or	a0,a0,a4
    80001b66:	9782                	jalr	a5
}
    80001b68:	70a2                	ld	ra,40(sp)
    80001b6a:	7402                	ld	s0,32(sp)
    80001b6c:	64e2                	ld	s1,24(sp)
    80001b6e:	6145                	addi	sp,sp,48
    80001b70:	8082                	ret
      panic("exec");
    80001b72:	00005517          	auipc	a0,0x5
    80001b76:	76e50513          	addi	a0,a0,1902 # 800072e0 <etext+0x2e0>
    80001b7a:	cbbfe0ef          	jal	80000834 <panic>

0000000080001b7e <allocpid>:
{
    80001b7e:	1101                	addi	sp,sp,-32
    80001b80:	ec06                	sd	ra,24(sp)
    80001b82:	e822                	sd	s0,16(sp)
    80001b84:	e426                	sd	s1,8(sp)
    80001b86:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b88:	00011517          	auipc	a0,0x11
    80001b8c:	a5050513          	addi	a0,a0,-1456 # 800125d8 <pid_lock>
    80001b90:	898ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001b94:	00009797          	auipc	a5,0x9
    80001b98:	8f078793          	addi	a5,a5,-1808 # 8000a484 <nextpid>
    80001b9c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b9e:	0014871b          	addiw	a4,s1,1
    80001ba2:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ba4:	00011517          	auipc	a0,0x11
    80001ba8:	a3450513          	addi	a0,a0,-1484 # 800125d8 <pid_lock>
    80001bac:	904ff0ef          	jal	80000cb0 <release>
}
    80001bb0:	8526                	mv	a0,s1
    80001bb2:	60e2                	ld	ra,24(sp)
    80001bb4:	6442                	ld	s0,16(sp)
    80001bb6:	64a2                	ld	s1,8(sp)
    80001bb8:	6105                	addi	sp,sp,32
    80001bba:	8082                	ret

0000000080001bbc <proc_pagetable>:
{
    80001bbc:	1101                	addi	sp,sp,-32
    80001bbe:	ec06                	sd	ra,24(sp)
    80001bc0:	e822                	sd	s0,16(sp)
    80001bc2:	e426                	sd	s1,8(sp)
    80001bc4:	e04a                	sd	s2,0(sp)
    80001bc6:	1000                	addi	s0,sp,32
    80001bc8:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001bca:	e30ff0ef          	jal	800011fa <uvmcreate>
    80001bce:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001bd0:	cd05                	beqz	a0,80001c08 <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001bd2:	4729                	li	a4,10
    80001bd4:	00004697          	auipc	a3,0x4
    80001bd8:	42c68693          	addi	a3,a3,1068 # 80006000 <_trampoline>
    80001bdc:	6605                	lui	a2,0x1
    80001bde:	040005b7          	lui	a1,0x4000
    80001be2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001be4:	05b2                	slli	a1,a1,0xc
    80001be6:	c6cff0ef          	jal	80001052 <mappages>
    80001bea:	02054663          	bltz	a0,80001c16 <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001bee:	4719                	li	a4,6
    80001bf0:	05893683          	ld	a3,88(s2)
    80001bf4:	6605                	lui	a2,0x1
    80001bf6:	020005b7          	lui	a1,0x2000
    80001bfa:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bfc:	05b6                	slli	a1,a1,0xd
    80001bfe:	8526                	mv	a0,s1
    80001c00:	c52ff0ef          	jal	80001052 <mappages>
    80001c04:	00054f63          	bltz	a0,80001c22 <proc_pagetable+0x66>
}
    80001c08:	8526                	mv	a0,s1
    80001c0a:	60e2                	ld	ra,24(sp)
    80001c0c:	6442                	ld	s0,16(sp)
    80001c0e:	64a2                	ld	s1,8(sp)
    80001c10:	6902                	ld	s2,0(sp)
    80001c12:	6105                	addi	sp,sp,32
    80001c14:	8082                	ret
    uvmfree(pagetable, 0);
    80001c16:	4581                	li	a1,0
    80001c18:	8526                	mv	a0,s1
    80001c1a:	fdaff0ef          	jal	800013f4 <uvmfree>
    return 0;
    80001c1e:	4481                	li	s1,0
    80001c20:	b7e5                	j	80001c08 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c22:	4681                	li	a3,0
    80001c24:	4605                	li	a2,1
    80001c26:	040005b7          	lui	a1,0x4000
    80001c2a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c2c:	05b2                	slli	a1,a1,0xc
    80001c2e:	8526                	mv	a0,s1
    80001c30:	df0ff0ef          	jal	80001220 <uvmunmap>
    uvmfree(pagetable, 0);
    80001c34:	4581                	li	a1,0
    80001c36:	8526                	mv	a0,s1
    80001c38:	fbcff0ef          	jal	800013f4 <uvmfree>
    return 0;
    80001c3c:	4481                	li	s1,0
    80001c3e:	b7e9                	j	80001c08 <proc_pagetable+0x4c>

0000000080001c40 <proc_freepagetable>:
{
    80001c40:	1101                	addi	sp,sp,-32
    80001c42:	ec06                	sd	ra,24(sp)
    80001c44:	e822                	sd	s0,16(sp)
    80001c46:	e426                	sd	s1,8(sp)
    80001c48:	e04a                	sd	s2,0(sp)
    80001c4a:	1000                	addi	s0,sp,32
    80001c4c:	84aa                	mv	s1,a0
    80001c4e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c50:	4681                	li	a3,0
    80001c52:	4605                	li	a2,1
    80001c54:	040005b7          	lui	a1,0x4000
    80001c58:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c5a:	05b2                	slli	a1,a1,0xc
    80001c5c:	dc4ff0ef          	jal	80001220 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c60:	4681                	li	a3,0
    80001c62:	4605                	li	a2,1
    80001c64:	020005b7          	lui	a1,0x2000
    80001c68:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c6a:	05b6                	slli	a1,a1,0xd
    80001c6c:	8526                	mv	a0,s1
    80001c6e:	db2ff0ef          	jal	80001220 <uvmunmap>
  uvmfree(pagetable, sz);
    80001c72:	85ca                	mv	a1,s2
    80001c74:	8526                	mv	a0,s1
    80001c76:	f7eff0ef          	jal	800013f4 <uvmfree>
}
    80001c7a:	60e2                	ld	ra,24(sp)
    80001c7c:	6442                	ld	s0,16(sp)
    80001c7e:	64a2                	ld	s1,8(sp)
    80001c80:	6902                	ld	s2,0(sp)
    80001c82:	6105                	addi	sp,sp,32
    80001c84:	8082                	ret

0000000080001c86 <freeproc>:
{
    80001c86:	1101                	addi	sp,sp,-32
    80001c88:	ec06                	sd	ra,24(sp)
    80001c8a:	e822                	sd	s0,16(sp)
    80001c8c:	e426                	sd	s1,8(sp)
    80001c8e:	1000                	addi	s0,sp,32
    80001c90:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001c92:	6d28                	ld	a0,88(a0)
    80001c94:	c119                	beqz	a0,80001c9a <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001c96:	dd1fe0ef          	jal	80000a66 <kfree>
  p->trapframe = 0;
    80001c9a:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001c9e:	68a8                	ld	a0,80(s1)
    80001ca0:	c501                	beqz	a0,80001ca8 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001ca2:	64ac                	ld	a1,72(s1)
    80001ca4:	f9dff0ef          	jal	80001c40 <proc_freepagetable>
  p->pagetable = 0;
    80001ca8:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001cac:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001cb0:	0204a823          	sw	zero,48(s1)
  p->name[0] = 0;
    80001cb4:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001cb8:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001cbc:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001cc0:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001cc4:	0004ac23          	sw	zero,24(s1)
}
    80001cc8:	60e2                	ld	ra,24(sp)
    80001cca:	6442                	ld	s0,16(sp)
    80001ccc:	64a2                	ld	s1,8(sp)
    80001cce:	6105                	addi	sp,sp,32
    80001cd0:	8082                	ret

0000000080001cd2 <allocproc>:
{
    80001cd2:	1101                	addi	sp,sp,-32
    80001cd4:	ec06                	sd	ra,24(sp)
    80001cd6:	e822                	sd	s0,16(sp)
    80001cd8:	e426                	sd	s1,8(sp)
    80001cda:	e04a                	sd	s2,0(sp)
    80001cdc:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001cde:	00011497          	auipc	s1,0x11
    80001ce2:	d2a48493          	addi	s1,s1,-726 # 80012a08 <proc>
    80001ce6:	00016917          	auipc	s2,0x16
    80001cea:	72290913          	addi	s2,s2,1826 # 80018408 <tickslock>
    acquire(&p->lock);
    80001cee:	8526                	mv	a0,s1
    80001cf0:	f39fe0ef          	jal	80000c28 <acquire>
    if (p->state == UNUSED) {
    80001cf4:	4c9c                	lw	a5,24(s1)
    80001cf6:	cb91                	beqz	a5,80001d0a <allocproc+0x38>
      release(&p->lock);
    80001cf8:	8526                	mv	a0,s1
    80001cfa:	fb7fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001cfe:	16848493          	addi	s1,s1,360
    80001d02:	ff2496e3          	bne	s1,s2,80001cee <allocproc+0x1c>
  return 0;
    80001d06:	4481                	li	s1,0
    80001d08:	a089                	j	80001d4a <allocproc+0x78>
  p->pid = allocpid();
    80001d0a:	e75ff0ef          	jal	80001b7e <allocpid>
    80001d0e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001d10:	4785                	li	a5,1
    80001d12:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001d14:	e3bfe0ef          	jal	80000b4e <kalloc>
    80001d18:	892a                	mv	s2,a0
    80001d1a:	eca8                	sd	a0,88(s1)
    80001d1c:	cd15                	beqz	a0,80001d58 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001d1e:	8526                	mv	a0,s1
    80001d20:	e9dff0ef          	jal	80001bbc <proc_pagetable>
    80001d24:	892a                	mv	s2,a0
    80001d26:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001d28:	c121                	beqz	a0,80001d68 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001d2a:	07000613          	li	a2,112
    80001d2e:	4581                	li	a1,0
    80001d30:	06048513          	addi	a0,s1,96
    80001d34:	fb5fe0ef          	jal	80000ce8 <memset>
  p->context.ra = (uint64)forkret;
    80001d38:	00000797          	auipc	a5,0x0
    80001d3c:	db078793          	addi	a5,a5,-592 # 80001ae8 <forkret>
    80001d40:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d42:	60bc                	ld	a5,64(s1)
    80001d44:	6705                	lui	a4,0x1
    80001d46:	97ba                	add	a5,a5,a4
    80001d48:	f4bc                	sd	a5,104(s1)
}
    80001d4a:	8526                	mv	a0,s1
    80001d4c:	60e2                	ld	ra,24(sp)
    80001d4e:	6442                	ld	s0,16(sp)
    80001d50:	64a2                	ld	s1,8(sp)
    80001d52:	6902                	ld	s2,0(sp)
    80001d54:	6105                	addi	sp,sp,32
    80001d56:	8082                	ret
    freeproc(p);
    80001d58:	8526                	mv	a0,s1
    80001d5a:	f2dff0ef          	jal	80001c86 <freeproc>
    release(&p->lock);
    80001d5e:	8526                	mv	a0,s1
    80001d60:	f51fe0ef          	jal	80000cb0 <release>
    return 0;
    80001d64:	84ca                	mv	s1,s2
    80001d66:	b7d5                	j	80001d4a <allocproc+0x78>
    freeproc(p);
    80001d68:	8526                	mv	a0,s1
    80001d6a:	f1dff0ef          	jal	80001c86 <freeproc>
    release(&p->lock);
    80001d6e:	8526                	mv	a0,s1
    80001d70:	f41fe0ef          	jal	80000cb0 <release>
    return 0;
    80001d74:	84ca                	mv	s1,s2
    80001d76:	bfd1                	j	80001d4a <allocproc+0x78>

0000000080001d78 <userinit>:
{
    80001d78:	1101                	addi	sp,sp,-32
    80001d7a:	ec06                	sd	ra,24(sp)
    80001d7c:	e822                	sd	s0,16(sp)
    80001d7e:	e426                	sd	s1,8(sp)
    80001d80:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d82:	f51ff0ef          	jal	80001cd2 <allocproc>
    80001d86:	84aa                	mv	s1,a0
  initproc = p;
    80001d88:	00008797          	auipc	a5,0x8
    80001d8c:	74a7b423          	sd	a0,1864(a5) # 8000a4d0 <initproc>
  p->cwd = namei("/");
    80001d90:	00005517          	auipc	a0,0x5
    80001d94:	55850513          	addi	a0,a0,1368 # 800072e8 <etext+0x2e8>
    80001d98:	6ef010ef          	jal	80003c86 <namei>
    80001d9c:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001da0:	478d                	li	a5,3
    80001da2:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001da4:	8526                	mv	a0,s1
    80001da6:	f0bfe0ef          	jal	80000cb0 <release>
}
    80001daa:	60e2                	ld	ra,24(sp)
    80001dac:	6442                	ld	s0,16(sp)
    80001dae:	64a2                	ld	s1,8(sp)
    80001db0:	6105                	addi	sp,sp,32
    80001db2:	8082                	ret

0000000080001db4 <growproc>:
{
    80001db4:	1101                	addi	sp,sp,-32
    80001db6:	ec06                	sd	ra,24(sp)
    80001db8:	e822                	sd	s0,16(sp)
    80001dba:	e426                	sd	s1,8(sp)
    80001dbc:	e04a                	sd	s2,0(sp)
    80001dbe:	1000                	addi	s0,sp,32
    80001dc0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001dc2:	cf5ff0ef          	jal	80001ab6 <myproc>
    80001dc6:	892a                	mv	s2,a0
  sz = p->sz;
    80001dc8:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001dca:	02905963          	blez	s1,80001dfc <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001dce:	00b48633          	add	a2,s1,a1
    80001dd2:	020007b7          	lui	a5,0x2000
    80001dd6:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001dd8:	07b6                	slli	a5,a5,0xd
    80001dda:	02c7ea63          	bltu	a5,a2,80001e0e <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001dde:	4691                	li	a3,4
    80001de0:	6928                	ld	a0,80(a0)
    80001de2:	d0cff0ef          	jal	800012ee <uvmalloc>
    80001de6:	85aa                	mv	a1,a0
    80001de8:	c50d                	beqz	a0,80001e12 <growproc+0x5e>
  p->sz = sz;
    80001dea:	04b93423          	sd	a1,72(s2)
  return 0;
    80001dee:	4501                	li	a0,0
}
    80001df0:	60e2                	ld	ra,24(sp)
    80001df2:	6442                	ld	s0,16(sp)
    80001df4:	64a2                	ld	s1,8(sp)
    80001df6:	6902                	ld	s2,0(sp)
    80001df8:	6105                	addi	sp,sp,32
    80001dfa:	8082                	ret
  } else if (n < 0) {
    80001dfc:	fe04d7e3          	bgez	s1,80001dea <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e00:	00b48633          	add	a2,s1,a1
    80001e04:	6928                	ld	a0,80(a0)
    80001e06:	ca4ff0ef          	jal	800012aa <uvmdealloc>
    80001e0a:	85aa                	mv	a1,a0
    80001e0c:	bff9                	j	80001dea <growproc+0x36>
      return -1;
    80001e0e:	557d                	li	a0,-1
    80001e10:	b7c5                	j	80001df0 <growproc+0x3c>
      return -1;
    80001e12:	557d                	li	a0,-1
    80001e14:	bff1                	j	80001df0 <growproc+0x3c>

0000000080001e16 <kfork>:
{
    80001e16:	7139                	addi	sp,sp,-64
    80001e18:	fc06                	sd	ra,56(sp)
    80001e1a:	f822                	sd	s0,48(sp)
    80001e1c:	f426                	sd	s1,40(sp)
    80001e1e:	e456                	sd	s5,8(sp)
    80001e20:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e22:	c95ff0ef          	jal	80001ab6 <myproc>
    80001e26:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001e28:	eabff0ef          	jal	80001cd2 <allocproc>
    80001e2c:	0e050a63          	beqz	a0,80001f20 <kfork+0x10a>
    80001e30:	e852                	sd	s4,16(sp)
    80001e32:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001e34:	048ab603          	ld	a2,72(s5)
    80001e38:	692c                	ld	a1,80(a0)
    80001e3a:	050ab503          	ld	a0,80(s5)
    80001e3e:	de8ff0ef          	jal	80001426 <uvmcopy>
    80001e42:	04054863          	bltz	a0,80001e92 <kfork+0x7c>
    80001e46:	f04a                	sd	s2,32(sp)
    80001e48:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001e4a:	048ab783          	ld	a5,72(s5)
    80001e4e:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e52:	058ab683          	ld	a3,88(s5)
    80001e56:	87b6                	mv	a5,a3
    80001e58:	058a3703          	ld	a4,88(s4)
    80001e5c:	12068693          	addi	a3,a3,288
    80001e60:	6388                	ld	a0,0(a5)
    80001e62:	678c                	ld	a1,8(a5)
    80001e64:	6b90                	ld	a2,16(a5)
    80001e66:	e308                	sd	a0,0(a4)
    80001e68:	e70c                	sd	a1,8(a4)
    80001e6a:	eb10                	sd	a2,16(a4)
    80001e6c:	6f90                	ld	a2,24(a5)
    80001e6e:	ef10                	sd	a2,24(a4)
    80001e70:	02078793          	addi	a5,a5,32
    80001e74:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001e78:	fed794e3          	bne	a5,a3,80001e60 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001e7c:	058a3783          	ld	a5,88(s4)
    80001e80:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001e84:	0d0a8493          	addi	s1,s5,208
    80001e88:	0d0a0913          	addi	s2,s4,208
    80001e8c:	150a8993          	addi	s3,s5,336
    80001e90:	a831                	j	80001eac <kfork+0x96>
    freeproc(np);
    80001e92:	8552                	mv	a0,s4
    80001e94:	df3ff0ef          	jal	80001c86 <freeproc>
    release(&np->lock);
    80001e98:	8552                	mv	a0,s4
    80001e9a:	e17fe0ef          	jal	80000cb0 <release>
    return -1;
    80001e9e:	54fd                	li	s1,-1
    80001ea0:	6a42                	ld	s4,16(sp)
    80001ea2:	a885                	j	80001f12 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001ea4:	04a1                	addi	s1,s1,8
    80001ea6:	0921                	addi	s2,s2,8
    80001ea8:	01348963          	beq	s1,s3,80001eba <kfork+0xa4>
    if (p->ofile[i])
    80001eac:	6088                	ld	a0,0(s1)
    80001eae:	d97d                	beqz	a0,80001ea4 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eb0:	428020ef          	jal	800042d8 <filedup>
    80001eb4:	00a93023          	sd	a0,0(s2)
    80001eb8:	b7f5                	j	80001ea4 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001eba:	150ab503          	ld	a0,336(s5)
    80001ebe:	4f8010ef          	jal	800033b6 <idup>
    80001ec2:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ec6:	4641                	li	a2,16
    80001ec8:	158a8593          	addi	a1,s5,344
    80001ecc:	158a0513          	addi	a0,s4,344
    80001ed0:	f6dfe0ef          	jal	80000e3c <safestrcpy>
  pid = np->pid;
    80001ed4:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001ed8:	8552                	mv	a0,s4
    80001eda:	dd7fe0ef          	jal	80000cb0 <release>
  acquire(&wait_lock);
    80001ede:	00010517          	auipc	a0,0x10
    80001ee2:	71250513          	addi	a0,a0,1810 # 800125f0 <wait_lock>
    80001ee6:	d43fe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001eea:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001eee:	00010517          	auipc	a0,0x10
    80001ef2:	70250513          	addi	a0,a0,1794 # 800125f0 <wait_lock>
    80001ef6:	dbbfe0ef          	jal	80000cb0 <release>
  acquire(&np->lock);
    80001efa:	8552                	mv	a0,s4
    80001efc:	d2dfe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001f00:	478d                	li	a5,3
    80001f02:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f06:	8552                	mv	a0,s4
    80001f08:	da9fe0ef          	jal	80000cb0 <release>
  return pid;
    80001f0c:	7902                	ld	s2,32(sp)
    80001f0e:	69e2                	ld	s3,24(sp)
    80001f10:	6a42                	ld	s4,16(sp)
}
    80001f12:	8526                	mv	a0,s1
    80001f14:	70e2                	ld	ra,56(sp)
    80001f16:	7442                	ld	s0,48(sp)
    80001f18:	74a2                	ld	s1,40(sp)
    80001f1a:	6aa2                	ld	s5,8(sp)
    80001f1c:	6121                	addi	sp,sp,64
    80001f1e:	8082                	ret
    return -1;
    80001f20:	54fd                	li	s1,-1
    80001f22:	bfc5                	j	80001f12 <kfork+0xfc>

0000000080001f24 <scheduler>:
{
    80001f24:	711d                	addi	sp,sp,-96
    80001f26:	ec86                	sd	ra,88(sp)
    80001f28:	e8a2                	sd	s0,80(sp)
    80001f2a:	e4a6                	sd	s1,72(sp)
    80001f2c:	e0ca                	sd	s2,64(sp)
    80001f2e:	fc4e                	sd	s3,56(sp)
    80001f30:	f852                	sd	s4,48(sp)
    80001f32:	f456                	sd	s5,40(sp)
    80001f34:	f05a                	sd	s6,32(sp)
    80001f36:	ec5e                	sd	s7,24(sp)
    80001f38:	e862                	sd	s8,16(sp)
    80001f3a:	e466                	sd	s9,8(sp)
    80001f3c:	1080                	addi	s0,sp,96
    80001f3e:	8792                	mv	a5,tp
  int id = r_tp();
    80001f40:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f42:	00779a93          	slli	s5,a5,0x7
    80001f46:	00010717          	auipc	a4,0x10
    80001f4a:	69270713          	addi	a4,a4,1682 # 800125d8 <pid_lock>
    80001f4e:	9756                	add	a4,a4,s5
    80001f50:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f54:	00010717          	auipc	a4,0x10
    80001f58:	6bc70713          	addi	a4,a4,1724 # 80012610 <cpus+0x8>
    80001f5c:	9aba                	add	s5,s5,a4
        p->state = RUNNING;
    80001f5e:	4c11                	li	s8,4
        c->proc = p;
    80001f60:	00010b17          	auipc	s6,0x10
    80001f64:	678b0b13          	addi	s6,s6,1656 # 800125d8 <pid_lock>
    80001f68:	079e                	slli	a5,a5,0x7
    80001f6a:	00fb0a33          	add	s4,s6,a5
        found = 1;
    80001f6e:	4b85                	li	s7,1
    80001f70:	a0a9                	j	80001fba <scheduler+0x96>
      release(&p->lock);
    80001f72:	8526                	mv	a0,s1
    80001f74:	d3dfe0ef          	jal	80000cb0 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f78:	16848493          	addi	s1,s1,360
    80001f7c:	03248b63          	beq	s1,s2,80001fb2 <scheduler+0x8e>
      acquire(&p->lock);
    80001f80:	8526                	mv	a0,s1
    80001f82:	ca7fe0ef          	jal	80000c28 <acquire>
      if (p->state == RUNNABLE) {
    80001f86:	4c9c                	lw	a5,24(s1)
    80001f88:	ff3795e3          	bne	a5,s3,80001f72 <scheduler+0x4e>
        p->state = RUNNING;
    80001f8c:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001f90:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f94:	06048593          	addi	a1,s1,96
    80001f98:	8556                	mv	a0,s5
    80001f9a:	5f4000ef          	jal	8000258e <swtch>
    80001f9e:	8792                	mv	a5,tp
        mycpu()->intena = 0;
    80001fa0:	2781                	sext.w	a5,a5
    80001fa2:	079e                	slli	a5,a5,0x7
    80001fa4:	97da                	add	a5,a5,s6
    80001fa6:	0a07a623          	sw	zero,172(a5)
        c->proc = 0;
    80001faa:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001fae:	8cde                	mv	s9,s7
    80001fb0:	b7c9                	j	80001f72 <scheduler+0x4e>
    if (found == 0) {
    80001fb2:	000c9463          	bnez	s9,80001fba <scheduler+0x96>
      asm volatile("wfi");
    80001fb6:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001fba:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001fbe:	10017073          	csrci	sstatus,2
    int found = 0;
    80001fc2:	4c81                	li	s9,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001fc4:	00011497          	auipc	s1,0x11
    80001fc8:	a4448493          	addi	s1,s1,-1468 # 80012a08 <proc>
      if (p->state == RUNNABLE) {
    80001fcc:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80001fce:	00016917          	auipc	s2,0x16
    80001fd2:	43a90913          	addi	s2,s2,1082 # 80018408 <tickslock>
    80001fd6:	b76d                	j	80001f80 <scheduler+0x5c>

0000000080001fd8 <sched>:
{
    80001fd8:	7179                	addi	sp,sp,-48
    80001fda:	f406                	sd	ra,40(sp)
    80001fdc:	f022                	sd	s0,32(sp)
    80001fde:	ec26                	sd	s1,24(sp)
    80001fe0:	e84a                	sd	s2,16(sp)
    80001fe2:	e44e                	sd	s3,8(sp)
    80001fe4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fe6:	ad1ff0ef          	jal	80001ab6 <myproc>
    80001fea:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001fec:	bd7fe0ef          	jal	80000bc2 <holding>
    80001ff0:	c935                	beqz	a0,80002064 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80001ff2:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001ff4:	2781                	sext.w	a5,a5
    80001ff6:	079e                	slli	a5,a5,0x7
    80001ff8:	00010717          	auipc	a4,0x10
    80001ffc:	5e070713          	addi	a4,a4,1504 # 800125d8 <pid_lock>
    80002000:	97ba                	add	a5,a5,a4
    80002002:	0a87a703          	lw	a4,168(a5)
    80002006:	4785                	li	a5,1
    80002008:	06f71463          	bne	a4,a5,80002070 <sched+0x98>
  if (p->state == RUNNING)
    8000200c:	4c98                	lw	a4,24(s1)
    8000200e:	4791                	li	a5,4
    80002010:	06f70663          	beq	a4,a5,8000207c <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002014:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002018:	8b89                	andi	a5,a5,2
  if (intr_get())
    8000201a:	e7bd                	bnez	a5,80002088 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    8000201c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000201e:	00010917          	auipc	s2,0x10
    80002022:	5ba90913          	addi	s2,s2,1466 # 800125d8 <pid_lock>
    80002026:	2781                	sext.w	a5,a5
    80002028:	079e                	slli	a5,a5,0x7
    8000202a:	97ca                	add	a5,a5,s2
    8000202c:	0ac7a983          	lw	s3,172(a5)
    80002030:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002032:	2781                	sext.w	a5,a5
    80002034:	079e                	slli	a5,a5,0x7
    80002036:	07a1                	addi	a5,a5,8
    80002038:	00010597          	auipc	a1,0x10
    8000203c:	5d058593          	addi	a1,a1,1488 # 80012608 <cpus>
    80002040:	95be                	add	a1,a1,a5
    80002042:	06048513          	addi	a0,s1,96
    80002046:	548000ef          	jal	8000258e <swtch>
    8000204a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000204c:	2781                	sext.w	a5,a5
    8000204e:	079e                	slli	a5,a5,0x7
    80002050:	993e                	add	s2,s2,a5
    80002052:	0b392623          	sw	s3,172(s2)
}
    80002056:	70a2                	ld	ra,40(sp)
    80002058:	7402                	ld	s0,32(sp)
    8000205a:	64e2                	ld	s1,24(sp)
    8000205c:	6942                	ld	s2,16(sp)
    8000205e:	69a2                	ld	s3,8(sp)
    80002060:	6145                	addi	sp,sp,48
    80002062:	8082                	ret
    panic("sched p->lock");
    80002064:	00005517          	auipc	a0,0x5
    80002068:	28c50513          	addi	a0,a0,652 # 800072f0 <etext+0x2f0>
    8000206c:	fc8fe0ef          	jal	80000834 <panic>
    panic("sched locks");
    80002070:	00005517          	auipc	a0,0x5
    80002074:	29050513          	addi	a0,a0,656 # 80007300 <etext+0x300>
    80002078:	fbcfe0ef          	jal	80000834 <panic>
    panic("sched RUNNING");
    8000207c:	00005517          	auipc	a0,0x5
    80002080:	29450513          	addi	a0,a0,660 # 80007310 <etext+0x310>
    80002084:	fb0fe0ef          	jal	80000834 <panic>
    panic("sched interruptible");
    80002088:	00005517          	auipc	a0,0x5
    8000208c:	29850513          	addi	a0,a0,664 # 80007320 <etext+0x320>
    80002090:	fa4fe0ef          	jal	80000834 <panic>

0000000080002094 <yield>:
{
    80002094:	1101                	addi	sp,sp,-32
    80002096:	ec06                	sd	ra,24(sp)
    80002098:	e822                	sd	s0,16(sp)
    8000209a:	e426                	sd	s1,8(sp)
    8000209c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000209e:	a19ff0ef          	jal	80001ab6 <myproc>
    800020a2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020a4:	b85fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    800020a8:	478d                	li	a5,3
    800020aa:	cc9c                	sw	a5,24(s1)
  sched();
    800020ac:	f2dff0ef          	jal	80001fd8 <sched>
  release(&p->lock);
    800020b0:	8526                	mv	a0,s1
    800020b2:	bfffe0ef          	jal	80000cb0 <release>
}
    800020b6:	60e2                	ld	ra,24(sp)
    800020b8:	6442                	ld	s0,16(sp)
    800020ba:	64a2                	ld	s1,8(sp)
    800020bc:	6105                	addi	sp,sp,32
    800020be:	8082                	ret

00000000800020c0 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    800020c0:	1101                	addi	sp,sp,-32
    800020c2:	ec06                	sd	ra,24(sp)
    800020c4:	e822                	sd	s0,16(sp)
    800020c6:	e426                	sd	s1,8(sp)
    800020c8:	e04a                	sd	s2,0(sp)
    800020ca:	1000                	addi	s0,sp,32
    800020cc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800020ce:	9e9ff0ef          	jal	80001ab6 <myproc>
    800020d2:	892a                	mv	s2,a0

  acquire(&p->lock);
    800020d4:	b55fe0ef          	jal	80000c28 <acquire>
  if (chan == 0)
    800020d8:	cc81                	beqz	s1,800020f0 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    800020da:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    800020de:	854a                	mv	a0,s2
    800020e0:	bd1fe0ef          	jal	80000cb0 <release>
}
    800020e4:	60e2                	ld	ra,24(sp)
    800020e6:	6442                	ld	s0,16(sp)
    800020e8:	64a2                	ld	s1,8(sp)
    800020ea:	6902                	ld	s2,0(sp)
    800020ec:	6105                	addi	sp,sp,32
    800020ee:	8082                	ret
    panic("sleep_prepare: zero chan");
    800020f0:	00005517          	auipc	a0,0x5
    800020f4:	24850513          	addi	a0,a0,584 # 80007338 <etext+0x338>
    800020f8:	f3cfe0ef          	jal	80000834 <panic>

00000000800020fc <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    800020fc:	1101                	addi	sp,sp,-32
    800020fe:	ec06                	sd	ra,24(sp)
    80002100:	e822                	sd	s0,16(sp)
    80002102:	e426                	sd	s1,8(sp)
    80002104:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002106:	9b1ff0ef          	jal	80001ab6 <myproc>
    8000210a:	84aa                	mv	s1,a0

  acquire(&p->lock);
    8000210c:	b1dfe0ef          	jal	80000c28 <acquire>
  if (p->chan != 0) {
    80002110:	709c                	ld	a5,32(s1)
    80002112:	c789                	beqz	a5,8000211c <sleep+0x20>
    p->state = SLEEPING;
    80002114:	4789                	li	a5,2
    80002116:	cc9c                	sw	a5,24(s1)
    sched();
    80002118:	ec1ff0ef          	jal	80001fd8 <sched>
  }
  release(&p->lock);
    8000211c:	8526                	mv	a0,s1
    8000211e:	b93fe0ef          	jal	80000cb0 <release>
}
    80002122:	60e2                	ld	ra,24(sp)
    80002124:	6442                	ld	s0,16(sp)
    80002126:	64a2                	ld	s1,8(sp)
    80002128:	6105                	addi	sp,sp,32
    8000212a:	8082                	ret

000000008000212c <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    8000212c:	7139                	addi	sp,sp,-64
    8000212e:	fc06                	sd	ra,56(sp)
    80002130:	f822                	sd	s0,48(sp)
    80002132:	f426                	sd	s1,40(sp)
    80002134:	f04a                	sd	s2,32(sp)
    80002136:	ec4e                	sd	s3,24(sp)
    80002138:	e852                	sd	s4,16(sp)
    8000213a:	e456                	sd	s5,8(sp)
    8000213c:	0080                	addi	s0,sp,64
    8000213e:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002140:	00011497          	auipc	s1,0x11
    80002144:	8c848493          	addi	s1,s1,-1848 # 80012a08 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    80002148:	4a09                	li	s4,2
        p->state = RUNNABLE;
    8000214a:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    8000214c:	00016997          	auipc	s3,0x16
    80002150:	2bc98993          	addi	s3,s3,700 # 80018408 <tickslock>
    80002154:	a801                	j	80002164 <wakeup+0x38>
      }
    }
    release(&p->lock);
    80002156:	8526                	mv	a0,s1
    80002158:	b59fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000215c:	16848493          	addi	s1,s1,360
    80002160:	03348063          	beq	s1,s3,80002180 <wakeup+0x54>
    acquire(&p->lock);
    80002164:	8526                	mv	a0,s1
    80002166:	ac3fe0ef          	jal	80000c28 <acquire>
    if (p->chan == chan) {
    8000216a:	709c                	ld	a5,32(s1)
    8000216c:	ff2795e3          	bne	a5,s2,80002156 <wakeup+0x2a>
      p->chan = 0;
    80002170:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    80002174:	4c9c                	lw	a5,24(s1)
    80002176:	ff4790e3          	bne	a5,s4,80002156 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000217a:	0154ac23          	sw	s5,24(s1)
    8000217e:	bfe1                	j	80002156 <wakeup+0x2a>
  }
}
    80002180:	70e2                	ld	ra,56(sp)
    80002182:	7442                	ld	s0,48(sp)
    80002184:	74a2                	ld	s1,40(sp)
    80002186:	7902                	ld	s2,32(sp)
    80002188:	69e2                	ld	s3,24(sp)
    8000218a:	6a42                	ld	s4,16(sp)
    8000218c:	6aa2                	ld	s5,8(sp)
    8000218e:	6121                	addi	sp,sp,64
    80002190:	8082                	ret

0000000080002192 <reparent>:
{
    80002192:	7179                	addi	sp,sp,-48
    80002194:	f406                	sd	ra,40(sp)
    80002196:	f022                	sd	s0,32(sp)
    80002198:	ec26                	sd	s1,24(sp)
    8000219a:	e84a                	sd	s2,16(sp)
    8000219c:	e44e                	sd	s3,8(sp)
    8000219e:	e052                	sd	s4,0(sp)
    800021a0:	1800                	addi	s0,sp,48
    800021a2:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800021a4:	00011497          	auipc	s1,0x11
    800021a8:	86448493          	addi	s1,s1,-1948 # 80012a08 <proc>
      pp->parent = initproc;
    800021ac:	00008a17          	auipc	s4,0x8
    800021b0:	324a0a13          	addi	s4,s4,804 # 8000a4d0 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800021b4:	00016997          	auipc	s3,0x16
    800021b8:	25498993          	addi	s3,s3,596 # 80018408 <tickslock>
    800021bc:	a029                	j	800021c6 <reparent+0x34>
    800021be:	16848493          	addi	s1,s1,360
    800021c2:	01348b63          	beq	s1,s3,800021d8 <reparent+0x46>
    if (pp->parent == p) {
    800021c6:	7c9c                	ld	a5,56(s1)
    800021c8:	ff279be3          	bne	a5,s2,800021be <reparent+0x2c>
      pp->parent = initproc;
    800021cc:	000a3503          	ld	a0,0(s4)
    800021d0:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800021d2:	f5bff0ef          	jal	8000212c <wakeup>
    800021d6:	b7e5                	j	800021be <reparent+0x2c>
}
    800021d8:	70a2                	ld	ra,40(sp)
    800021da:	7402                	ld	s0,32(sp)
    800021dc:	64e2                	ld	s1,24(sp)
    800021de:	6942                	ld	s2,16(sp)
    800021e0:	69a2                	ld	s3,8(sp)
    800021e2:	6a02                	ld	s4,0(sp)
    800021e4:	6145                	addi	sp,sp,48
    800021e6:	8082                	ret

00000000800021e8 <kexit>:
{
    800021e8:	7179                	addi	sp,sp,-48
    800021ea:	f406                	sd	ra,40(sp)
    800021ec:	f022                	sd	s0,32(sp)
    800021ee:	ec26                	sd	s1,24(sp)
    800021f0:	e84a                	sd	s2,16(sp)
    800021f2:	e44e                	sd	s3,8(sp)
    800021f4:	e052                	sd	s4,0(sp)
    800021f6:	1800                	addi	s0,sp,48
    800021f8:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021fa:	8bdff0ef          	jal	80001ab6 <myproc>
    800021fe:	89aa                	mv	s3,a0
  if (p == initproc)
    80002200:	00008797          	auipc	a5,0x8
    80002204:	2d07b783          	ld	a5,720(a5) # 8000a4d0 <initproc>
    80002208:	0d050493          	addi	s1,a0,208
    8000220c:	15050913          	addi	s2,a0,336
    80002210:	00a79b63          	bne	a5,a0,80002226 <kexit+0x3e>
    panic("init exiting");
    80002214:	00005517          	auipc	a0,0x5
    80002218:	14450513          	addi	a0,a0,324 # 80007358 <etext+0x358>
    8000221c:	e18fe0ef          	jal	80000834 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    80002220:	04a1                	addi	s1,s1,8
    80002222:	01248963          	beq	s1,s2,80002234 <kexit+0x4c>
    if (p->ofile[fd]) {
    80002226:	6088                	ld	a0,0(s1)
    80002228:	dd65                	beqz	a0,80002220 <kexit+0x38>
      fileclose(f);
    8000222a:	0f4020ef          	jal	8000431e <fileclose>
      p->ofile[fd] = 0;
    8000222e:	0004b023          	sd	zero,0(s1)
    80002232:	b7fd                	j	80002220 <kexit+0x38>
  begin_op();
    80002234:	431010ef          	jal	80003e64 <begin_op>
  iput(p->cwd);
    80002238:	1509b503          	ld	a0,336(s3)
    8000223c:	332010ef          	jal	8000356e <iput>
  end_op();
    80002240:	4b1010ef          	jal	80003ef0 <end_op>
  p->cwd = 0;
    80002244:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002248:	00010517          	auipc	a0,0x10
    8000224c:	3a850513          	addi	a0,a0,936 # 800125f0 <wait_lock>
    80002250:	9d9fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    80002254:	854e                	mv	a0,s3
    80002256:	f3dff0ef          	jal	80002192 <reparent>
  wakeup(p->parent);
    8000225a:	0389b503          	ld	a0,56(s3)
    8000225e:	ecfff0ef          	jal	8000212c <wakeup>
  acquire(&p->lock);
    80002262:	854e                	mv	a0,s3
    80002264:	9c5fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    80002268:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000226c:	4795                	li	a5,5
    8000226e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002272:	00010517          	auipc	a0,0x10
    80002276:	37e50513          	addi	a0,a0,894 # 800125f0 <wait_lock>
    8000227a:	a37fe0ef          	jal	80000cb0 <release>
  sched();
    8000227e:	d5bff0ef          	jal	80001fd8 <sched>
  panic("zombie exit");
    80002282:	00005517          	auipc	a0,0x5
    80002286:	0e650513          	addi	a0,a0,230 # 80007368 <etext+0x368>
    8000228a:	daafe0ef          	jal	80000834 <panic>

000000008000228e <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    8000228e:	c525                	beqz	a0,800022f6 <kkill+0x68>
{
    80002290:	7179                	addi	sp,sp,-48
    80002292:	f406                	sd	ra,40(sp)
    80002294:	f022                	sd	s0,32(sp)
    80002296:	ec26                	sd	s1,24(sp)
    80002298:	e84a                	sd	s2,16(sp)
    8000229a:	e44e                	sd	s3,8(sp)
    8000229c:	1800                	addi	s0,sp,48
    8000229e:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    800022a0:	00010497          	auipc	s1,0x10
    800022a4:	76848493          	addi	s1,s1,1896 # 80012a08 <proc>
    800022a8:	00016997          	auipc	s3,0x16
    800022ac:	16098993          	addi	s3,s3,352 # 80018408 <tickslock>
    acquire(&p->lock);
    800022b0:	8526                	mv	a0,s1
    800022b2:	977fe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid) {
    800022b6:	589c                	lw	a5,48(s1)
    800022b8:	01278b63          	beq	a5,s2,800022ce <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800022bc:	8526                	mv	a0,s1
    800022be:	9f3fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800022c2:	16848493          	addi	s1,s1,360
    800022c6:	ff3495e3          	bne	s1,s3,800022b0 <kkill+0x22>
  }
  return -1;
    800022ca:	557d                	li	a0,-1
    800022cc:	a819                	j	800022e2 <kkill+0x54>
      p->killed = 1;
    800022ce:	4785                	li	a5,1
    800022d0:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    800022d2:	4c98                	lw	a4,24(s1)
    800022d4:	4789                	li	a5,2
    800022d6:	00f70d63          	beq	a4,a5,800022f0 <kkill+0x62>
      release(&p->lock);
    800022da:	8526                	mv	a0,s1
    800022dc:	9d5fe0ef          	jal	80000cb0 <release>
      return 0;
    800022e0:	4501                	li	a0,0
}
    800022e2:	70a2                	ld	ra,40(sp)
    800022e4:	7402                	ld	s0,32(sp)
    800022e6:	64e2                	ld	s1,24(sp)
    800022e8:	6942                	ld	s2,16(sp)
    800022ea:	69a2                	ld	s3,8(sp)
    800022ec:	6145                	addi	sp,sp,48
    800022ee:	8082                	ret
        p->state = RUNNABLE;
    800022f0:	478d                	li	a5,3
    800022f2:	cc9c                	sw	a5,24(s1)
    800022f4:	b7dd                	j	800022da <kkill+0x4c>
    return -1;
    800022f6:	557d                	li	a0,-1
}
    800022f8:	8082                	ret

00000000800022fa <setkilled>:

void
setkilled(struct proc *p)
{
    800022fa:	1101                	addi	sp,sp,-32
    800022fc:	ec06                	sd	ra,24(sp)
    800022fe:	e822                	sd	s0,16(sp)
    80002300:	e426                	sd	s1,8(sp)
    80002302:	1000                	addi	s0,sp,32
    80002304:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002306:	923fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    8000230a:	4785                	li	a5,1
    8000230c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000230e:	8526                	mv	a0,s1
    80002310:	9a1fe0ef          	jal	80000cb0 <release>
}
    80002314:	60e2                	ld	ra,24(sp)
    80002316:	6442                	ld	s0,16(sp)
    80002318:	64a2                	ld	s1,8(sp)
    8000231a:	6105                	addi	sp,sp,32
    8000231c:	8082                	ret

000000008000231e <killed>:

int
killed(struct proc *p)
{
    8000231e:	1101                	addi	sp,sp,-32
    80002320:	ec06                	sd	ra,24(sp)
    80002322:	e822                	sd	s0,16(sp)
    80002324:	e426                	sd	s1,8(sp)
    80002326:	e04a                	sd	s2,0(sp)
    80002328:	1000                	addi	s0,sp,32
    8000232a:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000232c:	8fdfe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    80002330:	549c                	lw	a5,40(s1)
    80002332:	893e                	mv	s2,a5
  release(&p->lock);
    80002334:	8526                	mv	a0,s1
    80002336:	97bfe0ef          	jal	80000cb0 <release>
  return k;
}
    8000233a:	854a                	mv	a0,s2
    8000233c:	60e2                	ld	ra,24(sp)
    8000233e:	6442                	ld	s0,16(sp)
    80002340:	64a2                	ld	s1,8(sp)
    80002342:	6902                	ld	s2,0(sp)
    80002344:	6105                	addi	sp,sp,32
    80002346:	8082                	ret

0000000080002348 <kwait>:
{
    80002348:	715d                	addi	sp,sp,-80
    8000234a:	e486                	sd	ra,72(sp)
    8000234c:	e0a2                	sd	s0,64(sp)
    8000234e:	fc26                	sd	s1,56(sp)
    80002350:	f84a                	sd	s2,48(sp)
    80002352:	f44e                	sd	s3,40(sp)
    80002354:	f052                	sd	s4,32(sp)
    80002356:	ec56                	sd	s5,24(sp)
    80002358:	e85a                	sd	s6,16(sp)
    8000235a:	e45e                	sd	s7,8(sp)
    8000235c:	0880                	addi	s0,sp,80
    8000235e:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002360:	f56ff0ef          	jal	80001ab6 <myproc>
    80002364:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002366:	00010517          	auipc	a0,0x10
    8000236a:	28a50513          	addi	a0,a0,650 # 800125f0 <wait_lock>
    8000236e:	8bbfe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    80002372:	4a15                	li	s4,5
        havekids = 1;
    80002374:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002376:	00016997          	auipc	s3,0x16
    8000237a:	09298993          	addi	s3,s3,146 # 80018408 <tickslock>
    release(&wait_lock);
    8000237e:	00010b17          	auipc	s6,0x10
    80002382:	272b0b13          	addi	s6,s6,626 # 800125f0 <wait_lock>
    80002386:	a845                	j	80002436 <kwait+0xee>
          pid = pp->pid;
    80002388:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    8000238c:	000b8e63          	beqz	s7,800023a8 <kwait+0x60>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    80002390:	4711                	li	a4,4
    80002392:	02c48693          	addi	a3,s1,44
    80002396:	865e                	mv	a2,s7
    80002398:	04893583          	ld	a1,72(s2)
    8000239c:	05093503          	ld	a0,80(s2)
    800023a0:	9e2ff0ef          	jal	80001582 <copyout>
          if (addr != 0 &&
    800023a4:	02054c63          	bltz	a0,800023dc <kwait+0x94>
          pp->parent = 0;
    800023a8:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    800023ac:	8526                	mv	a0,s1
    800023ae:	8d9ff0ef          	jal	80001c86 <freeproc>
          release(&pp->lock);
    800023b2:	8526                	mv	a0,s1
    800023b4:	8fdfe0ef          	jal	80000cb0 <release>
          release(&wait_lock);
    800023b8:	00010517          	auipc	a0,0x10
    800023bc:	23850513          	addi	a0,a0,568 # 800125f0 <wait_lock>
    800023c0:	8f1fe0ef          	jal	80000cb0 <release>
}
    800023c4:	854e                	mv	a0,s3
    800023c6:	60a6                	ld	ra,72(sp)
    800023c8:	6406                	ld	s0,64(sp)
    800023ca:	74e2                	ld	s1,56(sp)
    800023cc:	7942                	ld	s2,48(sp)
    800023ce:	79a2                	ld	s3,40(sp)
    800023d0:	7a02                	ld	s4,32(sp)
    800023d2:	6ae2                	ld	s5,24(sp)
    800023d4:	6b42                	ld	s6,16(sp)
    800023d6:	6ba2                	ld	s7,8(sp)
    800023d8:	6161                	addi	sp,sp,80
    800023da:	8082                	ret
            release(&pp->lock);
    800023dc:	8526                	mv	a0,s1
    800023de:	8d3fe0ef          	jal	80000cb0 <release>
            release(&wait_lock);
    800023e2:	00010517          	auipc	a0,0x10
    800023e6:	20e50513          	addi	a0,a0,526 # 800125f0 <wait_lock>
    800023ea:	8c7fe0ef          	jal	80000cb0 <release>
            return -1;
    800023ee:	59fd                	li	s3,-1
    800023f0:	bfd1                	j	800023c4 <kwait+0x7c>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800023f2:	16848493          	addi	s1,s1,360
    800023f6:	03348063          	beq	s1,s3,80002416 <kwait+0xce>
      if (pp->parent == p) {
    800023fa:	7c9c                	ld	a5,56(s1)
    800023fc:	ff279be3          	bne	a5,s2,800023f2 <kwait+0xaa>
        acquire(&pp->lock);
    80002400:	8526                	mv	a0,s1
    80002402:	827fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    80002406:	4c9c                	lw	a5,24(s1)
    80002408:	f94780e3          	beq	a5,s4,80002388 <kwait+0x40>
        release(&pp->lock);
    8000240c:	8526                	mv	a0,s1
    8000240e:	8a3fe0ef          	jal	80000cb0 <release>
        havekids = 1;
    80002412:	8756                	mv	a4,s5
    80002414:	bff9                	j	800023f2 <kwait+0xaa>
    if (!havekids || killed(p)) {
    80002416:	c715                	beqz	a4,80002442 <kwait+0xfa>
    80002418:	854a                	mv	a0,s2
    8000241a:	f05ff0ef          	jal	8000231e <killed>
    8000241e:	e115                	bnez	a0,80002442 <kwait+0xfa>
    sleep_prepare(p); //DOC: wait-sleep
    80002420:	854a                	mv	a0,s2
    80002422:	c9fff0ef          	jal	800020c0 <sleep_prepare>
    release(&wait_lock);
    80002426:	855a                	mv	a0,s6
    80002428:	889fe0ef          	jal	80000cb0 <release>
    sleep();
    8000242c:	cd1ff0ef          	jal	800020fc <sleep>
    acquire(&wait_lock);
    80002430:	855a                	mv	a0,s6
    80002432:	ff6fe0ef          	jal	80000c28 <acquire>
    havekids = 0;
    80002436:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002438:	00010497          	auipc	s1,0x10
    8000243c:	5d048493          	addi	s1,s1,1488 # 80012a08 <proc>
    80002440:	bf6d                	j	800023fa <kwait+0xb2>
      release(&wait_lock);
    80002442:	00010517          	auipc	a0,0x10
    80002446:	1ae50513          	addi	a0,a0,430 # 800125f0 <wait_lock>
    8000244a:	867fe0ef          	jal	80000cb0 <release>
      return -1;
    8000244e:	59fd                	li	s3,-1
    80002450:	bf95                	j	800023c4 <kwait+0x7c>

0000000080002452 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002452:	7179                	addi	sp,sp,-48
    80002454:	f406                	sd	ra,40(sp)
    80002456:	f022                	sd	s0,32(sp)
    80002458:	ec26                	sd	s1,24(sp)
    8000245a:	e84a                	sd	s2,16(sp)
    8000245c:	e44e                	sd	s3,8(sp)
    8000245e:	e052                	sd	s4,0(sp)
    80002460:	1800                	addi	s0,sp,48
    80002462:	84aa                	mv	s1,a0
    80002464:	8a2e                	mv	s4,a1
    80002466:	89b2                	mv	s3,a2
    80002468:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000246a:	e4cff0ef          	jal	80001ab6 <myproc>
  if (user_dst) {
    8000246e:	c085                	beqz	s1,8000248e <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    80002470:	874a                	mv	a4,s2
    80002472:	86ce                	mv	a3,s3
    80002474:	8652                	mv	a2,s4
    80002476:	652c                	ld	a1,72(a0)
    80002478:	6928                	ld	a0,80(a0)
    8000247a:	908ff0ef          	jal	80001582 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000247e:	70a2                	ld	ra,40(sp)
    80002480:	7402                	ld	s0,32(sp)
    80002482:	64e2                	ld	s1,24(sp)
    80002484:	6942                	ld	s2,16(sp)
    80002486:	69a2                	ld	s3,8(sp)
    80002488:	6a02                	ld	s4,0(sp)
    8000248a:	6145                	addi	sp,sp,48
    8000248c:	8082                	ret
    memmove((char *)dst, src, len);
    8000248e:	0009061b          	sext.w	a2,s2
    80002492:	85ce                	mv	a1,s3
    80002494:	8552                	mv	a0,s4
    80002496:	8b3fe0ef          	jal	80000d48 <memmove>
    return 0;
    8000249a:	8526                	mv	a0,s1
    8000249c:	b7cd                	j	8000247e <either_copyout+0x2c>

000000008000249e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000249e:	7179                	addi	sp,sp,-48
    800024a0:	f406                	sd	ra,40(sp)
    800024a2:	f022                	sd	s0,32(sp)
    800024a4:	ec26                	sd	s1,24(sp)
    800024a6:	e84a                	sd	s2,16(sp)
    800024a8:	e44e                	sd	s3,8(sp)
    800024aa:	e052                	sd	s4,0(sp)
    800024ac:	1800                	addi	s0,sp,48
    800024ae:	8a2a                	mv	s4,a0
    800024b0:	84ae                	mv	s1,a1
    800024b2:	89b2                	mv	s3,a2
    800024b4:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800024b6:	e00ff0ef          	jal	80001ab6 <myproc>
  if (user_src) {
    800024ba:	c085                	beqz	s1,800024da <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    800024bc:	874a                	mv	a4,s2
    800024be:	86ce                	mv	a3,s3
    800024c0:	8652                	mv	a2,s4
    800024c2:	652c                	ld	a1,72(a0)
    800024c4:	6928                	ld	a0,80(a0)
    800024c6:	982ff0ef          	jal	80001648 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800024ca:	70a2                	ld	ra,40(sp)
    800024cc:	7402                	ld	s0,32(sp)
    800024ce:	64e2                	ld	s1,24(sp)
    800024d0:	6942                	ld	s2,16(sp)
    800024d2:	69a2                	ld	s3,8(sp)
    800024d4:	6a02                	ld	s4,0(sp)
    800024d6:	6145                	addi	sp,sp,48
    800024d8:	8082                	ret
    memmove(dst, (char *)src, len);
    800024da:	0009061b          	sext.w	a2,s2
    800024de:	85ce                	mv	a1,s3
    800024e0:	8552                	mv	a0,s4
    800024e2:	867fe0ef          	jal	80000d48 <memmove>
    return 0;
    800024e6:	8526                	mv	a0,s1
    800024e8:	b7cd                	j	800024ca <either_copyin+0x2c>

00000000800024ea <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800024ea:	715d                	addi	sp,sp,-80
    800024ec:	e486                	sd	ra,72(sp)
    800024ee:	e0a2                	sd	s0,64(sp)
    800024f0:	fc26                	sd	s1,56(sp)
    800024f2:	f84a                	sd	s2,48(sp)
    800024f4:	f44e                	sd	s3,40(sp)
    800024f6:	f052                	sd	s4,32(sp)
    800024f8:	ec56                	sd	s5,24(sp)
    800024fa:	e85a                	sd	s6,16(sp)
    800024fc:	e45e                	sd	s7,8(sp)
    800024fe:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    80002500:	00005517          	auipc	a0,0x5
    80002504:	b7850513          	addi	a0,a0,-1160 # 80007078 <etext+0x78>
    80002508:	802fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000250c:	00010497          	auipc	s1,0x10
    80002510:	65448493          	addi	s1,s1,1620 # 80012b60 <proc+0x158>
    80002514:	00016917          	auipc	s2,0x16
    80002518:	04c90913          	addi	s2,s2,76 # 80018560 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000251c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000251e:	00005997          	auipc	s3,0x5
    80002522:	e5a98993          	addi	s3,s3,-422 # 80007378 <etext+0x378>
    printk("%d %s %s", p->pid, state, p->name);
    80002526:	00005a97          	auipc	s5,0x5
    8000252a:	e5aa8a93          	addi	s5,s5,-422 # 80007380 <etext+0x380>
    printk("\n");
    8000252e:	00005a17          	auipc	s4,0x5
    80002532:	b4aa0a13          	addi	s4,s4,-1206 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002536:	00005b97          	auipc	s7,0x5
    8000253a:	36ab8b93          	addi	s7,s7,874 # 800078a0 <states.0>
    8000253e:	a829                	j	80002558 <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    80002540:	ed86a583          	lw	a1,-296(a3)
    80002544:	8556                	mv	a0,s5
    80002546:	fc5fd0ef          	jal	8000050a <printk>
    printk("\n");
    8000254a:	8552                	mv	a0,s4
    8000254c:	fbffd0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002550:	16848493          	addi	s1,s1,360
    80002554:	03248263          	beq	s1,s2,80002578 <procdump+0x8e>
    if (p->state == UNUSED)
    80002558:	86a6                	mv	a3,s1
    8000255a:	ec04a783          	lw	a5,-320(s1)
    8000255e:	dbed                	beqz	a5,80002550 <procdump+0x66>
      state = "???";
    80002560:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002562:	fcfb6fe3          	bltu	s6,a5,80002540 <procdump+0x56>
    80002566:	02079713          	slli	a4,a5,0x20
    8000256a:	01d75793          	srli	a5,a4,0x1d
    8000256e:	97de                	add	a5,a5,s7
    80002570:	6390                	ld	a2,0(a5)
    80002572:	f679                	bnez	a2,80002540 <procdump+0x56>
      state = "???";
    80002574:	864e                	mv	a2,s3
    80002576:	b7e9                	j	80002540 <procdump+0x56>
  }
}
    80002578:	60a6                	ld	ra,72(sp)
    8000257a:	6406                	ld	s0,64(sp)
    8000257c:	74e2                	ld	s1,56(sp)
    8000257e:	7942                	ld	s2,48(sp)
    80002580:	79a2                	ld	s3,40(sp)
    80002582:	7a02                	ld	s4,32(sp)
    80002584:	6ae2                	ld	s5,24(sp)
    80002586:	6b42                	ld	s6,16(sp)
    80002588:	6ba2                	ld	s7,8(sp)
    8000258a:	6161                	addi	sp,sp,80
    8000258c:	8082                	ret

000000008000258e <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000258e:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002592:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002596:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002598:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000259a:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    8000259e:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800025a2:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800025a6:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800025aa:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800025ae:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800025b2:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800025b6:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800025ba:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800025be:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800025c2:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800025c6:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800025ca:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800025cc:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800025ce:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800025d2:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800025d6:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800025da:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800025de:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800025e2:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800025e6:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800025ea:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800025ee:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800025f2:	0685bd83          	ld	s11,104(a1)
        
        ret
    800025f6:	8082                	ret

00000000800025f8 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800025f8:	1141                	addi	sp,sp,-16
    800025fa:	e406                	sd	ra,8(sp)
    800025fc:	e022                	sd	s0,0(sp)
    800025fe:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002600:	00005597          	auipc	a1,0x5
    80002604:	dc058593          	addi	a1,a1,-576 # 800073c0 <etext+0x3c0>
    80002608:	00016517          	auipc	a0,0x16
    8000260c:	e0050513          	addi	a0,a0,-512 # 80018408 <tickslock>
    80002610:	d98fe0ef          	jal	80000ba8 <initlock>
}
    80002614:	60a2                	ld	ra,8(sp)
    80002616:	6402                	ld	s0,0(sp)
    80002618:	0141                	addi	sp,sp,16
    8000261a:	8082                	ret

000000008000261c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000261c:	1141                	addi	sp,sp,-16
    8000261e:	e406                	sd	ra,8(sp)
    80002620:	e022                	sd	s0,0(sp)
    80002622:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002624:	00003797          	auipc	a5,0x3
    80002628:	18c78793          	addi	a5,a5,396 # 800057b0 <kernelvec>
    8000262c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002630:	60a2                	ld	ra,8(sp)
    80002632:	6402                	ld	s0,0(sp)
    80002634:	0141                	addi	sp,sp,16
    80002636:	8082                	ret

0000000080002638 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002638:	1141                	addi	sp,sp,-16
    8000263a:	e406                	sd	ra,8(sp)
    8000263c:	e022                	sd	s0,0(sp)
    8000263e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002640:	c76ff0ef          	jal	80001ab6 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80002644:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002648:	04000737          	lui	a4,0x4000
    8000264c:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000264e:	0732                	slli	a4,a4,0xc
    80002650:	00004797          	auipc	a5,0x4
    80002654:	9b078793          	addi	a5,a5,-1616 # 80006000 <_trampoline>
    80002658:	00004697          	auipc	a3,0x4
    8000265c:	9a868693          	addi	a3,a3,-1624 # 80006000 <_trampoline>
    80002660:	8f95                	sub	a5,a5,a3
    80002662:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002664:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002668:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    8000266a:	18002773          	csrr	a4,satp
    8000266e:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002670:	6d38                	ld	a4,88(a0)
    80002672:	613c                	ld	a5,64(a0)
    80002674:	6685                	lui	a3,0x1
    80002676:	97b6                	add	a5,a5,a3
    80002678:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000267a:	6d3c                	ld	a5,88(a0)
    8000267c:	00000717          	auipc	a4,0x0
    80002680:	0fc70713          	addi	a4,a4,252 # 80002778 <usertrap>
    80002684:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002686:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    80002688:	8712                	mv	a4,tp
    8000268a:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000268c:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002690:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002694:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002698:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000269c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    8000269e:	6f9c                	ld	a5,24(a5)
    800026a0:	14179073          	csrw	sepc,a5
}
    800026a4:	60a2                	ld	ra,8(sp)
    800026a6:	6402                	ld	s0,0(sp)
    800026a8:	0141                	addi	sp,sp,16
    800026aa:	8082                	ret

00000000800026ac <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026ac:	1141                	addi	sp,sp,-16
    800026ae:	e406                	sd	ra,8(sp)
    800026b0:	e022                	sd	s0,0(sp)
    800026b2:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    800026b4:	bceff0ef          	jal	80001a82 <cpuid>
    800026b8:	cd11                	beqz	a0,800026d4 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    800026ba:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800026be:	000f4737          	lui	a4,0xf4
    800026c2:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800026c6:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    800026c8:	14d79073          	csrw	stimecmp,a5
}
    800026cc:	60a2                	ld	ra,8(sp)
    800026ce:	6402                	ld	s0,0(sp)
    800026d0:	0141                	addi	sp,sp,16
    800026d2:	8082                	ret
    acquire(&tickslock);
    800026d4:	00016517          	auipc	a0,0x16
    800026d8:	d3450513          	addi	a0,a0,-716 # 80018408 <tickslock>
    800026dc:	d4cfe0ef          	jal	80000c28 <acquire>
    ticks++;
    800026e0:	00008717          	auipc	a4,0x8
    800026e4:	df870713          	addi	a4,a4,-520 # 8000a4d8 <ticks>
    800026e8:	431c                	lw	a5,0(a4)
    800026ea:	2785                	addiw	a5,a5,1
    800026ec:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    800026ee:	853a                	mv	a0,a4
    800026f0:	a3dff0ef          	jal	8000212c <wakeup>
    release(&tickslock);
    800026f4:	00016517          	auipc	a0,0x16
    800026f8:	d1450513          	addi	a0,a0,-748 # 80018408 <tickslock>
    800026fc:	db4fe0ef          	jal	80000cb0 <release>
    80002700:	bf6d                	j	800026ba <clockintr+0xe>

0000000080002702 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002702:	1101                	addi	sp,sp,-32
    80002704:	ec06                	sd	ra,24(sp)
    80002706:	e822                	sd	s0,16(sp)
    80002708:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    8000270a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    8000270e:	57fd                	li	a5,-1
    80002710:	17fe                	slli	a5,a5,0x3f
    80002712:	07a5                	addi	a5,a5,9
    80002714:	00f70c63          	beq	a4,a5,8000272c <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    80002718:	57fd                	li	a5,-1
    8000271a:	17fe                	slli	a5,a5,0x3f
    8000271c:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000271e:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    80002720:	04f70863          	beq	a4,a5,80002770 <devintr+0x6e>
  }
}
    80002724:	60e2                	ld	ra,24(sp)
    80002726:	6442                	ld	s0,16(sp)
    80002728:	6105                	addi	sp,sp,32
    8000272a:	8082                	ret
    8000272c:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000272e:	130030ef          	jal	8000585e <plic_claim>
    80002732:	872a                	mv	a4,a0
    80002734:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    80002736:	47a9                	li	a5,10
    80002738:	00f50963          	beq	a0,a5,8000274a <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    8000273c:	4785                	li	a5,1
    8000273e:	00f50963          	beq	a0,a5,80002750 <devintr+0x4e>
    return 1;
    80002742:	4505                	li	a0,1
    } else if (irq) {
    80002744:	eb09                	bnez	a4,80002756 <devintr+0x54>
    80002746:	64a2                	ld	s1,8(sp)
    80002748:	bff1                	j	80002724 <devintr+0x22>
      uartintr();
    8000274a:	aa4fe0ef          	jal	800009ee <uartintr>
    if (irq)
    8000274e:	a819                	j	80002764 <devintr+0x62>
      virtio_disk_intr();
    80002750:	5ca030ef          	jal	80005d1a <virtio_disk_intr>
    if (irq)
    80002754:	a801                	j	80002764 <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    80002756:	85ba                	mv	a1,a4
    80002758:	00005517          	auipc	a0,0x5
    8000275c:	c7050513          	addi	a0,a0,-912 # 800073c8 <etext+0x3c8>
    80002760:	dabfd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    80002764:	8526                	mv	a0,s1
    80002766:	11a030ef          	jal	80005880 <plic_complete>
    return 1;
    8000276a:	4505                	li	a0,1
    8000276c:	64a2                	ld	s1,8(sp)
    8000276e:	bf5d                	j	80002724 <devintr+0x22>
    clockintr();
    80002770:	f3dff0ef          	jal	800026ac <clockintr>
    return 2;
    80002774:	4509                	li	a0,2
    80002776:	b77d                	j	80002724 <devintr+0x22>

0000000080002778 <usertrap>:
{
    80002778:	1101                	addi	sp,sp,-32
    8000277a:	ec06                	sd	ra,24(sp)
    8000277c:	e822                	sd	s0,16(sp)
    8000277e:	e426                	sd	s1,8(sp)
    80002780:	e04a                	sd	s2,0(sp)
    80002782:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002784:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002788:	1007f793          	andi	a5,a5,256
    8000278c:	eba5                	bnez	a5,800027fc <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    8000278e:	00003797          	auipc	a5,0x3
    80002792:	02278793          	addi	a5,a5,34 # 800057b0 <kernelvec>
    80002796:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000279a:	b1cff0ef          	jal	80001ab6 <myproc>
    8000279e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800027a0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    800027a2:	14102773          	csrr	a4,sepc
    800027a6:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    800027a8:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    800027ac:	47a1                	li	a5,8
    800027ae:	04f70d63          	beq	a4,a5,80002808 <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    800027b2:	f51ff0ef          	jal	80002702 <devintr>
    800027b6:	892a                	mv	s2,a0
    800027b8:	e54d                	bnez	a0,80002862 <usertrap+0xea>
    800027ba:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    800027be:	47bd                	li	a5,15
    800027c0:	08f70463          	beq	a4,a5,80002848 <usertrap+0xd0>
    800027c4:	14202773          	csrr	a4,scause
    800027c8:	47b5                	li	a5,13
    800027ca:	06f70f63          	beq	a4,a5,80002848 <usertrap+0xd0>
    800027ce:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800027d2:	5890                	lw	a2,48(s1)
    800027d4:	00005517          	auipc	a0,0x5
    800027d8:	c3450513          	addi	a0,a0,-972 # 80007408 <etext+0x408>
    800027dc:	d2ffd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800027e0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800027e4:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800027e8:	00005517          	auipc	a0,0x5
    800027ec:	c5050513          	addi	a0,a0,-944 # 80007438 <etext+0x438>
    800027f0:	d1bfd0ef          	jal	8000050a <printk>
    setkilled(p);
    800027f4:	8526                	mv	a0,s1
    800027f6:	b05ff0ef          	jal	800022fa <setkilled>
    800027fa:	a015                	j	8000281e <usertrap+0xa6>
    panic("usertrap: not from user mode");
    800027fc:	00005517          	auipc	a0,0x5
    80002800:	bec50513          	addi	a0,a0,-1044 # 800073e8 <etext+0x3e8>
    80002804:	830fe0ef          	jal	80000834 <panic>
    if (killed(p))
    80002808:	b17ff0ef          	jal	8000231e <killed>
    8000280c:	e915                	bnez	a0,80002840 <usertrap+0xc8>
    p->trapframe->epc += 4;
    8000280e:	6cb8                	ld	a4,88(s1)
    80002810:	6f1c                	ld	a5,24(a4)
    80002812:	0791                	addi	a5,a5,4
    80002814:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80002816:	10016073          	csrsi	sstatus,2
    syscall();
    8000281a:	244000ef          	jal	80002a5e <syscall>
  if (killed(p))
    8000281e:	8526                	mv	a0,s1
    80002820:	affff0ef          	jal	8000231e <killed>
    80002824:	e521                	bnez	a0,8000286c <usertrap+0xf4>
  prepare_return();
    80002826:	e13ff0ef          	jal	80002638 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000282a:	68a8                	ld	a0,80(s1)
    8000282c:	8131                	srli	a0,a0,0xc
    8000282e:	57fd                	li	a5,-1
    80002830:	17fe                	slli	a5,a5,0x3f
    80002832:	8d5d                	or	a0,a0,a5
}
    80002834:	60e2                	ld	ra,24(sp)
    80002836:	6442                	ld	s0,16(sp)
    80002838:	64a2                	ld	s1,8(sp)
    8000283a:	6902                	ld	s2,0(sp)
    8000283c:	6105                	addi	sp,sp,32
    8000283e:	8082                	ret
      kexit(-1);
    80002840:	557d                	li	a0,-1
    80002842:	9a7ff0ef          	jal	800021e8 <kexit>
    80002846:	b7e1                	j	8000280e <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    80002848:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    8000284c:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    80002850:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    80002852:	0016b693          	seqz	a3,a3
    80002856:	64ac                	ld	a1,72(s1)
    80002858:	68a8                	ld	a0,80(s1)
    8000285a:	cadfe0ef          	jal	80001506 <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    8000285e:	f161                	bnez	a0,8000281e <usertrap+0xa6>
    80002860:	b7bd                	j	800027ce <usertrap+0x56>
  if (killed(p))
    80002862:	8526                	mv	a0,s1
    80002864:	abbff0ef          	jal	8000231e <killed>
    80002868:	c511                	beqz	a0,80002874 <usertrap+0xfc>
    8000286a:	a011                	j	8000286e <usertrap+0xf6>
    8000286c:	4901                	li	s2,0
    kexit(-1);
    8000286e:	557d                	li	a0,-1
    80002870:	979ff0ef          	jal	800021e8 <kexit>
  if (which_dev == 2)
    80002874:	4789                	li	a5,2
    80002876:	faf918e3          	bne	s2,a5,80002826 <usertrap+0xae>
    yield();
    8000287a:	81bff0ef          	jal	80002094 <yield>
    8000287e:	b765                	j	80002826 <usertrap+0xae>

0000000080002880 <kerneltrap>:
{
    80002880:	7179                	addi	sp,sp,-48
    80002882:	f406                	sd	ra,40(sp)
    80002884:	f022                	sd	s0,32(sp)
    80002886:	ec26                	sd	s1,24(sp)
    80002888:	e84a                	sd	s2,16(sp)
    8000288a:	e44e                	sd	s3,8(sp)
    8000288c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    8000288e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002892:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    80002896:	142027f3          	csrr	a5,scause
    8000289a:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    8000289c:	1004f793          	andi	a5,s1,256
    800028a0:	c795                	beqz	a5,800028cc <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800028a2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800028a6:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    800028a8:	eb85                	bnez	a5,800028d8 <kerneltrap+0x58>
  if ((which_dev = devintr()) == 0) {
    800028aa:	e59ff0ef          	jal	80002702 <devintr>
    800028ae:	c91d                	beqz	a0,800028e4 <kerneltrap+0x64>
  if (which_dev == 2 && myproc() != 0)
    800028b0:	4789                	li	a5,2
    800028b2:	04f50a63          	beq	a0,a5,80002906 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    800028b6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800028ba:	10049073          	csrw	sstatus,s1
}
    800028be:	70a2                	ld	ra,40(sp)
    800028c0:	7402                	ld	s0,32(sp)
    800028c2:	64e2                	ld	s1,24(sp)
    800028c4:	6942                	ld	s2,16(sp)
    800028c6:	69a2                	ld	s3,8(sp)
    800028c8:	6145                	addi	sp,sp,48
    800028ca:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800028cc:	00005517          	auipc	a0,0x5
    800028d0:	b9450513          	addi	a0,a0,-1132 # 80007460 <etext+0x460>
    800028d4:	f61fd0ef          	jal	80000834 <panic>
    panic("kerneltrap: interrupts enabled");
    800028d8:	00005517          	auipc	a0,0x5
    800028dc:	bb050513          	addi	a0,a0,-1104 # 80007488 <etext+0x488>
    800028e0:	f55fd0ef          	jal	80000834 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800028e4:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800028e8:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    800028ec:	85ce                	mv	a1,s3
    800028ee:	00005517          	auipc	a0,0x5
    800028f2:	bba50513          	addi	a0,a0,-1094 # 800074a8 <etext+0x4a8>
    800028f6:	c15fd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    800028fa:	00005517          	auipc	a0,0x5
    800028fe:	bd650513          	addi	a0,a0,-1066 # 800074d0 <etext+0x4d0>
    80002902:	f33fd0ef          	jal	80000834 <panic>
  if (which_dev == 2 && myproc() != 0)
    80002906:	9b0ff0ef          	jal	80001ab6 <myproc>
    8000290a:	d555                	beqz	a0,800028b6 <kerneltrap+0x36>
    yield();
    8000290c:	f88ff0ef          	jal	80002094 <yield>
    80002910:	b75d                	j	800028b6 <kerneltrap+0x36>

0000000080002912 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002912:	1101                	addi	sp,sp,-32
    80002914:	ec06                	sd	ra,24(sp)
    80002916:	e822                	sd	s0,16(sp)
    80002918:	e426                	sd	s1,8(sp)
    8000291a:	1000                	addi	s0,sp,32
    8000291c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000291e:	998ff0ef          	jal	80001ab6 <myproc>
  switch (n) {
    80002922:	4795                	li	a5,5
    80002924:	0497e163          	bltu	a5,s1,80002966 <argraw+0x54>
    80002928:	048a                	slli	s1,s1,0x2
    8000292a:	00005717          	auipc	a4,0x5
    8000292e:	fa670713          	addi	a4,a4,-90 # 800078d0 <states.0+0x30>
    80002932:	94ba                	add	s1,s1,a4
    80002934:	409c                	lw	a5,0(s1)
    80002936:	97ba                	add	a5,a5,a4
    80002938:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000293a:	6d3c                	ld	a5,88(a0)
    8000293c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000293e:	60e2                	ld	ra,24(sp)
    80002940:	6442                	ld	s0,16(sp)
    80002942:	64a2                	ld	s1,8(sp)
    80002944:	6105                	addi	sp,sp,32
    80002946:	8082                	ret
    return p->trapframe->a1;
    80002948:	6d3c                	ld	a5,88(a0)
    8000294a:	7fa8                	ld	a0,120(a5)
    8000294c:	bfcd                	j	8000293e <argraw+0x2c>
    return p->trapframe->a2;
    8000294e:	6d3c                	ld	a5,88(a0)
    80002950:	63c8                	ld	a0,128(a5)
    80002952:	b7f5                	j	8000293e <argraw+0x2c>
    return p->trapframe->a3;
    80002954:	6d3c                	ld	a5,88(a0)
    80002956:	67c8                	ld	a0,136(a5)
    80002958:	b7dd                	j	8000293e <argraw+0x2c>
    return p->trapframe->a4;
    8000295a:	6d3c                	ld	a5,88(a0)
    8000295c:	6bc8                	ld	a0,144(a5)
    8000295e:	b7c5                	j	8000293e <argraw+0x2c>
    return p->trapframe->a5;
    80002960:	6d3c                	ld	a5,88(a0)
    80002962:	6fc8                	ld	a0,152(a5)
    80002964:	bfe9                	j	8000293e <argraw+0x2c>
  panic("argraw");
    80002966:	00005517          	auipc	a0,0x5
    8000296a:	b7a50513          	addi	a0,a0,-1158 # 800074e0 <etext+0x4e0>
    8000296e:	ec7fd0ef          	jal	80000834 <panic>

0000000080002972 <fetchaddr>:
{
    80002972:	1101                	addi	sp,sp,-32
    80002974:	ec06                	sd	ra,24(sp)
    80002976:	e822                	sd	s0,16(sp)
    80002978:	e426                	sd	s1,8(sp)
    8000297a:	e04a                	sd	s2,0(sp)
    8000297c:	1000                	addi	s0,sp,32
    8000297e:	84aa                	mv	s1,a0
    80002980:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002982:	934ff0ef          	jal	80001ab6 <myproc>
  if (addr >= p->sz ||
    80002986:	652c                	ld	a1,72(a0)
    80002988:	02b4f663          	bgeu	s1,a1,800029b4 <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000298c:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    80002990:	02f5e463          	bltu	a1,a5,800029b8 <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    80002994:	4721                	li	a4,8
    80002996:	86a6                	mv	a3,s1
    80002998:	864a                	mv	a2,s2
    8000299a:	6928                	ld	a0,80(a0)
    8000299c:	cadfe0ef          	jal	80001648 <copyin>
    800029a0:	00a03533          	snez	a0,a0
    800029a4:	40a0053b          	negw	a0,a0
}
    800029a8:	60e2                	ld	ra,24(sp)
    800029aa:	6442                	ld	s0,16(sp)
    800029ac:	64a2                	ld	s1,8(sp)
    800029ae:	6902                	ld	s2,0(sp)
    800029b0:	6105                	addi	sp,sp,32
    800029b2:	8082                	ret
    return -1;
    800029b4:	557d                	li	a0,-1
    800029b6:	bfcd                	j	800029a8 <fetchaddr+0x36>
    800029b8:	557d                	li	a0,-1
    800029ba:	b7fd                	j	800029a8 <fetchaddr+0x36>

00000000800029bc <fetchstr>:
{
    800029bc:	7179                	addi	sp,sp,-48
    800029be:	f406                	sd	ra,40(sp)
    800029c0:	f022                	sd	s0,32(sp)
    800029c2:	ec26                	sd	s1,24(sp)
    800029c4:	e84a                	sd	s2,16(sp)
    800029c6:	e44e                	sd	s3,8(sp)
    800029c8:	1800                	addi	s0,sp,48
    800029ca:	89aa                	mv	s3,a0
    800029cc:	84ae                	mv	s1,a1
    800029ce:	8932                	mv	s2,a2
  struct proc *p = myproc();
    800029d0:	8e6ff0ef          	jal	80001ab6 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    800029d4:	874a                	mv	a4,s2
    800029d6:	86ce                	mv	a3,s3
    800029d8:	8626                	mv	a2,s1
    800029da:	652c                	ld	a1,72(a0)
    800029dc:	6928                	ld	a0,80(a0)
    800029de:	d07fe0ef          	jal	800016e4 <copyinstr>
    800029e2:	00054c63          	bltz	a0,800029fa <fetchstr+0x3e>
  return strlen(buf);
    800029e6:	8526                	mv	a0,s1
    800029e8:	c8afe0ef          	jal	80000e72 <strlen>
}
    800029ec:	70a2                	ld	ra,40(sp)
    800029ee:	7402                	ld	s0,32(sp)
    800029f0:	64e2                	ld	s1,24(sp)
    800029f2:	6942                	ld	s2,16(sp)
    800029f4:	69a2                	ld	s3,8(sp)
    800029f6:	6145                	addi	sp,sp,48
    800029f8:	8082                	ret
    return -1;
    800029fa:	557d                	li	a0,-1
    800029fc:	bfc5                	j	800029ec <fetchstr+0x30>

00000000800029fe <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800029fe:	1101                	addi	sp,sp,-32
    80002a00:	ec06                	sd	ra,24(sp)
    80002a02:	e822                	sd	s0,16(sp)
    80002a04:	e426                	sd	s1,8(sp)
    80002a06:	1000                	addi	s0,sp,32
    80002a08:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a0a:	f09ff0ef          	jal	80002912 <argraw>
    80002a0e:	c088                	sw	a0,0(s1)
}
    80002a10:	60e2                	ld	ra,24(sp)
    80002a12:	6442                	ld	s0,16(sp)
    80002a14:	64a2                	ld	s1,8(sp)
    80002a16:	6105                	addi	sp,sp,32
    80002a18:	8082                	ret

0000000080002a1a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002a1a:	1101                	addi	sp,sp,-32
    80002a1c:	ec06                	sd	ra,24(sp)
    80002a1e:	e822                	sd	s0,16(sp)
    80002a20:	e426                	sd	s1,8(sp)
    80002a22:	1000                	addi	s0,sp,32
    80002a24:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a26:	eedff0ef          	jal	80002912 <argraw>
    80002a2a:	e088                	sd	a0,0(s1)
}
    80002a2c:	60e2                	ld	ra,24(sp)
    80002a2e:	6442                	ld	s0,16(sp)
    80002a30:	64a2                	ld	s1,8(sp)
    80002a32:	6105                	addi	sp,sp,32
    80002a34:	8082                	ret

0000000080002a36 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002a36:	1101                	addi	sp,sp,-32
    80002a38:	ec06                	sd	ra,24(sp)
    80002a3a:	e822                	sd	s0,16(sp)
    80002a3c:	e426                	sd	s1,8(sp)
    80002a3e:	e04a                	sd	s2,0(sp)
    80002a40:	1000                	addi	s0,sp,32
    80002a42:	892e                	mv	s2,a1
    80002a44:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002a46:	ecdff0ef          	jal	80002912 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002a4a:	8626                	mv	a2,s1
    80002a4c:	85ca                	mv	a1,s2
    80002a4e:	f6fff0ef          	jal	800029bc <fetchstr>
}
    80002a52:	60e2                	ld	ra,24(sp)
    80002a54:	6442                	ld	s0,16(sp)
    80002a56:	64a2                	ld	s1,8(sp)
    80002a58:	6902                	ld	s2,0(sp)
    80002a5a:	6105                	addi	sp,sp,32
    80002a5c:	8082                	ret

0000000080002a5e <syscall>:
  // clang-format on
};

void
syscall(void)
{
    80002a5e:	1101                	addi	sp,sp,-32
    80002a60:	ec06                	sd	ra,24(sp)
    80002a62:	e822                	sd	s0,16(sp)
    80002a64:	e426                	sd	s1,8(sp)
    80002a66:	e04a                	sd	s2,0(sp)
    80002a68:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002a6a:	84cff0ef          	jal	80001ab6 <myproc>
    80002a6e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002a70:	05853903          	ld	s2,88(a0)
    80002a74:	0a893783          	ld	a5,168(s2)
    80002a78:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002a7c:	37fd                	addiw	a5,a5,-1
    80002a7e:	4759                	li	a4,22
    80002a80:	00f76f63          	bltu	a4,a5,80002a9e <syscall+0x40>
    80002a84:	00369713          	slli	a4,a3,0x3
    80002a88:	00005797          	auipc	a5,0x5
    80002a8c:	e6078793          	addi	a5,a5,-416 # 800078e8 <syscalls>
    80002a90:	97ba                	add	a5,a5,a4
    80002a92:	639c                	ld	a5,0(a5)
    80002a94:	c789                	beqz	a5,80002a9e <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002a96:	9782                	jalr	a5
    80002a98:	06a93823          	sd	a0,112(s2)
    80002a9c:	a829                	j	80002ab6 <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    80002a9e:	15848613          	addi	a2,s1,344
    80002aa2:	588c                	lw	a1,48(s1)
    80002aa4:	00005517          	auipc	a0,0x5
    80002aa8:	a4450513          	addi	a0,a0,-1468 # 800074e8 <etext+0x4e8>
    80002aac:	a5ffd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    80002ab0:	6cbc                	ld	a5,88(s1)
    80002ab2:	577d                	li	a4,-1
    80002ab4:	fbb8                	sd	a4,112(a5)
  }
}
    80002ab6:	60e2                	ld	ra,24(sp)
    80002ab8:	6442                	ld	s0,16(sp)
    80002aba:	64a2                	ld	s1,8(sp)
    80002abc:	6902                	ld	s2,0(sp)
    80002abe:	6105                	addi	sp,sp,32
    80002ac0:	8082                	ret

0000000080002ac2 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002ac2:	1101                	addi	sp,sp,-32
    80002ac4:	ec06                	sd	ra,24(sp)
    80002ac6:	e822                	sd	s0,16(sp)
    80002ac8:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002aca:	fec40593          	addi	a1,s0,-20
    80002ace:	4501                	li	a0,0
    80002ad0:	f2fff0ef          	jal	800029fe <argint>
  kexit(n);
    80002ad4:	fec42503          	lw	a0,-20(s0)
    80002ad8:	f10ff0ef          	jal	800021e8 <kexit>
  return 0; // not reached
}
    80002adc:	4501                	li	a0,0
    80002ade:	60e2                	ld	ra,24(sp)
    80002ae0:	6442                	ld	s0,16(sp)
    80002ae2:	6105                	addi	sp,sp,32
    80002ae4:	8082                	ret

0000000080002ae6 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ae6:	1141                	addi	sp,sp,-16
    80002ae8:	e406                	sd	ra,8(sp)
    80002aea:	e022                	sd	s0,0(sp)
    80002aec:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002aee:	fc9fe0ef          	jal	80001ab6 <myproc>
}
    80002af2:	5908                	lw	a0,48(a0)
    80002af4:	60a2                	ld	ra,8(sp)
    80002af6:	6402                	ld	s0,0(sp)
    80002af8:	0141                	addi	sp,sp,16
    80002afa:	8082                	ret

0000000080002afc <sys_fork>:

uint64
sys_fork(void)
{
    80002afc:	1141                	addi	sp,sp,-16
    80002afe:	e406                	sd	ra,8(sp)
    80002b00:	e022                	sd	s0,0(sp)
    80002b02:	0800                	addi	s0,sp,16
  return kfork();
    80002b04:	b12ff0ef          	jal	80001e16 <kfork>
}
    80002b08:	60a2                	ld	ra,8(sp)
    80002b0a:	6402                	ld	s0,0(sp)
    80002b0c:	0141                	addi	sp,sp,16
    80002b0e:	8082                	ret

0000000080002b10 <sys_wait>:

uint64
sys_wait(void)
{
    80002b10:	1101                	addi	sp,sp,-32
    80002b12:	ec06                	sd	ra,24(sp)
    80002b14:	e822                	sd	s0,16(sp)
    80002b16:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002b18:	fe840593          	addi	a1,s0,-24
    80002b1c:	4501                	li	a0,0
    80002b1e:	efdff0ef          	jal	80002a1a <argaddr>
  return kwait(p);
    80002b22:	fe843503          	ld	a0,-24(s0)
    80002b26:	823ff0ef          	jal	80002348 <kwait>
}
    80002b2a:	60e2                	ld	ra,24(sp)
    80002b2c:	6442                	ld	s0,16(sp)
    80002b2e:	6105                	addi	sp,sp,32
    80002b30:	8082                	ret

0000000080002b32 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002b32:	7179                	addi	sp,sp,-48
    80002b34:	f406                	sd	ra,40(sp)
    80002b36:	f022                	sd	s0,32(sp)
    80002b38:	ec26                	sd	s1,24(sp)
    80002b3a:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002b3c:	fd840593          	addi	a1,s0,-40
    80002b40:	4501                	li	a0,0
    80002b42:	ebdff0ef          	jal	800029fe <argint>
  argint(1, &t);
    80002b46:	fdc40593          	addi	a1,s0,-36
    80002b4a:	4505                	li	a0,1
    80002b4c:	eb3ff0ef          	jal	800029fe <argint>
  addr = myproc()->sz;
    80002b50:	f67fe0ef          	jal	80001ab6 <myproc>
    80002b54:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002b56:	fdc42703          	lw	a4,-36(s0)
    80002b5a:	4785                	li	a5,1
    80002b5c:	02f70763          	beq	a4,a5,80002b8a <sys_sbrk+0x58>
    80002b60:	fd842783          	lw	a5,-40(s0)
    80002b64:	0207c363          	bltz	a5,80002b8a <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002b68:	97a6                	add	a5,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    80002b6a:	02000737          	lui	a4,0x2000
    80002b6e:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002b70:	0736                	slli	a4,a4,0xd
    80002b72:	02f76a63          	bltu	a4,a5,80002ba6 <sys_sbrk+0x74>
    80002b76:	0297e863          	bltu	a5,s1,80002ba6 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002b7a:	f3dfe0ef          	jal	80001ab6 <myproc>
    80002b7e:	fd842703          	lw	a4,-40(s0)
    80002b82:	653c                	ld	a5,72(a0)
    80002b84:	97ba                	add	a5,a5,a4
    80002b86:	e53c                	sd	a5,72(a0)
    80002b88:	a039                	j	80002b96 <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002b8a:	fd842503          	lw	a0,-40(s0)
    80002b8e:	a26ff0ef          	jal	80001db4 <growproc>
    80002b92:	00054863          	bltz	a0,80002ba2 <sys_sbrk+0x70>
  }
  return addr;
}
    80002b96:	8526                	mv	a0,s1
    80002b98:	70a2                	ld	ra,40(sp)
    80002b9a:	7402                	ld	s0,32(sp)
    80002b9c:	64e2                	ld	s1,24(sp)
    80002b9e:	6145                	addi	sp,sp,48
    80002ba0:	8082                	ret
      return -1;
    80002ba2:	54fd                	li	s1,-1
    80002ba4:	bfcd                	j	80002b96 <sys_sbrk+0x64>
      return -1;
    80002ba6:	54fd                	li	s1,-1
    80002ba8:	b7fd                	j	80002b96 <sys_sbrk+0x64>

0000000080002baa <sys_pause>:

uint64
sys_pause(void)
{
    80002baa:	7139                	addi	sp,sp,-64
    80002bac:	fc06                	sd	ra,56(sp)
    80002bae:	f822                	sd	s0,48(sp)
    80002bb0:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002bb2:	fcc40593          	addi	a1,s0,-52
    80002bb6:	4501                	li	a0,0
    80002bb8:	e47ff0ef          	jal	800029fe <argint>
  if (n < 0)
    80002bbc:	fcc42783          	lw	a5,-52(s0)
    80002bc0:	0807c063          	bltz	a5,80002c40 <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002bc4:	00016517          	auipc	a0,0x16
    80002bc8:	84450513          	addi	a0,a0,-1980 # 80018408 <tickslock>
    80002bcc:	85cfe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002bd0:	fcc42783          	lw	a5,-52(s0)
    80002bd4:	cbb9                	beqz	a5,80002c2a <sys_pause+0x80>
    80002bd6:	f426                	sd	s1,40(sp)
    80002bd8:	f04a                	sd	s2,32(sp)
    80002bda:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002bdc:	00008997          	auipc	s3,0x8
    80002be0:	8fc9a983          	lw	s3,-1796(s3) # 8000a4d8 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002be4:	00008917          	auipc	s2,0x8
    80002be8:	8f490913          	addi	s2,s2,-1804 # 8000a4d8 <ticks>
    release(&tickslock);
    80002bec:	00016497          	auipc	s1,0x16
    80002bf0:	81c48493          	addi	s1,s1,-2020 # 80018408 <tickslock>
    if (killed(myproc())) {
    80002bf4:	ec3fe0ef          	jal	80001ab6 <myproc>
    80002bf8:	f26ff0ef          	jal	8000231e <killed>
    80002bfc:	e529                	bnez	a0,80002c46 <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002bfe:	854a                	mv	a0,s2
    80002c00:	cc0ff0ef          	jal	800020c0 <sleep_prepare>
    release(&tickslock);
    80002c04:	8526                	mv	a0,s1
    80002c06:	8aafe0ef          	jal	80000cb0 <release>
    sleep();
    80002c0a:	cf2ff0ef          	jal	800020fc <sleep>
    acquire(&tickslock);
    80002c0e:	8526                	mv	a0,s1
    80002c10:	818fe0ef          	jal	80000c28 <acquire>
  while (ticks - ticks0 < n) {
    80002c14:	00092783          	lw	a5,0(s2)
    80002c18:	413787bb          	subw	a5,a5,s3
    80002c1c:	fcc42703          	lw	a4,-52(s0)
    80002c20:	fce7eae3          	bltu	a5,a4,80002bf4 <sys_pause+0x4a>
    80002c24:	74a2                	ld	s1,40(sp)
    80002c26:	7902                	ld	s2,32(sp)
    80002c28:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002c2a:	00015517          	auipc	a0,0x15
    80002c2e:	7de50513          	addi	a0,a0,2014 # 80018408 <tickslock>
    80002c32:	87efe0ef          	jal	80000cb0 <release>
  return 0;
    80002c36:	4501                	li	a0,0
}
    80002c38:	70e2                	ld	ra,56(sp)
    80002c3a:	7442                	ld	s0,48(sp)
    80002c3c:	6121                	addi	sp,sp,64
    80002c3e:	8082                	ret
    n = 0;
    80002c40:	fc042623          	sw	zero,-52(s0)
    80002c44:	b741                	j	80002bc4 <sys_pause+0x1a>
      release(&tickslock);
    80002c46:	00015517          	auipc	a0,0x15
    80002c4a:	7c250513          	addi	a0,a0,1986 # 80018408 <tickslock>
    80002c4e:	862fe0ef          	jal	80000cb0 <release>
      return -1;
    80002c52:	557d                	li	a0,-1
    80002c54:	74a2                	ld	s1,40(sp)
    80002c56:	7902                	ld	s2,32(sp)
    80002c58:	69e2                	ld	s3,24(sp)
    80002c5a:	bff9                	j	80002c38 <sys_pause+0x8e>

0000000080002c5c <sys_kill>:

uint64
sys_kill(void)
{
    80002c5c:	1101                	addi	sp,sp,-32
    80002c5e:	ec06                	sd	ra,24(sp)
    80002c60:	e822                	sd	s0,16(sp)
    80002c62:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002c64:	fec40593          	addi	a1,s0,-20
    80002c68:	4501                	li	a0,0
    80002c6a:	d95ff0ef          	jal	800029fe <argint>
  return kkill(pid);
    80002c6e:	fec42503          	lw	a0,-20(s0)
    80002c72:	e1cff0ef          	jal	8000228e <kkill>
}
    80002c76:	60e2                	ld	ra,24(sp)
    80002c78:	6442                	ld	s0,16(sp)
    80002c7a:	6105                	addi	sp,sp,32
    80002c7c:	8082                	ret

0000000080002c7e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002c7e:	1101                	addi	sp,sp,-32
    80002c80:	ec06                	sd	ra,24(sp)
    80002c82:	e822                	sd	s0,16(sp)
    80002c84:	e426                	sd	s1,8(sp)
    80002c86:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002c88:	00015517          	auipc	a0,0x15
    80002c8c:	78050513          	addi	a0,a0,1920 # 80018408 <tickslock>
    80002c90:	f99fd0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002c94:	00008797          	auipc	a5,0x8
    80002c98:	8447a783          	lw	a5,-1980(a5) # 8000a4d8 <ticks>
    80002c9c:	84be                	mv	s1,a5
  release(&tickslock);
    80002c9e:	00015517          	auipc	a0,0x15
    80002ca2:	76a50513          	addi	a0,a0,1898 # 80018408 <tickslock>
    80002ca6:	80afe0ef          	jal	80000cb0 <release>
  return xticks;
}
    80002caa:	02049513          	slli	a0,s1,0x20
    80002cae:	9101                	srli	a0,a0,0x20
    80002cb0:	60e2                	ld	ra,24(sp)
    80002cb2:	6442                	ld	s0,16(sp)
    80002cb4:	64a2                	ld	s1,8(sp)
    80002cb6:	6105                	addi	sp,sp,32
    80002cb8:	8082                	ret

0000000080002cba <sys_vmprint>:

uint64
sys_vmprint(void)
{
    80002cba:	1141                	addi	sp,sp,-16
    80002cbc:	e406                	sd	ra,8(sp)
    80002cbe:	e022                	sd	s0,0(sp)
    80002cc0:	0800                	addi	s0,sp,16
  return vmprint();
    80002cc2:	af9fe0ef          	jal	800017ba <vmprint>
}
    80002cc6:	60a2                	ld	ra,8(sp)
    80002cc8:	6402                	ld	s0,0(sp)
    80002cca:	0141                	addi	sp,sp,16
    80002ccc:	8082                	ret

0000000080002cce <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002cce:	7179                	addi	sp,sp,-48
    80002cd0:	f406                	sd	ra,40(sp)
    80002cd2:	f022                	sd	s0,32(sp)
    80002cd4:	ec26                	sd	s1,24(sp)
    80002cd6:	e84a                	sd	s2,16(sp)
    80002cd8:	e44e                	sd	s3,8(sp)
    80002cda:	e052                	sd	s4,0(sp)
    80002cdc:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002cde:	00005597          	auipc	a1,0x5
    80002ce2:	82a58593          	addi	a1,a1,-2006 # 80007508 <etext+0x508>
    80002ce6:	00015517          	auipc	a0,0x15
    80002cea:	73a50513          	addi	a0,a0,1850 # 80018420 <bcache>
    80002cee:	ebbfd0ef          	jal	80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002cf2:	0001d797          	auipc	a5,0x1d
    80002cf6:	72e78793          	addi	a5,a5,1838 # 80020420 <bcache+0x8000>
    80002cfa:	0001e717          	auipc	a4,0x1e
    80002cfe:	98e70713          	addi	a4,a4,-1650 # 80020688 <bcache+0x8268>
    80002d02:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002d06:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002d0a:	00015497          	auipc	s1,0x15
    80002d0e:	72e48493          	addi	s1,s1,1838 # 80018438 <bcache+0x18>
    b->next = bcache.head.next;
    80002d12:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002d14:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002d16:	00004a17          	auipc	s4,0x4
    80002d1a:	7faa0a13          	addi	s4,s4,2042 # 80007510 <etext+0x510>
    b->next = bcache.head.next;
    80002d1e:	2b893783          	ld	a5,696(s2)
    80002d22:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002d24:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002d28:	85d2                	mv	a1,s4
    80002d2a:	01048513          	addi	a0,s1,16
    80002d2e:	41c010ef          	jal	8000414a <initsleeplock>
    bcache.head.next->prev = b;
    80002d32:	2b893783          	ld	a5,696(s2)
    80002d36:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002d38:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002d3c:	45848493          	addi	s1,s1,1112
    80002d40:	fd349fe3          	bne	s1,s3,80002d1e <binit+0x50>
  }
}
    80002d44:	70a2                	ld	ra,40(sp)
    80002d46:	7402                	ld	s0,32(sp)
    80002d48:	64e2                	ld	s1,24(sp)
    80002d4a:	6942                	ld	s2,16(sp)
    80002d4c:	69a2                	ld	s3,8(sp)
    80002d4e:	6a02                	ld	s4,0(sp)
    80002d50:	6145                	addi	sp,sp,48
    80002d52:	8082                	ret

0000000080002d54 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002d54:	7179                	addi	sp,sp,-48
    80002d56:	f406                	sd	ra,40(sp)
    80002d58:	f022                	sd	s0,32(sp)
    80002d5a:	ec26                	sd	s1,24(sp)
    80002d5c:	e84a                	sd	s2,16(sp)
    80002d5e:	e44e                	sd	s3,8(sp)
    80002d60:	1800                	addi	s0,sp,48
    80002d62:	892a                	mv	s2,a0
    80002d64:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002d66:	00015517          	auipc	a0,0x15
    80002d6a:	6ba50513          	addi	a0,a0,1722 # 80018420 <bcache>
    80002d6e:	ebbfd0ef          	jal	80000c28 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002d72:	0001e497          	auipc	s1,0x1e
    80002d76:	9664b483          	ld	s1,-1690(s1) # 800206d8 <bcache+0x82b8>
    80002d7a:	0001e797          	auipc	a5,0x1e
    80002d7e:	90e78793          	addi	a5,a5,-1778 # 80020688 <bcache+0x8268>
    80002d82:	02f48b63          	beq	s1,a5,80002db8 <bread+0x64>
    80002d86:	873e                	mv	a4,a5
    80002d88:	a021                	j	80002d90 <bread+0x3c>
    80002d8a:	68a4                	ld	s1,80(s1)
    80002d8c:	02e48663          	beq	s1,a4,80002db8 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002d90:	449c                	lw	a5,8(s1)
    80002d92:	ff279ce3          	bne	a5,s2,80002d8a <bread+0x36>
    80002d96:	44dc                	lw	a5,12(s1)
    80002d98:	ff3799e3          	bne	a5,s3,80002d8a <bread+0x36>
      b->refcnt++;
    80002d9c:	40bc                	lw	a5,64(s1)
    80002d9e:	2785                	addiw	a5,a5,1
    80002da0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002da2:	00015517          	auipc	a0,0x15
    80002da6:	67e50513          	addi	a0,a0,1662 # 80018420 <bcache>
    80002daa:	f07fd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002dae:	01048513          	addi	a0,s1,16
    80002db2:	3ce010ef          	jal	80004180 <acquiresleep>
      return b;
    80002db6:	a889                	j	80002e08 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002db8:	0001e497          	auipc	s1,0x1e
    80002dbc:	9184b483          	ld	s1,-1768(s1) # 800206d0 <bcache+0x82b0>
    80002dc0:	0001e797          	auipc	a5,0x1e
    80002dc4:	8c878793          	addi	a5,a5,-1848 # 80020688 <bcache+0x8268>
    80002dc8:	00f48863          	beq	s1,a5,80002dd8 <bread+0x84>
    80002dcc:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002dce:	40bc                	lw	a5,64(s1)
    80002dd0:	cb91                	beqz	a5,80002de4 <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002dd2:	64a4                	ld	s1,72(s1)
    80002dd4:	fee49de3          	bne	s1,a4,80002dce <bread+0x7a>
  panic("bget: no buffers");
    80002dd8:	00004517          	auipc	a0,0x4
    80002ddc:	74050513          	addi	a0,a0,1856 # 80007518 <etext+0x518>
    80002de0:	a55fd0ef          	jal	80000834 <panic>
      b->dev = dev;
    80002de4:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002de8:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002dec:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002df0:	4785                	li	a5,1
    80002df2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002df4:	00015517          	auipc	a0,0x15
    80002df8:	62c50513          	addi	a0,a0,1580 # 80018420 <bcache>
    80002dfc:	eb5fd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002e00:	01048513          	addi	a0,s1,16
    80002e04:	37c010ef          	jal	80004180 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002e08:	409c                	lw	a5,0(s1)
    80002e0a:	cb89                	beqz	a5,80002e1c <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002e0c:	8526                	mv	a0,s1
    80002e0e:	70a2                	ld	ra,40(sp)
    80002e10:	7402                	ld	s0,32(sp)
    80002e12:	64e2                	ld	s1,24(sp)
    80002e14:	6942                	ld	s2,16(sp)
    80002e16:	69a2                	ld	s3,8(sp)
    80002e18:	6145                	addi	sp,sp,48
    80002e1a:	8082                	ret
    virtio_disk_rw(b, 0);
    80002e1c:	4581                	li	a1,0
    80002e1e:	8526                	mv	a0,s1
    80002e20:	4c7020ef          	jal	80005ae6 <virtio_disk_rw>
    b->valid = 1;
    80002e24:	4785                	li	a5,1
    80002e26:	c09c                	sw	a5,0(s1)
  return b;
    80002e28:	b7d5                	j	80002e0c <bread+0xb8>

0000000080002e2a <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002e2a:	1101                	addi	sp,sp,-32
    80002e2c:	ec06                	sd	ra,24(sp)
    80002e2e:	e822                	sd	s0,16(sp)
    80002e30:	e426                	sd	s1,8(sp)
    80002e32:	1000                	addi	s0,sp,32
    80002e34:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002e36:	0541                	addi	a0,a0,16
    80002e38:	3d4010ef          	jal	8000420c <holdingsleep>
    80002e3c:	c911                	beqz	a0,80002e50 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002e3e:	4585                	li	a1,1
    80002e40:	8526                	mv	a0,s1
    80002e42:	4a5020ef          	jal	80005ae6 <virtio_disk_rw>
}
    80002e46:	60e2                	ld	ra,24(sp)
    80002e48:	6442                	ld	s0,16(sp)
    80002e4a:	64a2                	ld	s1,8(sp)
    80002e4c:	6105                	addi	sp,sp,32
    80002e4e:	8082                	ret
    panic("bwrite");
    80002e50:	00004517          	auipc	a0,0x4
    80002e54:	6e050513          	addi	a0,a0,1760 # 80007530 <etext+0x530>
    80002e58:	9ddfd0ef          	jal	80000834 <panic>

0000000080002e5c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002e5c:	1101                	addi	sp,sp,-32
    80002e5e:	ec06                	sd	ra,24(sp)
    80002e60:	e822                	sd	s0,16(sp)
    80002e62:	e426                	sd	s1,8(sp)
    80002e64:	e04a                	sd	s2,0(sp)
    80002e66:	1000                	addi	s0,sp,32
    80002e68:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002e6a:	01050913          	addi	s2,a0,16
    80002e6e:	854a                	mv	a0,s2
    80002e70:	39c010ef          	jal	8000420c <holdingsleep>
    80002e74:	c125                	beqz	a0,80002ed4 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002e76:	854a                	mv	a0,s2
    80002e78:	35c010ef          	jal	800041d4 <releasesleep>

  acquire(&bcache.lock);
    80002e7c:	00015517          	auipc	a0,0x15
    80002e80:	5a450513          	addi	a0,a0,1444 # 80018420 <bcache>
    80002e84:	da5fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002e88:	40bc                	lw	a5,64(s1)
    80002e8a:	37fd                	addiw	a5,a5,-1
    80002e8c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002e8e:	e79d                	bnez	a5,80002ebc <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002e90:	68b8                	ld	a4,80(s1)
    80002e92:	64bc                	ld	a5,72(s1)
    80002e94:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002e96:	68b8                	ld	a4,80(s1)
    80002e98:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002e9a:	0001d797          	auipc	a5,0x1d
    80002e9e:	58678793          	addi	a5,a5,1414 # 80020420 <bcache+0x8000>
    80002ea2:	2b87b703          	ld	a4,696(a5)
    80002ea6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002ea8:	0001d717          	auipc	a4,0x1d
    80002eac:	7e070713          	addi	a4,a4,2016 # 80020688 <bcache+0x8268>
    80002eb0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002eb2:	2b87b703          	ld	a4,696(a5)
    80002eb6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002eb8:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002ebc:	00015517          	auipc	a0,0x15
    80002ec0:	56450513          	addi	a0,a0,1380 # 80018420 <bcache>
    80002ec4:	dedfd0ef          	jal	80000cb0 <release>
}
    80002ec8:	60e2                	ld	ra,24(sp)
    80002eca:	6442                	ld	s0,16(sp)
    80002ecc:	64a2                	ld	s1,8(sp)
    80002ece:	6902                	ld	s2,0(sp)
    80002ed0:	6105                	addi	sp,sp,32
    80002ed2:	8082                	ret
    panic("brelse");
    80002ed4:	00004517          	auipc	a0,0x4
    80002ed8:	66450513          	addi	a0,a0,1636 # 80007538 <etext+0x538>
    80002edc:	959fd0ef          	jal	80000834 <panic>

0000000080002ee0 <bpin>:

void
bpin(struct buf *b)
{
    80002ee0:	1101                	addi	sp,sp,-32
    80002ee2:	ec06                	sd	ra,24(sp)
    80002ee4:	e822                	sd	s0,16(sp)
    80002ee6:	e426                	sd	s1,8(sp)
    80002ee8:	1000                	addi	s0,sp,32
    80002eea:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002eec:	00015517          	auipc	a0,0x15
    80002ef0:	53450513          	addi	a0,a0,1332 # 80018420 <bcache>
    80002ef4:	d35fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002ef8:	40bc                	lw	a5,64(s1)
    80002efa:	2785                	addiw	a5,a5,1
    80002efc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002efe:	00015517          	auipc	a0,0x15
    80002f02:	52250513          	addi	a0,a0,1314 # 80018420 <bcache>
    80002f06:	dabfd0ef          	jal	80000cb0 <release>
}
    80002f0a:	60e2                	ld	ra,24(sp)
    80002f0c:	6442                	ld	s0,16(sp)
    80002f0e:	64a2                	ld	s1,8(sp)
    80002f10:	6105                	addi	sp,sp,32
    80002f12:	8082                	ret

0000000080002f14 <bunpin>:

void
bunpin(struct buf *b)
{
    80002f14:	1101                	addi	sp,sp,-32
    80002f16:	ec06                	sd	ra,24(sp)
    80002f18:	e822                	sd	s0,16(sp)
    80002f1a:	e426                	sd	s1,8(sp)
    80002f1c:	1000                	addi	s0,sp,32
    80002f1e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f20:	00015517          	auipc	a0,0x15
    80002f24:	50050513          	addi	a0,a0,1280 # 80018420 <bcache>
    80002f28:	d01fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002f2c:	40bc                	lw	a5,64(s1)
    80002f2e:	37fd                	addiw	a5,a5,-1
    80002f30:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f32:	00015517          	auipc	a0,0x15
    80002f36:	4ee50513          	addi	a0,a0,1262 # 80018420 <bcache>
    80002f3a:	d77fd0ef          	jal	80000cb0 <release>
}
    80002f3e:	60e2                	ld	ra,24(sp)
    80002f40:	6442                	ld	s0,16(sp)
    80002f42:	64a2                	ld	s1,8(sp)
    80002f44:	6105                	addi	sp,sp,32
    80002f46:	8082                	ret

0000000080002f48 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002f48:	1101                	addi	sp,sp,-32
    80002f4a:	ec06                	sd	ra,24(sp)
    80002f4c:	e822                	sd	s0,16(sp)
    80002f4e:	e426                	sd	s1,8(sp)
    80002f50:	e04a                	sd	s2,0(sp)
    80002f52:	1000                	addi	s0,sp,32
    80002f54:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002f56:	00d5d79b          	srliw	a5,a1,0xd
    80002f5a:	0001e597          	auipc	a1,0x1e
    80002f5e:	ba25a583          	lw	a1,-1118(a1) # 80020afc <sb+0x1c>
    80002f62:	9dbd                	addw	a1,a1,a5
    80002f64:	df1ff0ef          	jal	80002d54 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002f68:	0074f713          	andi	a4,s1,7
    80002f6c:	4785                	li	a5,1
    80002f6e:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002f72:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80002f74:	90d9                	srli	s1,s1,0x36
    80002f76:	00950733          	add	a4,a0,s1
    80002f7a:	05874703          	lbu	a4,88(a4)
    80002f7e:	00e7f6b3          	and	a3,a5,a4
    80002f82:	c29d                	beqz	a3,80002fa8 <bfree+0x60>
    80002f84:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002f86:	94aa                	add	s1,s1,a0
    80002f88:	fff7c793          	not	a5,a5
    80002f8c:	8f7d                	and	a4,a4,a5
    80002f8e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002f92:	080010ef          	jal	80004012 <log_write>
  brelse(bp);
    80002f96:	854a                	mv	a0,s2
    80002f98:	ec5ff0ef          	jal	80002e5c <brelse>
}
    80002f9c:	60e2                	ld	ra,24(sp)
    80002f9e:	6442                	ld	s0,16(sp)
    80002fa0:	64a2                	ld	s1,8(sp)
    80002fa2:	6902                	ld	s2,0(sp)
    80002fa4:	6105                	addi	sp,sp,32
    80002fa6:	8082                	ret
    panic("freeing free block");
    80002fa8:	00004517          	auipc	a0,0x4
    80002fac:	59850513          	addi	a0,a0,1432 # 80007540 <etext+0x540>
    80002fb0:	885fd0ef          	jal	80000834 <panic>

0000000080002fb4 <balloc>:
{
    80002fb4:	715d                	addi	sp,sp,-80
    80002fb6:	e486                	sd	ra,72(sp)
    80002fb8:	e0a2                	sd	s0,64(sp)
    80002fba:	fc26                	sd	s1,56(sp)
    80002fbc:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80002fbe:	0001e797          	auipc	a5,0x1e
    80002fc2:	b267a783          	lw	a5,-1242(a5) # 80020ae4 <sb+0x4>
    80002fc6:	0e078263          	beqz	a5,800030aa <balloc+0xf6>
    80002fca:	f84a                	sd	s2,48(sp)
    80002fcc:	f44e                	sd	s3,40(sp)
    80002fce:	f052                	sd	s4,32(sp)
    80002fd0:	ec56                	sd	s5,24(sp)
    80002fd2:	e85a                	sd	s6,16(sp)
    80002fd4:	e45e                	sd	s7,8(sp)
    80002fd6:	e062                	sd	s8,0(sp)
    80002fd8:	8baa                	mv	s7,a0
    80002fda:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002fdc:	0001eb17          	auipc	s6,0x1e
    80002fe0:	b04b0b13          	addi	s6,s6,-1276 # 80020ae0 <sb>
      m = 1 << (bi % 8);
    80002fe4:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002fe6:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80002fe8:	6c09                	lui	s8,0x2
    80002fea:	a09d                	j	80003050 <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80002fec:	97ca                	add	a5,a5,s2
    80002fee:	8e55                	or	a2,a2,a3
    80002ff0:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002ff4:	854a                	mv	a0,s2
    80002ff6:	01c010ef          	jal	80004012 <log_write>
        brelse(bp);
    80002ffa:	854a                	mv	a0,s2
    80002ffc:	e61ff0ef          	jal	80002e5c <brelse>
  bp = bread(dev, bno);
    80003000:	85a6                	mv	a1,s1
    80003002:	855e                	mv	a0,s7
    80003004:	d51ff0ef          	jal	80002d54 <bread>
    80003008:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000300a:	40000613          	li	a2,1024
    8000300e:	4581                	li	a1,0
    80003010:	05850513          	addi	a0,a0,88
    80003014:	cd5fd0ef          	jal	80000ce8 <memset>
  log_write(bp);
    80003018:	854a                	mv	a0,s2
    8000301a:	7f9000ef          	jal	80004012 <log_write>
  brelse(bp);
    8000301e:	854a                	mv	a0,s2
    80003020:	e3dff0ef          	jal	80002e5c <brelse>
}
    80003024:	7942                	ld	s2,48(sp)
    80003026:	79a2                	ld	s3,40(sp)
    80003028:	7a02                	ld	s4,32(sp)
    8000302a:	6ae2                	ld	s5,24(sp)
    8000302c:	6b42                	ld	s6,16(sp)
    8000302e:	6ba2                	ld	s7,8(sp)
    80003030:	6c02                	ld	s8,0(sp)
}
    80003032:	8526                	mv	a0,s1
    80003034:	60a6                	ld	ra,72(sp)
    80003036:	6406                	ld	s0,64(sp)
    80003038:	74e2                	ld	s1,56(sp)
    8000303a:	6161                	addi	sp,sp,80
    8000303c:	8082                	ret
    brelse(bp);
    8000303e:	854a                	mv	a0,s2
    80003040:	e1dff0ef          	jal	80002e5c <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80003044:	015c0abb          	addw	s5,s8,s5
    80003048:	004b2783          	lw	a5,4(s6)
    8000304c:	04faf863          	bgeu	s5,a5,8000309c <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80003050:	40dad59b          	sraiw	a1,s5,0xd
    80003054:	01cb2783          	lw	a5,28(s6)
    80003058:	9dbd                	addw	a1,a1,a5
    8000305a:	855e                	mv	a0,s7
    8000305c:	cf9ff0ef          	jal	80002d54 <bread>
    80003060:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003062:	004b2503          	lw	a0,4(s6)
    80003066:	84d6                	mv	s1,s5
    80003068:	4701                	li	a4,0
    8000306a:	fca4fae3          	bgeu	s1,a0,8000303e <balloc+0x8a>
      m = 1 << (bi % 8);
    8000306e:	00777693          	andi	a3,a4,7
    80003072:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80003076:	41f7579b          	sraiw	a5,a4,0x1f
    8000307a:	01d7d79b          	srliw	a5,a5,0x1d
    8000307e:	9fb9                	addw	a5,a5,a4
    80003080:	4037d79b          	sraiw	a5,a5,0x3
    80003084:	00f90633          	add	a2,s2,a5
    80003088:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    8000308c:	00c6f5b3          	and	a1,a3,a2
    80003090:	ddb1                	beqz	a1,80002fec <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003092:	2705                	addiw	a4,a4,1
    80003094:	2485                	addiw	s1,s1,1
    80003096:	fd471ae3          	bne	a4,s4,8000306a <balloc+0xb6>
    8000309a:	b755                	j	8000303e <balloc+0x8a>
    8000309c:	7942                	ld	s2,48(sp)
    8000309e:	79a2                	ld	s3,40(sp)
    800030a0:	7a02                	ld	s4,32(sp)
    800030a2:	6ae2                	ld	s5,24(sp)
    800030a4:	6b42                	ld	s6,16(sp)
    800030a6:	6ba2                	ld	s7,8(sp)
    800030a8:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    800030aa:	00004517          	auipc	a0,0x4
    800030ae:	4ae50513          	addi	a0,a0,1198 # 80007558 <etext+0x558>
    800030b2:	c58fd0ef          	jal	8000050a <printk>
  return 0;
    800030b6:	4481                	li	s1,0
    800030b8:	bfad                	j	80003032 <balloc+0x7e>

00000000800030ba <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800030ba:	7179                	addi	sp,sp,-48
    800030bc:	f406                	sd	ra,40(sp)
    800030be:	f022                	sd	s0,32(sp)
    800030c0:	ec26                	sd	s1,24(sp)
    800030c2:	e84a                	sd	s2,16(sp)
    800030c4:	e44e                	sd	s3,8(sp)
    800030c6:	1800                	addi	s0,sp,48
    800030c8:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    800030ca:	47ad                	li	a5,11
    800030cc:	02b7e363          	bltu	a5,a1,800030f2 <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    800030d0:	02059793          	slli	a5,a1,0x20
    800030d4:	01e7d593          	srli	a1,a5,0x1e
    800030d8:	00b509b3          	add	s3,a0,a1
    800030dc:	0509a483          	lw	s1,80(s3)
    800030e0:	e0b5                	bnez	s1,80003144 <bmap+0x8a>
      addr = balloc(ip->dev);
    800030e2:	4108                	lw	a0,0(a0)
    800030e4:	ed1ff0ef          	jal	80002fb4 <balloc>
    800030e8:	84aa                	mv	s1,a0
      if (addr == 0)
    800030ea:	cd29                	beqz	a0,80003144 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    800030ec:	04a9a823          	sw	a0,80(s3)
    800030f0:	a891                	j	80003144 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800030f2:	ff45879b          	addiw	a5,a1,-12
    800030f6:	873e                	mv	a4,a5
    800030f8:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    800030fa:	0ff00793          	li	a5,255
    800030fe:	06e7e763          	bltu	a5,a4,8000316c <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    80003102:	08052483          	lw	s1,128(a0)
    80003106:	e891                	bnez	s1,8000311a <bmap+0x60>
      addr = balloc(ip->dev);
    80003108:	4108                	lw	a0,0(a0)
    8000310a:	eabff0ef          	jal	80002fb4 <balloc>
    8000310e:	84aa                	mv	s1,a0
      if (addr == 0)
    80003110:	c915                	beqz	a0,80003144 <bmap+0x8a>
    80003112:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003114:	08a92023          	sw	a0,128(s2)
    80003118:	a011                	j	8000311c <bmap+0x62>
    8000311a:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000311c:	85a6                	mv	a1,s1
    8000311e:	00092503          	lw	a0,0(s2)
    80003122:	c33ff0ef          	jal	80002d54 <bread>
    80003126:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80003128:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    8000312c:	02099713          	slli	a4,s3,0x20
    80003130:	01e75593          	srli	a1,a4,0x1e
    80003134:	97ae                	add	a5,a5,a1
    80003136:	89be                	mv	s3,a5
    80003138:	4384                	lw	s1,0(a5)
    8000313a:	cc89                	beqz	s1,80003154 <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000313c:	8552                	mv	a0,s4
    8000313e:	d1fff0ef          	jal	80002e5c <brelse>
    return addr;
    80003142:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003144:	8526                	mv	a0,s1
    80003146:	70a2                	ld	ra,40(sp)
    80003148:	7402                	ld	s0,32(sp)
    8000314a:	64e2                	ld	s1,24(sp)
    8000314c:	6942                	ld	s2,16(sp)
    8000314e:	69a2                	ld	s3,8(sp)
    80003150:	6145                	addi	sp,sp,48
    80003152:	8082                	ret
      addr = balloc(ip->dev);
    80003154:	00092503          	lw	a0,0(s2)
    80003158:	e5dff0ef          	jal	80002fb4 <balloc>
    8000315c:	84aa                	mv	s1,a0
      if (addr) {
    8000315e:	dd79                	beqz	a0,8000313c <bmap+0x82>
        a[bn] = addr;
    80003160:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80003164:	8552                	mv	a0,s4
    80003166:	6ad000ef          	jal	80004012 <log_write>
    8000316a:	bfc9                	j	8000313c <bmap+0x82>
    8000316c:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000316e:	00004517          	auipc	a0,0x4
    80003172:	40250513          	addi	a0,a0,1026 # 80007570 <etext+0x570>
    80003176:	ebefd0ef          	jal	80000834 <panic>

000000008000317a <iget>:
{
    8000317a:	7179                	addi	sp,sp,-48
    8000317c:	f406                	sd	ra,40(sp)
    8000317e:	f022                	sd	s0,32(sp)
    80003180:	ec26                	sd	s1,24(sp)
    80003182:	e84a                	sd	s2,16(sp)
    80003184:	e44e                	sd	s3,8(sp)
    80003186:	e052                	sd	s4,0(sp)
    80003188:	1800                	addi	s0,sp,48
    8000318a:	892a                	mv	s2,a0
    8000318c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000318e:	0001e517          	auipc	a0,0x1e
    80003192:	97250513          	addi	a0,a0,-1678 # 80020b00 <itable>
    80003196:	a93fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    8000319a:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    8000319c:	0001e497          	auipc	s1,0x1e
    800031a0:	97c48493          	addi	s1,s1,-1668 # 80020b18 <itable+0x18>
    800031a4:	0001f697          	auipc	a3,0x1f
    800031a8:	40468693          	addi	a3,a3,1028 # 800225a8 <log>
    800031ac:	a809                	j	800031be <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    800031ae:	e781                	bnez	a5,800031b6 <iget+0x3c>
    800031b0:	00099363          	bnez	s3,800031b6 <iget+0x3c>
      empty = ip;
    800031b4:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    800031b6:	08848493          	addi	s1,s1,136
    800031ba:	02d48563          	beq	s1,a3,800031e4 <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    800031be:	449c                	lw	a5,8(s1)
    800031c0:	fef057e3          	blez	a5,800031ae <iget+0x34>
    800031c4:	4098                	lw	a4,0(s1)
    800031c6:	ff2718e3          	bne	a4,s2,800031b6 <iget+0x3c>
    800031ca:	40d8                	lw	a4,4(s1)
    800031cc:	ff4715e3          	bne	a4,s4,800031b6 <iget+0x3c>
      ip->ref++;
    800031d0:	2785                	addiw	a5,a5,1
    800031d2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800031d4:	0001e517          	auipc	a0,0x1e
    800031d8:	92c50513          	addi	a0,a0,-1748 # 80020b00 <itable>
    800031dc:	ad5fd0ef          	jal	80000cb0 <release>
      return ip;
    800031e0:	89a6                	mv	s3,s1
    800031e2:	a015                	j	80003206 <iget+0x8c>
  if (empty == 0)
    800031e4:	02098a63          	beqz	s3,80003218 <iget+0x9e>
  ip->dev = dev;
    800031e8:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    800031ec:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    800031f0:	4785                	li	a5,1
    800031f2:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    800031f6:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    800031fa:	0001e517          	auipc	a0,0x1e
    800031fe:	90650513          	addi	a0,a0,-1786 # 80020b00 <itable>
    80003202:	aaffd0ef          	jal	80000cb0 <release>
}
    80003206:	854e                	mv	a0,s3
    80003208:	70a2                	ld	ra,40(sp)
    8000320a:	7402                	ld	s0,32(sp)
    8000320c:	64e2                	ld	s1,24(sp)
    8000320e:	6942                	ld	s2,16(sp)
    80003210:	69a2                	ld	s3,8(sp)
    80003212:	6a02                	ld	s4,0(sp)
    80003214:	6145                	addi	sp,sp,48
    80003216:	8082                	ret
    panic("iget: no inodes");
    80003218:	00004517          	auipc	a0,0x4
    8000321c:	37050513          	addi	a0,a0,880 # 80007588 <etext+0x588>
    80003220:	e14fd0ef          	jal	80000834 <panic>

0000000080003224 <iinit>:
{
    80003224:	7179                	addi	sp,sp,-48
    80003226:	f406                	sd	ra,40(sp)
    80003228:	f022                	sd	s0,32(sp)
    8000322a:	ec26                	sd	s1,24(sp)
    8000322c:	e84a                	sd	s2,16(sp)
    8000322e:	e44e                	sd	s3,8(sp)
    80003230:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003232:	00004597          	auipc	a1,0x4
    80003236:	36658593          	addi	a1,a1,870 # 80007598 <etext+0x598>
    8000323a:	0001e517          	auipc	a0,0x1e
    8000323e:	8c650513          	addi	a0,a0,-1850 # 80020b00 <itable>
    80003242:	967fd0ef          	jal	80000ba8 <initlock>
  for (i = 0; i < NINODE; i++) {
    80003246:	0001e497          	auipc	s1,0x1e
    8000324a:	8e248493          	addi	s1,s1,-1822 # 80020b28 <itable+0x28>
    8000324e:	0001f997          	auipc	s3,0x1f
    80003252:	36a98993          	addi	s3,s3,874 # 800225b8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003256:	00004917          	auipc	s2,0x4
    8000325a:	34a90913          	addi	s2,s2,842 # 800075a0 <etext+0x5a0>
    8000325e:	85ca                	mv	a1,s2
    80003260:	8526                	mv	a0,s1
    80003262:	6e9000ef          	jal	8000414a <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    80003266:	08848493          	addi	s1,s1,136
    8000326a:	ff349ae3          	bne	s1,s3,8000325e <iinit+0x3a>
}
    8000326e:	70a2                	ld	ra,40(sp)
    80003270:	7402                	ld	s0,32(sp)
    80003272:	64e2                	ld	s1,24(sp)
    80003274:	6942                	ld	s2,16(sp)
    80003276:	69a2                	ld	s3,8(sp)
    80003278:	6145                	addi	sp,sp,48
    8000327a:	8082                	ret

000000008000327c <ialloc>:
{
    8000327c:	7139                	addi	sp,sp,-64
    8000327e:	fc06                	sd	ra,56(sp)
    80003280:	f822                	sd	s0,48(sp)
    80003282:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003284:	0001e717          	auipc	a4,0x1e
    80003288:	86872703          	lw	a4,-1944(a4) # 80020aec <sb+0xc>
    8000328c:	4785                	li	a5,1
    8000328e:	06e7f063          	bgeu	a5,a4,800032ee <ialloc+0x72>
    80003292:	f426                	sd	s1,40(sp)
    80003294:	f04a                	sd	s2,32(sp)
    80003296:	ec4e                	sd	s3,24(sp)
    80003298:	e852                	sd	s4,16(sp)
    8000329a:	e456                	sd	s5,8(sp)
    8000329c:	e05a                	sd	s6,0(sp)
    8000329e:	8aaa                	mv	s5,a0
    800032a0:	8b2e                	mv	s6,a1
    800032a2:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800032a4:	0001ea17          	auipc	s4,0x1e
    800032a8:	83ca0a13          	addi	s4,s4,-1988 # 80020ae0 <sb>
    800032ac:	00495593          	srli	a1,s2,0x4
    800032b0:	018a2783          	lw	a5,24(s4)
    800032b4:	9dbd                	addw	a1,a1,a5
    800032b6:	8556                	mv	a0,s5
    800032b8:	a9dff0ef          	jal	80002d54 <bread>
    800032bc:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    800032be:	05850993          	addi	s3,a0,88
    800032c2:	00f97793          	andi	a5,s2,15
    800032c6:	079a                	slli	a5,a5,0x6
    800032c8:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    800032ca:	00099783          	lh	a5,0(s3)
    800032ce:	cb9d                	beqz	a5,80003304 <ialloc+0x88>
    brelse(bp);
    800032d0:	b8dff0ef          	jal	80002e5c <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    800032d4:	0905                	addi	s2,s2,1
    800032d6:	00ca2703          	lw	a4,12(s4)
    800032da:	0009079b          	sext.w	a5,s2
    800032de:	fce7e7e3          	bltu	a5,a4,800032ac <ialloc+0x30>
    800032e2:	74a2                	ld	s1,40(sp)
    800032e4:	7902                	ld	s2,32(sp)
    800032e6:	69e2                	ld	s3,24(sp)
    800032e8:	6a42                	ld	s4,16(sp)
    800032ea:	6aa2                	ld	s5,8(sp)
    800032ec:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    800032ee:	00004517          	auipc	a0,0x4
    800032f2:	2ba50513          	addi	a0,a0,698 # 800075a8 <etext+0x5a8>
    800032f6:	a14fd0ef          	jal	8000050a <printk>
  return 0;
    800032fa:	4501                	li	a0,0
}
    800032fc:	70e2                	ld	ra,56(sp)
    800032fe:	7442                	ld	s0,48(sp)
    80003300:	6121                	addi	sp,sp,64
    80003302:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003304:	04000613          	li	a2,64
    80003308:	4581                	li	a1,0
    8000330a:	854e                	mv	a0,s3
    8000330c:	9ddfd0ef          	jal	80000ce8 <memset>
      dip->type = type;
    80003310:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    80003314:	8526                	mv	a0,s1
    80003316:	4fd000ef          	jal	80004012 <log_write>
      brelse(bp);
    8000331a:	8526                	mv	a0,s1
    8000331c:	b41ff0ef          	jal	80002e5c <brelse>
      return iget(dev, inum);
    80003320:	0009059b          	sext.w	a1,s2
    80003324:	8556                	mv	a0,s5
    80003326:	e55ff0ef          	jal	8000317a <iget>
    8000332a:	74a2                	ld	s1,40(sp)
    8000332c:	7902                	ld	s2,32(sp)
    8000332e:	69e2                	ld	s3,24(sp)
    80003330:	6a42                	ld	s4,16(sp)
    80003332:	6aa2                	ld	s5,8(sp)
    80003334:	6b02                	ld	s6,0(sp)
    80003336:	b7d9                	j	800032fc <ialloc+0x80>

0000000080003338 <iupdate>:
{
    80003338:	1101                	addi	sp,sp,-32
    8000333a:	ec06                	sd	ra,24(sp)
    8000333c:	e822                	sd	s0,16(sp)
    8000333e:	e426                	sd	s1,8(sp)
    80003340:	e04a                	sd	s2,0(sp)
    80003342:	1000                	addi	s0,sp,32
    80003344:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003346:	415c                	lw	a5,4(a0)
    80003348:	0047d79b          	srliw	a5,a5,0x4
    8000334c:	0001d597          	auipc	a1,0x1d
    80003350:	7ac5a583          	lw	a1,1964(a1) # 80020af8 <sb+0x18>
    80003354:	9dbd                	addw	a1,a1,a5
    80003356:	4108                	lw	a0,0(a0)
    80003358:	9fdff0ef          	jal	80002d54 <bread>
    8000335c:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000335e:	05850793          	addi	a5,a0,88
    80003362:	40d8                	lw	a4,4(s1)
    80003364:	8b3d                	andi	a4,a4,15
    80003366:	071a                	slli	a4,a4,0x6
    80003368:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000336a:	04449703          	lh	a4,68(s1)
    8000336e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003372:	04649703          	lh	a4,70(s1)
    80003376:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000337a:	04849703          	lh	a4,72(s1)
    8000337e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003382:	04a49703          	lh	a4,74(s1)
    80003386:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000338a:	44f8                	lw	a4,76(s1)
    8000338c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000338e:	03400613          	li	a2,52
    80003392:	05048593          	addi	a1,s1,80
    80003396:	00c78513          	addi	a0,a5,12
    8000339a:	9affd0ef          	jal	80000d48 <memmove>
  log_write(bp);
    8000339e:	854a                	mv	a0,s2
    800033a0:	473000ef          	jal	80004012 <log_write>
  brelse(bp);
    800033a4:	854a                	mv	a0,s2
    800033a6:	ab7ff0ef          	jal	80002e5c <brelse>
}
    800033aa:	60e2                	ld	ra,24(sp)
    800033ac:	6442                	ld	s0,16(sp)
    800033ae:	64a2                	ld	s1,8(sp)
    800033b0:	6902                	ld	s2,0(sp)
    800033b2:	6105                	addi	sp,sp,32
    800033b4:	8082                	ret

00000000800033b6 <idup>:
{
    800033b6:	1101                	addi	sp,sp,-32
    800033b8:	ec06                	sd	ra,24(sp)
    800033ba:	e822                	sd	s0,16(sp)
    800033bc:	e426                	sd	s1,8(sp)
    800033be:	1000                	addi	s0,sp,32
    800033c0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800033c2:	0001d517          	auipc	a0,0x1d
    800033c6:	73e50513          	addi	a0,a0,1854 # 80020b00 <itable>
    800033ca:	85ffd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    800033ce:	449c                	lw	a5,8(s1)
    800033d0:	2785                	addiw	a5,a5,1
    800033d2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033d4:	0001d517          	auipc	a0,0x1d
    800033d8:	72c50513          	addi	a0,a0,1836 # 80020b00 <itable>
    800033dc:	8d5fd0ef          	jal	80000cb0 <release>
}
    800033e0:	8526                	mv	a0,s1
    800033e2:	60e2                	ld	ra,24(sp)
    800033e4:	6442                	ld	s0,16(sp)
    800033e6:	64a2                	ld	s1,8(sp)
    800033e8:	6105                	addi	sp,sp,32
    800033ea:	8082                	ret

00000000800033ec <ilock>:
{
    800033ec:	1101                	addi	sp,sp,-32
    800033ee:	ec06                	sd	ra,24(sp)
    800033f0:	e822                	sd	s0,16(sp)
    800033f2:	e426                	sd	s1,8(sp)
    800033f4:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    800033f6:	cd19                	beqz	a0,80003414 <ilock+0x28>
    800033f8:	84aa                	mv	s1,a0
    800033fa:	451c                	lw	a5,8(a0)
    800033fc:	00f05c63          	blez	a5,80003414 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003400:	0541                	addi	a0,a0,16
    80003402:	57f000ef          	jal	80004180 <acquiresleep>
  if (ip->valid == 0) {
    80003406:	40bc                	lw	a5,64(s1)
    80003408:	cf89                	beqz	a5,80003422 <ilock+0x36>
}
    8000340a:	60e2                	ld	ra,24(sp)
    8000340c:	6442                	ld	s0,16(sp)
    8000340e:	64a2                	ld	s1,8(sp)
    80003410:	6105                	addi	sp,sp,32
    80003412:	8082                	ret
    80003414:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003416:	00004517          	auipc	a0,0x4
    8000341a:	1aa50513          	addi	a0,a0,426 # 800075c0 <etext+0x5c0>
    8000341e:	c16fd0ef          	jal	80000834 <panic>
    80003422:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003424:	40dc                	lw	a5,4(s1)
    80003426:	0047d79b          	srliw	a5,a5,0x4
    8000342a:	0001d597          	auipc	a1,0x1d
    8000342e:	6ce5a583          	lw	a1,1742(a1) # 80020af8 <sb+0x18>
    80003432:	9dbd                	addw	a1,a1,a5
    80003434:	4088                	lw	a0,0(s1)
    80003436:	91fff0ef          	jal	80002d54 <bread>
    8000343a:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000343c:	05850593          	addi	a1,a0,88
    80003440:	40dc                	lw	a5,4(s1)
    80003442:	8bbd                	andi	a5,a5,15
    80003444:	079a                	slli	a5,a5,0x6
    80003446:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003448:	00059783          	lh	a5,0(a1)
    8000344c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003450:	00259783          	lh	a5,2(a1)
    80003454:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003458:	00459783          	lh	a5,4(a1)
    8000345c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003460:	00659783          	lh	a5,6(a1)
    80003464:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003468:	459c                	lw	a5,8(a1)
    8000346a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000346c:	03400613          	li	a2,52
    80003470:	05b1                	addi	a1,a1,12
    80003472:	05048513          	addi	a0,s1,80
    80003476:	8d3fd0ef          	jal	80000d48 <memmove>
    brelse(bp);
    8000347a:	854a                	mv	a0,s2
    8000347c:	9e1ff0ef          	jal	80002e5c <brelse>
    ip->valid = 1;
    80003480:	4785                	li	a5,1
    80003482:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003484:	04449783          	lh	a5,68(s1)
    80003488:	c399                	beqz	a5,8000348e <ilock+0xa2>
    8000348a:	6902                	ld	s2,0(sp)
    8000348c:	bfbd                	j	8000340a <ilock+0x1e>
      panic("ilock: no type");
    8000348e:	00004517          	auipc	a0,0x4
    80003492:	13a50513          	addi	a0,a0,314 # 800075c8 <etext+0x5c8>
    80003496:	b9efd0ef          	jal	80000834 <panic>

000000008000349a <iunlock>:
{
    8000349a:	1101                	addi	sp,sp,-32
    8000349c:	ec06                	sd	ra,24(sp)
    8000349e:	e822                	sd	s0,16(sp)
    800034a0:	e426                	sd	s1,8(sp)
    800034a2:	e04a                	sd	s2,0(sp)
    800034a4:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800034a6:	c505                	beqz	a0,800034ce <iunlock+0x34>
    800034a8:	84aa                	mv	s1,a0
    800034aa:	01050913          	addi	s2,a0,16
    800034ae:	854a                	mv	a0,s2
    800034b0:	55d000ef          	jal	8000420c <holdingsleep>
    800034b4:	cd09                	beqz	a0,800034ce <iunlock+0x34>
    800034b6:	449c                	lw	a5,8(s1)
    800034b8:	00f05b63          	blez	a5,800034ce <iunlock+0x34>
  releasesleep(&ip->lock);
    800034bc:	854a                	mv	a0,s2
    800034be:	517000ef          	jal	800041d4 <releasesleep>
}
    800034c2:	60e2                	ld	ra,24(sp)
    800034c4:	6442                	ld	s0,16(sp)
    800034c6:	64a2                	ld	s1,8(sp)
    800034c8:	6902                	ld	s2,0(sp)
    800034ca:	6105                	addi	sp,sp,32
    800034cc:	8082                	ret
    panic("iunlock");
    800034ce:	00004517          	auipc	a0,0x4
    800034d2:	10a50513          	addi	a0,a0,266 # 800075d8 <etext+0x5d8>
    800034d6:	b5efd0ef          	jal	80000834 <panic>

00000000800034da <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800034da:	7179                	addi	sp,sp,-48
    800034dc:	f406                	sd	ra,40(sp)
    800034de:	f022                	sd	s0,32(sp)
    800034e0:	ec26                	sd	s1,24(sp)
    800034e2:	e84a                	sd	s2,16(sp)
    800034e4:	e44e                	sd	s3,8(sp)
    800034e6:	1800                	addi	s0,sp,48
    800034e8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    800034ea:	05050493          	addi	s1,a0,80
    800034ee:	08050913          	addi	s2,a0,128
    800034f2:	a021                	j	800034fa <itrunc+0x20>
    800034f4:	0491                	addi	s1,s1,4
    800034f6:	01248b63          	beq	s1,s2,8000350c <itrunc+0x32>
    if (ip->addrs[i]) {
    800034fa:	408c                	lw	a1,0(s1)
    800034fc:	dde5                	beqz	a1,800034f4 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800034fe:	0009a503          	lw	a0,0(s3)
    80003502:	a47ff0ef          	jal	80002f48 <bfree>
      ip->addrs[i] = 0;
    80003506:	0004a023          	sw	zero,0(s1)
    8000350a:	b7ed                	j	800034f4 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    8000350c:	0809a583          	lw	a1,128(s3)
    80003510:	ed89                	bnez	a1,8000352a <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003512:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003516:	854e                	mv	a0,s3
    80003518:	e21ff0ef          	jal	80003338 <iupdate>
}
    8000351c:	70a2                	ld	ra,40(sp)
    8000351e:	7402                	ld	s0,32(sp)
    80003520:	64e2                	ld	s1,24(sp)
    80003522:	6942                	ld	s2,16(sp)
    80003524:	69a2                	ld	s3,8(sp)
    80003526:	6145                	addi	sp,sp,48
    80003528:	8082                	ret
    8000352a:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000352c:	0009a503          	lw	a0,0(s3)
    80003530:	825ff0ef          	jal	80002d54 <bread>
    80003534:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    80003536:	05850493          	addi	s1,a0,88
    8000353a:	45850913          	addi	s2,a0,1112
    8000353e:	a021                	j	80003546 <itrunc+0x6c>
    80003540:	0491                	addi	s1,s1,4
    80003542:	01248963          	beq	s1,s2,80003554 <itrunc+0x7a>
      if (a[j])
    80003546:	408c                	lw	a1,0(s1)
    80003548:	dde5                	beqz	a1,80003540 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000354a:	0009a503          	lw	a0,0(s3)
    8000354e:	9fbff0ef          	jal	80002f48 <bfree>
    80003552:	b7fd                	j	80003540 <itrunc+0x66>
    brelse(bp);
    80003554:	8552                	mv	a0,s4
    80003556:	907ff0ef          	jal	80002e5c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000355a:	0809a583          	lw	a1,128(s3)
    8000355e:	0009a503          	lw	a0,0(s3)
    80003562:	9e7ff0ef          	jal	80002f48 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003566:	0809a023          	sw	zero,128(s3)
    8000356a:	6a02                	ld	s4,0(sp)
    8000356c:	b75d                	j	80003512 <itrunc+0x38>

000000008000356e <iput>:
{
    8000356e:	7179                	addi	sp,sp,-48
    80003570:	f406                	sd	ra,40(sp)
    80003572:	f022                	sd	s0,32(sp)
    80003574:	ec26                	sd	s1,24(sp)
    80003576:	1800                	addi	s0,sp,48
    80003578:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000357a:	0001d517          	auipc	a0,0x1d
    8000357e:	58650513          	addi	a0,a0,1414 # 80020b00 <itable>
    80003582:	ea6fd0ef          	jal	80000c28 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003586:	449c                	lw	a5,8(s1)
    80003588:	4705                	li	a4,1
    8000358a:	00e78f63          	beq	a5,a4,800035a8 <iput+0x3a>
  ip->ref--;
    8000358e:	37fd                	addiw	a5,a5,-1
    80003590:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003592:	0001d517          	auipc	a0,0x1d
    80003596:	56e50513          	addi	a0,a0,1390 # 80020b00 <itable>
    8000359a:	f16fd0ef          	jal	80000cb0 <release>
}
    8000359e:	70a2                	ld	ra,40(sp)
    800035a0:	7402                	ld	s0,32(sp)
    800035a2:	64e2                	ld	s1,24(sp)
    800035a4:	6145                	addi	sp,sp,48
    800035a6:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    800035a8:	40b8                	lw	a4,64(s1)
    800035aa:	d375                	beqz	a4,8000358e <iput+0x20>
    800035ac:	e84a                	sd	s2,16(sp)
    800035ae:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    800035b0:	0004aa03          	lw	s4,0(s1)
    800035b4:	0044a903          	lw	s2,4(s1)
  if (last) {
    800035b8:	04a49703          	lh	a4,74(s1)
    800035bc:	ef3d                	bnez	a4,8000363a <iput+0xcc>
    800035be:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    800035c0:	01048793          	addi	a5,s1,16
    800035c4:	89be                	mv	s3,a5
    800035c6:	853e                	mv	a0,a5
    800035c8:	3b9000ef          	jal	80004180 <acquiresleep>
    release(&itable.lock);
    800035cc:	0001d517          	auipc	a0,0x1d
    800035d0:	53450513          	addi	a0,a0,1332 # 80020b00 <itable>
    800035d4:	edcfd0ef          	jal	80000cb0 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    800035d8:	8526                	mv	a0,s1
    800035da:	f01ff0ef          	jal	800034da <itrunc>
    ip->valid = 0;
    800035de:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800035e2:	854e                	mv	a0,s3
    800035e4:	3f1000ef          	jal	800041d4 <releasesleep>
    acquire(&itable.lock);
    800035e8:	0001d517          	auipc	a0,0x1d
    800035ec:	51850513          	addi	a0,a0,1304 # 80020b00 <itable>
    800035f0:	e38fd0ef          	jal	80000c28 <acquire>
  ip->ref--;
    800035f4:	449c                	lw	a5,8(s1)
    800035f6:	37fd                	addiw	a5,a5,-1
    800035f8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800035fa:	0001d517          	auipc	a0,0x1d
    800035fe:	50650513          	addi	a0,a0,1286 # 80020b00 <itable>
    80003602:	eaefd0ef          	jal	80000cb0 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003606:	0049579b          	srliw	a5,s2,0x4
    8000360a:	0001d597          	auipc	a1,0x1d
    8000360e:	4ee5a583          	lw	a1,1262(a1) # 80020af8 <sb+0x18>
    80003612:	9dbd                	addw	a1,a1,a5
    80003614:	8552                	mv	a0,s4
    80003616:	f3eff0ef          	jal	80002d54 <bread>
    8000361a:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000361c:	00f97793          	andi	a5,s2,15
  dip->type = 0;
    80003620:	079a                	slli	a5,a5,0x6
    80003622:	97aa                	add	a5,a5,a0
    80003624:	04079c23          	sh	zero,88(a5)
  log_write(bp);
    80003628:	1eb000ef          	jal	80004012 <log_write>
  brelse(bp);
    8000362c:	8526                	mv	a0,s1
    8000362e:	82fff0ef          	jal	80002e5c <brelse>
}
    80003632:	6942                	ld	s2,16(sp)
    80003634:	69a2                	ld	s3,8(sp)
    80003636:	6a02                	ld	s4,0(sp)
    80003638:	b79d                	j	8000359e <iput+0x30>
    8000363a:	6942                	ld	s2,16(sp)
    8000363c:	6a02                	ld	s4,0(sp)
    8000363e:	bf81                	j	8000358e <iput+0x20>

0000000080003640 <iunlockput>:
{
    80003640:	1101                	addi	sp,sp,-32
    80003642:	ec06                	sd	ra,24(sp)
    80003644:	e822                	sd	s0,16(sp)
    80003646:	e426                	sd	s1,8(sp)
    80003648:	1000                	addi	s0,sp,32
    8000364a:	84aa                	mv	s1,a0
  iunlock(ip);
    8000364c:	e4fff0ef          	jal	8000349a <iunlock>
  iput(ip);
    80003650:	8526                	mv	a0,s1
    80003652:	f1dff0ef          	jal	8000356e <iput>
}
    80003656:	60e2                	ld	ra,24(sp)
    80003658:	6442                	ld	s0,16(sp)
    8000365a:	64a2                	ld	s1,8(sp)
    8000365c:	6105                	addi	sp,sp,32
    8000365e:	8082                	ret

0000000080003660 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003660:	0001d717          	auipc	a4,0x1d
    80003664:	48c72703          	lw	a4,1164(a4) # 80020aec <sb+0xc>
    80003668:	4785                	li	a5,1
    8000366a:	0ae7fe63          	bgeu	a5,a4,80003726 <ireclaim+0xc6>
{
    8000366e:	7139                	addi	sp,sp,-64
    80003670:	fc06                	sd	ra,56(sp)
    80003672:	f822                	sd	s0,48(sp)
    80003674:	f426                	sd	s1,40(sp)
    80003676:	f04a                	sd	s2,32(sp)
    80003678:	ec4e                	sd	s3,24(sp)
    8000367a:	e852                	sd	s4,16(sp)
    8000367c:	e456                	sd	s5,8(sp)
    8000367e:	e05a                	sd	s6,0(sp)
    80003680:	0080                	addi	s0,sp,64
    80003682:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003684:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003686:	0001da17          	auipc	s4,0x1d
    8000368a:	45aa0a13          	addi	s4,s4,1114 # 80020ae0 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    8000368e:	00004b17          	auipc	s6,0x4
    80003692:	f52b0b13          	addi	s6,s6,-174 # 800075e0 <etext+0x5e0>
    80003696:	a099                	j	800036dc <ireclaim+0x7c>
    80003698:	85ce                	mv	a1,s3
    8000369a:	855a                	mv	a0,s6
    8000369c:	e6ffc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    800036a0:	85ce                	mv	a1,s3
    800036a2:	8556                	mv	a0,s5
    800036a4:	ad7ff0ef          	jal	8000317a <iget>
    800036a8:	89aa                	mv	s3,a0
    brelse(bp);
    800036aa:	854a                	mv	a0,s2
    800036ac:	fb0ff0ef          	jal	80002e5c <brelse>
    if (ip) {
    800036b0:	00098f63          	beqz	s3,800036ce <ireclaim+0x6e>
      begin_op();
    800036b4:	7b0000ef          	jal	80003e64 <begin_op>
      ilock(ip);
    800036b8:	854e                	mv	a0,s3
    800036ba:	d33ff0ef          	jal	800033ec <ilock>
      iunlock(ip);
    800036be:	854e                	mv	a0,s3
    800036c0:	ddbff0ef          	jal	8000349a <iunlock>
      iput(ip);
    800036c4:	854e                	mv	a0,s3
    800036c6:	ea9ff0ef          	jal	8000356e <iput>
      end_op();
    800036ca:	027000ef          	jal	80003ef0 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800036ce:	0485                	addi	s1,s1,1
    800036d0:	00ca2703          	lw	a4,12(s4)
    800036d4:	0004879b          	sext.w	a5,s1
    800036d8:	02e7fd63          	bgeu	a5,a4,80003712 <ireclaim+0xb2>
    800036dc:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800036e0:	0044d593          	srli	a1,s1,0x4
    800036e4:	018a2783          	lw	a5,24(s4)
    800036e8:	9dbd                	addw	a1,a1,a5
    800036ea:	8556                	mv	a0,s5
    800036ec:	e68ff0ef          	jal	80002d54 <bread>
    800036f0:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800036f2:	05850793          	addi	a5,a0,88
    800036f6:	00f9f713          	andi	a4,s3,15
    800036fa:	071a                	slli	a4,a4,0x6
    800036fc:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    800036fe:	00079703          	lh	a4,0(a5)
    80003702:	c701                	beqz	a4,8000370a <ireclaim+0xaa>
    80003704:	00679783          	lh	a5,6(a5)
    80003708:	dbc1                	beqz	a5,80003698 <ireclaim+0x38>
    brelse(bp);
    8000370a:	854a                	mv	a0,s2
    8000370c:	f50ff0ef          	jal	80002e5c <brelse>
    if (ip) {
    80003710:	bf7d                	j	800036ce <ireclaim+0x6e>
}
    80003712:	70e2                	ld	ra,56(sp)
    80003714:	7442                	ld	s0,48(sp)
    80003716:	74a2                	ld	s1,40(sp)
    80003718:	7902                	ld	s2,32(sp)
    8000371a:	69e2                	ld	s3,24(sp)
    8000371c:	6a42                	ld	s4,16(sp)
    8000371e:	6aa2                	ld	s5,8(sp)
    80003720:	6b02                	ld	s6,0(sp)
    80003722:	6121                	addi	sp,sp,64
    80003724:	8082                	ret
    80003726:	8082                	ret

0000000080003728 <fsinit>:
{
    80003728:	1101                	addi	sp,sp,-32
    8000372a:	ec06                	sd	ra,24(sp)
    8000372c:	e822                	sd	s0,16(sp)
    8000372e:	e426                	sd	s1,8(sp)
    80003730:	e04a                	sd	s2,0(sp)
    80003732:	1000                	addi	s0,sp,32
    80003734:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003736:	4585                	li	a1,1
    80003738:	e1cff0ef          	jal	80002d54 <bread>
    8000373c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000373e:	02000613          	li	a2,32
    80003742:	05850593          	addi	a1,a0,88
    80003746:	0001d517          	auipc	a0,0x1d
    8000374a:	39a50513          	addi	a0,a0,922 # 80020ae0 <sb>
    8000374e:	dfafd0ef          	jal	80000d48 <memmove>
  brelse(bp);
    80003752:	8526                	mv	a0,s1
    80003754:	f08ff0ef          	jal	80002e5c <brelse>
  if (sb.magic != FSMAGIC)
    80003758:	0001d717          	auipc	a4,0x1d
    8000375c:	38872703          	lw	a4,904(a4) # 80020ae0 <sb>
    80003760:	102037b7          	lui	a5,0x10203
    80003764:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003768:	02f71263          	bne	a4,a5,8000378c <fsinit+0x64>
  initlog(dev, &sb);
    8000376c:	0001d597          	auipc	a1,0x1d
    80003770:	37458593          	addi	a1,a1,884 # 80020ae0 <sb>
    80003774:	854a                	mv	a0,s2
    80003776:	66c000ef          	jal	80003de2 <initlog>
  ireclaim(dev);
    8000377a:	854a                	mv	a0,s2
    8000377c:	ee5ff0ef          	jal	80003660 <ireclaim>
}
    80003780:	60e2                	ld	ra,24(sp)
    80003782:	6442                	ld	s0,16(sp)
    80003784:	64a2                	ld	s1,8(sp)
    80003786:	6902                	ld	s2,0(sp)
    80003788:	6105                	addi	sp,sp,32
    8000378a:	8082                	ret
    panic("invalid file system");
    8000378c:	00004517          	auipc	a0,0x4
    80003790:	e7450513          	addi	a0,a0,-396 # 80007600 <etext+0x600>
    80003794:	8a0fd0ef          	jal	80000834 <panic>

0000000080003798 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003798:	1141                	addi	sp,sp,-16
    8000379a:	e406                	sd	ra,8(sp)
    8000379c:	e022                	sd	s0,0(sp)
    8000379e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800037a0:	411c                	lw	a5,0(a0)
    800037a2:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800037a4:	415c                	lw	a5,4(a0)
    800037a6:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800037a8:	04451783          	lh	a5,68(a0)
    800037ac:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800037b0:	04a51783          	lh	a5,74(a0)
    800037b4:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800037b8:	04c56783          	lwu	a5,76(a0)
    800037bc:	e99c                	sd	a5,16(a1)
}
    800037be:	60a2                	ld	ra,8(sp)
    800037c0:	6402                	ld	s0,0(sp)
    800037c2:	0141                	addi	sp,sp,16
    800037c4:	8082                	ret

00000000800037c6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    800037c6:	457c                	lw	a5,76(a0)
    800037c8:	0ed7e663          	bltu	a5,a3,800038b4 <readi+0xee>
{
    800037cc:	7159                	addi	sp,sp,-112
    800037ce:	f486                	sd	ra,104(sp)
    800037d0:	f0a2                	sd	s0,96(sp)
    800037d2:	eca6                	sd	s1,88(sp)
    800037d4:	e0d2                	sd	s4,64(sp)
    800037d6:	fc56                	sd	s5,56(sp)
    800037d8:	f85a                	sd	s6,48(sp)
    800037da:	f45e                	sd	s7,40(sp)
    800037dc:	1880                	addi	s0,sp,112
    800037de:	8b2a                	mv	s6,a0
    800037e0:	8bae                	mv	s7,a1
    800037e2:	8a32                	mv	s4,a2
    800037e4:	84b6                	mv	s1,a3
    800037e6:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    800037e8:	9f35                	addw	a4,a4,a3
    return 0;
    800037ea:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    800037ec:	0ad76b63          	bltu	a4,a3,800038a2 <readi+0xdc>
    800037f0:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    800037f2:	00e7f463          	bgeu	a5,a4,800037fa <readi+0x34>
    n = ip->size - off;
    800037f6:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800037fa:	080a8b63          	beqz	s5,80003890 <readi+0xca>
    800037fe:	e8ca                	sd	s2,80(sp)
    80003800:	f062                	sd	s8,32(sp)
    80003802:	ec66                	sd	s9,24(sp)
    80003804:	e86a                	sd	s10,16(sp)
    80003806:	e46e                	sd	s11,8(sp)
    80003808:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    8000380a:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000380e:	5c7d                	li	s8,-1
    80003810:	a80d                	j	80003842 <readi+0x7c>
    80003812:	020d1d93          	slli	s11,s10,0x20
    80003816:	020ddd93          	srli	s11,s11,0x20
    8000381a:	05890613          	addi	a2,s2,88
    8000381e:	86ee                	mv	a3,s11
    80003820:	963e                	add	a2,a2,a5
    80003822:	85d2                	mv	a1,s4
    80003824:	855e                	mv	a0,s7
    80003826:	c2dfe0ef          	jal	80002452 <either_copyout>
    8000382a:	05850363          	beq	a0,s8,80003870 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000382e:	854a                	mv	a0,s2
    80003830:	e2cff0ef          	jal	80002e5c <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003834:	013d09bb          	addw	s3,s10,s3
    80003838:	009d04bb          	addw	s1,s10,s1
    8000383c:	9a6e                	add	s4,s4,s11
    8000383e:	0559f363          	bgeu	s3,s5,80003884 <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    80003842:	00a4d59b          	srliw	a1,s1,0xa
    80003846:	855a                	mv	a0,s6
    80003848:	873ff0ef          	jal	800030ba <bmap>
    8000384c:	85aa                	mv	a1,a0
    if (addr == 0)
    8000384e:	c139                	beqz	a0,80003894 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003850:	000b2503          	lw	a0,0(s6)
    80003854:	d00ff0ef          	jal	80002d54 <bread>
    80003858:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    8000385a:	3ff4f793          	andi	a5,s1,1023
    8000385e:	40fc873b          	subw	a4,s9,a5
    80003862:	413a86bb          	subw	a3,s5,s3
    80003866:	8d3a                	mv	s10,a4
    80003868:	fae6f5e3          	bgeu	a3,a4,80003812 <readi+0x4c>
    8000386c:	8d36                	mv	s10,a3
    8000386e:	b755                	j	80003812 <readi+0x4c>
      brelse(bp);
    80003870:	854a                	mv	a0,s2
    80003872:	deaff0ef          	jal	80002e5c <brelse>
      tot = -1;
    80003876:	59fd                	li	s3,-1
      break;
    80003878:	6946                	ld	s2,80(sp)
    8000387a:	7c02                	ld	s8,32(sp)
    8000387c:	6ce2                	ld	s9,24(sp)
    8000387e:	6d42                	ld	s10,16(sp)
    80003880:	6da2                	ld	s11,8(sp)
    80003882:	a831                	j	8000389e <readi+0xd8>
    80003884:	6946                	ld	s2,80(sp)
    80003886:	7c02                	ld	s8,32(sp)
    80003888:	6ce2                	ld	s9,24(sp)
    8000388a:	6d42                	ld	s10,16(sp)
    8000388c:	6da2                	ld	s11,8(sp)
    8000388e:	a801                	j	8000389e <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003890:	89d6                	mv	s3,s5
    80003892:	a031                	j	8000389e <readi+0xd8>
    80003894:	6946                	ld	s2,80(sp)
    80003896:	7c02                	ld	s8,32(sp)
    80003898:	6ce2                	ld	s9,24(sp)
    8000389a:	6d42                	ld	s10,16(sp)
    8000389c:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000389e:	854e                	mv	a0,s3
    800038a0:	69a6                	ld	s3,72(sp)
}
    800038a2:	70a6                	ld	ra,104(sp)
    800038a4:	7406                	ld	s0,96(sp)
    800038a6:	64e6                	ld	s1,88(sp)
    800038a8:	6a06                	ld	s4,64(sp)
    800038aa:	7ae2                	ld	s5,56(sp)
    800038ac:	7b42                	ld	s6,48(sp)
    800038ae:	7ba2                	ld	s7,40(sp)
    800038b0:	6165                	addi	sp,sp,112
    800038b2:	8082                	ret
    return 0;
    800038b4:	4501                	li	a0,0
}
    800038b6:	8082                	ret

00000000800038b8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    800038b8:	457c                	lw	a5,76(a0)
    800038ba:	0ed7ee63          	bltu	a5,a3,800039b6 <writei+0xfe>
{
    800038be:	7159                	addi	sp,sp,-112
    800038c0:	f486                	sd	ra,104(sp)
    800038c2:	f0a2                	sd	s0,96(sp)
    800038c4:	e8ca                	sd	s2,80(sp)
    800038c6:	e0d2                	sd	s4,64(sp)
    800038c8:	fc56                	sd	s5,56(sp)
    800038ca:	f85a                	sd	s6,48(sp)
    800038cc:	f45e                	sd	s7,40(sp)
    800038ce:	1880                	addi	s0,sp,112
    800038d0:	8aaa                	mv	s5,a0
    800038d2:	8bae                	mv	s7,a1
    800038d4:	8a32                	mv	s4,a2
    800038d6:	8936                	mv	s2,a3
    800038d8:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    800038da:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    800038de:	00043737          	lui	a4,0x43
    800038e2:	0cf76c63          	bltu	a4,a5,800039ba <writei+0x102>
    800038e6:	0cd7ea63          	bltu	a5,a3,800039ba <writei+0x102>
    800038ea:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800038ec:	0a0b0d63          	beqz	s6,800039a6 <writei+0xee>
    800038f0:	eca6                	sd	s1,88(sp)
    800038f2:	f062                	sd	s8,32(sp)
    800038f4:	ec66                	sd	s9,24(sp)
    800038f6:	e86a                	sd	s10,16(sp)
    800038f8:	e46e                	sd	s11,8(sp)
    800038fa:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800038fc:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003900:	5c7d                	li	s8,-1
    80003902:	a825                	j	8000393a <writei+0x82>
    80003904:	020d1d93          	slli	s11,s10,0x20
    80003908:	020ddd93          	srli	s11,s11,0x20
    8000390c:	05848513          	addi	a0,s1,88
    80003910:	86ee                	mv	a3,s11
    80003912:	8652                	mv	a2,s4
    80003914:	85de                	mv	a1,s7
    80003916:	953e                	add	a0,a0,a5
    80003918:	b87fe0ef          	jal	8000249e <either_copyin>
    8000391c:	05850663          	beq	a0,s8,80003968 <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    80003920:	8526                	mv	a0,s1
    80003922:	6f0000ef          	jal	80004012 <log_write>
    brelse(bp);
    80003926:	8526                	mv	a0,s1
    80003928:	d34ff0ef          	jal	80002e5c <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    8000392c:	013d09bb          	addw	s3,s10,s3
    80003930:	012d093b          	addw	s2,s10,s2
    80003934:	9a6e                	add	s4,s4,s11
    80003936:	0369ff63          	bgeu	s3,s6,80003974 <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    8000393a:	00a9559b          	srliw	a1,s2,0xa
    8000393e:	8556                	mv	a0,s5
    80003940:	f7aff0ef          	jal	800030ba <bmap>
    80003944:	85aa                	mv	a1,a0
    if (addr == 0)
    80003946:	c51d                	beqz	a0,80003974 <writei+0xbc>
    bp = bread(ip->dev, addr);
    80003948:	000aa503          	lw	a0,0(s5)
    8000394c:	c08ff0ef          	jal	80002d54 <bread>
    80003950:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003952:	3ff97793          	andi	a5,s2,1023
    80003956:	40fc873b          	subw	a4,s9,a5
    8000395a:	413b06bb          	subw	a3,s6,s3
    8000395e:	8d3a                	mv	s10,a4
    80003960:	fae6f2e3          	bgeu	a3,a4,80003904 <writei+0x4c>
    80003964:	8d36                	mv	s10,a3
    80003966:	bf79                	j	80003904 <writei+0x4c>
      log_write(bp);
    80003968:	8526                	mv	a0,s1
    8000396a:	6a8000ef          	jal	80004012 <log_write>
      brelse(bp);
    8000396e:	8526                	mv	a0,s1
    80003970:	cecff0ef          	jal	80002e5c <brelse>
  }

  if (off > ip->size)
    80003974:	04caa783          	lw	a5,76(s5)
    80003978:	0327f963          	bgeu	a5,s2,800039aa <writei+0xf2>
    ip->size = off;
    8000397c:	052aa623          	sw	s2,76(s5)
    80003980:	64e6                	ld	s1,88(sp)
    80003982:	7c02                	ld	s8,32(sp)
    80003984:	6ce2                	ld	s9,24(sp)
    80003986:	6d42                	ld	s10,16(sp)
    80003988:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000398a:	8556                	mv	a0,s5
    8000398c:	9adff0ef          	jal	80003338 <iupdate>

  return tot;
    80003990:	854e                	mv	a0,s3
    80003992:	69a6                	ld	s3,72(sp)
}
    80003994:	70a6                	ld	ra,104(sp)
    80003996:	7406                	ld	s0,96(sp)
    80003998:	6946                	ld	s2,80(sp)
    8000399a:	6a06                	ld	s4,64(sp)
    8000399c:	7ae2                	ld	s5,56(sp)
    8000399e:	7b42                	ld	s6,48(sp)
    800039a0:	7ba2                	ld	s7,40(sp)
    800039a2:	6165                	addi	sp,sp,112
    800039a4:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800039a6:	89da                	mv	s3,s6
    800039a8:	b7cd                	j	8000398a <writei+0xd2>
    800039aa:	64e6                	ld	s1,88(sp)
    800039ac:	7c02                	ld	s8,32(sp)
    800039ae:	6ce2                	ld	s9,24(sp)
    800039b0:	6d42                	ld	s10,16(sp)
    800039b2:	6da2                	ld	s11,8(sp)
    800039b4:	bfd9                	j	8000398a <writei+0xd2>
    return -1;
    800039b6:	557d                	li	a0,-1
}
    800039b8:	8082                	ret
    return -1;
    800039ba:	557d                	li	a0,-1
    800039bc:	bfe1                	j	80003994 <writei+0xdc>

00000000800039be <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800039be:	1141                	addi	sp,sp,-16
    800039c0:	e406                	sd	ra,8(sp)
    800039c2:	e022                	sd	s0,0(sp)
    800039c4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800039c6:	4639                	li	a2,14
    800039c8:	bf4fd0ef          	jal	80000dbc <strncmp>
}
    800039cc:	60a2                	ld	ra,8(sp)
    800039ce:	6402                	ld	s0,0(sp)
    800039d0:	0141                	addi	sp,sp,16
    800039d2:	8082                	ret

00000000800039d4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800039d4:	711d                	addi	sp,sp,-96
    800039d6:	ec86                	sd	ra,88(sp)
    800039d8:	e8a2                	sd	s0,80(sp)
    800039da:	e4a6                	sd	s1,72(sp)
    800039dc:	e0ca                	sd	s2,64(sp)
    800039de:	fc4e                	sd	s3,56(sp)
    800039e0:	f852                	sd	s4,48(sp)
    800039e2:	f456                	sd	s5,40(sp)
    800039e4:	f05a                	sd	s6,32(sp)
    800039e6:	ec5e                	sd	s7,24(sp)
    800039e8:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    800039ea:	04451703          	lh	a4,68(a0)
    800039ee:	4785                	li	a5,1
    800039f0:	00f71f63          	bne	a4,a5,80003a0e <dirlookup+0x3a>
    800039f4:	892a                	mv	s2,a0
    800039f6:	8aae                	mv	s5,a1
    800039f8:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    800039fa:	457c                	lw	a5,76(a0)
    800039fc:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039fe:	fa040a13          	addi	s4,s0,-96
    80003a02:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    80003a04:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003a08:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a0a:	e39d                	bnez	a5,80003a30 <dirlookup+0x5c>
    80003a0c:	a8b9                	j	80003a6a <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003a0e:	00004517          	auipc	a0,0x4
    80003a12:	c0a50513          	addi	a0,a0,-1014 # 80007618 <etext+0x618>
    80003a16:	e1ffc0ef          	jal	80000834 <panic>
      panic("dirlookup read");
    80003a1a:	00004517          	auipc	a0,0x4
    80003a1e:	c1650513          	addi	a0,a0,-1002 # 80007630 <etext+0x630>
    80003a22:	e13fc0ef          	jal	80000834 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a26:	24c1                	addiw	s1,s1,16
    80003a28:	04c92783          	lw	a5,76(s2)
    80003a2c:	02f4fe63          	bgeu	s1,a5,80003a68 <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a30:	874e                	mv	a4,s3
    80003a32:	86a6                	mv	a3,s1
    80003a34:	8652                	mv	a2,s4
    80003a36:	4581                	li	a1,0
    80003a38:	854a                	mv	a0,s2
    80003a3a:	d8dff0ef          	jal	800037c6 <readi>
    80003a3e:	fd351ee3          	bne	a0,s3,80003a1a <dirlookup+0x46>
    if (de.inum == 0)
    80003a42:	fa045783          	lhu	a5,-96(s0)
    80003a46:	d3e5                	beqz	a5,80003a26 <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    80003a48:	85da                	mv	a1,s6
    80003a4a:	8556                	mv	a0,s5
    80003a4c:	f73ff0ef          	jal	800039be <namecmp>
    80003a50:	f979                	bnez	a0,80003a26 <dirlookup+0x52>
      if (poff)
    80003a52:	000b8463          	beqz	s7,80003a5a <dirlookup+0x86>
        *poff = off;
    80003a56:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003a5a:	fa045583          	lhu	a1,-96(s0)
    80003a5e:	00092503          	lw	a0,0(s2)
    80003a62:	f18ff0ef          	jal	8000317a <iget>
    80003a66:	a011                	j	80003a6a <dirlookup+0x96>
  return 0;
    80003a68:	4501                	li	a0,0
}
    80003a6a:	60e6                	ld	ra,88(sp)
    80003a6c:	6446                	ld	s0,80(sp)
    80003a6e:	64a6                	ld	s1,72(sp)
    80003a70:	6906                	ld	s2,64(sp)
    80003a72:	79e2                	ld	s3,56(sp)
    80003a74:	7a42                	ld	s4,48(sp)
    80003a76:	7aa2                	ld	s5,40(sp)
    80003a78:	7b02                	ld	s6,32(sp)
    80003a7a:	6be2                	ld	s7,24(sp)
    80003a7c:	6125                	addi	sp,sp,96
    80003a7e:	8082                	ret

0000000080003a80 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003a80:	711d                	addi	sp,sp,-96
    80003a82:	ec86                	sd	ra,88(sp)
    80003a84:	e8a2                	sd	s0,80(sp)
    80003a86:	e4a6                	sd	s1,72(sp)
    80003a88:	e0ca                	sd	s2,64(sp)
    80003a8a:	fc4e                	sd	s3,56(sp)
    80003a8c:	f852                	sd	s4,48(sp)
    80003a8e:	f456                	sd	s5,40(sp)
    80003a90:	f05a                	sd	s6,32(sp)
    80003a92:	ec5e                	sd	s7,24(sp)
    80003a94:	e862                	sd	s8,16(sp)
    80003a96:	e466                	sd	s9,8(sp)
    80003a98:	e06a                	sd	s10,0(sp)
    80003a9a:	1080                	addi	s0,sp,96
    80003a9c:	84aa                	mv	s1,a0
    80003a9e:	8b2e                	mv	s6,a1
    80003aa0:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003aa2:	00054703          	lbu	a4,0(a0)
    80003aa6:	02f00793          	li	a5,47
    80003aaa:	00f70f63          	beq	a4,a5,80003ac8 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003aae:	808fe0ef          	jal	80001ab6 <myproc>
    80003ab2:	15053503          	ld	a0,336(a0)
    80003ab6:	901ff0ef          	jal	800033b6 <idup>
    80003aba:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003abc:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    80003ac0:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003ac2:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003ac4:	4b85                	li	s7,1
    80003ac6:	a07d                	j	80003b74 <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    80003ac8:	4585                	li	a1,1
    80003aca:	852e                	mv	a0,a1
    80003acc:	eaeff0ef          	jal	8000317a <iget>
    80003ad0:	8a2a                	mv	s4,a0
    80003ad2:	b7ed                	j	80003abc <namex+0x3c>
      iunlockput(ip);
    80003ad4:	8552                	mv	a0,s4
    80003ad6:	b6bff0ef          	jal	80003640 <iunlockput>
      return 0;
    80003ada:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003adc:	8552                	mv	a0,s4
    80003ade:	60e6                	ld	ra,88(sp)
    80003ae0:	6446                	ld	s0,80(sp)
    80003ae2:	64a6                	ld	s1,72(sp)
    80003ae4:	6906                	ld	s2,64(sp)
    80003ae6:	79e2                	ld	s3,56(sp)
    80003ae8:	7a42                	ld	s4,48(sp)
    80003aea:	7aa2                	ld	s5,40(sp)
    80003aec:	7b02                	ld	s6,32(sp)
    80003aee:	6be2                	ld	s7,24(sp)
    80003af0:	6c42                	ld	s8,16(sp)
    80003af2:	6ca2                	ld	s9,8(sp)
    80003af4:	6d02                	ld	s10,0(sp)
    80003af6:	6125                	addi	sp,sp,96
    80003af8:	8082                	ret
      iunlockput(ip);
    80003afa:	8552                	mv	a0,s4
    80003afc:	b45ff0ef          	jal	80003640 <iunlockput>
      return 0;
    80003b00:	4a01                	li	s4,0
    80003b02:	bfe9                	j	80003adc <namex+0x5c>
      iunlock(ip);
    80003b04:	8552                	mv	a0,s4
    80003b06:	995ff0ef          	jal	8000349a <iunlock>
      return ip;
    80003b0a:	bfc9                	j	80003adc <namex+0x5c>
      iunlockput(ip);
    80003b0c:	8552                	mv	a0,s4
    80003b0e:	b33ff0ef          	jal	80003640 <iunlockput>
      return 0;
    80003b12:	8a4a                	mv	s4,s2
    80003b14:	b7e1                	j	80003adc <namex+0x5c>
  while (*path != '/' && *path != 0)
    80003b16:	8926                	mv	s2,s1
  len = path - s;
    80003b18:	4d01                	li	s10,0
    80003b1a:	4601                	li	a2,0
    memmove(name, s, len);
    80003b1c:	2601                	sext.w	a2,a2
    80003b1e:	85a6                	mv	a1,s1
    80003b20:	8556                	mv	a0,s5
    80003b22:	a26fd0ef          	jal	80000d48 <memmove>
    name[len] = 0;
    80003b26:	9d56                	add	s10,s10,s5
    80003b28:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffdb818>
  while (*path == '/')
    80003b2c:	00094783          	lbu	a5,0(s2)
    80003b30:	09379b63          	bne	a5,s3,80003bc6 <namex+0x146>
    80003b34:	84ca                	mv	s1,s2
    path++;
    80003b36:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003b38:	0004c783          	lbu	a5,0(s1)
    80003b3c:	ff378de3          	beq	a5,s3,80003b36 <namex+0xb6>
    ilock(ip);
    80003b40:	8552                	mv	a0,s4
    80003b42:	8abff0ef          	jal	800033ec <ilock>
    if (ip->type != T_DIR) {
    80003b46:	044a1783          	lh	a5,68(s4)
    80003b4a:	f97795e3          	bne	a5,s7,80003ad4 <namex+0x54>
    if (ip->nlink == 0) {
    80003b4e:	04aa1783          	lh	a5,74(s4)
    80003b52:	d7c5                	beqz	a5,80003afa <namex+0x7a>
    if (nameiparent && *path == '\0') {
    80003b54:	000b0563          	beqz	s6,80003b5e <namex+0xde>
    80003b58:	0004c783          	lbu	a5,0(s1)
    80003b5c:	d7c5                	beqz	a5,80003b04 <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003b5e:	4601                	li	a2,0
    80003b60:	85d6                	mv	a1,s5
    80003b62:	8552                	mv	a0,s4
    80003b64:	e71ff0ef          	jal	800039d4 <dirlookup>
    80003b68:	892a                	mv	s2,a0
    80003b6a:	d14d                	beqz	a0,80003b0c <namex+0x8c>
    iunlockput(ip);
    80003b6c:	8552                	mv	a0,s4
    80003b6e:	ad3ff0ef          	jal	80003640 <iunlockput>
    ip = next;
    80003b72:	8a4a                	mv	s4,s2
  while (*path == '/')
    80003b74:	0004c783          	lbu	a5,0(s1)
    80003b78:	01379763          	bne	a5,s3,80003b86 <namex+0x106>
    path++;
    80003b7c:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003b7e:	0004c783          	lbu	a5,0(s1)
    80003b82:	ff378de3          	beq	a5,s3,80003b7c <namex+0xfc>
  if (*path == 0)
    80003b86:	c7a1                	beqz	a5,80003bce <namex+0x14e>
  while (*path != '/' && *path != 0)
    80003b88:	0004c783          	lbu	a5,0(s1)
    80003b8c:	fd178713          	addi	a4,a5,-47
    80003b90:	d359                	beqz	a4,80003b16 <namex+0x96>
    80003b92:	d3d1                	beqz	a5,80003b16 <namex+0x96>
    80003b94:	8926                	mv	s2,s1
    path++;
    80003b96:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    80003b98:	00094783          	lbu	a5,0(s2)
    80003b9c:	fd178713          	addi	a4,a5,-47
    80003ba0:	c311                	beqz	a4,80003ba4 <namex+0x124>
    80003ba2:	fbf5                	bnez	a5,80003b96 <namex+0x116>
  len = path - s;
    80003ba4:	40990633          	sub	a2,s2,s1
    80003ba8:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80003bac:	f7ac58e3          	bge	s8,s10,80003b1c <namex+0x9c>
    memmove(name, s, DIRSIZ);
    80003bb0:	8666                	mv	a2,s9
    80003bb2:	85a6                	mv	a1,s1
    80003bb4:	8556                	mv	a0,s5
    80003bb6:	992fd0ef          	jal	80000d48 <memmove>
  while (*path == '/')
    80003bba:	00094783          	lbu	a5,0(s2)
    80003bbe:	84ca                	mv	s1,s2
    80003bc0:	f7378be3          	beq	a5,s3,80003b36 <namex+0xb6>
    80003bc4:	bfb5                	j	80003b40 <namex+0xc0>
  while ((path = skipelem(path, name)) != 0) {
    80003bc6:	00090463          	beqz	s2,80003bce <namex+0x14e>
    80003bca:	84ca                	mv	s1,s2
    80003bcc:	bf95                	j	80003b40 <namex+0xc0>
  if (nameiparent) {
    80003bce:	f00b07e3          	beqz	s6,80003adc <namex+0x5c>
    iput(ip);
    80003bd2:	8552                	mv	a0,s4
    80003bd4:	99bff0ef          	jal	8000356e <iput>
    return 0;
    80003bd8:	4a01                	li	s4,0
    80003bda:	b709                	j	80003adc <namex+0x5c>

0000000080003bdc <dirlink>:
{
    80003bdc:	715d                	addi	sp,sp,-80
    80003bde:	e486                	sd	ra,72(sp)
    80003be0:	e0a2                	sd	s0,64(sp)
    80003be2:	f84a                	sd	s2,48(sp)
    80003be4:	ec56                	sd	s5,24(sp)
    80003be6:	e85a                	sd	s6,16(sp)
    80003be8:	0880                	addi	s0,sp,80
    80003bea:	892a                	mv	s2,a0
    80003bec:	8aae                	mv	s5,a1
    80003bee:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003bf0:	4601                	li	a2,0
    80003bf2:	de3ff0ef          	jal	800039d4 <dirlookup>
    80003bf6:	ed1d                	bnez	a0,80003c34 <dirlink+0x58>
    80003bf8:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003bfa:	04c92483          	lw	s1,76(s2)
    80003bfe:	c4b9                	beqz	s1,80003c4c <dirlink+0x70>
    80003c00:	f44e                	sd	s3,40(sp)
    80003c02:	f052                	sd	s4,32(sp)
    80003c04:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c06:	fb040a13          	addi	s4,s0,-80
    80003c0a:	49c1                	li	s3,16
    80003c0c:	874e                	mv	a4,s3
    80003c0e:	86a6                	mv	a3,s1
    80003c10:	8652                	mv	a2,s4
    80003c12:	4581                	li	a1,0
    80003c14:	854a                	mv	a0,s2
    80003c16:	bb1ff0ef          	jal	800037c6 <readi>
    80003c1a:	03351163          	bne	a0,s3,80003c3c <dirlink+0x60>
    if (de.inum == 0)
    80003c1e:	fb045783          	lhu	a5,-80(s0)
    80003c22:	c39d                	beqz	a5,80003c48 <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003c24:	24c1                	addiw	s1,s1,16
    80003c26:	04c92783          	lw	a5,76(s2)
    80003c2a:	fef4e1e3          	bltu	s1,a5,80003c0c <dirlink+0x30>
    80003c2e:	79a2                	ld	s3,40(sp)
    80003c30:	7a02                	ld	s4,32(sp)
    80003c32:	a829                	j	80003c4c <dirlink+0x70>
    iput(ip);
    80003c34:	93bff0ef          	jal	8000356e <iput>
    return -1;
    80003c38:	557d                	li	a0,-1
    80003c3a:	a83d                	j	80003c78 <dirlink+0x9c>
      panic("dirlink read");
    80003c3c:	00004517          	auipc	a0,0x4
    80003c40:	a0450513          	addi	a0,a0,-1532 # 80007640 <etext+0x640>
    80003c44:	bf1fc0ef          	jal	80000834 <panic>
    80003c48:	79a2                	ld	s3,40(sp)
    80003c4a:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003c4c:	4639                	li	a2,14
    80003c4e:	85d6                	mv	a1,s5
    80003c50:	fb240513          	addi	a0,s0,-78
    80003c54:	9a2fd0ef          	jal	80000df6 <strncpy>
  de.inum = inum;
    80003c58:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c5c:	4741                	li	a4,16
    80003c5e:	86a6                	mv	a3,s1
    80003c60:	fb040613          	addi	a2,s0,-80
    80003c64:	4581                	li	a1,0
    80003c66:	854a                	mv	a0,s2
    80003c68:	c51ff0ef          	jal	800038b8 <writei>
    80003c6c:	1541                	addi	a0,a0,-16
    80003c6e:	00a03533          	snez	a0,a0
    80003c72:	40a0053b          	negw	a0,a0
    80003c76:	74e2                	ld	s1,56(sp)
}
    80003c78:	60a6                	ld	ra,72(sp)
    80003c7a:	6406                	ld	s0,64(sp)
    80003c7c:	7942                	ld	s2,48(sp)
    80003c7e:	6ae2                	ld	s5,24(sp)
    80003c80:	6b42                	ld	s6,16(sp)
    80003c82:	6161                	addi	sp,sp,80
    80003c84:	8082                	ret

0000000080003c86 <namei>:

struct inode *
namei(char *path)
{
    80003c86:	1101                	addi	sp,sp,-32
    80003c88:	ec06                	sd	ra,24(sp)
    80003c8a:	e822                	sd	s0,16(sp)
    80003c8c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003c8e:	fe040613          	addi	a2,s0,-32
    80003c92:	4581                	li	a1,0
    80003c94:	dedff0ef          	jal	80003a80 <namex>
}
    80003c98:	60e2                	ld	ra,24(sp)
    80003c9a:	6442                	ld	s0,16(sp)
    80003c9c:	6105                	addi	sp,sp,32
    80003c9e:	8082                	ret

0000000080003ca0 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003ca0:	1141                	addi	sp,sp,-16
    80003ca2:	e406                	sd	ra,8(sp)
    80003ca4:	e022                	sd	s0,0(sp)
    80003ca6:	0800                	addi	s0,sp,16
    80003ca8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003caa:	4585                	li	a1,1
    80003cac:	dd5ff0ef          	jal	80003a80 <namex>
}
    80003cb0:	60a2                	ld	ra,8(sp)
    80003cb2:	6402                	ld	s0,0(sp)
    80003cb4:	0141                	addi	sp,sp,16
    80003cb6:	8082                	ret

0000000080003cb8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003cb8:	1101                	addi	sp,sp,-32
    80003cba:	ec06                	sd	ra,24(sp)
    80003cbc:	e822                	sd	s0,16(sp)
    80003cbe:	e426                	sd	s1,8(sp)
    80003cc0:	e04a                	sd	s2,0(sp)
    80003cc2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003cc4:	0001f917          	auipc	s2,0x1f
    80003cc8:	8e490913          	addi	s2,s2,-1820 # 800225a8 <log>
    80003ccc:	01892583          	lw	a1,24(s2)
    80003cd0:	02492503          	lw	a0,36(s2)
    80003cd4:	880ff0ef          	jal	80002d54 <bread>
    80003cd8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003cda:	02c92603          	lw	a2,44(s2)
    80003cde:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003ce0:	00c05f63          	blez	a2,80003cfe <write_head+0x46>
    80003ce4:	0001f717          	auipc	a4,0x1f
    80003ce8:	8f470713          	addi	a4,a4,-1804 # 800225d8 <log+0x30>
    80003cec:	87aa                	mv	a5,a0
    80003cee:	060a                	slli	a2,a2,0x2
    80003cf0:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003cf2:	4314                	lw	a3,0(a4)
    80003cf4:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003cf6:	0711                	addi	a4,a4,4
    80003cf8:	0791                	addi	a5,a5,4
    80003cfa:	fec79ce3          	bne	a5,a2,80003cf2 <write_head+0x3a>
  }
  bwrite(buf);
    80003cfe:	8526                	mv	a0,s1
    80003d00:	92aff0ef          	jal	80002e2a <bwrite>
  brelse(buf);
    80003d04:	8526                	mv	a0,s1
    80003d06:	956ff0ef          	jal	80002e5c <brelse>
}
    80003d0a:	60e2                	ld	ra,24(sp)
    80003d0c:	6442                	ld	s0,16(sp)
    80003d0e:	64a2                	ld	s1,8(sp)
    80003d10:	6902                	ld	s2,0(sp)
    80003d12:	6105                	addi	sp,sp,32
    80003d14:	8082                	ret

0000000080003d16 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d16:	0001f797          	auipc	a5,0x1f
    80003d1a:	8be7a783          	lw	a5,-1858(a5) # 800225d4 <log+0x2c>
    80003d1e:	0cf05163          	blez	a5,80003de0 <install_trans+0xca>
{
    80003d22:	715d                	addi	sp,sp,-80
    80003d24:	e486                	sd	ra,72(sp)
    80003d26:	e0a2                	sd	s0,64(sp)
    80003d28:	fc26                	sd	s1,56(sp)
    80003d2a:	f84a                	sd	s2,48(sp)
    80003d2c:	f44e                	sd	s3,40(sp)
    80003d2e:	f052                	sd	s4,32(sp)
    80003d30:	ec56                	sd	s5,24(sp)
    80003d32:	e85a                	sd	s6,16(sp)
    80003d34:	e45e                	sd	s7,8(sp)
    80003d36:	e062                	sd	s8,0(sp)
    80003d38:	0880                	addi	s0,sp,80
    80003d3a:	8b2a                	mv	s6,a0
    80003d3c:	0001fa97          	auipc	s5,0x1f
    80003d40:	89ca8a93          	addi	s5,s5,-1892 # 800225d8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d44:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d46:	00004c17          	auipc	s8,0x4
    80003d4a:	90ac0c13          	addi	s8,s8,-1782 # 80007650 <etext+0x650>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003d4e:	0001fa17          	auipc	s4,0x1f
    80003d52:	85aa0a13          	addi	s4,s4,-1958 # 800225a8 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003d56:	40000b93          	li	s7,1024
    80003d5a:	a025                	j	80003d82 <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d5c:	000aa603          	lw	a2,0(s5)
    80003d60:	85ce                	mv	a1,s3
    80003d62:	8562                	mv	a0,s8
    80003d64:	fa6fc0ef          	jal	8000050a <printk>
    80003d68:	a839                	j	80003d86 <install_trans+0x70>
    brelse(lbuf);
    80003d6a:	854a                	mv	a0,s2
    80003d6c:	8f0ff0ef          	jal	80002e5c <brelse>
    brelse(dbuf);
    80003d70:	8526                	mv	a0,s1
    80003d72:	8eaff0ef          	jal	80002e5c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d76:	2985                	addiw	s3,s3,1
    80003d78:	0a91                	addi	s5,s5,4
    80003d7a:	02ca2783          	lw	a5,44(s4)
    80003d7e:	04f9d563          	bge	s3,a5,80003dc8 <install_trans+0xb2>
    if (recovering) {
    80003d82:	fc0b1de3          	bnez	s6,80003d5c <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003d86:	018a2583          	lw	a1,24(s4)
    80003d8a:	013585bb          	addw	a1,a1,s3
    80003d8e:	2585                	addiw	a1,a1,1
    80003d90:	024a2503          	lw	a0,36(s4)
    80003d94:	fc1fe0ef          	jal	80002d54 <bread>
    80003d98:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003d9a:	000aa583          	lw	a1,0(s5)
    80003d9e:	024a2503          	lw	a0,36(s4)
    80003da2:	fb3fe0ef          	jal	80002d54 <bread>
    80003da6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003da8:	865e                	mv	a2,s7
    80003daa:	05890593          	addi	a1,s2,88
    80003dae:	05850513          	addi	a0,a0,88
    80003db2:	f97fc0ef          	jal	80000d48 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003db6:	8526                	mv	a0,s1
    80003db8:	872ff0ef          	jal	80002e2a <bwrite>
    if (recovering == 0)
    80003dbc:	fa0b17e3          	bnez	s6,80003d6a <install_trans+0x54>
      bunpin(dbuf);
    80003dc0:	8526                	mv	a0,s1
    80003dc2:	952ff0ef          	jal	80002f14 <bunpin>
    80003dc6:	b755                	j	80003d6a <install_trans+0x54>
}
    80003dc8:	60a6                	ld	ra,72(sp)
    80003dca:	6406                	ld	s0,64(sp)
    80003dcc:	74e2                	ld	s1,56(sp)
    80003dce:	7942                	ld	s2,48(sp)
    80003dd0:	79a2                	ld	s3,40(sp)
    80003dd2:	7a02                	ld	s4,32(sp)
    80003dd4:	6ae2                	ld	s5,24(sp)
    80003dd6:	6b42                	ld	s6,16(sp)
    80003dd8:	6ba2                	ld	s7,8(sp)
    80003dda:	6c02                	ld	s8,0(sp)
    80003ddc:	6161                	addi	sp,sp,80
    80003dde:	8082                	ret
    80003de0:	8082                	ret

0000000080003de2 <initlog>:
{
    80003de2:	7179                	addi	sp,sp,-48
    80003de4:	f406                	sd	ra,40(sp)
    80003de6:	f022                	sd	s0,32(sp)
    80003de8:	ec26                	sd	s1,24(sp)
    80003dea:	e84a                	sd	s2,16(sp)
    80003dec:	e44e                	sd	s3,8(sp)
    80003dee:	1800                	addi	s0,sp,48
    80003df0:	84aa                	mv	s1,a0
    80003df2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003df4:	0001e917          	auipc	s2,0x1e
    80003df8:	7b490913          	addi	s2,s2,1972 # 800225a8 <log>
    80003dfc:	00004597          	auipc	a1,0x4
    80003e00:	87458593          	addi	a1,a1,-1932 # 80007670 <etext+0x670>
    80003e04:	854a                	mv	a0,s2
    80003e06:	da3fc0ef          	jal	80000ba8 <initlock>
  log.start = sb->logstart;
    80003e0a:	0149a583          	lw	a1,20(s3)
    80003e0e:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003e12:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003e16:	8526                	mv	a0,s1
    80003e18:	f3dfe0ef          	jal	80002d54 <bread>
  log.lh.n = lh->n;
    80003e1c:	4d30                	lw	a2,88(a0)
    80003e1e:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003e22:	00c05f63          	blez	a2,80003e40 <initlog+0x5e>
    80003e26:	87aa                	mv	a5,a0
    80003e28:	0001e717          	auipc	a4,0x1e
    80003e2c:	7b070713          	addi	a4,a4,1968 # 800225d8 <log+0x30>
    80003e30:	060a                	slli	a2,a2,0x2
    80003e32:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003e34:	4ff4                	lw	a3,92(a5)
    80003e36:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e38:	0791                	addi	a5,a5,4
    80003e3a:	0711                	addi	a4,a4,4
    80003e3c:	fec79ce3          	bne	a5,a2,80003e34 <initlog+0x52>
  brelse(buf);
    80003e40:	81cff0ef          	jal	80002e5c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003e44:	4505                	li	a0,1
    80003e46:	ed1ff0ef          	jal	80003d16 <install_trans>
  log.lh.n = 0;
    80003e4a:	0001e797          	auipc	a5,0x1e
    80003e4e:	7807a523          	sw	zero,1930(a5) # 800225d4 <log+0x2c>
  write_head(); // clear the log
    80003e52:	e67ff0ef          	jal	80003cb8 <write_head>
}
    80003e56:	70a2                	ld	ra,40(sp)
    80003e58:	7402                	ld	s0,32(sp)
    80003e5a:	64e2                	ld	s1,24(sp)
    80003e5c:	6942                	ld	s2,16(sp)
    80003e5e:	69a2                	ld	s3,8(sp)
    80003e60:	6145                	addi	sp,sp,48
    80003e62:	8082                	ret

0000000080003e64 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003e64:	1101                	addi	sp,sp,-32
    80003e66:	ec06                	sd	ra,24(sp)
    80003e68:	e822                	sd	s0,16(sp)
    80003e6a:	e426                	sd	s1,8(sp)
    80003e6c:	e04a                	sd	s2,0(sp)
    80003e6e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003e70:	0001e517          	auipc	a0,0x1e
    80003e74:	73850513          	addi	a0,a0,1848 # 800225a8 <log>
    80003e78:	db1fc0ef          	jal	80000c28 <acquire>
  while (1) {
    if (log.committing) {
    80003e7c:	0001e497          	auipc	s1,0x1e
    80003e80:	72c48493          	addi	s1,s1,1836 # 800225a8 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003e84:	4979                	li	s2,30
    80003e86:	a821                	j	80003e9e <begin_op+0x3a>
      sleep_prepare(&log);
    80003e88:	8526                	mv	a0,s1
    80003e8a:	a36fe0ef          	jal	800020c0 <sleep_prepare>
      release(&log.lock);
    80003e8e:	8526                	mv	a0,s1
    80003e90:	e21fc0ef          	jal	80000cb0 <release>
      sleep();
    80003e94:	a68fe0ef          	jal	800020fc <sleep>
      acquire(&log.lock);
    80003e98:	8526                	mv	a0,s1
    80003e9a:	d8ffc0ef          	jal	80000c28 <acquire>
    if (log.committing) {
    80003e9e:	509c                	lw	a5,32(s1)
    80003ea0:	f7e5                	bnez	a5,80003e88 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003ea2:	4cd8                	lw	a4,28(s1)
    80003ea4:	2705                	addiw	a4,a4,1
    80003ea6:	0027179b          	slliw	a5,a4,0x2
    80003eaa:	9fb9                	addw	a5,a5,a4
    80003eac:	0017979b          	slliw	a5,a5,0x1
    80003eb0:	54d4                	lw	a3,44(s1)
    80003eb2:	9fb5                	addw	a5,a5,a3
    80003eb4:	00f95e63          	bge	s2,a5,80003ed0 <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003eb8:	8526                	mv	a0,s1
    80003eba:	a06fe0ef          	jal	800020c0 <sleep_prepare>
      release(&log.lock);
    80003ebe:	8526                	mv	a0,s1
    80003ec0:	df1fc0ef          	jal	80000cb0 <release>
      sleep();
    80003ec4:	a38fe0ef          	jal	800020fc <sleep>
      acquire(&log.lock);
    80003ec8:	8526                	mv	a0,s1
    80003eca:	d5ffc0ef          	jal	80000c28 <acquire>
    80003ece:	bfc1                	j	80003e9e <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003ed0:	0001e797          	auipc	a5,0x1e
    80003ed4:	6ee7aa23          	sw	a4,1780(a5) # 800225c4 <log+0x1c>
      release(&log.lock);
    80003ed8:	0001e517          	auipc	a0,0x1e
    80003edc:	6d050513          	addi	a0,a0,1744 # 800225a8 <log>
    80003ee0:	dd1fc0ef          	jal	80000cb0 <release>
      break;
    }
  }
}
    80003ee4:	60e2                	ld	ra,24(sp)
    80003ee6:	6442                	ld	s0,16(sp)
    80003ee8:	64a2                	ld	s1,8(sp)
    80003eea:	6902                	ld	s2,0(sp)
    80003eec:	6105                	addi	sp,sp,32
    80003eee:	8082                	ret

0000000080003ef0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003ef0:	7139                	addi	sp,sp,-64
    80003ef2:	fc06                	sd	ra,56(sp)
    80003ef4:	f822                	sd	s0,48(sp)
    80003ef6:	f426                	sd	s1,40(sp)
    80003ef8:	f04a                	sd	s2,32(sp)
    80003efa:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003efc:	0001e497          	auipc	s1,0x1e
    80003f00:	6ac48493          	addi	s1,s1,1708 # 800225a8 <log>
    80003f04:	8526                	mv	a0,s1
    80003f06:	d23fc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003f0a:	4cdc                	lw	a5,28(s1)
    80003f0c:	37fd                	addiw	a5,a5,-1
    80003f0e:	893e                	mv	s2,a5
    80003f10:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003f12:	509c                	lw	a5,32(s1)
    80003f14:	e3b1                	bnez	a5,80003f58 <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003f16:	04091a63          	bnez	s2,80003f6a <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    80003f1a:	0001e497          	auipc	s1,0x1e
    80003f1e:	68e48493          	addi	s1,s1,1678 # 800225a8 <log>
    80003f22:	4785                	li	a5,1
    80003f24:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003f26:	8526                	mv	a0,s1
    80003f28:	d89fc0ef          	jal	80000cb0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003f2c:	54dc                	lw	a5,44(s1)
    80003f2e:	06f04063          	bgtz	a5,80003f8e <end_op+0x9e>
    acquire(&log.lock);
    80003f32:	0001e497          	auipc	s1,0x1e
    80003f36:	67648493          	addi	s1,s1,1654 # 800225a8 <log>
    80003f3a:	8526                	mv	a0,s1
    80003f3c:	cedfc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003f40:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003f44:	549c                	lw	a5,40(s1)
    80003f46:	2785                	addiw	a5,a5,1
    80003f48:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003f4a:	8526                	mv	a0,s1
    80003f4c:	9e0fe0ef          	jal	8000212c <wakeup>
    release(&log.lock);
    80003f50:	8526                	mv	a0,s1
    80003f52:	d5ffc0ef          	jal	80000cb0 <release>
}
    80003f56:	a035                	j	80003f82 <end_op+0x92>
    80003f58:	ec4e                	sd	s3,24(sp)
    80003f5a:	e852                	sd	s4,16(sp)
    80003f5c:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003f5e:	00003517          	auipc	a0,0x3
    80003f62:	71a50513          	addi	a0,a0,1818 # 80007678 <etext+0x678>
    80003f66:	8cffc0ef          	jal	80000834 <panic>
    wakeup(&log);
    80003f6a:	0001e517          	auipc	a0,0x1e
    80003f6e:	63e50513          	addi	a0,a0,1598 # 800225a8 <log>
    80003f72:	9bafe0ef          	jal	8000212c <wakeup>
  release(&log.lock);
    80003f76:	0001e517          	auipc	a0,0x1e
    80003f7a:	63250513          	addi	a0,a0,1586 # 800225a8 <log>
    80003f7e:	d33fc0ef          	jal	80000cb0 <release>
}
    80003f82:	70e2                	ld	ra,56(sp)
    80003f84:	7442                	ld	s0,48(sp)
    80003f86:	74a2                	ld	s1,40(sp)
    80003f88:	7902                	ld	s2,32(sp)
    80003f8a:	6121                	addi	sp,sp,64
    80003f8c:	8082                	ret
    80003f8e:	ec4e                	sd	s3,24(sp)
    80003f90:	e852                	sd	s4,16(sp)
    80003f92:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f94:	0001ea97          	auipc	s5,0x1e
    80003f98:	644a8a93          	addi	s5,s5,1604 # 800225d8 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003f9c:	0001ea17          	auipc	s4,0x1e
    80003fa0:	60ca0a13          	addi	s4,s4,1548 # 800225a8 <log>
    80003fa4:	018a2583          	lw	a1,24(s4)
    80003fa8:	012585bb          	addw	a1,a1,s2
    80003fac:	2585                	addiw	a1,a1,1
    80003fae:	024a2503          	lw	a0,36(s4)
    80003fb2:	da3fe0ef          	jal	80002d54 <bread>
    80003fb6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003fb8:	000aa583          	lw	a1,0(s5)
    80003fbc:	024a2503          	lw	a0,36(s4)
    80003fc0:	d95fe0ef          	jal	80002d54 <bread>
    80003fc4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003fc6:	40000613          	li	a2,1024
    80003fca:	05850593          	addi	a1,a0,88
    80003fce:	05848513          	addi	a0,s1,88
    80003fd2:	d77fc0ef          	jal	80000d48 <memmove>
    bwrite(to); // write the log
    80003fd6:	8526                	mv	a0,s1
    80003fd8:	e53fe0ef          	jal	80002e2a <bwrite>
    brelse(from);
    80003fdc:	854e                	mv	a0,s3
    80003fde:	e7ffe0ef          	jal	80002e5c <brelse>
    brelse(to);
    80003fe2:	8526                	mv	a0,s1
    80003fe4:	e79fe0ef          	jal	80002e5c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fe8:	2905                	addiw	s2,s2,1
    80003fea:	0a91                	addi	s5,s5,4
    80003fec:	02ca2783          	lw	a5,44(s4)
    80003ff0:	faf94ae3          	blt	s2,a5,80003fa4 <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80003ff4:	cc5ff0ef          	jal	80003cb8 <write_head>
    install_trans(0); // Now install writes to home locations
    80003ff8:	4501                	li	a0,0
    80003ffa:	d1dff0ef          	jal	80003d16 <install_trans>
    log.lh.n = 0;
    80003ffe:	0001e797          	auipc	a5,0x1e
    80004002:	5c07ab23          	sw	zero,1494(a5) # 800225d4 <log+0x2c>
    write_head(); // Erase the transaction from the log
    80004006:	cb3ff0ef          	jal	80003cb8 <write_head>
    8000400a:	69e2                	ld	s3,24(sp)
    8000400c:	6a42                	ld	s4,16(sp)
    8000400e:	6aa2                	ld	s5,8(sp)
    80004010:	b70d                	j	80003f32 <end_op+0x42>

0000000080004012 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004012:	1101                	addi	sp,sp,-32
    80004014:	ec06                	sd	ra,24(sp)
    80004016:	e822                	sd	s0,16(sp)
    80004018:	e426                	sd	s1,8(sp)
    8000401a:	1000                	addi	s0,sp,32
    8000401c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000401e:	0001e517          	auipc	a0,0x1e
    80004022:	58a50513          	addi	a0,a0,1418 # 800225a8 <log>
    80004026:	c03fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    8000402a:	0001e617          	auipc	a2,0x1e
    8000402e:	5aa62603          	lw	a2,1450(a2) # 800225d4 <log+0x2c>
    80004032:	47f5                	li	a5,29
    80004034:	04c7cd63          	blt	a5,a2,8000408e <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004038:	0001e797          	auipc	a5,0x1e
    8000403c:	58c7a783          	lw	a5,1420(a5) # 800225c4 <log+0x1c>
    80004040:	04f05d63          	blez	a5,8000409a <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004044:	4781                	li	a5,0
    80004046:	06c05063          	blez	a2,800040a6 <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    8000404a:	44cc                	lw	a1,12(s1)
    8000404c:	0001e717          	auipc	a4,0x1e
    80004050:	58c70713          	addi	a4,a4,1420 # 800225d8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004054:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80004056:	4314                	lw	a3,0(a4)
    80004058:	04b68763          	beq	a3,a1,800040a6 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    8000405c:	2785                	addiw	a5,a5,1
    8000405e:	0711                	addi	a4,a4,4
    80004060:	fef61be3          	bne	a2,a5,80004056 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004064:	060a                	slli	a2,a2,0x2
    80004066:	02060613          	addi	a2,a2,32
    8000406a:	0001e797          	auipc	a5,0x1e
    8000406e:	53e78793          	addi	a5,a5,1342 # 800225a8 <log>
    80004072:	97b2                	add	a5,a5,a2
    80004074:	44d8                	lw	a4,12(s1)
    80004076:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80004078:	8526                	mv	a0,s1
    8000407a:	e67fe0ef          	jal	80002ee0 <bpin>
    log.lh.n++;
    8000407e:	0001e717          	auipc	a4,0x1e
    80004082:	52a70713          	addi	a4,a4,1322 # 800225a8 <log>
    80004086:	575c                	lw	a5,44(a4)
    80004088:	2785                	addiw	a5,a5,1
    8000408a:	d75c                	sw	a5,44(a4)
    8000408c:	a815                	j	800040c0 <log_write+0xae>
    panic("too big a transaction");
    8000408e:	00003517          	auipc	a0,0x3
    80004092:	5fa50513          	addi	a0,a0,1530 # 80007688 <etext+0x688>
    80004096:	f9efc0ef          	jal	80000834 <panic>
    panic("log_write outside of trans");
    8000409a:	00003517          	auipc	a0,0x3
    8000409e:	60650513          	addi	a0,a0,1542 # 800076a0 <etext+0x6a0>
    800040a2:	f92fc0ef          	jal	80000834 <panic>
  log.lh.block[i] = b->blockno;
    800040a6:	00279693          	slli	a3,a5,0x2
    800040aa:	02068693          	addi	a3,a3,32
    800040ae:	0001e717          	auipc	a4,0x1e
    800040b2:	4fa70713          	addi	a4,a4,1274 # 800225a8 <log>
    800040b6:	9736                	add	a4,a4,a3
    800040b8:	44d4                	lw	a3,12(s1)
    800040ba:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    800040bc:	faf60ee3          	beq	a2,a5,80004078 <log_write+0x66>
  }
  release(&log.lock);
    800040c0:	0001e517          	auipc	a0,0x1e
    800040c4:	4e850513          	addi	a0,a0,1256 # 800225a8 <log>
    800040c8:	be9fc0ef          	jal	80000cb0 <release>
}
    800040cc:	60e2                	ld	ra,24(sp)
    800040ce:	6442                	ld	s0,16(sp)
    800040d0:	64a2                	ld	s1,8(sp)
    800040d2:	6105                	addi	sp,sp,32
    800040d4:	8082                	ret

00000000800040d6 <sys_sync>:

uint64
sys_sync(void)
{
    800040d6:	1101                	addi	sp,sp,-32
    800040d8:	ec06                	sd	ra,24(sp)
    800040da:	e822                	sd	s0,16(sp)
    800040dc:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800040de:	0001e517          	auipc	a0,0x1e
    800040e2:	4ca50513          	addi	a0,a0,1226 # 800225a8 <log>
    800040e6:	b43fc0ef          	jal	80000c28 <acquire>
  if (log.committing || log.outstanding > 0) {
    800040ea:	0001e797          	auipc	a5,0x1e
    800040ee:	4de7a783          	lw	a5,1246(a5) # 800225c8 <log+0x20>
    800040f2:	e799                	bnez	a5,80004100 <sys_sync+0x2a>
    800040f4:	0001e797          	auipc	a5,0x1e
    800040f8:	4d07a783          	lw	a5,1232(a5) # 800225c4 <log+0x1c>
    800040fc:	02f05c63          	blez	a5,80004134 <sys_sync+0x5e>
    80004100:	e426                	sd	s1,8(sp)
    80004102:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    80004104:	0001e917          	auipc	s2,0x1e
    80004108:	4cc92903          	lw	s2,1228(s2) # 800225d0 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    8000410c:	0001e497          	auipc	s1,0x1e
    80004110:	49c48493          	addi	s1,s1,1180 # 800225a8 <log>
    80004114:	8526                	mv	a0,s1
    80004116:	fabfd0ef          	jal	800020c0 <sleep_prepare>
      release(&log.lock);
    8000411a:	8526                	mv	a0,s1
    8000411c:	b95fc0ef          	jal	80000cb0 <release>
      sleep();
    80004120:	fddfd0ef          	jal	800020fc <sleep>
      acquire(&log.lock);
    80004124:	8526                	mv	a0,s1
    80004126:	b03fc0ef          	jal	80000c28 <acquire>
    while (log.ncommit < n) {
    8000412a:	549c                	lw	a5,40(s1)
    8000412c:	fef954e3          	bge	s2,a5,80004114 <sys_sync+0x3e>
    80004130:	64a2                	ld	s1,8(sp)
    80004132:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    80004134:	0001e517          	auipc	a0,0x1e
    80004138:	47450513          	addi	a0,a0,1140 # 800225a8 <log>
    8000413c:	b75fc0ef          	jal	80000cb0 <release>
  return 0;
}
    80004140:	4501                	li	a0,0
    80004142:	60e2                	ld	ra,24(sp)
    80004144:	6442                	ld	s0,16(sp)
    80004146:	6105                	addi	sp,sp,32
    80004148:	8082                	ret

000000008000414a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000414a:	1101                	addi	sp,sp,-32
    8000414c:	ec06                	sd	ra,24(sp)
    8000414e:	e822                	sd	s0,16(sp)
    80004150:	e426                	sd	s1,8(sp)
    80004152:	e04a                	sd	s2,0(sp)
    80004154:	1000                	addi	s0,sp,32
    80004156:	84aa                	mv	s1,a0
    80004158:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000415a:	00003597          	auipc	a1,0x3
    8000415e:	56658593          	addi	a1,a1,1382 # 800076c0 <etext+0x6c0>
    80004162:	0521                	addi	a0,a0,8
    80004164:	a45fc0ef          	jal	80000ba8 <initlock>
  lk->name = name;
    80004168:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000416c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004170:	0204a423          	sw	zero,40(s1)
}
    80004174:	60e2                	ld	ra,24(sp)
    80004176:	6442                	ld	s0,16(sp)
    80004178:	64a2                	ld	s1,8(sp)
    8000417a:	6902                	ld	s2,0(sp)
    8000417c:	6105                	addi	sp,sp,32
    8000417e:	8082                	ret

0000000080004180 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004180:	1101                	addi	sp,sp,-32
    80004182:	ec06                	sd	ra,24(sp)
    80004184:	e822                	sd	s0,16(sp)
    80004186:	e426                	sd	s1,8(sp)
    80004188:	e04a                	sd	s2,0(sp)
    8000418a:	1000                	addi	s0,sp,32
    8000418c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000418e:	00850913          	addi	s2,a0,8
    80004192:	854a                	mv	a0,s2
    80004194:	a95fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80004198:	409c                	lw	a5,0(s1)
    8000419a:	cf91                	beqz	a5,800041b6 <acquiresleep+0x36>
    sleep_prepare(lk);
    8000419c:	8526                	mv	a0,s1
    8000419e:	f23fd0ef          	jal	800020c0 <sleep_prepare>
    release(&lk->lk);
    800041a2:	854a                	mv	a0,s2
    800041a4:	b0dfc0ef          	jal	80000cb0 <release>
    sleep();
    800041a8:	f55fd0ef          	jal	800020fc <sleep>
    acquire(&lk->lk);
    800041ac:	854a                	mv	a0,s2
    800041ae:	a7bfc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    800041b2:	409c                	lw	a5,0(s1)
    800041b4:	f7e5                	bnez	a5,8000419c <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800041b6:	4785                	li	a5,1
    800041b8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800041ba:	8fdfd0ef          	jal	80001ab6 <myproc>
    800041be:	591c                	lw	a5,48(a0)
    800041c0:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800041c2:	854a                	mv	a0,s2
    800041c4:	aedfc0ef          	jal	80000cb0 <release>
}
    800041c8:	60e2                	ld	ra,24(sp)
    800041ca:	6442                	ld	s0,16(sp)
    800041cc:	64a2                	ld	s1,8(sp)
    800041ce:	6902                	ld	s2,0(sp)
    800041d0:	6105                	addi	sp,sp,32
    800041d2:	8082                	ret

00000000800041d4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800041d4:	1101                	addi	sp,sp,-32
    800041d6:	ec06                	sd	ra,24(sp)
    800041d8:	e822                	sd	s0,16(sp)
    800041da:	e426                	sd	s1,8(sp)
    800041dc:	e04a                	sd	s2,0(sp)
    800041de:	1000                	addi	s0,sp,32
    800041e0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800041e2:	00850913          	addi	s2,a0,8
    800041e6:	854a                	mv	a0,s2
    800041e8:	a41fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    800041ec:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800041f0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800041f4:	8526                	mv	a0,s1
    800041f6:	f37fd0ef          	jal	8000212c <wakeup>
  release(&lk->lk);
    800041fa:	854a                	mv	a0,s2
    800041fc:	ab5fc0ef          	jal	80000cb0 <release>
}
    80004200:	60e2                	ld	ra,24(sp)
    80004202:	6442                	ld	s0,16(sp)
    80004204:	64a2                	ld	s1,8(sp)
    80004206:	6902                	ld	s2,0(sp)
    80004208:	6105                	addi	sp,sp,32
    8000420a:	8082                	ret

000000008000420c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000420c:	7179                	addi	sp,sp,-48
    8000420e:	f406                	sd	ra,40(sp)
    80004210:	f022                	sd	s0,32(sp)
    80004212:	ec26                	sd	s1,24(sp)
    80004214:	e84a                	sd	s2,16(sp)
    80004216:	1800                	addi	s0,sp,48
    80004218:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    8000421a:	00850913          	addi	s2,a0,8
    8000421e:	854a                	mv	a0,s2
    80004220:	a09fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004224:	409c                	lw	a5,0(s1)
    80004226:	ef81                	bnez	a5,8000423e <holdingsleep+0x32>
    80004228:	4481                	li	s1,0
  release(&lk->lk);
    8000422a:	854a                	mv	a0,s2
    8000422c:	a85fc0ef          	jal	80000cb0 <release>
  return r;
}
    80004230:	8526                	mv	a0,s1
    80004232:	70a2                	ld	ra,40(sp)
    80004234:	7402                	ld	s0,32(sp)
    80004236:	64e2                	ld	s1,24(sp)
    80004238:	6942                	ld	s2,16(sp)
    8000423a:	6145                	addi	sp,sp,48
    8000423c:	8082                	ret
    8000423e:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004240:	0284a983          	lw	s3,40(s1)
    80004244:	873fd0ef          	jal	80001ab6 <myproc>
    80004248:	5904                	lw	s1,48(a0)
    8000424a:	413484b3          	sub	s1,s1,s3
    8000424e:	0014b493          	seqz	s1,s1
    80004252:	69a2                	ld	s3,8(sp)
    80004254:	bfd9                	j	8000422a <holdingsleep+0x1e>

0000000080004256 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004256:	1141                	addi	sp,sp,-16
    80004258:	e406                	sd	ra,8(sp)
    8000425a:	e022                	sd	s0,0(sp)
    8000425c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000425e:	00003597          	auipc	a1,0x3
    80004262:	47258593          	addi	a1,a1,1138 # 800076d0 <etext+0x6d0>
    80004266:	0001e517          	auipc	a0,0x1e
    8000426a:	48a50513          	addi	a0,a0,1162 # 800226f0 <ftable>
    8000426e:	93bfc0ef          	jal	80000ba8 <initlock>
}
    80004272:	60a2                	ld	ra,8(sp)
    80004274:	6402                	ld	s0,0(sp)
    80004276:	0141                	addi	sp,sp,16
    80004278:	8082                	ret

000000008000427a <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    8000427a:	1101                	addi	sp,sp,-32
    8000427c:	ec06                	sd	ra,24(sp)
    8000427e:	e822                	sd	s0,16(sp)
    80004280:	e426                	sd	s1,8(sp)
    80004282:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004284:	0001e517          	auipc	a0,0x1e
    80004288:	46c50513          	addi	a0,a0,1132 # 800226f0 <ftable>
    8000428c:	99dfc0ef          	jal	80000c28 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004290:	0001e497          	auipc	s1,0x1e
    80004294:	47848493          	addi	s1,s1,1144 # 80022708 <ftable+0x18>
    80004298:	0001f717          	auipc	a4,0x1f
    8000429c:	41070713          	addi	a4,a4,1040 # 800236a8 <disk>
    if (f->ref == 0) {
    800042a0:	40dc                	lw	a5,4(s1)
    800042a2:	cf89                	beqz	a5,800042bc <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    800042a4:	02848493          	addi	s1,s1,40
    800042a8:	fee49ce3          	bne	s1,a4,800042a0 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800042ac:	0001e517          	auipc	a0,0x1e
    800042b0:	44450513          	addi	a0,a0,1092 # 800226f0 <ftable>
    800042b4:	9fdfc0ef          	jal	80000cb0 <release>
  return 0;
    800042b8:	4481                	li	s1,0
    800042ba:	a809                	j	800042cc <filealloc+0x52>
      f->ref = 1;
    800042bc:	4785                	li	a5,1
    800042be:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800042c0:	0001e517          	auipc	a0,0x1e
    800042c4:	43050513          	addi	a0,a0,1072 # 800226f0 <ftable>
    800042c8:	9e9fc0ef          	jal	80000cb0 <release>
}
    800042cc:	8526                	mv	a0,s1
    800042ce:	60e2                	ld	ra,24(sp)
    800042d0:	6442                	ld	s0,16(sp)
    800042d2:	64a2                	ld	s1,8(sp)
    800042d4:	6105                	addi	sp,sp,32
    800042d6:	8082                	ret

00000000800042d8 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    800042d8:	1101                	addi	sp,sp,-32
    800042da:	ec06                	sd	ra,24(sp)
    800042dc:	e822                	sd	s0,16(sp)
    800042de:	e426                	sd	s1,8(sp)
    800042e0:	1000                	addi	s0,sp,32
    800042e2:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800042e4:	0001e517          	auipc	a0,0x1e
    800042e8:	40c50513          	addi	a0,a0,1036 # 800226f0 <ftable>
    800042ec:	93dfc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    800042f0:	40dc                	lw	a5,4(s1)
    800042f2:	02f05063          	blez	a5,80004312 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800042f6:	2785                	addiw	a5,a5,1
    800042f8:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800042fa:	0001e517          	auipc	a0,0x1e
    800042fe:	3f650513          	addi	a0,a0,1014 # 800226f0 <ftable>
    80004302:	9affc0ef          	jal	80000cb0 <release>
  return f;
}
    80004306:	8526                	mv	a0,s1
    80004308:	60e2                	ld	ra,24(sp)
    8000430a:	6442                	ld	s0,16(sp)
    8000430c:	64a2                	ld	s1,8(sp)
    8000430e:	6105                	addi	sp,sp,32
    80004310:	8082                	ret
    panic("filedup");
    80004312:	00003517          	auipc	a0,0x3
    80004316:	3c650513          	addi	a0,a0,966 # 800076d8 <etext+0x6d8>
    8000431a:	d1afc0ef          	jal	80000834 <panic>

000000008000431e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000431e:	7139                	addi	sp,sp,-64
    80004320:	fc06                	sd	ra,56(sp)
    80004322:	f822                	sd	s0,48(sp)
    80004324:	f426                	sd	s1,40(sp)
    80004326:	0080                	addi	s0,sp,64
    80004328:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000432a:	0001e517          	auipc	a0,0x1e
    8000432e:	3c650513          	addi	a0,a0,966 # 800226f0 <ftable>
    80004332:	8f7fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    80004336:	40dc                	lw	a5,4(s1)
    80004338:	04f05a63          	blez	a5,8000438c <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    8000433c:	37fd                	addiw	a5,a5,-1
    8000433e:	c0dc                	sw	a5,4(s1)
    80004340:	06f04063          	bgtz	a5,800043a0 <fileclose+0x82>
    80004344:	f04a                	sd	s2,32(sp)
    80004346:	ec4e                	sd	s3,24(sp)
    80004348:	e852                	sd	s4,16(sp)
    8000434a:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000434c:	0004a903          	lw	s2,0(s1)
    80004350:	0094c783          	lbu	a5,9(s1)
    80004354:	89be                	mv	s3,a5
    80004356:	689c                	ld	a5,16(s1)
    80004358:	8a3e                	mv	s4,a5
    8000435a:	6c9c                	ld	a5,24(s1)
    8000435c:	8abe                	mv	s5,a5
  f->ref = 0;
    8000435e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004362:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004366:	0001e517          	auipc	a0,0x1e
    8000436a:	38a50513          	addi	a0,a0,906 # 800226f0 <ftable>
    8000436e:	943fc0ef          	jal	80000cb0 <release>

  if (ff.type == FD_PIPE) {
    80004372:	4785                	li	a5,1
    80004374:	04f90163          	beq	s2,a5,800043b6 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    80004378:	ffe9079b          	addiw	a5,s2,-2
    8000437c:	4705                	li	a4,1
    8000437e:	04f77563          	bgeu	a4,a5,800043c8 <fileclose+0xaa>
    80004382:	7902                	ld	s2,32(sp)
    80004384:	69e2                	ld	s3,24(sp)
    80004386:	6a42                	ld	s4,16(sp)
    80004388:	6aa2                	ld	s5,8(sp)
    8000438a:	a00d                	j	800043ac <fileclose+0x8e>
    8000438c:	f04a                	sd	s2,32(sp)
    8000438e:	ec4e                	sd	s3,24(sp)
    80004390:	e852                	sd	s4,16(sp)
    80004392:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004394:	00003517          	auipc	a0,0x3
    80004398:	34c50513          	addi	a0,a0,844 # 800076e0 <etext+0x6e0>
    8000439c:	c98fc0ef          	jal	80000834 <panic>
    release(&ftable.lock);
    800043a0:	0001e517          	auipc	a0,0x1e
    800043a4:	35050513          	addi	a0,a0,848 # 800226f0 <ftable>
    800043a8:	909fc0ef          	jal	80000cb0 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800043ac:	70e2                	ld	ra,56(sp)
    800043ae:	7442                	ld	s0,48(sp)
    800043b0:	74a2                	ld	s1,40(sp)
    800043b2:	6121                	addi	sp,sp,64
    800043b4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800043b6:	85ce                	mv	a1,s3
    800043b8:	8552                	mv	a0,s4
    800043ba:	36a000ef          	jal	80004724 <pipeclose>
    800043be:	7902                	ld	s2,32(sp)
    800043c0:	69e2                	ld	s3,24(sp)
    800043c2:	6a42                	ld	s4,16(sp)
    800043c4:	6aa2                	ld	s5,8(sp)
    800043c6:	b7dd                	j	800043ac <fileclose+0x8e>
    begin_op();
    800043c8:	a9dff0ef          	jal	80003e64 <begin_op>
    iput(ff.ip);
    800043cc:	8556                	mv	a0,s5
    800043ce:	9a0ff0ef          	jal	8000356e <iput>
    end_op();
    800043d2:	b1fff0ef          	jal	80003ef0 <end_op>
    800043d6:	7902                	ld	s2,32(sp)
    800043d8:	69e2                	ld	s3,24(sp)
    800043da:	6a42                	ld	s4,16(sp)
    800043dc:	6aa2                	ld	s5,8(sp)
    800043de:	b7f9                	j	800043ac <fileclose+0x8e>

00000000800043e0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800043e0:	715d                	addi	sp,sp,-80
    800043e2:	e486                	sd	ra,72(sp)
    800043e4:	e0a2                	sd	s0,64(sp)
    800043e6:	fc26                	sd	s1,56(sp)
    800043e8:	f052                	sd	s4,32(sp)
    800043ea:	0880                	addi	s0,sp,80
    800043ec:	84aa                	mv	s1,a0
    800043ee:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    800043f0:	ec6fd0ef          	jal	80001ab6 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    800043f4:	409c                	lw	a5,0(s1)
    800043f6:	37f9                	addiw	a5,a5,-2
    800043f8:	4705                	li	a4,1
    800043fa:	04f76963          	bltu	a4,a5,8000444c <filestat+0x6c>
    800043fe:	f84a                	sd	s2,48(sp)
    80004400:	f44e                	sd	s3,40(sp)
    80004402:	892a                	mv	s2,a0
    memset(&st, 0, sizeof(st));
    80004404:	fb840993          	addi	s3,s0,-72
    80004408:	4661                	li	a2,24
    8000440a:	4581                	li	a1,0
    8000440c:	854e                	mv	a0,s3
    8000440e:	8dbfc0ef          	jal	80000ce8 <memset>
    ilock(f->ip);
    80004412:	6c88                	ld	a0,24(s1)
    80004414:	fd9fe0ef          	jal	800033ec <ilock>
    stati(f->ip, &st);
    80004418:	85ce                	mv	a1,s3
    8000441a:	6c88                	ld	a0,24(s1)
    8000441c:	b7cff0ef          	jal	80003798 <stati>
    iunlock(f->ip);
    80004420:	6c88                	ld	a0,24(s1)
    80004422:	878ff0ef          	jal	8000349a <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    80004426:	4761                	li	a4,24
    80004428:	86ce                	mv	a3,s3
    8000442a:	8652                	mv	a2,s4
    8000442c:	04893583          	ld	a1,72(s2)
    80004430:	05093503          	ld	a0,80(s2)
    80004434:	94efd0ef          	jal	80001582 <copyout>
    80004438:	41f5551b          	sraiw	a0,a0,0x1f
    8000443c:	7942                	ld	s2,48(sp)
    8000443e:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004440:	60a6                	ld	ra,72(sp)
    80004442:	6406                	ld	s0,64(sp)
    80004444:	74e2                	ld	s1,56(sp)
    80004446:	7a02                	ld	s4,32(sp)
    80004448:	6161                	addi	sp,sp,80
    8000444a:	8082                	ret
  return -1;
    8000444c:	557d                	li	a0,-1
    8000444e:	bfcd                	j	80004440 <filestat+0x60>

0000000080004450 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004450:	7179                	addi	sp,sp,-48
    80004452:	f406                	sd	ra,40(sp)
    80004454:	f022                	sd	s0,32(sp)
    80004456:	e84a                	sd	s2,16(sp)
    80004458:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    8000445a:	00854783          	lbu	a5,8(a0)
    8000445e:	c3dd                	beqz	a5,80004504 <fileread+0xb4>
    80004460:	ec26                	sd	s1,24(sp)
    80004462:	e44e                	sd	s3,8(sp)
    80004464:	84aa                	mv	s1,a0
    80004466:	892e                	mv	s2,a1
    80004468:	89b2                	mv	s3,a2
    8000446a:	01f6579b          	srliw	a5,a2,0x1f
    8000446e:	ebc9                	bnez	a5,80004500 <fileread+0xb0>
    return -1;

  if (f->type == FD_PIPE) {
    80004470:	411c                	lw	a5,0(a0)
    80004472:	4705                	li	a4,1
    80004474:	04e78363          	beq	a5,a4,800044ba <fileread+0x6a>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    80004478:	470d                	li	a4,3
    8000447a:	04e78763          	beq	a5,a4,800044c8 <fileread+0x78>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    8000447e:	4709                	li	a4,2
    80004480:	06e79a63          	bne	a5,a4,800044f4 <fileread+0xa4>
    ilock(f->ip);
    80004484:	6d08                	ld	a0,24(a0)
    80004486:	f67fe0ef          	jal	800033ec <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000448a:	874e                	mv	a4,s3
    8000448c:	5094                	lw	a3,32(s1)
    8000448e:	864a                	mv	a2,s2
    80004490:	4585                	li	a1,1
    80004492:	6c88                	ld	a0,24(s1)
    80004494:	b32ff0ef          	jal	800037c6 <readi>
    80004498:	892a                	mv	s2,a0
    8000449a:	00a05563          	blez	a0,800044a4 <fileread+0x54>
      f->off += r;
    8000449e:	509c                	lw	a5,32(s1)
    800044a0:	9fa9                	addw	a5,a5,a0
    800044a2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800044a4:	6c88                	ld	a0,24(s1)
    800044a6:	ff5fe0ef          	jal	8000349a <iunlock>
    800044aa:	64e2                	ld	s1,24(sp)
    800044ac:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800044ae:	854a                	mv	a0,s2
    800044b0:	70a2                	ld	ra,40(sp)
    800044b2:	7402                	ld	s0,32(sp)
    800044b4:	6942                	ld	s2,16(sp)
    800044b6:	6145                	addi	sp,sp,48
    800044b8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800044ba:	6908                	ld	a0,16(a0)
    800044bc:	3e2000ef          	jal	8000489e <piperead>
    800044c0:	892a                	mv	s2,a0
    800044c2:	64e2                	ld	s1,24(sp)
    800044c4:	69a2                	ld	s3,8(sp)
    800044c6:	b7e5                	j	800044ae <fileread+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800044c8:	02451783          	lh	a5,36(a0)
    800044cc:	03079693          	slli	a3,a5,0x30
    800044d0:	92c1                	srli	a3,a3,0x30
    800044d2:	4725                	li	a4,9
    800044d4:	02d76b63          	bltu	a4,a3,8000450a <fileread+0xba>
    800044d8:	0792                	slli	a5,a5,0x4
    800044da:	0001e717          	auipc	a4,0x1e
    800044de:	17670713          	addi	a4,a4,374 # 80022650 <devsw>
    800044e2:	97ba                	add	a5,a5,a4
    800044e4:	639c                	ld	a5,0(a5)
    800044e6:	c79d                	beqz	a5,80004514 <fileread+0xc4>
    r = devsw[f->major].read(1, addr, n);
    800044e8:	4505                	li	a0,1
    800044ea:	9782                	jalr	a5
    800044ec:	892a                	mv	s2,a0
    800044ee:	64e2                	ld	s1,24(sp)
    800044f0:	69a2                	ld	s3,8(sp)
    800044f2:	bf75                	j	800044ae <fileread+0x5e>
    panic("fileread");
    800044f4:	00003517          	auipc	a0,0x3
    800044f8:	1fc50513          	addi	a0,a0,508 # 800076f0 <etext+0x6f0>
    800044fc:	b38fc0ef          	jal	80000834 <panic>
    80004500:	64e2                	ld	s1,24(sp)
    80004502:	69a2                	ld	s3,8(sp)
    return -1;
    80004504:	57fd                	li	a5,-1
    80004506:	893e                	mv	s2,a5
    80004508:	b75d                	j	800044ae <fileread+0x5e>
      return -1;
    8000450a:	57fd                	li	a5,-1
    8000450c:	893e                	mv	s2,a5
    8000450e:	64e2                	ld	s1,24(sp)
    80004510:	69a2                	ld	s3,8(sp)
    80004512:	bf71                	j	800044ae <fileread+0x5e>
    80004514:	57fd                	li	a5,-1
    80004516:	893e                	mv	s2,a5
    80004518:	64e2                	ld	s1,24(sp)
    8000451a:	69a2                	ld	s3,8(sp)
    8000451c:	bf49                	j	800044ae <fileread+0x5e>

000000008000451e <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    8000451e:	00954783          	lbu	a5,9(a0)
    80004522:	12078b63          	beqz	a5,80004658 <filewrite+0x13a>
{
    80004526:	711d                	addi	sp,sp,-96
    80004528:	ec86                	sd	ra,88(sp)
    8000452a:	e8a2                	sd	s0,80(sp)
    8000452c:	e0ca                	sd	s2,64(sp)
    8000452e:	f456                	sd	s5,40(sp)
    80004530:	f05a                	sd	s6,32(sp)
    80004532:	1080                	addi	s0,sp,96
    80004534:	892a                	mv	s2,a0
    80004536:	8b2e                	mv	s6,a1
    80004538:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    8000453a:	01f6579b          	srliw	a5,a2,0x1f
    8000453e:	0e079d63          	bnez	a5,80004638 <filewrite+0x11a>
    return -1;

  if (f->type == FD_PIPE) {
    80004542:	411c                	lw	a5,0(a0)
    80004544:	4705                	li	a4,1
    80004546:	02e78a63          	beq	a5,a4,8000457a <filewrite+0x5c>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    8000454a:	470d                	li	a4,3
    8000454c:	02e78b63          	beq	a5,a4,80004582 <filewrite+0x64>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004550:	4709                	li	a4,2
    80004552:	0ce79763          	bne	a5,a4,80004620 <filewrite+0x102>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    80004556:	0ec05763          	blez	a2,80004644 <filewrite+0x126>
    8000455a:	e4a6                	sd	s1,72(sp)
    8000455c:	fc4e                	sd	s3,56(sp)
    8000455e:	f852                	sd	s4,48(sp)
    80004560:	ec5e                	sd	s7,24(sp)
    80004562:	e862                	sd	s8,16(sp)
    80004564:	e466                	sd	s9,8(sp)
    int i = 0;
    80004566:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    80004568:	6b85                	lui	s7,0x1
    8000456a:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000456e:	6785                	lui	a5,0x1
    80004570:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004574:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004576:	4c05                	li	s8,1
    80004578:	a8ad                	j	800045f2 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    8000457a:	6908                	ld	a0,16(a0)
    8000457c:	206000ef          	jal	80004782 <pipewrite>
    80004580:	a849                	j	80004612 <filewrite+0xf4>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004582:	02451783          	lh	a5,36(a0)
    80004586:	03079693          	slli	a3,a5,0x30
    8000458a:	92c1                	srli	a3,a3,0x30
    8000458c:	4725                	li	a4,9
    8000458e:	0ad76763          	bltu	a4,a3,8000463c <filewrite+0x11e>
    80004592:	0792                	slli	a5,a5,0x4
    80004594:	0001e717          	auipc	a4,0x1e
    80004598:	0bc70713          	addi	a4,a4,188 # 80022650 <devsw>
    8000459c:	97ba                	add	a5,a5,a4
    8000459e:	679c                	ld	a5,8(a5)
    800045a0:	c3c5                	beqz	a5,80004640 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800045a2:	4505                	li	a0,1
    800045a4:	9782                	jalr	a5
    800045a6:	a0b5                	j	80004612 <filewrite+0xf4>
      if (n1 > max)
    800045a8:	2981                	sext.w	s3,s3
      begin_op();
    800045aa:	8bbff0ef          	jal	80003e64 <begin_op>
      ilock(f->ip);
    800045ae:	01893503          	ld	a0,24(s2)
    800045b2:	e3bfe0ef          	jal	800033ec <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800045b6:	874e                	mv	a4,s3
    800045b8:	02092683          	lw	a3,32(s2)
    800045bc:	016a0633          	add	a2,s4,s6
    800045c0:	85e2                	mv	a1,s8
    800045c2:	01893503          	ld	a0,24(s2)
    800045c6:	af2ff0ef          	jal	800038b8 <writei>
    800045ca:	84aa                	mv	s1,a0
    800045cc:	00a05763          	blez	a0,800045da <filewrite+0xbc>
        f->off += r;
    800045d0:	02092783          	lw	a5,32(s2)
    800045d4:	9fa9                	addw	a5,a5,a0
    800045d6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800045da:	01893503          	ld	a0,24(s2)
    800045de:	ebdfe0ef          	jal	8000349a <iunlock>
      end_op();
    800045e2:	90fff0ef          	jal	80003ef0 <end_op>

      if (r != n1) {
    800045e6:	00999d63          	bne	s3,s1,80004600 <filewrite+0xe2>
        // error from writei
        break;
      }
      i += r;
    800045ea:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    800045ee:	015a5963          	bge	s4,s5,80004600 <filewrite+0xe2>
      int n1 = n - i;
    800045f2:	414a87bb          	subw	a5,s5,s4
    800045f6:	89be                	mv	s3,a5
      if (n1 > max)
    800045f8:	fafbd8e3          	bge	s7,a5,800045a8 <filewrite+0x8a>
    800045fc:	89e6                	mv	s3,s9
    800045fe:	b76d                	j	800045a8 <filewrite+0x8a>
    }
    ret = (i == n ? n : -1);
    80004600:	054a9463          	bne	s5,s4,80004648 <filewrite+0x12a>
    80004604:	8556                	mv	a0,s5
    80004606:	64a6                	ld	s1,72(sp)
    80004608:	79e2                	ld	s3,56(sp)
    8000460a:	7a42                	ld	s4,48(sp)
    8000460c:	6be2                	ld	s7,24(sp)
    8000460e:	6c42                	ld	s8,16(sp)
    80004610:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004612:	60e6                	ld	ra,88(sp)
    80004614:	6446                	ld	s0,80(sp)
    80004616:	6906                	ld	s2,64(sp)
    80004618:	7aa2                	ld	s5,40(sp)
    8000461a:	7b02                	ld	s6,32(sp)
    8000461c:	6125                	addi	sp,sp,96
    8000461e:	8082                	ret
    80004620:	e4a6                	sd	s1,72(sp)
    80004622:	fc4e                	sd	s3,56(sp)
    80004624:	f852                	sd	s4,48(sp)
    80004626:	ec5e                	sd	s7,24(sp)
    80004628:	e862                	sd	s8,16(sp)
    8000462a:	e466                	sd	s9,8(sp)
    panic("filewrite");
    8000462c:	00003517          	auipc	a0,0x3
    80004630:	0d450513          	addi	a0,a0,212 # 80007700 <etext+0x700>
    80004634:	a00fc0ef          	jal	80000834 <panic>
    return -1;
    80004638:	557d                	li	a0,-1
    8000463a:	bfe1                	j	80004612 <filewrite+0xf4>
      return -1;
    8000463c:	557d                	li	a0,-1
    8000463e:	bfd1                	j	80004612 <filewrite+0xf4>
    80004640:	557d                	li	a0,-1
    80004642:	bfc1                	j	80004612 <filewrite+0xf4>
    ret = (i == n ? n : -1);
    80004644:	8532                	mv	a0,a2
    80004646:	b7f1                	j	80004612 <filewrite+0xf4>
    80004648:	557d                	li	a0,-1
    8000464a:	64a6                	ld	s1,72(sp)
    8000464c:	79e2                	ld	s3,56(sp)
    8000464e:	7a42                	ld	s4,48(sp)
    80004650:	6be2                	ld	s7,24(sp)
    80004652:	6c42                	ld	s8,16(sp)
    80004654:	6ca2                	ld	s9,8(sp)
    80004656:	bf75                	j	80004612 <filewrite+0xf4>
    return -1;
    80004658:	557d                	li	a0,-1
}
    8000465a:	8082                	ret

000000008000465c <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000465c:	7179                	addi	sp,sp,-48
    8000465e:	f406                	sd	ra,40(sp)
    80004660:	f022                	sd	s0,32(sp)
    80004662:	ec26                	sd	s1,24(sp)
    80004664:	e052                	sd	s4,0(sp)
    80004666:	1800                	addi	s0,sp,48
    80004668:	84aa                	mv	s1,a0
    8000466a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000466c:	0005b023          	sd	zero,0(a1)
    80004670:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004674:	c07ff0ef          	jal	8000427a <filealloc>
    80004678:	e088                	sd	a0,0(s1)
    8000467a:	c549                	beqz	a0,80004704 <pipealloc+0xa8>
    8000467c:	bffff0ef          	jal	8000427a <filealloc>
    80004680:	00aa3023          	sd	a0,0(s4)
    80004684:	cd25                	beqz	a0,800046fc <pipealloc+0xa0>
    80004686:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    80004688:	cc6fc0ef          	jal	80000b4e <kalloc>
    8000468c:	892a                	mv	s2,a0
    8000468e:	c12d                	beqz	a0,800046f0 <pipealloc+0x94>
    80004690:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004692:	4985                	li	s3,1
    80004694:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004698:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000469c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800046a0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800046a4:	00003597          	auipc	a1,0x3
    800046a8:	06c58593          	addi	a1,a1,108 # 80007710 <etext+0x710>
    800046ac:	cfcfc0ef          	jal	80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    800046b0:	609c                	ld	a5,0(s1)
    800046b2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800046b6:	609c                	ld	a5,0(s1)
    800046b8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800046bc:	609c                	ld	a5,0(s1)
    800046be:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800046c2:	609c                	ld	a5,0(s1)
    800046c4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800046c8:	000a3783          	ld	a5,0(s4)
    800046cc:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800046d0:	000a3783          	ld	a5,0(s4)
    800046d4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800046d8:	000a3783          	ld	a5,0(s4)
    800046dc:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800046e0:	000a3783          	ld	a5,0(s4)
    800046e4:	0127b823          	sd	s2,16(a5)
  return 0;
    800046e8:	4501                	li	a0,0
    800046ea:	6942                	ld	s2,16(sp)
    800046ec:	69a2                	ld	s3,8(sp)
    800046ee:	a01d                	j	80004714 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    800046f0:	6088                	ld	a0,0(s1)
    800046f2:	c119                	beqz	a0,800046f8 <pipealloc+0x9c>
    800046f4:	6942                	ld	s2,16(sp)
    800046f6:	a029                	j	80004700 <pipealloc+0xa4>
    800046f8:	6942                	ld	s2,16(sp)
    800046fa:	a029                	j	80004704 <pipealloc+0xa8>
    800046fc:	6088                	ld	a0,0(s1)
    800046fe:	c10d                	beqz	a0,80004720 <pipealloc+0xc4>
    fileclose(*f0);
    80004700:	c1fff0ef          	jal	8000431e <fileclose>
  if (*f1)
    80004704:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004708:	557d                	li	a0,-1
  if (*f1)
    8000470a:	c789                	beqz	a5,80004714 <pipealloc+0xb8>
    fileclose(*f1);
    8000470c:	853e                	mv	a0,a5
    8000470e:	c11ff0ef          	jal	8000431e <fileclose>
  return -1;
    80004712:	557d                	li	a0,-1
}
    80004714:	70a2                	ld	ra,40(sp)
    80004716:	7402                	ld	s0,32(sp)
    80004718:	64e2                	ld	s1,24(sp)
    8000471a:	6a02                	ld	s4,0(sp)
    8000471c:	6145                	addi	sp,sp,48
    8000471e:	8082                	ret
  return -1;
    80004720:	557d                	li	a0,-1
    80004722:	bfcd                	j	80004714 <pipealloc+0xb8>

0000000080004724 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004724:	1101                	addi	sp,sp,-32
    80004726:	ec06                	sd	ra,24(sp)
    80004728:	e822                	sd	s0,16(sp)
    8000472a:	e426                	sd	s1,8(sp)
    8000472c:	e04a                	sd	s2,0(sp)
    8000472e:	1000                	addi	s0,sp,32
    80004730:	84aa                	mv	s1,a0
    80004732:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004734:	cf4fc0ef          	jal	80000c28 <acquire>
  if (writable) {
    80004738:	02090763          	beqz	s2,80004766 <pipeclose+0x42>
    pi->writeopen = 0;
    8000473c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004740:	21848513          	addi	a0,s1,536
    80004744:	9e9fd0ef          	jal	8000212c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    80004748:	2204a783          	lw	a5,544(s1)
    8000474c:	e781                	bnez	a5,80004754 <pipeclose+0x30>
    8000474e:	2244a783          	lw	a5,548(s1)
    80004752:	c38d                	beqz	a5,80004774 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    80004754:	8526                	mv	a0,s1
    80004756:	d5afc0ef          	jal	80000cb0 <release>
}
    8000475a:	60e2                	ld	ra,24(sp)
    8000475c:	6442                	ld	s0,16(sp)
    8000475e:	64a2                	ld	s1,8(sp)
    80004760:	6902                	ld	s2,0(sp)
    80004762:	6105                	addi	sp,sp,32
    80004764:	8082                	ret
    pi->readopen = 0;
    80004766:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000476a:	21c48513          	addi	a0,s1,540
    8000476e:	9bffd0ef          	jal	8000212c <wakeup>
    80004772:	bfd9                	j	80004748 <pipeclose+0x24>
    release(&pi->lock);
    80004774:	8526                	mv	a0,s1
    80004776:	d3afc0ef          	jal	80000cb0 <release>
    kfree((char *)pi);
    8000477a:	8526                	mv	a0,s1
    8000477c:	aeafc0ef          	jal	80000a66 <kfree>
    80004780:	bfe9                	j	8000475a <pipeclose+0x36>

0000000080004782 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004782:	7159                	addi	sp,sp,-112
    80004784:	f486                	sd	ra,104(sp)
    80004786:	f0a2                	sd	s0,96(sp)
    80004788:	eca6                	sd	s1,88(sp)
    8000478a:	e8ca                	sd	s2,80(sp)
    8000478c:	e4ce                	sd	s3,72(sp)
    8000478e:	e0d2                	sd	s4,64(sp)
    80004790:	fc56                	sd	s5,56(sp)
    80004792:	1880                	addi	s0,sp,112
    80004794:	84aa                	mv	s1,a0
    80004796:	8aae                	mv	s5,a1
    80004798:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000479a:	b1cfd0ef          	jal	80001ab6 <myproc>
    8000479e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800047a0:	8526                	mv	a0,s1
    800047a2:	c86fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    800047a6:	0f405a63          	blez	s4,8000489a <pipewrite+0x118>
    800047aa:	f85a                	sd	s6,48(sp)
    800047ac:	f45e                	sd	s7,40(sp)
    800047ae:	f062                	sd	s8,32(sp)
    800047b0:	ec66                	sd	s9,24(sp)
    800047b2:	e86a                	sd	s10,16(sp)
  int i = 0;
    800047b4:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    800047b6:	f9f40c13          	addi	s8,s0,-97
    800047ba:	4b85                	li	s7,1
    800047bc:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800047be:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    800047c2:	21c48c93          	addi	s9,s1,540
    800047c6:	a0a1                	j	8000480e <pipewrite+0x8c>
      release(&pi->lock);
    800047c8:	8526                	mv	a0,s1
    800047ca:	ce6fc0ef          	jal	80000cb0 <release>
      return -1;
    800047ce:	597d                	li	s2,-1
    800047d0:	7b42                	ld	s6,48(sp)
    800047d2:	7ba2                	ld	s7,40(sp)
    800047d4:	7c02                	ld	s8,32(sp)
    800047d6:	6ce2                	ld	s9,24(sp)
    800047d8:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800047da:	854a                	mv	a0,s2
    800047dc:	70a6                	ld	ra,104(sp)
    800047de:	7406                	ld	s0,96(sp)
    800047e0:	64e6                	ld	s1,88(sp)
    800047e2:	6946                	ld	s2,80(sp)
    800047e4:	69a6                	ld	s3,72(sp)
    800047e6:	6a06                	ld	s4,64(sp)
    800047e8:	7ae2                	ld	s5,56(sp)
    800047ea:	6165                	addi	sp,sp,112
    800047ec:	8082                	ret
      wakeup(&pi->nread);
    800047ee:	856a                	mv	a0,s10
    800047f0:	93dfd0ef          	jal	8000212c <wakeup>
      sleep_prepare(&pi->nwrite);
    800047f4:	8566                	mv	a0,s9
    800047f6:	8cbfd0ef          	jal	800020c0 <sleep_prepare>
      release(&pi->lock);
    800047fa:	8526                	mv	a0,s1
    800047fc:	cb4fc0ef          	jal	80000cb0 <release>
      sleep();
    80004800:	8fdfd0ef          	jal	800020fc <sleep>
      acquire(&pi->lock);
    80004804:	8526                	mv	a0,s1
    80004806:	c22fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    8000480a:	07495b63          	bge	s2,s4,80004880 <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    8000480e:	2204a783          	lw	a5,544(s1)
    80004812:	dbdd                	beqz	a5,800047c8 <pipewrite+0x46>
    80004814:	854e                	mv	a0,s3
    80004816:	b09fd0ef          	jal	8000231e <killed>
    8000481a:	f55d                	bnez	a0,800047c8 <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    8000481c:	2184a783          	lw	a5,536(s1)
    80004820:	21c4a703          	lw	a4,540(s1)
    80004824:	2007879b          	addiw	a5,a5,512
    80004828:	fcf703e3          	beq	a4,a5,800047ee <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    8000482c:	875e                	mv	a4,s7
    8000482e:	015906b3          	add	a3,s2,s5
    80004832:	8662                	mv	a2,s8
    80004834:	0489b583          	ld	a1,72(s3)
    80004838:	0509b503          	ld	a0,80(s3)
    8000483c:	e0dfc0ef          	jal	80001648 <copyin>
    80004840:	03650163          	beq	a0,s6,80004862 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004844:	21c4a783          	lw	a5,540(s1)
    80004848:	0017871b          	addiw	a4,a5,1
    8000484c:	20e4ae23          	sw	a4,540(s1)
    80004850:	1ff7f793          	andi	a5,a5,511
    80004854:	97a6                	add	a5,a5,s1
    80004856:	f9f44703          	lbu	a4,-97(s0)
    8000485a:	00e78c23          	sb	a4,24(a5)
      i++;
    8000485e:	2905                	addiw	s2,s2,1
    80004860:	b76d                	j	8000480a <pipewrite+0x88>
        if (i == 0)
    80004862:	00090863          	beqz	s2,80004872 <pipewrite+0xf0>
    80004866:	7b42                	ld	s6,48(sp)
    80004868:	7ba2                	ld	s7,40(sp)
    8000486a:	7c02                	ld	s8,32(sp)
    8000486c:	6ce2                	ld	s9,24(sp)
    8000486e:	6d42                	ld	s10,16(sp)
    80004870:	a829                	j	8000488a <pipewrite+0x108>
          i = -1;
    80004872:	892a                	mv	s2,a0
        break;
    80004874:	7b42                	ld	s6,48(sp)
    80004876:	7ba2                	ld	s7,40(sp)
    80004878:	7c02                	ld	s8,32(sp)
    8000487a:	6ce2                	ld	s9,24(sp)
    8000487c:	6d42                	ld	s10,16(sp)
    8000487e:	a031                	j	8000488a <pipewrite+0x108>
    80004880:	7b42                	ld	s6,48(sp)
    80004882:	7ba2                	ld	s7,40(sp)
    80004884:	7c02                	ld	s8,32(sp)
    80004886:	6ce2                	ld	s9,24(sp)
    80004888:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    8000488a:	21848513          	addi	a0,s1,536
    8000488e:	89ffd0ef          	jal	8000212c <wakeup>
  release(&pi->lock);
    80004892:	8526                	mv	a0,s1
    80004894:	c1cfc0ef          	jal	80000cb0 <release>
  return i;
    80004898:	b789                	j	800047da <pipewrite+0x58>
  int i = 0;
    8000489a:	4901                	li	s2,0
    8000489c:	b7fd                	j	8000488a <pipewrite+0x108>

000000008000489e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000489e:	711d                	addi	sp,sp,-96
    800048a0:	ec86                	sd	ra,88(sp)
    800048a2:	e8a2                	sd	s0,80(sp)
    800048a4:	e4a6                	sd	s1,72(sp)
    800048a6:	e0ca                	sd	s2,64(sp)
    800048a8:	fc4e                	sd	s3,56(sp)
    800048aa:	f852                	sd	s4,48(sp)
    800048ac:	f456                	sd	s5,40(sp)
    800048ae:	1080                	addi	s0,sp,96
    800048b0:	84aa                	mv	s1,a0
    800048b2:	89ae                	mv	s3,a1
    800048b4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800048b6:	a00fd0ef          	jal	80001ab6 <myproc>
    800048ba:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    800048bc:	8526                	mv	a0,s1
    800048be:	b6afc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800048c2:	0d505263          	blez	s5,80004986 <piperead+0xe8>
    800048c6:	2184a703          	lw	a4,536(s1)
    800048ca:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    800048ce:	21848a13          	addi	s4,s1,536
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800048d2:	02f71e63          	bne	a4,a5,8000490e <piperead+0x70>
    800048d6:	2244a783          	lw	a5,548(s1)
    800048da:	c3b9                	beqz	a5,80004920 <piperead+0x82>
    if (killed(pr)) {
    800048dc:	854a                	mv	a0,s2
    800048de:	a41fd0ef          	jal	8000231e <killed>
    800048e2:	e915                	bnez	a0,80004916 <piperead+0x78>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    800048e4:	8552                	mv	a0,s4
    800048e6:	fdafd0ef          	jal	800020c0 <sleep_prepare>
    release(&pi->lock);
    800048ea:	8526                	mv	a0,s1
    800048ec:	bc4fc0ef          	jal	80000cb0 <release>
    sleep();
    800048f0:	80dfd0ef          	jal	800020fc <sleep>
    acquire(&pi->lock);
    800048f4:	8526                	mv	a0,s1
    800048f6:	b32fc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800048fa:	2184a703          	lw	a4,536(s1)
    800048fe:	21c4a783          	lw	a5,540(s1)
    80004902:	fcf70ae3          	beq	a4,a5,800048d6 <piperead+0x38>
    80004906:	f05a                	sd	s6,32(sp)
    80004908:	ec5e                	sd	s7,24(sp)
    8000490a:	e862                	sd	s8,16(sp)
    8000490c:	a829                	j	80004926 <piperead+0x88>
    8000490e:	f05a                	sd	s6,32(sp)
    80004910:	ec5e                	sd	s7,24(sp)
    80004912:	e862                	sd	s8,16(sp)
    80004914:	a809                	j	80004926 <piperead+0x88>
      release(&pi->lock);
    80004916:	8526                	mv	a0,s1
    80004918:	b98fc0ef          	jal	80000cb0 <release>
      return -1;
    8000491c:	5a7d                	li	s4,-1
    8000491e:	a8a5                	j	80004996 <piperead+0xf8>
    80004920:	f05a                	sd	s6,32(sp)
    80004922:	ec5e                	sd	s7,24(sp)
    80004924:	e862                	sd	s8,16(sp)
{
    80004926:	4a01                	li	s4,0
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004928:	faf40c13          	addi	s8,s0,-81
    8000492c:	4b85                	li	s7,1
    8000492e:	5b7d                	li	s6,-1
    if (pi->nread == pi->nwrite)
    80004930:	2184a783          	lw	a5,536(s1)
    80004934:	21c4a703          	lw	a4,540(s1)
    80004938:	06f70e63          	beq	a4,a5,800049b4 <piperead+0x116>
    ch = pi->data[pi->nread % PIPESIZE];
    8000493c:	1ff7f793          	andi	a5,a5,511
    80004940:	97a6                	add	a5,a5,s1
    80004942:	0187c783          	lbu	a5,24(a5)
    80004946:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    8000494a:	875e                	mv	a4,s7
    8000494c:	86e2                	mv	a3,s8
    8000494e:	864e                	mv	a2,s3
    80004950:	04893583          	ld	a1,72(s2)
    80004954:	05093503          	ld	a0,80(s2)
    80004958:	c2bfc0ef          	jal	80001582 <copyout>
    8000495c:	01650f63          	beq	a0,s6,8000497a <piperead+0xdc>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004960:	2184a783          	lw	a5,536(s1)
    80004964:	2785                	addiw	a5,a5,1
    80004966:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    8000496a:	2a05                	addiw	s4,s4,1
    8000496c:	0985                	addi	s3,s3,1
    8000496e:	fd4a91e3          	bne	s5,s4,80004930 <piperead+0x92>
    80004972:	7b02                	ld	s6,32(sp)
    80004974:	6be2                	ld	s7,24(sp)
    80004976:	6c42                	ld	s8,16(sp)
    80004978:	a801                	j	80004988 <piperead+0xea>
      if (i == 0)
    8000497a:	020a0863          	beqz	s4,800049aa <piperead+0x10c>
    8000497e:	7b02                	ld	s6,32(sp)
    80004980:	6be2                	ld	s7,24(sp)
    80004982:	6c42                	ld	s8,16(sp)
    80004984:	a011                	j	80004988 <piperead+0xea>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004986:	4a01                	li	s4,0
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    80004988:	21c48513          	addi	a0,s1,540
    8000498c:	fa0fd0ef          	jal	8000212c <wakeup>
  release(&pi->lock);
    80004990:	8526                	mv	a0,s1
    80004992:	b1efc0ef          	jal	80000cb0 <release>
  return i;
}
    80004996:	8552                	mv	a0,s4
    80004998:	60e6                	ld	ra,88(sp)
    8000499a:	6446                	ld	s0,80(sp)
    8000499c:	64a6                	ld	s1,72(sp)
    8000499e:	6906                	ld	s2,64(sp)
    800049a0:	79e2                	ld	s3,56(sp)
    800049a2:	7a42                	ld	s4,48(sp)
    800049a4:	7aa2                	ld	s5,40(sp)
    800049a6:	6125                	addi	sp,sp,96
    800049a8:	8082                	ret
        i = -1;
    800049aa:	8a2a                	mv	s4,a0
    800049ac:	7b02                	ld	s6,32(sp)
    800049ae:	6be2                	ld	s7,24(sp)
    800049b0:	6c42                	ld	s8,16(sp)
    800049b2:	bfd9                	j	80004988 <piperead+0xea>
    800049b4:	7b02                	ld	s6,32(sp)
    800049b6:	6be2                	ld	s7,24(sp)
    800049b8:	6c42                	ld	s8,16(sp)
    800049ba:	b7f9                	j	80004988 <piperead+0xea>

00000000800049bc <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    800049bc:	1141                	addi	sp,sp,-16
    800049be:	e406                	sd	ra,8(sp)
    800049c0:	e022                	sd	s0,0(sp)
    800049c2:	0800                	addi	s0,sp,16
    800049c4:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    800049c6:	0035151b          	slliw	a0,a0,0x3
    800049ca:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    800049cc:	8b89                	andi	a5,a5,2
    800049ce:	c399                	beqz	a5,800049d4 <flags2perm+0x18>
    perm |= PTE_W;
    800049d0:	00456513          	ori	a0,a0,4
  return perm;
}
    800049d4:	60a2                	ld	ra,8(sp)
    800049d6:	6402                	ld	s0,0(sp)
    800049d8:	0141                	addi	sp,sp,16
    800049da:	8082                	ret

00000000800049dc <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800049dc:	de010113          	addi	sp,sp,-544
    800049e0:	20113c23          	sd	ra,536(sp)
    800049e4:	20813823          	sd	s0,528(sp)
    800049e8:	20913423          	sd	s1,520(sp)
    800049ec:	21213023          	sd	s2,512(sp)
    800049f0:	1400                	addi	s0,sp,544
    800049f2:	892a                	mv	s2,a0
    800049f4:	dea43823          	sd	a0,-528(s0)
    800049f8:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800049fc:	8bafd0ef          	jal	80001ab6 <myproc>
    80004a00:	84aa                	mv	s1,a0

  begin_op();
    80004a02:	c62ff0ef          	jal	80003e64 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    80004a06:	854a                	mv	a0,s2
    80004a08:	a7eff0ef          	jal	80003c86 <namei>
    80004a0c:	cd21                	beqz	a0,80004a64 <kexec+0x88>
    80004a0e:	fbd2                	sd	s4,496(sp)
    80004a10:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004a12:	9dbfe0ef          	jal	800033ec <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004a16:	04000713          	li	a4,64
    80004a1a:	4681                	li	a3,0
    80004a1c:	e5040613          	addi	a2,s0,-432
    80004a20:	4581                	li	a1,0
    80004a22:	8552                	mv	a0,s4
    80004a24:	da3fe0ef          	jal	800037c6 <readi>
    80004a28:	04000793          	li	a5,64
    80004a2c:	00f51a63          	bne	a0,a5,80004a40 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004a30:	e5042703          	lw	a4,-432(s0)
    80004a34:	464c47b7          	lui	a5,0x464c4
    80004a38:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004a3c:	02f70863          	beq	a4,a5,80004a6c <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    80004a40:	8552                	mv	a0,s4
    80004a42:	bfffe0ef          	jal	80003640 <iunlockput>
    end_op();
    80004a46:	caaff0ef          	jal	80003ef0 <end_op>
  }
  return -1;
    80004a4a:	557d                	li	a0,-1
    80004a4c:	7a5e                	ld	s4,496(sp)
}
    80004a4e:	21813083          	ld	ra,536(sp)
    80004a52:	21013403          	ld	s0,528(sp)
    80004a56:	20813483          	ld	s1,520(sp)
    80004a5a:	20013903          	ld	s2,512(sp)
    80004a5e:	22010113          	addi	sp,sp,544
    80004a62:	8082                	ret
    end_op();
    80004a64:	c8cff0ef          	jal	80003ef0 <end_op>
    return -1;
    80004a68:	557d                	li	a0,-1
    80004a6a:	b7d5                	j	80004a4e <kexec+0x72>
    80004a6c:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004a6e:	8526                	mv	a0,s1
    80004a70:	94cfd0ef          	jal	80001bbc <proc_pagetable>
    80004a74:	8b2a                	mv	s6,a0
    80004a76:	26050e63          	beqz	a0,80004cf2 <kexec+0x316>
    80004a7a:	ffce                	sd	s3,504(sp)
    80004a7c:	f7d6                	sd	s5,488(sp)
    80004a7e:	efde                	sd	s7,472(sp)
    80004a80:	ebe2                	sd	s8,464(sp)
    80004a82:	e7e6                	sd	s9,456(sp)
    80004a84:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004a86:	e8845783          	lhu	a5,-376(s0)
    80004a8a:	14078263          	beqz	a5,80004bce <kexec+0x1f2>
    80004a8e:	ff6e                	sd	s11,440(sp)
    80004a90:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a94:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004a96:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a98:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    80004a9c:	6c85                	lui	s9,0x1
    80004a9e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004aa2:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    80004aa6:	6a85                	lui	s5,0x1
    80004aa8:	a085                	j	80004b08 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004aaa:	00003517          	auipc	a0,0x3
    80004aae:	c6e50513          	addi	a0,a0,-914 # 80007718 <etext+0x718>
    80004ab2:	d83fb0ef          	jal	80000834 <panic>
    if (sz - i < PGSIZE)
    80004ab6:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004ab8:	874a                	mv	a4,s2
    80004aba:	009b86bb          	addw	a3,s7,s1
    80004abe:	4581                	li	a1,0
    80004ac0:	8552                	mv	a0,s4
    80004ac2:	d05fe0ef          	jal	800037c6 <readi>
    80004ac6:	22a91a63          	bne	s2,a0,80004cfa <kexec+0x31e>
  for (i = 0; i < sz; i += PGSIZE) {
    80004aca:	009a84bb          	addw	s1,s5,s1
    80004ace:	0334f263          	bgeu	s1,s3,80004af2 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004ad2:	02049593          	slli	a1,s1,0x20
    80004ad6:	9181                	srli	a1,a1,0x20
    80004ad8:	95e2                	add	a1,a1,s8
    80004ada:	855a                	mv	a0,s6
    80004adc:	d3cfc0ef          	jal	80001018 <walkaddr>
    80004ae0:	862a                	mv	a2,a0
    if (pa == 0)
    80004ae2:	d561                	beqz	a0,80004aaa <kexec+0xce>
    if (sz - i < PGSIZE)
    80004ae4:	409987bb          	subw	a5,s3,s1
    80004ae8:	893e                	mv	s2,a5
    80004aea:	fcfcf6e3          	bgeu	s9,a5,80004ab6 <kexec+0xda>
    80004aee:	8956                	mv	s2,s5
    80004af0:	b7d9                	j	80004ab6 <kexec+0xda>
    sz = sz1;
    80004af2:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004af6:	2d05                	addiw	s10,s10,1
    80004af8:	e0843783          	ld	a5,-504(s0)
    80004afc:	0387869b          	addiw	a3,a5,56
    80004b00:	e8845783          	lhu	a5,-376(s0)
    80004b04:	06fd5d63          	bge	s10,a5,80004b7e <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004b08:	e0d43423          	sd	a3,-504(s0)
    80004b0c:	876e                	mv	a4,s11
    80004b0e:	e1840613          	addi	a2,s0,-488
    80004b12:	4581                	li	a1,0
    80004b14:	8552                	mv	a0,s4
    80004b16:	cb1fe0ef          	jal	800037c6 <readi>
    80004b1a:	1db51e63          	bne	a0,s11,80004cf6 <kexec+0x31a>
    if (ph.type != ELF_PROG_LOAD)
    80004b1e:	e1842783          	lw	a5,-488(s0)
    80004b22:	4705                	li	a4,1
    80004b24:	fce799e3          	bne	a5,a4,80004af6 <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    80004b28:	e4043483          	ld	s1,-448(s0)
    80004b2c:	e3843783          	ld	a5,-456(s0)
    80004b30:	1ef4e363          	bltu	s1,a5,80004d16 <kexec+0x33a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004b34:	e2843783          	ld	a5,-472(s0)
    80004b38:	94be                	add	s1,s1,a5
    80004b3a:	1ef4e163          	bltu	s1,a5,80004d1c <kexec+0x340>
    if (ph.vaddr % PGSIZE != 0)
    80004b3e:	de843703          	ld	a4,-536(s0)
    80004b42:	8ff9                	and	a5,a5,a4
    80004b44:	1c079f63          	bnez	a5,80004d22 <kexec+0x346>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004b48:	e1c42503          	lw	a0,-484(s0)
    80004b4c:	e71ff0ef          	jal	800049bc <flags2perm>
    80004b50:	86aa                	mv	a3,a0
    80004b52:	8626                	mv	a2,s1
    80004b54:	85ca                	mv	a1,s2
    80004b56:	855a                	mv	a0,s6
    80004b58:	f96fc0ef          	jal	800012ee <uvmalloc>
    80004b5c:	dea43c23          	sd	a0,-520(s0)
    80004b60:	1c050463          	beqz	a0,80004d28 <kexec+0x34c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004b64:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004b68:	00098863          	beqz	s3,80004b78 <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004b6c:	e2843c03          	ld	s8,-472(s0)
    80004b70:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004b74:	4481                	li	s1,0
    80004b76:	bfb1                	j	80004ad2 <kexec+0xf6>
    sz = sz1;
    80004b78:	df843903          	ld	s2,-520(s0)
    80004b7c:	bfad                	j	80004af6 <kexec+0x11a>
    80004b7e:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    80004b80:	8552                	mv	a0,s4
    80004b82:	abffe0ef          	jal	80003640 <iunlockput>
  end_op();
    80004b86:	b6aff0ef          	jal	80003ef0 <end_op>
  p = myproc();
    80004b8a:	f2dfc0ef          	jal	80001ab6 <myproc>
    80004b8e:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004b90:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    80004b94:	6c05                	lui	s8,0x1
    80004b96:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    80004b98:	9c4a                	add	s8,s8,s2
    80004b9a:	77fd                	lui	a5,0xfffff
    80004b9c:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004ba0:	4691                	li	a3,4
    80004ba2:	6609                	lui	a2,0x2
    80004ba4:	9662                	add	a2,a2,s8
    80004ba6:	85e2                	mv	a1,s8
    80004ba8:	855a                	mv	a0,s6
    80004baa:	f44fc0ef          	jal	800012ee <uvmalloc>
    80004bae:	892a                	mv	s2,a0
    80004bb0:	e10d                	bnez	a0,80004bd2 <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    80004bb2:	85e2                	mv	a1,s8
    80004bb4:	855a                	mv	a0,s6
    80004bb6:	88afd0ef          	jal	80001c40 <proc_freepagetable>
  return -1;
    80004bba:	557d                	li	a0,-1
    80004bbc:	79fe                	ld	s3,504(sp)
    80004bbe:	7a5e                	ld	s4,496(sp)
    80004bc0:	7abe                	ld	s5,488(sp)
    80004bc2:	7b1e                	ld	s6,480(sp)
    80004bc4:	6bfe                	ld	s7,472(sp)
    80004bc6:	6c5e                	ld	s8,464(sp)
    80004bc8:	6cbe                	ld	s9,456(sp)
    80004bca:	6d1e                	ld	s10,448(sp)
    80004bcc:	b549                	j	80004a4e <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004bce:	4901                	li	s2,0
    80004bd0:	bf45                	j	80004b80 <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004bd2:	75f9                	lui	a1,0xffffe
    80004bd4:	95aa                	add	a1,a1,a0
    80004bd6:	855a                	mv	a0,s6
    80004bd8:	8e9fc0ef          	jal	800014c0 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004bdc:	80090a13          	addi	s4,s2,-2048
    80004be0:	800a0a13          	addi	s4,s4,-2048
  for (argc = 0; argv[argc]; argc++) {
    80004be4:	e0043783          	ld	a5,-512(s0)
    80004be8:	6388                	ld	a0,0(a5)
    80004bea:	c545                	beqz	a0,80004c92 <kexec+0x2b6>
  sp = sz;
    80004bec:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004bee:	4481                	li	s1,0
    ustack[argc] = sp;
    80004bf0:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004bf4:	a7efc0ef          	jal	80000e72 <strlen>
    80004bf8:	0015079b          	addiw	a5,a0,1
    80004bfc:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004c00:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004c04:	134c6563          	bltu	s8,s4,80004d2e <kexec+0x352>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004c08:	e0043d03          	ld	s10,-512(s0)
    80004c0c:	000d3c83          	ld	s9,0(s10)
    80004c10:	8566                	mv	a0,s9
    80004c12:	a60fc0ef          	jal	80000e72 <strlen>
    80004c16:	0015071b          	addiw	a4,a0,1
    80004c1a:	86e6                	mv	a3,s9
    80004c1c:	8662                	mv	a2,s8
    80004c1e:	85ca                	mv	a1,s2
    80004c20:	855a                	mv	a0,s6
    80004c22:	961fc0ef          	jal	80001582 <copyout>
    80004c26:	10054663          	bltz	a0,80004d32 <kexec+0x356>
    ustack[argc] = sp;
    80004c2a:	00349793          	slli	a5,s1,0x3
    80004c2e:	97de                	add	a5,a5,s7
    80004c30:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb818>
  for (argc = 0; argv[argc]; argc++) {
    80004c34:	0485                	addi	s1,s1,1
    80004c36:	008d0793          	addi	a5,s10,8
    80004c3a:	e0f43023          	sd	a5,-512(s0)
    80004c3e:	008d3503          	ld	a0,8(s10)
    80004c42:	f94d                	bnez	a0,80004bf4 <kexec+0x218>
  ustack[argc] = 0;
    80004c44:	00349793          	slli	a5,s1,0x3
    80004c48:	f9078793          	addi	a5,a5,-112
    80004c4c:	97a2                	add	a5,a5,s0
    80004c4e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004c52:	00349713          	slli	a4,s1,0x3
    80004c56:	0721                	addi	a4,a4,8
    80004c58:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004c5c:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004c60:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004c62:	f54be8e3          	bltu	s7,s4,80004bb2 <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004c66:	e9040693          	addi	a3,s0,-368
    80004c6a:	865e                	mv	a2,s7
    80004c6c:	85ca                	mv	a1,s2
    80004c6e:	855a                	mv	a0,s6
    80004c70:	913fc0ef          	jal	80001582 <copyout>
    80004c74:	f2054fe3          	bltz	a0,80004bb2 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004c78:	0589b783          	ld	a5,88(s3)
    80004c7c:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004c80:	df043783          	ld	a5,-528(s0)
    80004c84:	0007c703          	lbu	a4,0(a5)
    80004c88:	c30d                	beqz	a4,80004caa <kexec+0x2ce>
    80004c8a:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004c8c:	02f00693          	li	a3,47
    80004c90:	a801                	j	80004ca0 <kexec+0x2c4>
  sp = sz;
    80004c92:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004c94:	4481                	li	s1,0
    80004c96:	b77d                	j	80004c44 <kexec+0x268>
  for (last = s = path; *s; s++)
    80004c98:	0785                	addi	a5,a5,1
    80004c9a:	fff7c703          	lbu	a4,-1(a5)
    80004c9e:	c711                	beqz	a4,80004caa <kexec+0x2ce>
    if (*s == '/')
    80004ca0:	fed71ce3          	bne	a4,a3,80004c98 <kexec+0x2bc>
      last = s + 1;
    80004ca4:	def43823          	sd	a5,-528(s0)
    80004ca8:	bfc5                	j	80004c98 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004caa:	4641                	li	a2,16
    80004cac:	df043583          	ld	a1,-528(s0)
    80004cb0:	15898513          	addi	a0,s3,344
    80004cb4:	988fc0ef          	jal	80000e3c <safestrcpy>
  oldpagetable = p->pagetable;
    80004cb8:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004cbc:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004cc0:	0529b423          	sd	s2,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004cc4:	0589b783          	ld	a5,88(s3)
    80004cc8:	e6843703          	ld	a4,-408(s0)
    80004ccc:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004cce:	0589b783          	ld	a5,88(s3)
    80004cd2:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004cd6:	85d6                	mv	a1,s5
    80004cd8:	f69fc0ef          	jal	80001c40 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004cdc:	0004851b          	sext.w	a0,s1
    80004ce0:	79fe                	ld	s3,504(sp)
    80004ce2:	7a5e                	ld	s4,496(sp)
    80004ce4:	7abe                	ld	s5,488(sp)
    80004ce6:	7b1e                	ld	s6,480(sp)
    80004ce8:	6bfe                	ld	s7,472(sp)
    80004cea:	6c5e                	ld	s8,464(sp)
    80004cec:	6cbe                	ld	s9,456(sp)
    80004cee:	6d1e                	ld	s10,448(sp)
    80004cf0:	bbb9                	j	80004a4e <kexec+0x72>
    80004cf2:	7b1e                	ld	s6,480(sp)
    80004cf4:	b3b1                	j	80004a40 <kexec+0x64>
    80004cf6:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004cfa:	df843583          	ld	a1,-520(s0)
    80004cfe:	855a                	mv	a0,s6
    80004d00:	f41fc0ef          	jal	80001c40 <proc_freepagetable>
  if (ip) {
    80004d04:	79fe                	ld	s3,504(sp)
    80004d06:	7abe                	ld	s5,488(sp)
    80004d08:	7b1e                	ld	s6,480(sp)
    80004d0a:	6bfe                	ld	s7,472(sp)
    80004d0c:	6c5e                	ld	s8,464(sp)
    80004d0e:	6cbe                	ld	s9,456(sp)
    80004d10:	6d1e                	ld	s10,448(sp)
    80004d12:	7dfa                	ld	s11,440(sp)
    80004d14:	b335                	j	80004a40 <kexec+0x64>
    80004d16:	df243c23          	sd	s2,-520(s0)
    80004d1a:	b7c5                	j	80004cfa <kexec+0x31e>
    80004d1c:	df243c23          	sd	s2,-520(s0)
    80004d20:	bfe9                	j	80004cfa <kexec+0x31e>
    80004d22:	df243c23          	sd	s2,-520(s0)
    80004d26:	bfd1                	j	80004cfa <kexec+0x31e>
    80004d28:	df243c23          	sd	s2,-520(s0)
    80004d2c:	b7f9                	j	80004cfa <kexec+0x31e>
  sz = sz1;
    80004d2e:	8c4a                	mv	s8,s2
    80004d30:	b549                	j	80004bb2 <kexec+0x1d6>
    80004d32:	8c4a                	mv	s8,s2
    80004d34:	bdbd                	j	80004bb2 <kexec+0x1d6>

0000000080004d36 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004d36:	7179                	addi	sp,sp,-48
    80004d38:	f406                	sd	ra,40(sp)
    80004d3a:	f022                	sd	s0,32(sp)
    80004d3c:	ec26                	sd	s1,24(sp)
    80004d3e:	e84a                	sd	s2,16(sp)
    80004d40:	1800                	addi	s0,sp,48
    80004d42:	892e                	mv	s2,a1
    80004d44:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004d46:	fdc40593          	addi	a1,s0,-36
    80004d4a:	cb5fd0ef          	jal	800029fe <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004d4e:	fdc42703          	lw	a4,-36(s0)
    80004d52:	47bd                	li	a5,15
    80004d54:	02e7ea63          	bltu	a5,a4,80004d88 <argfd+0x52>
    80004d58:	d5ffc0ef          	jal	80001ab6 <myproc>
    80004d5c:	fdc42703          	lw	a4,-36(s0)
    80004d60:	00371793          	slli	a5,a4,0x3
    80004d64:	0d078793          	addi	a5,a5,208
    80004d68:	953e                	add	a0,a0,a5
    80004d6a:	611c                	ld	a5,0(a0)
    80004d6c:	c385                	beqz	a5,80004d8c <argfd+0x56>
    return -1;
  if (pfd)
    80004d6e:	00090463          	beqz	s2,80004d76 <argfd+0x40>
    *pfd = fd;
    80004d72:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004d76:	4501                	li	a0,0
  if (pf)
    80004d78:	c091                	beqz	s1,80004d7c <argfd+0x46>
    *pf = f;
    80004d7a:	e09c                	sd	a5,0(s1)
}
    80004d7c:	70a2                	ld	ra,40(sp)
    80004d7e:	7402                	ld	s0,32(sp)
    80004d80:	64e2                	ld	s1,24(sp)
    80004d82:	6942                	ld	s2,16(sp)
    80004d84:	6145                	addi	sp,sp,48
    80004d86:	8082                	ret
    return -1;
    80004d88:	557d                	li	a0,-1
    80004d8a:	bfcd                	j	80004d7c <argfd+0x46>
    80004d8c:	557d                	li	a0,-1
    80004d8e:	b7fd                	j	80004d7c <argfd+0x46>

0000000080004d90 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004d90:	1101                	addi	sp,sp,-32
    80004d92:	ec06                	sd	ra,24(sp)
    80004d94:	e822                	sd	s0,16(sp)
    80004d96:	e426                	sd	s1,8(sp)
    80004d98:	1000                	addi	s0,sp,32
    80004d9a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004d9c:	d1bfc0ef          	jal	80001ab6 <myproc>
    80004da0:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004da2:	0d050793          	addi	a5,a0,208
    80004da6:	4501                	li	a0,0
    80004da8:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004daa:	6398                	ld	a4,0(a5)
    80004dac:	cb19                	beqz	a4,80004dc2 <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004dae:	2505                	addiw	a0,a0,1
    80004db0:	07a1                	addi	a5,a5,8
    80004db2:	fed51ce3          	bne	a0,a3,80004daa <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004db6:	557d                	li	a0,-1
}
    80004db8:	60e2                	ld	ra,24(sp)
    80004dba:	6442                	ld	s0,16(sp)
    80004dbc:	64a2                	ld	s1,8(sp)
    80004dbe:	6105                	addi	sp,sp,32
    80004dc0:	8082                	ret
      p->ofile[fd] = f;
    80004dc2:	00351793          	slli	a5,a0,0x3
    80004dc6:	0d078793          	addi	a5,a5,208
    80004dca:	963e                	add	a2,a2,a5
    80004dcc:	e204                	sd	s1,0(a2)
      return fd;
    80004dce:	b7ed                	j	80004db8 <fdalloc+0x28>

0000000080004dd0 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004dd0:	715d                	addi	sp,sp,-80
    80004dd2:	e486                	sd	ra,72(sp)
    80004dd4:	e0a2                	sd	s0,64(sp)
    80004dd6:	fc26                	sd	s1,56(sp)
    80004dd8:	f84a                	sd	s2,48(sp)
    80004dda:	f052                	sd	s4,32(sp)
    80004ddc:	ec56                	sd	s5,24(sp)
    80004dde:	e85a                	sd	s6,16(sp)
    80004de0:	0880                	addi	s0,sp,80
    80004de2:	8a2e                	mv	s4,a1
    80004de4:	8ab2                	mv	s5,a2
    80004de6:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004de8:	fb040593          	addi	a1,s0,-80
    80004dec:	eb5fe0ef          	jal	80003ca0 <nameiparent>
    80004df0:	84aa                	mv	s1,a0
    80004df2:	12050f63          	beqz	a0,80004f30 <create+0x160>
    return 0;

  ilock(dp);
    80004df6:	df6fe0ef          	jal	800033ec <ilock>

  if (dp->nlink == 0) {
    80004dfa:	04a49783          	lh	a5,74(s1)
    80004dfe:	cbb9                	beqz	a5,80004e54 <create+0x84>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004e00:	7761                	lui	a4,0xffff8
    80004e02:	0705                	addi	a4,a4,1 # ffffffffffff8001 <end+0xffffffff7ffd4819>
    80004e04:	97ba                	add	a5,a5,a4
    80004e06:	e781                	bnez	a5,80004e0e <create+0x3e>
    80004e08:	fffa0793          	addi	a5,s4,-1
    80004e0c:	cba9                	beqz	a5,80004e5e <create+0x8e>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004e0e:	4601                	li	a2,0
    80004e10:	fb040593          	addi	a1,s0,-80
    80004e14:	8526                	mv	a0,s1
    80004e16:	bbffe0ef          	jal	800039d4 <dirlookup>
    80004e1a:	892a                	mv	s2,a0
    80004e1c:	c939                	beqz	a0,80004e72 <create+0xa2>
    iunlockput(dp);
    80004e1e:	8526                	mv	a0,s1
    80004e20:	821fe0ef          	jal	80003640 <iunlockput>
    ilock(ip);
    80004e24:	854a                	mv	a0,s2
    80004e26:	dc6fe0ef          	jal	800033ec <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004e2a:	4789                	li	a5,2
    80004e2c:	02fa1e63          	bne	s4,a5,80004e68 <create+0x98>
    80004e30:	04495783          	lhu	a5,68(s2)
    80004e34:	37f9                	addiw	a5,a5,-2
    80004e36:	17c2                	slli	a5,a5,0x30
    80004e38:	93c1                	srli	a5,a5,0x30
    80004e3a:	4705                	li	a4,1
    80004e3c:	02f76663          	bltu	a4,a5,80004e68 <create+0x98>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004e40:	854a                	mv	a0,s2
    80004e42:	60a6                	ld	ra,72(sp)
    80004e44:	6406                	ld	s0,64(sp)
    80004e46:	74e2                	ld	s1,56(sp)
    80004e48:	7942                	ld	s2,48(sp)
    80004e4a:	7a02                	ld	s4,32(sp)
    80004e4c:	6ae2                	ld	s5,24(sp)
    80004e4e:	6b42                	ld	s6,16(sp)
    80004e50:	6161                	addi	sp,sp,80
    80004e52:	8082                	ret
    iunlockput(dp);
    80004e54:	8526                	mv	a0,s1
    80004e56:	feafe0ef          	jal	80003640 <iunlockput>
    return 0;
    80004e5a:	4901                	li	s2,0
    80004e5c:	b7d5                	j	80004e40 <create+0x70>
    iunlockput(dp);
    80004e5e:	8526                	mv	a0,s1
    80004e60:	fe0fe0ef          	jal	80003640 <iunlockput>
    return 0;
    80004e64:	4901                	li	s2,0
    80004e66:	bfe9                	j	80004e40 <create+0x70>
    iunlockput(ip);
    80004e68:	854a                	mv	a0,s2
    80004e6a:	fd6fe0ef          	jal	80003640 <iunlockput>
    return 0;
    80004e6e:	4901                	li	s2,0
    80004e70:	bfc1                	j	80004e40 <create+0x70>
    80004e72:	f44e                	sd	s3,40(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004e74:	85d2                	mv	a1,s4
    80004e76:	4088                	lw	a0,0(s1)
    80004e78:	c04fe0ef          	jal	8000327c <ialloc>
    80004e7c:	89aa                	mv	s3,a0
    80004e7e:	cd1d                	beqz	a0,80004ebc <create+0xec>
  ilock(ip);
    80004e80:	d6cfe0ef          	jal	800033ec <ilock>
  ip->major = major;
    80004e84:	05599323          	sh	s5,70(s3)
  ip->minor = minor;
    80004e88:	05699423          	sh	s6,72(s3)
  ip->nlink = 1;
    80004e8c:	4705                	li	a4,1
    80004e8e:	04e99523          	sh	a4,74(s3)
  iupdate(ip);
    80004e92:	854e                	mv	a0,s3
    80004e94:	ca4fe0ef          	jal	80003338 <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80004e98:	4705                	li	a4,1
    80004e9a:	02ea0763          	beq	s4,a4,80004ec8 <create+0xf8>
  if (dirlink(dp, name, ip->inum) < 0)
    80004e9e:	0049a603          	lw	a2,4(s3)
    80004ea2:	fb040593          	addi	a1,s0,-80
    80004ea6:	8526                	mv	a0,s1
    80004ea8:	d35fe0ef          	jal	80003bdc <dirlink>
    80004eac:	06054563          	bltz	a0,80004f16 <create+0x146>
  iunlockput(dp);
    80004eb0:	8526                	mv	a0,s1
    80004eb2:	f8efe0ef          	jal	80003640 <iunlockput>
  return ip;
    80004eb6:	894e                	mv	s2,s3
    80004eb8:	79a2                	ld	s3,40(sp)
    80004eba:	b759                	j	80004e40 <create+0x70>
    iunlockput(dp);
    80004ebc:	8526                	mv	a0,s1
    80004ebe:	f82fe0ef          	jal	80003640 <iunlockput>
    return 0;
    80004ec2:	894e                	mv	s2,s3
    80004ec4:	79a2                	ld	s3,40(sp)
    80004ec6:	bfad                	j	80004e40 <create+0x70>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004ec8:	0049a603          	lw	a2,4(s3)
    80004ecc:	00003597          	auipc	a1,0x3
    80004ed0:	86c58593          	addi	a1,a1,-1940 # 80007738 <etext+0x738>
    80004ed4:	854e                	mv	a0,s3
    80004ed6:	d07fe0ef          	jal	80003bdc <dirlink>
    80004eda:	02054e63          	bltz	a0,80004f16 <create+0x146>
    80004ede:	40d0                	lw	a2,4(s1)
    80004ee0:	00003597          	auipc	a1,0x3
    80004ee4:	86058593          	addi	a1,a1,-1952 # 80007740 <etext+0x740>
    80004ee8:	854e                	mv	a0,s3
    80004eea:	cf3fe0ef          	jal	80003bdc <dirlink>
    80004eee:	02054463          	bltz	a0,80004f16 <create+0x146>
  if (dirlink(dp, name, ip->inum) < 0)
    80004ef2:	0049a603          	lw	a2,4(s3)
    80004ef6:	fb040593          	addi	a1,s0,-80
    80004efa:	8526                	mv	a0,s1
    80004efc:	ce1fe0ef          	jal	80003bdc <dirlink>
    80004f00:	00054b63          	bltz	a0,80004f16 <create+0x146>
    dp->nlink++; // for ".."
    80004f04:	04a4d783          	lhu	a5,74(s1)
    80004f08:	2785                	addiw	a5,a5,1
    80004f0a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004f0e:	8526                	mv	a0,s1
    80004f10:	c28fe0ef          	jal	80003338 <iupdate>
    80004f14:	bf71                	j	80004eb0 <create+0xe0>
  ip->nlink = 0;
    80004f16:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    80004f1a:	854e                	mv	a0,s3
    80004f1c:	c1cfe0ef          	jal	80003338 <iupdate>
  iunlockput(ip);
    80004f20:	854e                	mv	a0,s3
    80004f22:	f1efe0ef          	jal	80003640 <iunlockput>
  iunlockput(dp);
    80004f26:	8526                	mv	a0,s1
    80004f28:	f18fe0ef          	jal	80003640 <iunlockput>
  return 0;
    80004f2c:	79a2                	ld	s3,40(sp)
    80004f2e:	bf09                	j	80004e40 <create+0x70>
    return 0;
    80004f30:	892a                	mv	s2,a0
    80004f32:	b739                	j	80004e40 <create+0x70>

0000000080004f34 <sys_dup>:
{
    80004f34:	7179                	addi	sp,sp,-48
    80004f36:	f406                	sd	ra,40(sp)
    80004f38:	f022                	sd	s0,32(sp)
    80004f3a:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004f3c:	fd840613          	addi	a2,s0,-40
    80004f40:	4581                	li	a1,0
    80004f42:	4501                	li	a0,0
    80004f44:	df3ff0ef          	jal	80004d36 <argfd>
    return -1;
    80004f48:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004f4a:	02054363          	bltz	a0,80004f70 <sys_dup+0x3c>
    80004f4e:	ec26                	sd	s1,24(sp)
    80004f50:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004f52:	fd843483          	ld	s1,-40(s0)
    80004f56:	8526                	mv	a0,s1
    80004f58:	e39ff0ef          	jal	80004d90 <fdalloc>
    80004f5c:	892a                	mv	s2,a0
    return -1;
    80004f5e:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004f60:	00054d63          	bltz	a0,80004f7a <sys_dup+0x46>
  filedup(f);
    80004f64:	8526                	mv	a0,s1
    80004f66:	b72ff0ef          	jal	800042d8 <filedup>
  return fd;
    80004f6a:	87ca                	mv	a5,s2
    80004f6c:	64e2                	ld	s1,24(sp)
    80004f6e:	6942                	ld	s2,16(sp)
}
    80004f70:	853e                	mv	a0,a5
    80004f72:	70a2                	ld	ra,40(sp)
    80004f74:	7402                	ld	s0,32(sp)
    80004f76:	6145                	addi	sp,sp,48
    80004f78:	8082                	ret
    80004f7a:	64e2                	ld	s1,24(sp)
    80004f7c:	6942                	ld	s2,16(sp)
    80004f7e:	bfcd                	j	80004f70 <sys_dup+0x3c>

0000000080004f80 <sys_read>:
{
    80004f80:	7179                	addi	sp,sp,-48
    80004f82:	f406                	sd	ra,40(sp)
    80004f84:	f022                	sd	s0,32(sp)
    80004f86:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f88:	fd840593          	addi	a1,s0,-40
    80004f8c:	4505                	li	a0,1
    80004f8e:	a8dfd0ef          	jal	80002a1a <argaddr>
  argint(2, &n);
    80004f92:	fe440593          	addi	a1,s0,-28
    80004f96:	4509                	li	a0,2
    80004f98:	a67fd0ef          	jal	800029fe <argint>
  if (argfd(0, 0, &f) < 0)
    80004f9c:	fe840613          	addi	a2,s0,-24
    80004fa0:	4581                	li	a1,0
    80004fa2:	4501                	li	a0,0
    80004fa4:	d93ff0ef          	jal	80004d36 <argfd>
    80004fa8:	87aa                	mv	a5,a0
    return -1;
    80004faa:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004fac:	0007ca63          	bltz	a5,80004fc0 <sys_read+0x40>
  return fileread(f, p, n);
    80004fb0:	fe442603          	lw	a2,-28(s0)
    80004fb4:	fd843583          	ld	a1,-40(s0)
    80004fb8:	fe843503          	ld	a0,-24(s0)
    80004fbc:	c94ff0ef          	jal	80004450 <fileread>
}
    80004fc0:	70a2                	ld	ra,40(sp)
    80004fc2:	7402                	ld	s0,32(sp)
    80004fc4:	6145                	addi	sp,sp,48
    80004fc6:	8082                	ret

0000000080004fc8 <sys_write>:
{
    80004fc8:	7179                	addi	sp,sp,-48
    80004fca:	f406                	sd	ra,40(sp)
    80004fcc:	f022                	sd	s0,32(sp)
    80004fce:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004fd0:	fd840593          	addi	a1,s0,-40
    80004fd4:	4505                	li	a0,1
    80004fd6:	a45fd0ef          	jal	80002a1a <argaddr>
  argint(2, &n);
    80004fda:	fe440593          	addi	a1,s0,-28
    80004fde:	4509                	li	a0,2
    80004fe0:	a1ffd0ef          	jal	800029fe <argint>
  if (argfd(0, 0, &f) < 0)
    80004fe4:	fe840613          	addi	a2,s0,-24
    80004fe8:	4581                	li	a1,0
    80004fea:	4501                	li	a0,0
    80004fec:	d4bff0ef          	jal	80004d36 <argfd>
    80004ff0:	87aa                	mv	a5,a0
    return -1;
    80004ff2:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004ff4:	0007ca63          	bltz	a5,80005008 <sys_write+0x40>
  return filewrite(f, p, n);
    80004ff8:	fe442603          	lw	a2,-28(s0)
    80004ffc:	fd843583          	ld	a1,-40(s0)
    80005000:	fe843503          	ld	a0,-24(s0)
    80005004:	d1aff0ef          	jal	8000451e <filewrite>
}
    80005008:	70a2                	ld	ra,40(sp)
    8000500a:	7402                	ld	s0,32(sp)
    8000500c:	6145                	addi	sp,sp,48
    8000500e:	8082                	ret

0000000080005010 <sys_close>:
{
    80005010:	1101                	addi	sp,sp,-32
    80005012:	ec06                	sd	ra,24(sp)
    80005014:	e822                	sd	s0,16(sp)
    80005016:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80005018:	fe040613          	addi	a2,s0,-32
    8000501c:	fec40593          	addi	a1,s0,-20
    80005020:	4501                	li	a0,0
    80005022:	d15ff0ef          	jal	80004d36 <argfd>
    return -1;
    80005026:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80005028:	02054163          	bltz	a0,8000504a <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    8000502c:	a8bfc0ef          	jal	80001ab6 <myproc>
    80005030:	fec42783          	lw	a5,-20(s0)
    80005034:	078e                	slli	a5,a5,0x3
    80005036:	0d078793          	addi	a5,a5,208
    8000503a:	953e                	add	a0,a0,a5
    8000503c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005040:	fe043503          	ld	a0,-32(s0)
    80005044:	adaff0ef          	jal	8000431e <fileclose>
  return 0;
    80005048:	4781                	li	a5,0
}
    8000504a:	853e                	mv	a0,a5
    8000504c:	60e2                	ld	ra,24(sp)
    8000504e:	6442                	ld	s0,16(sp)
    80005050:	6105                	addi	sp,sp,32
    80005052:	8082                	ret

0000000080005054 <sys_fstat>:
{
    80005054:	1101                	addi	sp,sp,-32
    80005056:	ec06                	sd	ra,24(sp)
    80005058:	e822                	sd	s0,16(sp)
    8000505a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000505c:	fe040593          	addi	a1,s0,-32
    80005060:	4505                	li	a0,1
    80005062:	9b9fd0ef          	jal	80002a1a <argaddr>
  if (argfd(0, 0, &f) < 0)
    80005066:	fe840613          	addi	a2,s0,-24
    8000506a:	4581                	li	a1,0
    8000506c:	4501                	li	a0,0
    8000506e:	cc9ff0ef          	jal	80004d36 <argfd>
    80005072:	87aa                	mv	a5,a0
    return -1;
    80005074:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005076:	0007c863          	bltz	a5,80005086 <sys_fstat+0x32>
  return filestat(f, st);
    8000507a:	fe043583          	ld	a1,-32(s0)
    8000507e:	fe843503          	ld	a0,-24(s0)
    80005082:	b5eff0ef          	jal	800043e0 <filestat>
}
    80005086:	60e2                	ld	ra,24(sp)
    80005088:	6442                	ld	s0,16(sp)
    8000508a:	6105                	addi	sp,sp,32
    8000508c:	8082                	ret

000000008000508e <sys_link>:
{
    8000508e:	7169                	addi	sp,sp,-304
    80005090:	f606                	sd	ra,296(sp)
    80005092:	f222                	sd	s0,288(sp)
    80005094:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005096:	08000613          	li	a2,128
    8000509a:	ed040593          	addi	a1,s0,-304
    8000509e:	4501                	li	a0,0
    800050a0:	997fd0ef          	jal	80002a36 <argstr>
    return -1;
    800050a4:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050a6:	10054163          	bltz	a0,800051a8 <sys_link+0x11a>
    800050aa:	08000613          	li	a2,128
    800050ae:	f5040593          	addi	a1,s0,-176
    800050b2:	4505                	li	a0,1
    800050b4:	983fd0ef          	jal	80002a36 <argstr>
    return -1;
    800050b8:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050ba:	0e054763          	bltz	a0,800051a8 <sys_link+0x11a>
    800050be:	ee26                	sd	s1,280(sp)
  begin_op();
    800050c0:	da5fe0ef          	jal	80003e64 <begin_op>
  if ((ip = namei(old)) == 0) {
    800050c4:	ed040513          	addi	a0,s0,-304
    800050c8:	bbffe0ef          	jal	80003c86 <namei>
    800050cc:	84aa                	mv	s1,a0
    800050ce:	cd35                	beqz	a0,8000514a <sys_link+0xbc>
  ilock(ip);
    800050d0:	b1cfe0ef          	jal	800033ec <ilock>
  if (ip->type == T_DIR) {
    800050d4:	04449703          	lh	a4,68(s1)
    800050d8:	4785                	li	a5,1
    800050da:	06f70d63          	beq	a4,a5,80005154 <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    800050de:	04a49783          	lh	a5,74(s1)
    800050e2:	6721                	lui	a4,0x8
    800050e4:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    800050e6:	06e78f63          	beq	a5,a4,80005164 <sys_link+0xd6>
    800050ea:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800050ec:	2785                	addiw	a5,a5,1
    800050ee:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800050f2:	8526                	mv	a0,s1
    800050f4:	a44fe0ef          	jal	80003338 <iupdate>
  iunlock(ip);
    800050f8:	8526                	mv	a0,s1
    800050fa:	ba0fe0ef          	jal	8000349a <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    800050fe:	fd040593          	addi	a1,s0,-48
    80005102:	f5040513          	addi	a0,s0,-176
    80005106:	b9bfe0ef          	jal	80003ca0 <nameiparent>
    8000510a:	892a                	mv	s2,a0
    8000510c:	c93d                	beqz	a0,80005182 <sys_link+0xf4>
  ilock(dp);
    8000510e:	adefe0ef          	jal	800033ec <ilock>
  if (dp->nlink == 0) {
    80005112:	04a91783          	lh	a5,74(s2)
    80005116:	cfb9                	beqz	a5,80005174 <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    80005118:	854a                	mv	a0,s2
    8000511a:	00092703          	lw	a4,0(s2)
    8000511e:	409c                	lw	a5,0(s1)
    80005120:	04f71e63          	bne	a4,a5,8000517c <sys_link+0xee>
    80005124:	40d0                	lw	a2,4(s1)
    80005126:	fd040593          	addi	a1,s0,-48
    8000512a:	ab3fe0ef          	jal	80003bdc <dirlink>
    8000512e:	04054763          	bltz	a0,8000517c <sys_link+0xee>
  iunlockput(dp);
    80005132:	854a                	mv	a0,s2
    80005134:	d0cfe0ef          	jal	80003640 <iunlockput>
  iput(ip);
    80005138:	8526                	mv	a0,s1
    8000513a:	c34fe0ef          	jal	8000356e <iput>
  end_op();
    8000513e:	db3fe0ef          	jal	80003ef0 <end_op>
  return 0;
    80005142:	4781                	li	a5,0
    80005144:	64f2                	ld	s1,280(sp)
    80005146:	6952                	ld	s2,272(sp)
    80005148:	a085                	j	800051a8 <sys_link+0x11a>
    end_op();
    8000514a:	da7fe0ef          	jal	80003ef0 <end_op>
    return -1;
    8000514e:	57fd                	li	a5,-1
    80005150:	64f2                	ld	s1,280(sp)
    80005152:	a899                	j	800051a8 <sys_link+0x11a>
    iunlockput(ip);
    80005154:	8526                	mv	a0,s1
    80005156:	ceafe0ef          	jal	80003640 <iunlockput>
    end_op();
    8000515a:	d97fe0ef          	jal	80003ef0 <end_op>
    return -1;
    8000515e:	57fd                	li	a5,-1
    80005160:	64f2                	ld	s1,280(sp)
    80005162:	a099                	j	800051a8 <sys_link+0x11a>
    iunlockput(ip);
    80005164:	8526                	mv	a0,s1
    80005166:	cdafe0ef          	jal	80003640 <iunlockput>
    end_op();
    8000516a:	d87fe0ef          	jal	80003ef0 <end_op>
    return -1;
    8000516e:	57fd                	li	a5,-1
    80005170:	64f2                	ld	s1,280(sp)
    80005172:	a81d                	j	800051a8 <sys_link+0x11a>
    iunlockput(dp);
    80005174:	854a                	mv	a0,s2
    80005176:	ccafe0ef          	jal	80003640 <iunlockput>
    goto bad;
    8000517a:	a021                	j	80005182 <sys_link+0xf4>
    iunlockput(dp);
    8000517c:	854a                	mv	a0,s2
    8000517e:	cc2fe0ef          	jal	80003640 <iunlockput>
  ilock(ip);
    80005182:	8526                	mv	a0,s1
    80005184:	a68fe0ef          	jal	800033ec <ilock>
  ip->nlink--;
    80005188:	04a4d783          	lhu	a5,74(s1)
    8000518c:	37fd                	addiw	a5,a5,-1
    8000518e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005192:	8526                	mv	a0,s1
    80005194:	9a4fe0ef          	jal	80003338 <iupdate>
  iunlockput(ip);
    80005198:	8526                	mv	a0,s1
    8000519a:	ca6fe0ef          	jal	80003640 <iunlockput>
  end_op();
    8000519e:	d53fe0ef          	jal	80003ef0 <end_op>
  return -1;
    800051a2:	57fd                	li	a5,-1
    800051a4:	64f2                	ld	s1,280(sp)
    800051a6:	6952                	ld	s2,272(sp)
}
    800051a8:	853e                	mv	a0,a5
    800051aa:	70b2                	ld	ra,296(sp)
    800051ac:	7412                	ld	s0,288(sp)
    800051ae:	6155                	addi	sp,sp,304
    800051b0:	8082                	ret

00000000800051b2 <sys_unlink>:
{
    800051b2:	7151                	addi	sp,sp,-240
    800051b4:	f586                	sd	ra,232(sp)
    800051b6:	f1a2                	sd	s0,224(sp)
    800051b8:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    800051ba:	08000613          	li	a2,128
    800051be:	f3040593          	addi	a1,s0,-208
    800051c2:	4501                	li	a0,0
    800051c4:	873fd0ef          	jal	80002a36 <argstr>
    800051c8:	14054d63          	bltz	a0,80005322 <sys_unlink+0x170>
    800051cc:	eda6                	sd	s1,216(sp)
  begin_op();
    800051ce:	c97fe0ef          	jal	80003e64 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    800051d2:	fb040593          	addi	a1,s0,-80
    800051d6:	f3040513          	addi	a0,s0,-208
    800051da:	ac7fe0ef          	jal	80003ca0 <nameiparent>
    800051de:	84aa                	mv	s1,a0
    800051e0:	c955                	beqz	a0,80005294 <sys_unlink+0xe2>
  ilock(dp);
    800051e2:	a0afe0ef          	jal	800033ec <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800051e6:	00002597          	auipc	a1,0x2
    800051ea:	55258593          	addi	a1,a1,1362 # 80007738 <etext+0x738>
    800051ee:	fb040513          	addi	a0,s0,-80
    800051f2:	fccfe0ef          	jal	800039be <namecmp>
    800051f6:	10050b63          	beqz	a0,8000530c <sys_unlink+0x15a>
    800051fa:	00002597          	auipc	a1,0x2
    800051fe:	54658593          	addi	a1,a1,1350 # 80007740 <etext+0x740>
    80005202:	fb040513          	addi	a0,s0,-80
    80005206:	fb8fe0ef          	jal	800039be <namecmp>
    8000520a:	10050163          	beqz	a0,8000530c <sys_unlink+0x15a>
    8000520e:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    80005210:	f2c40613          	addi	a2,s0,-212
    80005214:	fb040593          	addi	a1,s0,-80
    80005218:	8526                	mv	a0,s1
    8000521a:	fbafe0ef          	jal	800039d4 <dirlookup>
    8000521e:	892a                	mv	s2,a0
    80005220:	0e050563          	beqz	a0,8000530a <sys_unlink+0x158>
    80005224:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80005226:	9c6fe0ef          	jal	800033ec <ilock>
  if (ip->nlink < 1)
    8000522a:	04a91783          	lh	a5,74(s2)
    8000522e:	06f05863          	blez	a5,8000529e <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    80005232:	04491703          	lh	a4,68(s2)
    80005236:	4785                	li	a5,1
    80005238:	06f70963          	beq	a4,a5,800052aa <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    8000523c:	fc040993          	addi	s3,s0,-64
    80005240:	4641                	li	a2,16
    80005242:	4581                	li	a1,0
    80005244:	854e                	mv	a0,s3
    80005246:	aa3fb0ef          	jal	80000ce8 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000524a:	4741                	li	a4,16
    8000524c:	f2c42683          	lw	a3,-212(s0)
    80005250:	864e                	mv	a2,s3
    80005252:	4581                	li	a1,0
    80005254:	8526                	mv	a0,s1
    80005256:	e62fe0ef          	jal	800038b8 <writei>
    8000525a:	47c1                	li	a5,16
    8000525c:	08f51863          	bne	a0,a5,800052ec <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    80005260:	04491703          	lh	a4,68(s2)
    80005264:	4785                	li	a5,1
    80005266:	08f70963          	beq	a4,a5,800052f8 <sys_unlink+0x146>
  iunlockput(dp);
    8000526a:	8526                	mv	a0,s1
    8000526c:	bd4fe0ef          	jal	80003640 <iunlockput>
  ip->nlink--;
    80005270:	04a95783          	lhu	a5,74(s2)
    80005274:	37fd                	addiw	a5,a5,-1
    80005276:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000527a:	854a                	mv	a0,s2
    8000527c:	8bcfe0ef          	jal	80003338 <iupdate>
  iunlockput(ip);
    80005280:	854a                	mv	a0,s2
    80005282:	bbefe0ef          	jal	80003640 <iunlockput>
  end_op();
    80005286:	c6bfe0ef          	jal	80003ef0 <end_op>
  return 0;
    8000528a:	4501                	li	a0,0
    8000528c:	64ee                	ld	s1,216(sp)
    8000528e:	694e                	ld	s2,208(sp)
    80005290:	69ae                	ld	s3,200(sp)
    80005292:	a061                	j	8000531a <sys_unlink+0x168>
    end_op();
    80005294:	c5dfe0ef          	jal	80003ef0 <end_op>
    return -1;
    80005298:	557d                	li	a0,-1
    8000529a:	64ee                	ld	s1,216(sp)
    8000529c:	a8bd                	j	8000531a <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    8000529e:	00002517          	auipc	a0,0x2
    800052a2:	4aa50513          	addi	a0,a0,1194 # 80007748 <etext+0x748>
    800052a6:	d8efb0ef          	jal	80000834 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    800052aa:	04c92703          	lw	a4,76(s2)
    800052ae:	02000793          	li	a5,32
    800052b2:	f8e7f5e3          	bgeu	a5,a4,8000523c <sys_unlink+0x8a>
    800052b6:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800052b8:	4741                	li	a4,16
    800052ba:	86ce                	mv	a3,s3
    800052bc:	f1840613          	addi	a2,s0,-232
    800052c0:	4581                	li	a1,0
    800052c2:	854a                	mv	a0,s2
    800052c4:	d02fe0ef          	jal	800037c6 <readi>
    800052c8:	47c1                	li	a5,16
    800052ca:	00f51b63          	bne	a0,a5,800052e0 <sys_unlink+0x12e>
    if (de.inum != 0)
    800052ce:	f1845783          	lhu	a5,-232(s0)
    800052d2:	ebb1                	bnez	a5,80005326 <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    800052d4:	29c1                	addiw	s3,s3,16
    800052d6:	04c92783          	lw	a5,76(s2)
    800052da:	fcf9efe3          	bltu	s3,a5,800052b8 <sys_unlink+0x106>
    800052de:	bfb9                	j	8000523c <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800052e0:	00002517          	auipc	a0,0x2
    800052e4:	48050513          	addi	a0,a0,1152 # 80007760 <etext+0x760>
    800052e8:	d4cfb0ef          	jal	80000834 <panic>
    panic("unlink: writei");
    800052ec:	00002517          	auipc	a0,0x2
    800052f0:	48c50513          	addi	a0,a0,1164 # 80007778 <etext+0x778>
    800052f4:	d40fb0ef          	jal	80000834 <panic>
    dp->nlink--;
    800052f8:	04a4d783          	lhu	a5,74(s1)
    800052fc:	37fd                	addiw	a5,a5,-1
    800052fe:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005302:	8526                	mv	a0,s1
    80005304:	834fe0ef          	jal	80003338 <iupdate>
    80005308:	b78d                	j	8000526a <sys_unlink+0xb8>
    8000530a:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000530c:	8526                	mv	a0,s1
    8000530e:	b32fe0ef          	jal	80003640 <iunlockput>
  end_op();
    80005312:	bdffe0ef          	jal	80003ef0 <end_op>
  return -1;
    80005316:	557d                	li	a0,-1
    80005318:	64ee                	ld	s1,216(sp)
}
    8000531a:	70ae                	ld	ra,232(sp)
    8000531c:	740e                	ld	s0,224(sp)
    8000531e:	616d                	addi	sp,sp,240
    80005320:	8082                	ret
    return -1;
    80005322:	557d                	li	a0,-1
    80005324:	bfdd                	j	8000531a <sys_unlink+0x168>
    iunlockput(ip);
    80005326:	854a                	mv	a0,s2
    80005328:	b18fe0ef          	jal	80003640 <iunlockput>
    goto bad;
    8000532c:	694e                	ld	s2,208(sp)
    8000532e:	69ae                	ld	s3,200(sp)
    80005330:	bff1                	j	8000530c <sys_unlink+0x15a>

0000000080005332 <sys_open>:

uint64
sys_open(void)
{
    80005332:	7131                	addi	sp,sp,-192
    80005334:	fd06                	sd	ra,184(sp)
    80005336:	f922                	sd	s0,176(sp)
    80005338:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000533a:	f4c40593          	addi	a1,s0,-180
    8000533e:	4505                	li	a0,1
    80005340:	ebefd0ef          	jal	800029fe <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005344:	08000613          	li	a2,128
    80005348:	f5040593          	addi	a1,s0,-176
    8000534c:	4501                	li	a0,0
    8000534e:	ee8fd0ef          	jal	80002a36 <argstr>
    80005352:	87aa                	mv	a5,a0
    return -1;
    80005354:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005356:	0a07c363          	bltz	a5,800053fc <sys_open+0xca>
    8000535a:	f526                	sd	s1,168(sp)

  begin_op();
    8000535c:	b09fe0ef          	jal	80003e64 <begin_op>

  if (omode & O_CREATE) {
    80005360:	f4c42783          	lw	a5,-180(s0)
    80005364:	2007f793          	andi	a5,a5,512
    80005368:	c3dd                	beqz	a5,8000540e <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    8000536a:	4681                	li	a3,0
    8000536c:	4601                	li	a2,0
    8000536e:	4589                	li	a1,2
    80005370:	f5040513          	addi	a0,s0,-176
    80005374:	a5dff0ef          	jal	80004dd0 <create>
    80005378:	84aa                	mv	s1,a0
    if (ip == 0) {
    8000537a:	c549                	beqz	a0,80005404 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    8000537c:	04449703          	lh	a4,68(s1)
    80005380:	478d                	li	a5,3
    80005382:	00f71763          	bne	a4,a5,80005390 <sys_open+0x5e>
    80005386:	0464d703          	lhu	a4,70(s1)
    8000538a:	47a5                	li	a5,9
    8000538c:	0ae7ee63          	bltu	a5,a4,80005448 <sys_open+0x116>
    80005390:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    80005392:	ee9fe0ef          	jal	8000427a <filealloc>
    80005396:	892a                	mv	s2,a0
    80005398:	c561                	beqz	a0,80005460 <sys_open+0x12e>
    8000539a:	ed4e                	sd	s3,152(sp)
    8000539c:	9f5ff0ef          	jal	80004d90 <fdalloc>
    800053a0:	89aa                	mv	s3,a0
    800053a2:	0a054b63          	bltz	a0,80005458 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    800053a6:	04449703          	lh	a4,68(s1)
    800053aa:	478d                	li	a5,3
    800053ac:	0cf70363          	beq	a4,a5,80005472 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800053b0:	4789                	li	a5,2
    800053b2:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800053b6:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800053ba:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800053be:	f4c42783          	lw	a5,-180(s0)
    800053c2:	0017f713          	andi	a4,a5,1
    800053c6:	00174713          	xori	a4,a4,1
    800053ca:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800053ce:	0037f713          	andi	a4,a5,3
    800053d2:	00e03733          	snez	a4,a4
    800053d6:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    800053da:	4007f793          	andi	a5,a5,1024
    800053de:	c791                	beqz	a5,800053ea <sys_open+0xb8>
    800053e0:	04449703          	lh	a4,68(s1)
    800053e4:	4789                	li	a5,2
    800053e6:	08f70d63          	beq	a4,a5,80005480 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800053ea:	8526                	mv	a0,s1
    800053ec:	8aefe0ef          	jal	8000349a <iunlock>
  end_op();
    800053f0:	b01fe0ef          	jal	80003ef0 <end_op>

  return fd;
    800053f4:	854e                	mv	a0,s3
    800053f6:	74aa                	ld	s1,168(sp)
    800053f8:	790a                	ld	s2,160(sp)
    800053fa:	69ea                	ld	s3,152(sp)
}
    800053fc:	70ea                	ld	ra,184(sp)
    800053fe:	744a                	ld	s0,176(sp)
    80005400:	6129                	addi	sp,sp,192
    80005402:	8082                	ret
      end_op();
    80005404:	aedfe0ef          	jal	80003ef0 <end_op>
      return -1;
    80005408:	557d                	li	a0,-1
    8000540a:	74aa                	ld	s1,168(sp)
    8000540c:	bfc5                	j	800053fc <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    8000540e:	f5040513          	addi	a0,s0,-176
    80005412:	875fe0ef          	jal	80003c86 <namei>
    80005416:	84aa                	mv	s1,a0
    80005418:	c11d                	beqz	a0,8000543e <sys_open+0x10c>
    ilock(ip);
    8000541a:	fd3fd0ef          	jal	800033ec <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    8000541e:	04449703          	lh	a4,68(s1)
    80005422:	4785                	li	a5,1
    80005424:	f4f71ce3          	bne	a4,a5,8000537c <sys_open+0x4a>
    80005428:	f4c42783          	lw	a5,-180(s0)
    8000542c:	d3b5                	beqz	a5,80005390 <sys_open+0x5e>
      iunlockput(ip);
    8000542e:	8526                	mv	a0,s1
    80005430:	a10fe0ef          	jal	80003640 <iunlockput>
      end_op();
    80005434:	abdfe0ef          	jal	80003ef0 <end_op>
      return -1;
    80005438:	557d                	li	a0,-1
    8000543a:	74aa                	ld	s1,168(sp)
    8000543c:	b7c1                	j	800053fc <sys_open+0xca>
      end_op();
    8000543e:	ab3fe0ef          	jal	80003ef0 <end_op>
      return -1;
    80005442:	557d                	li	a0,-1
    80005444:	74aa                	ld	s1,168(sp)
    80005446:	bf5d                	j	800053fc <sys_open+0xca>
    iunlockput(ip);
    80005448:	8526                	mv	a0,s1
    8000544a:	9f6fe0ef          	jal	80003640 <iunlockput>
    end_op();
    8000544e:	aa3fe0ef          	jal	80003ef0 <end_op>
    return -1;
    80005452:	557d                	li	a0,-1
    80005454:	74aa                	ld	s1,168(sp)
    80005456:	b75d                	j	800053fc <sys_open+0xca>
      fileclose(f);
    80005458:	854a                	mv	a0,s2
    8000545a:	ec5fe0ef          	jal	8000431e <fileclose>
    8000545e:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005460:	8526                	mv	a0,s1
    80005462:	9defe0ef          	jal	80003640 <iunlockput>
    end_op();
    80005466:	a8bfe0ef          	jal	80003ef0 <end_op>
    return -1;
    8000546a:	557d                	li	a0,-1
    8000546c:	74aa                	ld	s1,168(sp)
    8000546e:	790a                	ld	s2,160(sp)
    80005470:	b771                	j	800053fc <sys_open+0xca>
    f->type = FD_DEVICE;
    80005472:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005476:	04649783          	lh	a5,70(s1)
    8000547a:	02f91223          	sh	a5,36(s2)
    8000547e:	bf35                	j	800053ba <sys_open+0x88>
    itrunc(ip);
    80005480:	8526                	mv	a0,s1
    80005482:	858fe0ef          	jal	800034da <itrunc>
    80005486:	b795                	j	800053ea <sys_open+0xb8>

0000000080005488 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005488:	7175                	addi	sp,sp,-144
    8000548a:	e506                	sd	ra,136(sp)
    8000548c:	e122                	sd	s0,128(sp)
    8000548e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005490:	9d5fe0ef          	jal	80003e64 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    80005494:	08000613          	li	a2,128
    80005498:	f7040593          	addi	a1,s0,-144
    8000549c:	4501                	li	a0,0
    8000549e:	d98fd0ef          	jal	80002a36 <argstr>
    800054a2:	02054363          	bltz	a0,800054c8 <sys_mkdir+0x40>
    800054a6:	4681                	li	a3,0
    800054a8:	4601                	li	a2,0
    800054aa:	4585                	li	a1,1
    800054ac:	f7040513          	addi	a0,s0,-144
    800054b0:	921ff0ef          	jal	80004dd0 <create>
    800054b4:	c911                	beqz	a0,800054c8 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800054b6:	98afe0ef          	jal	80003640 <iunlockput>
  end_op();
    800054ba:	a37fe0ef          	jal	80003ef0 <end_op>
  return 0;
    800054be:	4501                	li	a0,0
}
    800054c0:	60aa                	ld	ra,136(sp)
    800054c2:	640a                	ld	s0,128(sp)
    800054c4:	6149                	addi	sp,sp,144
    800054c6:	8082                	ret
    end_op();
    800054c8:	a29fe0ef          	jal	80003ef0 <end_op>
    return -1;
    800054cc:	557d                	li	a0,-1
    800054ce:	bfcd                	j	800054c0 <sys_mkdir+0x38>

00000000800054d0 <sys_mknod>:

uint64
sys_mknod(void)
{
    800054d0:	7135                	addi	sp,sp,-160
    800054d2:	ed06                	sd	ra,152(sp)
    800054d4:	e922                	sd	s0,144(sp)
    800054d6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800054d8:	98dfe0ef          	jal	80003e64 <begin_op>
  argint(1, &major);
    800054dc:	f6c40593          	addi	a1,s0,-148
    800054e0:	4505                	li	a0,1
    800054e2:	d1cfd0ef          	jal	800029fe <argint>
  argint(2, &minor);
    800054e6:	f6840593          	addi	a1,s0,-152
    800054ea:	4509                	li	a0,2
    800054ec:	d12fd0ef          	jal	800029fe <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800054f0:	08000613          	li	a2,128
    800054f4:	f7040593          	addi	a1,s0,-144
    800054f8:	4501                	li	a0,0
    800054fa:	d3cfd0ef          	jal	80002a36 <argstr>
    800054fe:	02054563          	bltz	a0,80005528 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    80005502:	f6841683          	lh	a3,-152(s0)
    80005506:	f6c41603          	lh	a2,-148(s0)
    8000550a:	458d                	li	a1,3
    8000550c:	f7040513          	addi	a0,s0,-144
    80005510:	8c1ff0ef          	jal	80004dd0 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005514:	c911                	beqz	a0,80005528 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005516:	92afe0ef          	jal	80003640 <iunlockput>
  end_op();
    8000551a:	9d7fe0ef          	jal	80003ef0 <end_op>
  return 0;
    8000551e:	4501                	li	a0,0
}
    80005520:	60ea                	ld	ra,152(sp)
    80005522:	644a                	ld	s0,144(sp)
    80005524:	610d                	addi	sp,sp,160
    80005526:	8082                	ret
    end_op();
    80005528:	9c9fe0ef          	jal	80003ef0 <end_op>
    return -1;
    8000552c:	557d                	li	a0,-1
    8000552e:	bfcd                	j	80005520 <sys_mknod+0x50>

0000000080005530 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005530:	7135                	addi	sp,sp,-160
    80005532:	ed06                	sd	ra,152(sp)
    80005534:	e922                	sd	s0,144(sp)
    80005536:	e14a                	sd	s2,128(sp)
    80005538:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000553a:	d7cfc0ef          	jal	80001ab6 <myproc>
    8000553e:	892a                	mv	s2,a0

  begin_op();
    80005540:	925fe0ef          	jal	80003e64 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    80005544:	08000613          	li	a2,128
    80005548:	f6040593          	addi	a1,s0,-160
    8000554c:	4501                	li	a0,0
    8000554e:	ce8fd0ef          	jal	80002a36 <argstr>
    80005552:	04054363          	bltz	a0,80005598 <sys_chdir+0x68>
    80005556:	e526                	sd	s1,136(sp)
    80005558:	f6040513          	addi	a0,s0,-160
    8000555c:	f2afe0ef          	jal	80003c86 <namei>
    80005560:	84aa                	mv	s1,a0
    80005562:	c915                	beqz	a0,80005596 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005564:	e89fd0ef          	jal	800033ec <ilock>
  if (ip->type != T_DIR) {
    80005568:	04449703          	lh	a4,68(s1)
    8000556c:	4785                	li	a5,1
    8000556e:	02f71963          	bne	a4,a5,800055a0 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005572:	8526                	mv	a0,s1
    80005574:	f27fd0ef          	jal	8000349a <iunlock>
  iput(p->cwd);
    80005578:	15093503          	ld	a0,336(s2)
    8000557c:	ff3fd0ef          	jal	8000356e <iput>
  end_op();
    80005580:	971fe0ef          	jal	80003ef0 <end_op>
  p->cwd = ip;
    80005584:	14993823          	sd	s1,336(s2)
  return 0;
    80005588:	4501                	li	a0,0
    8000558a:	64aa                	ld	s1,136(sp)
}
    8000558c:	60ea                	ld	ra,152(sp)
    8000558e:	644a                	ld	s0,144(sp)
    80005590:	690a                	ld	s2,128(sp)
    80005592:	610d                	addi	sp,sp,160
    80005594:	8082                	ret
    80005596:	64aa                	ld	s1,136(sp)
    end_op();
    80005598:	959fe0ef          	jal	80003ef0 <end_op>
    return -1;
    8000559c:	557d                	li	a0,-1
    8000559e:	b7fd                	j	8000558c <sys_chdir+0x5c>
    iunlockput(ip);
    800055a0:	8526                	mv	a0,s1
    800055a2:	89efe0ef          	jal	80003640 <iunlockput>
    end_op();
    800055a6:	94bfe0ef          	jal	80003ef0 <end_op>
    return -1;
    800055aa:	557d                	li	a0,-1
    800055ac:	64aa                	ld	s1,136(sp)
    800055ae:	bff9                	j	8000558c <sys_chdir+0x5c>

00000000800055b0 <sys_exec>:

uint64
sys_exec(void)
{
    800055b0:	7105                	addi	sp,sp,-480
    800055b2:	ef86                	sd	ra,472(sp)
    800055b4:	eba2                	sd	s0,464(sp)
    800055b6:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800055b8:	e2840593          	addi	a1,s0,-472
    800055bc:	4505                	li	a0,1
    800055be:	c5cfd0ef          	jal	80002a1a <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    800055c2:	08000613          	li	a2,128
    800055c6:	f3040593          	addi	a1,s0,-208
    800055ca:	4501                	li	a0,0
    800055cc:	c6afd0ef          	jal	80002a36 <argstr>
    800055d0:	87aa                	mv	a5,a0
    return -1;
    800055d2:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    800055d4:	0e07c063          	bltz	a5,800056b4 <sys_exec+0x104>
    800055d8:	e7a6                	sd	s1,456(sp)
    800055da:	e3ca                	sd	s2,448(sp)
    800055dc:	ff4e                	sd	s3,440(sp)
    800055de:	fb52                	sd	s4,432(sp)
    800055e0:	f756                	sd	s5,424(sp)
    800055e2:	f35a                	sd	s6,416(sp)
    800055e4:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800055e6:	e3040a13          	addi	s4,s0,-464
    800055ea:	10000613          	li	a2,256
    800055ee:	4581                	li	a1,0
    800055f0:	8552                	mv	a0,s4
    800055f2:	ef6fb0ef          	jal	80000ce8 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    800055f6:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800055f8:	89d2                	mv	s3,s4
    800055fa:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    800055fc:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005600:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    80005602:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005606:	00391513          	slli	a0,s2,0x3
    8000560a:	85d6                	mv	a1,s5
    8000560c:	e2843783          	ld	a5,-472(s0)
    80005610:	953e                	add	a0,a0,a5
    80005612:	b60fd0ef          	jal	80002972 <fetchaddr>
    80005616:	02054663          	bltz	a0,80005642 <sys_exec+0x92>
    if (uarg == 0) {
    8000561a:	e2043783          	ld	a5,-480(s0)
    8000561e:	c7a1                	beqz	a5,80005666 <sys_exec+0xb6>
    argv[i] = kalloc();
    80005620:	d2efb0ef          	jal	80000b4e <kalloc>
    80005624:	85aa                	mv	a1,a0
    80005626:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    8000562a:	cd01                	beqz	a0,80005642 <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000562c:	865a                	mv	a2,s6
    8000562e:	e2043503          	ld	a0,-480(s0)
    80005632:	b8afd0ef          	jal	800029bc <fetchstr>
    80005636:	00054663          	bltz	a0,80005642 <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    8000563a:	0905                	addi	s2,s2,1
    8000563c:	09a1                	addi	s3,s3,8
    8000563e:	fd7914e3          	bne	s2,s7,80005606 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005642:	100a0a13          	addi	s4,s4,256
    80005646:	6088                	ld	a0,0(s1)
    80005648:	cd31                	beqz	a0,800056a4 <sys_exec+0xf4>
    kfree(argv[i]);
    8000564a:	c1cfb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000564e:	04a1                	addi	s1,s1,8
    80005650:	ff449be3          	bne	s1,s4,80005646 <sys_exec+0x96>
  return -1;
    80005654:	557d                	li	a0,-1
    80005656:	64be                	ld	s1,456(sp)
    80005658:	691e                	ld	s2,448(sp)
    8000565a:	79fa                	ld	s3,440(sp)
    8000565c:	7a5a                	ld	s4,432(sp)
    8000565e:	7aba                	ld	s5,424(sp)
    80005660:	7b1a                	ld	s6,416(sp)
    80005662:	6bfa                	ld	s7,408(sp)
    80005664:	a881                	j	800056b4 <sys_exec+0x104>
      argv[i] = 0;
    80005666:	0009079b          	sext.w	a5,s2
    8000566a:	e3040593          	addi	a1,s0,-464
    8000566e:	078e                	slli	a5,a5,0x3
    80005670:	97ae                	add	a5,a5,a1
    80005672:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    80005676:	f3040513          	addi	a0,s0,-208
    8000567a:	b62ff0ef          	jal	800049dc <kexec>
    8000567e:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005680:	100a0a13          	addi	s4,s4,256
    80005684:	6088                	ld	a0,0(s1)
    80005686:	c511                	beqz	a0,80005692 <sys_exec+0xe2>
    kfree(argv[i]);
    80005688:	bdefb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000568c:	04a1                	addi	s1,s1,8
    8000568e:	ff449be3          	bne	s1,s4,80005684 <sys_exec+0xd4>
  return ret;
    80005692:	854a                	mv	a0,s2
    80005694:	64be                	ld	s1,456(sp)
    80005696:	691e                	ld	s2,448(sp)
    80005698:	79fa                	ld	s3,440(sp)
    8000569a:	7a5a                	ld	s4,432(sp)
    8000569c:	7aba                	ld	s5,424(sp)
    8000569e:	7b1a                	ld	s6,416(sp)
    800056a0:	6bfa                	ld	s7,408(sp)
    800056a2:	a809                	j	800056b4 <sys_exec+0x104>
  return -1;
    800056a4:	557d                	li	a0,-1
    800056a6:	64be                	ld	s1,456(sp)
    800056a8:	691e                	ld	s2,448(sp)
    800056aa:	79fa                	ld	s3,440(sp)
    800056ac:	7a5a                	ld	s4,432(sp)
    800056ae:	7aba                	ld	s5,424(sp)
    800056b0:	7b1a                	ld	s6,416(sp)
    800056b2:	6bfa                	ld	s7,408(sp)
}
    800056b4:	60fe                	ld	ra,472(sp)
    800056b6:	645e                	ld	s0,464(sp)
    800056b8:	613d                	addi	sp,sp,480
    800056ba:	8082                	ret

00000000800056bc <sys_pipe>:

uint64
sys_pipe(void)
{
    800056bc:	7139                	addi	sp,sp,-64
    800056be:	fc06                	sd	ra,56(sp)
    800056c0:	f822                	sd	s0,48(sp)
    800056c2:	f426                	sd	s1,40(sp)
    800056c4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800056c6:	bf0fc0ef          	jal	80001ab6 <myproc>
    800056ca:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800056cc:	fd840593          	addi	a1,s0,-40
    800056d0:	4501                	li	a0,0
    800056d2:	b48fd0ef          	jal	80002a1a <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    800056d6:	fc840593          	addi	a1,s0,-56
    800056da:	fd040513          	addi	a0,s0,-48
    800056de:	f7ffe0ef          	jal	8000465c <pipealloc>
    return -1;
    800056e2:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    800056e4:	0a054963          	bltz	a0,80005796 <sys_pipe+0xda>
  fd0 = -1;
    800056e8:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    800056ec:	fd043503          	ld	a0,-48(s0)
    800056f0:	ea0ff0ef          	jal	80004d90 <fdalloc>
    800056f4:	fca42223          	sw	a0,-60(s0)
    800056f8:	08054663          	bltz	a0,80005784 <sys_pipe+0xc8>
    800056fc:	fc843503          	ld	a0,-56(s0)
    80005700:	e90ff0ef          	jal	80004d90 <fdalloc>
    80005704:	fca42023          	sw	a0,-64(s0)
    80005708:	06054463          	bltz	a0,80005770 <sys_pipe+0xb4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    8000570c:	4711                	li	a4,4
    8000570e:	fc440693          	addi	a3,s0,-60
    80005712:	fd843603          	ld	a2,-40(s0)
    80005716:	64ac                	ld	a1,72(s1)
    80005718:	68a8                	ld	a0,80(s1)
    8000571a:	e69fb0ef          	jal	80001582 <copyout>
    8000571e:	00054f63          	bltz	a0,8000573c <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    80005722:	4711                	li	a4,4
    80005724:	fc040693          	addi	a3,s0,-64
    80005728:	fd843603          	ld	a2,-40(s0)
    8000572c:	963a                	add	a2,a2,a4
    8000572e:	64ac                	ld	a1,72(s1)
    80005730:	68a8                	ld	a0,80(s1)
    80005732:	e51fb0ef          	jal	80001582 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005736:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005738:	04055f63          	bgez	a0,80005796 <sys_pipe+0xda>
    p->ofile[fd0] = 0;
    8000573c:	fc442783          	lw	a5,-60(s0)
    80005740:	078e                	slli	a5,a5,0x3
    80005742:	0d078793          	addi	a5,a5,208
    80005746:	97a6                	add	a5,a5,s1
    80005748:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000574c:	fc042783          	lw	a5,-64(s0)
    80005750:	078e                	slli	a5,a5,0x3
    80005752:	0d078793          	addi	a5,a5,208
    80005756:	94be                	add	s1,s1,a5
    80005758:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000575c:	fd043503          	ld	a0,-48(s0)
    80005760:	bbffe0ef          	jal	8000431e <fileclose>
    fileclose(wf);
    80005764:	fc843503          	ld	a0,-56(s0)
    80005768:	bb7fe0ef          	jal	8000431e <fileclose>
    return -1;
    8000576c:	57fd                	li	a5,-1
    8000576e:	a025                	j	80005796 <sys_pipe+0xda>
    if (fd0 >= 0)
    80005770:	fc442783          	lw	a5,-60(s0)
    80005774:	0007c863          	bltz	a5,80005784 <sys_pipe+0xc8>
      p->ofile[fd0] = 0;
    80005778:	078e                	slli	a5,a5,0x3
    8000577a:	0d078793          	addi	a5,a5,208
    8000577e:	97a6                	add	a5,a5,s1
    80005780:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005784:	fd043503          	ld	a0,-48(s0)
    80005788:	b97fe0ef          	jal	8000431e <fileclose>
    fileclose(wf);
    8000578c:	fc843503          	ld	a0,-56(s0)
    80005790:	b8ffe0ef          	jal	8000431e <fileclose>
    return -1;
    80005794:	57fd                	li	a5,-1
}
    80005796:	853e                	mv	a0,a5
    80005798:	70e2                	ld	ra,56(sp)
    8000579a:	7442                	ld	s0,48(sp)
    8000579c:	74a2                	ld	s1,40(sp)
    8000579e:	6121                	addi	sp,sp,64
    800057a0:	8082                	ret
	...

00000000800057b0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800057b0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800057b2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800057b4:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    800057b6:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800057b8:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800057ba:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800057bc:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800057be:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800057c0:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800057c2:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800057c4:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800057c6:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800057c8:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800057ca:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800057cc:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800057ce:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800057d0:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800057d2:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800057d4:	8acfd0ef          	jal	80002880 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800057d8:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800057da:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800057dc:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800057de:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800057e0:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800057e2:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800057e4:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800057e6:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800057e8:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800057ea:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800057ec:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800057ee:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800057f0:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800057f2:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800057f4:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800057f6:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800057f8:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800057fa:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800057fc:	10200073          	sret
    80005800:	0001                	nop
    80005802:	00000013          	nop
    80005806:	00000013          	nop
    8000580a:	00000013          	nop

000000008000580e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000580e:	1141                	addi	sp,sp,-16
    80005810:	e406                	sd	ra,8(sp)
    80005812:	e022                	sd	s0,0(sp)
    80005814:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(volatile uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80005816:	0c000737          	lui	a4,0xc000
    8000581a:	4785                	li	a5,1
    8000581c:	d71c                	sw	a5,40(a4)
  *(volatile uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    8000581e:	c35c                	sw	a5,4(a4)
}
    80005820:	60a2                	ld	ra,8(sp)
    80005822:	6402                	ld	s0,0(sp)
    80005824:	0141                	addi	sp,sp,16
    80005826:	8082                	ret

0000000080005828 <plicinithart>:

void
plicinithart(void)
{
    80005828:	1141                	addi	sp,sp,-16
    8000582a:	e406                	sd	ra,8(sp)
    8000582c:	e022                	sd	s0,0(sp)
    8000582e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005830:	a52fc0ef          	jal	80001a82 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(volatile uint32 *)PLIC_SENABLE(hart) =
    80005834:	0085179b          	slliw	a5,a0,0x8
    80005838:	0c002737          	lui	a4,0xc002
    8000583c:	08070713          	addi	a4,a4,128 # c002080 <_entry-0x73ffdf80>
    80005840:	97ba                	add	a5,a5,a4
    80005842:	40200713          	li	a4,1026
    80005846:	c398                	sw	a4,0(a5)
    (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);

  // set this hart's S-mode priority threshold to 0.
  *(volatile uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005848:	00d5151b          	slliw	a0,a0,0xd
    8000584c:	0c2017b7          	lui	a5,0xc201
    80005850:	953e                	add	a0,a0,a5
    80005852:	00052023          	sw	zero,0(a0)
}
    80005856:	60a2                	ld	ra,8(sp)
    80005858:	6402                	ld	s0,0(sp)
    8000585a:	0141                	addi	sp,sp,16
    8000585c:	8082                	ret

000000008000585e <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000585e:	1141                	addi	sp,sp,-16
    80005860:	e406                	sd	ra,8(sp)
    80005862:	e022                	sd	s0,0(sp)
    80005864:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005866:	a1cfc0ef          	jal	80001a82 <cpuid>
  int irq = *(volatile uint32 *)PLIC_SCLAIM(hart);
    8000586a:	00d5151b          	slliw	a0,a0,0xd
    8000586e:	0c2017b7          	lui	a5,0xc201
    80005872:	0791                	addi	a5,a5,4 # c201004 <_entry-0x73dfeffc>
    80005874:	953e                	add	a0,a0,a5
    80005876:	4108                	lw	a0,0(a0)
  return irq;
}
    80005878:	60a2                	ld	ra,8(sp)
    8000587a:	6402                	ld	s0,0(sp)
    8000587c:	0141                	addi	sp,sp,16
    8000587e:	8082                	ret

0000000080005880 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005880:	1101                	addi	sp,sp,-32
    80005882:	ec06                	sd	ra,24(sp)
    80005884:	e822                	sd	s0,16(sp)
    80005886:	e426                	sd	s1,8(sp)
    80005888:	1000                	addi	s0,sp,32
    8000588a:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000588c:	9f6fc0ef          	jal	80001a82 <cpuid>
  *(volatile uint32 *)PLIC_SCLAIM(hart) = irq;
    80005890:	00d5179b          	slliw	a5,a0,0xd
    80005894:	0c201737          	lui	a4,0xc201
    80005898:	0711                	addi	a4,a4,4 # c201004 <_entry-0x73dfeffc>
    8000589a:	97ba                	add	a5,a5,a4
    8000589c:	c384                	sw	s1,0(a5)
}
    8000589e:	60e2                	ld	ra,24(sp)
    800058a0:	6442                	ld	s0,16(sp)
    800058a2:	64a2                	ld	s1,8(sp)
    800058a4:	6105                	addi	sp,sp,32
    800058a6:	8082                	ret

00000000800058a8 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800058a8:	1141                	addi	sp,sp,-16
    800058aa:	e406                	sd	ra,8(sp)
    800058ac:	e022                	sd	s0,0(sp)
    800058ae:	0800                	addi	s0,sp,16
  if (i >= NUM)
    800058b0:	479d                	li	a5,7
    800058b2:	04a7ca63          	blt	a5,a0,80005906 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    800058b6:	0001e797          	auipc	a5,0x1e
    800058ba:	df278793          	addi	a5,a5,-526 # 800236a8 <disk>
    800058be:	97aa                	add	a5,a5,a0
    800058c0:	0187c783          	lbu	a5,24(a5)
    800058c4:	e7b9                	bnez	a5,80005912 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800058c6:	00451693          	slli	a3,a0,0x4
    800058ca:	0001e797          	auipc	a5,0x1e
    800058ce:	dde78793          	addi	a5,a5,-546 # 800236a8 <disk>
    800058d2:	6398                	ld	a4,0(a5)
    800058d4:	9736                	add	a4,a4,a3
    800058d6:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800058da:	6398                	ld	a4,0(a5)
    800058dc:	9736                	add	a4,a4,a3
    800058de:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800058e2:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800058e6:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800058ea:	97aa                	add	a5,a5,a0
    800058ec:	4705                	li	a4,1
    800058ee:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800058f2:	0001e517          	auipc	a0,0x1e
    800058f6:	dce50513          	addi	a0,a0,-562 # 800236c0 <disk+0x18>
    800058fa:	833fc0ef          	jal	8000212c <wakeup>
}
    800058fe:	60a2                	ld	ra,8(sp)
    80005900:	6402                	ld	s0,0(sp)
    80005902:	0141                	addi	sp,sp,16
    80005904:	8082                	ret
    panic("free_desc 1");
    80005906:	00002517          	auipc	a0,0x2
    8000590a:	e8250513          	addi	a0,a0,-382 # 80007788 <etext+0x788>
    8000590e:	f27fa0ef          	jal	80000834 <panic>
    panic("free_desc 2");
    80005912:	00002517          	auipc	a0,0x2
    80005916:	e8650513          	addi	a0,a0,-378 # 80007798 <etext+0x798>
    8000591a:	f1bfa0ef          	jal	80000834 <panic>

000000008000591e <virtio_disk_init>:
{
    8000591e:	1101                	addi	sp,sp,-32
    80005920:	ec06                	sd	ra,24(sp)
    80005922:	e822                	sd	s0,16(sp)
    80005924:	e426                	sd	s1,8(sp)
    80005926:	e04a                	sd	s2,0(sp)
    80005928:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000592a:	00002597          	auipc	a1,0x2
    8000592e:	e7e58593          	addi	a1,a1,-386 # 800077a8 <etext+0x7a8>
    80005932:	0001e517          	auipc	a0,0x1e
    80005936:	e9e50513          	addi	a0,a0,-354 # 800237d0 <disk+0x128>
    8000593a:	a6efb0ef          	jal	80000ba8 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000593e:	100017b7          	lui	a5,0x10001
    80005942:	4398                	lw	a4,0(a5)
    80005944:	2701                	sext.w	a4,a4
    80005946:	747277b7          	lui	a5,0x74727
    8000594a:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000594e:	14f71863          	bne	a4,a5,80005a9e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005952:	100017b7          	lui	a5,0x10001
    80005956:	43dc                	lw	a5,4(a5)
    80005958:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000595a:	4709                	li	a4,2
    8000595c:	14e79163          	bne	a5,a4,80005a9e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005960:	100017b7          	lui	a5,0x10001
    80005964:	479c                	lw	a5,8(a5)
    80005966:	2781                	sext.w	a5,a5
    80005968:	12e79b63          	bne	a5,a4,80005a9e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    8000596c:	100017b7          	lui	a5,0x10001
    80005970:	47d8                	lw	a4,12(a5)
    80005972:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005974:	554d47b7          	lui	a5,0x554d4
    80005978:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000597c:	12f71163          	bne	a4,a5,80005a9e <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005980:	100017b7          	lui	a5,0x10001
    80005984:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005988:	4705                	li	a4,1
    8000598a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000598c:	470d                	li	a4,3
    8000598e:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005990:	10001737          	lui	a4,0x10001
    80005994:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005996:	c7ffe6b7          	lui	a3,0xc7ffe
    8000599a:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fdad77>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000599e:	8f75                	and	a4,a4,a3
    800059a0:	100016b7          	lui	a3,0x10001
    800059a4:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800059a6:	472d                	li	a4,11
    800059a8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800059aa:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800059ae:	439c                	lw	a5,0(a5)
    800059b0:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800059b4:	8ba1                	andi	a5,a5,8
    800059b6:	0e078a63          	beqz	a5,80005aaa <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800059ba:	100017b7          	lui	a5,0x10001
    800059be:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    800059c2:	43fc                	lw	a5,68(a5)
    800059c4:	2781                	sext.w	a5,a5
    800059c6:	0e079863          	bnez	a5,80005ab6 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800059ca:	100017b7          	lui	a5,0x10001
    800059ce:	5bdc                	lw	a5,52(a5)
    800059d0:	2781                	sext.w	a5,a5
  if (max == 0)
    800059d2:	0e078863          	beqz	a5,80005ac2 <virtio_disk_init+0x1a4>
  if (max < NUM)
    800059d6:	471d                	li	a4,7
    800059d8:	0ef77b63          	bgeu	a4,a5,80005ace <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    800059dc:	972fb0ef          	jal	80000b4e <kalloc>
    800059e0:	0001e497          	auipc	s1,0x1e
    800059e4:	cc848493          	addi	s1,s1,-824 # 800236a8 <disk>
    800059e8:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800059ea:	964fb0ef          	jal	80000b4e <kalloc>
    800059ee:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800059f0:	95efb0ef          	jal	80000b4e <kalloc>
    800059f4:	87aa                	mv	a5,a0
    800059f6:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    800059f8:	6088                	ld	a0,0(s1)
    800059fa:	0e050063          	beqz	a0,80005ada <virtio_disk_init+0x1bc>
    800059fe:	0001e717          	auipc	a4,0x1e
    80005a02:	cb273703          	ld	a4,-846(a4) # 800236b0 <disk+0x8>
    80005a06:	cb71                	beqz	a4,80005ada <virtio_disk_init+0x1bc>
    80005a08:	cbe9                	beqz	a5,80005ada <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005a0a:	6605                	lui	a2,0x1
    80005a0c:	4581                	li	a1,0
    80005a0e:	adafb0ef          	jal	80000ce8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005a12:	0001e497          	auipc	s1,0x1e
    80005a16:	c9648493          	addi	s1,s1,-874 # 800236a8 <disk>
    80005a1a:	6605                	lui	a2,0x1
    80005a1c:	4581                	li	a1,0
    80005a1e:	6488                	ld	a0,8(s1)
    80005a20:	ac8fb0ef          	jal	80000ce8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005a24:	6605                	lui	a2,0x1
    80005a26:	4581                	li	a1,0
    80005a28:	6888                	ld	a0,16(s1)
    80005a2a:	abefb0ef          	jal	80000ce8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005a2e:	100017b7          	lui	a5,0x10001
    80005a32:	4721                	li	a4,8
    80005a34:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005a36:	4098                	lw	a4,0(s1)
    80005a38:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005a3c:	40d8                	lw	a4,4(s1)
    80005a3e:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005a42:	649c                	ld	a5,8(s1)
    80005a44:	0007869b          	sext.w	a3,a5
    80005a48:	10001737          	lui	a4,0x10001
    80005a4c:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005a50:	9781                	srai	a5,a5,0x20
    80005a52:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005a56:	689c                	ld	a5,16(s1)
    80005a58:	0007869b          	sext.w	a3,a5
    80005a5c:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005a60:	9781                	srai	a5,a5,0x20
    80005a62:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005a66:	4785                	li	a5,1
    80005a68:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005a6a:	00f48c23          	sb	a5,24(s1)
    80005a6e:	00f48ca3          	sb	a5,25(s1)
    80005a72:	00f48d23          	sb	a5,26(s1)
    80005a76:	00f48da3          	sb	a5,27(s1)
    80005a7a:	00f48e23          	sb	a5,28(s1)
    80005a7e:	00f48ea3          	sb	a5,29(s1)
    80005a82:	00f48f23          	sb	a5,30(s1)
    80005a86:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005a8a:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a8e:	07272823          	sw	s2,112(a4)
}
    80005a92:	60e2                	ld	ra,24(sp)
    80005a94:	6442                	ld	s0,16(sp)
    80005a96:	64a2                	ld	s1,8(sp)
    80005a98:	6902                	ld	s2,0(sp)
    80005a9a:	6105                	addi	sp,sp,32
    80005a9c:	8082                	ret
    panic("could not find virtio disk");
    80005a9e:	00002517          	auipc	a0,0x2
    80005aa2:	d1a50513          	addi	a0,a0,-742 # 800077b8 <etext+0x7b8>
    80005aa6:	d8ffa0ef          	jal	80000834 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005aaa:	00002517          	auipc	a0,0x2
    80005aae:	d2e50513          	addi	a0,a0,-722 # 800077d8 <etext+0x7d8>
    80005ab2:	d83fa0ef          	jal	80000834 <panic>
    panic("virtio disk should not be ready");
    80005ab6:	00002517          	auipc	a0,0x2
    80005aba:	d4250513          	addi	a0,a0,-702 # 800077f8 <etext+0x7f8>
    80005abe:	d77fa0ef          	jal	80000834 <panic>
    panic("virtio disk has no queue 0");
    80005ac2:	00002517          	auipc	a0,0x2
    80005ac6:	d5650513          	addi	a0,a0,-682 # 80007818 <etext+0x818>
    80005aca:	d6bfa0ef          	jal	80000834 <panic>
    panic("virtio disk max queue too short");
    80005ace:	00002517          	auipc	a0,0x2
    80005ad2:	d6a50513          	addi	a0,a0,-662 # 80007838 <etext+0x838>
    80005ad6:	d5ffa0ef          	jal	80000834 <panic>
    panic("virtio disk kalloc");
    80005ada:	00002517          	auipc	a0,0x2
    80005ade:	d7e50513          	addi	a0,a0,-642 # 80007858 <etext+0x858>
    80005ae2:	d53fa0ef          	jal	80000834 <panic>

0000000080005ae6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005ae6:	711d                	addi	sp,sp,-96
    80005ae8:	ec86                	sd	ra,88(sp)
    80005aea:	e8a2                	sd	s0,80(sp)
    80005aec:	e4a6                	sd	s1,72(sp)
    80005aee:	e0ca                	sd	s2,64(sp)
    80005af0:	fc4e                	sd	s3,56(sp)
    80005af2:	f852                	sd	s4,48(sp)
    80005af4:	f456                	sd	s5,40(sp)
    80005af6:	f05a                	sd	s6,32(sp)
    80005af8:	ec5e                	sd	s7,24(sp)
    80005afa:	e862                	sd	s8,16(sp)
    80005afc:	1080                	addi	s0,sp,96
    80005afe:	89aa                	mv	s3,a0
    80005b00:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005b02:	00c52b83          	lw	s7,12(a0)
    80005b06:	001b9b9b          	slliw	s7,s7,0x1
    80005b0a:	1b82                	slli	s7,s7,0x20
    80005b0c:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005b10:	0001e517          	auipc	a0,0x1e
    80005b14:	cc050513          	addi	a0,a0,-832 # 800237d0 <disk+0x128>
    80005b18:	910fb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < NUM; i++) {
    80005b1c:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005b1e:	0001ea97          	auipc	s5,0x1e
    80005b22:	b8aa8a93          	addi	s5,s5,-1142 # 800236a8 <disk>
  for (int i = 0; i < 3; i++) {
    80005b26:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005b28:	5c7d                	li	s8,-1
    80005b2a:	a8a5                	j	80005ba2 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80005b2c:	00fa8733          	add	a4,s5,a5
    80005b30:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005b34:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005b36:	0207c563          	bltz	a5,80005b60 <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    80005b3a:	2905                	addiw	s2,s2,1
    80005b3c:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005b3e:	07490663          	beq	s2,s4,80005baa <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80005b42:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005b44:	0001e717          	auipc	a4,0x1e
    80005b48:	b6470713          	addi	a4,a4,-1180 # 800236a8 <disk>
    80005b4c:	4781                	li	a5,0
    if (disk.free[i]) {
    80005b4e:	01874683          	lbu	a3,24(a4)
    80005b52:	fee9                	bnez	a3,80005b2c <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    80005b54:	2785                	addiw	a5,a5,1
    80005b56:	0705                	addi	a4,a4,1
    80005b58:	fe979be3          	bne	a5,s1,80005b4e <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005b5c:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    80005b60:	01205d63          	blez	s2,80005b7a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005b64:	fa042503          	lw	a0,-96(s0)
    80005b68:	d41ff0ef          	jal	800058a8 <free_desc>
      for (int j = 0; j < i; j++)
    80005b6c:	4785                	li	a5,1
    80005b6e:	0127d663          	bge	a5,s2,80005b7a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005b72:	fa442503          	lw	a0,-92(s0)
    80005b76:	d33ff0ef          	jal	800058a8 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005b7a:	0001e517          	auipc	a0,0x1e
    80005b7e:	b4650513          	addi	a0,a0,-1210 # 800236c0 <disk+0x18>
    80005b82:	d3efc0ef          	jal	800020c0 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005b86:	0001e517          	auipc	a0,0x1e
    80005b8a:	c4a50513          	addi	a0,a0,-950 # 800237d0 <disk+0x128>
    80005b8e:	922fb0ef          	jal	80000cb0 <release>
    sleep();
    80005b92:	d6afc0ef          	jal	800020fc <sleep>
    acquire(&disk.vdisk_lock);
    80005b96:	0001e517          	auipc	a0,0x1e
    80005b9a:	c3a50513          	addi	a0,a0,-966 # 800237d0 <disk+0x128>
    80005b9e:	88afb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < 3; i++) {
    80005ba2:	fa040613          	addi	a2,s0,-96
    80005ba6:	4901                	li	s2,0
    80005ba8:	bf69                	j	80005b42 <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005baa:	fa042503          	lw	a0,-96(s0)
    80005bae:	00451693          	slli	a3,a0,0x4

  if (write)
    80005bb2:	0001e797          	auipc	a5,0x1e
    80005bb6:	af678793          	addi	a5,a5,-1290 # 800236a8 <disk>
    80005bba:	00451713          	slli	a4,a0,0x4
    80005bbe:	0a070713          	addi	a4,a4,160
    80005bc2:	973e                	add	a4,a4,a5
    80005bc4:	01603633          	snez	a2,s6
    80005bc8:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005bca:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005bce:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005bd2:	6398                	ld	a4,0(a5)
    80005bd4:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005bd6:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005bda:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005bdc:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005bde:	6390                	ld	a2,0(a5)
    80005be0:	00d60833          	add	a6,a2,a3
    80005be4:	4741                	li	a4,16
    80005be6:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005bea:	4585                	li	a1,1
    80005bec:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005bf0:	fa442703          	lw	a4,-92(s0)
    80005bf4:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005bf8:	0712                	slli	a4,a4,0x4
    80005bfa:	963a                	add	a2,a2,a4
    80005bfc:	05898813          	addi	a6,s3,88
    80005c00:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005c04:	0007b883          	ld	a7,0(a5)
    80005c08:	9746                	add	a4,a4,a7
    80005c0a:	40000613          	li	a2,1024
    80005c0e:	c710                	sw	a2,8(a4)
  if (write)
    80005c10:	001b3613          	seqz	a2,s6
    80005c14:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005c18:	8e4d                	or	a2,a2,a1
    80005c1a:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005c1e:	fa842603          	lw	a2,-88(s0)
    80005c22:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005c26:	00451813          	slli	a6,a0,0x4
    80005c2a:	02080813          	addi	a6,a6,32
    80005c2e:	983e                	add	a6,a6,a5
    80005c30:	577d                	li	a4,-1
    80005c32:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005c36:	0612                	slli	a2,a2,0x4
    80005c38:	98b2                	add	a7,a7,a2
    80005c3a:	03068713          	addi	a4,a3,48
    80005c3e:	973e                	add	a4,a4,a5
    80005c40:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005c44:	6398                	ld	a4,0(a5)
    80005c46:	9732                	add	a4,a4,a2
    80005c48:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005c4a:	4689                	li	a3,2
    80005c4c:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005c50:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005c54:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005c58:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005c5c:	6794                	ld	a3,8(a5)
    80005c5e:	0026d703          	lhu	a4,2(a3)
    80005c62:	8b1d                	andi	a4,a4,7
    80005c64:	0706                	slli	a4,a4,0x1
    80005c66:	96ba                	add	a3,a3,a4
    80005c68:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005c6c:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005c70:	6798                	ld	a4,8(a5)
    80005c72:	00275783          	lhu	a5,2(a4)
    80005c76:	2785                	addiw	a5,a5,1
    80005c78:	00f71123          	sh	a5,2(a4)
    80005c7c:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005c80:	100017b7          	lui	a5,0x10001
    80005c84:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005c88:	0049a783          	lw	a5,4(s3)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005c8c:	0001e497          	auipc	s1,0x1e
    80005c90:	b4448493          	addi	s1,s1,-1212 # 800237d0 <disk+0x128>
  while (b->disk == 1) {
    80005c94:	892e                	mv	s2,a1
    80005c96:	02b79163          	bne	a5,a1,80005cb8 <virtio_disk_rw+0x1d2>
    sleep_prepare(b);
    80005c9a:	854e                	mv	a0,s3
    80005c9c:	c24fc0ef          	jal	800020c0 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005ca0:	8526                	mv	a0,s1
    80005ca2:	80efb0ef          	jal	80000cb0 <release>
    sleep();
    80005ca6:	c56fc0ef          	jal	800020fc <sleep>
    acquire(&disk.vdisk_lock);
    80005caa:	8526                	mv	a0,s1
    80005cac:	f7dfa0ef          	jal	80000c28 <acquire>
  while (b->disk == 1) {
    80005cb0:	0049a783          	lw	a5,4(s3)
    80005cb4:	ff2783e3          	beq	a5,s2,80005c9a <virtio_disk_rw+0x1b4>
  }

  disk.info[idx[0]].b = 0;
    80005cb8:	fa042903          	lw	s2,-96(s0)
    80005cbc:	00491713          	slli	a4,s2,0x4
    80005cc0:	02070713          	addi	a4,a4,32
    80005cc4:	0001e797          	auipc	a5,0x1e
    80005cc8:	9e478793          	addi	a5,a5,-1564 # 800236a8 <disk>
    80005ccc:	97ba                	add	a5,a5,a4
    80005cce:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005cd2:	0001e997          	auipc	s3,0x1e
    80005cd6:	9d698993          	addi	s3,s3,-1578 # 800236a8 <disk>
    80005cda:	00491713          	slli	a4,s2,0x4
    80005cde:	0009b783          	ld	a5,0(s3)
    80005ce2:	97ba                	add	a5,a5,a4
    80005ce4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005ce8:	854a                	mv	a0,s2
    80005cea:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005cee:	bbbff0ef          	jal	800058a8 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005cf2:	8885                	andi	s1,s1,1
    80005cf4:	f0fd                	bnez	s1,80005cda <virtio_disk_rw+0x1f4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005cf6:	0001e517          	auipc	a0,0x1e
    80005cfa:	ada50513          	addi	a0,a0,-1318 # 800237d0 <disk+0x128>
    80005cfe:	fb3fa0ef          	jal	80000cb0 <release>
}
    80005d02:	60e6                	ld	ra,88(sp)
    80005d04:	6446                	ld	s0,80(sp)
    80005d06:	64a6                	ld	s1,72(sp)
    80005d08:	6906                	ld	s2,64(sp)
    80005d0a:	79e2                	ld	s3,56(sp)
    80005d0c:	7a42                	ld	s4,48(sp)
    80005d0e:	7aa2                	ld	s5,40(sp)
    80005d10:	7b02                	ld	s6,32(sp)
    80005d12:	6be2                	ld	s7,24(sp)
    80005d14:	6c42                	ld	s8,16(sp)
    80005d16:	6125                	addi	sp,sp,96
    80005d18:	8082                	ret

0000000080005d1a <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005d1a:	1101                	addi	sp,sp,-32
    80005d1c:	ec06                	sd	ra,24(sp)
    80005d1e:	e822                	sd	s0,16(sp)
    80005d20:	e426                	sd	s1,8(sp)
    80005d22:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005d24:	0001e497          	auipc	s1,0x1e
    80005d28:	98448493          	addi	s1,s1,-1660 # 800236a8 <disk>
    80005d2c:	0001e517          	auipc	a0,0x1e
    80005d30:	aa450513          	addi	a0,a0,-1372 # 800237d0 <disk+0x128>
    80005d34:	ef5fa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005d38:	100017b7          	lui	a5,0x10001
    80005d3c:	53bc                	lw	a5,96(a5)
    80005d3e:	8b8d                	andi	a5,a5,3
    80005d40:	10001737          	lui	a4,0x10001
    80005d44:	d37c                	sw	a5,100(a4)
    80005d46:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005d4a:	689c                	ld	a5,16(s1)
    80005d4c:	0204d703          	lhu	a4,32(s1)
    80005d50:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005d54:	04f70863          	beq	a4,a5,80005da4 <virtio_disk_intr+0x8a>
    80005d58:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005d5c:	6898                	ld	a4,16(s1)
    80005d5e:	0204d783          	lhu	a5,32(s1)
    80005d62:	8b9d                	andi	a5,a5,7
    80005d64:	078e                	slli	a5,a5,0x3
    80005d66:	97ba                	add	a5,a5,a4
    80005d68:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005d6a:	00479713          	slli	a4,a5,0x4
    80005d6e:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005d72:	9726                	add	a4,a4,s1
    80005d74:	01074703          	lbu	a4,16(a4)
    80005d78:	e329                	bnez	a4,80005dba <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005d7a:	0792                	slli	a5,a5,0x4
    80005d7c:	02078793          	addi	a5,a5,32
    80005d80:	97a6                	add	a5,a5,s1
    80005d82:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005d84:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005d88:	ba4fc0ef          	jal	8000212c <wakeup>

    disk.used_idx += 1;
    80005d8c:	0204d783          	lhu	a5,32(s1)
    80005d90:	2785                	addiw	a5,a5,1
    80005d92:	17c2                	slli	a5,a5,0x30
    80005d94:	93c1                	srli	a5,a5,0x30
    80005d96:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005d9a:	6898                	ld	a4,16(s1)
    80005d9c:	00275703          	lhu	a4,2(a4)
    80005da0:	faf71ce3          	bne	a4,a5,80005d58 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005da4:	0001e517          	auipc	a0,0x1e
    80005da8:	a2c50513          	addi	a0,a0,-1492 # 800237d0 <disk+0x128>
    80005dac:	f05fa0ef          	jal	80000cb0 <release>
}
    80005db0:	60e2                	ld	ra,24(sp)
    80005db2:	6442                	ld	s0,16(sp)
    80005db4:	64a2                	ld	s1,8(sp)
    80005db6:	6105                	addi	sp,sp,32
    80005db8:	8082                	ret
      panic("virtio_disk_intr status");
    80005dba:	00002517          	auipc	a0,0x2
    80005dbe:	ab650513          	addi	a0,a0,-1354 # 80007870 <etext+0x870>
    80005dc2:	a73fa0ef          	jal	80000834 <panic>
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
