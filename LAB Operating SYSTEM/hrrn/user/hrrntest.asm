
user/_hrrntest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

#define NUM_CHILDREN 4

int main(int argc, char *argv[]) {
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
  16:	1100                	addi	s0,sp,160
  // Mix of very long, short, and medium processes
  // P1: Very Long (80 ticks)
  // P2: Short (10 ticks)
  // P3: Short (10 ticks)
  // P4: Medium (30 ticks)
  int burst_times[NUM_CHILDREN] = {80, 10, 10, 30};
  18:	05000793          	li	a5,80
  1c:	f8f42823          	sw	a5,-112(s0)
  20:	47a9                	li	a5,10
  22:	f8f42a23          	sw	a5,-108(s0)
  26:	f8f42c23          	sw	a5,-104(s0)
  2a:	47f9                	li	a5,30
  2c:	f8f42e23          	sw	a5,-100(s0)
  uint64 workloads[NUM_CHILDREN] = {80000000ULL, 10000000ULL, 10000000ULL, 30000000ULL};
  30:	04c4b7b7          	lui	a5,0x4c4b
  34:	40078793          	addi	a5,a5,1024 # 4c4b400 <base+0x4c493f0>
  38:	f6f43823          	sd	a5,-144(s0)
  3c:	009897b7          	lui	a5,0x989
  40:	68078793          	addi	a5,a5,1664 # 989680 <base+0x987670>
  44:	f6f43c23          	sd	a5,-136(s0)
  48:	f8f43023          	sd	a5,-128(s0)
  4c:	01c9c7b7          	lui	a5,0x1c9c
  50:	38078793          	addi	a5,a5,896 # 1c9c380 <base+0x1c9a370>
  54:	f8f43423          	sd	a5,-120(s0)

  printf("--- Highest Response Ratio Next (HRRN) Test ---\n");
  58:	00001517          	auipc	a0,0x1
  5c:	a3850513          	addi	a0,a0,-1480 # a90 <malloc+0xf2>
  60:	087000ef          	jal	8e6 <printf>
  printf("Parent PID: %d\n", getpid());
  64:	4ac000ef          	jal	510 <getpid>
  68:	85aa                	mv	a1,a0
  6a:	00001517          	auipc	a0,0x1
  6e:	a5e50513          	addi	a0,a0,-1442 # ac8 <malloc+0x12a>
  72:	075000ef          	jal	8e6 <printf>
  printf("Forking 4 processes: P1(Long=80), P2(Short=10), P3(Short=10), P4(Med=30)...\n\n");
  76:	00001517          	auipc	a0,0x1
  7a:	a6250513          	addi	a0,a0,-1438 # ad8 <malloc+0x13a>
  7e:	069000ef          	jal	8e6 <printf>

  for (int i = 0; i < NUM_CHILDREN; i++) {
  82:	f9040a93          	addi	s5,s0,-112
  86:	fa040a13          	addi	s4,s0,-96
  printf("Forking 4 processes: P1(Long=80), P2(Short=10), P3(Short=10), P4(Med=30)...\n\n");
  8a:	89d2                	mv	s3,s4
  for (int i = 0; i < NUM_CHILDREN; i++) {
  8c:	4901                	li	s2,0
      exit(0);
    } else {
      // Parent records burst time immediately
      set_burst(pid, burst_times[i]);
      pids[i] = pid;
      printf("[Parent] Forked Child %d (PID %d) with declared burst time = %d\n",
  8e:	00001c17          	auipc	s8,0x1
  92:	b32c0c13          	addi	s8,s8,-1230 # bc0 <malloc+0x222>
  for (int i = 0; i < NUM_CHILDREN; i++) {
  96:	4b91                	li	s7,4
    int pid = fork();
  98:	3f0000ef          	jal	488 <fork>
  9c:	84aa                	mv	s1,a0
    if (pid < 0) {
  9e:	08054363          	bltz	a0,124 <main+0x124>
    if (pid == 0) {
  a2:	c951                	beqz	a0,136 <main+0x136>
      set_burst(pid, burst_times[i]);
  a4:	000aab03          	lw	s6,0(s5)
  a8:	85da                	mv	a1,s6
  aa:	48e000ef          	jal	538 <set_burst>
      pids[i] = pid;
  ae:	0099a023          	sw	s1,0(s3)
      printf("[Parent] Forked Child %d (PID %d) with declared burst time = %d\n",
  b2:	0019059b          	addiw	a1,s2,1
  b6:	892e                	mv	s2,a1
  b8:	86da                	mv	a3,s6
  ba:	8626                	mv	a2,s1
  bc:	8562                	mv	a0,s8
  be:	029000ef          	jal	8e6 <printf>
  for (int i = 0; i < NUM_CHILDREN; i++) {
  c2:	0a91                	addi	s5,s5,4
  c4:	0991                	addi	s3,s3,4
  c6:	fd7919e3          	bne	s2,s7,98 <main+0x98>
             i + 1, pid, burst_times[i]);
    }
  }

  printf("\n[Parent] All children forked. Waiting for completion...\n\n");
  ca:	00001517          	auipc	a0,0x1
  ce:	b3e50513          	addi	a0,a0,-1218 # c08 <malloc+0x26a>
  d2:	015000ef          	jal	8e6 <printf>

  for (int order = 1; order <= NUM_CHILDREN; order++) {
  d6:	4485                	li	s1,1
    int finished_pid = wait(0);
    int child_idx = -1;
    int bt = -1;
    for (int i = 0; i < NUM_CHILDREN; i++) {
  d8:	4911                	li	s2,4
    int bt = -1;
  da:	59fd                	li	s3,-1
        child_idx = i + 1;
        bt = burst_times[i];
        break;
      }
    }
    printf(">> Completion Order %d: PID %d (Child %d, Burst Time %d ticks)\n",
  dc:	00001b17          	auipc	s6,0x1
  e0:	b6cb0b13          	addi	s6,s6,-1172 # c48 <malloc+0x2aa>
  for (int order = 1; order <= NUM_CHILDREN; order++) {
  e4:	4a95                	li	s5,5
    int finished_pid = wait(0);
  e6:	4501                	li	a0,0
  e8:	3b0000ef          	jal	498 <wait>
  ec:	862a                	mv	a2,a0
  ee:	8752                	mv	a4,s4
    for (int i = 0; i < NUM_CHILDREN; i++) {
  f0:	4781                	li	a5,0
      if (pids[i] == finished_pid) {
  f2:	4314                	lw	a3,0(a4)
  f4:	0cc68a63          	beq	a3,a2,1c8 <main+0x1c8>
    for (int i = 0; i < NUM_CHILDREN; i++) {
  f8:	2785                	addiw	a5,a5,1
  fa:	0711                	addi	a4,a4,4
  fc:	ff279be3          	bne	a5,s2,f2 <main+0xf2>
    int bt = -1;
 100:	874e                	mv	a4,s3
    int child_idx = -1;
 102:	86ce                	mv	a3,s3
    printf(">> Completion Order %d: PID %d (Child %d, Burst Time %d ticks)\n",
 104:	85a6                	mv	a1,s1
 106:	855a                	mv	a0,s6
 108:	7de000ef          	jal	8e6 <printf>
  for (int order = 1; order <= NUM_CHILDREN; order++) {
 10c:	2485                	addiw	s1,s1,1
 10e:	fd549ce3          	bne	s1,s5,e6 <main+0xe6>
           order, finished_pid, child_idx, bt);
  }

  printf("\n--- HRRN Test Passed: Short jobs ran early; long jobs completed without starvation! ---\n");
 112:	00001517          	auipc	a0,0x1
 116:	b7650513          	addi	a0,a0,-1162 # c88 <malloc+0x2ea>
 11a:	7cc000ef          	jal	8e6 <printf>
  exit(0);
 11e:	4501                	li	a0,0
 120:	370000ef          	jal	490 <exit>
      printf("Fork failed!\n");
 124:	00001517          	auipc	a0,0x1
 128:	a0450513          	addi	a0,a0,-1532 # b28 <malloc+0x18a>
 12c:	7ba000ef          	jal	8e6 <printf>
      exit(1);
 130:	4505                	li	a0,1
 132:	35e000ef          	jal	490 <exit>
      int my_pid = getpid();
 136:	3da000ef          	jal	510 <getpid>
 13a:	84aa                	mv	s1,a0
      set_burst(my_pid, burst_times[i]);
 13c:	00291793          	slli	a5,s2,0x2
 140:	fb078793          	addi	a5,a5,-80
 144:	97a2                	add	a5,a5,s0
 146:	fe07a983          	lw	s3,-32(a5)
 14a:	85ce                	mv	a1,s3
 14c:	3ec000ef          	jal	538 <set_burst>
      printf("[Child %d | PID %d] Declared Burst Time = %d ticks (uptime: %d)\n",
 150:	00190a1b          	addiw	s4,s2,1
 154:	3d4000ef          	jal	528 <uptime>
 158:	872a                	mv	a4,a0
 15a:	86ce                	mv	a3,s3
 15c:	8626                	mv	a2,s1
 15e:	85d2                	mv	a1,s4
 160:	00001517          	auipc	a0,0x1
 164:	9d850513          	addi	a0,a0,-1576 # b38 <malloc+0x19a>
 168:	77e000ef          	jal	8e6 <printf>
      volatile uint64 counter = 0;
 16c:	f6043023          	sd	zero,-160(s0)
      for (volatile uint64 j = 0; j < workloads[i]; j++) {
 170:	f6043423          	sd	zero,-152(s0)
 174:	00391793          	slli	a5,s2,0x3
 178:	fb078793          	addi	a5,a5,-80
 17c:	97a2                	add	a5,a5,s0
 17e:	fc07b683          	ld	a3,-64(a5)
 182:	f6843783          	ld	a5,-152(s0)
 186:	02d7f263          	bgeu	a5,a3,1aa <main+0x1aa>
        counter += j;
 18a:	f6843703          	ld	a4,-152(s0)
 18e:	f6043783          	ld	a5,-160(s0)
 192:	97ba                	add	a5,a5,a4
 194:	f6f43023          	sd	a5,-160(s0)
      for (volatile uint64 j = 0; j < workloads[i]; j++) {
 198:	f6843783          	ld	a5,-152(s0)
 19c:	0785                	addi	a5,a5,1
 19e:	f6f43423          	sd	a5,-152(s0)
 1a2:	f6843783          	ld	a5,-152(s0)
 1a6:	fed7e2e3          	bltu	a5,a3,18a <main+0x18a>
      printf("[Child %d | PID %d | BT %d] Completed workload at tick %d\n",
 1aa:	37e000ef          	jal	528 <uptime>
 1ae:	872a                	mv	a4,a0
 1b0:	86ce                	mv	a3,s3
 1b2:	8626                	mv	a2,s1
 1b4:	85d2                	mv	a1,s4
 1b6:	00001517          	auipc	a0,0x1
 1ba:	9ca50513          	addi	a0,a0,-1590 # b80 <malloc+0x1e2>
 1be:	728000ef          	jal	8e6 <printf>
      exit(0);
 1c2:	4501                	li	a0,0
 1c4:	2cc000ef          	jal	490 <exit>
        child_idx = i + 1;
 1c8:	0017869b          	addiw	a3,a5,1
        bt = burst_times[i];
 1cc:	078a                	slli	a5,a5,0x2
 1ce:	fb078793          	addi	a5,a5,-80
 1d2:	97a2                	add	a5,a5,s0
 1d4:	fe07a703          	lw	a4,-32(a5)
        break;
 1d8:	b735                	j	104 <main+0x104>

00000000000001da <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1da:	1141                	addi	sp,sp,-16
 1dc:	e406                	sd	ra,8(sp)
 1de:	e022                	sd	s0,0(sp)
 1e0:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1e2:	e1fff0ef          	jal	0 <main>
  exit(r);
 1e6:	2aa000ef          	jal	490 <exit>

00000000000001ea <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 1ea:	1141                	addi	sp,sp,-16
 1ec:	e406                	sd	ra,8(sp)
 1ee:	e022                	sd	s0,0(sp)
 1f0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 1f2:	87aa                	mv	a5,a0
 1f4:	0585                	addi	a1,a1,1
 1f6:	0785                	addi	a5,a5,1
 1f8:	fff5c703          	lbu	a4,-1(a1)
 1fc:	fee78fa3          	sb	a4,-1(a5)
 200:	fb75                	bnez	a4,1f4 <strcpy+0xa>
    ;
  return os;
}
 202:	60a2                	ld	ra,8(sp)
 204:	6402                	ld	s0,0(sp)
 206:	0141                	addi	sp,sp,16
 208:	8082                	ret

000000000000020a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 20a:	1141                	addi	sp,sp,-16
 20c:	e406                	sd	ra,8(sp)
 20e:	e022                	sd	s0,0(sp)
 210:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 212:	00054783          	lbu	a5,0(a0)
 216:	cb91                	beqz	a5,22a <strcmp+0x20>
 218:	0005c703          	lbu	a4,0(a1)
 21c:	00f71763          	bne	a4,a5,22a <strcmp+0x20>
    p++, q++;
 220:	0505                	addi	a0,a0,1
 222:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 224:	00054783          	lbu	a5,0(a0)
 228:	fbe5                	bnez	a5,218 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 22a:	0005c503          	lbu	a0,0(a1)
}
 22e:	40a7853b          	subw	a0,a5,a0
 232:	60a2                	ld	ra,8(sp)
 234:	6402                	ld	s0,0(sp)
 236:	0141                	addi	sp,sp,16
 238:	8082                	ret

000000000000023a <strlen>:

uint
strlen(const char *s)
{
 23a:	1141                	addi	sp,sp,-16
 23c:	e406                	sd	ra,8(sp)
 23e:	e022                	sd	s0,0(sp)
 240:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 242:	00054783          	lbu	a5,0(a0)
 246:	cf91                	beqz	a5,262 <strlen+0x28>
 248:	00150793          	addi	a5,a0,1
 24c:	86be                	mv	a3,a5
 24e:	0785                	addi	a5,a5,1
 250:	fff7c703          	lbu	a4,-1(a5)
 254:	ff65                	bnez	a4,24c <strlen+0x12>
 256:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 25a:	60a2                	ld	ra,8(sp)
 25c:	6402                	ld	s0,0(sp)
 25e:	0141                	addi	sp,sp,16
 260:	8082                	ret
  for (n = 0; s[n]; n++)
 262:	4501                	li	a0,0
 264:	bfdd                	j	25a <strlen+0x20>

0000000000000266 <memset>:

void *
memset(void *dst, int c, uint n)
{
 266:	1141                	addi	sp,sp,-16
 268:	e406                	sd	ra,8(sp)
 26a:	e022                	sd	s0,0(sp)
 26c:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 26e:	ca19                	beqz	a2,284 <memset+0x1e>
 270:	87aa                	mv	a5,a0
 272:	1602                	slli	a2,a2,0x20
 274:	9201                	srli	a2,a2,0x20
 276:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 27a:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 27e:	0785                	addi	a5,a5,1
 280:	fee79de3          	bne	a5,a4,27a <memset+0x14>
  }
  return dst;
}
 284:	60a2                	ld	ra,8(sp)
 286:	6402                	ld	s0,0(sp)
 288:	0141                	addi	sp,sp,16
 28a:	8082                	ret

000000000000028c <strchr>:

char *
strchr(const char *s, char c)
{
 28c:	1141                	addi	sp,sp,-16
 28e:	e406                	sd	ra,8(sp)
 290:	e022                	sd	s0,0(sp)
 292:	0800                	addi	s0,sp,16
  for (; *s; s++)
 294:	00054783          	lbu	a5,0(a0)
 298:	cf81                	beqz	a5,2b0 <strchr+0x24>
    if (*s == c)
 29a:	00f58763          	beq	a1,a5,2a8 <strchr+0x1c>
  for (; *s; s++)
 29e:	0505                	addi	a0,a0,1
 2a0:	00054783          	lbu	a5,0(a0)
 2a4:	fbfd                	bnez	a5,29a <strchr+0xe>
      return (char *)s;
  return 0;
 2a6:	4501                	li	a0,0
}
 2a8:	60a2                	ld	ra,8(sp)
 2aa:	6402                	ld	s0,0(sp)
 2ac:	0141                	addi	sp,sp,16
 2ae:	8082                	ret
  return 0;
 2b0:	4501                	li	a0,0
 2b2:	bfdd                	j	2a8 <strchr+0x1c>

00000000000002b4 <gets>:

char *
gets(char *buf, int max)
{
 2b4:	711d                	addi	sp,sp,-96
 2b6:	ec86                	sd	ra,88(sp)
 2b8:	e8a2                	sd	s0,80(sp)
 2ba:	e4a6                	sd	s1,72(sp)
 2bc:	e0ca                	sd	s2,64(sp)
 2be:	fc4e                	sd	s3,56(sp)
 2c0:	f852                	sd	s4,48(sp)
 2c2:	f456                	sd	s5,40(sp)
 2c4:	f05a                	sd	s6,32(sp)
 2c6:	ec5e                	sd	s7,24(sp)
 2c8:	e862                	sd	s8,16(sp)
 2ca:	1080                	addi	s0,sp,96
 2cc:	8baa                	mv	s7,a0
 2ce:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 2d0:	892a                	mv	s2,a0
 2d2:	4481                	li	s1,0
    cc = read(0, &c, 1);
 2d4:	faf40b13          	addi	s6,s0,-81
 2d8:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 2da:	8c26                	mv	s8,s1
 2dc:	0014899b          	addiw	s3,s1,1
 2e0:	84ce                	mv	s1,s3
 2e2:	0349d463          	bge	s3,s4,30a <gets+0x56>
    cc = read(0, &c, 1);
 2e6:	8656                	mv	a2,s5
 2e8:	85da                	mv	a1,s6
 2ea:	4501                	li	a0,0
 2ec:	1bc000ef          	jal	4a8 <read>
    if (cc < 1)
 2f0:	00a05d63          	blez	a0,30a <gets+0x56>
      break;
    buf[i++] = c;
 2f4:	faf44783          	lbu	a5,-81(s0)
 2f8:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 2fc:	0905                	addi	s2,s2,1
 2fe:	ff678713          	addi	a4,a5,-10
 302:	c319                	beqz	a4,308 <gets+0x54>
 304:	17cd                	addi	a5,a5,-13
 306:	fbf1                	bnez	a5,2da <gets+0x26>
    buf[i++] = c;
 308:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 30a:	9c5e                	add	s8,s8,s7
 30c:	000c0023          	sb	zero,0(s8)
  return buf;
}
 310:	855e                	mv	a0,s7
 312:	60e6                	ld	ra,88(sp)
 314:	6446                	ld	s0,80(sp)
 316:	64a6                	ld	s1,72(sp)
 318:	6906                	ld	s2,64(sp)
 31a:	79e2                	ld	s3,56(sp)
 31c:	7a42                	ld	s4,48(sp)
 31e:	7aa2                	ld	s5,40(sp)
 320:	7b02                	ld	s6,32(sp)
 322:	6be2                	ld	s7,24(sp)
 324:	6c42                	ld	s8,16(sp)
 326:	6125                	addi	sp,sp,96
 328:	8082                	ret

000000000000032a <stat>:

int
stat(const char *n, struct stat *st)
{
 32a:	1101                	addi	sp,sp,-32
 32c:	ec06                	sd	ra,24(sp)
 32e:	e822                	sd	s0,16(sp)
 330:	e04a                	sd	s2,0(sp)
 332:	1000                	addi	s0,sp,32
 334:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 336:	4581                	li	a1,0
 338:	198000ef          	jal	4d0 <open>
  if (fd < 0)
 33c:	02054263          	bltz	a0,360 <stat+0x36>
 340:	e426                	sd	s1,8(sp)
 342:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 344:	85ca                	mv	a1,s2
 346:	1a2000ef          	jal	4e8 <fstat>
 34a:	892a                	mv	s2,a0
  close(fd);
 34c:	8526                	mv	a0,s1
 34e:	16a000ef          	jal	4b8 <close>
  return r;
 352:	64a2                	ld	s1,8(sp)
}
 354:	854a                	mv	a0,s2
 356:	60e2                	ld	ra,24(sp)
 358:	6442                	ld	s0,16(sp)
 35a:	6902                	ld	s2,0(sp)
 35c:	6105                	addi	sp,sp,32
 35e:	8082                	ret
    return -1;
 360:	57fd                	li	a5,-1
 362:	893e                	mv	s2,a5
 364:	bfc5                	j	354 <stat+0x2a>

0000000000000366 <atoi>:

int
atoi(const char *s)
{
 366:	1141                	addi	sp,sp,-16
 368:	e406                	sd	ra,8(sp)
 36a:	e022                	sd	s0,0(sp)
 36c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 36e:	00054683          	lbu	a3,0(a0)
 372:	fd06879b          	addiw	a5,a3,-48
 376:	0ff7f793          	zext.b	a5,a5
 37a:	4625                	li	a2,9
 37c:	02f66963          	bltu	a2,a5,3ae <atoi+0x48>
 380:	872a                	mv	a4,a0
  n = 0;
 382:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 384:	0705                	addi	a4,a4,1
 386:	0025179b          	slliw	a5,a0,0x2
 38a:	9fa9                	addw	a5,a5,a0
 38c:	0017979b          	slliw	a5,a5,0x1
 390:	9fb5                	addw	a5,a5,a3
 392:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 396:	00074683          	lbu	a3,0(a4)
 39a:	fd06879b          	addiw	a5,a3,-48
 39e:	0ff7f793          	zext.b	a5,a5
 3a2:	fef671e3          	bgeu	a2,a5,384 <atoi+0x1e>
  return n;
}
 3a6:	60a2                	ld	ra,8(sp)
 3a8:	6402                	ld	s0,0(sp)
 3aa:	0141                	addi	sp,sp,16
 3ac:	8082                	ret
  n = 0;
 3ae:	4501                	li	a0,0
 3b0:	bfdd                	j	3a6 <atoi+0x40>

00000000000003b2 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 3b2:	1141                	addi	sp,sp,-16
 3b4:	e406                	sd	ra,8(sp)
 3b6:	e022                	sd	s0,0(sp)
 3b8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3ba:	02b57563          	bgeu	a0,a1,3e4 <memmove+0x32>
    while (n-- > 0)
 3be:	00c05f63          	blez	a2,3dc <memmove+0x2a>
 3c2:	1602                	slli	a2,a2,0x20
 3c4:	9201                	srli	a2,a2,0x20
 3c6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3ca:	872a                	mv	a4,a0
      *dst++ = *src++;
 3cc:	0585                	addi	a1,a1,1
 3ce:	0705                	addi	a4,a4,1
 3d0:	fff5c683          	lbu	a3,-1(a1)
 3d4:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 3d8:	fee79ae3          	bne	a5,a4,3cc <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3dc:	60a2                	ld	ra,8(sp)
 3de:	6402                	ld	s0,0(sp)
 3e0:	0141                	addi	sp,sp,16
 3e2:	8082                	ret
    while (n-- > 0)
 3e4:	fec05ce3          	blez	a2,3dc <memmove+0x2a>
    dst += n;
 3e8:	00c50733          	add	a4,a0,a2
    src += n;
 3ec:	95b2                	add	a1,a1,a2
 3ee:	fff6079b          	addiw	a5,a2,-1
 3f2:	1782                	slli	a5,a5,0x20
 3f4:	9381                	srli	a5,a5,0x20
 3f6:	fff7c793          	not	a5,a5
 3fa:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3fc:	15fd                	addi	a1,a1,-1
 3fe:	177d                	addi	a4,a4,-1
 400:	0005c683          	lbu	a3,0(a1)
 404:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 408:	fef71ae3          	bne	a4,a5,3fc <memmove+0x4a>
 40c:	bfc1                	j	3dc <memmove+0x2a>

000000000000040e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 40e:	1141                	addi	sp,sp,-16
 410:	e406                	sd	ra,8(sp)
 412:	e022                	sd	s0,0(sp)
 414:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 416:	c61d                	beqz	a2,444 <memcmp+0x36>
 418:	1602                	slli	a2,a2,0x20
 41a:	9201                	srli	a2,a2,0x20
 41c:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 420:	00054783          	lbu	a5,0(a0)
 424:	0005c703          	lbu	a4,0(a1)
 428:	00e79863          	bne	a5,a4,438 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 42c:	0505                	addi	a0,a0,1
    p2++;
 42e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 430:	fed518e3          	bne	a0,a3,420 <memcmp+0x12>
  }
  return 0;
 434:	4501                	li	a0,0
 436:	a019                	j	43c <memcmp+0x2e>
      return *p1 - *p2;
 438:	40e7853b          	subw	a0,a5,a4
}
 43c:	60a2                	ld	ra,8(sp)
 43e:	6402                	ld	s0,0(sp)
 440:	0141                	addi	sp,sp,16
 442:	8082                	ret
  return 0;
 444:	4501                	li	a0,0
 446:	bfdd                	j	43c <memcmp+0x2e>

0000000000000448 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 448:	1141                	addi	sp,sp,-16
 44a:	e406                	sd	ra,8(sp)
 44c:	e022                	sd	s0,0(sp)
 44e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 450:	f63ff0ef          	jal	3b2 <memmove>
}
 454:	60a2                	ld	ra,8(sp)
 456:	6402                	ld	s0,0(sp)
 458:	0141                	addi	sp,sp,16
 45a:	8082                	ret

000000000000045c <sbrk>:

char *
sbrk(int n)
{
 45c:	1141                	addi	sp,sp,-16
 45e:	e406                	sd	ra,8(sp)
 460:	e022                	sd	s0,0(sp)
 462:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 464:	4585                	li	a1,1
 466:	0b2000ef          	jal	518 <sys_sbrk>
}
 46a:	60a2                	ld	ra,8(sp)
 46c:	6402                	ld	s0,0(sp)
 46e:	0141                	addi	sp,sp,16
 470:	8082                	ret

0000000000000472 <sbrklazy>:

char *
sbrklazy(int n)
{
 472:	1141                	addi	sp,sp,-16
 474:	e406                	sd	ra,8(sp)
 476:	e022                	sd	s0,0(sp)
 478:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 47a:	4589                	li	a1,2
 47c:	09c000ef          	jal	518 <sys_sbrk>
}
 480:	60a2                	ld	ra,8(sp)
 482:	6402                	ld	s0,0(sp)
 484:	0141                	addi	sp,sp,16
 486:	8082                	ret

0000000000000488 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 488:	4885                	li	a7,1
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <exit>:
.global exit
exit:
 li a7, SYS_exit
 490:	4889                	li	a7,2
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <wait>:
.global wait
wait:
 li a7, SYS_wait
 498:	488d                	li	a7,3
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4a0:	4891                	li	a7,4
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <read>:
.global read
read:
 li a7, SYS_read
 4a8:	4895                	li	a7,5
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <write>:
.global write
write:
 li a7, SYS_write
 4b0:	48c1                	li	a7,16
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <close>:
.global close
close:
 li a7, SYS_close
 4b8:	48d5                	li	a7,21
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4c0:	4899                	li	a7,6
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4c8:	489d                	li	a7,7
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <open>:
.global open
open:
 li a7, SYS_open
 4d0:	48bd                	li	a7,15
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4d8:	48c5                	li	a7,17
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4e0:	48c9                	li	a7,18
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4e8:	48a1                	li	a7,8
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <link>:
.global link
link:
 li a7, SYS_link
 4f0:	48cd                	li	a7,19
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4f8:	48d1                	li	a7,20
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 500:	48a5                	li	a7,9
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <dup>:
.global dup
dup:
 li a7, SYS_dup
 508:	48a9                	li	a7,10
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 510:	48ad                	li	a7,11
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 518:	48b1                	li	a7,12
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <pause>:
.global pause
pause:
 li a7, SYS_pause
 520:	48b5                	li	a7,13
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 528:	48b9                	li	a7,14
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <sync>:
.global sync
sync:
 li a7, SYS_sync
 530:	48d9                	li	a7,22
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <set_burst>:
.global set_burst
set_burst:
 li a7, SYS_set_burst
 538:	48dd                	li	a7,23
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 540:	1101                	addi	sp,sp,-32
 542:	ec06                	sd	ra,24(sp)
 544:	e822                	sd	s0,16(sp)
 546:	1000                	addi	s0,sp,32
 548:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 54c:	4605                	li	a2,1
 54e:	fef40593          	addi	a1,s0,-17
 552:	f5fff0ef          	jal	4b0 <write>
}
 556:	60e2                	ld	ra,24(sp)
 558:	6442                	ld	s0,16(sp)
 55a:	6105                	addi	sp,sp,32
 55c:	8082                	ret

000000000000055e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 55e:	715d                	addi	sp,sp,-80
 560:	e486                	sd	ra,72(sp)
 562:	e0a2                	sd	s0,64(sp)
 564:	f84a                	sd	s2,48(sp)
 566:	f44e                	sd	s3,40(sp)
 568:	0880                	addi	s0,sp,80
 56a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 56c:	c6d1                	beqz	a3,5f8 <printint+0x9a>
 56e:	0805d563          	bgez	a1,5f8 <printint+0x9a>
    neg = 1;
    x = -xx;
 572:	40b005b3          	neg	a1,a1
    neg = 1;
 576:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 578:	fb840993          	addi	s3,s0,-72
  neg = 0;
 57c:	86ce                	mv	a3,s3
  i = 0;
 57e:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 580:	00000817          	auipc	a6,0x0
 584:	77080813          	addi	a6,a6,1904 # cf0 <digits>
 588:	88ba                	mv	a7,a4
 58a:	0017051b          	addiw	a0,a4,1
 58e:	872a                	mv	a4,a0
 590:	02c5f7b3          	remu	a5,a1,a2
 594:	97c2                	add	a5,a5,a6
 596:	0007c783          	lbu	a5,0(a5)
 59a:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 59e:	87ae                	mv	a5,a1
 5a0:	02c5d5b3          	divu	a1,a1,a2
 5a4:	0685                	addi	a3,a3,1
 5a6:	fec7f1e3          	bgeu	a5,a2,588 <printint+0x2a>
  if (neg)
 5aa:	00030c63          	beqz	t1,5c2 <printint+0x64>
    buf[i++] = '-';
 5ae:	fd050793          	addi	a5,a0,-48
 5b2:	00878533          	add	a0,a5,s0
 5b6:	02d00793          	li	a5,45
 5ba:	fef50423          	sb	a5,-24(a0)
 5be:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 5c2:	02e05563          	blez	a4,5ec <printint+0x8e>
 5c6:	fc26                	sd	s1,56(sp)
 5c8:	377d                	addiw	a4,a4,-1
 5ca:	00e984b3          	add	s1,s3,a4
 5ce:	19fd                	addi	s3,s3,-1
 5d0:	99ba                	add	s3,s3,a4
 5d2:	1702                	slli	a4,a4,0x20
 5d4:	9301                	srli	a4,a4,0x20
 5d6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5da:	0004c583          	lbu	a1,0(s1)
 5de:	854a                	mv	a0,s2
 5e0:	f61ff0ef          	jal	540 <putc>
  while (--i >= 0)
 5e4:	14fd                	addi	s1,s1,-1
 5e6:	ff349ae3          	bne	s1,s3,5da <printint+0x7c>
 5ea:	74e2                	ld	s1,56(sp)
}
 5ec:	60a6                	ld	ra,72(sp)
 5ee:	6406                	ld	s0,64(sp)
 5f0:	7942                	ld	s2,48(sp)
 5f2:	79a2                	ld	s3,40(sp)
 5f4:	6161                	addi	sp,sp,80
 5f6:	8082                	ret
  neg = 0;
 5f8:	4301                	li	t1,0
 5fa:	bfbd                	j	578 <printint+0x1a>

00000000000005fc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5fc:	711d                	addi	sp,sp,-96
 5fe:	ec86                	sd	ra,88(sp)
 600:	e8a2                	sd	s0,80(sp)
 602:	e4a6                	sd	s1,72(sp)
 604:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 606:	0005c483          	lbu	s1,0(a1)
 60a:	22048363          	beqz	s1,830 <vprintf+0x234>
 60e:	e0ca                	sd	s2,64(sp)
 610:	fc4e                	sd	s3,56(sp)
 612:	f852                	sd	s4,48(sp)
 614:	f456                	sd	s5,40(sp)
 616:	f05a                	sd	s6,32(sp)
 618:	ec5e                	sd	s7,24(sp)
 61a:	e862                	sd	s8,16(sp)
 61c:	8b2a                	mv	s6,a0
 61e:	8a2e                	mv	s4,a1
 620:	8bb2                	mv	s7,a2
  state = 0;
 622:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 624:	4901                	li	s2,0
 626:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 628:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 62c:	06400c13          	li	s8,100
 630:	a00d                	j	652 <vprintf+0x56>
        putc(fd, c0);
 632:	85a6                	mv	a1,s1
 634:	855a                	mv	a0,s6
 636:	f0bff0ef          	jal	540 <putc>
 63a:	a019                	j	640 <vprintf+0x44>
    } else if (state == '%') {
 63c:	03598363          	beq	s3,s5,662 <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 640:	0019079b          	addiw	a5,s2,1
 644:	893e                	mv	s2,a5
 646:	873e                	mv	a4,a5
 648:	97d2                	add	a5,a5,s4
 64a:	0007c483          	lbu	s1,0(a5)
 64e:	1c048a63          	beqz	s1,822 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 652:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 656:	fe0993e3          	bnez	s3,63c <vprintf+0x40>
      if (c0 == '%') {
 65a:	fd579ce3          	bne	a5,s5,632 <vprintf+0x36>
        state = '%';
 65e:	89be                	mv	s3,a5
 660:	b7c5                	j	640 <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 662:	00ea06b3          	add	a3,s4,a4
 666:	0016c603          	lbu	a2,1(a3)
      if (c1)
 66a:	1c060863          	beqz	a2,83a <vprintf+0x23e>
      if (c0 == 'd') {
 66e:	03878763          	beq	a5,s8,69c <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 672:	f9478693          	addi	a3,a5,-108
 676:	0016b693          	seqz	a3,a3
 67a:	f9c60593          	addi	a1,a2,-100
 67e:	e99d                	bnez	a1,6b4 <vprintf+0xb8>
 680:	ca95                	beqz	a3,6b4 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 682:	008b8493          	addi	s1,s7,8
 686:	4685                	li	a3,1
 688:	4629                	li	a2,10
 68a:	000bb583          	ld	a1,0(s7)
 68e:	855a                	mv	a0,s6
 690:	ecfff0ef          	jal	55e <printint>
        i += 1;
 694:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 696:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 698:	4981                	li	s3,0
 69a:	b75d                	j	640 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 69c:	008b8493          	addi	s1,s7,8
 6a0:	4685                	li	a3,1
 6a2:	4629                	li	a2,10
 6a4:	000ba583          	lw	a1,0(s7)
 6a8:	855a                	mv	a0,s6
 6aa:	eb5ff0ef          	jal	55e <printint>
 6ae:	8ba6                	mv	s7,s1
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	b779                	j	640 <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 6b4:	9752                	add	a4,a4,s4
 6b6:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 6ba:	f9460713          	addi	a4,a2,-108
 6be:	00173713          	seqz	a4,a4
 6c2:	8f75                	and	a4,a4,a3
 6c4:	f9c58513          	addi	a0,a1,-100
 6c8:	18051363          	bnez	a0,84e <vprintf+0x252>
 6cc:	18070163          	beqz	a4,84e <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6d0:	008b8493          	addi	s1,s7,8
 6d4:	4685                	li	a3,1
 6d6:	4629                	li	a2,10
 6d8:	000bb583          	ld	a1,0(s7)
 6dc:	855a                	mv	a0,s6
 6de:	e81ff0ef          	jal	55e <printint>
        i += 2;
 6e2:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6e4:	8ba6                	mv	s7,s1
      state = 0;
 6e6:	4981                	li	s3,0
        i += 2;
 6e8:	bfa1                	j	640 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6ea:	008b8493          	addi	s1,s7,8
 6ee:	4681                	li	a3,0
 6f0:	4629                	li	a2,10
 6f2:	000be583          	lwu	a1,0(s7)
 6f6:	855a                	mv	a0,s6
 6f8:	e67ff0ef          	jal	55e <printint>
 6fc:	8ba6                	mv	s7,s1
      state = 0;
 6fe:	4981                	li	s3,0
 700:	b781                	j	640 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 702:	008b8493          	addi	s1,s7,8
 706:	4681                	li	a3,0
 708:	4629                	li	a2,10
 70a:	000bb583          	ld	a1,0(s7)
 70e:	855a                	mv	a0,s6
 710:	e4fff0ef          	jal	55e <printint>
        i += 1;
 714:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 716:	8ba6                	mv	s7,s1
      state = 0;
 718:	4981                	li	s3,0
 71a:	b71d                	j	640 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 71c:	008b8493          	addi	s1,s7,8
 720:	4681                	li	a3,0
 722:	4629                	li	a2,10
 724:	000bb583          	ld	a1,0(s7)
 728:	855a                	mv	a0,s6
 72a:	e35ff0ef          	jal	55e <printint>
        i += 2;
 72e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 730:	8ba6                	mv	s7,s1
      state = 0;
 732:	4981                	li	s3,0
        i += 2;
 734:	b731                	j	640 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 736:	008b8493          	addi	s1,s7,8
 73a:	4681                	li	a3,0
 73c:	4641                	li	a2,16
 73e:	000be583          	lwu	a1,0(s7)
 742:	855a                	mv	a0,s6
 744:	e1bff0ef          	jal	55e <printint>
 748:	8ba6                	mv	s7,s1
      state = 0;
 74a:	4981                	li	s3,0
 74c:	bdd5                	j	640 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 74e:	008b8493          	addi	s1,s7,8
 752:	4681                	li	a3,0
 754:	4641                	li	a2,16
 756:	000bb583          	ld	a1,0(s7)
 75a:	855a                	mv	a0,s6
 75c:	e03ff0ef          	jal	55e <printint>
        i += 1;
 760:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 762:	8ba6                	mv	s7,s1
      state = 0;
 764:	4981                	li	s3,0
 766:	bde9                	j	640 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 768:	008b8493          	addi	s1,s7,8
 76c:	4681                	li	a3,0
 76e:	4641                	li	a2,16
 770:	000bb583          	ld	a1,0(s7)
 774:	855a                	mv	a0,s6
 776:	de9ff0ef          	jal	55e <printint>
        i += 2;
 77a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 77c:	8ba6                	mv	s7,s1
      state = 0;
 77e:	4981                	li	s3,0
        i += 2;
 780:	b5c1                	j	640 <vprintf+0x44>
 782:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 784:	008b8793          	addi	a5,s7,8
 788:	8cbe                	mv	s9,a5
 78a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 78e:	03000593          	li	a1,48
 792:	855a                	mv	a0,s6
 794:	dadff0ef          	jal	540 <putc>
  putc(fd, 'x');
 798:	07800593          	li	a1,120
 79c:	855a                	mv	a0,s6
 79e:	da3ff0ef          	jal	540 <putc>
 7a2:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7a4:	00000b97          	auipc	s7,0x0
 7a8:	54cb8b93          	addi	s7,s7,1356 # cf0 <digits>
 7ac:	03c9d793          	srli	a5,s3,0x3c
 7b0:	97de                	add	a5,a5,s7
 7b2:	0007c583          	lbu	a1,0(a5)
 7b6:	855a                	mv	a0,s6
 7b8:	d89ff0ef          	jal	540 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7bc:	0992                	slli	s3,s3,0x4
 7be:	34fd                	addiw	s1,s1,-1
 7c0:	f4f5                	bnez	s1,7ac <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 7c2:	8be6                	mv	s7,s9
      state = 0;
 7c4:	4981                	li	s3,0
 7c6:	6ca2                	ld	s9,8(sp)
 7c8:	bda5                	j	640 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 7ca:	008b8493          	addi	s1,s7,8
 7ce:	000bc583          	lbu	a1,0(s7)
 7d2:	855a                	mv	a0,s6
 7d4:	d6dff0ef          	jal	540 <putc>
 7d8:	8ba6                	mv	s7,s1
      state = 0;
 7da:	4981                	li	s3,0
 7dc:	b595                	j	640 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 7de:	008b8993          	addi	s3,s7,8
 7e2:	000bb483          	ld	s1,0(s7)
 7e6:	cc91                	beqz	s1,802 <vprintf+0x206>
        for (; *s; s++)
 7e8:	0004c583          	lbu	a1,0(s1)
 7ec:	c985                	beqz	a1,81c <vprintf+0x220>
          putc(fd, *s);
 7ee:	855a                	mv	a0,s6
 7f0:	d51ff0ef          	jal	540 <putc>
        for (; *s; s++)
 7f4:	0485                	addi	s1,s1,1
 7f6:	0004c583          	lbu	a1,0(s1)
 7fa:	f9f5                	bnez	a1,7ee <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 7fc:	8bce                	mv	s7,s3
      state = 0;
 7fe:	4981                	li	s3,0
 800:	b581                	j	640 <vprintf+0x44>
          s = "(null)";
 802:	00000497          	auipc	s1,0x0
 806:	4e648493          	addi	s1,s1,1254 # ce8 <malloc+0x34a>
        for (; *s; s++)
 80a:	02800593          	li	a1,40
 80e:	b7c5                	j	7ee <vprintf+0x1f2>
        putc(fd, '%');
 810:	85be                	mv	a1,a5
 812:	855a                	mv	a0,s6
 814:	d2dff0ef          	jal	540 <putc>
      state = 0;
 818:	4981                	li	s3,0
 81a:	b51d                	j	640 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 81c:	8bce                	mv	s7,s3
      state = 0;
 81e:	4981                	li	s3,0
 820:	b505                	j	640 <vprintf+0x44>
 822:	6906                	ld	s2,64(sp)
 824:	79e2                	ld	s3,56(sp)
 826:	7a42                	ld	s4,48(sp)
 828:	7aa2                	ld	s5,40(sp)
 82a:	7b02                	ld	s6,32(sp)
 82c:	6be2                	ld	s7,24(sp)
 82e:	6c42                	ld	s8,16(sp)
    }
  }
}
 830:	60e6                	ld	ra,88(sp)
 832:	6446                	ld	s0,80(sp)
 834:	64a6                	ld	s1,72(sp)
 836:	6125                	addi	sp,sp,96
 838:	8082                	ret
      if (c0 == 'd') {
 83a:	06400713          	li	a4,100
 83e:	e4e78fe3          	beq	a5,a4,69c <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 842:	f9478693          	addi	a3,a5,-108
 846:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 84a:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 84c:	4701                	li	a4,0
      } else if (c0 == 'u') {
 84e:	07500513          	li	a0,117
 852:	e8a78ce3          	beq	a5,a0,6ea <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 856:	f8b60513          	addi	a0,a2,-117
 85a:	e119                	bnez	a0,860 <vprintf+0x264>
 85c:	ea0693e3          	bnez	a3,702 <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 860:	f8b58513          	addi	a0,a1,-117
 864:	e119                	bnez	a0,86a <vprintf+0x26e>
 866:	ea071be3          	bnez	a4,71c <vprintf+0x120>
      } else if (c0 == 'x') {
 86a:	07800513          	li	a0,120
 86e:	eca784e3          	beq	a5,a0,736 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 872:	f8860613          	addi	a2,a2,-120
 876:	e219                	bnez	a2,87c <vprintf+0x280>
 878:	ec069be3          	bnez	a3,74e <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 87c:	f8858593          	addi	a1,a1,-120
 880:	e199                	bnez	a1,886 <vprintf+0x28a>
 882:	ee0713e3          	bnez	a4,768 <vprintf+0x16c>
      } else if (c0 == 'p') {
 886:	07000713          	li	a4,112
 88a:	eee78ce3          	beq	a5,a4,782 <vprintf+0x186>
      } else if (c0 == 'c') {
 88e:	06300713          	li	a4,99
 892:	f2e78ce3          	beq	a5,a4,7ca <vprintf+0x1ce>
      } else if (c0 == 's') {
 896:	07300713          	li	a4,115
 89a:	f4e782e3          	beq	a5,a4,7de <vprintf+0x1e2>
      } else if (c0 == '%') {
 89e:	02500713          	li	a4,37
 8a2:	f6e787e3          	beq	a5,a4,810 <vprintf+0x214>
        putc(fd, '%');
 8a6:	02500593          	li	a1,37
 8aa:	855a                	mv	a0,s6
 8ac:	c95ff0ef          	jal	540 <putc>
        putc(fd, c0);
 8b0:	85a6                	mv	a1,s1
 8b2:	855a                	mv	a0,s6
 8b4:	c8dff0ef          	jal	540 <putc>
      state = 0;
 8b8:	4981                	li	s3,0
 8ba:	b359                	j	640 <vprintf+0x44>

00000000000008bc <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8bc:	715d                	addi	sp,sp,-80
 8be:	ec06                	sd	ra,24(sp)
 8c0:	e822                	sd	s0,16(sp)
 8c2:	1000                	addi	s0,sp,32
 8c4:	e010                	sd	a2,0(s0)
 8c6:	e414                	sd	a3,8(s0)
 8c8:	e818                	sd	a4,16(s0)
 8ca:	ec1c                	sd	a5,24(s0)
 8cc:	03043023          	sd	a6,32(s0)
 8d0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8d4:	8622                	mv	a2,s0
 8d6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8da:	d23ff0ef          	jal	5fc <vprintf>
}
 8de:	60e2                	ld	ra,24(sp)
 8e0:	6442                	ld	s0,16(sp)
 8e2:	6161                	addi	sp,sp,80
 8e4:	8082                	ret

00000000000008e6 <printf>:

void
printf(const char *fmt, ...)
{
 8e6:	711d                	addi	sp,sp,-96
 8e8:	ec06                	sd	ra,24(sp)
 8ea:	e822                	sd	s0,16(sp)
 8ec:	1000                	addi	s0,sp,32
 8ee:	e40c                	sd	a1,8(s0)
 8f0:	e810                	sd	a2,16(s0)
 8f2:	ec14                	sd	a3,24(s0)
 8f4:	f018                	sd	a4,32(s0)
 8f6:	f41c                	sd	a5,40(s0)
 8f8:	03043823          	sd	a6,48(s0)
 8fc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 900:	00840613          	addi	a2,s0,8
 904:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 908:	85aa                	mv	a1,a0
 90a:	4505                	li	a0,1
 90c:	cf1ff0ef          	jal	5fc <vprintf>
}
 910:	60e2                	ld	ra,24(sp)
 912:	6442                	ld	s0,16(sp)
 914:	6125                	addi	sp,sp,96
 916:	8082                	ret

0000000000000918 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 918:	1141                	addi	sp,sp,-16
 91a:	e406                	sd	ra,8(sp)
 91c:	e022                	sd	s0,0(sp)
 91e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 920:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 924:	00001797          	auipc	a5,0x1
 928:	6dc7b783          	ld	a5,1756(a5) # 2000 <freep>
 92c:	a039                	j	93a <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 92e:	6398                	ld	a4,0(a5)
 930:	00e7e463          	bltu	a5,a4,938 <free+0x20>
 934:	00e6ea63          	bltu	a3,a4,948 <free+0x30>
{
 938:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 93a:	fed7fae3          	bgeu	a5,a3,92e <free+0x16>
 93e:	6398                	ld	a4,0(a5)
 940:	00e6e463          	bltu	a3,a4,948 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 944:	fee7eae3          	bltu	a5,a4,938 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 948:	ff852583          	lw	a1,-8(a0)
 94c:	6390                	ld	a2,0(a5)
 94e:	02059813          	slli	a6,a1,0x20
 952:	01c85713          	srli	a4,a6,0x1c
 956:	9736                	add	a4,a4,a3
 958:	02e60563          	beq	a2,a4,982 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 95c:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 960:	4790                	lw	a2,8(a5)
 962:	02061593          	slli	a1,a2,0x20
 966:	01c5d713          	srli	a4,a1,0x1c
 96a:	973e                	add	a4,a4,a5
 96c:	02e68263          	beq	a3,a4,990 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 970:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 972:	00001717          	auipc	a4,0x1
 976:	68f73723          	sd	a5,1678(a4) # 2000 <freep>
}
 97a:	60a2                	ld	ra,8(sp)
 97c:	6402                	ld	s0,0(sp)
 97e:	0141                	addi	sp,sp,16
 980:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 982:	4618                	lw	a4,8(a2)
 984:	9f2d                	addw	a4,a4,a1
 986:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 98a:	6398                	ld	a4,0(a5)
 98c:	6310                	ld	a2,0(a4)
 98e:	b7f9                	j	95c <free+0x44>
    p->s.size += bp->s.size;
 990:	ff852703          	lw	a4,-8(a0)
 994:	9f31                	addw	a4,a4,a2
 996:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 998:	ff053683          	ld	a3,-16(a0)
 99c:	bfd1                	j	970 <free+0x58>

000000000000099e <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 99e:	7139                	addi	sp,sp,-64
 9a0:	fc06                	sd	ra,56(sp)
 9a2:	f822                	sd	s0,48(sp)
 9a4:	f04a                	sd	s2,32(sp)
 9a6:	ec4e                	sd	s3,24(sp)
 9a8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 9aa:	02051993          	slli	s3,a0,0x20
 9ae:	0209d993          	srli	s3,s3,0x20
 9b2:	09bd                	addi	s3,s3,15
 9b4:	0049d993          	srli	s3,s3,0x4
 9b8:	2985                	addiw	s3,s3,1
 9ba:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 9bc:	00001517          	auipc	a0,0x1
 9c0:	64453503          	ld	a0,1604(a0) # 2000 <freep>
 9c4:	c905                	beqz	a0,9f4 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 9c6:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 9c8:	4798                	lw	a4,8(a5)
 9ca:	09377663          	bgeu	a4,s3,a56 <malloc+0xb8>
 9ce:	f426                	sd	s1,40(sp)
 9d0:	e852                	sd	s4,16(sp)
 9d2:	e456                	sd	s5,8(sp)
 9d4:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 9d6:	8a4e                	mv	s4,s3
 9d8:	6705                	lui	a4,0x1
 9da:	00e9f363          	bgeu	s3,a4,9e0 <malloc+0x42>
 9de:	6a05                	lui	s4,0x1
 9e0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9e4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 9e8:	00001497          	auipc	s1,0x1
 9ec:	61848493          	addi	s1,s1,1560 # 2000 <freep>
  if (p == SBRK_ERROR)
 9f0:	5afd                	li	s5,-1
 9f2:	a83d                	j	a30 <malloc+0x92>
 9f4:	f426                	sd	s1,40(sp)
 9f6:	e852                	sd	s4,16(sp)
 9f8:	e456                	sd	s5,8(sp)
 9fa:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9fc:	00001797          	auipc	a5,0x1
 a00:	61478793          	addi	a5,a5,1556 # 2010 <base>
 a04:	00001717          	auipc	a4,0x1
 a08:	5ef73e23          	sd	a5,1532(a4) # 2000 <freep>
 a0c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a0e:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 a12:	b7d1                	j	9d6 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 a14:	6398                	ld	a4,0(a5)
 a16:	e118                	sd	a4,0(a0)
 a18:	a899                	j	a6e <malloc+0xd0>
  hp->s.size = nu;
 a1a:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 a1e:	0541                	addi	a0,a0,16
 a20:	ef9ff0ef          	jal	918 <free>
  return freep;
 a24:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 a26:	c125                	beqz	a0,a86 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 a28:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 a2a:	4798                	lw	a4,8(a5)
 a2c:	03277163          	bgeu	a4,s2,a4e <malloc+0xb0>
    if (p == freep)
 a30:	6098                	ld	a4,0(s1)
 a32:	853e                	mv	a0,a5
 a34:	fef71ae3          	bne	a4,a5,a28 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 a38:	8552                	mv	a0,s4
 a3a:	a23ff0ef          	jal	45c <sbrk>
  if (p == SBRK_ERROR)
 a3e:	fd551ee3          	bne	a0,s5,a1a <malloc+0x7c>
        return 0;
 a42:	4501                	li	a0,0
 a44:	74a2                	ld	s1,40(sp)
 a46:	6a42                	ld	s4,16(sp)
 a48:	6aa2                	ld	s5,8(sp)
 a4a:	6b02                	ld	s6,0(sp)
 a4c:	a03d                	j	a7a <malloc+0xdc>
 a4e:	74a2                	ld	s1,40(sp)
 a50:	6a42                	ld	s4,16(sp)
 a52:	6aa2                	ld	s5,8(sp)
 a54:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 a56:	fae90fe3          	beq	s2,a4,a14 <malloc+0x76>
        p->s.size -= nunits;
 a5a:	4137073b          	subw	a4,a4,s3
 a5e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a60:	02071693          	slli	a3,a4,0x20
 a64:	01c6d713          	srli	a4,a3,0x1c
 a68:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a6a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a6e:	00001717          	auipc	a4,0x1
 a72:	58a73923          	sd	a0,1426(a4) # 2000 <freep>
      return (void *)(p + 1);
 a76:	01078513          	addi	a0,a5,16
  }
}
 a7a:	70e2                	ld	ra,56(sp)
 a7c:	7442                	ld	s0,48(sp)
 a7e:	7902                	ld	s2,32(sp)
 a80:	69e2                	ld	s3,24(sp)
 a82:	6121                	addi	sp,sp,64
 a84:	8082                	ret
 a86:	74a2                	ld	s1,40(sp)
 a88:	6a42                	ld	s4,16(sp)
 a8a:	6aa2                	ld	s5,8(sp)
 a8c:	6b02                	ld	s6,0(sp)
 a8e:	b7f5                	j	a7a <malloc+0xdc>
