
user/_priotest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"

#define NUM_CHILDREN 4
#define WORKLOAD 40000000ULL

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
  int priorities[NUM_CHILDREN] = {5, 8, 12, 20}; // 1 = highest, 20 = lowest
  18:	4795                	li	a5,5
  1a:	f8f42823          	sw	a5,-112(s0)
  1e:	47a1                	li	a5,8
  20:	f8f42a23          	sw	a5,-108(s0)
  24:	47b1                	li	a5,12
  26:	f8f42c23          	sw	a5,-104(s0)
  2a:	47d1                	li	a5,20
  2c:	f8f42e23          	sw	a5,-100(s0)

  printf("--- Priority Preemptive Scheduler with Aging Test ---\n");
  30:	00001517          	auipc	a0,0x1
  34:	a7050513          	addi	a0,a0,-1424 # aa0 <malloc+0x100>
  38:	0b1000ef          	jal	8e8 <printf>
  printf("Parent PID: %d\n", getpid());
  3c:	4d6000ef          	jal	512 <getpid>
  40:	85aa                	mv	a1,a0
  42:	00001517          	auipc	a0,0x1
  46:	a9e50513          	addi	a0,a0,-1378 # ae0 <malloc+0x140>
  4a:	09f000ef          	jal	8e8 <printf>
  printf("Forking %d processes with priorities (5=High, 8=Med-High, 12=Med-Low, 20=Lowest)...\n\n", NUM_CHILDREN);
  4e:	4591                	li	a1,4
  50:	00001517          	auipc	a0,0x1
  54:	aa050513          	addi	a0,a0,-1376 # af0 <malloc+0x150>
  58:	091000ef          	jal	8e8 <printf>

  for (int i = 0; i < NUM_CHILDREN; i++) {
  5c:	f9040a93          	addi	s5,s0,-112
  60:	fa040a13          	addi	s4,s0,-96
  printf("Forking %d processes with priorities (5=High, 8=Med-High, 12=Med-Low, 20=Lowest)...\n\n", NUM_CHILDREN);
  64:	89d2                	mv	s3,s4
  for (int i = 0; i < NUM_CHILDREN; i++) {
  66:	4901                	li	s2,0
      exit(0);
    } else {
      // Parent sets priority immediately
      set_priority(pid, priorities[i]);
      pids[i] = pid;
      printf("[Parent] Forked Child %d (PID %d) assigned Priority %d\n", i + 1, pid, priorities[i]);
  68:	00001c17          	auipc	s8,0x1
  6c:	bd0c0c13          	addi	s8,s8,-1072 # c38 <malloc+0x298>
  for (int i = 0; i < NUM_CHILDREN; i++) {
  70:	4b91                	li	s7,4
    int pid = fork();
  72:	418000ef          	jal	48a <fork>
  76:	84aa                	mv	s1,a0
    if (pid < 0) {
  78:	08054363          	bltz	a0,fe <main+0xfe>
    if (pid == 0) {
  7c:	c951                	beqz	a0,110 <main+0x110>
      set_priority(pid, priorities[i]);
  7e:	000aab03          	lw	s6,0(s5)
  82:	85da                	mv	a1,s6
  84:	4b6000ef          	jal	53a <set_priority>
      pids[i] = pid;
  88:	0099a023          	sw	s1,0(s3)
      printf("[Parent] Forked Child %d (PID %d) assigned Priority %d\n", i + 1, pid, priorities[i]);
  8c:	0019059b          	addiw	a1,s2,1
  90:	892e                	mv	s2,a1
  92:	86da                	mv	a3,s6
  94:	8626                	mv	a2,s1
  96:	8562                	mv	a0,s8
  98:	051000ef          	jal	8e8 <printf>
  for (int i = 0; i < NUM_CHILDREN; i++) {
  9c:	0a91                	addi	s5,s5,4
  9e:	0991                	addi	s3,s3,4
  a0:	fd7919e3          	bne	s2,s7,72 <main+0x72>
    }
  }

  printf("\n[Parent] All children running. Waiting for completion...\n\n");
  a4:	00001517          	auipc	a0,0x1
  a8:	bcc50513          	addi	a0,a0,-1076 # c70 <malloc+0x2d0>
  ac:	03d000ef          	jal	8e8 <printf>

  for (int order = 1; order <= NUM_CHILDREN; order++) {
  b0:	4485                	li	s1,1
    int finished_pid = wait(0);
    int child_idx = -1;
    int init_prio = -1;
    for (int i = 0; i < NUM_CHILDREN; i++) {
  b2:	4911                	li	s2,4
    int init_prio = -1;
  b4:	59fd                	li	s3,-1
        child_idx = i + 1;
        init_prio = priorities[i];
        break;
      }
    }
    printf(">> Completion Order %d: PID %d (Child %d, Initial Priority %d)\n",
  b6:	00001b17          	auipc	s6,0x1
  ba:	bfab0b13          	addi	s6,s6,-1030 # cb0 <malloc+0x310>
  for (int order = 1; order <= NUM_CHILDREN; order++) {
  be:	4a95                	li	s5,5
    int finished_pid = wait(0);
  c0:	4501                	li	a0,0
  c2:	3d8000ef          	jal	49a <wait>
  c6:	862a                	mv	a2,a0
  c8:	8752                	mv	a4,s4
    for (int i = 0; i < NUM_CHILDREN; i++) {
  ca:	4781                	li	a5,0
      if (pids[i] == finished_pid) {
  cc:	4314                	lw	a3,0(a4)
  ce:	0ec68e63          	beq	a3,a2,1ca <main+0x1ca>
    for (int i = 0; i < NUM_CHILDREN; i++) {
  d2:	2785                	addiw	a5,a5,1
  d4:	0711                	addi	a4,a4,4
  d6:	ff279be3          	bne	a5,s2,cc <main+0xcc>
    int init_prio = -1;
  da:	874e                	mv	a4,s3
    int child_idx = -1;
  dc:	86ce                	mv	a3,s3
    printf(">> Completion Order %d: PID %d (Child %d, Initial Priority %d)\n",
  de:	85a6                	mv	a1,s1
  e0:	855a                	mv	a0,s6
  e2:	007000ef          	jal	8e8 <printf>
  for (int order = 1; order <= NUM_CHILDREN; order++) {
  e6:	2485                	addiw	s1,s1,1
  e8:	fd549ce3          	bne	s1,s5,c0 <main+0xc0>
           order, finished_pid, child_idx, init_prio);
  }

  printf("\n--- Priority Test Passed: High priority completed first; low priority ran via aging! ---\n");
  ec:	00001517          	auipc	a0,0x1
  f0:	c0450513          	addi	a0,a0,-1020 # cf0 <malloc+0x350>
  f4:	7f4000ef          	jal	8e8 <printf>
  exit(0);
  f8:	4501                	li	a0,0
  fa:	398000ef          	jal	492 <exit>
      printf("Fork failed!\n");
  fe:	00001517          	auipc	a0,0x1
 102:	a4a50513          	addi	a0,a0,-1462 # b48 <malloc+0x1a8>
 106:	7e2000ef          	jal	8e8 <printf>
      exit(1);
 10a:	4505                	li	a0,1
 10c:	386000ef          	jal	492 <exit>
      int my_pid = getpid();
 110:	402000ef          	jal	512 <getpid>
 114:	8a2a                	mv	s4,a0
      set_priority(my_pid, priorities[i]);
 116:	00291793          	slli	a5,s2,0x2
 11a:	fb078793          	addi	a5,a5,-80
 11e:	97a2                	add	a5,a5,s0
 120:	fe07aa83          	lw	s5,-32(a5)
 124:	85d6                	mv	a1,s5
 126:	414000ef          	jal	53a <set_priority>
      printf("[Child %d | PID %d] Started with Priority %d (uptime: %d ticks)\n",
 12a:	2905                	addiw	s2,s2,1
 12c:	3fe000ef          	jal	52a <uptime>
 130:	872a                	mv	a4,a0
 132:	86d6                	mv	a3,s5
 134:	8652                	mv	a2,s4
 136:	85ca                	mv	a1,s2
 138:	00001517          	auipc	a0,0x1
 13c:	a2050513          	addi	a0,a0,-1504 # b58 <malloc+0x1b8>
 140:	7a8000ef          	jal	8e8 <printf>
      volatile uint64 counter = 0;
 144:	f8043023          	sd	zero,-128(s0)
      for (volatile uint64 j = 0; j < WORKLOAD; j++) {
 148:	f8043423          	sd	zero,-120(s0)
 14c:	f8843703          	ld	a4,-120(s0)
 150:	026267b7          	lui	a5,0x2626
 154:	9ff78793          	addi	a5,a5,-1537 # 26259ff <base+0x26239ef>
 158:	04e7ea63          	bltu	a5,a4,1ac <main+0x1ac>
        if (j == WORKLOAD / 2) {
 15c:	013139b7          	lui	s3,0x1313
 160:	d0098993          	addi	s3,s3,-768 # 1312d00 <base+0x1310cf0>
          printf("[Child %d | PID %d | InitPrio %d] Reached 50%% progress (uptime: %d ticks)\n",
 164:	00001b17          	auipc	s6,0x1
 168:	a3cb0b13          	addi	s6,s6,-1476 # ba0 <malloc+0x200>
      for (volatile uint64 j = 0; j < WORKLOAD; j++) {
 16c:	84be                	mv	s1,a5
 16e:	a811                	j	182 <main+0x182>
 170:	f8843783          	ld	a5,-120(s0)
 174:	0785                	addi	a5,a5,1
 176:	f8f43423          	sd	a5,-120(s0)
 17a:	f8843783          	ld	a5,-120(s0)
 17e:	02f4e763          	bltu	s1,a5,1ac <main+0x1ac>
        counter += j;
 182:	f8843703          	ld	a4,-120(s0)
 186:	f8043783          	ld	a5,-128(s0)
 18a:	97ba                	add	a5,a5,a4
 18c:	f8f43023          	sd	a5,-128(s0)
        if (j == WORKLOAD / 2) {
 190:	f8843783          	ld	a5,-120(s0)
 194:	fd379ee3          	bne	a5,s3,170 <main+0x170>
          printf("[Child %d | PID %d | InitPrio %d] Reached 50%% progress (uptime: %d ticks)\n",
 198:	392000ef          	jal	52a <uptime>
 19c:	872a                	mv	a4,a0
 19e:	86d6                	mv	a3,s5
 1a0:	8652                	mv	a2,s4
 1a2:	85ca                	mv	a1,s2
 1a4:	855a                	mv	a0,s6
 1a6:	742000ef          	jal	8e8 <printf>
 1aa:	b7d9                	j	170 <main+0x170>
      printf("[Child %d | PID %d | InitPrio %d] Completed workload at tick %d\n",
 1ac:	37e000ef          	jal	52a <uptime>
 1b0:	872a                	mv	a4,a0
 1b2:	86d6                	mv	a3,s5
 1b4:	8652                	mv	a2,s4
 1b6:	85ca                	mv	a1,s2
 1b8:	00001517          	auipc	a0,0x1
 1bc:	a3850513          	addi	a0,a0,-1480 # bf0 <malloc+0x250>
 1c0:	728000ef          	jal	8e8 <printf>
      exit(0);
 1c4:	4501                	li	a0,0
 1c6:	2cc000ef          	jal	492 <exit>
        child_idx = i + 1;
 1ca:	0017869b          	addiw	a3,a5,1
        init_prio = priorities[i];
 1ce:	078a                	slli	a5,a5,0x2
 1d0:	fb078793          	addi	a5,a5,-80
 1d4:	97a2                	add	a5,a5,s0
 1d6:	fe07a703          	lw	a4,-32(a5)
        break;
 1da:	b711                	j	de <main+0xde>

00000000000001dc <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1dc:	1141                	addi	sp,sp,-16
 1de:	e406                	sd	ra,8(sp)
 1e0:	e022                	sd	s0,0(sp)
 1e2:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1e4:	e1dff0ef          	jal	0 <main>
  exit(r);
 1e8:	2aa000ef          	jal	492 <exit>

00000000000001ec <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 1ec:	1141                	addi	sp,sp,-16
 1ee:	e406                	sd	ra,8(sp)
 1f0:	e022                	sd	s0,0(sp)
 1f2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 1f4:	87aa                	mv	a5,a0
 1f6:	0585                	addi	a1,a1,1
 1f8:	0785                	addi	a5,a5,1
 1fa:	fff5c703          	lbu	a4,-1(a1)
 1fe:	fee78fa3          	sb	a4,-1(a5)
 202:	fb75                	bnez	a4,1f6 <strcpy+0xa>
    ;
  return os;
}
 204:	60a2                	ld	ra,8(sp)
 206:	6402                	ld	s0,0(sp)
 208:	0141                	addi	sp,sp,16
 20a:	8082                	ret

000000000000020c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 20c:	1141                	addi	sp,sp,-16
 20e:	e406                	sd	ra,8(sp)
 210:	e022                	sd	s0,0(sp)
 212:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 214:	00054783          	lbu	a5,0(a0)
 218:	cb91                	beqz	a5,22c <strcmp+0x20>
 21a:	0005c703          	lbu	a4,0(a1)
 21e:	00f71763          	bne	a4,a5,22c <strcmp+0x20>
    p++, q++;
 222:	0505                	addi	a0,a0,1
 224:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 226:	00054783          	lbu	a5,0(a0)
 22a:	fbe5                	bnez	a5,21a <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 22c:	0005c503          	lbu	a0,0(a1)
}
 230:	40a7853b          	subw	a0,a5,a0
 234:	60a2                	ld	ra,8(sp)
 236:	6402                	ld	s0,0(sp)
 238:	0141                	addi	sp,sp,16
 23a:	8082                	ret

000000000000023c <strlen>:

uint
strlen(const char *s)
{
 23c:	1141                	addi	sp,sp,-16
 23e:	e406                	sd	ra,8(sp)
 240:	e022                	sd	s0,0(sp)
 242:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 244:	00054783          	lbu	a5,0(a0)
 248:	cf91                	beqz	a5,264 <strlen+0x28>
 24a:	00150793          	addi	a5,a0,1
 24e:	86be                	mv	a3,a5
 250:	0785                	addi	a5,a5,1
 252:	fff7c703          	lbu	a4,-1(a5)
 256:	ff65                	bnez	a4,24e <strlen+0x12>
 258:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 25c:	60a2                	ld	ra,8(sp)
 25e:	6402                	ld	s0,0(sp)
 260:	0141                	addi	sp,sp,16
 262:	8082                	ret
  for (n = 0; s[n]; n++)
 264:	4501                	li	a0,0
 266:	bfdd                	j	25c <strlen+0x20>

0000000000000268 <memset>:

void *
memset(void *dst, int c, uint n)
{
 268:	1141                	addi	sp,sp,-16
 26a:	e406                	sd	ra,8(sp)
 26c:	e022                	sd	s0,0(sp)
 26e:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 270:	ca19                	beqz	a2,286 <memset+0x1e>
 272:	87aa                	mv	a5,a0
 274:	1602                	slli	a2,a2,0x20
 276:	9201                	srli	a2,a2,0x20
 278:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 27c:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 280:	0785                	addi	a5,a5,1
 282:	fee79de3          	bne	a5,a4,27c <memset+0x14>
  }
  return dst;
}
 286:	60a2                	ld	ra,8(sp)
 288:	6402                	ld	s0,0(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret

000000000000028e <strchr>:

char *
strchr(const char *s, char c)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e406                	sd	ra,8(sp)
 292:	e022                	sd	s0,0(sp)
 294:	0800                	addi	s0,sp,16
  for (; *s; s++)
 296:	00054783          	lbu	a5,0(a0)
 29a:	cf81                	beqz	a5,2b2 <strchr+0x24>
    if (*s == c)
 29c:	00f58763          	beq	a1,a5,2aa <strchr+0x1c>
  for (; *s; s++)
 2a0:	0505                	addi	a0,a0,1
 2a2:	00054783          	lbu	a5,0(a0)
 2a6:	fbfd                	bnez	a5,29c <strchr+0xe>
      return (char *)s;
  return 0;
 2a8:	4501                	li	a0,0
}
 2aa:	60a2                	ld	ra,8(sp)
 2ac:	6402                	ld	s0,0(sp)
 2ae:	0141                	addi	sp,sp,16
 2b0:	8082                	ret
  return 0;
 2b2:	4501                	li	a0,0
 2b4:	bfdd                	j	2aa <strchr+0x1c>

00000000000002b6 <gets>:

char *
gets(char *buf, int max)
{
 2b6:	711d                	addi	sp,sp,-96
 2b8:	ec86                	sd	ra,88(sp)
 2ba:	e8a2                	sd	s0,80(sp)
 2bc:	e4a6                	sd	s1,72(sp)
 2be:	e0ca                	sd	s2,64(sp)
 2c0:	fc4e                	sd	s3,56(sp)
 2c2:	f852                	sd	s4,48(sp)
 2c4:	f456                	sd	s5,40(sp)
 2c6:	f05a                	sd	s6,32(sp)
 2c8:	ec5e                	sd	s7,24(sp)
 2ca:	e862                	sd	s8,16(sp)
 2cc:	1080                	addi	s0,sp,96
 2ce:	8baa                	mv	s7,a0
 2d0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 2d2:	892a                	mv	s2,a0
 2d4:	4481                	li	s1,0
    cc = read(0, &c, 1);
 2d6:	faf40b13          	addi	s6,s0,-81
 2da:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 2dc:	8c26                	mv	s8,s1
 2de:	0014899b          	addiw	s3,s1,1
 2e2:	84ce                	mv	s1,s3
 2e4:	0349d463          	bge	s3,s4,30c <gets+0x56>
    cc = read(0, &c, 1);
 2e8:	8656                	mv	a2,s5
 2ea:	85da                	mv	a1,s6
 2ec:	4501                	li	a0,0
 2ee:	1bc000ef          	jal	4aa <read>
    if (cc < 1)
 2f2:	00a05d63          	blez	a0,30c <gets+0x56>
      break;
    buf[i++] = c;
 2f6:	faf44783          	lbu	a5,-81(s0)
 2fa:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 2fe:	0905                	addi	s2,s2,1
 300:	ff678713          	addi	a4,a5,-10
 304:	c319                	beqz	a4,30a <gets+0x54>
 306:	17cd                	addi	a5,a5,-13
 308:	fbf1                	bnez	a5,2dc <gets+0x26>
    buf[i++] = c;
 30a:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 30c:	9c5e                	add	s8,s8,s7
 30e:	000c0023          	sb	zero,0(s8)
  return buf;
}
 312:	855e                	mv	a0,s7
 314:	60e6                	ld	ra,88(sp)
 316:	6446                	ld	s0,80(sp)
 318:	64a6                	ld	s1,72(sp)
 31a:	6906                	ld	s2,64(sp)
 31c:	79e2                	ld	s3,56(sp)
 31e:	7a42                	ld	s4,48(sp)
 320:	7aa2                	ld	s5,40(sp)
 322:	7b02                	ld	s6,32(sp)
 324:	6be2                	ld	s7,24(sp)
 326:	6c42                	ld	s8,16(sp)
 328:	6125                	addi	sp,sp,96
 32a:	8082                	ret

000000000000032c <stat>:

int
stat(const char *n, struct stat *st)
{
 32c:	1101                	addi	sp,sp,-32
 32e:	ec06                	sd	ra,24(sp)
 330:	e822                	sd	s0,16(sp)
 332:	e04a                	sd	s2,0(sp)
 334:	1000                	addi	s0,sp,32
 336:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 338:	4581                	li	a1,0
 33a:	198000ef          	jal	4d2 <open>
  if (fd < 0)
 33e:	02054263          	bltz	a0,362 <stat+0x36>
 342:	e426                	sd	s1,8(sp)
 344:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 346:	85ca                	mv	a1,s2
 348:	1a2000ef          	jal	4ea <fstat>
 34c:	892a                	mv	s2,a0
  close(fd);
 34e:	8526                	mv	a0,s1
 350:	16a000ef          	jal	4ba <close>
  return r;
 354:	64a2                	ld	s1,8(sp)
}
 356:	854a                	mv	a0,s2
 358:	60e2                	ld	ra,24(sp)
 35a:	6442                	ld	s0,16(sp)
 35c:	6902                	ld	s2,0(sp)
 35e:	6105                	addi	sp,sp,32
 360:	8082                	ret
    return -1;
 362:	57fd                	li	a5,-1
 364:	893e                	mv	s2,a5
 366:	bfc5                	j	356 <stat+0x2a>

0000000000000368 <atoi>:

int
atoi(const char *s)
{
 368:	1141                	addi	sp,sp,-16
 36a:	e406                	sd	ra,8(sp)
 36c:	e022                	sd	s0,0(sp)
 36e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 370:	00054683          	lbu	a3,0(a0)
 374:	fd06879b          	addiw	a5,a3,-48
 378:	0ff7f793          	zext.b	a5,a5
 37c:	4625                	li	a2,9
 37e:	02f66963          	bltu	a2,a5,3b0 <atoi+0x48>
 382:	872a                	mv	a4,a0
  n = 0;
 384:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 386:	0705                	addi	a4,a4,1
 388:	0025179b          	slliw	a5,a0,0x2
 38c:	9fa9                	addw	a5,a5,a0
 38e:	0017979b          	slliw	a5,a5,0x1
 392:	9fb5                	addw	a5,a5,a3
 394:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 398:	00074683          	lbu	a3,0(a4)
 39c:	fd06879b          	addiw	a5,a3,-48
 3a0:	0ff7f793          	zext.b	a5,a5
 3a4:	fef671e3          	bgeu	a2,a5,386 <atoi+0x1e>
  return n;
}
 3a8:	60a2                	ld	ra,8(sp)
 3aa:	6402                	ld	s0,0(sp)
 3ac:	0141                	addi	sp,sp,16
 3ae:	8082                	ret
  n = 0;
 3b0:	4501                	li	a0,0
 3b2:	bfdd                	j	3a8 <atoi+0x40>

00000000000003b4 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 3b4:	1141                	addi	sp,sp,-16
 3b6:	e406                	sd	ra,8(sp)
 3b8:	e022                	sd	s0,0(sp)
 3ba:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3bc:	02b57563          	bgeu	a0,a1,3e6 <memmove+0x32>
    while (n-- > 0)
 3c0:	00c05f63          	blez	a2,3de <memmove+0x2a>
 3c4:	1602                	slli	a2,a2,0x20
 3c6:	9201                	srli	a2,a2,0x20
 3c8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3cc:	872a                	mv	a4,a0
      *dst++ = *src++;
 3ce:	0585                	addi	a1,a1,1
 3d0:	0705                	addi	a4,a4,1
 3d2:	fff5c683          	lbu	a3,-1(a1)
 3d6:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 3da:	fee79ae3          	bne	a5,a4,3ce <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3de:	60a2                	ld	ra,8(sp)
 3e0:	6402                	ld	s0,0(sp)
 3e2:	0141                	addi	sp,sp,16
 3e4:	8082                	ret
    while (n-- > 0)
 3e6:	fec05ce3          	blez	a2,3de <memmove+0x2a>
    dst += n;
 3ea:	00c50733          	add	a4,a0,a2
    src += n;
 3ee:	95b2                	add	a1,a1,a2
 3f0:	fff6079b          	addiw	a5,a2,-1
 3f4:	1782                	slli	a5,a5,0x20
 3f6:	9381                	srli	a5,a5,0x20
 3f8:	fff7c793          	not	a5,a5
 3fc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3fe:	15fd                	addi	a1,a1,-1
 400:	177d                	addi	a4,a4,-1
 402:	0005c683          	lbu	a3,0(a1)
 406:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 40a:	fef71ae3          	bne	a4,a5,3fe <memmove+0x4a>
 40e:	bfc1                	j	3de <memmove+0x2a>

0000000000000410 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 410:	1141                	addi	sp,sp,-16
 412:	e406                	sd	ra,8(sp)
 414:	e022                	sd	s0,0(sp)
 416:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 418:	c61d                	beqz	a2,446 <memcmp+0x36>
 41a:	1602                	slli	a2,a2,0x20
 41c:	9201                	srli	a2,a2,0x20
 41e:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 422:	00054783          	lbu	a5,0(a0)
 426:	0005c703          	lbu	a4,0(a1)
 42a:	00e79863          	bne	a5,a4,43a <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 42e:	0505                	addi	a0,a0,1
    p2++;
 430:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 432:	fed518e3          	bne	a0,a3,422 <memcmp+0x12>
  }
  return 0;
 436:	4501                	li	a0,0
 438:	a019                	j	43e <memcmp+0x2e>
      return *p1 - *p2;
 43a:	40e7853b          	subw	a0,a5,a4
}
 43e:	60a2                	ld	ra,8(sp)
 440:	6402                	ld	s0,0(sp)
 442:	0141                	addi	sp,sp,16
 444:	8082                	ret
  return 0;
 446:	4501                	li	a0,0
 448:	bfdd                	j	43e <memcmp+0x2e>

000000000000044a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 44a:	1141                	addi	sp,sp,-16
 44c:	e406                	sd	ra,8(sp)
 44e:	e022                	sd	s0,0(sp)
 450:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 452:	f63ff0ef          	jal	3b4 <memmove>
}
 456:	60a2                	ld	ra,8(sp)
 458:	6402                	ld	s0,0(sp)
 45a:	0141                	addi	sp,sp,16
 45c:	8082                	ret

000000000000045e <sbrk>:

char *
sbrk(int n)
{
 45e:	1141                	addi	sp,sp,-16
 460:	e406                	sd	ra,8(sp)
 462:	e022                	sd	s0,0(sp)
 464:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 466:	4585                	li	a1,1
 468:	0b2000ef          	jal	51a <sys_sbrk>
}
 46c:	60a2                	ld	ra,8(sp)
 46e:	6402                	ld	s0,0(sp)
 470:	0141                	addi	sp,sp,16
 472:	8082                	ret

0000000000000474 <sbrklazy>:

char *
sbrklazy(int n)
{
 474:	1141                	addi	sp,sp,-16
 476:	e406                	sd	ra,8(sp)
 478:	e022                	sd	s0,0(sp)
 47a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 47c:	4589                	li	a1,2
 47e:	09c000ef          	jal	51a <sys_sbrk>
}
 482:	60a2                	ld	ra,8(sp)
 484:	6402                	ld	s0,0(sp)
 486:	0141                	addi	sp,sp,16
 488:	8082                	ret

000000000000048a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 48a:	4885                	li	a7,1
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <exit>:
.global exit
exit:
 li a7, SYS_exit
 492:	4889                	li	a7,2
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <wait>:
.global wait
wait:
 li a7, SYS_wait
 49a:	488d                	li	a7,3
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4a2:	4891                	li	a7,4
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <read>:
.global read
read:
 li a7, SYS_read
 4aa:	4895                	li	a7,5
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <write>:
.global write
write:
 li a7, SYS_write
 4b2:	48c1                	li	a7,16
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <close>:
.global close
close:
 li a7, SYS_close
 4ba:	48d5                	li	a7,21
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4c2:	4899                	li	a7,6
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <exec>:
.global exec
exec:
 li a7, SYS_exec
 4ca:	489d                	li	a7,7
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <open>:
.global open
open:
 li a7, SYS_open
 4d2:	48bd                	li	a7,15
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4da:	48c5                	li	a7,17
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4e2:	48c9                	li	a7,18
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4ea:	48a1                	li	a7,8
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <link>:
.global link
link:
 li a7, SYS_link
 4f2:	48cd                	li	a7,19
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4fa:	48d1                	li	a7,20
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 502:	48a5                	li	a7,9
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <dup>:
.global dup
dup:
 li a7, SYS_dup
 50a:	48a9                	li	a7,10
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 512:	48ad                	li	a7,11
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 51a:	48b1                	li	a7,12
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <pause>:
.global pause
pause:
 li a7, SYS_pause
 522:	48b5                	li	a7,13
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 52a:	48b9                	li	a7,14
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <sync>:
.global sync
sync:
 li a7, SYS_sync
 532:	48d9                	li	a7,22
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 53a:	48dd                	li	a7,23
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 542:	1101                	addi	sp,sp,-32
 544:	ec06                	sd	ra,24(sp)
 546:	e822                	sd	s0,16(sp)
 548:	1000                	addi	s0,sp,32
 54a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 54e:	4605                	li	a2,1
 550:	fef40593          	addi	a1,s0,-17
 554:	f5fff0ef          	jal	4b2 <write>
}
 558:	60e2                	ld	ra,24(sp)
 55a:	6442                	ld	s0,16(sp)
 55c:	6105                	addi	sp,sp,32
 55e:	8082                	ret

0000000000000560 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 560:	715d                	addi	sp,sp,-80
 562:	e486                	sd	ra,72(sp)
 564:	e0a2                	sd	s0,64(sp)
 566:	f84a                	sd	s2,48(sp)
 568:	f44e                	sd	s3,40(sp)
 56a:	0880                	addi	s0,sp,80
 56c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 56e:	c6d1                	beqz	a3,5fa <printint+0x9a>
 570:	0805d563          	bgez	a1,5fa <printint+0x9a>
    neg = 1;
    x = -xx;
 574:	40b005b3          	neg	a1,a1
    neg = 1;
 578:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 57a:	fb840993          	addi	s3,s0,-72
  neg = 0;
 57e:	86ce                	mv	a3,s3
  i = 0;
 580:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 582:	00000817          	auipc	a6,0x0
 586:	7d680813          	addi	a6,a6,2006 # d58 <digits>
 58a:	88ba                	mv	a7,a4
 58c:	0017051b          	addiw	a0,a4,1
 590:	872a                	mv	a4,a0
 592:	02c5f7b3          	remu	a5,a1,a2
 596:	97c2                	add	a5,a5,a6
 598:	0007c783          	lbu	a5,0(a5)
 59c:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 5a0:	87ae                	mv	a5,a1
 5a2:	02c5d5b3          	divu	a1,a1,a2
 5a6:	0685                	addi	a3,a3,1
 5a8:	fec7f1e3          	bgeu	a5,a2,58a <printint+0x2a>
  if (neg)
 5ac:	00030c63          	beqz	t1,5c4 <printint+0x64>
    buf[i++] = '-';
 5b0:	fd050793          	addi	a5,a0,-48
 5b4:	00878533          	add	a0,a5,s0
 5b8:	02d00793          	li	a5,45
 5bc:	fef50423          	sb	a5,-24(a0)
 5c0:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 5c4:	02e05563          	blez	a4,5ee <printint+0x8e>
 5c8:	fc26                	sd	s1,56(sp)
 5ca:	377d                	addiw	a4,a4,-1
 5cc:	00e984b3          	add	s1,s3,a4
 5d0:	19fd                	addi	s3,s3,-1
 5d2:	99ba                	add	s3,s3,a4
 5d4:	1702                	slli	a4,a4,0x20
 5d6:	9301                	srli	a4,a4,0x20
 5d8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5dc:	0004c583          	lbu	a1,0(s1)
 5e0:	854a                	mv	a0,s2
 5e2:	f61ff0ef          	jal	542 <putc>
  while (--i >= 0)
 5e6:	14fd                	addi	s1,s1,-1
 5e8:	ff349ae3          	bne	s1,s3,5dc <printint+0x7c>
 5ec:	74e2                	ld	s1,56(sp)
}
 5ee:	60a6                	ld	ra,72(sp)
 5f0:	6406                	ld	s0,64(sp)
 5f2:	7942                	ld	s2,48(sp)
 5f4:	79a2                	ld	s3,40(sp)
 5f6:	6161                	addi	sp,sp,80
 5f8:	8082                	ret
  neg = 0;
 5fa:	4301                	li	t1,0
 5fc:	bfbd                	j	57a <printint+0x1a>

00000000000005fe <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5fe:	711d                	addi	sp,sp,-96
 600:	ec86                	sd	ra,88(sp)
 602:	e8a2                	sd	s0,80(sp)
 604:	e4a6                	sd	s1,72(sp)
 606:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 608:	0005c483          	lbu	s1,0(a1)
 60c:	22048363          	beqz	s1,832 <vprintf+0x234>
 610:	e0ca                	sd	s2,64(sp)
 612:	fc4e                	sd	s3,56(sp)
 614:	f852                	sd	s4,48(sp)
 616:	f456                	sd	s5,40(sp)
 618:	f05a                	sd	s6,32(sp)
 61a:	ec5e                	sd	s7,24(sp)
 61c:	e862                	sd	s8,16(sp)
 61e:	8b2a                	mv	s6,a0
 620:	8a2e                	mv	s4,a1
 622:	8bb2                	mv	s7,a2
  state = 0;
 624:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 626:	4901                	li	s2,0
 628:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 62a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 62e:	06400c13          	li	s8,100
 632:	a00d                	j	654 <vprintf+0x56>
        putc(fd, c0);
 634:	85a6                	mv	a1,s1
 636:	855a                	mv	a0,s6
 638:	f0bff0ef          	jal	542 <putc>
 63c:	a019                	j	642 <vprintf+0x44>
    } else if (state == '%') {
 63e:	03598363          	beq	s3,s5,664 <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 642:	0019079b          	addiw	a5,s2,1
 646:	893e                	mv	s2,a5
 648:	873e                	mv	a4,a5
 64a:	97d2                	add	a5,a5,s4
 64c:	0007c483          	lbu	s1,0(a5)
 650:	1c048a63          	beqz	s1,824 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 654:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 658:	fe0993e3          	bnez	s3,63e <vprintf+0x40>
      if (c0 == '%') {
 65c:	fd579ce3          	bne	a5,s5,634 <vprintf+0x36>
        state = '%';
 660:	89be                	mv	s3,a5
 662:	b7c5                	j	642 <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 664:	00ea06b3          	add	a3,s4,a4
 668:	0016c603          	lbu	a2,1(a3)
      if (c1)
 66c:	1c060863          	beqz	a2,83c <vprintf+0x23e>
      if (c0 == 'd') {
 670:	03878763          	beq	a5,s8,69e <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 674:	f9478693          	addi	a3,a5,-108
 678:	0016b693          	seqz	a3,a3
 67c:	f9c60593          	addi	a1,a2,-100
 680:	e99d                	bnez	a1,6b6 <vprintf+0xb8>
 682:	ca95                	beqz	a3,6b6 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 684:	008b8493          	addi	s1,s7,8
 688:	4685                	li	a3,1
 68a:	4629                	li	a2,10
 68c:	000bb583          	ld	a1,0(s7)
 690:	855a                	mv	a0,s6
 692:	ecfff0ef          	jal	560 <printint>
        i += 1;
 696:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 698:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 69a:	4981                	li	s3,0
 69c:	b75d                	j	642 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 69e:	008b8493          	addi	s1,s7,8
 6a2:	4685                	li	a3,1
 6a4:	4629                	li	a2,10
 6a6:	000ba583          	lw	a1,0(s7)
 6aa:	855a                	mv	a0,s6
 6ac:	eb5ff0ef          	jal	560 <printint>
 6b0:	8ba6                	mv	s7,s1
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	b779                	j	642 <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 6b6:	9752                	add	a4,a4,s4
 6b8:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 6bc:	f9460713          	addi	a4,a2,-108
 6c0:	00173713          	seqz	a4,a4
 6c4:	8f75                	and	a4,a4,a3
 6c6:	f9c58513          	addi	a0,a1,-100
 6ca:	18051363          	bnez	a0,850 <vprintf+0x252>
 6ce:	18070163          	beqz	a4,850 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6d2:	008b8493          	addi	s1,s7,8
 6d6:	4685                	li	a3,1
 6d8:	4629                	li	a2,10
 6da:	000bb583          	ld	a1,0(s7)
 6de:	855a                	mv	a0,s6
 6e0:	e81ff0ef          	jal	560 <printint>
        i += 2;
 6e4:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6e6:	8ba6                	mv	s7,s1
      state = 0;
 6e8:	4981                	li	s3,0
        i += 2;
 6ea:	bfa1                	j	642 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6ec:	008b8493          	addi	s1,s7,8
 6f0:	4681                	li	a3,0
 6f2:	4629                	li	a2,10
 6f4:	000be583          	lwu	a1,0(s7)
 6f8:	855a                	mv	a0,s6
 6fa:	e67ff0ef          	jal	560 <printint>
 6fe:	8ba6                	mv	s7,s1
      state = 0;
 700:	4981                	li	s3,0
 702:	b781                	j	642 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 704:	008b8493          	addi	s1,s7,8
 708:	4681                	li	a3,0
 70a:	4629                	li	a2,10
 70c:	000bb583          	ld	a1,0(s7)
 710:	855a                	mv	a0,s6
 712:	e4fff0ef          	jal	560 <printint>
        i += 1;
 716:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 718:	8ba6                	mv	s7,s1
      state = 0;
 71a:	4981                	li	s3,0
 71c:	b71d                	j	642 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 71e:	008b8493          	addi	s1,s7,8
 722:	4681                	li	a3,0
 724:	4629                	li	a2,10
 726:	000bb583          	ld	a1,0(s7)
 72a:	855a                	mv	a0,s6
 72c:	e35ff0ef          	jal	560 <printint>
        i += 2;
 730:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 732:	8ba6                	mv	s7,s1
      state = 0;
 734:	4981                	li	s3,0
        i += 2;
 736:	b731                	j	642 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 738:	008b8493          	addi	s1,s7,8
 73c:	4681                	li	a3,0
 73e:	4641                	li	a2,16
 740:	000be583          	lwu	a1,0(s7)
 744:	855a                	mv	a0,s6
 746:	e1bff0ef          	jal	560 <printint>
 74a:	8ba6                	mv	s7,s1
      state = 0;
 74c:	4981                	li	s3,0
 74e:	bdd5                	j	642 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 750:	008b8493          	addi	s1,s7,8
 754:	4681                	li	a3,0
 756:	4641                	li	a2,16
 758:	000bb583          	ld	a1,0(s7)
 75c:	855a                	mv	a0,s6
 75e:	e03ff0ef          	jal	560 <printint>
        i += 1;
 762:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 764:	8ba6                	mv	s7,s1
      state = 0;
 766:	4981                	li	s3,0
 768:	bde9                	j	642 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 76a:	008b8493          	addi	s1,s7,8
 76e:	4681                	li	a3,0
 770:	4641                	li	a2,16
 772:	000bb583          	ld	a1,0(s7)
 776:	855a                	mv	a0,s6
 778:	de9ff0ef          	jal	560 <printint>
        i += 2;
 77c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 77e:	8ba6                	mv	s7,s1
      state = 0;
 780:	4981                	li	s3,0
        i += 2;
 782:	b5c1                	j	642 <vprintf+0x44>
 784:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 786:	008b8793          	addi	a5,s7,8
 78a:	8cbe                	mv	s9,a5
 78c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 790:	03000593          	li	a1,48
 794:	855a                	mv	a0,s6
 796:	dadff0ef          	jal	542 <putc>
  putc(fd, 'x');
 79a:	07800593          	li	a1,120
 79e:	855a                	mv	a0,s6
 7a0:	da3ff0ef          	jal	542 <putc>
 7a4:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7a6:	00000b97          	auipc	s7,0x0
 7aa:	5b2b8b93          	addi	s7,s7,1458 # d58 <digits>
 7ae:	03c9d793          	srli	a5,s3,0x3c
 7b2:	97de                	add	a5,a5,s7
 7b4:	0007c583          	lbu	a1,0(a5)
 7b8:	855a                	mv	a0,s6
 7ba:	d89ff0ef          	jal	542 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7be:	0992                	slli	s3,s3,0x4
 7c0:	34fd                	addiw	s1,s1,-1
 7c2:	f4f5                	bnez	s1,7ae <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 7c4:	8be6                	mv	s7,s9
      state = 0;
 7c6:	4981                	li	s3,0
 7c8:	6ca2                	ld	s9,8(sp)
 7ca:	bda5                	j	642 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 7cc:	008b8493          	addi	s1,s7,8
 7d0:	000bc583          	lbu	a1,0(s7)
 7d4:	855a                	mv	a0,s6
 7d6:	d6dff0ef          	jal	542 <putc>
 7da:	8ba6                	mv	s7,s1
      state = 0;
 7dc:	4981                	li	s3,0
 7de:	b595                	j	642 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 7e0:	008b8993          	addi	s3,s7,8
 7e4:	000bb483          	ld	s1,0(s7)
 7e8:	cc91                	beqz	s1,804 <vprintf+0x206>
        for (; *s; s++)
 7ea:	0004c583          	lbu	a1,0(s1)
 7ee:	c985                	beqz	a1,81e <vprintf+0x220>
          putc(fd, *s);
 7f0:	855a                	mv	a0,s6
 7f2:	d51ff0ef          	jal	542 <putc>
        for (; *s; s++)
 7f6:	0485                	addi	s1,s1,1
 7f8:	0004c583          	lbu	a1,0(s1)
 7fc:	f9f5                	bnez	a1,7f0 <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 7fe:	8bce                	mv	s7,s3
      state = 0;
 800:	4981                	li	s3,0
 802:	b581                	j	642 <vprintf+0x44>
          s = "(null)";
 804:	00000497          	auipc	s1,0x0
 808:	54c48493          	addi	s1,s1,1356 # d50 <malloc+0x3b0>
        for (; *s; s++)
 80c:	02800593          	li	a1,40
 810:	b7c5                	j	7f0 <vprintf+0x1f2>
        putc(fd, '%');
 812:	85be                	mv	a1,a5
 814:	855a                	mv	a0,s6
 816:	d2dff0ef          	jal	542 <putc>
      state = 0;
 81a:	4981                	li	s3,0
 81c:	b51d                	j	642 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 81e:	8bce                	mv	s7,s3
      state = 0;
 820:	4981                	li	s3,0
 822:	b505                	j	642 <vprintf+0x44>
 824:	6906                	ld	s2,64(sp)
 826:	79e2                	ld	s3,56(sp)
 828:	7a42                	ld	s4,48(sp)
 82a:	7aa2                	ld	s5,40(sp)
 82c:	7b02                	ld	s6,32(sp)
 82e:	6be2                	ld	s7,24(sp)
 830:	6c42                	ld	s8,16(sp)
    }
  }
}
 832:	60e6                	ld	ra,88(sp)
 834:	6446                	ld	s0,80(sp)
 836:	64a6                	ld	s1,72(sp)
 838:	6125                	addi	sp,sp,96
 83a:	8082                	ret
      if (c0 == 'd') {
 83c:	06400713          	li	a4,100
 840:	e4e78fe3          	beq	a5,a4,69e <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 844:	f9478693          	addi	a3,a5,-108
 848:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 84c:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 84e:	4701                	li	a4,0
      } else if (c0 == 'u') {
 850:	07500513          	li	a0,117
 854:	e8a78ce3          	beq	a5,a0,6ec <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 858:	f8b60513          	addi	a0,a2,-117
 85c:	e119                	bnez	a0,862 <vprintf+0x264>
 85e:	ea0693e3          	bnez	a3,704 <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 862:	f8b58513          	addi	a0,a1,-117
 866:	e119                	bnez	a0,86c <vprintf+0x26e>
 868:	ea071be3          	bnez	a4,71e <vprintf+0x120>
      } else if (c0 == 'x') {
 86c:	07800513          	li	a0,120
 870:	eca784e3          	beq	a5,a0,738 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 874:	f8860613          	addi	a2,a2,-120
 878:	e219                	bnez	a2,87e <vprintf+0x280>
 87a:	ec069be3          	bnez	a3,750 <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 87e:	f8858593          	addi	a1,a1,-120
 882:	e199                	bnez	a1,888 <vprintf+0x28a>
 884:	ee0713e3          	bnez	a4,76a <vprintf+0x16c>
      } else if (c0 == 'p') {
 888:	07000713          	li	a4,112
 88c:	eee78ce3          	beq	a5,a4,784 <vprintf+0x186>
      } else if (c0 == 'c') {
 890:	06300713          	li	a4,99
 894:	f2e78ce3          	beq	a5,a4,7cc <vprintf+0x1ce>
      } else if (c0 == 's') {
 898:	07300713          	li	a4,115
 89c:	f4e782e3          	beq	a5,a4,7e0 <vprintf+0x1e2>
      } else if (c0 == '%') {
 8a0:	02500713          	li	a4,37
 8a4:	f6e787e3          	beq	a5,a4,812 <vprintf+0x214>
        putc(fd, '%');
 8a8:	02500593          	li	a1,37
 8ac:	855a                	mv	a0,s6
 8ae:	c95ff0ef          	jal	542 <putc>
        putc(fd, c0);
 8b2:	85a6                	mv	a1,s1
 8b4:	855a                	mv	a0,s6
 8b6:	c8dff0ef          	jal	542 <putc>
      state = 0;
 8ba:	4981                	li	s3,0
 8bc:	b359                	j	642 <vprintf+0x44>

00000000000008be <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8be:	715d                	addi	sp,sp,-80
 8c0:	ec06                	sd	ra,24(sp)
 8c2:	e822                	sd	s0,16(sp)
 8c4:	1000                	addi	s0,sp,32
 8c6:	e010                	sd	a2,0(s0)
 8c8:	e414                	sd	a3,8(s0)
 8ca:	e818                	sd	a4,16(s0)
 8cc:	ec1c                	sd	a5,24(s0)
 8ce:	03043023          	sd	a6,32(s0)
 8d2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8d6:	8622                	mv	a2,s0
 8d8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8dc:	d23ff0ef          	jal	5fe <vprintf>
}
 8e0:	60e2                	ld	ra,24(sp)
 8e2:	6442                	ld	s0,16(sp)
 8e4:	6161                	addi	sp,sp,80
 8e6:	8082                	ret

00000000000008e8 <printf>:

void
printf(const char *fmt, ...)
{
 8e8:	711d                	addi	sp,sp,-96
 8ea:	ec06                	sd	ra,24(sp)
 8ec:	e822                	sd	s0,16(sp)
 8ee:	1000                	addi	s0,sp,32
 8f0:	e40c                	sd	a1,8(s0)
 8f2:	e810                	sd	a2,16(s0)
 8f4:	ec14                	sd	a3,24(s0)
 8f6:	f018                	sd	a4,32(s0)
 8f8:	f41c                	sd	a5,40(s0)
 8fa:	03043823          	sd	a6,48(s0)
 8fe:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 902:	00840613          	addi	a2,s0,8
 906:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 90a:	85aa                	mv	a1,a0
 90c:	4505                	li	a0,1
 90e:	cf1ff0ef          	jal	5fe <vprintf>
}
 912:	60e2                	ld	ra,24(sp)
 914:	6442                	ld	s0,16(sp)
 916:	6125                	addi	sp,sp,96
 918:	8082                	ret

000000000000091a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 91a:	1141                	addi	sp,sp,-16
 91c:	e406                	sd	ra,8(sp)
 91e:	e022                	sd	s0,0(sp)
 920:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 922:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 926:	00001797          	auipc	a5,0x1
 92a:	6da7b783          	ld	a5,1754(a5) # 2000 <freep>
 92e:	a039                	j	93c <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 930:	6398                	ld	a4,0(a5)
 932:	00e7e463          	bltu	a5,a4,93a <free+0x20>
 936:	00e6ea63          	bltu	a3,a4,94a <free+0x30>
{
 93a:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 93c:	fed7fae3          	bgeu	a5,a3,930 <free+0x16>
 940:	6398                	ld	a4,0(a5)
 942:	00e6e463          	bltu	a3,a4,94a <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 946:	fee7eae3          	bltu	a5,a4,93a <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 94a:	ff852583          	lw	a1,-8(a0)
 94e:	6390                	ld	a2,0(a5)
 950:	02059813          	slli	a6,a1,0x20
 954:	01c85713          	srli	a4,a6,0x1c
 958:	9736                	add	a4,a4,a3
 95a:	02e60563          	beq	a2,a4,984 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 95e:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 962:	4790                	lw	a2,8(a5)
 964:	02061593          	slli	a1,a2,0x20
 968:	01c5d713          	srli	a4,a1,0x1c
 96c:	973e                	add	a4,a4,a5
 96e:	02e68263          	beq	a3,a4,992 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 972:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 974:	00001717          	auipc	a4,0x1
 978:	68f73623          	sd	a5,1676(a4) # 2000 <freep>
}
 97c:	60a2                	ld	ra,8(sp)
 97e:	6402                	ld	s0,0(sp)
 980:	0141                	addi	sp,sp,16
 982:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 984:	4618                	lw	a4,8(a2)
 986:	9f2d                	addw	a4,a4,a1
 988:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 98c:	6398                	ld	a4,0(a5)
 98e:	6310                	ld	a2,0(a4)
 990:	b7f9                	j	95e <free+0x44>
    p->s.size += bp->s.size;
 992:	ff852703          	lw	a4,-8(a0)
 996:	9f31                	addw	a4,a4,a2
 998:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 99a:	ff053683          	ld	a3,-16(a0)
 99e:	bfd1                	j	972 <free+0x58>

00000000000009a0 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 9a0:	7139                	addi	sp,sp,-64
 9a2:	fc06                	sd	ra,56(sp)
 9a4:	f822                	sd	s0,48(sp)
 9a6:	f04a                	sd	s2,32(sp)
 9a8:	ec4e                	sd	s3,24(sp)
 9aa:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 9ac:	02051993          	slli	s3,a0,0x20
 9b0:	0209d993          	srli	s3,s3,0x20
 9b4:	09bd                	addi	s3,s3,15
 9b6:	0049d993          	srli	s3,s3,0x4
 9ba:	2985                	addiw	s3,s3,1
 9bc:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 9be:	00001517          	auipc	a0,0x1
 9c2:	64253503          	ld	a0,1602(a0) # 2000 <freep>
 9c6:	c905                	beqz	a0,9f6 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 9c8:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 9ca:	4798                	lw	a4,8(a5)
 9cc:	09377663          	bgeu	a4,s3,a58 <malloc+0xb8>
 9d0:	f426                	sd	s1,40(sp)
 9d2:	e852                	sd	s4,16(sp)
 9d4:	e456                	sd	s5,8(sp)
 9d6:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 9d8:	8a4e                	mv	s4,s3
 9da:	6705                	lui	a4,0x1
 9dc:	00e9f363          	bgeu	s3,a4,9e2 <malloc+0x42>
 9e0:	6a05                	lui	s4,0x1
 9e2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9e6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 9ea:	00001497          	auipc	s1,0x1
 9ee:	61648493          	addi	s1,s1,1558 # 2000 <freep>
  if (p == SBRK_ERROR)
 9f2:	5afd                	li	s5,-1
 9f4:	a83d                	j	a32 <malloc+0x92>
 9f6:	f426                	sd	s1,40(sp)
 9f8:	e852                	sd	s4,16(sp)
 9fa:	e456                	sd	s5,8(sp)
 9fc:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9fe:	00001797          	auipc	a5,0x1
 a02:	61278793          	addi	a5,a5,1554 # 2010 <base>
 a06:	00001717          	auipc	a4,0x1
 a0a:	5ef73d23          	sd	a5,1530(a4) # 2000 <freep>
 a0e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a10:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 a14:	b7d1                	j	9d8 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 a16:	6398                	ld	a4,0(a5)
 a18:	e118                	sd	a4,0(a0)
 a1a:	a899                	j	a70 <malloc+0xd0>
  hp->s.size = nu;
 a1c:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 a20:	0541                	addi	a0,a0,16
 a22:	ef9ff0ef          	jal	91a <free>
  return freep;
 a26:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 a28:	c125                	beqz	a0,a88 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 a2a:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 a2c:	4798                	lw	a4,8(a5)
 a2e:	03277163          	bgeu	a4,s2,a50 <malloc+0xb0>
    if (p == freep)
 a32:	6098                	ld	a4,0(s1)
 a34:	853e                	mv	a0,a5
 a36:	fef71ae3          	bne	a4,a5,a2a <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 a3a:	8552                	mv	a0,s4
 a3c:	a23ff0ef          	jal	45e <sbrk>
  if (p == SBRK_ERROR)
 a40:	fd551ee3          	bne	a0,s5,a1c <malloc+0x7c>
        return 0;
 a44:	4501                	li	a0,0
 a46:	74a2                	ld	s1,40(sp)
 a48:	6a42                	ld	s4,16(sp)
 a4a:	6aa2                	ld	s5,8(sp)
 a4c:	6b02                	ld	s6,0(sp)
 a4e:	a03d                	j	a7c <malloc+0xdc>
 a50:	74a2                	ld	s1,40(sp)
 a52:	6a42                	ld	s4,16(sp)
 a54:	6aa2                	ld	s5,8(sp)
 a56:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 a58:	fae90fe3          	beq	s2,a4,a16 <malloc+0x76>
        p->s.size -= nunits;
 a5c:	4137073b          	subw	a4,a4,s3
 a60:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a62:	02071693          	slli	a3,a4,0x20
 a66:	01c6d713          	srli	a4,a3,0x1c
 a6a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a6c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a70:	00001717          	auipc	a4,0x1
 a74:	58a73823          	sd	a0,1424(a4) # 2000 <freep>
      return (void *)(p + 1);
 a78:	01078513          	addi	a0,a5,16
  }
}
 a7c:	70e2                	ld	ra,56(sp)
 a7e:	7442                	ld	s0,48(sp)
 a80:	7902                	ld	s2,32(sp)
 a82:	69e2                	ld	s3,24(sp)
 a84:	6121                	addi	sp,sp,64
 a86:	8082                	ret
 a88:	74a2                	ld	s1,40(sp)
 a8a:	6a42                	ld	s4,16(sp)
 a8c:	6aa2                	ld	s5,8(sp)
 a8e:	6b02                	ld	s6,0(sp)
 a90:	b7f5                	j	a7c <malloc+0xdc>
