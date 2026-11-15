
user/_syncdeadlock:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <run_process>:
  {RES_PRINTER, RES_DISK},    // P2 needs Printer & Disk
  {RES_PRINTER, RES_SCANNER}, // P3 needs Printer & Scanner
  {RES_SCANNER, RES_DISK}     // P4 needs Scanner & Disk
};

void run_process(struct shared_state *sh, int id) {
   0:	7135                	addi	sp,sp,-160
   2:	ed06                	sd	ra,152(sp)
   4:	e922                	sd	s0,144(sp)
   6:	e526                	sd	s1,136(sp)
   8:	e14a                	sd	s2,128(sp)
   a:	fcce                	sd	s3,120(sp)
   c:	f8d2                	sd	s4,112(sp)
   e:	f4d6                	sd	s5,104(sp)
  10:	f0da                	sd	s6,96(sp)
  12:	ecde                	sd	s7,88(sp)
  14:	e8e2                	sd	s8,80(sp)
  16:	e4e6                	sd	s9,72(sp)
  18:	e0ea                	sd	s10,64(sp)
  1a:	fc6e                	sd	s11,56(sp)
  1c:	1100                	addi	s0,sp,160
  1e:	8a2a                	mv	s4,a0
  20:	8aae                	mv	s5,a1
  int r1 = proc_needs[id][0];
  22:	00359793          	slli	a5,a1,0x3
  26:	00002717          	auipc	a4,0x2
  2a:	fda70713          	addi	a4,a4,-38 # 2000 <proc_needs>
  2e:	973e                	add	a4,a4,a5
  30:	431c                	lw	a5,0(a4)
  int r2 = proc_needs[id][1];
  32:	4358                	lw	a4,4(a4)

  // Resource ordering deadlock avoidance strategy:
  // Strictly request lower-numbered resource type first, then higher-numbered.
  int first = (r1 < r2) ? r1 : r2;
  34:	86be                	mv	a3,a5
  36:	00f75363          	bge	a4,a5,3c <run_process+0x3c>
  3a:	86ba                	mv	a3,a4
  3c:	2681                	sext.w	a3,a3
  3e:	f8d43423          	sd	a3,-120(s0)
  int second = (r1 < r2) ? r2 : r1;
  42:	86be                	mv	a3,a5
  44:	00e7d363          	bge	a5,a4,4a <run_process+0x4a>
  48:	86ba                	mv	a3,a4
  4a:	0006879b          	sext.w	a5,a3
  4e:	f8f43023          	sd	a5,-128(s0)

  for (int cycle = 1; cycle <= NUM_CYCLES; cycle++) {
  52:	4c85                	li	s9,1
    // 1. Request first resource
    sem_wait(SEM_MUTEX);
  54:	490d                	li	s2,3
    printf("[Proc %d (pid %d)]: Requesting %s (first resource)...\n",
  56:	00001d17          	auipc	s10,0x1
  5a:	1fad0d13          	addi	s10,s10,506 # 1250 <res_names>
  5e:	f8843703          	ld	a4,-120(s0)
  62:	00371793          	slli	a5,a4,0x3
  66:	97ea                	add	a5,a5,s10
  68:	f6f43423          	sd	a5,-152(s0)
  6c:	00271793          	slli	a5,a4,0x2
  70:	f6f43023          	sd	a5,-160(s0)
  74:	00fa0c33          	add	s8,s4,a5
    sem_wait(SEM_MUTEX);
  78:	854a                	mv	a0,s2
  7a:	752000ef          	jal	7cc <sem_wait>
    printf("[Proc %d (pid %d)]: Requesting %s (first resource)...\n",
  7e:	716000ef          	jal	794 <getpid>
  82:	862a                	mv	a2,a0
  84:	f6843783          	ld	a5,-152(s0)
  88:	6384                	ld	s1,0(a5)
  8a:	f6943c23          	sd	s1,-136(s0)
  8e:	86a6                	mv	a3,s1
  90:	85d6                	mv	a1,s5
  92:	00001517          	auipc	a0,0x1
  96:	c9e50513          	addi	a0,a0,-866 # d30 <malloc+0xf6>
  9a:	2e9000ef          	jal	b82 <printf>
           id, getpid(), res_names[first]);
    sem_post(SEM_MUTEX);
  9e:	854a                	mv	a0,s2
  a0:	734000ef          	jal	7d4 <sem_post>

    sem_wait(first);
  a4:	f8843503          	ld	a0,-120(s0)
  a8:	724000ef          	jal	7cc <sem_wait>

    sem_wait(SEM_MUTEX);
  ac:	854a                	mv	a0,s2
  ae:	71e000ef          	jal	7cc <sem_wait>
    sh->in_use[first]++;
  b2:	000c2783          	lw	a5,0(s8)
  b6:	2785                	addiw	a5,a5,1
  b8:	00fc2023          	sw	a5,0(s8)
    printf("[Proc %d (pid %d)]: GRANTED %s (In use: %d/%d)\n",
  bc:	6d8000ef          	jal	794 <getpid>
  c0:	862a                	mv	a2,a0
  c2:	f6043783          	ld	a5,-160(s0)
  c6:	97ea                	add	a5,a5,s10
  c8:	4f9c                	lw	a5,24(a5)
  ca:	000c2703          	lw	a4,0(s8)
  ce:	86a6                	mv	a3,s1
  d0:	85d6                	mv	a1,s5
  d2:	00001517          	auipc	a0,0x1
  d6:	c9e50513          	addi	a0,a0,-866 # d70 <malloc+0x136>
  da:	2a9000ef          	jal	b82 <printf>
           id, getpid(), res_names[first], sh->in_use[first], res_capacities[first]);
    sem_post(SEM_MUTEX);
  de:	854a                	mv	a0,s2
  e0:	6f4000ef          	jal	7d4 <sem_post>

    // 2. Request second resource
    sem_wait(SEM_MUTEX);
  e4:	854a                	mv	a0,s2
  e6:	6e6000ef          	jal	7cc <sem_wait>
    printf("[Proc %d (pid %d)]: Requesting %s (second resource)...\n",
  ea:	6aa000ef          	jal	794 <getpid>
  ee:	862a                	mv	a2,a0
  f0:	f8043483          	ld	s1,-128(s0)
  f4:	00349793          	slli	a5,s1,0x3
  f8:	97ea                	add	a5,a5,s10
  fa:	0007b983          	ld	s3,0(a5)
  fe:	f7343823          	sd	s3,-144(s0)
 102:	86ce                	mv	a3,s3
 104:	85d6                	mv	a1,s5
 106:	00001517          	auipc	a0,0x1
 10a:	c9a50513          	addi	a0,a0,-870 # da0 <malloc+0x166>
 10e:	275000ef          	jal	b82 <printf>
           id, getpid(), res_names[second]);
    sem_post(SEM_MUTEX);
 112:	854a                	mv	a0,s2
 114:	6c0000ef          	jal	7d4 <sem_post>

    sem_wait(second);
 118:	8526                	mv	a0,s1
 11a:	6b2000ef          	jal	7cc <sem_wait>

    sem_wait(SEM_MUTEX);
 11e:	854a                	mv	a0,s2
 120:	6ac000ef          	jal	7cc <sem_wait>
    sh->in_use[second]++;
 124:	048a                	slli	s1,s1,0x2
 126:	009a0bb3          	add	s7,s4,s1
 12a:	000ba783          	lw	a5,0(s7)
 12e:	2785                	addiw	a5,a5,1
 130:	00fba023          	sw	a5,0(s7)
    printf("[Proc %d (pid %d)]: GRANTED %s (In use: %d/%d)\n",
 134:	660000ef          	jal	794 <getpid>
 138:	862a                	mv	a2,a0
 13a:	94ea                	add	s1,s1,s10
 13c:	4c9c                	lw	a5,24(s1)
 13e:	000ba703          	lw	a4,0(s7)
 142:	86ce                	mv	a3,s3
 144:	85d6                	mv	a1,s5
 146:	00001517          	auipc	a0,0x1
 14a:	c2a50513          	addi	a0,a0,-982 # d70 <malloc+0x136>
 14e:	235000ef          	jal	b82 <printf>
           id, getpid(), res_names[second], sh->in_use[second], res_capacities[second]);

    // Check invariants
    for (int k = 0; k < NUM_RES_TYPES; k++) {
 152:	84d2                	mv	s1,s4
 154:	00001997          	auipc	s3,0x1
 158:	11498993          	addi	s3,s3,276 # 1268 <res_capacities>
 15c:	00001b17          	auipc	s6,0x1
 160:	0f4b0b13          	addi	s6,s6,244 # 1250 <res_names>
 164:	00ca0d93          	addi	s11,s4,12
      if (sh->in_use[k] > res_capacities[k]) {
 168:	4090                	lw	a2,0(s1)
 16a:	0009a683          	lw	a3,0(s3)
 16e:	0ec6c163          	blt	a3,a2,250 <run_process+0x250>
    for (int k = 0; k < NUM_RES_TYPES; k++) {
 172:	0491                	addi	s1,s1,4
 174:	0991                	addi	s3,s3,4
 176:	0b21                	addi	s6,s6,8
 178:	ffb498e3          	bne	s1,s11,168 <run_process+0x168>
               res_names[k], sh->in_use[k], res_capacities[k]);
        sh->violations++;
      }
    }

    printf("[Proc %d (pid %d)]: Holding [%s, %s]. STARTING WORK (Cycle %d/%d)...\n",
 17c:	618000ef          	jal	794 <getpid>
 180:	862a                	mv	a2,a0
 182:	884a                	mv	a6,s2
 184:	87e6                	mv	a5,s9
 186:	f7043983          	ld	s3,-144(s0)
 18a:	874e                	mv	a4,s3
 18c:	f7843483          	ld	s1,-136(s0)
 190:	86a6                	mv	a3,s1
 192:	85d6                	mv	a1,s5
 194:	00001517          	auipc	a0,0x1
 198:	c8450513          	addi	a0,a0,-892 # e18 <malloc+0x1de>
 19c:	1e7000ef          	jal	b82 <printf>
           id, getpid(), res_names[first], res_names[second], cycle, NUM_CYCLES);
    sem_post(SEM_MUTEX);
 1a0:	854a                	mv	a0,s2
 1a2:	632000ef          	jal	7d4 <sem_post>

    // Simulate task execution
    pause(2);
 1a6:	4509                	li	a0,2
 1a8:	5fc000ef          	jal	7a4 <pause>

    // 3. Release resources
    sem_wait(SEM_MUTEX);
 1ac:	854a                	mv	a0,s2
 1ae:	61e000ef          	jal	7cc <sem_wait>
    sh->in_use[second]--;
 1b2:	000ba783          	lw	a5,0(s7)
 1b6:	37fd                	addiw	a5,a5,-1
 1b8:	00fba023          	sw	a5,0(s7)
    sh->in_use[first]--;
 1bc:	000c2783          	lw	a5,0(s8)
 1c0:	37fd                	addiw	a5,a5,-1
 1c2:	00fc2023          	sw	a5,0(s8)
    sh->completed[id]++;
 1c6:	002a9793          	slli	a5,s5,0x2
 1ca:	97d2                	add	a5,a5,s4
 1cc:	47d8                	lw	a4,12(a5)
 1ce:	2705                	addiw	a4,a4,1
 1d0:	c7d8                	sw	a4,12(a5)
    sh->total_tasks++;
 1d2:	024a2783          	lw	a5,36(s4)
 1d6:	2785                	addiw	a5,a5,1
 1d8:	02fa2223          	sw	a5,36(s4)
    printf("[Proc %d (pid %d)]: FINISHED WORK. Released [%s, %s] (Cycle %d/%d done).\n",
 1dc:	5b8000ef          	jal	794 <getpid>
 1e0:	862a                	mv	a2,a0
 1e2:	884a                	mv	a6,s2
 1e4:	87e6                	mv	a5,s9
 1e6:	874e                	mv	a4,s3
 1e8:	86a6                	mv	a3,s1
 1ea:	85d6                	mv	a1,s5
 1ec:	00001517          	auipc	a0,0x1
 1f0:	c7450513          	addi	a0,a0,-908 # e60 <malloc+0x226>
 1f4:	18f000ef          	jal	b82 <printf>
           id, getpid(), res_names[first], res_names[second], cycle, NUM_CYCLES);
    sem_post(SEM_MUTEX);
 1f8:	854a                	mv	a0,s2
 1fa:	5da000ef          	jal	7d4 <sem_post>

    sem_post(second);
 1fe:	f8043503          	ld	a0,-128(s0)
 202:	5d2000ef          	jal	7d4 <sem_post>
    sem_post(first);
 206:	f8843503          	ld	a0,-120(s0)
 20a:	5ca000ef          	jal	7d4 <sem_post>

    // Brief delay before next cycle
    pause(1);
 20e:	4505                	li	a0,1
 210:	594000ef          	jal	7a4 <pause>
  for (int cycle = 1; cycle <= NUM_CYCLES; cycle++) {
 214:	2c85                	addiw	s9,s9,1
 216:	4791                	li	a5,4
 218:	e6fc90e3          	bne	s9,a5,78 <run_process+0x78>
  }

  printf("[Proc %d (pid %d)]: Completed all %d cycles cleanly.\n",
 21c:	578000ef          	jal	794 <getpid>
 220:	862a                	mv	a2,a0
 222:	468d                	li	a3,3
 224:	85d6                	mv	a1,s5
 226:	00001517          	auipc	a0,0x1
 22a:	c8a50513          	addi	a0,a0,-886 # eb0 <malloc+0x276>
 22e:	155000ef          	jal	b82 <printf>
         id, getpid(), NUM_CYCLES);
}
 232:	60ea                	ld	ra,152(sp)
 234:	644a                	ld	s0,144(sp)
 236:	64aa                	ld	s1,136(sp)
 238:	690a                	ld	s2,128(sp)
 23a:	79e6                	ld	s3,120(sp)
 23c:	7a46                	ld	s4,112(sp)
 23e:	7aa6                	ld	s5,104(sp)
 240:	7b06                	ld	s6,96(sp)
 242:	6be6                	ld	s7,88(sp)
 244:	6c46                	ld	s8,80(sp)
 246:	6ca6                	ld	s9,72(sp)
 248:	6d06                	ld	s10,64(sp)
 24a:	7de2                	ld	s11,56(sp)
 24c:	610d                	addi	sp,sp,160
 24e:	8082                	ret
        printf("VIOLATION: Resource %s exceeded capacity! (Used: %d, Max: %d)\n",
 250:	000b3583          	ld	a1,0(s6)
 254:	00001517          	auipc	a0,0x1
 258:	b8450513          	addi	a0,a0,-1148 # dd8 <malloc+0x19e>
 25c:	127000ef          	jal	b82 <printf>
        sh->violations++;
 260:	020a2783          	lw	a5,32(s4)
 264:	2785                	addiw	a5,a5,1
 266:	02fa2023          	sw	a5,32(s4)
 26a:	b721                	j	172 <run_process+0x172>

000000000000026c <main>:

int main(int argc, char *argv[]) {
 26c:	7179                	addi	sp,sp,-48
 26e:	f406                	sd	ra,40(sp)
 270:	f022                	sd	s0,32(sp)
 272:	1800                	addi	s0,sp,48
  printf("============================================================\n");
 274:	00001517          	auipc	a0,0x1
 278:	c7450513          	addi	a0,a0,-908 # ee8 <malloc+0x2ae>
 27c:	107000ef          	jal	b82 <printf>
  printf(" Multi-Resource Synchronization with Deadlock Avoidance   \n");
 280:	00001517          	auipc	a0,0x1
 284:	ca850513          	addi	a0,a0,-856 # f28 <malloc+0x2ee>
 288:	0fb000ef          	jal	b82 <printf>
  printf(" Processes: 5, Resources: Printer(2), Scanner(1), Disk(2)   \n");
 28c:	00001517          	auipc	a0,0x1
 290:	cdc50513          	addi	a0,a0,-804 # f68 <malloc+0x32e>
 294:	0ef000ef          	jal	b82 <printf>
  printf(" Strategy : Resource Ordering (Hierarchy of Resources)      \n");
 298:	00001517          	auipc	a0,0x1
 29c:	d1050513          	addi	a0,a0,-752 # fa8 <malloc+0x36e>
 2a0:	0e3000ef          	jal	b82 <printf>
  printf(" Cycles   : %d per process (Total tasks = %d)               \n",
 2a4:	463d                	li	a2,15
 2a6:	458d                	li	a1,3
 2a8:	00001517          	auipc	a0,0x1
 2ac:	d4050513          	addi	a0,a0,-704 # fe8 <malloc+0x3ae>
 2b0:	0d3000ef          	jal	b82 <printf>
         NUM_CYCLES, NUM_PROCS * NUM_CYCLES);
  printf("============================================================\n");
 2b4:	00001517          	auipc	a0,0x1
 2b8:	c3450513          	addi	a0,a0,-972 # ee8 <malloc+0x2ae>
 2bc:	0c7000ef          	jal	b82 <printf>

  // Obtain shared memory page
  struct shared_state *sh = (struct shared_state *)shm_get();
 2c0:	4fc000ef          	jal	7bc <shm_get>
  if (sh == 0) {
 2c4:	cd31                	beqz	a0,320 <main+0xb4>
 2c6:	ec26                	sd	s1,24(sp)
 2c8:	e84a                	sd	s2,16(sp)
 2ca:	84aa                	mv	s1,a0
    exit(1);
  }

  // Initialize shared state
  for (int i = 0; i < NUM_RES_TYPES; i++) {
    sh->in_use[i] = 0;
 2cc:	00052023          	sw	zero,0(a0)
 2d0:	00052223          	sw	zero,4(a0)
 2d4:	00052423          	sw	zero,8(a0)
  }
  for (int i = 0; i < NUM_PROCS; i++) {
    sh->completed[i] = 0;
 2d8:	00052623          	sw	zero,12(a0)
 2dc:	00052823          	sw	zero,16(a0)
 2e0:	00052a23          	sw	zero,20(a0)
 2e4:	00052c23          	sw	zero,24(a0)
 2e8:	00052e23          	sw	zero,28(a0)
  }
  sh->violations = 0;
 2ec:	02052023          	sw	zero,32(a0)
  sh->total_tasks = 0;
 2f0:	02052223          	sw	zero,36(a0)
  // Initialize semaphores
  // SEM_PRINTER (0) = 2
  // SEM_SCANNER (1) = 1
  // SEM_DISK    (2) = 2
  // SEM_MUTEX   (3) = 1
  if (sem_init(RES_PRINTER, res_capacities[RES_PRINTER]) < 0 ||
 2f4:	4589                	li	a1,2
 2f6:	4501                	li	a0,0
 2f8:	4cc000ef          	jal	7c4 <sem_init>
 2fc:	00054863          	bltz	a0,30c <main+0xa0>
      sem_init(RES_SCANNER, res_capacities[RES_SCANNER]) < 0 ||
 300:	4585                	li	a1,1
 302:	852e                	mv	a0,a1
 304:	4c0000ef          	jal	7c4 <sem_init>
  if (sem_init(RES_PRINTER, res_capacities[RES_PRINTER]) < 0 ||
 308:	02055863          	bgez	a0,338 <main+0xcc>
 30c:	e44e                	sd	s3,8(sp)
      sem_init(RES_DISK,    res_capacities[RES_DISK]) < 0 ||
      sem_init(SEM_MUTEX,   1) < 0) {
    printf("Error: sem_init failed\n");
 30e:	00001517          	auipc	a0,0x1
 312:	d3250513          	addi	a0,a0,-718 # 1040 <malloc+0x406>
 316:	06d000ef          	jal	b82 <printf>
    exit(1);
 31a:	4505                	li	a0,1
 31c:	3f8000ef          	jal	714 <exit>
 320:	ec26                	sd	s1,24(sp)
 322:	e84a                	sd	s2,16(sp)
 324:	e44e                	sd	s3,8(sp)
    printf("Error: shm_get failed\n");
 326:	00001517          	auipc	a0,0x1
 32a:	d0250513          	addi	a0,a0,-766 # 1028 <malloc+0x3ee>
 32e:	055000ef          	jal	b82 <printf>
    exit(1);
 332:	4505                	li	a0,1
 334:	3e0000ef          	jal	714 <exit>
      sem_init(RES_DISK,    res_capacities[RES_DISK]) < 0 ||
 338:	4589                	li	a1,2
 33a:	852e                	mv	a0,a1
 33c:	488000ef          	jal	7c4 <sem_init>
      sem_init(RES_SCANNER, res_capacities[RES_SCANNER]) < 0 ||
 340:	fc0546e3          	bltz	a0,30c <main+0xa0>
      sem_init(SEM_MUTEX,   1) < 0) {
 344:	4585                	li	a1,1
 346:	450d                	li	a0,3
 348:	47c000ef          	jal	7c4 <sem_init>
  }

  // Fork 5 processes
  for (int i = 0; i < NUM_PROCS; i++) {
 34c:	4901                	li	s2,0
      sem_init(RES_DISK,    res_capacities[RES_DISK]) < 0 ||
 34e:	fa054fe3          	bltz	a0,30c <main+0xa0>
    int pid = fork();
 352:	3ba000ef          	jal	70c <fork>
    if (pid < 0) {
 356:	0a054863          	bltz	a0,406 <main+0x19a>
      printf("fork failed for proc %d\n", i);
      exit(1);
    }
    if (pid == 0) {
 35a:	c169                	beqz	a0,41c <main+0x1b0>
  for (int i = 0; i < NUM_PROCS; i++) {
 35c:	0019079b          	addiw	a5,s2,1
 360:	893e                	mv	s2,a5
 362:	4715                	li	a4,5
 364:	fee797e3          	bne	a5,a4,352 <main+0xe6>
 368:	e44e                	sd	s3,8(sp)
    }
  }

  // Wait for all 5 processes to finish
  for (int i = 0; i < NUM_PROCS; i++) {
    wait(0);
 36a:	4501                	li	a0,0
 36c:	3b0000ef          	jal	71c <wait>
  for (int i = 0; i < NUM_PROCS; i++) {
 370:	fff9079b          	addiw	a5,s2,-1
 374:	893e                	mv	s2,a5
 376:	fbf5                	bnez	a5,36a <main+0xfe>
  }

  int expected_total = NUM_PROCS * NUM_CYCLES;

  printf("============================================================\n");
 378:	00001517          	auipc	a0,0x1
 37c:	b7050513          	addi	a0,a0,-1168 # ee8 <malloc+0x2ae>
 380:	003000ef          	jal	b82 <printf>
  printf("Simulation Finished Summary:\n");
 384:	00001517          	auipc	a0,0x1
 388:	cf450513          	addi	a0,a0,-780 # 1078 <malloc+0x43e>
 38c:	7f6000ef          	jal	b82 <printf>
  for (int i = 0; i < NUM_PROCS; i++) {
 390:	00c48793          	addi	a5,s1,12
 394:	863e                	mv	a2,a5
 396:	4781                	li	a5,0
    printf("Process %d completed: %d / %d tasks.\n",
 398:	468d                	li	a3,3
 39a:	8932                	mv	s2,a2
 39c:	4210                	lw	a2,0(a2)
 39e:	89be                	mv	s3,a5
 3a0:	85be                	mv	a1,a5
 3a2:	00001517          	auipc	a0,0x1
 3a6:	cf650513          	addi	a0,a0,-778 # 1098 <malloc+0x45e>
 3aa:	7d8000ef          	jal	b82 <printf>
  for (int i = 0; i < NUM_PROCS; i++) {
 3ae:	0019879b          	addiw	a5,s3,1
 3b2:	00490713          	addi	a4,s2,4
 3b6:	863a                	mv	a2,a4
 3b8:	4715                	li	a4,5
 3ba:	fce79fe3          	bne	a5,a4,398 <main+0x12c>
           i, sh->completed[i], NUM_CYCLES);
  }
  printf("Total tasks completed: %d (Expected: %d)\n", sh->total_tasks, expected_total);
 3be:	463d                	li	a2,15
 3c0:	50cc                	lw	a1,36(s1)
 3c2:	00001517          	auipc	a0,0x1
 3c6:	cfe50513          	addi	a0,a0,-770 # 10c0 <malloc+0x486>
 3ca:	7b8000ef          	jal	b82 <printf>
  printf("Capacity violations: %d\n", sh->violations);
 3ce:	508c                	lw	a1,32(s1)
 3d0:	00001517          	auipc	a0,0x1
 3d4:	d2050513          	addi	a0,a0,-736 # 10f0 <malloc+0x4b6>
 3d8:	7aa000ef          	jal	b82 <printf>

  if (sh->total_tasks == expected_total && sh->violations == 0) {
 3dc:	50d8                	lw	a4,36(s1)
 3de:	47bd                	li	a5,15
 3e0:	00f71463          	bne	a4,a5,3e8 <main+0x17c>
 3e4:	509c                	lw	a5,32(s1)
 3e6:	c3b9                	beqz	a5,42c <main+0x1c0>
    printf("SUCCESS:\n");
    printf("  1. All 5 processes completed without any deadlock or starvation.\n");
    printf("  2. Resource capacities (Printer: 2, Scanner: 1, Disk: 2) were strictly preserved.\n");
    printf("  3. Resource ordering guaranteed acyclic wait-for relationships.\n");
  } else {
    printf("FAILURE: Simulation assertions failed!\n");
 3e8:	00001517          	auipc	a0,0x1
 3ec:	e2050513          	addi	a0,a0,-480 # 1208 <malloc+0x5ce>
 3f0:	792000ef          	jal	b82 <printf>
  }
  printf("============================================================\n");
 3f4:	00001517          	auipc	a0,0x1
 3f8:	af450513          	addi	a0,a0,-1292 # ee8 <malloc+0x2ae>
 3fc:	786000ef          	jal	b82 <printf>

  exit(0);
 400:	4501                	li	a0,0
 402:	312000ef          	jal	714 <exit>
 406:	e44e                	sd	s3,8(sp)
      printf("fork failed for proc %d\n", i);
 408:	85ca                	mv	a1,s2
 40a:	00001517          	auipc	a0,0x1
 40e:	c4e50513          	addi	a0,a0,-946 # 1058 <malloc+0x41e>
 412:	770000ef          	jal	b82 <printf>
      exit(1);
 416:	4505                	li	a0,1
 418:	2fc000ef          	jal	714 <exit>
 41c:	e44e                	sd	s3,8(sp)
      run_process(sh, i);
 41e:	85ca                	mv	a1,s2
 420:	8526                	mv	a0,s1
 422:	bdfff0ef          	jal	0 <run_process>
      exit(0);
 426:	4501                	li	a0,0
 428:	2ec000ef          	jal	714 <exit>
    printf("SUCCESS:\n");
 42c:	00001517          	auipc	a0,0x1
 430:	ce450513          	addi	a0,a0,-796 # 1110 <malloc+0x4d6>
 434:	74e000ef          	jal	b82 <printf>
    printf("  1. All 5 processes completed without any deadlock or starvation.\n");
 438:	00001517          	auipc	a0,0x1
 43c:	ce850513          	addi	a0,a0,-792 # 1120 <malloc+0x4e6>
 440:	742000ef          	jal	b82 <printf>
    printf("  2. Resource capacities (Printer: 2, Scanner: 1, Disk: 2) were strictly preserved.\n");
 444:	00001517          	auipc	a0,0x1
 448:	d2450513          	addi	a0,a0,-732 # 1168 <malloc+0x52e>
 44c:	736000ef          	jal	b82 <printf>
    printf("  3. Resource ordering guaranteed acyclic wait-for relationships.\n");
 450:	00001517          	auipc	a0,0x1
 454:	d7050513          	addi	a0,a0,-656 # 11c0 <malloc+0x586>
 458:	72a000ef          	jal	b82 <printf>
 45c:	bf61                	j	3f4 <main+0x188>

000000000000045e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 45e:	1141                	addi	sp,sp,-16
 460:	e406                	sd	ra,8(sp)
 462:	e022                	sd	s0,0(sp)
 464:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 466:	e07ff0ef          	jal	26c <main>
  exit(r);
 46a:	2aa000ef          	jal	714 <exit>

000000000000046e <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 46e:	1141                	addi	sp,sp,-16
 470:	e406                	sd	ra,8(sp)
 472:	e022                	sd	s0,0(sp)
 474:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 476:	87aa                	mv	a5,a0
 478:	0585                	addi	a1,a1,1
 47a:	0785                	addi	a5,a5,1
 47c:	fff5c703          	lbu	a4,-1(a1)
 480:	fee78fa3          	sb	a4,-1(a5)
 484:	fb75                	bnez	a4,478 <strcpy+0xa>
    ;
  return os;
}
 486:	60a2                	ld	ra,8(sp)
 488:	6402                	ld	s0,0(sp)
 48a:	0141                	addi	sp,sp,16
 48c:	8082                	ret

000000000000048e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 48e:	1141                	addi	sp,sp,-16
 490:	e406                	sd	ra,8(sp)
 492:	e022                	sd	s0,0(sp)
 494:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 496:	00054783          	lbu	a5,0(a0)
 49a:	cb91                	beqz	a5,4ae <strcmp+0x20>
 49c:	0005c703          	lbu	a4,0(a1)
 4a0:	00f71763          	bne	a4,a5,4ae <strcmp+0x20>
    p++, q++;
 4a4:	0505                	addi	a0,a0,1
 4a6:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 4a8:	00054783          	lbu	a5,0(a0)
 4ac:	fbe5                	bnez	a5,49c <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 4ae:	0005c503          	lbu	a0,0(a1)
}
 4b2:	40a7853b          	subw	a0,a5,a0
 4b6:	60a2                	ld	ra,8(sp)
 4b8:	6402                	ld	s0,0(sp)
 4ba:	0141                	addi	sp,sp,16
 4bc:	8082                	ret

00000000000004be <strlen>:

uint
strlen(const char *s)
{
 4be:	1141                	addi	sp,sp,-16
 4c0:	e406                	sd	ra,8(sp)
 4c2:	e022                	sd	s0,0(sp)
 4c4:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 4c6:	00054783          	lbu	a5,0(a0)
 4ca:	cf91                	beqz	a5,4e6 <strlen+0x28>
 4cc:	00150793          	addi	a5,a0,1
 4d0:	86be                	mv	a3,a5
 4d2:	0785                	addi	a5,a5,1
 4d4:	fff7c703          	lbu	a4,-1(a5)
 4d8:	ff65                	bnez	a4,4d0 <strlen+0x12>
 4da:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 4de:	60a2                	ld	ra,8(sp)
 4e0:	6402                	ld	s0,0(sp)
 4e2:	0141                	addi	sp,sp,16
 4e4:	8082                	ret
  for (n = 0; s[n]; n++)
 4e6:	4501                	li	a0,0
 4e8:	bfdd                	j	4de <strlen+0x20>

00000000000004ea <memset>:

void *
memset(void *dst, int c, uint n)
{
 4ea:	1141                	addi	sp,sp,-16
 4ec:	e406                	sd	ra,8(sp)
 4ee:	e022                	sd	s0,0(sp)
 4f0:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 4f2:	ca19                	beqz	a2,508 <memset+0x1e>
 4f4:	87aa                	mv	a5,a0
 4f6:	1602                	slli	a2,a2,0x20
 4f8:	9201                	srli	a2,a2,0x20
 4fa:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 4fe:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 502:	0785                	addi	a5,a5,1
 504:	fee79de3          	bne	a5,a4,4fe <memset+0x14>
  }
  return dst;
}
 508:	60a2                	ld	ra,8(sp)
 50a:	6402                	ld	s0,0(sp)
 50c:	0141                	addi	sp,sp,16
 50e:	8082                	ret

0000000000000510 <strchr>:

char *
strchr(const char *s, char c)
{
 510:	1141                	addi	sp,sp,-16
 512:	e406                	sd	ra,8(sp)
 514:	e022                	sd	s0,0(sp)
 516:	0800                	addi	s0,sp,16
  for (; *s; s++)
 518:	00054783          	lbu	a5,0(a0)
 51c:	cf81                	beqz	a5,534 <strchr+0x24>
    if (*s == c)
 51e:	00f58763          	beq	a1,a5,52c <strchr+0x1c>
  for (; *s; s++)
 522:	0505                	addi	a0,a0,1
 524:	00054783          	lbu	a5,0(a0)
 528:	fbfd                	bnez	a5,51e <strchr+0xe>
      return (char *)s;
  return 0;
 52a:	4501                	li	a0,0
}
 52c:	60a2                	ld	ra,8(sp)
 52e:	6402                	ld	s0,0(sp)
 530:	0141                	addi	sp,sp,16
 532:	8082                	ret
  return 0;
 534:	4501                	li	a0,0
 536:	bfdd                	j	52c <strchr+0x1c>

0000000000000538 <gets>:

char *
gets(char *buf, int max)
{
 538:	711d                	addi	sp,sp,-96
 53a:	ec86                	sd	ra,88(sp)
 53c:	e8a2                	sd	s0,80(sp)
 53e:	e4a6                	sd	s1,72(sp)
 540:	e0ca                	sd	s2,64(sp)
 542:	fc4e                	sd	s3,56(sp)
 544:	f852                	sd	s4,48(sp)
 546:	f456                	sd	s5,40(sp)
 548:	f05a                	sd	s6,32(sp)
 54a:	ec5e                	sd	s7,24(sp)
 54c:	e862                	sd	s8,16(sp)
 54e:	1080                	addi	s0,sp,96
 550:	8baa                	mv	s7,a0
 552:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 554:	892a                	mv	s2,a0
 556:	4481                	li	s1,0
    cc = read(0, &c, 1);
 558:	faf40b13          	addi	s6,s0,-81
 55c:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 55e:	8c26                	mv	s8,s1
 560:	0014899b          	addiw	s3,s1,1
 564:	84ce                	mv	s1,s3
 566:	0349d463          	bge	s3,s4,58e <gets+0x56>
    cc = read(0, &c, 1);
 56a:	8656                	mv	a2,s5
 56c:	85da                	mv	a1,s6
 56e:	4501                	li	a0,0
 570:	1bc000ef          	jal	72c <read>
    if (cc < 1)
 574:	00a05d63          	blez	a0,58e <gets+0x56>
      break;
    buf[i++] = c;
 578:	faf44783          	lbu	a5,-81(s0)
 57c:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 580:	0905                	addi	s2,s2,1
 582:	ff678713          	addi	a4,a5,-10
 586:	c319                	beqz	a4,58c <gets+0x54>
 588:	17cd                	addi	a5,a5,-13
 58a:	fbf1                	bnez	a5,55e <gets+0x26>
    buf[i++] = c;
 58c:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 58e:	9c5e                	add	s8,s8,s7
 590:	000c0023          	sb	zero,0(s8)
  return buf;
}
 594:	855e                	mv	a0,s7
 596:	60e6                	ld	ra,88(sp)
 598:	6446                	ld	s0,80(sp)
 59a:	64a6                	ld	s1,72(sp)
 59c:	6906                	ld	s2,64(sp)
 59e:	79e2                	ld	s3,56(sp)
 5a0:	7a42                	ld	s4,48(sp)
 5a2:	7aa2                	ld	s5,40(sp)
 5a4:	7b02                	ld	s6,32(sp)
 5a6:	6be2                	ld	s7,24(sp)
 5a8:	6c42                	ld	s8,16(sp)
 5aa:	6125                	addi	sp,sp,96
 5ac:	8082                	ret

00000000000005ae <stat>:

int
stat(const char *n, struct stat *st)
{
 5ae:	1101                	addi	sp,sp,-32
 5b0:	ec06                	sd	ra,24(sp)
 5b2:	e822                	sd	s0,16(sp)
 5b4:	e04a                	sd	s2,0(sp)
 5b6:	1000                	addi	s0,sp,32
 5b8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5ba:	4581                	li	a1,0
 5bc:	198000ef          	jal	754 <open>
  if (fd < 0)
 5c0:	02054263          	bltz	a0,5e4 <stat+0x36>
 5c4:	e426                	sd	s1,8(sp)
 5c6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 5c8:	85ca                	mv	a1,s2
 5ca:	1a2000ef          	jal	76c <fstat>
 5ce:	892a                	mv	s2,a0
  close(fd);
 5d0:	8526                	mv	a0,s1
 5d2:	16a000ef          	jal	73c <close>
  return r;
 5d6:	64a2                	ld	s1,8(sp)
}
 5d8:	854a                	mv	a0,s2
 5da:	60e2                	ld	ra,24(sp)
 5dc:	6442                	ld	s0,16(sp)
 5de:	6902                	ld	s2,0(sp)
 5e0:	6105                	addi	sp,sp,32
 5e2:	8082                	ret
    return -1;
 5e4:	57fd                	li	a5,-1
 5e6:	893e                	mv	s2,a5
 5e8:	bfc5                	j	5d8 <stat+0x2a>

00000000000005ea <atoi>:

int
atoi(const char *s)
{
 5ea:	1141                	addi	sp,sp,-16
 5ec:	e406                	sd	ra,8(sp)
 5ee:	e022                	sd	s0,0(sp)
 5f0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 5f2:	00054683          	lbu	a3,0(a0)
 5f6:	fd06879b          	addiw	a5,a3,-48
 5fa:	0ff7f793          	zext.b	a5,a5
 5fe:	4625                	li	a2,9
 600:	02f66963          	bltu	a2,a5,632 <atoi+0x48>
 604:	872a                	mv	a4,a0
  n = 0;
 606:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 608:	0705                	addi	a4,a4,1
 60a:	0025179b          	slliw	a5,a0,0x2
 60e:	9fa9                	addw	a5,a5,a0
 610:	0017979b          	slliw	a5,a5,0x1
 614:	9fb5                	addw	a5,a5,a3
 616:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 61a:	00074683          	lbu	a3,0(a4)
 61e:	fd06879b          	addiw	a5,a3,-48
 622:	0ff7f793          	zext.b	a5,a5
 626:	fef671e3          	bgeu	a2,a5,608 <atoi+0x1e>
  return n;
}
 62a:	60a2                	ld	ra,8(sp)
 62c:	6402                	ld	s0,0(sp)
 62e:	0141                	addi	sp,sp,16
 630:	8082                	ret
  n = 0;
 632:	4501                	li	a0,0
 634:	bfdd                	j	62a <atoi+0x40>

0000000000000636 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 636:	1141                	addi	sp,sp,-16
 638:	e406                	sd	ra,8(sp)
 63a:	e022                	sd	s0,0(sp)
 63c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 63e:	02b57563          	bgeu	a0,a1,668 <memmove+0x32>
    while (n-- > 0)
 642:	00c05f63          	blez	a2,660 <memmove+0x2a>
 646:	1602                	slli	a2,a2,0x20
 648:	9201                	srli	a2,a2,0x20
 64a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 64e:	872a                	mv	a4,a0
      *dst++ = *src++;
 650:	0585                	addi	a1,a1,1
 652:	0705                	addi	a4,a4,1
 654:	fff5c683          	lbu	a3,-1(a1)
 658:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 65c:	fee79ae3          	bne	a5,a4,650 <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 660:	60a2                	ld	ra,8(sp)
 662:	6402                	ld	s0,0(sp)
 664:	0141                	addi	sp,sp,16
 666:	8082                	ret
    while (n-- > 0)
 668:	fec05ce3          	blez	a2,660 <memmove+0x2a>
    dst += n;
 66c:	00c50733          	add	a4,a0,a2
    src += n;
 670:	95b2                	add	a1,a1,a2
 672:	fff6079b          	addiw	a5,a2,-1
 676:	1782                	slli	a5,a5,0x20
 678:	9381                	srli	a5,a5,0x20
 67a:	fff7c793          	not	a5,a5
 67e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 680:	15fd                	addi	a1,a1,-1
 682:	177d                	addi	a4,a4,-1
 684:	0005c683          	lbu	a3,0(a1)
 688:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 68c:	fef71ae3          	bne	a4,a5,680 <memmove+0x4a>
 690:	bfc1                	j	660 <memmove+0x2a>

0000000000000692 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 692:	1141                	addi	sp,sp,-16
 694:	e406                	sd	ra,8(sp)
 696:	e022                	sd	s0,0(sp)
 698:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 69a:	c61d                	beqz	a2,6c8 <memcmp+0x36>
 69c:	1602                	slli	a2,a2,0x20
 69e:	9201                	srli	a2,a2,0x20
 6a0:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 6a4:	00054783          	lbu	a5,0(a0)
 6a8:	0005c703          	lbu	a4,0(a1)
 6ac:	00e79863          	bne	a5,a4,6bc <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 6b0:	0505                	addi	a0,a0,1
    p2++;
 6b2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 6b4:	fed518e3          	bne	a0,a3,6a4 <memcmp+0x12>
  }
  return 0;
 6b8:	4501                	li	a0,0
 6ba:	a019                	j	6c0 <memcmp+0x2e>
      return *p1 - *p2;
 6bc:	40e7853b          	subw	a0,a5,a4
}
 6c0:	60a2                	ld	ra,8(sp)
 6c2:	6402                	ld	s0,0(sp)
 6c4:	0141                	addi	sp,sp,16
 6c6:	8082                	ret
  return 0;
 6c8:	4501                	li	a0,0
 6ca:	bfdd                	j	6c0 <memcmp+0x2e>

00000000000006cc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 6cc:	1141                	addi	sp,sp,-16
 6ce:	e406                	sd	ra,8(sp)
 6d0:	e022                	sd	s0,0(sp)
 6d2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 6d4:	f63ff0ef          	jal	636 <memmove>
}
 6d8:	60a2                	ld	ra,8(sp)
 6da:	6402                	ld	s0,0(sp)
 6dc:	0141                	addi	sp,sp,16
 6de:	8082                	ret

00000000000006e0 <sbrk>:

char *
sbrk(int n)
{
 6e0:	1141                	addi	sp,sp,-16
 6e2:	e406                	sd	ra,8(sp)
 6e4:	e022                	sd	s0,0(sp)
 6e6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 6e8:	4585                	li	a1,1
 6ea:	0b2000ef          	jal	79c <sys_sbrk>
}
 6ee:	60a2                	ld	ra,8(sp)
 6f0:	6402                	ld	s0,0(sp)
 6f2:	0141                	addi	sp,sp,16
 6f4:	8082                	ret

00000000000006f6 <sbrklazy>:

char *
sbrklazy(int n)
{
 6f6:	1141                	addi	sp,sp,-16
 6f8:	e406                	sd	ra,8(sp)
 6fa:	e022                	sd	s0,0(sp)
 6fc:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 6fe:	4589                	li	a1,2
 700:	09c000ef          	jal	79c <sys_sbrk>
}
 704:	60a2                	ld	ra,8(sp)
 706:	6402                	ld	s0,0(sp)
 708:	0141                	addi	sp,sp,16
 70a:	8082                	ret

000000000000070c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 70c:	4885                	li	a7,1
 ecall
 70e:	00000073          	ecall
 ret
 712:	8082                	ret

0000000000000714 <exit>:
.global exit
exit:
 li a7, SYS_exit
 714:	4889                	li	a7,2
 ecall
 716:	00000073          	ecall
 ret
 71a:	8082                	ret

000000000000071c <wait>:
.global wait
wait:
 li a7, SYS_wait
 71c:	488d                	li	a7,3
 ecall
 71e:	00000073          	ecall
 ret
 722:	8082                	ret

0000000000000724 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 724:	4891                	li	a7,4
 ecall
 726:	00000073          	ecall
 ret
 72a:	8082                	ret

000000000000072c <read>:
.global read
read:
 li a7, SYS_read
 72c:	4895                	li	a7,5
 ecall
 72e:	00000073          	ecall
 ret
 732:	8082                	ret

0000000000000734 <write>:
.global write
write:
 li a7, SYS_write
 734:	48c1                	li	a7,16
 ecall
 736:	00000073          	ecall
 ret
 73a:	8082                	ret

000000000000073c <close>:
.global close
close:
 li a7, SYS_close
 73c:	48d5                	li	a7,21
 ecall
 73e:	00000073          	ecall
 ret
 742:	8082                	ret

0000000000000744 <kill>:
.global kill
kill:
 li a7, SYS_kill
 744:	4899                	li	a7,6
 ecall
 746:	00000073          	ecall
 ret
 74a:	8082                	ret

000000000000074c <exec>:
.global exec
exec:
 li a7, SYS_exec
 74c:	489d                	li	a7,7
 ecall
 74e:	00000073          	ecall
 ret
 752:	8082                	ret

0000000000000754 <open>:
.global open
open:
 li a7, SYS_open
 754:	48bd                	li	a7,15
 ecall
 756:	00000073          	ecall
 ret
 75a:	8082                	ret

000000000000075c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 75c:	48c5                	li	a7,17
 ecall
 75e:	00000073          	ecall
 ret
 762:	8082                	ret

0000000000000764 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 764:	48c9                	li	a7,18
 ecall
 766:	00000073          	ecall
 ret
 76a:	8082                	ret

000000000000076c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 76c:	48a1                	li	a7,8
 ecall
 76e:	00000073          	ecall
 ret
 772:	8082                	ret

0000000000000774 <link>:
.global link
link:
 li a7, SYS_link
 774:	48cd                	li	a7,19
 ecall
 776:	00000073          	ecall
 ret
 77a:	8082                	ret

000000000000077c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 77c:	48d1                	li	a7,20
 ecall
 77e:	00000073          	ecall
 ret
 782:	8082                	ret

0000000000000784 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 784:	48a5                	li	a7,9
 ecall
 786:	00000073          	ecall
 ret
 78a:	8082                	ret

000000000000078c <dup>:
.global dup
dup:
 li a7, SYS_dup
 78c:	48a9                	li	a7,10
 ecall
 78e:	00000073          	ecall
 ret
 792:	8082                	ret

0000000000000794 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 794:	48ad                	li	a7,11
 ecall
 796:	00000073          	ecall
 ret
 79a:	8082                	ret

000000000000079c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 79c:	48b1                	li	a7,12
 ecall
 79e:	00000073          	ecall
 ret
 7a2:	8082                	ret

00000000000007a4 <pause>:
.global pause
pause:
 li a7, SYS_pause
 7a4:	48b5                	li	a7,13
 ecall
 7a6:	00000073          	ecall
 ret
 7aa:	8082                	ret

00000000000007ac <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 7ac:	48b9                	li	a7,14
 ecall
 7ae:	00000073          	ecall
 ret
 7b2:	8082                	ret

00000000000007b4 <sync>:
.global sync
sync:
 li a7, SYS_sync
 7b4:	48d9                	li	a7,22
 ecall
 7b6:	00000073          	ecall
 ret
 7ba:	8082                	ret

00000000000007bc <shm_get>:
.global shm_get
shm_get:
 li a7, SYS_shm_get
 7bc:	48dd                	li	a7,23
 ecall
 7be:	00000073          	ecall
 ret
 7c2:	8082                	ret

00000000000007c4 <sem_init>:
.global sem_init
sem_init:
 li a7, SYS_sem_init
 7c4:	48e1                	li	a7,24
 ecall
 7c6:	00000073          	ecall
 ret
 7ca:	8082                	ret

00000000000007cc <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 7cc:	48e5                	li	a7,25
 ecall
 7ce:	00000073          	ecall
 ret
 7d2:	8082                	ret

00000000000007d4 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 7d4:	48e9                	li	a7,26
 ecall
 7d6:	00000073          	ecall
 ret
 7da:	8082                	ret

00000000000007dc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 7dc:	1101                	addi	sp,sp,-32
 7de:	ec06                	sd	ra,24(sp)
 7e0:	e822                	sd	s0,16(sp)
 7e2:	1000                	addi	s0,sp,32
 7e4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 7e8:	4605                	li	a2,1
 7ea:	fef40593          	addi	a1,s0,-17
 7ee:	f47ff0ef          	jal	734 <write>
}
 7f2:	60e2                	ld	ra,24(sp)
 7f4:	6442                	ld	s0,16(sp)
 7f6:	6105                	addi	sp,sp,32
 7f8:	8082                	ret

00000000000007fa <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 7fa:	715d                	addi	sp,sp,-80
 7fc:	e486                	sd	ra,72(sp)
 7fe:	e0a2                	sd	s0,64(sp)
 800:	f84a                	sd	s2,48(sp)
 802:	f44e                	sd	s3,40(sp)
 804:	0880                	addi	s0,sp,80
 806:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 808:	c6d1                	beqz	a3,894 <printint+0x9a>
 80a:	0805d563          	bgez	a1,894 <printint+0x9a>
    neg = 1;
    x = -xx;
 80e:	40b005b3          	neg	a1,a1
    neg = 1;
 812:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 814:	fb840993          	addi	s3,s0,-72
  neg = 0;
 818:	86ce                	mv	a3,s3
  i = 0;
 81a:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 81c:	00001817          	auipc	a6,0x1
 820:	a5c80813          	addi	a6,a6,-1444 # 1278 <digits>
 824:	88ba                	mv	a7,a4
 826:	0017051b          	addiw	a0,a4,1
 82a:	872a                	mv	a4,a0
 82c:	02c5f7b3          	remu	a5,a1,a2
 830:	97c2                	add	a5,a5,a6
 832:	0007c783          	lbu	a5,0(a5)
 836:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 83a:	87ae                	mv	a5,a1
 83c:	02c5d5b3          	divu	a1,a1,a2
 840:	0685                	addi	a3,a3,1
 842:	fec7f1e3          	bgeu	a5,a2,824 <printint+0x2a>
  if (neg)
 846:	00030c63          	beqz	t1,85e <printint+0x64>
    buf[i++] = '-';
 84a:	fd050793          	addi	a5,a0,-48
 84e:	00878533          	add	a0,a5,s0
 852:	02d00793          	li	a5,45
 856:	fef50423          	sb	a5,-24(a0)
 85a:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 85e:	02e05563          	blez	a4,888 <printint+0x8e>
 862:	fc26                	sd	s1,56(sp)
 864:	377d                	addiw	a4,a4,-1
 866:	00e984b3          	add	s1,s3,a4
 86a:	19fd                	addi	s3,s3,-1
 86c:	99ba                	add	s3,s3,a4
 86e:	1702                	slli	a4,a4,0x20
 870:	9301                	srli	a4,a4,0x20
 872:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 876:	0004c583          	lbu	a1,0(s1)
 87a:	854a                	mv	a0,s2
 87c:	f61ff0ef          	jal	7dc <putc>
  while (--i >= 0)
 880:	14fd                	addi	s1,s1,-1
 882:	ff349ae3          	bne	s1,s3,876 <printint+0x7c>
 886:	74e2                	ld	s1,56(sp)
}
 888:	60a6                	ld	ra,72(sp)
 88a:	6406                	ld	s0,64(sp)
 88c:	7942                	ld	s2,48(sp)
 88e:	79a2                	ld	s3,40(sp)
 890:	6161                	addi	sp,sp,80
 892:	8082                	ret
  neg = 0;
 894:	4301                	li	t1,0
 896:	bfbd                	j	814 <printint+0x1a>

0000000000000898 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 898:	711d                	addi	sp,sp,-96
 89a:	ec86                	sd	ra,88(sp)
 89c:	e8a2                	sd	s0,80(sp)
 89e:	e4a6                	sd	s1,72(sp)
 8a0:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 8a2:	0005c483          	lbu	s1,0(a1)
 8a6:	22048363          	beqz	s1,acc <vprintf+0x234>
 8aa:	e0ca                	sd	s2,64(sp)
 8ac:	fc4e                	sd	s3,56(sp)
 8ae:	f852                	sd	s4,48(sp)
 8b0:	f456                	sd	s5,40(sp)
 8b2:	f05a                	sd	s6,32(sp)
 8b4:	ec5e                	sd	s7,24(sp)
 8b6:	e862                	sd	s8,16(sp)
 8b8:	8b2a                	mv	s6,a0
 8ba:	8a2e                	mv	s4,a1
 8bc:	8bb2                	mv	s7,a2
  state = 0;
 8be:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 8c0:	4901                	li	s2,0
 8c2:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 8c4:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 8c8:	06400c13          	li	s8,100
 8cc:	a00d                	j	8ee <vprintf+0x56>
        putc(fd, c0);
 8ce:	85a6                	mv	a1,s1
 8d0:	855a                	mv	a0,s6
 8d2:	f0bff0ef          	jal	7dc <putc>
 8d6:	a019                	j	8dc <vprintf+0x44>
    } else if (state == '%') {
 8d8:	03598363          	beq	s3,s5,8fe <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 8dc:	0019079b          	addiw	a5,s2,1
 8e0:	893e                	mv	s2,a5
 8e2:	873e                	mv	a4,a5
 8e4:	97d2                	add	a5,a5,s4
 8e6:	0007c483          	lbu	s1,0(a5)
 8ea:	1c048a63          	beqz	s1,abe <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 8ee:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 8f2:	fe0993e3          	bnez	s3,8d8 <vprintf+0x40>
      if (c0 == '%') {
 8f6:	fd579ce3          	bne	a5,s5,8ce <vprintf+0x36>
        state = '%';
 8fa:	89be                	mv	s3,a5
 8fc:	b7c5                	j	8dc <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 8fe:	00ea06b3          	add	a3,s4,a4
 902:	0016c603          	lbu	a2,1(a3)
      if (c1)
 906:	1c060863          	beqz	a2,ad6 <vprintf+0x23e>
      if (c0 == 'd') {
 90a:	03878763          	beq	a5,s8,938 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 90e:	f9478693          	addi	a3,a5,-108
 912:	0016b693          	seqz	a3,a3
 916:	f9c60593          	addi	a1,a2,-100
 91a:	e99d                	bnez	a1,950 <vprintf+0xb8>
 91c:	ca95                	beqz	a3,950 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 91e:	008b8493          	addi	s1,s7,8
 922:	4685                	li	a3,1
 924:	4629                	li	a2,10
 926:	000bb583          	ld	a1,0(s7)
 92a:	855a                	mv	a0,s6
 92c:	ecfff0ef          	jal	7fa <printint>
        i += 1;
 930:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 932:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 934:	4981                	li	s3,0
 936:	b75d                	j	8dc <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 938:	008b8493          	addi	s1,s7,8
 93c:	4685                	li	a3,1
 93e:	4629                	li	a2,10
 940:	000ba583          	lw	a1,0(s7)
 944:	855a                	mv	a0,s6
 946:	eb5ff0ef          	jal	7fa <printint>
 94a:	8ba6                	mv	s7,s1
      state = 0;
 94c:	4981                	li	s3,0
 94e:	b779                	j	8dc <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 950:	9752                	add	a4,a4,s4
 952:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 956:	f9460713          	addi	a4,a2,-108
 95a:	00173713          	seqz	a4,a4
 95e:	8f75                	and	a4,a4,a3
 960:	f9c58513          	addi	a0,a1,-100
 964:	18051363          	bnez	a0,aea <vprintf+0x252>
 968:	18070163          	beqz	a4,aea <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 96c:	008b8493          	addi	s1,s7,8
 970:	4685                	li	a3,1
 972:	4629                	li	a2,10
 974:	000bb583          	ld	a1,0(s7)
 978:	855a                	mv	a0,s6
 97a:	e81ff0ef          	jal	7fa <printint>
        i += 2;
 97e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 980:	8ba6                	mv	s7,s1
      state = 0;
 982:	4981                	li	s3,0
        i += 2;
 984:	bfa1                	j	8dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 986:	008b8493          	addi	s1,s7,8
 98a:	4681                	li	a3,0
 98c:	4629                	li	a2,10
 98e:	000be583          	lwu	a1,0(s7)
 992:	855a                	mv	a0,s6
 994:	e67ff0ef          	jal	7fa <printint>
 998:	8ba6                	mv	s7,s1
      state = 0;
 99a:	4981                	li	s3,0
 99c:	b781                	j	8dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 99e:	008b8493          	addi	s1,s7,8
 9a2:	4681                	li	a3,0
 9a4:	4629                	li	a2,10
 9a6:	000bb583          	ld	a1,0(s7)
 9aa:	855a                	mv	a0,s6
 9ac:	e4fff0ef          	jal	7fa <printint>
        i += 1;
 9b0:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 9b2:	8ba6                	mv	s7,s1
      state = 0;
 9b4:	4981                	li	s3,0
 9b6:	b71d                	j	8dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 9b8:	008b8493          	addi	s1,s7,8
 9bc:	4681                	li	a3,0
 9be:	4629                	li	a2,10
 9c0:	000bb583          	ld	a1,0(s7)
 9c4:	855a                	mv	a0,s6
 9c6:	e35ff0ef          	jal	7fa <printint>
        i += 2;
 9ca:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 9cc:	8ba6                	mv	s7,s1
      state = 0;
 9ce:	4981                	li	s3,0
        i += 2;
 9d0:	b731                	j	8dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 9d2:	008b8493          	addi	s1,s7,8
 9d6:	4681                	li	a3,0
 9d8:	4641                	li	a2,16
 9da:	000be583          	lwu	a1,0(s7)
 9de:	855a                	mv	a0,s6
 9e0:	e1bff0ef          	jal	7fa <printint>
 9e4:	8ba6                	mv	s7,s1
      state = 0;
 9e6:	4981                	li	s3,0
 9e8:	bdd5                	j	8dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 9ea:	008b8493          	addi	s1,s7,8
 9ee:	4681                	li	a3,0
 9f0:	4641                	li	a2,16
 9f2:	000bb583          	ld	a1,0(s7)
 9f6:	855a                	mv	a0,s6
 9f8:	e03ff0ef          	jal	7fa <printint>
        i += 1;
 9fc:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 9fe:	8ba6                	mv	s7,s1
      state = 0;
 a00:	4981                	li	s3,0
 a02:	bde9                	j	8dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 a04:	008b8493          	addi	s1,s7,8
 a08:	4681                	li	a3,0
 a0a:	4641                	li	a2,16
 a0c:	000bb583          	ld	a1,0(s7)
 a10:	855a                	mv	a0,s6
 a12:	de9ff0ef          	jal	7fa <printint>
        i += 2;
 a16:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 a18:	8ba6                	mv	s7,s1
      state = 0;
 a1a:	4981                	li	s3,0
        i += 2;
 a1c:	b5c1                	j	8dc <vprintf+0x44>
 a1e:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 a20:	008b8793          	addi	a5,s7,8
 a24:	8cbe                	mv	s9,a5
 a26:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 a2a:	03000593          	li	a1,48
 a2e:	855a                	mv	a0,s6
 a30:	dadff0ef          	jal	7dc <putc>
  putc(fd, 'x');
 a34:	07800593          	li	a1,120
 a38:	855a                	mv	a0,s6
 a3a:	da3ff0ef          	jal	7dc <putc>
 a3e:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 a40:	00001b97          	auipc	s7,0x1
 a44:	838b8b93          	addi	s7,s7,-1992 # 1278 <digits>
 a48:	03c9d793          	srli	a5,s3,0x3c
 a4c:	97de                	add	a5,a5,s7
 a4e:	0007c583          	lbu	a1,0(a5)
 a52:	855a                	mv	a0,s6
 a54:	d89ff0ef          	jal	7dc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 a58:	0992                	slli	s3,s3,0x4
 a5a:	34fd                	addiw	s1,s1,-1
 a5c:	f4f5                	bnez	s1,a48 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 a5e:	8be6                	mv	s7,s9
      state = 0;
 a60:	4981                	li	s3,0
 a62:	6ca2                	ld	s9,8(sp)
 a64:	bda5                	j	8dc <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 a66:	008b8493          	addi	s1,s7,8
 a6a:	000bc583          	lbu	a1,0(s7)
 a6e:	855a                	mv	a0,s6
 a70:	d6dff0ef          	jal	7dc <putc>
 a74:	8ba6                	mv	s7,s1
      state = 0;
 a76:	4981                	li	s3,0
 a78:	b595                	j	8dc <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 a7a:	008b8993          	addi	s3,s7,8
 a7e:	000bb483          	ld	s1,0(s7)
 a82:	cc91                	beqz	s1,a9e <vprintf+0x206>
        for (; *s; s++)
 a84:	0004c583          	lbu	a1,0(s1)
 a88:	c985                	beqz	a1,ab8 <vprintf+0x220>
          putc(fd, *s);
 a8a:	855a                	mv	a0,s6
 a8c:	d51ff0ef          	jal	7dc <putc>
        for (; *s; s++)
 a90:	0485                	addi	s1,s1,1
 a92:	0004c583          	lbu	a1,0(s1)
 a96:	f9f5                	bnez	a1,a8a <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 a98:	8bce                	mv	s7,s3
      state = 0;
 a9a:	4981                	li	s3,0
 a9c:	b581                	j	8dc <vprintf+0x44>
          s = "(null)";
 a9e:	00000497          	auipc	s1,0x0
 aa2:	7aa48493          	addi	s1,s1,1962 # 1248 <malloc+0x60e>
        for (; *s; s++)
 aa6:	02800593          	li	a1,40
 aaa:	b7c5                	j	a8a <vprintf+0x1f2>
        putc(fd, '%');
 aac:	85be                	mv	a1,a5
 aae:	855a                	mv	a0,s6
 ab0:	d2dff0ef          	jal	7dc <putc>
      state = 0;
 ab4:	4981                	li	s3,0
 ab6:	b51d                	j	8dc <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 ab8:	8bce                	mv	s7,s3
      state = 0;
 aba:	4981                	li	s3,0
 abc:	b505                	j	8dc <vprintf+0x44>
 abe:	6906                	ld	s2,64(sp)
 ac0:	79e2                	ld	s3,56(sp)
 ac2:	7a42                	ld	s4,48(sp)
 ac4:	7aa2                	ld	s5,40(sp)
 ac6:	7b02                	ld	s6,32(sp)
 ac8:	6be2                	ld	s7,24(sp)
 aca:	6c42                	ld	s8,16(sp)
    }
  }
}
 acc:	60e6                	ld	ra,88(sp)
 ace:	6446                	ld	s0,80(sp)
 ad0:	64a6                	ld	s1,72(sp)
 ad2:	6125                	addi	sp,sp,96
 ad4:	8082                	ret
      if (c0 == 'd') {
 ad6:	06400713          	li	a4,100
 ada:	e4e78fe3          	beq	a5,a4,938 <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 ade:	f9478693          	addi	a3,a5,-108
 ae2:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 ae6:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 ae8:	4701                	li	a4,0
      } else if (c0 == 'u') {
 aea:	07500513          	li	a0,117
 aee:	e8a78ce3          	beq	a5,a0,986 <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 af2:	f8b60513          	addi	a0,a2,-117
 af6:	e119                	bnez	a0,afc <vprintf+0x264>
 af8:	ea0693e3          	bnez	a3,99e <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 afc:	f8b58513          	addi	a0,a1,-117
 b00:	e119                	bnez	a0,b06 <vprintf+0x26e>
 b02:	ea071be3          	bnez	a4,9b8 <vprintf+0x120>
      } else if (c0 == 'x') {
 b06:	07800513          	li	a0,120
 b0a:	eca784e3          	beq	a5,a0,9d2 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 b0e:	f8860613          	addi	a2,a2,-120
 b12:	e219                	bnez	a2,b18 <vprintf+0x280>
 b14:	ec069be3          	bnez	a3,9ea <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 b18:	f8858593          	addi	a1,a1,-120
 b1c:	e199                	bnez	a1,b22 <vprintf+0x28a>
 b1e:	ee0713e3          	bnez	a4,a04 <vprintf+0x16c>
      } else if (c0 == 'p') {
 b22:	07000713          	li	a4,112
 b26:	eee78ce3          	beq	a5,a4,a1e <vprintf+0x186>
      } else if (c0 == 'c') {
 b2a:	06300713          	li	a4,99
 b2e:	f2e78ce3          	beq	a5,a4,a66 <vprintf+0x1ce>
      } else if (c0 == 's') {
 b32:	07300713          	li	a4,115
 b36:	f4e782e3          	beq	a5,a4,a7a <vprintf+0x1e2>
      } else if (c0 == '%') {
 b3a:	02500713          	li	a4,37
 b3e:	f6e787e3          	beq	a5,a4,aac <vprintf+0x214>
        putc(fd, '%');
 b42:	02500593          	li	a1,37
 b46:	855a                	mv	a0,s6
 b48:	c95ff0ef          	jal	7dc <putc>
        putc(fd, c0);
 b4c:	85a6                	mv	a1,s1
 b4e:	855a                	mv	a0,s6
 b50:	c8dff0ef          	jal	7dc <putc>
      state = 0;
 b54:	4981                	li	s3,0
 b56:	b359                	j	8dc <vprintf+0x44>

0000000000000b58 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 b58:	715d                	addi	sp,sp,-80
 b5a:	ec06                	sd	ra,24(sp)
 b5c:	e822                	sd	s0,16(sp)
 b5e:	1000                	addi	s0,sp,32
 b60:	e010                	sd	a2,0(s0)
 b62:	e414                	sd	a3,8(s0)
 b64:	e818                	sd	a4,16(s0)
 b66:	ec1c                	sd	a5,24(s0)
 b68:	03043023          	sd	a6,32(s0)
 b6c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 b70:	8622                	mv	a2,s0
 b72:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 b76:	d23ff0ef          	jal	898 <vprintf>
}
 b7a:	60e2                	ld	ra,24(sp)
 b7c:	6442                	ld	s0,16(sp)
 b7e:	6161                	addi	sp,sp,80
 b80:	8082                	ret

0000000000000b82 <printf>:

void
printf(const char *fmt, ...)
{
 b82:	711d                	addi	sp,sp,-96
 b84:	ec06                	sd	ra,24(sp)
 b86:	e822                	sd	s0,16(sp)
 b88:	1000                	addi	s0,sp,32
 b8a:	e40c                	sd	a1,8(s0)
 b8c:	e810                	sd	a2,16(s0)
 b8e:	ec14                	sd	a3,24(s0)
 b90:	f018                	sd	a4,32(s0)
 b92:	f41c                	sd	a5,40(s0)
 b94:	03043823          	sd	a6,48(s0)
 b98:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 b9c:	00840613          	addi	a2,s0,8
 ba0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 ba4:	85aa                	mv	a1,a0
 ba6:	4505                	li	a0,1
 ba8:	cf1ff0ef          	jal	898 <vprintf>
}
 bac:	60e2                	ld	ra,24(sp)
 bae:	6442                	ld	s0,16(sp)
 bb0:	6125                	addi	sp,sp,96
 bb2:	8082                	ret

0000000000000bb4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 bb4:	1141                	addi	sp,sp,-16
 bb6:	e406                	sd	ra,8(sp)
 bb8:	e022                	sd	s0,0(sp)
 bba:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 bbc:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bc0:	00001797          	auipc	a5,0x1
 bc4:	4707b783          	ld	a5,1136(a5) # 2030 <freep>
 bc8:	a039                	j	bd6 <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 bca:	6398                	ld	a4,0(a5)
 bcc:	00e7e463          	bltu	a5,a4,bd4 <free+0x20>
 bd0:	00e6ea63          	bltu	a3,a4,be4 <free+0x30>
{
 bd4:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bd6:	fed7fae3          	bgeu	a5,a3,bca <free+0x16>
 bda:	6398                	ld	a4,0(a5)
 bdc:	00e6e463          	bltu	a3,a4,be4 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 be0:	fee7eae3          	bltu	a5,a4,bd4 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 be4:	ff852583          	lw	a1,-8(a0)
 be8:	6390                	ld	a2,0(a5)
 bea:	02059813          	slli	a6,a1,0x20
 bee:	01c85713          	srli	a4,a6,0x1c
 bf2:	9736                	add	a4,a4,a3
 bf4:	02e60563          	beq	a2,a4,c1e <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 bf8:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 bfc:	4790                	lw	a2,8(a5)
 bfe:	02061593          	slli	a1,a2,0x20
 c02:	01c5d713          	srli	a4,a1,0x1c
 c06:	973e                	add	a4,a4,a5
 c08:	02e68263          	beq	a3,a4,c2c <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 c0c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 c0e:	00001717          	auipc	a4,0x1
 c12:	42f73123          	sd	a5,1058(a4) # 2030 <freep>
}
 c16:	60a2                	ld	ra,8(sp)
 c18:	6402                	ld	s0,0(sp)
 c1a:	0141                	addi	sp,sp,16
 c1c:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 c1e:	4618                	lw	a4,8(a2)
 c20:	9f2d                	addw	a4,a4,a1
 c22:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 c26:	6398                	ld	a4,0(a5)
 c28:	6310                	ld	a2,0(a4)
 c2a:	b7f9                	j	bf8 <free+0x44>
    p->s.size += bp->s.size;
 c2c:	ff852703          	lw	a4,-8(a0)
 c30:	9f31                	addw	a4,a4,a2
 c32:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 c34:	ff053683          	ld	a3,-16(a0)
 c38:	bfd1                	j	c0c <free+0x58>

0000000000000c3a <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 c3a:	7139                	addi	sp,sp,-64
 c3c:	fc06                	sd	ra,56(sp)
 c3e:	f822                	sd	s0,48(sp)
 c40:	f04a                	sd	s2,32(sp)
 c42:	ec4e                	sd	s3,24(sp)
 c44:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 c46:	02051993          	slli	s3,a0,0x20
 c4a:	0209d993          	srli	s3,s3,0x20
 c4e:	09bd                	addi	s3,s3,15
 c50:	0049d993          	srli	s3,s3,0x4
 c54:	2985                	addiw	s3,s3,1
 c56:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 c58:	00001517          	auipc	a0,0x1
 c5c:	3d853503          	ld	a0,984(a0) # 2030 <freep>
 c60:	c905                	beqz	a0,c90 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 c62:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 c64:	4798                	lw	a4,8(a5)
 c66:	09377663          	bgeu	a4,s3,cf2 <malloc+0xb8>
 c6a:	f426                	sd	s1,40(sp)
 c6c:	e852                	sd	s4,16(sp)
 c6e:	e456                	sd	s5,8(sp)
 c70:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 c72:	8a4e                	mv	s4,s3
 c74:	6705                	lui	a4,0x1
 c76:	00e9f363          	bgeu	s3,a4,c7c <malloc+0x42>
 c7a:	6a05                	lui	s4,0x1
 c7c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 c80:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 c84:	00001497          	auipc	s1,0x1
 c88:	3ac48493          	addi	s1,s1,940 # 2030 <freep>
  if (p == SBRK_ERROR)
 c8c:	5afd                	li	s5,-1
 c8e:	a83d                	j	ccc <malloc+0x92>
 c90:	f426                	sd	s1,40(sp)
 c92:	e852                	sd	s4,16(sp)
 c94:	e456                	sd	s5,8(sp)
 c96:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 c98:	00001797          	auipc	a5,0x1
 c9c:	3a878793          	addi	a5,a5,936 # 2040 <base>
 ca0:	00001717          	auipc	a4,0x1
 ca4:	38f73823          	sd	a5,912(a4) # 2030 <freep>
 ca8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 caa:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 cae:	b7d1                	j	c72 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 cb0:	6398                	ld	a4,0(a5)
 cb2:	e118                	sd	a4,0(a0)
 cb4:	a899                	j	d0a <malloc+0xd0>
  hp->s.size = nu;
 cb6:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 cba:	0541                	addi	a0,a0,16
 cbc:	ef9ff0ef          	jal	bb4 <free>
  return freep;
 cc0:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 cc2:	c125                	beqz	a0,d22 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 cc4:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 cc6:	4798                	lw	a4,8(a5)
 cc8:	03277163          	bgeu	a4,s2,cea <malloc+0xb0>
    if (p == freep)
 ccc:	6098                	ld	a4,0(s1)
 cce:	853e                	mv	a0,a5
 cd0:	fef71ae3          	bne	a4,a5,cc4 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 cd4:	8552                	mv	a0,s4
 cd6:	a0bff0ef          	jal	6e0 <sbrk>
  if (p == SBRK_ERROR)
 cda:	fd551ee3          	bne	a0,s5,cb6 <malloc+0x7c>
        return 0;
 cde:	4501                	li	a0,0
 ce0:	74a2                	ld	s1,40(sp)
 ce2:	6a42                	ld	s4,16(sp)
 ce4:	6aa2                	ld	s5,8(sp)
 ce6:	6b02                	ld	s6,0(sp)
 ce8:	a03d                	j	d16 <malloc+0xdc>
 cea:	74a2                	ld	s1,40(sp)
 cec:	6a42                	ld	s4,16(sp)
 cee:	6aa2                	ld	s5,8(sp)
 cf0:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 cf2:	fae90fe3          	beq	s2,a4,cb0 <malloc+0x76>
        p->s.size -= nunits;
 cf6:	4137073b          	subw	a4,a4,s3
 cfa:	c798                	sw	a4,8(a5)
        p += p->s.size;
 cfc:	02071693          	slli	a3,a4,0x20
 d00:	01c6d713          	srli	a4,a3,0x1c
 d04:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 d06:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 d0a:	00001717          	auipc	a4,0x1
 d0e:	32a73323          	sd	a0,806(a4) # 2030 <freep>
      return (void *)(p + 1);
 d12:	01078513          	addi	a0,a5,16
  }
}
 d16:	70e2                	ld	ra,56(sp)
 d18:	7442                	ld	s0,48(sp)
 d1a:	7902                	ld	s2,32(sp)
 d1c:	69e2                	ld	s3,24(sp)
 d1e:	6121                	addi	sp,sp,64
 d20:	8082                	ret
 d22:	74a2                	ld	s1,40(sp)
 d24:	6a42                	ld	s4,16(sp)
 d26:	6aa2                	ld	s5,8(sp)
 d28:	6b02                	ld	s6,0(sp)
 d2a:	b7f5                	j	d16 <malloc+0xdc>
