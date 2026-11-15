
user/_faulttest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	711d                	addi	sp,sp,-96
   2:	ec86                	sd	ra,88(sp)
   4:	e8a2                	sd	s0,80(sp)
   6:	f852                	sd	s4,48(sp)
   8:	1080                	addi	s0,sp,96
  printf("============================================================\n");
   a:	00001517          	auipc	a0,0x1
   e:	af650513          	addi	a0,a0,-1290 # b00 <malloc+0xf4>
  12:	143000ef          	jal	954 <printf>
  printf("        Lazy Memory Allocation Test (faulttest)             \n");
  16:	00001517          	auipc	a0,0x1
  1a:	b3250513          	addi	a0,a0,-1230 # b48 <malloc+0x13c>
  1e:	137000ef          	jal	954 <printf>
  printf("============================================================\n\n");
  22:	00001517          	auipc	a0,0x1
  26:	b6650513          	addi	a0,a0,-1178 # b88 <malloc+0x17c>
  2a:	12b000ef          	jal	954 <printf>

  printf("--- 1. Baseline Page Fault Count ---\n");
  2e:	00001517          	auipc	a0,0x1
  32:	b9a50513          	addi	a0,a0,-1126 # bc8 <malloc+0x1bc>
  36:	11f000ef          	jal	954 <printf>
  int f0 = getfaults();
  3a:	56c000ef          	jal	5a6 <getfaults>
  3e:	8a2a                	mv	s4,a0
  printf("Initial handled page faults: %d\n\n", f0);
  40:	85aa                	mv	a1,a0
  42:	00001517          	auipc	a0,0x1
  46:	bae50513          	addi	a0,a0,-1106 # bf0 <malloc+0x1e4>
  4a:	10b000ef          	jal	954 <printf>

  printf("--- 2. Requesting 32 pages via sbrk(32 * 4096 = 131072 bytes) ---\n");
  4e:	00001517          	auipc	a0,0x1
  52:	bca50513          	addi	a0,a0,-1078 # c18 <malloc+0x20c>
  56:	0ff000ef          	jal	954 <printf>
  char *p = sbrk(32 * 4096);
  5a:	00020537          	lui	a0,0x20
  5e:	46c000ef          	jal	4ca <sbrk>
  if (p == (char *)-1) {
  62:	57fd                	li	a5,-1
  64:	12f50a63          	beq	a0,a5,198 <main+0x198>
  68:	e4a6                	sd	s1,72(sp)
  6a:	e0ca                	sd	s2,64(sp)
  6c:	fc4e                	sd	s3,56(sp)
  6e:	f456                	sd	s5,40(sp)
  70:	f05a                	sd	s6,32(sp)
  72:	89aa                	mv	s3,a0
    printf("sbrk failed!\n");
    exit(1);
  }
  printf("sbrk returned base address: 0x%lx\n", (uint64)p);
  74:	85aa                	mv	a1,a0
  76:	00001517          	auipc	a0,0x1
  7a:	bfa50513          	addi	a0,a0,-1030 # c70 <malloc+0x264>
  7e:	0d7000ef          	jal	954 <printf>

  int f_after_sbrk = getfaults();
  82:	524000ef          	jal	5a6 <getfaults>
  86:	84aa                	mv	s1,a0
  printf("Handled page faults immediately after sbrk: %d\n", f_after_sbrk);
  88:	85aa                	mv	a1,a0
  8a:	00001517          	auipc	a0,0x1
  8e:	c0e50513          	addi	a0,a0,-1010 # c98 <malloc+0x28c>
  92:	0c3000ef          	jal	954 <printf>
  if (f_after_sbrk == f0) {
  96:	109a0f63          	beq	s4,s1,1b4 <main+0x1b4>
    printf("PASSED: No physical pages allocated yet (lazy allocation active!)\n\n");
  } else {
    printf("FAILED: Expected 0 new page faults, got %d\n\n", f_after_sbrk - f0);
  9a:	414485bb          	subw	a1,s1,s4
  9e:	00001517          	auipc	a0,0x1
  a2:	c7250513          	addi	a0,a0,-910 # d10 <malloc+0x304>
  a6:	0af000ef          	jal	954 <printf>
  }

  printf("--- 3. Writing to exactly 5 distinct pages ---\n");
  aa:	00001517          	auipc	a0,0x1
  ae:	c9650513          	addi	a0,a0,-874 # d40 <malloc+0x334>
  b2:	0a3000ef          	jal	954 <printf>
  int page_indices[5] = {0, 4, 11, 19, 31};
  b6:	fa042423          	sw	zero,-88(s0)
  ba:	4791                	li	a5,4
  bc:	faf42623          	sw	a5,-84(s0)
  c0:	47ad                	li	a5,11
  c2:	faf42823          	sw	a5,-80(s0)
  c6:	47cd                	li	a5,19
  c8:	faf42a23          	sw	a5,-76(s0)
  cc:	47fd                	li	a5,31
  ce:	faf42c23          	sw	a5,-72(s0)
  for (int i = 0; i < 5; i++) {
  d2:	fa840913          	addi	s2,s0,-88
  int page_indices[5] = {0, 4, 11, 19, 31};
  d6:	04100493          	li	s1,65
    int idx = page_indices[i];
    p[idx * 4096] = 'A' + i;
    printf("  Touched page index %d (VA 0x%lx) with '%c'\n",
  da:	00001b17          	auipc	s6,0x1
  de:	c96b0b13          	addi	s6,s6,-874 # d70 <malloc+0x364>
  for (int i = 0; i < 5; i++) {
  e2:	04600a93          	li	s5,70
    int idx = page_indices[i];
  e6:	00092583          	lw	a1,0(s2)
    p[idx * 4096] = 'A' + i;
  ea:	00c5961b          	slliw	a2,a1,0xc
  ee:	964e                	add	a2,a2,s3
  f0:	00960023          	sb	s1,0(a2)
    printf("  Touched page index %d (VA 0x%lx) with '%c'\n",
  f4:	86a6                	mv	a3,s1
  f6:	855a                	mv	a0,s6
  f8:	05d000ef          	jal	954 <printf>
  for (int i = 0; i < 5; i++) {
  fc:	0911                	addi	s2,s2,4
  fe:	2485                	addiw	s1,s1,1
 100:	ff5493e3          	bne	s1,s5,e6 <main+0xe6>
           idx, (uint64)&p[idx * 4096], 'A' + i);
  }
  printf("\n");
 104:	00001517          	auipc	a0,0x1
 108:	c9c50513          	addi	a0,a0,-868 # da0 <malloc+0x394>
 10c:	049000ef          	jal	954 <printf>

  printf("--- 4. Checking Page Fault Count via getfaults() ---\n");
 110:	00001517          	auipc	a0,0x1
 114:	c9850513          	addi	a0,a0,-872 # da8 <malloc+0x39c>
 118:	03d000ef          	jal	954 <printf>
  int f_after_writes = getfaults();
 11c:	48a000ef          	jal	5a6 <getfaults>
 120:	85aa                	mv	a1,a0
  int new_faults = f_after_writes - f0;
 122:	41450a3b          	subw	s4,a0,s4
  printf("Total handled page faults: %d (New faults: %d)\n", f_after_writes, new_faults);
 126:	8652                	mv	a2,s4
 128:	00001517          	auipc	a0,0x1
 12c:	cb850513          	addi	a0,a0,-840 # de0 <malloc+0x3d4>
 130:	025000ef          	jal	954 <printf>

  if (new_faults == 5) {
 134:	4795                	li	a5,5
 136:	08fa0663          	beq	s4,a5,1c2 <main+0x1c2>
    printf("SUCCESS: Exactly 5 page faults were handled by the kernel!\n\n");
  } else {
    printf("FAILED: Expected 5 page faults, got %d\n\n", new_faults);
 13a:	85d2                	mv	a1,s4
 13c:	00001517          	auipc	a0,0x1
 140:	d1450513          	addi	a0,a0,-748 # e50 <malloc+0x444>
 144:	011000ef          	jal	954 <printf>
  }

  printf("--- 5. Testing Access Above Allocated Memory Size ---\n");
 148:	00001517          	auipc	a0,0x1
 14c:	d3850513          	addi	a0,a0,-712 # e80 <malloc+0x474>
 150:	005000ef          	jal	954 <printf>
  int pid = fork();
 154:	3a2000ef          	jal	4f6 <fork>
  if (pid < 0) {
 158:	06054c63          	bltz	a0,1d0 <main+0x1d0>
    printf("fork failed!\n");
    exit(1);
  }

  if (pid == 0) {
 15c:	e159                	bnez	a0,1e2 <main+0x1e2>
    // Child process accesses address above process size
    char *bad_addr = p + (35 * 4096);
    printf("[Child pid %d] Attempting to access address above p->sz (VA 0x%lx)...\n",
 15e:	420000ef          	jal	57e <getpid>
 162:	85aa                	mv	a1,a0
    char *bad_addr = p + (35 * 4096);
 164:	000237b7          	lui	a5,0x23
 168:	99be                	add	s3,s3,a5
    printf("[Child pid %d] Attempting to access address above p->sz (VA 0x%lx)...\n",
 16a:	864e                	mv	a2,s3
 16c:	00001517          	auipc	a0,0x1
 170:	d5c50513          	addi	a0,a0,-676 # ec8 <malloc+0x4bc>
 174:	7e0000ef          	jal	954 <printf>
           getpid(), (uint64)bad_addr);
    *bad_addr = 'Z'; // Must trigger unhandled page fault and kill process
 178:	05a00793          	li	a5,90
 17c:	00f98023          	sb	a5,0(s3)
    printf("[Child pid %d] ERROR: Out-of-bounds access succeeded unexpectedly!\n", getpid());
 180:	3fe000ef          	jal	57e <getpid>
 184:	85aa                	mv	a1,a0
 186:	00001517          	auipc	a0,0x1
 18a:	d8a50513          	addi	a0,a0,-630 # f10 <malloc+0x504>
 18e:	7c6000ef          	jal	954 <printf>
    exit(0);
 192:	4501                	li	a0,0
 194:	36a000ef          	jal	4fe <exit>
 198:	e4a6                	sd	s1,72(sp)
 19a:	e0ca                	sd	s2,64(sp)
 19c:	fc4e                	sd	s3,56(sp)
 19e:	f456                	sd	s5,40(sp)
 1a0:	f05a                	sd	s6,32(sp)
    printf("sbrk failed!\n");
 1a2:	00001517          	auipc	a0,0x1
 1a6:	abe50513          	addi	a0,a0,-1346 # c60 <malloc+0x254>
 1aa:	7aa000ef          	jal	954 <printf>
    exit(1);
 1ae:	4505                	li	a0,1
 1b0:	34e000ef          	jal	4fe <exit>
    printf("PASSED: No physical pages allocated yet (lazy allocation active!)\n\n");
 1b4:	00001517          	auipc	a0,0x1
 1b8:	b1450513          	addi	a0,a0,-1260 # cc8 <malloc+0x2bc>
 1bc:	798000ef          	jal	954 <printf>
 1c0:	b5ed                	j	aa <main+0xaa>
    printf("SUCCESS: Exactly 5 page faults were handled by the kernel!\n\n");
 1c2:	00001517          	auipc	a0,0x1
 1c6:	c4e50513          	addi	a0,a0,-946 # e10 <malloc+0x404>
 1ca:	78a000ef          	jal	954 <printf>
 1ce:	bfad                	j	148 <main+0x148>
    printf("fork failed!\n");
 1d0:	00001517          	auipc	a0,0x1
 1d4:	ce850513          	addi	a0,a0,-792 # eb8 <malloc+0x4ac>
 1d8:	77c000ef          	jal	954 <printf>
    exit(1);
 1dc:	4505                	li	a0,1
 1de:	320000ef          	jal	4fe <exit>
  } else {
    int status = 0;
 1e2:	fa042223          	sw	zero,-92(s0)
    wait(&status);
 1e6:	fa440513          	addi	a0,s0,-92
 1ea:	31c000ef          	jal	506 <wait>
    printf("[Parent] Child process terminated with status %d.\n", status);
 1ee:	fa442583          	lw	a1,-92(s0)
 1f2:	00001517          	auipc	a0,0x1
 1f6:	d6650513          	addi	a0,a0,-666 # f58 <malloc+0x54c>
 1fa:	75a000ef          	jal	954 <printf>
    if (status != 0) {
 1fe:	fa442783          	lw	a5,-92(s0)
 202:	cf85                	beqz	a5,23a <main+0x23a>
      printf("[Parent] SUCCESS: Only the offending child was killed by the kernel!\n");
 204:	00001517          	auipc	a0,0x1
 208:	d8c50513          	addi	a0,a0,-628 # f90 <malloc+0x584>
 20c:	748000ef          	jal	954 <printf>
    } else {
      printf("[Parent] FAILED: Child process exited normally without being killed.\n");
    }
  }

  printf("\n============================================================\n");
 210:	00001517          	auipc	a0,0x1
 214:	e1050513          	addi	a0,a0,-496 # 1020 <malloc+0x614>
 218:	73c000ef          	jal	954 <printf>
  printf("faulttest: All lazy allocation tests completed successfully!\n");
 21c:	00001517          	auipc	a0,0x1
 220:	e4450513          	addi	a0,a0,-444 # 1060 <malloc+0x654>
 224:	730000ef          	jal	954 <printf>
  printf("============================================================\n");
 228:	00001517          	auipc	a0,0x1
 22c:	8d850513          	addi	a0,a0,-1832 # b00 <malloc+0xf4>
 230:	724000ef          	jal	954 <printf>
  exit(0);
 234:	4501                	li	a0,0
 236:	2c8000ef          	jal	4fe <exit>
      printf("[Parent] FAILED: Child process exited normally without being killed.\n");
 23a:	00001517          	auipc	a0,0x1
 23e:	d9e50513          	addi	a0,a0,-610 # fd8 <malloc+0x5cc>
 242:	712000ef          	jal	954 <printf>
 246:	b7e9                	j	210 <main+0x210>

0000000000000248 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 248:	1141                	addi	sp,sp,-16
 24a:	e406                	sd	ra,8(sp)
 24c:	e022                	sd	s0,0(sp)
 24e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 250:	db1ff0ef          	jal	0 <main>
  exit(r);
 254:	2aa000ef          	jal	4fe <exit>

0000000000000258 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 258:	1141                	addi	sp,sp,-16
 25a:	e406                	sd	ra,8(sp)
 25c:	e022                	sd	s0,0(sp)
 25e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 260:	87aa                	mv	a5,a0
 262:	0585                	addi	a1,a1,1
 264:	0785                	addi	a5,a5,1 # 23001 <base+0x20ff1>
 266:	fff5c703          	lbu	a4,-1(a1)
 26a:	fee78fa3          	sb	a4,-1(a5)
 26e:	fb75                	bnez	a4,262 <strcpy+0xa>
    ;
  return os;
}
 270:	60a2                	ld	ra,8(sp)
 272:	6402                	ld	s0,0(sp)
 274:	0141                	addi	sp,sp,16
 276:	8082                	ret

0000000000000278 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 278:	1141                	addi	sp,sp,-16
 27a:	e406                	sd	ra,8(sp)
 27c:	e022                	sd	s0,0(sp)
 27e:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 280:	00054783          	lbu	a5,0(a0)
 284:	cb91                	beqz	a5,298 <strcmp+0x20>
 286:	0005c703          	lbu	a4,0(a1)
 28a:	00f71763          	bne	a4,a5,298 <strcmp+0x20>
    p++, q++;
 28e:	0505                	addi	a0,a0,1
 290:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 292:	00054783          	lbu	a5,0(a0)
 296:	fbe5                	bnez	a5,286 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 298:	0005c503          	lbu	a0,0(a1)
}
 29c:	40a7853b          	subw	a0,a5,a0
 2a0:	60a2                	ld	ra,8(sp)
 2a2:	6402                	ld	s0,0(sp)
 2a4:	0141                	addi	sp,sp,16
 2a6:	8082                	ret

00000000000002a8 <strlen>:

uint
strlen(const char *s)
{
 2a8:	1141                	addi	sp,sp,-16
 2aa:	e406                	sd	ra,8(sp)
 2ac:	e022                	sd	s0,0(sp)
 2ae:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 2b0:	00054783          	lbu	a5,0(a0)
 2b4:	cf91                	beqz	a5,2d0 <strlen+0x28>
 2b6:	00150793          	addi	a5,a0,1
 2ba:	86be                	mv	a3,a5
 2bc:	0785                	addi	a5,a5,1
 2be:	fff7c703          	lbu	a4,-1(a5)
 2c2:	ff65                	bnez	a4,2ba <strlen+0x12>
 2c4:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 2c8:	60a2                	ld	ra,8(sp)
 2ca:	6402                	ld	s0,0(sp)
 2cc:	0141                	addi	sp,sp,16
 2ce:	8082                	ret
  for (n = 0; s[n]; n++)
 2d0:	4501                	li	a0,0
 2d2:	bfdd                	j	2c8 <strlen+0x20>

00000000000002d4 <memset>:

void *
memset(void *dst, int c, uint n)
{
 2d4:	1141                	addi	sp,sp,-16
 2d6:	e406                	sd	ra,8(sp)
 2d8:	e022                	sd	s0,0(sp)
 2da:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 2dc:	ca19                	beqz	a2,2f2 <memset+0x1e>
 2de:	87aa                	mv	a5,a0
 2e0:	1602                	slli	a2,a2,0x20
 2e2:	9201                	srli	a2,a2,0x20
 2e4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2e8:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 2ec:	0785                	addi	a5,a5,1
 2ee:	fee79de3          	bne	a5,a4,2e8 <memset+0x14>
  }
  return dst;
}
 2f2:	60a2                	ld	ra,8(sp)
 2f4:	6402                	ld	s0,0(sp)
 2f6:	0141                	addi	sp,sp,16
 2f8:	8082                	ret

00000000000002fa <strchr>:

char *
strchr(const char *s, char c)
{
 2fa:	1141                	addi	sp,sp,-16
 2fc:	e406                	sd	ra,8(sp)
 2fe:	e022                	sd	s0,0(sp)
 300:	0800                	addi	s0,sp,16
  for (; *s; s++)
 302:	00054783          	lbu	a5,0(a0)
 306:	cf81                	beqz	a5,31e <strchr+0x24>
    if (*s == c)
 308:	00f58763          	beq	a1,a5,316 <strchr+0x1c>
  for (; *s; s++)
 30c:	0505                	addi	a0,a0,1
 30e:	00054783          	lbu	a5,0(a0)
 312:	fbfd                	bnez	a5,308 <strchr+0xe>
      return (char *)s;
  return 0;
 314:	4501                	li	a0,0
}
 316:	60a2                	ld	ra,8(sp)
 318:	6402                	ld	s0,0(sp)
 31a:	0141                	addi	sp,sp,16
 31c:	8082                	ret
  return 0;
 31e:	4501                	li	a0,0
 320:	bfdd                	j	316 <strchr+0x1c>

0000000000000322 <gets>:

char *
gets(char *buf, int max)
{
 322:	711d                	addi	sp,sp,-96
 324:	ec86                	sd	ra,88(sp)
 326:	e8a2                	sd	s0,80(sp)
 328:	e4a6                	sd	s1,72(sp)
 32a:	e0ca                	sd	s2,64(sp)
 32c:	fc4e                	sd	s3,56(sp)
 32e:	f852                	sd	s4,48(sp)
 330:	f456                	sd	s5,40(sp)
 332:	f05a                	sd	s6,32(sp)
 334:	ec5e                	sd	s7,24(sp)
 336:	e862                	sd	s8,16(sp)
 338:	1080                	addi	s0,sp,96
 33a:	8baa                	mv	s7,a0
 33c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 33e:	892a                	mv	s2,a0
 340:	4481                	li	s1,0
    cc = read(0, &c, 1);
 342:	faf40b13          	addi	s6,s0,-81
 346:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 348:	8c26                	mv	s8,s1
 34a:	0014899b          	addiw	s3,s1,1
 34e:	84ce                	mv	s1,s3
 350:	0349d463          	bge	s3,s4,378 <gets+0x56>
    cc = read(0, &c, 1);
 354:	8656                	mv	a2,s5
 356:	85da                	mv	a1,s6
 358:	4501                	li	a0,0
 35a:	1bc000ef          	jal	516 <read>
    if (cc < 1)
 35e:	00a05d63          	blez	a0,378 <gets+0x56>
      break;
    buf[i++] = c;
 362:	faf44783          	lbu	a5,-81(s0)
 366:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 36a:	0905                	addi	s2,s2,1
 36c:	ff678713          	addi	a4,a5,-10
 370:	c319                	beqz	a4,376 <gets+0x54>
 372:	17cd                	addi	a5,a5,-13
 374:	fbf1                	bnez	a5,348 <gets+0x26>
    buf[i++] = c;
 376:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 378:	9c5e                	add	s8,s8,s7
 37a:	000c0023          	sb	zero,0(s8)
  return buf;
}
 37e:	855e                	mv	a0,s7
 380:	60e6                	ld	ra,88(sp)
 382:	6446                	ld	s0,80(sp)
 384:	64a6                	ld	s1,72(sp)
 386:	6906                	ld	s2,64(sp)
 388:	79e2                	ld	s3,56(sp)
 38a:	7a42                	ld	s4,48(sp)
 38c:	7aa2                	ld	s5,40(sp)
 38e:	7b02                	ld	s6,32(sp)
 390:	6be2                	ld	s7,24(sp)
 392:	6c42                	ld	s8,16(sp)
 394:	6125                	addi	sp,sp,96
 396:	8082                	ret

0000000000000398 <stat>:

int
stat(const char *n, struct stat *st)
{
 398:	1101                	addi	sp,sp,-32
 39a:	ec06                	sd	ra,24(sp)
 39c:	e822                	sd	s0,16(sp)
 39e:	e04a                	sd	s2,0(sp)
 3a0:	1000                	addi	s0,sp,32
 3a2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3a4:	4581                	li	a1,0
 3a6:	198000ef          	jal	53e <open>
  if (fd < 0)
 3aa:	02054263          	bltz	a0,3ce <stat+0x36>
 3ae:	e426                	sd	s1,8(sp)
 3b0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3b2:	85ca                	mv	a1,s2
 3b4:	1a2000ef          	jal	556 <fstat>
 3b8:	892a                	mv	s2,a0
  close(fd);
 3ba:	8526                	mv	a0,s1
 3bc:	16a000ef          	jal	526 <close>
  return r;
 3c0:	64a2                	ld	s1,8(sp)
}
 3c2:	854a                	mv	a0,s2
 3c4:	60e2                	ld	ra,24(sp)
 3c6:	6442                	ld	s0,16(sp)
 3c8:	6902                	ld	s2,0(sp)
 3ca:	6105                	addi	sp,sp,32
 3cc:	8082                	ret
    return -1;
 3ce:	57fd                	li	a5,-1
 3d0:	893e                	mv	s2,a5
 3d2:	bfc5                	j	3c2 <stat+0x2a>

00000000000003d4 <atoi>:

int
atoi(const char *s)
{
 3d4:	1141                	addi	sp,sp,-16
 3d6:	e406                	sd	ra,8(sp)
 3d8:	e022                	sd	s0,0(sp)
 3da:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 3dc:	00054683          	lbu	a3,0(a0)
 3e0:	fd06879b          	addiw	a5,a3,-48
 3e4:	0ff7f793          	zext.b	a5,a5
 3e8:	4625                	li	a2,9
 3ea:	02f66963          	bltu	a2,a5,41c <atoi+0x48>
 3ee:	872a                	mv	a4,a0
  n = 0;
 3f0:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 3f2:	0705                	addi	a4,a4,1
 3f4:	0025179b          	slliw	a5,a0,0x2
 3f8:	9fa9                	addw	a5,a5,a0
 3fa:	0017979b          	slliw	a5,a5,0x1
 3fe:	9fb5                	addw	a5,a5,a3
 400:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 404:	00074683          	lbu	a3,0(a4)
 408:	fd06879b          	addiw	a5,a3,-48
 40c:	0ff7f793          	zext.b	a5,a5
 410:	fef671e3          	bgeu	a2,a5,3f2 <atoi+0x1e>
  return n;
}
 414:	60a2                	ld	ra,8(sp)
 416:	6402                	ld	s0,0(sp)
 418:	0141                	addi	sp,sp,16
 41a:	8082                	ret
  n = 0;
 41c:	4501                	li	a0,0
 41e:	bfdd                	j	414 <atoi+0x40>

0000000000000420 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 420:	1141                	addi	sp,sp,-16
 422:	e406                	sd	ra,8(sp)
 424:	e022                	sd	s0,0(sp)
 426:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 428:	02b57563          	bgeu	a0,a1,452 <memmove+0x32>
    while (n-- > 0)
 42c:	00c05f63          	blez	a2,44a <memmove+0x2a>
 430:	1602                	slli	a2,a2,0x20
 432:	9201                	srli	a2,a2,0x20
 434:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 438:	872a                	mv	a4,a0
      *dst++ = *src++;
 43a:	0585                	addi	a1,a1,1
 43c:	0705                	addi	a4,a4,1
 43e:	fff5c683          	lbu	a3,-1(a1)
 442:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 446:	fee79ae3          	bne	a5,a4,43a <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 44a:	60a2                	ld	ra,8(sp)
 44c:	6402                	ld	s0,0(sp)
 44e:	0141                	addi	sp,sp,16
 450:	8082                	ret
    while (n-- > 0)
 452:	fec05ce3          	blez	a2,44a <memmove+0x2a>
    dst += n;
 456:	00c50733          	add	a4,a0,a2
    src += n;
 45a:	95b2                	add	a1,a1,a2
 45c:	fff6079b          	addiw	a5,a2,-1
 460:	1782                	slli	a5,a5,0x20
 462:	9381                	srli	a5,a5,0x20
 464:	fff7c793          	not	a5,a5
 468:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 46a:	15fd                	addi	a1,a1,-1
 46c:	177d                	addi	a4,a4,-1
 46e:	0005c683          	lbu	a3,0(a1)
 472:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 476:	fef71ae3          	bne	a4,a5,46a <memmove+0x4a>
 47a:	bfc1                	j	44a <memmove+0x2a>

000000000000047c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 47c:	1141                	addi	sp,sp,-16
 47e:	e406                	sd	ra,8(sp)
 480:	e022                	sd	s0,0(sp)
 482:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 484:	c61d                	beqz	a2,4b2 <memcmp+0x36>
 486:	1602                	slli	a2,a2,0x20
 488:	9201                	srli	a2,a2,0x20
 48a:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 48e:	00054783          	lbu	a5,0(a0)
 492:	0005c703          	lbu	a4,0(a1)
 496:	00e79863          	bne	a5,a4,4a6 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 49a:	0505                	addi	a0,a0,1
    p2++;
 49c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 49e:	fed518e3          	bne	a0,a3,48e <memcmp+0x12>
  }
  return 0;
 4a2:	4501                	li	a0,0
 4a4:	a019                	j	4aa <memcmp+0x2e>
      return *p1 - *p2;
 4a6:	40e7853b          	subw	a0,a5,a4
}
 4aa:	60a2                	ld	ra,8(sp)
 4ac:	6402                	ld	s0,0(sp)
 4ae:	0141                	addi	sp,sp,16
 4b0:	8082                	ret
  return 0;
 4b2:	4501                	li	a0,0
 4b4:	bfdd                	j	4aa <memcmp+0x2e>

00000000000004b6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4b6:	1141                	addi	sp,sp,-16
 4b8:	e406                	sd	ra,8(sp)
 4ba:	e022                	sd	s0,0(sp)
 4bc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4be:	f63ff0ef          	jal	420 <memmove>
}
 4c2:	60a2                	ld	ra,8(sp)
 4c4:	6402                	ld	s0,0(sp)
 4c6:	0141                	addi	sp,sp,16
 4c8:	8082                	ret

00000000000004ca <sbrk>:

char *
sbrk(int n)
{
 4ca:	1141                	addi	sp,sp,-16
 4cc:	e406                	sd	ra,8(sp)
 4ce:	e022                	sd	s0,0(sp)
 4d0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4d2:	4585                	li	a1,1
 4d4:	0b2000ef          	jal	586 <sys_sbrk>
}
 4d8:	60a2                	ld	ra,8(sp)
 4da:	6402                	ld	s0,0(sp)
 4dc:	0141                	addi	sp,sp,16
 4de:	8082                	ret

00000000000004e0 <sbrklazy>:

char *
sbrklazy(int n)
{
 4e0:	1141                	addi	sp,sp,-16
 4e2:	e406                	sd	ra,8(sp)
 4e4:	e022                	sd	s0,0(sp)
 4e6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4e8:	4589                	li	a1,2
 4ea:	09c000ef          	jal	586 <sys_sbrk>
}
 4ee:	60a2                	ld	ra,8(sp)
 4f0:	6402                	ld	s0,0(sp)
 4f2:	0141                	addi	sp,sp,16
 4f4:	8082                	ret

00000000000004f6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4f6:	4885                	li	a7,1
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <exit>:
.global exit
exit:
 li a7, SYS_exit
 4fe:	4889                	li	a7,2
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <wait>:
.global wait
wait:
 li a7, SYS_wait
 506:	488d                	li	a7,3
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 50e:	4891                	li	a7,4
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <read>:
.global read
read:
 li a7, SYS_read
 516:	4895                	li	a7,5
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <write>:
.global write
write:
 li a7, SYS_write
 51e:	48c1                	li	a7,16
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <close>:
.global close
close:
 li a7, SYS_close
 526:	48d5                	li	a7,21
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <kill>:
.global kill
kill:
 li a7, SYS_kill
 52e:	4899                	li	a7,6
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <exec>:
.global exec
exec:
 li a7, SYS_exec
 536:	489d                	li	a7,7
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <open>:
.global open
open:
 li a7, SYS_open
 53e:	48bd                	li	a7,15
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 546:	48c5                	li	a7,17
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 54e:	48c9                	li	a7,18
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 556:	48a1                	li	a7,8
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <link>:
.global link
link:
 li a7, SYS_link
 55e:	48cd                	li	a7,19
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 566:	48d1                	li	a7,20
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 56e:	48a5                	li	a7,9
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <dup>:
.global dup
dup:
 li a7, SYS_dup
 576:	48a9                	li	a7,10
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 57e:	48ad                	li	a7,11
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 586:	48b1                	li	a7,12
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <pause>:
.global pause
pause:
 li a7, SYS_pause
 58e:	48b5                	li	a7,13
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 596:	48b9                	li	a7,14
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <sync>:
.global sync
sync:
 li a7, SYS_sync
 59e:	48d9                	li	a7,22
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <getfaults>:
.global getfaults
getfaults:
 li a7, SYS_getfaults
 5a6:	48dd                	li	a7,23
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5ae:	1101                	addi	sp,sp,-32
 5b0:	ec06                	sd	ra,24(sp)
 5b2:	e822                	sd	s0,16(sp)
 5b4:	1000                	addi	s0,sp,32
 5b6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5ba:	4605                	li	a2,1
 5bc:	fef40593          	addi	a1,s0,-17
 5c0:	f5fff0ef          	jal	51e <write>
}
 5c4:	60e2                	ld	ra,24(sp)
 5c6:	6442                	ld	s0,16(sp)
 5c8:	6105                	addi	sp,sp,32
 5ca:	8082                	ret

00000000000005cc <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 5cc:	715d                	addi	sp,sp,-80
 5ce:	e486                	sd	ra,72(sp)
 5d0:	e0a2                	sd	s0,64(sp)
 5d2:	f84a                	sd	s2,48(sp)
 5d4:	f44e                	sd	s3,40(sp)
 5d6:	0880                	addi	s0,sp,80
 5d8:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 5da:	c6d1                	beqz	a3,666 <printint+0x9a>
 5dc:	0805d563          	bgez	a1,666 <printint+0x9a>
    neg = 1;
    x = -xx;
 5e0:	40b005b3          	neg	a1,a1
    neg = 1;
 5e4:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 5e6:	fb840993          	addi	s3,s0,-72
  neg = 0;
 5ea:	86ce                	mv	a3,s3
  i = 0;
 5ec:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 5ee:	00001817          	auipc	a6,0x1
 5f2:	aba80813          	addi	a6,a6,-1350 # 10a8 <digits>
 5f6:	88ba                	mv	a7,a4
 5f8:	0017051b          	addiw	a0,a4,1
 5fc:	872a                	mv	a4,a0
 5fe:	02c5f7b3          	remu	a5,a1,a2
 602:	97c2                	add	a5,a5,a6
 604:	0007c783          	lbu	a5,0(a5)
 608:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 60c:	87ae                	mv	a5,a1
 60e:	02c5d5b3          	divu	a1,a1,a2
 612:	0685                	addi	a3,a3,1
 614:	fec7f1e3          	bgeu	a5,a2,5f6 <printint+0x2a>
  if (neg)
 618:	00030c63          	beqz	t1,630 <printint+0x64>
    buf[i++] = '-';
 61c:	fd050793          	addi	a5,a0,-48
 620:	00878533          	add	a0,a5,s0
 624:	02d00793          	li	a5,45
 628:	fef50423          	sb	a5,-24(a0)
 62c:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 630:	02e05563          	blez	a4,65a <printint+0x8e>
 634:	fc26                	sd	s1,56(sp)
 636:	377d                	addiw	a4,a4,-1
 638:	00e984b3          	add	s1,s3,a4
 63c:	19fd                	addi	s3,s3,-1
 63e:	99ba                	add	s3,s3,a4
 640:	1702                	slli	a4,a4,0x20
 642:	9301                	srli	a4,a4,0x20
 644:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 648:	0004c583          	lbu	a1,0(s1)
 64c:	854a                	mv	a0,s2
 64e:	f61ff0ef          	jal	5ae <putc>
  while (--i >= 0)
 652:	14fd                	addi	s1,s1,-1
 654:	ff349ae3          	bne	s1,s3,648 <printint+0x7c>
 658:	74e2                	ld	s1,56(sp)
}
 65a:	60a6                	ld	ra,72(sp)
 65c:	6406                	ld	s0,64(sp)
 65e:	7942                	ld	s2,48(sp)
 660:	79a2                	ld	s3,40(sp)
 662:	6161                	addi	sp,sp,80
 664:	8082                	ret
  neg = 0;
 666:	4301                	li	t1,0
 668:	bfbd                	j	5e6 <printint+0x1a>

000000000000066a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 66a:	711d                	addi	sp,sp,-96
 66c:	ec86                	sd	ra,88(sp)
 66e:	e8a2                	sd	s0,80(sp)
 670:	e4a6                	sd	s1,72(sp)
 672:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 674:	0005c483          	lbu	s1,0(a1)
 678:	22048363          	beqz	s1,89e <vprintf+0x234>
 67c:	e0ca                	sd	s2,64(sp)
 67e:	fc4e                	sd	s3,56(sp)
 680:	f852                	sd	s4,48(sp)
 682:	f456                	sd	s5,40(sp)
 684:	f05a                	sd	s6,32(sp)
 686:	ec5e                	sd	s7,24(sp)
 688:	e862                	sd	s8,16(sp)
 68a:	8b2a                	mv	s6,a0
 68c:	8a2e                	mv	s4,a1
 68e:	8bb2                	mv	s7,a2
  state = 0;
 690:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 692:	4901                	li	s2,0
 694:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 696:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 69a:	06400c13          	li	s8,100
 69e:	a00d                	j	6c0 <vprintf+0x56>
        putc(fd, c0);
 6a0:	85a6                	mv	a1,s1
 6a2:	855a                	mv	a0,s6
 6a4:	f0bff0ef          	jal	5ae <putc>
 6a8:	a019                	j	6ae <vprintf+0x44>
    } else if (state == '%') {
 6aa:	03598363          	beq	s3,s5,6d0 <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 6ae:	0019079b          	addiw	a5,s2,1
 6b2:	893e                	mv	s2,a5
 6b4:	873e                	mv	a4,a5
 6b6:	97d2                	add	a5,a5,s4
 6b8:	0007c483          	lbu	s1,0(a5)
 6bc:	1c048a63          	beqz	s1,890 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 6c0:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 6c4:	fe0993e3          	bnez	s3,6aa <vprintf+0x40>
      if (c0 == '%') {
 6c8:	fd579ce3          	bne	a5,s5,6a0 <vprintf+0x36>
        state = '%';
 6cc:	89be                	mv	s3,a5
 6ce:	b7c5                	j	6ae <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 6d0:	00ea06b3          	add	a3,s4,a4
 6d4:	0016c603          	lbu	a2,1(a3)
      if (c1)
 6d8:	1c060863          	beqz	a2,8a8 <vprintf+0x23e>
      if (c0 == 'd') {
 6dc:	03878763          	beq	a5,s8,70a <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 6e0:	f9478693          	addi	a3,a5,-108
 6e4:	0016b693          	seqz	a3,a3
 6e8:	f9c60593          	addi	a1,a2,-100
 6ec:	e99d                	bnez	a1,722 <vprintf+0xb8>
 6ee:	ca95                	beqz	a3,722 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6f0:	008b8493          	addi	s1,s7,8
 6f4:	4685                	li	a3,1
 6f6:	4629                	li	a2,10
 6f8:	000bb583          	ld	a1,0(s7)
 6fc:	855a                	mv	a0,s6
 6fe:	ecfff0ef          	jal	5cc <printint>
        i += 1;
 702:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 704:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 706:	4981                	li	s3,0
 708:	b75d                	j	6ae <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 70a:	008b8493          	addi	s1,s7,8
 70e:	4685                	li	a3,1
 710:	4629                	li	a2,10
 712:	000ba583          	lw	a1,0(s7)
 716:	855a                	mv	a0,s6
 718:	eb5ff0ef          	jal	5cc <printint>
 71c:	8ba6                	mv	s7,s1
      state = 0;
 71e:	4981                	li	s3,0
 720:	b779                	j	6ae <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 722:	9752                	add	a4,a4,s4
 724:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 728:	f9460713          	addi	a4,a2,-108
 72c:	00173713          	seqz	a4,a4
 730:	8f75                	and	a4,a4,a3
 732:	f9c58513          	addi	a0,a1,-100
 736:	18051363          	bnez	a0,8bc <vprintf+0x252>
 73a:	18070163          	beqz	a4,8bc <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 73e:	008b8493          	addi	s1,s7,8
 742:	4685                	li	a3,1
 744:	4629                	li	a2,10
 746:	000bb583          	ld	a1,0(s7)
 74a:	855a                	mv	a0,s6
 74c:	e81ff0ef          	jal	5cc <printint>
        i += 2;
 750:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 752:	8ba6                	mv	s7,s1
      state = 0;
 754:	4981                	li	s3,0
        i += 2;
 756:	bfa1                	j	6ae <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 758:	008b8493          	addi	s1,s7,8
 75c:	4681                	li	a3,0
 75e:	4629                	li	a2,10
 760:	000be583          	lwu	a1,0(s7)
 764:	855a                	mv	a0,s6
 766:	e67ff0ef          	jal	5cc <printint>
 76a:	8ba6                	mv	s7,s1
      state = 0;
 76c:	4981                	li	s3,0
 76e:	b781                	j	6ae <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 770:	008b8493          	addi	s1,s7,8
 774:	4681                	li	a3,0
 776:	4629                	li	a2,10
 778:	000bb583          	ld	a1,0(s7)
 77c:	855a                	mv	a0,s6
 77e:	e4fff0ef          	jal	5cc <printint>
        i += 1;
 782:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 784:	8ba6                	mv	s7,s1
      state = 0;
 786:	4981                	li	s3,0
 788:	b71d                	j	6ae <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 78a:	008b8493          	addi	s1,s7,8
 78e:	4681                	li	a3,0
 790:	4629                	li	a2,10
 792:	000bb583          	ld	a1,0(s7)
 796:	855a                	mv	a0,s6
 798:	e35ff0ef          	jal	5cc <printint>
        i += 2;
 79c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 79e:	8ba6                	mv	s7,s1
      state = 0;
 7a0:	4981                	li	s3,0
        i += 2;
 7a2:	b731                	j	6ae <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 7a4:	008b8493          	addi	s1,s7,8
 7a8:	4681                	li	a3,0
 7aa:	4641                	li	a2,16
 7ac:	000be583          	lwu	a1,0(s7)
 7b0:	855a                	mv	a0,s6
 7b2:	e1bff0ef          	jal	5cc <printint>
 7b6:	8ba6                	mv	s7,s1
      state = 0;
 7b8:	4981                	li	s3,0
 7ba:	bdd5                	j	6ae <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7bc:	008b8493          	addi	s1,s7,8
 7c0:	4681                	li	a3,0
 7c2:	4641                	li	a2,16
 7c4:	000bb583          	ld	a1,0(s7)
 7c8:	855a                	mv	a0,s6
 7ca:	e03ff0ef          	jal	5cc <printint>
        i += 1;
 7ce:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7d0:	8ba6                	mv	s7,s1
      state = 0;
 7d2:	4981                	li	s3,0
 7d4:	bde9                	j	6ae <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7d6:	008b8493          	addi	s1,s7,8
 7da:	4681                	li	a3,0
 7dc:	4641                	li	a2,16
 7de:	000bb583          	ld	a1,0(s7)
 7e2:	855a                	mv	a0,s6
 7e4:	de9ff0ef          	jal	5cc <printint>
        i += 2;
 7e8:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7ea:	8ba6                	mv	s7,s1
      state = 0;
 7ec:	4981                	li	s3,0
        i += 2;
 7ee:	b5c1                	j	6ae <vprintf+0x44>
 7f0:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 7f2:	008b8793          	addi	a5,s7,8
 7f6:	8cbe                	mv	s9,a5
 7f8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7fc:	03000593          	li	a1,48
 800:	855a                	mv	a0,s6
 802:	dadff0ef          	jal	5ae <putc>
  putc(fd, 'x');
 806:	07800593          	li	a1,120
 80a:	855a                	mv	a0,s6
 80c:	da3ff0ef          	jal	5ae <putc>
 810:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 812:	00001b97          	auipc	s7,0x1
 816:	896b8b93          	addi	s7,s7,-1898 # 10a8 <digits>
 81a:	03c9d793          	srli	a5,s3,0x3c
 81e:	97de                	add	a5,a5,s7
 820:	0007c583          	lbu	a1,0(a5)
 824:	855a                	mv	a0,s6
 826:	d89ff0ef          	jal	5ae <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 82a:	0992                	slli	s3,s3,0x4
 82c:	34fd                	addiw	s1,s1,-1
 82e:	f4f5                	bnez	s1,81a <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 830:	8be6                	mv	s7,s9
      state = 0;
 832:	4981                	li	s3,0
 834:	6ca2                	ld	s9,8(sp)
 836:	bda5                	j	6ae <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 838:	008b8493          	addi	s1,s7,8
 83c:	000bc583          	lbu	a1,0(s7)
 840:	855a                	mv	a0,s6
 842:	d6dff0ef          	jal	5ae <putc>
 846:	8ba6                	mv	s7,s1
      state = 0;
 848:	4981                	li	s3,0
 84a:	b595                	j	6ae <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 84c:	008b8993          	addi	s3,s7,8
 850:	000bb483          	ld	s1,0(s7)
 854:	cc91                	beqz	s1,870 <vprintf+0x206>
        for (; *s; s++)
 856:	0004c583          	lbu	a1,0(s1)
 85a:	c985                	beqz	a1,88a <vprintf+0x220>
          putc(fd, *s);
 85c:	855a                	mv	a0,s6
 85e:	d51ff0ef          	jal	5ae <putc>
        for (; *s; s++)
 862:	0485                	addi	s1,s1,1
 864:	0004c583          	lbu	a1,0(s1)
 868:	f9f5                	bnez	a1,85c <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 86a:	8bce                	mv	s7,s3
      state = 0;
 86c:	4981                	li	s3,0
 86e:	b581                	j	6ae <vprintf+0x44>
          s = "(null)";
 870:	00001497          	auipc	s1,0x1
 874:	83048493          	addi	s1,s1,-2000 # 10a0 <malloc+0x694>
        for (; *s; s++)
 878:	02800593          	li	a1,40
 87c:	b7c5                	j	85c <vprintf+0x1f2>
        putc(fd, '%');
 87e:	85be                	mv	a1,a5
 880:	855a                	mv	a0,s6
 882:	d2dff0ef          	jal	5ae <putc>
      state = 0;
 886:	4981                	li	s3,0
 888:	b51d                	j	6ae <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 88a:	8bce                	mv	s7,s3
      state = 0;
 88c:	4981                	li	s3,0
 88e:	b505                	j	6ae <vprintf+0x44>
 890:	6906                	ld	s2,64(sp)
 892:	79e2                	ld	s3,56(sp)
 894:	7a42                	ld	s4,48(sp)
 896:	7aa2                	ld	s5,40(sp)
 898:	7b02                	ld	s6,32(sp)
 89a:	6be2                	ld	s7,24(sp)
 89c:	6c42                	ld	s8,16(sp)
    }
  }
}
 89e:	60e6                	ld	ra,88(sp)
 8a0:	6446                	ld	s0,80(sp)
 8a2:	64a6                	ld	s1,72(sp)
 8a4:	6125                	addi	sp,sp,96
 8a6:	8082                	ret
      if (c0 == 'd') {
 8a8:	06400713          	li	a4,100
 8ac:	e4e78fe3          	beq	a5,a4,70a <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 8b0:	f9478693          	addi	a3,a5,-108
 8b4:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 8b8:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 8ba:	4701                	li	a4,0
      } else if (c0 == 'u') {
 8bc:	07500513          	li	a0,117
 8c0:	e8a78ce3          	beq	a5,a0,758 <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 8c4:	f8b60513          	addi	a0,a2,-117
 8c8:	e119                	bnez	a0,8ce <vprintf+0x264>
 8ca:	ea0693e3          	bnez	a3,770 <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 8ce:	f8b58513          	addi	a0,a1,-117
 8d2:	e119                	bnez	a0,8d8 <vprintf+0x26e>
 8d4:	ea071be3          	bnez	a4,78a <vprintf+0x120>
      } else if (c0 == 'x') {
 8d8:	07800513          	li	a0,120
 8dc:	eca784e3          	beq	a5,a0,7a4 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 8e0:	f8860613          	addi	a2,a2,-120
 8e4:	e219                	bnez	a2,8ea <vprintf+0x280>
 8e6:	ec069be3          	bnez	a3,7bc <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 8ea:	f8858593          	addi	a1,a1,-120
 8ee:	e199                	bnez	a1,8f4 <vprintf+0x28a>
 8f0:	ee0713e3          	bnez	a4,7d6 <vprintf+0x16c>
      } else if (c0 == 'p') {
 8f4:	07000713          	li	a4,112
 8f8:	eee78ce3          	beq	a5,a4,7f0 <vprintf+0x186>
      } else if (c0 == 'c') {
 8fc:	06300713          	li	a4,99
 900:	f2e78ce3          	beq	a5,a4,838 <vprintf+0x1ce>
      } else if (c0 == 's') {
 904:	07300713          	li	a4,115
 908:	f4e782e3          	beq	a5,a4,84c <vprintf+0x1e2>
      } else if (c0 == '%') {
 90c:	02500713          	li	a4,37
 910:	f6e787e3          	beq	a5,a4,87e <vprintf+0x214>
        putc(fd, '%');
 914:	02500593          	li	a1,37
 918:	855a                	mv	a0,s6
 91a:	c95ff0ef          	jal	5ae <putc>
        putc(fd, c0);
 91e:	85a6                	mv	a1,s1
 920:	855a                	mv	a0,s6
 922:	c8dff0ef          	jal	5ae <putc>
      state = 0;
 926:	4981                	li	s3,0
 928:	b359                	j	6ae <vprintf+0x44>

000000000000092a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 92a:	715d                	addi	sp,sp,-80
 92c:	ec06                	sd	ra,24(sp)
 92e:	e822                	sd	s0,16(sp)
 930:	1000                	addi	s0,sp,32
 932:	e010                	sd	a2,0(s0)
 934:	e414                	sd	a3,8(s0)
 936:	e818                	sd	a4,16(s0)
 938:	ec1c                	sd	a5,24(s0)
 93a:	03043023          	sd	a6,32(s0)
 93e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 942:	8622                	mv	a2,s0
 944:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 948:	d23ff0ef          	jal	66a <vprintf>
}
 94c:	60e2                	ld	ra,24(sp)
 94e:	6442                	ld	s0,16(sp)
 950:	6161                	addi	sp,sp,80
 952:	8082                	ret

0000000000000954 <printf>:

void
printf(const char *fmt, ...)
{
 954:	711d                	addi	sp,sp,-96
 956:	ec06                	sd	ra,24(sp)
 958:	e822                	sd	s0,16(sp)
 95a:	1000                	addi	s0,sp,32
 95c:	e40c                	sd	a1,8(s0)
 95e:	e810                	sd	a2,16(s0)
 960:	ec14                	sd	a3,24(s0)
 962:	f018                	sd	a4,32(s0)
 964:	f41c                	sd	a5,40(s0)
 966:	03043823          	sd	a6,48(s0)
 96a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 96e:	00840613          	addi	a2,s0,8
 972:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 976:	85aa                	mv	a1,a0
 978:	4505                	li	a0,1
 97a:	cf1ff0ef          	jal	66a <vprintf>
}
 97e:	60e2                	ld	ra,24(sp)
 980:	6442                	ld	s0,16(sp)
 982:	6125                	addi	sp,sp,96
 984:	8082                	ret

0000000000000986 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 986:	1141                	addi	sp,sp,-16
 988:	e406                	sd	ra,8(sp)
 98a:	e022                	sd	s0,0(sp)
 98c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 98e:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 992:	00001797          	auipc	a5,0x1
 996:	66e7b783          	ld	a5,1646(a5) # 2000 <freep>
 99a:	a039                	j	9a8 <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 99c:	6398                	ld	a4,0(a5)
 99e:	00e7e463          	bltu	a5,a4,9a6 <free+0x20>
 9a2:	00e6ea63          	bltu	a3,a4,9b6 <free+0x30>
{
 9a6:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9a8:	fed7fae3          	bgeu	a5,a3,99c <free+0x16>
 9ac:	6398                	ld	a4,0(a5)
 9ae:	00e6e463          	bltu	a3,a4,9b6 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9b2:	fee7eae3          	bltu	a5,a4,9a6 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 9b6:	ff852583          	lw	a1,-8(a0)
 9ba:	6390                	ld	a2,0(a5)
 9bc:	02059813          	slli	a6,a1,0x20
 9c0:	01c85713          	srli	a4,a6,0x1c
 9c4:	9736                	add	a4,a4,a3
 9c6:	02e60563          	beq	a2,a4,9f0 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 9ca:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 9ce:	4790                	lw	a2,8(a5)
 9d0:	02061593          	slli	a1,a2,0x20
 9d4:	01c5d713          	srli	a4,a1,0x1c
 9d8:	973e                	add	a4,a4,a5
 9da:	02e68263          	beq	a3,a4,9fe <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 9de:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9e0:	00001717          	auipc	a4,0x1
 9e4:	62f73023          	sd	a5,1568(a4) # 2000 <freep>
}
 9e8:	60a2                	ld	ra,8(sp)
 9ea:	6402                	ld	s0,0(sp)
 9ec:	0141                	addi	sp,sp,16
 9ee:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 9f0:	4618                	lw	a4,8(a2)
 9f2:	9f2d                	addw	a4,a4,a1
 9f4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9f8:	6398                	ld	a4,0(a5)
 9fa:	6310                	ld	a2,0(a4)
 9fc:	b7f9                	j	9ca <free+0x44>
    p->s.size += bp->s.size;
 9fe:	ff852703          	lw	a4,-8(a0)
 a02:	9f31                	addw	a4,a4,a2
 a04:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a06:	ff053683          	ld	a3,-16(a0)
 a0a:	bfd1                	j	9de <free+0x58>

0000000000000a0c <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 a0c:	7139                	addi	sp,sp,-64
 a0e:	fc06                	sd	ra,56(sp)
 a10:	f822                	sd	s0,48(sp)
 a12:	f04a                	sd	s2,32(sp)
 a14:	ec4e                	sd	s3,24(sp)
 a16:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 a18:	02051993          	slli	s3,a0,0x20
 a1c:	0209d993          	srli	s3,s3,0x20
 a20:	09bd                	addi	s3,s3,15
 a22:	0049d993          	srli	s3,s3,0x4
 a26:	2985                	addiw	s3,s3,1
 a28:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 a2a:	00001517          	auipc	a0,0x1
 a2e:	5d653503          	ld	a0,1494(a0) # 2000 <freep>
 a32:	c905                	beqz	a0,a62 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 a34:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 a36:	4798                	lw	a4,8(a5)
 a38:	09377663          	bgeu	a4,s3,ac4 <malloc+0xb8>
 a3c:	f426                	sd	s1,40(sp)
 a3e:	e852                	sd	s4,16(sp)
 a40:	e456                	sd	s5,8(sp)
 a42:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 a44:	8a4e                	mv	s4,s3
 a46:	6705                	lui	a4,0x1
 a48:	00e9f363          	bgeu	s3,a4,a4e <malloc+0x42>
 a4c:	6a05                	lui	s4,0x1
 a4e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a52:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 a56:	00001497          	auipc	s1,0x1
 a5a:	5aa48493          	addi	s1,s1,1450 # 2000 <freep>
  if (p == SBRK_ERROR)
 a5e:	5afd                	li	s5,-1
 a60:	a83d                	j	a9e <malloc+0x92>
 a62:	f426                	sd	s1,40(sp)
 a64:	e852                	sd	s4,16(sp)
 a66:	e456                	sd	s5,8(sp)
 a68:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a6a:	00001797          	auipc	a5,0x1
 a6e:	5a678793          	addi	a5,a5,1446 # 2010 <base>
 a72:	00001717          	auipc	a4,0x1
 a76:	58f73723          	sd	a5,1422(a4) # 2000 <freep>
 a7a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a7c:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 a80:	b7d1                	j	a44 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 a82:	6398                	ld	a4,0(a5)
 a84:	e118                	sd	a4,0(a0)
 a86:	a899                	j	adc <malloc+0xd0>
  hp->s.size = nu;
 a88:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 a8c:	0541                	addi	a0,a0,16
 a8e:	ef9ff0ef          	jal	986 <free>
  return freep;
 a92:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 a94:	c125                	beqz	a0,af4 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 a96:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 a98:	4798                	lw	a4,8(a5)
 a9a:	03277163          	bgeu	a4,s2,abc <malloc+0xb0>
    if (p == freep)
 a9e:	6098                	ld	a4,0(s1)
 aa0:	853e                	mv	a0,a5
 aa2:	fef71ae3          	bne	a4,a5,a96 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 aa6:	8552                	mv	a0,s4
 aa8:	a23ff0ef          	jal	4ca <sbrk>
  if (p == SBRK_ERROR)
 aac:	fd551ee3          	bne	a0,s5,a88 <malloc+0x7c>
        return 0;
 ab0:	4501                	li	a0,0
 ab2:	74a2                	ld	s1,40(sp)
 ab4:	6a42                	ld	s4,16(sp)
 ab6:	6aa2                	ld	s5,8(sp)
 ab8:	6b02                	ld	s6,0(sp)
 aba:	a03d                	j	ae8 <malloc+0xdc>
 abc:	74a2                	ld	s1,40(sp)
 abe:	6a42                	ld	s4,16(sp)
 ac0:	6aa2                	ld	s5,8(sp)
 ac2:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 ac4:	fae90fe3          	beq	s2,a4,a82 <malloc+0x76>
        p->s.size -= nunits;
 ac8:	4137073b          	subw	a4,a4,s3
 acc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ace:	02071693          	slli	a3,a4,0x20
 ad2:	01c6d713          	srli	a4,a3,0x1c
 ad6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 ad8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 adc:	00001717          	auipc	a4,0x1
 ae0:	52a73223          	sd	a0,1316(a4) # 2000 <freep>
      return (void *)(p + 1);
 ae4:	01078513          	addi	a0,a5,16
  }
}
 ae8:	70e2                	ld	ra,56(sp)
 aea:	7442                	ld	s0,48(sp)
 aec:	7902                	ld	s2,32(sp)
 aee:	69e2                	ld	s3,24(sp)
 af0:	6121                	addi	sp,sp,64
 af2:	8082                	ret
 af4:	74a2                	ld	s1,40(sp)
 af6:	6a42                	ld	s4,16(sp)
 af8:	6aa2                	ld	s5,8(sp)
 afa:	6b02                	ld	s6,0(sp)
 afc:	b7f5                	j	ae8 <malloc+0xdc>
