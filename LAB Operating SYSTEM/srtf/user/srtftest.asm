
user/_srtftest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <delay>:
#include "kernel/stat.h"
#include "user/user.h"

#define NUM_CHILDREN 3

void delay(int count) {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  for (volatile int i = 0; i < count; i++) {
   8:	fe042623          	sw	zero,-20(s0)
   c:	fec42783          	lw	a5,-20(s0)
  10:	872a                	mv	a4,a0
  12:	00a7dc63          	bge	a5,a0,2a <delay+0x2a>
  16:	fec42783          	lw	a5,-20(s0)
  1a:	2785                	addiw	a5,a5,1
  1c:	fef42623          	sw	a5,-20(s0)
  20:	fec42783          	lw	a5,-20(s0)
  24:	2781                	sext.w	a5,a5
  26:	fee7c8e3          	blt	a5,a4,16 <delay+0x16>
    // busy delay
  }
}
  2a:	60e2                	ld	ra,24(sp)
  2c:	6442                	ld	s0,16(sp)
  2e:	6105                	addi	sp,sp,32
  30:	8082                	ret

0000000000000032 <main>:

int main(int argc, char *argv[]) {
  32:	7135                	addi	sp,sp,-160
  34:	ed06                	sd	ra,152(sp)
  36:	e922                	sd	s0,144(sp)
  38:	e526                	sd	s1,136(sp)
  3a:	e14a                	sd	s2,128(sp)
  3c:	fcce                	sd	s3,120(sp)
  3e:	f8d2                	sd	s4,112(sp)
  40:	f4d6                	sd	s5,104(sp)
  42:	f0da                	sd	s6,96(sp)
  44:	ecde                	sd	s7,88(sp)
  46:	e8e2                	sd	s8,80(sp)
  48:	1100                	addi	s0,sp,160
  int pids[NUM_CHILDREN];
  // 3 processes: Long (30 ticks), Medium (15 ticks), Short (5 ticks)
  int burst_times[NUM_CHILDREN] = {30, 15, 5};
  4a:	47f9                	li	a5,30
  4c:	f8f42823          	sw	a5,-112(s0)
  50:	47bd                	li	a5,15
  52:	f8f42a23          	sw	a5,-108(s0)
  56:	4795                	li	a5,5
  58:	f8f42c23          	sw	a5,-104(s0)
  uint64 workloads[NUM_CHILDREN] = {60000000ULL, 30000000ULL, 10000000ULL};
  5c:	039387b7          	lui	a5,0x3938
  60:	70078793          	addi	a5,a5,1792 # 3938700 <base+0x39366f0>
  64:	f6f43c23          	sd	a5,-136(s0)
  68:	01c9c7b7          	lui	a5,0x1c9c
  6c:	38078793          	addi	a5,a5,896 # 1c9c380 <base+0x1c9a370>
  70:	f8f43023          	sd	a5,-128(s0)
  74:	009897b7          	lui	a5,0x989
  78:	68078793          	addi	a5,a5,1664 # 989680 <base+0x987670>
  7c:	f8f43423          	sd	a5,-120(s0)

  printf("--- Shortest Remaining Time First (SRTF) Preemptive Test ---\n");
  80:	00001517          	auipc	a0,0x1
  84:	a9050513          	addi	a0,a0,-1392 # b10 <malloc+0x100>
  88:	0d1000ef          	jal	958 <printf>
  printf("Parent PID: %d\n", getpid());
  8c:	4f6000ef          	jal	582 <getpid>
  90:	85aa                	mv	a1,a0
  92:	00001517          	auipc	a0,0x1
  96:	ac650513          	addi	a0,a0,-1338 # b58 <malloc+0x148>
  9a:	0bf000ef          	jal	958 <printf>
  printf("Forking 3 processes with staggered arrival: P1(Long=30), P2(Med=15), P3(Short=5)...\n\n");
  9e:	00001517          	auipc	a0,0x1
  a2:	aca50513          	addi	a0,a0,-1334 # b68 <malloc+0x158>
  a6:	0b3000ef          	jal	958 <printf>

  for (int i = 0; i < NUM_CHILDREN; i++) {
  aa:	f9040a93          	addi	s5,s0,-112
  ae:	fa040a13          	addi	s4,s0,-96
  b2:	4901                	li	s2,0
      exit(0);
    } else {
      // Parent records burst time immediately
      set_burst(pid, burst_times[i]);
      pids[i] = pid;
      printf("[Parent] Forked Child %d (PID %d) with declared burst time = %d\n",
  b4:	00001c17          	auipc	s8,0x1
  b8:	be4c0c13          	addi	s8,s8,-1052 # c98 <malloc+0x288>
  for (int i = 0; i < NUM_CHILDREN; i++) {
  bc:	4b8d                	li	s7,3
      delay(8000000);
  be:	007a1b37          	lui	s6,0x7a1
  c2:	200b0b13          	addi	s6,s6,512 # 7a1200 <base+0x79f1f0>
  c6:	a801                	j	d6 <main+0xa4>
  for (int i = 0; i < NUM_CHILDREN; i++) {
  c8:	0a91                	addi	s5,s5,4
  ca:	0a11                	addi	s4,s4,4
    if (i > 0) {
  cc:	01205563          	blez	s2,d6 <main+0xa4>
      delay(8000000);
  d0:	855a                	mv	a0,s6
  d2:	f2fff0ef          	jal	0 <delay>
    int pid = fork();
  d6:	424000ef          	jal	4fa <fork>
  da:	84aa                	mv	s1,a0
    if (pid < 0) {
  dc:	08054363          	bltz	a0,162 <main+0x130>
    if (pid == 0) {
  e0:	c951                	beqz	a0,174 <main+0x142>
      set_burst(pid, burst_times[i]);
  e2:	000aa983          	lw	s3,0(s5)
  e6:	85ce                	mv	a1,s3
  e8:	4c2000ef          	jal	5aa <set_burst>
      pids[i] = pid;
  ec:	009a2023          	sw	s1,0(s4)
      printf("[Parent] Forked Child %d (PID %d) with declared burst time = %d\n",
  f0:	0019059b          	addiw	a1,s2,1
  f4:	892e                	mv	s2,a1
  f6:	86ce                	mv	a3,s3
  f8:	8626                	mv	a2,s1
  fa:	8562                	mv	a0,s8
  fc:	05d000ef          	jal	958 <printf>
  for (int i = 0; i < NUM_CHILDREN; i++) {
 100:	fd7914e3          	bne	s2,s7,c8 <main+0x96>
             i + 1, pid, burst_times[i]);
    }
  }

  printf("\n[Parent] All children forked. Waiting for completion...\n\n");
 104:	00001517          	auipc	a0,0x1
 108:	bdc50513          	addi	a0,a0,-1060 # ce0 <malloc+0x2d0>
 10c:	04d000ef          	jal	958 <printf>

  for (int order = 1; order <= NUM_CHILDREN; order++) {
 110:	4485                	li	s1,1
    int finished_pid = wait(0);
    int child_idx = -1;
    int bt = -1;
 112:	597d                	li	s2,-1
        child_idx = i + 1;
        bt = burst_times[i];
        break;
      }
    }
    printf(">> Completion Order %d: PID %d (Child %d, Burst Time %d ticks)\n",
 114:	00001a17          	auipc	s4,0x1
 118:	c0ca0a13          	addi	s4,s4,-1012 # d20 <malloc+0x310>
  for (int order = 1; order <= NUM_CHILDREN; order++) {
 11c:	4991                	li	s3,4
    int finished_pid = wait(0);
 11e:	4501                	li	a0,0
 120:	3ea000ef          	jal	50a <wait>
 124:	862a                	mv	a2,a0
      if (pids[i] == finished_pid) {
 126:	fa042783          	lw	a5,-96(s0)
 12a:	10a78563          	beq	a5,a0,234 <main+0x202>
 12e:	fa442783          	lw	a5,-92(s0)
 132:	10a78b63          	beq	a5,a0,248 <main+0x216>
 136:	fa842783          	lw	a5,-88(s0)
    int bt = -1;
 13a:	874a                	mv	a4,s2
    int child_idx = -1;
 13c:	86ca                	mv	a3,s2
      if (pids[i] == finished_pid) {
 13e:	0ea78963          	beq	a5,a0,230 <main+0x1fe>
    printf(">> Completion Order %d: PID %d (Child %d, Burst Time %d ticks)\n",
 142:	85a6                	mv	a1,s1
 144:	8552                	mv	a0,s4
 146:	013000ef          	jal	958 <printf>
  for (int order = 1; order <= NUM_CHILDREN; order++) {
 14a:	2485                	addiw	s1,s1,1
 14c:	fd3499e3          	bne	s1,s3,11e <main+0xec>
           order, finished_pid, child_idx, bt);
  }

  printf("\n--- SRTF Test Passed: Short jobs preempted longer jobs and finished first! ---\n");
 150:	00001517          	auipc	a0,0x1
 154:	c1050513          	addi	a0,a0,-1008 # d60 <malloc+0x350>
 158:	001000ef          	jal	958 <printf>
  exit(0);
 15c:	4501                	li	a0,0
 15e:	3a4000ef          	jal	502 <exit>
      printf("Fork failed!\n");
 162:	00001517          	auipc	a0,0x1
 166:	a5e50513          	addi	a0,a0,-1442 # bc0 <malloc+0x1b0>
 16a:	7ee000ef          	jal	958 <printf>
      exit(1);
 16e:	4505                	li	a0,1
 170:	392000ef          	jal	502 <exit>
      int my_pid = getpid();
 174:	40e000ef          	jal	582 <getpid>
 178:	84aa                	mv	s1,a0
      set_burst(my_pid, burst_times[i]);
 17a:	00291793          	slli	a5,s2,0x2
 17e:	fb078793          	addi	a5,a5,-80
 182:	97a2                	add	a5,a5,s0
 184:	fe07a983          	lw	s3,-32(a5)
 188:	85ce                	mv	a1,s3
 18a:	420000ef          	jal	5aa <set_burst>
      printf("[Child %d | PID %d] Running with Burst Time = %d ticks (uptime: %d)\n",
 18e:	00190a1b          	addiw	s4,s2,1
 192:	408000ef          	jal	59a <uptime>
 196:	872a                	mv	a4,a0
 198:	86ce                	mv	a3,s3
 19a:	8626                	mv	a2,s1
 19c:	85d2                	mv	a1,s4
 19e:	00001517          	auipc	a0,0x1
 1a2:	a3250513          	addi	a0,a0,-1486 # bd0 <malloc+0x1c0>
 1a6:	7b2000ef          	jal	958 <printf>
      volatile uint64 counter = 0;
 1aa:	f6043423          	sd	zero,-152(s0)
      for (volatile uint64 j = 0; j < workloads[i]; j++) {
 1ae:	f6043823          	sd	zero,-144(s0)
 1b2:	00391793          	slli	a5,s2,0x3
 1b6:	fb078793          	addi	a5,a5,-80
 1ba:	97a2                	add	a5,a5,s0
 1bc:	fc87b903          	ld	s2,-56(a5)
 1c0:	f7043783          	ld	a5,-144(s0)
 1c4:	0527f763          	bgeu	a5,s2,212 <main+0x1e0>
        if (j == workloads[i] / 2) {
 1c8:	00195a93          	srli	s5,s2,0x1
          printf("[Child %d | PID %d | BT %d] Reached 50%% progress (uptime: %d)\n",
 1cc:	00001b17          	auipc	s6,0x1
 1d0:	a4cb0b13          	addi	s6,s6,-1460 # c18 <malloc+0x208>
 1d4:	a811                	j	1e8 <main+0x1b6>
      for (volatile uint64 j = 0; j < workloads[i]; j++) {
 1d6:	f7043783          	ld	a5,-144(s0)
 1da:	0785                	addi	a5,a5,1
 1dc:	f6f43823          	sd	a5,-144(s0)
 1e0:	f7043783          	ld	a5,-144(s0)
 1e4:	0327f763          	bgeu	a5,s2,212 <main+0x1e0>
        counter += j;
 1e8:	f7043703          	ld	a4,-144(s0)
 1ec:	f6843783          	ld	a5,-152(s0)
 1f0:	97ba                	add	a5,a5,a4
 1f2:	f6f43423          	sd	a5,-152(s0)
        if (j == workloads[i] / 2) {
 1f6:	f7043783          	ld	a5,-144(s0)
 1fa:	fcfa9ee3          	bne	s5,a5,1d6 <main+0x1a4>
          printf("[Child %d | PID %d | BT %d] Reached 50%% progress (uptime: %d)\n",
 1fe:	39c000ef          	jal	59a <uptime>
 202:	872a                	mv	a4,a0
 204:	86ce                	mv	a3,s3
 206:	8626                	mv	a2,s1
 208:	85d2                	mv	a1,s4
 20a:	855a                	mv	a0,s6
 20c:	74c000ef          	jal	958 <printf>
 210:	b7d9                	j	1d6 <main+0x1a4>
      printf("[Child %d | PID %d | BT %d] Completed workload at tick %d\n",
 212:	388000ef          	jal	59a <uptime>
 216:	872a                	mv	a4,a0
 218:	86ce                	mv	a3,s3
 21a:	8626                	mv	a2,s1
 21c:	85d2                	mv	a1,s4
 21e:	00001517          	auipc	a0,0x1
 222:	a3a50513          	addi	a0,a0,-1478 # c58 <malloc+0x248>
 226:	732000ef          	jal	958 <printf>
      exit(0);
 22a:	4501                	li	a0,0
 22c:	2d6000ef          	jal	502 <exit>
 230:	4789                	li	a5,2
 232:	a011                	j	236 <main+0x204>
    for (int i = 0; i < NUM_CHILDREN; i++) {
 234:	4781                	li	a5,0
        child_idx = i + 1;
 236:	00178693          	addi	a3,a5,1
        bt = burst_times[i];
 23a:	078a                	slli	a5,a5,0x2
 23c:	fb078793          	addi	a5,a5,-80
 240:	97a2                	add	a5,a5,s0
 242:	fe07a703          	lw	a4,-32(a5)
        break;
 246:	bdf5                	j	142 <main+0x110>
    for (int i = 0; i < NUM_CHILDREN; i++) {
 248:	4785                	li	a5,1
 24a:	b7f5                	j	236 <main+0x204>

000000000000024c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 24c:	1141                	addi	sp,sp,-16
 24e:	e406                	sd	ra,8(sp)
 250:	e022                	sd	s0,0(sp)
 252:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 254:	ddfff0ef          	jal	32 <main>
  exit(r);
 258:	2aa000ef          	jal	502 <exit>

000000000000025c <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 25c:	1141                	addi	sp,sp,-16
 25e:	e406                	sd	ra,8(sp)
 260:	e022                	sd	s0,0(sp)
 262:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 264:	87aa                	mv	a5,a0
 266:	0585                	addi	a1,a1,1
 268:	0785                	addi	a5,a5,1
 26a:	fff5c703          	lbu	a4,-1(a1)
 26e:	fee78fa3          	sb	a4,-1(a5)
 272:	fb75                	bnez	a4,266 <strcpy+0xa>
    ;
  return os;
}
 274:	60a2                	ld	ra,8(sp)
 276:	6402                	ld	s0,0(sp)
 278:	0141                	addi	sp,sp,16
 27a:	8082                	ret

000000000000027c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e406                	sd	ra,8(sp)
 280:	e022                	sd	s0,0(sp)
 282:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 284:	00054783          	lbu	a5,0(a0)
 288:	cb91                	beqz	a5,29c <strcmp+0x20>
 28a:	0005c703          	lbu	a4,0(a1)
 28e:	00f71763          	bne	a4,a5,29c <strcmp+0x20>
    p++, q++;
 292:	0505                	addi	a0,a0,1
 294:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 296:	00054783          	lbu	a5,0(a0)
 29a:	fbe5                	bnez	a5,28a <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 29c:	0005c503          	lbu	a0,0(a1)
}
 2a0:	40a7853b          	subw	a0,a5,a0
 2a4:	60a2                	ld	ra,8(sp)
 2a6:	6402                	ld	s0,0(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret

00000000000002ac <strlen>:

uint
strlen(const char *s)
{
 2ac:	1141                	addi	sp,sp,-16
 2ae:	e406                	sd	ra,8(sp)
 2b0:	e022                	sd	s0,0(sp)
 2b2:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 2b4:	00054783          	lbu	a5,0(a0)
 2b8:	cf91                	beqz	a5,2d4 <strlen+0x28>
 2ba:	00150793          	addi	a5,a0,1
 2be:	86be                	mv	a3,a5
 2c0:	0785                	addi	a5,a5,1
 2c2:	fff7c703          	lbu	a4,-1(a5)
 2c6:	ff65                	bnez	a4,2be <strlen+0x12>
 2c8:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 2cc:	60a2                	ld	ra,8(sp)
 2ce:	6402                	ld	s0,0(sp)
 2d0:	0141                	addi	sp,sp,16
 2d2:	8082                	ret
  for (n = 0; s[n]; n++)
 2d4:	4501                	li	a0,0
 2d6:	bfdd                	j	2cc <strlen+0x20>

00000000000002d8 <memset>:

void *
memset(void *dst, int c, uint n)
{
 2d8:	1141                	addi	sp,sp,-16
 2da:	e406                	sd	ra,8(sp)
 2dc:	e022                	sd	s0,0(sp)
 2de:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 2e0:	ca19                	beqz	a2,2f6 <memset+0x1e>
 2e2:	87aa                	mv	a5,a0
 2e4:	1602                	slli	a2,a2,0x20
 2e6:	9201                	srli	a2,a2,0x20
 2e8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2ec:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 2f0:	0785                	addi	a5,a5,1
 2f2:	fee79de3          	bne	a5,a4,2ec <memset+0x14>
  }
  return dst;
}
 2f6:	60a2                	ld	ra,8(sp)
 2f8:	6402                	ld	s0,0(sp)
 2fa:	0141                	addi	sp,sp,16
 2fc:	8082                	ret

00000000000002fe <strchr>:

char *
strchr(const char *s, char c)
{
 2fe:	1141                	addi	sp,sp,-16
 300:	e406                	sd	ra,8(sp)
 302:	e022                	sd	s0,0(sp)
 304:	0800                	addi	s0,sp,16
  for (; *s; s++)
 306:	00054783          	lbu	a5,0(a0)
 30a:	cf81                	beqz	a5,322 <strchr+0x24>
    if (*s == c)
 30c:	00f58763          	beq	a1,a5,31a <strchr+0x1c>
  for (; *s; s++)
 310:	0505                	addi	a0,a0,1
 312:	00054783          	lbu	a5,0(a0)
 316:	fbfd                	bnez	a5,30c <strchr+0xe>
      return (char *)s;
  return 0;
 318:	4501                	li	a0,0
}
 31a:	60a2                	ld	ra,8(sp)
 31c:	6402                	ld	s0,0(sp)
 31e:	0141                	addi	sp,sp,16
 320:	8082                	ret
  return 0;
 322:	4501                	li	a0,0
 324:	bfdd                	j	31a <strchr+0x1c>

0000000000000326 <gets>:

char *
gets(char *buf, int max)
{
 326:	711d                	addi	sp,sp,-96
 328:	ec86                	sd	ra,88(sp)
 32a:	e8a2                	sd	s0,80(sp)
 32c:	e4a6                	sd	s1,72(sp)
 32e:	e0ca                	sd	s2,64(sp)
 330:	fc4e                	sd	s3,56(sp)
 332:	f852                	sd	s4,48(sp)
 334:	f456                	sd	s5,40(sp)
 336:	f05a                	sd	s6,32(sp)
 338:	ec5e                	sd	s7,24(sp)
 33a:	e862                	sd	s8,16(sp)
 33c:	1080                	addi	s0,sp,96
 33e:	8baa                	mv	s7,a0
 340:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 342:	892a                	mv	s2,a0
 344:	4481                	li	s1,0
    cc = read(0, &c, 1);
 346:	faf40b13          	addi	s6,s0,-81
 34a:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 34c:	8c26                	mv	s8,s1
 34e:	0014899b          	addiw	s3,s1,1
 352:	84ce                	mv	s1,s3
 354:	0349d463          	bge	s3,s4,37c <gets+0x56>
    cc = read(0, &c, 1);
 358:	8656                	mv	a2,s5
 35a:	85da                	mv	a1,s6
 35c:	4501                	li	a0,0
 35e:	1bc000ef          	jal	51a <read>
    if (cc < 1)
 362:	00a05d63          	blez	a0,37c <gets+0x56>
      break;
    buf[i++] = c;
 366:	faf44783          	lbu	a5,-81(s0)
 36a:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 36e:	0905                	addi	s2,s2,1
 370:	ff678713          	addi	a4,a5,-10
 374:	c319                	beqz	a4,37a <gets+0x54>
 376:	17cd                	addi	a5,a5,-13
 378:	fbf1                	bnez	a5,34c <gets+0x26>
    buf[i++] = c;
 37a:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 37c:	9c5e                	add	s8,s8,s7
 37e:	000c0023          	sb	zero,0(s8)
  return buf;
}
 382:	855e                	mv	a0,s7
 384:	60e6                	ld	ra,88(sp)
 386:	6446                	ld	s0,80(sp)
 388:	64a6                	ld	s1,72(sp)
 38a:	6906                	ld	s2,64(sp)
 38c:	79e2                	ld	s3,56(sp)
 38e:	7a42                	ld	s4,48(sp)
 390:	7aa2                	ld	s5,40(sp)
 392:	7b02                	ld	s6,32(sp)
 394:	6be2                	ld	s7,24(sp)
 396:	6c42                	ld	s8,16(sp)
 398:	6125                	addi	sp,sp,96
 39a:	8082                	ret

000000000000039c <stat>:

int
stat(const char *n, struct stat *st)
{
 39c:	1101                	addi	sp,sp,-32
 39e:	ec06                	sd	ra,24(sp)
 3a0:	e822                	sd	s0,16(sp)
 3a2:	e04a                	sd	s2,0(sp)
 3a4:	1000                	addi	s0,sp,32
 3a6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3a8:	4581                	li	a1,0
 3aa:	198000ef          	jal	542 <open>
  if (fd < 0)
 3ae:	02054263          	bltz	a0,3d2 <stat+0x36>
 3b2:	e426                	sd	s1,8(sp)
 3b4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3b6:	85ca                	mv	a1,s2
 3b8:	1a2000ef          	jal	55a <fstat>
 3bc:	892a                	mv	s2,a0
  close(fd);
 3be:	8526                	mv	a0,s1
 3c0:	16a000ef          	jal	52a <close>
  return r;
 3c4:	64a2                	ld	s1,8(sp)
}
 3c6:	854a                	mv	a0,s2
 3c8:	60e2                	ld	ra,24(sp)
 3ca:	6442                	ld	s0,16(sp)
 3cc:	6902                	ld	s2,0(sp)
 3ce:	6105                	addi	sp,sp,32
 3d0:	8082                	ret
    return -1;
 3d2:	57fd                	li	a5,-1
 3d4:	893e                	mv	s2,a5
 3d6:	bfc5                	j	3c6 <stat+0x2a>

00000000000003d8 <atoi>:

int
atoi(const char *s)
{
 3d8:	1141                	addi	sp,sp,-16
 3da:	e406                	sd	ra,8(sp)
 3dc:	e022                	sd	s0,0(sp)
 3de:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 3e0:	00054683          	lbu	a3,0(a0)
 3e4:	fd06879b          	addiw	a5,a3,-48
 3e8:	0ff7f793          	zext.b	a5,a5
 3ec:	4625                	li	a2,9
 3ee:	02f66963          	bltu	a2,a5,420 <atoi+0x48>
 3f2:	872a                	mv	a4,a0
  n = 0;
 3f4:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 3f6:	0705                	addi	a4,a4,1
 3f8:	0025179b          	slliw	a5,a0,0x2
 3fc:	9fa9                	addw	a5,a5,a0
 3fe:	0017979b          	slliw	a5,a5,0x1
 402:	9fb5                	addw	a5,a5,a3
 404:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 408:	00074683          	lbu	a3,0(a4)
 40c:	fd06879b          	addiw	a5,a3,-48
 410:	0ff7f793          	zext.b	a5,a5
 414:	fef671e3          	bgeu	a2,a5,3f6 <atoi+0x1e>
  return n;
}
 418:	60a2                	ld	ra,8(sp)
 41a:	6402                	ld	s0,0(sp)
 41c:	0141                	addi	sp,sp,16
 41e:	8082                	ret
  n = 0;
 420:	4501                	li	a0,0
 422:	bfdd                	j	418 <atoi+0x40>

0000000000000424 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 424:	1141                	addi	sp,sp,-16
 426:	e406                	sd	ra,8(sp)
 428:	e022                	sd	s0,0(sp)
 42a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 42c:	02b57563          	bgeu	a0,a1,456 <memmove+0x32>
    while (n-- > 0)
 430:	00c05f63          	blez	a2,44e <memmove+0x2a>
 434:	1602                	slli	a2,a2,0x20
 436:	9201                	srli	a2,a2,0x20
 438:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 43c:	872a                	mv	a4,a0
      *dst++ = *src++;
 43e:	0585                	addi	a1,a1,1
 440:	0705                	addi	a4,a4,1
 442:	fff5c683          	lbu	a3,-1(a1)
 446:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 44a:	fee79ae3          	bne	a5,a4,43e <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 44e:	60a2                	ld	ra,8(sp)
 450:	6402                	ld	s0,0(sp)
 452:	0141                	addi	sp,sp,16
 454:	8082                	ret
    while (n-- > 0)
 456:	fec05ce3          	blez	a2,44e <memmove+0x2a>
    dst += n;
 45a:	00c50733          	add	a4,a0,a2
    src += n;
 45e:	95b2                	add	a1,a1,a2
 460:	fff6079b          	addiw	a5,a2,-1
 464:	1782                	slli	a5,a5,0x20
 466:	9381                	srli	a5,a5,0x20
 468:	fff7c793          	not	a5,a5
 46c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 46e:	15fd                	addi	a1,a1,-1
 470:	177d                	addi	a4,a4,-1
 472:	0005c683          	lbu	a3,0(a1)
 476:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 47a:	fef71ae3          	bne	a4,a5,46e <memmove+0x4a>
 47e:	bfc1                	j	44e <memmove+0x2a>

0000000000000480 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 480:	1141                	addi	sp,sp,-16
 482:	e406                	sd	ra,8(sp)
 484:	e022                	sd	s0,0(sp)
 486:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 488:	c61d                	beqz	a2,4b6 <memcmp+0x36>
 48a:	1602                	slli	a2,a2,0x20
 48c:	9201                	srli	a2,a2,0x20
 48e:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 492:	00054783          	lbu	a5,0(a0)
 496:	0005c703          	lbu	a4,0(a1)
 49a:	00e79863          	bne	a5,a4,4aa <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 49e:	0505                	addi	a0,a0,1
    p2++;
 4a0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4a2:	fed518e3          	bne	a0,a3,492 <memcmp+0x12>
  }
  return 0;
 4a6:	4501                	li	a0,0
 4a8:	a019                	j	4ae <memcmp+0x2e>
      return *p1 - *p2;
 4aa:	40e7853b          	subw	a0,a5,a4
}
 4ae:	60a2                	ld	ra,8(sp)
 4b0:	6402                	ld	s0,0(sp)
 4b2:	0141                	addi	sp,sp,16
 4b4:	8082                	ret
  return 0;
 4b6:	4501                	li	a0,0
 4b8:	bfdd                	j	4ae <memcmp+0x2e>

00000000000004ba <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4ba:	1141                	addi	sp,sp,-16
 4bc:	e406                	sd	ra,8(sp)
 4be:	e022                	sd	s0,0(sp)
 4c0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4c2:	f63ff0ef          	jal	424 <memmove>
}
 4c6:	60a2                	ld	ra,8(sp)
 4c8:	6402                	ld	s0,0(sp)
 4ca:	0141                	addi	sp,sp,16
 4cc:	8082                	ret

00000000000004ce <sbrk>:

char *
sbrk(int n)
{
 4ce:	1141                	addi	sp,sp,-16
 4d0:	e406                	sd	ra,8(sp)
 4d2:	e022                	sd	s0,0(sp)
 4d4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4d6:	4585                	li	a1,1
 4d8:	0b2000ef          	jal	58a <sys_sbrk>
}
 4dc:	60a2                	ld	ra,8(sp)
 4de:	6402                	ld	s0,0(sp)
 4e0:	0141                	addi	sp,sp,16
 4e2:	8082                	ret

00000000000004e4 <sbrklazy>:

char *
sbrklazy(int n)
{
 4e4:	1141                	addi	sp,sp,-16
 4e6:	e406                	sd	ra,8(sp)
 4e8:	e022                	sd	s0,0(sp)
 4ea:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4ec:	4589                	li	a1,2
 4ee:	09c000ef          	jal	58a <sys_sbrk>
}
 4f2:	60a2                	ld	ra,8(sp)
 4f4:	6402                	ld	s0,0(sp)
 4f6:	0141                	addi	sp,sp,16
 4f8:	8082                	ret

00000000000004fa <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4fa:	4885                	li	a7,1
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <exit>:
.global exit
exit:
 li a7, SYS_exit
 502:	4889                	li	a7,2
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <wait>:
.global wait
wait:
 li a7, SYS_wait
 50a:	488d                	li	a7,3
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 512:	4891                	li	a7,4
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <read>:
.global read
read:
 li a7, SYS_read
 51a:	4895                	li	a7,5
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <write>:
.global write
write:
 li a7, SYS_write
 522:	48c1                	li	a7,16
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <close>:
.global close
close:
 li a7, SYS_close
 52a:	48d5                	li	a7,21
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <kill>:
.global kill
kill:
 li a7, SYS_kill
 532:	4899                	li	a7,6
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <exec>:
.global exec
exec:
 li a7, SYS_exec
 53a:	489d                	li	a7,7
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <open>:
.global open
open:
 li a7, SYS_open
 542:	48bd                	li	a7,15
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 54a:	48c5                	li	a7,17
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 552:	48c9                	li	a7,18
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 55a:	48a1                	li	a7,8
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <link>:
.global link
link:
 li a7, SYS_link
 562:	48cd                	li	a7,19
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 56a:	48d1                	li	a7,20
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 572:	48a5                	li	a7,9
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <dup>:
.global dup
dup:
 li a7, SYS_dup
 57a:	48a9                	li	a7,10
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 582:	48ad                	li	a7,11
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 58a:	48b1                	li	a7,12
 ecall
 58c:	00000073          	ecall
 ret
 590:	8082                	ret

0000000000000592 <pause>:
.global pause
pause:
 li a7, SYS_pause
 592:	48b5                	li	a7,13
 ecall
 594:	00000073          	ecall
 ret
 598:	8082                	ret

000000000000059a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 59a:	48b9                	li	a7,14
 ecall
 59c:	00000073          	ecall
 ret
 5a0:	8082                	ret

00000000000005a2 <sync>:
.global sync
sync:
 li a7, SYS_sync
 5a2:	48d9                	li	a7,22
 ecall
 5a4:	00000073          	ecall
 ret
 5a8:	8082                	ret

00000000000005aa <set_burst>:
.global set_burst
set_burst:
 li a7, SYS_set_burst
 5aa:	48dd                	li	a7,23
 ecall
 5ac:	00000073          	ecall
 ret
 5b0:	8082                	ret

00000000000005b2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5b2:	1101                	addi	sp,sp,-32
 5b4:	ec06                	sd	ra,24(sp)
 5b6:	e822                	sd	s0,16(sp)
 5b8:	1000                	addi	s0,sp,32
 5ba:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5be:	4605                	li	a2,1
 5c0:	fef40593          	addi	a1,s0,-17
 5c4:	f5fff0ef          	jal	522 <write>
}
 5c8:	60e2                	ld	ra,24(sp)
 5ca:	6442                	ld	s0,16(sp)
 5cc:	6105                	addi	sp,sp,32
 5ce:	8082                	ret

00000000000005d0 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 5d0:	715d                	addi	sp,sp,-80
 5d2:	e486                	sd	ra,72(sp)
 5d4:	e0a2                	sd	s0,64(sp)
 5d6:	f84a                	sd	s2,48(sp)
 5d8:	f44e                	sd	s3,40(sp)
 5da:	0880                	addi	s0,sp,80
 5dc:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 5de:	c6d1                	beqz	a3,66a <printint+0x9a>
 5e0:	0805d563          	bgez	a1,66a <printint+0x9a>
    neg = 1;
    x = -xx;
 5e4:	40b005b3          	neg	a1,a1
    neg = 1;
 5e8:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 5ea:	fb840993          	addi	s3,s0,-72
  neg = 0;
 5ee:	86ce                	mv	a3,s3
  i = 0;
 5f0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 5f2:	00000817          	auipc	a6,0x0
 5f6:	7ce80813          	addi	a6,a6,1998 # dc0 <digits>
 5fa:	88ba                	mv	a7,a4
 5fc:	0017051b          	addiw	a0,a4,1
 600:	872a                	mv	a4,a0
 602:	02c5f7b3          	remu	a5,a1,a2
 606:	97c2                	add	a5,a5,a6
 608:	0007c783          	lbu	a5,0(a5)
 60c:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 610:	87ae                	mv	a5,a1
 612:	02c5d5b3          	divu	a1,a1,a2
 616:	0685                	addi	a3,a3,1
 618:	fec7f1e3          	bgeu	a5,a2,5fa <printint+0x2a>
  if (neg)
 61c:	00030c63          	beqz	t1,634 <printint+0x64>
    buf[i++] = '-';
 620:	fd050793          	addi	a5,a0,-48
 624:	00878533          	add	a0,a5,s0
 628:	02d00793          	li	a5,45
 62c:	fef50423          	sb	a5,-24(a0)
 630:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 634:	02e05563          	blez	a4,65e <printint+0x8e>
 638:	fc26                	sd	s1,56(sp)
 63a:	377d                	addiw	a4,a4,-1
 63c:	00e984b3          	add	s1,s3,a4
 640:	19fd                	addi	s3,s3,-1
 642:	99ba                	add	s3,s3,a4
 644:	1702                	slli	a4,a4,0x20
 646:	9301                	srli	a4,a4,0x20
 648:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 64c:	0004c583          	lbu	a1,0(s1)
 650:	854a                	mv	a0,s2
 652:	f61ff0ef          	jal	5b2 <putc>
  while (--i >= 0)
 656:	14fd                	addi	s1,s1,-1
 658:	ff349ae3          	bne	s1,s3,64c <printint+0x7c>
 65c:	74e2                	ld	s1,56(sp)
}
 65e:	60a6                	ld	ra,72(sp)
 660:	6406                	ld	s0,64(sp)
 662:	7942                	ld	s2,48(sp)
 664:	79a2                	ld	s3,40(sp)
 666:	6161                	addi	sp,sp,80
 668:	8082                	ret
  neg = 0;
 66a:	4301                	li	t1,0
 66c:	bfbd                	j	5ea <printint+0x1a>

000000000000066e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 66e:	711d                	addi	sp,sp,-96
 670:	ec86                	sd	ra,88(sp)
 672:	e8a2                	sd	s0,80(sp)
 674:	e4a6                	sd	s1,72(sp)
 676:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 678:	0005c483          	lbu	s1,0(a1)
 67c:	22048363          	beqz	s1,8a2 <vprintf+0x234>
 680:	e0ca                	sd	s2,64(sp)
 682:	fc4e                	sd	s3,56(sp)
 684:	f852                	sd	s4,48(sp)
 686:	f456                	sd	s5,40(sp)
 688:	f05a                	sd	s6,32(sp)
 68a:	ec5e                	sd	s7,24(sp)
 68c:	e862                	sd	s8,16(sp)
 68e:	8b2a                	mv	s6,a0
 690:	8a2e                	mv	s4,a1
 692:	8bb2                	mv	s7,a2
  state = 0;
 694:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 696:	4901                	li	s2,0
 698:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 69a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 69e:	06400c13          	li	s8,100
 6a2:	a00d                	j	6c4 <vprintf+0x56>
        putc(fd, c0);
 6a4:	85a6                	mv	a1,s1
 6a6:	855a                	mv	a0,s6
 6a8:	f0bff0ef          	jal	5b2 <putc>
 6ac:	a019                	j	6b2 <vprintf+0x44>
    } else if (state == '%') {
 6ae:	03598363          	beq	s3,s5,6d4 <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 6b2:	0019079b          	addiw	a5,s2,1
 6b6:	893e                	mv	s2,a5
 6b8:	873e                	mv	a4,a5
 6ba:	97d2                	add	a5,a5,s4
 6bc:	0007c483          	lbu	s1,0(a5)
 6c0:	1c048a63          	beqz	s1,894 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 6c4:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 6c8:	fe0993e3          	bnez	s3,6ae <vprintf+0x40>
      if (c0 == '%') {
 6cc:	fd579ce3          	bne	a5,s5,6a4 <vprintf+0x36>
        state = '%';
 6d0:	89be                	mv	s3,a5
 6d2:	b7c5                	j	6b2 <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 6d4:	00ea06b3          	add	a3,s4,a4
 6d8:	0016c603          	lbu	a2,1(a3)
      if (c1)
 6dc:	1c060863          	beqz	a2,8ac <vprintf+0x23e>
      if (c0 == 'd') {
 6e0:	03878763          	beq	a5,s8,70e <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 6e4:	f9478693          	addi	a3,a5,-108
 6e8:	0016b693          	seqz	a3,a3
 6ec:	f9c60593          	addi	a1,a2,-100
 6f0:	e99d                	bnez	a1,726 <vprintf+0xb8>
 6f2:	ca95                	beqz	a3,726 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6f4:	008b8493          	addi	s1,s7,8
 6f8:	4685                	li	a3,1
 6fa:	4629                	li	a2,10
 6fc:	000bb583          	ld	a1,0(s7)
 700:	855a                	mv	a0,s6
 702:	ecfff0ef          	jal	5d0 <printint>
        i += 1;
 706:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 708:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 70a:	4981                	li	s3,0
 70c:	b75d                	j	6b2 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 70e:	008b8493          	addi	s1,s7,8
 712:	4685                	li	a3,1
 714:	4629                	li	a2,10
 716:	000ba583          	lw	a1,0(s7)
 71a:	855a                	mv	a0,s6
 71c:	eb5ff0ef          	jal	5d0 <printint>
 720:	8ba6                	mv	s7,s1
      state = 0;
 722:	4981                	li	s3,0
 724:	b779                	j	6b2 <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 726:	9752                	add	a4,a4,s4
 728:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 72c:	f9460713          	addi	a4,a2,-108
 730:	00173713          	seqz	a4,a4
 734:	8f75                	and	a4,a4,a3
 736:	f9c58513          	addi	a0,a1,-100
 73a:	18051363          	bnez	a0,8c0 <vprintf+0x252>
 73e:	18070163          	beqz	a4,8c0 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 742:	008b8493          	addi	s1,s7,8
 746:	4685                	li	a3,1
 748:	4629                	li	a2,10
 74a:	000bb583          	ld	a1,0(s7)
 74e:	855a                	mv	a0,s6
 750:	e81ff0ef          	jal	5d0 <printint>
        i += 2;
 754:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 756:	8ba6                	mv	s7,s1
      state = 0;
 758:	4981                	li	s3,0
        i += 2;
 75a:	bfa1                	j	6b2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 75c:	008b8493          	addi	s1,s7,8
 760:	4681                	li	a3,0
 762:	4629                	li	a2,10
 764:	000be583          	lwu	a1,0(s7)
 768:	855a                	mv	a0,s6
 76a:	e67ff0ef          	jal	5d0 <printint>
 76e:	8ba6                	mv	s7,s1
      state = 0;
 770:	4981                	li	s3,0
 772:	b781                	j	6b2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 774:	008b8493          	addi	s1,s7,8
 778:	4681                	li	a3,0
 77a:	4629                	li	a2,10
 77c:	000bb583          	ld	a1,0(s7)
 780:	855a                	mv	a0,s6
 782:	e4fff0ef          	jal	5d0 <printint>
        i += 1;
 786:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 788:	8ba6                	mv	s7,s1
      state = 0;
 78a:	4981                	li	s3,0
 78c:	b71d                	j	6b2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 78e:	008b8493          	addi	s1,s7,8
 792:	4681                	li	a3,0
 794:	4629                	li	a2,10
 796:	000bb583          	ld	a1,0(s7)
 79a:	855a                	mv	a0,s6
 79c:	e35ff0ef          	jal	5d0 <printint>
        i += 2;
 7a0:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7a2:	8ba6                	mv	s7,s1
      state = 0;
 7a4:	4981                	li	s3,0
        i += 2;
 7a6:	b731                	j	6b2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 7a8:	008b8493          	addi	s1,s7,8
 7ac:	4681                	li	a3,0
 7ae:	4641                	li	a2,16
 7b0:	000be583          	lwu	a1,0(s7)
 7b4:	855a                	mv	a0,s6
 7b6:	e1bff0ef          	jal	5d0 <printint>
 7ba:	8ba6                	mv	s7,s1
      state = 0;
 7bc:	4981                	li	s3,0
 7be:	bdd5                	j	6b2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7c0:	008b8493          	addi	s1,s7,8
 7c4:	4681                	li	a3,0
 7c6:	4641                	li	a2,16
 7c8:	000bb583          	ld	a1,0(s7)
 7cc:	855a                	mv	a0,s6
 7ce:	e03ff0ef          	jal	5d0 <printint>
        i += 1;
 7d2:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7d4:	8ba6                	mv	s7,s1
      state = 0;
 7d6:	4981                	li	s3,0
 7d8:	bde9                	j	6b2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7da:	008b8493          	addi	s1,s7,8
 7de:	4681                	li	a3,0
 7e0:	4641                	li	a2,16
 7e2:	000bb583          	ld	a1,0(s7)
 7e6:	855a                	mv	a0,s6
 7e8:	de9ff0ef          	jal	5d0 <printint>
        i += 2;
 7ec:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7ee:	8ba6                	mv	s7,s1
      state = 0;
 7f0:	4981                	li	s3,0
        i += 2;
 7f2:	b5c1                	j	6b2 <vprintf+0x44>
 7f4:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 7f6:	008b8793          	addi	a5,s7,8
 7fa:	8cbe                	mv	s9,a5
 7fc:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 800:	03000593          	li	a1,48
 804:	855a                	mv	a0,s6
 806:	dadff0ef          	jal	5b2 <putc>
  putc(fd, 'x');
 80a:	07800593          	li	a1,120
 80e:	855a                	mv	a0,s6
 810:	da3ff0ef          	jal	5b2 <putc>
 814:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 816:	00000b97          	auipc	s7,0x0
 81a:	5aab8b93          	addi	s7,s7,1450 # dc0 <digits>
 81e:	03c9d793          	srli	a5,s3,0x3c
 822:	97de                	add	a5,a5,s7
 824:	0007c583          	lbu	a1,0(a5)
 828:	855a                	mv	a0,s6
 82a:	d89ff0ef          	jal	5b2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 82e:	0992                	slli	s3,s3,0x4
 830:	34fd                	addiw	s1,s1,-1
 832:	f4f5                	bnez	s1,81e <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 834:	8be6                	mv	s7,s9
      state = 0;
 836:	4981                	li	s3,0
 838:	6ca2                	ld	s9,8(sp)
 83a:	bda5                	j	6b2 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 83c:	008b8493          	addi	s1,s7,8
 840:	000bc583          	lbu	a1,0(s7)
 844:	855a                	mv	a0,s6
 846:	d6dff0ef          	jal	5b2 <putc>
 84a:	8ba6                	mv	s7,s1
      state = 0;
 84c:	4981                	li	s3,0
 84e:	b595                	j	6b2 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 850:	008b8993          	addi	s3,s7,8
 854:	000bb483          	ld	s1,0(s7)
 858:	cc91                	beqz	s1,874 <vprintf+0x206>
        for (; *s; s++)
 85a:	0004c583          	lbu	a1,0(s1)
 85e:	c985                	beqz	a1,88e <vprintf+0x220>
          putc(fd, *s);
 860:	855a                	mv	a0,s6
 862:	d51ff0ef          	jal	5b2 <putc>
        for (; *s; s++)
 866:	0485                	addi	s1,s1,1
 868:	0004c583          	lbu	a1,0(s1)
 86c:	f9f5                	bnez	a1,860 <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 86e:	8bce                	mv	s7,s3
      state = 0;
 870:	4981                	li	s3,0
 872:	b581                	j	6b2 <vprintf+0x44>
          s = "(null)";
 874:	00000497          	auipc	s1,0x0
 878:	54448493          	addi	s1,s1,1348 # db8 <malloc+0x3a8>
        for (; *s; s++)
 87c:	02800593          	li	a1,40
 880:	b7c5                	j	860 <vprintf+0x1f2>
        putc(fd, '%');
 882:	85be                	mv	a1,a5
 884:	855a                	mv	a0,s6
 886:	d2dff0ef          	jal	5b2 <putc>
      state = 0;
 88a:	4981                	li	s3,0
 88c:	b51d                	j	6b2 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 88e:	8bce                	mv	s7,s3
      state = 0;
 890:	4981                	li	s3,0
 892:	b505                	j	6b2 <vprintf+0x44>
 894:	6906                	ld	s2,64(sp)
 896:	79e2                	ld	s3,56(sp)
 898:	7a42                	ld	s4,48(sp)
 89a:	7aa2                	ld	s5,40(sp)
 89c:	7b02                	ld	s6,32(sp)
 89e:	6be2                	ld	s7,24(sp)
 8a0:	6c42                	ld	s8,16(sp)
    }
  }
}
 8a2:	60e6                	ld	ra,88(sp)
 8a4:	6446                	ld	s0,80(sp)
 8a6:	64a6                	ld	s1,72(sp)
 8a8:	6125                	addi	sp,sp,96
 8aa:	8082                	ret
      if (c0 == 'd') {
 8ac:	06400713          	li	a4,100
 8b0:	e4e78fe3          	beq	a5,a4,70e <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 8b4:	f9478693          	addi	a3,a5,-108
 8b8:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 8bc:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 8be:	4701                	li	a4,0
      } else if (c0 == 'u') {
 8c0:	07500513          	li	a0,117
 8c4:	e8a78ce3          	beq	a5,a0,75c <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 8c8:	f8b60513          	addi	a0,a2,-117
 8cc:	e119                	bnez	a0,8d2 <vprintf+0x264>
 8ce:	ea0693e3          	bnez	a3,774 <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 8d2:	f8b58513          	addi	a0,a1,-117
 8d6:	e119                	bnez	a0,8dc <vprintf+0x26e>
 8d8:	ea071be3          	bnez	a4,78e <vprintf+0x120>
      } else if (c0 == 'x') {
 8dc:	07800513          	li	a0,120
 8e0:	eca784e3          	beq	a5,a0,7a8 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 8e4:	f8860613          	addi	a2,a2,-120
 8e8:	e219                	bnez	a2,8ee <vprintf+0x280>
 8ea:	ec069be3          	bnez	a3,7c0 <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 8ee:	f8858593          	addi	a1,a1,-120
 8f2:	e199                	bnez	a1,8f8 <vprintf+0x28a>
 8f4:	ee0713e3          	bnez	a4,7da <vprintf+0x16c>
      } else if (c0 == 'p') {
 8f8:	07000713          	li	a4,112
 8fc:	eee78ce3          	beq	a5,a4,7f4 <vprintf+0x186>
      } else if (c0 == 'c') {
 900:	06300713          	li	a4,99
 904:	f2e78ce3          	beq	a5,a4,83c <vprintf+0x1ce>
      } else if (c0 == 's') {
 908:	07300713          	li	a4,115
 90c:	f4e782e3          	beq	a5,a4,850 <vprintf+0x1e2>
      } else if (c0 == '%') {
 910:	02500713          	li	a4,37
 914:	f6e787e3          	beq	a5,a4,882 <vprintf+0x214>
        putc(fd, '%');
 918:	02500593          	li	a1,37
 91c:	855a                	mv	a0,s6
 91e:	c95ff0ef          	jal	5b2 <putc>
        putc(fd, c0);
 922:	85a6                	mv	a1,s1
 924:	855a                	mv	a0,s6
 926:	c8dff0ef          	jal	5b2 <putc>
      state = 0;
 92a:	4981                	li	s3,0
 92c:	b359                	j	6b2 <vprintf+0x44>

000000000000092e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 92e:	715d                	addi	sp,sp,-80
 930:	ec06                	sd	ra,24(sp)
 932:	e822                	sd	s0,16(sp)
 934:	1000                	addi	s0,sp,32
 936:	e010                	sd	a2,0(s0)
 938:	e414                	sd	a3,8(s0)
 93a:	e818                	sd	a4,16(s0)
 93c:	ec1c                	sd	a5,24(s0)
 93e:	03043023          	sd	a6,32(s0)
 942:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 946:	8622                	mv	a2,s0
 948:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 94c:	d23ff0ef          	jal	66e <vprintf>
}
 950:	60e2                	ld	ra,24(sp)
 952:	6442                	ld	s0,16(sp)
 954:	6161                	addi	sp,sp,80
 956:	8082                	ret

0000000000000958 <printf>:

void
printf(const char *fmt, ...)
{
 958:	711d                	addi	sp,sp,-96
 95a:	ec06                	sd	ra,24(sp)
 95c:	e822                	sd	s0,16(sp)
 95e:	1000                	addi	s0,sp,32
 960:	e40c                	sd	a1,8(s0)
 962:	e810                	sd	a2,16(s0)
 964:	ec14                	sd	a3,24(s0)
 966:	f018                	sd	a4,32(s0)
 968:	f41c                	sd	a5,40(s0)
 96a:	03043823          	sd	a6,48(s0)
 96e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 972:	00840613          	addi	a2,s0,8
 976:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 97a:	85aa                	mv	a1,a0
 97c:	4505                	li	a0,1
 97e:	cf1ff0ef          	jal	66e <vprintf>
}
 982:	60e2                	ld	ra,24(sp)
 984:	6442                	ld	s0,16(sp)
 986:	6125                	addi	sp,sp,96
 988:	8082                	ret

000000000000098a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 98a:	1141                	addi	sp,sp,-16
 98c:	e406                	sd	ra,8(sp)
 98e:	e022                	sd	s0,0(sp)
 990:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 992:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 996:	00001797          	auipc	a5,0x1
 99a:	66a7b783          	ld	a5,1642(a5) # 2000 <freep>
 99e:	a039                	j	9ac <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9a0:	6398                	ld	a4,0(a5)
 9a2:	00e7e463          	bltu	a5,a4,9aa <free+0x20>
 9a6:	00e6ea63          	bltu	a3,a4,9ba <free+0x30>
{
 9aa:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9ac:	fed7fae3          	bgeu	a5,a3,9a0 <free+0x16>
 9b0:	6398                	ld	a4,0(a5)
 9b2:	00e6e463          	bltu	a3,a4,9ba <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9b6:	fee7eae3          	bltu	a5,a4,9aa <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 9ba:	ff852583          	lw	a1,-8(a0)
 9be:	6390                	ld	a2,0(a5)
 9c0:	02059813          	slli	a6,a1,0x20
 9c4:	01c85713          	srli	a4,a6,0x1c
 9c8:	9736                	add	a4,a4,a3
 9ca:	02e60563          	beq	a2,a4,9f4 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 9ce:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 9d2:	4790                	lw	a2,8(a5)
 9d4:	02061593          	slli	a1,a2,0x20
 9d8:	01c5d713          	srli	a4,a1,0x1c
 9dc:	973e                	add	a4,a4,a5
 9de:	02e68263          	beq	a3,a4,a02 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 9e2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9e4:	00001717          	auipc	a4,0x1
 9e8:	60f73e23          	sd	a5,1564(a4) # 2000 <freep>
}
 9ec:	60a2                	ld	ra,8(sp)
 9ee:	6402                	ld	s0,0(sp)
 9f0:	0141                	addi	sp,sp,16
 9f2:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 9f4:	4618                	lw	a4,8(a2)
 9f6:	9f2d                	addw	a4,a4,a1
 9f8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9fc:	6398                	ld	a4,0(a5)
 9fe:	6310                	ld	a2,0(a4)
 a00:	b7f9                	j	9ce <free+0x44>
    p->s.size += bp->s.size;
 a02:	ff852703          	lw	a4,-8(a0)
 a06:	9f31                	addw	a4,a4,a2
 a08:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a0a:	ff053683          	ld	a3,-16(a0)
 a0e:	bfd1                	j	9e2 <free+0x58>

0000000000000a10 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 a10:	7139                	addi	sp,sp,-64
 a12:	fc06                	sd	ra,56(sp)
 a14:	f822                	sd	s0,48(sp)
 a16:	f04a                	sd	s2,32(sp)
 a18:	ec4e                	sd	s3,24(sp)
 a1a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 a1c:	02051993          	slli	s3,a0,0x20
 a20:	0209d993          	srli	s3,s3,0x20
 a24:	09bd                	addi	s3,s3,15
 a26:	0049d993          	srli	s3,s3,0x4
 a2a:	2985                	addiw	s3,s3,1
 a2c:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 a2e:	00001517          	auipc	a0,0x1
 a32:	5d253503          	ld	a0,1490(a0) # 2000 <freep>
 a36:	c905                	beqz	a0,a66 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 a38:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 a3a:	4798                	lw	a4,8(a5)
 a3c:	09377663          	bgeu	a4,s3,ac8 <malloc+0xb8>
 a40:	f426                	sd	s1,40(sp)
 a42:	e852                	sd	s4,16(sp)
 a44:	e456                	sd	s5,8(sp)
 a46:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 a48:	8a4e                	mv	s4,s3
 a4a:	6705                	lui	a4,0x1
 a4c:	00e9f363          	bgeu	s3,a4,a52 <malloc+0x42>
 a50:	6a05                	lui	s4,0x1
 a52:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a56:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 a5a:	00001497          	auipc	s1,0x1
 a5e:	5a648493          	addi	s1,s1,1446 # 2000 <freep>
  if (p == SBRK_ERROR)
 a62:	5afd                	li	s5,-1
 a64:	a83d                	j	aa2 <malloc+0x92>
 a66:	f426                	sd	s1,40(sp)
 a68:	e852                	sd	s4,16(sp)
 a6a:	e456                	sd	s5,8(sp)
 a6c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a6e:	00001797          	auipc	a5,0x1
 a72:	5a278793          	addi	a5,a5,1442 # 2010 <base>
 a76:	00001717          	auipc	a4,0x1
 a7a:	58f73523          	sd	a5,1418(a4) # 2000 <freep>
 a7e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a80:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 a84:	b7d1                	j	a48 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 a86:	6398                	ld	a4,0(a5)
 a88:	e118                	sd	a4,0(a0)
 a8a:	a899                	j	ae0 <malloc+0xd0>
  hp->s.size = nu;
 a8c:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 a90:	0541                	addi	a0,a0,16
 a92:	ef9ff0ef          	jal	98a <free>
  return freep;
 a96:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 a98:	c125                	beqz	a0,af8 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 a9a:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 a9c:	4798                	lw	a4,8(a5)
 a9e:	03277163          	bgeu	a4,s2,ac0 <malloc+0xb0>
    if (p == freep)
 aa2:	6098                	ld	a4,0(s1)
 aa4:	853e                	mv	a0,a5
 aa6:	fef71ae3          	bne	a4,a5,a9a <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 aaa:	8552                	mv	a0,s4
 aac:	a23ff0ef          	jal	4ce <sbrk>
  if (p == SBRK_ERROR)
 ab0:	fd551ee3          	bne	a0,s5,a8c <malloc+0x7c>
        return 0;
 ab4:	4501                	li	a0,0
 ab6:	74a2                	ld	s1,40(sp)
 ab8:	6a42                	ld	s4,16(sp)
 aba:	6aa2                	ld	s5,8(sp)
 abc:	6b02                	ld	s6,0(sp)
 abe:	a03d                	j	aec <malloc+0xdc>
 ac0:	74a2                	ld	s1,40(sp)
 ac2:	6a42                	ld	s4,16(sp)
 ac4:	6aa2                	ld	s5,8(sp)
 ac6:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 ac8:	fae90fe3          	beq	s2,a4,a86 <malloc+0x76>
        p->s.size -= nunits;
 acc:	4137073b          	subw	a4,a4,s3
 ad0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ad2:	02071693          	slli	a3,a4,0x20
 ad6:	01c6d713          	srli	a4,a3,0x1c
 ada:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 adc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 ae0:	00001717          	auipc	a4,0x1
 ae4:	52a73023          	sd	a0,1312(a4) # 2000 <freep>
      return (void *)(p + 1);
 ae8:	01078513          	addi	a0,a5,16
  }
}
 aec:	70e2                	ld	ra,56(sp)
 aee:	7442                	ld	s0,48(sp)
 af0:	7902                	ld	s2,32(sp)
 af2:	69e2                	ld	s3,24(sp)
 af4:	6121                	addi	sp,sp,64
 af6:	8082                	ret
 af8:	74a2                	ld	s1,40(sp)
 afa:	6a42                	ld	s4,16(sp)
 afc:	6aa2                	ld	s5,8(sp)
 afe:	6b02                	ld	s6,0(sp)
 b00:	b7f5                	j	aec <malloc+0xdc>
