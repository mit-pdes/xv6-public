
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
    8000011c:	334020ef          	jal	80002450 <either_copyin>
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
    800001c4:	10c020ef          	jal	800022d0 <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	6a7010ef          	jal	80002072 <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	2df000ef          	jal	80000cb0 <release>
      sleep();
    800001d6:	6d9010ef          	jal	800020ae <sleep>
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
    80000220:	1e4020ef          	jal	80002404 <either_copyout>
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
    800002ea:	1b2020ef          	jal	8000249c <procdump>
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
    8000042a:	4b5010ef          	jal	800020de <wakeup>
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
    8000093a:	738010ef          	jal	80002072 <sleep_prepare>
      release(&tx_lock);
    8000093e:	8526                	mv	a0,s1
    80000940:	370000ef          	jal	80000cb0 <release>
      sleep();
    80000944:	76a010ef          	jal	800020ae <sleep>
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
    80000a54:	68a010ef          	jal	800020de <wakeup>
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
    80000ed4:	6fa010ef          	jal	800025ce <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ed8:	0f1040ef          	jal	800057c8 <plicinithart>
  }

  scheduler();
    80000edc:	77f000ef          	jal	80001e5a <scheduler>
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
    80000f1c:	68e010ef          	jal	800025aa <trapinit>
    trapinithart();     // install kernel trap vector
    80000f20:	6ae010ef          	jal	800025ce <trapinithart>
    plicinit();         // set up interrupt controller
    80000f24:	08b040ef          	jal	800057ae <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f28:	0a1040ef          	jal	800057c8 <plicinithart>
    binit();            // buffer cache
    80000f2c:	543010ef          	jal	80002c6e <binit>
    iinit();            // inode table
    80000f30:	294020ef          	jal	800031c4 <iinit>
    fileinit();         // file table
    80000f34:	2c2030ef          	jal	800041f6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f38:	187040ef          	jal	800058be <virtio_disk_init>
    userinit();         // first user process
    80000f3c:	4ff000ef          	jal	80001c3a <userinit>
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
    800019a2:	527010ef          	jal	800036c8 <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    800019a6:	00005797          	auipc	a5,0x5
    800019aa:	7da78793          	addi	a5,a5,2010 # 80007180 <etext+0x180>
    800019ae:	fcf43823          	sd	a5,-48(s0)
    800019b2:	fc043c23          	sd	zero,-40(s0)
    800019b6:	fd040593          	addi	a1,s0,-48
    800019ba:	853e                	mv	a0,a5
    800019bc:	7c1020ef          	jal	8000497c <kexec>
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
    800019ce:	41d000ef          	jal	800025ea <prepare_return>
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
  p->ctime = 0;
    80001b5a:	1604a423          	sw	zero,360(s1)
  p->burst_time = 0;
    80001b5e:	1604a623          	sw	zero,364(s1)
}
    80001b62:	60e2                	ld	ra,24(sp)
    80001b64:	6442                	ld	s0,16(sp)
    80001b66:	64a2                	ld	s1,8(sp)
    80001b68:	6105                	addi	sp,sp,32
    80001b6a:	8082                	ret

0000000080001b6c <allocproc>:
{
    80001b6c:	1101                	addi	sp,sp,-32
    80001b6e:	ec06                	sd	ra,24(sp)
    80001b70:	e822                	sd	s0,16(sp)
    80001b72:	e426                	sd	s1,8(sp)
    80001b74:	e04a                	sd	s2,0(sp)
    80001b76:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b78:	00011497          	auipc	s1,0x11
    80001b7c:	d2048493          	addi	s1,s1,-736 # 80012898 <proc>
    80001b80:	00017917          	auipc	s2,0x17
    80001b84:	91890913          	addi	s2,s2,-1768 # 80018498 <tickslock>
    acquire(&p->lock);
    80001b88:	8526                	mv	a0,s1
    80001b8a:	89eff0ef          	jal	80000c28 <acquire>
    if (p->state == UNUSED) {
    80001b8e:	4c9c                	lw	a5,24(s1)
    80001b90:	cb91                	beqz	a5,80001ba4 <allocproc+0x38>
      release(&p->lock);
    80001b92:	8526                	mv	a0,s1
    80001b94:	91cff0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b98:	17048493          	addi	s1,s1,368
    80001b9c:	ff2496e3          	bne	s1,s2,80001b88 <allocproc+0x1c>
  return 0;
    80001ba0:	4481                	li	s1,0
    80001ba2:	a0ad                	j	80001c0c <allocproc+0xa0>
  p->pid = allocpid();
    80001ba4:	e6dff0ef          	jal	80001a10 <allocpid>
    80001ba8:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001baa:	4785                	li	a5,1
    80001bac:	cc9c                	sw	a5,24(s1)
  acquire(&tickslock);
    80001bae:	00017517          	auipc	a0,0x17
    80001bb2:	8ea50513          	addi	a0,a0,-1814 # 80018498 <tickslock>
    80001bb6:	872ff0ef          	jal	80000c28 <acquire>
  p->ctime = ticks;
    80001bba:	00008797          	auipc	a5,0x8
    80001bbe:	7ae7a783          	lw	a5,1966(a5) # 8000a368 <ticks>
    80001bc2:	16f4a423          	sw	a5,360(s1)
  release(&tickslock);
    80001bc6:	00017517          	auipc	a0,0x17
    80001bca:	8d250513          	addi	a0,a0,-1838 # 80018498 <tickslock>
    80001bce:	8e2ff0ef          	jal	80000cb0 <release>
  p->burst_time = 0;
    80001bd2:	1604a623          	sw	zero,364(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001bd6:	f79fe0ef          	jal	80000b4e <kalloc>
    80001bda:	892a                	mv	s2,a0
    80001bdc:	eca8                	sd	a0,88(s1)
    80001bde:	cd15                	beqz	a0,80001c1a <allocproc+0xae>
  p->pagetable = proc_pagetable(p);
    80001be0:	8526                	mv	a0,s1
    80001be2:	e6dff0ef          	jal	80001a4e <proc_pagetable>
    80001be6:	892a                	mv	s2,a0
    80001be8:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001bea:	c121                	beqz	a0,80001c2a <allocproc+0xbe>
  memset(&p->context, 0, sizeof(p->context));
    80001bec:	07000613          	li	a2,112
    80001bf0:	4581                	li	a1,0
    80001bf2:	06048513          	addi	a0,s1,96
    80001bf6:	8f2ff0ef          	jal	80000ce8 <memset>
  p->context.ra = (uint64)forkret;
    80001bfa:	00000797          	auipc	a5,0x0
    80001bfe:	d8078793          	addi	a5,a5,-640 # 8000197a <forkret>
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
    80001c1c:	efdff0ef          	jal	80001b18 <freeproc>
    release(&p->lock);
    80001c20:	8526                	mv	a0,s1
    80001c22:	88eff0ef          	jal	80000cb0 <release>
    return 0;
    80001c26:	84ca                	mv	s1,s2
    80001c28:	b7d5                	j	80001c0c <allocproc+0xa0>
    freeproc(p);
    80001c2a:	8526                	mv	a0,s1
    80001c2c:	eedff0ef          	jal	80001b18 <freeproc>
    release(&p->lock);
    80001c30:	8526                	mv	a0,s1
    80001c32:	87eff0ef          	jal	80000cb0 <release>
    return 0;
    80001c36:	84ca                	mv	s1,s2
    80001c38:	bfd1                	j	80001c0c <allocproc+0xa0>

0000000080001c3a <userinit>:
{
    80001c3a:	1101                	addi	sp,sp,-32
    80001c3c:	ec06                	sd	ra,24(sp)
    80001c3e:	e822                	sd	s0,16(sp)
    80001c40:	e426                	sd	s1,8(sp)
    80001c42:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c44:	f29ff0ef          	jal	80001b6c <allocproc>
    80001c48:	84aa                	mv	s1,a0
  initproc = p;
    80001c4a:	00008797          	auipc	a5,0x8
    80001c4e:	70a7bb23          	sd	a0,1814(a5) # 8000a360 <initproc>
  p->cwd = namei("/");
    80001c52:	00005517          	auipc	a0,0x5
    80001c56:	53e50513          	addi	a0,a0,1342 # 80007190 <etext+0x190>
    80001c5a:	7cd010ef          	jal	80003c26 <namei>
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
    80001c84:	cc5ff0ef          	jal	80001948 <myproc>
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
    80001ca4:	e4aff0ef          	jal	800012ee <uvmalloc>
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
    80001cc8:	de2ff0ef          	jal	800012aa <uvmdealloc>
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
    80001ce4:	c65ff0ef          	jal	80001948 <myproc>
    80001ce8:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001cea:	e83ff0ef          	jal	80001b6c <allocproc>
    80001cee:	0e050a63          	beqz	a0,80001de2 <kfork+0x10a>
    80001cf2:	e852                	sd	s4,16(sp)
    80001cf4:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001cf6:	048ab603          	ld	a2,72(s5)
    80001cfa:	692c                	ld	a1,80(a0)
    80001cfc:	050ab503          	ld	a0,80(s5)
    80001d00:	f26ff0ef          	jal	80001426 <uvmcopy>
    80001d04:	04054863          	bltz	a0,80001d54 <kfork+0x7c>
    80001d08:	f04a                	sd	s2,32(sp)
    80001d0a:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001d0c:	048ab783          	ld	a5,72(s5)
    80001d10:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001d14:	058ab683          	ld	a3,88(s5)
    80001d18:	87b6                	mv	a5,a3
    80001d1a:	058a3703          	ld	a4,88(s4)
    80001d1e:	12068693          	addi	a3,a3,288
    80001d22:	6388                	ld	a0,0(a5)
    80001d24:	678c                	ld	a1,8(a5)
    80001d26:	6b90                	ld	a2,16(a5)
    80001d28:	e308                	sd	a0,0(a4)
    80001d2a:	e70c                	sd	a1,8(a4)
    80001d2c:	eb10                	sd	a2,16(a4)
    80001d2e:	6f90                	ld	a2,24(a5)
    80001d30:	ef10                	sd	a2,24(a4)
    80001d32:	02078793          	addi	a5,a5,32
    80001d36:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d3a:	fed794e3          	bne	a5,a3,80001d22 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d3e:	058a3783          	ld	a5,88(s4)
    80001d42:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001d46:	0d0a8493          	addi	s1,s5,208
    80001d4a:	0d0a0913          	addi	s2,s4,208
    80001d4e:	150a8993          	addi	s3,s5,336
    80001d52:	a831                	j	80001d6e <kfork+0x96>
    freeproc(np);
    80001d54:	8552                	mv	a0,s4
    80001d56:	dc3ff0ef          	jal	80001b18 <freeproc>
    release(&np->lock);
    80001d5a:	8552                	mv	a0,s4
    80001d5c:	f55fe0ef          	jal	80000cb0 <release>
    return -1;
    80001d60:	54fd                	li	s1,-1
    80001d62:	6a42                	ld	s4,16(sp)
    80001d64:	a885                	j	80001dd4 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001d66:	04a1                	addi	s1,s1,8
    80001d68:	0921                	addi	s2,s2,8
    80001d6a:	01348963          	beq	s1,s3,80001d7c <kfork+0xa4>
    if (p->ofile[i])
    80001d6e:	6088                	ld	a0,0(s1)
    80001d70:	d97d                	beqz	a0,80001d66 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d72:	506020ef          	jal	80004278 <filedup>
    80001d76:	00a93023          	sd	a0,0(s2)
    80001d7a:	b7f5                	j	80001d66 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d7c:	150ab503          	ld	a0,336(s5)
    80001d80:	5d6010ef          	jal	80003356 <idup>
    80001d84:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d88:	4641                	li	a2,16
    80001d8a:	158a8593          	addi	a1,s5,344
    80001d8e:	158a0513          	addi	a0,s4,344
    80001d92:	8aaff0ef          	jal	80000e3c <safestrcpy>
  pid = np->pid;
    80001d96:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001d9a:	8552                	mv	a0,s4
    80001d9c:	f15fe0ef          	jal	80000cb0 <release>
  acquire(&wait_lock);
    80001da0:	00010517          	auipc	a0,0x10
    80001da4:	6e050513          	addi	a0,a0,1760 # 80012480 <wait_lock>
    80001da8:	e81fe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001dac:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001db0:	00010517          	auipc	a0,0x10
    80001db4:	6d050513          	addi	a0,a0,1744 # 80012480 <wait_lock>
    80001db8:	ef9fe0ef          	jal	80000cb0 <release>
  acquire(&np->lock);
    80001dbc:	8552                	mv	a0,s4
    80001dbe:	e6bfe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001dc2:	478d                	li	a5,3
    80001dc4:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001dc8:	8552                	mv	a0,s4
    80001dca:	ee7fe0ef          	jal	80000cb0 <release>
  return pid;
    80001dce:	7902                	ld	s2,32(sp)
    80001dd0:	69e2                	ld	s3,24(sp)
    80001dd2:	6a42                	ld	s4,16(sp)
}
    80001dd4:	8526                	mv	a0,s1
    80001dd6:	70e2                	ld	ra,56(sp)
    80001dd8:	7442                	ld	s0,48(sp)
    80001dda:	74a2                	ld	s1,40(sp)
    80001ddc:	6aa2                	ld	s5,8(sp)
    80001dde:	6121                	addi	sp,sp,64
    80001de0:	8082                	ret
    return -1;
    80001de2:	54fd                	li	s1,-1
    80001de4:	bfc5                	j	80001dd4 <kfork+0xfc>

0000000080001de6 <set_burst>:
  if (bt <= 0)
    80001de6:	06b05863          	blez	a1,80001e56 <set_burst+0x70>
{
    80001dea:	7179                	addi	sp,sp,-48
    80001dec:	f406                	sd	ra,40(sp)
    80001dee:	f022                	sd	s0,32(sp)
    80001df0:	ec26                	sd	s1,24(sp)
    80001df2:	e84a                	sd	s2,16(sp)
    80001df4:	e44e                	sd	s3,8(sp)
    80001df6:	e052                	sd	s4,0(sp)
    80001df8:	1800                	addi	s0,sp,48
    80001dfa:	892a                	mv	s2,a0
    80001dfc:	8a2e                	mv	s4,a1
  for (p = proc; p < &proc[NPROC]; p++) {
    80001dfe:	00011497          	auipc	s1,0x11
    80001e02:	a9a48493          	addi	s1,s1,-1382 # 80012898 <proc>
    80001e06:	00016997          	auipc	s3,0x16
    80001e0a:	69298993          	addi	s3,s3,1682 # 80018498 <tickslock>
    80001e0e:	a801                	j	80001e1e <set_burst+0x38>
    release(&p->lock);
    80001e10:	8526                	mv	a0,s1
    80001e12:	e9ffe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001e16:	17048493          	addi	s1,s1,368
    80001e1a:	03348c63          	beq	s1,s3,80001e52 <set_burst+0x6c>
    acquire(&p->lock);
    80001e1e:	8526                	mv	a0,s1
    80001e20:	e09fe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid || (pid == 0 && p == myproc())) {
    80001e24:	589c                	lw	a5,48(s1)
    80001e26:	01278863          	beq	a5,s2,80001e36 <set_burst+0x50>
    80001e2a:	fe0913e3          	bnez	s2,80001e10 <set_burst+0x2a>
    80001e2e:	b1bff0ef          	jal	80001948 <myproc>
    80001e32:	fc951fe3          	bne	a0,s1,80001e10 <set_burst+0x2a>
      p->burst_time = bt;
    80001e36:	1744a623          	sw	s4,364(s1)
      release(&p->lock);
    80001e3a:	8526                	mv	a0,s1
    80001e3c:	e75fe0ef          	jal	80000cb0 <release>
      return 0;
    80001e40:	4501                	li	a0,0
}
    80001e42:	70a2                	ld	ra,40(sp)
    80001e44:	7402                	ld	s0,32(sp)
    80001e46:	64e2                	ld	s1,24(sp)
    80001e48:	6942                	ld	s2,16(sp)
    80001e4a:	69a2                	ld	s3,8(sp)
    80001e4c:	6a02                	ld	s4,0(sp)
    80001e4e:	6145                	addi	sp,sp,48
    80001e50:	8082                	ret
  return -1;
    80001e52:	557d                	li	a0,-1
    80001e54:	b7fd                	j	80001e42 <set_burst+0x5c>
    return -1;
    80001e56:	557d                	li	a0,-1
}
    80001e58:	8082                	ret

0000000080001e5a <scheduler>:
{
    80001e5a:	7119                	addi	sp,sp,-128
    80001e5c:	fc86                	sd	ra,120(sp)
    80001e5e:	f8a2                	sd	s0,112(sp)
    80001e60:	f4a6                	sd	s1,104(sp)
    80001e62:	f0ca                	sd	s2,96(sp)
    80001e64:	ecce                	sd	s3,88(sp)
    80001e66:	e8d2                	sd	s4,80(sp)
    80001e68:	e4d6                	sd	s5,72(sp)
    80001e6a:	e0da                	sd	s6,64(sp)
    80001e6c:	fc5e                	sd	s7,56(sp)
    80001e6e:	f862                	sd	s8,48(sp)
    80001e70:	f466                	sd	s9,40(sp)
    80001e72:	f06a                	sd	s10,32(sp)
    80001e74:	ec6e                	sd	s11,24(sp)
    80001e76:	0100                	addi	s0,sp,128
    80001e78:	8792                	mv	a5,tp
  int id = r_tp();
    80001e7a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001e7c:	00779693          	slli	a3,a5,0x7
    80001e80:	00010717          	auipc	a4,0x10
    80001e84:	5e870713          	addi	a4,a4,1512 # 80012468 <pid_lock>
    80001e88:	9736                	add	a4,a4,a3
    80001e8a:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &best_p->context);
    80001e8e:	00010717          	auipc	a4,0x10
    80001e92:	61270713          	addi	a4,a4,1554 # 800124a0 <cpus+0x8>
    80001e96:	9736                	add	a4,a4,a3
    80001e98:	f8e43423          	sd	a4,-120(s0)
    acquire(&tickslock);
    80001e9c:	00016d17          	auipc	s10,0x16
    80001ea0:	5fcd0d13          	addi	s10,s10,1532 # 80018498 <tickslock>
          ratio = 100;
    80001ea4:	06400b93          	li	s7,100
          ratio = ((w + p->burst_time) * 100) / p->burst_time;
    80001ea8:	06400c93          	li	s9,100
      c->proc = best_p;
    80001eac:	00010717          	auipc	a4,0x10
    80001eb0:	5bc70713          	addi	a4,a4,1468 # 80012468 <pid_lock>
    80001eb4:	00d70db3          	add	s11,a4,a3
    80001eb8:	a861                	j	80001f50 <scheduler+0xf6>
          ratio = ((w + p->burst_time) * 100) / p->burst_time;
    80001eba:	00f9093b          	addw	s2,s2,a5
    80001ebe:	032c893b          	mulw	s2,s9,s2
    80001ec2:	02f9493b          	divw	s2,s2,a5
        if (best_p == 0 || ratio > max_ratio) {
    80001ec6:	020a8e63          	beqz	s5,80001f02 <scheduler+0xa8>
    80001eca:	032b4c63          	blt	s6,s2,80001f02 <scheduler+0xa8>
      release(&p->lock);
    80001ece:	8526                	mv	a0,s1
    80001ed0:	de1fe0ef          	jal	80000cb0 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001ed4:	17048493          	addi	s1,s1,368
    80001ed8:	05348063          	beq	s1,s3,80001f18 <scheduler+0xbe>
      acquire(&p->lock);
    80001edc:	8526                	mv	a0,s1
    80001ede:	d4bfe0ef          	jal	80000c28 <acquire>
      if (p->state == RUNNABLE) {
    80001ee2:	4c9c                	lw	a5,24(s1)
    80001ee4:	ff4795e3          	bne	a5,s4,80001ece <scheduler+0x74>
        if (p->burst_time > 0) {
    80001ee8:	16c4a783          	lw	a5,364(s1)
          ratio = 100;
    80001eec:	895e                	mv	s2,s7
        if (p->burst_time > 0) {
    80001eee:	fcf05ce3          	blez	a5,80001ec6 <scheduler+0x6c>
          int w = (cur_ticks >= p->ctime) ? (cur_ticks - p->ctime) : 0;
    80001ef2:	1684a703          	lw	a4,360(s1)
    80001ef6:	4901                	li	s2,0
    80001ef8:	fcec61e3          	bltu	s8,a4,80001eba <scheduler+0x60>
    80001efc:	40ec093b          	subw	s2,s8,a4
    80001f00:	bf6d                	j	80001eba <scheduler+0x60>
          if (best_p)
    80001f02:	000a8863          	beqz	s5,80001f12 <scheduler+0xb8>
            release(&best_p->lock);
    80001f06:	8556                	mv	a0,s5
    80001f08:	da9fe0ef          	jal	80000cb0 <release>
          max_ratio = ratio;
    80001f0c:	8b4a                	mv	s6,s2
          best_p = p;
    80001f0e:	8aa6                	mv	s5,s1
    80001f10:	b7d1                	j	80001ed4 <scheduler+0x7a>
          max_ratio = ratio;
    80001f12:	8b4a                	mv	s6,s2
          best_p = p;
    80001f14:	8aa6                	mv	s5,s1
    80001f16:	bf7d                	j	80001ed4 <scheduler+0x7a>
    if (best_p) {
    80001f18:	060a8663          	beqz	s5,80001f84 <scheduler+0x12a>
      best_p->state = RUNNING;
    80001f1c:	4791                	li	a5,4
    80001f1e:	00faac23          	sw	a5,24(s5)
      c->proc = best_p;
    80001f22:	035db823          	sd	s5,48(s11)
      swtch(&c->context, &best_p->context);
    80001f26:	060a8593          	addi	a1,s5,96
    80001f2a:	f8843503          	ld	a0,-120(s0)
    80001f2e:	612000ef          	jal	80002540 <swtch>
    80001f32:	8792                	mv	a5,tp
      mycpu()->intena = 0;
    80001f34:	2781                	sext.w	a5,a5
    80001f36:	079e                	slli	a5,a5,0x7
    80001f38:	00010717          	auipc	a4,0x10
    80001f3c:	53070713          	addi	a4,a4,1328 # 80012468 <pid_lock>
    80001f40:	97ba                	add	a5,a5,a4
    80001f42:	0a07a623          	sw	zero,172(a5)
      c->proc = 0;
    80001f46:	020db823          	sd	zero,48(s11)
      release(&best_p->lock);
    80001f4a:	8556                	mv	a0,s5
    80001f4c:	d65fe0ef          	jal	80000cb0 <release>
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001f50:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001f54:	10017073          	csrci	sstatus,2
    acquire(&tickslock);
    80001f58:	856a                	mv	a0,s10
    80001f5a:	ccffe0ef          	jal	80000c28 <acquire>
    cur_ticks = ticks;
    80001f5e:	00008c17          	auipc	s8,0x8
    80001f62:	40ac2c03          	lw	s8,1034(s8) # 8000a368 <ticks>
    release(&tickslock);
    80001f66:	856a                	mv	a0,s10
    80001f68:	d49fe0ef          	jal	80000cb0 <release>
    int max_ratio = -1;
    80001f6c:	5b7d                	li	s6,-1
    struct proc *best_p = 0;
    80001f6e:	4a81                	li	s5,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f70:	00011497          	auipc	s1,0x11
    80001f74:	92848493          	addi	s1,s1,-1752 # 80012898 <proc>
      if (p->state == RUNNABLE) {
    80001f78:	4a0d                	li	s4,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f7a:	00016997          	auipc	s3,0x16
    80001f7e:	51e98993          	addi	s3,s3,1310 # 80018498 <tickslock>
    80001f82:	bfa9                	j	80001edc <scheduler+0x82>
      asm volatile("wfi");
    80001f84:	10500073          	wfi
    80001f88:	b7e1                	j	80001f50 <scheduler+0xf6>

0000000080001f8a <sched>:
{
    80001f8a:	7179                	addi	sp,sp,-48
    80001f8c:	f406                	sd	ra,40(sp)
    80001f8e:	f022                	sd	s0,32(sp)
    80001f90:	ec26                	sd	s1,24(sp)
    80001f92:	e84a                	sd	s2,16(sp)
    80001f94:	e44e                	sd	s3,8(sp)
    80001f96:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f98:	9b1ff0ef          	jal	80001948 <myproc>
    80001f9c:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001f9e:	c25fe0ef          	jal	80000bc2 <holding>
    80001fa2:	c935                	beqz	a0,80002016 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80001fa4:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001fa6:	2781                	sext.w	a5,a5
    80001fa8:	079e                	slli	a5,a5,0x7
    80001faa:	00010717          	auipc	a4,0x10
    80001fae:	4be70713          	addi	a4,a4,1214 # 80012468 <pid_lock>
    80001fb2:	97ba                	add	a5,a5,a4
    80001fb4:	0a87a703          	lw	a4,168(a5)
    80001fb8:	4785                	li	a5,1
    80001fba:	06f71463          	bne	a4,a5,80002022 <sched+0x98>
  if (p->state == RUNNING)
    80001fbe:	4c98                	lw	a4,24(s1)
    80001fc0:	4791                	li	a5,4
    80001fc2:	06f70663          	beq	a4,a5,8000202e <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001fc6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001fca:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001fcc:	e7bd                	bnez	a5,8000203a <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    80001fce:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001fd0:	00010917          	auipc	s2,0x10
    80001fd4:	49890913          	addi	s2,s2,1176 # 80012468 <pid_lock>
    80001fd8:	2781                	sext.w	a5,a5
    80001fda:	079e                	slli	a5,a5,0x7
    80001fdc:	97ca                	add	a5,a5,s2
    80001fde:	0ac7a983          	lw	s3,172(a5)
    80001fe2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fe4:	2781                	sext.w	a5,a5
    80001fe6:	079e                	slli	a5,a5,0x7
    80001fe8:	07a1                	addi	a5,a5,8
    80001fea:	00010597          	auipc	a1,0x10
    80001fee:	4ae58593          	addi	a1,a1,1198 # 80012498 <cpus>
    80001ff2:	95be                	add	a1,a1,a5
    80001ff4:	06048513          	addi	a0,s1,96
    80001ff8:	548000ef          	jal	80002540 <swtch>
    80001ffc:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001ffe:	2781                	sext.w	a5,a5
    80002000:	079e                	slli	a5,a5,0x7
    80002002:	993e                	add	s2,s2,a5
    80002004:	0b392623          	sw	s3,172(s2)
}
    80002008:	70a2                	ld	ra,40(sp)
    8000200a:	7402                	ld	s0,32(sp)
    8000200c:	64e2                	ld	s1,24(sp)
    8000200e:	6942                	ld	s2,16(sp)
    80002010:	69a2                	ld	s3,8(sp)
    80002012:	6145                	addi	sp,sp,48
    80002014:	8082                	ret
    panic("sched p->lock");
    80002016:	00005517          	auipc	a0,0x5
    8000201a:	18250513          	addi	a0,a0,386 # 80007198 <etext+0x198>
    8000201e:	817fe0ef          	jal	80000834 <panic>
    panic("sched locks");
    80002022:	00005517          	auipc	a0,0x5
    80002026:	18650513          	addi	a0,a0,390 # 800071a8 <etext+0x1a8>
    8000202a:	80bfe0ef          	jal	80000834 <panic>
    panic("sched RUNNING");
    8000202e:	00005517          	auipc	a0,0x5
    80002032:	18a50513          	addi	a0,a0,394 # 800071b8 <etext+0x1b8>
    80002036:	ffefe0ef          	jal	80000834 <panic>
    panic("sched interruptible");
    8000203a:	00005517          	auipc	a0,0x5
    8000203e:	18e50513          	addi	a0,a0,398 # 800071c8 <etext+0x1c8>
    80002042:	ff2fe0ef          	jal	80000834 <panic>

0000000080002046 <yield>:
{
    80002046:	1101                	addi	sp,sp,-32
    80002048:	ec06                	sd	ra,24(sp)
    8000204a:	e822                	sd	s0,16(sp)
    8000204c:	e426                	sd	s1,8(sp)
    8000204e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002050:	8f9ff0ef          	jal	80001948 <myproc>
    80002054:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002056:	bd3fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    8000205a:	478d                	li	a5,3
    8000205c:	cc9c                	sw	a5,24(s1)
  sched();
    8000205e:	f2dff0ef          	jal	80001f8a <sched>
  release(&p->lock);
    80002062:	8526                	mv	a0,s1
    80002064:	c4dfe0ef          	jal	80000cb0 <release>
}
    80002068:	60e2                	ld	ra,24(sp)
    8000206a:	6442                	ld	s0,16(sp)
    8000206c:	64a2                	ld	s1,8(sp)
    8000206e:	6105                	addi	sp,sp,32
    80002070:	8082                	ret

0000000080002072 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80002072:	1101                	addi	sp,sp,-32
    80002074:	ec06                	sd	ra,24(sp)
    80002076:	e822                	sd	s0,16(sp)
    80002078:	e426                	sd	s1,8(sp)
    8000207a:	e04a                	sd	s2,0(sp)
    8000207c:	1000                	addi	s0,sp,32
    8000207e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002080:	8c9ff0ef          	jal	80001948 <myproc>
    80002084:	892a                	mv	s2,a0

  acquire(&p->lock);
    80002086:	ba3fe0ef          	jal	80000c28 <acquire>
  if (chan == 0)
    8000208a:	cc81                	beqz	s1,800020a2 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    8000208c:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80002090:	854a                	mv	a0,s2
    80002092:	c1ffe0ef          	jal	80000cb0 <release>
}
    80002096:	60e2                	ld	ra,24(sp)
    80002098:	6442                	ld	s0,16(sp)
    8000209a:	64a2                	ld	s1,8(sp)
    8000209c:	6902                	ld	s2,0(sp)
    8000209e:	6105                	addi	sp,sp,32
    800020a0:	8082                	ret
    panic("sleep_prepare: zero chan");
    800020a2:	00005517          	auipc	a0,0x5
    800020a6:	13e50513          	addi	a0,a0,318 # 800071e0 <etext+0x1e0>
    800020aa:	f8afe0ef          	jal	80000834 <panic>

00000000800020ae <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    800020ae:	1101                	addi	sp,sp,-32
    800020b0:	ec06                	sd	ra,24(sp)
    800020b2:	e822                	sd	s0,16(sp)
    800020b4:	e426                	sd	s1,8(sp)
    800020b6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020b8:	891ff0ef          	jal	80001948 <myproc>
    800020bc:	84aa                	mv	s1,a0

  acquire(&p->lock);
    800020be:	b6bfe0ef          	jal	80000c28 <acquire>
  if (p->chan != 0) {
    800020c2:	709c                	ld	a5,32(s1)
    800020c4:	c789                	beqz	a5,800020ce <sleep+0x20>
    p->state = SLEEPING;
    800020c6:	4789                	li	a5,2
    800020c8:	cc9c                	sw	a5,24(s1)
    sched();
    800020ca:	ec1ff0ef          	jal	80001f8a <sched>
  }
  release(&p->lock);
    800020ce:	8526                	mv	a0,s1
    800020d0:	be1fe0ef          	jal	80000cb0 <release>
}
    800020d4:	60e2                	ld	ra,24(sp)
    800020d6:	6442                	ld	s0,16(sp)
    800020d8:	64a2                	ld	s1,8(sp)
    800020da:	6105                	addi	sp,sp,32
    800020dc:	8082                	ret

00000000800020de <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    800020de:	7139                	addi	sp,sp,-64
    800020e0:	fc06                	sd	ra,56(sp)
    800020e2:	f822                	sd	s0,48(sp)
    800020e4:	f426                	sd	s1,40(sp)
    800020e6:	f04a                	sd	s2,32(sp)
    800020e8:	ec4e                	sd	s3,24(sp)
    800020ea:	e852                	sd	s4,16(sp)
    800020ec:	e456                	sd	s5,8(sp)
    800020ee:	0080                	addi	s0,sp,64
    800020f0:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800020f2:	00010497          	auipc	s1,0x10
    800020f6:	7a648493          	addi	s1,s1,1958 # 80012898 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    800020fa:	4a09                	li	s4,2
        p->state = RUNNABLE;
    800020fc:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    800020fe:	00016997          	auipc	s3,0x16
    80002102:	39a98993          	addi	s3,s3,922 # 80018498 <tickslock>
    80002106:	a801                	j	80002116 <wakeup+0x38>
      }
    }
    release(&p->lock);
    80002108:	8526                	mv	a0,s1
    8000210a:	ba7fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000210e:	17048493          	addi	s1,s1,368
    80002112:	03348063          	beq	s1,s3,80002132 <wakeup+0x54>
    acquire(&p->lock);
    80002116:	8526                	mv	a0,s1
    80002118:	b11fe0ef          	jal	80000c28 <acquire>
    if (p->chan == chan) {
    8000211c:	709c                	ld	a5,32(s1)
    8000211e:	ff2795e3          	bne	a5,s2,80002108 <wakeup+0x2a>
      p->chan = 0;
    80002122:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    80002126:	4c9c                	lw	a5,24(s1)
    80002128:	ff4790e3          	bne	a5,s4,80002108 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000212c:	0154ac23          	sw	s5,24(s1)
    80002130:	bfe1                	j	80002108 <wakeup+0x2a>
  }
}
    80002132:	70e2                	ld	ra,56(sp)
    80002134:	7442                	ld	s0,48(sp)
    80002136:	74a2                	ld	s1,40(sp)
    80002138:	7902                	ld	s2,32(sp)
    8000213a:	69e2                	ld	s3,24(sp)
    8000213c:	6a42                	ld	s4,16(sp)
    8000213e:	6aa2                	ld	s5,8(sp)
    80002140:	6121                	addi	sp,sp,64
    80002142:	8082                	ret

0000000080002144 <reparent>:
{
    80002144:	7179                	addi	sp,sp,-48
    80002146:	f406                	sd	ra,40(sp)
    80002148:	f022                	sd	s0,32(sp)
    8000214a:	ec26                	sd	s1,24(sp)
    8000214c:	e84a                	sd	s2,16(sp)
    8000214e:	e44e                	sd	s3,8(sp)
    80002150:	e052                	sd	s4,0(sp)
    80002152:	1800                	addi	s0,sp,48
    80002154:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002156:	00010497          	auipc	s1,0x10
    8000215a:	74248493          	addi	s1,s1,1858 # 80012898 <proc>
      pp->parent = initproc;
    8000215e:	00008a17          	auipc	s4,0x8
    80002162:	202a0a13          	addi	s4,s4,514 # 8000a360 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002166:	00016997          	auipc	s3,0x16
    8000216a:	33298993          	addi	s3,s3,818 # 80018498 <tickslock>
    8000216e:	a029                	j	80002178 <reparent+0x34>
    80002170:	17048493          	addi	s1,s1,368
    80002174:	01348b63          	beq	s1,s3,8000218a <reparent+0x46>
    if (pp->parent == p) {
    80002178:	7c9c                	ld	a5,56(s1)
    8000217a:	ff279be3          	bne	a5,s2,80002170 <reparent+0x2c>
      pp->parent = initproc;
    8000217e:	000a3503          	ld	a0,0(s4)
    80002182:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002184:	f5bff0ef          	jal	800020de <wakeup>
    80002188:	b7e5                	j	80002170 <reparent+0x2c>
}
    8000218a:	70a2                	ld	ra,40(sp)
    8000218c:	7402                	ld	s0,32(sp)
    8000218e:	64e2                	ld	s1,24(sp)
    80002190:	6942                	ld	s2,16(sp)
    80002192:	69a2                	ld	s3,8(sp)
    80002194:	6a02                	ld	s4,0(sp)
    80002196:	6145                	addi	sp,sp,48
    80002198:	8082                	ret

000000008000219a <kexit>:
{
    8000219a:	7179                	addi	sp,sp,-48
    8000219c:	f406                	sd	ra,40(sp)
    8000219e:	f022                	sd	s0,32(sp)
    800021a0:	ec26                	sd	s1,24(sp)
    800021a2:	e84a                	sd	s2,16(sp)
    800021a4:	e44e                	sd	s3,8(sp)
    800021a6:	e052                	sd	s4,0(sp)
    800021a8:	1800                	addi	s0,sp,48
    800021aa:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021ac:	f9cff0ef          	jal	80001948 <myproc>
    800021b0:	89aa                	mv	s3,a0
  if (p == initproc)
    800021b2:	00008797          	auipc	a5,0x8
    800021b6:	1ae7b783          	ld	a5,430(a5) # 8000a360 <initproc>
    800021ba:	0d050493          	addi	s1,a0,208
    800021be:	15050913          	addi	s2,a0,336
    800021c2:	00a79b63          	bne	a5,a0,800021d8 <kexit+0x3e>
    panic("init exiting");
    800021c6:	00005517          	auipc	a0,0x5
    800021ca:	03a50513          	addi	a0,a0,58 # 80007200 <etext+0x200>
    800021ce:	e66fe0ef          	jal	80000834 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    800021d2:	04a1                	addi	s1,s1,8
    800021d4:	01248963          	beq	s1,s2,800021e6 <kexit+0x4c>
    if (p->ofile[fd]) {
    800021d8:	6088                	ld	a0,0(s1)
    800021da:	dd65                	beqz	a0,800021d2 <kexit+0x38>
      fileclose(f);
    800021dc:	0e2020ef          	jal	800042be <fileclose>
      p->ofile[fd] = 0;
    800021e0:	0004b023          	sd	zero,0(s1)
    800021e4:	b7fd                	j	800021d2 <kexit+0x38>
  begin_op();
    800021e6:	41f010ef          	jal	80003e04 <begin_op>
  iput(p->cwd);
    800021ea:	1509b503          	ld	a0,336(s3)
    800021ee:	320010ef          	jal	8000350e <iput>
  end_op();
    800021f2:	49f010ef          	jal	80003e90 <end_op>
  p->cwd = 0;
    800021f6:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800021fa:	00010517          	auipc	a0,0x10
    800021fe:	28650513          	addi	a0,a0,646 # 80012480 <wait_lock>
    80002202:	a27fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    80002206:	854e                	mv	a0,s3
    80002208:	f3dff0ef          	jal	80002144 <reparent>
  wakeup(p->parent);
    8000220c:	0389b503          	ld	a0,56(s3)
    80002210:	ecfff0ef          	jal	800020de <wakeup>
  acquire(&p->lock);
    80002214:	854e                	mv	a0,s3
    80002216:	a13fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    8000221a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000221e:	4795                	li	a5,5
    80002220:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002224:	00010517          	auipc	a0,0x10
    80002228:	25c50513          	addi	a0,a0,604 # 80012480 <wait_lock>
    8000222c:	a85fe0ef          	jal	80000cb0 <release>
  sched();
    80002230:	d5bff0ef          	jal	80001f8a <sched>
  panic("zombie exit");
    80002234:	00005517          	auipc	a0,0x5
    80002238:	fdc50513          	addi	a0,a0,-36 # 80007210 <etext+0x210>
    8000223c:	df8fe0ef          	jal	80000834 <panic>

0000000080002240 <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    80002240:	c525                	beqz	a0,800022a8 <kkill+0x68>
{
    80002242:	7179                	addi	sp,sp,-48
    80002244:	f406                	sd	ra,40(sp)
    80002246:	f022                	sd	s0,32(sp)
    80002248:	ec26                	sd	s1,24(sp)
    8000224a:	e84a                	sd	s2,16(sp)
    8000224c:	e44e                	sd	s3,8(sp)
    8000224e:	1800                	addi	s0,sp,48
    80002250:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002252:	00010497          	auipc	s1,0x10
    80002256:	64648493          	addi	s1,s1,1606 # 80012898 <proc>
    8000225a:	00016997          	auipc	s3,0x16
    8000225e:	23e98993          	addi	s3,s3,574 # 80018498 <tickslock>
    acquire(&p->lock);
    80002262:	8526                	mv	a0,s1
    80002264:	9c5fe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid) {
    80002268:	589c                	lw	a5,48(s1)
    8000226a:	01278b63          	beq	a5,s2,80002280 <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000226e:	8526                	mv	a0,s1
    80002270:	a41fe0ef          	jal	80000cb0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002274:	17048493          	addi	s1,s1,368
    80002278:	ff3495e3          	bne	s1,s3,80002262 <kkill+0x22>
  }
  return -1;
    8000227c:	557d                	li	a0,-1
    8000227e:	a819                	j	80002294 <kkill+0x54>
      p->killed = 1;
    80002280:	4785                	li	a5,1
    80002282:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    80002284:	4c98                	lw	a4,24(s1)
    80002286:	4789                	li	a5,2
    80002288:	00f70d63          	beq	a4,a5,800022a2 <kkill+0x62>
      release(&p->lock);
    8000228c:	8526                	mv	a0,s1
    8000228e:	a23fe0ef          	jal	80000cb0 <release>
      return 0;
    80002292:	4501                	li	a0,0
}
    80002294:	70a2                	ld	ra,40(sp)
    80002296:	7402                	ld	s0,32(sp)
    80002298:	64e2                	ld	s1,24(sp)
    8000229a:	6942                	ld	s2,16(sp)
    8000229c:	69a2                	ld	s3,8(sp)
    8000229e:	6145                	addi	sp,sp,48
    800022a0:	8082                	ret
        p->state = RUNNABLE;
    800022a2:	478d                	li	a5,3
    800022a4:	cc9c                	sw	a5,24(s1)
    800022a6:	b7dd                	j	8000228c <kkill+0x4c>
    return -1;
    800022a8:	557d                	li	a0,-1
}
    800022aa:	8082                	ret

00000000800022ac <setkilled>:

void
setkilled(struct proc *p)
{
    800022ac:	1101                	addi	sp,sp,-32
    800022ae:	ec06                	sd	ra,24(sp)
    800022b0:	e822                	sd	s0,16(sp)
    800022b2:	e426                	sd	s1,8(sp)
    800022b4:	1000                	addi	s0,sp,32
    800022b6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022b8:	971fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    800022bc:	4785                	li	a5,1
    800022be:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022c0:	8526                	mv	a0,s1
    800022c2:	9effe0ef          	jal	80000cb0 <release>
}
    800022c6:	60e2                	ld	ra,24(sp)
    800022c8:	6442                	ld	s0,16(sp)
    800022ca:	64a2                	ld	s1,8(sp)
    800022cc:	6105                	addi	sp,sp,32
    800022ce:	8082                	ret

00000000800022d0 <killed>:

int
killed(struct proc *p)
{
    800022d0:	1101                	addi	sp,sp,-32
    800022d2:	ec06                	sd	ra,24(sp)
    800022d4:	e822                	sd	s0,16(sp)
    800022d6:	e426                	sd	s1,8(sp)
    800022d8:	e04a                	sd	s2,0(sp)
    800022da:	1000                	addi	s0,sp,32
    800022dc:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800022de:	94bfe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    800022e2:	549c                	lw	a5,40(s1)
    800022e4:	893e                	mv	s2,a5
  release(&p->lock);
    800022e6:	8526                	mv	a0,s1
    800022e8:	9c9fe0ef          	jal	80000cb0 <release>
  return k;
}
    800022ec:	854a                	mv	a0,s2
    800022ee:	60e2                	ld	ra,24(sp)
    800022f0:	6442                	ld	s0,16(sp)
    800022f2:	64a2                	ld	s1,8(sp)
    800022f4:	6902                	ld	s2,0(sp)
    800022f6:	6105                	addi	sp,sp,32
    800022f8:	8082                	ret

00000000800022fa <kwait>:
{
    800022fa:	715d                	addi	sp,sp,-80
    800022fc:	e486                	sd	ra,72(sp)
    800022fe:	e0a2                	sd	s0,64(sp)
    80002300:	fc26                	sd	s1,56(sp)
    80002302:	f84a                	sd	s2,48(sp)
    80002304:	f44e                	sd	s3,40(sp)
    80002306:	f052                	sd	s4,32(sp)
    80002308:	ec56                	sd	s5,24(sp)
    8000230a:	e85a                	sd	s6,16(sp)
    8000230c:	e45e                	sd	s7,8(sp)
    8000230e:	0880                	addi	s0,sp,80
    80002310:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002312:	e36ff0ef          	jal	80001948 <myproc>
    80002316:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002318:	00010517          	auipc	a0,0x10
    8000231c:	16850513          	addi	a0,a0,360 # 80012480 <wait_lock>
    80002320:	909fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    80002324:	4a15                	li	s4,5
        havekids = 1;
    80002326:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002328:	00016997          	auipc	s3,0x16
    8000232c:	17098993          	addi	s3,s3,368 # 80018498 <tickslock>
    release(&wait_lock);
    80002330:	00010b17          	auipc	s6,0x10
    80002334:	150b0b13          	addi	s6,s6,336 # 80012480 <wait_lock>
    80002338:	a845                	j	800023e8 <kwait+0xee>
          pid = pp->pid;
    8000233a:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    8000233e:	000b8e63          	beqz	s7,8000235a <kwait+0x60>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    80002342:	4711                	li	a4,4
    80002344:	02c48693          	addi	a3,s1,44
    80002348:	865e                	mv	a2,s7
    8000234a:	04893583          	ld	a1,72(s2)
    8000234e:	05093503          	ld	a0,80(s2)
    80002352:	a30ff0ef          	jal	80001582 <copyout>
          if (addr != 0 &&
    80002356:	02054c63          	bltz	a0,8000238e <kwait+0x94>
          pp->parent = 0;
    8000235a:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    8000235e:	8526                	mv	a0,s1
    80002360:	fb8ff0ef          	jal	80001b18 <freeproc>
          release(&pp->lock);
    80002364:	8526                	mv	a0,s1
    80002366:	94bfe0ef          	jal	80000cb0 <release>
          release(&wait_lock);
    8000236a:	00010517          	auipc	a0,0x10
    8000236e:	11650513          	addi	a0,a0,278 # 80012480 <wait_lock>
    80002372:	93ffe0ef          	jal	80000cb0 <release>
}
    80002376:	854e                	mv	a0,s3
    80002378:	60a6                	ld	ra,72(sp)
    8000237a:	6406                	ld	s0,64(sp)
    8000237c:	74e2                	ld	s1,56(sp)
    8000237e:	7942                	ld	s2,48(sp)
    80002380:	79a2                	ld	s3,40(sp)
    80002382:	7a02                	ld	s4,32(sp)
    80002384:	6ae2                	ld	s5,24(sp)
    80002386:	6b42                	ld	s6,16(sp)
    80002388:	6ba2                	ld	s7,8(sp)
    8000238a:	6161                	addi	sp,sp,80
    8000238c:	8082                	ret
            release(&pp->lock);
    8000238e:	8526                	mv	a0,s1
    80002390:	921fe0ef          	jal	80000cb0 <release>
            release(&wait_lock);
    80002394:	00010517          	auipc	a0,0x10
    80002398:	0ec50513          	addi	a0,a0,236 # 80012480 <wait_lock>
    8000239c:	915fe0ef          	jal	80000cb0 <release>
            return -1;
    800023a0:	59fd                	li	s3,-1
    800023a2:	bfd1                	j	80002376 <kwait+0x7c>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800023a4:	17048493          	addi	s1,s1,368
    800023a8:	03348063          	beq	s1,s3,800023c8 <kwait+0xce>
      if (pp->parent == p) {
    800023ac:	7c9c                	ld	a5,56(s1)
    800023ae:	ff279be3          	bne	a5,s2,800023a4 <kwait+0xaa>
        acquire(&pp->lock);
    800023b2:	8526                	mv	a0,s1
    800023b4:	875fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    800023b8:	4c9c                	lw	a5,24(s1)
    800023ba:	f94780e3          	beq	a5,s4,8000233a <kwait+0x40>
        release(&pp->lock);
    800023be:	8526                	mv	a0,s1
    800023c0:	8f1fe0ef          	jal	80000cb0 <release>
        havekids = 1;
    800023c4:	8756                	mv	a4,s5
    800023c6:	bff9                	j	800023a4 <kwait+0xaa>
    if (!havekids || killed(p)) {
    800023c8:	c715                	beqz	a4,800023f4 <kwait+0xfa>
    800023ca:	854a                	mv	a0,s2
    800023cc:	f05ff0ef          	jal	800022d0 <killed>
    800023d0:	e115                	bnez	a0,800023f4 <kwait+0xfa>
    sleep_prepare(p); //DOC: wait-sleep
    800023d2:	854a                	mv	a0,s2
    800023d4:	c9fff0ef          	jal	80002072 <sleep_prepare>
    release(&wait_lock);
    800023d8:	855a                	mv	a0,s6
    800023da:	8d7fe0ef          	jal	80000cb0 <release>
    sleep();
    800023de:	cd1ff0ef          	jal	800020ae <sleep>
    acquire(&wait_lock);
    800023e2:	855a                	mv	a0,s6
    800023e4:	845fe0ef          	jal	80000c28 <acquire>
    havekids = 0;
    800023e8:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800023ea:	00010497          	auipc	s1,0x10
    800023ee:	4ae48493          	addi	s1,s1,1198 # 80012898 <proc>
    800023f2:	bf6d                	j	800023ac <kwait+0xb2>
      release(&wait_lock);
    800023f4:	00010517          	auipc	a0,0x10
    800023f8:	08c50513          	addi	a0,a0,140 # 80012480 <wait_lock>
    800023fc:	8b5fe0ef          	jal	80000cb0 <release>
      return -1;
    80002400:	59fd                	li	s3,-1
    80002402:	bf95                	j	80002376 <kwait+0x7c>

0000000080002404 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002404:	7179                	addi	sp,sp,-48
    80002406:	f406                	sd	ra,40(sp)
    80002408:	f022                	sd	s0,32(sp)
    8000240a:	ec26                	sd	s1,24(sp)
    8000240c:	e84a                	sd	s2,16(sp)
    8000240e:	e44e                	sd	s3,8(sp)
    80002410:	e052                	sd	s4,0(sp)
    80002412:	1800                	addi	s0,sp,48
    80002414:	84aa                	mv	s1,a0
    80002416:	8a2e                	mv	s4,a1
    80002418:	89b2                	mv	s3,a2
    8000241a:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000241c:	d2cff0ef          	jal	80001948 <myproc>
  if (user_dst) {
    80002420:	c085                	beqz	s1,80002440 <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    80002422:	874a                	mv	a4,s2
    80002424:	86ce                	mv	a3,s3
    80002426:	8652                	mv	a2,s4
    80002428:	652c                	ld	a1,72(a0)
    8000242a:	6928                	ld	a0,80(a0)
    8000242c:	956ff0ef          	jal	80001582 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002430:	70a2                	ld	ra,40(sp)
    80002432:	7402                	ld	s0,32(sp)
    80002434:	64e2                	ld	s1,24(sp)
    80002436:	6942                	ld	s2,16(sp)
    80002438:	69a2                	ld	s3,8(sp)
    8000243a:	6a02                	ld	s4,0(sp)
    8000243c:	6145                	addi	sp,sp,48
    8000243e:	8082                	ret
    memmove((char *)dst, src, len);
    80002440:	0009061b          	sext.w	a2,s2
    80002444:	85ce                	mv	a1,s3
    80002446:	8552                	mv	a0,s4
    80002448:	901fe0ef          	jal	80000d48 <memmove>
    return 0;
    8000244c:	8526                	mv	a0,s1
    8000244e:	b7cd                	j	80002430 <either_copyout+0x2c>

0000000080002450 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002450:	7179                	addi	sp,sp,-48
    80002452:	f406                	sd	ra,40(sp)
    80002454:	f022                	sd	s0,32(sp)
    80002456:	ec26                	sd	s1,24(sp)
    80002458:	e84a                	sd	s2,16(sp)
    8000245a:	e44e                	sd	s3,8(sp)
    8000245c:	e052                	sd	s4,0(sp)
    8000245e:	1800                	addi	s0,sp,48
    80002460:	8a2a                	mv	s4,a0
    80002462:	84ae                	mv	s1,a1
    80002464:	89b2                	mv	s3,a2
    80002466:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002468:	ce0ff0ef          	jal	80001948 <myproc>
  if (user_src) {
    8000246c:	c085                	beqz	s1,8000248c <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    8000246e:	874a                	mv	a4,s2
    80002470:	86ce                	mv	a3,s3
    80002472:	8652                	mv	a2,s4
    80002474:	652c                	ld	a1,72(a0)
    80002476:	6928                	ld	a0,80(a0)
    80002478:	9d0ff0ef          	jal	80001648 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000247c:	70a2                	ld	ra,40(sp)
    8000247e:	7402                	ld	s0,32(sp)
    80002480:	64e2                	ld	s1,24(sp)
    80002482:	6942                	ld	s2,16(sp)
    80002484:	69a2                	ld	s3,8(sp)
    80002486:	6a02                	ld	s4,0(sp)
    80002488:	6145                	addi	sp,sp,48
    8000248a:	8082                	ret
    memmove(dst, (char *)src, len);
    8000248c:	0009061b          	sext.w	a2,s2
    80002490:	85ce                	mv	a1,s3
    80002492:	8552                	mv	a0,s4
    80002494:	8b5fe0ef          	jal	80000d48 <memmove>
    return 0;
    80002498:	8526                	mv	a0,s1
    8000249a:	b7cd                	j	8000247c <either_copyin+0x2c>

000000008000249c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000249c:	715d                	addi	sp,sp,-80
    8000249e:	e486                	sd	ra,72(sp)
    800024a0:	e0a2                	sd	s0,64(sp)
    800024a2:	fc26                	sd	s1,56(sp)
    800024a4:	f84a                	sd	s2,48(sp)
    800024a6:	f44e                	sd	s3,40(sp)
    800024a8:	f052                	sd	s4,32(sp)
    800024aa:	ec56                	sd	s5,24(sp)
    800024ac:	e85a                	sd	s6,16(sp)
    800024ae:	e45e                	sd	s7,8(sp)
    800024b0:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    800024b2:	00005517          	auipc	a0,0x5
    800024b6:	bc650513          	addi	a0,a0,-1082 # 80007078 <etext+0x78>
    800024ba:	850fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800024be:	00010497          	auipc	s1,0x10
    800024c2:	53248493          	addi	s1,s1,1330 # 800129f0 <proc+0x158>
    800024c6:	00016917          	auipc	s2,0x16
    800024ca:	12a90913          	addi	s2,s2,298 # 800185f0 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024ce:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800024d0:	00005997          	auipc	s3,0x5
    800024d4:	d5098993          	addi	s3,s3,-688 # 80007220 <etext+0x220>
    printk("%d %s %s", p->pid, state, p->name);
    800024d8:	00005a97          	auipc	s5,0x5
    800024dc:	d50a8a93          	addi	s5,s5,-688 # 80007228 <etext+0x228>
    printk("\n");
    800024e0:	00005a17          	auipc	s4,0x5
    800024e4:	b98a0a13          	addi	s4,s4,-1128 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024e8:	00005b97          	auipc	s7,0x5
    800024ec:	260b8b93          	addi	s7,s7,608 # 80007748 <states.0>
    800024f0:	a829                	j	8000250a <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    800024f2:	ed86a583          	lw	a1,-296(a3)
    800024f6:	8556                	mv	a0,s5
    800024f8:	812fe0ef          	jal	8000050a <printk>
    printk("\n");
    800024fc:	8552                	mv	a0,s4
    800024fe:	80cfe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002502:	17048493          	addi	s1,s1,368
    80002506:	03248263          	beq	s1,s2,8000252a <procdump+0x8e>
    if (p->state == UNUSED)
    8000250a:	86a6                	mv	a3,s1
    8000250c:	ec04a783          	lw	a5,-320(s1)
    80002510:	dbed                	beqz	a5,80002502 <procdump+0x66>
      state = "???";
    80002512:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002514:	fcfb6fe3          	bltu	s6,a5,800024f2 <procdump+0x56>
    80002518:	02079713          	slli	a4,a5,0x20
    8000251c:	01d75793          	srli	a5,a4,0x1d
    80002520:	97de                	add	a5,a5,s7
    80002522:	6390                	ld	a2,0(a5)
    80002524:	f679                	bnez	a2,800024f2 <procdump+0x56>
      state = "???";
    80002526:	864e                	mv	a2,s3
    80002528:	b7e9                	j	800024f2 <procdump+0x56>
  }
}
    8000252a:	60a6                	ld	ra,72(sp)
    8000252c:	6406                	ld	s0,64(sp)
    8000252e:	74e2                	ld	s1,56(sp)
    80002530:	7942                	ld	s2,48(sp)
    80002532:	79a2                	ld	s3,40(sp)
    80002534:	7a02                	ld	s4,32(sp)
    80002536:	6ae2                	ld	s5,24(sp)
    80002538:	6b42                	ld	s6,16(sp)
    8000253a:	6ba2                	ld	s7,8(sp)
    8000253c:	6161                	addi	sp,sp,80
    8000253e:	8082                	ret

0000000080002540 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002540:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002544:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002548:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000254a:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000254c:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002550:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002554:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002558:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    8000255c:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002560:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002564:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002568:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    8000256c:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002570:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002574:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002578:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000257c:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000257e:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002580:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002584:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002588:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000258c:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002590:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002594:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002598:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000259c:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800025a0:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800025a4:	0685bd83          	ld	s11,104(a1)
        
        ret
    800025a8:	8082                	ret

00000000800025aa <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800025aa:	1141                	addi	sp,sp,-16
    800025ac:	e406                	sd	ra,8(sp)
    800025ae:	e022                	sd	s0,0(sp)
    800025b0:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800025b2:	00005597          	auipc	a1,0x5
    800025b6:	cb658593          	addi	a1,a1,-842 # 80007268 <etext+0x268>
    800025ba:	00016517          	auipc	a0,0x16
    800025be:	ede50513          	addi	a0,a0,-290 # 80018498 <tickslock>
    800025c2:	de6fe0ef          	jal	80000ba8 <initlock>
}
    800025c6:	60a2                	ld	ra,8(sp)
    800025c8:	6402                	ld	s0,0(sp)
    800025ca:	0141                	addi	sp,sp,16
    800025cc:	8082                	ret

00000000800025ce <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800025ce:	1141                	addi	sp,sp,-16
    800025d0:	e406                	sd	ra,8(sp)
    800025d2:	e022                	sd	s0,0(sp)
    800025d4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    800025d6:	00003797          	auipc	a5,0x3
    800025da:	17a78793          	addi	a5,a5,378 # 80005750 <kernelvec>
    800025de:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800025e2:	60a2                	ld	ra,8(sp)
    800025e4:	6402                	ld	s0,0(sp)
    800025e6:	0141                	addi	sp,sp,16
    800025e8:	8082                	ret

00000000800025ea <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800025ea:	1141                	addi	sp,sp,-16
    800025ec:	e406                	sd	ra,8(sp)
    800025ee:	e022                	sd	s0,0(sp)
    800025f0:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800025f2:	b56ff0ef          	jal	80001948 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    800025f6:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800025fa:	04000737          	lui	a4,0x4000
    800025fe:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002600:	0732                	slli	a4,a4,0xc
    80002602:	00004797          	auipc	a5,0x4
    80002606:	9fe78793          	addi	a5,a5,-1538 # 80006000 <_trampoline>
    8000260a:	00004697          	auipc	a3,0x4
    8000260e:	9f668693          	addi	a3,a3,-1546 # 80006000 <_trampoline>
    80002612:	8f95                	sub	a5,a5,a3
    80002614:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002616:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000261a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    8000261c:	18002773          	csrr	a4,satp
    80002620:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002622:	6d38                	ld	a4,88(a0)
    80002624:	613c                	ld	a5,64(a0)
    80002626:	6685                	lui	a3,0x1
    80002628:	97b6                	add	a5,a5,a3
    8000262a:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000262c:	6d3c                	ld	a5,88(a0)
    8000262e:	00000717          	auipc	a4,0x0
    80002632:	0fc70713          	addi	a4,a4,252 # 8000272a <usertrap>
    80002636:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002638:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    8000263a:	8712                	mv	a4,tp
    8000263c:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000263e:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002642:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002646:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    8000264a:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000264e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002650:	6f9c                	ld	a5,24(a5)
    80002652:	14179073          	csrw	sepc,a5
}
    80002656:	60a2                	ld	ra,8(sp)
    80002658:	6402                	ld	s0,0(sp)
    8000265a:	0141                	addi	sp,sp,16
    8000265c:	8082                	ret

000000008000265e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000265e:	1141                	addi	sp,sp,-16
    80002660:	e406                	sd	ra,8(sp)
    80002662:	e022                	sd	s0,0(sp)
    80002664:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80002666:	aaeff0ef          	jal	80001914 <cpuid>
    8000266a:	cd11                	beqz	a0,80002686 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    8000266c:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002670:	000f4737          	lui	a4,0xf4
    80002674:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002678:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000267a:	14d79073          	csrw	stimecmp,a5
}
    8000267e:	60a2                	ld	ra,8(sp)
    80002680:	6402                	ld	s0,0(sp)
    80002682:	0141                	addi	sp,sp,16
    80002684:	8082                	ret
    acquire(&tickslock);
    80002686:	00016517          	auipc	a0,0x16
    8000268a:	e1250513          	addi	a0,a0,-494 # 80018498 <tickslock>
    8000268e:	d9afe0ef          	jal	80000c28 <acquire>
    ticks++;
    80002692:	00008717          	auipc	a4,0x8
    80002696:	cd670713          	addi	a4,a4,-810 # 8000a368 <ticks>
    8000269a:	431c                	lw	a5,0(a4)
    8000269c:	2785                	addiw	a5,a5,1
    8000269e:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    800026a0:	853a                	mv	a0,a4
    800026a2:	a3dff0ef          	jal	800020de <wakeup>
    release(&tickslock);
    800026a6:	00016517          	auipc	a0,0x16
    800026aa:	df250513          	addi	a0,a0,-526 # 80018498 <tickslock>
    800026ae:	e02fe0ef          	jal	80000cb0 <release>
    800026b2:	bf6d                	j	8000266c <clockintr+0xe>

00000000800026b4 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800026b4:	1101                	addi	sp,sp,-32
    800026b6:	ec06                	sd	ra,24(sp)
    800026b8:	e822                	sd	s0,16(sp)
    800026ba:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    800026bc:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    800026c0:	57fd                	li	a5,-1
    800026c2:	17fe                	slli	a5,a5,0x3f
    800026c4:	07a5                	addi	a5,a5,9
    800026c6:	00f70c63          	beq	a4,a5,800026de <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    800026ca:	57fd                	li	a5,-1
    800026cc:	17fe                	slli	a5,a5,0x3f
    800026ce:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800026d0:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    800026d2:	04f70863          	beq	a4,a5,80002722 <devintr+0x6e>
  }
}
    800026d6:	60e2                	ld	ra,24(sp)
    800026d8:	6442                	ld	s0,16(sp)
    800026da:	6105                	addi	sp,sp,32
    800026dc:	8082                	ret
    800026de:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800026e0:	11e030ef          	jal	800057fe <plic_claim>
    800026e4:	872a                	mv	a4,a0
    800026e6:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    800026e8:	47a9                	li	a5,10
    800026ea:	00f50963          	beq	a0,a5,800026fc <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    800026ee:	4785                	li	a5,1
    800026f0:	00f50963          	beq	a0,a5,80002702 <devintr+0x4e>
    return 1;
    800026f4:	4505                	li	a0,1
    } else if (irq) {
    800026f6:	eb09                	bnez	a4,80002708 <devintr+0x54>
    800026f8:	64a2                	ld	s1,8(sp)
    800026fa:	bff1                	j	800026d6 <devintr+0x22>
      uartintr();
    800026fc:	af2fe0ef          	jal	800009ee <uartintr>
    if (irq)
    80002700:	a819                	j	80002716 <devintr+0x62>
      virtio_disk_intr();
    80002702:	5b8030ef          	jal	80005cba <virtio_disk_intr>
    if (irq)
    80002706:	a801                	j	80002716 <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    80002708:	85ba                	mv	a1,a4
    8000270a:	00005517          	auipc	a0,0x5
    8000270e:	b6650513          	addi	a0,a0,-1178 # 80007270 <etext+0x270>
    80002712:	df9fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    80002716:	8526                	mv	a0,s1
    80002718:	108030ef          	jal	80005820 <plic_complete>
    return 1;
    8000271c:	4505                	li	a0,1
    8000271e:	64a2                	ld	s1,8(sp)
    80002720:	bf5d                	j	800026d6 <devintr+0x22>
    clockintr();
    80002722:	f3dff0ef          	jal	8000265e <clockintr>
    return 2;
    80002726:	4509                	li	a0,2
    80002728:	b77d                	j	800026d6 <devintr+0x22>

000000008000272a <usertrap>:
{
    8000272a:	1101                	addi	sp,sp,-32
    8000272c:	ec06                	sd	ra,24(sp)
    8000272e:	e822                	sd	s0,16(sp)
    80002730:	e426                	sd	s1,8(sp)
    80002732:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002734:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002738:	1007f793          	andi	a5,a5,256
    8000273c:	e7bd                	bnez	a5,800027aa <usertrap+0x80>
  asm volatile("csrw stvec, %0" : : "r"(x));
    8000273e:	00003797          	auipc	a5,0x3
    80002742:	01278793          	addi	a5,a5,18 # 80005750 <kernelvec>
    80002746:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000274a:	9feff0ef          	jal	80001948 <myproc>
    8000274e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002750:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002752:	14102773          	csrr	a4,sepc
    80002756:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    80002758:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    8000275c:	47a1                	li	a5,8
    8000275e:	04f70c63          	beq	a4,a5,800027b6 <usertrap+0x8c>
  } else if ((which_dev = devintr()) != 0) {
    80002762:	f53ff0ef          	jal	800026b4 <devintr>
    80002766:	e13d                	bnez	a0,800027cc <usertrap+0xa2>
    80002768:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    8000276c:	47bd                	li	a5,15
    8000276e:	08f70363          	beq	a4,a5,800027f4 <usertrap+0xca>
    80002772:	14202773          	csrr	a4,scause
    80002776:	47b5                	li	a5,13
    80002778:	06f70e63          	beq	a4,a5,800027f4 <usertrap+0xca>
    8000277c:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002780:	5890                	lw	a2,48(s1)
    80002782:	00005517          	auipc	a0,0x5
    80002786:	b2e50513          	addi	a0,a0,-1234 # 800072b0 <etext+0x2b0>
    8000278a:	d81fd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    8000278e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002792:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002796:	00005517          	auipc	a0,0x5
    8000279a:	b4a50513          	addi	a0,a0,-1206 # 800072e0 <etext+0x2e0>
    8000279e:	d6dfd0ef          	jal	8000050a <printk>
    setkilled(p);
    800027a2:	8526                	mv	a0,s1
    800027a4:	b09ff0ef          	jal	800022ac <setkilled>
    800027a8:	a015                	j	800027cc <usertrap+0xa2>
    panic("usertrap: not from user mode");
    800027aa:	00005517          	auipc	a0,0x5
    800027ae:	ae650513          	addi	a0,a0,-1306 # 80007290 <etext+0x290>
    800027b2:	882fe0ef          	jal	80000834 <panic>
    if (killed(p))
    800027b6:	b1bff0ef          	jal	800022d0 <killed>
    800027ba:	e90d                	bnez	a0,800027ec <usertrap+0xc2>
    p->trapframe->epc += 4;
    800027bc:	6cb8                	ld	a4,88(s1)
    800027be:	6f1c                	ld	a5,24(a4)
    800027c0:	0791                	addi	a5,a5,4
    800027c2:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    800027c4:	10016073          	csrsi	sstatus,2
    syscall();
    800027c8:	21a000ef          	jal	800029e2 <syscall>
  if (killed(p))
    800027cc:	8526                	mv	a0,s1
    800027ce:	b03ff0ef          	jal	800022d0 <killed>
    800027d2:	ed15                	bnez	a0,8000280e <usertrap+0xe4>
  prepare_return();
    800027d4:	e17ff0ef          	jal	800025ea <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800027d8:	68a8                	ld	a0,80(s1)
    800027da:	8131                	srli	a0,a0,0xc
}
    800027dc:	57fd                	li	a5,-1
    800027de:	17fe                	slli	a5,a5,0x3f
    800027e0:	8d5d                	or	a0,a0,a5
    800027e2:	60e2                	ld	ra,24(sp)
    800027e4:	6442                	ld	s0,16(sp)
    800027e6:	64a2                	ld	s1,8(sp)
    800027e8:	6105                	addi	sp,sp,32
    800027ea:	8082                	ret
      kexit(-1);
    800027ec:	557d                	li	a0,-1
    800027ee:	9adff0ef          	jal	8000219a <kexit>
    800027f2:	b7e9                	j	800027bc <usertrap+0x92>
  asm volatile("csrr %0, stval" : "=r"(x));
    800027f4:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    800027f8:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    800027fc:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    800027fe:	0016b693          	seqz	a3,a3
    80002802:	64ac                	ld	a1,72(s1)
    80002804:	68a8                	ld	a0,80(s1)
    80002806:	d01fe0ef          	jal	80001506 <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    8000280a:	f169                	bnez	a0,800027cc <usertrap+0xa2>
    8000280c:	bf85                	j	8000277c <usertrap+0x52>
    kexit(-1);
    8000280e:	557d                	li	a0,-1
    80002810:	98bff0ef          	jal	8000219a <kexit>
    80002814:	b7c1                	j	800027d4 <usertrap+0xaa>

0000000080002816 <kerneltrap>:
{
    80002816:	7179                	addi	sp,sp,-48
    80002818:	f406                	sd	ra,40(sp)
    8000281a:	f022                	sd	s0,32(sp)
    8000281c:	ec26                	sd	s1,24(sp)
    8000281e:	e84a                	sd	s2,16(sp)
    80002820:	e44e                	sd	s3,8(sp)
    80002822:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002824:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002828:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    8000282c:	142027f3          	csrr	a5,scause
    80002830:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    80002832:	1004f793          	andi	a5,s1,256
    80002836:	c39d                	beqz	a5,8000285c <kerneltrap+0x46>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002838:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000283c:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    8000283e:	e78d                	bnez	a5,80002868 <kerneltrap+0x52>
  if ((which_dev = devintr()) == 0) {
    80002840:	e75ff0ef          	jal	800026b4 <devintr>
    80002844:	c905                	beqz	a0,80002874 <kerneltrap+0x5e>
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002846:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    8000284a:	10049073          	csrw	sstatus,s1
}
    8000284e:	70a2                	ld	ra,40(sp)
    80002850:	7402                	ld	s0,32(sp)
    80002852:	64e2                	ld	s1,24(sp)
    80002854:	6942                	ld	s2,16(sp)
    80002856:	69a2                	ld	s3,8(sp)
    80002858:	6145                	addi	sp,sp,48
    8000285a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000285c:	00005517          	auipc	a0,0x5
    80002860:	aac50513          	addi	a0,a0,-1364 # 80007308 <etext+0x308>
    80002864:	fd1fd0ef          	jal	80000834 <panic>
    panic("kerneltrap: interrupts enabled");
    80002868:	00005517          	auipc	a0,0x5
    8000286c:	ac850513          	addi	a0,a0,-1336 # 80007330 <etext+0x330>
    80002870:	fc5fd0ef          	jal	80000834 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002874:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002878:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    8000287c:	85ce                	mv	a1,s3
    8000287e:	00005517          	auipc	a0,0x5
    80002882:	ad250513          	addi	a0,a0,-1326 # 80007350 <etext+0x350>
    80002886:	c85fd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    8000288a:	00005517          	auipc	a0,0x5
    8000288e:	aee50513          	addi	a0,a0,-1298 # 80007378 <etext+0x378>
    80002892:	fa3fd0ef          	jal	80000834 <panic>

0000000080002896 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002896:	1101                	addi	sp,sp,-32
    80002898:	ec06                	sd	ra,24(sp)
    8000289a:	e822                	sd	s0,16(sp)
    8000289c:	e426                	sd	s1,8(sp)
    8000289e:	1000                	addi	s0,sp,32
    800028a0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800028a2:	8a6ff0ef          	jal	80001948 <myproc>
  switch (n) {
    800028a6:	4795                	li	a5,5
    800028a8:	0497e163          	bltu	a5,s1,800028ea <argraw+0x54>
    800028ac:	048a                	slli	s1,s1,0x2
    800028ae:	00005717          	auipc	a4,0x5
    800028b2:	eca70713          	addi	a4,a4,-310 # 80007778 <states.0+0x30>
    800028b6:	94ba                	add	s1,s1,a4
    800028b8:	409c                	lw	a5,0(s1)
    800028ba:	97ba                	add	a5,a5,a4
    800028bc:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800028be:	6d3c                	ld	a5,88(a0)
    800028c0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800028c2:	60e2                	ld	ra,24(sp)
    800028c4:	6442                	ld	s0,16(sp)
    800028c6:	64a2                	ld	s1,8(sp)
    800028c8:	6105                	addi	sp,sp,32
    800028ca:	8082                	ret
    return p->trapframe->a1;
    800028cc:	6d3c                	ld	a5,88(a0)
    800028ce:	7fa8                	ld	a0,120(a5)
    800028d0:	bfcd                	j	800028c2 <argraw+0x2c>
    return p->trapframe->a2;
    800028d2:	6d3c                	ld	a5,88(a0)
    800028d4:	63c8                	ld	a0,128(a5)
    800028d6:	b7f5                	j	800028c2 <argraw+0x2c>
    return p->trapframe->a3;
    800028d8:	6d3c                	ld	a5,88(a0)
    800028da:	67c8                	ld	a0,136(a5)
    800028dc:	b7dd                	j	800028c2 <argraw+0x2c>
    return p->trapframe->a4;
    800028de:	6d3c                	ld	a5,88(a0)
    800028e0:	6bc8                	ld	a0,144(a5)
    800028e2:	b7c5                	j	800028c2 <argraw+0x2c>
    return p->trapframe->a5;
    800028e4:	6d3c                	ld	a5,88(a0)
    800028e6:	6fc8                	ld	a0,152(a5)
    800028e8:	bfe9                	j	800028c2 <argraw+0x2c>
  panic("argraw");
    800028ea:	00005517          	auipc	a0,0x5
    800028ee:	a9e50513          	addi	a0,a0,-1378 # 80007388 <etext+0x388>
    800028f2:	f43fd0ef          	jal	80000834 <panic>

00000000800028f6 <fetchaddr>:
{
    800028f6:	1101                	addi	sp,sp,-32
    800028f8:	ec06                	sd	ra,24(sp)
    800028fa:	e822                	sd	s0,16(sp)
    800028fc:	e426                	sd	s1,8(sp)
    800028fe:	e04a                	sd	s2,0(sp)
    80002900:	1000                	addi	s0,sp,32
    80002902:	84aa                	mv	s1,a0
    80002904:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002906:	842ff0ef          	jal	80001948 <myproc>
  if (addr >= p->sz ||
    8000290a:	652c                	ld	a1,72(a0)
    8000290c:	02b4f663          	bgeu	s1,a1,80002938 <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002910:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    80002914:	02f5e463          	bltu	a1,a5,8000293c <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    80002918:	4721                	li	a4,8
    8000291a:	86a6                	mv	a3,s1
    8000291c:	864a                	mv	a2,s2
    8000291e:	6928                	ld	a0,80(a0)
    80002920:	d29fe0ef          	jal	80001648 <copyin>
    80002924:	00a03533          	snez	a0,a0
    80002928:	40a0053b          	negw	a0,a0
}
    8000292c:	60e2                	ld	ra,24(sp)
    8000292e:	6442                	ld	s0,16(sp)
    80002930:	64a2                	ld	s1,8(sp)
    80002932:	6902                	ld	s2,0(sp)
    80002934:	6105                	addi	sp,sp,32
    80002936:	8082                	ret
    return -1;
    80002938:	557d                	li	a0,-1
    8000293a:	bfcd                	j	8000292c <fetchaddr+0x36>
    8000293c:	557d                	li	a0,-1
    8000293e:	b7fd                	j	8000292c <fetchaddr+0x36>

0000000080002940 <fetchstr>:
{
    80002940:	7179                	addi	sp,sp,-48
    80002942:	f406                	sd	ra,40(sp)
    80002944:	f022                	sd	s0,32(sp)
    80002946:	ec26                	sd	s1,24(sp)
    80002948:	e84a                	sd	s2,16(sp)
    8000294a:	e44e                	sd	s3,8(sp)
    8000294c:	1800                	addi	s0,sp,48
    8000294e:	89aa                	mv	s3,a0
    80002950:	84ae                	mv	s1,a1
    80002952:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002954:	ff5fe0ef          	jal	80001948 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    80002958:	874a                	mv	a4,s2
    8000295a:	86ce                	mv	a3,s3
    8000295c:	8626                	mv	a2,s1
    8000295e:	652c                	ld	a1,72(a0)
    80002960:	6928                	ld	a0,80(a0)
    80002962:	d83fe0ef          	jal	800016e4 <copyinstr>
    80002966:	00054c63          	bltz	a0,8000297e <fetchstr+0x3e>
  return strlen(buf);
    8000296a:	8526                	mv	a0,s1
    8000296c:	d06fe0ef          	jal	80000e72 <strlen>
}
    80002970:	70a2                	ld	ra,40(sp)
    80002972:	7402                	ld	s0,32(sp)
    80002974:	64e2                	ld	s1,24(sp)
    80002976:	6942                	ld	s2,16(sp)
    80002978:	69a2                	ld	s3,8(sp)
    8000297a:	6145                	addi	sp,sp,48
    8000297c:	8082                	ret
    return -1;
    8000297e:	557d                	li	a0,-1
    80002980:	bfc5                	j	80002970 <fetchstr+0x30>

0000000080002982 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002982:	1101                	addi	sp,sp,-32
    80002984:	ec06                	sd	ra,24(sp)
    80002986:	e822                	sd	s0,16(sp)
    80002988:	e426                	sd	s1,8(sp)
    8000298a:	1000                	addi	s0,sp,32
    8000298c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000298e:	f09ff0ef          	jal	80002896 <argraw>
    80002992:	c088                	sw	a0,0(s1)
}
    80002994:	60e2                	ld	ra,24(sp)
    80002996:	6442                	ld	s0,16(sp)
    80002998:	64a2                	ld	s1,8(sp)
    8000299a:	6105                	addi	sp,sp,32
    8000299c:	8082                	ret

000000008000299e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000299e:	1101                	addi	sp,sp,-32
    800029a0:	ec06                	sd	ra,24(sp)
    800029a2:	e822                	sd	s0,16(sp)
    800029a4:	e426                	sd	s1,8(sp)
    800029a6:	1000                	addi	s0,sp,32
    800029a8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800029aa:	eedff0ef          	jal	80002896 <argraw>
    800029ae:	e088                	sd	a0,0(s1)
}
    800029b0:	60e2                	ld	ra,24(sp)
    800029b2:	6442                	ld	s0,16(sp)
    800029b4:	64a2                	ld	s1,8(sp)
    800029b6:	6105                	addi	sp,sp,32
    800029b8:	8082                	ret

00000000800029ba <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800029ba:	1101                	addi	sp,sp,-32
    800029bc:	ec06                	sd	ra,24(sp)
    800029be:	e822                	sd	s0,16(sp)
    800029c0:	e426                	sd	s1,8(sp)
    800029c2:	e04a                	sd	s2,0(sp)
    800029c4:	1000                	addi	s0,sp,32
    800029c6:	892e                	mv	s2,a1
    800029c8:	84b2                	mv	s1,a2
  *ip = argraw(n);
    800029ca:	ecdff0ef          	jal	80002896 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    800029ce:	8626                	mv	a2,s1
    800029d0:	85ca                	mv	a1,s2
    800029d2:	f6fff0ef          	jal	80002940 <fetchstr>
}
    800029d6:	60e2                	ld	ra,24(sp)
    800029d8:	6442                	ld	s0,16(sp)
    800029da:	64a2                	ld	s1,8(sp)
    800029dc:	6902                	ld	s2,0(sp)
    800029de:	6105                	addi	sp,sp,32
    800029e0:	8082                	ret

00000000800029e2 <syscall>:
  // clang-format on
};

void
syscall(void)
{
    800029e2:	1101                	addi	sp,sp,-32
    800029e4:	ec06                	sd	ra,24(sp)
    800029e6:	e822                	sd	s0,16(sp)
    800029e8:	e426                	sd	s1,8(sp)
    800029ea:	e04a                	sd	s2,0(sp)
    800029ec:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800029ee:	f5bfe0ef          	jal	80001948 <myproc>
    800029f2:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800029f4:	05853903          	ld	s2,88(a0)
    800029f8:	0a893783          	ld	a5,168(s2)
    800029fc:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002a00:	37fd                	addiw	a5,a5,-1
    80002a02:	4759                	li	a4,22
    80002a04:	00f76f63          	bltu	a4,a5,80002a22 <syscall+0x40>
    80002a08:	00369713          	slli	a4,a3,0x3
    80002a0c:	00005797          	auipc	a5,0x5
    80002a10:	d8478793          	addi	a5,a5,-636 # 80007790 <syscalls>
    80002a14:	97ba                	add	a5,a5,a4
    80002a16:	639c                	ld	a5,0(a5)
    80002a18:	c789                	beqz	a5,80002a22 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002a1a:	9782                	jalr	a5
    80002a1c:	06a93823          	sd	a0,112(s2)
    80002a20:	a829                	j	80002a3a <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    80002a22:	15848613          	addi	a2,s1,344
    80002a26:	588c                	lw	a1,48(s1)
    80002a28:	00005517          	auipc	a0,0x5
    80002a2c:	96850513          	addi	a0,a0,-1688 # 80007390 <etext+0x390>
    80002a30:	adbfd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    80002a34:	6cbc                	ld	a5,88(s1)
    80002a36:	577d                	li	a4,-1
    80002a38:	fbb8                	sd	a4,112(a5)
  }
}
    80002a3a:	60e2                	ld	ra,24(sp)
    80002a3c:	6442                	ld	s0,16(sp)
    80002a3e:	64a2                	ld	s1,8(sp)
    80002a40:	6902                	ld	s2,0(sp)
    80002a42:	6105                	addi	sp,sp,32
    80002a44:	8082                	ret

0000000080002a46 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002a46:	1101                	addi	sp,sp,-32
    80002a48:	ec06                	sd	ra,24(sp)
    80002a4a:	e822                	sd	s0,16(sp)
    80002a4c:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002a4e:	fec40593          	addi	a1,s0,-20
    80002a52:	4501                	li	a0,0
    80002a54:	f2fff0ef          	jal	80002982 <argint>
  kexit(n);
    80002a58:	fec42503          	lw	a0,-20(s0)
    80002a5c:	f3eff0ef          	jal	8000219a <kexit>
  return 0; // not reached
}
    80002a60:	4501                	li	a0,0
    80002a62:	60e2                	ld	ra,24(sp)
    80002a64:	6442                	ld	s0,16(sp)
    80002a66:	6105                	addi	sp,sp,32
    80002a68:	8082                	ret

0000000080002a6a <sys_getpid>:

uint64
sys_getpid(void)
{
    80002a6a:	1141                	addi	sp,sp,-16
    80002a6c:	e406                	sd	ra,8(sp)
    80002a6e:	e022                	sd	s0,0(sp)
    80002a70:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002a72:	ed7fe0ef          	jal	80001948 <myproc>
}
    80002a76:	5908                	lw	a0,48(a0)
    80002a78:	60a2                	ld	ra,8(sp)
    80002a7a:	6402                	ld	s0,0(sp)
    80002a7c:	0141                	addi	sp,sp,16
    80002a7e:	8082                	ret

0000000080002a80 <sys_fork>:

uint64
sys_fork(void)
{
    80002a80:	1141                	addi	sp,sp,-16
    80002a82:	e406                	sd	ra,8(sp)
    80002a84:	e022                	sd	s0,0(sp)
    80002a86:	0800                	addi	s0,sp,16
  return kfork();
    80002a88:	a50ff0ef          	jal	80001cd8 <kfork>
}
    80002a8c:	60a2                	ld	ra,8(sp)
    80002a8e:	6402                	ld	s0,0(sp)
    80002a90:	0141                	addi	sp,sp,16
    80002a92:	8082                	ret

0000000080002a94 <sys_wait>:

uint64
sys_wait(void)
{
    80002a94:	1101                	addi	sp,sp,-32
    80002a96:	ec06                	sd	ra,24(sp)
    80002a98:	e822                	sd	s0,16(sp)
    80002a9a:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002a9c:	fe840593          	addi	a1,s0,-24
    80002aa0:	4501                	li	a0,0
    80002aa2:	efdff0ef          	jal	8000299e <argaddr>
  return kwait(p);
    80002aa6:	fe843503          	ld	a0,-24(s0)
    80002aaa:	851ff0ef          	jal	800022fa <kwait>
}
    80002aae:	60e2                	ld	ra,24(sp)
    80002ab0:	6442                	ld	s0,16(sp)
    80002ab2:	6105                	addi	sp,sp,32
    80002ab4:	8082                	ret

0000000080002ab6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002ab6:	7179                	addi	sp,sp,-48
    80002ab8:	f406                	sd	ra,40(sp)
    80002aba:	f022                	sd	s0,32(sp)
    80002abc:	ec26                	sd	s1,24(sp)
    80002abe:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002ac0:	fd840593          	addi	a1,s0,-40
    80002ac4:	4501                	li	a0,0
    80002ac6:	ebdff0ef          	jal	80002982 <argint>
  argint(1, &t);
    80002aca:	fdc40593          	addi	a1,s0,-36
    80002ace:	4505                	li	a0,1
    80002ad0:	eb3ff0ef          	jal	80002982 <argint>
  addr = myproc()->sz;
    80002ad4:	e75fe0ef          	jal	80001948 <myproc>
    80002ad8:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002ada:	fdc42703          	lw	a4,-36(s0)
    80002ade:	4785                	li	a5,1
    80002ae0:	02f70763          	beq	a4,a5,80002b0e <sys_sbrk+0x58>
    80002ae4:	fd842783          	lw	a5,-40(s0)
    80002ae8:	0207c363          	bltz	a5,80002b0e <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002aec:	97a6                	add	a5,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    80002aee:	02000737          	lui	a4,0x2000
    80002af2:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002af4:	0736                	slli	a4,a4,0xd
    80002af6:	02f76a63          	bltu	a4,a5,80002b2a <sys_sbrk+0x74>
    80002afa:	0297e863          	bltu	a5,s1,80002b2a <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002afe:	e4bfe0ef          	jal	80001948 <myproc>
    80002b02:	fd842703          	lw	a4,-40(s0)
    80002b06:	653c                	ld	a5,72(a0)
    80002b08:	97ba                	add	a5,a5,a4
    80002b0a:	e53c                	sd	a5,72(a0)
    80002b0c:	a039                	j	80002b1a <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002b0e:	fd842503          	lw	a0,-40(s0)
    80002b12:	964ff0ef          	jal	80001c76 <growproc>
    80002b16:	00054863          	bltz	a0,80002b26 <sys_sbrk+0x70>
  }
  return addr;
}
    80002b1a:	8526                	mv	a0,s1
    80002b1c:	70a2                	ld	ra,40(sp)
    80002b1e:	7402                	ld	s0,32(sp)
    80002b20:	64e2                	ld	s1,24(sp)
    80002b22:	6145                	addi	sp,sp,48
    80002b24:	8082                	ret
      return -1;
    80002b26:	54fd                	li	s1,-1
    80002b28:	bfcd                	j	80002b1a <sys_sbrk+0x64>
      return -1;
    80002b2a:	54fd                	li	s1,-1
    80002b2c:	b7fd                	j	80002b1a <sys_sbrk+0x64>

0000000080002b2e <sys_pause>:

uint64
sys_pause(void)
{
    80002b2e:	7139                	addi	sp,sp,-64
    80002b30:	fc06                	sd	ra,56(sp)
    80002b32:	f822                	sd	s0,48(sp)
    80002b34:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002b36:	fcc40593          	addi	a1,s0,-52
    80002b3a:	4501                	li	a0,0
    80002b3c:	e47ff0ef          	jal	80002982 <argint>
  if (n < 0)
    80002b40:	fcc42783          	lw	a5,-52(s0)
    80002b44:	0807c063          	bltz	a5,80002bc4 <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002b48:	00016517          	auipc	a0,0x16
    80002b4c:	95050513          	addi	a0,a0,-1712 # 80018498 <tickslock>
    80002b50:	8d8fe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002b54:	fcc42783          	lw	a5,-52(s0)
    80002b58:	cbb9                	beqz	a5,80002bae <sys_pause+0x80>
    80002b5a:	f426                	sd	s1,40(sp)
    80002b5c:	f04a                	sd	s2,32(sp)
    80002b5e:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002b60:	00008997          	auipc	s3,0x8
    80002b64:	8089a983          	lw	s3,-2040(s3) # 8000a368 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002b68:	00008917          	auipc	s2,0x8
    80002b6c:	80090913          	addi	s2,s2,-2048 # 8000a368 <ticks>
    release(&tickslock);
    80002b70:	00016497          	auipc	s1,0x16
    80002b74:	92848493          	addi	s1,s1,-1752 # 80018498 <tickslock>
    if (killed(myproc())) {
    80002b78:	dd1fe0ef          	jal	80001948 <myproc>
    80002b7c:	f54ff0ef          	jal	800022d0 <killed>
    80002b80:	e529                	bnez	a0,80002bca <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002b82:	854a                	mv	a0,s2
    80002b84:	ceeff0ef          	jal	80002072 <sleep_prepare>
    release(&tickslock);
    80002b88:	8526                	mv	a0,s1
    80002b8a:	926fe0ef          	jal	80000cb0 <release>
    sleep();
    80002b8e:	d20ff0ef          	jal	800020ae <sleep>
    acquire(&tickslock);
    80002b92:	8526                	mv	a0,s1
    80002b94:	894fe0ef          	jal	80000c28 <acquire>
  while (ticks - ticks0 < n) {
    80002b98:	00092783          	lw	a5,0(s2)
    80002b9c:	413787bb          	subw	a5,a5,s3
    80002ba0:	fcc42703          	lw	a4,-52(s0)
    80002ba4:	fce7eae3          	bltu	a5,a4,80002b78 <sys_pause+0x4a>
    80002ba8:	74a2                	ld	s1,40(sp)
    80002baa:	7902                	ld	s2,32(sp)
    80002bac:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002bae:	00016517          	auipc	a0,0x16
    80002bb2:	8ea50513          	addi	a0,a0,-1814 # 80018498 <tickslock>
    80002bb6:	8fafe0ef          	jal	80000cb0 <release>
  return 0;
    80002bba:	4501                	li	a0,0
}
    80002bbc:	70e2                	ld	ra,56(sp)
    80002bbe:	7442                	ld	s0,48(sp)
    80002bc0:	6121                	addi	sp,sp,64
    80002bc2:	8082                	ret
    n = 0;
    80002bc4:	fc042623          	sw	zero,-52(s0)
    80002bc8:	b741                	j	80002b48 <sys_pause+0x1a>
      release(&tickslock);
    80002bca:	00016517          	auipc	a0,0x16
    80002bce:	8ce50513          	addi	a0,a0,-1842 # 80018498 <tickslock>
    80002bd2:	8defe0ef          	jal	80000cb0 <release>
      return -1;
    80002bd6:	557d                	li	a0,-1
    80002bd8:	74a2                	ld	s1,40(sp)
    80002bda:	7902                	ld	s2,32(sp)
    80002bdc:	69e2                	ld	s3,24(sp)
    80002bde:	bff9                	j	80002bbc <sys_pause+0x8e>

0000000080002be0 <sys_kill>:

uint64
sys_kill(void)
{
    80002be0:	1101                	addi	sp,sp,-32
    80002be2:	ec06                	sd	ra,24(sp)
    80002be4:	e822                	sd	s0,16(sp)
    80002be6:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002be8:	fec40593          	addi	a1,s0,-20
    80002bec:	4501                	li	a0,0
    80002bee:	d95ff0ef          	jal	80002982 <argint>
  return kkill(pid);
    80002bf2:	fec42503          	lw	a0,-20(s0)
    80002bf6:	e4aff0ef          	jal	80002240 <kkill>
}
    80002bfa:	60e2                	ld	ra,24(sp)
    80002bfc:	6442                	ld	s0,16(sp)
    80002bfe:	6105                	addi	sp,sp,32
    80002c00:	8082                	ret

0000000080002c02 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002c02:	1101                	addi	sp,sp,-32
    80002c04:	ec06                	sd	ra,24(sp)
    80002c06:	e822                	sd	s0,16(sp)
    80002c08:	e426                	sd	s1,8(sp)
    80002c0a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002c0c:	00016517          	auipc	a0,0x16
    80002c10:	88c50513          	addi	a0,a0,-1908 # 80018498 <tickslock>
    80002c14:	814fe0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002c18:	00007797          	auipc	a5,0x7
    80002c1c:	7507a783          	lw	a5,1872(a5) # 8000a368 <ticks>
    80002c20:	84be                	mv	s1,a5
  release(&tickslock);
    80002c22:	00016517          	auipc	a0,0x16
    80002c26:	87650513          	addi	a0,a0,-1930 # 80018498 <tickslock>
    80002c2a:	886fe0ef          	jal	80000cb0 <release>
  return xticks;
}
    80002c2e:	02049513          	slli	a0,s1,0x20
    80002c32:	9101                	srli	a0,a0,0x20
    80002c34:	60e2                	ld	ra,24(sp)
    80002c36:	6442                	ld	s0,16(sp)
    80002c38:	64a2                	ld	s1,8(sp)
    80002c3a:	6105                	addi	sp,sp,32
    80002c3c:	8082                	ret

0000000080002c3e <sys_set_burst>:

// HRRN: System call to set declared burst time
uint64
sys_set_burst(void)
{
    80002c3e:	1101                	addi	sp,sp,-32
    80002c40:	ec06                	sd	ra,24(sp)
    80002c42:	e822                	sd	s0,16(sp)
    80002c44:	1000                	addi	s0,sp,32
  int pid;
  int bt;

  argint(0, &pid);
    80002c46:	fec40593          	addi	a1,s0,-20
    80002c4a:	4501                	li	a0,0
    80002c4c:	d37ff0ef          	jal	80002982 <argint>
  argint(1, &bt);
    80002c50:	fe840593          	addi	a1,s0,-24
    80002c54:	4505                	li	a0,1
    80002c56:	d2dff0ef          	jal	80002982 <argint>
  return set_burst(pid, bt);
    80002c5a:	fe842583          	lw	a1,-24(s0)
    80002c5e:	fec42503          	lw	a0,-20(s0)
    80002c62:	984ff0ef          	jal	80001de6 <set_burst>
}
    80002c66:	60e2                	ld	ra,24(sp)
    80002c68:	6442                	ld	s0,16(sp)
    80002c6a:	6105                	addi	sp,sp,32
    80002c6c:	8082                	ret

0000000080002c6e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002c6e:	7179                	addi	sp,sp,-48
    80002c70:	f406                	sd	ra,40(sp)
    80002c72:	f022                	sd	s0,32(sp)
    80002c74:	ec26                	sd	s1,24(sp)
    80002c76:	e84a                	sd	s2,16(sp)
    80002c78:	e44e                	sd	s3,8(sp)
    80002c7a:	e052                	sd	s4,0(sp)
    80002c7c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002c7e:	00004597          	auipc	a1,0x4
    80002c82:	73258593          	addi	a1,a1,1842 # 800073b0 <etext+0x3b0>
    80002c86:	00016517          	auipc	a0,0x16
    80002c8a:	82a50513          	addi	a0,a0,-2006 # 800184b0 <bcache>
    80002c8e:	f1bfd0ef          	jal	80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002c92:	0001e797          	auipc	a5,0x1e
    80002c96:	81e78793          	addi	a5,a5,-2018 # 800204b0 <bcache+0x8000>
    80002c9a:	0001e717          	auipc	a4,0x1e
    80002c9e:	a7e70713          	addi	a4,a4,-1410 # 80020718 <bcache+0x8268>
    80002ca2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002ca6:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002caa:	00016497          	auipc	s1,0x16
    80002cae:	81e48493          	addi	s1,s1,-2018 # 800184c8 <bcache+0x18>
    b->next = bcache.head.next;
    80002cb2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002cb4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002cb6:	00004a17          	auipc	s4,0x4
    80002cba:	702a0a13          	addi	s4,s4,1794 # 800073b8 <etext+0x3b8>
    b->next = bcache.head.next;
    80002cbe:	2b893783          	ld	a5,696(s2)
    80002cc2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002cc4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002cc8:	85d2                	mv	a1,s4
    80002cca:	01048513          	addi	a0,s1,16
    80002cce:	41c010ef          	jal	800040ea <initsleeplock>
    bcache.head.next->prev = b;
    80002cd2:	2b893783          	ld	a5,696(s2)
    80002cd6:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002cd8:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002cdc:	45848493          	addi	s1,s1,1112
    80002ce0:	fd349fe3          	bne	s1,s3,80002cbe <binit+0x50>
  }
}
    80002ce4:	70a2                	ld	ra,40(sp)
    80002ce6:	7402                	ld	s0,32(sp)
    80002ce8:	64e2                	ld	s1,24(sp)
    80002cea:	6942                	ld	s2,16(sp)
    80002cec:	69a2                	ld	s3,8(sp)
    80002cee:	6a02                	ld	s4,0(sp)
    80002cf0:	6145                	addi	sp,sp,48
    80002cf2:	8082                	ret

0000000080002cf4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002cf4:	7179                	addi	sp,sp,-48
    80002cf6:	f406                	sd	ra,40(sp)
    80002cf8:	f022                	sd	s0,32(sp)
    80002cfa:	ec26                	sd	s1,24(sp)
    80002cfc:	e84a                	sd	s2,16(sp)
    80002cfe:	e44e                	sd	s3,8(sp)
    80002d00:	1800                	addi	s0,sp,48
    80002d02:	892a                	mv	s2,a0
    80002d04:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002d06:	00015517          	auipc	a0,0x15
    80002d0a:	7aa50513          	addi	a0,a0,1962 # 800184b0 <bcache>
    80002d0e:	f1bfd0ef          	jal	80000c28 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002d12:	0001e497          	auipc	s1,0x1e
    80002d16:	a564b483          	ld	s1,-1450(s1) # 80020768 <bcache+0x82b8>
    80002d1a:	0001e797          	auipc	a5,0x1e
    80002d1e:	9fe78793          	addi	a5,a5,-1538 # 80020718 <bcache+0x8268>
    80002d22:	02f48b63          	beq	s1,a5,80002d58 <bread+0x64>
    80002d26:	873e                	mv	a4,a5
    80002d28:	a021                	j	80002d30 <bread+0x3c>
    80002d2a:	68a4                	ld	s1,80(s1)
    80002d2c:	02e48663          	beq	s1,a4,80002d58 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002d30:	449c                	lw	a5,8(s1)
    80002d32:	ff279ce3          	bne	a5,s2,80002d2a <bread+0x36>
    80002d36:	44dc                	lw	a5,12(s1)
    80002d38:	ff3799e3          	bne	a5,s3,80002d2a <bread+0x36>
      b->refcnt++;
    80002d3c:	40bc                	lw	a5,64(s1)
    80002d3e:	2785                	addiw	a5,a5,1
    80002d40:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d42:	00015517          	auipc	a0,0x15
    80002d46:	76e50513          	addi	a0,a0,1902 # 800184b0 <bcache>
    80002d4a:	f67fd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002d4e:	01048513          	addi	a0,s1,16
    80002d52:	3ce010ef          	jal	80004120 <acquiresleep>
      return b;
    80002d56:	a889                	j	80002da8 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002d58:	0001e497          	auipc	s1,0x1e
    80002d5c:	a084b483          	ld	s1,-1528(s1) # 80020760 <bcache+0x82b0>
    80002d60:	0001e797          	auipc	a5,0x1e
    80002d64:	9b878793          	addi	a5,a5,-1608 # 80020718 <bcache+0x8268>
    80002d68:	00f48863          	beq	s1,a5,80002d78 <bread+0x84>
    80002d6c:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002d6e:	40bc                	lw	a5,64(s1)
    80002d70:	cb91                	beqz	a5,80002d84 <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002d72:	64a4                	ld	s1,72(s1)
    80002d74:	fee49de3          	bne	s1,a4,80002d6e <bread+0x7a>
  panic("bget: no buffers");
    80002d78:	00004517          	auipc	a0,0x4
    80002d7c:	64850513          	addi	a0,a0,1608 # 800073c0 <etext+0x3c0>
    80002d80:	ab5fd0ef          	jal	80000834 <panic>
      b->dev = dev;
    80002d84:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002d88:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002d8c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002d90:	4785                	li	a5,1
    80002d92:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d94:	00015517          	auipc	a0,0x15
    80002d98:	71c50513          	addi	a0,a0,1820 # 800184b0 <bcache>
    80002d9c:	f15fd0ef          	jal	80000cb0 <release>
      acquiresleep(&b->lock);
    80002da0:	01048513          	addi	a0,s1,16
    80002da4:	37c010ef          	jal	80004120 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002da8:	409c                	lw	a5,0(s1)
    80002daa:	cb89                	beqz	a5,80002dbc <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002dac:	8526                	mv	a0,s1
    80002dae:	70a2                	ld	ra,40(sp)
    80002db0:	7402                	ld	s0,32(sp)
    80002db2:	64e2                	ld	s1,24(sp)
    80002db4:	6942                	ld	s2,16(sp)
    80002db6:	69a2                	ld	s3,8(sp)
    80002db8:	6145                	addi	sp,sp,48
    80002dba:	8082                	ret
    virtio_disk_rw(b, 0);
    80002dbc:	4581                	li	a1,0
    80002dbe:	8526                	mv	a0,s1
    80002dc0:	4c7020ef          	jal	80005a86 <virtio_disk_rw>
    b->valid = 1;
    80002dc4:	4785                	li	a5,1
    80002dc6:	c09c                	sw	a5,0(s1)
  return b;
    80002dc8:	b7d5                	j	80002dac <bread+0xb8>

0000000080002dca <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002dca:	1101                	addi	sp,sp,-32
    80002dcc:	ec06                	sd	ra,24(sp)
    80002dce:	e822                	sd	s0,16(sp)
    80002dd0:	e426                	sd	s1,8(sp)
    80002dd2:	1000                	addi	s0,sp,32
    80002dd4:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002dd6:	0541                	addi	a0,a0,16
    80002dd8:	3d4010ef          	jal	800041ac <holdingsleep>
    80002ddc:	c911                	beqz	a0,80002df0 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002dde:	4585                	li	a1,1
    80002de0:	8526                	mv	a0,s1
    80002de2:	4a5020ef          	jal	80005a86 <virtio_disk_rw>
}
    80002de6:	60e2                	ld	ra,24(sp)
    80002de8:	6442                	ld	s0,16(sp)
    80002dea:	64a2                	ld	s1,8(sp)
    80002dec:	6105                	addi	sp,sp,32
    80002dee:	8082                	ret
    panic("bwrite");
    80002df0:	00004517          	auipc	a0,0x4
    80002df4:	5e850513          	addi	a0,a0,1512 # 800073d8 <etext+0x3d8>
    80002df8:	a3dfd0ef          	jal	80000834 <panic>

0000000080002dfc <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002dfc:	1101                	addi	sp,sp,-32
    80002dfe:	ec06                	sd	ra,24(sp)
    80002e00:	e822                	sd	s0,16(sp)
    80002e02:	e426                	sd	s1,8(sp)
    80002e04:	e04a                	sd	s2,0(sp)
    80002e06:	1000                	addi	s0,sp,32
    80002e08:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002e0a:	01050913          	addi	s2,a0,16
    80002e0e:	854a                	mv	a0,s2
    80002e10:	39c010ef          	jal	800041ac <holdingsleep>
    80002e14:	c125                	beqz	a0,80002e74 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002e16:	854a                	mv	a0,s2
    80002e18:	35c010ef          	jal	80004174 <releasesleep>

  acquire(&bcache.lock);
    80002e1c:	00015517          	auipc	a0,0x15
    80002e20:	69450513          	addi	a0,a0,1684 # 800184b0 <bcache>
    80002e24:	e05fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002e28:	40bc                	lw	a5,64(s1)
    80002e2a:	37fd                	addiw	a5,a5,-1
    80002e2c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002e2e:	e79d                	bnez	a5,80002e5c <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002e30:	68b8                	ld	a4,80(s1)
    80002e32:	64bc                	ld	a5,72(s1)
    80002e34:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002e36:	68b8                	ld	a4,80(s1)
    80002e38:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002e3a:	0001d797          	auipc	a5,0x1d
    80002e3e:	67678793          	addi	a5,a5,1654 # 800204b0 <bcache+0x8000>
    80002e42:	2b87b703          	ld	a4,696(a5)
    80002e46:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002e48:	0001e717          	auipc	a4,0x1e
    80002e4c:	8d070713          	addi	a4,a4,-1840 # 80020718 <bcache+0x8268>
    80002e50:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002e52:	2b87b703          	ld	a4,696(a5)
    80002e56:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002e58:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002e5c:	00015517          	auipc	a0,0x15
    80002e60:	65450513          	addi	a0,a0,1620 # 800184b0 <bcache>
    80002e64:	e4dfd0ef          	jal	80000cb0 <release>
}
    80002e68:	60e2                	ld	ra,24(sp)
    80002e6a:	6442                	ld	s0,16(sp)
    80002e6c:	64a2                	ld	s1,8(sp)
    80002e6e:	6902                	ld	s2,0(sp)
    80002e70:	6105                	addi	sp,sp,32
    80002e72:	8082                	ret
    panic("brelse");
    80002e74:	00004517          	auipc	a0,0x4
    80002e78:	56c50513          	addi	a0,a0,1388 # 800073e0 <etext+0x3e0>
    80002e7c:	9b9fd0ef          	jal	80000834 <panic>

0000000080002e80 <bpin>:

void
bpin(struct buf *b)
{
    80002e80:	1101                	addi	sp,sp,-32
    80002e82:	ec06                	sd	ra,24(sp)
    80002e84:	e822                	sd	s0,16(sp)
    80002e86:	e426                	sd	s1,8(sp)
    80002e88:	1000                	addi	s0,sp,32
    80002e8a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e8c:	00015517          	auipc	a0,0x15
    80002e90:	62450513          	addi	a0,a0,1572 # 800184b0 <bcache>
    80002e94:	d95fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002e98:	40bc                	lw	a5,64(s1)
    80002e9a:	2785                	addiw	a5,a5,1
    80002e9c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e9e:	00015517          	auipc	a0,0x15
    80002ea2:	61250513          	addi	a0,a0,1554 # 800184b0 <bcache>
    80002ea6:	e0bfd0ef          	jal	80000cb0 <release>
}
    80002eaa:	60e2                	ld	ra,24(sp)
    80002eac:	6442                	ld	s0,16(sp)
    80002eae:	64a2                	ld	s1,8(sp)
    80002eb0:	6105                	addi	sp,sp,32
    80002eb2:	8082                	ret

0000000080002eb4 <bunpin>:

void
bunpin(struct buf *b)
{
    80002eb4:	1101                	addi	sp,sp,-32
    80002eb6:	ec06                	sd	ra,24(sp)
    80002eb8:	e822                	sd	s0,16(sp)
    80002eba:	e426                	sd	s1,8(sp)
    80002ebc:	1000                	addi	s0,sp,32
    80002ebe:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ec0:	00015517          	auipc	a0,0x15
    80002ec4:	5f050513          	addi	a0,a0,1520 # 800184b0 <bcache>
    80002ec8:	d61fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002ecc:	40bc                	lw	a5,64(s1)
    80002ece:	37fd                	addiw	a5,a5,-1
    80002ed0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002ed2:	00015517          	auipc	a0,0x15
    80002ed6:	5de50513          	addi	a0,a0,1502 # 800184b0 <bcache>
    80002eda:	dd7fd0ef          	jal	80000cb0 <release>
}
    80002ede:	60e2                	ld	ra,24(sp)
    80002ee0:	6442                	ld	s0,16(sp)
    80002ee2:	64a2                	ld	s1,8(sp)
    80002ee4:	6105                	addi	sp,sp,32
    80002ee6:	8082                	ret

0000000080002ee8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002ee8:	1101                	addi	sp,sp,-32
    80002eea:	ec06                	sd	ra,24(sp)
    80002eec:	e822                	sd	s0,16(sp)
    80002eee:	e426                	sd	s1,8(sp)
    80002ef0:	e04a                	sd	s2,0(sp)
    80002ef2:	1000                	addi	s0,sp,32
    80002ef4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002ef6:	00d5d79b          	srliw	a5,a1,0xd
    80002efa:	0001e597          	auipc	a1,0x1e
    80002efe:	c925a583          	lw	a1,-878(a1) # 80020b8c <sb+0x1c>
    80002f02:	9dbd                	addw	a1,a1,a5
    80002f04:	df1ff0ef          	jal	80002cf4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002f08:	0074f713          	andi	a4,s1,7
    80002f0c:	4785                	li	a5,1
    80002f0e:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002f12:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80002f14:	90d9                	srli	s1,s1,0x36
    80002f16:	00950733          	add	a4,a0,s1
    80002f1a:	05874703          	lbu	a4,88(a4)
    80002f1e:	00e7f6b3          	and	a3,a5,a4
    80002f22:	c29d                	beqz	a3,80002f48 <bfree+0x60>
    80002f24:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002f26:	94aa                	add	s1,s1,a0
    80002f28:	fff7c793          	not	a5,a5
    80002f2c:	8f7d                	and	a4,a4,a5
    80002f2e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002f32:	080010ef          	jal	80003fb2 <log_write>
  brelse(bp);
    80002f36:	854a                	mv	a0,s2
    80002f38:	ec5ff0ef          	jal	80002dfc <brelse>
}
    80002f3c:	60e2                	ld	ra,24(sp)
    80002f3e:	6442                	ld	s0,16(sp)
    80002f40:	64a2                	ld	s1,8(sp)
    80002f42:	6902                	ld	s2,0(sp)
    80002f44:	6105                	addi	sp,sp,32
    80002f46:	8082                	ret
    panic("freeing free block");
    80002f48:	00004517          	auipc	a0,0x4
    80002f4c:	4a050513          	addi	a0,a0,1184 # 800073e8 <etext+0x3e8>
    80002f50:	8e5fd0ef          	jal	80000834 <panic>

0000000080002f54 <balloc>:
{
    80002f54:	715d                	addi	sp,sp,-80
    80002f56:	e486                	sd	ra,72(sp)
    80002f58:	e0a2                	sd	s0,64(sp)
    80002f5a:	fc26                	sd	s1,56(sp)
    80002f5c:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80002f5e:	0001e797          	auipc	a5,0x1e
    80002f62:	c167a783          	lw	a5,-1002(a5) # 80020b74 <sb+0x4>
    80002f66:	0e078263          	beqz	a5,8000304a <balloc+0xf6>
    80002f6a:	f84a                	sd	s2,48(sp)
    80002f6c:	f44e                	sd	s3,40(sp)
    80002f6e:	f052                	sd	s4,32(sp)
    80002f70:	ec56                	sd	s5,24(sp)
    80002f72:	e85a                	sd	s6,16(sp)
    80002f74:	e45e                	sd	s7,8(sp)
    80002f76:	e062                	sd	s8,0(sp)
    80002f78:	8baa                	mv	s7,a0
    80002f7a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002f7c:	0001eb17          	auipc	s6,0x1e
    80002f80:	bf4b0b13          	addi	s6,s6,-1036 # 80020b70 <sb>
      m = 1 << (bi % 8);
    80002f84:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002f86:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80002f88:	6c09                	lui	s8,0x2
    80002f8a:	a09d                	j	80002ff0 <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80002f8c:	97ca                	add	a5,a5,s2
    80002f8e:	8e55                	or	a2,a2,a3
    80002f90:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002f94:	854a                	mv	a0,s2
    80002f96:	01c010ef          	jal	80003fb2 <log_write>
        brelse(bp);
    80002f9a:	854a                	mv	a0,s2
    80002f9c:	e61ff0ef          	jal	80002dfc <brelse>
  bp = bread(dev, bno);
    80002fa0:	85a6                	mv	a1,s1
    80002fa2:	855e                	mv	a0,s7
    80002fa4:	d51ff0ef          	jal	80002cf4 <bread>
    80002fa8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002faa:	40000613          	li	a2,1024
    80002fae:	4581                	li	a1,0
    80002fb0:	05850513          	addi	a0,a0,88
    80002fb4:	d35fd0ef          	jal	80000ce8 <memset>
  log_write(bp);
    80002fb8:	854a                	mv	a0,s2
    80002fba:	7f9000ef          	jal	80003fb2 <log_write>
  brelse(bp);
    80002fbe:	854a                	mv	a0,s2
    80002fc0:	e3dff0ef          	jal	80002dfc <brelse>
}
    80002fc4:	7942                	ld	s2,48(sp)
    80002fc6:	79a2                	ld	s3,40(sp)
    80002fc8:	7a02                	ld	s4,32(sp)
    80002fca:	6ae2                	ld	s5,24(sp)
    80002fcc:	6b42                	ld	s6,16(sp)
    80002fce:	6ba2                	ld	s7,8(sp)
    80002fd0:	6c02                	ld	s8,0(sp)
}
    80002fd2:	8526                	mv	a0,s1
    80002fd4:	60a6                	ld	ra,72(sp)
    80002fd6:	6406                	ld	s0,64(sp)
    80002fd8:	74e2                	ld	s1,56(sp)
    80002fda:	6161                	addi	sp,sp,80
    80002fdc:	8082                	ret
    brelse(bp);
    80002fde:	854a                	mv	a0,s2
    80002fe0:	e1dff0ef          	jal	80002dfc <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80002fe4:	015c0abb          	addw	s5,s8,s5
    80002fe8:	004b2783          	lw	a5,4(s6)
    80002fec:	04faf863          	bgeu	s5,a5,8000303c <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80002ff0:	40dad59b          	sraiw	a1,s5,0xd
    80002ff4:	01cb2783          	lw	a5,28(s6)
    80002ff8:	9dbd                	addw	a1,a1,a5
    80002ffa:	855e                	mv	a0,s7
    80002ffc:	cf9ff0ef          	jal	80002cf4 <bread>
    80003000:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003002:	004b2503          	lw	a0,4(s6)
    80003006:	84d6                	mv	s1,s5
    80003008:	4701                	li	a4,0
    8000300a:	fca4fae3          	bgeu	s1,a0,80002fde <balloc+0x8a>
      m = 1 << (bi % 8);
    8000300e:	00777693          	andi	a3,a4,7
    80003012:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80003016:	41f7579b          	sraiw	a5,a4,0x1f
    8000301a:	01d7d79b          	srliw	a5,a5,0x1d
    8000301e:	9fb9                	addw	a5,a5,a4
    80003020:	4037d79b          	sraiw	a5,a5,0x3
    80003024:	00f90633          	add	a2,s2,a5
    80003028:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    8000302c:	00c6f5b3          	and	a1,a3,a2
    80003030:	ddb1                	beqz	a1,80002f8c <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003032:	2705                	addiw	a4,a4,1
    80003034:	2485                	addiw	s1,s1,1
    80003036:	fd471ae3          	bne	a4,s4,8000300a <balloc+0xb6>
    8000303a:	b755                	j	80002fde <balloc+0x8a>
    8000303c:	7942                	ld	s2,48(sp)
    8000303e:	79a2                	ld	s3,40(sp)
    80003040:	7a02                	ld	s4,32(sp)
    80003042:	6ae2                	ld	s5,24(sp)
    80003044:	6b42                	ld	s6,16(sp)
    80003046:	6ba2                	ld	s7,8(sp)
    80003048:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    8000304a:	00004517          	auipc	a0,0x4
    8000304e:	3b650513          	addi	a0,a0,950 # 80007400 <etext+0x400>
    80003052:	cb8fd0ef          	jal	8000050a <printk>
  return 0;
    80003056:	4481                	li	s1,0
    80003058:	bfad                	j	80002fd2 <balloc+0x7e>

000000008000305a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000305a:	7179                	addi	sp,sp,-48
    8000305c:	f406                	sd	ra,40(sp)
    8000305e:	f022                	sd	s0,32(sp)
    80003060:	ec26                	sd	s1,24(sp)
    80003062:	e84a                	sd	s2,16(sp)
    80003064:	e44e                	sd	s3,8(sp)
    80003066:	1800                	addi	s0,sp,48
    80003068:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    8000306a:	47ad                	li	a5,11
    8000306c:	02b7e363          	bltu	a5,a1,80003092 <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    80003070:	02059793          	slli	a5,a1,0x20
    80003074:	01e7d593          	srli	a1,a5,0x1e
    80003078:	00b509b3          	add	s3,a0,a1
    8000307c:	0509a483          	lw	s1,80(s3)
    80003080:	e0b5                	bnez	s1,800030e4 <bmap+0x8a>
      addr = balloc(ip->dev);
    80003082:	4108                	lw	a0,0(a0)
    80003084:	ed1ff0ef          	jal	80002f54 <balloc>
    80003088:	84aa                	mv	s1,a0
      if (addr == 0)
    8000308a:	cd29                	beqz	a0,800030e4 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    8000308c:	04a9a823          	sw	a0,80(s3)
    80003090:	a891                	j	800030e4 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003092:	ff45879b          	addiw	a5,a1,-12
    80003096:	873e                	mv	a4,a5
    80003098:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    8000309a:	0ff00793          	li	a5,255
    8000309e:	06e7e763          	bltu	a5,a4,8000310c <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    800030a2:	08052483          	lw	s1,128(a0)
    800030a6:	e891                	bnez	s1,800030ba <bmap+0x60>
      addr = balloc(ip->dev);
    800030a8:	4108                	lw	a0,0(a0)
    800030aa:	eabff0ef          	jal	80002f54 <balloc>
    800030ae:	84aa                	mv	s1,a0
      if (addr == 0)
    800030b0:	c915                	beqz	a0,800030e4 <bmap+0x8a>
    800030b2:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800030b4:	08a92023          	sw	a0,128(s2)
    800030b8:	a011                	j	800030bc <bmap+0x62>
    800030ba:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800030bc:	85a6                	mv	a1,s1
    800030be:	00092503          	lw	a0,0(s2)
    800030c2:	c33ff0ef          	jal	80002cf4 <bread>
    800030c6:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    800030c8:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    800030cc:	02099713          	slli	a4,s3,0x20
    800030d0:	01e75593          	srli	a1,a4,0x1e
    800030d4:	97ae                	add	a5,a5,a1
    800030d6:	89be                	mv	s3,a5
    800030d8:	4384                	lw	s1,0(a5)
    800030da:	cc89                	beqz	s1,800030f4 <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800030dc:	8552                	mv	a0,s4
    800030de:	d1fff0ef          	jal	80002dfc <brelse>
    return addr;
    800030e2:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800030e4:	8526                	mv	a0,s1
    800030e6:	70a2                	ld	ra,40(sp)
    800030e8:	7402                	ld	s0,32(sp)
    800030ea:	64e2                	ld	s1,24(sp)
    800030ec:	6942                	ld	s2,16(sp)
    800030ee:	69a2                	ld	s3,8(sp)
    800030f0:	6145                	addi	sp,sp,48
    800030f2:	8082                	ret
      addr = balloc(ip->dev);
    800030f4:	00092503          	lw	a0,0(s2)
    800030f8:	e5dff0ef          	jal	80002f54 <balloc>
    800030fc:	84aa                	mv	s1,a0
      if (addr) {
    800030fe:	dd79                	beqz	a0,800030dc <bmap+0x82>
        a[bn] = addr;
    80003100:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80003104:	8552                	mv	a0,s4
    80003106:	6ad000ef          	jal	80003fb2 <log_write>
    8000310a:	bfc9                	j	800030dc <bmap+0x82>
    8000310c:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000310e:	00004517          	auipc	a0,0x4
    80003112:	30a50513          	addi	a0,a0,778 # 80007418 <etext+0x418>
    80003116:	f1efd0ef          	jal	80000834 <panic>

000000008000311a <iget>:
{
    8000311a:	7179                	addi	sp,sp,-48
    8000311c:	f406                	sd	ra,40(sp)
    8000311e:	f022                	sd	s0,32(sp)
    80003120:	ec26                	sd	s1,24(sp)
    80003122:	e84a                	sd	s2,16(sp)
    80003124:	e44e                	sd	s3,8(sp)
    80003126:	e052                	sd	s4,0(sp)
    80003128:	1800                	addi	s0,sp,48
    8000312a:	892a                	mv	s2,a0
    8000312c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000312e:	0001e517          	auipc	a0,0x1e
    80003132:	a6250513          	addi	a0,a0,-1438 # 80020b90 <itable>
    80003136:	af3fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    8000313a:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    8000313c:	0001e497          	auipc	s1,0x1e
    80003140:	a6c48493          	addi	s1,s1,-1428 # 80020ba8 <itable+0x18>
    80003144:	0001f697          	auipc	a3,0x1f
    80003148:	4f468693          	addi	a3,a3,1268 # 80022638 <log>
    8000314c:	a809                	j	8000315e <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    8000314e:	e781                	bnez	a5,80003156 <iget+0x3c>
    80003150:	00099363          	bnez	s3,80003156 <iget+0x3c>
      empty = ip;
    80003154:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80003156:	08848493          	addi	s1,s1,136
    8000315a:	02d48563          	beq	s1,a3,80003184 <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    8000315e:	449c                	lw	a5,8(s1)
    80003160:	fef057e3          	blez	a5,8000314e <iget+0x34>
    80003164:	4098                	lw	a4,0(s1)
    80003166:	ff2718e3          	bne	a4,s2,80003156 <iget+0x3c>
    8000316a:	40d8                	lw	a4,4(s1)
    8000316c:	ff4715e3          	bne	a4,s4,80003156 <iget+0x3c>
      ip->ref++;
    80003170:	2785                	addiw	a5,a5,1
    80003172:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003174:	0001e517          	auipc	a0,0x1e
    80003178:	a1c50513          	addi	a0,a0,-1508 # 80020b90 <itable>
    8000317c:	b35fd0ef          	jal	80000cb0 <release>
      return ip;
    80003180:	89a6                	mv	s3,s1
    80003182:	a015                	j	800031a6 <iget+0x8c>
  if (empty == 0)
    80003184:	02098a63          	beqz	s3,800031b8 <iget+0x9e>
  ip->dev = dev;
    80003188:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    8000318c:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003190:	4785                	li	a5,1
    80003192:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003196:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    8000319a:	0001e517          	auipc	a0,0x1e
    8000319e:	9f650513          	addi	a0,a0,-1546 # 80020b90 <itable>
    800031a2:	b0ffd0ef          	jal	80000cb0 <release>
}
    800031a6:	854e                	mv	a0,s3
    800031a8:	70a2                	ld	ra,40(sp)
    800031aa:	7402                	ld	s0,32(sp)
    800031ac:	64e2                	ld	s1,24(sp)
    800031ae:	6942                	ld	s2,16(sp)
    800031b0:	69a2                	ld	s3,8(sp)
    800031b2:	6a02                	ld	s4,0(sp)
    800031b4:	6145                	addi	sp,sp,48
    800031b6:	8082                	ret
    panic("iget: no inodes");
    800031b8:	00004517          	auipc	a0,0x4
    800031bc:	27850513          	addi	a0,a0,632 # 80007430 <etext+0x430>
    800031c0:	e74fd0ef          	jal	80000834 <panic>

00000000800031c4 <iinit>:
{
    800031c4:	7179                	addi	sp,sp,-48
    800031c6:	f406                	sd	ra,40(sp)
    800031c8:	f022                	sd	s0,32(sp)
    800031ca:	ec26                	sd	s1,24(sp)
    800031cc:	e84a                	sd	s2,16(sp)
    800031ce:	e44e                	sd	s3,8(sp)
    800031d0:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800031d2:	00004597          	auipc	a1,0x4
    800031d6:	26e58593          	addi	a1,a1,622 # 80007440 <etext+0x440>
    800031da:	0001e517          	auipc	a0,0x1e
    800031de:	9b650513          	addi	a0,a0,-1610 # 80020b90 <itable>
    800031e2:	9c7fd0ef          	jal	80000ba8 <initlock>
  for (i = 0; i < NINODE; i++) {
    800031e6:	0001e497          	auipc	s1,0x1e
    800031ea:	9d248493          	addi	s1,s1,-1582 # 80020bb8 <itable+0x28>
    800031ee:	0001f997          	auipc	s3,0x1f
    800031f2:	45a98993          	addi	s3,s3,1114 # 80022648 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800031f6:	00004917          	auipc	s2,0x4
    800031fa:	25290913          	addi	s2,s2,594 # 80007448 <etext+0x448>
    800031fe:	85ca                	mv	a1,s2
    80003200:	8526                	mv	a0,s1
    80003202:	6e9000ef          	jal	800040ea <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    80003206:	08848493          	addi	s1,s1,136
    8000320a:	ff349ae3          	bne	s1,s3,800031fe <iinit+0x3a>
}
    8000320e:	70a2                	ld	ra,40(sp)
    80003210:	7402                	ld	s0,32(sp)
    80003212:	64e2                	ld	s1,24(sp)
    80003214:	6942                	ld	s2,16(sp)
    80003216:	69a2                	ld	s3,8(sp)
    80003218:	6145                	addi	sp,sp,48
    8000321a:	8082                	ret

000000008000321c <ialloc>:
{
    8000321c:	7139                	addi	sp,sp,-64
    8000321e:	fc06                	sd	ra,56(sp)
    80003220:	f822                	sd	s0,48(sp)
    80003222:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003224:	0001e717          	auipc	a4,0x1e
    80003228:	95872703          	lw	a4,-1704(a4) # 80020b7c <sb+0xc>
    8000322c:	4785                	li	a5,1
    8000322e:	06e7f063          	bgeu	a5,a4,8000328e <ialloc+0x72>
    80003232:	f426                	sd	s1,40(sp)
    80003234:	f04a                	sd	s2,32(sp)
    80003236:	ec4e                	sd	s3,24(sp)
    80003238:	e852                	sd	s4,16(sp)
    8000323a:	e456                	sd	s5,8(sp)
    8000323c:	e05a                	sd	s6,0(sp)
    8000323e:	8aaa                	mv	s5,a0
    80003240:	8b2e                	mv	s6,a1
    80003242:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003244:	0001ea17          	auipc	s4,0x1e
    80003248:	92ca0a13          	addi	s4,s4,-1748 # 80020b70 <sb>
    8000324c:	00495593          	srli	a1,s2,0x4
    80003250:	018a2783          	lw	a5,24(s4)
    80003254:	9dbd                	addw	a1,a1,a5
    80003256:	8556                	mv	a0,s5
    80003258:	a9dff0ef          	jal	80002cf4 <bread>
    8000325c:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    8000325e:	05850993          	addi	s3,a0,88
    80003262:	00f97793          	andi	a5,s2,15
    80003266:	079a                	slli	a5,a5,0x6
    80003268:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    8000326a:	00099783          	lh	a5,0(s3)
    8000326e:	cb9d                	beqz	a5,800032a4 <ialloc+0x88>
    brelse(bp);
    80003270:	b8dff0ef          	jal	80002dfc <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003274:	0905                	addi	s2,s2,1
    80003276:	00ca2703          	lw	a4,12(s4)
    8000327a:	0009079b          	sext.w	a5,s2
    8000327e:	fce7e7e3          	bltu	a5,a4,8000324c <ialloc+0x30>
    80003282:	74a2                	ld	s1,40(sp)
    80003284:	7902                	ld	s2,32(sp)
    80003286:	69e2                	ld	s3,24(sp)
    80003288:	6a42                	ld	s4,16(sp)
    8000328a:	6aa2                	ld	s5,8(sp)
    8000328c:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    8000328e:	00004517          	auipc	a0,0x4
    80003292:	1c250513          	addi	a0,a0,450 # 80007450 <etext+0x450>
    80003296:	a74fd0ef          	jal	8000050a <printk>
  return 0;
    8000329a:	4501                	li	a0,0
}
    8000329c:	70e2                	ld	ra,56(sp)
    8000329e:	7442                	ld	s0,48(sp)
    800032a0:	6121                	addi	sp,sp,64
    800032a2:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800032a4:	04000613          	li	a2,64
    800032a8:	4581                	li	a1,0
    800032aa:	854e                	mv	a0,s3
    800032ac:	a3dfd0ef          	jal	80000ce8 <memset>
      dip->type = type;
    800032b0:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    800032b4:	8526                	mv	a0,s1
    800032b6:	4fd000ef          	jal	80003fb2 <log_write>
      brelse(bp);
    800032ba:	8526                	mv	a0,s1
    800032bc:	b41ff0ef          	jal	80002dfc <brelse>
      return iget(dev, inum);
    800032c0:	0009059b          	sext.w	a1,s2
    800032c4:	8556                	mv	a0,s5
    800032c6:	e55ff0ef          	jal	8000311a <iget>
    800032ca:	74a2                	ld	s1,40(sp)
    800032cc:	7902                	ld	s2,32(sp)
    800032ce:	69e2                	ld	s3,24(sp)
    800032d0:	6a42                	ld	s4,16(sp)
    800032d2:	6aa2                	ld	s5,8(sp)
    800032d4:	6b02                	ld	s6,0(sp)
    800032d6:	b7d9                	j	8000329c <ialloc+0x80>

00000000800032d8 <iupdate>:
{
    800032d8:	1101                	addi	sp,sp,-32
    800032da:	ec06                	sd	ra,24(sp)
    800032dc:	e822                	sd	s0,16(sp)
    800032de:	e426                	sd	s1,8(sp)
    800032e0:	e04a                	sd	s2,0(sp)
    800032e2:	1000                	addi	s0,sp,32
    800032e4:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032e6:	415c                	lw	a5,4(a0)
    800032e8:	0047d79b          	srliw	a5,a5,0x4
    800032ec:	0001e597          	auipc	a1,0x1e
    800032f0:	89c5a583          	lw	a1,-1892(a1) # 80020b88 <sb+0x18>
    800032f4:	9dbd                	addw	a1,a1,a5
    800032f6:	4108                	lw	a0,0(a0)
    800032f8:	9fdff0ef          	jal	80002cf4 <bread>
    800032fc:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    800032fe:	05850793          	addi	a5,a0,88
    80003302:	40d8                	lw	a4,4(s1)
    80003304:	8b3d                	andi	a4,a4,15
    80003306:	071a                	slli	a4,a4,0x6
    80003308:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000330a:	04449703          	lh	a4,68(s1)
    8000330e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003312:	04649703          	lh	a4,70(s1)
    80003316:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000331a:	04849703          	lh	a4,72(s1)
    8000331e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003322:	04a49703          	lh	a4,74(s1)
    80003326:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000332a:	44f8                	lw	a4,76(s1)
    8000332c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000332e:	03400613          	li	a2,52
    80003332:	05048593          	addi	a1,s1,80
    80003336:	00c78513          	addi	a0,a5,12
    8000333a:	a0ffd0ef          	jal	80000d48 <memmove>
  log_write(bp);
    8000333e:	854a                	mv	a0,s2
    80003340:	473000ef          	jal	80003fb2 <log_write>
  brelse(bp);
    80003344:	854a                	mv	a0,s2
    80003346:	ab7ff0ef          	jal	80002dfc <brelse>
}
    8000334a:	60e2                	ld	ra,24(sp)
    8000334c:	6442                	ld	s0,16(sp)
    8000334e:	64a2                	ld	s1,8(sp)
    80003350:	6902                	ld	s2,0(sp)
    80003352:	6105                	addi	sp,sp,32
    80003354:	8082                	ret

0000000080003356 <idup>:
{
    80003356:	1101                	addi	sp,sp,-32
    80003358:	ec06                	sd	ra,24(sp)
    8000335a:	e822                	sd	s0,16(sp)
    8000335c:	e426                	sd	s1,8(sp)
    8000335e:	1000                	addi	s0,sp,32
    80003360:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003362:	0001e517          	auipc	a0,0x1e
    80003366:	82e50513          	addi	a0,a0,-2002 # 80020b90 <itable>
    8000336a:	8bffd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    8000336e:	449c                	lw	a5,8(s1)
    80003370:	2785                	addiw	a5,a5,1
    80003372:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003374:	0001e517          	auipc	a0,0x1e
    80003378:	81c50513          	addi	a0,a0,-2020 # 80020b90 <itable>
    8000337c:	935fd0ef          	jal	80000cb0 <release>
}
    80003380:	8526                	mv	a0,s1
    80003382:	60e2                	ld	ra,24(sp)
    80003384:	6442                	ld	s0,16(sp)
    80003386:	64a2                	ld	s1,8(sp)
    80003388:	6105                	addi	sp,sp,32
    8000338a:	8082                	ret

000000008000338c <ilock>:
{
    8000338c:	1101                	addi	sp,sp,-32
    8000338e:	ec06                	sd	ra,24(sp)
    80003390:	e822                	sd	s0,16(sp)
    80003392:	e426                	sd	s1,8(sp)
    80003394:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    80003396:	cd19                	beqz	a0,800033b4 <ilock+0x28>
    80003398:	84aa                	mv	s1,a0
    8000339a:	451c                	lw	a5,8(a0)
    8000339c:	00f05c63          	blez	a5,800033b4 <ilock+0x28>
  acquiresleep(&ip->lock);
    800033a0:	0541                	addi	a0,a0,16
    800033a2:	57f000ef          	jal	80004120 <acquiresleep>
  if (ip->valid == 0) {
    800033a6:	40bc                	lw	a5,64(s1)
    800033a8:	cf89                	beqz	a5,800033c2 <ilock+0x36>
}
    800033aa:	60e2                	ld	ra,24(sp)
    800033ac:	6442                	ld	s0,16(sp)
    800033ae:	64a2                	ld	s1,8(sp)
    800033b0:	6105                	addi	sp,sp,32
    800033b2:	8082                	ret
    800033b4:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800033b6:	00004517          	auipc	a0,0x4
    800033ba:	0b250513          	addi	a0,a0,178 # 80007468 <etext+0x468>
    800033be:	c76fd0ef          	jal	80000834 <panic>
    800033c2:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800033c4:	40dc                	lw	a5,4(s1)
    800033c6:	0047d79b          	srliw	a5,a5,0x4
    800033ca:	0001d597          	auipc	a1,0x1d
    800033ce:	7be5a583          	lw	a1,1982(a1) # 80020b88 <sb+0x18>
    800033d2:	9dbd                	addw	a1,a1,a5
    800033d4:	4088                	lw	a0,0(s1)
    800033d6:	91fff0ef          	jal	80002cf4 <bread>
    800033da:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    800033dc:	05850593          	addi	a1,a0,88
    800033e0:	40dc                	lw	a5,4(s1)
    800033e2:	8bbd                	andi	a5,a5,15
    800033e4:	079a                	slli	a5,a5,0x6
    800033e6:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800033e8:	00059783          	lh	a5,0(a1)
    800033ec:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800033f0:	00259783          	lh	a5,2(a1)
    800033f4:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800033f8:	00459783          	lh	a5,4(a1)
    800033fc:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003400:	00659783          	lh	a5,6(a1)
    80003404:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003408:	459c                	lw	a5,8(a1)
    8000340a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000340c:	03400613          	li	a2,52
    80003410:	05b1                	addi	a1,a1,12
    80003412:	05048513          	addi	a0,s1,80
    80003416:	933fd0ef          	jal	80000d48 <memmove>
    brelse(bp);
    8000341a:	854a                	mv	a0,s2
    8000341c:	9e1ff0ef          	jal	80002dfc <brelse>
    ip->valid = 1;
    80003420:	4785                	li	a5,1
    80003422:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003424:	04449783          	lh	a5,68(s1)
    80003428:	c399                	beqz	a5,8000342e <ilock+0xa2>
    8000342a:	6902                	ld	s2,0(sp)
    8000342c:	bfbd                	j	800033aa <ilock+0x1e>
      panic("ilock: no type");
    8000342e:	00004517          	auipc	a0,0x4
    80003432:	04250513          	addi	a0,a0,66 # 80007470 <etext+0x470>
    80003436:	bfefd0ef          	jal	80000834 <panic>

000000008000343a <iunlock>:
{
    8000343a:	1101                	addi	sp,sp,-32
    8000343c:	ec06                	sd	ra,24(sp)
    8000343e:	e822                	sd	s0,16(sp)
    80003440:	e426                	sd	s1,8(sp)
    80003442:	e04a                	sd	s2,0(sp)
    80003444:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003446:	c505                	beqz	a0,8000346e <iunlock+0x34>
    80003448:	84aa                	mv	s1,a0
    8000344a:	01050913          	addi	s2,a0,16
    8000344e:	854a                	mv	a0,s2
    80003450:	55d000ef          	jal	800041ac <holdingsleep>
    80003454:	cd09                	beqz	a0,8000346e <iunlock+0x34>
    80003456:	449c                	lw	a5,8(s1)
    80003458:	00f05b63          	blez	a5,8000346e <iunlock+0x34>
  releasesleep(&ip->lock);
    8000345c:	854a                	mv	a0,s2
    8000345e:	517000ef          	jal	80004174 <releasesleep>
}
    80003462:	60e2                	ld	ra,24(sp)
    80003464:	6442                	ld	s0,16(sp)
    80003466:	64a2                	ld	s1,8(sp)
    80003468:	6902                	ld	s2,0(sp)
    8000346a:	6105                	addi	sp,sp,32
    8000346c:	8082                	ret
    panic("iunlock");
    8000346e:	00004517          	auipc	a0,0x4
    80003472:	01250513          	addi	a0,a0,18 # 80007480 <etext+0x480>
    80003476:	bbefd0ef          	jal	80000834 <panic>

000000008000347a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000347a:	7179                	addi	sp,sp,-48
    8000347c:	f406                	sd	ra,40(sp)
    8000347e:	f022                	sd	s0,32(sp)
    80003480:	ec26                	sd	s1,24(sp)
    80003482:	e84a                	sd	s2,16(sp)
    80003484:	e44e                	sd	s3,8(sp)
    80003486:	1800                	addi	s0,sp,48
    80003488:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    8000348a:	05050493          	addi	s1,a0,80
    8000348e:	08050913          	addi	s2,a0,128
    80003492:	a021                	j	8000349a <itrunc+0x20>
    80003494:	0491                	addi	s1,s1,4
    80003496:	01248b63          	beq	s1,s2,800034ac <itrunc+0x32>
    if (ip->addrs[i]) {
    8000349a:	408c                	lw	a1,0(s1)
    8000349c:	dde5                	beqz	a1,80003494 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000349e:	0009a503          	lw	a0,0(s3)
    800034a2:	a47ff0ef          	jal	80002ee8 <bfree>
      ip->addrs[i] = 0;
    800034a6:	0004a023          	sw	zero,0(s1)
    800034aa:	b7ed                	j	80003494 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    800034ac:	0809a583          	lw	a1,128(s3)
    800034b0:	ed89                	bnez	a1,800034ca <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800034b2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800034b6:	854e                	mv	a0,s3
    800034b8:	e21ff0ef          	jal	800032d8 <iupdate>
}
    800034bc:	70a2                	ld	ra,40(sp)
    800034be:	7402                	ld	s0,32(sp)
    800034c0:	64e2                	ld	s1,24(sp)
    800034c2:	6942                	ld	s2,16(sp)
    800034c4:	69a2                	ld	s3,8(sp)
    800034c6:	6145                	addi	sp,sp,48
    800034c8:	8082                	ret
    800034ca:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800034cc:	0009a503          	lw	a0,0(s3)
    800034d0:	825ff0ef          	jal	80002cf4 <bread>
    800034d4:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    800034d6:	05850493          	addi	s1,a0,88
    800034da:	45850913          	addi	s2,a0,1112
    800034de:	a021                	j	800034e6 <itrunc+0x6c>
    800034e0:	0491                	addi	s1,s1,4
    800034e2:	01248963          	beq	s1,s2,800034f4 <itrunc+0x7a>
      if (a[j])
    800034e6:	408c                	lw	a1,0(s1)
    800034e8:	dde5                	beqz	a1,800034e0 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800034ea:	0009a503          	lw	a0,0(s3)
    800034ee:	9fbff0ef          	jal	80002ee8 <bfree>
    800034f2:	b7fd                	j	800034e0 <itrunc+0x66>
    brelse(bp);
    800034f4:	8552                	mv	a0,s4
    800034f6:	907ff0ef          	jal	80002dfc <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800034fa:	0809a583          	lw	a1,128(s3)
    800034fe:	0009a503          	lw	a0,0(s3)
    80003502:	9e7ff0ef          	jal	80002ee8 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003506:	0809a023          	sw	zero,128(s3)
    8000350a:	6a02                	ld	s4,0(sp)
    8000350c:	b75d                	j	800034b2 <itrunc+0x38>

000000008000350e <iput>:
{
    8000350e:	7179                	addi	sp,sp,-48
    80003510:	f406                	sd	ra,40(sp)
    80003512:	f022                	sd	s0,32(sp)
    80003514:	ec26                	sd	s1,24(sp)
    80003516:	1800                	addi	s0,sp,48
    80003518:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000351a:	0001d517          	auipc	a0,0x1d
    8000351e:	67650513          	addi	a0,a0,1654 # 80020b90 <itable>
    80003522:	f06fd0ef          	jal	80000c28 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003526:	449c                	lw	a5,8(s1)
    80003528:	4705                	li	a4,1
    8000352a:	00e78f63          	beq	a5,a4,80003548 <iput+0x3a>
  ip->ref--;
    8000352e:	37fd                	addiw	a5,a5,-1
    80003530:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003532:	0001d517          	auipc	a0,0x1d
    80003536:	65e50513          	addi	a0,a0,1630 # 80020b90 <itable>
    8000353a:	f76fd0ef          	jal	80000cb0 <release>
}
    8000353e:	70a2                	ld	ra,40(sp)
    80003540:	7402                	ld	s0,32(sp)
    80003542:	64e2                	ld	s1,24(sp)
    80003544:	6145                	addi	sp,sp,48
    80003546:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003548:	40b8                	lw	a4,64(s1)
    8000354a:	d375                	beqz	a4,8000352e <iput+0x20>
    8000354c:	e84a                	sd	s2,16(sp)
    8000354e:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    80003550:	0004aa03          	lw	s4,0(s1)
    80003554:	0044a903          	lw	s2,4(s1)
  if (last) {
    80003558:	04a49703          	lh	a4,74(s1)
    8000355c:	ef3d                	bnez	a4,800035da <iput+0xcc>
    8000355e:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    80003560:	01048793          	addi	a5,s1,16
    80003564:	89be                	mv	s3,a5
    80003566:	853e                	mv	a0,a5
    80003568:	3b9000ef          	jal	80004120 <acquiresleep>
    release(&itable.lock);
    8000356c:	0001d517          	auipc	a0,0x1d
    80003570:	62450513          	addi	a0,a0,1572 # 80020b90 <itable>
    80003574:	f3cfd0ef          	jal	80000cb0 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    80003578:	8526                	mv	a0,s1
    8000357a:	f01ff0ef          	jal	8000347a <itrunc>
    ip->valid = 0;
    8000357e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003582:	854e                	mv	a0,s3
    80003584:	3f1000ef          	jal	80004174 <releasesleep>
    acquire(&itable.lock);
    80003588:	0001d517          	auipc	a0,0x1d
    8000358c:	60850513          	addi	a0,a0,1544 # 80020b90 <itable>
    80003590:	e98fd0ef          	jal	80000c28 <acquire>
  ip->ref--;
    80003594:	449c                	lw	a5,8(s1)
    80003596:	37fd                	addiw	a5,a5,-1
    80003598:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000359a:	0001d517          	auipc	a0,0x1d
    8000359e:	5f650513          	addi	a0,a0,1526 # 80020b90 <itable>
    800035a2:	f0efd0ef          	jal	80000cb0 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800035a6:	0049579b          	srliw	a5,s2,0x4
    800035aa:	0001d597          	auipc	a1,0x1d
    800035ae:	5de5a583          	lw	a1,1502(a1) # 80020b88 <sb+0x18>
    800035b2:	9dbd                	addw	a1,a1,a5
    800035b4:	8552                	mv	a0,s4
    800035b6:	f3eff0ef          	jal	80002cf4 <bread>
    800035ba:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800035bc:	00f97793          	andi	a5,s2,15
  dip->type = 0;
    800035c0:	079a                	slli	a5,a5,0x6
    800035c2:	97aa                	add	a5,a5,a0
    800035c4:	04079c23          	sh	zero,88(a5)
  log_write(bp);
    800035c8:	1eb000ef          	jal	80003fb2 <log_write>
  brelse(bp);
    800035cc:	8526                	mv	a0,s1
    800035ce:	82fff0ef          	jal	80002dfc <brelse>
}
    800035d2:	6942                	ld	s2,16(sp)
    800035d4:	69a2                	ld	s3,8(sp)
    800035d6:	6a02                	ld	s4,0(sp)
    800035d8:	b79d                	j	8000353e <iput+0x30>
    800035da:	6942                	ld	s2,16(sp)
    800035dc:	6a02                	ld	s4,0(sp)
    800035de:	bf81                	j	8000352e <iput+0x20>

00000000800035e0 <iunlockput>:
{
    800035e0:	1101                	addi	sp,sp,-32
    800035e2:	ec06                	sd	ra,24(sp)
    800035e4:	e822                	sd	s0,16(sp)
    800035e6:	e426                	sd	s1,8(sp)
    800035e8:	1000                	addi	s0,sp,32
    800035ea:	84aa                	mv	s1,a0
  iunlock(ip);
    800035ec:	e4fff0ef          	jal	8000343a <iunlock>
  iput(ip);
    800035f0:	8526                	mv	a0,s1
    800035f2:	f1dff0ef          	jal	8000350e <iput>
}
    800035f6:	60e2                	ld	ra,24(sp)
    800035f8:	6442                	ld	s0,16(sp)
    800035fa:	64a2                	ld	s1,8(sp)
    800035fc:	6105                	addi	sp,sp,32
    800035fe:	8082                	ret

0000000080003600 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003600:	0001d717          	auipc	a4,0x1d
    80003604:	57c72703          	lw	a4,1404(a4) # 80020b7c <sb+0xc>
    80003608:	4785                	li	a5,1
    8000360a:	0ae7fe63          	bgeu	a5,a4,800036c6 <ireclaim+0xc6>
{
    8000360e:	7139                	addi	sp,sp,-64
    80003610:	fc06                	sd	ra,56(sp)
    80003612:	f822                	sd	s0,48(sp)
    80003614:	f426                	sd	s1,40(sp)
    80003616:	f04a                	sd	s2,32(sp)
    80003618:	ec4e                	sd	s3,24(sp)
    8000361a:	e852                	sd	s4,16(sp)
    8000361c:	e456                	sd	s5,8(sp)
    8000361e:	e05a                	sd	s6,0(sp)
    80003620:	0080                	addi	s0,sp,64
    80003622:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003624:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003626:	0001da17          	auipc	s4,0x1d
    8000362a:	54aa0a13          	addi	s4,s4,1354 # 80020b70 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    8000362e:	00004b17          	auipc	s6,0x4
    80003632:	e5ab0b13          	addi	s6,s6,-422 # 80007488 <etext+0x488>
    80003636:	a099                	j	8000367c <ireclaim+0x7c>
    80003638:	85ce                	mv	a1,s3
    8000363a:	855a                	mv	a0,s6
    8000363c:	ecffc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    80003640:	85ce                	mv	a1,s3
    80003642:	8556                	mv	a0,s5
    80003644:	ad7ff0ef          	jal	8000311a <iget>
    80003648:	89aa                	mv	s3,a0
    brelse(bp);
    8000364a:	854a                	mv	a0,s2
    8000364c:	fb0ff0ef          	jal	80002dfc <brelse>
    if (ip) {
    80003650:	00098f63          	beqz	s3,8000366e <ireclaim+0x6e>
      begin_op();
    80003654:	7b0000ef          	jal	80003e04 <begin_op>
      ilock(ip);
    80003658:	854e                	mv	a0,s3
    8000365a:	d33ff0ef          	jal	8000338c <ilock>
      iunlock(ip);
    8000365e:	854e                	mv	a0,s3
    80003660:	ddbff0ef          	jal	8000343a <iunlock>
      iput(ip);
    80003664:	854e                	mv	a0,s3
    80003666:	ea9ff0ef          	jal	8000350e <iput>
      end_op();
    8000366a:	027000ef          	jal	80003e90 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000366e:	0485                	addi	s1,s1,1
    80003670:	00ca2703          	lw	a4,12(s4)
    80003674:	0004879b          	sext.w	a5,s1
    80003678:	02e7fd63          	bgeu	a5,a4,800036b2 <ireclaim+0xb2>
    8000367c:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003680:	0044d593          	srli	a1,s1,0x4
    80003684:	018a2783          	lw	a5,24(s4)
    80003688:	9dbd                	addw	a1,a1,a5
    8000368a:	8556                	mv	a0,s5
    8000368c:	e68ff0ef          	jal	80002cf4 <bread>
    80003690:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003692:	05850793          	addi	a5,a0,88
    80003696:	00f9f713          	andi	a4,s3,15
    8000369a:	071a                	slli	a4,a4,0x6
    8000369c:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    8000369e:	00079703          	lh	a4,0(a5)
    800036a2:	c701                	beqz	a4,800036aa <ireclaim+0xaa>
    800036a4:	00679783          	lh	a5,6(a5)
    800036a8:	dbc1                	beqz	a5,80003638 <ireclaim+0x38>
    brelse(bp);
    800036aa:	854a                	mv	a0,s2
    800036ac:	f50ff0ef          	jal	80002dfc <brelse>
    if (ip) {
    800036b0:	bf7d                	j	8000366e <ireclaim+0x6e>
}
    800036b2:	70e2                	ld	ra,56(sp)
    800036b4:	7442                	ld	s0,48(sp)
    800036b6:	74a2                	ld	s1,40(sp)
    800036b8:	7902                	ld	s2,32(sp)
    800036ba:	69e2                	ld	s3,24(sp)
    800036bc:	6a42                	ld	s4,16(sp)
    800036be:	6aa2                	ld	s5,8(sp)
    800036c0:	6b02                	ld	s6,0(sp)
    800036c2:	6121                	addi	sp,sp,64
    800036c4:	8082                	ret
    800036c6:	8082                	ret

00000000800036c8 <fsinit>:
{
    800036c8:	1101                	addi	sp,sp,-32
    800036ca:	ec06                	sd	ra,24(sp)
    800036cc:	e822                	sd	s0,16(sp)
    800036ce:	e426                	sd	s1,8(sp)
    800036d0:	e04a                	sd	s2,0(sp)
    800036d2:	1000                	addi	s0,sp,32
    800036d4:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800036d6:	4585                	li	a1,1
    800036d8:	e1cff0ef          	jal	80002cf4 <bread>
    800036dc:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036de:	02000613          	li	a2,32
    800036e2:	05850593          	addi	a1,a0,88
    800036e6:	0001d517          	auipc	a0,0x1d
    800036ea:	48a50513          	addi	a0,a0,1162 # 80020b70 <sb>
    800036ee:	e5afd0ef          	jal	80000d48 <memmove>
  brelse(bp);
    800036f2:	8526                	mv	a0,s1
    800036f4:	f08ff0ef          	jal	80002dfc <brelse>
  if (sb.magic != FSMAGIC)
    800036f8:	0001d717          	auipc	a4,0x1d
    800036fc:	47872703          	lw	a4,1144(a4) # 80020b70 <sb>
    80003700:	102037b7          	lui	a5,0x10203
    80003704:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003708:	02f71263          	bne	a4,a5,8000372c <fsinit+0x64>
  initlog(dev, &sb);
    8000370c:	0001d597          	auipc	a1,0x1d
    80003710:	46458593          	addi	a1,a1,1124 # 80020b70 <sb>
    80003714:	854a                	mv	a0,s2
    80003716:	66c000ef          	jal	80003d82 <initlog>
  ireclaim(dev);
    8000371a:	854a                	mv	a0,s2
    8000371c:	ee5ff0ef          	jal	80003600 <ireclaim>
}
    80003720:	60e2                	ld	ra,24(sp)
    80003722:	6442                	ld	s0,16(sp)
    80003724:	64a2                	ld	s1,8(sp)
    80003726:	6902                	ld	s2,0(sp)
    80003728:	6105                	addi	sp,sp,32
    8000372a:	8082                	ret
    panic("invalid file system");
    8000372c:	00004517          	auipc	a0,0x4
    80003730:	d7c50513          	addi	a0,a0,-644 # 800074a8 <etext+0x4a8>
    80003734:	900fd0ef          	jal	80000834 <panic>

0000000080003738 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003738:	1141                	addi	sp,sp,-16
    8000373a:	e406                	sd	ra,8(sp)
    8000373c:	e022                	sd	s0,0(sp)
    8000373e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003740:	411c                	lw	a5,0(a0)
    80003742:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003744:	415c                	lw	a5,4(a0)
    80003746:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003748:	04451783          	lh	a5,68(a0)
    8000374c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003750:	04a51783          	lh	a5,74(a0)
    80003754:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003758:	04c56783          	lwu	a5,76(a0)
    8000375c:	e99c                	sd	a5,16(a1)
}
    8000375e:	60a2                	ld	ra,8(sp)
    80003760:	6402                	ld	s0,0(sp)
    80003762:	0141                	addi	sp,sp,16
    80003764:	8082                	ret

0000000080003766 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003766:	457c                	lw	a5,76(a0)
    80003768:	0ed7e663          	bltu	a5,a3,80003854 <readi+0xee>
{
    8000376c:	7159                	addi	sp,sp,-112
    8000376e:	f486                	sd	ra,104(sp)
    80003770:	f0a2                	sd	s0,96(sp)
    80003772:	eca6                	sd	s1,88(sp)
    80003774:	e0d2                	sd	s4,64(sp)
    80003776:	fc56                	sd	s5,56(sp)
    80003778:	f85a                	sd	s6,48(sp)
    8000377a:	f45e                	sd	s7,40(sp)
    8000377c:	1880                	addi	s0,sp,112
    8000377e:	8b2a                	mv	s6,a0
    80003780:	8bae                	mv	s7,a1
    80003782:	8a32                	mv	s4,a2
    80003784:	84b6                	mv	s1,a3
    80003786:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    80003788:	9f35                	addw	a4,a4,a3
    return 0;
    8000378a:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    8000378c:	0ad76b63          	bltu	a4,a3,80003842 <readi+0xdc>
    80003790:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    80003792:	00e7f463          	bgeu	a5,a4,8000379a <readi+0x34>
    n = ip->size - off;
    80003796:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    8000379a:	080a8b63          	beqz	s5,80003830 <readi+0xca>
    8000379e:	e8ca                	sd	s2,80(sp)
    800037a0:	f062                	sd	s8,32(sp)
    800037a2:	ec66                	sd	s9,24(sp)
    800037a4:	e86a                	sd	s10,16(sp)
    800037a6:	e46e                	sd	s11,8(sp)
    800037a8:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800037aa:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800037ae:	5c7d                	li	s8,-1
    800037b0:	a80d                	j	800037e2 <readi+0x7c>
    800037b2:	020d1d93          	slli	s11,s10,0x20
    800037b6:	020ddd93          	srli	s11,s11,0x20
    800037ba:	05890613          	addi	a2,s2,88
    800037be:	86ee                	mv	a3,s11
    800037c0:	963e                	add	a2,a2,a5
    800037c2:	85d2                	mv	a1,s4
    800037c4:	855e                	mv	a0,s7
    800037c6:	c3ffe0ef          	jal	80002404 <either_copyout>
    800037ca:	05850363          	beq	a0,s8,80003810 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800037ce:	854a                	mv	a0,s2
    800037d0:	e2cff0ef          	jal	80002dfc <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800037d4:	013d09bb          	addw	s3,s10,s3
    800037d8:	009d04bb          	addw	s1,s10,s1
    800037dc:	9a6e                	add	s4,s4,s11
    800037de:	0559f363          	bgeu	s3,s5,80003824 <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    800037e2:	00a4d59b          	srliw	a1,s1,0xa
    800037e6:	855a                	mv	a0,s6
    800037e8:	873ff0ef          	jal	8000305a <bmap>
    800037ec:	85aa                	mv	a1,a0
    if (addr == 0)
    800037ee:	c139                	beqz	a0,80003834 <readi+0xce>
    bp = bread(ip->dev, addr);
    800037f0:	000b2503          	lw	a0,0(s6)
    800037f4:	d00ff0ef          	jal	80002cf4 <bread>
    800037f8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    800037fa:	3ff4f793          	andi	a5,s1,1023
    800037fe:	40fc873b          	subw	a4,s9,a5
    80003802:	413a86bb          	subw	a3,s5,s3
    80003806:	8d3a                	mv	s10,a4
    80003808:	fae6f5e3          	bgeu	a3,a4,800037b2 <readi+0x4c>
    8000380c:	8d36                	mv	s10,a3
    8000380e:	b755                	j	800037b2 <readi+0x4c>
      brelse(bp);
    80003810:	854a                	mv	a0,s2
    80003812:	deaff0ef          	jal	80002dfc <brelse>
      tot = -1;
    80003816:	59fd                	li	s3,-1
      break;
    80003818:	6946                	ld	s2,80(sp)
    8000381a:	7c02                	ld	s8,32(sp)
    8000381c:	6ce2                	ld	s9,24(sp)
    8000381e:	6d42                	ld	s10,16(sp)
    80003820:	6da2                	ld	s11,8(sp)
    80003822:	a831                	j	8000383e <readi+0xd8>
    80003824:	6946                	ld	s2,80(sp)
    80003826:	7c02                	ld	s8,32(sp)
    80003828:	6ce2                	ld	s9,24(sp)
    8000382a:	6d42                	ld	s10,16(sp)
    8000382c:	6da2                	ld	s11,8(sp)
    8000382e:	a801                	j	8000383e <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003830:	89d6                	mv	s3,s5
    80003832:	a031                	j	8000383e <readi+0xd8>
    80003834:	6946                	ld	s2,80(sp)
    80003836:	7c02                	ld	s8,32(sp)
    80003838:	6ce2                	ld	s9,24(sp)
    8000383a:	6d42                	ld	s10,16(sp)
    8000383c:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000383e:	854e                	mv	a0,s3
    80003840:	69a6                	ld	s3,72(sp)
}
    80003842:	70a6                	ld	ra,104(sp)
    80003844:	7406                	ld	s0,96(sp)
    80003846:	64e6                	ld	s1,88(sp)
    80003848:	6a06                	ld	s4,64(sp)
    8000384a:	7ae2                	ld	s5,56(sp)
    8000384c:	7b42                	ld	s6,48(sp)
    8000384e:	7ba2                	ld	s7,40(sp)
    80003850:	6165                	addi	sp,sp,112
    80003852:	8082                	ret
    return 0;
    80003854:	4501                	li	a0,0
}
    80003856:	8082                	ret

0000000080003858 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003858:	457c                	lw	a5,76(a0)
    8000385a:	0ed7ee63          	bltu	a5,a3,80003956 <writei+0xfe>
{
    8000385e:	7159                	addi	sp,sp,-112
    80003860:	f486                	sd	ra,104(sp)
    80003862:	f0a2                	sd	s0,96(sp)
    80003864:	e8ca                	sd	s2,80(sp)
    80003866:	e0d2                	sd	s4,64(sp)
    80003868:	fc56                	sd	s5,56(sp)
    8000386a:	f85a                	sd	s6,48(sp)
    8000386c:	f45e                	sd	s7,40(sp)
    8000386e:	1880                	addi	s0,sp,112
    80003870:	8aaa                	mv	s5,a0
    80003872:	8bae                	mv	s7,a1
    80003874:	8a32                	mv	s4,a2
    80003876:	8936                	mv	s2,a3
    80003878:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    8000387a:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    8000387e:	00043737          	lui	a4,0x43
    80003882:	0cf76c63          	bltu	a4,a5,8000395a <writei+0x102>
    80003886:	0cd7ea63          	bltu	a5,a3,8000395a <writei+0x102>
    8000388a:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    8000388c:	0a0b0d63          	beqz	s6,80003946 <writei+0xee>
    80003890:	eca6                	sd	s1,88(sp)
    80003892:	f062                	sd	s8,32(sp)
    80003894:	ec66                	sd	s9,24(sp)
    80003896:	e86a                	sd	s10,16(sp)
    80003898:	e46e                	sd	s11,8(sp)
    8000389a:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    8000389c:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800038a0:	5c7d                	li	s8,-1
    800038a2:	a825                	j	800038da <writei+0x82>
    800038a4:	020d1d93          	slli	s11,s10,0x20
    800038a8:	020ddd93          	srli	s11,s11,0x20
    800038ac:	05848513          	addi	a0,s1,88
    800038b0:	86ee                	mv	a3,s11
    800038b2:	8652                	mv	a2,s4
    800038b4:	85de                	mv	a1,s7
    800038b6:	953e                	add	a0,a0,a5
    800038b8:	b99fe0ef          	jal	80002450 <either_copyin>
    800038bc:	05850663          	beq	a0,s8,80003908 <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    800038c0:	8526                	mv	a0,s1
    800038c2:	6f0000ef          	jal	80003fb2 <log_write>
    brelse(bp);
    800038c6:	8526                	mv	a0,s1
    800038c8:	d34ff0ef          	jal	80002dfc <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800038cc:	013d09bb          	addw	s3,s10,s3
    800038d0:	012d093b          	addw	s2,s10,s2
    800038d4:	9a6e                	add	s4,s4,s11
    800038d6:	0369ff63          	bgeu	s3,s6,80003914 <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    800038da:	00a9559b          	srliw	a1,s2,0xa
    800038de:	8556                	mv	a0,s5
    800038e0:	f7aff0ef          	jal	8000305a <bmap>
    800038e4:	85aa                	mv	a1,a0
    if (addr == 0)
    800038e6:	c51d                	beqz	a0,80003914 <writei+0xbc>
    bp = bread(ip->dev, addr);
    800038e8:	000aa503          	lw	a0,0(s5)
    800038ec:	c08ff0ef          	jal	80002cf4 <bread>
    800038f0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    800038f2:	3ff97793          	andi	a5,s2,1023
    800038f6:	40fc873b          	subw	a4,s9,a5
    800038fa:	413b06bb          	subw	a3,s6,s3
    800038fe:	8d3a                	mv	s10,a4
    80003900:	fae6f2e3          	bgeu	a3,a4,800038a4 <writei+0x4c>
    80003904:	8d36                	mv	s10,a3
    80003906:	bf79                	j	800038a4 <writei+0x4c>
      log_write(bp);
    80003908:	8526                	mv	a0,s1
    8000390a:	6a8000ef          	jal	80003fb2 <log_write>
      brelse(bp);
    8000390e:	8526                	mv	a0,s1
    80003910:	cecff0ef          	jal	80002dfc <brelse>
  }

  if (off > ip->size)
    80003914:	04caa783          	lw	a5,76(s5)
    80003918:	0327f963          	bgeu	a5,s2,8000394a <writei+0xf2>
    ip->size = off;
    8000391c:	052aa623          	sw	s2,76(s5)
    80003920:	64e6                	ld	s1,88(sp)
    80003922:	7c02                	ld	s8,32(sp)
    80003924:	6ce2                	ld	s9,24(sp)
    80003926:	6d42                	ld	s10,16(sp)
    80003928:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000392a:	8556                	mv	a0,s5
    8000392c:	9adff0ef          	jal	800032d8 <iupdate>

  return tot;
    80003930:	854e                	mv	a0,s3
    80003932:	69a6                	ld	s3,72(sp)
}
    80003934:	70a6                	ld	ra,104(sp)
    80003936:	7406                	ld	s0,96(sp)
    80003938:	6946                	ld	s2,80(sp)
    8000393a:	6a06                	ld	s4,64(sp)
    8000393c:	7ae2                	ld	s5,56(sp)
    8000393e:	7b42                	ld	s6,48(sp)
    80003940:	7ba2                	ld	s7,40(sp)
    80003942:	6165                	addi	sp,sp,112
    80003944:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003946:	89da                	mv	s3,s6
    80003948:	b7cd                	j	8000392a <writei+0xd2>
    8000394a:	64e6                	ld	s1,88(sp)
    8000394c:	7c02                	ld	s8,32(sp)
    8000394e:	6ce2                	ld	s9,24(sp)
    80003950:	6d42                	ld	s10,16(sp)
    80003952:	6da2                	ld	s11,8(sp)
    80003954:	bfd9                	j	8000392a <writei+0xd2>
    return -1;
    80003956:	557d                	li	a0,-1
}
    80003958:	8082                	ret
    return -1;
    8000395a:	557d                	li	a0,-1
    8000395c:	bfe1                	j	80003934 <writei+0xdc>

000000008000395e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000395e:	1141                	addi	sp,sp,-16
    80003960:	e406                	sd	ra,8(sp)
    80003962:	e022                	sd	s0,0(sp)
    80003964:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003966:	4639                	li	a2,14
    80003968:	c54fd0ef          	jal	80000dbc <strncmp>
}
    8000396c:	60a2                	ld	ra,8(sp)
    8000396e:	6402                	ld	s0,0(sp)
    80003970:	0141                	addi	sp,sp,16
    80003972:	8082                	ret

0000000080003974 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003974:	711d                	addi	sp,sp,-96
    80003976:	ec86                	sd	ra,88(sp)
    80003978:	e8a2                	sd	s0,80(sp)
    8000397a:	e4a6                	sd	s1,72(sp)
    8000397c:	e0ca                	sd	s2,64(sp)
    8000397e:	fc4e                	sd	s3,56(sp)
    80003980:	f852                	sd	s4,48(sp)
    80003982:	f456                	sd	s5,40(sp)
    80003984:	f05a                	sd	s6,32(sp)
    80003986:	ec5e                	sd	s7,24(sp)
    80003988:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    8000398a:	04451703          	lh	a4,68(a0)
    8000398e:	4785                	li	a5,1
    80003990:	00f71f63          	bne	a4,a5,800039ae <dirlookup+0x3a>
    80003994:	892a                	mv	s2,a0
    80003996:	8aae                	mv	s5,a1
    80003998:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    8000399a:	457c                	lw	a5,76(a0)
    8000399c:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000399e:	fa040a13          	addi	s4,s0,-96
    800039a2:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    800039a4:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800039a8:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800039aa:	e39d                	bnez	a5,800039d0 <dirlookup+0x5c>
    800039ac:	a8b9                	j	80003a0a <dirlookup+0x96>
    panic("dirlookup not DIR");
    800039ae:	00004517          	auipc	a0,0x4
    800039b2:	b1250513          	addi	a0,a0,-1262 # 800074c0 <etext+0x4c0>
    800039b6:	e7ffc0ef          	jal	80000834 <panic>
      panic("dirlookup read");
    800039ba:	00004517          	auipc	a0,0x4
    800039be:	b1e50513          	addi	a0,a0,-1250 # 800074d8 <etext+0x4d8>
    800039c2:	e73fc0ef          	jal	80000834 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800039c6:	24c1                	addiw	s1,s1,16
    800039c8:	04c92783          	lw	a5,76(s2)
    800039cc:	02f4fe63          	bgeu	s1,a5,80003a08 <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039d0:	874e                	mv	a4,s3
    800039d2:	86a6                	mv	a3,s1
    800039d4:	8652                	mv	a2,s4
    800039d6:	4581                	li	a1,0
    800039d8:	854a                	mv	a0,s2
    800039da:	d8dff0ef          	jal	80003766 <readi>
    800039de:	fd351ee3          	bne	a0,s3,800039ba <dirlookup+0x46>
    if (de.inum == 0)
    800039e2:	fa045783          	lhu	a5,-96(s0)
    800039e6:	d3e5                	beqz	a5,800039c6 <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    800039e8:	85da                	mv	a1,s6
    800039ea:	8556                	mv	a0,s5
    800039ec:	f73ff0ef          	jal	8000395e <namecmp>
    800039f0:	f979                	bnez	a0,800039c6 <dirlookup+0x52>
      if (poff)
    800039f2:	000b8463          	beqz	s7,800039fa <dirlookup+0x86>
        *poff = off;
    800039f6:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    800039fa:	fa045583          	lhu	a1,-96(s0)
    800039fe:	00092503          	lw	a0,0(s2)
    80003a02:	f18ff0ef          	jal	8000311a <iget>
    80003a06:	a011                	j	80003a0a <dirlookup+0x96>
  return 0;
    80003a08:	4501                	li	a0,0
}
    80003a0a:	60e6                	ld	ra,88(sp)
    80003a0c:	6446                	ld	s0,80(sp)
    80003a0e:	64a6                	ld	s1,72(sp)
    80003a10:	6906                	ld	s2,64(sp)
    80003a12:	79e2                	ld	s3,56(sp)
    80003a14:	7a42                	ld	s4,48(sp)
    80003a16:	7aa2                	ld	s5,40(sp)
    80003a18:	7b02                	ld	s6,32(sp)
    80003a1a:	6be2                	ld	s7,24(sp)
    80003a1c:	6125                	addi	sp,sp,96
    80003a1e:	8082                	ret

0000000080003a20 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003a20:	711d                	addi	sp,sp,-96
    80003a22:	ec86                	sd	ra,88(sp)
    80003a24:	e8a2                	sd	s0,80(sp)
    80003a26:	e4a6                	sd	s1,72(sp)
    80003a28:	e0ca                	sd	s2,64(sp)
    80003a2a:	fc4e                	sd	s3,56(sp)
    80003a2c:	f852                	sd	s4,48(sp)
    80003a2e:	f456                	sd	s5,40(sp)
    80003a30:	f05a                	sd	s6,32(sp)
    80003a32:	ec5e                	sd	s7,24(sp)
    80003a34:	e862                	sd	s8,16(sp)
    80003a36:	e466                	sd	s9,8(sp)
    80003a38:	e06a                	sd	s10,0(sp)
    80003a3a:	1080                	addi	s0,sp,96
    80003a3c:	84aa                	mv	s1,a0
    80003a3e:	8b2e                	mv	s6,a1
    80003a40:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003a42:	00054703          	lbu	a4,0(a0)
    80003a46:	02f00793          	li	a5,47
    80003a4a:	00f70f63          	beq	a4,a5,80003a68 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003a4e:	efbfd0ef          	jal	80001948 <myproc>
    80003a52:	15053503          	ld	a0,336(a0)
    80003a56:	901ff0ef          	jal	80003356 <idup>
    80003a5a:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003a5c:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    80003a60:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003a62:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003a64:	4b85                	li	s7,1
    80003a66:	a07d                	j	80003b14 <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    80003a68:	4585                	li	a1,1
    80003a6a:	852e                	mv	a0,a1
    80003a6c:	eaeff0ef          	jal	8000311a <iget>
    80003a70:	8a2a                	mv	s4,a0
    80003a72:	b7ed                	j	80003a5c <namex+0x3c>
      iunlockput(ip);
    80003a74:	8552                	mv	a0,s4
    80003a76:	b6bff0ef          	jal	800035e0 <iunlockput>
      return 0;
    80003a7a:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003a7c:	8552                	mv	a0,s4
    80003a7e:	60e6                	ld	ra,88(sp)
    80003a80:	6446                	ld	s0,80(sp)
    80003a82:	64a6                	ld	s1,72(sp)
    80003a84:	6906                	ld	s2,64(sp)
    80003a86:	79e2                	ld	s3,56(sp)
    80003a88:	7a42                	ld	s4,48(sp)
    80003a8a:	7aa2                	ld	s5,40(sp)
    80003a8c:	7b02                	ld	s6,32(sp)
    80003a8e:	6be2                	ld	s7,24(sp)
    80003a90:	6c42                	ld	s8,16(sp)
    80003a92:	6ca2                	ld	s9,8(sp)
    80003a94:	6d02                	ld	s10,0(sp)
    80003a96:	6125                	addi	sp,sp,96
    80003a98:	8082                	ret
      iunlockput(ip);
    80003a9a:	8552                	mv	a0,s4
    80003a9c:	b45ff0ef          	jal	800035e0 <iunlockput>
      return 0;
    80003aa0:	4a01                	li	s4,0
    80003aa2:	bfe9                	j	80003a7c <namex+0x5c>
      iunlock(ip);
    80003aa4:	8552                	mv	a0,s4
    80003aa6:	995ff0ef          	jal	8000343a <iunlock>
      return ip;
    80003aaa:	bfc9                	j	80003a7c <namex+0x5c>
      iunlockput(ip);
    80003aac:	8552                	mv	a0,s4
    80003aae:	b33ff0ef          	jal	800035e0 <iunlockput>
      return 0;
    80003ab2:	8a4a                	mv	s4,s2
    80003ab4:	b7e1                	j	80003a7c <namex+0x5c>
  while (*path != '/' && *path != 0)
    80003ab6:	8926                	mv	s2,s1
  len = path - s;
    80003ab8:	4d01                	li	s10,0
    80003aba:	4601                	li	a2,0
    memmove(name, s, len);
    80003abc:	2601                	sext.w	a2,a2
    80003abe:	85a6                	mv	a1,s1
    80003ac0:	8556                	mv	a0,s5
    80003ac2:	a86fd0ef          	jal	80000d48 <memmove>
    name[len] = 0;
    80003ac6:	9d56                	add	s10,s10,s5
    80003ac8:	000d0023          	sb	zero,0(s10)
  while (*path == '/')
    80003acc:	00094783          	lbu	a5,0(s2)
    80003ad0:	09379b63          	bne	a5,s3,80003b66 <namex+0x146>
    80003ad4:	84ca                	mv	s1,s2
    path++;
    80003ad6:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003ad8:	0004c783          	lbu	a5,0(s1)
    80003adc:	ff378de3          	beq	a5,s3,80003ad6 <namex+0xb6>
    ilock(ip);
    80003ae0:	8552                	mv	a0,s4
    80003ae2:	8abff0ef          	jal	8000338c <ilock>
    if (ip->type != T_DIR) {
    80003ae6:	044a1783          	lh	a5,68(s4)
    80003aea:	f97795e3          	bne	a5,s7,80003a74 <namex+0x54>
    if (ip->nlink == 0) {
    80003aee:	04aa1783          	lh	a5,74(s4)
    80003af2:	d7c5                	beqz	a5,80003a9a <namex+0x7a>
    if (nameiparent && *path == '\0') {
    80003af4:	000b0563          	beqz	s6,80003afe <namex+0xde>
    80003af8:	0004c783          	lbu	a5,0(s1)
    80003afc:	d7c5                	beqz	a5,80003aa4 <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003afe:	4601                	li	a2,0
    80003b00:	85d6                	mv	a1,s5
    80003b02:	8552                	mv	a0,s4
    80003b04:	e71ff0ef          	jal	80003974 <dirlookup>
    80003b08:	892a                	mv	s2,a0
    80003b0a:	d14d                	beqz	a0,80003aac <namex+0x8c>
    iunlockput(ip);
    80003b0c:	8552                	mv	a0,s4
    80003b0e:	ad3ff0ef          	jal	800035e0 <iunlockput>
    ip = next;
    80003b12:	8a4a                	mv	s4,s2
  while (*path == '/')
    80003b14:	0004c783          	lbu	a5,0(s1)
    80003b18:	01379763          	bne	a5,s3,80003b26 <namex+0x106>
    path++;
    80003b1c:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003b1e:	0004c783          	lbu	a5,0(s1)
    80003b22:	ff378de3          	beq	a5,s3,80003b1c <namex+0xfc>
  if (*path == 0)
    80003b26:	c7a1                	beqz	a5,80003b6e <namex+0x14e>
  while (*path != '/' && *path != 0)
    80003b28:	0004c783          	lbu	a5,0(s1)
    80003b2c:	fd178713          	addi	a4,a5,-47
    80003b30:	d359                	beqz	a4,80003ab6 <namex+0x96>
    80003b32:	d3d1                	beqz	a5,80003ab6 <namex+0x96>
    80003b34:	8926                	mv	s2,s1
    path++;
    80003b36:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    80003b38:	00094783          	lbu	a5,0(s2)
    80003b3c:	fd178713          	addi	a4,a5,-47
    80003b40:	c311                	beqz	a4,80003b44 <namex+0x124>
    80003b42:	fbf5                	bnez	a5,80003b36 <namex+0x116>
  len = path - s;
    80003b44:	40990633          	sub	a2,s2,s1
    80003b48:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80003b4c:	f7ac58e3          	bge	s8,s10,80003abc <namex+0x9c>
    memmove(name, s, DIRSIZ);
    80003b50:	8666                	mv	a2,s9
    80003b52:	85a6                	mv	a1,s1
    80003b54:	8556                	mv	a0,s5
    80003b56:	9f2fd0ef          	jal	80000d48 <memmove>
  while (*path == '/')
    80003b5a:	00094783          	lbu	a5,0(s2)
    80003b5e:	84ca                	mv	s1,s2
    80003b60:	f7378be3          	beq	a5,s3,80003ad6 <namex+0xb6>
    80003b64:	bfb5                	j	80003ae0 <namex+0xc0>
  while ((path = skipelem(path, name)) != 0) {
    80003b66:	00090463          	beqz	s2,80003b6e <namex+0x14e>
    80003b6a:	84ca                	mv	s1,s2
    80003b6c:	bf95                	j	80003ae0 <namex+0xc0>
  if (nameiparent) {
    80003b6e:	f00b07e3          	beqz	s6,80003a7c <namex+0x5c>
    iput(ip);
    80003b72:	8552                	mv	a0,s4
    80003b74:	99bff0ef          	jal	8000350e <iput>
    return 0;
    80003b78:	4a01                	li	s4,0
    80003b7a:	b709                	j	80003a7c <namex+0x5c>

0000000080003b7c <dirlink>:
{
    80003b7c:	715d                	addi	sp,sp,-80
    80003b7e:	e486                	sd	ra,72(sp)
    80003b80:	e0a2                	sd	s0,64(sp)
    80003b82:	f84a                	sd	s2,48(sp)
    80003b84:	ec56                	sd	s5,24(sp)
    80003b86:	e85a                	sd	s6,16(sp)
    80003b88:	0880                	addi	s0,sp,80
    80003b8a:	892a                	mv	s2,a0
    80003b8c:	8aae                	mv	s5,a1
    80003b8e:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003b90:	4601                	li	a2,0
    80003b92:	de3ff0ef          	jal	80003974 <dirlookup>
    80003b96:	ed1d                	bnez	a0,80003bd4 <dirlink+0x58>
    80003b98:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003b9a:	04c92483          	lw	s1,76(s2)
    80003b9e:	c4b9                	beqz	s1,80003bec <dirlink+0x70>
    80003ba0:	f44e                	sd	s3,40(sp)
    80003ba2:	f052                	sd	s4,32(sp)
    80003ba4:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ba6:	fb040a13          	addi	s4,s0,-80
    80003baa:	49c1                	li	s3,16
    80003bac:	874e                	mv	a4,s3
    80003bae:	86a6                	mv	a3,s1
    80003bb0:	8652                	mv	a2,s4
    80003bb2:	4581                	li	a1,0
    80003bb4:	854a                	mv	a0,s2
    80003bb6:	bb1ff0ef          	jal	80003766 <readi>
    80003bba:	03351163          	bne	a0,s3,80003bdc <dirlink+0x60>
    if (de.inum == 0)
    80003bbe:	fb045783          	lhu	a5,-80(s0)
    80003bc2:	c39d                	beqz	a5,80003be8 <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003bc4:	24c1                	addiw	s1,s1,16
    80003bc6:	04c92783          	lw	a5,76(s2)
    80003bca:	fef4e1e3          	bltu	s1,a5,80003bac <dirlink+0x30>
    80003bce:	79a2                	ld	s3,40(sp)
    80003bd0:	7a02                	ld	s4,32(sp)
    80003bd2:	a829                	j	80003bec <dirlink+0x70>
    iput(ip);
    80003bd4:	93bff0ef          	jal	8000350e <iput>
    return -1;
    80003bd8:	557d                	li	a0,-1
    80003bda:	a83d                	j	80003c18 <dirlink+0x9c>
      panic("dirlink read");
    80003bdc:	00004517          	auipc	a0,0x4
    80003be0:	90c50513          	addi	a0,a0,-1780 # 800074e8 <etext+0x4e8>
    80003be4:	c51fc0ef          	jal	80000834 <panic>
    80003be8:	79a2                	ld	s3,40(sp)
    80003bea:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003bec:	4639                	li	a2,14
    80003bee:	85d6                	mv	a1,s5
    80003bf0:	fb240513          	addi	a0,s0,-78
    80003bf4:	a02fd0ef          	jal	80000df6 <strncpy>
  de.inum = inum;
    80003bf8:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bfc:	4741                	li	a4,16
    80003bfe:	86a6                	mv	a3,s1
    80003c00:	fb040613          	addi	a2,s0,-80
    80003c04:	4581                	li	a1,0
    80003c06:	854a                	mv	a0,s2
    80003c08:	c51ff0ef          	jal	80003858 <writei>
    80003c0c:	1541                	addi	a0,a0,-16
    80003c0e:	00a03533          	snez	a0,a0
    80003c12:	40a0053b          	negw	a0,a0
    80003c16:	74e2                	ld	s1,56(sp)
}
    80003c18:	60a6                	ld	ra,72(sp)
    80003c1a:	6406                	ld	s0,64(sp)
    80003c1c:	7942                	ld	s2,48(sp)
    80003c1e:	6ae2                	ld	s5,24(sp)
    80003c20:	6b42                	ld	s6,16(sp)
    80003c22:	6161                	addi	sp,sp,80
    80003c24:	8082                	ret

0000000080003c26 <namei>:

struct inode *
namei(char *path)
{
    80003c26:	1101                	addi	sp,sp,-32
    80003c28:	ec06                	sd	ra,24(sp)
    80003c2a:	e822                	sd	s0,16(sp)
    80003c2c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003c2e:	fe040613          	addi	a2,s0,-32
    80003c32:	4581                	li	a1,0
    80003c34:	dedff0ef          	jal	80003a20 <namex>
}
    80003c38:	60e2                	ld	ra,24(sp)
    80003c3a:	6442                	ld	s0,16(sp)
    80003c3c:	6105                	addi	sp,sp,32
    80003c3e:	8082                	ret

0000000080003c40 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003c40:	1141                	addi	sp,sp,-16
    80003c42:	e406                	sd	ra,8(sp)
    80003c44:	e022                	sd	s0,0(sp)
    80003c46:	0800                	addi	s0,sp,16
    80003c48:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003c4a:	4585                	li	a1,1
    80003c4c:	dd5ff0ef          	jal	80003a20 <namex>
}
    80003c50:	60a2                	ld	ra,8(sp)
    80003c52:	6402                	ld	s0,0(sp)
    80003c54:	0141                	addi	sp,sp,16
    80003c56:	8082                	ret

0000000080003c58 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003c58:	1101                	addi	sp,sp,-32
    80003c5a:	ec06                	sd	ra,24(sp)
    80003c5c:	e822                	sd	s0,16(sp)
    80003c5e:	e426                	sd	s1,8(sp)
    80003c60:	e04a                	sd	s2,0(sp)
    80003c62:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003c64:	0001f917          	auipc	s2,0x1f
    80003c68:	9d490913          	addi	s2,s2,-1580 # 80022638 <log>
    80003c6c:	01892583          	lw	a1,24(s2)
    80003c70:	02492503          	lw	a0,36(s2)
    80003c74:	880ff0ef          	jal	80002cf4 <bread>
    80003c78:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003c7a:	02c92603          	lw	a2,44(s2)
    80003c7e:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003c80:	00c05f63          	blez	a2,80003c9e <write_head+0x46>
    80003c84:	0001f717          	auipc	a4,0x1f
    80003c88:	9e470713          	addi	a4,a4,-1564 # 80022668 <log+0x30>
    80003c8c:	87aa                	mv	a5,a0
    80003c8e:	060a                	slli	a2,a2,0x2
    80003c90:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003c92:	4314                	lw	a3,0(a4)
    80003c94:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003c96:	0711                	addi	a4,a4,4
    80003c98:	0791                	addi	a5,a5,4
    80003c9a:	fec79ce3          	bne	a5,a2,80003c92 <write_head+0x3a>
  }
  bwrite(buf);
    80003c9e:	8526                	mv	a0,s1
    80003ca0:	92aff0ef          	jal	80002dca <bwrite>
  brelse(buf);
    80003ca4:	8526                	mv	a0,s1
    80003ca6:	956ff0ef          	jal	80002dfc <brelse>
}
    80003caa:	60e2                	ld	ra,24(sp)
    80003cac:	6442                	ld	s0,16(sp)
    80003cae:	64a2                	ld	s1,8(sp)
    80003cb0:	6902                	ld	s2,0(sp)
    80003cb2:	6105                	addi	sp,sp,32
    80003cb4:	8082                	ret

0000000080003cb6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cb6:	0001f797          	auipc	a5,0x1f
    80003cba:	9ae7a783          	lw	a5,-1618(a5) # 80022664 <log+0x2c>
    80003cbe:	0cf05163          	blez	a5,80003d80 <install_trans+0xca>
{
    80003cc2:	715d                	addi	sp,sp,-80
    80003cc4:	e486                	sd	ra,72(sp)
    80003cc6:	e0a2                	sd	s0,64(sp)
    80003cc8:	fc26                	sd	s1,56(sp)
    80003cca:	f84a                	sd	s2,48(sp)
    80003ccc:	f44e                	sd	s3,40(sp)
    80003cce:	f052                	sd	s4,32(sp)
    80003cd0:	ec56                	sd	s5,24(sp)
    80003cd2:	e85a                	sd	s6,16(sp)
    80003cd4:	e45e                	sd	s7,8(sp)
    80003cd6:	e062                	sd	s8,0(sp)
    80003cd8:	0880                	addi	s0,sp,80
    80003cda:	8b2a                	mv	s6,a0
    80003cdc:	0001fa97          	auipc	s5,0x1f
    80003ce0:	98ca8a93          	addi	s5,s5,-1652 # 80022668 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ce4:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003ce6:	00004c17          	auipc	s8,0x4
    80003cea:	812c0c13          	addi	s8,s8,-2030 # 800074f8 <etext+0x4f8>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003cee:	0001fa17          	auipc	s4,0x1f
    80003cf2:	94aa0a13          	addi	s4,s4,-1718 # 80022638 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003cf6:	40000b93          	li	s7,1024
    80003cfa:	a025                	j	80003d22 <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003cfc:	000aa603          	lw	a2,0(s5)
    80003d00:	85ce                	mv	a1,s3
    80003d02:	8562                	mv	a0,s8
    80003d04:	807fc0ef          	jal	8000050a <printk>
    80003d08:	a839                	j	80003d26 <install_trans+0x70>
    brelse(lbuf);
    80003d0a:	854a                	mv	a0,s2
    80003d0c:	8f0ff0ef          	jal	80002dfc <brelse>
    brelse(dbuf);
    80003d10:	8526                	mv	a0,s1
    80003d12:	8eaff0ef          	jal	80002dfc <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d16:	2985                	addiw	s3,s3,1
    80003d18:	0a91                	addi	s5,s5,4
    80003d1a:	02ca2783          	lw	a5,44(s4)
    80003d1e:	04f9d563          	bge	s3,a5,80003d68 <install_trans+0xb2>
    if (recovering) {
    80003d22:	fc0b1de3          	bnez	s6,80003cfc <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003d26:	018a2583          	lw	a1,24(s4)
    80003d2a:	013585bb          	addw	a1,a1,s3
    80003d2e:	2585                	addiw	a1,a1,1
    80003d30:	024a2503          	lw	a0,36(s4)
    80003d34:	fc1fe0ef          	jal	80002cf4 <bread>
    80003d38:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003d3a:	000aa583          	lw	a1,0(s5)
    80003d3e:	024a2503          	lw	a0,36(s4)
    80003d42:	fb3fe0ef          	jal	80002cf4 <bread>
    80003d46:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003d48:	865e                	mv	a2,s7
    80003d4a:	05890593          	addi	a1,s2,88
    80003d4e:	05850513          	addi	a0,a0,88
    80003d52:	ff7fc0ef          	jal	80000d48 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003d56:	8526                	mv	a0,s1
    80003d58:	872ff0ef          	jal	80002dca <bwrite>
    if (recovering == 0)
    80003d5c:	fa0b17e3          	bnez	s6,80003d0a <install_trans+0x54>
      bunpin(dbuf);
    80003d60:	8526                	mv	a0,s1
    80003d62:	952ff0ef          	jal	80002eb4 <bunpin>
    80003d66:	b755                	j	80003d0a <install_trans+0x54>
}
    80003d68:	60a6                	ld	ra,72(sp)
    80003d6a:	6406                	ld	s0,64(sp)
    80003d6c:	74e2                	ld	s1,56(sp)
    80003d6e:	7942                	ld	s2,48(sp)
    80003d70:	79a2                	ld	s3,40(sp)
    80003d72:	7a02                	ld	s4,32(sp)
    80003d74:	6ae2                	ld	s5,24(sp)
    80003d76:	6b42                	ld	s6,16(sp)
    80003d78:	6ba2                	ld	s7,8(sp)
    80003d7a:	6c02                	ld	s8,0(sp)
    80003d7c:	6161                	addi	sp,sp,80
    80003d7e:	8082                	ret
    80003d80:	8082                	ret

0000000080003d82 <initlog>:
{
    80003d82:	7179                	addi	sp,sp,-48
    80003d84:	f406                	sd	ra,40(sp)
    80003d86:	f022                	sd	s0,32(sp)
    80003d88:	ec26                	sd	s1,24(sp)
    80003d8a:	e84a                	sd	s2,16(sp)
    80003d8c:	e44e                	sd	s3,8(sp)
    80003d8e:	1800                	addi	s0,sp,48
    80003d90:	84aa                	mv	s1,a0
    80003d92:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003d94:	0001f917          	auipc	s2,0x1f
    80003d98:	8a490913          	addi	s2,s2,-1884 # 80022638 <log>
    80003d9c:	00003597          	auipc	a1,0x3
    80003da0:	77c58593          	addi	a1,a1,1916 # 80007518 <etext+0x518>
    80003da4:	854a                	mv	a0,s2
    80003da6:	e03fc0ef          	jal	80000ba8 <initlock>
  log.start = sb->logstart;
    80003daa:	0149a583          	lw	a1,20(s3)
    80003dae:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003db2:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003db6:	8526                	mv	a0,s1
    80003db8:	f3dfe0ef          	jal	80002cf4 <bread>
  log.lh.n = lh->n;
    80003dbc:	4d30                	lw	a2,88(a0)
    80003dbe:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003dc2:	00c05f63          	blez	a2,80003de0 <initlog+0x5e>
    80003dc6:	87aa                	mv	a5,a0
    80003dc8:	0001f717          	auipc	a4,0x1f
    80003dcc:	8a070713          	addi	a4,a4,-1888 # 80022668 <log+0x30>
    80003dd0:	060a                	slli	a2,a2,0x2
    80003dd2:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003dd4:	4ff4                	lw	a3,92(a5)
    80003dd6:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003dd8:	0791                	addi	a5,a5,4
    80003dda:	0711                	addi	a4,a4,4
    80003ddc:	fec79ce3          	bne	a5,a2,80003dd4 <initlog+0x52>
  brelse(buf);
    80003de0:	81cff0ef          	jal	80002dfc <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003de4:	4505                	li	a0,1
    80003de6:	ed1ff0ef          	jal	80003cb6 <install_trans>
  log.lh.n = 0;
    80003dea:	0001f797          	auipc	a5,0x1f
    80003dee:	8607ad23          	sw	zero,-1926(a5) # 80022664 <log+0x2c>
  write_head(); // clear the log
    80003df2:	e67ff0ef          	jal	80003c58 <write_head>
}
    80003df6:	70a2                	ld	ra,40(sp)
    80003df8:	7402                	ld	s0,32(sp)
    80003dfa:	64e2                	ld	s1,24(sp)
    80003dfc:	6942                	ld	s2,16(sp)
    80003dfe:	69a2                	ld	s3,8(sp)
    80003e00:	6145                	addi	sp,sp,48
    80003e02:	8082                	ret

0000000080003e04 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003e04:	1101                	addi	sp,sp,-32
    80003e06:	ec06                	sd	ra,24(sp)
    80003e08:	e822                	sd	s0,16(sp)
    80003e0a:	e426                	sd	s1,8(sp)
    80003e0c:	e04a                	sd	s2,0(sp)
    80003e0e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003e10:	0001f517          	auipc	a0,0x1f
    80003e14:	82850513          	addi	a0,a0,-2008 # 80022638 <log>
    80003e18:	e11fc0ef          	jal	80000c28 <acquire>
  while (1) {
    if (log.committing) {
    80003e1c:	0001f497          	auipc	s1,0x1f
    80003e20:	81c48493          	addi	s1,s1,-2020 # 80022638 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003e24:	4979                	li	s2,30
    80003e26:	a821                	j	80003e3e <begin_op+0x3a>
      sleep_prepare(&log);
    80003e28:	8526                	mv	a0,s1
    80003e2a:	a48fe0ef          	jal	80002072 <sleep_prepare>
      release(&log.lock);
    80003e2e:	8526                	mv	a0,s1
    80003e30:	e81fc0ef          	jal	80000cb0 <release>
      sleep();
    80003e34:	a7afe0ef          	jal	800020ae <sleep>
      acquire(&log.lock);
    80003e38:	8526                	mv	a0,s1
    80003e3a:	deffc0ef          	jal	80000c28 <acquire>
    if (log.committing) {
    80003e3e:	509c                	lw	a5,32(s1)
    80003e40:	f7e5                	bnez	a5,80003e28 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003e42:	4cd8                	lw	a4,28(s1)
    80003e44:	2705                	addiw	a4,a4,1
    80003e46:	0027179b          	slliw	a5,a4,0x2
    80003e4a:	9fb9                	addw	a5,a5,a4
    80003e4c:	0017979b          	slliw	a5,a5,0x1
    80003e50:	54d4                	lw	a3,44(s1)
    80003e52:	9fb5                	addw	a5,a5,a3
    80003e54:	00f95e63          	bge	s2,a5,80003e70 <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003e58:	8526                	mv	a0,s1
    80003e5a:	a18fe0ef          	jal	80002072 <sleep_prepare>
      release(&log.lock);
    80003e5e:	8526                	mv	a0,s1
    80003e60:	e51fc0ef          	jal	80000cb0 <release>
      sleep();
    80003e64:	a4afe0ef          	jal	800020ae <sleep>
      acquire(&log.lock);
    80003e68:	8526                	mv	a0,s1
    80003e6a:	dbffc0ef          	jal	80000c28 <acquire>
    80003e6e:	bfc1                	j	80003e3e <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003e70:	0001e797          	auipc	a5,0x1e
    80003e74:	7ee7a223          	sw	a4,2020(a5) # 80022654 <log+0x1c>
      release(&log.lock);
    80003e78:	0001e517          	auipc	a0,0x1e
    80003e7c:	7c050513          	addi	a0,a0,1984 # 80022638 <log>
    80003e80:	e31fc0ef          	jal	80000cb0 <release>
      break;
    }
  }
}
    80003e84:	60e2                	ld	ra,24(sp)
    80003e86:	6442                	ld	s0,16(sp)
    80003e88:	64a2                	ld	s1,8(sp)
    80003e8a:	6902                	ld	s2,0(sp)
    80003e8c:	6105                	addi	sp,sp,32
    80003e8e:	8082                	ret

0000000080003e90 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003e90:	7139                	addi	sp,sp,-64
    80003e92:	fc06                	sd	ra,56(sp)
    80003e94:	f822                	sd	s0,48(sp)
    80003e96:	f426                	sd	s1,40(sp)
    80003e98:	f04a                	sd	s2,32(sp)
    80003e9a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003e9c:	0001e497          	auipc	s1,0x1e
    80003ea0:	79c48493          	addi	s1,s1,1948 # 80022638 <log>
    80003ea4:	8526                	mv	a0,s1
    80003ea6:	d83fc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003eaa:	4cdc                	lw	a5,28(s1)
    80003eac:	37fd                	addiw	a5,a5,-1
    80003eae:	893e                	mv	s2,a5
    80003eb0:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003eb2:	509c                	lw	a5,32(s1)
    80003eb4:	e3b1                	bnez	a5,80003ef8 <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003eb6:	04091a63          	bnez	s2,80003f0a <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    80003eba:	0001e497          	auipc	s1,0x1e
    80003ebe:	77e48493          	addi	s1,s1,1918 # 80022638 <log>
    80003ec2:	4785                	li	a5,1
    80003ec4:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003ec6:	8526                	mv	a0,s1
    80003ec8:	de9fc0ef          	jal	80000cb0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003ecc:	54dc                	lw	a5,44(s1)
    80003ece:	06f04063          	bgtz	a5,80003f2e <end_op+0x9e>
    acquire(&log.lock);
    80003ed2:	0001e497          	auipc	s1,0x1e
    80003ed6:	76648493          	addi	s1,s1,1894 # 80022638 <log>
    80003eda:	8526                	mv	a0,s1
    80003edc:	d4dfc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003ee0:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003ee4:	549c                	lw	a5,40(s1)
    80003ee6:	2785                	addiw	a5,a5,1
    80003ee8:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003eea:	8526                	mv	a0,s1
    80003eec:	9f2fe0ef          	jal	800020de <wakeup>
    release(&log.lock);
    80003ef0:	8526                	mv	a0,s1
    80003ef2:	dbffc0ef          	jal	80000cb0 <release>
}
    80003ef6:	a035                	j	80003f22 <end_op+0x92>
    80003ef8:	ec4e                	sd	s3,24(sp)
    80003efa:	e852                	sd	s4,16(sp)
    80003efc:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003efe:	00003517          	auipc	a0,0x3
    80003f02:	62250513          	addi	a0,a0,1570 # 80007520 <etext+0x520>
    80003f06:	92ffc0ef          	jal	80000834 <panic>
    wakeup(&log);
    80003f0a:	0001e517          	auipc	a0,0x1e
    80003f0e:	72e50513          	addi	a0,a0,1838 # 80022638 <log>
    80003f12:	9ccfe0ef          	jal	800020de <wakeup>
  release(&log.lock);
    80003f16:	0001e517          	auipc	a0,0x1e
    80003f1a:	72250513          	addi	a0,a0,1826 # 80022638 <log>
    80003f1e:	d93fc0ef          	jal	80000cb0 <release>
}
    80003f22:	70e2                	ld	ra,56(sp)
    80003f24:	7442                	ld	s0,48(sp)
    80003f26:	74a2                	ld	s1,40(sp)
    80003f28:	7902                	ld	s2,32(sp)
    80003f2a:	6121                	addi	sp,sp,64
    80003f2c:	8082                	ret
    80003f2e:	ec4e                	sd	s3,24(sp)
    80003f30:	e852                	sd	s4,16(sp)
    80003f32:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f34:	0001ea97          	auipc	s5,0x1e
    80003f38:	734a8a93          	addi	s5,s5,1844 # 80022668 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003f3c:	0001ea17          	auipc	s4,0x1e
    80003f40:	6fca0a13          	addi	s4,s4,1788 # 80022638 <log>
    80003f44:	018a2583          	lw	a1,24(s4)
    80003f48:	012585bb          	addw	a1,a1,s2
    80003f4c:	2585                	addiw	a1,a1,1
    80003f4e:	024a2503          	lw	a0,36(s4)
    80003f52:	da3fe0ef          	jal	80002cf4 <bread>
    80003f56:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003f58:	000aa583          	lw	a1,0(s5)
    80003f5c:	024a2503          	lw	a0,36(s4)
    80003f60:	d95fe0ef          	jal	80002cf4 <bread>
    80003f64:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003f66:	40000613          	li	a2,1024
    80003f6a:	05850593          	addi	a1,a0,88
    80003f6e:	05848513          	addi	a0,s1,88
    80003f72:	dd7fc0ef          	jal	80000d48 <memmove>
    bwrite(to); // write the log
    80003f76:	8526                	mv	a0,s1
    80003f78:	e53fe0ef          	jal	80002dca <bwrite>
    brelse(from);
    80003f7c:	854e                	mv	a0,s3
    80003f7e:	e7ffe0ef          	jal	80002dfc <brelse>
    brelse(to);
    80003f82:	8526                	mv	a0,s1
    80003f84:	e79fe0ef          	jal	80002dfc <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f88:	2905                	addiw	s2,s2,1
    80003f8a:	0a91                	addi	s5,s5,4
    80003f8c:	02ca2783          	lw	a5,44(s4)
    80003f90:	faf94ae3          	blt	s2,a5,80003f44 <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80003f94:	cc5ff0ef          	jal	80003c58 <write_head>
    install_trans(0); // Now install writes to home locations
    80003f98:	4501                	li	a0,0
    80003f9a:	d1dff0ef          	jal	80003cb6 <install_trans>
    log.lh.n = 0;
    80003f9e:	0001e797          	auipc	a5,0x1e
    80003fa2:	6c07a323          	sw	zero,1734(a5) # 80022664 <log+0x2c>
    write_head(); // Erase the transaction from the log
    80003fa6:	cb3ff0ef          	jal	80003c58 <write_head>
    80003faa:	69e2                	ld	s3,24(sp)
    80003fac:	6a42                	ld	s4,16(sp)
    80003fae:	6aa2                	ld	s5,8(sp)
    80003fb0:	b70d                	j	80003ed2 <end_op+0x42>

0000000080003fb2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003fb2:	1101                	addi	sp,sp,-32
    80003fb4:	ec06                	sd	ra,24(sp)
    80003fb6:	e822                	sd	s0,16(sp)
    80003fb8:	e426                	sd	s1,8(sp)
    80003fba:	1000                	addi	s0,sp,32
    80003fbc:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003fbe:	0001e517          	auipc	a0,0x1e
    80003fc2:	67a50513          	addi	a0,a0,1658 # 80022638 <log>
    80003fc6:	c63fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003fca:	0001e617          	auipc	a2,0x1e
    80003fce:	69a62603          	lw	a2,1690(a2) # 80022664 <log+0x2c>
    80003fd2:	47f5                	li	a5,29
    80003fd4:	04c7cd63          	blt	a5,a2,8000402e <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003fd8:	0001e797          	auipc	a5,0x1e
    80003fdc:	67c7a783          	lw	a5,1660(a5) # 80022654 <log+0x1c>
    80003fe0:	04f05d63          	blez	a5,8000403a <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003fe4:	4781                	li	a5,0
    80003fe6:	06c05063          	blez	a2,80004046 <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    80003fea:	44cc                	lw	a1,12(s1)
    80003fec:	0001e717          	auipc	a4,0x1e
    80003ff0:	67c70713          	addi	a4,a4,1660 # 80022668 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003ff4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80003ff6:	4314                	lw	a3,0(a4)
    80003ff8:	04b68763          	beq	a3,a1,80004046 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80003ffc:	2785                	addiw	a5,a5,1
    80003ffe:	0711                	addi	a4,a4,4
    80004000:	fef61be3          	bne	a2,a5,80003ff6 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004004:	060a                	slli	a2,a2,0x2
    80004006:	02060613          	addi	a2,a2,32
    8000400a:	0001e797          	auipc	a5,0x1e
    8000400e:	62e78793          	addi	a5,a5,1582 # 80022638 <log>
    80004012:	97b2                	add	a5,a5,a2
    80004014:	44d8                	lw	a4,12(s1)
    80004016:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80004018:	8526                	mv	a0,s1
    8000401a:	e67fe0ef          	jal	80002e80 <bpin>
    log.lh.n++;
    8000401e:	0001e717          	auipc	a4,0x1e
    80004022:	61a70713          	addi	a4,a4,1562 # 80022638 <log>
    80004026:	575c                	lw	a5,44(a4)
    80004028:	2785                	addiw	a5,a5,1
    8000402a:	d75c                	sw	a5,44(a4)
    8000402c:	a815                	j	80004060 <log_write+0xae>
    panic("too big a transaction");
    8000402e:	00003517          	auipc	a0,0x3
    80004032:	50250513          	addi	a0,a0,1282 # 80007530 <etext+0x530>
    80004036:	ffefc0ef          	jal	80000834 <panic>
    panic("log_write outside of trans");
    8000403a:	00003517          	auipc	a0,0x3
    8000403e:	50e50513          	addi	a0,a0,1294 # 80007548 <etext+0x548>
    80004042:	ff2fc0ef          	jal	80000834 <panic>
  log.lh.block[i] = b->blockno;
    80004046:	00279693          	slli	a3,a5,0x2
    8000404a:	02068693          	addi	a3,a3,32
    8000404e:	0001e717          	auipc	a4,0x1e
    80004052:	5ea70713          	addi	a4,a4,1514 # 80022638 <log>
    80004056:	9736                	add	a4,a4,a3
    80004058:	44d4                	lw	a3,12(s1)
    8000405a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    8000405c:	faf60ee3          	beq	a2,a5,80004018 <log_write+0x66>
  }
  release(&log.lock);
    80004060:	0001e517          	auipc	a0,0x1e
    80004064:	5d850513          	addi	a0,a0,1496 # 80022638 <log>
    80004068:	c49fc0ef          	jal	80000cb0 <release>
}
    8000406c:	60e2                	ld	ra,24(sp)
    8000406e:	6442                	ld	s0,16(sp)
    80004070:	64a2                	ld	s1,8(sp)
    80004072:	6105                	addi	sp,sp,32
    80004074:	8082                	ret

0000000080004076 <sys_sync>:

uint64
sys_sync(void)
{
    80004076:	1101                	addi	sp,sp,-32
    80004078:	ec06                	sd	ra,24(sp)
    8000407a:	e822                	sd	s0,16(sp)
    8000407c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000407e:	0001e517          	auipc	a0,0x1e
    80004082:	5ba50513          	addi	a0,a0,1466 # 80022638 <log>
    80004086:	ba3fc0ef          	jal	80000c28 <acquire>
  if (log.committing || log.outstanding > 0) {
    8000408a:	0001e797          	auipc	a5,0x1e
    8000408e:	5ce7a783          	lw	a5,1486(a5) # 80022658 <log+0x20>
    80004092:	e799                	bnez	a5,800040a0 <sys_sync+0x2a>
    80004094:	0001e797          	auipc	a5,0x1e
    80004098:	5c07a783          	lw	a5,1472(a5) # 80022654 <log+0x1c>
    8000409c:	02f05c63          	blez	a5,800040d4 <sys_sync+0x5e>
    800040a0:	e426                	sd	s1,8(sp)
    800040a2:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    800040a4:	0001e917          	auipc	s2,0x1e
    800040a8:	5bc92903          	lw	s2,1468(s2) # 80022660 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    800040ac:	0001e497          	auipc	s1,0x1e
    800040b0:	58c48493          	addi	s1,s1,1420 # 80022638 <log>
    800040b4:	8526                	mv	a0,s1
    800040b6:	fbdfd0ef          	jal	80002072 <sleep_prepare>
      release(&log.lock);
    800040ba:	8526                	mv	a0,s1
    800040bc:	bf5fc0ef          	jal	80000cb0 <release>
      sleep();
    800040c0:	feffd0ef          	jal	800020ae <sleep>
      acquire(&log.lock);
    800040c4:	8526                	mv	a0,s1
    800040c6:	b63fc0ef          	jal	80000c28 <acquire>
    while (log.ncommit < n) {
    800040ca:	549c                	lw	a5,40(s1)
    800040cc:	fef954e3          	bge	s2,a5,800040b4 <sys_sync+0x3e>
    800040d0:	64a2                	ld	s1,8(sp)
    800040d2:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    800040d4:	0001e517          	auipc	a0,0x1e
    800040d8:	56450513          	addi	a0,a0,1380 # 80022638 <log>
    800040dc:	bd5fc0ef          	jal	80000cb0 <release>
  return 0;
}
    800040e0:	4501                	li	a0,0
    800040e2:	60e2                	ld	ra,24(sp)
    800040e4:	6442                	ld	s0,16(sp)
    800040e6:	6105                	addi	sp,sp,32
    800040e8:	8082                	ret

00000000800040ea <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800040ea:	1101                	addi	sp,sp,-32
    800040ec:	ec06                	sd	ra,24(sp)
    800040ee:	e822                	sd	s0,16(sp)
    800040f0:	e426                	sd	s1,8(sp)
    800040f2:	e04a                	sd	s2,0(sp)
    800040f4:	1000                	addi	s0,sp,32
    800040f6:	84aa                	mv	s1,a0
    800040f8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800040fa:	00003597          	auipc	a1,0x3
    800040fe:	46e58593          	addi	a1,a1,1134 # 80007568 <etext+0x568>
    80004102:	0521                	addi	a0,a0,8
    80004104:	aa5fc0ef          	jal	80000ba8 <initlock>
  lk->name = name;
    80004108:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000410c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004110:	0204a423          	sw	zero,40(s1)
}
    80004114:	60e2                	ld	ra,24(sp)
    80004116:	6442                	ld	s0,16(sp)
    80004118:	64a2                	ld	s1,8(sp)
    8000411a:	6902                	ld	s2,0(sp)
    8000411c:	6105                	addi	sp,sp,32
    8000411e:	8082                	ret

0000000080004120 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004120:	1101                	addi	sp,sp,-32
    80004122:	ec06                	sd	ra,24(sp)
    80004124:	e822                	sd	s0,16(sp)
    80004126:	e426                	sd	s1,8(sp)
    80004128:	e04a                	sd	s2,0(sp)
    8000412a:	1000                	addi	s0,sp,32
    8000412c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000412e:	00850913          	addi	s2,a0,8
    80004132:	854a                	mv	a0,s2
    80004134:	af5fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80004138:	409c                	lw	a5,0(s1)
    8000413a:	cf91                	beqz	a5,80004156 <acquiresleep+0x36>
    sleep_prepare(lk);
    8000413c:	8526                	mv	a0,s1
    8000413e:	f35fd0ef          	jal	80002072 <sleep_prepare>
    release(&lk->lk);
    80004142:	854a                	mv	a0,s2
    80004144:	b6dfc0ef          	jal	80000cb0 <release>
    sleep();
    80004148:	f67fd0ef          	jal	800020ae <sleep>
    acquire(&lk->lk);
    8000414c:	854a                	mv	a0,s2
    8000414e:	adbfc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80004152:	409c                	lw	a5,0(s1)
    80004154:	f7e5                	bnez	a5,8000413c <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004156:	4785                	li	a5,1
    80004158:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000415a:	feefd0ef          	jal	80001948 <myproc>
    8000415e:	591c                	lw	a5,48(a0)
    80004160:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004162:	854a                	mv	a0,s2
    80004164:	b4dfc0ef          	jal	80000cb0 <release>
}
    80004168:	60e2                	ld	ra,24(sp)
    8000416a:	6442                	ld	s0,16(sp)
    8000416c:	64a2                	ld	s1,8(sp)
    8000416e:	6902                	ld	s2,0(sp)
    80004170:	6105                	addi	sp,sp,32
    80004172:	8082                	ret

0000000080004174 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004174:	1101                	addi	sp,sp,-32
    80004176:	ec06                	sd	ra,24(sp)
    80004178:	e822                	sd	s0,16(sp)
    8000417a:	e426                	sd	s1,8(sp)
    8000417c:	e04a                	sd	s2,0(sp)
    8000417e:	1000                	addi	s0,sp,32
    80004180:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004182:	00850913          	addi	s2,a0,8
    80004186:	854a                	mv	a0,s2
    80004188:	aa1fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    8000418c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004190:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004194:	8526                	mv	a0,s1
    80004196:	f49fd0ef          	jal	800020de <wakeup>
  release(&lk->lk);
    8000419a:	854a                	mv	a0,s2
    8000419c:	b15fc0ef          	jal	80000cb0 <release>
}
    800041a0:	60e2                	ld	ra,24(sp)
    800041a2:	6442                	ld	s0,16(sp)
    800041a4:	64a2                	ld	s1,8(sp)
    800041a6:	6902                	ld	s2,0(sp)
    800041a8:	6105                	addi	sp,sp,32
    800041aa:	8082                	ret

00000000800041ac <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800041ac:	7179                	addi	sp,sp,-48
    800041ae:	f406                	sd	ra,40(sp)
    800041b0:	f022                	sd	s0,32(sp)
    800041b2:	ec26                	sd	s1,24(sp)
    800041b4:	e84a                	sd	s2,16(sp)
    800041b6:	1800                	addi	s0,sp,48
    800041b8:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    800041ba:	00850913          	addi	s2,a0,8
    800041be:	854a                	mv	a0,s2
    800041c0:	a69fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800041c4:	409c                	lw	a5,0(s1)
    800041c6:	ef81                	bnez	a5,800041de <holdingsleep+0x32>
    800041c8:	4481                	li	s1,0
  release(&lk->lk);
    800041ca:	854a                	mv	a0,s2
    800041cc:	ae5fc0ef          	jal	80000cb0 <release>
  return r;
}
    800041d0:	8526                	mv	a0,s1
    800041d2:	70a2                	ld	ra,40(sp)
    800041d4:	7402                	ld	s0,32(sp)
    800041d6:	64e2                	ld	s1,24(sp)
    800041d8:	6942                	ld	s2,16(sp)
    800041da:	6145                	addi	sp,sp,48
    800041dc:	8082                	ret
    800041de:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800041e0:	0284a983          	lw	s3,40(s1)
    800041e4:	f64fd0ef          	jal	80001948 <myproc>
    800041e8:	5904                	lw	s1,48(a0)
    800041ea:	413484b3          	sub	s1,s1,s3
    800041ee:	0014b493          	seqz	s1,s1
    800041f2:	69a2                	ld	s3,8(sp)
    800041f4:	bfd9                	j	800041ca <holdingsleep+0x1e>

00000000800041f6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800041f6:	1141                	addi	sp,sp,-16
    800041f8:	e406                	sd	ra,8(sp)
    800041fa:	e022                	sd	s0,0(sp)
    800041fc:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800041fe:	00003597          	auipc	a1,0x3
    80004202:	37a58593          	addi	a1,a1,890 # 80007578 <etext+0x578>
    80004206:	0001e517          	auipc	a0,0x1e
    8000420a:	57a50513          	addi	a0,a0,1402 # 80022780 <ftable>
    8000420e:	99bfc0ef          	jal	80000ba8 <initlock>
}
    80004212:	60a2                	ld	ra,8(sp)
    80004214:	6402                	ld	s0,0(sp)
    80004216:	0141                	addi	sp,sp,16
    80004218:	8082                	ret

000000008000421a <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    8000421a:	1101                	addi	sp,sp,-32
    8000421c:	ec06                	sd	ra,24(sp)
    8000421e:	e822                	sd	s0,16(sp)
    80004220:	e426                	sd	s1,8(sp)
    80004222:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004224:	0001e517          	auipc	a0,0x1e
    80004228:	55c50513          	addi	a0,a0,1372 # 80022780 <ftable>
    8000422c:	9fdfc0ef          	jal	80000c28 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004230:	0001e497          	auipc	s1,0x1e
    80004234:	56848493          	addi	s1,s1,1384 # 80022798 <ftable+0x18>
    80004238:	0001f717          	auipc	a4,0x1f
    8000423c:	50070713          	addi	a4,a4,1280 # 80023738 <disk>
    if (f->ref == 0) {
    80004240:	40dc                	lw	a5,4(s1)
    80004242:	cf89                	beqz	a5,8000425c <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004244:	02848493          	addi	s1,s1,40
    80004248:	fee49ce3          	bne	s1,a4,80004240 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000424c:	0001e517          	auipc	a0,0x1e
    80004250:	53450513          	addi	a0,a0,1332 # 80022780 <ftable>
    80004254:	a5dfc0ef          	jal	80000cb0 <release>
  return 0;
    80004258:	4481                	li	s1,0
    8000425a:	a809                	j	8000426c <filealloc+0x52>
      f->ref = 1;
    8000425c:	4785                	li	a5,1
    8000425e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004260:	0001e517          	auipc	a0,0x1e
    80004264:	52050513          	addi	a0,a0,1312 # 80022780 <ftable>
    80004268:	a49fc0ef          	jal	80000cb0 <release>
}
    8000426c:	8526                	mv	a0,s1
    8000426e:	60e2                	ld	ra,24(sp)
    80004270:	6442                	ld	s0,16(sp)
    80004272:	64a2                	ld	s1,8(sp)
    80004274:	6105                	addi	sp,sp,32
    80004276:	8082                	ret

0000000080004278 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004278:	1101                	addi	sp,sp,-32
    8000427a:	ec06                	sd	ra,24(sp)
    8000427c:	e822                	sd	s0,16(sp)
    8000427e:	e426                	sd	s1,8(sp)
    80004280:	1000                	addi	s0,sp,32
    80004282:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004284:	0001e517          	auipc	a0,0x1e
    80004288:	4fc50513          	addi	a0,a0,1276 # 80022780 <ftable>
    8000428c:	99dfc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    80004290:	40dc                	lw	a5,4(s1)
    80004292:	02f05063          	blez	a5,800042b2 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004296:	2785                	addiw	a5,a5,1
    80004298:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000429a:	0001e517          	auipc	a0,0x1e
    8000429e:	4e650513          	addi	a0,a0,1254 # 80022780 <ftable>
    800042a2:	a0ffc0ef          	jal	80000cb0 <release>
  return f;
}
    800042a6:	8526                	mv	a0,s1
    800042a8:	60e2                	ld	ra,24(sp)
    800042aa:	6442                	ld	s0,16(sp)
    800042ac:	64a2                	ld	s1,8(sp)
    800042ae:	6105                	addi	sp,sp,32
    800042b0:	8082                	ret
    panic("filedup");
    800042b2:	00003517          	auipc	a0,0x3
    800042b6:	2ce50513          	addi	a0,a0,718 # 80007580 <etext+0x580>
    800042ba:	d7afc0ef          	jal	80000834 <panic>

00000000800042be <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800042be:	7139                	addi	sp,sp,-64
    800042c0:	fc06                	sd	ra,56(sp)
    800042c2:	f822                	sd	s0,48(sp)
    800042c4:	f426                	sd	s1,40(sp)
    800042c6:	0080                	addi	s0,sp,64
    800042c8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800042ca:	0001e517          	auipc	a0,0x1e
    800042ce:	4b650513          	addi	a0,a0,1206 # 80022780 <ftable>
    800042d2:	957fc0ef          	jal	80000c28 <acquire>
  if (f->ref < 1)
    800042d6:	40dc                	lw	a5,4(s1)
    800042d8:	04f05a63          	blez	a5,8000432c <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    800042dc:	37fd                	addiw	a5,a5,-1
    800042de:	c0dc                	sw	a5,4(s1)
    800042e0:	06f04063          	bgtz	a5,80004340 <fileclose+0x82>
    800042e4:	f04a                	sd	s2,32(sp)
    800042e6:	ec4e                	sd	s3,24(sp)
    800042e8:	e852                	sd	s4,16(sp)
    800042ea:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800042ec:	0004a903          	lw	s2,0(s1)
    800042f0:	0094c783          	lbu	a5,9(s1)
    800042f4:	89be                	mv	s3,a5
    800042f6:	689c                	ld	a5,16(s1)
    800042f8:	8a3e                	mv	s4,a5
    800042fa:	6c9c                	ld	a5,24(s1)
    800042fc:	8abe                	mv	s5,a5
  f->ref = 0;
    800042fe:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004302:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004306:	0001e517          	auipc	a0,0x1e
    8000430a:	47a50513          	addi	a0,a0,1146 # 80022780 <ftable>
    8000430e:	9a3fc0ef          	jal	80000cb0 <release>

  if (ff.type == FD_PIPE) {
    80004312:	4785                	li	a5,1
    80004314:	04f90163          	beq	s2,a5,80004356 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    80004318:	ffe9079b          	addiw	a5,s2,-2
    8000431c:	4705                	li	a4,1
    8000431e:	04f77563          	bgeu	a4,a5,80004368 <fileclose+0xaa>
    80004322:	7902                	ld	s2,32(sp)
    80004324:	69e2                	ld	s3,24(sp)
    80004326:	6a42                	ld	s4,16(sp)
    80004328:	6aa2                	ld	s5,8(sp)
    8000432a:	a00d                	j	8000434c <fileclose+0x8e>
    8000432c:	f04a                	sd	s2,32(sp)
    8000432e:	ec4e                	sd	s3,24(sp)
    80004330:	e852                	sd	s4,16(sp)
    80004332:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004334:	00003517          	auipc	a0,0x3
    80004338:	25450513          	addi	a0,a0,596 # 80007588 <etext+0x588>
    8000433c:	cf8fc0ef          	jal	80000834 <panic>
    release(&ftable.lock);
    80004340:	0001e517          	auipc	a0,0x1e
    80004344:	44050513          	addi	a0,a0,1088 # 80022780 <ftable>
    80004348:	969fc0ef          	jal	80000cb0 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000434c:	70e2                	ld	ra,56(sp)
    8000434e:	7442                	ld	s0,48(sp)
    80004350:	74a2                	ld	s1,40(sp)
    80004352:	6121                	addi	sp,sp,64
    80004354:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004356:	85ce                	mv	a1,s3
    80004358:	8552                	mv	a0,s4
    8000435a:	36a000ef          	jal	800046c4 <pipeclose>
    8000435e:	7902                	ld	s2,32(sp)
    80004360:	69e2                	ld	s3,24(sp)
    80004362:	6a42                	ld	s4,16(sp)
    80004364:	6aa2                	ld	s5,8(sp)
    80004366:	b7dd                	j	8000434c <fileclose+0x8e>
    begin_op();
    80004368:	a9dff0ef          	jal	80003e04 <begin_op>
    iput(ff.ip);
    8000436c:	8556                	mv	a0,s5
    8000436e:	9a0ff0ef          	jal	8000350e <iput>
    end_op();
    80004372:	b1fff0ef          	jal	80003e90 <end_op>
    80004376:	7902                	ld	s2,32(sp)
    80004378:	69e2                	ld	s3,24(sp)
    8000437a:	6a42                	ld	s4,16(sp)
    8000437c:	6aa2                	ld	s5,8(sp)
    8000437e:	b7f9                	j	8000434c <fileclose+0x8e>

0000000080004380 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004380:	715d                	addi	sp,sp,-80
    80004382:	e486                	sd	ra,72(sp)
    80004384:	e0a2                	sd	s0,64(sp)
    80004386:	fc26                	sd	s1,56(sp)
    80004388:	f052                	sd	s4,32(sp)
    8000438a:	0880                	addi	s0,sp,80
    8000438c:	84aa                	mv	s1,a0
    8000438e:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004390:	db8fd0ef          	jal	80001948 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    80004394:	409c                	lw	a5,0(s1)
    80004396:	37f9                	addiw	a5,a5,-2
    80004398:	4705                	li	a4,1
    8000439a:	04f76963          	bltu	a4,a5,800043ec <filestat+0x6c>
    8000439e:	f84a                	sd	s2,48(sp)
    800043a0:	f44e                	sd	s3,40(sp)
    800043a2:	892a                	mv	s2,a0
    memset(&st, 0, sizeof(st));
    800043a4:	fb840993          	addi	s3,s0,-72
    800043a8:	4661                	li	a2,24
    800043aa:	4581                	li	a1,0
    800043ac:	854e                	mv	a0,s3
    800043ae:	93bfc0ef          	jal	80000ce8 <memset>
    ilock(f->ip);
    800043b2:	6c88                	ld	a0,24(s1)
    800043b4:	fd9fe0ef          	jal	8000338c <ilock>
    stati(f->ip, &st);
    800043b8:	85ce                	mv	a1,s3
    800043ba:	6c88                	ld	a0,24(s1)
    800043bc:	b7cff0ef          	jal	80003738 <stati>
    iunlock(f->ip);
    800043c0:	6c88                	ld	a0,24(s1)
    800043c2:	878ff0ef          	jal	8000343a <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    800043c6:	4761                	li	a4,24
    800043c8:	86ce                	mv	a3,s3
    800043ca:	8652                	mv	a2,s4
    800043cc:	04893583          	ld	a1,72(s2)
    800043d0:	05093503          	ld	a0,80(s2)
    800043d4:	9aefd0ef          	jal	80001582 <copyout>
    800043d8:	41f5551b          	sraiw	a0,a0,0x1f
    800043dc:	7942                	ld	s2,48(sp)
    800043de:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800043e0:	60a6                	ld	ra,72(sp)
    800043e2:	6406                	ld	s0,64(sp)
    800043e4:	74e2                	ld	s1,56(sp)
    800043e6:	7a02                	ld	s4,32(sp)
    800043e8:	6161                	addi	sp,sp,80
    800043ea:	8082                	ret
  return -1;
    800043ec:	557d                	li	a0,-1
    800043ee:	bfcd                	j	800043e0 <filestat+0x60>

00000000800043f0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800043f0:	7179                	addi	sp,sp,-48
    800043f2:	f406                	sd	ra,40(sp)
    800043f4:	f022                	sd	s0,32(sp)
    800043f6:	e84a                	sd	s2,16(sp)
    800043f8:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    800043fa:	00854783          	lbu	a5,8(a0)
    800043fe:	c3dd                	beqz	a5,800044a4 <fileread+0xb4>
    80004400:	ec26                	sd	s1,24(sp)
    80004402:	e44e                	sd	s3,8(sp)
    80004404:	84aa                	mv	s1,a0
    80004406:	892e                	mv	s2,a1
    80004408:	89b2                	mv	s3,a2
    8000440a:	01f6579b          	srliw	a5,a2,0x1f
    8000440e:	ebc9                	bnez	a5,800044a0 <fileread+0xb0>
    return -1;

  if (f->type == FD_PIPE) {
    80004410:	411c                	lw	a5,0(a0)
    80004412:	4705                	li	a4,1
    80004414:	04e78363          	beq	a5,a4,8000445a <fileread+0x6a>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    80004418:	470d                	li	a4,3
    8000441a:	04e78763          	beq	a5,a4,80004468 <fileread+0x78>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    8000441e:	4709                	li	a4,2
    80004420:	06e79a63          	bne	a5,a4,80004494 <fileread+0xa4>
    ilock(f->ip);
    80004424:	6d08                	ld	a0,24(a0)
    80004426:	f67fe0ef          	jal	8000338c <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000442a:	874e                	mv	a4,s3
    8000442c:	5094                	lw	a3,32(s1)
    8000442e:	864a                	mv	a2,s2
    80004430:	4585                	li	a1,1
    80004432:	6c88                	ld	a0,24(s1)
    80004434:	b32ff0ef          	jal	80003766 <readi>
    80004438:	892a                	mv	s2,a0
    8000443a:	00a05563          	blez	a0,80004444 <fileread+0x54>
      f->off += r;
    8000443e:	509c                	lw	a5,32(s1)
    80004440:	9fa9                	addw	a5,a5,a0
    80004442:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004444:	6c88                	ld	a0,24(s1)
    80004446:	ff5fe0ef          	jal	8000343a <iunlock>
    8000444a:	64e2                	ld	s1,24(sp)
    8000444c:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000444e:	854a                	mv	a0,s2
    80004450:	70a2                	ld	ra,40(sp)
    80004452:	7402                	ld	s0,32(sp)
    80004454:	6942                	ld	s2,16(sp)
    80004456:	6145                	addi	sp,sp,48
    80004458:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000445a:	6908                	ld	a0,16(a0)
    8000445c:	3e2000ef          	jal	8000483e <piperead>
    80004460:	892a                	mv	s2,a0
    80004462:	64e2                	ld	s1,24(sp)
    80004464:	69a2                	ld	s3,8(sp)
    80004466:	b7e5                	j	8000444e <fileread+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004468:	02451783          	lh	a5,36(a0)
    8000446c:	03079693          	slli	a3,a5,0x30
    80004470:	92c1                	srli	a3,a3,0x30
    80004472:	4725                	li	a4,9
    80004474:	02d76b63          	bltu	a4,a3,800044aa <fileread+0xba>
    80004478:	0792                	slli	a5,a5,0x4
    8000447a:	0001e717          	auipc	a4,0x1e
    8000447e:	26670713          	addi	a4,a4,614 # 800226e0 <devsw>
    80004482:	97ba                	add	a5,a5,a4
    80004484:	639c                	ld	a5,0(a5)
    80004486:	c79d                	beqz	a5,800044b4 <fileread+0xc4>
    r = devsw[f->major].read(1, addr, n);
    80004488:	4505                	li	a0,1
    8000448a:	9782                	jalr	a5
    8000448c:	892a                	mv	s2,a0
    8000448e:	64e2                	ld	s1,24(sp)
    80004490:	69a2                	ld	s3,8(sp)
    80004492:	bf75                	j	8000444e <fileread+0x5e>
    panic("fileread");
    80004494:	00003517          	auipc	a0,0x3
    80004498:	10450513          	addi	a0,a0,260 # 80007598 <etext+0x598>
    8000449c:	b98fc0ef          	jal	80000834 <panic>
    800044a0:	64e2                	ld	s1,24(sp)
    800044a2:	69a2                	ld	s3,8(sp)
    return -1;
    800044a4:	57fd                	li	a5,-1
    800044a6:	893e                	mv	s2,a5
    800044a8:	b75d                	j	8000444e <fileread+0x5e>
      return -1;
    800044aa:	57fd                	li	a5,-1
    800044ac:	893e                	mv	s2,a5
    800044ae:	64e2                	ld	s1,24(sp)
    800044b0:	69a2                	ld	s3,8(sp)
    800044b2:	bf71                	j	8000444e <fileread+0x5e>
    800044b4:	57fd                	li	a5,-1
    800044b6:	893e                	mv	s2,a5
    800044b8:	64e2                	ld	s1,24(sp)
    800044ba:	69a2                	ld	s3,8(sp)
    800044bc:	bf49                	j	8000444e <fileread+0x5e>

00000000800044be <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    800044be:	00954783          	lbu	a5,9(a0)
    800044c2:	12078b63          	beqz	a5,800045f8 <filewrite+0x13a>
{
    800044c6:	711d                	addi	sp,sp,-96
    800044c8:	ec86                	sd	ra,88(sp)
    800044ca:	e8a2                	sd	s0,80(sp)
    800044cc:	e0ca                	sd	s2,64(sp)
    800044ce:	f456                	sd	s5,40(sp)
    800044d0:	f05a                	sd	s6,32(sp)
    800044d2:	1080                	addi	s0,sp,96
    800044d4:	892a                	mv	s2,a0
    800044d6:	8b2e                	mv	s6,a1
    800044d8:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    800044da:	01f6579b          	srliw	a5,a2,0x1f
    800044de:	0e079d63          	bnez	a5,800045d8 <filewrite+0x11a>
    return -1;

  if (f->type == FD_PIPE) {
    800044e2:	411c                	lw	a5,0(a0)
    800044e4:	4705                	li	a4,1
    800044e6:	02e78a63          	beq	a5,a4,8000451a <filewrite+0x5c>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800044ea:	470d                	li	a4,3
    800044ec:	02e78b63          	beq	a5,a4,80004522 <filewrite+0x64>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    800044f0:	4709                	li	a4,2
    800044f2:	0ce79763          	bne	a5,a4,800045c0 <filewrite+0x102>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    800044f6:	0ec05763          	blez	a2,800045e4 <filewrite+0x126>
    800044fa:	e4a6                	sd	s1,72(sp)
    800044fc:	fc4e                	sd	s3,56(sp)
    800044fe:	f852                	sd	s4,48(sp)
    80004500:	ec5e                	sd	s7,24(sp)
    80004502:	e862                	sd	s8,16(sp)
    80004504:	e466                	sd	s9,8(sp)
    int i = 0;
    80004506:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    80004508:	6b85                	lui	s7,0x1
    8000450a:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000450e:	6785                	lui	a5,0x1
    80004510:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004514:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004516:	4c05                	li	s8,1
    80004518:	a8ad                	j	80004592 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    8000451a:	6908                	ld	a0,16(a0)
    8000451c:	206000ef          	jal	80004722 <pipewrite>
    80004520:	a849                	j	800045b2 <filewrite+0xf4>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004522:	02451783          	lh	a5,36(a0)
    80004526:	03079693          	slli	a3,a5,0x30
    8000452a:	92c1                	srli	a3,a3,0x30
    8000452c:	4725                	li	a4,9
    8000452e:	0ad76763          	bltu	a4,a3,800045dc <filewrite+0x11e>
    80004532:	0792                	slli	a5,a5,0x4
    80004534:	0001e717          	auipc	a4,0x1e
    80004538:	1ac70713          	addi	a4,a4,428 # 800226e0 <devsw>
    8000453c:	97ba                	add	a5,a5,a4
    8000453e:	679c                	ld	a5,8(a5)
    80004540:	c3c5                	beqz	a5,800045e0 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004542:	4505                	li	a0,1
    80004544:	9782                	jalr	a5
    80004546:	a0b5                	j	800045b2 <filewrite+0xf4>
      if (n1 > max)
    80004548:	2981                	sext.w	s3,s3
      begin_op();
    8000454a:	8bbff0ef          	jal	80003e04 <begin_op>
      ilock(f->ip);
    8000454e:	01893503          	ld	a0,24(s2)
    80004552:	e3bfe0ef          	jal	8000338c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004556:	874e                	mv	a4,s3
    80004558:	02092683          	lw	a3,32(s2)
    8000455c:	016a0633          	add	a2,s4,s6
    80004560:	85e2                	mv	a1,s8
    80004562:	01893503          	ld	a0,24(s2)
    80004566:	af2ff0ef          	jal	80003858 <writei>
    8000456a:	84aa                	mv	s1,a0
    8000456c:	00a05763          	blez	a0,8000457a <filewrite+0xbc>
        f->off += r;
    80004570:	02092783          	lw	a5,32(s2)
    80004574:	9fa9                	addw	a5,a5,a0
    80004576:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000457a:	01893503          	ld	a0,24(s2)
    8000457e:	ebdfe0ef          	jal	8000343a <iunlock>
      end_op();
    80004582:	90fff0ef          	jal	80003e90 <end_op>

      if (r != n1) {
    80004586:	00999d63          	bne	s3,s1,800045a0 <filewrite+0xe2>
        // error from writei
        break;
      }
      i += r;
    8000458a:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    8000458e:	015a5963          	bge	s4,s5,800045a0 <filewrite+0xe2>
      int n1 = n - i;
    80004592:	414a87bb          	subw	a5,s5,s4
    80004596:	89be                	mv	s3,a5
      if (n1 > max)
    80004598:	fafbd8e3          	bge	s7,a5,80004548 <filewrite+0x8a>
    8000459c:	89e6                	mv	s3,s9
    8000459e:	b76d                	j	80004548 <filewrite+0x8a>
    }
    ret = (i == n ? n : -1);
    800045a0:	054a9463          	bne	s5,s4,800045e8 <filewrite+0x12a>
    800045a4:	8556                	mv	a0,s5
    800045a6:	64a6                	ld	s1,72(sp)
    800045a8:	79e2                	ld	s3,56(sp)
    800045aa:	7a42                	ld	s4,48(sp)
    800045ac:	6be2                	ld	s7,24(sp)
    800045ae:	6c42                	ld	s8,16(sp)
    800045b0:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800045b2:	60e6                	ld	ra,88(sp)
    800045b4:	6446                	ld	s0,80(sp)
    800045b6:	6906                	ld	s2,64(sp)
    800045b8:	7aa2                	ld	s5,40(sp)
    800045ba:	7b02                	ld	s6,32(sp)
    800045bc:	6125                	addi	sp,sp,96
    800045be:	8082                	ret
    800045c0:	e4a6                	sd	s1,72(sp)
    800045c2:	fc4e                	sd	s3,56(sp)
    800045c4:	f852                	sd	s4,48(sp)
    800045c6:	ec5e                	sd	s7,24(sp)
    800045c8:	e862                	sd	s8,16(sp)
    800045ca:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800045cc:	00003517          	auipc	a0,0x3
    800045d0:	fdc50513          	addi	a0,a0,-36 # 800075a8 <etext+0x5a8>
    800045d4:	a60fc0ef          	jal	80000834 <panic>
    return -1;
    800045d8:	557d                	li	a0,-1
    800045da:	bfe1                	j	800045b2 <filewrite+0xf4>
      return -1;
    800045dc:	557d                	li	a0,-1
    800045de:	bfd1                	j	800045b2 <filewrite+0xf4>
    800045e0:	557d                	li	a0,-1
    800045e2:	bfc1                	j	800045b2 <filewrite+0xf4>
    ret = (i == n ? n : -1);
    800045e4:	8532                	mv	a0,a2
    800045e6:	b7f1                	j	800045b2 <filewrite+0xf4>
    800045e8:	557d                	li	a0,-1
    800045ea:	64a6                	ld	s1,72(sp)
    800045ec:	79e2                	ld	s3,56(sp)
    800045ee:	7a42                	ld	s4,48(sp)
    800045f0:	6be2                	ld	s7,24(sp)
    800045f2:	6c42                	ld	s8,16(sp)
    800045f4:	6ca2                	ld	s9,8(sp)
    800045f6:	bf75                	j	800045b2 <filewrite+0xf4>
    return -1;
    800045f8:	557d                	li	a0,-1
}
    800045fa:	8082                	ret

00000000800045fc <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800045fc:	7179                	addi	sp,sp,-48
    800045fe:	f406                	sd	ra,40(sp)
    80004600:	f022                	sd	s0,32(sp)
    80004602:	ec26                	sd	s1,24(sp)
    80004604:	e052                	sd	s4,0(sp)
    80004606:	1800                	addi	s0,sp,48
    80004608:	84aa                	mv	s1,a0
    8000460a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000460c:	0005b023          	sd	zero,0(a1)
    80004610:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004614:	c07ff0ef          	jal	8000421a <filealloc>
    80004618:	e088                	sd	a0,0(s1)
    8000461a:	c549                	beqz	a0,800046a4 <pipealloc+0xa8>
    8000461c:	bffff0ef          	jal	8000421a <filealloc>
    80004620:	00aa3023          	sd	a0,0(s4)
    80004624:	cd25                	beqz	a0,8000469c <pipealloc+0xa0>
    80004626:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    80004628:	d26fc0ef          	jal	80000b4e <kalloc>
    8000462c:	892a                	mv	s2,a0
    8000462e:	c12d                	beqz	a0,80004690 <pipealloc+0x94>
    80004630:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004632:	4985                	li	s3,1
    80004634:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004638:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000463c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004640:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004644:	00003597          	auipc	a1,0x3
    80004648:	f7458593          	addi	a1,a1,-140 # 800075b8 <etext+0x5b8>
    8000464c:	d5cfc0ef          	jal	80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    80004650:	609c                	ld	a5,0(s1)
    80004652:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004656:	609c                	ld	a5,0(s1)
    80004658:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000465c:	609c                	ld	a5,0(s1)
    8000465e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004662:	609c                	ld	a5,0(s1)
    80004664:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004668:	000a3783          	ld	a5,0(s4)
    8000466c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004670:	000a3783          	ld	a5,0(s4)
    80004674:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004678:	000a3783          	ld	a5,0(s4)
    8000467c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004680:	000a3783          	ld	a5,0(s4)
    80004684:	0127b823          	sd	s2,16(a5)
  return 0;
    80004688:	4501                	li	a0,0
    8000468a:	6942                	ld	s2,16(sp)
    8000468c:	69a2                	ld	s3,8(sp)
    8000468e:	a01d                	j	800046b4 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80004690:	6088                	ld	a0,0(s1)
    80004692:	c119                	beqz	a0,80004698 <pipealloc+0x9c>
    80004694:	6942                	ld	s2,16(sp)
    80004696:	a029                	j	800046a0 <pipealloc+0xa4>
    80004698:	6942                	ld	s2,16(sp)
    8000469a:	a029                	j	800046a4 <pipealloc+0xa8>
    8000469c:	6088                	ld	a0,0(s1)
    8000469e:	c10d                	beqz	a0,800046c0 <pipealloc+0xc4>
    fileclose(*f0);
    800046a0:	c1fff0ef          	jal	800042be <fileclose>
  if (*f1)
    800046a4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800046a8:	557d                	li	a0,-1
  if (*f1)
    800046aa:	c789                	beqz	a5,800046b4 <pipealloc+0xb8>
    fileclose(*f1);
    800046ac:	853e                	mv	a0,a5
    800046ae:	c11ff0ef          	jal	800042be <fileclose>
  return -1;
    800046b2:	557d                	li	a0,-1
}
    800046b4:	70a2                	ld	ra,40(sp)
    800046b6:	7402                	ld	s0,32(sp)
    800046b8:	64e2                	ld	s1,24(sp)
    800046ba:	6a02                	ld	s4,0(sp)
    800046bc:	6145                	addi	sp,sp,48
    800046be:	8082                	ret
  return -1;
    800046c0:	557d                	li	a0,-1
    800046c2:	bfcd                	j	800046b4 <pipealloc+0xb8>

00000000800046c4 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800046c4:	1101                	addi	sp,sp,-32
    800046c6:	ec06                	sd	ra,24(sp)
    800046c8:	e822                	sd	s0,16(sp)
    800046ca:	e426                	sd	s1,8(sp)
    800046cc:	e04a                	sd	s2,0(sp)
    800046ce:	1000                	addi	s0,sp,32
    800046d0:	84aa                	mv	s1,a0
    800046d2:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800046d4:	d54fc0ef          	jal	80000c28 <acquire>
  if (writable) {
    800046d8:	02090763          	beqz	s2,80004706 <pipeclose+0x42>
    pi->writeopen = 0;
    800046dc:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800046e0:	21848513          	addi	a0,s1,536
    800046e4:	9fbfd0ef          	jal	800020de <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    800046e8:	2204a783          	lw	a5,544(s1)
    800046ec:	e781                	bnez	a5,800046f4 <pipeclose+0x30>
    800046ee:	2244a783          	lw	a5,548(s1)
    800046f2:	c38d                	beqz	a5,80004714 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    800046f4:	8526                	mv	a0,s1
    800046f6:	dbafc0ef          	jal	80000cb0 <release>
}
    800046fa:	60e2                	ld	ra,24(sp)
    800046fc:	6442                	ld	s0,16(sp)
    800046fe:	64a2                	ld	s1,8(sp)
    80004700:	6902                	ld	s2,0(sp)
    80004702:	6105                	addi	sp,sp,32
    80004704:	8082                	ret
    pi->readopen = 0;
    80004706:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000470a:	21c48513          	addi	a0,s1,540
    8000470e:	9d1fd0ef          	jal	800020de <wakeup>
    80004712:	bfd9                	j	800046e8 <pipeclose+0x24>
    release(&pi->lock);
    80004714:	8526                	mv	a0,s1
    80004716:	d9afc0ef          	jal	80000cb0 <release>
    kfree((char *)pi);
    8000471a:	8526                	mv	a0,s1
    8000471c:	b4afc0ef          	jal	80000a66 <kfree>
    80004720:	bfe9                	j	800046fa <pipeclose+0x36>

0000000080004722 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004722:	7159                	addi	sp,sp,-112
    80004724:	f486                	sd	ra,104(sp)
    80004726:	f0a2                	sd	s0,96(sp)
    80004728:	eca6                	sd	s1,88(sp)
    8000472a:	e8ca                	sd	s2,80(sp)
    8000472c:	e4ce                	sd	s3,72(sp)
    8000472e:	e0d2                	sd	s4,64(sp)
    80004730:	fc56                	sd	s5,56(sp)
    80004732:	1880                	addi	s0,sp,112
    80004734:	84aa                	mv	s1,a0
    80004736:	8aae                	mv	s5,a1
    80004738:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000473a:	a0efd0ef          	jal	80001948 <myproc>
    8000473e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004740:	8526                	mv	a0,s1
    80004742:	ce6fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    80004746:	0f405a63          	blez	s4,8000483a <pipewrite+0x118>
    8000474a:	f85a                	sd	s6,48(sp)
    8000474c:	f45e                	sd	s7,40(sp)
    8000474e:	f062                	sd	s8,32(sp)
    80004750:	ec66                	sd	s9,24(sp)
    80004752:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004754:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004756:	f9f40c13          	addi	s8,s0,-97
    8000475a:	4b85                	li	s7,1
    8000475c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000475e:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    80004762:	21c48c93          	addi	s9,s1,540
    80004766:	a0a1                	j	800047ae <pipewrite+0x8c>
      release(&pi->lock);
    80004768:	8526                	mv	a0,s1
    8000476a:	d46fc0ef          	jal	80000cb0 <release>
      return -1;
    8000476e:	597d                	li	s2,-1
    80004770:	7b42                	ld	s6,48(sp)
    80004772:	7ba2                	ld	s7,40(sp)
    80004774:	7c02                	ld	s8,32(sp)
    80004776:	6ce2                	ld	s9,24(sp)
    80004778:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000477a:	854a                	mv	a0,s2
    8000477c:	70a6                	ld	ra,104(sp)
    8000477e:	7406                	ld	s0,96(sp)
    80004780:	64e6                	ld	s1,88(sp)
    80004782:	6946                	ld	s2,80(sp)
    80004784:	69a6                	ld	s3,72(sp)
    80004786:	6a06                	ld	s4,64(sp)
    80004788:	7ae2                	ld	s5,56(sp)
    8000478a:	6165                	addi	sp,sp,112
    8000478c:	8082                	ret
      wakeup(&pi->nread);
    8000478e:	856a                	mv	a0,s10
    80004790:	94ffd0ef          	jal	800020de <wakeup>
      sleep_prepare(&pi->nwrite);
    80004794:	8566                	mv	a0,s9
    80004796:	8ddfd0ef          	jal	80002072 <sleep_prepare>
      release(&pi->lock);
    8000479a:	8526                	mv	a0,s1
    8000479c:	d14fc0ef          	jal	80000cb0 <release>
      sleep();
    800047a0:	90ffd0ef          	jal	800020ae <sleep>
      acquire(&pi->lock);
    800047a4:	8526                	mv	a0,s1
    800047a6:	c82fc0ef          	jal	80000c28 <acquire>
  while (i < n) {
    800047aa:	07495b63          	bge	s2,s4,80004820 <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    800047ae:	2204a783          	lw	a5,544(s1)
    800047b2:	dbdd                	beqz	a5,80004768 <pipewrite+0x46>
    800047b4:	854e                	mv	a0,s3
    800047b6:	b1bfd0ef          	jal	800022d0 <killed>
    800047ba:	f55d                	bnez	a0,80004768 <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    800047bc:	2184a783          	lw	a5,536(s1)
    800047c0:	21c4a703          	lw	a4,540(s1)
    800047c4:	2007879b          	addiw	a5,a5,512
    800047c8:	fcf703e3          	beq	a4,a5,8000478e <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    800047cc:	875e                	mv	a4,s7
    800047ce:	015906b3          	add	a3,s2,s5
    800047d2:	8662                	mv	a2,s8
    800047d4:	0489b583          	ld	a1,72(s3)
    800047d8:	0509b503          	ld	a0,80(s3)
    800047dc:	e6dfc0ef          	jal	80001648 <copyin>
    800047e0:	03650163          	beq	a0,s6,80004802 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800047e4:	21c4a783          	lw	a5,540(s1)
    800047e8:	0017871b          	addiw	a4,a5,1
    800047ec:	20e4ae23          	sw	a4,540(s1)
    800047f0:	1ff7f793          	andi	a5,a5,511
    800047f4:	97a6                	add	a5,a5,s1
    800047f6:	f9f44703          	lbu	a4,-97(s0)
    800047fa:	00e78c23          	sb	a4,24(a5)
      i++;
    800047fe:	2905                	addiw	s2,s2,1
    80004800:	b76d                	j	800047aa <pipewrite+0x88>
        if (i == 0)
    80004802:	00090863          	beqz	s2,80004812 <pipewrite+0xf0>
    80004806:	7b42                	ld	s6,48(sp)
    80004808:	7ba2                	ld	s7,40(sp)
    8000480a:	7c02                	ld	s8,32(sp)
    8000480c:	6ce2                	ld	s9,24(sp)
    8000480e:	6d42                	ld	s10,16(sp)
    80004810:	a829                	j	8000482a <pipewrite+0x108>
          i = -1;
    80004812:	892a                	mv	s2,a0
        break;
    80004814:	7b42                	ld	s6,48(sp)
    80004816:	7ba2                	ld	s7,40(sp)
    80004818:	7c02                	ld	s8,32(sp)
    8000481a:	6ce2                	ld	s9,24(sp)
    8000481c:	6d42                	ld	s10,16(sp)
    8000481e:	a031                	j	8000482a <pipewrite+0x108>
    80004820:	7b42                	ld	s6,48(sp)
    80004822:	7ba2                	ld	s7,40(sp)
    80004824:	7c02                	ld	s8,32(sp)
    80004826:	6ce2                	ld	s9,24(sp)
    80004828:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    8000482a:	21848513          	addi	a0,s1,536
    8000482e:	8b1fd0ef          	jal	800020de <wakeup>
  release(&pi->lock);
    80004832:	8526                	mv	a0,s1
    80004834:	c7cfc0ef          	jal	80000cb0 <release>
  return i;
    80004838:	b789                	j	8000477a <pipewrite+0x58>
  int i = 0;
    8000483a:	4901                	li	s2,0
    8000483c:	b7fd                	j	8000482a <pipewrite+0x108>

000000008000483e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000483e:	711d                	addi	sp,sp,-96
    80004840:	ec86                	sd	ra,88(sp)
    80004842:	e8a2                	sd	s0,80(sp)
    80004844:	e4a6                	sd	s1,72(sp)
    80004846:	e0ca                	sd	s2,64(sp)
    80004848:	fc4e                	sd	s3,56(sp)
    8000484a:	f852                	sd	s4,48(sp)
    8000484c:	f456                	sd	s5,40(sp)
    8000484e:	1080                	addi	s0,sp,96
    80004850:	84aa                	mv	s1,a0
    80004852:	89ae                	mv	s3,a1
    80004854:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004856:	8f2fd0ef          	jal	80001948 <myproc>
    8000485a:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    8000485c:	8526                	mv	a0,s1
    8000485e:	bcafc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004862:	0d505263          	blez	s5,80004926 <piperead+0xe8>
    80004866:	2184a703          	lw	a4,536(s1)
    8000486a:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    8000486e:	21848a13          	addi	s4,s1,536
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004872:	02f71e63          	bne	a4,a5,800048ae <piperead+0x70>
    80004876:	2244a783          	lw	a5,548(s1)
    8000487a:	c3b9                	beqz	a5,800048c0 <piperead+0x82>
    if (killed(pr)) {
    8000487c:	854a                	mv	a0,s2
    8000487e:	a53fd0ef          	jal	800022d0 <killed>
    80004882:	e915                	bnez	a0,800048b6 <piperead+0x78>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004884:	8552                	mv	a0,s4
    80004886:	fecfd0ef          	jal	80002072 <sleep_prepare>
    release(&pi->lock);
    8000488a:	8526                	mv	a0,s1
    8000488c:	c24fc0ef          	jal	80000cb0 <release>
    sleep();
    80004890:	81ffd0ef          	jal	800020ae <sleep>
    acquire(&pi->lock);
    80004894:	8526                	mv	a0,s1
    80004896:	b92fc0ef          	jal	80000c28 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    8000489a:	2184a703          	lw	a4,536(s1)
    8000489e:	21c4a783          	lw	a5,540(s1)
    800048a2:	fcf70ae3          	beq	a4,a5,80004876 <piperead+0x38>
    800048a6:	f05a                	sd	s6,32(sp)
    800048a8:	ec5e                	sd	s7,24(sp)
    800048aa:	e862                	sd	s8,16(sp)
    800048ac:	a829                	j	800048c6 <piperead+0x88>
    800048ae:	f05a                	sd	s6,32(sp)
    800048b0:	ec5e                	sd	s7,24(sp)
    800048b2:	e862                	sd	s8,16(sp)
    800048b4:	a809                	j	800048c6 <piperead+0x88>
      release(&pi->lock);
    800048b6:	8526                	mv	a0,s1
    800048b8:	bf8fc0ef          	jal	80000cb0 <release>
      return -1;
    800048bc:	5a7d                	li	s4,-1
    800048be:	a8a5                	j	80004936 <piperead+0xf8>
    800048c0:	f05a                	sd	s6,32(sp)
    800048c2:	ec5e                	sd	s7,24(sp)
    800048c4:	e862                	sd	s8,16(sp)
{
    800048c6:	4a01                	li	s4,0
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    800048c8:	faf40c13          	addi	s8,s0,-81
    800048cc:	4b85                	li	s7,1
    800048ce:	5b7d                	li	s6,-1
    if (pi->nread == pi->nwrite)
    800048d0:	2184a783          	lw	a5,536(s1)
    800048d4:	21c4a703          	lw	a4,540(s1)
    800048d8:	06f70e63          	beq	a4,a5,80004954 <piperead+0x116>
    ch = pi->data[pi->nread % PIPESIZE];
    800048dc:	1ff7f793          	andi	a5,a5,511
    800048e0:	97a6                	add	a5,a5,s1
    800048e2:	0187c783          	lbu	a5,24(a5)
    800048e6:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    800048ea:	875e                	mv	a4,s7
    800048ec:	86e2                	mv	a3,s8
    800048ee:	864e                	mv	a2,s3
    800048f0:	04893583          	ld	a1,72(s2)
    800048f4:	05093503          	ld	a0,80(s2)
    800048f8:	c8bfc0ef          	jal	80001582 <copyout>
    800048fc:	01650f63          	beq	a0,s6,8000491a <piperead+0xdc>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004900:	2184a783          	lw	a5,536(s1)
    80004904:	2785                	addiw	a5,a5,1
    80004906:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    8000490a:	2a05                	addiw	s4,s4,1
    8000490c:	0985                	addi	s3,s3,1
    8000490e:	fd4a91e3          	bne	s5,s4,800048d0 <piperead+0x92>
    80004912:	7b02                	ld	s6,32(sp)
    80004914:	6be2                	ld	s7,24(sp)
    80004916:	6c42                	ld	s8,16(sp)
    80004918:	a801                	j	80004928 <piperead+0xea>
      if (i == 0)
    8000491a:	020a0863          	beqz	s4,8000494a <piperead+0x10c>
    8000491e:	7b02                	ld	s6,32(sp)
    80004920:	6be2                	ld	s7,24(sp)
    80004922:	6c42                	ld	s8,16(sp)
    80004924:	a011                	j	80004928 <piperead+0xea>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004926:	4a01                	li	s4,0
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    80004928:	21c48513          	addi	a0,s1,540
    8000492c:	fb2fd0ef          	jal	800020de <wakeup>
  release(&pi->lock);
    80004930:	8526                	mv	a0,s1
    80004932:	b7efc0ef          	jal	80000cb0 <release>
  return i;
}
    80004936:	8552                	mv	a0,s4
    80004938:	60e6                	ld	ra,88(sp)
    8000493a:	6446                	ld	s0,80(sp)
    8000493c:	64a6                	ld	s1,72(sp)
    8000493e:	6906                	ld	s2,64(sp)
    80004940:	79e2                	ld	s3,56(sp)
    80004942:	7a42                	ld	s4,48(sp)
    80004944:	7aa2                	ld	s5,40(sp)
    80004946:	6125                	addi	sp,sp,96
    80004948:	8082                	ret
        i = -1;
    8000494a:	8a2a                	mv	s4,a0
    8000494c:	7b02                	ld	s6,32(sp)
    8000494e:	6be2                	ld	s7,24(sp)
    80004950:	6c42                	ld	s8,16(sp)
    80004952:	bfd9                	j	80004928 <piperead+0xea>
    80004954:	7b02                	ld	s6,32(sp)
    80004956:	6be2                	ld	s7,24(sp)
    80004958:	6c42                	ld	s8,16(sp)
    8000495a:	b7f9                	j	80004928 <piperead+0xea>

000000008000495c <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    8000495c:	1141                	addi	sp,sp,-16
    8000495e:	e406                	sd	ra,8(sp)
    80004960:	e022                	sd	s0,0(sp)
    80004962:	0800                	addi	s0,sp,16
    80004964:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    80004966:	0035151b          	slliw	a0,a0,0x3
    8000496a:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    8000496c:	8b89                	andi	a5,a5,2
    8000496e:	c399                	beqz	a5,80004974 <flags2perm+0x18>
    perm |= PTE_W;
    80004970:	00456513          	ori	a0,a0,4
  return perm;
}
    80004974:	60a2                	ld	ra,8(sp)
    80004976:	6402                	ld	s0,0(sp)
    80004978:	0141                	addi	sp,sp,16
    8000497a:	8082                	ret

000000008000497c <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    8000497c:	de010113          	addi	sp,sp,-544
    80004980:	20113c23          	sd	ra,536(sp)
    80004984:	20813823          	sd	s0,528(sp)
    80004988:	20913423          	sd	s1,520(sp)
    8000498c:	21213023          	sd	s2,512(sp)
    80004990:	1400                	addi	s0,sp,544
    80004992:	892a                	mv	s2,a0
    80004994:	dea43823          	sd	a0,-528(s0)
    80004998:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000499c:	fadfc0ef          	jal	80001948 <myproc>
    800049a0:	84aa                	mv	s1,a0

  begin_op();
    800049a2:	c62ff0ef          	jal	80003e04 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    800049a6:	854a                	mv	a0,s2
    800049a8:	a7eff0ef          	jal	80003c26 <namei>
    800049ac:	cd21                	beqz	a0,80004a04 <kexec+0x88>
    800049ae:	fbd2                	sd	s4,496(sp)
    800049b0:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800049b2:	9dbfe0ef          	jal	8000338c <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800049b6:	04000713          	li	a4,64
    800049ba:	4681                	li	a3,0
    800049bc:	e5040613          	addi	a2,s0,-432
    800049c0:	4581                	li	a1,0
    800049c2:	8552                	mv	a0,s4
    800049c4:	da3fe0ef          	jal	80003766 <readi>
    800049c8:	04000793          	li	a5,64
    800049cc:	00f51a63          	bne	a0,a5,800049e0 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    800049d0:	e5042703          	lw	a4,-432(s0)
    800049d4:	464c47b7          	lui	a5,0x464c4
    800049d8:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800049dc:	02f70863          	beq	a4,a5,80004a0c <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    800049e0:	8552                	mv	a0,s4
    800049e2:	bfffe0ef          	jal	800035e0 <iunlockput>
    end_op();
    800049e6:	caaff0ef          	jal	80003e90 <end_op>
  }
  return -1;
    800049ea:	557d                	li	a0,-1
    800049ec:	7a5e                	ld	s4,496(sp)
}
    800049ee:	21813083          	ld	ra,536(sp)
    800049f2:	21013403          	ld	s0,528(sp)
    800049f6:	20813483          	ld	s1,520(sp)
    800049fa:	20013903          	ld	s2,512(sp)
    800049fe:	22010113          	addi	sp,sp,544
    80004a02:	8082                	ret
    end_op();
    80004a04:	c8cff0ef          	jal	80003e90 <end_op>
    return -1;
    80004a08:	557d                	li	a0,-1
    80004a0a:	b7d5                	j	800049ee <kexec+0x72>
    80004a0c:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004a0e:	8526                	mv	a0,s1
    80004a10:	83efd0ef          	jal	80001a4e <proc_pagetable>
    80004a14:	8b2a                	mv	s6,a0
    80004a16:	26050e63          	beqz	a0,80004c92 <kexec+0x316>
    80004a1a:	ffce                	sd	s3,504(sp)
    80004a1c:	f7d6                	sd	s5,488(sp)
    80004a1e:	efde                	sd	s7,472(sp)
    80004a20:	ebe2                	sd	s8,464(sp)
    80004a22:	e7e6                	sd	s9,456(sp)
    80004a24:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004a26:	e8845783          	lhu	a5,-376(s0)
    80004a2a:	14078263          	beqz	a5,80004b6e <kexec+0x1f2>
    80004a2e:	ff6e                	sd	s11,440(sp)
    80004a30:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a34:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004a36:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a38:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    80004a3c:	6c85                	lui	s9,0x1
    80004a3e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004a42:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    80004a46:	6a85                	lui	s5,0x1
    80004a48:	a085                	j	80004aa8 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004a4a:	00003517          	auipc	a0,0x3
    80004a4e:	b7650513          	addi	a0,a0,-1162 # 800075c0 <etext+0x5c0>
    80004a52:	de3fb0ef          	jal	80000834 <panic>
    if (sz - i < PGSIZE)
    80004a56:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004a58:	874a                	mv	a4,s2
    80004a5a:	009b86bb          	addw	a3,s7,s1
    80004a5e:	4581                	li	a1,0
    80004a60:	8552                	mv	a0,s4
    80004a62:	d05fe0ef          	jal	80003766 <readi>
    80004a66:	22a91a63          	bne	s2,a0,80004c9a <kexec+0x31e>
  for (i = 0; i < sz; i += PGSIZE) {
    80004a6a:	009a84bb          	addw	s1,s5,s1
    80004a6e:	0334f263          	bgeu	s1,s3,80004a92 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004a72:	02049593          	slli	a1,s1,0x20
    80004a76:	9181                	srli	a1,a1,0x20
    80004a78:	95e2                	add	a1,a1,s8
    80004a7a:	855a                	mv	a0,s6
    80004a7c:	d9cfc0ef          	jal	80001018 <walkaddr>
    80004a80:	862a                	mv	a2,a0
    if (pa == 0)
    80004a82:	d561                	beqz	a0,80004a4a <kexec+0xce>
    if (sz - i < PGSIZE)
    80004a84:	409987bb          	subw	a5,s3,s1
    80004a88:	893e                	mv	s2,a5
    80004a8a:	fcfcf6e3          	bgeu	s9,a5,80004a56 <kexec+0xda>
    80004a8e:	8956                	mv	s2,s5
    80004a90:	b7d9                	j	80004a56 <kexec+0xda>
    sz = sz1;
    80004a92:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004a96:	2d05                	addiw	s10,s10,1
    80004a98:	e0843783          	ld	a5,-504(s0)
    80004a9c:	0387869b          	addiw	a3,a5,56
    80004aa0:	e8845783          	lhu	a5,-376(s0)
    80004aa4:	06fd5d63          	bge	s10,a5,80004b1e <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004aa8:	e0d43423          	sd	a3,-504(s0)
    80004aac:	876e                	mv	a4,s11
    80004aae:	e1840613          	addi	a2,s0,-488
    80004ab2:	4581                	li	a1,0
    80004ab4:	8552                	mv	a0,s4
    80004ab6:	cb1fe0ef          	jal	80003766 <readi>
    80004aba:	1db51e63          	bne	a0,s11,80004c96 <kexec+0x31a>
    if (ph.type != ELF_PROG_LOAD)
    80004abe:	e1842783          	lw	a5,-488(s0)
    80004ac2:	4705                	li	a4,1
    80004ac4:	fce799e3          	bne	a5,a4,80004a96 <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    80004ac8:	e4043483          	ld	s1,-448(s0)
    80004acc:	e3843783          	ld	a5,-456(s0)
    80004ad0:	1ef4e363          	bltu	s1,a5,80004cb6 <kexec+0x33a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004ad4:	e2843783          	ld	a5,-472(s0)
    80004ad8:	94be                	add	s1,s1,a5
    80004ada:	1ef4e163          	bltu	s1,a5,80004cbc <kexec+0x340>
    if (ph.vaddr % PGSIZE != 0)
    80004ade:	de843703          	ld	a4,-536(s0)
    80004ae2:	8ff9                	and	a5,a5,a4
    80004ae4:	1c079f63          	bnez	a5,80004cc2 <kexec+0x346>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004ae8:	e1c42503          	lw	a0,-484(s0)
    80004aec:	e71ff0ef          	jal	8000495c <flags2perm>
    80004af0:	86aa                	mv	a3,a0
    80004af2:	8626                	mv	a2,s1
    80004af4:	85ca                	mv	a1,s2
    80004af6:	855a                	mv	a0,s6
    80004af8:	ff6fc0ef          	jal	800012ee <uvmalloc>
    80004afc:	dea43c23          	sd	a0,-520(s0)
    80004b00:	1c050463          	beqz	a0,80004cc8 <kexec+0x34c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004b04:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004b08:	00098863          	beqz	s3,80004b18 <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004b0c:	e2843c03          	ld	s8,-472(s0)
    80004b10:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004b14:	4481                	li	s1,0
    80004b16:	bfb1                	j	80004a72 <kexec+0xf6>
    sz = sz1;
    80004b18:	df843903          	ld	s2,-520(s0)
    80004b1c:	bfad                	j	80004a96 <kexec+0x11a>
    80004b1e:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    80004b20:	8552                	mv	a0,s4
    80004b22:	abffe0ef          	jal	800035e0 <iunlockput>
  end_op();
    80004b26:	b6aff0ef          	jal	80003e90 <end_op>
  p = myproc();
    80004b2a:	e1ffc0ef          	jal	80001948 <myproc>
    80004b2e:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004b30:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    80004b34:	6c05                	lui	s8,0x1
    80004b36:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    80004b38:	9c4a                	add	s8,s8,s2
    80004b3a:	77fd                	lui	a5,0xfffff
    80004b3c:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004b40:	4691                	li	a3,4
    80004b42:	6609                	lui	a2,0x2
    80004b44:	9662                	add	a2,a2,s8
    80004b46:	85e2                	mv	a1,s8
    80004b48:	855a                	mv	a0,s6
    80004b4a:	fa4fc0ef          	jal	800012ee <uvmalloc>
    80004b4e:	892a                	mv	s2,a0
    80004b50:	e10d                	bnez	a0,80004b72 <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    80004b52:	85e2                	mv	a1,s8
    80004b54:	855a                	mv	a0,s6
    80004b56:	f7dfc0ef          	jal	80001ad2 <proc_freepagetable>
  return -1;
    80004b5a:	557d                	li	a0,-1
    80004b5c:	79fe                	ld	s3,504(sp)
    80004b5e:	7a5e                	ld	s4,496(sp)
    80004b60:	7abe                	ld	s5,488(sp)
    80004b62:	7b1e                	ld	s6,480(sp)
    80004b64:	6bfe                	ld	s7,472(sp)
    80004b66:	6c5e                	ld	s8,464(sp)
    80004b68:	6cbe                	ld	s9,456(sp)
    80004b6a:	6d1e                	ld	s10,448(sp)
    80004b6c:	b549                	j	800049ee <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004b6e:	4901                	li	s2,0
    80004b70:	bf45                	j	80004b20 <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004b72:	75f9                	lui	a1,0xffffe
    80004b74:	95aa                	add	a1,a1,a0
    80004b76:	855a                	mv	a0,s6
    80004b78:	949fc0ef          	jal	800014c0 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004b7c:	80090a13          	addi	s4,s2,-2048
    80004b80:	800a0a13          	addi	s4,s4,-2048
  for (argc = 0; argv[argc]; argc++) {
    80004b84:	e0043783          	ld	a5,-512(s0)
    80004b88:	6388                	ld	a0,0(a5)
    80004b8a:	c545                	beqz	a0,80004c32 <kexec+0x2b6>
  sp = sz;
    80004b8c:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004b8e:	4481                	li	s1,0
    ustack[argc] = sp;
    80004b90:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004b94:	adefc0ef          	jal	80000e72 <strlen>
    80004b98:	0015079b          	addiw	a5,a0,1
    80004b9c:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004ba0:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004ba4:	134c6563          	bltu	s8,s4,80004cce <kexec+0x352>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ba8:	e0043d03          	ld	s10,-512(s0)
    80004bac:	000d3c83          	ld	s9,0(s10)
    80004bb0:	8566                	mv	a0,s9
    80004bb2:	ac0fc0ef          	jal	80000e72 <strlen>
    80004bb6:	0015071b          	addiw	a4,a0,1
    80004bba:	86e6                	mv	a3,s9
    80004bbc:	8662                	mv	a2,s8
    80004bbe:	85ca                	mv	a1,s2
    80004bc0:	855a                	mv	a0,s6
    80004bc2:	9c1fc0ef          	jal	80001582 <copyout>
    80004bc6:	10054663          	bltz	a0,80004cd2 <kexec+0x356>
    ustack[argc] = sp;
    80004bca:	00349793          	slli	a5,s1,0x3
    80004bce:	97de                	add	a5,a5,s7
    80004bd0:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb788>
  for (argc = 0; argv[argc]; argc++) {
    80004bd4:	0485                	addi	s1,s1,1
    80004bd6:	008d0793          	addi	a5,s10,8
    80004bda:	e0f43023          	sd	a5,-512(s0)
    80004bde:	008d3503          	ld	a0,8(s10)
    80004be2:	f94d                	bnez	a0,80004b94 <kexec+0x218>
  ustack[argc] = 0;
    80004be4:	00349793          	slli	a5,s1,0x3
    80004be8:	f9078793          	addi	a5,a5,-112
    80004bec:	97a2                	add	a5,a5,s0
    80004bee:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004bf2:	00349713          	slli	a4,s1,0x3
    80004bf6:	0721                	addi	a4,a4,8
    80004bf8:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004bfc:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004c00:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004c02:	f54be8e3          	bltu	s7,s4,80004b52 <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004c06:	e9040693          	addi	a3,s0,-368
    80004c0a:	865e                	mv	a2,s7
    80004c0c:	85ca                	mv	a1,s2
    80004c0e:	855a                	mv	a0,s6
    80004c10:	973fc0ef          	jal	80001582 <copyout>
    80004c14:	f2054fe3          	bltz	a0,80004b52 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004c18:	0589b783          	ld	a5,88(s3)
    80004c1c:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004c20:	df043783          	ld	a5,-528(s0)
    80004c24:	0007c703          	lbu	a4,0(a5)
    80004c28:	c30d                	beqz	a4,80004c4a <kexec+0x2ce>
    80004c2a:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004c2c:	02f00693          	li	a3,47
    80004c30:	a801                	j	80004c40 <kexec+0x2c4>
  sp = sz;
    80004c32:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004c34:	4481                	li	s1,0
    80004c36:	b77d                	j	80004be4 <kexec+0x268>
  for (last = s = path; *s; s++)
    80004c38:	0785                	addi	a5,a5,1
    80004c3a:	fff7c703          	lbu	a4,-1(a5)
    80004c3e:	c711                	beqz	a4,80004c4a <kexec+0x2ce>
    if (*s == '/')
    80004c40:	fed71ce3          	bne	a4,a3,80004c38 <kexec+0x2bc>
      last = s + 1;
    80004c44:	def43823          	sd	a5,-528(s0)
    80004c48:	bfc5                	j	80004c38 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004c4a:	4641                	li	a2,16
    80004c4c:	df043583          	ld	a1,-528(s0)
    80004c50:	15898513          	addi	a0,s3,344
    80004c54:	9e8fc0ef          	jal	80000e3c <safestrcpy>
  oldpagetable = p->pagetable;
    80004c58:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004c5c:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004c60:	0529b423          	sd	s2,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004c64:	0589b783          	ld	a5,88(s3)
    80004c68:	e6843703          	ld	a4,-408(s0)
    80004c6c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004c6e:	0589b783          	ld	a5,88(s3)
    80004c72:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004c76:	85d6                	mv	a1,s5
    80004c78:	e5bfc0ef          	jal	80001ad2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004c7c:	0004851b          	sext.w	a0,s1
    80004c80:	79fe                	ld	s3,504(sp)
    80004c82:	7a5e                	ld	s4,496(sp)
    80004c84:	7abe                	ld	s5,488(sp)
    80004c86:	7b1e                	ld	s6,480(sp)
    80004c88:	6bfe                	ld	s7,472(sp)
    80004c8a:	6c5e                	ld	s8,464(sp)
    80004c8c:	6cbe                	ld	s9,456(sp)
    80004c8e:	6d1e                	ld	s10,448(sp)
    80004c90:	bbb9                	j	800049ee <kexec+0x72>
    80004c92:	7b1e                	ld	s6,480(sp)
    80004c94:	b3b1                	j	800049e0 <kexec+0x64>
    80004c96:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004c9a:	df843583          	ld	a1,-520(s0)
    80004c9e:	855a                	mv	a0,s6
    80004ca0:	e33fc0ef          	jal	80001ad2 <proc_freepagetable>
  if (ip) {
    80004ca4:	79fe                	ld	s3,504(sp)
    80004ca6:	7abe                	ld	s5,488(sp)
    80004ca8:	7b1e                	ld	s6,480(sp)
    80004caa:	6bfe                	ld	s7,472(sp)
    80004cac:	6c5e                	ld	s8,464(sp)
    80004cae:	6cbe                	ld	s9,456(sp)
    80004cb0:	6d1e                	ld	s10,448(sp)
    80004cb2:	7dfa                	ld	s11,440(sp)
    80004cb4:	b335                	j	800049e0 <kexec+0x64>
    80004cb6:	df243c23          	sd	s2,-520(s0)
    80004cba:	b7c5                	j	80004c9a <kexec+0x31e>
    80004cbc:	df243c23          	sd	s2,-520(s0)
    80004cc0:	bfe9                	j	80004c9a <kexec+0x31e>
    80004cc2:	df243c23          	sd	s2,-520(s0)
    80004cc6:	bfd1                	j	80004c9a <kexec+0x31e>
    80004cc8:	df243c23          	sd	s2,-520(s0)
    80004ccc:	b7f9                	j	80004c9a <kexec+0x31e>
  sz = sz1;
    80004cce:	8c4a                	mv	s8,s2
    80004cd0:	b549                	j	80004b52 <kexec+0x1d6>
    80004cd2:	8c4a                	mv	s8,s2
    80004cd4:	bdbd                	j	80004b52 <kexec+0x1d6>

0000000080004cd6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004cd6:	7179                	addi	sp,sp,-48
    80004cd8:	f406                	sd	ra,40(sp)
    80004cda:	f022                	sd	s0,32(sp)
    80004cdc:	ec26                	sd	s1,24(sp)
    80004cde:	e84a                	sd	s2,16(sp)
    80004ce0:	1800                	addi	s0,sp,48
    80004ce2:	892e                	mv	s2,a1
    80004ce4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004ce6:	fdc40593          	addi	a1,s0,-36
    80004cea:	c99fd0ef          	jal	80002982 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004cee:	fdc42703          	lw	a4,-36(s0)
    80004cf2:	47bd                	li	a5,15
    80004cf4:	02e7ea63          	bltu	a5,a4,80004d28 <argfd+0x52>
    80004cf8:	c51fc0ef          	jal	80001948 <myproc>
    80004cfc:	fdc42703          	lw	a4,-36(s0)
    80004d00:	00371793          	slli	a5,a4,0x3
    80004d04:	0d078793          	addi	a5,a5,208
    80004d08:	953e                	add	a0,a0,a5
    80004d0a:	611c                	ld	a5,0(a0)
    80004d0c:	c385                	beqz	a5,80004d2c <argfd+0x56>
    return -1;
  if (pfd)
    80004d0e:	00090463          	beqz	s2,80004d16 <argfd+0x40>
    *pfd = fd;
    80004d12:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004d16:	4501                	li	a0,0
  if (pf)
    80004d18:	c091                	beqz	s1,80004d1c <argfd+0x46>
    *pf = f;
    80004d1a:	e09c                	sd	a5,0(s1)
}
    80004d1c:	70a2                	ld	ra,40(sp)
    80004d1e:	7402                	ld	s0,32(sp)
    80004d20:	64e2                	ld	s1,24(sp)
    80004d22:	6942                	ld	s2,16(sp)
    80004d24:	6145                	addi	sp,sp,48
    80004d26:	8082                	ret
    return -1;
    80004d28:	557d                	li	a0,-1
    80004d2a:	bfcd                	j	80004d1c <argfd+0x46>
    80004d2c:	557d                	li	a0,-1
    80004d2e:	b7fd                	j	80004d1c <argfd+0x46>

0000000080004d30 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004d30:	1101                	addi	sp,sp,-32
    80004d32:	ec06                	sd	ra,24(sp)
    80004d34:	e822                	sd	s0,16(sp)
    80004d36:	e426                	sd	s1,8(sp)
    80004d38:	1000                	addi	s0,sp,32
    80004d3a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004d3c:	c0dfc0ef          	jal	80001948 <myproc>
    80004d40:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004d42:	0d050793          	addi	a5,a0,208
    80004d46:	4501                	li	a0,0
    80004d48:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004d4a:	6398                	ld	a4,0(a5)
    80004d4c:	cb19                	beqz	a4,80004d62 <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004d4e:	2505                	addiw	a0,a0,1
    80004d50:	07a1                	addi	a5,a5,8
    80004d52:	fed51ce3          	bne	a0,a3,80004d4a <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004d56:	557d                	li	a0,-1
}
    80004d58:	60e2                	ld	ra,24(sp)
    80004d5a:	6442                	ld	s0,16(sp)
    80004d5c:	64a2                	ld	s1,8(sp)
    80004d5e:	6105                	addi	sp,sp,32
    80004d60:	8082                	ret
      p->ofile[fd] = f;
    80004d62:	00351793          	slli	a5,a0,0x3
    80004d66:	0d078793          	addi	a5,a5,208
    80004d6a:	963e                	add	a2,a2,a5
    80004d6c:	e204                	sd	s1,0(a2)
      return fd;
    80004d6e:	b7ed                	j	80004d58 <fdalloc+0x28>

0000000080004d70 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004d70:	715d                	addi	sp,sp,-80
    80004d72:	e486                	sd	ra,72(sp)
    80004d74:	e0a2                	sd	s0,64(sp)
    80004d76:	fc26                	sd	s1,56(sp)
    80004d78:	f84a                	sd	s2,48(sp)
    80004d7a:	f052                	sd	s4,32(sp)
    80004d7c:	ec56                	sd	s5,24(sp)
    80004d7e:	e85a                	sd	s6,16(sp)
    80004d80:	0880                	addi	s0,sp,80
    80004d82:	8a2e                	mv	s4,a1
    80004d84:	8ab2                	mv	s5,a2
    80004d86:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004d88:	fb040593          	addi	a1,s0,-80
    80004d8c:	eb5fe0ef          	jal	80003c40 <nameiparent>
    80004d90:	84aa                	mv	s1,a0
    80004d92:	12050f63          	beqz	a0,80004ed0 <create+0x160>
    return 0;

  ilock(dp);
    80004d96:	df6fe0ef          	jal	8000338c <ilock>

  if (dp->nlink == 0) {
    80004d9a:	04a49783          	lh	a5,74(s1)
    80004d9e:	cbb9                	beqz	a5,80004df4 <create+0x84>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004da0:	7761                	lui	a4,0xffff8
    80004da2:	0705                	addi	a4,a4,1 # ffffffffffff8001 <end+0xffffffff7ffd4789>
    80004da4:	97ba                	add	a5,a5,a4
    80004da6:	e781                	bnez	a5,80004dae <create+0x3e>
    80004da8:	fffa0793          	addi	a5,s4,-1
    80004dac:	cba9                	beqz	a5,80004dfe <create+0x8e>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004dae:	4601                	li	a2,0
    80004db0:	fb040593          	addi	a1,s0,-80
    80004db4:	8526                	mv	a0,s1
    80004db6:	bbffe0ef          	jal	80003974 <dirlookup>
    80004dba:	892a                	mv	s2,a0
    80004dbc:	c939                	beqz	a0,80004e12 <create+0xa2>
    iunlockput(dp);
    80004dbe:	8526                	mv	a0,s1
    80004dc0:	821fe0ef          	jal	800035e0 <iunlockput>
    ilock(ip);
    80004dc4:	854a                	mv	a0,s2
    80004dc6:	dc6fe0ef          	jal	8000338c <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004dca:	4789                	li	a5,2
    80004dcc:	02fa1e63          	bne	s4,a5,80004e08 <create+0x98>
    80004dd0:	04495783          	lhu	a5,68(s2)
    80004dd4:	37f9                	addiw	a5,a5,-2
    80004dd6:	17c2                	slli	a5,a5,0x30
    80004dd8:	93c1                	srli	a5,a5,0x30
    80004dda:	4705                	li	a4,1
    80004ddc:	02f76663          	bltu	a4,a5,80004e08 <create+0x98>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004de0:	854a                	mv	a0,s2
    80004de2:	60a6                	ld	ra,72(sp)
    80004de4:	6406                	ld	s0,64(sp)
    80004de6:	74e2                	ld	s1,56(sp)
    80004de8:	7942                	ld	s2,48(sp)
    80004dea:	7a02                	ld	s4,32(sp)
    80004dec:	6ae2                	ld	s5,24(sp)
    80004dee:	6b42                	ld	s6,16(sp)
    80004df0:	6161                	addi	sp,sp,80
    80004df2:	8082                	ret
    iunlockput(dp);
    80004df4:	8526                	mv	a0,s1
    80004df6:	feafe0ef          	jal	800035e0 <iunlockput>
    return 0;
    80004dfa:	4901                	li	s2,0
    80004dfc:	b7d5                	j	80004de0 <create+0x70>
    iunlockput(dp);
    80004dfe:	8526                	mv	a0,s1
    80004e00:	fe0fe0ef          	jal	800035e0 <iunlockput>
    return 0;
    80004e04:	4901                	li	s2,0
    80004e06:	bfe9                	j	80004de0 <create+0x70>
    iunlockput(ip);
    80004e08:	854a                	mv	a0,s2
    80004e0a:	fd6fe0ef          	jal	800035e0 <iunlockput>
    return 0;
    80004e0e:	4901                	li	s2,0
    80004e10:	bfc1                	j	80004de0 <create+0x70>
    80004e12:	f44e                	sd	s3,40(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004e14:	85d2                	mv	a1,s4
    80004e16:	4088                	lw	a0,0(s1)
    80004e18:	c04fe0ef          	jal	8000321c <ialloc>
    80004e1c:	89aa                	mv	s3,a0
    80004e1e:	cd1d                	beqz	a0,80004e5c <create+0xec>
  ilock(ip);
    80004e20:	d6cfe0ef          	jal	8000338c <ilock>
  ip->major = major;
    80004e24:	05599323          	sh	s5,70(s3)
  ip->minor = minor;
    80004e28:	05699423          	sh	s6,72(s3)
  ip->nlink = 1;
    80004e2c:	4705                	li	a4,1
    80004e2e:	04e99523          	sh	a4,74(s3)
  iupdate(ip);
    80004e32:	854e                	mv	a0,s3
    80004e34:	ca4fe0ef          	jal	800032d8 <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80004e38:	4705                	li	a4,1
    80004e3a:	02ea0763          	beq	s4,a4,80004e68 <create+0xf8>
  if (dirlink(dp, name, ip->inum) < 0)
    80004e3e:	0049a603          	lw	a2,4(s3)
    80004e42:	fb040593          	addi	a1,s0,-80
    80004e46:	8526                	mv	a0,s1
    80004e48:	d35fe0ef          	jal	80003b7c <dirlink>
    80004e4c:	06054563          	bltz	a0,80004eb6 <create+0x146>
  iunlockput(dp);
    80004e50:	8526                	mv	a0,s1
    80004e52:	f8efe0ef          	jal	800035e0 <iunlockput>
  return ip;
    80004e56:	894e                	mv	s2,s3
    80004e58:	79a2                	ld	s3,40(sp)
    80004e5a:	b759                	j	80004de0 <create+0x70>
    iunlockput(dp);
    80004e5c:	8526                	mv	a0,s1
    80004e5e:	f82fe0ef          	jal	800035e0 <iunlockput>
    return 0;
    80004e62:	894e                	mv	s2,s3
    80004e64:	79a2                	ld	s3,40(sp)
    80004e66:	bfad                	j	80004de0 <create+0x70>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004e68:	0049a603          	lw	a2,4(s3)
    80004e6c:	00002597          	auipc	a1,0x2
    80004e70:	77458593          	addi	a1,a1,1908 # 800075e0 <etext+0x5e0>
    80004e74:	854e                	mv	a0,s3
    80004e76:	d07fe0ef          	jal	80003b7c <dirlink>
    80004e7a:	02054e63          	bltz	a0,80004eb6 <create+0x146>
    80004e7e:	40d0                	lw	a2,4(s1)
    80004e80:	00002597          	auipc	a1,0x2
    80004e84:	76858593          	addi	a1,a1,1896 # 800075e8 <etext+0x5e8>
    80004e88:	854e                	mv	a0,s3
    80004e8a:	cf3fe0ef          	jal	80003b7c <dirlink>
    80004e8e:	02054463          	bltz	a0,80004eb6 <create+0x146>
  if (dirlink(dp, name, ip->inum) < 0)
    80004e92:	0049a603          	lw	a2,4(s3)
    80004e96:	fb040593          	addi	a1,s0,-80
    80004e9a:	8526                	mv	a0,s1
    80004e9c:	ce1fe0ef          	jal	80003b7c <dirlink>
    80004ea0:	00054b63          	bltz	a0,80004eb6 <create+0x146>
    dp->nlink++; // for ".."
    80004ea4:	04a4d783          	lhu	a5,74(s1)
    80004ea8:	2785                	addiw	a5,a5,1
    80004eaa:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004eae:	8526                	mv	a0,s1
    80004eb0:	c28fe0ef          	jal	800032d8 <iupdate>
    80004eb4:	bf71                	j	80004e50 <create+0xe0>
  ip->nlink = 0;
    80004eb6:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    80004eba:	854e                	mv	a0,s3
    80004ebc:	c1cfe0ef          	jal	800032d8 <iupdate>
  iunlockput(ip);
    80004ec0:	854e                	mv	a0,s3
    80004ec2:	f1efe0ef          	jal	800035e0 <iunlockput>
  iunlockput(dp);
    80004ec6:	8526                	mv	a0,s1
    80004ec8:	f18fe0ef          	jal	800035e0 <iunlockput>
  return 0;
    80004ecc:	79a2                	ld	s3,40(sp)
    80004ece:	bf09                	j	80004de0 <create+0x70>
    return 0;
    80004ed0:	892a                	mv	s2,a0
    80004ed2:	b739                	j	80004de0 <create+0x70>

0000000080004ed4 <sys_dup>:
{
    80004ed4:	7179                	addi	sp,sp,-48
    80004ed6:	f406                	sd	ra,40(sp)
    80004ed8:	f022                	sd	s0,32(sp)
    80004eda:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004edc:	fd840613          	addi	a2,s0,-40
    80004ee0:	4581                	li	a1,0
    80004ee2:	4501                	li	a0,0
    80004ee4:	df3ff0ef          	jal	80004cd6 <argfd>
    return -1;
    80004ee8:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004eea:	02054363          	bltz	a0,80004f10 <sys_dup+0x3c>
    80004eee:	ec26                	sd	s1,24(sp)
    80004ef0:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004ef2:	fd843483          	ld	s1,-40(s0)
    80004ef6:	8526                	mv	a0,s1
    80004ef8:	e39ff0ef          	jal	80004d30 <fdalloc>
    80004efc:	892a                	mv	s2,a0
    return -1;
    80004efe:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004f00:	00054d63          	bltz	a0,80004f1a <sys_dup+0x46>
  filedup(f);
    80004f04:	8526                	mv	a0,s1
    80004f06:	b72ff0ef          	jal	80004278 <filedup>
  return fd;
    80004f0a:	87ca                	mv	a5,s2
    80004f0c:	64e2                	ld	s1,24(sp)
    80004f0e:	6942                	ld	s2,16(sp)
}
    80004f10:	853e                	mv	a0,a5
    80004f12:	70a2                	ld	ra,40(sp)
    80004f14:	7402                	ld	s0,32(sp)
    80004f16:	6145                	addi	sp,sp,48
    80004f18:	8082                	ret
    80004f1a:	64e2                	ld	s1,24(sp)
    80004f1c:	6942                	ld	s2,16(sp)
    80004f1e:	bfcd                	j	80004f10 <sys_dup+0x3c>

0000000080004f20 <sys_read>:
{
    80004f20:	7179                	addi	sp,sp,-48
    80004f22:	f406                	sd	ra,40(sp)
    80004f24:	f022                	sd	s0,32(sp)
    80004f26:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f28:	fd840593          	addi	a1,s0,-40
    80004f2c:	4505                	li	a0,1
    80004f2e:	a71fd0ef          	jal	8000299e <argaddr>
  argint(2, &n);
    80004f32:	fe440593          	addi	a1,s0,-28
    80004f36:	4509                	li	a0,2
    80004f38:	a4bfd0ef          	jal	80002982 <argint>
  if (argfd(0, 0, &f) < 0)
    80004f3c:	fe840613          	addi	a2,s0,-24
    80004f40:	4581                	li	a1,0
    80004f42:	4501                	li	a0,0
    80004f44:	d93ff0ef          	jal	80004cd6 <argfd>
    80004f48:	87aa                	mv	a5,a0
    return -1;
    80004f4a:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004f4c:	0007ca63          	bltz	a5,80004f60 <sys_read+0x40>
  return fileread(f, p, n);
    80004f50:	fe442603          	lw	a2,-28(s0)
    80004f54:	fd843583          	ld	a1,-40(s0)
    80004f58:	fe843503          	ld	a0,-24(s0)
    80004f5c:	c94ff0ef          	jal	800043f0 <fileread>
}
    80004f60:	70a2                	ld	ra,40(sp)
    80004f62:	7402                	ld	s0,32(sp)
    80004f64:	6145                	addi	sp,sp,48
    80004f66:	8082                	ret

0000000080004f68 <sys_write>:
{
    80004f68:	7179                	addi	sp,sp,-48
    80004f6a:	f406                	sd	ra,40(sp)
    80004f6c:	f022                	sd	s0,32(sp)
    80004f6e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f70:	fd840593          	addi	a1,s0,-40
    80004f74:	4505                	li	a0,1
    80004f76:	a29fd0ef          	jal	8000299e <argaddr>
  argint(2, &n);
    80004f7a:	fe440593          	addi	a1,s0,-28
    80004f7e:	4509                	li	a0,2
    80004f80:	a03fd0ef          	jal	80002982 <argint>
  if (argfd(0, 0, &f) < 0)
    80004f84:	fe840613          	addi	a2,s0,-24
    80004f88:	4581                	li	a1,0
    80004f8a:	4501                	li	a0,0
    80004f8c:	d4bff0ef          	jal	80004cd6 <argfd>
    80004f90:	87aa                	mv	a5,a0
    return -1;
    80004f92:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004f94:	0007ca63          	bltz	a5,80004fa8 <sys_write+0x40>
  return filewrite(f, p, n);
    80004f98:	fe442603          	lw	a2,-28(s0)
    80004f9c:	fd843583          	ld	a1,-40(s0)
    80004fa0:	fe843503          	ld	a0,-24(s0)
    80004fa4:	d1aff0ef          	jal	800044be <filewrite>
}
    80004fa8:	70a2                	ld	ra,40(sp)
    80004faa:	7402                	ld	s0,32(sp)
    80004fac:	6145                	addi	sp,sp,48
    80004fae:	8082                	ret

0000000080004fb0 <sys_close>:
{
    80004fb0:	1101                	addi	sp,sp,-32
    80004fb2:	ec06                	sd	ra,24(sp)
    80004fb4:	e822                	sd	s0,16(sp)
    80004fb6:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80004fb8:	fe040613          	addi	a2,s0,-32
    80004fbc:	fec40593          	addi	a1,s0,-20
    80004fc0:	4501                	li	a0,0
    80004fc2:	d15ff0ef          	jal	80004cd6 <argfd>
    return -1;
    80004fc6:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80004fc8:	02054163          	bltz	a0,80004fea <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004fcc:	97dfc0ef          	jal	80001948 <myproc>
    80004fd0:	fec42783          	lw	a5,-20(s0)
    80004fd4:	078e                	slli	a5,a5,0x3
    80004fd6:	0d078793          	addi	a5,a5,208
    80004fda:	953e                	add	a0,a0,a5
    80004fdc:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004fe0:	fe043503          	ld	a0,-32(s0)
    80004fe4:	adaff0ef          	jal	800042be <fileclose>
  return 0;
    80004fe8:	4781                	li	a5,0
}
    80004fea:	853e                	mv	a0,a5
    80004fec:	60e2                	ld	ra,24(sp)
    80004fee:	6442                	ld	s0,16(sp)
    80004ff0:	6105                	addi	sp,sp,32
    80004ff2:	8082                	ret

0000000080004ff4 <sys_fstat>:
{
    80004ff4:	1101                	addi	sp,sp,-32
    80004ff6:	ec06                	sd	ra,24(sp)
    80004ff8:	e822                	sd	s0,16(sp)
    80004ffa:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004ffc:	fe040593          	addi	a1,s0,-32
    80005000:	4505                	li	a0,1
    80005002:	99dfd0ef          	jal	8000299e <argaddr>
  if (argfd(0, 0, &f) < 0)
    80005006:	fe840613          	addi	a2,s0,-24
    8000500a:	4581                	li	a1,0
    8000500c:	4501                	li	a0,0
    8000500e:	cc9ff0ef          	jal	80004cd6 <argfd>
    80005012:	87aa                	mv	a5,a0
    return -1;
    80005014:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005016:	0007c863          	bltz	a5,80005026 <sys_fstat+0x32>
  return filestat(f, st);
    8000501a:	fe043583          	ld	a1,-32(s0)
    8000501e:	fe843503          	ld	a0,-24(s0)
    80005022:	b5eff0ef          	jal	80004380 <filestat>
}
    80005026:	60e2                	ld	ra,24(sp)
    80005028:	6442                	ld	s0,16(sp)
    8000502a:	6105                	addi	sp,sp,32
    8000502c:	8082                	ret

000000008000502e <sys_link>:
{
    8000502e:	7169                	addi	sp,sp,-304
    80005030:	f606                	sd	ra,296(sp)
    80005032:	f222                	sd	s0,288(sp)
    80005034:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005036:	08000613          	li	a2,128
    8000503a:	ed040593          	addi	a1,s0,-304
    8000503e:	4501                	li	a0,0
    80005040:	97bfd0ef          	jal	800029ba <argstr>
    return -1;
    80005044:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005046:	10054163          	bltz	a0,80005148 <sys_link+0x11a>
    8000504a:	08000613          	li	a2,128
    8000504e:	f5040593          	addi	a1,s0,-176
    80005052:	4505                	li	a0,1
    80005054:	967fd0ef          	jal	800029ba <argstr>
    return -1;
    80005058:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000505a:	0e054763          	bltz	a0,80005148 <sys_link+0x11a>
    8000505e:	ee26                	sd	s1,280(sp)
  begin_op();
    80005060:	da5fe0ef          	jal	80003e04 <begin_op>
  if ((ip = namei(old)) == 0) {
    80005064:	ed040513          	addi	a0,s0,-304
    80005068:	bbffe0ef          	jal	80003c26 <namei>
    8000506c:	84aa                	mv	s1,a0
    8000506e:	cd35                	beqz	a0,800050ea <sys_link+0xbc>
  ilock(ip);
    80005070:	b1cfe0ef          	jal	8000338c <ilock>
  if (ip->type == T_DIR) {
    80005074:	04449703          	lh	a4,68(s1)
    80005078:	4785                	li	a5,1
    8000507a:	06f70d63          	beq	a4,a5,800050f4 <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    8000507e:	04a49783          	lh	a5,74(s1)
    80005082:	6721                	lui	a4,0x8
    80005084:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80005086:	06e78f63          	beq	a5,a4,80005104 <sys_link+0xd6>
    8000508a:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000508c:	2785                	addiw	a5,a5,1
    8000508e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005092:	8526                	mv	a0,s1
    80005094:	a44fe0ef          	jal	800032d8 <iupdate>
  iunlock(ip);
    80005098:	8526                	mv	a0,s1
    8000509a:	ba0fe0ef          	jal	8000343a <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    8000509e:	fd040593          	addi	a1,s0,-48
    800050a2:	f5040513          	addi	a0,s0,-176
    800050a6:	b9bfe0ef          	jal	80003c40 <nameiparent>
    800050aa:	892a                	mv	s2,a0
    800050ac:	c93d                	beqz	a0,80005122 <sys_link+0xf4>
  ilock(dp);
    800050ae:	adefe0ef          	jal	8000338c <ilock>
  if (dp->nlink == 0) {
    800050b2:	04a91783          	lh	a5,74(s2)
    800050b6:	cfb9                	beqz	a5,80005114 <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    800050b8:	854a                	mv	a0,s2
    800050ba:	00092703          	lw	a4,0(s2)
    800050be:	409c                	lw	a5,0(s1)
    800050c0:	04f71e63          	bne	a4,a5,8000511c <sys_link+0xee>
    800050c4:	40d0                	lw	a2,4(s1)
    800050c6:	fd040593          	addi	a1,s0,-48
    800050ca:	ab3fe0ef          	jal	80003b7c <dirlink>
    800050ce:	04054763          	bltz	a0,8000511c <sys_link+0xee>
  iunlockput(dp);
    800050d2:	854a                	mv	a0,s2
    800050d4:	d0cfe0ef          	jal	800035e0 <iunlockput>
  iput(ip);
    800050d8:	8526                	mv	a0,s1
    800050da:	c34fe0ef          	jal	8000350e <iput>
  end_op();
    800050de:	db3fe0ef          	jal	80003e90 <end_op>
  return 0;
    800050e2:	4781                	li	a5,0
    800050e4:	64f2                	ld	s1,280(sp)
    800050e6:	6952                	ld	s2,272(sp)
    800050e8:	a085                	j	80005148 <sys_link+0x11a>
    end_op();
    800050ea:	da7fe0ef          	jal	80003e90 <end_op>
    return -1;
    800050ee:	57fd                	li	a5,-1
    800050f0:	64f2                	ld	s1,280(sp)
    800050f2:	a899                	j	80005148 <sys_link+0x11a>
    iunlockput(ip);
    800050f4:	8526                	mv	a0,s1
    800050f6:	ceafe0ef          	jal	800035e0 <iunlockput>
    end_op();
    800050fa:	d97fe0ef          	jal	80003e90 <end_op>
    return -1;
    800050fe:	57fd                	li	a5,-1
    80005100:	64f2                	ld	s1,280(sp)
    80005102:	a099                	j	80005148 <sys_link+0x11a>
    iunlockput(ip);
    80005104:	8526                	mv	a0,s1
    80005106:	cdafe0ef          	jal	800035e0 <iunlockput>
    end_op();
    8000510a:	d87fe0ef          	jal	80003e90 <end_op>
    return -1;
    8000510e:	57fd                	li	a5,-1
    80005110:	64f2                	ld	s1,280(sp)
    80005112:	a81d                	j	80005148 <sys_link+0x11a>
    iunlockput(dp);
    80005114:	854a                	mv	a0,s2
    80005116:	ccafe0ef          	jal	800035e0 <iunlockput>
    goto bad;
    8000511a:	a021                	j	80005122 <sys_link+0xf4>
    iunlockput(dp);
    8000511c:	854a                	mv	a0,s2
    8000511e:	cc2fe0ef          	jal	800035e0 <iunlockput>
  ilock(ip);
    80005122:	8526                	mv	a0,s1
    80005124:	a68fe0ef          	jal	8000338c <ilock>
  ip->nlink--;
    80005128:	04a4d783          	lhu	a5,74(s1)
    8000512c:	37fd                	addiw	a5,a5,-1
    8000512e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005132:	8526                	mv	a0,s1
    80005134:	9a4fe0ef          	jal	800032d8 <iupdate>
  iunlockput(ip);
    80005138:	8526                	mv	a0,s1
    8000513a:	ca6fe0ef          	jal	800035e0 <iunlockput>
  end_op();
    8000513e:	d53fe0ef          	jal	80003e90 <end_op>
  return -1;
    80005142:	57fd                	li	a5,-1
    80005144:	64f2                	ld	s1,280(sp)
    80005146:	6952                	ld	s2,272(sp)
}
    80005148:	853e                	mv	a0,a5
    8000514a:	70b2                	ld	ra,296(sp)
    8000514c:	7412                	ld	s0,288(sp)
    8000514e:	6155                	addi	sp,sp,304
    80005150:	8082                	ret

0000000080005152 <sys_unlink>:
{
    80005152:	7151                	addi	sp,sp,-240
    80005154:	f586                	sd	ra,232(sp)
    80005156:	f1a2                	sd	s0,224(sp)
    80005158:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    8000515a:	08000613          	li	a2,128
    8000515e:	f3040593          	addi	a1,s0,-208
    80005162:	4501                	li	a0,0
    80005164:	857fd0ef          	jal	800029ba <argstr>
    80005168:	14054d63          	bltz	a0,800052c2 <sys_unlink+0x170>
    8000516c:	eda6                	sd	s1,216(sp)
  begin_op();
    8000516e:	c97fe0ef          	jal	80003e04 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    80005172:	fb040593          	addi	a1,s0,-80
    80005176:	f3040513          	addi	a0,s0,-208
    8000517a:	ac7fe0ef          	jal	80003c40 <nameiparent>
    8000517e:	84aa                	mv	s1,a0
    80005180:	c955                	beqz	a0,80005234 <sys_unlink+0xe2>
  ilock(dp);
    80005182:	a0afe0ef          	jal	8000338c <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005186:	00002597          	auipc	a1,0x2
    8000518a:	45a58593          	addi	a1,a1,1114 # 800075e0 <etext+0x5e0>
    8000518e:	fb040513          	addi	a0,s0,-80
    80005192:	fccfe0ef          	jal	8000395e <namecmp>
    80005196:	10050b63          	beqz	a0,800052ac <sys_unlink+0x15a>
    8000519a:	00002597          	auipc	a1,0x2
    8000519e:	44e58593          	addi	a1,a1,1102 # 800075e8 <etext+0x5e8>
    800051a2:	fb040513          	addi	a0,s0,-80
    800051a6:	fb8fe0ef          	jal	8000395e <namecmp>
    800051aa:	10050163          	beqz	a0,800052ac <sys_unlink+0x15a>
    800051ae:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    800051b0:	f2c40613          	addi	a2,s0,-212
    800051b4:	fb040593          	addi	a1,s0,-80
    800051b8:	8526                	mv	a0,s1
    800051ba:	fbafe0ef          	jal	80003974 <dirlookup>
    800051be:	892a                	mv	s2,a0
    800051c0:	0e050563          	beqz	a0,800052aa <sys_unlink+0x158>
    800051c4:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    800051c6:	9c6fe0ef          	jal	8000338c <ilock>
  if (ip->nlink < 1)
    800051ca:	04a91783          	lh	a5,74(s2)
    800051ce:	06f05863          	blez	a5,8000523e <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    800051d2:	04491703          	lh	a4,68(s2)
    800051d6:	4785                	li	a5,1
    800051d8:	06f70963          	beq	a4,a5,8000524a <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    800051dc:	fc040993          	addi	s3,s0,-64
    800051e0:	4641                	li	a2,16
    800051e2:	4581                	li	a1,0
    800051e4:	854e                	mv	a0,s3
    800051e6:	b03fb0ef          	jal	80000ce8 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800051ea:	4741                	li	a4,16
    800051ec:	f2c42683          	lw	a3,-212(s0)
    800051f0:	864e                	mv	a2,s3
    800051f2:	4581                	li	a1,0
    800051f4:	8526                	mv	a0,s1
    800051f6:	e62fe0ef          	jal	80003858 <writei>
    800051fa:	47c1                	li	a5,16
    800051fc:	08f51863          	bne	a0,a5,8000528c <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    80005200:	04491703          	lh	a4,68(s2)
    80005204:	4785                	li	a5,1
    80005206:	08f70963          	beq	a4,a5,80005298 <sys_unlink+0x146>
  iunlockput(dp);
    8000520a:	8526                	mv	a0,s1
    8000520c:	bd4fe0ef          	jal	800035e0 <iunlockput>
  ip->nlink--;
    80005210:	04a95783          	lhu	a5,74(s2)
    80005214:	37fd                	addiw	a5,a5,-1
    80005216:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000521a:	854a                	mv	a0,s2
    8000521c:	8bcfe0ef          	jal	800032d8 <iupdate>
  iunlockput(ip);
    80005220:	854a                	mv	a0,s2
    80005222:	bbefe0ef          	jal	800035e0 <iunlockput>
  end_op();
    80005226:	c6bfe0ef          	jal	80003e90 <end_op>
  return 0;
    8000522a:	4501                	li	a0,0
    8000522c:	64ee                	ld	s1,216(sp)
    8000522e:	694e                	ld	s2,208(sp)
    80005230:	69ae                	ld	s3,200(sp)
    80005232:	a061                	j	800052ba <sys_unlink+0x168>
    end_op();
    80005234:	c5dfe0ef          	jal	80003e90 <end_op>
    return -1;
    80005238:	557d                	li	a0,-1
    8000523a:	64ee                	ld	s1,216(sp)
    8000523c:	a8bd                	j	800052ba <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    8000523e:	00002517          	auipc	a0,0x2
    80005242:	3b250513          	addi	a0,a0,946 # 800075f0 <etext+0x5f0>
    80005246:	deefb0ef          	jal	80000834 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    8000524a:	04c92703          	lw	a4,76(s2)
    8000524e:	02000793          	li	a5,32
    80005252:	f8e7f5e3          	bgeu	a5,a4,800051dc <sys_unlink+0x8a>
    80005256:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005258:	4741                	li	a4,16
    8000525a:	86ce                	mv	a3,s3
    8000525c:	f1840613          	addi	a2,s0,-232
    80005260:	4581                	li	a1,0
    80005262:	854a                	mv	a0,s2
    80005264:	d02fe0ef          	jal	80003766 <readi>
    80005268:	47c1                	li	a5,16
    8000526a:	00f51b63          	bne	a0,a5,80005280 <sys_unlink+0x12e>
    if (de.inum != 0)
    8000526e:	f1845783          	lhu	a5,-232(s0)
    80005272:	ebb1                	bnez	a5,800052c6 <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80005274:	29c1                	addiw	s3,s3,16
    80005276:	04c92783          	lw	a5,76(s2)
    8000527a:	fcf9efe3          	bltu	s3,a5,80005258 <sys_unlink+0x106>
    8000527e:	bfb9                	j	800051dc <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005280:	00002517          	auipc	a0,0x2
    80005284:	38850513          	addi	a0,a0,904 # 80007608 <etext+0x608>
    80005288:	dacfb0ef          	jal	80000834 <panic>
    panic("unlink: writei");
    8000528c:	00002517          	auipc	a0,0x2
    80005290:	39450513          	addi	a0,a0,916 # 80007620 <etext+0x620>
    80005294:	da0fb0ef          	jal	80000834 <panic>
    dp->nlink--;
    80005298:	04a4d783          	lhu	a5,74(s1)
    8000529c:	37fd                	addiw	a5,a5,-1
    8000529e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800052a2:	8526                	mv	a0,s1
    800052a4:	834fe0ef          	jal	800032d8 <iupdate>
    800052a8:	b78d                	j	8000520a <sys_unlink+0xb8>
    800052aa:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800052ac:	8526                	mv	a0,s1
    800052ae:	b32fe0ef          	jal	800035e0 <iunlockput>
  end_op();
    800052b2:	bdffe0ef          	jal	80003e90 <end_op>
  return -1;
    800052b6:	557d                	li	a0,-1
    800052b8:	64ee                	ld	s1,216(sp)
}
    800052ba:	70ae                	ld	ra,232(sp)
    800052bc:	740e                	ld	s0,224(sp)
    800052be:	616d                	addi	sp,sp,240
    800052c0:	8082                	ret
    return -1;
    800052c2:	557d                	li	a0,-1
    800052c4:	bfdd                	j	800052ba <sys_unlink+0x168>
    iunlockput(ip);
    800052c6:	854a                	mv	a0,s2
    800052c8:	b18fe0ef          	jal	800035e0 <iunlockput>
    goto bad;
    800052cc:	694e                	ld	s2,208(sp)
    800052ce:	69ae                	ld	s3,200(sp)
    800052d0:	bff1                	j	800052ac <sys_unlink+0x15a>

00000000800052d2 <sys_open>:

uint64
sys_open(void)
{
    800052d2:	7131                	addi	sp,sp,-192
    800052d4:	fd06                	sd	ra,184(sp)
    800052d6:	f922                	sd	s0,176(sp)
    800052d8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800052da:	f4c40593          	addi	a1,s0,-180
    800052de:	4505                	li	a0,1
    800052e0:	ea2fd0ef          	jal	80002982 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800052e4:	08000613          	li	a2,128
    800052e8:	f5040593          	addi	a1,s0,-176
    800052ec:	4501                	li	a0,0
    800052ee:	eccfd0ef          	jal	800029ba <argstr>
    800052f2:	87aa                	mv	a5,a0
    return -1;
    800052f4:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800052f6:	0a07c363          	bltz	a5,8000539c <sys_open+0xca>
    800052fa:	f526                	sd	s1,168(sp)

  begin_op();
    800052fc:	b09fe0ef          	jal	80003e04 <begin_op>

  if (omode & O_CREATE) {
    80005300:	f4c42783          	lw	a5,-180(s0)
    80005304:	2007f793          	andi	a5,a5,512
    80005308:	c3dd                	beqz	a5,800053ae <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    8000530a:	4681                	li	a3,0
    8000530c:	4601                	li	a2,0
    8000530e:	4589                	li	a1,2
    80005310:	f5040513          	addi	a0,s0,-176
    80005314:	a5dff0ef          	jal	80004d70 <create>
    80005318:	84aa                	mv	s1,a0
    if (ip == 0) {
    8000531a:	c549                	beqz	a0,800053a4 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    8000531c:	04449703          	lh	a4,68(s1)
    80005320:	478d                	li	a5,3
    80005322:	00f71763          	bne	a4,a5,80005330 <sys_open+0x5e>
    80005326:	0464d703          	lhu	a4,70(s1)
    8000532a:	47a5                	li	a5,9
    8000532c:	0ae7ee63          	bltu	a5,a4,800053e8 <sys_open+0x116>
    80005330:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    80005332:	ee9fe0ef          	jal	8000421a <filealloc>
    80005336:	892a                	mv	s2,a0
    80005338:	c561                	beqz	a0,80005400 <sys_open+0x12e>
    8000533a:	ed4e                	sd	s3,152(sp)
    8000533c:	9f5ff0ef          	jal	80004d30 <fdalloc>
    80005340:	89aa                	mv	s3,a0
    80005342:	0a054b63          	bltz	a0,800053f8 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    80005346:	04449703          	lh	a4,68(s1)
    8000534a:	478d                	li	a5,3
    8000534c:	0cf70363          	beq	a4,a5,80005412 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005350:	4789                	li	a5,2
    80005352:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005356:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000535a:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000535e:	f4c42783          	lw	a5,-180(s0)
    80005362:	0017f713          	andi	a4,a5,1
    80005366:	00174713          	xori	a4,a4,1
    8000536a:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000536e:	0037f713          	andi	a4,a5,3
    80005372:	00e03733          	snez	a4,a4
    80005376:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    8000537a:	4007f793          	andi	a5,a5,1024
    8000537e:	c791                	beqz	a5,8000538a <sys_open+0xb8>
    80005380:	04449703          	lh	a4,68(s1)
    80005384:	4789                	li	a5,2
    80005386:	08f70d63          	beq	a4,a5,80005420 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    8000538a:	8526                	mv	a0,s1
    8000538c:	8aefe0ef          	jal	8000343a <iunlock>
  end_op();
    80005390:	b01fe0ef          	jal	80003e90 <end_op>

  return fd;
    80005394:	854e                	mv	a0,s3
    80005396:	74aa                	ld	s1,168(sp)
    80005398:	790a                	ld	s2,160(sp)
    8000539a:	69ea                	ld	s3,152(sp)
}
    8000539c:	70ea                	ld	ra,184(sp)
    8000539e:	744a                	ld	s0,176(sp)
    800053a0:	6129                	addi	sp,sp,192
    800053a2:	8082                	ret
      end_op();
    800053a4:	aedfe0ef          	jal	80003e90 <end_op>
      return -1;
    800053a8:	557d                	li	a0,-1
    800053aa:	74aa                	ld	s1,168(sp)
    800053ac:	bfc5                	j	8000539c <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    800053ae:	f5040513          	addi	a0,s0,-176
    800053b2:	875fe0ef          	jal	80003c26 <namei>
    800053b6:	84aa                	mv	s1,a0
    800053b8:	c11d                	beqz	a0,800053de <sys_open+0x10c>
    ilock(ip);
    800053ba:	fd3fd0ef          	jal	8000338c <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    800053be:	04449703          	lh	a4,68(s1)
    800053c2:	4785                	li	a5,1
    800053c4:	f4f71ce3          	bne	a4,a5,8000531c <sys_open+0x4a>
    800053c8:	f4c42783          	lw	a5,-180(s0)
    800053cc:	d3b5                	beqz	a5,80005330 <sys_open+0x5e>
      iunlockput(ip);
    800053ce:	8526                	mv	a0,s1
    800053d0:	a10fe0ef          	jal	800035e0 <iunlockput>
      end_op();
    800053d4:	abdfe0ef          	jal	80003e90 <end_op>
      return -1;
    800053d8:	557d                	li	a0,-1
    800053da:	74aa                	ld	s1,168(sp)
    800053dc:	b7c1                	j	8000539c <sys_open+0xca>
      end_op();
    800053de:	ab3fe0ef          	jal	80003e90 <end_op>
      return -1;
    800053e2:	557d                	li	a0,-1
    800053e4:	74aa                	ld	s1,168(sp)
    800053e6:	bf5d                	j	8000539c <sys_open+0xca>
    iunlockput(ip);
    800053e8:	8526                	mv	a0,s1
    800053ea:	9f6fe0ef          	jal	800035e0 <iunlockput>
    end_op();
    800053ee:	aa3fe0ef          	jal	80003e90 <end_op>
    return -1;
    800053f2:	557d                	li	a0,-1
    800053f4:	74aa                	ld	s1,168(sp)
    800053f6:	b75d                	j	8000539c <sys_open+0xca>
      fileclose(f);
    800053f8:	854a                	mv	a0,s2
    800053fa:	ec5fe0ef          	jal	800042be <fileclose>
    800053fe:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005400:	8526                	mv	a0,s1
    80005402:	9defe0ef          	jal	800035e0 <iunlockput>
    end_op();
    80005406:	a8bfe0ef          	jal	80003e90 <end_op>
    return -1;
    8000540a:	557d                	li	a0,-1
    8000540c:	74aa                	ld	s1,168(sp)
    8000540e:	790a                	ld	s2,160(sp)
    80005410:	b771                	j	8000539c <sys_open+0xca>
    f->type = FD_DEVICE;
    80005412:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005416:	04649783          	lh	a5,70(s1)
    8000541a:	02f91223          	sh	a5,36(s2)
    8000541e:	bf35                	j	8000535a <sys_open+0x88>
    itrunc(ip);
    80005420:	8526                	mv	a0,s1
    80005422:	858fe0ef          	jal	8000347a <itrunc>
    80005426:	b795                	j	8000538a <sys_open+0xb8>

0000000080005428 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005428:	7175                	addi	sp,sp,-144
    8000542a:	e506                	sd	ra,136(sp)
    8000542c:	e122                	sd	s0,128(sp)
    8000542e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005430:	9d5fe0ef          	jal	80003e04 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    80005434:	08000613          	li	a2,128
    80005438:	f7040593          	addi	a1,s0,-144
    8000543c:	4501                	li	a0,0
    8000543e:	d7cfd0ef          	jal	800029ba <argstr>
    80005442:	02054363          	bltz	a0,80005468 <sys_mkdir+0x40>
    80005446:	4681                	li	a3,0
    80005448:	4601                	li	a2,0
    8000544a:	4585                	li	a1,1
    8000544c:	f7040513          	addi	a0,s0,-144
    80005450:	921ff0ef          	jal	80004d70 <create>
    80005454:	c911                	beqz	a0,80005468 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005456:	98afe0ef          	jal	800035e0 <iunlockput>
  end_op();
    8000545a:	a37fe0ef          	jal	80003e90 <end_op>
  return 0;
    8000545e:	4501                	li	a0,0
}
    80005460:	60aa                	ld	ra,136(sp)
    80005462:	640a                	ld	s0,128(sp)
    80005464:	6149                	addi	sp,sp,144
    80005466:	8082                	ret
    end_op();
    80005468:	a29fe0ef          	jal	80003e90 <end_op>
    return -1;
    8000546c:	557d                	li	a0,-1
    8000546e:	bfcd                	j	80005460 <sys_mkdir+0x38>

0000000080005470 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005470:	7135                	addi	sp,sp,-160
    80005472:	ed06                	sd	ra,152(sp)
    80005474:	e922                	sd	s0,144(sp)
    80005476:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005478:	98dfe0ef          	jal	80003e04 <begin_op>
  argint(1, &major);
    8000547c:	f6c40593          	addi	a1,s0,-148
    80005480:	4505                	li	a0,1
    80005482:	d00fd0ef          	jal	80002982 <argint>
  argint(2, &minor);
    80005486:	f6840593          	addi	a1,s0,-152
    8000548a:	4509                	li	a0,2
    8000548c:	cf6fd0ef          	jal	80002982 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005490:	08000613          	li	a2,128
    80005494:	f7040593          	addi	a1,s0,-144
    80005498:	4501                	li	a0,0
    8000549a:	d20fd0ef          	jal	800029ba <argstr>
    8000549e:	02054563          	bltz	a0,800054c8 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    800054a2:	f6841683          	lh	a3,-152(s0)
    800054a6:	f6c41603          	lh	a2,-148(s0)
    800054aa:	458d                	li	a1,3
    800054ac:	f7040513          	addi	a0,s0,-144
    800054b0:	8c1ff0ef          	jal	80004d70 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800054b4:	c911                	beqz	a0,800054c8 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800054b6:	92afe0ef          	jal	800035e0 <iunlockput>
  end_op();
    800054ba:	9d7fe0ef          	jal	80003e90 <end_op>
  return 0;
    800054be:	4501                	li	a0,0
}
    800054c0:	60ea                	ld	ra,152(sp)
    800054c2:	644a                	ld	s0,144(sp)
    800054c4:	610d                	addi	sp,sp,160
    800054c6:	8082                	ret
    end_op();
    800054c8:	9c9fe0ef          	jal	80003e90 <end_op>
    return -1;
    800054cc:	557d                	li	a0,-1
    800054ce:	bfcd                	j	800054c0 <sys_mknod+0x50>

00000000800054d0 <sys_chdir>:

uint64
sys_chdir(void)
{
    800054d0:	7135                	addi	sp,sp,-160
    800054d2:	ed06                	sd	ra,152(sp)
    800054d4:	e922                	sd	s0,144(sp)
    800054d6:	e14a                	sd	s2,128(sp)
    800054d8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800054da:	c6efc0ef          	jal	80001948 <myproc>
    800054de:	892a                	mv	s2,a0

  begin_op();
    800054e0:	925fe0ef          	jal	80003e04 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    800054e4:	08000613          	li	a2,128
    800054e8:	f6040593          	addi	a1,s0,-160
    800054ec:	4501                	li	a0,0
    800054ee:	cccfd0ef          	jal	800029ba <argstr>
    800054f2:	04054363          	bltz	a0,80005538 <sys_chdir+0x68>
    800054f6:	e526                	sd	s1,136(sp)
    800054f8:	f6040513          	addi	a0,s0,-160
    800054fc:	f2afe0ef          	jal	80003c26 <namei>
    80005500:	84aa                	mv	s1,a0
    80005502:	c915                	beqz	a0,80005536 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005504:	e89fd0ef          	jal	8000338c <ilock>
  if (ip->type != T_DIR) {
    80005508:	04449703          	lh	a4,68(s1)
    8000550c:	4785                	li	a5,1
    8000550e:	02f71963          	bne	a4,a5,80005540 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005512:	8526                	mv	a0,s1
    80005514:	f27fd0ef          	jal	8000343a <iunlock>
  iput(p->cwd);
    80005518:	15093503          	ld	a0,336(s2)
    8000551c:	ff3fd0ef          	jal	8000350e <iput>
  end_op();
    80005520:	971fe0ef          	jal	80003e90 <end_op>
  p->cwd = ip;
    80005524:	14993823          	sd	s1,336(s2)
  return 0;
    80005528:	4501                	li	a0,0
    8000552a:	64aa                	ld	s1,136(sp)
}
    8000552c:	60ea                	ld	ra,152(sp)
    8000552e:	644a                	ld	s0,144(sp)
    80005530:	690a                	ld	s2,128(sp)
    80005532:	610d                	addi	sp,sp,160
    80005534:	8082                	ret
    80005536:	64aa                	ld	s1,136(sp)
    end_op();
    80005538:	959fe0ef          	jal	80003e90 <end_op>
    return -1;
    8000553c:	557d                	li	a0,-1
    8000553e:	b7fd                	j	8000552c <sys_chdir+0x5c>
    iunlockput(ip);
    80005540:	8526                	mv	a0,s1
    80005542:	89efe0ef          	jal	800035e0 <iunlockput>
    end_op();
    80005546:	94bfe0ef          	jal	80003e90 <end_op>
    return -1;
    8000554a:	557d                	li	a0,-1
    8000554c:	64aa                	ld	s1,136(sp)
    8000554e:	bff9                	j	8000552c <sys_chdir+0x5c>

0000000080005550 <sys_exec>:

uint64
sys_exec(void)
{
    80005550:	7105                	addi	sp,sp,-480
    80005552:	ef86                	sd	ra,472(sp)
    80005554:	eba2                	sd	s0,464(sp)
    80005556:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005558:	e2840593          	addi	a1,s0,-472
    8000555c:	4505                	li	a0,1
    8000555e:	c40fd0ef          	jal	8000299e <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    80005562:	08000613          	li	a2,128
    80005566:	f3040593          	addi	a1,s0,-208
    8000556a:	4501                	li	a0,0
    8000556c:	c4efd0ef          	jal	800029ba <argstr>
    80005570:	87aa                	mv	a5,a0
    return -1;
    80005572:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    80005574:	0e07c063          	bltz	a5,80005654 <sys_exec+0x104>
    80005578:	e7a6                	sd	s1,456(sp)
    8000557a:	e3ca                	sd	s2,448(sp)
    8000557c:	ff4e                	sd	s3,440(sp)
    8000557e:	fb52                	sd	s4,432(sp)
    80005580:	f756                	sd	s5,424(sp)
    80005582:	f35a                	sd	s6,416(sp)
    80005584:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005586:	e3040a13          	addi	s4,s0,-464
    8000558a:	10000613          	li	a2,256
    8000558e:	4581                	li	a1,0
    80005590:	8552                	mv	a0,s4
    80005592:	f56fb0ef          	jal	80000ce8 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    80005596:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005598:	89d2                	mv	s3,s4
    8000559a:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    8000559c:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800055a0:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    800055a2:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    800055a6:	00391513          	slli	a0,s2,0x3
    800055aa:	85d6                	mv	a1,s5
    800055ac:	e2843783          	ld	a5,-472(s0)
    800055b0:	953e                	add	a0,a0,a5
    800055b2:	b44fd0ef          	jal	800028f6 <fetchaddr>
    800055b6:	02054663          	bltz	a0,800055e2 <sys_exec+0x92>
    if (uarg == 0) {
    800055ba:	e2043783          	ld	a5,-480(s0)
    800055be:	c7a1                	beqz	a5,80005606 <sys_exec+0xb6>
    argv[i] = kalloc();
    800055c0:	d8efb0ef          	jal	80000b4e <kalloc>
    800055c4:	85aa                	mv	a1,a0
    800055c6:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    800055ca:	cd01                	beqz	a0,800055e2 <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800055cc:	865a                	mv	a2,s6
    800055ce:	e2043503          	ld	a0,-480(s0)
    800055d2:	b6efd0ef          	jal	80002940 <fetchstr>
    800055d6:	00054663          	bltz	a0,800055e2 <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    800055da:	0905                	addi	s2,s2,1
    800055dc:	09a1                	addi	s3,s3,8
    800055de:	fd7914e3          	bne	s2,s7,800055a6 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055e2:	100a0a13          	addi	s4,s4,256
    800055e6:	6088                	ld	a0,0(s1)
    800055e8:	cd31                	beqz	a0,80005644 <sys_exec+0xf4>
    kfree(argv[i]);
    800055ea:	c7cfb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055ee:	04a1                	addi	s1,s1,8
    800055f0:	ff449be3          	bne	s1,s4,800055e6 <sys_exec+0x96>
  return -1;
    800055f4:	557d                	li	a0,-1
    800055f6:	64be                	ld	s1,456(sp)
    800055f8:	691e                	ld	s2,448(sp)
    800055fa:	79fa                	ld	s3,440(sp)
    800055fc:	7a5a                	ld	s4,432(sp)
    800055fe:	7aba                	ld	s5,424(sp)
    80005600:	7b1a                	ld	s6,416(sp)
    80005602:	6bfa                	ld	s7,408(sp)
    80005604:	a881                	j	80005654 <sys_exec+0x104>
      argv[i] = 0;
    80005606:	0009079b          	sext.w	a5,s2
    8000560a:	e3040593          	addi	a1,s0,-464
    8000560e:	078e                	slli	a5,a5,0x3
    80005610:	97ae                	add	a5,a5,a1
    80005612:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    80005616:	f3040513          	addi	a0,s0,-208
    8000561a:	b62ff0ef          	jal	8000497c <kexec>
    8000561e:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005620:	100a0a13          	addi	s4,s4,256
    80005624:	6088                	ld	a0,0(s1)
    80005626:	c511                	beqz	a0,80005632 <sys_exec+0xe2>
    kfree(argv[i]);
    80005628:	c3efb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000562c:	04a1                	addi	s1,s1,8
    8000562e:	ff449be3          	bne	s1,s4,80005624 <sys_exec+0xd4>
  return ret;
    80005632:	854a                	mv	a0,s2
    80005634:	64be                	ld	s1,456(sp)
    80005636:	691e                	ld	s2,448(sp)
    80005638:	79fa                	ld	s3,440(sp)
    8000563a:	7a5a                	ld	s4,432(sp)
    8000563c:	7aba                	ld	s5,424(sp)
    8000563e:	7b1a                	ld	s6,416(sp)
    80005640:	6bfa                	ld	s7,408(sp)
    80005642:	a809                	j	80005654 <sys_exec+0x104>
  return -1;
    80005644:	557d                	li	a0,-1
    80005646:	64be                	ld	s1,456(sp)
    80005648:	691e                	ld	s2,448(sp)
    8000564a:	79fa                	ld	s3,440(sp)
    8000564c:	7a5a                	ld	s4,432(sp)
    8000564e:	7aba                	ld	s5,424(sp)
    80005650:	7b1a                	ld	s6,416(sp)
    80005652:	6bfa                	ld	s7,408(sp)
}
    80005654:	60fe                	ld	ra,472(sp)
    80005656:	645e                	ld	s0,464(sp)
    80005658:	613d                	addi	sp,sp,480
    8000565a:	8082                	ret

000000008000565c <sys_pipe>:

uint64
sys_pipe(void)
{
    8000565c:	7139                	addi	sp,sp,-64
    8000565e:	fc06                	sd	ra,56(sp)
    80005660:	f822                	sd	s0,48(sp)
    80005662:	f426                	sd	s1,40(sp)
    80005664:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005666:	ae2fc0ef          	jal	80001948 <myproc>
    8000566a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000566c:	fd840593          	addi	a1,s0,-40
    80005670:	4501                	li	a0,0
    80005672:	b2cfd0ef          	jal	8000299e <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    80005676:	fc840593          	addi	a1,s0,-56
    8000567a:	fd040513          	addi	a0,s0,-48
    8000567e:	f7ffe0ef          	jal	800045fc <pipealloc>
    return -1;
    80005682:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    80005684:	0a054963          	bltz	a0,80005736 <sys_pipe+0xda>
  fd0 = -1;
    80005688:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    8000568c:	fd043503          	ld	a0,-48(s0)
    80005690:	ea0ff0ef          	jal	80004d30 <fdalloc>
    80005694:	fca42223          	sw	a0,-60(s0)
    80005698:	08054663          	bltz	a0,80005724 <sys_pipe+0xc8>
    8000569c:	fc843503          	ld	a0,-56(s0)
    800056a0:	e90ff0ef          	jal	80004d30 <fdalloc>
    800056a4:	fca42023          	sw	a0,-64(s0)
    800056a8:	06054463          	bltz	a0,80005710 <sys_pipe+0xb4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800056ac:	4711                	li	a4,4
    800056ae:	fc440693          	addi	a3,s0,-60
    800056b2:	fd843603          	ld	a2,-40(s0)
    800056b6:	64ac                	ld	a1,72(s1)
    800056b8:	68a8                	ld	a0,80(s1)
    800056ba:	ec9fb0ef          	jal	80001582 <copyout>
    800056be:	00054f63          	bltz	a0,800056dc <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    800056c2:	4711                	li	a4,4
    800056c4:	fc040693          	addi	a3,s0,-64
    800056c8:	fd843603          	ld	a2,-40(s0)
    800056cc:	963a                	add	a2,a2,a4
    800056ce:	64ac                	ld	a1,72(s1)
    800056d0:	68a8                	ld	a0,80(s1)
    800056d2:	eb1fb0ef          	jal	80001582 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800056d6:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800056d8:	04055f63          	bgez	a0,80005736 <sys_pipe+0xda>
    p->ofile[fd0] = 0;
    800056dc:	fc442783          	lw	a5,-60(s0)
    800056e0:	078e                	slli	a5,a5,0x3
    800056e2:	0d078793          	addi	a5,a5,208
    800056e6:	97a6                	add	a5,a5,s1
    800056e8:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800056ec:	fc042783          	lw	a5,-64(s0)
    800056f0:	078e                	slli	a5,a5,0x3
    800056f2:	0d078793          	addi	a5,a5,208
    800056f6:	94be                	add	s1,s1,a5
    800056f8:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800056fc:	fd043503          	ld	a0,-48(s0)
    80005700:	bbffe0ef          	jal	800042be <fileclose>
    fileclose(wf);
    80005704:	fc843503          	ld	a0,-56(s0)
    80005708:	bb7fe0ef          	jal	800042be <fileclose>
    return -1;
    8000570c:	57fd                	li	a5,-1
    8000570e:	a025                	j	80005736 <sys_pipe+0xda>
    if (fd0 >= 0)
    80005710:	fc442783          	lw	a5,-60(s0)
    80005714:	0007c863          	bltz	a5,80005724 <sys_pipe+0xc8>
      p->ofile[fd0] = 0;
    80005718:	078e                	slli	a5,a5,0x3
    8000571a:	0d078793          	addi	a5,a5,208
    8000571e:	97a6                	add	a5,a5,s1
    80005720:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005724:	fd043503          	ld	a0,-48(s0)
    80005728:	b97fe0ef          	jal	800042be <fileclose>
    fileclose(wf);
    8000572c:	fc843503          	ld	a0,-56(s0)
    80005730:	b8ffe0ef          	jal	800042be <fileclose>
    return -1;
    80005734:	57fd                	li	a5,-1
}
    80005736:	853e                	mv	a0,a5
    80005738:	70e2                	ld	ra,56(sp)
    8000573a:	7442                	ld	s0,48(sp)
    8000573c:	74a2                	ld	s1,40(sp)
    8000573e:	6121                	addi	sp,sp,64
    80005740:	8082                	ret
	...

0000000080005750 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005750:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005752:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005754:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    80005756:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005758:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000575a:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000575c:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    8000575e:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005760:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005762:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005764:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005766:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005768:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000576a:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000576c:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    8000576e:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005770:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005772:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005774:	8a2fd0ef          	jal	80002816 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005778:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000577a:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000577c:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    8000577e:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005780:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005782:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005784:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005786:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005788:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000578a:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000578c:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    8000578e:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005790:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005792:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005794:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005796:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005798:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000579a:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000579c:	10200073          	sret
    800057a0:	0001                	nop
    800057a2:	00000013          	nop
    800057a6:	00000013          	nop
    800057aa:	00000013          	nop

00000000800057ae <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800057ae:	1141                	addi	sp,sp,-16
    800057b0:	e406                	sd	ra,8(sp)
    800057b2:	e022                	sd	s0,0(sp)
    800057b4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(volatile uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    800057b6:	0c000737          	lui	a4,0xc000
    800057ba:	4785                	li	a5,1
    800057bc:	d71c                	sw	a5,40(a4)
  *(volatile uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    800057be:	c35c                	sw	a5,4(a4)
}
    800057c0:	60a2                	ld	ra,8(sp)
    800057c2:	6402                	ld	s0,0(sp)
    800057c4:	0141                	addi	sp,sp,16
    800057c6:	8082                	ret

00000000800057c8 <plicinithart>:

void
plicinithart(void)
{
    800057c8:	1141                	addi	sp,sp,-16
    800057ca:	e406                	sd	ra,8(sp)
    800057cc:	e022                	sd	s0,0(sp)
    800057ce:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800057d0:	944fc0ef          	jal	80001914 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(volatile uint32 *)PLIC_SENABLE(hart) =
    800057d4:	0085179b          	slliw	a5,a0,0x8
    800057d8:	0c002737          	lui	a4,0xc002
    800057dc:	08070713          	addi	a4,a4,128 # c002080 <_entry-0x73ffdf80>
    800057e0:	97ba                	add	a5,a5,a4
    800057e2:	40200713          	li	a4,1026
    800057e6:	c398                	sw	a4,0(a5)
    (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);

  // set this hart's S-mode priority threshold to 0.
  *(volatile uint32 *)PLIC_SPRIORITY(hart) = 0;
    800057e8:	00d5151b          	slliw	a0,a0,0xd
    800057ec:	0c2017b7          	lui	a5,0xc201
    800057f0:	953e                	add	a0,a0,a5
    800057f2:	00052023          	sw	zero,0(a0)
}
    800057f6:	60a2                	ld	ra,8(sp)
    800057f8:	6402                	ld	s0,0(sp)
    800057fa:	0141                	addi	sp,sp,16
    800057fc:	8082                	ret

00000000800057fe <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800057fe:	1141                	addi	sp,sp,-16
    80005800:	e406                	sd	ra,8(sp)
    80005802:	e022                	sd	s0,0(sp)
    80005804:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005806:	90efc0ef          	jal	80001914 <cpuid>
  int irq = *(volatile uint32 *)PLIC_SCLAIM(hart);
    8000580a:	00d5151b          	slliw	a0,a0,0xd
    8000580e:	0c2017b7          	lui	a5,0xc201
    80005812:	0791                	addi	a5,a5,4 # c201004 <_entry-0x73dfeffc>
    80005814:	953e                	add	a0,a0,a5
    80005816:	4108                	lw	a0,0(a0)
  return irq;
}
    80005818:	60a2                	ld	ra,8(sp)
    8000581a:	6402                	ld	s0,0(sp)
    8000581c:	0141                	addi	sp,sp,16
    8000581e:	8082                	ret

0000000080005820 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005820:	1101                	addi	sp,sp,-32
    80005822:	ec06                	sd	ra,24(sp)
    80005824:	e822                	sd	s0,16(sp)
    80005826:	e426                	sd	s1,8(sp)
    80005828:	1000                	addi	s0,sp,32
    8000582a:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000582c:	8e8fc0ef          	jal	80001914 <cpuid>
  *(volatile uint32 *)PLIC_SCLAIM(hart) = irq;
    80005830:	00d5179b          	slliw	a5,a0,0xd
    80005834:	0c201737          	lui	a4,0xc201
    80005838:	0711                	addi	a4,a4,4 # c201004 <_entry-0x73dfeffc>
    8000583a:	97ba                	add	a5,a5,a4
    8000583c:	c384                	sw	s1,0(a5)
}
    8000583e:	60e2                	ld	ra,24(sp)
    80005840:	6442                	ld	s0,16(sp)
    80005842:	64a2                	ld	s1,8(sp)
    80005844:	6105                	addi	sp,sp,32
    80005846:	8082                	ret

0000000080005848 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005848:	1141                	addi	sp,sp,-16
    8000584a:	e406                	sd	ra,8(sp)
    8000584c:	e022                	sd	s0,0(sp)
    8000584e:	0800                	addi	s0,sp,16
  if (i >= NUM)
    80005850:	479d                	li	a5,7
    80005852:	04a7ca63          	blt	a5,a0,800058a6 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    80005856:	0001e797          	auipc	a5,0x1e
    8000585a:	ee278793          	addi	a5,a5,-286 # 80023738 <disk>
    8000585e:	97aa                	add	a5,a5,a0
    80005860:	0187c783          	lbu	a5,24(a5)
    80005864:	e7b9                	bnez	a5,800058b2 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005866:	00451693          	slli	a3,a0,0x4
    8000586a:	0001e797          	auipc	a5,0x1e
    8000586e:	ece78793          	addi	a5,a5,-306 # 80023738 <disk>
    80005872:	6398                	ld	a4,0(a5)
    80005874:	9736                	add	a4,a4,a3
    80005876:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000587a:	6398                	ld	a4,0(a5)
    8000587c:	9736                	add	a4,a4,a3
    8000587e:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005882:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005886:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000588a:	97aa                	add	a5,a5,a0
    8000588c:	4705                	li	a4,1
    8000588e:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005892:	0001e517          	auipc	a0,0x1e
    80005896:	ebe50513          	addi	a0,a0,-322 # 80023750 <disk+0x18>
    8000589a:	845fc0ef          	jal	800020de <wakeup>
}
    8000589e:	60a2                	ld	ra,8(sp)
    800058a0:	6402                	ld	s0,0(sp)
    800058a2:	0141                	addi	sp,sp,16
    800058a4:	8082                	ret
    panic("free_desc 1");
    800058a6:	00002517          	auipc	a0,0x2
    800058aa:	d8a50513          	addi	a0,a0,-630 # 80007630 <etext+0x630>
    800058ae:	f87fa0ef          	jal	80000834 <panic>
    panic("free_desc 2");
    800058b2:	00002517          	auipc	a0,0x2
    800058b6:	d8e50513          	addi	a0,a0,-626 # 80007640 <etext+0x640>
    800058ba:	f7bfa0ef          	jal	80000834 <panic>

00000000800058be <virtio_disk_init>:
{
    800058be:	1101                	addi	sp,sp,-32
    800058c0:	ec06                	sd	ra,24(sp)
    800058c2:	e822                	sd	s0,16(sp)
    800058c4:	e426                	sd	s1,8(sp)
    800058c6:	e04a                	sd	s2,0(sp)
    800058c8:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800058ca:	00002597          	auipc	a1,0x2
    800058ce:	d8658593          	addi	a1,a1,-634 # 80007650 <etext+0x650>
    800058d2:	0001e517          	auipc	a0,0x1e
    800058d6:	f8e50513          	addi	a0,a0,-114 # 80023860 <disk+0x128>
    800058da:	acefb0ef          	jal	80000ba8 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800058de:	100017b7          	lui	a5,0x10001
    800058e2:	4398                	lw	a4,0(a5)
    800058e4:	2701                	sext.w	a4,a4
    800058e6:	747277b7          	lui	a5,0x74727
    800058ea:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800058ee:	14f71863          	bne	a4,a5,80005a3e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800058f2:	100017b7          	lui	a5,0x10001
    800058f6:	43dc                	lw	a5,4(a5)
    800058f8:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800058fa:	4709                	li	a4,2
    800058fc:	14e79163          	bne	a5,a4,80005a3e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005900:	100017b7          	lui	a5,0x10001
    80005904:	479c                	lw	a5,8(a5)
    80005906:	2781                	sext.w	a5,a5
    80005908:	12e79b63          	bne	a5,a4,80005a3e <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    8000590c:	100017b7          	lui	a5,0x10001
    80005910:	47d8                	lw	a4,12(a5)
    80005912:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005914:	554d47b7          	lui	a5,0x554d4
    80005918:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000591c:	12f71163          	bne	a4,a5,80005a3e <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005920:	100017b7          	lui	a5,0x10001
    80005924:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005928:	4705                	li	a4,1
    8000592a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000592c:	470d                	li	a4,3
    8000592e:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005930:	10001737          	lui	a4,0x10001
    80005934:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005936:	c7ffe6b7          	lui	a3,0xc7ffe
    8000593a:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fdace7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000593e:	8f75                	and	a4,a4,a3
    80005940:	100016b7          	lui	a3,0x10001
    80005944:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005946:	472d                	li	a4,11
    80005948:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000594a:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000594e:	439c                	lw	a5,0(a5)
    80005950:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005954:	8ba1                	andi	a5,a5,8
    80005956:	0e078a63          	beqz	a5,80005a4a <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000595a:	100017b7          	lui	a5,0x10001
    8000595e:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80005962:	43fc                	lw	a5,68(a5)
    80005964:	2781                	sext.w	a5,a5
    80005966:	0e079863          	bnez	a5,80005a56 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000596a:	100017b7          	lui	a5,0x10001
    8000596e:	5bdc                	lw	a5,52(a5)
    80005970:	2781                	sext.w	a5,a5
  if (max == 0)
    80005972:	0e078863          	beqz	a5,80005a62 <virtio_disk_init+0x1a4>
  if (max < NUM)
    80005976:	471d                	li	a4,7
    80005978:	0ef77b63          	bgeu	a4,a5,80005a6e <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    8000597c:	9d2fb0ef          	jal	80000b4e <kalloc>
    80005980:	0001e497          	auipc	s1,0x1e
    80005984:	db848493          	addi	s1,s1,-584 # 80023738 <disk>
    80005988:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    8000598a:	9c4fb0ef          	jal	80000b4e <kalloc>
    8000598e:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005990:	9befb0ef          	jal	80000b4e <kalloc>
    80005994:	87aa                	mv	a5,a0
    80005996:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005998:	6088                	ld	a0,0(s1)
    8000599a:	0e050063          	beqz	a0,80005a7a <virtio_disk_init+0x1bc>
    8000599e:	0001e717          	auipc	a4,0x1e
    800059a2:	da273703          	ld	a4,-606(a4) # 80023740 <disk+0x8>
    800059a6:	cb71                	beqz	a4,80005a7a <virtio_disk_init+0x1bc>
    800059a8:	cbe9                	beqz	a5,80005a7a <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    800059aa:	6605                	lui	a2,0x1
    800059ac:	4581                	li	a1,0
    800059ae:	b3afb0ef          	jal	80000ce8 <memset>
  memset(disk.avail, 0, PGSIZE);
    800059b2:	0001e497          	auipc	s1,0x1e
    800059b6:	d8648493          	addi	s1,s1,-634 # 80023738 <disk>
    800059ba:	6605                	lui	a2,0x1
    800059bc:	4581                	li	a1,0
    800059be:	6488                	ld	a0,8(s1)
    800059c0:	b28fb0ef          	jal	80000ce8 <memset>
  memset(disk.used, 0, PGSIZE);
    800059c4:	6605                	lui	a2,0x1
    800059c6:	4581                	li	a1,0
    800059c8:	6888                	ld	a0,16(s1)
    800059ca:	b1efb0ef          	jal	80000ce8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800059ce:	100017b7          	lui	a5,0x10001
    800059d2:	4721                	li	a4,8
    800059d4:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800059d6:	4098                	lw	a4,0(s1)
    800059d8:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800059dc:	40d8                	lw	a4,4(s1)
    800059de:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800059e2:	649c                	ld	a5,8(s1)
    800059e4:	0007869b          	sext.w	a3,a5
    800059e8:	10001737          	lui	a4,0x10001
    800059ec:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800059f0:	9781                	srai	a5,a5,0x20
    800059f2:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800059f6:	689c                	ld	a5,16(s1)
    800059f8:	0007869b          	sext.w	a3,a5
    800059fc:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005a00:	9781                	srai	a5,a5,0x20
    80005a02:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005a06:	4785                	li	a5,1
    80005a08:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005a0a:	00f48c23          	sb	a5,24(s1)
    80005a0e:	00f48ca3          	sb	a5,25(s1)
    80005a12:	00f48d23          	sb	a5,26(s1)
    80005a16:	00f48da3          	sb	a5,27(s1)
    80005a1a:	00f48e23          	sb	a5,28(s1)
    80005a1e:	00f48ea3          	sb	a5,29(s1)
    80005a22:	00f48f23          	sb	a5,30(s1)
    80005a26:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005a2a:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a2e:	07272823          	sw	s2,112(a4)
}
    80005a32:	60e2                	ld	ra,24(sp)
    80005a34:	6442                	ld	s0,16(sp)
    80005a36:	64a2                	ld	s1,8(sp)
    80005a38:	6902                	ld	s2,0(sp)
    80005a3a:	6105                	addi	sp,sp,32
    80005a3c:	8082                	ret
    panic("could not find virtio disk");
    80005a3e:	00002517          	auipc	a0,0x2
    80005a42:	c2250513          	addi	a0,a0,-990 # 80007660 <etext+0x660>
    80005a46:	deffa0ef          	jal	80000834 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005a4a:	00002517          	auipc	a0,0x2
    80005a4e:	c3650513          	addi	a0,a0,-970 # 80007680 <etext+0x680>
    80005a52:	de3fa0ef          	jal	80000834 <panic>
    panic("virtio disk should not be ready");
    80005a56:	00002517          	auipc	a0,0x2
    80005a5a:	c4a50513          	addi	a0,a0,-950 # 800076a0 <etext+0x6a0>
    80005a5e:	dd7fa0ef          	jal	80000834 <panic>
    panic("virtio disk has no queue 0");
    80005a62:	00002517          	auipc	a0,0x2
    80005a66:	c5e50513          	addi	a0,a0,-930 # 800076c0 <etext+0x6c0>
    80005a6a:	dcbfa0ef          	jal	80000834 <panic>
    panic("virtio disk max queue too short");
    80005a6e:	00002517          	auipc	a0,0x2
    80005a72:	c7250513          	addi	a0,a0,-910 # 800076e0 <etext+0x6e0>
    80005a76:	dbffa0ef          	jal	80000834 <panic>
    panic("virtio disk kalloc");
    80005a7a:	00002517          	auipc	a0,0x2
    80005a7e:	c8650513          	addi	a0,a0,-890 # 80007700 <etext+0x700>
    80005a82:	db3fa0ef          	jal	80000834 <panic>

0000000080005a86 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005a86:	711d                	addi	sp,sp,-96
    80005a88:	ec86                	sd	ra,88(sp)
    80005a8a:	e8a2                	sd	s0,80(sp)
    80005a8c:	e4a6                	sd	s1,72(sp)
    80005a8e:	e0ca                	sd	s2,64(sp)
    80005a90:	fc4e                	sd	s3,56(sp)
    80005a92:	f852                	sd	s4,48(sp)
    80005a94:	f456                	sd	s5,40(sp)
    80005a96:	f05a                	sd	s6,32(sp)
    80005a98:	ec5e                	sd	s7,24(sp)
    80005a9a:	e862                	sd	s8,16(sp)
    80005a9c:	1080                	addi	s0,sp,96
    80005a9e:	89aa                	mv	s3,a0
    80005aa0:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005aa2:	00c52b83          	lw	s7,12(a0)
    80005aa6:	001b9b9b          	slliw	s7,s7,0x1
    80005aaa:	1b82                	slli	s7,s7,0x20
    80005aac:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005ab0:	0001e517          	auipc	a0,0x1e
    80005ab4:	db050513          	addi	a0,a0,-592 # 80023860 <disk+0x128>
    80005ab8:	970fb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < NUM; i++) {
    80005abc:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005abe:	0001ea97          	auipc	s5,0x1e
    80005ac2:	c7aa8a93          	addi	s5,s5,-902 # 80023738 <disk>
  for (int i = 0; i < 3; i++) {
    80005ac6:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005ac8:	5c7d                	li	s8,-1
    80005aca:	a8a5                	j	80005b42 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80005acc:	00fa8733          	add	a4,s5,a5
    80005ad0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005ad4:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005ad6:	0207c563          	bltz	a5,80005b00 <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    80005ada:	2905                	addiw	s2,s2,1
    80005adc:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005ade:	07490663          	beq	s2,s4,80005b4a <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80005ae2:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005ae4:	0001e717          	auipc	a4,0x1e
    80005ae8:	c5470713          	addi	a4,a4,-940 # 80023738 <disk>
    80005aec:	4781                	li	a5,0
    if (disk.free[i]) {
    80005aee:	01874683          	lbu	a3,24(a4)
    80005af2:	fee9                	bnez	a3,80005acc <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    80005af4:	2785                	addiw	a5,a5,1
    80005af6:	0705                	addi	a4,a4,1
    80005af8:	fe979be3          	bne	a5,s1,80005aee <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005afc:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    80005b00:	01205d63          	blez	s2,80005b1a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005b04:	fa042503          	lw	a0,-96(s0)
    80005b08:	d41ff0ef          	jal	80005848 <free_desc>
      for (int j = 0; j < i; j++)
    80005b0c:	4785                	li	a5,1
    80005b0e:	0127d663          	bge	a5,s2,80005b1a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005b12:	fa442503          	lw	a0,-92(s0)
    80005b16:	d33ff0ef          	jal	80005848 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005b1a:	0001e517          	auipc	a0,0x1e
    80005b1e:	c3650513          	addi	a0,a0,-970 # 80023750 <disk+0x18>
    80005b22:	d50fc0ef          	jal	80002072 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005b26:	0001e517          	auipc	a0,0x1e
    80005b2a:	d3a50513          	addi	a0,a0,-710 # 80023860 <disk+0x128>
    80005b2e:	982fb0ef          	jal	80000cb0 <release>
    sleep();
    80005b32:	d7cfc0ef          	jal	800020ae <sleep>
    acquire(&disk.vdisk_lock);
    80005b36:	0001e517          	auipc	a0,0x1e
    80005b3a:	d2a50513          	addi	a0,a0,-726 # 80023860 <disk+0x128>
    80005b3e:	8eafb0ef          	jal	80000c28 <acquire>
  for (int i = 0; i < 3; i++) {
    80005b42:	fa040613          	addi	a2,s0,-96
    80005b46:	4901                	li	s2,0
    80005b48:	bf69                	j	80005ae2 <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b4a:	fa042503          	lw	a0,-96(s0)
    80005b4e:	00451693          	slli	a3,a0,0x4

  if (write)
    80005b52:	0001e797          	auipc	a5,0x1e
    80005b56:	be678793          	addi	a5,a5,-1050 # 80023738 <disk>
    80005b5a:	00451713          	slli	a4,a0,0x4
    80005b5e:	0a070713          	addi	a4,a4,160
    80005b62:	973e                	add	a4,a4,a5
    80005b64:	01603633          	snez	a2,s6
    80005b68:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005b6a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005b6e:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005b72:	6398                	ld	a4,0(a5)
    80005b74:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b76:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005b7a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005b7c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005b7e:	6390                	ld	a2,0(a5)
    80005b80:	00d60833          	add	a6,a2,a3
    80005b84:	4741                	li	a4,16
    80005b86:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005b8a:	4585                	li	a1,1
    80005b8c:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005b90:	fa442703          	lw	a4,-92(s0)
    80005b94:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005b98:	0712                	slli	a4,a4,0x4
    80005b9a:	963a                	add	a2,a2,a4
    80005b9c:	05898813          	addi	a6,s3,88
    80005ba0:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005ba4:	0007b883          	ld	a7,0(a5)
    80005ba8:	9746                	add	a4,a4,a7
    80005baa:	40000613          	li	a2,1024
    80005bae:	c710                	sw	a2,8(a4)
  if (write)
    80005bb0:	001b3613          	seqz	a2,s6
    80005bb4:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005bb8:	8e4d                	or	a2,a2,a1
    80005bba:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005bbe:	fa842603          	lw	a2,-88(s0)
    80005bc2:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005bc6:	00451813          	slli	a6,a0,0x4
    80005bca:	02080813          	addi	a6,a6,32
    80005bce:	983e                	add	a6,a6,a5
    80005bd0:	577d                	li	a4,-1
    80005bd2:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005bd6:	0612                	slli	a2,a2,0x4
    80005bd8:	98b2                	add	a7,a7,a2
    80005bda:	03068713          	addi	a4,a3,48
    80005bde:	973e                	add	a4,a4,a5
    80005be0:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005be4:	6398                	ld	a4,0(a5)
    80005be6:	9732                	add	a4,a4,a2
    80005be8:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005bea:	4689                	li	a3,2
    80005bec:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005bf0:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005bf4:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005bf8:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005bfc:	6794                	ld	a3,8(a5)
    80005bfe:	0026d703          	lhu	a4,2(a3)
    80005c02:	8b1d                	andi	a4,a4,7
    80005c04:	0706                	slli	a4,a4,0x1
    80005c06:	96ba                	add	a3,a3,a4
    80005c08:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005c0c:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005c10:	6798                	ld	a4,8(a5)
    80005c12:	00275783          	lhu	a5,2(a4)
    80005c16:	2785                	addiw	a5,a5,1
    80005c18:	00f71123          	sh	a5,2(a4)
    80005c1c:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005c20:	100017b7          	lui	a5,0x10001
    80005c24:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005c28:	0049a783          	lw	a5,4(s3)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005c2c:	0001e497          	auipc	s1,0x1e
    80005c30:	c3448493          	addi	s1,s1,-972 # 80023860 <disk+0x128>
  while (b->disk == 1) {
    80005c34:	892e                	mv	s2,a1
    80005c36:	02b79163          	bne	a5,a1,80005c58 <virtio_disk_rw+0x1d2>
    sleep_prepare(b);
    80005c3a:	854e                	mv	a0,s3
    80005c3c:	c36fc0ef          	jal	80002072 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005c40:	8526                	mv	a0,s1
    80005c42:	86efb0ef          	jal	80000cb0 <release>
    sleep();
    80005c46:	c68fc0ef          	jal	800020ae <sleep>
    acquire(&disk.vdisk_lock);
    80005c4a:	8526                	mv	a0,s1
    80005c4c:	fddfa0ef          	jal	80000c28 <acquire>
  while (b->disk == 1) {
    80005c50:	0049a783          	lw	a5,4(s3)
    80005c54:	ff2783e3          	beq	a5,s2,80005c3a <virtio_disk_rw+0x1b4>
  }

  disk.info[idx[0]].b = 0;
    80005c58:	fa042903          	lw	s2,-96(s0)
    80005c5c:	00491713          	slli	a4,s2,0x4
    80005c60:	02070713          	addi	a4,a4,32
    80005c64:	0001e797          	auipc	a5,0x1e
    80005c68:	ad478793          	addi	a5,a5,-1324 # 80023738 <disk>
    80005c6c:	97ba                	add	a5,a5,a4
    80005c6e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005c72:	0001e997          	auipc	s3,0x1e
    80005c76:	ac698993          	addi	s3,s3,-1338 # 80023738 <disk>
    80005c7a:	00491713          	slli	a4,s2,0x4
    80005c7e:	0009b783          	ld	a5,0(s3)
    80005c82:	97ba                	add	a5,a5,a4
    80005c84:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005c88:	854a                	mv	a0,s2
    80005c8a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005c8e:	bbbff0ef          	jal	80005848 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005c92:	8885                	andi	s1,s1,1
    80005c94:	f0fd                	bnez	s1,80005c7a <virtio_disk_rw+0x1f4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005c96:	0001e517          	auipc	a0,0x1e
    80005c9a:	bca50513          	addi	a0,a0,-1078 # 80023860 <disk+0x128>
    80005c9e:	812fb0ef          	jal	80000cb0 <release>
}
    80005ca2:	60e6                	ld	ra,88(sp)
    80005ca4:	6446                	ld	s0,80(sp)
    80005ca6:	64a6                	ld	s1,72(sp)
    80005ca8:	6906                	ld	s2,64(sp)
    80005caa:	79e2                	ld	s3,56(sp)
    80005cac:	7a42                	ld	s4,48(sp)
    80005cae:	7aa2                	ld	s5,40(sp)
    80005cb0:	7b02                	ld	s6,32(sp)
    80005cb2:	6be2                	ld	s7,24(sp)
    80005cb4:	6c42                	ld	s8,16(sp)
    80005cb6:	6125                	addi	sp,sp,96
    80005cb8:	8082                	ret

0000000080005cba <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005cba:	1101                	addi	sp,sp,-32
    80005cbc:	ec06                	sd	ra,24(sp)
    80005cbe:	e822                	sd	s0,16(sp)
    80005cc0:	e426                	sd	s1,8(sp)
    80005cc2:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005cc4:	0001e497          	auipc	s1,0x1e
    80005cc8:	a7448493          	addi	s1,s1,-1420 # 80023738 <disk>
    80005ccc:	0001e517          	auipc	a0,0x1e
    80005cd0:	b9450513          	addi	a0,a0,-1132 # 80023860 <disk+0x128>
    80005cd4:	f55fa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005cd8:	100017b7          	lui	a5,0x10001
    80005cdc:	53bc                	lw	a5,96(a5)
    80005cde:	8b8d                	andi	a5,a5,3
    80005ce0:	10001737          	lui	a4,0x10001
    80005ce4:	d37c                	sw	a5,100(a4)
    80005ce6:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005cea:	689c                	ld	a5,16(s1)
    80005cec:	0204d703          	lhu	a4,32(s1)
    80005cf0:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005cf4:	04f70863          	beq	a4,a5,80005d44 <virtio_disk_intr+0x8a>
    80005cf8:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005cfc:	6898                	ld	a4,16(s1)
    80005cfe:	0204d783          	lhu	a5,32(s1)
    80005d02:	8b9d                	andi	a5,a5,7
    80005d04:	078e                	slli	a5,a5,0x3
    80005d06:	97ba                	add	a5,a5,a4
    80005d08:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005d0a:	00479713          	slli	a4,a5,0x4
    80005d0e:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005d12:	9726                	add	a4,a4,s1
    80005d14:	01074703          	lbu	a4,16(a4)
    80005d18:	e329                	bnez	a4,80005d5a <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005d1a:	0792                	slli	a5,a5,0x4
    80005d1c:	02078793          	addi	a5,a5,32
    80005d20:	97a6                	add	a5,a5,s1
    80005d22:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005d24:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005d28:	bb6fc0ef          	jal	800020de <wakeup>

    disk.used_idx += 1;
    80005d2c:	0204d783          	lhu	a5,32(s1)
    80005d30:	2785                	addiw	a5,a5,1
    80005d32:	17c2                	slli	a5,a5,0x30
    80005d34:	93c1                	srli	a5,a5,0x30
    80005d36:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005d3a:	6898                	ld	a4,16(s1)
    80005d3c:	00275703          	lhu	a4,2(a4)
    80005d40:	faf71ce3          	bne	a4,a5,80005cf8 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005d44:	0001e517          	auipc	a0,0x1e
    80005d48:	b1c50513          	addi	a0,a0,-1252 # 80023860 <disk+0x128>
    80005d4c:	f65fa0ef          	jal	80000cb0 <release>
}
    80005d50:	60e2                	ld	ra,24(sp)
    80005d52:	6442                	ld	s0,16(sp)
    80005d54:	64a2                	ld	s1,8(sp)
    80005d56:	6105                	addi	sp,sp,32
    80005d58:	8082                	ret
      panic("virtio_disk_intr status");
    80005d5a:	00002517          	auipc	a0,0x2
    80005d5e:	9be50513          	addi	a0,a0,-1602 # 80007718 <etext+0x718>
    80005d62:	ad3fa0ef          	jal	80000834 <panic>
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
