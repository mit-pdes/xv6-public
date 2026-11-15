
user/_vatest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int global_var = 42;

int main(int argc, char *argv[]) {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	1800                	addi	s0,sp,48
  int local_var = 100;
   c:	06400793          	li	a5,100
  10:	fcf42e23          	sw	a5,-36(s0)
  char *heap_var = (char *)malloc(128);
  14:	08000513          	li	a0,128
  18:	181000ef          	jal	998 <malloc>
  1c:	84aa                	mv	s1,a0
  if (heap_var)
  1e:	c509                	beqz	a0,28 <main+0x28>
    heap_var[0] = 'X';
  20:	05800793          	li	a5,88
  24:	00f50023          	sb	a5,0(a0)

  printf("============================================================\n");
  28:	00001517          	auipc	a0,0x1
  2c:	a6850513          	addi	a0,a0,-1432 # a90 <malloc+0xf8>
  30:	0b1000ef          	jal	8e0 <printf>
  printf("  Virtual to Physical Address Translation Test (vatest)     \n");
  34:	00001517          	auipc	a0,0x1
  38:	aa450513          	addi	a0,a0,-1372 # ad8 <malloc+0x140>
  3c:	0a5000ef          	jal	8e0 <printf>
  printf("============================================================\n\n");
  40:	00001517          	auipc	a0,0x1
  44:	ad850513          	addi	a0,a0,-1320 # b18 <malloc+0x180>
  48:	099000ef          	jal	8e0 <printf>

  printf("--- Step 1: Translate Global, Local (Stack), and Heap Variables ---\n");
  4c:	00001517          	auipc	a0,0x1
  50:	b0c50513          	addi	a0,a0,-1268 # b58 <malloc+0x1c0>
  54:	08d000ef          	jal	8e0 <printf>
  uint64 g_va = (uint64)&global_var;
  uint64 g_pa = va2pa(g_va);
  58:	00002517          	auipc	a0,0x2
  5c:	fa850513          	addi	a0,a0,-88 # 2000 <global_var>
  60:	4d2000ef          	jal	532 <va2pa>
  64:	862a                	mv	a2,a0
  printf("Global Variable:  VA = 0x%lx  -->  PA = 0x%lx\n", g_va, g_pa);
  66:	00002597          	auipc	a1,0x2
  6a:	f9a58593          	addi	a1,a1,-102 # 2000 <global_var>
  6e:	00001517          	auipc	a0,0x1
  72:	b3250513          	addi	a0,a0,-1230 # ba0 <malloc+0x208>
  76:	06b000ef          	jal	8e0 <printf>

  uint64 l_va = (uint64)&local_var;
  7a:	fdc40913          	addi	s2,s0,-36
  uint64 l_pa = va2pa(l_va);
  7e:	854a                	mv	a0,s2
  80:	4b2000ef          	jal	532 <va2pa>
  84:	862a                	mv	a2,a0
  printf("Local Variable:   VA = 0x%lx  -->  PA = 0x%lx\n", l_va, l_pa);
  86:	85ca                	mv	a1,s2
  88:	00001517          	auipc	a0,0x1
  8c:	b4850513          	addi	a0,a0,-1208 # bd0 <malloc+0x238>
  90:	051000ef          	jal	8e0 <printf>

  uint64 h_va = (uint64)heap_var;
  uint64 h_pa = va2pa(h_va);
  94:	8526                	mv	a0,s1
  96:	49c000ef          	jal	532 <va2pa>
  9a:	862a                	mv	a2,a0
  printf("Heap Variable:    VA = 0x%lx  -->  PA = 0x%lx\n\n", h_va, h_pa);
  9c:	85a6                	mv	a1,s1
  9e:	00001517          	auipc	a0,0x1
  a2:	b6250513          	addi	a0,a0,-1182 # c00 <malloc+0x268>
  a6:	03b000ef          	jal	8e0 <printf>

  printf("--- Step 2: Unmapped Address Translation (0x7FFFFFFF) ---\n");
  aa:	00001517          	auipc	a0,0x1
  ae:	b8650513          	addi	a0,a0,-1146 # c30 <malloc+0x298>
  b2:	02f000ef          	jal	8e0 <printf>
  uint64 bad_va = 0x7FFFFFFF;
  uint64 bad_pa = va2pa(bad_va);
  b6:	80000937          	lui	s2,0x80000
  ba:	fff94513          	not	a0,s2
  be:	474000ef          	jal	532 <va2pa>
  c2:	84aa                	mv	s1,a0
  printf("Unmapped Address: VA = 0x%lx  -->  Result = %ld (Expected: -1)\n", bad_va, (long)bad_pa);
  c4:	862a                	mv	a2,a0
  c6:	fff94593          	not	a1,s2
  ca:	00001517          	auipc	a0,0x1
  ce:	ba650513          	addi	a0,a0,-1114 # c70 <malloc+0x2d8>
  d2:	00f000ef          	jal	8e0 <printf>
  if ((long)bad_pa == -1) {
  d6:	57fd                	li	a5,-1
  d8:	04f48b63          	beq	s1,a5,12e <main+0x12e>
    printf("SUCCESS: va2pa correctly returned -1 for unmapped address.\n\n");
  } else {
    printf("FAILURE: va2pa did not return -1.\n\n");
  dc:	00001517          	auipc	a0,0x1
  e0:	c1450513          	addi	a0,a0,-1004 # cf0 <malloc+0x358>
  e4:	7fc000ef          	jal	8e0 <printf>
  }

  printf("--- Step 3: Forking Child to Demonstrate Distinct Physical Pages ---\n");
  e8:	00001517          	auipc	a0,0x1
  ec:	c3050513          	addi	a0,a0,-976 # d18 <malloc+0x380>
  f0:	7f0000ef          	jal	8e0 <printf>
  int pid = fork();
  f4:	38e000ef          	jal	482 <fork>
  if (pid < 0) {
  f8:	04054263          	bltz	a0,13c <main+0x13c>
    printf("Fork failed!\n");
    exit(1);
  }

  if (pid == 0) {
  fc:	e929                	bnez	a0,14e <main+0x14e>
    // Child
    uint64 child_g_va = (uint64)&global_var;
    uint64 child_g_pa = va2pa(child_g_va);
  fe:	00002517          	auipc	a0,0x2
 102:	f0250513          	addi	a0,a0,-254 # 2000 <global_var>
 106:	42c000ef          	jal	532 <va2pa>
 10a:	84aa                	mv	s1,a0
    printf("[Child PID %d]  VA = 0x%lx  -->  PA = 0x%lx\n", getpid(), child_g_va, child_g_pa);
 10c:	3fe000ef          	jal	50a <getpid>
 110:	85aa                	mv	a1,a0
 112:	86a6                	mv	a3,s1
 114:	00002617          	auipc	a2,0x2
 118:	eec60613          	addi	a2,a2,-276 # 2000 <global_var>
 11c:	00001517          	auipc	a0,0x1
 120:	c5450513          	addi	a0,a0,-940 # d70 <malloc+0x3d8>
 124:	7bc000ef          	jal	8e0 <printf>
    exit(0);
 128:	4501                	li	a0,0
 12a:	360000ef          	jal	48a <exit>
    printf("SUCCESS: va2pa correctly returned -1 for unmapped address.\n\n");
 12e:	00001517          	auipc	a0,0x1
 132:	b8250513          	addi	a0,a0,-1150 # cb0 <malloc+0x318>
 136:	7aa000ef          	jal	8e0 <printf>
 13a:	b77d                	j	e8 <main+0xe8>
    printf("Fork failed!\n");
 13c:	00001517          	auipc	a0,0x1
 140:	c2450513          	addi	a0,a0,-988 # d60 <malloc+0x3c8>
 144:	79c000ef          	jal	8e0 <printf>
    exit(1);
 148:	4505                	li	a0,1
 14a:	340000ef          	jal	48a <exit>
  } else {
    // Parent
    wait(0);
 14e:	4501                	li	a0,0
 150:	342000ef          	jal	492 <wait>
    uint64 parent_g_va = (uint64)&global_var;
    uint64 parent_g_pa = va2pa(parent_g_va);
 154:	00002517          	auipc	a0,0x2
 158:	eac50513          	addi	a0,a0,-340 # 2000 <global_var>
 15c:	3d6000ef          	jal	532 <va2pa>
 160:	84aa                	mv	s1,a0
    printf("[Parent PID %d] VA = 0x%lx  -->  PA = 0x%lx\n", getpid(), parent_g_va, parent_g_pa);
 162:	3a8000ef          	jal	50a <getpid>
 166:	85aa                	mv	a1,a0
 168:	86a6                	mv	a3,s1
 16a:	00002617          	auipc	a2,0x2
 16e:	e9660613          	addi	a2,a2,-362 # 2000 <global_var>
 172:	00001517          	auipc	a0,0x1
 176:	c2e50513          	addi	a0,a0,-978 # da0 <malloc+0x408>
 17a:	766000ef          	jal	8e0 <printf>
    printf("\nVERIFICATION:\n");
 17e:	00001517          	auipc	a0,0x1
 182:	c5250513          	addi	a0,a0,-942 # dd0 <malloc+0x438>
 186:	75a000ef          	jal	8e0 <printf>
    printf("Same virtual address:   0x%lx (Parent & Child)\n", parent_g_va);
 18a:	00002597          	auipc	a1,0x2
 18e:	e7658593          	addi	a1,a1,-394 # 2000 <global_var>
 192:	00001517          	auipc	a0,0x1
 196:	c4e50513          	addi	a0,a0,-946 # de0 <malloc+0x448>
 19a:	746000ef          	jal	8e0 <printf>
    printf("Separate physical page: PA copied on fork (Parent PA != Child PA)\n");
 19e:	00001517          	auipc	a0,0x1
 1a2:	c7250513          	addi	a0,a0,-910 # e10 <malloc+0x478>
 1a6:	73a000ef          	jal	8e0 <printf>
  }

  printf("\n============================================================\n");
 1aa:	00001517          	auipc	a0,0x1
 1ae:	cae50513          	addi	a0,a0,-850 # e58 <malloc+0x4c0>
 1b2:	72e000ef          	jal	8e0 <printf>
  printf("vatest passed all verification steps successfully!\n");
 1b6:	00001517          	auipc	a0,0x1
 1ba:	ce250513          	addi	a0,a0,-798 # e98 <malloc+0x500>
 1be:	722000ef          	jal	8e0 <printf>
  printf("============================================================\n");
 1c2:	00001517          	auipc	a0,0x1
 1c6:	8ce50513          	addi	a0,a0,-1842 # a90 <malloc+0xf8>
 1ca:	716000ef          	jal	8e0 <printf>
  exit(0);
 1ce:	4501                	li	a0,0
 1d0:	2ba000ef          	jal	48a <exit>

00000000000001d4 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1d4:	1141                	addi	sp,sp,-16
 1d6:	e406                	sd	ra,8(sp)
 1d8:	e022                	sd	s0,0(sp)
 1da:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1dc:	e25ff0ef          	jal	0 <main>
  exit(r);
 1e0:	2aa000ef          	jal	48a <exit>

00000000000001e4 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 1e4:	1141                	addi	sp,sp,-16
 1e6:	e406                	sd	ra,8(sp)
 1e8:	e022                	sd	s0,0(sp)
 1ea:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 1ec:	87aa                	mv	a5,a0
 1ee:	0585                	addi	a1,a1,1
 1f0:	0785                	addi	a5,a5,1
 1f2:	fff5c703          	lbu	a4,-1(a1)
 1f6:	fee78fa3          	sb	a4,-1(a5)
 1fa:	fb75                	bnez	a4,1ee <strcpy+0xa>
    ;
  return os;
}
 1fc:	60a2                	ld	ra,8(sp)
 1fe:	6402                	ld	s0,0(sp)
 200:	0141                	addi	sp,sp,16
 202:	8082                	ret

0000000000000204 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 204:	1141                	addi	sp,sp,-16
 206:	e406                	sd	ra,8(sp)
 208:	e022                	sd	s0,0(sp)
 20a:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 20c:	00054783          	lbu	a5,0(a0)
 210:	cb91                	beqz	a5,224 <strcmp+0x20>
 212:	0005c703          	lbu	a4,0(a1)
 216:	00f71763          	bne	a4,a5,224 <strcmp+0x20>
    p++, q++;
 21a:	0505                	addi	a0,a0,1
 21c:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 21e:	00054783          	lbu	a5,0(a0)
 222:	fbe5                	bnez	a5,212 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 224:	0005c503          	lbu	a0,0(a1)
}
 228:	40a7853b          	subw	a0,a5,a0
 22c:	60a2                	ld	ra,8(sp)
 22e:	6402                	ld	s0,0(sp)
 230:	0141                	addi	sp,sp,16
 232:	8082                	ret

0000000000000234 <strlen>:

uint
strlen(const char *s)
{
 234:	1141                	addi	sp,sp,-16
 236:	e406                	sd	ra,8(sp)
 238:	e022                	sd	s0,0(sp)
 23a:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 23c:	00054783          	lbu	a5,0(a0)
 240:	cf91                	beqz	a5,25c <strlen+0x28>
 242:	00150793          	addi	a5,a0,1
 246:	86be                	mv	a3,a5
 248:	0785                	addi	a5,a5,1
 24a:	fff7c703          	lbu	a4,-1(a5)
 24e:	ff65                	bnez	a4,246 <strlen+0x12>
 250:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 254:	60a2                	ld	ra,8(sp)
 256:	6402                	ld	s0,0(sp)
 258:	0141                	addi	sp,sp,16
 25a:	8082                	ret
  for (n = 0; s[n]; n++)
 25c:	4501                	li	a0,0
 25e:	bfdd                	j	254 <strlen+0x20>

0000000000000260 <memset>:

void *
memset(void *dst, int c, uint n)
{
 260:	1141                	addi	sp,sp,-16
 262:	e406                	sd	ra,8(sp)
 264:	e022                	sd	s0,0(sp)
 266:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 268:	ca19                	beqz	a2,27e <memset+0x1e>
 26a:	87aa                	mv	a5,a0
 26c:	1602                	slli	a2,a2,0x20
 26e:	9201                	srli	a2,a2,0x20
 270:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 274:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 278:	0785                	addi	a5,a5,1
 27a:	fee79de3          	bne	a5,a4,274 <memset+0x14>
  }
  return dst;
}
 27e:	60a2                	ld	ra,8(sp)
 280:	6402                	ld	s0,0(sp)
 282:	0141                	addi	sp,sp,16
 284:	8082                	ret

0000000000000286 <strchr>:

char *
strchr(const char *s, char c)
{
 286:	1141                	addi	sp,sp,-16
 288:	e406                	sd	ra,8(sp)
 28a:	e022                	sd	s0,0(sp)
 28c:	0800                	addi	s0,sp,16
  for (; *s; s++)
 28e:	00054783          	lbu	a5,0(a0)
 292:	cf81                	beqz	a5,2aa <strchr+0x24>
    if (*s == c)
 294:	00f58763          	beq	a1,a5,2a2 <strchr+0x1c>
  for (; *s; s++)
 298:	0505                	addi	a0,a0,1
 29a:	00054783          	lbu	a5,0(a0)
 29e:	fbfd                	bnez	a5,294 <strchr+0xe>
      return (char *)s;
  return 0;
 2a0:	4501                	li	a0,0
}
 2a2:	60a2                	ld	ra,8(sp)
 2a4:	6402                	ld	s0,0(sp)
 2a6:	0141                	addi	sp,sp,16
 2a8:	8082                	ret
  return 0;
 2aa:	4501                	li	a0,0
 2ac:	bfdd                	j	2a2 <strchr+0x1c>

00000000000002ae <gets>:

char *
gets(char *buf, int max)
{
 2ae:	711d                	addi	sp,sp,-96
 2b0:	ec86                	sd	ra,88(sp)
 2b2:	e8a2                	sd	s0,80(sp)
 2b4:	e4a6                	sd	s1,72(sp)
 2b6:	e0ca                	sd	s2,64(sp)
 2b8:	fc4e                	sd	s3,56(sp)
 2ba:	f852                	sd	s4,48(sp)
 2bc:	f456                	sd	s5,40(sp)
 2be:	f05a                	sd	s6,32(sp)
 2c0:	ec5e                	sd	s7,24(sp)
 2c2:	e862                	sd	s8,16(sp)
 2c4:	1080                	addi	s0,sp,96
 2c6:	8baa                	mv	s7,a0
 2c8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 2ca:	892a                	mv	s2,a0
 2cc:	4481                	li	s1,0
    cc = read(0, &c, 1);
 2ce:	faf40b13          	addi	s6,s0,-81
 2d2:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 2d4:	8c26                	mv	s8,s1
 2d6:	0014899b          	addiw	s3,s1,1
 2da:	84ce                	mv	s1,s3
 2dc:	0349d463          	bge	s3,s4,304 <gets+0x56>
    cc = read(0, &c, 1);
 2e0:	8656                	mv	a2,s5
 2e2:	85da                	mv	a1,s6
 2e4:	4501                	li	a0,0
 2e6:	1bc000ef          	jal	4a2 <read>
    if (cc < 1)
 2ea:	00a05d63          	blez	a0,304 <gets+0x56>
      break;
    buf[i++] = c;
 2ee:	faf44783          	lbu	a5,-81(s0)
 2f2:	00f90023          	sb	a5,0(s2) # ffffffff80000000 <base+0xffffffff7fffdfe0>
    if (c == '\n' || c == '\r')
 2f6:	0905                	addi	s2,s2,1
 2f8:	ff678713          	addi	a4,a5,-10
 2fc:	c319                	beqz	a4,302 <gets+0x54>
 2fe:	17cd                	addi	a5,a5,-13
 300:	fbf1                	bnez	a5,2d4 <gets+0x26>
    buf[i++] = c;
 302:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 304:	9c5e                	add	s8,s8,s7
 306:	000c0023          	sb	zero,0(s8)
  return buf;
}
 30a:	855e                	mv	a0,s7
 30c:	60e6                	ld	ra,88(sp)
 30e:	6446                	ld	s0,80(sp)
 310:	64a6                	ld	s1,72(sp)
 312:	6906                	ld	s2,64(sp)
 314:	79e2                	ld	s3,56(sp)
 316:	7a42                	ld	s4,48(sp)
 318:	7aa2                	ld	s5,40(sp)
 31a:	7b02                	ld	s6,32(sp)
 31c:	6be2                	ld	s7,24(sp)
 31e:	6c42                	ld	s8,16(sp)
 320:	6125                	addi	sp,sp,96
 322:	8082                	ret

0000000000000324 <stat>:

int
stat(const char *n, struct stat *st)
{
 324:	1101                	addi	sp,sp,-32
 326:	ec06                	sd	ra,24(sp)
 328:	e822                	sd	s0,16(sp)
 32a:	e04a                	sd	s2,0(sp)
 32c:	1000                	addi	s0,sp,32
 32e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 330:	4581                	li	a1,0
 332:	198000ef          	jal	4ca <open>
  if (fd < 0)
 336:	02054263          	bltz	a0,35a <stat+0x36>
 33a:	e426                	sd	s1,8(sp)
 33c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 33e:	85ca                	mv	a1,s2
 340:	1a2000ef          	jal	4e2 <fstat>
 344:	892a                	mv	s2,a0
  close(fd);
 346:	8526                	mv	a0,s1
 348:	16a000ef          	jal	4b2 <close>
  return r;
 34c:	64a2                	ld	s1,8(sp)
}
 34e:	854a                	mv	a0,s2
 350:	60e2                	ld	ra,24(sp)
 352:	6442                	ld	s0,16(sp)
 354:	6902                	ld	s2,0(sp)
 356:	6105                	addi	sp,sp,32
 358:	8082                	ret
    return -1;
 35a:	57fd                	li	a5,-1
 35c:	893e                	mv	s2,a5
 35e:	bfc5                	j	34e <stat+0x2a>

0000000000000360 <atoi>:

int
atoi(const char *s)
{
 360:	1141                	addi	sp,sp,-16
 362:	e406                	sd	ra,8(sp)
 364:	e022                	sd	s0,0(sp)
 366:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 368:	00054683          	lbu	a3,0(a0)
 36c:	fd06879b          	addiw	a5,a3,-48
 370:	0ff7f793          	zext.b	a5,a5
 374:	4625                	li	a2,9
 376:	02f66963          	bltu	a2,a5,3a8 <atoi+0x48>
 37a:	872a                	mv	a4,a0
  n = 0;
 37c:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 37e:	0705                	addi	a4,a4,1
 380:	0025179b          	slliw	a5,a0,0x2
 384:	9fa9                	addw	a5,a5,a0
 386:	0017979b          	slliw	a5,a5,0x1
 38a:	9fb5                	addw	a5,a5,a3
 38c:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 390:	00074683          	lbu	a3,0(a4)
 394:	fd06879b          	addiw	a5,a3,-48
 398:	0ff7f793          	zext.b	a5,a5
 39c:	fef671e3          	bgeu	a2,a5,37e <atoi+0x1e>
  return n;
}
 3a0:	60a2                	ld	ra,8(sp)
 3a2:	6402                	ld	s0,0(sp)
 3a4:	0141                	addi	sp,sp,16
 3a6:	8082                	ret
  n = 0;
 3a8:	4501                	li	a0,0
 3aa:	bfdd                	j	3a0 <atoi+0x40>

00000000000003ac <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 3ac:	1141                	addi	sp,sp,-16
 3ae:	e406                	sd	ra,8(sp)
 3b0:	e022                	sd	s0,0(sp)
 3b2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3b4:	02b57563          	bgeu	a0,a1,3de <memmove+0x32>
    while (n-- > 0)
 3b8:	00c05f63          	blez	a2,3d6 <memmove+0x2a>
 3bc:	1602                	slli	a2,a2,0x20
 3be:	9201                	srli	a2,a2,0x20
 3c0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3c4:	872a                	mv	a4,a0
      *dst++ = *src++;
 3c6:	0585                	addi	a1,a1,1
 3c8:	0705                	addi	a4,a4,1
 3ca:	fff5c683          	lbu	a3,-1(a1)
 3ce:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 3d2:	fee79ae3          	bne	a5,a4,3c6 <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3d6:	60a2                	ld	ra,8(sp)
 3d8:	6402                	ld	s0,0(sp)
 3da:	0141                	addi	sp,sp,16
 3dc:	8082                	ret
    while (n-- > 0)
 3de:	fec05ce3          	blez	a2,3d6 <memmove+0x2a>
    dst += n;
 3e2:	00c50733          	add	a4,a0,a2
    src += n;
 3e6:	95b2                	add	a1,a1,a2
 3e8:	fff6079b          	addiw	a5,a2,-1
 3ec:	1782                	slli	a5,a5,0x20
 3ee:	9381                	srli	a5,a5,0x20
 3f0:	fff7c793          	not	a5,a5
 3f4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3f6:	15fd                	addi	a1,a1,-1
 3f8:	177d                	addi	a4,a4,-1
 3fa:	0005c683          	lbu	a3,0(a1)
 3fe:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 402:	fef71ae3          	bne	a4,a5,3f6 <memmove+0x4a>
 406:	bfc1                	j	3d6 <memmove+0x2a>

0000000000000408 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 408:	1141                	addi	sp,sp,-16
 40a:	e406                	sd	ra,8(sp)
 40c:	e022                	sd	s0,0(sp)
 40e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 410:	c61d                	beqz	a2,43e <memcmp+0x36>
 412:	1602                	slli	a2,a2,0x20
 414:	9201                	srli	a2,a2,0x20
 416:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 41a:	00054783          	lbu	a5,0(a0)
 41e:	0005c703          	lbu	a4,0(a1)
 422:	00e79863          	bne	a5,a4,432 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 426:	0505                	addi	a0,a0,1
    p2++;
 428:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 42a:	fed518e3          	bne	a0,a3,41a <memcmp+0x12>
  }
  return 0;
 42e:	4501                	li	a0,0
 430:	a019                	j	436 <memcmp+0x2e>
      return *p1 - *p2;
 432:	40e7853b          	subw	a0,a5,a4
}
 436:	60a2                	ld	ra,8(sp)
 438:	6402                	ld	s0,0(sp)
 43a:	0141                	addi	sp,sp,16
 43c:	8082                	ret
  return 0;
 43e:	4501                	li	a0,0
 440:	bfdd                	j	436 <memcmp+0x2e>

0000000000000442 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 442:	1141                	addi	sp,sp,-16
 444:	e406                	sd	ra,8(sp)
 446:	e022                	sd	s0,0(sp)
 448:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 44a:	f63ff0ef          	jal	3ac <memmove>
}
 44e:	60a2                	ld	ra,8(sp)
 450:	6402                	ld	s0,0(sp)
 452:	0141                	addi	sp,sp,16
 454:	8082                	ret

0000000000000456 <sbrk>:

char *
sbrk(int n)
{
 456:	1141                	addi	sp,sp,-16
 458:	e406                	sd	ra,8(sp)
 45a:	e022                	sd	s0,0(sp)
 45c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 45e:	4585                	li	a1,1
 460:	0b2000ef          	jal	512 <sys_sbrk>
}
 464:	60a2                	ld	ra,8(sp)
 466:	6402                	ld	s0,0(sp)
 468:	0141                	addi	sp,sp,16
 46a:	8082                	ret

000000000000046c <sbrklazy>:

char *
sbrklazy(int n)
{
 46c:	1141                	addi	sp,sp,-16
 46e:	e406                	sd	ra,8(sp)
 470:	e022                	sd	s0,0(sp)
 472:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 474:	4589                	li	a1,2
 476:	09c000ef          	jal	512 <sys_sbrk>
}
 47a:	60a2                	ld	ra,8(sp)
 47c:	6402                	ld	s0,0(sp)
 47e:	0141                	addi	sp,sp,16
 480:	8082                	ret

0000000000000482 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 482:	4885                	li	a7,1
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <exit>:
.global exit
exit:
 li a7, SYS_exit
 48a:	4889                	li	a7,2
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <wait>:
.global wait
wait:
 li a7, SYS_wait
 492:	488d                	li	a7,3
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 49a:	4891                	li	a7,4
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <read>:
.global read
read:
 li a7, SYS_read
 4a2:	4895                	li	a7,5
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <write>:
.global write
write:
 li a7, SYS_write
 4aa:	48c1                	li	a7,16
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <close>:
.global close
close:
 li a7, SYS_close
 4b2:	48d5                	li	a7,21
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <kill>:
.global kill
kill:
 li a7, SYS_kill
 4ba:	4899                	li	a7,6
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4c2:	489d                	li	a7,7
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <open>:
.global open
open:
 li a7, SYS_open
 4ca:	48bd                	li	a7,15
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4d2:	48c5                	li	a7,17
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4da:	48c9                	li	a7,18
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4e2:	48a1                	li	a7,8
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <link>:
.global link
link:
 li a7, SYS_link
 4ea:	48cd                	li	a7,19
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4f2:	48d1                	li	a7,20
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4fa:	48a5                	li	a7,9
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <dup>:
.global dup
dup:
 li a7, SYS_dup
 502:	48a9                	li	a7,10
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 50a:	48ad                	li	a7,11
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 512:	48b1                	li	a7,12
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <pause>:
.global pause
pause:
 li a7, SYS_pause
 51a:	48b5                	li	a7,13
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 522:	48b9                	li	a7,14
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <sync>:
.global sync
sync:
 li a7, SYS_sync
 52a:	48d9                	li	a7,22
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
 532:	48dd                	li	a7,23
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 53a:	1101                	addi	sp,sp,-32
 53c:	ec06                	sd	ra,24(sp)
 53e:	e822                	sd	s0,16(sp)
 540:	1000                	addi	s0,sp,32
 542:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 546:	4605                	li	a2,1
 548:	fef40593          	addi	a1,s0,-17
 54c:	f5fff0ef          	jal	4aa <write>
}
 550:	60e2                	ld	ra,24(sp)
 552:	6442                	ld	s0,16(sp)
 554:	6105                	addi	sp,sp,32
 556:	8082                	ret

0000000000000558 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 558:	715d                	addi	sp,sp,-80
 55a:	e486                	sd	ra,72(sp)
 55c:	e0a2                	sd	s0,64(sp)
 55e:	f84a                	sd	s2,48(sp)
 560:	f44e                	sd	s3,40(sp)
 562:	0880                	addi	s0,sp,80
 564:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 566:	c6d1                	beqz	a3,5f2 <printint+0x9a>
 568:	0805d563          	bgez	a1,5f2 <printint+0x9a>
    neg = 1;
    x = -xx;
 56c:	40b005b3          	neg	a1,a1
    neg = 1;
 570:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 572:	fb840993          	addi	s3,s0,-72
  neg = 0;
 576:	86ce                	mv	a3,s3
  i = 0;
 578:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 57a:	00001817          	auipc	a6,0x1
 57e:	95e80813          	addi	a6,a6,-1698 # ed8 <digits>
 582:	88ba                	mv	a7,a4
 584:	0017051b          	addiw	a0,a4,1
 588:	872a                	mv	a4,a0
 58a:	02c5f7b3          	remu	a5,a1,a2
 58e:	97c2                	add	a5,a5,a6
 590:	0007c783          	lbu	a5,0(a5)
 594:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 598:	87ae                	mv	a5,a1
 59a:	02c5d5b3          	divu	a1,a1,a2
 59e:	0685                	addi	a3,a3,1
 5a0:	fec7f1e3          	bgeu	a5,a2,582 <printint+0x2a>
  if (neg)
 5a4:	00030c63          	beqz	t1,5bc <printint+0x64>
    buf[i++] = '-';
 5a8:	fd050793          	addi	a5,a0,-48
 5ac:	00878533          	add	a0,a5,s0
 5b0:	02d00793          	li	a5,45
 5b4:	fef50423          	sb	a5,-24(a0)
 5b8:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 5bc:	02e05563          	blez	a4,5e6 <printint+0x8e>
 5c0:	fc26                	sd	s1,56(sp)
 5c2:	377d                	addiw	a4,a4,-1
 5c4:	00e984b3          	add	s1,s3,a4
 5c8:	19fd                	addi	s3,s3,-1
 5ca:	99ba                	add	s3,s3,a4
 5cc:	1702                	slli	a4,a4,0x20
 5ce:	9301                	srli	a4,a4,0x20
 5d0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5d4:	0004c583          	lbu	a1,0(s1)
 5d8:	854a                	mv	a0,s2
 5da:	f61ff0ef          	jal	53a <putc>
  while (--i >= 0)
 5de:	14fd                	addi	s1,s1,-1
 5e0:	ff349ae3          	bne	s1,s3,5d4 <printint+0x7c>
 5e4:	74e2                	ld	s1,56(sp)
}
 5e6:	60a6                	ld	ra,72(sp)
 5e8:	6406                	ld	s0,64(sp)
 5ea:	7942                	ld	s2,48(sp)
 5ec:	79a2                	ld	s3,40(sp)
 5ee:	6161                	addi	sp,sp,80
 5f0:	8082                	ret
  neg = 0;
 5f2:	4301                	li	t1,0
 5f4:	bfbd                	j	572 <printint+0x1a>

00000000000005f6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5f6:	711d                	addi	sp,sp,-96
 5f8:	ec86                	sd	ra,88(sp)
 5fa:	e8a2                	sd	s0,80(sp)
 5fc:	e4a6                	sd	s1,72(sp)
 5fe:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 600:	0005c483          	lbu	s1,0(a1)
 604:	22048363          	beqz	s1,82a <vprintf+0x234>
 608:	e0ca                	sd	s2,64(sp)
 60a:	fc4e                	sd	s3,56(sp)
 60c:	f852                	sd	s4,48(sp)
 60e:	f456                	sd	s5,40(sp)
 610:	f05a                	sd	s6,32(sp)
 612:	ec5e                	sd	s7,24(sp)
 614:	e862                	sd	s8,16(sp)
 616:	8b2a                	mv	s6,a0
 618:	8a2e                	mv	s4,a1
 61a:	8bb2                	mv	s7,a2
  state = 0;
 61c:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 61e:	4901                	li	s2,0
 620:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 622:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 626:	06400c13          	li	s8,100
 62a:	a00d                	j	64c <vprintf+0x56>
        putc(fd, c0);
 62c:	85a6                	mv	a1,s1
 62e:	855a                	mv	a0,s6
 630:	f0bff0ef          	jal	53a <putc>
 634:	a019                	j	63a <vprintf+0x44>
    } else if (state == '%') {
 636:	03598363          	beq	s3,s5,65c <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 63a:	0019079b          	addiw	a5,s2,1
 63e:	893e                	mv	s2,a5
 640:	873e                	mv	a4,a5
 642:	97d2                	add	a5,a5,s4
 644:	0007c483          	lbu	s1,0(a5)
 648:	1c048a63          	beqz	s1,81c <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 64c:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 650:	fe0993e3          	bnez	s3,636 <vprintf+0x40>
      if (c0 == '%') {
 654:	fd579ce3          	bne	a5,s5,62c <vprintf+0x36>
        state = '%';
 658:	89be                	mv	s3,a5
 65a:	b7c5                	j	63a <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 65c:	00ea06b3          	add	a3,s4,a4
 660:	0016c603          	lbu	a2,1(a3)
      if (c1)
 664:	1c060863          	beqz	a2,834 <vprintf+0x23e>
      if (c0 == 'd') {
 668:	03878763          	beq	a5,s8,696 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 66c:	f9478693          	addi	a3,a5,-108
 670:	0016b693          	seqz	a3,a3
 674:	f9c60593          	addi	a1,a2,-100
 678:	e99d                	bnez	a1,6ae <vprintf+0xb8>
 67a:	ca95                	beqz	a3,6ae <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 67c:	008b8493          	addi	s1,s7,8
 680:	4685                	li	a3,1
 682:	4629                	li	a2,10
 684:	000bb583          	ld	a1,0(s7)
 688:	855a                	mv	a0,s6
 68a:	ecfff0ef          	jal	558 <printint>
        i += 1;
 68e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 690:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 692:	4981                	li	s3,0
 694:	b75d                	j	63a <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 696:	008b8493          	addi	s1,s7,8
 69a:	4685                	li	a3,1
 69c:	4629                	li	a2,10
 69e:	000ba583          	lw	a1,0(s7)
 6a2:	855a                	mv	a0,s6
 6a4:	eb5ff0ef          	jal	558 <printint>
 6a8:	8ba6                	mv	s7,s1
      state = 0;
 6aa:	4981                	li	s3,0
 6ac:	b779                	j	63a <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 6ae:	9752                	add	a4,a4,s4
 6b0:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 6b4:	f9460713          	addi	a4,a2,-108
 6b8:	00173713          	seqz	a4,a4
 6bc:	8f75                	and	a4,a4,a3
 6be:	f9c58513          	addi	a0,a1,-100
 6c2:	18051363          	bnez	a0,848 <vprintf+0x252>
 6c6:	18070163          	beqz	a4,848 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ca:	008b8493          	addi	s1,s7,8
 6ce:	4685                	li	a3,1
 6d0:	4629                	li	a2,10
 6d2:	000bb583          	ld	a1,0(s7)
 6d6:	855a                	mv	a0,s6
 6d8:	e81ff0ef          	jal	558 <printint>
        i += 2;
 6dc:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6de:	8ba6                	mv	s7,s1
      state = 0;
 6e0:	4981                	li	s3,0
        i += 2;
 6e2:	bfa1                	j	63a <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6e4:	008b8493          	addi	s1,s7,8
 6e8:	4681                	li	a3,0
 6ea:	4629                	li	a2,10
 6ec:	000be583          	lwu	a1,0(s7)
 6f0:	855a                	mv	a0,s6
 6f2:	e67ff0ef          	jal	558 <printint>
 6f6:	8ba6                	mv	s7,s1
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	b781                	j	63a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6fc:	008b8493          	addi	s1,s7,8
 700:	4681                	li	a3,0
 702:	4629                	li	a2,10
 704:	000bb583          	ld	a1,0(s7)
 708:	855a                	mv	a0,s6
 70a:	e4fff0ef          	jal	558 <printint>
        i += 1;
 70e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 710:	8ba6                	mv	s7,s1
      state = 0;
 712:	4981                	li	s3,0
 714:	b71d                	j	63a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 716:	008b8493          	addi	s1,s7,8
 71a:	4681                	li	a3,0
 71c:	4629                	li	a2,10
 71e:	000bb583          	ld	a1,0(s7)
 722:	855a                	mv	a0,s6
 724:	e35ff0ef          	jal	558 <printint>
        i += 2;
 728:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 72a:	8ba6                	mv	s7,s1
      state = 0;
 72c:	4981                	li	s3,0
        i += 2;
 72e:	b731                	j	63a <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 730:	008b8493          	addi	s1,s7,8
 734:	4681                	li	a3,0
 736:	4641                	li	a2,16
 738:	000be583          	lwu	a1,0(s7)
 73c:	855a                	mv	a0,s6
 73e:	e1bff0ef          	jal	558 <printint>
 742:	8ba6                	mv	s7,s1
      state = 0;
 744:	4981                	li	s3,0
 746:	bdd5                	j	63a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 748:	008b8493          	addi	s1,s7,8
 74c:	4681                	li	a3,0
 74e:	4641                	li	a2,16
 750:	000bb583          	ld	a1,0(s7)
 754:	855a                	mv	a0,s6
 756:	e03ff0ef          	jal	558 <printint>
        i += 1;
 75a:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 75c:	8ba6                	mv	s7,s1
      state = 0;
 75e:	4981                	li	s3,0
 760:	bde9                	j	63a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 762:	008b8493          	addi	s1,s7,8
 766:	4681                	li	a3,0
 768:	4641                	li	a2,16
 76a:	000bb583          	ld	a1,0(s7)
 76e:	855a                	mv	a0,s6
 770:	de9ff0ef          	jal	558 <printint>
        i += 2;
 774:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 776:	8ba6                	mv	s7,s1
      state = 0;
 778:	4981                	li	s3,0
        i += 2;
 77a:	b5c1                	j	63a <vprintf+0x44>
 77c:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 77e:	008b8793          	addi	a5,s7,8
 782:	8cbe                	mv	s9,a5
 784:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 788:	03000593          	li	a1,48
 78c:	855a                	mv	a0,s6
 78e:	dadff0ef          	jal	53a <putc>
  putc(fd, 'x');
 792:	07800593          	li	a1,120
 796:	855a                	mv	a0,s6
 798:	da3ff0ef          	jal	53a <putc>
 79c:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 79e:	00000b97          	auipc	s7,0x0
 7a2:	73ab8b93          	addi	s7,s7,1850 # ed8 <digits>
 7a6:	03c9d793          	srli	a5,s3,0x3c
 7aa:	97de                	add	a5,a5,s7
 7ac:	0007c583          	lbu	a1,0(a5)
 7b0:	855a                	mv	a0,s6
 7b2:	d89ff0ef          	jal	53a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7b6:	0992                	slli	s3,s3,0x4
 7b8:	34fd                	addiw	s1,s1,-1
 7ba:	f4f5                	bnez	s1,7a6 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 7bc:	8be6                	mv	s7,s9
      state = 0;
 7be:	4981                	li	s3,0
 7c0:	6ca2                	ld	s9,8(sp)
 7c2:	bda5                	j	63a <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 7c4:	008b8493          	addi	s1,s7,8
 7c8:	000bc583          	lbu	a1,0(s7)
 7cc:	855a                	mv	a0,s6
 7ce:	d6dff0ef          	jal	53a <putc>
 7d2:	8ba6                	mv	s7,s1
      state = 0;
 7d4:	4981                	li	s3,0
 7d6:	b595                	j	63a <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 7d8:	008b8993          	addi	s3,s7,8
 7dc:	000bb483          	ld	s1,0(s7)
 7e0:	cc91                	beqz	s1,7fc <vprintf+0x206>
        for (; *s; s++)
 7e2:	0004c583          	lbu	a1,0(s1)
 7e6:	c985                	beqz	a1,816 <vprintf+0x220>
          putc(fd, *s);
 7e8:	855a                	mv	a0,s6
 7ea:	d51ff0ef          	jal	53a <putc>
        for (; *s; s++)
 7ee:	0485                	addi	s1,s1,1
 7f0:	0004c583          	lbu	a1,0(s1)
 7f4:	f9f5                	bnez	a1,7e8 <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 7f6:	8bce                	mv	s7,s3
      state = 0;
 7f8:	4981                	li	s3,0
 7fa:	b581                	j	63a <vprintf+0x44>
          s = "(null)";
 7fc:	00000497          	auipc	s1,0x0
 800:	6d448493          	addi	s1,s1,1748 # ed0 <malloc+0x538>
        for (; *s; s++)
 804:	02800593          	li	a1,40
 808:	b7c5                	j	7e8 <vprintf+0x1f2>
        putc(fd, '%');
 80a:	85be                	mv	a1,a5
 80c:	855a                	mv	a0,s6
 80e:	d2dff0ef          	jal	53a <putc>
      state = 0;
 812:	4981                	li	s3,0
 814:	b51d                	j	63a <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 816:	8bce                	mv	s7,s3
      state = 0;
 818:	4981                	li	s3,0
 81a:	b505                	j	63a <vprintf+0x44>
 81c:	6906                	ld	s2,64(sp)
 81e:	79e2                	ld	s3,56(sp)
 820:	7a42                	ld	s4,48(sp)
 822:	7aa2                	ld	s5,40(sp)
 824:	7b02                	ld	s6,32(sp)
 826:	6be2                	ld	s7,24(sp)
 828:	6c42                	ld	s8,16(sp)
    }
  }
}
 82a:	60e6                	ld	ra,88(sp)
 82c:	6446                	ld	s0,80(sp)
 82e:	64a6                	ld	s1,72(sp)
 830:	6125                	addi	sp,sp,96
 832:	8082                	ret
      if (c0 == 'd') {
 834:	06400713          	li	a4,100
 838:	e4e78fe3          	beq	a5,a4,696 <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 83c:	f9478693          	addi	a3,a5,-108
 840:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 844:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 846:	4701                	li	a4,0
      } else if (c0 == 'u') {
 848:	07500513          	li	a0,117
 84c:	e8a78ce3          	beq	a5,a0,6e4 <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 850:	f8b60513          	addi	a0,a2,-117
 854:	e119                	bnez	a0,85a <vprintf+0x264>
 856:	ea0693e3          	bnez	a3,6fc <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 85a:	f8b58513          	addi	a0,a1,-117
 85e:	e119                	bnez	a0,864 <vprintf+0x26e>
 860:	ea071be3          	bnez	a4,716 <vprintf+0x120>
      } else if (c0 == 'x') {
 864:	07800513          	li	a0,120
 868:	eca784e3          	beq	a5,a0,730 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 86c:	f8860613          	addi	a2,a2,-120
 870:	e219                	bnez	a2,876 <vprintf+0x280>
 872:	ec069be3          	bnez	a3,748 <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 876:	f8858593          	addi	a1,a1,-120
 87a:	e199                	bnez	a1,880 <vprintf+0x28a>
 87c:	ee0713e3          	bnez	a4,762 <vprintf+0x16c>
      } else if (c0 == 'p') {
 880:	07000713          	li	a4,112
 884:	eee78ce3          	beq	a5,a4,77c <vprintf+0x186>
      } else if (c0 == 'c') {
 888:	06300713          	li	a4,99
 88c:	f2e78ce3          	beq	a5,a4,7c4 <vprintf+0x1ce>
      } else if (c0 == 's') {
 890:	07300713          	li	a4,115
 894:	f4e782e3          	beq	a5,a4,7d8 <vprintf+0x1e2>
      } else if (c0 == '%') {
 898:	02500713          	li	a4,37
 89c:	f6e787e3          	beq	a5,a4,80a <vprintf+0x214>
        putc(fd, '%');
 8a0:	02500593          	li	a1,37
 8a4:	855a                	mv	a0,s6
 8a6:	c95ff0ef          	jal	53a <putc>
        putc(fd, c0);
 8aa:	85a6                	mv	a1,s1
 8ac:	855a                	mv	a0,s6
 8ae:	c8dff0ef          	jal	53a <putc>
      state = 0;
 8b2:	4981                	li	s3,0
 8b4:	b359                	j	63a <vprintf+0x44>

00000000000008b6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8b6:	715d                	addi	sp,sp,-80
 8b8:	ec06                	sd	ra,24(sp)
 8ba:	e822                	sd	s0,16(sp)
 8bc:	1000                	addi	s0,sp,32
 8be:	e010                	sd	a2,0(s0)
 8c0:	e414                	sd	a3,8(s0)
 8c2:	e818                	sd	a4,16(s0)
 8c4:	ec1c                	sd	a5,24(s0)
 8c6:	03043023          	sd	a6,32(s0)
 8ca:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8ce:	8622                	mv	a2,s0
 8d0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8d4:	d23ff0ef          	jal	5f6 <vprintf>
}
 8d8:	60e2                	ld	ra,24(sp)
 8da:	6442                	ld	s0,16(sp)
 8dc:	6161                	addi	sp,sp,80
 8de:	8082                	ret

00000000000008e0 <printf>:

void
printf(const char *fmt, ...)
{
 8e0:	711d                	addi	sp,sp,-96
 8e2:	ec06                	sd	ra,24(sp)
 8e4:	e822                	sd	s0,16(sp)
 8e6:	1000                	addi	s0,sp,32
 8e8:	e40c                	sd	a1,8(s0)
 8ea:	e810                	sd	a2,16(s0)
 8ec:	ec14                	sd	a3,24(s0)
 8ee:	f018                	sd	a4,32(s0)
 8f0:	f41c                	sd	a5,40(s0)
 8f2:	03043823          	sd	a6,48(s0)
 8f6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8fa:	00840613          	addi	a2,s0,8
 8fe:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 902:	85aa                	mv	a1,a0
 904:	4505                	li	a0,1
 906:	cf1ff0ef          	jal	5f6 <vprintf>
}
 90a:	60e2                	ld	ra,24(sp)
 90c:	6442                	ld	s0,16(sp)
 90e:	6125                	addi	sp,sp,96
 910:	8082                	ret

0000000000000912 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 912:	1141                	addi	sp,sp,-16
 914:	e406                	sd	ra,8(sp)
 916:	e022                	sd	s0,0(sp)
 918:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 91a:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 91e:	00001797          	auipc	a5,0x1
 922:	6f27b783          	ld	a5,1778(a5) # 2010 <freep>
 926:	a039                	j	934 <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 928:	6398                	ld	a4,0(a5)
 92a:	00e7e463          	bltu	a5,a4,932 <free+0x20>
 92e:	00e6ea63          	bltu	a3,a4,942 <free+0x30>
{
 932:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 934:	fed7fae3          	bgeu	a5,a3,928 <free+0x16>
 938:	6398                	ld	a4,0(a5)
 93a:	00e6e463          	bltu	a3,a4,942 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 93e:	fee7eae3          	bltu	a5,a4,932 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 942:	ff852583          	lw	a1,-8(a0)
 946:	6390                	ld	a2,0(a5)
 948:	02059813          	slli	a6,a1,0x20
 94c:	01c85713          	srli	a4,a6,0x1c
 950:	9736                	add	a4,a4,a3
 952:	02e60563          	beq	a2,a4,97c <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 956:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 95a:	4790                	lw	a2,8(a5)
 95c:	02061593          	slli	a1,a2,0x20
 960:	01c5d713          	srli	a4,a1,0x1c
 964:	973e                	add	a4,a4,a5
 966:	02e68263          	beq	a3,a4,98a <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 96a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 96c:	00001717          	auipc	a4,0x1
 970:	6af73223          	sd	a5,1700(a4) # 2010 <freep>
}
 974:	60a2                	ld	ra,8(sp)
 976:	6402                	ld	s0,0(sp)
 978:	0141                	addi	sp,sp,16
 97a:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 97c:	4618                	lw	a4,8(a2)
 97e:	9f2d                	addw	a4,a4,a1
 980:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 984:	6398                	ld	a4,0(a5)
 986:	6310                	ld	a2,0(a4)
 988:	b7f9                	j	956 <free+0x44>
    p->s.size += bp->s.size;
 98a:	ff852703          	lw	a4,-8(a0)
 98e:	9f31                	addw	a4,a4,a2
 990:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 992:	ff053683          	ld	a3,-16(a0)
 996:	bfd1                	j	96a <free+0x58>

0000000000000998 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 998:	7139                	addi	sp,sp,-64
 99a:	fc06                	sd	ra,56(sp)
 99c:	f822                	sd	s0,48(sp)
 99e:	f04a                	sd	s2,32(sp)
 9a0:	ec4e                	sd	s3,24(sp)
 9a2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 9a4:	02051993          	slli	s3,a0,0x20
 9a8:	0209d993          	srli	s3,s3,0x20
 9ac:	09bd                	addi	s3,s3,15
 9ae:	0049d993          	srli	s3,s3,0x4
 9b2:	2985                	addiw	s3,s3,1
 9b4:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 9b6:	00001517          	auipc	a0,0x1
 9ba:	65a53503          	ld	a0,1626(a0) # 2010 <freep>
 9be:	c905                	beqz	a0,9ee <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 9c0:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 9c2:	4798                	lw	a4,8(a5)
 9c4:	09377663          	bgeu	a4,s3,a50 <malloc+0xb8>
 9c8:	f426                	sd	s1,40(sp)
 9ca:	e852                	sd	s4,16(sp)
 9cc:	e456                	sd	s5,8(sp)
 9ce:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 9d0:	8a4e                	mv	s4,s3
 9d2:	6705                	lui	a4,0x1
 9d4:	00e9f363          	bgeu	s3,a4,9da <malloc+0x42>
 9d8:	6a05                	lui	s4,0x1
 9da:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9de:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 9e2:	00001497          	auipc	s1,0x1
 9e6:	62e48493          	addi	s1,s1,1582 # 2010 <freep>
  if (p == SBRK_ERROR)
 9ea:	5afd                	li	s5,-1
 9ec:	a83d                	j	a2a <malloc+0x92>
 9ee:	f426                	sd	s1,40(sp)
 9f0:	e852                	sd	s4,16(sp)
 9f2:	e456                	sd	s5,8(sp)
 9f4:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9f6:	00001797          	auipc	a5,0x1
 9fa:	62a78793          	addi	a5,a5,1578 # 2020 <base>
 9fe:	00001717          	auipc	a4,0x1
 a02:	60f73923          	sd	a5,1554(a4) # 2010 <freep>
 a06:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a08:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 a0c:	b7d1                	j	9d0 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 a0e:	6398                	ld	a4,0(a5)
 a10:	e118                	sd	a4,0(a0)
 a12:	a899                	j	a68 <malloc+0xd0>
  hp->s.size = nu;
 a14:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 a18:	0541                	addi	a0,a0,16
 a1a:	ef9ff0ef          	jal	912 <free>
  return freep;
 a1e:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 a20:	c125                	beqz	a0,a80 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 a22:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 a24:	4798                	lw	a4,8(a5)
 a26:	03277163          	bgeu	a4,s2,a48 <malloc+0xb0>
    if (p == freep)
 a2a:	6098                	ld	a4,0(s1)
 a2c:	853e                	mv	a0,a5
 a2e:	fef71ae3          	bne	a4,a5,a22 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 a32:	8552                	mv	a0,s4
 a34:	a23ff0ef          	jal	456 <sbrk>
  if (p == SBRK_ERROR)
 a38:	fd551ee3          	bne	a0,s5,a14 <malloc+0x7c>
        return 0;
 a3c:	4501                	li	a0,0
 a3e:	74a2                	ld	s1,40(sp)
 a40:	6a42                	ld	s4,16(sp)
 a42:	6aa2                	ld	s5,8(sp)
 a44:	6b02                	ld	s6,0(sp)
 a46:	a03d                	j	a74 <malloc+0xdc>
 a48:	74a2                	ld	s1,40(sp)
 a4a:	6a42                	ld	s4,16(sp)
 a4c:	6aa2                	ld	s5,8(sp)
 a4e:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 a50:	fae90fe3          	beq	s2,a4,a0e <malloc+0x76>
        p->s.size -= nunits;
 a54:	4137073b          	subw	a4,a4,s3
 a58:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a5a:	02071693          	slli	a3,a4,0x20
 a5e:	01c6d713          	srli	a4,a3,0x1c
 a62:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a64:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a68:	00001717          	auipc	a4,0x1
 a6c:	5aa73423          	sd	a0,1448(a4) # 2010 <freep>
      return (void *)(p + 1);
 a70:	01078513          	addi	a0,a5,16
  }
}
 a74:	70e2                	ld	ra,56(sp)
 a76:	7442                	ld	s0,48(sp)
 a78:	7902                	ld	s2,32(sp)
 a7a:	69e2                	ld	s3,24(sp)
 a7c:	6121                	addi	sp,sp,64
 a7e:	8082                	ret
 a80:	74a2                	ld	s1,40(sp)
 a82:	6a42                	ld	s4,16(sp)
 a84:	6aa2                	ld	s5,8(sp)
 a86:	6b02                	ld	s6,0(sp)
 a88:	b7f5                	j	a74 <malloc+0xdc>
