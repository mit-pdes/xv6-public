
user/_memtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print_meminfo>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/meminfo.h"

void print_meminfo(const char *label, struct meminfo *mi) {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84ae                	mv	s1,a1
  printf("[%s]\n", label);
   c:	85aa                	mv	a1,a0
   e:	00001517          	auipc	a0,0x1
  12:	b4250513          	addi	a0,a0,-1214 # b50 <malloc+0xfe>
  16:	185000ef          	jal	99a <printf>
  printf("  Total System Pages:      %ld (%ld KB)\n", mi->total_pages, mi->total_pages * 4);
  1a:	608c                	ld	a1,0(s1)
  1c:	00259613          	slli	a2,a1,0x2
  20:	00001517          	auipc	a0,0x1
  24:	b4050513          	addi	a0,a0,-1216 # b60 <malloc+0x10e>
  28:	173000ef          	jal	99a <printf>
  printf("  Free Physical Pages:     %ld (%ld KB)\n", mi->free_pages, mi->free_pages * 4);
  2c:	648c                	ld	a1,8(s1)
  2e:	00259613          	slli	a2,a1,0x2
  32:	00001517          	auipc	a0,0x1
  36:	b5e50513          	addi	a0,a0,-1186 # b90 <malloc+0x13e>
  3a:	161000ef          	jal	99a <printf>
  printf("  Process Address Pages:   %ld (%ld KB, sz/PGSIZE)\n", mi->user_pages, mi->user_pages * 4);
  3e:	688c                	ld	a1,16(s1)
  40:	00259613          	slli	a2,a1,0x2
  44:	00001517          	auipc	a0,0x1
  48:	b7c50513          	addi	a0,a0,-1156 # bc0 <malloc+0x16e>
  4c:	14f000ef          	jal	99a <printf>
  printf("  Process Page-Table Pages:%ld (%ld KB)\n", mi->pagetable_pages, mi->pagetable_pages * 4);
  50:	6c8c                	ld	a1,24(s1)
  52:	00259613          	slli	a2,a1,0x2
  56:	00001517          	auipc	a0,0x1
  5a:	ba250513          	addi	a0,a0,-1118 # bf8 <malloc+0x1a6>
  5e:	13d000ef          	jal	99a <printf>
}
  62:	60e2                	ld	ra,24(sp)
  64:	6442                	ld	s0,16(sp)
  66:	64a2                	ld	s1,8(sp)
  68:	6105                	addi	sp,sp,32
  6a:	8082                	ret

000000000000006c <main>:

int main(int argc, char *argv[]) {
  6c:	7131                	addi	sp,sp,-192
  6e:	fd06                	sd	ra,184(sp)
  70:	f922                	sd	s0,176(sp)
  72:	0180                	addi	s0,sp,192
  struct meminfo mi_baseline, mi_allocated, mi_child, mi_after_fork, mi_after_free;

  printf("============================================================\n");
  74:	00001517          	auipc	a0,0x1
  78:	bb450513          	addi	a0,a0,-1100 # c28 <malloc+0x1d6>
  7c:	11f000ef          	jal	99a <printf>
  printf("         Physical Memory Statistics Test (memtest)          \n");
  80:	00001517          	auipc	a0,0x1
  84:	be850513          	addi	a0,a0,-1048 # c68 <malloc+0x216>
  88:	113000ef          	jal	99a <printf>
  printf("============================================================\n\n");
  8c:	00001517          	auipc	a0,0x1
  90:	c1c50513          	addi	a0,a0,-996 # ca8 <malloc+0x256>
  94:	107000ef          	jal	99a <printf>

  // Step 1: Baseline memory state
  if (getmeminfo(&mi_baseline) < 0) {
  98:	fc040513          	addi	a0,s0,-64
  9c:	550000ef          	jal	5ec <getmeminfo>
  a0:	0c054b63          	bltz	a0,176 <main+0x10a>
    printf("getmeminfo failed!\n");
    exit(1);
  }
  print_meminfo("1. Initial Baseline", &mi_baseline);
  a4:	fc040593          	addi	a1,s0,-64
  a8:	00001517          	auipc	a0,0x1
  ac:	c5850513          	addi	a0,a0,-936 # d00 <malloc+0x2ae>
  b0:	f51ff0ef          	jal	0 <print_meminfo>

  // Step 2: Grow heap by 4 pages (16384 bytes)
  printf("\n--- Step 2: Allocate 4 Pages (16 KB) with sbrk(4 * 4096) ---\n");
  b4:	00001517          	auipc	a0,0x1
  b8:	c6450513          	addi	a0,a0,-924 # d18 <malloc+0x2c6>
  bc:	0df000ef          	jal	99a <printf>
  char *p = sbrk(4 * 4096);
  c0:	6511                	lui	a0,0x4
  c2:	44e000ef          	jal	510 <sbrk>
  if (p == (char *)-1) {
  c6:	57fd                	li	a5,-1
  c8:	0cf50163          	beq	a0,a5,18a <main+0x11e>
  cc:	f526                	sd	s1,168(sp)
    printf("sbrk failed!\n");
    exit(1);
  }
  // Touch pages so physical allocation is active
  for (int i = 0; i < 4 * 4096; i += 4096)
    p[i] = 'A';
  ce:	04100793          	li	a5,65
  d2:	00f50023          	sb	a5,0(a0) # 4000 <base+0x1ff0>
  d6:	6705                	lui	a4,0x1
  d8:	972a                	add	a4,a4,a0
  da:	00f70023          	sb	a5,0(a4) # 1000 <malloc+0x5ae>
  de:	6709                	lui	a4,0x2
  e0:	972a                	add	a4,a4,a0
  e2:	00f70023          	sb	a5,0(a4) # 2000 <freep>
  e6:	670d                	lui	a4,0x3
  e8:	953a                	add	a0,a0,a4
  ea:	00f50023          	sb	a5,0(a0)

  getmeminfo(&mi_allocated);
  ee:	fa040493          	addi	s1,s0,-96
  f2:	8526                	mv	a0,s1
  f4:	4f8000ef          	jal	5ec <getmeminfo>
  print_meminfo("2. After Heap Expansion (sbrk +4 pages)", &mi_allocated);
  f8:	85a6                	mv	a1,s1
  fa:	00001517          	auipc	a0,0x1
  fe:	c6e50513          	addi	a0,a0,-914 # d68 <malloc+0x316>
 102:	effff0ef          	jal	0 <print_meminfo>
  printf("  -> Free pages change: %ld -> %ld (decreased by %ld)\n",
 106:	fc843583          	ld	a1,-56(s0)
 10a:	fa843603          	ld	a2,-88(s0)
 10e:	40c586b3          	sub	a3,a1,a2
 112:	00001517          	auipc	a0,0x1
 116:	c7e50513          	addi	a0,a0,-898 # d90 <malloc+0x33e>
 11a:	081000ef          	jal	99a <printf>
         mi_baseline.free_pages, mi_allocated.free_pages,
         mi_baseline.free_pages - mi_allocated.free_pages);
  printf("  -> Process user pages: %ld -> %ld (increased by %ld)\n",
 11e:	fd043583          	ld	a1,-48(s0)
 122:	fb043603          	ld	a2,-80(s0)
 126:	40b606b3          	sub	a3,a2,a1
 12a:	00001517          	auipc	a0,0x1
 12e:	c9e50513          	addi	a0,a0,-866 # dc8 <malloc+0x376>
 132:	069000ef          	jal	99a <printf>
         mi_baseline.user_pages, mi_allocated.user_pages,
         mi_allocated.user_pages - mi_baseline.user_pages);

  // Step 3: Fork a child process
  printf("\n--- Step 3: Forking a Child Process ---\n");
 136:	00001517          	auipc	a0,0x1
 13a:	cca50513          	addi	a0,a0,-822 # e00 <malloc+0x3ae>
 13e:	05d000ef          	jal	99a <printf>
  int pid = fork();
 142:	3fa000ef          	jal	53c <fork>
  if (pid < 0) {
 146:	04054c63          	bltz	a0,19e <main+0x132>
    printf("Fork failed!\n");
    exit(1);
  }

  if (pid == 0) {
 14a:	e13d                	bnez	a0,1b0 <main+0x144>
    // Child process prints its memory state
    getmeminfo(&mi_child);
 14c:	f8040493          	addi	s1,s0,-128
 150:	8526                	mv	a0,s1
 152:	49a000ef          	jal	5ec <getmeminfo>
    print_meminfo("3a. Inside Child Process", &mi_child);
 156:	85a6                	mv	a1,s1
 158:	00001517          	auipc	a0,0x1
 15c:	ce850513          	addi	a0,a0,-792 # e40 <malloc+0x3ee>
 160:	ea1ff0ef          	jal	0 <print_meminfo>
    printf("  -> Free pages dropped further due to child address space and page tables.\n");
 164:	00001517          	auipc	a0,0x1
 168:	cfc50513          	addi	a0,a0,-772 # e60 <malloc+0x40e>
 16c:	02f000ef          	jal	99a <printf>
    exit(0);
 170:	4501                	li	a0,0
 172:	3d2000ef          	jal	544 <exit>
 176:	f526                	sd	s1,168(sp)
    printf("getmeminfo failed!\n");
 178:	00001517          	auipc	a0,0x1
 17c:	b7050513          	addi	a0,a0,-1168 # ce8 <malloc+0x296>
 180:	01b000ef          	jal	99a <printf>
    exit(1);
 184:	4505                	li	a0,1
 186:	3be000ef          	jal	544 <exit>
 18a:	f526                	sd	s1,168(sp)
    printf("sbrk failed!\n");
 18c:	00001517          	auipc	a0,0x1
 190:	bcc50513          	addi	a0,a0,-1076 # d58 <malloc+0x306>
 194:	007000ef          	jal	99a <printf>
    exit(1);
 198:	4505                	li	a0,1
 19a:	3aa000ef          	jal	544 <exit>
    printf("Fork failed!\n");
 19e:	00001517          	auipc	a0,0x1
 1a2:	c9250513          	addi	a0,a0,-878 # e30 <malloc+0x3de>
 1a6:	7f4000ef          	jal	99a <printf>
    exit(1);
 1aa:	4505                	li	a0,1
 1ac:	398000ef          	jal	544 <exit>
  } else {
    // Parent waits for child to exit and reaps it
    wait(0);
 1b0:	4501                	li	a0,0
 1b2:	39a000ef          	jal	54c <wait>
    getmeminfo(&mi_after_fork);
 1b6:	f6040493          	addi	s1,s0,-160
 1ba:	8526                	mv	a0,s1
 1bc:	430000ef          	jal	5ec <getmeminfo>
    print_meminfo("3b. Parent After Reaping Child", &mi_after_fork);
 1c0:	85a6                	mv	a1,s1
 1c2:	00001517          	auipc	a0,0x1
 1c6:	cee50513          	addi	a0,a0,-786 # eb0 <malloc+0x45e>
 1ca:	e37ff0ef          	jal	0 <print_meminfo>

    // Verify zero memory leak from fork/exit
    printf("\n--- Verification: Memory Leak Check After Child Termination ---\n");
 1ce:	00001517          	auipc	a0,0x1
 1d2:	d0250513          	addi	a0,a0,-766 # ed0 <malloc+0x47e>
 1d6:	7c4000ef          	jal	99a <printf>
    printf("  Free pages before fork: %ld\n", mi_allocated.free_pages);
 1da:	fa843583          	ld	a1,-88(s0)
 1de:	00001517          	auipc	a0,0x1
 1e2:	d3a50513          	addi	a0,a0,-710 # f18 <malloc+0x4c6>
 1e6:	7b4000ef          	jal	99a <printf>
    printf("  Free pages after reap:  %ld\n", mi_after_fork.free_pages);
 1ea:	f6843583          	ld	a1,-152(s0)
 1ee:	00001517          	auipc	a0,0x1
 1f2:	d4a50513          	addi	a0,a0,-694 # f38 <malloc+0x4e6>
 1f6:	7a4000ef          	jal	99a <printf>
    if (mi_after_fork.free_pages == mi_allocated.free_pages) {
 1fa:	f6843783          	ld	a5,-152(s0)
 1fe:	fa843583          	ld	a1,-88(s0)
 202:	06b78f63          	beq	a5,a1,280 <main+0x214>
      printf("  >> SUCCESS: Exact match! All child frames and page tables reaped (NO LEAK).\n");
    } else {
      printf("  >> WARNING: Discrepancy of %ld pages.\n",
 206:	8d9d                	sub	a1,a1,a5
 208:	00001517          	auipc	a0,0x1
 20c:	da050513          	addi	a0,a0,-608 # fa8 <malloc+0x556>
 210:	78a000ef          	jal	99a <printf>
             mi_allocated.free_pages - mi_after_fork.free_pages);
    }
  }

  // Step 4: Deallocate heap memory with sbrk(-4 * 4096)
  printf("\n--- Step 4: Shrink Heap with sbrk(-4 * 4096) ---\n");
 214:	00001517          	auipc	a0,0x1
 218:	dc450513          	addi	a0,a0,-572 # fd8 <malloc+0x586>
 21c:	77e000ef          	jal	99a <printf>
  sbrk(-4 * 4096);
 220:	7571                	lui	a0,0xffffc
 222:	2ee000ef          	jal	510 <sbrk>
  getmeminfo(&mi_after_free);
 226:	f4040493          	addi	s1,s0,-192
 22a:	8526                	mv	a0,s1
 22c:	3c0000ef          	jal	5ec <getmeminfo>
  print_meminfo("4. After Heap Shrinking", &mi_after_free);
 230:	85a6                	mv	a1,s1
 232:	00001517          	auipc	a0,0x1
 236:	dde50513          	addi	a0,a0,-546 # 1010 <malloc+0x5be>
 23a:	dc7ff0ef          	jal	0 <print_meminfo>
  printf("  -> Free pages returned from %ld to %ld (restored %ld pages)\n",
 23e:	f6843583          	ld	a1,-152(s0)
 242:	f4843603          	ld	a2,-184(s0)
 246:	40b606b3          	sub	a3,a2,a1
 24a:	00001517          	auipc	a0,0x1
 24e:	dde50513          	addi	a0,a0,-546 # 1028 <malloc+0x5d6>
 252:	748000ef          	jal	99a <printf>
         mi_after_fork.free_pages, mi_after_free.free_pages,
         mi_after_free.free_pages - mi_after_fork.free_pages);

  printf("\n============================================================\n");
 256:	00001517          	auipc	a0,0x1
 25a:	e1250513          	addi	a0,a0,-494 # 1068 <malloc+0x616>
 25e:	73c000ef          	jal	99a <printf>
  printf("memtest completed all tasks successfully!\n");
 262:	00001517          	auipc	a0,0x1
 266:	e4650513          	addi	a0,a0,-442 # 10a8 <malloc+0x656>
 26a:	730000ef          	jal	99a <printf>
  printf("============================================================\n");
 26e:	00001517          	auipc	a0,0x1
 272:	9ba50513          	addi	a0,a0,-1606 # c28 <malloc+0x1d6>
 276:	724000ef          	jal	99a <printf>
  exit(0);
 27a:	4501                	li	a0,0
 27c:	2c8000ef          	jal	544 <exit>
      printf("  >> SUCCESS: Exact match! All child frames and page tables reaped (NO LEAK).\n");
 280:	00001517          	auipc	a0,0x1
 284:	cd850513          	addi	a0,a0,-808 # f58 <malloc+0x506>
 288:	712000ef          	jal	99a <printf>
 28c:	b761                	j	214 <main+0x1a8>

000000000000028e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e406                	sd	ra,8(sp)
 292:	e022                	sd	s0,0(sp)
 294:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 296:	dd7ff0ef          	jal	6c <main>
  exit(r);
 29a:	2aa000ef          	jal	544 <exit>

000000000000029e <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 29e:	1141                	addi	sp,sp,-16
 2a0:	e406                	sd	ra,8(sp)
 2a2:	e022                	sd	s0,0(sp)
 2a4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 2a6:	87aa                	mv	a5,a0
 2a8:	0585                	addi	a1,a1,1
 2aa:	0785                	addi	a5,a5,1
 2ac:	fff5c703          	lbu	a4,-1(a1)
 2b0:	fee78fa3          	sb	a4,-1(a5)
 2b4:	fb75                	bnez	a4,2a8 <strcpy+0xa>
    ;
  return os;
}
 2b6:	60a2                	ld	ra,8(sp)
 2b8:	6402                	ld	s0,0(sp)
 2ba:	0141                	addi	sp,sp,16
 2bc:	8082                	ret

00000000000002be <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2be:	1141                	addi	sp,sp,-16
 2c0:	e406                	sd	ra,8(sp)
 2c2:	e022                	sd	s0,0(sp)
 2c4:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 2c6:	00054783          	lbu	a5,0(a0)
 2ca:	cb91                	beqz	a5,2de <strcmp+0x20>
 2cc:	0005c703          	lbu	a4,0(a1)
 2d0:	00f71763          	bne	a4,a5,2de <strcmp+0x20>
    p++, q++;
 2d4:	0505                	addi	a0,a0,1
 2d6:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 2d8:	00054783          	lbu	a5,0(a0)
 2dc:	fbe5                	bnez	a5,2cc <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 2de:	0005c503          	lbu	a0,0(a1)
}
 2e2:	40a7853b          	subw	a0,a5,a0
 2e6:	60a2                	ld	ra,8(sp)
 2e8:	6402                	ld	s0,0(sp)
 2ea:	0141                	addi	sp,sp,16
 2ec:	8082                	ret

00000000000002ee <strlen>:

uint
strlen(const char *s)
{
 2ee:	1141                	addi	sp,sp,-16
 2f0:	e406                	sd	ra,8(sp)
 2f2:	e022                	sd	s0,0(sp)
 2f4:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 2f6:	00054783          	lbu	a5,0(a0)
 2fa:	cf91                	beqz	a5,316 <strlen+0x28>
 2fc:	00150793          	addi	a5,a0,1
 300:	86be                	mv	a3,a5
 302:	0785                	addi	a5,a5,1
 304:	fff7c703          	lbu	a4,-1(a5)
 308:	ff65                	bnez	a4,300 <strlen+0x12>
 30a:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 30e:	60a2                	ld	ra,8(sp)
 310:	6402                	ld	s0,0(sp)
 312:	0141                	addi	sp,sp,16
 314:	8082                	ret
  for (n = 0; s[n]; n++)
 316:	4501                	li	a0,0
 318:	bfdd                	j	30e <strlen+0x20>

000000000000031a <memset>:

void *
memset(void *dst, int c, uint n)
{
 31a:	1141                	addi	sp,sp,-16
 31c:	e406                	sd	ra,8(sp)
 31e:	e022                	sd	s0,0(sp)
 320:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 322:	ca19                	beqz	a2,338 <memset+0x1e>
 324:	87aa                	mv	a5,a0
 326:	1602                	slli	a2,a2,0x20
 328:	9201                	srli	a2,a2,0x20
 32a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 32e:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 332:	0785                	addi	a5,a5,1
 334:	fee79de3          	bne	a5,a4,32e <memset+0x14>
  }
  return dst;
}
 338:	60a2                	ld	ra,8(sp)
 33a:	6402                	ld	s0,0(sp)
 33c:	0141                	addi	sp,sp,16
 33e:	8082                	ret

0000000000000340 <strchr>:

char *
strchr(const char *s, char c)
{
 340:	1141                	addi	sp,sp,-16
 342:	e406                	sd	ra,8(sp)
 344:	e022                	sd	s0,0(sp)
 346:	0800                	addi	s0,sp,16
  for (; *s; s++)
 348:	00054783          	lbu	a5,0(a0)
 34c:	cf81                	beqz	a5,364 <strchr+0x24>
    if (*s == c)
 34e:	00f58763          	beq	a1,a5,35c <strchr+0x1c>
  for (; *s; s++)
 352:	0505                	addi	a0,a0,1
 354:	00054783          	lbu	a5,0(a0)
 358:	fbfd                	bnez	a5,34e <strchr+0xe>
      return (char *)s;
  return 0;
 35a:	4501                	li	a0,0
}
 35c:	60a2                	ld	ra,8(sp)
 35e:	6402                	ld	s0,0(sp)
 360:	0141                	addi	sp,sp,16
 362:	8082                	ret
  return 0;
 364:	4501                	li	a0,0
 366:	bfdd                	j	35c <strchr+0x1c>

0000000000000368 <gets>:

char *
gets(char *buf, int max)
{
 368:	711d                	addi	sp,sp,-96
 36a:	ec86                	sd	ra,88(sp)
 36c:	e8a2                	sd	s0,80(sp)
 36e:	e4a6                	sd	s1,72(sp)
 370:	e0ca                	sd	s2,64(sp)
 372:	fc4e                	sd	s3,56(sp)
 374:	f852                	sd	s4,48(sp)
 376:	f456                	sd	s5,40(sp)
 378:	f05a                	sd	s6,32(sp)
 37a:	ec5e                	sd	s7,24(sp)
 37c:	e862                	sd	s8,16(sp)
 37e:	1080                	addi	s0,sp,96
 380:	8baa                	mv	s7,a0
 382:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 384:	892a                	mv	s2,a0
 386:	4481                	li	s1,0
    cc = read(0, &c, 1);
 388:	faf40b13          	addi	s6,s0,-81
 38c:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 38e:	8c26                	mv	s8,s1
 390:	0014899b          	addiw	s3,s1,1
 394:	84ce                	mv	s1,s3
 396:	0349d463          	bge	s3,s4,3be <gets+0x56>
    cc = read(0, &c, 1);
 39a:	8656                	mv	a2,s5
 39c:	85da                	mv	a1,s6
 39e:	4501                	li	a0,0
 3a0:	1bc000ef          	jal	55c <read>
    if (cc < 1)
 3a4:	00a05d63          	blez	a0,3be <gets+0x56>
      break;
    buf[i++] = c;
 3a8:	faf44783          	lbu	a5,-81(s0)
 3ac:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 3b0:	0905                	addi	s2,s2,1
 3b2:	ff678713          	addi	a4,a5,-10
 3b6:	c319                	beqz	a4,3bc <gets+0x54>
 3b8:	17cd                	addi	a5,a5,-13
 3ba:	fbf1                	bnez	a5,38e <gets+0x26>
    buf[i++] = c;
 3bc:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 3be:	9c5e                	add	s8,s8,s7
 3c0:	000c0023          	sb	zero,0(s8)
  return buf;
}
 3c4:	855e                	mv	a0,s7
 3c6:	60e6                	ld	ra,88(sp)
 3c8:	6446                	ld	s0,80(sp)
 3ca:	64a6                	ld	s1,72(sp)
 3cc:	6906                	ld	s2,64(sp)
 3ce:	79e2                	ld	s3,56(sp)
 3d0:	7a42                	ld	s4,48(sp)
 3d2:	7aa2                	ld	s5,40(sp)
 3d4:	7b02                	ld	s6,32(sp)
 3d6:	6be2                	ld	s7,24(sp)
 3d8:	6c42                	ld	s8,16(sp)
 3da:	6125                	addi	sp,sp,96
 3dc:	8082                	ret

00000000000003de <stat>:

int
stat(const char *n, struct stat *st)
{
 3de:	1101                	addi	sp,sp,-32
 3e0:	ec06                	sd	ra,24(sp)
 3e2:	e822                	sd	s0,16(sp)
 3e4:	e04a                	sd	s2,0(sp)
 3e6:	1000                	addi	s0,sp,32
 3e8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3ea:	4581                	li	a1,0
 3ec:	198000ef          	jal	584 <open>
  if (fd < 0)
 3f0:	02054263          	bltz	a0,414 <stat+0x36>
 3f4:	e426                	sd	s1,8(sp)
 3f6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3f8:	85ca                	mv	a1,s2
 3fa:	1a2000ef          	jal	59c <fstat>
 3fe:	892a                	mv	s2,a0
  close(fd);
 400:	8526                	mv	a0,s1
 402:	16a000ef          	jal	56c <close>
  return r;
 406:	64a2                	ld	s1,8(sp)
}
 408:	854a                	mv	a0,s2
 40a:	60e2                	ld	ra,24(sp)
 40c:	6442                	ld	s0,16(sp)
 40e:	6902                	ld	s2,0(sp)
 410:	6105                	addi	sp,sp,32
 412:	8082                	ret
    return -1;
 414:	57fd                	li	a5,-1
 416:	893e                	mv	s2,a5
 418:	bfc5                	j	408 <stat+0x2a>

000000000000041a <atoi>:

int
atoi(const char *s)
{
 41a:	1141                	addi	sp,sp,-16
 41c:	e406                	sd	ra,8(sp)
 41e:	e022                	sd	s0,0(sp)
 420:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 422:	00054683          	lbu	a3,0(a0)
 426:	fd06879b          	addiw	a5,a3,-48
 42a:	0ff7f793          	zext.b	a5,a5
 42e:	4625                	li	a2,9
 430:	02f66963          	bltu	a2,a5,462 <atoi+0x48>
 434:	872a                	mv	a4,a0
  n = 0;
 436:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 438:	0705                	addi	a4,a4,1 # 3001 <base+0xff1>
 43a:	0025179b          	slliw	a5,a0,0x2
 43e:	9fa9                	addw	a5,a5,a0
 440:	0017979b          	slliw	a5,a5,0x1
 444:	9fb5                	addw	a5,a5,a3
 446:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 44a:	00074683          	lbu	a3,0(a4)
 44e:	fd06879b          	addiw	a5,a3,-48
 452:	0ff7f793          	zext.b	a5,a5
 456:	fef671e3          	bgeu	a2,a5,438 <atoi+0x1e>
  return n;
}
 45a:	60a2                	ld	ra,8(sp)
 45c:	6402                	ld	s0,0(sp)
 45e:	0141                	addi	sp,sp,16
 460:	8082                	ret
  n = 0;
 462:	4501                	li	a0,0
 464:	bfdd                	j	45a <atoi+0x40>

0000000000000466 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 466:	1141                	addi	sp,sp,-16
 468:	e406                	sd	ra,8(sp)
 46a:	e022                	sd	s0,0(sp)
 46c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 46e:	02b57563          	bgeu	a0,a1,498 <memmove+0x32>
    while (n-- > 0)
 472:	00c05f63          	blez	a2,490 <memmove+0x2a>
 476:	1602                	slli	a2,a2,0x20
 478:	9201                	srli	a2,a2,0x20
 47a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 47e:	872a                	mv	a4,a0
      *dst++ = *src++;
 480:	0585                	addi	a1,a1,1
 482:	0705                	addi	a4,a4,1
 484:	fff5c683          	lbu	a3,-1(a1)
 488:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 48c:	fee79ae3          	bne	a5,a4,480 <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 490:	60a2                	ld	ra,8(sp)
 492:	6402                	ld	s0,0(sp)
 494:	0141                	addi	sp,sp,16
 496:	8082                	ret
    while (n-- > 0)
 498:	fec05ce3          	blez	a2,490 <memmove+0x2a>
    dst += n;
 49c:	00c50733          	add	a4,a0,a2
    src += n;
 4a0:	95b2                	add	a1,a1,a2
 4a2:	fff6079b          	addiw	a5,a2,-1
 4a6:	1782                	slli	a5,a5,0x20
 4a8:	9381                	srli	a5,a5,0x20
 4aa:	fff7c793          	not	a5,a5
 4ae:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4b0:	15fd                	addi	a1,a1,-1
 4b2:	177d                	addi	a4,a4,-1
 4b4:	0005c683          	lbu	a3,0(a1)
 4b8:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 4bc:	fef71ae3          	bne	a4,a5,4b0 <memmove+0x4a>
 4c0:	bfc1                	j	490 <memmove+0x2a>

00000000000004c2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4c2:	1141                	addi	sp,sp,-16
 4c4:	e406                	sd	ra,8(sp)
 4c6:	e022                	sd	s0,0(sp)
 4c8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4ca:	c61d                	beqz	a2,4f8 <memcmp+0x36>
 4cc:	1602                	slli	a2,a2,0x20
 4ce:	9201                	srli	a2,a2,0x20
 4d0:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 4d4:	00054783          	lbu	a5,0(a0)
 4d8:	0005c703          	lbu	a4,0(a1)
 4dc:	00e79863          	bne	a5,a4,4ec <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 4e0:	0505                	addi	a0,a0,1
    p2++;
 4e2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4e4:	fed518e3          	bne	a0,a3,4d4 <memcmp+0x12>
  }
  return 0;
 4e8:	4501                	li	a0,0
 4ea:	a019                	j	4f0 <memcmp+0x2e>
      return *p1 - *p2;
 4ec:	40e7853b          	subw	a0,a5,a4
}
 4f0:	60a2                	ld	ra,8(sp)
 4f2:	6402                	ld	s0,0(sp)
 4f4:	0141                	addi	sp,sp,16
 4f6:	8082                	ret
  return 0;
 4f8:	4501                	li	a0,0
 4fa:	bfdd                	j	4f0 <memcmp+0x2e>

00000000000004fc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4fc:	1141                	addi	sp,sp,-16
 4fe:	e406                	sd	ra,8(sp)
 500:	e022                	sd	s0,0(sp)
 502:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 504:	f63ff0ef          	jal	466 <memmove>
}
 508:	60a2                	ld	ra,8(sp)
 50a:	6402                	ld	s0,0(sp)
 50c:	0141                	addi	sp,sp,16
 50e:	8082                	ret

0000000000000510 <sbrk>:

char *
sbrk(int n)
{
 510:	1141                	addi	sp,sp,-16
 512:	e406                	sd	ra,8(sp)
 514:	e022                	sd	s0,0(sp)
 516:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 518:	4585                	li	a1,1
 51a:	0b2000ef          	jal	5cc <sys_sbrk>
}
 51e:	60a2                	ld	ra,8(sp)
 520:	6402                	ld	s0,0(sp)
 522:	0141                	addi	sp,sp,16
 524:	8082                	ret

0000000000000526 <sbrklazy>:

char *
sbrklazy(int n)
{
 526:	1141                	addi	sp,sp,-16
 528:	e406                	sd	ra,8(sp)
 52a:	e022                	sd	s0,0(sp)
 52c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 52e:	4589                	li	a1,2
 530:	09c000ef          	jal	5cc <sys_sbrk>
}
 534:	60a2                	ld	ra,8(sp)
 536:	6402                	ld	s0,0(sp)
 538:	0141                	addi	sp,sp,16
 53a:	8082                	ret

000000000000053c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 53c:	4885                	li	a7,1
 ecall
 53e:	00000073          	ecall
 ret
 542:	8082                	ret

0000000000000544 <exit>:
.global exit
exit:
 li a7, SYS_exit
 544:	4889                	li	a7,2
 ecall
 546:	00000073          	ecall
 ret
 54a:	8082                	ret

000000000000054c <wait>:
.global wait
wait:
 li a7, SYS_wait
 54c:	488d                	li	a7,3
 ecall
 54e:	00000073          	ecall
 ret
 552:	8082                	ret

0000000000000554 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 554:	4891                	li	a7,4
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <read>:
.global read
read:
 li a7, SYS_read
 55c:	4895                	li	a7,5
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <write>:
.global write
write:
 li a7, SYS_write
 564:	48c1                	li	a7,16
 ecall
 566:	00000073          	ecall
 ret
 56a:	8082                	ret

000000000000056c <close>:
.global close
close:
 li a7, SYS_close
 56c:	48d5                	li	a7,21
 ecall
 56e:	00000073          	ecall
 ret
 572:	8082                	ret

0000000000000574 <kill>:
.global kill
kill:
 li a7, SYS_kill
 574:	4899                	li	a7,6
 ecall
 576:	00000073          	ecall
 ret
 57a:	8082                	ret

000000000000057c <exec>:
.global exec
exec:
 li a7, SYS_exec
 57c:	489d                	li	a7,7
 ecall
 57e:	00000073          	ecall
 ret
 582:	8082                	ret

0000000000000584 <open>:
.global open
open:
 li a7, SYS_open
 584:	48bd                	li	a7,15
 ecall
 586:	00000073          	ecall
 ret
 58a:	8082                	ret

000000000000058c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 58c:	48c5                	li	a7,17
 ecall
 58e:	00000073          	ecall
 ret
 592:	8082                	ret

0000000000000594 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 594:	48c9                	li	a7,18
 ecall
 596:	00000073          	ecall
 ret
 59a:	8082                	ret

000000000000059c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 59c:	48a1                	li	a7,8
 ecall
 59e:	00000073          	ecall
 ret
 5a2:	8082                	ret

00000000000005a4 <link>:
.global link
link:
 li a7, SYS_link
 5a4:	48cd                	li	a7,19
 ecall
 5a6:	00000073          	ecall
 ret
 5aa:	8082                	ret

00000000000005ac <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5ac:	48d1                	li	a7,20
 ecall
 5ae:	00000073          	ecall
 ret
 5b2:	8082                	ret

00000000000005b4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5b4:	48a5                	li	a7,9
 ecall
 5b6:	00000073          	ecall
 ret
 5ba:	8082                	ret

00000000000005bc <dup>:
.global dup
dup:
 li a7, SYS_dup
 5bc:	48a9                	li	a7,10
 ecall
 5be:	00000073          	ecall
 ret
 5c2:	8082                	ret

00000000000005c4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5c4:	48ad                	li	a7,11
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 5cc:	48b1                	li	a7,12
 ecall
 5ce:	00000073          	ecall
 ret
 5d2:	8082                	ret

00000000000005d4 <pause>:
.global pause
pause:
 li a7, SYS_pause
 5d4:	48b5                	li	a7,13
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5dc:	48b9                	li	a7,14
 ecall
 5de:	00000073          	ecall
 ret
 5e2:	8082                	ret

00000000000005e4 <sync>:
.global sync
sync:
 li a7, SYS_sync
 5e4:	48d9                	li	a7,22
 ecall
 5e6:	00000073          	ecall
 ret
 5ea:	8082                	ret

00000000000005ec <getmeminfo>:
.global getmeminfo
getmeminfo:
 li a7, SYS_getmeminfo
 5ec:	48dd                	li	a7,23
 ecall
 5ee:	00000073          	ecall
 ret
 5f2:	8082                	ret

00000000000005f4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5f4:	1101                	addi	sp,sp,-32
 5f6:	ec06                	sd	ra,24(sp)
 5f8:	e822                	sd	s0,16(sp)
 5fa:	1000                	addi	s0,sp,32
 5fc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 600:	4605                	li	a2,1
 602:	fef40593          	addi	a1,s0,-17
 606:	f5fff0ef          	jal	564 <write>
}
 60a:	60e2                	ld	ra,24(sp)
 60c:	6442                	ld	s0,16(sp)
 60e:	6105                	addi	sp,sp,32
 610:	8082                	ret

0000000000000612 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 612:	715d                	addi	sp,sp,-80
 614:	e486                	sd	ra,72(sp)
 616:	e0a2                	sd	s0,64(sp)
 618:	f84a                	sd	s2,48(sp)
 61a:	f44e                	sd	s3,40(sp)
 61c:	0880                	addi	s0,sp,80
 61e:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 620:	c6d1                	beqz	a3,6ac <printint+0x9a>
 622:	0805d563          	bgez	a1,6ac <printint+0x9a>
    neg = 1;
    x = -xx;
 626:	40b005b3          	neg	a1,a1
    neg = 1;
 62a:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 62c:	fb840993          	addi	s3,s0,-72
  neg = 0;
 630:	86ce                	mv	a3,s3
  i = 0;
 632:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 634:	00001817          	auipc	a6,0x1
 638:	aac80813          	addi	a6,a6,-1364 # 10e0 <digits>
 63c:	88ba                	mv	a7,a4
 63e:	0017051b          	addiw	a0,a4,1
 642:	872a                	mv	a4,a0
 644:	02c5f7b3          	remu	a5,a1,a2
 648:	97c2                	add	a5,a5,a6
 64a:	0007c783          	lbu	a5,0(a5)
 64e:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 652:	87ae                	mv	a5,a1
 654:	02c5d5b3          	divu	a1,a1,a2
 658:	0685                	addi	a3,a3,1
 65a:	fec7f1e3          	bgeu	a5,a2,63c <printint+0x2a>
  if (neg)
 65e:	00030c63          	beqz	t1,676 <printint+0x64>
    buf[i++] = '-';
 662:	fd050793          	addi	a5,a0,-48
 666:	00878533          	add	a0,a5,s0
 66a:	02d00793          	li	a5,45
 66e:	fef50423          	sb	a5,-24(a0)
 672:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 676:	02e05563          	blez	a4,6a0 <printint+0x8e>
 67a:	fc26                	sd	s1,56(sp)
 67c:	377d                	addiw	a4,a4,-1
 67e:	00e984b3          	add	s1,s3,a4
 682:	19fd                	addi	s3,s3,-1
 684:	99ba                	add	s3,s3,a4
 686:	1702                	slli	a4,a4,0x20
 688:	9301                	srli	a4,a4,0x20
 68a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 68e:	0004c583          	lbu	a1,0(s1)
 692:	854a                	mv	a0,s2
 694:	f61ff0ef          	jal	5f4 <putc>
  while (--i >= 0)
 698:	14fd                	addi	s1,s1,-1
 69a:	ff349ae3          	bne	s1,s3,68e <printint+0x7c>
 69e:	74e2                	ld	s1,56(sp)
}
 6a0:	60a6                	ld	ra,72(sp)
 6a2:	6406                	ld	s0,64(sp)
 6a4:	7942                	ld	s2,48(sp)
 6a6:	79a2                	ld	s3,40(sp)
 6a8:	6161                	addi	sp,sp,80
 6aa:	8082                	ret
  neg = 0;
 6ac:	4301                	li	t1,0
 6ae:	bfbd                	j	62c <printint+0x1a>

00000000000006b0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6b0:	711d                	addi	sp,sp,-96
 6b2:	ec86                	sd	ra,88(sp)
 6b4:	e8a2                	sd	s0,80(sp)
 6b6:	e4a6                	sd	s1,72(sp)
 6b8:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 6ba:	0005c483          	lbu	s1,0(a1)
 6be:	22048363          	beqz	s1,8e4 <vprintf+0x234>
 6c2:	e0ca                	sd	s2,64(sp)
 6c4:	fc4e                	sd	s3,56(sp)
 6c6:	f852                	sd	s4,48(sp)
 6c8:	f456                	sd	s5,40(sp)
 6ca:	f05a                	sd	s6,32(sp)
 6cc:	ec5e                	sd	s7,24(sp)
 6ce:	e862                	sd	s8,16(sp)
 6d0:	8b2a                	mv	s6,a0
 6d2:	8a2e                	mv	s4,a1
 6d4:	8bb2                	mv	s7,a2
  state = 0;
 6d6:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 6d8:	4901                	li	s2,0
 6da:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 6dc:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 6e0:	06400c13          	li	s8,100
 6e4:	a00d                	j	706 <vprintf+0x56>
        putc(fd, c0);
 6e6:	85a6                	mv	a1,s1
 6e8:	855a                	mv	a0,s6
 6ea:	f0bff0ef          	jal	5f4 <putc>
 6ee:	a019                	j	6f4 <vprintf+0x44>
    } else if (state == '%') {
 6f0:	03598363          	beq	s3,s5,716 <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 6f4:	0019079b          	addiw	a5,s2,1
 6f8:	893e                	mv	s2,a5
 6fa:	873e                	mv	a4,a5
 6fc:	97d2                	add	a5,a5,s4
 6fe:	0007c483          	lbu	s1,0(a5)
 702:	1c048a63          	beqz	s1,8d6 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 706:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 70a:	fe0993e3          	bnez	s3,6f0 <vprintf+0x40>
      if (c0 == '%') {
 70e:	fd579ce3          	bne	a5,s5,6e6 <vprintf+0x36>
        state = '%';
 712:	89be                	mv	s3,a5
 714:	b7c5                	j	6f4 <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 716:	00ea06b3          	add	a3,s4,a4
 71a:	0016c603          	lbu	a2,1(a3)
      if (c1)
 71e:	1c060863          	beqz	a2,8ee <vprintf+0x23e>
      if (c0 == 'd') {
 722:	03878763          	beq	a5,s8,750 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 726:	f9478693          	addi	a3,a5,-108
 72a:	0016b693          	seqz	a3,a3
 72e:	f9c60593          	addi	a1,a2,-100
 732:	e99d                	bnez	a1,768 <vprintf+0xb8>
 734:	ca95                	beqz	a3,768 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 736:	008b8493          	addi	s1,s7,8
 73a:	4685                	li	a3,1
 73c:	4629                	li	a2,10
 73e:	000bb583          	ld	a1,0(s7)
 742:	855a                	mv	a0,s6
 744:	ecfff0ef          	jal	612 <printint>
        i += 1;
 748:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 74a:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 74c:	4981                	li	s3,0
 74e:	b75d                	j	6f4 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 750:	008b8493          	addi	s1,s7,8
 754:	4685                	li	a3,1
 756:	4629                	li	a2,10
 758:	000ba583          	lw	a1,0(s7)
 75c:	855a                	mv	a0,s6
 75e:	eb5ff0ef          	jal	612 <printint>
 762:	8ba6                	mv	s7,s1
      state = 0;
 764:	4981                	li	s3,0
 766:	b779                	j	6f4 <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 768:	9752                	add	a4,a4,s4
 76a:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 76e:	f9460713          	addi	a4,a2,-108
 772:	00173713          	seqz	a4,a4
 776:	8f75                	and	a4,a4,a3
 778:	f9c58513          	addi	a0,a1,-100
 77c:	18051363          	bnez	a0,902 <vprintf+0x252>
 780:	18070163          	beqz	a4,902 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 784:	008b8493          	addi	s1,s7,8
 788:	4685                	li	a3,1
 78a:	4629                	li	a2,10
 78c:	000bb583          	ld	a1,0(s7)
 790:	855a                	mv	a0,s6
 792:	e81ff0ef          	jal	612 <printint>
        i += 2;
 796:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 798:	8ba6                	mv	s7,s1
      state = 0;
 79a:	4981                	li	s3,0
        i += 2;
 79c:	bfa1                	j	6f4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 79e:	008b8493          	addi	s1,s7,8
 7a2:	4681                	li	a3,0
 7a4:	4629                	li	a2,10
 7a6:	000be583          	lwu	a1,0(s7)
 7aa:	855a                	mv	a0,s6
 7ac:	e67ff0ef          	jal	612 <printint>
 7b0:	8ba6                	mv	s7,s1
      state = 0;
 7b2:	4981                	li	s3,0
 7b4:	b781                	j	6f4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7b6:	008b8493          	addi	s1,s7,8
 7ba:	4681                	li	a3,0
 7bc:	4629                	li	a2,10
 7be:	000bb583          	ld	a1,0(s7)
 7c2:	855a                	mv	a0,s6
 7c4:	e4fff0ef          	jal	612 <printint>
        i += 1;
 7c8:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 7ca:	8ba6                	mv	s7,s1
      state = 0;
 7cc:	4981                	li	s3,0
 7ce:	b71d                	j	6f4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7d0:	008b8493          	addi	s1,s7,8
 7d4:	4681                	li	a3,0
 7d6:	4629                	li	a2,10
 7d8:	000bb583          	ld	a1,0(s7)
 7dc:	855a                	mv	a0,s6
 7de:	e35ff0ef          	jal	612 <printint>
        i += 2;
 7e2:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7e4:	8ba6                	mv	s7,s1
      state = 0;
 7e6:	4981                	li	s3,0
        i += 2;
 7e8:	b731                	j	6f4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 7ea:	008b8493          	addi	s1,s7,8
 7ee:	4681                	li	a3,0
 7f0:	4641                	li	a2,16
 7f2:	000be583          	lwu	a1,0(s7)
 7f6:	855a                	mv	a0,s6
 7f8:	e1bff0ef          	jal	612 <printint>
 7fc:	8ba6                	mv	s7,s1
      state = 0;
 7fe:	4981                	li	s3,0
 800:	bdd5                	j	6f4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 802:	008b8493          	addi	s1,s7,8
 806:	4681                	li	a3,0
 808:	4641                	li	a2,16
 80a:	000bb583          	ld	a1,0(s7)
 80e:	855a                	mv	a0,s6
 810:	e03ff0ef          	jal	612 <printint>
        i += 1;
 814:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 816:	8ba6                	mv	s7,s1
      state = 0;
 818:	4981                	li	s3,0
 81a:	bde9                	j	6f4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 81c:	008b8493          	addi	s1,s7,8
 820:	4681                	li	a3,0
 822:	4641                	li	a2,16
 824:	000bb583          	ld	a1,0(s7)
 828:	855a                	mv	a0,s6
 82a:	de9ff0ef          	jal	612 <printint>
        i += 2;
 82e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 830:	8ba6                	mv	s7,s1
      state = 0;
 832:	4981                	li	s3,0
        i += 2;
 834:	b5c1                	j	6f4 <vprintf+0x44>
 836:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 838:	008b8793          	addi	a5,s7,8
 83c:	8cbe                	mv	s9,a5
 83e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 842:	03000593          	li	a1,48
 846:	855a                	mv	a0,s6
 848:	dadff0ef          	jal	5f4 <putc>
  putc(fd, 'x');
 84c:	07800593          	li	a1,120
 850:	855a                	mv	a0,s6
 852:	da3ff0ef          	jal	5f4 <putc>
 856:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 858:	00001b97          	auipc	s7,0x1
 85c:	888b8b93          	addi	s7,s7,-1912 # 10e0 <digits>
 860:	03c9d793          	srli	a5,s3,0x3c
 864:	97de                	add	a5,a5,s7
 866:	0007c583          	lbu	a1,0(a5)
 86a:	855a                	mv	a0,s6
 86c:	d89ff0ef          	jal	5f4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 870:	0992                	slli	s3,s3,0x4
 872:	34fd                	addiw	s1,s1,-1
 874:	f4f5                	bnez	s1,860 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 876:	8be6                	mv	s7,s9
      state = 0;
 878:	4981                	li	s3,0
 87a:	6ca2                	ld	s9,8(sp)
 87c:	bda5                	j	6f4 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 87e:	008b8493          	addi	s1,s7,8
 882:	000bc583          	lbu	a1,0(s7)
 886:	855a                	mv	a0,s6
 888:	d6dff0ef          	jal	5f4 <putc>
 88c:	8ba6                	mv	s7,s1
      state = 0;
 88e:	4981                	li	s3,0
 890:	b595                	j	6f4 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 892:	008b8993          	addi	s3,s7,8
 896:	000bb483          	ld	s1,0(s7)
 89a:	cc91                	beqz	s1,8b6 <vprintf+0x206>
        for (; *s; s++)
 89c:	0004c583          	lbu	a1,0(s1)
 8a0:	c985                	beqz	a1,8d0 <vprintf+0x220>
          putc(fd, *s);
 8a2:	855a                	mv	a0,s6
 8a4:	d51ff0ef          	jal	5f4 <putc>
        for (; *s; s++)
 8a8:	0485                	addi	s1,s1,1
 8aa:	0004c583          	lbu	a1,0(s1)
 8ae:	f9f5                	bnez	a1,8a2 <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 8b0:	8bce                	mv	s7,s3
      state = 0;
 8b2:	4981                	li	s3,0
 8b4:	b581                	j	6f4 <vprintf+0x44>
          s = "(null)";
 8b6:	00001497          	auipc	s1,0x1
 8ba:	82248493          	addi	s1,s1,-2014 # 10d8 <malloc+0x686>
        for (; *s; s++)
 8be:	02800593          	li	a1,40
 8c2:	b7c5                	j	8a2 <vprintf+0x1f2>
        putc(fd, '%');
 8c4:	85be                	mv	a1,a5
 8c6:	855a                	mv	a0,s6
 8c8:	d2dff0ef          	jal	5f4 <putc>
      state = 0;
 8cc:	4981                	li	s3,0
 8ce:	b51d                	j	6f4 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 8d0:	8bce                	mv	s7,s3
      state = 0;
 8d2:	4981                	li	s3,0
 8d4:	b505                	j	6f4 <vprintf+0x44>
 8d6:	6906                	ld	s2,64(sp)
 8d8:	79e2                	ld	s3,56(sp)
 8da:	7a42                	ld	s4,48(sp)
 8dc:	7aa2                	ld	s5,40(sp)
 8de:	7b02                	ld	s6,32(sp)
 8e0:	6be2                	ld	s7,24(sp)
 8e2:	6c42                	ld	s8,16(sp)
    }
  }
}
 8e4:	60e6                	ld	ra,88(sp)
 8e6:	6446                	ld	s0,80(sp)
 8e8:	64a6                	ld	s1,72(sp)
 8ea:	6125                	addi	sp,sp,96
 8ec:	8082                	ret
      if (c0 == 'd') {
 8ee:	06400713          	li	a4,100
 8f2:	e4e78fe3          	beq	a5,a4,750 <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 8f6:	f9478693          	addi	a3,a5,-108
 8fa:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 8fe:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 900:	4701                	li	a4,0
      } else if (c0 == 'u') {
 902:	07500513          	li	a0,117
 906:	e8a78ce3          	beq	a5,a0,79e <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 90a:	f8b60513          	addi	a0,a2,-117
 90e:	e119                	bnez	a0,914 <vprintf+0x264>
 910:	ea0693e3          	bnez	a3,7b6 <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 914:	f8b58513          	addi	a0,a1,-117
 918:	e119                	bnez	a0,91e <vprintf+0x26e>
 91a:	ea071be3          	bnez	a4,7d0 <vprintf+0x120>
      } else if (c0 == 'x') {
 91e:	07800513          	li	a0,120
 922:	eca784e3          	beq	a5,a0,7ea <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 926:	f8860613          	addi	a2,a2,-120
 92a:	e219                	bnez	a2,930 <vprintf+0x280>
 92c:	ec069be3          	bnez	a3,802 <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 930:	f8858593          	addi	a1,a1,-120
 934:	e199                	bnez	a1,93a <vprintf+0x28a>
 936:	ee0713e3          	bnez	a4,81c <vprintf+0x16c>
      } else if (c0 == 'p') {
 93a:	07000713          	li	a4,112
 93e:	eee78ce3          	beq	a5,a4,836 <vprintf+0x186>
      } else if (c0 == 'c') {
 942:	06300713          	li	a4,99
 946:	f2e78ce3          	beq	a5,a4,87e <vprintf+0x1ce>
      } else if (c0 == 's') {
 94a:	07300713          	li	a4,115
 94e:	f4e782e3          	beq	a5,a4,892 <vprintf+0x1e2>
      } else if (c0 == '%') {
 952:	02500713          	li	a4,37
 956:	f6e787e3          	beq	a5,a4,8c4 <vprintf+0x214>
        putc(fd, '%');
 95a:	02500593          	li	a1,37
 95e:	855a                	mv	a0,s6
 960:	c95ff0ef          	jal	5f4 <putc>
        putc(fd, c0);
 964:	85a6                	mv	a1,s1
 966:	855a                	mv	a0,s6
 968:	c8dff0ef          	jal	5f4 <putc>
      state = 0;
 96c:	4981                	li	s3,0
 96e:	b359                	j	6f4 <vprintf+0x44>

0000000000000970 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 970:	715d                	addi	sp,sp,-80
 972:	ec06                	sd	ra,24(sp)
 974:	e822                	sd	s0,16(sp)
 976:	1000                	addi	s0,sp,32
 978:	e010                	sd	a2,0(s0)
 97a:	e414                	sd	a3,8(s0)
 97c:	e818                	sd	a4,16(s0)
 97e:	ec1c                	sd	a5,24(s0)
 980:	03043023          	sd	a6,32(s0)
 984:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 988:	8622                	mv	a2,s0
 98a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 98e:	d23ff0ef          	jal	6b0 <vprintf>
}
 992:	60e2                	ld	ra,24(sp)
 994:	6442                	ld	s0,16(sp)
 996:	6161                	addi	sp,sp,80
 998:	8082                	ret

000000000000099a <printf>:

void
printf(const char *fmt, ...)
{
 99a:	711d                	addi	sp,sp,-96
 99c:	ec06                	sd	ra,24(sp)
 99e:	e822                	sd	s0,16(sp)
 9a0:	1000                	addi	s0,sp,32
 9a2:	e40c                	sd	a1,8(s0)
 9a4:	e810                	sd	a2,16(s0)
 9a6:	ec14                	sd	a3,24(s0)
 9a8:	f018                	sd	a4,32(s0)
 9aa:	f41c                	sd	a5,40(s0)
 9ac:	03043823          	sd	a6,48(s0)
 9b0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 9b4:	00840613          	addi	a2,s0,8
 9b8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 9bc:	85aa                	mv	a1,a0
 9be:	4505                	li	a0,1
 9c0:	cf1ff0ef          	jal	6b0 <vprintf>
}
 9c4:	60e2                	ld	ra,24(sp)
 9c6:	6442                	ld	s0,16(sp)
 9c8:	6125                	addi	sp,sp,96
 9ca:	8082                	ret

00000000000009cc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9cc:	1141                	addi	sp,sp,-16
 9ce:	e406                	sd	ra,8(sp)
 9d0:	e022                	sd	s0,0(sp)
 9d2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 9d4:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9d8:	00001797          	auipc	a5,0x1
 9dc:	6287b783          	ld	a5,1576(a5) # 2000 <freep>
 9e0:	a039                	j	9ee <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9e2:	6398                	ld	a4,0(a5)
 9e4:	00e7e463          	bltu	a5,a4,9ec <free+0x20>
 9e8:	00e6ea63          	bltu	a3,a4,9fc <free+0x30>
{
 9ec:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9ee:	fed7fae3          	bgeu	a5,a3,9e2 <free+0x16>
 9f2:	6398                	ld	a4,0(a5)
 9f4:	00e6e463          	bltu	a3,a4,9fc <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9f8:	fee7eae3          	bltu	a5,a4,9ec <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 9fc:	ff852583          	lw	a1,-8(a0)
 a00:	6390                	ld	a2,0(a5)
 a02:	02059813          	slli	a6,a1,0x20
 a06:	01c85713          	srli	a4,a6,0x1c
 a0a:	9736                	add	a4,a4,a3
 a0c:	02e60563          	beq	a2,a4,a36 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 a10:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 a14:	4790                	lw	a2,8(a5)
 a16:	02061593          	slli	a1,a2,0x20
 a1a:	01c5d713          	srli	a4,a1,0x1c
 a1e:	973e                	add	a4,a4,a5
 a20:	02e68263          	beq	a3,a4,a44 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 a24:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a26:	00001717          	auipc	a4,0x1
 a2a:	5cf73d23          	sd	a5,1498(a4) # 2000 <freep>
}
 a2e:	60a2                	ld	ra,8(sp)
 a30:	6402                	ld	s0,0(sp)
 a32:	0141                	addi	sp,sp,16
 a34:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 a36:	4618                	lw	a4,8(a2)
 a38:	9f2d                	addw	a4,a4,a1
 a3a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a3e:	6398                	ld	a4,0(a5)
 a40:	6310                	ld	a2,0(a4)
 a42:	b7f9                	j	a10 <free+0x44>
    p->s.size += bp->s.size;
 a44:	ff852703          	lw	a4,-8(a0)
 a48:	9f31                	addw	a4,a4,a2
 a4a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a4c:	ff053683          	ld	a3,-16(a0)
 a50:	bfd1                	j	a24 <free+0x58>

0000000000000a52 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 a52:	7139                	addi	sp,sp,-64
 a54:	fc06                	sd	ra,56(sp)
 a56:	f822                	sd	s0,48(sp)
 a58:	f04a                	sd	s2,32(sp)
 a5a:	ec4e                	sd	s3,24(sp)
 a5c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 a5e:	02051993          	slli	s3,a0,0x20
 a62:	0209d993          	srli	s3,s3,0x20
 a66:	09bd                	addi	s3,s3,15
 a68:	0049d993          	srli	s3,s3,0x4
 a6c:	2985                	addiw	s3,s3,1
 a6e:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 a70:	00001517          	auipc	a0,0x1
 a74:	59053503          	ld	a0,1424(a0) # 2000 <freep>
 a78:	c905                	beqz	a0,aa8 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 a7a:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 a7c:	4798                	lw	a4,8(a5)
 a7e:	09377663          	bgeu	a4,s3,b0a <malloc+0xb8>
 a82:	f426                	sd	s1,40(sp)
 a84:	e852                	sd	s4,16(sp)
 a86:	e456                	sd	s5,8(sp)
 a88:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 a8a:	8a4e                	mv	s4,s3
 a8c:	6705                	lui	a4,0x1
 a8e:	00e9f363          	bgeu	s3,a4,a94 <malloc+0x42>
 a92:	6a05                	lui	s4,0x1
 a94:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a98:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 a9c:	00001497          	auipc	s1,0x1
 aa0:	56448493          	addi	s1,s1,1380 # 2000 <freep>
  if (p == SBRK_ERROR)
 aa4:	5afd                	li	s5,-1
 aa6:	a83d                	j	ae4 <malloc+0x92>
 aa8:	f426                	sd	s1,40(sp)
 aaa:	e852                	sd	s4,16(sp)
 aac:	e456                	sd	s5,8(sp)
 aae:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 ab0:	00001797          	auipc	a5,0x1
 ab4:	56078793          	addi	a5,a5,1376 # 2010 <base>
 ab8:	00001717          	auipc	a4,0x1
 abc:	54f73423          	sd	a5,1352(a4) # 2000 <freep>
 ac0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 ac2:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 ac6:	b7d1                	j	a8a <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 ac8:	6398                	ld	a4,0(a5)
 aca:	e118                	sd	a4,0(a0)
 acc:	a899                	j	b22 <malloc+0xd0>
  hp->s.size = nu;
 ace:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 ad2:	0541                	addi	a0,a0,16
 ad4:	ef9ff0ef          	jal	9cc <free>
  return freep;
 ad8:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 ada:	c125                	beqz	a0,b3a <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 adc:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 ade:	4798                	lw	a4,8(a5)
 ae0:	03277163          	bgeu	a4,s2,b02 <malloc+0xb0>
    if (p == freep)
 ae4:	6098                	ld	a4,0(s1)
 ae6:	853e                	mv	a0,a5
 ae8:	fef71ae3          	bne	a4,a5,adc <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 aec:	8552                	mv	a0,s4
 aee:	a23ff0ef          	jal	510 <sbrk>
  if (p == SBRK_ERROR)
 af2:	fd551ee3          	bne	a0,s5,ace <malloc+0x7c>
        return 0;
 af6:	4501                	li	a0,0
 af8:	74a2                	ld	s1,40(sp)
 afa:	6a42                	ld	s4,16(sp)
 afc:	6aa2                	ld	s5,8(sp)
 afe:	6b02                	ld	s6,0(sp)
 b00:	a03d                	j	b2e <malloc+0xdc>
 b02:	74a2                	ld	s1,40(sp)
 b04:	6a42                	ld	s4,16(sp)
 b06:	6aa2                	ld	s5,8(sp)
 b08:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 b0a:	fae90fe3          	beq	s2,a4,ac8 <malloc+0x76>
        p->s.size -= nunits;
 b0e:	4137073b          	subw	a4,a4,s3
 b12:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b14:	02071693          	slli	a3,a4,0x20
 b18:	01c6d713          	srli	a4,a3,0x1c
 b1c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b1e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b22:	00001717          	auipc	a4,0x1
 b26:	4ca73f23          	sd	a0,1246(a4) # 2000 <freep>
      return (void *)(p + 1);
 b2a:	01078513          	addi	a0,a5,16
  }
}
 b2e:	70e2                	ld	ra,56(sp)
 b30:	7442                	ld	s0,48(sp)
 b32:	7902                	ld	s2,32(sp)
 b34:	69e2                	ld	s3,24(sp)
 b36:	6121                	addi	sp,sp,64
 b38:	8082                	ret
 b3a:	74a2                	ld	s1,40(sp)
 b3c:	6a42                	ld	s4,16(sp)
 b3e:	6aa2                	ld	s5,8(sp)
 b40:	6b02                	ld	s6,0(sp)
 b42:	b7f5                	j	b2e <malloc+0xdc>
