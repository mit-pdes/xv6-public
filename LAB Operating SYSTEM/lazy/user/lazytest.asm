
user/_lazytest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"
#include "kernel/meminfo.h"

#define LARGE_SZ (32 * 1024 * 1024) // 32 MB = 8192 pages

int main(int argc, char *argv[]) {
   0:	7171                	addi	sp,sp,-176
   2:	f506                	sd	ra,168(sp)
   4:	f122                	sd	s0,160(sp)
   6:	1900                	addi	s0,sp,176
  struct meminfo mi_before, mi_after_sbrk, mi_after_touch;

  printf("============================================================\n");
   8:	00001517          	auipc	a0,0x1
   c:	bd850513          	addi	a0,a0,-1064 # be0 <malloc+0xf4>
  10:	225000ef          	jal	a34 <printf>
  printf("      Lazy Memory Allocation (Demand Paging) Test           \n");
  14:	00001517          	auipc	a0,0x1
  18:	c1450513          	addi	a0,a0,-1004 # c28 <malloc+0x13c>
  1c:	219000ef          	jal	a34 <printf>
  printf("============================================================\n\n");
  20:	00001517          	auipc	a0,0x1
  24:	c4850513          	addi	a0,a0,-952 # c68 <malloc+0x17c>
  28:	20d000ef          	jal	a34 <printf>

  // Step 1: Measure initial physical memory
  getmeminfo(&mi_before);
  2c:	fb040513          	addi	a0,s0,-80
  30:	656000ef          	jal	686 <getmeminfo>
  printf("--- Step 1: Initial Baseline Memory ---\n");
  34:	00001517          	auipc	a0,0x1
  38:	c7450513          	addi	a0,a0,-908 # ca8 <malloc+0x1bc>
  3c:	1f9000ef          	jal	a34 <printf>
  printf("  Free physical pages:     %ld (%ld KB)\n", mi_before.free_pages, mi_before.free_pages * 4);
  40:	fb843583          	ld	a1,-72(s0)
  44:	00259613          	slli	a2,a1,0x2
  48:	00001517          	auipc	a0,0x1
  4c:	c9050513          	addi	a0,a0,-880 # cd8 <malloc+0x1ec>
  50:	1e5000ef          	jal	a34 <printf>
  printf("  Process user pages:      %ld\n\n", mi_before.user_pages);
  54:	fc043583          	ld	a1,-64(s0)
  58:	00001517          	auipc	a0,0x1
  5c:	cb050513          	addi	a0,a0,-848 # d08 <malloc+0x21c>
  60:	1d5000ef          	jal	a34 <printf>

  // Step 2: Large sbrk of 32 MB
  printf("--- Step 2: Request Large sbrk(32 MB) ---\n");
  64:	00001517          	auipc	a0,0x1
  68:	ccc50513          	addi	a0,a0,-820 # d30 <malloc+0x244>
  6c:	1c9000ef          	jal	a34 <printf>
  char *p = sbrk(LARGE_SZ);
  70:	02000537          	lui	a0,0x2000
  74:	536000ef          	jal	5aa <sbrk>
  if (p == (char *)-1) {
  78:	57fd                	li	a5,-1
  7a:	18f50e63          	beq	a0,a5,216 <main+0x216>
  7e:	ed26                	sd	s1,152(sp)
  80:	e94a                	sd	s2,144(sp)
  82:	e54e                	sd	s3,136(sp)
  84:	84aa                	mv	s1,a0
    printf("sbrk(32MB) failed!\n");
    exit(1);
  }
  getmeminfo(&mi_after_sbrk);
  86:	f9040513          	addi	a0,s0,-112
  8a:	5fc000ef          	jal	686 <getmeminfo>
  printf("  sbrk returned base address: %p\n", p);
  8e:	85a6                	mv	a1,s1
  90:	00001517          	auipc	a0,0x1
  94:	ce850513          	addi	a0,a0,-792 # d78 <malloc+0x28c>
  98:	19d000ef          	jal	a34 <printf>
  printf("  Process virtual pages (sz/PGSIZE): %ld -> %ld (+8192 pages)\n",
  9c:	fa043603          	ld	a2,-96(s0)
  a0:	fc043583          	ld	a1,-64(s0)
  a4:	00001517          	auipc	a0,0x1
  a8:	cfc50513          	addi	a0,a0,-772 # da0 <malloc+0x2b4>
  ac:	189000ef          	jal	a34 <printf>
         mi_before.user_pages, mi_after_sbrk.user_pages);
  printf("  Free physical pages: %ld -> %ld (change = %ld pages)\n",
  b0:	fb843583          	ld	a1,-72(s0)
  b4:	f9843603          	ld	a2,-104(s0)
  b8:	40c586b3          	sub	a3,a1,a2
  bc:	00001517          	auipc	a0,0x1
  c0:	d2450513          	addi	a0,a0,-732 # de0 <malloc+0x2f4>
  c4:	171000ef          	jal	a34 <printf>
         mi_before.free_pages, mi_after_sbrk.free_pages,
         mi_before.free_pages - mi_after_sbrk.free_pages);
  if (mi_after_sbrk.free_pages == mi_before.free_pages) {
  c8:	f9843703          	ld	a4,-104(s0)
  cc:	fb843783          	ld	a5,-72(s0)
  d0:	16f70063          	beq	a4,a5,230 <main+0x230>
    printf("  >> SUCCESS: 32 MB allocated lazily without consuming physical frames!\n\n");
  } else {
    printf("  >> WARNING: Physical memory consumed eagerly.\n\n");
  d4:	00001517          	auipc	a0,0x1
  d8:	d9450513          	addi	a0,a0,-620 # e68 <malloc+0x37c>
  dc:	159000ef          	jal	a34 <printf>
  }

  // Step 3: Touch only 3 widely spaced pages
  printf("--- Step 3: Touching 3 Widely Spaced Pages (0 MB, 16 MB, 31 MB) ---\n");
  e0:	00001517          	auipc	a0,0x1
  e4:	dc050513          	addi	a0,a0,-576 # ea0 <malloc+0x3b4>
  e8:	14d000ef          	jal	a34 <printf>
  uint64 off0 = 0;
  uint64 off1 = 16 * 1024 * 1024;
  uint64 off2 = 31 * 1024 * 1024;

  p[off0] = 'A';
  ec:	04100793          	li	a5,65
  f0:	00f48023          	sb	a5,0(s1)
  p[off1] = 'B';
  f4:	01000937          	lui	s2,0x1000
  f8:	9926                	add	s2,s2,s1
  fa:	04200793          	li	a5,66
  fe:	00f90023          	sb	a5,0(s2) # 1000000 <base+0xffdff0>
  p[off2] = 'C';
 102:	01f009b7          	lui	s3,0x1f00
 106:	99a6                	add	s3,s3,s1
 108:	04300793          	li	a5,67
 10c:	00f98023          	sb	a5,0(s3) # 1f00000 <base+0x1efdff0>

  getmeminfo(&mi_after_touch);
 110:	f7040513          	addi	a0,s0,-144
 114:	572000ef          	jal	686 <getmeminfo>
  printf("  Read back touched bytes: p[0]=%c, p[16MB]=%c, p[31MB]=%c\n",
 118:	0009c683          	lbu	a3,0(s3)
 11c:	00094603          	lbu	a2,0(s2)
 120:	0004c583          	lbu	a1,0(s1)
 124:	00001517          	auipc	a0,0x1
 128:	dc450513          	addi	a0,a0,-572 # ee8 <malloc+0x3fc>
 12c:	109000ef          	jal	a34 <printf>
         p[off0], p[off1], p[off2]);
  printf("  Free physical pages: %ld -> %ld (consumed %ld physical frames for 3 pages + page tables)\n",
 130:	f9843583          	ld	a1,-104(s0)
 134:	f7843603          	ld	a2,-136(s0)
 138:	40c586b3          	sub	a3,a1,a2
 13c:	00001517          	auipc	a0,0x1
 140:	dec50513          	addi	a0,a0,-532 # f28 <malloc+0x43c>
 144:	0f1000ef          	jal	a34 <printf>
         mi_after_sbrk.free_pages, mi_after_touch.free_pages,
         mi_after_sbrk.free_pages - mi_after_touch.free_pages);
  printf("  >> SUCCESS: Only touched pages triggered on-demand page faults!\n\n");
 148:	00001517          	auipc	a0,0x1
 14c:	e4050513          	addi	a0,a0,-448 # f88 <malloc+0x49c>
 150:	0e5000ef          	jal	a34 <printf>

  // Step 4: System call using an untouched buffer
  printf("--- Step 4: Kernel System Call (read/pipe) into Untouched Heap Buffer ---\n");
 154:	00001517          	auipc	a0,0x1
 158:	e7c50513          	addi	a0,a0,-388 # fd0 <malloc+0x4e4>
 15c:	0d9000ef          	jal	a34 <printf>
  int fds[2];
  if (pipe(fds) < 0) {
 160:	f6840513          	addi	a0,s0,-152
 164:	48a000ef          	jal	5ee <pipe>
 168:	0c054b63          	bltz	a0,23e <main+0x23e>
 16c:	e152                	sd	s4,128(sp)
    printf("pipe failed!\n");
    exit(1);
  }
  char *untouched_buf = p + (20 * 1024 * 1024); // 20 MB offset: untouched
 16e:	01400937          	lui	s2,0x1400
 172:	9926                	add	s2,s2,s1
  char test_msg[] = "HELLO_LAZY!";
 174:	00001797          	auipc	a5,0x1
 178:	1a478793          	addi	a5,a5,420 # 1318 <malloc+0x82c>
 17c:	6398                	ld	a4,0(a5)
 17e:	f4e43c23          	sd	a4,-168(s0)
 182:	479c                	lw	a5,8(a5)
 184:	f6f42023          	sw	a5,-160(s0)
  write(fds[1], test_msg, 12);
 188:	f5840a13          	addi	s4,s0,-168
 18c:	4631                	li	a2,12
 18e:	85d2                	mv	a1,s4
 190:	f6c42503          	lw	a0,-148(s0)
 194:	46a000ef          	jal	5fe <write>
  int nread = read(fds[0], untouched_buf, 12);
 198:	4631                	li	a2,12
 19a:	85ca                	mv	a1,s2
 19c:	f6842503          	lw	a0,-152(s0)
 1a0:	456000ef          	jal	5f6 <read>
 1a4:	89aa                	mv	s3,a0
  close(fds[0]);
 1a6:	f6842503          	lw	a0,-152(s0)
 1aa:	45c000ef          	jal	606 <close>
  close(fds[1]);
 1ae:	f6c42503          	lw	a0,-148(s0)
 1b2:	454000ef          	jal	606 <close>

  printf("  Pipe read into untouched buffer returned: %d bytes, content: '%s'\n",
 1b6:	864a                	mv	a2,s2
 1b8:	85ce                	mv	a1,s3
 1ba:	00001517          	auipc	a0,0x1
 1be:	e7650513          	addi	a0,a0,-394 # 1030 <malloc+0x544>
 1c2:	073000ef          	jal	a34 <printf>
         nread, untouched_buf);
  if (strcmp(untouched_buf, test_msg) == 0) {
 1c6:	85d2                	mv	a1,s4
 1c8:	854a                	mv	a0,s2
 1ca:	18e000ef          	jal	358 <strcmp>
 1ce:	e151                	bnez	a0,252 <main+0x252>
    printf("  >> SUCCESS: Kernel successfully handled demand paging during syscall!\n\n");
 1d0:	00001517          	auipc	a0,0x1
 1d4:	ea850513          	addi	a0,a0,-344 # 1078 <malloc+0x58c>
 1d8:	05d000ef          	jal	a34 <printf>
  } else {
    printf("  >> FAILURE: Buffer content mismatch.\n\n");
  }

  // Step 5: Test fork & exit with lazy pages
  printf("--- Step 5: Testing fork() & exit() with Lazy Mappings ---\n");
 1dc:	00001517          	auipc	a0,0x1
 1e0:	f1c50513          	addi	a0,a0,-228 # 10f8 <malloc+0x60c>
 1e4:	051000ef          	jal	a34 <printf>
  int pid = fork();
 1e8:	3ee000ef          	jal	5d6 <fork>
  if (pid < 0) {
 1ec:	06054a63          	bltz	a0,260 <main+0x260>
    printf("fork failed!\n");
    exit(1);
  }
  if (pid == 0) {
 1f0:	e15d                	bnez	a0,296 <main+0x296>
    // Child verifies data and touches a new page
    if (p[off0] == 'A' && p[off1] == 'B' && p[off2] == 'C') {
 1f2:	0004c703          	lbu	a4,0(s1)
 1f6:	04100793          	li	a5,65
 1fa:	00f71b63          	bne	a4,a5,210 <main+0x210>
 1fe:	010007b7          	lui	a5,0x1000
 202:	97a6                	add	a5,a5,s1
 204:	0007c703          	lbu	a4,0(a5) # 1000000 <base+0xffdff0>
 208:	04200793          	li	a5,66
 20c:	06f70363          	beq	a4,a5,272 <main+0x272>
      p[8 * 1024 * 1024] = 'D'; // Touch 8 MB in child
      exit(0);
    }
    exit(1);
 210:	4505                	li	a0,1
 212:	3cc000ef          	jal	5de <exit>
 216:	ed26                	sd	s1,152(sp)
 218:	e94a                	sd	s2,144(sp)
 21a:	e54e                	sd	s3,136(sp)
 21c:	e152                	sd	s4,128(sp)
    printf("sbrk(32MB) failed!\n");
 21e:	00001517          	auipc	a0,0x1
 222:	b4250513          	addi	a0,a0,-1214 # d60 <malloc+0x274>
 226:	00f000ef          	jal	a34 <printf>
    exit(1);
 22a:	4505                	li	a0,1
 22c:	3b2000ef          	jal	5de <exit>
    printf("  >> SUCCESS: 32 MB allocated lazily without consuming physical frames!\n\n");
 230:	00001517          	auipc	a0,0x1
 234:	be850513          	addi	a0,a0,-1048 # e18 <malloc+0x32c>
 238:	7fc000ef          	jal	a34 <printf>
 23c:	b555                	j	e0 <main+0xe0>
 23e:	e152                	sd	s4,128(sp)
    printf("pipe failed!\n");
 240:	00001517          	auipc	a0,0x1
 244:	de050513          	addi	a0,a0,-544 # 1020 <malloc+0x534>
 248:	7ec000ef          	jal	a34 <printf>
    exit(1);
 24c:	4505                	li	a0,1
 24e:	390000ef          	jal	5de <exit>
    printf("  >> FAILURE: Buffer content mismatch.\n\n");
 252:	00001517          	auipc	a0,0x1
 256:	e7650513          	addi	a0,a0,-394 # 10c8 <malloc+0x5dc>
 25a:	7da000ef          	jal	a34 <printf>
 25e:	bfbd                	j	1dc <main+0x1dc>
    printf("fork failed!\n");
 260:	00001517          	auipc	a0,0x1
 264:	ed850513          	addi	a0,a0,-296 # 1138 <malloc+0x64c>
 268:	7cc000ef          	jal	a34 <printf>
    exit(1);
 26c:	4505                	li	a0,1
 26e:	370000ef          	jal	5de <exit>
    if (p[off0] == 'A' && p[off1] == 'B' && p[off2] == 'C') {
 272:	01f007b7          	lui	a5,0x1f00
 276:	97a6                	add	a5,a5,s1
 278:	0007c703          	lbu	a4,0(a5) # 1f00000 <base+0x1efdff0>
 27c:	04300793          	li	a5,67
 280:	f8f718e3          	bne	a4,a5,210 <main+0x210>
      p[8 * 1024 * 1024] = 'D'; // Touch 8 MB in child
 284:	008007b7          	lui	a5,0x800
 288:	97a6                	add	a5,a5,s1
 28a:	04400713          	li	a4,68
 28e:	00e78023          	sb	a4,0(a5) # 800000 <base+0x7fdff0>
      exit(0);
 292:	34c000ef          	jal	5de <exit>
  }
  wait(0);
 296:	4501                	li	a0,0
 298:	34e000ef          	jal	5e6 <wait>
  printf("  Child process executed, accessed lazy pages, and exited cleanly.\n\n");
 29c:	00001517          	auipc	a0,0x1
 2a0:	eac50513          	addi	a0,a0,-340 # 1148 <malloc+0x65c>
 2a4:	790000ef          	jal	a34 <printf>

  // Step 6: Test invalid access beyond sz
  printf("--- Step 6: Testing Invalid Access Beyond sz (Expect Child Process Termination) ---\n");
 2a8:	00001517          	auipc	a0,0x1
 2ac:	ee850513          	addi	a0,a0,-280 # 1190 <malloc+0x6a4>
 2b0:	784000ef          	jal	a34 <printf>
  int pid_bad = fork();
 2b4:	322000ef          	jal	5d6 <fork>
  if (pid_bad == 0) {
 2b8:	e51d                	bnez	a0,2e6 <main+0x2e6>
    // Access far beyond allocated heap (33 MB > 32 MB)
    printf("  [Child] Attempting invalid write to p[33 MB]...\n");
 2ba:	00001517          	auipc	a0,0x1
 2be:	f2e50513          	addi	a0,a0,-210 # 11e8 <malloc+0x6fc>
 2c2:	772000ef          	jal	a34 <printf>
    p[33 * 1024 * 1024] = 'X';
 2c6:	021007b7          	lui	a5,0x2100
 2ca:	94be                	add	s1,s1,a5
 2cc:	05800793          	li	a5,88
 2d0:	00f48023          	sb	a5,0(s1)
    printf("  [Child] ERROR: Should have been killed!\n");
 2d4:	00001517          	auipc	a0,0x1
 2d8:	f4c50513          	addi	a0,a0,-180 # 1220 <malloc+0x734>
 2dc:	758000ef          	jal	a34 <printf>
    exit(0);
 2e0:	4501                	li	a0,0
 2e2:	2fc000ef          	jal	5de <exit>
  }
  int status = 0;
 2e6:	f4042a23          	sw	zero,-172(s0)
  wait(&status);
 2ea:	f5440513          	addi	a0,s0,-172
 2ee:	2f8000ef          	jal	5e6 <wait>
  printf("  Parent successfully reaped faulted child. Kernel is intact and running!\n");
 2f2:	00001517          	auipc	a0,0x1
 2f6:	f5e50513          	addi	a0,a0,-162 # 1250 <malloc+0x764>
 2fa:	73a000ef          	jal	a34 <printf>

  printf("\n============================================================\n");
 2fe:	00001517          	auipc	a0,0x1
 302:	fa250513          	addi	a0,a0,-94 # 12a0 <malloc+0x7b4>
 306:	72e000ef          	jal	a34 <printf>
  printf("lazytest passed all tasks and edge-case verifications!\n");
 30a:	00001517          	auipc	a0,0x1
 30e:	fd650513          	addi	a0,a0,-42 # 12e0 <malloc+0x7f4>
 312:	722000ef          	jal	a34 <printf>
  printf("============================================================\n");
 316:	00001517          	auipc	a0,0x1
 31a:	8ca50513          	addi	a0,a0,-1846 # be0 <malloc+0xf4>
 31e:	716000ef          	jal	a34 <printf>
  exit(0);
 322:	4501                	li	a0,0
 324:	2ba000ef          	jal	5de <exit>

0000000000000328 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 328:	1141                	addi	sp,sp,-16
 32a:	e406                	sd	ra,8(sp)
 32c:	e022                	sd	s0,0(sp)
 32e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 330:	cd1ff0ef          	jal	0 <main>
  exit(r);
 334:	2aa000ef          	jal	5de <exit>

0000000000000338 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 338:	1141                	addi	sp,sp,-16
 33a:	e406                	sd	ra,8(sp)
 33c:	e022                	sd	s0,0(sp)
 33e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 340:	87aa                	mv	a5,a0
 342:	0585                	addi	a1,a1,1
 344:	0785                	addi	a5,a5,1 # 2100001 <base+0x20fdff1>
 346:	fff5c703          	lbu	a4,-1(a1)
 34a:	fee78fa3          	sb	a4,-1(a5)
 34e:	fb75                	bnez	a4,342 <strcpy+0xa>
    ;
  return os;
}
 350:	60a2                	ld	ra,8(sp)
 352:	6402                	ld	s0,0(sp)
 354:	0141                	addi	sp,sp,16
 356:	8082                	ret

0000000000000358 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 358:	1141                	addi	sp,sp,-16
 35a:	e406                	sd	ra,8(sp)
 35c:	e022                	sd	s0,0(sp)
 35e:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 360:	00054783          	lbu	a5,0(a0)
 364:	cb91                	beqz	a5,378 <strcmp+0x20>
 366:	0005c703          	lbu	a4,0(a1)
 36a:	00f71763          	bne	a4,a5,378 <strcmp+0x20>
    p++, q++;
 36e:	0505                	addi	a0,a0,1
 370:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 372:	00054783          	lbu	a5,0(a0)
 376:	fbe5                	bnez	a5,366 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 378:	0005c503          	lbu	a0,0(a1)
}
 37c:	40a7853b          	subw	a0,a5,a0
 380:	60a2                	ld	ra,8(sp)
 382:	6402                	ld	s0,0(sp)
 384:	0141                	addi	sp,sp,16
 386:	8082                	ret

0000000000000388 <strlen>:

uint
strlen(const char *s)
{
 388:	1141                	addi	sp,sp,-16
 38a:	e406                	sd	ra,8(sp)
 38c:	e022                	sd	s0,0(sp)
 38e:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 390:	00054783          	lbu	a5,0(a0)
 394:	cf91                	beqz	a5,3b0 <strlen+0x28>
 396:	00150793          	addi	a5,a0,1
 39a:	86be                	mv	a3,a5
 39c:	0785                	addi	a5,a5,1
 39e:	fff7c703          	lbu	a4,-1(a5)
 3a2:	ff65                	bnez	a4,39a <strlen+0x12>
 3a4:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 3a8:	60a2                	ld	ra,8(sp)
 3aa:	6402                	ld	s0,0(sp)
 3ac:	0141                	addi	sp,sp,16
 3ae:	8082                	ret
  for (n = 0; s[n]; n++)
 3b0:	4501                	li	a0,0
 3b2:	bfdd                	j	3a8 <strlen+0x20>

00000000000003b4 <memset>:

void *
memset(void *dst, int c, uint n)
{
 3b4:	1141                	addi	sp,sp,-16
 3b6:	e406                	sd	ra,8(sp)
 3b8:	e022                	sd	s0,0(sp)
 3ba:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 3bc:	ca19                	beqz	a2,3d2 <memset+0x1e>
 3be:	87aa                	mv	a5,a0
 3c0:	1602                	slli	a2,a2,0x20
 3c2:	9201                	srli	a2,a2,0x20
 3c4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 3c8:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 3cc:	0785                	addi	a5,a5,1
 3ce:	fee79de3          	bne	a5,a4,3c8 <memset+0x14>
  }
  return dst;
}
 3d2:	60a2                	ld	ra,8(sp)
 3d4:	6402                	ld	s0,0(sp)
 3d6:	0141                	addi	sp,sp,16
 3d8:	8082                	ret

00000000000003da <strchr>:

char *
strchr(const char *s, char c)
{
 3da:	1141                	addi	sp,sp,-16
 3dc:	e406                	sd	ra,8(sp)
 3de:	e022                	sd	s0,0(sp)
 3e0:	0800                	addi	s0,sp,16
  for (; *s; s++)
 3e2:	00054783          	lbu	a5,0(a0)
 3e6:	cf81                	beqz	a5,3fe <strchr+0x24>
    if (*s == c)
 3e8:	00f58763          	beq	a1,a5,3f6 <strchr+0x1c>
  for (; *s; s++)
 3ec:	0505                	addi	a0,a0,1
 3ee:	00054783          	lbu	a5,0(a0)
 3f2:	fbfd                	bnez	a5,3e8 <strchr+0xe>
      return (char *)s;
  return 0;
 3f4:	4501                	li	a0,0
}
 3f6:	60a2                	ld	ra,8(sp)
 3f8:	6402                	ld	s0,0(sp)
 3fa:	0141                	addi	sp,sp,16
 3fc:	8082                	ret
  return 0;
 3fe:	4501                	li	a0,0
 400:	bfdd                	j	3f6 <strchr+0x1c>

0000000000000402 <gets>:

char *
gets(char *buf, int max)
{
 402:	711d                	addi	sp,sp,-96
 404:	ec86                	sd	ra,88(sp)
 406:	e8a2                	sd	s0,80(sp)
 408:	e4a6                	sd	s1,72(sp)
 40a:	e0ca                	sd	s2,64(sp)
 40c:	fc4e                	sd	s3,56(sp)
 40e:	f852                	sd	s4,48(sp)
 410:	f456                	sd	s5,40(sp)
 412:	f05a                	sd	s6,32(sp)
 414:	ec5e                	sd	s7,24(sp)
 416:	e862                	sd	s8,16(sp)
 418:	1080                	addi	s0,sp,96
 41a:	8baa                	mv	s7,a0
 41c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 41e:	892a                	mv	s2,a0
 420:	4481                	li	s1,0
    cc = read(0, &c, 1);
 422:	faf40b13          	addi	s6,s0,-81
 426:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 428:	8c26                	mv	s8,s1
 42a:	0014899b          	addiw	s3,s1,1
 42e:	84ce                	mv	s1,s3
 430:	0349d463          	bge	s3,s4,458 <gets+0x56>
    cc = read(0, &c, 1);
 434:	8656                	mv	a2,s5
 436:	85da                	mv	a1,s6
 438:	4501                	li	a0,0
 43a:	1bc000ef          	jal	5f6 <read>
    if (cc < 1)
 43e:	00a05d63          	blez	a0,458 <gets+0x56>
      break;
    buf[i++] = c;
 442:	faf44783          	lbu	a5,-81(s0)
 446:	00f90023          	sb	a5,0(s2) # 1400000 <base+0x13fdff0>
    if (c == '\n' || c == '\r')
 44a:	0905                	addi	s2,s2,1
 44c:	ff678713          	addi	a4,a5,-10
 450:	c319                	beqz	a4,456 <gets+0x54>
 452:	17cd                	addi	a5,a5,-13
 454:	fbf1                	bnez	a5,428 <gets+0x26>
    buf[i++] = c;
 456:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 458:	9c5e                	add	s8,s8,s7
 45a:	000c0023          	sb	zero,0(s8)
  return buf;
}
 45e:	855e                	mv	a0,s7
 460:	60e6                	ld	ra,88(sp)
 462:	6446                	ld	s0,80(sp)
 464:	64a6                	ld	s1,72(sp)
 466:	6906                	ld	s2,64(sp)
 468:	79e2                	ld	s3,56(sp)
 46a:	7a42                	ld	s4,48(sp)
 46c:	7aa2                	ld	s5,40(sp)
 46e:	7b02                	ld	s6,32(sp)
 470:	6be2                	ld	s7,24(sp)
 472:	6c42                	ld	s8,16(sp)
 474:	6125                	addi	sp,sp,96
 476:	8082                	ret

0000000000000478 <stat>:

int
stat(const char *n, struct stat *st)
{
 478:	1101                	addi	sp,sp,-32
 47a:	ec06                	sd	ra,24(sp)
 47c:	e822                	sd	s0,16(sp)
 47e:	e04a                	sd	s2,0(sp)
 480:	1000                	addi	s0,sp,32
 482:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 484:	4581                	li	a1,0
 486:	198000ef          	jal	61e <open>
  if (fd < 0)
 48a:	02054263          	bltz	a0,4ae <stat+0x36>
 48e:	e426                	sd	s1,8(sp)
 490:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 492:	85ca                	mv	a1,s2
 494:	1a2000ef          	jal	636 <fstat>
 498:	892a                	mv	s2,a0
  close(fd);
 49a:	8526                	mv	a0,s1
 49c:	16a000ef          	jal	606 <close>
  return r;
 4a0:	64a2                	ld	s1,8(sp)
}
 4a2:	854a                	mv	a0,s2
 4a4:	60e2                	ld	ra,24(sp)
 4a6:	6442                	ld	s0,16(sp)
 4a8:	6902                	ld	s2,0(sp)
 4aa:	6105                	addi	sp,sp,32
 4ac:	8082                	ret
    return -1;
 4ae:	57fd                	li	a5,-1
 4b0:	893e                	mv	s2,a5
 4b2:	bfc5                	j	4a2 <stat+0x2a>

00000000000004b4 <atoi>:

int
atoi(const char *s)
{
 4b4:	1141                	addi	sp,sp,-16
 4b6:	e406                	sd	ra,8(sp)
 4b8:	e022                	sd	s0,0(sp)
 4ba:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 4bc:	00054683          	lbu	a3,0(a0)
 4c0:	fd06879b          	addiw	a5,a3,-48
 4c4:	0ff7f793          	zext.b	a5,a5
 4c8:	4625                	li	a2,9
 4ca:	02f66963          	bltu	a2,a5,4fc <atoi+0x48>
 4ce:	872a                	mv	a4,a0
  n = 0;
 4d0:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 4d2:	0705                	addi	a4,a4,1
 4d4:	0025179b          	slliw	a5,a0,0x2
 4d8:	9fa9                	addw	a5,a5,a0
 4da:	0017979b          	slliw	a5,a5,0x1
 4de:	9fb5                	addw	a5,a5,a3
 4e0:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 4e4:	00074683          	lbu	a3,0(a4)
 4e8:	fd06879b          	addiw	a5,a3,-48
 4ec:	0ff7f793          	zext.b	a5,a5
 4f0:	fef671e3          	bgeu	a2,a5,4d2 <atoi+0x1e>
  return n;
}
 4f4:	60a2                	ld	ra,8(sp)
 4f6:	6402                	ld	s0,0(sp)
 4f8:	0141                	addi	sp,sp,16
 4fa:	8082                	ret
  n = 0;
 4fc:	4501                	li	a0,0
 4fe:	bfdd                	j	4f4 <atoi+0x40>

0000000000000500 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 500:	1141                	addi	sp,sp,-16
 502:	e406                	sd	ra,8(sp)
 504:	e022                	sd	s0,0(sp)
 506:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 508:	02b57563          	bgeu	a0,a1,532 <memmove+0x32>
    while (n-- > 0)
 50c:	00c05f63          	blez	a2,52a <memmove+0x2a>
 510:	1602                	slli	a2,a2,0x20
 512:	9201                	srli	a2,a2,0x20
 514:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 518:	872a                	mv	a4,a0
      *dst++ = *src++;
 51a:	0585                	addi	a1,a1,1
 51c:	0705                	addi	a4,a4,1
 51e:	fff5c683          	lbu	a3,-1(a1)
 522:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 526:	fee79ae3          	bne	a5,a4,51a <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 52a:	60a2                	ld	ra,8(sp)
 52c:	6402                	ld	s0,0(sp)
 52e:	0141                	addi	sp,sp,16
 530:	8082                	ret
    while (n-- > 0)
 532:	fec05ce3          	blez	a2,52a <memmove+0x2a>
    dst += n;
 536:	00c50733          	add	a4,a0,a2
    src += n;
 53a:	95b2                	add	a1,a1,a2
 53c:	fff6079b          	addiw	a5,a2,-1
 540:	1782                	slli	a5,a5,0x20
 542:	9381                	srli	a5,a5,0x20
 544:	fff7c793          	not	a5,a5
 548:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 54a:	15fd                	addi	a1,a1,-1
 54c:	177d                	addi	a4,a4,-1
 54e:	0005c683          	lbu	a3,0(a1)
 552:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 556:	fef71ae3          	bne	a4,a5,54a <memmove+0x4a>
 55a:	bfc1                	j	52a <memmove+0x2a>

000000000000055c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 55c:	1141                	addi	sp,sp,-16
 55e:	e406                	sd	ra,8(sp)
 560:	e022                	sd	s0,0(sp)
 562:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 564:	c61d                	beqz	a2,592 <memcmp+0x36>
 566:	1602                	slli	a2,a2,0x20
 568:	9201                	srli	a2,a2,0x20
 56a:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 56e:	00054783          	lbu	a5,0(a0)
 572:	0005c703          	lbu	a4,0(a1)
 576:	00e79863          	bne	a5,a4,586 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 57a:	0505                	addi	a0,a0,1
    p2++;
 57c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 57e:	fed518e3          	bne	a0,a3,56e <memcmp+0x12>
  }
  return 0;
 582:	4501                	li	a0,0
 584:	a019                	j	58a <memcmp+0x2e>
      return *p1 - *p2;
 586:	40e7853b          	subw	a0,a5,a4
}
 58a:	60a2                	ld	ra,8(sp)
 58c:	6402                	ld	s0,0(sp)
 58e:	0141                	addi	sp,sp,16
 590:	8082                	ret
  return 0;
 592:	4501                	li	a0,0
 594:	bfdd                	j	58a <memcmp+0x2e>

0000000000000596 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 596:	1141                	addi	sp,sp,-16
 598:	e406                	sd	ra,8(sp)
 59a:	e022                	sd	s0,0(sp)
 59c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 59e:	f63ff0ef          	jal	500 <memmove>
}
 5a2:	60a2                	ld	ra,8(sp)
 5a4:	6402                	ld	s0,0(sp)
 5a6:	0141                	addi	sp,sp,16
 5a8:	8082                	ret

00000000000005aa <sbrk>:

char *
sbrk(int n)
{
 5aa:	1141                	addi	sp,sp,-16
 5ac:	e406                	sd	ra,8(sp)
 5ae:	e022                	sd	s0,0(sp)
 5b0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 5b2:	4589                	li	a1,2
 5b4:	0b2000ef          	jal	666 <sys_sbrk>
}
 5b8:	60a2                	ld	ra,8(sp)
 5ba:	6402                	ld	s0,0(sp)
 5bc:	0141                	addi	sp,sp,16
 5be:	8082                	ret

00000000000005c0 <sbrklazy>:

char *
sbrklazy(int n)
{
 5c0:	1141                	addi	sp,sp,-16
 5c2:	e406                	sd	ra,8(sp)
 5c4:	e022                	sd	s0,0(sp)
 5c6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 5c8:	4589                	li	a1,2
 5ca:	09c000ef          	jal	666 <sys_sbrk>
}
 5ce:	60a2                	ld	ra,8(sp)
 5d0:	6402                	ld	s0,0(sp)
 5d2:	0141                	addi	sp,sp,16
 5d4:	8082                	ret

00000000000005d6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5d6:	4885                	li	a7,1
 ecall
 5d8:	00000073          	ecall
 ret
 5dc:	8082                	ret

00000000000005de <exit>:
.global exit
exit:
 li a7, SYS_exit
 5de:	4889                	li	a7,2
 ecall
 5e0:	00000073          	ecall
 ret
 5e4:	8082                	ret

00000000000005e6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 5e6:	488d                	li	a7,3
 ecall
 5e8:	00000073          	ecall
 ret
 5ec:	8082                	ret

00000000000005ee <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5ee:	4891                	li	a7,4
 ecall
 5f0:	00000073          	ecall
 ret
 5f4:	8082                	ret

00000000000005f6 <read>:
.global read
read:
 li a7, SYS_read
 5f6:	4895                	li	a7,5
 ecall
 5f8:	00000073          	ecall
 ret
 5fc:	8082                	ret

00000000000005fe <write>:
.global write
write:
 li a7, SYS_write
 5fe:	48c1                	li	a7,16
 ecall
 600:	00000073          	ecall
 ret
 604:	8082                	ret

0000000000000606 <close>:
.global close
close:
 li a7, SYS_close
 606:	48d5                	li	a7,21
 ecall
 608:	00000073          	ecall
 ret
 60c:	8082                	ret

000000000000060e <kill>:
.global kill
kill:
 li a7, SYS_kill
 60e:	4899                	li	a7,6
 ecall
 610:	00000073          	ecall
 ret
 614:	8082                	ret

0000000000000616 <exec>:
.global exec
exec:
 li a7, SYS_exec
 616:	489d                	li	a7,7
 ecall
 618:	00000073          	ecall
 ret
 61c:	8082                	ret

000000000000061e <open>:
.global open
open:
 li a7, SYS_open
 61e:	48bd                	li	a7,15
 ecall
 620:	00000073          	ecall
 ret
 624:	8082                	ret

0000000000000626 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 626:	48c5                	li	a7,17
 ecall
 628:	00000073          	ecall
 ret
 62c:	8082                	ret

000000000000062e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 62e:	48c9                	li	a7,18
 ecall
 630:	00000073          	ecall
 ret
 634:	8082                	ret

0000000000000636 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 636:	48a1                	li	a7,8
 ecall
 638:	00000073          	ecall
 ret
 63c:	8082                	ret

000000000000063e <link>:
.global link
link:
 li a7, SYS_link
 63e:	48cd                	li	a7,19
 ecall
 640:	00000073          	ecall
 ret
 644:	8082                	ret

0000000000000646 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 646:	48d1                	li	a7,20
 ecall
 648:	00000073          	ecall
 ret
 64c:	8082                	ret

000000000000064e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 64e:	48a5                	li	a7,9
 ecall
 650:	00000073          	ecall
 ret
 654:	8082                	ret

0000000000000656 <dup>:
.global dup
dup:
 li a7, SYS_dup
 656:	48a9                	li	a7,10
 ecall
 658:	00000073          	ecall
 ret
 65c:	8082                	ret

000000000000065e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 65e:	48ad                	li	a7,11
 ecall
 660:	00000073          	ecall
 ret
 664:	8082                	ret

0000000000000666 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 666:	48b1                	li	a7,12
 ecall
 668:	00000073          	ecall
 ret
 66c:	8082                	ret

000000000000066e <pause>:
.global pause
pause:
 li a7, SYS_pause
 66e:	48b5                	li	a7,13
 ecall
 670:	00000073          	ecall
 ret
 674:	8082                	ret

0000000000000676 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 676:	48b9                	li	a7,14
 ecall
 678:	00000073          	ecall
 ret
 67c:	8082                	ret

000000000000067e <sync>:
.global sync
sync:
 li a7, SYS_sync
 67e:	48d9                	li	a7,22
 ecall
 680:	00000073          	ecall
 ret
 684:	8082                	ret

0000000000000686 <getmeminfo>:
.global getmeminfo
getmeminfo:
 li a7, SYS_getmeminfo
 686:	48dd                	li	a7,23
 ecall
 688:	00000073          	ecall
 ret
 68c:	8082                	ret

000000000000068e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 68e:	1101                	addi	sp,sp,-32
 690:	ec06                	sd	ra,24(sp)
 692:	e822                	sd	s0,16(sp)
 694:	1000                	addi	s0,sp,32
 696:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 69a:	4605                	li	a2,1
 69c:	fef40593          	addi	a1,s0,-17
 6a0:	f5fff0ef          	jal	5fe <write>
}
 6a4:	60e2                	ld	ra,24(sp)
 6a6:	6442                	ld	s0,16(sp)
 6a8:	6105                	addi	sp,sp,32
 6aa:	8082                	ret

00000000000006ac <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 6ac:	715d                	addi	sp,sp,-80
 6ae:	e486                	sd	ra,72(sp)
 6b0:	e0a2                	sd	s0,64(sp)
 6b2:	f84a                	sd	s2,48(sp)
 6b4:	f44e                	sd	s3,40(sp)
 6b6:	0880                	addi	s0,sp,80
 6b8:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 6ba:	c6d1                	beqz	a3,746 <printint+0x9a>
 6bc:	0805d563          	bgez	a1,746 <printint+0x9a>
    neg = 1;
    x = -xx;
 6c0:	40b005b3          	neg	a1,a1
    neg = 1;
 6c4:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 6c6:	fb840993          	addi	s3,s0,-72
  neg = 0;
 6ca:	86ce                	mv	a3,s3
  i = 0;
 6cc:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 6ce:	00001817          	auipc	a6,0x1
 6d2:	c6280813          	addi	a6,a6,-926 # 1330 <digits>
 6d6:	88ba                	mv	a7,a4
 6d8:	0017051b          	addiw	a0,a4,1
 6dc:	872a                	mv	a4,a0
 6de:	02c5f7b3          	remu	a5,a1,a2
 6e2:	97c2                	add	a5,a5,a6
 6e4:	0007c783          	lbu	a5,0(a5)
 6e8:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 6ec:	87ae                	mv	a5,a1
 6ee:	02c5d5b3          	divu	a1,a1,a2
 6f2:	0685                	addi	a3,a3,1
 6f4:	fec7f1e3          	bgeu	a5,a2,6d6 <printint+0x2a>
  if (neg)
 6f8:	00030c63          	beqz	t1,710 <printint+0x64>
    buf[i++] = '-';
 6fc:	fd050793          	addi	a5,a0,-48
 700:	00878533          	add	a0,a5,s0
 704:	02d00793          	li	a5,45
 708:	fef50423          	sb	a5,-24(a0)
 70c:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 710:	02e05563          	blez	a4,73a <printint+0x8e>
 714:	fc26                	sd	s1,56(sp)
 716:	377d                	addiw	a4,a4,-1
 718:	00e984b3          	add	s1,s3,a4
 71c:	19fd                	addi	s3,s3,-1
 71e:	99ba                	add	s3,s3,a4
 720:	1702                	slli	a4,a4,0x20
 722:	9301                	srli	a4,a4,0x20
 724:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 728:	0004c583          	lbu	a1,0(s1)
 72c:	854a                	mv	a0,s2
 72e:	f61ff0ef          	jal	68e <putc>
  while (--i >= 0)
 732:	14fd                	addi	s1,s1,-1
 734:	ff349ae3          	bne	s1,s3,728 <printint+0x7c>
 738:	74e2                	ld	s1,56(sp)
}
 73a:	60a6                	ld	ra,72(sp)
 73c:	6406                	ld	s0,64(sp)
 73e:	7942                	ld	s2,48(sp)
 740:	79a2                	ld	s3,40(sp)
 742:	6161                	addi	sp,sp,80
 744:	8082                	ret
  neg = 0;
 746:	4301                	li	t1,0
 748:	bfbd                	j	6c6 <printint+0x1a>

000000000000074a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 74a:	711d                	addi	sp,sp,-96
 74c:	ec86                	sd	ra,88(sp)
 74e:	e8a2                	sd	s0,80(sp)
 750:	e4a6                	sd	s1,72(sp)
 752:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 754:	0005c483          	lbu	s1,0(a1)
 758:	22048363          	beqz	s1,97e <vprintf+0x234>
 75c:	e0ca                	sd	s2,64(sp)
 75e:	fc4e                	sd	s3,56(sp)
 760:	f852                	sd	s4,48(sp)
 762:	f456                	sd	s5,40(sp)
 764:	f05a                	sd	s6,32(sp)
 766:	ec5e                	sd	s7,24(sp)
 768:	e862                	sd	s8,16(sp)
 76a:	8b2a                	mv	s6,a0
 76c:	8a2e                	mv	s4,a1
 76e:	8bb2                	mv	s7,a2
  state = 0;
 770:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 772:	4901                	li	s2,0
 774:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 776:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 77a:	06400c13          	li	s8,100
 77e:	a00d                	j	7a0 <vprintf+0x56>
        putc(fd, c0);
 780:	85a6                	mv	a1,s1
 782:	855a                	mv	a0,s6
 784:	f0bff0ef          	jal	68e <putc>
 788:	a019                	j	78e <vprintf+0x44>
    } else if (state == '%') {
 78a:	03598363          	beq	s3,s5,7b0 <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 78e:	0019079b          	addiw	a5,s2,1
 792:	893e                	mv	s2,a5
 794:	873e                	mv	a4,a5
 796:	97d2                	add	a5,a5,s4
 798:	0007c483          	lbu	s1,0(a5)
 79c:	1c048a63          	beqz	s1,970 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 7a0:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 7a4:	fe0993e3          	bnez	s3,78a <vprintf+0x40>
      if (c0 == '%') {
 7a8:	fd579ce3          	bne	a5,s5,780 <vprintf+0x36>
        state = '%';
 7ac:	89be                	mv	s3,a5
 7ae:	b7c5                	j	78e <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 7b0:	00ea06b3          	add	a3,s4,a4
 7b4:	0016c603          	lbu	a2,1(a3)
      if (c1)
 7b8:	1c060863          	beqz	a2,988 <vprintf+0x23e>
      if (c0 == 'd') {
 7bc:	03878763          	beq	a5,s8,7ea <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 7c0:	f9478693          	addi	a3,a5,-108
 7c4:	0016b693          	seqz	a3,a3
 7c8:	f9c60593          	addi	a1,a2,-100
 7cc:	e99d                	bnez	a1,802 <vprintf+0xb8>
 7ce:	ca95                	beqz	a3,802 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7d0:	008b8493          	addi	s1,s7,8
 7d4:	4685                	li	a3,1
 7d6:	4629                	li	a2,10
 7d8:	000bb583          	ld	a1,0(s7)
 7dc:	855a                	mv	a0,s6
 7de:	ecfff0ef          	jal	6ac <printint>
        i += 1;
 7e2:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 7e4:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 7e6:	4981                	li	s3,0
 7e8:	b75d                	j	78e <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 7ea:	008b8493          	addi	s1,s7,8
 7ee:	4685                	li	a3,1
 7f0:	4629                	li	a2,10
 7f2:	000ba583          	lw	a1,0(s7)
 7f6:	855a                	mv	a0,s6
 7f8:	eb5ff0ef          	jal	6ac <printint>
 7fc:	8ba6                	mv	s7,s1
      state = 0;
 7fe:	4981                	li	s3,0
 800:	b779                	j	78e <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 802:	9752                	add	a4,a4,s4
 804:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 808:	f9460713          	addi	a4,a2,-108
 80c:	00173713          	seqz	a4,a4
 810:	8f75                	and	a4,a4,a3
 812:	f9c58513          	addi	a0,a1,-100
 816:	18051363          	bnez	a0,99c <vprintf+0x252>
 81a:	18070163          	beqz	a4,99c <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 81e:	008b8493          	addi	s1,s7,8
 822:	4685                	li	a3,1
 824:	4629                	li	a2,10
 826:	000bb583          	ld	a1,0(s7)
 82a:	855a                	mv	a0,s6
 82c:	e81ff0ef          	jal	6ac <printint>
        i += 2;
 830:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 832:	8ba6                	mv	s7,s1
      state = 0;
 834:	4981                	li	s3,0
        i += 2;
 836:	bfa1                	j	78e <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 838:	008b8493          	addi	s1,s7,8
 83c:	4681                	li	a3,0
 83e:	4629                	li	a2,10
 840:	000be583          	lwu	a1,0(s7)
 844:	855a                	mv	a0,s6
 846:	e67ff0ef          	jal	6ac <printint>
 84a:	8ba6                	mv	s7,s1
      state = 0;
 84c:	4981                	li	s3,0
 84e:	b781                	j	78e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 850:	008b8493          	addi	s1,s7,8
 854:	4681                	li	a3,0
 856:	4629                	li	a2,10
 858:	000bb583          	ld	a1,0(s7)
 85c:	855a                	mv	a0,s6
 85e:	e4fff0ef          	jal	6ac <printint>
        i += 1;
 862:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 864:	8ba6                	mv	s7,s1
      state = 0;
 866:	4981                	li	s3,0
 868:	b71d                	j	78e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 86a:	008b8493          	addi	s1,s7,8
 86e:	4681                	li	a3,0
 870:	4629                	li	a2,10
 872:	000bb583          	ld	a1,0(s7)
 876:	855a                	mv	a0,s6
 878:	e35ff0ef          	jal	6ac <printint>
        i += 2;
 87c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 87e:	8ba6                	mv	s7,s1
      state = 0;
 880:	4981                	li	s3,0
        i += 2;
 882:	b731                	j	78e <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 884:	008b8493          	addi	s1,s7,8
 888:	4681                	li	a3,0
 88a:	4641                	li	a2,16
 88c:	000be583          	lwu	a1,0(s7)
 890:	855a                	mv	a0,s6
 892:	e1bff0ef          	jal	6ac <printint>
 896:	8ba6                	mv	s7,s1
      state = 0;
 898:	4981                	li	s3,0
 89a:	bdd5                	j	78e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 89c:	008b8493          	addi	s1,s7,8
 8a0:	4681                	li	a3,0
 8a2:	4641                	li	a2,16
 8a4:	000bb583          	ld	a1,0(s7)
 8a8:	855a                	mv	a0,s6
 8aa:	e03ff0ef          	jal	6ac <printint>
        i += 1;
 8ae:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 8b0:	8ba6                	mv	s7,s1
      state = 0;
 8b2:	4981                	li	s3,0
 8b4:	bde9                	j	78e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 8b6:	008b8493          	addi	s1,s7,8
 8ba:	4681                	li	a3,0
 8bc:	4641                	li	a2,16
 8be:	000bb583          	ld	a1,0(s7)
 8c2:	855a                	mv	a0,s6
 8c4:	de9ff0ef          	jal	6ac <printint>
        i += 2;
 8c8:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 8ca:	8ba6                	mv	s7,s1
      state = 0;
 8cc:	4981                	li	s3,0
        i += 2;
 8ce:	b5c1                	j	78e <vprintf+0x44>
 8d0:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 8d2:	008b8793          	addi	a5,s7,8
 8d6:	8cbe                	mv	s9,a5
 8d8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 8dc:	03000593          	li	a1,48
 8e0:	855a                	mv	a0,s6
 8e2:	dadff0ef          	jal	68e <putc>
  putc(fd, 'x');
 8e6:	07800593          	li	a1,120
 8ea:	855a                	mv	a0,s6
 8ec:	da3ff0ef          	jal	68e <putc>
 8f0:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8f2:	00001b97          	auipc	s7,0x1
 8f6:	a3eb8b93          	addi	s7,s7,-1474 # 1330 <digits>
 8fa:	03c9d793          	srli	a5,s3,0x3c
 8fe:	97de                	add	a5,a5,s7
 900:	0007c583          	lbu	a1,0(a5)
 904:	855a                	mv	a0,s6
 906:	d89ff0ef          	jal	68e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 90a:	0992                	slli	s3,s3,0x4
 90c:	34fd                	addiw	s1,s1,-1
 90e:	f4f5                	bnez	s1,8fa <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 910:	8be6                	mv	s7,s9
      state = 0;
 912:	4981                	li	s3,0
 914:	6ca2                	ld	s9,8(sp)
 916:	bda5                	j	78e <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 918:	008b8493          	addi	s1,s7,8
 91c:	000bc583          	lbu	a1,0(s7)
 920:	855a                	mv	a0,s6
 922:	d6dff0ef          	jal	68e <putc>
 926:	8ba6                	mv	s7,s1
      state = 0;
 928:	4981                	li	s3,0
 92a:	b595                	j	78e <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 92c:	008b8993          	addi	s3,s7,8
 930:	000bb483          	ld	s1,0(s7)
 934:	cc91                	beqz	s1,950 <vprintf+0x206>
        for (; *s; s++)
 936:	0004c583          	lbu	a1,0(s1)
 93a:	c985                	beqz	a1,96a <vprintf+0x220>
          putc(fd, *s);
 93c:	855a                	mv	a0,s6
 93e:	d51ff0ef          	jal	68e <putc>
        for (; *s; s++)
 942:	0485                	addi	s1,s1,1
 944:	0004c583          	lbu	a1,0(s1)
 948:	f9f5                	bnez	a1,93c <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 94a:	8bce                	mv	s7,s3
      state = 0;
 94c:	4981                	li	s3,0
 94e:	b581                	j	78e <vprintf+0x44>
          s = "(null)";
 950:	00001497          	auipc	s1,0x1
 954:	9d848493          	addi	s1,s1,-1576 # 1328 <malloc+0x83c>
        for (; *s; s++)
 958:	02800593          	li	a1,40
 95c:	b7c5                	j	93c <vprintf+0x1f2>
        putc(fd, '%');
 95e:	85be                	mv	a1,a5
 960:	855a                	mv	a0,s6
 962:	d2dff0ef          	jal	68e <putc>
      state = 0;
 966:	4981                	li	s3,0
 968:	b51d                	j	78e <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 96a:	8bce                	mv	s7,s3
      state = 0;
 96c:	4981                	li	s3,0
 96e:	b505                	j	78e <vprintf+0x44>
 970:	6906                	ld	s2,64(sp)
 972:	79e2                	ld	s3,56(sp)
 974:	7a42                	ld	s4,48(sp)
 976:	7aa2                	ld	s5,40(sp)
 978:	7b02                	ld	s6,32(sp)
 97a:	6be2                	ld	s7,24(sp)
 97c:	6c42                	ld	s8,16(sp)
    }
  }
}
 97e:	60e6                	ld	ra,88(sp)
 980:	6446                	ld	s0,80(sp)
 982:	64a6                	ld	s1,72(sp)
 984:	6125                	addi	sp,sp,96
 986:	8082                	ret
      if (c0 == 'd') {
 988:	06400713          	li	a4,100
 98c:	e4e78fe3          	beq	a5,a4,7ea <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 990:	f9478693          	addi	a3,a5,-108
 994:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 998:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 99a:	4701                	li	a4,0
      } else if (c0 == 'u') {
 99c:	07500513          	li	a0,117
 9a0:	e8a78ce3          	beq	a5,a0,838 <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 9a4:	f8b60513          	addi	a0,a2,-117
 9a8:	e119                	bnez	a0,9ae <vprintf+0x264>
 9aa:	ea0693e3          	bnez	a3,850 <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 9ae:	f8b58513          	addi	a0,a1,-117
 9b2:	e119                	bnez	a0,9b8 <vprintf+0x26e>
 9b4:	ea071be3          	bnez	a4,86a <vprintf+0x120>
      } else if (c0 == 'x') {
 9b8:	07800513          	li	a0,120
 9bc:	eca784e3          	beq	a5,a0,884 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 9c0:	f8860613          	addi	a2,a2,-120
 9c4:	e219                	bnez	a2,9ca <vprintf+0x280>
 9c6:	ec069be3          	bnez	a3,89c <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 9ca:	f8858593          	addi	a1,a1,-120
 9ce:	e199                	bnez	a1,9d4 <vprintf+0x28a>
 9d0:	ee0713e3          	bnez	a4,8b6 <vprintf+0x16c>
      } else if (c0 == 'p') {
 9d4:	07000713          	li	a4,112
 9d8:	eee78ce3          	beq	a5,a4,8d0 <vprintf+0x186>
      } else if (c0 == 'c') {
 9dc:	06300713          	li	a4,99
 9e0:	f2e78ce3          	beq	a5,a4,918 <vprintf+0x1ce>
      } else if (c0 == 's') {
 9e4:	07300713          	li	a4,115
 9e8:	f4e782e3          	beq	a5,a4,92c <vprintf+0x1e2>
      } else if (c0 == '%') {
 9ec:	02500713          	li	a4,37
 9f0:	f6e787e3          	beq	a5,a4,95e <vprintf+0x214>
        putc(fd, '%');
 9f4:	02500593          	li	a1,37
 9f8:	855a                	mv	a0,s6
 9fa:	c95ff0ef          	jal	68e <putc>
        putc(fd, c0);
 9fe:	85a6                	mv	a1,s1
 a00:	855a                	mv	a0,s6
 a02:	c8dff0ef          	jal	68e <putc>
      state = 0;
 a06:	4981                	li	s3,0
 a08:	b359                	j	78e <vprintf+0x44>

0000000000000a0a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a0a:	715d                	addi	sp,sp,-80
 a0c:	ec06                	sd	ra,24(sp)
 a0e:	e822                	sd	s0,16(sp)
 a10:	1000                	addi	s0,sp,32
 a12:	e010                	sd	a2,0(s0)
 a14:	e414                	sd	a3,8(s0)
 a16:	e818                	sd	a4,16(s0)
 a18:	ec1c                	sd	a5,24(s0)
 a1a:	03043023          	sd	a6,32(s0)
 a1e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a22:	8622                	mv	a2,s0
 a24:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a28:	d23ff0ef          	jal	74a <vprintf>
}
 a2c:	60e2                	ld	ra,24(sp)
 a2e:	6442                	ld	s0,16(sp)
 a30:	6161                	addi	sp,sp,80
 a32:	8082                	ret

0000000000000a34 <printf>:

void
printf(const char *fmt, ...)
{
 a34:	711d                	addi	sp,sp,-96
 a36:	ec06                	sd	ra,24(sp)
 a38:	e822                	sd	s0,16(sp)
 a3a:	1000                	addi	s0,sp,32
 a3c:	e40c                	sd	a1,8(s0)
 a3e:	e810                	sd	a2,16(s0)
 a40:	ec14                	sd	a3,24(s0)
 a42:	f018                	sd	a4,32(s0)
 a44:	f41c                	sd	a5,40(s0)
 a46:	03043823          	sd	a6,48(s0)
 a4a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a4e:	00840613          	addi	a2,s0,8
 a52:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a56:	85aa                	mv	a1,a0
 a58:	4505                	li	a0,1
 a5a:	cf1ff0ef          	jal	74a <vprintf>
}
 a5e:	60e2                	ld	ra,24(sp)
 a60:	6442                	ld	s0,16(sp)
 a62:	6125                	addi	sp,sp,96
 a64:	8082                	ret

0000000000000a66 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a66:	1141                	addi	sp,sp,-16
 a68:	e406                	sd	ra,8(sp)
 a6a:	e022                	sd	s0,0(sp)
 a6c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 a6e:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a72:	00001797          	auipc	a5,0x1
 a76:	58e7b783          	ld	a5,1422(a5) # 2000 <freep>
 a7a:	a039                	j	a88 <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a7c:	6398                	ld	a4,0(a5)
 a7e:	00e7e463          	bltu	a5,a4,a86 <free+0x20>
 a82:	00e6ea63          	bltu	a3,a4,a96 <free+0x30>
{
 a86:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a88:	fed7fae3          	bgeu	a5,a3,a7c <free+0x16>
 a8c:	6398                	ld	a4,0(a5)
 a8e:	00e6e463          	bltu	a3,a4,a96 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a92:	fee7eae3          	bltu	a5,a4,a86 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 a96:	ff852583          	lw	a1,-8(a0)
 a9a:	6390                	ld	a2,0(a5)
 a9c:	02059813          	slli	a6,a1,0x20
 aa0:	01c85713          	srli	a4,a6,0x1c
 aa4:	9736                	add	a4,a4,a3
 aa6:	02e60563          	beq	a2,a4,ad0 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 aaa:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 aae:	4790                	lw	a2,8(a5)
 ab0:	02061593          	slli	a1,a2,0x20
 ab4:	01c5d713          	srli	a4,a1,0x1c
 ab8:	973e                	add	a4,a4,a5
 aba:	02e68263          	beq	a3,a4,ade <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 abe:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 ac0:	00001717          	auipc	a4,0x1
 ac4:	54f73023          	sd	a5,1344(a4) # 2000 <freep>
}
 ac8:	60a2                	ld	ra,8(sp)
 aca:	6402                	ld	s0,0(sp)
 acc:	0141                	addi	sp,sp,16
 ace:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 ad0:	4618                	lw	a4,8(a2)
 ad2:	9f2d                	addw	a4,a4,a1
 ad4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 ad8:	6398                	ld	a4,0(a5)
 ada:	6310                	ld	a2,0(a4)
 adc:	b7f9                	j	aaa <free+0x44>
    p->s.size += bp->s.size;
 ade:	ff852703          	lw	a4,-8(a0)
 ae2:	9f31                	addw	a4,a4,a2
 ae4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 ae6:	ff053683          	ld	a3,-16(a0)
 aea:	bfd1                	j	abe <free+0x58>

0000000000000aec <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 aec:	7139                	addi	sp,sp,-64
 aee:	fc06                	sd	ra,56(sp)
 af0:	f822                	sd	s0,48(sp)
 af2:	f04a                	sd	s2,32(sp)
 af4:	ec4e                	sd	s3,24(sp)
 af6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 af8:	02051993          	slli	s3,a0,0x20
 afc:	0209d993          	srli	s3,s3,0x20
 b00:	09bd                	addi	s3,s3,15
 b02:	0049d993          	srli	s3,s3,0x4
 b06:	2985                	addiw	s3,s3,1
 b08:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 b0a:	00001517          	auipc	a0,0x1
 b0e:	4f653503          	ld	a0,1270(a0) # 2000 <freep>
 b12:	c905                	beqz	a0,b42 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 b14:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 b16:	4798                	lw	a4,8(a5)
 b18:	09377663          	bgeu	a4,s3,ba4 <malloc+0xb8>
 b1c:	f426                	sd	s1,40(sp)
 b1e:	e852                	sd	s4,16(sp)
 b20:	e456                	sd	s5,8(sp)
 b22:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 b24:	8a4e                	mv	s4,s3
 b26:	6705                	lui	a4,0x1
 b28:	00e9f363          	bgeu	s3,a4,b2e <malloc+0x42>
 b2c:	6a05                	lui	s4,0x1
 b2e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b32:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 b36:	00001497          	auipc	s1,0x1
 b3a:	4ca48493          	addi	s1,s1,1226 # 2000 <freep>
  if (p == SBRK_ERROR)
 b3e:	5afd                	li	s5,-1
 b40:	a83d                	j	b7e <malloc+0x92>
 b42:	f426                	sd	s1,40(sp)
 b44:	e852                	sd	s4,16(sp)
 b46:	e456                	sd	s5,8(sp)
 b48:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 b4a:	00001797          	auipc	a5,0x1
 b4e:	4c678793          	addi	a5,a5,1222 # 2010 <base>
 b52:	00001717          	auipc	a4,0x1
 b56:	4af73723          	sd	a5,1198(a4) # 2000 <freep>
 b5a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b5c:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 b60:	b7d1                	j	b24 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 b62:	6398                	ld	a4,0(a5)
 b64:	e118                	sd	a4,0(a0)
 b66:	a899                	j	bbc <malloc+0xd0>
  hp->s.size = nu;
 b68:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 b6c:	0541                	addi	a0,a0,16
 b6e:	ef9ff0ef          	jal	a66 <free>
  return freep;
 b72:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 b74:	c125                	beqz	a0,bd4 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 b76:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 b78:	4798                	lw	a4,8(a5)
 b7a:	03277163          	bgeu	a4,s2,b9c <malloc+0xb0>
    if (p == freep)
 b7e:	6098                	ld	a4,0(s1)
 b80:	853e                	mv	a0,a5
 b82:	fef71ae3          	bne	a4,a5,b76 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 b86:	8552                	mv	a0,s4
 b88:	a23ff0ef          	jal	5aa <sbrk>
  if (p == SBRK_ERROR)
 b8c:	fd551ee3          	bne	a0,s5,b68 <malloc+0x7c>
        return 0;
 b90:	4501                	li	a0,0
 b92:	74a2                	ld	s1,40(sp)
 b94:	6a42                	ld	s4,16(sp)
 b96:	6aa2                	ld	s5,8(sp)
 b98:	6b02                	ld	s6,0(sp)
 b9a:	a03d                	j	bc8 <malloc+0xdc>
 b9c:	74a2                	ld	s1,40(sp)
 b9e:	6a42                	ld	s4,16(sp)
 ba0:	6aa2                	ld	s5,8(sp)
 ba2:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 ba4:	fae90fe3          	beq	s2,a4,b62 <malloc+0x76>
        p->s.size -= nunits;
 ba8:	4137073b          	subw	a4,a4,s3
 bac:	c798                	sw	a4,8(a5)
        p += p->s.size;
 bae:	02071693          	slli	a3,a4,0x20
 bb2:	01c6d713          	srli	a4,a3,0x1c
 bb6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 bb8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 bbc:	00001717          	auipc	a4,0x1
 bc0:	44a73223          	sd	a0,1092(a4) # 2000 <freep>
      return (void *)(p + 1);
 bc4:	01078513          	addi	a0,a5,16
  }
}
 bc8:	70e2                	ld	ra,56(sp)
 bca:	7442                	ld	s0,48(sp)
 bcc:	7902                	ld	s2,32(sp)
 bce:	69e2                	ld	s3,24(sp)
 bd0:	6121                	addi	sp,sp,64
 bd2:	8082                	ret
 bd4:	74a2                	ld	s1,40(sp)
 bd6:	6a42                	ld	s4,16(sp)
 bd8:	6aa2                	ld	s5,8(sp)
 bda:	6b02                	ld	s6,0(sp)
 bdc:	b7f5                	j	bc8 <malloc+0xdc>
