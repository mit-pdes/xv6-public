
user/_dining:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <philosopher>:
  int meals_eaten[N_PHIL];
  int violations;
  int total_meals;
};

void philosopher(struct dining_shared *ds, int id) {
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	addi	s0,sp,128
  1e:	8baa                	mv	s7,a0
  20:	892e                	mv	s2,a1
  int left = id;
  int right = (id + 1) % N_PHIL;
  22:	00158c9b          	addiw	s9,a1,1
  26:	666667b7          	lui	a5,0x66666
  2a:	66778793          	addi	a5,a5,1639 # 66666667 <base+0x66664657>
  2e:	02fc87b3          	mul	a5,s9,a5
  32:	9785                	srai	a5,a5,0x21
  34:	41fcd71b          	sraiw	a4,s9,0x1f
  38:	9f99                	subw	a5,a5,a4
  3a:	0027971b          	slliw	a4,a5,0x2
  3e:	9fb9                	addw	a5,a5,a4
  40:	40fc8cbb          	subw	s9,s9,a5
  // Resource ordering deadlock avoidance strategy:
  // Always acquire the lower-numbered fork first, then higher-numbered fork.
  // For philosophers 0, 1, 2, 3: first is left (i), second is right (i+1).
  // For philosopher 4: left is 4, right is 0 -> first is right (0), second is left (4).
  // This breaks circular wait and guarantees freedom from deadlock.
  int first_fork = (left < right) ? left : right;
  44:	8aae                	mv	s5,a1
  46:	00bcd363          	bge	s9,a1,4c <philosopher+0x4c>
  4a:	8ae6                	mv	s5,s9
  4c:	2a81                	sext.w	s5,s5
  int second_fork = (left < right) ? right : left;
  4e:	8a4a                	mv	s4,s2
  50:	01995363          	bge	s2,s9,56 <philosopher+0x56>
  54:	8a66                	mv	s4,s9
  56:	2a01                	sext.w	s4,s4
    // 3. EATING transition
    sem_wait(SEM_MUTEX);
    ds->state[id] = STATE_EATING;

    // Verify mutual exclusion: neither neighbor may be EATING simultaneously
    int left_neighbor = (id + N_PHIL - 1) % N_PHIL;
  58:	0049069b          	addiw	a3,s2,4
  5c:	666667b7          	lui	a5,0x66666
  60:	66778793          	addi	a5,a5,1639 # 66666667 <base+0x66664657>
  64:	02f687b3          	mul	a5,a3,a5
  68:	9785                	srai	a5,a5,0x21
  6a:	41f6d71b          	sraiw	a4,a3,0x1f
  6e:	9f99                	subw	a5,a5,a4
  70:	0027971b          	slliw	a4,a5,0x2
  74:	9fb9                	addw	a5,a5,a4
  76:	40f687bb          	subw	a5,a3,a5
  7a:	f8f43023          	sd	a5,-128(s0)
  for (int cycle = 1; cycle <= NUM_CYCLES; cycle++) {
  7e:	4b05                	li	s6,1
    pause(1);
  80:	8d5a                	mv	s10,s6
    sem_wait(SEM_MUTEX);
  82:	4495                	li	s1,5
  84:	00291993          	slli	s3,s2,0x2
  88:	99de                	add	s3,s3,s7
    ds->state[id] = STATE_EATING;
  8a:	4c09                	li	s8,2
    int right_neighbor = (id + 1) % N_PHIL;
    if (ds->state[left_neighbor] == STATE_EATING ||
  8c:	00279d93          	slli	s11,a5,0x2
  90:	9dde                	add	s11,s11,s7
        ds->state[right_neighbor] == STATE_EATING) {
  92:	002c9793          	slli	a5,s9,0x2
  96:	97de                	add	a5,a5,s7
  98:	f8f43423          	sd	a5,-120(s0)
  9c:	a861                	j	134 <philosopher+0x134>
      printf("VIOLATION: Philosopher %d is EATING while neighbor (%d or %d) is also EATING!\n",
  9e:	86e6                	mv	a3,s9
  a0:	f8043603          	ld	a2,-128(s0)
  a4:	85ca                	mv	a1,s2
  a6:	00001517          	auipc	a0,0x1
  aa:	c9250513          	addi	a0,a0,-878 # d38 <malloc+0x17e>
  ae:	255000ef          	jal	b02 <printf>
             id, left_neighbor, right_neighbor);
      ds->violations++;
  b2:	028ba783          	lw	a5,40(s7)
  b6:	2785                	addiw	a5,a5,1
  b8:	02fba423          	sw	a5,40(s7)
    }

    ds->meals_eaten[id]++;
  bc:	0149a783          	lw	a5,20(s3)
  c0:	2785                	addiw	a5,a5,1
  c2:	00f9aa23          	sw	a5,20(s3)
    ds->total_meals++;
  c6:	02cba783          	lw	a5,44(s7)
  ca:	2785                	addiw	a5,a5,1
  cc:	02fba623          	sw	a5,44(s7)
    printf("Philosopher %d [pid %d]: HUNGRY -> EATING (holding forks %d, %d) [Meal #%d]\n",
  d0:	644000ef          	jal	714 <getpid>
  d4:	862a                	mv	a2,a0
  d6:	0149a783          	lw	a5,20(s3)
  da:	8752                	mv	a4,s4
  dc:	86d6                	mv	a3,s5
  de:	85ca                	mv	a1,s2
  e0:	00001517          	auipc	a0,0x1
  e4:	ca850513          	addi	a0,a0,-856 # d88 <malloc+0x1ce>
  e8:	21b000ef          	jal	b02 <printf>
           id, getpid(), first_fork, second_fork, ds->meals_eaten[id]);
    sem_post(SEM_MUTEX);
  ec:	8526                	mv	a0,s1
  ee:	666000ef          	jal	754 <sem_post>

    // Eating duration
    pause(2);
  f2:	8562                	mv	a0,s8
  f4:	630000ef          	jal	724 <pause>

    // 4. Release both forks
    sem_post(second_fork);
  f8:	8552                	mv	a0,s4
  fa:	65a000ef          	jal	754 <sem_post>
    sem_post(first_fork);
  fe:	8556                	mv	a0,s5
 100:	654000ef          	jal	754 <sem_post>

    // EATING -> THINKING transition
    sem_wait(SEM_MUTEX);
 104:	8526                	mv	a0,s1
 106:	646000ef          	jal	74c <sem_wait>
    ds->state[id] = STATE_THINKING;
 10a:	0009a023          	sw	zero,0(s3)
    printf("Philosopher %d [pid %d]: EATING -> THINKING (released forks %d, %d)\n",
 10e:	606000ef          	jal	714 <getpid>
 112:	862a                	mv	a2,a0
 114:	8752                	mv	a4,s4
 116:	86d6                	mv	a3,s5
 118:	85ca                	mv	a1,s2
 11a:	00001517          	auipc	a0,0x1
 11e:	cbe50513          	addi	a0,a0,-834 # dd8 <malloc+0x21e>
 122:	1e1000ef          	jal	b02 <printf>
           id, getpid(), first_fork, second_fork);
    sem_post(SEM_MUTEX);
 126:	8526                	mv	a0,s1
 128:	62c000ef          	jal	754 <sem_post>
  for (int cycle = 1; cycle <= NUM_CYCLES; cycle++) {
 12c:	2b05                	addiw	s6,s6,1
 12e:	4799                	li	a5,6
 130:	08fb0063          	beq	s6,a5,1b0 <philosopher+0x1b0>
    pause(1);
 134:	856a                	mv	a0,s10
 136:	5ee000ef          	jal	724 <pause>
    sem_wait(SEM_MUTEX);
 13a:	8526                	mv	a0,s1
 13c:	610000ef          	jal	74c <sem_wait>
    ds->state[id] = STATE_HUNGRY;
 140:	01a9a023          	sw	s10,0(s3)
    printf("Philosopher %d [pid %d]: THINKING -> HUNGRY (Cycle %d/%d)\n",
 144:	5d0000ef          	jal	714 <getpid>
 148:	862a                	mv	a2,a0
 14a:	8726                	mv	a4,s1
 14c:	86da                	mv	a3,s6
 14e:	85ca                	mv	a1,s2
 150:	00001517          	auipc	a0,0x1
 154:	b6050513          	addi	a0,a0,-1184 # cb0 <malloc+0xf6>
 158:	1ab000ef          	jal	b02 <printf>
    sem_post(SEM_MUTEX);
 15c:	8526                	mv	a0,s1
 15e:	5f6000ef          	jal	754 <sem_post>
    sem_wait(first_fork);
 162:	8556                	mv	a0,s5
 164:	5e8000ef          	jal	74c <sem_wait>
    sem_wait(SEM_MUTEX);
 168:	8526                	mv	a0,s1
 16a:	5e2000ef          	jal	74c <sem_wait>
    printf("Philosopher %d [pid %d]: picked up fork %d, waiting for fork %d\n",
 16e:	5a6000ef          	jal	714 <getpid>
 172:	862a                	mv	a2,a0
 174:	8752                	mv	a4,s4
 176:	86d6                	mv	a3,s5
 178:	85ca                	mv	a1,s2
 17a:	00001517          	auipc	a0,0x1
 17e:	b7650513          	addi	a0,a0,-1162 # cf0 <malloc+0x136>
 182:	181000ef          	jal	b02 <printf>
    sem_post(SEM_MUTEX);
 186:	8526                	mv	a0,s1
 188:	5cc000ef          	jal	754 <sem_post>
    sem_wait(second_fork);
 18c:	8552                	mv	a0,s4
 18e:	5be000ef          	jal	74c <sem_wait>
    sem_wait(SEM_MUTEX);
 192:	8526                	mv	a0,s1
 194:	5b8000ef          	jal	74c <sem_wait>
    ds->state[id] = STATE_EATING;
 198:	0189a023          	sw	s8,0(s3)
    if (ds->state[left_neighbor] == STATE_EATING ||
 19c:	000da783          	lw	a5,0(s11)
 1a0:	ef878fe3          	beq	a5,s8,9e <philosopher+0x9e>
 1a4:	f8843783          	ld	a5,-120(s0)
 1a8:	439c                	lw	a5,0(a5)
 1aa:	f18799e3          	bne	a5,s8,bc <philosopher+0xbc>
 1ae:	bdc5                	j	9e <philosopher+0x9e>
  }

  printf("Philosopher %d [pid %d]: Finished all %d dining cycles.\n",
 1b0:	564000ef          	jal	714 <getpid>
 1b4:	862a                	mv	a2,a0
 1b6:	4695                	li	a3,5
 1b8:	85ca                	mv	a1,s2
 1ba:	00001517          	auipc	a0,0x1
 1be:	c6650513          	addi	a0,a0,-922 # e20 <malloc+0x266>
 1c2:	141000ef          	jal	b02 <printf>
         id, getpid(), NUM_CYCLES);
}
 1c6:	70e6                	ld	ra,120(sp)
 1c8:	7446                	ld	s0,112(sp)
 1ca:	74a6                	ld	s1,104(sp)
 1cc:	7906                	ld	s2,96(sp)
 1ce:	69e6                	ld	s3,88(sp)
 1d0:	6a46                	ld	s4,80(sp)
 1d2:	6aa6                	ld	s5,72(sp)
 1d4:	6b06                	ld	s6,64(sp)
 1d6:	7be2                	ld	s7,56(sp)
 1d8:	7c42                	ld	s8,48(sp)
 1da:	7ca2                	ld	s9,40(sp)
 1dc:	7d02                	ld	s10,32(sp)
 1de:	6de2                	ld	s11,24(sp)
 1e0:	6109                	addi	sp,sp,128
 1e2:	8082                	ret

00000000000001e4 <main>:

int main(int argc, char *argv[]) {
 1e4:	7139                	addi	sp,sp,-64
 1e6:	fc06                	sd	ra,56(sp)
 1e8:	f822                	sd	s0,48(sp)
 1ea:	0080                	addi	s0,sp,64
  printf("============================================================\n");
 1ec:	00001517          	auipc	a0,0x1
 1f0:	c7450513          	addi	a0,a0,-908 # e60 <malloc+0x2a6>
 1f4:	10f000ef          	jal	b02 <printf>
  printf("Dining Philosophers Simulation with Deadlock Avoidance\n");
 1f8:	00001517          	auipc	a0,0x1
 1fc:	ca850513          	addi	a0,a0,-856 # ea0 <malloc+0x2e6>
 200:	103000ef          	jal	b02 <printf>
  printf("Philosophers = %d, Forks = %d, Cycles = %d\n", N_PHIL, N_PHIL, NUM_CYCLES);
 204:	4695                	li	a3,5
 206:	8636                	mv	a2,a3
 208:	85b6                	mv	a1,a3
 20a:	00001517          	auipc	a0,0x1
 20e:	cce50513          	addi	a0,a0,-818 # ed8 <malloc+0x31e>
 212:	0f1000ef          	jal	b02 <printf>
  printf("Strategy: Resource Ordering (acquire lower-numbered fork first)\n");
 216:	00001517          	auipc	a0,0x1
 21a:	cf250513          	addi	a0,a0,-782 # f08 <malloc+0x34e>
 21e:	0e5000ef          	jal	b02 <printf>
  printf("============================================================\n");
 222:	00001517          	auipc	a0,0x1
 226:	c3e50513          	addi	a0,a0,-962 # e60 <malloc+0x2a6>
 22a:	0d9000ef          	jal	b02 <printf>

  // Obtain shared memory page
  struct dining_shared *ds = (struct dining_shared *)shm_get();
 22e:	50e000ef          	jal	73c <shm_get>
  if (ds == 0) {
 232:	10050663          	beqz	a0,33e <main+0x15a>
 236:	f426                	sd	s1,40(sp)
 238:	f04a                	sd	s2,32(sp)
 23a:	ec4e                	sd	s3,24(sp)
 23c:	e852                	sd	s4,16(sp)
 23e:	84aa                	mv	s1,a0
    exit(1);
  }

  // Initialize shared state
  for (int i = 0; i < N_PHIL; i++) {
    ds->state[i] = STATE_THINKING;
 240:	00052023          	sw	zero,0(a0)
    ds->meals_eaten[i] = 0;
 244:	00052a23          	sw	zero,20(a0)
    ds->state[i] = STATE_THINKING;
 248:	00052223          	sw	zero,4(a0)
    ds->meals_eaten[i] = 0;
 24c:	00052c23          	sw	zero,24(a0)
    ds->state[i] = STATE_THINKING;
 250:	00052423          	sw	zero,8(a0)
    ds->meals_eaten[i] = 0;
 254:	00052e23          	sw	zero,28(a0)
    ds->state[i] = STATE_THINKING;
 258:	00052623          	sw	zero,12(a0)
    ds->meals_eaten[i] = 0;
 25c:	02052023          	sw	zero,32(a0)
    ds->state[i] = STATE_THINKING;
 260:	00052823          	sw	zero,16(a0)
    ds->meals_eaten[i] = 0;
 264:	02052223          	sw	zero,36(a0)
  }
  ds->violations = 0;
 268:	02052423          	sw	zero,40(a0)
  ds->total_meals = 0;
 26c:	02052623          	sw	zero,44(a0)

  // Initialize fork semaphores 0..4 (each initialized to 1)
  for (int i = 0; i < N_PHIL; i++) {
 270:	4901                	li	s2,0
    if (sem_init(i, 1) < 0) {
 272:	4985                	li	s3,1
  for (int i = 0; i < N_PHIL; i++) {
 274:	4a15                	li	s4,5
    if (sem_init(i, 1) < 0) {
 276:	85ce                	mv	a1,s3
 278:	854a                	mv	a0,s2
 27a:	4ca000ef          	jal	744 <sem_init>
 27e:	0c054e63          	bltz	a0,35a <main+0x176>
  for (int i = 0; i < N_PHIL; i++) {
 282:	2905                	addiw	s2,s2,1
 284:	ff4919e3          	bne	s2,s4,276 <main+0x92>
      exit(1);
    }
  }

  // Initialize state mutex semaphore 5
  if (sem_init(SEM_MUTEX, 1) < 0) {
 288:	4585                	li	a1,1
 28a:	4515                	li	a0,5
 28c:	4b8000ef          	jal	744 <sem_init>
    printf("Error: sem_init SEM_MUTEX failed\n");
    exit(1);
  }

  // Fork 5 philosopher processes
  for (int i = 0; i < N_PHIL; i++) {
 290:	4901                	li	s2,0
 292:	4995                	li	s3,5
  if (sem_init(SEM_MUTEX, 1) < 0) {
 294:	0c054e63          	bltz	a0,370 <main+0x18c>
    int pid = fork();
 298:	3f4000ef          	jal	68c <fork>
    if (pid < 0) {
 29c:	0e054463          	bltz	a0,384 <main+0x1a0>
      printf("fork philosopher %d failed\n", i);
      exit(1);
    }
    if (pid == 0) {
 2a0:	0e050d63          	beqz	a0,39a <main+0x1b6>
  for (int i = 0; i < N_PHIL; i++) {
 2a4:	2905                	addiw	s2,s2,1
 2a6:	ff3919e3          	bne	s2,s3,298 <main+0xb4>
 2aa:	e456                	sd	s5,8(sp)
 2ac:	4915                	li	s2,5
    }
  }

  // Wait for all 5 philosopher processes to complete
  for (int i = 0; i < N_PHIL; i++) {
    wait(0);
 2ae:	4501                	li	a0,0
 2b0:	3ec000ef          	jal	69c <wait>
  for (int i = 0; i < N_PHIL; i++) {
 2b4:	397d                	addiw	s2,s2,-1
 2b6:	fe091ce3          	bnez	s2,2ae <main+0xca>
  }

  int expected_total = N_PHIL * NUM_CYCLES;

  printf("============================================================\n");
 2ba:	00001517          	auipc	a0,0x1
 2be:	ba650513          	addi	a0,a0,-1114 # e60 <malloc+0x2a6>
 2c2:	041000ef          	jal	b02 <printf>
  printf("Simulation Finished Summary:\n");
 2c6:	00001517          	auipc	a0,0x1
 2ca:	d0a50513          	addi	a0,a0,-758 # fd0 <malloc+0x416>
 2ce:	035000ef          	jal	b02 <printf>
  for (int i = 0; i < N_PHIL; i++) {
 2d2:	01448993          	addi	s3,s1,20
    printf("Philosopher %d ate %d / %d meals.\n",
 2d6:	4a15                	li	s4,5
 2d8:	00001a97          	auipc	s5,0x1
 2dc:	d18a8a93          	addi	s5,s5,-744 # ff0 <malloc+0x436>
 2e0:	86d2                	mv	a3,s4
 2e2:	0009a603          	lw	a2,0(s3)
 2e6:	85ca                	mv	a1,s2
 2e8:	8556                	mv	a0,s5
 2ea:	019000ef          	jal	b02 <printf>
  for (int i = 0; i < N_PHIL; i++) {
 2ee:	2905                	addiw	s2,s2,1
 2f0:	0991                	addi	s3,s3,4
 2f2:	ff4917e3          	bne	s2,s4,2e0 <main+0xfc>
           i, ds->meals_eaten[i], NUM_CYCLES);
  }
  printf("Total meals eaten: %d (Expected: %d)\n", ds->total_meals, expected_total);
 2f6:	4665                	li	a2,25
 2f8:	54cc                	lw	a1,44(s1)
 2fa:	00001517          	auipc	a0,0x1
 2fe:	d1e50513          	addi	a0,a0,-738 # 1018 <malloc+0x45e>
 302:	001000ef          	jal	b02 <printf>
  printf("Mutual exclusion violations: %d\n", ds->violations);
 306:	548c                	lw	a1,40(s1)
 308:	00001517          	auipc	a0,0x1
 30c:	d3850513          	addi	a0,a0,-712 # 1040 <malloc+0x486>
 310:	7f2000ef          	jal	b02 <printf>

  if (ds->total_meals == expected_total && ds->violations == 0) {
 314:	54d8                	lw	a4,44(s1)
 316:	47e5                	li	a5,25
 318:	00f71463          	bne	a4,a5,320 <main+0x13c>
 31c:	549c                	lw	a5,40(s1)
 31e:	c7d1                	beqz	a5,3aa <main+0x1c6>
    printf("SUCCESS:\n");
    printf("  1. All 5 philosophers completed all %d cycles without deadlocking.\n", NUM_CYCLES);
    printf("  2. No two adjacent philosophers ate simultaneously.\n");
    printf("  3. Resource ordering effectively eliminated circular wait.\n");
  } else {
    printf("FAILURE: Dining simulation assertions failed!\n");
 320:	00001517          	auipc	a0,0x1
 324:	e1850513          	addi	a0,a0,-488 # 1138 <malloc+0x57e>
 328:	7da000ef          	jal	b02 <printf>
  }
  printf("============================================================\n");
 32c:	00001517          	auipc	a0,0x1
 330:	b3450513          	addi	a0,a0,-1228 # e60 <malloc+0x2a6>
 334:	7ce000ef          	jal	b02 <printf>

  exit(0);
 338:	4501                	li	a0,0
 33a:	35a000ef          	jal	694 <exit>
 33e:	f426                	sd	s1,40(sp)
 340:	f04a                	sd	s2,32(sp)
 342:	ec4e                	sd	s3,24(sp)
 344:	e852                	sd	s4,16(sp)
 346:	e456                	sd	s5,8(sp)
    printf("Error: shm_get failed\n");
 348:	00001517          	auipc	a0,0x1
 34c:	c0850513          	addi	a0,a0,-1016 # f50 <malloc+0x396>
 350:	7b2000ef          	jal	b02 <printf>
    exit(1);
 354:	4505                	li	a0,1
 356:	33e000ef          	jal	694 <exit>
 35a:	e456                	sd	s5,8(sp)
      printf("Error: sem_init fork %d failed\n", i);
 35c:	85ca                	mv	a1,s2
 35e:	00001517          	auipc	a0,0x1
 362:	c0a50513          	addi	a0,a0,-1014 # f68 <malloc+0x3ae>
 366:	79c000ef          	jal	b02 <printf>
      exit(1);
 36a:	4505                	li	a0,1
 36c:	328000ef          	jal	694 <exit>
 370:	e456                	sd	s5,8(sp)
    printf("Error: sem_init SEM_MUTEX failed\n");
 372:	00001517          	auipc	a0,0x1
 376:	c1650513          	addi	a0,a0,-1002 # f88 <malloc+0x3ce>
 37a:	788000ef          	jal	b02 <printf>
    exit(1);
 37e:	4505                	li	a0,1
 380:	314000ef          	jal	694 <exit>
 384:	e456                	sd	s5,8(sp)
      printf("fork philosopher %d failed\n", i);
 386:	85ca                	mv	a1,s2
 388:	00001517          	auipc	a0,0x1
 38c:	c2850513          	addi	a0,a0,-984 # fb0 <malloc+0x3f6>
 390:	772000ef          	jal	b02 <printf>
      exit(1);
 394:	4505                	li	a0,1
 396:	2fe000ef          	jal	694 <exit>
 39a:	e456                	sd	s5,8(sp)
      philosopher(ds, i);
 39c:	85ca                	mv	a1,s2
 39e:	8526                	mv	a0,s1
 3a0:	c61ff0ef          	jal	0 <philosopher>
      exit(0);
 3a4:	4501                	li	a0,0
 3a6:	2ee000ef          	jal	694 <exit>
    printf("SUCCESS:\n");
 3aa:	00001517          	auipc	a0,0x1
 3ae:	cbe50513          	addi	a0,a0,-834 # 1068 <malloc+0x4ae>
 3b2:	750000ef          	jal	b02 <printf>
    printf("  1. All 5 philosophers completed all %d cycles without deadlocking.\n", NUM_CYCLES);
 3b6:	4595                	li	a1,5
 3b8:	00001517          	auipc	a0,0x1
 3bc:	cc050513          	addi	a0,a0,-832 # 1078 <malloc+0x4be>
 3c0:	742000ef          	jal	b02 <printf>
    printf("  2. No two adjacent philosophers ate simultaneously.\n");
 3c4:	00001517          	auipc	a0,0x1
 3c8:	cfc50513          	addi	a0,a0,-772 # 10c0 <malloc+0x506>
 3cc:	736000ef          	jal	b02 <printf>
    printf("  3. Resource ordering effectively eliminated circular wait.\n");
 3d0:	00001517          	auipc	a0,0x1
 3d4:	d2850513          	addi	a0,a0,-728 # 10f8 <malloc+0x53e>
 3d8:	72a000ef          	jal	b02 <printf>
 3dc:	bf81                	j	32c <main+0x148>

00000000000003de <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 3de:	1141                	addi	sp,sp,-16
 3e0:	e406                	sd	ra,8(sp)
 3e2:	e022                	sd	s0,0(sp)
 3e4:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 3e6:	dffff0ef          	jal	1e4 <main>
  exit(r);
 3ea:	2aa000ef          	jal	694 <exit>

00000000000003ee <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 3ee:	1141                	addi	sp,sp,-16
 3f0:	e406                	sd	ra,8(sp)
 3f2:	e022                	sd	s0,0(sp)
 3f4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 3f6:	87aa                	mv	a5,a0
 3f8:	0585                	addi	a1,a1,1
 3fa:	0785                	addi	a5,a5,1
 3fc:	fff5c703          	lbu	a4,-1(a1)
 400:	fee78fa3          	sb	a4,-1(a5)
 404:	fb75                	bnez	a4,3f8 <strcpy+0xa>
    ;
  return os;
}
 406:	60a2                	ld	ra,8(sp)
 408:	6402                	ld	s0,0(sp)
 40a:	0141                	addi	sp,sp,16
 40c:	8082                	ret

000000000000040e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 40e:	1141                	addi	sp,sp,-16
 410:	e406                	sd	ra,8(sp)
 412:	e022                	sd	s0,0(sp)
 414:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 416:	00054783          	lbu	a5,0(a0)
 41a:	cb91                	beqz	a5,42e <strcmp+0x20>
 41c:	0005c703          	lbu	a4,0(a1)
 420:	00f71763          	bne	a4,a5,42e <strcmp+0x20>
    p++, q++;
 424:	0505                	addi	a0,a0,1
 426:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 428:	00054783          	lbu	a5,0(a0)
 42c:	fbe5                	bnez	a5,41c <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 42e:	0005c503          	lbu	a0,0(a1)
}
 432:	40a7853b          	subw	a0,a5,a0
 436:	60a2                	ld	ra,8(sp)
 438:	6402                	ld	s0,0(sp)
 43a:	0141                	addi	sp,sp,16
 43c:	8082                	ret

000000000000043e <strlen>:

uint
strlen(const char *s)
{
 43e:	1141                	addi	sp,sp,-16
 440:	e406                	sd	ra,8(sp)
 442:	e022                	sd	s0,0(sp)
 444:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 446:	00054783          	lbu	a5,0(a0)
 44a:	cf91                	beqz	a5,466 <strlen+0x28>
 44c:	00150793          	addi	a5,a0,1
 450:	86be                	mv	a3,a5
 452:	0785                	addi	a5,a5,1
 454:	fff7c703          	lbu	a4,-1(a5)
 458:	ff65                	bnez	a4,450 <strlen+0x12>
 45a:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 45e:	60a2                	ld	ra,8(sp)
 460:	6402                	ld	s0,0(sp)
 462:	0141                	addi	sp,sp,16
 464:	8082                	ret
  for (n = 0; s[n]; n++)
 466:	4501                	li	a0,0
 468:	bfdd                	j	45e <strlen+0x20>

000000000000046a <memset>:

void *
memset(void *dst, int c, uint n)
{
 46a:	1141                	addi	sp,sp,-16
 46c:	e406                	sd	ra,8(sp)
 46e:	e022                	sd	s0,0(sp)
 470:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 472:	ca19                	beqz	a2,488 <memset+0x1e>
 474:	87aa                	mv	a5,a0
 476:	1602                	slli	a2,a2,0x20
 478:	9201                	srli	a2,a2,0x20
 47a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 47e:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 482:	0785                	addi	a5,a5,1
 484:	fee79de3          	bne	a5,a4,47e <memset+0x14>
  }
  return dst;
}
 488:	60a2                	ld	ra,8(sp)
 48a:	6402                	ld	s0,0(sp)
 48c:	0141                	addi	sp,sp,16
 48e:	8082                	ret

0000000000000490 <strchr>:

char *
strchr(const char *s, char c)
{
 490:	1141                	addi	sp,sp,-16
 492:	e406                	sd	ra,8(sp)
 494:	e022                	sd	s0,0(sp)
 496:	0800                	addi	s0,sp,16
  for (; *s; s++)
 498:	00054783          	lbu	a5,0(a0)
 49c:	cf81                	beqz	a5,4b4 <strchr+0x24>
    if (*s == c)
 49e:	00f58763          	beq	a1,a5,4ac <strchr+0x1c>
  for (; *s; s++)
 4a2:	0505                	addi	a0,a0,1
 4a4:	00054783          	lbu	a5,0(a0)
 4a8:	fbfd                	bnez	a5,49e <strchr+0xe>
      return (char *)s;
  return 0;
 4aa:	4501                	li	a0,0
}
 4ac:	60a2                	ld	ra,8(sp)
 4ae:	6402                	ld	s0,0(sp)
 4b0:	0141                	addi	sp,sp,16
 4b2:	8082                	ret
  return 0;
 4b4:	4501                	li	a0,0
 4b6:	bfdd                	j	4ac <strchr+0x1c>

00000000000004b8 <gets>:

char *
gets(char *buf, int max)
{
 4b8:	711d                	addi	sp,sp,-96
 4ba:	ec86                	sd	ra,88(sp)
 4bc:	e8a2                	sd	s0,80(sp)
 4be:	e4a6                	sd	s1,72(sp)
 4c0:	e0ca                	sd	s2,64(sp)
 4c2:	fc4e                	sd	s3,56(sp)
 4c4:	f852                	sd	s4,48(sp)
 4c6:	f456                	sd	s5,40(sp)
 4c8:	f05a                	sd	s6,32(sp)
 4ca:	ec5e                	sd	s7,24(sp)
 4cc:	e862                	sd	s8,16(sp)
 4ce:	1080                	addi	s0,sp,96
 4d0:	8baa                	mv	s7,a0
 4d2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 4d4:	892a                	mv	s2,a0
 4d6:	4481                	li	s1,0
    cc = read(0, &c, 1);
 4d8:	faf40b13          	addi	s6,s0,-81
 4dc:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 4de:	8c26                	mv	s8,s1
 4e0:	0014899b          	addiw	s3,s1,1
 4e4:	84ce                	mv	s1,s3
 4e6:	0349d463          	bge	s3,s4,50e <gets+0x56>
    cc = read(0, &c, 1);
 4ea:	8656                	mv	a2,s5
 4ec:	85da                	mv	a1,s6
 4ee:	4501                	li	a0,0
 4f0:	1bc000ef          	jal	6ac <read>
    if (cc < 1)
 4f4:	00a05d63          	blez	a0,50e <gets+0x56>
      break;
    buf[i++] = c;
 4f8:	faf44783          	lbu	a5,-81(s0)
 4fc:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 500:	0905                	addi	s2,s2,1
 502:	ff678713          	addi	a4,a5,-10
 506:	c319                	beqz	a4,50c <gets+0x54>
 508:	17cd                	addi	a5,a5,-13
 50a:	fbf1                	bnez	a5,4de <gets+0x26>
    buf[i++] = c;
 50c:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 50e:	9c5e                	add	s8,s8,s7
 510:	000c0023          	sb	zero,0(s8)
  return buf;
}
 514:	855e                	mv	a0,s7
 516:	60e6                	ld	ra,88(sp)
 518:	6446                	ld	s0,80(sp)
 51a:	64a6                	ld	s1,72(sp)
 51c:	6906                	ld	s2,64(sp)
 51e:	79e2                	ld	s3,56(sp)
 520:	7a42                	ld	s4,48(sp)
 522:	7aa2                	ld	s5,40(sp)
 524:	7b02                	ld	s6,32(sp)
 526:	6be2                	ld	s7,24(sp)
 528:	6c42                	ld	s8,16(sp)
 52a:	6125                	addi	sp,sp,96
 52c:	8082                	ret

000000000000052e <stat>:

int
stat(const char *n, struct stat *st)
{
 52e:	1101                	addi	sp,sp,-32
 530:	ec06                	sd	ra,24(sp)
 532:	e822                	sd	s0,16(sp)
 534:	e04a                	sd	s2,0(sp)
 536:	1000                	addi	s0,sp,32
 538:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 53a:	4581                	li	a1,0
 53c:	198000ef          	jal	6d4 <open>
  if (fd < 0)
 540:	02054263          	bltz	a0,564 <stat+0x36>
 544:	e426                	sd	s1,8(sp)
 546:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 548:	85ca                	mv	a1,s2
 54a:	1a2000ef          	jal	6ec <fstat>
 54e:	892a                	mv	s2,a0
  close(fd);
 550:	8526                	mv	a0,s1
 552:	16a000ef          	jal	6bc <close>
  return r;
 556:	64a2                	ld	s1,8(sp)
}
 558:	854a                	mv	a0,s2
 55a:	60e2                	ld	ra,24(sp)
 55c:	6442                	ld	s0,16(sp)
 55e:	6902                	ld	s2,0(sp)
 560:	6105                	addi	sp,sp,32
 562:	8082                	ret
    return -1;
 564:	57fd                	li	a5,-1
 566:	893e                	mv	s2,a5
 568:	bfc5                	j	558 <stat+0x2a>

000000000000056a <atoi>:

int
atoi(const char *s)
{
 56a:	1141                	addi	sp,sp,-16
 56c:	e406                	sd	ra,8(sp)
 56e:	e022                	sd	s0,0(sp)
 570:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 572:	00054683          	lbu	a3,0(a0)
 576:	fd06879b          	addiw	a5,a3,-48
 57a:	0ff7f793          	zext.b	a5,a5
 57e:	4625                	li	a2,9
 580:	02f66963          	bltu	a2,a5,5b2 <atoi+0x48>
 584:	872a                	mv	a4,a0
  n = 0;
 586:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 588:	0705                	addi	a4,a4,1
 58a:	0025179b          	slliw	a5,a0,0x2
 58e:	9fa9                	addw	a5,a5,a0
 590:	0017979b          	slliw	a5,a5,0x1
 594:	9fb5                	addw	a5,a5,a3
 596:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 59a:	00074683          	lbu	a3,0(a4)
 59e:	fd06879b          	addiw	a5,a3,-48
 5a2:	0ff7f793          	zext.b	a5,a5
 5a6:	fef671e3          	bgeu	a2,a5,588 <atoi+0x1e>
  return n;
}
 5aa:	60a2                	ld	ra,8(sp)
 5ac:	6402                	ld	s0,0(sp)
 5ae:	0141                	addi	sp,sp,16
 5b0:	8082                	ret
  n = 0;
 5b2:	4501                	li	a0,0
 5b4:	bfdd                	j	5aa <atoi+0x40>

00000000000005b6 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 5b6:	1141                	addi	sp,sp,-16
 5b8:	e406                	sd	ra,8(sp)
 5ba:	e022                	sd	s0,0(sp)
 5bc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 5be:	02b57563          	bgeu	a0,a1,5e8 <memmove+0x32>
    while (n-- > 0)
 5c2:	00c05f63          	blez	a2,5e0 <memmove+0x2a>
 5c6:	1602                	slli	a2,a2,0x20
 5c8:	9201                	srli	a2,a2,0x20
 5ca:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 5ce:	872a                	mv	a4,a0
      *dst++ = *src++;
 5d0:	0585                	addi	a1,a1,1
 5d2:	0705                	addi	a4,a4,1
 5d4:	fff5c683          	lbu	a3,-1(a1)
 5d8:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 5dc:	fee79ae3          	bne	a5,a4,5d0 <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 5e0:	60a2                	ld	ra,8(sp)
 5e2:	6402                	ld	s0,0(sp)
 5e4:	0141                	addi	sp,sp,16
 5e6:	8082                	ret
    while (n-- > 0)
 5e8:	fec05ce3          	blez	a2,5e0 <memmove+0x2a>
    dst += n;
 5ec:	00c50733          	add	a4,a0,a2
    src += n;
 5f0:	95b2                	add	a1,a1,a2
 5f2:	fff6079b          	addiw	a5,a2,-1
 5f6:	1782                	slli	a5,a5,0x20
 5f8:	9381                	srli	a5,a5,0x20
 5fa:	fff7c793          	not	a5,a5
 5fe:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 600:	15fd                	addi	a1,a1,-1
 602:	177d                	addi	a4,a4,-1
 604:	0005c683          	lbu	a3,0(a1)
 608:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 60c:	fef71ae3          	bne	a4,a5,600 <memmove+0x4a>
 610:	bfc1                	j	5e0 <memmove+0x2a>

0000000000000612 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 612:	1141                	addi	sp,sp,-16
 614:	e406                	sd	ra,8(sp)
 616:	e022                	sd	s0,0(sp)
 618:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 61a:	c61d                	beqz	a2,648 <memcmp+0x36>
 61c:	1602                	slli	a2,a2,0x20
 61e:	9201                	srli	a2,a2,0x20
 620:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 624:	00054783          	lbu	a5,0(a0)
 628:	0005c703          	lbu	a4,0(a1)
 62c:	00e79863          	bne	a5,a4,63c <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 630:	0505                	addi	a0,a0,1
    p2++;
 632:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 634:	fed518e3          	bne	a0,a3,624 <memcmp+0x12>
  }
  return 0;
 638:	4501                	li	a0,0
 63a:	a019                	j	640 <memcmp+0x2e>
      return *p1 - *p2;
 63c:	40e7853b          	subw	a0,a5,a4
}
 640:	60a2                	ld	ra,8(sp)
 642:	6402                	ld	s0,0(sp)
 644:	0141                	addi	sp,sp,16
 646:	8082                	ret
  return 0;
 648:	4501                	li	a0,0
 64a:	bfdd                	j	640 <memcmp+0x2e>

000000000000064c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 64c:	1141                	addi	sp,sp,-16
 64e:	e406                	sd	ra,8(sp)
 650:	e022                	sd	s0,0(sp)
 652:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 654:	f63ff0ef          	jal	5b6 <memmove>
}
 658:	60a2                	ld	ra,8(sp)
 65a:	6402                	ld	s0,0(sp)
 65c:	0141                	addi	sp,sp,16
 65e:	8082                	ret

0000000000000660 <sbrk>:

char *
sbrk(int n)
{
 660:	1141                	addi	sp,sp,-16
 662:	e406                	sd	ra,8(sp)
 664:	e022                	sd	s0,0(sp)
 666:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 668:	4585                	li	a1,1
 66a:	0b2000ef          	jal	71c <sys_sbrk>
}
 66e:	60a2                	ld	ra,8(sp)
 670:	6402                	ld	s0,0(sp)
 672:	0141                	addi	sp,sp,16
 674:	8082                	ret

0000000000000676 <sbrklazy>:

char *
sbrklazy(int n)
{
 676:	1141                	addi	sp,sp,-16
 678:	e406                	sd	ra,8(sp)
 67a:	e022                	sd	s0,0(sp)
 67c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 67e:	4589                	li	a1,2
 680:	09c000ef          	jal	71c <sys_sbrk>
}
 684:	60a2                	ld	ra,8(sp)
 686:	6402                	ld	s0,0(sp)
 688:	0141                	addi	sp,sp,16
 68a:	8082                	ret

000000000000068c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 68c:	4885                	li	a7,1
 ecall
 68e:	00000073          	ecall
 ret
 692:	8082                	ret

0000000000000694 <exit>:
.global exit
exit:
 li a7, SYS_exit
 694:	4889                	li	a7,2
 ecall
 696:	00000073          	ecall
 ret
 69a:	8082                	ret

000000000000069c <wait>:
.global wait
wait:
 li a7, SYS_wait
 69c:	488d                	li	a7,3
 ecall
 69e:	00000073          	ecall
 ret
 6a2:	8082                	ret

00000000000006a4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 6a4:	4891                	li	a7,4
 ecall
 6a6:	00000073          	ecall
 ret
 6aa:	8082                	ret

00000000000006ac <read>:
.global read
read:
 li a7, SYS_read
 6ac:	4895                	li	a7,5
 ecall
 6ae:	00000073          	ecall
 ret
 6b2:	8082                	ret

00000000000006b4 <write>:
.global write
write:
 li a7, SYS_write
 6b4:	48c1                	li	a7,16
 ecall
 6b6:	00000073          	ecall
 ret
 6ba:	8082                	ret

00000000000006bc <close>:
.global close
close:
 li a7, SYS_close
 6bc:	48d5                	li	a7,21
 ecall
 6be:	00000073          	ecall
 ret
 6c2:	8082                	ret

00000000000006c4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 6c4:	4899                	li	a7,6
 ecall
 6c6:	00000073          	ecall
 ret
 6ca:	8082                	ret

00000000000006cc <exec>:
.global exec
exec:
 li a7, SYS_exec
 6cc:	489d                	li	a7,7
 ecall
 6ce:	00000073          	ecall
 ret
 6d2:	8082                	ret

00000000000006d4 <open>:
.global open
open:
 li a7, SYS_open
 6d4:	48bd                	li	a7,15
 ecall
 6d6:	00000073          	ecall
 ret
 6da:	8082                	ret

00000000000006dc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 6dc:	48c5                	li	a7,17
 ecall
 6de:	00000073          	ecall
 ret
 6e2:	8082                	ret

00000000000006e4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 6e4:	48c9                	li	a7,18
 ecall
 6e6:	00000073          	ecall
 ret
 6ea:	8082                	ret

00000000000006ec <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 6ec:	48a1                	li	a7,8
 ecall
 6ee:	00000073          	ecall
 ret
 6f2:	8082                	ret

00000000000006f4 <link>:
.global link
link:
 li a7, SYS_link
 6f4:	48cd                	li	a7,19
 ecall
 6f6:	00000073          	ecall
 ret
 6fa:	8082                	ret

00000000000006fc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 6fc:	48d1                	li	a7,20
 ecall
 6fe:	00000073          	ecall
 ret
 702:	8082                	ret

0000000000000704 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 704:	48a5                	li	a7,9
 ecall
 706:	00000073          	ecall
 ret
 70a:	8082                	ret

000000000000070c <dup>:
.global dup
dup:
 li a7, SYS_dup
 70c:	48a9                	li	a7,10
 ecall
 70e:	00000073          	ecall
 ret
 712:	8082                	ret

0000000000000714 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 714:	48ad                	li	a7,11
 ecall
 716:	00000073          	ecall
 ret
 71a:	8082                	ret

000000000000071c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 71c:	48b1                	li	a7,12
 ecall
 71e:	00000073          	ecall
 ret
 722:	8082                	ret

0000000000000724 <pause>:
.global pause
pause:
 li a7, SYS_pause
 724:	48b5                	li	a7,13
 ecall
 726:	00000073          	ecall
 ret
 72a:	8082                	ret

000000000000072c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 72c:	48b9                	li	a7,14
 ecall
 72e:	00000073          	ecall
 ret
 732:	8082                	ret

0000000000000734 <sync>:
.global sync
sync:
 li a7, SYS_sync
 734:	48d9                	li	a7,22
 ecall
 736:	00000073          	ecall
 ret
 73a:	8082                	ret

000000000000073c <shm_get>:
.global shm_get
shm_get:
 li a7, SYS_shm_get
 73c:	48dd                	li	a7,23
 ecall
 73e:	00000073          	ecall
 ret
 742:	8082                	ret

0000000000000744 <sem_init>:
.global sem_init
sem_init:
 li a7, SYS_sem_init
 744:	48e1                	li	a7,24
 ecall
 746:	00000073          	ecall
 ret
 74a:	8082                	ret

000000000000074c <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 74c:	48e5                	li	a7,25
 ecall
 74e:	00000073          	ecall
 ret
 752:	8082                	ret

0000000000000754 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 754:	48e9                	li	a7,26
 ecall
 756:	00000073          	ecall
 ret
 75a:	8082                	ret

000000000000075c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 75c:	1101                	addi	sp,sp,-32
 75e:	ec06                	sd	ra,24(sp)
 760:	e822                	sd	s0,16(sp)
 762:	1000                	addi	s0,sp,32
 764:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 768:	4605                	li	a2,1
 76a:	fef40593          	addi	a1,s0,-17
 76e:	f47ff0ef          	jal	6b4 <write>
}
 772:	60e2                	ld	ra,24(sp)
 774:	6442                	ld	s0,16(sp)
 776:	6105                	addi	sp,sp,32
 778:	8082                	ret

000000000000077a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 77a:	715d                	addi	sp,sp,-80
 77c:	e486                	sd	ra,72(sp)
 77e:	e0a2                	sd	s0,64(sp)
 780:	f84a                	sd	s2,48(sp)
 782:	f44e                	sd	s3,40(sp)
 784:	0880                	addi	s0,sp,80
 786:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 788:	c6d1                	beqz	a3,814 <printint+0x9a>
 78a:	0805d563          	bgez	a1,814 <printint+0x9a>
    neg = 1;
    x = -xx;
 78e:	40b005b3          	neg	a1,a1
    neg = 1;
 792:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 794:	fb840993          	addi	s3,s0,-72
  neg = 0;
 798:	86ce                	mv	a3,s3
  i = 0;
 79a:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 79c:	00001817          	auipc	a6,0x1
 7a0:	9d480813          	addi	a6,a6,-1580 # 1170 <digits>
 7a4:	88ba                	mv	a7,a4
 7a6:	0017051b          	addiw	a0,a4,1
 7aa:	872a                	mv	a4,a0
 7ac:	02c5f7b3          	remu	a5,a1,a2
 7b0:	97c2                	add	a5,a5,a6
 7b2:	0007c783          	lbu	a5,0(a5)
 7b6:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 7ba:	87ae                	mv	a5,a1
 7bc:	02c5d5b3          	divu	a1,a1,a2
 7c0:	0685                	addi	a3,a3,1
 7c2:	fec7f1e3          	bgeu	a5,a2,7a4 <printint+0x2a>
  if (neg)
 7c6:	00030c63          	beqz	t1,7de <printint+0x64>
    buf[i++] = '-';
 7ca:	fd050793          	addi	a5,a0,-48
 7ce:	00878533          	add	a0,a5,s0
 7d2:	02d00793          	li	a5,45
 7d6:	fef50423          	sb	a5,-24(a0)
 7da:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 7de:	02e05563          	blez	a4,808 <printint+0x8e>
 7e2:	fc26                	sd	s1,56(sp)
 7e4:	377d                	addiw	a4,a4,-1
 7e6:	00e984b3          	add	s1,s3,a4
 7ea:	19fd                	addi	s3,s3,-1
 7ec:	99ba                	add	s3,s3,a4
 7ee:	1702                	slli	a4,a4,0x20
 7f0:	9301                	srli	a4,a4,0x20
 7f2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 7f6:	0004c583          	lbu	a1,0(s1)
 7fa:	854a                	mv	a0,s2
 7fc:	f61ff0ef          	jal	75c <putc>
  while (--i >= 0)
 800:	14fd                	addi	s1,s1,-1
 802:	ff349ae3          	bne	s1,s3,7f6 <printint+0x7c>
 806:	74e2                	ld	s1,56(sp)
}
 808:	60a6                	ld	ra,72(sp)
 80a:	6406                	ld	s0,64(sp)
 80c:	7942                	ld	s2,48(sp)
 80e:	79a2                	ld	s3,40(sp)
 810:	6161                	addi	sp,sp,80
 812:	8082                	ret
  neg = 0;
 814:	4301                	li	t1,0
 816:	bfbd                	j	794 <printint+0x1a>

0000000000000818 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 818:	711d                	addi	sp,sp,-96
 81a:	ec86                	sd	ra,88(sp)
 81c:	e8a2                	sd	s0,80(sp)
 81e:	e4a6                	sd	s1,72(sp)
 820:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 822:	0005c483          	lbu	s1,0(a1)
 826:	22048363          	beqz	s1,a4c <vprintf+0x234>
 82a:	e0ca                	sd	s2,64(sp)
 82c:	fc4e                	sd	s3,56(sp)
 82e:	f852                	sd	s4,48(sp)
 830:	f456                	sd	s5,40(sp)
 832:	f05a                	sd	s6,32(sp)
 834:	ec5e                	sd	s7,24(sp)
 836:	e862                	sd	s8,16(sp)
 838:	8b2a                	mv	s6,a0
 83a:	8a2e                	mv	s4,a1
 83c:	8bb2                	mv	s7,a2
  state = 0;
 83e:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 840:	4901                	li	s2,0
 842:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 844:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 848:	06400c13          	li	s8,100
 84c:	a00d                	j	86e <vprintf+0x56>
        putc(fd, c0);
 84e:	85a6                	mv	a1,s1
 850:	855a                	mv	a0,s6
 852:	f0bff0ef          	jal	75c <putc>
 856:	a019                	j	85c <vprintf+0x44>
    } else if (state == '%') {
 858:	03598363          	beq	s3,s5,87e <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 85c:	0019079b          	addiw	a5,s2,1
 860:	893e                	mv	s2,a5
 862:	873e                	mv	a4,a5
 864:	97d2                	add	a5,a5,s4
 866:	0007c483          	lbu	s1,0(a5)
 86a:	1c048a63          	beqz	s1,a3e <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 86e:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 872:	fe0993e3          	bnez	s3,858 <vprintf+0x40>
      if (c0 == '%') {
 876:	fd579ce3          	bne	a5,s5,84e <vprintf+0x36>
        state = '%';
 87a:	89be                	mv	s3,a5
 87c:	b7c5                	j	85c <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 87e:	00ea06b3          	add	a3,s4,a4
 882:	0016c603          	lbu	a2,1(a3)
      if (c1)
 886:	1c060863          	beqz	a2,a56 <vprintf+0x23e>
      if (c0 == 'd') {
 88a:	03878763          	beq	a5,s8,8b8 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 88e:	f9478693          	addi	a3,a5,-108
 892:	0016b693          	seqz	a3,a3
 896:	f9c60593          	addi	a1,a2,-100
 89a:	e99d                	bnez	a1,8d0 <vprintf+0xb8>
 89c:	ca95                	beqz	a3,8d0 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 89e:	008b8493          	addi	s1,s7,8
 8a2:	4685                	li	a3,1
 8a4:	4629                	li	a2,10
 8a6:	000bb583          	ld	a1,0(s7)
 8aa:	855a                	mv	a0,s6
 8ac:	ecfff0ef          	jal	77a <printint>
        i += 1;
 8b0:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 8b2:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 8b4:	4981                	li	s3,0
 8b6:	b75d                	j	85c <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 8b8:	008b8493          	addi	s1,s7,8
 8bc:	4685                	li	a3,1
 8be:	4629                	li	a2,10
 8c0:	000ba583          	lw	a1,0(s7)
 8c4:	855a                	mv	a0,s6
 8c6:	eb5ff0ef          	jal	77a <printint>
 8ca:	8ba6                	mv	s7,s1
      state = 0;
 8cc:	4981                	li	s3,0
 8ce:	b779                	j	85c <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 8d0:	9752                	add	a4,a4,s4
 8d2:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 8d6:	f9460713          	addi	a4,a2,-108
 8da:	00173713          	seqz	a4,a4
 8de:	8f75                	and	a4,a4,a3
 8e0:	f9c58513          	addi	a0,a1,-100
 8e4:	18051363          	bnez	a0,a6a <vprintf+0x252>
 8e8:	18070163          	beqz	a4,a6a <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 8ec:	008b8493          	addi	s1,s7,8
 8f0:	4685                	li	a3,1
 8f2:	4629                	li	a2,10
 8f4:	000bb583          	ld	a1,0(s7)
 8f8:	855a                	mv	a0,s6
 8fa:	e81ff0ef          	jal	77a <printint>
        i += 2;
 8fe:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 900:	8ba6                	mv	s7,s1
      state = 0;
 902:	4981                	li	s3,0
        i += 2;
 904:	bfa1                	j	85c <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 906:	008b8493          	addi	s1,s7,8
 90a:	4681                	li	a3,0
 90c:	4629                	li	a2,10
 90e:	000be583          	lwu	a1,0(s7)
 912:	855a                	mv	a0,s6
 914:	e67ff0ef          	jal	77a <printint>
 918:	8ba6                	mv	s7,s1
      state = 0;
 91a:	4981                	li	s3,0
 91c:	b781                	j	85c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 91e:	008b8493          	addi	s1,s7,8
 922:	4681                	li	a3,0
 924:	4629                	li	a2,10
 926:	000bb583          	ld	a1,0(s7)
 92a:	855a                	mv	a0,s6
 92c:	e4fff0ef          	jal	77a <printint>
        i += 1;
 930:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 932:	8ba6                	mv	s7,s1
      state = 0;
 934:	4981                	li	s3,0
 936:	b71d                	j	85c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 938:	008b8493          	addi	s1,s7,8
 93c:	4681                	li	a3,0
 93e:	4629                	li	a2,10
 940:	000bb583          	ld	a1,0(s7)
 944:	855a                	mv	a0,s6
 946:	e35ff0ef          	jal	77a <printint>
        i += 2;
 94a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 94c:	8ba6                	mv	s7,s1
      state = 0;
 94e:	4981                	li	s3,0
        i += 2;
 950:	b731                	j	85c <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 952:	008b8493          	addi	s1,s7,8
 956:	4681                	li	a3,0
 958:	4641                	li	a2,16
 95a:	000be583          	lwu	a1,0(s7)
 95e:	855a                	mv	a0,s6
 960:	e1bff0ef          	jal	77a <printint>
 964:	8ba6                	mv	s7,s1
      state = 0;
 966:	4981                	li	s3,0
 968:	bdd5                	j	85c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 96a:	008b8493          	addi	s1,s7,8
 96e:	4681                	li	a3,0
 970:	4641                	li	a2,16
 972:	000bb583          	ld	a1,0(s7)
 976:	855a                	mv	a0,s6
 978:	e03ff0ef          	jal	77a <printint>
        i += 1;
 97c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 97e:	8ba6                	mv	s7,s1
      state = 0;
 980:	4981                	li	s3,0
 982:	bde9                	j	85c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 984:	008b8493          	addi	s1,s7,8
 988:	4681                	li	a3,0
 98a:	4641                	li	a2,16
 98c:	000bb583          	ld	a1,0(s7)
 990:	855a                	mv	a0,s6
 992:	de9ff0ef          	jal	77a <printint>
        i += 2;
 996:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 998:	8ba6                	mv	s7,s1
      state = 0;
 99a:	4981                	li	s3,0
        i += 2;
 99c:	b5c1                	j	85c <vprintf+0x44>
 99e:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 9a0:	008b8793          	addi	a5,s7,8
 9a4:	8cbe                	mv	s9,a5
 9a6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 9aa:	03000593          	li	a1,48
 9ae:	855a                	mv	a0,s6
 9b0:	dadff0ef          	jal	75c <putc>
  putc(fd, 'x');
 9b4:	07800593          	li	a1,120
 9b8:	855a                	mv	a0,s6
 9ba:	da3ff0ef          	jal	75c <putc>
 9be:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 9c0:	00000b97          	auipc	s7,0x0
 9c4:	7b0b8b93          	addi	s7,s7,1968 # 1170 <digits>
 9c8:	03c9d793          	srli	a5,s3,0x3c
 9cc:	97de                	add	a5,a5,s7
 9ce:	0007c583          	lbu	a1,0(a5)
 9d2:	855a                	mv	a0,s6
 9d4:	d89ff0ef          	jal	75c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 9d8:	0992                	slli	s3,s3,0x4
 9da:	34fd                	addiw	s1,s1,-1
 9dc:	f4f5                	bnez	s1,9c8 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 9de:	8be6                	mv	s7,s9
      state = 0;
 9e0:	4981                	li	s3,0
 9e2:	6ca2                	ld	s9,8(sp)
 9e4:	bda5                	j	85c <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 9e6:	008b8493          	addi	s1,s7,8
 9ea:	000bc583          	lbu	a1,0(s7)
 9ee:	855a                	mv	a0,s6
 9f0:	d6dff0ef          	jal	75c <putc>
 9f4:	8ba6                	mv	s7,s1
      state = 0;
 9f6:	4981                	li	s3,0
 9f8:	b595                	j	85c <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 9fa:	008b8993          	addi	s3,s7,8
 9fe:	000bb483          	ld	s1,0(s7)
 a02:	cc91                	beqz	s1,a1e <vprintf+0x206>
        for (; *s; s++)
 a04:	0004c583          	lbu	a1,0(s1)
 a08:	c985                	beqz	a1,a38 <vprintf+0x220>
          putc(fd, *s);
 a0a:	855a                	mv	a0,s6
 a0c:	d51ff0ef          	jal	75c <putc>
        for (; *s; s++)
 a10:	0485                	addi	s1,s1,1
 a12:	0004c583          	lbu	a1,0(s1)
 a16:	f9f5                	bnez	a1,a0a <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 a18:	8bce                	mv	s7,s3
      state = 0;
 a1a:	4981                	li	s3,0
 a1c:	b581                	j	85c <vprintf+0x44>
          s = "(null)";
 a1e:	00000497          	auipc	s1,0x0
 a22:	74a48493          	addi	s1,s1,1866 # 1168 <malloc+0x5ae>
        for (; *s; s++)
 a26:	02800593          	li	a1,40
 a2a:	b7c5                	j	a0a <vprintf+0x1f2>
        putc(fd, '%');
 a2c:	85be                	mv	a1,a5
 a2e:	855a                	mv	a0,s6
 a30:	d2dff0ef          	jal	75c <putc>
      state = 0;
 a34:	4981                	li	s3,0
 a36:	b51d                	j	85c <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 a38:	8bce                	mv	s7,s3
      state = 0;
 a3a:	4981                	li	s3,0
 a3c:	b505                	j	85c <vprintf+0x44>
 a3e:	6906                	ld	s2,64(sp)
 a40:	79e2                	ld	s3,56(sp)
 a42:	7a42                	ld	s4,48(sp)
 a44:	7aa2                	ld	s5,40(sp)
 a46:	7b02                	ld	s6,32(sp)
 a48:	6be2                	ld	s7,24(sp)
 a4a:	6c42                	ld	s8,16(sp)
    }
  }
}
 a4c:	60e6                	ld	ra,88(sp)
 a4e:	6446                	ld	s0,80(sp)
 a50:	64a6                	ld	s1,72(sp)
 a52:	6125                	addi	sp,sp,96
 a54:	8082                	ret
      if (c0 == 'd') {
 a56:	06400713          	li	a4,100
 a5a:	e4e78fe3          	beq	a5,a4,8b8 <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 a5e:	f9478693          	addi	a3,a5,-108
 a62:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 a66:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 a68:	4701                	li	a4,0
      } else if (c0 == 'u') {
 a6a:	07500513          	li	a0,117
 a6e:	e8a78ce3          	beq	a5,a0,906 <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 a72:	f8b60513          	addi	a0,a2,-117
 a76:	e119                	bnez	a0,a7c <vprintf+0x264>
 a78:	ea0693e3          	bnez	a3,91e <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 a7c:	f8b58513          	addi	a0,a1,-117
 a80:	e119                	bnez	a0,a86 <vprintf+0x26e>
 a82:	ea071be3          	bnez	a4,938 <vprintf+0x120>
      } else if (c0 == 'x') {
 a86:	07800513          	li	a0,120
 a8a:	eca784e3          	beq	a5,a0,952 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 a8e:	f8860613          	addi	a2,a2,-120
 a92:	e219                	bnez	a2,a98 <vprintf+0x280>
 a94:	ec069be3          	bnez	a3,96a <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 a98:	f8858593          	addi	a1,a1,-120
 a9c:	e199                	bnez	a1,aa2 <vprintf+0x28a>
 a9e:	ee0713e3          	bnez	a4,984 <vprintf+0x16c>
      } else if (c0 == 'p') {
 aa2:	07000713          	li	a4,112
 aa6:	eee78ce3          	beq	a5,a4,99e <vprintf+0x186>
      } else if (c0 == 'c') {
 aaa:	06300713          	li	a4,99
 aae:	f2e78ce3          	beq	a5,a4,9e6 <vprintf+0x1ce>
      } else if (c0 == 's') {
 ab2:	07300713          	li	a4,115
 ab6:	f4e782e3          	beq	a5,a4,9fa <vprintf+0x1e2>
      } else if (c0 == '%') {
 aba:	02500713          	li	a4,37
 abe:	f6e787e3          	beq	a5,a4,a2c <vprintf+0x214>
        putc(fd, '%');
 ac2:	02500593          	li	a1,37
 ac6:	855a                	mv	a0,s6
 ac8:	c95ff0ef          	jal	75c <putc>
        putc(fd, c0);
 acc:	85a6                	mv	a1,s1
 ace:	855a                	mv	a0,s6
 ad0:	c8dff0ef          	jal	75c <putc>
      state = 0;
 ad4:	4981                	li	s3,0
 ad6:	b359                	j	85c <vprintf+0x44>

0000000000000ad8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 ad8:	715d                	addi	sp,sp,-80
 ada:	ec06                	sd	ra,24(sp)
 adc:	e822                	sd	s0,16(sp)
 ade:	1000                	addi	s0,sp,32
 ae0:	e010                	sd	a2,0(s0)
 ae2:	e414                	sd	a3,8(s0)
 ae4:	e818                	sd	a4,16(s0)
 ae6:	ec1c                	sd	a5,24(s0)
 ae8:	03043023          	sd	a6,32(s0)
 aec:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 af0:	8622                	mv	a2,s0
 af2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 af6:	d23ff0ef          	jal	818 <vprintf>
}
 afa:	60e2                	ld	ra,24(sp)
 afc:	6442                	ld	s0,16(sp)
 afe:	6161                	addi	sp,sp,80
 b00:	8082                	ret

0000000000000b02 <printf>:

void
printf(const char *fmt, ...)
{
 b02:	711d                	addi	sp,sp,-96
 b04:	ec06                	sd	ra,24(sp)
 b06:	e822                	sd	s0,16(sp)
 b08:	1000                	addi	s0,sp,32
 b0a:	e40c                	sd	a1,8(s0)
 b0c:	e810                	sd	a2,16(s0)
 b0e:	ec14                	sd	a3,24(s0)
 b10:	f018                	sd	a4,32(s0)
 b12:	f41c                	sd	a5,40(s0)
 b14:	03043823          	sd	a6,48(s0)
 b18:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 b1c:	00840613          	addi	a2,s0,8
 b20:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 b24:	85aa                	mv	a1,a0
 b26:	4505                	li	a0,1
 b28:	cf1ff0ef          	jal	818 <vprintf>
}
 b2c:	60e2                	ld	ra,24(sp)
 b2e:	6442                	ld	s0,16(sp)
 b30:	6125                	addi	sp,sp,96
 b32:	8082                	ret

0000000000000b34 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b34:	1141                	addi	sp,sp,-16
 b36:	e406                	sd	ra,8(sp)
 b38:	e022                	sd	s0,0(sp)
 b3a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 b3c:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b40:	00001797          	auipc	a5,0x1
 b44:	4c07b783          	ld	a5,1216(a5) # 2000 <freep>
 b48:	a039                	j	b56 <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b4a:	6398                	ld	a4,0(a5)
 b4c:	00e7e463          	bltu	a5,a4,b54 <free+0x20>
 b50:	00e6ea63          	bltu	a3,a4,b64 <free+0x30>
{
 b54:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b56:	fed7fae3          	bgeu	a5,a3,b4a <free+0x16>
 b5a:	6398                	ld	a4,0(a5)
 b5c:	00e6e463          	bltu	a3,a4,b64 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b60:	fee7eae3          	bltu	a5,a4,b54 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 b64:	ff852583          	lw	a1,-8(a0)
 b68:	6390                	ld	a2,0(a5)
 b6a:	02059813          	slli	a6,a1,0x20
 b6e:	01c85713          	srli	a4,a6,0x1c
 b72:	9736                	add	a4,a4,a3
 b74:	02e60563          	beq	a2,a4,b9e <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 b78:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 b7c:	4790                	lw	a2,8(a5)
 b7e:	02061593          	slli	a1,a2,0x20
 b82:	01c5d713          	srli	a4,a1,0x1c
 b86:	973e                	add	a4,a4,a5
 b88:	02e68263          	beq	a3,a4,bac <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 b8c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 b8e:	00001717          	auipc	a4,0x1
 b92:	46f73923          	sd	a5,1138(a4) # 2000 <freep>
}
 b96:	60a2                	ld	ra,8(sp)
 b98:	6402                	ld	s0,0(sp)
 b9a:	0141                	addi	sp,sp,16
 b9c:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 b9e:	4618                	lw	a4,8(a2)
 ba0:	9f2d                	addw	a4,a4,a1
 ba2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 ba6:	6398                	ld	a4,0(a5)
 ba8:	6310                	ld	a2,0(a4)
 baa:	b7f9                	j	b78 <free+0x44>
    p->s.size += bp->s.size;
 bac:	ff852703          	lw	a4,-8(a0)
 bb0:	9f31                	addw	a4,a4,a2
 bb2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 bb4:	ff053683          	ld	a3,-16(a0)
 bb8:	bfd1                	j	b8c <free+0x58>

0000000000000bba <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 bba:	7139                	addi	sp,sp,-64
 bbc:	fc06                	sd	ra,56(sp)
 bbe:	f822                	sd	s0,48(sp)
 bc0:	f04a                	sd	s2,32(sp)
 bc2:	ec4e                	sd	s3,24(sp)
 bc4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 bc6:	02051993          	slli	s3,a0,0x20
 bca:	0209d993          	srli	s3,s3,0x20
 bce:	09bd                	addi	s3,s3,15
 bd0:	0049d993          	srli	s3,s3,0x4
 bd4:	2985                	addiw	s3,s3,1
 bd6:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 bd8:	00001517          	auipc	a0,0x1
 bdc:	42853503          	ld	a0,1064(a0) # 2000 <freep>
 be0:	c905                	beqz	a0,c10 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 be2:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 be4:	4798                	lw	a4,8(a5)
 be6:	09377663          	bgeu	a4,s3,c72 <malloc+0xb8>
 bea:	f426                	sd	s1,40(sp)
 bec:	e852                	sd	s4,16(sp)
 bee:	e456                	sd	s5,8(sp)
 bf0:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 bf2:	8a4e                	mv	s4,s3
 bf4:	6705                	lui	a4,0x1
 bf6:	00e9f363          	bgeu	s3,a4,bfc <malloc+0x42>
 bfa:	6a05                	lui	s4,0x1
 bfc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 c00:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 c04:	00001497          	auipc	s1,0x1
 c08:	3fc48493          	addi	s1,s1,1020 # 2000 <freep>
  if (p == SBRK_ERROR)
 c0c:	5afd                	li	s5,-1
 c0e:	a83d                	j	c4c <malloc+0x92>
 c10:	f426                	sd	s1,40(sp)
 c12:	e852                	sd	s4,16(sp)
 c14:	e456                	sd	s5,8(sp)
 c16:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 c18:	00001797          	auipc	a5,0x1
 c1c:	3f878793          	addi	a5,a5,1016 # 2010 <base>
 c20:	00001717          	auipc	a4,0x1
 c24:	3ef73023          	sd	a5,992(a4) # 2000 <freep>
 c28:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 c2a:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 c2e:	b7d1                	j	bf2 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 c30:	6398                	ld	a4,0(a5)
 c32:	e118                	sd	a4,0(a0)
 c34:	a899                	j	c8a <malloc+0xd0>
  hp->s.size = nu;
 c36:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 c3a:	0541                	addi	a0,a0,16
 c3c:	ef9ff0ef          	jal	b34 <free>
  return freep;
 c40:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 c42:	c125                	beqz	a0,ca2 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 c44:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 c46:	4798                	lw	a4,8(a5)
 c48:	03277163          	bgeu	a4,s2,c6a <malloc+0xb0>
    if (p == freep)
 c4c:	6098                	ld	a4,0(s1)
 c4e:	853e                	mv	a0,a5
 c50:	fef71ae3          	bne	a4,a5,c44 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 c54:	8552                	mv	a0,s4
 c56:	a0bff0ef          	jal	660 <sbrk>
  if (p == SBRK_ERROR)
 c5a:	fd551ee3          	bne	a0,s5,c36 <malloc+0x7c>
        return 0;
 c5e:	4501                	li	a0,0
 c60:	74a2                	ld	s1,40(sp)
 c62:	6a42                	ld	s4,16(sp)
 c64:	6aa2                	ld	s5,8(sp)
 c66:	6b02                	ld	s6,0(sp)
 c68:	a03d                	j	c96 <malloc+0xdc>
 c6a:	74a2                	ld	s1,40(sp)
 c6c:	6a42                	ld	s4,16(sp)
 c6e:	6aa2                	ld	s5,8(sp)
 c70:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 c72:	fae90fe3          	beq	s2,a4,c30 <malloc+0x76>
        p->s.size -= nunits;
 c76:	4137073b          	subw	a4,a4,s3
 c7a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 c7c:	02071693          	slli	a3,a4,0x20
 c80:	01c6d713          	srli	a4,a3,0x1c
 c84:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c86:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c8a:	00001717          	auipc	a4,0x1
 c8e:	36a73b23          	sd	a0,886(a4) # 2000 <freep>
      return (void *)(p + 1);
 c92:	01078513          	addi	a0,a5,16
  }
}
 c96:	70e2                	ld	ra,56(sp)
 c98:	7442                	ld	s0,48(sp)
 c9a:	7902                	ld	s2,32(sp)
 c9c:	69e2                	ld	s3,24(sp)
 c9e:	6121                	addi	sp,sp,64
 ca0:	8082                	ret
 ca2:	74a2                	ld	s1,40(sp)
 ca4:	6a42                	ld	s4,16(sp)
 ca6:	6aa2                	ld	s5,8(sp)
 ca8:	6b02                	ld	s6,0(sp)
 caa:	b7f5                	j	c96 <malloc+0xdc>
