
user/_memtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"

#define ALLOC_PAGES 10
#define ALLOC_SIZE (ALLOC_PAGES * 4096)

int main(int argc, char *argv[]) {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  printf("============================================================\n");
   8:	00001517          	auipc	a0,0x1
   c:	9f850513          	addi	a0,a0,-1544 # a00 <malloc+0xf6>
  10:	043000ef          	jal	852 <printf>
  printf("  Physical Memory Allocation Tracking Test (memtest)        \n");
  14:	00001517          	auipc	a0,0x1
  18:	a3450513          	addi	a0,a0,-1484 # a48 <malloc+0x13e>
  1c:	037000ef          	jal	852 <printf>
  printf("============================================================\n\n");
  20:	00001517          	auipc	a0,0x1
  24:	a6850513          	addi	a0,a0,-1432 # a88 <malloc+0x17e>
  28:	02b000ef          	jal	852 <printf>

  printf("--- Step 1: Baseline Memory Statistics ---\n");
  2c:	00001517          	auipc	a0,0x1
  30:	a9c50513          	addi	a0,a0,-1380 # ac8 <malloc+0x1be>
  34:	01f000ef          	jal	852 <printf>
  memstats();
  38:	46c000ef          	jal	4a4 <memstats>

  printf("\n--- Step 2: Allocating %d Pages (%d KB) using sbrk() ---\n",
  3c:	02800613          	li	a2,40
  40:	45a9                	li	a1,10
  42:	00001517          	auipc	a0,0x1
  46:	ab650513          	addi	a0,a0,-1354 # af8 <malloc+0x1ee>
  4a:	009000ef          	jal	852 <printf>
         ALLOC_PAGES, ALLOC_SIZE / 1024);
  char *ptr = sbrk(ALLOC_SIZE);
  4e:	6529                	lui	a0,0xa
  50:	378000ef          	jal	3c8 <sbrk>
  if (ptr == (char *)-1) {
  54:	57fd                	li	a5,-1
  56:	0cf50663          	beq	a0,a5,122 <main+0x122>
  5a:	85aa                	mv	a1,a0
  5c:	87aa                	mv	a5,a0
  5e:	6729                	lui	a4,0xa
  60:	972a                	add	a4,a4,a0
    printf("sbrk allocation failed!\n");
    exit(1);
  }
  // Write to each allocated page so physical frames are accessed
  for (int i = 0; i < ALLOC_SIZE; i += 4096) {
    ptr[i] = 'M';
  62:	04d00613          	li	a2,77
  for (int i = 0; i < ALLOC_SIZE; i += 4096) {
  66:	6685                	lui	a3,0x1
    ptr[i] = 'M';
  68:	00c78023          	sb	a2,0(a5)
  for (int i = 0; i < ALLOC_SIZE; i += 4096) {
  6c:	97b6                	add	a5,a5,a3
  6e:	fee79de3          	bne	a5,a4,68 <main+0x68>
  }

  printf("Memory allocated at virtual address: %p\n", ptr);
  72:	00001517          	auipc	a0,0x1
  76:	ae650513          	addi	a0,a0,-1306 # b58 <malloc+0x24e>
  7a:	7d8000ef          	jal	852 <printf>
  printf("Updated statistics after allocation:\n");
  7e:	00001517          	auipc	a0,0x1
  82:	b0a50513          	addi	a0,a0,-1270 # b88 <malloc+0x27e>
  86:	7cc000ef          	jal	852 <printf>
  memstats();
  8a:	41a000ef          	jal	4a4 <memstats>

  printf("\n--- Step 3: Deallocating %d Pages using sbrk(-%d) ---\n",
  8e:	6629                	lui	a2,0xa
  90:	45a9                	li	a1,10
  92:	00001517          	auipc	a0,0x1
  96:	b1e50513          	addi	a0,a0,-1250 # bb0 <malloc+0x2a6>
  9a:	7b8000ef          	jal	852 <printf>
         ALLOC_PAGES, ALLOC_SIZE);
  if (sbrk(-ALLOC_SIZE) == (char *)-1) {
  9e:	7559                	lui	a0,0xffff6
  a0:	328000ef          	jal	3c8 <sbrk>
  a4:	57fd                	li	a5,-1
  a6:	08f50763          	beq	a0,a5,134 <main+0x134>
    printf("sbrk deallocation failed!\n");
    exit(1);
  }

  printf("Updated statistics after deallocation:\n");
  aa:	00001517          	auipc	a0,0x1
  ae:	b5e50513          	addi	a0,a0,-1186 # c08 <malloc+0x2fe>
  b2:	7a0000ef          	jal	852 <printf>
  memstats();
  b6:	3ee000ef          	jal	4a4 <memstats>

  printf("\n============================================================\n");
  ba:	00001517          	auipc	a0,0x1
  be:	b7650513          	addi	a0,a0,-1162 # c30 <malloc+0x326>
  c2:	790000ef          	jal	852 <printf>
  printf("memtest completed successfully!\n");
  c6:	00001517          	auipc	a0,0x1
  ca:	baa50513          	addi	a0,a0,-1110 # c70 <malloc+0x366>
  ce:	784000ef          	jal	852 <printf>
  printf("Observations:\n");
  d2:	00001517          	auipc	a0,0x1
  d6:	bc650513          	addi	a0,a0,-1082 # c98 <malloc+0x38e>
  da:	778000ef          	jal	852 <printf>
  printf("  1. Allocating %d pages increased total & currently allocated counters\n", ALLOC_PAGES);
  de:	45a9                	li	a1,10
  e0:	00001517          	auipc	a0,0x1
  e4:	bc850513          	addi	a0,a0,-1080 # ca8 <malloc+0x39e>
  e8:	76a000ef          	jal	852 <printf>
  printf("     and decreased available physical memory.\n");
  ec:	00001517          	auipc	a0,0x1
  f0:	c0c50513          	addi	a0,a0,-1012 # cf8 <malloc+0x3ee>
  f4:	75e000ef          	jal	852 <printf>
  printf("  2. Releasing the memory increased total freed pages and restored\n");
  f8:	00001517          	auipc	a0,0x1
  fc:	c3050513          	addi	a0,a0,-976 # d28 <malloc+0x41e>
 100:	752000ef          	jal	852 <printf>
  printf("     the available physical pages.\n");
 104:	00001517          	auipc	a0,0x1
 108:	c6c50513          	addi	a0,a0,-916 # d70 <malloc+0x466>
 10c:	746000ef          	jal	852 <printf>
  printf("============================================================\n");
 110:	00001517          	auipc	a0,0x1
 114:	8f050513          	addi	a0,a0,-1808 # a00 <malloc+0xf6>
 118:	73a000ef          	jal	852 <printf>
  exit(0);
 11c:	4501                	li	a0,0
 11e:	2de000ef          	jal	3fc <exit>
    printf("sbrk allocation failed!\n");
 122:	00001517          	auipc	a0,0x1
 126:	a1650513          	addi	a0,a0,-1514 # b38 <malloc+0x22e>
 12a:	728000ef          	jal	852 <printf>
    exit(1);
 12e:	4505                	li	a0,1
 130:	2cc000ef          	jal	3fc <exit>
    printf("sbrk deallocation failed!\n");
 134:	00001517          	auipc	a0,0x1
 138:	ab450513          	addi	a0,a0,-1356 # be8 <malloc+0x2de>
 13c:	716000ef          	jal	852 <printf>
    exit(1);
 140:	4505                	li	a0,1
 142:	2ba000ef          	jal	3fc <exit>

0000000000000146 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 146:	1141                	addi	sp,sp,-16
 148:	e406                	sd	ra,8(sp)
 14a:	e022                	sd	s0,0(sp)
 14c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 14e:	eb3ff0ef          	jal	0 <main>
  exit(r);
 152:	2aa000ef          	jal	3fc <exit>

0000000000000156 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 156:	1141                	addi	sp,sp,-16
 158:	e406                	sd	ra,8(sp)
 15a:	e022                	sd	s0,0(sp)
 15c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 15e:	87aa                	mv	a5,a0
 160:	0585                	addi	a1,a1,1
 162:	0785                	addi	a5,a5,1
 164:	fff5c703          	lbu	a4,-1(a1)
 168:	fee78fa3          	sb	a4,-1(a5)
 16c:	fb75                	bnez	a4,160 <strcpy+0xa>
    ;
  return os;
}
 16e:	60a2                	ld	ra,8(sp)
 170:	6402                	ld	s0,0(sp)
 172:	0141                	addi	sp,sp,16
 174:	8082                	ret

0000000000000176 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 176:	1141                	addi	sp,sp,-16
 178:	e406                	sd	ra,8(sp)
 17a:	e022                	sd	s0,0(sp)
 17c:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 17e:	00054783          	lbu	a5,0(a0)
 182:	cb91                	beqz	a5,196 <strcmp+0x20>
 184:	0005c703          	lbu	a4,0(a1)
 188:	00f71763          	bne	a4,a5,196 <strcmp+0x20>
    p++, q++;
 18c:	0505                	addi	a0,a0,1
 18e:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 190:	00054783          	lbu	a5,0(a0)
 194:	fbe5                	bnez	a5,184 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 196:	0005c503          	lbu	a0,0(a1)
}
 19a:	40a7853b          	subw	a0,a5,a0
 19e:	60a2                	ld	ra,8(sp)
 1a0:	6402                	ld	s0,0(sp)
 1a2:	0141                	addi	sp,sp,16
 1a4:	8082                	ret

00000000000001a6 <strlen>:

uint
strlen(const char *s)
{
 1a6:	1141                	addi	sp,sp,-16
 1a8:	e406                	sd	ra,8(sp)
 1aa:	e022                	sd	s0,0(sp)
 1ac:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 1ae:	00054783          	lbu	a5,0(a0)
 1b2:	cf91                	beqz	a5,1ce <strlen+0x28>
 1b4:	00150793          	addi	a5,a0,1
 1b8:	86be                	mv	a3,a5
 1ba:	0785                	addi	a5,a5,1
 1bc:	fff7c703          	lbu	a4,-1(a5)
 1c0:	ff65                	bnez	a4,1b8 <strlen+0x12>
 1c2:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 1c6:	60a2                	ld	ra,8(sp)
 1c8:	6402                	ld	s0,0(sp)
 1ca:	0141                	addi	sp,sp,16
 1cc:	8082                	ret
  for (n = 0; s[n]; n++)
 1ce:	4501                	li	a0,0
 1d0:	bfdd                	j	1c6 <strlen+0x20>

00000000000001d2 <memset>:

void *
memset(void *dst, int c, uint n)
{
 1d2:	1141                	addi	sp,sp,-16
 1d4:	e406                	sd	ra,8(sp)
 1d6:	e022                	sd	s0,0(sp)
 1d8:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 1da:	ca19                	beqz	a2,1f0 <memset+0x1e>
 1dc:	87aa                	mv	a5,a0
 1de:	1602                	slli	a2,a2,0x20
 1e0:	9201                	srli	a2,a2,0x20
 1e2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1e6:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 1ea:	0785                	addi	a5,a5,1
 1ec:	fee79de3          	bne	a5,a4,1e6 <memset+0x14>
  }
  return dst;
}
 1f0:	60a2                	ld	ra,8(sp)
 1f2:	6402                	ld	s0,0(sp)
 1f4:	0141                	addi	sp,sp,16
 1f6:	8082                	ret

00000000000001f8 <strchr>:

char *
strchr(const char *s, char c)
{
 1f8:	1141                	addi	sp,sp,-16
 1fa:	e406                	sd	ra,8(sp)
 1fc:	e022                	sd	s0,0(sp)
 1fe:	0800                	addi	s0,sp,16
  for (; *s; s++)
 200:	00054783          	lbu	a5,0(a0)
 204:	cf81                	beqz	a5,21c <strchr+0x24>
    if (*s == c)
 206:	00f58763          	beq	a1,a5,214 <strchr+0x1c>
  for (; *s; s++)
 20a:	0505                	addi	a0,a0,1
 20c:	00054783          	lbu	a5,0(a0)
 210:	fbfd                	bnez	a5,206 <strchr+0xe>
      return (char *)s;
  return 0;
 212:	4501                	li	a0,0
}
 214:	60a2                	ld	ra,8(sp)
 216:	6402                	ld	s0,0(sp)
 218:	0141                	addi	sp,sp,16
 21a:	8082                	ret
  return 0;
 21c:	4501                	li	a0,0
 21e:	bfdd                	j	214 <strchr+0x1c>

0000000000000220 <gets>:

char *
gets(char *buf, int max)
{
 220:	711d                	addi	sp,sp,-96
 222:	ec86                	sd	ra,88(sp)
 224:	e8a2                	sd	s0,80(sp)
 226:	e4a6                	sd	s1,72(sp)
 228:	e0ca                	sd	s2,64(sp)
 22a:	fc4e                	sd	s3,56(sp)
 22c:	f852                	sd	s4,48(sp)
 22e:	f456                	sd	s5,40(sp)
 230:	f05a                	sd	s6,32(sp)
 232:	ec5e                	sd	s7,24(sp)
 234:	e862                	sd	s8,16(sp)
 236:	1080                	addi	s0,sp,96
 238:	8baa                	mv	s7,a0
 23a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 23c:	892a                	mv	s2,a0
 23e:	4481                	li	s1,0
    cc = read(0, &c, 1);
 240:	faf40b13          	addi	s6,s0,-81
 244:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 246:	8c26                	mv	s8,s1
 248:	0014899b          	addiw	s3,s1,1
 24c:	84ce                	mv	s1,s3
 24e:	0349d463          	bge	s3,s4,276 <gets+0x56>
    cc = read(0, &c, 1);
 252:	8656                	mv	a2,s5
 254:	85da                	mv	a1,s6
 256:	4501                	li	a0,0
 258:	1bc000ef          	jal	414 <read>
    if (cc < 1)
 25c:	00a05d63          	blez	a0,276 <gets+0x56>
      break;
    buf[i++] = c;
 260:	faf44783          	lbu	a5,-81(s0)
 264:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 268:	0905                	addi	s2,s2,1
 26a:	ff678713          	addi	a4,a5,-10
 26e:	c319                	beqz	a4,274 <gets+0x54>
 270:	17cd                	addi	a5,a5,-13
 272:	fbf1                	bnez	a5,246 <gets+0x26>
    buf[i++] = c;
 274:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 276:	9c5e                	add	s8,s8,s7
 278:	000c0023          	sb	zero,0(s8)
  return buf;
}
 27c:	855e                	mv	a0,s7
 27e:	60e6                	ld	ra,88(sp)
 280:	6446                	ld	s0,80(sp)
 282:	64a6                	ld	s1,72(sp)
 284:	6906                	ld	s2,64(sp)
 286:	79e2                	ld	s3,56(sp)
 288:	7a42                	ld	s4,48(sp)
 28a:	7aa2                	ld	s5,40(sp)
 28c:	7b02                	ld	s6,32(sp)
 28e:	6be2                	ld	s7,24(sp)
 290:	6c42                	ld	s8,16(sp)
 292:	6125                	addi	sp,sp,96
 294:	8082                	ret

0000000000000296 <stat>:

int
stat(const char *n, struct stat *st)
{
 296:	1101                	addi	sp,sp,-32
 298:	ec06                	sd	ra,24(sp)
 29a:	e822                	sd	s0,16(sp)
 29c:	e04a                	sd	s2,0(sp)
 29e:	1000                	addi	s0,sp,32
 2a0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2a2:	4581                	li	a1,0
 2a4:	198000ef          	jal	43c <open>
  if (fd < 0)
 2a8:	02054263          	bltz	a0,2cc <stat+0x36>
 2ac:	e426                	sd	s1,8(sp)
 2ae:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2b0:	85ca                	mv	a1,s2
 2b2:	1a2000ef          	jal	454 <fstat>
 2b6:	892a                	mv	s2,a0
  close(fd);
 2b8:	8526                	mv	a0,s1
 2ba:	16a000ef          	jal	424 <close>
  return r;
 2be:	64a2                	ld	s1,8(sp)
}
 2c0:	854a                	mv	a0,s2
 2c2:	60e2                	ld	ra,24(sp)
 2c4:	6442                	ld	s0,16(sp)
 2c6:	6902                	ld	s2,0(sp)
 2c8:	6105                	addi	sp,sp,32
 2ca:	8082                	ret
    return -1;
 2cc:	57fd                	li	a5,-1
 2ce:	893e                	mv	s2,a5
 2d0:	bfc5                	j	2c0 <stat+0x2a>

00000000000002d2 <atoi>:

int
atoi(const char *s)
{
 2d2:	1141                	addi	sp,sp,-16
 2d4:	e406                	sd	ra,8(sp)
 2d6:	e022                	sd	s0,0(sp)
 2d8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 2da:	00054683          	lbu	a3,0(a0)
 2de:	fd06879b          	addiw	a5,a3,-48 # fd0 <digits+0x230>
 2e2:	0ff7f793          	zext.b	a5,a5
 2e6:	4625                	li	a2,9
 2e8:	02f66963          	bltu	a2,a5,31a <atoi+0x48>
 2ec:	872a                	mv	a4,a0
  n = 0;
 2ee:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 2f0:	0705                	addi	a4,a4,1 # a001 <base+0x7ff1>
 2f2:	0025179b          	slliw	a5,a0,0x2
 2f6:	9fa9                	addw	a5,a5,a0
 2f8:	0017979b          	slliw	a5,a5,0x1
 2fc:	9fb5                	addw	a5,a5,a3
 2fe:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 302:	00074683          	lbu	a3,0(a4)
 306:	fd06879b          	addiw	a5,a3,-48
 30a:	0ff7f793          	zext.b	a5,a5
 30e:	fef671e3          	bgeu	a2,a5,2f0 <atoi+0x1e>
  return n;
}
 312:	60a2                	ld	ra,8(sp)
 314:	6402                	ld	s0,0(sp)
 316:	0141                	addi	sp,sp,16
 318:	8082                	ret
  n = 0;
 31a:	4501                	li	a0,0
 31c:	bfdd                	j	312 <atoi+0x40>

000000000000031e <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 31e:	1141                	addi	sp,sp,-16
 320:	e406                	sd	ra,8(sp)
 322:	e022                	sd	s0,0(sp)
 324:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 326:	02b57563          	bgeu	a0,a1,350 <memmove+0x32>
    while (n-- > 0)
 32a:	00c05f63          	blez	a2,348 <memmove+0x2a>
 32e:	1602                	slli	a2,a2,0x20
 330:	9201                	srli	a2,a2,0x20
 332:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 336:	872a                	mv	a4,a0
      *dst++ = *src++;
 338:	0585                	addi	a1,a1,1
 33a:	0705                	addi	a4,a4,1
 33c:	fff5c683          	lbu	a3,-1(a1)
 340:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 344:	fee79ae3          	bne	a5,a4,338 <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 348:	60a2                	ld	ra,8(sp)
 34a:	6402                	ld	s0,0(sp)
 34c:	0141                	addi	sp,sp,16
 34e:	8082                	ret
    while (n-- > 0)
 350:	fec05ce3          	blez	a2,348 <memmove+0x2a>
    dst += n;
 354:	00c50733          	add	a4,a0,a2
    src += n;
 358:	95b2                	add	a1,a1,a2
 35a:	fff6079b          	addiw	a5,a2,-1 # 9fff <base+0x7fef>
 35e:	1782                	slli	a5,a5,0x20
 360:	9381                	srli	a5,a5,0x20
 362:	fff7c793          	not	a5,a5
 366:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 368:	15fd                	addi	a1,a1,-1
 36a:	177d                	addi	a4,a4,-1
 36c:	0005c683          	lbu	a3,0(a1)
 370:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 374:	fef71ae3          	bne	a4,a5,368 <memmove+0x4a>
 378:	bfc1                	j	348 <memmove+0x2a>

000000000000037a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 37a:	1141                	addi	sp,sp,-16
 37c:	e406                	sd	ra,8(sp)
 37e:	e022                	sd	s0,0(sp)
 380:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 382:	c61d                	beqz	a2,3b0 <memcmp+0x36>
 384:	1602                	slli	a2,a2,0x20
 386:	9201                	srli	a2,a2,0x20
 388:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 38c:	00054783          	lbu	a5,0(a0)
 390:	0005c703          	lbu	a4,0(a1)
 394:	00e79863          	bne	a5,a4,3a4 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 398:	0505                	addi	a0,a0,1
    p2++;
 39a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 39c:	fed518e3          	bne	a0,a3,38c <memcmp+0x12>
  }
  return 0;
 3a0:	4501                	li	a0,0
 3a2:	a019                	j	3a8 <memcmp+0x2e>
      return *p1 - *p2;
 3a4:	40e7853b          	subw	a0,a5,a4
}
 3a8:	60a2                	ld	ra,8(sp)
 3aa:	6402                	ld	s0,0(sp)
 3ac:	0141                	addi	sp,sp,16
 3ae:	8082                	ret
  return 0;
 3b0:	4501                	li	a0,0
 3b2:	bfdd                	j	3a8 <memcmp+0x2e>

00000000000003b4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3b4:	1141                	addi	sp,sp,-16
 3b6:	e406                	sd	ra,8(sp)
 3b8:	e022                	sd	s0,0(sp)
 3ba:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3bc:	f63ff0ef          	jal	31e <memmove>
}
 3c0:	60a2                	ld	ra,8(sp)
 3c2:	6402                	ld	s0,0(sp)
 3c4:	0141                	addi	sp,sp,16
 3c6:	8082                	ret

00000000000003c8 <sbrk>:

char *
sbrk(int n)
{
 3c8:	1141                	addi	sp,sp,-16
 3ca:	e406                	sd	ra,8(sp)
 3cc:	e022                	sd	s0,0(sp)
 3ce:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3d0:	4585                	li	a1,1
 3d2:	0b2000ef          	jal	484 <sys_sbrk>
}
 3d6:	60a2                	ld	ra,8(sp)
 3d8:	6402                	ld	s0,0(sp)
 3da:	0141                	addi	sp,sp,16
 3dc:	8082                	ret

00000000000003de <sbrklazy>:

char *
sbrklazy(int n)
{
 3de:	1141                	addi	sp,sp,-16
 3e0:	e406                	sd	ra,8(sp)
 3e2:	e022                	sd	s0,0(sp)
 3e4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3e6:	4589                	li	a1,2
 3e8:	09c000ef          	jal	484 <sys_sbrk>
}
 3ec:	60a2                	ld	ra,8(sp)
 3ee:	6402                	ld	s0,0(sp)
 3f0:	0141                	addi	sp,sp,16
 3f2:	8082                	ret

00000000000003f4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3f4:	4885                	li	a7,1
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <exit>:
.global exit
exit:
 li a7, SYS_exit
 3fc:	4889                	li	a7,2
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <wait>:
.global wait
wait:
 li a7, SYS_wait
 404:	488d                	li	a7,3
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 40c:	4891                	li	a7,4
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <read>:
.global read
read:
 li a7, SYS_read
 414:	4895                	li	a7,5
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <write>:
.global write
write:
 li a7, SYS_write
 41c:	48c1                	li	a7,16
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <close>:
.global close
close:
 li a7, SYS_close
 424:	48d5                	li	a7,21
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <kill>:
.global kill
kill:
 li a7, SYS_kill
 42c:	4899                	li	a7,6
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <exec>:
.global exec
exec:
 li a7, SYS_exec
 434:	489d                	li	a7,7
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <open>:
.global open
open:
 li a7, SYS_open
 43c:	48bd                	li	a7,15
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 444:	48c5                	li	a7,17
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 44c:	48c9                	li	a7,18
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 454:	48a1                	li	a7,8
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <link>:
.global link
link:
 li a7, SYS_link
 45c:	48cd                	li	a7,19
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 464:	48d1                	li	a7,20
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 46c:	48a5                	li	a7,9
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <dup>:
.global dup
dup:
 li a7, SYS_dup
 474:	48a9                	li	a7,10
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 47c:	48ad                	li	a7,11
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 484:	48b1                	li	a7,12
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <pause>:
.global pause
pause:
 li a7, SYS_pause
 48c:	48b5                	li	a7,13
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 494:	48b9                	li	a7,14
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <sync>:
.global sync
sync:
 li a7, SYS_sync
 49c:	48d9                	li	a7,22
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <memstats>:
.global memstats
memstats:
 li a7, SYS_memstats
 4a4:	48dd                	li	a7,23
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ac:	1101                	addi	sp,sp,-32
 4ae:	ec06                	sd	ra,24(sp)
 4b0:	e822                	sd	s0,16(sp)
 4b2:	1000                	addi	s0,sp,32
 4b4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4b8:	4605                	li	a2,1
 4ba:	fef40593          	addi	a1,s0,-17
 4be:	f5fff0ef          	jal	41c <write>
}
 4c2:	60e2                	ld	ra,24(sp)
 4c4:	6442                	ld	s0,16(sp)
 4c6:	6105                	addi	sp,sp,32
 4c8:	8082                	ret

00000000000004ca <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4ca:	715d                	addi	sp,sp,-80
 4cc:	e486                	sd	ra,72(sp)
 4ce:	e0a2                	sd	s0,64(sp)
 4d0:	f84a                	sd	s2,48(sp)
 4d2:	f44e                	sd	s3,40(sp)
 4d4:	0880                	addi	s0,sp,80
 4d6:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 4d8:	c6d1                	beqz	a3,564 <printint+0x9a>
 4da:	0805d563          	bgez	a1,564 <printint+0x9a>
    neg = 1;
    x = -xx;
 4de:	40b005b3          	neg	a1,a1
    neg = 1;
 4e2:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 4e4:	fb840993          	addi	s3,s0,-72
  neg = 0;
 4e8:	86ce                	mv	a3,s3
  i = 0;
 4ea:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 4ec:	00001817          	auipc	a6,0x1
 4f0:	8b480813          	addi	a6,a6,-1868 # da0 <digits>
 4f4:	88ba                	mv	a7,a4
 4f6:	0017051b          	addiw	a0,a4,1
 4fa:	872a                	mv	a4,a0
 4fc:	02c5f7b3          	remu	a5,a1,a2
 500:	97c2                	add	a5,a5,a6
 502:	0007c783          	lbu	a5,0(a5)
 506:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 50a:	87ae                	mv	a5,a1
 50c:	02c5d5b3          	divu	a1,a1,a2
 510:	0685                	addi	a3,a3,1
 512:	fec7f1e3          	bgeu	a5,a2,4f4 <printint+0x2a>
  if (neg)
 516:	00030c63          	beqz	t1,52e <printint+0x64>
    buf[i++] = '-';
 51a:	fd050793          	addi	a5,a0,-48
 51e:	00878533          	add	a0,a5,s0
 522:	02d00793          	li	a5,45
 526:	fef50423          	sb	a5,-24(a0)
 52a:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 52e:	02e05563          	blez	a4,558 <printint+0x8e>
 532:	fc26                	sd	s1,56(sp)
 534:	377d                	addiw	a4,a4,-1
 536:	00e984b3          	add	s1,s3,a4
 53a:	19fd                	addi	s3,s3,-1
 53c:	99ba                	add	s3,s3,a4
 53e:	1702                	slli	a4,a4,0x20
 540:	9301                	srli	a4,a4,0x20
 542:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 546:	0004c583          	lbu	a1,0(s1)
 54a:	854a                	mv	a0,s2
 54c:	f61ff0ef          	jal	4ac <putc>
  while (--i >= 0)
 550:	14fd                	addi	s1,s1,-1
 552:	ff349ae3          	bne	s1,s3,546 <printint+0x7c>
 556:	74e2                	ld	s1,56(sp)
}
 558:	60a6                	ld	ra,72(sp)
 55a:	6406                	ld	s0,64(sp)
 55c:	7942                	ld	s2,48(sp)
 55e:	79a2                	ld	s3,40(sp)
 560:	6161                	addi	sp,sp,80
 562:	8082                	ret
  neg = 0;
 564:	4301                	li	t1,0
 566:	bfbd                	j	4e4 <printint+0x1a>

0000000000000568 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 568:	711d                	addi	sp,sp,-96
 56a:	ec86                	sd	ra,88(sp)
 56c:	e8a2                	sd	s0,80(sp)
 56e:	e4a6                	sd	s1,72(sp)
 570:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 572:	0005c483          	lbu	s1,0(a1)
 576:	22048363          	beqz	s1,79c <vprintf+0x234>
 57a:	e0ca                	sd	s2,64(sp)
 57c:	fc4e                	sd	s3,56(sp)
 57e:	f852                	sd	s4,48(sp)
 580:	f456                	sd	s5,40(sp)
 582:	f05a                	sd	s6,32(sp)
 584:	ec5e                	sd	s7,24(sp)
 586:	e862                	sd	s8,16(sp)
 588:	8b2a                	mv	s6,a0
 58a:	8a2e                	mv	s4,a1
 58c:	8bb2                	mv	s7,a2
  state = 0;
 58e:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 590:	4901                	li	s2,0
 592:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 594:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 598:	06400c13          	li	s8,100
 59c:	a00d                	j	5be <vprintf+0x56>
        putc(fd, c0);
 59e:	85a6                	mv	a1,s1
 5a0:	855a                	mv	a0,s6
 5a2:	f0bff0ef          	jal	4ac <putc>
 5a6:	a019                	j	5ac <vprintf+0x44>
    } else if (state == '%') {
 5a8:	03598363          	beq	s3,s5,5ce <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 5ac:	0019079b          	addiw	a5,s2,1
 5b0:	893e                	mv	s2,a5
 5b2:	873e                	mv	a4,a5
 5b4:	97d2                	add	a5,a5,s4
 5b6:	0007c483          	lbu	s1,0(a5)
 5ba:	1c048a63          	beqz	s1,78e <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 5be:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 5c2:	fe0993e3          	bnez	s3,5a8 <vprintf+0x40>
      if (c0 == '%') {
 5c6:	fd579ce3          	bne	a5,s5,59e <vprintf+0x36>
        state = '%';
 5ca:	89be                	mv	s3,a5
 5cc:	b7c5                	j	5ac <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 5ce:	00ea06b3          	add	a3,s4,a4
 5d2:	0016c603          	lbu	a2,1(a3)
      if (c1)
 5d6:	1c060863          	beqz	a2,7a6 <vprintf+0x23e>
      if (c0 == 'd') {
 5da:	03878763          	beq	a5,s8,608 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 5de:	f9478693          	addi	a3,a5,-108
 5e2:	0016b693          	seqz	a3,a3
 5e6:	f9c60593          	addi	a1,a2,-100
 5ea:	e99d                	bnez	a1,620 <vprintf+0xb8>
 5ec:	ca95                	beqz	a3,620 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ee:	008b8493          	addi	s1,s7,8
 5f2:	4685                	li	a3,1
 5f4:	4629                	li	a2,10
 5f6:	000bb583          	ld	a1,0(s7)
 5fa:	855a                	mv	a0,s6
 5fc:	ecfff0ef          	jal	4ca <printint>
        i += 1;
 600:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 602:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 604:	4981                	li	s3,0
 606:	b75d                	j	5ac <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 608:	008b8493          	addi	s1,s7,8
 60c:	4685                	li	a3,1
 60e:	4629                	li	a2,10
 610:	000ba583          	lw	a1,0(s7)
 614:	855a                	mv	a0,s6
 616:	eb5ff0ef          	jal	4ca <printint>
 61a:	8ba6                	mv	s7,s1
      state = 0;
 61c:	4981                	li	s3,0
 61e:	b779                	j	5ac <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 620:	9752                	add	a4,a4,s4
 622:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 626:	f9460713          	addi	a4,a2,-108
 62a:	00173713          	seqz	a4,a4
 62e:	8f75                	and	a4,a4,a3
 630:	f9c58513          	addi	a0,a1,-100
 634:	18051363          	bnez	a0,7ba <vprintf+0x252>
 638:	18070163          	beqz	a4,7ba <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 63c:	008b8493          	addi	s1,s7,8
 640:	4685                	li	a3,1
 642:	4629                	li	a2,10
 644:	000bb583          	ld	a1,0(s7)
 648:	855a                	mv	a0,s6
 64a:	e81ff0ef          	jal	4ca <printint>
        i += 2;
 64e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 650:	8ba6                	mv	s7,s1
      state = 0;
 652:	4981                	li	s3,0
        i += 2;
 654:	bfa1                	j	5ac <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 656:	008b8493          	addi	s1,s7,8
 65a:	4681                	li	a3,0
 65c:	4629                	li	a2,10
 65e:	000be583          	lwu	a1,0(s7)
 662:	855a                	mv	a0,s6
 664:	e67ff0ef          	jal	4ca <printint>
 668:	8ba6                	mv	s7,s1
      state = 0;
 66a:	4981                	li	s3,0
 66c:	b781                	j	5ac <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 66e:	008b8493          	addi	s1,s7,8
 672:	4681                	li	a3,0
 674:	4629                	li	a2,10
 676:	000bb583          	ld	a1,0(s7)
 67a:	855a                	mv	a0,s6
 67c:	e4fff0ef          	jal	4ca <printint>
        i += 1;
 680:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 682:	8ba6                	mv	s7,s1
      state = 0;
 684:	4981                	li	s3,0
 686:	b71d                	j	5ac <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 688:	008b8493          	addi	s1,s7,8
 68c:	4681                	li	a3,0
 68e:	4629                	li	a2,10
 690:	000bb583          	ld	a1,0(s7)
 694:	855a                	mv	a0,s6
 696:	e35ff0ef          	jal	4ca <printint>
        i += 2;
 69a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 69c:	8ba6                	mv	s7,s1
      state = 0;
 69e:	4981                	li	s3,0
        i += 2;
 6a0:	b731                	j	5ac <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6a2:	008b8493          	addi	s1,s7,8
 6a6:	4681                	li	a3,0
 6a8:	4641                	li	a2,16
 6aa:	000be583          	lwu	a1,0(s7)
 6ae:	855a                	mv	a0,s6
 6b0:	e1bff0ef          	jal	4ca <printint>
 6b4:	8ba6                	mv	s7,s1
      state = 0;
 6b6:	4981                	li	s3,0
 6b8:	bdd5                	j	5ac <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ba:	008b8493          	addi	s1,s7,8
 6be:	4681                	li	a3,0
 6c0:	4641                	li	a2,16
 6c2:	000bb583          	ld	a1,0(s7)
 6c6:	855a                	mv	a0,s6
 6c8:	e03ff0ef          	jal	4ca <printint>
        i += 1;
 6cc:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ce:	8ba6                	mv	s7,s1
      state = 0;
 6d0:	4981                	li	s3,0
 6d2:	bde9                	j	5ac <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d4:	008b8493          	addi	s1,s7,8
 6d8:	4681                	li	a3,0
 6da:	4641                	li	a2,16
 6dc:	000bb583          	ld	a1,0(s7)
 6e0:	855a                	mv	a0,s6
 6e2:	de9ff0ef          	jal	4ca <printint>
        i += 2;
 6e6:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6e8:	8ba6                	mv	s7,s1
      state = 0;
 6ea:	4981                	li	s3,0
        i += 2;
 6ec:	b5c1                	j	5ac <vprintf+0x44>
 6ee:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 6f0:	008b8793          	addi	a5,s7,8
 6f4:	8cbe                	mv	s9,a5
 6f6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6fa:	03000593          	li	a1,48
 6fe:	855a                	mv	a0,s6
 700:	dadff0ef          	jal	4ac <putc>
  putc(fd, 'x');
 704:	07800593          	li	a1,120
 708:	855a                	mv	a0,s6
 70a:	da3ff0ef          	jal	4ac <putc>
 70e:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 710:	00000b97          	auipc	s7,0x0
 714:	690b8b93          	addi	s7,s7,1680 # da0 <digits>
 718:	03c9d793          	srli	a5,s3,0x3c
 71c:	97de                	add	a5,a5,s7
 71e:	0007c583          	lbu	a1,0(a5)
 722:	855a                	mv	a0,s6
 724:	d89ff0ef          	jal	4ac <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 728:	0992                	slli	s3,s3,0x4
 72a:	34fd                	addiw	s1,s1,-1
 72c:	f4f5                	bnez	s1,718 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 72e:	8be6                	mv	s7,s9
      state = 0;
 730:	4981                	li	s3,0
 732:	6ca2                	ld	s9,8(sp)
 734:	bda5                	j	5ac <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 736:	008b8493          	addi	s1,s7,8
 73a:	000bc583          	lbu	a1,0(s7)
 73e:	855a                	mv	a0,s6
 740:	d6dff0ef          	jal	4ac <putc>
 744:	8ba6                	mv	s7,s1
      state = 0;
 746:	4981                	li	s3,0
 748:	b595                	j	5ac <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 74a:	008b8993          	addi	s3,s7,8
 74e:	000bb483          	ld	s1,0(s7)
 752:	cc91                	beqz	s1,76e <vprintf+0x206>
        for (; *s; s++)
 754:	0004c583          	lbu	a1,0(s1)
 758:	c985                	beqz	a1,788 <vprintf+0x220>
          putc(fd, *s);
 75a:	855a                	mv	a0,s6
 75c:	d51ff0ef          	jal	4ac <putc>
        for (; *s; s++)
 760:	0485                	addi	s1,s1,1
 762:	0004c583          	lbu	a1,0(s1)
 766:	f9f5                	bnez	a1,75a <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 768:	8bce                	mv	s7,s3
      state = 0;
 76a:	4981                	li	s3,0
 76c:	b581                	j	5ac <vprintf+0x44>
          s = "(null)";
 76e:	00000497          	auipc	s1,0x0
 772:	62a48493          	addi	s1,s1,1578 # d98 <malloc+0x48e>
        for (; *s; s++)
 776:	02800593          	li	a1,40
 77a:	b7c5                	j	75a <vprintf+0x1f2>
        putc(fd, '%');
 77c:	85be                	mv	a1,a5
 77e:	855a                	mv	a0,s6
 780:	d2dff0ef          	jal	4ac <putc>
      state = 0;
 784:	4981                	li	s3,0
 786:	b51d                	j	5ac <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 788:	8bce                	mv	s7,s3
      state = 0;
 78a:	4981                	li	s3,0
 78c:	b505                	j	5ac <vprintf+0x44>
 78e:	6906                	ld	s2,64(sp)
 790:	79e2                	ld	s3,56(sp)
 792:	7a42                	ld	s4,48(sp)
 794:	7aa2                	ld	s5,40(sp)
 796:	7b02                	ld	s6,32(sp)
 798:	6be2                	ld	s7,24(sp)
 79a:	6c42                	ld	s8,16(sp)
    }
  }
}
 79c:	60e6                	ld	ra,88(sp)
 79e:	6446                	ld	s0,80(sp)
 7a0:	64a6                	ld	s1,72(sp)
 7a2:	6125                	addi	sp,sp,96
 7a4:	8082                	ret
      if (c0 == 'd') {
 7a6:	06400713          	li	a4,100
 7aa:	e4e78fe3          	beq	a5,a4,608 <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 7ae:	f9478693          	addi	a3,a5,-108
 7b2:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 7b6:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 7b8:	4701                	li	a4,0
      } else if (c0 == 'u') {
 7ba:	07500513          	li	a0,117
 7be:	e8a78ce3          	beq	a5,a0,656 <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 7c2:	f8b60513          	addi	a0,a2,-117
 7c6:	e119                	bnez	a0,7cc <vprintf+0x264>
 7c8:	ea0693e3          	bnez	a3,66e <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 7cc:	f8b58513          	addi	a0,a1,-117
 7d0:	e119                	bnez	a0,7d6 <vprintf+0x26e>
 7d2:	ea071be3          	bnez	a4,688 <vprintf+0x120>
      } else if (c0 == 'x') {
 7d6:	07800513          	li	a0,120
 7da:	eca784e3          	beq	a5,a0,6a2 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 7de:	f8860613          	addi	a2,a2,-120
 7e2:	e219                	bnez	a2,7e8 <vprintf+0x280>
 7e4:	ec069be3          	bnez	a3,6ba <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 7e8:	f8858593          	addi	a1,a1,-120
 7ec:	e199                	bnez	a1,7f2 <vprintf+0x28a>
 7ee:	ee0713e3          	bnez	a4,6d4 <vprintf+0x16c>
      } else if (c0 == 'p') {
 7f2:	07000713          	li	a4,112
 7f6:	eee78ce3          	beq	a5,a4,6ee <vprintf+0x186>
      } else if (c0 == 'c') {
 7fa:	06300713          	li	a4,99
 7fe:	f2e78ce3          	beq	a5,a4,736 <vprintf+0x1ce>
      } else if (c0 == 's') {
 802:	07300713          	li	a4,115
 806:	f4e782e3          	beq	a5,a4,74a <vprintf+0x1e2>
      } else if (c0 == '%') {
 80a:	02500713          	li	a4,37
 80e:	f6e787e3          	beq	a5,a4,77c <vprintf+0x214>
        putc(fd, '%');
 812:	02500593          	li	a1,37
 816:	855a                	mv	a0,s6
 818:	c95ff0ef          	jal	4ac <putc>
        putc(fd, c0);
 81c:	85a6                	mv	a1,s1
 81e:	855a                	mv	a0,s6
 820:	c8dff0ef          	jal	4ac <putc>
      state = 0;
 824:	4981                	li	s3,0
 826:	b359                	j	5ac <vprintf+0x44>

0000000000000828 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 828:	715d                	addi	sp,sp,-80
 82a:	ec06                	sd	ra,24(sp)
 82c:	e822                	sd	s0,16(sp)
 82e:	1000                	addi	s0,sp,32
 830:	e010                	sd	a2,0(s0)
 832:	e414                	sd	a3,8(s0)
 834:	e818                	sd	a4,16(s0)
 836:	ec1c                	sd	a5,24(s0)
 838:	03043023          	sd	a6,32(s0)
 83c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 840:	8622                	mv	a2,s0
 842:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 846:	d23ff0ef          	jal	568 <vprintf>
}
 84a:	60e2                	ld	ra,24(sp)
 84c:	6442                	ld	s0,16(sp)
 84e:	6161                	addi	sp,sp,80
 850:	8082                	ret

0000000000000852 <printf>:

void
printf(const char *fmt, ...)
{
 852:	711d                	addi	sp,sp,-96
 854:	ec06                	sd	ra,24(sp)
 856:	e822                	sd	s0,16(sp)
 858:	1000                	addi	s0,sp,32
 85a:	e40c                	sd	a1,8(s0)
 85c:	e810                	sd	a2,16(s0)
 85e:	ec14                	sd	a3,24(s0)
 860:	f018                	sd	a4,32(s0)
 862:	f41c                	sd	a5,40(s0)
 864:	03043823          	sd	a6,48(s0)
 868:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 86c:	00840613          	addi	a2,s0,8
 870:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 874:	85aa                	mv	a1,a0
 876:	4505                	li	a0,1
 878:	cf1ff0ef          	jal	568 <vprintf>
}
 87c:	60e2                	ld	ra,24(sp)
 87e:	6442                	ld	s0,16(sp)
 880:	6125                	addi	sp,sp,96
 882:	8082                	ret

0000000000000884 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 884:	1141                	addi	sp,sp,-16
 886:	e406                	sd	ra,8(sp)
 888:	e022                	sd	s0,0(sp)
 88a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 88c:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 890:	00001797          	auipc	a5,0x1
 894:	7707b783          	ld	a5,1904(a5) # 2000 <freep>
 898:	a039                	j	8a6 <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 89a:	6398                	ld	a4,0(a5)
 89c:	00e7e463          	bltu	a5,a4,8a4 <free+0x20>
 8a0:	00e6ea63          	bltu	a3,a4,8b4 <free+0x30>
{
 8a4:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a6:	fed7fae3          	bgeu	a5,a3,89a <free+0x16>
 8aa:	6398                	ld	a4,0(a5)
 8ac:	00e6e463          	bltu	a3,a4,8b4 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b0:	fee7eae3          	bltu	a5,a4,8a4 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 8b4:	ff852583          	lw	a1,-8(a0)
 8b8:	6390                	ld	a2,0(a5)
 8ba:	02059813          	slli	a6,a1,0x20
 8be:	01c85713          	srli	a4,a6,0x1c
 8c2:	9736                	add	a4,a4,a3
 8c4:	02e60563          	beq	a2,a4,8ee <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 8c8:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 8cc:	4790                	lw	a2,8(a5)
 8ce:	02061593          	slli	a1,a2,0x20
 8d2:	01c5d713          	srli	a4,a1,0x1c
 8d6:	973e                	add	a4,a4,a5
 8d8:	02e68263          	beq	a3,a4,8fc <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 8dc:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8de:	00001717          	auipc	a4,0x1
 8e2:	72f73123          	sd	a5,1826(a4) # 2000 <freep>
}
 8e6:	60a2                	ld	ra,8(sp)
 8e8:	6402                	ld	s0,0(sp)
 8ea:	0141                	addi	sp,sp,16
 8ec:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 8ee:	4618                	lw	a4,8(a2)
 8f0:	9f2d                	addw	a4,a4,a1
 8f2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8f6:	6398                	ld	a4,0(a5)
 8f8:	6310                	ld	a2,0(a4)
 8fa:	b7f9                	j	8c8 <free+0x44>
    p->s.size += bp->s.size;
 8fc:	ff852703          	lw	a4,-8(a0)
 900:	9f31                	addw	a4,a4,a2
 902:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 904:	ff053683          	ld	a3,-16(a0)
 908:	bfd1                	j	8dc <free+0x58>

000000000000090a <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 90a:	7139                	addi	sp,sp,-64
 90c:	fc06                	sd	ra,56(sp)
 90e:	f822                	sd	s0,48(sp)
 910:	f04a                	sd	s2,32(sp)
 912:	ec4e                	sd	s3,24(sp)
 914:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 916:	02051993          	slli	s3,a0,0x20
 91a:	0209d993          	srli	s3,s3,0x20
 91e:	09bd                	addi	s3,s3,15
 920:	0049d993          	srli	s3,s3,0x4
 924:	2985                	addiw	s3,s3,1
 926:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 928:	00001517          	auipc	a0,0x1
 92c:	6d853503          	ld	a0,1752(a0) # 2000 <freep>
 930:	c905                	beqz	a0,960 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 932:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 934:	4798                	lw	a4,8(a5)
 936:	09377663          	bgeu	a4,s3,9c2 <malloc+0xb8>
 93a:	f426                	sd	s1,40(sp)
 93c:	e852                	sd	s4,16(sp)
 93e:	e456                	sd	s5,8(sp)
 940:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 942:	8a4e                	mv	s4,s3
 944:	6705                	lui	a4,0x1
 946:	00e9f363          	bgeu	s3,a4,94c <malloc+0x42>
 94a:	6a05                	lui	s4,0x1
 94c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 950:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 954:	00001497          	auipc	s1,0x1
 958:	6ac48493          	addi	s1,s1,1708 # 2000 <freep>
  if (p == SBRK_ERROR)
 95c:	5afd                	li	s5,-1
 95e:	a83d                	j	99c <malloc+0x92>
 960:	f426                	sd	s1,40(sp)
 962:	e852                	sd	s4,16(sp)
 964:	e456                	sd	s5,8(sp)
 966:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 968:	00001797          	auipc	a5,0x1
 96c:	6a878793          	addi	a5,a5,1704 # 2010 <base>
 970:	00001717          	auipc	a4,0x1
 974:	68f73823          	sd	a5,1680(a4) # 2000 <freep>
 978:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 97a:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 97e:	b7d1                	j	942 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 980:	6398                	ld	a4,0(a5)
 982:	e118                	sd	a4,0(a0)
 984:	a899                	j	9da <malloc+0xd0>
  hp->s.size = nu;
 986:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 98a:	0541                	addi	a0,a0,16
 98c:	ef9ff0ef          	jal	884 <free>
  return freep;
 990:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 992:	c125                	beqz	a0,9f2 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 994:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 996:	4798                	lw	a4,8(a5)
 998:	03277163          	bgeu	a4,s2,9ba <malloc+0xb0>
    if (p == freep)
 99c:	6098                	ld	a4,0(s1)
 99e:	853e                	mv	a0,a5
 9a0:	fef71ae3          	bne	a4,a5,994 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 9a4:	8552                	mv	a0,s4
 9a6:	a23ff0ef          	jal	3c8 <sbrk>
  if (p == SBRK_ERROR)
 9aa:	fd551ee3          	bne	a0,s5,986 <malloc+0x7c>
        return 0;
 9ae:	4501                	li	a0,0
 9b0:	74a2                	ld	s1,40(sp)
 9b2:	6a42                	ld	s4,16(sp)
 9b4:	6aa2                	ld	s5,8(sp)
 9b6:	6b02                	ld	s6,0(sp)
 9b8:	a03d                	j	9e6 <malloc+0xdc>
 9ba:	74a2                	ld	s1,40(sp)
 9bc:	6a42                	ld	s4,16(sp)
 9be:	6aa2                	ld	s5,8(sp)
 9c0:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 9c2:	fae90fe3          	beq	s2,a4,980 <malloc+0x76>
        p->s.size -= nunits;
 9c6:	4137073b          	subw	a4,a4,s3
 9ca:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9cc:	02071693          	slli	a3,a4,0x20
 9d0:	01c6d713          	srli	a4,a3,0x1c
 9d4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9d6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9da:	00001717          	auipc	a4,0x1
 9de:	62a73323          	sd	a0,1574(a4) # 2000 <freep>
      return (void *)(p + 1);
 9e2:	01078513          	addi	a0,a5,16
  }
}
 9e6:	70e2                	ld	ra,56(sp)
 9e8:	7442                	ld	s0,48(sp)
 9ea:	7902                	ld	s2,32(sp)
 9ec:	69e2                	ld	s3,24(sp)
 9ee:	6121                	addi	sp,sp,64
 9f0:	8082                	ret
 9f2:	74a2                	ld	s1,40(sp)
 9f4:	6a42                	ld	s4,16(sp)
 9f6:	6aa2                	ld	s5,8(sp)
 9f8:	6b02                	ld	s6,0(sp)
 9fa:	b7f5                	j	9e6 <malloc+0xdc>
