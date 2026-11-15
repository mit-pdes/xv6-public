
user/_threadtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <thread_worker>:
#define PGSIZE 4096

volatile int counter = 0;
volatile int start_flag = 0;

void thread_worker(void *arg) {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	1800                	addi	s0,sp,48
  int id = (int)(uint64)arg;
   a:	0005079b          	sext.w	a5,a0
   e:	84be                	mv	s1,a5

  // Wait until all threads are created so they run truly concurrently
  while (start_flag == 0)
  10:	00002717          	auipc	a4,0x2
  14:	ff070713          	addi	a4,a4,-16 # 2000 <start_flag>
  18:	431c                	lw	a5,0(a4)
  1a:	2781                	sext.w	a5,a5
  1c:	dff5                	beqz	a5,18 <thread_worker+0x18>
  1e:	66e1                	lui	a3,0x18
  20:	6a068693          	addi	a3,a3,1696 # 186a0 <base+0x16690>
    ;

  for (int i = 0; i < INCREMENTS_PER_THREAD; i++) {
    // Non-atomic read-modify-write on shared memory variable
    volatile int val = counter;
  24:	00002617          	auipc	a2,0x2
  28:	fe060613          	addi	a2,a2,-32 # 2004 <counter>
    for (volatile int d = 0; d < 3; d++); // short window to expose race condition
  2c:	4709                	li	a4,2
  2e:	a039                	j	3c <thread_worker+0x3c>
    counter = val + 1;
  30:	fd842783          	lw	a5,-40(s0)
  34:	2785                	addiw	a5,a5,1
  36:	c21c                	sw	a5,0(a2)
  for (int i = 0; i < INCREMENTS_PER_THREAD; i++) {
  38:	36fd                	addiw	a3,a3,-1
  3a:	c69d                	beqz	a3,68 <thread_worker+0x68>
    volatile int val = counter;
  3c:	421c                	lw	a5,0(a2)
  3e:	2781                	sext.w	a5,a5
  40:	fcf42c23          	sw	a5,-40(s0)
    for (volatile int d = 0; d < 3; d++); // short window to expose race condition
  44:	fc042e23          	sw	zero,-36(s0)
  48:	fdc42783          	lw	a5,-36(s0)
  4c:	2781                	sext.w	a5,a5
  4e:	fef741e3          	blt	a4,a5,30 <thread_worker+0x30>
  52:	fdc42783          	lw	a5,-36(s0)
  56:	2785                	addiw	a5,a5,1
  58:	fcf42e23          	sw	a5,-36(s0)
  5c:	fdc42783          	lw	a5,-36(s0)
  60:	2781                	sext.w	a5,a5
  62:	fef758e3          	bge	a4,a5,52 <thread_worker+0x52>
  66:	b7e9                	j	30 <thread_worker+0x30>
  }

  printf("Thread %d (pid %d) finished %d increments.\n",
  68:	540000ef          	jal	5a8 <getpid>
  6c:	862a                	mv	a2,a0
  6e:	66e1                	lui	a3,0x18
  70:	6a068693          	addi	a3,a3,1696 # 186a0 <base+0x16690>
  74:	85a6                	mv	a1,s1
  76:	00001517          	auipc	a0,0x1
  7a:	aba50513          	addi	a0,a0,-1350 # b30 <malloc+0xf2>
  7e:	109000ef          	jal	986 <printf>
         id, getpid(), INCREMENTS_PER_THREAD);
  exit(0);
  82:	4501                	li	a0,0
  84:	4a4000ef          	jal	528 <exit>

0000000000000088 <main>:
}

int main(int argc, char *argv[]) {
  88:	7119                	addi	sp,sp,-128
  8a:	fc86                	sd	ra,120(sp)
  8c:	f8a2                	sd	s0,112(sp)
  8e:	f4a6                	sd	s1,104(sp)
  90:	f0ca                	sd	s2,96(sp)
  92:	ecce                	sd	s3,88(sp)
  94:	e8d2                	sd	s4,80(sp)
  96:	e4d6                	sd	s5,72(sp)
  98:	e0da                	sd	s6,64(sp)
  9a:	fc5e                	sd	s7,56(sp)
  9c:	f862                	sd	s8,48(sp)
  9e:	f466                	sd	s9,40(sp)
  a0:	0100                	addi	s0,sp,128
  printf("============================================================\n");
  a2:	00001517          	auipc	a0,0x1
  a6:	abe50513          	addi	a0,a0,-1346 # b60 <malloc+0x122>
  aa:	0dd000ef          	jal	986 <printf>
  printf("   Kernel-Supported Threads Demonstration with clone()      \n");
  ae:	00001517          	auipc	a0,0x1
  b2:	af250513          	addi	a0,a0,-1294 # ba0 <malloc+0x162>
  b6:	0d1000ef          	jal	986 <printf>
  printf("   Threads: %d, Increments per thread: %d                   \n",
  ba:	6661                	lui	a2,0x18
  bc:	6a060613          	addi	a2,a2,1696 # 186a0 <base+0x16690>
  c0:	458d                	li	a1,3
  c2:	00001517          	auipc	a0,0x1
  c6:	b1e50513          	addi	a0,a0,-1250 # be0 <malloc+0x1a2>
  ca:	0bd000ef          	jal	986 <printf>
         NUM_THREADS, INCREMENTS_PER_THREAD);
  printf("   Expected counter without race condition: %d              \n",
  ce:	000495b7          	lui	a1,0x49
  d2:	3e058593          	addi	a1,a1,992 # 493e0 <base+0x473d0>
  d6:	00001517          	auipc	a0,0x1
  da:	b4a50513          	addi	a0,a0,-1206 # c20 <malloc+0x1e2>
  de:	0a9000ef          	jal	986 <printf>
         NUM_THREADS * INCREMENTS_PER_THREAD);
  printf("============================================================\n");
  e2:	00001517          	auipc	a0,0x1
  e6:	a7e50513          	addi	a0,a0,-1410 # b60 <malloc+0x122>
  ea:	09d000ef          	jal	986 <printf>

  void *stacks[NUM_THREADS];
  int tids[NUM_THREADS];

  counter = 0;
  ee:	00002797          	auipc	a5,0x2
  f2:	f007ab23          	sw	zero,-234(a5) # 2004 <counter>

  // Create threads
  for (int i = 0; i < NUM_THREADS; i++) {
  f6:	f8840913          	addi	s2,s0,-120
  counter = 0;
  fa:	8a4a                	mv	s4,s2
  fc:	4485                	li	s1,1
    stacks[i] = malloc(PGSIZE);
  fe:	6a85                	lui	s5,0x1
    if (stacks[i] == 0) {
      printf("Error: malloc failed for thread %d stack\n", i);
      exit(1);
    }

    tids[i] = clone(thread_worker, (void *)(uint64)(i + 1), stacks[i]);
 100:	00000b17          	auipc	s6,0x0
 104:	f00b0b13          	addi	s6,s6,-256 # 0 <thread_worker>
    if (tids[i] < 0) {
      printf("Error: clone failed for thread %d\n", i);
      exit(1);
    }
    printf("Main (pid %d): Cloned Thread %d with pid %d\n",
 108:	00001c17          	auipc	s8,0x1
 10c:	bb0c0c13          	addi	s8,s8,-1104 # cb8 <malloc+0x27a>
  for (int i = 0; i < NUM_THREADS; i++) {
 110:	4b91                	li	s7,4
 112:	fff48c9b          	addiw	s9,s1,-1
    stacks[i] = malloc(PGSIZE);
 116:	8556                	mv	a0,s5
 118:	127000ef          	jal	a3e <malloc>
 11c:	862a                	mv	a2,a0
 11e:	00aa3023          	sd	a0,0(s4)
    if (stacks[i] == 0) {
 122:	10050c63          	beqz	a0,23a <main+0x1b2>
    tids[i] = clone(thread_worker, (void *)(uint64)(i + 1), stacks[i]);
 126:	85a6                	mv	a1,s1
 128:	855a                	mv	a0,s6
 12a:	4a6000ef          	jal	5d0 <clone>
 12e:	89aa                	mv	s3,a0
    if (tids[i] < 0) {
 130:	10054f63          	bltz	a0,24e <main+0x1c6>
    printf("Main (pid %d): Cloned Thread %d with pid %d\n",
 134:	474000ef          	jal	5a8 <getpid>
 138:	85aa                	mv	a1,a0
 13a:	86ce                	mv	a3,s3
 13c:	0004861b          	sext.w	a2,s1
 140:	8562                	mv	a0,s8
 142:	045000ef          	jal	986 <printf>
  for (int i = 0; i < NUM_THREADS; i++) {
 146:	0485                	addi	s1,s1,1
 148:	0a21                	addi	s4,s4,8
 14a:	fd7494e3          	bne	s1,s7,112 <main+0x8a>
           getpid(), i + 1, tids[i]);
  }

  // Release all threads simultaneously across CPUs
  printf("Main: Releasing all 3 threads concurrently...\n");
 14e:	00001517          	auipc	a0,0x1
 152:	b9a50513          	addi	a0,a0,-1126 # ce8 <malloc+0x2aa>
 156:	031000ef          	jal	986 <printf>
  start_flag = 1;
 15a:	4785                	li	a5,1
 15c:	00002717          	auipc	a4,0x2
 160:	eaf72223          	sw	a5,-348(a4) # 2000 <start_flag>
 164:	448d                	li	s1,3

  // Join all threads
  for (int i = 0; i < NUM_THREADS; i++) {
    int joined_pid = join();
    printf("Main: Reaped thread with pid %d via join()\n", joined_pid);
 166:	00001997          	auipc	s3,0x1
 16a:	bb298993          	addi	s3,s3,-1102 # d18 <malloc+0x2da>
    int joined_pid = join();
 16e:	46a000ef          	jal	5d8 <join>
 172:	85aa                	mv	a1,a0
    printf("Main: Reaped thread with pid %d via join()\n", joined_pid);
 174:	854e                	mv	a0,s3
 176:	011000ef          	jal	986 <printf>
  for (int i = 0; i < NUM_THREADS; i++) {
 17a:	34fd                	addiw	s1,s1,-1
 17c:	f8ed                	bnez	s1,16e <main+0xe6>
  }

  int expected = NUM_THREADS * INCREMENTS_PER_THREAD;
  int actual = counter;
 17e:	00002497          	auipc	s1,0x2
 182:	e864a483          	lw	s1,-378(s1) # 2004 <counter>

  printf("============================================================\n");
 186:	00001517          	auipc	a0,0x1
 18a:	9da50513          	addi	a0,a0,-1574 # b60 <malloc+0x122>
 18e:	7f8000ef          	jal	986 <printf>
  printf("Simulation Finished Summary:\n");
 192:	00001517          	auipc	a0,0x1
 196:	bb650513          	addi	a0,a0,-1098 # d48 <malloc+0x30a>
 19a:	7ec000ef          	jal	986 <printf>
  printf("All %d threads executed in the SAME shared address space.\n", NUM_THREADS);
 19e:	458d                	li	a1,3
 1a0:	00001517          	auipc	a0,0x1
 1a4:	bc850513          	addi	a0,a0,-1080 # d68 <malloc+0x32a>
 1a8:	7de000ef          	jal	986 <printf>
  printf("Expected Counter : %d\n", expected);
 1ac:	000495b7          	lui	a1,0x49
 1b0:	3e058593          	addi	a1,a1,992 # 493e0 <base+0x473d0>
 1b4:	00001517          	auipc	a0,0x1
 1b8:	bf450513          	addi	a0,a0,-1036 # da8 <malloc+0x36a>
 1bc:	7ca000ef          	jal	986 <printf>
  printf("Actual Counter   : %d\n", actual);
 1c0:	85a6                	mv	a1,s1
 1c2:	00001517          	auipc	a0,0x1
 1c6:	bfe50513          	addi	a0,a0,-1026 # dc0 <malloc+0x382>
 1ca:	7bc000ef          	jal	986 <printf>

  if (actual < expected) {
 1ce:	000497b7          	lui	a5,0x49
 1d2:	3df78793          	addi	a5,a5,991 # 493df <base+0x473cf>
 1d6:	0897c663          	blt	a5,s1,262 <main+0x1da>
    int lost = expected - actual;
 1da:	000497b7          	lui	a5,0x49
 1de:	3e07879b          	addiw	a5,a5,992 # 493e0 <base+0x473d0>
 1e2:	409785bb          	subw	a1,a5,s1
    int pct = (lost * 100) / expected;
 1e6:	06400613          	li	a2,100
 1ea:	02b6063b          	mulw	a2,a2,a1
    printf("Race condition confirmed: Lost updates = %d (%d%% loss).\n",
 1ee:	02f6463b          	divw	a2,a2,a5
 1f2:	00001517          	auipc	a0,0x1
 1f6:	be650513          	addi	a0,a0,-1050 # dd8 <malloc+0x39a>
 1fa:	78c000ef          	jal	986 <printf>
           lost, pct);
    printf("Explanation: Unsynchronized concurrent execution caused\n");
 1fe:	00001517          	auipc	a0,0x1
 202:	c1a50513          	addi	a0,a0,-998 # e18 <malloc+0x3da>
 206:	780000ef          	jal	986 <printf>
    printf("interleaved read-modify-write cycles. (Fixed in Question 2 using Semaphores).\n");
 20a:	00001517          	auipc	a0,0x1
 20e:	c4e50513          	addi	a0,a0,-946 # e58 <malloc+0x41a>
 212:	774000ef          	jal	986 <printf>
  } else {
    printf("Counter reached %d.\n", actual);
  }
  printf("============================================================\n");
 216:	00001517          	auipc	a0,0x1
 21a:	94a50513          	addi	a0,a0,-1718 # b60 <malloc+0x122>
 21e:	768000ef          	jal	986 <printf>

  // Free allocated stack pages
  for (int i = 0; i < NUM_THREADS; i++) {
 222:	01890493          	addi	s1,s2,24
    free(stacks[i]);
 226:	00093503          	ld	a0,0(s2)
 22a:	78e000ef          	jal	9b8 <free>
  for (int i = 0; i < NUM_THREADS; i++) {
 22e:	0921                	addi	s2,s2,8
 230:	fe991be3          	bne	s2,s1,226 <main+0x19e>
  }

  exit(0);
 234:	4501                	li	a0,0
 236:	2f2000ef          	jal	528 <exit>
      printf("Error: malloc failed for thread %d stack\n", i);
 23a:	85e6                	mv	a1,s9
 23c:	00001517          	auipc	a0,0x1
 240:	a2450513          	addi	a0,a0,-1500 # c60 <malloc+0x222>
 244:	742000ef          	jal	986 <printf>
      exit(1);
 248:	4505                	li	a0,1
 24a:	2de000ef          	jal	528 <exit>
      printf("Error: clone failed for thread %d\n", i);
 24e:	85e6                	mv	a1,s9
 250:	00001517          	auipc	a0,0x1
 254:	a4050513          	addi	a0,a0,-1472 # c90 <malloc+0x252>
 258:	72e000ef          	jal	986 <printf>
      exit(1);
 25c:	4505                	li	a0,1
 25e:	2ca000ef          	jal	528 <exit>
    printf("Counter reached %d.\n", actual);
 262:	85a6                	mv	a1,s1
 264:	00001517          	auipc	a0,0x1
 268:	c4450513          	addi	a0,a0,-956 # ea8 <malloc+0x46a>
 26c:	71a000ef          	jal	986 <printf>
 270:	b75d                	j	216 <main+0x18e>

0000000000000272 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 272:	1141                	addi	sp,sp,-16
 274:	e406                	sd	ra,8(sp)
 276:	e022                	sd	s0,0(sp)
 278:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 27a:	e0fff0ef          	jal	88 <main>
  exit(r);
 27e:	2aa000ef          	jal	528 <exit>

0000000000000282 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 282:	1141                	addi	sp,sp,-16
 284:	e406                	sd	ra,8(sp)
 286:	e022                	sd	s0,0(sp)
 288:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 28a:	87aa                	mv	a5,a0
 28c:	0585                	addi	a1,a1,1
 28e:	0785                	addi	a5,a5,1
 290:	fff5c703          	lbu	a4,-1(a1)
 294:	fee78fa3          	sb	a4,-1(a5)
 298:	fb75                	bnez	a4,28c <strcpy+0xa>
    ;
  return os;
}
 29a:	60a2                	ld	ra,8(sp)
 29c:	6402                	ld	s0,0(sp)
 29e:	0141                	addi	sp,sp,16
 2a0:	8082                	ret

00000000000002a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2a2:	1141                	addi	sp,sp,-16
 2a4:	e406                	sd	ra,8(sp)
 2a6:	e022                	sd	s0,0(sp)
 2a8:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 2aa:	00054783          	lbu	a5,0(a0)
 2ae:	cb91                	beqz	a5,2c2 <strcmp+0x20>
 2b0:	0005c703          	lbu	a4,0(a1)
 2b4:	00f71763          	bne	a4,a5,2c2 <strcmp+0x20>
    p++, q++;
 2b8:	0505                	addi	a0,a0,1
 2ba:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 2bc:	00054783          	lbu	a5,0(a0)
 2c0:	fbe5                	bnez	a5,2b0 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 2c2:	0005c503          	lbu	a0,0(a1)
}
 2c6:	40a7853b          	subw	a0,a5,a0
 2ca:	60a2                	ld	ra,8(sp)
 2cc:	6402                	ld	s0,0(sp)
 2ce:	0141                	addi	sp,sp,16
 2d0:	8082                	ret

00000000000002d2 <strlen>:

uint
strlen(const char *s)
{
 2d2:	1141                	addi	sp,sp,-16
 2d4:	e406                	sd	ra,8(sp)
 2d6:	e022                	sd	s0,0(sp)
 2d8:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 2da:	00054783          	lbu	a5,0(a0)
 2de:	cf91                	beqz	a5,2fa <strlen+0x28>
 2e0:	00150793          	addi	a5,a0,1
 2e4:	86be                	mv	a3,a5
 2e6:	0785                	addi	a5,a5,1
 2e8:	fff7c703          	lbu	a4,-1(a5)
 2ec:	ff65                	bnez	a4,2e4 <strlen+0x12>
 2ee:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 2f2:	60a2                	ld	ra,8(sp)
 2f4:	6402                	ld	s0,0(sp)
 2f6:	0141                	addi	sp,sp,16
 2f8:	8082                	ret
  for (n = 0; s[n]; n++)
 2fa:	4501                	li	a0,0
 2fc:	bfdd                	j	2f2 <strlen+0x20>

00000000000002fe <memset>:

void *
memset(void *dst, int c, uint n)
{
 2fe:	1141                	addi	sp,sp,-16
 300:	e406                	sd	ra,8(sp)
 302:	e022                	sd	s0,0(sp)
 304:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 306:	ca19                	beqz	a2,31c <memset+0x1e>
 308:	87aa                	mv	a5,a0
 30a:	1602                	slli	a2,a2,0x20
 30c:	9201                	srli	a2,a2,0x20
 30e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 312:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 316:	0785                	addi	a5,a5,1
 318:	fee79de3          	bne	a5,a4,312 <memset+0x14>
  }
  return dst;
}
 31c:	60a2                	ld	ra,8(sp)
 31e:	6402                	ld	s0,0(sp)
 320:	0141                	addi	sp,sp,16
 322:	8082                	ret

0000000000000324 <strchr>:

char *
strchr(const char *s, char c)
{
 324:	1141                	addi	sp,sp,-16
 326:	e406                	sd	ra,8(sp)
 328:	e022                	sd	s0,0(sp)
 32a:	0800                	addi	s0,sp,16
  for (; *s; s++)
 32c:	00054783          	lbu	a5,0(a0)
 330:	cf81                	beqz	a5,348 <strchr+0x24>
    if (*s == c)
 332:	00f58763          	beq	a1,a5,340 <strchr+0x1c>
  for (; *s; s++)
 336:	0505                	addi	a0,a0,1
 338:	00054783          	lbu	a5,0(a0)
 33c:	fbfd                	bnez	a5,332 <strchr+0xe>
      return (char *)s;
  return 0;
 33e:	4501                	li	a0,0
}
 340:	60a2                	ld	ra,8(sp)
 342:	6402                	ld	s0,0(sp)
 344:	0141                	addi	sp,sp,16
 346:	8082                	ret
  return 0;
 348:	4501                	li	a0,0
 34a:	bfdd                	j	340 <strchr+0x1c>

000000000000034c <gets>:

char *
gets(char *buf, int max)
{
 34c:	711d                	addi	sp,sp,-96
 34e:	ec86                	sd	ra,88(sp)
 350:	e8a2                	sd	s0,80(sp)
 352:	e4a6                	sd	s1,72(sp)
 354:	e0ca                	sd	s2,64(sp)
 356:	fc4e                	sd	s3,56(sp)
 358:	f852                	sd	s4,48(sp)
 35a:	f456                	sd	s5,40(sp)
 35c:	f05a                	sd	s6,32(sp)
 35e:	ec5e                	sd	s7,24(sp)
 360:	e862                	sd	s8,16(sp)
 362:	1080                	addi	s0,sp,96
 364:	8baa                	mv	s7,a0
 366:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 368:	892a                	mv	s2,a0
 36a:	4481                	li	s1,0
    cc = read(0, &c, 1);
 36c:	faf40b13          	addi	s6,s0,-81
 370:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 372:	8c26                	mv	s8,s1
 374:	0014899b          	addiw	s3,s1,1
 378:	84ce                	mv	s1,s3
 37a:	0349d463          	bge	s3,s4,3a2 <gets+0x56>
    cc = read(0, &c, 1);
 37e:	8656                	mv	a2,s5
 380:	85da                	mv	a1,s6
 382:	4501                	li	a0,0
 384:	1bc000ef          	jal	540 <read>
    if (cc < 1)
 388:	00a05d63          	blez	a0,3a2 <gets+0x56>
      break;
    buf[i++] = c;
 38c:	faf44783          	lbu	a5,-81(s0)
 390:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 394:	0905                	addi	s2,s2,1
 396:	ff678713          	addi	a4,a5,-10
 39a:	c319                	beqz	a4,3a0 <gets+0x54>
 39c:	17cd                	addi	a5,a5,-13
 39e:	fbf1                	bnez	a5,372 <gets+0x26>
    buf[i++] = c;
 3a0:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 3a2:	9c5e                	add	s8,s8,s7
 3a4:	000c0023          	sb	zero,0(s8)
  return buf;
}
 3a8:	855e                	mv	a0,s7
 3aa:	60e6                	ld	ra,88(sp)
 3ac:	6446                	ld	s0,80(sp)
 3ae:	64a6                	ld	s1,72(sp)
 3b0:	6906                	ld	s2,64(sp)
 3b2:	79e2                	ld	s3,56(sp)
 3b4:	7a42                	ld	s4,48(sp)
 3b6:	7aa2                	ld	s5,40(sp)
 3b8:	7b02                	ld	s6,32(sp)
 3ba:	6be2                	ld	s7,24(sp)
 3bc:	6c42                	ld	s8,16(sp)
 3be:	6125                	addi	sp,sp,96
 3c0:	8082                	ret

00000000000003c2 <stat>:

int
stat(const char *n, struct stat *st)
{
 3c2:	1101                	addi	sp,sp,-32
 3c4:	ec06                	sd	ra,24(sp)
 3c6:	e822                	sd	s0,16(sp)
 3c8:	e04a                	sd	s2,0(sp)
 3ca:	1000                	addi	s0,sp,32
 3cc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3ce:	4581                	li	a1,0
 3d0:	198000ef          	jal	568 <open>
  if (fd < 0)
 3d4:	02054263          	bltz	a0,3f8 <stat+0x36>
 3d8:	e426                	sd	s1,8(sp)
 3da:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3dc:	85ca                	mv	a1,s2
 3de:	1a2000ef          	jal	580 <fstat>
 3e2:	892a                	mv	s2,a0
  close(fd);
 3e4:	8526                	mv	a0,s1
 3e6:	16a000ef          	jal	550 <close>
  return r;
 3ea:	64a2                	ld	s1,8(sp)
}
 3ec:	854a                	mv	a0,s2
 3ee:	60e2                	ld	ra,24(sp)
 3f0:	6442                	ld	s0,16(sp)
 3f2:	6902                	ld	s2,0(sp)
 3f4:	6105                	addi	sp,sp,32
 3f6:	8082                	ret
    return -1;
 3f8:	57fd                	li	a5,-1
 3fa:	893e                	mv	s2,a5
 3fc:	bfc5                	j	3ec <stat+0x2a>

00000000000003fe <atoi>:

int
atoi(const char *s)
{
 3fe:	1141                	addi	sp,sp,-16
 400:	e406                	sd	ra,8(sp)
 402:	e022                	sd	s0,0(sp)
 404:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 406:	00054683          	lbu	a3,0(a0)
 40a:	fd06879b          	addiw	a5,a3,-48
 40e:	0ff7f793          	zext.b	a5,a5
 412:	4625                	li	a2,9
 414:	02f66963          	bltu	a2,a5,446 <atoi+0x48>
 418:	872a                	mv	a4,a0
  n = 0;
 41a:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 41c:	0705                	addi	a4,a4,1
 41e:	0025179b          	slliw	a5,a0,0x2
 422:	9fa9                	addw	a5,a5,a0
 424:	0017979b          	slliw	a5,a5,0x1
 428:	9fb5                	addw	a5,a5,a3
 42a:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 42e:	00074683          	lbu	a3,0(a4)
 432:	fd06879b          	addiw	a5,a3,-48
 436:	0ff7f793          	zext.b	a5,a5
 43a:	fef671e3          	bgeu	a2,a5,41c <atoi+0x1e>
  return n;
}
 43e:	60a2                	ld	ra,8(sp)
 440:	6402                	ld	s0,0(sp)
 442:	0141                	addi	sp,sp,16
 444:	8082                	ret
  n = 0;
 446:	4501                	li	a0,0
 448:	bfdd                	j	43e <atoi+0x40>

000000000000044a <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 44a:	1141                	addi	sp,sp,-16
 44c:	e406                	sd	ra,8(sp)
 44e:	e022                	sd	s0,0(sp)
 450:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 452:	02b57563          	bgeu	a0,a1,47c <memmove+0x32>
    while (n-- > 0)
 456:	00c05f63          	blez	a2,474 <memmove+0x2a>
 45a:	1602                	slli	a2,a2,0x20
 45c:	9201                	srli	a2,a2,0x20
 45e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 462:	872a                	mv	a4,a0
      *dst++ = *src++;
 464:	0585                	addi	a1,a1,1
 466:	0705                	addi	a4,a4,1
 468:	fff5c683          	lbu	a3,-1(a1)
 46c:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 470:	fee79ae3          	bne	a5,a4,464 <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 474:	60a2                	ld	ra,8(sp)
 476:	6402                	ld	s0,0(sp)
 478:	0141                	addi	sp,sp,16
 47a:	8082                	ret
    while (n-- > 0)
 47c:	fec05ce3          	blez	a2,474 <memmove+0x2a>
    dst += n;
 480:	00c50733          	add	a4,a0,a2
    src += n;
 484:	95b2                	add	a1,a1,a2
 486:	fff6079b          	addiw	a5,a2,-1
 48a:	1782                	slli	a5,a5,0x20
 48c:	9381                	srli	a5,a5,0x20
 48e:	fff7c793          	not	a5,a5
 492:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 494:	15fd                	addi	a1,a1,-1
 496:	177d                	addi	a4,a4,-1
 498:	0005c683          	lbu	a3,0(a1)
 49c:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 4a0:	fef71ae3          	bne	a4,a5,494 <memmove+0x4a>
 4a4:	bfc1                	j	474 <memmove+0x2a>

00000000000004a6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4a6:	1141                	addi	sp,sp,-16
 4a8:	e406                	sd	ra,8(sp)
 4aa:	e022                	sd	s0,0(sp)
 4ac:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4ae:	c61d                	beqz	a2,4dc <memcmp+0x36>
 4b0:	1602                	slli	a2,a2,0x20
 4b2:	9201                	srli	a2,a2,0x20
 4b4:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 4b8:	00054783          	lbu	a5,0(a0)
 4bc:	0005c703          	lbu	a4,0(a1)
 4c0:	00e79863          	bne	a5,a4,4d0 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 4c4:	0505                	addi	a0,a0,1
    p2++;
 4c6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4c8:	fed518e3          	bne	a0,a3,4b8 <memcmp+0x12>
  }
  return 0;
 4cc:	4501                	li	a0,0
 4ce:	a019                	j	4d4 <memcmp+0x2e>
      return *p1 - *p2;
 4d0:	40e7853b          	subw	a0,a5,a4
}
 4d4:	60a2                	ld	ra,8(sp)
 4d6:	6402                	ld	s0,0(sp)
 4d8:	0141                	addi	sp,sp,16
 4da:	8082                	ret
  return 0;
 4dc:	4501                	li	a0,0
 4de:	bfdd                	j	4d4 <memcmp+0x2e>

00000000000004e0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4e0:	1141                	addi	sp,sp,-16
 4e2:	e406                	sd	ra,8(sp)
 4e4:	e022                	sd	s0,0(sp)
 4e6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4e8:	f63ff0ef          	jal	44a <memmove>
}
 4ec:	60a2                	ld	ra,8(sp)
 4ee:	6402                	ld	s0,0(sp)
 4f0:	0141                	addi	sp,sp,16
 4f2:	8082                	ret

00000000000004f4 <sbrk>:

char *
sbrk(int n)
{
 4f4:	1141                	addi	sp,sp,-16
 4f6:	e406                	sd	ra,8(sp)
 4f8:	e022                	sd	s0,0(sp)
 4fa:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4fc:	4585                	li	a1,1
 4fe:	0b2000ef          	jal	5b0 <sys_sbrk>
}
 502:	60a2                	ld	ra,8(sp)
 504:	6402                	ld	s0,0(sp)
 506:	0141                	addi	sp,sp,16
 508:	8082                	ret

000000000000050a <sbrklazy>:

char *
sbrklazy(int n)
{
 50a:	1141                	addi	sp,sp,-16
 50c:	e406                	sd	ra,8(sp)
 50e:	e022                	sd	s0,0(sp)
 510:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 512:	4589                	li	a1,2
 514:	09c000ef          	jal	5b0 <sys_sbrk>
}
 518:	60a2                	ld	ra,8(sp)
 51a:	6402                	ld	s0,0(sp)
 51c:	0141                	addi	sp,sp,16
 51e:	8082                	ret

0000000000000520 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 520:	4885                	li	a7,1
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <exit>:
.global exit
exit:
 li a7, SYS_exit
 528:	4889                	li	a7,2
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <wait>:
.global wait
wait:
 li a7, SYS_wait
 530:	488d                	li	a7,3
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 538:	4891                	li	a7,4
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <read>:
.global read
read:
 li a7, SYS_read
 540:	4895                	li	a7,5
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <write>:
.global write
write:
 li a7, SYS_write
 548:	48c1                	li	a7,16
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <close>:
.global close
close:
 li a7, SYS_close
 550:	48d5                	li	a7,21
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <kill>:
.global kill
kill:
 li a7, SYS_kill
 558:	4899                	li	a7,6
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <exec>:
.global exec
exec:
 li a7, SYS_exec
 560:	489d                	li	a7,7
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <open>:
.global open
open:
 li a7, SYS_open
 568:	48bd                	li	a7,15
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 570:	48c5                	li	a7,17
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 578:	48c9                	li	a7,18
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 580:	48a1                	li	a7,8
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <link>:
.global link
link:
 li a7, SYS_link
 588:	48cd                	li	a7,19
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 590:	48d1                	li	a7,20
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 598:	48a5                	li	a7,9
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5a0:	48a9                	li	a7,10
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5a8:	48ad                	li	a7,11
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 5b0:	48b1                	li	a7,12
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <pause>:
.global pause
pause:
 li a7, SYS_pause
 5b8:	48b5                	li	a7,13
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5c0:	48b9                	li	a7,14
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <sync>:
.global sync
sync:
 li a7, SYS_sync
 5c8:	48d9                	li	a7,22
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <clone>:
.global clone
clone:
 li a7, SYS_clone
 5d0:	48dd                	li	a7,23
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <join>:
.global join
join:
 li a7, SYS_join
 5d8:	48e1                	li	a7,24
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5e0:	1101                	addi	sp,sp,-32
 5e2:	ec06                	sd	ra,24(sp)
 5e4:	e822                	sd	s0,16(sp)
 5e6:	1000                	addi	s0,sp,32
 5e8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5ec:	4605                	li	a2,1
 5ee:	fef40593          	addi	a1,s0,-17
 5f2:	f57ff0ef          	jal	548 <write>
}
 5f6:	60e2                	ld	ra,24(sp)
 5f8:	6442                	ld	s0,16(sp)
 5fa:	6105                	addi	sp,sp,32
 5fc:	8082                	ret

00000000000005fe <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 5fe:	715d                	addi	sp,sp,-80
 600:	e486                	sd	ra,72(sp)
 602:	e0a2                	sd	s0,64(sp)
 604:	f84a                	sd	s2,48(sp)
 606:	f44e                	sd	s3,40(sp)
 608:	0880                	addi	s0,sp,80
 60a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 60c:	c6d1                	beqz	a3,698 <printint+0x9a>
 60e:	0805d563          	bgez	a1,698 <printint+0x9a>
    neg = 1;
    x = -xx;
 612:	40b005b3          	neg	a1,a1
    neg = 1;
 616:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 618:	fb840993          	addi	s3,s0,-72
  neg = 0;
 61c:	86ce                	mv	a3,s3
  i = 0;
 61e:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 620:	00001817          	auipc	a6,0x1
 624:	8a880813          	addi	a6,a6,-1880 # ec8 <digits>
 628:	88ba                	mv	a7,a4
 62a:	0017051b          	addiw	a0,a4,1
 62e:	872a                	mv	a4,a0
 630:	02c5f7b3          	remu	a5,a1,a2
 634:	97c2                	add	a5,a5,a6
 636:	0007c783          	lbu	a5,0(a5)
 63a:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 63e:	87ae                	mv	a5,a1
 640:	02c5d5b3          	divu	a1,a1,a2
 644:	0685                	addi	a3,a3,1
 646:	fec7f1e3          	bgeu	a5,a2,628 <printint+0x2a>
  if (neg)
 64a:	00030c63          	beqz	t1,662 <printint+0x64>
    buf[i++] = '-';
 64e:	fd050793          	addi	a5,a0,-48
 652:	00878533          	add	a0,a5,s0
 656:	02d00793          	li	a5,45
 65a:	fef50423          	sb	a5,-24(a0)
 65e:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 662:	02e05563          	blez	a4,68c <printint+0x8e>
 666:	fc26                	sd	s1,56(sp)
 668:	377d                	addiw	a4,a4,-1
 66a:	00e984b3          	add	s1,s3,a4
 66e:	19fd                	addi	s3,s3,-1
 670:	99ba                	add	s3,s3,a4
 672:	1702                	slli	a4,a4,0x20
 674:	9301                	srli	a4,a4,0x20
 676:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 67a:	0004c583          	lbu	a1,0(s1)
 67e:	854a                	mv	a0,s2
 680:	f61ff0ef          	jal	5e0 <putc>
  while (--i >= 0)
 684:	14fd                	addi	s1,s1,-1
 686:	ff349ae3          	bne	s1,s3,67a <printint+0x7c>
 68a:	74e2                	ld	s1,56(sp)
}
 68c:	60a6                	ld	ra,72(sp)
 68e:	6406                	ld	s0,64(sp)
 690:	7942                	ld	s2,48(sp)
 692:	79a2                	ld	s3,40(sp)
 694:	6161                	addi	sp,sp,80
 696:	8082                	ret
  neg = 0;
 698:	4301                	li	t1,0
 69a:	bfbd                	j	618 <printint+0x1a>

000000000000069c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 69c:	711d                	addi	sp,sp,-96
 69e:	ec86                	sd	ra,88(sp)
 6a0:	e8a2                	sd	s0,80(sp)
 6a2:	e4a6                	sd	s1,72(sp)
 6a4:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 6a6:	0005c483          	lbu	s1,0(a1)
 6aa:	22048363          	beqz	s1,8d0 <vprintf+0x234>
 6ae:	e0ca                	sd	s2,64(sp)
 6b0:	fc4e                	sd	s3,56(sp)
 6b2:	f852                	sd	s4,48(sp)
 6b4:	f456                	sd	s5,40(sp)
 6b6:	f05a                	sd	s6,32(sp)
 6b8:	ec5e                	sd	s7,24(sp)
 6ba:	e862                	sd	s8,16(sp)
 6bc:	8b2a                	mv	s6,a0
 6be:	8a2e                	mv	s4,a1
 6c0:	8bb2                	mv	s7,a2
  state = 0;
 6c2:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 6c4:	4901                	li	s2,0
 6c6:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 6c8:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 6cc:	06400c13          	li	s8,100
 6d0:	a00d                	j	6f2 <vprintf+0x56>
        putc(fd, c0);
 6d2:	85a6                	mv	a1,s1
 6d4:	855a                	mv	a0,s6
 6d6:	f0bff0ef          	jal	5e0 <putc>
 6da:	a019                	j	6e0 <vprintf+0x44>
    } else if (state == '%') {
 6dc:	03598363          	beq	s3,s5,702 <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 6e0:	0019079b          	addiw	a5,s2,1
 6e4:	893e                	mv	s2,a5
 6e6:	873e                	mv	a4,a5
 6e8:	97d2                	add	a5,a5,s4
 6ea:	0007c483          	lbu	s1,0(a5)
 6ee:	1c048a63          	beqz	s1,8c2 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 6f2:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 6f6:	fe0993e3          	bnez	s3,6dc <vprintf+0x40>
      if (c0 == '%') {
 6fa:	fd579ce3          	bne	a5,s5,6d2 <vprintf+0x36>
        state = '%';
 6fe:	89be                	mv	s3,a5
 700:	b7c5                	j	6e0 <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 702:	00ea06b3          	add	a3,s4,a4
 706:	0016c603          	lbu	a2,1(a3)
      if (c1)
 70a:	1c060863          	beqz	a2,8da <vprintf+0x23e>
      if (c0 == 'd') {
 70e:	03878763          	beq	a5,s8,73c <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 712:	f9478693          	addi	a3,a5,-108
 716:	0016b693          	seqz	a3,a3
 71a:	f9c60593          	addi	a1,a2,-100
 71e:	e99d                	bnez	a1,754 <vprintf+0xb8>
 720:	ca95                	beqz	a3,754 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 722:	008b8493          	addi	s1,s7,8
 726:	4685                	li	a3,1
 728:	4629                	li	a2,10
 72a:	000bb583          	ld	a1,0(s7)
 72e:	855a                	mv	a0,s6
 730:	ecfff0ef          	jal	5fe <printint>
        i += 1;
 734:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 736:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 738:	4981                	li	s3,0
 73a:	b75d                	j	6e0 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 73c:	008b8493          	addi	s1,s7,8
 740:	4685                	li	a3,1
 742:	4629                	li	a2,10
 744:	000ba583          	lw	a1,0(s7)
 748:	855a                	mv	a0,s6
 74a:	eb5ff0ef          	jal	5fe <printint>
 74e:	8ba6                	mv	s7,s1
      state = 0;
 750:	4981                	li	s3,0
 752:	b779                	j	6e0 <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 754:	9752                	add	a4,a4,s4
 756:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 75a:	f9460713          	addi	a4,a2,-108
 75e:	00173713          	seqz	a4,a4
 762:	8f75                	and	a4,a4,a3
 764:	f9c58513          	addi	a0,a1,-100
 768:	18051363          	bnez	a0,8ee <vprintf+0x252>
 76c:	18070163          	beqz	a4,8ee <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 770:	008b8493          	addi	s1,s7,8
 774:	4685                	li	a3,1
 776:	4629                	li	a2,10
 778:	000bb583          	ld	a1,0(s7)
 77c:	855a                	mv	a0,s6
 77e:	e81ff0ef          	jal	5fe <printint>
        i += 2;
 782:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 784:	8ba6                	mv	s7,s1
      state = 0;
 786:	4981                	li	s3,0
        i += 2;
 788:	bfa1                	j	6e0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 78a:	008b8493          	addi	s1,s7,8
 78e:	4681                	li	a3,0
 790:	4629                	li	a2,10
 792:	000be583          	lwu	a1,0(s7)
 796:	855a                	mv	a0,s6
 798:	e67ff0ef          	jal	5fe <printint>
 79c:	8ba6                	mv	s7,s1
      state = 0;
 79e:	4981                	li	s3,0
 7a0:	b781                	j	6e0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7a2:	008b8493          	addi	s1,s7,8
 7a6:	4681                	li	a3,0
 7a8:	4629                	li	a2,10
 7aa:	000bb583          	ld	a1,0(s7)
 7ae:	855a                	mv	a0,s6
 7b0:	e4fff0ef          	jal	5fe <printint>
        i += 1;
 7b4:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 7b6:	8ba6                	mv	s7,s1
      state = 0;
 7b8:	4981                	li	s3,0
 7ba:	b71d                	j	6e0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7bc:	008b8493          	addi	s1,s7,8
 7c0:	4681                	li	a3,0
 7c2:	4629                	li	a2,10
 7c4:	000bb583          	ld	a1,0(s7)
 7c8:	855a                	mv	a0,s6
 7ca:	e35ff0ef          	jal	5fe <printint>
        i += 2;
 7ce:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7d0:	8ba6                	mv	s7,s1
      state = 0;
 7d2:	4981                	li	s3,0
        i += 2;
 7d4:	b731                	j	6e0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 7d6:	008b8493          	addi	s1,s7,8
 7da:	4681                	li	a3,0
 7dc:	4641                	li	a2,16
 7de:	000be583          	lwu	a1,0(s7)
 7e2:	855a                	mv	a0,s6
 7e4:	e1bff0ef          	jal	5fe <printint>
 7e8:	8ba6                	mv	s7,s1
      state = 0;
 7ea:	4981                	li	s3,0
 7ec:	bdd5                	j	6e0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7ee:	008b8493          	addi	s1,s7,8
 7f2:	4681                	li	a3,0
 7f4:	4641                	li	a2,16
 7f6:	000bb583          	ld	a1,0(s7)
 7fa:	855a                	mv	a0,s6
 7fc:	e03ff0ef          	jal	5fe <printint>
        i += 1;
 800:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 802:	8ba6                	mv	s7,s1
      state = 0;
 804:	4981                	li	s3,0
 806:	bde9                	j	6e0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 808:	008b8493          	addi	s1,s7,8
 80c:	4681                	li	a3,0
 80e:	4641                	li	a2,16
 810:	000bb583          	ld	a1,0(s7)
 814:	855a                	mv	a0,s6
 816:	de9ff0ef          	jal	5fe <printint>
        i += 2;
 81a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 81c:	8ba6                	mv	s7,s1
      state = 0;
 81e:	4981                	li	s3,0
        i += 2;
 820:	b5c1                	j	6e0 <vprintf+0x44>
 822:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 824:	008b8793          	addi	a5,s7,8
 828:	8cbe                	mv	s9,a5
 82a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 82e:	03000593          	li	a1,48
 832:	855a                	mv	a0,s6
 834:	dadff0ef          	jal	5e0 <putc>
  putc(fd, 'x');
 838:	07800593          	li	a1,120
 83c:	855a                	mv	a0,s6
 83e:	da3ff0ef          	jal	5e0 <putc>
 842:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 844:	00000b97          	auipc	s7,0x0
 848:	684b8b93          	addi	s7,s7,1668 # ec8 <digits>
 84c:	03c9d793          	srli	a5,s3,0x3c
 850:	97de                	add	a5,a5,s7
 852:	0007c583          	lbu	a1,0(a5)
 856:	855a                	mv	a0,s6
 858:	d89ff0ef          	jal	5e0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 85c:	0992                	slli	s3,s3,0x4
 85e:	34fd                	addiw	s1,s1,-1
 860:	f4f5                	bnez	s1,84c <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 862:	8be6                	mv	s7,s9
      state = 0;
 864:	4981                	li	s3,0
 866:	6ca2                	ld	s9,8(sp)
 868:	bda5                	j	6e0 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 86a:	008b8493          	addi	s1,s7,8
 86e:	000bc583          	lbu	a1,0(s7)
 872:	855a                	mv	a0,s6
 874:	d6dff0ef          	jal	5e0 <putc>
 878:	8ba6                	mv	s7,s1
      state = 0;
 87a:	4981                	li	s3,0
 87c:	b595                	j	6e0 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 87e:	008b8993          	addi	s3,s7,8
 882:	000bb483          	ld	s1,0(s7)
 886:	cc91                	beqz	s1,8a2 <vprintf+0x206>
        for (; *s; s++)
 888:	0004c583          	lbu	a1,0(s1)
 88c:	c985                	beqz	a1,8bc <vprintf+0x220>
          putc(fd, *s);
 88e:	855a                	mv	a0,s6
 890:	d51ff0ef          	jal	5e0 <putc>
        for (; *s; s++)
 894:	0485                	addi	s1,s1,1
 896:	0004c583          	lbu	a1,0(s1)
 89a:	f9f5                	bnez	a1,88e <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 89c:	8bce                	mv	s7,s3
      state = 0;
 89e:	4981                	li	s3,0
 8a0:	b581                	j	6e0 <vprintf+0x44>
          s = "(null)";
 8a2:	00000497          	auipc	s1,0x0
 8a6:	61e48493          	addi	s1,s1,1566 # ec0 <malloc+0x482>
        for (; *s; s++)
 8aa:	02800593          	li	a1,40
 8ae:	b7c5                	j	88e <vprintf+0x1f2>
        putc(fd, '%');
 8b0:	85be                	mv	a1,a5
 8b2:	855a                	mv	a0,s6
 8b4:	d2dff0ef          	jal	5e0 <putc>
      state = 0;
 8b8:	4981                	li	s3,0
 8ba:	b51d                	j	6e0 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 8bc:	8bce                	mv	s7,s3
      state = 0;
 8be:	4981                	li	s3,0
 8c0:	b505                	j	6e0 <vprintf+0x44>
 8c2:	6906                	ld	s2,64(sp)
 8c4:	79e2                	ld	s3,56(sp)
 8c6:	7a42                	ld	s4,48(sp)
 8c8:	7aa2                	ld	s5,40(sp)
 8ca:	7b02                	ld	s6,32(sp)
 8cc:	6be2                	ld	s7,24(sp)
 8ce:	6c42                	ld	s8,16(sp)
    }
  }
}
 8d0:	60e6                	ld	ra,88(sp)
 8d2:	6446                	ld	s0,80(sp)
 8d4:	64a6                	ld	s1,72(sp)
 8d6:	6125                	addi	sp,sp,96
 8d8:	8082                	ret
      if (c0 == 'd') {
 8da:	06400713          	li	a4,100
 8de:	e4e78fe3          	beq	a5,a4,73c <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 8e2:	f9478693          	addi	a3,a5,-108
 8e6:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 8ea:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 8ec:	4701                	li	a4,0
      } else if (c0 == 'u') {
 8ee:	07500513          	li	a0,117
 8f2:	e8a78ce3          	beq	a5,a0,78a <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 8f6:	f8b60513          	addi	a0,a2,-117
 8fa:	e119                	bnez	a0,900 <vprintf+0x264>
 8fc:	ea0693e3          	bnez	a3,7a2 <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 900:	f8b58513          	addi	a0,a1,-117
 904:	e119                	bnez	a0,90a <vprintf+0x26e>
 906:	ea071be3          	bnez	a4,7bc <vprintf+0x120>
      } else if (c0 == 'x') {
 90a:	07800513          	li	a0,120
 90e:	eca784e3          	beq	a5,a0,7d6 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 912:	f8860613          	addi	a2,a2,-120
 916:	e219                	bnez	a2,91c <vprintf+0x280>
 918:	ec069be3          	bnez	a3,7ee <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 91c:	f8858593          	addi	a1,a1,-120
 920:	e199                	bnez	a1,926 <vprintf+0x28a>
 922:	ee0713e3          	bnez	a4,808 <vprintf+0x16c>
      } else if (c0 == 'p') {
 926:	07000713          	li	a4,112
 92a:	eee78ce3          	beq	a5,a4,822 <vprintf+0x186>
      } else if (c0 == 'c') {
 92e:	06300713          	li	a4,99
 932:	f2e78ce3          	beq	a5,a4,86a <vprintf+0x1ce>
      } else if (c0 == 's') {
 936:	07300713          	li	a4,115
 93a:	f4e782e3          	beq	a5,a4,87e <vprintf+0x1e2>
      } else if (c0 == '%') {
 93e:	02500713          	li	a4,37
 942:	f6e787e3          	beq	a5,a4,8b0 <vprintf+0x214>
        putc(fd, '%');
 946:	02500593          	li	a1,37
 94a:	855a                	mv	a0,s6
 94c:	c95ff0ef          	jal	5e0 <putc>
        putc(fd, c0);
 950:	85a6                	mv	a1,s1
 952:	855a                	mv	a0,s6
 954:	c8dff0ef          	jal	5e0 <putc>
      state = 0;
 958:	4981                	li	s3,0
 95a:	b359                	j	6e0 <vprintf+0x44>

000000000000095c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 95c:	715d                	addi	sp,sp,-80
 95e:	ec06                	sd	ra,24(sp)
 960:	e822                	sd	s0,16(sp)
 962:	1000                	addi	s0,sp,32
 964:	e010                	sd	a2,0(s0)
 966:	e414                	sd	a3,8(s0)
 968:	e818                	sd	a4,16(s0)
 96a:	ec1c                	sd	a5,24(s0)
 96c:	03043023          	sd	a6,32(s0)
 970:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 974:	8622                	mv	a2,s0
 976:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 97a:	d23ff0ef          	jal	69c <vprintf>
}
 97e:	60e2                	ld	ra,24(sp)
 980:	6442                	ld	s0,16(sp)
 982:	6161                	addi	sp,sp,80
 984:	8082                	ret

0000000000000986 <printf>:

void
printf(const char *fmt, ...)
{
 986:	711d                	addi	sp,sp,-96
 988:	ec06                	sd	ra,24(sp)
 98a:	e822                	sd	s0,16(sp)
 98c:	1000                	addi	s0,sp,32
 98e:	e40c                	sd	a1,8(s0)
 990:	e810                	sd	a2,16(s0)
 992:	ec14                	sd	a3,24(s0)
 994:	f018                	sd	a4,32(s0)
 996:	f41c                	sd	a5,40(s0)
 998:	03043823          	sd	a6,48(s0)
 99c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 9a0:	00840613          	addi	a2,s0,8
 9a4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 9a8:	85aa                	mv	a1,a0
 9aa:	4505                	li	a0,1
 9ac:	cf1ff0ef          	jal	69c <vprintf>
}
 9b0:	60e2                	ld	ra,24(sp)
 9b2:	6442                	ld	s0,16(sp)
 9b4:	6125                	addi	sp,sp,96
 9b6:	8082                	ret

00000000000009b8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9b8:	1141                	addi	sp,sp,-16
 9ba:	e406                	sd	ra,8(sp)
 9bc:	e022                	sd	s0,0(sp)
 9be:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 9c0:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9c4:	00001797          	auipc	a5,0x1
 9c8:	6447b783          	ld	a5,1604(a5) # 2008 <freep>
 9cc:	a039                	j	9da <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9ce:	6398                	ld	a4,0(a5)
 9d0:	00e7e463          	bltu	a5,a4,9d8 <free+0x20>
 9d4:	00e6ea63          	bltu	a3,a4,9e8 <free+0x30>
{
 9d8:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9da:	fed7fae3          	bgeu	a5,a3,9ce <free+0x16>
 9de:	6398                	ld	a4,0(a5)
 9e0:	00e6e463          	bltu	a3,a4,9e8 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9e4:	fee7eae3          	bltu	a5,a4,9d8 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 9e8:	ff852583          	lw	a1,-8(a0)
 9ec:	6390                	ld	a2,0(a5)
 9ee:	02059813          	slli	a6,a1,0x20
 9f2:	01c85713          	srli	a4,a6,0x1c
 9f6:	9736                	add	a4,a4,a3
 9f8:	02e60563          	beq	a2,a4,a22 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 9fc:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 a00:	4790                	lw	a2,8(a5)
 a02:	02061593          	slli	a1,a2,0x20
 a06:	01c5d713          	srli	a4,a1,0x1c
 a0a:	973e                	add	a4,a4,a5
 a0c:	02e68263          	beq	a3,a4,a30 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 a10:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a12:	00001717          	auipc	a4,0x1
 a16:	5ef73b23          	sd	a5,1526(a4) # 2008 <freep>
}
 a1a:	60a2                	ld	ra,8(sp)
 a1c:	6402                	ld	s0,0(sp)
 a1e:	0141                	addi	sp,sp,16
 a20:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 a22:	4618                	lw	a4,8(a2)
 a24:	9f2d                	addw	a4,a4,a1
 a26:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a2a:	6398                	ld	a4,0(a5)
 a2c:	6310                	ld	a2,0(a4)
 a2e:	b7f9                	j	9fc <free+0x44>
    p->s.size += bp->s.size;
 a30:	ff852703          	lw	a4,-8(a0)
 a34:	9f31                	addw	a4,a4,a2
 a36:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a38:	ff053683          	ld	a3,-16(a0)
 a3c:	bfd1                	j	a10 <free+0x58>

0000000000000a3e <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 a3e:	7139                	addi	sp,sp,-64
 a40:	fc06                	sd	ra,56(sp)
 a42:	f822                	sd	s0,48(sp)
 a44:	f04a                	sd	s2,32(sp)
 a46:	ec4e                	sd	s3,24(sp)
 a48:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 a4a:	02051993          	slli	s3,a0,0x20
 a4e:	0209d993          	srli	s3,s3,0x20
 a52:	09bd                	addi	s3,s3,15
 a54:	0049d993          	srli	s3,s3,0x4
 a58:	2985                	addiw	s3,s3,1
 a5a:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 a5c:	00001517          	auipc	a0,0x1
 a60:	5ac53503          	ld	a0,1452(a0) # 2008 <freep>
 a64:	c905                	beqz	a0,a94 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 a66:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 a68:	4798                	lw	a4,8(a5)
 a6a:	09377663          	bgeu	a4,s3,af6 <malloc+0xb8>
 a6e:	f426                	sd	s1,40(sp)
 a70:	e852                	sd	s4,16(sp)
 a72:	e456                	sd	s5,8(sp)
 a74:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 a76:	8a4e                	mv	s4,s3
 a78:	6705                	lui	a4,0x1
 a7a:	00e9f363          	bgeu	s3,a4,a80 <malloc+0x42>
 a7e:	6a05                	lui	s4,0x1
 a80:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a84:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 a88:	00001497          	auipc	s1,0x1
 a8c:	58048493          	addi	s1,s1,1408 # 2008 <freep>
  if (p == SBRK_ERROR)
 a90:	5afd                	li	s5,-1
 a92:	a83d                	j	ad0 <malloc+0x92>
 a94:	f426                	sd	s1,40(sp)
 a96:	e852                	sd	s4,16(sp)
 a98:	e456                	sd	s5,8(sp)
 a9a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a9c:	00001797          	auipc	a5,0x1
 aa0:	57478793          	addi	a5,a5,1396 # 2010 <base>
 aa4:	00001717          	auipc	a4,0x1
 aa8:	56f73223          	sd	a5,1380(a4) # 2008 <freep>
 aac:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 aae:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 ab2:	b7d1                	j	a76 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 ab4:	6398                	ld	a4,0(a5)
 ab6:	e118                	sd	a4,0(a0)
 ab8:	a899                	j	b0e <malloc+0xd0>
  hp->s.size = nu;
 aba:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 abe:	0541                	addi	a0,a0,16
 ac0:	ef9ff0ef          	jal	9b8 <free>
  return freep;
 ac4:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 ac6:	c125                	beqz	a0,b26 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 ac8:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 aca:	4798                	lw	a4,8(a5)
 acc:	03277163          	bgeu	a4,s2,aee <malloc+0xb0>
    if (p == freep)
 ad0:	6098                	ld	a4,0(s1)
 ad2:	853e                	mv	a0,a5
 ad4:	fef71ae3          	bne	a4,a5,ac8 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 ad8:	8552                	mv	a0,s4
 ada:	a1bff0ef          	jal	4f4 <sbrk>
  if (p == SBRK_ERROR)
 ade:	fd551ee3          	bne	a0,s5,aba <malloc+0x7c>
        return 0;
 ae2:	4501                	li	a0,0
 ae4:	74a2                	ld	s1,40(sp)
 ae6:	6a42                	ld	s4,16(sp)
 ae8:	6aa2                	ld	s5,8(sp)
 aea:	6b02                	ld	s6,0(sp)
 aec:	a03d                	j	b1a <malloc+0xdc>
 aee:	74a2                	ld	s1,40(sp)
 af0:	6a42                	ld	s4,16(sp)
 af2:	6aa2                	ld	s5,8(sp)
 af4:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 af6:	fae90fe3          	beq	s2,a4,ab4 <malloc+0x76>
        p->s.size -= nunits;
 afa:	4137073b          	subw	a4,a4,s3
 afe:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b00:	02071693          	slli	a3,a4,0x20
 b04:	01c6d713          	srli	a4,a3,0x1c
 b08:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b0a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b0e:	00001717          	auipc	a4,0x1
 b12:	4ea73d23          	sd	a0,1274(a4) # 2008 <freep>
      return (void *)(p + 1);
 b16:	01078513          	addi	a0,a5,16
  }
}
 b1a:	70e2                	ld	ra,56(sp)
 b1c:	7442                	ld	s0,48(sp)
 b1e:	7902                	ld	s2,32(sp)
 b20:	69e2                	ld	s3,24(sp)
 b22:	6121                	addi	sp,sp,64
 b24:	8082                	ret
 b26:	74a2                	ld	s1,40(sp)
 b28:	6a42                	ld	s4,16(sp)
 b2a:	6aa2                	ld	s5,8(sp)
 b2c:	6b02                	ld	s6,0(sp)
 b2e:	b7f5                	j	b1a <malloc+0xdc>
