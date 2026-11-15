
user/_mlfqtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	0880                	addi	s0,sp,80
  printf("--- Multilevel Feedback Queue (MLFQ) Scheduler Test ---\n");
   8:	00001517          	auipc	a0,0x1
   c:	a9850513          	addi	a0,a0,-1384 # aa0 <malloc+0xf4>
  10:	0e5000ef          	jal	8f4 <printf>
  printf("Parent PID: %d\n", getpid());
  14:	50a000ef          	jal	51e <getpid>
  18:	85aa                	mv	a1,a0
  1a:	00001517          	auipc	a0,0x1
  1e:	ac650513          	addi	a0,a0,-1338 # ae0 <malloc+0x134>
  22:	0d3000ef          	jal	8f4 <printf>
  printf("Forking CPU-bound process (demotes to level 2) and I/O-bound process (remains at level 0)...\n\n");
  26:	00001517          	auipc	a0,0x1
  2a:	aca50513          	addi	a0,a0,-1334 # af0 <malloc+0x144>
  2e:	0c7000ef          	jal	8f4 <printf>

  int pid_cpu = fork();
  32:	464000ef          	jal	496 <fork>
  if (pid_cpu < 0) {
  36:	0a054a63          	bltz	a0,ea <main+0xea>
  3a:	fc26                	sd	s1,56(sp)
  3c:	f84a                	sd	s2,48(sp)
  3e:	f44e                	sd	s3,40(sp)
  40:	f052                	sd	s4,32(sp)
  42:	ec56                	sd	s5,24(sp)
  44:	e85a                	sd	s6,16(sp)
    printf("Fork failed!\n");
    exit(1);
  }

  if (pid_cpu == 0) {
  46:	e169                	bnez	a0,108 <main+0x108>
    // CPU-bound child: performs continuous computation without yielding
    int my_pid = getpid();
  48:	4d6000ef          	jal	51e <getpid>
  4c:	89aa                	mv	s3,a0
    printf("[CPU-bound | PID %d] Initial Queue Level: %d (uptime: %d)\n",
  4e:	4f8000ef          	jal	546 <get_queue>
  52:	84aa                	mv	s1,a0
  54:	4e2000ef          	jal	536 <uptime>
  58:	86aa                	mv	a3,a0
  5a:	8626                	mv	a2,s1
  5c:	85ce                	mv	a1,s3
  5e:	00001517          	auipc	a0,0x1
  62:	b0250513          	addi	a0,a0,-1278 # b60 <malloc+0x1b4>
  66:	08f000ef          	jal	8f4 <printf>
           my_pid, get_queue(my_pid), uptime());

    volatile uint64 counter = 0;
  6a:	fa043823          	sd	zero,-80(s0)
    for (int step = 1; step <= 3; step++) {
  6e:	4905                	li	s2,1
      for (volatile uint64 j = 0; j < 40000000ULL; j++) {
  70:	026264b7          	lui	s1,0x2626
  74:	9ff48493          	addi	s1,s1,-1537 # 26259ff <base+0x26239ef>
        counter += j;
      }
      printf("[CPU-bound | PID %d] After Step %d computation: Queue Level = %d (uptime: %d)\n",
  78:	00001a97          	auipc	s5,0x1
  7c:	b28a8a93          	addi	s5,s5,-1240 # ba0 <malloc+0x1f4>
    for (int step = 1; step <= 3; step++) {
  80:	4a11                	li	s4,4
      for (volatile uint64 j = 0; j < 40000000ULL; j++) {
  82:	fa043c23          	sd	zero,-72(s0)
  86:	fb843783          	ld	a5,-72(s0)
  8a:	02f4e263          	bltu	s1,a5,ae <main+0xae>
        counter += j;
  8e:	fb843703          	ld	a4,-72(s0)
  92:	fb043783          	ld	a5,-80(s0)
  96:	97ba                	add	a5,a5,a4
  98:	faf43823          	sd	a5,-80(s0)
      for (volatile uint64 j = 0; j < 40000000ULL; j++) {
  9c:	fb843783          	ld	a5,-72(s0)
  a0:	0785                	addi	a5,a5,1
  a2:	faf43c23          	sd	a5,-72(s0)
  a6:	fb843783          	ld	a5,-72(s0)
  aa:	fef4f2e3          	bgeu	s1,a5,8e <main+0x8e>
      printf("[CPU-bound | PID %d] After Step %d computation: Queue Level = %d (uptime: %d)\n",
  ae:	854e                	mv	a0,s3
  b0:	496000ef          	jal	546 <get_queue>
  b4:	8b2a                	mv	s6,a0
  b6:	480000ef          	jal	536 <uptime>
  ba:	872a                	mv	a4,a0
  bc:	86da                	mv	a3,s6
  be:	864a                	mv	a2,s2
  c0:	85ce                	mv	a1,s3
  c2:	8556                	mv	a0,s5
  c4:	031000ef          	jal	8f4 <printf>
    for (int step = 1; step <= 3; step++) {
  c8:	2905                	addiw	s2,s2,1
  ca:	fb491ce3          	bne	s2,s4,82 <main+0x82>
             my_pid, step, get_queue(my_pid), uptime());
    }

    printf("[CPU-bound | PID %d] Final Queue Level = %d (successfully sank to lowest queue!)\n",
  ce:	854e                	mv	a0,s3
  d0:	476000ef          	jal	546 <get_queue>
  d4:	862a                	mv	a2,a0
  d6:	85ce                	mv	a1,s3
  d8:	00001517          	auipc	a0,0x1
  dc:	b1850513          	addi	a0,a0,-1256 # bf0 <malloc+0x244>
  e0:	015000ef          	jal	8f4 <printf>
           my_pid, get_queue(my_pid));
    exit(0);
  e4:	4501                	li	a0,0
  e6:	3b8000ef          	jal	49e <exit>
  ea:	fc26                	sd	s1,56(sp)
  ec:	f84a                	sd	s2,48(sp)
  ee:	f44e                	sd	s3,40(sp)
  f0:	f052                	sd	s4,32(sp)
  f2:	ec56                	sd	s5,24(sp)
  f4:	e85a                	sd	s6,16(sp)
    printf("Fork failed!\n");
  f6:	00001517          	auipc	a0,0x1
  fa:	a5a50513          	addi	a0,a0,-1446 # b50 <malloc+0x1a4>
  fe:	7f6000ef          	jal	8f4 <printf>
    exit(1);
 102:	4505                	li	a0,1
 104:	39a000ef          	jal	49e <exit>
  }

  int pid_io = fork();
 108:	38e000ef          	jal	496 <fork>
  if (pid_io < 0) {
 10c:	0a054663          	bltz	a0,1b8 <main+0x1b8>
    printf("Fork failed!\n");
    exit(1);
  }

  if (pid_io == 0) {
 110:	ed4d                	bnez	a0,1ca <main+0x1ca>
    // I/O-bound child: frequently calls pause(1) (sleeps) before exhausting quantum
    int my_pid = getpid();
 112:	40c000ef          	jal	51e <getpid>
 116:	89aa                	mv	s3,a0
    printf("[I/O-bound | PID %d] Initial Queue Level: %d (uptime: %d)\n",
 118:	42e000ef          	jal	546 <get_queue>
 11c:	84aa                	mv	s1,a0
 11e:	418000ef          	jal	536 <uptime>
 122:	86aa                	mv	a3,a0
 124:	8626                	mv	a2,s1
 126:	85ce                	mv	a1,s3
 128:	00001517          	auipc	a0,0x1
 12c:	b2050513          	addi	a0,a0,-1248 # c48 <malloc+0x29c>
 130:	7c4000ef          	jal	8f4 <printf>
           my_pid, get_queue(my_pid), uptime());

    for (int step = 1; step <= 5; step++) {
 134:	4905                	li	s2,1
      // Simulate I/O burst by sleeping 1 tick
      pause(1);
 136:	8b4a                	mv	s6,s2
      // Small computation
      volatile uint64 counter = 0;
      for (volatile int j = 0; j < 1000000; j++) {
 138:	000f44b7          	lui	s1,0xf4
 13c:	23f48493          	addi	s1,s1,575 # f423f <base+0xf222f>
        counter += j;
      }
      printf("[I/O-bound | PID %d] After Step %d I/O burst: Queue Level = %d (remains at high priority!)\n",
 140:	00001a97          	auipc	s5,0x1
 144:	b48a8a93          	addi	s5,s5,-1208 # c88 <malloc+0x2dc>
    for (int step = 1; step <= 5; step++) {
 148:	4a19                	li	s4,6
      pause(1);
 14a:	855a                	mv	a0,s6
 14c:	3e2000ef          	jal	52e <pause>
      volatile uint64 counter = 0;
 150:	fa043c23          	sd	zero,-72(s0)
      for (volatile int j = 0; j < 1000000; j++) {
 154:	fa042823          	sw	zero,-80(s0)
 158:	fb042783          	lw	a5,-80(s0)
 15c:	2781                	sext.w	a5,a5
 15e:	02f4c363          	blt	s1,a5,184 <main+0x184>
        counter += j;
 162:	fb042783          	lw	a5,-80(s0)
 166:	fb843703          	ld	a4,-72(s0)
 16a:	97ba                	add	a5,a5,a4
 16c:	faf43c23          	sd	a5,-72(s0)
      for (volatile int j = 0; j < 1000000; j++) {
 170:	fb042783          	lw	a5,-80(s0)
 174:	2785                	addiw	a5,a5,1
 176:	faf42823          	sw	a5,-80(s0)
 17a:	fb042783          	lw	a5,-80(s0)
 17e:	2781                	sext.w	a5,a5
 180:	fef4d1e3          	bge	s1,a5,162 <main+0x162>
      printf("[I/O-bound | PID %d] After Step %d I/O burst: Queue Level = %d (remains at high priority!)\n",
 184:	854e                	mv	a0,s3
 186:	3c0000ef          	jal	546 <get_queue>
 18a:	86aa                	mv	a3,a0
 18c:	864a                	mv	a2,s2
 18e:	85ce                	mv	a1,s3
 190:	8556                	mv	a0,s5
 192:	762000ef          	jal	8f4 <printf>
    for (int step = 1; step <= 5; step++) {
 196:	2905                	addiw	s2,s2,1
 198:	fb4919e3          	bne	s2,s4,14a <main+0x14a>
             my_pid, step, get_queue(my_pid));
    }

    printf("[I/O-bound | PID %d] Final Queue Level = %d (retained top priority!)\n",
 19c:	854e                	mv	a0,s3
 19e:	3a8000ef          	jal	546 <get_queue>
 1a2:	862a                	mv	a2,a0
 1a4:	85ce                	mv	a1,s3
 1a6:	00001517          	auipc	a0,0x1
 1aa:	b4250513          	addi	a0,a0,-1214 # ce8 <malloc+0x33c>
 1ae:	746000ef          	jal	8f4 <printf>
           my_pid, get_queue(my_pid));
    exit(0);
 1b2:	4501                	li	a0,0
 1b4:	2ea000ef          	jal	49e <exit>
    printf("Fork failed!\n");
 1b8:	00001517          	auipc	a0,0x1
 1bc:	99850513          	addi	a0,a0,-1640 # b50 <malloc+0x1a4>
 1c0:	734000ef          	jal	8f4 <printf>
    exit(1);
 1c4:	4505                	li	a0,1
 1c6:	2d8000ef          	jal	49e <exit>
  }

  // Parent waits for both children
  wait(0);
 1ca:	4501                	li	a0,0
 1cc:	2da000ef          	jal	4a6 <wait>
  wait(0);
 1d0:	4501                	li	a0,0
 1d2:	2d4000ef          	jal	4a6 <wait>

  printf("\n--- MLFQ Test Passed: CPU-bound sank to lowest queue; I/O process remained in top queue! ---\n");
 1d6:	00001517          	auipc	a0,0x1
 1da:	b5a50513          	addi	a0,a0,-1190 # d30 <malloc+0x384>
 1de:	716000ef          	jal	8f4 <printf>
  exit(0);
 1e2:	4501                	li	a0,0
 1e4:	2ba000ef          	jal	49e <exit>

00000000000001e8 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1e8:	1141                	addi	sp,sp,-16
 1ea:	e406                	sd	ra,8(sp)
 1ec:	e022                	sd	s0,0(sp)
 1ee:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1f0:	e11ff0ef          	jal	0 <main>
  exit(r);
 1f4:	2aa000ef          	jal	49e <exit>

00000000000001f8 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 1f8:	1141                	addi	sp,sp,-16
 1fa:	e406                	sd	ra,8(sp)
 1fc:	e022                	sd	s0,0(sp)
 1fe:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 200:	87aa                	mv	a5,a0
 202:	0585                	addi	a1,a1,1
 204:	0785                	addi	a5,a5,1
 206:	fff5c703          	lbu	a4,-1(a1)
 20a:	fee78fa3          	sb	a4,-1(a5)
 20e:	fb75                	bnez	a4,202 <strcpy+0xa>
    ;
  return os;
}
 210:	60a2                	ld	ra,8(sp)
 212:	6402                	ld	s0,0(sp)
 214:	0141                	addi	sp,sp,16
 216:	8082                	ret

0000000000000218 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 218:	1141                	addi	sp,sp,-16
 21a:	e406                	sd	ra,8(sp)
 21c:	e022                	sd	s0,0(sp)
 21e:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 220:	00054783          	lbu	a5,0(a0)
 224:	cb91                	beqz	a5,238 <strcmp+0x20>
 226:	0005c703          	lbu	a4,0(a1)
 22a:	00f71763          	bne	a4,a5,238 <strcmp+0x20>
    p++, q++;
 22e:	0505                	addi	a0,a0,1
 230:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 232:	00054783          	lbu	a5,0(a0)
 236:	fbe5                	bnez	a5,226 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 238:	0005c503          	lbu	a0,0(a1)
}
 23c:	40a7853b          	subw	a0,a5,a0
 240:	60a2                	ld	ra,8(sp)
 242:	6402                	ld	s0,0(sp)
 244:	0141                	addi	sp,sp,16
 246:	8082                	ret

0000000000000248 <strlen>:

uint
strlen(const char *s)
{
 248:	1141                	addi	sp,sp,-16
 24a:	e406                	sd	ra,8(sp)
 24c:	e022                	sd	s0,0(sp)
 24e:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 250:	00054783          	lbu	a5,0(a0)
 254:	cf91                	beqz	a5,270 <strlen+0x28>
 256:	00150793          	addi	a5,a0,1
 25a:	86be                	mv	a3,a5
 25c:	0785                	addi	a5,a5,1
 25e:	fff7c703          	lbu	a4,-1(a5)
 262:	ff65                	bnez	a4,25a <strlen+0x12>
 264:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 268:	60a2                	ld	ra,8(sp)
 26a:	6402                	ld	s0,0(sp)
 26c:	0141                	addi	sp,sp,16
 26e:	8082                	ret
  for (n = 0; s[n]; n++)
 270:	4501                	li	a0,0
 272:	bfdd                	j	268 <strlen+0x20>

0000000000000274 <memset>:

void *
memset(void *dst, int c, uint n)
{
 274:	1141                	addi	sp,sp,-16
 276:	e406                	sd	ra,8(sp)
 278:	e022                	sd	s0,0(sp)
 27a:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 27c:	ca19                	beqz	a2,292 <memset+0x1e>
 27e:	87aa                	mv	a5,a0
 280:	1602                	slli	a2,a2,0x20
 282:	9201                	srli	a2,a2,0x20
 284:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 288:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 28c:	0785                	addi	a5,a5,1
 28e:	fee79de3          	bne	a5,a4,288 <memset+0x14>
  }
  return dst;
}
 292:	60a2                	ld	ra,8(sp)
 294:	6402                	ld	s0,0(sp)
 296:	0141                	addi	sp,sp,16
 298:	8082                	ret

000000000000029a <strchr>:

char *
strchr(const char *s, char c)
{
 29a:	1141                	addi	sp,sp,-16
 29c:	e406                	sd	ra,8(sp)
 29e:	e022                	sd	s0,0(sp)
 2a0:	0800                	addi	s0,sp,16
  for (; *s; s++)
 2a2:	00054783          	lbu	a5,0(a0)
 2a6:	cf81                	beqz	a5,2be <strchr+0x24>
    if (*s == c)
 2a8:	00f58763          	beq	a1,a5,2b6 <strchr+0x1c>
  for (; *s; s++)
 2ac:	0505                	addi	a0,a0,1
 2ae:	00054783          	lbu	a5,0(a0)
 2b2:	fbfd                	bnez	a5,2a8 <strchr+0xe>
      return (char *)s;
  return 0;
 2b4:	4501                	li	a0,0
}
 2b6:	60a2                	ld	ra,8(sp)
 2b8:	6402                	ld	s0,0(sp)
 2ba:	0141                	addi	sp,sp,16
 2bc:	8082                	ret
  return 0;
 2be:	4501                	li	a0,0
 2c0:	bfdd                	j	2b6 <strchr+0x1c>

00000000000002c2 <gets>:

char *
gets(char *buf, int max)
{
 2c2:	711d                	addi	sp,sp,-96
 2c4:	ec86                	sd	ra,88(sp)
 2c6:	e8a2                	sd	s0,80(sp)
 2c8:	e4a6                	sd	s1,72(sp)
 2ca:	e0ca                	sd	s2,64(sp)
 2cc:	fc4e                	sd	s3,56(sp)
 2ce:	f852                	sd	s4,48(sp)
 2d0:	f456                	sd	s5,40(sp)
 2d2:	f05a                	sd	s6,32(sp)
 2d4:	ec5e                	sd	s7,24(sp)
 2d6:	e862                	sd	s8,16(sp)
 2d8:	1080                	addi	s0,sp,96
 2da:	8baa                	mv	s7,a0
 2dc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 2de:	892a                	mv	s2,a0
 2e0:	4481                	li	s1,0
    cc = read(0, &c, 1);
 2e2:	faf40b13          	addi	s6,s0,-81
 2e6:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 2e8:	8c26                	mv	s8,s1
 2ea:	0014899b          	addiw	s3,s1,1
 2ee:	84ce                	mv	s1,s3
 2f0:	0349d463          	bge	s3,s4,318 <gets+0x56>
    cc = read(0, &c, 1);
 2f4:	8656                	mv	a2,s5
 2f6:	85da                	mv	a1,s6
 2f8:	4501                	li	a0,0
 2fa:	1bc000ef          	jal	4b6 <read>
    if (cc < 1)
 2fe:	00a05d63          	blez	a0,318 <gets+0x56>
      break;
    buf[i++] = c;
 302:	faf44783          	lbu	a5,-81(s0)
 306:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 30a:	0905                	addi	s2,s2,1
 30c:	ff678713          	addi	a4,a5,-10
 310:	c319                	beqz	a4,316 <gets+0x54>
 312:	17cd                	addi	a5,a5,-13
 314:	fbf1                	bnez	a5,2e8 <gets+0x26>
    buf[i++] = c;
 316:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 318:	9c5e                	add	s8,s8,s7
 31a:	000c0023          	sb	zero,0(s8)
  return buf;
}
 31e:	855e                	mv	a0,s7
 320:	60e6                	ld	ra,88(sp)
 322:	6446                	ld	s0,80(sp)
 324:	64a6                	ld	s1,72(sp)
 326:	6906                	ld	s2,64(sp)
 328:	79e2                	ld	s3,56(sp)
 32a:	7a42                	ld	s4,48(sp)
 32c:	7aa2                	ld	s5,40(sp)
 32e:	7b02                	ld	s6,32(sp)
 330:	6be2                	ld	s7,24(sp)
 332:	6c42                	ld	s8,16(sp)
 334:	6125                	addi	sp,sp,96
 336:	8082                	ret

0000000000000338 <stat>:

int
stat(const char *n, struct stat *st)
{
 338:	1101                	addi	sp,sp,-32
 33a:	ec06                	sd	ra,24(sp)
 33c:	e822                	sd	s0,16(sp)
 33e:	e04a                	sd	s2,0(sp)
 340:	1000                	addi	s0,sp,32
 342:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 344:	4581                	li	a1,0
 346:	198000ef          	jal	4de <open>
  if (fd < 0)
 34a:	02054263          	bltz	a0,36e <stat+0x36>
 34e:	e426                	sd	s1,8(sp)
 350:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 352:	85ca                	mv	a1,s2
 354:	1a2000ef          	jal	4f6 <fstat>
 358:	892a                	mv	s2,a0
  close(fd);
 35a:	8526                	mv	a0,s1
 35c:	16a000ef          	jal	4c6 <close>
  return r;
 360:	64a2                	ld	s1,8(sp)
}
 362:	854a                	mv	a0,s2
 364:	60e2                	ld	ra,24(sp)
 366:	6442                	ld	s0,16(sp)
 368:	6902                	ld	s2,0(sp)
 36a:	6105                	addi	sp,sp,32
 36c:	8082                	ret
    return -1;
 36e:	57fd                	li	a5,-1
 370:	893e                	mv	s2,a5
 372:	bfc5                	j	362 <stat+0x2a>

0000000000000374 <atoi>:

int
atoi(const char *s)
{
 374:	1141                	addi	sp,sp,-16
 376:	e406                	sd	ra,8(sp)
 378:	e022                	sd	s0,0(sp)
 37a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 37c:	00054683          	lbu	a3,0(a0)
 380:	fd06879b          	addiw	a5,a3,-48
 384:	0ff7f793          	zext.b	a5,a5
 388:	4625                	li	a2,9
 38a:	02f66963          	bltu	a2,a5,3bc <atoi+0x48>
 38e:	872a                	mv	a4,a0
  n = 0;
 390:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 392:	0705                	addi	a4,a4,1
 394:	0025179b          	slliw	a5,a0,0x2
 398:	9fa9                	addw	a5,a5,a0
 39a:	0017979b          	slliw	a5,a5,0x1
 39e:	9fb5                	addw	a5,a5,a3
 3a0:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 3a4:	00074683          	lbu	a3,0(a4)
 3a8:	fd06879b          	addiw	a5,a3,-48
 3ac:	0ff7f793          	zext.b	a5,a5
 3b0:	fef671e3          	bgeu	a2,a5,392 <atoi+0x1e>
  return n;
}
 3b4:	60a2                	ld	ra,8(sp)
 3b6:	6402                	ld	s0,0(sp)
 3b8:	0141                	addi	sp,sp,16
 3ba:	8082                	ret
  n = 0;
 3bc:	4501                	li	a0,0
 3be:	bfdd                	j	3b4 <atoi+0x40>

00000000000003c0 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 3c0:	1141                	addi	sp,sp,-16
 3c2:	e406                	sd	ra,8(sp)
 3c4:	e022                	sd	s0,0(sp)
 3c6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3c8:	02b57563          	bgeu	a0,a1,3f2 <memmove+0x32>
    while (n-- > 0)
 3cc:	00c05f63          	blez	a2,3ea <memmove+0x2a>
 3d0:	1602                	slli	a2,a2,0x20
 3d2:	9201                	srli	a2,a2,0x20
 3d4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3d8:	872a                	mv	a4,a0
      *dst++ = *src++;
 3da:	0585                	addi	a1,a1,1
 3dc:	0705                	addi	a4,a4,1
 3de:	fff5c683          	lbu	a3,-1(a1)
 3e2:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 3e6:	fee79ae3          	bne	a5,a4,3da <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3ea:	60a2                	ld	ra,8(sp)
 3ec:	6402                	ld	s0,0(sp)
 3ee:	0141                	addi	sp,sp,16
 3f0:	8082                	ret
    while (n-- > 0)
 3f2:	fec05ce3          	blez	a2,3ea <memmove+0x2a>
    dst += n;
 3f6:	00c50733          	add	a4,a0,a2
    src += n;
 3fa:	95b2                	add	a1,a1,a2
 3fc:	fff6079b          	addiw	a5,a2,-1
 400:	1782                	slli	a5,a5,0x20
 402:	9381                	srli	a5,a5,0x20
 404:	fff7c793          	not	a5,a5
 408:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 40a:	15fd                	addi	a1,a1,-1
 40c:	177d                	addi	a4,a4,-1
 40e:	0005c683          	lbu	a3,0(a1)
 412:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 416:	fef71ae3          	bne	a4,a5,40a <memmove+0x4a>
 41a:	bfc1                	j	3ea <memmove+0x2a>

000000000000041c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 41c:	1141                	addi	sp,sp,-16
 41e:	e406                	sd	ra,8(sp)
 420:	e022                	sd	s0,0(sp)
 422:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 424:	c61d                	beqz	a2,452 <memcmp+0x36>
 426:	1602                	slli	a2,a2,0x20
 428:	9201                	srli	a2,a2,0x20
 42a:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 42e:	00054783          	lbu	a5,0(a0)
 432:	0005c703          	lbu	a4,0(a1)
 436:	00e79863          	bne	a5,a4,446 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 43a:	0505                	addi	a0,a0,1
    p2++;
 43c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 43e:	fed518e3          	bne	a0,a3,42e <memcmp+0x12>
  }
  return 0;
 442:	4501                	li	a0,0
 444:	a019                	j	44a <memcmp+0x2e>
      return *p1 - *p2;
 446:	40e7853b          	subw	a0,a5,a4
}
 44a:	60a2                	ld	ra,8(sp)
 44c:	6402                	ld	s0,0(sp)
 44e:	0141                	addi	sp,sp,16
 450:	8082                	ret
  return 0;
 452:	4501                	li	a0,0
 454:	bfdd                	j	44a <memcmp+0x2e>

0000000000000456 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 456:	1141                	addi	sp,sp,-16
 458:	e406                	sd	ra,8(sp)
 45a:	e022                	sd	s0,0(sp)
 45c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 45e:	f63ff0ef          	jal	3c0 <memmove>
}
 462:	60a2                	ld	ra,8(sp)
 464:	6402                	ld	s0,0(sp)
 466:	0141                	addi	sp,sp,16
 468:	8082                	ret

000000000000046a <sbrk>:

char *
sbrk(int n)
{
 46a:	1141                	addi	sp,sp,-16
 46c:	e406                	sd	ra,8(sp)
 46e:	e022                	sd	s0,0(sp)
 470:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 472:	4585                	li	a1,1
 474:	0b2000ef          	jal	526 <sys_sbrk>
}
 478:	60a2                	ld	ra,8(sp)
 47a:	6402                	ld	s0,0(sp)
 47c:	0141                	addi	sp,sp,16
 47e:	8082                	ret

0000000000000480 <sbrklazy>:

char *
sbrklazy(int n)
{
 480:	1141                	addi	sp,sp,-16
 482:	e406                	sd	ra,8(sp)
 484:	e022                	sd	s0,0(sp)
 486:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 488:	4589                	li	a1,2
 48a:	09c000ef          	jal	526 <sys_sbrk>
}
 48e:	60a2                	ld	ra,8(sp)
 490:	6402                	ld	s0,0(sp)
 492:	0141                	addi	sp,sp,16
 494:	8082                	ret

0000000000000496 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 496:	4885                	li	a7,1
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <exit>:
.global exit
exit:
 li a7, SYS_exit
 49e:	4889                	li	a7,2
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4a6:	488d                	li	a7,3
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4ae:	4891                	li	a7,4
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <read>:
.global read
read:
 li a7, SYS_read
 4b6:	4895                	li	a7,5
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <write>:
.global write
write:
 li a7, SYS_write
 4be:	48c1                	li	a7,16
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <close>:
.global close
close:
 li a7, SYS_close
 4c6:	48d5                	li	a7,21
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <kill>:
.global kill
kill:
 li a7, SYS_kill
 4ce:	4899                	li	a7,6
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4d6:	489d                	li	a7,7
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <open>:
.global open
open:
 li a7, SYS_open
 4de:	48bd                	li	a7,15
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4e6:	48c5                	li	a7,17
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4ee:	48c9                	li	a7,18
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4f6:	48a1                	li	a7,8
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <link>:
.global link
link:
 li a7, SYS_link
 4fe:	48cd                	li	a7,19
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 506:	48d1                	li	a7,20
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 50e:	48a5                	li	a7,9
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <dup>:
.global dup
dup:
 li a7, SYS_dup
 516:	48a9                	li	a7,10
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 51e:	48ad                	li	a7,11
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 526:	48b1                	li	a7,12
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <pause>:
.global pause
pause:
 li a7, SYS_pause
 52e:	48b5                	li	a7,13
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 536:	48b9                	li	a7,14
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <sync>:
.global sync
sync:
 li a7, SYS_sync
 53e:	48d9                	li	a7,22
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <get_queue>:
.global get_queue
get_queue:
 li a7, SYS_get_queue
 546:	48dd                	li	a7,23
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 54e:	1101                	addi	sp,sp,-32
 550:	ec06                	sd	ra,24(sp)
 552:	e822                	sd	s0,16(sp)
 554:	1000                	addi	s0,sp,32
 556:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 55a:	4605                	li	a2,1
 55c:	fef40593          	addi	a1,s0,-17
 560:	f5fff0ef          	jal	4be <write>
}
 564:	60e2                	ld	ra,24(sp)
 566:	6442                	ld	s0,16(sp)
 568:	6105                	addi	sp,sp,32
 56a:	8082                	ret

000000000000056c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 56c:	715d                	addi	sp,sp,-80
 56e:	e486                	sd	ra,72(sp)
 570:	e0a2                	sd	s0,64(sp)
 572:	f84a                	sd	s2,48(sp)
 574:	f44e                	sd	s3,40(sp)
 576:	0880                	addi	s0,sp,80
 578:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 57a:	c6d1                	beqz	a3,606 <printint+0x9a>
 57c:	0805d563          	bgez	a1,606 <printint+0x9a>
    neg = 1;
    x = -xx;
 580:	40b005b3          	neg	a1,a1
    neg = 1;
 584:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 586:	fb840993          	addi	s3,s0,-72
  neg = 0;
 58a:	86ce                	mv	a3,s3
  i = 0;
 58c:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 58e:	00001817          	auipc	a6,0x1
 592:	80a80813          	addi	a6,a6,-2038 # d98 <digits>
 596:	88ba                	mv	a7,a4
 598:	0017051b          	addiw	a0,a4,1
 59c:	872a                	mv	a4,a0
 59e:	02c5f7b3          	remu	a5,a1,a2
 5a2:	97c2                	add	a5,a5,a6
 5a4:	0007c783          	lbu	a5,0(a5)
 5a8:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 5ac:	87ae                	mv	a5,a1
 5ae:	02c5d5b3          	divu	a1,a1,a2
 5b2:	0685                	addi	a3,a3,1
 5b4:	fec7f1e3          	bgeu	a5,a2,596 <printint+0x2a>
  if (neg)
 5b8:	00030c63          	beqz	t1,5d0 <printint+0x64>
    buf[i++] = '-';
 5bc:	fd050793          	addi	a5,a0,-48
 5c0:	00878533          	add	a0,a5,s0
 5c4:	02d00793          	li	a5,45
 5c8:	fef50423          	sb	a5,-24(a0)
 5cc:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 5d0:	02e05563          	blez	a4,5fa <printint+0x8e>
 5d4:	fc26                	sd	s1,56(sp)
 5d6:	377d                	addiw	a4,a4,-1
 5d8:	00e984b3          	add	s1,s3,a4
 5dc:	19fd                	addi	s3,s3,-1
 5de:	99ba                	add	s3,s3,a4
 5e0:	1702                	slli	a4,a4,0x20
 5e2:	9301                	srli	a4,a4,0x20
 5e4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5e8:	0004c583          	lbu	a1,0(s1)
 5ec:	854a                	mv	a0,s2
 5ee:	f61ff0ef          	jal	54e <putc>
  while (--i >= 0)
 5f2:	14fd                	addi	s1,s1,-1
 5f4:	ff349ae3          	bne	s1,s3,5e8 <printint+0x7c>
 5f8:	74e2                	ld	s1,56(sp)
}
 5fa:	60a6                	ld	ra,72(sp)
 5fc:	6406                	ld	s0,64(sp)
 5fe:	7942                	ld	s2,48(sp)
 600:	79a2                	ld	s3,40(sp)
 602:	6161                	addi	sp,sp,80
 604:	8082                	ret
  neg = 0;
 606:	4301                	li	t1,0
 608:	bfbd                	j	586 <printint+0x1a>

000000000000060a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 60a:	711d                	addi	sp,sp,-96
 60c:	ec86                	sd	ra,88(sp)
 60e:	e8a2                	sd	s0,80(sp)
 610:	e4a6                	sd	s1,72(sp)
 612:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 614:	0005c483          	lbu	s1,0(a1)
 618:	22048363          	beqz	s1,83e <vprintf+0x234>
 61c:	e0ca                	sd	s2,64(sp)
 61e:	fc4e                	sd	s3,56(sp)
 620:	f852                	sd	s4,48(sp)
 622:	f456                	sd	s5,40(sp)
 624:	f05a                	sd	s6,32(sp)
 626:	ec5e                	sd	s7,24(sp)
 628:	e862                	sd	s8,16(sp)
 62a:	8b2a                	mv	s6,a0
 62c:	8a2e                	mv	s4,a1
 62e:	8bb2                	mv	s7,a2
  state = 0;
 630:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 632:	4901                	li	s2,0
 634:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 636:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 63a:	06400c13          	li	s8,100
 63e:	a00d                	j	660 <vprintf+0x56>
        putc(fd, c0);
 640:	85a6                	mv	a1,s1
 642:	855a                	mv	a0,s6
 644:	f0bff0ef          	jal	54e <putc>
 648:	a019                	j	64e <vprintf+0x44>
    } else if (state == '%') {
 64a:	03598363          	beq	s3,s5,670 <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 64e:	0019079b          	addiw	a5,s2,1
 652:	893e                	mv	s2,a5
 654:	873e                	mv	a4,a5
 656:	97d2                	add	a5,a5,s4
 658:	0007c483          	lbu	s1,0(a5)
 65c:	1c048a63          	beqz	s1,830 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 660:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 664:	fe0993e3          	bnez	s3,64a <vprintf+0x40>
      if (c0 == '%') {
 668:	fd579ce3          	bne	a5,s5,640 <vprintf+0x36>
        state = '%';
 66c:	89be                	mv	s3,a5
 66e:	b7c5                	j	64e <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 670:	00ea06b3          	add	a3,s4,a4
 674:	0016c603          	lbu	a2,1(a3)
      if (c1)
 678:	1c060863          	beqz	a2,848 <vprintf+0x23e>
      if (c0 == 'd') {
 67c:	03878763          	beq	a5,s8,6aa <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 680:	f9478693          	addi	a3,a5,-108
 684:	0016b693          	seqz	a3,a3
 688:	f9c60593          	addi	a1,a2,-100
 68c:	e99d                	bnez	a1,6c2 <vprintf+0xb8>
 68e:	ca95                	beqz	a3,6c2 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 690:	008b8493          	addi	s1,s7,8
 694:	4685                	li	a3,1
 696:	4629                	li	a2,10
 698:	000bb583          	ld	a1,0(s7)
 69c:	855a                	mv	a0,s6
 69e:	ecfff0ef          	jal	56c <printint>
        i += 1;
 6a2:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a4:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	b75d                	j	64e <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 6aa:	008b8493          	addi	s1,s7,8
 6ae:	4685                	li	a3,1
 6b0:	4629                	li	a2,10
 6b2:	000ba583          	lw	a1,0(s7)
 6b6:	855a                	mv	a0,s6
 6b8:	eb5ff0ef          	jal	56c <printint>
 6bc:	8ba6                	mv	s7,s1
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	b779                	j	64e <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 6c2:	9752                	add	a4,a4,s4
 6c4:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 6c8:	f9460713          	addi	a4,a2,-108
 6cc:	00173713          	seqz	a4,a4
 6d0:	8f75                	and	a4,a4,a3
 6d2:	f9c58513          	addi	a0,a1,-100
 6d6:	18051363          	bnez	a0,85c <vprintf+0x252>
 6da:	18070163          	beqz	a4,85c <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6de:	008b8493          	addi	s1,s7,8
 6e2:	4685                	li	a3,1
 6e4:	4629                	li	a2,10
 6e6:	000bb583          	ld	a1,0(s7)
 6ea:	855a                	mv	a0,s6
 6ec:	e81ff0ef          	jal	56c <printint>
        i += 2;
 6f0:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6f2:	8ba6                	mv	s7,s1
      state = 0;
 6f4:	4981                	li	s3,0
        i += 2;
 6f6:	bfa1                	j	64e <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6f8:	008b8493          	addi	s1,s7,8
 6fc:	4681                	li	a3,0
 6fe:	4629                	li	a2,10
 700:	000be583          	lwu	a1,0(s7)
 704:	855a                	mv	a0,s6
 706:	e67ff0ef          	jal	56c <printint>
 70a:	8ba6                	mv	s7,s1
      state = 0;
 70c:	4981                	li	s3,0
 70e:	b781                	j	64e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 710:	008b8493          	addi	s1,s7,8
 714:	4681                	li	a3,0
 716:	4629                	li	a2,10
 718:	000bb583          	ld	a1,0(s7)
 71c:	855a                	mv	a0,s6
 71e:	e4fff0ef          	jal	56c <printint>
        i += 1;
 722:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 724:	8ba6                	mv	s7,s1
      state = 0;
 726:	4981                	li	s3,0
 728:	b71d                	j	64e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 72a:	008b8493          	addi	s1,s7,8
 72e:	4681                	li	a3,0
 730:	4629                	li	a2,10
 732:	000bb583          	ld	a1,0(s7)
 736:	855a                	mv	a0,s6
 738:	e35ff0ef          	jal	56c <printint>
        i += 2;
 73c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 73e:	8ba6                	mv	s7,s1
      state = 0;
 740:	4981                	li	s3,0
        i += 2;
 742:	b731                	j	64e <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 744:	008b8493          	addi	s1,s7,8
 748:	4681                	li	a3,0
 74a:	4641                	li	a2,16
 74c:	000be583          	lwu	a1,0(s7)
 750:	855a                	mv	a0,s6
 752:	e1bff0ef          	jal	56c <printint>
 756:	8ba6                	mv	s7,s1
      state = 0;
 758:	4981                	li	s3,0
 75a:	bdd5                	j	64e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 75c:	008b8493          	addi	s1,s7,8
 760:	4681                	li	a3,0
 762:	4641                	li	a2,16
 764:	000bb583          	ld	a1,0(s7)
 768:	855a                	mv	a0,s6
 76a:	e03ff0ef          	jal	56c <printint>
        i += 1;
 76e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 770:	8ba6                	mv	s7,s1
      state = 0;
 772:	4981                	li	s3,0
 774:	bde9                	j	64e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 776:	008b8493          	addi	s1,s7,8
 77a:	4681                	li	a3,0
 77c:	4641                	li	a2,16
 77e:	000bb583          	ld	a1,0(s7)
 782:	855a                	mv	a0,s6
 784:	de9ff0ef          	jal	56c <printint>
        i += 2;
 788:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 78a:	8ba6                	mv	s7,s1
      state = 0;
 78c:	4981                	li	s3,0
        i += 2;
 78e:	b5c1                	j	64e <vprintf+0x44>
 790:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 792:	008b8793          	addi	a5,s7,8
 796:	8cbe                	mv	s9,a5
 798:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 79c:	03000593          	li	a1,48
 7a0:	855a                	mv	a0,s6
 7a2:	dadff0ef          	jal	54e <putc>
  putc(fd, 'x');
 7a6:	07800593          	li	a1,120
 7aa:	855a                	mv	a0,s6
 7ac:	da3ff0ef          	jal	54e <putc>
 7b0:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7b2:	00000b97          	auipc	s7,0x0
 7b6:	5e6b8b93          	addi	s7,s7,1510 # d98 <digits>
 7ba:	03c9d793          	srli	a5,s3,0x3c
 7be:	97de                	add	a5,a5,s7
 7c0:	0007c583          	lbu	a1,0(a5)
 7c4:	855a                	mv	a0,s6
 7c6:	d89ff0ef          	jal	54e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7ca:	0992                	slli	s3,s3,0x4
 7cc:	34fd                	addiw	s1,s1,-1
 7ce:	f4f5                	bnez	s1,7ba <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 7d0:	8be6                	mv	s7,s9
      state = 0;
 7d2:	4981                	li	s3,0
 7d4:	6ca2                	ld	s9,8(sp)
 7d6:	bda5                	j	64e <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 7d8:	008b8493          	addi	s1,s7,8
 7dc:	000bc583          	lbu	a1,0(s7)
 7e0:	855a                	mv	a0,s6
 7e2:	d6dff0ef          	jal	54e <putc>
 7e6:	8ba6                	mv	s7,s1
      state = 0;
 7e8:	4981                	li	s3,0
 7ea:	b595                	j	64e <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 7ec:	008b8993          	addi	s3,s7,8
 7f0:	000bb483          	ld	s1,0(s7)
 7f4:	cc91                	beqz	s1,810 <vprintf+0x206>
        for (; *s; s++)
 7f6:	0004c583          	lbu	a1,0(s1)
 7fa:	c985                	beqz	a1,82a <vprintf+0x220>
          putc(fd, *s);
 7fc:	855a                	mv	a0,s6
 7fe:	d51ff0ef          	jal	54e <putc>
        for (; *s; s++)
 802:	0485                	addi	s1,s1,1
 804:	0004c583          	lbu	a1,0(s1)
 808:	f9f5                	bnez	a1,7fc <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 80a:	8bce                	mv	s7,s3
      state = 0;
 80c:	4981                	li	s3,0
 80e:	b581                	j	64e <vprintf+0x44>
          s = "(null)";
 810:	00000497          	auipc	s1,0x0
 814:	58048493          	addi	s1,s1,1408 # d90 <malloc+0x3e4>
        for (; *s; s++)
 818:	02800593          	li	a1,40
 81c:	b7c5                	j	7fc <vprintf+0x1f2>
        putc(fd, '%');
 81e:	85be                	mv	a1,a5
 820:	855a                	mv	a0,s6
 822:	d2dff0ef          	jal	54e <putc>
      state = 0;
 826:	4981                	li	s3,0
 828:	b51d                	j	64e <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 82a:	8bce                	mv	s7,s3
      state = 0;
 82c:	4981                	li	s3,0
 82e:	b505                	j	64e <vprintf+0x44>
 830:	6906                	ld	s2,64(sp)
 832:	79e2                	ld	s3,56(sp)
 834:	7a42                	ld	s4,48(sp)
 836:	7aa2                	ld	s5,40(sp)
 838:	7b02                	ld	s6,32(sp)
 83a:	6be2                	ld	s7,24(sp)
 83c:	6c42                	ld	s8,16(sp)
    }
  }
}
 83e:	60e6                	ld	ra,88(sp)
 840:	6446                	ld	s0,80(sp)
 842:	64a6                	ld	s1,72(sp)
 844:	6125                	addi	sp,sp,96
 846:	8082                	ret
      if (c0 == 'd') {
 848:	06400713          	li	a4,100
 84c:	e4e78fe3          	beq	a5,a4,6aa <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 850:	f9478693          	addi	a3,a5,-108
 854:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 858:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 85a:	4701                	li	a4,0
      } else if (c0 == 'u') {
 85c:	07500513          	li	a0,117
 860:	e8a78ce3          	beq	a5,a0,6f8 <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 864:	f8b60513          	addi	a0,a2,-117
 868:	e119                	bnez	a0,86e <vprintf+0x264>
 86a:	ea0693e3          	bnez	a3,710 <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 86e:	f8b58513          	addi	a0,a1,-117
 872:	e119                	bnez	a0,878 <vprintf+0x26e>
 874:	ea071be3          	bnez	a4,72a <vprintf+0x120>
      } else if (c0 == 'x') {
 878:	07800513          	li	a0,120
 87c:	eca784e3          	beq	a5,a0,744 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 880:	f8860613          	addi	a2,a2,-120
 884:	e219                	bnez	a2,88a <vprintf+0x280>
 886:	ec069be3          	bnez	a3,75c <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 88a:	f8858593          	addi	a1,a1,-120
 88e:	e199                	bnez	a1,894 <vprintf+0x28a>
 890:	ee0713e3          	bnez	a4,776 <vprintf+0x16c>
      } else if (c0 == 'p') {
 894:	07000713          	li	a4,112
 898:	eee78ce3          	beq	a5,a4,790 <vprintf+0x186>
      } else if (c0 == 'c') {
 89c:	06300713          	li	a4,99
 8a0:	f2e78ce3          	beq	a5,a4,7d8 <vprintf+0x1ce>
      } else if (c0 == 's') {
 8a4:	07300713          	li	a4,115
 8a8:	f4e782e3          	beq	a5,a4,7ec <vprintf+0x1e2>
      } else if (c0 == '%') {
 8ac:	02500713          	li	a4,37
 8b0:	f6e787e3          	beq	a5,a4,81e <vprintf+0x214>
        putc(fd, '%');
 8b4:	02500593          	li	a1,37
 8b8:	855a                	mv	a0,s6
 8ba:	c95ff0ef          	jal	54e <putc>
        putc(fd, c0);
 8be:	85a6                	mv	a1,s1
 8c0:	855a                	mv	a0,s6
 8c2:	c8dff0ef          	jal	54e <putc>
      state = 0;
 8c6:	4981                	li	s3,0
 8c8:	b359                	j	64e <vprintf+0x44>

00000000000008ca <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8ca:	715d                	addi	sp,sp,-80
 8cc:	ec06                	sd	ra,24(sp)
 8ce:	e822                	sd	s0,16(sp)
 8d0:	1000                	addi	s0,sp,32
 8d2:	e010                	sd	a2,0(s0)
 8d4:	e414                	sd	a3,8(s0)
 8d6:	e818                	sd	a4,16(s0)
 8d8:	ec1c                	sd	a5,24(s0)
 8da:	03043023          	sd	a6,32(s0)
 8de:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8e2:	8622                	mv	a2,s0
 8e4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8e8:	d23ff0ef          	jal	60a <vprintf>
}
 8ec:	60e2                	ld	ra,24(sp)
 8ee:	6442                	ld	s0,16(sp)
 8f0:	6161                	addi	sp,sp,80
 8f2:	8082                	ret

00000000000008f4 <printf>:

void
printf(const char *fmt, ...)
{
 8f4:	711d                	addi	sp,sp,-96
 8f6:	ec06                	sd	ra,24(sp)
 8f8:	e822                	sd	s0,16(sp)
 8fa:	1000                	addi	s0,sp,32
 8fc:	e40c                	sd	a1,8(s0)
 8fe:	e810                	sd	a2,16(s0)
 900:	ec14                	sd	a3,24(s0)
 902:	f018                	sd	a4,32(s0)
 904:	f41c                	sd	a5,40(s0)
 906:	03043823          	sd	a6,48(s0)
 90a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 90e:	00840613          	addi	a2,s0,8
 912:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 916:	85aa                	mv	a1,a0
 918:	4505                	li	a0,1
 91a:	cf1ff0ef          	jal	60a <vprintf>
}
 91e:	60e2                	ld	ra,24(sp)
 920:	6442                	ld	s0,16(sp)
 922:	6125                	addi	sp,sp,96
 924:	8082                	ret

0000000000000926 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 926:	1141                	addi	sp,sp,-16
 928:	e406                	sd	ra,8(sp)
 92a:	e022                	sd	s0,0(sp)
 92c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 92e:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 932:	00001797          	auipc	a5,0x1
 936:	6ce7b783          	ld	a5,1742(a5) # 2000 <freep>
 93a:	a039                	j	948 <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 93c:	6398                	ld	a4,0(a5)
 93e:	00e7e463          	bltu	a5,a4,946 <free+0x20>
 942:	00e6ea63          	bltu	a3,a4,956 <free+0x30>
{
 946:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 948:	fed7fae3          	bgeu	a5,a3,93c <free+0x16>
 94c:	6398                	ld	a4,0(a5)
 94e:	00e6e463          	bltu	a3,a4,956 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 952:	fee7eae3          	bltu	a5,a4,946 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 956:	ff852583          	lw	a1,-8(a0)
 95a:	6390                	ld	a2,0(a5)
 95c:	02059813          	slli	a6,a1,0x20
 960:	01c85713          	srli	a4,a6,0x1c
 964:	9736                	add	a4,a4,a3
 966:	02e60563          	beq	a2,a4,990 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 96a:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 96e:	4790                	lw	a2,8(a5)
 970:	02061593          	slli	a1,a2,0x20
 974:	01c5d713          	srli	a4,a1,0x1c
 978:	973e                	add	a4,a4,a5
 97a:	02e68263          	beq	a3,a4,99e <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 97e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 980:	00001717          	auipc	a4,0x1
 984:	68f73023          	sd	a5,1664(a4) # 2000 <freep>
}
 988:	60a2                	ld	ra,8(sp)
 98a:	6402                	ld	s0,0(sp)
 98c:	0141                	addi	sp,sp,16
 98e:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 990:	4618                	lw	a4,8(a2)
 992:	9f2d                	addw	a4,a4,a1
 994:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 998:	6398                	ld	a4,0(a5)
 99a:	6310                	ld	a2,0(a4)
 99c:	b7f9                	j	96a <free+0x44>
    p->s.size += bp->s.size;
 99e:	ff852703          	lw	a4,-8(a0)
 9a2:	9f31                	addw	a4,a4,a2
 9a4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9a6:	ff053683          	ld	a3,-16(a0)
 9aa:	bfd1                	j	97e <free+0x58>

00000000000009ac <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 9ac:	7139                	addi	sp,sp,-64
 9ae:	fc06                	sd	ra,56(sp)
 9b0:	f822                	sd	s0,48(sp)
 9b2:	f04a                	sd	s2,32(sp)
 9b4:	ec4e                	sd	s3,24(sp)
 9b6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 9b8:	02051993          	slli	s3,a0,0x20
 9bc:	0209d993          	srli	s3,s3,0x20
 9c0:	09bd                	addi	s3,s3,15
 9c2:	0049d993          	srli	s3,s3,0x4
 9c6:	2985                	addiw	s3,s3,1
 9c8:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 9ca:	00001517          	auipc	a0,0x1
 9ce:	63653503          	ld	a0,1590(a0) # 2000 <freep>
 9d2:	c905                	beqz	a0,a02 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 9d4:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 9d6:	4798                	lw	a4,8(a5)
 9d8:	09377663          	bgeu	a4,s3,a64 <malloc+0xb8>
 9dc:	f426                	sd	s1,40(sp)
 9de:	e852                	sd	s4,16(sp)
 9e0:	e456                	sd	s5,8(sp)
 9e2:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 9e4:	8a4e                	mv	s4,s3
 9e6:	6705                	lui	a4,0x1
 9e8:	00e9f363          	bgeu	s3,a4,9ee <malloc+0x42>
 9ec:	6a05                	lui	s4,0x1
 9ee:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9f2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 9f6:	00001497          	auipc	s1,0x1
 9fa:	60a48493          	addi	s1,s1,1546 # 2000 <freep>
  if (p == SBRK_ERROR)
 9fe:	5afd                	li	s5,-1
 a00:	a83d                	j	a3e <malloc+0x92>
 a02:	f426                	sd	s1,40(sp)
 a04:	e852                	sd	s4,16(sp)
 a06:	e456                	sd	s5,8(sp)
 a08:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a0a:	00001797          	auipc	a5,0x1
 a0e:	60678793          	addi	a5,a5,1542 # 2010 <base>
 a12:	00001717          	auipc	a4,0x1
 a16:	5ef73723          	sd	a5,1518(a4) # 2000 <freep>
 a1a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a1c:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 a20:	b7d1                	j	9e4 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 a22:	6398                	ld	a4,0(a5)
 a24:	e118                	sd	a4,0(a0)
 a26:	a899                	j	a7c <malloc+0xd0>
  hp->s.size = nu;
 a28:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 a2c:	0541                	addi	a0,a0,16
 a2e:	ef9ff0ef          	jal	926 <free>
  return freep;
 a32:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 a34:	c125                	beqz	a0,a94 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 a36:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 a38:	4798                	lw	a4,8(a5)
 a3a:	03277163          	bgeu	a4,s2,a5c <malloc+0xb0>
    if (p == freep)
 a3e:	6098                	ld	a4,0(s1)
 a40:	853e                	mv	a0,a5
 a42:	fef71ae3          	bne	a4,a5,a36 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 a46:	8552                	mv	a0,s4
 a48:	a23ff0ef          	jal	46a <sbrk>
  if (p == SBRK_ERROR)
 a4c:	fd551ee3          	bne	a0,s5,a28 <malloc+0x7c>
        return 0;
 a50:	4501                	li	a0,0
 a52:	74a2                	ld	s1,40(sp)
 a54:	6a42                	ld	s4,16(sp)
 a56:	6aa2                	ld	s5,8(sp)
 a58:	6b02                	ld	s6,0(sp)
 a5a:	a03d                	j	a88 <malloc+0xdc>
 a5c:	74a2                	ld	s1,40(sp)
 a5e:	6a42                	ld	s4,16(sp)
 a60:	6aa2                	ld	s5,8(sp)
 a62:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 a64:	fae90fe3          	beq	s2,a4,a22 <malloc+0x76>
        p->s.size -= nunits;
 a68:	4137073b          	subw	a4,a4,s3
 a6c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a6e:	02071693          	slli	a3,a4,0x20
 a72:	01c6d713          	srli	a4,a3,0x1c
 a76:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a78:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a7c:	00001717          	auipc	a4,0x1
 a80:	58a73223          	sd	a0,1412(a4) # 2000 <freep>
      return (void *)(p + 1);
 a84:	01078513          	addi	a0,a5,16
  }
}
 a88:	70e2                	ld	ra,56(sp)
 a8a:	7442                	ld	s0,48(sp)
 a8c:	7902                	ld	s2,32(sp)
 a8e:	69e2                	ld	s3,24(sp)
 a90:	6121                	addi	sp,sp,64
 a92:	8082                	ret
 a94:	74a2                	ld	s1,40(sp)
 a96:	6a42                	ld	s4,16(sp)
 a98:	6aa2                	ld	s5,8(sp)
 a9a:	6b02                	ld	s6,0(sp)
 a9c:	b7f5                	j	a88 <malloc+0xdc>
