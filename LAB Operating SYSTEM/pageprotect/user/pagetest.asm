
user/_pagetest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	1800                	addi	s0,sp,48
  printf("============================================================\n");
   8:	00001517          	auipc	a0,0x1
   c:	b5850513          	addi	a0,a0,-1192 # b60 <malloc+0xfc>
  10:	19d000ef          	jal	9ac <printf>
  printf("  Page Table Management & Page Protection Test (pagetest)   \n");
  14:	00001517          	auipc	a0,0x1
  18:	b9450513          	addi	a0,a0,-1132 # ba8 <malloc+0x144>
  1c:	191000ef          	jal	9ac <printf>
  printf("============================================================\n\n");
  20:	00001517          	auipc	a0,0x1
  24:	bc850513          	addi	a0,a0,-1080 # be8 <malloc+0x184>
  28:	185000ef          	jal	9ac <printf>

  printf("--- 1. Allocating a physical page using sbrk(4096) ---\n");
  2c:	00001517          	auipc	a0,0x1
  30:	bfc50513          	addi	a0,a0,-1028 # c28 <malloc+0x1c4>
  34:	179000ef          	jal	9ac <printf>
  char *p = sbrk(4096);
  38:	6505                	lui	a0,0x1
  3a:	4e0000ef          	jal	51a <sbrk>
  if (p == (char *)-1) {
  3e:	57fd                	li	a5,-1
  40:	12f50163          	beq	a0,a5,162 <main+0x162>
  44:	ec26                	sd	s1,24(sp)
  46:	84aa                	mv	s1,a0
    printf("sbrk(4096) failed!\n");
    exit(1);
  }
  printf("Allocated page at Virtual Address: 0x%lx\n\n", (uint64)p);
  48:	85aa                	mv	a1,a0
  4a:	00001517          	auipc	a0,0x1
  4e:	c2e50513          	addi	a0,a0,-978 # c78 <malloc+0x214>
  52:	15b000ef          	jal	9ac <printf>

  printf("--- 2. Writing initial data to the allocated page ---\n");
  56:	00001517          	auipc	a0,0x1
  5a:	c5250513          	addi	a0,a0,-942 # ca8 <malloc+0x244>
  5e:	14f000ef          	jal	9ac <printf>
  *p = 'H';
  62:	04800793          	li	a5,72
  66:	00f48023          	sb	a5,0(s1)
  *(p + 1) = 'I';
  6a:	04900793          	li	a5,73
  6e:	00f480a3          	sb	a5,1(s1)
  *(p + 2) = '\0';
  72:	00048123          	sb	zero,2(s1)
  printf("Successfully wrote \"%s\" to page at 0x%lx\n\n", p, (uint64)p);
  76:	8626                	mv	a2,s1
  78:	85a6                	mv	a1,s1
  7a:	00001517          	auipc	a0,0x1
  7e:	c6650513          	addi	a0,a0,-922 # ce0 <malloc+0x27c>
  82:	12b000ef          	jal	9ac <printf>

  printf("--- 3. Checking pageinfo BEFORE setreadonly ---\n");
  86:	00001517          	auipc	a0,0x1
  8a:	c8a50513          	addi	a0,a0,-886 # d10 <malloc+0x2ac>
  8e:	11f000ef          	jal	9ac <printf>
  if (pageinfo((uint64)p) < 0) {
  92:	8526                	mv	a0,s1
  94:	562000ef          	jal	5f6 <pageinfo>
  98:	0c054f63          	bltz	a0,176 <main+0x176>
    printf("pageinfo failed!\n");
    exit(1);
  }
  printf("Expected: Present=1, Writable=1, User=1\n\n");
  9c:	00001517          	auipc	a0,0x1
  a0:	cc450513          	addi	a0,a0,-828 # d60 <malloc+0x2fc>
  a4:	109000ef          	jal	9ac <printf>

  printf("--- 4. Invoking setreadonly() to mark page READ-ONLY ---\n");
  a8:	00001517          	auipc	a0,0x1
  ac:	ce850513          	addi	a0,a0,-792 # d90 <malloc+0x32c>
  b0:	0fd000ef          	jal	9ac <printf>
  if (setreadonly((uint64)p) < 0) {
  b4:	8526                	mv	a0,s1
  b6:	548000ef          	jal	5fe <setreadonly>
  ba:	0c054763          	bltz	a0,188 <main+0x188>
    printf("setreadonly failed!\n");
    exit(1);
  }
  printf("setreadonly() returned success.\n\n");
  be:	00001517          	auipc	a0,0x1
  c2:	d2a50513          	addi	a0,a0,-726 # de8 <malloc+0x384>
  c6:	0e7000ef          	jal	9ac <printf>

  printf("--- 5. Checking pageinfo AFTER setreadonly ---\n");
  ca:	00001517          	auipc	a0,0x1
  ce:	d4650513          	addi	a0,a0,-698 # e10 <malloc+0x3ac>
  d2:	0db000ef          	jal	9ac <printf>
  if (pageinfo((uint64)p) < 0) {
  d6:	8526                	mv	a0,s1
  d8:	51e000ef          	jal	5f6 <pageinfo>
  dc:	0a054f63          	bltz	a0,19a <main+0x19a>
    printf("pageinfo failed!\n");
    exit(1);
  }
  printf("Expected: Present=1, Writable=0, User=1 (Write permission removed!)\n\n");
  e0:	00001517          	auipc	a0,0x1
  e4:	d6050513          	addi	a0,a0,-672 # e40 <malloc+0x3dc>
  e8:	0c5000ef          	jal	9ac <printf>

  printf("--- 6. Verifying READ operations still succeed ---\n");
  ec:	00001517          	auipc	a0,0x1
  f0:	d9c50513          	addi	a0,a0,-612 # e88 <malloc+0x424>
  f4:	0b9000ef          	jal	9ac <printf>
  printf("Read value from read-only page: '%c%c'\n", *p, *(p + 1));
  f8:	0014c603          	lbu	a2,1(s1)
  fc:	0004c583          	lbu	a1,0(s1)
 100:	00001517          	auipc	a0,0x1
 104:	dc050513          	addi	a0,a0,-576 # ec0 <malloc+0x45c>
 108:	0a5000ef          	jal	9ac <printf>
  printf("Read verification passed!\n\n");
 10c:	00001517          	auipc	a0,0x1
 110:	ddc50513          	addi	a0,a0,-548 # ee8 <malloc+0x484>
 114:	099000ef          	jal	9ac <printf>

  printf("--- 7. Attempting WRITE to read-only page in a child process ---\n");
 118:	00001517          	auipc	a0,0x1
 11c:	df050513          	addi	a0,a0,-528 # f08 <malloc+0x4a4>
 120:	08d000ef          	jal	9ac <printf>
  int pid = fork();
 124:	422000ef          	jal	546 <fork>
  if (pid < 0) {
 128:	08054263          	bltz	a0,1ac <main+0x1ac>
    printf("fork failed!\n");
    exit(1);
  }

  if (pid == 0) {
 12c:	e949                	bnez	a0,1be <main+0x1be>
    printf("[Child pid %d] Attempting to write 'X' to read-only address 0x%lx...\n", getpid(), (uint64)p);
 12e:	4a0000ef          	jal	5ce <getpid>
 132:	85aa                	mv	a1,a0
 134:	8626                	mv	a2,s1
 136:	00001517          	auipc	a0,0x1
 13a:	e2a50513          	addi	a0,a0,-470 # f60 <malloc+0x4fc>
 13e:	06f000ef          	jal	9ac <printf>
    // This write MUST trigger a store page fault exception in hardware MMU!
    *p = 'X';
 142:	05800793          	li	a5,88
 146:	00f48023          	sb	a5,0(s1)
    // If execution reaches here, protection failed!
    printf("[Child pid %d] ERROR: Write succeeded on read-only page!\n", getpid());
 14a:	484000ef          	jal	5ce <getpid>
 14e:	85aa                	mv	a1,a0
 150:	00001517          	auipc	a0,0x1
 154:	e5850513          	addi	a0,a0,-424 # fa8 <malloc+0x544>
 158:	055000ef          	jal	9ac <printf>
    exit(0);
 15c:	4501                	li	a0,0
 15e:	3f0000ef          	jal	54e <exit>
 162:	ec26                	sd	s1,24(sp)
    printf("sbrk(4096) failed!\n");
 164:	00001517          	auipc	a0,0x1
 168:	afc50513          	addi	a0,a0,-1284 # c60 <malloc+0x1fc>
 16c:	041000ef          	jal	9ac <printf>
    exit(1);
 170:	4505                	li	a0,1
 172:	3dc000ef          	jal	54e <exit>
    printf("pageinfo failed!\n");
 176:	00001517          	auipc	a0,0x1
 17a:	bd250513          	addi	a0,a0,-1070 # d48 <malloc+0x2e4>
 17e:	02f000ef          	jal	9ac <printf>
    exit(1);
 182:	4505                	li	a0,1
 184:	3ca000ef          	jal	54e <exit>
    printf("setreadonly failed!\n");
 188:	00001517          	auipc	a0,0x1
 18c:	c4850513          	addi	a0,a0,-952 # dd0 <malloc+0x36c>
 190:	01d000ef          	jal	9ac <printf>
    exit(1);
 194:	4505                	li	a0,1
 196:	3b8000ef          	jal	54e <exit>
    printf("pageinfo failed!\n");
 19a:	00001517          	auipc	a0,0x1
 19e:	bae50513          	addi	a0,a0,-1106 # d48 <malloc+0x2e4>
 1a2:	00b000ef          	jal	9ac <printf>
    exit(1);
 1a6:	4505                	li	a0,1
 1a8:	3a6000ef          	jal	54e <exit>
    printf("fork failed!\n");
 1ac:	00001517          	auipc	a0,0x1
 1b0:	da450513          	addi	a0,a0,-604 # f50 <malloc+0x4ec>
 1b4:	7f8000ef          	jal	9ac <printf>
    exit(1);
 1b8:	4505                	li	a0,1
 1ba:	394000ef          	jal	54e <exit>
  } else {
    int status = 0;
 1be:	fc042e23          	sw	zero,-36(s0)
    wait(&status);
 1c2:	fdc40513          	addi	a0,s0,-36
 1c6:	390000ef          	jal	556 <wait>
    printf("[Parent] Child process terminated with status %d.\n", status);
 1ca:	fdc42583          	lw	a1,-36(s0)
 1ce:	00001517          	auipc	a0,0x1
 1d2:	e1a50513          	addi	a0,a0,-486 # fe8 <malloc+0x584>
 1d6:	7d6000ef          	jal	9ac <printf>
    if (status != 0) {
 1da:	fdc42783          	lw	a5,-36(s0)
 1de:	c7d5                	beqz	a5,28a <main+0x28a>
      printf("[Parent] SUCCESS: Child process was killed by kernel due to page fault exception!\n");
 1e0:	00001517          	auipc	a0,0x1
 1e4:	e4050513          	addi	a0,a0,-448 # 1020 <malloc+0x5bc>
 1e8:	7c4000ef          	jal	9ac <printf>
    } else {
      printf("[Parent] FAILED: Child process exited normally without page fault.\n");
    }
  }
  printf("\n");
 1ec:	00001517          	auipc	a0,0x1
 1f0:	ed450513          	addi	a0,a0,-300 # 10c0 <malloc+0x65c>
 1f4:	7b8000ef          	jal	9ac <printf>

  printf("--- 8. Testing unmapped address error handling ---\n");
 1f8:	00001517          	auipc	a0,0x1
 1fc:	ed050513          	addi	a0,a0,-304 # 10c8 <malloc+0x664>
 200:	7ac000ef          	jal	9ac <printf>
  uint64 unmapped = 0x7FFFFFF0;
  printf("Calling pageinfo on unmapped address 0x%lx:\n", unmapped);
 204:	800005b7          	lui	a1,0x80000
 208:	ff05c593          	xori	a1,a1,-16
 20c:	00001517          	auipc	a0,0x1
 210:	ef450513          	addi	a0,a0,-268 # 1100 <malloc+0x69c>
 214:	798000ef          	jal	9ac <printf>
  int r1 = pageinfo(unmapped);
 218:	80000537          	lui	a0,0x80000
 21c:	ff054513          	xori	a0,a0,-16
 220:	3d6000ef          	jal	5f6 <pageinfo>
 224:	85aa                	mv	a1,a0
  printf("pageinfo returned: %d (expected -1)\n", r1);
 226:	00001517          	auipc	a0,0x1
 22a:	f0a50513          	addi	a0,a0,-246 # 1130 <malloc+0x6cc>
 22e:	77e000ef          	jal	9ac <printf>

  printf("Calling setreadonly on unmapped address 0x%lx:\n", unmapped);
 232:	800005b7          	lui	a1,0x80000
 236:	ff05c593          	xori	a1,a1,-16
 23a:	00001517          	auipc	a0,0x1
 23e:	f1e50513          	addi	a0,a0,-226 # 1158 <malloc+0x6f4>
 242:	76a000ef          	jal	9ac <printf>
  int r2 = setreadonly(unmapped);
 246:	80000537          	lui	a0,0x80000
 24a:	ff054513          	xori	a0,a0,-16
 24e:	3b0000ef          	jal	5fe <setreadonly>
 252:	85aa                	mv	a1,a0
  printf("setreadonly returned: %d (expected -1)\n\n", r2);
 254:	00001517          	auipc	a0,0x1
 258:	f3450513          	addi	a0,a0,-204 # 1188 <malloc+0x724>
 25c:	750000ef          	jal	9ac <printf>

  printf("============================================================\n");
 260:	00001517          	auipc	a0,0x1
 264:	90050513          	addi	a0,a0,-1792 # b60 <malloc+0xfc>
 268:	744000ef          	jal	9ac <printf>
  printf("pagetest: All page protection tests completed successfully!\n");
 26c:	00001517          	auipc	a0,0x1
 270:	f4c50513          	addi	a0,a0,-180 # 11b8 <malloc+0x754>
 274:	738000ef          	jal	9ac <printf>
  printf("============================================================\n");
 278:	00001517          	auipc	a0,0x1
 27c:	8e850513          	addi	a0,a0,-1816 # b60 <malloc+0xfc>
 280:	72c000ef          	jal	9ac <printf>
  exit(0);
 284:	4501                	li	a0,0
 286:	2c8000ef          	jal	54e <exit>
      printf("[Parent] FAILED: Child process exited normally without page fault.\n");
 28a:	00001517          	auipc	a0,0x1
 28e:	dee50513          	addi	a0,a0,-530 # 1078 <malloc+0x614>
 292:	71a000ef          	jal	9ac <printf>
 296:	bf99                	j	1ec <main+0x1ec>

0000000000000298 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e406                	sd	ra,8(sp)
 29c:	e022                	sd	s0,0(sp)
 29e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 2a0:	d61ff0ef          	jal	0 <main>
  exit(r);
 2a4:	2aa000ef          	jal	54e <exit>

00000000000002a8 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 2a8:	1141                	addi	sp,sp,-16
 2aa:	e406                	sd	ra,8(sp)
 2ac:	e022                	sd	s0,0(sp)
 2ae:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 2b0:	87aa                	mv	a5,a0
 2b2:	0585                	addi	a1,a1,1 # ffffffff80000001 <base+0xffffffff7fffdff1>
 2b4:	0785                	addi	a5,a5,1
 2b6:	fff5c703          	lbu	a4,-1(a1)
 2ba:	fee78fa3          	sb	a4,-1(a5)
 2be:	fb75                	bnez	a4,2b2 <strcpy+0xa>
    ;
  return os;
}
 2c0:	60a2                	ld	ra,8(sp)
 2c2:	6402                	ld	s0,0(sp)
 2c4:	0141                	addi	sp,sp,16
 2c6:	8082                	ret

00000000000002c8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2c8:	1141                	addi	sp,sp,-16
 2ca:	e406                	sd	ra,8(sp)
 2cc:	e022                	sd	s0,0(sp)
 2ce:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 2d0:	00054783          	lbu	a5,0(a0)
 2d4:	cb91                	beqz	a5,2e8 <strcmp+0x20>
 2d6:	0005c703          	lbu	a4,0(a1)
 2da:	00f71763          	bne	a4,a5,2e8 <strcmp+0x20>
    p++, q++;
 2de:	0505                	addi	a0,a0,1
 2e0:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 2e2:	00054783          	lbu	a5,0(a0)
 2e6:	fbe5                	bnez	a5,2d6 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 2e8:	0005c503          	lbu	a0,0(a1)
}
 2ec:	40a7853b          	subw	a0,a5,a0
 2f0:	60a2                	ld	ra,8(sp)
 2f2:	6402                	ld	s0,0(sp)
 2f4:	0141                	addi	sp,sp,16
 2f6:	8082                	ret

00000000000002f8 <strlen>:

uint
strlen(const char *s)
{
 2f8:	1141                	addi	sp,sp,-16
 2fa:	e406                	sd	ra,8(sp)
 2fc:	e022                	sd	s0,0(sp)
 2fe:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 300:	00054783          	lbu	a5,0(a0)
 304:	cf91                	beqz	a5,320 <strlen+0x28>
 306:	00150793          	addi	a5,a0,1
 30a:	86be                	mv	a3,a5
 30c:	0785                	addi	a5,a5,1
 30e:	fff7c703          	lbu	a4,-1(a5)
 312:	ff65                	bnez	a4,30a <strlen+0x12>
 314:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 318:	60a2                	ld	ra,8(sp)
 31a:	6402                	ld	s0,0(sp)
 31c:	0141                	addi	sp,sp,16
 31e:	8082                	ret
  for (n = 0; s[n]; n++)
 320:	4501                	li	a0,0
 322:	bfdd                	j	318 <strlen+0x20>

0000000000000324 <memset>:

void *
memset(void *dst, int c, uint n)
{
 324:	1141                	addi	sp,sp,-16
 326:	e406                	sd	ra,8(sp)
 328:	e022                	sd	s0,0(sp)
 32a:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 32c:	ca19                	beqz	a2,342 <memset+0x1e>
 32e:	87aa                	mv	a5,a0
 330:	1602                	slli	a2,a2,0x20
 332:	9201                	srli	a2,a2,0x20
 334:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 338:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 33c:	0785                	addi	a5,a5,1
 33e:	fee79de3          	bne	a5,a4,338 <memset+0x14>
  }
  return dst;
}
 342:	60a2                	ld	ra,8(sp)
 344:	6402                	ld	s0,0(sp)
 346:	0141                	addi	sp,sp,16
 348:	8082                	ret

000000000000034a <strchr>:

char *
strchr(const char *s, char c)
{
 34a:	1141                	addi	sp,sp,-16
 34c:	e406                	sd	ra,8(sp)
 34e:	e022                	sd	s0,0(sp)
 350:	0800                	addi	s0,sp,16
  for (; *s; s++)
 352:	00054783          	lbu	a5,0(a0)
 356:	cf81                	beqz	a5,36e <strchr+0x24>
    if (*s == c)
 358:	00f58763          	beq	a1,a5,366 <strchr+0x1c>
  for (; *s; s++)
 35c:	0505                	addi	a0,a0,1
 35e:	00054783          	lbu	a5,0(a0)
 362:	fbfd                	bnez	a5,358 <strchr+0xe>
      return (char *)s;
  return 0;
 364:	4501                	li	a0,0
}
 366:	60a2                	ld	ra,8(sp)
 368:	6402                	ld	s0,0(sp)
 36a:	0141                	addi	sp,sp,16
 36c:	8082                	ret
  return 0;
 36e:	4501                	li	a0,0
 370:	bfdd                	j	366 <strchr+0x1c>

0000000000000372 <gets>:

char *
gets(char *buf, int max)
{
 372:	711d                	addi	sp,sp,-96
 374:	ec86                	sd	ra,88(sp)
 376:	e8a2                	sd	s0,80(sp)
 378:	e4a6                	sd	s1,72(sp)
 37a:	e0ca                	sd	s2,64(sp)
 37c:	fc4e                	sd	s3,56(sp)
 37e:	f852                	sd	s4,48(sp)
 380:	f456                	sd	s5,40(sp)
 382:	f05a                	sd	s6,32(sp)
 384:	ec5e                	sd	s7,24(sp)
 386:	e862                	sd	s8,16(sp)
 388:	1080                	addi	s0,sp,96
 38a:	8baa                	mv	s7,a0
 38c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 38e:	892a                	mv	s2,a0
 390:	4481                	li	s1,0
    cc = read(0, &c, 1);
 392:	faf40b13          	addi	s6,s0,-81
 396:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 398:	8c26                	mv	s8,s1
 39a:	0014899b          	addiw	s3,s1,1
 39e:	84ce                	mv	s1,s3
 3a0:	0349d463          	bge	s3,s4,3c8 <gets+0x56>
    cc = read(0, &c, 1);
 3a4:	8656                	mv	a2,s5
 3a6:	85da                	mv	a1,s6
 3a8:	4501                	li	a0,0
 3aa:	1bc000ef          	jal	566 <read>
    if (cc < 1)
 3ae:	00a05d63          	blez	a0,3c8 <gets+0x56>
      break;
    buf[i++] = c;
 3b2:	faf44783          	lbu	a5,-81(s0)
 3b6:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 3ba:	0905                	addi	s2,s2,1
 3bc:	ff678713          	addi	a4,a5,-10
 3c0:	c319                	beqz	a4,3c6 <gets+0x54>
 3c2:	17cd                	addi	a5,a5,-13
 3c4:	fbf1                	bnez	a5,398 <gets+0x26>
    buf[i++] = c;
 3c6:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 3c8:	9c5e                	add	s8,s8,s7
 3ca:	000c0023          	sb	zero,0(s8)
  return buf;
}
 3ce:	855e                	mv	a0,s7
 3d0:	60e6                	ld	ra,88(sp)
 3d2:	6446                	ld	s0,80(sp)
 3d4:	64a6                	ld	s1,72(sp)
 3d6:	6906                	ld	s2,64(sp)
 3d8:	79e2                	ld	s3,56(sp)
 3da:	7a42                	ld	s4,48(sp)
 3dc:	7aa2                	ld	s5,40(sp)
 3de:	7b02                	ld	s6,32(sp)
 3e0:	6be2                	ld	s7,24(sp)
 3e2:	6c42                	ld	s8,16(sp)
 3e4:	6125                	addi	sp,sp,96
 3e6:	8082                	ret

00000000000003e8 <stat>:

int
stat(const char *n, struct stat *st)
{
 3e8:	1101                	addi	sp,sp,-32
 3ea:	ec06                	sd	ra,24(sp)
 3ec:	e822                	sd	s0,16(sp)
 3ee:	e04a                	sd	s2,0(sp)
 3f0:	1000                	addi	s0,sp,32
 3f2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3f4:	4581                	li	a1,0
 3f6:	198000ef          	jal	58e <open>
  if (fd < 0)
 3fa:	02054263          	bltz	a0,41e <stat+0x36>
 3fe:	e426                	sd	s1,8(sp)
 400:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 402:	85ca                	mv	a1,s2
 404:	1a2000ef          	jal	5a6 <fstat>
 408:	892a                	mv	s2,a0
  close(fd);
 40a:	8526                	mv	a0,s1
 40c:	16a000ef          	jal	576 <close>
  return r;
 410:	64a2                	ld	s1,8(sp)
}
 412:	854a                	mv	a0,s2
 414:	60e2                	ld	ra,24(sp)
 416:	6442                	ld	s0,16(sp)
 418:	6902                	ld	s2,0(sp)
 41a:	6105                	addi	sp,sp,32
 41c:	8082                	ret
    return -1;
 41e:	57fd                	li	a5,-1
 420:	893e                	mv	s2,a5
 422:	bfc5                	j	412 <stat+0x2a>

0000000000000424 <atoi>:

int
atoi(const char *s)
{
 424:	1141                	addi	sp,sp,-16
 426:	e406                	sd	ra,8(sp)
 428:	e022                	sd	s0,0(sp)
 42a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 42c:	00054683          	lbu	a3,0(a0)
 430:	fd06879b          	addiw	a5,a3,-48
 434:	0ff7f793          	zext.b	a5,a5
 438:	4625                	li	a2,9
 43a:	02f66963          	bltu	a2,a5,46c <atoi+0x48>
 43e:	872a                	mv	a4,a0
  n = 0;
 440:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 442:	0705                	addi	a4,a4,1
 444:	0025179b          	slliw	a5,a0,0x2
 448:	9fa9                	addw	a5,a5,a0
 44a:	0017979b          	slliw	a5,a5,0x1
 44e:	9fb5                	addw	a5,a5,a3
 450:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 454:	00074683          	lbu	a3,0(a4)
 458:	fd06879b          	addiw	a5,a3,-48
 45c:	0ff7f793          	zext.b	a5,a5
 460:	fef671e3          	bgeu	a2,a5,442 <atoi+0x1e>
  return n;
}
 464:	60a2                	ld	ra,8(sp)
 466:	6402                	ld	s0,0(sp)
 468:	0141                	addi	sp,sp,16
 46a:	8082                	ret
  n = 0;
 46c:	4501                	li	a0,0
 46e:	bfdd                	j	464 <atoi+0x40>

0000000000000470 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 470:	1141                	addi	sp,sp,-16
 472:	e406                	sd	ra,8(sp)
 474:	e022                	sd	s0,0(sp)
 476:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 478:	02b57563          	bgeu	a0,a1,4a2 <memmove+0x32>
    while (n-- > 0)
 47c:	00c05f63          	blez	a2,49a <memmove+0x2a>
 480:	1602                	slli	a2,a2,0x20
 482:	9201                	srli	a2,a2,0x20
 484:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 488:	872a                	mv	a4,a0
      *dst++ = *src++;
 48a:	0585                	addi	a1,a1,1
 48c:	0705                	addi	a4,a4,1
 48e:	fff5c683          	lbu	a3,-1(a1)
 492:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 496:	fee79ae3          	bne	a5,a4,48a <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 49a:	60a2                	ld	ra,8(sp)
 49c:	6402                	ld	s0,0(sp)
 49e:	0141                	addi	sp,sp,16
 4a0:	8082                	ret
    while (n-- > 0)
 4a2:	fec05ce3          	blez	a2,49a <memmove+0x2a>
    dst += n;
 4a6:	00c50733          	add	a4,a0,a2
    src += n;
 4aa:	95b2                	add	a1,a1,a2
 4ac:	fff6079b          	addiw	a5,a2,-1
 4b0:	1782                	slli	a5,a5,0x20
 4b2:	9381                	srli	a5,a5,0x20
 4b4:	fff7c793          	not	a5,a5
 4b8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4ba:	15fd                	addi	a1,a1,-1
 4bc:	177d                	addi	a4,a4,-1
 4be:	0005c683          	lbu	a3,0(a1)
 4c2:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 4c6:	fef71ae3          	bne	a4,a5,4ba <memmove+0x4a>
 4ca:	bfc1                	j	49a <memmove+0x2a>

00000000000004cc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4cc:	1141                	addi	sp,sp,-16
 4ce:	e406                	sd	ra,8(sp)
 4d0:	e022                	sd	s0,0(sp)
 4d2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4d4:	c61d                	beqz	a2,502 <memcmp+0x36>
 4d6:	1602                	slli	a2,a2,0x20
 4d8:	9201                	srli	a2,a2,0x20
 4da:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 4de:	00054783          	lbu	a5,0(a0)
 4e2:	0005c703          	lbu	a4,0(a1)
 4e6:	00e79863          	bne	a5,a4,4f6 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 4ea:	0505                	addi	a0,a0,1
    p2++;
 4ec:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4ee:	fed518e3          	bne	a0,a3,4de <memcmp+0x12>
  }
  return 0;
 4f2:	4501                	li	a0,0
 4f4:	a019                	j	4fa <memcmp+0x2e>
      return *p1 - *p2;
 4f6:	40e7853b          	subw	a0,a5,a4
}
 4fa:	60a2                	ld	ra,8(sp)
 4fc:	6402                	ld	s0,0(sp)
 4fe:	0141                	addi	sp,sp,16
 500:	8082                	ret
  return 0;
 502:	4501                	li	a0,0
 504:	bfdd                	j	4fa <memcmp+0x2e>

0000000000000506 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 506:	1141                	addi	sp,sp,-16
 508:	e406                	sd	ra,8(sp)
 50a:	e022                	sd	s0,0(sp)
 50c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 50e:	f63ff0ef          	jal	470 <memmove>
}
 512:	60a2                	ld	ra,8(sp)
 514:	6402                	ld	s0,0(sp)
 516:	0141                	addi	sp,sp,16
 518:	8082                	ret

000000000000051a <sbrk>:

char *
sbrk(int n)
{
 51a:	1141                	addi	sp,sp,-16
 51c:	e406                	sd	ra,8(sp)
 51e:	e022                	sd	s0,0(sp)
 520:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 522:	4585                	li	a1,1
 524:	0b2000ef          	jal	5d6 <sys_sbrk>
}
 528:	60a2                	ld	ra,8(sp)
 52a:	6402                	ld	s0,0(sp)
 52c:	0141                	addi	sp,sp,16
 52e:	8082                	ret

0000000000000530 <sbrklazy>:

char *
sbrklazy(int n)
{
 530:	1141                	addi	sp,sp,-16
 532:	e406                	sd	ra,8(sp)
 534:	e022                	sd	s0,0(sp)
 536:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 538:	4589                	li	a1,2
 53a:	09c000ef          	jal	5d6 <sys_sbrk>
}
 53e:	60a2                	ld	ra,8(sp)
 540:	6402                	ld	s0,0(sp)
 542:	0141                	addi	sp,sp,16
 544:	8082                	ret

0000000000000546 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 546:	4885                	li	a7,1
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <exit>:
.global exit
exit:
 li a7, SYS_exit
 54e:	4889                	li	a7,2
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <wait>:
.global wait
wait:
 li a7, SYS_wait
 556:	488d                	li	a7,3
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 55e:	4891                	li	a7,4
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <read>:
.global read
read:
 li a7, SYS_read
 566:	4895                	li	a7,5
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <write>:
.global write
write:
 li a7, SYS_write
 56e:	48c1                	li	a7,16
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <close>:
.global close
close:
 li a7, SYS_close
 576:	48d5                	li	a7,21
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <kill>:
.global kill
kill:
 li a7, SYS_kill
 57e:	4899                	li	a7,6
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <exec>:
.global exec
exec:
 li a7, SYS_exec
 586:	489d                	li	a7,7
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <open>:
.global open
open:
 li a7, SYS_open
 58e:	48bd                	li	a7,15
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 596:	48c5                	li	a7,17
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 59e:	48c9                	li	a7,18
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5a6:	48a1                	li	a7,8
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <link>:
.global link
link:
 li a7, SYS_link
 5ae:	48cd                	li	a7,19
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5b6:	48d1                	li	a7,20
 ecall
 5b8:	00000073          	ecall
 ret
 5bc:	8082                	ret

00000000000005be <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5be:	48a5                	li	a7,9
 ecall
 5c0:	00000073          	ecall
 ret
 5c4:	8082                	ret

00000000000005c6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5c6:	48a9                	li	a7,10
 ecall
 5c8:	00000073          	ecall
 ret
 5cc:	8082                	ret

00000000000005ce <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5ce:	48ad                	li	a7,11
 ecall
 5d0:	00000073          	ecall
 ret
 5d4:	8082                	ret

00000000000005d6 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 5d6:	48b1                	li	a7,12
 ecall
 5d8:	00000073          	ecall
 ret
 5dc:	8082                	ret

00000000000005de <pause>:
.global pause
pause:
 li a7, SYS_pause
 5de:	48b5                	li	a7,13
 ecall
 5e0:	00000073          	ecall
 ret
 5e4:	8082                	ret

00000000000005e6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5e6:	48b9                	li	a7,14
 ecall
 5e8:	00000073          	ecall
 ret
 5ec:	8082                	ret

00000000000005ee <sync>:
.global sync
sync:
 li a7, SYS_sync
 5ee:	48d9                	li	a7,22
 ecall
 5f0:	00000073          	ecall
 ret
 5f4:	8082                	ret

00000000000005f6 <pageinfo>:
.global pageinfo
pageinfo:
 li a7, SYS_pageinfo
 5f6:	48dd                	li	a7,23
 ecall
 5f8:	00000073          	ecall
 ret
 5fc:	8082                	ret

00000000000005fe <setreadonly>:
.global setreadonly
setreadonly:
 li a7, SYS_setreadonly
 5fe:	48e1                	li	a7,24
 ecall
 600:	00000073          	ecall
 ret
 604:	8082                	ret

0000000000000606 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 606:	1101                	addi	sp,sp,-32
 608:	ec06                	sd	ra,24(sp)
 60a:	e822                	sd	s0,16(sp)
 60c:	1000                	addi	s0,sp,32
 60e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 612:	4605                	li	a2,1
 614:	fef40593          	addi	a1,s0,-17
 618:	f57ff0ef          	jal	56e <write>
}
 61c:	60e2                	ld	ra,24(sp)
 61e:	6442                	ld	s0,16(sp)
 620:	6105                	addi	sp,sp,32
 622:	8082                	ret

0000000000000624 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 624:	715d                	addi	sp,sp,-80
 626:	e486                	sd	ra,72(sp)
 628:	e0a2                	sd	s0,64(sp)
 62a:	f84a                	sd	s2,48(sp)
 62c:	f44e                	sd	s3,40(sp)
 62e:	0880                	addi	s0,sp,80
 630:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 632:	c6d1                	beqz	a3,6be <printint+0x9a>
 634:	0805d563          	bgez	a1,6be <printint+0x9a>
    neg = 1;
    x = -xx;
 638:	40b005b3          	neg	a1,a1
    neg = 1;
 63c:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 63e:	fb840993          	addi	s3,s0,-72
  neg = 0;
 642:	86ce                	mv	a3,s3
  i = 0;
 644:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 646:	00001817          	auipc	a6,0x1
 64a:	bba80813          	addi	a6,a6,-1094 # 1200 <digits>
 64e:	88ba                	mv	a7,a4
 650:	0017051b          	addiw	a0,a4,1
 654:	872a                	mv	a4,a0
 656:	02c5f7b3          	remu	a5,a1,a2
 65a:	97c2                	add	a5,a5,a6
 65c:	0007c783          	lbu	a5,0(a5)
 660:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 664:	87ae                	mv	a5,a1
 666:	02c5d5b3          	divu	a1,a1,a2
 66a:	0685                	addi	a3,a3,1
 66c:	fec7f1e3          	bgeu	a5,a2,64e <printint+0x2a>
  if (neg)
 670:	00030c63          	beqz	t1,688 <printint+0x64>
    buf[i++] = '-';
 674:	fd050793          	addi	a5,a0,-48
 678:	00878533          	add	a0,a5,s0
 67c:	02d00793          	li	a5,45
 680:	fef50423          	sb	a5,-24(a0)
 684:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 688:	02e05563          	blez	a4,6b2 <printint+0x8e>
 68c:	fc26                	sd	s1,56(sp)
 68e:	377d                	addiw	a4,a4,-1
 690:	00e984b3          	add	s1,s3,a4
 694:	19fd                	addi	s3,s3,-1
 696:	99ba                	add	s3,s3,a4
 698:	1702                	slli	a4,a4,0x20
 69a:	9301                	srli	a4,a4,0x20
 69c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6a0:	0004c583          	lbu	a1,0(s1)
 6a4:	854a                	mv	a0,s2
 6a6:	f61ff0ef          	jal	606 <putc>
  while (--i >= 0)
 6aa:	14fd                	addi	s1,s1,-1
 6ac:	ff349ae3          	bne	s1,s3,6a0 <printint+0x7c>
 6b0:	74e2                	ld	s1,56(sp)
}
 6b2:	60a6                	ld	ra,72(sp)
 6b4:	6406                	ld	s0,64(sp)
 6b6:	7942                	ld	s2,48(sp)
 6b8:	79a2                	ld	s3,40(sp)
 6ba:	6161                	addi	sp,sp,80
 6bc:	8082                	ret
  neg = 0;
 6be:	4301                	li	t1,0
 6c0:	bfbd                	j	63e <printint+0x1a>

00000000000006c2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6c2:	711d                	addi	sp,sp,-96
 6c4:	ec86                	sd	ra,88(sp)
 6c6:	e8a2                	sd	s0,80(sp)
 6c8:	e4a6                	sd	s1,72(sp)
 6ca:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 6cc:	0005c483          	lbu	s1,0(a1)
 6d0:	22048363          	beqz	s1,8f6 <vprintf+0x234>
 6d4:	e0ca                	sd	s2,64(sp)
 6d6:	fc4e                	sd	s3,56(sp)
 6d8:	f852                	sd	s4,48(sp)
 6da:	f456                	sd	s5,40(sp)
 6dc:	f05a                	sd	s6,32(sp)
 6de:	ec5e                	sd	s7,24(sp)
 6e0:	e862                	sd	s8,16(sp)
 6e2:	8b2a                	mv	s6,a0
 6e4:	8a2e                	mv	s4,a1
 6e6:	8bb2                	mv	s7,a2
  state = 0;
 6e8:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 6ea:	4901                	li	s2,0
 6ec:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 6ee:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 6f2:	06400c13          	li	s8,100
 6f6:	a00d                	j	718 <vprintf+0x56>
        putc(fd, c0);
 6f8:	85a6                	mv	a1,s1
 6fa:	855a                	mv	a0,s6
 6fc:	f0bff0ef          	jal	606 <putc>
 700:	a019                	j	706 <vprintf+0x44>
    } else if (state == '%') {
 702:	03598363          	beq	s3,s5,728 <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 706:	0019079b          	addiw	a5,s2,1
 70a:	893e                	mv	s2,a5
 70c:	873e                	mv	a4,a5
 70e:	97d2                	add	a5,a5,s4
 710:	0007c483          	lbu	s1,0(a5)
 714:	1c048a63          	beqz	s1,8e8 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 718:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 71c:	fe0993e3          	bnez	s3,702 <vprintf+0x40>
      if (c0 == '%') {
 720:	fd579ce3          	bne	a5,s5,6f8 <vprintf+0x36>
        state = '%';
 724:	89be                	mv	s3,a5
 726:	b7c5                	j	706 <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 728:	00ea06b3          	add	a3,s4,a4
 72c:	0016c603          	lbu	a2,1(a3)
      if (c1)
 730:	1c060863          	beqz	a2,900 <vprintf+0x23e>
      if (c0 == 'd') {
 734:	03878763          	beq	a5,s8,762 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 738:	f9478693          	addi	a3,a5,-108
 73c:	0016b693          	seqz	a3,a3
 740:	f9c60593          	addi	a1,a2,-100
 744:	e99d                	bnez	a1,77a <vprintf+0xb8>
 746:	ca95                	beqz	a3,77a <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 748:	008b8493          	addi	s1,s7,8
 74c:	4685                	li	a3,1
 74e:	4629                	li	a2,10
 750:	000bb583          	ld	a1,0(s7)
 754:	855a                	mv	a0,s6
 756:	ecfff0ef          	jal	624 <printint>
        i += 1;
 75a:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 75c:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 75e:	4981                	li	s3,0
 760:	b75d                	j	706 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 762:	008b8493          	addi	s1,s7,8
 766:	4685                	li	a3,1
 768:	4629                	li	a2,10
 76a:	000ba583          	lw	a1,0(s7)
 76e:	855a                	mv	a0,s6
 770:	eb5ff0ef          	jal	624 <printint>
 774:	8ba6                	mv	s7,s1
      state = 0;
 776:	4981                	li	s3,0
 778:	b779                	j	706 <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 77a:	9752                	add	a4,a4,s4
 77c:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 780:	f9460713          	addi	a4,a2,-108
 784:	00173713          	seqz	a4,a4
 788:	8f75                	and	a4,a4,a3
 78a:	f9c58513          	addi	a0,a1,-100
 78e:	18051363          	bnez	a0,914 <vprintf+0x252>
 792:	18070163          	beqz	a4,914 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 796:	008b8493          	addi	s1,s7,8
 79a:	4685                	li	a3,1
 79c:	4629                	li	a2,10
 79e:	000bb583          	ld	a1,0(s7)
 7a2:	855a                	mv	a0,s6
 7a4:	e81ff0ef          	jal	624 <printint>
        i += 2;
 7a8:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7aa:	8ba6                	mv	s7,s1
      state = 0;
 7ac:	4981                	li	s3,0
        i += 2;
 7ae:	bfa1                	j	706 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 7b0:	008b8493          	addi	s1,s7,8
 7b4:	4681                	li	a3,0
 7b6:	4629                	li	a2,10
 7b8:	000be583          	lwu	a1,0(s7)
 7bc:	855a                	mv	a0,s6
 7be:	e67ff0ef          	jal	624 <printint>
 7c2:	8ba6                	mv	s7,s1
      state = 0;
 7c4:	4981                	li	s3,0
 7c6:	b781                	j	706 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7c8:	008b8493          	addi	s1,s7,8
 7cc:	4681                	li	a3,0
 7ce:	4629                	li	a2,10
 7d0:	000bb583          	ld	a1,0(s7)
 7d4:	855a                	mv	a0,s6
 7d6:	e4fff0ef          	jal	624 <printint>
        i += 1;
 7da:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 7dc:	8ba6                	mv	s7,s1
      state = 0;
 7de:	4981                	li	s3,0
 7e0:	b71d                	j	706 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7e2:	008b8493          	addi	s1,s7,8
 7e6:	4681                	li	a3,0
 7e8:	4629                	li	a2,10
 7ea:	000bb583          	ld	a1,0(s7)
 7ee:	855a                	mv	a0,s6
 7f0:	e35ff0ef          	jal	624 <printint>
        i += 2;
 7f4:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7f6:	8ba6                	mv	s7,s1
      state = 0;
 7f8:	4981                	li	s3,0
        i += 2;
 7fa:	b731                	j	706 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 7fc:	008b8493          	addi	s1,s7,8
 800:	4681                	li	a3,0
 802:	4641                	li	a2,16
 804:	000be583          	lwu	a1,0(s7)
 808:	855a                	mv	a0,s6
 80a:	e1bff0ef          	jal	624 <printint>
 80e:	8ba6                	mv	s7,s1
      state = 0;
 810:	4981                	li	s3,0
 812:	bdd5                	j	706 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 814:	008b8493          	addi	s1,s7,8
 818:	4681                	li	a3,0
 81a:	4641                	li	a2,16
 81c:	000bb583          	ld	a1,0(s7)
 820:	855a                	mv	a0,s6
 822:	e03ff0ef          	jal	624 <printint>
        i += 1;
 826:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 828:	8ba6                	mv	s7,s1
      state = 0;
 82a:	4981                	li	s3,0
 82c:	bde9                	j	706 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 82e:	008b8493          	addi	s1,s7,8
 832:	4681                	li	a3,0
 834:	4641                	li	a2,16
 836:	000bb583          	ld	a1,0(s7)
 83a:	855a                	mv	a0,s6
 83c:	de9ff0ef          	jal	624 <printint>
        i += 2;
 840:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 842:	8ba6                	mv	s7,s1
      state = 0;
 844:	4981                	li	s3,0
        i += 2;
 846:	b5c1                	j	706 <vprintf+0x44>
 848:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 84a:	008b8793          	addi	a5,s7,8
 84e:	8cbe                	mv	s9,a5
 850:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 854:	03000593          	li	a1,48
 858:	855a                	mv	a0,s6
 85a:	dadff0ef          	jal	606 <putc>
  putc(fd, 'x');
 85e:	07800593          	li	a1,120
 862:	855a                	mv	a0,s6
 864:	da3ff0ef          	jal	606 <putc>
 868:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 86a:	00001b97          	auipc	s7,0x1
 86e:	996b8b93          	addi	s7,s7,-1642 # 1200 <digits>
 872:	03c9d793          	srli	a5,s3,0x3c
 876:	97de                	add	a5,a5,s7
 878:	0007c583          	lbu	a1,0(a5)
 87c:	855a                	mv	a0,s6
 87e:	d89ff0ef          	jal	606 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 882:	0992                	slli	s3,s3,0x4
 884:	34fd                	addiw	s1,s1,-1
 886:	f4f5                	bnez	s1,872 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 888:	8be6                	mv	s7,s9
      state = 0;
 88a:	4981                	li	s3,0
 88c:	6ca2                	ld	s9,8(sp)
 88e:	bda5                	j	706 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 890:	008b8493          	addi	s1,s7,8
 894:	000bc583          	lbu	a1,0(s7)
 898:	855a                	mv	a0,s6
 89a:	d6dff0ef          	jal	606 <putc>
 89e:	8ba6                	mv	s7,s1
      state = 0;
 8a0:	4981                	li	s3,0
 8a2:	b595                	j	706 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 8a4:	008b8993          	addi	s3,s7,8
 8a8:	000bb483          	ld	s1,0(s7)
 8ac:	cc91                	beqz	s1,8c8 <vprintf+0x206>
        for (; *s; s++)
 8ae:	0004c583          	lbu	a1,0(s1)
 8b2:	c985                	beqz	a1,8e2 <vprintf+0x220>
          putc(fd, *s);
 8b4:	855a                	mv	a0,s6
 8b6:	d51ff0ef          	jal	606 <putc>
        for (; *s; s++)
 8ba:	0485                	addi	s1,s1,1
 8bc:	0004c583          	lbu	a1,0(s1)
 8c0:	f9f5                	bnez	a1,8b4 <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 8c2:	8bce                	mv	s7,s3
      state = 0;
 8c4:	4981                	li	s3,0
 8c6:	b581                	j	706 <vprintf+0x44>
          s = "(null)";
 8c8:	00001497          	auipc	s1,0x1
 8cc:	93048493          	addi	s1,s1,-1744 # 11f8 <malloc+0x794>
        for (; *s; s++)
 8d0:	02800593          	li	a1,40
 8d4:	b7c5                	j	8b4 <vprintf+0x1f2>
        putc(fd, '%');
 8d6:	85be                	mv	a1,a5
 8d8:	855a                	mv	a0,s6
 8da:	d2dff0ef          	jal	606 <putc>
      state = 0;
 8de:	4981                	li	s3,0
 8e0:	b51d                	j	706 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 8e2:	8bce                	mv	s7,s3
      state = 0;
 8e4:	4981                	li	s3,0
 8e6:	b505                	j	706 <vprintf+0x44>
 8e8:	6906                	ld	s2,64(sp)
 8ea:	79e2                	ld	s3,56(sp)
 8ec:	7a42                	ld	s4,48(sp)
 8ee:	7aa2                	ld	s5,40(sp)
 8f0:	7b02                	ld	s6,32(sp)
 8f2:	6be2                	ld	s7,24(sp)
 8f4:	6c42                	ld	s8,16(sp)
    }
  }
}
 8f6:	60e6                	ld	ra,88(sp)
 8f8:	6446                	ld	s0,80(sp)
 8fa:	64a6                	ld	s1,72(sp)
 8fc:	6125                	addi	sp,sp,96
 8fe:	8082                	ret
      if (c0 == 'd') {
 900:	06400713          	li	a4,100
 904:	e4e78fe3          	beq	a5,a4,762 <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 908:	f9478693          	addi	a3,a5,-108
 90c:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 910:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 912:	4701                	li	a4,0
      } else if (c0 == 'u') {
 914:	07500513          	li	a0,117
 918:	e8a78ce3          	beq	a5,a0,7b0 <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 91c:	f8b60513          	addi	a0,a2,-117
 920:	e119                	bnez	a0,926 <vprintf+0x264>
 922:	ea0693e3          	bnez	a3,7c8 <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 926:	f8b58513          	addi	a0,a1,-117
 92a:	e119                	bnez	a0,930 <vprintf+0x26e>
 92c:	ea071be3          	bnez	a4,7e2 <vprintf+0x120>
      } else if (c0 == 'x') {
 930:	07800513          	li	a0,120
 934:	eca784e3          	beq	a5,a0,7fc <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 938:	f8860613          	addi	a2,a2,-120
 93c:	e219                	bnez	a2,942 <vprintf+0x280>
 93e:	ec069be3          	bnez	a3,814 <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 942:	f8858593          	addi	a1,a1,-120
 946:	e199                	bnez	a1,94c <vprintf+0x28a>
 948:	ee0713e3          	bnez	a4,82e <vprintf+0x16c>
      } else if (c0 == 'p') {
 94c:	07000713          	li	a4,112
 950:	eee78ce3          	beq	a5,a4,848 <vprintf+0x186>
      } else if (c0 == 'c') {
 954:	06300713          	li	a4,99
 958:	f2e78ce3          	beq	a5,a4,890 <vprintf+0x1ce>
      } else if (c0 == 's') {
 95c:	07300713          	li	a4,115
 960:	f4e782e3          	beq	a5,a4,8a4 <vprintf+0x1e2>
      } else if (c0 == '%') {
 964:	02500713          	li	a4,37
 968:	f6e787e3          	beq	a5,a4,8d6 <vprintf+0x214>
        putc(fd, '%');
 96c:	02500593          	li	a1,37
 970:	855a                	mv	a0,s6
 972:	c95ff0ef          	jal	606 <putc>
        putc(fd, c0);
 976:	85a6                	mv	a1,s1
 978:	855a                	mv	a0,s6
 97a:	c8dff0ef          	jal	606 <putc>
      state = 0;
 97e:	4981                	li	s3,0
 980:	b359                	j	706 <vprintf+0x44>

0000000000000982 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 982:	715d                	addi	sp,sp,-80
 984:	ec06                	sd	ra,24(sp)
 986:	e822                	sd	s0,16(sp)
 988:	1000                	addi	s0,sp,32
 98a:	e010                	sd	a2,0(s0)
 98c:	e414                	sd	a3,8(s0)
 98e:	e818                	sd	a4,16(s0)
 990:	ec1c                	sd	a5,24(s0)
 992:	03043023          	sd	a6,32(s0)
 996:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 99a:	8622                	mv	a2,s0
 99c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9a0:	d23ff0ef          	jal	6c2 <vprintf>
}
 9a4:	60e2                	ld	ra,24(sp)
 9a6:	6442                	ld	s0,16(sp)
 9a8:	6161                	addi	sp,sp,80
 9aa:	8082                	ret

00000000000009ac <printf>:

void
printf(const char *fmt, ...)
{
 9ac:	711d                	addi	sp,sp,-96
 9ae:	ec06                	sd	ra,24(sp)
 9b0:	e822                	sd	s0,16(sp)
 9b2:	1000                	addi	s0,sp,32
 9b4:	e40c                	sd	a1,8(s0)
 9b6:	e810                	sd	a2,16(s0)
 9b8:	ec14                	sd	a3,24(s0)
 9ba:	f018                	sd	a4,32(s0)
 9bc:	f41c                	sd	a5,40(s0)
 9be:	03043823          	sd	a6,48(s0)
 9c2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 9c6:	00840613          	addi	a2,s0,8
 9ca:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 9ce:	85aa                	mv	a1,a0
 9d0:	4505                	li	a0,1
 9d2:	cf1ff0ef          	jal	6c2 <vprintf>
}
 9d6:	60e2                	ld	ra,24(sp)
 9d8:	6442                	ld	s0,16(sp)
 9da:	6125                	addi	sp,sp,96
 9dc:	8082                	ret

00000000000009de <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9de:	1141                	addi	sp,sp,-16
 9e0:	e406                	sd	ra,8(sp)
 9e2:	e022                	sd	s0,0(sp)
 9e4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 9e6:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9ea:	00001797          	auipc	a5,0x1
 9ee:	6167b783          	ld	a5,1558(a5) # 2000 <freep>
 9f2:	a039                	j	a00 <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9f4:	6398                	ld	a4,0(a5)
 9f6:	00e7e463          	bltu	a5,a4,9fe <free+0x20>
 9fa:	00e6ea63          	bltu	a3,a4,a0e <free+0x30>
{
 9fe:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a00:	fed7fae3          	bgeu	a5,a3,9f4 <free+0x16>
 a04:	6398                	ld	a4,0(a5)
 a06:	00e6e463          	bltu	a3,a4,a0e <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a0a:	fee7eae3          	bltu	a5,a4,9fe <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 a0e:	ff852583          	lw	a1,-8(a0)
 a12:	6390                	ld	a2,0(a5)
 a14:	02059813          	slli	a6,a1,0x20
 a18:	01c85713          	srli	a4,a6,0x1c
 a1c:	9736                	add	a4,a4,a3
 a1e:	02e60563          	beq	a2,a4,a48 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 a22:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 a26:	4790                	lw	a2,8(a5)
 a28:	02061593          	slli	a1,a2,0x20
 a2c:	01c5d713          	srli	a4,a1,0x1c
 a30:	973e                	add	a4,a4,a5
 a32:	02e68263          	beq	a3,a4,a56 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 a36:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a38:	00001717          	auipc	a4,0x1
 a3c:	5cf73423          	sd	a5,1480(a4) # 2000 <freep>
}
 a40:	60a2                	ld	ra,8(sp)
 a42:	6402                	ld	s0,0(sp)
 a44:	0141                	addi	sp,sp,16
 a46:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 a48:	4618                	lw	a4,8(a2)
 a4a:	9f2d                	addw	a4,a4,a1
 a4c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a50:	6398                	ld	a4,0(a5)
 a52:	6310                	ld	a2,0(a4)
 a54:	b7f9                	j	a22 <free+0x44>
    p->s.size += bp->s.size;
 a56:	ff852703          	lw	a4,-8(a0)
 a5a:	9f31                	addw	a4,a4,a2
 a5c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a5e:	ff053683          	ld	a3,-16(a0)
 a62:	bfd1                	j	a36 <free+0x58>

0000000000000a64 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 a64:	7139                	addi	sp,sp,-64
 a66:	fc06                	sd	ra,56(sp)
 a68:	f822                	sd	s0,48(sp)
 a6a:	f04a                	sd	s2,32(sp)
 a6c:	ec4e                	sd	s3,24(sp)
 a6e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 a70:	02051993          	slli	s3,a0,0x20
 a74:	0209d993          	srli	s3,s3,0x20
 a78:	09bd                	addi	s3,s3,15
 a7a:	0049d993          	srli	s3,s3,0x4
 a7e:	2985                	addiw	s3,s3,1
 a80:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 a82:	00001517          	auipc	a0,0x1
 a86:	57e53503          	ld	a0,1406(a0) # 2000 <freep>
 a8a:	c905                	beqz	a0,aba <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 a8c:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 a8e:	4798                	lw	a4,8(a5)
 a90:	09377663          	bgeu	a4,s3,b1c <malloc+0xb8>
 a94:	f426                	sd	s1,40(sp)
 a96:	e852                	sd	s4,16(sp)
 a98:	e456                	sd	s5,8(sp)
 a9a:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 a9c:	8a4e                	mv	s4,s3
 a9e:	6705                	lui	a4,0x1
 aa0:	00e9f363          	bgeu	s3,a4,aa6 <malloc+0x42>
 aa4:	6a05                	lui	s4,0x1
 aa6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 aaa:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 aae:	00001497          	auipc	s1,0x1
 ab2:	55248493          	addi	s1,s1,1362 # 2000 <freep>
  if (p == SBRK_ERROR)
 ab6:	5afd                	li	s5,-1
 ab8:	a83d                	j	af6 <malloc+0x92>
 aba:	f426                	sd	s1,40(sp)
 abc:	e852                	sd	s4,16(sp)
 abe:	e456                	sd	s5,8(sp)
 ac0:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 ac2:	00001797          	auipc	a5,0x1
 ac6:	54e78793          	addi	a5,a5,1358 # 2010 <base>
 aca:	00001717          	auipc	a4,0x1
 ace:	52f73b23          	sd	a5,1334(a4) # 2000 <freep>
 ad2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 ad4:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 ad8:	b7d1                	j	a9c <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 ada:	6398                	ld	a4,0(a5)
 adc:	e118                	sd	a4,0(a0)
 ade:	a899                	j	b34 <malloc+0xd0>
  hp->s.size = nu;
 ae0:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 ae4:	0541                	addi	a0,a0,16
 ae6:	ef9ff0ef          	jal	9de <free>
  return freep;
 aea:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 aec:	c125                	beqz	a0,b4c <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 aee:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 af0:	4798                	lw	a4,8(a5)
 af2:	03277163          	bgeu	a4,s2,b14 <malloc+0xb0>
    if (p == freep)
 af6:	6098                	ld	a4,0(s1)
 af8:	853e                	mv	a0,a5
 afa:	fef71ae3          	bne	a4,a5,aee <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 afe:	8552                	mv	a0,s4
 b00:	a1bff0ef          	jal	51a <sbrk>
  if (p == SBRK_ERROR)
 b04:	fd551ee3          	bne	a0,s5,ae0 <malloc+0x7c>
        return 0;
 b08:	4501                	li	a0,0
 b0a:	74a2                	ld	s1,40(sp)
 b0c:	6a42                	ld	s4,16(sp)
 b0e:	6aa2                	ld	s5,8(sp)
 b10:	6b02                	ld	s6,0(sp)
 b12:	a03d                	j	b40 <malloc+0xdc>
 b14:	74a2                	ld	s1,40(sp)
 b16:	6a42                	ld	s4,16(sp)
 b18:	6aa2                	ld	s5,8(sp)
 b1a:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 b1c:	fae90fe3          	beq	s2,a4,ada <malloc+0x76>
        p->s.size -= nunits;
 b20:	4137073b          	subw	a4,a4,s3
 b24:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b26:	02071693          	slli	a3,a4,0x20
 b2a:	01c6d713          	srli	a4,a3,0x1c
 b2e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b30:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b34:	00001717          	auipc	a4,0x1
 b38:	4ca73623          	sd	a0,1228(a4) # 2000 <freep>
      return (void *)(p + 1);
 b3c:	01078513          	addi	a0,a5,16
  }
}
 b40:	70e2                	ld	ra,56(sp)
 b42:	7442                	ld	s0,48(sp)
 b44:	7902                	ld	s2,32(sp)
 b46:	69e2                	ld	s3,24(sp)
 b48:	6121                	addi	sp,sp,64
 b4a:	8082                	ret
 b4c:	74a2                	ld	s1,40(sp)
 b4e:	6a42                	ld	s4,16(sp)
 b50:	6aa2                	ld	s5,8(sp)
 b52:	6b02                	ld	s6,0(sp)
 b54:	b7f5                	j	b40 <malloc+0xdc>
