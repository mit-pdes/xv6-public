
user/_sjftest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"

#define NUM_CHILDREN 4
#define WORKLOAD 50000000ULL

int main(int argc, char *argv[]) {
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
  16:	0100                	addi	s0,sp,128
  int pids[NUM_CHILDREN];
  // Deliberately unsorted burst times to prove SJF reorders execution
  // Arrival order: 40, 10, 30, 20
  int burst_times[NUM_CHILDREN] = {40, 10, 30, 20};
  18:	02800793          	li	a5,40
  1c:	f8f42823          	sw	a5,-112(s0)
  20:	47a9                	li	a5,10
  22:	f8f42a23          	sw	a5,-108(s0)
  26:	47f9                	li	a5,30
  28:	f8f42c23          	sw	a5,-104(s0)
  2c:	47d1                	li	a5,20
  2e:	f8f42e23          	sw	a5,-100(s0)

  printf("--- Non-preemptive Shortest Job First (SJF) Test ---\n");
  32:	00001517          	auipc	a0,0x1
  36:	a3e50513          	addi	a0,a0,-1474 # a70 <malloc+0xfc>
  3a:	083000ef          	jal	8bc <printf>
  printf("Parent PID: %d\n", getpid());
  3e:	4a8000ef          	jal	4e6 <getpid>
  42:	85aa                	mv	a1,a0
  44:	00001517          	auipc	a0,0x1
  48:	a6c50513          	addi	a0,a0,-1428 # ab0 <malloc+0x13c>
  4c:	071000ef          	jal	8bc <printf>
  printf("Forking %d processes with declared burst times (40, 10, 30, 20 ticks)...\n\n", NUM_CHILDREN);
  50:	4591                	li	a1,4
  52:	00001517          	auipc	a0,0x1
  56:	a6e50513          	addi	a0,a0,-1426 # ac0 <malloc+0x14c>
  5a:	063000ef          	jal	8bc <printf>

  for (int i = 0; i < NUM_CHILDREN; i++) {
  5e:	f9040a93          	addi	s5,s0,-112
  62:	fa040a13          	addi	s4,s0,-96
  printf("Forking %d processes with declared burst times (40, 10, 30, 20 ticks)...\n\n", NUM_CHILDREN);
  66:	89d2                	mv	s3,s4
  for (int i = 0; i < NUM_CHILDREN; i++) {
  68:	4901                	li	s2,0
      exit(0);
    } else {
      // Parent also records burst time in kernel immediately
      set_burst(pid, burst_times[i]);
      pids[i] = pid;
      printf("[Parent] Forked Child %d (PID %d) with declared burst time = %d\n",
  6a:	00001c17          	auipc	s8,0x1
  6e:	b3ec0c13          	addi	s8,s8,-1218 # ba8 <malloc+0x234>
  for (int i = 0; i < NUM_CHILDREN; i++) {
  72:	4b91                	li	s7,4
    int pid = fork();
  74:	3ea000ef          	jal	45e <fork>
  78:	84aa                	mv	s1,a0
    if (pid < 0) {
  7a:	08054363          	bltz	a0,100 <main+0x100>
    if (pid == 0) {
  7e:	c951                	beqz	a0,112 <main+0x112>
      set_burst(pid, burst_times[i]);
  80:	000aab03          	lw	s6,0(s5)
  84:	85da                	mv	a1,s6
  86:	488000ef          	jal	50e <set_burst>
      pids[i] = pid;
  8a:	0099a023          	sw	s1,0(s3)
      printf("[Parent] Forked Child %d (PID %d) with declared burst time = %d\n",
  8e:	0019059b          	addiw	a1,s2,1
  92:	892e                	mv	s2,a1
  94:	86da                	mv	a3,s6
  96:	8626                	mv	a2,s1
  98:	8562                	mv	a0,s8
  9a:	023000ef          	jal	8bc <printf>
  for (int i = 0; i < NUM_CHILDREN; i++) {
  9e:	0a91                	addi	s5,s5,4
  a0:	0991                	addi	s3,s3,4
  a2:	fd7919e3          	bne	s2,s7,74 <main+0x74>
             i + 1, pid, burst_times[i]);
    }
  }

  printf("\n[Parent] All children forked. Waiting for completion...\n\n");
  a6:	00001517          	auipc	a0,0x1
  aa:	b4a50513          	addi	a0,a0,-1206 # bf0 <malloc+0x27c>
  ae:	00f000ef          	jal	8bc <printf>

  for (int order = 1; order <= NUM_CHILDREN; order++) {
  b2:	4485                	li	s1,1
    int finished_pid = wait(0);
    int child_idx = -1;
    int bt = -1;
    for (int i = 0; i < NUM_CHILDREN; i++) {
  b4:	4911                	li	s2,4
    int bt = -1;
  b6:	59fd                	li	s3,-1
        child_idx = i + 1;
        bt = burst_times[i];
        break;
      }
    }
    printf(">> Completion Order %d: PID %d (Child %d, Declared Burst Time %d ticks)\n",
  b8:	00001b17          	auipc	s6,0x1
  bc:	b78b0b13          	addi	s6,s6,-1160 # c30 <malloc+0x2bc>
  for (int order = 1; order <= NUM_CHILDREN; order++) {
  c0:	4a95                	li	s5,5
    int finished_pid = wait(0);
  c2:	4501                	li	a0,0
  c4:	3aa000ef          	jal	46e <wait>
  c8:	862a                	mv	a2,a0
  ca:	8752                	mv	a4,s4
    for (int i = 0; i < NUM_CHILDREN; i++) {
  cc:	4781                	li	a5,0
      if (pids[i] == finished_pid) {
  ce:	4314                	lw	a3,0(a4)
  d0:	0cc68763          	beq	a3,a2,19e <main+0x19e>
    for (int i = 0; i < NUM_CHILDREN; i++) {
  d4:	2785                	addiw	a5,a5,1
  d6:	0711                	addi	a4,a4,4
  d8:	ff279be3          	bne	a5,s2,ce <main+0xce>
    int bt = -1;
  dc:	874e                	mv	a4,s3
    int child_idx = -1;
  de:	86ce                	mv	a3,s3
    printf(">> Completion Order %d: PID %d (Child %d, Declared Burst Time %d ticks)\n",
  e0:	85a6                	mv	a1,s1
  e2:	855a                	mv	a0,s6
  e4:	7d8000ef          	jal	8bc <printf>
  for (int order = 1; order <= NUM_CHILDREN; order++) {
  e8:	2485                	addiw	s1,s1,1
  ea:	fd549ce3          	bne	s1,s5,c2 <main+0xc2>
           order, finished_pid, child_idx, bt);
  }

  printf("\n--- SJF Test Passed: Processes completed strictly in ascending order of declared burst time! ---\n");
  ee:	00001517          	auipc	a0,0x1
  f2:	b9250513          	addi	a0,a0,-1134 # c80 <malloc+0x30c>
  f6:	7c6000ef          	jal	8bc <printf>
  exit(0);
  fa:	4501                	li	a0,0
  fc:	36a000ef          	jal	466 <exit>
      printf("Fork failed!\n");
 100:	00001517          	auipc	a0,0x1
 104:	a1050513          	addi	a0,a0,-1520 # b10 <malloc+0x19c>
 108:	7b4000ef          	jal	8bc <printf>
      exit(1);
 10c:	4505                	li	a0,1
 10e:	358000ef          	jal	466 <exit>
      int my_pid = getpid();
 112:	3d4000ef          	jal	4e6 <getpid>
 116:	84aa                	mv	s1,a0
      set_burst(my_pid, burst_times[i]);
 118:	00291793          	slli	a5,s2,0x2
 11c:	fb078793          	addi	a5,a5,-80
 120:	97a2                	add	a5,a5,s0
 122:	fe07a983          	lw	s3,-32(a5)
 126:	85ce                	mv	a1,s3
 128:	3e6000ef          	jal	50e <set_burst>
      printf("[Child %d | PID %d] Declared burst time = %d ticks (uptime: %d)\n",
 12c:	2905                	addiw	s2,s2,1
 12e:	3d0000ef          	jal	4fe <uptime>
 132:	872a                	mv	a4,a0
 134:	86ce                	mv	a3,s3
 136:	8626                	mv	a2,s1
 138:	85ca                	mv	a1,s2
 13a:	00001517          	auipc	a0,0x1
 13e:	9e650513          	addi	a0,a0,-1562 # b20 <malloc+0x1ac>
 142:	77a000ef          	jal	8bc <printf>
      volatile uint64 counter = 0;
 146:	f8043023          	sd	zero,-128(s0)
      for (volatile uint64 j = 0; j < WORKLOAD; j++) {
 14a:	f8043423          	sd	zero,-120(s0)
 14e:	f8843703          	ld	a4,-120(s0)
 152:	02faf7b7          	lui	a5,0x2faf
 156:	07f78793          	addi	a5,a5,127 # 2faf07f <base+0x2fad06f>
 15a:	02e7e363          	bltu	a5,a4,180 <main+0x180>
 15e:	86be                	mv	a3,a5
        counter += j;
 160:	f8843703          	ld	a4,-120(s0)
 164:	f8043783          	ld	a5,-128(s0)
 168:	97ba                	add	a5,a5,a4
 16a:	f8f43023          	sd	a5,-128(s0)
      for (volatile uint64 j = 0; j < WORKLOAD; j++) {
 16e:	f8843783          	ld	a5,-120(s0)
 172:	0785                	addi	a5,a5,1
 174:	f8f43423          	sd	a5,-120(s0)
 178:	f8843783          	ld	a5,-120(s0)
 17c:	fef6f2e3          	bgeu	a3,a5,160 <main+0x160>
      printf("[Child %d | PID %d | BT %d] Completed workload at tick %d\n",
 180:	37e000ef          	jal	4fe <uptime>
 184:	872a                	mv	a4,a0
 186:	86ce                	mv	a3,s3
 188:	8626                	mv	a2,s1
 18a:	85ca                	mv	a1,s2
 18c:	00001517          	auipc	a0,0x1
 190:	9dc50513          	addi	a0,a0,-1572 # b68 <malloc+0x1f4>
 194:	728000ef          	jal	8bc <printf>
      exit(0);
 198:	4501                	li	a0,0
 19a:	2cc000ef          	jal	466 <exit>
        child_idx = i + 1;
 19e:	0017869b          	addiw	a3,a5,1
        bt = burst_times[i];
 1a2:	078a                	slli	a5,a5,0x2
 1a4:	fb078793          	addi	a5,a5,-80
 1a8:	97a2                	add	a5,a5,s0
 1aa:	fe07a703          	lw	a4,-32(a5)
        break;
 1ae:	bf0d                	j	e0 <main+0xe0>

00000000000001b0 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1b0:	1141                	addi	sp,sp,-16
 1b2:	e406                	sd	ra,8(sp)
 1b4:	e022                	sd	s0,0(sp)
 1b6:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1b8:	e49ff0ef          	jal	0 <main>
  exit(r);
 1bc:	2aa000ef          	jal	466 <exit>

00000000000001c0 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 1c0:	1141                	addi	sp,sp,-16
 1c2:	e406                	sd	ra,8(sp)
 1c4:	e022                	sd	s0,0(sp)
 1c6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 1c8:	87aa                	mv	a5,a0
 1ca:	0585                	addi	a1,a1,1
 1cc:	0785                	addi	a5,a5,1
 1ce:	fff5c703          	lbu	a4,-1(a1)
 1d2:	fee78fa3          	sb	a4,-1(a5)
 1d6:	fb75                	bnez	a4,1ca <strcpy+0xa>
    ;
  return os;
}
 1d8:	60a2                	ld	ra,8(sp)
 1da:	6402                	ld	s0,0(sp)
 1dc:	0141                	addi	sp,sp,16
 1de:	8082                	ret

00000000000001e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1e0:	1141                	addi	sp,sp,-16
 1e2:	e406                	sd	ra,8(sp)
 1e4:	e022                	sd	s0,0(sp)
 1e6:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 1e8:	00054783          	lbu	a5,0(a0)
 1ec:	cb91                	beqz	a5,200 <strcmp+0x20>
 1ee:	0005c703          	lbu	a4,0(a1)
 1f2:	00f71763          	bne	a4,a5,200 <strcmp+0x20>
    p++, q++;
 1f6:	0505                	addi	a0,a0,1
 1f8:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 1fa:	00054783          	lbu	a5,0(a0)
 1fe:	fbe5                	bnez	a5,1ee <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 200:	0005c503          	lbu	a0,0(a1)
}
 204:	40a7853b          	subw	a0,a5,a0
 208:	60a2                	ld	ra,8(sp)
 20a:	6402                	ld	s0,0(sp)
 20c:	0141                	addi	sp,sp,16
 20e:	8082                	ret

0000000000000210 <strlen>:

uint
strlen(const char *s)
{
 210:	1141                	addi	sp,sp,-16
 212:	e406                	sd	ra,8(sp)
 214:	e022                	sd	s0,0(sp)
 216:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 218:	00054783          	lbu	a5,0(a0)
 21c:	cf91                	beqz	a5,238 <strlen+0x28>
 21e:	00150793          	addi	a5,a0,1
 222:	86be                	mv	a3,a5
 224:	0785                	addi	a5,a5,1
 226:	fff7c703          	lbu	a4,-1(a5)
 22a:	ff65                	bnez	a4,222 <strlen+0x12>
 22c:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 230:	60a2                	ld	ra,8(sp)
 232:	6402                	ld	s0,0(sp)
 234:	0141                	addi	sp,sp,16
 236:	8082                	ret
  for (n = 0; s[n]; n++)
 238:	4501                	li	a0,0
 23a:	bfdd                	j	230 <strlen+0x20>

000000000000023c <memset>:

void *
memset(void *dst, int c, uint n)
{
 23c:	1141                	addi	sp,sp,-16
 23e:	e406                	sd	ra,8(sp)
 240:	e022                	sd	s0,0(sp)
 242:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 244:	ca19                	beqz	a2,25a <memset+0x1e>
 246:	87aa                	mv	a5,a0
 248:	1602                	slli	a2,a2,0x20
 24a:	9201                	srli	a2,a2,0x20
 24c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 250:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 254:	0785                	addi	a5,a5,1
 256:	fee79de3          	bne	a5,a4,250 <memset+0x14>
  }
  return dst;
}
 25a:	60a2                	ld	ra,8(sp)
 25c:	6402                	ld	s0,0(sp)
 25e:	0141                	addi	sp,sp,16
 260:	8082                	ret

0000000000000262 <strchr>:

char *
strchr(const char *s, char c)
{
 262:	1141                	addi	sp,sp,-16
 264:	e406                	sd	ra,8(sp)
 266:	e022                	sd	s0,0(sp)
 268:	0800                	addi	s0,sp,16
  for (; *s; s++)
 26a:	00054783          	lbu	a5,0(a0)
 26e:	cf81                	beqz	a5,286 <strchr+0x24>
    if (*s == c)
 270:	00f58763          	beq	a1,a5,27e <strchr+0x1c>
  for (; *s; s++)
 274:	0505                	addi	a0,a0,1
 276:	00054783          	lbu	a5,0(a0)
 27a:	fbfd                	bnez	a5,270 <strchr+0xe>
      return (char *)s;
  return 0;
 27c:	4501                	li	a0,0
}
 27e:	60a2                	ld	ra,8(sp)
 280:	6402                	ld	s0,0(sp)
 282:	0141                	addi	sp,sp,16
 284:	8082                	ret
  return 0;
 286:	4501                	li	a0,0
 288:	bfdd                	j	27e <strchr+0x1c>

000000000000028a <gets>:

char *
gets(char *buf, int max)
{
 28a:	711d                	addi	sp,sp,-96
 28c:	ec86                	sd	ra,88(sp)
 28e:	e8a2                	sd	s0,80(sp)
 290:	e4a6                	sd	s1,72(sp)
 292:	e0ca                	sd	s2,64(sp)
 294:	fc4e                	sd	s3,56(sp)
 296:	f852                	sd	s4,48(sp)
 298:	f456                	sd	s5,40(sp)
 29a:	f05a                	sd	s6,32(sp)
 29c:	ec5e                	sd	s7,24(sp)
 29e:	e862                	sd	s8,16(sp)
 2a0:	1080                	addi	s0,sp,96
 2a2:	8baa                	mv	s7,a0
 2a4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 2a6:	892a                	mv	s2,a0
 2a8:	4481                	li	s1,0
    cc = read(0, &c, 1);
 2aa:	faf40b13          	addi	s6,s0,-81
 2ae:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 2b0:	8c26                	mv	s8,s1
 2b2:	0014899b          	addiw	s3,s1,1
 2b6:	84ce                	mv	s1,s3
 2b8:	0349d463          	bge	s3,s4,2e0 <gets+0x56>
    cc = read(0, &c, 1);
 2bc:	8656                	mv	a2,s5
 2be:	85da                	mv	a1,s6
 2c0:	4501                	li	a0,0
 2c2:	1bc000ef          	jal	47e <read>
    if (cc < 1)
 2c6:	00a05d63          	blez	a0,2e0 <gets+0x56>
      break;
    buf[i++] = c;
 2ca:	faf44783          	lbu	a5,-81(s0)
 2ce:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 2d2:	0905                	addi	s2,s2,1
 2d4:	ff678713          	addi	a4,a5,-10
 2d8:	c319                	beqz	a4,2de <gets+0x54>
 2da:	17cd                	addi	a5,a5,-13
 2dc:	fbf1                	bnez	a5,2b0 <gets+0x26>
    buf[i++] = c;
 2de:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 2e0:	9c5e                	add	s8,s8,s7
 2e2:	000c0023          	sb	zero,0(s8)
  return buf;
}
 2e6:	855e                	mv	a0,s7
 2e8:	60e6                	ld	ra,88(sp)
 2ea:	6446                	ld	s0,80(sp)
 2ec:	64a6                	ld	s1,72(sp)
 2ee:	6906                	ld	s2,64(sp)
 2f0:	79e2                	ld	s3,56(sp)
 2f2:	7a42                	ld	s4,48(sp)
 2f4:	7aa2                	ld	s5,40(sp)
 2f6:	7b02                	ld	s6,32(sp)
 2f8:	6be2                	ld	s7,24(sp)
 2fa:	6c42                	ld	s8,16(sp)
 2fc:	6125                	addi	sp,sp,96
 2fe:	8082                	ret

0000000000000300 <stat>:

int
stat(const char *n, struct stat *st)
{
 300:	1101                	addi	sp,sp,-32
 302:	ec06                	sd	ra,24(sp)
 304:	e822                	sd	s0,16(sp)
 306:	e04a                	sd	s2,0(sp)
 308:	1000                	addi	s0,sp,32
 30a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 30c:	4581                	li	a1,0
 30e:	198000ef          	jal	4a6 <open>
  if (fd < 0)
 312:	02054263          	bltz	a0,336 <stat+0x36>
 316:	e426                	sd	s1,8(sp)
 318:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 31a:	85ca                	mv	a1,s2
 31c:	1a2000ef          	jal	4be <fstat>
 320:	892a                	mv	s2,a0
  close(fd);
 322:	8526                	mv	a0,s1
 324:	16a000ef          	jal	48e <close>
  return r;
 328:	64a2                	ld	s1,8(sp)
}
 32a:	854a                	mv	a0,s2
 32c:	60e2                	ld	ra,24(sp)
 32e:	6442                	ld	s0,16(sp)
 330:	6902                	ld	s2,0(sp)
 332:	6105                	addi	sp,sp,32
 334:	8082                	ret
    return -1;
 336:	57fd                	li	a5,-1
 338:	893e                	mv	s2,a5
 33a:	bfc5                	j	32a <stat+0x2a>

000000000000033c <atoi>:

int
atoi(const char *s)
{
 33c:	1141                	addi	sp,sp,-16
 33e:	e406                	sd	ra,8(sp)
 340:	e022                	sd	s0,0(sp)
 342:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 344:	00054683          	lbu	a3,0(a0)
 348:	fd06879b          	addiw	a5,a3,-48
 34c:	0ff7f793          	zext.b	a5,a5
 350:	4625                	li	a2,9
 352:	02f66963          	bltu	a2,a5,384 <atoi+0x48>
 356:	872a                	mv	a4,a0
  n = 0;
 358:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 35a:	0705                	addi	a4,a4,1
 35c:	0025179b          	slliw	a5,a0,0x2
 360:	9fa9                	addw	a5,a5,a0
 362:	0017979b          	slliw	a5,a5,0x1
 366:	9fb5                	addw	a5,a5,a3
 368:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 36c:	00074683          	lbu	a3,0(a4)
 370:	fd06879b          	addiw	a5,a3,-48
 374:	0ff7f793          	zext.b	a5,a5
 378:	fef671e3          	bgeu	a2,a5,35a <atoi+0x1e>
  return n;
}
 37c:	60a2                	ld	ra,8(sp)
 37e:	6402                	ld	s0,0(sp)
 380:	0141                	addi	sp,sp,16
 382:	8082                	ret
  n = 0;
 384:	4501                	li	a0,0
 386:	bfdd                	j	37c <atoi+0x40>

0000000000000388 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 388:	1141                	addi	sp,sp,-16
 38a:	e406                	sd	ra,8(sp)
 38c:	e022                	sd	s0,0(sp)
 38e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 390:	02b57563          	bgeu	a0,a1,3ba <memmove+0x32>
    while (n-- > 0)
 394:	00c05f63          	blez	a2,3b2 <memmove+0x2a>
 398:	1602                	slli	a2,a2,0x20
 39a:	9201                	srli	a2,a2,0x20
 39c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3a0:	872a                	mv	a4,a0
      *dst++ = *src++;
 3a2:	0585                	addi	a1,a1,1
 3a4:	0705                	addi	a4,a4,1
 3a6:	fff5c683          	lbu	a3,-1(a1)
 3aa:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 3ae:	fee79ae3          	bne	a5,a4,3a2 <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3b2:	60a2                	ld	ra,8(sp)
 3b4:	6402                	ld	s0,0(sp)
 3b6:	0141                	addi	sp,sp,16
 3b8:	8082                	ret
    while (n-- > 0)
 3ba:	fec05ce3          	blez	a2,3b2 <memmove+0x2a>
    dst += n;
 3be:	00c50733          	add	a4,a0,a2
    src += n;
 3c2:	95b2                	add	a1,a1,a2
 3c4:	fff6079b          	addiw	a5,a2,-1
 3c8:	1782                	slli	a5,a5,0x20
 3ca:	9381                	srli	a5,a5,0x20
 3cc:	fff7c793          	not	a5,a5
 3d0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3d2:	15fd                	addi	a1,a1,-1
 3d4:	177d                	addi	a4,a4,-1
 3d6:	0005c683          	lbu	a3,0(a1)
 3da:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 3de:	fef71ae3          	bne	a4,a5,3d2 <memmove+0x4a>
 3e2:	bfc1                	j	3b2 <memmove+0x2a>

00000000000003e4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3e4:	1141                	addi	sp,sp,-16
 3e6:	e406                	sd	ra,8(sp)
 3e8:	e022                	sd	s0,0(sp)
 3ea:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3ec:	c61d                	beqz	a2,41a <memcmp+0x36>
 3ee:	1602                	slli	a2,a2,0x20
 3f0:	9201                	srli	a2,a2,0x20
 3f2:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 3f6:	00054783          	lbu	a5,0(a0)
 3fa:	0005c703          	lbu	a4,0(a1)
 3fe:	00e79863          	bne	a5,a4,40e <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 402:	0505                	addi	a0,a0,1
    p2++;
 404:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 406:	fed518e3          	bne	a0,a3,3f6 <memcmp+0x12>
  }
  return 0;
 40a:	4501                	li	a0,0
 40c:	a019                	j	412 <memcmp+0x2e>
      return *p1 - *p2;
 40e:	40e7853b          	subw	a0,a5,a4
}
 412:	60a2                	ld	ra,8(sp)
 414:	6402                	ld	s0,0(sp)
 416:	0141                	addi	sp,sp,16
 418:	8082                	ret
  return 0;
 41a:	4501                	li	a0,0
 41c:	bfdd                	j	412 <memcmp+0x2e>

000000000000041e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 41e:	1141                	addi	sp,sp,-16
 420:	e406                	sd	ra,8(sp)
 422:	e022                	sd	s0,0(sp)
 424:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 426:	f63ff0ef          	jal	388 <memmove>
}
 42a:	60a2                	ld	ra,8(sp)
 42c:	6402                	ld	s0,0(sp)
 42e:	0141                	addi	sp,sp,16
 430:	8082                	ret

0000000000000432 <sbrk>:

char *
sbrk(int n)
{
 432:	1141                	addi	sp,sp,-16
 434:	e406                	sd	ra,8(sp)
 436:	e022                	sd	s0,0(sp)
 438:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 43a:	4585                	li	a1,1
 43c:	0b2000ef          	jal	4ee <sys_sbrk>
}
 440:	60a2                	ld	ra,8(sp)
 442:	6402                	ld	s0,0(sp)
 444:	0141                	addi	sp,sp,16
 446:	8082                	ret

0000000000000448 <sbrklazy>:

char *
sbrklazy(int n)
{
 448:	1141                	addi	sp,sp,-16
 44a:	e406                	sd	ra,8(sp)
 44c:	e022                	sd	s0,0(sp)
 44e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 450:	4589                	li	a1,2
 452:	09c000ef          	jal	4ee <sys_sbrk>
}
 456:	60a2                	ld	ra,8(sp)
 458:	6402                	ld	s0,0(sp)
 45a:	0141                	addi	sp,sp,16
 45c:	8082                	ret

000000000000045e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 45e:	4885                	li	a7,1
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <exit>:
.global exit
exit:
 li a7, SYS_exit
 466:	4889                	li	a7,2
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <wait>:
.global wait
wait:
 li a7, SYS_wait
 46e:	488d                	li	a7,3
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 476:	4891                	li	a7,4
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <read>:
.global read
read:
 li a7, SYS_read
 47e:	4895                	li	a7,5
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <write>:
.global write
write:
 li a7, SYS_write
 486:	48c1                	li	a7,16
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <close>:
.global close
close:
 li a7, SYS_close
 48e:	48d5                	li	a7,21
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <kill>:
.global kill
kill:
 li a7, SYS_kill
 496:	4899                	li	a7,6
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <exec>:
.global exec
exec:
 li a7, SYS_exec
 49e:	489d                	li	a7,7
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <open>:
.global open
open:
 li a7, SYS_open
 4a6:	48bd                	li	a7,15
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4ae:	48c5                	li	a7,17
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4b6:	48c9                	li	a7,18
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4be:	48a1                	li	a7,8
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <link>:
.global link
link:
 li a7, SYS_link
 4c6:	48cd                	li	a7,19
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4ce:	48d1                	li	a7,20
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4d6:	48a5                	li	a7,9
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <dup>:
.global dup
dup:
 li a7, SYS_dup
 4de:	48a9                	li	a7,10
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4e6:	48ad                	li	a7,11
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4ee:	48b1                	li	a7,12
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <pause>:
.global pause
pause:
 li a7, SYS_pause
 4f6:	48b5                	li	a7,13
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4fe:	48b9                	li	a7,14
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <sync>:
.global sync
sync:
 li a7, SYS_sync
 506:	48d9                	li	a7,22
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <set_burst>:
.global set_burst
set_burst:
 li a7, SYS_set_burst
 50e:	48dd                	li	a7,23
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 516:	1101                	addi	sp,sp,-32
 518:	ec06                	sd	ra,24(sp)
 51a:	e822                	sd	s0,16(sp)
 51c:	1000                	addi	s0,sp,32
 51e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 522:	4605                	li	a2,1
 524:	fef40593          	addi	a1,s0,-17
 528:	f5fff0ef          	jal	486 <write>
}
 52c:	60e2                	ld	ra,24(sp)
 52e:	6442                	ld	s0,16(sp)
 530:	6105                	addi	sp,sp,32
 532:	8082                	ret

0000000000000534 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 534:	715d                	addi	sp,sp,-80
 536:	e486                	sd	ra,72(sp)
 538:	e0a2                	sd	s0,64(sp)
 53a:	f84a                	sd	s2,48(sp)
 53c:	f44e                	sd	s3,40(sp)
 53e:	0880                	addi	s0,sp,80
 540:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 542:	c6d1                	beqz	a3,5ce <printint+0x9a>
 544:	0805d563          	bgez	a1,5ce <printint+0x9a>
    neg = 1;
    x = -xx;
 548:	40b005b3          	neg	a1,a1
    neg = 1;
 54c:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 54e:	fb840993          	addi	s3,s0,-72
  neg = 0;
 552:	86ce                	mv	a3,s3
  i = 0;
 554:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 556:	00000817          	auipc	a6,0x0
 55a:	79a80813          	addi	a6,a6,1946 # cf0 <digits>
 55e:	88ba                	mv	a7,a4
 560:	0017051b          	addiw	a0,a4,1
 564:	872a                	mv	a4,a0
 566:	02c5f7b3          	remu	a5,a1,a2
 56a:	97c2                	add	a5,a5,a6
 56c:	0007c783          	lbu	a5,0(a5)
 570:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 574:	87ae                	mv	a5,a1
 576:	02c5d5b3          	divu	a1,a1,a2
 57a:	0685                	addi	a3,a3,1
 57c:	fec7f1e3          	bgeu	a5,a2,55e <printint+0x2a>
  if (neg)
 580:	00030c63          	beqz	t1,598 <printint+0x64>
    buf[i++] = '-';
 584:	fd050793          	addi	a5,a0,-48
 588:	00878533          	add	a0,a5,s0
 58c:	02d00793          	li	a5,45
 590:	fef50423          	sb	a5,-24(a0)
 594:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 598:	02e05563          	blez	a4,5c2 <printint+0x8e>
 59c:	fc26                	sd	s1,56(sp)
 59e:	377d                	addiw	a4,a4,-1
 5a0:	00e984b3          	add	s1,s3,a4
 5a4:	19fd                	addi	s3,s3,-1
 5a6:	99ba                	add	s3,s3,a4
 5a8:	1702                	slli	a4,a4,0x20
 5aa:	9301                	srli	a4,a4,0x20
 5ac:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5b0:	0004c583          	lbu	a1,0(s1)
 5b4:	854a                	mv	a0,s2
 5b6:	f61ff0ef          	jal	516 <putc>
  while (--i >= 0)
 5ba:	14fd                	addi	s1,s1,-1
 5bc:	ff349ae3          	bne	s1,s3,5b0 <printint+0x7c>
 5c0:	74e2                	ld	s1,56(sp)
}
 5c2:	60a6                	ld	ra,72(sp)
 5c4:	6406                	ld	s0,64(sp)
 5c6:	7942                	ld	s2,48(sp)
 5c8:	79a2                	ld	s3,40(sp)
 5ca:	6161                	addi	sp,sp,80
 5cc:	8082                	ret
  neg = 0;
 5ce:	4301                	li	t1,0
 5d0:	bfbd                	j	54e <printint+0x1a>

00000000000005d2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5d2:	711d                	addi	sp,sp,-96
 5d4:	ec86                	sd	ra,88(sp)
 5d6:	e8a2                	sd	s0,80(sp)
 5d8:	e4a6                	sd	s1,72(sp)
 5da:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 5dc:	0005c483          	lbu	s1,0(a1)
 5e0:	22048363          	beqz	s1,806 <vprintf+0x234>
 5e4:	e0ca                	sd	s2,64(sp)
 5e6:	fc4e                	sd	s3,56(sp)
 5e8:	f852                	sd	s4,48(sp)
 5ea:	f456                	sd	s5,40(sp)
 5ec:	f05a                	sd	s6,32(sp)
 5ee:	ec5e                	sd	s7,24(sp)
 5f0:	e862                	sd	s8,16(sp)
 5f2:	8b2a                	mv	s6,a0
 5f4:	8a2e                	mv	s4,a1
 5f6:	8bb2                	mv	s7,a2
  state = 0;
 5f8:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 5fa:	4901                	li	s2,0
 5fc:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 5fe:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 602:	06400c13          	li	s8,100
 606:	a00d                	j	628 <vprintf+0x56>
        putc(fd, c0);
 608:	85a6                	mv	a1,s1
 60a:	855a                	mv	a0,s6
 60c:	f0bff0ef          	jal	516 <putc>
 610:	a019                	j	616 <vprintf+0x44>
    } else if (state == '%') {
 612:	03598363          	beq	s3,s5,638 <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 616:	0019079b          	addiw	a5,s2,1
 61a:	893e                	mv	s2,a5
 61c:	873e                	mv	a4,a5
 61e:	97d2                	add	a5,a5,s4
 620:	0007c483          	lbu	s1,0(a5)
 624:	1c048a63          	beqz	s1,7f8 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 628:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 62c:	fe0993e3          	bnez	s3,612 <vprintf+0x40>
      if (c0 == '%') {
 630:	fd579ce3          	bne	a5,s5,608 <vprintf+0x36>
        state = '%';
 634:	89be                	mv	s3,a5
 636:	b7c5                	j	616 <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 638:	00ea06b3          	add	a3,s4,a4
 63c:	0016c603          	lbu	a2,1(a3)
      if (c1)
 640:	1c060863          	beqz	a2,810 <vprintf+0x23e>
      if (c0 == 'd') {
 644:	03878763          	beq	a5,s8,672 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 648:	f9478693          	addi	a3,a5,-108
 64c:	0016b693          	seqz	a3,a3
 650:	f9c60593          	addi	a1,a2,-100
 654:	e99d                	bnez	a1,68a <vprintf+0xb8>
 656:	ca95                	beqz	a3,68a <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 658:	008b8493          	addi	s1,s7,8
 65c:	4685                	li	a3,1
 65e:	4629                	li	a2,10
 660:	000bb583          	ld	a1,0(s7)
 664:	855a                	mv	a0,s6
 666:	ecfff0ef          	jal	534 <printint>
        i += 1;
 66a:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 66c:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 66e:	4981                	li	s3,0
 670:	b75d                	j	616 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 672:	008b8493          	addi	s1,s7,8
 676:	4685                	li	a3,1
 678:	4629                	li	a2,10
 67a:	000ba583          	lw	a1,0(s7)
 67e:	855a                	mv	a0,s6
 680:	eb5ff0ef          	jal	534 <printint>
 684:	8ba6                	mv	s7,s1
      state = 0;
 686:	4981                	li	s3,0
 688:	b779                	j	616 <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 68a:	9752                	add	a4,a4,s4
 68c:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 690:	f9460713          	addi	a4,a2,-108
 694:	00173713          	seqz	a4,a4
 698:	8f75                	and	a4,a4,a3
 69a:	f9c58513          	addi	a0,a1,-100
 69e:	18051363          	bnez	a0,824 <vprintf+0x252>
 6a2:	18070163          	beqz	a4,824 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a6:	008b8493          	addi	s1,s7,8
 6aa:	4685                	li	a3,1
 6ac:	4629                	li	a2,10
 6ae:	000bb583          	ld	a1,0(s7)
 6b2:	855a                	mv	a0,s6
 6b4:	e81ff0ef          	jal	534 <printint>
        i += 2;
 6b8:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ba:	8ba6                	mv	s7,s1
      state = 0;
 6bc:	4981                	li	s3,0
        i += 2;
 6be:	bfa1                	j	616 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6c0:	008b8493          	addi	s1,s7,8
 6c4:	4681                	li	a3,0
 6c6:	4629                	li	a2,10
 6c8:	000be583          	lwu	a1,0(s7)
 6cc:	855a                	mv	a0,s6
 6ce:	e67ff0ef          	jal	534 <printint>
 6d2:	8ba6                	mv	s7,s1
      state = 0;
 6d4:	4981                	li	s3,0
 6d6:	b781                	j	616 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d8:	008b8493          	addi	s1,s7,8
 6dc:	4681                	li	a3,0
 6de:	4629                	li	a2,10
 6e0:	000bb583          	ld	a1,0(s7)
 6e4:	855a                	mv	a0,s6
 6e6:	e4fff0ef          	jal	534 <printint>
        i += 1;
 6ea:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ec:	8ba6                	mv	s7,s1
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	b71d                	j	616 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f2:	008b8493          	addi	s1,s7,8
 6f6:	4681                	li	a3,0
 6f8:	4629                	li	a2,10
 6fa:	000bb583          	ld	a1,0(s7)
 6fe:	855a                	mv	a0,s6
 700:	e35ff0ef          	jal	534 <printint>
        i += 2;
 704:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 706:	8ba6                	mv	s7,s1
      state = 0;
 708:	4981                	li	s3,0
        i += 2;
 70a:	b731                	j	616 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 70c:	008b8493          	addi	s1,s7,8
 710:	4681                	li	a3,0
 712:	4641                	li	a2,16
 714:	000be583          	lwu	a1,0(s7)
 718:	855a                	mv	a0,s6
 71a:	e1bff0ef          	jal	534 <printint>
 71e:	8ba6                	mv	s7,s1
      state = 0;
 720:	4981                	li	s3,0
 722:	bdd5                	j	616 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 724:	008b8493          	addi	s1,s7,8
 728:	4681                	li	a3,0
 72a:	4641                	li	a2,16
 72c:	000bb583          	ld	a1,0(s7)
 730:	855a                	mv	a0,s6
 732:	e03ff0ef          	jal	534 <printint>
        i += 1;
 736:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 738:	8ba6                	mv	s7,s1
      state = 0;
 73a:	4981                	li	s3,0
 73c:	bde9                	j	616 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 73e:	008b8493          	addi	s1,s7,8
 742:	4681                	li	a3,0
 744:	4641                	li	a2,16
 746:	000bb583          	ld	a1,0(s7)
 74a:	855a                	mv	a0,s6
 74c:	de9ff0ef          	jal	534 <printint>
        i += 2;
 750:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 752:	8ba6                	mv	s7,s1
      state = 0;
 754:	4981                	li	s3,0
        i += 2;
 756:	b5c1                	j	616 <vprintf+0x44>
 758:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 75a:	008b8793          	addi	a5,s7,8
 75e:	8cbe                	mv	s9,a5
 760:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 764:	03000593          	li	a1,48
 768:	855a                	mv	a0,s6
 76a:	dadff0ef          	jal	516 <putc>
  putc(fd, 'x');
 76e:	07800593          	li	a1,120
 772:	855a                	mv	a0,s6
 774:	da3ff0ef          	jal	516 <putc>
 778:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 77a:	00000b97          	auipc	s7,0x0
 77e:	576b8b93          	addi	s7,s7,1398 # cf0 <digits>
 782:	03c9d793          	srli	a5,s3,0x3c
 786:	97de                	add	a5,a5,s7
 788:	0007c583          	lbu	a1,0(a5)
 78c:	855a                	mv	a0,s6
 78e:	d89ff0ef          	jal	516 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 792:	0992                	slli	s3,s3,0x4
 794:	34fd                	addiw	s1,s1,-1
 796:	f4f5                	bnez	s1,782 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 798:	8be6                	mv	s7,s9
      state = 0;
 79a:	4981                	li	s3,0
 79c:	6ca2                	ld	s9,8(sp)
 79e:	bda5                	j	616 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 7a0:	008b8493          	addi	s1,s7,8
 7a4:	000bc583          	lbu	a1,0(s7)
 7a8:	855a                	mv	a0,s6
 7aa:	d6dff0ef          	jal	516 <putc>
 7ae:	8ba6                	mv	s7,s1
      state = 0;
 7b0:	4981                	li	s3,0
 7b2:	b595                	j	616 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 7b4:	008b8993          	addi	s3,s7,8
 7b8:	000bb483          	ld	s1,0(s7)
 7bc:	cc91                	beqz	s1,7d8 <vprintf+0x206>
        for (; *s; s++)
 7be:	0004c583          	lbu	a1,0(s1)
 7c2:	c985                	beqz	a1,7f2 <vprintf+0x220>
          putc(fd, *s);
 7c4:	855a                	mv	a0,s6
 7c6:	d51ff0ef          	jal	516 <putc>
        for (; *s; s++)
 7ca:	0485                	addi	s1,s1,1
 7cc:	0004c583          	lbu	a1,0(s1)
 7d0:	f9f5                	bnez	a1,7c4 <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 7d2:	8bce                	mv	s7,s3
      state = 0;
 7d4:	4981                	li	s3,0
 7d6:	b581                	j	616 <vprintf+0x44>
          s = "(null)";
 7d8:	00000497          	auipc	s1,0x0
 7dc:	51048493          	addi	s1,s1,1296 # ce8 <malloc+0x374>
        for (; *s; s++)
 7e0:	02800593          	li	a1,40
 7e4:	b7c5                	j	7c4 <vprintf+0x1f2>
        putc(fd, '%');
 7e6:	85be                	mv	a1,a5
 7e8:	855a                	mv	a0,s6
 7ea:	d2dff0ef          	jal	516 <putc>
      state = 0;
 7ee:	4981                	li	s3,0
 7f0:	b51d                	j	616 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 7f2:	8bce                	mv	s7,s3
      state = 0;
 7f4:	4981                	li	s3,0
 7f6:	b505                	j	616 <vprintf+0x44>
 7f8:	6906                	ld	s2,64(sp)
 7fa:	79e2                	ld	s3,56(sp)
 7fc:	7a42                	ld	s4,48(sp)
 7fe:	7aa2                	ld	s5,40(sp)
 800:	7b02                	ld	s6,32(sp)
 802:	6be2                	ld	s7,24(sp)
 804:	6c42                	ld	s8,16(sp)
    }
  }
}
 806:	60e6                	ld	ra,88(sp)
 808:	6446                	ld	s0,80(sp)
 80a:	64a6                	ld	s1,72(sp)
 80c:	6125                	addi	sp,sp,96
 80e:	8082                	ret
      if (c0 == 'd') {
 810:	06400713          	li	a4,100
 814:	e4e78fe3          	beq	a5,a4,672 <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 818:	f9478693          	addi	a3,a5,-108
 81c:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 820:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 822:	4701                	li	a4,0
      } else if (c0 == 'u') {
 824:	07500513          	li	a0,117
 828:	e8a78ce3          	beq	a5,a0,6c0 <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 82c:	f8b60513          	addi	a0,a2,-117
 830:	e119                	bnez	a0,836 <vprintf+0x264>
 832:	ea0693e3          	bnez	a3,6d8 <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 836:	f8b58513          	addi	a0,a1,-117
 83a:	e119                	bnez	a0,840 <vprintf+0x26e>
 83c:	ea071be3          	bnez	a4,6f2 <vprintf+0x120>
      } else if (c0 == 'x') {
 840:	07800513          	li	a0,120
 844:	eca784e3          	beq	a5,a0,70c <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 848:	f8860613          	addi	a2,a2,-120
 84c:	e219                	bnez	a2,852 <vprintf+0x280>
 84e:	ec069be3          	bnez	a3,724 <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 852:	f8858593          	addi	a1,a1,-120
 856:	e199                	bnez	a1,85c <vprintf+0x28a>
 858:	ee0713e3          	bnez	a4,73e <vprintf+0x16c>
      } else if (c0 == 'p') {
 85c:	07000713          	li	a4,112
 860:	eee78ce3          	beq	a5,a4,758 <vprintf+0x186>
      } else if (c0 == 'c') {
 864:	06300713          	li	a4,99
 868:	f2e78ce3          	beq	a5,a4,7a0 <vprintf+0x1ce>
      } else if (c0 == 's') {
 86c:	07300713          	li	a4,115
 870:	f4e782e3          	beq	a5,a4,7b4 <vprintf+0x1e2>
      } else if (c0 == '%') {
 874:	02500713          	li	a4,37
 878:	f6e787e3          	beq	a5,a4,7e6 <vprintf+0x214>
        putc(fd, '%');
 87c:	02500593          	li	a1,37
 880:	855a                	mv	a0,s6
 882:	c95ff0ef          	jal	516 <putc>
        putc(fd, c0);
 886:	85a6                	mv	a1,s1
 888:	855a                	mv	a0,s6
 88a:	c8dff0ef          	jal	516 <putc>
      state = 0;
 88e:	4981                	li	s3,0
 890:	b359                	j	616 <vprintf+0x44>

0000000000000892 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 892:	715d                	addi	sp,sp,-80
 894:	ec06                	sd	ra,24(sp)
 896:	e822                	sd	s0,16(sp)
 898:	1000                	addi	s0,sp,32
 89a:	e010                	sd	a2,0(s0)
 89c:	e414                	sd	a3,8(s0)
 89e:	e818                	sd	a4,16(s0)
 8a0:	ec1c                	sd	a5,24(s0)
 8a2:	03043023          	sd	a6,32(s0)
 8a6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8aa:	8622                	mv	a2,s0
 8ac:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8b0:	d23ff0ef          	jal	5d2 <vprintf>
}
 8b4:	60e2                	ld	ra,24(sp)
 8b6:	6442                	ld	s0,16(sp)
 8b8:	6161                	addi	sp,sp,80
 8ba:	8082                	ret

00000000000008bc <printf>:

void
printf(const char *fmt, ...)
{
 8bc:	711d                	addi	sp,sp,-96
 8be:	ec06                	sd	ra,24(sp)
 8c0:	e822                	sd	s0,16(sp)
 8c2:	1000                	addi	s0,sp,32
 8c4:	e40c                	sd	a1,8(s0)
 8c6:	e810                	sd	a2,16(s0)
 8c8:	ec14                	sd	a3,24(s0)
 8ca:	f018                	sd	a4,32(s0)
 8cc:	f41c                	sd	a5,40(s0)
 8ce:	03043823          	sd	a6,48(s0)
 8d2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8d6:	00840613          	addi	a2,s0,8
 8da:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8de:	85aa                	mv	a1,a0
 8e0:	4505                	li	a0,1
 8e2:	cf1ff0ef          	jal	5d2 <vprintf>
}
 8e6:	60e2                	ld	ra,24(sp)
 8e8:	6442                	ld	s0,16(sp)
 8ea:	6125                	addi	sp,sp,96
 8ec:	8082                	ret

00000000000008ee <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8ee:	1141                	addi	sp,sp,-16
 8f0:	e406                	sd	ra,8(sp)
 8f2:	e022                	sd	s0,0(sp)
 8f4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 8f6:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8fa:	00001797          	auipc	a5,0x1
 8fe:	7067b783          	ld	a5,1798(a5) # 2000 <freep>
 902:	a039                	j	910 <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 904:	6398                	ld	a4,0(a5)
 906:	00e7e463          	bltu	a5,a4,90e <free+0x20>
 90a:	00e6ea63          	bltu	a3,a4,91e <free+0x30>
{
 90e:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 910:	fed7fae3          	bgeu	a5,a3,904 <free+0x16>
 914:	6398                	ld	a4,0(a5)
 916:	00e6e463          	bltu	a3,a4,91e <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 91a:	fee7eae3          	bltu	a5,a4,90e <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 91e:	ff852583          	lw	a1,-8(a0)
 922:	6390                	ld	a2,0(a5)
 924:	02059813          	slli	a6,a1,0x20
 928:	01c85713          	srli	a4,a6,0x1c
 92c:	9736                	add	a4,a4,a3
 92e:	02e60563          	beq	a2,a4,958 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 932:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 936:	4790                	lw	a2,8(a5)
 938:	02061593          	slli	a1,a2,0x20
 93c:	01c5d713          	srli	a4,a1,0x1c
 940:	973e                	add	a4,a4,a5
 942:	02e68263          	beq	a3,a4,966 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 946:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 948:	00001717          	auipc	a4,0x1
 94c:	6af73c23          	sd	a5,1720(a4) # 2000 <freep>
}
 950:	60a2                	ld	ra,8(sp)
 952:	6402                	ld	s0,0(sp)
 954:	0141                	addi	sp,sp,16
 956:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 958:	4618                	lw	a4,8(a2)
 95a:	9f2d                	addw	a4,a4,a1
 95c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 960:	6398                	ld	a4,0(a5)
 962:	6310                	ld	a2,0(a4)
 964:	b7f9                	j	932 <free+0x44>
    p->s.size += bp->s.size;
 966:	ff852703          	lw	a4,-8(a0)
 96a:	9f31                	addw	a4,a4,a2
 96c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 96e:	ff053683          	ld	a3,-16(a0)
 972:	bfd1                	j	946 <free+0x58>

0000000000000974 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 974:	7139                	addi	sp,sp,-64
 976:	fc06                	sd	ra,56(sp)
 978:	f822                	sd	s0,48(sp)
 97a:	f04a                	sd	s2,32(sp)
 97c:	ec4e                	sd	s3,24(sp)
 97e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 980:	02051993          	slli	s3,a0,0x20
 984:	0209d993          	srli	s3,s3,0x20
 988:	09bd                	addi	s3,s3,15
 98a:	0049d993          	srli	s3,s3,0x4
 98e:	2985                	addiw	s3,s3,1
 990:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 992:	00001517          	auipc	a0,0x1
 996:	66e53503          	ld	a0,1646(a0) # 2000 <freep>
 99a:	c905                	beqz	a0,9ca <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 99c:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 99e:	4798                	lw	a4,8(a5)
 9a0:	09377663          	bgeu	a4,s3,a2c <malloc+0xb8>
 9a4:	f426                	sd	s1,40(sp)
 9a6:	e852                	sd	s4,16(sp)
 9a8:	e456                	sd	s5,8(sp)
 9aa:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 9ac:	8a4e                	mv	s4,s3
 9ae:	6705                	lui	a4,0x1
 9b0:	00e9f363          	bgeu	s3,a4,9b6 <malloc+0x42>
 9b4:	6a05                	lui	s4,0x1
 9b6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9ba:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 9be:	00001497          	auipc	s1,0x1
 9c2:	64248493          	addi	s1,s1,1602 # 2000 <freep>
  if (p == SBRK_ERROR)
 9c6:	5afd                	li	s5,-1
 9c8:	a83d                	j	a06 <malloc+0x92>
 9ca:	f426                	sd	s1,40(sp)
 9cc:	e852                	sd	s4,16(sp)
 9ce:	e456                	sd	s5,8(sp)
 9d0:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9d2:	00001797          	auipc	a5,0x1
 9d6:	63e78793          	addi	a5,a5,1598 # 2010 <base>
 9da:	00001717          	auipc	a4,0x1
 9de:	62f73323          	sd	a5,1574(a4) # 2000 <freep>
 9e2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9e4:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 9e8:	b7d1                	j	9ac <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 9ea:	6398                	ld	a4,0(a5)
 9ec:	e118                	sd	a4,0(a0)
 9ee:	a899                	j	a44 <malloc+0xd0>
  hp->s.size = nu;
 9f0:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 9f4:	0541                	addi	a0,a0,16
 9f6:	ef9ff0ef          	jal	8ee <free>
  return freep;
 9fa:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 9fc:	c125                	beqz	a0,a5c <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 9fe:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 a00:	4798                	lw	a4,8(a5)
 a02:	03277163          	bgeu	a4,s2,a24 <malloc+0xb0>
    if (p == freep)
 a06:	6098                	ld	a4,0(s1)
 a08:	853e                	mv	a0,a5
 a0a:	fef71ae3          	bne	a4,a5,9fe <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 a0e:	8552                	mv	a0,s4
 a10:	a23ff0ef          	jal	432 <sbrk>
  if (p == SBRK_ERROR)
 a14:	fd551ee3          	bne	a0,s5,9f0 <malloc+0x7c>
        return 0;
 a18:	4501                	li	a0,0
 a1a:	74a2                	ld	s1,40(sp)
 a1c:	6a42                	ld	s4,16(sp)
 a1e:	6aa2                	ld	s5,8(sp)
 a20:	6b02                	ld	s6,0(sp)
 a22:	a03d                	j	a50 <malloc+0xdc>
 a24:	74a2                	ld	s1,40(sp)
 a26:	6a42                	ld	s4,16(sp)
 a28:	6aa2                	ld	s5,8(sp)
 a2a:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 a2c:	fae90fe3          	beq	s2,a4,9ea <malloc+0x76>
        p->s.size -= nunits;
 a30:	4137073b          	subw	a4,a4,s3
 a34:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a36:	02071693          	slli	a3,a4,0x20
 a3a:	01c6d713          	srli	a4,a3,0x1c
 a3e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a40:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a44:	00001717          	auipc	a4,0x1
 a48:	5aa73e23          	sd	a0,1468(a4) # 2000 <freep>
      return (void *)(p + 1);
 a4c:	01078513          	addi	a0,a5,16
  }
}
 a50:	70e2                	ld	ra,56(sp)
 a52:	7442                	ld	s0,48(sp)
 a54:	7902                	ld	s2,32(sp)
 a56:	69e2                	ld	s3,24(sp)
 a58:	6121                	addi	sp,sp,64
 a5a:	8082                	ret
 a5c:	74a2                	ld	s1,40(sp)
 a5e:	6a42                	ld	s4,16(sp)
 a60:	6aa2                	ld	s5,8(sp)
 a62:	6b02                	ld	s6,0(sp)
 a64:	b7f5                	j	a50 <malloc+0xdc>
