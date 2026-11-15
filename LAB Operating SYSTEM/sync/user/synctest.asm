
user/_synctest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <sync_thread_worker>:
#define SEM_COUNTER 0

volatile int counter = 0;
volatile int start_flag = 0;

void sync_thread_worker(void *arg) {
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	0080                	addi	s0,sp,64
  int id = (int)(uint64)arg;
  10:	0005079b          	sext.w	a5,a0
  14:	8a3e                	mv	s4,a5

  while (start_flag == 0)
  16:	00002717          	auipc	a4,0x2
  1a:	ffa70713          	addi	a4,a4,-6 # 2010 <start_flag>
  1e:	431c                	lw	a5,0(a4)
  20:	2781                	sext.w	a5,a5
  22:	dff5                	beqz	a5,1e <sync_thread_worker+0x1e>
  24:	6961                	lui	s2,0x18
  26:	6a090913          	addi	s2,s2,1696 # 186a0 <base+0x16668>
    ;

  for (int i = 0; i < INCREMENTS_PER_THREAD; i++) {
    // Synchronized Critical Section using Semaphore
    sem_wait(SEM_COUNTER);
    volatile int val = counter;
  2a:	00002997          	auipc	s3,0x2
  2e:	fea98993          	addi	s3,s3,-22 # 2014 <counter>
    for (volatile int d = 0; d < 3; d++);
  32:	4489                	li	s1,2
  34:	a821                	j	4c <sync_thread_worker+0x4c>
    counter = val + 1;
  36:	fc842783          	lw	a5,-56(s0)
  3a:	2785                	addiw	a5,a5,1
  3c:	00f9a023          	sw	a5,0(s3)
    sem_signal(SEM_COUNTER);
  40:	4501                	li	a0,0
  42:	0a3000ef          	jal	8e4 <sem_signal>
  for (int i = 0; i < INCREMENTS_PER_THREAD; i++) {
  46:	397d                	addiw	s2,s2,-1
  48:	02090c63          	beqz	s2,80 <sync_thread_worker+0x80>
    sem_wait(SEM_COUNTER);
  4c:	4501                	li	a0,0
  4e:	08f000ef          	jal	8dc <sem_wait>
    volatile int val = counter;
  52:	0009a783          	lw	a5,0(s3)
  56:	2781                	sext.w	a5,a5
  58:	fcf42423          	sw	a5,-56(s0)
    for (volatile int d = 0; d < 3; d++);
  5c:	fc042623          	sw	zero,-52(s0)
  60:	fcc42783          	lw	a5,-52(s0)
  64:	2781                	sext.w	a5,a5
  66:	fcf4c8e3          	blt	s1,a5,36 <sync_thread_worker+0x36>
  6a:	fcc42783          	lw	a5,-52(s0)
  6e:	2785                	addiw	a5,a5,1
  70:	fcf42623          	sw	a5,-52(s0)
  74:	fcc42783          	lw	a5,-52(s0)
  78:	2781                	sext.w	a5,a5
  7a:	fef4d8e3          	bge	s1,a5,6a <sync_thread_worker+0x6a>
  7e:	bf65                	j	36 <sync_thread_worker+0x36>
  }

  printf("Thread %d (pid %d) finished %d synchronized increments.\n",
  80:	01d000ef          	jal	89c <getpid>
  84:	862a                	mv	a2,a0
  86:	66e1                	lui	a3,0x18
  88:	6a068693          	addi	a3,a3,1696 # 186a0 <base+0x16668>
  8c:	85d2                	mv	a1,s4
  8e:	00001517          	auipc	a0,0x1
  92:	db250513          	addi	a0,a0,-590 # e40 <malloc+0xf6>
  96:	3fd000ef          	jal	c92 <printf>
         id, getpid(), INCREMENTS_PER_THREAD);
  exit(0);
  9a:	4501                	li	a0,0
  9c:	780000ef          	jal	81c <exit>

00000000000000a0 <producer_thread>:
int pc_in = 0;
int pc_out = 0;
int pc_count = 0;
int pc_max_seen = 0;

void producer_thread(void *arg) {
  a0:	715d                	addi	sp,sp,-80
  a2:	e486                	sd	ra,72(sp)
  a4:	e0a2                	sd	s0,64(sp)
  a6:	fc26                	sd	s1,56(sp)
  a8:	f84a                	sd	s2,48(sp)
  aa:	f44e                	sd	s3,40(sp)
  ac:	f052                	sd	s4,32(sp)
  ae:	ec56                	sd	s5,24(sp)
  b0:	e85a                	sd	s6,16(sp)
  b2:	e45e                	sd	s7,8(sp)
  b4:	e062                	sd	s8,0(sp)
  b6:	0880                	addi	s0,sp,80
  for (int item = 1; item <= TOTAL_ITEMS; item++) {
  b8:	4485                	li	s1,1
    sem_wait(SEM_PC_EMPTY);
  ba:	4c09                	li	s8,2
    sem_wait(SEM_PC_MUTEX);
  bc:	89a6                	mv	s3,s1

    pc_buffer[pc_in] = item;
  be:	00002a17          	auipc	s4,0x2
  c2:	f4ea0a13          	addi	s4,s4,-178 # 200c <pc_in>
  c6:	00002b97          	auipc	s7,0x2
  ca:	f5ab8b93          	addi	s7,s7,-166 # 2020 <pc_buffer>
    pc_in = (pc_in + 1) % BUFFER_SIZE;
  ce:	66666b37          	lui	s6,0x66666
  d2:	667b0b13          	addi	s6,s6,1639 # 66666667 <base+0x6666462f>
    pc_count++;
  d6:	00002917          	auipc	s2,0x2
  da:	f2e90913          	addi	s2,s2,-210 # 2004 <pc_count>
    if (pc_count > pc_max_seen)
  de:	00002a97          	auipc	s5,0x2
  e2:	f22a8a93          	addi	s5,s5,-222 # 2000 <pc_max_seen>
  e6:	a81d                	j	11c <producer_thread+0x7c>
      pc_max_seen = pc_count;

    printf("[Producer (pid %d)]: Produced %d | Buffer count: %d/%d\n",
  e8:	7b4000ef          	jal	89c <getpid>
  ec:	85aa                	mv	a1,a0
  ee:	4715                	li	a4,5
  f0:	00092683          	lw	a3,0(s2)
  f4:	8626                	mv	a2,s1
  f6:	00001517          	auipc	a0,0x1
  fa:	d8a50513          	addi	a0,a0,-630 # e80 <malloc+0x136>
  fe:	395000ef          	jal	c92 <printf>
           getpid(), item, pc_count, BUFFER_SIZE);

    sem_signal(SEM_PC_MUTEX);
 102:	854e                	mv	a0,s3
 104:	7e0000ef          	jal	8e4 <sem_signal>
    sem_signal(SEM_PC_FULL);
 108:	450d                	li	a0,3
 10a:	7da000ef          	jal	8e4 <sem_signal>

    pause(1);
 10e:	854e                	mv	a0,s3
 110:	79c000ef          	jal	8ac <pause>
  for (int item = 1; item <= TOTAL_ITEMS; item++) {
 114:	2485                	addiw	s1,s1,1
 116:	47c1                	li	a5,16
 118:	04f48763          	beq	s1,a5,166 <producer_thread+0xc6>
    sem_wait(SEM_PC_EMPTY);
 11c:	8562                	mv	a0,s8
 11e:	7be000ef          	jal	8dc <sem_wait>
    sem_wait(SEM_PC_MUTEX);
 122:	854e                	mv	a0,s3
 124:	7b8000ef          	jal	8dc <sem_wait>
    pc_buffer[pc_in] = item;
 128:	000a2783          	lw	a5,0(s4)
 12c:	00279713          	slli	a4,a5,0x2
 130:	975e                	add	a4,a4,s7
 132:	c304                	sw	s1,0(a4)
    pc_in = (pc_in + 1) % BUFFER_SIZE;
 134:	2785                	addiw	a5,a5,1
 136:	03678733          	mul	a4,a5,s6
 13a:	9705                	srai	a4,a4,0x21
 13c:	41f7d69b          	sraiw	a3,a5,0x1f
 140:	9f15                	subw	a4,a4,a3
 142:	0027169b          	slliw	a3,a4,0x2
 146:	9f35                	addw	a4,a4,a3
 148:	9f99                	subw	a5,a5,a4
 14a:	00fa2023          	sw	a5,0(s4)
    pc_count++;
 14e:	00092783          	lw	a5,0(s2)
 152:	2785                	addiw	a5,a5,1
 154:	00f92023          	sw	a5,0(s2)
    if (pc_count > pc_max_seen)
 158:	000aa703          	lw	a4,0(s5)
 15c:	f8f756e3          	bge	a4,a5,e8 <producer_thread+0x48>
      pc_max_seen = pc_count;
 160:	00faa023          	sw	a5,0(s5)
 164:	b751                	j	e8 <producer_thread+0x48>
  }
  exit(0);
 166:	4501                	li	a0,0
 168:	6b4000ef          	jal	81c <exit>

000000000000016c <consumer_thread>:
}

void consumer_thread(void *arg) {
 16c:	7159                	addi	sp,sp,-112
 16e:	f486                	sd	ra,104(sp)
 170:	f0a2                	sd	s0,96(sp)
 172:	eca6                	sd	s1,88(sp)
 174:	e8ca                	sd	s2,80(sp)
 176:	e4ce                	sd	s3,72(sp)
 178:	e0d2                	sd	s4,64(sp)
 17a:	fc56                	sd	s5,56(sp)
 17c:	f85a                	sd	s6,48(sp)
 17e:	f45e                	sd	s7,40(sp)
 180:	f062                	sd	s8,32(sp)
 182:	ec66                	sd	s9,24(sp)
 184:	e86a                	sd	s10,16(sp)
 186:	e46e                	sd	s11,8(sp)
 188:	1880                	addi	s0,sp,112
 18a:	4a3d                	li	s4,15
  int last_item = 0;
  int order_errors = 0;
 18c:	4c81                	li	s9,0
  int last_item = 0;
 18e:	4481                	li	s1,0

  for (int i = 0; i < TOTAL_ITEMS; i++) {
    sem_wait(SEM_PC_FULL);
 190:	4d8d                	li	s11,3
    sem_wait(SEM_PC_MUTEX);
 192:	4b85                	li	s7,1

    int item = pc_buffer[pc_out];
 194:	00002b17          	auipc	s6,0x2
 198:	e74b0b13          	addi	s6,s6,-396 # 2008 <pc_out>
 19c:	00002d17          	auipc	s10,0x2
 1a0:	e84d0d13          	addi	s10,s10,-380 # 2020 <pc_buffer>
    pc_out = (pc_out + 1) % BUFFER_SIZE;
 1a4:	66666c37          	lui	s8,0x66666
 1a8:	667c0c13          	addi	s8,s8,1639 # 66666667 <base+0x6666462f>
    pc_count--;
 1ac:	00002997          	auipc	s3,0x2
 1b0:	e5898993          	addi	s3,s3,-424 # 2004 <pc_count>
      order_errors++;
    }
    last_item = item;

    sem_signal(SEM_PC_MUTEX);
    sem_signal(SEM_PC_EMPTY);
 1b4:	4a89                	li	s5,2
 1b6:	a829                	j	1d0 <consumer_thread+0x64>
    sem_signal(SEM_PC_MUTEX);
 1b8:	855e                	mv	a0,s7
 1ba:	72a000ef          	jal	8e4 <sem_signal>
    sem_signal(SEM_PC_EMPTY);
 1be:	8556                	mv	a0,s5
 1c0:	724000ef          	jal	8e4 <sem_signal>

    pause(2); // let producer fill buffer
 1c4:	8556                	mv	a0,s5
 1c6:	6e6000ef          	jal	8ac <pause>
  for (int i = 0; i < TOTAL_ITEMS; i++) {
 1ca:	3a7d                	addiw	s4,s4,-1
 1cc:	060a0b63          	beqz	s4,242 <consumer_thread+0xd6>
    sem_wait(SEM_PC_FULL);
 1d0:	856e                	mv	a0,s11
 1d2:	70a000ef          	jal	8dc <sem_wait>
    sem_wait(SEM_PC_MUTEX);
 1d6:	855e                	mv	a0,s7
 1d8:	704000ef          	jal	8dc <sem_wait>
    int item = pc_buffer[pc_out];
 1dc:	000b2783          	lw	a5,0(s6)
 1e0:	8926                	mv	s2,s1
 1e2:	00279713          	slli	a4,a5,0x2
 1e6:	976a                	add	a4,a4,s10
 1e8:	4304                	lw	s1,0(a4)
    pc_out = (pc_out + 1) % BUFFER_SIZE;
 1ea:	2785                	addiw	a5,a5,1
 1ec:	03878733          	mul	a4,a5,s8
 1f0:	9705                	srai	a4,a4,0x21
 1f2:	41f7d69b          	sraiw	a3,a5,0x1f
 1f6:	9f15                	subw	a4,a4,a3
 1f8:	0027169b          	slliw	a3,a4,0x2
 1fc:	9f35                	addw	a4,a4,a3
 1fe:	9f99                	subw	a5,a5,a4
 200:	00fb2023          	sw	a5,0(s6)
    pc_count--;
 204:	0009a783          	lw	a5,0(s3)
 208:	37fd                	addiw	a5,a5,-1
 20a:	00f9a023          	sw	a5,0(s3)
    printf("[Consumer (pid %d)]: Consumed %d | Buffer count: %d/%d\n",
 20e:	68e000ef          	jal	89c <getpid>
 212:	85aa                	mv	a1,a0
 214:	4715                	li	a4,5
 216:	0009a683          	lw	a3,0(s3)
 21a:	8626                	mv	a2,s1
 21c:	00001517          	auipc	a0,0x1
 220:	c9c50513          	addi	a0,a0,-868 # eb8 <malloc+0x16e>
 224:	26f000ef          	jal	c92 <printf>
    if (item != last_item + 1) {
 228:	0019059b          	addiw	a1,s2,1
 22c:	f89586e3          	beq	a1,s1,1b8 <consumer_thread+0x4c>
      printf("ERROR: Expected %d, got %d\n", last_item + 1, item);
 230:	8626                	mv	a2,s1
 232:	00001517          	auipc	a0,0x1
 236:	cbe50513          	addi	a0,a0,-834 # ef0 <malloc+0x1a6>
 23a:	259000ef          	jal	c92 <printf>
      order_errors++;
 23e:	2c85                	addiw	s9,s9,1
 240:	bfa5                	j	1b8 <consumer_thread+0x4c>
  }

  if (order_errors == 0 && last_item == TOTAL_ITEMS) {
 242:	000c9463          	bnez	s9,24a <consumer_thread+0xde>
 246:	14c5                	addi	s1,s1,-15
 248:	c481                	beqz	s1,250 <consumer_thread+0xe4>
    printf("Consumer: All %d items verified in strict FIFO order!\n", TOTAL_ITEMS);
  }
  exit(0);
 24a:	4501                	li	a0,0
 24c:	5d0000ef          	jal	81c <exit>
    printf("Consumer: All %d items verified in strict FIFO order!\n", TOTAL_ITEMS);
 250:	45bd                	li	a1,15
 252:	00001517          	auipc	a0,0x1
 256:	cbe50513          	addi	a0,a0,-834 # f10 <malloc+0x1c6>
 25a:	239000ef          	jal	c92 <printf>
 25e:	b7f5                	j	24a <consumer_thread+0xde>

0000000000000260 <test_part1_synchronized_counter>:
void test_part1_synchronized_counter(void) {
 260:	7159                	addi	sp,sp,-112
 262:	f486                	sd	ra,104(sp)
 264:	f0a2                	sd	s0,96(sp)
 266:	eca6                	sd	s1,88(sp)
 268:	e8ca                	sd	s2,80(sp)
 26a:	e4ce                	sd	s3,72(sp)
 26c:	e0d2                	sd	s4,64(sp)
 26e:	fc56                	sd	s5,56(sp)
 270:	f85a                	sd	s6,48(sp)
 272:	f45e                	sd	s7,40(sp)
 274:	1880                	addi	s0,sp,112
  printf("============================================================\n");
 276:	00001517          	auipc	a0,0x1
 27a:	cd250513          	addi	a0,a0,-814 # f48 <malloc+0x1fe>
 27e:	215000ef          	jal	c92 <printf>
  printf(" PART 1: Synchronized Threads Counter Test using Semaphores \n");
 282:	00001517          	auipc	a0,0x1
 286:	d0650513          	addi	a0,a0,-762 # f88 <malloc+0x23e>
 28a:	209000ef          	jal	c92 <printf>
  printf(" Threads: %d, Increments: %d each, Expected: %d            \n",
 28e:	000496b7          	lui	a3,0x49
 292:	3e068693          	addi	a3,a3,992 # 493e0 <base+0x473a8>
 296:	6661                	lui	a2,0x18
 298:	6a060613          	addi	a2,a2,1696 # 186a0 <base+0x16668>
 29c:	458d                	li	a1,3
 29e:	00001517          	auipc	a0,0x1
 2a2:	d2a50513          	addi	a0,a0,-726 # fc8 <malloc+0x27e>
 2a6:	1ed000ef          	jal	c92 <printf>
  printf("============================================================\n");
 2aa:	00001517          	auipc	a0,0x1
 2ae:	c9e50513          	addi	a0,a0,-866 # f48 <malloc+0x1fe>
 2b2:	1e1000ef          	jal	c92 <printf>
  sem_init(SEM_COUNTER, 1);
 2b6:	4585                	li	a1,1
 2b8:	4501                	li	a0,0
 2ba:	61a000ef          	jal	8d4 <sem_init>
  counter = 0;
 2be:	00002797          	auipc	a5,0x2
 2c2:	d407ab23          	sw	zero,-682(a5) # 2014 <counter>
  start_flag = 0;
 2c6:	00002797          	auipc	a5,0x2
 2ca:	d407a523          	sw	zero,-694(a5) # 2010 <start_flag>
  for (int i = 0; i < NUM_THREADS; i++) {
 2ce:	f9840913          	addi	s2,s0,-104
  start_flag = 0;
 2d2:	89ca                	mv	s3,s2
 2d4:	4485                	li	s1,1
    stacks[i] = malloc(PGSIZE);
 2d6:	6b85                	lui	s7,0x1
    tids[i] = clone(sync_thread_worker, (void *)(uint64)(i + 1), stacks[i]);
 2d8:	00000b17          	auipc	s6,0x0
 2dc:	d28b0b13          	addi	s6,s6,-728 # 0 <sync_thread_worker>
    printf("Main: Cloned Thread %d (pid %d)\n", i + 1, tids[i]);
 2e0:	00001a97          	auipc	s5,0x1
 2e4:	d28a8a93          	addi	s5,s5,-728 # 1008 <malloc+0x2be>
  for (int i = 0; i < NUM_THREADS; i++) {
 2e8:	4a11                	li	s4,4
    stacks[i] = malloc(PGSIZE);
 2ea:	855e                	mv	a0,s7
 2ec:	25f000ef          	jal	d4a <malloc>
 2f0:	862a                	mv	a2,a0
 2f2:	00a9b023          	sd	a0,0(s3)
    tids[i] = clone(sync_thread_worker, (void *)(uint64)(i + 1), stacks[i]);
 2f6:	85a6                	mv	a1,s1
 2f8:	855a                	mv	a0,s6
 2fa:	5ca000ef          	jal	8c4 <clone>
 2fe:	862a                	mv	a2,a0
    printf("Main: Cloned Thread %d (pid %d)\n", i + 1, tids[i]);
 300:	0004859b          	sext.w	a1,s1
 304:	8556                	mv	a0,s5
 306:	18d000ef          	jal	c92 <printf>
  for (int i = 0; i < NUM_THREADS; i++) {
 30a:	0485                	addi	s1,s1,1
 30c:	09a1                	addi	s3,s3,8
 30e:	fd449ee3          	bne	s1,s4,2ea <test_part1_synchronized_counter+0x8a>
  printf("Main: Releasing all 3 threads concurrently...\n");
 312:	00001517          	auipc	a0,0x1
 316:	d1e50513          	addi	a0,a0,-738 # 1030 <malloc+0x2e6>
 31a:	179000ef          	jal	c92 <printf>
  start_flag = 1;
 31e:	4785                	li	a5,1
 320:	00002717          	auipc	a4,0x2
 324:	cef72823          	sw	a5,-784(a4) # 2010 <start_flag>
  for (int i = 0; i < NUM_THREADS; i++) {
 328:	01890993          	addi	s3,s2,24
    printf("Main: Reaped thread with pid %d via join()\n", pid);
 32c:	00001497          	auipc	s1,0x1
 330:	d3448493          	addi	s1,s1,-716 # 1060 <malloc+0x316>
    int pid = join();
 334:	598000ef          	jal	8cc <join>
 338:	85aa                	mv	a1,a0
    printf("Main: Reaped thread with pid %d via join()\n", pid);
 33a:	8526                	mv	a0,s1
 33c:	157000ef          	jal	c92 <printf>
    free(stacks[i]);
 340:	00093503          	ld	a0,0(s2)
 344:	181000ef          	jal	cc4 <free>
  for (int i = 0; i < NUM_THREADS; i++) {
 348:	0921                	addi	s2,s2,8
 34a:	ff3915e3          	bne	s2,s3,334 <test_part1_synchronized_counter+0xd4>
  int actual = counter;
 34e:	00002497          	auipc	s1,0x2
 352:	cc64a483          	lw	s1,-826(s1) # 2014 <counter>
  printf("------------------------------------------------------------\n");
 356:	00001517          	auipc	a0,0x1
 35a:	d3a50513          	addi	a0,a0,-710 # 1090 <malloc+0x346>
 35e:	135000ef          	jal	c92 <printf>
  printf("Part 1 Results: Expected = %d, Actual = %d\n", expected, actual);
 362:	8626                	mv	a2,s1
 364:	000495b7          	lui	a1,0x49
 368:	3e058593          	addi	a1,a1,992 # 493e0 <base+0x473a8>
 36c:	00001517          	auipc	a0,0x1
 370:	d6450513          	addi	a0,a0,-668 # 10d0 <malloc+0x386>
 374:	11f000ef          	jal	c92 <printf>
  if (actual == expected) {
 378:	000497b7          	lui	a5,0x49
 37c:	3e078793          	addi	a5,a5,992 # 493e0 <base+0x473a8>
 380:	02f48863          	beq	s1,a5,3b0 <test_part1_synchronized_counter+0x150>
    printf("FAILURE: Race condition still present (lost = %d)\n", expected - actual);
 384:	000495b7          	lui	a1,0x49
 388:	3e05859b          	addiw	a1,a1,992 # 493e0 <base+0x473a8>
 38c:	9d85                	subw	a1,a1,s1
 38e:	00001517          	auipc	a0,0x1
 392:	dea50513          	addi	a0,a0,-534 # 1178 <malloc+0x42e>
 396:	0fd000ef          	jal	c92 <printf>
}
 39a:	70a6                	ld	ra,104(sp)
 39c:	7406                	ld	s0,96(sp)
 39e:	64e6                	ld	s1,88(sp)
 3a0:	6946                	ld	s2,80(sp)
 3a2:	69a6                	ld	s3,72(sp)
 3a4:	6a06                	ld	s4,64(sp)
 3a6:	7ae2                	ld	s5,56(sp)
 3a8:	7b42                	ld	s6,48(sp)
 3aa:	7ba2                	ld	s7,40(sp)
 3ac:	6165                	addi	sp,sp,112
 3ae:	8082                	ret
    printf("SUCCESS: Counter reached EXACTLY %d with 0 lost updates!\n", actual);
 3b0:	85a6                	mv	a1,s1
 3b2:	00001517          	auipc	a0,0x1
 3b6:	d4e50513          	addi	a0,a0,-690 # 1100 <malloc+0x3b6>
 3ba:	0d9000ef          	jal	c92 <printf>
    printf("Semaphores successfully eliminated the race condition.\n");
 3be:	00001517          	auipc	a0,0x1
 3c2:	d8250513          	addi	a0,a0,-638 # 1140 <malloc+0x3f6>
 3c6:	0cd000ef          	jal	c92 <printf>
 3ca:	bfc1                	j	39a <test_part1_synchronized_counter+0x13a>

00000000000003cc <test_part2_producer_consumer>:
}

void test_part2_producer_consumer(void) {
 3cc:	7179                	addi	sp,sp,-48
 3ce:	f406                	sd	ra,40(sp)
 3d0:	f022                	sd	s0,32(sp)
 3d2:	ec26                	sd	s1,24(sp)
 3d4:	e84a                	sd	s2,16(sp)
 3d6:	e44e                	sd	s3,8(sp)
 3d8:	e052                	sd	s4,0(sp)
 3da:	1800                	addi	s0,sp,48
  printf("\n============================================================\n");
 3dc:	00001517          	auipc	a0,0x1
 3e0:	dd450513          	addi	a0,a0,-556 # 11b0 <malloc+0x466>
 3e4:	0af000ef          	jal	c92 <printf>
  printf(" PART 2: Classic Producer-Consumer Bounded Buffer Test      \n");
 3e8:	00001517          	auipc	a0,0x1
 3ec:	e0850513          	addi	a0,a0,-504 # 11f0 <malloc+0x4a6>
 3f0:	0a3000ef          	jal	c92 <printf>
  printf(" Buffer Size = %d, Total Items = %d                         \n",
 3f4:	463d                	li	a2,15
 3f6:	4595                	li	a1,5
 3f8:	00001517          	auipc	a0,0x1
 3fc:	e3850513          	addi	a0,a0,-456 # 1230 <malloc+0x4e6>
 400:	093000ef          	jal	c92 <printf>
         BUFFER_SIZE, TOTAL_ITEMS);
  printf(" Semaphores: Empty (init 5), Full (init 0), Mutex (init 1)  \n");
 404:	00001517          	auipc	a0,0x1
 408:	e6c50513          	addi	a0,a0,-404 # 1270 <malloc+0x526>
 40c:	087000ef          	jal	c92 <printf>
  printf("============================================================\n");
 410:	00001517          	auipc	a0,0x1
 414:	b3850513          	addi	a0,a0,-1224 # f48 <malloc+0x1fe>
 418:	07b000ef          	jal	c92 <printf>

  pc_in = 0;
 41c:	00002797          	auipc	a5,0x2
 420:	be07a823          	sw	zero,-1040(a5) # 200c <pc_in>
  pc_out = 0;
 424:	00002797          	auipc	a5,0x2
 428:	be07a223          	sw	zero,-1052(a5) # 2008 <pc_out>
  pc_count = 0;
 42c:	00002497          	auipc	s1,0x2
 430:	bd848493          	addi	s1,s1,-1064 # 2004 <pc_count>
 434:	0004a023          	sw	zero,0(s1)
  pc_max_seen = 0;
 438:	00002917          	auipc	s2,0x2
 43c:	bc890913          	addi	s2,s2,-1080 # 2000 <pc_max_seen>
 440:	00092023          	sw	zero,0(s2)

  sem_init(SEM_PC_MUTEX, 1);
 444:	4585                	li	a1,1
 446:	852e                	mv	a0,a1
 448:	48c000ef          	jal	8d4 <sem_init>
  sem_init(SEM_PC_EMPTY, BUFFER_SIZE);
 44c:	4595                	li	a1,5
 44e:	4509                	li	a0,2
 450:	484000ef          	jal	8d4 <sem_init>
  sem_init(SEM_PC_FULL, 0);
 454:	4581                	li	a1,0
 456:	450d                	li	a0,3
 458:	47c000ef          	jal	8d4 <sem_init>

  void *stack_p = malloc(PGSIZE);
 45c:	6505                	lui	a0,0x1
 45e:	0ed000ef          	jal	d4a <malloc>
 462:	8a2a                	mv	s4,a0
  void *stack_c = malloc(PGSIZE);
 464:	6505                	lui	a0,0x1
 466:	0e5000ef          	jal	d4a <malloc>
 46a:	89aa                	mv	s3,a0

  clone(producer_thread, 0, stack_p);
 46c:	8652                	mv	a2,s4
 46e:	4581                	li	a1,0
 470:	00000517          	auipc	a0,0x0
 474:	c3050513          	addi	a0,a0,-976 # a0 <producer_thread>
 478:	44c000ef          	jal	8c4 <clone>
  clone(consumer_thread, 0, stack_c);
 47c:	864e                	mv	a2,s3
 47e:	4581                	li	a1,0
 480:	00000517          	auipc	a0,0x0
 484:	cec50513          	addi	a0,a0,-788 # 16c <consumer_thread>
 488:	43c000ef          	jal	8c4 <clone>

  join();
 48c:	440000ef          	jal	8cc <join>
  join();
 490:	43c000ef          	jal	8cc <join>

  free(stack_p);
 494:	8552                	mv	a0,s4
 496:	02f000ef          	jal	cc4 <free>
  free(stack_c);
 49a:	854e                	mv	a0,s3
 49c:	029000ef          	jal	cc4 <free>

  printf("------------------------------------------------------------\n");
 4a0:	00001517          	auipc	a0,0x1
 4a4:	bf050513          	addi	a0,a0,-1040 # 1090 <malloc+0x346>
 4a8:	7ea000ef          	jal	c92 <printf>
  printf("Part 2 Results: Peak Buffer Usage = %d/%d slots, Final Count = %d\n",
 4ac:	4094                	lw	a3,0(s1)
 4ae:	4615                	li	a2,5
 4b0:	00092583          	lw	a1,0(s2)
 4b4:	00001517          	auipc	a0,0x1
 4b8:	dfc50513          	addi	a0,a0,-516 # 12b0 <malloc+0x566>
 4bc:	7d6000ef          	jal	c92 <printf>
         pc_max_seen, BUFFER_SIZE, pc_count);
  if (pc_count == 0 && pc_max_seen <= BUFFER_SIZE) {
 4c0:	409c                	lw	a5,0(s1)
 4c2:	eb81                	bnez	a5,4d2 <test_part2_producer_consumer+0x106>
 4c4:	00002717          	auipc	a4,0x2
 4c8:	b3c72703          	lw	a4,-1220(a4) # 2000 <pc_max_seen>
 4cc:	4795                	li	a5,5
 4ce:	02e7d063          	bge	a5,a4,4ee <test_part2_producer_consumer+0x122>
    printf("SUCCESS: No buffer overflow or underflow occurred.\n");
    printf("Producer-Consumer synchronization fully verified!\n");
  } else {
    printf("FAILURE: Buffer bounds violated!\n");
 4d2:	00001517          	auipc	a0,0x1
 4d6:	e9650513          	addi	a0,a0,-362 # 1368 <malloc+0x61e>
 4da:	7b8000ef          	jal	c92 <printf>
  }
}
 4de:	70a2                	ld	ra,40(sp)
 4e0:	7402                	ld	s0,32(sp)
 4e2:	64e2                	ld	s1,24(sp)
 4e4:	6942                	ld	s2,16(sp)
 4e6:	69a2                	ld	s3,8(sp)
 4e8:	6a02                	ld	s4,0(sp)
 4ea:	6145                	addi	sp,sp,48
 4ec:	8082                	ret
    printf("SUCCESS: No buffer overflow or underflow occurred.\n");
 4ee:	00001517          	auipc	a0,0x1
 4f2:	e0a50513          	addi	a0,a0,-502 # 12f8 <malloc+0x5ae>
 4f6:	79c000ef          	jal	c92 <printf>
    printf("Producer-Consumer synchronization fully verified!\n");
 4fa:	00001517          	auipc	a0,0x1
 4fe:	e3650513          	addi	a0,a0,-458 # 1330 <malloc+0x5e6>
 502:	790000ef          	jal	c92 <printf>
 506:	bfe1                	j	4de <test_part2_producer_consumer+0x112>

0000000000000508 <main>:

int main(int argc, char *argv[]) {
 508:	1141                	addi	sp,sp,-16
 50a:	e406                	sd	ra,8(sp)
 50c:	e022                	sd	s0,0(sp)
 50e:	0800                	addi	s0,sp,16
  printf("============================================================\n");
 510:	00001517          	auipc	a0,0x1
 514:	a3850513          	addi	a0,a0,-1480 # f48 <malloc+0x1fe>
 518:	77a000ef          	jal	c92 <printf>
  printf("      xv6 Process/Thread Synchronization using Semaphores   \n");
 51c:	00001517          	auipc	a0,0x1
 520:	e7450513          	addi	a0,a0,-396 # 1390 <malloc+0x646>
 524:	76e000ef          	jal	c92 <printf>
  printf("============================================================\n");
 528:	00001517          	auipc	a0,0x1
 52c:	a2050513          	addi	a0,a0,-1504 # f48 <malloc+0x1fe>
 530:	762000ef          	jal	c92 <printf>

  test_part1_synchronized_counter();
 534:	d2dff0ef          	jal	260 <test_part1_synchronized_counter>
  test_part2_producer_consumer();
 538:	e95ff0ef          	jal	3cc <test_part2_producer_consumer>

  printf("\n============================================================\n");
 53c:	00001517          	auipc	a0,0x1
 540:	c7450513          	addi	a0,a0,-908 # 11b0 <malloc+0x466>
 544:	74e000ef          	jal	c92 <printf>
  printf("All synchronization tests completed successfully!\n");
 548:	00001517          	auipc	a0,0x1
 54c:	e8850513          	addi	a0,a0,-376 # 13d0 <malloc+0x686>
 550:	742000ef          	jal	c92 <printf>
  printf("============================================================\n");
 554:	00001517          	auipc	a0,0x1
 558:	9f450513          	addi	a0,a0,-1548 # f48 <malloc+0x1fe>
 55c:	736000ef          	jal	c92 <printf>

  exit(0);
 560:	4501                	li	a0,0
 562:	2ba000ef          	jal	81c <exit>

0000000000000566 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 566:	1141                	addi	sp,sp,-16
 568:	e406                	sd	ra,8(sp)
 56a:	e022                	sd	s0,0(sp)
 56c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 56e:	f9bff0ef          	jal	508 <main>
  exit(r);
 572:	2aa000ef          	jal	81c <exit>

0000000000000576 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 576:	1141                	addi	sp,sp,-16
 578:	e406                	sd	ra,8(sp)
 57a:	e022                	sd	s0,0(sp)
 57c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 57e:	87aa                	mv	a5,a0
 580:	0585                	addi	a1,a1,1
 582:	0785                	addi	a5,a5,1
 584:	fff5c703          	lbu	a4,-1(a1)
 588:	fee78fa3          	sb	a4,-1(a5)
 58c:	fb75                	bnez	a4,580 <strcpy+0xa>
    ;
  return os;
}
 58e:	60a2                	ld	ra,8(sp)
 590:	6402                	ld	s0,0(sp)
 592:	0141                	addi	sp,sp,16
 594:	8082                	ret

0000000000000596 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 596:	1141                	addi	sp,sp,-16
 598:	e406                	sd	ra,8(sp)
 59a:	e022                	sd	s0,0(sp)
 59c:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 59e:	00054783          	lbu	a5,0(a0)
 5a2:	cb91                	beqz	a5,5b6 <strcmp+0x20>
 5a4:	0005c703          	lbu	a4,0(a1)
 5a8:	00f71763          	bne	a4,a5,5b6 <strcmp+0x20>
    p++, q++;
 5ac:	0505                	addi	a0,a0,1
 5ae:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 5b0:	00054783          	lbu	a5,0(a0)
 5b4:	fbe5                	bnez	a5,5a4 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 5b6:	0005c503          	lbu	a0,0(a1)
}
 5ba:	40a7853b          	subw	a0,a5,a0
 5be:	60a2                	ld	ra,8(sp)
 5c0:	6402                	ld	s0,0(sp)
 5c2:	0141                	addi	sp,sp,16
 5c4:	8082                	ret

00000000000005c6 <strlen>:

uint
strlen(const char *s)
{
 5c6:	1141                	addi	sp,sp,-16
 5c8:	e406                	sd	ra,8(sp)
 5ca:	e022                	sd	s0,0(sp)
 5cc:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 5ce:	00054783          	lbu	a5,0(a0)
 5d2:	cf91                	beqz	a5,5ee <strlen+0x28>
 5d4:	00150793          	addi	a5,a0,1
 5d8:	86be                	mv	a3,a5
 5da:	0785                	addi	a5,a5,1
 5dc:	fff7c703          	lbu	a4,-1(a5)
 5e0:	ff65                	bnez	a4,5d8 <strlen+0x12>
 5e2:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 5e6:	60a2                	ld	ra,8(sp)
 5e8:	6402                	ld	s0,0(sp)
 5ea:	0141                	addi	sp,sp,16
 5ec:	8082                	ret
  for (n = 0; s[n]; n++)
 5ee:	4501                	li	a0,0
 5f0:	bfdd                	j	5e6 <strlen+0x20>

00000000000005f2 <memset>:

void *
memset(void *dst, int c, uint n)
{
 5f2:	1141                	addi	sp,sp,-16
 5f4:	e406                	sd	ra,8(sp)
 5f6:	e022                	sd	s0,0(sp)
 5f8:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 5fa:	ca19                	beqz	a2,610 <memset+0x1e>
 5fc:	87aa                	mv	a5,a0
 5fe:	1602                	slli	a2,a2,0x20
 600:	9201                	srli	a2,a2,0x20
 602:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 606:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 60a:	0785                	addi	a5,a5,1
 60c:	fee79de3          	bne	a5,a4,606 <memset+0x14>
  }
  return dst;
}
 610:	60a2                	ld	ra,8(sp)
 612:	6402                	ld	s0,0(sp)
 614:	0141                	addi	sp,sp,16
 616:	8082                	ret

0000000000000618 <strchr>:

char *
strchr(const char *s, char c)
{
 618:	1141                	addi	sp,sp,-16
 61a:	e406                	sd	ra,8(sp)
 61c:	e022                	sd	s0,0(sp)
 61e:	0800                	addi	s0,sp,16
  for (; *s; s++)
 620:	00054783          	lbu	a5,0(a0)
 624:	cf81                	beqz	a5,63c <strchr+0x24>
    if (*s == c)
 626:	00f58763          	beq	a1,a5,634 <strchr+0x1c>
  for (; *s; s++)
 62a:	0505                	addi	a0,a0,1
 62c:	00054783          	lbu	a5,0(a0)
 630:	fbfd                	bnez	a5,626 <strchr+0xe>
      return (char *)s;
  return 0;
 632:	4501                	li	a0,0
}
 634:	60a2                	ld	ra,8(sp)
 636:	6402                	ld	s0,0(sp)
 638:	0141                	addi	sp,sp,16
 63a:	8082                	ret
  return 0;
 63c:	4501                	li	a0,0
 63e:	bfdd                	j	634 <strchr+0x1c>

0000000000000640 <gets>:

char *
gets(char *buf, int max)
{
 640:	711d                	addi	sp,sp,-96
 642:	ec86                	sd	ra,88(sp)
 644:	e8a2                	sd	s0,80(sp)
 646:	e4a6                	sd	s1,72(sp)
 648:	e0ca                	sd	s2,64(sp)
 64a:	fc4e                	sd	s3,56(sp)
 64c:	f852                	sd	s4,48(sp)
 64e:	f456                	sd	s5,40(sp)
 650:	f05a                	sd	s6,32(sp)
 652:	ec5e                	sd	s7,24(sp)
 654:	e862                	sd	s8,16(sp)
 656:	1080                	addi	s0,sp,96
 658:	8baa                	mv	s7,a0
 65a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 65c:	892a                	mv	s2,a0
 65e:	4481                	li	s1,0
    cc = read(0, &c, 1);
 660:	faf40b13          	addi	s6,s0,-81
 664:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 666:	8c26                	mv	s8,s1
 668:	0014899b          	addiw	s3,s1,1
 66c:	84ce                	mv	s1,s3
 66e:	0349d463          	bge	s3,s4,696 <gets+0x56>
    cc = read(0, &c, 1);
 672:	8656                	mv	a2,s5
 674:	85da                	mv	a1,s6
 676:	4501                	li	a0,0
 678:	1bc000ef          	jal	834 <read>
    if (cc < 1)
 67c:	00a05d63          	blez	a0,696 <gets+0x56>
      break;
    buf[i++] = c;
 680:	faf44783          	lbu	a5,-81(s0)
 684:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 688:	0905                	addi	s2,s2,1
 68a:	ff678713          	addi	a4,a5,-10
 68e:	c319                	beqz	a4,694 <gets+0x54>
 690:	17cd                	addi	a5,a5,-13
 692:	fbf1                	bnez	a5,666 <gets+0x26>
    buf[i++] = c;
 694:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 696:	9c5e                	add	s8,s8,s7
 698:	000c0023          	sb	zero,0(s8)
  return buf;
}
 69c:	855e                	mv	a0,s7
 69e:	60e6                	ld	ra,88(sp)
 6a0:	6446                	ld	s0,80(sp)
 6a2:	64a6                	ld	s1,72(sp)
 6a4:	6906                	ld	s2,64(sp)
 6a6:	79e2                	ld	s3,56(sp)
 6a8:	7a42                	ld	s4,48(sp)
 6aa:	7aa2                	ld	s5,40(sp)
 6ac:	7b02                	ld	s6,32(sp)
 6ae:	6be2                	ld	s7,24(sp)
 6b0:	6c42                	ld	s8,16(sp)
 6b2:	6125                	addi	sp,sp,96
 6b4:	8082                	ret

00000000000006b6 <stat>:

int
stat(const char *n, struct stat *st)
{
 6b6:	1101                	addi	sp,sp,-32
 6b8:	ec06                	sd	ra,24(sp)
 6ba:	e822                	sd	s0,16(sp)
 6bc:	e04a                	sd	s2,0(sp)
 6be:	1000                	addi	s0,sp,32
 6c0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 6c2:	4581                	li	a1,0
 6c4:	198000ef          	jal	85c <open>
  if (fd < 0)
 6c8:	02054263          	bltz	a0,6ec <stat+0x36>
 6cc:	e426                	sd	s1,8(sp)
 6ce:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 6d0:	85ca                	mv	a1,s2
 6d2:	1a2000ef          	jal	874 <fstat>
 6d6:	892a                	mv	s2,a0
  close(fd);
 6d8:	8526                	mv	a0,s1
 6da:	16a000ef          	jal	844 <close>
  return r;
 6de:	64a2                	ld	s1,8(sp)
}
 6e0:	854a                	mv	a0,s2
 6e2:	60e2                	ld	ra,24(sp)
 6e4:	6442                	ld	s0,16(sp)
 6e6:	6902                	ld	s2,0(sp)
 6e8:	6105                	addi	sp,sp,32
 6ea:	8082                	ret
    return -1;
 6ec:	57fd                	li	a5,-1
 6ee:	893e                	mv	s2,a5
 6f0:	bfc5                	j	6e0 <stat+0x2a>

00000000000006f2 <atoi>:

int
atoi(const char *s)
{
 6f2:	1141                	addi	sp,sp,-16
 6f4:	e406                	sd	ra,8(sp)
 6f6:	e022                	sd	s0,0(sp)
 6f8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 6fa:	00054683          	lbu	a3,0(a0)
 6fe:	fd06879b          	addiw	a5,a3,-48
 702:	0ff7f793          	zext.b	a5,a5
 706:	4625                	li	a2,9
 708:	02f66963          	bltu	a2,a5,73a <atoi+0x48>
 70c:	872a                	mv	a4,a0
  n = 0;
 70e:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 710:	0705                	addi	a4,a4,1
 712:	0025179b          	slliw	a5,a0,0x2
 716:	9fa9                	addw	a5,a5,a0
 718:	0017979b          	slliw	a5,a5,0x1
 71c:	9fb5                	addw	a5,a5,a3
 71e:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 722:	00074683          	lbu	a3,0(a4)
 726:	fd06879b          	addiw	a5,a3,-48
 72a:	0ff7f793          	zext.b	a5,a5
 72e:	fef671e3          	bgeu	a2,a5,710 <atoi+0x1e>
  return n;
}
 732:	60a2                	ld	ra,8(sp)
 734:	6402                	ld	s0,0(sp)
 736:	0141                	addi	sp,sp,16
 738:	8082                	ret
  n = 0;
 73a:	4501                	li	a0,0
 73c:	bfdd                	j	732 <atoi+0x40>

000000000000073e <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 73e:	1141                	addi	sp,sp,-16
 740:	e406                	sd	ra,8(sp)
 742:	e022                	sd	s0,0(sp)
 744:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 746:	02b57563          	bgeu	a0,a1,770 <memmove+0x32>
    while (n-- > 0)
 74a:	00c05f63          	blez	a2,768 <memmove+0x2a>
 74e:	1602                	slli	a2,a2,0x20
 750:	9201                	srli	a2,a2,0x20
 752:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 756:	872a                	mv	a4,a0
      *dst++ = *src++;
 758:	0585                	addi	a1,a1,1
 75a:	0705                	addi	a4,a4,1
 75c:	fff5c683          	lbu	a3,-1(a1)
 760:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 764:	fee79ae3          	bne	a5,a4,758 <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 768:	60a2                	ld	ra,8(sp)
 76a:	6402                	ld	s0,0(sp)
 76c:	0141                	addi	sp,sp,16
 76e:	8082                	ret
    while (n-- > 0)
 770:	fec05ce3          	blez	a2,768 <memmove+0x2a>
    dst += n;
 774:	00c50733          	add	a4,a0,a2
    src += n;
 778:	95b2                	add	a1,a1,a2
 77a:	fff6079b          	addiw	a5,a2,-1
 77e:	1782                	slli	a5,a5,0x20
 780:	9381                	srli	a5,a5,0x20
 782:	fff7c793          	not	a5,a5
 786:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 788:	15fd                	addi	a1,a1,-1
 78a:	177d                	addi	a4,a4,-1
 78c:	0005c683          	lbu	a3,0(a1)
 790:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 794:	fef71ae3          	bne	a4,a5,788 <memmove+0x4a>
 798:	bfc1                	j	768 <memmove+0x2a>

000000000000079a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 79a:	1141                	addi	sp,sp,-16
 79c:	e406                	sd	ra,8(sp)
 79e:	e022                	sd	s0,0(sp)
 7a0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 7a2:	c61d                	beqz	a2,7d0 <memcmp+0x36>
 7a4:	1602                	slli	a2,a2,0x20
 7a6:	9201                	srli	a2,a2,0x20
 7a8:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 7ac:	00054783          	lbu	a5,0(a0)
 7b0:	0005c703          	lbu	a4,0(a1)
 7b4:	00e79863          	bne	a5,a4,7c4 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 7b8:	0505                	addi	a0,a0,1
    p2++;
 7ba:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 7bc:	fed518e3          	bne	a0,a3,7ac <memcmp+0x12>
  }
  return 0;
 7c0:	4501                	li	a0,0
 7c2:	a019                	j	7c8 <memcmp+0x2e>
      return *p1 - *p2;
 7c4:	40e7853b          	subw	a0,a5,a4
}
 7c8:	60a2                	ld	ra,8(sp)
 7ca:	6402                	ld	s0,0(sp)
 7cc:	0141                	addi	sp,sp,16
 7ce:	8082                	ret
  return 0;
 7d0:	4501                	li	a0,0
 7d2:	bfdd                	j	7c8 <memcmp+0x2e>

00000000000007d4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 7d4:	1141                	addi	sp,sp,-16
 7d6:	e406                	sd	ra,8(sp)
 7d8:	e022                	sd	s0,0(sp)
 7da:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 7dc:	f63ff0ef          	jal	73e <memmove>
}
 7e0:	60a2                	ld	ra,8(sp)
 7e2:	6402                	ld	s0,0(sp)
 7e4:	0141                	addi	sp,sp,16
 7e6:	8082                	ret

00000000000007e8 <sbrk>:

char *
sbrk(int n)
{
 7e8:	1141                	addi	sp,sp,-16
 7ea:	e406                	sd	ra,8(sp)
 7ec:	e022                	sd	s0,0(sp)
 7ee:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 7f0:	4585                	li	a1,1
 7f2:	0b2000ef          	jal	8a4 <sys_sbrk>
}
 7f6:	60a2                	ld	ra,8(sp)
 7f8:	6402                	ld	s0,0(sp)
 7fa:	0141                	addi	sp,sp,16
 7fc:	8082                	ret

00000000000007fe <sbrklazy>:

char *
sbrklazy(int n)
{
 7fe:	1141                	addi	sp,sp,-16
 800:	e406                	sd	ra,8(sp)
 802:	e022                	sd	s0,0(sp)
 804:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 806:	4589                	li	a1,2
 808:	09c000ef          	jal	8a4 <sys_sbrk>
}
 80c:	60a2                	ld	ra,8(sp)
 80e:	6402                	ld	s0,0(sp)
 810:	0141                	addi	sp,sp,16
 812:	8082                	ret

0000000000000814 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 814:	4885                	li	a7,1
 ecall
 816:	00000073          	ecall
 ret
 81a:	8082                	ret

000000000000081c <exit>:
.global exit
exit:
 li a7, SYS_exit
 81c:	4889                	li	a7,2
 ecall
 81e:	00000073          	ecall
 ret
 822:	8082                	ret

0000000000000824 <wait>:
.global wait
wait:
 li a7, SYS_wait
 824:	488d                	li	a7,3
 ecall
 826:	00000073          	ecall
 ret
 82a:	8082                	ret

000000000000082c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 82c:	4891                	li	a7,4
 ecall
 82e:	00000073          	ecall
 ret
 832:	8082                	ret

0000000000000834 <read>:
.global read
read:
 li a7, SYS_read
 834:	4895                	li	a7,5
 ecall
 836:	00000073          	ecall
 ret
 83a:	8082                	ret

000000000000083c <write>:
.global write
write:
 li a7, SYS_write
 83c:	48c1                	li	a7,16
 ecall
 83e:	00000073          	ecall
 ret
 842:	8082                	ret

0000000000000844 <close>:
.global close
close:
 li a7, SYS_close
 844:	48d5                	li	a7,21
 ecall
 846:	00000073          	ecall
 ret
 84a:	8082                	ret

000000000000084c <kill>:
.global kill
kill:
 li a7, SYS_kill
 84c:	4899                	li	a7,6
 ecall
 84e:	00000073          	ecall
 ret
 852:	8082                	ret

0000000000000854 <exec>:
.global exec
exec:
 li a7, SYS_exec
 854:	489d                	li	a7,7
 ecall
 856:	00000073          	ecall
 ret
 85a:	8082                	ret

000000000000085c <open>:
.global open
open:
 li a7, SYS_open
 85c:	48bd                	li	a7,15
 ecall
 85e:	00000073          	ecall
 ret
 862:	8082                	ret

0000000000000864 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 864:	48c5                	li	a7,17
 ecall
 866:	00000073          	ecall
 ret
 86a:	8082                	ret

000000000000086c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 86c:	48c9                	li	a7,18
 ecall
 86e:	00000073          	ecall
 ret
 872:	8082                	ret

0000000000000874 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 874:	48a1                	li	a7,8
 ecall
 876:	00000073          	ecall
 ret
 87a:	8082                	ret

000000000000087c <link>:
.global link
link:
 li a7, SYS_link
 87c:	48cd                	li	a7,19
 ecall
 87e:	00000073          	ecall
 ret
 882:	8082                	ret

0000000000000884 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 884:	48d1                	li	a7,20
 ecall
 886:	00000073          	ecall
 ret
 88a:	8082                	ret

000000000000088c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 88c:	48a5                	li	a7,9
 ecall
 88e:	00000073          	ecall
 ret
 892:	8082                	ret

0000000000000894 <dup>:
.global dup
dup:
 li a7, SYS_dup
 894:	48a9                	li	a7,10
 ecall
 896:	00000073          	ecall
 ret
 89a:	8082                	ret

000000000000089c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 89c:	48ad                	li	a7,11
 ecall
 89e:	00000073          	ecall
 ret
 8a2:	8082                	ret

00000000000008a4 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 8a4:	48b1                	li	a7,12
 ecall
 8a6:	00000073          	ecall
 ret
 8aa:	8082                	ret

00000000000008ac <pause>:
.global pause
pause:
 li a7, SYS_pause
 8ac:	48b5                	li	a7,13
 ecall
 8ae:	00000073          	ecall
 ret
 8b2:	8082                	ret

00000000000008b4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 8b4:	48b9                	li	a7,14
 ecall
 8b6:	00000073          	ecall
 ret
 8ba:	8082                	ret

00000000000008bc <sync>:
.global sync
sync:
 li a7, SYS_sync
 8bc:	48d9                	li	a7,22
 ecall
 8be:	00000073          	ecall
 ret
 8c2:	8082                	ret

00000000000008c4 <clone>:
.global clone
clone:
 li a7, SYS_clone
 8c4:	48dd                	li	a7,23
 ecall
 8c6:	00000073          	ecall
 ret
 8ca:	8082                	ret

00000000000008cc <join>:
.global join
join:
 li a7, SYS_join
 8cc:	48e1                	li	a7,24
 ecall
 8ce:	00000073          	ecall
 ret
 8d2:	8082                	ret

00000000000008d4 <sem_init>:
.global sem_init
sem_init:
 li a7, SYS_sem_init
 8d4:	48e5                	li	a7,25
 ecall
 8d6:	00000073          	ecall
 ret
 8da:	8082                	ret

00000000000008dc <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 8dc:	48e9                	li	a7,26
 ecall
 8de:	00000073          	ecall
 ret
 8e2:	8082                	ret

00000000000008e4 <sem_signal>:
.global sem_signal
sem_signal:
 li a7, SYS_sem_signal
 8e4:	48ed                	li	a7,27
 ecall
 8e6:	00000073          	ecall
 ret
 8ea:	8082                	ret

00000000000008ec <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 8ec:	1101                	addi	sp,sp,-32
 8ee:	ec06                	sd	ra,24(sp)
 8f0:	e822                	sd	s0,16(sp)
 8f2:	1000                	addi	s0,sp,32
 8f4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 8f8:	4605                	li	a2,1
 8fa:	fef40593          	addi	a1,s0,-17
 8fe:	f3fff0ef          	jal	83c <write>
}
 902:	60e2                	ld	ra,24(sp)
 904:	6442                	ld	s0,16(sp)
 906:	6105                	addi	sp,sp,32
 908:	8082                	ret

000000000000090a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 90a:	715d                	addi	sp,sp,-80
 90c:	e486                	sd	ra,72(sp)
 90e:	e0a2                	sd	s0,64(sp)
 910:	f84a                	sd	s2,48(sp)
 912:	f44e                	sd	s3,40(sp)
 914:	0880                	addi	s0,sp,80
 916:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 918:	c6d1                	beqz	a3,9a4 <printint+0x9a>
 91a:	0805d563          	bgez	a1,9a4 <printint+0x9a>
    neg = 1;
    x = -xx;
 91e:	40b005b3          	neg	a1,a1
    neg = 1;
 922:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 924:	fb840993          	addi	s3,s0,-72
  neg = 0;
 928:	86ce                	mv	a3,s3
  i = 0;
 92a:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 92c:	00001817          	auipc	a6,0x1
 930:	ae480813          	addi	a6,a6,-1308 # 1410 <digits>
 934:	88ba                	mv	a7,a4
 936:	0017051b          	addiw	a0,a4,1
 93a:	872a                	mv	a4,a0
 93c:	02c5f7b3          	remu	a5,a1,a2
 940:	97c2                	add	a5,a5,a6
 942:	0007c783          	lbu	a5,0(a5)
 946:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 94a:	87ae                	mv	a5,a1
 94c:	02c5d5b3          	divu	a1,a1,a2
 950:	0685                	addi	a3,a3,1
 952:	fec7f1e3          	bgeu	a5,a2,934 <printint+0x2a>
  if (neg)
 956:	00030c63          	beqz	t1,96e <printint+0x64>
    buf[i++] = '-';
 95a:	fd050793          	addi	a5,a0,-48
 95e:	00878533          	add	a0,a5,s0
 962:	02d00793          	li	a5,45
 966:	fef50423          	sb	a5,-24(a0)
 96a:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 96e:	02e05563          	blez	a4,998 <printint+0x8e>
 972:	fc26                	sd	s1,56(sp)
 974:	377d                	addiw	a4,a4,-1
 976:	00e984b3          	add	s1,s3,a4
 97a:	19fd                	addi	s3,s3,-1
 97c:	99ba                	add	s3,s3,a4
 97e:	1702                	slli	a4,a4,0x20
 980:	9301                	srli	a4,a4,0x20
 982:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 986:	0004c583          	lbu	a1,0(s1)
 98a:	854a                	mv	a0,s2
 98c:	f61ff0ef          	jal	8ec <putc>
  while (--i >= 0)
 990:	14fd                	addi	s1,s1,-1
 992:	ff349ae3          	bne	s1,s3,986 <printint+0x7c>
 996:	74e2                	ld	s1,56(sp)
}
 998:	60a6                	ld	ra,72(sp)
 99a:	6406                	ld	s0,64(sp)
 99c:	7942                	ld	s2,48(sp)
 99e:	79a2                	ld	s3,40(sp)
 9a0:	6161                	addi	sp,sp,80
 9a2:	8082                	ret
  neg = 0;
 9a4:	4301                	li	t1,0
 9a6:	bfbd                	j	924 <printint+0x1a>

00000000000009a8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 9a8:	711d                	addi	sp,sp,-96
 9aa:	ec86                	sd	ra,88(sp)
 9ac:	e8a2                	sd	s0,80(sp)
 9ae:	e4a6                	sd	s1,72(sp)
 9b0:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 9b2:	0005c483          	lbu	s1,0(a1)
 9b6:	22048363          	beqz	s1,bdc <vprintf+0x234>
 9ba:	e0ca                	sd	s2,64(sp)
 9bc:	fc4e                	sd	s3,56(sp)
 9be:	f852                	sd	s4,48(sp)
 9c0:	f456                	sd	s5,40(sp)
 9c2:	f05a                	sd	s6,32(sp)
 9c4:	ec5e                	sd	s7,24(sp)
 9c6:	e862                	sd	s8,16(sp)
 9c8:	8b2a                	mv	s6,a0
 9ca:	8a2e                	mv	s4,a1
 9cc:	8bb2                	mv	s7,a2
  state = 0;
 9ce:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 9d0:	4901                	li	s2,0
 9d2:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 9d4:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 9d8:	06400c13          	li	s8,100
 9dc:	a00d                	j	9fe <vprintf+0x56>
        putc(fd, c0);
 9de:	85a6                	mv	a1,s1
 9e0:	855a                	mv	a0,s6
 9e2:	f0bff0ef          	jal	8ec <putc>
 9e6:	a019                	j	9ec <vprintf+0x44>
    } else if (state == '%') {
 9e8:	03598363          	beq	s3,s5,a0e <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 9ec:	0019079b          	addiw	a5,s2,1
 9f0:	893e                	mv	s2,a5
 9f2:	873e                	mv	a4,a5
 9f4:	97d2                	add	a5,a5,s4
 9f6:	0007c483          	lbu	s1,0(a5)
 9fa:	1c048a63          	beqz	s1,bce <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 9fe:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 a02:	fe0993e3          	bnez	s3,9e8 <vprintf+0x40>
      if (c0 == '%') {
 a06:	fd579ce3          	bne	a5,s5,9de <vprintf+0x36>
        state = '%';
 a0a:	89be                	mv	s3,a5
 a0c:	b7c5                	j	9ec <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 a0e:	00ea06b3          	add	a3,s4,a4
 a12:	0016c603          	lbu	a2,1(a3)
      if (c1)
 a16:	1c060863          	beqz	a2,be6 <vprintf+0x23e>
      if (c0 == 'd') {
 a1a:	03878763          	beq	a5,s8,a48 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 a1e:	f9478693          	addi	a3,a5,-108
 a22:	0016b693          	seqz	a3,a3
 a26:	f9c60593          	addi	a1,a2,-100
 a2a:	e99d                	bnez	a1,a60 <vprintf+0xb8>
 a2c:	ca95                	beqz	a3,a60 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 a2e:	008b8493          	addi	s1,s7,8 # 1008 <malloc+0x2be>
 a32:	4685                	li	a3,1
 a34:	4629                	li	a2,10
 a36:	000bb583          	ld	a1,0(s7)
 a3a:	855a                	mv	a0,s6
 a3c:	ecfff0ef          	jal	90a <printint>
        i += 1;
 a40:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 a42:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 a44:	4981                	li	s3,0
 a46:	b75d                	j	9ec <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 a48:	008b8493          	addi	s1,s7,8
 a4c:	4685                	li	a3,1
 a4e:	4629                	li	a2,10
 a50:	000ba583          	lw	a1,0(s7)
 a54:	855a                	mv	a0,s6
 a56:	eb5ff0ef          	jal	90a <printint>
 a5a:	8ba6                	mv	s7,s1
      state = 0;
 a5c:	4981                	li	s3,0
 a5e:	b779                	j	9ec <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 a60:	9752                	add	a4,a4,s4
 a62:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 a66:	f9460713          	addi	a4,a2,-108
 a6a:	00173713          	seqz	a4,a4
 a6e:	8f75                	and	a4,a4,a3
 a70:	f9c58513          	addi	a0,a1,-100
 a74:	18051363          	bnez	a0,bfa <vprintf+0x252>
 a78:	18070163          	beqz	a4,bfa <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 a7c:	008b8493          	addi	s1,s7,8
 a80:	4685                	li	a3,1
 a82:	4629                	li	a2,10
 a84:	000bb583          	ld	a1,0(s7)
 a88:	855a                	mv	a0,s6
 a8a:	e81ff0ef          	jal	90a <printint>
        i += 2;
 a8e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 a90:	8ba6                	mv	s7,s1
      state = 0;
 a92:	4981                	li	s3,0
        i += 2;
 a94:	bfa1                	j	9ec <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 a96:	008b8493          	addi	s1,s7,8
 a9a:	4681                	li	a3,0
 a9c:	4629                	li	a2,10
 a9e:	000be583          	lwu	a1,0(s7)
 aa2:	855a                	mv	a0,s6
 aa4:	e67ff0ef          	jal	90a <printint>
 aa8:	8ba6                	mv	s7,s1
      state = 0;
 aaa:	4981                	li	s3,0
 aac:	b781                	j	9ec <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 aae:	008b8493          	addi	s1,s7,8
 ab2:	4681                	li	a3,0
 ab4:	4629                	li	a2,10
 ab6:	000bb583          	ld	a1,0(s7)
 aba:	855a                	mv	a0,s6
 abc:	e4fff0ef          	jal	90a <printint>
        i += 1;
 ac0:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 ac2:	8ba6                	mv	s7,s1
      state = 0;
 ac4:	4981                	li	s3,0
 ac6:	b71d                	j	9ec <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 ac8:	008b8493          	addi	s1,s7,8
 acc:	4681                	li	a3,0
 ace:	4629                	li	a2,10
 ad0:	000bb583          	ld	a1,0(s7)
 ad4:	855a                	mv	a0,s6
 ad6:	e35ff0ef          	jal	90a <printint>
        i += 2;
 ada:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 adc:	8ba6                	mv	s7,s1
      state = 0;
 ade:	4981                	li	s3,0
        i += 2;
 ae0:	b731                	j	9ec <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 ae2:	008b8493          	addi	s1,s7,8
 ae6:	4681                	li	a3,0
 ae8:	4641                	li	a2,16
 aea:	000be583          	lwu	a1,0(s7)
 aee:	855a                	mv	a0,s6
 af0:	e1bff0ef          	jal	90a <printint>
 af4:	8ba6                	mv	s7,s1
      state = 0;
 af6:	4981                	li	s3,0
 af8:	bdd5                	j	9ec <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 afa:	008b8493          	addi	s1,s7,8
 afe:	4681                	li	a3,0
 b00:	4641                	li	a2,16
 b02:	000bb583          	ld	a1,0(s7)
 b06:	855a                	mv	a0,s6
 b08:	e03ff0ef          	jal	90a <printint>
        i += 1;
 b0c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 b0e:	8ba6                	mv	s7,s1
      state = 0;
 b10:	4981                	li	s3,0
 b12:	bde9                	j	9ec <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 b14:	008b8493          	addi	s1,s7,8
 b18:	4681                	li	a3,0
 b1a:	4641                	li	a2,16
 b1c:	000bb583          	ld	a1,0(s7)
 b20:	855a                	mv	a0,s6
 b22:	de9ff0ef          	jal	90a <printint>
        i += 2;
 b26:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 b28:	8ba6                	mv	s7,s1
      state = 0;
 b2a:	4981                	li	s3,0
        i += 2;
 b2c:	b5c1                	j	9ec <vprintf+0x44>
 b2e:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 b30:	008b8793          	addi	a5,s7,8
 b34:	8cbe                	mv	s9,a5
 b36:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 b3a:	03000593          	li	a1,48
 b3e:	855a                	mv	a0,s6
 b40:	dadff0ef          	jal	8ec <putc>
  putc(fd, 'x');
 b44:	07800593          	li	a1,120
 b48:	855a                	mv	a0,s6
 b4a:	da3ff0ef          	jal	8ec <putc>
 b4e:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 b50:	00001b97          	auipc	s7,0x1
 b54:	8c0b8b93          	addi	s7,s7,-1856 # 1410 <digits>
 b58:	03c9d793          	srli	a5,s3,0x3c
 b5c:	97de                	add	a5,a5,s7
 b5e:	0007c583          	lbu	a1,0(a5)
 b62:	855a                	mv	a0,s6
 b64:	d89ff0ef          	jal	8ec <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 b68:	0992                	slli	s3,s3,0x4
 b6a:	34fd                	addiw	s1,s1,-1
 b6c:	f4f5                	bnez	s1,b58 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 b6e:	8be6                	mv	s7,s9
      state = 0;
 b70:	4981                	li	s3,0
 b72:	6ca2                	ld	s9,8(sp)
 b74:	bda5                	j	9ec <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 b76:	008b8493          	addi	s1,s7,8
 b7a:	000bc583          	lbu	a1,0(s7)
 b7e:	855a                	mv	a0,s6
 b80:	d6dff0ef          	jal	8ec <putc>
 b84:	8ba6                	mv	s7,s1
      state = 0;
 b86:	4981                	li	s3,0
 b88:	b595                	j	9ec <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 b8a:	008b8993          	addi	s3,s7,8
 b8e:	000bb483          	ld	s1,0(s7)
 b92:	cc91                	beqz	s1,bae <vprintf+0x206>
        for (; *s; s++)
 b94:	0004c583          	lbu	a1,0(s1)
 b98:	c985                	beqz	a1,bc8 <vprintf+0x220>
          putc(fd, *s);
 b9a:	855a                	mv	a0,s6
 b9c:	d51ff0ef          	jal	8ec <putc>
        for (; *s; s++)
 ba0:	0485                	addi	s1,s1,1
 ba2:	0004c583          	lbu	a1,0(s1)
 ba6:	f9f5                	bnez	a1,b9a <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 ba8:	8bce                	mv	s7,s3
      state = 0;
 baa:	4981                	li	s3,0
 bac:	b581                	j	9ec <vprintf+0x44>
          s = "(null)";
 bae:	00001497          	auipc	s1,0x1
 bb2:	85a48493          	addi	s1,s1,-1958 # 1408 <malloc+0x6be>
        for (; *s; s++)
 bb6:	02800593          	li	a1,40
 bba:	b7c5                	j	b9a <vprintf+0x1f2>
        putc(fd, '%');
 bbc:	85be                	mv	a1,a5
 bbe:	855a                	mv	a0,s6
 bc0:	d2dff0ef          	jal	8ec <putc>
      state = 0;
 bc4:	4981                	li	s3,0
 bc6:	b51d                	j	9ec <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 bc8:	8bce                	mv	s7,s3
      state = 0;
 bca:	4981                	li	s3,0
 bcc:	b505                	j	9ec <vprintf+0x44>
 bce:	6906                	ld	s2,64(sp)
 bd0:	79e2                	ld	s3,56(sp)
 bd2:	7a42                	ld	s4,48(sp)
 bd4:	7aa2                	ld	s5,40(sp)
 bd6:	7b02                	ld	s6,32(sp)
 bd8:	6be2                	ld	s7,24(sp)
 bda:	6c42                	ld	s8,16(sp)
    }
  }
}
 bdc:	60e6                	ld	ra,88(sp)
 bde:	6446                	ld	s0,80(sp)
 be0:	64a6                	ld	s1,72(sp)
 be2:	6125                	addi	sp,sp,96
 be4:	8082                	ret
      if (c0 == 'd') {
 be6:	06400713          	li	a4,100
 bea:	e4e78fe3          	beq	a5,a4,a48 <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 bee:	f9478693          	addi	a3,a5,-108
 bf2:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 bf6:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 bf8:	4701                	li	a4,0
      } else if (c0 == 'u') {
 bfa:	07500513          	li	a0,117
 bfe:	e8a78ce3          	beq	a5,a0,a96 <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 c02:	f8b60513          	addi	a0,a2,-117
 c06:	e119                	bnez	a0,c0c <vprintf+0x264>
 c08:	ea0693e3          	bnez	a3,aae <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 c0c:	f8b58513          	addi	a0,a1,-117
 c10:	e119                	bnez	a0,c16 <vprintf+0x26e>
 c12:	ea071be3          	bnez	a4,ac8 <vprintf+0x120>
      } else if (c0 == 'x') {
 c16:	07800513          	li	a0,120
 c1a:	eca784e3          	beq	a5,a0,ae2 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 c1e:	f8860613          	addi	a2,a2,-120
 c22:	e219                	bnez	a2,c28 <vprintf+0x280>
 c24:	ec069be3          	bnez	a3,afa <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 c28:	f8858593          	addi	a1,a1,-120
 c2c:	e199                	bnez	a1,c32 <vprintf+0x28a>
 c2e:	ee0713e3          	bnez	a4,b14 <vprintf+0x16c>
      } else if (c0 == 'p') {
 c32:	07000713          	li	a4,112
 c36:	eee78ce3          	beq	a5,a4,b2e <vprintf+0x186>
      } else if (c0 == 'c') {
 c3a:	06300713          	li	a4,99
 c3e:	f2e78ce3          	beq	a5,a4,b76 <vprintf+0x1ce>
      } else if (c0 == 's') {
 c42:	07300713          	li	a4,115
 c46:	f4e782e3          	beq	a5,a4,b8a <vprintf+0x1e2>
      } else if (c0 == '%') {
 c4a:	02500713          	li	a4,37
 c4e:	f6e787e3          	beq	a5,a4,bbc <vprintf+0x214>
        putc(fd, '%');
 c52:	02500593          	li	a1,37
 c56:	855a                	mv	a0,s6
 c58:	c95ff0ef          	jal	8ec <putc>
        putc(fd, c0);
 c5c:	85a6                	mv	a1,s1
 c5e:	855a                	mv	a0,s6
 c60:	c8dff0ef          	jal	8ec <putc>
      state = 0;
 c64:	4981                	li	s3,0
 c66:	b359                	j	9ec <vprintf+0x44>

0000000000000c68 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 c68:	715d                	addi	sp,sp,-80
 c6a:	ec06                	sd	ra,24(sp)
 c6c:	e822                	sd	s0,16(sp)
 c6e:	1000                	addi	s0,sp,32
 c70:	e010                	sd	a2,0(s0)
 c72:	e414                	sd	a3,8(s0)
 c74:	e818                	sd	a4,16(s0)
 c76:	ec1c                	sd	a5,24(s0)
 c78:	03043023          	sd	a6,32(s0)
 c7c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 c80:	8622                	mv	a2,s0
 c82:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 c86:	d23ff0ef          	jal	9a8 <vprintf>
}
 c8a:	60e2                	ld	ra,24(sp)
 c8c:	6442                	ld	s0,16(sp)
 c8e:	6161                	addi	sp,sp,80
 c90:	8082                	ret

0000000000000c92 <printf>:

void
printf(const char *fmt, ...)
{
 c92:	711d                	addi	sp,sp,-96
 c94:	ec06                	sd	ra,24(sp)
 c96:	e822                	sd	s0,16(sp)
 c98:	1000                	addi	s0,sp,32
 c9a:	e40c                	sd	a1,8(s0)
 c9c:	e810                	sd	a2,16(s0)
 c9e:	ec14                	sd	a3,24(s0)
 ca0:	f018                	sd	a4,32(s0)
 ca2:	f41c                	sd	a5,40(s0)
 ca4:	03043823          	sd	a6,48(s0)
 ca8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 cac:	00840613          	addi	a2,s0,8
 cb0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 cb4:	85aa                	mv	a1,a0
 cb6:	4505                	li	a0,1
 cb8:	cf1ff0ef          	jal	9a8 <vprintf>
}
 cbc:	60e2                	ld	ra,24(sp)
 cbe:	6442                	ld	s0,16(sp)
 cc0:	6125                	addi	sp,sp,96
 cc2:	8082                	ret

0000000000000cc4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 cc4:	1141                	addi	sp,sp,-16
 cc6:	e406                	sd	ra,8(sp)
 cc8:	e022                	sd	s0,0(sp)
 cca:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 ccc:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 cd0:	00001797          	auipc	a5,0x1
 cd4:	3487b783          	ld	a5,840(a5) # 2018 <freep>
 cd8:	a039                	j	ce6 <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 cda:	6398                	ld	a4,0(a5)
 cdc:	00e7e463          	bltu	a5,a4,ce4 <free+0x20>
 ce0:	00e6ea63          	bltu	a3,a4,cf4 <free+0x30>
{
 ce4:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ce6:	fed7fae3          	bgeu	a5,a3,cda <free+0x16>
 cea:	6398                	ld	a4,0(a5)
 cec:	00e6e463          	bltu	a3,a4,cf4 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 cf0:	fee7eae3          	bltu	a5,a4,ce4 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 cf4:	ff852583          	lw	a1,-8(a0)
 cf8:	6390                	ld	a2,0(a5)
 cfa:	02059813          	slli	a6,a1,0x20
 cfe:	01c85713          	srli	a4,a6,0x1c
 d02:	9736                	add	a4,a4,a3
 d04:	02e60563          	beq	a2,a4,d2e <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 d08:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 d0c:	4790                	lw	a2,8(a5)
 d0e:	02061593          	slli	a1,a2,0x20
 d12:	01c5d713          	srli	a4,a1,0x1c
 d16:	973e                	add	a4,a4,a5
 d18:	02e68263          	beq	a3,a4,d3c <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 d1c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 d1e:	00001717          	auipc	a4,0x1
 d22:	2ef73d23          	sd	a5,762(a4) # 2018 <freep>
}
 d26:	60a2                	ld	ra,8(sp)
 d28:	6402                	ld	s0,0(sp)
 d2a:	0141                	addi	sp,sp,16
 d2c:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 d2e:	4618                	lw	a4,8(a2)
 d30:	9f2d                	addw	a4,a4,a1
 d32:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 d36:	6398                	ld	a4,0(a5)
 d38:	6310                	ld	a2,0(a4)
 d3a:	b7f9                	j	d08 <free+0x44>
    p->s.size += bp->s.size;
 d3c:	ff852703          	lw	a4,-8(a0)
 d40:	9f31                	addw	a4,a4,a2
 d42:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 d44:	ff053683          	ld	a3,-16(a0)
 d48:	bfd1                	j	d1c <free+0x58>

0000000000000d4a <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 d4a:	7139                	addi	sp,sp,-64
 d4c:	fc06                	sd	ra,56(sp)
 d4e:	f822                	sd	s0,48(sp)
 d50:	f04a                	sd	s2,32(sp)
 d52:	ec4e                	sd	s3,24(sp)
 d54:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 d56:	02051993          	slli	s3,a0,0x20
 d5a:	0209d993          	srli	s3,s3,0x20
 d5e:	09bd                	addi	s3,s3,15
 d60:	0049d993          	srli	s3,s3,0x4
 d64:	2985                	addiw	s3,s3,1
 d66:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 d68:	00001517          	auipc	a0,0x1
 d6c:	2b053503          	ld	a0,688(a0) # 2018 <freep>
 d70:	c905                	beqz	a0,da0 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 d72:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 d74:	4798                	lw	a4,8(a5)
 d76:	09377663          	bgeu	a4,s3,e02 <malloc+0xb8>
 d7a:	f426                	sd	s1,40(sp)
 d7c:	e852                	sd	s4,16(sp)
 d7e:	e456                	sd	s5,8(sp)
 d80:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 d82:	8a4e                	mv	s4,s3
 d84:	6705                	lui	a4,0x1
 d86:	00e9f363          	bgeu	s3,a4,d8c <malloc+0x42>
 d8a:	6a05                	lui	s4,0x1
 d8c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 d90:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 d94:	00001497          	auipc	s1,0x1
 d98:	28448493          	addi	s1,s1,644 # 2018 <freep>
  if (p == SBRK_ERROR)
 d9c:	5afd                	li	s5,-1
 d9e:	a83d                	j	ddc <malloc+0x92>
 da0:	f426                	sd	s1,40(sp)
 da2:	e852                	sd	s4,16(sp)
 da4:	e456                	sd	s5,8(sp)
 da6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 da8:	00001797          	auipc	a5,0x1
 dac:	29078793          	addi	a5,a5,656 # 2038 <base>
 db0:	00001717          	auipc	a4,0x1
 db4:	26f73423          	sd	a5,616(a4) # 2018 <freep>
 db8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 dba:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 dbe:	b7d1                	j	d82 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 dc0:	6398                	ld	a4,0(a5)
 dc2:	e118                	sd	a4,0(a0)
 dc4:	a899                	j	e1a <malloc+0xd0>
  hp->s.size = nu;
 dc6:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 dca:	0541                	addi	a0,a0,16
 dcc:	ef9ff0ef          	jal	cc4 <free>
  return freep;
 dd0:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 dd2:	c125                	beqz	a0,e32 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 dd4:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 dd6:	4798                	lw	a4,8(a5)
 dd8:	03277163          	bgeu	a4,s2,dfa <malloc+0xb0>
    if (p == freep)
 ddc:	6098                	ld	a4,0(s1)
 dde:	853e                	mv	a0,a5
 de0:	fef71ae3          	bne	a4,a5,dd4 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 de4:	8552                	mv	a0,s4
 de6:	a03ff0ef          	jal	7e8 <sbrk>
  if (p == SBRK_ERROR)
 dea:	fd551ee3          	bne	a0,s5,dc6 <malloc+0x7c>
        return 0;
 dee:	4501                	li	a0,0
 df0:	74a2                	ld	s1,40(sp)
 df2:	6a42                	ld	s4,16(sp)
 df4:	6aa2                	ld	s5,8(sp)
 df6:	6b02                	ld	s6,0(sp)
 df8:	a03d                	j	e26 <malloc+0xdc>
 dfa:	74a2                	ld	s1,40(sp)
 dfc:	6a42                	ld	s4,16(sp)
 dfe:	6aa2                	ld	s5,8(sp)
 e00:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 e02:	fae90fe3          	beq	s2,a4,dc0 <malloc+0x76>
        p->s.size -= nunits;
 e06:	4137073b          	subw	a4,a4,s3
 e0a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 e0c:	02071693          	slli	a3,a4,0x20
 e10:	01c6d713          	srli	a4,a3,0x1c
 e14:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 e16:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 e1a:	00001717          	auipc	a4,0x1
 e1e:	1ea73f23          	sd	a0,510(a4) # 2018 <freep>
      return (void *)(p + 1);
 e22:	01078513          	addi	a0,a5,16
  }
}
 e26:	70e2                	ld	ra,56(sp)
 e28:	7442                	ld	s0,48(sp)
 e2a:	7902                	ld	s2,32(sp)
 e2c:	69e2                	ld	s3,24(sp)
 e2e:	6121                	addi	sp,sp,64
 e30:	8082                	ret
 e32:	74a2                	ld	s1,40(sp)
 e34:	6a42                	ld	s4,16(sp)
 e36:	6aa2                	ld	s5,8(sp)
 e38:	6b02                	ld	s6,0(sp)
 e3a:	b7f5                	j	e26 <malloc+0xdc>
