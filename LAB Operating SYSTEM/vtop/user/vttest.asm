
user/_vttest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print_mapping>:

int global_var = 42;

static void
print_mapping(const char *name, uint64 va)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
   c:	84aa                	mv	s1,a0
   e:	892e                	mv	s2,a1
  uint64 pa = vtop(va);
  10:	852e                	mv	a0,a1
  12:	506000ef          	jal	518 <vtop>
  if (pa == (uint64)-1) {
  16:	57fd                	li	a5,-1
  18:	02f50163          	beq	a0,a5,3a <print_mapping+0x3a>
  1c:	86aa                	mv	a3,a0
    printf("[vtop] %s:\n       VA: 0x%lx  ->  PA: -1 (UNMAPPED / INVALID)\n", name, va);
  } else {
    printf("[vtop] %s:\n       VA: 0x%lx  ->  PA: 0x%lx\n", name, va, pa);
  1e:	864a                	mv	a2,s2
  20:	85a6                	mv	a1,s1
  22:	00001517          	auipc	a0,0x1
  26:	a9650513          	addi	a0,a0,-1386 # ab8 <malloc+0x13a>
  2a:	09d000ef          	jal	8c6 <printf>
  }
}
  2e:	60e2                	ld	ra,24(sp)
  30:	6442                	ld	s0,16(sp)
  32:	64a2                	ld	s1,8(sp)
  34:	6902                	ld	s2,0(sp)
  36:	6105                	addi	sp,sp,32
  38:	8082                	ret
    printf("[vtop] %s:\n       VA: 0x%lx  ->  PA: -1 (UNMAPPED / INVALID)\n", name, va);
  3a:	864a                	mv	a2,s2
  3c:	85a6                	mv	a1,s1
  3e:	00001517          	auipc	a0,0x1
  42:	a3250513          	addi	a0,a0,-1486 # a70 <malloc+0xf2>
  46:	081000ef          	jal	8c6 <printf>
  4a:	b7d5                	j	2e <print_mapping+0x2e>

000000000000004c <main>:

int
main(int argc, char *argv[])
{
  4c:	7179                	addi	sp,sp,-48
  4e:	f406                	sd	ra,40(sp)
  50:	f022                	sd	s0,32(sp)
  52:	1800                	addi	s0,sp,48
  int stack_var = 100;
  54:	06400793          	li	a5,100
  58:	fcf42e23          	sw	a5,-36(s0)

  printf("============================================================\n");
  5c:	00001517          	auipc	a0,0x1
  60:	a8c50513          	addi	a0,a0,-1396 # ae8 <malloc+0x16a>
  64:	063000ef          	jal	8c6 <printf>
  printf("    Virtual-to-Physical Address Translation Test (vtop)     \n");
  68:	00001517          	auipc	a0,0x1
  6c:	ac050513          	addi	a0,a0,-1344 # b28 <malloc+0x1aa>
  70:	057000ef          	jal	8c6 <printf>
  printf("============================================================\n\n");
  74:	00001517          	auipc	a0,0x1
  78:	af450513          	addi	a0,a0,-1292 # b68 <malloc+0x1ea>
  7c:	04b000ef          	jal	8c6 <printf>

  printf("--- 1. Testing Code and Global Variables ---\n");
  80:	00001517          	auipc	a0,0x1
  84:	b2850513          	addi	a0,a0,-1240 # ba8 <malloc+0x22a>
  88:	03f000ef          	jal	8c6 <printf>
  print_mapping("main() function code", (uint64)main);
  8c:	00000597          	auipc	a1,0x0
  90:	fc058593          	addi	a1,a1,-64 # 4c <main>
  94:	00001517          	auipc	a0,0x1
  98:	b4450513          	addi	a0,a0,-1212 # bd8 <malloc+0x25a>
  9c:	f65ff0ef          	jal	0 <print_mapping>
  print_mapping("global_var (global data)", (uint64)&global_var);
  a0:	00002597          	auipc	a1,0x2
  a4:	f6058593          	addi	a1,a1,-160 # 2000 <global_var>
  a8:	00001517          	auipc	a0,0x1
  ac:	b4850513          	addi	a0,a0,-1208 # bf0 <malloc+0x272>
  b0:	f51ff0ef          	jal	0 <print_mapping>
  printf("\n");
  b4:	00001517          	auipc	a0,0x1
  b8:	b5c50513          	addi	a0,a0,-1188 # c10 <malloc+0x292>
  bc:	00b000ef          	jal	8c6 <printf>

  printf("--- 2. Testing Stack Variable ---\n");
  c0:	00001517          	auipc	a0,0x1
  c4:	b5850513          	addi	a0,a0,-1192 # c18 <malloc+0x29a>
  c8:	7fe000ef          	jal	8c6 <printf>
  print_mapping("stack_var (local stack variable)", (uint64)&stack_var);
  cc:	fdc40593          	addi	a1,s0,-36
  d0:	00001517          	auipc	a0,0x1
  d4:	b7050513          	addi	a0,a0,-1168 # c40 <malloc+0x2c2>
  d8:	f29ff0ef          	jal	0 <print_mapping>
  printf("\n");
  dc:	00001517          	auipc	a0,0x1
  e0:	b3450513          	addi	a0,a0,-1228 # c10 <malloc+0x292>
  e4:	7e2000ef          	jal	8c6 <printf>

  printf("--- 3. Testing Heap Allocation via sbrk() ---\n");
  e8:	00001517          	auipc	a0,0x1
  ec:	b8050513          	addi	a0,a0,-1152 # c68 <malloc+0x2ea>
  f0:	7d6000ef          	jal	8c6 <printf>
  char *heap_ptr = sbrk(4096);
  f4:	6505                	lui	a0,0x1
  f6:	346000ef          	jal	43c <sbrk>
  if (heap_ptr == (char *)-1) {
  fa:	57fd                	li	a5,-1
  fc:	0af50563          	beq	a0,a5,1a6 <main+0x15a>
 100:	ec26                	sd	s1,24(sp)
 102:	84aa                	mv	s1,a0
    printf("sbrk failed!\n");
    exit(1);
  }
  // Write data to touch the page
  *heap_ptr = 'X';
 104:	05800793          	li	a5,88
 108:	00f50023          	sb	a5,0(a0) # 1000 <digits+0x238>
  *(heap_ptr + 256) = 'Y';
 10c:	05900793          	li	a5,89
 110:	10f50023          	sb	a5,256(a0)
  print_mapping("heap_ptr (allocated heap page base)", (uint64)heap_ptr);
 114:	85aa                	mv	a1,a0
 116:	00001517          	auipc	a0,0x1
 11a:	b9250513          	addi	a0,a0,-1134 # ca8 <malloc+0x32a>
 11e:	ee3ff0ef          	jal	0 <print_mapping>
  print_mapping("heap_ptr + 256 (offset within page)", (uint64)(heap_ptr + 256));
 122:	10048593          	addi	a1,s1,256
 126:	00001517          	auipc	a0,0x1
 12a:	baa50513          	addi	a0,a0,-1110 # cd0 <malloc+0x352>
 12e:	ed3ff0ef          	jal	0 <print_mapping>
  printf("\n");
 132:	00001517          	auipc	a0,0x1
 136:	ade50513          	addi	a0,a0,-1314 # c10 <malloc+0x292>
 13a:	78c000ef          	jal	8c6 <printf>

  printf("--- 4. Testing Unmapped Virtual Addresses ---\n");
 13e:	00001517          	auipc	a0,0x1
 142:	bba50513          	addi	a0,a0,-1094 # cf8 <malloc+0x37a>
 146:	780000ef          	jal	8c6 <printf>
  uint64 unmapped_va1 = 0x7FFFFFF0;
  uint64 unmapped_va2 = (uint64)heap_ptr + (1024ULL * 1024ULL * 64ULL); // 64MB above heap
  print_mapping("Unmapped Address 1 (arbitrary high address)", unmapped_va1);
 14a:	800005b7          	lui	a1,0x80000
 14e:	ff05c593          	xori	a1,a1,-16
 152:	00001517          	auipc	a0,0x1
 156:	bd650513          	addi	a0,a0,-1066 # d28 <malloc+0x3aa>
 15a:	ea7ff0ef          	jal	0 <print_mapping>
  print_mapping("Unmapped Address 2 (far above heap break)", unmapped_va2);
 15e:	040005b7          	lui	a1,0x4000
 162:	95a6                	add	a1,a1,s1
 164:	00001517          	auipc	a0,0x1
 168:	bf450513          	addi	a0,a0,-1036 # d58 <malloc+0x3da>
 16c:	e95ff0ef          	jal	0 <print_mapping>
  printf("\n");
 170:	00001517          	auipc	a0,0x1
 174:	aa050513          	addi	a0,a0,-1376 # c10 <malloc+0x292>
 178:	74e000ef          	jal	8c6 <printf>

  printf("============================================================\n");
 17c:	00001517          	auipc	a0,0x1
 180:	96c50513          	addi	a0,a0,-1684 # ae8 <malloc+0x16a>
 184:	742000ef          	jal	8c6 <printf>
  printf("vttest: All translation tests completed successfully!\n");
 188:	00001517          	auipc	a0,0x1
 18c:	c0050513          	addi	a0,a0,-1024 # d88 <malloc+0x40a>
 190:	736000ef          	jal	8c6 <printf>
  printf("============================================================\n");
 194:	00001517          	auipc	a0,0x1
 198:	95450513          	addi	a0,a0,-1708 # ae8 <malloc+0x16a>
 19c:	72a000ef          	jal	8c6 <printf>
  exit(0);
 1a0:	4501                	li	a0,0
 1a2:	2ce000ef          	jal	470 <exit>
 1a6:	ec26                	sd	s1,24(sp)
    printf("sbrk failed!\n");
 1a8:	00001517          	auipc	a0,0x1
 1ac:	af050513          	addi	a0,a0,-1296 # c98 <malloc+0x31a>
 1b0:	716000ef          	jal	8c6 <printf>
    exit(1);
 1b4:	4505                	li	a0,1
 1b6:	2ba000ef          	jal	470 <exit>

00000000000001ba <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1ba:	1141                	addi	sp,sp,-16
 1bc:	e406                	sd	ra,8(sp)
 1be:	e022                	sd	s0,0(sp)
 1c0:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1c2:	e8bff0ef          	jal	4c <main>
  exit(r);
 1c6:	2aa000ef          	jal	470 <exit>

00000000000001ca <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 1ca:	1141                	addi	sp,sp,-16
 1cc:	e406                	sd	ra,8(sp)
 1ce:	e022                	sd	s0,0(sp)
 1d0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 1d2:	87aa                	mv	a5,a0
 1d4:	0585                	addi	a1,a1,1 # 4000001 <base+0x3ffdfe1>
 1d6:	0785                	addi	a5,a5,1
 1d8:	fff5c703          	lbu	a4,-1(a1)
 1dc:	fee78fa3          	sb	a4,-1(a5)
 1e0:	fb75                	bnez	a4,1d4 <strcpy+0xa>
    ;
  return os;
}
 1e2:	60a2                	ld	ra,8(sp)
 1e4:	6402                	ld	s0,0(sp)
 1e6:	0141                	addi	sp,sp,16
 1e8:	8082                	ret

00000000000001ea <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1ea:	1141                	addi	sp,sp,-16
 1ec:	e406                	sd	ra,8(sp)
 1ee:	e022                	sd	s0,0(sp)
 1f0:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 1f2:	00054783          	lbu	a5,0(a0)
 1f6:	cb91                	beqz	a5,20a <strcmp+0x20>
 1f8:	0005c703          	lbu	a4,0(a1)
 1fc:	00f71763          	bne	a4,a5,20a <strcmp+0x20>
    p++, q++;
 200:	0505                	addi	a0,a0,1
 202:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 204:	00054783          	lbu	a5,0(a0)
 208:	fbe5                	bnez	a5,1f8 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 20a:	0005c503          	lbu	a0,0(a1)
}
 20e:	40a7853b          	subw	a0,a5,a0
 212:	60a2                	ld	ra,8(sp)
 214:	6402                	ld	s0,0(sp)
 216:	0141                	addi	sp,sp,16
 218:	8082                	ret

000000000000021a <strlen>:

uint
strlen(const char *s)
{
 21a:	1141                	addi	sp,sp,-16
 21c:	e406                	sd	ra,8(sp)
 21e:	e022                	sd	s0,0(sp)
 220:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 222:	00054783          	lbu	a5,0(a0)
 226:	cf91                	beqz	a5,242 <strlen+0x28>
 228:	00150793          	addi	a5,a0,1
 22c:	86be                	mv	a3,a5
 22e:	0785                	addi	a5,a5,1
 230:	fff7c703          	lbu	a4,-1(a5)
 234:	ff65                	bnez	a4,22c <strlen+0x12>
 236:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 23a:	60a2                	ld	ra,8(sp)
 23c:	6402                	ld	s0,0(sp)
 23e:	0141                	addi	sp,sp,16
 240:	8082                	ret
  for (n = 0; s[n]; n++)
 242:	4501                	li	a0,0
 244:	bfdd                	j	23a <strlen+0x20>

0000000000000246 <memset>:

void *
memset(void *dst, int c, uint n)
{
 246:	1141                	addi	sp,sp,-16
 248:	e406                	sd	ra,8(sp)
 24a:	e022                	sd	s0,0(sp)
 24c:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 24e:	ca19                	beqz	a2,264 <memset+0x1e>
 250:	87aa                	mv	a5,a0
 252:	1602                	slli	a2,a2,0x20
 254:	9201                	srli	a2,a2,0x20
 256:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 25a:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 25e:	0785                	addi	a5,a5,1
 260:	fee79de3          	bne	a5,a4,25a <memset+0x14>
  }
  return dst;
}
 264:	60a2                	ld	ra,8(sp)
 266:	6402                	ld	s0,0(sp)
 268:	0141                	addi	sp,sp,16
 26a:	8082                	ret

000000000000026c <strchr>:

char *
strchr(const char *s, char c)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e406                	sd	ra,8(sp)
 270:	e022                	sd	s0,0(sp)
 272:	0800                	addi	s0,sp,16
  for (; *s; s++)
 274:	00054783          	lbu	a5,0(a0)
 278:	cf81                	beqz	a5,290 <strchr+0x24>
    if (*s == c)
 27a:	00f58763          	beq	a1,a5,288 <strchr+0x1c>
  for (; *s; s++)
 27e:	0505                	addi	a0,a0,1
 280:	00054783          	lbu	a5,0(a0)
 284:	fbfd                	bnez	a5,27a <strchr+0xe>
      return (char *)s;
  return 0;
 286:	4501                	li	a0,0
}
 288:	60a2                	ld	ra,8(sp)
 28a:	6402                	ld	s0,0(sp)
 28c:	0141                	addi	sp,sp,16
 28e:	8082                	ret
  return 0;
 290:	4501                	li	a0,0
 292:	bfdd                	j	288 <strchr+0x1c>

0000000000000294 <gets>:

char *
gets(char *buf, int max)
{
 294:	711d                	addi	sp,sp,-96
 296:	ec86                	sd	ra,88(sp)
 298:	e8a2                	sd	s0,80(sp)
 29a:	e4a6                	sd	s1,72(sp)
 29c:	e0ca                	sd	s2,64(sp)
 29e:	fc4e                	sd	s3,56(sp)
 2a0:	f852                	sd	s4,48(sp)
 2a2:	f456                	sd	s5,40(sp)
 2a4:	f05a                	sd	s6,32(sp)
 2a6:	ec5e                	sd	s7,24(sp)
 2a8:	e862                	sd	s8,16(sp)
 2aa:	1080                	addi	s0,sp,96
 2ac:	8baa                	mv	s7,a0
 2ae:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 2b0:	892a                	mv	s2,a0
 2b2:	4481                	li	s1,0
    cc = read(0, &c, 1);
 2b4:	faf40b13          	addi	s6,s0,-81
 2b8:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 2ba:	8c26                	mv	s8,s1
 2bc:	0014899b          	addiw	s3,s1,1
 2c0:	84ce                	mv	s1,s3
 2c2:	0349d463          	bge	s3,s4,2ea <gets+0x56>
    cc = read(0, &c, 1);
 2c6:	8656                	mv	a2,s5
 2c8:	85da                	mv	a1,s6
 2ca:	4501                	li	a0,0
 2cc:	1bc000ef          	jal	488 <read>
    if (cc < 1)
 2d0:	00a05d63          	blez	a0,2ea <gets+0x56>
      break;
    buf[i++] = c;
 2d4:	faf44783          	lbu	a5,-81(s0)
 2d8:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 2dc:	0905                	addi	s2,s2,1
 2de:	ff678713          	addi	a4,a5,-10
 2e2:	c319                	beqz	a4,2e8 <gets+0x54>
 2e4:	17cd                	addi	a5,a5,-13
 2e6:	fbf1                	bnez	a5,2ba <gets+0x26>
    buf[i++] = c;
 2e8:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 2ea:	9c5e                	add	s8,s8,s7
 2ec:	000c0023          	sb	zero,0(s8)
  return buf;
}
 2f0:	855e                	mv	a0,s7
 2f2:	60e6                	ld	ra,88(sp)
 2f4:	6446                	ld	s0,80(sp)
 2f6:	64a6                	ld	s1,72(sp)
 2f8:	6906                	ld	s2,64(sp)
 2fa:	79e2                	ld	s3,56(sp)
 2fc:	7a42                	ld	s4,48(sp)
 2fe:	7aa2                	ld	s5,40(sp)
 300:	7b02                	ld	s6,32(sp)
 302:	6be2                	ld	s7,24(sp)
 304:	6c42                	ld	s8,16(sp)
 306:	6125                	addi	sp,sp,96
 308:	8082                	ret

000000000000030a <stat>:

int
stat(const char *n, struct stat *st)
{
 30a:	1101                	addi	sp,sp,-32
 30c:	ec06                	sd	ra,24(sp)
 30e:	e822                	sd	s0,16(sp)
 310:	e04a                	sd	s2,0(sp)
 312:	1000                	addi	s0,sp,32
 314:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 316:	4581                	li	a1,0
 318:	198000ef          	jal	4b0 <open>
  if (fd < 0)
 31c:	02054263          	bltz	a0,340 <stat+0x36>
 320:	e426                	sd	s1,8(sp)
 322:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 324:	85ca                	mv	a1,s2
 326:	1a2000ef          	jal	4c8 <fstat>
 32a:	892a                	mv	s2,a0
  close(fd);
 32c:	8526                	mv	a0,s1
 32e:	16a000ef          	jal	498 <close>
  return r;
 332:	64a2                	ld	s1,8(sp)
}
 334:	854a                	mv	a0,s2
 336:	60e2                	ld	ra,24(sp)
 338:	6442                	ld	s0,16(sp)
 33a:	6902                	ld	s2,0(sp)
 33c:	6105                	addi	sp,sp,32
 33e:	8082                	ret
    return -1;
 340:	57fd                	li	a5,-1
 342:	893e                	mv	s2,a5
 344:	bfc5                	j	334 <stat+0x2a>

0000000000000346 <atoi>:

int
atoi(const char *s)
{
 346:	1141                	addi	sp,sp,-16
 348:	e406                	sd	ra,8(sp)
 34a:	e022                	sd	s0,0(sp)
 34c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 34e:	00054683          	lbu	a3,0(a0)
 352:	fd06879b          	addiw	a5,a3,-48
 356:	0ff7f793          	zext.b	a5,a5
 35a:	4625                	li	a2,9
 35c:	02f66963          	bltu	a2,a5,38e <atoi+0x48>
 360:	872a                	mv	a4,a0
  n = 0;
 362:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 364:	0705                	addi	a4,a4,1
 366:	0025179b          	slliw	a5,a0,0x2
 36a:	9fa9                	addw	a5,a5,a0
 36c:	0017979b          	slliw	a5,a5,0x1
 370:	9fb5                	addw	a5,a5,a3
 372:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 376:	00074683          	lbu	a3,0(a4)
 37a:	fd06879b          	addiw	a5,a3,-48
 37e:	0ff7f793          	zext.b	a5,a5
 382:	fef671e3          	bgeu	a2,a5,364 <atoi+0x1e>
  return n;
}
 386:	60a2                	ld	ra,8(sp)
 388:	6402                	ld	s0,0(sp)
 38a:	0141                	addi	sp,sp,16
 38c:	8082                	ret
  n = 0;
 38e:	4501                	li	a0,0
 390:	bfdd                	j	386 <atoi+0x40>

0000000000000392 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 392:	1141                	addi	sp,sp,-16
 394:	e406                	sd	ra,8(sp)
 396:	e022                	sd	s0,0(sp)
 398:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 39a:	02b57563          	bgeu	a0,a1,3c4 <memmove+0x32>
    while (n-- > 0)
 39e:	00c05f63          	blez	a2,3bc <memmove+0x2a>
 3a2:	1602                	slli	a2,a2,0x20
 3a4:	9201                	srli	a2,a2,0x20
 3a6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3aa:	872a                	mv	a4,a0
      *dst++ = *src++;
 3ac:	0585                	addi	a1,a1,1
 3ae:	0705                	addi	a4,a4,1
 3b0:	fff5c683          	lbu	a3,-1(a1)
 3b4:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 3b8:	fee79ae3          	bne	a5,a4,3ac <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3bc:	60a2                	ld	ra,8(sp)
 3be:	6402                	ld	s0,0(sp)
 3c0:	0141                	addi	sp,sp,16
 3c2:	8082                	ret
    while (n-- > 0)
 3c4:	fec05ce3          	blez	a2,3bc <memmove+0x2a>
    dst += n;
 3c8:	00c50733          	add	a4,a0,a2
    src += n;
 3cc:	95b2                	add	a1,a1,a2
 3ce:	fff6079b          	addiw	a5,a2,-1
 3d2:	1782                	slli	a5,a5,0x20
 3d4:	9381                	srli	a5,a5,0x20
 3d6:	fff7c793          	not	a5,a5
 3da:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3dc:	15fd                	addi	a1,a1,-1
 3de:	177d                	addi	a4,a4,-1
 3e0:	0005c683          	lbu	a3,0(a1)
 3e4:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 3e8:	fef71ae3          	bne	a4,a5,3dc <memmove+0x4a>
 3ec:	bfc1                	j	3bc <memmove+0x2a>

00000000000003ee <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3ee:	1141                	addi	sp,sp,-16
 3f0:	e406                	sd	ra,8(sp)
 3f2:	e022                	sd	s0,0(sp)
 3f4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3f6:	c61d                	beqz	a2,424 <memcmp+0x36>
 3f8:	1602                	slli	a2,a2,0x20
 3fa:	9201                	srli	a2,a2,0x20
 3fc:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 400:	00054783          	lbu	a5,0(a0)
 404:	0005c703          	lbu	a4,0(a1)
 408:	00e79863          	bne	a5,a4,418 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 40c:	0505                	addi	a0,a0,1
    p2++;
 40e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 410:	fed518e3          	bne	a0,a3,400 <memcmp+0x12>
  }
  return 0;
 414:	4501                	li	a0,0
 416:	a019                	j	41c <memcmp+0x2e>
      return *p1 - *p2;
 418:	40e7853b          	subw	a0,a5,a4
}
 41c:	60a2                	ld	ra,8(sp)
 41e:	6402                	ld	s0,0(sp)
 420:	0141                	addi	sp,sp,16
 422:	8082                	ret
  return 0;
 424:	4501                	li	a0,0
 426:	bfdd                	j	41c <memcmp+0x2e>

0000000000000428 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 428:	1141                	addi	sp,sp,-16
 42a:	e406                	sd	ra,8(sp)
 42c:	e022                	sd	s0,0(sp)
 42e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 430:	f63ff0ef          	jal	392 <memmove>
}
 434:	60a2                	ld	ra,8(sp)
 436:	6402                	ld	s0,0(sp)
 438:	0141                	addi	sp,sp,16
 43a:	8082                	ret

000000000000043c <sbrk>:

char *
sbrk(int n)
{
 43c:	1141                	addi	sp,sp,-16
 43e:	e406                	sd	ra,8(sp)
 440:	e022                	sd	s0,0(sp)
 442:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 444:	4585                	li	a1,1
 446:	0b2000ef          	jal	4f8 <sys_sbrk>
}
 44a:	60a2                	ld	ra,8(sp)
 44c:	6402                	ld	s0,0(sp)
 44e:	0141                	addi	sp,sp,16
 450:	8082                	ret

0000000000000452 <sbrklazy>:

char *
sbrklazy(int n)
{
 452:	1141                	addi	sp,sp,-16
 454:	e406                	sd	ra,8(sp)
 456:	e022                	sd	s0,0(sp)
 458:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 45a:	4589                	li	a1,2
 45c:	09c000ef          	jal	4f8 <sys_sbrk>
}
 460:	60a2                	ld	ra,8(sp)
 462:	6402                	ld	s0,0(sp)
 464:	0141                	addi	sp,sp,16
 466:	8082                	ret

0000000000000468 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 468:	4885                	li	a7,1
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <exit>:
.global exit
exit:
 li a7, SYS_exit
 470:	4889                	li	a7,2
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <wait>:
.global wait
wait:
 li a7, SYS_wait
 478:	488d                	li	a7,3
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 480:	4891                	li	a7,4
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <read>:
.global read
read:
 li a7, SYS_read
 488:	4895                	li	a7,5
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <write>:
.global write
write:
 li a7, SYS_write
 490:	48c1                	li	a7,16
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <close>:
.global close
close:
 li a7, SYS_close
 498:	48d5                	li	a7,21
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4a0:	4899                	li	a7,6
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4a8:	489d                	li	a7,7
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <open>:
.global open
open:
 li a7, SYS_open
 4b0:	48bd                	li	a7,15
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4b8:	48c5                	li	a7,17
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4c0:	48c9                	li	a7,18
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4c8:	48a1                	li	a7,8
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <link>:
.global link
link:
 li a7, SYS_link
 4d0:	48cd                	li	a7,19
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4d8:	48d1                	li	a7,20
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4e0:	48a5                	li	a7,9
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4e8:	48a9                	li	a7,10
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4f0:	48ad                	li	a7,11
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4f8:	48b1                	li	a7,12
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <pause>:
.global pause
pause:
 li a7, SYS_pause
 500:	48b5                	li	a7,13
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 508:	48b9                	li	a7,14
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <sync>:
.global sync
sync:
 li a7, SYS_sync
 510:	48d9                	li	a7,22
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <vtop>:
.global vtop
vtop:
 li a7, SYS_vtop
 518:	48dd                	li	a7,23
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 520:	1101                	addi	sp,sp,-32
 522:	ec06                	sd	ra,24(sp)
 524:	e822                	sd	s0,16(sp)
 526:	1000                	addi	s0,sp,32
 528:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 52c:	4605                	li	a2,1
 52e:	fef40593          	addi	a1,s0,-17
 532:	f5fff0ef          	jal	490 <write>
}
 536:	60e2                	ld	ra,24(sp)
 538:	6442                	ld	s0,16(sp)
 53a:	6105                	addi	sp,sp,32
 53c:	8082                	ret

000000000000053e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 53e:	715d                	addi	sp,sp,-80
 540:	e486                	sd	ra,72(sp)
 542:	e0a2                	sd	s0,64(sp)
 544:	f84a                	sd	s2,48(sp)
 546:	f44e                	sd	s3,40(sp)
 548:	0880                	addi	s0,sp,80
 54a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 54c:	c6d1                	beqz	a3,5d8 <printint+0x9a>
 54e:	0805d563          	bgez	a1,5d8 <printint+0x9a>
    neg = 1;
    x = -xx;
 552:	40b005b3          	neg	a1,a1
    neg = 1;
 556:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 558:	fb840993          	addi	s3,s0,-72
  neg = 0;
 55c:	86ce                	mv	a3,s3
  i = 0;
 55e:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 560:	00001817          	auipc	a6,0x1
 564:	86880813          	addi	a6,a6,-1944 # dc8 <digits>
 568:	88ba                	mv	a7,a4
 56a:	0017051b          	addiw	a0,a4,1
 56e:	872a                	mv	a4,a0
 570:	02c5f7b3          	remu	a5,a1,a2
 574:	97c2                	add	a5,a5,a6
 576:	0007c783          	lbu	a5,0(a5)
 57a:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 57e:	87ae                	mv	a5,a1
 580:	02c5d5b3          	divu	a1,a1,a2
 584:	0685                	addi	a3,a3,1
 586:	fec7f1e3          	bgeu	a5,a2,568 <printint+0x2a>
  if (neg)
 58a:	00030c63          	beqz	t1,5a2 <printint+0x64>
    buf[i++] = '-';
 58e:	fd050793          	addi	a5,a0,-48
 592:	00878533          	add	a0,a5,s0
 596:	02d00793          	li	a5,45
 59a:	fef50423          	sb	a5,-24(a0)
 59e:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 5a2:	02e05563          	blez	a4,5cc <printint+0x8e>
 5a6:	fc26                	sd	s1,56(sp)
 5a8:	377d                	addiw	a4,a4,-1
 5aa:	00e984b3          	add	s1,s3,a4
 5ae:	19fd                	addi	s3,s3,-1
 5b0:	99ba                	add	s3,s3,a4
 5b2:	1702                	slli	a4,a4,0x20
 5b4:	9301                	srli	a4,a4,0x20
 5b6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5ba:	0004c583          	lbu	a1,0(s1)
 5be:	854a                	mv	a0,s2
 5c0:	f61ff0ef          	jal	520 <putc>
  while (--i >= 0)
 5c4:	14fd                	addi	s1,s1,-1
 5c6:	ff349ae3          	bne	s1,s3,5ba <printint+0x7c>
 5ca:	74e2                	ld	s1,56(sp)
}
 5cc:	60a6                	ld	ra,72(sp)
 5ce:	6406                	ld	s0,64(sp)
 5d0:	7942                	ld	s2,48(sp)
 5d2:	79a2                	ld	s3,40(sp)
 5d4:	6161                	addi	sp,sp,80
 5d6:	8082                	ret
  neg = 0;
 5d8:	4301                	li	t1,0
 5da:	bfbd                	j	558 <printint+0x1a>

00000000000005dc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5dc:	711d                	addi	sp,sp,-96
 5de:	ec86                	sd	ra,88(sp)
 5e0:	e8a2                	sd	s0,80(sp)
 5e2:	e4a6                	sd	s1,72(sp)
 5e4:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 5e6:	0005c483          	lbu	s1,0(a1)
 5ea:	22048363          	beqz	s1,810 <vprintf+0x234>
 5ee:	e0ca                	sd	s2,64(sp)
 5f0:	fc4e                	sd	s3,56(sp)
 5f2:	f852                	sd	s4,48(sp)
 5f4:	f456                	sd	s5,40(sp)
 5f6:	f05a                	sd	s6,32(sp)
 5f8:	ec5e                	sd	s7,24(sp)
 5fa:	e862                	sd	s8,16(sp)
 5fc:	8b2a                	mv	s6,a0
 5fe:	8a2e                	mv	s4,a1
 600:	8bb2                	mv	s7,a2
  state = 0;
 602:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 604:	4901                	li	s2,0
 606:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 608:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 60c:	06400c13          	li	s8,100
 610:	a00d                	j	632 <vprintf+0x56>
        putc(fd, c0);
 612:	85a6                	mv	a1,s1
 614:	855a                	mv	a0,s6
 616:	f0bff0ef          	jal	520 <putc>
 61a:	a019                	j	620 <vprintf+0x44>
    } else if (state == '%') {
 61c:	03598363          	beq	s3,s5,642 <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 620:	0019079b          	addiw	a5,s2,1
 624:	893e                	mv	s2,a5
 626:	873e                	mv	a4,a5
 628:	97d2                	add	a5,a5,s4
 62a:	0007c483          	lbu	s1,0(a5)
 62e:	1c048a63          	beqz	s1,802 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 632:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 636:	fe0993e3          	bnez	s3,61c <vprintf+0x40>
      if (c0 == '%') {
 63a:	fd579ce3          	bne	a5,s5,612 <vprintf+0x36>
        state = '%';
 63e:	89be                	mv	s3,a5
 640:	b7c5                	j	620 <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 642:	00ea06b3          	add	a3,s4,a4
 646:	0016c603          	lbu	a2,1(a3)
      if (c1)
 64a:	1c060863          	beqz	a2,81a <vprintf+0x23e>
      if (c0 == 'd') {
 64e:	03878763          	beq	a5,s8,67c <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 652:	f9478693          	addi	a3,a5,-108
 656:	0016b693          	seqz	a3,a3
 65a:	f9c60593          	addi	a1,a2,-100
 65e:	e99d                	bnez	a1,694 <vprintf+0xb8>
 660:	ca95                	beqz	a3,694 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 662:	008b8493          	addi	s1,s7,8
 666:	4685                	li	a3,1
 668:	4629                	li	a2,10
 66a:	000bb583          	ld	a1,0(s7)
 66e:	855a                	mv	a0,s6
 670:	ecfff0ef          	jal	53e <printint>
        i += 1;
 674:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 676:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 678:	4981                	li	s3,0
 67a:	b75d                	j	620 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 67c:	008b8493          	addi	s1,s7,8
 680:	4685                	li	a3,1
 682:	4629                	li	a2,10
 684:	000ba583          	lw	a1,0(s7)
 688:	855a                	mv	a0,s6
 68a:	eb5ff0ef          	jal	53e <printint>
 68e:	8ba6                	mv	s7,s1
      state = 0;
 690:	4981                	li	s3,0
 692:	b779                	j	620 <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 694:	9752                	add	a4,a4,s4
 696:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 69a:	f9460713          	addi	a4,a2,-108
 69e:	00173713          	seqz	a4,a4
 6a2:	8f75                	and	a4,a4,a3
 6a4:	f9c58513          	addi	a0,a1,-100
 6a8:	18051363          	bnez	a0,82e <vprintf+0x252>
 6ac:	18070163          	beqz	a4,82e <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6b0:	008b8493          	addi	s1,s7,8
 6b4:	4685                	li	a3,1
 6b6:	4629                	li	a2,10
 6b8:	000bb583          	ld	a1,0(s7)
 6bc:	855a                	mv	a0,s6
 6be:	e81ff0ef          	jal	53e <printint>
        i += 2;
 6c2:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6c4:	8ba6                	mv	s7,s1
      state = 0;
 6c6:	4981                	li	s3,0
        i += 2;
 6c8:	bfa1                	j	620 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6ca:	008b8493          	addi	s1,s7,8
 6ce:	4681                	li	a3,0
 6d0:	4629                	li	a2,10
 6d2:	000be583          	lwu	a1,0(s7)
 6d6:	855a                	mv	a0,s6
 6d8:	e67ff0ef          	jal	53e <printint>
 6dc:	8ba6                	mv	s7,s1
      state = 0;
 6de:	4981                	li	s3,0
 6e0:	b781                	j	620 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e2:	008b8493          	addi	s1,s7,8
 6e6:	4681                	li	a3,0
 6e8:	4629                	li	a2,10
 6ea:	000bb583          	ld	a1,0(s7)
 6ee:	855a                	mv	a0,s6
 6f0:	e4fff0ef          	jal	53e <printint>
        i += 1;
 6f4:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f6:	8ba6                	mv	s7,s1
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	b71d                	j	620 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6fc:	008b8493          	addi	s1,s7,8
 700:	4681                	li	a3,0
 702:	4629                	li	a2,10
 704:	000bb583          	ld	a1,0(s7)
 708:	855a                	mv	a0,s6
 70a:	e35ff0ef          	jal	53e <printint>
        i += 2;
 70e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 710:	8ba6                	mv	s7,s1
      state = 0;
 712:	4981                	li	s3,0
        i += 2;
 714:	b731                	j	620 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 716:	008b8493          	addi	s1,s7,8
 71a:	4681                	li	a3,0
 71c:	4641                	li	a2,16
 71e:	000be583          	lwu	a1,0(s7)
 722:	855a                	mv	a0,s6
 724:	e1bff0ef          	jal	53e <printint>
 728:	8ba6                	mv	s7,s1
      state = 0;
 72a:	4981                	li	s3,0
 72c:	bdd5                	j	620 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 72e:	008b8493          	addi	s1,s7,8
 732:	4681                	li	a3,0
 734:	4641                	li	a2,16
 736:	000bb583          	ld	a1,0(s7)
 73a:	855a                	mv	a0,s6
 73c:	e03ff0ef          	jal	53e <printint>
        i += 1;
 740:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 742:	8ba6                	mv	s7,s1
      state = 0;
 744:	4981                	li	s3,0
 746:	bde9                	j	620 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 748:	008b8493          	addi	s1,s7,8
 74c:	4681                	li	a3,0
 74e:	4641                	li	a2,16
 750:	000bb583          	ld	a1,0(s7)
 754:	855a                	mv	a0,s6
 756:	de9ff0ef          	jal	53e <printint>
        i += 2;
 75a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 75c:	8ba6                	mv	s7,s1
      state = 0;
 75e:	4981                	li	s3,0
        i += 2;
 760:	b5c1                	j	620 <vprintf+0x44>
 762:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 764:	008b8793          	addi	a5,s7,8
 768:	8cbe                	mv	s9,a5
 76a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 76e:	03000593          	li	a1,48
 772:	855a                	mv	a0,s6
 774:	dadff0ef          	jal	520 <putc>
  putc(fd, 'x');
 778:	07800593          	li	a1,120
 77c:	855a                	mv	a0,s6
 77e:	da3ff0ef          	jal	520 <putc>
 782:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 784:	00000b97          	auipc	s7,0x0
 788:	644b8b93          	addi	s7,s7,1604 # dc8 <digits>
 78c:	03c9d793          	srli	a5,s3,0x3c
 790:	97de                	add	a5,a5,s7
 792:	0007c583          	lbu	a1,0(a5)
 796:	855a                	mv	a0,s6
 798:	d89ff0ef          	jal	520 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 79c:	0992                	slli	s3,s3,0x4
 79e:	34fd                	addiw	s1,s1,-1
 7a0:	f4f5                	bnez	s1,78c <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 7a2:	8be6                	mv	s7,s9
      state = 0;
 7a4:	4981                	li	s3,0
 7a6:	6ca2                	ld	s9,8(sp)
 7a8:	bda5                	j	620 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 7aa:	008b8493          	addi	s1,s7,8
 7ae:	000bc583          	lbu	a1,0(s7)
 7b2:	855a                	mv	a0,s6
 7b4:	d6dff0ef          	jal	520 <putc>
 7b8:	8ba6                	mv	s7,s1
      state = 0;
 7ba:	4981                	li	s3,0
 7bc:	b595                	j	620 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 7be:	008b8993          	addi	s3,s7,8
 7c2:	000bb483          	ld	s1,0(s7)
 7c6:	cc91                	beqz	s1,7e2 <vprintf+0x206>
        for (; *s; s++)
 7c8:	0004c583          	lbu	a1,0(s1)
 7cc:	c985                	beqz	a1,7fc <vprintf+0x220>
          putc(fd, *s);
 7ce:	855a                	mv	a0,s6
 7d0:	d51ff0ef          	jal	520 <putc>
        for (; *s; s++)
 7d4:	0485                	addi	s1,s1,1
 7d6:	0004c583          	lbu	a1,0(s1)
 7da:	f9f5                	bnez	a1,7ce <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 7dc:	8bce                	mv	s7,s3
      state = 0;
 7de:	4981                	li	s3,0
 7e0:	b581                	j	620 <vprintf+0x44>
          s = "(null)";
 7e2:	00000497          	auipc	s1,0x0
 7e6:	5de48493          	addi	s1,s1,1502 # dc0 <malloc+0x442>
        for (; *s; s++)
 7ea:	02800593          	li	a1,40
 7ee:	b7c5                	j	7ce <vprintf+0x1f2>
        putc(fd, '%');
 7f0:	85be                	mv	a1,a5
 7f2:	855a                	mv	a0,s6
 7f4:	d2dff0ef          	jal	520 <putc>
      state = 0;
 7f8:	4981                	li	s3,0
 7fa:	b51d                	j	620 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 7fc:	8bce                	mv	s7,s3
      state = 0;
 7fe:	4981                	li	s3,0
 800:	b505                	j	620 <vprintf+0x44>
 802:	6906                	ld	s2,64(sp)
 804:	79e2                	ld	s3,56(sp)
 806:	7a42                	ld	s4,48(sp)
 808:	7aa2                	ld	s5,40(sp)
 80a:	7b02                	ld	s6,32(sp)
 80c:	6be2                	ld	s7,24(sp)
 80e:	6c42                	ld	s8,16(sp)
    }
  }
}
 810:	60e6                	ld	ra,88(sp)
 812:	6446                	ld	s0,80(sp)
 814:	64a6                	ld	s1,72(sp)
 816:	6125                	addi	sp,sp,96
 818:	8082                	ret
      if (c0 == 'd') {
 81a:	06400713          	li	a4,100
 81e:	e4e78fe3          	beq	a5,a4,67c <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 822:	f9478693          	addi	a3,a5,-108
 826:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 82a:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 82c:	4701                	li	a4,0
      } else if (c0 == 'u') {
 82e:	07500513          	li	a0,117
 832:	e8a78ce3          	beq	a5,a0,6ca <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 836:	f8b60513          	addi	a0,a2,-117
 83a:	e119                	bnez	a0,840 <vprintf+0x264>
 83c:	ea0693e3          	bnez	a3,6e2 <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 840:	f8b58513          	addi	a0,a1,-117
 844:	e119                	bnez	a0,84a <vprintf+0x26e>
 846:	ea071be3          	bnez	a4,6fc <vprintf+0x120>
      } else if (c0 == 'x') {
 84a:	07800513          	li	a0,120
 84e:	eca784e3          	beq	a5,a0,716 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 852:	f8860613          	addi	a2,a2,-120
 856:	e219                	bnez	a2,85c <vprintf+0x280>
 858:	ec069be3          	bnez	a3,72e <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 85c:	f8858593          	addi	a1,a1,-120
 860:	e199                	bnez	a1,866 <vprintf+0x28a>
 862:	ee0713e3          	bnez	a4,748 <vprintf+0x16c>
      } else if (c0 == 'p') {
 866:	07000713          	li	a4,112
 86a:	eee78ce3          	beq	a5,a4,762 <vprintf+0x186>
      } else if (c0 == 'c') {
 86e:	06300713          	li	a4,99
 872:	f2e78ce3          	beq	a5,a4,7aa <vprintf+0x1ce>
      } else if (c0 == 's') {
 876:	07300713          	li	a4,115
 87a:	f4e782e3          	beq	a5,a4,7be <vprintf+0x1e2>
      } else if (c0 == '%') {
 87e:	02500713          	li	a4,37
 882:	f6e787e3          	beq	a5,a4,7f0 <vprintf+0x214>
        putc(fd, '%');
 886:	02500593          	li	a1,37
 88a:	855a                	mv	a0,s6
 88c:	c95ff0ef          	jal	520 <putc>
        putc(fd, c0);
 890:	85a6                	mv	a1,s1
 892:	855a                	mv	a0,s6
 894:	c8dff0ef          	jal	520 <putc>
      state = 0;
 898:	4981                	li	s3,0
 89a:	b359                	j	620 <vprintf+0x44>

000000000000089c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 89c:	715d                	addi	sp,sp,-80
 89e:	ec06                	sd	ra,24(sp)
 8a0:	e822                	sd	s0,16(sp)
 8a2:	1000                	addi	s0,sp,32
 8a4:	e010                	sd	a2,0(s0)
 8a6:	e414                	sd	a3,8(s0)
 8a8:	e818                	sd	a4,16(s0)
 8aa:	ec1c                	sd	a5,24(s0)
 8ac:	03043023          	sd	a6,32(s0)
 8b0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8b4:	8622                	mv	a2,s0
 8b6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8ba:	d23ff0ef          	jal	5dc <vprintf>
}
 8be:	60e2                	ld	ra,24(sp)
 8c0:	6442                	ld	s0,16(sp)
 8c2:	6161                	addi	sp,sp,80
 8c4:	8082                	ret

00000000000008c6 <printf>:

void
printf(const char *fmt, ...)
{
 8c6:	711d                	addi	sp,sp,-96
 8c8:	ec06                	sd	ra,24(sp)
 8ca:	e822                	sd	s0,16(sp)
 8cc:	1000                	addi	s0,sp,32
 8ce:	e40c                	sd	a1,8(s0)
 8d0:	e810                	sd	a2,16(s0)
 8d2:	ec14                	sd	a3,24(s0)
 8d4:	f018                	sd	a4,32(s0)
 8d6:	f41c                	sd	a5,40(s0)
 8d8:	03043823          	sd	a6,48(s0)
 8dc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8e0:	00840613          	addi	a2,s0,8
 8e4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8e8:	85aa                	mv	a1,a0
 8ea:	4505                	li	a0,1
 8ec:	cf1ff0ef          	jal	5dc <vprintf>
}
 8f0:	60e2                	ld	ra,24(sp)
 8f2:	6442                	ld	s0,16(sp)
 8f4:	6125                	addi	sp,sp,96
 8f6:	8082                	ret

00000000000008f8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8f8:	1141                	addi	sp,sp,-16
 8fa:	e406                	sd	ra,8(sp)
 8fc:	e022                	sd	s0,0(sp)
 8fe:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 900:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 904:	00001797          	auipc	a5,0x1
 908:	70c7b783          	ld	a5,1804(a5) # 2010 <freep>
 90c:	a039                	j	91a <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 90e:	6398                	ld	a4,0(a5)
 910:	00e7e463          	bltu	a5,a4,918 <free+0x20>
 914:	00e6ea63          	bltu	a3,a4,928 <free+0x30>
{
 918:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 91a:	fed7fae3          	bgeu	a5,a3,90e <free+0x16>
 91e:	6398                	ld	a4,0(a5)
 920:	00e6e463          	bltu	a3,a4,928 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 924:	fee7eae3          	bltu	a5,a4,918 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 928:	ff852583          	lw	a1,-8(a0)
 92c:	6390                	ld	a2,0(a5)
 92e:	02059813          	slli	a6,a1,0x20
 932:	01c85713          	srli	a4,a6,0x1c
 936:	9736                	add	a4,a4,a3
 938:	02e60563          	beq	a2,a4,962 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 93c:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 940:	4790                	lw	a2,8(a5)
 942:	02061593          	slli	a1,a2,0x20
 946:	01c5d713          	srli	a4,a1,0x1c
 94a:	973e                	add	a4,a4,a5
 94c:	02e68263          	beq	a3,a4,970 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 950:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 952:	00001717          	auipc	a4,0x1
 956:	6af73f23          	sd	a5,1726(a4) # 2010 <freep>
}
 95a:	60a2                	ld	ra,8(sp)
 95c:	6402                	ld	s0,0(sp)
 95e:	0141                	addi	sp,sp,16
 960:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 962:	4618                	lw	a4,8(a2)
 964:	9f2d                	addw	a4,a4,a1
 966:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 96a:	6398                	ld	a4,0(a5)
 96c:	6310                	ld	a2,0(a4)
 96e:	b7f9                	j	93c <free+0x44>
    p->s.size += bp->s.size;
 970:	ff852703          	lw	a4,-8(a0)
 974:	9f31                	addw	a4,a4,a2
 976:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 978:	ff053683          	ld	a3,-16(a0)
 97c:	bfd1                	j	950 <free+0x58>

000000000000097e <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 97e:	7139                	addi	sp,sp,-64
 980:	fc06                	sd	ra,56(sp)
 982:	f822                	sd	s0,48(sp)
 984:	f04a                	sd	s2,32(sp)
 986:	ec4e                	sd	s3,24(sp)
 988:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 98a:	02051993          	slli	s3,a0,0x20
 98e:	0209d993          	srli	s3,s3,0x20
 992:	09bd                	addi	s3,s3,15
 994:	0049d993          	srli	s3,s3,0x4
 998:	2985                	addiw	s3,s3,1
 99a:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 99c:	00001517          	auipc	a0,0x1
 9a0:	67453503          	ld	a0,1652(a0) # 2010 <freep>
 9a4:	c905                	beqz	a0,9d4 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 9a6:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 9a8:	4798                	lw	a4,8(a5)
 9aa:	09377663          	bgeu	a4,s3,a36 <malloc+0xb8>
 9ae:	f426                	sd	s1,40(sp)
 9b0:	e852                	sd	s4,16(sp)
 9b2:	e456                	sd	s5,8(sp)
 9b4:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 9b6:	8a4e                	mv	s4,s3
 9b8:	6705                	lui	a4,0x1
 9ba:	00e9f363          	bgeu	s3,a4,9c0 <malloc+0x42>
 9be:	6a05                	lui	s4,0x1
 9c0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9c4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 9c8:	00001497          	auipc	s1,0x1
 9cc:	64848493          	addi	s1,s1,1608 # 2010 <freep>
  if (p == SBRK_ERROR)
 9d0:	5afd                	li	s5,-1
 9d2:	a83d                	j	a10 <malloc+0x92>
 9d4:	f426                	sd	s1,40(sp)
 9d6:	e852                	sd	s4,16(sp)
 9d8:	e456                	sd	s5,8(sp)
 9da:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9dc:	00001797          	auipc	a5,0x1
 9e0:	64478793          	addi	a5,a5,1604 # 2020 <base>
 9e4:	00001717          	auipc	a4,0x1
 9e8:	62f73623          	sd	a5,1580(a4) # 2010 <freep>
 9ec:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9ee:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 9f2:	b7d1                	j	9b6 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 9f4:	6398                	ld	a4,0(a5)
 9f6:	e118                	sd	a4,0(a0)
 9f8:	a899                	j	a4e <malloc+0xd0>
  hp->s.size = nu;
 9fa:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 9fe:	0541                	addi	a0,a0,16
 a00:	ef9ff0ef          	jal	8f8 <free>
  return freep;
 a04:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 a06:	c125                	beqz	a0,a66 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 a08:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 a0a:	4798                	lw	a4,8(a5)
 a0c:	03277163          	bgeu	a4,s2,a2e <malloc+0xb0>
    if (p == freep)
 a10:	6098                	ld	a4,0(s1)
 a12:	853e                	mv	a0,a5
 a14:	fef71ae3          	bne	a4,a5,a08 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 a18:	8552                	mv	a0,s4
 a1a:	a23ff0ef          	jal	43c <sbrk>
  if (p == SBRK_ERROR)
 a1e:	fd551ee3          	bne	a0,s5,9fa <malloc+0x7c>
        return 0;
 a22:	4501                	li	a0,0
 a24:	74a2                	ld	s1,40(sp)
 a26:	6a42                	ld	s4,16(sp)
 a28:	6aa2                	ld	s5,8(sp)
 a2a:	6b02                	ld	s6,0(sp)
 a2c:	a03d                	j	a5a <malloc+0xdc>
 a2e:	74a2                	ld	s1,40(sp)
 a30:	6a42                	ld	s4,16(sp)
 a32:	6aa2                	ld	s5,8(sp)
 a34:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 a36:	fae90fe3          	beq	s2,a4,9f4 <malloc+0x76>
        p->s.size -= nunits;
 a3a:	4137073b          	subw	a4,a4,s3
 a3e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a40:	02071693          	slli	a3,a4,0x20
 a44:	01c6d713          	srli	a4,a3,0x1c
 a48:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a4a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a4e:	00001717          	auipc	a4,0x1
 a52:	5ca73123          	sd	a0,1474(a4) # 2010 <freep>
      return (void *)(p + 1);
 a56:	01078513          	addi	a0,a5,16
  }
}
 a5a:	70e2                	ld	ra,56(sp)
 a5c:	7442                	ld	s0,48(sp)
 a5e:	7902                	ld	s2,32(sp)
 a60:	69e2                	ld	s3,24(sp)
 a62:	6121                	addi	sp,sp,64
 a64:	8082                	ret
 a66:	74a2                	ld	s1,40(sp)
 a68:	6a42                	ld	s4,16(sp)
 a6a:	6aa2                	ld	s5,8(sp)
 a6c:	6b02                	ld	s6,0(sp)
 a6e:	b7f5                	j	a5a <malloc+0xdc>
