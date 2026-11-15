
user/_prodcons:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <producer>:
  int count;
  int max_observed;
  int min_observed;
};

void producer(struct shared_buffer *sb) {
   0:	711d                	addi	sp,sp,-96
   2:	ec86                	sd	ra,88(sp)
   4:	e8a2                	sd	s0,80(sp)
   6:	e4a6                	sd	s1,72(sp)
   8:	e0ca                	sd	s2,64(sp)
   a:	fc4e                	sd	s3,56(sp)
   c:	f852                	sd	s4,48(sp)
   e:	f456                	sd	s5,40(sp)
  10:	f05a                	sd	s6,32(sp)
  12:	ec5e                	sd	s7,24(sp)
  14:	e862                	sd	s8,16(sp)
  16:	e466                	sd	s9,8(sp)
  18:	1080                	addi	s0,sp,96
  1a:	84aa                	mv	s1,a0
  printf("Producer started (pid %d)\n", getpid());
  1c:	6c4000ef          	jal	6e0 <getpid>
  20:	85aa                	mv	a1,a0
  22:	00001517          	auipc	a0,0x1
  26:	c5e50513          	addi	a0,a0,-930 # c80 <malloc+0xfa>
  2a:	2a5000ef          	jal	ace <printf>
  for (int item = 1; item <= TOTAL_ITEMS; item++) {
  2e:	4905                	li	s2,1
    // Check if buffer is currently full before waiting
    if (sb->count == BUFFER_SIZE) {
  30:	4995                	li	s3,5
      printf("Producer: Buffer is FULL (%d/%d slots), waiting on empty semaphore...\n",
  32:	00001c97          	auipc	s9,0x1
  36:	c6ec8c93          	addi	s9,s9,-914 # ca0 <malloc+0x11a>
             sb->count, BUFFER_SIZE);
    }

    // Wait for free slot
    sem_wait(SEM_EMPTY);
  3a:	8a4a                	mv	s4,s2
    // Enter critical section
    sem_wait(SEM_MUTEX);

    // Insert item
    sb->buffer[sb->in] = item;
    sb->in = (sb->in + 1) % BUFFER_SIZE;
  3c:	66666ab7          	lui	s5,0x66666
  40:	667a8a93          	addi	s5,s5,1639 # 66666667 <base+0x66664657>
    sb->count++;

    if (sb->count > sb->max_observed)
      sb->max_observed = sb->count;

    printf("Producer [pid %d]: Produced item %d | Buffer count: %d/%d\n",
  44:	00001c17          	auipc	s8,0x1
  48:	ca4c0c13          	addi	s8,s8,-860 # ce8 <malloc+0x162>
           getpid(), item, sb->count, BUFFER_SIZE);

    // Exit critical section
    sem_post(SEM_MUTEX);
    // Signal that a slot is full
    sem_post(SEM_FULL);
  4c:	4b89                	li	s7,2
  for (int item = 1; item <= TOTAL_ITEMS; item++) {
  4e:	4b55                	li	s6,21
  50:	a825                	j	88 <producer+0x88>
      printf("Producer: Buffer is FULL (%d/%d slots), waiting on empty semaphore...\n",
  52:	864e                	mv	a2,s3
  54:	85ce                	mv	a1,s3
  56:	8566                	mv	a0,s9
  58:	277000ef          	jal	ace <printf>
  5c:	a80d                	j	8e <producer+0x8e>
    printf("Producer [pid %d]: Produced item %d | Buffer count: %d/%d\n",
  5e:	682000ef          	jal	6e0 <getpid>
  62:	85aa                	mv	a1,a0
  64:	874e                	mv	a4,s3
  66:	4cd4                	lw	a3,28(s1)
  68:	864a                	mv	a2,s2
  6a:	8562                	mv	a0,s8
  6c:	263000ef          	jal	ace <printf>
    sem_post(SEM_MUTEX);
  70:	4501                	li	a0,0
  72:	6ae000ef          	jal	720 <sem_post>
    sem_post(SEM_FULL);
  76:	855e                	mv	a0,s7
  78:	6a8000ef          	jal	720 <sem_post>

    // Sleep briefly (1 tick)
    pause(1);
  7c:	8552                	mv	a0,s4
  7e:	672000ef          	jal	6f0 <pause>
  for (int item = 1; item <= TOTAL_ITEMS; item++) {
  82:	2905                	addiw	s2,s2,1
  84:	05690563          	beq	s2,s6,ce <producer+0xce>
    if (sb->count == BUFFER_SIZE) {
  88:	4cdc                	lw	a5,28(s1)
  8a:	fd3784e3          	beq	a5,s3,52 <producer+0x52>
    sem_wait(SEM_EMPTY);
  8e:	8552                	mv	a0,s4
  90:	688000ef          	jal	718 <sem_wait>
    sem_wait(SEM_MUTEX);
  94:	4501                	li	a0,0
  96:	682000ef          	jal	718 <sem_wait>
    sb->buffer[sb->in] = item;
  9a:	48dc                	lw	a5,20(s1)
  9c:	00279713          	slli	a4,a5,0x2
  a0:	9726                	add	a4,a4,s1
  a2:	01272023          	sw	s2,0(a4)
    sb->in = (sb->in + 1) % BUFFER_SIZE;
  a6:	2785                	addiw	a5,a5,1
  a8:	03578733          	mul	a4,a5,s5
  ac:	9705                	srai	a4,a4,0x21
  ae:	41f7d69b          	sraiw	a3,a5,0x1f
  b2:	9f15                	subw	a4,a4,a3
  b4:	0027169b          	slliw	a3,a4,0x2
  b8:	9f35                	addw	a4,a4,a3
  ba:	9f99                	subw	a5,a5,a4
  bc:	c8dc                	sw	a5,20(s1)
    sb->count++;
  be:	4cdc                	lw	a5,28(s1)
  c0:	2785                	addiw	a5,a5,1
  c2:	ccdc                	sw	a5,28(s1)
    if (sb->count > sb->max_observed)
  c4:	5098                	lw	a4,32(s1)
  c6:	f8f75ce3          	bge	a4,a5,5e <producer+0x5e>
      sb->max_observed = sb->count;
  ca:	d09c                	sw	a5,32(s1)
  cc:	bf49                	j	5e <producer+0x5e>
  }
  printf("Producer finished producing %d items.\n", TOTAL_ITEMS);
  ce:	45d1                	li	a1,20
  d0:	00001517          	auipc	a0,0x1
  d4:	c5850513          	addi	a0,a0,-936 # d28 <malloc+0x1a2>
  d8:	1f7000ef          	jal	ace <printf>
}
  dc:	60e6                	ld	ra,88(sp)
  de:	6446                	ld	s0,80(sp)
  e0:	64a6                	ld	s1,72(sp)
  e2:	6906                	ld	s2,64(sp)
  e4:	79e2                	ld	s3,56(sp)
  e6:	7a42                	ld	s4,48(sp)
  e8:	7aa2                	ld	s5,40(sp)
  ea:	7b02                	ld	s6,32(sp)
  ec:	6be2                	ld	s7,24(sp)
  ee:	6c42                	ld	s8,16(sp)
  f0:	6ca2                	ld	s9,8(sp)
  f2:	6125                	addi	sp,sp,96
  f4:	8082                	ret

00000000000000f6 <consumer>:

void consumer(struct shared_buffer *sb) {
  f6:	7159                	addi	sp,sp,-112
  f8:	f486                	sd	ra,104(sp)
  fa:	f0a2                	sd	s0,96(sp)
  fc:	eca6                	sd	s1,88(sp)
  fe:	e8ca                	sd	s2,80(sp)
 100:	e4ce                	sd	s3,72(sp)
 102:	e0d2                	sd	s4,64(sp)
 104:	fc56                	sd	s5,56(sp)
 106:	f85a                	sd	s6,48(sp)
 108:	f45e                	sd	s7,40(sp)
 10a:	f062                	sd	s8,32(sp)
 10c:	ec66                	sd	s9,24(sp)
 10e:	e86a                	sd	s10,16(sp)
 110:	e46e                	sd	s11,8(sp)
 112:	1880                	addi	s0,sp,112
 114:	84aa                	mv	s1,a0
  int last_item = 0;
  int errors = 0;

  printf("Consumer started (pid %d)\n", getpid());
 116:	5ca000ef          	jal	6e0 <getpid>
 11a:	85aa                	mv	a1,a0
 11c:	00001517          	auipc	a0,0x1
 120:	c3450513          	addi	a0,a0,-972 # d50 <malloc+0x1ca>
 124:	1ab000ef          	jal	ace <printf>
 128:	4a51                	li	s4,20
  int errors = 0;
 12a:	4c01                	li	s8,0
  int last_item = 0;
 12c:	4981                	li	s3,0
  for (int i = 0; i < TOTAL_ITEMS; i++) {
    // Check if buffer is currently empty before waiting
    if (sb->count == 0) {
      printf("Consumer: Buffer is EMPTY (0/%d slots), waiting on full semaphore...\n",
 12e:	4b15                	li	s6,5
             BUFFER_SIZE);
    }

    // Wait for available item
    sem_wait(SEM_FULL);
 130:	4a89                	li	s5,2
    // Enter critical section
    sem_wait(SEM_MUTEX);

    // Remove item
    int item = sb->buffer[sb->out];
    sb->out = (sb->out + 1) % BUFFER_SIZE;
 132:	66666bb7          	lui	s7,0x66666
 136:	667b8b93          	addi	s7,s7,1639 # 66666667 <base+0x66664657>
    sb->count--;

    if (sb->count < sb->min_observed)
      sb->min_observed = sb->count;

    printf("Consumer [pid %d]: Consumed item %d | Buffer count: %d/%d\n",
 13a:	00001d17          	auipc	s10,0x1
 13e:	c7ed0d13          	addi	s10,s10,-898 # db8 <malloc+0x232>
           getpid(), item, sb->count, BUFFER_SIZE);

    // Verify FIFO order and no data corruption
    if (item != last_item + 1) {
      printf("ERROR: Expected item %d but got %d!\n", last_item + 1, item);
 142:	00001d97          	auipc	s11,0x1
 146:	cb6d8d93          	addi	s11,s11,-842 # df8 <malloc+0x272>
    last_item = item;

    // Exit critical section
    sem_post(SEM_MUTEX);
    // Signal that a slot is empty
    sem_post(SEM_EMPTY);
 14a:	4c85                	li	s9,1
 14c:	a099                	j	192 <consumer+0x9c>
      printf("Consumer: Buffer is EMPTY (0/%d slots), waiting on full semaphore...\n",
 14e:	85da                	mv	a1,s6
 150:	00001517          	auipc	a0,0x1
 154:	c2050513          	addi	a0,a0,-992 # d70 <malloc+0x1ea>
 158:	177000ef          	jal	ace <printf>
 15c:	a82d                	j	196 <consumer+0xa0>
    printf("Consumer [pid %d]: Consumed item %d | Buffer count: %d/%d\n",
 15e:	582000ef          	jal	6e0 <getpid>
 162:	85aa                	mv	a1,a0
 164:	875a                	mv	a4,s6
 166:	4cd4                	lw	a3,28(s1)
 168:	864a                	mv	a2,s2
 16a:	856a                	mv	a0,s10
 16c:	163000ef          	jal	ace <printf>
    if (item != last_item + 1) {
 170:	0019859b          	addiw	a1,s3,1
 174:	07259163          	bne	a1,s2,1d6 <consumer+0xe0>
    sem_post(SEM_MUTEX);
 178:	4501                	li	a0,0
 17a:	5a6000ef          	jal	720 <sem_post>
    sem_post(SEM_EMPTY);
 17e:	8566                	mv	a0,s9
 180:	5a0000ef          	jal	720 <sem_post>

    // Sleep briefly (2 ticks) to let producer outpace consumer and test buffer full condition
    pause(2);
 184:	8556                	mv	a0,s5
 186:	56a000ef          	jal	6f0 <pause>
  for (int i = 0; i < TOTAL_ITEMS; i++) {
 18a:	3a7d                	addiw	s4,s4,-1
 18c:	040a0b63          	beqz	s4,1e2 <consumer+0xec>
 190:	89ca                	mv	s3,s2
    if (sb->count == 0) {
 192:	4cdc                	lw	a5,28(s1)
 194:	dfcd                	beqz	a5,14e <consumer+0x58>
    sem_wait(SEM_FULL);
 196:	8556                	mv	a0,s5
 198:	580000ef          	jal	718 <sem_wait>
    sem_wait(SEM_MUTEX);
 19c:	4501                	li	a0,0
 19e:	57a000ef          	jal	718 <sem_wait>
    int item = sb->buffer[sb->out];
 1a2:	4c9c                	lw	a5,24(s1)
 1a4:	00279713          	slli	a4,a5,0x2
 1a8:	9726                	add	a4,a4,s1
 1aa:	00072903          	lw	s2,0(a4)
    sb->out = (sb->out + 1) % BUFFER_SIZE;
 1ae:	2785                	addiw	a5,a5,1
 1b0:	03778733          	mul	a4,a5,s7
 1b4:	9705                	srai	a4,a4,0x21
 1b6:	41f7d69b          	sraiw	a3,a5,0x1f
 1ba:	9f15                	subw	a4,a4,a3
 1bc:	0027169b          	slliw	a3,a4,0x2
 1c0:	9f35                	addw	a4,a4,a3
 1c2:	9f99                	subw	a5,a5,a4
 1c4:	cc9c                	sw	a5,24(s1)
    sb->count--;
 1c6:	4cdc                	lw	a5,28(s1)
 1c8:	37fd                	addiw	a5,a5,-1
 1ca:	ccdc                	sw	a5,28(s1)
    if (sb->count < sb->min_observed)
 1cc:	50d8                	lw	a4,36(s1)
 1ce:	f8e7d8e3          	bge	a5,a4,15e <consumer+0x68>
      sb->min_observed = sb->count;
 1d2:	d0dc                	sw	a5,36(s1)
 1d4:	b769                	j	15e <consumer+0x68>
      printf("ERROR: Expected item %d but got %d!\n", last_item + 1, item);
 1d6:	864a                	mv	a2,s2
 1d8:	856e                	mv	a0,s11
 1da:	0f5000ef          	jal	ace <printf>
      errors++;
 1de:	2c05                	addiw	s8,s8,1
 1e0:	bf61                	j	178 <consumer+0x82>
  }

  if (errors == 0 && last_item == TOTAL_ITEMS) {
 1e2:	020c1b63          	bnez	s8,218 <consumer+0x122>
 1e6:	1931                	addi	s2,s2,-20
 1e8:	02091863          	bnez	s2,218 <consumer+0x122>
    printf("Consumer verification: ALL %d items received correctly in FIFO order!\n", TOTAL_ITEMS);
 1ec:	45d1                	li	a1,20
 1ee:	00001517          	auipc	a0,0x1
 1f2:	c3250513          	addi	a0,a0,-974 # e20 <malloc+0x29a>
 1f6:	0d9000ef          	jal	ace <printf>
  } else {
    printf("Consumer verification: FAILED with %d order errors.\n", errors);
  }
}
 1fa:	70a6                	ld	ra,104(sp)
 1fc:	7406                	ld	s0,96(sp)
 1fe:	64e6                	ld	s1,88(sp)
 200:	6946                	ld	s2,80(sp)
 202:	69a6                	ld	s3,72(sp)
 204:	6a06                	ld	s4,64(sp)
 206:	7ae2                	ld	s5,56(sp)
 208:	7b42                	ld	s6,48(sp)
 20a:	7ba2                	ld	s7,40(sp)
 20c:	7c02                	ld	s8,32(sp)
 20e:	6ce2                	ld	s9,24(sp)
 210:	6d42                	ld	s10,16(sp)
 212:	6da2                	ld	s11,8(sp)
 214:	6165                	addi	sp,sp,112
 216:	8082                	ret
    printf("Consumer verification: FAILED with %d order errors.\n", errors);
 218:	85e2                	mv	a1,s8
 21a:	00001517          	auipc	a0,0x1
 21e:	c4e50513          	addi	a0,a0,-946 # e68 <malloc+0x2e2>
 222:	0ad000ef          	jal	ace <printf>
}
 226:	bfd1                	j	1fa <consumer+0x104>

0000000000000228 <main>:

int main(int argc, char *argv[]) {
 228:	1101                	addi	sp,sp,-32
 22a:	ec06                	sd	ra,24(sp)
 22c:	e822                	sd	s0,16(sp)
 22e:	1000                	addi	s0,sp,32
  printf("============================================================\n");
 230:	00001517          	auipc	a0,0x1
 234:	c7050513          	addi	a0,a0,-912 # ea0 <malloc+0x31a>
 238:	097000ef          	jal	ace <printf>
  printf("Producer-Consumer Bounded Buffer Simulation with Semaphores\n");
 23c:	00001517          	auipc	a0,0x1
 240:	ca450513          	addi	a0,a0,-860 # ee0 <malloc+0x35a>
 244:	08b000ef          	jal	ace <printf>
  printf("Buffer capacity = %d, Total items = %d\n", BUFFER_SIZE, TOTAL_ITEMS);
 248:	4651                	li	a2,20
 24a:	4595                	li	a1,5
 24c:	00001517          	auipc	a0,0x1
 250:	cd450513          	addi	a0,a0,-812 # f20 <malloc+0x39a>
 254:	07b000ef          	jal	ace <printf>
  printf("============================================================\n");
 258:	00001517          	auipc	a0,0x1
 25c:	c4850513          	addi	a0,a0,-952 # ea0 <malloc+0x31a>
 260:	06f000ef          	jal	ace <printf>

  // Obtain shared memory page
  struct shared_buffer *sb = (struct shared_buffer *)shm_get();
 264:	4a4000ef          	jal	708 <shm_get>
  if (sb == 0) {
 268:	c131                	beqz	a0,2ac <main+0x84>
 26a:	e426                	sd	s1,8(sp)
 26c:	84aa                	mv	s1,a0
    printf("Error: shm_get failed\n");
    exit(1);
  }

  // Initialize shared state
  sb->in = 0;
 26e:	00052a23          	sw	zero,20(a0)
  sb->out = 0;
 272:	00052c23          	sw	zero,24(a0)
  sb->count = 0;
 276:	00052e23          	sw	zero,28(a0)
  sb->max_observed = 0;
 27a:	02052023          	sw	zero,32(a0)
  sb->min_observed = 0;
 27e:	02052223          	sw	zero,36(a0)

  // Initialize semaphores
  // SEM_MUTEX = 1 (binary semaphore for mutual exclusion)
  // SEM_EMPTY = BUFFER_SIZE (counting semaphore for available slots)
  // SEM_FULL  = 0 (counting semaphore for filled slots)
  if (sem_init(SEM_MUTEX, 1) < 0 ||
 282:	4585                	li	a1,1
 284:	4501                	li	a0,0
 286:	48a000ef          	jal	710 <sem_init>
 28a:	00054863          	bltz	a0,29a <main+0x72>
      sem_init(SEM_EMPTY, BUFFER_SIZE) < 0 ||
 28e:	4595                	li	a1,5
 290:	4505                	li	a0,1
 292:	47e000ef          	jal	710 <sem_init>
  if (sem_init(SEM_MUTEX, 1) < 0 ||
 296:	02055563          	bgez	a0,2c0 <main+0x98>
      sem_init(SEM_FULL, 0) < 0) {
    printf("Error: sem_init failed\n");
 29a:	00001517          	auipc	a0,0x1
 29e:	cc650513          	addi	a0,a0,-826 # f60 <malloc+0x3da>
 2a2:	02d000ef          	jal	ace <printf>
    exit(1);
 2a6:	4505                	li	a0,1
 2a8:	3b8000ef          	jal	660 <exit>
 2ac:	e426                	sd	s1,8(sp)
    printf("Error: shm_get failed\n");
 2ae:	00001517          	auipc	a0,0x1
 2b2:	c9a50513          	addi	a0,a0,-870 # f48 <malloc+0x3c2>
 2b6:	019000ef          	jal	ace <printf>
    exit(1);
 2ba:	4505                	li	a0,1
 2bc:	3a4000ef          	jal	660 <exit>
      sem_init(SEM_FULL, 0) < 0) {
 2c0:	4581                	li	a1,0
 2c2:	4509                	li	a0,2
 2c4:	44c000ef          	jal	710 <sem_init>
      sem_init(SEM_EMPTY, BUFFER_SIZE) < 0 ||
 2c8:	fc0549e3          	bltz	a0,29a <main+0x72>
  }

  int pid_prod = fork();
 2cc:	38c000ef          	jal	658 <fork>
  if (pid_prod < 0) {
 2d0:	00054963          	bltz	a0,2e2 <main+0xba>
    printf("fork producer failed\n");
    exit(1);
  }
  if (pid_prod == 0) {
 2d4:	e105                	bnez	a0,2f4 <main+0xcc>
    producer(sb);
 2d6:	8526                	mv	a0,s1
 2d8:	d29ff0ef          	jal	0 <producer>
    exit(0);
 2dc:	4501                	li	a0,0
 2de:	382000ef          	jal	660 <exit>
    printf("fork producer failed\n");
 2e2:	00001517          	auipc	a0,0x1
 2e6:	c9650513          	addi	a0,a0,-874 # f78 <malloc+0x3f2>
 2ea:	7e4000ef          	jal	ace <printf>
    exit(1);
 2ee:	4505                	li	a0,1
 2f0:	370000ef          	jal	660 <exit>
  }

  int pid_cons = fork();
 2f4:	364000ef          	jal	658 <fork>
  if (pid_cons < 0) {
 2f8:	00054963          	bltz	a0,30a <main+0xe2>
    printf("fork consumer failed\n");
    exit(1);
  }
  if (pid_cons == 0) {
 2fc:	e105                	bnez	a0,31c <main+0xf4>
    consumer(sb);
 2fe:	8526                	mv	a0,s1
 300:	df7ff0ef          	jal	f6 <consumer>
    exit(0);
 304:	4501                	li	a0,0
 306:	35a000ef          	jal	660 <exit>
    printf("fork consumer failed\n");
 30a:	00001517          	auipc	a0,0x1
 30e:	c8650513          	addi	a0,a0,-890 # f90 <malloc+0x40a>
 312:	7bc000ef          	jal	ace <printf>
    exit(1);
 316:	4505                	li	a0,1
 318:	348000ef          	jal	660 <exit>
  }

  // Wait for both children to terminate
  wait(0);
 31c:	4501                	li	a0,0
 31e:	34a000ef          	jal	668 <wait>
  wait(0);
 322:	4501                	li	a0,0
 324:	344000ef          	jal	668 <wait>

  printf("============================================================\n");
 328:	00001517          	auipc	a0,0x1
 32c:	b7850513          	addi	a0,a0,-1160 # ea0 <malloc+0x31a>
 330:	79e000ef          	jal	ace <printf>
  printf("Simulation Finished Summary:\n");
 334:	00001517          	auipc	a0,0x1
 338:	c7450513          	addi	a0,a0,-908 # fa8 <malloc+0x422>
 33c:	792000ef          	jal	ace <printf>
  printf("Peak buffer usage: %d / %d slots\n", sb->max_observed, BUFFER_SIZE);
 340:	4615                	li	a2,5
 342:	508c                	lw	a1,32(s1)
 344:	00001517          	auipc	a0,0x1
 348:	c8450513          	addi	a0,a0,-892 # fc8 <malloc+0x442>
 34c:	782000ef          	jal	ace <printf>
  printf("Min buffer usage: %d / %d slots\n", sb->min_observed, BUFFER_SIZE);
 350:	4615                	li	a2,5
 352:	50cc                	lw	a1,36(s1)
 354:	00001517          	auipc	a0,0x1
 358:	c9c50513          	addi	a0,a0,-868 # ff0 <malloc+0x46a>
 35c:	772000ef          	jal	ace <printf>
  if (sb->count == 0 && sb->max_observed <= BUFFER_SIZE && sb->min_observed >= 0) {
 360:	4cdc                	lw	a5,28(s1)
 362:	eb81                	bnez	a5,372 <main+0x14a>
 364:	5098                	lw	a4,32(s1)
 366:	4795                	li	a5,5
 368:	00e7c563          	blt	a5,a4,372 <main+0x14a>
 36c:	50dc                	lw	a5,36(s1)
 36e:	0207d163          	bgez	a5,390 <main+0x168>
    printf("SUCCESS: No buffer overflow or underflow detected.\n");
    printf("Buffer is cleanly drained (final count = 0).\n");
  } else {
    printf("FAILURE: Buffer state violated!\n");
 372:	00001517          	auipc	a0,0x1
 376:	d0e50513          	addi	a0,a0,-754 # 1080 <malloc+0x4fa>
 37a:	754000ef          	jal	ace <printf>
  }
  printf("============================================================\n");
 37e:	00001517          	auipc	a0,0x1
 382:	b2250513          	addi	a0,a0,-1246 # ea0 <malloc+0x31a>
 386:	748000ef          	jal	ace <printf>

  exit(0);
 38a:	4501                	li	a0,0
 38c:	2d4000ef          	jal	660 <exit>
    printf("SUCCESS: No buffer overflow or underflow detected.\n");
 390:	00001517          	auipc	a0,0x1
 394:	c8850513          	addi	a0,a0,-888 # 1018 <malloc+0x492>
 398:	736000ef          	jal	ace <printf>
    printf("Buffer is cleanly drained (final count = 0).\n");
 39c:	00001517          	auipc	a0,0x1
 3a0:	cb450513          	addi	a0,a0,-844 # 1050 <malloc+0x4ca>
 3a4:	72a000ef          	jal	ace <printf>
 3a8:	bfd9                	j	37e <main+0x156>

00000000000003aa <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 3aa:	1141                	addi	sp,sp,-16
 3ac:	e406                	sd	ra,8(sp)
 3ae:	e022                	sd	s0,0(sp)
 3b0:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 3b2:	e77ff0ef          	jal	228 <main>
  exit(r);
 3b6:	2aa000ef          	jal	660 <exit>

00000000000003ba <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 3ba:	1141                	addi	sp,sp,-16
 3bc:	e406                	sd	ra,8(sp)
 3be:	e022                	sd	s0,0(sp)
 3c0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 3c2:	87aa                	mv	a5,a0
 3c4:	0585                	addi	a1,a1,1
 3c6:	0785                	addi	a5,a5,1
 3c8:	fff5c703          	lbu	a4,-1(a1)
 3cc:	fee78fa3          	sb	a4,-1(a5)
 3d0:	fb75                	bnez	a4,3c4 <strcpy+0xa>
    ;
  return os;
}
 3d2:	60a2                	ld	ra,8(sp)
 3d4:	6402                	ld	s0,0(sp)
 3d6:	0141                	addi	sp,sp,16
 3d8:	8082                	ret

00000000000003da <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3da:	1141                	addi	sp,sp,-16
 3dc:	e406                	sd	ra,8(sp)
 3de:	e022                	sd	s0,0(sp)
 3e0:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 3e2:	00054783          	lbu	a5,0(a0)
 3e6:	cb91                	beqz	a5,3fa <strcmp+0x20>
 3e8:	0005c703          	lbu	a4,0(a1)
 3ec:	00f71763          	bne	a4,a5,3fa <strcmp+0x20>
    p++, q++;
 3f0:	0505                	addi	a0,a0,1
 3f2:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 3f4:	00054783          	lbu	a5,0(a0)
 3f8:	fbe5                	bnez	a5,3e8 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 3fa:	0005c503          	lbu	a0,0(a1)
}
 3fe:	40a7853b          	subw	a0,a5,a0
 402:	60a2                	ld	ra,8(sp)
 404:	6402                	ld	s0,0(sp)
 406:	0141                	addi	sp,sp,16
 408:	8082                	ret

000000000000040a <strlen>:

uint
strlen(const char *s)
{
 40a:	1141                	addi	sp,sp,-16
 40c:	e406                	sd	ra,8(sp)
 40e:	e022                	sd	s0,0(sp)
 410:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 412:	00054783          	lbu	a5,0(a0)
 416:	cf91                	beqz	a5,432 <strlen+0x28>
 418:	00150793          	addi	a5,a0,1
 41c:	86be                	mv	a3,a5
 41e:	0785                	addi	a5,a5,1
 420:	fff7c703          	lbu	a4,-1(a5)
 424:	ff65                	bnez	a4,41c <strlen+0x12>
 426:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 42a:	60a2                	ld	ra,8(sp)
 42c:	6402                	ld	s0,0(sp)
 42e:	0141                	addi	sp,sp,16
 430:	8082                	ret
  for (n = 0; s[n]; n++)
 432:	4501                	li	a0,0
 434:	bfdd                	j	42a <strlen+0x20>

0000000000000436 <memset>:

void *
memset(void *dst, int c, uint n)
{
 436:	1141                	addi	sp,sp,-16
 438:	e406                	sd	ra,8(sp)
 43a:	e022                	sd	s0,0(sp)
 43c:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 43e:	ca19                	beqz	a2,454 <memset+0x1e>
 440:	87aa                	mv	a5,a0
 442:	1602                	slli	a2,a2,0x20
 444:	9201                	srli	a2,a2,0x20
 446:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 44a:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 44e:	0785                	addi	a5,a5,1
 450:	fee79de3          	bne	a5,a4,44a <memset+0x14>
  }
  return dst;
}
 454:	60a2                	ld	ra,8(sp)
 456:	6402                	ld	s0,0(sp)
 458:	0141                	addi	sp,sp,16
 45a:	8082                	ret

000000000000045c <strchr>:

char *
strchr(const char *s, char c)
{
 45c:	1141                	addi	sp,sp,-16
 45e:	e406                	sd	ra,8(sp)
 460:	e022                	sd	s0,0(sp)
 462:	0800                	addi	s0,sp,16
  for (; *s; s++)
 464:	00054783          	lbu	a5,0(a0)
 468:	cf81                	beqz	a5,480 <strchr+0x24>
    if (*s == c)
 46a:	00f58763          	beq	a1,a5,478 <strchr+0x1c>
  for (; *s; s++)
 46e:	0505                	addi	a0,a0,1
 470:	00054783          	lbu	a5,0(a0)
 474:	fbfd                	bnez	a5,46a <strchr+0xe>
      return (char *)s;
  return 0;
 476:	4501                	li	a0,0
}
 478:	60a2                	ld	ra,8(sp)
 47a:	6402                	ld	s0,0(sp)
 47c:	0141                	addi	sp,sp,16
 47e:	8082                	ret
  return 0;
 480:	4501                	li	a0,0
 482:	bfdd                	j	478 <strchr+0x1c>

0000000000000484 <gets>:

char *
gets(char *buf, int max)
{
 484:	711d                	addi	sp,sp,-96
 486:	ec86                	sd	ra,88(sp)
 488:	e8a2                	sd	s0,80(sp)
 48a:	e4a6                	sd	s1,72(sp)
 48c:	e0ca                	sd	s2,64(sp)
 48e:	fc4e                	sd	s3,56(sp)
 490:	f852                	sd	s4,48(sp)
 492:	f456                	sd	s5,40(sp)
 494:	f05a                	sd	s6,32(sp)
 496:	ec5e                	sd	s7,24(sp)
 498:	e862                	sd	s8,16(sp)
 49a:	1080                	addi	s0,sp,96
 49c:	8baa                	mv	s7,a0
 49e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 4a0:	892a                	mv	s2,a0
 4a2:	4481                	li	s1,0
    cc = read(0, &c, 1);
 4a4:	faf40b13          	addi	s6,s0,-81
 4a8:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 4aa:	8c26                	mv	s8,s1
 4ac:	0014899b          	addiw	s3,s1,1
 4b0:	84ce                	mv	s1,s3
 4b2:	0349d463          	bge	s3,s4,4da <gets+0x56>
    cc = read(0, &c, 1);
 4b6:	8656                	mv	a2,s5
 4b8:	85da                	mv	a1,s6
 4ba:	4501                	li	a0,0
 4bc:	1bc000ef          	jal	678 <read>
    if (cc < 1)
 4c0:	00a05d63          	blez	a0,4da <gets+0x56>
      break;
    buf[i++] = c;
 4c4:	faf44783          	lbu	a5,-81(s0)
 4c8:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 4cc:	0905                	addi	s2,s2,1
 4ce:	ff678713          	addi	a4,a5,-10
 4d2:	c319                	beqz	a4,4d8 <gets+0x54>
 4d4:	17cd                	addi	a5,a5,-13
 4d6:	fbf1                	bnez	a5,4aa <gets+0x26>
    buf[i++] = c;
 4d8:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 4da:	9c5e                	add	s8,s8,s7
 4dc:	000c0023          	sb	zero,0(s8)
  return buf;
}
 4e0:	855e                	mv	a0,s7
 4e2:	60e6                	ld	ra,88(sp)
 4e4:	6446                	ld	s0,80(sp)
 4e6:	64a6                	ld	s1,72(sp)
 4e8:	6906                	ld	s2,64(sp)
 4ea:	79e2                	ld	s3,56(sp)
 4ec:	7a42                	ld	s4,48(sp)
 4ee:	7aa2                	ld	s5,40(sp)
 4f0:	7b02                	ld	s6,32(sp)
 4f2:	6be2                	ld	s7,24(sp)
 4f4:	6c42                	ld	s8,16(sp)
 4f6:	6125                	addi	sp,sp,96
 4f8:	8082                	ret

00000000000004fa <stat>:

int
stat(const char *n, struct stat *st)
{
 4fa:	1101                	addi	sp,sp,-32
 4fc:	ec06                	sd	ra,24(sp)
 4fe:	e822                	sd	s0,16(sp)
 500:	e04a                	sd	s2,0(sp)
 502:	1000                	addi	s0,sp,32
 504:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 506:	4581                	li	a1,0
 508:	198000ef          	jal	6a0 <open>
  if (fd < 0)
 50c:	02054263          	bltz	a0,530 <stat+0x36>
 510:	e426                	sd	s1,8(sp)
 512:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 514:	85ca                	mv	a1,s2
 516:	1a2000ef          	jal	6b8 <fstat>
 51a:	892a                	mv	s2,a0
  close(fd);
 51c:	8526                	mv	a0,s1
 51e:	16a000ef          	jal	688 <close>
  return r;
 522:	64a2                	ld	s1,8(sp)
}
 524:	854a                	mv	a0,s2
 526:	60e2                	ld	ra,24(sp)
 528:	6442                	ld	s0,16(sp)
 52a:	6902                	ld	s2,0(sp)
 52c:	6105                	addi	sp,sp,32
 52e:	8082                	ret
    return -1;
 530:	57fd                	li	a5,-1
 532:	893e                	mv	s2,a5
 534:	bfc5                	j	524 <stat+0x2a>

0000000000000536 <atoi>:

int
atoi(const char *s)
{
 536:	1141                	addi	sp,sp,-16
 538:	e406                	sd	ra,8(sp)
 53a:	e022                	sd	s0,0(sp)
 53c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 53e:	00054683          	lbu	a3,0(a0)
 542:	fd06879b          	addiw	a5,a3,-48
 546:	0ff7f793          	zext.b	a5,a5
 54a:	4625                	li	a2,9
 54c:	02f66963          	bltu	a2,a5,57e <atoi+0x48>
 550:	872a                	mv	a4,a0
  n = 0;
 552:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 554:	0705                	addi	a4,a4,1
 556:	0025179b          	slliw	a5,a0,0x2
 55a:	9fa9                	addw	a5,a5,a0
 55c:	0017979b          	slliw	a5,a5,0x1
 560:	9fb5                	addw	a5,a5,a3
 562:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 566:	00074683          	lbu	a3,0(a4)
 56a:	fd06879b          	addiw	a5,a3,-48
 56e:	0ff7f793          	zext.b	a5,a5
 572:	fef671e3          	bgeu	a2,a5,554 <atoi+0x1e>
  return n;
}
 576:	60a2                	ld	ra,8(sp)
 578:	6402                	ld	s0,0(sp)
 57a:	0141                	addi	sp,sp,16
 57c:	8082                	ret
  n = 0;
 57e:	4501                	li	a0,0
 580:	bfdd                	j	576 <atoi+0x40>

0000000000000582 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 582:	1141                	addi	sp,sp,-16
 584:	e406                	sd	ra,8(sp)
 586:	e022                	sd	s0,0(sp)
 588:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 58a:	02b57563          	bgeu	a0,a1,5b4 <memmove+0x32>
    while (n-- > 0)
 58e:	00c05f63          	blez	a2,5ac <memmove+0x2a>
 592:	1602                	slli	a2,a2,0x20
 594:	9201                	srli	a2,a2,0x20
 596:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 59a:	872a                	mv	a4,a0
      *dst++ = *src++;
 59c:	0585                	addi	a1,a1,1
 59e:	0705                	addi	a4,a4,1
 5a0:	fff5c683          	lbu	a3,-1(a1)
 5a4:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 5a8:	fee79ae3          	bne	a5,a4,59c <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 5ac:	60a2                	ld	ra,8(sp)
 5ae:	6402                	ld	s0,0(sp)
 5b0:	0141                	addi	sp,sp,16
 5b2:	8082                	ret
    while (n-- > 0)
 5b4:	fec05ce3          	blez	a2,5ac <memmove+0x2a>
    dst += n;
 5b8:	00c50733          	add	a4,a0,a2
    src += n;
 5bc:	95b2                	add	a1,a1,a2
 5be:	fff6079b          	addiw	a5,a2,-1
 5c2:	1782                	slli	a5,a5,0x20
 5c4:	9381                	srli	a5,a5,0x20
 5c6:	fff7c793          	not	a5,a5
 5ca:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 5cc:	15fd                	addi	a1,a1,-1
 5ce:	177d                	addi	a4,a4,-1
 5d0:	0005c683          	lbu	a3,0(a1)
 5d4:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 5d8:	fef71ae3          	bne	a4,a5,5cc <memmove+0x4a>
 5dc:	bfc1                	j	5ac <memmove+0x2a>

00000000000005de <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 5de:	1141                	addi	sp,sp,-16
 5e0:	e406                	sd	ra,8(sp)
 5e2:	e022                	sd	s0,0(sp)
 5e4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 5e6:	c61d                	beqz	a2,614 <memcmp+0x36>
 5e8:	1602                	slli	a2,a2,0x20
 5ea:	9201                	srli	a2,a2,0x20
 5ec:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 5f0:	00054783          	lbu	a5,0(a0)
 5f4:	0005c703          	lbu	a4,0(a1)
 5f8:	00e79863          	bne	a5,a4,608 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 5fc:	0505                	addi	a0,a0,1
    p2++;
 5fe:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 600:	fed518e3          	bne	a0,a3,5f0 <memcmp+0x12>
  }
  return 0;
 604:	4501                	li	a0,0
 606:	a019                	j	60c <memcmp+0x2e>
      return *p1 - *p2;
 608:	40e7853b          	subw	a0,a5,a4
}
 60c:	60a2                	ld	ra,8(sp)
 60e:	6402                	ld	s0,0(sp)
 610:	0141                	addi	sp,sp,16
 612:	8082                	ret
  return 0;
 614:	4501                	li	a0,0
 616:	bfdd                	j	60c <memcmp+0x2e>

0000000000000618 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 618:	1141                	addi	sp,sp,-16
 61a:	e406                	sd	ra,8(sp)
 61c:	e022                	sd	s0,0(sp)
 61e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 620:	f63ff0ef          	jal	582 <memmove>
}
 624:	60a2                	ld	ra,8(sp)
 626:	6402                	ld	s0,0(sp)
 628:	0141                	addi	sp,sp,16
 62a:	8082                	ret

000000000000062c <sbrk>:

char *
sbrk(int n)
{
 62c:	1141                	addi	sp,sp,-16
 62e:	e406                	sd	ra,8(sp)
 630:	e022                	sd	s0,0(sp)
 632:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 634:	4585                	li	a1,1
 636:	0b2000ef          	jal	6e8 <sys_sbrk>
}
 63a:	60a2                	ld	ra,8(sp)
 63c:	6402                	ld	s0,0(sp)
 63e:	0141                	addi	sp,sp,16
 640:	8082                	ret

0000000000000642 <sbrklazy>:

char *
sbrklazy(int n)
{
 642:	1141                	addi	sp,sp,-16
 644:	e406                	sd	ra,8(sp)
 646:	e022                	sd	s0,0(sp)
 648:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 64a:	4589                	li	a1,2
 64c:	09c000ef          	jal	6e8 <sys_sbrk>
}
 650:	60a2                	ld	ra,8(sp)
 652:	6402                	ld	s0,0(sp)
 654:	0141                	addi	sp,sp,16
 656:	8082                	ret

0000000000000658 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 658:	4885                	li	a7,1
 ecall
 65a:	00000073          	ecall
 ret
 65e:	8082                	ret

0000000000000660 <exit>:
.global exit
exit:
 li a7, SYS_exit
 660:	4889                	li	a7,2
 ecall
 662:	00000073          	ecall
 ret
 666:	8082                	ret

0000000000000668 <wait>:
.global wait
wait:
 li a7, SYS_wait
 668:	488d                	li	a7,3
 ecall
 66a:	00000073          	ecall
 ret
 66e:	8082                	ret

0000000000000670 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 670:	4891                	li	a7,4
 ecall
 672:	00000073          	ecall
 ret
 676:	8082                	ret

0000000000000678 <read>:
.global read
read:
 li a7, SYS_read
 678:	4895                	li	a7,5
 ecall
 67a:	00000073          	ecall
 ret
 67e:	8082                	ret

0000000000000680 <write>:
.global write
write:
 li a7, SYS_write
 680:	48c1                	li	a7,16
 ecall
 682:	00000073          	ecall
 ret
 686:	8082                	ret

0000000000000688 <close>:
.global close
close:
 li a7, SYS_close
 688:	48d5                	li	a7,21
 ecall
 68a:	00000073          	ecall
 ret
 68e:	8082                	ret

0000000000000690 <kill>:
.global kill
kill:
 li a7, SYS_kill
 690:	4899                	li	a7,6
 ecall
 692:	00000073          	ecall
 ret
 696:	8082                	ret

0000000000000698 <exec>:
.global exec
exec:
 li a7, SYS_exec
 698:	489d                	li	a7,7
 ecall
 69a:	00000073          	ecall
 ret
 69e:	8082                	ret

00000000000006a0 <open>:
.global open
open:
 li a7, SYS_open
 6a0:	48bd                	li	a7,15
 ecall
 6a2:	00000073          	ecall
 ret
 6a6:	8082                	ret

00000000000006a8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 6a8:	48c5                	li	a7,17
 ecall
 6aa:	00000073          	ecall
 ret
 6ae:	8082                	ret

00000000000006b0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 6b0:	48c9                	li	a7,18
 ecall
 6b2:	00000073          	ecall
 ret
 6b6:	8082                	ret

00000000000006b8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 6b8:	48a1                	li	a7,8
 ecall
 6ba:	00000073          	ecall
 ret
 6be:	8082                	ret

00000000000006c0 <link>:
.global link
link:
 li a7, SYS_link
 6c0:	48cd                	li	a7,19
 ecall
 6c2:	00000073          	ecall
 ret
 6c6:	8082                	ret

00000000000006c8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 6c8:	48d1                	li	a7,20
 ecall
 6ca:	00000073          	ecall
 ret
 6ce:	8082                	ret

00000000000006d0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 6d0:	48a5                	li	a7,9
 ecall
 6d2:	00000073          	ecall
 ret
 6d6:	8082                	ret

00000000000006d8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 6d8:	48a9                	li	a7,10
 ecall
 6da:	00000073          	ecall
 ret
 6de:	8082                	ret

00000000000006e0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 6e0:	48ad                	li	a7,11
 ecall
 6e2:	00000073          	ecall
 ret
 6e6:	8082                	ret

00000000000006e8 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 6e8:	48b1                	li	a7,12
 ecall
 6ea:	00000073          	ecall
 ret
 6ee:	8082                	ret

00000000000006f0 <pause>:
.global pause
pause:
 li a7, SYS_pause
 6f0:	48b5                	li	a7,13
 ecall
 6f2:	00000073          	ecall
 ret
 6f6:	8082                	ret

00000000000006f8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 6f8:	48b9                	li	a7,14
 ecall
 6fa:	00000073          	ecall
 ret
 6fe:	8082                	ret

0000000000000700 <sync>:
.global sync
sync:
 li a7, SYS_sync
 700:	48d9                	li	a7,22
 ecall
 702:	00000073          	ecall
 ret
 706:	8082                	ret

0000000000000708 <shm_get>:
.global shm_get
shm_get:
 li a7, SYS_shm_get
 708:	48dd                	li	a7,23
 ecall
 70a:	00000073          	ecall
 ret
 70e:	8082                	ret

0000000000000710 <sem_init>:
.global sem_init
sem_init:
 li a7, SYS_sem_init
 710:	48e1                	li	a7,24
 ecall
 712:	00000073          	ecall
 ret
 716:	8082                	ret

0000000000000718 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 718:	48e5                	li	a7,25
 ecall
 71a:	00000073          	ecall
 ret
 71e:	8082                	ret

0000000000000720 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 720:	48e9                	li	a7,26
 ecall
 722:	00000073          	ecall
 ret
 726:	8082                	ret

0000000000000728 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 728:	1101                	addi	sp,sp,-32
 72a:	ec06                	sd	ra,24(sp)
 72c:	e822                	sd	s0,16(sp)
 72e:	1000                	addi	s0,sp,32
 730:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 734:	4605                	li	a2,1
 736:	fef40593          	addi	a1,s0,-17
 73a:	f47ff0ef          	jal	680 <write>
}
 73e:	60e2                	ld	ra,24(sp)
 740:	6442                	ld	s0,16(sp)
 742:	6105                	addi	sp,sp,32
 744:	8082                	ret

0000000000000746 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 746:	715d                	addi	sp,sp,-80
 748:	e486                	sd	ra,72(sp)
 74a:	e0a2                	sd	s0,64(sp)
 74c:	f84a                	sd	s2,48(sp)
 74e:	f44e                	sd	s3,40(sp)
 750:	0880                	addi	s0,sp,80
 752:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 754:	c6d1                	beqz	a3,7e0 <printint+0x9a>
 756:	0805d563          	bgez	a1,7e0 <printint+0x9a>
    neg = 1;
    x = -xx;
 75a:	40b005b3          	neg	a1,a1
    neg = 1;
 75e:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 760:	fb840993          	addi	s3,s0,-72
  neg = 0;
 764:	86ce                	mv	a3,s3
  i = 0;
 766:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 768:	00001817          	auipc	a6,0x1
 76c:	94880813          	addi	a6,a6,-1720 # 10b0 <digits>
 770:	88ba                	mv	a7,a4
 772:	0017051b          	addiw	a0,a4,1
 776:	872a                	mv	a4,a0
 778:	02c5f7b3          	remu	a5,a1,a2
 77c:	97c2                	add	a5,a5,a6
 77e:	0007c783          	lbu	a5,0(a5)
 782:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 786:	87ae                	mv	a5,a1
 788:	02c5d5b3          	divu	a1,a1,a2
 78c:	0685                	addi	a3,a3,1
 78e:	fec7f1e3          	bgeu	a5,a2,770 <printint+0x2a>
  if (neg)
 792:	00030c63          	beqz	t1,7aa <printint+0x64>
    buf[i++] = '-';
 796:	fd050793          	addi	a5,a0,-48
 79a:	00878533          	add	a0,a5,s0
 79e:	02d00793          	li	a5,45
 7a2:	fef50423          	sb	a5,-24(a0)
 7a6:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 7aa:	02e05563          	blez	a4,7d4 <printint+0x8e>
 7ae:	fc26                	sd	s1,56(sp)
 7b0:	377d                	addiw	a4,a4,-1
 7b2:	00e984b3          	add	s1,s3,a4
 7b6:	19fd                	addi	s3,s3,-1
 7b8:	99ba                	add	s3,s3,a4
 7ba:	1702                	slli	a4,a4,0x20
 7bc:	9301                	srli	a4,a4,0x20
 7be:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 7c2:	0004c583          	lbu	a1,0(s1)
 7c6:	854a                	mv	a0,s2
 7c8:	f61ff0ef          	jal	728 <putc>
  while (--i >= 0)
 7cc:	14fd                	addi	s1,s1,-1
 7ce:	ff349ae3          	bne	s1,s3,7c2 <printint+0x7c>
 7d2:	74e2                	ld	s1,56(sp)
}
 7d4:	60a6                	ld	ra,72(sp)
 7d6:	6406                	ld	s0,64(sp)
 7d8:	7942                	ld	s2,48(sp)
 7da:	79a2                	ld	s3,40(sp)
 7dc:	6161                	addi	sp,sp,80
 7de:	8082                	ret
  neg = 0;
 7e0:	4301                	li	t1,0
 7e2:	bfbd                	j	760 <printint+0x1a>

00000000000007e4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 7e4:	711d                	addi	sp,sp,-96
 7e6:	ec86                	sd	ra,88(sp)
 7e8:	e8a2                	sd	s0,80(sp)
 7ea:	e4a6                	sd	s1,72(sp)
 7ec:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 7ee:	0005c483          	lbu	s1,0(a1)
 7f2:	22048363          	beqz	s1,a18 <vprintf+0x234>
 7f6:	e0ca                	sd	s2,64(sp)
 7f8:	fc4e                	sd	s3,56(sp)
 7fa:	f852                	sd	s4,48(sp)
 7fc:	f456                	sd	s5,40(sp)
 7fe:	f05a                	sd	s6,32(sp)
 800:	ec5e                	sd	s7,24(sp)
 802:	e862                	sd	s8,16(sp)
 804:	8b2a                	mv	s6,a0
 806:	8a2e                	mv	s4,a1
 808:	8bb2                	mv	s7,a2
  state = 0;
 80a:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 80c:	4901                	li	s2,0
 80e:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 810:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 814:	06400c13          	li	s8,100
 818:	a00d                	j	83a <vprintf+0x56>
        putc(fd, c0);
 81a:	85a6                	mv	a1,s1
 81c:	855a                	mv	a0,s6
 81e:	f0bff0ef          	jal	728 <putc>
 822:	a019                	j	828 <vprintf+0x44>
    } else if (state == '%') {
 824:	03598363          	beq	s3,s5,84a <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 828:	0019079b          	addiw	a5,s2,1
 82c:	893e                	mv	s2,a5
 82e:	873e                	mv	a4,a5
 830:	97d2                	add	a5,a5,s4
 832:	0007c483          	lbu	s1,0(a5)
 836:	1c048a63          	beqz	s1,a0a <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 83a:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 83e:	fe0993e3          	bnez	s3,824 <vprintf+0x40>
      if (c0 == '%') {
 842:	fd579ce3          	bne	a5,s5,81a <vprintf+0x36>
        state = '%';
 846:	89be                	mv	s3,a5
 848:	b7c5                	j	828 <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 84a:	00ea06b3          	add	a3,s4,a4
 84e:	0016c603          	lbu	a2,1(a3)
      if (c1)
 852:	1c060863          	beqz	a2,a22 <vprintf+0x23e>
      if (c0 == 'd') {
 856:	03878763          	beq	a5,s8,884 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 85a:	f9478693          	addi	a3,a5,-108
 85e:	0016b693          	seqz	a3,a3
 862:	f9c60593          	addi	a1,a2,-100
 866:	e99d                	bnez	a1,89c <vprintf+0xb8>
 868:	ca95                	beqz	a3,89c <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 86a:	008b8493          	addi	s1,s7,8
 86e:	4685                	li	a3,1
 870:	4629                	li	a2,10
 872:	000bb583          	ld	a1,0(s7)
 876:	855a                	mv	a0,s6
 878:	ecfff0ef          	jal	746 <printint>
        i += 1;
 87c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 87e:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 880:	4981                	li	s3,0
 882:	b75d                	j	828 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 884:	008b8493          	addi	s1,s7,8
 888:	4685                	li	a3,1
 88a:	4629                	li	a2,10
 88c:	000ba583          	lw	a1,0(s7)
 890:	855a                	mv	a0,s6
 892:	eb5ff0ef          	jal	746 <printint>
 896:	8ba6                	mv	s7,s1
      state = 0;
 898:	4981                	li	s3,0
 89a:	b779                	j	828 <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 89c:	9752                	add	a4,a4,s4
 89e:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 8a2:	f9460713          	addi	a4,a2,-108
 8a6:	00173713          	seqz	a4,a4
 8aa:	8f75                	and	a4,a4,a3
 8ac:	f9c58513          	addi	a0,a1,-100
 8b0:	18051363          	bnez	a0,a36 <vprintf+0x252>
 8b4:	18070163          	beqz	a4,a36 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 8b8:	008b8493          	addi	s1,s7,8
 8bc:	4685                	li	a3,1
 8be:	4629                	li	a2,10
 8c0:	000bb583          	ld	a1,0(s7)
 8c4:	855a                	mv	a0,s6
 8c6:	e81ff0ef          	jal	746 <printint>
        i += 2;
 8ca:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 8cc:	8ba6                	mv	s7,s1
      state = 0;
 8ce:	4981                	li	s3,0
        i += 2;
 8d0:	bfa1                	j	828 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 8d2:	008b8493          	addi	s1,s7,8
 8d6:	4681                	li	a3,0
 8d8:	4629                	li	a2,10
 8da:	000be583          	lwu	a1,0(s7)
 8de:	855a                	mv	a0,s6
 8e0:	e67ff0ef          	jal	746 <printint>
 8e4:	8ba6                	mv	s7,s1
      state = 0;
 8e6:	4981                	li	s3,0
 8e8:	b781                	j	828 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8ea:	008b8493          	addi	s1,s7,8
 8ee:	4681                	li	a3,0
 8f0:	4629                	li	a2,10
 8f2:	000bb583          	ld	a1,0(s7)
 8f6:	855a                	mv	a0,s6
 8f8:	e4fff0ef          	jal	746 <printint>
        i += 1;
 8fc:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 8fe:	8ba6                	mv	s7,s1
      state = 0;
 900:	4981                	li	s3,0
 902:	b71d                	j	828 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 904:	008b8493          	addi	s1,s7,8
 908:	4681                	li	a3,0
 90a:	4629                	li	a2,10
 90c:	000bb583          	ld	a1,0(s7)
 910:	855a                	mv	a0,s6
 912:	e35ff0ef          	jal	746 <printint>
        i += 2;
 916:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 918:	8ba6                	mv	s7,s1
      state = 0;
 91a:	4981                	li	s3,0
        i += 2;
 91c:	b731                	j	828 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 91e:	008b8493          	addi	s1,s7,8
 922:	4681                	li	a3,0
 924:	4641                	li	a2,16
 926:	000be583          	lwu	a1,0(s7)
 92a:	855a                	mv	a0,s6
 92c:	e1bff0ef          	jal	746 <printint>
 930:	8ba6                	mv	s7,s1
      state = 0;
 932:	4981                	li	s3,0
 934:	bdd5                	j	828 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 936:	008b8493          	addi	s1,s7,8
 93a:	4681                	li	a3,0
 93c:	4641                	li	a2,16
 93e:	000bb583          	ld	a1,0(s7)
 942:	855a                	mv	a0,s6
 944:	e03ff0ef          	jal	746 <printint>
        i += 1;
 948:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 94a:	8ba6                	mv	s7,s1
      state = 0;
 94c:	4981                	li	s3,0
 94e:	bde9                	j	828 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 950:	008b8493          	addi	s1,s7,8
 954:	4681                	li	a3,0
 956:	4641                	li	a2,16
 958:	000bb583          	ld	a1,0(s7)
 95c:	855a                	mv	a0,s6
 95e:	de9ff0ef          	jal	746 <printint>
        i += 2;
 962:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 964:	8ba6                	mv	s7,s1
      state = 0;
 966:	4981                	li	s3,0
        i += 2;
 968:	b5c1                	j	828 <vprintf+0x44>
 96a:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 96c:	008b8793          	addi	a5,s7,8
 970:	8cbe                	mv	s9,a5
 972:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 976:	03000593          	li	a1,48
 97a:	855a                	mv	a0,s6
 97c:	dadff0ef          	jal	728 <putc>
  putc(fd, 'x');
 980:	07800593          	li	a1,120
 984:	855a                	mv	a0,s6
 986:	da3ff0ef          	jal	728 <putc>
 98a:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 98c:	00000b97          	auipc	s7,0x0
 990:	724b8b93          	addi	s7,s7,1828 # 10b0 <digits>
 994:	03c9d793          	srli	a5,s3,0x3c
 998:	97de                	add	a5,a5,s7
 99a:	0007c583          	lbu	a1,0(a5)
 99e:	855a                	mv	a0,s6
 9a0:	d89ff0ef          	jal	728 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 9a4:	0992                	slli	s3,s3,0x4
 9a6:	34fd                	addiw	s1,s1,-1
 9a8:	f4f5                	bnez	s1,994 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 9aa:	8be6                	mv	s7,s9
      state = 0;
 9ac:	4981                	li	s3,0
 9ae:	6ca2                	ld	s9,8(sp)
 9b0:	bda5                	j	828 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 9b2:	008b8493          	addi	s1,s7,8
 9b6:	000bc583          	lbu	a1,0(s7)
 9ba:	855a                	mv	a0,s6
 9bc:	d6dff0ef          	jal	728 <putc>
 9c0:	8ba6                	mv	s7,s1
      state = 0;
 9c2:	4981                	li	s3,0
 9c4:	b595                	j	828 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 9c6:	008b8993          	addi	s3,s7,8
 9ca:	000bb483          	ld	s1,0(s7)
 9ce:	cc91                	beqz	s1,9ea <vprintf+0x206>
        for (; *s; s++)
 9d0:	0004c583          	lbu	a1,0(s1)
 9d4:	c985                	beqz	a1,a04 <vprintf+0x220>
          putc(fd, *s);
 9d6:	855a                	mv	a0,s6
 9d8:	d51ff0ef          	jal	728 <putc>
        for (; *s; s++)
 9dc:	0485                	addi	s1,s1,1
 9de:	0004c583          	lbu	a1,0(s1)
 9e2:	f9f5                	bnez	a1,9d6 <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 9e4:	8bce                	mv	s7,s3
      state = 0;
 9e6:	4981                	li	s3,0
 9e8:	b581                	j	828 <vprintf+0x44>
          s = "(null)";
 9ea:	00000497          	auipc	s1,0x0
 9ee:	6be48493          	addi	s1,s1,1726 # 10a8 <malloc+0x522>
        for (; *s; s++)
 9f2:	02800593          	li	a1,40
 9f6:	b7c5                	j	9d6 <vprintf+0x1f2>
        putc(fd, '%');
 9f8:	85be                	mv	a1,a5
 9fa:	855a                	mv	a0,s6
 9fc:	d2dff0ef          	jal	728 <putc>
      state = 0;
 a00:	4981                	li	s3,0
 a02:	b51d                	j	828 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 a04:	8bce                	mv	s7,s3
      state = 0;
 a06:	4981                	li	s3,0
 a08:	b505                	j	828 <vprintf+0x44>
 a0a:	6906                	ld	s2,64(sp)
 a0c:	79e2                	ld	s3,56(sp)
 a0e:	7a42                	ld	s4,48(sp)
 a10:	7aa2                	ld	s5,40(sp)
 a12:	7b02                	ld	s6,32(sp)
 a14:	6be2                	ld	s7,24(sp)
 a16:	6c42                	ld	s8,16(sp)
    }
  }
}
 a18:	60e6                	ld	ra,88(sp)
 a1a:	6446                	ld	s0,80(sp)
 a1c:	64a6                	ld	s1,72(sp)
 a1e:	6125                	addi	sp,sp,96
 a20:	8082                	ret
      if (c0 == 'd') {
 a22:	06400713          	li	a4,100
 a26:	e4e78fe3          	beq	a5,a4,884 <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 a2a:	f9478693          	addi	a3,a5,-108
 a2e:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 a32:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 a34:	4701                	li	a4,0
      } else if (c0 == 'u') {
 a36:	07500513          	li	a0,117
 a3a:	e8a78ce3          	beq	a5,a0,8d2 <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 a3e:	f8b60513          	addi	a0,a2,-117
 a42:	e119                	bnez	a0,a48 <vprintf+0x264>
 a44:	ea0693e3          	bnez	a3,8ea <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 a48:	f8b58513          	addi	a0,a1,-117
 a4c:	e119                	bnez	a0,a52 <vprintf+0x26e>
 a4e:	ea071be3          	bnez	a4,904 <vprintf+0x120>
      } else if (c0 == 'x') {
 a52:	07800513          	li	a0,120
 a56:	eca784e3          	beq	a5,a0,91e <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 a5a:	f8860613          	addi	a2,a2,-120
 a5e:	e219                	bnez	a2,a64 <vprintf+0x280>
 a60:	ec069be3          	bnez	a3,936 <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 a64:	f8858593          	addi	a1,a1,-120
 a68:	e199                	bnez	a1,a6e <vprintf+0x28a>
 a6a:	ee0713e3          	bnez	a4,950 <vprintf+0x16c>
      } else if (c0 == 'p') {
 a6e:	07000713          	li	a4,112
 a72:	eee78ce3          	beq	a5,a4,96a <vprintf+0x186>
      } else if (c0 == 'c') {
 a76:	06300713          	li	a4,99
 a7a:	f2e78ce3          	beq	a5,a4,9b2 <vprintf+0x1ce>
      } else if (c0 == 's') {
 a7e:	07300713          	li	a4,115
 a82:	f4e782e3          	beq	a5,a4,9c6 <vprintf+0x1e2>
      } else if (c0 == '%') {
 a86:	02500713          	li	a4,37
 a8a:	f6e787e3          	beq	a5,a4,9f8 <vprintf+0x214>
        putc(fd, '%');
 a8e:	02500593          	li	a1,37
 a92:	855a                	mv	a0,s6
 a94:	c95ff0ef          	jal	728 <putc>
        putc(fd, c0);
 a98:	85a6                	mv	a1,s1
 a9a:	855a                	mv	a0,s6
 a9c:	c8dff0ef          	jal	728 <putc>
      state = 0;
 aa0:	4981                	li	s3,0
 aa2:	b359                	j	828 <vprintf+0x44>

0000000000000aa4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 aa4:	715d                	addi	sp,sp,-80
 aa6:	ec06                	sd	ra,24(sp)
 aa8:	e822                	sd	s0,16(sp)
 aaa:	1000                	addi	s0,sp,32
 aac:	e010                	sd	a2,0(s0)
 aae:	e414                	sd	a3,8(s0)
 ab0:	e818                	sd	a4,16(s0)
 ab2:	ec1c                	sd	a5,24(s0)
 ab4:	03043023          	sd	a6,32(s0)
 ab8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 abc:	8622                	mv	a2,s0
 abe:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 ac2:	d23ff0ef          	jal	7e4 <vprintf>
}
 ac6:	60e2                	ld	ra,24(sp)
 ac8:	6442                	ld	s0,16(sp)
 aca:	6161                	addi	sp,sp,80
 acc:	8082                	ret

0000000000000ace <printf>:

void
printf(const char *fmt, ...)
{
 ace:	711d                	addi	sp,sp,-96
 ad0:	ec06                	sd	ra,24(sp)
 ad2:	e822                	sd	s0,16(sp)
 ad4:	1000                	addi	s0,sp,32
 ad6:	e40c                	sd	a1,8(s0)
 ad8:	e810                	sd	a2,16(s0)
 ada:	ec14                	sd	a3,24(s0)
 adc:	f018                	sd	a4,32(s0)
 ade:	f41c                	sd	a5,40(s0)
 ae0:	03043823          	sd	a6,48(s0)
 ae4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 ae8:	00840613          	addi	a2,s0,8
 aec:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 af0:	85aa                	mv	a1,a0
 af2:	4505                	li	a0,1
 af4:	cf1ff0ef          	jal	7e4 <vprintf>
}
 af8:	60e2                	ld	ra,24(sp)
 afa:	6442                	ld	s0,16(sp)
 afc:	6125                	addi	sp,sp,96
 afe:	8082                	ret

0000000000000b00 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b00:	1141                	addi	sp,sp,-16
 b02:	e406                	sd	ra,8(sp)
 b04:	e022                	sd	s0,0(sp)
 b06:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 b08:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b0c:	00001797          	auipc	a5,0x1
 b10:	4f47b783          	ld	a5,1268(a5) # 2000 <freep>
 b14:	a039                	j	b22 <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b16:	6398                	ld	a4,0(a5)
 b18:	00e7e463          	bltu	a5,a4,b20 <free+0x20>
 b1c:	00e6ea63          	bltu	a3,a4,b30 <free+0x30>
{
 b20:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b22:	fed7fae3          	bgeu	a5,a3,b16 <free+0x16>
 b26:	6398                	ld	a4,0(a5)
 b28:	00e6e463          	bltu	a3,a4,b30 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b2c:	fee7eae3          	bltu	a5,a4,b20 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 b30:	ff852583          	lw	a1,-8(a0)
 b34:	6390                	ld	a2,0(a5)
 b36:	02059813          	slli	a6,a1,0x20
 b3a:	01c85713          	srli	a4,a6,0x1c
 b3e:	9736                	add	a4,a4,a3
 b40:	02e60563          	beq	a2,a4,b6a <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 b44:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 b48:	4790                	lw	a2,8(a5)
 b4a:	02061593          	slli	a1,a2,0x20
 b4e:	01c5d713          	srli	a4,a1,0x1c
 b52:	973e                	add	a4,a4,a5
 b54:	02e68263          	beq	a3,a4,b78 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 b58:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 b5a:	00001717          	auipc	a4,0x1
 b5e:	4af73323          	sd	a5,1190(a4) # 2000 <freep>
}
 b62:	60a2                	ld	ra,8(sp)
 b64:	6402                	ld	s0,0(sp)
 b66:	0141                	addi	sp,sp,16
 b68:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 b6a:	4618                	lw	a4,8(a2)
 b6c:	9f2d                	addw	a4,a4,a1
 b6e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 b72:	6398                	ld	a4,0(a5)
 b74:	6310                	ld	a2,0(a4)
 b76:	b7f9                	j	b44 <free+0x44>
    p->s.size += bp->s.size;
 b78:	ff852703          	lw	a4,-8(a0)
 b7c:	9f31                	addw	a4,a4,a2
 b7e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 b80:	ff053683          	ld	a3,-16(a0)
 b84:	bfd1                	j	b58 <free+0x58>

0000000000000b86 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 b86:	7139                	addi	sp,sp,-64
 b88:	fc06                	sd	ra,56(sp)
 b8a:	f822                	sd	s0,48(sp)
 b8c:	f04a                	sd	s2,32(sp)
 b8e:	ec4e                	sd	s3,24(sp)
 b90:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 b92:	02051993          	slli	s3,a0,0x20
 b96:	0209d993          	srli	s3,s3,0x20
 b9a:	09bd                	addi	s3,s3,15
 b9c:	0049d993          	srli	s3,s3,0x4
 ba0:	2985                	addiw	s3,s3,1
 ba2:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 ba4:	00001517          	auipc	a0,0x1
 ba8:	45c53503          	ld	a0,1116(a0) # 2000 <freep>
 bac:	c905                	beqz	a0,bdc <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 bae:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 bb0:	4798                	lw	a4,8(a5)
 bb2:	09377663          	bgeu	a4,s3,c3e <malloc+0xb8>
 bb6:	f426                	sd	s1,40(sp)
 bb8:	e852                	sd	s4,16(sp)
 bba:	e456                	sd	s5,8(sp)
 bbc:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 bbe:	8a4e                	mv	s4,s3
 bc0:	6705                	lui	a4,0x1
 bc2:	00e9f363          	bgeu	s3,a4,bc8 <malloc+0x42>
 bc6:	6a05                	lui	s4,0x1
 bc8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 bcc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 bd0:	00001497          	auipc	s1,0x1
 bd4:	43048493          	addi	s1,s1,1072 # 2000 <freep>
  if (p == SBRK_ERROR)
 bd8:	5afd                	li	s5,-1
 bda:	a83d                	j	c18 <malloc+0x92>
 bdc:	f426                	sd	s1,40(sp)
 bde:	e852                	sd	s4,16(sp)
 be0:	e456                	sd	s5,8(sp)
 be2:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 be4:	00001797          	auipc	a5,0x1
 be8:	42c78793          	addi	a5,a5,1068 # 2010 <base>
 bec:	00001717          	auipc	a4,0x1
 bf0:	40f73a23          	sd	a5,1044(a4) # 2000 <freep>
 bf4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 bf6:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 bfa:	b7d1                	j	bbe <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 bfc:	6398                	ld	a4,0(a5)
 bfe:	e118                	sd	a4,0(a0)
 c00:	a899                	j	c56 <malloc+0xd0>
  hp->s.size = nu;
 c02:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 c06:	0541                	addi	a0,a0,16
 c08:	ef9ff0ef          	jal	b00 <free>
  return freep;
 c0c:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 c0e:	c125                	beqz	a0,c6e <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 c10:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 c12:	4798                	lw	a4,8(a5)
 c14:	03277163          	bgeu	a4,s2,c36 <malloc+0xb0>
    if (p == freep)
 c18:	6098                	ld	a4,0(s1)
 c1a:	853e                	mv	a0,a5
 c1c:	fef71ae3          	bne	a4,a5,c10 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 c20:	8552                	mv	a0,s4
 c22:	a0bff0ef          	jal	62c <sbrk>
  if (p == SBRK_ERROR)
 c26:	fd551ee3          	bne	a0,s5,c02 <malloc+0x7c>
        return 0;
 c2a:	4501                	li	a0,0
 c2c:	74a2                	ld	s1,40(sp)
 c2e:	6a42                	ld	s4,16(sp)
 c30:	6aa2                	ld	s5,8(sp)
 c32:	6b02                	ld	s6,0(sp)
 c34:	a03d                	j	c62 <malloc+0xdc>
 c36:	74a2                	ld	s1,40(sp)
 c38:	6a42                	ld	s4,16(sp)
 c3a:	6aa2                	ld	s5,8(sp)
 c3c:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 c3e:	fae90fe3          	beq	s2,a4,bfc <malloc+0x76>
        p->s.size -= nunits;
 c42:	4137073b          	subw	a4,a4,s3
 c46:	c798                	sw	a4,8(a5)
        p += p->s.size;
 c48:	02071693          	slli	a3,a4,0x20
 c4c:	01c6d713          	srli	a4,a3,0x1c
 c50:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c52:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c56:	00001717          	auipc	a4,0x1
 c5a:	3aa73523          	sd	a0,938(a4) # 2000 <freep>
      return (void *)(p + 1);
 c5e:	01078513          	addi	a0,a5,16
  }
}
 c62:	70e2                	ld	ra,56(sp)
 c64:	7442                	ld	s0,48(sp)
 c66:	7902                	ld	s2,32(sp)
 c68:	69e2                	ld	s3,24(sp)
 c6a:	6121                	addi	sp,sp,64
 c6c:	8082                	ret
 c6e:	74a2                	ld	s1,40(sp)
 c70:	6a42                	ld	s4,16(sp)
 c72:	6aa2                	ld	s5,8(sp)
 c74:	6b02                	ld	s6,0(sp)
 c76:	b7f5                	j	c62 <malloc+0xdc>
