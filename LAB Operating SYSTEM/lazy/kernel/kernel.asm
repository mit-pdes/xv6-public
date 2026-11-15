
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
    80000004:	39813103          	ld	sp,920(sp) # 8000a398 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000066:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb107>
    8000006a:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000006c:	6705                	lui	a4,0x1
    8000006e:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80000072:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r"(x));
    80000074:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r"(x));
    80000078:	00001797          	auipc	a5,0x1
    8000007c:	ea278793          	addi	a5,a5,-350 # 80000f1a <main>
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
    8000011c:	32a020ef          	jal	80002446 <either_copyin>
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
    80000198:	24c50513          	addi	a0,a0,588 # 800123e0 <cons>
    8000019c:	309000ef          	jal	80000ca4 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    800001a0:	00012497          	auipc	s1,0x12
    800001a4:	24048493          	addi	s1,s1,576 # 800123e0 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a8:	00012917          	auipc	s2,0x12
    800001ac:	2d090913          	addi	s2,s2,720 # 80012478 <cons+0x98>
  while (n > 0) {
    800001b0:	0d305263          	blez	s3,80000274 <consoleread+0xfc>
    while (cons.r == cons.w) {
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	0af71763          	bne	a4,a5,8000026a <consoleread+0xf2>
      if (killed(myproc())) {
    800001c0:	09f010ef          	jal	80001a5e <myproc>
    800001c4:	102020ef          	jal	800022c6 <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	69d010ef          	jal	80002068 <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	35b000ef          	jal	80000d2c <release>
      sleep();
    800001d6:	6cf010ef          	jal	800020a4 <sleep>
      acquire(&cons.lock);
    800001da:	8526                	mv	a0,s1
    800001dc:	2c9000ef          	jal	80000ca4 <acquire>
    while (cons.r == cons.w) {
    800001e0:	0984a783          	lw	a5,152(s1)
    800001e4:	09c4a703          	lw	a4,156(s1)
    800001e8:	fcf70ce3          	beq	a4,a5,800001c0 <consoleread+0x48>
    800001ec:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ee:	00012717          	auipc	a4,0x12
    800001f2:	1f270713          	addi	a4,a4,498 # 800123e0 <cons>
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
    80000220:	1da020ef          	jal	800023fa <either_copyout>
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
    8000023c:	1a850513          	addi	a0,a0,424 # 800123e0 <cons>
    80000240:	2ed000ef          	jal	80000d2c <release>
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
    80000262:	20f72d23          	sw	a5,538(a4) # 80012478 <cons+0x98>
    80000266:	7aa2                	ld	s5,40(sp)
    80000268:	a031                	j	80000274 <consoleread+0xfc>
    8000026a:	f456                	sd	s5,40(sp)
    8000026c:	b749                	j	800001ee <consoleread+0x76>
    8000026e:	7aa2                	ld	s5,40(sp)
    80000270:	a011                	j	80000274 <consoleread+0xfc>
    80000272:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000274:	00012517          	auipc	a0,0x12
    80000278:	16c50513          	addi	a0,a0,364 # 800123e0 <cons>
    8000027c:	2b1000ef          	jal	80000d2c <release>
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
    800002cc:	11850513          	addi	a0,a0,280 # 800123e0 <cons>
    800002d0:	1d5000ef          	jal	80000ca4 <acquire>

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
    800002ea:	1a8020ef          	jal	80002492 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ee:	00012517          	auipc	a0,0x12
    800002f2:	0f250513          	addi	a0,a0,242 # 800123e0 <cons>
    800002f6:	237000ef          	jal	80000d2c <release>
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
    80000310:	0d470713          	addi	a4,a4,212 # 800123e0 <cons>
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
    80000336:	0ae70713          	addi	a4,a4,174 # 800123e0 <cons>
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
    80000360:	11c72703          	lw	a4,284(a4) # 80012478 <cons+0x98>
    80000364:	9f99                	subw	a5,a5,a4
    80000366:	08000713          	li	a4,128
    8000036a:	f8e792e3          	bne	a5,a4,800002ee <consoleintr+0x32>
    8000036e:	a075                	j	8000041a <consoleintr+0x15e>
    80000370:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000372:	00012717          	auipc	a4,0x12
    80000376:	06e70713          	addi	a4,a4,110 # 800123e0 <cons>
    8000037a:	0a072783          	lw	a5,160(a4)
    8000037e:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000382:	00012497          	auipc	s1,0x12
    80000386:	05e48493          	addi	s1,s1,94 # 800123e0 <cons>
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
    800003c8:	01c70713          	addi	a4,a4,28 # 800123e0 <cons>
    800003cc:	0a072783          	lw	a5,160(a4)
    800003d0:	09c72703          	lw	a4,156(a4)
    800003d4:	f0f70de3          	beq	a4,a5,800002ee <consoleintr+0x32>
      cons.e--;
    800003d8:	37fd                	addiw	a5,a5,-1
    800003da:	00012717          	auipc	a4,0x12
    800003de:	0af72323          	sw	a5,166(a4) # 80012480 <cons+0xa0>
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
    800003fc:	fe878793          	addi	a5,a5,-24 # 800123e0 <cons>
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
    8000041e:	06c7a123          	sw	a2,98(a5) # 8001247c <cons+0x9c>
        wakeup(&cons.r);
    80000422:	00012517          	auipc	a0,0x12
    80000426:	05650513          	addi	a0,a0,86 # 80012478 <cons+0x98>
    8000042a:	4ab010ef          	jal	800020d4 <wakeup>
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
    80000444:	fa050513          	addi	a0,a0,-96 # 800123e0 <cons>
    80000448:	7dc000ef          	jal	80000c24 <initlock>

  uartinit();
    8000044c:	448000ef          	jal	80000894 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000450:	00022797          	auipc	a5,0x22
    80000454:	11078793          	addi	a5,a5,272 # 80022560 <devsw>
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
    80000492:	2ea80813          	addi	a6,a6,746 # 80007778 <digits>
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
    8000052c:	e8c7a783          	lw	a5,-372(a5) # 8000a3b4 <panicking>
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
    80000572:	f1a50513          	addi	a0,a0,-230 # 80012488 <pr>
    80000576:	72e000ef          	jal	80000ca4 <acquire>
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
    800006e6:	096c8c93          	addi	s9,s9,150 # 80007778 <digits>
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
    8000076e:	c4a7a783          	lw	a5,-950(a5) # 8000a3b4 <panicking>
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
    80000798:	cf450513          	addi	a0,a0,-780 # 80012488 <pr>
    8000079c:	590000ef          	jal	80000d2c <release>
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
    80000848:	b697a823          	sw	s1,-1168(a5) # 8000a3b4 <panicking>
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
    8000086a:	b497a523          	sw	s1,-1206(a5) # 8000a3b0 <panicked>
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
    80000884:	c0850513          	addi	a0,a0,-1016 # 80012488 <pr>
    80000888:	39c000ef          	jal	80000c24 <initlock>
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
    800008da:	bca50513          	addi	a0,a0,-1078 # 800124a0 <tx_lock>
    800008de:	346000ef          	jal	80000c24 <initlock>
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
    800008fe:	ba650513          	addi	a0,a0,-1114 # 800124a0 <tx_lock>
    80000902:	3a2000ef          	jal	80000ca4 <acquire>

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
    8000091c:	aa490913          	addi	s2,s2,-1372 # 8000a3bc <tx_busy>
      // wait for a UART interrupt to set tx_busy to 0.
      sleep_prepare(&tx_chan);
    80000920:	0000a997          	auipc	s3,0xa
    80000924:	a9898993          	addi	s3,s3,-1384 # 8000a3b8 <tx_chan>
      release(&tx_lock);
    80000928:	00012497          	auipc	s1,0x12
    8000092c:	b7848493          	addi	s1,s1,-1160 # 800124a0 <tx_lock>
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
    8000093a:	72e010ef          	jal	80002068 <sleep_prepare>
      release(&tx_lock);
    8000093e:	8526                	mv	a0,s1
    80000940:	3ec000ef          	jal	80000d2c <release>
      sleep();
    80000944:	760010ef          	jal	800020a4 <sleep>
      acquire(&tx_lock);
    80000948:	8526                	mv	a0,s1
    8000094a:	35a000ef          	jal	80000ca4 <acquire>
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
    8000097c:	b2850513          	addi	a0,a0,-1240 # 800124a0 <tx_lock>
    80000980:	3ac000ef          	jal	80000d2c <release>
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
    800009a0:	a187a783          	lw	a5,-1512(a5) # 8000a3b4 <panicking>
    800009a4:	cf95                	beqz	a5,800009e0 <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    800009a6:	0000a797          	auipc	a5,0xa
    800009aa:	a0a7a783          	lw	a5,-1526(a5) # 8000a3b0 <panicked>
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
    800009d0:	9e87a783          	lw	a5,-1560(a5) # 8000a3b4 <panicking>
    800009d4:	cb91                	beqz	a5,800009e8 <uartputc_sync+0x58>
    pop_off();
}
    800009d6:	60e2                	ld	ra,24(sp)
    800009d8:	6442                	ld	s0,16(sp)
    800009da:	64a2                	ld	s1,8(sp)
    800009dc:	6105                	addi	sp,sp,32
    800009de:	8082                	ret
    push_off();
    800009e0:	28a000ef          	jal	80000c6a <push_off>
    800009e4:	b7c9                	j	800009a6 <uartputc_sync+0x16>
    for (;;)
    800009e6:	a001                	j	800009e6 <uartputc_sync+0x56>
    pop_off();
    800009e8:	2fc000ef          	jal	80000ce4 <pop_off>
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
    80000a06:	a9e50513          	addi	a0,a0,-1378 # 800124a0 <tx_lock>
    80000a0a:	29a000ef          	jal	80000ca4 <acquire>
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
    80000a20:	a8450513          	addi	a0,a0,-1404 # 800124a0 <tx_lock>
    80000a24:	308000ef          	jal	80000d2c <release>
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
    80000a48:	9607ac23          	sw	zero,-1672(a5) # 8000a3bc <tx_busy>
    wakeup(&tx_chan);
    80000a4c:	0000a517          	auipc	a0,0xa
    80000a50:	96c50513          	addi	a0,a0,-1684 # 8000a3b8 <tx_chan>
    80000a54:	680010ef          	jal	800020d4 <wakeup>
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
    80000a76:	c8678793          	addi	a5,a5,-890 # 800236f8 <end>
    80000a7a:	00f53733          	sltu	a4,a0,a5
    80000a7e:	47c5                	li	a5,17
    80000a80:	07ee                	slli	a5,a5,0x1b
    80000a82:	17fd                	addi	a5,a5,-1
    80000a84:	00a7b7b3          	sltu	a5,a5,a0
    80000a88:	8fd9                	or	a5,a5,a4
    80000a8a:	e3b9                	bnez	a5,80000ad0 <kfree+0x6a>
    80000a8c:	84aa                	mv	s1,a0
    80000a8e:	03451793          	slli	a5,a0,0x34
    80000a92:	ef9d                	bnez	a5,80000ad0 <kfree+0x6a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a94:	6605                	lui	a2,0x1
    80000a96:	4585                	li	a1,1
    80000a98:	2cc000ef          	jal	80000d64 <memset>

  r = (struct run *)pa;

  acquire(&kmem.lock);
    80000a9c:	00012917          	auipc	s2,0x12
    80000aa0:	a1c90913          	addi	s2,s2,-1508 # 800124b8 <kmem>
    80000aa4:	854a                	mv	a0,s2
    80000aa6:	1fe000ef          	jal	80000ca4 <acquire>
  r->next = kmem.freelist;
    80000aaa:	01893783          	ld	a5,24(s2)
    80000aae:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000ab0:	00993c23          	sd	s1,24(s2)
  kmem.free_pages++;
    80000ab4:	02093783          	ld	a5,32(s2)
    80000ab8:	0785                	addi	a5,a5,1
    80000aba:	02f93023          	sd	a5,32(s2)
  release(&kmem.lock);
    80000abe:	854a                	mv	a0,s2
    80000ac0:	26c000ef          	jal	80000d2c <release>
}
    80000ac4:	60e2                	ld	ra,24(sp)
    80000ac6:	6442                	ld	s0,16(sp)
    80000ac8:	64a2                	ld	s1,8(sp)
    80000aca:	6902                	ld	s2,0(sp)
    80000acc:	6105                	addi	sp,sp,32
    80000ace:	8082                	ret
    panic("kfree");
    80000ad0:	00006517          	auipc	a0,0x6
    80000ad4:	56850513          	addi	a0,a0,1384 # 80007038 <etext+0x38>
    80000ad8:	d5dff0ef          	jal	80000834 <panic>

0000000080000adc <freerange>:
{
    80000adc:	7179                	addi	sp,sp,-48
    80000ade:	f406                	sd	ra,40(sp)
    80000ae0:	f022                	sd	s0,32(sp)
    80000ae2:	ec26                	sd	s1,24(sp)
    80000ae4:	1800                	addi	s0,sp,48
  p = (char *)PGROUNDUP((uint64)pa_start);
    80000ae6:	6785                	lui	a5,0x1
    80000ae8:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000aec:	00e504b3          	add	s1,a0,a4
    80000af0:	777d                	lui	a4,0xfffff
    80000af2:	8cf9                	and	s1,s1,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000af4:	94be                	add	s1,s1,a5
    80000af6:	0295e263          	bltu	a1,s1,80000b1a <freerange+0x3e>
    80000afa:	e84a                	sd	s2,16(sp)
    80000afc:	e44e                	sd	s3,8(sp)
    80000afe:	e052                	sd	s4,0(sp)
    80000b00:	892e                	mv	s2,a1
    kfree(p);
    80000b02:	8a3a                	mv	s4,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000b04:	89be                	mv	s3,a5
    kfree(p);
    80000b06:	01448533          	add	a0,s1,s4
    80000b0a:	f5dff0ef          	jal	80000a66 <kfree>
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000b0e:	94ce                	add	s1,s1,s3
    80000b10:	fe997be3          	bgeu	s2,s1,80000b06 <freerange+0x2a>
    80000b14:	6942                	ld	s2,16(sp)
    80000b16:	69a2                	ld	s3,8(sp)
    80000b18:	6a02                	ld	s4,0(sp)
}
    80000b1a:	70a2                	ld	ra,40(sp)
    80000b1c:	7402                	ld	s0,32(sp)
    80000b1e:	64e2                	ld	s1,24(sp)
    80000b20:	6145                	addi	sp,sp,48
    80000b22:	8082                	ret

0000000080000b24 <kinit>:
{
    80000b24:	1101                	addi	sp,sp,-32
    80000b26:	ec06                	sd	ra,24(sp)
    80000b28:	e822                	sd	s0,16(sp)
    80000b2a:	e426                	sd	s1,8(sp)
    80000b2c:	1000                	addi	s0,sp,32
  initlock(&kmem.lock, "kmem");
    80000b2e:	00012497          	auipc	s1,0x12
    80000b32:	98a48493          	addi	s1,s1,-1654 # 800124b8 <kmem>
    80000b36:	00006597          	auipc	a1,0x6
    80000b3a:	50a58593          	addi	a1,a1,1290 # 80007040 <etext+0x40>
    80000b3e:	8526                	mv	a0,s1
    80000b40:	0e4000ef          	jal	80000c24 <initlock>
  kmem.free_pages = 0;
    80000b44:	0204b023          	sd	zero,32(s1)
  kmem.total_pages = ((uint64)PHYSTOP - PGROUNDUP((uint64)end)) / PGSIZE;
    80000b48:	00024717          	auipc	a4,0x24
    80000b4c:	baf70713          	addi	a4,a4,-1105 # 800246f7 <end+0xfff>
    80000b50:	77fd                	lui	a5,0xfffff
    80000b52:	8f7d                	and	a4,a4,a5
    80000b54:	47c5                	li	a5,17
    80000b56:	07ee                	slli	a5,a5,0x1b
    80000b58:	8f99                	sub	a5,a5,a4
    80000b5a:	83b1                	srli	a5,a5,0xc
    80000b5c:	f49c                	sd	a5,40(s1)
  freerange(end, (void *)PHYSTOP);
    80000b5e:	45c5                	li	a1,17
    80000b60:	05ee                	slli	a1,a1,0x1b
    80000b62:	00023517          	auipc	a0,0x23
    80000b66:	b9650513          	addi	a0,a0,-1130 # 800236f8 <end>
    80000b6a:	f73ff0ef          	jal	80000adc <freerange>
}
    80000b6e:	60e2                	ld	ra,24(sp)
    80000b70:	6442                	ld	s0,16(sp)
    80000b72:	64a2                	ld	s1,8(sp)
    80000b74:	6105                	addi	sp,sp,32
    80000b76:	8082                	ret

0000000080000b78 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b78:	1101                	addi	sp,sp,-32
    80000b7a:	ec06                	sd	ra,24(sp)
    80000b7c:	e822                	sd	s0,16(sp)
    80000b7e:	e426                	sd	s1,8(sp)
    80000b80:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b82:	00012517          	auipc	a0,0x12
    80000b86:	93650513          	addi	a0,a0,-1738 # 800124b8 <kmem>
    80000b8a:	11a000ef          	jal	80000ca4 <acquire>
  r = kmem.freelist;
    80000b8e:	00012497          	auipc	s1,0x12
    80000b92:	9424b483          	ld	s1,-1726(s1) # 800124d0 <kmem+0x18>
  if (r) {
    80000b96:	c885                	beqz	s1,80000bc6 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b98:	6098                	ld	a4,0(s1)
    80000b9a:	00012797          	auipc	a5,0x12
    80000b9e:	91e78793          	addi	a5,a5,-1762 # 800124b8 <kmem>
    80000ba2:	ef98                	sd	a4,24(a5)
    kmem.free_pages--;
    80000ba4:	7398                	ld	a4,32(a5)
    80000ba6:	177d                	addi	a4,a4,-1
    80000ba8:	f398                	sd	a4,32(a5)
  }
  release(&kmem.lock);
    80000baa:	853e                	mv	a0,a5
    80000bac:	180000ef          	jal	80000d2c <release>

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk
    80000bb0:	6605                	lui	a2,0x1
    80000bb2:	4595                	li	a1,5
    80000bb4:	8526                	mv	a0,s1
    80000bb6:	1ae000ef          	jal	80000d64 <memset>
  return (void *)r;
}
    80000bba:	8526                	mv	a0,s1
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
  release(&kmem.lock);
    80000bc6:	00012517          	auipc	a0,0x12
    80000bca:	8f250513          	addi	a0,a0,-1806 # 800124b8 <kmem>
    80000bce:	15e000ef          	jal	80000d2c <release>
  if (r)
    80000bd2:	b7e5                	j	80000bba <kalloc+0x42>

0000000080000bd4 <get_free_pages>:

uint64
get_free_pages(void)
{
    80000bd4:	1101                	addi	sp,sp,-32
    80000bd6:	ec06                	sd	ra,24(sp)
    80000bd8:	e822                	sd	s0,16(sp)
    80000bda:	e426                	sd	s1,8(sp)
    80000bdc:	1000                	addi	s0,sp,32
  uint64 cnt;
  acquire(&kmem.lock);
    80000bde:	00012517          	auipc	a0,0x12
    80000be2:	8da50513          	addi	a0,a0,-1830 # 800124b8 <kmem>
    80000be6:	0be000ef          	jal	80000ca4 <acquire>
  cnt = kmem.free_pages;
    80000bea:	00012797          	auipc	a5,0x12
    80000bee:	8ee7b783          	ld	a5,-1810(a5) # 800124d8 <kmem+0x20>
    80000bf2:	84be                	mv	s1,a5
  release(&kmem.lock);
    80000bf4:	00012517          	auipc	a0,0x12
    80000bf8:	8c450513          	addi	a0,a0,-1852 # 800124b8 <kmem>
    80000bfc:	130000ef          	jal	80000d2c <release>
  return cnt;
}
    80000c00:	8526                	mv	a0,s1
    80000c02:	60e2                	ld	ra,24(sp)
    80000c04:	6442                	ld	s0,16(sp)
    80000c06:	64a2                	ld	s1,8(sp)
    80000c08:	6105                	addi	sp,sp,32
    80000c0a:	8082                	ret

0000000080000c0c <get_total_pages>:

uint64
get_total_pages(void)
{
    80000c0c:	1141                	addi	sp,sp,-16
    80000c0e:	e406                	sd	ra,8(sp)
    80000c10:	e022                	sd	s0,0(sp)
    80000c12:	0800                	addi	s0,sp,16
  return kmem.total_pages;
}
    80000c14:	00012517          	auipc	a0,0x12
    80000c18:	8cc53503          	ld	a0,-1844(a0) # 800124e0 <kmem+0x28>
    80000c1c:	60a2                	ld	ra,8(sp)
    80000c1e:	6402                	ld	s0,0(sp)
    80000c20:	0141                	addi	sp,sp,16
    80000c22:	8082                	ret

0000000080000c24 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c24:	1141                	addi	sp,sp,-16
    80000c26:	e406                	sd	ra,8(sp)
    80000c28:	e022                	sd	s0,0(sp)
    80000c2a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c2c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c2e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c32:	00053823          	sd	zero,16(a0)
}
    80000c36:	60a2                	ld	ra,8(sp)
    80000c38:	6402                	ld	s0,0(sp)
    80000c3a:	0141                	addi	sp,sp,16
    80000c3c:	8082                	ret

0000000080000c3e <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c3e:	411c                	lw	a5,0(a0)
    80000c40:	e399                	bnez	a5,80000c46 <holding+0x8>
    80000c42:	4501                	li	a0,0
  return r;
}
    80000c44:	8082                	ret
{
    80000c46:	1101                	addi	sp,sp,-32
    80000c48:	ec06                	sd	ra,24(sp)
    80000c4a:	e822                	sd	s0,16(sp)
    80000c4c:	e426                	sd	s1,8(sp)
    80000c4e:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c50:	691c                	ld	a5,16(a0)
    80000c52:	84be                	mv	s1,a5
    80000c54:	5eb000ef          	jal	80001a3e <mycpu>
    80000c58:	40a48533          	sub	a0,s1,a0
    80000c5c:	00153513          	seqz	a0,a0
}
    80000c60:	60e2                	ld	ra,24(sp)
    80000c62:	6442                	ld	s0,16(sp)
    80000c64:	64a2                	ld	s1,8(sp)
    80000c66:	6105                	addi	sp,sp,32
    80000c68:	8082                	ret

0000000080000c6a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c6a:	1101                	addi	sp,sp,-32
    80000c6c:	ec06                	sd	ra,24(sp)
    80000c6e:	e822                	sd	s0,16(sp)
    80000c70:	e426                	sd	s1,8(sp)
    80000c72:	1000                	addi	s0,sp,32
  __asm__ __volatile__("csrrc %0, sstatus, %1" : "=r"(x) : "rK"(x) : "memory");
    80000c74:	100177f3          	csrrci	a5,sstatus,2
    80000c78:	84be                	mv	s1,a5
  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  uint64 flags = rc_sstatus(SSTATUS_SIE);
  int old = !!(flags & SSTATUS_SIE);

  if (mycpu()->noff == 0)
    80000c7a:	5c5000ef          	jal	80001a3e <mycpu>
    80000c7e:	5d3c                	lw	a5,120(a0)
    80000c80:	cb99                	beqz	a5,80000c96 <push_off+0x2c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c82:	5bd000ef          	jal	80001a3e <mycpu>
    80000c86:	5d3c                	lw	a5,120(a0)
    80000c88:	2785                	addiw	a5,a5,1
    80000c8a:	dd3c                	sw	a5,120(a0)
}
    80000c8c:	60e2                	ld	ra,24(sp)
    80000c8e:	6442                	ld	s0,16(sp)
    80000c90:	64a2                	ld	s1,8(sp)
    80000c92:	6105                	addi	sp,sp,32
    80000c94:	8082                	ret
    mycpu()->intena = old;
    80000c96:	5a9000ef          	jal	80001a3e <mycpu>
  int old = !!(flags & SSTATUS_SIE);
    80000c9a:	0014d793          	srli	a5,s1,0x1
    80000c9e:	8b85                	andi	a5,a5,1
    mycpu()->intena = old;
    80000ca0:	dd7c                	sw	a5,124(a0)
    80000ca2:	b7c5                	j	80000c82 <push_off+0x18>

0000000080000ca4 <acquire>:
{
    80000ca4:	1101                	addi	sp,sp,-32
    80000ca6:	ec06                	sd	ra,24(sp)
    80000ca8:	e822                	sd	s0,16(sp)
    80000caa:	e426                	sd	s1,8(sp)
    80000cac:	1000                	addi	s0,sp,32
    80000cae:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000cb0:	fbbff0ef          	jal	80000c6a <push_off>
  if (holding(lk))
    80000cb4:	8526                	mv	a0,s1
    80000cb6:	f89ff0ef          	jal	80000c3e <holding>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000cba:	4705                	li	a4,1
  if (holding(lk))
    80000cbc:	ed11                	bnez	a0,80000cd8 <acquire+0x34>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000cbe:	87ba                	mv	a5,a4
    80000cc0:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000cc4:	2781                	sext.w	a5,a5
    80000cc6:	ffe5                	bnez	a5,80000cbe <acquire+0x1a>
  lk->cpu = mycpu();
    80000cc8:	577000ef          	jal	80001a3e <mycpu>
    80000ccc:	e888                	sd	a0,16(s1)
}
    80000cce:	60e2                	ld	ra,24(sp)
    80000cd0:	6442                	ld	s0,16(sp)
    80000cd2:	64a2                	ld	s1,8(sp)
    80000cd4:	6105                	addi	sp,sp,32
    80000cd6:	8082                	ret
    panic("acquire");
    80000cd8:	00006517          	auipc	a0,0x6
    80000cdc:	37050513          	addi	a0,a0,880 # 80007048 <etext+0x48>
    80000ce0:	b55ff0ef          	jal	80000834 <panic>

0000000080000ce4 <pop_off>:

void
pop_off(void)
{
    80000ce4:	1141                	addi	sp,sp,-16
    80000ce6:	e406                	sd	ra,8(sp)
    80000ce8:	e022                	sd	s0,0(sp)
    80000cea:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cec:	553000ef          	jal	80001a3e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000cf0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cf4:	8b89                	andi	a5,a5,2
  if (intr_get())
    80000cf6:	ef99                	bnez	a5,80000d14 <pop_off+0x30>
    panic("pop_off - interruptible");
  if (c->noff < 1)
    80000cf8:	5d3c                	lw	a5,120(a0)
    80000cfa:	02f05363          	blez	a5,80000d20 <pop_off+0x3c>
    panic("pop_off");
  c->noff -= 1;
    80000cfe:	37fd                	addiw	a5,a5,-1
    80000d00:	dd3c                	sw	a5,120(a0)
  if (c->noff == 0 && c->intena)
    80000d02:	e789                	bnez	a5,80000d0c <pop_off+0x28>
    80000d04:	5d7c                	lw	a5,124(a0)
    80000d06:	c399                	beqz	a5,80000d0c <pop_off+0x28>
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80000d08:	10016073          	csrsi	sstatus,2
    intr_on();
}
    80000d0c:	60a2                	ld	ra,8(sp)
    80000d0e:	6402                	ld	s0,0(sp)
    80000d10:	0141                	addi	sp,sp,16
    80000d12:	8082                	ret
    panic("pop_off - interruptible");
    80000d14:	00006517          	auipc	a0,0x6
    80000d18:	33c50513          	addi	a0,a0,828 # 80007050 <etext+0x50>
    80000d1c:	b19ff0ef          	jal	80000834 <panic>
    panic("pop_off");
    80000d20:	00006517          	auipc	a0,0x6
    80000d24:	34850513          	addi	a0,a0,840 # 80007068 <etext+0x68>
    80000d28:	b0dff0ef          	jal	80000834 <panic>

0000000080000d2c <release>:
{
    80000d2c:	1101                	addi	sp,sp,-32
    80000d2e:	ec06                	sd	ra,24(sp)
    80000d30:	e822                	sd	s0,16(sp)
    80000d32:	e426                	sd	s1,8(sp)
    80000d34:	1000                	addi	s0,sp,32
    80000d36:	84aa                	mv	s1,a0
  if (!holding(lk))
    80000d38:	f07ff0ef          	jal	80000c3e <holding>
    80000d3c:	cd11                	beqz	a0,80000d58 <release+0x2c>
  lk->cpu = 0;
    80000d3e:	0004b823          	sd	zero,16(s1)
  __atomic_store_n(&lk->locked, 0, __ATOMIC_RELEASE);
    80000d42:	0310000f          	fence	rw,w
    80000d46:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000d4a:	f9bff0ef          	jal	80000ce4 <pop_off>
}
    80000d4e:	60e2                	ld	ra,24(sp)
    80000d50:	6442                	ld	s0,16(sp)
    80000d52:	64a2                	ld	s1,8(sp)
    80000d54:	6105                	addi	sp,sp,32
    80000d56:	8082                	ret
    panic("release");
    80000d58:	00006517          	auipc	a0,0x6
    80000d5c:	31850513          	addi	a0,a0,792 # 80007070 <etext+0x70>
    80000d60:	ad5ff0ef          	jal	80000834 <panic>

0000000080000d64 <memset>:
#include "types.h"

void *
memset(void *dst, int c, uint n)
{
    80000d64:	1141                	addi	sp,sp,-16
    80000d66:	e406                	sd	ra,8(sp)
    80000d68:	e022                	sd	s0,0(sp)
    80000d6a:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
    80000d6c:	ca19                	beqz	a2,80000d82 <memset+0x1e>
    80000d6e:	87aa                	mv	a5,a0
    80000d70:	1602                	slli	a2,a2,0x20
    80000d72:	9201                	srli	a2,a2,0x20
    80000d74:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d78:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
    80000d7c:	0785                	addi	a5,a5,1
    80000d7e:	fee79de3          	bne	a5,a4,80000d78 <memset+0x14>
  }
  return dst;
}
    80000d82:	60a2                	ld	ra,8(sp)
    80000d84:	6402                	ld	s0,0(sp)
    80000d86:	0141                	addi	sp,sp,16
    80000d88:	8082                	ret

0000000080000d8a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while (n-- > 0) {
    80000d92:	c61d                	beqz	a2,80000dc0 <memcmp+0x36>
    80000d94:	1602                	slli	a2,a2,0x20
    80000d96:	9201                	srli	a2,a2,0x20
    80000d98:	00c506b3          	add	a3,a0,a2
    if (*s1 != *s2)
    80000d9c:	00054783          	lbu	a5,0(a0)
    80000da0:	0005c703          	lbu	a4,0(a1)
    80000da4:	00e79863          	bne	a5,a4,80000db4 <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000da8:	0505                	addi	a0,a0,1
    80000daa:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    80000dac:	fed518e3          	bne	a0,a3,80000d9c <memcmp+0x12>
  }

  return 0;
    80000db0:	4501                	li	a0,0
    80000db2:	a019                	j	80000db8 <memcmp+0x2e>
      return *s1 - *s2;
    80000db4:	40e7853b          	subw	a0,a5,a4
}
    80000db8:	60a2                	ld	ra,8(sp)
    80000dba:	6402                	ld	s0,0(sp)
    80000dbc:	0141                	addi	sp,sp,16
    80000dbe:	8082                	ret
  return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	bfdd                	j	80000db8 <memcmp+0x2e>

0000000080000dc4 <memmove>:

void *
memmove(void *dst, const void *src, uint n)
{
    80000dc4:	1141                	addi	sp,sp,-16
    80000dc6:	e406                	sd	ra,8(sp)
    80000dc8:	e022                	sd	s0,0(sp)
    80000dca:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if (n == 0)
    80000dcc:	c205                	beqz	a2,80000dec <memmove+0x28>
    return dst;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
    80000dce:	02a5e363          	bltu	a1,a0,80000df4 <memmove+0x30>
    s += n;
    d += n;
    while (n-- > 0)
      *--d = *--s;
  } else
    while (n-- > 0)
    80000dd2:	1602                	slli	a2,a2,0x20
    80000dd4:	9201                	srli	a2,a2,0x20
    80000dd6:	00c587b3          	add	a5,a1,a2
{
    80000dda:	872a                	mv	a4,a0
      *d++ = *s++;
    80000ddc:	0585                	addi	a1,a1,1
    80000dde:	0705                	addi	a4,a4,1
    80000de0:	fff5c683          	lbu	a3,-1(a1)
    80000de4:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
    80000de8:	feb79ae3          	bne	a5,a1,80000ddc <memmove+0x18>

  return dst;
}
    80000dec:	60a2                	ld	ra,8(sp)
    80000dee:	6402                	ld	s0,0(sp)
    80000df0:	0141                	addi	sp,sp,16
    80000df2:	8082                	ret
  if (s < d && s + n > d) {
    80000df4:	02061693          	slli	a3,a2,0x20
    80000df8:	9281                	srli	a3,a3,0x20
    80000dfa:	00d58733          	add	a4,a1,a3
    80000dfe:	fce57ae3          	bgeu	a0,a4,80000dd2 <memmove+0xe>
    d += n;
    80000e02:	96aa                	add	a3,a3,a0
    while (n-- > 0)
    80000e04:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000e08:	1782                	slli	a5,a5,0x20
    80000e0a:	9381                	srli	a5,a5,0x20
    80000e0c:	fff7c793          	not	a5,a5
    80000e10:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000e12:	177d                	addi	a4,a4,-1
    80000e14:	16fd                	addi	a3,a3,-1
    80000e16:	00074603          	lbu	a2,0(a4)
    80000e1a:	00c68023          	sb	a2,0(a3)
    while (n-- > 0)
    80000e1e:	fee79ae3          	bne	a5,a4,80000e12 <memmove+0x4e>
    80000e22:	b7e9                	j	80000dec <memmove+0x28>

0000000080000e24 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void *
memcpy(void *dst, const void *src, uint n)
{
    80000e24:	1141                	addi	sp,sp,-16
    80000e26:	e406                	sd	ra,8(sp)
    80000e28:	e022                	sd	s0,0(sp)
    80000e2a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e2c:	f99ff0ef          	jal	80000dc4 <memmove>
}
    80000e30:	60a2                	ld	ra,8(sp)
    80000e32:	6402                	ld	s0,0(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e406                	sd	ra,8(sp)
    80000e3c:	e022                	sd	s0,0(sp)
    80000e3e:	0800                	addi	s0,sp,16
  while (n > 0 && *p && *p == *q)
    80000e40:	ce11                	beqz	a2,80000e5c <strncmp+0x24>
    80000e42:	00054783          	lbu	a5,0(a0)
    80000e46:	cf89                	beqz	a5,80000e60 <strncmp+0x28>
    80000e48:	0005c703          	lbu	a4,0(a1)
    80000e4c:	00f71a63          	bne	a4,a5,80000e60 <strncmp+0x28>
    n--, p++, q++;
    80000e50:	367d                	addiw	a2,a2,-1
    80000e52:	0505                	addi	a0,a0,1
    80000e54:	0585                	addi	a1,a1,1
  while (n > 0 && *p && *p == *q)
    80000e56:	f675                	bnez	a2,80000e42 <strncmp+0xa>
  if (n == 0)
    return 0;
    80000e58:	4501                	li	a0,0
    80000e5a:	a801                	j	80000e6a <strncmp+0x32>
    80000e5c:	4501                	li	a0,0
    80000e5e:	a031                	j	80000e6a <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000e60:	00054503          	lbu	a0,0(a0)
    80000e64:	0005c783          	lbu	a5,0(a1)
    80000e68:	9d1d                	subw	a0,a0,a5
}
    80000e6a:	60a2                	ld	ra,8(sp)
    80000e6c:	6402                	ld	s0,0(sp)
    80000e6e:	0141                	addi	sp,sp,16
    80000e70:	8082                	ret

0000000080000e72 <strncpy>:

char *
strncpy(char *s, const char *t, int n)
{
    80000e72:	1141                	addi	sp,sp,-16
    80000e74:	e406                	sd	ra,8(sp)
    80000e76:	e022                	sd	s0,0(sp)
    80000e78:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while (n-- > 0 && (*s++ = *t++) != 0)
    80000e7a:	87aa                	mv	a5,a0
    80000e7c:	a011                	j	80000e80 <strncpy+0xe>
    80000e7e:	8636                	mv	a2,a3
    80000e80:	02c05863          	blez	a2,80000eb0 <strncpy+0x3e>
    80000e84:	fff6069b          	addiw	a3,a2,-1
    80000e88:	8836                	mv	a6,a3
    80000e8a:	0785                	addi	a5,a5,1
    80000e8c:	0005c703          	lbu	a4,0(a1)
    80000e90:	fee78fa3          	sb	a4,-1(a5)
    80000e94:	0585                	addi	a1,a1,1
    80000e96:	f765                	bnez	a4,80000e7e <strncpy+0xc>
    ;
  while (n-- > 0)
    80000e98:	873e                	mv	a4,a5
    80000e9a:	01005b63          	blez	a6,80000eb0 <strncpy+0x3e>
    80000e9e:	9fb1                	addw	a5,a5,a2
    80000ea0:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000ea2:	0705                	addi	a4,a4,1
    80000ea4:	fe070fa3          	sb	zero,-1(a4)
  while (n-- > 0)
    80000ea8:	40e786bb          	subw	a3,a5,a4
    80000eac:	fed04be3          	bgtz	a3,80000ea2 <strncpy+0x30>
  return os;
}
    80000eb0:	60a2                	ld	ra,8(sp)
    80000eb2:	6402                	ld	s0,0(sp)
    80000eb4:	0141                	addi	sp,sp,16
    80000eb6:	8082                	ret

0000000080000eb8 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char *
safestrcpy(char *s, const char *t, int n)
{
    80000eb8:	1141                	addi	sp,sp,-16
    80000eba:	e406                	sd	ra,8(sp)
    80000ebc:	e022                	sd	s0,0(sp)
    80000ebe:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if (n <= 0)
    80000ec0:	02c05363          	blez	a2,80000ee6 <safestrcpy+0x2e>
    80000ec4:	fff6069b          	addiw	a3,a2,-1
    80000ec8:	1682                	slli	a3,a3,0x20
    80000eca:	9281                	srli	a3,a3,0x20
    80000ecc:	96ae                	add	a3,a3,a1
    80000ece:	87aa                	mv	a5,a0
    return os;
  while (--n > 0 && (*s++ = *t++) != 0)
    80000ed0:	00d58963          	beq	a1,a3,80000ee2 <safestrcpy+0x2a>
    80000ed4:	0585                	addi	a1,a1,1
    80000ed6:	0785                	addi	a5,a5,1
    80000ed8:	fff5c703          	lbu	a4,-1(a1)
    80000edc:	fee78fa3          	sb	a4,-1(a5)
    80000ee0:	fb65                	bnez	a4,80000ed0 <safestrcpy+0x18>
    ;
  *s = 0;
    80000ee2:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ee6:	60a2                	ld	ra,8(sp)
    80000ee8:	6402                	ld	s0,0(sp)
    80000eea:	0141                	addi	sp,sp,16
    80000eec:	8082                	ret

0000000080000eee <strlen>:

int
strlen(const char *s)
{
    80000eee:	1141                	addi	sp,sp,-16
    80000ef0:	e406                	sd	ra,8(sp)
    80000ef2:	e022                	sd	s0,0(sp)
    80000ef4:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
    80000ef6:	00054783          	lbu	a5,0(a0)
    80000efa:	cf91                	beqz	a5,80000f16 <strlen+0x28>
    80000efc:	00150793          	addi	a5,a0,1
    80000f00:	86be                	mv	a3,a5
    80000f02:	0785                	addi	a5,a5,1
    80000f04:	fff7c703          	lbu	a4,-1(a5)
    80000f08:	ff65                	bnez	a4,80000f00 <strlen+0x12>
    80000f0a:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000f0e:	60a2                	ld	ra,8(sp)
    80000f10:	6402                	ld	s0,0(sp)
    80000f12:	0141                	addi	sp,sp,16
    80000f14:	8082                	ret
  for (n = 0; s[n]; n++)
    80000f16:	4501                	li	a0,0
    80000f18:	bfdd                	j	80000f0e <strlen+0x20>

0000000080000f1a <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f1a:	1141                	addi	sp,sp,-16
    80000f1c:	e406                	sd	ra,8(sp)
    80000f1e:	e022                	sd	s0,0(sp)
    80000f20:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80000f22:	309000ef          	jal	80001a2a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();         // first user process

    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
  } else {
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000f26:	00009717          	auipc	a4,0x9
    80000f2a:	49a70713          	addi	a4,a4,1178 # 8000a3c0 <started>
  if (cpuid() == 0) {
    80000f2e:	c51d                	beqz	a0,80000f5c <main+0x42>
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000f30:	431c                	lw	a5,0(a4)
    80000f32:	0230000f          	fence	r,rw
    80000f36:	2781                	sext.w	a5,a5
    80000f38:	dfe5                	beqz	a5,80000f30 <main+0x16>
      ;

    printk("hart %d starting\n", cpuid());
    80000f3a:	2f1000ef          	jal	80001a2a <cpuid>
    80000f3e:	85aa                	mv	a1,a0
    80000f40:	00006517          	auipc	a0,0x6
    80000f44:	15850513          	addi	a0,a0,344 # 80007098 <etext+0x98>
    80000f48:	dc2ff0ef          	jal	8000050a <printk>
    kvminithart();  // turn on paging
    80000f4c:	082000ef          	jal	80000fce <kvminithart>
    trapinithart(); // install kernel trap vector
    80000f50:	674010ef          	jal	800025c4 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000f54:	0f5040ef          	jal	80005848 <plicinithart>
  }

  scheduler();
    80000f58:	775000ef          	jal	80001ecc <scheduler>
    consoleinit();
    80000f5c:	cd4ff0ef          	jal	80000430 <consoleinit>
    printkinit();
    80000f60:	911ff0ef          	jal	80000870 <printkinit>
    printk("\n");
    80000f64:	00006517          	auipc	a0,0x6
    80000f68:	11450513          	addi	a0,a0,276 # 80007078 <etext+0x78>
    80000f6c:	d9eff0ef          	jal	8000050a <printk>
    printk("xv6 kernel is booting\n");
    80000f70:	00006517          	auipc	a0,0x6
    80000f74:	11050513          	addi	a0,a0,272 # 80007080 <etext+0x80>
    80000f78:	d92ff0ef          	jal	8000050a <printk>
    printk("\n");
    80000f7c:	00006517          	auipc	a0,0x6
    80000f80:	0fc50513          	addi	a0,a0,252 # 80007078 <etext+0x78>
    80000f84:	d86ff0ef          	jal	8000050a <printk>
    kinit();            // physical page allocator
    80000f88:	b9dff0ef          	jal	80000b24 <kinit>
    kvminit();          // create kernel page table
    80000f8c:	294000ef          	jal	80001220 <kvminit>
    kvminithart();      // turn on paging
    80000f90:	03e000ef          	jal	80000fce <kvminithart>
    procinit();         // process table
    80000f94:	1e1000ef          	jal	80001974 <procinit>
    trapinit();         // trap vectors
    80000f98:	608010ef          	jal	800025a0 <trapinit>
    trapinithart();     // install kernel trap vector
    80000f9c:	628010ef          	jal	800025c4 <trapinithart>
    plicinit();         // set up interrupt controller
    80000fa0:	08f040ef          	jal	8000582e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000fa4:	0a5040ef          	jal	80005848 <plicinithart>
    binit();            // buffer cache
    80000fa8:	547010ef          	jal	80002cee <binit>
    iinit();            // inode table
    80000fac:	298020ef          	jal	80003244 <iinit>
    fileinit();         // file table
    80000fb0:	2c6030ef          	jal	80004276 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fb4:	18b040ef          	jal	8000593e <virtio_disk_init>
    userinit();         // first user process
    80000fb8:	569000ef          	jal	80001d20 <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000fbc:	00009797          	auipc	a5,0x9
    80000fc0:	40478793          	addi	a5,a5,1028 # 8000a3c0 <started>
    80000fc4:	4705                	li	a4,1
    80000fc6:	0310000f          	fence	rw,w
    80000fca:	c398                	sw	a4,0(a5)
    80000fcc:	b771                	j	80000f58 <main+0x3e>

0000000080000fce <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000fce:	1141                	addi	sp,sp,-16
    80000fd0:	e406                	sd	ra,8(sp)
    80000fd2:	e022                	sd	s0,0(sp)
    80000fd4:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000fd6:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fda:	00009797          	auipc	a5,0x9
    80000fde:	3ee7b783          	ld	a5,1006(a5) # 8000a3c8 <kernel_pagetable>
    80000fe2:	83b1                	srli	a5,a5,0xc
    80000fe4:	577d                	li	a4,-1
    80000fe6:	177e                	slli	a4,a4,0x3f
    80000fe8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r"(x));
    80000fea:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000fee:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000ff2:	60a2                	ld	ra,8(sp)
    80000ff4:	6402                	ld	s0,0(sp)
    80000ff6:	0141                	addi	sp,sp,16
    80000ff8:	8082                	ret

0000000080000ffa <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000ffa:	7139                	addi	sp,sp,-64
    80000ffc:	fc06                	sd	ra,56(sp)
    80000ffe:	f822                	sd	s0,48(sp)
    80001000:	f426                	sd	s1,40(sp)
    80001002:	f04a                	sd	s2,32(sp)
    80001004:	ec4e                	sd	s3,24(sp)
    80001006:	e852                	sd	s4,16(sp)
    80001008:	e456                	sd	s5,8(sp)
    8000100a:	e05a                	sd	s6,0(sp)
    8000100c:	0080                	addi	s0,sp,64
    8000100e:	84aa                	mv	s1,a0
    80001010:	89ae                	mv	s3,a1
    80001012:	8b32                	mv	s6,a2
  if (va >= MAXVA)
    80001014:	57fd                	li	a5,-1
    80001016:	83e9                	srli	a5,a5,0x1a
    80001018:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--) {
    8000101a:	4ab1                	li	s5,12
  if (va >= MAXVA)
    8000101c:	04b7e263          	bltu	a5,a1,80001060 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80001020:	0149d933          	srl	s2,s3,s4
    80001024:	1ff97913          	andi	s2,s2,511
    80001028:	090e                	slli	s2,s2,0x3
    8000102a:	9926                	add	s2,s2,s1
    if (*pte & PTE_V) {
    8000102c:	00093483          	ld	s1,0(s2)
    80001030:	0014f793          	andi	a5,s1,1
    80001034:	cf85                	beqz	a5,8000106c <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001036:	80a9                	srli	s1,s1,0xa
    80001038:	04b2                	slli	s1,s1,0xc
  for (int level = 2; level > 0; level--) {
    8000103a:	3a5d                	addiw	s4,s4,-9
    8000103c:	ff5a12e3          	bne	s4,s5,80001020 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80001040:	00c9d513          	srli	a0,s3,0xc
    80001044:	1ff57513          	andi	a0,a0,511
    80001048:	050e                	slli	a0,a0,0x3
    8000104a:	9526                	add	a0,a0,s1
}
    8000104c:	70e2                	ld	ra,56(sp)
    8000104e:	7442                	ld	s0,48(sp)
    80001050:	74a2                	ld	s1,40(sp)
    80001052:	7902                	ld	s2,32(sp)
    80001054:	69e2                	ld	s3,24(sp)
    80001056:	6a42                	ld	s4,16(sp)
    80001058:	6aa2                	ld	s5,8(sp)
    8000105a:	6b02                	ld	s6,0(sp)
    8000105c:	6121                	addi	sp,sp,64
    8000105e:	8082                	ret
    panic("walk");
    80001060:	00006517          	auipc	a0,0x6
    80001064:	05050513          	addi	a0,a0,80 # 800070b0 <etext+0xb0>
    80001068:	fccff0ef          	jal	80000834 <panic>
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    8000106c:	020b0263          	beqz	s6,80001090 <walk+0x96>
    80001070:	b09ff0ef          	jal	80000b78 <kalloc>
    80001074:	84aa                	mv	s1,a0
    80001076:	d979                	beqz	a0,8000104c <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    80001078:	6605                	lui	a2,0x1
    8000107a:	4581                	li	a1,0
    8000107c:	ce9ff0ef          	jal	80000d64 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001080:	00c4d793          	srli	a5,s1,0xc
    80001084:	07aa                	slli	a5,a5,0xa
    80001086:	0017e793          	ori	a5,a5,1
    8000108a:	00f93023          	sd	a5,0(s2)
    8000108e:	b775                	j	8000103a <walk+0x40>
        return 0;
    80001090:	4501                	li	a0,0
    80001092:	bf6d                	j	8000104c <walk+0x52>

0000000080001094 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001094:	715d                	addi	sp,sp,-80
    80001096:	e486                	sd	ra,72(sp)
    80001098:	e0a2                	sd	s0,64(sp)
    8000109a:	fc26                	sd	s1,56(sp)
    8000109c:	f84a                	sd	s2,48(sp)
    8000109e:	f44e                	sd	s3,40(sp)
    800010a0:	f052                	sd	s4,32(sp)
    800010a2:	ec56                	sd	s5,24(sp)
    800010a4:	e85a                	sd	s6,16(sp)
    800010a6:	e45e                	sd	s7,8(sp)
    800010a8:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    800010aa:	03459793          	slli	a5,a1,0x34
    800010ae:	eba1                	bnez	a5,800010fe <mappages+0x6a>
    800010b0:	8a2a                	mv	s4,a0
    800010b2:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if ((size % PGSIZE) != 0)
    800010b4:	03461793          	slli	a5,a2,0x34
    800010b8:	eba9                	bnez	a5,8000110a <mappages+0x76>
    panic("mappages: size not aligned");

  if (size == 0)
    800010ba:	ce31                	beqz	a2,80001116 <mappages+0x82>
    panic("mappages: size");

  a = va;
  last = va + size - PGSIZE;
    800010bc:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    800010c0:	80060613          	addi	a2,a2,-2048
    800010c4:	00b60933          	add	s2,a2,a1
  a = va;
    800010c8:	84ae                	mv	s1,a1
  for (;;) {
    if ((pte = walk(pagetable, a, 1)) == 0)
    800010ca:	4b05                	li	s6,1
    800010cc:	40b689b3          	sub	s3,a3,a1
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    if ((pte = walk(pagetable, a, 1)) == 0)
    800010d2:	865a                	mv	a2,s6
    800010d4:	85a6                	mv	a1,s1
    800010d6:	8552                	mv	a0,s4
    800010d8:	f23ff0ef          	jal	80000ffa <walk>
    800010dc:	c929                	beqz	a0,8000112e <mappages+0x9a>
    if (*pte & PTE_V)
    800010de:	611c                	ld	a5,0(a0)
    800010e0:	8b85                	andi	a5,a5,1
    800010e2:	e3a1                	bnez	a5,80001122 <mappages+0x8e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010e4:	013487b3          	add	a5,s1,s3
    800010e8:	83b1                	srli	a5,a5,0xc
    800010ea:	07aa                	slli	a5,a5,0xa
    800010ec:	0157e7b3          	or	a5,a5,s5
    800010f0:	0017e793          	ori	a5,a5,1
    800010f4:	e11c                	sd	a5,0(a0)
    if (a == last)
    800010f6:	05248863          	beq	s1,s2,80001146 <mappages+0xb2>
    a += PGSIZE;
    800010fa:	94de                	add	s1,s1,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    800010fc:	bfd9                	j	800010d2 <mappages+0x3e>
    panic("mappages: va not aligned");
    800010fe:	00006517          	auipc	a0,0x6
    80001102:	fba50513          	addi	a0,a0,-70 # 800070b8 <etext+0xb8>
    80001106:	f2eff0ef          	jal	80000834 <panic>
    panic("mappages: size not aligned");
    8000110a:	00006517          	auipc	a0,0x6
    8000110e:	fce50513          	addi	a0,a0,-50 # 800070d8 <etext+0xd8>
    80001112:	f22ff0ef          	jal	80000834 <panic>
    panic("mappages: size");
    80001116:	00006517          	auipc	a0,0x6
    8000111a:	fe250513          	addi	a0,a0,-30 # 800070f8 <etext+0xf8>
    8000111e:	f16ff0ef          	jal	80000834 <panic>
      panic("mappages: remap");
    80001122:	00006517          	auipc	a0,0x6
    80001126:	fe650513          	addi	a0,a0,-26 # 80007108 <etext+0x108>
    8000112a:	f0aff0ef          	jal	80000834 <panic>
      return -1;
    8000112e:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001130:	60a6                	ld	ra,72(sp)
    80001132:	6406                	ld	s0,64(sp)
    80001134:	74e2                	ld	s1,56(sp)
    80001136:	7942                	ld	s2,48(sp)
    80001138:	79a2                	ld	s3,40(sp)
    8000113a:	7a02                	ld	s4,32(sp)
    8000113c:	6ae2                	ld	s5,24(sp)
    8000113e:	6b42                	ld	s6,16(sp)
    80001140:	6ba2                	ld	s7,8(sp)
    80001142:	6161                	addi	sp,sp,80
    80001144:	8082                	ret
  return 0;
    80001146:	4501                	li	a0,0
    80001148:	b7e5                	j	80001130 <mappages+0x9c>

000000008000114a <kvmmap>:
{
    8000114a:	1141                	addi	sp,sp,-16
    8000114c:	e406                	sd	ra,8(sp)
    8000114e:	e022                	sd	s0,0(sp)
    80001150:	0800                	addi	s0,sp,16
    80001152:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001154:	86b2                	mv	a3,a2
    80001156:	863e                	mv	a2,a5
    80001158:	f3dff0ef          	jal	80001094 <mappages>
    8000115c:	e509                	bnez	a0,80001166 <kvmmap+0x1c>
}
    8000115e:	60a2                	ld	ra,8(sp)
    80001160:	6402                	ld	s0,0(sp)
    80001162:	0141                	addi	sp,sp,16
    80001164:	8082                	ret
    panic("kvmmap");
    80001166:	00006517          	auipc	a0,0x6
    8000116a:	fb250513          	addi	a0,a0,-78 # 80007118 <etext+0x118>
    8000116e:	ec6ff0ef          	jal	80000834 <panic>

0000000080001172 <kvmmake>:
{
    80001172:	1101                	addi	sp,sp,-32
    80001174:	ec06                	sd	ra,24(sp)
    80001176:	e822                	sd	s0,16(sp)
    80001178:	e426                	sd	s1,8(sp)
    8000117a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    8000117c:	9fdff0ef          	jal	80000b78 <kalloc>
    80001180:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001182:	6605                	lui	a2,0x1
    80001184:	4581                	li	a1,0
    80001186:	bdfff0ef          	jal	80000d64 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000118a:	4719                	li	a4,6
    8000118c:	6685                	lui	a3,0x1
    8000118e:	10000637          	lui	a2,0x10000
    80001192:	85b2                	mv	a1,a2
    80001194:	8526                	mv	a0,s1
    80001196:	fb5ff0ef          	jal	8000114a <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000119a:	4719                	li	a4,6
    8000119c:	6685                	lui	a3,0x1
    8000119e:	10001637          	lui	a2,0x10001
    800011a2:	85b2                	mv	a1,a2
    800011a4:	8526                	mv	a0,s1
    800011a6:	fa5ff0ef          	jal	8000114a <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800011aa:	4719                	li	a4,6
    800011ac:	040006b7          	lui	a3,0x4000
    800011b0:	0c000637          	lui	a2,0xc000
    800011b4:	85b2                	mv	a1,a2
    800011b6:	8526                	mv	a0,s1
    800011b8:	f93ff0ef          	jal	8000114a <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    800011bc:	4729                	li	a4,10
    800011be:	80006697          	auipc	a3,0x80006
    800011c2:	e4268693          	addi	a3,a3,-446 # 7000 <_entry-0x7fff9000>
    800011c6:	4605                	li	a2,1
    800011c8:	067e                	slli	a2,a2,0x1f
    800011ca:	85b2                	mv	a1,a2
    800011cc:	8526                	mv	a0,s1
    800011ce:	f7dff0ef          	jal	8000114a <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext,
    800011d2:	4719                	li	a4,6
    800011d4:	00006697          	auipc	a3,0x6
    800011d8:	e2c68693          	addi	a3,a3,-468 # 80007000 <etext>
    800011dc:	47c5                	li	a5,17
    800011de:	07ee                	slli	a5,a5,0x1b
    800011e0:	40d786b3          	sub	a3,a5,a3
    800011e4:	00006617          	auipc	a2,0x6
    800011e8:	e1c60613          	addi	a2,a2,-484 # 80007000 <etext>
    800011ec:	85b2                	mv	a1,a2
    800011ee:	8526                	mv	a0,s1
    800011f0:	f5bff0ef          	jal	8000114a <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011f4:	4729                	li	a4,10
    800011f6:	6685                	lui	a3,0x1
    800011f8:	00005617          	auipc	a2,0x5
    800011fc:	e0860613          	addi	a2,a2,-504 # 80006000 <_trampoline>
    80001200:	040005b7          	lui	a1,0x4000
    80001204:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001206:	05b2                	slli	a1,a1,0xc
    80001208:	8526                	mv	a0,s1
    8000120a:	f41ff0ef          	jal	8000114a <kvmmap>
  proc_mapstacks(kpgtbl);
    8000120e:	8526                	mv	a0,s1
    80001210:	6c0000ef          	jal	800018d0 <proc_mapstacks>
}
    80001214:	8526                	mv	a0,s1
    80001216:	60e2                	ld	ra,24(sp)
    80001218:	6442                	ld	s0,16(sp)
    8000121a:	64a2                	ld	s1,8(sp)
    8000121c:	6105                	addi	sp,sp,32
    8000121e:	8082                	ret

0000000080001220 <kvminit>:
{
    80001220:	1141                	addi	sp,sp,-16
    80001222:	e406                	sd	ra,8(sp)
    80001224:	e022                	sd	s0,0(sp)
    80001226:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001228:	f4bff0ef          	jal	80001172 <kvmmake>
    8000122c:	00009797          	auipc	a5,0x9
    80001230:	18a7be23          	sd	a0,412(a5) # 8000a3c8 <kernel_pagetable>
}
    80001234:	60a2                	ld	ra,8(sp)
    80001236:	6402                	ld	s0,0(sp)
    80001238:	0141                	addi	sp,sp,16
    8000123a:	8082                	ret

000000008000123c <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000123c:	1101                	addi	sp,sp,-32
    8000123e:	ec06                	sd	ra,24(sp)
    80001240:	e822                	sd	s0,16(sp)
    80001242:	e426                	sd	s1,8(sp)
    80001244:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    80001246:	933ff0ef          	jal	80000b78 <kalloc>
    8000124a:	84aa                	mv	s1,a0
  if (pagetable == 0)
    8000124c:	c509                	beqz	a0,80001256 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000124e:	6605                	lui	a2,0x1
    80001250:	4581                	li	a1,0
    80001252:	b13ff0ef          	jal	80000d64 <memset>
  return pagetable;
}
    80001256:	8526                	mv	a0,s1
    80001258:	60e2                	ld	ra,24(sp)
    8000125a:	6442                	ld	s0,16(sp)
    8000125c:	64a2                	ld	s1,8(sp)
    8000125e:	6105                	addi	sp,sp,32
    80001260:	8082                	ret

0000000080001262 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001262:	7139                	addi	sp,sp,-64
    80001264:	fc06                	sd	ra,56(sp)
    80001266:	f822                	sd	s0,48(sp)
    80001268:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    8000126a:	03459793          	slli	a5,a1,0x34
    8000126e:	e38d                	bnez	a5,80001290 <uvmunmap+0x2e>
    80001270:	f04a                	sd	s2,32(sp)
    80001272:	ec4e                	sd	s3,24(sp)
    80001274:	e852                	sd	s4,16(sp)
    80001276:	e456                	sd	s5,8(sp)
    80001278:	e05a                	sd	s6,0(sp)
    8000127a:	8a2a                	mv	s4,a0
    8000127c:	892e                	mv	s2,a1
    8000127e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    80001280:	0632                	slli	a2,a2,0xc
    80001282:	00b609b3          	add	s3,a2,a1
    80001286:	6b05                	lui	s6,0x1
    80001288:	0535f963          	bgeu	a1,s3,800012da <uvmunmap+0x78>
    8000128c:	f426                	sd	s1,40(sp)
    8000128e:	a015                	j	800012b2 <uvmunmap+0x50>
    80001290:	f426                	sd	s1,40(sp)
    80001292:	f04a                	sd	s2,32(sp)
    80001294:	ec4e                	sd	s3,24(sp)
    80001296:	e852                	sd	s4,16(sp)
    80001298:	e456                	sd	s5,8(sp)
    8000129a:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    8000129c:	00006517          	auipc	a0,0x6
    800012a0:	e8450513          	addi	a0,a0,-380 # 80007120 <etext+0x120>
    800012a4:	d90ff0ef          	jal	80000834 <panic>
      continue;
    if (do_free) {
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
    800012a8:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    800012ac:	995a                	add	s2,s2,s6
    800012ae:	03397563          	bgeu	s2,s3,800012d8 <uvmunmap+0x76>
    if ((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    800012b2:	4601                	li	a2,0
    800012b4:	85ca                	mv	a1,s2
    800012b6:	8552                	mv	a0,s4
    800012b8:	d43ff0ef          	jal	80000ffa <walk>
    800012bc:	84aa                	mv	s1,a0
    800012be:	d57d                	beqz	a0,800012ac <uvmunmap+0x4a>
    if ((*pte & PTE_V) == 0) // has physical page been allocated?
    800012c0:	611c                	ld	a5,0(a0)
    800012c2:	0017f713          	andi	a4,a5,1
    800012c6:	d37d                	beqz	a4,800012ac <uvmunmap+0x4a>
    if (do_free) {
    800012c8:	fe0a80e3          	beqz	s5,800012a8 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    800012cc:	83a9                	srli	a5,a5,0xa
      kfree((void *)pa);
    800012ce:	00c79513          	slli	a0,a5,0xc
    800012d2:	f94ff0ef          	jal	80000a66 <kfree>
    800012d6:	bfc9                	j	800012a8 <uvmunmap+0x46>
    800012d8:	74a2                	ld	s1,40(sp)
    800012da:	7902                	ld	s2,32(sp)
    800012dc:	69e2                	ld	s3,24(sp)
    800012de:	6a42                	ld	s4,16(sp)
    800012e0:	6aa2                	ld	s5,8(sp)
    800012e2:	6b02                	ld	s6,0(sp)
  }
}
    800012e4:	70e2                	ld	ra,56(sp)
    800012e6:	7442                	ld	s0,48(sp)
    800012e8:	6121                	addi	sp,sp,64
    800012ea:	8082                	ret

00000000800012ec <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012ec:	1101                	addi	sp,sp,-32
    800012ee:	ec06                	sd	ra,24(sp)
    800012f0:	e822                	sd	s0,16(sp)
    800012f2:	e426                	sd	s1,8(sp)
    800012f4:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    800012f6:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    800012f8:	00b67d63          	bgeu	a2,a1,80001312 <uvmdealloc+0x26>
    800012fc:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz)) {
    800012fe:	6785                	lui	a5,0x1
    80001300:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001302:	00f60733          	add	a4,a2,a5
    80001306:	76fd                	lui	a3,0xfffff
    80001308:	8f75                	and	a4,a4,a3
    8000130a:	97ae                	add	a5,a5,a1
    8000130c:	8ff5                	and	a5,a5,a3
    8000130e:	00f76863          	bltu	a4,a5,8000131e <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001312:	8526                	mv	a0,s1
    80001314:	60e2                	ld	ra,24(sp)
    80001316:	6442                	ld	s0,16(sp)
    80001318:	64a2                	ld	s1,8(sp)
    8000131a:	6105                	addi	sp,sp,32
    8000131c:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000131e:	8f99                	sub	a5,a5,a4
    80001320:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001322:	4685                	li	a3,1
    80001324:	0007861b          	sext.w	a2,a5
    80001328:	85ba                	mv	a1,a4
    8000132a:	f39ff0ef          	jal	80001262 <uvmunmap>
    8000132e:	b7d5                	j	80001312 <uvmdealloc+0x26>

0000000080001330 <uvmalloc>:
  if (newsz < oldsz)
    80001330:	0ab66163          	bltu	a2,a1,800013d2 <uvmalloc+0xa2>
{
    80001334:	715d                	addi	sp,sp,-80
    80001336:	e486                	sd	ra,72(sp)
    80001338:	e0a2                	sd	s0,64(sp)
    8000133a:	f84a                	sd	s2,48(sp)
    8000133c:	f052                	sd	s4,32(sp)
    8000133e:	ec56                	sd	s5,24(sp)
    80001340:	e45e                	sd	s7,8(sp)
    80001342:	0880                	addi	s0,sp,80
    80001344:	8aaa                	mv	s5,a0
    80001346:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001348:	6785                	lui	a5,0x1
    8000134a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000134c:	95be                	add	a1,a1,a5
    8000134e:	77fd                	lui	a5,0xfffff
    80001350:	00f5f933          	and	s2,a1,a5
    80001354:	8bca                	mv	s7,s2
  for (a = oldsz; a < newsz; a += PGSIZE) {
    80001356:	08c97063          	bgeu	s2,a2,800013d6 <uvmalloc+0xa6>
    8000135a:	fc26                	sd	s1,56(sp)
    8000135c:	f44e                	sd	s3,40(sp)
    8000135e:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    80001360:	6985                	lui	s3,0x1
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    80001362:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001366:	813ff0ef          	jal	80000b78 <kalloc>
    8000136a:	84aa                	mv	s1,a0
    if (mem == 0) {
    8000136c:	c50d                	beqz	a0,80001396 <uvmalloc+0x66>
    memset(mem, 0, PGSIZE);
    8000136e:	864e                	mv	a2,s3
    80001370:	4581                	li	a1,0
    80001372:	9f3ff0ef          	jal	80000d64 <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    80001376:	875a                	mv	a4,s6
    80001378:	86a6                	mv	a3,s1
    8000137a:	864e                	mv	a2,s3
    8000137c:	85ca                	mv	a1,s2
    8000137e:	8556                	mv	a0,s5
    80001380:	d15ff0ef          	jal	80001094 <mappages>
    80001384:	e915                	bnez	a0,800013b8 <uvmalloc+0x88>
  for (a = oldsz; a < newsz; a += PGSIZE) {
    80001386:	994e                	add	s2,s2,s3
    80001388:	fd496fe3          	bltu	s2,s4,80001366 <uvmalloc+0x36>
  return newsz;
    8000138c:	8552                	mv	a0,s4
    8000138e:	74e2                	ld	s1,56(sp)
    80001390:	79a2                	ld	s3,40(sp)
    80001392:	6b42                	ld	s6,16(sp)
    80001394:	a811                	j	800013a8 <uvmalloc+0x78>
      uvmdealloc(pagetable, a, oldsz);
    80001396:	865e                	mv	a2,s7
    80001398:	85ca                	mv	a1,s2
    8000139a:	8556                	mv	a0,s5
    8000139c:	f51ff0ef          	jal	800012ec <uvmdealloc>
      return 0;
    800013a0:	4501                	li	a0,0
    800013a2:	74e2                	ld	s1,56(sp)
    800013a4:	79a2                	ld	s3,40(sp)
    800013a6:	6b42                	ld	s6,16(sp)
}
    800013a8:	60a6                	ld	ra,72(sp)
    800013aa:	6406                	ld	s0,64(sp)
    800013ac:	7942                	ld	s2,48(sp)
    800013ae:	7a02                	ld	s4,32(sp)
    800013b0:	6ae2                	ld	s5,24(sp)
    800013b2:	6ba2                	ld	s7,8(sp)
    800013b4:	6161                	addi	sp,sp,80
    800013b6:	8082                	ret
      kfree(mem);
    800013b8:	8526                	mv	a0,s1
    800013ba:	eacff0ef          	jal	80000a66 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013be:	865e                	mv	a2,s7
    800013c0:	85ca                	mv	a1,s2
    800013c2:	8556                	mv	a0,s5
    800013c4:	f29ff0ef          	jal	800012ec <uvmdealloc>
      return 0;
    800013c8:	4501                	li	a0,0
    800013ca:	74e2                	ld	s1,56(sp)
    800013cc:	79a2                	ld	s3,40(sp)
    800013ce:	6b42                	ld	s6,16(sp)
    800013d0:	bfe1                	j	800013a8 <uvmalloc+0x78>
    return oldsz;
    800013d2:	852e                	mv	a0,a1
}
    800013d4:	8082                	ret
  return newsz;
    800013d6:	8532                	mv	a0,a2
    800013d8:	bfc1                	j	800013a8 <uvmalloc+0x78>

00000000800013da <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013da:	7179                	addi	sp,sp,-48
    800013dc:	f406                	sd	ra,40(sp)
    800013de:	f022                	sd	s0,32(sp)
    800013e0:	ec26                	sd	s1,24(sp)
    800013e2:	e84a                	sd	s2,16(sp)
    800013e4:	e44e                	sd	s3,8(sp)
    800013e6:	1800                	addi	s0,sp,48
    800013e8:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++) {
    800013ea:	84aa                	mv	s1,a0
    800013ec:	6905                	lui	s2,0x1
    800013ee:	992a                	add	s2,s2,a0
    800013f0:	a811                	j	80001404 <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if (pte & PTE_V) {
      panic("freewalk: leaf");
    800013f2:	00006517          	auipc	a0,0x6
    800013f6:	d4650513          	addi	a0,a0,-698 # 80007138 <etext+0x138>
    800013fa:	c3aff0ef          	jal	80000834 <panic>
  for (int i = 0; i < 512; i++) {
    800013fe:	04a1                	addi	s1,s1,8
    80001400:	03248163          	beq	s1,s2,80001422 <freewalk+0x48>
    pte_t pte = pagetable[i];
    80001404:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    80001406:	0017f713          	andi	a4,a5,1
    8000140a:	db75                	beqz	a4,800013fe <freewalk+0x24>
    8000140c:	00e7f713          	andi	a4,a5,14
    80001410:	f36d                	bnez	a4,800013f2 <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    80001412:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001414:	00c79513          	slli	a0,a5,0xc
    80001418:	fc3ff0ef          	jal	800013da <freewalk>
      pagetable[i] = 0;
    8000141c:	0004b023          	sd	zero,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    80001420:	bff9                	j	800013fe <freewalk+0x24>
    }
  }
  kfree((void *)pagetable);
    80001422:	854e                	mv	a0,s3
    80001424:	e42ff0ef          	jal	80000a66 <kfree>
}
    80001428:	70a2                	ld	ra,40(sp)
    8000142a:	7402                	ld	s0,32(sp)
    8000142c:	64e2                	ld	s1,24(sp)
    8000142e:	6942                	ld	s2,16(sp)
    80001430:	69a2                	ld	s3,8(sp)
    80001432:	6145                	addi	sp,sp,48
    80001434:	8082                	ret

0000000080001436 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001436:	1101                	addi	sp,sp,-32
    80001438:	ec06                	sd	ra,24(sp)
    8000143a:	e822                	sd	s0,16(sp)
    8000143c:	e426                	sd	s1,8(sp)
    8000143e:	1000                	addi	s0,sp,32
    80001440:	84aa                	mv	s1,a0
  if (sz > 0)
    80001442:	e989                	bnez	a1,80001454 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    80001444:	8526                	mv	a0,s1
    80001446:	f95ff0ef          	jal	800013da <freewalk>
}
    8000144a:	60e2                	ld	ra,24(sp)
    8000144c:	6442                	ld	s0,16(sp)
    8000144e:	64a2                	ld	s1,8(sp)
    80001450:	6105                	addi	sp,sp,32
    80001452:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80001454:	6785                	lui	a5,0x1
    80001456:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001458:	95be                	add	a1,a1,a5
    8000145a:	4685                	li	a3,1
    8000145c:	00c5d613          	srli	a2,a1,0xc
    80001460:	4581                	li	a1,0
    80001462:	e01ff0ef          	jal	80001262 <uvmunmap>
    80001466:	bff9                	j	80001444 <uvmfree+0xe>

0000000080001468 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for (i = 0; i < sz; i += PGSIZE) {
    80001468:	ca59                	beqz	a2,800014fe <uvmcopy+0x96>
{
    8000146a:	715d                	addi	sp,sp,-80
    8000146c:	e486                	sd	ra,72(sp)
    8000146e:	e0a2                	sd	s0,64(sp)
    80001470:	fc26                	sd	s1,56(sp)
    80001472:	f84a                	sd	s2,48(sp)
    80001474:	f44e                	sd	s3,40(sp)
    80001476:	f052                	sd	s4,32(sp)
    80001478:	ec56                	sd	s5,24(sp)
    8000147a:	e85a                	sd	s6,16(sp)
    8000147c:	e45e                	sd	s7,8(sp)
    8000147e:	0880                	addi	s0,sp,80
    80001480:	8b2a                	mv	s6,a0
    80001482:	8bae                	mv	s7,a1
    80001484:	8ab2                	mv	s5,a2
  for (i = 0; i < sz; i += PGSIZE) {
    80001486:	4481                	li	s1,0
      continue; // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if ((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    80001488:	6a05                	lui	s4,0x1
    8000148a:	a021                	j	80001492 <uvmcopy+0x2a>
  for (i = 0; i < sz; i += PGSIZE) {
    8000148c:	94d2                	add	s1,s1,s4
    8000148e:	0554fc63          	bgeu	s1,s5,800014e6 <uvmcopy+0x7e>
    if ((pte = walk(old, i, 0)) == 0)
    80001492:	4601                	li	a2,0
    80001494:	85a6                	mv	a1,s1
    80001496:	855a                	mv	a0,s6
    80001498:	b63ff0ef          	jal	80000ffa <walk>
    8000149c:	d965                	beqz	a0,8000148c <uvmcopy+0x24>
    if ((*pte & PTE_V) == 0)
    8000149e:	00053983          	ld	s3,0(a0)
    800014a2:	0019f793          	andi	a5,s3,1
    800014a6:	d3fd                	beqz	a5,8000148c <uvmcopy+0x24>
    if ((mem = kalloc()) == 0)
    800014a8:	ed0ff0ef          	jal	80000b78 <kalloc>
    800014ac:	892a                	mv	s2,a0
    800014ae:	c11d                	beqz	a0,800014d4 <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    800014b0:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char *)pa, PGSIZE);
    800014b4:	8652                	mv	a2,s4
    800014b6:	05b2                	slli	a1,a1,0xc
    800014b8:	90dff0ef          	jal	80000dc4 <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0) {
    800014bc:	3ff9f713          	andi	a4,s3,1023
    800014c0:	86ca                	mv	a3,s2
    800014c2:	8652                	mv	a2,s4
    800014c4:	85a6                	mv	a1,s1
    800014c6:	855e                	mv	a0,s7
    800014c8:	bcdff0ef          	jal	80001094 <mappages>
    800014cc:	d161                	beqz	a0,8000148c <uvmcopy+0x24>
      kfree(mem);
    800014ce:	854a                	mv	a0,s2
    800014d0:	d96ff0ef          	jal	80000a66 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014d4:	4685                	li	a3,1
    800014d6:	00c4d613          	srli	a2,s1,0xc
    800014da:	4581                	li	a1,0
    800014dc:	855e                	mv	a0,s7
    800014de:	d85ff0ef          	jal	80001262 <uvmunmap>
  return -1;
    800014e2:	557d                	li	a0,-1
    800014e4:	a011                	j	800014e8 <uvmcopy+0x80>
  return 0;
    800014e6:	4501                	li	a0,0
}
    800014e8:	60a6                	ld	ra,72(sp)
    800014ea:	6406                	ld	s0,64(sp)
    800014ec:	74e2                	ld	s1,56(sp)
    800014ee:	7942                	ld	s2,48(sp)
    800014f0:	79a2                	ld	s3,40(sp)
    800014f2:	7a02                	ld	s4,32(sp)
    800014f4:	6ae2                	ld	s5,24(sp)
    800014f6:	6b42                	ld	s6,16(sp)
    800014f8:	6ba2                	ld	s7,8(sp)
    800014fa:	6161                	addi	sp,sp,80
    800014fc:	8082                	ret
  return 0;
    800014fe:	4501                	li	a0,0
}
    80001500:	8082                	ret

0000000080001502 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001502:	1141                	addi	sp,sp,-16
    80001504:	e406                	sd	ra,8(sp)
    80001506:	e022                	sd	s0,0(sp)
    80001508:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    8000150a:	4601                	li	a2,0
    8000150c:	aefff0ef          	jal	80000ffa <walk>
  if (pte == 0)
    80001510:	c901                	beqz	a0,80001520 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001512:	611c                	ld	a5,0(a0)
    80001514:	9bbd                	andi	a5,a5,-17
    80001516:	e11c                	sd	a5,0(a0)
}
    80001518:	60a2                	ld	ra,8(sp)
    8000151a:	6402                	ld	s0,0(sp)
    8000151c:	0141                	addi	sp,sp,16
    8000151e:	8082                	ret
    panic("uvmclear");
    80001520:	00006517          	auipc	a0,0x6
    80001524:	c2850513          	addi	a0,a0,-984 # 80007148 <etext+0x148>
    80001528:	b0cff0ef          	jal	80000834 <panic>

000000008000152c <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    8000152c:	1141                	addi	sp,sp,-16
    8000152e:	e406                	sd	ra,8(sp)
    80001530:	e022                	sd	s0,0(sp)
    80001532:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001534:	4601                	li	a2,0
    80001536:	ac5ff0ef          	jal	80000ffa <walk>
  if (pte == 0) {
    8000153a:	c119                	beqz	a0,80001540 <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V) {
    8000153c:	6108                	ld	a0,0(a0)
    8000153e:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001540:	60a2                	ld	ra,8(sp)
    80001542:	6402                	ld	s0,0(sp)
    80001544:	0141                	addi	sp,sp,16
    80001546:	8082                	ret

0000000080001548 <vmfault>:
{
    80001548:	7179                	addi	sp,sp,-48
    8000154a:	f406                	sd	ra,40(sp)
    8000154c:	f022                	sd	s0,32(sp)
    8000154e:	ec26                	sd	s1,24(sp)
    80001550:	e84a                	sd	s2,16(sp)
    80001552:	e44e                	sd	s3,8(sp)
    80001554:	e052                	sd	s4,0(sp)
    80001556:	1800                	addi	s0,sp,48
    80001558:	89aa                	mv	s3,a0
    8000155a:	892e                	mv	s2,a1
    8000155c:	84b2                	mv	s1,a2
  struct proc *p = myproc();
    8000155e:	500000ef          	jal	80001a5e <myproc>
    return 0;
    80001562:	4a01                	li	s4,0
  if (va >= psz)
    80001564:	0324f263          	bgeu	s1,s2,80001588 <vmfault+0x40>
  if (p && va < PGROUNDDOWN(p->trapframe->sp))
    80001568:	c901                	beqz	a0,80001578 <vmfault+0x30>
    8000156a:	6d3c                	ld	a5,88(a0)
    8000156c:	7b9c                	ld	a5,48(a5)
    8000156e:	777d                	lui	a4,0xfffff
    80001570:	8ff9                	and	a5,a5,a4
    return 0;
    80001572:	4a01                	li	s4,0
  if (p && va < PGROUNDDOWN(p->trapframe->sp))
    80001574:	00f4ea63          	bltu	s1,a5,80001588 <vmfault+0x40>
  va = PGROUNDDOWN(va);
    80001578:	77fd                	lui	a5,0xfffff
    8000157a:	8cfd                	and	s1,s1,a5
  if (ismapped(pagetable, va)) {
    8000157c:	85a6                	mv	a1,s1
    8000157e:	854e                	mv	a0,s3
    80001580:	fadff0ef          	jal	8000152c <ismapped>
    return 0;
    80001584:	4a01                	li	s4,0
  if (ismapped(pagetable, va)) {
    80001586:	c911                	beqz	a0,8000159a <vmfault+0x52>
}
    80001588:	8552                	mv	a0,s4
    8000158a:	70a2                	ld	ra,40(sp)
    8000158c:	7402                	ld	s0,32(sp)
    8000158e:	64e2                	ld	s1,24(sp)
    80001590:	6942                	ld	s2,16(sp)
    80001592:	69a2                	ld	s3,8(sp)
    80001594:	6a02                	ld	s4,0(sp)
    80001596:	6145                	addi	sp,sp,48
    80001598:	8082                	ret
  mem = (uint64)kalloc();
    8000159a:	ddeff0ef          	jal	80000b78 <kalloc>
    8000159e:	892a                	mv	s2,a0
  if (mem == 0)
    800015a0:	d565                	beqz	a0,80001588 <vmfault+0x40>
  mem = (uint64)kalloc();
    800015a2:	8a2a                	mv	s4,a0
  memset((void *)mem, 0, PGSIZE);
    800015a4:	6605                	lui	a2,0x1
    800015a6:	4581                	li	a1,0
    800015a8:	fbcff0ef          	jal	80000d64 <memset>
  if (mappages(pagetable, va, PGSIZE, mem, PTE_W | PTE_U | PTE_R | PTE_X) != 0) {
    800015ac:	4779                	li	a4,30
    800015ae:	86ca                	mv	a3,s2
    800015b0:	6605                	lui	a2,0x1
    800015b2:	85a6                	mv	a1,s1
    800015b4:	854e                	mv	a0,s3
    800015b6:	adfff0ef          	jal	80001094 <mappages>
    800015ba:	d579                	beqz	a0,80001588 <vmfault+0x40>
    kfree((void *)mem);
    800015bc:	854a                	mv	a0,s2
    800015be:	ca8ff0ef          	jal	80000a66 <kfree>
    return 0;
    800015c2:	4a01                	li	s4,0
    800015c4:	b7d1                	j	80001588 <vmfault+0x40>

00000000800015c6 <walkaddr>:
  if (va >= MAXVA)
    800015c6:	57fd                	li	a5,-1
    800015c8:	83e9                	srli	a5,a5,0x1a
    800015ca:	00b7f463          	bgeu	a5,a1,800015d2 <walkaddr+0xc>
    return 0;
    800015ce:	4501                	li	a0,0
}
    800015d0:	8082                	ret
{
    800015d2:	1101                	addi	sp,sp,-32
    800015d4:	ec06                	sd	ra,24(sp)
    800015d6:	e822                	sd	s0,16(sp)
    800015d8:	e426                	sd	s1,8(sp)
    800015da:	e04a                	sd	s2,0(sp)
    800015dc:	1000                	addi	s0,sp,32
    800015de:	84aa                	mv	s1,a0
    800015e0:	892e                	mv	s2,a1
  pte = walk(pagetable, va, 0);
    800015e2:	4601                	li	a2,0
    800015e4:	a17ff0ef          	jal	80000ffa <walk>
    800015e8:	87aa                	mv	a5,a0
  if (pte == 0 || (*pte & PTE_V) == 0) {
    800015ea:	c501                	beqz	a0,800015f2 <walkaddr+0x2c>
    800015ec:	6118                	ld	a4,0(a0)
    800015ee:	8b05                	andi	a4,a4,1
    800015f0:	e731                	bnez	a4,8000163c <walkaddr+0x76>
    struct proc *p = myproc();
    800015f2:	46c000ef          	jal	80001a5e <myproc>
    800015f6:	87aa                	mv	a5,a0
    if (p && pagetable == p->pagetable && va < p->sz && va >= PGROUNDDOWN(p->trapframe->sp)) {
    800015f8:	cd29                	beqz	a0,80001652 <walkaddr+0x8c>
    800015fa:	6938                	ld	a4,80(a0)
      return 0;
    800015fc:	4501                	li	a0,0
    if (p && pagetable == p->pagetable && va < p->sz && va >= PGROUNDDOWN(p->trapframe->sp)) {
    800015fe:	00970863          	beq	a4,s1,8000160e <walkaddr+0x48>
}
    80001602:	60e2                	ld	ra,24(sp)
    80001604:	6442                	ld	s0,16(sp)
    80001606:	64a2                	ld	s1,8(sp)
    80001608:	6902                	ld	s2,0(sp)
    8000160a:	6105                	addi	sp,sp,32
    8000160c:	8082                	ret
    if (p && pagetable == p->pagetable && va < p->sz && va >= PGROUNDDOWN(p->trapframe->sp)) {
    8000160e:	67ac                	ld	a1,72(a5)
    80001610:	feb979e3          	bgeu	s2,a1,80001602 <walkaddr+0x3c>
    80001614:	6fbc                	ld	a5,88(a5)
    80001616:	7b9c                	ld	a5,48(a5)
    80001618:	777d                	lui	a4,0xfffff
    8000161a:	8ff9                	and	a5,a5,a4
    8000161c:	fef963e3          	bltu	s2,a5,80001602 <walkaddr+0x3c>
      if (vmfault(pagetable, p->sz, va, 1) != 0) {
    80001620:	4685                	li	a3,1
    80001622:	864a                	mv	a2,s2
    80001624:	8526                	mv	a0,s1
    80001626:	f23ff0ef          	jal	80001548 <vmfault>
    8000162a:	dd61                	beqz	a0,80001602 <walkaddr+0x3c>
        pte = walk(pagetable, va, 0);
    8000162c:	4601                	li	a2,0
    8000162e:	85ca                	mv	a1,s2
    80001630:	8526                	mv	a0,s1
    80001632:	9c9ff0ef          	jal	80000ffa <walk>
    80001636:	87aa                	mv	a5,a0
    return 0;
    80001638:	4501                	li	a0,0
  if (pte == 0)
    8000163a:	d7e1                	beqz	a5,80001602 <walkaddr+0x3c>
  if ((*pte & PTE_V) == 0)
    8000163c:	639c                	ld	a5,0(a5)
  if ((*pte & PTE_U) == 0)
    8000163e:	0117f693          	andi	a3,a5,17
    80001642:	4745                	li	a4,17
    return 0;
    80001644:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    80001646:	fae69ee3          	bne	a3,a4,80001602 <walkaddr+0x3c>
  pa = PTE2PA(*pte);
    8000164a:	83a9                	srli	a5,a5,0xa
    8000164c:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001650:	bf4d                	j	80001602 <walkaddr+0x3c>
      return 0;
    80001652:	4501                	li	a0,0
    80001654:	b77d                	j	80001602 <walkaddr+0x3c>

0000000080001656 <copyout>:
  while (len > 0) {
    80001656:	cf49                	beqz	a4,800016f0 <copyout+0x9a>
{
    80001658:	7159                	addi	sp,sp,-112
    8000165a:	f486                	sd	ra,104(sp)
    8000165c:	f0a2                	sd	s0,96(sp)
    8000165e:	eca6                	sd	s1,88(sp)
    80001660:	e8ca                	sd	s2,80(sp)
    80001662:	e4ce                	sd	s3,72(sp)
    80001664:	e0d2                	sd	s4,64(sp)
    80001666:	fc56                	sd	s5,56(sp)
    80001668:	f85a                	sd	s6,48(sp)
    8000166a:	f45e                	sd	s7,40(sp)
    8000166c:	f062                	sd	s8,32(sp)
    8000166e:	ec66                	sd	s9,24(sp)
    80001670:	e86a                	sd	s10,16(sp)
    80001672:	e46e                	sd	s11,8(sp)
    80001674:	1880                	addi	s0,sp,112
    80001676:	8baa                	mv	s7,a0
    80001678:	8dae                	mv	s11,a1
    8000167a:	8a32                	mv	s4,a2
    8000167c:	8b36                	mv	s6,a3
    8000167e:	8aba                	mv	s5,a4
    va0 = PGROUNDDOWN(dstva);
    80001680:	7d7d                	lui	s10,0xfffff
    if (va0 >= MAXVA)
    80001682:	5cfd                	li	s9,-1
    80001684:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    80001688:	6c05                	lui	s8,0x1
    8000168a:	a005                	j	800016aa <copyout+0x54>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000168c:	409a0533          	sub	a0,s4,s1
    80001690:	0009061b          	sext.w	a2,s2
    80001694:	85da                	mv	a1,s6
    80001696:	954e                	add	a0,a0,s3
    80001698:	f2cff0ef          	jal	80000dc4 <memmove>
    len -= n;
    8000169c:	412a8ab3          	sub	s5,s5,s2
    src += n;
    800016a0:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    800016a2:	01848a33          	add	s4,s1,s8
  while (len > 0) {
    800016a6:	040a8363          	beqz	s5,800016ec <copyout+0x96>
    va0 = PGROUNDDOWN(dstva);
    800016aa:	01aa74b3          	and	s1,s4,s10
    if (va0 >= MAXVA)
    800016ae:	049ce363          	bltu	s9,s1,800016f4 <copyout+0x9e>
    pa0 = walkaddr(pagetable, va0);
    800016b2:	85a6                	mv	a1,s1
    800016b4:	855e                	mv	a0,s7
    800016b6:	f11ff0ef          	jal	800015c6 <walkaddr>
    800016ba:	89aa                	mv	s3,a0
    if (pa0 == 0) {
    800016bc:	e909                	bnez	a0,800016ce <copyout+0x78>
      if ((pa0 = vmfault(pagetable, psz, va0, 0)) == 0) {
    800016be:	4681                	li	a3,0
    800016c0:	8626                	mv	a2,s1
    800016c2:	85ee                	mv	a1,s11
    800016c4:	855e                	mv	a0,s7
    800016c6:	e83ff0ef          	jal	80001548 <vmfault>
    800016ca:	89aa                	mv	s3,a0
    800016cc:	c521                	beqz	a0,80001714 <copyout+0xbe>
    pte = walk(pagetable, va0, 0);
    800016ce:	4601                	li	a2,0
    800016d0:	85a6                	mv	a1,s1
    800016d2:	855e                	mv	a0,s7
    800016d4:	927ff0ef          	jal	80000ffa <walk>
    if ((*pte & PTE_W) == 0)
    800016d8:	611c                	ld	a5,0(a0)
    800016da:	8b91                	andi	a5,a5,4
    800016dc:	cf95                	beqz	a5,80001718 <copyout+0xc2>
    n = PGSIZE - (dstva - va0);
    800016de:	41448933          	sub	s2,s1,s4
    800016e2:	9962                	add	s2,s2,s8
    if (n > len)
    800016e4:	fb2af4e3          	bgeu	s5,s2,8000168c <copyout+0x36>
    800016e8:	8956                	mv	s2,s5
    800016ea:	b74d                	j	8000168c <copyout+0x36>
  return 0;
    800016ec:	4501                	li	a0,0
    800016ee:	a021                	j	800016f6 <copyout+0xa0>
    800016f0:	4501                	li	a0,0
}
    800016f2:	8082                	ret
      return -1;
    800016f4:	557d                	li	a0,-1
}
    800016f6:	70a6                	ld	ra,104(sp)
    800016f8:	7406                	ld	s0,96(sp)
    800016fa:	64e6                	ld	s1,88(sp)
    800016fc:	6946                	ld	s2,80(sp)
    800016fe:	69a6                	ld	s3,72(sp)
    80001700:	6a06                	ld	s4,64(sp)
    80001702:	7ae2                	ld	s5,56(sp)
    80001704:	7b42                	ld	s6,48(sp)
    80001706:	7ba2                	ld	s7,40(sp)
    80001708:	7c02                	ld	s8,32(sp)
    8000170a:	6ce2                	ld	s9,24(sp)
    8000170c:	6d42                	ld	s10,16(sp)
    8000170e:	6da2                	ld	s11,8(sp)
    80001710:	6165                	addi	sp,sp,112
    80001712:	8082                	ret
        return -1;
    80001714:	557d                	li	a0,-1
    80001716:	b7c5                	j	800016f6 <copyout+0xa0>
      return -1;
    80001718:	557d                	li	a0,-1
    8000171a:	bff1                	j	800016f6 <copyout+0xa0>

000000008000171c <copyin>:
  while (len > 0) {
    8000171c:	cf41                	beqz	a4,800017b4 <copyin+0x98>
{
    8000171e:	711d                	addi	sp,sp,-96
    80001720:	ec86                	sd	ra,88(sp)
    80001722:	e8a2                	sd	s0,80(sp)
    80001724:	e4a6                	sd	s1,72(sp)
    80001726:	e0ca                	sd	s2,64(sp)
    80001728:	fc4e                	sd	s3,56(sp)
    8000172a:	f852                	sd	s4,48(sp)
    8000172c:	f456                	sd	s5,40(sp)
    8000172e:	f05a                	sd	s6,32(sp)
    80001730:	ec5e                	sd	s7,24(sp)
    80001732:	e862                	sd	s8,16(sp)
    80001734:	e466                	sd	s9,8(sp)
    80001736:	e06a                	sd	s10,0(sp)
    80001738:	1080                	addi	s0,sp,96
    8000173a:	8baa                	mv	s7,a0
    8000173c:	8cae                	mv	s9,a1
    8000173e:	8ab2                	mv	s5,a2
    80001740:	8936                	mv	s2,a3
    80001742:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(srcva);
    80001744:	7c7d                	lui	s8,0xfffff
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    80001746:	4d05                	li	s10,1
    n = PGSIZE - (srcva - va0);
    80001748:	6b05                	lui	s6,0x1
    8000174a:	a035                	j	80001776 <copyin+0x5a>
    8000174c:	412984b3          	sub	s1,s3,s2
    80001750:	94da                	add	s1,s1,s6
    if (n > len)
    80001752:	009a7363          	bgeu	s4,s1,80001758 <copyin+0x3c>
    80001756:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001758:	413905b3          	sub	a1,s2,s3
    8000175c:	0004861b          	sext.w	a2,s1
    80001760:	95aa                	add	a1,a1,a0
    80001762:	8556                	mv	a0,s5
    80001764:	e60ff0ef          	jal	80000dc4 <memmove>
    len -= n;
    80001768:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000176c:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    8000176e:	01698933          	add	s2,s3,s6
  while (len > 0) {
    80001772:	020a0263          	beqz	s4,80001796 <copyin+0x7a>
    va0 = PGROUNDDOWN(srcva);
    80001776:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    8000177a:	85ce                	mv	a1,s3
    8000177c:	855e                	mv	a0,s7
    8000177e:	e49ff0ef          	jal	800015c6 <walkaddr>
    if (pa0 == 0) {
    80001782:	f569                	bnez	a0,8000174c <copyin+0x30>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    80001784:	86ea                	mv	a3,s10
    80001786:	864e                	mv	a2,s3
    80001788:	85e6                	mv	a1,s9
    8000178a:	855e                	mv	a0,s7
    8000178c:	dbdff0ef          	jal	80001548 <vmfault>
    80001790:	fd55                	bnez	a0,8000174c <copyin+0x30>
        return -1;
    80001792:	557d                	li	a0,-1
    80001794:	a011                	j	80001798 <copyin+0x7c>
  return 0;
    80001796:	4501                	li	a0,0
}
    80001798:	60e6                	ld	ra,88(sp)
    8000179a:	6446                	ld	s0,80(sp)
    8000179c:	64a6                	ld	s1,72(sp)
    8000179e:	6906                	ld	s2,64(sp)
    800017a0:	79e2                	ld	s3,56(sp)
    800017a2:	7a42                	ld	s4,48(sp)
    800017a4:	7aa2                	ld	s5,40(sp)
    800017a6:	7b02                	ld	s6,32(sp)
    800017a8:	6be2                	ld	s7,24(sp)
    800017aa:	6c42                	ld	s8,16(sp)
    800017ac:	6ca2                	ld	s9,8(sp)
    800017ae:	6d02                	ld	s10,0(sp)
    800017b0:	6125                	addi	sp,sp,96
    800017b2:	8082                	ret
  return 0;
    800017b4:	4501                	li	a0,0
}
    800017b6:	8082                	ret

00000000800017b8 <copyinstr>:
  while (got_null == 0 && max > 0) {
    800017b8:	c769                	beqz	a4,80001882 <copyinstr+0xca>
{
    800017ba:	711d                	addi	sp,sp,-96
    800017bc:	ec86                	sd	ra,88(sp)
    800017be:	e8a2                	sd	s0,80(sp)
    800017c0:	e4a6                	sd	s1,72(sp)
    800017c2:	e0ca                	sd	s2,64(sp)
    800017c4:	fc4e                	sd	s3,56(sp)
    800017c6:	f852                	sd	s4,48(sp)
    800017c8:	f456                	sd	s5,40(sp)
    800017ca:	f05a                	sd	s6,32(sp)
    800017cc:	ec5e                	sd	s7,24(sp)
    800017ce:	e862                	sd	s8,16(sp)
    800017d0:	e466                	sd	s9,8(sp)
    800017d2:	1080                	addi	s0,sp,96
    800017d4:	8b2a                	mv	s6,a0
    800017d6:	8c2e                	mv	s8,a1
    800017d8:	89b2                	mv	s3,a2
    800017da:	84b6                	mv	s1,a3
    800017dc:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(srcva);
    800017de:	7bfd                	lui	s7,0xfffff
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    800017e0:	4c85                	li	s9,1
    n = PGSIZE - (srcva - va0);
    800017e2:	6a85                	lui	s5,0x1
    800017e4:	a881                	j	80001834 <copyinstr+0x7c>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    800017e6:	86e6                	mv	a3,s9
    800017e8:	864a                	mv	a2,s2
    800017ea:	85e2                	mv	a1,s8
    800017ec:	855a                	mv	a0,s6
    800017ee:	d5bff0ef          	jal	80001548 <vmfault>
    800017f2:	e921                	bnez	a0,80001842 <copyinstr+0x8a>
        return -1;
    800017f4:	557d                	li	a0,-1
    800017f6:	a801                	j	80001806 <copyinstr+0x4e>
        *dst = '\0';
    800017f8:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb908>
        got_null = 1;
    800017fc:	4785                	li	a5,1
  if (got_null) {
    800017fe:	0017c793          	xori	a5,a5,1
    80001802:	40f0053b          	negw	a0,a5
}
    80001806:	60e6                	ld	ra,88(sp)
    80001808:	6446                	ld	s0,80(sp)
    8000180a:	64a6                	ld	s1,72(sp)
    8000180c:	6906                	ld	s2,64(sp)
    8000180e:	79e2                	ld	s3,56(sp)
    80001810:	7a42                	ld	s4,48(sp)
    80001812:	7aa2                	ld	s5,40(sp)
    80001814:	7b02                	ld	s6,32(sp)
    80001816:	6be2                	ld	s7,24(sp)
    80001818:	6c42                	ld	s8,16(sp)
    8000181a:	6ca2                	ld	s9,8(sp)
    8000181c:	6125                	addi	sp,sp,96
    8000181e:	8082                	ret
    80001820:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80001824:	974e                	add	a4,a4,s3
      --max;
    80001826:	40b70a33          	sub	s4,a4,a1
    srcva = va0 + PGSIZE;
    8000182a:	015904b3          	add	s1,s2,s5
  while (got_null == 0 && max > 0) {
    8000182e:	04e58463          	beq	a1,a4,80001876 <copyinstr+0xbe>
{
    80001832:	89be                	mv	s3,a5
    va0 = PGROUNDDOWN(srcva);
    80001834:	0174f933          	and	s2,s1,s7
    pa0 = walkaddr(pagetable, va0);
    80001838:	85ca                	mv	a1,s2
    8000183a:	855a                	mv	a0,s6
    8000183c:	d8bff0ef          	jal	800015c6 <walkaddr>
    if (pa0 == 0) {
    80001840:	d15d                	beqz	a0,800017e6 <copyinstr+0x2e>
    n = PGSIZE - (srcva - va0);
    80001842:	40990633          	sub	a2,s2,s1
    80001846:	9656                	add	a2,a2,s5
    if (n > max)
    80001848:	00ca7363          	bgeu	s4,a2,8000184e <copyinstr+0x96>
    8000184c:	8652                	mv	a2,s4
    while (n > 0) {
    8000184e:	c615                	beqz	a2,8000187a <copyinstr+0xc2>
    char *p = (char *)(pa0 + (srcva - va0));
    80001850:	412484b3          	sub	s1,s1,s2
    80001854:	94aa                	add	s1,s1,a0
    80001856:	87ce                	mv	a5,s3
      if (*p == '\0') {
    80001858:	413484b3          	sub	s1,s1,s3
    while (n > 0) {
    8000185c:	964e                	add	a2,a2,s3
    8000185e:	85be                	mv	a1,a5
      if (*p == '\0') {
    80001860:	00f48733          	add	a4,s1,a5
    80001864:	00074683          	lbu	a3,0(a4) # fffffffffffff000 <end+0xffffffff7ffdb908>
    80001868:	dac1                	beqz	a3,800017f8 <copyinstr+0x40>
        *dst = *p;
    8000186a:	00d78023          	sb	a3,0(a5)
      dst++;
    8000186e:	0785                	addi	a5,a5,1
    while (n > 0) {
    80001870:	fec797e3          	bne	a5,a2,8000185e <copyinstr+0xa6>
    80001874:	b775                	j	80001820 <copyinstr+0x68>
    80001876:	4781                	li	a5,0
    80001878:	b759                	j	800017fe <copyinstr+0x46>
    srcva = va0 + PGSIZE;
    8000187a:	6485                	lui	s1,0x1
    8000187c:	94ca                	add	s1,s1,s2
    8000187e:	87ce                	mv	a5,s3
    80001880:	bf4d                	j	80001832 <copyinstr+0x7a>
  int got_null = 0;
    80001882:	4781                	li	a5,0
  if (got_null) {
    80001884:	0017c793          	xori	a5,a5,1
    80001888:	40f0053b          	negw	a0,a5
}
    8000188c:	8082                	ret

000000008000188e <count_pagetable_pages>:

// Count physical pages allocated for a process page table
uint64
count_pagetable_pages(pagetable_t pagetable)
{
    8000188e:	1141                	addi	sp,sp,-16
    80001890:	e406                	sd	ra,8(sp)
    80001892:	e022                	sd	s0,0(sp)
    80001894:	0800                	addi	s0,sp,16
    80001896:	862a                	mv	a2,a0
  uint64 count = 1; // Root level 2 table
  for (int i = 0; i < 512; i++) {
    80001898:	6585                	lui	a1,0x1
    8000189a:	95aa                	add	a1,a1,a0
  uint64 count = 1; // Root level 2 table
    8000189c:	4505                	li	a0,1
    8000189e:	6805                	lui	a6,0x1
    800018a0:	a021                	j	800018a8 <count_pagetable_pages+0x1a>
  for (int i = 0; i < 512; i++) {
    800018a2:	0621                	addi	a2,a2,8 # 1008 <_entry-0x7fffeff8>
    800018a4:	02b60263          	beq	a2,a1,800018c8 <count_pagetable_pages+0x3a>
    pte_t pte = pagetable[i];
    800018a8:	621c                	ld	a5,0(a2)
    if (pte & PTE_V) {
    800018aa:	0017f713          	andi	a4,a5,1
    800018ae:	db75                	beqz	a4,800018a2 <count_pagetable_pages+0x14>
      count++; // Level 1 page table
    800018b0:	0505                	addi	a0,a0,1
      pagetable_t pt1 = (pagetable_t)PTE2PA(pte);
    800018b2:	83a9                	srli	a5,a5,0xa
    800018b4:	07b2                	slli	a5,a5,0xc
      for (int j = 0; j < 512; j++) {
    800018b6:	010786b3          	add	a3,a5,a6
        pte_t pte1 = pt1[j];
        if (pte1 & PTE_V) {
    800018ba:	6398                	ld	a4,0(a5)
    800018bc:	8b05                	andi	a4,a4,1
    800018be:	953a                	add	a0,a0,a4
      for (int j = 0; j < 512; j++) {
    800018c0:	07a1                	addi	a5,a5,8
    800018c2:	fed79ce3          	bne	a5,a3,800018ba <count_pagetable_pages+0x2c>
    800018c6:	bff1                	j	800018a2 <count_pagetable_pages+0x14>
        }
      }
    }
  }
  return count;
}
    800018c8:	60a2                	ld	ra,8(sp)
    800018ca:	6402                	ld	s0,0(sp)
    800018cc:	0141                	addi	sp,sp,16
    800018ce:	8082                	ret

00000000800018d0 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800018d0:	715d                	addi	sp,sp,-80
    800018d2:	e486                	sd	ra,72(sp)
    800018d4:	e0a2                	sd	s0,64(sp)
    800018d6:	fc26                	sd	s1,56(sp)
    800018d8:	f84a                	sd	s2,48(sp)
    800018da:	f44e                	sd	s3,40(sp)
    800018dc:	f052                	sd	s4,32(sp)
    800018de:	ec56                	sd	s5,24(sp)
    800018e0:	e85a                	sd	s6,16(sp)
    800018e2:	e45e                	sd	s7,8(sp)
    800018e4:	e062                	sd	s8,0(sp)
    800018e6:	0880                	addi	s0,sp,80
    800018e8:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800018ea:	00011497          	auipc	s1,0x11
    800018ee:	02e48493          	addi	s1,s1,46 # 80012918 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800018f2:	8c26                	mv	s8,s1
    800018f4:	000a57b7          	lui	a5,0xa5
    800018f8:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    800018fc:	07b2                	slli	a5,a5,0xc
    800018fe:	fa578793          	addi	a5,a5,-91
    80001902:	4fa50937          	lui	s2,0x4fa50
    80001906:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    8000190a:	1902                	slli	s2,s2,0x20
    8000190c:	993e                	add	s2,s2,a5
    8000190e:	040009b7          	lui	s3,0x4000
    80001912:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001914:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001916:	4b99                	li	s7,6
    80001918:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    8000191a:	00017a97          	auipc	s5,0x17
    8000191e:	9fea8a93          	addi	s5,s5,-1538 # 80018318 <tickslock>
    char *pa = kalloc();
    80001922:	a56ff0ef          	jal	80000b78 <kalloc>
    80001926:	862a                	mv	a2,a0
    if (pa == 0)
    80001928:	c121                	beqz	a0,80001968 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    8000192a:	418485b3          	sub	a1,s1,s8
    8000192e:	858d                	srai	a1,a1,0x3
    80001930:	032585b3          	mul	a1,a1,s2
    80001934:	05b6                	slli	a1,a1,0xd
    80001936:	6789                	lui	a5,0x2
    80001938:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000193a:	875e                	mv	a4,s7
    8000193c:	86da                	mv	a3,s6
    8000193e:	40b985b3          	sub	a1,s3,a1
    80001942:	8552                	mv	a0,s4
    80001944:	807ff0ef          	jal	8000114a <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001948:	16848493          	addi	s1,s1,360
    8000194c:	fd549be3          	bne	s1,s5,80001922 <proc_mapstacks+0x52>
  }
}
    80001950:	60a6                	ld	ra,72(sp)
    80001952:	6406                	ld	s0,64(sp)
    80001954:	74e2                	ld	s1,56(sp)
    80001956:	7942                	ld	s2,48(sp)
    80001958:	79a2                	ld	s3,40(sp)
    8000195a:	7a02                	ld	s4,32(sp)
    8000195c:	6ae2                	ld	s5,24(sp)
    8000195e:	6b42                	ld	s6,16(sp)
    80001960:	6ba2                	ld	s7,8(sp)
    80001962:	6c02                	ld	s8,0(sp)
    80001964:	6161                	addi	sp,sp,80
    80001966:	8082                	ret
      panic("kalloc");
    80001968:	00005517          	auipc	a0,0x5
    8000196c:	7f050513          	addi	a0,a0,2032 # 80007158 <etext+0x158>
    80001970:	ec5fe0ef          	jal	80000834 <panic>

0000000080001974 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001974:	7139                	addi	sp,sp,-64
    80001976:	fc06                	sd	ra,56(sp)
    80001978:	f822                	sd	s0,48(sp)
    8000197a:	f426                	sd	s1,40(sp)
    8000197c:	f04a                	sd	s2,32(sp)
    8000197e:	ec4e                	sd	s3,24(sp)
    80001980:	e852                	sd	s4,16(sp)
    80001982:	e456                	sd	s5,8(sp)
    80001984:	e05a                	sd	s6,0(sp)
    80001986:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001988:	00005597          	auipc	a1,0x5
    8000198c:	7d858593          	addi	a1,a1,2008 # 80007160 <etext+0x160>
    80001990:	00011517          	auipc	a0,0x11
    80001994:	b5850513          	addi	a0,a0,-1192 # 800124e8 <pid_lock>
    80001998:	a8cff0ef          	jal	80000c24 <initlock>
  initlock(&wait_lock, "wait_lock");
    8000199c:	00005597          	auipc	a1,0x5
    800019a0:	7cc58593          	addi	a1,a1,1996 # 80007168 <etext+0x168>
    800019a4:	00011517          	auipc	a0,0x11
    800019a8:	b5c50513          	addi	a0,a0,-1188 # 80012500 <wait_lock>
    800019ac:	a78ff0ef          	jal	80000c24 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    800019b0:	00011497          	auipc	s1,0x11
    800019b4:	f6848493          	addi	s1,s1,-152 # 80012918 <proc>
    initlock(&p->lock, "proc");
    800019b8:	00005b17          	auipc	s6,0x5
    800019bc:	7c0b0b13          	addi	s6,s6,1984 # 80007178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    800019c0:	8aa6                	mv	s5,s1
    800019c2:	000a57b7          	lui	a5,0xa5
    800019c6:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    800019ca:	07b2                	slli	a5,a5,0xc
    800019cc:	fa578793          	addi	a5,a5,-91
    800019d0:	4fa50937          	lui	s2,0x4fa50
    800019d4:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    800019d8:	1902                	slli	s2,s2,0x20
    800019da:	993e                	add	s2,s2,a5
    800019dc:	040009b7          	lui	s3,0x4000
    800019e0:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800019e2:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    800019e4:	00017a17          	auipc	s4,0x17
    800019e8:	934a0a13          	addi	s4,s4,-1740 # 80018318 <tickslock>
    initlock(&p->lock, "proc");
    800019ec:	85da                	mv	a1,s6
    800019ee:	8526                	mv	a0,s1
    800019f0:	a34ff0ef          	jal	80000c24 <initlock>
    p->state = UNUSED;
    800019f4:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    800019f8:	415487b3          	sub	a5,s1,s5
    800019fc:	878d                	srai	a5,a5,0x3
    800019fe:	032787b3          	mul	a5,a5,s2
    80001a02:	07b6                	slli	a5,a5,0xd
    80001a04:	6709                	lui	a4,0x2
    80001a06:	9fb9                	addw	a5,a5,a4
    80001a08:	40f987b3          	sub	a5,s3,a5
    80001a0c:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    80001a0e:	16848493          	addi	s1,s1,360
    80001a12:	fd449de3          	bne	s1,s4,800019ec <procinit+0x78>
  }
}
    80001a16:	70e2                	ld	ra,56(sp)
    80001a18:	7442                	ld	s0,48(sp)
    80001a1a:	74a2                	ld	s1,40(sp)
    80001a1c:	7902                	ld	s2,32(sp)
    80001a1e:	69e2                	ld	s3,24(sp)
    80001a20:	6a42                	ld	s4,16(sp)
    80001a22:	6aa2                	ld	s5,8(sp)
    80001a24:	6b02                	ld	s6,0(sp)
    80001a26:	6121                	addi	sp,sp,64
    80001a28:	8082                	ret

0000000080001a2a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001a2a:	1141                	addi	sp,sp,-16
    80001a2c:	e406                	sd	ra,8(sp)
    80001a2e:	e022                	sd	s0,0(sp)
    80001a30:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    80001a32:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a34:	2501                	sext.w	a0,a0
    80001a36:	60a2                	ld	ra,8(sp)
    80001a38:	6402                	ld	s0,0(sp)
    80001a3a:	0141                	addi	sp,sp,16
    80001a3c:	8082                	ret

0000000080001a3e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001a3e:	1141                	addi	sp,sp,-16
    80001a40:	e406                	sd	ra,8(sp)
    80001a42:	e022                	sd	s0,0(sp)
    80001a44:	0800                	addi	s0,sp,16
    80001a46:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a48:	2781                	sext.w	a5,a5
    80001a4a:	079e                	slli	a5,a5,0x7
  return c;
}
    80001a4c:	00011517          	auipc	a0,0x11
    80001a50:	acc50513          	addi	a0,a0,-1332 # 80012518 <cpus>
    80001a54:	953e                	add	a0,a0,a5
    80001a56:	60a2                	ld	ra,8(sp)
    80001a58:	6402                	ld	s0,0(sp)
    80001a5a:	0141                	addi	sp,sp,16
    80001a5c:	8082                	ret

0000000080001a5e <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001a5e:	1101                	addi	sp,sp,-32
    80001a60:	ec06                	sd	ra,24(sp)
    80001a62:	e822                	sd	s0,16(sp)
    80001a64:	e426                	sd	s1,8(sp)
    80001a66:	1000                	addi	s0,sp,32
  push_off();
    80001a68:	a02ff0ef          	jal	80000c6a <push_off>
    80001a6c:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a6e:	2781                	sext.w	a5,a5
    80001a70:	079e                	slli	a5,a5,0x7
    80001a72:	00011717          	auipc	a4,0x11
    80001a76:	a7670713          	addi	a4,a4,-1418 # 800124e8 <pid_lock>
    80001a7a:	97ba                	add	a5,a5,a4
    80001a7c:	7b9c                	ld	a5,48(a5)
    80001a7e:	84be                	mv	s1,a5
  pop_off();
    80001a80:	a64ff0ef          	jal	80000ce4 <pop_off>
  return p;
}
    80001a84:	8526                	mv	a0,s1
    80001a86:	60e2                	ld	ra,24(sp)
    80001a88:	6442                	ld	s0,16(sp)
    80001a8a:	64a2                	ld	s1,8(sp)
    80001a8c:	6105                	addi	sp,sp,32
    80001a8e:	8082                	ret

0000000080001a90 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a90:	7179                	addi	sp,sp,-48
    80001a92:	f406                	sd	ra,40(sp)
    80001a94:	f022                	sd	s0,32(sp)
    80001a96:	ec26                	sd	s1,24(sp)
    80001a98:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001a9a:	fc5ff0ef          	jal	80001a5e <myproc>
    80001a9e:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001aa0:	a8cff0ef          	jal	80000d2c <release>

  if (first) {
    80001aa4:	00009797          	auipc	a5,0x9
    80001aa8:	8dc7a783          	lw	a5,-1828(a5) # 8000a380 <first.1>
    80001aac:	cf85                	beqz	a5,80001ae4 <forkret+0x54>
    first = 0;
    80001aae:	00009797          	auipc	a5,0x9
    80001ab2:	8c07a923          	sw	zero,-1838(a5) # 8000a380 <first.1>

    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001ab6:	4505                	li	a0,1
    80001ab8:	491010ef          	jal	80003748 <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001abc:	00005797          	auipc	a5,0x5
    80001ac0:	6c478793          	addi	a5,a5,1732 # 80007180 <etext+0x180>
    80001ac4:	fcf43823          	sd	a5,-48(s0)
    80001ac8:	fc043c23          	sd	zero,-40(s0)
    80001acc:	fd040593          	addi	a1,s0,-48
    80001ad0:	853e                	mv	a0,a5
    80001ad2:	72b020ef          	jal	800049fc <kexec>
    80001ad6:	6cbc                	ld	a5,88(s1)
    80001ad8:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001ada:	6cbc                	ld	a5,88(s1)
    80001adc:	7bb8                	ld	a4,112(a5)
    80001ade:	57fd                	li	a5,-1
    80001ae0:	02f70d63          	beq	a4,a5,80001b1a <forkret+0x8a>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001ae4:	2fd000ef          	jal	800025e0 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001ae8:	68a8                	ld	a0,80(s1)
    80001aea:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001aec:	04000737          	lui	a4,0x4000
    80001af0:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001af2:	0732                	slli	a4,a4,0xc
    80001af4:	00004797          	auipc	a5,0x4
    80001af8:	5a878793          	addi	a5,a5,1448 # 8000609c <userret>
    80001afc:	00004697          	auipc	a3,0x4
    80001b00:	50468693          	addi	a3,a3,1284 # 80006000 <_trampoline>
    80001b04:	8f95                	sub	a5,a5,a3
    80001b06:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001b08:	577d                	li	a4,-1
    80001b0a:	177e                	slli	a4,a4,0x3f
    80001b0c:	8d59                	or	a0,a0,a4
    80001b0e:	9782                	jalr	a5
}
    80001b10:	70a2                	ld	ra,40(sp)
    80001b12:	7402                	ld	s0,32(sp)
    80001b14:	64e2                	ld	s1,24(sp)
    80001b16:	6145                	addi	sp,sp,48
    80001b18:	8082                	ret
      panic("exec");
    80001b1a:	00005517          	auipc	a0,0x5
    80001b1e:	66e50513          	addi	a0,a0,1646 # 80007188 <etext+0x188>
    80001b22:	d13fe0ef          	jal	80000834 <panic>

0000000080001b26 <allocpid>:
{
    80001b26:	1101                	addi	sp,sp,-32
    80001b28:	ec06                	sd	ra,24(sp)
    80001b2a:	e822                	sd	s0,16(sp)
    80001b2c:	e426                	sd	s1,8(sp)
    80001b2e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b30:	00011517          	auipc	a0,0x11
    80001b34:	9b850513          	addi	a0,a0,-1608 # 800124e8 <pid_lock>
    80001b38:	96cff0ef          	jal	80000ca4 <acquire>
  pid = nextpid;
    80001b3c:	00009797          	auipc	a5,0x9
    80001b40:	84878793          	addi	a5,a5,-1976 # 8000a384 <nextpid>
    80001b44:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b46:	0014871b          	addiw	a4,s1,1
    80001b4a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b4c:	00011517          	auipc	a0,0x11
    80001b50:	99c50513          	addi	a0,a0,-1636 # 800124e8 <pid_lock>
    80001b54:	9d8ff0ef          	jal	80000d2c <release>
}
    80001b58:	8526                	mv	a0,s1
    80001b5a:	60e2                	ld	ra,24(sp)
    80001b5c:	6442                	ld	s0,16(sp)
    80001b5e:	64a2                	ld	s1,8(sp)
    80001b60:	6105                	addi	sp,sp,32
    80001b62:	8082                	ret

0000000080001b64 <proc_pagetable>:
{
    80001b64:	1101                	addi	sp,sp,-32
    80001b66:	ec06                	sd	ra,24(sp)
    80001b68:	e822                	sd	s0,16(sp)
    80001b6a:	e426                	sd	s1,8(sp)
    80001b6c:	e04a                	sd	s2,0(sp)
    80001b6e:	1000                	addi	s0,sp,32
    80001b70:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b72:	ecaff0ef          	jal	8000123c <uvmcreate>
    80001b76:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001b78:	cd05                	beqz	a0,80001bb0 <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001b7a:	4729                	li	a4,10
    80001b7c:	00004697          	auipc	a3,0x4
    80001b80:	48468693          	addi	a3,a3,1156 # 80006000 <_trampoline>
    80001b84:	6605                	lui	a2,0x1
    80001b86:	040005b7          	lui	a1,0x4000
    80001b8a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b8c:	05b2                	slli	a1,a1,0xc
    80001b8e:	d06ff0ef          	jal	80001094 <mappages>
    80001b92:	02054663          	bltz	a0,80001bbe <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001b96:	4719                	li	a4,6
    80001b98:	05893683          	ld	a3,88(s2)
    80001b9c:	6605                	lui	a2,0x1
    80001b9e:	020005b7          	lui	a1,0x2000
    80001ba2:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ba4:	05b6                	slli	a1,a1,0xd
    80001ba6:	8526                	mv	a0,s1
    80001ba8:	cecff0ef          	jal	80001094 <mappages>
    80001bac:	00054f63          	bltz	a0,80001bca <proc_pagetable+0x66>
}
    80001bb0:	8526                	mv	a0,s1
    80001bb2:	60e2                	ld	ra,24(sp)
    80001bb4:	6442                	ld	s0,16(sp)
    80001bb6:	64a2                	ld	s1,8(sp)
    80001bb8:	6902                	ld	s2,0(sp)
    80001bba:	6105                	addi	sp,sp,32
    80001bbc:	8082                	ret
    uvmfree(pagetable, 0);
    80001bbe:	4581                	li	a1,0
    80001bc0:	8526                	mv	a0,s1
    80001bc2:	875ff0ef          	jal	80001436 <uvmfree>
    return 0;
    80001bc6:	4481                	li	s1,0
    80001bc8:	b7e5                	j	80001bb0 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bca:	4681                	li	a3,0
    80001bcc:	4605                	li	a2,1
    80001bce:	040005b7          	lui	a1,0x4000
    80001bd2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bd4:	05b2                	slli	a1,a1,0xc
    80001bd6:	8526                	mv	a0,s1
    80001bd8:	e8aff0ef          	jal	80001262 <uvmunmap>
    uvmfree(pagetable, 0);
    80001bdc:	4581                	li	a1,0
    80001bde:	8526                	mv	a0,s1
    80001be0:	857ff0ef          	jal	80001436 <uvmfree>
    return 0;
    80001be4:	4481                	li	s1,0
    80001be6:	b7e9                	j	80001bb0 <proc_pagetable+0x4c>

0000000080001be8 <proc_freepagetable>:
{
    80001be8:	1101                	addi	sp,sp,-32
    80001bea:	ec06                	sd	ra,24(sp)
    80001bec:	e822                	sd	s0,16(sp)
    80001bee:	e426                	sd	s1,8(sp)
    80001bf0:	e04a                	sd	s2,0(sp)
    80001bf2:	1000                	addi	s0,sp,32
    80001bf4:	84aa                	mv	s1,a0
    80001bf6:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bf8:	4681                	li	a3,0
    80001bfa:	4605                	li	a2,1
    80001bfc:	040005b7          	lui	a1,0x4000
    80001c00:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c02:	05b2                	slli	a1,a1,0xc
    80001c04:	e5eff0ef          	jal	80001262 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c08:	4681                	li	a3,0
    80001c0a:	4605                	li	a2,1
    80001c0c:	020005b7          	lui	a1,0x2000
    80001c10:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c12:	05b6                	slli	a1,a1,0xd
    80001c14:	8526                	mv	a0,s1
    80001c16:	e4cff0ef          	jal	80001262 <uvmunmap>
  uvmfree(pagetable, sz);
    80001c1a:	85ca                	mv	a1,s2
    80001c1c:	8526                	mv	a0,s1
    80001c1e:	819ff0ef          	jal	80001436 <uvmfree>
}
    80001c22:	60e2                	ld	ra,24(sp)
    80001c24:	6442                	ld	s0,16(sp)
    80001c26:	64a2                	ld	s1,8(sp)
    80001c28:	6902                	ld	s2,0(sp)
    80001c2a:	6105                	addi	sp,sp,32
    80001c2c:	8082                	ret

0000000080001c2e <freeproc>:
{
    80001c2e:	1101                	addi	sp,sp,-32
    80001c30:	ec06                	sd	ra,24(sp)
    80001c32:	e822                	sd	s0,16(sp)
    80001c34:	e426                	sd	s1,8(sp)
    80001c36:	1000                	addi	s0,sp,32
    80001c38:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001c3a:	6d28                	ld	a0,88(a0)
    80001c3c:	c119                	beqz	a0,80001c42 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001c3e:	e29fe0ef          	jal	80000a66 <kfree>
  p->trapframe = 0;
    80001c42:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001c46:	68a8                	ld	a0,80(s1)
    80001c48:	c501                	beqz	a0,80001c50 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001c4a:	64ac                	ld	a1,72(s1)
    80001c4c:	f9dff0ef          	jal	80001be8 <proc_freepagetable>
  p->pagetable = 0;
    80001c50:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c54:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c58:	0204a823          	sw	zero,48(s1)
  p->name[0] = 0;
    80001c5c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c60:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c64:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c68:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c6c:	0004ac23          	sw	zero,24(s1)
}
    80001c70:	60e2                	ld	ra,24(sp)
    80001c72:	6442                	ld	s0,16(sp)
    80001c74:	64a2                	ld	s1,8(sp)
    80001c76:	6105                	addi	sp,sp,32
    80001c78:	8082                	ret

0000000080001c7a <allocproc>:
{
    80001c7a:	1101                	addi	sp,sp,-32
    80001c7c:	ec06                	sd	ra,24(sp)
    80001c7e:	e822                	sd	s0,16(sp)
    80001c80:	e426                	sd	s1,8(sp)
    80001c82:	e04a                	sd	s2,0(sp)
    80001c84:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001c86:	00011497          	auipc	s1,0x11
    80001c8a:	c9248493          	addi	s1,s1,-878 # 80012918 <proc>
    80001c8e:	00016917          	auipc	s2,0x16
    80001c92:	68a90913          	addi	s2,s2,1674 # 80018318 <tickslock>
    acquire(&p->lock);
    80001c96:	8526                	mv	a0,s1
    80001c98:	80cff0ef          	jal	80000ca4 <acquire>
    if (p->state == UNUSED) {
    80001c9c:	4c9c                	lw	a5,24(s1)
    80001c9e:	cb91                	beqz	a5,80001cb2 <allocproc+0x38>
      release(&p->lock);
    80001ca0:	8526                	mv	a0,s1
    80001ca2:	88aff0ef          	jal	80000d2c <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001ca6:	16848493          	addi	s1,s1,360
    80001caa:	ff2496e3          	bne	s1,s2,80001c96 <allocproc+0x1c>
  return 0;
    80001cae:	4481                	li	s1,0
    80001cb0:	a089                	j	80001cf2 <allocproc+0x78>
  p->pid = allocpid();
    80001cb2:	e75ff0ef          	jal	80001b26 <allocpid>
    80001cb6:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001cb8:	4785                	li	a5,1
    80001cba:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001cbc:	ebdfe0ef          	jal	80000b78 <kalloc>
    80001cc0:	892a                	mv	s2,a0
    80001cc2:	eca8                	sd	a0,88(s1)
    80001cc4:	cd15                	beqz	a0,80001d00 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001cc6:	8526                	mv	a0,s1
    80001cc8:	e9dff0ef          	jal	80001b64 <proc_pagetable>
    80001ccc:	892a                	mv	s2,a0
    80001cce:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001cd0:	c121                	beqz	a0,80001d10 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001cd2:	07000613          	li	a2,112
    80001cd6:	4581                	li	a1,0
    80001cd8:	06048513          	addi	a0,s1,96
    80001cdc:	888ff0ef          	jal	80000d64 <memset>
  p->context.ra = (uint64)forkret;
    80001ce0:	00000797          	auipc	a5,0x0
    80001ce4:	db078793          	addi	a5,a5,-592 # 80001a90 <forkret>
    80001ce8:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cea:	60bc                	ld	a5,64(s1)
    80001cec:	6705                	lui	a4,0x1
    80001cee:	97ba                	add	a5,a5,a4
    80001cf0:	f4bc                	sd	a5,104(s1)
}
    80001cf2:	8526                	mv	a0,s1
    80001cf4:	60e2                	ld	ra,24(sp)
    80001cf6:	6442                	ld	s0,16(sp)
    80001cf8:	64a2                	ld	s1,8(sp)
    80001cfa:	6902                	ld	s2,0(sp)
    80001cfc:	6105                	addi	sp,sp,32
    80001cfe:	8082                	ret
    freeproc(p);
    80001d00:	8526                	mv	a0,s1
    80001d02:	f2dff0ef          	jal	80001c2e <freeproc>
    release(&p->lock);
    80001d06:	8526                	mv	a0,s1
    80001d08:	824ff0ef          	jal	80000d2c <release>
    return 0;
    80001d0c:	84ca                	mv	s1,s2
    80001d0e:	b7d5                	j	80001cf2 <allocproc+0x78>
    freeproc(p);
    80001d10:	8526                	mv	a0,s1
    80001d12:	f1dff0ef          	jal	80001c2e <freeproc>
    release(&p->lock);
    80001d16:	8526                	mv	a0,s1
    80001d18:	814ff0ef          	jal	80000d2c <release>
    return 0;
    80001d1c:	84ca                	mv	s1,s2
    80001d1e:	bfd1                	j	80001cf2 <allocproc+0x78>

0000000080001d20 <userinit>:
{
    80001d20:	1101                	addi	sp,sp,-32
    80001d22:	ec06                	sd	ra,24(sp)
    80001d24:	e822                	sd	s0,16(sp)
    80001d26:	e426                	sd	s1,8(sp)
    80001d28:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d2a:	f51ff0ef          	jal	80001c7a <allocproc>
    80001d2e:	84aa                	mv	s1,a0
  initproc = p;
    80001d30:	00008797          	auipc	a5,0x8
    80001d34:	6aa7b023          	sd	a0,1696(a5) # 8000a3d0 <initproc>
  p->cwd = namei("/");
    80001d38:	00005517          	auipc	a0,0x5
    80001d3c:	45850513          	addi	a0,a0,1112 # 80007190 <etext+0x190>
    80001d40:	767010ef          	jal	80003ca6 <namei>
    80001d44:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d48:	478d                	li	a5,3
    80001d4a:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d4c:	8526                	mv	a0,s1
    80001d4e:	fdffe0ef          	jal	80000d2c <release>
}
    80001d52:	60e2                	ld	ra,24(sp)
    80001d54:	6442                	ld	s0,16(sp)
    80001d56:	64a2                	ld	s1,8(sp)
    80001d58:	6105                	addi	sp,sp,32
    80001d5a:	8082                	ret

0000000080001d5c <growproc>:
{
    80001d5c:	1101                	addi	sp,sp,-32
    80001d5e:	ec06                	sd	ra,24(sp)
    80001d60:	e822                	sd	s0,16(sp)
    80001d62:	e426                	sd	s1,8(sp)
    80001d64:	e04a                	sd	s2,0(sp)
    80001d66:	1000                	addi	s0,sp,32
    80001d68:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d6a:	cf5ff0ef          	jal	80001a5e <myproc>
    80001d6e:	892a                	mv	s2,a0
  sz = p->sz;
    80001d70:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001d72:	02905963          	blez	s1,80001da4 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001d76:	00b48633          	add	a2,s1,a1
    80001d7a:	020007b7          	lui	a5,0x2000
    80001d7e:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001d80:	07b6                	slli	a5,a5,0xd
    80001d82:	02c7ea63          	bltu	a5,a2,80001db6 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d86:	4691                	li	a3,4
    80001d88:	6928                	ld	a0,80(a0)
    80001d8a:	da6ff0ef          	jal	80001330 <uvmalloc>
    80001d8e:	85aa                	mv	a1,a0
    80001d90:	c50d                	beqz	a0,80001dba <growproc+0x5e>
  p->sz = sz;
    80001d92:	04b93423          	sd	a1,72(s2)
  return 0;
    80001d96:	4501                	li	a0,0
}
    80001d98:	60e2                	ld	ra,24(sp)
    80001d9a:	6442                	ld	s0,16(sp)
    80001d9c:	64a2                	ld	s1,8(sp)
    80001d9e:	6902                	ld	s2,0(sp)
    80001da0:	6105                	addi	sp,sp,32
    80001da2:	8082                	ret
  } else if (n < 0) {
    80001da4:	fe04d7e3          	bgez	s1,80001d92 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001da8:	00b48633          	add	a2,s1,a1
    80001dac:	6928                	ld	a0,80(a0)
    80001dae:	d3eff0ef          	jal	800012ec <uvmdealloc>
    80001db2:	85aa                	mv	a1,a0
    80001db4:	bff9                	j	80001d92 <growproc+0x36>
      return -1;
    80001db6:	557d                	li	a0,-1
    80001db8:	b7c5                	j	80001d98 <growproc+0x3c>
      return -1;
    80001dba:	557d                	li	a0,-1
    80001dbc:	bff1                	j	80001d98 <growproc+0x3c>

0000000080001dbe <kfork>:
{
    80001dbe:	7139                	addi	sp,sp,-64
    80001dc0:	fc06                	sd	ra,56(sp)
    80001dc2:	f822                	sd	s0,48(sp)
    80001dc4:	f426                	sd	s1,40(sp)
    80001dc6:	e456                	sd	s5,8(sp)
    80001dc8:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001dca:	c95ff0ef          	jal	80001a5e <myproc>
    80001dce:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001dd0:	eabff0ef          	jal	80001c7a <allocproc>
    80001dd4:	0e050a63          	beqz	a0,80001ec8 <kfork+0x10a>
    80001dd8:	e852                	sd	s4,16(sp)
    80001dda:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001ddc:	048ab603          	ld	a2,72(s5)
    80001de0:	692c                	ld	a1,80(a0)
    80001de2:	050ab503          	ld	a0,80(s5)
    80001de6:	e82ff0ef          	jal	80001468 <uvmcopy>
    80001dea:	04054863          	bltz	a0,80001e3a <kfork+0x7c>
    80001dee:	f04a                	sd	s2,32(sp)
    80001df0:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001df2:	048ab783          	ld	a5,72(s5)
    80001df6:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001dfa:	058ab683          	ld	a3,88(s5)
    80001dfe:	87b6                	mv	a5,a3
    80001e00:	058a3703          	ld	a4,88(s4)
    80001e04:	12068693          	addi	a3,a3,288
    80001e08:	6388                	ld	a0,0(a5)
    80001e0a:	678c                	ld	a1,8(a5)
    80001e0c:	6b90                	ld	a2,16(a5)
    80001e0e:	e308                	sd	a0,0(a4)
    80001e10:	e70c                	sd	a1,8(a4)
    80001e12:	eb10                	sd	a2,16(a4)
    80001e14:	6f90                	ld	a2,24(a5)
    80001e16:	ef10                	sd	a2,24(a4)
    80001e18:	02078793          	addi	a5,a5,32
    80001e1c:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001e20:	fed794e3          	bne	a5,a3,80001e08 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001e24:	058a3783          	ld	a5,88(s4)
    80001e28:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001e2c:	0d0a8493          	addi	s1,s5,208
    80001e30:	0d0a0913          	addi	s2,s4,208
    80001e34:	150a8993          	addi	s3,s5,336
    80001e38:	a831                	j	80001e54 <kfork+0x96>
    freeproc(np);
    80001e3a:	8552                	mv	a0,s4
    80001e3c:	df3ff0ef          	jal	80001c2e <freeproc>
    release(&np->lock);
    80001e40:	8552                	mv	a0,s4
    80001e42:	eebfe0ef          	jal	80000d2c <release>
    return -1;
    80001e46:	54fd                	li	s1,-1
    80001e48:	6a42                	ld	s4,16(sp)
    80001e4a:	a885                	j	80001eba <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001e4c:	04a1                	addi	s1,s1,8
    80001e4e:	0921                	addi	s2,s2,8
    80001e50:	01348963          	beq	s1,s3,80001e62 <kfork+0xa4>
    if (p->ofile[i])
    80001e54:	6088                	ld	a0,0(s1)
    80001e56:	d97d                	beqz	a0,80001e4c <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e58:	4a0020ef          	jal	800042f8 <filedup>
    80001e5c:	00a93023          	sd	a0,0(s2)
    80001e60:	b7f5                	j	80001e4c <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001e62:	150ab503          	ld	a0,336(s5)
    80001e66:	570010ef          	jal	800033d6 <idup>
    80001e6a:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e6e:	4641                	li	a2,16
    80001e70:	158a8593          	addi	a1,s5,344
    80001e74:	158a0513          	addi	a0,s4,344
    80001e78:	840ff0ef          	jal	80000eb8 <safestrcpy>
  pid = np->pid;
    80001e7c:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001e80:	8552                	mv	a0,s4
    80001e82:	eabfe0ef          	jal	80000d2c <release>
  acquire(&wait_lock);
    80001e86:	00010517          	auipc	a0,0x10
    80001e8a:	67a50513          	addi	a0,a0,1658 # 80012500 <wait_lock>
    80001e8e:	e17fe0ef          	jal	80000ca4 <acquire>
  np->parent = p;
    80001e92:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e96:	00010517          	auipc	a0,0x10
    80001e9a:	66a50513          	addi	a0,a0,1642 # 80012500 <wait_lock>
    80001e9e:	e8ffe0ef          	jal	80000d2c <release>
  acquire(&np->lock);
    80001ea2:	8552                	mv	a0,s4
    80001ea4:	e01fe0ef          	jal	80000ca4 <acquire>
  np->state = RUNNABLE;
    80001ea8:	478d                	li	a5,3
    80001eaa:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001eae:	8552                	mv	a0,s4
    80001eb0:	e7dfe0ef          	jal	80000d2c <release>
  return pid;
    80001eb4:	7902                	ld	s2,32(sp)
    80001eb6:	69e2                	ld	s3,24(sp)
    80001eb8:	6a42                	ld	s4,16(sp)
}
    80001eba:	8526                	mv	a0,s1
    80001ebc:	70e2                	ld	ra,56(sp)
    80001ebe:	7442                	ld	s0,48(sp)
    80001ec0:	74a2                	ld	s1,40(sp)
    80001ec2:	6aa2                	ld	s5,8(sp)
    80001ec4:	6121                	addi	sp,sp,64
    80001ec6:	8082                	ret
    return -1;
    80001ec8:	54fd                	li	s1,-1
    80001eca:	bfc5                	j	80001eba <kfork+0xfc>

0000000080001ecc <scheduler>:
{
    80001ecc:	711d                	addi	sp,sp,-96
    80001ece:	ec86                	sd	ra,88(sp)
    80001ed0:	e8a2                	sd	s0,80(sp)
    80001ed2:	e4a6                	sd	s1,72(sp)
    80001ed4:	e0ca                	sd	s2,64(sp)
    80001ed6:	fc4e                	sd	s3,56(sp)
    80001ed8:	f852                	sd	s4,48(sp)
    80001eda:	f456                	sd	s5,40(sp)
    80001edc:	f05a                	sd	s6,32(sp)
    80001ede:	ec5e                	sd	s7,24(sp)
    80001ee0:	e862                	sd	s8,16(sp)
    80001ee2:	e466                	sd	s9,8(sp)
    80001ee4:	1080                	addi	s0,sp,96
    80001ee6:	8792                	mv	a5,tp
  int id = r_tp();
    80001ee8:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001eea:	00779a93          	slli	s5,a5,0x7
    80001eee:	00010717          	auipc	a4,0x10
    80001ef2:	5fa70713          	addi	a4,a4,1530 # 800124e8 <pid_lock>
    80001ef6:	9756                	add	a4,a4,s5
    80001ef8:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001efc:	00010717          	auipc	a4,0x10
    80001f00:	62470713          	addi	a4,a4,1572 # 80012520 <cpus+0x8>
    80001f04:	9aba                	add	s5,s5,a4
        p->state = RUNNING;
    80001f06:	4c11                	li	s8,4
        c->proc = p;
    80001f08:	00010b17          	auipc	s6,0x10
    80001f0c:	5e0b0b13          	addi	s6,s6,1504 # 800124e8 <pid_lock>
    80001f10:	079e                	slli	a5,a5,0x7
    80001f12:	00fb0a33          	add	s4,s6,a5
        found = 1;
    80001f16:	4b85                	li	s7,1
    80001f18:	a0a9                	j	80001f62 <scheduler+0x96>
      release(&p->lock);
    80001f1a:	8526                	mv	a0,s1
    80001f1c:	e11fe0ef          	jal	80000d2c <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f20:	16848493          	addi	s1,s1,360
    80001f24:	03248b63          	beq	s1,s2,80001f5a <scheduler+0x8e>
      acquire(&p->lock);
    80001f28:	8526                	mv	a0,s1
    80001f2a:	d7bfe0ef          	jal	80000ca4 <acquire>
      if (p->state == RUNNABLE) {
    80001f2e:	4c9c                	lw	a5,24(s1)
    80001f30:	ff3795e3          	bne	a5,s3,80001f1a <scheduler+0x4e>
        p->state = RUNNING;
    80001f34:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001f38:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f3c:	06048593          	addi	a1,s1,96
    80001f40:	8556                	mv	a0,s5
    80001f42:	5f4000ef          	jal	80002536 <swtch>
    80001f46:	8792                	mv	a5,tp
        mycpu()->intena = 0;
    80001f48:	2781                	sext.w	a5,a5
    80001f4a:	079e                	slli	a5,a5,0x7
    80001f4c:	97da                	add	a5,a5,s6
    80001f4e:	0a07a623          	sw	zero,172(a5)
        c->proc = 0;
    80001f52:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001f56:	8cde                	mv	s9,s7
    80001f58:	b7c9                	j	80001f1a <scheduler+0x4e>
    if (found == 0) {
    80001f5a:	000c9463          	bnez	s9,80001f62 <scheduler+0x96>
      asm volatile("wfi");
    80001f5e:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001f62:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001f66:	10017073          	csrci	sstatus,2
    int found = 0;
    80001f6a:	4c81                	li	s9,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f6c:	00011497          	auipc	s1,0x11
    80001f70:	9ac48493          	addi	s1,s1,-1620 # 80012918 <proc>
      if (p->state == RUNNABLE) {
    80001f74:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f76:	00016917          	auipc	s2,0x16
    80001f7a:	3a290913          	addi	s2,s2,930 # 80018318 <tickslock>
    80001f7e:	b76d                	j	80001f28 <scheduler+0x5c>

0000000080001f80 <sched>:
{
    80001f80:	7179                	addi	sp,sp,-48
    80001f82:	f406                	sd	ra,40(sp)
    80001f84:	f022                	sd	s0,32(sp)
    80001f86:	ec26                	sd	s1,24(sp)
    80001f88:	e84a                	sd	s2,16(sp)
    80001f8a:	e44e                	sd	s3,8(sp)
    80001f8c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f8e:	ad1ff0ef          	jal	80001a5e <myproc>
    80001f92:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001f94:	cabfe0ef          	jal	80000c3e <holding>
    80001f98:	c935                	beqz	a0,8000200c <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80001f9a:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001f9c:	2781                	sext.w	a5,a5
    80001f9e:	079e                	slli	a5,a5,0x7
    80001fa0:	00010717          	auipc	a4,0x10
    80001fa4:	54870713          	addi	a4,a4,1352 # 800124e8 <pid_lock>
    80001fa8:	97ba                	add	a5,a5,a4
    80001faa:	0a87a703          	lw	a4,168(a5)
    80001fae:	4785                	li	a5,1
    80001fb0:	06f71463          	bne	a4,a5,80002018 <sched+0x98>
  if (p->state == RUNNING)
    80001fb4:	4c98                	lw	a4,24(s1)
    80001fb6:	4791                	li	a5,4
    80001fb8:	06f70663          	beq	a4,a5,80002024 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001fbc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001fc0:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001fc2:	e7bd                	bnez	a5,80002030 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    80001fc4:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001fc6:	00010917          	auipc	s2,0x10
    80001fca:	52290913          	addi	s2,s2,1314 # 800124e8 <pid_lock>
    80001fce:	2781                	sext.w	a5,a5
    80001fd0:	079e                	slli	a5,a5,0x7
    80001fd2:	97ca                	add	a5,a5,s2
    80001fd4:	0ac7a983          	lw	s3,172(a5)
    80001fd8:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fda:	2781                	sext.w	a5,a5
    80001fdc:	079e                	slli	a5,a5,0x7
    80001fde:	07a1                	addi	a5,a5,8
    80001fe0:	00010597          	auipc	a1,0x10
    80001fe4:	53858593          	addi	a1,a1,1336 # 80012518 <cpus>
    80001fe8:	95be                	add	a1,a1,a5
    80001fea:	06048513          	addi	a0,s1,96
    80001fee:	548000ef          	jal	80002536 <swtch>
    80001ff2:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001ff4:	2781                	sext.w	a5,a5
    80001ff6:	079e                	slli	a5,a5,0x7
    80001ff8:	993e                	add	s2,s2,a5
    80001ffa:	0b392623          	sw	s3,172(s2)
}
    80001ffe:	70a2                	ld	ra,40(sp)
    80002000:	7402                	ld	s0,32(sp)
    80002002:	64e2                	ld	s1,24(sp)
    80002004:	6942                	ld	s2,16(sp)
    80002006:	69a2                	ld	s3,8(sp)
    80002008:	6145                	addi	sp,sp,48
    8000200a:	8082                	ret
    panic("sched p->lock");
    8000200c:	00005517          	auipc	a0,0x5
    80002010:	18c50513          	addi	a0,a0,396 # 80007198 <etext+0x198>
    80002014:	821fe0ef          	jal	80000834 <panic>
    panic("sched locks");
    80002018:	00005517          	auipc	a0,0x5
    8000201c:	19050513          	addi	a0,a0,400 # 800071a8 <etext+0x1a8>
    80002020:	815fe0ef          	jal	80000834 <panic>
    panic("sched RUNNING");
    80002024:	00005517          	auipc	a0,0x5
    80002028:	19450513          	addi	a0,a0,404 # 800071b8 <etext+0x1b8>
    8000202c:	809fe0ef          	jal	80000834 <panic>
    panic("sched interruptible");
    80002030:	00005517          	auipc	a0,0x5
    80002034:	19850513          	addi	a0,a0,408 # 800071c8 <etext+0x1c8>
    80002038:	ffcfe0ef          	jal	80000834 <panic>

000000008000203c <yield>:
{
    8000203c:	1101                	addi	sp,sp,-32
    8000203e:	ec06                	sd	ra,24(sp)
    80002040:	e822                	sd	s0,16(sp)
    80002042:	e426                	sd	s1,8(sp)
    80002044:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002046:	a19ff0ef          	jal	80001a5e <myproc>
    8000204a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000204c:	c59fe0ef          	jal	80000ca4 <acquire>
  p->state = RUNNABLE;
    80002050:	478d                	li	a5,3
    80002052:	cc9c                	sw	a5,24(s1)
  sched();
    80002054:	f2dff0ef          	jal	80001f80 <sched>
  release(&p->lock);
    80002058:	8526                	mv	a0,s1
    8000205a:	cd3fe0ef          	jal	80000d2c <release>
}
    8000205e:	60e2                	ld	ra,24(sp)
    80002060:	6442                	ld	s0,16(sp)
    80002062:	64a2                	ld	s1,8(sp)
    80002064:	6105                	addi	sp,sp,32
    80002066:	8082                	ret

0000000080002068 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80002068:	1101                	addi	sp,sp,-32
    8000206a:	ec06                	sd	ra,24(sp)
    8000206c:	e822                	sd	s0,16(sp)
    8000206e:	e426                	sd	s1,8(sp)
    80002070:	e04a                	sd	s2,0(sp)
    80002072:	1000                	addi	s0,sp,32
    80002074:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002076:	9e9ff0ef          	jal	80001a5e <myproc>
    8000207a:	892a                	mv	s2,a0

  acquire(&p->lock);
    8000207c:	c29fe0ef          	jal	80000ca4 <acquire>
  if (chan == 0)
    80002080:	cc81                	beqz	s1,80002098 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80002082:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80002086:	854a                	mv	a0,s2
    80002088:	ca5fe0ef          	jal	80000d2c <release>
}
    8000208c:	60e2                	ld	ra,24(sp)
    8000208e:	6442                	ld	s0,16(sp)
    80002090:	64a2                	ld	s1,8(sp)
    80002092:	6902                	ld	s2,0(sp)
    80002094:	6105                	addi	sp,sp,32
    80002096:	8082                	ret
    panic("sleep_prepare: zero chan");
    80002098:	00005517          	auipc	a0,0x5
    8000209c:	14850513          	addi	a0,a0,328 # 800071e0 <etext+0x1e0>
    800020a0:	f94fe0ef          	jal	80000834 <panic>

00000000800020a4 <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    800020a4:	1101                	addi	sp,sp,-32
    800020a6:	ec06                	sd	ra,24(sp)
    800020a8:	e822                	sd	s0,16(sp)
    800020aa:	e426                	sd	s1,8(sp)
    800020ac:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020ae:	9b1ff0ef          	jal	80001a5e <myproc>
    800020b2:	84aa                	mv	s1,a0

  acquire(&p->lock);
    800020b4:	bf1fe0ef          	jal	80000ca4 <acquire>
  if (p->chan != 0) {
    800020b8:	709c                	ld	a5,32(s1)
    800020ba:	c789                	beqz	a5,800020c4 <sleep+0x20>
    p->state = SLEEPING;
    800020bc:	4789                	li	a5,2
    800020be:	cc9c                	sw	a5,24(s1)
    sched();
    800020c0:	ec1ff0ef          	jal	80001f80 <sched>
  }
  release(&p->lock);
    800020c4:	8526                	mv	a0,s1
    800020c6:	c67fe0ef          	jal	80000d2c <release>
}
    800020ca:	60e2                	ld	ra,24(sp)
    800020cc:	6442                	ld	s0,16(sp)
    800020ce:	64a2                	ld	s1,8(sp)
    800020d0:	6105                	addi	sp,sp,32
    800020d2:	8082                	ret

00000000800020d4 <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    800020d4:	7139                	addi	sp,sp,-64
    800020d6:	fc06                	sd	ra,56(sp)
    800020d8:	f822                	sd	s0,48(sp)
    800020da:	f426                	sd	s1,40(sp)
    800020dc:	f04a                	sd	s2,32(sp)
    800020de:	ec4e                	sd	s3,24(sp)
    800020e0:	e852                	sd	s4,16(sp)
    800020e2:	e456                	sd	s5,8(sp)
    800020e4:	0080                	addi	s0,sp,64
    800020e6:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800020e8:	00011497          	auipc	s1,0x11
    800020ec:	83048493          	addi	s1,s1,-2000 # 80012918 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    800020f0:	4a09                	li	s4,2
        p->state = RUNNABLE;
    800020f2:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    800020f4:	00016997          	auipc	s3,0x16
    800020f8:	22498993          	addi	s3,s3,548 # 80018318 <tickslock>
    800020fc:	a801                	j	8000210c <wakeup+0x38>
      }
    }
    release(&p->lock);
    800020fe:	8526                	mv	a0,s1
    80002100:	c2dfe0ef          	jal	80000d2c <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002104:	16848493          	addi	s1,s1,360
    80002108:	03348063          	beq	s1,s3,80002128 <wakeup+0x54>
    acquire(&p->lock);
    8000210c:	8526                	mv	a0,s1
    8000210e:	b97fe0ef          	jal	80000ca4 <acquire>
    if (p->chan == chan) {
    80002112:	709c                	ld	a5,32(s1)
    80002114:	ff2795e3          	bne	a5,s2,800020fe <wakeup+0x2a>
      p->chan = 0;
    80002118:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    8000211c:	4c9c                	lw	a5,24(s1)
    8000211e:	ff4790e3          	bne	a5,s4,800020fe <wakeup+0x2a>
        p->state = RUNNABLE;
    80002122:	0154ac23          	sw	s5,24(s1)
    80002126:	bfe1                	j	800020fe <wakeup+0x2a>
  }
}
    80002128:	70e2                	ld	ra,56(sp)
    8000212a:	7442                	ld	s0,48(sp)
    8000212c:	74a2                	ld	s1,40(sp)
    8000212e:	7902                	ld	s2,32(sp)
    80002130:	69e2                	ld	s3,24(sp)
    80002132:	6a42                	ld	s4,16(sp)
    80002134:	6aa2                	ld	s5,8(sp)
    80002136:	6121                	addi	sp,sp,64
    80002138:	8082                	ret

000000008000213a <reparent>:
{
    8000213a:	7179                	addi	sp,sp,-48
    8000213c:	f406                	sd	ra,40(sp)
    8000213e:	f022                	sd	s0,32(sp)
    80002140:	ec26                	sd	s1,24(sp)
    80002142:	e84a                	sd	s2,16(sp)
    80002144:	e44e                	sd	s3,8(sp)
    80002146:	e052                	sd	s4,0(sp)
    80002148:	1800                	addi	s0,sp,48
    8000214a:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000214c:	00010497          	auipc	s1,0x10
    80002150:	7cc48493          	addi	s1,s1,1996 # 80012918 <proc>
      pp->parent = initproc;
    80002154:	00008a17          	auipc	s4,0x8
    80002158:	27ca0a13          	addi	s4,s4,636 # 8000a3d0 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000215c:	00016997          	auipc	s3,0x16
    80002160:	1bc98993          	addi	s3,s3,444 # 80018318 <tickslock>
    80002164:	a029                	j	8000216e <reparent+0x34>
    80002166:	16848493          	addi	s1,s1,360
    8000216a:	01348b63          	beq	s1,s3,80002180 <reparent+0x46>
    if (pp->parent == p) {
    8000216e:	7c9c                	ld	a5,56(s1)
    80002170:	ff279be3          	bne	a5,s2,80002166 <reparent+0x2c>
      pp->parent = initproc;
    80002174:	000a3503          	ld	a0,0(s4)
    80002178:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000217a:	f5bff0ef          	jal	800020d4 <wakeup>
    8000217e:	b7e5                	j	80002166 <reparent+0x2c>
}
    80002180:	70a2                	ld	ra,40(sp)
    80002182:	7402                	ld	s0,32(sp)
    80002184:	64e2                	ld	s1,24(sp)
    80002186:	6942                	ld	s2,16(sp)
    80002188:	69a2                	ld	s3,8(sp)
    8000218a:	6a02                	ld	s4,0(sp)
    8000218c:	6145                	addi	sp,sp,48
    8000218e:	8082                	ret

0000000080002190 <kexit>:
{
    80002190:	7179                	addi	sp,sp,-48
    80002192:	f406                	sd	ra,40(sp)
    80002194:	f022                	sd	s0,32(sp)
    80002196:	ec26                	sd	s1,24(sp)
    80002198:	e84a                	sd	s2,16(sp)
    8000219a:	e44e                	sd	s3,8(sp)
    8000219c:	e052                	sd	s4,0(sp)
    8000219e:	1800                	addi	s0,sp,48
    800021a0:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021a2:	8bdff0ef          	jal	80001a5e <myproc>
    800021a6:	89aa                	mv	s3,a0
  if (p == initproc)
    800021a8:	00008797          	auipc	a5,0x8
    800021ac:	2287b783          	ld	a5,552(a5) # 8000a3d0 <initproc>
    800021b0:	0d050493          	addi	s1,a0,208
    800021b4:	15050913          	addi	s2,a0,336
    800021b8:	00a79b63          	bne	a5,a0,800021ce <kexit+0x3e>
    panic("init exiting");
    800021bc:	00005517          	auipc	a0,0x5
    800021c0:	04450513          	addi	a0,a0,68 # 80007200 <etext+0x200>
    800021c4:	e70fe0ef          	jal	80000834 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    800021c8:	04a1                	addi	s1,s1,8
    800021ca:	01248963          	beq	s1,s2,800021dc <kexit+0x4c>
    if (p->ofile[fd]) {
    800021ce:	6088                	ld	a0,0(s1)
    800021d0:	dd65                	beqz	a0,800021c8 <kexit+0x38>
      fileclose(f);
    800021d2:	16c020ef          	jal	8000433e <fileclose>
      p->ofile[fd] = 0;
    800021d6:	0004b023          	sd	zero,0(s1)
    800021da:	b7fd                	j	800021c8 <kexit+0x38>
  begin_op();
    800021dc:	4a9010ef          	jal	80003e84 <begin_op>
  iput(p->cwd);
    800021e0:	1509b503          	ld	a0,336(s3)
    800021e4:	3aa010ef          	jal	8000358e <iput>
  end_op();
    800021e8:	529010ef          	jal	80003f10 <end_op>
  p->cwd = 0;
    800021ec:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800021f0:	00010517          	auipc	a0,0x10
    800021f4:	31050513          	addi	a0,a0,784 # 80012500 <wait_lock>
    800021f8:	aadfe0ef          	jal	80000ca4 <acquire>
  reparent(p);
    800021fc:	854e                	mv	a0,s3
    800021fe:	f3dff0ef          	jal	8000213a <reparent>
  wakeup(p->parent);
    80002202:	0389b503          	ld	a0,56(s3)
    80002206:	ecfff0ef          	jal	800020d4 <wakeup>
  acquire(&p->lock);
    8000220a:	854e                	mv	a0,s3
    8000220c:	a99fe0ef          	jal	80000ca4 <acquire>
  p->xstate = status;
    80002210:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002214:	4795                	li	a5,5
    80002216:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000221a:	00010517          	auipc	a0,0x10
    8000221e:	2e650513          	addi	a0,a0,742 # 80012500 <wait_lock>
    80002222:	b0bfe0ef          	jal	80000d2c <release>
  sched();
    80002226:	d5bff0ef          	jal	80001f80 <sched>
  panic("zombie exit");
    8000222a:	00005517          	auipc	a0,0x5
    8000222e:	fe650513          	addi	a0,a0,-26 # 80007210 <etext+0x210>
    80002232:	e02fe0ef          	jal	80000834 <panic>

0000000080002236 <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    80002236:	c525                	beqz	a0,8000229e <kkill+0x68>
{
    80002238:	7179                	addi	sp,sp,-48
    8000223a:	f406                	sd	ra,40(sp)
    8000223c:	f022                	sd	s0,32(sp)
    8000223e:	ec26                	sd	s1,24(sp)
    80002240:	e84a                	sd	s2,16(sp)
    80002242:	e44e                	sd	s3,8(sp)
    80002244:	1800                	addi	s0,sp,48
    80002246:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002248:	00010497          	auipc	s1,0x10
    8000224c:	6d048493          	addi	s1,s1,1744 # 80012918 <proc>
    80002250:	00016997          	auipc	s3,0x16
    80002254:	0c898993          	addi	s3,s3,200 # 80018318 <tickslock>
    acquire(&p->lock);
    80002258:	8526                	mv	a0,s1
    8000225a:	a4bfe0ef          	jal	80000ca4 <acquire>
    if (p->pid == pid) {
    8000225e:	589c                	lw	a5,48(s1)
    80002260:	01278b63          	beq	a5,s2,80002276 <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002264:	8526                	mv	a0,s1
    80002266:	ac7fe0ef          	jal	80000d2c <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000226a:	16848493          	addi	s1,s1,360
    8000226e:	ff3495e3          	bne	s1,s3,80002258 <kkill+0x22>
  }
  return -1;
    80002272:	557d                	li	a0,-1
    80002274:	a819                	j	8000228a <kkill+0x54>
      p->killed = 1;
    80002276:	4785                	li	a5,1
    80002278:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    8000227a:	4c98                	lw	a4,24(s1)
    8000227c:	4789                	li	a5,2
    8000227e:	00f70d63          	beq	a4,a5,80002298 <kkill+0x62>
      release(&p->lock);
    80002282:	8526                	mv	a0,s1
    80002284:	aa9fe0ef          	jal	80000d2c <release>
      return 0;
    80002288:	4501                	li	a0,0
}
    8000228a:	70a2                	ld	ra,40(sp)
    8000228c:	7402                	ld	s0,32(sp)
    8000228e:	64e2                	ld	s1,24(sp)
    80002290:	6942                	ld	s2,16(sp)
    80002292:	69a2                	ld	s3,8(sp)
    80002294:	6145                	addi	sp,sp,48
    80002296:	8082                	ret
        p->state = RUNNABLE;
    80002298:	478d                	li	a5,3
    8000229a:	cc9c                	sw	a5,24(s1)
    8000229c:	b7dd                	j	80002282 <kkill+0x4c>
    return -1;
    8000229e:	557d                	li	a0,-1
}
    800022a0:	8082                	ret

00000000800022a2 <setkilled>:

void
setkilled(struct proc *p)
{
    800022a2:	1101                	addi	sp,sp,-32
    800022a4:	ec06                	sd	ra,24(sp)
    800022a6:	e822                	sd	s0,16(sp)
    800022a8:	e426                	sd	s1,8(sp)
    800022aa:	1000                	addi	s0,sp,32
    800022ac:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022ae:	9f7fe0ef          	jal	80000ca4 <acquire>
  p->killed = 1;
    800022b2:	4785                	li	a5,1
    800022b4:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022b6:	8526                	mv	a0,s1
    800022b8:	a75fe0ef          	jal	80000d2c <release>
}
    800022bc:	60e2                	ld	ra,24(sp)
    800022be:	6442                	ld	s0,16(sp)
    800022c0:	64a2                	ld	s1,8(sp)
    800022c2:	6105                	addi	sp,sp,32
    800022c4:	8082                	ret

00000000800022c6 <killed>:

int
killed(struct proc *p)
{
    800022c6:	1101                	addi	sp,sp,-32
    800022c8:	ec06                	sd	ra,24(sp)
    800022ca:	e822                	sd	s0,16(sp)
    800022cc:	e426                	sd	s1,8(sp)
    800022ce:	e04a                	sd	s2,0(sp)
    800022d0:	1000                	addi	s0,sp,32
    800022d2:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800022d4:	9d1fe0ef          	jal	80000ca4 <acquire>
  k = p->killed;
    800022d8:	549c                	lw	a5,40(s1)
    800022da:	893e                	mv	s2,a5
  release(&p->lock);
    800022dc:	8526                	mv	a0,s1
    800022de:	a4ffe0ef          	jal	80000d2c <release>
  return k;
}
    800022e2:	854a                	mv	a0,s2
    800022e4:	60e2                	ld	ra,24(sp)
    800022e6:	6442                	ld	s0,16(sp)
    800022e8:	64a2                	ld	s1,8(sp)
    800022ea:	6902                	ld	s2,0(sp)
    800022ec:	6105                	addi	sp,sp,32
    800022ee:	8082                	ret

00000000800022f0 <kwait>:
{
    800022f0:	715d                	addi	sp,sp,-80
    800022f2:	e486                	sd	ra,72(sp)
    800022f4:	e0a2                	sd	s0,64(sp)
    800022f6:	fc26                	sd	s1,56(sp)
    800022f8:	f84a                	sd	s2,48(sp)
    800022fa:	f44e                	sd	s3,40(sp)
    800022fc:	f052                	sd	s4,32(sp)
    800022fe:	ec56                	sd	s5,24(sp)
    80002300:	e85a                	sd	s6,16(sp)
    80002302:	e45e                	sd	s7,8(sp)
    80002304:	0880                	addi	s0,sp,80
    80002306:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002308:	f56ff0ef          	jal	80001a5e <myproc>
    8000230c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000230e:	00010517          	auipc	a0,0x10
    80002312:	1f250513          	addi	a0,a0,498 # 80012500 <wait_lock>
    80002316:	98ffe0ef          	jal	80000ca4 <acquire>
        if (pp->state == ZOMBIE) {
    8000231a:	4a15                	li	s4,5
        havekids = 1;
    8000231c:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000231e:	00016997          	auipc	s3,0x16
    80002322:	ffa98993          	addi	s3,s3,-6 # 80018318 <tickslock>
    release(&wait_lock);
    80002326:	00010b17          	auipc	s6,0x10
    8000232a:	1dab0b13          	addi	s6,s6,474 # 80012500 <wait_lock>
    8000232e:	a845                	j	800023de <kwait+0xee>
          pid = pp->pid;
    80002330:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    80002334:	000b8e63          	beqz	s7,80002350 <kwait+0x60>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    80002338:	4711                	li	a4,4
    8000233a:	02c48693          	addi	a3,s1,44
    8000233e:	865e                	mv	a2,s7
    80002340:	04893583          	ld	a1,72(s2)
    80002344:	05093503          	ld	a0,80(s2)
    80002348:	b0eff0ef          	jal	80001656 <copyout>
          if (addr != 0 &&
    8000234c:	02054c63          	bltz	a0,80002384 <kwait+0x94>
          pp->parent = 0;
    80002350:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    80002354:	8526                	mv	a0,s1
    80002356:	8d9ff0ef          	jal	80001c2e <freeproc>
          release(&pp->lock);
    8000235a:	8526                	mv	a0,s1
    8000235c:	9d1fe0ef          	jal	80000d2c <release>
          release(&wait_lock);
    80002360:	00010517          	auipc	a0,0x10
    80002364:	1a050513          	addi	a0,a0,416 # 80012500 <wait_lock>
    80002368:	9c5fe0ef          	jal	80000d2c <release>
}
    8000236c:	854e                	mv	a0,s3
    8000236e:	60a6                	ld	ra,72(sp)
    80002370:	6406                	ld	s0,64(sp)
    80002372:	74e2                	ld	s1,56(sp)
    80002374:	7942                	ld	s2,48(sp)
    80002376:	79a2                	ld	s3,40(sp)
    80002378:	7a02                	ld	s4,32(sp)
    8000237a:	6ae2                	ld	s5,24(sp)
    8000237c:	6b42                	ld	s6,16(sp)
    8000237e:	6ba2                	ld	s7,8(sp)
    80002380:	6161                	addi	sp,sp,80
    80002382:	8082                	ret
            release(&pp->lock);
    80002384:	8526                	mv	a0,s1
    80002386:	9a7fe0ef          	jal	80000d2c <release>
            release(&wait_lock);
    8000238a:	00010517          	auipc	a0,0x10
    8000238e:	17650513          	addi	a0,a0,374 # 80012500 <wait_lock>
    80002392:	99bfe0ef          	jal	80000d2c <release>
            return -1;
    80002396:	59fd                	li	s3,-1
    80002398:	bfd1                	j	8000236c <kwait+0x7c>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000239a:	16848493          	addi	s1,s1,360
    8000239e:	03348063          	beq	s1,s3,800023be <kwait+0xce>
      if (pp->parent == p) {
    800023a2:	7c9c                	ld	a5,56(s1)
    800023a4:	ff279be3          	bne	a5,s2,8000239a <kwait+0xaa>
        acquire(&pp->lock);
    800023a8:	8526                	mv	a0,s1
    800023aa:	8fbfe0ef          	jal	80000ca4 <acquire>
        if (pp->state == ZOMBIE) {
    800023ae:	4c9c                	lw	a5,24(s1)
    800023b0:	f94780e3          	beq	a5,s4,80002330 <kwait+0x40>
        release(&pp->lock);
    800023b4:	8526                	mv	a0,s1
    800023b6:	977fe0ef          	jal	80000d2c <release>
        havekids = 1;
    800023ba:	8756                	mv	a4,s5
    800023bc:	bff9                	j	8000239a <kwait+0xaa>
    if (!havekids || killed(p)) {
    800023be:	c715                	beqz	a4,800023ea <kwait+0xfa>
    800023c0:	854a                	mv	a0,s2
    800023c2:	f05ff0ef          	jal	800022c6 <killed>
    800023c6:	e115                	bnez	a0,800023ea <kwait+0xfa>
    sleep_prepare(p); //DOC: wait-sleep
    800023c8:	854a                	mv	a0,s2
    800023ca:	c9fff0ef          	jal	80002068 <sleep_prepare>
    release(&wait_lock);
    800023ce:	855a                	mv	a0,s6
    800023d0:	95dfe0ef          	jal	80000d2c <release>
    sleep();
    800023d4:	cd1ff0ef          	jal	800020a4 <sleep>
    acquire(&wait_lock);
    800023d8:	855a                	mv	a0,s6
    800023da:	8cbfe0ef          	jal	80000ca4 <acquire>
    havekids = 0;
    800023de:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800023e0:	00010497          	auipc	s1,0x10
    800023e4:	53848493          	addi	s1,s1,1336 # 80012918 <proc>
    800023e8:	bf6d                	j	800023a2 <kwait+0xb2>
      release(&wait_lock);
    800023ea:	00010517          	auipc	a0,0x10
    800023ee:	11650513          	addi	a0,a0,278 # 80012500 <wait_lock>
    800023f2:	93bfe0ef          	jal	80000d2c <release>
      return -1;
    800023f6:	59fd                	li	s3,-1
    800023f8:	bf95                	j	8000236c <kwait+0x7c>

00000000800023fa <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800023fa:	7179                	addi	sp,sp,-48
    800023fc:	f406                	sd	ra,40(sp)
    800023fe:	f022                	sd	s0,32(sp)
    80002400:	ec26                	sd	s1,24(sp)
    80002402:	e84a                	sd	s2,16(sp)
    80002404:	e44e                	sd	s3,8(sp)
    80002406:	e052                	sd	s4,0(sp)
    80002408:	1800                	addi	s0,sp,48
    8000240a:	84aa                	mv	s1,a0
    8000240c:	8a2e                	mv	s4,a1
    8000240e:	89b2                	mv	s3,a2
    80002410:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002412:	e4cff0ef          	jal	80001a5e <myproc>
  if (user_dst) {
    80002416:	c085                	beqz	s1,80002436 <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    80002418:	874a                	mv	a4,s2
    8000241a:	86ce                	mv	a3,s3
    8000241c:	8652                	mv	a2,s4
    8000241e:	652c                	ld	a1,72(a0)
    80002420:	6928                	ld	a0,80(a0)
    80002422:	a34ff0ef          	jal	80001656 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002426:	70a2                	ld	ra,40(sp)
    80002428:	7402                	ld	s0,32(sp)
    8000242a:	64e2                	ld	s1,24(sp)
    8000242c:	6942                	ld	s2,16(sp)
    8000242e:	69a2                	ld	s3,8(sp)
    80002430:	6a02                	ld	s4,0(sp)
    80002432:	6145                	addi	sp,sp,48
    80002434:	8082                	ret
    memmove((char *)dst, src, len);
    80002436:	0009061b          	sext.w	a2,s2
    8000243a:	85ce                	mv	a1,s3
    8000243c:	8552                	mv	a0,s4
    8000243e:	987fe0ef          	jal	80000dc4 <memmove>
    return 0;
    80002442:	8526                	mv	a0,s1
    80002444:	b7cd                	j	80002426 <either_copyout+0x2c>

0000000080002446 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002446:	7179                	addi	sp,sp,-48
    80002448:	f406                	sd	ra,40(sp)
    8000244a:	f022                	sd	s0,32(sp)
    8000244c:	ec26                	sd	s1,24(sp)
    8000244e:	e84a                	sd	s2,16(sp)
    80002450:	e44e                	sd	s3,8(sp)
    80002452:	e052                	sd	s4,0(sp)
    80002454:	1800                	addi	s0,sp,48
    80002456:	8a2a                	mv	s4,a0
    80002458:	84ae                	mv	s1,a1
    8000245a:	89b2                	mv	s3,a2
    8000245c:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000245e:	e00ff0ef          	jal	80001a5e <myproc>
  if (user_src) {
    80002462:	c085                	beqz	s1,80002482 <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    80002464:	874a                	mv	a4,s2
    80002466:	86ce                	mv	a3,s3
    80002468:	8652                	mv	a2,s4
    8000246a:	652c                	ld	a1,72(a0)
    8000246c:	6928                	ld	a0,80(a0)
    8000246e:	aaeff0ef          	jal	8000171c <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002472:	70a2                	ld	ra,40(sp)
    80002474:	7402                	ld	s0,32(sp)
    80002476:	64e2                	ld	s1,24(sp)
    80002478:	6942                	ld	s2,16(sp)
    8000247a:	69a2                	ld	s3,8(sp)
    8000247c:	6a02                	ld	s4,0(sp)
    8000247e:	6145                	addi	sp,sp,48
    80002480:	8082                	ret
    memmove(dst, (char *)src, len);
    80002482:	0009061b          	sext.w	a2,s2
    80002486:	85ce                	mv	a1,s3
    80002488:	8552                	mv	a0,s4
    8000248a:	93bfe0ef          	jal	80000dc4 <memmove>
    return 0;
    8000248e:	8526                	mv	a0,s1
    80002490:	b7cd                	j	80002472 <either_copyin+0x2c>

0000000080002492 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002492:	715d                	addi	sp,sp,-80
    80002494:	e486                	sd	ra,72(sp)
    80002496:	e0a2                	sd	s0,64(sp)
    80002498:	fc26                	sd	s1,56(sp)
    8000249a:	f84a                	sd	s2,48(sp)
    8000249c:	f44e                	sd	s3,40(sp)
    8000249e:	f052                	sd	s4,32(sp)
    800024a0:	ec56                	sd	s5,24(sp)
    800024a2:	e85a                	sd	s6,16(sp)
    800024a4:	e45e                	sd	s7,8(sp)
    800024a6:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    800024a8:	00005517          	auipc	a0,0x5
    800024ac:	bd050513          	addi	a0,a0,-1072 # 80007078 <etext+0x78>
    800024b0:	85afe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800024b4:	00010497          	auipc	s1,0x10
    800024b8:	5bc48493          	addi	s1,s1,1468 # 80012a70 <proc+0x158>
    800024bc:	00016917          	auipc	s2,0x16
    800024c0:	fb490913          	addi	s2,s2,-76 # 80018470 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024c4:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800024c6:	00005997          	auipc	s3,0x5
    800024ca:	d5a98993          	addi	s3,s3,-678 # 80007220 <etext+0x220>
    printk("%d %s %s", p->pid, state, p->name);
    800024ce:	00005a97          	auipc	s5,0x5
    800024d2:	d5aa8a93          	addi	s5,s5,-678 # 80007228 <etext+0x228>
    printk("\n");
    800024d6:	00005a17          	auipc	s4,0x5
    800024da:	ba2a0a13          	addi	s4,s4,-1118 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024de:	00005b97          	auipc	s7,0x5
    800024e2:	2b2b8b93          	addi	s7,s7,690 # 80007790 <states.0>
    800024e6:	a829                	j	80002500 <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    800024e8:	ed86a583          	lw	a1,-296(a3)
    800024ec:	8556                	mv	a0,s5
    800024ee:	81cfe0ef          	jal	8000050a <printk>
    printk("\n");
    800024f2:	8552                	mv	a0,s4
    800024f4:	816fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800024f8:	16848493          	addi	s1,s1,360
    800024fc:	03248263          	beq	s1,s2,80002520 <procdump+0x8e>
    if (p->state == UNUSED)
    80002500:	86a6                	mv	a3,s1
    80002502:	ec04a783          	lw	a5,-320(s1)
    80002506:	dbed                	beqz	a5,800024f8 <procdump+0x66>
      state = "???";
    80002508:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000250a:	fcfb6fe3          	bltu	s6,a5,800024e8 <procdump+0x56>
    8000250e:	02079713          	slli	a4,a5,0x20
    80002512:	01d75793          	srli	a5,a4,0x1d
    80002516:	97de                	add	a5,a5,s7
    80002518:	6390                	ld	a2,0(a5)
    8000251a:	f679                	bnez	a2,800024e8 <procdump+0x56>
      state = "???";
    8000251c:	864e                	mv	a2,s3
    8000251e:	b7e9                	j	800024e8 <procdump+0x56>
  }
}
    80002520:	60a6                	ld	ra,72(sp)
    80002522:	6406                	ld	s0,64(sp)
    80002524:	74e2                	ld	s1,56(sp)
    80002526:	7942                	ld	s2,48(sp)
    80002528:	79a2                	ld	s3,40(sp)
    8000252a:	7a02                	ld	s4,32(sp)
    8000252c:	6ae2                	ld	s5,24(sp)
    8000252e:	6b42                	ld	s6,16(sp)
    80002530:	6ba2                	ld	s7,8(sp)
    80002532:	6161                	addi	sp,sp,80
    80002534:	8082                	ret

0000000080002536 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002536:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    8000253a:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000253e:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002540:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002542:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002546:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    8000254a:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    8000254e:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002552:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002556:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    8000255a:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000255e:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002562:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002566:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    8000256a:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000256e:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002572:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002574:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002576:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    8000257a:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000257e:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002582:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002586:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    8000258a:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000258e:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002592:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002596:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    8000259a:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000259e:	8082                	ret

00000000800025a0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800025a0:	1141                	addi	sp,sp,-16
    800025a2:	e406                	sd	ra,8(sp)
    800025a4:	e022                	sd	s0,0(sp)
    800025a6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800025a8:	00005597          	auipc	a1,0x5
    800025ac:	cc058593          	addi	a1,a1,-832 # 80007268 <etext+0x268>
    800025b0:	00016517          	auipc	a0,0x16
    800025b4:	d6850513          	addi	a0,a0,-664 # 80018318 <tickslock>
    800025b8:	e6cfe0ef          	jal	80000c24 <initlock>
}
    800025bc:	60a2                	ld	ra,8(sp)
    800025be:	6402                	ld	s0,0(sp)
    800025c0:	0141                	addi	sp,sp,16
    800025c2:	8082                	ret

00000000800025c4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800025c4:	1141                	addi	sp,sp,-16
    800025c6:	e406                	sd	ra,8(sp)
    800025c8:	e022                	sd	s0,0(sp)
    800025ca:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    800025cc:	00003797          	auipc	a5,0x3
    800025d0:	20478793          	addi	a5,a5,516 # 800057d0 <kernelvec>
    800025d4:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800025d8:	60a2                	ld	ra,8(sp)
    800025da:	6402                	ld	s0,0(sp)
    800025dc:	0141                	addi	sp,sp,16
    800025de:	8082                	ret

00000000800025e0 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800025e0:	1141                	addi	sp,sp,-16
    800025e2:	e406                	sd	ra,8(sp)
    800025e4:	e022                	sd	s0,0(sp)
    800025e6:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800025e8:	c76ff0ef          	jal	80001a5e <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    800025ec:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800025f0:	04000737          	lui	a4,0x4000
    800025f4:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800025f6:	0732                	slli	a4,a4,0xc
    800025f8:	00004797          	auipc	a5,0x4
    800025fc:	a0878793          	addi	a5,a5,-1528 # 80006000 <_trampoline>
    80002600:	00004697          	auipc	a3,0x4
    80002604:	a0068693          	addi	a3,a3,-1536 # 80006000 <_trampoline>
    80002608:	8f95                	sub	a5,a5,a3
    8000260a:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    8000260c:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002610:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    80002612:	18002773          	csrr	a4,satp
    80002616:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002618:	6d38                	ld	a4,88(a0)
    8000261a:	613c                	ld	a5,64(a0)
    8000261c:	6685                	lui	a3,0x1
    8000261e:	97b6                	add	a5,a5,a3
    80002620:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002622:	6d3c                	ld	a5,88(a0)
    80002624:	00000717          	auipc	a4,0x0
    80002628:	0fc70713          	addi	a4,a4,252 # 80002720 <usertrap>
    8000262c:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    8000262e:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    80002630:	8712                	mv	a4,tp
    80002632:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002634:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002638:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000263c:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002640:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002644:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002646:	6f9c                	ld	a5,24(a5)
    80002648:	14179073          	csrw	sepc,a5
}
    8000264c:	60a2                	ld	ra,8(sp)
    8000264e:	6402                	ld	s0,0(sp)
    80002650:	0141                	addi	sp,sp,16
    80002652:	8082                	ret

0000000080002654 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002654:	1141                	addi	sp,sp,-16
    80002656:	e406                	sd	ra,8(sp)
    80002658:	e022                	sd	s0,0(sp)
    8000265a:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    8000265c:	bceff0ef          	jal	80001a2a <cpuid>
    80002660:	cd11                	beqz	a0,8000267c <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    80002662:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002666:	000f4737          	lui	a4,0xf4
    8000266a:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000266e:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    80002670:	14d79073          	csrw	stimecmp,a5
}
    80002674:	60a2                	ld	ra,8(sp)
    80002676:	6402                	ld	s0,0(sp)
    80002678:	0141                	addi	sp,sp,16
    8000267a:	8082                	ret
    acquire(&tickslock);
    8000267c:	00016517          	auipc	a0,0x16
    80002680:	c9c50513          	addi	a0,a0,-868 # 80018318 <tickslock>
    80002684:	e20fe0ef          	jal	80000ca4 <acquire>
    ticks++;
    80002688:	00008717          	auipc	a4,0x8
    8000268c:	d5070713          	addi	a4,a4,-688 # 8000a3d8 <ticks>
    80002690:	431c                	lw	a5,0(a4)
    80002692:	2785                	addiw	a5,a5,1
    80002694:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002696:	853a                	mv	a0,a4
    80002698:	a3dff0ef          	jal	800020d4 <wakeup>
    release(&tickslock);
    8000269c:	00016517          	auipc	a0,0x16
    800026a0:	c7c50513          	addi	a0,a0,-900 # 80018318 <tickslock>
    800026a4:	e88fe0ef          	jal	80000d2c <release>
    800026a8:	bf6d                	j	80002662 <clockintr+0xe>

00000000800026aa <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800026aa:	1101                	addi	sp,sp,-32
    800026ac:	ec06                	sd	ra,24(sp)
    800026ae:	e822                	sd	s0,16(sp)
    800026b0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    800026b2:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    800026b6:	57fd                	li	a5,-1
    800026b8:	17fe                	slli	a5,a5,0x3f
    800026ba:	07a5                	addi	a5,a5,9
    800026bc:	00f70c63          	beq	a4,a5,800026d4 <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    800026c0:	57fd                	li	a5,-1
    800026c2:	17fe                	slli	a5,a5,0x3f
    800026c4:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800026c6:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    800026c8:	04f70863          	beq	a4,a5,80002718 <devintr+0x6e>
  }
}
    800026cc:	60e2                	ld	ra,24(sp)
    800026ce:	6442                	ld	s0,16(sp)
    800026d0:	6105                	addi	sp,sp,32
    800026d2:	8082                	ret
    800026d4:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800026d6:	1a8030ef          	jal	8000587e <plic_claim>
    800026da:	872a                	mv	a4,a0
    800026dc:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    800026de:	47a9                	li	a5,10
    800026e0:	00f50963          	beq	a0,a5,800026f2 <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    800026e4:	4785                	li	a5,1
    800026e6:	00f50963          	beq	a0,a5,800026f8 <devintr+0x4e>
    return 1;
    800026ea:	4505                	li	a0,1
    } else if (irq) {
    800026ec:	eb09                	bnez	a4,800026fe <devintr+0x54>
    800026ee:	64a2                	ld	s1,8(sp)
    800026f0:	bff1                	j	800026cc <devintr+0x22>
      uartintr();
    800026f2:	afcfe0ef          	jal	800009ee <uartintr>
    if (irq)
    800026f6:	a819                	j	8000270c <devintr+0x62>
      virtio_disk_intr();
    800026f8:	642030ef          	jal	80005d3a <virtio_disk_intr>
    if (irq)
    800026fc:	a801                	j	8000270c <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    800026fe:	85ba                	mv	a1,a4
    80002700:	00005517          	auipc	a0,0x5
    80002704:	b7050513          	addi	a0,a0,-1168 # 80007270 <etext+0x270>
    80002708:	e03fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    8000270c:	8526                	mv	a0,s1
    8000270e:	192030ef          	jal	800058a0 <plic_complete>
    return 1;
    80002712:	4505                	li	a0,1
    80002714:	64a2                	ld	s1,8(sp)
    80002716:	bf5d                	j	800026cc <devintr+0x22>
    clockintr();
    80002718:	f3dff0ef          	jal	80002654 <clockintr>
    return 2;
    8000271c:	4509                	li	a0,2
    8000271e:	b77d                	j	800026cc <devintr+0x22>

0000000080002720 <usertrap>:
{
    80002720:	1101                	addi	sp,sp,-32
    80002722:	ec06                	sd	ra,24(sp)
    80002724:	e822                	sd	s0,16(sp)
    80002726:	e426                	sd	s1,8(sp)
    80002728:	e04a                	sd	s2,0(sp)
    8000272a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000272c:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002730:	1007f793          	andi	a5,a5,256
    80002734:	e3d1                	bnez	a5,800027b8 <usertrap+0x98>
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002736:	00003797          	auipc	a5,0x3
    8000273a:	09a78793          	addi	a5,a5,154 # 800057d0 <kernelvec>
    8000273e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002742:	b1cff0ef          	jal	80001a5e <myproc>
    80002746:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002748:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    8000274a:	14102773          	csrr	a4,sepc
    8000274e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    80002750:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    80002754:	47a1                	li	a5,8
    80002756:	06f70763          	beq	a4,a5,800027c4 <usertrap+0xa4>
  } else if ((which_dev = devintr()) != 0) {
    8000275a:	f51ff0ef          	jal	800026aa <devintr>
    8000275e:	892a                	mv	s2,a0
    80002760:	0e051463          	bnez	a0,80002848 <usertrap+0x128>
    80002764:	14202773          	csrr	a4,scause
  } else if (r_scause() == 15 || r_scause() == 13 || r_scause() == 12) {
    80002768:	47bd                	li	a5,15
    8000276a:	00f70c63          	beq	a4,a5,80002782 <usertrap+0x62>
    8000276e:	14202773          	csrr	a4,scause
    80002772:	47b5                	li	a5,13
    80002774:	00f70763          	beq	a4,a5,80002782 <usertrap+0x62>
    80002778:	14202773          	csrr	a4,scause
    8000277c:	47b1                	li	a5,12
    8000277e:	08f71e63          	bne	a4,a5,8000281a <usertrap+0xfa>
  asm volatile("csrr %0, stval" : "=r"(x));
    80002782:	143026f3          	csrr	a3,stval
    80002786:	8936                	mv	s2,a3
    if (va < p->sz && va >= PGROUNDDOWN(p->trapframe->sp) &&
    80002788:	64ac                	ld	a1,72(s1)
    8000278a:	00b6f863          	bgeu	a3,a1,8000279a <usertrap+0x7a>
    8000278e:	6cbc                	ld	a5,88(s1)
    80002790:	7b9c                	ld	a5,48(a5)
    80002792:	777d                	lui	a4,0xfffff
    80002794:	8ff9                	and	a5,a5,a4
    80002796:	06f6f763          	bgeu	a3,a5,80002804 <usertrap+0xe4>
      printk("usertrap(): page fault at invalid va 0x%lx (sz 0x%lx, sp 0x%lx) pid=%d\n",
    8000279a:	6cbc                	ld	a5,88(s1)
    8000279c:	5898                	lw	a4,48(s1)
    8000279e:	7b94                	ld	a3,48(a5)
    800027a0:	64b0                	ld	a2,72(s1)
    800027a2:	85ca                	mv	a1,s2
    800027a4:	00005517          	auipc	a0,0x5
    800027a8:	b0c50513          	addi	a0,a0,-1268 # 800072b0 <etext+0x2b0>
    800027ac:	d5ffd0ef          	jal	8000050a <printk>
      setkilled(p);
    800027b0:	8526                	mv	a0,s1
    800027b2:	af1ff0ef          	jal	800022a2 <setkilled>
    800027b6:	a015                	j	800027da <usertrap+0xba>
    panic("usertrap: not from user mode");
    800027b8:	00005517          	auipc	a0,0x5
    800027bc:	ad850513          	addi	a0,a0,-1320 # 80007290 <etext+0x290>
    800027c0:	874fe0ef          	jal	80000834 <panic>
    if (killed(p))
    800027c4:	b03ff0ef          	jal	800022c6 <killed>
    800027c8:	e915                	bnez	a0,800027fc <usertrap+0xdc>
    p->trapframe->epc += 4;
    800027ca:	6cb8                	ld	a4,88(s1)
    800027cc:	6f1c                	ld	a5,24(a4)
    800027ce:	0791                	addi	a5,a5,4
    800027d0:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    800027d2:	10016073          	csrsi	sstatus,2
    syscall();
    800027d6:	26e000ef          	jal	80002a44 <syscall>
  if (killed(p))
    800027da:	8526                	mv	a0,s1
    800027dc:	aebff0ef          	jal	800022c6 <killed>
    800027e0:	e92d                	bnez	a0,80002852 <usertrap+0x132>
  prepare_return();
    800027e2:	dffff0ef          	jal	800025e0 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800027e6:	68a8                	ld	a0,80(s1)
    800027e8:	8131                	srli	a0,a0,0xc
    800027ea:	57fd                	li	a5,-1
    800027ec:	17fe                	slli	a5,a5,0x3f
    800027ee:	8d5d                	or	a0,a0,a5
}
    800027f0:	60e2                	ld	ra,24(sp)
    800027f2:	6442                	ld	s0,16(sp)
    800027f4:	64a2                	ld	s1,8(sp)
    800027f6:	6902                	ld	s2,0(sp)
    800027f8:	6105                	addi	sp,sp,32
    800027fa:	8082                	ret
      kexit(-1);
    800027fc:	557d                	li	a0,-1
    800027fe:	993ff0ef          	jal	80002190 <kexit>
    80002802:	b7e1                	j	800027ca <usertrap+0xaa>
  asm volatile("csrr %0, scause" : "=r"(x));
    80002804:	142026f3          	csrr	a3,scause
        vmfault(p->pagetable, p->sz, va, (r_scause() == 13) ? 1 : 0) != 0) {
    80002808:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    8000280a:	0016b693          	seqz	a3,a3
    8000280e:	864a                	mv	a2,s2
    80002810:	68a8                	ld	a0,80(s1)
    80002812:	d37fe0ef          	jal	80001548 <vmfault>
    if (va < p->sz && va >= PGROUNDDOWN(p->trapframe->sp) &&
    80002816:	f171                	bnez	a0,800027da <usertrap+0xba>
    80002818:	b749                	j	8000279a <usertrap+0x7a>
    8000281a:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000281e:	5890                	lw	a2,48(s1)
    80002820:	00005517          	auipc	a0,0x5
    80002824:	ad850513          	addi	a0,a0,-1320 # 800072f8 <etext+0x2f8>
    80002828:	ce3fd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    8000282c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002830:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002834:	00005517          	auipc	a0,0x5
    80002838:	af450513          	addi	a0,a0,-1292 # 80007328 <etext+0x328>
    8000283c:	ccffd0ef          	jal	8000050a <printk>
    setkilled(p);
    80002840:	8526                	mv	a0,s1
    80002842:	a61ff0ef          	jal	800022a2 <setkilled>
    80002846:	bf51                	j	800027da <usertrap+0xba>
  if (killed(p))
    80002848:	8526                	mv	a0,s1
    8000284a:	a7dff0ef          	jal	800022c6 <killed>
    8000284e:	c511                	beqz	a0,8000285a <usertrap+0x13a>
    80002850:	a011                	j	80002854 <usertrap+0x134>
    80002852:	4901                	li	s2,0
    kexit(-1);
    80002854:	557d                	li	a0,-1
    80002856:	93bff0ef          	jal	80002190 <kexit>
  if (which_dev == 2)
    8000285a:	4789                	li	a5,2
    8000285c:	f8f913e3          	bne	s2,a5,800027e2 <usertrap+0xc2>
    yield();
    80002860:	fdcff0ef          	jal	8000203c <yield>
    80002864:	bfbd                	j	800027e2 <usertrap+0xc2>

0000000080002866 <kerneltrap>:
{
    80002866:	7179                	addi	sp,sp,-48
    80002868:	f406                	sd	ra,40(sp)
    8000286a:	f022                	sd	s0,32(sp)
    8000286c:	ec26                	sd	s1,24(sp)
    8000286e:	e84a                	sd	s2,16(sp)
    80002870:	e44e                	sd	s3,8(sp)
    80002872:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002874:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002878:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    8000287c:	142027f3          	csrr	a5,scause
    80002880:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    80002882:	1004f793          	andi	a5,s1,256
    80002886:	c795                	beqz	a5,800028b2 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002888:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000288c:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    8000288e:	eb85                	bnez	a5,800028be <kerneltrap+0x58>
  if ((which_dev = devintr()) == 0) {
    80002890:	e1bff0ef          	jal	800026aa <devintr>
    80002894:	c91d                	beqz	a0,800028ca <kerneltrap+0x64>
  if (which_dev == 2 && myproc() != 0)
    80002896:	4789                	li	a5,2
    80002898:	04f50a63          	beq	a0,a5,800028ec <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    8000289c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800028a0:	10049073          	csrw	sstatus,s1
}
    800028a4:	70a2                	ld	ra,40(sp)
    800028a6:	7402                	ld	s0,32(sp)
    800028a8:	64e2                	ld	s1,24(sp)
    800028aa:	6942                	ld	s2,16(sp)
    800028ac:	69a2                	ld	s3,8(sp)
    800028ae:	6145                	addi	sp,sp,48
    800028b0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800028b2:	00005517          	auipc	a0,0x5
    800028b6:	a9e50513          	addi	a0,a0,-1378 # 80007350 <etext+0x350>
    800028ba:	f7bfd0ef          	jal	80000834 <panic>
    panic("kerneltrap: interrupts enabled");
    800028be:	00005517          	auipc	a0,0x5
    800028c2:	aba50513          	addi	a0,a0,-1350 # 80007378 <etext+0x378>
    800028c6:	f6ffd0ef          	jal	80000834 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800028ca:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800028ce:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    800028d2:	85ce                	mv	a1,s3
    800028d4:	00005517          	auipc	a0,0x5
    800028d8:	ac450513          	addi	a0,a0,-1340 # 80007398 <etext+0x398>
    800028dc:	c2ffd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    800028e0:	00005517          	auipc	a0,0x5
    800028e4:	ae050513          	addi	a0,a0,-1312 # 800073c0 <etext+0x3c0>
    800028e8:	f4dfd0ef          	jal	80000834 <panic>
  if (which_dev == 2 && myproc() != 0)
    800028ec:	972ff0ef          	jal	80001a5e <myproc>
    800028f0:	d555                	beqz	a0,8000289c <kerneltrap+0x36>
    yield();
    800028f2:	f4aff0ef          	jal	8000203c <yield>
    800028f6:	b75d                	j	8000289c <kerneltrap+0x36>

00000000800028f8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800028f8:	1101                	addi	sp,sp,-32
    800028fa:	ec06                	sd	ra,24(sp)
    800028fc:	e822                	sd	s0,16(sp)
    800028fe:	e426                	sd	s1,8(sp)
    80002900:	1000                	addi	s0,sp,32
    80002902:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002904:	95aff0ef          	jal	80001a5e <myproc>
  switch (n) {
    80002908:	4795                	li	a5,5
    8000290a:	0497e163          	bltu	a5,s1,8000294c <argraw+0x54>
    8000290e:	048a                	slli	s1,s1,0x2
    80002910:	00005717          	auipc	a4,0x5
    80002914:	eb070713          	addi	a4,a4,-336 # 800077c0 <states.0+0x30>
    80002918:	94ba                	add	s1,s1,a4
    8000291a:	409c                	lw	a5,0(s1)
    8000291c:	97ba                	add	a5,a5,a4
    8000291e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002920:	6d3c                	ld	a5,88(a0)
    80002922:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002924:	60e2                	ld	ra,24(sp)
    80002926:	6442                	ld	s0,16(sp)
    80002928:	64a2                	ld	s1,8(sp)
    8000292a:	6105                	addi	sp,sp,32
    8000292c:	8082                	ret
    return p->trapframe->a1;
    8000292e:	6d3c                	ld	a5,88(a0)
    80002930:	7fa8                	ld	a0,120(a5)
    80002932:	bfcd                	j	80002924 <argraw+0x2c>
    return p->trapframe->a2;
    80002934:	6d3c                	ld	a5,88(a0)
    80002936:	63c8                	ld	a0,128(a5)
    80002938:	b7f5                	j	80002924 <argraw+0x2c>
    return p->trapframe->a3;
    8000293a:	6d3c                	ld	a5,88(a0)
    8000293c:	67c8                	ld	a0,136(a5)
    8000293e:	b7dd                	j	80002924 <argraw+0x2c>
    return p->trapframe->a4;
    80002940:	6d3c                	ld	a5,88(a0)
    80002942:	6bc8                	ld	a0,144(a5)
    80002944:	b7c5                	j	80002924 <argraw+0x2c>
    return p->trapframe->a5;
    80002946:	6d3c                	ld	a5,88(a0)
    80002948:	6fc8                	ld	a0,152(a5)
    8000294a:	bfe9                	j	80002924 <argraw+0x2c>
  panic("argraw");
    8000294c:	00005517          	auipc	a0,0x5
    80002950:	a8450513          	addi	a0,a0,-1404 # 800073d0 <etext+0x3d0>
    80002954:	ee1fd0ef          	jal	80000834 <panic>

0000000080002958 <fetchaddr>:
{
    80002958:	1101                	addi	sp,sp,-32
    8000295a:	ec06                	sd	ra,24(sp)
    8000295c:	e822                	sd	s0,16(sp)
    8000295e:	e426                	sd	s1,8(sp)
    80002960:	e04a                	sd	s2,0(sp)
    80002962:	1000                	addi	s0,sp,32
    80002964:	84aa                	mv	s1,a0
    80002966:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002968:	8f6ff0ef          	jal	80001a5e <myproc>
  if (addr >= p->sz ||
    8000296c:	652c                	ld	a1,72(a0)
    8000296e:	02b4f663          	bgeu	s1,a1,8000299a <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002972:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    80002976:	02f5e463          	bltu	a1,a5,8000299e <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    8000297a:	4721                	li	a4,8
    8000297c:	86a6                	mv	a3,s1
    8000297e:	864a                	mv	a2,s2
    80002980:	6928                	ld	a0,80(a0)
    80002982:	d9bfe0ef          	jal	8000171c <copyin>
    80002986:	00a03533          	snez	a0,a0
    8000298a:	40a0053b          	negw	a0,a0
}
    8000298e:	60e2                	ld	ra,24(sp)
    80002990:	6442                	ld	s0,16(sp)
    80002992:	64a2                	ld	s1,8(sp)
    80002994:	6902                	ld	s2,0(sp)
    80002996:	6105                	addi	sp,sp,32
    80002998:	8082                	ret
    return -1;
    8000299a:	557d                	li	a0,-1
    8000299c:	bfcd                	j	8000298e <fetchaddr+0x36>
    8000299e:	557d                	li	a0,-1
    800029a0:	b7fd                	j	8000298e <fetchaddr+0x36>

00000000800029a2 <fetchstr>:
{
    800029a2:	7179                	addi	sp,sp,-48
    800029a4:	f406                	sd	ra,40(sp)
    800029a6:	f022                	sd	s0,32(sp)
    800029a8:	ec26                	sd	s1,24(sp)
    800029aa:	e84a                	sd	s2,16(sp)
    800029ac:	e44e                	sd	s3,8(sp)
    800029ae:	1800                	addi	s0,sp,48
    800029b0:	89aa                	mv	s3,a0
    800029b2:	84ae                	mv	s1,a1
    800029b4:	8932                	mv	s2,a2
  struct proc *p = myproc();
    800029b6:	8a8ff0ef          	jal	80001a5e <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    800029ba:	874a                	mv	a4,s2
    800029bc:	86ce                	mv	a3,s3
    800029be:	8626                	mv	a2,s1
    800029c0:	652c                	ld	a1,72(a0)
    800029c2:	6928                	ld	a0,80(a0)
    800029c4:	df5fe0ef          	jal	800017b8 <copyinstr>
    800029c8:	00054c63          	bltz	a0,800029e0 <fetchstr+0x3e>
  return strlen(buf);
    800029cc:	8526                	mv	a0,s1
    800029ce:	d20fe0ef          	jal	80000eee <strlen>
}
    800029d2:	70a2                	ld	ra,40(sp)
    800029d4:	7402                	ld	s0,32(sp)
    800029d6:	64e2                	ld	s1,24(sp)
    800029d8:	6942                	ld	s2,16(sp)
    800029da:	69a2                	ld	s3,8(sp)
    800029dc:	6145                	addi	sp,sp,48
    800029de:	8082                	ret
    return -1;
    800029e0:	557d                	li	a0,-1
    800029e2:	bfc5                	j	800029d2 <fetchstr+0x30>

00000000800029e4 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800029e4:	1101                	addi	sp,sp,-32
    800029e6:	ec06                	sd	ra,24(sp)
    800029e8:	e822                	sd	s0,16(sp)
    800029ea:	e426                	sd	s1,8(sp)
    800029ec:	1000                	addi	s0,sp,32
    800029ee:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800029f0:	f09ff0ef          	jal	800028f8 <argraw>
    800029f4:	c088                	sw	a0,0(s1)
}
    800029f6:	60e2                	ld	ra,24(sp)
    800029f8:	6442                	ld	s0,16(sp)
    800029fa:	64a2                	ld	s1,8(sp)
    800029fc:	6105                	addi	sp,sp,32
    800029fe:	8082                	ret

0000000080002a00 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002a00:	1101                	addi	sp,sp,-32
    80002a02:	ec06                	sd	ra,24(sp)
    80002a04:	e822                	sd	s0,16(sp)
    80002a06:	e426                	sd	s1,8(sp)
    80002a08:	1000                	addi	s0,sp,32
    80002a0a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a0c:	eedff0ef          	jal	800028f8 <argraw>
    80002a10:	e088                	sd	a0,0(s1)
}
    80002a12:	60e2                	ld	ra,24(sp)
    80002a14:	6442                	ld	s0,16(sp)
    80002a16:	64a2                	ld	s1,8(sp)
    80002a18:	6105                	addi	sp,sp,32
    80002a1a:	8082                	ret

0000000080002a1c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002a1c:	1101                	addi	sp,sp,-32
    80002a1e:	ec06                	sd	ra,24(sp)
    80002a20:	e822                	sd	s0,16(sp)
    80002a22:	e426                	sd	s1,8(sp)
    80002a24:	e04a                	sd	s2,0(sp)
    80002a26:	1000                	addi	s0,sp,32
    80002a28:	892e                	mv	s2,a1
    80002a2a:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002a2c:	ecdff0ef          	jal	800028f8 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002a30:	8626                	mv	a2,s1
    80002a32:	85ca                	mv	a1,s2
    80002a34:	f6fff0ef          	jal	800029a2 <fetchstr>
}
    80002a38:	60e2                	ld	ra,24(sp)
    80002a3a:	6442                	ld	s0,16(sp)
    80002a3c:	64a2                	ld	s1,8(sp)
    80002a3e:	6902                	ld	s2,0(sp)
    80002a40:	6105                	addi	sp,sp,32
    80002a42:	8082                	ret

0000000080002a44 <syscall>:
  // clang-format on
};

void
syscall(void)
{
    80002a44:	1101                	addi	sp,sp,-32
    80002a46:	ec06                	sd	ra,24(sp)
    80002a48:	e822                	sd	s0,16(sp)
    80002a4a:	e426                	sd	s1,8(sp)
    80002a4c:	e04a                	sd	s2,0(sp)
    80002a4e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002a50:	80eff0ef          	jal	80001a5e <myproc>
    80002a54:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002a56:	05853903          	ld	s2,88(a0)
    80002a5a:	0a893783          	ld	a5,168(s2)
    80002a5e:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002a62:	37fd                	addiw	a5,a5,-1
    80002a64:	4759                	li	a4,22
    80002a66:	00f76f63          	bltu	a4,a5,80002a84 <syscall+0x40>
    80002a6a:	00369713          	slli	a4,a3,0x3
    80002a6e:	00005797          	auipc	a5,0x5
    80002a72:	d6a78793          	addi	a5,a5,-662 # 800077d8 <syscalls>
    80002a76:	97ba                	add	a5,a5,a4
    80002a78:	639c                	ld	a5,0(a5)
    80002a7a:	c789                	beqz	a5,80002a84 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002a7c:	9782                	jalr	a5
    80002a7e:	06a93823          	sd	a0,112(s2)
    80002a82:	a829                	j	80002a9c <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    80002a84:	15848613          	addi	a2,s1,344
    80002a88:	588c                	lw	a1,48(s1)
    80002a8a:	00005517          	auipc	a0,0x5
    80002a8e:	94e50513          	addi	a0,a0,-1714 # 800073d8 <etext+0x3d8>
    80002a92:	a79fd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    80002a96:	6cbc                	ld	a5,88(s1)
    80002a98:	577d                	li	a4,-1
    80002a9a:	fbb8                	sd	a4,112(a5)
  }
}
    80002a9c:	60e2                	ld	ra,24(sp)
    80002a9e:	6442                	ld	s0,16(sp)
    80002aa0:	64a2                	ld	s1,8(sp)
    80002aa2:	6902                	ld	s2,0(sp)
    80002aa4:	6105                	addi	sp,sp,32
    80002aa6:	8082                	ret

0000000080002aa8 <sys_exit>:
#include "vm.h"
#include "meminfo.h"

uint64
sys_exit(void)
{
    80002aa8:	1101                	addi	sp,sp,-32
    80002aaa:	ec06                	sd	ra,24(sp)
    80002aac:	e822                	sd	s0,16(sp)
    80002aae:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002ab0:	fec40593          	addi	a1,s0,-20
    80002ab4:	4501                	li	a0,0
    80002ab6:	f2fff0ef          	jal	800029e4 <argint>
  kexit(n);
    80002aba:	fec42503          	lw	a0,-20(s0)
    80002abe:	ed2ff0ef          	jal	80002190 <kexit>
  return 0; // not reached
}
    80002ac2:	4501                	li	a0,0
    80002ac4:	60e2                	ld	ra,24(sp)
    80002ac6:	6442                	ld	s0,16(sp)
    80002ac8:	6105                	addi	sp,sp,32
    80002aca:	8082                	ret

0000000080002acc <sys_getpid>:

uint64
sys_getpid(void)
{
    80002acc:	1141                	addi	sp,sp,-16
    80002ace:	e406                	sd	ra,8(sp)
    80002ad0:	e022                	sd	s0,0(sp)
    80002ad2:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ad4:	f8bfe0ef          	jal	80001a5e <myproc>
}
    80002ad8:	5908                	lw	a0,48(a0)
    80002ada:	60a2                	ld	ra,8(sp)
    80002adc:	6402                	ld	s0,0(sp)
    80002ade:	0141                	addi	sp,sp,16
    80002ae0:	8082                	ret

0000000080002ae2 <sys_fork>:

uint64
sys_fork(void)
{
    80002ae2:	1141                	addi	sp,sp,-16
    80002ae4:	e406                	sd	ra,8(sp)
    80002ae6:	e022                	sd	s0,0(sp)
    80002ae8:	0800                	addi	s0,sp,16
  return kfork();
    80002aea:	ad4ff0ef          	jal	80001dbe <kfork>
}
    80002aee:	60a2                	ld	ra,8(sp)
    80002af0:	6402                	ld	s0,0(sp)
    80002af2:	0141                	addi	sp,sp,16
    80002af4:	8082                	ret

0000000080002af6 <sys_wait>:

uint64
sys_wait(void)
{
    80002af6:	1101                	addi	sp,sp,-32
    80002af8:	ec06                	sd	ra,24(sp)
    80002afa:	e822                	sd	s0,16(sp)
    80002afc:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002afe:	fe840593          	addi	a1,s0,-24
    80002b02:	4501                	li	a0,0
    80002b04:	efdff0ef          	jal	80002a00 <argaddr>
  return kwait(p);
    80002b08:	fe843503          	ld	a0,-24(s0)
    80002b0c:	fe4ff0ef          	jal	800022f0 <kwait>
}
    80002b10:	60e2                	ld	ra,24(sp)
    80002b12:	6442                	ld	s0,16(sp)
    80002b14:	6105                	addi	sp,sp,32
    80002b16:	8082                	ret

0000000080002b18 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002b18:	7179                	addi	sp,sp,-48
    80002b1a:	f406                	sd	ra,40(sp)
    80002b1c:	f022                	sd	s0,32(sp)
    80002b1e:	ec26                	sd	s1,24(sp)
    80002b20:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002b22:	fdc40593          	addi	a1,s0,-36
    80002b26:	4501                	li	a0,0
    80002b28:	ebdff0ef          	jal	800029e4 <argint>
  addr = myproc()->sz;
    80002b2c:	f33fe0ef          	jal	80001a5e <myproc>
    80002b30:	6524                	ld	s1,72(a0)

  if (n < 0) {
    80002b32:	fdc42503          	lw	a0,-36(s0)
    80002b36:	02054a63          	bltz	a0,80002b6a <sys_sbrk+0x52>
    if (growproc(n) < 0) {
      return -1;
    }
  } else if (n > 0) {
    80002b3a:	02a05263          	blez	a0,80002b5e <sys_sbrk+0x46>
    // Lazily allocate memory: increase process sz without allocating physical frames.
    // When the process touches the page, page fault handler (vmfault) allocates it.
    if (addr + n < addr)
    80002b3e:	9526                	add	a0,a0,s1
      return -1;
    if (addr + n > TRAPFRAME)
    80002b40:	020007b7          	lui	a5,0x2000
    80002b44:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80002b46:	07b6                	slli	a5,a5,0xd
    80002b48:	02a7e763          	bltu	a5,a0,80002b76 <sys_sbrk+0x5e>
    80002b4c:	02956563          	bltu	a0,s1,80002b76 <sys_sbrk+0x5e>
      return -1;
    myproc()->sz += n;
    80002b50:	f0ffe0ef          	jal	80001a5e <myproc>
    80002b54:	fdc42703          	lw	a4,-36(s0)
    80002b58:	653c                	ld	a5,72(a0)
    80002b5a:	97ba                	add	a5,a5,a4
    80002b5c:	e53c                	sd	a5,72(a0)
  }
  return addr;
}
    80002b5e:	8526                	mv	a0,s1
    80002b60:	70a2                	ld	ra,40(sp)
    80002b62:	7402                	ld	s0,32(sp)
    80002b64:	64e2                	ld	s1,24(sp)
    80002b66:	6145                	addi	sp,sp,48
    80002b68:	8082                	ret
    if (growproc(n) < 0) {
    80002b6a:	9f2ff0ef          	jal	80001d5c <growproc>
    80002b6e:	fe0558e3          	bgez	a0,80002b5e <sys_sbrk+0x46>
      return -1;
    80002b72:	54fd                	li	s1,-1
    80002b74:	b7ed                	j	80002b5e <sys_sbrk+0x46>
      return -1;
    80002b76:	54fd                	li	s1,-1
    80002b78:	b7dd                	j	80002b5e <sys_sbrk+0x46>

0000000080002b7a <sys_pause>:

uint64
sys_pause(void)
{
    80002b7a:	7139                	addi	sp,sp,-64
    80002b7c:	fc06                	sd	ra,56(sp)
    80002b7e:	f822                	sd	s0,48(sp)
    80002b80:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002b82:	fcc40593          	addi	a1,s0,-52
    80002b86:	4501                	li	a0,0
    80002b88:	e5dff0ef          	jal	800029e4 <argint>
  if (n < 0)
    80002b8c:	fcc42783          	lw	a5,-52(s0)
    80002b90:	0807c063          	bltz	a5,80002c10 <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002b94:	00015517          	auipc	a0,0x15
    80002b98:	78450513          	addi	a0,a0,1924 # 80018318 <tickslock>
    80002b9c:	908fe0ef          	jal	80000ca4 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002ba0:	fcc42783          	lw	a5,-52(s0)
    80002ba4:	cbb9                	beqz	a5,80002bfa <sys_pause+0x80>
    80002ba6:	f426                	sd	s1,40(sp)
    80002ba8:	f04a                	sd	s2,32(sp)
    80002baa:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002bac:	00008997          	auipc	s3,0x8
    80002bb0:	82c9a983          	lw	s3,-2004(s3) # 8000a3d8 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002bb4:	00008917          	auipc	s2,0x8
    80002bb8:	82490913          	addi	s2,s2,-2012 # 8000a3d8 <ticks>
    release(&tickslock);
    80002bbc:	00015497          	auipc	s1,0x15
    80002bc0:	75c48493          	addi	s1,s1,1884 # 80018318 <tickslock>
    if (killed(myproc())) {
    80002bc4:	e9bfe0ef          	jal	80001a5e <myproc>
    80002bc8:	efeff0ef          	jal	800022c6 <killed>
    80002bcc:	e529                	bnez	a0,80002c16 <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002bce:	854a                	mv	a0,s2
    80002bd0:	c98ff0ef          	jal	80002068 <sleep_prepare>
    release(&tickslock);
    80002bd4:	8526                	mv	a0,s1
    80002bd6:	956fe0ef          	jal	80000d2c <release>
    sleep();
    80002bda:	ccaff0ef          	jal	800020a4 <sleep>
    acquire(&tickslock);
    80002bde:	8526                	mv	a0,s1
    80002be0:	8c4fe0ef          	jal	80000ca4 <acquire>
  while (ticks - ticks0 < n) {
    80002be4:	00092783          	lw	a5,0(s2)
    80002be8:	413787bb          	subw	a5,a5,s3
    80002bec:	fcc42703          	lw	a4,-52(s0)
    80002bf0:	fce7eae3          	bltu	a5,a4,80002bc4 <sys_pause+0x4a>
    80002bf4:	74a2                	ld	s1,40(sp)
    80002bf6:	7902                	ld	s2,32(sp)
    80002bf8:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002bfa:	00015517          	auipc	a0,0x15
    80002bfe:	71e50513          	addi	a0,a0,1822 # 80018318 <tickslock>
    80002c02:	92afe0ef          	jal	80000d2c <release>
  return 0;
    80002c06:	4501                	li	a0,0
}
    80002c08:	70e2                	ld	ra,56(sp)
    80002c0a:	7442                	ld	s0,48(sp)
    80002c0c:	6121                	addi	sp,sp,64
    80002c0e:	8082                	ret
    n = 0;
    80002c10:	fc042623          	sw	zero,-52(s0)
    80002c14:	b741                	j	80002b94 <sys_pause+0x1a>
      release(&tickslock);
    80002c16:	00015517          	auipc	a0,0x15
    80002c1a:	70250513          	addi	a0,a0,1794 # 80018318 <tickslock>
    80002c1e:	90efe0ef          	jal	80000d2c <release>
      return -1;
    80002c22:	557d                	li	a0,-1
    80002c24:	74a2                	ld	s1,40(sp)
    80002c26:	7902                	ld	s2,32(sp)
    80002c28:	69e2                	ld	s3,24(sp)
    80002c2a:	bff9                	j	80002c08 <sys_pause+0x8e>

0000000080002c2c <sys_kill>:

uint64
sys_kill(void)
{
    80002c2c:	1101                	addi	sp,sp,-32
    80002c2e:	ec06                	sd	ra,24(sp)
    80002c30:	e822                	sd	s0,16(sp)
    80002c32:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002c34:	fec40593          	addi	a1,s0,-20
    80002c38:	4501                	li	a0,0
    80002c3a:	dabff0ef          	jal	800029e4 <argint>
  return kkill(pid);
    80002c3e:	fec42503          	lw	a0,-20(s0)
    80002c42:	df4ff0ef          	jal	80002236 <kkill>
}
    80002c46:	60e2                	ld	ra,24(sp)
    80002c48:	6442                	ld	s0,16(sp)
    80002c4a:	6105                	addi	sp,sp,32
    80002c4c:	8082                	ret

0000000080002c4e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002c4e:	1101                	addi	sp,sp,-32
    80002c50:	ec06                	sd	ra,24(sp)
    80002c52:	e822                	sd	s0,16(sp)
    80002c54:	e426                	sd	s1,8(sp)
    80002c56:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002c58:	00015517          	auipc	a0,0x15
    80002c5c:	6c050513          	addi	a0,a0,1728 # 80018318 <tickslock>
    80002c60:	844fe0ef          	jal	80000ca4 <acquire>
  xticks = ticks;
    80002c64:	00007797          	auipc	a5,0x7
    80002c68:	7747a783          	lw	a5,1908(a5) # 8000a3d8 <ticks>
    80002c6c:	84be                	mv	s1,a5
  release(&tickslock);
    80002c6e:	00015517          	auipc	a0,0x15
    80002c72:	6aa50513          	addi	a0,a0,1706 # 80018318 <tickslock>
    80002c76:	8b6fe0ef          	jal	80000d2c <release>
  return xticks;
}
    80002c7a:	02049513          	slli	a0,s1,0x20
    80002c7e:	9101                	srli	a0,a0,0x20
    80002c80:	60e2                	ld	ra,24(sp)
    80002c82:	6442                	ld	s0,16(sp)
    80002c84:	64a2                	ld	s1,8(sp)
    80002c86:	6105                	addi	sp,sp,32
    80002c88:	8082                	ret

0000000080002c8a <sys_getmeminfo>:

uint64
sys_getmeminfo(void)
{
    80002c8a:	715d                	addi	sp,sp,-80
    80002c8c:	e486                	sd	ra,72(sp)
    80002c8e:	e0a2                	sd	s0,64(sp)
    80002c90:	0880                	addi	s0,sp,80
  uint64 addr;
  argaddr(0, &addr);
    80002c92:	fd840593          	addi	a1,s0,-40
    80002c96:	4501                	li	a0,0
    80002c98:	d69ff0ef          	jal	80002a00 <argaddr>
  if (addr == 0)
    80002c9c:	fd843783          	ld	a5,-40(s0)
    return -1;
    80002ca0:	557d                	li	a0,-1
  if (addr == 0)
    80002ca2:	c3b1                	beqz	a5,80002ce6 <sys_getmeminfo+0x5c>
    80002ca4:	fc26                	sd	s1,56(sp)

  struct proc *p = myproc();
    80002ca6:	db9fe0ef          	jal	80001a5e <myproc>
    80002caa:	84aa                	mv	s1,a0
  struct meminfo mi;
  mi.total_pages = get_total_pages();
    80002cac:	f61fd0ef          	jal	80000c0c <get_total_pages>
    80002cb0:	faa43c23          	sd	a0,-72(s0)
  mi.free_pages = get_free_pages();
    80002cb4:	f21fd0ef          	jal	80000bd4 <get_free_pages>
    80002cb8:	fca43023          	sd	a0,-64(s0)
  mi.user_pages = p->sz / PGSIZE;
    80002cbc:	64bc                	ld	a5,72(s1)
    80002cbe:	83b1                	srli	a5,a5,0xc
    80002cc0:	fcf43423          	sd	a5,-56(s0)
  mi.pagetable_pages = count_pagetable_pages(p->pagetable);
    80002cc4:	68a8                	ld	a0,80(s1)
    80002cc6:	bc9fe0ef          	jal	8000188e <count_pagetable_pages>
    80002cca:	fca43823          	sd	a0,-48(s0)

  if (copyout(p->pagetable, p->sz, addr, (char *)&mi, sizeof(mi)) < 0)
    80002cce:	02000713          	li	a4,32
    80002cd2:	fb840693          	addi	a3,s0,-72
    80002cd6:	fd843603          	ld	a2,-40(s0)
    80002cda:	64ac                	ld	a1,72(s1)
    80002cdc:	68a8                	ld	a0,80(s1)
    80002cde:	979fe0ef          	jal	80001656 <copyout>
    80002ce2:	957d                	srai	a0,a0,0x3f
    80002ce4:	74e2                	ld	s1,56(sp)
    return -1;
  return 0;
}
    80002ce6:	60a6                	ld	ra,72(sp)
    80002ce8:	6406                	ld	s0,64(sp)
    80002cea:	6161                	addi	sp,sp,80
    80002cec:	8082                	ret

0000000080002cee <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002cee:	7179                	addi	sp,sp,-48
    80002cf0:	f406                	sd	ra,40(sp)
    80002cf2:	f022                	sd	s0,32(sp)
    80002cf4:	ec26                	sd	s1,24(sp)
    80002cf6:	e84a                	sd	s2,16(sp)
    80002cf8:	e44e                	sd	s3,8(sp)
    80002cfa:	e052                	sd	s4,0(sp)
    80002cfc:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002cfe:	00004597          	auipc	a1,0x4
    80002d02:	6fa58593          	addi	a1,a1,1786 # 800073f8 <etext+0x3f8>
    80002d06:	00015517          	auipc	a0,0x15
    80002d0a:	62a50513          	addi	a0,a0,1578 # 80018330 <bcache>
    80002d0e:	f17fd0ef          	jal	80000c24 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002d12:	0001d797          	auipc	a5,0x1d
    80002d16:	61e78793          	addi	a5,a5,1566 # 80020330 <bcache+0x8000>
    80002d1a:	0001e717          	auipc	a4,0x1e
    80002d1e:	87e70713          	addi	a4,a4,-1922 # 80020598 <bcache+0x8268>
    80002d22:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002d26:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002d2a:	00015497          	auipc	s1,0x15
    80002d2e:	61e48493          	addi	s1,s1,1566 # 80018348 <bcache+0x18>
    b->next = bcache.head.next;
    80002d32:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002d34:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002d36:	00004a17          	auipc	s4,0x4
    80002d3a:	6caa0a13          	addi	s4,s4,1738 # 80007400 <etext+0x400>
    b->next = bcache.head.next;
    80002d3e:	2b893783          	ld	a5,696(s2)
    80002d42:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002d44:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002d48:	85d2                	mv	a1,s4
    80002d4a:	01048513          	addi	a0,s1,16
    80002d4e:	41c010ef          	jal	8000416a <initsleeplock>
    bcache.head.next->prev = b;
    80002d52:	2b893783          	ld	a5,696(s2)
    80002d56:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002d58:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002d5c:	45848493          	addi	s1,s1,1112
    80002d60:	fd349fe3          	bne	s1,s3,80002d3e <binit+0x50>
  }
}
    80002d64:	70a2                	ld	ra,40(sp)
    80002d66:	7402                	ld	s0,32(sp)
    80002d68:	64e2                	ld	s1,24(sp)
    80002d6a:	6942                	ld	s2,16(sp)
    80002d6c:	69a2                	ld	s3,8(sp)
    80002d6e:	6a02                	ld	s4,0(sp)
    80002d70:	6145                	addi	sp,sp,48
    80002d72:	8082                	ret

0000000080002d74 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002d74:	7179                	addi	sp,sp,-48
    80002d76:	f406                	sd	ra,40(sp)
    80002d78:	f022                	sd	s0,32(sp)
    80002d7a:	ec26                	sd	s1,24(sp)
    80002d7c:	e84a                	sd	s2,16(sp)
    80002d7e:	e44e                	sd	s3,8(sp)
    80002d80:	1800                	addi	s0,sp,48
    80002d82:	892a                	mv	s2,a0
    80002d84:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002d86:	00015517          	auipc	a0,0x15
    80002d8a:	5aa50513          	addi	a0,a0,1450 # 80018330 <bcache>
    80002d8e:	f17fd0ef          	jal	80000ca4 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002d92:	0001e497          	auipc	s1,0x1e
    80002d96:	8564b483          	ld	s1,-1962(s1) # 800205e8 <bcache+0x82b8>
    80002d9a:	0001d797          	auipc	a5,0x1d
    80002d9e:	7fe78793          	addi	a5,a5,2046 # 80020598 <bcache+0x8268>
    80002da2:	02f48b63          	beq	s1,a5,80002dd8 <bread+0x64>
    80002da6:	873e                	mv	a4,a5
    80002da8:	a021                	j	80002db0 <bread+0x3c>
    80002daa:	68a4                	ld	s1,80(s1)
    80002dac:	02e48663          	beq	s1,a4,80002dd8 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002db0:	449c                	lw	a5,8(s1)
    80002db2:	ff279ce3          	bne	a5,s2,80002daa <bread+0x36>
    80002db6:	44dc                	lw	a5,12(s1)
    80002db8:	ff3799e3          	bne	a5,s3,80002daa <bread+0x36>
      b->refcnt++;
    80002dbc:	40bc                	lw	a5,64(s1)
    80002dbe:	2785                	addiw	a5,a5,1
    80002dc0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002dc2:	00015517          	auipc	a0,0x15
    80002dc6:	56e50513          	addi	a0,a0,1390 # 80018330 <bcache>
    80002dca:	f63fd0ef          	jal	80000d2c <release>
      acquiresleep(&b->lock);
    80002dce:	01048513          	addi	a0,s1,16
    80002dd2:	3ce010ef          	jal	800041a0 <acquiresleep>
      return b;
    80002dd6:	a889                	j	80002e28 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002dd8:	0001e497          	auipc	s1,0x1e
    80002ddc:	8084b483          	ld	s1,-2040(s1) # 800205e0 <bcache+0x82b0>
    80002de0:	0001d797          	auipc	a5,0x1d
    80002de4:	7b878793          	addi	a5,a5,1976 # 80020598 <bcache+0x8268>
    80002de8:	00f48863          	beq	s1,a5,80002df8 <bread+0x84>
    80002dec:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002dee:	40bc                	lw	a5,64(s1)
    80002df0:	cb91                	beqz	a5,80002e04 <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002df2:	64a4                	ld	s1,72(s1)
    80002df4:	fee49de3          	bne	s1,a4,80002dee <bread+0x7a>
  panic("bget: no buffers");
    80002df8:	00004517          	auipc	a0,0x4
    80002dfc:	61050513          	addi	a0,a0,1552 # 80007408 <etext+0x408>
    80002e00:	a35fd0ef          	jal	80000834 <panic>
      b->dev = dev;
    80002e04:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002e08:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002e0c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002e10:	4785                	li	a5,1
    80002e12:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e14:	00015517          	auipc	a0,0x15
    80002e18:	51c50513          	addi	a0,a0,1308 # 80018330 <bcache>
    80002e1c:	f11fd0ef          	jal	80000d2c <release>
      acquiresleep(&b->lock);
    80002e20:	01048513          	addi	a0,s1,16
    80002e24:	37c010ef          	jal	800041a0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002e28:	409c                	lw	a5,0(s1)
    80002e2a:	cb89                	beqz	a5,80002e3c <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002e2c:	8526                	mv	a0,s1
    80002e2e:	70a2                	ld	ra,40(sp)
    80002e30:	7402                	ld	s0,32(sp)
    80002e32:	64e2                	ld	s1,24(sp)
    80002e34:	6942                	ld	s2,16(sp)
    80002e36:	69a2                	ld	s3,8(sp)
    80002e38:	6145                	addi	sp,sp,48
    80002e3a:	8082                	ret
    virtio_disk_rw(b, 0);
    80002e3c:	4581                	li	a1,0
    80002e3e:	8526                	mv	a0,s1
    80002e40:	4c7020ef          	jal	80005b06 <virtio_disk_rw>
    b->valid = 1;
    80002e44:	4785                	li	a5,1
    80002e46:	c09c                	sw	a5,0(s1)
  return b;
    80002e48:	b7d5                	j	80002e2c <bread+0xb8>

0000000080002e4a <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002e4a:	1101                	addi	sp,sp,-32
    80002e4c:	ec06                	sd	ra,24(sp)
    80002e4e:	e822                	sd	s0,16(sp)
    80002e50:	e426                	sd	s1,8(sp)
    80002e52:	1000                	addi	s0,sp,32
    80002e54:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002e56:	0541                	addi	a0,a0,16
    80002e58:	3d4010ef          	jal	8000422c <holdingsleep>
    80002e5c:	c911                	beqz	a0,80002e70 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002e5e:	4585                	li	a1,1
    80002e60:	8526                	mv	a0,s1
    80002e62:	4a5020ef          	jal	80005b06 <virtio_disk_rw>
}
    80002e66:	60e2                	ld	ra,24(sp)
    80002e68:	6442                	ld	s0,16(sp)
    80002e6a:	64a2                	ld	s1,8(sp)
    80002e6c:	6105                	addi	sp,sp,32
    80002e6e:	8082                	ret
    panic("bwrite");
    80002e70:	00004517          	auipc	a0,0x4
    80002e74:	5b050513          	addi	a0,a0,1456 # 80007420 <etext+0x420>
    80002e78:	9bdfd0ef          	jal	80000834 <panic>

0000000080002e7c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002e7c:	1101                	addi	sp,sp,-32
    80002e7e:	ec06                	sd	ra,24(sp)
    80002e80:	e822                	sd	s0,16(sp)
    80002e82:	e426                	sd	s1,8(sp)
    80002e84:	e04a                	sd	s2,0(sp)
    80002e86:	1000                	addi	s0,sp,32
    80002e88:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002e8a:	01050913          	addi	s2,a0,16
    80002e8e:	854a                	mv	a0,s2
    80002e90:	39c010ef          	jal	8000422c <holdingsleep>
    80002e94:	c125                	beqz	a0,80002ef4 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002e96:	854a                	mv	a0,s2
    80002e98:	35c010ef          	jal	800041f4 <releasesleep>

  acquire(&bcache.lock);
    80002e9c:	00015517          	auipc	a0,0x15
    80002ea0:	49450513          	addi	a0,a0,1172 # 80018330 <bcache>
    80002ea4:	e01fd0ef          	jal	80000ca4 <acquire>
  b->refcnt--;
    80002ea8:	40bc                	lw	a5,64(s1)
    80002eaa:	37fd                	addiw	a5,a5,-1
    80002eac:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002eae:	e79d                	bnez	a5,80002edc <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002eb0:	68b8                	ld	a4,80(s1)
    80002eb2:	64bc                	ld	a5,72(s1)
    80002eb4:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002eb6:	68b8                	ld	a4,80(s1)
    80002eb8:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002eba:	0001d797          	auipc	a5,0x1d
    80002ebe:	47678793          	addi	a5,a5,1142 # 80020330 <bcache+0x8000>
    80002ec2:	2b87b703          	ld	a4,696(a5)
    80002ec6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002ec8:	0001d717          	auipc	a4,0x1d
    80002ecc:	6d070713          	addi	a4,a4,1744 # 80020598 <bcache+0x8268>
    80002ed0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002ed2:	2b87b703          	ld	a4,696(a5)
    80002ed6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002ed8:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002edc:	00015517          	auipc	a0,0x15
    80002ee0:	45450513          	addi	a0,a0,1108 # 80018330 <bcache>
    80002ee4:	e49fd0ef          	jal	80000d2c <release>
}
    80002ee8:	60e2                	ld	ra,24(sp)
    80002eea:	6442                	ld	s0,16(sp)
    80002eec:	64a2                	ld	s1,8(sp)
    80002eee:	6902                	ld	s2,0(sp)
    80002ef0:	6105                	addi	sp,sp,32
    80002ef2:	8082                	ret
    panic("brelse");
    80002ef4:	00004517          	auipc	a0,0x4
    80002ef8:	53450513          	addi	a0,a0,1332 # 80007428 <etext+0x428>
    80002efc:	939fd0ef          	jal	80000834 <panic>

0000000080002f00 <bpin>:

void
bpin(struct buf *b)
{
    80002f00:	1101                	addi	sp,sp,-32
    80002f02:	ec06                	sd	ra,24(sp)
    80002f04:	e822                	sd	s0,16(sp)
    80002f06:	e426                	sd	s1,8(sp)
    80002f08:	1000                	addi	s0,sp,32
    80002f0a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f0c:	00015517          	auipc	a0,0x15
    80002f10:	42450513          	addi	a0,a0,1060 # 80018330 <bcache>
    80002f14:	d91fd0ef          	jal	80000ca4 <acquire>
  b->refcnt++;
    80002f18:	40bc                	lw	a5,64(s1)
    80002f1a:	2785                	addiw	a5,a5,1
    80002f1c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f1e:	00015517          	auipc	a0,0x15
    80002f22:	41250513          	addi	a0,a0,1042 # 80018330 <bcache>
    80002f26:	e07fd0ef          	jal	80000d2c <release>
}
    80002f2a:	60e2                	ld	ra,24(sp)
    80002f2c:	6442                	ld	s0,16(sp)
    80002f2e:	64a2                	ld	s1,8(sp)
    80002f30:	6105                	addi	sp,sp,32
    80002f32:	8082                	ret

0000000080002f34 <bunpin>:

void
bunpin(struct buf *b)
{
    80002f34:	1101                	addi	sp,sp,-32
    80002f36:	ec06                	sd	ra,24(sp)
    80002f38:	e822                	sd	s0,16(sp)
    80002f3a:	e426                	sd	s1,8(sp)
    80002f3c:	1000                	addi	s0,sp,32
    80002f3e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f40:	00015517          	auipc	a0,0x15
    80002f44:	3f050513          	addi	a0,a0,1008 # 80018330 <bcache>
    80002f48:	d5dfd0ef          	jal	80000ca4 <acquire>
  b->refcnt--;
    80002f4c:	40bc                	lw	a5,64(s1)
    80002f4e:	37fd                	addiw	a5,a5,-1
    80002f50:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f52:	00015517          	auipc	a0,0x15
    80002f56:	3de50513          	addi	a0,a0,990 # 80018330 <bcache>
    80002f5a:	dd3fd0ef          	jal	80000d2c <release>
}
    80002f5e:	60e2                	ld	ra,24(sp)
    80002f60:	6442                	ld	s0,16(sp)
    80002f62:	64a2                	ld	s1,8(sp)
    80002f64:	6105                	addi	sp,sp,32
    80002f66:	8082                	ret

0000000080002f68 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002f68:	1101                	addi	sp,sp,-32
    80002f6a:	ec06                	sd	ra,24(sp)
    80002f6c:	e822                	sd	s0,16(sp)
    80002f6e:	e426                	sd	s1,8(sp)
    80002f70:	e04a                	sd	s2,0(sp)
    80002f72:	1000                	addi	s0,sp,32
    80002f74:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002f76:	00d5d79b          	srliw	a5,a1,0xd
    80002f7a:	0001e597          	auipc	a1,0x1e
    80002f7e:	a925a583          	lw	a1,-1390(a1) # 80020a0c <sb+0x1c>
    80002f82:	9dbd                	addw	a1,a1,a5
    80002f84:	df1ff0ef          	jal	80002d74 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002f88:	0074f713          	andi	a4,s1,7
    80002f8c:	4785                	li	a5,1
    80002f8e:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002f92:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80002f94:	90d9                	srli	s1,s1,0x36
    80002f96:	00950733          	add	a4,a0,s1
    80002f9a:	05874703          	lbu	a4,88(a4)
    80002f9e:	00e7f6b3          	and	a3,a5,a4
    80002fa2:	c29d                	beqz	a3,80002fc8 <bfree+0x60>
    80002fa4:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002fa6:	94aa                	add	s1,s1,a0
    80002fa8:	fff7c793          	not	a5,a5
    80002fac:	8f7d                	and	a4,a4,a5
    80002fae:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002fb2:	080010ef          	jal	80004032 <log_write>
  brelse(bp);
    80002fb6:	854a                	mv	a0,s2
    80002fb8:	ec5ff0ef          	jal	80002e7c <brelse>
}
    80002fbc:	60e2                	ld	ra,24(sp)
    80002fbe:	6442                	ld	s0,16(sp)
    80002fc0:	64a2                	ld	s1,8(sp)
    80002fc2:	6902                	ld	s2,0(sp)
    80002fc4:	6105                	addi	sp,sp,32
    80002fc6:	8082                	ret
    panic("freeing free block");
    80002fc8:	00004517          	auipc	a0,0x4
    80002fcc:	46850513          	addi	a0,a0,1128 # 80007430 <etext+0x430>
    80002fd0:	865fd0ef          	jal	80000834 <panic>

0000000080002fd4 <balloc>:
{
    80002fd4:	715d                	addi	sp,sp,-80
    80002fd6:	e486                	sd	ra,72(sp)
    80002fd8:	e0a2                	sd	s0,64(sp)
    80002fda:	fc26                	sd	s1,56(sp)
    80002fdc:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80002fde:	0001e797          	auipc	a5,0x1e
    80002fe2:	a167a783          	lw	a5,-1514(a5) # 800209f4 <sb+0x4>
    80002fe6:	0e078263          	beqz	a5,800030ca <balloc+0xf6>
    80002fea:	f84a                	sd	s2,48(sp)
    80002fec:	f44e                	sd	s3,40(sp)
    80002fee:	f052                	sd	s4,32(sp)
    80002ff0:	ec56                	sd	s5,24(sp)
    80002ff2:	e85a                	sd	s6,16(sp)
    80002ff4:	e45e                	sd	s7,8(sp)
    80002ff6:	e062                	sd	s8,0(sp)
    80002ff8:	8baa                	mv	s7,a0
    80002ffa:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002ffc:	0001eb17          	auipc	s6,0x1e
    80003000:	9f4b0b13          	addi	s6,s6,-1548 # 800209f0 <sb>
      m = 1 << (bi % 8);
    80003004:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003006:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80003008:	6c09                	lui	s8,0x2
    8000300a:	a09d                	j	80003070 <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    8000300c:	97ca                	add	a5,a5,s2
    8000300e:	8e55                	or	a2,a2,a3
    80003010:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003014:	854a                	mv	a0,s2
    80003016:	01c010ef          	jal	80004032 <log_write>
        brelse(bp);
    8000301a:	854a                	mv	a0,s2
    8000301c:	e61ff0ef          	jal	80002e7c <brelse>
  bp = bread(dev, bno);
    80003020:	85a6                	mv	a1,s1
    80003022:	855e                	mv	a0,s7
    80003024:	d51ff0ef          	jal	80002d74 <bread>
    80003028:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000302a:	40000613          	li	a2,1024
    8000302e:	4581                	li	a1,0
    80003030:	05850513          	addi	a0,a0,88
    80003034:	d31fd0ef          	jal	80000d64 <memset>
  log_write(bp);
    80003038:	854a                	mv	a0,s2
    8000303a:	7f9000ef          	jal	80004032 <log_write>
  brelse(bp);
    8000303e:	854a                	mv	a0,s2
    80003040:	e3dff0ef          	jal	80002e7c <brelse>
}
    80003044:	7942                	ld	s2,48(sp)
    80003046:	79a2                	ld	s3,40(sp)
    80003048:	7a02                	ld	s4,32(sp)
    8000304a:	6ae2                	ld	s5,24(sp)
    8000304c:	6b42                	ld	s6,16(sp)
    8000304e:	6ba2                	ld	s7,8(sp)
    80003050:	6c02                	ld	s8,0(sp)
}
    80003052:	8526                	mv	a0,s1
    80003054:	60a6                	ld	ra,72(sp)
    80003056:	6406                	ld	s0,64(sp)
    80003058:	74e2                	ld	s1,56(sp)
    8000305a:	6161                	addi	sp,sp,80
    8000305c:	8082                	ret
    brelse(bp);
    8000305e:	854a                	mv	a0,s2
    80003060:	e1dff0ef          	jal	80002e7c <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80003064:	015c0abb          	addw	s5,s8,s5
    80003068:	004b2783          	lw	a5,4(s6)
    8000306c:	04faf863          	bgeu	s5,a5,800030bc <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80003070:	40dad59b          	sraiw	a1,s5,0xd
    80003074:	01cb2783          	lw	a5,28(s6)
    80003078:	9dbd                	addw	a1,a1,a5
    8000307a:	855e                	mv	a0,s7
    8000307c:	cf9ff0ef          	jal	80002d74 <bread>
    80003080:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003082:	004b2503          	lw	a0,4(s6)
    80003086:	84d6                	mv	s1,s5
    80003088:	4701                	li	a4,0
    8000308a:	fca4fae3          	bgeu	s1,a0,8000305e <balloc+0x8a>
      m = 1 << (bi % 8);
    8000308e:	00777693          	andi	a3,a4,7
    80003092:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80003096:	41f7579b          	sraiw	a5,a4,0x1f
    8000309a:	01d7d79b          	srliw	a5,a5,0x1d
    8000309e:	9fb9                	addw	a5,a5,a4
    800030a0:	4037d79b          	sraiw	a5,a5,0x3
    800030a4:	00f90633          	add	a2,s2,a5
    800030a8:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    800030ac:	00c6f5b3          	and	a1,a3,a2
    800030b0:	ddb1                	beqz	a1,8000300c <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    800030b2:	2705                	addiw	a4,a4,1
    800030b4:	2485                	addiw	s1,s1,1
    800030b6:	fd471ae3          	bne	a4,s4,8000308a <balloc+0xb6>
    800030ba:	b755                	j	8000305e <balloc+0x8a>
    800030bc:	7942                	ld	s2,48(sp)
    800030be:	79a2                	ld	s3,40(sp)
    800030c0:	7a02                	ld	s4,32(sp)
    800030c2:	6ae2                	ld	s5,24(sp)
    800030c4:	6b42                	ld	s6,16(sp)
    800030c6:	6ba2                	ld	s7,8(sp)
    800030c8:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    800030ca:	00004517          	auipc	a0,0x4
    800030ce:	37e50513          	addi	a0,a0,894 # 80007448 <etext+0x448>
    800030d2:	c38fd0ef          	jal	8000050a <printk>
  return 0;
    800030d6:	4481                	li	s1,0
    800030d8:	bfad                	j	80003052 <balloc+0x7e>

00000000800030da <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800030da:	7179                	addi	sp,sp,-48
    800030dc:	f406                	sd	ra,40(sp)
    800030de:	f022                	sd	s0,32(sp)
    800030e0:	ec26                	sd	s1,24(sp)
    800030e2:	e84a                	sd	s2,16(sp)
    800030e4:	e44e                	sd	s3,8(sp)
    800030e6:	1800                	addi	s0,sp,48
    800030e8:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    800030ea:	47ad                	li	a5,11
    800030ec:	02b7e363          	bltu	a5,a1,80003112 <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    800030f0:	02059793          	slli	a5,a1,0x20
    800030f4:	01e7d593          	srli	a1,a5,0x1e
    800030f8:	00b509b3          	add	s3,a0,a1
    800030fc:	0509a483          	lw	s1,80(s3)
    80003100:	e0b5                	bnez	s1,80003164 <bmap+0x8a>
      addr = balloc(ip->dev);
    80003102:	4108                	lw	a0,0(a0)
    80003104:	ed1ff0ef          	jal	80002fd4 <balloc>
    80003108:	84aa                	mv	s1,a0
      if (addr == 0)
    8000310a:	cd29                	beqz	a0,80003164 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    8000310c:	04a9a823          	sw	a0,80(s3)
    80003110:	a891                	j	80003164 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003112:	ff45879b          	addiw	a5,a1,-12
    80003116:	873e                	mv	a4,a5
    80003118:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    8000311a:	0ff00793          	li	a5,255
    8000311e:	06e7e763          	bltu	a5,a4,8000318c <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    80003122:	08052483          	lw	s1,128(a0)
    80003126:	e891                	bnez	s1,8000313a <bmap+0x60>
      addr = balloc(ip->dev);
    80003128:	4108                	lw	a0,0(a0)
    8000312a:	eabff0ef          	jal	80002fd4 <balloc>
    8000312e:	84aa                	mv	s1,a0
      if (addr == 0)
    80003130:	c915                	beqz	a0,80003164 <bmap+0x8a>
    80003132:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003134:	08a92023          	sw	a0,128(s2)
    80003138:	a011                	j	8000313c <bmap+0x62>
    8000313a:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000313c:	85a6                	mv	a1,s1
    8000313e:	00092503          	lw	a0,0(s2)
    80003142:	c33ff0ef          	jal	80002d74 <bread>
    80003146:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80003148:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    8000314c:	02099713          	slli	a4,s3,0x20
    80003150:	01e75593          	srli	a1,a4,0x1e
    80003154:	97ae                	add	a5,a5,a1
    80003156:	89be                	mv	s3,a5
    80003158:	4384                	lw	s1,0(a5)
    8000315a:	cc89                	beqz	s1,80003174 <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000315c:	8552                	mv	a0,s4
    8000315e:	d1fff0ef          	jal	80002e7c <brelse>
    return addr;
    80003162:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003164:	8526                	mv	a0,s1
    80003166:	70a2                	ld	ra,40(sp)
    80003168:	7402                	ld	s0,32(sp)
    8000316a:	64e2                	ld	s1,24(sp)
    8000316c:	6942                	ld	s2,16(sp)
    8000316e:	69a2                	ld	s3,8(sp)
    80003170:	6145                	addi	sp,sp,48
    80003172:	8082                	ret
      addr = balloc(ip->dev);
    80003174:	00092503          	lw	a0,0(s2)
    80003178:	e5dff0ef          	jal	80002fd4 <balloc>
    8000317c:	84aa                	mv	s1,a0
      if (addr) {
    8000317e:	dd79                	beqz	a0,8000315c <bmap+0x82>
        a[bn] = addr;
    80003180:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80003184:	8552                	mv	a0,s4
    80003186:	6ad000ef          	jal	80004032 <log_write>
    8000318a:	bfc9                	j	8000315c <bmap+0x82>
    8000318c:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000318e:	00004517          	auipc	a0,0x4
    80003192:	2d250513          	addi	a0,a0,722 # 80007460 <etext+0x460>
    80003196:	e9efd0ef          	jal	80000834 <panic>

000000008000319a <iget>:
{
    8000319a:	7179                	addi	sp,sp,-48
    8000319c:	f406                	sd	ra,40(sp)
    8000319e:	f022                	sd	s0,32(sp)
    800031a0:	ec26                	sd	s1,24(sp)
    800031a2:	e84a                	sd	s2,16(sp)
    800031a4:	e44e                	sd	s3,8(sp)
    800031a6:	e052                	sd	s4,0(sp)
    800031a8:	1800                	addi	s0,sp,48
    800031aa:	892a                	mv	s2,a0
    800031ac:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800031ae:	0001e517          	auipc	a0,0x1e
    800031b2:	86250513          	addi	a0,a0,-1950 # 80020a10 <itable>
    800031b6:	aeffd0ef          	jal	80000ca4 <acquire>
  empty = 0;
    800031ba:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    800031bc:	0001e497          	auipc	s1,0x1e
    800031c0:	86c48493          	addi	s1,s1,-1940 # 80020a28 <itable+0x18>
    800031c4:	0001f697          	auipc	a3,0x1f
    800031c8:	2f468693          	addi	a3,a3,756 # 800224b8 <log>
    800031cc:	a809                	j	800031de <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    800031ce:	e781                	bnez	a5,800031d6 <iget+0x3c>
    800031d0:	00099363          	bnez	s3,800031d6 <iget+0x3c>
      empty = ip;
    800031d4:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    800031d6:	08848493          	addi	s1,s1,136
    800031da:	02d48563          	beq	s1,a3,80003204 <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    800031de:	449c                	lw	a5,8(s1)
    800031e0:	fef057e3          	blez	a5,800031ce <iget+0x34>
    800031e4:	4098                	lw	a4,0(s1)
    800031e6:	ff2718e3          	bne	a4,s2,800031d6 <iget+0x3c>
    800031ea:	40d8                	lw	a4,4(s1)
    800031ec:	ff4715e3          	bne	a4,s4,800031d6 <iget+0x3c>
      ip->ref++;
    800031f0:	2785                	addiw	a5,a5,1
    800031f2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800031f4:	0001e517          	auipc	a0,0x1e
    800031f8:	81c50513          	addi	a0,a0,-2020 # 80020a10 <itable>
    800031fc:	b31fd0ef          	jal	80000d2c <release>
      return ip;
    80003200:	89a6                	mv	s3,s1
    80003202:	a015                	j	80003226 <iget+0x8c>
  if (empty == 0)
    80003204:	02098a63          	beqz	s3,80003238 <iget+0x9e>
  ip->dev = dev;
    80003208:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    8000320c:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003210:	4785                	li	a5,1
    80003212:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003216:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    8000321a:	0001d517          	auipc	a0,0x1d
    8000321e:	7f650513          	addi	a0,a0,2038 # 80020a10 <itable>
    80003222:	b0bfd0ef          	jal	80000d2c <release>
}
    80003226:	854e                	mv	a0,s3
    80003228:	70a2                	ld	ra,40(sp)
    8000322a:	7402                	ld	s0,32(sp)
    8000322c:	64e2                	ld	s1,24(sp)
    8000322e:	6942                	ld	s2,16(sp)
    80003230:	69a2                	ld	s3,8(sp)
    80003232:	6a02                	ld	s4,0(sp)
    80003234:	6145                	addi	sp,sp,48
    80003236:	8082                	ret
    panic("iget: no inodes");
    80003238:	00004517          	auipc	a0,0x4
    8000323c:	24050513          	addi	a0,a0,576 # 80007478 <etext+0x478>
    80003240:	df4fd0ef          	jal	80000834 <panic>

0000000080003244 <iinit>:
{
    80003244:	7179                	addi	sp,sp,-48
    80003246:	f406                	sd	ra,40(sp)
    80003248:	f022                	sd	s0,32(sp)
    8000324a:	ec26                	sd	s1,24(sp)
    8000324c:	e84a                	sd	s2,16(sp)
    8000324e:	e44e                	sd	s3,8(sp)
    80003250:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003252:	00004597          	auipc	a1,0x4
    80003256:	23658593          	addi	a1,a1,566 # 80007488 <etext+0x488>
    8000325a:	0001d517          	auipc	a0,0x1d
    8000325e:	7b650513          	addi	a0,a0,1974 # 80020a10 <itable>
    80003262:	9c3fd0ef          	jal	80000c24 <initlock>
  for (i = 0; i < NINODE; i++) {
    80003266:	0001d497          	auipc	s1,0x1d
    8000326a:	7d248493          	addi	s1,s1,2002 # 80020a38 <itable+0x28>
    8000326e:	0001f997          	auipc	s3,0x1f
    80003272:	25a98993          	addi	s3,s3,602 # 800224c8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003276:	00004917          	auipc	s2,0x4
    8000327a:	21a90913          	addi	s2,s2,538 # 80007490 <etext+0x490>
    8000327e:	85ca                	mv	a1,s2
    80003280:	8526                	mv	a0,s1
    80003282:	6e9000ef          	jal	8000416a <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    80003286:	08848493          	addi	s1,s1,136
    8000328a:	ff349ae3          	bne	s1,s3,8000327e <iinit+0x3a>
}
    8000328e:	70a2                	ld	ra,40(sp)
    80003290:	7402                	ld	s0,32(sp)
    80003292:	64e2                	ld	s1,24(sp)
    80003294:	6942                	ld	s2,16(sp)
    80003296:	69a2                	ld	s3,8(sp)
    80003298:	6145                	addi	sp,sp,48
    8000329a:	8082                	ret

000000008000329c <ialloc>:
{
    8000329c:	7139                	addi	sp,sp,-64
    8000329e:	fc06                	sd	ra,56(sp)
    800032a0:	f822                	sd	s0,48(sp)
    800032a2:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    800032a4:	0001d717          	auipc	a4,0x1d
    800032a8:	75872703          	lw	a4,1880(a4) # 800209fc <sb+0xc>
    800032ac:	4785                	li	a5,1
    800032ae:	06e7f063          	bgeu	a5,a4,8000330e <ialloc+0x72>
    800032b2:	f426                	sd	s1,40(sp)
    800032b4:	f04a                	sd	s2,32(sp)
    800032b6:	ec4e                	sd	s3,24(sp)
    800032b8:	e852                	sd	s4,16(sp)
    800032ba:	e456                	sd	s5,8(sp)
    800032bc:	e05a                	sd	s6,0(sp)
    800032be:	8aaa                	mv	s5,a0
    800032c0:	8b2e                	mv	s6,a1
    800032c2:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800032c4:	0001da17          	auipc	s4,0x1d
    800032c8:	72ca0a13          	addi	s4,s4,1836 # 800209f0 <sb>
    800032cc:	00495593          	srli	a1,s2,0x4
    800032d0:	018a2783          	lw	a5,24(s4)
    800032d4:	9dbd                	addw	a1,a1,a5
    800032d6:	8556                	mv	a0,s5
    800032d8:	a9dff0ef          	jal	80002d74 <bread>
    800032dc:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    800032de:	05850993          	addi	s3,a0,88
    800032e2:	00f97793          	andi	a5,s2,15
    800032e6:	079a                	slli	a5,a5,0x6
    800032e8:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    800032ea:	00099783          	lh	a5,0(s3)
    800032ee:	cb9d                	beqz	a5,80003324 <ialloc+0x88>
    brelse(bp);
    800032f0:	b8dff0ef          	jal	80002e7c <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    800032f4:	0905                	addi	s2,s2,1
    800032f6:	00ca2703          	lw	a4,12(s4)
    800032fa:	0009079b          	sext.w	a5,s2
    800032fe:	fce7e7e3          	bltu	a5,a4,800032cc <ialloc+0x30>
    80003302:	74a2                	ld	s1,40(sp)
    80003304:	7902                	ld	s2,32(sp)
    80003306:	69e2                	ld	s3,24(sp)
    80003308:	6a42                	ld	s4,16(sp)
    8000330a:	6aa2                	ld	s5,8(sp)
    8000330c:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    8000330e:	00004517          	auipc	a0,0x4
    80003312:	18a50513          	addi	a0,a0,394 # 80007498 <etext+0x498>
    80003316:	9f4fd0ef          	jal	8000050a <printk>
  return 0;
    8000331a:	4501                	li	a0,0
}
    8000331c:	70e2                	ld	ra,56(sp)
    8000331e:	7442                	ld	s0,48(sp)
    80003320:	6121                	addi	sp,sp,64
    80003322:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003324:	04000613          	li	a2,64
    80003328:	4581                	li	a1,0
    8000332a:	854e                	mv	a0,s3
    8000332c:	a39fd0ef          	jal	80000d64 <memset>
      dip->type = type;
    80003330:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    80003334:	8526                	mv	a0,s1
    80003336:	4fd000ef          	jal	80004032 <log_write>
      brelse(bp);
    8000333a:	8526                	mv	a0,s1
    8000333c:	b41ff0ef          	jal	80002e7c <brelse>
      return iget(dev, inum);
    80003340:	0009059b          	sext.w	a1,s2
    80003344:	8556                	mv	a0,s5
    80003346:	e55ff0ef          	jal	8000319a <iget>
    8000334a:	74a2                	ld	s1,40(sp)
    8000334c:	7902                	ld	s2,32(sp)
    8000334e:	69e2                	ld	s3,24(sp)
    80003350:	6a42                	ld	s4,16(sp)
    80003352:	6aa2                	ld	s5,8(sp)
    80003354:	6b02                	ld	s6,0(sp)
    80003356:	b7d9                	j	8000331c <ialloc+0x80>

0000000080003358 <iupdate>:
{
    80003358:	1101                	addi	sp,sp,-32
    8000335a:	ec06                	sd	ra,24(sp)
    8000335c:	e822                	sd	s0,16(sp)
    8000335e:	e426                	sd	s1,8(sp)
    80003360:	e04a                	sd	s2,0(sp)
    80003362:	1000                	addi	s0,sp,32
    80003364:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003366:	415c                	lw	a5,4(a0)
    80003368:	0047d79b          	srliw	a5,a5,0x4
    8000336c:	0001d597          	auipc	a1,0x1d
    80003370:	69c5a583          	lw	a1,1692(a1) # 80020a08 <sb+0x18>
    80003374:	9dbd                	addw	a1,a1,a5
    80003376:	4108                	lw	a0,0(a0)
    80003378:	9fdff0ef          	jal	80002d74 <bread>
    8000337c:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000337e:	05850793          	addi	a5,a0,88
    80003382:	40d8                	lw	a4,4(s1)
    80003384:	8b3d                	andi	a4,a4,15
    80003386:	071a                	slli	a4,a4,0x6
    80003388:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000338a:	04449703          	lh	a4,68(s1)
    8000338e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003392:	04649703          	lh	a4,70(s1)
    80003396:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000339a:	04849703          	lh	a4,72(s1)
    8000339e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800033a2:	04a49703          	lh	a4,74(s1)
    800033a6:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800033aa:	44f8                	lw	a4,76(s1)
    800033ac:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800033ae:	03400613          	li	a2,52
    800033b2:	05048593          	addi	a1,s1,80
    800033b6:	00c78513          	addi	a0,a5,12
    800033ba:	a0bfd0ef          	jal	80000dc4 <memmove>
  log_write(bp);
    800033be:	854a                	mv	a0,s2
    800033c0:	473000ef          	jal	80004032 <log_write>
  brelse(bp);
    800033c4:	854a                	mv	a0,s2
    800033c6:	ab7ff0ef          	jal	80002e7c <brelse>
}
    800033ca:	60e2                	ld	ra,24(sp)
    800033cc:	6442                	ld	s0,16(sp)
    800033ce:	64a2                	ld	s1,8(sp)
    800033d0:	6902                	ld	s2,0(sp)
    800033d2:	6105                	addi	sp,sp,32
    800033d4:	8082                	ret

00000000800033d6 <idup>:
{
    800033d6:	1101                	addi	sp,sp,-32
    800033d8:	ec06                	sd	ra,24(sp)
    800033da:	e822                	sd	s0,16(sp)
    800033dc:	e426                	sd	s1,8(sp)
    800033de:	1000                	addi	s0,sp,32
    800033e0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800033e2:	0001d517          	auipc	a0,0x1d
    800033e6:	62e50513          	addi	a0,a0,1582 # 80020a10 <itable>
    800033ea:	8bbfd0ef          	jal	80000ca4 <acquire>
  ip->ref++;
    800033ee:	449c                	lw	a5,8(s1)
    800033f0:	2785                	addiw	a5,a5,1
    800033f2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033f4:	0001d517          	auipc	a0,0x1d
    800033f8:	61c50513          	addi	a0,a0,1564 # 80020a10 <itable>
    800033fc:	931fd0ef          	jal	80000d2c <release>
}
    80003400:	8526                	mv	a0,s1
    80003402:	60e2                	ld	ra,24(sp)
    80003404:	6442                	ld	s0,16(sp)
    80003406:	64a2                	ld	s1,8(sp)
    80003408:	6105                	addi	sp,sp,32
    8000340a:	8082                	ret

000000008000340c <ilock>:
{
    8000340c:	1101                	addi	sp,sp,-32
    8000340e:	ec06                	sd	ra,24(sp)
    80003410:	e822                	sd	s0,16(sp)
    80003412:	e426                	sd	s1,8(sp)
    80003414:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    80003416:	cd19                	beqz	a0,80003434 <ilock+0x28>
    80003418:	84aa                	mv	s1,a0
    8000341a:	451c                	lw	a5,8(a0)
    8000341c:	00f05c63          	blez	a5,80003434 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003420:	0541                	addi	a0,a0,16
    80003422:	57f000ef          	jal	800041a0 <acquiresleep>
  if (ip->valid == 0) {
    80003426:	40bc                	lw	a5,64(s1)
    80003428:	cf89                	beqz	a5,80003442 <ilock+0x36>
}
    8000342a:	60e2                	ld	ra,24(sp)
    8000342c:	6442                	ld	s0,16(sp)
    8000342e:	64a2                	ld	s1,8(sp)
    80003430:	6105                	addi	sp,sp,32
    80003432:	8082                	ret
    80003434:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003436:	00004517          	auipc	a0,0x4
    8000343a:	07a50513          	addi	a0,a0,122 # 800074b0 <etext+0x4b0>
    8000343e:	bf6fd0ef          	jal	80000834 <panic>
    80003442:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003444:	40dc                	lw	a5,4(s1)
    80003446:	0047d79b          	srliw	a5,a5,0x4
    8000344a:	0001d597          	auipc	a1,0x1d
    8000344e:	5be5a583          	lw	a1,1470(a1) # 80020a08 <sb+0x18>
    80003452:	9dbd                	addw	a1,a1,a5
    80003454:	4088                	lw	a0,0(s1)
    80003456:	91fff0ef          	jal	80002d74 <bread>
    8000345a:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000345c:	05850593          	addi	a1,a0,88
    80003460:	40dc                	lw	a5,4(s1)
    80003462:	8bbd                	andi	a5,a5,15
    80003464:	079a                	slli	a5,a5,0x6
    80003466:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003468:	00059783          	lh	a5,0(a1)
    8000346c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003470:	00259783          	lh	a5,2(a1)
    80003474:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003478:	00459783          	lh	a5,4(a1)
    8000347c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003480:	00659783          	lh	a5,6(a1)
    80003484:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003488:	459c                	lw	a5,8(a1)
    8000348a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000348c:	03400613          	li	a2,52
    80003490:	05b1                	addi	a1,a1,12
    80003492:	05048513          	addi	a0,s1,80
    80003496:	92ffd0ef          	jal	80000dc4 <memmove>
    brelse(bp);
    8000349a:	854a                	mv	a0,s2
    8000349c:	9e1ff0ef          	jal	80002e7c <brelse>
    ip->valid = 1;
    800034a0:	4785                	li	a5,1
    800034a2:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    800034a4:	04449783          	lh	a5,68(s1)
    800034a8:	c399                	beqz	a5,800034ae <ilock+0xa2>
    800034aa:	6902                	ld	s2,0(sp)
    800034ac:	bfbd                	j	8000342a <ilock+0x1e>
      panic("ilock: no type");
    800034ae:	00004517          	auipc	a0,0x4
    800034b2:	00a50513          	addi	a0,a0,10 # 800074b8 <etext+0x4b8>
    800034b6:	b7efd0ef          	jal	80000834 <panic>

00000000800034ba <iunlock>:
{
    800034ba:	1101                	addi	sp,sp,-32
    800034bc:	ec06                	sd	ra,24(sp)
    800034be:	e822                	sd	s0,16(sp)
    800034c0:	e426                	sd	s1,8(sp)
    800034c2:	e04a                	sd	s2,0(sp)
    800034c4:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800034c6:	c505                	beqz	a0,800034ee <iunlock+0x34>
    800034c8:	84aa                	mv	s1,a0
    800034ca:	01050913          	addi	s2,a0,16
    800034ce:	854a                	mv	a0,s2
    800034d0:	55d000ef          	jal	8000422c <holdingsleep>
    800034d4:	cd09                	beqz	a0,800034ee <iunlock+0x34>
    800034d6:	449c                	lw	a5,8(s1)
    800034d8:	00f05b63          	blez	a5,800034ee <iunlock+0x34>
  releasesleep(&ip->lock);
    800034dc:	854a                	mv	a0,s2
    800034de:	517000ef          	jal	800041f4 <releasesleep>
}
    800034e2:	60e2                	ld	ra,24(sp)
    800034e4:	6442                	ld	s0,16(sp)
    800034e6:	64a2                	ld	s1,8(sp)
    800034e8:	6902                	ld	s2,0(sp)
    800034ea:	6105                	addi	sp,sp,32
    800034ec:	8082                	ret
    panic("iunlock");
    800034ee:	00004517          	auipc	a0,0x4
    800034f2:	fda50513          	addi	a0,a0,-38 # 800074c8 <etext+0x4c8>
    800034f6:	b3efd0ef          	jal	80000834 <panic>

00000000800034fa <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800034fa:	7179                	addi	sp,sp,-48
    800034fc:	f406                	sd	ra,40(sp)
    800034fe:	f022                	sd	s0,32(sp)
    80003500:	ec26                	sd	s1,24(sp)
    80003502:	e84a                	sd	s2,16(sp)
    80003504:	e44e                	sd	s3,8(sp)
    80003506:	1800                	addi	s0,sp,48
    80003508:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    8000350a:	05050493          	addi	s1,a0,80
    8000350e:	08050913          	addi	s2,a0,128
    80003512:	a021                	j	8000351a <itrunc+0x20>
    80003514:	0491                	addi	s1,s1,4
    80003516:	01248b63          	beq	s1,s2,8000352c <itrunc+0x32>
    if (ip->addrs[i]) {
    8000351a:	408c                	lw	a1,0(s1)
    8000351c:	dde5                	beqz	a1,80003514 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000351e:	0009a503          	lw	a0,0(s3)
    80003522:	a47ff0ef          	jal	80002f68 <bfree>
      ip->addrs[i] = 0;
    80003526:	0004a023          	sw	zero,0(s1)
    8000352a:	b7ed                	j	80003514 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    8000352c:	0809a583          	lw	a1,128(s3)
    80003530:	ed89                	bnez	a1,8000354a <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003532:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003536:	854e                	mv	a0,s3
    80003538:	e21ff0ef          	jal	80003358 <iupdate>
}
    8000353c:	70a2                	ld	ra,40(sp)
    8000353e:	7402                	ld	s0,32(sp)
    80003540:	64e2                	ld	s1,24(sp)
    80003542:	6942                	ld	s2,16(sp)
    80003544:	69a2                	ld	s3,8(sp)
    80003546:	6145                	addi	sp,sp,48
    80003548:	8082                	ret
    8000354a:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000354c:	0009a503          	lw	a0,0(s3)
    80003550:	825ff0ef          	jal	80002d74 <bread>
    80003554:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    80003556:	05850493          	addi	s1,a0,88
    8000355a:	45850913          	addi	s2,a0,1112
    8000355e:	a021                	j	80003566 <itrunc+0x6c>
    80003560:	0491                	addi	s1,s1,4
    80003562:	01248963          	beq	s1,s2,80003574 <itrunc+0x7a>
      if (a[j])
    80003566:	408c                	lw	a1,0(s1)
    80003568:	dde5                	beqz	a1,80003560 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000356a:	0009a503          	lw	a0,0(s3)
    8000356e:	9fbff0ef          	jal	80002f68 <bfree>
    80003572:	b7fd                	j	80003560 <itrunc+0x66>
    brelse(bp);
    80003574:	8552                	mv	a0,s4
    80003576:	907ff0ef          	jal	80002e7c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000357a:	0809a583          	lw	a1,128(s3)
    8000357e:	0009a503          	lw	a0,0(s3)
    80003582:	9e7ff0ef          	jal	80002f68 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003586:	0809a023          	sw	zero,128(s3)
    8000358a:	6a02                	ld	s4,0(sp)
    8000358c:	b75d                	j	80003532 <itrunc+0x38>

000000008000358e <iput>:
{
    8000358e:	7179                	addi	sp,sp,-48
    80003590:	f406                	sd	ra,40(sp)
    80003592:	f022                	sd	s0,32(sp)
    80003594:	ec26                	sd	s1,24(sp)
    80003596:	1800                	addi	s0,sp,48
    80003598:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000359a:	0001d517          	auipc	a0,0x1d
    8000359e:	47650513          	addi	a0,a0,1142 # 80020a10 <itable>
    800035a2:	f02fd0ef          	jal	80000ca4 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    800035a6:	449c                	lw	a5,8(s1)
    800035a8:	4705                	li	a4,1
    800035aa:	00e78f63          	beq	a5,a4,800035c8 <iput+0x3a>
  ip->ref--;
    800035ae:	37fd                	addiw	a5,a5,-1
    800035b0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800035b2:	0001d517          	auipc	a0,0x1d
    800035b6:	45e50513          	addi	a0,a0,1118 # 80020a10 <itable>
    800035ba:	f72fd0ef          	jal	80000d2c <release>
}
    800035be:	70a2                	ld	ra,40(sp)
    800035c0:	7402                	ld	s0,32(sp)
    800035c2:	64e2                	ld	s1,24(sp)
    800035c4:	6145                	addi	sp,sp,48
    800035c6:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    800035c8:	40b8                	lw	a4,64(s1)
    800035ca:	d375                	beqz	a4,800035ae <iput+0x20>
    800035cc:	e84a                	sd	s2,16(sp)
    800035ce:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    800035d0:	0004aa03          	lw	s4,0(s1)
    800035d4:	0044a903          	lw	s2,4(s1)
  if (last) {
    800035d8:	04a49703          	lh	a4,74(s1)
    800035dc:	ef3d                	bnez	a4,8000365a <iput+0xcc>
    800035de:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    800035e0:	01048793          	addi	a5,s1,16
    800035e4:	89be                	mv	s3,a5
    800035e6:	853e                	mv	a0,a5
    800035e8:	3b9000ef          	jal	800041a0 <acquiresleep>
    release(&itable.lock);
    800035ec:	0001d517          	auipc	a0,0x1d
    800035f0:	42450513          	addi	a0,a0,1060 # 80020a10 <itable>
    800035f4:	f38fd0ef          	jal	80000d2c <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    800035f8:	8526                	mv	a0,s1
    800035fa:	f01ff0ef          	jal	800034fa <itrunc>
    ip->valid = 0;
    800035fe:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003602:	854e                	mv	a0,s3
    80003604:	3f1000ef          	jal	800041f4 <releasesleep>
    acquire(&itable.lock);
    80003608:	0001d517          	auipc	a0,0x1d
    8000360c:	40850513          	addi	a0,a0,1032 # 80020a10 <itable>
    80003610:	e94fd0ef          	jal	80000ca4 <acquire>
  ip->ref--;
    80003614:	449c                	lw	a5,8(s1)
    80003616:	37fd                	addiw	a5,a5,-1
    80003618:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000361a:	0001d517          	auipc	a0,0x1d
    8000361e:	3f650513          	addi	a0,a0,1014 # 80020a10 <itable>
    80003622:	f0afd0ef          	jal	80000d2c <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003626:	0049579b          	srliw	a5,s2,0x4
    8000362a:	0001d597          	auipc	a1,0x1d
    8000362e:	3de5a583          	lw	a1,990(a1) # 80020a08 <sb+0x18>
    80003632:	9dbd                	addw	a1,a1,a5
    80003634:	8552                	mv	a0,s4
    80003636:	f3eff0ef          	jal	80002d74 <bread>
    8000363a:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000363c:	00f97793          	andi	a5,s2,15
  dip->type = 0;
    80003640:	079a                	slli	a5,a5,0x6
    80003642:	97aa                	add	a5,a5,a0
    80003644:	04079c23          	sh	zero,88(a5)
  log_write(bp);
    80003648:	1eb000ef          	jal	80004032 <log_write>
  brelse(bp);
    8000364c:	8526                	mv	a0,s1
    8000364e:	82fff0ef          	jal	80002e7c <brelse>
}
    80003652:	6942                	ld	s2,16(sp)
    80003654:	69a2                	ld	s3,8(sp)
    80003656:	6a02                	ld	s4,0(sp)
    80003658:	b79d                	j	800035be <iput+0x30>
    8000365a:	6942                	ld	s2,16(sp)
    8000365c:	6a02                	ld	s4,0(sp)
    8000365e:	bf81                	j	800035ae <iput+0x20>

0000000080003660 <iunlockput>:
{
    80003660:	1101                	addi	sp,sp,-32
    80003662:	ec06                	sd	ra,24(sp)
    80003664:	e822                	sd	s0,16(sp)
    80003666:	e426                	sd	s1,8(sp)
    80003668:	1000                	addi	s0,sp,32
    8000366a:	84aa                	mv	s1,a0
  iunlock(ip);
    8000366c:	e4fff0ef          	jal	800034ba <iunlock>
  iput(ip);
    80003670:	8526                	mv	a0,s1
    80003672:	f1dff0ef          	jal	8000358e <iput>
}
    80003676:	60e2                	ld	ra,24(sp)
    80003678:	6442                	ld	s0,16(sp)
    8000367a:	64a2                	ld	s1,8(sp)
    8000367c:	6105                	addi	sp,sp,32
    8000367e:	8082                	ret

0000000080003680 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003680:	0001d717          	auipc	a4,0x1d
    80003684:	37c72703          	lw	a4,892(a4) # 800209fc <sb+0xc>
    80003688:	4785                	li	a5,1
    8000368a:	0ae7fe63          	bgeu	a5,a4,80003746 <ireclaim+0xc6>
{
    8000368e:	7139                	addi	sp,sp,-64
    80003690:	fc06                	sd	ra,56(sp)
    80003692:	f822                	sd	s0,48(sp)
    80003694:	f426                	sd	s1,40(sp)
    80003696:	f04a                	sd	s2,32(sp)
    80003698:	ec4e                	sd	s3,24(sp)
    8000369a:	e852                	sd	s4,16(sp)
    8000369c:	e456                	sd	s5,8(sp)
    8000369e:	e05a                	sd	s6,0(sp)
    800036a0:	0080                	addi	s0,sp,64
    800036a2:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800036a4:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800036a6:	0001da17          	auipc	s4,0x1d
    800036aa:	34aa0a13          	addi	s4,s4,842 # 800209f0 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    800036ae:	00004b17          	auipc	s6,0x4
    800036b2:	e22b0b13          	addi	s6,s6,-478 # 800074d0 <etext+0x4d0>
    800036b6:	a099                	j	800036fc <ireclaim+0x7c>
    800036b8:	85ce                	mv	a1,s3
    800036ba:	855a                	mv	a0,s6
    800036bc:	e4ffc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    800036c0:	85ce                	mv	a1,s3
    800036c2:	8556                	mv	a0,s5
    800036c4:	ad7ff0ef          	jal	8000319a <iget>
    800036c8:	89aa                	mv	s3,a0
    brelse(bp);
    800036ca:	854a                	mv	a0,s2
    800036cc:	fb0ff0ef          	jal	80002e7c <brelse>
    if (ip) {
    800036d0:	00098f63          	beqz	s3,800036ee <ireclaim+0x6e>
      begin_op();
    800036d4:	7b0000ef          	jal	80003e84 <begin_op>
      ilock(ip);
    800036d8:	854e                	mv	a0,s3
    800036da:	d33ff0ef          	jal	8000340c <ilock>
      iunlock(ip);
    800036de:	854e                	mv	a0,s3
    800036e0:	ddbff0ef          	jal	800034ba <iunlock>
      iput(ip);
    800036e4:	854e                	mv	a0,s3
    800036e6:	ea9ff0ef          	jal	8000358e <iput>
      end_op();
    800036ea:	027000ef          	jal	80003f10 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800036ee:	0485                	addi	s1,s1,1
    800036f0:	00ca2703          	lw	a4,12(s4)
    800036f4:	0004879b          	sext.w	a5,s1
    800036f8:	02e7fd63          	bgeu	a5,a4,80003732 <ireclaim+0xb2>
    800036fc:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003700:	0044d593          	srli	a1,s1,0x4
    80003704:	018a2783          	lw	a5,24(s4)
    80003708:	9dbd                	addw	a1,a1,a5
    8000370a:	8556                	mv	a0,s5
    8000370c:	e68ff0ef          	jal	80002d74 <bread>
    80003710:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003712:	05850793          	addi	a5,a0,88
    80003716:	00f9f713          	andi	a4,s3,15
    8000371a:	071a                	slli	a4,a4,0x6
    8000371c:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    8000371e:	00079703          	lh	a4,0(a5)
    80003722:	c701                	beqz	a4,8000372a <ireclaim+0xaa>
    80003724:	00679783          	lh	a5,6(a5)
    80003728:	dbc1                	beqz	a5,800036b8 <ireclaim+0x38>
    brelse(bp);
    8000372a:	854a                	mv	a0,s2
    8000372c:	f50ff0ef          	jal	80002e7c <brelse>
    if (ip) {
    80003730:	bf7d                	j	800036ee <ireclaim+0x6e>
}
    80003732:	70e2                	ld	ra,56(sp)
    80003734:	7442                	ld	s0,48(sp)
    80003736:	74a2                	ld	s1,40(sp)
    80003738:	7902                	ld	s2,32(sp)
    8000373a:	69e2                	ld	s3,24(sp)
    8000373c:	6a42                	ld	s4,16(sp)
    8000373e:	6aa2                	ld	s5,8(sp)
    80003740:	6b02                	ld	s6,0(sp)
    80003742:	6121                	addi	sp,sp,64
    80003744:	8082                	ret
    80003746:	8082                	ret

0000000080003748 <fsinit>:
{
    80003748:	1101                	addi	sp,sp,-32
    8000374a:	ec06                	sd	ra,24(sp)
    8000374c:	e822                	sd	s0,16(sp)
    8000374e:	e426                	sd	s1,8(sp)
    80003750:	e04a                	sd	s2,0(sp)
    80003752:	1000                	addi	s0,sp,32
    80003754:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003756:	4585                	li	a1,1
    80003758:	e1cff0ef          	jal	80002d74 <bread>
    8000375c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000375e:	02000613          	li	a2,32
    80003762:	05850593          	addi	a1,a0,88
    80003766:	0001d517          	auipc	a0,0x1d
    8000376a:	28a50513          	addi	a0,a0,650 # 800209f0 <sb>
    8000376e:	e56fd0ef          	jal	80000dc4 <memmove>
  brelse(bp);
    80003772:	8526                	mv	a0,s1
    80003774:	f08ff0ef          	jal	80002e7c <brelse>
  if (sb.magic != FSMAGIC)
    80003778:	0001d717          	auipc	a4,0x1d
    8000377c:	27872703          	lw	a4,632(a4) # 800209f0 <sb>
    80003780:	102037b7          	lui	a5,0x10203
    80003784:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003788:	02f71263          	bne	a4,a5,800037ac <fsinit+0x64>
  initlog(dev, &sb);
    8000378c:	0001d597          	auipc	a1,0x1d
    80003790:	26458593          	addi	a1,a1,612 # 800209f0 <sb>
    80003794:	854a                	mv	a0,s2
    80003796:	66c000ef          	jal	80003e02 <initlog>
  ireclaim(dev);
    8000379a:	854a                	mv	a0,s2
    8000379c:	ee5ff0ef          	jal	80003680 <ireclaim>
}
    800037a0:	60e2                	ld	ra,24(sp)
    800037a2:	6442                	ld	s0,16(sp)
    800037a4:	64a2                	ld	s1,8(sp)
    800037a6:	6902                	ld	s2,0(sp)
    800037a8:	6105                	addi	sp,sp,32
    800037aa:	8082                	ret
    panic("invalid file system");
    800037ac:	00004517          	auipc	a0,0x4
    800037b0:	d4450513          	addi	a0,a0,-700 # 800074f0 <etext+0x4f0>
    800037b4:	880fd0ef          	jal	80000834 <panic>

00000000800037b8 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800037b8:	1141                	addi	sp,sp,-16
    800037ba:	e406                	sd	ra,8(sp)
    800037bc:	e022                	sd	s0,0(sp)
    800037be:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800037c0:	411c                	lw	a5,0(a0)
    800037c2:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800037c4:	415c                	lw	a5,4(a0)
    800037c6:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800037c8:	04451783          	lh	a5,68(a0)
    800037cc:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800037d0:	04a51783          	lh	a5,74(a0)
    800037d4:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800037d8:	04c56783          	lwu	a5,76(a0)
    800037dc:	e99c                	sd	a5,16(a1)
}
    800037de:	60a2                	ld	ra,8(sp)
    800037e0:	6402                	ld	s0,0(sp)
    800037e2:	0141                	addi	sp,sp,16
    800037e4:	8082                	ret

00000000800037e6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    800037e6:	457c                	lw	a5,76(a0)
    800037e8:	0ed7e663          	bltu	a5,a3,800038d4 <readi+0xee>
{
    800037ec:	7159                	addi	sp,sp,-112
    800037ee:	f486                	sd	ra,104(sp)
    800037f0:	f0a2                	sd	s0,96(sp)
    800037f2:	eca6                	sd	s1,88(sp)
    800037f4:	e0d2                	sd	s4,64(sp)
    800037f6:	fc56                	sd	s5,56(sp)
    800037f8:	f85a                	sd	s6,48(sp)
    800037fa:	f45e                	sd	s7,40(sp)
    800037fc:	1880                	addi	s0,sp,112
    800037fe:	8b2a                	mv	s6,a0
    80003800:	8bae                	mv	s7,a1
    80003802:	8a32                	mv	s4,a2
    80003804:	84b6                	mv	s1,a3
    80003806:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    80003808:	9f35                	addw	a4,a4,a3
    return 0;
    8000380a:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    8000380c:	0ad76b63          	bltu	a4,a3,800038c2 <readi+0xdc>
    80003810:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    80003812:	00e7f463          	bgeu	a5,a4,8000381a <readi+0x34>
    n = ip->size - off;
    80003816:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    8000381a:	080a8b63          	beqz	s5,800038b0 <readi+0xca>
    8000381e:	e8ca                	sd	s2,80(sp)
    80003820:	f062                	sd	s8,32(sp)
    80003822:	ec66                	sd	s9,24(sp)
    80003824:	e86a                	sd	s10,16(sp)
    80003826:	e46e                	sd	s11,8(sp)
    80003828:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    8000382a:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000382e:	5c7d                	li	s8,-1
    80003830:	a80d                	j	80003862 <readi+0x7c>
    80003832:	020d1d93          	slli	s11,s10,0x20
    80003836:	020ddd93          	srli	s11,s11,0x20
    8000383a:	05890613          	addi	a2,s2,88
    8000383e:	86ee                	mv	a3,s11
    80003840:	963e                	add	a2,a2,a5
    80003842:	85d2                	mv	a1,s4
    80003844:	855e                	mv	a0,s7
    80003846:	bb5fe0ef          	jal	800023fa <either_copyout>
    8000384a:	05850363          	beq	a0,s8,80003890 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000384e:	854a                	mv	a0,s2
    80003850:	e2cff0ef          	jal	80002e7c <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003854:	013d09bb          	addw	s3,s10,s3
    80003858:	009d04bb          	addw	s1,s10,s1
    8000385c:	9a6e                	add	s4,s4,s11
    8000385e:	0559f363          	bgeu	s3,s5,800038a4 <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    80003862:	00a4d59b          	srliw	a1,s1,0xa
    80003866:	855a                	mv	a0,s6
    80003868:	873ff0ef          	jal	800030da <bmap>
    8000386c:	85aa                	mv	a1,a0
    if (addr == 0)
    8000386e:	c139                	beqz	a0,800038b4 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003870:	000b2503          	lw	a0,0(s6)
    80003874:	d00ff0ef          	jal	80002d74 <bread>
    80003878:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    8000387a:	3ff4f793          	andi	a5,s1,1023
    8000387e:	40fc873b          	subw	a4,s9,a5
    80003882:	413a86bb          	subw	a3,s5,s3
    80003886:	8d3a                	mv	s10,a4
    80003888:	fae6f5e3          	bgeu	a3,a4,80003832 <readi+0x4c>
    8000388c:	8d36                	mv	s10,a3
    8000388e:	b755                	j	80003832 <readi+0x4c>
      brelse(bp);
    80003890:	854a                	mv	a0,s2
    80003892:	deaff0ef          	jal	80002e7c <brelse>
      tot = -1;
    80003896:	59fd                	li	s3,-1
      break;
    80003898:	6946                	ld	s2,80(sp)
    8000389a:	7c02                	ld	s8,32(sp)
    8000389c:	6ce2                	ld	s9,24(sp)
    8000389e:	6d42                	ld	s10,16(sp)
    800038a0:	6da2                	ld	s11,8(sp)
    800038a2:	a831                	j	800038be <readi+0xd8>
    800038a4:	6946                	ld	s2,80(sp)
    800038a6:	7c02                	ld	s8,32(sp)
    800038a8:	6ce2                	ld	s9,24(sp)
    800038aa:	6d42                	ld	s10,16(sp)
    800038ac:	6da2                	ld	s11,8(sp)
    800038ae:	a801                	j	800038be <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800038b0:	89d6                	mv	s3,s5
    800038b2:	a031                	j	800038be <readi+0xd8>
    800038b4:	6946                	ld	s2,80(sp)
    800038b6:	7c02                	ld	s8,32(sp)
    800038b8:	6ce2                	ld	s9,24(sp)
    800038ba:	6d42                	ld	s10,16(sp)
    800038bc:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800038be:	854e                	mv	a0,s3
    800038c0:	69a6                	ld	s3,72(sp)
}
    800038c2:	70a6                	ld	ra,104(sp)
    800038c4:	7406                	ld	s0,96(sp)
    800038c6:	64e6                	ld	s1,88(sp)
    800038c8:	6a06                	ld	s4,64(sp)
    800038ca:	7ae2                	ld	s5,56(sp)
    800038cc:	7b42                	ld	s6,48(sp)
    800038ce:	7ba2                	ld	s7,40(sp)
    800038d0:	6165                	addi	sp,sp,112
    800038d2:	8082                	ret
    return 0;
    800038d4:	4501                	li	a0,0
}
    800038d6:	8082                	ret

00000000800038d8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    800038d8:	457c                	lw	a5,76(a0)
    800038da:	0ed7ee63          	bltu	a5,a3,800039d6 <writei+0xfe>
{
    800038de:	7159                	addi	sp,sp,-112
    800038e0:	f486                	sd	ra,104(sp)
    800038e2:	f0a2                	sd	s0,96(sp)
    800038e4:	e8ca                	sd	s2,80(sp)
    800038e6:	e0d2                	sd	s4,64(sp)
    800038e8:	fc56                	sd	s5,56(sp)
    800038ea:	f85a                	sd	s6,48(sp)
    800038ec:	f45e                	sd	s7,40(sp)
    800038ee:	1880                	addi	s0,sp,112
    800038f0:	8aaa                	mv	s5,a0
    800038f2:	8bae                	mv	s7,a1
    800038f4:	8a32                	mv	s4,a2
    800038f6:	8936                	mv	s2,a3
    800038f8:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    800038fa:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    800038fe:	00043737          	lui	a4,0x43
    80003902:	0cf76c63          	bltu	a4,a5,800039da <writei+0x102>
    80003906:	0cd7ea63          	bltu	a5,a3,800039da <writei+0x102>
    8000390a:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    8000390c:	0a0b0d63          	beqz	s6,800039c6 <writei+0xee>
    80003910:	eca6                	sd	s1,88(sp)
    80003912:	f062                	sd	s8,32(sp)
    80003914:	ec66                	sd	s9,24(sp)
    80003916:	e86a                	sd	s10,16(sp)
    80003918:	e46e                	sd	s11,8(sp)
    8000391a:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    8000391c:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003920:	5c7d                	li	s8,-1
    80003922:	a825                	j	8000395a <writei+0x82>
    80003924:	020d1d93          	slli	s11,s10,0x20
    80003928:	020ddd93          	srli	s11,s11,0x20
    8000392c:	05848513          	addi	a0,s1,88
    80003930:	86ee                	mv	a3,s11
    80003932:	8652                	mv	a2,s4
    80003934:	85de                	mv	a1,s7
    80003936:	953e                	add	a0,a0,a5
    80003938:	b0ffe0ef          	jal	80002446 <either_copyin>
    8000393c:	05850663          	beq	a0,s8,80003988 <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    80003940:	8526                	mv	a0,s1
    80003942:	6f0000ef          	jal	80004032 <log_write>
    brelse(bp);
    80003946:	8526                	mv	a0,s1
    80003948:	d34ff0ef          	jal	80002e7c <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    8000394c:	013d09bb          	addw	s3,s10,s3
    80003950:	012d093b          	addw	s2,s10,s2
    80003954:	9a6e                	add	s4,s4,s11
    80003956:	0369ff63          	bgeu	s3,s6,80003994 <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    8000395a:	00a9559b          	srliw	a1,s2,0xa
    8000395e:	8556                	mv	a0,s5
    80003960:	f7aff0ef          	jal	800030da <bmap>
    80003964:	85aa                	mv	a1,a0
    if (addr == 0)
    80003966:	c51d                	beqz	a0,80003994 <writei+0xbc>
    bp = bread(ip->dev, addr);
    80003968:	000aa503          	lw	a0,0(s5)
    8000396c:	c08ff0ef          	jal	80002d74 <bread>
    80003970:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003972:	3ff97793          	andi	a5,s2,1023
    80003976:	40fc873b          	subw	a4,s9,a5
    8000397a:	413b06bb          	subw	a3,s6,s3
    8000397e:	8d3a                	mv	s10,a4
    80003980:	fae6f2e3          	bgeu	a3,a4,80003924 <writei+0x4c>
    80003984:	8d36                	mv	s10,a3
    80003986:	bf79                	j	80003924 <writei+0x4c>
      log_write(bp);
    80003988:	8526                	mv	a0,s1
    8000398a:	6a8000ef          	jal	80004032 <log_write>
      brelse(bp);
    8000398e:	8526                	mv	a0,s1
    80003990:	cecff0ef          	jal	80002e7c <brelse>
  }

  if (off > ip->size)
    80003994:	04caa783          	lw	a5,76(s5)
    80003998:	0327f963          	bgeu	a5,s2,800039ca <writei+0xf2>
    ip->size = off;
    8000399c:	052aa623          	sw	s2,76(s5)
    800039a0:	64e6                	ld	s1,88(sp)
    800039a2:	7c02                	ld	s8,32(sp)
    800039a4:	6ce2                	ld	s9,24(sp)
    800039a6:	6d42                	ld	s10,16(sp)
    800039a8:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800039aa:	8556                	mv	a0,s5
    800039ac:	9adff0ef          	jal	80003358 <iupdate>

  return tot;
    800039b0:	854e                	mv	a0,s3
    800039b2:	69a6                	ld	s3,72(sp)
}
    800039b4:	70a6                	ld	ra,104(sp)
    800039b6:	7406                	ld	s0,96(sp)
    800039b8:	6946                	ld	s2,80(sp)
    800039ba:	6a06                	ld	s4,64(sp)
    800039bc:	7ae2                	ld	s5,56(sp)
    800039be:	7b42                	ld	s6,48(sp)
    800039c0:	7ba2                	ld	s7,40(sp)
    800039c2:	6165                	addi	sp,sp,112
    800039c4:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800039c6:	89da                	mv	s3,s6
    800039c8:	b7cd                	j	800039aa <writei+0xd2>
    800039ca:	64e6                	ld	s1,88(sp)
    800039cc:	7c02                	ld	s8,32(sp)
    800039ce:	6ce2                	ld	s9,24(sp)
    800039d0:	6d42                	ld	s10,16(sp)
    800039d2:	6da2                	ld	s11,8(sp)
    800039d4:	bfd9                	j	800039aa <writei+0xd2>
    return -1;
    800039d6:	557d                	li	a0,-1
}
    800039d8:	8082                	ret
    return -1;
    800039da:	557d                	li	a0,-1
    800039dc:	bfe1                	j	800039b4 <writei+0xdc>

00000000800039de <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800039de:	1141                	addi	sp,sp,-16
    800039e0:	e406                	sd	ra,8(sp)
    800039e2:	e022                	sd	s0,0(sp)
    800039e4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800039e6:	4639                	li	a2,14
    800039e8:	c50fd0ef          	jal	80000e38 <strncmp>
}
    800039ec:	60a2                	ld	ra,8(sp)
    800039ee:	6402                	ld	s0,0(sp)
    800039f0:	0141                	addi	sp,sp,16
    800039f2:	8082                	ret

00000000800039f4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800039f4:	711d                	addi	sp,sp,-96
    800039f6:	ec86                	sd	ra,88(sp)
    800039f8:	e8a2                	sd	s0,80(sp)
    800039fa:	e4a6                	sd	s1,72(sp)
    800039fc:	e0ca                	sd	s2,64(sp)
    800039fe:	fc4e                	sd	s3,56(sp)
    80003a00:	f852                	sd	s4,48(sp)
    80003a02:	f456                	sd	s5,40(sp)
    80003a04:	f05a                	sd	s6,32(sp)
    80003a06:	ec5e                	sd	s7,24(sp)
    80003a08:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003a0a:	04451703          	lh	a4,68(a0)
    80003a0e:	4785                	li	a5,1
    80003a10:	00f71f63          	bne	a4,a5,80003a2e <dirlookup+0x3a>
    80003a14:	892a                	mv	s2,a0
    80003a16:	8aae                	mv	s5,a1
    80003a18:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a1a:	457c                	lw	a5,76(a0)
    80003a1c:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a1e:	fa040a13          	addi	s4,s0,-96
    80003a22:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    80003a24:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003a28:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a2a:	e39d                	bnez	a5,80003a50 <dirlookup+0x5c>
    80003a2c:	a8b9                	j	80003a8a <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003a2e:	00004517          	auipc	a0,0x4
    80003a32:	ada50513          	addi	a0,a0,-1318 # 80007508 <etext+0x508>
    80003a36:	dfffc0ef          	jal	80000834 <panic>
      panic("dirlookup read");
    80003a3a:	00004517          	auipc	a0,0x4
    80003a3e:	ae650513          	addi	a0,a0,-1306 # 80007520 <etext+0x520>
    80003a42:	df3fc0ef          	jal	80000834 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a46:	24c1                	addiw	s1,s1,16
    80003a48:	04c92783          	lw	a5,76(s2)
    80003a4c:	02f4fe63          	bgeu	s1,a5,80003a88 <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a50:	874e                	mv	a4,s3
    80003a52:	86a6                	mv	a3,s1
    80003a54:	8652                	mv	a2,s4
    80003a56:	4581                	li	a1,0
    80003a58:	854a                	mv	a0,s2
    80003a5a:	d8dff0ef          	jal	800037e6 <readi>
    80003a5e:	fd351ee3          	bne	a0,s3,80003a3a <dirlookup+0x46>
    if (de.inum == 0)
    80003a62:	fa045783          	lhu	a5,-96(s0)
    80003a66:	d3e5                	beqz	a5,80003a46 <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    80003a68:	85da                	mv	a1,s6
    80003a6a:	8556                	mv	a0,s5
    80003a6c:	f73ff0ef          	jal	800039de <namecmp>
    80003a70:	f979                	bnez	a0,80003a46 <dirlookup+0x52>
      if (poff)
    80003a72:	000b8463          	beqz	s7,80003a7a <dirlookup+0x86>
        *poff = off;
    80003a76:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003a7a:	fa045583          	lhu	a1,-96(s0)
    80003a7e:	00092503          	lw	a0,0(s2)
    80003a82:	f18ff0ef          	jal	8000319a <iget>
    80003a86:	a011                	j	80003a8a <dirlookup+0x96>
  return 0;
    80003a88:	4501                	li	a0,0
}
    80003a8a:	60e6                	ld	ra,88(sp)
    80003a8c:	6446                	ld	s0,80(sp)
    80003a8e:	64a6                	ld	s1,72(sp)
    80003a90:	6906                	ld	s2,64(sp)
    80003a92:	79e2                	ld	s3,56(sp)
    80003a94:	7a42                	ld	s4,48(sp)
    80003a96:	7aa2                	ld	s5,40(sp)
    80003a98:	7b02                	ld	s6,32(sp)
    80003a9a:	6be2                	ld	s7,24(sp)
    80003a9c:	6125                	addi	sp,sp,96
    80003a9e:	8082                	ret

0000000080003aa0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003aa0:	711d                	addi	sp,sp,-96
    80003aa2:	ec86                	sd	ra,88(sp)
    80003aa4:	e8a2                	sd	s0,80(sp)
    80003aa6:	e4a6                	sd	s1,72(sp)
    80003aa8:	e0ca                	sd	s2,64(sp)
    80003aaa:	fc4e                	sd	s3,56(sp)
    80003aac:	f852                	sd	s4,48(sp)
    80003aae:	f456                	sd	s5,40(sp)
    80003ab0:	f05a                	sd	s6,32(sp)
    80003ab2:	ec5e                	sd	s7,24(sp)
    80003ab4:	e862                	sd	s8,16(sp)
    80003ab6:	e466                	sd	s9,8(sp)
    80003ab8:	e06a                	sd	s10,0(sp)
    80003aba:	1080                	addi	s0,sp,96
    80003abc:	84aa                	mv	s1,a0
    80003abe:	8b2e                	mv	s6,a1
    80003ac0:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003ac2:	00054703          	lbu	a4,0(a0)
    80003ac6:	02f00793          	li	a5,47
    80003aca:	00f70f63          	beq	a4,a5,80003ae8 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003ace:	f91fd0ef          	jal	80001a5e <myproc>
    80003ad2:	15053503          	ld	a0,336(a0)
    80003ad6:	901ff0ef          	jal	800033d6 <idup>
    80003ada:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003adc:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    80003ae0:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003ae2:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003ae4:	4b85                	li	s7,1
    80003ae6:	a07d                	j	80003b94 <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    80003ae8:	4585                	li	a1,1
    80003aea:	852e                	mv	a0,a1
    80003aec:	eaeff0ef          	jal	8000319a <iget>
    80003af0:	8a2a                	mv	s4,a0
    80003af2:	b7ed                	j	80003adc <namex+0x3c>
      iunlockput(ip);
    80003af4:	8552                	mv	a0,s4
    80003af6:	b6bff0ef          	jal	80003660 <iunlockput>
      return 0;
    80003afa:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003afc:	8552                	mv	a0,s4
    80003afe:	60e6                	ld	ra,88(sp)
    80003b00:	6446                	ld	s0,80(sp)
    80003b02:	64a6                	ld	s1,72(sp)
    80003b04:	6906                	ld	s2,64(sp)
    80003b06:	79e2                	ld	s3,56(sp)
    80003b08:	7a42                	ld	s4,48(sp)
    80003b0a:	7aa2                	ld	s5,40(sp)
    80003b0c:	7b02                	ld	s6,32(sp)
    80003b0e:	6be2                	ld	s7,24(sp)
    80003b10:	6c42                	ld	s8,16(sp)
    80003b12:	6ca2                	ld	s9,8(sp)
    80003b14:	6d02                	ld	s10,0(sp)
    80003b16:	6125                	addi	sp,sp,96
    80003b18:	8082                	ret
      iunlockput(ip);
    80003b1a:	8552                	mv	a0,s4
    80003b1c:	b45ff0ef          	jal	80003660 <iunlockput>
      return 0;
    80003b20:	4a01                	li	s4,0
    80003b22:	bfe9                	j	80003afc <namex+0x5c>
      iunlock(ip);
    80003b24:	8552                	mv	a0,s4
    80003b26:	995ff0ef          	jal	800034ba <iunlock>
      return ip;
    80003b2a:	bfc9                	j	80003afc <namex+0x5c>
      iunlockput(ip);
    80003b2c:	8552                	mv	a0,s4
    80003b2e:	b33ff0ef          	jal	80003660 <iunlockput>
      return 0;
    80003b32:	8a4a                	mv	s4,s2
    80003b34:	b7e1                	j	80003afc <namex+0x5c>
  while (*path != '/' && *path != 0)
    80003b36:	8926                	mv	s2,s1
  len = path - s;
    80003b38:	4d01                	li	s10,0
    80003b3a:	4601                	li	a2,0
    memmove(name, s, len);
    80003b3c:	2601                	sext.w	a2,a2
    80003b3e:	85a6                	mv	a1,s1
    80003b40:	8556                	mv	a0,s5
    80003b42:	a82fd0ef          	jal	80000dc4 <memmove>
    name[len] = 0;
    80003b46:	9d56                	add	s10,s10,s5
    80003b48:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffdb908>
  while (*path == '/')
    80003b4c:	00094783          	lbu	a5,0(s2)
    80003b50:	09379b63          	bne	a5,s3,80003be6 <namex+0x146>
    80003b54:	84ca                	mv	s1,s2
    path++;
    80003b56:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003b58:	0004c783          	lbu	a5,0(s1)
    80003b5c:	ff378de3          	beq	a5,s3,80003b56 <namex+0xb6>
    ilock(ip);
    80003b60:	8552                	mv	a0,s4
    80003b62:	8abff0ef          	jal	8000340c <ilock>
    if (ip->type != T_DIR) {
    80003b66:	044a1783          	lh	a5,68(s4)
    80003b6a:	f97795e3          	bne	a5,s7,80003af4 <namex+0x54>
    if (ip->nlink == 0) {
    80003b6e:	04aa1783          	lh	a5,74(s4)
    80003b72:	d7c5                	beqz	a5,80003b1a <namex+0x7a>
    if (nameiparent && *path == '\0') {
    80003b74:	000b0563          	beqz	s6,80003b7e <namex+0xde>
    80003b78:	0004c783          	lbu	a5,0(s1)
    80003b7c:	d7c5                	beqz	a5,80003b24 <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003b7e:	4601                	li	a2,0
    80003b80:	85d6                	mv	a1,s5
    80003b82:	8552                	mv	a0,s4
    80003b84:	e71ff0ef          	jal	800039f4 <dirlookup>
    80003b88:	892a                	mv	s2,a0
    80003b8a:	d14d                	beqz	a0,80003b2c <namex+0x8c>
    iunlockput(ip);
    80003b8c:	8552                	mv	a0,s4
    80003b8e:	ad3ff0ef          	jal	80003660 <iunlockput>
    ip = next;
    80003b92:	8a4a                	mv	s4,s2
  while (*path == '/')
    80003b94:	0004c783          	lbu	a5,0(s1)
    80003b98:	01379763          	bne	a5,s3,80003ba6 <namex+0x106>
    path++;
    80003b9c:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003b9e:	0004c783          	lbu	a5,0(s1)
    80003ba2:	ff378de3          	beq	a5,s3,80003b9c <namex+0xfc>
  if (*path == 0)
    80003ba6:	c7a1                	beqz	a5,80003bee <namex+0x14e>
  while (*path != '/' && *path != 0)
    80003ba8:	0004c783          	lbu	a5,0(s1)
    80003bac:	fd178713          	addi	a4,a5,-47
    80003bb0:	d359                	beqz	a4,80003b36 <namex+0x96>
    80003bb2:	d3d1                	beqz	a5,80003b36 <namex+0x96>
    80003bb4:	8926                	mv	s2,s1
    path++;
    80003bb6:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    80003bb8:	00094783          	lbu	a5,0(s2)
    80003bbc:	fd178713          	addi	a4,a5,-47
    80003bc0:	c311                	beqz	a4,80003bc4 <namex+0x124>
    80003bc2:	fbf5                	bnez	a5,80003bb6 <namex+0x116>
  len = path - s;
    80003bc4:	40990633          	sub	a2,s2,s1
    80003bc8:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80003bcc:	f7ac58e3          	bge	s8,s10,80003b3c <namex+0x9c>
    memmove(name, s, DIRSIZ);
    80003bd0:	8666                	mv	a2,s9
    80003bd2:	85a6                	mv	a1,s1
    80003bd4:	8556                	mv	a0,s5
    80003bd6:	9eefd0ef          	jal	80000dc4 <memmove>
  while (*path == '/')
    80003bda:	00094783          	lbu	a5,0(s2)
    80003bde:	84ca                	mv	s1,s2
    80003be0:	f7378be3          	beq	a5,s3,80003b56 <namex+0xb6>
    80003be4:	bfb5                	j	80003b60 <namex+0xc0>
  while ((path = skipelem(path, name)) != 0) {
    80003be6:	00090463          	beqz	s2,80003bee <namex+0x14e>
    80003bea:	84ca                	mv	s1,s2
    80003bec:	bf95                	j	80003b60 <namex+0xc0>
  if (nameiparent) {
    80003bee:	f00b07e3          	beqz	s6,80003afc <namex+0x5c>
    iput(ip);
    80003bf2:	8552                	mv	a0,s4
    80003bf4:	99bff0ef          	jal	8000358e <iput>
    return 0;
    80003bf8:	4a01                	li	s4,0
    80003bfa:	b709                	j	80003afc <namex+0x5c>

0000000080003bfc <dirlink>:
{
    80003bfc:	715d                	addi	sp,sp,-80
    80003bfe:	e486                	sd	ra,72(sp)
    80003c00:	e0a2                	sd	s0,64(sp)
    80003c02:	f84a                	sd	s2,48(sp)
    80003c04:	ec56                	sd	s5,24(sp)
    80003c06:	e85a                	sd	s6,16(sp)
    80003c08:	0880                	addi	s0,sp,80
    80003c0a:	892a                	mv	s2,a0
    80003c0c:	8aae                	mv	s5,a1
    80003c0e:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003c10:	4601                	li	a2,0
    80003c12:	de3ff0ef          	jal	800039f4 <dirlookup>
    80003c16:	ed1d                	bnez	a0,80003c54 <dirlink+0x58>
    80003c18:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003c1a:	04c92483          	lw	s1,76(s2)
    80003c1e:	c4b9                	beqz	s1,80003c6c <dirlink+0x70>
    80003c20:	f44e                	sd	s3,40(sp)
    80003c22:	f052                	sd	s4,32(sp)
    80003c24:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c26:	fb040a13          	addi	s4,s0,-80
    80003c2a:	49c1                	li	s3,16
    80003c2c:	874e                	mv	a4,s3
    80003c2e:	86a6                	mv	a3,s1
    80003c30:	8652                	mv	a2,s4
    80003c32:	4581                	li	a1,0
    80003c34:	854a                	mv	a0,s2
    80003c36:	bb1ff0ef          	jal	800037e6 <readi>
    80003c3a:	03351163          	bne	a0,s3,80003c5c <dirlink+0x60>
    if (de.inum == 0)
    80003c3e:	fb045783          	lhu	a5,-80(s0)
    80003c42:	c39d                	beqz	a5,80003c68 <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003c44:	24c1                	addiw	s1,s1,16
    80003c46:	04c92783          	lw	a5,76(s2)
    80003c4a:	fef4e1e3          	bltu	s1,a5,80003c2c <dirlink+0x30>
    80003c4e:	79a2                	ld	s3,40(sp)
    80003c50:	7a02                	ld	s4,32(sp)
    80003c52:	a829                	j	80003c6c <dirlink+0x70>
    iput(ip);
    80003c54:	93bff0ef          	jal	8000358e <iput>
    return -1;
    80003c58:	557d                	li	a0,-1
    80003c5a:	a83d                	j	80003c98 <dirlink+0x9c>
      panic("dirlink read");
    80003c5c:	00004517          	auipc	a0,0x4
    80003c60:	8d450513          	addi	a0,a0,-1836 # 80007530 <etext+0x530>
    80003c64:	bd1fc0ef          	jal	80000834 <panic>
    80003c68:	79a2                	ld	s3,40(sp)
    80003c6a:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003c6c:	4639                	li	a2,14
    80003c6e:	85d6                	mv	a1,s5
    80003c70:	fb240513          	addi	a0,s0,-78
    80003c74:	9fefd0ef          	jal	80000e72 <strncpy>
  de.inum = inum;
    80003c78:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c7c:	4741                	li	a4,16
    80003c7e:	86a6                	mv	a3,s1
    80003c80:	fb040613          	addi	a2,s0,-80
    80003c84:	4581                	li	a1,0
    80003c86:	854a                	mv	a0,s2
    80003c88:	c51ff0ef          	jal	800038d8 <writei>
    80003c8c:	1541                	addi	a0,a0,-16
    80003c8e:	00a03533          	snez	a0,a0
    80003c92:	40a0053b          	negw	a0,a0
    80003c96:	74e2                	ld	s1,56(sp)
}
    80003c98:	60a6                	ld	ra,72(sp)
    80003c9a:	6406                	ld	s0,64(sp)
    80003c9c:	7942                	ld	s2,48(sp)
    80003c9e:	6ae2                	ld	s5,24(sp)
    80003ca0:	6b42                	ld	s6,16(sp)
    80003ca2:	6161                	addi	sp,sp,80
    80003ca4:	8082                	ret

0000000080003ca6 <namei>:

struct inode *
namei(char *path)
{
    80003ca6:	1101                	addi	sp,sp,-32
    80003ca8:	ec06                	sd	ra,24(sp)
    80003caa:	e822                	sd	s0,16(sp)
    80003cac:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003cae:	fe040613          	addi	a2,s0,-32
    80003cb2:	4581                	li	a1,0
    80003cb4:	dedff0ef          	jal	80003aa0 <namex>
}
    80003cb8:	60e2                	ld	ra,24(sp)
    80003cba:	6442                	ld	s0,16(sp)
    80003cbc:	6105                	addi	sp,sp,32
    80003cbe:	8082                	ret

0000000080003cc0 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003cc0:	1141                	addi	sp,sp,-16
    80003cc2:	e406                	sd	ra,8(sp)
    80003cc4:	e022                	sd	s0,0(sp)
    80003cc6:	0800                	addi	s0,sp,16
    80003cc8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003cca:	4585                	li	a1,1
    80003ccc:	dd5ff0ef          	jal	80003aa0 <namex>
}
    80003cd0:	60a2                	ld	ra,8(sp)
    80003cd2:	6402                	ld	s0,0(sp)
    80003cd4:	0141                	addi	sp,sp,16
    80003cd6:	8082                	ret

0000000080003cd8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003cd8:	1101                	addi	sp,sp,-32
    80003cda:	ec06                	sd	ra,24(sp)
    80003cdc:	e822                	sd	s0,16(sp)
    80003cde:	e426                	sd	s1,8(sp)
    80003ce0:	e04a                	sd	s2,0(sp)
    80003ce2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003ce4:	0001e917          	auipc	s2,0x1e
    80003ce8:	7d490913          	addi	s2,s2,2004 # 800224b8 <log>
    80003cec:	01892583          	lw	a1,24(s2)
    80003cf0:	02492503          	lw	a0,36(s2)
    80003cf4:	880ff0ef          	jal	80002d74 <bread>
    80003cf8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003cfa:	02c92603          	lw	a2,44(s2)
    80003cfe:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003d00:	00c05f63          	blez	a2,80003d1e <write_head+0x46>
    80003d04:	0001e717          	auipc	a4,0x1e
    80003d08:	7e470713          	addi	a4,a4,2020 # 800224e8 <log+0x30>
    80003d0c:	87aa                	mv	a5,a0
    80003d0e:	060a                	slli	a2,a2,0x2
    80003d10:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003d12:	4314                	lw	a3,0(a4)
    80003d14:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003d16:	0711                	addi	a4,a4,4
    80003d18:	0791                	addi	a5,a5,4
    80003d1a:	fec79ce3          	bne	a5,a2,80003d12 <write_head+0x3a>
  }
  bwrite(buf);
    80003d1e:	8526                	mv	a0,s1
    80003d20:	92aff0ef          	jal	80002e4a <bwrite>
  brelse(buf);
    80003d24:	8526                	mv	a0,s1
    80003d26:	956ff0ef          	jal	80002e7c <brelse>
}
    80003d2a:	60e2                	ld	ra,24(sp)
    80003d2c:	6442                	ld	s0,16(sp)
    80003d2e:	64a2                	ld	s1,8(sp)
    80003d30:	6902                	ld	s2,0(sp)
    80003d32:	6105                	addi	sp,sp,32
    80003d34:	8082                	ret

0000000080003d36 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d36:	0001e797          	auipc	a5,0x1e
    80003d3a:	7ae7a783          	lw	a5,1966(a5) # 800224e4 <log+0x2c>
    80003d3e:	0cf05163          	blez	a5,80003e00 <install_trans+0xca>
{
    80003d42:	715d                	addi	sp,sp,-80
    80003d44:	e486                	sd	ra,72(sp)
    80003d46:	e0a2                	sd	s0,64(sp)
    80003d48:	fc26                	sd	s1,56(sp)
    80003d4a:	f84a                	sd	s2,48(sp)
    80003d4c:	f44e                	sd	s3,40(sp)
    80003d4e:	f052                	sd	s4,32(sp)
    80003d50:	ec56                	sd	s5,24(sp)
    80003d52:	e85a                	sd	s6,16(sp)
    80003d54:	e45e                	sd	s7,8(sp)
    80003d56:	e062                	sd	s8,0(sp)
    80003d58:	0880                	addi	s0,sp,80
    80003d5a:	8b2a                	mv	s6,a0
    80003d5c:	0001ea97          	auipc	s5,0x1e
    80003d60:	78ca8a93          	addi	s5,s5,1932 # 800224e8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d64:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d66:	00003c17          	auipc	s8,0x3
    80003d6a:	7dac0c13          	addi	s8,s8,2010 # 80007540 <etext+0x540>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003d6e:	0001ea17          	auipc	s4,0x1e
    80003d72:	74aa0a13          	addi	s4,s4,1866 # 800224b8 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003d76:	40000b93          	li	s7,1024
    80003d7a:	a025                	j	80003da2 <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d7c:	000aa603          	lw	a2,0(s5)
    80003d80:	85ce                	mv	a1,s3
    80003d82:	8562                	mv	a0,s8
    80003d84:	f86fc0ef          	jal	8000050a <printk>
    80003d88:	a839                	j	80003da6 <install_trans+0x70>
    brelse(lbuf);
    80003d8a:	854a                	mv	a0,s2
    80003d8c:	8f0ff0ef          	jal	80002e7c <brelse>
    brelse(dbuf);
    80003d90:	8526                	mv	a0,s1
    80003d92:	8eaff0ef          	jal	80002e7c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d96:	2985                	addiw	s3,s3,1
    80003d98:	0a91                	addi	s5,s5,4
    80003d9a:	02ca2783          	lw	a5,44(s4)
    80003d9e:	04f9d563          	bge	s3,a5,80003de8 <install_trans+0xb2>
    if (recovering) {
    80003da2:	fc0b1de3          	bnez	s6,80003d7c <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003da6:	018a2583          	lw	a1,24(s4)
    80003daa:	013585bb          	addw	a1,a1,s3
    80003dae:	2585                	addiw	a1,a1,1
    80003db0:	024a2503          	lw	a0,36(s4)
    80003db4:	fc1fe0ef          	jal	80002d74 <bread>
    80003db8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003dba:	000aa583          	lw	a1,0(s5)
    80003dbe:	024a2503          	lw	a0,36(s4)
    80003dc2:	fb3fe0ef          	jal	80002d74 <bread>
    80003dc6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003dc8:	865e                	mv	a2,s7
    80003dca:	05890593          	addi	a1,s2,88
    80003dce:	05850513          	addi	a0,a0,88
    80003dd2:	ff3fc0ef          	jal	80000dc4 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003dd6:	8526                	mv	a0,s1
    80003dd8:	872ff0ef          	jal	80002e4a <bwrite>
    if (recovering == 0)
    80003ddc:	fa0b17e3          	bnez	s6,80003d8a <install_trans+0x54>
      bunpin(dbuf);
    80003de0:	8526                	mv	a0,s1
    80003de2:	952ff0ef          	jal	80002f34 <bunpin>
    80003de6:	b755                	j	80003d8a <install_trans+0x54>
}
    80003de8:	60a6                	ld	ra,72(sp)
    80003dea:	6406                	ld	s0,64(sp)
    80003dec:	74e2                	ld	s1,56(sp)
    80003dee:	7942                	ld	s2,48(sp)
    80003df0:	79a2                	ld	s3,40(sp)
    80003df2:	7a02                	ld	s4,32(sp)
    80003df4:	6ae2                	ld	s5,24(sp)
    80003df6:	6b42                	ld	s6,16(sp)
    80003df8:	6ba2                	ld	s7,8(sp)
    80003dfa:	6c02                	ld	s8,0(sp)
    80003dfc:	6161                	addi	sp,sp,80
    80003dfe:	8082                	ret
    80003e00:	8082                	ret

0000000080003e02 <initlog>:
{
    80003e02:	7179                	addi	sp,sp,-48
    80003e04:	f406                	sd	ra,40(sp)
    80003e06:	f022                	sd	s0,32(sp)
    80003e08:	ec26                	sd	s1,24(sp)
    80003e0a:	e84a                	sd	s2,16(sp)
    80003e0c:	e44e                	sd	s3,8(sp)
    80003e0e:	1800                	addi	s0,sp,48
    80003e10:	84aa                	mv	s1,a0
    80003e12:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003e14:	0001e917          	auipc	s2,0x1e
    80003e18:	6a490913          	addi	s2,s2,1700 # 800224b8 <log>
    80003e1c:	00003597          	auipc	a1,0x3
    80003e20:	74458593          	addi	a1,a1,1860 # 80007560 <etext+0x560>
    80003e24:	854a                	mv	a0,s2
    80003e26:	dfffc0ef          	jal	80000c24 <initlock>
  log.start = sb->logstart;
    80003e2a:	0149a583          	lw	a1,20(s3)
    80003e2e:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003e32:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003e36:	8526                	mv	a0,s1
    80003e38:	f3dfe0ef          	jal	80002d74 <bread>
  log.lh.n = lh->n;
    80003e3c:	4d30                	lw	a2,88(a0)
    80003e3e:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003e42:	00c05f63          	blez	a2,80003e60 <initlog+0x5e>
    80003e46:	87aa                	mv	a5,a0
    80003e48:	0001e717          	auipc	a4,0x1e
    80003e4c:	6a070713          	addi	a4,a4,1696 # 800224e8 <log+0x30>
    80003e50:	060a                	slli	a2,a2,0x2
    80003e52:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003e54:	4ff4                	lw	a3,92(a5)
    80003e56:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e58:	0791                	addi	a5,a5,4
    80003e5a:	0711                	addi	a4,a4,4
    80003e5c:	fec79ce3          	bne	a5,a2,80003e54 <initlog+0x52>
  brelse(buf);
    80003e60:	81cff0ef          	jal	80002e7c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003e64:	4505                	li	a0,1
    80003e66:	ed1ff0ef          	jal	80003d36 <install_trans>
  log.lh.n = 0;
    80003e6a:	0001e797          	auipc	a5,0x1e
    80003e6e:	6607ad23          	sw	zero,1658(a5) # 800224e4 <log+0x2c>
  write_head(); // clear the log
    80003e72:	e67ff0ef          	jal	80003cd8 <write_head>
}
    80003e76:	70a2                	ld	ra,40(sp)
    80003e78:	7402                	ld	s0,32(sp)
    80003e7a:	64e2                	ld	s1,24(sp)
    80003e7c:	6942                	ld	s2,16(sp)
    80003e7e:	69a2                	ld	s3,8(sp)
    80003e80:	6145                	addi	sp,sp,48
    80003e82:	8082                	ret

0000000080003e84 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003e84:	1101                	addi	sp,sp,-32
    80003e86:	ec06                	sd	ra,24(sp)
    80003e88:	e822                	sd	s0,16(sp)
    80003e8a:	e426                	sd	s1,8(sp)
    80003e8c:	e04a                	sd	s2,0(sp)
    80003e8e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003e90:	0001e517          	auipc	a0,0x1e
    80003e94:	62850513          	addi	a0,a0,1576 # 800224b8 <log>
    80003e98:	e0dfc0ef          	jal	80000ca4 <acquire>
  while (1) {
    if (log.committing) {
    80003e9c:	0001e497          	auipc	s1,0x1e
    80003ea0:	61c48493          	addi	s1,s1,1564 # 800224b8 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003ea4:	4979                	li	s2,30
    80003ea6:	a821                	j	80003ebe <begin_op+0x3a>
      sleep_prepare(&log);
    80003ea8:	8526                	mv	a0,s1
    80003eaa:	9befe0ef          	jal	80002068 <sleep_prepare>
      release(&log.lock);
    80003eae:	8526                	mv	a0,s1
    80003eb0:	e7dfc0ef          	jal	80000d2c <release>
      sleep();
    80003eb4:	9f0fe0ef          	jal	800020a4 <sleep>
      acquire(&log.lock);
    80003eb8:	8526                	mv	a0,s1
    80003eba:	debfc0ef          	jal	80000ca4 <acquire>
    if (log.committing) {
    80003ebe:	509c                	lw	a5,32(s1)
    80003ec0:	f7e5                	bnez	a5,80003ea8 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003ec2:	4cd8                	lw	a4,28(s1)
    80003ec4:	2705                	addiw	a4,a4,1
    80003ec6:	0027179b          	slliw	a5,a4,0x2
    80003eca:	9fb9                	addw	a5,a5,a4
    80003ecc:	0017979b          	slliw	a5,a5,0x1
    80003ed0:	54d4                	lw	a3,44(s1)
    80003ed2:	9fb5                	addw	a5,a5,a3
    80003ed4:	00f95e63          	bge	s2,a5,80003ef0 <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003ed8:	8526                	mv	a0,s1
    80003eda:	98efe0ef          	jal	80002068 <sleep_prepare>
      release(&log.lock);
    80003ede:	8526                	mv	a0,s1
    80003ee0:	e4dfc0ef          	jal	80000d2c <release>
      sleep();
    80003ee4:	9c0fe0ef          	jal	800020a4 <sleep>
      acquire(&log.lock);
    80003ee8:	8526                	mv	a0,s1
    80003eea:	dbbfc0ef          	jal	80000ca4 <acquire>
    80003eee:	bfc1                	j	80003ebe <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003ef0:	0001e797          	auipc	a5,0x1e
    80003ef4:	5ee7a223          	sw	a4,1508(a5) # 800224d4 <log+0x1c>
      release(&log.lock);
    80003ef8:	0001e517          	auipc	a0,0x1e
    80003efc:	5c050513          	addi	a0,a0,1472 # 800224b8 <log>
    80003f00:	e2dfc0ef          	jal	80000d2c <release>
      break;
    }
  }
}
    80003f04:	60e2                	ld	ra,24(sp)
    80003f06:	6442                	ld	s0,16(sp)
    80003f08:	64a2                	ld	s1,8(sp)
    80003f0a:	6902                	ld	s2,0(sp)
    80003f0c:	6105                	addi	sp,sp,32
    80003f0e:	8082                	ret

0000000080003f10 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003f10:	7139                	addi	sp,sp,-64
    80003f12:	fc06                	sd	ra,56(sp)
    80003f14:	f822                	sd	s0,48(sp)
    80003f16:	f426                	sd	s1,40(sp)
    80003f18:	f04a                	sd	s2,32(sp)
    80003f1a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003f1c:	0001e497          	auipc	s1,0x1e
    80003f20:	59c48493          	addi	s1,s1,1436 # 800224b8 <log>
    80003f24:	8526                	mv	a0,s1
    80003f26:	d7ffc0ef          	jal	80000ca4 <acquire>
  log.outstanding -= 1;
    80003f2a:	4cdc                	lw	a5,28(s1)
    80003f2c:	37fd                	addiw	a5,a5,-1
    80003f2e:	893e                	mv	s2,a5
    80003f30:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003f32:	509c                	lw	a5,32(s1)
    80003f34:	e3b1                	bnez	a5,80003f78 <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003f36:	04091a63          	bnez	s2,80003f8a <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    80003f3a:	0001e497          	auipc	s1,0x1e
    80003f3e:	57e48493          	addi	s1,s1,1406 # 800224b8 <log>
    80003f42:	4785                	li	a5,1
    80003f44:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003f46:	8526                	mv	a0,s1
    80003f48:	de5fc0ef          	jal	80000d2c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003f4c:	54dc                	lw	a5,44(s1)
    80003f4e:	06f04063          	bgtz	a5,80003fae <end_op+0x9e>
    acquire(&log.lock);
    80003f52:	0001e497          	auipc	s1,0x1e
    80003f56:	56648493          	addi	s1,s1,1382 # 800224b8 <log>
    80003f5a:	8526                	mv	a0,s1
    80003f5c:	d49fc0ef          	jal	80000ca4 <acquire>
    log.committing = 0;
    80003f60:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003f64:	549c                	lw	a5,40(s1)
    80003f66:	2785                	addiw	a5,a5,1
    80003f68:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003f6a:	8526                	mv	a0,s1
    80003f6c:	968fe0ef          	jal	800020d4 <wakeup>
    release(&log.lock);
    80003f70:	8526                	mv	a0,s1
    80003f72:	dbbfc0ef          	jal	80000d2c <release>
}
    80003f76:	a035                	j	80003fa2 <end_op+0x92>
    80003f78:	ec4e                	sd	s3,24(sp)
    80003f7a:	e852                	sd	s4,16(sp)
    80003f7c:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003f7e:	00003517          	auipc	a0,0x3
    80003f82:	5ea50513          	addi	a0,a0,1514 # 80007568 <etext+0x568>
    80003f86:	8affc0ef          	jal	80000834 <panic>
    wakeup(&log);
    80003f8a:	0001e517          	auipc	a0,0x1e
    80003f8e:	52e50513          	addi	a0,a0,1326 # 800224b8 <log>
    80003f92:	942fe0ef          	jal	800020d4 <wakeup>
  release(&log.lock);
    80003f96:	0001e517          	auipc	a0,0x1e
    80003f9a:	52250513          	addi	a0,a0,1314 # 800224b8 <log>
    80003f9e:	d8ffc0ef          	jal	80000d2c <release>
}
    80003fa2:	70e2                	ld	ra,56(sp)
    80003fa4:	7442                	ld	s0,48(sp)
    80003fa6:	74a2                	ld	s1,40(sp)
    80003fa8:	7902                	ld	s2,32(sp)
    80003faa:	6121                	addi	sp,sp,64
    80003fac:	8082                	ret
    80003fae:	ec4e                	sd	s3,24(sp)
    80003fb0:	e852                	sd	s4,16(sp)
    80003fb2:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fb4:	0001ea97          	auipc	s5,0x1e
    80003fb8:	534a8a93          	addi	s5,s5,1332 # 800224e8 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003fbc:	0001ea17          	auipc	s4,0x1e
    80003fc0:	4fca0a13          	addi	s4,s4,1276 # 800224b8 <log>
    80003fc4:	018a2583          	lw	a1,24(s4)
    80003fc8:	012585bb          	addw	a1,a1,s2
    80003fcc:	2585                	addiw	a1,a1,1
    80003fce:	024a2503          	lw	a0,36(s4)
    80003fd2:	da3fe0ef          	jal	80002d74 <bread>
    80003fd6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003fd8:	000aa583          	lw	a1,0(s5)
    80003fdc:	024a2503          	lw	a0,36(s4)
    80003fe0:	d95fe0ef          	jal	80002d74 <bread>
    80003fe4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003fe6:	40000613          	li	a2,1024
    80003fea:	05850593          	addi	a1,a0,88
    80003fee:	05848513          	addi	a0,s1,88
    80003ff2:	dd3fc0ef          	jal	80000dc4 <memmove>
    bwrite(to); // write the log
    80003ff6:	8526                	mv	a0,s1
    80003ff8:	e53fe0ef          	jal	80002e4a <bwrite>
    brelse(from);
    80003ffc:	854e                	mv	a0,s3
    80003ffe:	e7ffe0ef          	jal	80002e7c <brelse>
    brelse(to);
    80004002:	8526                	mv	a0,s1
    80004004:	e79fe0ef          	jal	80002e7c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004008:	2905                	addiw	s2,s2,1
    8000400a:	0a91                	addi	s5,s5,4
    8000400c:	02ca2783          	lw	a5,44(s4)
    80004010:	faf94ae3          	blt	s2,a5,80003fc4 <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80004014:	cc5ff0ef          	jal	80003cd8 <write_head>
    install_trans(0); // Now install writes to home locations
    80004018:	4501                	li	a0,0
    8000401a:	d1dff0ef          	jal	80003d36 <install_trans>
    log.lh.n = 0;
    8000401e:	0001e797          	auipc	a5,0x1e
    80004022:	4c07a323          	sw	zero,1222(a5) # 800224e4 <log+0x2c>
    write_head(); // Erase the transaction from the log
    80004026:	cb3ff0ef          	jal	80003cd8 <write_head>
    8000402a:	69e2                	ld	s3,24(sp)
    8000402c:	6a42                	ld	s4,16(sp)
    8000402e:	6aa2                	ld	s5,8(sp)
    80004030:	b70d                	j	80003f52 <end_op+0x42>

0000000080004032 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004032:	1101                	addi	sp,sp,-32
    80004034:	ec06                	sd	ra,24(sp)
    80004036:	e822                	sd	s0,16(sp)
    80004038:	e426                	sd	s1,8(sp)
    8000403a:	1000                	addi	s0,sp,32
    8000403c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000403e:	0001e517          	auipc	a0,0x1e
    80004042:	47a50513          	addi	a0,a0,1146 # 800224b8 <log>
    80004046:	c5ffc0ef          	jal	80000ca4 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    8000404a:	0001e617          	auipc	a2,0x1e
    8000404e:	49a62603          	lw	a2,1178(a2) # 800224e4 <log+0x2c>
    80004052:	47f5                	li	a5,29
    80004054:	04c7cd63          	blt	a5,a2,800040ae <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004058:	0001e797          	auipc	a5,0x1e
    8000405c:	47c7a783          	lw	a5,1148(a5) # 800224d4 <log+0x1c>
    80004060:	04f05d63          	blez	a5,800040ba <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004064:	4781                	li	a5,0
    80004066:	06c05063          	blez	a2,800040c6 <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    8000406a:	44cc                	lw	a1,12(s1)
    8000406c:	0001e717          	auipc	a4,0x1e
    80004070:	47c70713          	addi	a4,a4,1148 # 800224e8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004074:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80004076:	4314                	lw	a3,0(a4)
    80004078:	04b68763          	beq	a3,a1,800040c6 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    8000407c:	2785                	addiw	a5,a5,1
    8000407e:	0711                	addi	a4,a4,4
    80004080:	fef61be3          	bne	a2,a5,80004076 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004084:	060a                	slli	a2,a2,0x2
    80004086:	02060613          	addi	a2,a2,32
    8000408a:	0001e797          	auipc	a5,0x1e
    8000408e:	42e78793          	addi	a5,a5,1070 # 800224b8 <log>
    80004092:	97b2                	add	a5,a5,a2
    80004094:	44d8                	lw	a4,12(s1)
    80004096:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80004098:	8526                	mv	a0,s1
    8000409a:	e67fe0ef          	jal	80002f00 <bpin>
    log.lh.n++;
    8000409e:	0001e717          	auipc	a4,0x1e
    800040a2:	41a70713          	addi	a4,a4,1050 # 800224b8 <log>
    800040a6:	575c                	lw	a5,44(a4)
    800040a8:	2785                	addiw	a5,a5,1
    800040aa:	d75c                	sw	a5,44(a4)
    800040ac:	a815                	j	800040e0 <log_write+0xae>
    panic("too big a transaction");
    800040ae:	00003517          	auipc	a0,0x3
    800040b2:	4ca50513          	addi	a0,a0,1226 # 80007578 <etext+0x578>
    800040b6:	f7efc0ef          	jal	80000834 <panic>
    panic("log_write outside of trans");
    800040ba:	00003517          	auipc	a0,0x3
    800040be:	4d650513          	addi	a0,a0,1238 # 80007590 <etext+0x590>
    800040c2:	f72fc0ef          	jal	80000834 <panic>
  log.lh.block[i] = b->blockno;
    800040c6:	00279693          	slli	a3,a5,0x2
    800040ca:	02068693          	addi	a3,a3,32
    800040ce:	0001e717          	auipc	a4,0x1e
    800040d2:	3ea70713          	addi	a4,a4,1002 # 800224b8 <log>
    800040d6:	9736                	add	a4,a4,a3
    800040d8:	44d4                	lw	a3,12(s1)
    800040da:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    800040dc:	faf60ee3          	beq	a2,a5,80004098 <log_write+0x66>
  }
  release(&log.lock);
    800040e0:	0001e517          	auipc	a0,0x1e
    800040e4:	3d850513          	addi	a0,a0,984 # 800224b8 <log>
    800040e8:	c45fc0ef          	jal	80000d2c <release>
}
    800040ec:	60e2                	ld	ra,24(sp)
    800040ee:	6442                	ld	s0,16(sp)
    800040f0:	64a2                	ld	s1,8(sp)
    800040f2:	6105                	addi	sp,sp,32
    800040f4:	8082                	ret

00000000800040f6 <sys_sync>:

uint64
sys_sync(void)
{
    800040f6:	1101                	addi	sp,sp,-32
    800040f8:	ec06                	sd	ra,24(sp)
    800040fa:	e822                	sd	s0,16(sp)
    800040fc:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800040fe:	0001e517          	auipc	a0,0x1e
    80004102:	3ba50513          	addi	a0,a0,954 # 800224b8 <log>
    80004106:	b9ffc0ef          	jal	80000ca4 <acquire>
  if (log.committing || log.outstanding > 0) {
    8000410a:	0001e797          	auipc	a5,0x1e
    8000410e:	3ce7a783          	lw	a5,974(a5) # 800224d8 <log+0x20>
    80004112:	e799                	bnez	a5,80004120 <sys_sync+0x2a>
    80004114:	0001e797          	auipc	a5,0x1e
    80004118:	3c07a783          	lw	a5,960(a5) # 800224d4 <log+0x1c>
    8000411c:	02f05c63          	blez	a5,80004154 <sys_sync+0x5e>
    80004120:	e426                	sd	s1,8(sp)
    80004122:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    80004124:	0001e917          	auipc	s2,0x1e
    80004128:	3bc92903          	lw	s2,956(s2) # 800224e0 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    8000412c:	0001e497          	auipc	s1,0x1e
    80004130:	38c48493          	addi	s1,s1,908 # 800224b8 <log>
    80004134:	8526                	mv	a0,s1
    80004136:	f33fd0ef          	jal	80002068 <sleep_prepare>
      release(&log.lock);
    8000413a:	8526                	mv	a0,s1
    8000413c:	bf1fc0ef          	jal	80000d2c <release>
      sleep();
    80004140:	f65fd0ef          	jal	800020a4 <sleep>
      acquire(&log.lock);
    80004144:	8526                	mv	a0,s1
    80004146:	b5ffc0ef          	jal	80000ca4 <acquire>
    while (log.ncommit < n) {
    8000414a:	549c                	lw	a5,40(s1)
    8000414c:	fef954e3          	bge	s2,a5,80004134 <sys_sync+0x3e>
    80004150:	64a2                	ld	s1,8(sp)
    80004152:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    80004154:	0001e517          	auipc	a0,0x1e
    80004158:	36450513          	addi	a0,a0,868 # 800224b8 <log>
    8000415c:	bd1fc0ef          	jal	80000d2c <release>
  return 0;
}
    80004160:	4501                	li	a0,0
    80004162:	60e2                	ld	ra,24(sp)
    80004164:	6442                	ld	s0,16(sp)
    80004166:	6105                	addi	sp,sp,32
    80004168:	8082                	ret

000000008000416a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000416a:	1101                	addi	sp,sp,-32
    8000416c:	ec06                	sd	ra,24(sp)
    8000416e:	e822                	sd	s0,16(sp)
    80004170:	e426                	sd	s1,8(sp)
    80004172:	e04a                	sd	s2,0(sp)
    80004174:	1000                	addi	s0,sp,32
    80004176:	84aa                	mv	s1,a0
    80004178:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000417a:	00003597          	auipc	a1,0x3
    8000417e:	43658593          	addi	a1,a1,1078 # 800075b0 <etext+0x5b0>
    80004182:	0521                	addi	a0,a0,8
    80004184:	aa1fc0ef          	jal	80000c24 <initlock>
  lk->name = name;
    80004188:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000418c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004190:	0204a423          	sw	zero,40(s1)
}
    80004194:	60e2                	ld	ra,24(sp)
    80004196:	6442                	ld	s0,16(sp)
    80004198:	64a2                	ld	s1,8(sp)
    8000419a:	6902                	ld	s2,0(sp)
    8000419c:	6105                	addi	sp,sp,32
    8000419e:	8082                	ret

00000000800041a0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800041a0:	1101                	addi	sp,sp,-32
    800041a2:	ec06                	sd	ra,24(sp)
    800041a4:	e822                	sd	s0,16(sp)
    800041a6:	e426                	sd	s1,8(sp)
    800041a8:	e04a                	sd	s2,0(sp)
    800041aa:	1000                	addi	s0,sp,32
    800041ac:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800041ae:	00850913          	addi	s2,a0,8
    800041b2:	854a                	mv	a0,s2
    800041b4:	af1fc0ef          	jal	80000ca4 <acquire>
  while (lk->locked) {
    800041b8:	409c                	lw	a5,0(s1)
    800041ba:	cf91                	beqz	a5,800041d6 <acquiresleep+0x36>
    sleep_prepare(lk);
    800041bc:	8526                	mv	a0,s1
    800041be:	eabfd0ef          	jal	80002068 <sleep_prepare>
    release(&lk->lk);
    800041c2:	854a                	mv	a0,s2
    800041c4:	b69fc0ef          	jal	80000d2c <release>
    sleep();
    800041c8:	eddfd0ef          	jal	800020a4 <sleep>
    acquire(&lk->lk);
    800041cc:	854a                	mv	a0,s2
    800041ce:	ad7fc0ef          	jal	80000ca4 <acquire>
  while (lk->locked) {
    800041d2:	409c                	lw	a5,0(s1)
    800041d4:	f7e5                	bnez	a5,800041bc <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800041d6:	4785                	li	a5,1
    800041d8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800041da:	885fd0ef          	jal	80001a5e <myproc>
    800041de:	591c                	lw	a5,48(a0)
    800041e0:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800041e2:	854a                	mv	a0,s2
    800041e4:	b49fc0ef          	jal	80000d2c <release>
}
    800041e8:	60e2                	ld	ra,24(sp)
    800041ea:	6442                	ld	s0,16(sp)
    800041ec:	64a2                	ld	s1,8(sp)
    800041ee:	6902                	ld	s2,0(sp)
    800041f0:	6105                	addi	sp,sp,32
    800041f2:	8082                	ret

00000000800041f4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800041f4:	1101                	addi	sp,sp,-32
    800041f6:	ec06                	sd	ra,24(sp)
    800041f8:	e822                	sd	s0,16(sp)
    800041fa:	e426                	sd	s1,8(sp)
    800041fc:	e04a                	sd	s2,0(sp)
    800041fe:	1000                	addi	s0,sp,32
    80004200:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004202:	00850913          	addi	s2,a0,8
    80004206:	854a                	mv	a0,s2
    80004208:	a9dfc0ef          	jal	80000ca4 <acquire>
  lk->locked = 0;
    8000420c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004210:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004214:	8526                	mv	a0,s1
    80004216:	ebffd0ef          	jal	800020d4 <wakeup>
  release(&lk->lk);
    8000421a:	854a                	mv	a0,s2
    8000421c:	b11fc0ef          	jal	80000d2c <release>
}
    80004220:	60e2                	ld	ra,24(sp)
    80004222:	6442                	ld	s0,16(sp)
    80004224:	64a2                	ld	s1,8(sp)
    80004226:	6902                	ld	s2,0(sp)
    80004228:	6105                	addi	sp,sp,32
    8000422a:	8082                	ret

000000008000422c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000422c:	7179                	addi	sp,sp,-48
    8000422e:	f406                	sd	ra,40(sp)
    80004230:	f022                	sd	s0,32(sp)
    80004232:	ec26                	sd	s1,24(sp)
    80004234:	e84a                	sd	s2,16(sp)
    80004236:	1800                	addi	s0,sp,48
    80004238:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    8000423a:	00850913          	addi	s2,a0,8
    8000423e:	854a                	mv	a0,s2
    80004240:	a65fc0ef          	jal	80000ca4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004244:	409c                	lw	a5,0(s1)
    80004246:	ef81                	bnez	a5,8000425e <holdingsleep+0x32>
    80004248:	4481                	li	s1,0
  release(&lk->lk);
    8000424a:	854a                	mv	a0,s2
    8000424c:	ae1fc0ef          	jal	80000d2c <release>
  return r;
}
    80004250:	8526                	mv	a0,s1
    80004252:	70a2                	ld	ra,40(sp)
    80004254:	7402                	ld	s0,32(sp)
    80004256:	64e2                	ld	s1,24(sp)
    80004258:	6942                	ld	s2,16(sp)
    8000425a:	6145                	addi	sp,sp,48
    8000425c:	8082                	ret
    8000425e:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004260:	0284a983          	lw	s3,40(s1)
    80004264:	ffafd0ef          	jal	80001a5e <myproc>
    80004268:	5904                	lw	s1,48(a0)
    8000426a:	413484b3          	sub	s1,s1,s3
    8000426e:	0014b493          	seqz	s1,s1
    80004272:	69a2                	ld	s3,8(sp)
    80004274:	bfd9                	j	8000424a <holdingsleep+0x1e>

0000000080004276 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004276:	1141                	addi	sp,sp,-16
    80004278:	e406                	sd	ra,8(sp)
    8000427a:	e022                	sd	s0,0(sp)
    8000427c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000427e:	00003597          	auipc	a1,0x3
    80004282:	34258593          	addi	a1,a1,834 # 800075c0 <etext+0x5c0>
    80004286:	0001e517          	auipc	a0,0x1e
    8000428a:	37a50513          	addi	a0,a0,890 # 80022600 <ftable>
    8000428e:	997fc0ef          	jal	80000c24 <initlock>
}
    80004292:	60a2                	ld	ra,8(sp)
    80004294:	6402                	ld	s0,0(sp)
    80004296:	0141                	addi	sp,sp,16
    80004298:	8082                	ret

000000008000429a <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    8000429a:	1101                	addi	sp,sp,-32
    8000429c:	ec06                	sd	ra,24(sp)
    8000429e:	e822                	sd	s0,16(sp)
    800042a0:	e426                	sd	s1,8(sp)
    800042a2:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800042a4:	0001e517          	auipc	a0,0x1e
    800042a8:	35c50513          	addi	a0,a0,860 # 80022600 <ftable>
    800042ac:	9f9fc0ef          	jal	80000ca4 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    800042b0:	0001e497          	auipc	s1,0x1e
    800042b4:	36848493          	addi	s1,s1,872 # 80022618 <ftable+0x18>
    800042b8:	0001f717          	auipc	a4,0x1f
    800042bc:	30070713          	addi	a4,a4,768 # 800235b8 <disk>
    if (f->ref == 0) {
    800042c0:	40dc                	lw	a5,4(s1)
    800042c2:	cf89                	beqz	a5,800042dc <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    800042c4:	02848493          	addi	s1,s1,40
    800042c8:	fee49ce3          	bne	s1,a4,800042c0 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800042cc:	0001e517          	auipc	a0,0x1e
    800042d0:	33450513          	addi	a0,a0,820 # 80022600 <ftable>
    800042d4:	a59fc0ef          	jal	80000d2c <release>
  return 0;
    800042d8:	4481                	li	s1,0
    800042da:	a809                	j	800042ec <filealloc+0x52>
      f->ref = 1;
    800042dc:	4785                	li	a5,1
    800042de:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800042e0:	0001e517          	auipc	a0,0x1e
    800042e4:	32050513          	addi	a0,a0,800 # 80022600 <ftable>
    800042e8:	a45fc0ef          	jal	80000d2c <release>
}
    800042ec:	8526                	mv	a0,s1
    800042ee:	60e2                	ld	ra,24(sp)
    800042f0:	6442                	ld	s0,16(sp)
    800042f2:	64a2                	ld	s1,8(sp)
    800042f4:	6105                	addi	sp,sp,32
    800042f6:	8082                	ret

00000000800042f8 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    800042f8:	1101                	addi	sp,sp,-32
    800042fa:	ec06                	sd	ra,24(sp)
    800042fc:	e822                	sd	s0,16(sp)
    800042fe:	e426                	sd	s1,8(sp)
    80004300:	1000                	addi	s0,sp,32
    80004302:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004304:	0001e517          	auipc	a0,0x1e
    80004308:	2fc50513          	addi	a0,a0,764 # 80022600 <ftable>
    8000430c:	999fc0ef          	jal	80000ca4 <acquire>
  if (f->ref < 1)
    80004310:	40dc                	lw	a5,4(s1)
    80004312:	02f05063          	blez	a5,80004332 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004316:	2785                	addiw	a5,a5,1
    80004318:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000431a:	0001e517          	auipc	a0,0x1e
    8000431e:	2e650513          	addi	a0,a0,742 # 80022600 <ftable>
    80004322:	a0bfc0ef          	jal	80000d2c <release>
  return f;
}
    80004326:	8526                	mv	a0,s1
    80004328:	60e2                	ld	ra,24(sp)
    8000432a:	6442                	ld	s0,16(sp)
    8000432c:	64a2                	ld	s1,8(sp)
    8000432e:	6105                	addi	sp,sp,32
    80004330:	8082                	ret
    panic("filedup");
    80004332:	00003517          	auipc	a0,0x3
    80004336:	29650513          	addi	a0,a0,662 # 800075c8 <etext+0x5c8>
    8000433a:	cfafc0ef          	jal	80000834 <panic>

000000008000433e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000433e:	7139                	addi	sp,sp,-64
    80004340:	fc06                	sd	ra,56(sp)
    80004342:	f822                	sd	s0,48(sp)
    80004344:	f426                	sd	s1,40(sp)
    80004346:	0080                	addi	s0,sp,64
    80004348:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000434a:	0001e517          	auipc	a0,0x1e
    8000434e:	2b650513          	addi	a0,a0,694 # 80022600 <ftable>
    80004352:	953fc0ef          	jal	80000ca4 <acquire>
  if (f->ref < 1)
    80004356:	40dc                	lw	a5,4(s1)
    80004358:	04f05a63          	blez	a5,800043ac <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    8000435c:	37fd                	addiw	a5,a5,-1
    8000435e:	c0dc                	sw	a5,4(s1)
    80004360:	06f04063          	bgtz	a5,800043c0 <fileclose+0x82>
    80004364:	f04a                	sd	s2,32(sp)
    80004366:	ec4e                	sd	s3,24(sp)
    80004368:	e852                	sd	s4,16(sp)
    8000436a:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000436c:	0004a903          	lw	s2,0(s1)
    80004370:	0094c783          	lbu	a5,9(s1)
    80004374:	89be                	mv	s3,a5
    80004376:	689c                	ld	a5,16(s1)
    80004378:	8a3e                	mv	s4,a5
    8000437a:	6c9c                	ld	a5,24(s1)
    8000437c:	8abe                	mv	s5,a5
  f->ref = 0;
    8000437e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004382:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004386:	0001e517          	auipc	a0,0x1e
    8000438a:	27a50513          	addi	a0,a0,634 # 80022600 <ftable>
    8000438e:	99ffc0ef          	jal	80000d2c <release>

  if (ff.type == FD_PIPE) {
    80004392:	4785                	li	a5,1
    80004394:	04f90163          	beq	s2,a5,800043d6 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    80004398:	ffe9079b          	addiw	a5,s2,-2
    8000439c:	4705                	li	a4,1
    8000439e:	04f77563          	bgeu	a4,a5,800043e8 <fileclose+0xaa>
    800043a2:	7902                	ld	s2,32(sp)
    800043a4:	69e2                	ld	s3,24(sp)
    800043a6:	6a42                	ld	s4,16(sp)
    800043a8:	6aa2                	ld	s5,8(sp)
    800043aa:	a00d                	j	800043cc <fileclose+0x8e>
    800043ac:	f04a                	sd	s2,32(sp)
    800043ae:	ec4e                	sd	s3,24(sp)
    800043b0:	e852                	sd	s4,16(sp)
    800043b2:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800043b4:	00003517          	auipc	a0,0x3
    800043b8:	21c50513          	addi	a0,a0,540 # 800075d0 <etext+0x5d0>
    800043bc:	c78fc0ef          	jal	80000834 <panic>
    release(&ftable.lock);
    800043c0:	0001e517          	auipc	a0,0x1e
    800043c4:	24050513          	addi	a0,a0,576 # 80022600 <ftable>
    800043c8:	965fc0ef          	jal	80000d2c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800043cc:	70e2                	ld	ra,56(sp)
    800043ce:	7442                	ld	s0,48(sp)
    800043d0:	74a2                	ld	s1,40(sp)
    800043d2:	6121                	addi	sp,sp,64
    800043d4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800043d6:	85ce                	mv	a1,s3
    800043d8:	8552                	mv	a0,s4
    800043da:	36a000ef          	jal	80004744 <pipeclose>
    800043de:	7902                	ld	s2,32(sp)
    800043e0:	69e2                	ld	s3,24(sp)
    800043e2:	6a42                	ld	s4,16(sp)
    800043e4:	6aa2                	ld	s5,8(sp)
    800043e6:	b7dd                	j	800043cc <fileclose+0x8e>
    begin_op();
    800043e8:	a9dff0ef          	jal	80003e84 <begin_op>
    iput(ff.ip);
    800043ec:	8556                	mv	a0,s5
    800043ee:	9a0ff0ef          	jal	8000358e <iput>
    end_op();
    800043f2:	b1fff0ef          	jal	80003f10 <end_op>
    800043f6:	7902                	ld	s2,32(sp)
    800043f8:	69e2                	ld	s3,24(sp)
    800043fa:	6a42                	ld	s4,16(sp)
    800043fc:	6aa2                	ld	s5,8(sp)
    800043fe:	b7f9                	j	800043cc <fileclose+0x8e>

0000000080004400 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004400:	715d                	addi	sp,sp,-80
    80004402:	e486                	sd	ra,72(sp)
    80004404:	e0a2                	sd	s0,64(sp)
    80004406:	fc26                	sd	s1,56(sp)
    80004408:	f052                	sd	s4,32(sp)
    8000440a:	0880                	addi	s0,sp,80
    8000440c:	84aa                	mv	s1,a0
    8000440e:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004410:	e4efd0ef          	jal	80001a5e <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    80004414:	409c                	lw	a5,0(s1)
    80004416:	37f9                	addiw	a5,a5,-2
    80004418:	4705                	li	a4,1
    8000441a:	04f76963          	bltu	a4,a5,8000446c <filestat+0x6c>
    8000441e:	f84a                	sd	s2,48(sp)
    80004420:	f44e                	sd	s3,40(sp)
    80004422:	892a                	mv	s2,a0
    memset(&st, 0, sizeof(st));
    80004424:	fb840993          	addi	s3,s0,-72
    80004428:	4661                	li	a2,24
    8000442a:	4581                	li	a1,0
    8000442c:	854e                	mv	a0,s3
    8000442e:	937fc0ef          	jal	80000d64 <memset>
    ilock(f->ip);
    80004432:	6c88                	ld	a0,24(s1)
    80004434:	fd9fe0ef          	jal	8000340c <ilock>
    stati(f->ip, &st);
    80004438:	85ce                	mv	a1,s3
    8000443a:	6c88                	ld	a0,24(s1)
    8000443c:	b7cff0ef          	jal	800037b8 <stati>
    iunlock(f->ip);
    80004440:	6c88                	ld	a0,24(s1)
    80004442:	878ff0ef          	jal	800034ba <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    80004446:	4761                	li	a4,24
    80004448:	86ce                	mv	a3,s3
    8000444a:	8652                	mv	a2,s4
    8000444c:	04893583          	ld	a1,72(s2)
    80004450:	05093503          	ld	a0,80(s2)
    80004454:	a02fd0ef          	jal	80001656 <copyout>
    80004458:	41f5551b          	sraiw	a0,a0,0x1f
    8000445c:	7942                	ld	s2,48(sp)
    8000445e:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004460:	60a6                	ld	ra,72(sp)
    80004462:	6406                	ld	s0,64(sp)
    80004464:	74e2                	ld	s1,56(sp)
    80004466:	7a02                	ld	s4,32(sp)
    80004468:	6161                	addi	sp,sp,80
    8000446a:	8082                	ret
  return -1;
    8000446c:	557d                	li	a0,-1
    8000446e:	bfcd                	j	80004460 <filestat+0x60>

0000000080004470 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004470:	7179                	addi	sp,sp,-48
    80004472:	f406                	sd	ra,40(sp)
    80004474:	f022                	sd	s0,32(sp)
    80004476:	e84a                	sd	s2,16(sp)
    80004478:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    8000447a:	00854783          	lbu	a5,8(a0)
    8000447e:	c3dd                	beqz	a5,80004524 <fileread+0xb4>
    80004480:	ec26                	sd	s1,24(sp)
    80004482:	e44e                	sd	s3,8(sp)
    80004484:	84aa                	mv	s1,a0
    80004486:	892e                	mv	s2,a1
    80004488:	89b2                	mv	s3,a2
    8000448a:	01f6579b          	srliw	a5,a2,0x1f
    8000448e:	ebc9                	bnez	a5,80004520 <fileread+0xb0>
    return -1;

  if (f->type == FD_PIPE) {
    80004490:	411c                	lw	a5,0(a0)
    80004492:	4705                	li	a4,1
    80004494:	04e78363          	beq	a5,a4,800044da <fileread+0x6a>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    80004498:	470d                	li	a4,3
    8000449a:	04e78763          	beq	a5,a4,800044e8 <fileread+0x78>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    8000449e:	4709                	li	a4,2
    800044a0:	06e79a63          	bne	a5,a4,80004514 <fileread+0xa4>
    ilock(f->ip);
    800044a4:	6d08                	ld	a0,24(a0)
    800044a6:	f67fe0ef          	jal	8000340c <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800044aa:	874e                	mv	a4,s3
    800044ac:	5094                	lw	a3,32(s1)
    800044ae:	864a                	mv	a2,s2
    800044b0:	4585                	li	a1,1
    800044b2:	6c88                	ld	a0,24(s1)
    800044b4:	b32ff0ef          	jal	800037e6 <readi>
    800044b8:	892a                	mv	s2,a0
    800044ba:	00a05563          	blez	a0,800044c4 <fileread+0x54>
      f->off += r;
    800044be:	509c                	lw	a5,32(s1)
    800044c0:	9fa9                	addw	a5,a5,a0
    800044c2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800044c4:	6c88                	ld	a0,24(s1)
    800044c6:	ff5fe0ef          	jal	800034ba <iunlock>
    800044ca:	64e2                	ld	s1,24(sp)
    800044cc:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800044ce:	854a                	mv	a0,s2
    800044d0:	70a2                	ld	ra,40(sp)
    800044d2:	7402                	ld	s0,32(sp)
    800044d4:	6942                	ld	s2,16(sp)
    800044d6:	6145                	addi	sp,sp,48
    800044d8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800044da:	6908                	ld	a0,16(a0)
    800044dc:	3e2000ef          	jal	800048be <piperead>
    800044e0:	892a                	mv	s2,a0
    800044e2:	64e2                	ld	s1,24(sp)
    800044e4:	69a2                	ld	s3,8(sp)
    800044e6:	b7e5                	j	800044ce <fileread+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800044e8:	02451783          	lh	a5,36(a0)
    800044ec:	03079693          	slli	a3,a5,0x30
    800044f0:	92c1                	srli	a3,a3,0x30
    800044f2:	4725                	li	a4,9
    800044f4:	02d76b63          	bltu	a4,a3,8000452a <fileread+0xba>
    800044f8:	0792                	slli	a5,a5,0x4
    800044fa:	0001e717          	auipc	a4,0x1e
    800044fe:	06670713          	addi	a4,a4,102 # 80022560 <devsw>
    80004502:	97ba                	add	a5,a5,a4
    80004504:	639c                	ld	a5,0(a5)
    80004506:	c79d                	beqz	a5,80004534 <fileread+0xc4>
    r = devsw[f->major].read(1, addr, n);
    80004508:	4505                	li	a0,1
    8000450a:	9782                	jalr	a5
    8000450c:	892a                	mv	s2,a0
    8000450e:	64e2                	ld	s1,24(sp)
    80004510:	69a2                	ld	s3,8(sp)
    80004512:	bf75                	j	800044ce <fileread+0x5e>
    panic("fileread");
    80004514:	00003517          	auipc	a0,0x3
    80004518:	0cc50513          	addi	a0,a0,204 # 800075e0 <etext+0x5e0>
    8000451c:	b18fc0ef          	jal	80000834 <panic>
    80004520:	64e2                	ld	s1,24(sp)
    80004522:	69a2                	ld	s3,8(sp)
    return -1;
    80004524:	57fd                	li	a5,-1
    80004526:	893e                	mv	s2,a5
    80004528:	b75d                	j	800044ce <fileread+0x5e>
      return -1;
    8000452a:	57fd                	li	a5,-1
    8000452c:	893e                	mv	s2,a5
    8000452e:	64e2                	ld	s1,24(sp)
    80004530:	69a2                	ld	s3,8(sp)
    80004532:	bf71                	j	800044ce <fileread+0x5e>
    80004534:	57fd                	li	a5,-1
    80004536:	893e                	mv	s2,a5
    80004538:	64e2                	ld	s1,24(sp)
    8000453a:	69a2                	ld	s3,8(sp)
    8000453c:	bf49                	j	800044ce <fileread+0x5e>

000000008000453e <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    8000453e:	00954783          	lbu	a5,9(a0)
    80004542:	12078b63          	beqz	a5,80004678 <filewrite+0x13a>
{
    80004546:	711d                	addi	sp,sp,-96
    80004548:	ec86                	sd	ra,88(sp)
    8000454a:	e8a2                	sd	s0,80(sp)
    8000454c:	e0ca                	sd	s2,64(sp)
    8000454e:	f456                	sd	s5,40(sp)
    80004550:	f05a                	sd	s6,32(sp)
    80004552:	1080                	addi	s0,sp,96
    80004554:	892a                	mv	s2,a0
    80004556:	8b2e                	mv	s6,a1
    80004558:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    8000455a:	01f6579b          	srliw	a5,a2,0x1f
    8000455e:	0e079d63          	bnez	a5,80004658 <filewrite+0x11a>
    return -1;

  if (f->type == FD_PIPE) {
    80004562:	411c                	lw	a5,0(a0)
    80004564:	4705                	li	a4,1
    80004566:	02e78a63          	beq	a5,a4,8000459a <filewrite+0x5c>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    8000456a:	470d                	li	a4,3
    8000456c:	02e78b63          	beq	a5,a4,800045a2 <filewrite+0x64>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004570:	4709                	li	a4,2
    80004572:	0ce79763          	bne	a5,a4,80004640 <filewrite+0x102>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    80004576:	0ec05763          	blez	a2,80004664 <filewrite+0x126>
    8000457a:	e4a6                	sd	s1,72(sp)
    8000457c:	fc4e                	sd	s3,56(sp)
    8000457e:	f852                	sd	s4,48(sp)
    80004580:	ec5e                	sd	s7,24(sp)
    80004582:	e862                	sd	s8,16(sp)
    80004584:	e466                	sd	s9,8(sp)
    int i = 0;
    80004586:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    80004588:	6b85                	lui	s7,0x1
    8000458a:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000458e:	6785                	lui	a5,0x1
    80004590:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004594:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004596:	4c05                	li	s8,1
    80004598:	a8ad                	j	80004612 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    8000459a:	6908                	ld	a0,16(a0)
    8000459c:	206000ef          	jal	800047a2 <pipewrite>
    800045a0:	a849                	j	80004632 <filewrite+0xf4>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800045a2:	02451783          	lh	a5,36(a0)
    800045a6:	03079693          	slli	a3,a5,0x30
    800045aa:	92c1                	srli	a3,a3,0x30
    800045ac:	4725                	li	a4,9
    800045ae:	0ad76763          	bltu	a4,a3,8000465c <filewrite+0x11e>
    800045b2:	0792                	slli	a5,a5,0x4
    800045b4:	0001e717          	auipc	a4,0x1e
    800045b8:	fac70713          	addi	a4,a4,-84 # 80022560 <devsw>
    800045bc:	97ba                	add	a5,a5,a4
    800045be:	679c                	ld	a5,8(a5)
    800045c0:	c3c5                	beqz	a5,80004660 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800045c2:	4505                	li	a0,1
    800045c4:	9782                	jalr	a5
    800045c6:	a0b5                	j	80004632 <filewrite+0xf4>
      if (n1 > max)
    800045c8:	2981                	sext.w	s3,s3
      begin_op();
    800045ca:	8bbff0ef          	jal	80003e84 <begin_op>
      ilock(f->ip);
    800045ce:	01893503          	ld	a0,24(s2)
    800045d2:	e3bfe0ef          	jal	8000340c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800045d6:	874e                	mv	a4,s3
    800045d8:	02092683          	lw	a3,32(s2)
    800045dc:	016a0633          	add	a2,s4,s6
    800045e0:	85e2                	mv	a1,s8
    800045e2:	01893503          	ld	a0,24(s2)
    800045e6:	af2ff0ef          	jal	800038d8 <writei>
    800045ea:	84aa                	mv	s1,a0
    800045ec:	00a05763          	blez	a0,800045fa <filewrite+0xbc>
        f->off += r;
    800045f0:	02092783          	lw	a5,32(s2)
    800045f4:	9fa9                	addw	a5,a5,a0
    800045f6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800045fa:	01893503          	ld	a0,24(s2)
    800045fe:	ebdfe0ef          	jal	800034ba <iunlock>
      end_op();
    80004602:	90fff0ef          	jal	80003f10 <end_op>

      if (r != n1) {
    80004606:	00999d63          	bne	s3,s1,80004620 <filewrite+0xe2>
        // error from writei
        break;
      }
      i += r;
    8000460a:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    8000460e:	015a5963          	bge	s4,s5,80004620 <filewrite+0xe2>
      int n1 = n - i;
    80004612:	414a87bb          	subw	a5,s5,s4
    80004616:	89be                	mv	s3,a5
      if (n1 > max)
    80004618:	fafbd8e3          	bge	s7,a5,800045c8 <filewrite+0x8a>
    8000461c:	89e6                	mv	s3,s9
    8000461e:	b76d                	j	800045c8 <filewrite+0x8a>
    }
    ret = (i == n ? n : -1);
    80004620:	054a9463          	bne	s5,s4,80004668 <filewrite+0x12a>
    80004624:	8556                	mv	a0,s5
    80004626:	64a6                	ld	s1,72(sp)
    80004628:	79e2                	ld	s3,56(sp)
    8000462a:	7a42                	ld	s4,48(sp)
    8000462c:	6be2                	ld	s7,24(sp)
    8000462e:	6c42                	ld	s8,16(sp)
    80004630:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004632:	60e6                	ld	ra,88(sp)
    80004634:	6446                	ld	s0,80(sp)
    80004636:	6906                	ld	s2,64(sp)
    80004638:	7aa2                	ld	s5,40(sp)
    8000463a:	7b02                	ld	s6,32(sp)
    8000463c:	6125                	addi	sp,sp,96
    8000463e:	8082                	ret
    80004640:	e4a6                	sd	s1,72(sp)
    80004642:	fc4e                	sd	s3,56(sp)
    80004644:	f852                	sd	s4,48(sp)
    80004646:	ec5e                	sd	s7,24(sp)
    80004648:	e862                	sd	s8,16(sp)
    8000464a:	e466                	sd	s9,8(sp)
    panic("filewrite");
    8000464c:	00003517          	auipc	a0,0x3
    80004650:	fa450513          	addi	a0,a0,-92 # 800075f0 <etext+0x5f0>
    80004654:	9e0fc0ef          	jal	80000834 <panic>
    return -1;
    80004658:	557d                	li	a0,-1
    8000465a:	bfe1                	j	80004632 <filewrite+0xf4>
      return -1;
    8000465c:	557d                	li	a0,-1
    8000465e:	bfd1                	j	80004632 <filewrite+0xf4>
    80004660:	557d                	li	a0,-1
    80004662:	bfc1                	j	80004632 <filewrite+0xf4>
    ret = (i == n ? n : -1);
    80004664:	8532                	mv	a0,a2
    80004666:	b7f1                	j	80004632 <filewrite+0xf4>
    80004668:	557d                	li	a0,-1
    8000466a:	64a6                	ld	s1,72(sp)
    8000466c:	79e2                	ld	s3,56(sp)
    8000466e:	7a42                	ld	s4,48(sp)
    80004670:	6be2                	ld	s7,24(sp)
    80004672:	6c42                	ld	s8,16(sp)
    80004674:	6ca2                	ld	s9,8(sp)
    80004676:	bf75                	j	80004632 <filewrite+0xf4>
    return -1;
    80004678:	557d                	li	a0,-1
}
    8000467a:	8082                	ret

000000008000467c <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000467c:	7179                	addi	sp,sp,-48
    8000467e:	f406                	sd	ra,40(sp)
    80004680:	f022                	sd	s0,32(sp)
    80004682:	ec26                	sd	s1,24(sp)
    80004684:	e052                	sd	s4,0(sp)
    80004686:	1800                	addi	s0,sp,48
    80004688:	84aa                	mv	s1,a0
    8000468a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000468c:	0005b023          	sd	zero,0(a1)
    80004690:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004694:	c07ff0ef          	jal	8000429a <filealloc>
    80004698:	e088                	sd	a0,0(s1)
    8000469a:	c549                	beqz	a0,80004724 <pipealloc+0xa8>
    8000469c:	bffff0ef          	jal	8000429a <filealloc>
    800046a0:	00aa3023          	sd	a0,0(s4)
    800046a4:	cd25                	beqz	a0,8000471c <pipealloc+0xa0>
    800046a6:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    800046a8:	cd0fc0ef          	jal	80000b78 <kalloc>
    800046ac:	892a                	mv	s2,a0
    800046ae:	c12d                	beqz	a0,80004710 <pipealloc+0x94>
    800046b0:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800046b2:	4985                	li	s3,1
    800046b4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800046b8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800046bc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800046c0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800046c4:	00003597          	auipc	a1,0x3
    800046c8:	f3c58593          	addi	a1,a1,-196 # 80007600 <etext+0x600>
    800046cc:	d58fc0ef          	jal	80000c24 <initlock>
  (*f0)->type = FD_PIPE;
    800046d0:	609c                	ld	a5,0(s1)
    800046d2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800046d6:	609c                	ld	a5,0(s1)
    800046d8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800046dc:	609c                	ld	a5,0(s1)
    800046de:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800046e2:	609c                	ld	a5,0(s1)
    800046e4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800046e8:	000a3783          	ld	a5,0(s4)
    800046ec:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800046f0:	000a3783          	ld	a5,0(s4)
    800046f4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800046f8:	000a3783          	ld	a5,0(s4)
    800046fc:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004700:	000a3783          	ld	a5,0(s4)
    80004704:	0127b823          	sd	s2,16(a5)
  return 0;
    80004708:	4501                	li	a0,0
    8000470a:	6942                	ld	s2,16(sp)
    8000470c:	69a2                	ld	s3,8(sp)
    8000470e:	a01d                	j	80004734 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80004710:	6088                	ld	a0,0(s1)
    80004712:	c119                	beqz	a0,80004718 <pipealloc+0x9c>
    80004714:	6942                	ld	s2,16(sp)
    80004716:	a029                	j	80004720 <pipealloc+0xa4>
    80004718:	6942                	ld	s2,16(sp)
    8000471a:	a029                	j	80004724 <pipealloc+0xa8>
    8000471c:	6088                	ld	a0,0(s1)
    8000471e:	c10d                	beqz	a0,80004740 <pipealloc+0xc4>
    fileclose(*f0);
    80004720:	c1fff0ef          	jal	8000433e <fileclose>
  if (*f1)
    80004724:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004728:	557d                	li	a0,-1
  if (*f1)
    8000472a:	c789                	beqz	a5,80004734 <pipealloc+0xb8>
    fileclose(*f1);
    8000472c:	853e                	mv	a0,a5
    8000472e:	c11ff0ef          	jal	8000433e <fileclose>
  return -1;
    80004732:	557d                	li	a0,-1
}
    80004734:	70a2                	ld	ra,40(sp)
    80004736:	7402                	ld	s0,32(sp)
    80004738:	64e2                	ld	s1,24(sp)
    8000473a:	6a02                	ld	s4,0(sp)
    8000473c:	6145                	addi	sp,sp,48
    8000473e:	8082                	ret
  return -1;
    80004740:	557d                	li	a0,-1
    80004742:	bfcd                	j	80004734 <pipealloc+0xb8>

0000000080004744 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004744:	1101                	addi	sp,sp,-32
    80004746:	ec06                	sd	ra,24(sp)
    80004748:	e822                	sd	s0,16(sp)
    8000474a:	e426                	sd	s1,8(sp)
    8000474c:	e04a                	sd	s2,0(sp)
    8000474e:	1000                	addi	s0,sp,32
    80004750:	84aa                	mv	s1,a0
    80004752:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004754:	d50fc0ef          	jal	80000ca4 <acquire>
  if (writable) {
    80004758:	02090763          	beqz	s2,80004786 <pipeclose+0x42>
    pi->writeopen = 0;
    8000475c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004760:	21848513          	addi	a0,s1,536
    80004764:	971fd0ef          	jal	800020d4 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    80004768:	2204a783          	lw	a5,544(s1)
    8000476c:	e781                	bnez	a5,80004774 <pipeclose+0x30>
    8000476e:	2244a783          	lw	a5,548(s1)
    80004772:	c38d                	beqz	a5,80004794 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    80004774:	8526                	mv	a0,s1
    80004776:	db6fc0ef          	jal	80000d2c <release>
}
    8000477a:	60e2                	ld	ra,24(sp)
    8000477c:	6442                	ld	s0,16(sp)
    8000477e:	64a2                	ld	s1,8(sp)
    80004780:	6902                	ld	s2,0(sp)
    80004782:	6105                	addi	sp,sp,32
    80004784:	8082                	ret
    pi->readopen = 0;
    80004786:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000478a:	21c48513          	addi	a0,s1,540
    8000478e:	947fd0ef          	jal	800020d4 <wakeup>
    80004792:	bfd9                	j	80004768 <pipeclose+0x24>
    release(&pi->lock);
    80004794:	8526                	mv	a0,s1
    80004796:	d96fc0ef          	jal	80000d2c <release>
    kfree((char *)pi);
    8000479a:	8526                	mv	a0,s1
    8000479c:	acafc0ef          	jal	80000a66 <kfree>
    800047a0:	bfe9                	j	8000477a <pipeclose+0x36>

00000000800047a2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800047a2:	7159                	addi	sp,sp,-112
    800047a4:	f486                	sd	ra,104(sp)
    800047a6:	f0a2                	sd	s0,96(sp)
    800047a8:	eca6                	sd	s1,88(sp)
    800047aa:	e8ca                	sd	s2,80(sp)
    800047ac:	e4ce                	sd	s3,72(sp)
    800047ae:	e0d2                	sd	s4,64(sp)
    800047b0:	fc56                	sd	s5,56(sp)
    800047b2:	1880                	addi	s0,sp,112
    800047b4:	84aa                	mv	s1,a0
    800047b6:	8aae                	mv	s5,a1
    800047b8:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800047ba:	aa4fd0ef          	jal	80001a5e <myproc>
    800047be:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800047c0:	8526                	mv	a0,s1
    800047c2:	ce2fc0ef          	jal	80000ca4 <acquire>
  while (i < n) {
    800047c6:	0f405a63          	blez	s4,800048ba <pipewrite+0x118>
    800047ca:	f85a                	sd	s6,48(sp)
    800047cc:	f45e                	sd	s7,40(sp)
    800047ce:	f062                	sd	s8,32(sp)
    800047d0:	ec66                	sd	s9,24(sp)
    800047d2:	e86a                	sd	s10,16(sp)
  int i = 0;
    800047d4:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    800047d6:	f9f40c13          	addi	s8,s0,-97
    800047da:	4b85                	li	s7,1
    800047dc:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800047de:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    800047e2:	21c48c93          	addi	s9,s1,540
    800047e6:	a0a1                	j	8000482e <pipewrite+0x8c>
      release(&pi->lock);
    800047e8:	8526                	mv	a0,s1
    800047ea:	d42fc0ef          	jal	80000d2c <release>
      return -1;
    800047ee:	597d                	li	s2,-1
    800047f0:	7b42                	ld	s6,48(sp)
    800047f2:	7ba2                	ld	s7,40(sp)
    800047f4:	7c02                	ld	s8,32(sp)
    800047f6:	6ce2                	ld	s9,24(sp)
    800047f8:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800047fa:	854a                	mv	a0,s2
    800047fc:	70a6                	ld	ra,104(sp)
    800047fe:	7406                	ld	s0,96(sp)
    80004800:	64e6                	ld	s1,88(sp)
    80004802:	6946                	ld	s2,80(sp)
    80004804:	69a6                	ld	s3,72(sp)
    80004806:	6a06                	ld	s4,64(sp)
    80004808:	7ae2                	ld	s5,56(sp)
    8000480a:	6165                	addi	sp,sp,112
    8000480c:	8082                	ret
      wakeup(&pi->nread);
    8000480e:	856a                	mv	a0,s10
    80004810:	8c5fd0ef          	jal	800020d4 <wakeup>
      sleep_prepare(&pi->nwrite);
    80004814:	8566                	mv	a0,s9
    80004816:	853fd0ef          	jal	80002068 <sleep_prepare>
      release(&pi->lock);
    8000481a:	8526                	mv	a0,s1
    8000481c:	d10fc0ef          	jal	80000d2c <release>
      sleep();
    80004820:	885fd0ef          	jal	800020a4 <sleep>
      acquire(&pi->lock);
    80004824:	8526                	mv	a0,s1
    80004826:	c7efc0ef          	jal	80000ca4 <acquire>
  while (i < n) {
    8000482a:	07495b63          	bge	s2,s4,800048a0 <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    8000482e:	2204a783          	lw	a5,544(s1)
    80004832:	dbdd                	beqz	a5,800047e8 <pipewrite+0x46>
    80004834:	854e                	mv	a0,s3
    80004836:	a91fd0ef          	jal	800022c6 <killed>
    8000483a:	f55d                	bnez	a0,800047e8 <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    8000483c:	2184a783          	lw	a5,536(s1)
    80004840:	21c4a703          	lw	a4,540(s1)
    80004844:	2007879b          	addiw	a5,a5,512
    80004848:	fcf703e3          	beq	a4,a5,8000480e <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    8000484c:	875e                	mv	a4,s7
    8000484e:	015906b3          	add	a3,s2,s5
    80004852:	8662                	mv	a2,s8
    80004854:	0489b583          	ld	a1,72(s3)
    80004858:	0509b503          	ld	a0,80(s3)
    8000485c:	ec1fc0ef          	jal	8000171c <copyin>
    80004860:	03650163          	beq	a0,s6,80004882 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004864:	21c4a783          	lw	a5,540(s1)
    80004868:	0017871b          	addiw	a4,a5,1
    8000486c:	20e4ae23          	sw	a4,540(s1)
    80004870:	1ff7f793          	andi	a5,a5,511
    80004874:	97a6                	add	a5,a5,s1
    80004876:	f9f44703          	lbu	a4,-97(s0)
    8000487a:	00e78c23          	sb	a4,24(a5)
      i++;
    8000487e:	2905                	addiw	s2,s2,1
    80004880:	b76d                	j	8000482a <pipewrite+0x88>
        if (i == 0)
    80004882:	00090863          	beqz	s2,80004892 <pipewrite+0xf0>
    80004886:	7b42                	ld	s6,48(sp)
    80004888:	7ba2                	ld	s7,40(sp)
    8000488a:	7c02                	ld	s8,32(sp)
    8000488c:	6ce2                	ld	s9,24(sp)
    8000488e:	6d42                	ld	s10,16(sp)
    80004890:	a829                	j	800048aa <pipewrite+0x108>
          i = -1;
    80004892:	892a                	mv	s2,a0
        break;
    80004894:	7b42                	ld	s6,48(sp)
    80004896:	7ba2                	ld	s7,40(sp)
    80004898:	7c02                	ld	s8,32(sp)
    8000489a:	6ce2                	ld	s9,24(sp)
    8000489c:	6d42                	ld	s10,16(sp)
    8000489e:	a031                	j	800048aa <pipewrite+0x108>
    800048a0:	7b42                	ld	s6,48(sp)
    800048a2:	7ba2                	ld	s7,40(sp)
    800048a4:	7c02                	ld	s8,32(sp)
    800048a6:	6ce2                	ld	s9,24(sp)
    800048a8:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    800048aa:	21848513          	addi	a0,s1,536
    800048ae:	827fd0ef          	jal	800020d4 <wakeup>
  release(&pi->lock);
    800048b2:	8526                	mv	a0,s1
    800048b4:	c78fc0ef          	jal	80000d2c <release>
  return i;
    800048b8:	b789                	j	800047fa <pipewrite+0x58>
  int i = 0;
    800048ba:	4901                	li	s2,0
    800048bc:	b7fd                	j	800048aa <pipewrite+0x108>

00000000800048be <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800048be:	711d                	addi	sp,sp,-96
    800048c0:	ec86                	sd	ra,88(sp)
    800048c2:	e8a2                	sd	s0,80(sp)
    800048c4:	e4a6                	sd	s1,72(sp)
    800048c6:	e0ca                	sd	s2,64(sp)
    800048c8:	fc4e                	sd	s3,56(sp)
    800048ca:	f852                	sd	s4,48(sp)
    800048cc:	f456                	sd	s5,40(sp)
    800048ce:	1080                	addi	s0,sp,96
    800048d0:	84aa                	mv	s1,a0
    800048d2:	89ae                	mv	s3,a1
    800048d4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800048d6:	988fd0ef          	jal	80001a5e <myproc>
    800048da:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    800048dc:	8526                	mv	a0,s1
    800048de:	bc6fc0ef          	jal	80000ca4 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800048e2:	0d505263          	blez	s5,800049a6 <piperead+0xe8>
    800048e6:	2184a703          	lw	a4,536(s1)
    800048ea:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    800048ee:	21848a13          	addi	s4,s1,536
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800048f2:	02f71e63          	bne	a4,a5,8000492e <piperead+0x70>
    800048f6:	2244a783          	lw	a5,548(s1)
    800048fa:	c3b9                	beqz	a5,80004940 <piperead+0x82>
    if (killed(pr)) {
    800048fc:	854a                	mv	a0,s2
    800048fe:	9c9fd0ef          	jal	800022c6 <killed>
    80004902:	e915                	bnez	a0,80004936 <piperead+0x78>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004904:	8552                	mv	a0,s4
    80004906:	f62fd0ef          	jal	80002068 <sleep_prepare>
    release(&pi->lock);
    8000490a:	8526                	mv	a0,s1
    8000490c:	c20fc0ef          	jal	80000d2c <release>
    sleep();
    80004910:	f94fd0ef          	jal	800020a4 <sleep>
    acquire(&pi->lock);
    80004914:	8526                	mv	a0,s1
    80004916:	b8efc0ef          	jal	80000ca4 <acquire>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    8000491a:	2184a703          	lw	a4,536(s1)
    8000491e:	21c4a783          	lw	a5,540(s1)
    80004922:	fcf70ae3          	beq	a4,a5,800048f6 <piperead+0x38>
    80004926:	f05a                	sd	s6,32(sp)
    80004928:	ec5e                	sd	s7,24(sp)
    8000492a:	e862                	sd	s8,16(sp)
    8000492c:	a829                	j	80004946 <piperead+0x88>
    8000492e:	f05a                	sd	s6,32(sp)
    80004930:	ec5e                	sd	s7,24(sp)
    80004932:	e862                	sd	s8,16(sp)
    80004934:	a809                	j	80004946 <piperead+0x88>
      release(&pi->lock);
    80004936:	8526                	mv	a0,s1
    80004938:	bf4fc0ef          	jal	80000d2c <release>
      return -1;
    8000493c:	5a7d                	li	s4,-1
    8000493e:	a8a5                	j	800049b6 <piperead+0xf8>
    80004940:	f05a                	sd	s6,32(sp)
    80004942:	ec5e                	sd	s7,24(sp)
    80004944:	e862                	sd	s8,16(sp)
{
    80004946:	4a01                	li	s4,0
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004948:	faf40c13          	addi	s8,s0,-81
    8000494c:	4b85                	li	s7,1
    8000494e:	5b7d                	li	s6,-1
    if (pi->nread == pi->nwrite)
    80004950:	2184a783          	lw	a5,536(s1)
    80004954:	21c4a703          	lw	a4,540(s1)
    80004958:	06f70e63          	beq	a4,a5,800049d4 <piperead+0x116>
    ch = pi->data[pi->nread % PIPESIZE];
    8000495c:	1ff7f793          	andi	a5,a5,511
    80004960:	97a6                	add	a5,a5,s1
    80004962:	0187c783          	lbu	a5,24(a5)
    80004966:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    8000496a:	875e                	mv	a4,s7
    8000496c:	86e2                	mv	a3,s8
    8000496e:	864e                	mv	a2,s3
    80004970:	04893583          	ld	a1,72(s2)
    80004974:	05093503          	ld	a0,80(s2)
    80004978:	cdffc0ef          	jal	80001656 <copyout>
    8000497c:	01650f63          	beq	a0,s6,8000499a <piperead+0xdc>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004980:	2184a783          	lw	a5,536(s1)
    80004984:	2785                	addiw	a5,a5,1
    80004986:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    8000498a:	2a05                	addiw	s4,s4,1
    8000498c:	0985                	addi	s3,s3,1
    8000498e:	fd4a91e3          	bne	s5,s4,80004950 <piperead+0x92>
    80004992:	7b02                	ld	s6,32(sp)
    80004994:	6be2                	ld	s7,24(sp)
    80004996:	6c42                	ld	s8,16(sp)
    80004998:	a801                	j	800049a8 <piperead+0xea>
      if (i == 0)
    8000499a:	020a0863          	beqz	s4,800049ca <piperead+0x10c>
    8000499e:	7b02                	ld	s6,32(sp)
    800049a0:	6be2                	ld	s7,24(sp)
    800049a2:	6c42                	ld	s8,16(sp)
    800049a4:	a011                	j	800049a8 <piperead+0xea>
  while (n > 0 && pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800049a6:	4a01                	li	s4,0
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    800049a8:	21c48513          	addi	a0,s1,540
    800049ac:	f28fd0ef          	jal	800020d4 <wakeup>
  release(&pi->lock);
    800049b0:	8526                	mv	a0,s1
    800049b2:	b7afc0ef          	jal	80000d2c <release>
  return i;
}
    800049b6:	8552                	mv	a0,s4
    800049b8:	60e6                	ld	ra,88(sp)
    800049ba:	6446                	ld	s0,80(sp)
    800049bc:	64a6                	ld	s1,72(sp)
    800049be:	6906                	ld	s2,64(sp)
    800049c0:	79e2                	ld	s3,56(sp)
    800049c2:	7a42                	ld	s4,48(sp)
    800049c4:	7aa2                	ld	s5,40(sp)
    800049c6:	6125                	addi	sp,sp,96
    800049c8:	8082                	ret
        i = -1;
    800049ca:	8a2a                	mv	s4,a0
    800049cc:	7b02                	ld	s6,32(sp)
    800049ce:	6be2                	ld	s7,24(sp)
    800049d0:	6c42                	ld	s8,16(sp)
    800049d2:	bfd9                	j	800049a8 <piperead+0xea>
    800049d4:	7b02                	ld	s6,32(sp)
    800049d6:	6be2                	ld	s7,24(sp)
    800049d8:	6c42                	ld	s8,16(sp)
    800049da:	b7f9                	j	800049a8 <piperead+0xea>

00000000800049dc <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    800049dc:	1141                	addi	sp,sp,-16
    800049de:	e406                	sd	ra,8(sp)
    800049e0:	e022                	sd	s0,0(sp)
    800049e2:	0800                	addi	s0,sp,16
    800049e4:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    800049e6:	0035151b          	slliw	a0,a0,0x3
    800049ea:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    800049ec:	8b89                	andi	a5,a5,2
    800049ee:	c399                	beqz	a5,800049f4 <flags2perm+0x18>
    perm |= PTE_W;
    800049f0:	00456513          	ori	a0,a0,4
  return perm;
}
    800049f4:	60a2                	ld	ra,8(sp)
    800049f6:	6402                	ld	s0,0(sp)
    800049f8:	0141                	addi	sp,sp,16
    800049fa:	8082                	ret

00000000800049fc <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800049fc:	de010113          	addi	sp,sp,-544
    80004a00:	20113c23          	sd	ra,536(sp)
    80004a04:	20813823          	sd	s0,528(sp)
    80004a08:	20913423          	sd	s1,520(sp)
    80004a0c:	21213023          	sd	s2,512(sp)
    80004a10:	1400                	addi	s0,sp,544
    80004a12:	892a                	mv	s2,a0
    80004a14:	dea43823          	sd	a0,-528(s0)
    80004a18:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004a1c:	842fd0ef          	jal	80001a5e <myproc>
    80004a20:	84aa                	mv	s1,a0

  begin_op();
    80004a22:	c62ff0ef          	jal	80003e84 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    80004a26:	854a                	mv	a0,s2
    80004a28:	a7eff0ef          	jal	80003ca6 <namei>
    80004a2c:	cd21                	beqz	a0,80004a84 <kexec+0x88>
    80004a2e:	fbd2                	sd	s4,496(sp)
    80004a30:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004a32:	9dbfe0ef          	jal	8000340c <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004a36:	04000713          	li	a4,64
    80004a3a:	4681                	li	a3,0
    80004a3c:	e5040613          	addi	a2,s0,-432
    80004a40:	4581                	li	a1,0
    80004a42:	8552                	mv	a0,s4
    80004a44:	da3fe0ef          	jal	800037e6 <readi>
    80004a48:	04000793          	li	a5,64
    80004a4c:	00f51a63          	bne	a0,a5,80004a60 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004a50:	e5042703          	lw	a4,-432(s0)
    80004a54:	464c47b7          	lui	a5,0x464c4
    80004a58:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004a5c:	02f70863          	beq	a4,a5,80004a8c <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    80004a60:	8552                	mv	a0,s4
    80004a62:	bfffe0ef          	jal	80003660 <iunlockput>
    end_op();
    80004a66:	caaff0ef          	jal	80003f10 <end_op>
  }
  return -1;
    80004a6a:	557d                	li	a0,-1
    80004a6c:	7a5e                	ld	s4,496(sp)
}
    80004a6e:	21813083          	ld	ra,536(sp)
    80004a72:	21013403          	ld	s0,528(sp)
    80004a76:	20813483          	ld	s1,520(sp)
    80004a7a:	20013903          	ld	s2,512(sp)
    80004a7e:	22010113          	addi	sp,sp,544
    80004a82:	8082                	ret
    end_op();
    80004a84:	c8cff0ef          	jal	80003f10 <end_op>
    return -1;
    80004a88:	557d                	li	a0,-1
    80004a8a:	b7d5                	j	80004a6e <kexec+0x72>
    80004a8c:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004a8e:	8526                	mv	a0,s1
    80004a90:	8d4fd0ef          	jal	80001b64 <proc_pagetable>
    80004a94:	8b2a                	mv	s6,a0
    80004a96:	26050e63          	beqz	a0,80004d12 <kexec+0x316>
    80004a9a:	ffce                	sd	s3,504(sp)
    80004a9c:	f7d6                	sd	s5,488(sp)
    80004a9e:	efde                	sd	s7,472(sp)
    80004aa0:	ebe2                	sd	s8,464(sp)
    80004aa2:	e7e6                	sd	s9,456(sp)
    80004aa4:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004aa6:	e8845783          	lhu	a5,-376(s0)
    80004aaa:	14078263          	beqz	a5,80004bee <kexec+0x1f2>
    80004aae:	ff6e                	sd	s11,440(sp)
    80004ab0:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ab4:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004ab6:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ab8:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    80004abc:	6c85                	lui	s9,0x1
    80004abe:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004ac2:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    80004ac6:	6a85                	lui	s5,0x1
    80004ac8:	a085                	j	80004b28 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004aca:	00003517          	auipc	a0,0x3
    80004ace:	b3e50513          	addi	a0,a0,-1218 # 80007608 <etext+0x608>
    80004ad2:	d63fb0ef          	jal	80000834 <panic>
    if (sz - i < PGSIZE)
    80004ad6:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004ad8:	874a                	mv	a4,s2
    80004ada:	009b86bb          	addw	a3,s7,s1
    80004ade:	4581                	li	a1,0
    80004ae0:	8552                	mv	a0,s4
    80004ae2:	d05fe0ef          	jal	800037e6 <readi>
    80004ae6:	22a91a63          	bne	s2,a0,80004d1a <kexec+0x31e>
  for (i = 0; i < sz; i += PGSIZE) {
    80004aea:	009a84bb          	addw	s1,s5,s1
    80004aee:	0334f263          	bgeu	s1,s3,80004b12 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004af2:	02049593          	slli	a1,s1,0x20
    80004af6:	9181                	srli	a1,a1,0x20
    80004af8:	95e2                	add	a1,a1,s8
    80004afa:	855a                	mv	a0,s6
    80004afc:	acbfc0ef          	jal	800015c6 <walkaddr>
    80004b00:	862a                	mv	a2,a0
    if (pa == 0)
    80004b02:	d561                	beqz	a0,80004aca <kexec+0xce>
    if (sz - i < PGSIZE)
    80004b04:	409987bb          	subw	a5,s3,s1
    80004b08:	893e                	mv	s2,a5
    80004b0a:	fcfcf6e3          	bgeu	s9,a5,80004ad6 <kexec+0xda>
    80004b0e:	8956                	mv	s2,s5
    80004b10:	b7d9                	j	80004ad6 <kexec+0xda>
    sz = sz1;
    80004b12:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004b16:	2d05                	addiw	s10,s10,1
    80004b18:	e0843783          	ld	a5,-504(s0)
    80004b1c:	0387869b          	addiw	a3,a5,56
    80004b20:	e8845783          	lhu	a5,-376(s0)
    80004b24:	06fd5d63          	bge	s10,a5,80004b9e <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004b28:	e0d43423          	sd	a3,-504(s0)
    80004b2c:	876e                	mv	a4,s11
    80004b2e:	e1840613          	addi	a2,s0,-488
    80004b32:	4581                	li	a1,0
    80004b34:	8552                	mv	a0,s4
    80004b36:	cb1fe0ef          	jal	800037e6 <readi>
    80004b3a:	1db51e63          	bne	a0,s11,80004d16 <kexec+0x31a>
    if (ph.type != ELF_PROG_LOAD)
    80004b3e:	e1842783          	lw	a5,-488(s0)
    80004b42:	4705                	li	a4,1
    80004b44:	fce799e3          	bne	a5,a4,80004b16 <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    80004b48:	e4043483          	ld	s1,-448(s0)
    80004b4c:	e3843783          	ld	a5,-456(s0)
    80004b50:	1ef4e363          	bltu	s1,a5,80004d36 <kexec+0x33a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004b54:	e2843783          	ld	a5,-472(s0)
    80004b58:	94be                	add	s1,s1,a5
    80004b5a:	1ef4e163          	bltu	s1,a5,80004d3c <kexec+0x340>
    if (ph.vaddr % PGSIZE != 0)
    80004b5e:	de843703          	ld	a4,-536(s0)
    80004b62:	8ff9                	and	a5,a5,a4
    80004b64:	1c079f63          	bnez	a5,80004d42 <kexec+0x346>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004b68:	e1c42503          	lw	a0,-484(s0)
    80004b6c:	e71ff0ef          	jal	800049dc <flags2perm>
    80004b70:	86aa                	mv	a3,a0
    80004b72:	8626                	mv	a2,s1
    80004b74:	85ca                	mv	a1,s2
    80004b76:	855a                	mv	a0,s6
    80004b78:	fb8fc0ef          	jal	80001330 <uvmalloc>
    80004b7c:	dea43c23          	sd	a0,-520(s0)
    80004b80:	1c050463          	beqz	a0,80004d48 <kexec+0x34c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004b84:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004b88:	00098863          	beqz	s3,80004b98 <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004b8c:	e2843c03          	ld	s8,-472(s0)
    80004b90:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004b94:	4481                	li	s1,0
    80004b96:	bfb1                	j	80004af2 <kexec+0xf6>
    sz = sz1;
    80004b98:	df843903          	ld	s2,-520(s0)
    80004b9c:	bfad                	j	80004b16 <kexec+0x11a>
    80004b9e:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    80004ba0:	8552                	mv	a0,s4
    80004ba2:	abffe0ef          	jal	80003660 <iunlockput>
  end_op();
    80004ba6:	b6aff0ef          	jal	80003f10 <end_op>
  p = myproc();
    80004baa:	eb5fc0ef          	jal	80001a5e <myproc>
    80004bae:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004bb0:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    80004bb4:	6c05                	lui	s8,0x1
    80004bb6:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    80004bb8:	9c4a                	add	s8,s8,s2
    80004bba:	77fd                	lui	a5,0xfffff
    80004bbc:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004bc0:	4691                	li	a3,4
    80004bc2:	6609                	lui	a2,0x2
    80004bc4:	9662                	add	a2,a2,s8
    80004bc6:	85e2                	mv	a1,s8
    80004bc8:	855a                	mv	a0,s6
    80004bca:	f66fc0ef          	jal	80001330 <uvmalloc>
    80004bce:	892a                	mv	s2,a0
    80004bd0:	e10d                	bnez	a0,80004bf2 <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    80004bd2:	85e2                	mv	a1,s8
    80004bd4:	855a                	mv	a0,s6
    80004bd6:	812fd0ef          	jal	80001be8 <proc_freepagetable>
  return -1;
    80004bda:	557d                	li	a0,-1
    80004bdc:	79fe                	ld	s3,504(sp)
    80004bde:	7a5e                	ld	s4,496(sp)
    80004be0:	7abe                	ld	s5,488(sp)
    80004be2:	7b1e                	ld	s6,480(sp)
    80004be4:	6bfe                	ld	s7,472(sp)
    80004be6:	6c5e                	ld	s8,464(sp)
    80004be8:	6cbe                	ld	s9,456(sp)
    80004bea:	6d1e                	ld	s10,448(sp)
    80004bec:	b549                	j	80004a6e <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004bee:	4901                	li	s2,0
    80004bf0:	bf45                	j	80004ba0 <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004bf2:	75f9                	lui	a1,0xffffe
    80004bf4:	95aa                	add	a1,a1,a0
    80004bf6:	855a                	mv	a0,s6
    80004bf8:	90bfc0ef          	jal	80001502 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004bfc:	80090a13          	addi	s4,s2,-2048
    80004c00:	800a0a13          	addi	s4,s4,-2048
  for (argc = 0; argv[argc]; argc++) {
    80004c04:	e0043783          	ld	a5,-512(s0)
    80004c08:	6388                	ld	a0,0(a5)
    80004c0a:	c545                	beqz	a0,80004cb2 <kexec+0x2b6>
  sp = sz;
    80004c0c:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004c0e:	4481                	li	s1,0
    ustack[argc] = sp;
    80004c10:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004c14:	adafc0ef          	jal	80000eee <strlen>
    80004c18:	0015079b          	addiw	a5,a0,1
    80004c1c:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004c20:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004c24:	134c6563          	bltu	s8,s4,80004d4e <kexec+0x352>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004c28:	e0043d03          	ld	s10,-512(s0)
    80004c2c:	000d3c83          	ld	s9,0(s10)
    80004c30:	8566                	mv	a0,s9
    80004c32:	abcfc0ef          	jal	80000eee <strlen>
    80004c36:	0015071b          	addiw	a4,a0,1
    80004c3a:	86e6                	mv	a3,s9
    80004c3c:	8662                	mv	a2,s8
    80004c3e:	85ca                	mv	a1,s2
    80004c40:	855a                	mv	a0,s6
    80004c42:	a15fc0ef          	jal	80001656 <copyout>
    80004c46:	10054663          	bltz	a0,80004d52 <kexec+0x356>
    ustack[argc] = sp;
    80004c4a:	00349793          	slli	a5,s1,0x3
    80004c4e:	97de                	add	a5,a5,s7
    80004c50:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb908>
  for (argc = 0; argv[argc]; argc++) {
    80004c54:	0485                	addi	s1,s1,1
    80004c56:	008d0793          	addi	a5,s10,8
    80004c5a:	e0f43023          	sd	a5,-512(s0)
    80004c5e:	008d3503          	ld	a0,8(s10)
    80004c62:	f94d                	bnez	a0,80004c14 <kexec+0x218>
  ustack[argc] = 0;
    80004c64:	00349793          	slli	a5,s1,0x3
    80004c68:	f9078793          	addi	a5,a5,-112
    80004c6c:	97a2                	add	a5,a5,s0
    80004c6e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004c72:	00349713          	slli	a4,s1,0x3
    80004c76:	0721                	addi	a4,a4,8
    80004c78:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004c7c:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004c80:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004c82:	f54be8e3          	bltu	s7,s4,80004bd2 <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004c86:	e9040693          	addi	a3,s0,-368
    80004c8a:	865e                	mv	a2,s7
    80004c8c:	85ca                	mv	a1,s2
    80004c8e:	855a                	mv	a0,s6
    80004c90:	9c7fc0ef          	jal	80001656 <copyout>
    80004c94:	f2054fe3          	bltz	a0,80004bd2 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004c98:	0589b783          	ld	a5,88(s3)
    80004c9c:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004ca0:	df043783          	ld	a5,-528(s0)
    80004ca4:	0007c703          	lbu	a4,0(a5)
    80004ca8:	c30d                	beqz	a4,80004cca <kexec+0x2ce>
    80004caa:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004cac:	02f00693          	li	a3,47
    80004cb0:	a801                	j	80004cc0 <kexec+0x2c4>
  sp = sz;
    80004cb2:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004cb4:	4481                	li	s1,0
    80004cb6:	b77d                	j	80004c64 <kexec+0x268>
  for (last = s = path; *s; s++)
    80004cb8:	0785                	addi	a5,a5,1
    80004cba:	fff7c703          	lbu	a4,-1(a5)
    80004cbe:	c711                	beqz	a4,80004cca <kexec+0x2ce>
    if (*s == '/')
    80004cc0:	fed71ce3          	bne	a4,a3,80004cb8 <kexec+0x2bc>
      last = s + 1;
    80004cc4:	def43823          	sd	a5,-528(s0)
    80004cc8:	bfc5                	j	80004cb8 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004cca:	4641                	li	a2,16
    80004ccc:	df043583          	ld	a1,-528(s0)
    80004cd0:	15898513          	addi	a0,s3,344
    80004cd4:	9e4fc0ef          	jal	80000eb8 <safestrcpy>
  oldpagetable = p->pagetable;
    80004cd8:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004cdc:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004ce0:	0529b423          	sd	s2,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004ce4:	0589b783          	ld	a5,88(s3)
    80004ce8:	e6843703          	ld	a4,-408(s0)
    80004cec:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004cee:	0589b783          	ld	a5,88(s3)
    80004cf2:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004cf6:	85d6                	mv	a1,s5
    80004cf8:	ef1fc0ef          	jal	80001be8 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004cfc:	0004851b          	sext.w	a0,s1
    80004d00:	79fe                	ld	s3,504(sp)
    80004d02:	7a5e                	ld	s4,496(sp)
    80004d04:	7abe                	ld	s5,488(sp)
    80004d06:	7b1e                	ld	s6,480(sp)
    80004d08:	6bfe                	ld	s7,472(sp)
    80004d0a:	6c5e                	ld	s8,464(sp)
    80004d0c:	6cbe                	ld	s9,456(sp)
    80004d0e:	6d1e                	ld	s10,448(sp)
    80004d10:	bbb9                	j	80004a6e <kexec+0x72>
    80004d12:	7b1e                	ld	s6,480(sp)
    80004d14:	b3b1                	j	80004a60 <kexec+0x64>
    80004d16:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004d1a:	df843583          	ld	a1,-520(s0)
    80004d1e:	855a                	mv	a0,s6
    80004d20:	ec9fc0ef          	jal	80001be8 <proc_freepagetable>
  if (ip) {
    80004d24:	79fe                	ld	s3,504(sp)
    80004d26:	7abe                	ld	s5,488(sp)
    80004d28:	7b1e                	ld	s6,480(sp)
    80004d2a:	6bfe                	ld	s7,472(sp)
    80004d2c:	6c5e                	ld	s8,464(sp)
    80004d2e:	6cbe                	ld	s9,456(sp)
    80004d30:	6d1e                	ld	s10,448(sp)
    80004d32:	7dfa                	ld	s11,440(sp)
    80004d34:	b335                	j	80004a60 <kexec+0x64>
    80004d36:	df243c23          	sd	s2,-520(s0)
    80004d3a:	b7c5                	j	80004d1a <kexec+0x31e>
    80004d3c:	df243c23          	sd	s2,-520(s0)
    80004d40:	bfe9                	j	80004d1a <kexec+0x31e>
    80004d42:	df243c23          	sd	s2,-520(s0)
    80004d46:	bfd1                	j	80004d1a <kexec+0x31e>
    80004d48:	df243c23          	sd	s2,-520(s0)
    80004d4c:	b7f9                	j	80004d1a <kexec+0x31e>
  sz = sz1;
    80004d4e:	8c4a                	mv	s8,s2
    80004d50:	b549                	j	80004bd2 <kexec+0x1d6>
    80004d52:	8c4a                	mv	s8,s2
    80004d54:	bdbd                	j	80004bd2 <kexec+0x1d6>

0000000080004d56 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004d56:	7179                	addi	sp,sp,-48
    80004d58:	f406                	sd	ra,40(sp)
    80004d5a:	f022                	sd	s0,32(sp)
    80004d5c:	ec26                	sd	s1,24(sp)
    80004d5e:	e84a                	sd	s2,16(sp)
    80004d60:	1800                	addi	s0,sp,48
    80004d62:	892e                	mv	s2,a1
    80004d64:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004d66:	fdc40593          	addi	a1,s0,-36
    80004d6a:	c7bfd0ef          	jal	800029e4 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004d6e:	fdc42703          	lw	a4,-36(s0)
    80004d72:	47bd                	li	a5,15
    80004d74:	02e7ea63          	bltu	a5,a4,80004da8 <argfd+0x52>
    80004d78:	ce7fc0ef          	jal	80001a5e <myproc>
    80004d7c:	fdc42703          	lw	a4,-36(s0)
    80004d80:	00371793          	slli	a5,a4,0x3
    80004d84:	0d078793          	addi	a5,a5,208
    80004d88:	953e                	add	a0,a0,a5
    80004d8a:	611c                	ld	a5,0(a0)
    80004d8c:	c385                	beqz	a5,80004dac <argfd+0x56>
    return -1;
  if (pfd)
    80004d8e:	00090463          	beqz	s2,80004d96 <argfd+0x40>
    *pfd = fd;
    80004d92:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004d96:	4501                	li	a0,0
  if (pf)
    80004d98:	c091                	beqz	s1,80004d9c <argfd+0x46>
    *pf = f;
    80004d9a:	e09c                	sd	a5,0(s1)
}
    80004d9c:	70a2                	ld	ra,40(sp)
    80004d9e:	7402                	ld	s0,32(sp)
    80004da0:	64e2                	ld	s1,24(sp)
    80004da2:	6942                	ld	s2,16(sp)
    80004da4:	6145                	addi	sp,sp,48
    80004da6:	8082                	ret
    return -1;
    80004da8:	557d                	li	a0,-1
    80004daa:	bfcd                	j	80004d9c <argfd+0x46>
    80004dac:	557d                	li	a0,-1
    80004dae:	b7fd                	j	80004d9c <argfd+0x46>

0000000080004db0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004db0:	1101                	addi	sp,sp,-32
    80004db2:	ec06                	sd	ra,24(sp)
    80004db4:	e822                	sd	s0,16(sp)
    80004db6:	e426                	sd	s1,8(sp)
    80004db8:	1000                	addi	s0,sp,32
    80004dba:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004dbc:	ca3fc0ef          	jal	80001a5e <myproc>
    80004dc0:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004dc2:	0d050793          	addi	a5,a0,208
    80004dc6:	4501                	li	a0,0
    80004dc8:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004dca:	6398                	ld	a4,0(a5)
    80004dcc:	cb19                	beqz	a4,80004de2 <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004dce:	2505                	addiw	a0,a0,1
    80004dd0:	07a1                	addi	a5,a5,8
    80004dd2:	fed51ce3          	bne	a0,a3,80004dca <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004dd6:	557d                	li	a0,-1
}
    80004dd8:	60e2                	ld	ra,24(sp)
    80004dda:	6442                	ld	s0,16(sp)
    80004ddc:	64a2                	ld	s1,8(sp)
    80004dde:	6105                	addi	sp,sp,32
    80004de0:	8082                	ret
      p->ofile[fd] = f;
    80004de2:	00351793          	slli	a5,a0,0x3
    80004de6:	0d078793          	addi	a5,a5,208
    80004dea:	963e                	add	a2,a2,a5
    80004dec:	e204                	sd	s1,0(a2)
      return fd;
    80004dee:	b7ed                	j	80004dd8 <fdalloc+0x28>

0000000080004df0 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004df0:	715d                	addi	sp,sp,-80
    80004df2:	e486                	sd	ra,72(sp)
    80004df4:	e0a2                	sd	s0,64(sp)
    80004df6:	fc26                	sd	s1,56(sp)
    80004df8:	f84a                	sd	s2,48(sp)
    80004dfa:	f052                	sd	s4,32(sp)
    80004dfc:	ec56                	sd	s5,24(sp)
    80004dfe:	e85a                	sd	s6,16(sp)
    80004e00:	0880                	addi	s0,sp,80
    80004e02:	8a2e                	mv	s4,a1
    80004e04:	8ab2                	mv	s5,a2
    80004e06:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004e08:	fb040593          	addi	a1,s0,-80
    80004e0c:	eb5fe0ef          	jal	80003cc0 <nameiparent>
    80004e10:	84aa                	mv	s1,a0
    80004e12:	12050f63          	beqz	a0,80004f50 <create+0x160>
    return 0;

  ilock(dp);
    80004e16:	df6fe0ef          	jal	8000340c <ilock>

  if (dp->nlink == 0) {
    80004e1a:	04a49783          	lh	a5,74(s1)
    80004e1e:	cbb9                	beqz	a5,80004e74 <create+0x84>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004e20:	7761                	lui	a4,0xffff8
    80004e22:	0705                	addi	a4,a4,1 # ffffffffffff8001 <end+0xffffffff7ffd4909>
    80004e24:	97ba                	add	a5,a5,a4
    80004e26:	e781                	bnez	a5,80004e2e <create+0x3e>
    80004e28:	fffa0793          	addi	a5,s4,-1
    80004e2c:	cba9                	beqz	a5,80004e7e <create+0x8e>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004e2e:	4601                	li	a2,0
    80004e30:	fb040593          	addi	a1,s0,-80
    80004e34:	8526                	mv	a0,s1
    80004e36:	bbffe0ef          	jal	800039f4 <dirlookup>
    80004e3a:	892a                	mv	s2,a0
    80004e3c:	c939                	beqz	a0,80004e92 <create+0xa2>
    iunlockput(dp);
    80004e3e:	8526                	mv	a0,s1
    80004e40:	821fe0ef          	jal	80003660 <iunlockput>
    ilock(ip);
    80004e44:	854a                	mv	a0,s2
    80004e46:	dc6fe0ef          	jal	8000340c <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004e4a:	4789                	li	a5,2
    80004e4c:	02fa1e63          	bne	s4,a5,80004e88 <create+0x98>
    80004e50:	04495783          	lhu	a5,68(s2)
    80004e54:	37f9                	addiw	a5,a5,-2
    80004e56:	17c2                	slli	a5,a5,0x30
    80004e58:	93c1                	srli	a5,a5,0x30
    80004e5a:	4705                	li	a4,1
    80004e5c:	02f76663          	bltu	a4,a5,80004e88 <create+0x98>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004e60:	854a                	mv	a0,s2
    80004e62:	60a6                	ld	ra,72(sp)
    80004e64:	6406                	ld	s0,64(sp)
    80004e66:	74e2                	ld	s1,56(sp)
    80004e68:	7942                	ld	s2,48(sp)
    80004e6a:	7a02                	ld	s4,32(sp)
    80004e6c:	6ae2                	ld	s5,24(sp)
    80004e6e:	6b42                	ld	s6,16(sp)
    80004e70:	6161                	addi	sp,sp,80
    80004e72:	8082                	ret
    iunlockput(dp);
    80004e74:	8526                	mv	a0,s1
    80004e76:	feafe0ef          	jal	80003660 <iunlockput>
    return 0;
    80004e7a:	4901                	li	s2,0
    80004e7c:	b7d5                	j	80004e60 <create+0x70>
    iunlockput(dp);
    80004e7e:	8526                	mv	a0,s1
    80004e80:	fe0fe0ef          	jal	80003660 <iunlockput>
    return 0;
    80004e84:	4901                	li	s2,0
    80004e86:	bfe9                	j	80004e60 <create+0x70>
    iunlockput(ip);
    80004e88:	854a                	mv	a0,s2
    80004e8a:	fd6fe0ef          	jal	80003660 <iunlockput>
    return 0;
    80004e8e:	4901                	li	s2,0
    80004e90:	bfc1                	j	80004e60 <create+0x70>
    80004e92:	f44e                	sd	s3,40(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004e94:	85d2                	mv	a1,s4
    80004e96:	4088                	lw	a0,0(s1)
    80004e98:	c04fe0ef          	jal	8000329c <ialloc>
    80004e9c:	89aa                	mv	s3,a0
    80004e9e:	cd1d                	beqz	a0,80004edc <create+0xec>
  ilock(ip);
    80004ea0:	d6cfe0ef          	jal	8000340c <ilock>
  ip->major = major;
    80004ea4:	05599323          	sh	s5,70(s3)
  ip->minor = minor;
    80004ea8:	05699423          	sh	s6,72(s3)
  ip->nlink = 1;
    80004eac:	4705                	li	a4,1
    80004eae:	04e99523          	sh	a4,74(s3)
  iupdate(ip);
    80004eb2:	854e                	mv	a0,s3
    80004eb4:	ca4fe0ef          	jal	80003358 <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80004eb8:	4705                	li	a4,1
    80004eba:	02ea0763          	beq	s4,a4,80004ee8 <create+0xf8>
  if (dirlink(dp, name, ip->inum) < 0)
    80004ebe:	0049a603          	lw	a2,4(s3)
    80004ec2:	fb040593          	addi	a1,s0,-80
    80004ec6:	8526                	mv	a0,s1
    80004ec8:	d35fe0ef          	jal	80003bfc <dirlink>
    80004ecc:	06054563          	bltz	a0,80004f36 <create+0x146>
  iunlockput(dp);
    80004ed0:	8526                	mv	a0,s1
    80004ed2:	f8efe0ef          	jal	80003660 <iunlockput>
  return ip;
    80004ed6:	894e                	mv	s2,s3
    80004ed8:	79a2                	ld	s3,40(sp)
    80004eda:	b759                	j	80004e60 <create+0x70>
    iunlockput(dp);
    80004edc:	8526                	mv	a0,s1
    80004ede:	f82fe0ef          	jal	80003660 <iunlockput>
    return 0;
    80004ee2:	894e                	mv	s2,s3
    80004ee4:	79a2                	ld	s3,40(sp)
    80004ee6:	bfad                	j	80004e60 <create+0x70>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004ee8:	0049a603          	lw	a2,4(s3)
    80004eec:	00002597          	auipc	a1,0x2
    80004ef0:	73c58593          	addi	a1,a1,1852 # 80007628 <etext+0x628>
    80004ef4:	854e                	mv	a0,s3
    80004ef6:	d07fe0ef          	jal	80003bfc <dirlink>
    80004efa:	02054e63          	bltz	a0,80004f36 <create+0x146>
    80004efe:	40d0                	lw	a2,4(s1)
    80004f00:	00002597          	auipc	a1,0x2
    80004f04:	73058593          	addi	a1,a1,1840 # 80007630 <etext+0x630>
    80004f08:	854e                	mv	a0,s3
    80004f0a:	cf3fe0ef          	jal	80003bfc <dirlink>
    80004f0e:	02054463          	bltz	a0,80004f36 <create+0x146>
  if (dirlink(dp, name, ip->inum) < 0)
    80004f12:	0049a603          	lw	a2,4(s3)
    80004f16:	fb040593          	addi	a1,s0,-80
    80004f1a:	8526                	mv	a0,s1
    80004f1c:	ce1fe0ef          	jal	80003bfc <dirlink>
    80004f20:	00054b63          	bltz	a0,80004f36 <create+0x146>
    dp->nlink++; // for ".."
    80004f24:	04a4d783          	lhu	a5,74(s1)
    80004f28:	2785                	addiw	a5,a5,1
    80004f2a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004f2e:	8526                	mv	a0,s1
    80004f30:	c28fe0ef          	jal	80003358 <iupdate>
    80004f34:	bf71                	j	80004ed0 <create+0xe0>
  ip->nlink = 0;
    80004f36:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    80004f3a:	854e                	mv	a0,s3
    80004f3c:	c1cfe0ef          	jal	80003358 <iupdate>
  iunlockput(ip);
    80004f40:	854e                	mv	a0,s3
    80004f42:	f1efe0ef          	jal	80003660 <iunlockput>
  iunlockput(dp);
    80004f46:	8526                	mv	a0,s1
    80004f48:	f18fe0ef          	jal	80003660 <iunlockput>
  return 0;
    80004f4c:	79a2                	ld	s3,40(sp)
    80004f4e:	bf09                	j	80004e60 <create+0x70>
    return 0;
    80004f50:	892a                	mv	s2,a0
    80004f52:	b739                	j	80004e60 <create+0x70>

0000000080004f54 <sys_dup>:
{
    80004f54:	7179                	addi	sp,sp,-48
    80004f56:	f406                	sd	ra,40(sp)
    80004f58:	f022                	sd	s0,32(sp)
    80004f5a:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004f5c:	fd840613          	addi	a2,s0,-40
    80004f60:	4581                	li	a1,0
    80004f62:	4501                	li	a0,0
    80004f64:	df3ff0ef          	jal	80004d56 <argfd>
    return -1;
    80004f68:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004f6a:	02054363          	bltz	a0,80004f90 <sys_dup+0x3c>
    80004f6e:	ec26                	sd	s1,24(sp)
    80004f70:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004f72:	fd843483          	ld	s1,-40(s0)
    80004f76:	8526                	mv	a0,s1
    80004f78:	e39ff0ef          	jal	80004db0 <fdalloc>
    80004f7c:	892a                	mv	s2,a0
    return -1;
    80004f7e:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004f80:	00054d63          	bltz	a0,80004f9a <sys_dup+0x46>
  filedup(f);
    80004f84:	8526                	mv	a0,s1
    80004f86:	b72ff0ef          	jal	800042f8 <filedup>
  return fd;
    80004f8a:	87ca                	mv	a5,s2
    80004f8c:	64e2                	ld	s1,24(sp)
    80004f8e:	6942                	ld	s2,16(sp)
}
    80004f90:	853e                	mv	a0,a5
    80004f92:	70a2                	ld	ra,40(sp)
    80004f94:	7402                	ld	s0,32(sp)
    80004f96:	6145                	addi	sp,sp,48
    80004f98:	8082                	ret
    80004f9a:	64e2                	ld	s1,24(sp)
    80004f9c:	6942                	ld	s2,16(sp)
    80004f9e:	bfcd                	j	80004f90 <sys_dup+0x3c>

0000000080004fa0 <sys_read>:
{
    80004fa0:	7179                	addi	sp,sp,-48
    80004fa2:	f406                	sd	ra,40(sp)
    80004fa4:	f022                	sd	s0,32(sp)
    80004fa6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004fa8:	fd840593          	addi	a1,s0,-40
    80004fac:	4505                	li	a0,1
    80004fae:	a53fd0ef          	jal	80002a00 <argaddr>
  argint(2, &n);
    80004fb2:	fe440593          	addi	a1,s0,-28
    80004fb6:	4509                	li	a0,2
    80004fb8:	a2dfd0ef          	jal	800029e4 <argint>
  if (argfd(0, 0, &f) < 0)
    80004fbc:	fe840613          	addi	a2,s0,-24
    80004fc0:	4581                	li	a1,0
    80004fc2:	4501                	li	a0,0
    80004fc4:	d93ff0ef          	jal	80004d56 <argfd>
    80004fc8:	87aa                	mv	a5,a0
    return -1;
    80004fca:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004fcc:	0007ca63          	bltz	a5,80004fe0 <sys_read+0x40>
  return fileread(f, p, n);
    80004fd0:	fe442603          	lw	a2,-28(s0)
    80004fd4:	fd843583          	ld	a1,-40(s0)
    80004fd8:	fe843503          	ld	a0,-24(s0)
    80004fdc:	c94ff0ef          	jal	80004470 <fileread>
}
    80004fe0:	70a2                	ld	ra,40(sp)
    80004fe2:	7402                	ld	s0,32(sp)
    80004fe4:	6145                	addi	sp,sp,48
    80004fe6:	8082                	ret

0000000080004fe8 <sys_write>:
{
    80004fe8:	7179                	addi	sp,sp,-48
    80004fea:	f406                	sd	ra,40(sp)
    80004fec:	f022                	sd	s0,32(sp)
    80004fee:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004ff0:	fd840593          	addi	a1,s0,-40
    80004ff4:	4505                	li	a0,1
    80004ff6:	a0bfd0ef          	jal	80002a00 <argaddr>
  argint(2, &n);
    80004ffa:	fe440593          	addi	a1,s0,-28
    80004ffe:	4509                	li	a0,2
    80005000:	9e5fd0ef          	jal	800029e4 <argint>
  if (argfd(0, 0, &f) < 0)
    80005004:	fe840613          	addi	a2,s0,-24
    80005008:	4581                	li	a1,0
    8000500a:	4501                	li	a0,0
    8000500c:	d4bff0ef          	jal	80004d56 <argfd>
    80005010:	87aa                	mv	a5,a0
    return -1;
    80005012:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005014:	0007ca63          	bltz	a5,80005028 <sys_write+0x40>
  return filewrite(f, p, n);
    80005018:	fe442603          	lw	a2,-28(s0)
    8000501c:	fd843583          	ld	a1,-40(s0)
    80005020:	fe843503          	ld	a0,-24(s0)
    80005024:	d1aff0ef          	jal	8000453e <filewrite>
}
    80005028:	70a2                	ld	ra,40(sp)
    8000502a:	7402                	ld	s0,32(sp)
    8000502c:	6145                	addi	sp,sp,48
    8000502e:	8082                	ret

0000000080005030 <sys_close>:
{
    80005030:	1101                	addi	sp,sp,-32
    80005032:	ec06                	sd	ra,24(sp)
    80005034:	e822                	sd	s0,16(sp)
    80005036:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80005038:	fe040613          	addi	a2,s0,-32
    8000503c:	fec40593          	addi	a1,s0,-20
    80005040:	4501                	li	a0,0
    80005042:	d15ff0ef          	jal	80004d56 <argfd>
    return -1;
    80005046:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80005048:	02054163          	bltz	a0,8000506a <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    8000504c:	a13fc0ef          	jal	80001a5e <myproc>
    80005050:	fec42783          	lw	a5,-20(s0)
    80005054:	078e                	slli	a5,a5,0x3
    80005056:	0d078793          	addi	a5,a5,208
    8000505a:	953e                	add	a0,a0,a5
    8000505c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005060:	fe043503          	ld	a0,-32(s0)
    80005064:	adaff0ef          	jal	8000433e <fileclose>
  return 0;
    80005068:	4781                	li	a5,0
}
    8000506a:	853e                	mv	a0,a5
    8000506c:	60e2                	ld	ra,24(sp)
    8000506e:	6442                	ld	s0,16(sp)
    80005070:	6105                	addi	sp,sp,32
    80005072:	8082                	ret

0000000080005074 <sys_fstat>:
{
    80005074:	1101                	addi	sp,sp,-32
    80005076:	ec06                	sd	ra,24(sp)
    80005078:	e822                	sd	s0,16(sp)
    8000507a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000507c:	fe040593          	addi	a1,s0,-32
    80005080:	4505                	li	a0,1
    80005082:	97ffd0ef          	jal	80002a00 <argaddr>
  if (argfd(0, 0, &f) < 0)
    80005086:	fe840613          	addi	a2,s0,-24
    8000508a:	4581                	li	a1,0
    8000508c:	4501                	li	a0,0
    8000508e:	cc9ff0ef          	jal	80004d56 <argfd>
    80005092:	87aa                	mv	a5,a0
    return -1;
    80005094:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005096:	0007c863          	bltz	a5,800050a6 <sys_fstat+0x32>
  return filestat(f, st);
    8000509a:	fe043583          	ld	a1,-32(s0)
    8000509e:	fe843503          	ld	a0,-24(s0)
    800050a2:	b5eff0ef          	jal	80004400 <filestat>
}
    800050a6:	60e2                	ld	ra,24(sp)
    800050a8:	6442                	ld	s0,16(sp)
    800050aa:	6105                	addi	sp,sp,32
    800050ac:	8082                	ret

00000000800050ae <sys_link>:
{
    800050ae:	7169                	addi	sp,sp,-304
    800050b0:	f606                	sd	ra,296(sp)
    800050b2:	f222                	sd	s0,288(sp)
    800050b4:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050b6:	08000613          	li	a2,128
    800050ba:	ed040593          	addi	a1,s0,-304
    800050be:	4501                	li	a0,0
    800050c0:	95dfd0ef          	jal	80002a1c <argstr>
    return -1;
    800050c4:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050c6:	10054163          	bltz	a0,800051c8 <sys_link+0x11a>
    800050ca:	08000613          	li	a2,128
    800050ce:	f5040593          	addi	a1,s0,-176
    800050d2:	4505                	li	a0,1
    800050d4:	949fd0ef          	jal	80002a1c <argstr>
    return -1;
    800050d8:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050da:	0e054763          	bltz	a0,800051c8 <sys_link+0x11a>
    800050de:	ee26                	sd	s1,280(sp)
  begin_op();
    800050e0:	da5fe0ef          	jal	80003e84 <begin_op>
  if ((ip = namei(old)) == 0) {
    800050e4:	ed040513          	addi	a0,s0,-304
    800050e8:	bbffe0ef          	jal	80003ca6 <namei>
    800050ec:	84aa                	mv	s1,a0
    800050ee:	cd35                	beqz	a0,8000516a <sys_link+0xbc>
  ilock(ip);
    800050f0:	b1cfe0ef          	jal	8000340c <ilock>
  if (ip->type == T_DIR) {
    800050f4:	04449703          	lh	a4,68(s1)
    800050f8:	4785                	li	a5,1
    800050fa:	06f70d63          	beq	a4,a5,80005174 <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    800050fe:	04a49783          	lh	a5,74(s1)
    80005102:	6721                	lui	a4,0x8
    80005104:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80005106:	06e78f63          	beq	a5,a4,80005184 <sys_link+0xd6>
    8000510a:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000510c:	2785                	addiw	a5,a5,1
    8000510e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005112:	8526                	mv	a0,s1
    80005114:	a44fe0ef          	jal	80003358 <iupdate>
  iunlock(ip);
    80005118:	8526                	mv	a0,s1
    8000511a:	ba0fe0ef          	jal	800034ba <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    8000511e:	fd040593          	addi	a1,s0,-48
    80005122:	f5040513          	addi	a0,s0,-176
    80005126:	b9bfe0ef          	jal	80003cc0 <nameiparent>
    8000512a:	892a                	mv	s2,a0
    8000512c:	c93d                	beqz	a0,800051a2 <sys_link+0xf4>
  ilock(dp);
    8000512e:	adefe0ef          	jal	8000340c <ilock>
  if (dp->nlink == 0) {
    80005132:	04a91783          	lh	a5,74(s2)
    80005136:	cfb9                	beqz	a5,80005194 <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    80005138:	854a                	mv	a0,s2
    8000513a:	00092703          	lw	a4,0(s2)
    8000513e:	409c                	lw	a5,0(s1)
    80005140:	04f71e63          	bne	a4,a5,8000519c <sys_link+0xee>
    80005144:	40d0                	lw	a2,4(s1)
    80005146:	fd040593          	addi	a1,s0,-48
    8000514a:	ab3fe0ef          	jal	80003bfc <dirlink>
    8000514e:	04054763          	bltz	a0,8000519c <sys_link+0xee>
  iunlockput(dp);
    80005152:	854a                	mv	a0,s2
    80005154:	d0cfe0ef          	jal	80003660 <iunlockput>
  iput(ip);
    80005158:	8526                	mv	a0,s1
    8000515a:	c34fe0ef          	jal	8000358e <iput>
  end_op();
    8000515e:	db3fe0ef          	jal	80003f10 <end_op>
  return 0;
    80005162:	4781                	li	a5,0
    80005164:	64f2                	ld	s1,280(sp)
    80005166:	6952                	ld	s2,272(sp)
    80005168:	a085                	j	800051c8 <sys_link+0x11a>
    end_op();
    8000516a:	da7fe0ef          	jal	80003f10 <end_op>
    return -1;
    8000516e:	57fd                	li	a5,-1
    80005170:	64f2                	ld	s1,280(sp)
    80005172:	a899                	j	800051c8 <sys_link+0x11a>
    iunlockput(ip);
    80005174:	8526                	mv	a0,s1
    80005176:	ceafe0ef          	jal	80003660 <iunlockput>
    end_op();
    8000517a:	d97fe0ef          	jal	80003f10 <end_op>
    return -1;
    8000517e:	57fd                	li	a5,-1
    80005180:	64f2                	ld	s1,280(sp)
    80005182:	a099                	j	800051c8 <sys_link+0x11a>
    iunlockput(ip);
    80005184:	8526                	mv	a0,s1
    80005186:	cdafe0ef          	jal	80003660 <iunlockput>
    end_op();
    8000518a:	d87fe0ef          	jal	80003f10 <end_op>
    return -1;
    8000518e:	57fd                	li	a5,-1
    80005190:	64f2                	ld	s1,280(sp)
    80005192:	a81d                	j	800051c8 <sys_link+0x11a>
    iunlockput(dp);
    80005194:	854a                	mv	a0,s2
    80005196:	ccafe0ef          	jal	80003660 <iunlockput>
    goto bad;
    8000519a:	a021                	j	800051a2 <sys_link+0xf4>
    iunlockput(dp);
    8000519c:	854a                	mv	a0,s2
    8000519e:	cc2fe0ef          	jal	80003660 <iunlockput>
  ilock(ip);
    800051a2:	8526                	mv	a0,s1
    800051a4:	a68fe0ef          	jal	8000340c <ilock>
  ip->nlink--;
    800051a8:	04a4d783          	lhu	a5,74(s1)
    800051ac:	37fd                	addiw	a5,a5,-1
    800051ae:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800051b2:	8526                	mv	a0,s1
    800051b4:	9a4fe0ef          	jal	80003358 <iupdate>
  iunlockput(ip);
    800051b8:	8526                	mv	a0,s1
    800051ba:	ca6fe0ef          	jal	80003660 <iunlockput>
  end_op();
    800051be:	d53fe0ef          	jal	80003f10 <end_op>
  return -1;
    800051c2:	57fd                	li	a5,-1
    800051c4:	64f2                	ld	s1,280(sp)
    800051c6:	6952                	ld	s2,272(sp)
}
    800051c8:	853e                	mv	a0,a5
    800051ca:	70b2                	ld	ra,296(sp)
    800051cc:	7412                	ld	s0,288(sp)
    800051ce:	6155                	addi	sp,sp,304
    800051d0:	8082                	ret

00000000800051d2 <sys_unlink>:
{
    800051d2:	7151                	addi	sp,sp,-240
    800051d4:	f586                	sd	ra,232(sp)
    800051d6:	f1a2                	sd	s0,224(sp)
    800051d8:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    800051da:	08000613          	li	a2,128
    800051de:	f3040593          	addi	a1,s0,-208
    800051e2:	4501                	li	a0,0
    800051e4:	839fd0ef          	jal	80002a1c <argstr>
    800051e8:	14054d63          	bltz	a0,80005342 <sys_unlink+0x170>
    800051ec:	eda6                	sd	s1,216(sp)
  begin_op();
    800051ee:	c97fe0ef          	jal	80003e84 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    800051f2:	fb040593          	addi	a1,s0,-80
    800051f6:	f3040513          	addi	a0,s0,-208
    800051fa:	ac7fe0ef          	jal	80003cc0 <nameiparent>
    800051fe:	84aa                	mv	s1,a0
    80005200:	c955                	beqz	a0,800052b4 <sys_unlink+0xe2>
  ilock(dp);
    80005202:	a0afe0ef          	jal	8000340c <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005206:	00002597          	auipc	a1,0x2
    8000520a:	42258593          	addi	a1,a1,1058 # 80007628 <etext+0x628>
    8000520e:	fb040513          	addi	a0,s0,-80
    80005212:	fccfe0ef          	jal	800039de <namecmp>
    80005216:	10050b63          	beqz	a0,8000532c <sys_unlink+0x15a>
    8000521a:	00002597          	auipc	a1,0x2
    8000521e:	41658593          	addi	a1,a1,1046 # 80007630 <etext+0x630>
    80005222:	fb040513          	addi	a0,s0,-80
    80005226:	fb8fe0ef          	jal	800039de <namecmp>
    8000522a:	10050163          	beqz	a0,8000532c <sys_unlink+0x15a>
    8000522e:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    80005230:	f2c40613          	addi	a2,s0,-212
    80005234:	fb040593          	addi	a1,s0,-80
    80005238:	8526                	mv	a0,s1
    8000523a:	fbafe0ef          	jal	800039f4 <dirlookup>
    8000523e:	892a                	mv	s2,a0
    80005240:	0e050563          	beqz	a0,8000532a <sys_unlink+0x158>
    80005244:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80005246:	9c6fe0ef          	jal	8000340c <ilock>
  if (ip->nlink < 1)
    8000524a:	04a91783          	lh	a5,74(s2)
    8000524e:	06f05863          	blez	a5,800052be <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    80005252:	04491703          	lh	a4,68(s2)
    80005256:	4785                	li	a5,1
    80005258:	06f70963          	beq	a4,a5,800052ca <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    8000525c:	fc040993          	addi	s3,s0,-64
    80005260:	4641                	li	a2,16
    80005262:	4581                	li	a1,0
    80005264:	854e                	mv	a0,s3
    80005266:	afffb0ef          	jal	80000d64 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000526a:	4741                	li	a4,16
    8000526c:	f2c42683          	lw	a3,-212(s0)
    80005270:	864e                	mv	a2,s3
    80005272:	4581                	li	a1,0
    80005274:	8526                	mv	a0,s1
    80005276:	e62fe0ef          	jal	800038d8 <writei>
    8000527a:	47c1                	li	a5,16
    8000527c:	08f51863          	bne	a0,a5,8000530c <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    80005280:	04491703          	lh	a4,68(s2)
    80005284:	4785                	li	a5,1
    80005286:	08f70963          	beq	a4,a5,80005318 <sys_unlink+0x146>
  iunlockput(dp);
    8000528a:	8526                	mv	a0,s1
    8000528c:	bd4fe0ef          	jal	80003660 <iunlockput>
  ip->nlink--;
    80005290:	04a95783          	lhu	a5,74(s2)
    80005294:	37fd                	addiw	a5,a5,-1
    80005296:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000529a:	854a                	mv	a0,s2
    8000529c:	8bcfe0ef          	jal	80003358 <iupdate>
  iunlockput(ip);
    800052a0:	854a                	mv	a0,s2
    800052a2:	bbefe0ef          	jal	80003660 <iunlockput>
  end_op();
    800052a6:	c6bfe0ef          	jal	80003f10 <end_op>
  return 0;
    800052aa:	4501                	li	a0,0
    800052ac:	64ee                	ld	s1,216(sp)
    800052ae:	694e                	ld	s2,208(sp)
    800052b0:	69ae                	ld	s3,200(sp)
    800052b2:	a061                	j	8000533a <sys_unlink+0x168>
    end_op();
    800052b4:	c5dfe0ef          	jal	80003f10 <end_op>
    return -1;
    800052b8:	557d                	li	a0,-1
    800052ba:	64ee                	ld	s1,216(sp)
    800052bc:	a8bd                	j	8000533a <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800052be:	00002517          	auipc	a0,0x2
    800052c2:	37a50513          	addi	a0,a0,890 # 80007638 <etext+0x638>
    800052c6:	d6efb0ef          	jal	80000834 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    800052ca:	04c92703          	lw	a4,76(s2)
    800052ce:	02000793          	li	a5,32
    800052d2:	f8e7f5e3          	bgeu	a5,a4,8000525c <sys_unlink+0x8a>
    800052d6:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800052d8:	4741                	li	a4,16
    800052da:	86ce                	mv	a3,s3
    800052dc:	f1840613          	addi	a2,s0,-232
    800052e0:	4581                	li	a1,0
    800052e2:	854a                	mv	a0,s2
    800052e4:	d02fe0ef          	jal	800037e6 <readi>
    800052e8:	47c1                	li	a5,16
    800052ea:	00f51b63          	bne	a0,a5,80005300 <sys_unlink+0x12e>
    if (de.inum != 0)
    800052ee:	f1845783          	lhu	a5,-232(s0)
    800052f2:	ebb1                	bnez	a5,80005346 <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    800052f4:	29c1                	addiw	s3,s3,16
    800052f6:	04c92783          	lw	a5,76(s2)
    800052fa:	fcf9efe3          	bltu	s3,a5,800052d8 <sys_unlink+0x106>
    800052fe:	bfb9                	j	8000525c <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005300:	00002517          	auipc	a0,0x2
    80005304:	35050513          	addi	a0,a0,848 # 80007650 <etext+0x650>
    80005308:	d2cfb0ef          	jal	80000834 <panic>
    panic("unlink: writei");
    8000530c:	00002517          	auipc	a0,0x2
    80005310:	35c50513          	addi	a0,a0,860 # 80007668 <etext+0x668>
    80005314:	d20fb0ef          	jal	80000834 <panic>
    dp->nlink--;
    80005318:	04a4d783          	lhu	a5,74(s1)
    8000531c:	37fd                	addiw	a5,a5,-1
    8000531e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005322:	8526                	mv	a0,s1
    80005324:	834fe0ef          	jal	80003358 <iupdate>
    80005328:	b78d                	j	8000528a <sys_unlink+0xb8>
    8000532a:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000532c:	8526                	mv	a0,s1
    8000532e:	b32fe0ef          	jal	80003660 <iunlockput>
  end_op();
    80005332:	bdffe0ef          	jal	80003f10 <end_op>
  return -1;
    80005336:	557d                	li	a0,-1
    80005338:	64ee                	ld	s1,216(sp)
}
    8000533a:	70ae                	ld	ra,232(sp)
    8000533c:	740e                	ld	s0,224(sp)
    8000533e:	616d                	addi	sp,sp,240
    80005340:	8082                	ret
    return -1;
    80005342:	557d                	li	a0,-1
    80005344:	bfdd                	j	8000533a <sys_unlink+0x168>
    iunlockput(ip);
    80005346:	854a                	mv	a0,s2
    80005348:	b18fe0ef          	jal	80003660 <iunlockput>
    goto bad;
    8000534c:	694e                	ld	s2,208(sp)
    8000534e:	69ae                	ld	s3,200(sp)
    80005350:	bff1                	j	8000532c <sys_unlink+0x15a>

0000000080005352 <sys_open>:

uint64
sys_open(void)
{
    80005352:	7131                	addi	sp,sp,-192
    80005354:	fd06                	sd	ra,184(sp)
    80005356:	f922                	sd	s0,176(sp)
    80005358:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000535a:	f4c40593          	addi	a1,s0,-180
    8000535e:	4505                	li	a0,1
    80005360:	e84fd0ef          	jal	800029e4 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005364:	08000613          	li	a2,128
    80005368:	f5040593          	addi	a1,s0,-176
    8000536c:	4501                	li	a0,0
    8000536e:	eaefd0ef          	jal	80002a1c <argstr>
    80005372:	87aa                	mv	a5,a0
    return -1;
    80005374:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005376:	0a07c363          	bltz	a5,8000541c <sys_open+0xca>
    8000537a:	f526                	sd	s1,168(sp)

  begin_op();
    8000537c:	b09fe0ef          	jal	80003e84 <begin_op>

  if (omode & O_CREATE) {
    80005380:	f4c42783          	lw	a5,-180(s0)
    80005384:	2007f793          	andi	a5,a5,512
    80005388:	c3dd                	beqz	a5,8000542e <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    8000538a:	4681                	li	a3,0
    8000538c:	4601                	li	a2,0
    8000538e:	4589                	li	a1,2
    80005390:	f5040513          	addi	a0,s0,-176
    80005394:	a5dff0ef          	jal	80004df0 <create>
    80005398:	84aa                	mv	s1,a0
    if (ip == 0) {
    8000539a:	c549                	beqz	a0,80005424 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    8000539c:	04449703          	lh	a4,68(s1)
    800053a0:	478d                	li	a5,3
    800053a2:	00f71763          	bne	a4,a5,800053b0 <sys_open+0x5e>
    800053a6:	0464d703          	lhu	a4,70(s1)
    800053aa:	47a5                	li	a5,9
    800053ac:	0ae7ee63          	bltu	a5,a4,80005468 <sys_open+0x116>
    800053b0:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    800053b2:	ee9fe0ef          	jal	8000429a <filealloc>
    800053b6:	892a                	mv	s2,a0
    800053b8:	c561                	beqz	a0,80005480 <sys_open+0x12e>
    800053ba:	ed4e                	sd	s3,152(sp)
    800053bc:	9f5ff0ef          	jal	80004db0 <fdalloc>
    800053c0:	89aa                	mv	s3,a0
    800053c2:	0a054b63          	bltz	a0,80005478 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    800053c6:	04449703          	lh	a4,68(s1)
    800053ca:	478d                	li	a5,3
    800053cc:	0cf70363          	beq	a4,a5,80005492 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800053d0:	4789                	li	a5,2
    800053d2:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800053d6:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800053da:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800053de:	f4c42783          	lw	a5,-180(s0)
    800053e2:	0017f713          	andi	a4,a5,1
    800053e6:	00174713          	xori	a4,a4,1
    800053ea:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800053ee:	0037f713          	andi	a4,a5,3
    800053f2:	00e03733          	snez	a4,a4
    800053f6:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    800053fa:	4007f793          	andi	a5,a5,1024
    800053fe:	c791                	beqz	a5,8000540a <sys_open+0xb8>
    80005400:	04449703          	lh	a4,68(s1)
    80005404:	4789                	li	a5,2
    80005406:	08f70d63          	beq	a4,a5,800054a0 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    8000540a:	8526                	mv	a0,s1
    8000540c:	8aefe0ef          	jal	800034ba <iunlock>
  end_op();
    80005410:	b01fe0ef          	jal	80003f10 <end_op>

  return fd;
    80005414:	854e                	mv	a0,s3
    80005416:	74aa                	ld	s1,168(sp)
    80005418:	790a                	ld	s2,160(sp)
    8000541a:	69ea                	ld	s3,152(sp)
}
    8000541c:	70ea                	ld	ra,184(sp)
    8000541e:	744a                	ld	s0,176(sp)
    80005420:	6129                	addi	sp,sp,192
    80005422:	8082                	ret
      end_op();
    80005424:	aedfe0ef          	jal	80003f10 <end_op>
      return -1;
    80005428:	557d                	li	a0,-1
    8000542a:	74aa                	ld	s1,168(sp)
    8000542c:	bfc5                	j	8000541c <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    8000542e:	f5040513          	addi	a0,s0,-176
    80005432:	875fe0ef          	jal	80003ca6 <namei>
    80005436:	84aa                	mv	s1,a0
    80005438:	c11d                	beqz	a0,8000545e <sys_open+0x10c>
    ilock(ip);
    8000543a:	fd3fd0ef          	jal	8000340c <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    8000543e:	04449703          	lh	a4,68(s1)
    80005442:	4785                	li	a5,1
    80005444:	f4f71ce3          	bne	a4,a5,8000539c <sys_open+0x4a>
    80005448:	f4c42783          	lw	a5,-180(s0)
    8000544c:	d3b5                	beqz	a5,800053b0 <sys_open+0x5e>
      iunlockput(ip);
    8000544e:	8526                	mv	a0,s1
    80005450:	a10fe0ef          	jal	80003660 <iunlockput>
      end_op();
    80005454:	abdfe0ef          	jal	80003f10 <end_op>
      return -1;
    80005458:	557d                	li	a0,-1
    8000545a:	74aa                	ld	s1,168(sp)
    8000545c:	b7c1                	j	8000541c <sys_open+0xca>
      end_op();
    8000545e:	ab3fe0ef          	jal	80003f10 <end_op>
      return -1;
    80005462:	557d                	li	a0,-1
    80005464:	74aa                	ld	s1,168(sp)
    80005466:	bf5d                	j	8000541c <sys_open+0xca>
    iunlockput(ip);
    80005468:	8526                	mv	a0,s1
    8000546a:	9f6fe0ef          	jal	80003660 <iunlockput>
    end_op();
    8000546e:	aa3fe0ef          	jal	80003f10 <end_op>
    return -1;
    80005472:	557d                	li	a0,-1
    80005474:	74aa                	ld	s1,168(sp)
    80005476:	b75d                	j	8000541c <sys_open+0xca>
      fileclose(f);
    80005478:	854a                	mv	a0,s2
    8000547a:	ec5fe0ef          	jal	8000433e <fileclose>
    8000547e:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005480:	8526                	mv	a0,s1
    80005482:	9defe0ef          	jal	80003660 <iunlockput>
    end_op();
    80005486:	a8bfe0ef          	jal	80003f10 <end_op>
    return -1;
    8000548a:	557d                	li	a0,-1
    8000548c:	74aa                	ld	s1,168(sp)
    8000548e:	790a                	ld	s2,160(sp)
    80005490:	b771                	j	8000541c <sys_open+0xca>
    f->type = FD_DEVICE;
    80005492:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005496:	04649783          	lh	a5,70(s1)
    8000549a:	02f91223          	sh	a5,36(s2)
    8000549e:	bf35                	j	800053da <sys_open+0x88>
    itrunc(ip);
    800054a0:	8526                	mv	a0,s1
    800054a2:	858fe0ef          	jal	800034fa <itrunc>
    800054a6:	b795                	j	8000540a <sys_open+0xb8>

00000000800054a8 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800054a8:	7175                	addi	sp,sp,-144
    800054aa:	e506                	sd	ra,136(sp)
    800054ac:	e122                	sd	s0,128(sp)
    800054ae:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800054b0:	9d5fe0ef          	jal	80003e84 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    800054b4:	08000613          	li	a2,128
    800054b8:	f7040593          	addi	a1,s0,-144
    800054bc:	4501                	li	a0,0
    800054be:	d5efd0ef          	jal	80002a1c <argstr>
    800054c2:	02054363          	bltz	a0,800054e8 <sys_mkdir+0x40>
    800054c6:	4681                	li	a3,0
    800054c8:	4601                	li	a2,0
    800054ca:	4585                	li	a1,1
    800054cc:	f7040513          	addi	a0,s0,-144
    800054d0:	921ff0ef          	jal	80004df0 <create>
    800054d4:	c911                	beqz	a0,800054e8 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800054d6:	98afe0ef          	jal	80003660 <iunlockput>
  end_op();
    800054da:	a37fe0ef          	jal	80003f10 <end_op>
  return 0;
    800054de:	4501                	li	a0,0
}
    800054e0:	60aa                	ld	ra,136(sp)
    800054e2:	640a                	ld	s0,128(sp)
    800054e4:	6149                	addi	sp,sp,144
    800054e6:	8082                	ret
    end_op();
    800054e8:	a29fe0ef          	jal	80003f10 <end_op>
    return -1;
    800054ec:	557d                	li	a0,-1
    800054ee:	bfcd                	j	800054e0 <sys_mkdir+0x38>

00000000800054f0 <sys_mknod>:

uint64
sys_mknod(void)
{
    800054f0:	7135                	addi	sp,sp,-160
    800054f2:	ed06                	sd	ra,152(sp)
    800054f4:	e922                	sd	s0,144(sp)
    800054f6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800054f8:	98dfe0ef          	jal	80003e84 <begin_op>
  argint(1, &major);
    800054fc:	f6c40593          	addi	a1,s0,-148
    80005500:	4505                	li	a0,1
    80005502:	ce2fd0ef          	jal	800029e4 <argint>
  argint(2, &minor);
    80005506:	f6840593          	addi	a1,s0,-152
    8000550a:	4509                	li	a0,2
    8000550c:	cd8fd0ef          	jal	800029e4 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005510:	08000613          	li	a2,128
    80005514:	f7040593          	addi	a1,s0,-144
    80005518:	4501                	li	a0,0
    8000551a:	d02fd0ef          	jal	80002a1c <argstr>
    8000551e:	02054563          	bltz	a0,80005548 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    80005522:	f6841683          	lh	a3,-152(s0)
    80005526:	f6c41603          	lh	a2,-148(s0)
    8000552a:	458d                	li	a1,3
    8000552c:	f7040513          	addi	a0,s0,-144
    80005530:	8c1ff0ef          	jal	80004df0 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005534:	c911                	beqz	a0,80005548 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005536:	92afe0ef          	jal	80003660 <iunlockput>
  end_op();
    8000553a:	9d7fe0ef          	jal	80003f10 <end_op>
  return 0;
    8000553e:	4501                	li	a0,0
}
    80005540:	60ea                	ld	ra,152(sp)
    80005542:	644a                	ld	s0,144(sp)
    80005544:	610d                	addi	sp,sp,160
    80005546:	8082                	ret
    end_op();
    80005548:	9c9fe0ef          	jal	80003f10 <end_op>
    return -1;
    8000554c:	557d                	li	a0,-1
    8000554e:	bfcd                	j	80005540 <sys_mknod+0x50>

0000000080005550 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005550:	7135                	addi	sp,sp,-160
    80005552:	ed06                	sd	ra,152(sp)
    80005554:	e922                	sd	s0,144(sp)
    80005556:	e14a                	sd	s2,128(sp)
    80005558:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000555a:	d04fc0ef          	jal	80001a5e <myproc>
    8000555e:	892a                	mv	s2,a0

  begin_op();
    80005560:	925fe0ef          	jal	80003e84 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    80005564:	08000613          	li	a2,128
    80005568:	f6040593          	addi	a1,s0,-160
    8000556c:	4501                	li	a0,0
    8000556e:	caefd0ef          	jal	80002a1c <argstr>
    80005572:	04054363          	bltz	a0,800055b8 <sys_chdir+0x68>
    80005576:	e526                	sd	s1,136(sp)
    80005578:	f6040513          	addi	a0,s0,-160
    8000557c:	f2afe0ef          	jal	80003ca6 <namei>
    80005580:	84aa                	mv	s1,a0
    80005582:	c915                	beqz	a0,800055b6 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005584:	e89fd0ef          	jal	8000340c <ilock>
  if (ip->type != T_DIR) {
    80005588:	04449703          	lh	a4,68(s1)
    8000558c:	4785                	li	a5,1
    8000558e:	02f71963          	bne	a4,a5,800055c0 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005592:	8526                	mv	a0,s1
    80005594:	f27fd0ef          	jal	800034ba <iunlock>
  iput(p->cwd);
    80005598:	15093503          	ld	a0,336(s2)
    8000559c:	ff3fd0ef          	jal	8000358e <iput>
  end_op();
    800055a0:	971fe0ef          	jal	80003f10 <end_op>
  p->cwd = ip;
    800055a4:	14993823          	sd	s1,336(s2)
  return 0;
    800055a8:	4501                	li	a0,0
    800055aa:	64aa                	ld	s1,136(sp)
}
    800055ac:	60ea                	ld	ra,152(sp)
    800055ae:	644a                	ld	s0,144(sp)
    800055b0:	690a                	ld	s2,128(sp)
    800055b2:	610d                	addi	sp,sp,160
    800055b4:	8082                	ret
    800055b6:	64aa                	ld	s1,136(sp)
    end_op();
    800055b8:	959fe0ef          	jal	80003f10 <end_op>
    return -1;
    800055bc:	557d                	li	a0,-1
    800055be:	b7fd                	j	800055ac <sys_chdir+0x5c>
    iunlockput(ip);
    800055c0:	8526                	mv	a0,s1
    800055c2:	89efe0ef          	jal	80003660 <iunlockput>
    end_op();
    800055c6:	94bfe0ef          	jal	80003f10 <end_op>
    return -1;
    800055ca:	557d                	li	a0,-1
    800055cc:	64aa                	ld	s1,136(sp)
    800055ce:	bff9                	j	800055ac <sys_chdir+0x5c>

00000000800055d0 <sys_exec>:

uint64
sys_exec(void)
{
    800055d0:	7105                	addi	sp,sp,-480
    800055d2:	ef86                	sd	ra,472(sp)
    800055d4:	eba2                	sd	s0,464(sp)
    800055d6:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800055d8:	e2840593          	addi	a1,s0,-472
    800055dc:	4505                	li	a0,1
    800055de:	c22fd0ef          	jal	80002a00 <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    800055e2:	08000613          	li	a2,128
    800055e6:	f3040593          	addi	a1,s0,-208
    800055ea:	4501                	li	a0,0
    800055ec:	c30fd0ef          	jal	80002a1c <argstr>
    800055f0:	87aa                	mv	a5,a0
    return -1;
    800055f2:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    800055f4:	0e07c063          	bltz	a5,800056d4 <sys_exec+0x104>
    800055f8:	e7a6                	sd	s1,456(sp)
    800055fa:	e3ca                	sd	s2,448(sp)
    800055fc:	ff4e                	sd	s3,440(sp)
    800055fe:	fb52                	sd	s4,432(sp)
    80005600:	f756                	sd	s5,424(sp)
    80005602:	f35a                	sd	s6,416(sp)
    80005604:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005606:	e3040a13          	addi	s4,s0,-464
    8000560a:	10000613          	li	a2,256
    8000560e:	4581                	li	a1,0
    80005610:	8552                	mv	a0,s4
    80005612:	f52fb0ef          	jal	80000d64 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    80005616:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005618:	89d2                	mv	s3,s4
    8000561a:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    8000561c:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005620:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    80005622:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005626:	00391513          	slli	a0,s2,0x3
    8000562a:	85d6                	mv	a1,s5
    8000562c:	e2843783          	ld	a5,-472(s0)
    80005630:	953e                	add	a0,a0,a5
    80005632:	b26fd0ef          	jal	80002958 <fetchaddr>
    80005636:	02054663          	bltz	a0,80005662 <sys_exec+0x92>
    if (uarg == 0) {
    8000563a:	e2043783          	ld	a5,-480(s0)
    8000563e:	c7a1                	beqz	a5,80005686 <sys_exec+0xb6>
    argv[i] = kalloc();
    80005640:	d38fb0ef          	jal	80000b78 <kalloc>
    80005644:	85aa                	mv	a1,a0
    80005646:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    8000564a:	cd01                	beqz	a0,80005662 <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000564c:	865a                	mv	a2,s6
    8000564e:	e2043503          	ld	a0,-480(s0)
    80005652:	b50fd0ef          	jal	800029a2 <fetchstr>
    80005656:	00054663          	bltz	a0,80005662 <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    8000565a:	0905                	addi	s2,s2,1
    8000565c:	09a1                	addi	s3,s3,8
    8000565e:	fd7914e3          	bne	s2,s7,80005626 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005662:	100a0a13          	addi	s4,s4,256
    80005666:	6088                	ld	a0,0(s1)
    80005668:	cd31                	beqz	a0,800056c4 <sys_exec+0xf4>
    kfree(argv[i]);
    8000566a:	bfcfb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000566e:	04a1                	addi	s1,s1,8
    80005670:	ff449be3          	bne	s1,s4,80005666 <sys_exec+0x96>
  return -1;
    80005674:	557d                	li	a0,-1
    80005676:	64be                	ld	s1,456(sp)
    80005678:	691e                	ld	s2,448(sp)
    8000567a:	79fa                	ld	s3,440(sp)
    8000567c:	7a5a                	ld	s4,432(sp)
    8000567e:	7aba                	ld	s5,424(sp)
    80005680:	7b1a                	ld	s6,416(sp)
    80005682:	6bfa                	ld	s7,408(sp)
    80005684:	a881                	j	800056d4 <sys_exec+0x104>
      argv[i] = 0;
    80005686:	0009079b          	sext.w	a5,s2
    8000568a:	e3040593          	addi	a1,s0,-464
    8000568e:	078e                	slli	a5,a5,0x3
    80005690:	97ae                	add	a5,a5,a1
    80005692:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    80005696:	f3040513          	addi	a0,s0,-208
    8000569a:	b62ff0ef          	jal	800049fc <kexec>
    8000569e:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800056a0:	100a0a13          	addi	s4,s4,256
    800056a4:	6088                	ld	a0,0(s1)
    800056a6:	c511                	beqz	a0,800056b2 <sys_exec+0xe2>
    kfree(argv[i]);
    800056a8:	bbefb0ef          	jal	80000a66 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800056ac:	04a1                	addi	s1,s1,8
    800056ae:	ff449be3          	bne	s1,s4,800056a4 <sys_exec+0xd4>
  return ret;
    800056b2:	854a                	mv	a0,s2
    800056b4:	64be                	ld	s1,456(sp)
    800056b6:	691e                	ld	s2,448(sp)
    800056b8:	79fa                	ld	s3,440(sp)
    800056ba:	7a5a                	ld	s4,432(sp)
    800056bc:	7aba                	ld	s5,424(sp)
    800056be:	7b1a                	ld	s6,416(sp)
    800056c0:	6bfa                	ld	s7,408(sp)
    800056c2:	a809                	j	800056d4 <sys_exec+0x104>
  return -1;
    800056c4:	557d                	li	a0,-1
    800056c6:	64be                	ld	s1,456(sp)
    800056c8:	691e                	ld	s2,448(sp)
    800056ca:	79fa                	ld	s3,440(sp)
    800056cc:	7a5a                	ld	s4,432(sp)
    800056ce:	7aba                	ld	s5,424(sp)
    800056d0:	7b1a                	ld	s6,416(sp)
    800056d2:	6bfa                	ld	s7,408(sp)
}
    800056d4:	60fe                	ld	ra,472(sp)
    800056d6:	645e                	ld	s0,464(sp)
    800056d8:	613d                	addi	sp,sp,480
    800056da:	8082                	ret

00000000800056dc <sys_pipe>:

uint64
sys_pipe(void)
{
    800056dc:	7139                	addi	sp,sp,-64
    800056de:	fc06                	sd	ra,56(sp)
    800056e0:	f822                	sd	s0,48(sp)
    800056e2:	f426                	sd	s1,40(sp)
    800056e4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800056e6:	b78fc0ef          	jal	80001a5e <myproc>
    800056ea:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800056ec:	fd840593          	addi	a1,s0,-40
    800056f0:	4501                	li	a0,0
    800056f2:	b0efd0ef          	jal	80002a00 <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    800056f6:	fc840593          	addi	a1,s0,-56
    800056fa:	fd040513          	addi	a0,s0,-48
    800056fe:	f7ffe0ef          	jal	8000467c <pipealloc>
    return -1;
    80005702:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    80005704:	0a054963          	bltz	a0,800057b6 <sys_pipe+0xda>
  fd0 = -1;
    80005708:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    8000570c:	fd043503          	ld	a0,-48(s0)
    80005710:	ea0ff0ef          	jal	80004db0 <fdalloc>
    80005714:	fca42223          	sw	a0,-60(s0)
    80005718:	08054663          	bltz	a0,800057a4 <sys_pipe+0xc8>
    8000571c:	fc843503          	ld	a0,-56(s0)
    80005720:	e90ff0ef          	jal	80004db0 <fdalloc>
    80005724:	fca42023          	sw	a0,-64(s0)
    80005728:	06054463          	bltz	a0,80005790 <sys_pipe+0xb4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    8000572c:	4711                	li	a4,4
    8000572e:	fc440693          	addi	a3,s0,-60
    80005732:	fd843603          	ld	a2,-40(s0)
    80005736:	64ac                	ld	a1,72(s1)
    80005738:	68a8                	ld	a0,80(s1)
    8000573a:	f1dfb0ef          	jal	80001656 <copyout>
    8000573e:	00054f63          	bltz	a0,8000575c <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    80005742:	4711                	li	a4,4
    80005744:	fc040693          	addi	a3,s0,-64
    80005748:	fd843603          	ld	a2,-40(s0)
    8000574c:	963a                	add	a2,a2,a4
    8000574e:	64ac                	ld	a1,72(s1)
    80005750:	68a8                	ld	a0,80(s1)
    80005752:	f05fb0ef          	jal	80001656 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005756:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005758:	04055f63          	bgez	a0,800057b6 <sys_pipe+0xda>
    p->ofile[fd0] = 0;
    8000575c:	fc442783          	lw	a5,-60(s0)
    80005760:	078e                	slli	a5,a5,0x3
    80005762:	0d078793          	addi	a5,a5,208
    80005766:	97a6                	add	a5,a5,s1
    80005768:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000576c:	fc042783          	lw	a5,-64(s0)
    80005770:	078e                	slli	a5,a5,0x3
    80005772:	0d078793          	addi	a5,a5,208
    80005776:	94be                	add	s1,s1,a5
    80005778:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000577c:	fd043503          	ld	a0,-48(s0)
    80005780:	bbffe0ef          	jal	8000433e <fileclose>
    fileclose(wf);
    80005784:	fc843503          	ld	a0,-56(s0)
    80005788:	bb7fe0ef          	jal	8000433e <fileclose>
    return -1;
    8000578c:	57fd                	li	a5,-1
    8000578e:	a025                	j	800057b6 <sys_pipe+0xda>
    if (fd0 >= 0)
    80005790:	fc442783          	lw	a5,-60(s0)
    80005794:	0007c863          	bltz	a5,800057a4 <sys_pipe+0xc8>
      p->ofile[fd0] = 0;
    80005798:	078e                	slli	a5,a5,0x3
    8000579a:	0d078793          	addi	a5,a5,208
    8000579e:	97a6                	add	a5,a5,s1
    800057a0:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800057a4:	fd043503          	ld	a0,-48(s0)
    800057a8:	b97fe0ef          	jal	8000433e <fileclose>
    fileclose(wf);
    800057ac:	fc843503          	ld	a0,-56(s0)
    800057b0:	b8ffe0ef          	jal	8000433e <fileclose>
    return -1;
    800057b4:	57fd                	li	a5,-1
}
    800057b6:	853e                	mv	a0,a5
    800057b8:	70e2                	ld	ra,56(sp)
    800057ba:	7442                	ld	s0,48(sp)
    800057bc:	74a2                	ld	s1,40(sp)
    800057be:	6121                	addi	sp,sp,64
    800057c0:	8082                	ret
	...

00000000800057d0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800057d0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800057d2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800057d4:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    800057d6:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800057d8:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800057da:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800057dc:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800057de:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800057e0:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800057e2:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800057e4:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800057e6:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800057e8:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800057ea:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800057ec:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800057ee:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800057f0:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800057f2:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800057f4:	872fd0ef          	jal	80002866 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800057f8:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800057fa:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800057fc:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800057fe:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005800:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005802:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005804:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005806:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005808:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000580a:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000580c:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    8000580e:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005810:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005812:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005814:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005816:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005818:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000581a:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000581c:	10200073          	sret
    80005820:	0001                	nop
    80005822:	00000013          	nop
    80005826:	00000013          	nop
    8000582a:	00000013          	nop

000000008000582e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000582e:	1141                	addi	sp,sp,-16
    80005830:	e406                	sd	ra,8(sp)
    80005832:	e022                	sd	s0,0(sp)
    80005834:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(volatile uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80005836:	0c000737          	lui	a4,0xc000
    8000583a:	4785                	li	a5,1
    8000583c:	d71c                	sw	a5,40(a4)
  *(volatile uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    8000583e:	c35c                	sw	a5,4(a4)
}
    80005840:	60a2                	ld	ra,8(sp)
    80005842:	6402                	ld	s0,0(sp)
    80005844:	0141                	addi	sp,sp,16
    80005846:	8082                	ret

0000000080005848 <plicinithart>:

void
plicinithart(void)
{
    80005848:	1141                	addi	sp,sp,-16
    8000584a:	e406                	sd	ra,8(sp)
    8000584c:	e022                	sd	s0,0(sp)
    8000584e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005850:	9dafc0ef          	jal	80001a2a <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(volatile uint32 *)PLIC_SENABLE(hart) =
    80005854:	0085179b          	slliw	a5,a0,0x8
    80005858:	0c002737          	lui	a4,0xc002
    8000585c:	08070713          	addi	a4,a4,128 # c002080 <_entry-0x73ffdf80>
    80005860:	97ba                	add	a5,a5,a4
    80005862:	40200713          	li	a4,1026
    80005866:	c398                	sw	a4,0(a5)
    (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);

  // set this hart's S-mode priority threshold to 0.
  *(volatile uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005868:	00d5151b          	slliw	a0,a0,0xd
    8000586c:	0c2017b7          	lui	a5,0xc201
    80005870:	953e                	add	a0,a0,a5
    80005872:	00052023          	sw	zero,0(a0)
}
    80005876:	60a2                	ld	ra,8(sp)
    80005878:	6402                	ld	s0,0(sp)
    8000587a:	0141                	addi	sp,sp,16
    8000587c:	8082                	ret

000000008000587e <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000587e:	1141                	addi	sp,sp,-16
    80005880:	e406                	sd	ra,8(sp)
    80005882:	e022                	sd	s0,0(sp)
    80005884:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005886:	9a4fc0ef          	jal	80001a2a <cpuid>
  int irq = *(volatile uint32 *)PLIC_SCLAIM(hart);
    8000588a:	00d5151b          	slliw	a0,a0,0xd
    8000588e:	0c2017b7          	lui	a5,0xc201
    80005892:	0791                	addi	a5,a5,4 # c201004 <_entry-0x73dfeffc>
    80005894:	953e                	add	a0,a0,a5
    80005896:	4108                	lw	a0,0(a0)
  return irq;
}
    80005898:	60a2                	ld	ra,8(sp)
    8000589a:	6402                	ld	s0,0(sp)
    8000589c:	0141                	addi	sp,sp,16
    8000589e:	8082                	ret

00000000800058a0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800058a0:	1101                	addi	sp,sp,-32
    800058a2:	ec06                	sd	ra,24(sp)
    800058a4:	e822                	sd	s0,16(sp)
    800058a6:	e426                	sd	s1,8(sp)
    800058a8:	1000                	addi	s0,sp,32
    800058aa:	84aa                	mv	s1,a0
  int hart = cpuid();
    800058ac:	97efc0ef          	jal	80001a2a <cpuid>
  *(volatile uint32 *)PLIC_SCLAIM(hart) = irq;
    800058b0:	00d5179b          	slliw	a5,a0,0xd
    800058b4:	0c201737          	lui	a4,0xc201
    800058b8:	0711                	addi	a4,a4,4 # c201004 <_entry-0x73dfeffc>
    800058ba:	97ba                	add	a5,a5,a4
    800058bc:	c384                	sw	s1,0(a5)
}
    800058be:	60e2                	ld	ra,24(sp)
    800058c0:	6442                	ld	s0,16(sp)
    800058c2:	64a2                	ld	s1,8(sp)
    800058c4:	6105                	addi	sp,sp,32
    800058c6:	8082                	ret

00000000800058c8 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800058c8:	1141                	addi	sp,sp,-16
    800058ca:	e406                	sd	ra,8(sp)
    800058cc:	e022                	sd	s0,0(sp)
    800058ce:	0800                	addi	s0,sp,16
  if (i >= NUM)
    800058d0:	479d                	li	a5,7
    800058d2:	04a7ca63          	blt	a5,a0,80005926 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    800058d6:	0001e797          	auipc	a5,0x1e
    800058da:	ce278793          	addi	a5,a5,-798 # 800235b8 <disk>
    800058de:	97aa                	add	a5,a5,a0
    800058e0:	0187c783          	lbu	a5,24(a5)
    800058e4:	e7b9                	bnez	a5,80005932 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800058e6:	00451693          	slli	a3,a0,0x4
    800058ea:	0001e797          	auipc	a5,0x1e
    800058ee:	cce78793          	addi	a5,a5,-818 # 800235b8 <disk>
    800058f2:	6398                	ld	a4,0(a5)
    800058f4:	9736                	add	a4,a4,a3
    800058f6:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800058fa:	6398                	ld	a4,0(a5)
    800058fc:	9736                	add	a4,a4,a3
    800058fe:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005902:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005906:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000590a:	97aa                	add	a5,a5,a0
    8000590c:	4705                	li	a4,1
    8000590e:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005912:	0001e517          	auipc	a0,0x1e
    80005916:	cbe50513          	addi	a0,a0,-834 # 800235d0 <disk+0x18>
    8000591a:	fbafc0ef          	jal	800020d4 <wakeup>
}
    8000591e:	60a2                	ld	ra,8(sp)
    80005920:	6402                	ld	s0,0(sp)
    80005922:	0141                	addi	sp,sp,16
    80005924:	8082                	ret
    panic("free_desc 1");
    80005926:	00002517          	auipc	a0,0x2
    8000592a:	d5250513          	addi	a0,a0,-686 # 80007678 <etext+0x678>
    8000592e:	f07fa0ef          	jal	80000834 <panic>
    panic("free_desc 2");
    80005932:	00002517          	auipc	a0,0x2
    80005936:	d5650513          	addi	a0,a0,-682 # 80007688 <etext+0x688>
    8000593a:	efbfa0ef          	jal	80000834 <panic>

000000008000593e <virtio_disk_init>:
{
    8000593e:	1101                	addi	sp,sp,-32
    80005940:	ec06                	sd	ra,24(sp)
    80005942:	e822                	sd	s0,16(sp)
    80005944:	e426                	sd	s1,8(sp)
    80005946:	e04a                	sd	s2,0(sp)
    80005948:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000594a:	00002597          	auipc	a1,0x2
    8000594e:	d4e58593          	addi	a1,a1,-690 # 80007698 <etext+0x698>
    80005952:	0001e517          	auipc	a0,0x1e
    80005956:	d8e50513          	addi	a0,a0,-626 # 800236e0 <disk+0x128>
    8000595a:	acafb0ef          	jal	80000c24 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000595e:	100017b7          	lui	a5,0x10001
    80005962:	4398                	lw	a4,0(a5)
    80005964:	2701                	sext.w	a4,a4
    80005966:	747277b7          	lui	a5,0x74727
    8000596a:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000596e:	14f71863          	bne	a4,a5,80005abe <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005972:	100017b7          	lui	a5,0x10001
    80005976:	43dc                	lw	a5,4(a5)
    80005978:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000597a:	4709                	li	a4,2
    8000597c:	14e79163          	bne	a5,a4,80005abe <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005980:	100017b7          	lui	a5,0x10001
    80005984:	479c                	lw	a5,8(a5)
    80005986:	2781                	sext.w	a5,a5
    80005988:	12e79b63          	bne	a5,a4,80005abe <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    8000598c:	100017b7          	lui	a5,0x10001
    80005990:	47d8                	lw	a4,12(a5)
    80005992:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005994:	554d47b7          	lui	a5,0x554d4
    80005998:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000599c:	12f71163          	bne	a4,a5,80005abe <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    800059a0:	100017b7          	lui	a5,0x10001
    800059a4:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800059a8:	4705                	li	a4,1
    800059aa:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800059ac:	470d                	li	a4,3
    800059ae:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800059b0:	10001737          	lui	a4,0x10001
    800059b4:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800059b6:	c7ffe6b7          	lui	a3,0xc7ffe
    800059ba:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fdae67>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800059be:	8f75                	and	a4,a4,a3
    800059c0:	100016b7          	lui	a3,0x10001
    800059c4:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800059c6:	472d                	li	a4,11
    800059c8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800059ca:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800059ce:	439c                	lw	a5,0(a5)
    800059d0:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800059d4:	8ba1                	andi	a5,a5,8
    800059d6:	0e078a63          	beqz	a5,80005aca <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800059da:	100017b7          	lui	a5,0x10001
    800059de:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    800059e2:	43fc                	lw	a5,68(a5)
    800059e4:	2781                	sext.w	a5,a5
    800059e6:	0e079863          	bnez	a5,80005ad6 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800059ea:	100017b7          	lui	a5,0x10001
    800059ee:	5bdc                	lw	a5,52(a5)
    800059f0:	2781                	sext.w	a5,a5
  if (max == 0)
    800059f2:	0e078863          	beqz	a5,80005ae2 <virtio_disk_init+0x1a4>
  if (max < NUM)
    800059f6:	471d                	li	a4,7
    800059f8:	0ef77b63          	bgeu	a4,a5,80005aee <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    800059fc:	97cfb0ef          	jal	80000b78 <kalloc>
    80005a00:	0001e497          	auipc	s1,0x1e
    80005a04:	bb848493          	addi	s1,s1,-1096 # 800235b8 <disk>
    80005a08:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005a0a:	96efb0ef          	jal	80000b78 <kalloc>
    80005a0e:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005a10:	968fb0ef          	jal	80000b78 <kalloc>
    80005a14:	87aa                	mv	a5,a0
    80005a16:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005a18:	6088                	ld	a0,0(s1)
    80005a1a:	0e050063          	beqz	a0,80005afa <virtio_disk_init+0x1bc>
    80005a1e:	0001e717          	auipc	a4,0x1e
    80005a22:	ba273703          	ld	a4,-1118(a4) # 800235c0 <disk+0x8>
    80005a26:	cb71                	beqz	a4,80005afa <virtio_disk_init+0x1bc>
    80005a28:	cbe9                	beqz	a5,80005afa <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005a2a:	6605                	lui	a2,0x1
    80005a2c:	4581                	li	a1,0
    80005a2e:	b36fb0ef          	jal	80000d64 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005a32:	0001e497          	auipc	s1,0x1e
    80005a36:	b8648493          	addi	s1,s1,-1146 # 800235b8 <disk>
    80005a3a:	6605                	lui	a2,0x1
    80005a3c:	4581                	li	a1,0
    80005a3e:	6488                	ld	a0,8(s1)
    80005a40:	b24fb0ef          	jal	80000d64 <memset>
  memset(disk.used, 0, PGSIZE);
    80005a44:	6605                	lui	a2,0x1
    80005a46:	4581                	li	a1,0
    80005a48:	6888                	ld	a0,16(s1)
    80005a4a:	b1afb0ef          	jal	80000d64 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005a4e:	100017b7          	lui	a5,0x10001
    80005a52:	4721                	li	a4,8
    80005a54:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005a56:	4098                	lw	a4,0(s1)
    80005a58:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005a5c:	40d8                	lw	a4,4(s1)
    80005a5e:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005a62:	649c                	ld	a5,8(s1)
    80005a64:	0007869b          	sext.w	a3,a5
    80005a68:	10001737          	lui	a4,0x10001
    80005a6c:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005a70:	9781                	srai	a5,a5,0x20
    80005a72:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005a76:	689c                	ld	a5,16(s1)
    80005a78:	0007869b          	sext.w	a3,a5
    80005a7c:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005a80:	9781                	srai	a5,a5,0x20
    80005a82:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005a86:	4785                	li	a5,1
    80005a88:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005a8a:	00f48c23          	sb	a5,24(s1)
    80005a8e:	00f48ca3          	sb	a5,25(s1)
    80005a92:	00f48d23          	sb	a5,26(s1)
    80005a96:	00f48da3          	sb	a5,27(s1)
    80005a9a:	00f48e23          	sb	a5,28(s1)
    80005a9e:	00f48ea3          	sb	a5,29(s1)
    80005aa2:	00f48f23          	sb	a5,30(s1)
    80005aa6:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005aaa:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005aae:	07272823          	sw	s2,112(a4)
}
    80005ab2:	60e2                	ld	ra,24(sp)
    80005ab4:	6442                	ld	s0,16(sp)
    80005ab6:	64a2                	ld	s1,8(sp)
    80005ab8:	6902                	ld	s2,0(sp)
    80005aba:	6105                	addi	sp,sp,32
    80005abc:	8082                	ret
    panic("could not find virtio disk");
    80005abe:	00002517          	auipc	a0,0x2
    80005ac2:	bea50513          	addi	a0,a0,-1046 # 800076a8 <etext+0x6a8>
    80005ac6:	d6ffa0ef          	jal	80000834 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005aca:	00002517          	auipc	a0,0x2
    80005ace:	bfe50513          	addi	a0,a0,-1026 # 800076c8 <etext+0x6c8>
    80005ad2:	d63fa0ef          	jal	80000834 <panic>
    panic("virtio disk should not be ready");
    80005ad6:	00002517          	auipc	a0,0x2
    80005ada:	c1250513          	addi	a0,a0,-1006 # 800076e8 <etext+0x6e8>
    80005ade:	d57fa0ef          	jal	80000834 <panic>
    panic("virtio disk has no queue 0");
    80005ae2:	00002517          	auipc	a0,0x2
    80005ae6:	c2650513          	addi	a0,a0,-986 # 80007708 <etext+0x708>
    80005aea:	d4bfa0ef          	jal	80000834 <panic>
    panic("virtio disk max queue too short");
    80005aee:	00002517          	auipc	a0,0x2
    80005af2:	c3a50513          	addi	a0,a0,-966 # 80007728 <etext+0x728>
    80005af6:	d3ffa0ef          	jal	80000834 <panic>
    panic("virtio disk kalloc");
    80005afa:	00002517          	auipc	a0,0x2
    80005afe:	c4e50513          	addi	a0,a0,-946 # 80007748 <etext+0x748>
    80005b02:	d33fa0ef          	jal	80000834 <panic>

0000000080005b06 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005b06:	711d                	addi	sp,sp,-96
    80005b08:	ec86                	sd	ra,88(sp)
    80005b0a:	e8a2                	sd	s0,80(sp)
    80005b0c:	e4a6                	sd	s1,72(sp)
    80005b0e:	e0ca                	sd	s2,64(sp)
    80005b10:	fc4e                	sd	s3,56(sp)
    80005b12:	f852                	sd	s4,48(sp)
    80005b14:	f456                	sd	s5,40(sp)
    80005b16:	f05a                	sd	s6,32(sp)
    80005b18:	ec5e                	sd	s7,24(sp)
    80005b1a:	e862                	sd	s8,16(sp)
    80005b1c:	1080                	addi	s0,sp,96
    80005b1e:	89aa                	mv	s3,a0
    80005b20:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005b22:	00c52b83          	lw	s7,12(a0)
    80005b26:	001b9b9b          	slliw	s7,s7,0x1
    80005b2a:	1b82                	slli	s7,s7,0x20
    80005b2c:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005b30:	0001e517          	auipc	a0,0x1e
    80005b34:	bb050513          	addi	a0,a0,-1104 # 800236e0 <disk+0x128>
    80005b38:	96cfb0ef          	jal	80000ca4 <acquire>
  for (int i = 0; i < NUM; i++) {
    80005b3c:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005b3e:	0001ea97          	auipc	s5,0x1e
    80005b42:	a7aa8a93          	addi	s5,s5,-1414 # 800235b8 <disk>
  for (int i = 0; i < 3; i++) {
    80005b46:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005b48:	5c7d                	li	s8,-1
    80005b4a:	a8a5                	j	80005bc2 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80005b4c:	00fa8733          	add	a4,s5,a5
    80005b50:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005b54:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005b56:	0207c563          	bltz	a5,80005b80 <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    80005b5a:	2905                	addiw	s2,s2,1
    80005b5c:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005b5e:	07490663          	beq	s2,s4,80005bca <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80005b62:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005b64:	0001e717          	auipc	a4,0x1e
    80005b68:	a5470713          	addi	a4,a4,-1452 # 800235b8 <disk>
    80005b6c:	4781                	li	a5,0
    if (disk.free[i]) {
    80005b6e:	01874683          	lbu	a3,24(a4)
    80005b72:	fee9                	bnez	a3,80005b4c <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    80005b74:	2785                	addiw	a5,a5,1
    80005b76:	0705                	addi	a4,a4,1
    80005b78:	fe979be3          	bne	a5,s1,80005b6e <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005b7c:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    80005b80:	01205d63          	blez	s2,80005b9a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005b84:	fa042503          	lw	a0,-96(s0)
    80005b88:	d41ff0ef          	jal	800058c8 <free_desc>
      for (int j = 0; j < i; j++)
    80005b8c:	4785                	li	a5,1
    80005b8e:	0127d663          	bge	a5,s2,80005b9a <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005b92:	fa442503          	lw	a0,-92(s0)
    80005b96:	d33ff0ef          	jal	800058c8 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005b9a:	0001e517          	auipc	a0,0x1e
    80005b9e:	a3650513          	addi	a0,a0,-1482 # 800235d0 <disk+0x18>
    80005ba2:	cc6fc0ef          	jal	80002068 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005ba6:	0001e517          	auipc	a0,0x1e
    80005baa:	b3a50513          	addi	a0,a0,-1222 # 800236e0 <disk+0x128>
    80005bae:	97efb0ef          	jal	80000d2c <release>
    sleep();
    80005bb2:	cf2fc0ef          	jal	800020a4 <sleep>
    acquire(&disk.vdisk_lock);
    80005bb6:	0001e517          	auipc	a0,0x1e
    80005bba:	b2a50513          	addi	a0,a0,-1238 # 800236e0 <disk+0x128>
    80005bbe:	8e6fb0ef          	jal	80000ca4 <acquire>
  for (int i = 0; i < 3; i++) {
    80005bc2:	fa040613          	addi	a2,s0,-96
    80005bc6:	4901                	li	s2,0
    80005bc8:	bf69                	j	80005b62 <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005bca:	fa042503          	lw	a0,-96(s0)
    80005bce:	00451693          	slli	a3,a0,0x4

  if (write)
    80005bd2:	0001e797          	auipc	a5,0x1e
    80005bd6:	9e678793          	addi	a5,a5,-1562 # 800235b8 <disk>
    80005bda:	00451713          	slli	a4,a0,0x4
    80005bde:	0a070713          	addi	a4,a4,160
    80005be2:	973e                	add	a4,a4,a5
    80005be4:	01603633          	snez	a2,s6
    80005be8:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005bea:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005bee:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005bf2:	6398                	ld	a4,0(a5)
    80005bf4:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005bf6:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005bfa:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005bfc:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005bfe:	6390                	ld	a2,0(a5)
    80005c00:	00d60833          	add	a6,a2,a3
    80005c04:	4741                	li	a4,16
    80005c06:	00e82423          	sw	a4,8(a6) # 1008 <_entry-0x7fffeff8>
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005c0a:	4585                	li	a1,1
    80005c0c:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005c10:	fa442703          	lw	a4,-92(s0)
    80005c14:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005c18:	0712                	slli	a4,a4,0x4
    80005c1a:	963a                	add	a2,a2,a4
    80005c1c:	05898813          	addi	a6,s3,88
    80005c20:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005c24:	0007b883          	ld	a7,0(a5)
    80005c28:	9746                	add	a4,a4,a7
    80005c2a:	40000613          	li	a2,1024
    80005c2e:	c710                	sw	a2,8(a4)
  if (write)
    80005c30:	001b3613          	seqz	a2,s6
    80005c34:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005c38:	8e4d                	or	a2,a2,a1
    80005c3a:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005c3e:	fa842603          	lw	a2,-88(s0)
    80005c42:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005c46:	00451813          	slli	a6,a0,0x4
    80005c4a:	02080813          	addi	a6,a6,32
    80005c4e:	983e                	add	a6,a6,a5
    80005c50:	577d                	li	a4,-1
    80005c52:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005c56:	0612                	slli	a2,a2,0x4
    80005c58:	98b2                	add	a7,a7,a2
    80005c5a:	03068713          	addi	a4,a3,48
    80005c5e:	973e                	add	a4,a4,a5
    80005c60:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005c64:	6398                	ld	a4,0(a5)
    80005c66:	9732                	add	a4,a4,a2
    80005c68:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005c6a:	4689                	li	a3,2
    80005c6c:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005c70:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005c74:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005c78:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005c7c:	6794                	ld	a3,8(a5)
    80005c7e:	0026d703          	lhu	a4,2(a3)
    80005c82:	8b1d                	andi	a4,a4,7
    80005c84:	0706                	slli	a4,a4,0x1
    80005c86:	96ba                	add	a3,a3,a4
    80005c88:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005c8c:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005c90:	6798                	ld	a4,8(a5)
    80005c92:	00275783          	lhu	a5,2(a4)
    80005c96:	2785                	addiw	a5,a5,1
    80005c98:	00f71123          	sh	a5,2(a4)
    80005c9c:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005ca0:	100017b7          	lui	a5,0x10001
    80005ca4:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005ca8:	0049a783          	lw	a5,4(s3)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005cac:	0001e497          	auipc	s1,0x1e
    80005cb0:	a3448493          	addi	s1,s1,-1484 # 800236e0 <disk+0x128>
  while (b->disk == 1) {
    80005cb4:	892e                	mv	s2,a1
    80005cb6:	02b79163          	bne	a5,a1,80005cd8 <virtio_disk_rw+0x1d2>
    sleep_prepare(b);
    80005cba:	854e                	mv	a0,s3
    80005cbc:	bacfc0ef          	jal	80002068 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005cc0:	8526                	mv	a0,s1
    80005cc2:	86afb0ef          	jal	80000d2c <release>
    sleep();
    80005cc6:	bdefc0ef          	jal	800020a4 <sleep>
    acquire(&disk.vdisk_lock);
    80005cca:	8526                	mv	a0,s1
    80005ccc:	fd9fa0ef          	jal	80000ca4 <acquire>
  while (b->disk == 1) {
    80005cd0:	0049a783          	lw	a5,4(s3)
    80005cd4:	ff2783e3          	beq	a5,s2,80005cba <virtio_disk_rw+0x1b4>
  }

  disk.info[idx[0]].b = 0;
    80005cd8:	fa042903          	lw	s2,-96(s0)
    80005cdc:	00491713          	slli	a4,s2,0x4
    80005ce0:	02070713          	addi	a4,a4,32
    80005ce4:	0001e797          	auipc	a5,0x1e
    80005ce8:	8d478793          	addi	a5,a5,-1836 # 800235b8 <disk>
    80005cec:	97ba                	add	a5,a5,a4
    80005cee:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005cf2:	0001e997          	auipc	s3,0x1e
    80005cf6:	8c698993          	addi	s3,s3,-1850 # 800235b8 <disk>
    80005cfa:	00491713          	slli	a4,s2,0x4
    80005cfe:	0009b783          	ld	a5,0(s3)
    80005d02:	97ba                	add	a5,a5,a4
    80005d04:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005d08:	854a                	mv	a0,s2
    80005d0a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005d0e:	bbbff0ef          	jal	800058c8 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005d12:	8885                	andi	s1,s1,1
    80005d14:	f0fd                	bnez	s1,80005cfa <virtio_disk_rw+0x1f4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005d16:	0001e517          	auipc	a0,0x1e
    80005d1a:	9ca50513          	addi	a0,a0,-1590 # 800236e0 <disk+0x128>
    80005d1e:	80efb0ef          	jal	80000d2c <release>
}
    80005d22:	60e6                	ld	ra,88(sp)
    80005d24:	6446                	ld	s0,80(sp)
    80005d26:	64a6                	ld	s1,72(sp)
    80005d28:	6906                	ld	s2,64(sp)
    80005d2a:	79e2                	ld	s3,56(sp)
    80005d2c:	7a42                	ld	s4,48(sp)
    80005d2e:	7aa2                	ld	s5,40(sp)
    80005d30:	7b02                	ld	s6,32(sp)
    80005d32:	6be2                	ld	s7,24(sp)
    80005d34:	6c42                	ld	s8,16(sp)
    80005d36:	6125                	addi	sp,sp,96
    80005d38:	8082                	ret

0000000080005d3a <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005d3a:	1101                	addi	sp,sp,-32
    80005d3c:	ec06                	sd	ra,24(sp)
    80005d3e:	e822                	sd	s0,16(sp)
    80005d40:	e426                	sd	s1,8(sp)
    80005d42:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005d44:	0001e497          	auipc	s1,0x1e
    80005d48:	87448493          	addi	s1,s1,-1932 # 800235b8 <disk>
    80005d4c:	0001e517          	auipc	a0,0x1e
    80005d50:	99450513          	addi	a0,a0,-1644 # 800236e0 <disk+0x128>
    80005d54:	f51fa0ef          	jal	80000ca4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005d58:	100017b7          	lui	a5,0x10001
    80005d5c:	53bc                	lw	a5,96(a5)
    80005d5e:	8b8d                	andi	a5,a5,3
    80005d60:	10001737          	lui	a4,0x10001
    80005d64:	d37c                	sw	a5,100(a4)
    80005d66:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005d6a:	689c                	ld	a5,16(s1)
    80005d6c:	0204d703          	lhu	a4,32(s1)
    80005d70:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005d74:	04f70863          	beq	a4,a5,80005dc4 <virtio_disk_intr+0x8a>
    80005d78:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005d7c:	6898                	ld	a4,16(s1)
    80005d7e:	0204d783          	lhu	a5,32(s1)
    80005d82:	8b9d                	andi	a5,a5,7
    80005d84:	078e                	slli	a5,a5,0x3
    80005d86:	97ba                	add	a5,a5,a4
    80005d88:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005d8a:	00479713          	slli	a4,a5,0x4
    80005d8e:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005d92:	9726                	add	a4,a4,s1
    80005d94:	01074703          	lbu	a4,16(a4)
    80005d98:	e329                	bnez	a4,80005dda <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005d9a:	0792                	slli	a5,a5,0x4
    80005d9c:	02078793          	addi	a5,a5,32
    80005da0:	97a6                	add	a5,a5,s1
    80005da2:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005da4:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005da8:	b2cfc0ef          	jal	800020d4 <wakeup>

    disk.used_idx += 1;
    80005dac:	0204d783          	lhu	a5,32(s1)
    80005db0:	2785                	addiw	a5,a5,1
    80005db2:	17c2                	slli	a5,a5,0x30
    80005db4:	93c1                	srli	a5,a5,0x30
    80005db6:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005dba:	6898                	ld	a4,16(s1)
    80005dbc:	00275703          	lhu	a4,2(a4)
    80005dc0:	faf71ce3          	bne	a4,a5,80005d78 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005dc4:	0001e517          	auipc	a0,0x1e
    80005dc8:	91c50513          	addi	a0,a0,-1764 # 800236e0 <disk+0x128>
    80005dcc:	f61fa0ef          	jal	80000d2c <release>
}
    80005dd0:	60e2                	ld	ra,24(sp)
    80005dd2:	6442                	ld	s0,16(sp)
    80005dd4:	64a2                	ld	s1,8(sp)
    80005dd6:	6105                	addi	sp,sp,32
    80005dd8:	8082                	ret
      panic("virtio_disk_intr status");
    80005dda:	00002517          	auipc	a0,0x2
    80005dde:	98650513          	addi	a0,a0,-1658 # 80007760 <etext+0x760>
    80005de2:	a53fa0ef          	jal	80000834 <panic>
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
