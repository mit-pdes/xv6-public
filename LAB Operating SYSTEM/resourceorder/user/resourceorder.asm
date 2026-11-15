
user/_resourceorder:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <run_deadlock_scenario>:
#include "user/user.h"

#define LOCK1 0
#define LOCK2 1

void run_deadlock_scenario(void) {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  printf("============================================================\n");
   8:	00001517          	auipc	a0,0x1
   c:	d5850513          	addi	a0,a0,-680 # d60 <malloc+0xf2>
  10:	3a7000ef          	jal	bb6 <printf>
  printf("  SCENARIO 1: INCONSISTENT ORDERING (DEADLOCK DEMONSTRATION)\n");
  14:	00001517          	auipc	a0,0x1
  18:	d9450513          	addi	a0,a0,-620 # da8 <malloc+0x13a>
  1c:	39b000ef          	jal	bb6 <printf>
  printf("  Process A: Requests Lock1 -> Lock2\n");
  20:	00001517          	auipc	a0,0x1
  24:	dc850513          	addi	a0,a0,-568 # de8 <malloc+0x17a>
  28:	38f000ef          	jal	bb6 <printf>
  printf("  Process B: Requests Lock2 -> Lock1 (Reverse Order)\n");
  2c:	00001517          	auipc	a0,0x1
  30:	de450513          	addi	a0,a0,-540 # e10 <malloc+0x1a2>
  34:	383000ef          	jal	bb6 <printf>
  printf("============================================================\n");
  38:	00001517          	auipc	a0,0x1
  3c:	d2850513          	addi	a0,a0,-728 # d60 <malloc+0xf2>
  40:	377000ef          	jal	bb6 <printf>

  sem_init(LOCK1, 1);
  44:	4585                	li	a1,1
  46:	4501                	li	a0,0
  48:	7b0000ef          	jal	7f8 <sem_init>
  sem_init(LOCK2, 1);
  4c:	4585                	li	a1,1
  4e:	852e                	mv	a0,a1
  50:	7a8000ef          	jal	7f8 <sem_init>

  int pid_a = fork();
  54:	6ec000ef          	jal	740 <fork>
  if (pid_a < 0) {
  58:	02054363          	bltz	a0,7e <run_deadlock_scenario+0x7e>
    printf("fork A failed\n");
    exit(1);
  }
  if (pid_a == 0) {
  5c:	c91d                	beqz	a0,92 <run_deadlock_scenario+0x92>
    sem_post(LOCK2);
    sem_post(LOCK1);
    exit(0);
  }

  int pid_b = fork();
  5e:	6e2000ef          	jal	740 <fork>
  if (pid_b < 0) {
  62:	0c054c63          	bltz	a0,13a <run_deadlock_scenario+0x13a>
    printf("fork B failed\n");
    exit(1);
  }
  if (pid_b == 0) {
  66:	0e050463          	beqz	a0,14e <run_deadlock_scenario+0x14e>
    exit(0);
  }

  // Parent monitors processes
  // In this mode, both children hang forever in circular wait
  wait(0);
  6a:	4501                	li	a0,0
  6c:	6e4000ef          	jal	750 <wait>
  wait(0);
  70:	4501                	li	a0,0
  72:	6de000ef          	jal	750 <wait>
}
  76:	60e2                	ld	ra,24(sp)
  78:	6442                	ld	s0,16(sp)
  7a:	6105                	addi	sp,sp,32
  7c:	8082                	ret
  7e:	e426                	sd	s1,8(sp)
    printf("fork A failed\n");
  80:	00001517          	auipc	a0,0x1
  84:	dc850513          	addi	a0,a0,-568 # e48 <malloc+0x1da>
  88:	32f000ef          	jal	bb6 <printf>
    exit(1);
  8c:	4505                	li	a0,1
  8e:	6ba000ef          	jal	748 <exit>
  92:	e426                	sd	s1,8(sp)
    printf("[Tick %d] [Process A (pid %d)]: Attempting to acquire Lock 1...\n",
  94:	74c000ef          	jal	7e0 <uptime>
  98:	84aa                	mv	s1,a0
  9a:	72e000ef          	jal	7c8 <getpid>
  9e:	862a                	mv	a2,a0
  a0:	85a6                	mv	a1,s1
  a2:	00001517          	auipc	a0,0x1
  a6:	db650513          	addi	a0,a0,-586 # e58 <malloc+0x1ea>
  aa:	30d000ef          	jal	bb6 <printf>
    sem_wait(LOCK1);
  ae:	4501                	li	a0,0
  b0:	750000ef          	jal	800 <sem_wait>
    printf("[Tick %d] [Process A (pid %d)]: ACQUIRED Lock 1.\n",
  b4:	72c000ef          	jal	7e0 <uptime>
  b8:	84aa                	mv	s1,a0
  ba:	70e000ef          	jal	7c8 <getpid>
  be:	862a                	mv	a2,a0
  c0:	85a6                	mv	a1,s1
  c2:	00001517          	auipc	a0,0x1
  c6:	dde50513          	addi	a0,a0,-546 # ea0 <malloc+0x232>
  ca:	2ed000ef          	jal	bb6 <printf>
    printf("[Tick %d] [Process A (pid %d)]: Holding Lock 1, sleeping 2 ticks...\n",
  ce:	712000ef          	jal	7e0 <uptime>
  d2:	84aa                	mv	s1,a0
  d4:	6f4000ef          	jal	7c8 <getpid>
  d8:	862a                	mv	a2,a0
  da:	85a6                	mv	a1,s1
  dc:	00001517          	auipc	a0,0x1
  e0:	dfc50513          	addi	a0,a0,-516 # ed8 <malloc+0x26a>
  e4:	2d3000ef          	jal	bb6 <printf>
    pause(2);
  e8:	4509                	li	a0,2
  ea:	6ee000ef          	jal	7d8 <pause>
    printf("[Tick %d] [Process A (pid %d)]: Attempting to acquire Lock 2...\n",
  ee:	6f2000ef          	jal	7e0 <uptime>
  f2:	84aa                	mv	s1,a0
  f4:	6d4000ef          	jal	7c8 <getpid>
  f8:	862a                	mv	a2,a0
  fa:	85a6                	mv	a1,s1
  fc:	00001517          	auipc	a0,0x1
 100:	e2450513          	addi	a0,a0,-476 # f20 <malloc+0x2b2>
 104:	2b3000ef          	jal	bb6 <printf>
    sem_wait(LOCK2);
 108:	4505                	li	a0,1
 10a:	6f6000ef          	jal	800 <sem_wait>
    printf("[Tick %d] [Process A (pid %d)]: ACQUIRED Lock 2. Entering CS.\n",
 10e:	6d2000ef          	jal	7e0 <uptime>
 112:	84aa                	mv	s1,a0
 114:	6b4000ef          	jal	7c8 <getpid>
 118:	862a                	mv	a2,a0
 11a:	85a6                	mv	a1,s1
 11c:	00001517          	auipc	a0,0x1
 120:	e4c50513          	addi	a0,a0,-436 # f68 <malloc+0x2fa>
 124:	293000ef          	jal	bb6 <printf>
    sem_post(LOCK2);
 128:	4505                	li	a0,1
 12a:	6de000ef          	jal	808 <sem_post>
    sem_post(LOCK1);
 12e:	4501                	li	a0,0
 130:	6d8000ef          	jal	808 <sem_post>
    exit(0);
 134:	4501                	li	a0,0
 136:	612000ef          	jal	748 <exit>
 13a:	e426                	sd	s1,8(sp)
    printf("fork B failed\n");
 13c:	00001517          	auipc	a0,0x1
 140:	e6c50513          	addi	a0,a0,-404 # fa8 <malloc+0x33a>
 144:	273000ef          	jal	bb6 <printf>
    exit(1);
 148:	4505                	li	a0,1
 14a:	5fe000ef          	jal	748 <exit>
 14e:	e426                	sd	s1,8(sp)
    pause(1);
 150:	4505                	li	a0,1
 152:	686000ef          	jal	7d8 <pause>
    printf("[Tick %d] [Process B (pid %d)]: Attempting to acquire Lock 2...\n",
 156:	68a000ef          	jal	7e0 <uptime>
 15a:	84aa                	mv	s1,a0
 15c:	66c000ef          	jal	7c8 <getpid>
 160:	862a                	mv	a2,a0
 162:	85a6                	mv	a1,s1
 164:	00001517          	auipc	a0,0x1
 168:	e5450513          	addi	a0,a0,-428 # fb8 <malloc+0x34a>
 16c:	24b000ef          	jal	bb6 <printf>
    sem_wait(LOCK2);
 170:	4505                	li	a0,1
 172:	68e000ef          	jal	800 <sem_wait>
    printf("[Tick %d] [Process B (pid %d)]: ACQUIRED Lock 2.\n",
 176:	66a000ef          	jal	7e0 <uptime>
 17a:	84aa                	mv	s1,a0
 17c:	64c000ef          	jal	7c8 <getpid>
 180:	862a                	mv	a2,a0
 182:	85a6                	mv	a1,s1
 184:	00001517          	auipc	a0,0x1
 188:	e7c50513          	addi	a0,a0,-388 # 1000 <malloc+0x392>
 18c:	22b000ef          	jal	bb6 <printf>
    printf("[Tick %d] [Process B (pid %d)]: Holding Lock 2, sleeping 2 ticks...\n",
 190:	650000ef          	jal	7e0 <uptime>
 194:	84aa                	mv	s1,a0
 196:	632000ef          	jal	7c8 <getpid>
 19a:	862a                	mv	a2,a0
 19c:	85a6                	mv	a1,s1
 19e:	00001517          	auipc	a0,0x1
 1a2:	e9a50513          	addi	a0,a0,-358 # 1038 <malloc+0x3ca>
 1a6:	211000ef          	jal	bb6 <printf>
    pause(2);
 1aa:	4509                	li	a0,2
 1ac:	62c000ef          	jal	7d8 <pause>
    printf("[Tick %d] [Process B (pid %d)]: Attempting to acquire Lock 1...\n",
 1b0:	630000ef          	jal	7e0 <uptime>
 1b4:	84aa                	mv	s1,a0
 1b6:	612000ef          	jal	7c8 <getpid>
 1ba:	862a                	mv	a2,a0
 1bc:	85a6                	mv	a1,s1
 1be:	00001517          	auipc	a0,0x1
 1c2:	ec250513          	addi	a0,a0,-318 # 1080 <malloc+0x412>
 1c6:	1f1000ef          	jal	bb6 <printf>
    sem_wait(LOCK1);
 1ca:	4501                	li	a0,0
 1cc:	634000ef          	jal	800 <sem_wait>
    printf("[Tick %d] [Process B (pid %d)]: ACQUIRED Lock 1. Entering CS.\n",
 1d0:	610000ef          	jal	7e0 <uptime>
 1d4:	84aa                	mv	s1,a0
 1d6:	5f2000ef          	jal	7c8 <getpid>
 1da:	862a                	mv	a2,a0
 1dc:	85a6                	mv	a1,s1
 1de:	00001517          	auipc	a0,0x1
 1e2:	eea50513          	addi	a0,a0,-278 # 10c8 <malloc+0x45a>
 1e6:	1d1000ef          	jal	bb6 <printf>
    sem_post(LOCK1);
 1ea:	4501                	li	a0,0
 1ec:	61c000ef          	jal	808 <sem_post>
    sem_post(LOCK2);
 1f0:	4505                	li	a0,1
 1f2:	616000ef          	jal	808 <sem_post>
    exit(0);
 1f6:	4501                	li	a0,0
 1f8:	550000ef          	jal	748 <exit>

00000000000001fc <run_fixed_scenario>:

void run_fixed_scenario(void) {
 1fc:	1101                	addi	sp,sp,-32
 1fe:	ec06                	sd	ra,24(sp)
 200:	e822                	sd	s0,16(sp)
 202:	1000                	addi	s0,sp,32
  printf("============================================================\n");
 204:	00001517          	auipc	a0,0x1
 208:	b5c50513          	addi	a0,a0,-1188 # d60 <malloc+0xf2>
 20c:	1ab000ef          	jal	bb6 <printf>
  printf("  SCENARIO 2: RESOURCE ORDERING (DEADLOCK PREVENTED)\n");
 210:	00001517          	auipc	a0,0x1
 214:	ef850513          	addi	a0,a0,-264 # 1108 <malloc+0x49a>
 218:	19f000ef          	jal	bb6 <printf>
  printf("  Global Order: Lock1 (Resource 0) < Lock2 (Resource 1)\n");
 21c:	00001517          	auipc	a0,0x1
 220:	f2450513          	addi	a0,a0,-220 # 1140 <malloc+0x4d2>
 224:	193000ef          	jal	bb6 <printf>
  printf("  Both Process A & Process B acquire Lock1 THEN Lock2.\n");
 228:	00001517          	auipc	a0,0x1
 22c:	f5850513          	addi	a0,a0,-168 # 1180 <malloc+0x512>
 230:	187000ef          	jal	bb6 <printf>
  printf("============================================================\n");
 234:	00001517          	auipc	a0,0x1
 238:	b2c50513          	addi	a0,a0,-1236 # d60 <malloc+0xf2>
 23c:	17b000ef          	jal	bb6 <printf>

  sem_init(LOCK1, 1);
 240:	4585                	li	a1,1
 242:	4501                	li	a0,0
 244:	5b4000ef          	jal	7f8 <sem_init>
  sem_init(LOCK2, 1);
 248:	4585                	li	a1,1
 24a:	852e                	mv	a0,a1
 24c:	5ac000ef          	jal	7f8 <sem_init>

  int pid_a = fork();
 250:	4f0000ef          	jal	740 <fork>
  if (pid_a < 0) {
 254:	04054b63          	bltz	a0,2aa <run_fixed_scenario+0xae>
    printf("fork A failed\n");
    exit(1);
  }
  if (pid_a == 0) {
 258:	c13d                	beqz	a0,2be <run_fixed_scenario+0xc2>
    printf("[Tick %d] [Process A (pid %d)]: Completed successfully.\n",
           uptime(), getpid());
    exit(0);
  }

  int pid_b = fork();
 25a:	4e6000ef          	jal	740 <fork>
  if (pid_b < 0) {
 25e:	12054463          	bltz	a0,386 <run_fixed_scenario+0x18a>
    printf("fork B failed\n");
    exit(1);
  }
  if (pid_b == 0) {
 262:	12050c63          	beqz	a0,39a <run_fixed_scenario+0x19e>
           uptime(), getpid());
    exit(0);
  }

  // Parent waits for both children to complete
  wait(0);
 266:	4501                	li	a0,0
 268:	4e8000ef          	jal	750 <wait>
  wait(0);
 26c:	4501                	li	a0,0
 26e:	4e2000ef          	jal	750 <wait>

  printf("============================================================\n");
 272:	00001517          	auipc	a0,0x1
 276:	aee50513          	addi	a0,a0,-1298 # d60 <malloc+0xf2>
 27a:	13d000ef          	jal	bb6 <printf>
  printf("SUCCESS: Both Process A and Process B completed cleanly!\n");
 27e:	00001517          	auipc	a0,0x1
 282:	14250513          	addi	a0,a0,322 # 13c0 <malloc+0x752>
 286:	131000ef          	jal	bb6 <printf>
  printf("Deadlock was completely eliminated by enforcing global resource ordering.\n");
 28a:	00001517          	auipc	a0,0x1
 28e:	17650513          	addi	a0,a0,374 # 1400 <malloc+0x792>
 292:	125000ef          	jal	bb6 <printf>
  printf("============================================================\n");
 296:	00001517          	auipc	a0,0x1
 29a:	aca50513          	addi	a0,a0,-1334 # d60 <malloc+0xf2>
 29e:	119000ef          	jal	bb6 <printf>
}
 2a2:	60e2                	ld	ra,24(sp)
 2a4:	6442                	ld	s0,16(sp)
 2a6:	6105                	addi	sp,sp,32
 2a8:	8082                	ret
 2aa:	e426                	sd	s1,8(sp)
    printf("fork A failed\n");
 2ac:	00001517          	auipc	a0,0x1
 2b0:	b9c50513          	addi	a0,a0,-1124 # e48 <malloc+0x1da>
 2b4:	103000ef          	jal	bb6 <printf>
    exit(1);
 2b8:	4505                	li	a0,1
 2ba:	48e000ef          	jal	748 <exit>
 2be:	e426                	sd	s1,8(sp)
    printf("[Tick %d] [Process A (pid %d)]: Attempting to acquire Lock 1...\n",
 2c0:	520000ef          	jal	7e0 <uptime>
 2c4:	84aa                	mv	s1,a0
 2c6:	502000ef          	jal	7c8 <getpid>
 2ca:	862a                	mv	a2,a0
 2cc:	85a6                	mv	a1,s1
 2ce:	00001517          	auipc	a0,0x1
 2d2:	b8a50513          	addi	a0,a0,-1142 # e58 <malloc+0x1ea>
 2d6:	0e1000ef          	jal	bb6 <printf>
    sem_wait(LOCK1);
 2da:	4501                	li	a0,0
 2dc:	524000ef          	jal	800 <sem_wait>
    printf("[Tick %d] [Process A (pid %d)]: ACQUIRED Lock 1.\n",
 2e0:	500000ef          	jal	7e0 <uptime>
 2e4:	84aa                	mv	s1,a0
 2e6:	4e2000ef          	jal	7c8 <getpid>
 2ea:	862a                	mv	a2,a0
 2ec:	85a6                	mv	a1,s1
 2ee:	00001517          	auipc	a0,0x1
 2f2:	bb250513          	addi	a0,a0,-1102 # ea0 <malloc+0x232>
 2f6:	0c1000ef          	jal	bb6 <printf>
    pause(1);
 2fa:	4505                	li	a0,1
 2fc:	4dc000ef          	jal	7d8 <pause>
    printf("[Tick %d] [Process A (pid %d)]: Attempting to acquire Lock 2...\n",
 300:	4e0000ef          	jal	7e0 <uptime>
 304:	84aa                	mv	s1,a0
 306:	4c2000ef          	jal	7c8 <getpid>
 30a:	862a                	mv	a2,a0
 30c:	85a6                	mv	a1,s1
 30e:	00001517          	auipc	a0,0x1
 312:	c1250513          	addi	a0,a0,-1006 # f20 <malloc+0x2b2>
 316:	0a1000ef          	jal	bb6 <printf>
    sem_wait(LOCK2);
 31a:	4505                	li	a0,1
 31c:	4e4000ef          	jal	800 <sem_wait>
    printf("[Tick %d] [Process A (pid %d)]: ACQUIRED Lock 2. Entering Critical Section.\n",
 320:	4c0000ef          	jal	7e0 <uptime>
 324:	84aa                	mv	s1,a0
 326:	4a2000ef          	jal	7c8 <getpid>
 32a:	862a                	mv	a2,a0
 32c:	85a6                	mv	a1,s1
 32e:	00001517          	auipc	a0,0x1
 332:	e8a50513          	addi	a0,a0,-374 # 11b8 <malloc+0x54a>
 336:	081000ef          	jal	bb6 <printf>
    pause(2); // In CS
 33a:	4509                	li	a0,2
 33c:	49c000ef          	jal	7d8 <pause>
    printf("[Tick %d] [Process A (pid %d)]: Exiting Critical Section. Releasing Lock 2 and Lock 1.\n",
 340:	4a0000ef          	jal	7e0 <uptime>
 344:	84aa                	mv	s1,a0
 346:	482000ef          	jal	7c8 <getpid>
 34a:	862a                	mv	a2,a0
 34c:	85a6                	mv	a1,s1
 34e:	00001517          	auipc	a0,0x1
 352:	eba50513          	addi	a0,a0,-326 # 1208 <malloc+0x59a>
 356:	061000ef          	jal	bb6 <printf>
    sem_post(LOCK2);
 35a:	4505                	li	a0,1
 35c:	4ac000ef          	jal	808 <sem_post>
    sem_post(LOCK1);
 360:	4501                	li	a0,0
 362:	4a6000ef          	jal	808 <sem_post>
    printf("[Tick %d] [Process A (pid %d)]: Completed successfully.\n",
 366:	47a000ef          	jal	7e0 <uptime>
 36a:	84aa                	mv	s1,a0
 36c:	45c000ef          	jal	7c8 <getpid>
 370:	862a                	mv	a2,a0
 372:	85a6                	mv	a1,s1
 374:	00001517          	auipc	a0,0x1
 378:	eec50513          	addi	a0,a0,-276 # 1260 <malloc+0x5f2>
 37c:	03b000ef          	jal	bb6 <printf>
    exit(0);
 380:	4501                	li	a0,0
 382:	3c6000ef          	jal	748 <exit>
 386:	e426                	sd	s1,8(sp)
    printf("fork B failed\n");
 388:	00001517          	auipc	a0,0x1
 38c:	c2050513          	addi	a0,a0,-992 # fa8 <malloc+0x33a>
 390:	027000ef          	jal	bb6 <printf>
    exit(1);
 394:	4505                	li	a0,1
 396:	3b2000ef          	jal	748 <exit>
 39a:	e426                	sd	s1,8(sp)
    pause(1);
 39c:	4505                	li	a0,1
 39e:	43a000ef          	jal	7d8 <pause>
    printf("[Tick %d] [Process B (pid %d)]: Attempting to acquire Lock 1...\n",
 3a2:	43e000ef          	jal	7e0 <uptime>
 3a6:	84aa                	mv	s1,a0
 3a8:	420000ef          	jal	7c8 <getpid>
 3ac:	862a                	mv	a2,a0
 3ae:	85a6                	mv	a1,s1
 3b0:	00001517          	auipc	a0,0x1
 3b4:	cd050513          	addi	a0,a0,-816 # 1080 <malloc+0x412>
 3b8:	7fe000ef          	jal	bb6 <printf>
    sem_wait(LOCK1);
 3bc:	4501                	li	a0,0
 3be:	442000ef          	jal	800 <sem_wait>
    printf("[Tick %d] [Process B (pid %d)]: ACQUIRED Lock 1.\n",
 3c2:	41e000ef          	jal	7e0 <uptime>
 3c6:	84aa                	mv	s1,a0
 3c8:	400000ef          	jal	7c8 <getpid>
 3cc:	862a                	mv	a2,a0
 3ce:	85a6                	mv	a1,s1
 3d0:	00001517          	auipc	a0,0x1
 3d4:	ed050513          	addi	a0,a0,-304 # 12a0 <malloc+0x632>
 3d8:	7de000ef          	jal	bb6 <printf>
    printf("[Tick %d] [Process B (pid %d)]: Attempting to acquire Lock 2...\n",
 3dc:	404000ef          	jal	7e0 <uptime>
 3e0:	84aa                	mv	s1,a0
 3e2:	3e6000ef          	jal	7c8 <getpid>
 3e6:	862a                	mv	a2,a0
 3e8:	85a6                	mv	a1,s1
 3ea:	00001517          	auipc	a0,0x1
 3ee:	bce50513          	addi	a0,a0,-1074 # fb8 <malloc+0x34a>
 3f2:	7c4000ef          	jal	bb6 <printf>
    sem_wait(LOCK2);
 3f6:	4505                	li	a0,1
 3f8:	408000ef          	jal	800 <sem_wait>
    printf("[Tick %d] [Process B (pid %d)]: ACQUIRED Lock 2. Entering Critical Section.\n",
 3fc:	3e4000ef          	jal	7e0 <uptime>
 400:	84aa                	mv	s1,a0
 402:	3c6000ef          	jal	7c8 <getpid>
 406:	862a                	mv	a2,a0
 408:	85a6                	mv	a1,s1
 40a:	00001517          	auipc	a0,0x1
 40e:	ece50513          	addi	a0,a0,-306 # 12d8 <malloc+0x66a>
 412:	7a4000ef          	jal	bb6 <printf>
    pause(2); // In CS
 416:	4509                	li	a0,2
 418:	3c0000ef          	jal	7d8 <pause>
    printf("[Tick %d] [Process B (pid %d)]: Exiting Critical Section. Releasing Lock 2 and Lock 1.\n",
 41c:	3c4000ef          	jal	7e0 <uptime>
 420:	84aa                	mv	s1,a0
 422:	3a6000ef          	jal	7c8 <getpid>
 426:	862a                	mv	a2,a0
 428:	85a6                	mv	a1,s1
 42a:	00001517          	auipc	a0,0x1
 42e:	efe50513          	addi	a0,a0,-258 # 1328 <malloc+0x6ba>
 432:	784000ef          	jal	bb6 <printf>
    sem_post(LOCK2);
 436:	4505                	li	a0,1
 438:	3d0000ef          	jal	808 <sem_post>
    sem_post(LOCK1);
 43c:	4501                	li	a0,0
 43e:	3ca000ef          	jal	808 <sem_post>
    printf("[Tick %d] [Process B (pid %d)]: Completed successfully.\n",
 442:	39e000ef          	jal	7e0 <uptime>
 446:	84aa                	mv	s1,a0
 448:	380000ef          	jal	7c8 <getpid>
 44c:	862a                	mv	a2,a0
 44e:	85a6                	mv	a1,s1
 450:	00001517          	auipc	a0,0x1
 454:	f3050513          	addi	a0,a0,-208 # 1380 <malloc+0x712>
 458:	75e000ef          	jal	bb6 <printf>
    exit(0);
 45c:	4501                	li	a0,0
 45e:	2ea000ef          	jal	748 <exit>

0000000000000462 <main>:

int main(int argc, char *argv[]) {
 462:	1141                	addi	sp,sp,-16
 464:	e406                	sd	ra,8(sp)
 466:	e022                	sd	s0,0(sp)
 468:	0800                	addi	s0,sp,16
  if (argc > 1 && strcmp(argv[1], "bad") == 0) {
 46a:	4705                	li	a4,1
 46c:	00a75b63          	bge	a4,a0,482 <main+0x20>
 470:	87ae                	mv	a5,a1
 472:	00001597          	auipc	a1,0x1
 476:	fde58593          	addi	a1,a1,-34 # 1450 <malloc+0x7e2>
 47a:	6788                	ld	a0,8(a5)
 47c:	046000ef          	jal	4c2 <strcmp>
 480:	c511                	beqz	a0,48c <main+0x2a>
    run_deadlock_scenario();
  } else {
    run_fixed_scenario();
 482:	d7bff0ef          	jal	1fc <run_fixed_scenario>
  }
  exit(0);
 486:	4501                	li	a0,0
 488:	2c0000ef          	jal	748 <exit>
    run_deadlock_scenario();
 48c:	b75ff0ef          	jal	0 <run_deadlock_scenario>
 490:	bfdd                	j	486 <main+0x24>

0000000000000492 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 492:	1141                	addi	sp,sp,-16
 494:	e406                	sd	ra,8(sp)
 496:	e022                	sd	s0,0(sp)
 498:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 49a:	fc9ff0ef          	jal	462 <main>
  exit(r);
 49e:	2aa000ef          	jal	748 <exit>

00000000000004a2 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 4a2:	1141                	addi	sp,sp,-16
 4a4:	e406                	sd	ra,8(sp)
 4a6:	e022                	sd	s0,0(sp)
 4a8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 4aa:	87aa                	mv	a5,a0
 4ac:	0585                	addi	a1,a1,1
 4ae:	0785                	addi	a5,a5,1
 4b0:	fff5c703          	lbu	a4,-1(a1)
 4b4:	fee78fa3          	sb	a4,-1(a5)
 4b8:	fb75                	bnez	a4,4ac <strcpy+0xa>
    ;
  return os;
}
 4ba:	60a2                	ld	ra,8(sp)
 4bc:	6402                	ld	s0,0(sp)
 4be:	0141                	addi	sp,sp,16
 4c0:	8082                	ret

00000000000004c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4c2:	1141                	addi	sp,sp,-16
 4c4:	e406                	sd	ra,8(sp)
 4c6:	e022                	sd	s0,0(sp)
 4c8:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 4ca:	00054783          	lbu	a5,0(a0)
 4ce:	cb91                	beqz	a5,4e2 <strcmp+0x20>
 4d0:	0005c703          	lbu	a4,0(a1)
 4d4:	00f71763          	bne	a4,a5,4e2 <strcmp+0x20>
    p++, q++;
 4d8:	0505                	addi	a0,a0,1
 4da:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 4dc:	00054783          	lbu	a5,0(a0)
 4e0:	fbe5                	bnez	a5,4d0 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 4e2:	0005c503          	lbu	a0,0(a1)
}
 4e6:	40a7853b          	subw	a0,a5,a0
 4ea:	60a2                	ld	ra,8(sp)
 4ec:	6402                	ld	s0,0(sp)
 4ee:	0141                	addi	sp,sp,16
 4f0:	8082                	ret

00000000000004f2 <strlen>:

uint
strlen(const char *s)
{
 4f2:	1141                	addi	sp,sp,-16
 4f4:	e406                	sd	ra,8(sp)
 4f6:	e022                	sd	s0,0(sp)
 4f8:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 4fa:	00054783          	lbu	a5,0(a0)
 4fe:	cf91                	beqz	a5,51a <strlen+0x28>
 500:	00150793          	addi	a5,a0,1
 504:	86be                	mv	a3,a5
 506:	0785                	addi	a5,a5,1
 508:	fff7c703          	lbu	a4,-1(a5)
 50c:	ff65                	bnez	a4,504 <strlen+0x12>
 50e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 512:	60a2                	ld	ra,8(sp)
 514:	6402                	ld	s0,0(sp)
 516:	0141                	addi	sp,sp,16
 518:	8082                	ret
  for (n = 0; s[n]; n++)
 51a:	4501                	li	a0,0
 51c:	bfdd                	j	512 <strlen+0x20>

000000000000051e <memset>:

void *
memset(void *dst, int c, uint n)
{
 51e:	1141                	addi	sp,sp,-16
 520:	e406                	sd	ra,8(sp)
 522:	e022                	sd	s0,0(sp)
 524:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 526:	ca19                	beqz	a2,53c <memset+0x1e>
 528:	87aa                	mv	a5,a0
 52a:	1602                	slli	a2,a2,0x20
 52c:	9201                	srli	a2,a2,0x20
 52e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 532:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 536:	0785                	addi	a5,a5,1
 538:	fee79de3          	bne	a5,a4,532 <memset+0x14>
  }
  return dst;
}
 53c:	60a2                	ld	ra,8(sp)
 53e:	6402                	ld	s0,0(sp)
 540:	0141                	addi	sp,sp,16
 542:	8082                	ret

0000000000000544 <strchr>:

char *
strchr(const char *s, char c)
{
 544:	1141                	addi	sp,sp,-16
 546:	e406                	sd	ra,8(sp)
 548:	e022                	sd	s0,0(sp)
 54a:	0800                	addi	s0,sp,16
  for (; *s; s++)
 54c:	00054783          	lbu	a5,0(a0)
 550:	cf81                	beqz	a5,568 <strchr+0x24>
    if (*s == c)
 552:	00f58763          	beq	a1,a5,560 <strchr+0x1c>
  for (; *s; s++)
 556:	0505                	addi	a0,a0,1
 558:	00054783          	lbu	a5,0(a0)
 55c:	fbfd                	bnez	a5,552 <strchr+0xe>
      return (char *)s;
  return 0;
 55e:	4501                	li	a0,0
}
 560:	60a2                	ld	ra,8(sp)
 562:	6402                	ld	s0,0(sp)
 564:	0141                	addi	sp,sp,16
 566:	8082                	ret
  return 0;
 568:	4501                	li	a0,0
 56a:	bfdd                	j	560 <strchr+0x1c>

000000000000056c <gets>:

char *
gets(char *buf, int max)
{
 56c:	711d                	addi	sp,sp,-96
 56e:	ec86                	sd	ra,88(sp)
 570:	e8a2                	sd	s0,80(sp)
 572:	e4a6                	sd	s1,72(sp)
 574:	e0ca                	sd	s2,64(sp)
 576:	fc4e                	sd	s3,56(sp)
 578:	f852                	sd	s4,48(sp)
 57a:	f456                	sd	s5,40(sp)
 57c:	f05a                	sd	s6,32(sp)
 57e:	ec5e                	sd	s7,24(sp)
 580:	e862                	sd	s8,16(sp)
 582:	1080                	addi	s0,sp,96
 584:	8baa                	mv	s7,a0
 586:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 588:	892a                	mv	s2,a0
 58a:	4481                	li	s1,0
    cc = read(0, &c, 1);
 58c:	faf40b13          	addi	s6,s0,-81
 590:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 592:	8c26                	mv	s8,s1
 594:	0014899b          	addiw	s3,s1,1
 598:	84ce                	mv	s1,s3
 59a:	0349d463          	bge	s3,s4,5c2 <gets+0x56>
    cc = read(0, &c, 1);
 59e:	8656                	mv	a2,s5
 5a0:	85da                	mv	a1,s6
 5a2:	4501                	li	a0,0
 5a4:	1bc000ef          	jal	760 <read>
    if (cc < 1)
 5a8:	00a05d63          	blez	a0,5c2 <gets+0x56>
      break;
    buf[i++] = c;
 5ac:	faf44783          	lbu	a5,-81(s0)
 5b0:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 5b4:	0905                	addi	s2,s2,1
 5b6:	ff678713          	addi	a4,a5,-10
 5ba:	c319                	beqz	a4,5c0 <gets+0x54>
 5bc:	17cd                	addi	a5,a5,-13
 5be:	fbf1                	bnez	a5,592 <gets+0x26>
    buf[i++] = c;
 5c0:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 5c2:	9c5e                	add	s8,s8,s7
 5c4:	000c0023          	sb	zero,0(s8)
  return buf;
}
 5c8:	855e                	mv	a0,s7
 5ca:	60e6                	ld	ra,88(sp)
 5cc:	6446                	ld	s0,80(sp)
 5ce:	64a6                	ld	s1,72(sp)
 5d0:	6906                	ld	s2,64(sp)
 5d2:	79e2                	ld	s3,56(sp)
 5d4:	7a42                	ld	s4,48(sp)
 5d6:	7aa2                	ld	s5,40(sp)
 5d8:	7b02                	ld	s6,32(sp)
 5da:	6be2                	ld	s7,24(sp)
 5dc:	6c42                	ld	s8,16(sp)
 5de:	6125                	addi	sp,sp,96
 5e0:	8082                	ret

00000000000005e2 <stat>:

int
stat(const char *n, struct stat *st)
{
 5e2:	1101                	addi	sp,sp,-32
 5e4:	ec06                	sd	ra,24(sp)
 5e6:	e822                	sd	s0,16(sp)
 5e8:	e04a                	sd	s2,0(sp)
 5ea:	1000                	addi	s0,sp,32
 5ec:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5ee:	4581                	li	a1,0
 5f0:	198000ef          	jal	788 <open>
  if (fd < 0)
 5f4:	02054263          	bltz	a0,618 <stat+0x36>
 5f8:	e426                	sd	s1,8(sp)
 5fa:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 5fc:	85ca                	mv	a1,s2
 5fe:	1a2000ef          	jal	7a0 <fstat>
 602:	892a                	mv	s2,a0
  close(fd);
 604:	8526                	mv	a0,s1
 606:	16a000ef          	jal	770 <close>
  return r;
 60a:	64a2                	ld	s1,8(sp)
}
 60c:	854a                	mv	a0,s2
 60e:	60e2                	ld	ra,24(sp)
 610:	6442                	ld	s0,16(sp)
 612:	6902                	ld	s2,0(sp)
 614:	6105                	addi	sp,sp,32
 616:	8082                	ret
    return -1;
 618:	57fd                	li	a5,-1
 61a:	893e                	mv	s2,a5
 61c:	bfc5                	j	60c <stat+0x2a>

000000000000061e <atoi>:

int
atoi(const char *s)
{
 61e:	1141                	addi	sp,sp,-16
 620:	e406                	sd	ra,8(sp)
 622:	e022                	sd	s0,0(sp)
 624:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 626:	00054683          	lbu	a3,0(a0)
 62a:	fd06879b          	addiw	a5,a3,-48
 62e:	0ff7f793          	zext.b	a5,a5
 632:	4625                	li	a2,9
 634:	02f66963          	bltu	a2,a5,666 <atoi+0x48>
 638:	872a                	mv	a4,a0
  n = 0;
 63a:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 63c:	0705                	addi	a4,a4,1
 63e:	0025179b          	slliw	a5,a0,0x2
 642:	9fa9                	addw	a5,a5,a0
 644:	0017979b          	slliw	a5,a5,0x1
 648:	9fb5                	addw	a5,a5,a3
 64a:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 64e:	00074683          	lbu	a3,0(a4)
 652:	fd06879b          	addiw	a5,a3,-48
 656:	0ff7f793          	zext.b	a5,a5
 65a:	fef671e3          	bgeu	a2,a5,63c <atoi+0x1e>
  return n;
}
 65e:	60a2                	ld	ra,8(sp)
 660:	6402                	ld	s0,0(sp)
 662:	0141                	addi	sp,sp,16
 664:	8082                	ret
  n = 0;
 666:	4501                	li	a0,0
 668:	bfdd                	j	65e <atoi+0x40>

000000000000066a <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 66a:	1141                	addi	sp,sp,-16
 66c:	e406                	sd	ra,8(sp)
 66e:	e022                	sd	s0,0(sp)
 670:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 672:	02b57563          	bgeu	a0,a1,69c <memmove+0x32>
    while (n-- > 0)
 676:	00c05f63          	blez	a2,694 <memmove+0x2a>
 67a:	1602                	slli	a2,a2,0x20
 67c:	9201                	srli	a2,a2,0x20
 67e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 682:	872a                	mv	a4,a0
      *dst++ = *src++;
 684:	0585                	addi	a1,a1,1
 686:	0705                	addi	a4,a4,1
 688:	fff5c683          	lbu	a3,-1(a1)
 68c:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 690:	fee79ae3          	bne	a5,a4,684 <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 694:	60a2                	ld	ra,8(sp)
 696:	6402                	ld	s0,0(sp)
 698:	0141                	addi	sp,sp,16
 69a:	8082                	ret
    while (n-- > 0)
 69c:	fec05ce3          	blez	a2,694 <memmove+0x2a>
    dst += n;
 6a0:	00c50733          	add	a4,a0,a2
    src += n;
 6a4:	95b2                	add	a1,a1,a2
 6a6:	fff6079b          	addiw	a5,a2,-1
 6aa:	1782                	slli	a5,a5,0x20
 6ac:	9381                	srli	a5,a5,0x20
 6ae:	fff7c793          	not	a5,a5
 6b2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 6b4:	15fd                	addi	a1,a1,-1
 6b6:	177d                	addi	a4,a4,-1
 6b8:	0005c683          	lbu	a3,0(a1)
 6bc:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 6c0:	fef71ae3          	bne	a4,a5,6b4 <memmove+0x4a>
 6c4:	bfc1                	j	694 <memmove+0x2a>

00000000000006c6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 6c6:	1141                	addi	sp,sp,-16
 6c8:	e406                	sd	ra,8(sp)
 6ca:	e022                	sd	s0,0(sp)
 6cc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 6ce:	c61d                	beqz	a2,6fc <memcmp+0x36>
 6d0:	1602                	slli	a2,a2,0x20
 6d2:	9201                	srli	a2,a2,0x20
 6d4:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 6d8:	00054783          	lbu	a5,0(a0)
 6dc:	0005c703          	lbu	a4,0(a1)
 6e0:	00e79863          	bne	a5,a4,6f0 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 6e4:	0505                	addi	a0,a0,1
    p2++;
 6e6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 6e8:	fed518e3          	bne	a0,a3,6d8 <memcmp+0x12>
  }
  return 0;
 6ec:	4501                	li	a0,0
 6ee:	a019                	j	6f4 <memcmp+0x2e>
      return *p1 - *p2;
 6f0:	40e7853b          	subw	a0,a5,a4
}
 6f4:	60a2                	ld	ra,8(sp)
 6f6:	6402                	ld	s0,0(sp)
 6f8:	0141                	addi	sp,sp,16
 6fa:	8082                	ret
  return 0;
 6fc:	4501                	li	a0,0
 6fe:	bfdd                	j	6f4 <memcmp+0x2e>

0000000000000700 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 700:	1141                	addi	sp,sp,-16
 702:	e406                	sd	ra,8(sp)
 704:	e022                	sd	s0,0(sp)
 706:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 708:	f63ff0ef          	jal	66a <memmove>
}
 70c:	60a2                	ld	ra,8(sp)
 70e:	6402                	ld	s0,0(sp)
 710:	0141                	addi	sp,sp,16
 712:	8082                	ret

0000000000000714 <sbrk>:

char *
sbrk(int n)
{
 714:	1141                	addi	sp,sp,-16
 716:	e406                	sd	ra,8(sp)
 718:	e022                	sd	s0,0(sp)
 71a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 71c:	4585                	li	a1,1
 71e:	0b2000ef          	jal	7d0 <sys_sbrk>
}
 722:	60a2                	ld	ra,8(sp)
 724:	6402                	ld	s0,0(sp)
 726:	0141                	addi	sp,sp,16
 728:	8082                	ret

000000000000072a <sbrklazy>:

char *
sbrklazy(int n)
{
 72a:	1141                	addi	sp,sp,-16
 72c:	e406                	sd	ra,8(sp)
 72e:	e022                	sd	s0,0(sp)
 730:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 732:	4589                	li	a1,2
 734:	09c000ef          	jal	7d0 <sys_sbrk>
}
 738:	60a2                	ld	ra,8(sp)
 73a:	6402                	ld	s0,0(sp)
 73c:	0141                	addi	sp,sp,16
 73e:	8082                	ret

0000000000000740 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 740:	4885                	li	a7,1
 ecall
 742:	00000073          	ecall
 ret
 746:	8082                	ret

0000000000000748 <exit>:
.global exit
exit:
 li a7, SYS_exit
 748:	4889                	li	a7,2
 ecall
 74a:	00000073          	ecall
 ret
 74e:	8082                	ret

0000000000000750 <wait>:
.global wait
wait:
 li a7, SYS_wait
 750:	488d                	li	a7,3
 ecall
 752:	00000073          	ecall
 ret
 756:	8082                	ret

0000000000000758 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 758:	4891                	li	a7,4
 ecall
 75a:	00000073          	ecall
 ret
 75e:	8082                	ret

0000000000000760 <read>:
.global read
read:
 li a7, SYS_read
 760:	4895                	li	a7,5
 ecall
 762:	00000073          	ecall
 ret
 766:	8082                	ret

0000000000000768 <write>:
.global write
write:
 li a7, SYS_write
 768:	48c1                	li	a7,16
 ecall
 76a:	00000073          	ecall
 ret
 76e:	8082                	ret

0000000000000770 <close>:
.global close
close:
 li a7, SYS_close
 770:	48d5                	li	a7,21
 ecall
 772:	00000073          	ecall
 ret
 776:	8082                	ret

0000000000000778 <kill>:
.global kill
kill:
 li a7, SYS_kill
 778:	4899                	li	a7,6
 ecall
 77a:	00000073          	ecall
 ret
 77e:	8082                	ret

0000000000000780 <exec>:
.global exec
exec:
 li a7, SYS_exec
 780:	489d                	li	a7,7
 ecall
 782:	00000073          	ecall
 ret
 786:	8082                	ret

0000000000000788 <open>:
.global open
open:
 li a7, SYS_open
 788:	48bd                	li	a7,15
 ecall
 78a:	00000073          	ecall
 ret
 78e:	8082                	ret

0000000000000790 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 790:	48c5                	li	a7,17
 ecall
 792:	00000073          	ecall
 ret
 796:	8082                	ret

0000000000000798 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 798:	48c9                	li	a7,18
 ecall
 79a:	00000073          	ecall
 ret
 79e:	8082                	ret

00000000000007a0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 7a0:	48a1                	li	a7,8
 ecall
 7a2:	00000073          	ecall
 ret
 7a6:	8082                	ret

00000000000007a8 <link>:
.global link
link:
 li a7, SYS_link
 7a8:	48cd                	li	a7,19
 ecall
 7aa:	00000073          	ecall
 ret
 7ae:	8082                	ret

00000000000007b0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 7b0:	48d1                	li	a7,20
 ecall
 7b2:	00000073          	ecall
 ret
 7b6:	8082                	ret

00000000000007b8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 7b8:	48a5                	li	a7,9
 ecall
 7ba:	00000073          	ecall
 ret
 7be:	8082                	ret

00000000000007c0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 7c0:	48a9                	li	a7,10
 ecall
 7c2:	00000073          	ecall
 ret
 7c6:	8082                	ret

00000000000007c8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 7c8:	48ad                	li	a7,11
 ecall
 7ca:	00000073          	ecall
 ret
 7ce:	8082                	ret

00000000000007d0 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 7d0:	48b1                	li	a7,12
 ecall
 7d2:	00000073          	ecall
 ret
 7d6:	8082                	ret

00000000000007d8 <pause>:
.global pause
pause:
 li a7, SYS_pause
 7d8:	48b5                	li	a7,13
 ecall
 7da:	00000073          	ecall
 ret
 7de:	8082                	ret

00000000000007e0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 7e0:	48b9                	li	a7,14
 ecall
 7e2:	00000073          	ecall
 ret
 7e6:	8082                	ret

00000000000007e8 <sync>:
.global sync
sync:
 li a7, SYS_sync
 7e8:	48d9                	li	a7,22
 ecall
 7ea:	00000073          	ecall
 ret
 7ee:	8082                	ret

00000000000007f0 <shm_get>:
.global shm_get
shm_get:
 li a7, SYS_shm_get
 7f0:	48dd                	li	a7,23
 ecall
 7f2:	00000073          	ecall
 ret
 7f6:	8082                	ret

00000000000007f8 <sem_init>:
.global sem_init
sem_init:
 li a7, SYS_sem_init
 7f8:	48e1                	li	a7,24
 ecall
 7fa:	00000073          	ecall
 ret
 7fe:	8082                	ret

0000000000000800 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 800:	48e5                	li	a7,25
 ecall
 802:	00000073          	ecall
 ret
 806:	8082                	ret

0000000000000808 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 808:	48e9                	li	a7,26
 ecall
 80a:	00000073          	ecall
 ret
 80e:	8082                	ret

0000000000000810 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 810:	1101                	addi	sp,sp,-32
 812:	ec06                	sd	ra,24(sp)
 814:	e822                	sd	s0,16(sp)
 816:	1000                	addi	s0,sp,32
 818:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 81c:	4605                	li	a2,1
 81e:	fef40593          	addi	a1,s0,-17
 822:	f47ff0ef          	jal	768 <write>
}
 826:	60e2                	ld	ra,24(sp)
 828:	6442                	ld	s0,16(sp)
 82a:	6105                	addi	sp,sp,32
 82c:	8082                	ret

000000000000082e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 82e:	715d                	addi	sp,sp,-80
 830:	e486                	sd	ra,72(sp)
 832:	e0a2                	sd	s0,64(sp)
 834:	f84a                	sd	s2,48(sp)
 836:	f44e                	sd	s3,40(sp)
 838:	0880                	addi	s0,sp,80
 83a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 83c:	c6d1                	beqz	a3,8c8 <printint+0x9a>
 83e:	0805d563          	bgez	a1,8c8 <printint+0x9a>
    neg = 1;
    x = -xx;
 842:	40b005b3          	neg	a1,a1
    neg = 1;
 846:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 848:	fb840993          	addi	s3,s0,-72
  neg = 0;
 84c:	86ce                	mv	a3,s3
  i = 0;
 84e:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 850:	00001817          	auipc	a6,0x1
 854:	c1080813          	addi	a6,a6,-1008 # 1460 <digits>
 858:	88ba                	mv	a7,a4
 85a:	0017051b          	addiw	a0,a4,1
 85e:	872a                	mv	a4,a0
 860:	02c5f7b3          	remu	a5,a1,a2
 864:	97c2                	add	a5,a5,a6
 866:	0007c783          	lbu	a5,0(a5)
 86a:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 86e:	87ae                	mv	a5,a1
 870:	02c5d5b3          	divu	a1,a1,a2
 874:	0685                	addi	a3,a3,1
 876:	fec7f1e3          	bgeu	a5,a2,858 <printint+0x2a>
  if (neg)
 87a:	00030c63          	beqz	t1,892 <printint+0x64>
    buf[i++] = '-';
 87e:	fd050793          	addi	a5,a0,-48
 882:	00878533          	add	a0,a5,s0
 886:	02d00793          	li	a5,45
 88a:	fef50423          	sb	a5,-24(a0)
 88e:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 892:	02e05563          	blez	a4,8bc <printint+0x8e>
 896:	fc26                	sd	s1,56(sp)
 898:	377d                	addiw	a4,a4,-1
 89a:	00e984b3          	add	s1,s3,a4
 89e:	19fd                	addi	s3,s3,-1
 8a0:	99ba                	add	s3,s3,a4
 8a2:	1702                	slli	a4,a4,0x20
 8a4:	9301                	srli	a4,a4,0x20
 8a6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 8aa:	0004c583          	lbu	a1,0(s1)
 8ae:	854a                	mv	a0,s2
 8b0:	f61ff0ef          	jal	810 <putc>
  while (--i >= 0)
 8b4:	14fd                	addi	s1,s1,-1
 8b6:	ff349ae3          	bne	s1,s3,8aa <printint+0x7c>
 8ba:	74e2                	ld	s1,56(sp)
}
 8bc:	60a6                	ld	ra,72(sp)
 8be:	6406                	ld	s0,64(sp)
 8c0:	7942                	ld	s2,48(sp)
 8c2:	79a2                	ld	s3,40(sp)
 8c4:	6161                	addi	sp,sp,80
 8c6:	8082                	ret
  neg = 0;
 8c8:	4301                	li	t1,0
 8ca:	bfbd                	j	848 <printint+0x1a>

00000000000008cc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 8cc:	711d                	addi	sp,sp,-96
 8ce:	ec86                	sd	ra,88(sp)
 8d0:	e8a2                	sd	s0,80(sp)
 8d2:	e4a6                	sd	s1,72(sp)
 8d4:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 8d6:	0005c483          	lbu	s1,0(a1)
 8da:	22048363          	beqz	s1,b00 <vprintf+0x234>
 8de:	e0ca                	sd	s2,64(sp)
 8e0:	fc4e                	sd	s3,56(sp)
 8e2:	f852                	sd	s4,48(sp)
 8e4:	f456                	sd	s5,40(sp)
 8e6:	f05a                	sd	s6,32(sp)
 8e8:	ec5e                	sd	s7,24(sp)
 8ea:	e862                	sd	s8,16(sp)
 8ec:	8b2a                	mv	s6,a0
 8ee:	8a2e                	mv	s4,a1
 8f0:	8bb2                	mv	s7,a2
  state = 0;
 8f2:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 8f4:	4901                	li	s2,0
 8f6:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 8f8:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 8fc:	06400c13          	li	s8,100
 900:	a00d                	j	922 <vprintf+0x56>
        putc(fd, c0);
 902:	85a6                	mv	a1,s1
 904:	855a                	mv	a0,s6
 906:	f0bff0ef          	jal	810 <putc>
 90a:	a019                	j	910 <vprintf+0x44>
    } else if (state == '%') {
 90c:	03598363          	beq	s3,s5,932 <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 910:	0019079b          	addiw	a5,s2,1
 914:	893e                	mv	s2,a5
 916:	873e                	mv	a4,a5
 918:	97d2                	add	a5,a5,s4
 91a:	0007c483          	lbu	s1,0(a5)
 91e:	1c048a63          	beqz	s1,af2 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 922:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 926:	fe0993e3          	bnez	s3,90c <vprintf+0x40>
      if (c0 == '%') {
 92a:	fd579ce3          	bne	a5,s5,902 <vprintf+0x36>
        state = '%';
 92e:	89be                	mv	s3,a5
 930:	b7c5                	j	910 <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 932:	00ea06b3          	add	a3,s4,a4
 936:	0016c603          	lbu	a2,1(a3)
      if (c1)
 93a:	1c060863          	beqz	a2,b0a <vprintf+0x23e>
      if (c0 == 'd') {
 93e:	03878763          	beq	a5,s8,96c <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 942:	f9478693          	addi	a3,a5,-108
 946:	0016b693          	seqz	a3,a3
 94a:	f9c60593          	addi	a1,a2,-100
 94e:	e99d                	bnez	a1,984 <vprintf+0xb8>
 950:	ca95                	beqz	a3,984 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 952:	008b8493          	addi	s1,s7,8
 956:	4685                	li	a3,1
 958:	4629                	li	a2,10
 95a:	000bb583          	ld	a1,0(s7)
 95e:	855a                	mv	a0,s6
 960:	ecfff0ef          	jal	82e <printint>
        i += 1;
 964:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 966:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 968:	4981                	li	s3,0
 96a:	b75d                	j	910 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 96c:	008b8493          	addi	s1,s7,8
 970:	4685                	li	a3,1
 972:	4629                	li	a2,10
 974:	000ba583          	lw	a1,0(s7)
 978:	855a                	mv	a0,s6
 97a:	eb5ff0ef          	jal	82e <printint>
 97e:	8ba6                	mv	s7,s1
      state = 0;
 980:	4981                	li	s3,0
 982:	b779                	j	910 <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 984:	9752                	add	a4,a4,s4
 986:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 98a:	f9460713          	addi	a4,a2,-108
 98e:	00173713          	seqz	a4,a4
 992:	8f75                	and	a4,a4,a3
 994:	f9c58513          	addi	a0,a1,-100
 998:	18051363          	bnez	a0,b1e <vprintf+0x252>
 99c:	18070163          	beqz	a4,b1e <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 9a0:	008b8493          	addi	s1,s7,8
 9a4:	4685                	li	a3,1
 9a6:	4629                	li	a2,10
 9a8:	000bb583          	ld	a1,0(s7)
 9ac:	855a                	mv	a0,s6
 9ae:	e81ff0ef          	jal	82e <printint>
        i += 2;
 9b2:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 9b4:	8ba6                	mv	s7,s1
      state = 0;
 9b6:	4981                	li	s3,0
        i += 2;
 9b8:	bfa1                	j	910 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 9ba:	008b8493          	addi	s1,s7,8
 9be:	4681                	li	a3,0
 9c0:	4629                	li	a2,10
 9c2:	000be583          	lwu	a1,0(s7)
 9c6:	855a                	mv	a0,s6
 9c8:	e67ff0ef          	jal	82e <printint>
 9cc:	8ba6                	mv	s7,s1
      state = 0;
 9ce:	4981                	li	s3,0
 9d0:	b781                	j	910 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 9d2:	008b8493          	addi	s1,s7,8
 9d6:	4681                	li	a3,0
 9d8:	4629                	li	a2,10
 9da:	000bb583          	ld	a1,0(s7)
 9de:	855a                	mv	a0,s6
 9e0:	e4fff0ef          	jal	82e <printint>
        i += 1;
 9e4:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 9e6:	8ba6                	mv	s7,s1
      state = 0;
 9e8:	4981                	li	s3,0
 9ea:	b71d                	j	910 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 9ec:	008b8493          	addi	s1,s7,8
 9f0:	4681                	li	a3,0
 9f2:	4629                	li	a2,10
 9f4:	000bb583          	ld	a1,0(s7)
 9f8:	855a                	mv	a0,s6
 9fa:	e35ff0ef          	jal	82e <printint>
        i += 2;
 9fe:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 a00:	8ba6                	mv	s7,s1
      state = 0;
 a02:	4981                	li	s3,0
        i += 2;
 a04:	b731                	j	910 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 a06:	008b8493          	addi	s1,s7,8
 a0a:	4681                	li	a3,0
 a0c:	4641                	li	a2,16
 a0e:	000be583          	lwu	a1,0(s7)
 a12:	855a                	mv	a0,s6
 a14:	e1bff0ef          	jal	82e <printint>
 a18:	8ba6                	mv	s7,s1
      state = 0;
 a1a:	4981                	li	s3,0
 a1c:	bdd5                	j	910 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 a1e:	008b8493          	addi	s1,s7,8
 a22:	4681                	li	a3,0
 a24:	4641                	li	a2,16
 a26:	000bb583          	ld	a1,0(s7)
 a2a:	855a                	mv	a0,s6
 a2c:	e03ff0ef          	jal	82e <printint>
        i += 1;
 a30:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 a32:	8ba6                	mv	s7,s1
      state = 0;
 a34:	4981                	li	s3,0
 a36:	bde9                	j	910 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 a38:	008b8493          	addi	s1,s7,8
 a3c:	4681                	li	a3,0
 a3e:	4641                	li	a2,16
 a40:	000bb583          	ld	a1,0(s7)
 a44:	855a                	mv	a0,s6
 a46:	de9ff0ef          	jal	82e <printint>
        i += 2;
 a4a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 a4c:	8ba6                	mv	s7,s1
      state = 0;
 a4e:	4981                	li	s3,0
        i += 2;
 a50:	b5c1                	j	910 <vprintf+0x44>
 a52:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 a54:	008b8793          	addi	a5,s7,8
 a58:	8cbe                	mv	s9,a5
 a5a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 a5e:	03000593          	li	a1,48
 a62:	855a                	mv	a0,s6
 a64:	dadff0ef          	jal	810 <putc>
  putc(fd, 'x');
 a68:	07800593          	li	a1,120
 a6c:	855a                	mv	a0,s6
 a6e:	da3ff0ef          	jal	810 <putc>
 a72:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 a74:	00001b97          	auipc	s7,0x1
 a78:	9ecb8b93          	addi	s7,s7,-1556 # 1460 <digits>
 a7c:	03c9d793          	srli	a5,s3,0x3c
 a80:	97de                	add	a5,a5,s7
 a82:	0007c583          	lbu	a1,0(a5)
 a86:	855a                	mv	a0,s6
 a88:	d89ff0ef          	jal	810 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 a8c:	0992                	slli	s3,s3,0x4
 a8e:	34fd                	addiw	s1,s1,-1
 a90:	f4f5                	bnez	s1,a7c <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 a92:	8be6                	mv	s7,s9
      state = 0;
 a94:	4981                	li	s3,0
 a96:	6ca2                	ld	s9,8(sp)
 a98:	bda5                	j	910 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 a9a:	008b8493          	addi	s1,s7,8
 a9e:	000bc583          	lbu	a1,0(s7)
 aa2:	855a                	mv	a0,s6
 aa4:	d6dff0ef          	jal	810 <putc>
 aa8:	8ba6                	mv	s7,s1
      state = 0;
 aaa:	4981                	li	s3,0
 aac:	b595                	j	910 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 aae:	008b8993          	addi	s3,s7,8
 ab2:	000bb483          	ld	s1,0(s7)
 ab6:	cc91                	beqz	s1,ad2 <vprintf+0x206>
        for (; *s; s++)
 ab8:	0004c583          	lbu	a1,0(s1)
 abc:	c985                	beqz	a1,aec <vprintf+0x220>
          putc(fd, *s);
 abe:	855a                	mv	a0,s6
 ac0:	d51ff0ef          	jal	810 <putc>
        for (; *s; s++)
 ac4:	0485                	addi	s1,s1,1
 ac6:	0004c583          	lbu	a1,0(s1)
 aca:	f9f5                	bnez	a1,abe <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 acc:	8bce                	mv	s7,s3
      state = 0;
 ace:	4981                	li	s3,0
 ad0:	b581                	j	910 <vprintf+0x44>
          s = "(null)";
 ad2:	00001497          	auipc	s1,0x1
 ad6:	98648493          	addi	s1,s1,-1658 # 1458 <malloc+0x7ea>
        for (; *s; s++)
 ada:	02800593          	li	a1,40
 ade:	b7c5                	j	abe <vprintf+0x1f2>
        putc(fd, '%');
 ae0:	85be                	mv	a1,a5
 ae2:	855a                	mv	a0,s6
 ae4:	d2dff0ef          	jal	810 <putc>
      state = 0;
 ae8:	4981                	li	s3,0
 aea:	b51d                	j	910 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 aec:	8bce                	mv	s7,s3
      state = 0;
 aee:	4981                	li	s3,0
 af0:	b505                	j	910 <vprintf+0x44>
 af2:	6906                	ld	s2,64(sp)
 af4:	79e2                	ld	s3,56(sp)
 af6:	7a42                	ld	s4,48(sp)
 af8:	7aa2                	ld	s5,40(sp)
 afa:	7b02                	ld	s6,32(sp)
 afc:	6be2                	ld	s7,24(sp)
 afe:	6c42                	ld	s8,16(sp)
    }
  }
}
 b00:	60e6                	ld	ra,88(sp)
 b02:	6446                	ld	s0,80(sp)
 b04:	64a6                	ld	s1,72(sp)
 b06:	6125                	addi	sp,sp,96
 b08:	8082                	ret
      if (c0 == 'd') {
 b0a:	06400713          	li	a4,100
 b0e:	e4e78fe3          	beq	a5,a4,96c <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 b12:	f9478693          	addi	a3,a5,-108
 b16:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 b1a:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 b1c:	4701                	li	a4,0
      } else if (c0 == 'u') {
 b1e:	07500513          	li	a0,117
 b22:	e8a78ce3          	beq	a5,a0,9ba <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 b26:	f8b60513          	addi	a0,a2,-117
 b2a:	e119                	bnez	a0,b30 <vprintf+0x264>
 b2c:	ea0693e3          	bnez	a3,9d2 <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 b30:	f8b58513          	addi	a0,a1,-117
 b34:	e119                	bnez	a0,b3a <vprintf+0x26e>
 b36:	ea071be3          	bnez	a4,9ec <vprintf+0x120>
      } else if (c0 == 'x') {
 b3a:	07800513          	li	a0,120
 b3e:	eca784e3          	beq	a5,a0,a06 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 b42:	f8860613          	addi	a2,a2,-120
 b46:	e219                	bnez	a2,b4c <vprintf+0x280>
 b48:	ec069be3          	bnez	a3,a1e <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 b4c:	f8858593          	addi	a1,a1,-120
 b50:	e199                	bnez	a1,b56 <vprintf+0x28a>
 b52:	ee0713e3          	bnez	a4,a38 <vprintf+0x16c>
      } else if (c0 == 'p') {
 b56:	07000713          	li	a4,112
 b5a:	eee78ce3          	beq	a5,a4,a52 <vprintf+0x186>
      } else if (c0 == 'c') {
 b5e:	06300713          	li	a4,99
 b62:	f2e78ce3          	beq	a5,a4,a9a <vprintf+0x1ce>
      } else if (c0 == 's') {
 b66:	07300713          	li	a4,115
 b6a:	f4e782e3          	beq	a5,a4,aae <vprintf+0x1e2>
      } else if (c0 == '%') {
 b6e:	02500713          	li	a4,37
 b72:	f6e787e3          	beq	a5,a4,ae0 <vprintf+0x214>
        putc(fd, '%');
 b76:	02500593          	li	a1,37
 b7a:	855a                	mv	a0,s6
 b7c:	c95ff0ef          	jal	810 <putc>
        putc(fd, c0);
 b80:	85a6                	mv	a1,s1
 b82:	855a                	mv	a0,s6
 b84:	c8dff0ef          	jal	810 <putc>
      state = 0;
 b88:	4981                	li	s3,0
 b8a:	b359                	j	910 <vprintf+0x44>

0000000000000b8c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 b8c:	715d                	addi	sp,sp,-80
 b8e:	ec06                	sd	ra,24(sp)
 b90:	e822                	sd	s0,16(sp)
 b92:	1000                	addi	s0,sp,32
 b94:	e010                	sd	a2,0(s0)
 b96:	e414                	sd	a3,8(s0)
 b98:	e818                	sd	a4,16(s0)
 b9a:	ec1c                	sd	a5,24(s0)
 b9c:	03043023          	sd	a6,32(s0)
 ba0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 ba4:	8622                	mv	a2,s0
 ba6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 baa:	d23ff0ef          	jal	8cc <vprintf>
}
 bae:	60e2                	ld	ra,24(sp)
 bb0:	6442                	ld	s0,16(sp)
 bb2:	6161                	addi	sp,sp,80
 bb4:	8082                	ret

0000000000000bb6 <printf>:

void
printf(const char *fmt, ...)
{
 bb6:	711d                	addi	sp,sp,-96
 bb8:	ec06                	sd	ra,24(sp)
 bba:	e822                	sd	s0,16(sp)
 bbc:	1000                	addi	s0,sp,32
 bbe:	e40c                	sd	a1,8(s0)
 bc0:	e810                	sd	a2,16(s0)
 bc2:	ec14                	sd	a3,24(s0)
 bc4:	f018                	sd	a4,32(s0)
 bc6:	f41c                	sd	a5,40(s0)
 bc8:	03043823          	sd	a6,48(s0)
 bcc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 bd0:	00840613          	addi	a2,s0,8
 bd4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 bd8:	85aa                	mv	a1,a0
 bda:	4505                	li	a0,1
 bdc:	cf1ff0ef          	jal	8cc <vprintf>
}
 be0:	60e2                	ld	ra,24(sp)
 be2:	6442                	ld	s0,16(sp)
 be4:	6125                	addi	sp,sp,96
 be6:	8082                	ret

0000000000000be8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 be8:	1141                	addi	sp,sp,-16
 bea:	e406                	sd	ra,8(sp)
 bec:	e022                	sd	s0,0(sp)
 bee:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 bf0:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bf4:	00001797          	auipc	a5,0x1
 bf8:	40c7b783          	ld	a5,1036(a5) # 2000 <freep>
 bfc:	a039                	j	c0a <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 bfe:	6398                	ld	a4,0(a5)
 c00:	00e7e463          	bltu	a5,a4,c08 <free+0x20>
 c04:	00e6ea63          	bltu	a3,a4,c18 <free+0x30>
{
 c08:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c0a:	fed7fae3          	bgeu	a5,a3,bfe <free+0x16>
 c0e:	6398                	ld	a4,0(a5)
 c10:	00e6e463          	bltu	a3,a4,c18 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 c14:	fee7eae3          	bltu	a5,a4,c08 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 c18:	ff852583          	lw	a1,-8(a0)
 c1c:	6390                	ld	a2,0(a5)
 c1e:	02059813          	slli	a6,a1,0x20
 c22:	01c85713          	srli	a4,a6,0x1c
 c26:	9736                	add	a4,a4,a3
 c28:	02e60563          	beq	a2,a4,c52 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 c2c:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 c30:	4790                	lw	a2,8(a5)
 c32:	02061593          	slli	a1,a2,0x20
 c36:	01c5d713          	srli	a4,a1,0x1c
 c3a:	973e                	add	a4,a4,a5
 c3c:	02e68263          	beq	a3,a4,c60 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 c40:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 c42:	00001717          	auipc	a4,0x1
 c46:	3af73f23          	sd	a5,958(a4) # 2000 <freep>
}
 c4a:	60a2                	ld	ra,8(sp)
 c4c:	6402                	ld	s0,0(sp)
 c4e:	0141                	addi	sp,sp,16
 c50:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 c52:	4618                	lw	a4,8(a2)
 c54:	9f2d                	addw	a4,a4,a1
 c56:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 c5a:	6398                	ld	a4,0(a5)
 c5c:	6310                	ld	a2,0(a4)
 c5e:	b7f9                	j	c2c <free+0x44>
    p->s.size += bp->s.size;
 c60:	ff852703          	lw	a4,-8(a0)
 c64:	9f31                	addw	a4,a4,a2
 c66:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 c68:	ff053683          	ld	a3,-16(a0)
 c6c:	bfd1                	j	c40 <free+0x58>

0000000000000c6e <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 c6e:	7139                	addi	sp,sp,-64
 c70:	fc06                	sd	ra,56(sp)
 c72:	f822                	sd	s0,48(sp)
 c74:	f04a                	sd	s2,32(sp)
 c76:	ec4e                	sd	s3,24(sp)
 c78:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 c7a:	02051993          	slli	s3,a0,0x20
 c7e:	0209d993          	srli	s3,s3,0x20
 c82:	09bd                	addi	s3,s3,15
 c84:	0049d993          	srli	s3,s3,0x4
 c88:	2985                	addiw	s3,s3,1
 c8a:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 c8c:	00001517          	auipc	a0,0x1
 c90:	37453503          	ld	a0,884(a0) # 2000 <freep>
 c94:	c905                	beqz	a0,cc4 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 c96:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 c98:	4798                	lw	a4,8(a5)
 c9a:	09377663          	bgeu	a4,s3,d26 <malloc+0xb8>
 c9e:	f426                	sd	s1,40(sp)
 ca0:	e852                	sd	s4,16(sp)
 ca2:	e456                	sd	s5,8(sp)
 ca4:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 ca6:	8a4e                	mv	s4,s3
 ca8:	6705                	lui	a4,0x1
 caa:	00e9f363          	bgeu	s3,a4,cb0 <malloc+0x42>
 cae:	6a05                	lui	s4,0x1
 cb0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 cb4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 cb8:	00001497          	auipc	s1,0x1
 cbc:	34848493          	addi	s1,s1,840 # 2000 <freep>
  if (p == SBRK_ERROR)
 cc0:	5afd                	li	s5,-1
 cc2:	a83d                	j	d00 <malloc+0x92>
 cc4:	f426                	sd	s1,40(sp)
 cc6:	e852                	sd	s4,16(sp)
 cc8:	e456                	sd	s5,8(sp)
 cca:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 ccc:	00001797          	auipc	a5,0x1
 cd0:	34478793          	addi	a5,a5,836 # 2010 <base>
 cd4:	00001717          	auipc	a4,0x1
 cd8:	32f73623          	sd	a5,812(a4) # 2000 <freep>
 cdc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 cde:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 ce2:	b7d1                	j	ca6 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 ce4:	6398                	ld	a4,0(a5)
 ce6:	e118                	sd	a4,0(a0)
 ce8:	a899                	j	d3e <malloc+0xd0>
  hp->s.size = nu;
 cea:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 cee:	0541                	addi	a0,a0,16
 cf0:	ef9ff0ef          	jal	be8 <free>
  return freep;
 cf4:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 cf6:	c125                	beqz	a0,d56 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 cf8:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 cfa:	4798                	lw	a4,8(a5)
 cfc:	03277163          	bgeu	a4,s2,d1e <malloc+0xb0>
    if (p == freep)
 d00:	6098                	ld	a4,0(s1)
 d02:	853e                	mv	a0,a5
 d04:	fef71ae3          	bne	a4,a5,cf8 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 d08:	8552                	mv	a0,s4
 d0a:	a0bff0ef          	jal	714 <sbrk>
  if (p == SBRK_ERROR)
 d0e:	fd551ee3          	bne	a0,s5,cea <malloc+0x7c>
        return 0;
 d12:	4501                	li	a0,0
 d14:	74a2                	ld	s1,40(sp)
 d16:	6a42                	ld	s4,16(sp)
 d18:	6aa2                	ld	s5,8(sp)
 d1a:	6b02                	ld	s6,0(sp)
 d1c:	a03d                	j	d4a <malloc+0xdc>
 d1e:	74a2                	ld	s1,40(sp)
 d20:	6a42                	ld	s4,16(sp)
 d22:	6aa2                	ld	s5,8(sp)
 d24:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 d26:	fae90fe3          	beq	s2,a4,ce4 <malloc+0x76>
        p->s.size -= nunits;
 d2a:	4137073b          	subw	a4,a4,s3
 d2e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 d30:	02071693          	slli	a3,a4,0x20
 d34:	01c6d713          	srli	a4,a3,0x1c
 d38:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 d3a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 d3e:	00001717          	auipc	a4,0x1
 d42:	2ca73123          	sd	a0,706(a4) # 2000 <freep>
      return (void *)(p + 1);
 d46:	01078513          	addi	a0,a5,16
  }
}
 d4a:	70e2                	ld	ra,56(sp)
 d4c:	7442                	ld	s0,48(sp)
 d4e:	7902                	ld	s2,32(sp)
 d50:	69e2                	ld	s3,24(sp)
 d52:	6121                	addi	sp,sp,64
 d54:	8082                	ret
 d56:	74a2                	ld	s1,40(sp)
 d58:	6a42                	ld	s4,16(sp)
 d5a:	6aa2                	ld	s5,8(sp)
 d5c:	6b02                	ld	s6,0(sp)
 d5e:	b7f5                	j	d4a <malloc+0xdc>
