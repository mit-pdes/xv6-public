
user/_readwrite:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <reader>:
  int max_readers_seen;
  int total_writes;
  int violations;
};

void reader(struct rw_shared *sh, int id) {
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	ec56                	sd	s5,24(sp)
  10:	e85a                	sd	s6,16(sp)
  12:	e45e                	sd	s7,8(sp)
  14:	e062                	sd	s8,0(sp)
  16:	0880                	addi	s0,sp,80
  18:	84aa                	mv	s1,a0
  1a:	8aae                	mv	s5,a1
  printf("Reader %d started (pid %d)\n", id, getpid());
  1c:	704000ef          	jal	720 <getpid>
  20:	862a                	mv	a2,a0
  22:	85d6                	mv	a1,s5
  24:	00001517          	auipc	a0,0x1
  28:	c9c50513          	addi	a0,a0,-868 # cc0 <malloc+0xfa>
  2c:	2e3000ef          	jal	b0e <printf>
  30:	4a15                	li	s4,5

  for (int i = 0; i < READS_PER_READER; i++) {
    // Entry section
    sem_wait(SEM_MUTEX);
    sh->read_count++;
    if (sh->read_count == 1) {
  32:	4905                	li	s2,1
    }
    sem_post(SEM_MUTEX);

    // Reading Critical Section
    if (sh->active_writers > 0) {
      printf("VIOLATION: Reader [pid %d] reading while writer active!\n", getpid());
  34:	00001b97          	auipc	s7,0x1
  38:	cacb8b93          	addi	s7,s7,-852 # ce0 <malloc+0x11a>
      sh->violations++;
    }

    int val = sh->shared_data;
    printf("Reader %d [pid %d]: read shared_data = %d | active readers = %d\n",
  3c:	00001b17          	auipc	s6,0x1
  40:	ce4b0b13          	addi	s6,s6,-796 # d20 <malloc+0x15a>
  44:	a889                	j	96 <reader+0x96>
      sem_wait(SEM_WRT); // First reader locks out writers
  46:	854a                	mv	a0,s2
  48:	710000ef          	jal	758 <sem_wait>
  4c:	a8a9                	j	a6 <reader+0xa6>
    sem_post(SEM_MUTEX);
  4e:	4501                	li	a0,0
  50:	710000ef          	jal	760 <sem_post>
    if (sh->active_writers > 0) {
  54:	449c                	lw	a5,8(s1)
  56:	06f04063          	bgtz	a5,b6 <reader+0xb6>
    int val = sh->shared_data;
  5a:	0004ac03          	lw	s8,0(s1)
    printf("Reader %d [pid %d]: read shared_data = %d | active readers = %d\n",
  5e:	6c2000ef          	jal	720 <getpid>
  62:	862a                	mv	a2,a0
  64:	874e                	mv	a4,s3
  66:	86e2                	mv	a3,s8
  68:	85d6                	mv	a1,s5
  6a:	855a                	mv	a0,s6
  6c:	2a3000ef          	jal	b0e <printf>
           id, getpid(), val, cur_readers);

    pause(1); // simulate reading time & encourage concurrency
  70:	854a                	mv	a0,s2
  72:	6be000ef          	jal	730 <pause>

    // Exit section
    sem_wait(SEM_MUTEX);
  76:	4501                	li	a0,0
  78:	6e0000ef          	jal	758 <sem_wait>
    sh->read_count--;
  7c:	40dc                	lw	a5,4(s1)
  7e:	37fd                	addiw	a5,a5,-1
  80:	c0dc                	sw	a5,4(s1)
    if (sh->read_count == 0) {
  82:	c7a1                	beqz	a5,ca <reader+0xca>
      sem_post(SEM_WRT); // Last reader unlocks writers
    }
    sem_post(SEM_MUTEX);
  84:	4501                	li	a0,0
  86:	6da000ef          	jal	760 <sem_post>

    pause(1); // remainder delay
  8a:	854a                	mv	a0,s2
  8c:	6a4000ef          	jal	730 <pause>
  for (int i = 0; i < READS_PER_READER; i++) {
  90:	3a7d                	addiw	s4,s4,-1
  92:	040a0063          	beqz	s4,d2 <reader+0xd2>
    sem_wait(SEM_MUTEX);
  96:	4501                	li	a0,0
  98:	6c0000ef          	jal	758 <sem_wait>
    sh->read_count++;
  9c:	40dc                	lw	a5,4(s1)
  9e:	2785                	addiw	a5,a5,1
  a0:	c0dc                	sw	a5,4(s1)
    if (sh->read_count == 1) {
  a2:	fb2782e3          	beq	a5,s2,46 <reader+0x46>
    int cur_readers = sh->read_count;
  a6:	0044a983          	lw	s3,4(s1)
    if (cur_readers > sh->max_readers_seen) {
  aa:	44dc                	lw	a5,12(s1)
  ac:	fb37d1e3          	bge	a5,s3,4e <reader+0x4e>
      sh->max_readers_seen = cur_readers;
  b0:	0134a623          	sw	s3,12(s1)
  b4:	bf69                	j	4e <reader+0x4e>
      printf("VIOLATION: Reader [pid %d] reading while writer active!\n", getpid());
  b6:	66a000ef          	jal	720 <getpid>
  ba:	85aa                	mv	a1,a0
  bc:	855e                	mv	a0,s7
  be:	251000ef          	jal	b0e <printf>
      sh->violations++;
  c2:	48dc                	lw	a5,20(s1)
  c4:	2785                	addiw	a5,a5,1
  c6:	c8dc                	sw	a5,20(s1)
  c8:	bf49                	j	5a <reader+0x5a>
      sem_post(SEM_WRT); // Last reader unlocks writers
  ca:	854a                	mv	a0,s2
  cc:	694000ef          	jal	760 <sem_post>
  d0:	bf55                	j	84 <reader+0x84>
  }

  printf("Reader %d [pid %d] finished all %d reads.\n", id, getpid(), READS_PER_READER);
  d2:	64e000ef          	jal	720 <getpid>
  d6:	862a                	mv	a2,a0
  d8:	4695                	li	a3,5
  da:	85d6                	mv	a1,s5
  dc:	00001517          	auipc	a0,0x1
  e0:	c8c50513          	addi	a0,a0,-884 # d68 <malloc+0x1a2>
  e4:	22b000ef          	jal	b0e <printf>
}
  e8:	60a6                	ld	ra,72(sp)
  ea:	6406                	ld	s0,64(sp)
  ec:	74e2                	ld	s1,56(sp)
  ee:	7942                	ld	s2,48(sp)
  f0:	79a2                	ld	s3,40(sp)
  f2:	7a02                	ld	s4,32(sp)
  f4:	6ae2                	ld	s5,24(sp)
  f6:	6b42                	ld	s6,16(sp)
  f8:	6ba2                	ld	s7,8(sp)
  fa:	6c02                	ld	s8,0(sp)
  fc:	6161                	addi	sp,sp,80
  fe:	8082                	ret

0000000000000100 <writer>:

void writer(struct rw_shared *sh, int id) {
 100:	711d                	addi	sp,sp,-96
 102:	ec86                	sd	ra,88(sp)
 104:	e8a2                	sd	s0,80(sp)
 106:	e4a6                	sd	s1,72(sp)
 108:	e0ca                	sd	s2,64(sp)
 10a:	fc4e                	sd	s3,56(sp)
 10c:	f852                	sd	s4,48(sp)
 10e:	f456                	sd	s5,40(sp)
 110:	f05a                	sd	s6,32(sp)
 112:	ec5e                	sd	s7,24(sp)
 114:	e862                	sd	s8,16(sp)
 116:	e466                	sd	s9,8(sp)
 118:	1080                	addi	s0,sp,96
 11a:	84aa                	mv	s1,a0
 11c:	8aae                	mv	s5,a1
  printf("Writer %d started (pid %d)\n", id, getpid());
 11e:	602000ef          	jal	720 <getpid>
 122:	862a                	mv	a2,a0
 124:	85d6                	mv	a1,s5
 126:	00001517          	auipc	a0,0x1
 12a:	c7250513          	addi	a0,a0,-910 # d98 <malloc+0x1d2>
 12e:	1e1000ef          	jal	b0e <printf>
 132:	4a15                	li	s4,5

  for (int i = 0; i < WRITES_PER_WRITER; i++) {
    // Entry section: request exclusive lock
    sem_wait(SEM_WRT);
 134:	4985                	li	s3,1
    // Writing Critical Section
    sh->active_writers++;

    // Assert mutual exclusion
    if (sh->read_count != 0) {
      printf("VIOLATION: Writer [pid %d] writing while %d readers active!\n",
 136:	00001c97          	auipc	s9,0x1
 13a:	c82c8c93          	addi	s9,s9,-894 # db8 <malloc+0x1f2>
             getpid(), sh->read_count);
      sh->violations++;
    }
    if (sh->active_writers > 1) {
      printf("VIOLATION: Multiple writers active simultaneously (%d)!\n",
 13e:	00001c17          	auipc	s8,0x1
 142:	cbac0c13          	addi	s8,s8,-838 # df8 <malloc+0x232>

    sh->shared_data++;
    sh->total_writes++;
    int new_val = sh->shared_data;

    printf("Writer %d [pid %d]: wrote shared_data = %d | active readers = %d, active writers = %d\n",
 146:	00001b97          	auipc	s7,0x1
 14a:	cf2b8b93          	addi	s7,s7,-782 # e38 <malloc+0x272>
    sh->active_writers--;

    // Exit section: release exclusive lock
    sem_post(SEM_WRT);

    pause(2); // remainder delay to give readers opportunities
 14e:	4b09                	li	s6,2
 150:	a8a9                	j	1aa <writer+0xaa>
      printf("VIOLATION: Writer [pid %d] writing while %d readers active!\n",
 152:	5ce000ef          	jal	720 <getpid>
 156:	85aa                	mv	a1,a0
 158:	40d0                	lw	a2,4(s1)
 15a:	8566                	mv	a0,s9
 15c:	1b3000ef          	jal	b0e <printf>
      sh->violations++;
 160:	48dc                	lw	a5,20(s1)
 162:	2785                	addiw	a5,a5,1
 164:	c8dc                	sw	a5,20(s1)
 166:	a891                	j	1ba <writer+0xba>
    sh->shared_data++;
 168:	0004a903          	lw	s2,0(s1)
 16c:	2905                	addiw	s2,s2,1
 16e:	0124a023          	sw	s2,0(s1)
    sh->total_writes++;
 172:	489c                	lw	a5,16(s1)
 174:	2785                	addiw	a5,a5,1
 176:	c89c                	sw	a5,16(s1)
    printf("Writer %d [pid %d]: wrote shared_data = %d | active readers = %d, active writers = %d\n",
 178:	5a8000ef          	jal	720 <getpid>
 17c:	862a                	mv	a2,a0
 17e:	449c                	lw	a5,8(s1)
 180:	40d8                	lw	a4,4(s1)
 182:	86ca                	mv	a3,s2
 184:	85d6                	mv	a1,s5
 186:	855e                	mv	a0,s7
 188:	187000ef          	jal	b0e <printf>
    pause(1); // simulate write duration
 18c:	854e                	mv	a0,s3
 18e:	5a2000ef          	jal	730 <pause>
    sh->active_writers--;
 192:	449c                	lw	a5,8(s1)
 194:	37fd                	addiw	a5,a5,-1
 196:	c49c                	sw	a5,8(s1)
    sem_post(SEM_WRT);
 198:	854e                	mv	a0,s3
 19a:	5c6000ef          	jal	760 <sem_post>
    pause(2); // remainder delay to give readers opportunities
 19e:	855a                	mv	a0,s6
 1a0:	590000ef          	jal	730 <pause>
  for (int i = 0; i < WRITES_PER_WRITER; i++) {
 1a4:	3a7d                	addiw	s4,s4,-1
 1a6:	020a0463          	beqz	s4,1ce <writer+0xce>
    sem_wait(SEM_WRT);
 1aa:	854e                	mv	a0,s3
 1ac:	5ac000ef          	jal	758 <sem_wait>
    sh->active_writers++;
 1b0:	449c                	lw	a5,8(s1)
 1b2:	2785                	addiw	a5,a5,1
 1b4:	c49c                	sw	a5,8(s1)
    if (sh->read_count != 0) {
 1b6:	40dc                	lw	a5,4(s1)
 1b8:	ffc9                	bnez	a5,152 <writer+0x52>
    if (sh->active_writers > 1) {
 1ba:	448c                	lw	a1,8(s1)
 1bc:	fab9d6e3          	bge	s3,a1,168 <writer+0x68>
      printf("VIOLATION: Multiple writers active simultaneously (%d)!\n",
 1c0:	8562                	mv	a0,s8
 1c2:	14d000ef          	jal	b0e <printf>
      sh->violations++;
 1c6:	48dc                	lw	a5,20(s1)
 1c8:	2785                	addiw	a5,a5,1
 1ca:	c8dc                	sw	a5,20(s1)
 1cc:	bf71                	j	168 <writer+0x68>
  }

  printf("Writer %d [pid %d] finished all %d writes.\n", id, getpid(), WRITES_PER_WRITER);
 1ce:	552000ef          	jal	720 <getpid>
 1d2:	862a                	mv	a2,a0
 1d4:	4695                	li	a3,5
 1d6:	85d6                	mv	a1,s5
 1d8:	00001517          	auipc	a0,0x1
 1dc:	cb850513          	addi	a0,a0,-840 # e90 <malloc+0x2ca>
 1e0:	12f000ef          	jal	b0e <printf>
}
 1e4:	60e6                	ld	ra,88(sp)
 1e6:	6446                	ld	s0,80(sp)
 1e8:	64a6                	ld	s1,72(sp)
 1ea:	6906                	ld	s2,64(sp)
 1ec:	79e2                	ld	s3,56(sp)
 1ee:	7a42                	ld	s4,48(sp)
 1f0:	7aa2                	ld	s5,40(sp)
 1f2:	7b02                	ld	s6,32(sp)
 1f4:	6be2                	ld	s7,24(sp)
 1f6:	6c42                	ld	s8,16(sp)
 1f8:	6ca2                	ld	s9,8(sp)
 1fa:	6125                	addi	sp,sp,96
 1fc:	8082                	ret

00000000000001fe <main>:

int main(int argc, char *argv[]) {
 1fe:	7179                	addi	sp,sp,-48
 200:	f406                	sd	ra,40(sp)
 202:	f022                	sd	s0,32(sp)
 204:	1800                	addi	s0,sp,48
  printf("============================================================\n");
 206:	00001517          	auipc	a0,0x1
 20a:	cba50513          	addi	a0,a0,-838 # ec0 <malloc+0x2fa>
 20e:	101000ef          	jal	b0e <printf>
  printf("Readers-Writers Problem Simulation (Readers-Preference)\n");
 212:	00001517          	auipc	a0,0x1
 216:	cee50513          	addi	a0,a0,-786 # f00 <malloc+0x33a>
 21a:	0f5000ef          	jal	b0e <printf>
  printf("Readers = %d, Writers = %d\n", NUM_READERS, NUM_WRITERS);
 21e:	4609                	li	a2,2
 220:	458d                	li	a1,3
 222:	00001517          	auipc	a0,0x1
 226:	d1e50513          	addi	a0,a0,-738 # f40 <malloc+0x37a>
 22a:	0e5000ef          	jal	b0e <printf>
  printf("Reads per reader = %d, Writes per writer = %d\n",
 22e:	4615                	li	a2,5
 230:	85b2                	mv	a1,a2
 232:	00001517          	auipc	a0,0x1
 236:	d2e50513          	addi	a0,a0,-722 # f60 <malloc+0x39a>
 23a:	0d5000ef          	jal	b0e <printf>
         READS_PER_READER, WRITES_PER_WRITER);
  printf("============================================================\n");
 23e:	00001517          	auipc	a0,0x1
 242:	c8250513          	addi	a0,a0,-894 # ec0 <malloc+0x2fa>
 246:	0c9000ef          	jal	b0e <printf>

  // Obtain shared memory page
  struct rw_shared *sh = (struct rw_shared *)shm_get();
 24a:	4fe000ef          	jal	748 <shm_get>
  if (sh == 0) {
 24e:	0e050f63          	beqz	a0,34c <main+0x14e>
 252:	ec26                	sd	s1,24(sp)
 254:	e84a                	sd	s2,16(sp)
 256:	e44e                	sd	s3,8(sp)
 258:	84aa                	mv	s1,a0
    printf("Error: shm_get failed\n");
    exit(1);
  }

  // Initialize shared state
  sh->shared_data = 0;
 25a:	00052023          	sw	zero,0(a0)
  sh->read_count = 0;
 25e:	00052223          	sw	zero,4(a0)
  sh->active_writers = 0;
 262:	00052423          	sw	zero,8(a0)
  sh->max_readers_seen = 0;
 266:	00052623          	sw	zero,12(a0)
  sh->total_writes = 0;
 26a:	00052823          	sw	zero,16(a0)
  sh->violations = 0;
 26e:	00052a23          	sw	zero,20(a0)

  // Initialize semaphores
  // SEM_MUTEX (0) = 1 protects read_count
  // SEM_WRT   (1) = 1 protects writing critical section
  if (sem_init(SEM_MUTEX, 1) < 0 || sem_init(SEM_WRT, 1) < 0) {
 272:	4585                	li	a1,1
 274:	4501                	li	a0,0
 276:	4da000ef          	jal	750 <sem_init>
 27a:	0e054563          	bltz	a0,364 <main+0x166>
 27e:	4585                	li	a1,1
 280:	852e                	mv	a0,a1
 282:	4ce000ef          	jal	750 <sem_init>
    printf("Error: sem_init failed\n");
    exit(1);
  }

  // Fork readers
  for (int i = 1; i <= NUM_READERS; i++) {
 286:	4905                	li	s2,1
 288:	4991                	li	s3,4
  if (sem_init(SEM_MUTEX, 1) < 0 || sem_init(SEM_WRT, 1) < 0) {
 28a:	0c054d63          	bltz	a0,364 <main+0x166>
    int pid = fork();
 28e:	40a000ef          	jal	698 <fork>
    if (pid < 0) {
 292:	0e054263          	bltz	a0,376 <main+0x178>
      printf("fork reader failed\n");
      exit(1);
    }
    if (pid == 0) {
 296:	0e050963          	beqz	a0,388 <main+0x18a>
  for (int i = 1; i <= NUM_READERS; i++) {
 29a:	2905                	addiw	s2,s2,1
 29c:	ff3919e3          	bne	s2,s3,28e <main+0x90>
    }
  }

  // Fork writers
  for (int i = 1; i <= NUM_WRITERS; i++) {
    int pid = fork();
 2a0:	3f8000ef          	jal	698 <fork>
    if (pid < 0) {
 2a4:	0e054963          	bltz	a0,396 <main+0x198>
      printf("fork writer failed\n");
      exit(1);
    }
    if (pid == 0) {
 2a8:	10050063          	beqz	a0,3a8 <main+0x1aa>
    int pid = fork();
 2ac:	3ec000ef          	jal	698 <fork>
    if (pid < 0) {
 2b0:	0e054363          	bltz	a0,396 <main+0x198>
    if (pid == 0) {
 2b4:	4915                	li	s2,5
 2b6:	4589                	li	a1,2
 2b8:	0e050963          	beqz	a0,3aa <main+0x1ac>
  }

  // Wait for all reader and writer processes
  int total_children = NUM_READERS + NUM_WRITERS;
  for (int i = 0; i < total_children; i++) {
    wait(0);
 2bc:	4501                	li	a0,0
 2be:	3ea000ef          	jal	6a8 <wait>
  for (int i = 0; i < total_children; i++) {
 2c2:	397d                	addiw	s2,s2,-1
 2c4:	fe091ce3          	bnez	s2,2bc <main+0xbe>
  }

  int expected_final_data = NUM_WRITERS * WRITES_PER_WRITER;

  printf("============================================================\n");
 2c8:	00001517          	auipc	a0,0x1
 2cc:	bf850513          	addi	a0,a0,-1032 # ec0 <malloc+0x2fa>
 2d0:	03f000ef          	jal	b0e <printf>
  printf("Simulation Finished Summary:\n");
 2d4:	00001517          	auipc	a0,0x1
 2d8:	d1c50513          	addi	a0,a0,-740 # ff0 <malloc+0x42a>
 2dc:	033000ef          	jal	b0e <printf>
  printf("Final shared_data value: %d (Expected: %d)\n",
 2e0:	4629                	li	a2,10
 2e2:	408c                	lw	a1,0(s1)
 2e4:	00001517          	auipc	a0,0x1
 2e8:	d2c50513          	addi	a0,a0,-724 # 1010 <malloc+0x44a>
 2ec:	023000ef          	jal	b0e <printf>
         sh->shared_data, expected_final_data);
  printf("Total writes recorded: %d\n", sh->total_writes);
 2f0:	488c                	lw	a1,16(s1)
 2f2:	00001517          	auipc	a0,0x1
 2f6:	d4e50513          	addi	a0,a0,-690 # 1040 <malloc+0x47a>
 2fa:	015000ef          	jal	b0e <printf>
  printf("Max concurrent readers observed: %d\n", sh->max_readers_seen);
 2fe:	44cc                	lw	a1,12(s1)
 300:	00001517          	auipc	a0,0x1
 304:	d6050513          	addi	a0,a0,-672 # 1060 <malloc+0x49a>
 308:	007000ef          	jal	b0e <printf>
  printf("Synchronization violations: %d\n", sh->violations);
 30c:	48cc                	lw	a1,20(s1)
 30e:	00001517          	auipc	a0,0x1
 312:	d7a50513          	addi	a0,a0,-646 # 1088 <malloc+0x4c2>
 316:	7f8000ef          	jal	b0e <printf>

  if (sh->shared_data == expected_final_data &&
 31a:	4098                	lw	a4,0(s1)
 31c:	47a9                	li	a5,10
 31e:	00f71863          	bne	a4,a5,32e <main+0x130>
 322:	48dc                	lw	a5,20(s1)
 324:	e789                	bnez	a5,32e <main+0x130>
      sh->violations == 0 &&
 326:	44d8                	lw	a4,12(s1)
 328:	4785                	li	a5,1
 32a:	08e7c663          	blt	a5,a4,3b6 <main+0x1b8>
    printf("SUCCESS:\n");
    printf("  1. Multiple readers read simultaneously (max = %d).\n", sh->max_readers_seen);
    printf("  2. Writers had exclusive access (read_count = 0 and active_writers = 1).\n");
    printf("  3. No lost updates or race conditions occurred.\n");
  } else {
    printf("FAILURE: Synchronization assertions failed!\n");
 32e:	00001517          	auipc	a0,0x1
 332:	e4a50513          	addi	a0,a0,-438 # 1178 <malloc+0x5b2>
 336:	7d8000ef          	jal	b0e <printf>
  }
  printf("============================================================\n");
 33a:	00001517          	auipc	a0,0x1
 33e:	b8650513          	addi	a0,a0,-1146 # ec0 <malloc+0x2fa>
 342:	7cc000ef          	jal	b0e <printf>

  exit(0);
 346:	4501                	li	a0,0
 348:	358000ef          	jal	6a0 <exit>
 34c:	ec26                	sd	s1,24(sp)
 34e:	e84a                	sd	s2,16(sp)
 350:	e44e                	sd	s3,8(sp)
    printf("Error: shm_get failed\n");
 352:	00001517          	auipc	a0,0x1
 356:	c3e50513          	addi	a0,a0,-962 # f90 <malloc+0x3ca>
 35a:	7b4000ef          	jal	b0e <printf>
    exit(1);
 35e:	4505                	li	a0,1
 360:	340000ef          	jal	6a0 <exit>
    printf("Error: sem_init failed\n");
 364:	00001517          	auipc	a0,0x1
 368:	c4450513          	addi	a0,a0,-956 # fa8 <malloc+0x3e2>
 36c:	7a2000ef          	jal	b0e <printf>
    exit(1);
 370:	4505                	li	a0,1
 372:	32e000ef          	jal	6a0 <exit>
      printf("fork reader failed\n");
 376:	00001517          	auipc	a0,0x1
 37a:	c4a50513          	addi	a0,a0,-950 # fc0 <malloc+0x3fa>
 37e:	790000ef          	jal	b0e <printf>
      exit(1);
 382:	4505                	li	a0,1
 384:	31c000ef          	jal	6a0 <exit>
      reader(sh, i);
 388:	85ca                	mv	a1,s2
 38a:	8526                	mv	a0,s1
 38c:	c75ff0ef          	jal	0 <reader>
      exit(0);
 390:	4501                	li	a0,0
 392:	30e000ef          	jal	6a0 <exit>
      printf("fork writer failed\n");
 396:	00001517          	auipc	a0,0x1
 39a:	c4250513          	addi	a0,a0,-958 # fd8 <malloc+0x412>
 39e:	770000ef          	jal	b0e <printf>
      exit(1);
 3a2:	4505                	li	a0,1
 3a4:	2fc000ef          	jal	6a0 <exit>
  for (int i = 1; i <= NUM_WRITERS; i++) {
 3a8:	4585                	li	a1,1
      writer(sh, i);
 3aa:	8526                	mv	a0,s1
 3ac:	d55ff0ef          	jal	100 <writer>
      exit(0);
 3b0:	4501                	li	a0,0
 3b2:	2ee000ef          	jal	6a0 <exit>
    printf("SUCCESS:\n");
 3b6:	00001517          	auipc	a0,0x1
 3ba:	cf250513          	addi	a0,a0,-782 # 10a8 <malloc+0x4e2>
 3be:	750000ef          	jal	b0e <printf>
    printf("  1. Multiple readers read simultaneously (max = %d).\n", sh->max_readers_seen);
 3c2:	44cc                	lw	a1,12(s1)
 3c4:	00001517          	auipc	a0,0x1
 3c8:	cf450513          	addi	a0,a0,-780 # 10b8 <malloc+0x4f2>
 3cc:	742000ef          	jal	b0e <printf>
    printf("  2. Writers had exclusive access (read_count = 0 and active_writers = 1).\n");
 3d0:	00001517          	auipc	a0,0x1
 3d4:	d2050513          	addi	a0,a0,-736 # 10f0 <malloc+0x52a>
 3d8:	736000ef          	jal	b0e <printf>
    printf("  3. No lost updates or race conditions occurred.\n");
 3dc:	00001517          	auipc	a0,0x1
 3e0:	d6450513          	addi	a0,a0,-668 # 1140 <malloc+0x57a>
 3e4:	72a000ef          	jal	b0e <printf>
 3e8:	bf89                	j	33a <main+0x13c>

00000000000003ea <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 3ea:	1141                	addi	sp,sp,-16
 3ec:	e406                	sd	ra,8(sp)
 3ee:	e022                	sd	s0,0(sp)
 3f0:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 3f2:	e0dff0ef          	jal	1fe <main>
  exit(r);
 3f6:	2aa000ef          	jal	6a0 <exit>

00000000000003fa <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 3fa:	1141                	addi	sp,sp,-16
 3fc:	e406                	sd	ra,8(sp)
 3fe:	e022                	sd	s0,0(sp)
 400:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 402:	87aa                	mv	a5,a0
 404:	0585                	addi	a1,a1,1
 406:	0785                	addi	a5,a5,1
 408:	fff5c703          	lbu	a4,-1(a1)
 40c:	fee78fa3          	sb	a4,-1(a5)
 410:	fb75                	bnez	a4,404 <strcpy+0xa>
    ;
  return os;
}
 412:	60a2                	ld	ra,8(sp)
 414:	6402                	ld	s0,0(sp)
 416:	0141                	addi	sp,sp,16
 418:	8082                	ret

000000000000041a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 41a:	1141                	addi	sp,sp,-16
 41c:	e406                	sd	ra,8(sp)
 41e:	e022                	sd	s0,0(sp)
 420:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 422:	00054783          	lbu	a5,0(a0)
 426:	cb91                	beqz	a5,43a <strcmp+0x20>
 428:	0005c703          	lbu	a4,0(a1)
 42c:	00f71763          	bne	a4,a5,43a <strcmp+0x20>
    p++, q++;
 430:	0505                	addi	a0,a0,1
 432:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 434:	00054783          	lbu	a5,0(a0)
 438:	fbe5                	bnez	a5,428 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 43a:	0005c503          	lbu	a0,0(a1)
}
 43e:	40a7853b          	subw	a0,a5,a0
 442:	60a2                	ld	ra,8(sp)
 444:	6402                	ld	s0,0(sp)
 446:	0141                	addi	sp,sp,16
 448:	8082                	ret

000000000000044a <strlen>:

uint
strlen(const char *s)
{
 44a:	1141                	addi	sp,sp,-16
 44c:	e406                	sd	ra,8(sp)
 44e:	e022                	sd	s0,0(sp)
 450:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 452:	00054783          	lbu	a5,0(a0)
 456:	cf91                	beqz	a5,472 <strlen+0x28>
 458:	00150793          	addi	a5,a0,1
 45c:	86be                	mv	a3,a5
 45e:	0785                	addi	a5,a5,1
 460:	fff7c703          	lbu	a4,-1(a5)
 464:	ff65                	bnez	a4,45c <strlen+0x12>
 466:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 46a:	60a2                	ld	ra,8(sp)
 46c:	6402                	ld	s0,0(sp)
 46e:	0141                	addi	sp,sp,16
 470:	8082                	ret
  for (n = 0; s[n]; n++)
 472:	4501                	li	a0,0
 474:	bfdd                	j	46a <strlen+0x20>

0000000000000476 <memset>:

void *
memset(void *dst, int c, uint n)
{
 476:	1141                	addi	sp,sp,-16
 478:	e406                	sd	ra,8(sp)
 47a:	e022                	sd	s0,0(sp)
 47c:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 47e:	ca19                	beqz	a2,494 <memset+0x1e>
 480:	87aa                	mv	a5,a0
 482:	1602                	slli	a2,a2,0x20
 484:	9201                	srli	a2,a2,0x20
 486:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 48a:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 48e:	0785                	addi	a5,a5,1
 490:	fee79de3          	bne	a5,a4,48a <memset+0x14>
  }
  return dst;
}
 494:	60a2                	ld	ra,8(sp)
 496:	6402                	ld	s0,0(sp)
 498:	0141                	addi	sp,sp,16
 49a:	8082                	ret

000000000000049c <strchr>:

char *
strchr(const char *s, char c)
{
 49c:	1141                	addi	sp,sp,-16
 49e:	e406                	sd	ra,8(sp)
 4a0:	e022                	sd	s0,0(sp)
 4a2:	0800                	addi	s0,sp,16
  for (; *s; s++)
 4a4:	00054783          	lbu	a5,0(a0)
 4a8:	cf81                	beqz	a5,4c0 <strchr+0x24>
    if (*s == c)
 4aa:	00f58763          	beq	a1,a5,4b8 <strchr+0x1c>
  for (; *s; s++)
 4ae:	0505                	addi	a0,a0,1
 4b0:	00054783          	lbu	a5,0(a0)
 4b4:	fbfd                	bnez	a5,4aa <strchr+0xe>
      return (char *)s;
  return 0;
 4b6:	4501                	li	a0,0
}
 4b8:	60a2                	ld	ra,8(sp)
 4ba:	6402                	ld	s0,0(sp)
 4bc:	0141                	addi	sp,sp,16
 4be:	8082                	ret
  return 0;
 4c0:	4501                	li	a0,0
 4c2:	bfdd                	j	4b8 <strchr+0x1c>

00000000000004c4 <gets>:

char *
gets(char *buf, int max)
{
 4c4:	711d                	addi	sp,sp,-96
 4c6:	ec86                	sd	ra,88(sp)
 4c8:	e8a2                	sd	s0,80(sp)
 4ca:	e4a6                	sd	s1,72(sp)
 4cc:	e0ca                	sd	s2,64(sp)
 4ce:	fc4e                	sd	s3,56(sp)
 4d0:	f852                	sd	s4,48(sp)
 4d2:	f456                	sd	s5,40(sp)
 4d4:	f05a                	sd	s6,32(sp)
 4d6:	ec5e                	sd	s7,24(sp)
 4d8:	e862                	sd	s8,16(sp)
 4da:	1080                	addi	s0,sp,96
 4dc:	8baa                	mv	s7,a0
 4de:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 4e0:	892a                	mv	s2,a0
 4e2:	4481                	li	s1,0
    cc = read(0, &c, 1);
 4e4:	faf40b13          	addi	s6,s0,-81
 4e8:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 4ea:	8c26                	mv	s8,s1
 4ec:	0014899b          	addiw	s3,s1,1
 4f0:	84ce                	mv	s1,s3
 4f2:	0349d463          	bge	s3,s4,51a <gets+0x56>
    cc = read(0, &c, 1);
 4f6:	8656                	mv	a2,s5
 4f8:	85da                	mv	a1,s6
 4fa:	4501                	li	a0,0
 4fc:	1bc000ef          	jal	6b8 <read>
    if (cc < 1)
 500:	00a05d63          	blez	a0,51a <gets+0x56>
      break;
    buf[i++] = c;
 504:	faf44783          	lbu	a5,-81(s0)
 508:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 50c:	0905                	addi	s2,s2,1
 50e:	ff678713          	addi	a4,a5,-10
 512:	c319                	beqz	a4,518 <gets+0x54>
 514:	17cd                	addi	a5,a5,-13
 516:	fbf1                	bnez	a5,4ea <gets+0x26>
    buf[i++] = c;
 518:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 51a:	9c5e                	add	s8,s8,s7
 51c:	000c0023          	sb	zero,0(s8)
  return buf;
}
 520:	855e                	mv	a0,s7
 522:	60e6                	ld	ra,88(sp)
 524:	6446                	ld	s0,80(sp)
 526:	64a6                	ld	s1,72(sp)
 528:	6906                	ld	s2,64(sp)
 52a:	79e2                	ld	s3,56(sp)
 52c:	7a42                	ld	s4,48(sp)
 52e:	7aa2                	ld	s5,40(sp)
 530:	7b02                	ld	s6,32(sp)
 532:	6be2                	ld	s7,24(sp)
 534:	6c42                	ld	s8,16(sp)
 536:	6125                	addi	sp,sp,96
 538:	8082                	ret

000000000000053a <stat>:

int
stat(const char *n, struct stat *st)
{
 53a:	1101                	addi	sp,sp,-32
 53c:	ec06                	sd	ra,24(sp)
 53e:	e822                	sd	s0,16(sp)
 540:	e04a                	sd	s2,0(sp)
 542:	1000                	addi	s0,sp,32
 544:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 546:	4581                	li	a1,0
 548:	198000ef          	jal	6e0 <open>
  if (fd < 0)
 54c:	02054263          	bltz	a0,570 <stat+0x36>
 550:	e426                	sd	s1,8(sp)
 552:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 554:	85ca                	mv	a1,s2
 556:	1a2000ef          	jal	6f8 <fstat>
 55a:	892a                	mv	s2,a0
  close(fd);
 55c:	8526                	mv	a0,s1
 55e:	16a000ef          	jal	6c8 <close>
  return r;
 562:	64a2                	ld	s1,8(sp)
}
 564:	854a                	mv	a0,s2
 566:	60e2                	ld	ra,24(sp)
 568:	6442                	ld	s0,16(sp)
 56a:	6902                	ld	s2,0(sp)
 56c:	6105                	addi	sp,sp,32
 56e:	8082                	ret
    return -1;
 570:	57fd                	li	a5,-1
 572:	893e                	mv	s2,a5
 574:	bfc5                	j	564 <stat+0x2a>

0000000000000576 <atoi>:

int
atoi(const char *s)
{
 576:	1141                	addi	sp,sp,-16
 578:	e406                	sd	ra,8(sp)
 57a:	e022                	sd	s0,0(sp)
 57c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 57e:	00054683          	lbu	a3,0(a0)
 582:	fd06879b          	addiw	a5,a3,-48
 586:	0ff7f793          	zext.b	a5,a5
 58a:	4625                	li	a2,9
 58c:	02f66963          	bltu	a2,a5,5be <atoi+0x48>
 590:	872a                	mv	a4,a0
  n = 0;
 592:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 594:	0705                	addi	a4,a4,1
 596:	0025179b          	slliw	a5,a0,0x2
 59a:	9fa9                	addw	a5,a5,a0
 59c:	0017979b          	slliw	a5,a5,0x1
 5a0:	9fb5                	addw	a5,a5,a3
 5a2:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 5a6:	00074683          	lbu	a3,0(a4)
 5aa:	fd06879b          	addiw	a5,a3,-48
 5ae:	0ff7f793          	zext.b	a5,a5
 5b2:	fef671e3          	bgeu	a2,a5,594 <atoi+0x1e>
  return n;
}
 5b6:	60a2                	ld	ra,8(sp)
 5b8:	6402                	ld	s0,0(sp)
 5ba:	0141                	addi	sp,sp,16
 5bc:	8082                	ret
  n = 0;
 5be:	4501                	li	a0,0
 5c0:	bfdd                	j	5b6 <atoi+0x40>

00000000000005c2 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 5c2:	1141                	addi	sp,sp,-16
 5c4:	e406                	sd	ra,8(sp)
 5c6:	e022                	sd	s0,0(sp)
 5c8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 5ca:	02b57563          	bgeu	a0,a1,5f4 <memmove+0x32>
    while (n-- > 0)
 5ce:	00c05f63          	blez	a2,5ec <memmove+0x2a>
 5d2:	1602                	slli	a2,a2,0x20
 5d4:	9201                	srli	a2,a2,0x20
 5d6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 5da:	872a                	mv	a4,a0
      *dst++ = *src++;
 5dc:	0585                	addi	a1,a1,1
 5de:	0705                	addi	a4,a4,1
 5e0:	fff5c683          	lbu	a3,-1(a1)
 5e4:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 5e8:	fee79ae3          	bne	a5,a4,5dc <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 5ec:	60a2                	ld	ra,8(sp)
 5ee:	6402                	ld	s0,0(sp)
 5f0:	0141                	addi	sp,sp,16
 5f2:	8082                	ret
    while (n-- > 0)
 5f4:	fec05ce3          	blez	a2,5ec <memmove+0x2a>
    dst += n;
 5f8:	00c50733          	add	a4,a0,a2
    src += n;
 5fc:	95b2                	add	a1,a1,a2
 5fe:	fff6079b          	addiw	a5,a2,-1
 602:	1782                	slli	a5,a5,0x20
 604:	9381                	srli	a5,a5,0x20
 606:	fff7c793          	not	a5,a5
 60a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 60c:	15fd                	addi	a1,a1,-1
 60e:	177d                	addi	a4,a4,-1
 610:	0005c683          	lbu	a3,0(a1)
 614:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 618:	fef71ae3          	bne	a4,a5,60c <memmove+0x4a>
 61c:	bfc1                	j	5ec <memmove+0x2a>

000000000000061e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 61e:	1141                	addi	sp,sp,-16
 620:	e406                	sd	ra,8(sp)
 622:	e022                	sd	s0,0(sp)
 624:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 626:	c61d                	beqz	a2,654 <memcmp+0x36>
 628:	1602                	slli	a2,a2,0x20
 62a:	9201                	srli	a2,a2,0x20
 62c:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 630:	00054783          	lbu	a5,0(a0)
 634:	0005c703          	lbu	a4,0(a1)
 638:	00e79863          	bne	a5,a4,648 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 63c:	0505                	addi	a0,a0,1
    p2++;
 63e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 640:	fed518e3          	bne	a0,a3,630 <memcmp+0x12>
  }
  return 0;
 644:	4501                	li	a0,0
 646:	a019                	j	64c <memcmp+0x2e>
      return *p1 - *p2;
 648:	40e7853b          	subw	a0,a5,a4
}
 64c:	60a2                	ld	ra,8(sp)
 64e:	6402                	ld	s0,0(sp)
 650:	0141                	addi	sp,sp,16
 652:	8082                	ret
  return 0;
 654:	4501                	li	a0,0
 656:	bfdd                	j	64c <memcmp+0x2e>

0000000000000658 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 658:	1141                	addi	sp,sp,-16
 65a:	e406                	sd	ra,8(sp)
 65c:	e022                	sd	s0,0(sp)
 65e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 660:	f63ff0ef          	jal	5c2 <memmove>
}
 664:	60a2                	ld	ra,8(sp)
 666:	6402                	ld	s0,0(sp)
 668:	0141                	addi	sp,sp,16
 66a:	8082                	ret

000000000000066c <sbrk>:

char *
sbrk(int n)
{
 66c:	1141                	addi	sp,sp,-16
 66e:	e406                	sd	ra,8(sp)
 670:	e022                	sd	s0,0(sp)
 672:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 674:	4585                	li	a1,1
 676:	0b2000ef          	jal	728 <sys_sbrk>
}
 67a:	60a2                	ld	ra,8(sp)
 67c:	6402                	ld	s0,0(sp)
 67e:	0141                	addi	sp,sp,16
 680:	8082                	ret

0000000000000682 <sbrklazy>:

char *
sbrklazy(int n)
{
 682:	1141                	addi	sp,sp,-16
 684:	e406                	sd	ra,8(sp)
 686:	e022                	sd	s0,0(sp)
 688:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 68a:	4589                	li	a1,2
 68c:	09c000ef          	jal	728 <sys_sbrk>
}
 690:	60a2                	ld	ra,8(sp)
 692:	6402                	ld	s0,0(sp)
 694:	0141                	addi	sp,sp,16
 696:	8082                	ret

0000000000000698 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 698:	4885                	li	a7,1
 ecall
 69a:	00000073          	ecall
 ret
 69e:	8082                	ret

00000000000006a0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 6a0:	4889                	li	a7,2
 ecall
 6a2:	00000073          	ecall
 ret
 6a6:	8082                	ret

00000000000006a8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 6a8:	488d                	li	a7,3
 ecall
 6aa:	00000073          	ecall
 ret
 6ae:	8082                	ret

00000000000006b0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 6b0:	4891                	li	a7,4
 ecall
 6b2:	00000073          	ecall
 ret
 6b6:	8082                	ret

00000000000006b8 <read>:
.global read
read:
 li a7, SYS_read
 6b8:	4895                	li	a7,5
 ecall
 6ba:	00000073          	ecall
 ret
 6be:	8082                	ret

00000000000006c0 <write>:
.global write
write:
 li a7, SYS_write
 6c0:	48c1                	li	a7,16
 ecall
 6c2:	00000073          	ecall
 ret
 6c6:	8082                	ret

00000000000006c8 <close>:
.global close
close:
 li a7, SYS_close
 6c8:	48d5                	li	a7,21
 ecall
 6ca:	00000073          	ecall
 ret
 6ce:	8082                	ret

00000000000006d0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 6d0:	4899                	li	a7,6
 ecall
 6d2:	00000073          	ecall
 ret
 6d6:	8082                	ret

00000000000006d8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 6d8:	489d                	li	a7,7
 ecall
 6da:	00000073          	ecall
 ret
 6de:	8082                	ret

00000000000006e0 <open>:
.global open
open:
 li a7, SYS_open
 6e0:	48bd                	li	a7,15
 ecall
 6e2:	00000073          	ecall
 ret
 6e6:	8082                	ret

00000000000006e8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 6e8:	48c5                	li	a7,17
 ecall
 6ea:	00000073          	ecall
 ret
 6ee:	8082                	ret

00000000000006f0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 6f0:	48c9                	li	a7,18
 ecall
 6f2:	00000073          	ecall
 ret
 6f6:	8082                	ret

00000000000006f8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 6f8:	48a1                	li	a7,8
 ecall
 6fa:	00000073          	ecall
 ret
 6fe:	8082                	ret

0000000000000700 <link>:
.global link
link:
 li a7, SYS_link
 700:	48cd                	li	a7,19
 ecall
 702:	00000073          	ecall
 ret
 706:	8082                	ret

0000000000000708 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 708:	48d1                	li	a7,20
 ecall
 70a:	00000073          	ecall
 ret
 70e:	8082                	ret

0000000000000710 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 710:	48a5                	li	a7,9
 ecall
 712:	00000073          	ecall
 ret
 716:	8082                	ret

0000000000000718 <dup>:
.global dup
dup:
 li a7, SYS_dup
 718:	48a9                	li	a7,10
 ecall
 71a:	00000073          	ecall
 ret
 71e:	8082                	ret

0000000000000720 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 720:	48ad                	li	a7,11
 ecall
 722:	00000073          	ecall
 ret
 726:	8082                	ret

0000000000000728 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 728:	48b1                	li	a7,12
 ecall
 72a:	00000073          	ecall
 ret
 72e:	8082                	ret

0000000000000730 <pause>:
.global pause
pause:
 li a7, SYS_pause
 730:	48b5                	li	a7,13
 ecall
 732:	00000073          	ecall
 ret
 736:	8082                	ret

0000000000000738 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 738:	48b9                	li	a7,14
 ecall
 73a:	00000073          	ecall
 ret
 73e:	8082                	ret

0000000000000740 <sync>:
.global sync
sync:
 li a7, SYS_sync
 740:	48d9                	li	a7,22
 ecall
 742:	00000073          	ecall
 ret
 746:	8082                	ret

0000000000000748 <shm_get>:
.global shm_get
shm_get:
 li a7, SYS_shm_get
 748:	48dd                	li	a7,23
 ecall
 74a:	00000073          	ecall
 ret
 74e:	8082                	ret

0000000000000750 <sem_init>:
.global sem_init
sem_init:
 li a7, SYS_sem_init
 750:	48e1                	li	a7,24
 ecall
 752:	00000073          	ecall
 ret
 756:	8082                	ret

0000000000000758 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 758:	48e5                	li	a7,25
 ecall
 75a:	00000073          	ecall
 ret
 75e:	8082                	ret

0000000000000760 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 760:	48e9                	li	a7,26
 ecall
 762:	00000073          	ecall
 ret
 766:	8082                	ret

0000000000000768 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 768:	1101                	addi	sp,sp,-32
 76a:	ec06                	sd	ra,24(sp)
 76c:	e822                	sd	s0,16(sp)
 76e:	1000                	addi	s0,sp,32
 770:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 774:	4605                	li	a2,1
 776:	fef40593          	addi	a1,s0,-17
 77a:	f47ff0ef          	jal	6c0 <write>
}
 77e:	60e2                	ld	ra,24(sp)
 780:	6442                	ld	s0,16(sp)
 782:	6105                	addi	sp,sp,32
 784:	8082                	ret

0000000000000786 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 786:	715d                	addi	sp,sp,-80
 788:	e486                	sd	ra,72(sp)
 78a:	e0a2                	sd	s0,64(sp)
 78c:	f84a                	sd	s2,48(sp)
 78e:	f44e                	sd	s3,40(sp)
 790:	0880                	addi	s0,sp,80
 792:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 794:	c6d1                	beqz	a3,820 <printint+0x9a>
 796:	0805d563          	bgez	a1,820 <printint+0x9a>
    neg = 1;
    x = -xx;
 79a:	40b005b3          	neg	a1,a1
    neg = 1;
 79e:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 7a0:	fb840993          	addi	s3,s0,-72
  neg = 0;
 7a4:	86ce                	mv	a3,s3
  i = 0;
 7a6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 7a8:	00001817          	auipc	a6,0x1
 7ac:	a0880813          	addi	a6,a6,-1528 # 11b0 <digits>
 7b0:	88ba                	mv	a7,a4
 7b2:	0017051b          	addiw	a0,a4,1
 7b6:	872a                	mv	a4,a0
 7b8:	02c5f7b3          	remu	a5,a1,a2
 7bc:	97c2                	add	a5,a5,a6
 7be:	0007c783          	lbu	a5,0(a5)
 7c2:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 7c6:	87ae                	mv	a5,a1
 7c8:	02c5d5b3          	divu	a1,a1,a2
 7cc:	0685                	addi	a3,a3,1
 7ce:	fec7f1e3          	bgeu	a5,a2,7b0 <printint+0x2a>
  if (neg)
 7d2:	00030c63          	beqz	t1,7ea <printint+0x64>
    buf[i++] = '-';
 7d6:	fd050793          	addi	a5,a0,-48
 7da:	00878533          	add	a0,a5,s0
 7de:	02d00793          	li	a5,45
 7e2:	fef50423          	sb	a5,-24(a0)
 7e6:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 7ea:	02e05563          	blez	a4,814 <printint+0x8e>
 7ee:	fc26                	sd	s1,56(sp)
 7f0:	377d                	addiw	a4,a4,-1
 7f2:	00e984b3          	add	s1,s3,a4
 7f6:	19fd                	addi	s3,s3,-1
 7f8:	99ba                	add	s3,s3,a4
 7fa:	1702                	slli	a4,a4,0x20
 7fc:	9301                	srli	a4,a4,0x20
 7fe:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 802:	0004c583          	lbu	a1,0(s1)
 806:	854a                	mv	a0,s2
 808:	f61ff0ef          	jal	768 <putc>
  while (--i >= 0)
 80c:	14fd                	addi	s1,s1,-1
 80e:	ff349ae3          	bne	s1,s3,802 <printint+0x7c>
 812:	74e2                	ld	s1,56(sp)
}
 814:	60a6                	ld	ra,72(sp)
 816:	6406                	ld	s0,64(sp)
 818:	7942                	ld	s2,48(sp)
 81a:	79a2                	ld	s3,40(sp)
 81c:	6161                	addi	sp,sp,80
 81e:	8082                	ret
  neg = 0;
 820:	4301                	li	t1,0
 822:	bfbd                	j	7a0 <printint+0x1a>

0000000000000824 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 824:	711d                	addi	sp,sp,-96
 826:	ec86                	sd	ra,88(sp)
 828:	e8a2                	sd	s0,80(sp)
 82a:	e4a6                	sd	s1,72(sp)
 82c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 82e:	0005c483          	lbu	s1,0(a1)
 832:	22048363          	beqz	s1,a58 <vprintf+0x234>
 836:	e0ca                	sd	s2,64(sp)
 838:	fc4e                	sd	s3,56(sp)
 83a:	f852                	sd	s4,48(sp)
 83c:	f456                	sd	s5,40(sp)
 83e:	f05a                	sd	s6,32(sp)
 840:	ec5e                	sd	s7,24(sp)
 842:	e862                	sd	s8,16(sp)
 844:	8b2a                	mv	s6,a0
 846:	8a2e                	mv	s4,a1
 848:	8bb2                	mv	s7,a2
  state = 0;
 84a:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 84c:	4901                	li	s2,0
 84e:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 850:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 854:	06400c13          	li	s8,100
 858:	a00d                	j	87a <vprintf+0x56>
        putc(fd, c0);
 85a:	85a6                	mv	a1,s1
 85c:	855a                	mv	a0,s6
 85e:	f0bff0ef          	jal	768 <putc>
 862:	a019                	j	868 <vprintf+0x44>
    } else if (state == '%') {
 864:	03598363          	beq	s3,s5,88a <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 868:	0019079b          	addiw	a5,s2,1
 86c:	893e                	mv	s2,a5
 86e:	873e                	mv	a4,a5
 870:	97d2                	add	a5,a5,s4
 872:	0007c483          	lbu	s1,0(a5)
 876:	1c048a63          	beqz	s1,a4a <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 87a:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 87e:	fe0993e3          	bnez	s3,864 <vprintf+0x40>
      if (c0 == '%') {
 882:	fd579ce3          	bne	a5,s5,85a <vprintf+0x36>
        state = '%';
 886:	89be                	mv	s3,a5
 888:	b7c5                	j	868 <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 88a:	00ea06b3          	add	a3,s4,a4
 88e:	0016c603          	lbu	a2,1(a3)
      if (c1)
 892:	1c060863          	beqz	a2,a62 <vprintf+0x23e>
      if (c0 == 'd') {
 896:	03878763          	beq	a5,s8,8c4 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 89a:	f9478693          	addi	a3,a5,-108
 89e:	0016b693          	seqz	a3,a3
 8a2:	f9c60593          	addi	a1,a2,-100
 8a6:	e99d                	bnez	a1,8dc <vprintf+0xb8>
 8a8:	ca95                	beqz	a3,8dc <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 8aa:	008b8493          	addi	s1,s7,8
 8ae:	4685                	li	a3,1
 8b0:	4629                	li	a2,10
 8b2:	000bb583          	ld	a1,0(s7)
 8b6:	855a                	mv	a0,s6
 8b8:	ecfff0ef          	jal	786 <printint>
        i += 1;
 8bc:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 8be:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 8c0:	4981                	li	s3,0
 8c2:	b75d                	j	868 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 8c4:	008b8493          	addi	s1,s7,8
 8c8:	4685                	li	a3,1
 8ca:	4629                	li	a2,10
 8cc:	000ba583          	lw	a1,0(s7)
 8d0:	855a                	mv	a0,s6
 8d2:	eb5ff0ef          	jal	786 <printint>
 8d6:	8ba6                	mv	s7,s1
      state = 0;
 8d8:	4981                	li	s3,0
 8da:	b779                	j	868 <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 8dc:	9752                	add	a4,a4,s4
 8de:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 8e2:	f9460713          	addi	a4,a2,-108
 8e6:	00173713          	seqz	a4,a4
 8ea:	8f75                	and	a4,a4,a3
 8ec:	f9c58513          	addi	a0,a1,-100
 8f0:	18051363          	bnez	a0,a76 <vprintf+0x252>
 8f4:	18070163          	beqz	a4,a76 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 8f8:	008b8493          	addi	s1,s7,8
 8fc:	4685                	li	a3,1
 8fe:	4629                	li	a2,10
 900:	000bb583          	ld	a1,0(s7)
 904:	855a                	mv	a0,s6
 906:	e81ff0ef          	jal	786 <printint>
        i += 2;
 90a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 90c:	8ba6                	mv	s7,s1
      state = 0;
 90e:	4981                	li	s3,0
        i += 2;
 910:	bfa1                	j	868 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 912:	008b8493          	addi	s1,s7,8
 916:	4681                	li	a3,0
 918:	4629                	li	a2,10
 91a:	000be583          	lwu	a1,0(s7)
 91e:	855a                	mv	a0,s6
 920:	e67ff0ef          	jal	786 <printint>
 924:	8ba6                	mv	s7,s1
      state = 0;
 926:	4981                	li	s3,0
 928:	b781                	j	868 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 92a:	008b8493          	addi	s1,s7,8
 92e:	4681                	li	a3,0
 930:	4629                	li	a2,10
 932:	000bb583          	ld	a1,0(s7)
 936:	855a                	mv	a0,s6
 938:	e4fff0ef          	jal	786 <printint>
        i += 1;
 93c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 93e:	8ba6                	mv	s7,s1
      state = 0;
 940:	4981                	li	s3,0
 942:	b71d                	j	868 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 944:	008b8493          	addi	s1,s7,8
 948:	4681                	li	a3,0
 94a:	4629                	li	a2,10
 94c:	000bb583          	ld	a1,0(s7)
 950:	855a                	mv	a0,s6
 952:	e35ff0ef          	jal	786 <printint>
        i += 2;
 956:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 958:	8ba6                	mv	s7,s1
      state = 0;
 95a:	4981                	li	s3,0
        i += 2;
 95c:	b731                	j	868 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 95e:	008b8493          	addi	s1,s7,8
 962:	4681                	li	a3,0
 964:	4641                	li	a2,16
 966:	000be583          	lwu	a1,0(s7)
 96a:	855a                	mv	a0,s6
 96c:	e1bff0ef          	jal	786 <printint>
 970:	8ba6                	mv	s7,s1
      state = 0;
 972:	4981                	li	s3,0
 974:	bdd5                	j	868 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 976:	008b8493          	addi	s1,s7,8
 97a:	4681                	li	a3,0
 97c:	4641                	li	a2,16
 97e:	000bb583          	ld	a1,0(s7)
 982:	855a                	mv	a0,s6
 984:	e03ff0ef          	jal	786 <printint>
        i += 1;
 988:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 98a:	8ba6                	mv	s7,s1
      state = 0;
 98c:	4981                	li	s3,0
 98e:	bde9                	j	868 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 990:	008b8493          	addi	s1,s7,8
 994:	4681                	li	a3,0
 996:	4641                	li	a2,16
 998:	000bb583          	ld	a1,0(s7)
 99c:	855a                	mv	a0,s6
 99e:	de9ff0ef          	jal	786 <printint>
        i += 2;
 9a2:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 9a4:	8ba6                	mv	s7,s1
      state = 0;
 9a6:	4981                	li	s3,0
        i += 2;
 9a8:	b5c1                	j	868 <vprintf+0x44>
 9aa:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 9ac:	008b8793          	addi	a5,s7,8
 9b0:	8cbe                	mv	s9,a5
 9b2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 9b6:	03000593          	li	a1,48
 9ba:	855a                	mv	a0,s6
 9bc:	dadff0ef          	jal	768 <putc>
  putc(fd, 'x');
 9c0:	07800593          	li	a1,120
 9c4:	855a                	mv	a0,s6
 9c6:	da3ff0ef          	jal	768 <putc>
 9ca:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 9cc:	00000b97          	auipc	s7,0x0
 9d0:	7e4b8b93          	addi	s7,s7,2020 # 11b0 <digits>
 9d4:	03c9d793          	srli	a5,s3,0x3c
 9d8:	97de                	add	a5,a5,s7
 9da:	0007c583          	lbu	a1,0(a5)
 9de:	855a                	mv	a0,s6
 9e0:	d89ff0ef          	jal	768 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 9e4:	0992                	slli	s3,s3,0x4
 9e6:	34fd                	addiw	s1,s1,-1
 9e8:	f4f5                	bnez	s1,9d4 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 9ea:	8be6                	mv	s7,s9
      state = 0;
 9ec:	4981                	li	s3,0
 9ee:	6ca2                	ld	s9,8(sp)
 9f0:	bda5                	j	868 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 9f2:	008b8493          	addi	s1,s7,8
 9f6:	000bc583          	lbu	a1,0(s7)
 9fa:	855a                	mv	a0,s6
 9fc:	d6dff0ef          	jal	768 <putc>
 a00:	8ba6                	mv	s7,s1
      state = 0;
 a02:	4981                	li	s3,0
 a04:	b595                	j	868 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 a06:	008b8993          	addi	s3,s7,8
 a0a:	000bb483          	ld	s1,0(s7)
 a0e:	cc91                	beqz	s1,a2a <vprintf+0x206>
        for (; *s; s++)
 a10:	0004c583          	lbu	a1,0(s1)
 a14:	c985                	beqz	a1,a44 <vprintf+0x220>
          putc(fd, *s);
 a16:	855a                	mv	a0,s6
 a18:	d51ff0ef          	jal	768 <putc>
        for (; *s; s++)
 a1c:	0485                	addi	s1,s1,1
 a1e:	0004c583          	lbu	a1,0(s1)
 a22:	f9f5                	bnez	a1,a16 <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 a24:	8bce                	mv	s7,s3
      state = 0;
 a26:	4981                	li	s3,0
 a28:	b581                	j	868 <vprintf+0x44>
          s = "(null)";
 a2a:	00000497          	auipc	s1,0x0
 a2e:	77e48493          	addi	s1,s1,1918 # 11a8 <malloc+0x5e2>
        for (; *s; s++)
 a32:	02800593          	li	a1,40
 a36:	b7c5                	j	a16 <vprintf+0x1f2>
        putc(fd, '%');
 a38:	85be                	mv	a1,a5
 a3a:	855a                	mv	a0,s6
 a3c:	d2dff0ef          	jal	768 <putc>
      state = 0;
 a40:	4981                	li	s3,0
 a42:	b51d                	j	868 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 a44:	8bce                	mv	s7,s3
      state = 0;
 a46:	4981                	li	s3,0
 a48:	b505                	j	868 <vprintf+0x44>
 a4a:	6906                	ld	s2,64(sp)
 a4c:	79e2                	ld	s3,56(sp)
 a4e:	7a42                	ld	s4,48(sp)
 a50:	7aa2                	ld	s5,40(sp)
 a52:	7b02                	ld	s6,32(sp)
 a54:	6be2                	ld	s7,24(sp)
 a56:	6c42                	ld	s8,16(sp)
    }
  }
}
 a58:	60e6                	ld	ra,88(sp)
 a5a:	6446                	ld	s0,80(sp)
 a5c:	64a6                	ld	s1,72(sp)
 a5e:	6125                	addi	sp,sp,96
 a60:	8082                	ret
      if (c0 == 'd') {
 a62:	06400713          	li	a4,100
 a66:	e4e78fe3          	beq	a5,a4,8c4 <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 a6a:	f9478693          	addi	a3,a5,-108
 a6e:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 a72:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 a74:	4701                	li	a4,0
      } else if (c0 == 'u') {
 a76:	07500513          	li	a0,117
 a7a:	e8a78ce3          	beq	a5,a0,912 <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 a7e:	f8b60513          	addi	a0,a2,-117
 a82:	e119                	bnez	a0,a88 <vprintf+0x264>
 a84:	ea0693e3          	bnez	a3,92a <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 a88:	f8b58513          	addi	a0,a1,-117
 a8c:	e119                	bnez	a0,a92 <vprintf+0x26e>
 a8e:	ea071be3          	bnez	a4,944 <vprintf+0x120>
      } else if (c0 == 'x') {
 a92:	07800513          	li	a0,120
 a96:	eca784e3          	beq	a5,a0,95e <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 a9a:	f8860613          	addi	a2,a2,-120
 a9e:	e219                	bnez	a2,aa4 <vprintf+0x280>
 aa0:	ec069be3          	bnez	a3,976 <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 aa4:	f8858593          	addi	a1,a1,-120
 aa8:	e199                	bnez	a1,aae <vprintf+0x28a>
 aaa:	ee0713e3          	bnez	a4,990 <vprintf+0x16c>
      } else if (c0 == 'p') {
 aae:	07000713          	li	a4,112
 ab2:	eee78ce3          	beq	a5,a4,9aa <vprintf+0x186>
      } else if (c0 == 'c') {
 ab6:	06300713          	li	a4,99
 aba:	f2e78ce3          	beq	a5,a4,9f2 <vprintf+0x1ce>
      } else if (c0 == 's') {
 abe:	07300713          	li	a4,115
 ac2:	f4e782e3          	beq	a5,a4,a06 <vprintf+0x1e2>
      } else if (c0 == '%') {
 ac6:	02500713          	li	a4,37
 aca:	f6e787e3          	beq	a5,a4,a38 <vprintf+0x214>
        putc(fd, '%');
 ace:	02500593          	li	a1,37
 ad2:	855a                	mv	a0,s6
 ad4:	c95ff0ef          	jal	768 <putc>
        putc(fd, c0);
 ad8:	85a6                	mv	a1,s1
 ada:	855a                	mv	a0,s6
 adc:	c8dff0ef          	jal	768 <putc>
      state = 0;
 ae0:	4981                	li	s3,0
 ae2:	b359                	j	868 <vprintf+0x44>

0000000000000ae4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 ae4:	715d                	addi	sp,sp,-80
 ae6:	ec06                	sd	ra,24(sp)
 ae8:	e822                	sd	s0,16(sp)
 aea:	1000                	addi	s0,sp,32
 aec:	e010                	sd	a2,0(s0)
 aee:	e414                	sd	a3,8(s0)
 af0:	e818                	sd	a4,16(s0)
 af2:	ec1c                	sd	a5,24(s0)
 af4:	03043023          	sd	a6,32(s0)
 af8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 afc:	8622                	mv	a2,s0
 afe:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 b02:	d23ff0ef          	jal	824 <vprintf>
}
 b06:	60e2                	ld	ra,24(sp)
 b08:	6442                	ld	s0,16(sp)
 b0a:	6161                	addi	sp,sp,80
 b0c:	8082                	ret

0000000000000b0e <printf>:

void
printf(const char *fmt, ...)
{
 b0e:	711d                	addi	sp,sp,-96
 b10:	ec06                	sd	ra,24(sp)
 b12:	e822                	sd	s0,16(sp)
 b14:	1000                	addi	s0,sp,32
 b16:	e40c                	sd	a1,8(s0)
 b18:	e810                	sd	a2,16(s0)
 b1a:	ec14                	sd	a3,24(s0)
 b1c:	f018                	sd	a4,32(s0)
 b1e:	f41c                	sd	a5,40(s0)
 b20:	03043823          	sd	a6,48(s0)
 b24:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 b28:	00840613          	addi	a2,s0,8
 b2c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 b30:	85aa                	mv	a1,a0
 b32:	4505                	li	a0,1
 b34:	cf1ff0ef          	jal	824 <vprintf>
}
 b38:	60e2                	ld	ra,24(sp)
 b3a:	6442                	ld	s0,16(sp)
 b3c:	6125                	addi	sp,sp,96
 b3e:	8082                	ret

0000000000000b40 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b40:	1141                	addi	sp,sp,-16
 b42:	e406                	sd	ra,8(sp)
 b44:	e022                	sd	s0,0(sp)
 b46:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 b48:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b4c:	00001797          	auipc	a5,0x1
 b50:	4b47b783          	ld	a5,1204(a5) # 2000 <freep>
 b54:	a039                	j	b62 <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b56:	6398                	ld	a4,0(a5)
 b58:	00e7e463          	bltu	a5,a4,b60 <free+0x20>
 b5c:	00e6ea63          	bltu	a3,a4,b70 <free+0x30>
{
 b60:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b62:	fed7fae3          	bgeu	a5,a3,b56 <free+0x16>
 b66:	6398                	ld	a4,0(a5)
 b68:	00e6e463          	bltu	a3,a4,b70 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b6c:	fee7eae3          	bltu	a5,a4,b60 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 b70:	ff852583          	lw	a1,-8(a0)
 b74:	6390                	ld	a2,0(a5)
 b76:	02059813          	slli	a6,a1,0x20
 b7a:	01c85713          	srli	a4,a6,0x1c
 b7e:	9736                	add	a4,a4,a3
 b80:	02e60563          	beq	a2,a4,baa <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 b84:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 b88:	4790                	lw	a2,8(a5)
 b8a:	02061593          	slli	a1,a2,0x20
 b8e:	01c5d713          	srli	a4,a1,0x1c
 b92:	973e                	add	a4,a4,a5
 b94:	02e68263          	beq	a3,a4,bb8 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 b98:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 b9a:	00001717          	auipc	a4,0x1
 b9e:	46f73323          	sd	a5,1126(a4) # 2000 <freep>
}
 ba2:	60a2                	ld	ra,8(sp)
 ba4:	6402                	ld	s0,0(sp)
 ba6:	0141                	addi	sp,sp,16
 ba8:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 baa:	4618                	lw	a4,8(a2)
 bac:	9f2d                	addw	a4,a4,a1
 bae:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 bb2:	6398                	ld	a4,0(a5)
 bb4:	6310                	ld	a2,0(a4)
 bb6:	b7f9                	j	b84 <free+0x44>
    p->s.size += bp->s.size;
 bb8:	ff852703          	lw	a4,-8(a0)
 bbc:	9f31                	addw	a4,a4,a2
 bbe:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 bc0:	ff053683          	ld	a3,-16(a0)
 bc4:	bfd1                	j	b98 <free+0x58>

0000000000000bc6 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 bc6:	7139                	addi	sp,sp,-64
 bc8:	fc06                	sd	ra,56(sp)
 bca:	f822                	sd	s0,48(sp)
 bcc:	f04a                	sd	s2,32(sp)
 bce:	ec4e                	sd	s3,24(sp)
 bd0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 bd2:	02051993          	slli	s3,a0,0x20
 bd6:	0209d993          	srli	s3,s3,0x20
 bda:	09bd                	addi	s3,s3,15
 bdc:	0049d993          	srli	s3,s3,0x4
 be0:	2985                	addiw	s3,s3,1
 be2:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 be4:	00001517          	auipc	a0,0x1
 be8:	41c53503          	ld	a0,1052(a0) # 2000 <freep>
 bec:	c905                	beqz	a0,c1c <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 bee:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 bf0:	4798                	lw	a4,8(a5)
 bf2:	09377663          	bgeu	a4,s3,c7e <malloc+0xb8>
 bf6:	f426                	sd	s1,40(sp)
 bf8:	e852                	sd	s4,16(sp)
 bfa:	e456                	sd	s5,8(sp)
 bfc:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 bfe:	8a4e                	mv	s4,s3
 c00:	6705                	lui	a4,0x1
 c02:	00e9f363          	bgeu	s3,a4,c08 <malloc+0x42>
 c06:	6a05                	lui	s4,0x1
 c08:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 c0c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 c10:	00001497          	auipc	s1,0x1
 c14:	3f048493          	addi	s1,s1,1008 # 2000 <freep>
  if (p == SBRK_ERROR)
 c18:	5afd                	li	s5,-1
 c1a:	a83d                	j	c58 <malloc+0x92>
 c1c:	f426                	sd	s1,40(sp)
 c1e:	e852                	sd	s4,16(sp)
 c20:	e456                	sd	s5,8(sp)
 c22:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 c24:	00001797          	auipc	a5,0x1
 c28:	3ec78793          	addi	a5,a5,1004 # 2010 <base>
 c2c:	00001717          	auipc	a4,0x1
 c30:	3cf73a23          	sd	a5,980(a4) # 2000 <freep>
 c34:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 c36:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 c3a:	b7d1                	j	bfe <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 c3c:	6398                	ld	a4,0(a5)
 c3e:	e118                	sd	a4,0(a0)
 c40:	a899                	j	c96 <malloc+0xd0>
  hp->s.size = nu;
 c42:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 c46:	0541                	addi	a0,a0,16
 c48:	ef9ff0ef          	jal	b40 <free>
  return freep;
 c4c:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 c4e:	c125                	beqz	a0,cae <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 c50:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 c52:	4798                	lw	a4,8(a5)
 c54:	03277163          	bgeu	a4,s2,c76 <malloc+0xb0>
    if (p == freep)
 c58:	6098                	ld	a4,0(s1)
 c5a:	853e                	mv	a0,a5
 c5c:	fef71ae3          	bne	a4,a5,c50 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 c60:	8552                	mv	a0,s4
 c62:	a0bff0ef          	jal	66c <sbrk>
  if (p == SBRK_ERROR)
 c66:	fd551ee3          	bne	a0,s5,c42 <malloc+0x7c>
        return 0;
 c6a:	4501                	li	a0,0
 c6c:	74a2                	ld	s1,40(sp)
 c6e:	6a42                	ld	s4,16(sp)
 c70:	6aa2                	ld	s5,8(sp)
 c72:	6b02                	ld	s6,0(sp)
 c74:	a03d                	j	ca2 <malloc+0xdc>
 c76:	74a2                	ld	s1,40(sp)
 c78:	6a42                	ld	s4,16(sp)
 c7a:	6aa2                	ld	s5,8(sp)
 c7c:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 c7e:	fae90fe3          	beq	s2,a4,c3c <malloc+0x76>
        p->s.size -= nunits;
 c82:	4137073b          	subw	a4,a4,s3
 c86:	c798                	sw	a4,8(a5)
        p += p->s.size;
 c88:	02071693          	slli	a3,a4,0x20
 c8c:	01c6d713          	srli	a4,a3,0x1c
 c90:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c92:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c96:	00001717          	auipc	a4,0x1
 c9a:	36a73523          	sd	a0,874(a4) # 2000 <freep>
      return (void *)(p + 1);
 c9e:	01078513          	addi	a0,a5,16
  }
}
 ca2:	70e2                	ld	ra,56(sp)
 ca4:	7442                	ld	s0,48(sp)
 ca6:	7902                	ld	s2,32(sp)
 ca8:	69e2                	ld	s3,24(sp)
 caa:	6121                	addi	sp,sp,64
 cac:	8082                	ret
 cae:	74a2                	ld	s1,40(sp)
 cb0:	6a42                	ld	s4,16(sp)
 cb2:	6aa2                	ld	s5,8(sp)
 cb4:	6b02                	ld	s6,0(sp)
 cb6:	b7f5                	j	ca2 <malloc+0xdc>
