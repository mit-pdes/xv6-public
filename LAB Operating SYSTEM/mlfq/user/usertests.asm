
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	711d                	addi	sp,sp,-96
       2:	ec86                	sd	ra,88(sp)
       4:	e8a2                	sd	s0,80(sp)
       6:	e4a6                	sd	s1,72(sp)
       8:	e0ca                	sd	s2,64(sp)
       a:	fc4e                	sd	s3,56(sp)
       c:	f852                	sd	s4,48(sp)
       e:	1080                	addi	s0,sp,96
  uint64 addrs[] = {0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
      10:	00009797          	auipc	a5,0x9
      14:	90078793          	addi	a5,a5,-1792 # 8910 <malloc+0x2ae8>
      18:	638c                	ld	a1,0(a5)
      1a:	6790                	ld	a2,8(a5)
      1c:	6b94                	ld	a3,16(a5)
      1e:	6f98                	ld	a4,24(a5)
      20:	fab43423          	sd	a1,-88(s0)
      24:	fac43823          	sd	a2,-80(s0)
      28:	fad43c23          	sd	a3,-72(s0)
      2c:	fce43023          	sd	a4,-64(s0)
      30:	739c                	ld	a5,32(a5)
      32:	fcf43423          	sd	a5,-56(s0)
                    0xffffffffffffffff};

  for (int ai = 0; ai < sizeof(addrs) / sizeof(addrs[0]); ai++) {
      36:	fa840493          	addi	s1,s0,-88
      3a:	fd040a13          	addi	s4,s0,-48
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE | O_WRONLY);
      3e:	20100993          	li	s3,513
      42:	0004b903          	ld	s2,0(s1)
      46:	85ce                	mv	a1,s3
      48:	854a                	mv	a0,s2
      4a:	111050ef          	jal	595a <open>
    if (fd >= 0) {
      4e:	00055d63          	bgez	a0,68 <copyinstr1+0x68>
  for (int ai = 0; ai < sizeof(addrs) / sizeof(addrs[0]); ai++) {
      52:	04a1                	addi	s1,s1,8
      54:	ff4497e3          	bne	s1,s4,42 <copyinstr1+0x42>
      printf("open(%p) returned %d, not -1\n", (void *)addr, fd);
      exit(1);
    }
  }
}
      58:	60e6                	ld	ra,88(sp)
      5a:	6446                	ld	s0,80(sp)
      5c:	64a6                	ld	s1,72(sp)
      5e:	6906                	ld	s2,64(sp)
      60:	79e2                	ld	s3,56(sp)
      62:	7a42                	ld	s4,48(sp)
      64:	6125                	addi	sp,sp,96
      66:	8082                	ret
      printf("open(%p) returned %d, not -1\n", (void *)addr, fd);
      68:	862a                	mv	a2,a0
      6a:	85ca                	mv	a1,s2
      6c:	00006517          	auipc	a0,0x6
      70:	eb450513          	addi	a0,a0,-332 # 5f20 <malloc+0xf8>
      74:	4fd050ef          	jal	5d70 <printf>
      exit(1);
      78:	4505                	li	a0,1
      7a:	0a1050ef          	jal	591a <exit>

000000000000007e <bsstest>:
void
bsstest(char *s)
{
  int i;

  for (i = 0; i < sizeof(uninit); i++) {
      7e:	0000c797          	auipc	a5,0xc
      82:	57a78793          	addi	a5,a5,1402 # c5f8 <uninit>
      86:	0000f697          	auipc	a3,0xf
      8a:	c8268693          	addi	a3,a3,-894 # ed08 <buf>
    if (uninit[i] != '\0') {
      8e:	0007c703          	lbu	a4,0(a5)
      92:	e709                	bnez	a4,9c <bsstest+0x1e>
  for (i = 0; i < sizeof(uninit); i++) {
      94:	0785                	addi	a5,a5,1
      96:	fed79ce3          	bne	a5,a3,8e <bsstest+0x10>
      9a:	8082                	ret
{
      9c:	1141                	addi	sp,sp,-16
      9e:	e406                	sd	ra,8(sp)
      a0:	e022                	sd	s0,0(sp)
      a2:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      a4:	85aa                	mv	a1,a0
      a6:	00006517          	auipc	a0,0x6
      aa:	e9a50513          	addi	a0,a0,-358 # 5f40 <malloc+0x118>
      ae:	4c3050ef          	jal	5d70 <printf>
      exit(1);
      b2:	4505                	li	a0,1
      b4:	067050ef          	jal	591a <exit>

00000000000000b8 <opentest>:
{
      b8:	1101                	addi	sp,sp,-32
      ba:	ec06                	sd	ra,24(sp)
      bc:	e822                	sd	s0,16(sp)
      be:	e426                	sd	s1,8(sp)
      c0:	1000                	addi	s0,sp,32
      c2:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      c4:	4581                	li	a1,0
      c6:	00006517          	auipc	a0,0x6
      ca:	e9250513          	addi	a0,a0,-366 # 5f58 <malloc+0x130>
      ce:	08d050ef          	jal	595a <open>
  if (fd < 0) {
      d2:	02054263          	bltz	a0,f6 <opentest+0x3e>
  close(fd);
      d6:	06d050ef          	jal	5942 <close>
  fd = open("doesnotexist", 0);
      da:	4581                	li	a1,0
      dc:	00006517          	auipc	a0,0x6
      e0:	e9c50513          	addi	a0,a0,-356 # 5f78 <malloc+0x150>
      e4:	077050ef          	jal	595a <open>
  if (fd >= 0) {
      e8:	02055163          	bgez	a0,10a <opentest+0x52>
}
      ec:	60e2                	ld	ra,24(sp)
      ee:	6442                	ld	s0,16(sp)
      f0:	64a2                	ld	s1,8(sp)
      f2:	6105                	addi	sp,sp,32
      f4:	8082                	ret
    printf("%s: open echo failed!\n", s);
      f6:	85a6                	mv	a1,s1
      f8:	00006517          	auipc	a0,0x6
      fc:	e6850513          	addi	a0,a0,-408 # 5f60 <malloc+0x138>
     100:	471050ef          	jal	5d70 <printf>
    exit(1);
     104:	4505                	li	a0,1
     106:	015050ef          	jal	591a <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     10a:	85a6                	mv	a1,s1
     10c:	00006517          	auipc	a0,0x6
     110:	e7c50513          	addi	a0,a0,-388 # 5f88 <malloc+0x160>
     114:	45d050ef          	jal	5d70 <printf>
    exit(1);
     118:	4505                	li	a0,1
     11a:	001050ef          	jal	591a <exit>

000000000000011e <truncate2>:
{
     11e:	7179                	addi	sp,sp,-48
     120:	f406                	sd	ra,40(sp)
     122:	f022                	sd	s0,32(sp)
     124:	ec26                	sd	s1,24(sp)
     126:	e84a                	sd	s2,16(sp)
     128:	e44e                	sd	s3,8(sp)
     12a:	1800                	addi	s0,sp,48
     12c:	89aa                	mv	s3,a0
  unlink("truncfile");
     12e:	00006517          	auipc	a0,0x6
     132:	e8250513          	addi	a0,a0,-382 # 5fb0 <malloc+0x188>
     136:	035050ef          	jal	596a <unlink>
  int fd1 = open("truncfile", O_CREATE | O_TRUNC | O_WRONLY);
     13a:	60100593          	li	a1,1537
     13e:	00006517          	auipc	a0,0x6
     142:	e7250513          	addi	a0,a0,-398 # 5fb0 <malloc+0x188>
     146:	015050ef          	jal	595a <open>
     14a:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     14c:	4611                	li	a2,4
     14e:	00006597          	auipc	a1,0x6
     152:	e7258593          	addi	a1,a1,-398 # 5fc0 <malloc+0x198>
     156:	7e4050ef          	jal	593a <write>
  int fd2 = open("truncfile", O_TRUNC | O_WRONLY);
     15a:	40100593          	li	a1,1025
     15e:	00006517          	auipc	a0,0x6
     162:	e5250513          	addi	a0,a0,-430 # 5fb0 <malloc+0x188>
     166:	7f4050ef          	jal	595a <open>
     16a:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     16c:	4605                	li	a2,1
     16e:	00006597          	auipc	a1,0x6
     172:	e5a58593          	addi	a1,a1,-422 # 5fc8 <malloc+0x1a0>
     176:	8526                	mv	a0,s1
     178:	7c2050ef          	jal	593a <write>
  if (n != -1) {
     17c:	57fd                	li	a5,-1
     17e:	02f51563          	bne	a0,a5,1a8 <truncate2+0x8a>
  unlink("truncfile");
     182:	00006517          	auipc	a0,0x6
     186:	e2e50513          	addi	a0,a0,-466 # 5fb0 <malloc+0x188>
     18a:	7e0050ef          	jal	596a <unlink>
  close(fd1);
     18e:	8526                	mv	a0,s1
     190:	7b2050ef          	jal	5942 <close>
  close(fd2);
     194:	854a                	mv	a0,s2
     196:	7ac050ef          	jal	5942 <close>
}
     19a:	70a2                	ld	ra,40(sp)
     19c:	7402                	ld	s0,32(sp)
     19e:	64e2                	ld	s1,24(sp)
     1a0:	6942                	ld	s2,16(sp)
     1a2:	69a2                	ld	s3,8(sp)
     1a4:	6145                	addi	sp,sp,48
     1a6:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1a8:	862a                	mv	a2,a0
     1aa:	85ce                	mv	a1,s3
     1ac:	00006517          	auipc	a0,0x6
     1b0:	e2450513          	addi	a0,a0,-476 # 5fd0 <malloc+0x1a8>
     1b4:	3bd050ef          	jal	5d70 <printf>
    exit(1);
     1b8:	4505                	li	a0,1
     1ba:	760050ef          	jal	591a <exit>

00000000000001be <createtest>:
{
     1be:	7139                	addi	sp,sp,-64
     1c0:	fc06                	sd	ra,56(sp)
     1c2:	f822                	sd	s0,48(sp)
     1c4:	f426                	sd	s1,40(sp)
     1c6:	f04a                	sd	s2,32(sp)
     1c8:	ec4e                	sd	s3,24(sp)
     1ca:	e852                	sd	s4,16(sp)
     1cc:	0080                	addi	s0,sp,64
  name[0] = 'a';
     1ce:	06100793          	li	a5,97
     1d2:	fcf40423          	sb	a5,-56(s0)
  name[2] = '\0';
     1d6:	fc040523          	sb	zero,-54(s0)
     1da:	03000493          	li	s1,48
    fd = open(name, O_CREATE | O_RDWR);
     1de:	fc840a13          	addi	s4,s0,-56
     1e2:	20200993          	li	s3,514
  for (i = 0; i < N; i++) {
     1e6:	06400913          	li	s2,100
    name[1] = '0' + i;
     1ea:	fc9404a3          	sb	s1,-55(s0)
    fd = open(name, O_CREATE | O_RDWR);
     1ee:	85ce                	mv	a1,s3
     1f0:	8552                	mv	a0,s4
     1f2:	768050ef          	jal	595a <open>
    close(fd);
     1f6:	74c050ef          	jal	5942 <close>
  for (i = 0; i < N; i++) {
     1fa:	2485                	addiw	s1,s1,1
     1fc:	0ff4f493          	zext.b	s1,s1
     200:	ff2495e3          	bne	s1,s2,1ea <createtest+0x2c>
  name[0] = 'a';
     204:	06100793          	li	a5,97
     208:	fcf40423          	sb	a5,-56(s0)
  name[2] = '\0';
     20c:	fc040523          	sb	zero,-54(s0)
     210:	03000493          	li	s1,48
    unlink(name);
     214:	fc840993          	addi	s3,s0,-56
  for (i = 0; i < N; i++) {
     218:	06400913          	li	s2,100
    name[1] = '0' + i;
     21c:	fc9404a3          	sb	s1,-55(s0)
    unlink(name);
     220:	854e                	mv	a0,s3
     222:	748050ef          	jal	596a <unlink>
  for (i = 0; i < N; i++) {
     226:	2485                	addiw	s1,s1,1
     228:	0ff4f493          	zext.b	s1,s1
     22c:	ff2498e3          	bne	s1,s2,21c <createtest+0x5e>
}
     230:	70e2                	ld	ra,56(sp)
     232:	7442                	ld	s0,48(sp)
     234:	74a2                	ld	s1,40(sp)
     236:	7902                	ld	s2,32(sp)
     238:	69e2                	ld	s3,24(sp)
     23a:	6a42                	ld	s4,16(sp)
     23c:	6121                	addi	sp,sp,64
     23e:	8082                	ret

0000000000000240 <bigwrite>:
{
     240:	711d                	addi	sp,sp,-96
     242:	ec86                	sd	ra,88(sp)
     244:	e8a2                	sd	s0,80(sp)
     246:	e4a6                	sd	s1,72(sp)
     248:	e0ca                	sd	s2,64(sp)
     24a:	fc4e                	sd	s3,56(sp)
     24c:	f852                	sd	s4,48(sp)
     24e:	f456                	sd	s5,40(sp)
     250:	f05a                	sd	s6,32(sp)
     252:	ec5e                	sd	s7,24(sp)
     254:	e862                	sd	s8,16(sp)
     256:	e466                	sd	s9,8(sp)
     258:	1080                	addi	s0,sp,96
     25a:	8caa                	mv	s9,a0
  unlink("bigwrite");
     25c:	00006517          	auipc	a0,0x6
     260:	d9c50513          	addi	a0,a0,-612 # 5ff8 <malloc+0x1d0>
     264:	706050ef          	jal	596a <unlink>
  for (sz = 499; sz < (MAXOPBLOCKS + 2) * BSIZE; sz += 471) {
     268:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     26c:	20200b93          	li	s7,514
     270:	00006a17          	auipc	s4,0x6
     274:	d88a0a13          	addi	s4,s4,-632 # 5ff8 <malloc+0x1d0>
     278:	4b09                	li	s6,2
      int cc = write(fd, buf, sz);
     27a:	0000f997          	auipc	s3,0xf
     27e:	a8e98993          	addi	s3,s3,-1394 # ed08 <buf>
  for (sz = 499; sz < (MAXOPBLOCKS + 2) * BSIZE; sz += 471) {
     282:	6a8d                	lui	s5,0x3
     284:	1c9a8a93          	addi	s5,s5,457 # 31c9 <rmdot+0x51>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     288:	85de                	mv	a1,s7
     28a:	8552                	mv	a0,s4
     28c:	6ce050ef          	jal	595a <open>
     290:	892a                	mv	s2,a0
    if (fd < 0) {
     292:	04054463          	bltz	a0,2da <bigwrite+0x9a>
     296:	8c5a                	mv	s8,s6
      int cc = write(fd, buf, sz);
     298:	8626                	mv	a2,s1
     29a:	85ce                	mv	a1,s3
     29c:	854a                	mv	a0,s2
     29e:	69c050ef          	jal	593a <write>
      if (cc != sz) {
     2a2:	04951663          	bne	a0,s1,2ee <bigwrite+0xae>
    for (i = 0; i < 2; i++) {
     2a6:	3c7d                	addiw	s8,s8,-1
     2a8:	fe0c18e3          	bnez	s8,298 <bigwrite+0x58>
    close(fd);
     2ac:	854a                	mv	a0,s2
     2ae:	694050ef          	jal	5942 <close>
    unlink("bigwrite");
     2b2:	8552                	mv	a0,s4
     2b4:	6b6050ef          	jal	596a <unlink>
  for (sz = 499; sz < (MAXOPBLOCKS + 2) * BSIZE; sz += 471) {
     2b8:	1d74849b          	addiw	s1,s1,471
     2bc:	fd5496e3          	bne	s1,s5,288 <bigwrite+0x48>
}
     2c0:	60e6                	ld	ra,88(sp)
     2c2:	6446                	ld	s0,80(sp)
     2c4:	64a6                	ld	s1,72(sp)
     2c6:	6906                	ld	s2,64(sp)
     2c8:	79e2                	ld	s3,56(sp)
     2ca:	7a42                	ld	s4,48(sp)
     2cc:	7aa2                	ld	s5,40(sp)
     2ce:	7b02                	ld	s6,32(sp)
     2d0:	6be2                	ld	s7,24(sp)
     2d2:	6c42                	ld	s8,16(sp)
     2d4:	6ca2                	ld	s9,8(sp)
     2d6:	6125                	addi	sp,sp,96
     2d8:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     2da:	85e6                	mv	a1,s9
     2dc:	00006517          	auipc	a0,0x6
     2e0:	d2c50513          	addi	a0,a0,-724 # 6008 <malloc+0x1e0>
     2e4:	28d050ef          	jal	5d70 <printf>
      exit(1);
     2e8:	4505                	li	a0,1
     2ea:	630050ef          	jal	591a <exit>
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     2ee:	86aa                	mv	a3,a0
     2f0:	8626                	mv	a2,s1
     2f2:	85e6                	mv	a1,s9
     2f4:	00006517          	auipc	a0,0x6
     2f8:	d3450513          	addi	a0,a0,-716 # 6028 <malloc+0x200>
     2fc:	275050ef          	jal	5d70 <printf>
        exit(1);
     300:	4505                	li	a0,1
     302:	618050ef          	jal	591a <exit>

0000000000000306 <badwrite>:
// file is deleted? if the kernel has this bug, it will panic: balloc:
// out of blocks. assumed_free may need to be raised to be more than
// the number of free blocks. this test takes a long time.
void
badwrite(char *s)
{
     306:	7139                	addi	sp,sp,-64
     308:	fc06                	sd	ra,56(sp)
     30a:	f822                	sd	s0,48(sp)
     30c:	f426                	sd	s1,40(sp)
     30e:	f04a                	sd	s2,32(sp)
     310:	ec4e                	sd	s3,24(sp)
     312:	e852                	sd	s4,16(sp)
     314:	e456                	sd	s5,8(sp)
     316:	e05a                	sd	s6,0(sp)
     318:	0080                	addi	s0,sp,64
  int assumed_free = 600;

  unlink("junk");
     31a:	00006517          	auipc	a0,0x6
     31e:	d2650513          	addi	a0,a0,-730 # 6040 <malloc+0x218>
     322:	648050ef          	jal	596a <unlink>
     326:	25800913          	li	s2,600
  for (int i = 0; i < assumed_free; i++) {
    int fd = open("junk", O_CREATE | O_WRONLY);
     32a:	20100a93          	li	s5,513
     32e:	00006997          	auipc	s3,0x6
     332:	d1298993          	addi	s3,s3,-750 # 6040 <malloc+0x218>
    if (fd < 0) {
      printf("open junk failed\n");
      exit(1);
    }
    write(fd, (char *)0xffffffffffL, 1);
     336:	4b05                	li	s6,1
     338:	5a7d                	li	s4,-1
     33a:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE | O_WRONLY);
     33e:	85d6                	mv	a1,s5
     340:	854e                	mv	a0,s3
     342:	618050ef          	jal	595a <open>
     346:	84aa                	mv	s1,a0
    if (fd < 0) {
     348:	04054d63          	bltz	a0,3a2 <badwrite+0x9c>
    write(fd, (char *)0xffffffffffL, 1);
     34c:	865a                	mv	a2,s6
     34e:	85d2                	mv	a1,s4
     350:	5ea050ef          	jal	593a <write>
    close(fd);
     354:	8526                	mv	a0,s1
     356:	5ec050ef          	jal	5942 <close>
    unlink("junk");
     35a:	854e                	mv	a0,s3
     35c:	60e050ef          	jal	596a <unlink>
  for (int i = 0; i < assumed_free; i++) {
     360:	397d                	addiw	s2,s2,-1
     362:	fc091ee3          	bnez	s2,33e <badwrite+0x38>
  }

  int fd = open("junk", O_CREATE | O_WRONLY);
     366:	20100593          	li	a1,513
     36a:	00006517          	auipc	a0,0x6
     36e:	cd650513          	addi	a0,a0,-810 # 6040 <malloc+0x218>
     372:	5e8050ef          	jal	595a <open>
     376:	84aa                	mv	s1,a0
  if (fd < 0) {
     378:	02054e63          	bltz	a0,3b4 <badwrite+0xae>
    printf("open junk failed\n");
    exit(1);
  }
  if (write(fd, "x", 1) != 1) {
     37c:	4605                	li	a2,1
     37e:	00006597          	auipc	a1,0x6
     382:	c4a58593          	addi	a1,a1,-950 # 5fc8 <malloc+0x1a0>
     386:	5b4050ef          	jal	593a <write>
     38a:	4785                	li	a5,1
     38c:	02f50d63          	beq	a0,a5,3c6 <badwrite+0xc0>
    printf("write failed\n");
     390:	00006517          	auipc	a0,0x6
     394:	cd050513          	addi	a0,a0,-816 # 6060 <malloc+0x238>
     398:	1d9050ef          	jal	5d70 <printf>
    exit(1);
     39c:	4505                	li	a0,1
     39e:	57c050ef          	jal	591a <exit>
      printf("open junk failed\n");
     3a2:	00006517          	auipc	a0,0x6
     3a6:	ca650513          	addi	a0,a0,-858 # 6048 <malloc+0x220>
     3aa:	1c7050ef          	jal	5d70 <printf>
      exit(1);
     3ae:	4505                	li	a0,1
     3b0:	56a050ef          	jal	591a <exit>
    printf("open junk failed\n");
     3b4:	00006517          	auipc	a0,0x6
     3b8:	c9450513          	addi	a0,a0,-876 # 6048 <malloc+0x220>
     3bc:	1b5050ef          	jal	5d70 <printf>
    exit(1);
     3c0:	4505                	li	a0,1
     3c2:	558050ef          	jal	591a <exit>
  }
  close(fd);
     3c6:	8526                	mv	a0,s1
     3c8:	57a050ef          	jal	5942 <close>
  unlink("junk");
     3cc:	00006517          	auipc	a0,0x6
     3d0:	c7450513          	addi	a0,a0,-908 # 6040 <malloc+0x218>
     3d4:	596050ef          	jal	596a <unlink>

  exit(0);
     3d8:	4501                	li	a0,0
     3da:	540050ef          	jal	591a <exit>

00000000000003de <outofinodes>:
  }
}

void
outofinodes(char *s)
{
     3de:	711d                	addi	sp,sp,-96
     3e0:	ec86                	sd	ra,88(sp)
     3e2:	e8a2                	sd	s0,80(sp)
     3e4:	e4a6                	sd	s1,72(sp)
     3e6:	e0ca                	sd	s2,64(sp)
     3e8:	fc4e                	sd	s3,56(sp)
     3ea:	f852                	sd	s4,48(sp)
     3ec:	f456                	sd	s5,40(sp)
     3ee:	1080                	addi	s0,sp,96
  int nzz = 32 * 32;
  for (int i = 0; i < nzz; i++) {
     3f0:	4481                	li	s1,0
    char name[32];
    name[0] = 'z';
     3f2:	07a00993          	li	s3,122
    name[1] = 'z';
    name[2] = '0' + (i / 32);
    name[3] = '0' + (i % 32);
    name[4] = '\0';
    unlink(name);
     3f6:	fa040913          	addi	s2,s0,-96
    int fd = open(name, O_CREATE | O_RDWR | O_TRUNC);
     3fa:	60200a13          	li	s4,1538
  for (int i = 0; i < nzz; i++) {
     3fe:	40000a93          	li	s5,1024
    name[0] = 'z';
     402:	fb340023          	sb	s3,-96(s0)
    name[1] = 'z';
     406:	fb3400a3          	sb	s3,-95(s0)
    name[2] = '0' + (i / 32);
     40a:	41f4d71b          	sraiw	a4,s1,0x1f
     40e:	01b7571b          	srliw	a4,a4,0x1b
     412:	009707bb          	addw	a5,a4,s1
     416:	4057d69b          	sraiw	a3,a5,0x5
     41a:	0306869b          	addiw	a3,a3,48
     41e:	fad40123          	sb	a3,-94(s0)
    name[3] = '0' + (i % 32);
     422:	8bfd                	andi	a5,a5,31
     424:	9f99                	subw	a5,a5,a4
     426:	0307879b          	addiw	a5,a5,48
     42a:	faf401a3          	sb	a5,-93(s0)
    name[4] = '\0';
     42e:	fa040223          	sb	zero,-92(s0)
    unlink(name);
     432:	854a                	mv	a0,s2
     434:	536050ef          	jal	596a <unlink>
    int fd = open(name, O_CREATE | O_RDWR | O_TRUNC);
     438:	85d2                	mv	a1,s4
     43a:	854a                	mv	a0,s2
     43c:	51e050ef          	jal	595a <open>
    if (fd < 0) {
     440:	00054763          	bltz	a0,44e <outofinodes+0x70>
      // failure is eventually expected.
      break;
    }
    close(fd);
     444:	4fe050ef          	jal	5942 <close>
  for (int i = 0; i < nzz; i++) {
     448:	2485                	addiw	s1,s1,1
     44a:	fb549ce3          	bne	s1,s5,402 <outofinodes+0x24>
     44e:	4481                	li	s1,0
  }

  for (int i = 0; i < nzz; i++) {
    char name[32];
    name[0] = 'z';
     450:	07a00913          	li	s2,122
    name[1] = 'z';
    name[2] = '0' + (i / 32);
    name[3] = '0' + (i % 32);
    name[4] = '\0';
    unlink(name);
     454:	fa040a13          	addi	s4,s0,-96
  for (int i = 0; i < nzz; i++) {
     458:	40000993          	li	s3,1024
    name[0] = 'z';
     45c:	fb240023          	sb	s2,-96(s0)
    name[1] = 'z';
     460:	fb2400a3          	sb	s2,-95(s0)
    name[2] = '0' + (i / 32);
     464:	41f4d71b          	sraiw	a4,s1,0x1f
     468:	01b7571b          	srliw	a4,a4,0x1b
     46c:	009707bb          	addw	a5,a4,s1
     470:	4057d69b          	sraiw	a3,a5,0x5
     474:	0306869b          	addiw	a3,a3,48
     478:	fad40123          	sb	a3,-94(s0)
    name[3] = '0' + (i % 32);
     47c:	8bfd                	andi	a5,a5,31
     47e:	9f99                	subw	a5,a5,a4
     480:	0307879b          	addiw	a5,a5,48
     484:	faf401a3          	sb	a5,-93(s0)
    name[4] = '\0';
     488:	fa040223          	sb	zero,-92(s0)
    unlink(name);
     48c:	8552                	mv	a0,s4
     48e:	4dc050ef          	jal	596a <unlink>
  for (int i = 0; i < nzz; i++) {
     492:	2485                	addiw	s1,s1,1
     494:	fd3494e3          	bne	s1,s3,45c <outofinodes+0x7e>
  }
}
     498:	60e6                	ld	ra,88(sp)
     49a:	6446                	ld	s0,80(sp)
     49c:	64a6                	ld	s1,72(sp)
     49e:	6906                	ld	s2,64(sp)
     4a0:	79e2                	ld	s3,56(sp)
     4a2:	7a42                	ld	s4,48(sp)
     4a4:	7aa2                	ld	s5,40(sp)
     4a6:	6125                	addi	sp,sp,96
     4a8:	8082                	ret

00000000000004aa <copyin>:
{
     4aa:	7175                	addi	sp,sp,-144
     4ac:	e506                	sd	ra,136(sp)
     4ae:	e122                	sd	s0,128(sp)
     4b0:	fca6                	sd	s1,120(sp)
     4b2:	f8ca                	sd	s2,112(sp)
     4b4:	f4ce                	sd	s3,104(sp)
     4b6:	f0d2                	sd	s4,96(sp)
     4b8:	ecd6                	sd	s5,88(sp)
     4ba:	e8da                	sd	s6,80(sp)
     4bc:	e4de                	sd	s7,72(sp)
     4be:	e0e2                	sd	s8,64(sp)
     4c0:	fc66                	sd	s9,56(sp)
     4c2:	0900                	addi	s0,sp,144
  uint64 addrs[] = {0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
     4c4:	00008797          	auipc	a5,0x8
     4c8:	44c78793          	addi	a5,a5,1100 # 8910 <malloc+0x2ae8>
     4cc:	638c                	ld	a1,0(a5)
     4ce:	6790                	ld	a2,8(a5)
     4d0:	6b94                	ld	a3,16(a5)
     4d2:	6f98                	ld	a4,24(a5)
     4d4:	f6b43c23          	sd	a1,-136(s0)
     4d8:	f8c43023          	sd	a2,-128(s0)
     4dc:	f8d43423          	sd	a3,-120(s0)
     4e0:	f8e43823          	sd	a4,-112(s0)
     4e4:	739c                	ld	a5,32(a5)
     4e6:	f8f43c23          	sd	a5,-104(s0)
  for (int ai = 0; ai < sizeof(addrs) / sizeof(addrs[0]); ai++) {
     4ea:	f7840913          	addi	s2,s0,-136
     4ee:	fa040c93          	addi	s9,s0,-96
    int fd = open("copyin1", O_CREATE | O_WRONLY);
     4f2:	20100b13          	li	s6,513
     4f6:	00006a97          	auipc	s5,0x6
     4fa:	b7aa8a93          	addi	s5,s5,-1158 # 6070 <malloc+0x248>
    int n = write(fd, (void *)addr, 8192);
     4fe:	6a09                	lui	s4,0x2
    n = write(1, (char *)addr, 8192);
     500:	4c05                	li	s8,1
    if (pipe(fds) < 0) {
     502:	f7040b93          	addi	s7,s0,-144
    uint64 addr = addrs[ai];
     506:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE | O_WRONLY);
     50a:	85da                	mv	a1,s6
     50c:	8556                	mv	a0,s5
     50e:	44c050ef          	jal	595a <open>
     512:	84aa                	mv	s1,a0
    if (fd < 0) {
     514:	06054a63          	bltz	a0,588 <copyin+0xde>
    int n = write(fd, (void *)addr, 8192);
     518:	8652                	mv	a2,s4
     51a:	85ce                	mv	a1,s3
     51c:	41e050ef          	jal	593a <write>
    if (n >= 0) {
     520:	06055d63          	bgez	a0,59a <copyin+0xf0>
    close(fd);
     524:	8526                	mv	a0,s1
     526:	41c050ef          	jal	5942 <close>
    unlink("copyin1");
     52a:	8556                	mv	a0,s5
     52c:	43e050ef          	jal	596a <unlink>
    n = write(1, (char *)addr, 8192);
     530:	8652                	mv	a2,s4
     532:	85ce                	mv	a1,s3
     534:	8562                	mv	a0,s8
     536:	404050ef          	jal	593a <write>
    if (n > 0) {
     53a:	06a04b63          	bgtz	a0,5b0 <copyin+0x106>
    if (pipe(fds) < 0) {
     53e:	855e                	mv	a0,s7
     540:	3ea050ef          	jal	592a <pipe>
     544:	08054163          	bltz	a0,5c6 <copyin+0x11c>
    n = write(fds[1], (char *)addr, 8192);
     548:	8652                	mv	a2,s4
     54a:	85ce                	mv	a1,s3
     54c:	f7442503          	lw	a0,-140(s0)
     550:	3ea050ef          	jal	593a <write>
    if (n > 0) {
     554:	08a04263          	bgtz	a0,5d8 <copyin+0x12e>
    close(fds[0]);
     558:	f7042503          	lw	a0,-144(s0)
     55c:	3e6050ef          	jal	5942 <close>
    close(fds[1]);
     560:	f7442503          	lw	a0,-140(s0)
     564:	3de050ef          	jal	5942 <close>
  for (int ai = 0; ai < sizeof(addrs) / sizeof(addrs[0]); ai++) {
     568:	0921                	addi	s2,s2,8
     56a:	f9991ee3          	bne	s2,s9,506 <copyin+0x5c>
}
     56e:	60aa                	ld	ra,136(sp)
     570:	640a                	ld	s0,128(sp)
     572:	74e6                	ld	s1,120(sp)
     574:	7946                	ld	s2,112(sp)
     576:	79a6                	ld	s3,104(sp)
     578:	7a06                	ld	s4,96(sp)
     57a:	6ae6                	ld	s5,88(sp)
     57c:	6b46                	ld	s6,80(sp)
     57e:	6ba6                	ld	s7,72(sp)
     580:	6c06                	ld	s8,64(sp)
     582:	7ce2                	ld	s9,56(sp)
     584:	6149                	addi	sp,sp,144
     586:	8082                	ret
      printf("open(copyin1) failed\n");
     588:	00006517          	auipc	a0,0x6
     58c:	af050513          	addi	a0,a0,-1296 # 6078 <malloc+0x250>
     590:	7e0050ef          	jal	5d70 <printf>
      exit(1);
     594:	4505                	li	a0,1
     596:	384050ef          	jal	591a <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", (void *)addr, n);
     59a:	862a                	mv	a2,a0
     59c:	85ce                	mv	a1,s3
     59e:	00006517          	auipc	a0,0x6
     5a2:	af250513          	addi	a0,a0,-1294 # 6090 <malloc+0x268>
     5a6:	7ca050ef          	jal	5d70 <printf>
      exit(1);
     5aa:	4505                	li	a0,1
     5ac:	36e050ef          	jal	591a <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", (void *)addr, n);
     5b0:	862a                	mv	a2,a0
     5b2:	85ce                	mv	a1,s3
     5b4:	00006517          	auipc	a0,0x6
     5b8:	b0c50513          	addi	a0,a0,-1268 # 60c0 <malloc+0x298>
     5bc:	7b4050ef          	jal	5d70 <printf>
      exit(1);
     5c0:	4505                	li	a0,1
     5c2:	358050ef          	jal	591a <exit>
      printf("pipe() failed\n");
     5c6:	00006517          	auipc	a0,0x6
     5ca:	b2a50513          	addi	a0,a0,-1238 # 60f0 <malloc+0x2c8>
     5ce:	7a2050ef          	jal	5d70 <printf>
      exit(1);
     5d2:	4505                	li	a0,1
     5d4:	346050ef          	jal	591a <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", (void *)addr,
     5d8:	862a                	mv	a2,a0
     5da:	85ce                	mv	a1,s3
     5dc:	00006517          	auipc	a0,0x6
     5e0:	b2450513          	addi	a0,a0,-1244 # 6100 <malloc+0x2d8>
     5e4:	78c050ef          	jal	5d70 <printf>
      exit(1);
     5e8:	4505                	li	a0,1
     5ea:	330050ef          	jal	591a <exit>

00000000000005ee <copyout>:
{
     5ee:	7135                	addi	sp,sp,-160
     5f0:	ed06                	sd	ra,152(sp)
     5f2:	e922                	sd	s0,144(sp)
     5f4:	e526                	sd	s1,136(sp)
     5f6:	e14a                	sd	s2,128(sp)
     5f8:	fcce                	sd	s3,120(sp)
     5fa:	f8d2                	sd	s4,112(sp)
     5fc:	f4d6                	sd	s5,104(sp)
     5fe:	f0da                	sd	s6,96(sp)
     600:	ecde                	sd	s7,88(sp)
     602:	e8e2                	sd	s8,80(sp)
     604:	e4e6                	sd	s9,72(sp)
     606:	1100                	addi	s0,sp,160
  uint64 addrs[] = {0LL,          0x80000000LL, 0x3fffffe000,
     608:	00008797          	auipc	a5,0x8
     60c:	30878793          	addi	a5,a5,776 # 8910 <malloc+0x2ae8>
     610:	7788                	ld	a0,40(a5)
     612:	7b8c                	ld	a1,48(a5)
     614:	7f90                	ld	a2,56(a5)
     616:	63b4                	ld	a3,64(a5)
     618:	67b8                	ld	a4,72(a5)
     61a:	f6a43823          	sd	a0,-144(s0)
     61e:	f6b43c23          	sd	a1,-136(s0)
     622:	f8c43023          	sd	a2,-128(s0)
     626:	f8d43423          	sd	a3,-120(s0)
     62a:	f8e43823          	sd	a4,-112(s0)
     62e:	6bbc                	ld	a5,80(a5)
     630:	f8f43c23          	sd	a5,-104(s0)
  for (int ai = 0; ai < sizeof(addrs) / sizeof(addrs[0]); ai++) {
     634:	f7040913          	addi	s2,s0,-144
     638:	fa040c93          	addi	s9,s0,-96
    int fd = open("README", 0);
     63c:	00006b17          	auipc	s6,0x6
     640:	af4b0b13          	addi	s6,s6,-1292 # 6130 <malloc+0x308>
    int n = read(fd, (void *)addr, 8192);
     644:	6a89                	lui	s5,0x2
    if (pipe(fds) < 0) {
     646:	f6840c13          	addi	s8,s0,-152
    n = write(fds[1], "x", 1);
     64a:	4a05                	li	s4,1
     64c:	00006b97          	auipc	s7,0x6
     650:	97cb8b93          	addi	s7,s7,-1668 # 5fc8 <malloc+0x1a0>
    uint64 addr = addrs[ai];
     654:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     658:	4581                	li	a1,0
     65a:	855a                	mv	a0,s6
     65c:	2fe050ef          	jal	595a <open>
     660:	84aa                	mv	s1,a0
    if (fd < 0) {
     662:	06054863          	bltz	a0,6d2 <copyout+0xe4>
    int n = read(fd, (void *)addr, 8192);
     666:	8656                	mv	a2,s5
     668:	85ce                	mv	a1,s3
     66a:	2c8050ef          	jal	5932 <read>
    if (n > 0) {
     66e:	06a04b63          	bgtz	a0,6e4 <copyout+0xf6>
    close(fd);
     672:	8526                	mv	a0,s1
     674:	2ce050ef          	jal	5942 <close>
    if (pipe(fds) < 0) {
     678:	8562                	mv	a0,s8
     67a:	2b0050ef          	jal	592a <pipe>
     67e:	06054e63          	bltz	a0,6fa <copyout+0x10c>
    n = write(fds[1], "x", 1);
     682:	8652                	mv	a2,s4
     684:	85de                	mv	a1,s7
     686:	f6c42503          	lw	a0,-148(s0)
     68a:	2b0050ef          	jal	593a <write>
    if (n != 1) {
     68e:	07451f63          	bne	a0,s4,70c <copyout+0x11e>
    n = read(fds[0], (void *)addr, 8192);
     692:	8656                	mv	a2,s5
     694:	85ce                	mv	a1,s3
     696:	f6842503          	lw	a0,-152(s0)
     69a:	298050ef          	jal	5932 <read>
    if (n > 0) {
     69e:	08a04063          	bgtz	a0,71e <copyout+0x130>
    close(fds[0]);
     6a2:	f6842503          	lw	a0,-152(s0)
     6a6:	29c050ef          	jal	5942 <close>
    close(fds[1]);
     6aa:	f6c42503          	lw	a0,-148(s0)
     6ae:	294050ef          	jal	5942 <close>
  for (int ai = 0; ai < sizeof(addrs) / sizeof(addrs[0]); ai++) {
     6b2:	0921                	addi	s2,s2,8
     6b4:	fb9910e3          	bne	s2,s9,654 <copyout+0x66>
}
     6b8:	60ea                	ld	ra,152(sp)
     6ba:	644a                	ld	s0,144(sp)
     6bc:	64aa                	ld	s1,136(sp)
     6be:	690a                	ld	s2,128(sp)
     6c0:	79e6                	ld	s3,120(sp)
     6c2:	7a46                	ld	s4,112(sp)
     6c4:	7aa6                	ld	s5,104(sp)
     6c6:	7b06                	ld	s6,96(sp)
     6c8:	6be6                	ld	s7,88(sp)
     6ca:	6c46                	ld	s8,80(sp)
     6cc:	6ca6                	ld	s9,72(sp)
     6ce:	610d                	addi	sp,sp,160
     6d0:	8082                	ret
      printf("open(README) failed\n");
     6d2:	00006517          	auipc	a0,0x6
     6d6:	a6650513          	addi	a0,a0,-1434 # 6138 <malloc+0x310>
     6da:	696050ef          	jal	5d70 <printf>
      exit(1);
     6de:	4505                	li	a0,1
     6e0:	23a050ef          	jal	591a <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", (void *)addr, n);
     6e4:	862a                	mv	a2,a0
     6e6:	85ce                	mv	a1,s3
     6e8:	00006517          	auipc	a0,0x6
     6ec:	a6850513          	addi	a0,a0,-1432 # 6150 <malloc+0x328>
     6f0:	680050ef          	jal	5d70 <printf>
      exit(1);
     6f4:	4505                	li	a0,1
     6f6:	224050ef          	jal	591a <exit>
      printf("pipe() failed\n");
     6fa:	00006517          	auipc	a0,0x6
     6fe:	9f650513          	addi	a0,a0,-1546 # 60f0 <malloc+0x2c8>
     702:	66e050ef          	jal	5d70 <printf>
      exit(1);
     706:	4505                	li	a0,1
     708:	212050ef          	jal	591a <exit>
      printf("pipe write failed\n");
     70c:	00006517          	auipc	a0,0x6
     710:	a7450513          	addi	a0,a0,-1420 # 6180 <malloc+0x358>
     714:	65c050ef          	jal	5d70 <printf>
      exit(1);
     718:	4505                	li	a0,1
     71a:	200050ef          	jal	591a <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", (void *)addr,
     71e:	862a                	mv	a2,a0
     720:	85ce                	mv	a1,s3
     722:	00006517          	auipc	a0,0x6
     726:	a7650513          	addi	a0,a0,-1418 # 6198 <malloc+0x370>
     72a:	646050ef          	jal	5d70 <printf>
      exit(1);
     72e:	4505                	li	a0,1
     730:	1ea050ef          	jal	591a <exit>

0000000000000734 <truncate1>:
{
     734:	711d                	addi	sp,sp,-96
     736:	ec86                	sd	ra,88(sp)
     738:	e8a2                	sd	s0,80(sp)
     73a:	e4a6                	sd	s1,72(sp)
     73c:	e0ca                	sd	s2,64(sp)
     73e:	fc4e                	sd	s3,56(sp)
     740:	f852                	sd	s4,48(sp)
     742:	f456                	sd	s5,40(sp)
     744:	1080                	addi	s0,sp,96
     746:	8a2a                	mv	s4,a0
  unlink("truncfile");
     748:	00006517          	auipc	a0,0x6
     74c:	86850513          	addi	a0,a0,-1944 # 5fb0 <malloc+0x188>
     750:	21a050ef          	jal	596a <unlink>
  int fd1 = open("truncfile", O_CREATE | O_WRONLY | O_TRUNC);
     754:	60100593          	li	a1,1537
     758:	00006517          	auipc	a0,0x6
     75c:	85850513          	addi	a0,a0,-1960 # 5fb0 <malloc+0x188>
     760:	1fa050ef          	jal	595a <open>
     764:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     766:	4611                	li	a2,4
     768:	00006597          	auipc	a1,0x6
     76c:	85858593          	addi	a1,a1,-1960 # 5fc0 <malloc+0x198>
     770:	1ca050ef          	jal	593a <write>
  close(fd1);
     774:	8526                	mv	a0,s1
     776:	1cc050ef          	jal	5942 <close>
  int fd2 = open("truncfile", O_RDONLY);
     77a:	4581                	li	a1,0
     77c:	00006517          	auipc	a0,0x6
     780:	83450513          	addi	a0,a0,-1996 # 5fb0 <malloc+0x188>
     784:	1d6050ef          	jal	595a <open>
     788:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     78a:	02000613          	li	a2,32
     78e:	fa040593          	addi	a1,s0,-96
     792:	1a0050ef          	jal	5932 <read>
  if (n != 4) {
     796:	4791                	li	a5,4
     798:	0af51863          	bne	a0,a5,848 <truncate1+0x114>
  fd1 = open("truncfile", O_WRONLY | O_TRUNC);
     79c:	40100593          	li	a1,1025
     7a0:	00006517          	auipc	a0,0x6
     7a4:	81050513          	addi	a0,a0,-2032 # 5fb0 <malloc+0x188>
     7a8:	1b2050ef          	jal	595a <open>
     7ac:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     7ae:	4581                	li	a1,0
     7b0:	00006517          	auipc	a0,0x6
     7b4:	80050513          	addi	a0,a0,-2048 # 5fb0 <malloc+0x188>
     7b8:	1a2050ef          	jal	595a <open>
     7bc:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     7be:	02000613          	li	a2,32
     7c2:	fa040593          	addi	a1,s0,-96
     7c6:	16c050ef          	jal	5932 <read>
     7ca:	8aaa                	mv	s5,a0
  if (n != 0) {
     7cc:	e949                	bnez	a0,85e <truncate1+0x12a>
  n = read(fd2, buf, sizeof(buf));
     7ce:	02000613          	li	a2,32
     7d2:	fa040593          	addi	a1,s0,-96
     7d6:	8526                	mv	a0,s1
     7d8:	15a050ef          	jal	5932 <read>
     7dc:	8aaa                	mv	s5,a0
  if (n != 0) {
     7de:	e155                	bnez	a0,882 <truncate1+0x14e>
  write(fd1, "abcdef", 6);
     7e0:	4619                	li	a2,6
     7e2:	00006597          	auipc	a1,0x6
     7e6:	a4658593          	addi	a1,a1,-1466 # 6228 <malloc+0x400>
     7ea:	854e                	mv	a0,s3
     7ec:	14e050ef          	jal	593a <write>
  n = read(fd3, buf, sizeof(buf));
     7f0:	02000613          	li	a2,32
     7f4:	fa040593          	addi	a1,s0,-96
     7f8:	854a                	mv	a0,s2
     7fa:	138050ef          	jal	5932 <read>
  if (n != 6) {
     7fe:	4799                	li	a5,6
     800:	0af51363          	bne	a0,a5,8a6 <truncate1+0x172>
  n = read(fd2, buf, sizeof(buf));
     804:	02000613          	li	a2,32
     808:	fa040593          	addi	a1,s0,-96
     80c:	8526                	mv	a0,s1
     80e:	124050ef          	jal	5932 <read>
  if (n != 2) {
     812:	4789                	li	a5,2
     814:	0af51463          	bne	a0,a5,8bc <truncate1+0x188>
  unlink("truncfile");
     818:	00005517          	auipc	a0,0x5
     81c:	79850513          	addi	a0,a0,1944 # 5fb0 <malloc+0x188>
     820:	14a050ef          	jal	596a <unlink>
  close(fd1);
     824:	854e                	mv	a0,s3
     826:	11c050ef          	jal	5942 <close>
  close(fd2);
     82a:	8526                	mv	a0,s1
     82c:	116050ef          	jal	5942 <close>
  close(fd3);
     830:	854a                	mv	a0,s2
     832:	110050ef          	jal	5942 <close>
}
     836:	60e6                	ld	ra,88(sp)
     838:	6446                	ld	s0,80(sp)
     83a:	64a6                	ld	s1,72(sp)
     83c:	6906                	ld	s2,64(sp)
     83e:	79e2                	ld	s3,56(sp)
     840:	7a42                	ld	s4,48(sp)
     842:	7aa2                	ld	s5,40(sp)
     844:	6125                	addi	sp,sp,96
     846:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     848:	862a                	mv	a2,a0
     84a:	85d2                	mv	a1,s4
     84c:	00006517          	auipc	a0,0x6
     850:	97c50513          	addi	a0,a0,-1668 # 61c8 <malloc+0x3a0>
     854:	51c050ef          	jal	5d70 <printf>
    exit(1);
     858:	4505                	li	a0,1
     85a:	0c0050ef          	jal	591a <exit>
    printf("aaa fd3=%d\n", fd3);
     85e:	85ca                	mv	a1,s2
     860:	00006517          	auipc	a0,0x6
     864:	98850513          	addi	a0,a0,-1656 # 61e8 <malloc+0x3c0>
     868:	508050ef          	jal	5d70 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     86c:	8656                	mv	a2,s5
     86e:	85d2                	mv	a1,s4
     870:	00006517          	auipc	a0,0x6
     874:	98850513          	addi	a0,a0,-1656 # 61f8 <malloc+0x3d0>
     878:	4f8050ef          	jal	5d70 <printf>
    exit(1);
     87c:	4505                	li	a0,1
     87e:	09c050ef          	jal	591a <exit>
    printf("bbb fd2=%d\n", fd2);
     882:	85a6                	mv	a1,s1
     884:	00006517          	auipc	a0,0x6
     888:	99450513          	addi	a0,a0,-1644 # 6218 <malloc+0x3f0>
     88c:	4e4050ef          	jal	5d70 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     890:	8656                	mv	a2,s5
     892:	85d2                	mv	a1,s4
     894:	00006517          	auipc	a0,0x6
     898:	96450513          	addi	a0,a0,-1692 # 61f8 <malloc+0x3d0>
     89c:	4d4050ef          	jal	5d70 <printf>
    exit(1);
     8a0:	4505                	li	a0,1
     8a2:	078050ef          	jal	591a <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     8a6:	862a                	mv	a2,a0
     8a8:	85d2                	mv	a1,s4
     8aa:	00006517          	auipc	a0,0x6
     8ae:	98650513          	addi	a0,a0,-1658 # 6230 <malloc+0x408>
     8b2:	4be050ef          	jal	5d70 <printf>
    exit(1);
     8b6:	4505                	li	a0,1
     8b8:	062050ef          	jal	591a <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     8bc:	862a                	mv	a2,a0
     8be:	85d2                	mv	a1,s4
     8c0:	00006517          	auipc	a0,0x6
     8c4:	99050513          	addi	a0,a0,-1648 # 6250 <malloc+0x428>
     8c8:	4a8050ef          	jal	5d70 <printf>
    exit(1);
     8cc:	4505                	li	a0,1
     8ce:	04c050ef          	jal	591a <exit>

00000000000008d2 <writetest>:
{
     8d2:	715d                	addi	sp,sp,-80
     8d4:	e486                	sd	ra,72(sp)
     8d6:	e0a2                	sd	s0,64(sp)
     8d8:	fc26                	sd	s1,56(sp)
     8da:	f84a                	sd	s2,48(sp)
     8dc:	f44e                	sd	s3,40(sp)
     8de:	f052                	sd	s4,32(sp)
     8e0:	ec56                	sd	s5,24(sp)
     8e2:	e85a                	sd	s6,16(sp)
     8e4:	e45e                	sd	s7,8(sp)
     8e6:	0880                	addi	s0,sp,80
     8e8:	8baa                	mv	s7,a0
  fd = open("small", O_CREATE | O_RDWR);
     8ea:	20200593          	li	a1,514
     8ee:	00006517          	auipc	a0,0x6
     8f2:	98250513          	addi	a0,a0,-1662 # 6270 <malloc+0x448>
     8f6:	064050ef          	jal	595a <open>
  if (fd < 0) {
     8fa:	08054f63          	bltz	a0,998 <writetest+0xc6>
     8fe:	89aa                	mv	s3,a0
     900:	4901                	li	s2,0
    if (write(fd, "aaaaaaaaaa", SZ) != SZ) {
     902:	44a9                	li	s1,10
     904:	00006a17          	auipc	s4,0x6
     908:	994a0a13          	addi	s4,s4,-1644 # 6298 <malloc+0x470>
    if (write(fd, "bbbbbbbbbb", SZ) != SZ) {
     90c:	00006b17          	auipc	s6,0x6
     910:	9c4b0b13          	addi	s6,s6,-1596 # 62d0 <malloc+0x4a8>
  for (i = 0; i < N; i++) {
     914:	06400a93          	li	s5,100
    if (write(fd, "aaaaaaaaaa", SZ) != SZ) {
     918:	8626                	mv	a2,s1
     91a:	85d2                	mv	a1,s4
     91c:	854e                	mv	a0,s3
     91e:	01c050ef          	jal	593a <write>
     922:	08951563          	bne	a0,s1,9ac <writetest+0xda>
    if (write(fd, "bbbbbbbbbb", SZ) != SZ) {
     926:	8626                	mv	a2,s1
     928:	85da                	mv	a1,s6
     92a:	854e                	mv	a0,s3
     92c:	00e050ef          	jal	593a <write>
     930:	08951963          	bne	a0,s1,9c2 <writetest+0xf0>
  for (i = 0; i < N; i++) {
     934:	2905                	addiw	s2,s2,1
     936:	ff5911e3          	bne	s2,s5,918 <writetest+0x46>
  close(fd);
     93a:	854e                	mv	a0,s3
     93c:	006050ef          	jal	5942 <close>
  fd = open("small", O_RDONLY);
     940:	4581                	li	a1,0
     942:	00006517          	auipc	a0,0x6
     946:	92e50513          	addi	a0,a0,-1746 # 6270 <malloc+0x448>
     94a:	010050ef          	jal	595a <open>
     94e:	84aa                	mv	s1,a0
  if (fd < 0) {
     950:	08054463          	bltz	a0,9d8 <writetest+0x106>
  i = read(fd, buf, N * SZ * 2);
     954:	7d000613          	li	a2,2000
     958:	0000e597          	auipc	a1,0xe
     95c:	3b058593          	addi	a1,a1,944 # ed08 <buf>
     960:	7d3040ef          	jal	5932 <read>
  if (i != N * SZ * 2) {
     964:	7d000793          	li	a5,2000
     968:	08f51263          	bne	a0,a5,9ec <writetest+0x11a>
  close(fd);
     96c:	8526                	mv	a0,s1
     96e:	7d5040ef          	jal	5942 <close>
  if (unlink("small") < 0) {
     972:	00006517          	auipc	a0,0x6
     976:	8fe50513          	addi	a0,a0,-1794 # 6270 <malloc+0x448>
     97a:	7f1040ef          	jal	596a <unlink>
     97e:	08054163          	bltz	a0,a00 <writetest+0x12e>
}
     982:	60a6                	ld	ra,72(sp)
     984:	6406                	ld	s0,64(sp)
     986:	74e2                	ld	s1,56(sp)
     988:	7942                	ld	s2,48(sp)
     98a:	79a2                	ld	s3,40(sp)
     98c:	7a02                	ld	s4,32(sp)
     98e:	6ae2                	ld	s5,24(sp)
     990:	6b42                	ld	s6,16(sp)
     992:	6ba2                	ld	s7,8(sp)
     994:	6161                	addi	sp,sp,80
     996:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     998:	85de                	mv	a1,s7
     99a:	00006517          	auipc	a0,0x6
     99e:	8de50513          	addi	a0,a0,-1826 # 6278 <malloc+0x450>
     9a2:	3ce050ef          	jal	5d70 <printf>
    exit(1);
     9a6:	4505                	li	a0,1
     9a8:	773040ef          	jal	591a <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     9ac:	864a                	mv	a2,s2
     9ae:	85de                	mv	a1,s7
     9b0:	00006517          	auipc	a0,0x6
     9b4:	8f850513          	addi	a0,a0,-1800 # 62a8 <malloc+0x480>
     9b8:	3b8050ef          	jal	5d70 <printf>
      exit(1);
     9bc:	4505                	li	a0,1
     9be:	75d040ef          	jal	591a <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     9c2:	864a                	mv	a2,s2
     9c4:	85de                	mv	a1,s7
     9c6:	00006517          	auipc	a0,0x6
     9ca:	91a50513          	addi	a0,a0,-1766 # 62e0 <malloc+0x4b8>
     9ce:	3a2050ef          	jal	5d70 <printf>
      exit(1);
     9d2:	4505                	li	a0,1
     9d4:	747040ef          	jal	591a <exit>
    printf("%s: error: open small failed!\n", s);
     9d8:	85de                	mv	a1,s7
     9da:	00006517          	auipc	a0,0x6
     9de:	92e50513          	addi	a0,a0,-1746 # 6308 <malloc+0x4e0>
     9e2:	38e050ef          	jal	5d70 <printf>
    exit(1);
     9e6:	4505                	li	a0,1
     9e8:	733040ef          	jal	591a <exit>
    printf("%s: read failed\n", s);
     9ec:	85de                	mv	a1,s7
     9ee:	00006517          	auipc	a0,0x6
     9f2:	93a50513          	addi	a0,a0,-1734 # 6328 <malloc+0x500>
     9f6:	37a050ef          	jal	5d70 <printf>
    exit(1);
     9fa:	4505                	li	a0,1
     9fc:	71f040ef          	jal	591a <exit>
    printf("%s: unlink small failed\n", s);
     a00:	85de                	mv	a1,s7
     a02:	00006517          	auipc	a0,0x6
     a06:	93e50513          	addi	a0,a0,-1730 # 6340 <malloc+0x518>
     a0a:	366050ef          	jal	5d70 <printf>
    exit(1);
     a0e:	4505                	li	a0,1
     a10:	70b040ef          	jal	591a <exit>

0000000000000a14 <writebig>:
{
     a14:	7139                	addi	sp,sp,-64
     a16:	fc06                	sd	ra,56(sp)
     a18:	f822                	sd	s0,48(sp)
     a1a:	f426                	sd	s1,40(sp)
     a1c:	f04a                	sd	s2,32(sp)
     a1e:	ec4e                	sd	s3,24(sp)
     a20:	e852                	sd	s4,16(sp)
     a22:	e456                	sd	s5,8(sp)
     a24:	e05a                	sd	s6,0(sp)
     a26:	0080                	addi	s0,sp,64
     a28:	8b2a                	mv	s6,a0
  fd = open("big", O_CREATE | O_RDWR);
     a2a:	20200593          	li	a1,514
     a2e:	00006517          	auipc	a0,0x6
     a32:	93250513          	addi	a0,a0,-1742 # 6360 <malloc+0x538>
     a36:	725040ef          	jal	595a <open>
  if (fd < 0) {
     a3a:	06054a63          	bltz	a0,aae <writebig+0x9a>
     a3e:	8a2a                	mv	s4,a0
     a40:	4481                	li	s1,0
    ((int *)buf)[0] = i;
     a42:	0000e997          	auipc	s3,0xe
     a46:	2c698993          	addi	s3,s3,710 # ed08 <buf>
    if (write(fd, buf, BSIZE) != BSIZE) {
     a4a:	40000913          	li	s2,1024
  for (i = 0; i < MAXFILE; i++) {
     a4e:	10c00a93          	li	s5,268
    ((int *)buf)[0] = i;
     a52:	0099a023          	sw	s1,0(s3)
    if (write(fd, buf, BSIZE) != BSIZE) {
     a56:	864a                	mv	a2,s2
     a58:	85ce                	mv	a1,s3
     a5a:	8552                	mv	a0,s4
     a5c:	6df040ef          	jal	593a <write>
     a60:	07251163          	bne	a0,s2,ac2 <writebig+0xae>
  for (i = 0; i < MAXFILE; i++) {
     a64:	2485                	addiw	s1,s1,1
     a66:	ff5496e3          	bne	s1,s5,a52 <writebig+0x3e>
  close(fd);
     a6a:	8552                	mv	a0,s4
     a6c:	6d7040ef          	jal	5942 <close>
  fd = open("big", O_RDONLY);
     a70:	4581                	li	a1,0
     a72:	00006517          	auipc	a0,0x6
     a76:	8ee50513          	addi	a0,a0,-1810 # 6360 <malloc+0x538>
     a7a:	6e1040ef          	jal	595a <open>
     a7e:	8a2a                	mv	s4,a0
  n = 0;
     a80:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a82:	40000993          	li	s3,1024
     a86:	0000e917          	auipc	s2,0xe
     a8a:	28290913          	addi	s2,s2,642 # ed08 <buf>
  if (fd < 0) {
     a8e:	04054563          	bltz	a0,ad8 <writebig+0xc4>
    i = read(fd, buf, BSIZE);
     a92:	864e                	mv	a2,s3
     a94:	85ca                	mv	a1,s2
     a96:	8552                	mv	a0,s4
     a98:	69b040ef          	jal	5932 <read>
    if (i == 0) {
     a9c:	c921                	beqz	a0,aec <writebig+0xd8>
    } else if (i != BSIZE) {
     a9e:	09351b63          	bne	a0,s3,b34 <writebig+0x120>
    if (((int *)buf)[0] != n) {
     aa2:	00092683          	lw	a3,0(s2)
     aa6:	0a969263          	bne	a3,s1,b4a <writebig+0x136>
    n++;
     aaa:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     aac:	b7dd                	j	a92 <writebig+0x7e>
    printf("%s: error: creat big failed!\n", s);
     aae:	85da                	mv	a1,s6
     ab0:	00006517          	auipc	a0,0x6
     ab4:	8b850513          	addi	a0,a0,-1864 # 6368 <malloc+0x540>
     ab8:	2b8050ef          	jal	5d70 <printf>
    exit(1);
     abc:	4505                	li	a0,1
     abe:	65d040ef          	jal	591a <exit>
      printf("%s: error: write big file failed i=%d\n", s, i);
     ac2:	8626                	mv	a2,s1
     ac4:	85da                	mv	a1,s6
     ac6:	00006517          	auipc	a0,0x6
     aca:	8c250513          	addi	a0,a0,-1854 # 6388 <malloc+0x560>
     ace:	2a2050ef          	jal	5d70 <printf>
      exit(1);
     ad2:	4505                	li	a0,1
     ad4:	647040ef          	jal	591a <exit>
    printf("%s: error: open big failed!\n", s);
     ad8:	85da                	mv	a1,s6
     ada:	00006517          	auipc	a0,0x6
     ade:	8d650513          	addi	a0,a0,-1834 # 63b0 <malloc+0x588>
     ae2:	28e050ef          	jal	5d70 <printf>
    exit(1);
     ae6:	4505                	li	a0,1
     ae8:	633040ef          	jal	591a <exit>
      if (n != MAXFILE) {
     aec:	10c00793          	li	a5,268
     af0:	02f49763          	bne	s1,a5,b1e <writebig+0x10a>
  close(fd);
     af4:	8552                	mv	a0,s4
     af6:	64d040ef          	jal	5942 <close>
  if (unlink("big") < 0) {
     afa:	00006517          	auipc	a0,0x6
     afe:	86650513          	addi	a0,a0,-1946 # 6360 <malloc+0x538>
     b02:	669040ef          	jal	596a <unlink>
     b06:	04054d63          	bltz	a0,b60 <writebig+0x14c>
}
     b0a:	70e2                	ld	ra,56(sp)
     b0c:	7442                	ld	s0,48(sp)
     b0e:	74a2                	ld	s1,40(sp)
     b10:	7902                	ld	s2,32(sp)
     b12:	69e2                	ld	s3,24(sp)
     b14:	6a42                	ld	s4,16(sp)
     b16:	6aa2                	ld	s5,8(sp)
     b18:	6b02                	ld	s6,0(sp)
     b1a:	6121                	addi	sp,sp,64
     b1c:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     b1e:	8626                	mv	a2,s1
     b20:	85da                	mv	a1,s6
     b22:	00006517          	auipc	a0,0x6
     b26:	8ae50513          	addi	a0,a0,-1874 # 63d0 <malloc+0x5a8>
     b2a:	246050ef          	jal	5d70 <printf>
        exit(1);
     b2e:	4505                	li	a0,1
     b30:	5eb040ef          	jal	591a <exit>
      printf("%s: read failed %d\n", s, i);
     b34:	862a                	mv	a2,a0
     b36:	85da                	mv	a1,s6
     b38:	00006517          	auipc	a0,0x6
     b3c:	8c050513          	addi	a0,a0,-1856 # 63f8 <malloc+0x5d0>
     b40:	230050ef          	jal	5d70 <printf>
      exit(1);
     b44:	4505                	li	a0,1
     b46:	5d5040ef          	jal	591a <exit>
      printf("%s: read content of block %d is %d\n", s, n, ((int *)buf)[0]);
     b4a:	8626                	mv	a2,s1
     b4c:	85da                	mv	a1,s6
     b4e:	00006517          	auipc	a0,0x6
     b52:	8c250513          	addi	a0,a0,-1854 # 6410 <malloc+0x5e8>
     b56:	21a050ef          	jal	5d70 <printf>
      exit(1);
     b5a:	4505                	li	a0,1
     b5c:	5bf040ef          	jal	591a <exit>
    printf("%s: unlink big failed\n", s);
     b60:	85da                	mv	a1,s6
     b62:	00006517          	auipc	a0,0x6
     b66:	8d650513          	addi	a0,a0,-1834 # 6438 <malloc+0x610>
     b6a:	206050ef          	jal	5d70 <printf>
    exit(1);
     b6e:	4505                	li	a0,1
     b70:	5ab040ef          	jal	591a <exit>

0000000000000b74 <unlinkread>:
{
     b74:	7179                	addi	sp,sp,-48
     b76:	f406                	sd	ra,40(sp)
     b78:	f022                	sd	s0,32(sp)
     b7a:	ec26                	sd	s1,24(sp)
     b7c:	e84a                	sd	s2,16(sp)
     b7e:	e44e                	sd	s3,8(sp)
     b80:	1800                	addi	s0,sp,48
     b82:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b84:	20200593          	li	a1,514
     b88:	00006517          	auipc	a0,0x6
     b8c:	8c850513          	addi	a0,a0,-1848 # 6450 <malloc+0x628>
     b90:	5cb040ef          	jal	595a <open>
  if (fd < 0) {
     b94:	0a054f63          	bltz	a0,c52 <unlinkread+0xde>
     b98:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     b9a:	4615                	li	a2,5
     b9c:	00006597          	auipc	a1,0x6
     ba0:	8e458593          	addi	a1,a1,-1820 # 6480 <malloc+0x658>
     ba4:	597040ef          	jal	593a <write>
  close(fd);
     ba8:	8526                	mv	a0,s1
     baa:	599040ef          	jal	5942 <close>
  fd = open("unlinkread", O_RDWR);
     bae:	4589                	li	a1,2
     bb0:	00006517          	auipc	a0,0x6
     bb4:	8a050513          	addi	a0,a0,-1888 # 6450 <malloc+0x628>
     bb8:	5a3040ef          	jal	595a <open>
     bbc:	84aa                	mv	s1,a0
  if (fd < 0) {
     bbe:	0a054463          	bltz	a0,c66 <unlinkread+0xf2>
  if (unlink("unlinkread") != 0) {
     bc2:	00006517          	auipc	a0,0x6
     bc6:	88e50513          	addi	a0,a0,-1906 # 6450 <malloc+0x628>
     bca:	5a1040ef          	jal	596a <unlink>
     bce:	e555                	bnez	a0,c7a <unlinkread+0x106>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     bd0:	20200593          	li	a1,514
     bd4:	00006517          	auipc	a0,0x6
     bd8:	87c50513          	addi	a0,a0,-1924 # 6450 <malloc+0x628>
     bdc:	57f040ef          	jal	595a <open>
     be0:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     be2:	460d                	li	a2,3
     be4:	00006597          	auipc	a1,0x6
     be8:	8e458593          	addi	a1,a1,-1820 # 64c8 <malloc+0x6a0>
     bec:	54f040ef          	jal	593a <write>
  close(fd1);
     bf0:	854a                	mv	a0,s2
     bf2:	551040ef          	jal	5942 <close>
  if (read(fd, buf, sizeof(buf)) != SZ) {
     bf6:	660d                	lui	a2,0x3
     bf8:	0000e597          	auipc	a1,0xe
     bfc:	11058593          	addi	a1,a1,272 # ed08 <buf>
     c00:	8526                	mv	a0,s1
     c02:	531040ef          	jal	5932 <read>
     c06:	4795                	li	a5,5
     c08:	08f51363          	bne	a0,a5,c8e <unlinkread+0x11a>
  if (buf[0] != 'h') {
     c0c:	0000e717          	auipc	a4,0xe
     c10:	0fc74703          	lbu	a4,252(a4) # ed08 <buf>
     c14:	06800793          	li	a5,104
     c18:	08f71563          	bne	a4,a5,ca2 <unlinkread+0x12e>
  if (write(fd, buf, 10) != 10) {
     c1c:	4629                	li	a2,10
     c1e:	0000e597          	auipc	a1,0xe
     c22:	0ea58593          	addi	a1,a1,234 # ed08 <buf>
     c26:	8526                	mv	a0,s1
     c28:	513040ef          	jal	593a <write>
     c2c:	47a9                	li	a5,10
     c2e:	08f51463          	bne	a0,a5,cb6 <unlinkread+0x142>
  close(fd);
     c32:	8526                	mv	a0,s1
     c34:	50f040ef          	jal	5942 <close>
  unlink("unlinkread");
     c38:	00006517          	auipc	a0,0x6
     c3c:	81850513          	addi	a0,a0,-2024 # 6450 <malloc+0x628>
     c40:	52b040ef          	jal	596a <unlink>
}
     c44:	70a2                	ld	ra,40(sp)
     c46:	7402                	ld	s0,32(sp)
     c48:	64e2                	ld	s1,24(sp)
     c4a:	6942                	ld	s2,16(sp)
     c4c:	69a2                	ld	s3,8(sp)
     c4e:	6145                	addi	sp,sp,48
     c50:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     c52:	85ce                	mv	a1,s3
     c54:	00006517          	auipc	a0,0x6
     c58:	80c50513          	addi	a0,a0,-2036 # 6460 <malloc+0x638>
     c5c:	114050ef          	jal	5d70 <printf>
    exit(1);
     c60:	4505                	li	a0,1
     c62:	4b9040ef          	jal	591a <exit>
    printf("%s: open unlinkread failed\n", s);
     c66:	85ce                	mv	a1,s3
     c68:	00006517          	auipc	a0,0x6
     c6c:	82050513          	addi	a0,a0,-2016 # 6488 <malloc+0x660>
     c70:	100050ef          	jal	5d70 <printf>
    exit(1);
     c74:	4505                	li	a0,1
     c76:	4a5040ef          	jal	591a <exit>
    printf("%s: unlink unlinkread failed\n", s);
     c7a:	85ce                	mv	a1,s3
     c7c:	00006517          	auipc	a0,0x6
     c80:	82c50513          	addi	a0,a0,-2004 # 64a8 <malloc+0x680>
     c84:	0ec050ef          	jal	5d70 <printf>
    exit(1);
     c88:	4505                	li	a0,1
     c8a:	491040ef          	jal	591a <exit>
    printf("%s: unlinkread read failed", s);
     c8e:	85ce                	mv	a1,s3
     c90:	00006517          	auipc	a0,0x6
     c94:	84050513          	addi	a0,a0,-1984 # 64d0 <malloc+0x6a8>
     c98:	0d8050ef          	jal	5d70 <printf>
    exit(1);
     c9c:	4505                	li	a0,1
     c9e:	47d040ef          	jal	591a <exit>
    printf("%s: unlinkread wrong data\n", s);
     ca2:	85ce                	mv	a1,s3
     ca4:	00006517          	auipc	a0,0x6
     ca8:	84c50513          	addi	a0,a0,-1972 # 64f0 <malloc+0x6c8>
     cac:	0c4050ef          	jal	5d70 <printf>
    exit(1);
     cb0:	4505                	li	a0,1
     cb2:	469040ef          	jal	591a <exit>
    printf("%s: unlinkread write failed\n", s);
     cb6:	85ce                	mv	a1,s3
     cb8:	00006517          	auipc	a0,0x6
     cbc:	85850513          	addi	a0,a0,-1960 # 6510 <malloc+0x6e8>
     cc0:	0b0050ef          	jal	5d70 <printf>
    exit(1);
     cc4:	4505                	li	a0,1
     cc6:	455040ef          	jal	591a <exit>

0000000000000cca <linktest>:
{
     cca:	1101                	addi	sp,sp,-32
     ccc:	ec06                	sd	ra,24(sp)
     cce:	e822                	sd	s0,16(sp)
     cd0:	e426                	sd	s1,8(sp)
     cd2:	e04a                	sd	s2,0(sp)
     cd4:	1000                	addi	s0,sp,32
     cd6:	892a                	mv	s2,a0
  unlink("lf1");
     cd8:	00006517          	auipc	a0,0x6
     cdc:	85850513          	addi	a0,a0,-1960 # 6530 <malloc+0x708>
     ce0:	48b040ef          	jal	596a <unlink>
  unlink("lf2");
     ce4:	00006517          	auipc	a0,0x6
     ce8:	85450513          	addi	a0,a0,-1964 # 6538 <malloc+0x710>
     cec:	47f040ef          	jal	596a <unlink>
  fd = open("lf1", O_CREATE | O_RDWR);
     cf0:	20200593          	li	a1,514
     cf4:	00006517          	auipc	a0,0x6
     cf8:	83c50513          	addi	a0,a0,-1988 # 6530 <malloc+0x708>
     cfc:	45f040ef          	jal	595a <open>
  if (fd < 0) {
     d00:	0c054f63          	bltz	a0,dde <linktest+0x114>
     d04:	84aa                	mv	s1,a0
  if (write(fd, "hello", SZ) != SZ) {
     d06:	4615                	li	a2,5
     d08:	00005597          	auipc	a1,0x5
     d0c:	77858593          	addi	a1,a1,1912 # 6480 <malloc+0x658>
     d10:	42b040ef          	jal	593a <write>
     d14:	4795                	li	a5,5
     d16:	0cf51e63          	bne	a0,a5,df2 <linktest+0x128>
  close(fd);
     d1a:	8526                	mv	a0,s1
     d1c:	427040ef          	jal	5942 <close>
  if (link("lf1", "lf2") < 0) {
     d20:	00006597          	auipc	a1,0x6
     d24:	81858593          	addi	a1,a1,-2024 # 6538 <malloc+0x710>
     d28:	00006517          	auipc	a0,0x6
     d2c:	80850513          	addi	a0,a0,-2040 # 6530 <malloc+0x708>
     d30:	44b040ef          	jal	597a <link>
     d34:	0c054963          	bltz	a0,e06 <linktest+0x13c>
  unlink("lf1");
     d38:	00005517          	auipc	a0,0x5
     d3c:	7f850513          	addi	a0,a0,2040 # 6530 <malloc+0x708>
     d40:	42b040ef          	jal	596a <unlink>
  if (open("lf1", 0) >= 0) {
     d44:	4581                	li	a1,0
     d46:	00005517          	auipc	a0,0x5
     d4a:	7ea50513          	addi	a0,a0,2026 # 6530 <malloc+0x708>
     d4e:	40d040ef          	jal	595a <open>
     d52:	0c055463          	bgez	a0,e1a <linktest+0x150>
  fd = open("lf2", 0);
     d56:	4581                	li	a1,0
     d58:	00005517          	auipc	a0,0x5
     d5c:	7e050513          	addi	a0,a0,2016 # 6538 <malloc+0x710>
     d60:	3fb040ef          	jal	595a <open>
     d64:	84aa                	mv	s1,a0
  if (fd < 0) {
     d66:	0c054463          	bltz	a0,e2e <linktest+0x164>
  if (read(fd, buf, sizeof(buf)) != SZ) {
     d6a:	660d                	lui	a2,0x3
     d6c:	0000e597          	auipc	a1,0xe
     d70:	f9c58593          	addi	a1,a1,-100 # ed08 <buf>
     d74:	3bf040ef          	jal	5932 <read>
     d78:	4795                	li	a5,5
     d7a:	0cf51463          	bne	a0,a5,e42 <linktest+0x178>
  close(fd);
     d7e:	8526                	mv	a0,s1
     d80:	3c3040ef          	jal	5942 <close>
  if (link("lf2", "lf2") >= 0) {
     d84:	00005597          	auipc	a1,0x5
     d88:	7b458593          	addi	a1,a1,1972 # 6538 <malloc+0x710>
     d8c:	852e                	mv	a0,a1
     d8e:	3ed040ef          	jal	597a <link>
     d92:	0c055263          	bgez	a0,e56 <linktest+0x18c>
  unlink("lf2");
     d96:	00005517          	auipc	a0,0x5
     d9a:	7a250513          	addi	a0,a0,1954 # 6538 <malloc+0x710>
     d9e:	3cd040ef          	jal	596a <unlink>
  if (link("lf2", "lf1") >= 0) {
     da2:	00005597          	auipc	a1,0x5
     da6:	78e58593          	addi	a1,a1,1934 # 6530 <malloc+0x708>
     daa:	00005517          	auipc	a0,0x5
     dae:	78e50513          	addi	a0,a0,1934 # 6538 <malloc+0x710>
     db2:	3c9040ef          	jal	597a <link>
     db6:	0a055a63          	bgez	a0,e6a <linktest+0x1a0>
  if (link(".", "lf1") >= 0) {
     dba:	00005597          	auipc	a1,0x5
     dbe:	77658593          	addi	a1,a1,1910 # 6530 <malloc+0x708>
     dc2:	00006517          	auipc	a0,0x6
     dc6:	87e50513          	addi	a0,a0,-1922 # 6640 <malloc+0x818>
     dca:	3b1040ef          	jal	597a <link>
     dce:	0a055863          	bgez	a0,e7e <linktest+0x1b4>
}
     dd2:	60e2                	ld	ra,24(sp)
     dd4:	6442                	ld	s0,16(sp)
     dd6:	64a2                	ld	s1,8(sp)
     dd8:	6902                	ld	s2,0(sp)
     dda:	6105                	addi	sp,sp,32
     ddc:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     dde:	85ca                	mv	a1,s2
     de0:	00005517          	auipc	a0,0x5
     de4:	76050513          	addi	a0,a0,1888 # 6540 <malloc+0x718>
     de8:	789040ef          	jal	5d70 <printf>
    exit(1);
     dec:	4505                	li	a0,1
     dee:	32d040ef          	jal	591a <exit>
    printf("%s: write lf1 failed\n", s);
     df2:	85ca                	mv	a1,s2
     df4:	00005517          	auipc	a0,0x5
     df8:	76450513          	addi	a0,a0,1892 # 6558 <malloc+0x730>
     dfc:	775040ef          	jal	5d70 <printf>
    exit(1);
     e00:	4505                	li	a0,1
     e02:	319040ef          	jal	591a <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     e06:	85ca                	mv	a1,s2
     e08:	00005517          	auipc	a0,0x5
     e0c:	76850513          	addi	a0,a0,1896 # 6570 <malloc+0x748>
     e10:	761040ef          	jal	5d70 <printf>
    exit(1);
     e14:	4505                	li	a0,1
     e16:	305040ef          	jal	591a <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     e1a:	85ca                	mv	a1,s2
     e1c:	00005517          	auipc	a0,0x5
     e20:	77450513          	addi	a0,a0,1908 # 6590 <malloc+0x768>
     e24:	74d040ef          	jal	5d70 <printf>
    exit(1);
     e28:	4505                	li	a0,1
     e2a:	2f1040ef          	jal	591a <exit>
    printf("%s: open lf2 failed\n", s);
     e2e:	85ca                	mv	a1,s2
     e30:	00005517          	auipc	a0,0x5
     e34:	79050513          	addi	a0,a0,1936 # 65c0 <malloc+0x798>
     e38:	739040ef          	jal	5d70 <printf>
    exit(1);
     e3c:	4505                	li	a0,1
     e3e:	2dd040ef          	jal	591a <exit>
    printf("%s: read lf2 failed\n", s);
     e42:	85ca                	mv	a1,s2
     e44:	00005517          	auipc	a0,0x5
     e48:	79450513          	addi	a0,a0,1940 # 65d8 <malloc+0x7b0>
     e4c:	725040ef          	jal	5d70 <printf>
    exit(1);
     e50:	4505                	li	a0,1
     e52:	2c9040ef          	jal	591a <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     e56:	85ca                	mv	a1,s2
     e58:	00005517          	auipc	a0,0x5
     e5c:	79850513          	addi	a0,a0,1944 # 65f0 <malloc+0x7c8>
     e60:	711040ef          	jal	5d70 <printf>
    exit(1);
     e64:	4505                	li	a0,1
     e66:	2b5040ef          	jal	591a <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
     e6a:	85ca                	mv	a1,s2
     e6c:	00005517          	auipc	a0,0x5
     e70:	7ac50513          	addi	a0,a0,1964 # 6618 <malloc+0x7f0>
     e74:	6fd040ef          	jal	5d70 <printf>
    exit(1);
     e78:	4505                	li	a0,1
     e7a:	2a1040ef          	jal	591a <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     e7e:	85ca                	mv	a1,s2
     e80:	00005517          	auipc	a0,0x5
     e84:	7c850513          	addi	a0,a0,1992 # 6648 <malloc+0x820>
     e88:	6e9040ef          	jal	5d70 <printf>
    exit(1);
     e8c:	4505                	li	a0,1
     e8e:	28d040ef          	jal	591a <exit>

0000000000000e92 <validatetest>:
{
     e92:	7139                	addi	sp,sp,-64
     e94:	fc06                	sd	ra,56(sp)
     e96:	f822                	sd	s0,48(sp)
     e98:	f426                	sd	s1,40(sp)
     e9a:	f04a                	sd	s2,32(sp)
     e9c:	ec4e                	sd	s3,24(sp)
     e9e:	e852                	sd	s4,16(sp)
     ea0:	e456                	sd	s5,8(sp)
     ea2:	e05a                	sd	s6,0(sp)
     ea4:	0080                	addi	s0,sp,64
     ea6:	8b2a                	mv	s6,a0
  for (p = 0; p <= (uint)hi; p += PGSIZE) {
     ea8:	4481                	li	s1,0
    if (link("nosuchfile", (char *)p) != -1) {
     eaa:	00005997          	auipc	s3,0x5
     eae:	7be98993          	addi	s3,s3,1982 # 6668 <malloc+0x840>
     eb2:	597d                	li	s2,-1
  for (p = 0; p <= (uint)hi; p += PGSIZE) {
     eb4:	6a85                	lui	s5,0x1
     eb6:	00114a37          	lui	s4,0x114
    if (link("nosuchfile", (char *)p) != -1) {
     eba:	85a6                	mv	a1,s1
     ebc:	854e                	mv	a0,s3
     ebe:	2bd040ef          	jal	597a <link>
     ec2:	01251f63          	bne	a0,s2,ee0 <validatetest+0x4e>
  for (p = 0; p <= (uint)hi; p += PGSIZE) {
     ec6:	94d6                	add	s1,s1,s5
     ec8:	ff4499e3          	bne	s1,s4,eba <validatetest+0x28>
}
     ecc:	70e2                	ld	ra,56(sp)
     ece:	7442                	ld	s0,48(sp)
     ed0:	74a2                	ld	s1,40(sp)
     ed2:	7902                	ld	s2,32(sp)
     ed4:	69e2                	ld	s3,24(sp)
     ed6:	6a42                	ld	s4,16(sp)
     ed8:	6aa2                	ld	s5,8(sp)
     eda:	6b02                	ld	s6,0(sp)
     edc:	6121                	addi	sp,sp,64
     ede:	8082                	ret
      printf("%s: link should not succeed\n", s);
     ee0:	85da                	mv	a1,s6
     ee2:	00005517          	auipc	a0,0x5
     ee6:	79650513          	addi	a0,a0,1942 # 6678 <malloc+0x850>
     eea:	687040ef          	jal	5d70 <printf>
      exit(1);
     eee:	4505                	li	a0,1
     ef0:	22b040ef          	jal	591a <exit>

0000000000000ef4 <bigdir>:
{
     ef4:	711d                	addi	sp,sp,-96
     ef6:	ec86                	sd	ra,88(sp)
     ef8:	e8a2                	sd	s0,80(sp)
     efa:	e4a6                	sd	s1,72(sp)
     efc:	e0ca                	sd	s2,64(sp)
     efe:	fc4e                	sd	s3,56(sp)
     f00:	f852                	sd	s4,48(sp)
     f02:	f456                	sd	s5,40(sp)
     f04:	f05a                	sd	s6,32(sp)
     f06:	ec5e                	sd	s7,24(sp)
     f08:	1080                	addi	s0,sp,96
     f0a:	8baa                	mv	s7,a0
  unlink("bd");
     f0c:	00005517          	auipc	a0,0x5
     f10:	78c50513          	addi	a0,a0,1932 # 6698 <malloc+0x870>
     f14:	257040ef          	jal	596a <unlink>
  fd = open("bd", O_CREATE);
     f18:	20000593          	li	a1,512
     f1c:	00005517          	auipc	a0,0x5
     f20:	77c50513          	addi	a0,a0,1916 # 6698 <malloc+0x870>
     f24:	237040ef          	jal	595a <open>
  if (fd < 0) {
     f28:	0c054463          	bltz	a0,ff0 <bigdir+0xfc>
  close(fd);
     f2c:	217040ef          	jal	5942 <close>
  for (i = 0; i < N; i++) {
     f30:	4901                	li	s2,0
    name[0] = 'x';
     f32:	07800a93          	li	s5,120
    if (link("bd", name) != 0) {
     f36:	fa040a13          	addi	s4,s0,-96
     f3a:	00005997          	auipc	s3,0x5
     f3e:	75e98993          	addi	s3,s3,1886 # 6698 <malloc+0x870>
  for (i = 0; i < N; i++) {
     f42:	1f400b13          	li	s6,500
    name[0] = 'x';
     f46:	fb540023          	sb	s5,-96(s0)
    name[1] = '0' + (i / 64);
     f4a:	41f9571b          	sraiw	a4,s2,0x1f
     f4e:	01a7571b          	srliw	a4,a4,0x1a
     f52:	012707bb          	addw	a5,a4,s2
     f56:	4067d69b          	sraiw	a3,a5,0x6
     f5a:	0306869b          	addiw	a3,a3,48
     f5e:	fad400a3          	sb	a3,-95(s0)
    name[2] = '0' + (i % 64);
     f62:	03f7f793          	andi	a5,a5,63
     f66:	9f99                	subw	a5,a5,a4
     f68:	0307879b          	addiw	a5,a5,48
     f6c:	faf40123          	sb	a5,-94(s0)
    name[3] = '\0';
     f70:	fa0401a3          	sb	zero,-93(s0)
    if (link("bd", name) != 0) {
     f74:	85d2                	mv	a1,s4
     f76:	854e                	mv	a0,s3
     f78:	203040ef          	jal	597a <link>
     f7c:	84aa                	mv	s1,a0
     f7e:	e159                	bnez	a0,1004 <bigdir+0x110>
  for (i = 0; i < N; i++) {
     f80:	2905                	addiw	s2,s2,1
     f82:	fd6912e3          	bne	s2,s6,f46 <bigdir+0x52>
  unlink("bd");
     f86:	00005517          	auipc	a0,0x5
     f8a:	71250513          	addi	a0,a0,1810 # 6698 <malloc+0x870>
     f8e:	1dd040ef          	jal	596a <unlink>
    name[0] = 'x';
     f92:	07800993          	li	s3,120
    if (unlink(name) != 0) {
     f96:	fa040913          	addi	s2,s0,-96
  for (i = 0; i < N; i++) {
     f9a:	1f400a13          	li	s4,500
    name[0] = 'x';
     f9e:	fb340023          	sb	s3,-96(s0)
    name[1] = '0' + (i / 64);
     fa2:	41f4d71b          	sraiw	a4,s1,0x1f
     fa6:	01a7571b          	srliw	a4,a4,0x1a
     faa:	009707bb          	addw	a5,a4,s1
     fae:	4067d69b          	sraiw	a3,a5,0x6
     fb2:	0306869b          	addiw	a3,a3,48
     fb6:	fad400a3          	sb	a3,-95(s0)
    name[2] = '0' + (i % 64);
     fba:	03f7f793          	andi	a5,a5,63
     fbe:	9f99                	subw	a5,a5,a4
     fc0:	0307879b          	addiw	a5,a5,48
     fc4:	faf40123          	sb	a5,-94(s0)
    name[3] = '\0';
     fc8:	fa0401a3          	sb	zero,-93(s0)
    if (unlink(name) != 0) {
     fcc:	854a                	mv	a0,s2
     fce:	19d040ef          	jal	596a <unlink>
     fd2:	e531                	bnez	a0,101e <bigdir+0x12a>
  for (i = 0; i < N; i++) {
     fd4:	2485                	addiw	s1,s1,1
     fd6:	fd4494e3          	bne	s1,s4,f9e <bigdir+0xaa>
}
     fda:	60e6                	ld	ra,88(sp)
     fdc:	6446                	ld	s0,80(sp)
     fde:	64a6                	ld	s1,72(sp)
     fe0:	6906                	ld	s2,64(sp)
     fe2:	79e2                	ld	s3,56(sp)
     fe4:	7a42                	ld	s4,48(sp)
     fe6:	7aa2                	ld	s5,40(sp)
     fe8:	7b02                	ld	s6,32(sp)
     fea:	6be2                	ld	s7,24(sp)
     fec:	6125                	addi	sp,sp,96
     fee:	8082                	ret
    printf("%s: bigdir create failed\n", s);
     ff0:	85de                	mv	a1,s7
     ff2:	00005517          	auipc	a0,0x5
     ff6:	6ae50513          	addi	a0,a0,1710 # 66a0 <malloc+0x878>
     ffa:	577040ef          	jal	5d70 <printf>
    exit(1);
     ffe:	4505                	li	a0,1
    1000:	11b040ef          	jal	591a <exit>
      printf("%s: bigdir i=%d link(bd, %s) failed\n", s, i, name);
    1004:	fa040693          	addi	a3,s0,-96
    1008:	864a                	mv	a2,s2
    100a:	85de                	mv	a1,s7
    100c:	00005517          	auipc	a0,0x5
    1010:	6b450513          	addi	a0,a0,1716 # 66c0 <malloc+0x898>
    1014:	55d040ef          	jal	5d70 <printf>
      exit(1);
    1018:	4505                	li	a0,1
    101a:	101040ef          	jal	591a <exit>
      printf("%s: bigdir unlink failed", s);
    101e:	85de                	mv	a1,s7
    1020:	00005517          	auipc	a0,0x5
    1024:	6c850513          	addi	a0,a0,1736 # 66e8 <malloc+0x8c0>
    1028:	549040ef          	jal	5d70 <printf>
      exit(1);
    102c:	4505                	li	a0,1
    102e:	0ed040ef          	jal	591a <exit>

0000000000001032 <pgbug>:
{
    1032:	7179                	addi	sp,sp,-48
    1034:	f406                	sd	ra,40(sp)
    1036:	f022                	sd	s0,32(sp)
    1038:	ec26                	sd	s1,24(sp)
    103a:	1800                	addi	s0,sp,48
  argv[0] = 0;
    103c:	fc043c23          	sd	zero,-40(s0)
  exec(big, argv);
    1040:	0000a497          	auipc	s1,0xa
    1044:	fc048493          	addi	s1,s1,-64 # b000 <big>
    1048:	fd840593          	addi	a1,s0,-40
    104c:	6088                	ld	a0,0(s1)
    104e:	105040ef          	jal	5952 <exec>
  pipe(big);
    1052:	6088                	ld	a0,0(s1)
    1054:	0d7040ef          	jal	592a <pipe>
  exit(0);
    1058:	4501                	li	a0,0
    105a:	0c1040ef          	jal	591a <exit>

000000000000105e <badarg>:
{
    105e:	7139                	addi	sp,sp,-64
    1060:	fc06                	sd	ra,56(sp)
    1062:	f822                	sd	s0,48(sp)
    1064:	f426                	sd	s1,40(sp)
    1066:	f04a                	sd	s2,32(sp)
    1068:	ec4e                	sd	s3,24(sp)
    106a:	e852                	sd	s4,16(sp)
    106c:	0080                	addi	s0,sp,64
    106e:	64b1                	lui	s1,0xc
    1070:	35048493          	addi	s1,s1,848 # c350 <big.0+0xd60>
    argv[0] = (char *)0xffffffff;
    1074:	597d                	li	s2,-1
    1076:	02095913          	srli	s2,s2,0x20
    exec("echo", argv);
    107a:	fc040a13          	addi	s4,s0,-64
    107e:	00005997          	auipc	s3,0x5
    1082:	eda98993          	addi	s3,s3,-294 # 5f58 <malloc+0x130>
    argv[0] = (char *)0xffffffff;
    1086:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    108a:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    108e:	85d2                	mv	a1,s4
    1090:	854e                	mv	a0,s3
    1092:	0c1040ef          	jal	5952 <exec>
  for (int i = 0; i < 50000; i++) {
    1096:	34fd                	addiw	s1,s1,-1
    1098:	f4fd                	bnez	s1,1086 <badarg+0x28>
  exit(0);
    109a:	4501                	li	a0,0
    109c:	07f040ef          	jal	591a <exit>

00000000000010a0 <copyinstr2>:
{
    10a0:	7155                	addi	sp,sp,-208
    10a2:	e586                	sd	ra,200(sp)
    10a4:	e1a2                	sd	s0,192(sp)
    10a6:	0980                	addi	s0,sp,208
  for (int i = 0; i < MAXPATH; i++)
    10a8:	f6840793          	addi	a5,s0,-152
    10ac:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    10b0:	07800713          	li	a4,120
    10b4:	00e78023          	sb	a4,0(a5)
  for (int i = 0; i < MAXPATH; i++)
    10b8:	0785                	addi	a5,a5,1
    10ba:	fed79de3          	bne	a5,a3,10b4 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    10be:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    10c2:	f6840513          	addi	a0,s0,-152
    10c6:	0a5040ef          	jal	596a <unlink>
  if (ret != -1) {
    10ca:	57fd                	li	a5,-1
    10cc:	0cf51263          	bne	a0,a5,1190 <copyinstr2+0xf0>
  int fd = open(b, O_CREATE | O_WRONLY);
    10d0:	20100593          	li	a1,513
    10d4:	f6840513          	addi	a0,s0,-152
    10d8:	083040ef          	jal	595a <open>
  if (fd != -1) {
    10dc:	57fd                	li	a5,-1
    10de:	0cf51563          	bne	a0,a5,11a8 <copyinstr2+0x108>
  ret = link(b, b);
    10e2:	f6840513          	addi	a0,s0,-152
    10e6:	85aa                	mv	a1,a0
    10e8:	093040ef          	jal	597a <link>
  if (ret != -1) {
    10ec:	57fd                	li	a5,-1
    10ee:	0cf51963          	bne	a0,a5,11c0 <copyinstr2+0x120>
  char *args[] = {"xx", 0};
    10f2:	00006797          	auipc	a5,0x6
    10f6:	6de78793          	addi	a5,a5,1758 # 77d0 <malloc+0x19a8>
    10fa:	f4f43c23          	sd	a5,-168(s0)
    10fe:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1102:	f5840593          	addi	a1,s0,-168
    1106:	f6840513          	addi	a0,s0,-152
    110a:	049040ef          	jal	5952 <exec>
  if (ret != -1) {
    110e:	57fd                	li	a5,-1
    1110:	0cf51563          	bne	a0,a5,11da <copyinstr2+0x13a>
  int pid = fork();
    1114:	7fe040ef          	jal	5912 <fork>
  if (pid < 0) {
    1118:	0c054d63          	bltz	a0,11f2 <copyinstr2+0x152>
  if (pid == 0) {
    111c:	0e051863          	bnez	a0,120c <copyinstr2+0x16c>
    1120:	0000a797          	auipc	a5,0xa
    1124:	4d078793          	addi	a5,a5,1232 # b5f0 <big.0>
    1128:	0000b697          	auipc	a3,0xb
    112c:	4c868693          	addi	a3,a3,1224 # c5f0 <big.0+0x1000>
      big[i] = 'x';
    1130:	07800713          	li	a4,120
    1134:	00e78023          	sb	a4,0(a5)
    for (int i = 0; i < PGSIZE; i++)
    1138:	0785                	addi	a5,a5,1
    113a:	fed79de3          	bne	a5,a3,1134 <copyinstr2+0x94>
    big[PGSIZE] = '\0';
    113e:	0000b797          	auipc	a5,0xb
    1142:	4a078923          	sb	zero,1202(a5) # c5f0 <big.0+0x1000>
    char *args2[] = {big, big, big, 0};
    1146:	00007797          	auipc	a5,0x7
    114a:	7ca78793          	addi	a5,a5,1994 # 8910 <malloc+0x2ae8>
    114e:	6fb0                	ld	a2,88(a5)
    1150:	73b4                	ld	a3,96(a5)
    1152:	77b8                	ld	a4,104(a5)
    1154:	f2c43823          	sd	a2,-208(s0)
    1158:	f2d43c23          	sd	a3,-200(s0)
    115c:	f4e43023          	sd	a4,-192(s0)
    1160:	7bbc                	ld	a5,112(a5)
    1162:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    1166:	f3040593          	addi	a1,s0,-208
    116a:	00005517          	auipc	a0,0x5
    116e:	dee50513          	addi	a0,a0,-530 # 5f58 <malloc+0x130>
    1172:	7e0040ef          	jal	5952 <exec>
    if (ret != -1) {
    1176:	57fd                	li	a5,-1
    1178:	08f50663          	beq	a0,a5,1204 <copyinstr2+0x164>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    117c:	85be                	mv	a1,a5
    117e:	00005517          	auipc	a0,0x5
    1182:	61250513          	addi	a0,a0,1554 # 6790 <malloc+0x968>
    1186:	3eb040ef          	jal	5d70 <printf>
      exit(1);
    118a:	4505                	li	a0,1
    118c:	78e040ef          	jal	591a <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    1190:	862a                	mv	a2,a0
    1192:	f6840593          	addi	a1,s0,-152
    1196:	00005517          	auipc	a0,0x5
    119a:	57250513          	addi	a0,a0,1394 # 6708 <malloc+0x8e0>
    119e:	3d3040ef          	jal	5d70 <printf>
    exit(1);
    11a2:	4505                	li	a0,1
    11a4:	776040ef          	jal	591a <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    11a8:	862a                	mv	a2,a0
    11aa:	f6840593          	addi	a1,s0,-152
    11ae:	00005517          	auipc	a0,0x5
    11b2:	57a50513          	addi	a0,a0,1402 # 6728 <malloc+0x900>
    11b6:	3bb040ef          	jal	5d70 <printf>
    exit(1);
    11ba:	4505                	li	a0,1
    11bc:	75e040ef          	jal	591a <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    11c0:	f6840593          	addi	a1,s0,-152
    11c4:	86aa                	mv	a3,a0
    11c6:	862e                	mv	a2,a1
    11c8:	00005517          	auipc	a0,0x5
    11cc:	58050513          	addi	a0,a0,1408 # 6748 <malloc+0x920>
    11d0:	3a1040ef          	jal	5d70 <printf>
    exit(1);
    11d4:	4505                	li	a0,1
    11d6:	744040ef          	jal	591a <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    11da:	863e                	mv	a2,a5
    11dc:	f6840593          	addi	a1,s0,-152
    11e0:	00005517          	auipc	a0,0x5
    11e4:	59050513          	addi	a0,a0,1424 # 6770 <malloc+0x948>
    11e8:	389040ef          	jal	5d70 <printf>
    exit(1);
    11ec:	4505                	li	a0,1
    11ee:	72c040ef          	jal	591a <exit>
    printf("fork failed\n");
    11f2:	00007517          	auipc	a0,0x7
    11f6:	d7650513          	addi	a0,a0,-650 # 7f68 <malloc+0x2140>
    11fa:	377040ef          	jal	5d70 <printf>
    exit(1);
    11fe:	4505                	li	a0,1
    1200:	71a040ef          	jal	591a <exit>
    exit(747); // OK
    1204:	2eb00513          	li	a0,747
    1208:	712040ef          	jal	591a <exit>
  int st = 0;
    120c:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    1210:	f5440513          	addi	a0,s0,-172
    1214:	70e040ef          	jal	5922 <wait>
  if (st != 747) {
    1218:	f5442703          	lw	a4,-172(s0)
    121c:	2eb00793          	li	a5,747
    1220:	00f71663          	bne	a4,a5,122c <copyinstr2+0x18c>
}
    1224:	60ae                	ld	ra,200(sp)
    1226:	640e                	ld	s0,192(sp)
    1228:	6169                	addi	sp,sp,208
    122a:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    122c:	00005517          	auipc	a0,0x5
    1230:	58c50513          	addi	a0,a0,1420 # 67b8 <malloc+0x990>
    1234:	33d040ef          	jal	5d70 <printf>
    exit(1);
    1238:	4505                	li	a0,1
    123a:	6e0040ef          	jal	591a <exit>

000000000000123e <truncate3>:
{
    123e:	7175                	addi	sp,sp,-144
    1240:	e506                	sd	ra,136(sp)
    1242:	e122                	sd	s0,128(sp)
    1244:	fc66                	sd	s9,56(sp)
    1246:	0900                	addi	s0,sp,144
    1248:	8caa                	mv	s9,a0
  close(open("truncfile", O_CREATE | O_TRUNC | O_WRONLY));
    124a:	60100593          	li	a1,1537
    124e:	00005517          	auipc	a0,0x5
    1252:	d6250513          	addi	a0,a0,-670 # 5fb0 <malloc+0x188>
    1256:	704040ef          	jal	595a <open>
    125a:	6e8040ef          	jal	5942 <close>
  pid = fork();
    125e:	6b4040ef          	jal	5912 <fork>
  if (pid < 0) {
    1262:	06054d63          	bltz	a0,12dc <truncate3+0x9e>
  if (pid == 0) {
    1266:	e171                	bnez	a0,132a <truncate3+0xec>
    1268:	fca6                	sd	s1,120(sp)
    126a:	f8ca                	sd	s2,112(sp)
    126c:	f4ce                	sd	s3,104(sp)
    126e:	f0d2                	sd	s4,96(sp)
    1270:	ecd6                	sd	s5,88(sp)
    1272:	e8da                	sd	s6,80(sp)
    1274:	e4de                	sd	s7,72(sp)
    1276:	e0e2                	sd	s8,64(sp)
    1278:	06400913          	li	s2,100
      int fd = open("truncfile", O_WRONLY);
    127c:	4a85                	li	s5,1
    127e:	00005997          	auipc	s3,0x5
    1282:	d3298993          	addi	s3,s3,-718 # 5fb0 <malloc+0x188>
      int n = write(fd, "1234567890", 10);
    1286:	4a29                	li	s4,10
    1288:	00005b17          	auipc	s6,0x5
    128c:	590b0b13          	addi	s6,s6,1424 # 6818 <malloc+0x9f0>
      read(fd, buf, sizeof(buf));
    1290:	f7840c13          	addi	s8,s0,-136
    1294:	02000b93          	li	s7,32
      int fd = open("truncfile", O_WRONLY);
    1298:	85d6                	mv	a1,s5
    129a:	854e                	mv	a0,s3
    129c:	6be040ef          	jal	595a <open>
    12a0:	84aa                	mv	s1,a0
      if (fd < 0) {
    12a2:	04054f63          	bltz	a0,1300 <truncate3+0xc2>
      int n = write(fd, "1234567890", 10);
    12a6:	8652                	mv	a2,s4
    12a8:	85da                	mv	a1,s6
    12aa:	690040ef          	jal	593a <write>
      if (n != 10) {
    12ae:	07451363          	bne	a0,s4,1314 <truncate3+0xd6>
      close(fd);
    12b2:	8526                	mv	a0,s1
    12b4:	68e040ef          	jal	5942 <close>
      fd = open("truncfile", O_RDONLY);
    12b8:	4581                	li	a1,0
    12ba:	854e                	mv	a0,s3
    12bc:	69e040ef          	jal	595a <open>
    12c0:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    12c2:	865e                	mv	a2,s7
    12c4:	85e2                	mv	a1,s8
    12c6:	66c040ef          	jal	5932 <read>
      close(fd);
    12ca:	8526                	mv	a0,s1
    12cc:	676040ef          	jal	5942 <close>
    for (int i = 0; i < 100; i++) {
    12d0:	397d                	addiw	s2,s2,-1
    12d2:	fc0913e3          	bnez	s2,1298 <truncate3+0x5a>
    exit(0);
    12d6:	4501                	li	a0,0
    12d8:	642040ef          	jal	591a <exit>
    12dc:	fca6                	sd	s1,120(sp)
    12de:	f8ca                	sd	s2,112(sp)
    12e0:	f4ce                	sd	s3,104(sp)
    12e2:	f0d2                	sd	s4,96(sp)
    12e4:	ecd6                	sd	s5,88(sp)
    12e6:	e8da                	sd	s6,80(sp)
    12e8:	e4de                	sd	s7,72(sp)
    12ea:	e0e2                	sd	s8,64(sp)
    printf("%s: fork failed\n", s);
    12ec:	85e6                	mv	a1,s9
    12ee:	00005517          	auipc	a0,0x5
    12f2:	4fa50513          	addi	a0,a0,1274 # 67e8 <malloc+0x9c0>
    12f6:	27b040ef          	jal	5d70 <printf>
    exit(1);
    12fa:	4505                	li	a0,1
    12fc:	61e040ef          	jal	591a <exit>
        printf("%s: open failed\n", s);
    1300:	85e6                	mv	a1,s9
    1302:	00005517          	auipc	a0,0x5
    1306:	4fe50513          	addi	a0,a0,1278 # 6800 <malloc+0x9d8>
    130a:	267040ef          	jal	5d70 <printf>
        exit(1);
    130e:	4505                	li	a0,1
    1310:	60a040ef          	jal	591a <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    1314:	862a                	mv	a2,a0
    1316:	85e6                	mv	a1,s9
    1318:	00005517          	auipc	a0,0x5
    131c:	51050513          	addi	a0,a0,1296 # 6828 <malloc+0xa00>
    1320:	251040ef          	jal	5d70 <printf>
        exit(1);
    1324:	4505                	li	a0,1
    1326:	5f4040ef          	jal	591a <exit>
    132a:	fca6                	sd	s1,120(sp)
    132c:	f8ca                	sd	s2,112(sp)
    132e:	f4ce                	sd	s3,104(sp)
    1330:	f0d2                	sd	s4,96(sp)
    1332:	ecd6                	sd	s5,88(sp)
    1334:	e8da                	sd	s6,80(sp)
    1336:	09600913          	li	s2,150
    int fd = open("truncfile", O_CREATE | O_WRONLY | O_TRUNC);
    133a:	60100a93          	li	s5,1537
    133e:	00005a17          	auipc	s4,0x5
    1342:	c72a0a13          	addi	s4,s4,-910 # 5fb0 <malloc+0x188>
    int n = write(fd, "xxx", 3);
    1346:	498d                	li	s3,3
    1348:	00005b17          	auipc	s6,0x5
    134c:	500b0b13          	addi	s6,s6,1280 # 6848 <malloc+0xa20>
    int fd = open("truncfile", O_CREATE | O_WRONLY | O_TRUNC);
    1350:	85d6                	mv	a1,s5
    1352:	8552                	mv	a0,s4
    1354:	606040ef          	jal	595a <open>
    1358:	84aa                	mv	s1,a0
    if (fd < 0) {
    135a:	02054e63          	bltz	a0,1396 <truncate3+0x158>
    int n = write(fd, "xxx", 3);
    135e:	864e                	mv	a2,s3
    1360:	85da                	mv	a1,s6
    1362:	5d8040ef          	jal	593a <write>
    if (n != 3) {
    1366:	05351463          	bne	a0,s3,13ae <truncate3+0x170>
    close(fd);
    136a:	8526                	mv	a0,s1
    136c:	5d6040ef          	jal	5942 <close>
  for (int i = 0; i < 150; i++) {
    1370:	397d                	addiw	s2,s2,-1
    1372:	fc091fe3          	bnez	s2,1350 <truncate3+0x112>
    1376:	e4de                	sd	s7,72(sp)
    1378:	e0e2                	sd	s8,64(sp)
  wait(&xstatus);
    137a:	f9c40513          	addi	a0,s0,-100
    137e:	5a4040ef          	jal	5922 <wait>
  unlink("truncfile");
    1382:	00005517          	auipc	a0,0x5
    1386:	c2e50513          	addi	a0,a0,-978 # 5fb0 <malloc+0x188>
    138a:	5e0040ef          	jal	596a <unlink>
  exit(xstatus);
    138e:	f9c42503          	lw	a0,-100(s0)
    1392:	588040ef          	jal	591a <exit>
    1396:	e4de                	sd	s7,72(sp)
    1398:	e0e2                	sd	s8,64(sp)
      printf("%s: open failed\n", s);
    139a:	85e6                	mv	a1,s9
    139c:	00005517          	auipc	a0,0x5
    13a0:	46450513          	addi	a0,a0,1124 # 6800 <malloc+0x9d8>
    13a4:	1cd040ef          	jal	5d70 <printf>
      exit(1);
    13a8:	4505                	li	a0,1
    13aa:	570040ef          	jal	591a <exit>
    13ae:	e4de                	sd	s7,72(sp)
    13b0:	e0e2                	sd	s8,64(sp)
      printf("%s: write got %d, expected 3\n", s, n);
    13b2:	862a                	mv	a2,a0
    13b4:	85e6                	mv	a1,s9
    13b6:	00005517          	auipc	a0,0x5
    13ba:	49a50513          	addi	a0,a0,1178 # 6850 <malloc+0xa28>
    13be:	1b3040ef          	jal	5d70 <printf>
      exit(1);
    13c2:	4505                	li	a0,1
    13c4:	556040ef          	jal	591a <exit>

00000000000013c8 <pipe1>:
{
    13c8:	711d                	addi	sp,sp,-96
    13ca:	ec86                	sd	ra,88(sp)
    13cc:	e8a2                	sd	s0,80(sp)
    13ce:	e862                	sd	s8,16(sp)
    13d0:	1080                	addi	s0,sp,96
    13d2:	8c2a                	mv	s8,a0
  if (pipe(fds) != 0) {
    13d4:	fa840513          	addi	a0,s0,-88
    13d8:	552040ef          	jal	592a <pipe>
    13dc:	e925                	bnez	a0,144c <pipe1+0x84>
    13de:	e4a6                	sd	s1,72(sp)
    13e0:	fc4e                	sd	s3,56(sp)
    13e2:	84aa                	mv	s1,a0
  pid = fork();
    13e4:	52e040ef          	jal	5912 <fork>
    13e8:	89aa                	mv	s3,a0
  if (pid == 0) {
    13ea:	c151                	beqz	a0,146e <pipe1+0xa6>
  } else if (pid > 0) {
    13ec:	16a05063          	blez	a0,154c <pipe1+0x184>
    13f0:	e0ca                	sd	s2,64(sp)
    13f2:	f852                	sd	s4,48(sp)
    close(fds[1]);
    13f4:	fac42503          	lw	a0,-84(s0)
    13f8:	54a040ef          	jal	5942 <close>
    total = 0;
    13fc:	89a6                	mv	s3,s1
    cc = 1;
    13fe:	4905                	li	s2,1
    while ((n = read(fds[0], buf, cc)) > 0) {
    1400:	0000ea17          	auipc	s4,0xe
    1404:	908a0a13          	addi	s4,s4,-1784 # ed08 <buf>
    1408:	864a                	mv	a2,s2
    140a:	85d2                	mv	a1,s4
    140c:	fa842503          	lw	a0,-88(s0)
    1410:	522040ef          	jal	5932 <read>
    1414:	85aa                	mv	a1,a0
    1416:	0ea05963          	blez	a0,1508 <pipe1+0x140>
    141a:	0000e797          	auipc	a5,0xe
    141e:	8ee78793          	addi	a5,a5,-1810 # ed08 <buf>
    1422:	00b4863b          	addw	a2,s1,a1
        if ((buf[i] & 0xff) != (seq++ & 0xff)) {
    1426:	0007c683          	lbu	a3,0(a5)
    142a:	0ff4f713          	zext.b	a4,s1
    142e:	0ae69d63          	bne	a3,a4,14e8 <pipe1+0x120>
    1432:	2485                	addiw	s1,s1,1
      for (i = 0; i < n; i++) {
    1434:	0785                	addi	a5,a5,1
    1436:	fec498e3          	bne	s1,a2,1426 <pipe1+0x5e>
      total += n;
    143a:	00b989bb          	addw	s3,s3,a1
      cc = cc * 2;
    143e:	0019191b          	slliw	s2,s2,0x1
      if (cc > sizeof(buf))
    1442:	678d                	lui	a5,0x3
    1444:	fd27f2e3          	bgeu	a5,s2,1408 <pipe1+0x40>
        cc = sizeof(buf);
    1448:	893e                	mv	s2,a5
    144a:	bf7d                	j	1408 <pipe1+0x40>
    144c:	e4a6                	sd	s1,72(sp)
    144e:	e0ca                	sd	s2,64(sp)
    1450:	fc4e                	sd	s3,56(sp)
    1452:	f852                	sd	s4,48(sp)
    1454:	f456                	sd	s5,40(sp)
    1456:	f05a                	sd	s6,32(sp)
    1458:	ec5e                	sd	s7,24(sp)
    printf("%s: pipe() failed\n", s);
    145a:	85e2                	mv	a1,s8
    145c:	00005517          	auipc	a0,0x5
    1460:	41450513          	addi	a0,a0,1044 # 6870 <malloc+0xa48>
    1464:	10d040ef          	jal	5d70 <printf>
    exit(1);
    1468:	4505                	li	a0,1
    146a:	4b0040ef          	jal	591a <exit>
    146e:	e0ca                	sd	s2,64(sp)
    1470:	f852                	sd	s4,48(sp)
    1472:	f456                	sd	s5,40(sp)
    1474:	f05a                	sd	s6,32(sp)
    1476:	ec5e                	sd	s7,24(sp)
    close(fds[0]);
    1478:	fa842503          	lw	a0,-88(s0)
    147c:	4c6040ef          	jal	5942 <close>
    for (n = 0; n < N; n++) {
    1480:	0000eb17          	auipc	s6,0xe
    1484:	888b0b13          	addi	s6,s6,-1912 # ed08 <buf>
    1488:	416004bb          	negw	s1,s6
    148c:	0ff4f493          	zext.b	s1,s1
    1490:	409b0913          	addi	s2,s6,1033
      if (write(fds[1], buf, SZ) != SZ) {
    1494:	40900a13          	li	s4,1033
    1498:	8bda                	mv	s7,s6
    for (n = 0; n < N; n++) {
    149a:	6a85                	lui	s5,0x1
    149c:	42da8a93          	addi	s5,s5,1069 # 142d <pipe1+0x65>
{
    14a0:	87da                	mv	a5,s6
        buf[i] = seq++;
    14a2:	0097873b          	addw	a4,a5,s1
    14a6:	00e78023          	sb	a4,0(a5) # 3000 <subdir+0x476>
      for (i = 0; i < SZ; i++)
    14aa:	0785                	addi	a5,a5,1
    14ac:	ff279be3          	bne	a5,s2,14a2 <pipe1+0xda>
      if (write(fds[1], buf, SZ) != SZ) {
    14b0:	8652                	mv	a2,s4
    14b2:	85de                	mv	a1,s7
    14b4:	fac42503          	lw	a0,-84(s0)
    14b8:	482040ef          	jal	593a <write>
    14bc:	01451c63          	bne	a0,s4,14d4 <pipe1+0x10c>
    14c0:	4099899b          	addiw	s3,s3,1033
    for (n = 0; n < N; n++) {
    14c4:	24a5                	addiw	s1,s1,9
    14c6:	0ff4f493          	zext.b	s1,s1
    14ca:	fd599be3          	bne	s3,s5,14a0 <pipe1+0xd8>
    exit(0);
    14ce:	4501                	li	a0,0
    14d0:	44a040ef          	jal	591a <exit>
        printf("%s: pipe1 oops 1\n", s);
    14d4:	85e2                	mv	a1,s8
    14d6:	00005517          	auipc	a0,0x5
    14da:	3b250513          	addi	a0,a0,946 # 6888 <malloc+0xa60>
    14de:	093040ef          	jal	5d70 <printf>
        exit(1);
    14e2:	4505                	li	a0,1
    14e4:	436040ef          	jal	591a <exit>
          printf("%s: pipe1 oops 2\n", s);
    14e8:	85e2                	mv	a1,s8
    14ea:	00005517          	auipc	a0,0x5
    14ee:	3b650513          	addi	a0,a0,950 # 68a0 <malloc+0xa78>
    14f2:	07f040ef          	jal	5d70 <printf>
          return;
    14f6:	64a6                	ld	s1,72(sp)
    14f8:	6906                	ld	s2,64(sp)
    14fa:	79e2                	ld	s3,56(sp)
    14fc:	7a42                	ld	s4,48(sp)
}
    14fe:	60e6                	ld	ra,88(sp)
    1500:	6446                	ld	s0,80(sp)
    1502:	6c42                	ld	s8,16(sp)
    1504:	6125                	addi	sp,sp,96
    1506:	8082                	ret
    if (total != N * SZ) {
    1508:	6785                	lui	a5,0x1
    150a:	42d78793          	addi	a5,a5,1069 # 142d <pipe1+0x65>
    150e:	02f98063          	beq	s3,a5,152e <pipe1+0x166>
    1512:	f456                	sd	s5,40(sp)
    1514:	f05a                	sd	s6,32(sp)
    1516:	ec5e                	sd	s7,24(sp)
      printf("%s: pipe1 oops 3 total %d\n", s, total);
    1518:	864e                	mv	a2,s3
    151a:	85e2                	mv	a1,s8
    151c:	00005517          	auipc	a0,0x5
    1520:	39c50513          	addi	a0,a0,924 # 68b8 <malloc+0xa90>
    1524:	04d040ef          	jal	5d70 <printf>
      exit(1);
    1528:	4505                	li	a0,1
    152a:	3f0040ef          	jal	591a <exit>
    152e:	f456                	sd	s5,40(sp)
    1530:	f05a                	sd	s6,32(sp)
    1532:	ec5e                	sd	s7,24(sp)
    close(fds[0]);
    1534:	fa842503          	lw	a0,-88(s0)
    1538:	40a040ef          	jal	5942 <close>
    wait(&xstatus);
    153c:	fa440513          	addi	a0,s0,-92
    1540:	3e2040ef          	jal	5922 <wait>
    exit(xstatus);
    1544:	fa442503          	lw	a0,-92(s0)
    1548:	3d2040ef          	jal	591a <exit>
    154c:	e0ca                	sd	s2,64(sp)
    154e:	f852                	sd	s4,48(sp)
    1550:	f456                	sd	s5,40(sp)
    1552:	f05a                	sd	s6,32(sp)
    1554:	ec5e                	sd	s7,24(sp)
    printf("%s: fork() failed\n", s);
    1556:	85e2                	mv	a1,s8
    1558:	00005517          	auipc	a0,0x5
    155c:	38050513          	addi	a0,a0,896 # 68d8 <malloc+0xab0>
    1560:	011040ef          	jal	5d70 <printf>
    exit(1);
    1564:	4505                	li	a0,1
    1566:	3b4040ef          	jal	591a <exit>

000000000000156a <exitwait>:
{
    156a:	715d                	addi	sp,sp,-80
    156c:	e486                	sd	ra,72(sp)
    156e:	e0a2                	sd	s0,64(sp)
    1570:	fc26                	sd	s1,56(sp)
    1572:	f84a                	sd	s2,48(sp)
    1574:	f44e                	sd	s3,40(sp)
    1576:	f052                	sd	s4,32(sp)
    1578:	ec56                	sd	s5,24(sp)
    157a:	0880                	addi	s0,sp,80
    157c:	8aaa                	mv	s5,a0
  for (i = 0; i < 100; i++) {
    157e:	4901                	li	s2,0
      if (wait(&xstate) != pid) {
    1580:	fbc40993          	addi	s3,s0,-68
  for (i = 0; i < 100; i++) {
    1584:	06400a13          	li	s4,100
    pid = fork();
    1588:	38a040ef          	jal	5912 <fork>
    158c:	84aa                	mv	s1,a0
    if (pid < 0) {
    158e:	02054863          	bltz	a0,15be <exitwait+0x54>
    if (pid) {
    1592:	c525                	beqz	a0,15fa <exitwait+0x90>
      if (wait(&xstate) != pid) {
    1594:	854e                	mv	a0,s3
    1596:	38c040ef          	jal	5922 <wait>
    159a:	02951c63          	bne	a0,s1,15d2 <exitwait+0x68>
      if (i != xstate) {
    159e:	fbc42783          	lw	a5,-68(s0)
    15a2:	05279263          	bne	a5,s2,15e6 <exitwait+0x7c>
  for (i = 0; i < 100; i++) {
    15a6:	2905                	addiw	s2,s2,1
    15a8:	ff4910e3          	bne	s2,s4,1588 <exitwait+0x1e>
}
    15ac:	60a6                	ld	ra,72(sp)
    15ae:	6406                	ld	s0,64(sp)
    15b0:	74e2                	ld	s1,56(sp)
    15b2:	7942                	ld	s2,48(sp)
    15b4:	79a2                	ld	s3,40(sp)
    15b6:	7a02                	ld	s4,32(sp)
    15b8:	6ae2                	ld	s5,24(sp)
    15ba:	6161                	addi	sp,sp,80
    15bc:	8082                	ret
      printf("%s: fork failed\n", s);
    15be:	85d6                	mv	a1,s5
    15c0:	00005517          	auipc	a0,0x5
    15c4:	22850513          	addi	a0,a0,552 # 67e8 <malloc+0x9c0>
    15c8:	7a8040ef          	jal	5d70 <printf>
      exit(1);
    15cc:	4505                	li	a0,1
    15ce:	34c040ef          	jal	591a <exit>
        printf("%s: wait wrong pid\n", s);
    15d2:	85d6                	mv	a1,s5
    15d4:	00005517          	auipc	a0,0x5
    15d8:	31c50513          	addi	a0,a0,796 # 68f0 <malloc+0xac8>
    15dc:	794040ef          	jal	5d70 <printf>
        exit(1);
    15e0:	4505                	li	a0,1
    15e2:	338040ef          	jal	591a <exit>
        printf("%s: wait wrong exit status\n", s);
    15e6:	85d6                	mv	a1,s5
    15e8:	00005517          	auipc	a0,0x5
    15ec:	32050513          	addi	a0,a0,800 # 6908 <malloc+0xae0>
    15f0:	780040ef          	jal	5d70 <printf>
        exit(1);
    15f4:	4505                	li	a0,1
    15f6:	324040ef          	jal	591a <exit>
      exit(i);
    15fa:	854a                	mv	a0,s2
    15fc:	31e040ef          	jal	591a <exit>

0000000000001600 <twochildren>:
{
    1600:	1101                	addi	sp,sp,-32
    1602:	ec06                	sd	ra,24(sp)
    1604:	e822                	sd	s0,16(sp)
    1606:	e426                	sd	s1,8(sp)
    1608:	e04a                	sd	s2,0(sp)
    160a:	1000                	addi	s0,sp,32
    160c:	892a                	mv	s2,a0
    160e:	3e800493          	li	s1,1000
    int pid1 = fork();
    1612:	300040ef          	jal	5912 <fork>
    if (pid1 < 0) {
    1616:	02054663          	bltz	a0,1642 <twochildren+0x42>
    if (pid1 == 0) {
    161a:	cd15                	beqz	a0,1656 <twochildren+0x56>
      int pid2 = fork();
    161c:	2f6040ef          	jal	5912 <fork>
      if (pid2 < 0) {
    1620:	02054d63          	bltz	a0,165a <twochildren+0x5a>
      if (pid2 == 0) {
    1624:	c529                	beqz	a0,166e <twochildren+0x6e>
        wait(0);
    1626:	4501                	li	a0,0
    1628:	2fa040ef          	jal	5922 <wait>
        wait(0);
    162c:	4501                	li	a0,0
    162e:	2f4040ef          	jal	5922 <wait>
  for (int i = 0; i < 1000; i++) {
    1632:	34fd                	addiw	s1,s1,-1
    1634:	fcf9                	bnez	s1,1612 <twochildren+0x12>
}
    1636:	60e2                	ld	ra,24(sp)
    1638:	6442                	ld	s0,16(sp)
    163a:	64a2                	ld	s1,8(sp)
    163c:	6902                	ld	s2,0(sp)
    163e:	6105                	addi	sp,sp,32
    1640:	8082                	ret
      printf("%s: fork failed\n", s);
    1642:	85ca                	mv	a1,s2
    1644:	00005517          	auipc	a0,0x5
    1648:	1a450513          	addi	a0,a0,420 # 67e8 <malloc+0x9c0>
    164c:	724040ef          	jal	5d70 <printf>
      exit(1);
    1650:	4505                	li	a0,1
    1652:	2c8040ef          	jal	591a <exit>
      exit(0);
    1656:	2c4040ef          	jal	591a <exit>
        printf("%s: fork failed\n", s);
    165a:	85ca                	mv	a1,s2
    165c:	00005517          	auipc	a0,0x5
    1660:	18c50513          	addi	a0,a0,396 # 67e8 <malloc+0x9c0>
    1664:	70c040ef          	jal	5d70 <printf>
        exit(1);
    1668:	4505                	li	a0,1
    166a:	2b0040ef          	jal	591a <exit>
        exit(0);
    166e:	2ac040ef          	jal	591a <exit>

0000000000001672 <forkfork>:
{
    1672:	7179                	addi	sp,sp,-48
    1674:	f406                	sd	ra,40(sp)
    1676:	f022                	sd	s0,32(sp)
    1678:	ec26                	sd	s1,24(sp)
    167a:	1800                	addi	s0,sp,48
    167c:	84aa                	mv	s1,a0
    int pid = fork();
    167e:	294040ef          	jal	5912 <fork>
    if (pid < 0) {
    1682:	02054b63          	bltz	a0,16b8 <forkfork+0x46>
    if (pid == 0) {
    1686:	c139                	beqz	a0,16cc <forkfork+0x5a>
    int pid = fork();
    1688:	28a040ef          	jal	5912 <fork>
    if (pid < 0) {
    168c:	02054663          	bltz	a0,16b8 <forkfork+0x46>
    if (pid == 0) {
    1690:	cd15                	beqz	a0,16cc <forkfork+0x5a>
    wait(&xstatus);
    1692:	fdc40513          	addi	a0,s0,-36
    1696:	28c040ef          	jal	5922 <wait>
    if (xstatus != 0) {
    169a:	fdc42783          	lw	a5,-36(s0)
    169e:	ebb9                	bnez	a5,16f4 <forkfork+0x82>
    wait(&xstatus);
    16a0:	fdc40513          	addi	a0,s0,-36
    16a4:	27e040ef          	jal	5922 <wait>
    if (xstatus != 0) {
    16a8:	fdc42783          	lw	a5,-36(s0)
    16ac:	e7a1                	bnez	a5,16f4 <forkfork+0x82>
}
    16ae:	70a2                	ld	ra,40(sp)
    16b0:	7402                	ld	s0,32(sp)
    16b2:	64e2                	ld	s1,24(sp)
    16b4:	6145                	addi	sp,sp,48
    16b6:	8082                	ret
      printf("%s: fork failed", s);
    16b8:	85a6                	mv	a1,s1
    16ba:	00005517          	auipc	a0,0x5
    16be:	26e50513          	addi	a0,a0,622 # 6928 <malloc+0xb00>
    16c2:	6ae040ef          	jal	5d70 <printf>
      exit(1);
    16c6:	4505                	li	a0,1
    16c8:	252040ef          	jal	591a <exit>
{
    16cc:	0c800493          	li	s1,200
        int pid1 = fork();
    16d0:	242040ef          	jal	5912 <fork>
        if (pid1 < 0) {
    16d4:	00054b63          	bltz	a0,16ea <forkfork+0x78>
        if (pid1 == 0) {
    16d8:	cd01                	beqz	a0,16f0 <forkfork+0x7e>
        wait(0);
    16da:	4501                	li	a0,0
    16dc:	246040ef          	jal	5922 <wait>
      for (int j = 0; j < 200; j++) {
    16e0:	34fd                	addiw	s1,s1,-1
    16e2:	f4fd                	bnez	s1,16d0 <forkfork+0x5e>
      exit(0);
    16e4:	4501                	li	a0,0
    16e6:	234040ef          	jal	591a <exit>
          exit(1);
    16ea:	4505                	li	a0,1
    16ec:	22e040ef          	jal	591a <exit>
          exit(0);
    16f0:	22a040ef          	jal	591a <exit>
      printf("%s: fork in child failed", s);
    16f4:	85a6                	mv	a1,s1
    16f6:	00005517          	auipc	a0,0x5
    16fa:	24250513          	addi	a0,a0,578 # 6938 <malloc+0xb10>
    16fe:	672040ef          	jal	5d70 <printf>
      exit(1);
    1702:	4505                	li	a0,1
    1704:	216040ef          	jal	591a <exit>

0000000000001708 <reparent2>:
{
    1708:	1101                	addi	sp,sp,-32
    170a:	ec06                	sd	ra,24(sp)
    170c:	e822                	sd	s0,16(sp)
    170e:	e426                	sd	s1,8(sp)
    1710:	1000                	addi	s0,sp,32
    1712:	32000493          	li	s1,800
    int pid1 = fork();
    1716:	1fc040ef          	jal	5912 <fork>
    if (pid1 < 0) {
    171a:	00054b63          	bltz	a0,1730 <reparent2+0x28>
    if (pid1 == 0) {
    171e:	c115                	beqz	a0,1742 <reparent2+0x3a>
    wait(0);
    1720:	4501                	li	a0,0
    1722:	200040ef          	jal	5922 <wait>
  for (int i = 0; i < 800; i++) {
    1726:	34fd                	addiw	s1,s1,-1
    1728:	f4fd                	bnez	s1,1716 <reparent2+0xe>
  exit(0);
    172a:	4501                	li	a0,0
    172c:	1ee040ef          	jal	591a <exit>
      printf("fork failed\n");
    1730:	00007517          	auipc	a0,0x7
    1734:	83850513          	addi	a0,a0,-1992 # 7f68 <malloc+0x2140>
    1738:	638040ef          	jal	5d70 <printf>
      exit(1);
    173c:	4505                	li	a0,1
    173e:	1dc040ef          	jal	591a <exit>
      fork();
    1742:	1d0040ef          	jal	5912 <fork>
      fork();
    1746:	1cc040ef          	jal	5912 <fork>
      exit(0);
    174a:	4501                	li	a0,0
    174c:	1ce040ef          	jal	591a <exit>

0000000000001750 <createdelete>:
{
    1750:	7135                	addi	sp,sp,-160
    1752:	ed06                	sd	ra,152(sp)
    1754:	e922                	sd	s0,144(sp)
    1756:	e526                	sd	s1,136(sp)
    1758:	e14a                	sd	s2,128(sp)
    175a:	fcce                	sd	s3,120(sp)
    175c:	f8d2                	sd	s4,112(sp)
    175e:	f4d6                	sd	s5,104(sp)
    1760:	f0da                	sd	s6,96(sp)
    1762:	ecde                	sd	s7,88(sp)
    1764:	e8e2                	sd	s8,80(sp)
    1766:	e4e6                	sd	s9,72(sp)
    1768:	e0ea                	sd	s10,64(sp)
    176a:	fc6e                	sd	s11,56(sp)
    176c:	1100                	addi	s0,sp,160
    176e:	8daa                	mv	s11,a0
  for (pi = 0; pi < NCHILD; pi++) {
    1770:	4901                	li	s2,0
    1772:	4991                	li	s3,4
    pid = fork();
    1774:	19e040ef          	jal	5912 <fork>
    1778:	84aa                	mv	s1,a0
    if (pid < 0) {
    177a:	04054063          	bltz	a0,17ba <createdelete+0x6a>
    if (pid == 0) {
    177e:	c921                	beqz	a0,17ce <createdelete+0x7e>
  for (pi = 0; pi < NCHILD; pi++) {
    1780:	2905                	addiw	s2,s2,1
    1782:	ff3919e3          	bne	s2,s3,1774 <createdelete+0x24>
    1786:	4491                	li	s1,4
    wait(&xstatus);
    1788:	f6c40913          	addi	s2,s0,-148
    178c:	854a                	mv	a0,s2
    178e:	194040ef          	jal	5922 <wait>
    if (xstatus != 0)
    1792:	f6c42a83          	lw	s5,-148(s0)
    1796:	0c0a9263          	bnez	s5,185a <createdelete+0x10a>
  for (pi = 0; pi < NCHILD; pi++) {
    179a:	34fd                	addiw	s1,s1,-1
    179c:	f8e5                	bnez	s1,178c <createdelete+0x3c>
  name[0] = name[1] = name[2] = 0;
    179e:	f6040923          	sb	zero,-142(s0)
    17a2:	03000913          	li	s2,48
    17a6:	5a7d                	li	s4,-1
      if ((i == 0 || i >= N / 2) && fd < 0) {
    17a8:	4d25                	li	s10,9
    17aa:	07000c93          	li	s9,112
      fd = open(name, 0);
    17ae:	f7040c13          	addi	s8,s0,-144
      } else if ((i >= 1 && i < N / 2) && fd >= 0) {
    17b2:	4ba1                	li	s7,8
    for (pi = 0; pi < NCHILD; pi++) {
    17b4:	07400b13          	li	s6,116
    17b8:	aa39                	j	18d6 <createdelete+0x186>
      printf("%s: fork failed\n", s);
    17ba:	85ee                	mv	a1,s11
    17bc:	00005517          	auipc	a0,0x5
    17c0:	02c50513          	addi	a0,a0,44 # 67e8 <malloc+0x9c0>
    17c4:	5ac040ef          	jal	5d70 <printf>
      exit(1);
    17c8:	4505                	li	a0,1
    17ca:	150040ef          	jal	591a <exit>
      name[0] = 'p' + pi;
    17ce:	0709091b          	addiw	s2,s2,112
    17d2:	f7240823          	sb	s2,-144(s0)
      name[2] = '\0';
    17d6:	f6040923          	sb	zero,-142(s0)
        fd = open(name, O_CREATE | O_RDWR);
    17da:	f7040913          	addi	s2,s0,-144
    17de:	20200993          	li	s3,514
      for (i = 0; i < N; i++) {
    17e2:	4a51                	li	s4,20
    17e4:	a815                	j	1818 <createdelete+0xc8>
          printf("%s: create failed\n", s);
    17e6:	85ee                	mv	a1,s11
    17e8:	00005517          	auipc	a0,0x5
    17ec:	17050513          	addi	a0,a0,368 # 6958 <malloc+0xb30>
    17f0:	580040ef          	jal	5d70 <printf>
          exit(1);
    17f4:	4505                	li	a0,1
    17f6:	124040ef          	jal	591a <exit>
          name[1] = '0' + (i / 2);
    17fa:	01f4d79b          	srliw	a5,s1,0x1f
    17fe:	9fa5                	addw	a5,a5,s1
    1800:	4017d79b          	sraiw	a5,a5,0x1
    1804:	0307879b          	addiw	a5,a5,48
    1808:	f6f408a3          	sb	a5,-143(s0)
          if (unlink(name) < 0) {
    180c:	854a                	mv	a0,s2
    180e:	15c040ef          	jal	596a <unlink>
    1812:	02054a63          	bltz	a0,1846 <createdelete+0xf6>
      for (i = 0; i < N; i++) {
    1816:	2485                	addiw	s1,s1,1
        name[1] = '0' + i;
    1818:	0304879b          	addiw	a5,s1,48
    181c:	f6f408a3          	sb	a5,-143(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1820:	85ce                	mv	a1,s3
    1822:	854a                	mv	a0,s2
    1824:	136040ef          	jal	595a <open>
        if (fd < 0) {
    1828:	fa054fe3          	bltz	a0,17e6 <createdelete+0x96>
        close(fd);
    182c:	116040ef          	jal	5942 <close>
        if (i > 0 && (i % 2) == 0) {
    1830:	fe9053e3          	blez	s1,1816 <createdelete+0xc6>
    1834:	0014f793          	andi	a5,s1,1
    1838:	d3e9                	beqz	a5,17fa <createdelete+0xaa>
      for (i = 0; i < N; i++) {
    183a:	2485                	addiw	s1,s1,1
    183c:	fd449ee3          	bne	s1,s4,1818 <createdelete+0xc8>
      exit(0);
    1840:	4501                	li	a0,0
    1842:	0d8040ef          	jal	591a <exit>
            printf("%s: unlink failed\n", s);
    1846:	85ee                	mv	a1,s11
    1848:	00005517          	auipc	a0,0x5
    184c:	12850513          	addi	a0,a0,296 # 6970 <malloc+0xb48>
    1850:	520040ef          	jal	5d70 <printf>
            exit(1);
    1854:	4505                	li	a0,1
    1856:	0c4040ef          	jal	591a <exit>
      exit(1);
    185a:	4505                	li	a0,1
    185c:	0be040ef          	jal	591a <exit>
      } else if ((i >= 1 && i < N / 2) && fd >= 0) {
    1860:	054bf263          	bgeu	s7,s4,18a4 <createdelete+0x154>
      if (fd >= 0)
    1864:	04055e63          	bgez	a0,18c0 <createdelete+0x170>
    for (pi = 0; pi < NCHILD; pi++) {
    1868:	2485                	addiw	s1,s1,1
    186a:	0ff4f493          	zext.b	s1,s1
    186e:	05648c63          	beq	s1,s6,18c6 <createdelete+0x176>
      name[0] = 'p' + pi;
    1872:	f6940823          	sb	s1,-144(s0)
      name[1] = '0' + i;
    1876:	f72408a3          	sb	s2,-143(s0)
      fd = open(name, 0);
    187a:	4581                	li	a1,0
    187c:	8562                	mv	a0,s8
    187e:	0dc040ef          	jal	595a <open>
      if ((i == 0 || i >= N / 2) && fd < 0) {
    1882:	01f5579b          	srliw	a5,a0,0x1f
    1886:	dfe9                	beqz	a5,1860 <createdelete+0x110>
    1888:	fc098ce3          	beqz	s3,1860 <createdelete+0x110>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    188c:	f7040613          	addi	a2,s0,-144
    1890:	85ee                	mv	a1,s11
    1892:	00005517          	auipc	a0,0x5
    1896:	0f650513          	addi	a0,a0,246 # 6988 <malloc+0xb60>
    189a:	4d6040ef          	jal	5d70 <printf>
        exit(1);
    189e:	4505                	li	a0,1
    18a0:	07a040ef          	jal	591a <exit>
      } else if ((i >= 1 && i < N / 2) && fd >= 0) {
    18a4:	fc0542e3          	bltz	a0,1868 <createdelete+0x118>
        printf("%s: oops createdelete %s did exist\n", s, name);
    18a8:	f7040613          	addi	a2,s0,-144
    18ac:	85ee                	mv	a1,s11
    18ae:	00005517          	auipc	a0,0x5
    18b2:	10250513          	addi	a0,a0,258 # 69b0 <malloc+0xb88>
    18b6:	4ba040ef          	jal	5d70 <printf>
        exit(1);
    18ba:	4505                	li	a0,1
    18bc:	05e040ef          	jal	591a <exit>
        close(fd);
    18c0:	082040ef          	jal	5942 <close>
    18c4:	b755                	j	1868 <createdelete+0x118>
  for (i = 0; i < N; i++) {
    18c6:	2a85                	addiw	s5,s5,1
    18c8:	2a05                	addiw	s4,s4,1
    18ca:	2905                	addiw	s2,s2,1
    18cc:	0ff97913          	zext.b	s2,s2
    18d0:	47d1                	li	a5,20
    18d2:	00fa8a63          	beq	s5,a5,18e6 <createdelete+0x196>
      if ((i == 0 || i >= N / 2) && fd < 0) {
    18d6:	001ab993          	seqz	s3,s5
    18da:	015d27b3          	slt	a5,s10,s5
    18de:	00f9e9b3          	or	s3,s3,a5
    18e2:	84e6                	mv	s1,s9
    18e4:	b779                	j	1872 <createdelete+0x122>
    18e6:	03000913          	li	s2,48
  name[0] = name[1] = name[2] = 0;
    18ea:	07000b13          	li	s6,112
      unlink(name);
    18ee:	f7040a13          	addi	s4,s0,-144
    for (pi = 0; pi < NCHILD; pi++) {
    18f2:	07400993          	li	s3,116
  for (i = 0; i < N; i++) {
    18f6:	04400a93          	li	s5,68
  name[0] = name[1] = name[2] = 0;
    18fa:	84da                	mv	s1,s6
      name[0] = 'p' + pi;
    18fc:	f6940823          	sb	s1,-144(s0)
      name[1] = '0' + i;
    1900:	f72408a3          	sb	s2,-143(s0)
      unlink(name);
    1904:	8552                	mv	a0,s4
    1906:	064040ef          	jal	596a <unlink>
    for (pi = 0; pi < NCHILD; pi++) {
    190a:	2485                	addiw	s1,s1,1
    190c:	0ff4f493          	zext.b	s1,s1
    1910:	ff3496e3          	bne	s1,s3,18fc <createdelete+0x1ac>
  for (i = 0; i < N; i++) {
    1914:	2905                	addiw	s2,s2,1
    1916:	0ff97913          	zext.b	s2,s2
    191a:	ff5910e3          	bne	s2,s5,18fa <createdelete+0x1aa>
}
    191e:	60ea                	ld	ra,152(sp)
    1920:	644a                	ld	s0,144(sp)
    1922:	64aa                	ld	s1,136(sp)
    1924:	690a                	ld	s2,128(sp)
    1926:	79e6                	ld	s3,120(sp)
    1928:	7a46                	ld	s4,112(sp)
    192a:	7aa6                	ld	s5,104(sp)
    192c:	7b06                	ld	s6,96(sp)
    192e:	6be6                	ld	s7,88(sp)
    1930:	6c46                	ld	s8,80(sp)
    1932:	6ca6                	ld	s9,72(sp)
    1934:	6d06                	ld	s10,64(sp)
    1936:	7de2                	ld	s11,56(sp)
    1938:	610d                	addi	sp,sp,160
    193a:	8082                	ret

000000000000193c <linkunlink>:
{
    193c:	711d                	addi	sp,sp,-96
    193e:	ec86                	sd	ra,88(sp)
    1940:	e8a2                	sd	s0,80(sp)
    1942:	e4a6                	sd	s1,72(sp)
    1944:	e0ca                	sd	s2,64(sp)
    1946:	fc4e                	sd	s3,56(sp)
    1948:	f852                	sd	s4,48(sp)
    194a:	f456                	sd	s5,40(sp)
    194c:	f05a                	sd	s6,32(sp)
    194e:	ec5e                	sd	s7,24(sp)
    1950:	e862                	sd	s8,16(sp)
    1952:	e466                	sd	s9,8(sp)
    1954:	e06a                	sd	s10,0(sp)
    1956:	1080                	addi	s0,sp,96
    1958:	84aa                	mv	s1,a0
  unlink("x");
    195a:	00004517          	auipc	a0,0x4
    195e:	66e50513          	addi	a0,a0,1646 # 5fc8 <malloc+0x1a0>
    1962:	008040ef          	jal	596a <unlink>
  pid = fork();
    1966:	7ad030ef          	jal	5912 <fork>
  if (pid < 0) {
    196a:	04054363          	bltz	a0,19b0 <linkunlink+0x74>
    196e:	8d2a                	mv	s10,a0
  unsigned int x = (pid ? 1 : 97);
    1970:	06100913          	li	s2,97
    1974:	c111                	beqz	a0,1978 <linkunlink+0x3c>
    1976:	4905                	li	s2,1
    1978:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    197c:	41c65ab7          	lui	s5,0x41c65
    1980:	e6da8a9b          	addiw	s5,s5,-403 # 41c64e6d <base+0x41c53165>
    1984:	6a0d                	lui	s4,0x3
    1986:	039a0a1b          	addiw	s4,s4,57 # 3039 <subdir+0x4af>
    if ((x % 3) == 0) {
    198a:	000ab9b7          	lui	s3,0xab
    198e:	aab98993          	addi	s3,s3,-1365 # aaaab <base+0x98da3>
    1992:	09b2                	slli	s3,s3,0xc
    1994:	aab98993          	addi	s3,s3,-1365
    } else if ((x % 3) == 1) {
    1998:	4b85                	li	s7,1
      unlink("x");
    199a:	00004b17          	auipc	s6,0x4
    199e:	62eb0b13          	addi	s6,s6,1582 # 5fc8 <malloc+0x1a0>
      link("cat", "x");
    19a2:	00005c97          	auipc	s9,0x5
    19a6:	036c8c93          	addi	s9,s9,54 # 69d8 <malloc+0xbb0>
      close(open("x", O_RDWR | O_CREATE));
    19aa:	20200c13          	li	s8,514
    19ae:	a03d                	j	19dc <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    19b0:	85a6                	mv	a1,s1
    19b2:	00005517          	auipc	a0,0x5
    19b6:	e3650513          	addi	a0,a0,-458 # 67e8 <malloc+0x9c0>
    19ba:	3b6040ef          	jal	5d70 <printf>
    exit(1);
    19be:	4505                	li	a0,1
    19c0:	75b030ef          	jal	591a <exit>
      close(open("x", O_RDWR | O_CREATE));
    19c4:	85e2                	mv	a1,s8
    19c6:	855a                	mv	a0,s6
    19c8:	793030ef          	jal	595a <open>
    19cc:	777030ef          	jal	5942 <close>
    19d0:	a021                	j	19d8 <linkunlink+0x9c>
      unlink("x");
    19d2:	855a                	mv	a0,s6
    19d4:	797030ef          	jal	596a <unlink>
  for (i = 0; i < 100; i++) {
    19d8:	34fd                	addiw	s1,s1,-1
    19da:	c885                	beqz	s1,1a0a <linkunlink+0xce>
    x = x * 1103515245 + 12345;
    19dc:	035907bb          	mulw	a5,s2,s5
    19e0:	00fa07bb          	addw	a5,s4,a5
    19e4:	893e                	mv	s2,a5
    if ((x % 3) == 0) {
    19e6:	02079713          	slli	a4,a5,0x20
    19ea:	9301                	srli	a4,a4,0x20
    19ec:	03370733          	mul	a4,a4,s3
    19f0:	9305                	srli	a4,a4,0x21
    19f2:	0017169b          	slliw	a3,a4,0x1
    19f6:	9f35                	addw	a4,a4,a3
    19f8:	9f99                	subw	a5,a5,a4
    19fa:	d7e9                	beqz	a5,19c4 <linkunlink+0x88>
    } else if ((x % 3) == 1) {
    19fc:	fd779be3          	bne	a5,s7,19d2 <linkunlink+0x96>
      link("cat", "x");
    1a00:	85da                	mv	a1,s6
    1a02:	8566                	mv	a0,s9
    1a04:	777030ef          	jal	597a <link>
    1a08:	bfc1                	j	19d8 <linkunlink+0x9c>
  if (pid)
    1a0a:	020d0363          	beqz	s10,1a30 <linkunlink+0xf4>
    wait(0);
    1a0e:	4501                	li	a0,0
    1a10:	713030ef          	jal	5922 <wait>
}
    1a14:	60e6                	ld	ra,88(sp)
    1a16:	6446                	ld	s0,80(sp)
    1a18:	64a6                	ld	s1,72(sp)
    1a1a:	6906                	ld	s2,64(sp)
    1a1c:	79e2                	ld	s3,56(sp)
    1a1e:	7a42                	ld	s4,48(sp)
    1a20:	7aa2                	ld	s5,40(sp)
    1a22:	7b02                	ld	s6,32(sp)
    1a24:	6be2                	ld	s7,24(sp)
    1a26:	6c42                	ld	s8,16(sp)
    1a28:	6ca2                	ld	s9,8(sp)
    1a2a:	6d02                	ld	s10,0(sp)
    1a2c:	6125                	addi	sp,sp,96
    1a2e:	8082                	ret
    exit(0);
    1a30:	4501                	li	a0,0
    1a32:	6e9030ef          	jal	591a <exit>

0000000000001a36 <forktest>:
{
    1a36:	7179                	addi	sp,sp,-48
    1a38:	f406                	sd	ra,40(sp)
    1a3a:	f022                	sd	s0,32(sp)
    1a3c:	ec26                	sd	s1,24(sp)
    1a3e:	e84a                	sd	s2,16(sp)
    1a40:	e44e                	sd	s3,8(sp)
    1a42:	1800                	addi	s0,sp,48
    1a44:	89aa                	mv	s3,a0
  for (n = 0; n < N; n++) {
    1a46:	4481                	li	s1,0
    1a48:	3e800913          	li	s2,1000
    pid = fork();
    1a4c:	6c7030ef          	jal	5912 <fork>
    if (pid < 0)
    1a50:	06054063          	bltz	a0,1ab0 <forktest+0x7a>
    if (pid == 0)
    1a54:	cd11                	beqz	a0,1a70 <forktest+0x3a>
  for (n = 0; n < N; n++) {
    1a56:	2485                	addiw	s1,s1,1
    1a58:	ff249ae3          	bne	s1,s2,1a4c <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    1a5c:	85ce                	mv	a1,s3
    1a5e:	00005517          	auipc	a0,0x5
    1a62:	fca50513          	addi	a0,a0,-54 # 6a28 <malloc+0xc00>
    1a66:	30a040ef          	jal	5d70 <printf>
    exit(1);
    1a6a:	4505                	li	a0,1
    1a6c:	6af030ef          	jal	591a <exit>
      exit(0);
    1a70:	6ab030ef          	jal	591a <exit>
    printf("%s: no fork at all!\n", s);
    1a74:	85ce                	mv	a1,s3
    1a76:	00005517          	auipc	a0,0x5
    1a7a:	f6a50513          	addi	a0,a0,-150 # 69e0 <malloc+0xbb8>
    1a7e:	2f2040ef          	jal	5d70 <printf>
    exit(1);
    1a82:	4505                	li	a0,1
    1a84:	697030ef          	jal	591a <exit>
      printf("%s: wait stopped early\n", s);
    1a88:	85ce                	mv	a1,s3
    1a8a:	00005517          	auipc	a0,0x5
    1a8e:	f6e50513          	addi	a0,a0,-146 # 69f8 <malloc+0xbd0>
    1a92:	2de040ef          	jal	5d70 <printf>
      exit(1);
    1a96:	4505                	li	a0,1
    1a98:	683030ef          	jal	591a <exit>
    printf("%s: wait got too many\n", s);
    1a9c:	85ce                	mv	a1,s3
    1a9e:	00005517          	auipc	a0,0x5
    1aa2:	f7250513          	addi	a0,a0,-142 # 6a10 <malloc+0xbe8>
    1aa6:	2ca040ef          	jal	5d70 <printf>
    exit(1);
    1aaa:	4505                	li	a0,1
    1aac:	66f030ef          	jal	591a <exit>
  if (n == 0) {
    1ab0:	d0f1                	beqz	s1,1a74 <forktest+0x3e>
  for (; n > 0; n--) {
    1ab2:	00905963          	blez	s1,1ac4 <forktest+0x8e>
    if (wait(0) < 0) {
    1ab6:	4501                	li	a0,0
    1ab8:	66b030ef          	jal	5922 <wait>
    1abc:	fc0546e3          	bltz	a0,1a88 <forktest+0x52>
  for (; n > 0; n--) {
    1ac0:	34fd                	addiw	s1,s1,-1
    1ac2:	f8f5                	bnez	s1,1ab6 <forktest+0x80>
  if (wait(0) != -1) {
    1ac4:	4501                	li	a0,0
    1ac6:	65d030ef          	jal	5922 <wait>
    1aca:	57fd                	li	a5,-1
    1acc:	fcf518e3          	bne	a0,a5,1a9c <forktest+0x66>
}
    1ad0:	70a2                	ld	ra,40(sp)
    1ad2:	7402                	ld	s0,32(sp)
    1ad4:	64e2                	ld	s1,24(sp)
    1ad6:	6942                	ld	s2,16(sp)
    1ad8:	69a2                	ld	s3,8(sp)
    1ada:	6145                	addi	sp,sp,48
    1adc:	8082                	ret

0000000000001ade <kernmem>:
{
    1ade:	715d                	addi	sp,sp,-80
    1ae0:	e486                	sd	ra,72(sp)
    1ae2:	e0a2                	sd	s0,64(sp)
    1ae4:	fc26                	sd	s1,56(sp)
    1ae6:	f84a                	sd	s2,48(sp)
    1ae8:	f44e                	sd	s3,40(sp)
    1aea:	f052                	sd	s4,32(sp)
    1aec:	ec56                	sd	s5,24(sp)
    1aee:	e85a                	sd	s6,16(sp)
    1af0:	0880                	addi	s0,sp,80
    1af2:	8b2a                	mv	s6,a0
  for (a = (char *)(KERNBASE); a < (char *)(KERNBASE + 2000000); a += 50000) {
    1af4:	4485                	li	s1,1
    1af6:	04fe                	slli	s1,s1,0x1f
    wait(&xstatus);
    1af8:	fbc40a93          	addi	s5,s0,-68
    if (xstatus != -1) // did kernel kill child?
    1afc:	5a7d                	li	s4,-1
  for (a = (char *)(KERNBASE); a < (char *)(KERNBASE + 2000000); a += 50000) {
    1afe:	69b1                	lui	s3,0xc
    1b00:	35098993          	addi	s3,s3,848 # c350 <big.0+0xd60>
    1b04:	1003d937          	lui	s2,0x1003d
    1b08:	090e                	slli	s2,s2,0x3
    1b0a:	48090913          	addi	s2,s2,1152 # 1003d480 <base+0x1002b778>
    pid = fork();
    1b0e:	605030ef          	jal	5912 <fork>
    if (pid < 0) {
    1b12:	02054763          	bltz	a0,1b40 <kernmem+0x62>
    if (pid == 0) {
    1b16:	cd1d                	beqz	a0,1b54 <kernmem+0x76>
    wait(&xstatus);
    1b18:	8556                	mv	a0,s5
    1b1a:	609030ef          	jal	5922 <wait>
    if (xstatus != -1) // did kernel kill child?
    1b1e:	fbc42783          	lw	a5,-68(s0)
    1b22:	05479663          	bne	a5,s4,1b6e <kernmem+0x90>
  for (a = (char *)(KERNBASE); a < (char *)(KERNBASE + 2000000); a += 50000) {
    1b26:	94ce                	add	s1,s1,s3
    1b28:	ff2493e3          	bne	s1,s2,1b0e <kernmem+0x30>
}
    1b2c:	60a6                	ld	ra,72(sp)
    1b2e:	6406                	ld	s0,64(sp)
    1b30:	74e2                	ld	s1,56(sp)
    1b32:	7942                	ld	s2,48(sp)
    1b34:	79a2                	ld	s3,40(sp)
    1b36:	7a02                	ld	s4,32(sp)
    1b38:	6ae2                	ld	s5,24(sp)
    1b3a:	6b42                	ld	s6,16(sp)
    1b3c:	6161                	addi	sp,sp,80
    1b3e:	8082                	ret
      printf("%s: fork failed\n", s);
    1b40:	85da                	mv	a1,s6
    1b42:	00005517          	auipc	a0,0x5
    1b46:	ca650513          	addi	a0,a0,-858 # 67e8 <malloc+0x9c0>
    1b4a:	226040ef          	jal	5d70 <printf>
      exit(1);
    1b4e:	4505                	li	a0,1
    1b50:	5cb030ef          	jal	591a <exit>
      printf("%s: oops could read %p = %x\n", s, a, *a);
    1b54:	0004c683          	lbu	a3,0(s1)
    1b58:	8626                	mv	a2,s1
    1b5a:	85da                	mv	a1,s6
    1b5c:	00005517          	auipc	a0,0x5
    1b60:	ef450513          	addi	a0,a0,-268 # 6a50 <malloc+0xc28>
    1b64:	20c040ef          	jal	5d70 <printf>
      exit(1);
    1b68:	4505                	li	a0,1
    1b6a:	5b1030ef          	jal	591a <exit>
      exit(1);
    1b6e:	4505                	li	a0,1
    1b70:	5ab030ef          	jal	591a <exit>

0000000000001b74 <MAXVAplus>:
{
    1b74:	7139                	addi	sp,sp,-64
    1b76:	fc06                	sd	ra,56(sp)
    1b78:	f822                	sd	s0,48(sp)
    1b7a:	0080                	addi	s0,sp,64
  volatile uint64 a = MAXVA;
    1b7c:	4785                	li	a5,1
    1b7e:	179a                	slli	a5,a5,0x26
    1b80:	fcf43423          	sd	a5,-56(s0)
  for (; a != 0; a <<= 1) {
    1b84:	fc843783          	ld	a5,-56(s0)
    1b88:	cf9d                	beqz	a5,1bc6 <MAXVAplus+0x52>
    1b8a:	f426                	sd	s1,40(sp)
    1b8c:	f04a                	sd	s2,32(sp)
    1b8e:	ec4e                	sd	s3,24(sp)
    1b90:	89aa                	mv	s3,a0
    wait(&xstatus);
    1b92:	fc440913          	addi	s2,s0,-60
    if (xstatus != -1) // did kernel kill child?
    1b96:	54fd                	li	s1,-1
    pid = fork();
    1b98:	57b030ef          	jal	5912 <fork>
    if (pid < 0) {
    1b9c:	02054963          	bltz	a0,1bce <MAXVAplus+0x5a>
    if (pid == 0) {
    1ba0:	c129                	beqz	a0,1be2 <MAXVAplus+0x6e>
    wait(&xstatus);
    1ba2:	854a                	mv	a0,s2
    1ba4:	57f030ef          	jal	5922 <wait>
    if (xstatus != -1) // did kernel kill child?
    1ba8:	fc442783          	lw	a5,-60(s0)
    1bac:	04979d63          	bne	a5,s1,1c06 <MAXVAplus+0x92>
  for (; a != 0; a <<= 1) {
    1bb0:	fc843783          	ld	a5,-56(s0)
    1bb4:	0786                	slli	a5,a5,0x1
    1bb6:	fcf43423          	sd	a5,-56(s0)
    1bba:	fc843783          	ld	a5,-56(s0)
    1bbe:	ffe9                	bnez	a5,1b98 <MAXVAplus+0x24>
    1bc0:	74a2                	ld	s1,40(sp)
    1bc2:	7902                	ld	s2,32(sp)
    1bc4:	69e2                	ld	s3,24(sp)
}
    1bc6:	70e2                	ld	ra,56(sp)
    1bc8:	7442                	ld	s0,48(sp)
    1bca:	6121                	addi	sp,sp,64
    1bcc:	8082                	ret
      printf("%s: fork failed\n", s);
    1bce:	85ce                	mv	a1,s3
    1bd0:	00005517          	auipc	a0,0x5
    1bd4:	c1850513          	addi	a0,a0,-1000 # 67e8 <malloc+0x9c0>
    1bd8:	198040ef          	jal	5d70 <printf>
      exit(1);
    1bdc:	4505                	li	a0,1
    1bde:	53d030ef          	jal	591a <exit>
      *(char *)a = 99;
    1be2:	fc843783          	ld	a5,-56(s0)
    1be6:	06300713          	li	a4,99
    1bea:	00e78023          	sb	a4,0(a5)
      printf("%s: oops wrote %p\n", s, (void *)a);
    1bee:	fc843603          	ld	a2,-56(s0)
    1bf2:	85ce                	mv	a1,s3
    1bf4:	00005517          	auipc	a0,0x5
    1bf8:	e7c50513          	addi	a0,a0,-388 # 6a70 <malloc+0xc48>
    1bfc:	174040ef          	jal	5d70 <printf>
      exit(1);
    1c00:	4505                	li	a0,1
    1c02:	519030ef          	jal	591a <exit>
      exit(1);
    1c06:	4505                	li	a0,1
    1c08:	513030ef          	jal	591a <exit>

0000000000001c0c <stacktest>:
{
    1c0c:	7179                	addi	sp,sp,-48
    1c0e:	f406                	sd	ra,40(sp)
    1c10:	f022                	sd	s0,32(sp)
    1c12:	ec26                	sd	s1,24(sp)
    1c14:	1800                	addi	s0,sp,48
    1c16:	84aa                	mv	s1,a0
  pid = fork();
    1c18:	4fb030ef          	jal	5912 <fork>
  if (pid == 0) {
    1c1c:	cd11                	beqz	a0,1c38 <stacktest+0x2c>
  } else if (pid < 0) {
    1c1e:	02054c63          	bltz	a0,1c56 <stacktest+0x4a>
  wait(&xstatus);
    1c22:	fdc40513          	addi	a0,s0,-36
    1c26:	4fd030ef          	jal	5922 <wait>
  if (xstatus == -1) // kernel killed child?
    1c2a:	fdc42503          	lw	a0,-36(s0)
    1c2e:	57fd                	li	a5,-1
    1c30:	02f50d63          	beq	a0,a5,1c6a <stacktest+0x5e>
    exit(xstatus);
    1c34:	4e7030ef          	jal	591a <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r"(x));
    1c38:	878a                	mv	a5,sp
    printf("%s: stacktest: read below stack %d\n", s, *sp);
    1c3a:	80078793          	addi	a5,a5,-2048
    1c3e:	8007c603          	lbu	a2,-2048(a5)
    1c42:	85a6                	mv	a1,s1
    1c44:	00005517          	auipc	a0,0x5
    1c48:	e4450513          	addi	a0,a0,-444 # 6a88 <malloc+0xc60>
    1c4c:	124040ef          	jal	5d70 <printf>
    exit(1);
    1c50:	4505                	li	a0,1
    1c52:	4c9030ef          	jal	591a <exit>
    printf("%s: fork failed\n", s);
    1c56:	85a6                	mv	a1,s1
    1c58:	00005517          	auipc	a0,0x5
    1c5c:	b9050513          	addi	a0,a0,-1136 # 67e8 <malloc+0x9c0>
    1c60:	110040ef          	jal	5d70 <printf>
    exit(1);
    1c64:	4505                	li	a0,1
    1c66:	4b5030ef          	jal	591a <exit>
    exit(0);
    1c6a:	4501                	li	a0,0
    1c6c:	4af030ef          	jal	591a <exit>

0000000000001c70 <nowrite>:
{
    1c70:	7159                	addi	sp,sp,-112
    1c72:	f486                	sd	ra,104(sp)
    1c74:	f0a2                	sd	s0,96(sp)
    1c76:	eca6                	sd	s1,88(sp)
    1c78:	e8ca                	sd	s2,80(sp)
    1c7a:	e4ce                	sd	s3,72(sp)
    1c7c:	e0d2                	sd	s4,64(sp)
    1c7e:	1880                	addi	s0,sp,112
    1c80:	8a2a                	mv	s4,a0
  uint64 addrs[] = {0,
    1c82:	00007797          	auipc	a5,0x7
    1c86:	c8e78793          	addi	a5,a5,-882 # 8910 <malloc+0x2ae8>
    1c8a:	7788                	ld	a0,40(a5)
    1c8c:	7b8c                	ld	a1,48(a5)
    1c8e:	7f90                	ld	a2,56(a5)
    1c90:	63b4                	ld	a3,64(a5)
    1c92:	67b8                	ld	a4,72(a5)
    1c94:	f8a43c23          	sd	a0,-104(s0)
    1c98:	fab43023          	sd	a1,-96(s0)
    1c9c:	fac43423          	sd	a2,-88(s0)
    1ca0:	fad43823          	sd	a3,-80(s0)
    1ca4:	fae43c23          	sd	a4,-72(s0)
    1ca8:	6bbc                	ld	a5,80(a5)
    1caa:	fcf43023          	sd	a5,-64(s0)
  for (int ai = 0; ai < sizeof(addrs) / sizeof(addrs[0]); ai++) {
    1cae:	4481                	li	s1,0
    wait(&xstatus);
    1cb0:	fcc40913          	addi	s2,s0,-52
  for (int ai = 0; ai < sizeof(addrs) / sizeof(addrs[0]); ai++) {
    1cb4:	4999                	li	s3,6
    pid = fork();
    1cb6:	45d030ef          	jal	5912 <fork>
    if (pid == 0) {
    1cba:	cd19                	beqz	a0,1cd8 <nowrite+0x68>
    } else if (pid < 0) {
    1cbc:	04054163          	bltz	a0,1cfe <nowrite+0x8e>
    wait(&xstatus);
    1cc0:	854a                	mv	a0,s2
    1cc2:	461030ef          	jal	5922 <wait>
    if (xstatus == 0) {
    1cc6:	fcc42783          	lw	a5,-52(s0)
    1cca:	c7a1                	beqz	a5,1d12 <nowrite+0xa2>
  for (int ai = 0; ai < sizeof(addrs) / sizeof(addrs[0]); ai++) {
    1ccc:	2485                	addiw	s1,s1,1
    1cce:	ff3494e3          	bne	s1,s3,1cb6 <nowrite+0x46>
  exit(0);
    1cd2:	4501                	li	a0,0
    1cd4:	447030ef          	jal	591a <exit>
      volatile int *addr = (int *)addrs[ai];
    1cd8:	048e                	slli	s1,s1,0x3
    1cda:	fd048793          	addi	a5,s1,-48
    1cde:	008784b3          	add	s1,a5,s0
    1ce2:	fc84b603          	ld	a2,-56(s1)
      *addr = 10;
    1ce6:	47a9                	li	a5,10
    1ce8:	c21c                	sw	a5,0(a2)
      printf("%s: write to %p did not fail!\n", s, addr);
    1cea:	85d2                	mv	a1,s4
    1cec:	00005517          	auipc	a0,0x5
    1cf0:	dc450513          	addi	a0,a0,-572 # 6ab0 <malloc+0xc88>
    1cf4:	07c040ef          	jal	5d70 <printf>
      exit(0);
    1cf8:	4501                	li	a0,0
    1cfa:	421030ef          	jal	591a <exit>
      printf("%s: fork failed\n", s);
    1cfe:	85d2                	mv	a1,s4
    1d00:	00005517          	auipc	a0,0x5
    1d04:	ae850513          	addi	a0,a0,-1304 # 67e8 <malloc+0x9c0>
    1d08:	068040ef          	jal	5d70 <printf>
      exit(1);
    1d0c:	4505                	li	a0,1
    1d0e:	40d030ef          	jal	591a <exit>
      exit(1);
    1d12:	4505                	li	a0,1
    1d14:	407030ef          	jal	591a <exit>

0000000000001d18 <manywrites>:
{
    1d18:	7159                	addi	sp,sp,-112
    1d1a:	f486                	sd	ra,104(sp)
    1d1c:	f0a2                	sd	s0,96(sp)
    1d1e:	eca6                	sd	s1,88(sp)
    1d20:	e8ca                	sd	s2,80(sp)
    1d22:	e4ce                	sd	s3,72(sp)
    1d24:	ec66                	sd	s9,24(sp)
    1d26:	1880                	addi	s0,sp,112
    1d28:	8caa                	mv	s9,a0
  for (int ci = 0; ci < nchildren; ci++) {
    1d2a:	4901                	li	s2,0
    1d2c:	4991                	li	s3,4
    int pid = fork();
    1d2e:	3e5030ef          	jal	5912 <fork>
    1d32:	84aa                	mv	s1,a0
    if (pid < 0) {
    1d34:	02054c63          	bltz	a0,1d6c <manywrites+0x54>
    if (pid == 0) {
    1d38:	c929                	beqz	a0,1d8a <manywrites+0x72>
  for (int ci = 0; ci < nchildren; ci++) {
    1d3a:	2905                	addiw	s2,s2,1
    1d3c:	ff3919e3          	bne	s2,s3,1d2e <manywrites+0x16>
    1d40:	4491                	li	s1,4
    wait(&st);
    1d42:	f9840913          	addi	s2,s0,-104
    int st = 0;
    1d46:	f8042c23          	sw	zero,-104(s0)
    wait(&st);
    1d4a:	854a                	mv	a0,s2
    1d4c:	3d7030ef          	jal	5922 <wait>
    if (st != 0)
    1d50:	f9842503          	lw	a0,-104(s0)
    1d54:	0e051763          	bnez	a0,1e42 <manywrites+0x12a>
  for (int ci = 0; ci < nchildren; ci++) {
    1d58:	34fd                	addiw	s1,s1,-1
    1d5a:	f4f5                	bnez	s1,1d46 <manywrites+0x2e>
    1d5c:	e0d2                	sd	s4,64(sp)
    1d5e:	fc56                	sd	s5,56(sp)
    1d60:	f85a                	sd	s6,48(sp)
    1d62:	f45e                	sd	s7,40(sp)
    1d64:	f062                	sd	s8,32(sp)
    1d66:	e86a                	sd	s10,16(sp)
  exit(0);
    1d68:	3b3030ef          	jal	591a <exit>
    1d6c:	e0d2                	sd	s4,64(sp)
    1d6e:	fc56                	sd	s5,56(sp)
    1d70:	f85a                	sd	s6,48(sp)
    1d72:	f45e                	sd	s7,40(sp)
    1d74:	f062                	sd	s8,32(sp)
    1d76:	e86a                	sd	s10,16(sp)
      printf("fork failed\n");
    1d78:	00006517          	auipc	a0,0x6
    1d7c:	1f050513          	addi	a0,a0,496 # 7f68 <malloc+0x2140>
    1d80:	7f1030ef          	jal	5d70 <printf>
      exit(1);
    1d84:	4505                	li	a0,1
    1d86:	395030ef          	jal	591a <exit>
    1d8a:	e0d2                	sd	s4,64(sp)
    1d8c:	fc56                	sd	s5,56(sp)
    1d8e:	f85a                	sd	s6,48(sp)
    1d90:	f45e                	sd	s7,40(sp)
    1d92:	f062                	sd	s8,32(sp)
    1d94:	e86a                	sd	s10,16(sp)
      name[0] = 'b';
    1d96:	06200793          	li	a5,98
    1d9a:	f8f40c23          	sb	a5,-104(s0)
      name[1] = 'a' + ci;
    1d9e:	0619079b          	addiw	a5,s2,97
    1da2:	f8f40ca3          	sb	a5,-103(s0)
      name[2] = '\0';
    1da6:	f8040d23          	sb	zero,-102(s0)
      unlink(name);
    1daa:	f9840513          	addi	a0,s0,-104
    1dae:	3bd030ef          	jal	596a <unlink>
    1db2:	47f9                	li	a5,30
    1db4:	8d3e                	mv	s10,a5
          int fd = open(name, O_CREATE | O_RDWR);
    1db6:	f9840b93          	addi	s7,s0,-104
    1dba:	20200b13          	li	s6,514
          int cc = write(fd, buf, sz);
    1dbe:	6a8d                	lui	s5,0x3
    1dc0:	0000dc17          	auipc	s8,0xd
    1dc4:	f48c0c13          	addi	s8,s8,-184 # ed08 <buf>
        for (int i = 0; i < ci + 1; i++) {
    1dc8:	8a26                	mv	s4,s1
    1dca:	02094563          	bltz	s2,1df4 <manywrites+0xdc>
          int fd = open(name, O_CREATE | O_RDWR);
    1dce:	85da                	mv	a1,s6
    1dd0:	855e                	mv	a0,s7
    1dd2:	389030ef          	jal	595a <open>
    1dd6:	89aa                	mv	s3,a0
          if (fd < 0) {
    1dd8:	02054d63          	bltz	a0,1e12 <manywrites+0xfa>
          int cc = write(fd, buf, sz);
    1ddc:	8656                	mv	a2,s5
    1dde:	85e2                	mv	a1,s8
    1de0:	35b030ef          	jal	593a <write>
          if (cc != sz) {
    1de4:	05551363          	bne	a0,s5,1e2a <manywrites+0x112>
          close(fd);
    1de8:	854e                	mv	a0,s3
    1dea:	359030ef          	jal	5942 <close>
        for (int i = 0; i < ci + 1; i++) {
    1dee:	2a05                	addiw	s4,s4,1
    1df0:	fd495fe3          	bge	s2,s4,1dce <manywrites+0xb6>
        unlink(name);
    1df4:	f9840513          	addi	a0,s0,-104
    1df8:	373030ef          	jal	596a <unlink>
      for (int iters = 0; iters < howmany; iters++) {
    1dfc:	fffd079b          	addiw	a5,s10,-1
    1e00:	8d3e                	mv	s10,a5
    1e02:	f3f9                	bnez	a5,1dc8 <manywrites+0xb0>
      unlink(name);
    1e04:	f9840513          	addi	a0,s0,-104
    1e08:	363030ef          	jal	596a <unlink>
      exit(0);
    1e0c:	4501                	li	a0,0
    1e0e:	30d030ef          	jal	591a <exit>
            printf("%s: cannot create %s\n", s, name);
    1e12:	f9840613          	addi	a2,s0,-104
    1e16:	85e6                	mv	a1,s9
    1e18:	00005517          	auipc	a0,0x5
    1e1c:	cb850513          	addi	a0,a0,-840 # 6ad0 <malloc+0xca8>
    1e20:	751030ef          	jal	5d70 <printf>
            exit(1);
    1e24:	4505                	li	a0,1
    1e26:	2f5030ef          	jal	591a <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    1e2a:	86aa                	mv	a3,a0
    1e2c:	660d                	lui	a2,0x3
    1e2e:	85e6                	mv	a1,s9
    1e30:	00004517          	auipc	a0,0x4
    1e34:	1f850513          	addi	a0,a0,504 # 6028 <malloc+0x200>
    1e38:	739030ef          	jal	5d70 <printf>
            exit(1);
    1e3c:	4505                	li	a0,1
    1e3e:	2dd030ef          	jal	591a <exit>
    1e42:	e0d2                	sd	s4,64(sp)
    1e44:	fc56                	sd	s5,56(sp)
    1e46:	f85a                	sd	s6,48(sp)
    1e48:	f45e                	sd	s7,40(sp)
    1e4a:	f062                	sd	s8,32(sp)
    1e4c:	e86a                	sd	s10,16(sp)
      exit(st);
    1e4e:	2cd030ef          	jal	591a <exit>

0000000000001e52 <copyinstr3>:
{
    1e52:	7179                	addi	sp,sp,-48
    1e54:	f406                	sd	ra,40(sp)
    1e56:	f022                	sd	s0,32(sp)
    1e58:	ec26                	sd	s1,24(sp)
    1e5a:	1800                	addi	s0,sp,48
  sbrk(8192);
    1e5c:	6509                	lui	a0,0x2
    1e5e:	289030ef          	jal	58e6 <sbrk>
  uint64 top = (uint64)sbrk(0);
    1e62:	4501                	li	a0,0
    1e64:	283030ef          	jal	58e6 <sbrk>
  if ((top % PGSIZE) != 0) {
    1e68:	03451793          	slli	a5,a0,0x34
    1e6c:	e7bd                	bnez	a5,1eda <copyinstr3+0x88>
  top = (uint64)sbrk(0);
    1e6e:	4501                	li	a0,0
    1e70:	277030ef          	jal	58e6 <sbrk>
  if (top % PGSIZE) {
    1e74:	03451793          	slli	a5,a0,0x34
    1e78:	ebad                	bnez	a5,1eea <copyinstr3+0x98>
  char *b = (char *)(top - 1);
    1e7a:	fff50493          	addi	s1,a0,-1 # 1fff <rwsbrk+0xa9>
  *b = 'x';
    1e7e:	07800793          	li	a5,120
    1e82:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    1e86:	8526                	mv	a0,s1
    1e88:	2e3030ef          	jal	596a <unlink>
  if (ret != -1) {
    1e8c:	57fd                	li	a5,-1
    1e8e:	06f51763          	bne	a0,a5,1efc <copyinstr3+0xaa>
  int fd = open(b, O_CREATE | O_WRONLY);
    1e92:	20100593          	li	a1,513
    1e96:	8526                	mv	a0,s1
    1e98:	2c3030ef          	jal	595a <open>
  if (fd != -1) {
    1e9c:	57fd                	li	a5,-1
    1e9e:	06f51a63          	bne	a0,a5,1f12 <copyinstr3+0xc0>
  ret = link(b, b);
    1ea2:	85a6                	mv	a1,s1
    1ea4:	8526                	mv	a0,s1
    1ea6:	2d5030ef          	jal	597a <link>
  if (ret != -1) {
    1eaa:	57fd                	li	a5,-1
    1eac:	06f51e63          	bne	a0,a5,1f28 <copyinstr3+0xd6>
  char *args[] = {"xx", 0};
    1eb0:	00006797          	auipc	a5,0x6
    1eb4:	92078793          	addi	a5,a5,-1760 # 77d0 <malloc+0x19a8>
    1eb8:	fcf43823          	sd	a5,-48(s0)
    1ebc:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    1ec0:	fd040593          	addi	a1,s0,-48
    1ec4:	8526                	mv	a0,s1
    1ec6:	28d030ef          	jal	5952 <exec>
  if (ret != -1) {
    1eca:	57fd                	li	a5,-1
    1ecc:	06f51a63          	bne	a0,a5,1f40 <copyinstr3+0xee>
}
    1ed0:	70a2                	ld	ra,40(sp)
    1ed2:	7402                	ld	s0,32(sp)
    1ed4:	64e2                	ld	s1,24(sp)
    1ed6:	6145                	addi	sp,sp,48
    1ed8:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    1eda:	0347d513          	srli	a0,a5,0x34
    1ede:	6785                	lui	a5,0x1
    1ee0:	40a7853b          	subw	a0,a5,a0
    1ee4:	203030ef          	jal	58e6 <sbrk>
    1ee8:	b759                	j	1e6e <copyinstr3+0x1c>
    printf("oops\n");
    1eea:	00005517          	auipc	a0,0x5
    1eee:	bfe50513          	addi	a0,a0,-1026 # 6ae8 <malloc+0xcc0>
    1ef2:	67f030ef          	jal	5d70 <printf>
    exit(1);
    1ef6:	4505                	li	a0,1
    1ef8:	223030ef          	jal	591a <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    1efc:	862a                	mv	a2,a0
    1efe:	85a6                	mv	a1,s1
    1f00:	00005517          	auipc	a0,0x5
    1f04:	80850513          	addi	a0,a0,-2040 # 6708 <malloc+0x8e0>
    1f08:	669030ef          	jal	5d70 <printf>
    exit(1);
    1f0c:	4505                	li	a0,1
    1f0e:	20d030ef          	jal	591a <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    1f12:	862a                	mv	a2,a0
    1f14:	85a6                	mv	a1,s1
    1f16:	00005517          	auipc	a0,0x5
    1f1a:	81250513          	addi	a0,a0,-2030 # 6728 <malloc+0x900>
    1f1e:	653030ef          	jal	5d70 <printf>
    exit(1);
    1f22:	4505                	li	a0,1
    1f24:	1f7030ef          	jal	591a <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1f28:	86aa                	mv	a3,a0
    1f2a:	8626                	mv	a2,s1
    1f2c:	85a6                	mv	a1,s1
    1f2e:	00005517          	auipc	a0,0x5
    1f32:	81a50513          	addi	a0,a0,-2022 # 6748 <malloc+0x920>
    1f36:	63b030ef          	jal	5d70 <printf>
    exit(1);
    1f3a:	4505                	li	a0,1
    1f3c:	1df030ef          	jal	591a <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1f40:	863e                	mv	a2,a5
    1f42:	85a6                	mv	a1,s1
    1f44:	00005517          	auipc	a0,0x5
    1f48:	82c50513          	addi	a0,a0,-2004 # 6770 <malloc+0x948>
    1f4c:	625030ef          	jal	5d70 <printf>
    exit(1);
    1f50:	4505                	li	a0,1
    1f52:	1c9030ef          	jal	591a <exit>

0000000000001f56 <rwsbrk>:
{
    1f56:	1101                	addi	sp,sp,-32
    1f58:	ec06                	sd	ra,24(sp)
    1f5a:	e822                	sd	s0,16(sp)
    1f5c:	1000                	addi	s0,sp,32
  uint64 a = (uint64)sbrk(8192);
    1f5e:	6509                	lui	a0,0x2
    1f60:	187030ef          	jal	58e6 <sbrk>
  if (a == (uint64)SBRK_ERROR) {
    1f64:	57fd                	li	a5,-1
    1f66:	04f50a63          	beq	a0,a5,1fba <rwsbrk+0x64>
    1f6a:	e426                	sd	s1,8(sp)
    1f6c:	84aa                	mv	s1,a0
  if (sbrk(-8192) == SBRK_ERROR) {
    1f6e:	7579                	lui	a0,0xffffe
    1f70:	177030ef          	jal	58e6 <sbrk>
    1f74:	57fd                	li	a5,-1
    1f76:	04f50d63          	beq	a0,a5,1fd0 <rwsbrk+0x7a>
    1f7a:	e04a                	sd	s2,0(sp)
  fd = open("rwsbrk", O_CREATE | O_WRONLY);
    1f7c:	20100593          	li	a1,513
    1f80:	00005517          	auipc	a0,0x5
    1f84:	ba850513          	addi	a0,a0,-1112 # 6b28 <malloc+0xd00>
    1f88:	1d3030ef          	jal	595a <open>
    1f8c:	892a                	mv	s2,a0
  if (fd < 0) {
    1f8e:	04054b63          	bltz	a0,1fe4 <rwsbrk+0x8e>
  n = write(fd, (void *)(a + PGSIZE), 1024);
    1f92:	6785                	lui	a5,0x1
    1f94:	94be                	add	s1,s1,a5
    1f96:	40000613          	li	a2,1024
    1f9a:	85a6                	mv	a1,s1
    1f9c:	19f030ef          	jal	593a <write>
    1fa0:	862a                	mv	a2,a0
  if (n >= 0) {
    1fa2:	04054a63          	bltz	a0,1ff6 <rwsbrk+0xa0>
    printf("write(fd, %p, 1024) returned %d, not -1\n", (void *)a + PGSIZE, n);
    1fa6:	85a6                	mv	a1,s1
    1fa8:	00005517          	auipc	a0,0x5
    1fac:	ba050513          	addi	a0,a0,-1120 # 6b48 <malloc+0xd20>
    1fb0:	5c1030ef          	jal	5d70 <printf>
    exit(1);
    1fb4:	4505                	li	a0,1
    1fb6:	165030ef          	jal	591a <exit>
    1fba:	e426                	sd	s1,8(sp)
    1fbc:	e04a                	sd	s2,0(sp)
    printf("sbrk(rwsbrk) failed\n");
    1fbe:	00005517          	auipc	a0,0x5
    1fc2:	b3250513          	addi	a0,a0,-1230 # 6af0 <malloc+0xcc8>
    1fc6:	5ab030ef          	jal	5d70 <printf>
    exit(1);
    1fca:	4505                	li	a0,1
    1fcc:	14f030ef          	jal	591a <exit>
    1fd0:	e04a                	sd	s2,0(sp)
    printf("sbrk(rwsbrk) shrink failed\n");
    1fd2:	00005517          	auipc	a0,0x5
    1fd6:	b3650513          	addi	a0,a0,-1226 # 6b08 <malloc+0xce0>
    1fda:	597030ef          	jal	5d70 <printf>
    exit(1);
    1fde:	4505                	li	a0,1
    1fe0:	13b030ef          	jal	591a <exit>
    printf("open(rwsbrk) failed\n");
    1fe4:	00005517          	auipc	a0,0x5
    1fe8:	b4c50513          	addi	a0,a0,-1204 # 6b30 <malloc+0xd08>
    1fec:	585030ef          	jal	5d70 <printf>
    exit(1);
    1ff0:	4505                	li	a0,1
    1ff2:	129030ef          	jal	591a <exit>
  close(fd);
    1ff6:	854a                	mv	a0,s2
    1ff8:	14b030ef          	jal	5942 <close>
  unlink("rwsbrk");
    1ffc:	00005517          	auipc	a0,0x5
    2000:	b2c50513          	addi	a0,a0,-1236 # 6b28 <malloc+0xd00>
    2004:	167030ef          	jal	596a <unlink>
  fd = open("README", O_RDONLY);
    2008:	4581                	li	a1,0
    200a:	00004517          	auipc	a0,0x4
    200e:	12650513          	addi	a0,a0,294 # 6130 <malloc+0x308>
    2012:	149030ef          	jal	595a <open>
    2016:	892a                	mv	s2,a0
  if (fd < 0) {
    2018:	02054363          	bltz	a0,203e <rwsbrk+0xe8>
  n = read(fd, (void *)(a + PGSIZE), 10);
    201c:	4629                	li	a2,10
    201e:	85a6                	mv	a1,s1
    2020:	113030ef          	jal	5932 <read>
    2024:	862a                	mv	a2,a0
  if (n >= 0) {
    2026:	02054563          	bltz	a0,2050 <rwsbrk+0xfa>
    printf("read(fd, %p, 10) returned %d, not -1\n", (void *)a + PGSIZE, n);
    202a:	85a6                	mv	a1,s1
    202c:	00005517          	auipc	a0,0x5
    2030:	b4c50513          	addi	a0,a0,-1204 # 6b78 <malloc+0xd50>
    2034:	53d030ef          	jal	5d70 <printf>
    exit(1);
    2038:	4505                	li	a0,1
    203a:	0e1030ef          	jal	591a <exit>
    printf("open(README) failed\n");
    203e:	00004517          	auipc	a0,0x4
    2042:	0fa50513          	addi	a0,a0,250 # 6138 <malloc+0x310>
    2046:	52b030ef          	jal	5d70 <printf>
    exit(1);
    204a:	4505                	li	a0,1
    204c:	0cf030ef          	jal	591a <exit>
  close(fd);
    2050:	854a                	mv	a0,s2
    2052:	0f1030ef          	jal	5942 <close>
  exit(0);
    2056:	4501                	li	a0,0
    2058:	0c3030ef          	jal	591a <exit>

000000000000205c <sbrkbasic>:
{
    205c:	715d                	addi	sp,sp,-80
    205e:	e486                	sd	ra,72(sp)
    2060:	e0a2                	sd	s0,64(sp)
    2062:	ec56                	sd	s5,24(sp)
    2064:	0880                	addi	s0,sp,80
    2066:	8aaa                	mv	s5,a0
  pid = fork();
    2068:	0ab030ef          	jal	5912 <fork>
  if (pid < 0) {
    206c:	02054c63          	bltz	a0,20a4 <sbrkbasic+0x48>
  if (pid == 0) {
    2070:	ed31                	bnez	a0,20cc <sbrkbasic+0x70>
    a = sbrk(TOOMUCH);
    2072:	40000537          	lui	a0,0x40000
    2076:	071030ef          	jal	58e6 <sbrk>
    if (a == (char *)SBRK_ERROR) {
    207a:	57fd                	li	a5,-1
    207c:	04f50163          	beq	a0,a5,20be <sbrkbasic+0x62>
    2080:	fc26                	sd	s1,56(sp)
    2082:	f84a                	sd	s2,48(sp)
    2084:	f44e                	sd	s3,40(sp)
    2086:	f052                	sd	s4,32(sp)
    for (b = a; b < a + TOOMUCH; b += PGSIZE) {
    2088:	400007b7          	lui	a5,0x40000
    208c:	97aa                	add	a5,a5,a0
      *b = 99;
    208e:	06300693          	li	a3,99
    for (b = a; b < a + TOOMUCH; b += PGSIZE) {
    2092:	6705                	lui	a4,0x1
      *b = 99;
    2094:	00d50023          	sb	a3,0(a0) # 40000000 <base+0x3ffee2f8>
    for (b = a; b < a + TOOMUCH; b += PGSIZE) {
    2098:	953a                	add	a0,a0,a4
    209a:	fef51de3          	bne	a0,a5,2094 <sbrkbasic+0x38>
    exit(1);
    209e:	4505                	li	a0,1
    20a0:	07b030ef          	jal	591a <exit>
    20a4:	fc26                	sd	s1,56(sp)
    20a6:	f84a                	sd	s2,48(sp)
    20a8:	f44e                	sd	s3,40(sp)
    20aa:	f052                	sd	s4,32(sp)
    printf("fork failed in sbrkbasic\n");
    20ac:	00005517          	auipc	a0,0x5
    20b0:	af450513          	addi	a0,a0,-1292 # 6ba0 <malloc+0xd78>
    20b4:	4bd030ef          	jal	5d70 <printf>
    exit(1);
    20b8:	4505                	li	a0,1
    20ba:	061030ef          	jal	591a <exit>
    20be:	fc26                	sd	s1,56(sp)
    20c0:	f84a                	sd	s2,48(sp)
    20c2:	f44e                	sd	s3,40(sp)
    20c4:	f052                	sd	s4,32(sp)
      exit(0);
    20c6:	4501                	li	a0,0
    20c8:	053030ef          	jal	591a <exit>
  wait(&xstatus);
    20cc:	fbc40513          	addi	a0,s0,-68
    20d0:	053030ef          	jal	5922 <wait>
  if (xstatus == 1) {
    20d4:	fbc42703          	lw	a4,-68(s0)
    20d8:	4785                	li	a5,1
    20da:	02f70063          	beq	a4,a5,20fa <sbrkbasic+0x9e>
    20de:	fc26                	sd	s1,56(sp)
    20e0:	f84a                	sd	s2,48(sp)
    20e2:	f44e                	sd	s3,40(sp)
    20e4:	f052                	sd	s4,32(sp)
  a = sbrk(0);
    20e6:	4501                	li	a0,0
    20e8:	7fe030ef          	jal	58e6 <sbrk>
    20ec:	84aa                	mv	s1,a0
  for (i = 0; i < 5000; i++) {
    20ee:	4901                	li	s2,0
    b = sbrk(1);
    20f0:	4985                	li	s3,1
  for (i = 0; i < 5000; i++) {
    20f2:	6a05                	lui	s4,0x1
    20f4:	388a0a13          	addi	s4,s4,904 # 1388 <truncate3+0x14a>
    20f8:	a005                	j	2118 <sbrkbasic+0xbc>
    20fa:	fc26                	sd	s1,56(sp)
    20fc:	f84a                	sd	s2,48(sp)
    20fe:	f44e                	sd	s3,40(sp)
    2100:	f052                	sd	s4,32(sp)
    printf("%s: too much memory allocated!\n", s);
    2102:	85d6                	mv	a1,s5
    2104:	00005517          	auipc	a0,0x5
    2108:	abc50513          	addi	a0,a0,-1348 # 6bc0 <malloc+0xd98>
    210c:	465030ef          	jal	5d70 <printf>
    exit(1);
    2110:	4505                	li	a0,1
    2112:	009030ef          	jal	591a <exit>
    2116:	84be                	mv	s1,a5
    b = sbrk(1);
    2118:	854e                	mv	a0,s3
    211a:	7cc030ef          	jal	58e6 <sbrk>
    if (b != a) {
    211e:	04951163          	bne	a0,s1,2160 <sbrkbasic+0x104>
    *b = 1;
    2122:	01348023          	sb	s3,0(s1)
    a = b + 1;
    2126:	00148793          	addi	a5,s1,1
  for (i = 0; i < 5000; i++) {
    212a:	2905                	addiw	s2,s2,1
    212c:	ff4915e3          	bne	s2,s4,2116 <sbrkbasic+0xba>
  pid = fork();
    2130:	7e2030ef          	jal	5912 <fork>
    2134:	892a                	mv	s2,a0
  if (pid < 0) {
    2136:	04054263          	bltz	a0,217a <sbrkbasic+0x11e>
  c = sbrk(1);
    213a:	4505                	li	a0,1
    213c:	7aa030ef          	jal	58e6 <sbrk>
  c = sbrk(1);
    2140:	4505                	li	a0,1
    2142:	7a4030ef          	jal	58e6 <sbrk>
  if (c != a + 1) {
    2146:	0489                	addi	s1,s1,2
    2148:	04950363          	beq	a0,s1,218e <sbrkbasic+0x132>
    printf("%s: sbrk test failed post-fork\n", s);
    214c:	85d6                	mv	a1,s5
    214e:	00005517          	auipc	a0,0x5
    2152:	ad250513          	addi	a0,a0,-1326 # 6c20 <malloc+0xdf8>
    2156:	41b030ef          	jal	5d70 <printf>
    exit(1);
    215a:	4505                	li	a0,1
    215c:	7be030ef          	jal	591a <exit>
      printf("%s: sbrk test failed %d %p %p\n", s, i, a, b);
    2160:	872a                	mv	a4,a0
    2162:	86a6                	mv	a3,s1
    2164:	864a                	mv	a2,s2
    2166:	85d6                	mv	a1,s5
    2168:	00005517          	auipc	a0,0x5
    216c:	a7850513          	addi	a0,a0,-1416 # 6be0 <malloc+0xdb8>
    2170:	401030ef          	jal	5d70 <printf>
      exit(1);
    2174:	4505                	li	a0,1
    2176:	7a4030ef          	jal	591a <exit>
    printf("%s: sbrk test fork failed\n", s);
    217a:	85d6                	mv	a1,s5
    217c:	00005517          	auipc	a0,0x5
    2180:	a8450513          	addi	a0,a0,-1404 # 6c00 <malloc+0xdd8>
    2184:	3ed030ef          	jal	5d70 <printf>
    exit(1);
    2188:	4505                	li	a0,1
    218a:	790030ef          	jal	591a <exit>
  if (pid == 0)
    218e:	00091563          	bnez	s2,2198 <sbrkbasic+0x13c>
    exit(0);
    2192:	4501                	li	a0,0
    2194:	786030ef          	jal	591a <exit>
  wait(&xstatus);
    2198:	fbc40513          	addi	a0,s0,-68
    219c:	786030ef          	jal	5922 <wait>
  exit(xstatus);
    21a0:	fbc42503          	lw	a0,-68(s0)
    21a4:	776030ef          	jal	591a <exit>

00000000000021a8 <sbrkmuch>:
{
    21a8:	7179                	addi	sp,sp,-48
    21aa:	f406                	sd	ra,40(sp)
    21ac:	f022                	sd	s0,32(sp)
    21ae:	ec26                	sd	s1,24(sp)
    21b0:	e84a                	sd	s2,16(sp)
    21b2:	e44e                	sd	s3,8(sp)
    21b4:	e052                	sd	s4,0(sp)
    21b6:	1800                	addi	s0,sp,48
    21b8:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    21ba:	4501                	li	a0,0
    21bc:	72a030ef          	jal	58e6 <sbrk>
    21c0:	892a                	mv	s2,a0
  a = sbrk(0);
    21c2:	4501                	li	a0,0
    21c4:	722030ef          	jal	58e6 <sbrk>
    21c8:	84aa                	mv	s1,a0
  p = sbrk(amt);
    21ca:	06400537          	lui	a0,0x6400
    21ce:	9d05                	subw	a0,a0,s1
    21d0:	716030ef          	jal	58e6 <sbrk>
  if (p != a) {
    21d4:	08a49963          	bne	s1,a0,2266 <sbrkmuch+0xbe>
  *lastaddr = 99;
    21d8:	064007b7          	lui	a5,0x6400
    21dc:	06300713          	li	a4,99
    21e0:	fee78fa3          	sb	a4,-1(a5) # 63fffff <base+0x63ee2f7>
  a = sbrk(0);
    21e4:	4501                	li	a0,0
    21e6:	700030ef          	jal	58e6 <sbrk>
    21ea:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    21ec:	757d                	lui	a0,0xfffff
    21ee:	6f8030ef          	jal	58e6 <sbrk>
  if (c == (char *)SBRK_ERROR) {
    21f2:	57fd                	li	a5,-1
    21f4:	08f50363          	beq	a0,a5,227a <sbrkmuch+0xd2>
  c = sbrk(0);
    21f8:	4501                	li	a0,0
    21fa:	6ec030ef          	jal	58e6 <sbrk>
  if (c != a - PGSIZE) {
    21fe:	80048793          	addi	a5,s1,-2048
    2202:	80078793          	addi	a5,a5,-2048
    2206:	08f51463          	bne	a0,a5,228e <sbrkmuch+0xe6>
  a = sbrk(0);
    220a:	4501                	li	a0,0
    220c:	6da030ef          	jal	58e6 <sbrk>
    2210:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    2212:	6505                	lui	a0,0x1
    2214:	6d2030ef          	jal	58e6 <sbrk>
    2218:	8a2a                	mv	s4,a0
  if (c != a || sbrk(0) != a + PGSIZE) {
    221a:	08a49663          	bne	s1,a0,22a6 <sbrkmuch+0xfe>
    221e:	4501                	li	a0,0
    2220:	6c6030ef          	jal	58e6 <sbrk>
    2224:	6785                	lui	a5,0x1
    2226:	97a6                	add	a5,a5,s1
    2228:	06f51f63          	bne	a0,a5,22a6 <sbrkmuch+0xfe>
  if (*lastaddr == 99) {
    222c:	064007b7          	lui	a5,0x6400
    2230:	fff7c703          	lbu	a4,-1(a5) # 63fffff <base+0x63ee2f7>
    2234:	06300793          	li	a5,99
    2238:	08f70363          	beq	a4,a5,22be <sbrkmuch+0x116>
  a = sbrk(0);
    223c:	4501                	li	a0,0
    223e:	6a8030ef          	jal	58e6 <sbrk>
    2242:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    2244:	4501                	li	a0,0
    2246:	6a0030ef          	jal	58e6 <sbrk>
    224a:	40a9053b          	subw	a0,s2,a0
    224e:	698030ef          	jal	58e6 <sbrk>
  if (c != a) {
    2252:	08a49063          	bne	s1,a0,22d2 <sbrkmuch+0x12a>
}
    2256:	70a2                	ld	ra,40(sp)
    2258:	7402                	ld	s0,32(sp)
    225a:	64e2                	ld	s1,24(sp)
    225c:	6942                	ld	s2,16(sp)
    225e:	69a2                	ld	s3,8(sp)
    2260:	6a02                	ld	s4,0(sp)
    2262:	6145                	addi	sp,sp,48
    2264:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n",
    2266:	85ce                	mv	a1,s3
    2268:	00005517          	auipc	a0,0x5
    226c:	9d850513          	addi	a0,a0,-1576 # 6c40 <malloc+0xe18>
    2270:	301030ef          	jal	5d70 <printf>
    exit(1);
    2274:	4505                	li	a0,1
    2276:	6a4030ef          	jal	591a <exit>
    printf("%s: sbrk could not deallocate\n", s);
    227a:	85ce                	mv	a1,s3
    227c:	00005517          	auipc	a0,0x5
    2280:	a0c50513          	addi	a0,a0,-1524 # 6c88 <malloc+0xe60>
    2284:	2ed030ef          	jal	5d70 <printf>
    exit(1);
    2288:	4505                	li	a0,1
    228a:	690030ef          	jal	591a <exit>
    printf("%s: sbrk deallocation produced wrong address, a %p c %p\n", s, a,
    228e:	86aa                	mv	a3,a0
    2290:	8626                	mv	a2,s1
    2292:	85ce                	mv	a1,s3
    2294:	00005517          	auipc	a0,0x5
    2298:	a1450513          	addi	a0,a0,-1516 # 6ca8 <malloc+0xe80>
    229c:	2d5030ef          	jal	5d70 <printf>
    exit(1);
    22a0:	4505                	li	a0,1
    22a2:	678030ef          	jal	591a <exit>
    printf("%s: sbrk re-allocation failed, a %p c %p\n", s, a, c);
    22a6:	86d2                	mv	a3,s4
    22a8:	8626                	mv	a2,s1
    22aa:	85ce                	mv	a1,s3
    22ac:	00005517          	auipc	a0,0x5
    22b0:	a3c50513          	addi	a0,a0,-1476 # 6ce8 <malloc+0xec0>
    22b4:	2bd030ef          	jal	5d70 <printf>
    exit(1);
    22b8:	4505                	li	a0,1
    22ba:	660030ef          	jal	591a <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    22be:	85ce                	mv	a1,s3
    22c0:	00005517          	auipc	a0,0x5
    22c4:	a5850513          	addi	a0,a0,-1448 # 6d18 <malloc+0xef0>
    22c8:	2a9030ef          	jal	5d70 <printf>
    exit(1);
    22cc:	4505                	li	a0,1
    22ce:	64c030ef          	jal	591a <exit>
    printf("%s: sbrk downsize failed, a %p c %p\n", s, a, c);
    22d2:	86aa                	mv	a3,a0
    22d4:	8626                	mv	a2,s1
    22d6:	85ce                	mv	a1,s3
    22d8:	00005517          	auipc	a0,0x5
    22dc:	a7850513          	addi	a0,a0,-1416 # 6d50 <malloc+0xf28>
    22e0:	291030ef          	jal	5d70 <printf>
    exit(1);
    22e4:	4505                	li	a0,1
    22e6:	634030ef          	jal	591a <exit>

00000000000022ea <sbrkarg>:
{
    22ea:	7179                	addi	sp,sp,-48
    22ec:	f406                	sd	ra,40(sp)
    22ee:	f022                	sd	s0,32(sp)
    22f0:	ec26                	sd	s1,24(sp)
    22f2:	e84a                	sd	s2,16(sp)
    22f4:	e44e                	sd	s3,8(sp)
    22f6:	1800                	addi	s0,sp,48
    22f8:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    22fa:	6505                	lui	a0,0x1
    22fc:	5ea030ef          	jal	58e6 <sbrk>
    2300:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE | O_WRONLY);
    2302:	20100593          	li	a1,513
    2306:	00005517          	auipc	a0,0x5
    230a:	a7250513          	addi	a0,a0,-1422 # 6d78 <malloc+0xf50>
    230e:	64c030ef          	jal	595a <open>
    2312:	84aa                	mv	s1,a0
  unlink("sbrk");
    2314:	00005517          	auipc	a0,0x5
    2318:	a6450513          	addi	a0,a0,-1436 # 6d78 <malloc+0xf50>
    231c:	64e030ef          	jal	596a <unlink>
  if (fd < 0) {
    2320:	0204c963          	bltz	s1,2352 <sbrkarg+0x68>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    2324:	6605                	lui	a2,0x1
    2326:	85ca                	mv	a1,s2
    2328:	8526                	mv	a0,s1
    232a:	610030ef          	jal	593a <write>
    232e:	02054c63          	bltz	a0,2366 <sbrkarg+0x7c>
  close(fd);
    2332:	8526                	mv	a0,s1
    2334:	60e030ef          	jal	5942 <close>
  a = sbrk(PGSIZE);
    2338:	6505                	lui	a0,0x1
    233a:	5ac030ef          	jal	58e6 <sbrk>
  if (pipe((int *)a) != 0) {
    233e:	5ec030ef          	jal	592a <pipe>
    2342:	ed05                	bnez	a0,237a <sbrkarg+0x90>
}
    2344:	70a2                	ld	ra,40(sp)
    2346:	7402                	ld	s0,32(sp)
    2348:	64e2                	ld	s1,24(sp)
    234a:	6942                	ld	s2,16(sp)
    234c:	69a2                	ld	s3,8(sp)
    234e:	6145                	addi	sp,sp,48
    2350:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2352:	85ce                	mv	a1,s3
    2354:	00005517          	auipc	a0,0x5
    2358:	a2c50513          	addi	a0,a0,-1492 # 6d80 <malloc+0xf58>
    235c:	215030ef          	jal	5d70 <printf>
    exit(1);
    2360:	4505                	li	a0,1
    2362:	5b8030ef          	jal	591a <exit>
    printf("%s: write sbrk failed\n", s);
    2366:	85ce                	mv	a1,s3
    2368:	00005517          	auipc	a0,0x5
    236c:	a3050513          	addi	a0,a0,-1488 # 6d98 <malloc+0xf70>
    2370:	201030ef          	jal	5d70 <printf>
    exit(1);
    2374:	4505                	li	a0,1
    2376:	5a4030ef          	jal	591a <exit>
    printf("%s: pipe() failed\n", s);
    237a:	85ce                	mv	a1,s3
    237c:	00004517          	auipc	a0,0x4
    2380:	4f450513          	addi	a0,a0,1268 # 6870 <malloc+0xa48>
    2384:	1ed030ef          	jal	5d70 <printf>
    exit(1);
    2388:	4505                	li	a0,1
    238a:	590030ef          	jal	591a <exit>

000000000000238e <argptest>:
{
    238e:	1101                	addi	sp,sp,-32
    2390:	ec06                	sd	ra,24(sp)
    2392:	e822                	sd	s0,16(sp)
    2394:	e426                	sd	s1,8(sp)
    2396:	e04a                	sd	s2,0(sp)
    2398:	1000                	addi	s0,sp,32
    239a:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    239c:	4581                	li	a1,0
    239e:	00005517          	auipc	a0,0x5
    23a2:	a1250513          	addi	a0,a0,-1518 # 6db0 <malloc+0xf88>
    23a6:	5b4030ef          	jal	595a <open>
  if (fd < 0) {
    23aa:	02054563          	bltz	a0,23d4 <argptest+0x46>
    23ae:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    23b0:	4501                	li	a0,0
    23b2:	534030ef          	jal	58e6 <sbrk>
    23b6:	567d                	li	a2,-1
    23b8:	00c505b3          	add	a1,a0,a2
    23bc:	8526                	mv	a0,s1
    23be:	574030ef          	jal	5932 <read>
  close(fd);
    23c2:	8526                	mv	a0,s1
    23c4:	57e030ef          	jal	5942 <close>
}
    23c8:	60e2                	ld	ra,24(sp)
    23ca:	6442                	ld	s0,16(sp)
    23cc:	64a2                	ld	s1,8(sp)
    23ce:	6902                	ld	s2,0(sp)
    23d0:	6105                	addi	sp,sp,32
    23d2:	8082                	ret
    printf("%s: open failed\n", s);
    23d4:	85ca                	mv	a1,s2
    23d6:	00004517          	auipc	a0,0x4
    23da:	42a50513          	addi	a0,a0,1066 # 6800 <malloc+0x9d8>
    23de:	193030ef          	jal	5d70 <printf>
    exit(1);
    23e2:	4505                	li	a0,1
    23e4:	536030ef          	jal	591a <exit>

00000000000023e8 <sbrkbugs>:
{
    23e8:	1141                	addi	sp,sp,-16
    23ea:	e406                	sd	ra,8(sp)
    23ec:	e022                	sd	s0,0(sp)
    23ee:	0800                	addi	s0,sp,16
  int pid = fork();
    23f0:	522030ef          	jal	5912 <fork>
  if (pid < 0) {
    23f4:	00054c63          	bltz	a0,240c <sbrkbugs+0x24>
  if (pid == 0) {
    23f8:	e11d                	bnez	a0,241e <sbrkbugs+0x36>
    int sz = (uint64)sbrk(0);
    23fa:	4ec030ef          	jal	58e6 <sbrk>
    sbrk(-sz);
    23fe:	40a0053b          	negw	a0,a0
    2402:	4e4030ef          	jal	58e6 <sbrk>
    exit(0);
    2406:	4501                	li	a0,0
    2408:	512030ef          	jal	591a <exit>
    printf("fork failed\n");
    240c:	00006517          	auipc	a0,0x6
    2410:	b5c50513          	addi	a0,a0,-1188 # 7f68 <malloc+0x2140>
    2414:	15d030ef          	jal	5d70 <printf>
    exit(1);
    2418:	4505                	li	a0,1
    241a:	500030ef          	jal	591a <exit>
  wait(0);
    241e:	4501                	li	a0,0
    2420:	502030ef          	jal	5922 <wait>
  pid = fork();
    2424:	4ee030ef          	jal	5912 <fork>
  if (pid < 0) {
    2428:	00054f63          	bltz	a0,2446 <sbrkbugs+0x5e>
  if (pid == 0) {
    242c:	e515                	bnez	a0,2458 <sbrkbugs+0x70>
    int sz = (uint64)sbrk(0);
    242e:	4b8030ef          	jal	58e6 <sbrk>
    sbrk(-(sz - 3500));
    2432:	6785                	lui	a5,0x1
    2434:	dac7879b          	addiw	a5,a5,-596 # dac <linktest+0xe2>
    2438:	40a7853b          	subw	a0,a5,a0
    243c:	4aa030ef          	jal	58e6 <sbrk>
    exit(0);
    2440:	4501                	li	a0,0
    2442:	4d8030ef          	jal	591a <exit>
    printf("fork failed\n");
    2446:	00006517          	auipc	a0,0x6
    244a:	b2250513          	addi	a0,a0,-1246 # 7f68 <malloc+0x2140>
    244e:	123030ef          	jal	5d70 <printf>
    exit(1);
    2452:	4505                	li	a0,1
    2454:	4c6030ef          	jal	591a <exit>
  wait(0);
    2458:	4501                	li	a0,0
    245a:	4c8030ef          	jal	5922 <wait>
  pid = fork();
    245e:	4b4030ef          	jal	5912 <fork>
  if (pid < 0) {
    2462:	02054263          	bltz	a0,2486 <sbrkbugs+0x9e>
  if (pid == 0) {
    2466:	e90d                	bnez	a0,2498 <sbrkbugs+0xb0>
    sbrk((10 * PGSIZE + 2048) - (uint64)sbrk(0));
    2468:	47e030ef          	jal	58e6 <sbrk>
    246c:	67ad                	lui	a5,0xb
    246e:	8007879b          	addiw	a5,a5,-2048 # a800 <digits+0x1e48>
    2472:	40a7853b          	subw	a0,a5,a0
    2476:	470030ef          	jal	58e6 <sbrk>
    sbrk(-10);
    247a:	5559                	li	a0,-10
    247c:	46a030ef          	jal	58e6 <sbrk>
    exit(0);
    2480:	4501                	li	a0,0
    2482:	498030ef          	jal	591a <exit>
    printf("fork failed\n");
    2486:	00006517          	auipc	a0,0x6
    248a:	ae250513          	addi	a0,a0,-1310 # 7f68 <malloc+0x2140>
    248e:	0e3030ef          	jal	5d70 <printf>
    exit(1);
    2492:	4505                	li	a0,1
    2494:	486030ef          	jal	591a <exit>
  wait(0);
    2498:	4501                	li	a0,0
    249a:	488030ef          	jal	5922 <wait>
  exit(0);
    249e:	4501                	li	a0,0
    24a0:	47a030ef          	jal	591a <exit>

00000000000024a4 <sbrklast>:
{
    24a4:	7179                	addi	sp,sp,-48
    24a6:	f406                	sd	ra,40(sp)
    24a8:	f022                	sd	s0,32(sp)
    24aa:	ec26                	sd	s1,24(sp)
    24ac:	e84a                	sd	s2,16(sp)
    24ae:	e44e                	sd	s3,8(sp)
    24b0:	e052                	sd	s4,0(sp)
    24b2:	1800                	addi	s0,sp,48
  uint64 top = (uint64)sbrk(0);
    24b4:	4501                	li	a0,0
    24b6:	430030ef          	jal	58e6 <sbrk>
  if ((top % PGSIZE) != 0)
    24ba:	03451793          	slli	a5,a0,0x34
    24be:	ebad                	bnez	a5,2530 <sbrklast+0x8c>
  sbrk(PGSIZE);
    24c0:	6505                	lui	a0,0x1
    24c2:	424030ef          	jal	58e6 <sbrk>
  sbrk(10);
    24c6:	4529                	li	a0,10
    24c8:	41e030ef          	jal	58e6 <sbrk>
  sbrk(-20);
    24cc:	5531                	li	a0,-20
    24ce:	418030ef          	jal	58e6 <sbrk>
  top = (uint64)sbrk(0);
    24d2:	4501                	li	a0,0
    24d4:	412030ef          	jal	58e6 <sbrk>
    24d8:	84aa                	mv	s1,a0
  char *p = (char *)(top - 64);
    24da:	fc050913          	addi	s2,a0,-64 # fc0 <bigdir+0xcc>
  p[0] = 'x';
    24de:	07800993          	li	s3,120
    24e2:	fd350023          	sb	s3,-64(a0)
  p[1] = '\0';
    24e6:	fc0500a3          	sb	zero,-63(a0)
  int fd = open(p, O_RDWR | O_CREATE);
    24ea:	20200593          	li	a1,514
    24ee:	854a                	mv	a0,s2
    24f0:	46a030ef          	jal	595a <open>
    24f4:	8a2a                	mv	s4,a0
  write(fd, p, 1);
    24f6:	4605                	li	a2,1
    24f8:	85ca                	mv	a1,s2
    24fa:	440030ef          	jal	593a <write>
  close(fd);
    24fe:	8552                	mv	a0,s4
    2500:	442030ef          	jal	5942 <close>
  fd = open(p, O_RDWR);
    2504:	4589                	li	a1,2
    2506:	854a                	mv	a0,s2
    2508:	452030ef          	jal	595a <open>
  p[0] = '\0';
    250c:	fc048023          	sb	zero,-64(s1)
  read(fd, p, 1);
    2510:	4605                	li	a2,1
    2512:	85ca                	mv	a1,s2
    2514:	41e030ef          	jal	5932 <read>
  if (p[0] != 'x')
    2518:	fc04c783          	lbu	a5,-64(s1)
    251c:	03379263          	bne	a5,s3,2540 <sbrklast+0x9c>
}
    2520:	70a2                	ld	ra,40(sp)
    2522:	7402                	ld	s0,32(sp)
    2524:	64e2                	ld	s1,24(sp)
    2526:	6942                	ld	s2,16(sp)
    2528:	69a2                	ld	s3,8(sp)
    252a:	6a02                	ld	s4,0(sp)
    252c:	6145                	addi	sp,sp,48
    252e:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    2530:	0347d513          	srli	a0,a5,0x34
    2534:	6785                	lui	a5,0x1
    2536:	40a7853b          	subw	a0,a5,a0
    253a:	3ac030ef          	jal	58e6 <sbrk>
    253e:	b749                	j	24c0 <sbrklast+0x1c>
    exit(1);
    2540:	4505                	li	a0,1
    2542:	3d8030ef          	jal	591a <exit>

0000000000002546 <sbrk8000>:
{
    2546:	1141                	addi	sp,sp,-16
    2548:	e406                	sd	ra,8(sp)
    254a:	e022                	sd	s0,0(sp)
    254c:	0800                	addi	s0,sp,16
  sbrk(0x80000004);
    254e:	80000537          	lui	a0,0x80000
    2552:	0511                	addi	a0,a0,4 # ffffffff80000004 <base+0xffffffff7ffee2fc>
    2554:	392030ef          	jal	58e6 <sbrk>
  volatile char *top = sbrk(0);
    2558:	4501                	li	a0,0
    255a:	38c030ef          	jal	58e6 <sbrk>
  *(top - 1) = *(top - 1) + 1;
    255e:	fff54783          	lbu	a5,-1(a0)
    2562:	0785                	addi	a5,a5,1 # 1001 <bigdir+0x10d>
    2564:	0ff7f793          	zext.b	a5,a5
    2568:	fef50fa3          	sb	a5,-1(a0)
}
    256c:	60a2                	ld	ra,8(sp)
    256e:	6402                	ld	s0,0(sp)
    2570:	0141                	addi	sp,sp,16
    2572:	8082                	ret

0000000000002574 <execout>:
{
    2574:	711d                	addi	sp,sp,-96
    2576:	ec86                	sd	ra,88(sp)
    2578:	e8a2                	sd	s0,80(sp)
    257a:	e4a6                	sd	s1,72(sp)
    257c:	e0ca                	sd	s2,64(sp)
    257e:	fc4e                	sd	s3,56(sp)
    2580:	1080                	addi	s0,sp,96
  for (int avail = 0; avail < 15; avail++) {
    2582:	4901                	li	s2,0
    2584:	49bd                	li	s3,15
    int pid = fork();
    2586:	38c030ef          	jal	5912 <fork>
    258a:	84aa                	mv	s1,a0
    if (pid < 0) {
    258c:	00054e63          	bltz	a0,25a8 <execout+0x34>
    } else if (pid == 0) {
    2590:	c51d                	beqz	a0,25be <execout+0x4a>
      wait((int *)0);
    2592:	4501                	li	a0,0
    2594:	38e030ef          	jal	5922 <wait>
  for (int avail = 0; avail < 15; avail++) {
    2598:	2905                	addiw	s2,s2,1
    259a:	ff3916e3          	bne	s2,s3,2586 <execout+0x12>
    259e:	f852                	sd	s4,48(sp)
    25a0:	f456                	sd	s5,40(sp)
  exit(0);
    25a2:	4501                	li	a0,0
    25a4:	376030ef          	jal	591a <exit>
    25a8:	f852                	sd	s4,48(sp)
    25aa:	f456                	sd	s5,40(sp)
      printf("fork failed\n");
    25ac:	00006517          	auipc	a0,0x6
    25b0:	9bc50513          	addi	a0,a0,-1604 # 7f68 <malloc+0x2140>
    25b4:	7bc030ef          	jal	5d70 <printf>
      exit(1);
    25b8:	4505                	li	a0,1
    25ba:	360030ef          	jal	591a <exit>
    25be:	f852                	sd	s4,48(sp)
    25c0:	f456                	sd	s5,40(sp)
        char *a = sbrk(PGSIZE);
    25c2:	6985                	lui	s3,0x1
        if (a == SBRK_ERROR)
    25c4:	5a7d                	li	s4,-1
        *(a + PGSIZE - 1) = 1;
    25c6:	4a85                	li	s5,1
        char *a = sbrk(PGSIZE);
    25c8:	854e                	mv	a0,s3
    25ca:	31c030ef          	jal	58e6 <sbrk>
        if (a == SBRK_ERROR)
    25ce:	01450663          	beq	a0,s4,25da <execout+0x66>
        *(a + PGSIZE - 1) = 1;
    25d2:	954e                	add	a0,a0,s3
    25d4:	ff550fa3          	sb	s5,-1(a0)
      while (1) {
    25d8:	bfc5                	j	25c8 <execout+0x54>
        sbrk(-PGSIZE);
    25da:	79fd                	lui	s3,0xfffff
      for (int i = 0; i < avail; i++)
    25dc:	01205863          	blez	s2,25ec <execout+0x78>
        sbrk(-PGSIZE);
    25e0:	854e                	mv	a0,s3
    25e2:	304030ef          	jal	58e6 <sbrk>
      for (int i = 0; i < avail; i++)
    25e6:	2485                	addiw	s1,s1,1
    25e8:	ff249ce3          	bne	s1,s2,25e0 <execout+0x6c>
      close(1);
    25ec:	4505                	li	a0,1
    25ee:	354030ef          	jal	5942 <close>
      char *args[] = {"echo", "x", 0};
    25f2:	00004797          	auipc	a5,0x4
    25f6:	96678793          	addi	a5,a5,-1690 # 5f58 <malloc+0x130>
    25fa:	faf43423          	sd	a5,-88(s0)
    25fe:	00004797          	auipc	a5,0x4
    2602:	9ca78793          	addi	a5,a5,-1590 # 5fc8 <malloc+0x1a0>
    2606:	faf43823          	sd	a5,-80(s0)
    260a:	fa043c23          	sd	zero,-72(s0)
      exec("echo", args);
    260e:	fa840593          	addi	a1,s0,-88
    2612:	00004517          	auipc	a0,0x4
    2616:	94650513          	addi	a0,a0,-1722 # 5f58 <malloc+0x130>
    261a:	338030ef          	jal	5952 <exec>
      exit(0);
    261e:	4501                	li	a0,0
    2620:	2fa030ef          	jal	591a <exit>

0000000000002624 <fourteen>:
{
    2624:	1101                	addi	sp,sp,-32
    2626:	ec06                	sd	ra,24(sp)
    2628:	e822                	sd	s0,16(sp)
    262a:	e426                	sd	s1,8(sp)
    262c:	1000                	addi	s0,sp,32
    262e:	84aa                	mv	s1,a0
  if (mkdir("12345678901234") != 0) {
    2630:	00005517          	auipc	a0,0x5
    2634:	95850513          	addi	a0,a0,-1704 # 6f88 <malloc+0x1160>
    2638:	34a030ef          	jal	5982 <mkdir>
    263c:	e555                	bnez	a0,26e8 <fourteen+0xc4>
  if (mkdir("12345678901234/123456789012345") != 0) {
    263e:	00004517          	auipc	a0,0x4
    2642:	7a250513          	addi	a0,a0,1954 # 6de0 <malloc+0xfb8>
    2646:	33c030ef          	jal	5982 <mkdir>
    264a:	e94d                	bnez	a0,26fc <fourteen+0xd8>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    264c:	20000593          	li	a1,512
    2650:	00004517          	auipc	a0,0x4
    2654:	7e850513          	addi	a0,a0,2024 # 6e38 <malloc+0x1010>
    2658:	302030ef          	jal	595a <open>
  if (fd < 0) {
    265c:	0a054a63          	bltz	a0,2710 <fourteen+0xec>
  close(fd);
    2660:	2e2030ef          	jal	5942 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2664:	4581                	li	a1,0
    2666:	00005517          	auipc	a0,0x5
    266a:	84a50513          	addi	a0,a0,-1974 # 6eb0 <malloc+0x1088>
    266e:	2ec030ef          	jal	595a <open>
  if (fd < 0) {
    2672:	0a054963          	bltz	a0,2724 <fourteen+0x100>
  close(fd);
    2676:	2cc030ef          	jal	5942 <close>
  if (mkdir("12345678901234/12345678901234") == 0) {
    267a:	00005517          	auipc	a0,0x5
    267e:	8a650513          	addi	a0,a0,-1882 # 6f20 <malloc+0x10f8>
    2682:	300030ef          	jal	5982 <mkdir>
    2686:	c94d                	beqz	a0,2738 <fourteen+0x114>
  if (mkdir("123456789012345/12345678901234") == 0) {
    2688:	00005517          	auipc	a0,0x5
    268c:	8f050513          	addi	a0,a0,-1808 # 6f78 <malloc+0x1150>
    2690:	2f2030ef          	jal	5982 <mkdir>
    2694:	cd45                	beqz	a0,274c <fourteen+0x128>
  unlink("123456789012345/12345678901234");
    2696:	00005517          	auipc	a0,0x5
    269a:	8e250513          	addi	a0,a0,-1822 # 6f78 <malloc+0x1150>
    269e:	2cc030ef          	jal	596a <unlink>
  unlink("12345678901234/12345678901234");
    26a2:	00005517          	auipc	a0,0x5
    26a6:	87e50513          	addi	a0,a0,-1922 # 6f20 <malloc+0x10f8>
    26aa:	2c0030ef          	jal	596a <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    26ae:	00005517          	auipc	a0,0x5
    26b2:	80250513          	addi	a0,a0,-2046 # 6eb0 <malloc+0x1088>
    26b6:	2b4030ef          	jal	596a <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    26ba:	00004517          	auipc	a0,0x4
    26be:	77e50513          	addi	a0,a0,1918 # 6e38 <malloc+0x1010>
    26c2:	2a8030ef          	jal	596a <unlink>
  unlink("12345678901234/123456789012345");
    26c6:	00004517          	auipc	a0,0x4
    26ca:	71a50513          	addi	a0,a0,1818 # 6de0 <malloc+0xfb8>
    26ce:	29c030ef          	jal	596a <unlink>
  unlink("12345678901234");
    26d2:	00005517          	auipc	a0,0x5
    26d6:	8b650513          	addi	a0,a0,-1866 # 6f88 <malloc+0x1160>
    26da:	290030ef          	jal	596a <unlink>
}
    26de:	60e2                	ld	ra,24(sp)
    26e0:	6442                	ld	s0,16(sp)
    26e2:	64a2                	ld	s1,8(sp)
    26e4:	6105                	addi	sp,sp,32
    26e6:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    26e8:	85a6                	mv	a1,s1
    26ea:	00004517          	auipc	a0,0x4
    26ee:	6ce50513          	addi	a0,a0,1742 # 6db8 <malloc+0xf90>
    26f2:	67e030ef          	jal	5d70 <printf>
    exit(1);
    26f6:	4505                	li	a0,1
    26f8:	222030ef          	jal	591a <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    26fc:	85a6                	mv	a1,s1
    26fe:	00004517          	auipc	a0,0x4
    2702:	70250513          	addi	a0,a0,1794 # 6e00 <malloc+0xfd8>
    2706:	66a030ef          	jal	5d70 <printf>
    exit(1);
    270a:	4505                	li	a0,1
    270c:	20e030ef          	jal	591a <exit>
    printf(
    2710:	85a6                	mv	a1,s1
    2712:	00004517          	auipc	a0,0x4
    2716:	75650513          	addi	a0,a0,1878 # 6e68 <malloc+0x1040>
    271a:	656030ef          	jal	5d70 <printf>
    exit(1);
    271e:	4505                	li	a0,1
    2720:	1fa030ef          	jal	591a <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    2724:	85a6                	mv	a1,s1
    2726:	00004517          	auipc	a0,0x4
    272a:	7ba50513          	addi	a0,a0,1978 # 6ee0 <malloc+0x10b8>
    272e:	642030ef          	jal	5d70 <printf>
    exit(1);
    2732:	4505                	li	a0,1
    2734:	1e6030ef          	jal	591a <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    2738:	85a6                	mv	a1,s1
    273a:	00005517          	auipc	a0,0x5
    273e:	80650513          	addi	a0,a0,-2042 # 6f40 <malloc+0x1118>
    2742:	62e030ef          	jal	5d70 <printf>
    exit(1);
    2746:	4505                	li	a0,1
    2748:	1d2030ef          	jal	591a <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    274c:	85a6                	mv	a1,s1
    274e:	00005517          	auipc	a0,0x5
    2752:	84a50513          	addi	a0,a0,-1974 # 6f98 <malloc+0x1170>
    2756:	61a030ef          	jal	5d70 <printf>
    exit(1);
    275a:	4505                	li	a0,1
    275c:	1be030ef          	jal	591a <exit>

0000000000002760 <diskfull>:
{
    2760:	b6010113          	addi	sp,sp,-1184
    2764:	48113c23          	sd	ra,1176(sp)
    2768:	48813823          	sd	s0,1168(sp)
    276c:	48913423          	sd	s1,1160(sp)
    2770:	49213023          	sd	s2,1152(sp)
    2774:	47313c23          	sd	s3,1144(sp)
    2778:	47413823          	sd	s4,1136(sp)
    277c:	47513423          	sd	s5,1128(sp)
    2780:	47613023          	sd	s6,1120(sp)
    2784:	45713c23          	sd	s7,1112(sp)
    2788:	45813823          	sd	s8,1104(sp)
    278c:	45913423          	sd	s9,1096(sp)
    2790:	45a13023          	sd	s10,1088(sp)
    2794:	43b13c23          	sd	s11,1080(sp)
    2798:	4a010413          	addi	s0,sp,1184
    279c:	b6a43423          	sd	a0,-1176(s0)
  unlink("diskfulldir");
    27a0:	00005517          	auipc	a0,0x5
    27a4:	83050513          	addi	a0,a0,-2000 # 6fd0 <malloc+0x11a8>
    27a8:	1c2030ef          	jal	596a <unlink>
    27ac:	03000a93          	li	s5,48
    name[0] = 'b';
    27b0:	06200d13          	li	s10,98
    name[1] = 'i';
    27b4:	06900c93          	li	s9,105
    name[2] = 'g';
    27b8:	06700c13          	li	s8,103
    unlink(name);
    27bc:	b7040b13          	addi	s6,s0,-1168
    int fd = open(name, O_CREATE | O_RDWR | O_TRUNC);
    27c0:	60200b93          	li	s7,1538
    27c4:	10c00d93          	li	s11,268
      if (write(fd, buf, BSIZE) != BSIZE) {
    27c8:	b9040a13          	addi	s4,s0,-1136
    27cc:	aa8d                	j	293e <diskfull+0x1de>
      printf("%s: could not create file %s\n", s, name);
    27ce:	b7040613          	addi	a2,s0,-1168
    27d2:	b6843583          	ld	a1,-1176(s0)
    27d6:	00005517          	auipc	a0,0x5
    27da:	80a50513          	addi	a0,a0,-2038 # 6fe0 <malloc+0x11b8>
    27de:	592030ef          	jal	5d70 <printf>
      break;
    27e2:	a039                	j	27f0 <diskfull+0x90>
        close(fd);
    27e4:	854e                	mv	a0,s3
    27e6:	15c030ef          	jal	5942 <close>
    close(fd);
    27ea:	854e                	mv	a0,s3
    27ec:	156030ef          	jal	5942 <close>
  for (int i = 0; i < nzz; i++) {
    27f0:	4481                	li	s1,0
    name[0] = 'z';
    27f2:	07a00993          	li	s3,122
    unlink(name);
    27f6:	b9040913          	addi	s2,s0,-1136
    int fd = open(name, O_CREATE | O_RDWR | O_TRUNC);
    27fa:	60200a13          	li	s4,1538
  for (int i = 0; i < nzz; i++) {
    27fe:	08000a93          	li	s5,128
    name[0] = 'z';
    2802:	b9340823          	sb	s3,-1136(s0)
    name[1] = 'z';
    2806:	b93408a3          	sb	s3,-1135(s0)
    name[2] = '0' + (i / 32);
    280a:	41f4d71b          	sraiw	a4,s1,0x1f
    280e:	01b7571b          	srliw	a4,a4,0x1b
    2812:	009707bb          	addw	a5,a4,s1
    2816:	4057d69b          	sraiw	a3,a5,0x5
    281a:	0306869b          	addiw	a3,a3,48
    281e:	b8d40923          	sb	a3,-1134(s0)
    name[3] = '0' + (i % 32);
    2822:	8bfd                	andi	a5,a5,31
    2824:	9f99                	subw	a5,a5,a4
    2826:	0307879b          	addiw	a5,a5,48
    282a:	b8f409a3          	sb	a5,-1133(s0)
    name[4] = '\0';
    282e:	b8040a23          	sb	zero,-1132(s0)
    unlink(name);
    2832:	854a                	mv	a0,s2
    2834:	136030ef          	jal	596a <unlink>
    int fd = open(name, O_CREATE | O_RDWR | O_TRUNC);
    2838:	85d2                	mv	a1,s4
    283a:	854a                	mv	a0,s2
    283c:	11e030ef          	jal	595a <open>
    if (fd < 0)
    2840:	00054763          	bltz	a0,284e <diskfull+0xee>
    close(fd);
    2844:	0fe030ef          	jal	5942 <close>
  for (int i = 0; i < nzz; i++) {
    2848:	2485                	addiw	s1,s1,1
    284a:	fb549ce3          	bne	s1,s5,2802 <diskfull+0xa2>
  if (mkdir("diskfulldir") == 0)
    284e:	00004517          	auipc	a0,0x4
    2852:	78250513          	addi	a0,a0,1922 # 6fd0 <malloc+0x11a8>
    2856:	12c030ef          	jal	5982 <mkdir>
    285a:	12050363          	beqz	a0,2980 <diskfull+0x220>
  unlink("diskfulldir");
    285e:	00004517          	auipc	a0,0x4
    2862:	77250513          	addi	a0,a0,1906 # 6fd0 <malloc+0x11a8>
    2866:	104030ef          	jal	596a <unlink>
  for (int i = 0; i < nzz; i++) {
    286a:	4481                	li	s1,0
    name[0] = 'z';
    286c:	07a00913          	li	s2,122
    unlink(name);
    2870:	b9040a13          	addi	s4,s0,-1136
  for (int i = 0; i < nzz; i++) {
    2874:	08000993          	li	s3,128
    name[0] = 'z';
    2878:	b9240823          	sb	s2,-1136(s0)
    name[1] = 'z';
    287c:	b92408a3          	sb	s2,-1135(s0)
    name[2] = '0' + (i / 32);
    2880:	41f4d71b          	sraiw	a4,s1,0x1f
    2884:	01b7571b          	srliw	a4,a4,0x1b
    2888:	009707bb          	addw	a5,a4,s1
    288c:	4057d69b          	sraiw	a3,a5,0x5
    2890:	0306869b          	addiw	a3,a3,48
    2894:	b8d40923          	sb	a3,-1134(s0)
    name[3] = '0' + (i % 32);
    2898:	8bfd                	andi	a5,a5,31
    289a:	9f99                	subw	a5,a5,a4
    289c:	0307879b          	addiw	a5,a5,48
    28a0:	b8f409a3          	sb	a5,-1133(s0)
    name[4] = '\0';
    28a4:	b8040a23          	sb	zero,-1132(s0)
    unlink(name);
    28a8:	8552                	mv	a0,s4
    28aa:	0c0030ef          	jal	596a <unlink>
  for (int i = 0; i < nzz; i++) {
    28ae:	2485                	addiw	s1,s1,1
    28b0:	fd3494e3          	bne	s1,s3,2878 <diskfull+0x118>
    28b4:	03000493          	li	s1,48
    name[0] = 'b';
    28b8:	06200b13          	li	s6,98
    name[1] = 'i';
    28bc:	06900a93          	li	s5,105
    name[2] = 'g';
    28c0:	06700a13          	li	s4,103
    unlink(name);
    28c4:	b9040993          	addi	s3,s0,-1136
  for (int i = 0; '0' + i < 0177; i++) {
    28c8:	07f00913          	li	s2,127
    name[0] = 'b';
    28cc:	b9640823          	sb	s6,-1136(s0)
    name[1] = 'i';
    28d0:	b95408a3          	sb	s5,-1135(s0)
    name[2] = 'g';
    28d4:	b9440923          	sb	s4,-1134(s0)
    name[3] = '0' + i;
    28d8:	b89409a3          	sb	s1,-1133(s0)
    name[4] = '\0';
    28dc:	b8040a23          	sb	zero,-1132(s0)
    unlink(name);
    28e0:	854e                	mv	a0,s3
    28e2:	088030ef          	jal	596a <unlink>
  for (int i = 0; '0' + i < 0177; i++) {
    28e6:	2485                	addiw	s1,s1,1
    28e8:	0ff4f493          	zext.b	s1,s1
    28ec:	ff2490e3          	bne	s1,s2,28cc <diskfull+0x16c>
}
    28f0:	49813083          	ld	ra,1176(sp)
    28f4:	49013403          	ld	s0,1168(sp)
    28f8:	48813483          	ld	s1,1160(sp)
    28fc:	48013903          	ld	s2,1152(sp)
    2900:	47813983          	ld	s3,1144(sp)
    2904:	47013a03          	ld	s4,1136(sp)
    2908:	46813a83          	ld	s5,1128(sp)
    290c:	46013b03          	ld	s6,1120(sp)
    2910:	45813b83          	ld	s7,1112(sp)
    2914:	45013c03          	ld	s8,1104(sp)
    2918:	44813c83          	ld	s9,1096(sp)
    291c:	44013d03          	ld	s10,1088(sp)
    2920:	43813d83          	ld	s11,1080(sp)
    2924:	4a010113          	addi	sp,sp,1184
    2928:	8082                	ret
    close(fd);
    292a:	854e                	mv	a0,s3
    292c:	016030ef          	jal	5942 <close>
  for (fi = 0; done == 0 && '0' + fi < 0177; fi++) {
    2930:	2a85                	addiw	s5,s5,1 # 3001 <subdir+0x477>
    2932:	0ffafa93          	zext.b	s5,s5
    2936:	07f00793          	li	a5,127
    293a:	eafa8be3          	beq	s5,a5,27f0 <diskfull+0x90>
    name[0] = 'b';
    293e:	b7a40823          	sb	s10,-1168(s0)
    name[1] = 'i';
    2942:	b79408a3          	sb	s9,-1167(s0)
    name[2] = 'g';
    2946:	b7840923          	sb	s8,-1166(s0)
    name[3] = '0' + fi;
    294a:	b75409a3          	sb	s5,-1165(s0)
    name[4] = '\0';
    294e:	b6040a23          	sb	zero,-1164(s0)
    unlink(name);
    2952:	855a                	mv	a0,s6
    2954:	016030ef          	jal	596a <unlink>
    int fd = open(name, O_CREATE | O_RDWR | O_TRUNC);
    2958:	85de                	mv	a1,s7
    295a:	855a                	mv	a0,s6
    295c:	7ff020ef          	jal	595a <open>
    2960:	89aa                	mv	s3,a0
    if (fd < 0) {
    2962:	e60546e3          	bltz	a0,27ce <diskfull+0x6e>
    2966:	84ee                	mv	s1,s11
      if (write(fd, buf, BSIZE) != BSIZE) {
    2968:	40000913          	li	s2,1024
    296c:	864a                	mv	a2,s2
    296e:	85d2                	mv	a1,s4
    2970:	854e                	mv	a0,s3
    2972:	7c9020ef          	jal	593a <write>
    2976:	e72517e3          	bne	a0,s2,27e4 <diskfull+0x84>
    for (int i = 0; i < MAXFILE; i++) {
    297a:	34fd                	addiw	s1,s1,-1
    297c:	f8e5                	bnez	s1,296c <diskfull+0x20c>
    297e:	b775                	j	292a <diskfull+0x1ca>
    printf("%s: mkdir(diskfulldir) unexpectedly succeeded!\n", s);
    2980:	b6843583          	ld	a1,-1176(s0)
    2984:	00004517          	auipc	a0,0x4
    2988:	67c50513          	addi	a0,a0,1660 # 7000 <malloc+0x11d8>
    298c:	3e4030ef          	jal	5d70 <printf>
    2990:	b5f9                	j	285e <diskfull+0xfe>

0000000000002992 <iputtest>:
{
    2992:	1101                	addi	sp,sp,-32
    2994:	ec06                	sd	ra,24(sp)
    2996:	e822                	sd	s0,16(sp)
    2998:	e426                	sd	s1,8(sp)
    299a:	1000                	addi	s0,sp,32
    299c:	84aa                	mv	s1,a0
  if (mkdir("iputdir") < 0) {
    299e:	00004517          	auipc	a0,0x4
    29a2:	69250513          	addi	a0,a0,1682 # 7030 <malloc+0x1208>
    29a6:	7dd020ef          	jal	5982 <mkdir>
    29aa:	02054f63          	bltz	a0,29e8 <iputtest+0x56>
  if (chdir("iputdir") < 0) {
    29ae:	00004517          	auipc	a0,0x4
    29b2:	68250513          	addi	a0,a0,1666 # 7030 <malloc+0x1208>
    29b6:	7d5020ef          	jal	598a <chdir>
    29ba:	04054163          	bltz	a0,29fc <iputtest+0x6a>
  if (unlink("../iputdir") < 0) {
    29be:	00004517          	auipc	a0,0x4
    29c2:	6b250513          	addi	a0,a0,1714 # 7070 <malloc+0x1248>
    29c6:	7a5020ef          	jal	596a <unlink>
    29ca:	04054363          	bltz	a0,2a10 <iputtest+0x7e>
  if (chdir("/") < 0) {
    29ce:	00004517          	auipc	a0,0x4
    29d2:	6d250513          	addi	a0,a0,1746 # 70a0 <malloc+0x1278>
    29d6:	7b5020ef          	jal	598a <chdir>
    29da:	04054563          	bltz	a0,2a24 <iputtest+0x92>
}
    29de:	60e2                	ld	ra,24(sp)
    29e0:	6442                	ld	s0,16(sp)
    29e2:	64a2                	ld	s1,8(sp)
    29e4:	6105                	addi	sp,sp,32
    29e6:	8082                	ret
    printf("%s: mkdir failed\n", s);
    29e8:	85a6                	mv	a1,s1
    29ea:	00004517          	auipc	a0,0x4
    29ee:	64e50513          	addi	a0,a0,1614 # 7038 <malloc+0x1210>
    29f2:	37e030ef          	jal	5d70 <printf>
    exit(1);
    29f6:	4505                	li	a0,1
    29f8:	723020ef          	jal	591a <exit>
    printf("%s: chdir iputdir failed\n", s);
    29fc:	85a6                	mv	a1,s1
    29fe:	00004517          	auipc	a0,0x4
    2a02:	65250513          	addi	a0,a0,1618 # 7050 <malloc+0x1228>
    2a06:	36a030ef          	jal	5d70 <printf>
    exit(1);
    2a0a:	4505                	li	a0,1
    2a0c:	70f020ef          	jal	591a <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    2a10:	85a6                	mv	a1,s1
    2a12:	00004517          	auipc	a0,0x4
    2a16:	66e50513          	addi	a0,a0,1646 # 7080 <malloc+0x1258>
    2a1a:	356030ef          	jal	5d70 <printf>
    exit(1);
    2a1e:	4505                	li	a0,1
    2a20:	6fb020ef          	jal	591a <exit>
    printf("%s: chdir / failed\n", s);
    2a24:	85a6                	mv	a1,s1
    2a26:	00004517          	auipc	a0,0x4
    2a2a:	68250513          	addi	a0,a0,1666 # 70a8 <malloc+0x1280>
    2a2e:	342030ef          	jal	5d70 <printf>
    exit(1);
    2a32:	4505                	li	a0,1
    2a34:	6e7020ef          	jal	591a <exit>

0000000000002a38 <exitiputtest>:
{
    2a38:	7179                	addi	sp,sp,-48
    2a3a:	f406                	sd	ra,40(sp)
    2a3c:	f022                	sd	s0,32(sp)
    2a3e:	ec26                	sd	s1,24(sp)
    2a40:	1800                	addi	s0,sp,48
    2a42:	84aa                	mv	s1,a0
  pid = fork();
    2a44:	6cf020ef          	jal	5912 <fork>
  if (pid < 0) {
    2a48:	02054e63          	bltz	a0,2a84 <exitiputtest+0x4c>
  if (pid == 0) {
    2a4c:	e541                	bnez	a0,2ad4 <exitiputtest+0x9c>
    if (mkdir("iputdir") < 0) {
    2a4e:	00004517          	auipc	a0,0x4
    2a52:	5e250513          	addi	a0,a0,1506 # 7030 <malloc+0x1208>
    2a56:	72d020ef          	jal	5982 <mkdir>
    2a5a:	02054f63          	bltz	a0,2a98 <exitiputtest+0x60>
    if (chdir("iputdir") < 0) {
    2a5e:	00004517          	auipc	a0,0x4
    2a62:	5d250513          	addi	a0,a0,1490 # 7030 <malloc+0x1208>
    2a66:	725020ef          	jal	598a <chdir>
    2a6a:	04054163          	bltz	a0,2aac <exitiputtest+0x74>
    if (unlink("../iputdir") < 0) {
    2a6e:	00004517          	auipc	a0,0x4
    2a72:	60250513          	addi	a0,a0,1538 # 7070 <malloc+0x1248>
    2a76:	6f5020ef          	jal	596a <unlink>
    2a7a:	04054363          	bltz	a0,2ac0 <exitiputtest+0x88>
    exit(0);
    2a7e:	4501                	li	a0,0
    2a80:	69b020ef          	jal	591a <exit>
    printf("%s: fork failed\n", s);
    2a84:	85a6                	mv	a1,s1
    2a86:	00004517          	auipc	a0,0x4
    2a8a:	d6250513          	addi	a0,a0,-670 # 67e8 <malloc+0x9c0>
    2a8e:	2e2030ef          	jal	5d70 <printf>
    exit(1);
    2a92:	4505                	li	a0,1
    2a94:	687020ef          	jal	591a <exit>
      printf("%s: mkdir failed\n", s);
    2a98:	85a6                	mv	a1,s1
    2a9a:	00004517          	auipc	a0,0x4
    2a9e:	59e50513          	addi	a0,a0,1438 # 7038 <malloc+0x1210>
    2aa2:	2ce030ef          	jal	5d70 <printf>
      exit(1);
    2aa6:	4505                	li	a0,1
    2aa8:	673020ef          	jal	591a <exit>
      printf("%s: child chdir failed\n", s);
    2aac:	85a6                	mv	a1,s1
    2aae:	00004517          	auipc	a0,0x4
    2ab2:	61250513          	addi	a0,a0,1554 # 70c0 <malloc+0x1298>
    2ab6:	2ba030ef          	jal	5d70 <printf>
      exit(1);
    2aba:	4505                	li	a0,1
    2abc:	65f020ef          	jal	591a <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2ac0:	85a6                	mv	a1,s1
    2ac2:	00004517          	auipc	a0,0x4
    2ac6:	5be50513          	addi	a0,a0,1470 # 7080 <malloc+0x1258>
    2aca:	2a6030ef          	jal	5d70 <printf>
      exit(1);
    2ace:	4505                	li	a0,1
    2ad0:	64b020ef          	jal	591a <exit>
  wait(&xstatus);
    2ad4:	fdc40513          	addi	a0,s0,-36
    2ad8:	64b020ef          	jal	5922 <wait>
  exit(xstatus);
    2adc:	fdc42503          	lw	a0,-36(s0)
    2ae0:	63b020ef          	jal	591a <exit>

0000000000002ae4 <dirtest>:
{
    2ae4:	1101                	addi	sp,sp,-32
    2ae6:	ec06                	sd	ra,24(sp)
    2ae8:	e822                	sd	s0,16(sp)
    2aea:	e426                	sd	s1,8(sp)
    2aec:	1000                	addi	s0,sp,32
    2aee:	84aa                	mv	s1,a0
  if (mkdir("dir0") < 0) {
    2af0:	00004517          	auipc	a0,0x4
    2af4:	5e850513          	addi	a0,a0,1512 # 70d8 <malloc+0x12b0>
    2af8:	68b020ef          	jal	5982 <mkdir>
    2afc:	02054f63          	bltz	a0,2b3a <dirtest+0x56>
  if (chdir("dir0") < 0) {
    2b00:	00004517          	auipc	a0,0x4
    2b04:	5d850513          	addi	a0,a0,1496 # 70d8 <malloc+0x12b0>
    2b08:	683020ef          	jal	598a <chdir>
    2b0c:	04054163          	bltz	a0,2b4e <dirtest+0x6a>
  if (chdir("..") < 0) {
    2b10:	00004517          	auipc	a0,0x4
    2b14:	5e850513          	addi	a0,a0,1512 # 70f8 <malloc+0x12d0>
    2b18:	673020ef          	jal	598a <chdir>
    2b1c:	04054363          	bltz	a0,2b62 <dirtest+0x7e>
  if (unlink("dir0") < 0) {
    2b20:	00004517          	auipc	a0,0x4
    2b24:	5b850513          	addi	a0,a0,1464 # 70d8 <malloc+0x12b0>
    2b28:	643020ef          	jal	596a <unlink>
    2b2c:	04054563          	bltz	a0,2b76 <dirtest+0x92>
}
    2b30:	60e2                	ld	ra,24(sp)
    2b32:	6442                	ld	s0,16(sp)
    2b34:	64a2                	ld	s1,8(sp)
    2b36:	6105                	addi	sp,sp,32
    2b38:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2b3a:	85a6                	mv	a1,s1
    2b3c:	00004517          	auipc	a0,0x4
    2b40:	4fc50513          	addi	a0,a0,1276 # 7038 <malloc+0x1210>
    2b44:	22c030ef          	jal	5d70 <printf>
    exit(1);
    2b48:	4505                	li	a0,1
    2b4a:	5d1020ef          	jal	591a <exit>
    printf("%s: chdir dir0 failed\n", s);
    2b4e:	85a6                	mv	a1,s1
    2b50:	00004517          	auipc	a0,0x4
    2b54:	59050513          	addi	a0,a0,1424 # 70e0 <malloc+0x12b8>
    2b58:	218030ef          	jal	5d70 <printf>
    exit(1);
    2b5c:	4505                	li	a0,1
    2b5e:	5bd020ef          	jal	591a <exit>
    printf("%s: chdir .. failed\n", s);
    2b62:	85a6                	mv	a1,s1
    2b64:	00004517          	auipc	a0,0x4
    2b68:	59c50513          	addi	a0,a0,1436 # 7100 <malloc+0x12d8>
    2b6c:	204030ef          	jal	5d70 <printf>
    exit(1);
    2b70:	4505                	li	a0,1
    2b72:	5a9020ef          	jal	591a <exit>
    printf("%s: unlink dir0 failed\n", s);
    2b76:	85a6                	mv	a1,s1
    2b78:	00004517          	auipc	a0,0x4
    2b7c:	5a050513          	addi	a0,a0,1440 # 7118 <malloc+0x12f0>
    2b80:	1f0030ef          	jal	5d70 <printf>
    exit(1);
    2b84:	4505                	li	a0,1
    2b86:	595020ef          	jal	591a <exit>

0000000000002b8a <subdir>:
{
    2b8a:	1101                	addi	sp,sp,-32
    2b8c:	ec06                	sd	ra,24(sp)
    2b8e:	e822                	sd	s0,16(sp)
    2b90:	e426                	sd	s1,8(sp)
    2b92:	e04a                	sd	s2,0(sp)
    2b94:	1000                	addi	s0,sp,32
    2b96:	892a                	mv	s2,a0
  unlink("ff");
    2b98:	00004517          	auipc	a0,0x4
    2b9c:	6c850513          	addi	a0,a0,1736 # 7260 <malloc+0x1438>
    2ba0:	5cb020ef          	jal	596a <unlink>
  if (mkdir("dd") != 0) {
    2ba4:	00004517          	auipc	a0,0x4
    2ba8:	58c50513          	addi	a0,a0,1420 # 7130 <malloc+0x1308>
    2bac:	5d7020ef          	jal	5982 <mkdir>
    2bb0:	2e051263          	bnez	a0,2e94 <subdir+0x30a>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    2bb4:	20200593          	li	a1,514
    2bb8:	00004517          	auipc	a0,0x4
    2bbc:	59850513          	addi	a0,a0,1432 # 7150 <malloc+0x1328>
    2bc0:	59b020ef          	jal	595a <open>
    2bc4:	84aa                	mv	s1,a0
  if (fd < 0) {
    2bc6:	2e054163          	bltz	a0,2ea8 <subdir+0x31e>
  write(fd, "ff", 2);
    2bca:	4609                	li	a2,2
    2bcc:	00004597          	auipc	a1,0x4
    2bd0:	69458593          	addi	a1,a1,1684 # 7260 <malloc+0x1438>
    2bd4:	567020ef          	jal	593a <write>
  close(fd);
    2bd8:	8526                	mv	a0,s1
    2bda:	569020ef          	jal	5942 <close>
  if (unlink("dd") >= 0) {
    2bde:	00004517          	auipc	a0,0x4
    2be2:	55250513          	addi	a0,a0,1362 # 7130 <malloc+0x1308>
    2be6:	585020ef          	jal	596a <unlink>
    2bea:	2c055963          	bgez	a0,2ebc <subdir+0x332>
  if (mkdir("/dd/dd") != 0) {
    2bee:	00004517          	auipc	a0,0x4
    2bf2:	5ba50513          	addi	a0,a0,1466 # 71a8 <malloc+0x1380>
    2bf6:	58d020ef          	jal	5982 <mkdir>
    2bfa:	2c051b63          	bnez	a0,2ed0 <subdir+0x346>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2bfe:	20200593          	li	a1,514
    2c02:	00004517          	auipc	a0,0x4
    2c06:	5ce50513          	addi	a0,a0,1486 # 71d0 <malloc+0x13a8>
    2c0a:	551020ef          	jal	595a <open>
    2c0e:	84aa                	mv	s1,a0
  if (fd < 0) {
    2c10:	2c054a63          	bltz	a0,2ee4 <subdir+0x35a>
  write(fd, "FF", 2);
    2c14:	4609                	li	a2,2
    2c16:	00004597          	auipc	a1,0x4
    2c1a:	5ea58593          	addi	a1,a1,1514 # 7200 <malloc+0x13d8>
    2c1e:	51d020ef          	jal	593a <write>
  close(fd);
    2c22:	8526                	mv	a0,s1
    2c24:	51f020ef          	jal	5942 <close>
  fd = open("dd/dd/../ff", 0);
    2c28:	4581                	li	a1,0
    2c2a:	00004517          	auipc	a0,0x4
    2c2e:	5de50513          	addi	a0,a0,1502 # 7208 <malloc+0x13e0>
    2c32:	529020ef          	jal	595a <open>
    2c36:	84aa                	mv	s1,a0
  if (fd < 0) {
    2c38:	2c054063          	bltz	a0,2ef8 <subdir+0x36e>
  cc = read(fd, buf, sizeof(buf));
    2c3c:	660d                	lui	a2,0x3
    2c3e:	0000c597          	auipc	a1,0xc
    2c42:	0ca58593          	addi	a1,a1,202 # ed08 <buf>
    2c46:	4ed020ef          	jal	5932 <read>
  if (cc != 2 || buf[0] != 'f') {
    2c4a:	4789                	li	a5,2
    2c4c:	2cf51063          	bne	a0,a5,2f0c <subdir+0x382>
    2c50:	0000c717          	auipc	a4,0xc
    2c54:	0b874703          	lbu	a4,184(a4) # ed08 <buf>
    2c58:	06600793          	li	a5,102
    2c5c:	2af71863          	bne	a4,a5,2f0c <subdir+0x382>
  close(fd);
    2c60:	8526                	mv	a0,s1
    2c62:	4e1020ef          	jal	5942 <close>
  if (link("dd/dd/ff", "dd/dd/ffff") != 0) {
    2c66:	00004597          	auipc	a1,0x4
    2c6a:	5f258593          	addi	a1,a1,1522 # 7258 <malloc+0x1430>
    2c6e:	00004517          	auipc	a0,0x4
    2c72:	56250513          	addi	a0,a0,1378 # 71d0 <malloc+0x13a8>
    2c76:	505020ef          	jal	597a <link>
    2c7a:	2a051363          	bnez	a0,2f20 <subdir+0x396>
  if (unlink("dd/dd/ff") != 0) {
    2c7e:	00004517          	auipc	a0,0x4
    2c82:	55250513          	addi	a0,a0,1362 # 71d0 <malloc+0x13a8>
    2c86:	4e5020ef          	jal	596a <unlink>
    2c8a:	2a051563          	bnez	a0,2f34 <subdir+0x3aa>
  if (open("dd/dd/ff", O_RDONLY) >= 0) {
    2c8e:	4581                	li	a1,0
    2c90:	00004517          	auipc	a0,0x4
    2c94:	54050513          	addi	a0,a0,1344 # 71d0 <malloc+0x13a8>
    2c98:	4c3020ef          	jal	595a <open>
    2c9c:	2a055663          	bgez	a0,2f48 <subdir+0x3be>
  if (chdir("dd") != 0) {
    2ca0:	00004517          	auipc	a0,0x4
    2ca4:	49050513          	addi	a0,a0,1168 # 7130 <malloc+0x1308>
    2ca8:	4e3020ef          	jal	598a <chdir>
    2cac:	2a051863          	bnez	a0,2f5c <subdir+0x3d2>
  if (chdir("dd/../../dd") != 0) {
    2cb0:	00004517          	auipc	a0,0x4
    2cb4:	64050513          	addi	a0,a0,1600 # 72f0 <malloc+0x14c8>
    2cb8:	4d3020ef          	jal	598a <chdir>
    2cbc:	2a051a63          	bnez	a0,2f70 <subdir+0x3e6>
  if (chdir("dd/../../../dd") != 0) {
    2cc0:	00004517          	auipc	a0,0x4
    2cc4:	66050513          	addi	a0,a0,1632 # 7320 <malloc+0x14f8>
    2cc8:	4c3020ef          	jal	598a <chdir>
    2ccc:	2a051c63          	bnez	a0,2f84 <subdir+0x3fa>
  if (chdir("./..") != 0) {
    2cd0:	00004517          	auipc	a0,0x4
    2cd4:	68850513          	addi	a0,a0,1672 # 7358 <malloc+0x1530>
    2cd8:	4b3020ef          	jal	598a <chdir>
    2cdc:	2a051e63          	bnez	a0,2f98 <subdir+0x40e>
  fd = open("dd/dd/ffff", 0);
    2ce0:	4581                	li	a1,0
    2ce2:	00004517          	auipc	a0,0x4
    2ce6:	57650513          	addi	a0,a0,1398 # 7258 <malloc+0x1430>
    2cea:	471020ef          	jal	595a <open>
    2cee:	84aa                	mv	s1,a0
  if (fd < 0) {
    2cf0:	2a054e63          	bltz	a0,2fac <subdir+0x422>
  if (read(fd, buf, sizeof(buf)) != 2) {
    2cf4:	660d                	lui	a2,0x3
    2cf6:	0000c597          	auipc	a1,0xc
    2cfa:	01258593          	addi	a1,a1,18 # ed08 <buf>
    2cfe:	435020ef          	jal	5932 <read>
    2d02:	4789                	li	a5,2
    2d04:	2af51e63          	bne	a0,a5,2fc0 <subdir+0x436>
  close(fd);
    2d08:	8526                	mv	a0,s1
    2d0a:	439020ef          	jal	5942 <close>
  if (open("dd/dd/ff", O_RDONLY) >= 0) {
    2d0e:	4581                	li	a1,0
    2d10:	00004517          	auipc	a0,0x4
    2d14:	4c050513          	addi	a0,a0,1216 # 71d0 <malloc+0x13a8>
    2d18:	443020ef          	jal	595a <open>
    2d1c:	2a055c63          	bgez	a0,2fd4 <subdir+0x44a>
  if (open("dd/ff/ff", O_CREATE | O_RDWR) >= 0) {
    2d20:	20200593          	li	a1,514
    2d24:	00004517          	auipc	a0,0x4
    2d28:	6c450513          	addi	a0,a0,1732 # 73e8 <malloc+0x15c0>
    2d2c:	42f020ef          	jal	595a <open>
    2d30:	2a055c63          	bgez	a0,2fe8 <subdir+0x45e>
  if (open("dd/xx/ff", O_CREATE | O_RDWR) >= 0) {
    2d34:	20200593          	li	a1,514
    2d38:	00004517          	auipc	a0,0x4
    2d3c:	6e050513          	addi	a0,a0,1760 # 7418 <malloc+0x15f0>
    2d40:	41b020ef          	jal	595a <open>
    2d44:	2a055c63          	bgez	a0,2ffc <subdir+0x472>
  if (open("dd", O_CREATE) >= 0) {
    2d48:	20000593          	li	a1,512
    2d4c:	00004517          	auipc	a0,0x4
    2d50:	3e450513          	addi	a0,a0,996 # 7130 <malloc+0x1308>
    2d54:	407020ef          	jal	595a <open>
    2d58:	2a055c63          	bgez	a0,3010 <subdir+0x486>
  if (open("dd", O_RDWR) >= 0) {
    2d5c:	4589                	li	a1,2
    2d5e:	00004517          	auipc	a0,0x4
    2d62:	3d250513          	addi	a0,a0,978 # 7130 <malloc+0x1308>
    2d66:	3f5020ef          	jal	595a <open>
    2d6a:	2a055d63          	bgez	a0,3024 <subdir+0x49a>
  if (open("dd", O_WRONLY) >= 0) {
    2d6e:	4585                	li	a1,1
    2d70:	00004517          	auipc	a0,0x4
    2d74:	3c050513          	addi	a0,a0,960 # 7130 <malloc+0x1308>
    2d78:	3e3020ef          	jal	595a <open>
    2d7c:	2a055e63          	bgez	a0,3038 <subdir+0x4ae>
  if (link("dd/ff/ff", "dd/dd/xx") == 0) {
    2d80:	00004597          	auipc	a1,0x4
    2d84:	72858593          	addi	a1,a1,1832 # 74a8 <malloc+0x1680>
    2d88:	00004517          	auipc	a0,0x4
    2d8c:	66050513          	addi	a0,a0,1632 # 73e8 <malloc+0x15c0>
    2d90:	3eb020ef          	jal	597a <link>
    2d94:	2a050c63          	beqz	a0,304c <subdir+0x4c2>
  if (link("dd/xx/ff", "dd/dd/xx") == 0) {
    2d98:	00004597          	auipc	a1,0x4
    2d9c:	71058593          	addi	a1,a1,1808 # 74a8 <malloc+0x1680>
    2da0:	00004517          	auipc	a0,0x4
    2da4:	67850513          	addi	a0,a0,1656 # 7418 <malloc+0x15f0>
    2da8:	3d3020ef          	jal	597a <link>
    2dac:	2a050a63          	beqz	a0,3060 <subdir+0x4d6>
  if (link("dd/ff", "dd/dd/ffff") == 0) {
    2db0:	00004597          	auipc	a1,0x4
    2db4:	4a858593          	addi	a1,a1,1192 # 7258 <malloc+0x1430>
    2db8:	00004517          	auipc	a0,0x4
    2dbc:	39850513          	addi	a0,a0,920 # 7150 <malloc+0x1328>
    2dc0:	3bb020ef          	jal	597a <link>
    2dc4:	2a050863          	beqz	a0,3074 <subdir+0x4ea>
  if (mkdir("dd/ff/ff") == 0) {
    2dc8:	00004517          	auipc	a0,0x4
    2dcc:	62050513          	addi	a0,a0,1568 # 73e8 <malloc+0x15c0>
    2dd0:	3b3020ef          	jal	5982 <mkdir>
    2dd4:	2a050a63          	beqz	a0,3088 <subdir+0x4fe>
  if (mkdir("dd/xx/ff") == 0) {
    2dd8:	00004517          	auipc	a0,0x4
    2ddc:	64050513          	addi	a0,a0,1600 # 7418 <malloc+0x15f0>
    2de0:	3a3020ef          	jal	5982 <mkdir>
    2de4:	2a050c63          	beqz	a0,309c <subdir+0x512>
  if (mkdir("dd/dd/ffff") == 0) {
    2de8:	00004517          	auipc	a0,0x4
    2dec:	47050513          	addi	a0,a0,1136 # 7258 <malloc+0x1430>
    2df0:	393020ef          	jal	5982 <mkdir>
    2df4:	2a050e63          	beqz	a0,30b0 <subdir+0x526>
  if (unlink("dd/xx/ff") == 0) {
    2df8:	00004517          	auipc	a0,0x4
    2dfc:	62050513          	addi	a0,a0,1568 # 7418 <malloc+0x15f0>
    2e00:	36b020ef          	jal	596a <unlink>
    2e04:	2c050063          	beqz	a0,30c4 <subdir+0x53a>
  if (unlink("dd/ff/ff") == 0) {
    2e08:	00004517          	auipc	a0,0x4
    2e0c:	5e050513          	addi	a0,a0,1504 # 73e8 <malloc+0x15c0>
    2e10:	35b020ef          	jal	596a <unlink>
    2e14:	2c050263          	beqz	a0,30d8 <subdir+0x54e>
  if (chdir("dd/ff") == 0) {
    2e18:	00004517          	auipc	a0,0x4
    2e1c:	33850513          	addi	a0,a0,824 # 7150 <malloc+0x1328>
    2e20:	36b020ef          	jal	598a <chdir>
    2e24:	2c050463          	beqz	a0,30ec <subdir+0x562>
  if (chdir("dd/xx") == 0) {
    2e28:	00004517          	auipc	a0,0x4
    2e2c:	7d050513          	addi	a0,a0,2000 # 75f8 <malloc+0x17d0>
    2e30:	35b020ef          	jal	598a <chdir>
    2e34:	2c050663          	beqz	a0,3100 <subdir+0x576>
  if (unlink("dd/dd/ffff") != 0) {
    2e38:	00004517          	auipc	a0,0x4
    2e3c:	42050513          	addi	a0,a0,1056 # 7258 <malloc+0x1430>
    2e40:	32b020ef          	jal	596a <unlink>
    2e44:	2c051863          	bnez	a0,3114 <subdir+0x58a>
  if (unlink("dd/ff") != 0) {
    2e48:	00004517          	auipc	a0,0x4
    2e4c:	30850513          	addi	a0,a0,776 # 7150 <malloc+0x1328>
    2e50:	31b020ef          	jal	596a <unlink>
    2e54:	2c051a63          	bnez	a0,3128 <subdir+0x59e>
  if (unlink("dd") == 0) {
    2e58:	00004517          	auipc	a0,0x4
    2e5c:	2d850513          	addi	a0,a0,728 # 7130 <malloc+0x1308>
    2e60:	30b020ef          	jal	596a <unlink>
    2e64:	2c050c63          	beqz	a0,313c <subdir+0x5b2>
  if (unlink("dd/dd") < 0) {
    2e68:	00005517          	auipc	a0,0x5
    2e6c:	80050513          	addi	a0,a0,-2048 # 7668 <malloc+0x1840>
    2e70:	2fb020ef          	jal	596a <unlink>
    2e74:	2c054e63          	bltz	a0,3150 <subdir+0x5c6>
  if (unlink("dd") < 0) {
    2e78:	00004517          	auipc	a0,0x4
    2e7c:	2b850513          	addi	a0,a0,696 # 7130 <malloc+0x1308>
    2e80:	2eb020ef          	jal	596a <unlink>
    2e84:	2e054063          	bltz	a0,3164 <subdir+0x5da>
}
    2e88:	60e2                	ld	ra,24(sp)
    2e8a:	6442                	ld	s0,16(sp)
    2e8c:	64a2                	ld	s1,8(sp)
    2e8e:	6902                	ld	s2,0(sp)
    2e90:	6105                	addi	sp,sp,32
    2e92:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    2e94:	85ca                	mv	a1,s2
    2e96:	00004517          	auipc	a0,0x4
    2e9a:	2a250513          	addi	a0,a0,674 # 7138 <malloc+0x1310>
    2e9e:	6d3020ef          	jal	5d70 <printf>
    exit(1);
    2ea2:	4505                	li	a0,1
    2ea4:	277020ef          	jal	591a <exit>
    printf("%s: create dd/ff failed\n", s);
    2ea8:	85ca                	mv	a1,s2
    2eaa:	00004517          	auipc	a0,0x4
    2eae:	2ae50513          	addi	a0,a0,686 # 7158 <malloc+0x1330>
    2eb2:	6bf020ef          	jal	5d70 <printf>
    exit(1);
    2eb6:	4505                	li	a0,1
    2eb8:	263020ef          	jal	591a <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    2ebc:	85ca                	mv	a1,s2
    2ebe:	00004517          	auipc	a0,0x4
    2ec2:	2ba50513          	addi	a0,a0,698 # 7178 <malloc+0x1350>
    2ec6:	6ab020ef          	jal	5d70 <printf>
    exit(1);
    2eca:	4505                	li	a0,1
    2ecc:	24f020ef          	jal	591a <exit>
    printf("%s: subdir mkdir dd/dd failed\n", s);
    2ed0:	85ca                	mv	a1,s2
    2ed2:	00004517          	auipc	a0,0x4
    2ed6:	2de50513          	addi	a0,a0,734 # 71b0 <malloc+0x1388>
    2eda:	697020ef          	jal	5d70 <printf>
    exit(1);
    2ede:	4505                	li	a0,1
    2ee0:	23b020ef          	jal	591a <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    2ee4:	85ca                	mv	a1,s2
    2ee6:	00004517          	auipc	a0,0x4
    2eea:	2fa50513          	addi	a0,a0,762 # 71e0 <malloc+0x13b8>
    2eee:	683020ef          	jal	5d70 <printf>
    exit(1);
    2ef2:	4505                	li	a0,1
    2ef4:	227020ef          	jal	591a <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    2ef8:	85ca                	mv	a1,s2
    2efa:	00004517          	auipc	a0,0x4
    2efe:	31e50513          	addi	a0,a0,798 # 7218 <malloc+0x13f0>
    2f02:	66f020ef          	jal	5d70 <printf>
    exit(1);
    2f06:	4505                	li	a0,1
    2f08:	213020ef          	jal	591a <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    2f0c:	85ca                	mv	a1,s2
    2f0e:	00004517          	auipc	a0,0x4
    2f12:	32a50513          	addi	a0,a0,810 # 7238 <malloc+0x1410>
    2f16:	65b020ef          	jal	5d70 <printf>
    exit(1);
    2f1a:	4505                	li	a0,1
    2f1c:	1ff020ef          	jal	591a <exit>
    printf("%s: link dd/dd/ff dd/dd/ffff failed\n", s);
    2f20:	85ca                	mv	a1,s2
    2f22:	00004517          	auipc	a0,0x4
    2f26:	34650513          	addi	a0,a0,838 # 7268 <malloc+0x1440>
    2f2a:	647020ef          	jal	5d70 <printf>
    exit(1);
    2f2e:	4505                	li	a0,1
    2f30:	1eb020ef          	jal	591a <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    2f34:	85ca                	mv	a1,s2
    2f36:	00004517          	auipc	a0,0x4
    2f3a:	35a50513          	addi	a0,a0,858 # 7290 <malloc+0x1468>
    2f3e:	633020ef          	jal	5d70 <printf>
    exit(1);
    2f42:	4505                	li	a0,1
    2f44:	1d7020ef          	jal	591a <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    2f48:	85ca                	mv	a1,s2
    2f4a:	00004517          	auipc	a0,0x4
    2f4e:	36650513          	addi	a0,a0,870 # 72b0 <malloc+0x1488>
    2f52:	61f020ef          	jal	5d70 <printf>
    exit(1);
    2f56:	4505                	li	a0,1
    2f58:	1c3020ef          	jal	591a <exit>
    printf("%s: chdir dd failed\n", s);
    2f5c:	85ca                	mv	a1,s2
    2f5e:	00004517          	auipc	a0,0x4
    2f62:	37a50513          	addi	a0,a0,890 # 72d8 <malloc+0x14b0>
    2f66:	60b020ef          	jal	5d70 <printf>
    exit(1);
    2f6a:	4505                	li	a0,1
    2f6c:	1af020ef          	jal	591a <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    2f70:	85ca                	mv	a1,s2
    2f72:	00004517          	auipc	a0,0x4
    2f76:	38e50513          	addi	a0,a0,910 # 7300 <malloc+0x14d8>
    2f7a:	5f7020ef          	jal	5d70 <printf>
    exit(1);
    2f7e:	4505                	li	a0,1
    2f80:	19b020ef          	jal	591a <exit>
    printf("%s: chdir dd/../../../dd failed\n", s);
    2f84:	85ca                	mv	a1,s2
    2f86:	00004517          	auipc	a0,0x4
    2f8a:	3aa50513          	addi	a0,a0,938 # 7330 <malloc+0x1508>
    2f8e:	5e3020ef          	jal	5d70 <printf>
    exit(1);
    2f92:	4505                	li	a0,1
    2f94:	187020ef          	jal	591a <exit>
    printf("%s: chdir ./.. failed\n", s);
    2f98:	85ca                	mv	a1,s2
    2f9a:	00004517          	auipc	a0,0x4
    2f9e:	3c650513          	addi	a0,a0,966 # 7360 <malloc+0x1538>
    2fa2:	5cf020ef          	jal	5d70 <printf>
    exit(1);
    2fa6:	4505                	li	a0,1
    2fa8:	173020ef          	jal	591a <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    2fac:	85ca                	mv	a1,s2
    2fae:	00004517          	auipc	a0,0x4
    2fb2:	3ca50513          	addi	a0,a0,970 # 7378 <malloc+0x1550>
    2fb6:	5bb020ef          	jal	5d70 <printf>
    exit(1);
    2fba:	4505                	li	a0,1
    2fbc:	15f020ef          	jal	591a <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    2fc0:	85ca                	mv	a1,s2
    2fc2:	00004517          	auipc	a0,0x4
    2fc6:	3d650513          	addi	a0,a0,982 # 7398 <malloc+0x1570>
    2fca:	5a7020ef          	jal	5d70 <printf>
    exit(1);
    2fce:	4505                	li	a0,1
    2fd0:	14b020ef          	jal	591a <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    2fd4:	85ca                	mv	a1,s2
    2fd6:	00004517          	auipc	a0,0x4
    2fda:	3e250513          	addi	a0,a0,994 # 73b8 <malloc+0x1590>
    2fde:	593020ef          	jal	5d70 <printf>
    exit(1);
    2fe2:	4505                	li	a0,1
    2fe4:	137020ef          	jal	591a <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    2fe8:	85ca                	mv	a1,s2
    2fea:	00004517          	auipc	a0,0x4
    2fee:	40e50513          	addi	a0,a0,1038 # 73f8 <malloc+0x15d0>
    2ff2:	57f020ef          	jal	5d70 <printf>
    exit(1);
    2ff6:	4505                	li	a0,1
    2ff8:	123020ef          	jal	591a <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    2ffc:	85ca                	mv	a1,s2
    2ffe:	00004517          	auipc	a0,0x4
    3002:	42a50513          	addi	a0,a0,1066 # 7428 <malloc+0x1600>
    3006:	56b020ef          	jal	5d70 <printf>
    exit(1);
    300a:	4505                	li	a0,1
    300c:	10f020ef          	jal	591a <exit>
    printf("%s: create dd succeeded!\n", s);
    3010:	85ca                	mv	a1,s2
    3012:	00004517          	auipc	a0,0x4
    3016:	43650513          	addi	a0,a0,1078 # 7448 <malloc+0x1620>
    301a:	557020ef          	jal	5d70 <printf>
    exit(1);
    301e:	4505                	li	a0,1
    3020:	0fb020ef          	jal	591a <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    3024:	85ca                	mv	a1,s2
    3026:	00004517          	auipc	a0,0x4
    302a:	44250513          	addi	a0,a0,1090 # 7468 <malloc+0x1640>
    302e:	543020ef          	jal	5d70 <printf>
    exit(1);
    3032:	4505                	li	a0,1
    3034:	0e7020ef          	jal	591a <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3038:	85ca                	mv	a1,s2
    303a:	00004517          	auipc	a0,0x4
    303e:	44e50513          	addi	a0,a0,1102 # 7488 <malloc+0x1660>
    3042:	52f020ef          	jal	5d70 <printf>
    exit(1);
    3046:	4505                	li	a0,1
    3048:	0d3020ef          	jal	591a <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    304c:	85ca                	mv	a1,s2
    304e:	00004517          	auipc	a0,0x4
    3052:	46a50513          	addi	a0,a0,1130 # 74b8 <malloc+0x1690>
    3056:	51b020ef          	jal	5d70 <printf>
    exit(1);
    305a:	4505                	li	a0,1
    305c:	0bf020ef          	jal	591a <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3060:	85ca                	mv	a1,s2
    3062:	00004517          	auipc	a0,0x4
    3066:	47e50513          	addi	a0,a0,1150 # 74e0 <malloc+0x16b8>
    306a:	507020ef          	jal	5d70 <printf>
    exit(1);
    306e:	4505                	li	a0,1
    3070:	0ab020ef          	jal	591a <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    3074:	85ca                	mv	a1,s2
    3076:	00004517          	auipc	a0,0x4
    307a:	49250513          	addi	a0,a0,1170 # 7508 <malloc+0x16e0>
    307e:	4f3020ef          	jal	5d70 <printf>
    exit(1);
    3082:	4505                	li	a0,1
    3084:	097020ef          	jal	591a <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    3088:	85ca                	mv	a1,s2
    308a:	00004517          	auipc	a0,0x4
    308e:	4a650513          	addi	a0,a0,1190 # 7530 <malloc+0x1708>
    3092:	4df020ef          	jal	5d70 <printf>
    exit(1);
    3096:	4505                	li	a0,1
    3098:	083020ef          	jal	591a <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    309c:	85ca                	mv	a1,s2
    309e:	00004517          	auipc	a0,0x4
    30a2:	4b250513          	addi	a0,a0,1202 # 7550 <malloc+0x1728>
    30a6:	4cb020ef          	jal	5d70 <printf>
    exit(1);
    30aa:	4505                	li	a0,1
    30ac:	06f020ef          	jal	591a <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    30b0:	85ca                	mv	a1,s2
    30b2:	00004517          	auipc	a0,0x4
    30b6:	4be50513          	addi	a0,a0,1214 # 7570 <malloc+0x1748>
    30ba:	4b7020ef          	jal	5d70 <printf>
    exit(1);
    30be:	4505                	li	a0,1
    30c0:	05b020ef          	jal	591a <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    30c4:	85ca                	mv	a1,s2
    30c6:	00004517          	auipc	a0,0x4
    30ca:	4d250513          	addi	a0,a0,1234 # 7598 <malloc+0x1770>
    30ce:	4a3020ef          	jal	5d70 <printf>
    exit(1);
    30d2:	4505                	li	a0,1
    30d4:	047020ef          	jal	591a <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    30d8:	85ca                	mv	a1,s2
    30da:	00004517          	auipc	a0,0x4
    30de:	4de50513          	addi	a0,a0,1246 # 75b8 <malloc+0x1790>
    30e2:	48f020ef          	jal	5d70 <printf>
    exit(1);
    30e6:	4505                	li	a0,1
    30e8:	033020ef          	jal	591a <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    30ec:	85ca                	mv	a1,s2
    30ee:	00004517          	auipc	a0,0x4
    30f2:	4ea50513          	addi	a0,a0,1258 # 75d8 <malloc+0x17b0>
    30f6:	47b020ef          	jal	5d70 <printf>
    exit(1);
    30fa:	4505                	li	a0,1
    30fc:	01f020ef          	jal	591a <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3100:	85ca                	mv	a1,s2
    3102:	00004517          	auipc	a0,0x4
    3106:	4fe50513          	addi	a0,a0,1278 # 7600 <malloc+0x17d8>
    310a:	467020ef          	jal	5d70 <printf>
    exit(1);
    310e:	4505                	li	a0,1
    3110:	00b020ef          	jal	591a <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3114:	85ca                	mv	a1,s2
    3116:	00004517          	auipc	a0,0x4
    311a:	17a50513          	addi	a0,a0,378 # 7290 <malloc+0x1468>
    311e:	453020ef          	jal	5d70 <printf>
    exit(1);
    3122:	4505                	li	a0,1
    3124:	7f6020ef          	jal	591a <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3128:	85ca                	mv	a1,s2
    312a:	00004517          	auipc	a0,0x4
    312e:	4f650513          	addi	a0,a0,1270 # 7620 <malloc+0x17f8>
    3132:	43f020ef          	jal	5d70 <printf>
    exit(1);
    3136:	4505                	li	a0,1
    3138:	7e2020ef          	jal	591a <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    313c:	85ca                	mv	a1,s2
    313e:	00004517          	auipc	a0,0x4
    3142:	50250513          	addi	a0,a0,1282 # 7640 <malloc+0x1818>
    3146:	42b020ef          	jal	5d70 <printf>
    exit(1);
    314a:	4505                	li	a0,1
    314c:	7ce020ef          	jal	591a <exit>
    printf("%s: unlink dd/dd failed\n", s);
    3150:	85ca                	mv	a1,s2
    3152:	00004517          	auipc	a0,0x4
    3156:	51e50513          	addi	a0,a0,1310 # 7670 <malloc+0x1848>
    315a:	417020ef          	jal	5d70 <printf>
    exit(1);
    315e:	4505                	li	a0,1
    3160:	7ba020ef          	jal	591a <exit>
    printf("%s: unlink dd failed\n", s);
    3164:	85ca                	mv	a1,s2
    3166:	00004517          	auipc	a0,0x4
    316a:	52a50513          	addi	a0,a0,1322 # 7690 <malloc+0x1868>
    316e:	403020ef          	jal	5d70 <printf>
    exit(1);
    3172:	4505                	li	a0,1
    3174:	7a6020ef          	jal	591a <exit>

0000000000003178 <rmdot>:
{
    3178:	1101                	addi	sp,sp,-32
    317a:	ec06                	sd	ra,24(sp)
    317c:	e822                	sd	s0,16(sp)
    317e:	e426                	sd	s1,8(sp)
    3180:	1000                	addi	s0,sp,32
    3182:	84aa                	mv	s1,a0
  if (mkdir("dots") != 0) {
    3184:	00004517          	auipc	a0,0x4
    3188:	52450513          	addi	a0,a0,1316 # 76a8 <malloc+0x1880>
    318c:	7f6020ef          	jal	5982 <mkdir>
    3190:	e53d                	bnez	a0,31fe <rmdot+0x86>
  if (chdir("dots") != 0) {
    3192:	00004517          	auipc	a0,0x4
    3196:	51650513          	addi	a0,a0,1302 # 76a8 <malloc+0x1880>
    319a:	7f0020ef          	jal	598a <chdir>
    319e:	e935                	bnez	a0,3212 <rmdot+0x9a>
  if (unlink(".") == 0) {
    31a0:	00003517          	auipc	a0,0x3
    31a4:	4a050513          	addi	a0,a0,1184 # 6640 <malloc+0x818>
    31a8:	7c2020ef          	jal	596a <unlink>
    31ac:	cd2d                	beqz	a0,3226 <rmdot+0xae>
  if (unlink("..") == 0) {
    31ae:	00004517          	auipc	a0,0x4
    31b2:	f4a50513          	addi	a0,a0,-182 # 70f8 <malloc+0x12d0>
    31b6:	7b4020ef          	jal	596a <unlink>
    31ba:	c141                	beqz	a0,323a <rmdot+0xc2>
  if (chdir("/") != 0) {
    31bc:	00004517          	auipc	a0,0x4
    31c0:	ee450513          	addi	a0,a0,-284 # 70a0 <malloc+0x1278>
    31c4:	7c6020ef          	jal	598a <chdir>
    31c8:	e159                	bnez	a0,324e <rmdot+0xd6>
  if (unlink("dots/.") == 0) {
    31ca:	00004517          	auipc	a0,0x4
    31ce:	54650513          	addi	a0,a0,1350 # 7710 <malloc+0x18e8>
    31d2:	798020ef          	jal	596a <unlink>
    31d6:	c551                	beqz	a0,3262 <rmdot+0xea>
  if (unlink("dots/..") == 0) {
    31d8:	00004517          	auipc	a0,0x4
    31dc:	56050513          	addi	a0,a0,1376 # 7738 <malloc+0x1910>
    31e0:	78a020ef          	jal	596a <unlink>
    31e4:	c949                	beqz	a0,3276 <rmdot+0xfe>
  if (unlink("dots") != 0) {
    31e6:	00004517          	auipc	a0,0x4
    31ea:	4c250513          	addi	a0,a0,1218 # 76a8 <malloc+0x1880>
    31ee:	77c020ef          	jal	596a <unlink>
    31f2:	ed41                	bnez	a0,328a <rmdot+0x112>
}
    31f4:	60e2                	ld	ra,24(sp)
    31f6:	6442                	ld	s0,16(sp)
    31f8:	64a2                	ld	s1,8(sp)
    31fa:	6105                	addi	sp,sp,32
    31fc:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    31fe:	85a6                	mv	a1,s1
    3200:	00004517          	auipc	a0,0x4
    3204:	4b050513          	addi	a0,a0,1200 # 76b0 <malloc+0x1888>
    3208:	369020ef          	jal	5d70 <printf>
    exit(1);
    320c:	4505                	li	a0,1
    320e:	70c020ef          	jal	591a <exit>
    printf("%s: chdir dots failed\n", s);
    3212:	85a6                	mv	a1,s1
    3214:	00004517          	auipc	a0,0x4
    3218:	4b450513          	addi	a0,a0,1204 # 76c8 <malloc+0x18a0>
    321c:	355020ef          	jal	5d70 <printf>
    exit(1);
    3220:	4505                	li	a0,1
    3222:	6f8020ef          	jal	591a <exit>
    printf("%s: rm . worked!\n", s);
    3226:	85a6                	mv	a1,s1
    3228:	00004517          	auipc	a0,0x4
    322c:	4b850513          	addi	a0,a0,1208 # 76e0 <malloc+0x18b8>
    3230:	341020ef          	jal	5d70 <printf>
    exit(1);
    3234:	4505                	li	a0,1
    3236:	6e4020ef          	jal	591a <exit>
    printf("%s: rm .. worked!\n", s);
    323a:	85a6                	mv	a1,s1
    323c:	00004517          	auipc	a0,0x4
    3240:	4bc50513          	addi	a0,a0,1212 # 76f8 <malloc+0x18d0>
    3244:	32d020ef          	jal	5d70 <printf>
    exit(1);
    3248:	4505                	li	a0,1
    324a:	6d0020ef          	jal	591a <exit>
    printf("%s: chdir / failed\n", s);
    324e:	85a6                	mv	a1,s1
    3250:	00004517          	auipc	a0,0x4
    3254:	e5850513          	addi	a0,a0,-424 # 70a8 <malloc+0x1280>
    3258:	319020ef          	jal	5d70 <printf>
    exit(1);
    325c:	4505                	li	a0,1
    325e:	6bc020ef          	jal	591a <exit>
    printf("%s: unlink dots/. worked!\n", s);
    3262:	85a6                	mv	a1,s1
    3264:	00004517          	auipc	a0,0x4
    3268:	4b450513          	addi	a0,a0,1204 # 7718 <malloc+0x18f0>
    326c:	305020ef          	jal	5d70 <printf>
    exit(1);
    3270:	4505                	li	a0,1
    3272:	6a8020ef          	jal	591a <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    3276:	85a6                	mv	a1,s1
    3278:	00004517          	auipc	a0,0x4
    327c:	4c850513          	addi	a0,a0,1224 # 7740 <malloc+0x1918>
    3280:	2f1020ef          	jal	5d70 <printf>
    exit(1);
    3284:	4505                	li	a0,1
    3286:	694020ef          	jal	591a <exit>
    printf("%s: unlink dots failed!\n", s);
    328a:	85a6                	mv	a1,s1
    328c:	00004517          	auipc	a0,0x4
    3290:	4d450513          	addi	a0,a0,1236 # 7760 <malloc+0x1938>
    3294:	2dd020ef          	jal	5d70 <printf>
    exit(1);
    3298:	4505                	li	a0,1
    329a:	680020ef          	jal	591a <exit>

000000000000329e <dirfile>:
{
    329e:	1101                	addi	sp,sp,-32
    32a0:	ec06                	sd	ra,24(sp)
    32a2:	e822                	sd	s0,16(sp)
    32a4:	e426                	sd	s1,8(sp)
    32a6:	e04a                	sd	s2,0(sp)
    32a8:	1000                	addi	s0,sp,32
    32aa:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    32ac:	20000593          	li	a1,512
    32b0:	00004517          	auipc	a0,0x4
    32b4:	4d050513          	addi	a0,a0,1232 # 7780 <malloc+0x1958>
    32b8:	6a2020ef          	jal	595a <open>
  if (fd < 0) {
    32bc:	0c054563          	bltz	a0,3386 <dirfile+0xe8>
  close(fd);
    32c0:	682020ef          	jal	5942 <close>
  if (chdir("dirfile") == 0) {
    32c4:	00004517          	auipc	a0,0x4
    32c8:	4bc50513          	addi	a0,a0,1212 # 7780 <malloc+0x1958>
    32cc:	6be020ef          	jal	598a <chdir>
    32d0:	c569                	beqz	a0,339a <dirfile+0xfc>
  fd = open("dirfile/xx", 0);
    32d2:	4581                	li	a1,0
    32d4:	00004517          	auipc	a0,0x4
    32d8:	4f450513          	addi	a0,a0,1268 # 77c8 <malloc+0x19a0>
    32dc:	67e020ef          	jal	595a <open>
  if (fd >= 0) {
    32e0:	0c055763          	bgez	a0,33ae <dirfile+0x110>
  fd = open("dirfile/xx", O_CREATE);
    32e4:	20000593          	li	a1,512
    32e8:	00004517          	auipc	a0,0x4
    32ec:	4e050513          	addi	a0,a0,1248 # 77c8 <malloc+0x19a0>
    32f0:	66a020ef          	jal	595a <open>
  if (fd >= 0) {
    32f4:	0c055763          	bgez	a0,33c2 <dirfile+0x124>
  if (mkdir("dirfile/xx") == 0) {
    32f8:	00004517          	auipc	a0,0x4
    32fc:	4d050513          	addi	a0,a0,1232 # 77c8 <malloc+0x19a0>
    3300:	682020ef          	jal	5982 <mkdir>
    3304:	0c050963          	beqz	a0,33d6 <dirfile+0x138>
  if (unlink("dirfile/xx") == 0) {
    3308:	00004517          	auipc	a0,0x4
    330c:	4c050513          	addi	a0,a0,1216 # 77c8 <malloc+0x19a0>
    3310:	65a020ef          	jal	596a <unlink>
    3314:	0c050b63          	beqz	a0,33ea <dirfile+0x14c>
  if (link("README", "dirfile/xx") == 0) {
    3318:	00004597          	auipc	a1,0x4
    331c:	4b058593          	addi	a1,a1,1200 # 77c8 <malloc+0x19a0>
    3320:	00003517          	auipc	a0,0x3
    3324:	e1050513          	addi	a0,a0,-496 # 6130 <malloc+0x308>
    3328:	652020ef          	jal	597a <link>
    332c:	0c050963          	beqz	a0,33fe <dirfile+0x160>
  if (unlink("dirfile") != 0) {
    3330:	00004517          	auipc	a0,0x4
    3334:	45050513          	addi	a0,a0,1104 # 7780 <malloc+0x1958>
    3338:	632020ef          	jal	596a <unlink>
    333c:	0c051b63          	bnez	a0,3412 <dirfile+0x174>
  fd = open(".", O_RDWR);
    3340:	4589                	li	a1,2
    3342:	00003517          	auipc	a0,0x3
    3346:	2fe50513          	addi	a0,a0,766 # 6640 <malloc+0x818>
    334a:	610020ef          	jal	595a <open>
  if (fd >= 0) {
    334e:	0c055c63          	bgez	a0,3426 <dirfile+0x188>
  fd = open(".", 0);
    3352:	4581                	li	a1,0
    3354:	00003517          	auipc	a0,0x3
    3358:	2ec50513          	addi	a0,a0,748 # 6640 <malloc+0x818>
    335c:	5fe020ef          	jal	595a <open>
    3360:	84aa                	mv	s1,a0
  if (write(fd, "x", 1) > 0) {
    3362:	4605                	li	a2,1
    3364:	00003597          	auipc	a1,0x3
    3368:	c6458593          	addi	a1,a1,-924 # 5fc8 <malloc+0x1a0>
    336c:	5ce020ef          	jal	593a <write>
    3370:	0ca04563          	bgtz	a0,343a <dirfile+0x19c>
  close(fd);
    3374:	8526                	mv	a0,s1
    3376:	5cc020ef          	jal	5942 <close>
}
    337a:	60e2                	ld	ra,24(sp)
    337c:	6442                	ld	s0,16(sp)
    337e:	64a2                	ld	s1,8(sp)
    3380:	6902                	ld	s2,0(sp)
    3382:	6105                	addi	sp,sp,32
    3384:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    3386:	85ca                	mv	a1,s2
    3388:	00004517          	auipc	a0,0x4
    338c:	40050513          	addi	a0,a0,1024 # 7788 <malloc+0x1960>
    3390:	1e1020ef          	jal	5d70 <printf>
    exit(1);
    3394:	4505                	li	a0,1
    3396:	584020ef          	jal	591a <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    339a:	85ca                	mv	a1,s2
    339c:	00004517          	auipc	a0,0x4
    33a0:	40c50513          	addi	a0,a0,1036 # 77a8 <malloc+0x1980>
    33a4:	1cd020ef          	jal	5d70 <printf>
    exit(1);
    33a8:	4505                	li	a0,1
    33aa:	570020ef          	jal	591a <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    33ae:	85ca                	mv	a1,s2
    33b0:	00004517          	auipc	a0,0x4
    33b4:	42850513          	addi	a0,a0,1064 # 77d8 <malloc+0x19b0>
    33b8:	1b9020ef          	jal	5d70 <printf>
    exit(1);
    33bc:	4505                	li	a0,1
    33be:	55c020ef          	jal	591a <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    33c2:	85ca                	mv	a1,s2
    33c4:	00004517          	auipc	a0,0x4
    33c8:	41450513          	addi	a0,a0,1044 # 77d8 <malloc+0x19b0>
    33cc:	1a5020ef          	jal	5d70 <printf>
    exit(1);
    33d0:	4505                	li	a0,1
    33d2:	548020ef          	jal	591a <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    33d6:	85ca                	mv	a1,s2
    33d8:	00004517          	auipc	a0,0x4
    33dc:	42850513          	addi	a0,a0,1064 # 7800 <malloc+0x19d8>
    33e0:	191020ef          	jal	5d70 <printf>
    exit(1);
    33e4:	4505                	li	a0,1
    33e6:	534020ef          	jal	591a <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    33ea:	85ca                	mv	a1,s2
    33ec:	00004517          	auipc	a0,0x4
    33f0:	43c50513          	addi	a0,a0,1084 # 7828 <malloc+0x1a00>
    33f4:	17d020ef          	jal	5d70 <printf>
    exit(1);
    33f8:	4505                	li	a0,1
    33fa:	520020ef          	jal	591a <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    33fe:	85ca                	mv	a1,s2
    3400:	00004517          	auipc	a0,0x4
    3404:	45050513          	addi	a0,a0,1104 # 7850 <malloc+0x1a28>
    3408:	169020ef          	jal	5d70 <printf>
    exit(1);
    340c:	4505                	li	a0,1
    340e:	50c020ef          	jal	591a <exit>
    printf("%s: unlink dirfile failed!\n", s);
    3412:	85ca                	mv	a1,s2
    3414:	00004517          	auipc	a0,0x4
    3418:	46450513          	addi	a0,a0,1124 # 7878 <malloc+0x1a50>
    341c:	155020ef          	jal	5d70 <printf>
    exit(1);
    3420:	4505                	li	a0,1
    3422:	4f8020ef          	jal	591a <exit>
    printf("%s: open . for writing succeeded!\n", s);
    3426:	85ca                	mv	a1,s2
    3428:	00004517          	auipc	a0,0x4
    342c:	47050513          	addi	a0,a0,1136 # 7898 <malloc+0x1a70>
    3430:	141020ef          	jal	5d70 <printf>
    exit(1);
    3434:	4505                	li	a0,1
    3436:	4e4020ef          	jal	591a <exit>
    printf("%s: write . succeeded!\n", s);
    343a:	85ca                	mv	a1,s2
    343c:	00004517          	auipc	a0,0x4
    3440:	48450513          	addi	a0,a0,1156 # 78c0 <malloc+0x1a98>
    3444:	12d020ef          	jal	5d70 <printf>
    exit(1);
    3448:	4505                	li	a0,1
    344a:	4d0020ef          	jal	591a <exit>

000000000000344e <iref>:
{
    344e:	715d                	addi	sp,sp,-80
    3450:	e486                	sd	ra,72(sp)
    3452:	e0a2                	sd	s0,64(sp)
    3454:	fc26                	sd	s1,56(sp)
    3456:	f84a                	sd	s2,48(sp)
    3458:	f44e                	sd	s3,40(sp)
    345a:	f052                	sd	s4,32(sp)
    345c:	ec56                	sd	s5,24(sp)
    345e:	e85a                	sd	s6,16(sp)
    3460:	e45e                	sd	s7,8(sp)
    3462:	0880                	addi	s0,sp,80
    3464:	8baa                	mv	s7,a0
    3466:	03300913          	li	s2,51
    if (mkdir("irefd") != 0) {
    346a:	00004a97          	auipc	s5,0x4
    346e:	46ea8a93          	addi	s5,s5,1134 # 78d8 <malloc+0x1ab0>
    mkdir("");
    3472:	00004497          	auipc	s1,0x4
    3476:	f6e48493          	addi	s1,s1,-146 # 73e0 <malloc+0x15b8>
    link("README", "");
    347a:	00003b17          	auipc	s6,0x3
    347e:	cb6b0b13          	addi	s6,s6,-842 # 6130 <malloc+0x308>
    fd = open("", O_CREATE);
    3482:	20000a13          	li	s4,512
    fd = open("xx", O_CREATE);
    3486:	00004997          	auipc	s3,0x4
    348a:	34a98993          	addi	s3,s3,842 # 77d0 <malloc+0x19a8>
    348e:	a835                	j	34ca <iref+0x7c>
      printf("%s: mkdir irefd failed\n", s);
    3490:	85de                	mv	a1,s7
    3492:	00004517          	auipc	a0,0x4
    3496:	44e50513          	addi	a0,a0,1102 # 78e0 <malloc+0x1ab8>
    349a:	0d7020ef          	jal	5d70 <printf>
      exit(1);
    349e:	4505                	li	a0,1
    34a0:	47a020ef          	jal	591a <exit>
      printf("%s: chdir irefd failed\n", s);
    34a4:	85de                	mv	a1,s7
    34a6:	00004517          	auipc	a0,0x4
    34aa:	45250513          	addi	a0,a0,1106 # 78f8 <malloc+0x1ad0>
    34ae:	0c3020ef          	jal	5d70 <printf>
      exit(1);
    34b2:	4505                	li	a0,1
    34b4:	466020ef          	jal	591a <exit>
      close(fd);
    34b8:	48a020ef          	jal	5942 <close>
    34bc:	a825                	j	34f4 <iref+0xa6>
    unlink("xx");
    34be:	854e                	mv	a0,s3
    34c0:	4aa020ef          	jal	596a <unlink>
  for (i = 0; i < NINODE + 1; i++) {
    34c4:	397d                	addiw	s2,s2,-1
    34c6:	04090063          	beqz	s2,3506 <iref+0xb8>
    if (mkdir("irefd") != 0) {
    34ca:	8556                	mv	a0,s5
    34cc:	4b6020ef          	jal	5982 <mkdir>
    34d0:	f161                	bnez	a0,3490 <iref+0x42>
    if (chdir("irefd") != 0) {
    34d2:	8556                	mv	a0,s5
    34d4:	4b6020ef          	jal	598a <chdir>
    34d8:	f571                	bnez	a0,34a4 <iref+0x56>
    mkdir("");
    34da:	8526                	mv	a0,s1
    34dc:	4a6020ef          	jal	5982 <mkdir>
    link("README", "");
    34e0:	85a6                	mv	a1,s1
    34e2:	855a                	mv	a0,s6
    34e4:	496020ef          	jal	597a <link>
    fd = open("", O_CREATE);
    34e8:	85d2                	mv	a1,s4
    34ea:	8526                	mv	a0,s1
    34ec:	46e020ef          	jal	595a <open>
    if (fd >= 0)
    34f0:	fc0554e3          	bgez	a0,34b8 <iref+0x6a>
    fd = open("xx", O_CREATE);
    34f4:	85d2                	mv	a1,s4
    34f6:	854e                	mv	a0,s3
    34f8:	462020ef          	jal	595a <open>
    if (fd >= 0)
    34fc:	fc0541e3          	bltz	a0,34be <iref+0x70>
      close(fd);
    3500:	442020ef          	jal	5942 <close>
    3504:	bf6d                	j	34be <iref+0x70>
    3506:	03300493          	li	s1,51
    chdir("..");
    350a:	00004997          	auipc	s3,0x4
    350e:	bee98993          	addi	s3,s3,-1042 # 70f8 <malloc+0x12d0>
    unlink("irefd");
    3512:	00004917          	auipc	s2,0x4
    3516:	3c690913          	addi	s2,s2,966 # 78d8 <malloc+0x1ab0>
    chdir("..");
    351a:	854e                	mv	a0,s3
    351c:	46e020ef          	jal	598a <chdir>
    unlink("irefd");
    3520:	854a                	mv	a0,s2
    3522:	448020ef          	jal	596a <unlink>
  for (i = 0; i < NINODE + 1; i++) {
    3526:	34fd                	addiw	s1,s1,-1
    3528:	f8ed                	bnez	s1,351a <iref+0xcc>
  chdir("/");
    352a:	00004517          	auipc	a0,0x4
    352e:	b7650513          	addi	a0,a0,-1162 # 70a0 <malloc+0x1278>
    3532:	458020ef          	jal	598a <chdir>
}
    3536:	60a6                	ld	ra,72(sp)
    3538:	6406                	ld	s0,64(sp)
    353a:	74e2                	ld	s1,56(sp)
    353c:	7942                	ld	s2,48(sp)
    353e:	79a2                	ld	s3,40(sp)
    3540:	7a02                	ld	s4,32(sp)
    3542:	6ae2                	ld	s5,24(sp)
    3544:	6b42                	ld	s6,16(sp)
    3546:	6ba2                	ld	s7,8(sp)
    3548:	6161                	addi	sp,sp,80
    354a:	8082                	ret

000000000000354c <unlinkcwd>:
{
    354c:	1101                	addi	sp,sp,-32
    354e:	ec06                	sd	ra,24(sp)
    3550:	e822                	sd	s0,16(sp)
    3552:	e426                	sd	s1,8(sp)
    3554:	1000                	addi	s0,sp,32
    3556:	84aa                	mv	s1,a0
  if (mkdir("/a") < 0) {
    3558:	00004517          	auipc	a0,0x4
    355c:	3b850513          	addi	a0,a0,952 # 7910 <malloc+0x1ae8>
    3560:	422020ef          	jal	5982 <mkdir>
    3564:	06054a63          	bltz	a0,35d8 <unlinkcwd+0x8c>
  if (mkdir("/a/b") < 0) {
    3568:	00004517          	auipc	a0,0x4
    356c:	3c850513          	addi	a0,a0,968 # 7930 <malloc+0x1b08>
    3570:	412020ef          	jal	5982 <mkdir>
    3574:	06054c63          	bltz	a0,35ec <unlinkcwd+0xa0>
  if (chdir("/a/b") < 0) {
    3578:	00004517          	auipc	a0,0x4
    357c:	3b850513          	addi	a0,a0,952 # 7930 <malloc+0x1b08>
    3580:	40a020ef          	jal	598a <chdir>
    3584:	06054e63          	bltz	a0,3600 <unlinkcwd+0xb4>
  if (unlink("/a/b") < 0) {
    3588:	00004517          	auipc	a0,0x4
    358c:	3a850513          	addi	a0,a0,936 # 7930 <malloc+0x1b08>
    3590:	3da020ef          	jal	596a <unlink>
    3594:	08054063          	bltz	a0,3614 <unlinkcwd+0xc8>
  if (unlink("/a") < 0) {
    3598:	00004517          	auipc	a0,0x4
    359c:	37850513          	addi	a0,a0,888 # 7910 <malloc+0x1ae8>
    35a0:	3ca020ef          	jal	596a <unlink>
    35a4:	08054263          	bltz	a0,3628 <unlinkcwd+0xdc>
  if (open("../", O_RDONLY) > 0) {
    35a8:	4581                	li	a1,0
    35aa:	00004517          	auipc	a0,0x4
    35ae:	3ee50513          	addi	a0,a0,1006 # 7998 <malloc+0x1b70>
    35b2:	3a8020ef          	jal	595a <open>
    35b6:	08a04363          	bgtz	a0,363c <unlinkcwd+0xf0>
  if (open("../c", O_CREATE) > 0) {
    35ba:	20000593          	li	a1,512
    35be:	00004517          	auipc	a0,0x4
    35c2:	40a50513          	addi	a0,a0,1034 # 79c8 <malloc+0x1ba0>
    35c6:	394020ef          	jal	595a <open>
    35ca:	08a04163          	bgtz	a0,364c <unlinkcwd+0x100>
}
    35ce:	60e2                	ld	ra,24(sp)
    35d0:	6442                	ld	s0,16(sp)
    35d2:	64a2                	ld	s1,8(sp)
    35d4:	6105                	addi	sp,sp,32
    35d6:	8082                	ret
    printf("%s: mkdir /a failed\n", s);
    35d8:	85a6                	mv	a1,s1
    35da:	00004517          	auipc	a0,0x4
    35de:	33e50513          	addi	a0,a0,830 # 7918 <malloc+0x1af0>
    35e2:	78e020ef          	jal	5d70 <printf>
    exit(1);
    35e6:	4505                	li	a0,1
    35e8:	332020ef          	jal	591a <exit>
    printf("%s: mkdir /a/b failed\n", s);
    35ec:	85a6                	mv	a1,s1
    35ee:	00004517          	auipc	a0,0x4
    35f2:	34a50513          	addi	a0,a0,842 # 7938 <malloc+0x1b10>
    35f6:	77a020ef          	jal	5d70 <printf>
    exit(1);
    35fa:	4505                	li	a0,1
    35fc:	31e020ef          	jal	591a <exit>
    printf("%s: chdir failed\n", s);
    3600:	85a6                	mv	a1,s1
    3602:	00004517          	auipc	a0,0x4
    3606:	34e50513          	addi	a0,a0,846 # 7950 <malloc+0x1b28>
    360a:	766020ef          	jal	5d70 <printf>
    exit(1);
    360e:	4505                	li	a0,1
    3610:	30a020ef          	jal	591a <exit>
    printf("%s: unlink /a/b failed\n", s);
    3614:	85a6                	mv	a1,s1
    3616:	00004517          	auipc	a0,0x4
    361a:	35250513          	addi	a0,a0,850 # 7968 <malloc+0x1b40>
    361e:	752020ef          	jal	5d70 <printf>
    exit(1);
    3622:	4505                	li	a0,1
    3624:	2f6020ef          	jal	591a <exit>
    printf("%s: unlink /a failed\n", s);
    3628:	85a6                	mv	a1,s1
    362a:	00004517          	auipc	a0,0x4
    362e:	35650513          	addi	a0,a0,854 # 7980 <malloc+0x1b58>
    3632:	73e020ef          	jal	5d70 <printf>
    exit(1);
    3636:	4505                	li	a0,1
    3638:	2e2020ef          	jal	591a <exit>
    printf("%s: open ../ non-existing directory\n", s);
    363c:	85a6                	mv	a1,s1
    363e:	00004517          	auipc	a0,0x4
    3642:	36250513          	addi	a0,a0,866 # 79a0 <malloc+0x1b78>
    3646:	72a020ef          	jal	5d70 <printf>
    364a:	bf85                	j	35ba <unlinkcwd+0x6e>
    printf("%s: create ../c non-existing file\n", s);
    364c:	85a6                	mv	a1,s1
    364e:	00004517          	auipc	a0,0x4
    3652:	38250513          	addi	a0,a0,898 # 79d0 <malloc+0x1ba8>
    3656:	71a020ef          	jal	5d70 <printf>
}
    365a:	bf95                	j	35ce <unlinkcwd+0x82>

000000000000365c <openiputtest>:
{
    365c:	7179                	addi	sp,sp,-48
    365e:	f406                	sd	ra,40(sp)
    3660:	f022                	sd	s0,32(sp)
    3662:	ec26                	sd	s1,24(sp)
    3664:	1800                	addi	s0,sp,48
    3666:	84aa                	mv	s1,a0
  if (mkdir("oidir") < 0) {
    3668:	00004517          	auipc	a0,0x4
    366c:	39050513          	addi	a0,a0,912 # 79f8 <malloc+0x1bd0>
    3670:	312020ef          	jal	5982 <mkdir>
    3674:	02054a63          	bltz	a0,36a8 <openiputtest+0x4c>
  pid = fork();
    3678:	29a020ef          	jal	5912 <fork>
  if (pid < 0) {
    367c:	04054063          	bltz	a0,36bc <openiputtest+0x60>
  if (pid == 0) {
    3680:	e939                	bnez	a0,36d6 <openiputtest+0x7a>
    int fd = open("oidir", O_RDWR);
    3682:	4589                	li	a1,2
    3684:	00004517          	auipc	a0,0x4
    3688:	37450513          	addi	a0,a0,884 # 79f8 <malloc+0x1bd0>
    368c:	2ce020ef          	jal	595a <open>
    if (fd >= 0) {
    3690:	04054063          	bltz	a0,36d0 <openiputtest+0x74>
      printf("%s: open directory for write succeeded\n", s);
    3694:	85a6                	mv	a1,s1
    3696:	00004517          	auipc	a0,0x4
    369a:	38250513          	addi	a0,a0,898 # 7a18 <malloc+0x1bf0>
    369e:	6d2020ef          	jal	5d70 <printf>
      exit(1);
    36a2:	4505                	li	a0,1
    36a4:	276020ef          	jal	591a <exit>
    printf("%s: mkdir oidir failed\n", s);
    36a8:	85a6                	mv	a1,s1
    36aa:	00004517          	auipc	a0,0x4
    36ae:	35650513          	addi	a0,a0,854 # 7a00 <malloc+0x1bd8>
    36b2:	6be020ef          	jal	5d70 <printf>
    exit(1);
    36b6:	4505                	li	a0,1
    36b8:	262020ef          	jal	591a <exit>
    printf("%s: fork failed\n", s);
    36bc:	85a6                	mv	a1,s1
    36be:	00003517          	auipc	a0,0x3
    36c2:	12a50513          	addi	a0,a0,298 # 67e8 <malloc+0x9c0>
    36c6:	6aa020ef          	jal	5d70 <printf>
    exit(1);
    36ca:	4505                	li	a0,1
    36cc:	24e020ef          	jal	591a <exit>
    exit(0);
    36d0:	4501                	li	a0,0
    36d2:	248020ef          	jal	591a <exit>
  pause(1);
    36d6:	4505                	li	a0,1
    36d8:	2d2020ef          	jal	59aa <pause>
  if (unlink("oidir") != 0) {
    36dc:	00004517          	auipc	a0,0x4
    36e0:	31c50513          	addi	a0,a0,796 # 79f8 <malloc+0x1bd0>
    36e4:	286020ef          	jal	596a <unlink>
    36e8:	c919                	beqz	a0,36fe <openiputtest+0xa2>
    printf("%s: unlink failed\n", s);
    36ea:	85a6                	mv	a1,s1
    36ec:	00003517          	auipc	a0,0x3
    36f0:	28450513          	addi	a0,a0,644 # 6970 <malloc+0xb48>
    36f4:	67c020ef          	jal	5d70 <printf>
    exit(1);
    36f8:	4505                	li	a0,1
    36fa:	220020ef          	jal	591a <exit>
  wait(&xstatus);
    36fe:	fdc40513          	addi	a0,s0,-36
    3702:	220020ef          	jal	5922 <wait>
  exit(xstatus);
    3706:	fdc42503          	lw	a0,-36(s0)
    370a:	210020ef          	jal	591a <exit>

000000000000370e <forkforkfork>:
{
    370e:	1101                	addi	sp,sp,-32
    3710:	ec06                	sd	ra,24(sp)
    3712:	e822                	sd	s0,16(sp)
    3714:	e426                	sd	s1,8(sp)
    3716:	1000                	addi	s0,sp,32
    3718:	84aa                	mv	s1,a0
  unlink("stopforking");
    371a:	00004517          	auipc	a0,0x4
    371e:	32650513          	addi	a0,a0,806 # 7a40 <malloc+0x1c18>
    3722:	248020ef          	jal	596a <unlink>
  int pid = fork();
    3726:	1ec020ef          	jal	5912 <fork>
  if (pid < 0) {
    372a:	02054b63          	bltz	a0,3760 <forkforkfork+0x52>
  if (pid == 0) {
    372e:	c139                	beqz	a0,3774 <forkforkfork+0x66>
  pause(20); // two seconds
    3730:	4551                	li	a0,20
    3732:	278020ef          	jal	59aa <pause>
  close(open("stopforking", O_CREATE | O_RDWR));
    3736:	20200593          	li	a1,514
    373a:	00004517          	auipc	a0,0x4
    373e:	30650513          	addi	a0,a0,774 # 7a40 <malloc+0x1c18>
    3742:	218020ef          	jal	595a <open>
    3746:	1fc020ef          	jal	5942 <close>
  wait(0);
    374a:	4501                	li	a0,0
    374c:	1d6020ef          	jal	5922 <wait>
  pause(10); // one second
    3750:	4529                	li	a0,10
    3752:	258020ef          	jal	59aa <pause>
}
    3756:	60e2                	ld	ra,24(sp)
    3758:	6442                	ld	s0,16(sp)
    375a:	64a2                	ld	s1,8(sp)
    375c:	6105                	addi	sp,sp,32
    375e:	8082                	ret
    printf("%s: fork failed", s);
    3760:	85a6                	mv	a1,s1
    3762:	00003517          	auipc	a0,0x3
    3766:	1c650513          	addi	a0,a0,454 # 6928 <malloc+0xb00>
    376a:	606020ef          	jal	5d70 <printf>
    exit(1);
    376e:	4505                	li	a0,1
    3770:	1aa020ef          	jal	591a <exit>
      int fd = open("stopforking", 0);
    3774:	4581                	li	a1,0
    3776:	00004517          	auipc	a0,0x4
    377a:	2ca50513          	addi	a0,a0,714 # 7a40 <malloc+0x1c18>
    377e:	1dc020ef          	jal	595a <open>
      if (fd >= 0) {
    3782:	02055163          	bgez	a0,37a4 <forkforkfork+0x96>
      if (fork() < 0) {
    3786:	18c020ef          	jal	5912 <fork>
    378a:	fe0555e3          	bgez	a0,3774 <forkforkfork+0x66>
        close(open("stopforking", O_CREATE | O_RDWR));
    378e:	20200593          	li	a1,514
    3792:	00004517          	auipc	a0,0x4
    3796:	2ae50513          	addi	a0,a0,686 # 7a40 <malloc+0x1c18>
    379a:	1c0020ef          	jal	595a <open>
    379e:	1a4020ef          	jal	5942 <close>
    37a2:	bfc9                	j	3774 <forkforkfork+0x66>
        exit(0);
    37a4:	4501                	li	a0,0
    37a6:	174020ef          	jal	591a <exit>

00000000000037aa <exectest>:
{
    37aa:	711d                	addi	sp,sp,-96
    37ac:	ec86                	sd	ra,88(sp)
    37ae:	e8a2                	sd	s0,80(sp)
    37b0:	e0ca                	sd	s2,64(sp)
    37b2:	1080                	addi	s0,sp,96
    37b4:	892a                	mv	s2,a0
  char *echoargv[] = {"echo", "OK", 0};
    37b6:	00002797          	auipc	a5,0x2
    37ba:	7a278793          	addi	a5,a5,1954 # 5f58 <malloc+0x130>
    37be:	faf43823          	sd	a5,-80(s0)
    37c2:	00004797          	auipc	a5,0x4
    37c6:	28e78793          	addi	a5,a5,654 # 7a50 <malloc+0x1c28>
    37ca:	faf43c23          	sd	a5,-72(s0)
    37ce:	fc043023          	sd	zero,-64(s0)
  unlink("echo-ok");
    37d2:	00004517          	auipc	a0,0x4
    37d6:	28650513          	addi	a0,a0,646 # 7a58 <malloc+0x1c30>
    37da:	190020ef          	jal	596a <unlink>
  pid = fork();
    37de:	134020ef          	jal	5912 <fork>
  if (pid < 0) {
    37e2:	04054763          	bltz	a0,3830 <exectest+0x86>
    37e6:	e4a6                	sd	s1,72(sp)
    37e8:	fc4e                	sd	s3,56(sp)
    37ea:	84aa                	mv	s1,a0
  if (pid == 0) {
    37ec:	ed49                	bnez	a0,3886 <exectest+0xdc>
    int errfd = dup(1);
    37ee:	4505                	li	a0,1
    37f0:	1a2020ef          	jal	5992 <dup>
    37f4:	89aa                	mv	s3,a0
    if (errfd < 0) {
    37f6:	04054963          	bltz	a0,3848 <exectest+0x9e>
    close(1);
    37fa:	4505                	li	a0,1
    37fc:	146020ef          	jal	5942 <close>
    fd = open("echo-ok", O_CREATE | O_WRONLY);
    3800:	20100593          	li	a1,513
    3804:	00004517          	auipc	a0,0x4
    3808:	25450513          	addi	a0,a0,596 # 7a58 <malloc+0x1c30>
    380c:	14e020ef          	jal	595a <open>
    if (fd < 0) {
    3810:	04054663          	bltz	a0,385c <exectest+0xb2>
    if (fd != 1) {
    3814:	4785                	li	a5,1
    3816:	04f50e63          	beq	a0,a5,3872 <exectest+0xc8>
      fprintf(errfd, "%s: wrong fd\n", s);
    381a:	864a                	mv	a2,s2
    381c:	00004597          	auipc	a1,0x4
    3820:	25458593          	addi	a1,a1,596 # 7a70 <malloc+0x1c48>
    3824:	854e                	mv	a0,s3
    3826:	520020ef          	jal	5d46 <fprintf>
      exit(1);
    382a:	4505                	li	a0,1
    382c:	0ee020ef          	jal	591a <exit>
    3830:	e4a6                	sd	s1,72(sp)
    3832:	fc4e                	sd	s3,56(sp)
    printf("%s: fork failed\n", s);
    3834:	85ca                	mv	a1,s2
    3836:	00003517          	auipc	a0,0x3
    383a:	fb250513          	addi	a0,a0,-78 # 67e8 <malloc+0x9c0>
    383e:	532020ef          	jal	5d70 <printf>
    exit(1);
    3842:	4505                	li	a0,1
    3844:	0d6020ef          	jal	591a <exit>
      printf("%s: dup failed\n", s);
    3848:	85ca                	mv	a1,s2
    384a:	00004517          	auipc	a0,0x4
    384e:	21650513          	addi	a0,a0,534 # 7a60 <malloc+0x1c38>
    3852:	51e020ef          	jal	5d70 <printf>
      exit(1);
    3856:	4505                	li	a0,1
    3858:	0c2020ef          	jal	591a <exit>
      fprintf(errfd, "%s: create failed\n", s);
    385c:	864a                	mv	a2,s2
    385e:	00003597          	auipc	a1,0x3
    3862:	0fa58593          	addi	a1,a1,250 # 6958 <malloc+0xb30>
    3866:	854e                	mv	a0,s3
    3868:	4de020ef          	jal	5d46 <fprintf>
      exit(1);
    386c:	4505                	li	a0,1
    386e:	0ac020ef          	jal	591a <exit>
    if (exec("echo", echoargv) < 0) {
    3872:	fb040593          	addi	a1,s0,-80
    3876:	00002517          	auipc	a0,0x2
    387a:	6e250513          	addi	a0,a0,1762 # 5f58 <malloc+0x130>
    387e:	0d4020ef          	jal	5952 <exec>
    3882:	02054563          	bltz	a0,38ac <exectest+0x102>
  if (wait(&xstatus) != pid) {
    3886:	fcc40513          	addi	a0,s0,-52
    388a:	098020ef          	jal	5922 <wait>
    388e:	02951a63          	bne	a0,s1,38c2 <exectest+0x118>
  if (xstatus != 0) {
    3892:	fcc42603          	lw	a2,-52(s0)
    3896:	ce15                	beqz	a2,38d2 <exectest+0x128>
    printf("%s: nonzero wait status %d\n", s, xstatus);
    3898:	85ca                	mv	a1,s2
    389a:	00004517          	auipc	a0,0x4
    389e:	21650513          	addi	a0,a0,534 # 7ab0 <malloc+0x1c88>
    38a2:	4ce020ef          	jal	5d70 <printf>
    exit(1);
    38a6:	4505                	li	a0,1
    38a8:	072020ef          	jal	591a <exit>
      fprintf(errfd, "%s: exec echo failed\n", s);
    38ac:	864a                	mv	a2,s2
    38ae:	00004597          	auipc	a1,0x4
    38b2:	1d258593          	addi	a1,a1,466 # 7a80 <malloc+0x1c58>
    38b6:	854e                	mv	a0,s3
    38b8:	48e020ef          	jal	5d46 <fprintf>
      exit(1);
    38bc:	4505                	li	a0,1
    38be:	05c020ef          	jal	591a <exit>
    printf("%s: wait failed!\n", s);
    38c2:	85ca                	mv	a1,s2
    38c4:	00004517          	auipc	a0,0x4
    38c8:	1d450513          	addi	a0,a0,468 # 7a98 <malloc+0x1c70>
    38cc:	4a4020ef          	jal	5d70 <printf>
    38d0:	b7c9                	j	3892 <exectest+0xe8>
  fd = open("echo-ok", O_RDONLY);
    38d2:	4581                	li	a1,0
    38d4:	00004517          	auipc	a0,0x4
    38d8:	18450513          	addi	a0,a0,388 # 7a58 <malloc+0x1c30>
    38dc:	07e020ef          	jal	595a <open>
  if (fd < 0) {
    38e0:	02054463          	bltz	a0,3908 <exectest+0x15e>
  if (read(fd, buf, 2) != 2) {
    38e4:	4609                	li	a2,2
    38e6:	fa840593          	addi	a1,s0,-88
    38ea:	048020ef          	jal	5932 <read>
    38ee:	4789                	li	a5,2
    38f0:	02f50663          	beq	a0,a5,391c <exectest+0x172>
    printf("%s: read failed\n", s);
    38f4:	85ca                	mv	a1,s2
    38f6:	00003517          	auipc	a0,0x3
    38fa:	a3250513          	addi	a0,a0,-1486 # 6328 <malloc+0x500>
    38fe:	472020ef          	jal	5d70 <printf>
    exit(1);
    3902:	4505                	li	a0,1
    3904:	016020ef          	jal	591a <exit>
    printf("%s: open failed\n", s);
    3908:	85ca                	mv	a1,s2
    390a:	00003517          	auipc	a0,0x3
    390e:	ef650513          	addi	a0,a0,-266 # 6800 <malloc+0x9d8>
    3912:	45e020ef          	jal	5d70 <printf>
    exit(1);
    3916:	4505                	li	a0,1
    3918:	002020ef          	jal	591a <exit>
  unlink("echo-ok");
    391c:	00004517          	auipc	a0,0x4
    3920:	13c50513          	addi	a0,a0,316 # 7a58 <malloc+0x1c30>
    3924:	046020ef          	jal	596a <unlink>
  if (buf[0] == 'O' && buf[1] == 'K')
    3928:	fa844703          	lbu	a4,-88(s0)
    392c:	04f00793          	li	a5,79
    3930:	00f71863          	bne	a4,a5,3940 <exectest+0x196>
    3934:	fa944703          	lbu	a4,-87(s0)
    3938:	04b00793          	li	a5,75
    393c:	00f70c63          	beq	a4,a5,3954 <exectest+0x1aa>
    printf("%s: wrong output\n", s);
    3940:	85ca                	mv	a1,s2
    3942:	00004517          	auipc	a0,0x4
    3946:	18e50513          	addi	a0,a0,398 # 7ad0 <malloc+0x1ca8>
    394a:	426020ef          	jal	5d70 <printf>
    exit(1);
    394e:	4505                	li	a0,1
    3950:	7cb010ef          	jal	591a <exit>
    exit(0);
    3954:	4501                	li	a0,0
    3956:	7c5010ef          	jal	591a <exit>

000000000000395a <pipezero>:
{
    395a:	715d                	addi	sp,sp,-80
    395c:	e486                	sd	ra,72(sp)
    395e:	e0a2                	sd	s0,64(sp)
    3960:	fc26                	sd	s1,56(sp)
    3962:	f84a                	sd	s2,48(sp)
    3964:	f44e                	sd	s3,40(sp)
    3966:	f052                	sd	s4,32(sp)
    3968:	0880                	addi	s0,sp,80
    396a:	8a2a                	mv	s4,a0
  if ((reader = fork()) < 0) {
    396c:	7a7010ef          	jal	5912 <fork>
    3970:	04054663          	bltz	a0,39bc <pipezero+0x62>
    3974:	892a                	mv	s2,a0
  if (reader == 0) {
    3976:	cd29                	beqz	a0,39d0 <pipezero+0x76>
  if ((timer = fork()) < 0) {
    3978:	79b010ef          	jal	5912 <fork>
    397c:	84aa                	mv	s1,a0
    397e:	12054463          	bltz	a0,3aa6 <pipezero+0x14c>
  if (timer == 0) {
    3982:	14050263          	beqz	a0,3ac6 <pipezero+0x16c>
  pid = wait(&status);
    3986:	fcc40513          	addi	a0,s0,-52
    398a:	799010ef          	jal	5922 <wait>
    398e:	89aa                	mv	s3,a0
  if (pid == timer) {
    3990:	14a48263          	beq	s1,a0,3ad4 <pipezero+0x17a>
  kill(timer);
    3994:	8526                	mv	a0,s1
    3996:	7b5010ef          	jal	594a <kill>
  wait(0);
    399a:	4501                	li	a0,0
    399c:	787010ef          	jal	5922 <wait>
  if (pid != reader || status != 0)
    39a0:	15391a63          	bne	s2,s3,3af4 <pipezero+0x19a>
    39a4:	fcc42783          	lw	a5,-52(s0)
    39a8:	14079663          	bnez	a5,3af4 <pipezero+0x19a>
}
    39ac:	60a6                	ld	ra,72(sp)
    39ae:	6406                	ld	s0,64(sp)
    39b0:	74e2                	ld	s1,56(sp)
    39b2:	7942                	ld	s2,48(sp)
    39b4:	79a2                	ld	s3,40(sp)
    39b6:	7a02                	ld	s4,32(sp)
    39b8:	6161                	addi	sp,sp,80
    39ba:	8082                	ret
    printf("%s: fork failed\n", s);
    39bc:	85d2                	mv	a1,s4
    39be:	00003517          	auipc	a0,0x3
    39c2:	e2a50513          	addi	a0,a0,-470 # 67e8 <malloc+0x9c0>
    39c6:	3aa020ef          	jal	5d70 <printf>
    exit(1);
    39ca:	4505                	li	a0,1
    39cc:	74f010ef          	jal	591a <exit>
  char c = 'z';
    39d0:	07a00793          	li	a5,122
    39d4:	faf40fa3          	sb	a5,-65(s0)
  if (pipe(fds) < 0) {
    39d8:	fc040513          	addi	a0,s0,-64
    39dc:	74f010ef          	jal	592a <pipe>
    39e0:	08054563          	bltz	a0,3a6a <pipezero+0x110>
  if (read(fds[0], &c, 0) != 0 || c != 'z') {
    39e4:	4601                	li	a2,0
    39e6:	fbf40593          	addi	a1,s0,-65
    39ea:	fc042503          	lw	a0,-64(s0)
    39ee:	745010ef          	jal	5932 <read>
    39f2:	e551                	bnez	a0,3a7e <pipezero+0x124>
    39f4:	fbf44703          	lbu	a4,-65(s0)
    39f8:	07a00793          	li	a5,122
    39fc:	08f71163          	bne	a4,a5,3a7e <pipezero+0x124>
  if (write(fds[1], "x", 1) != 1 || read(fds[0], &c, 0) != 0 || c != 'z' ||
    3a00:	4605                	li	a2,1
    3a02:	00002597          	auipc	a1,0x2
    3a06:	5c658593          	addi	a1,a1,1478 # 5fc8 <malloc+0x1a0>
    3a0a:	fc442503          	lw	a0,-60(s0)
    3a0e:	72d010ef          	jal	593a <write>
    3a12:	4785                	li	a5,1
    3a14:	06f51f63          	bne	a0,a5,3a92 <pipezero+0x138>
    3a18:	4601                	li	a2,0
    3a1a:	fbf40593          	addi	a1,s0,-65
    3a1e:	fc042503          	lw	a0,-64(s0)
    3a22:	711010ef          	jal	5932 <read>
    3a26:	e535                	bnez	a0,3a92 <pipezero+0x138>
    3a28:	fbf44703          	lbu	a4,-65(s0)
    3a2c:	07a00793          	li	a5,122
    3a30:	06f71163          	bne	a4,a5,3a92 <pipezero+0x138>
      read(fds[0], &c, 1) != 1 || c != 'x') {
    3a34:	4605                	li	a2,1
    3a36:	fbf40593          	addi	a1,s0,-65
    3a3a:	fc042503          	lw	a0,-64(s0)
    3a3e:	6f5010ef          	jal	5932 <read>
  if (write(fds[1], "x", 1) != 1 || read(fds[0], &c, 0) != 0 || c != 'z' ||
    3a42:	4785                	li	a5,1
    3a44:	04f51763          	bne	a0,a5,3a92 <pipezero+0x138>
      read(fds[0], &c, 1) != 1 || c != 'x') {
    3a48:	fbf44703          	lbu	a4,-65(s0)
    3a4c:	07800793          	li	a5,120
    3a50:	04f71163          	bne	a4,a5,3a92 <pipezero+0x138>
  close(fds[0]);
    3a54:	fc042503          	lw	a0,-64(s0)
    3a58:	6eb010ef          	jal	5942 <close>
  close(fds[1]);
    3a5c:	fc442503          	lw	a0,-60(s0)
    3a60:	6e3010ef          	jal	5942 <close>
    exit(0);
    3a64:	4501                	li	a0,0
    3a66:	6b5010ef          	jal	591a <exit>
    printf("%s: pipe failed\n", s);
    3a6a:	85d2                	mv	a1,s4
    3a6c:	00004517          	auipc	a0,0x4
    3a70:	07c50513          	addi	a0,a0,124 # 7ae8 <malloc+0x1cc0>
    3a74:	2fc020ef          	jal	5d70 <printf>
    exit(1);
    3a78:	4505                	li	a0,1
    3a7a:	6a1010ef          	jal	591a <exit>
    printf("%s: zero-length read on empty pipe failed\n", s);
    3a7e:	85d2                	mv	a1,s4
    3a80:	00004517          	auipc	a0,0x4
    3a84:	08050513          	addi	a0,a0,128 # 7b00 <malloc+0x1cd8>
    3a88:	2e8020ef          	jal	5d70 <printf>
    exit(1);
    3a8c:	4505                	li	a0,1
    3a8e:	68d010ef          	jal	591a <exit>
    printf("%s: zero-length read consumed data\n", s);
    3a92:	85d2                	mv	a1,s4
    3a94:	00004517          	auipc	a0,0x4
    3a98:	09c50513          	addi	a0,a0,156 # 7b30 <malloc+0x1d08>
    3a9c:	2d4020ef          	jal	5d70 <printf>
    exit(1);
    3aa0:	4505                	li	a0,1
    3aa2:	679010ef          	jal	591a <exit>
    kill(reader);
    3aa6:	854a                	mv	a0,s2
    3aa8:	6a3010ef          	jal	594a <kill>
    wait(0);
    3aac:	4501                	li	a0,0
    3aae:	675010ef          	jal	5922 <wait>
    printf("%s: fork failed\n", s);
    3ab2:	85d2                	mv	a1,s4
    3ab4:	00003517          	auipc	a0,0x3
    3ab8:	d3450513          	addi	a0,a0,-716 # 67e8 <malloc+0x9c0>
    3abc:	2b4020ef          	jal	5d70 <printf>
    exit(1);
    3ac0:	4505                	li	a0,1
    3ac2:	659010ef          	jal	591a <exit>
    pause(50);
    3ac6:	03200513          	li	a0,50
    3aca:	6e1010ef          	jal	59aa <pause>
    exit(0);
    3ace:	4501                	li	a0,0
    3ad0:	64b010ef          	jal	591a <exit>
    kill(reader);
    3ad4:	854a                	mv	a0,s2
    3ad6:	675010ef          	jal	594a <kill>
    wait(0);
    3ada:	4501                	li	a0,0
    3adc:	647010ef          	jal	5922 <wait>
    printf("%s: zero-length read timed out\n", s);
    3ae0:	85d2                	mv	a1,s4
    3ae2:	00004517          	auipc	a0,0x4
    3ae6:	07650513          	addi	a0,a0,118 # 7b58 <malloc+0x1d30>
    3aea:	286020ef          	jal	5d70 <printf>
    exit(1);
    3aee:	4505                	li	a0,1
    3af0:	62b010ef          	jal	591a <exit>
    exit(1);
    3af4:	4505                	li	a0,1
    3af6:	625010ef          	jal	591a <exit>

0000000000003afa <killzero>:
{
    3afa:	7179                	addi	sp,sp,-48
    3afc:	f406                	sd	ra,40(sp)
    3afe:	f022                	sd	s0,32(sp)
    3b00:	e84a                	sd	s2,16(sp)
    3b02:	1800                	addi	s0,sp,48
    3b04:	892a                	mv	s2,a0
  kill(0);
    3b06:	4501                	li	a0,0
    3b08:	643010ef          	jal	594a <kill>
  pid = fork();
    3b0c:	607010ef          	jal	5912 <fork>
  if (pid < 0) {
    3b10:	00054863          	bltz	a0,3b20 <killzero+0x26>
    3b14:	ec26                	sd	s1,24(sp)
    3b16:	84aa                	mv	s1,a0
  if (pid == 0) {
    3b18:	ed19                	bnez	a0,3b36 <killzero+0x3c>
    exit(7);
    3b1a:	451d                	li	a0,7
    3b1c:	5ff010ef          	jal	591a <exit>
    3b20:	ec26                	sd	s1,24(sp)
    printf("%s: fork failed\n", s);
    3b22:	85ca                	mv	a1,s2
    3b24:	00003517          	auipc	a0,0x3
    3b28:	cc450513          	addi	a0,a0,-828 # 67e8 <malloc+0x9c0>
    3b2c:	244020ef          	jal	5d70 <printf>
    exit(1);
    3b30:	4505                	li	a0,1
    3b32:	5e9010ef          	jal	591a <exit>
  if (wait(&xst) != pid) {
    3b36:	fdc40513          	addi	a0,s0,-36
    3b3a:	5e9010ef          	jal	5922 <wait>
    3b3e:	02951163          	bne	a0,s1,3b60 <killzero+0x66>
  if (xst != 7) {
    3b42:	fdc42603          	lw	a2,-36(s0)
    3b46:	479d                	li	a5,7
    3b48:	02f60663          	beq	a2,a5,3b74 <killzero+0x7a>
    printf("%s: child exited with status %d, expected 7\n", s, xst);
    3b4c:	85ca                	mv	a1,s2
    3b4e:	00004517          	auipc	a0,0x4
    3b52:	02a50513          	addi	a0,a0,42 # 7b78 <malloc+0x1d50>
    3b56:	21a020ef          	jal	5d70 <printf>
    exit(1);
    3b5a:	4505                	li	a0,1
    3b5c:	5bf010ef          	jal	591a <exit>
    printf("%s: wait wrong pid\n", s);
    3b60:	85ca                	mv	a1,s2
    3b62:	00003517          	auipc	a0,0x3
    3b66:	d8e50513          	addi	a0,a0,-626 # 68f0 <malloc+0xac8>
    3b6a:	206020ef          	jal	5d70 <printf>
    exit(1);
    3b6e:	4505                	li	a0,1
    3b70:	5ab010ef          	jal	591a <exit>
  exit(0);
    3b74:	4501                	li	a0,0
    3b76:	5a5010ef          	jal	591a <exit>

0000000000003b7a <preempt>:
{
    3b7a:	7139                	addi	sp,sp,-64
    3b7c:	fc06                	sd	ra,56(sp)
    3b7e:	f822                	sd	s0,48(sp)
    3b80:	f426                	sd	s1,40(sp)
    3b82:	f04a                	sd	s2,32(sp)
    3b84:	ec4e                	sd	s3,24(sp)
    3b86:	e852                	sd	s4,16(sp)
    3b88:	0080                	addi	s0,sp,64
    3b8a:	892a                	mv	s2,a0
  pid1 = fork();
    3b8c:	587010ef          	jal	5912 <fork>
  if (pid1 < 0) {
    3b90:	00054563          	bltz	a0,3b9a <preempt+0x20>
    3b94:	84aa                	mv	s1,a0
  if (pid1 == 0)
    3b96:	ed01                	bnez	a0,3bae <preempt+0x34>
    for (;;)
    3b98:	a001                	j	3b98 <preempt+0x1e>
    printf("%s: fork failed", s);
    3b9a:	85ca                	mv	a1,s2
    3b9c:	00003517          	auipc	a0,0x3
    3ba0:	d8c50513          	addi	a0,a0,-628 # 6928 <malloc+0xb00>
    3ba4:	1cc020ef          	jal	5d70 <printf>
    exit(1);
    3ba8:	4505                	li	a0,1
    3baa:	571010ef          	jal	591a <exit>
  pid2 = fork();
    3bae:	565010ef          	jal	5912 <fork>
    3bb2:	89aa                	mv	s3,a0
  if (pid2 < 0) {
    3bb4:	00054463          	bltz	a0,3bbc <preempt+0x42>
  if (pid2 == 0)
    3bb8:	ed01                	bnez	a0,3bd0 <preempt+0x56>
    for (;;)
    3bba:	a001                	j	3bba <preempt+0x40>
    printf("%s: fork failed\n", s);
    3bbc:	85ca                	mv	a1,s2
    3bbe:	00003517          	auipc	a0,0x3
    3bc2:	c2a50513          	addi	a0,a0,-982 # 67e8 <malloc+0x9c0>
    3bc6:	1aa020ef          	jal	5d70 <printf>
    exit(1);
    3bca:	4505                	li	a0,1
    3bcc:	54f010ef          	jal	591a <exit>
  pipe(pfds);
    3bd0:	fc840513          	addi	a0,s0,-56
    3bd4:	557010ef          	jal	592a <pipe>
  pid3 = fork();
    3bd8:	53b010ef          	jal	5912 <fork>
    3bdc:	8a2a                	mv	s4,a0
  if (pid3 < 0) {
    3bde:	02054863          	bltz	a0,3c0e <preempt+0x94>
  if (pid3 == 0) {
    3be2:	e921                	bnez	a0,3c32 <preempt+0xb8>
    close(pfds[0]);
    3be4:	fc842503          	lw	a0,-56(s0)
    3be8:	55b010ef          	jal	5942 <close>
    if (write(pfds[1], "x", 1) != 1)
    3bec:	4605                	li	a2,1
    3bee:	00002597          	auipc	a1,0x2
    3bf2:	3da58593          	addi	a1,a1,986 # 5fc8 <malloc+0x1a0>
    3bf6:	fcc42503          	lw	a0,-52(s0)
    3bfa:	541010ef          	jal	593a <write>
    3bfe:	4785                	li	a5,1
    3c00:	02f51163          	bne	a0,a5,3c22 <preempt+0xa8>
    close(pfds[1]);
    3c04:	fcc42503          	lw	a0,-52(s0)
    3c08:	53b010ef          	jal	5942 <close>
    for (;;)
    3c0c:	a001                	j	3c0c <preempt+0x92>
    printf("%s: fork failed\n", s);
    3c0e:	85ca                	mv	a1,s2
    3c10:	00003517          	auipc	a0,0x3
    3c14:	bd850513          	addi	a0,a0,-1064 # 67e8 <malloc+0x9c0>
    3c18:	158020ef          	jal	5d70 <printf>
    exit(1);
    3c1c:	4505                	li	a0,1
    3c1e:	4fd010ef          	jal	591a <exit>
      printf("%s: preempt write error", s);
    3c22:	85ca                	mv	a1,s2
    3c24:	00004517          	auipc	a0,0x4
    3c28:	f8450513          	addi	a0,a0,-124 # 7ba8 <malloc+0x1d80>
    3c2c:	144020ef          	jal	5d70 <printf>
    3c30:	bfd1                	j	3c04 <preempt+0x8a>
  close(pfds[1]);
    3c32:	fcc42503          	lw	a0,-52(s0)
    3c36:	50d010ef          	jal	5942 <close>
  if (read(pfds[0], buf, sizeof(buf)) != 1) {
    3c3a:	660d                	lui	a2,0x3
    3c3c:	0000b597          	auipc	a1,0xb
    3c40:	0cc58593          	addi	a1,a1,204 # ed08 <buf>
    3c44:	fc842503          	lw	a0,-56(s0)
    3c48:	4eb010ef          	jal	5932 <read>
    3c4c:	4785                	li	a5,1
    3c4e:	02f50163          	beq	a0,a5,3c70 <preempt+0xf6>
    printf("%s: preempt read error", s);
    3c52:	85ca                	mv	a1,s2
    3c54:	00004517          	auipc	a0,0x4
    3c58:	f6c50513          	addi	a0,a0,-148 # 7bc0 <malloc+0x1d98>
    3c5c:	114020ef          	jal	5d70 <printf>
}
    3c60:	70e2                	ld	ra,56(sp)
    3c62:	7442                	ld	s0,48(sp)
    3c64:	74a2                	ld	s1,40(sp)
    3c66:	7902                	ld	s2,32(sp)
    3c68:	69e2                	ld	s3,24(sp)
    3c6a:	6a42                	ld	s4,16(sp)
    3c6c:	6121                	addi	sp,sp,64
    3c6e:	8082                	ret
  close(pfds[0]);
    3c70:	fc842503          	lw	a0,-56(s0)
    3c74:	4cf010ef          	jal	5942 <close>
  printf("kill... ");
    3c78:	00004517          	auipc	a0,0x4
    3c7c:	f6050513          	addi	a0,a0,-160 # 7bd8 <malloc+0x1db0>
    3c80:	0f0020ef          	jal	5d70 <printf>
  kill(pid1);
    3c84:	8526                	mv	a0,s1
    3c86:	4c5010ef          	jal	594a <kill>
  kill(pid2);
    3c8a:	854e                	mv	a0,s3
    3c8c:	4bf010ef          	jal	594a <kill>
  kill(pid3);
    3c90:	8552                	mv	a0,s4
    3c92:	4b9010ef          	jal	594a <kill>
  printf("wait... ");
    3c96:	00004517          	auipc	a0,0x4
    3c9a:	f5250513          	addi	a0,a0,-174 # 7be8 <malloc+0x1dc0>
    3c9e:	0d2020ef          	jal	5d70 <printf>
  wait(0);
    3ca2:	4501                	li	a0,0
    3ca4:	47f010ef          	jal	5922 <wait>
  wait(0);
    3ca8:	4501                	li	a0,0
    3caa:	479010ef          	jal	5922 <wait>
  wait(0);
    3cae:	4501                	li	a0,0
    3cb0:	473010ef          	jal	5922 <wait>
    3cb4:	b775                	j	3c60 <preempt+0xe6>

0000000000003cb6 <sbrkfail>:
{
    3cb6:	7175                	addi	sp,sp,-144
    3cb8:	e506                	sd	ra,136(sp)
    3cba:	e122                	sd	s0,128(sp)
    3cbc:	fca6                	sd	s1,120(sp)
    3cbe:	f8ca                	sd	s2,112(sp)
    3cc0:	f4ce                	sd	s3,104(sp)
    3cc2:	f0d2                	sd	s4,96(sp)
    3cc4:	ecd6                	sd	s5,88(sp)
    3cc6:	e8da                	sd	s6,80(sp)
    3cc8:	e4de                	sd	s7,72(sp)
    3cca:	e0e2                	sd	s8,64(sp)
    3ccc:	0900                	addi	s0,sp,144
    3cce:	8c2a                	mv	s8,a0
  if (pipe(fds) != 0) {
    3cd0:	fa040513          	addi	a0,s0,-96
    3cd4:	457010ef          	jal	592a <pipe>
    3cd8:	ed01                	bnez	a0,3cf0 <sbrkfail+0x3a>
    3cda:	8baa                	mv	s7,a0
    3cdc:	f7040493          	addi	s1,s0,-144
    3ce0:	f9840993          	addi	s3,s0,-104
    3ce4:	8926                	mv	s2,s1
    if (pids[i] != -1) {
    3ce6:	5a7d                	li	s4,-1
      read(fds[0], &scratch, 1);
    3ce8:	f9f40b13          	addi	s6,s0,-97
    3cec:	4a85                	li	s5,1
    3cee:	a095                	j	3d52 <sbrkfail+0x9c>
    printf("%s: pipe() failed\n", s);
    3cf0:	85e2                	mv	a1,s8
    3cf2:	00003517          	auipc	a0,0x3
    3cf6:	b7e50513          	addi	a0,a0,-1154 # 6870 <malloc+0xa48>
    3cfa:	076020ef          	jal	5d70 <printf>
    exit(1);
    3cfe:	4505                	li	a0,1
    3d00:	41b010ef          	jal	591a <exit>
      if (sbrk(BIG - (uint64)sbrk(0)) == (char *)SBRK_ERROR)
    3d04:	3e3010ef          	jal	58e6 <sbrk>
    3d08:	064007b7          	lui	a5,0x6400
    3d0c:	40a7853b          	subw	a0,a5,a0
    3d10:	3d7010ef          	jal	58e6 <sbrk>
    3d14:	57fd                	li	a5,-1
    3d16:	02f50163          	beq	a0,a5,3d38 <sbrkfail+0x82>
        write(fds[1], "1", 1);
    3d1a:	4605                	li	a2,1
    3d1c:	00005597          	auipc	a1,0x5
    3d20:	8c458593          	addi	a1,a1,-1852 # 85e0 <malloc+0x27b8>
    3d24:	fa442503          	lw	a0,-92(s0)
    3d28:	413010ef          	jal	593a <write>
        pause(1000);
    3d2c:	3e800493          	li	s1,1000
    3d30:	8526                	mv	a0,s1
    3d32:	479010ef          	jal	59aa <pause>
      for (;;)
    3d36:	bfed                	j	3d30 <sbrkfail+0x7a>
        write(fds[1], "0", 1);
    3d38:	4605                	li	a2,1
    3d3a:	00004597          	auipc	a1,0x4
    3d3e:	ebe58593          	addi	a1,a1,-322 # 7bf8 <malloc+0x1dd0>
    3d42:	fa442503          	lw	a0,-92(s0)
    3d46:	3f5010ef          	jal	593a <write>
    3d4a:	b7cd                	j	3d2c <sbrkfail+0x76>
  for (i = 0; i < sizeof(pids) / sizeof(pids[0]); i++) {
    3d4c:	0911                	addi	s2,s2,4
    3d4e:	03390a63          	beq	s2,s3,3d82 <sbrkfail+0xcc>
    if ((pids[i] = fork()) == 0) {
    3d52:	3c1010ef          	jal	5912 <fork>
    3d56:	00a92023          	sw	a0,0(s2)
    3d5a:	d54d                	beqz	a0,3d04 <sbrkfail+0x4e>
    if (pids[i] != -1) {
    3d5c:	ff4508e3          	beq	a0,s4,3d4c <sbrkfail+0x96>
      read(fds[0], &scratch, 1);
    3d60:	8656                	mv	a2,s5
    3d62:	85da                	mv	a1,s6
    3d64:	fa042503          	lw	a0,-96(s0)
    3d68:	3cb010ef          	jal	5932 <read>
      if (scratch == '0')
    3d6c:	f9f44783          	lbu	a5,-97(s0)
    3d70:	fd078793          	addi	a5,a5,-48 # 63fffd0 <base+0x63ee2c8>
    3d74:	0017b793          	seqz	a5,a5
    3d78:	00fbe7b3          	or	a5,s7,a5
    3d7c:	00078b9b          	sext.w	s7,a5
    3d80:	b7f1                	j	3d4c <sbrkfail+0x96>
  if (!failed) {
    3d82:	000b8863          	beqz	s7,3d92 <sbrkfail+0xdc>
  c = sbrk(PGSIZE);
    3d86:	6505                	lui	a0,0x1
    3d88:	35f010ef          	jal	58e6 <sbrk>
    3d8c:	8a2a                	mv	s4,a0
    if (pids[i] == -1)
    3d8e:	597d                	li	s2,-1
    3d90:	a821                	j	3da8 <sbrkfail+0xf2>
    printf("%s: no allocation failed; allocate more?\n", s);
    3d92:	85e2                	mv	a1,s8
    3d94:	00004517          	auipc	a0,0x4
    3d98:	e6c50513          	addi	a0,a0,-404 # 7c00 <malloc+0x1dd8>
    3d9c:	7d5010ef          	jal	5d70 <printf>
    3da0:	b7dd                	j	3d86 <sbrkfail+0xd0>
  for (i = 0; i < sizeof(pids) / sizeof(pids[0]); i++) {
    3da2:	0491                	addi	s1,s1,4
    3da4:	01348b63          	beq	s1,s3,3dba <sbrkfail+0x104>
    if (pids[i] == -1)
    3da8:	4088                	lw	a0,0(s1)
    3daa:	ff250ce3          	beq	a0,s2,3da2 <sbrkfail+0xec>
    kill(pids[i]);
    3dae:	39d010ef          	jal	594a <kill>
    wait(0);
    3db2:	4501                	li	a0,0
    3db4:	36f010ef          	jal	5922 <wait>
    3db8:	b7ed                	j	3da2 <sbrkfail+0xec>
  if (c == (char *)SBRK_ERROR) {
    3dba:	57fd                	li	a5,-1
    3dbc:	02fa0a63          	beq	s4,a5,3df0 <sbrkfail+0x13a>
  pid = fork();
    3dc0:	353010ef          	jal	5912 <fork>
  if (pid < 0) {
    3dc4:	04054063          	bltz	a0,3e04 <sbrkfail+0x14e>
  if (pid == 0) {
    3dc8:	e939                	bnez	a0,3e1e <sbrkfail+0x168>
    a = sbrk(10 * BIG);
    3dca:	3e800537          	lui	a0,0x3e800
    3dce:	319010ef          	jal	58e6 <sbrk>
    if (a == (char *)SBRK_ERROR) {
    3dd2:	57fd                	li	a5,-1
    3dd4:	04f50263          	beq	a0,a5,3e18 <sbrkfail+0x162>
    printf("%s: allocate a lot of memory succeeded %d\n", s, 10 * BIG);
    3dd8:	3e800637          	lui	a2,0x3e800
    3ddc:	85e2                	mv	a1,s8
    3dde:	00004517          	auipc	a0,0x4
    3de2:	e7250513          	addi	a0,a0,-398 # 7c50 <malloc+0x1e28>
    3de6:	78b010ef          	jal	5d70 <printf>
    exit(1);
    3dea:	4505                	li	a0,1
    3dec:	32f010ef          	jal	591a <exit>
    printf("%s: failed sbrk leaked memory\n", s);
    3df0:	85e2                	mv	a1,s8
    3df2:	00004517          	auipc	a0,0x4
    3df6:	e3e50513          	addi	a0,a0,-450 # 7c30 <malloc+0x1e08>
    3dfa:	777010ef          	jal	5d70 <printf>
    exit(1);
    3dfe:	4505                	li	a0,1
    3e00:	31b010ef          	jal	591a <exit>
    printf("%s: fork failed\n", s);
    3e04:	85e2                	mv	a1,s8
    3e06:	00003517          	auipc	a0,0x3
    3e0a:	9e250513          	addi	a0,a0,-1566 # 67e8 <malloc+0x9c0>
    3e0e:	763010ef          	jal	5d70 <printf>
    exit(1);
    3e12:	4505                	li	a0,1
    3e14:	307010ef          	jal	591a <exit>
      exit(0);
    3e18:	4501                	li	a0,0
    3e1a:	301010ef          	jal	591a <exit>
  wait(&xstatus);
    3e1e:	fac40513          	addi	a0,s0,-84
    3e22:	301010ef          	jal	5922 <wait>
  if (xstatus != 0)
    3e26:	fac42783          	lw	a5,-84(s0)
    3e2a:	ef89                	bnez	a5,3e44 <sbrkfail+0x18e>
}
    3e2c:	60aa                	ld	ra,136(sp)
    3e2e:	640a                	ld	s0,128(sp)
    3e30:	74e6                	ld	s1,120(sp)
    3e32:	7946                	ld	s2,112(sp)
    3e34:	79a6                	ld	s3,104(sp)
    3e36:	7a06                	ld	s4,96(sp)
    3e38:	6ae6                	ld	s5,88(sp)
    3e3a:	6b46                	ld	s6,80(sp)
    3e3c:	6ba6                	ld	s7,72(sp)
    3e3e:	6c06                	ld	s8,64(sp)
    3e40:	6149                	addi	sp,sp,144
    3e42:	8082                	ret
    exit(1);
    3e44:	4505                	li	a0,1
    3e46:	2d5010ef          	jal	591a <exit>

0000000000003e4a <killstatus>:
{
    3e4a:	715d                	addi	sp,sp,-80
    3e4c:	e486                	sd	ra,72(sp)
    3e4e:	e0a2                	sd	s0,64(sp)
    3e50:	fc26                	sd	s1,56(sp)
    3e52:	f84a                	sd	s2,48(sp)
    3e54:	f44e                	sd	s3,40(sp)
    3e56:	f052                	sd	s4,32(sp)
    3e58:	ec56                	sd	s5,24(sp)
    3e5a:	e85a                	sd	s6,16(sp)
    3e5c:	0880                	addi	s0,sp,80
    3e5e:	8b2a                	mv	s6,a0
    3e60:	06400913          	li	s2,100
    pause(1);
    3e64:	4a85                	li	s5,1
    wait(&xst);
    3e66:	fbc40a13          	addi	s4,s0,-68
    if (xst != -1) {
    3e6a:	59fd                	li	s3,-1
    int pid1 = fork();
    3e6c:	2a7010ef          	jal	5912 <fork>
    3e70:	84aa                	mv	s1,a0
    if (pid1 < 0) {
    3e72:	02054663          	bltz	a0,3e9e <killstatus+0x54>
    if (pid1 == 0) {
    3e76:	cd15                	beqz	a0,3eb2 <killstatus+0x68>
    pause(1);
    3e78:	8556                	mv	a0,s5
    3e7a:	331010ef          	jal	59aa <pause>
    kill(pid1);
    3e7e:	8526                	mv	a0,s1
    3e80:	2cb010ef          	jal	594a <kill>
    wait(&xst);
    3e84:	8552                	mv	a0,s4
    3e86:	29d010ef          	jal	5922 <wait>
    if (xst != -1) {
    3e8a:	fbc42783          	lw	a5,-68(s0)
    3e8e:	03379563          	bne	a5,s3,3eb8 <killstatus+0x6e>
  for (int i = 0; i < 100; i++) {
    3e92:	397d                	addiw	s2,s2,-1
    3e94:	fc091ce3          	bnez	s2,3e6c <killstatus+0x22>
  exit(0);
    3e98:	4501                	li	a0,0
    3e9a:	281010ef          	jal	591a <exit>
      printf("%s: fork failed\n", s);
    3e9e:	85da                	mv	a1,s6
    3ea0:	00003517          	auipc	a0,0x3
    3ea4:	94850513          	addi	a0,a0,-1720 # 67e8 <malloc+0x9c0>
    3ea8:	6c9010ef          	jal	5d70 <printf>
      exit(1);
    3eac:	4505                	li	a0,1
    3eae:	26d010ef          	jal	591a <exit>
        getpid();
    3eb2:	2e9010ef          	jal	599a <getpid>
      while (1) {
    3eb6:	bff5                	j	3eb2 <killstatus+0x68>
      printf("%s: status should be -1\n", s);
    3eb8:	85da                	mv	a1,s6
    3eba:	00004517          	auipc	a0,0x4
    3ebe:	dc650513          	addi	a0,a0,-570 # 7c80 <malloc+0x1e58>
    3ec2:	6af010ef          	jal	5d70 <printf>
      exit(1);
    3ec6:	4505                	li	a0,1
    3ec8:	253010ef          	jal	591a <exit>

0000000000003ecc <reparent>:
{
    3ecc:	7179                	addi	sp,sp,-48
    3ece:	f406                	sd	ra,40(sp)
    3ed0:	f022                	sd	s0,32(sp)
    3ed2:	ec26                	sd	s1,24(sp)
    3ed4:	e84a                	sd	s2,16(sp)
    3ed6:	e44e                	sd	s3,8(sp)
    3ed8:	e052                	sd	s4,0(sp)
    3eda:	1800                	addi	s0,sp,48
    3edc:	89aa                	mv	s3,a0
  int master_pid = getpid();
    3ede:	2bd010ef          	jal	599a <getpid>
    3ee2:	8a2a                	mv	s4,a0
    3ee4:	0c800913          	li	s2,200
    int pid = fork();
    3ee8:	22b010ef          	jal	5912 <fork>
    3eec:	84aa                	mv	s1,a0
    if (pid < 0) {
    3eee:	00054e63          	bltz	a0,3f0a <reparent+0x3e>
    if (pid) {
    3ef2:	c121                	beqz	a0,3f32 <reparent+0x66>
      if (wait(0) != pid) {
    3ef4:	4501                	li	a0,0
    3ef6:	22d010ef          	jal	5922 <wait>
    3efa:	02951263          	bne	a0,s1,3f1e <reparent+0x52>
  for (int i = 0; i < 200; i++) {
    3efe:	397d                	addiw	s2,s2,-1
    3f00:	fe0914e3          	bnez	s2,3ee8 <reparent+0x1c>
  exit(0);
    3f04:	4501                	li	a0,0
    3f06:	215010ef          	jal	591a <exit>
      printf("%s: fork failed\n", s);
    3f0a:	85ce                	mv	a1,s3
    3f0c:	00003517          	auipc	a0,0x3
    3f10:	8dc50513          	addi	a0,a0,-1828 # 67e8 <malloc+0x9c0>
    3f14:	65d010ef          	jal	5d70 <printf>
      exit(1);
    3f18:	4505                	li	a0,1
    3f1a:	201010ef          	jal	591a <exit>
        printf("%s: wait wrong pid\n", s);
    3f1e:	85ce                	mv	a1,s3
    3f20:	00003517          	auipc	a0,0x3
    3f24:	9d050513          	addi	a0,a0,-1584 # 68f0 <malloc+0xac8>
    3f28:	649010ef          	jal	5d70 <printf>
        exit(1);
    3f2c:	4505                	li	a0,1
    3f2e:	1ed010ef          	jal	591a <exit>
      int pid2 = fork();
    3f32:	1e1010ef          	jal	5912 <fork>
      if (pid2 < 0) {
    3f36:	00054563          	bltz	a0,3f40 <reparent+0x74>
      exit(0);
    3f3a:	4501                	li	a0,0
    3f3c:	1df010ef          	jal	591a <exit>
        kill(master_pid);
    3f40:	8552                	mv	a0,s4
    3f42:	209010ef          	jal	594a <kill>
        exit(1);
    3f46:	4505                	li	a0,1
    3f48:	1d3010ef          	jal	591a <exit>

0000000000003f4c <mem>:
{
    3f4c:	7139                	addi	sp,sp,-64
    3f4e:	fc06                	sd	ra,56(sp)
    3f50:	f822                	sd	s0,48(sp)
    3f52:	f426                	sd	s1,40(sp)
    3f54:	f04a                	sd	s2,32(sp)
    3f56:	ec4e                	sd	s3,24(sp)
    3f58:	0080                	addi	s0,sp,64
    3f5a:	89aa                	mv	s3,a0
  if ((pid = fork()) == 0) {
    3f5c:	1b7010ef          	jal	5912 <fork>
    m1 = 0;
    3f60:	4481                	li	s1,0
    while ((m2 = malloc(10001)) != 0) {
    3f62:	6909                	lui	s2,0x2
    3f64:	71190913          	addi	s2,s2,1809 # 2711 <fourteen+0xed>
  if ((pid = fork()) == 0) {
    3f68:	cd11                	beqz	a0,3f84 <mem+0x38>
    wait(&xstatus);
    3f6a:	fcc40513          	addi	a0,s0,-52
    3f6e:	1b5010ef          	jal	5922 <wait>
    if (xstatus == -1) {
    3f72:	fcc42503          	lw	a0,-52(s0)
    3f76:	57fd                	li	a5,-1
    3f78:	04f50363          	beq	a0,a5,3fbe <mem+0x72>
    exit(xstatus);
    3f7c:	19f010ef          	jal	591a <exit>
      *(char **)m2 = m1;
    3f80:	e104                	sd	s1,0(a0)
      m1 = m2;
    3f82:	84aa                	mv	s1,a0
    while ((m2 = malloc(10001)) != 0) {
    3f84:	854a                	mv	a0,s2
    3f86:	6a3010ef          	jal	5e28 <malloc>
    3f8a:	f97d                	bnez	a0,3f80 <mem+0x34>
    while (m1) {
    3f8c:	c491                	beqz	s1,3f98 <mem+0x4c>
      m2 = *(char **)m1;
    3f8e:	8526                	mv	a0,s1
    3f90:	6084                	ld	s1,0(s1)
      free(m1);
    3f92:	611010ef          	jal	5da2 <free>
    while (m1) {
    3f96:	fce5                	bnez	s1,3f8e <mem+0x42>
    m1 = malloc(1024 * 20);
    3f98:	6515                	lui	a0,0x5
    3f9a:	68f010ef          	jal	5e28 <malloc>
    if (m1 == 0) {
    3f9e:	c511                	beqz	a0,3faa <mem+0x5e>
    free(m1);
    3fa0:	603010ef          	jal	5da2 <free>
    exit(0);
    3fa4:	4501                	li	a0,0
    3fa6:	175010ef          	jal	591a <exit>
      printf("%s: couldn't allocate mem?!!\n", s);
    3faa:	85ce                	mv	a1,s3
    3fac:	00004517          	auipc	a0,0x4
    3fb0:	cf450513          	addi	a0,a0,-780 # 7ca0 <malloc+0x1e78>
    3fb4:	5bd010ef          	jal	5d70 <printf>
      exit(1);
    3fb8:	4505                	li	a0,1
    3fba:	161010ef          	jal	591a <exit>
      exit(0);
    3fbe:	4501                	li	a0,0
    3fc0:	15b010ef          	jal	591a <exit>

0000000000003fc4 <sharedfd>:
{
    3fc4:	7159                	addi	sp,sp,-112
    3fc6:	f486                	sd	ra,104(sp)
    3fc8:	f0a2                	sd	s0,96(sp)
    3fca:	eca6                	sd	s1,88(sp)
    3fcc:	f85a                	sd	s6,48(sp)
    3fce:	1880                	addi	s0,sp,112
    3fd0:	84aa                	mv	s1,a0
    3fd2:	8b2a                	mv	s6,a0
  unlink("sharedfd");
    3fd4:	00004517          	auipc	a0,0x4
    3fd8:	cec50513          	addi	a0,a0,-788 # 7cc0 <malloc+0x1e98>
    3fdc:	18f010ef          	jal	596a <unlink>
  fd = open("sharedfd", O_CREATE | O_RDWR);
    3fe0:	20200593          	li	a1,514
    3fe4:	00004517          	auipc	a0,0x4
    3fe8:	cdc50513          	addi	a0,a0,-804 # 7cc0 <malloc+0x1e98>
    3fec:	16f010ef          	jal	595a <open>
  if (fd < 0) {
    3ff0:	04054863          	bltz	a0,4040 <sharedfd+0x7c>
    3ff4:	e8ca                	sd	s2,80(sp)
    3ff6:	e4ce                	sd	s3,72(sp)
    3ff8:	e0d2                	sd	s4,64(sp)
    3ffa:	fc56                	sd	s5,56(sp)
    3ffc:	89aa                	mv	s3,a0
  pid = fork();
    3ffe:	115010ef          	jal	5912 <fork>
    4002:	8aaa                	mv	s5,a0
  memset(buf, pid == 0 ? 'c' : 'p', sizeof(buf));
    4004:	07000593          	li	a1,112
    4008:	e119                	bnez	a0,400e <sharedfd+0x4a>
    400a:	06300593          	li	a1,99
    400e:	4629                	li	a2,10
    4010:	fa040513          	addi	a0,s0,-96
    4014:	6dc010ef          	jal	56f0 <memset>
    4018:	3e800493          	li	s1,1000
    if (write(fd, buf, sizeof(buf)) != sizeof(buf)) {
    401c:	fa040a13          	addi	s4,s0,-96
    4020:	4929                	li	s2,10
    4022:	864a                	mv	a2,s2
    4024:	85d2                	mv	a1,s4
    4026:	854e                	mv	a0,s3
    4028:	113010ef          	jal	593a <write>
    402c:	03251963          	bne	a0,s2,405e <sharedfd+0x9a>
  for (i = 0; i < N; i++) {
    4030:	34fd                	addiw	s1,s1,-1
    4032:	f8e5                	bnez	s1,4022 <sharedfd+0x5e>
  if (pid == 0) {
    4034:	040a9063          	bnez	s5,4074 <sharedfd+0xb0>
    4038:	f45e                	sd	s7,40(sp)
    exit(0);
    403a:	4501                	li	a0,0
    403c:	0df010ef          	jal	591a <exit>
    4040:	e8ca                	sd	s2,80(sp)
    4042:	e4ce                	sd	s3,72(sp)
    4044:	e0d2                	sd	s4,64(sp)
    4046:	fc56                	sd	s5,56(sp)
    4048:	f45e                	sd	s7,40(sp)
    printf("%s: cannot open sharedfd for writing", s);
    404a:	85a6                	mv	a1,s1
    404c:	00004517          	auipc	a0,0x4
    4050:	c8450513          	addi	a0,a0,-892 # 7cd0 <malloc+0x1ea8>
    4054:	51d010ef          	jal	5d70 <printf>
    exit(1);
    4058:	4505                	li	a0,1
    405a:	0c1010ef          	jal	591a <exit>
    405e:	f45e                	sd	s7,40(sp)
      printf("%s: write sharedfd failed\n", s);
    4060:	85da                	mv	a1,s6
    4062:	00004517          	auipc	a0,0x4
    4066:	c9650513          	addi	a0,a0,-874 # 7cf8 <malloc+0x1ed0>
    406a:	507010ef          	jal	5d70 <printf>
      exit(1);
    406e:	4505                	li	a0,1
    4070:	0ab010ef          	jal	591a <exit>
    wait(&xstatus);
    4074:	f9c40513          	addi	a0,s0,-100
    4078:	0ab010ef          	jal	5922 <wait>
    if (xstatus != 0)
    407c:	f9c42a03          	lw	s4,-100(s0)
    4080:	000a0663          	beqz	s4,408c <sharedfd+0xc8>
    4084:	f45e                	sd	s7,40(sp)
      exit(xstatus);
    4086:	8552                	mv	a0,s4
    4088:	093010ef          	jal	591a <exit>
    408c:	f45e                	sd	s7,40(sp)
  close(fd);
    408e:	854e                	mv	a0,s3
    4090:	0b3010ef          	jal	5942 <close>
  fd = open("sharedfd", 0);
    4094:	4581                	li	a1,0
    4096:	00004517          	auipc	a0,0x4
    409a:	c2a50513          	addi	a0,a0,-982 # 7cc0 <malloc+0x1e98>
    409e:	0bd010ef          	jal	595a <open>
    40a2:	8baa                	mv	s7,a0
  nc = np = 0;
    40a4:	89d2                	mv	s3,s4
  if (fd < 0) {
    40a6:	02054363          	bltz	a0,40cc <sharedfd+0x108>
    40aa:	faa40913          	addi	s2,s0,-86
      if (buf[i] == 'c')
    40ae:	06300493          	li	s1,99
      if (buf[i] == 'p')
    40b2:	07000a93          	li	s5,112
  while ((n = read(fd, buf, sizeof(buf))) > 0) {
    40b6:	4629                	li	a2,10
    40b8:	fa040593          	addi	a1,s0,-96
    40bc:	855e                	mv	a0,s7
    40be:	075010ef          	jal	5932 <read>
    40c2:	02a05b63          	blez	a0,40f8 <sharedfd+0x134>
    40c6:	fa040793          	addi	a5,s0,-96
    40ca:	a839                	j	40e8 <sharedfd+0x124>
    printf("%s: cannot open sharedfd for reading\n", s);
    40cc:	85da                	mv	a1,s6
    40ce:	00004517          	auipc	a0,0x4
    40d2:	c4a50513          	addi	a0,a0,-950 # 7d18 <malloc+0x1ef0>
    40d6:	49b010ef          	jal	5d70 <printf>
    exit(1);
    40da:	4505                	li	a0,1
    40dc:	03f010ef          	jal	591a <exit>
        nc++;
    40e0:	2a05                	addiw	s4,s4,1
    for (i = 0; i < sizeof(buf); i++) {
    40e2:	0785                	addi	a5,a5,1
    40e4:	fd2789e3          	beq	a5,s2,40b6 <sharedfd+0xf2>
      if (buf[i] == 'c')
    40e8:	0007c703          	lbu	a4,0(a5)
    40ec:	fe970ae3          	beq	a4,s1,40e0 <sharedfd+0x11c>
      if (buf[i] == 'p')
    40f0:	ff5719e3          	bne	a4,s5,40e2 <sharedfd+0x11e>
        np++;
    40f4:	2985                	addiw	s3,s3,1
    40f6:	b7f5                	j	40e2 <sharedfd+0x11e>
  close(fd);
    40f8:	855e                	mv	a0,s7
    40fa:	049010ef          	jal	5942 <close>
  unlink("sharedfd");
    40fe:	00004517          	auipc	a0,0x4
    4102:	bc250513          	addi	a0,a0,-1086 # 7cc0 <malloc+0x1e98>
    4106:	065010ef          	jal	596a <unlink>
  if (nc == N * SZ && np == N * SZ) {
    410a:	6789                	lui	a5,0x2
    410c:	71078793          	addi	a5,a5,1808 # 2710 <fourteen+0xec>
    4110:	00fa1763          	bne	s4,a5,411e <sharedfd+0x15a>
    4114:	01499563          	bne	s3,s4,411e <sharedfd+0x15a>
    exit(0);
    4118:	4501                	li	a0,0
    411a:	001010ef          	jal	591a <exit>
    printf("%s: nc/np test fails\n", s);
    411e:	85da                	mv	a1,s6
    4120:	00004517          	auipc	a0,0x4
    4124:	c2050513          	addi	a0,a0,-992 # 7d40 <malloc+0x1f18>
    4128:	449010ef          	jal	5d70 <printf>
    exit(1);
    412c:	4505                	li	a0,1
    412e:	7ec010ef          	jal	591a <exit>

0000000000004132 <fourfiles>:
{
    4132:	7135                	addi	sp,sp,-160
    4134:	ed06                	sd	ra,152(sp)
    4136:	e922                	sd	s0,144(sp)
    4138:	e526                	sd	s1,136(sp)
    413a:	e14a                	sd	s2,128(sp)
    413c:	fcce                	sd	s3,120(sp)
    413e:	f8d2                	sd	s4,112(sp)
    4140:	f4d6                	sd	s5,104(sp)
    4142:	f0da                	sd	s6,96(sp)
    4144:	ecde                	sd	s7,88(sp)
    4146:	e8e2                	sd	s8,80(sp)
    4148:	e4e6                	sd	s9,72(sp)
    414a:	e0ea                	sd	s10,64(sp)
    414c:	fc6e                	sd	s11,56(sp)
    414e:	1100                	addi	s0,sp,160
    4150:	8caa                	mv	s9,a0
  char *names[] = {"f0", "f1", "f2", "f3"};
    4152:	00004797          	auipc	a5,0x4
    4156:	c0678793          	addi	a5,a5,-1018 # 7d58 <malloc+0x1f30>
    415a:	f6f43823          	sd	a5,-144(s0)
    415e:	00004797          	auipc	a5,0x4
    4162:	c0278793          	addi	a5,a5,-1022 # 7d60 <malloc+0x1f38>
    4166:	f6f43c23          	sd	a5,-136(s0)
    416a:	00004797          	auipc	a5,0x4
    416e:	bfe78793          	addi	a5,a5,-1026 # 7d68 <malloc+0x1f40>
    4172:	f8f43023          	sd	a5,-128(s0)
    4176:	00004797          	auipc	a5,0x4
    417a:	bfa78793          	addi	a5,a5,-1030 # 7d70 <malloc+0x1f48>
    417e:	f8f43423          	sd	a5,-120(s0)
  for (pi = 0; pi < NCHILD; pi++) {
    4182:	f7040b93          	addi	s7,s0,-144
  char *names[] = {"f0", "f1", "f2", "f3"};
    4186:	895e                	mv	s2,s7
  for (pi = 0; pi < NCHILD; pi++) {
    4188:	4481                	li	s1,0
    418a:	4a11                	li	s4,4
    fname = names[pi];
    418c:	00093983          	ld	s3,0(s2)
    unlink(fname);
    4190:	854e                	mv	a0,s3
    4192:	7d8010ef          	jal	596a <unlink>
    pid = fork();
    4196:	77c010ef          	jal	5912 <fork>
    if (pid < 0) {
    419a:	04054063          	bltz	a0,41da <fourfiles+0xa8>
    if (pid == 0) {
    419e:	c921                	beqz	a0,41ee <fourfiles+0xbc>
  for (pi = 0; pi < NCHILD; pi++) {
    41a0:	2485                	addiw	s1,s1,1
    41a2:	0921                	addi	s2,s2,8
    41a4:	ff4494e3          	bne	s1,s4,418c <fourfiles+0x5a>
    41a8:	4491                	li	s1,4
    wait(&xstatus);
    41aa:	f6c40913          	addi	s2,s0,-148
    41ae:	854a                	mv	a0,s2
    41b0:	772010ef          	jal	5922 <wait>
    if (xstatus != 0)
    41b4:	f6c42b03          	lw	s6,-148(s0)
    41b8:	0a0b1463          	bnez	s6,4260 <fourfiles+0x12e>
  for (pi = 0; pi < NCHILD; pi++) {
    41bc:	34fd                	addiw	s1,s1,-1
    41be:	f8e5                	bnez	s1,41ae <fourfiles+0x7c>
    41c0:	03000493          	li	s1,48
    while ((n = read(fd, buf, sizeof(buf))) > 0) {
    41c4:	6a8d                	lui	s5,0x3
    41c6:	0000ba17          	auipc	s4,0xb
    41ca:	b42a0a13          	addi	s4,s4,-1214 # ed08 <buf>
    if (total != N * SZ) {
    41ce:	6d05                	lui	s10,0x1
    41d0:	770d0d13          	addi	s10,s10,1904 # 1770 <createdelete+0x20>
  for (i = 0; i < NCHILD; i++) {
    41d4:	03400d93          	li	s11,52
    41d8:	a86d                	j	4292 <fourfiles+0x160>
      printf("%s: fork failed\n", s);
    41da:	85e6                	mv	a1,s9
    41dc:	00002517          	auipc	a0,0x2
    41e0:	60c50513          	addi	a0,a0,1548 # 67e8 <malloc+0x9c0>
    41e4:	38d010ef          	jal	5d70 <printf>
      exit(1);
    41e8:	4505                	li	a0,1
    41ea:	730010ef          	jal	591a <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    41ee:	20200593          	li	a1,514
    41f2:	854e                	mv	a0,s3
    41f4:	766010ef          	jal	595a <open>
    41f8:	892a                	mv	s2,a0
      if (fd < 0) {
    41fa:	04054063          	bltz	a0,423a <fourfiles+0x108>
      memset(buf, '0' + pi, SZ);
    41fe:	1f400613          	li	a2,500
    4202:	0304859b          	addiw	a1,s1,48
    4206:	0000b517          	auipc	a0,0xb
    420a:	b0250513          	addi	a0,a0,-1278 # ed08 <buf>
    420e:	4e2010ef          	jal	56f0 <memset>
    4212:	44b1                	li	s1,12
        if ((n = write(fd, buf, SZ)) != SZ) {
    4214:	1f400993          	li	s3,500
    4218:	0000ba17          	auipc	s4,0xb
    421c:	af0a0a13          	addi	s4,s4,-1296 # ed08 <buf>
    4220:	864e                	mv	a2,s3
    4222:	85d2                	mv	a1,s4
    4224:	854a                	mv	a0,s2
    4226:	714010ef          	jal	593a <write>
    422a:	85aa                	mv	a1,a0
    422c:	03351163          	bne	a0,s3,424e <fourfiles+0x11c>
      for (i = 0; i < N; i++) {
    4230:	34fd                	addiw	s1,s1,-1
    4232:	f4fd                	bnez	s1,4220 <fourfiles+0xee>
      exit(0);
    4234:	4501                	li	a0,0
    4236:	6e4010ef          	jal	591a <exit>
        printf("%s: create failed\n", s);
    423a:	85e6                	mv	a1,s9
    423c:	00002517          	auipc	a0,0x2
    4240:	71c50513          	addi	a0,a0,1820 # 6958 <malloc+0xb30>
    4244:	32d010ef          	jal	5d70 <printf>
        exit(1);
    4248:	4505                	li	a0,1
    424a:	6d0010ef          	jal	591a <exit>
          printf("write failed %d\n", n);
    424e:	00004517          	auipc	a0,0x4
    4252:	b2a50513          	addi	a0,a0,-1238 # 7d78 <malloc+0x1f50>
    4256:	31b010ef          	jal	5d70 <printf>
          exit(1);
    425a:	4505                	li	a0,1
    425c:	6be010ef          	jal	591a <exit>
      exit(xstatus);
    4260:	855a                	mv	a0,s6
    4262:	6b8010ef          	jal	591a <exit>
          printf("%s: wrong char\n", s);
    4266:	85e6                	mv	a1,s9
    4268:	00004517          	auipc	a0,0x4
    426c:	b2850513          	addi	a0,a0,-1240 # 7d90 <malloc+0x1f68>
    4270:	301010ef          	jal	5d70 <printf>
          exit(1);
    4274:	4505                	li	a0,1
    4276:	6a4010ef          	jal	591a <exit>
    close(fd);
    427a:	854e                	mv	a0,s3
    427c:	6c6010ef          	jal	5942 <close>
    if (total != N * SZ) {
    4280:	05a91863          	bne	s2,s10,42d0 <fourfiles+0x19e>
    unlink(fname);
    4284:	8562                	mv	a0,s8
    4286:	6e4010ef          	jal	596a <unlink>
  for (i = 0; i < NCHILD; i++) {
    428a:	0ba1                	addi	s7,s7,8
    428c:	2485                	addiw	s1,s1,1
    428e:	05b48b63          	beq	s1,s11,42e4 <fourfiles+0x1b2>
    fname = names[i];
    4292:	000bbc03          	ld	s8,0(s7)
    fd = open(fname, 0);
    4296:	4581                	li	a1,0
    4298:	8562                	mv	a0,s8
    429a:	6c0010ef          	jal	595a <open>
    429e:	89aa                	mv	s3,a0
    total = 0;
    42a0:	895a                	mv	s2,s6
    while ((n = read(fd, buf, sizeof(buf))) > 0) {
    42a2:	8656                	mv	a2,s5
    42a4:	85d2                	mv	a1,s4
    42a6:	854e                	mv	a0,s3
    42a8:	68a010ef          	jal	5932 <read>
    42ac:	fca057e3          	blez	a0,427a <fourfiles+0x148>
    42b0:	0000b797          	auipc	a5,0xb
    42b4:	a5878793          	addi	a5,a5,-1448 # ed08 <buf>
    42b8:	00f506b3          	add	a3,a0,a5
        if (buf[j] != '0' + i) {
    42bc:	0007c703          	lbu	a4,0(a5)
    42c0:	fa9713e3          	bne	a4,s1,4266 <fourfiles+0x134>
      for (j = 0; j < n; j++) {
    42c4:	0785                	addi	a5,a5,1
    42c6:	fed79be3          	bne	a5,a3,42bc <fourfiles+0x18a>
      total += n;
    42ca:	00a9093b          	addw	s2,s2,a0
    42ce:	bfd1                	j	42a2 <fourfiles+0x170>
      printf("wrong length %d\n", total);
    42d0:	85ca                	mv	a1,s2
    42d2:	00004517          	auipc	a0,0x4
    42d6:	ace50513          	addi	a0,a0,-1330 # 7da0 <malloc+0x1f78>
    42da:	297010ef          	jal	5d70 <printf>
      exit(1);
    42de:	4505                	li	a0,1
    42e0:	63a010ef          	jal	591a <exit>
}
    42e4:	60ea                	ld	ra,152(sp)
    42e6:	644a                	ld	s0,144(sp)
    42e8:	64aa                	ld	s1,136(sp)
    42ea:	690a                	ld	s2,128(sp)
    42ec:	79e6                	ld	s3,120(sp)
    42ee:	7a46                	ld	s4,112(sp)
    42f0:	7aa6                	ld	s5,104(sp)
    42f2:	7b06                	ld	s6,96(sp)
    42f4:	6be6                	ld	s7,88(sp)
    42f6:	6c46                	ld	s8,80(sp)
    42f8:	6ca6                	ld	s9,72(sp)
    42fa:	6d06                	ld	s10,64(sp)
    42fc:	7de2                	ld	s11,56(sp)
    42fe:	610d                	addi	sp,sp,160
    4300:	8082                	ret

0000000000004302 <concreate>:
{
    4302:	7171                	addi	sp,sp,-176
    4304:	f506                	sd	ra,168(sp)
    4306:	f122                	sd	s0,160(sp)
    4308:	ed26                	sd	s1,152(sp)
    430a:	e94a                	sd	s2,144(sp)
    430c:	e54e                	sd	s3,136(sp)
    430e:	e152                	sd	s4,128(sp)
    4310:	fcd6                	sd	s5,120(sp)
    4312:	f8da                	sd	s6,112(sp)
    4314:	f4de                	sd	s7,104(sp)
    4316:	f0e2                	sd	s8,96(sp)
    4318:	ece6                	sd	s9,88(sp)
    431a:	e8ea                	sd	s10,80(sp)
    431c:	1900                	addi	s0,sp,176
    431e:	8d2a                	mv	s10,a0
  file[0] = 'C';
    4320:	04300793          	li	a5,67
    4324:	f8f40c23          	sb	a5,-104(s0)
  file[2] = '\0';
    4328:	f8040d23          	sb	zero,-102(s0)
  for (i = 0; i < N; i++) {
    432c:	4901                	li	s2,0
    unlink(file);
    432e:	f9840993          	addi	s3,s0,-104
    if (pid && (i % 3) == 1) {
    4332:	55555b37          	lui	s6,0x55555
    4336:	556b0b13          	addi	s6,s6,1366 # 55555556 <base+0x5554384e>
    433a:	4b85                	li	s7,1
      fd = open(file, O_CREATE | O_RDWR);
    433c:	20200c13          	li	s8,514
      link("C0", file);
    4340:	00004c97          	auipc	s9,0x4
    4344:	a78c8c93          	addi	s9,s9,-1416 # 7db8 <malloc+0x1f90>
      wait(&xstatus);
    4348:	f5c40a93          	addi	s5,s0,-164
  for (i = 0; i < N; i++) {
    434c:	02800a13          	li	s4,40
    4350:	ac25                	j	4588 <concreate+0x286>
      link("C0", file);
    4352:	85ce                	mv	a1,s3
    4354:	8566                	mv	a0,s9
    4356:	624010ef          	jal	597a <link>
    if (pid == 0) {
    435a:	ac29                	j	4574 <concreate+0x272>
    } else if (pid == 0 && (i % 5) == 1) {
    435c:	666667b7          	lui	a5,0x66666
    4360:	66778793          	addi	a5,a5,1639 # 66666667 <base+0x6665495f>
    4364:	02f907b3          	mul	a5,s2,a5
    4368:	9785                	srai	a5,a5,0x21
    436a:	41f9571b          	sraiw	a4,s2,0x1f
    436e:	9f99                	subw	a5,a5,a4
    4370:	0027971b          	slliw	a4,a5,0x2
    4374:	9fb9                	addw	a5,a5,a4
    4376:	40f9093b          	subw	s2,s2,a5
    437a:	4785                	li	a5,1
    437c:	02f90563          	beq	s2,a5,43a6 <concreate+0xa4>
      fd = open(file, O_CREATE | O_RDWR);
    4380:	20200593          	li	a1,514
    4384:	f9840513          	addi	a0,s0,-104
    4388:	5d2010ef          	jal	595a <open>
      if (fd < 0) {
    438c:	1c055f63          	bgez	a0,456a <concreate+0x268>
        printf("concreate create %s failed\n", file);
    4390:	f9840593          	addi	a1,s0,-104
    4394:	00004517          	auipc	a0,0x4
    4398:	a2c50513          	addi	a0,a0,-1492 # 7dc0 <malloc+0x1f98>
    439c:	1d5010ef          	jal	5d70 <printf>
        exit(1);
    43a0:	4505                	li	a0,1
    43a2:	578010ef          	jal	591a <exit>
      link("C0", file);
    43a6:	f9840593          	addi	a1,s0,-104
    43aa:	00004517          	auipc	a0,0x4
    43ae:	a0e50513          	addi	a0,a0,-1522 # 7db8 <malloc+0x1f90>
    43b2:	5c8010ef          	jal	597a <link>
      exit(0);
    43b6:	4501                	li	a0,0
    43b8:	562010ef          	jal	591a <exit>
        exit(1);
    43bc:	4505                	li	a0,1
    43be:	55c010ef          	jal	591a <exit>
  memset(fa, 0, sizeof(fa));
    43c2:	02800613          	li	a2,40
    43c6:	4581                	li	a1,0
    43c8:	f7040513          	addi	a0,s0,-144
    43cc:	324010ef          	jal	56f0 <memset>
  fd = open(".", 0);
    43d0:	4581                	li	a1,0
    43d2:	00002517          	auipc	a0,0x2
    43d6:	26e50513          	addi	a0,a0,622 # 6640 <malloc+0x818>
    43da:	580010ef          	jal	595a <open>
    43de:	892a                	mv	s2,a0
  n = 0;
    43e0:	8b26                	mv	s6,s1
  while (read(fd, &de, sizeof(de)) > 0) {
    43e2:	f6040a13          	addi	s4,s0,-160
    43e6:	49c1                	li	s3,16
    if (de.name[0] == 'C' && de.name[2] == '\0') {
    43e8:	04300a93          	li	s5,67
      if (i < 0 || i >= sizeof(fa)) {
    43ec:	02700b93          	li	s7,39
      fa[i] = 1;
    43f0:	4c05                	li	s8,1
  while (read(fd, &de, sizeof(de)) > 0) {
    43f2:	864e                	mv	a2,s3
    43f4:	85d2                	mv	a1,s4
    43f6:	854a                	mv	a0,s2
    43f8:	53a010ef          	jal	5932 <read>
    43fc:	06a05763          	blez	a0,446a <concreate+0x168>
    if (de.inum == 0)
    4400:	f6045783          	lhu	a5,-160(s0)
    4404:	d7fd                	beqz	a5,43f2 <concreate+0xf0>
    if (de.name[0] == 'C' && de.name[2] == '\0') {
    4406:	f6244783          	lbu	a5,-158(s0)
    440a:	ff5794e3          	bne	a5,s5,43f2 <concreate+0xf0>
    440e:	f6444783          	lbu	a5,-156(s0)
    4412:	f3e5                	bnez	a5,43f2 <concreate+0xf0>
      i = de.name[1] - '0';
    4414:	f6344783          	lbu	a5,-157(s0)
    4418:	fd07879b          	addiw	a5,a5,-48
      if (i < 0 || i >= sizeof(fa)) {
    441c:	00fbef63          	bltu	s7,a5,443a <concreate+0x138>
      if (fa[i]) {
    4420:	fa078713          	addi	a4,a5,-96
    4424:	9722                	add	a4,a4,s0
    4426:	fd074703          	lbu	a4,-48(a4)
    442a:	e705                	bnez	a4,4452 <concreate+0x150>
      fa[i] = 1;
    442c:	fa078793          	addi	a5,a5,-96
    4430:	97a2                	add	a5,a5,s0
    4432:	fd878823          	sb	s8,-48(a5)
      n++;
    4436:	2b05                	addiw	s6,s6,1
    4438:	bf6d                	j	43f2 <concreate+0xf0>
        printf("%s: concreate weird file %s\n", s, de.name);
    443a:	f6240613          	addi	a2,s0,-158
    443e:	85ea                	mv	a1,s10
    4440:	00004517          	auipc	a0,0x4
    4444:	9a050513          	addi	a0,a0,-1632 # 7de0 <malloc+0x1fb8>
    4448:	129010ef          	jal	5d70 <printf>
        exit(1);
    444c:	4505                	li	a0,1
    444e:	4cc010ef          	jal	591a <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    4452:	f6240613          	addi	a2,s0,-158
    4456:	85ea                	mv	a1,s10
    4458:	00004517          	auipc	a0,0x4
    445c:	9a850513          	addi	a0,a0,-1624 # 7e00 <malloc+0x1fd8>
    4460:	111010ef          	jal	5d70 <printf>
        exit(1);
    4464:	4505                	li	a0,1
    4466:	4b4010ef          	jal	591a <exit>
  close(fd);
    446a:	854a                	mv	a0,s2
    446c:	4d6010ef          	jal	5942 <close>
  if (n != N) {
    4470:	02800793          	li	a5,40
    4474:	00fb1a63          	bne	s6,a5,4488 <concreate+0x186>
    if (((i % 3) == 0 && pid == 0) || ((i % 3) == 1 && pid != 0)) {
    4478:	55555a37          	lui	s4,0x55555
    447c:	556a0a13          	addi	s4,s4,1366 # 55555556 <base+0x5554384e>
      close(open(file, 0));
    4480:	f9840993          	addi	s3,s0,-104
  for (i = 0; i < N; i++) {
    4484:	8ada                	mv	s5,s6
    4486:	a049                	j	4508 <concreate+0x206>
    printf("%s: concreate not enough files in directory listing\n", s);
    4488:	85ea                	mv	a1,s10
    448a:	00004517          	auipc	a0,0x4
    448e:	99e50513          	addi	a0,a0,-1634 # 7e28 <malloc+0x2000>
    4492:	0df010ef          	jal	5d70 <printf>
    exit(1);
    4496:	4505                	li	a0,1
    4498:	482010ef          	jal	591a <exit>
      printf("%s: fork failed\n", s);
    449c:	85ea                	mv	a1,s10
    449e:	00002517          	auipc	a0,0x2
    44a2:	34a50513          	addi	a0,a0,842 # 67e8 <malloc+0x9c0>
    44a6:	0cb010ef          	jal	5d70 <printf>
      exit(1);
    44aa:	4505                	li	a0,1
    44ac:	46e010ef          	jal	591a <exit>
      close(open(file, 0));
    44b0:	4581                	li	a1,0
    44b2:	854e                	mv	a0,s3
    44b4:	4a6010ef          	jal	595a <open>
    44b8:	48a010ef          	jal	5942 <close>
      close(open(file, 0));
    44bc:	4581                	li	a1,0
    44be:	854e                	mv	a0,s3
    44c0:	49a010ef          	jal	595a <open>
    44c4:	47e010ef          	jal	5942 <close>
      close(open(file, 0));
    44c8:	4581                	li	a1,0
    44ca:	854e                	mv	a0,s3
    44cc:	48e010ef          	jal	595a <open>
    44d0:	472010ef          	jal	5942 <close>
      close(open(file, 0));
    44d4:	4581                	li	a1,0
    44d6:	854e                	mv	a0,s3
    44d8:	482010ef          	jal	595a <open>
    44dc:	466010ef          	jal	5942 <close>
      close(open(file, 0));
    44e0:	4581                	li	a1,0
    44e2:	854e                	mv	a0,s3
    44e4:	476010ef          	jal	595a <open>
    44e8:	45a010ef          	jal	5942 <close>
      close(open(file, 0));
    44ec:	4581                	li	a1,0
    44ee:	854e                	mv	a0,s3
    44f0:	46a010ef          	jal	595a <open>
    44f4:	44e010ef          	jal	5942 <close>
    if (pid == 0)
    44f8:	06090663          	beqz	s2,4564 <concreate+0x262>
      wait(0);
    44fc:	4501                	li	a0,0
    44fe:	424010ef          	jal	5922 <wait>
  for (i = 0; i < N; i++) {
    4502:	2485                	addiw	s1,s1,1
    4504:	0d548163          	beq	s1,s5,45c6 <concreate+0x2c4>
    file[1] = '0' + i;
    4508:	0304879b          	addiw	a5,s1,48
    450c:	f8f40ca3          	sb	a5,-103(s0)
    pid = fork();
    4510:	402010ef          	jal	5912 <fork>
    4514:	892a                	mv	s2,a0
    if (pid < 0) {
    4516:	f80543e3          	bltz	a0,449c <concreate+0x19a>
    if (((i % 3) == 0 && pid == 0) || ((i % 3) == 1 && pid != 0)) {
    451a:	03448733          	mul	a4,s1,s4
    451e:	9301                	srli	a4,a4,0x20
    4520:	41f4d79b          	sraiw	a5,s1,0x1f
    4524:	9f1d                	subw	a4,a4,a5
    4526:	0017179b          	slliw	a5,a4,0x1
    452a:	9fb9                	addw	a5,a5,a4
    452c:	40f487bb          	subw	a5,s1,a5
    4530:	00a7e733          	or	a4,a5,a0
    4534:	2701                	sext.w	a4,a4
    4536:	df2d                	beqz	a4,44b0 <concreate+0x1ae>
    4538:	c119                	beqz	a0,453e <concreate+0x23c>
    453a:	17fd                	addi	a5,a5,-1
    453c:	dbb5                	beqz	a5,44b0 <concreate+0x1ae>
      unlink(file);
    453e:	854e                	mv	a0,s3
    4540:	42a010ef          	jal	596a <unlink>
      unlink(file);
    4544:	854e                	mv	a0,s3
    4546:	424010ef          	jal	596a <unlink>
      unlink(file);
    454a:	854e                	mv	a0,s3
    454c:	41e010ef          	jal	596a <unlink>
      unlink(file);
    4550:	854e                	mv	a0,s3
    4552:	418010ef          	jal	596a <unlink>
      unlink(file);
    4556:	854e                	mv	a0,s3
    4558:	412010ef          	jal	596a <unlink>
      unlink(file);
    455c:	854e                	mv	a0,s3
    455e:	40c010ef          	jal	596a <unlink>
    4562:	bf59                	j	44f8 <concreate+0x1f6>
      exit(0);
    4564:	4501                	li	a0,0
    4566:	3b4010ef          	jal	591a <exit>
      close(fd);
    456a:	3d8010ef          	jal	5942 <close>
    if (pid == 0) {
    456e:	b5a1                	j	43b6 <concreate+0xb4>
      close(fd);
    4570:	3d2010ef          	jal	5942 <close>
      wait(&xstatus);
    4574:	8556                	mv	a0,s5
    4576:	3ac010ef          	jal	5922 <wait>
      if (xstatus != 0)
    457a:	f5c42483          	lw	s1,-164(s0)
    457e:	e2049fe3          	bnez	s1,43bc <concreate+0xba>
  for (i = 0; i < N; i++) {
    4582:	2905                	addiw	s2,s2,1
    4584:	e3490fe3          	beq	s2,s4,43c2 <concreate+0xc0>
    file[1] = '0' + i;
    4588:	0309079b          	addiw	a5,s2,48
    458c:	f8f40ca3          	sb	a5,-103(s0)
    unlink(file);
    4590:	854e                	mv	a0,s3
    4592:	3d8010ef          	jal	596a <unlink>
    pid = fork();
    4596:	37c010ef          	jal	5912 <fork>
    if (pid && (i % 3) == 1) {
    459a:	dc0501e3          	beqz	a0,435c <concreate+0x5a>
    459e:	036907b3          	mul	a5,s2,s6
    45a2:	9381                	srli	a5,a5,0x20
    45a4:	41f9571b          	sraiw	a4,s2,0x1f
    45a8:	9f99                	subw	a5,a5,a4
    45aa:	0017971b          	slliw	a4,a5,0x1
    45ae:	9fb9                	addw	a5,a5,a4
    45b0:	40f907bb          	subw	a5,s2,a5
    45b4:	d9778fe3          	beq	a5,s7,4352 <concreate+0x50>
      fd = open(file, O_CREATE | O_RDWR);
    45b8:	85e2                	mv	a1,s8
    45ba:	854e                	mv	a0,s3
    45bc:	39e010ef          	jal	595a <open>
      if (fd < 0) {
    45c0:	fa0558e3          	bgez	a0,4570 <concreate+0x26e>
    45c4:	b3f1                	j	4390 <concreate+0x8e>
}
    45c6:	70aa                	ld	ra,168(sp)
    45c8:	740a                	ld	s0,160(sp)
    45ca:	64ea                	ld	s1,152(sp)
    45cc:	694a                	ld	s2,144(sp)
    45ce:	69aa                	ld	s3,136(sp)
    45d0:	6a0a                	ld	s4,128(sp)
    45d2:	7ae6                	ld	s5,120(sp)
    45d4:	7b46                	ld	s6,112(sp)
    45d6:	7ba6                	ld	s7,104(sp)
    45d8:	7c06                	ld	s8,96(sp)
    45da:	6ce6                	ld	s9,88(sp)
    45dc:	6d46                	ld	s10,80(sp)
    45de:	614d                	addi	sp,sp,176
    45e0:	8082                	ret

00000000000045e2 <bigfile>:
{
    45e2:	7139                	addi	sp,sp,-64
    45e4:	fc06                	sd	ra,56(sp)
    45e6:	f822                	sd	s0,48(sp)
    45e8:	f426                	sd	s1,40(sp)
    45ea:	f04a                	sd	s2,32(sp)
    45ec:	ec4e                	sd	s3,24(sp)
    45ee:	e852                	sd	s4,16(sp)
    45f0:	e456                	sd	s5,8(sp)
    45f2:	e05a                	sd	s6,0(sp)
    45f4:	0080                	addi	s0,sp,64
    45f6:	8b2a                	mv	s6,a0
  unlink("bigfile.dat");
    45f8:	00004517          	auipc	a0,0x4
    45fc:	86850513          	addi	a0,a0,-1944 # 7e60 <malloc+0x2038>
    4600:	36a010ef          	jal	596a <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    4604:	20200593          	li	a1,514
    4608:	00004517          	auipc	a0,0x4
    460c:	85850513          	addi	a0,a0,-1960 # 7e60 <malloc+0x2038>
    4610:	34a010ef          	jal	595a <open>
  if (fd < 0) {
    4614:	08054a63          	bltz	a0,46a8 <bigfile+0xc6>
    4618:	8a2a                	mv	s4,a0
    461a:	4481                	li	s1,0
    memset(buf, i, SZ);
    461c:	25800913          	li	s2,600
    4620:	0000a997          	auipc	s3,0xa
    4624:	6e898993          	addi	s3,s3,1768 # ed08 <buf>
  for (i = 0; i < N; i++) {
    4628:	4ad1                	li	s5,20
    memset(buf, i, SZ);
    462a:	864a                	mv	a2,s2
    462c:	85a6                	mv	a1,s1
    462e:	854e                	mv	a0,s3
    4630:	0c0010ef          	jal	56f0 <memset>
    if (write(fd, buf, SZ) != SZ) {
    4634:	864a                	mv	a2,s2
    4636:	85ce                	mv	a1,s3
    4638:	8552                	mv	a0,s4
    463a:	300010ef          	jal	593a <write>
    463e:	07251f63          	bne	a0,s2,46bc <bigfile+0xda>
  for (i = 0; i < N; i++) {
    4642:	2485                	addiw	s1,s1,1
    4644:	ff5493e3          	bne	s1,s5,462a <bigfile+0x48>
  close(fd);
    4648:	8552                	mv	a0,s4
    464a:	2f8010ef          	jal	5942 <close>
  fd = open("bigfile.dat", 0);
    464e:	4581                	li	a1,0
    4650:	00004517          	auipc	a0,0x4
    4654:	81050513          	addi	a0,a0,-2032 # 7e60 <malloc+0x2038>
    4658:	302010ef          	jal	595a <open>
    465c:	8aaa                	mv	s5,a0
  total = 0;
    465e:	4a01                	li	s4,0
  for (i = 0;; i++) {
    4660:	4481                	li	s1,0
    cc = read(fd, buf, SZ / 2);
    4662:	12c00993          	li	s3,300
    4666:	0000a917          	auipc	s2,0xa
    466a:	6a290913          	addi	s2,s2,1698 # ed08 <buf>
  if (fd < 0) {
    466e:	06054163          	bltz	a0,46d0 <bigfile+0xee>
    cc = read(fd, buf, SZ / 2);
    4672:	864e                	mv	a2,s3
    4674:	85ca                	mv	a1,s2
    4676:	8556                	mv	a0,s5
    4678:	2ba010ef          	jal	5932 <read>
    if (cc < 0) {
    467c:	06054463          	bltz	a0,46e4 <bigfile+0x102>
    if (cc == 0)
    4680:	c145                	beqz	a0,4720 <bigfile+0x13e>
    if (cc != SZ / 2) {
    4682:	07351b63          	bne	a0,s3,46f8 <bigfile+0x116>
    if (buf[0] != i / 2 || buf[SZ / 2 - 1] != i / 2) {
    4686:	01f4d79b          	srliw	a5,s1,0x1f
    468a:	9fa5                	addw	a5,a5,s1
    468c:	4017d79b          	sraiw	a5,a5,0x1
    4690:	00094703          	lbu	a4,0(s2)
    4694:	06f71c63          	bne	a4,a5,470c <bigfile+0x12a>
    4698:	12b94703          	lbu	a4,299(s2)
    469c:	06f71863          	bne	a4,a5,470c <bigfile+0x12a>
    total += cc;
    46a0:	12ca0a1b          	addiw	s4,s4,300
  for (i = 0;; i++) {
    46a4:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ / 2);
    46a6:	b7f1                	j	4672 <bigfile+0x90>
    printf("%s: cannot create bigfile", s);
    46a8:	85da                	mv	a1,s6
    46aa:	00003517          	auipc	a0,0x3
    46ae:	7c650513          	addi	a0,a0,1990 # 7e70 <malloc+0x2048>
    46b2:	6be010ef          	jal	5d70 <printf>
    exit(1);
    46b6:	4505                	li	a0,1
    46b8:	262010ef          	jal	591a <exit>
      printf("%s: write bigfile failed\n", s);
    46bc:	85da                	mv	a1,s6
    46be:	00003517          	auipc	a0,0x3
    46c2:	7d250513          	addi	a0,a0,2002 # 7e90 <malloc+0x2068>
    46c6:	6aa010ef          	jal	5d70 <printf>
      exit(1);
    46ca:	4505                	li	a0,1
    46cc:	24e010ef          	jal	591a <exit>
    printf("%s: cannot open bigfile\n", s);
    46d0:	85da                	mv	a1,s6
    46d2:	00003517          	auipc	a0,0x3
    46d6:	7de50513          	addi	a0,a0,2014 # 7eb0 <malloc+0x2088>
    46da:	696010ef          	jal	5d70 <printf>
    exit(1);
    46de:	4505                	li	a0,1
    46e0:	23a010ef          	jal	591a <exit>
      printf("%s: read bigfile failed\n", s);
    46e4:	85da                	mv	a1,s6
    46e6:	00003517          	auipc	a0,0x3
    46ea:	7ea50513          	addi	a0,a0,2026 # 7ed0 <malloc+0x20a8>
    46ee:	682010ef          	jal	5d70 <printf>
      exit(1);
    46f2:	4505                	li	a0,1
    46f4:	226010ef          	jal	591a <exit>
      printf("%s: short read bigfile\n", s);
    46f8:	85da                	mv	a1,s6
    46fa:	00003517          	auipc	a0,0x3
    46fe:	7f650513          	addi	a0,a0,2038 # 7ef0 <malloc+0x20c8>
    4702:	66e010ef          	jal	5d70 <printf>
      exit(1);
    4706:	4505                	li	a0,1
    4708:	212010ef          	jal	591a <exit>
      printf("%s: read bigfile wrong data\n", s);
    470c:	85da                	mv	a1,s6
    470e:	00003517          	auipc	a0,0x3
    4712:	7fa50513          	addi	a0,a0,2042 # 7f08 <malloc+0x20e0>
    4716:	65a010ef          	jal	5d70 <printf>
      exit(1);
    471a:	4505                	li	a0,1
    471c:	1fe010ef          	jal	591a <exit>
  close(fd);
    4720:	8556                	mv	a0,s5
    4722:	220010ef          	jal	5942 <close>
  if (total != N * SZ) {
    4726:	678d                	lui	a5,0x3
    4728:	ee078793          	addi	a5,a5,-288 # 2ee0 <subdir+0x356>
    472c:	02fa1263          	bne	s4,a5,4750 <bigfile+0x16e>
  unlink("bigfile.dat");
    4730:	00003517          	auipc	a0,0x3
    4734:	73050513          	addi	a0,a0,1840 # 7e60 <malloc+0x2038>
    4738:	232010ef          	jal	596a <unlink>
}
    473c:	70e2                	ld	ra,56(sp)
    473e:	7442                	ld	s0,48(sp)
    4740:	74a2                	ld	s1,40(sp)
    4742:	7902                	ld	s2,32(sp)
    4744:	69e2                	ld	s3,24(sp)
    4746:	6a42                	ld	s4,16(sp)
    4748:	6aa2                	ld	s5,8(sp)
    474a:	6b02                	ld	s6,0(sp)
    474c:	6121                	addi	sp,sp,64
    474e:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    4750:	85da                	mv	a1,s6
    4752:	00003517          	auipc	a0,0x3
    4756:	7d650513          	addi	a0,a0,2006 # 7f28 <malloc+0x2100>
    475a:	616010ef          	jal	5d70 <printf>
    exit(1);
    475e:	4505                	li	a0,1
    4760:	1ba010ef          	jal	591a <exit>

0000000000004764 <bigargtest>:
{
    4764:	7121                	addi	sp,sp,-448
    4766:	ff06                	sd	ra,440(sp)
    4768:	fb22                	sd	s0,432(sp)
    476a:	f726                	sd	s1,424(sp)
    476c:	0380                	addi	s0,sp,448
    476e:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    4770:	00003517          	auipc	a0,0x3
    4774:	7d850513          	addi	a0,a0,2008 # 7f48 <malloc+0x2120>
    4778:	1f2010ef          	jal	596a <unlink>
  pid = fork();
    477c:	196010ef          	jal	5912 <fork>
  if (pid == 0) {
    4780:	c915                	beqz	a0,47b4 <bigargtest+0x50>
  } else if (pid < 0) {
    4782:	08054c63          	bltz	a0,481a <bigargtest+0xb6>
  wait(&xstatus);
    4786:	fdc40513          	addi	a0,s0,-36
    478a:	198010ef          	jal	5922 <wait>
  if (xstatus != 0)
    478e:	fdc42503          	lw	a0,-36(s0)
    4792:	ed51                	bnez	a0,482e <bigargtest+0xca>
  fd = open("bigarg-ok", 0);
    4794:	4581                	li	a1,0
    4796:	00003517          	auipc	a0,0x3
    479a:	7b250513          	addi	a0,a0,1970 # 7f48 <malloc+0x2120>
    479e:	1bc010ef          	jal	595a <open>
  if (fd < 0) {
    47a2:	08054863          	bltz	a0,4832 <bigargtest+0xce>
  close(fd);
    47a6:	19c010ef          	jal	5942 <close>
}
    47aa:	70fa                	ld	ra,440(sp)
    47ac:	745a                	ld	s0,432(sp)
    47ae:	74ba                	ld	s1,424(sp)
    47b0:	6139                	addi	sp,sp,448
    47b2:	8082                	ret
    memset(big, ' ', sizeof(big));
    47b4:	19000613          	li	a2,400
    47b8:	02000593          	li	a1,32
    47bc:	e4840513          	addi	a0,s0,-440
    47c0:	731000ef          	jal	56f0 <memset>
    big[sizeof(big) - 1] = '\0';
    47c4:	fc040ba3          	sb	zero,-41(s0)
    for (i = 0; i < MAXARG - 1; i++)
    47c8:	00007797          	auipc	a5,0x7
    47cc:	d2878793          	addi	a5,a5,-728 # b4f0 <args.1>
    47d0:	00007697          	auipc	a3,0x7
    47d4:	e1868693          	addi	a3,a3,-488 # b5e8 <args.1+0xf8>
      args[i] = big;
    47d8:	e4840713          	addi	a4,s0,-440
    47dc:	e398                	sd	a4,0(a5)
    for (i = 0; i < MAXARG - 1; i++)
    47de:	07a1                	addi	a5,a5,8
    47e0:	fed79ee3          	bne	a5,a3,47dc <bigargtest+0x78>
    args[MAXARG - 1] = 0;
    47e4:	00007797          	auipc	a5,0x7
    47e8:	e007b223          	sd	zero,-508(a5) # b5e8 <args.1+0xf8>
    exec("echo", args);
    47ec:	00007597          	auipc	a1,0x7
    47f0:	d0458593          	addi	a1,a1,-764 # b4f0 <args.1>
    47f4:	00001517          	auipc	a0,0x1
    47f8:	76450513          	addi	a0,a0,1892 # 5f58 <malloc+0x130>
    47fc:	156010ef          	jal	5952 <exec>
    fd = open("bigarg-ok", O_CREATE);
    4800:	20000593          	li	a1,512
    4804:	00003517          	auipc	a0,0x3
    4808:	74450513          	addi	a0,a0,1860 # 7f48 <malloc+0x2120>
    480c:	14e010ef          	jal	595a <open>
    close(fd);
    4810:	132010ef          	jal	5942 <close>
    exit(0);
    4814:	4501                	li	a0,0
    4816:	104010ef          	jal	591a <exit>
    printf("%s: bigargtest: fork failed\n", s);
    481a:	85a6                	mv	a1,s1
    481c:	00003517          	auipc	a0,0x3
    4820:	73c50513          	addi	a0,a0,1852 # 7f58 <malloc+0x2130>
    4824:	54c010ef          	jal	5d70 <printf>
    exit(1);
    4828:	4505                	li	a0,1
    482a:	0f0010ef          	jal	591a <exit>
    exit(xstatus);
    482e:	0ec010ef          	jal	591a <exit>
    printf("%s: bigarg test failed!\n", s);
    4832:	85a6                	mv	a1,s1
    4834:	00003517          	auipc	a0,0x3
    4838:	74450513          	addi	a0,a0,1860 # 7f78 <malloc+0x2150>
    483c:	534010ef          	jal	5d70 <printf>
    exit(1);
    4840:	4505                	li	a0,1
    4842:	0d8010ef          	jal	591a <exit>

0000000000004846 <partial_write>:
{
    4846:	bb010113          	addi	sp,sp,-1104
    484a:	44113423          	sd	ra,1096(sp)
    484e:	44813023          	sd	s0,1088(sp)
    4852:	42913c23          	sd	s1,1080(sp)
    4856:	43213823          	sd	s2,1072(sp)
    485a:	43313423          	sd	s3,1064(sp)
    485e:	43413023          	sd	s4,1056(sp)
    4862:	41513c23          	sd	s5,1048(sp)
    4866:	45010413          	addi	s0,sp,1104
    486a:	8aaa                	mv	s5,a0
  unlink("testfile");
    486c:	00003517          	auipc	a0,0x3
    4870:	72c50513          	addi	a0,a0,1836 # 7f98 <malloc+0x2170>
    4874:	0f6010ef          	jal	596a <unlink>
  int fd = open("testfile", O_CREATE | O_RDWR);
    4878:	20200593          	li	a1,514
    487c:	00003517          	auipc	a0,0x3
    4880:	71c50513          	addi	a0,a0,1820 # 7f98 <malloc+0x2170>
    4884:	0d6010ef          	jal	595a <open>
  if (fd < 0) {
    4888:	14054f63          	bltz	a0,49e6 <partial_write+0x1a0>
    488c:	84aa                	mv	s1,a0
  int cc = write(fd, "A", 1);
    488e:	4605                	li	a2,1
    4890:	00003597          	auipc	a1,0x3
    4894:	73858593          	addi	a1,a1,1848 # 7fc8 <malloc+0x21a0>
    4898:	0a2010ef          	jal	593a <write>
  if (cc != 1) {
    489c:	4785                	li	a5,1
    489e:	14f51e63          	bne	a0,a5,49fa <partial_write+0x1b4>
  close(fd);
    48a2:	8526                	mv	a0,s1
    48a4:	09e010ef          	jal	5942 <close>
  fd = open("testfile", O_RDWR);
    48a8:	4589                	li	a1,2
    48aa:	00003517          	auipc	a0,0x3
    48ae:	6ee50513          	addi	a0,a0,1774 # 7f98 <malloc+0x2170>
    48b2:	0a8010ef          	jal	595a <open>
    48b6:	892a                	mv	s2,a0
  if (fd < 0) {
    48b8:	14054b63          	bltz	a0,4a0e <partial_write+0x1c8>
  char *p = sbrk(0);
    48bc:	4501                	li	a0,0
    48be:	028010ef          	jal	58e6 <sbrk>
  sbrk(PGSIZE - ((uint64)p % PGSIZE));
    48c2:	6485                	lui	s1,0x1
    48c4:	14fd                	addi	s1,s1,-1 # fff <bigdir+0x10b>
    48c6:	009577b3          	and	a5,a0,s1
    48ca:	6505                	lui	a0,0x1
    48cc:	9d1d                	subw	a0,a0,a5
    48ce:	018010ef          	jal	58e6 <sbrk>
  p = sbrk(0);
    48d2:	4501                	li	a0,0
    48d4:	012010ef          	jal	58e6 <sbrk>
  if ((uint64)p % PGSIZE != 0) {
    48d8:	8ce9                	and	s1,s1,a0
    48da:	14049463          	bnez	s1,4a22 <partial_write+0x1dc>
  p[-1] = 'X';
    48de:	05800793          	li	a5,88
    48e2:	fef50fa3          	sb	a5,-1(a0) # fff <bigdir+0x10b>
  cc = write(fd, p - 1, 2);
    48e6:	4609                	li	a2,2
    48e8:	fff50593          	addi	a1,a0,-1
    48ec:	854a                	mv	a0,s2
    48ee:	04c010ef          	jal	593a <write>
  if (cc != -1) {
    48f2:	57fd                	li	a5,-1
    48f4:	14f51163          	bne	a0,a5,4a36 <partial_write+0x1f0>
  close(fd);
    48f8:	854a                	mv	a0,s2
    48fa:	048010ef          	jal	5942 <close>
  fd = open("testfile", O_RDONLY);
    48fe:	4581                	li	a1,0
    4900:	00003517          	auipc	a0,0x3
    4904:	69850513          	addi	a0,a0,1688 # 7f98 <malloc+0x2170>
    4908:	052010ef          	jal	595a <open>
    490c:	84aa                	mv	s1,a0
  if (fd < 0) {
    490e:	12054e63          	bltz	a0,4a4a <partial_write+0x204>
  cc = read(fd, &b, 1);
    4912:	4605                	li	a2,1
    4914:	fbf40593          	addi	a1,s0,-65
    4918:	01a010ef          	jal	5932 <read>
  if (cc != 1) {
    491c:	4785                	li	a5,1
    491e:	14f51063          	bne	a0,a5,4a5e <partial_write+0x218>
  close(fd);
    4922:	8526                	mv	a0,s1
    4924:	01e010ef          	jal	5942 <close>
  if (b != 'X') {
    4928:	fbf44603          	lbu	a2,-65(s0)
    492c:	05800793          	li	a5,88
    4930:	14f61163          	bne	a2,a5,4a72 <partial_write+0x22c>
  fd = open("bigfile", O_CREATE | O_RDWR);
    4934:	20200593          	li	a1,514
    4938:	00003517          	auipc	a0,0x3
    493c:	76050513          	addi	a0,a0,1888 # 8098 <malloc+0x2270>
    4940:	01a010ef          	jal	595a <open>
    4944:	8a2a                	mv	s4,a0
    4946:	04000913          	li	s2,64
    memset(buf, 0, sizeof(buf));
    494a:	bb840993          	addi	s3,s0,-1096
    494e:	40000493          	li	s1,1024
    4952:	8626                	mv	a2,s1
    4954:	4581                	li	a1,0
    4956:	854e                	mv	a0,s3
    4958:	599000ef          	jal	56f0 <memset>
    cc = write(fd, buf, sizeof(buf));
    495c:	8626                	mv	a2,s1
    495e:	85ce                	mv	a1,s3
    4960:	8552                	mv	a0,s4
    4962:	7d9000ef          	jal	593a <write>
    if (cc != sizeof(buf)) {
    4966:	12951063          	bne	a0,s1,4a86 <partial_write+0x240>
  for (int i = 0; i < 64; i++) {
    496a:	397d                	addiw	s2,s2,-1
    496c:	fe0913e3          	bnez	s2,4952 <partial_write+0x10c>
  close(fd);
    4970:	8552                	mv	a0,s4
    4972:	7d1000ef          	jal	5942 <close>
  unlink("bigfile");
    4976:	00003517          	auipc	a0,0x3
    497a:	72250513          	addi	a0,a0,1826 # 8098 <malloc+0x2270>
    497e:	7ed000ef          	jal	596a <unlink>
  fd = open("testfile", O_RDONLY);
    4982:	4581                	li	a1,0
    4984:	00003517          	auipc	a0,0x3
    4988:	61450513          	addi	a0,a0,1556 # 7f98 <malloc+0x2170>
    498c:	7cf000ef          	jal	595a <open>
    4990:	84aa                	mv	s1,a0
  if (fd < 0) {
    4992:	10054463          	bltz	a0,4a9a <partial_write+0x254>
  cc = read(fd, &b, 1);
    4996:	4605                	li	a2,1
    4998:	fbf40593          	addi	a1,s0,-65
    499c:	797000ef          	jal	5932 <read>
  if (cc != 1) {
    49a0:	4785                	li	a5,1
    49a2:	10f51663          	bne	a0,a5,4aae <partial_write+0x268>
  close(fd);
    49a6:	8526                	mv	a0,s1
    49a8:	79b000ef          	jal	5942 <close>
  if (b != 'X') {
    49ac:	fbf44603          	lbu	a2,-65(s0)
    49b0:	05800793          	li	a5,88
    49b4:	10f61763          	bne	a2,a5,4ac2 <partial_write+0x27c>
  unlink("testfile");
    49b8:	00003517          	auipc	a0,0x3
    49bc:	5e050513          	addi	a0,a0,1504 # 7f98 <malloc+0x2170>
    49c0:	7ab000ef          	jal	596a <unlink>
}
    49c4:	44813083          	ld	ra,1096(sp)
    49c8:	44013403          	ld	s0,1088(sp)
    49cc:	43813483          	ld	s1,1080(sp)
    49d0:	43013903          	ld	s2,1072(sp)
    49d4:	42813983          	ld	s3,1064(sp)
    49d8:	42013a03          	ld	s4,1056(sp)
    49dc:	41813a83          	ld	s5,1048(sp)
    49e0:	45010113          	addi	sp,sp,1104
    49e4:	8082                	ret
    printf("%s: cannot create testfile\n", s);
    49e6:	85d6                	mv	a1,s5
    49e8:	00003517          	auipc	a0,0x3
    49ec:	5c050513          	addi	a0,a0,1472 # 7fa8 <malloc+0x2180>
    49f0:	380010ef          	jal	5d70 <printf>
    exit(1);
    49f4:	4505                	li	a0,1
    49f6:	725000ef          	jal	591a <exit>
    printf("%s: could not write A\n", s);
    49fa:	85d6                	mv	a1,s5
    49fc:	00003517          	auipc	a0,0x3
    4a00:	5d450513          	addi	a0,a0,1492 # 7fd0 <malloc+0x21a8>
    4a04:	36c010ef          	jal	5d70 <printf>
    exit(1);
    4a08:	4505                	li	a0,1
    4a0a:	711000ef          	jal	591a <exit>
    printf("%s: cannot re-open testfile\n", s);
    4a0e:	85d6                	mv	a1,s5
    4a10:	00003517          	auipc	a0,0x3
    4a14:	5d850513          	addi	a0,a0,1496 # 7fe8 <malloc+0x21c0>
    4a18:	358010ef          	jal	5d70 <printf>
    exit(1);
    4a1c:	4505                	li	a0,1
    4a1e:	6fd000ef          	jal	591a <exit>
    printf("%s: sbrk did not align\n", s);
    4a22:	85d6                	mv	a1,s5
    4a24:	00003517          	auipc	a0,0x3
    4a28:	5e450513          	addi	a0,a0,1508 # 8008 <malloc+0x21e0>
    4a2c:	344010ef          	jal	5d70 <printf>
    exit(1);
    4a30:	4505                	li	a0,1
    4a32:	6e9000ef          	jal	591a <exit>
    printf("%s: write succeeded, should have failed\n", s);
    4a36:	85d6                	mv	a1,s5
    4a38:	00003517          	auipc	a0,0x3
    4a3c:	5e850513          	addi	a0,a0,1512 # 8020 <malloc+0x21f8>
    4a40:	330010ef          	jal	5d70 <printf>
    exit(1);
    4a44:	4505                	li	a0,1
    4a46:	6d5000ef          	jal	591a <exit>
    printf("%s: cannot re-open testfile\n", s);
    4a4a:	85d6                	mv	a1,s5
    4a4c:	00003517          	auipc	a0,0x3
    4a50:	59c50513          	addi	a0,a0,1436 # 7fe8 <malloc+0x21c0>
    4a54:	31c010ef          	jal	5d70 <printf>
    exit(1);
    4a58:	4505                	li	a0,1
    4a5a:	6c1000ef          	jal	591a <exit>
    printf("%s: cannot read testfile\n", s);
    4a5e:	85d6                	mv	a1,s5
    4a60:	00003517          	auipc	a0,0x3
    4a64:	5f050513          	addi	a0,a0,1520 # 8050 <malloc+0x2228>
    4a68:	308010ef          	jal	5d70 <printf>
    exit(1);
    4a6c:	4505                	li	a0,1
    4a6e:	6ad000ef          	jal	591a <exit>
    printf("%s: read returned %c, expected X\n", s, b);
    4a72:	85d6                	mv	a1,s5
    4a74:	00003517          	auipc	a0,0x3
    4a78:	5fc50513          	addi	a0,a0,1532 # 8070 <malloc+0x2248>
    4a7c:	2f4010ef          	jal	5d70 <printf>
    exit(1);
    4a80:	4505                	li	a0,1
    4a82:	699000ef          	jal	591a <exit>
      printf("%s: could not write to bigfile\n", s);
    4a86:	85d6                	mv	a1,s5
    4a88:	00003517          	auipc	a0,0x3
    4a8c:	61850513          	addi	a0,a0,1560 # 80a0 <malloc+0x2278>
    4a90:	2e0010ef          	jal	5d70 <printf>
      exit(-1);
    4a94:	557d                	li	a0,-1
    4a96:	685000ef          	jal	591a <exit>
    printf("%s: cannot re-open testfile\n", s);
    4a9a:	85d6                	mv	a1,s5
    4a9c:	00003517          	auipc	a0,0x3
    4aa0:	54c50513          	addi	a0,a0,1356 # 7fe8 <malloc+0x21c0>
    4aa4:	2cc010ef          	jal	5d70 <printf>
    exit(1);
    4aa8:	4505                	li	a0,1
    4aaa:	671000ef          	jal	591a <exit>
    printf("%s: cannot read testfile\n", s);
    4aae:	85d6                	mv	a1,s5
    4ab0:	00003517          	auipc	a0,0x3
    4ab4:	5a050513          	addi	a0,a0,1440 # 8050 <malloc+0x2228>
    4ab8:	2b8010ef          	jal	5d70 <printf>
    exit(1);
    4abc:	4505                	li	a0,1
    4abe:	65d000ef          	jal	591a <exit>
    printf("%s: read returned %c, expected X\n", s, b);
    4ac2:	85d6                	mv	a1,s5
    4ac4:	00003517          	auipc	a0,0x3
    4ac8:	5ac50513          	addi	a0,a0,1452 # 8070 <malloc+0x2248>
    4acc:	2a4010ef          	jal	5d70 <printf>
    exit(1);
    4ad0:	4505                	li	a0,1
    4ad2:	649000ef          	jal	591a <exit>

0000000000004ad6 <lazy_alloc>:
{
    4ad6:	1141                	addi	sp,sp,-16
    4ad8:	e406                	sd	ra,8(sp)
    4ada:	e022                	sd	s0,0(sp)
    4adc:	0800                	addi	s0,sp,16
  prev_end = sbrklazy(REGION_SZ);
    4ade:	40000537          	lui	a0,0x40000
    4ae2:	61b000ef          	jal	58fc <sbrklazy>
  if (prev_end == (char *)SBRK_ERROR) {
    4ae6:	57fd                	li	a5,-1
    4ae8:	02f50a63          	beq	a0,a5,4b1c <lazy_alloc+0x46>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
    4aec:	6605                	lui	a2,0x1
    4aee:	962a                	add	a2,a2,a0
    4af0:	400017b7          	lui	a5,0x40001
    4af4:	00f50733          	add	a4,a0,a5
    4af8:	87b2                	mv	a5,a2
    4afa:	000406b7          	lui	a3,0x40
    *(char **)i = i;
    4afe:	e39c                	sd	a5,0(a5)
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
    4b00:	97b6                	add	a5,a5,a3
    4b02:	fee79ee3          	bne	a5,a4,4afe <lazy_alloc+0x28>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
    4b06:	000406b7          	lui	a3,0x40
    if (*(char **)i != i) {
    4b0a:	621c                	ld	a5,0(a2)
    4b0c:	02c79163          	bne	a5,a2,4b2e <lazy_alloc+0x58>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
    4b10:	9636                	add	a2,a2,a3
    4b12:	fee61ce3          	bne	a2,a4,4b0a <lazy_alloc+0x34>
  exit(0);
    4b16:	4501                	li	a0,0
    4b18:	603000ef          	jal	591a <exit>
    printf("sbrklazy() failed\n");
    4b1c:	00003517          	auipc	a0,0x3
    4b20:	5a450513          	addi	a0,a0,1444 # 80c0 <malloc+0x2298>
    4b24:	24c010ef          	jal	5d70 <printf>
    exit(1);
    4b28:	4505                	li	a0,1
    4b2a:	5f1000ef          	jal	591a <exit>
      printf("failed to read value from memory\n");
    4b2e:	00003517          	auipc	a0,0x3
    4b32:	5aa50513          	addi	a0,a0,1450 # 80d8 <malloc+0x22b0>
    4b36:	23a010ef          	jal	5d70 <printf>
      exit(1);
    4b3a:	4505                	li	a0,1
    4b3c:	5df000ef          	jal	591a <exit>

0000000000004b40 <lazy_unmap>:
{
    4b40:	7139                	addi	sp,sp,-64
    4b42:	fc06                	sd	ra,56(sp)
    4b44:	f822                	sd	s0,48(sp)
    4b46:	0080                	addi	s0,sp,64
  prev_end = sbrklazy(REGION_SZ);
    4b48:	40000537          	lui	a0,0x40000
    4b4c:	5b1000ef          	jal	58fc <sbrklazy>
  if (prev_end == (char *)SBRK_ERROR) {
    4b50:	57fd                	li	a5,-1
    4b52:	04f50863          	beq	a0,a5,4ba2 <lazy_unmap+0x62>
    4b56:	f426                	sd	s1,40(sp)
    4b58:	f04a                	sd	s2,32(sp)
    4b5a:	ec4e                	sd	s3,24(sp)
    4b5c:	e852                	sd	s4,16(sp)
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
    4b5e:	6905                	lui	s2,0x1
    4b60:	992a                	add	s2,s2,a0
    4b62:	400017b7          	lui	a5,0x40001
    4b66:	00f504b3          	add	s1,a0,a5
    4b6a:	87ca                	mv	a5,s2
    4b6c:	01000737          	lui	a4,0x1000
    *(char **)i = i;
    4b70:	e39c                	sd	a5,0(a5)
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
    4b72:	97ba                	add	a5,a5,a4
    4b74:	fe979ee3          	bne	a5,s1,4b70 <lazy_unmap+0x30>
      wait(&status);
    4b78:	fcc40993          	addi	s3,s0,-52
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE) {
    4b7c:	01000a37          	lui	s4,0x1000
    pid = fork();
    4b80:	593000ef          	jal	5912 <fork>
    if (pid < 0) {
    4b84:	02054c63          	bltz	a0,4bbc <lazy_unmap+0x7c>
    } else if (pid == 0) {
    4b88:	c139                	beqz	a0,4bce <lazy_unmap+0x8e>
      wait(&status);
    4b8a:	854e                	mv	a0,s3
    4b8c:	597000ef          	jal	5922 <wait>
      if (status == 0) {
    4b90:	fcc42783          	lw	a5,-52(s0)
    4b94:	c7b1                	beqz	a5,4be0 <lazy_unmap+0xa0>
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE) {
    4b96:	9952                	add	s2,s2,s4
    4b98:	fe9914e3          	bne	s2,s1,4b80 <lazy_unmap+0x40>
  exit(0);
    4b9c:	4501                	li	a0,0
    4b9e:	57d000ef          	jal	591a <exit>
    4ba2:	f426                	sd	s1,40(sp)
    4ba4:	f04a                	sd	s2,32(sp)
    4ba6:	ec4e                	sd	s3,24(sp)
    4ba8:	e852                	sd	s4,16(sp)
    printf("sbrklazy() failed\n");
    4baa:	00003517          	auipc	a0,0x3
    4bae:	51650513          	addi	a0,a0,1302 # 80c0 <malloc+0x2298>
    4bb2:	1be010ef          	jal	5d70 <printf>
    exit(1);
    4bb6:	4505                	li	a0,1
    4bb8:	563000ef          	jal	591a <exit>
      printf("error forking\n");
    4bbc:	00003517          	auipc	a0,0x3
    4bc0:	54450513          	addi	a0,a0,1348 # 8100 <malloc+0x22d8>
    4bc4:	1ac010ef          	jal	5d70 <printf>
      exit(1);
    4bc8:	4505                	li	a0,1
    4bca:	551000ef          	jal	591a <exit>
      sbrklazy(-1L * REGION_SZ);
    4bce:	c0000537          	lui	a0,0xc0000
    4bd2:	52b000ef          	jal	58fc <sbrklazy>
      *(char **)i = i;
    4bd6:	01293023          	sd	s2,0(s2) # 1000 <bigdir+0x10c>
      exit(0);
    4bda:	4501                	li	a0,0
    4bdc:	53f000ef          	jal	591a <exit>
        printf("memory not unmapped\n");
    4be0:	00003517          	auipc	a0,0x3
    4be4:	53050513          	addi	a0,a0,1328 # 8110 <malloc+0x22e8>
    4be8:	188010ef          	jal	5d70 <printf>
        exit(1);
    4bec:	4505                	li	a0,1
    4bee:	52d000ef          	jal	591a <exit>

0000000000004bf2 <lazy_copy>:
{
    4bf2:	7119                	addi	sp,sp,-128
    4bf4:	fc86                	sd	ra,120(sp)
    4bf6:	f8a2                	sd	s0,112(sp)
    4bf8:	f4a6                	sd	s1,104(sp)
    4bfa:	f0ca                	sd	s2,96(sp)
    4bfc:	ecce                	sd	s3,88(sp)
    4bfe:	e8d2                	sd	s4,80(sp)
    4c00:	e4d6                	sd	s5,72(sp)
    4c02:	e0da                	sd	s6,64(sp)
    4c04:	fc5e                	sd	s7,56(sp)
    4c06:	0100                	addi	s0,sp,128
    char *p = sbrk(0);
    4c08:	4501                	li	a0,0
    4c0a:	4dd000ef          	jal	58e6 <sbrk>
    4c0e:	84aa                	mv	s1,a0
    sbrklazy(4 * PGSIZE);
    4c10:	6511                	lui	a0,0x4
    4c12:	4eb000ef          	jal	58fc <sbrklazy>
    open(p + 8192, 0);
    4c16:	4581                	li	a1,0
    4c18:	6509                	lui	a0,0x2
    4c1a:	9526                	add	a0,a0,s1
    4c1c:	53f000ef          	jal	595a <open>
    void *xx = sbrk(0);
    4c20:	4501                	li	a0,0
    4c22:	4c5000ef          	jal	58e6 <sbrk>
    4c26:	84aa                	mv	s1,a0
    void *ret = sbrk(-(((uint64)xx) + 1));
    4c28:	fff54513          	not	a0,a0
    4c2c:	2501                	sext.w	a0,a0
    4c2e:	4b9000ef          	jal	58e6 <sbrk>
    if (ret != xx) {
    4c32:	00a48c63          	beq	s1,a0,4c4a <lazy_copy+0x58>
    4c36:	85aa                	mv	a1,a0
      printf("sbrk(sbrk(0)+1) returned %p, not old sz\n", ret);
    4c38:	00003517          	auipc	a0,0x3
    4c3c:	4f050513          	addi	a0,a0,1264 # 8128 <malloc+0x2300>
    4c40:	130010ef          	jal	5d70 <printf>
      exit(1);
    4c44:	4505                	li	a0,1
    4c46:	4d5000ef          	jal	591a <exit>
  unsigned long bad[] = {
    4c4a:	00004797          	auipc	a5,0x4
    4c4e:	cc678793          	addi	a5,a5,-826 # 8910 <malloc+0x2ae8>
    4c52:	7fa8                	ld	a0,120(a5)
    4c54:	63cc                	ld	a1,128(a5)
    4c56:	67d0                	ld	a2,136(a5)
    4c58:	6bd4                	ld	a3,144(a5)
    4c5a:	6fd8                	ld	a4,152(a5)
    4c5c:	f8a43023          	sd	a0,-128(s0)
    4c60:	f8b43423          	sd	a1,-120(s0)
    4c64:	f8c43823          	sd	a2,-112(s0)
    4c68:	f8d43c23          	sd	a3,-104(s0)
    4c6c:	fae43023          	sd	a4,-96(s0)
    4c70:	73dc                	ld	a5,160(a5)
    4c72:	faf43423          	sd	a5,-88(s0)
  for (int i = 0; i < sizeof(bad) / sizeof(bad[0]); i++) {
    4c76:	f8040913          	addi	s2,s0,-128
    int fd = open("README", 0);
    4c7a:	00001a97          	auipc	s5,0x1
    4c7e:	4b6a8a93          	addi	s5,s5,1206 # 6130 <malloc+0x308>
    if (read(fd, (char *)bad[i], 512) >= 0) {
    4c82:	20000a13          	li	s4,512
    fd = open("junk", O_CREATE | O_RDWR | O_TRUNC);
    4c86:	60200b93          	li	s7,1538
    4c8a:	00001b17          	auipc	s6,0x1
    4c8e:	3b6b0b13          	addi	s6,s6,950 # 6040 <malloc+0x218>
    int fd = open("README", 0);
    4c92:	4581                	li	a1,0
    4c94:	8556                	mv	a0,s5
    4c96:	4c5000ef          	jal	595a <open>
    4c9a:	84aa                	mv	s1,a0
    if (fd < 0) {
    4c9c:	04054563          	bltz	a0,4ce6 <lazy_copy+0xf4>
    if (read(fd, (char *)bad[i], 512) >= 0) {
    4ca0:	00093983          	ld	s3,0(s2)
    4ca4:	8652                	mv	a2,s4
    4ca6:	85ce                	mv	a1,s3
    4ca8:	48b000ef          	jal	5932 <read>
    4cac:	04055663          	bgez	a0,4cf8 <lazy_copy+0x106>
    close(fd);
    4cb0:	8526                	mv	a0,s1
    4cb2:	491000ef          	jal	5942 <close>
    fd = open("junk", O_CREATE | O_RDWR | O_TRUNC);
    4cb6:	85de                	mv	a1,s7
    4cb8:	855a                	mv	a0,s6
    4cba:	4a1000ef          	jal	595a <open>
    4cbe:	84aa                	mv	s1,a0
    if (fd < 0) {
    4cc0:	04054563          	bltz	a0,4d0a <lazy_copy+0x118>
    if (write(fd, (char *)bad[i], 512) >= 0) {
    4cc4:	8652                	mv	a2,s4
    4cc6:	85ce                	mv	a1,s3
    4cc8:	473000ef          	jal	593a <write>
    4ccc:	04055863          	bgez	a0,4d1c <lazy_copy+0x12a>
    close(fd);
    4cd0:	8526                	mv	a0,s1
    4cd2:	471000ef          	jal	5942 <close>
  for (int i = 0; i < sizeof(bad) / sizeof(bad[0]); i++) {
    4cd6:	0921                	addi	s2,s2,8
    4cd8:	fb040793          	addi	a5,s0,-80
    4cdc:	faf91be3          	bne	s2,a5,4c92 <lazy_copy+0xa0>
  exit(0);
    4ce0:	4501                	li	a0,0
    4ce2:	439000ef          	jal	591a <exit>
      printf("cannot open README\n");
    4ce6:	00003517          	auipc	a0,0x3
    4cea:	47250513          	addi	a0,a0,1138 # 8158 <malloc+0x2330>
    4cee:	082010ef          	jal	5d70 <printf>
      exit(1);
    4cf2:	4505                	li	a0,1
    4cf4:	427000ef          	jal	591a <exit>
      printf("read succeeded\n");
    4cf8:	00003517          	auipc	a0,0x3
    4cfc:	47850513          	addi	a0,a0,1144 # 8170 <malloc+0x2348>
    4d00:	070010ef          	jal	5d70 <printf>
      exit(1);
    4d04:	4505                	li	a0,1
    4d06:	415000ef          	jal	591a <exit>
      printf("cannot open junk\n");
    4d0a:	00003517          	auipc	a0,0x3
    4d0e:	47650513          	addi	a0,a0,1142 # 8180 <malloc+0x2358>
    4d12:	05e010ef          	jal	5d70 <printf>
      exit(1);
    4d16:	4505                	li	a0,1
    4d18:	403000ef          	jal	591a <exit>
      printf("write succeeded\n");
    4d1c:	00003517          	auipc	a0,0x3
    4d20:	47c50513          	addi	a0,a0,1148 # 8198 <malloc+0x2370>
    4d24:	04c010ef          	jal	5d70 <printf>
      exit(1);
    4d28:	4505                	li	a0,1
    4d2a:	3f1000ef          	jal	591a <exit>

0000000000004d2e <lazy_sbrk>:
{
    4d2e:	7179                	addi	sp,sp,-48
    4d30:	f406                	sd	ra,40(sp)
    4d32:	f022                	sd	s0,32(sp)
    4d34:	ec26                	sd	s1,24(sp)
    4d36:	e84a                	sd	s2,16(sp)
    4d38:	e44e                	sd	s3,8(sp)
    4d3a:	e052                	sd	s4,0(sp)
    4d3c:	1800                	addi	s0,sp,48
  char *p = sbrk(0);
    4d3e:	4501                	li	a0,0
    4d40:	3a7000ef          	jal	58e6 <sbrk>
    4d44:	84aa                	mv	s1,a0
  while ((uint64)p < MAXVA - (1 << 30)) {
    4d46:	0ff00793          	li	a5,255
    4d4a:	07fa                	slli	a5,a5,0x1e
    4d4c:	02f57163          	bgeu	a0,a5,4d6e <lazy_sbrk+0x40>
    p = sbrklazy(1 << 30);
    4d50:	40000a37          	lui	s4,0x40000
    if (p == SBRK_ERROR) {
    4d54:	59fd                	li	s3,-1
  while ((uint64)p < MAXVA - (1 << 30)) {
    4d56:	893e                	mv	s2,a5
    p = sbrklazy(1 << 30);
    4d58:	8552                	mv	a0,s4
    4d5a:	3a3000ef          	jal	58fc <sbrklazy>
    if (p == SBRK_ERROR) {
    4d5e:	05350763          	beq	a0,s3,4dac <lazy_sbrk+0x7e>
    p = sbrklazy(0);
    4d62:	4501                	li	a0,0
    4d64:	399000ef          	jal	58fc <sbrklazy>
    4d68:	84aa                	mv	s1,a0
  while ((uint64)p < MAXVA - (1 << 30)) {
    4d6a:	ff2567e3          	bltu	a0,s2,4d58 <lazy_sbrk+0x2a>
  int n = TRAPFRAME - PGSIZE - (uint64)p;
    4d6e:	7975                	lui	s2,0xffffd
    4d70:	4099093b          	subw	s2,s2,s1
  char *p1 = sbrklazy(n);
    4d74:	854a                	mv	a0,s2
    4d76:	387000ef          	jal	58fc <sbrklazy>
  if (p1 == SBRK_ERROR || p1 != p) {
    4d7a:	00150793          	addi	a5,a0,1
    4d7e:	c3b9                	beqz	a5,4dc4 <lazy_sbrk+0x96>
    4d80:	04951263          	bne	a0,s1,4dc4 <lazy_sbrk+0x96>
  p = sbrk(PGSIZE);
    4d84:	6505                	lui	a0,0x1
    4d86:	361000ef          	jal	58e6 <sbrk>
    4d8a:	862a                	mv	a2,a0
  if (p == SBRK_ERROR || (uint64)p != TRAPFRAME - PGSIZE) {
    4d8c:	040007b7          	lui	a5,0x4000
    4d90:	17f5                	addi	a5,a5,-3 # 3fffffd <base+0x3fee2f5>
    4d92:	07b2                	slli	a5,a5,0xc
    4d94:	04f50463          	beq	a0,a5,4ddc <lazy_sbrk+0xae>
    printf("sbrk(%d) returned %p, not expected TRAPFRAME-PGSIZE\n", PGSIZE, p);
    4d98:	6585                	lui	a1,0x1
    4d9a:	00003517          	auipc	a0,0x3
    4d9e:	46650513          	addi	a0,a0,1126 # 8200 <malloc+0x23d8>
    4da2:	7cf000ef          	jal	5d70 <printf>
    exit(1);
    4da6:	4505                	li	a0,1
    4da8:	373000ef          	jal	591a <exit>
      printf("sbrklazy(%d) returned %p\n", 1 << 30, p);
    4dac:	567d                	li	a2,-1
    4dae:	400005b7          	lui	a1,0x40000
    4db2:	00003517          	auipc	a0,0x3
    4db6:	3fe50513          	addi	a0,a0,1022 # 81b0 <malloc+0x2388>
    4dba:	7b7000ef          	jal	5d70 <printf>
      exit(1);
    4dbe:	4505                	li	a0,1
    4dc0:	35b000ef          	jal	591a <exit>
    printf("sbrklazy(%d) returned %p, not expected %p\n", n, p1, p);
    4dc4:	86a6                	mv	a3,s1
    4dc6:	862a                	mv	a2,a0
    4dc8:	85ca                	mv	a1,s2
    4dca:	00003517          	auipc	a0,0x3
    4dce:	40650513          	addi	a0,a0,1030 # 81d0 <malloc+0x23a8>
    4dd2:	79f000ef          	jal	5d70 <printf>
    exit(1);
    4dd6:	4505                	li	a0,1
    4dd8:	343000ef          	jal	591a <exit>
  p[0] = 1;
    4ddc:	040007b7          	lui	a5,0x4000
    4de0:	17f5                	addi	a5,a5,-3 # 3fffffd <base+0x3fee2f5>
    4de2:	07b2                	slli	a5,a5,0xc
    4de4:	4705                	li	a4,1
    4de6:	00e78023          	sb	a4,0(a5)
  if (p[1] != 0) {
    4dea:	0017c783          	lbu	a5,1(a5)
    4dee:	cb91                	beqz	a5,4e02 <lazy_sbrk+0xd4>
    printf("sbrk() returned non-zero-filled memory\n");
    4df0:	00003517          	auipc	a0,0x3
    4df4:	44850513          	addi	a0,a0,1096 # 8238 <malloc+0x2410>
    4df8:	779000ef          	jal	5d70 <printf>
    exit(1);
    4dfc:	4505                	li	a0,1
    4dfe:	31d000ef          	jal	591a <exit>
  p = sbrk(1);
    4e02:	4505                	li	a0,1
    4e04:	2e3000ef          	jal	58e6 <sbrk>
    4e08:	85aa                	mv	a1,a0
  if ((uint64)p != -1) {
    4e0a:	57fd                	li	a5,-1
    4e0c:	00f50b63          	beq	a0,a5,4e22 <lazy_sbrk+0xf4>
    printf("sbrk(1) returned %p, expected error\n", p);
    4e10:	00003517          	auipc	a0,0x3
    4e14:	45050513          	addi	a0,a0,1104 # 8260 <malloc+0x2438>
    4e18:	759000ef          	jal	5d70 <printf>
    exit(1);
    4e1c:	4505                	li	a0,1
    4e1e:	2fd000ef          	jal	591a <exit>
  p = sbrklazy(1);
    4e22:	4505                	li	a0,1
    4e24:	2d9000ef          	jal	58fc <sbrklazy>
    4e28:	85aa                	mv	a1,a0
  if ((uint64)p != -1) {
    4e2a:	57fd                	li	a5,-1
    4e2c:	00f50b63          	beq	a0,a5,4e42 <lazy_sbrk+0x114>
    printf("sbrklazy(1) returned %p, expected error\n", p);
    4e30:	00003517          	auipc	a0,0x3
    4e34:	45850513          	addi	a0,a0,1112 # 8288 <malloc+0x2460>
    4e38:	739000ef          	jal	5d70 <printf>
    exit(1);
    4e3c:	4505                	li	a0,1
    4e3e:	2dd000ef          	jal	591a <exit>
  exit(0);
    4e42:	4501                	li	a0,0
    4e44:	2d7000ef          	jal	591a <exit>

0000000000004e48 <lazy_copyinstr>:
{
    4e48:	715d                	addi	sp,sp,-80
    4e4a:	e486                	sd	ra,72(sp)
    4e4c:	e0a2                	sd	s0,64(sp)
    4e4e:	fc26                	sd	s1,56(sp)
    4e50:	f84a                	sd	s2,48(sp)
    4e52:	f44e                	sd	s3,40(sp)
    4e54:	0880                	addi	s0,sp,80
    4e56:	89aa                	mv	s3,a0
  char *p = sbrk(0);
    4e58:	4501                	li	a0,0
    4e5a:	28d000ef          	jal	58e6 <sbrk>
  sbrk(PGSIZE - ((uint64)p % PGSIZE));
    4e5e:	6485                	lui	s1,0x1
    4e60:	14fd                	addi	s1,s1,-1 # fff <bigdir+0x10b>
    4e62:	009577b3          	and	a5,a0,s1
    4e66:	6505                	lui	a0,0x1
    4e68:	9d1d                	subw	a0,a0,a5
    4e6a:	27d000ef          	jal	58e6 <sbrk>
  p = sbrk(0);
    4e6e:	4501                	li	a0,0
    4e70:	277000ef          	jal	58e6 <sbrk>
  if ((uint64)p % PGSIZE != 0) {
    4e74:	8ce9                	and	s1,s1,a0
    4e76:	e8a9                	bnez	s1,4ec8 <lazy_copyinstr+0x80>
    4e78:	892a                	mv	s2,a0
  sbrklazy(2 * PGSIZE);
    4e7a:	6509                	lui	a0,0x2
    4e7c:	281000ef          	jal	58fc <sbrklazy>
  p[4095] = '/';
    4e80:	6505                	lui	a0,0x1
    4e82:	00a907b3          	add	a5,s2,a0
    4e86:	02f00713          	li	a4,47
    4e8a:	fee78fa3          	sb	a4,-1(a5)
  int fd = open(&p[4095], O_RDONLY);
    4e8e:	157d                	addi	a0,a0,-1 # fff <bigdir+0x10b>
    4e90:	4581                	li	a1,0
    4e92:	954a                	add	a0,a0,s2
    4e94:	2c7000ef          	jal	595a <open>
    4e98:	84aa                	mv	s1,a0
  if (fd < 0) {
    4e9a:	04054163          	bltz	a0,4edc <lazy_copyinstr+0x94>
  int r = fstat(fd, &st);
    4e9e:	fb840593          	addi	a1,s0,-72
    4ea2:	2d1000ef          	jal	5972 <fstat>
  if (r < 0) {
    4ea6:	04054463          	bltz	a0,4eee <lazy_copyinstr+0xa6>
  if (st.type != T_DIR) {
    4eaa:	fc041703          	lh	a4,-64(s0)
    4eae:	4785                	li	a5,1
    4eb0:	04f71863          	bne	a4,a5,4f00 <lazy_copyinstr+0xb8>
  close(fd);
    4eb4:	8526                	mv	a0,s1
    4eb6:	28d000ef          	jal	5942 <close>
}
    4eba:	60a6                	ld	ra,72(sp)
    4ebc:	6406                	ld	s0,64(sp)
    4ebe:	74e2                	ld	s1,56(sp)
    4ec0:	7942                	ld	s2,48(sp)
    4ec2:	79a2                	ld	s3,40(sp)
    4ec4:	6161                	addi	sp,sp,80
    4ec6:	8082                	ret
    printf("%s: sbrk did not align\n", s);
    4ec8:	85ce                	mv	a1,s3
    4eca:	00003517          	auipc	a0,0x3
    4ece:	13e50513          	addi	a0,a0,318 # 8008 <malloc+0x21e0>
    4ed2:	69f000ef          	jal	5d70 <printf>
    exit(1);
    4ed6:	4505                	li	a0,1
    4ed8:	243000ef          	jal	591a <exit>
    printf("could not open /");
    4edc:	00003517          	auipc	a0,0x3
    4ee0:	3dc50513          	addi	a0,a0,988 # 82b8 <malloc+0x2490>
    4ee4:	68d000ef          	jal	5d70 <printf>
    exit(1);
    4ee8:	4505                	li	a0,1
    4eea:	231000ef          	jal	591a <exit>
    printf("could not stat /");
    4eee:	00003517          	auipc	a0,0x3
    4ef2:	3e250513          	addi	a0,a0,994 # 82d0 <malloc+0x24a8>
    4ef6:	67b000ef          	jal	5d70 <printf>
    exit(1);
    4efa:	4505                	li	a0,1
    4efc:	21f000ef          	jal	591a <exit>
    printf("/ is not T_DIR");
    4f00:	00003517          	auipc	a0,0x3
    4f04:	3e850513          	addi	a0,a0,1000 # 82e8 <malloc+0x24c0>
    4f08:	669000ef          	jal	5d70 <printf>
    exit(1);
    4f0c:	4505                	li	a0,1
    4f0e:	20d000ef          	jal	591a <exit>

0000000000004f12 <fsfull>:
{
    4f12:	7131                	addi	sp,sp,-192
    4f14:	fd06                	sd	ra,184(sp)
    4f16:	f922                	sd	s0,176(sp)
    4f18:	f526                	sd	s1,168(sp)
    4f1a:	f14a                	sd	s2,160(sp)
    4f1c:	ed4e                	sd	s3,152(sp)
    4f1e:	e952                	sd	s4,144(sp)
    4f20:	e556                	sd	s5,136(sp)
    4f22:	e15a                	sd	s6,128(sp)
    4f24:	fcde                	sd	s7,120(sp)
    4f26:	f8e2                	sd	s8,112(sp)
    4f28:	f4e6                	sd	s9,104(sp)
    4f2a:	f0ea                	sd	s10,96(sp)
    4f2c:	ecee                	sd	s11,88(sp)
    4f2e:	0180                	addi	s0,sp,192
  printf("fsfull test\n");
    4f30:	00003517          	auipc	a0,0x3
    4f34:	3c850513          	addi	a0,a0,968 # 82f8 <malloc+0x24d0>
    4f38:	639000ef          	jal	5d70 <printf>
  int fsblocks = 0;
    4f3c:	4981                	li	s3,0
  for (nfiles = 0;; nfiles++) {
    4f3e:	4481                	li	s1,0
    name[0] = 'f';
    4f40:	06600d93          	li	s11,102
    name[1] = '0' + nfiles / 1000;
    4f44:	106257b7          	lui	a5,0x10625
    4f48:	dd378793          	addi	a5,a5,-557 # 10624dd3 <base+0x106130cb>
    4f4c:	f4f43423          	sd	a5,-184(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4f50:	51eb8b37          	lui	s6,0x51eb8
    4f54:	51fb0b13          	addi	s6,s6,1311 # 51eb851f <base+0x51ea6817>
    name[3] = '0' + (nfiles % 100) / 10;
    4f58:	66666ab7          	lui	s5,0x66666
    4f5c:	667a8a93          	addi	s5,s5,1639 # 66666667 <base+0x6665495f>
    printf("writing %s\n", name);
    4f60:	f5040d13          	addi	s10,s0,-176
    name[0] = 'f';
    4f64:	f5b40823          	sb	s11,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4f68:	f4843783          	ld	a5,-184(s0)
    4f6c:	02f487b3          	mul	a5,s1,a5
    4f70:	9799                	srai	a5,a5,0x26
    4f72:	41f4d69b          	sraiw	a3,s1,0x1f
    4f76:	9f95                	subw	a5,a5,a3
    4f78:	0307871b          	addiw	a4,a5,48
    4f7c:	f4e408a3          	sb	a4,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4f80:	3e800713          	li	a4,1000
    4f84:	02f707bb          	mulw	a5,a4,a5
    4f88:	40f487bb          	subw	a5,s1,a5
    4f8c:	03678733          	mul	a4,a5,s6
    4f90:	9715                	srai	a4,a4,0x25
    4f92:	41f7d79b          	sraiw	a5,a5,0x1f
    4f96:	40f707bb          	subw	a5,a4,a5
    4f9a:	0307879b          	addiw	a5,a5,48
    4f9e:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4fa2:	036487b3          	mul	a5,s1,s6
    4fa6:	9795                	srai	a5,a5,0x25
    4fa8:	9f95                	subw	a5,a5,a3
    4faa:	06400713          	li	a4,100
    4fae:	02f707bb          	mulw	a5,a4,a5
    4fb2:	40f487bb          	subw	a5,s1,a5
    4fb6:	03578733          	mul	a4,a5,s5
    4fba:	9709                	srai	a4,a4,0x22
    4fbc:	41f7d79b          	sraiw	a5,a5,0x1f
    4fc0:	40f707bb          	subw	a5,a4,a5
    4fc4:	0307879b          	addiw	a5,a5,48
    4fc8:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4fcc:	03548733          	mul	a4,s1,s5
    4fd0:	9709                	srai	a4,a4,0x22
    4fd2:	9f15                	subw	a4,a4,a3
    4fd4:	0027179b          	slliw	a5,a4,0x2
    4fd8:	9fb9                	addw	a5,a5,a4
    4fda:	0017979b          	slliw	a5,a5,0x1
    4fde:	40f487bb          	subw	a5,s1,a5
    4fe2:	0307879b          	addiw	a5,a5,48
    4fe6:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4fea:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    4fee:	85ea                	mv	a1,s10
    4ff0:	00003517          	auipc	a0,0x3
    4ff4:	31850513          	addi	a0,a0,792 # 8308 <malloc+0x24e0>
    4ff8:	579000ef          	jal	5d70 <printf>
    int fd = open(name, O_CREATE | O_RDWR);
    4ffc:	20200593          	li	a1,514
    5000:	856a                	mv	a0,s10
    5002:	159000ef          	jal	595a <open>
    5006:	892a                	mv	s2,a0
    if (fd < 0) {
    5008:	0e055c63          	bgez	a0,5100 <fsfull+0x1ee>
      printf("open %s failed\n", name);
    500c:	f5040593          	addi	a1,s0,-176
    5010:	00003517          	auipc	a0,0x3
    5014:	30850513          	addi	a0,a0,776 # 8318 <malloc+0x24f0>
    5018:	559000ef          	jal	5d70 <printf>
  while (nfiles >= 0) {
    501c:	0a04cc63          	bltz	s1,50d4 <fsfull+0x1c2>
    name[0] = 'f';
    5020:	06600c93          	li	s9,102
    name[1] = '0' + nfiles / 1000;
    5024:	10625ab7          	lui	s5,0x10625
    5028:	dd3a8a93          	addi	s5,s5,-557 # 10624dd3 <base+0x106130cb>
    name[2] = '0' + (nfiles % 1000) / 100;
    502c:	3e800c13          	li	s8,1000
    5030:	51eb8a37          	lui	s4,0x51eb8
    5034:	51fa0a13          	addi	s4,s4,1311 # 51eb851f <base+0x51ea6817>
    name[3] = '0' + (nfiles % 100) / 10;
    5038:	06400b93          	li	s7,100
    503c:	66666937          	lui	s2,0x66666
    5040:	66790913          	addi	s2,s2,1639 # 66666667 <base+0x6665495f>
    unlink(name);
    5044:	f5040b13          	addi	s6,s0,-176
    name[0] = 'f';
    5048:	f5940823          	sb	s9,-176(s0)
    name[1] = '0' + nfiles / 1000;
    504c:	035487b3          	mul	a5,s1,s5
    5050:	9799                	srai	a5,a5,0x26
    5052:	41f4d69b          	sraiw	a3,s1,0x1f
    5056:	9f95                	subw	a5,a5,a3
    5058:	0307871b          	addiw	a4,a5,48
    505c:	f4e408a3          	sb	a4,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    5060:	02fc07bb          	mulw	a5,s8,a5
    5064:	40f487bb          	subw	a5,s1,a5
    5068:	03478733          	mul	a4,a5,s4
    506c:	9715                	srai	a4,a4,0x25
    506e:	41f7d79b          	sraiw	a5,a5,0x1f
    5072:	40f707bb          	subw	a5,a4,a5
    5076:	0307879b          	addiw	a5,a5,48
    507a:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    507e:	034487b3          	mul	a5,s1,s4
    5082:	9795                	srai	a5,a5,0x25
    5084:	9f95                	subw	a5,a5,a3
    5086:	02fb87bb          	mulw	a5,s7,a5
    508a:	40f487bb          	subw	a5,s1,a5
    508e:	03278733          	mul	a4,a5,s2
    5092:	9709                	srai	a4,a4,0x22
    5094:	41f7d79b          	sraiw	a5,a5,0x1f
    5098:	40f707bb          	subw	a5,a4,a5
    509c:	0307879b          	addiw	a5,a5,48
    50a0:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    50a4:	03248733          	mul	a4,s1,s2
    50a8:	9709                	srai	a4,a4,0x22
    50aa:	9f15                	subw	a4,a4,a3
    50ac:	0027179b          	slliw	a5,a4,0x2
    50b0:	9fb9                	addw	a5,a5,a4
    50b2:	0017979b          	slliw	a5,a5,0x1
    50b6:	40f487bb          	subw	a5,s1,a5
    50ba:	0307879b          	addiw	a5,a5,48
    50be:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    50c2:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    50c6:	855a                	mv	a0,s6
    50c8:	0a3000ef          	jal	596a <unlink>
    nfiles--;
    50cc:	34fd                	addiw	s1,s1,-1
  while (nfiles >= 0) {
    50ce:	57fd                	li	a5,-1
    50d0:	f6f49ce3          	bne	s1,a5,5048 <fsfull+0x136>
  printf("fsfull test finished, %d blocks\n", fsblocks);
    50d4:	85ce                	mv	a1,s3
    50d6:	00003517          	auipc	a0,0x3
    50da:	26250513          	addi	a0,a0,610 # 8338 <malloc+0x2510>
    50de:	493000ef          	jal	5d70 <printf>
}
    50e2:	70ea                	ld	ra,184(sp)
    50e4:	744a                	ld	s0,176(sp)
    50e6:	74aa                	ld	s1,168(sp)
    50e8:	790a                	ld	s2,160(sp)
    50ea:	69ea                	ld	s3,152(sp)
    50ec:	6a4a                	ld	s4,144(sp)
    50ee:	6aaa                	ld	s5,136(sp)
    50f0:	6b0a                	ld	s6,128(sp)
    50f2:	7be6                	ld	s7,120(sp)
    50f4:	7c46                	ld	s8,112(sp)
    50f6:	7ca6                	ld	s9,104(sp)
    50f8:	7d06                	ld	s10,96(sp)
    50fa:	6de6                	ld	s11,88(sp)
    50fc:	6129                	addi	sp,sp,192
    50fe:	8082                	ret
    int total = 0;
    5100:	4a01                	li	s4,0
      int cc = write(fd, buf, BSIZE);
    5102:	40000c93          	li	s9,1024
    5106:	0000ac17          	auipc	s8,0xa
    510a:	c02c0c13          	addi	s8,s8,-1022 # ed08 <buf>
      if (cc < BSIZE)
    510e:	3ff00b93          	li	s7,1023
      int cc = write(fd, buf, BSIZE);
    5112:	8666                	mv	a2,s9
    5114:	85e2                	mv	a1,s8
    5116:	854a                	mv	a0,s2
    5118:	023000ef          	jal	593a <write>
      if (cc < BSIZE)
    511c:	00abd663          	bge	s7,a0,5128 <fsfull+0x216>
      total += cc;
    5120:	00aa0a3b          	addw	s4,s4,a0
      fsblocks++;
    5124:	2985                	addiw	s3,s3,1
    while (1) {
    5126:	b7f5                	j	5112 <fsfull+0x200>
    printf("wrote %d bytes\n", total);
    5128:	85d2                	mv	a1,s4
    512a:	00003517          	auipc	a0,0x3
    512e:	1fe50513          	addi	a0,a0,510 # 8328 <malloc+0x2500>
    5132:	43f000ef          	jal	5d70 <printf>
    close(fd);
    5136:	854a                	mv	a0,s2
    5138:	00b000ef          	jal	5942 <close>
    if (total == 0)
    513c:	ee0a00e3          	beqz	s4,501c <fsfull+0x10a>
  for (nfiles = 0;; nfiles++) {
    5140:	2485                	addiw	s1,s1,1
    5142:	b50d                	j	4f64 <fsfull+0x52>

0000000000005144 <linkoverflow>:

void
linkoverflow(char *s)
{
    5144:	7175                	addi	sp,sp,-144
    5146:	e506                	sd	ra,136(sp)
    5148:	e122                	sd	s0,128(sp)
    514a:	fca6                	sd	s1,120(sp)
    514c:	f8ca                	sd	s2,112(sp)
    514e:	f4ce                	sd	s3,104(sp)
    5150:	f0d2                	sd	s4,96(sp)
    5152:	ecd6                	sd	s5,88(sp)
    5154:	e8da                	sd	s6,80(sp)
    5156:	e4de                	sd	s7,72(sp)
    5158:	e0e2                	sd	s8,64(sp)
    515a:	fc66                	sd	s9,56(sp)
    515c:	f86a                	sd	s10,48(sp)
    515e:	0900                	addi	s0,sp,144
    5160:	8d2a                	mv	s10,a0
  enum { TARGET = 32768 };
  enum { DIRS = 64 };
  struct stat st;
  int i;

  unlink("/lof");
    5162:	00003517          	auipc	a0,0x3
    5166:	1fe50513          	addi	a0,a0,510 # 8360 <malloc+0x2538>
    516a:	001000ef          	jal	596a <unlink>
  int fd = open("/lof", O_CREATE | O_RDWR);
    516e:	20200593          	li	a1,514
    5172:	00003517          	auipc	a0,0x3
    5176:	1ee50513          	addi	a0,a0,494 # 8360 <malloc+0x2538>
    517a:	7e0000ef          	jal	595a <open>
  if (fd < 0) {
    517e:	02054863          	bltz	a0,51ae <linkoverflow+0x6a>
    printf("%s: cannot create /lof\n", s);
    exit(1);
  }
  close(fd);
    5182:	7c0000ef          	jal	5942 <close>

  for (i = 0; i < TARGET; i++) {
    5186:	4901                	li	s2,0
    int d = i % DIRS;
    int f = i / DIRS;

    char pn[16];
    pn[0] = '/';
    5188:	02f00993          	li	s3,47
    pn[1] = 'd';
    518c:	06400b93          	li	s7,100
    pn[2] = '_';
    5190:	05f00b13          	li	s6,95
    pn[3] = 'a' + (d / 16);
    pn[4] = 'a' + (d % 16);
    pn[5] = '\0';
    if (f == 0 && mkdir(pn) < 0) {
    5194:	f7840a13          	addi	s4,s0,-136
      printf("%s: mkdir(%s) failed\n", s, pn);
      exit(1);
    }

    pn[5] = '/';
    pn[6] = 'l';
    5198:	06c00c93          	li	s9,108
    pn[7] = 'a' + (f / 256);
    pn[8] = 'a' + ((f / 16) % 16);
    pn[9] = 'a' + (f % 16);
    pn[10] = '\0';

    if (link("/lof", pn) < 0) {
    519c:	00003c17          	auipc	s8,0x3
    51a0:	1c4c0c13          	addi	s8,s8,452 # 8360 <malloc+0x2538>
      }
      printf("%s: link failed after %d links (nlink=%d)\n", s, i, st.nlink);
      exit(1);
    }

    if (i % 100 == 0) {
    51a4:	51eb8ab7          	lui	s5,0x51eb8
    51a8:	51fa8a93          	addi	s5,s5,1311 # 51eb851f <base+0x51ea6817>
    51ac:	a869                	j	5246 <linkoverflow+0x102>
    printf("%s: cannot create /lof\n", s);
    51ae:	85ea                	mv	a1,s10
    51b0:	00003517          	auipc	a0,0x3
    51b4:	1b850513          	addi	a0,a0,440 # 8368 <malloc+0x2540>
    51b8:	3b9000ef          	jal	5d70 <printf>
    exit(1);
    51bc:	4505                	li	a0,1
    51be:	75c000ef          	jal	591a <exit>
    pn[5] = '/';
    51c2:	f7340ea3          	sb	s3,-131(s0)
    pn[6] = 'l';
    51c6:	f7940f23          	sb	s9,-130(s0)
    pn[7] = 'a' + (f / 256);
    51ca:	41f9579b          	sraiw	a5,s2,0x1f
    51ce:	0127d79b          	srliw	a5,a5,0x12
    51d2:	012787bb          	addw	a5,a5,s2
    51d6:	40e7d79b          	sraiw	a5,a5,0xe
    51da:	0617879b          	addiw	a5,a5,97
    51de:	f6f40fa3          	sb	a5,-129(s0)
    pn[8] = 'a' + ((f / 16) % 16);
    51e2:	41f4d71b          	sraiw	a4,s1,0x1f
    51e6:	01c7571b          	srliw	a4,a4,0x1c
    51ea:	9cb9                	addw	s1,s1,a4
    51ec:	4044d79b          	sraiw	a5,s1,0x4
    51f0:	41f7d69b          	sraiw	a3,a5,0x1f
    51f4:	01c6d69b          	srliw	a3,a3,0x1c
    51f8:	9fb5                	addw	a5,a5,a3
    51fa:	8bbd                	andi	a5,a5,15
    51fc:	9f95                	subw	a5,a5,a3
    51fe:	0617879b          	addiw	a5,a5,97
    5202:	f8f40023          	sb	a5,-128(s0)
    pn[9] = 'a' + (f % 16);
    5206:	88bd                	andi	s1,s1,15
    5208:	9c99                	subw	s1,s1,a4
    520a:	0614849b          	addiw	s1,s1,97
    520e:	f89400a3          	sb	s1,-127(s0)
    pn[10] = '\0';
    5212:	f8040123          	sb	zero,-126(s0)
    if (link("/lof", pn) < 0) {
    5216:	85d2                	mv	a1,s4
    5218:	8562                	mv	a0,s8
    521a:	760000ef          	jal	597a <link>
    521e:	08054a63          	bltz	a0,52b2 <linkoverflow+0x16e>
    if (i % 100 == 0) {
    5222:	03590733          	mul	a4,s2,s5
    5226:	9715                	srai	a4,a4,0x25
    5228:	41f9579b          	sraiw	a5,s2,0x1f
    522c:	9f1d                	subw	a4,a4,a5
    522e:	06400793          	li	a5,100
    5232:	02e787bb          	mulw	a5,a5,a4
    5236:	40f907bb          	subw	a5,s2,a5
    523a:	10078363          	beqz	a5,5340 <linkoverflow+0x1fc>
  for (i = 0; i < TARGET; i++) {
    523e:	2905                	addiw	s2,s2,1
    5240:	67a1                	lui	a5,0x8
    5242:	08f90863          	beq	s2,a5,52d2 <linkoverflow+0x18e>
    int d = i % DIRS;
    5246:	41f9571b          	sraiw	a4,s2,0x1f
    524a:	01a7571b          	srliw	a4,a4,0x1a
    524e:	012704bb          	addw	s1,a4,s2
    5252:	03f4f793          	andi	a5,s1,63
    5256:	9f99                	subw	a5,a5,a4
    int f = i / DIRS;
    5258:	4064d49b          	sraiw	s1,s1,0x6
    pn[0] = '/';
    525c:	f7340c23          	sb	s3,-136(s0)
    pn[1] = 'd';
    5260:	f7740ca3          	sb	s7,-135(s0)
    pn[2] = '_';
    5264:	f7640d23          	sb	s6,-134(s0)
    pn[3] = 'a' + (d / 16);
    5268:	41f7d71b          	sraiw	a4,a5,0x1f
    526c:	01c7571b          	srliw	a4,a4,0x1c
    5270:	9fb9                	addw	a5,a5,a4
    5272:	4047d69b          	sraiw	a3,a5,0x4
    5276:	0616869b          	addiw	a3,a3,97 # 40061 <base+0x2e359>
    527a:	f6d40da3          	sb	a3,-133(s0)
    pn[4] = 'a' + (d % 16);
    527e:	8bbd                	andi	a5,a5,15
    5280:	9f99                	subw	a5,a5,a4
    5282:	0617879b          	addiw	a5,a5,97 # 8061 <malloc+0x2239>
    5286:	f6f40e23          	sb	a5,-132(s0)
    pn[5] = '\0';
    528a:	f6040ea3          	sb	zero,-131(s0)
    if (f == 0 && mkdir(pn) < 0) {
    528e:	f895                	bnez	s1,51c2 <linkoverflow+0x7e>
    5290:	8552                	mv	a0,s4
    5292:	6f0000ef          	jal	5982 <mkdir>
    5296:	f20556e3          	bgez	a0,51c2 <linkoverflow+0x7e>
      printf("%s: mkdir(%s) failed\n", s, pn);
    529a:	f7840613          	addi	a2,s0,-136
    529e:	85ea                	mv	a1,s10
    52a0:	00003517          	auipc	a0,0x3
    52a4:	0e050513          	addi	a0,a0,224 # 8380 <malloc+0x2558>
    52a8:	2c9000ef          	jal	5d70 <printf>
      exit(1);
    52ac:	4505                	li	a0,1
    52ae:	66c000ef          	jal	591a <exit>
      if (stat("/lof", &st) < 0) {
    52b2:	f8840593          	addi	a1,s0,-120
    52b6:	00003517          	auipc	a0,0x3
    52ba:	0aa50513          	addi	a0,a0,170 # 8360 <malloc+0x2538>
    52be:	4f6000ef          	jal	57b4 <stat>
    52c2:	04054a63          	bltz	a0,5316 <linkoverflow+0x1d2>
      if (st.nlink >= 32767) {
    52c6:	f9241683          	lh	a3,-110(s0)
    52ca:	67a1                	lui	a5,0x8
    52cc:	17fd                	addi	a5,a5,-1 # 7fff <malloc+0x21d7>
    52ce:	04f69e63          	bne	a3,a5,532a <linkoverflow+0x1e6>
      printf("%s: i=%d, pn=%s\n", s, i, pn);
    }
  }

  if (stat("/lof", &st) < 0) {
    52d2:	f8840593          	addi	a1,s0,-120
    52d6:	00003517          	auipc	a0,0x3
    52da:	08a50513          	addi	a0,a0,138 # 8360 <malloc+0x2538>
    52de:	4d6000ef          	jal	57b4 <stat>
    52e2:	06054963          	bltz	a0,5354 <linkoverflow+0x210>
    printf("%s: stat(/lof) failed\n", s);
    exit(1);
  }

  unlink("/lof");
    52e6:	00003517          	auipc	a0,0x3
    52ea:	07a50513          	addi	a0,a0,122 # 8360 <malloc+0x2538>
    52ee:	67c000ef          	jal	596a <unlink>

  if (st.nlink < 0) {
    52f2:	f9241603          	lh	a2,-110(s0)
    52f6:	06064963          	bltz	a2,5368 <linkoverflow+0x224>
    printf("%s: negative link count: %d\n", s, st.nlink);
    exit(1);
  }
}
    52fa:	60aa                	ld	ra,136(sp)
    52fc:	640a                	ld	s0,128(sp)
    52fe:	74e6                	ld	s1,120(sp)
    5300:	7946                	ld	s2,112(sp)
    5302:	79a6                	ld	s3,104(sp)
    5304:	7a06                	ld	s4,96(sp)
    5306:	6ae6                	ld	s5,88(sp)
    5308:	6b46                	ld	s6,80(sp)
    530a:	6ba6                	ld	s7,72(sp)
    530c:	6c06                	ld	s8,64(sp)
    530e:	7ce2                	ld	s9,56(sp)
    5310:	7d42                	ld	s10,48(sp)
    5312:	6149                	addi	sp,sp,144
    5314:	8082                	ret
        printf("%s: stat(/lof) failed\n", s);
    5316:	85ea                	mv	a1,s10
    5318:	00003517          	auipc	a0,0x3
    531c:	08050513          	addi	a0,a0,128 # 8398 <malloc+0x2570>
    5320:	251000ef          	jal	5d70 <printf>
        exit(1);
    5324:	4505                	li	a0,1
    5326:	5f4000ef          	jal	591a <exit>
      printf("%s: link failed after %d links (nlink=%d)\n", s, i, st.nlink);
    532a:	864a                	mv	a2,s2
    532c:	85ea                	mv	a1,s10
    532e:	00003517          	auipc	a0,0x3
    5332:	08250513          	addi	a0,a0,130 # 83b0 <malloc+0x2588>
    5336:	23b000ef          	jal	5d70 <printf>
      exit(1);
    533a:	4505                	li	a0,1
    533c:	5de000ef          	jal	591a <exit>
      printf("%s: i=%d, pn=%s\n", s, i, pn);
    5340:	86d2                	mv	a3,s4
    5342:	864a                	mv	a2,s2
    5344:	85ea                	mv	a1,s10
    5346:	00003517          	auipc	a0,0x3
    534a:	09a50513          	addi	a0,a0,154 # 83e0 <malloc+0x25b8>
    534e:	223000ef          	jal	5d70 <printf>
    5352:	b5f5                	j	523e <linkoverflow+0xfa>
    printf("%s: stat(/lof) failed\n", s);
    5354:	85ea                	mv	a1,s10
    5356:	00003517          	auipc	a0,0x3
    535a:	04250513          	addi	a0,a0,66 # 8398 <malloc+0x2570>
    535e:	213000ef          	jal	5d70 <printf>
    exit(1);
    5362:	4505                	li	a0,1
    5364:	5b6000ef          	jal	591a <exit>
    printf("%s: negative link count: %d\n", s, st.nlink);
    5368:	85ea                	mv	a1,s10
    536a:	00003517          	auipc	a0,0x3
    536e:	08e50513          	addi	a0,a0,142 # 83f8 <malloc+0x25d0>
    5372:	1ff000ef          	jal	5d70 <printf>
    exit(1);
    5376:	4505                	li	a0,1
    5378:	5a2000ef          	jal	591a <exit>

000000000000537c <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s)
{
    537c:	7179                	addi	sp,sp,-48
    537e:	f406                	sd	ra,40(sp)
    5380:	f022                	sd	s0,32(sp)
    5382:	ec26                	sd	s1,24(sp)
    5384:	e84a                	sd	s2,16(sp)
    5386:	1800                	addi	s0,sp,48
    5388:	84aa                	mv	s1,a0
    538a:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    538c:	00003517          	auipc	a0,0x3
    5390:	08c50513          	addi	a0,a0,140 # 8418 <malloc+0x25f0>
    5394:	1dd000ef          	jal	5d70 <printf>
  if ((pid = fork()) < 0) {
    5398:	57a000ef          	jal	5912 <fork>
    539c:	02054a63          	bltz	a0,53d0 <run+0x54>
    printf("runtest: fork error\n");
    exit(1);
  }
  if (pid == 0) {
    53a0:	c129                	beqz	a0,53e2 <run+0x66>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    53a2:	fdc40513          	addi	a0,s0,-36
    53a6:	57c000ef          	jal	5922 <wait>
    if (xstatus != 0)
    53aa:	fdc42783          	lw	a5,-36(s0)
    53ae:	cf9d                	beqz	a5,53ec <run+0x70>
      printf("FAILED\n");
    53b0:	00003517          	auipc	a0,0x3
    53b4:	09050513          	addi	a0,a0,144 # 8440 <malloc+0x2618>
    53b8:	1b9000ef          	jal	5d70 <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    53bc:	fdc42503          	lw	a0,-36(s0)
  }
}
    53c0:	00153513          	seqz	a0,a0
    53c4:	70a2                	ld	ra,40(sp)
    53c6:	7402                	ld	s0,32(sp)
    53c8:	64e2                	ld	s1,24(sp)
    53ca:	6942                	ld	s2,16(sp)
    53cc:	6145                	addi	sp,sp,48
    53ce:	8082                	ret
    printf("runtest: fork error\n");
    53d0:	00003517          	auipc	a0,0x3
    53d4:	05850513          	addi	a0,a0,88 # 8428 <malloc+0x2600>
    53d8:	199000ef          	jal	5d70 <printf>
    exit(1);
    53dc:	4505                	li	a0,1
    53de:	53c000ef          	jal	591a <exit>
    f(s);
    53e2:	854a                	mv	a0,s2
    53e4:	9482                	jalr	s1
    exit(0);
    53e6:	4501                	li	a0,0
    53e8:	532000ef          	jal	591a <exit>
      printf("OK\n");
    53ec:	00003517          	auipc	a0,0x3
    53f0:	05c50513          	addi	a0,a0,92 # 8448 <malloc+0x2620>
    53f4:	17d000ef          	jal	5d70 <printf>
    53f8:	b7d1                	j	53bc <run+0x40>

00000000000053fa <runtests>:

int
runtests(struct test *tests, char *justone, int continuous)
{
    53fa:	7179                	addi	sp,sp,-48
    53fc:	f406                	sd	ra,40(sp)
    53fe:	f022                	sd	s0,32(sp)
    5400:	ec26                	sd	s1,24(sp)
    5402:	e44e                	sd	s3,8(sp)
    5404:	1800                	addi	s0,sp,48
    5406:	84aa                	mv	s1,a0
  int ntests = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    5408:	6508                	ld	a0,8(a0)
    540a:	cd29                	beqz	a0,5464 <runtests+0x6a>
    540c:	e84a                	sd	s2,16(sp)
    540e:	e052                	sd	s4,0(sp)
    5410:	892e                	mv	s2,a1
    if ((justone == 0) || strcmp(t->s, justone) == 0) {
      ntests++;
      if (!run(t->f, t->s)) {
        if (continuous != 2) {
    5412:	1679                	addi	a2,a2,-2 # ffe <bigdir+0x10a>
    5414:	00c03a33          	snez	s4,a2
  int ntests = 0;
    5418:	4981                	li	s3,0
    541a:	a029                	j	5424 <runtests+0x2a>
      ntests++;
    541c:	2985                	addiw	s3,s3,1
  for (struct test *t = tests; t->s != 0; t++) {
    541e:	04c1                	addi	s1,s1,16
    5420:	6488                	ld	a0,8(s1)
    5422:	c905                	beqz	a0,5452 <runtests+0x58>
    if ((justone == 0) || strcmp(t->s, justone) == 0) {
    5424:	00090663          	beqz	s2,5430 <runtests+0x36>
    5428:	85ca                	mv	a1,s2
    542a:	26a000ef          	jal	5694 <strcmp>
    542e:	f965                	bnez	a0,541e <runtests+0x24>
      if (!run(t->f, t->s)) {
    5430:	648c                	ld	a1,8(s1)
    5432:	6088                	ld	a0,0(s1)
    5434:	f49ff0ef          	jal	537c <run>
        if (continuous != 2) {
    5438:	f175                	bnez	a0,541c <runtests+0x22>
    543a:	fe0a01e3          	beqz	s4,541c <runtests+0x22>
          printf("SOME TESTS FAILED\n");
    543e:	00003517          	auipc	a0,0x3
    5442:	01250513          	addi	a0,a0,18 # 8450 <malloc+0x2628>
    5446:	12b000ef          	jal	5d70 <printf>
          return -1;
    544a:	59fd                	li	s3,-1
    544c:	6942                	ld	s2,16(sp)
    544e:	6a02                	ld	s4,0(sp)
    5450:	a019                	j	5456 <runtests+0x5c>
    5452:	6942                	ld	s2,16(sp)
    5454:	6a02                	ld	s4,0(sp)
        }
      }
    }
  }
  return ntests;
}
    5456:	854e                	mv	a0,s3
    5458:	70a2                	ld	ra,40(sp)
    545a:	7402                	ld	s0,32(sp)
    545c:	64e2                	ld	s1,24(sp)
    545e:	69a2                	ld	s3,8(sp)
    5460:	6145                	addi	sp,sp,48
    5462:	8082                	ret
  return ntests;
    5464:	4981                	li	s3,0
    5466:	bfc5                	j	5456 <runtests+0x5c>

0000000000005468 <countfree>:

// use sbrk() to count how many free physical memory pages there are.
int
countfree()
{
    5468:	7179                	addi	sp,sp,-48
    546a:	f406                	sd	ra,40(sp)
    546c:	f022                	sd	s0,32(sp)
    546e:	ec26                	sd	s1,24(sp)
    5470:	e84a                	sd	s2,16(sp)
    5472:	e44e                	sd	s3,8(sp)
    5474:	e052                	sd	s4,0(sp)
    5476:	1800                	addi	s0,sp,48
  int n = 0;
  uint64 sz0 = (uint64)sbrk(0);
    5478:	4501                	li	a0,0
    547a:	46c000ef          	jal	58e6 <sbrk>
    547e:	8a2a                	mv	s4,a0
  int n = 0;
    5480:	4481                	li	s1,0
  while (1) {
    char *a = sbrk(PGSIZE);
    5482:	6985                	lui	s3,0x1
    if (a == SBRK_ERROR) {
    5484:	597d                	li	s2,-1
    char *a = sbrk(PGSIZE);
    5486:	854e                	mv	a0,s3
    5488:	45e000ef          	jal	58e6 <sbrk>
    if (a == SBRK_ERROR) {
    548c:	01250463          	beq	a0,s2,5494 <countfree+0x2c>
      break;
    }
    n += 1;
    5490:	2485                	addiw	s1,s1,1
  while (1) {
    5492:	bfd5                	j	5486 <countfree+0x1e>
  }
  sbrk(-((uint64)sbrk(0) - sz0));
    5494:	4501                	li	a0,0
    5496:	450000ef          	jal	58e6 <sbrk>
    549a:	40aa053b          	subw	a0,s4,a0
    549e:	448000ef          	jal	58e6 <sbrk>
  return n;
}
    54a2:	8526                	mv	a0,s1
    54a4:	70a2                	ld	ra,40(sp)
    54a6:	7402                	ld	s0,32(sp)
    54a8:	64e2                	ld	s1,24(sp)
    54aa:	6942                	ld	s2,16(sp)
    54ac:	69a2                	ld	s3,8(sp)
    54ae:	6a02                	ld	s4,0(sp)
    54b0:	6145                	addi	sp,sp,48
    54b2:	8082                	ret

00000000000054b4 <drivetests>:

int
drivetests(int quick, int continuous, char *justone)
{
    54b4:	7159                	addi	sp,sp,-112
    54b6:	f486                	sd	ra,104(sp)
    54b8:	f0a2                	sd	s0,96(sp)
    54ba:	eca6                	sd	s1,88(sp)
    54bc:	e8ca                	sd	s2,80(sp)
    54be:	e4ce                	sd	s3,72(sp)
    54c0:	e0d2                	sd	s4,64(sp)
    54c2:	fc56                	sd	s5,56(sp)
    54c4:	f85a                	sd	s6,48(sp)
    54c6:	f45e                	sd	s7,40(sp)
    54c8:	f062                	sd	s8,32(sp)
    54ca:	ec66                	sd	s9,24(sp)
    54cc:	e86a                	sd	s10,16(sp)
    54ce:	e46e                	sd	s11,8(sp)
    54d0:	1880                	addi	s0,sp,112
    54d2:	8aaa                	mv	s5,a0
    54d4:	89ae                	mv	s3,a1
    54d6:	8a32                	mv	s4,a2
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
      if (continuous != 2) {
        return 1;
      }
    }
    if (justone != 0 && ntests == 0) {
    54d8:	00c03d33          	snez	s10,a2
    printf("usertests starting\n");
    54dc:	00003c17          	auipc	s8,0x3
    54e0:	f8cc0c13          	addi	s8,s8,-116 # 8468 <malloc+0x2640>
    n = runtests(quicktests, justone, continuous);
    54e4:	00006b97          	auipc	s7,0x6
    54e8:	b2cb8b93          	addi	s7,s7,-1236 # b010 <quicktests>
      if (continuous != 2) {
    54ec:	4b09                	li	s6,2
      n = runtests(slowtests, justone, continuous);
    54ee:	00006c97          	auipc	s9,0x6
    54f2:	f82c8c93          	addi	s9,s9,-126 # b470 <slowtests>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    54f6:	00003d97          	auipc	s11,0x3
    54fa:	faad8d93          	addi	s11,s11,-86 # 84a0 <malloc+0x2678>
    54fe:	a82d                	j	5538 <drivetests+0x84>
      if (continuous != 2) {
    5500:	0b699363          	bne	s3,s6,55a6 <drivetests+0xf2>
    int ntests = 0;
    5504:	4481                	li	s1,0
    5506:	a0b9                	j	5554 <drivetests+0xa0>
        printf("usertests slow tests starting\n");
    5508:	00003517          	auipc	a0,0x3
    550c:	f7850513          	addi	a0,a0,-136 # 8480 <malloc+0x2658>
    5510:	061000ef          	jal	5d70 <printf>
    5514:	a0a1                	j	555c <drivetests+0xa8>
        if (continuous != 2) {
    5516:	05698b63          	beq	s3,s6,556c <drivetests+0xb8>
          return 1;
    551a:	4505                	li	a0,1
    551c:	a0b5                	j	5588 <drivetests+0xd4>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    551e:	864a                	mv	a2,s2
    5520:	85aa                	mv	a1,a0
    5522:	856e                	mv	a0,s11
    5524:	04d000ef          	jal	5d70 <printf>
      if (continuous != 2) {
    5528:	09699163          	bne	s3,s6,55aa <drivetests+0xf6>
    if (justone != 0 && ntests == 0) {
    552c:	e491                	bnez	s1,5538 <drivetests+0x84>
    552e:	000d0563          	beqz	s10,5538 <drivetests+0x84>
    5532:	a0a1                	j	557a <drivetests+0xc6>
      printf("NO TESTS EXECUTED\n");
      return 1;
    }
  } while (continuous);
    5534:	06098d63          	beqz	s3,55ae <drivetests+0xfa>
    printf("usertests starting\n");
    5538:	8562                	mv	a0,s8
    553a:	037000ef          	jal	5d70 <printf>
    int free0 = countfree();
    553e:	f2bff0ef          	jal	5468 <countfree>
    5542:	892a                	mv	s2,a0
    n = runtests(quicktests, justone, continuous);
    5544:	864e                	mv	a2,s3
    5546:	85d2                	mv	a1,s4
    5548:	855e                	mv	a0,s7
    554a:	eb1ff0ef          	jal	53fa <runtests>
    554e:	84aa                	mv	s1,a0
    if (n < 0) {
    5550:	fa0548e3          	bltz	a0,5500 <drivetests+0x4c>
    if (!quick) {
    5554:	000a9c63          	bnez	s5,556c <drivetests+0xb8>
      if (justone == 0)
    5558:	fa0a08e3          	beqz	s4,5508 <drivetests+0x54>
      n = runtests(slowtests, justone, continuous);
    555c:	864e                	mv	a2,s3
    555e:	85d2                	mv	a1,s4
    5560:	8566                	mv	a0,s9
    5562:	e99ff0ef          	jal	53fa <runtests>
      if (n < 0) {
    5566:	fa0548e3          	bltz	a0,5516 <drivetests+0x62>
        ntests += n;
    556a:	9ca9                	addw	s1,s1,a0
    if ((free1 = countfree()) < free0) {
    556c:	efdff0ef          	jal	5468 <countfree>
    5570:	fb2547e3          	blt	a0,s2,551e <drivetests+0x6a>
    if (justone != 0 && ntests == 0) {
    5574:	f0e1                	bnez	s1,5534 <drivetests+0x80>
    5576:	fa0d0fe3          	beqz	s10,5534 <drivetests+0x80>
      printf("NO TESTS EXECUTED\n");
    557a:	00003517          	auipc	a0,0x3
    557e:	f5650513          	addi	a0,a0,-170 # 84d0 <malloc+0x26a8>
    5582:	7ee000ef          	jal	5d70 <printf>
      return 1;
    5586:	4505                	li	a0,1
  return 0;
}
    5588:	70a6                	ld	ra,104(sp)
    558a:	7406                	ld	s0,96(sp)
    558c:	64e6                	ld	s1,88(sp)
    558e:	6946                	ld	s2,80(sp)
    5590:	69a6                	ld	s3,72(sp)
    5592:	6a06                	ld	s4,64(sp)
    5594:	7ae2                	ld	s5,56(sp)
    5596:	7b42                	ld	s6,48(sp)
    5598:	7ba2                	ld	s7,40(sp)
    559a:	7c02                	ld	s8,32(sp)
    559c:	6ce2                	ld	s9,24(sp)
    559e:	6d42                	ld	s10,16(sp)
    55a0:	6da2                	ld	s11,8(sp)
    55a2:	6165                	addi	sp,sp,112
    55a4:	8082                	ret
        return 1;
    55a6:	4505                	li	a0,1
    55a8:	b7c5                	j	5588 <drivetests+0xd4>
        return 1;
    55aa:	4505                	li	a0,1
    55ac:	bff1                	j	5588 <drivetests+0xd4>
  return 0;
    55ae:	854e                	mv	a0,s3
    55b0:	bfe1                	j	5588 <drivetests+0xd4>

00000000000055b2 <main>:

int
main(int argc, char *argv[])
{
    55b2:	1101                	addi	sp,sp,-32
    55b4:	ec06                	sd	ra,24(sp)
    55b6:	e822                	sd	s0,16(sp)
    55b8:	e426                	sd	s1,8(sp)
    55ba:	e04a                	sd	s2,0(sp)
    55bc:	1000                	addi	s0,sp,32
    55be:	84aa                	mv	s1,a0
  int continuous = 0;
  int quick = 0;
  char *justone = 0;

  if (argc == 2 && strcmp(argv[1], "-q") == 0) {
    55c0:	4789                	li	a5,2
    55c2:	00f50e63          	beq	a0,a5,55de <main+0x2c>
    continuous = 1;
  } else if (argc == 2 && strcmp(argv[1], "-C") == 0) {
    continuous = 2;
  } else if (argc == 2 && argv[1][0] != '-') {
    justone = argv[1];
  } else if (argc > 1) {
    55c6:	4785                	li	a5,1
    55c8:	06a7c663          	blt	a5,a0,5634 <main+0x82>
  char *justone = 0;
    55cc:	4601                	li	a2,0
  int quick = 0;
    55ce:	4501                	li	a0,0
  int continuous = 0;
    55d0:	4581                	li	a1,0
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    exit(1);
  }
  if (drivetests(quick, continuous, justone)) {
    55d2:	ee3ff0ef          	jal	54b4 <drivetests>
    55d6:	cd35                	beqz	a0,5652 <main+0xa0>
    exit(1);
    55d8:	4505                	li	a0,1
    55da:	340000ef          	jal	591a <exit>
    55de:	892e                	mv	s2,a1
  if (argc == 2 && strcmp(argv[1], "-q") == 0) {
    55e0:	00003597          	auipc	a1,0x3
    55e4:	f0858593          	addi	a1,a1,-248 # 84e8 <malloc+0x26c0>
    55e8:	00893503          	ld	a0,8(s2)
    55ec:	0a8000ef          	jal	5694 <strcmp>
    55f0:	85aa                	mv	a1,a0
    55f2:	e501                	bnez	a0,55fa <main+0x48>
  char *justone = 0;
    55f4:	4601                	li	a2,0
    quick = 1;
    55f6:	4505                	li	a0,1
    55f8:	bfe9                	j	55d2 <main+0x20>
  } else if (argc == 2 && strcmp(argv[1], "-c") == 0) {
    55fa:	00003597          	auipc	a1,0x3
    55fe:	ef658593          	addi	a1,a1,-266 # 84f0 <malloc+0x26c8>
    5602:	00893503          	ld	a0,8(s2)
    5606:	08e000ef          	jal	5694 <strcmp>
    560a:	cd15                	beqz	a0,5646 <main+0x94>
  } else if (argc == 2 && strcmp(argv[1], "-C") == 0) {
    560c:	00003597          	auipc	a1,0x3
    5610:	f3458593          	addi	a1,a1,-204 # 8540 <malloc+0x2718>
    5614:	00893503          	ld	a0,8(s2)
    5618:	07c000ef          	jal	5694 <strcmp>
    561c:	c905                	beqz	a0,564c <main+0x9a>
  } else if (argc == 2 && argv[1][0] != '-') {
    561e:	00893603          	ld	a2,8(s2)
    5622:	00064703          	lbu	a4,0(a2)
    5626:	02d00793          	li	a5,45
    562a:	00f70563          	beq	a4,a5,5634 <main+0x82>
  int quick = 0;
    562e:	4501                	li	a0,0
  int continuous = 0;
    5630:	4581                	li	a1,0
    5632:	b745                	j	55d2 <main+0x20>
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    5634:	00003517          	auipc	a0,0x3
    5638:	ec450513          	addi	a0,a0,-316 # 84f8 <malloc+0x26d0>
    563c:	734000ef          	jal	5d70 <printf>
    exit(1);
    5640:	4505                	li	a0,1
    5642:	2d8000ef          	jal	591a <exit>
  char *justone = 0;
    5646:	4601                	li	a2,0
    continuous = 1;
    5648:	4585                	li	a1,1
    564a:	b761                	j	55d2 <main+0x20>
    continuous = 2;
    564c:	85a6                	mv	a1,s1
  char *justone = 0;
    564e:	4601                	li	a2,0
    5650:	b749                	j	55d2 <main+0x20>
  }
  printf("ALL TESTS PASSED\n");
    5652:	00003517          	auipc	a0,0x3
    5656:	ed650513          	addi	a0,a0,-298 # 8528 <malloc+0x2700>
    565a:	716000ef          	jal	5d70 <printf>
  exit(0);
    565e:	4501                	li	a0,0
    5660:	2ba000ef          	jal	591a <exit>

0000000000005664 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
    5664:	1141                	addi	sp,sp,-16
    5666:	e406                	sd	ra,8(sp)
    5668:	e022                	sd	s0,0(sp)
    566a:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
    566c:	f47ff0ef          	jal	55b2 <main>
  exit(r);
    5670:	2aa000ef          	jal	591a <exit>

0000000000005674 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
    5674:	1141                	addi	sp,sp,-16
    5676:	e406                	sd	ra,8(sp)
    5678:	e022                	sd	s0,0(sp)
    567a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
    567c:	87aa                	mv	a5,a0
    567e:	0585                	addi	a1,a1,1
    5680:	0785                	addi	a5,a5,1
    5682:	fff5c703          	lbu	a4,-1(a1)
    5686:	fee78fa3          	sb	a4,-1(a5)
    568a:	fb75                	bnez	a4,567e <strcpy+0xa>
    ;
  return os;
}
    568c:	60a2                	ld	ra,8(sp)
    568e:	6402                	ld	s0,0(sp)
    5690:	0141                	addi	sp,sp,16
    5692:	8082                	ret

0000000000005694 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    5694:	1141                	addi	sp,sp,-16
    5696:	e406                	sd	ra,8(sp)
    5698:	e022                	sd	s0,0(sp)
    569a:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
    569c:	00054783          	lbu	a5,0(a0)
    56a0:	cb91                	beqz	a5,56b4 <strcmp+0x20>
    56a2:	0005c703          	lbu	a4,0(a1)
    56a6:	00f71763          	bne	a4,a5,56b4 <strcmp+0x20>
    p++, q++;
    56aa:	0505                	addi	a0,a0,1
    56ac:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
    56ae:	00054783          	lbu	a5,0(a0)
    56b2:	fbe5                	bnez	a5,56a2 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
    56b4:	0005c503          	lbu	a0,0(a1)
}
    56b8:	40a7853b          	subw	a0,a5,a0
    56bc:	60a2                	ld	ra,8(sp)
    56be:	6402                	ld	s0,0(sp)
    56c0:	0141                	addi	sp,sp,16
    56c2:	8082                	ret

00000000000056c4 <strlen>:

uint
strlen(const char *s)
{
    56c4:	1141                	addi	sp,sp,-16
    56c6:	e406                	sd	ra,8(sp)
    56c8:	e022                	sd	s0,0(sp)
    56ca:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
    56cc:	00054783          	lbu	a5,0(a0)
    56d0:	cf91                	beqz	a5,56ec <strlen+0x28>
    56d2:	00150793          	addi	a5,a0,1
    56d6:	86be                	mv	a3,a5
    56d8:	0785                	addi	a5,a5,1
    56da:	fff7c703          	lbu	a4,-1(a5)
    56de:	ff65                	bnez	a4,56d6 <strlen+0x12>
    56e0:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    56e4:	60a2                	ld	ra,8(sp)
    56e6:	6402                	ld	s0,0(sp)
    56e8:	0141                	addi	sp,sp,16
    56ea:	8082                	ret
  for (n = 0; s[n]; n++)
    56ec:	4501                	li	a0,0
    56ee:	bfdd                	j	56e4 <strlen+0x20>

00000000000056f0 <memset>:

void *
memset(void *dst, int c, uint n)
{
    56f0:	1141                	addi	sp,sp,-16
    56f2:	e406                	sd	ra,8(sp)
    56f4:	e022                	sd	s0,0(sp)
    56f6:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
    56f8:	ca19                	beqz	a2,570e <memset+0x1e>
    56fa:	87aa                	mv	a5,a0
    56fc:	1602                	slli	a2,a2,0x20
    56fe:	9201                	srli	a2,a2,0x20
    5700:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    5704:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
    5708:	0785                	addi	a5,a5,1
    570a:	fee79de3          	bne	a5,a4,5704 <memset+0x14>
  }
  return dst;
}
    570e:	60a2                	ld	ra,8(sp)
    5710:	6402                	ld	s0,0(sp)
    5712:	0141                	addi	sp,sp,16
    5714:	8082                	ret

0000000000005716 <strchr>:

char *
strchr(const char *s, char c)
{
    5716:	1141                	addi	sp,sp,-16
    5718:	e406                	sd	ra,8(sp)
    571a:	e022                	sd	s0,0(sp)
    571c:	0800                	addi	s0,sp,16
  for (; *s; s++)
    571e:	00054783          	lbu	a5,0(a0)
    5722:	cf81                	beqz	a5,573a <strchr+0x24>
    if (*s == c)
    5724:	00f58763          	beq	a1,a5,5732 <strchr+0x1c>
  for (; *s; s++)
    5728:	0505                	addi	a0,a0,1
    572a:	00054783          	lbu	a5,0(a0)
    572e:	fbfd                	bnez	a5,5724 <strchr+0xe>
      return (char *)s;
  return 0;
    5730:	4501                	li	a0,0
}
    5732:	60a2                	ld	ra,8(sp)
    5734:	6402                	ld	s0,0(sp)
    5736:	0141                	addi	sp,sp,16
    5738:	8082                	ret
  return 0;
    573a:	4501                	li	a0,0
    573c:	bfdd                	j	5732 <strchr+0x1c>

000000000000573e <gets>:

char *
gets(char *buf, int max)
{
    573e:	711d                	addi	sp,sp,-96
    5740:	ec86                	sd	ra,88(sp)
    5742:	e8a2                	sd	s0,80(sp)
    5744:	e4a6                	sd	s1,72(sp)
    5746:	e0ca                	sd	s2,64(sp)
    5748:	fc4e                	sd	s3,56(sp)
    574a:	f852                	sd	s4,48(sp)
    574c:	f456                	sd	s5,40(sp)
    574e:	f05a                	sd	s6,32(sp)
    5750:	ec5e                	sd	s7,24(sp)
    5752:	e862                	sd	s8,16(sp)
    5754:	1080                	addi	s0,sp,96
    5756:	8baa                	mv	s7,a0
    5758:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
    575a:	892a                	mv	s2,a0
    575c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    575e:	faf40b13          	addi	s6,s0,-81
    5762:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
    5764:	8c26                	mv	s8,s1
    5766:	0014899b          	addiw	s3,s1,1
    576a:	84ce                	mv	s1,s3
    576c:	0349d463          	bge	s3,s4,5794 <gets+0x56>
    cc = read(0, &c, 1);
    5770:	8656                	mv	a2,s5
    5772:	85da                	mv	a1,s6
    5774:	4501                	li	a0,0
    5776:	1bc000ef          	jal	5932 <read>
    if (cc < 1)
    577a:	00a05d63          	blez	a0,5794 <gets+0x56>
      break;
    buf[i++] = c;
    577e:	faf44783          	lbu	a5,-81(s0)
    5782:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
    5786:	0905                	addi	s2,s2,1
    5788:	ff678713          	addi	a4,a5,-10
    578c:	c319                	beqz	a4,5792 <gets+0x54>
    578e:	17cd                	addi	a5,a5,-13
    5790:	fbf1                	bnez	a5,5764 <gets+0x26>
    buf[i++] = c;
    5792:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
    5794:	9c5e                	add	s8,s8,s7
    5796:	000c0023          	sb	zero,0(s8)
  return buf;
}
    579a:	855e                	mv	a0,s7
    579c:	60e6                	ld	ra,88(sp)
    579e:	6446                	ld	s0,80(sp)
    57a0:	64a6                	ld	s1,72(sp)
    57a2:	6906                	ld	s2,64(sp)
    57a4:	79e2                	ld	s3,56(sp)
    57a6:	7a42                	ld	s4,48(sp)
    57a8:	7aa2                	ld	s5,40(sp)
    57aa:	7b02                	ld	s6,32(sp)
    57ac:	6be2                	ld	s7,24(sp)
    57ae:	6c42                	ld	s8,16(sp)
    57b0:	6125                	addi	sp,sp,96
    57b2:	8082                	ret

00000000000057b4 <stat>:

int
stat(const char *n, struct stat *st)
{
    57b4:	1101                	addi	sp,sp,-32
    57b6:	ec06                	sd	ra,24(sp)
    57b8:	e822                	sd	s0,16(sp)
    57ba:	e04a                	sd	s2,0(sp)
    57bc:	1000                	addi	s0,sp,32
    57be:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    57c0:	4581                	li	a1,0
    57c2:	198000ef          	jal	595a <open>
  if (fd < 0)
    57c6:	02054263          	bltz	a0,57ea <stat+0x36>
    57ca:	e426                	sd	s1,8(sp)
    57cc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    57ce:	85ca                	mv	a1,s2
    57d0:	1a2000ef          	jal	5972 <fstat>
    57d4:	892a                	mv	s2,a0
  close(fd);
    57d6:	8526                	mv	a0,s1
    57d8:	16a000ef          	jal	5942 <close>
  return r;
    57dc:	64a2                	ld	s1,8(sp)
}
    57de:	854a                	mv	a0,s2
    57e0:	60e2                	ld	ra,24(sp)
    57e2:	6442                	ld	s0,16(sp)
    57e4:	6902                	ld	s2,0(sp)
    57e6:	6105                	addi	sp,sp,32
    57e8:	8082                	ret
    return -1;
    57ea:	57fd                	li	a5,-1
    57ec:	893e                	mv	s2,a5
    57ee:	bfc5                	j	57de <stat+0x2a>

00000000000057f0 <atoi>:

int
atoi(const char *s)
{
    57f0:	1141                	addi	sp,sp,-16
    57f2:	e406                	sd	ra,8(sp)
    57f4:	e022                	sd	s0,0(sp)
    57f6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
    57f8:	00054683          	lbu	a3,0(a0)
    57fc:	fd06879b          	addiw	a5,a3,-48
    5800:	0ff7f793          	zext.b	a5,a5
    5804:	4625                	li	a2,9
    5806:	02f66963          	bltu	a2,a5,5838 <atoi+0x48>
    580a:	872a                	mv	a4,a0
  n = 0;
    580c:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
    580e:	0705                	addi	a4,a4,1 # 1000001 <base+0xfee2f9>
    5810:	0025179b          	slliw	a5,a0,0x2
    5814:	9fa9                	addw	a5,a5,a0
    5816:	0017979b          	slliw	a5,a5,0x1
    581a:	9fb5                	addw	a5,a5,a3
    581c:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
    5820:	00074683          	lbu	a3,0(a4)
    5824:	fd06879b          	addiw	a5,a3,-48
    5828:	0ff7f793          	zext.b	a5,a5
    582c:	fef671e3          	bgeu	a2,a5,580e <atoi+0x1e>
  return n;
}
    5830:	60a2                	ld	ra,8(sp)
    5832:	6402                	ld	s0,0(sp)
    5834:	0141                	addi	sp,sp,16
    5836:	8082                	ret
  n = 0;
    5838:	4501                	li	a0,0
    583a:	bfdd                	j	5830 <atoi+0x40>

000000000000583c <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
    583c:	1141                	addi	sp,sp,-16
    583e:	e406                	sd	ra,8(sp)
    5840:	e022                	sd	s0,0(sp)
    5842:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    5844:	02b57563          	bgeu	a0,a1,586e <memmove+0x32>
    while (n-- > 0)
    5848:	00c05f63          	blez	a2,5866 <memmove+0x2a>
    584c:	1602                	slli	a2,a2,0x20
    584e:	9201                	srli	a2,a2,0x20
    5850:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    5854:	872a                	mv	a4,a0
      *dst++ = *src++;
    5856:	0585                	addi	a1,a1,1
    5858:	0705                	addi	a4,a4,1
    585a:	fff5c683          	lbu	a3,-1(a1)
    585e:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
    5862:	fee79ae3          	bne	a5,a4,5856 <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    5866:	60a2                	ld	ra,8(sp)
    5868:	6402                	ld	s0,0(sp)
    586a:	0141                	addi	sp,sp,16
    586c:	8082                	ret
    while (n-- > 0)
    586e:	fec05ce3          	blez	a2,5866 <memmove+0x2a>
    dst += n;
    5872:	00c50733          	add	a4,a0,a2
    src += n;
    5876:	95b2                	add	a1,a1,a2
    5878:	fff6079b          	addiw	a5,a2,-1
    587c:	1782                	slli	a5,a5,0x20
    587e:	9381                	srli	a5,a5,0x20
    5880:	fff7c793          	not	a5,a5
    5884:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    5886:	15fd                	addi	a1,a1,-1
    5888:	177d                	addi	a4,a4,-1
    588a:	0005c683          	lbu	a3,0(a1)
    588e:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
    5892:	fef71ae3          	bne	a4,a5,5886 <memmove+0x4a>
    5896:	bfc1                	j	5866 <memmove+0x2a>

0000000000005898 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    5898:	1141                	addi	sp,sp,-16
    589a:	e406                	sd	ra,8(sp)
    589c:	e022                	sd	s0,0(sp)
    589e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    58a0:	c61d                	beqz	a2,58ce <memcmp+0x36>
    58a2:	1602                	slli	a2,a2,0x20
    58a4:	9201                	srli	a2,a2,0x20
    58a6:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
    58aa:	00054783          	lbu	a5,0(a0)
    58ae:	0005c703          	lbu	a4,0(a1)
    58b2:	00e79863          	bne	a5,a4,58c2 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
    58b6:	0505                	addi	a0,a0,1
    p2++;
    58b8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    58ba:	fed518e3          	bne	a0,a3,58aa <memcmp+0x12>
  }
  return 0;
    58be:	4501                	li	a0,0
    58c0:	a019                	j	58c6 <memcmp+0x2e>
      return *p1 - *p2;
    58c2:	40e7853b          	subw	a0,a5,a4
}
    58c6:	60a2                	ld	ra,8(sp)
    58c8:	6402                	ld	s0,0(sp)
    58ca:	0141                	addi	sp,sp,16
    58cc:	8082                	ret
  return 0;
    58ce:	4501                	li	a0,0
    58d0:	bfdd                	j	58c6 <memcmp+0x2e>

00000000000058d2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    58d2:	1141                	addi	sp,sp,-16
    58d4:	e406                	sd	ra,8(sp)
    58d6:	e022                	sd	s0,0(sp)
    58d8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    58da:	f63ff0ef          	jal	583c <memmove>
}
    58de:	60a2                	ld	ra,8(sp)
    58e0:	6402                	ld	s0,0(sp)
    58e2:	0141                	addi	sp,sp,16
    58e4:	8082                	ret

00000000000058e6 <sbrk>:

char *
sbrk(int n)
{
    58e6:	1141                	addi	sp,sp,-16
    58e8:	e406                	sd	ra,8(sp)
    58ea:	e022                	sd	s0,0(sp)
    58ec:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
    58ee:	4585                	li	a1,1
    58f0:	0b2000ef          	jal	59a2 <sys_sbrk>
}
    58f4:	60a2                	ld	ra,8(sp)
    58f6:	6402                	ld	s0,0(sp)
    58f8:	0141                	addi	sp,sp,16
    58fa:	8082                	ret

00000000000058fc <sbrklazy>:

char *
sbrklazy(int n)
{
    58fc:	1141                	addi	sp,sp,-16
    58fe:	e406                	sd	ra,8(sp)
    5900:	e022                	sd	s0,0(sp)
    5902:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
    5904:	4589                	li	a1,2
    5906:	09c000ef          	jal	59a2 <sys_sbrk>
}
    590a:	60a2                	ld	ra,8(sp)
    590c:	6402                	ld	s0,0(sp)
    590e:	0141                	addi	sp,sp,16
    5910:	8082                	ret

0000000000005912 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    5912:	4885                	li	a7,1
 ecall
    5914:	00000073          	ecall
 ret
    5918:	8082                	ret

000000000000591a <exit>:
.global exit
exit:
 li a7, SYS_exit
    591a:	4889                	li	a7,2
 ecall
    591c:	00000073          	ecall
 ret
    5920:	8082                	ret

0000000000005922 <wait>:
.global wait
wait:
 li a7, SYS_wait
    5922:	488d                	li	a7,3
 ecall
    5924:	00000073          	ecall
 ret
    5928:	8082                	ret

000000000000592a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    592a:	4891                	li	a7,4
 ecall
    592c:	00000073          	ecall
 ret
    5930:	8082                	ret

0000000000005932 <read>:
.global read
read:
 li a7, SYS_read
    5932:	4895                	li	a7,5
 ecall
    5934:	00000073          	ecall
 ret
    5938:	8082                	ret

000000000000593a <write>:
.global write
write:
 li a7, SYS_write
    593a:	48c1                	li	a7,16
 ecall
    593c:	00000073          	ecall
 ret
    5940:	8082                	ret

0000000000005942 <close>:
.global close
close:
 li a7, SYS_close
    5942:	48d5                	li	a7,21
 ecall
    5944:	00000073          	ecall
 ret
    5948:	8082                	ret

000000000000594a <kill>:
.global kill
kill:
 li a7, SYS_kill
    594a:	4899                	li	a7,6
 ecall
    594c:	00000073          	ecall
 ret
    5950:	8082                	ret

0000000000005952 <exec>:
.global exec
exec:
 li a7, SYS_exec
    5952:	489d                	li	a7,7
 ecall
    5954:	00000073          	ecall
 ret
    5958:	8082                	ret

000000000000595a <open>:
.global open
open:
 li a7, SYS_open
    595a:	48bd                	li	a7,15
 ecall
    595c:	00000073          	ecall
 ret
    5960:	8082                	ret

0000000000005962 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5962:	48c5                	li	a7,17
 ecall
    5964:	00000073          	ecall
 ret
    5968:	8082                	ret

000000000000596a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    596a:	48c9                	li	a7,18
 ecall
    596c:	00000073          	ecall
 ret
    5970:	8082                	ret

0000000000005972 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    5972:	48a1                	li	a7,8
 ecall
    5974:	00000073          	ecall
 ret
    5978:	8082                	ret

000000000000597a <link>:
.global link
link:
 li a7, SYS_link
    597a:	48cd                	li	a7,19
 ecall
    597c:	00000073          	ecall
 ret
    5980:	8082                	ret

0000000000005982 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    5982:	48d1                	li	a7,20
 ecall
    5984:	00000073          	ecall
 ret
    5988:	8082                	ret

000000000000598a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    598a:	48a5                	li	a7,9
 ecall
    598c:	00000073          	ecall
 ret
    5990:	8082                	ret

0000000000005992 <dup>:
.global dup
dup:
 li a7, SYS_dup
    5992:	48a9                	li	a7,10
 ecall
    5994:	00000073          	ecall
 ret
    5998:	8082                	ret

000000000000599a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    599a:	48ad                	li	a7,11
 ecall
    599c:	00000073          	ecall
 ret
    59a0:	8082                	ret

00000000000059a2 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
    59a2:	48b1                	li	a7,12
 ecall
    59a4:	00000073          	ecall
 ret
    59a8:	8082                	ret

00000000000059aa <pause>:
.global pause
pause:
 li a7, SYS_pause
    59aa:	48b5                	li	a7,13
 ecall
    59ac:	00000073          	ecall
 ret
    59b0:	8082                	ret

00000000000059b2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    59b2:	48b9                	li	a7,14
 ecall
    59b4:	00000073          	ecall
 ret
    59b8:	8082                	ret

00000000000059ba <sync>:
.global sync
sync:
 li a7, SYS_sync
    59ba:	48d9                	li	a7,22
 ecall
    59bc:	00000073          	ecall
 ret
    59c0:	8082                	ret

00000000000059c2 <get_queue>:
.global get_queue
get_queue:
 li a7, SYS_get_queue
    59c2:	48dd                	li	a7,23
 ecall
    59c4:	00000073          	ecall
 ret
    59c8:	8082                	ret

00000000000059ca <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    59ca:	1101                	addi	sp,sp,-32
    59cc:	ec06                	sd	ra,24(sp)
    59ce:	e822                	sd	s0,16(sp)
    59d0:	1000                	addi	s0,sp,32
    59d2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    59d6:	4605                	li	a2,1
    59d8:	fef40593          	addi	a1,s0,-17
    59dc:	f5fff0ef          	jal	593a <write>
}
    59e0:	60e2                	ld	ra,24(sp)
    59e2:	6442                	ld	s0,16(sp)
    59e4:	6105                	addi	sp,sp,32
    59e6:	8082                	ret

00000000000059e8 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
    59e8:	715d                	addi	sp,sp,-80
    59ea:	e486                	sd	ra,72(sp)
    59ec:	e0a2                	sd	s0,64(sp)
    59ee:	f84a                	sd	s2,48(sp)
    59f0:	f44e                	sd	s3,40(sp)
    59f2:	0880                	addi	s0,sp,80
    59f4:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
    59f6:	c6d1                	beqz	a3,5a82 <printint+0x9a>
    59f8:	0805d563          	bgez	a1,5a82 <printint+0x9a>
    neg = 1;
    x = -xx;
    59fc:	40b005b3          	neg	a1,a1
    neg = 1;
    5a00:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
    5a02:	fb840993          	addi	s3,s0,-72
  neg = 0;
    5a06:	86ce                	mv	a3,s3
  i = 0;
    5a08:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    5a0a:	00003817          	auipc	a6,0x3
    5a0e:	fae80813          	addi	a6,a6,-82 # 89b8 <digits>
    5a12:	88ba                	mv	a7,a4
    5a14:	0017051b          	addiw	a0,a4,1
    5a18:	872a                	mv	a4,a0
    5a1a:	02c5f7b3          	remu	a5,a1,a2
    5a1e:	97c2                	add	a5,a5,a6
    5a20:	0007c783          	lbu	a5,0(a5)
    5a24:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
    5a28:	87ae                	mv	a5,a1
    5a2a:	02c5d5b3          	divu	a1,a1,a2
    5a2e:	0685                	addi	a3,a3,1
    5a30:	fec7f1e3          	bgeu	a5,a2,5a12 <printint+0x2a>
  if (neg)
    5a34:	00030c63          	beqz	t1,5a4c <printint+0x64>
    buf[i++] = '-';
    5a38:	fd050793          	addi	a5,a0,-48
    5a3c:	00878533          	add	a0,a5,s0
    5a40:	02d00793          	li	a5,45
    5a44:	fef50423          	sb	a5,-24(a0)
    5a48:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
    5a4c:	02e05563          	blez	a4,5a76 <printint+0x8e>
    5a50:	fc26                	sd	s1,56(sp)
    5a52:	377d                	addiw	a4,a4,-1
    5a54:	00e984b3          	add	s1,s3,a4
    5a58:	19fd                	addi	s3,s3,-1 # fff <bigdir+0x10b>
    5a5a:	99ba                	add	s3,s3,a4
    5a5c:	1702                	slli	a4,a4,0x20
    5a5e:	9301                	srli	a4,a4,0x20
    5a60:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    5a64:	0004c583          	lbu	a1,0(s1)
    5a68:	854a                	mv	a0,s2
    5a6a:	f61ff0ef          	jal	59ca <putc>
  while (--i >= 0)
    5a6e:	14fd                	addi	s1,s1,-1
    5a70:	ff349ae3          	bne	s1,s3,5a64 <printint+0x7c>
    5a74:	74e2                	ld	s1,56(sp)
}
    5a76:	60a6                	ld	ra,72(sp)
    5a78:	6406                	ld	s0,64(sp)
    5a7a:	7942                	ld	s2,48(sp)
    5a7c:	79a2                	ld	s3,40(sp)
    5a7e:	6161                	addi	sp,sp,80
    5a80:	8082                	ret
  neg = 0;
    5a82:	4301                	li	t1,0
    5a84:	bfbd                	j	5a02 <printint+0x1a>

0000000000005a86 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    5a86:	711d                	addi	sp,sp,-96
    5a88:	ec86                	sd	ra,88(sp)
    5a8a:	e8a2                	sd	s0,80(sp)
    5a8c:	e4a6                	sd	s1,72(sp)
    5a8e:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
    5a90:	0005c483          	lbu	s1,0(a1)
    5a94:	22048363          	beqz	s1,5cba <vprintf+0x234>
    5a98:	e0ca                	sd	s2,64(sp)
    5a9a:	fc4e                	sd	s3,56(sp)
    5a9c:	f852                	sd	s4,48(sp)
    5a9e:	f456                	sd	s5,40(sp)
    5aa0:	f05a                	sd	s6,32(sp)
    5aa2:	ec5e                	sd	s7,24(sp)
    5aa4:	e862                	sd	s8,16(sp)
    5aa6:	8b2a                	mv	s6,a0
    5aa8:	8a2e                	mv	s4,a1
    5aaa:	8bb2                	mv	s7,a2
  state = 0;
    5aac:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
    5aae:	4901                	li	s2,0
    5ab0:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
    5ab2:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
    5ab6:	06400c13          	li	s8,100
    5aba:	a00d                	j	5adc <vprintf+0x56>
        putc(fd, c0);
    5abc:	85a6                	mv	a1,s1
    5abe:	855a                	mv	a0,s6
    5ac0:	f0bff0ef          	jal	59ca <putc>
    5ac4:	a019                	j	5aca <vprintf+0x44>
    } else if (state == '%') {
    5ac6:	03598363          	beq	s3,s5,5aec <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
    5aca:	0019079b          	addiw	a5,s2,1
    5ace:	893e                	mv	s2,a5
    5ad0:	873e                	mv	a4,a5
    5ad2:	97d2                	add	a5,a5,s4
    5ad4:	0007c483          	lbu	s1,0(a5)
    5ad8:	1c048a63          	beqz	s1,5cac <vprintf+0x226>
    c0 = fmt[i] & 0xff;
    5adc:	0004879b          	sext.w	a5,s1
    if (state == 0) {
    5ae0:	fe0993e3          	bnez	s3,5ac6 <vprintf+0x40>
      if (c0 == '%') {
    5ae4:	fd579ce3          	bne	a5,s5,5abc <vprintf+0x36>
        state = '%';
    5ae8:	89be                	mv	s3,a5
    5aea:	b7c5                	j	5aca <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
    5aec:	00ea06b3          	add	a3,s4,a4
    5af0:	0016c603          	lbu	a2,1(a3)
      if (c1)
    5af4:	1c060863          	beqz	a2,5cc4 <vprintf+0x23e>
      if (c0 == 'd') {
    5af8:	03878763          	beq	a5,s8,5b26 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
    5afc:	f9478693          	addi	a3,a5,-108
    5b00:	0016b693          	seqz	a3,a3
    5b04:	f9c60593          	addi	a1,a2,-100
    5b08:	e99d                	bnez	a1,5b3e <vprintf+0xb8>
    5b0a:	ca95                	beqz	a3,5b3e <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
    5b0c:	008b8493          	addi	s1,s7,8
    5b10:	4685                	li	a3,1
    5b12:	4629                	li	a2,10
    5b14:	000bb583          	ld	a1,0(s7)
    5b18:	855a                	mv	a0,s6
    5b1a:	ecfff0ef          	jal	59e8 <printint>
        i += 1;
    5b1e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
    5b20:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
    5b22:	4981                	li	s3,0
    5b24:	b75d                	j	5aca <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
    5b26:	008b8493          	addi	s1,s7,8
    5b2a:	4685                	li	a3,1
    5b2c:	4629                	li	a2,10
    5b2e:	000ba583          	lw	a1,0(s7)
    5b32:	855a                	mv	a0,s6
    5b34:	eb5ff0ef          	jal	59e8 <printint>
    5b38:	8ba6                	mv	s7,s1
      state = 0;
    5b3a:	4981                	li	s3,0
    5b3c:	b779                	j	5aca <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
    5b3e:	9752                	add	a4,a4,s4
    5b40:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    5b44:	f9460713          	addi	a4,a2,-108
    5b48:	00173713          	seqz	a4,a4
    5b4c:	8f75                	and	a4,a4,a3
    5b4e:	f9c58513          	addi	a0,a1,-100
    5b52:	18051363          	bnez	a0,5cd8 <vprintf+0x252>
    5b56:	18070163          	beqz	a4,5cd8 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
    5b5a:	008b8493          	addi	s1,s7,8
    5b5e:	4685                	li	a3,1
    5b60:	4629                	li	a2,10
    5b62:	000bb583          	ld	a1,0(s7)
    5b66:	855a                	mv	a0,s6
    5b68:	e81ff0ef          	jal	59e8 <printint>
        i += 2;
    5b6c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
    5b6e:	8ba6                	mv	s7,s1
      state = 0;
    5b70:	4981                	li	s3,0
        i += 2;
    5b72:	bfa1                	j	5aca <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
    5b74:	008b8493          	addi	s1,s7,8
    5b78:	4681                	li	a3,0
    5b7a:	4629                	li	a2,10
    5b7c:	000be583          	lwu	a1,0(s7)
    5b80:	855a                	mv	a0,s6
    5b82:	e67ff0ef          	jal	59e8 <printint>
    5b86:	8ba6                	mv	s7,s1
      state = 0;
    5b88:	4981                	li	s3,0
    5b8a:	b781                	j	5aca <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5b8c:	008b8493          	addi	s1,s7,8
    5b90:	4681                	li	a3,0
    5b92:	4629                	li	a2,10
    5b94:	000bb583          	ld	a1,0(s7)
    5b98:	855a                	mv	a0,s6
    5b9a:	e4fff0ef          	jal	59e8 <printint>
        i += 1;
    5b9e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
    5ba0:	8ba6                	mv	s7,s1
      state = 0;
    5ba2:	4981                	li	s3,0
    5ba4:	b71d                	j	5aca <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5ba6:	008b8493          	addi	s1,s7,8
    5baa:	4681                	li	a3,0
    5bac:	4629                	li	a2,10
    5bae:	000bb583          	ld	a1,0(s7)
    5bb2:	855a                	mv	a0,s6
    5bb4:	e35ff0ef          	jal	59e8 <printint>
        i += 2;
    5bb8:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
    5bba:	8ba6                	mv	s7,s1
      state = 0;
    5bbc:	4981                	li	s3,0
        i += 2;
    5bbe:	b731                	j	5aca <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
    5bc0:	008b8493          	addi	s1,s7,8
    5bc4:	4681                	li	a3,0
    5bc6:	4641                	li	a2,16
    5bc8:	000be583          	lwu	a1,0(s7)
    5bcc:	855a                	mv	a0,s6
    5bce:	e1bff0ef          	jal	59e8 <printint>
    5bd2:	8ba6                	mv	s7,s1
      state = 0;
    5bd4:	4981                	li	s3,0
    5bd6:	bdd5                	j	5aca <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
    5bd8:	008b8493          	addi	s1,s7,8
    5bdc:	4681                	li	a3,0
    5bde:	4641                	li	a2,16
    5be0:	000bb583          	ld	a1,0(s7)
    5be4:	855a                	mv	a0,s6
    5be6:	e03ff0ef          	jal	59e8 <printint>
        i += 1;
    5bea:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
    5bec:	8ba6                	mv	s7,s1
      state = 0;
    5bee:	4981                	li	s3,0
    5bf0:	bde9                	j	5aca <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
    5bf2:	008b8493          	addi	s1,s7,8
    5bf6:	4681                	li	a3,0
    5bf8:	4641                	li	a2,16
    5bfa:	000bb583          	ld	a1,0(s7)
    5bfe:	855a                	mv	a0,s6
    5c00:	de9ff0ef          	jal	59e8 <printint>
        i += 2;
    5c04:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
    5c06:	8ba6                	mv	s7,s1
      state = 0;
    5c08:	4981                	li	s3,0
        i += 2;
    5c0a:	b5c1                	j	5aca <vprintf+0x44>
    5c0c:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
    5c0e:	008b8793          	addi	a5,s7,8
    5c12:	8cbe                	mv	s9,a5
    5c14:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    5c18:	03000593          	li	a1,48
    5c1c:	855a                	mv	a0,s6
    5c1e:	dadff0ef          	jal	59ca <putc>
  putc(fd, 'x');
    5c22:	07800593          	li	a1,120
    5c26:	855a                	mv	a0,s6
    5c28:	da3ff0ef          	jal	59ca <putc>
    5c2c:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5c2e:	00003b97          	auipc	s7,0x3
    5c32:	d8ab8b93          	addi	s7,s7,-630 # 89b8 <digits>
    5c36:	03c9d793          	srli	a5,s3,0x3c
    5c3a:	97de                	add	a5,a5,s7
    5c3c:	0007c583          	lbu	a1,0(a5)
    5c40:	855a                	mv	a0,s6
    5c42:	d89ff0ef          	jal	59ca <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5c46:	0992                	slli	s3,s3,0x4
    5c48:	34fd                	addiw	s1,s1,-1
    5c4a:	f4f5                	bnez	s1,5c36 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
    5c4c:	8be6                	mv	s7,s9
      state = 0;
    5c4e:	4981                	li	s3,0
    5c50:	6ca2                	ld	s9,8(sp)
    5c52:	bda5                	j	5aca <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
    5c54:	008b8493          	addi	s1,s7,8
    5c58:	000bc583          	lbu	a1,0(s7)
    5c5c:	855a                	mv	a0,s6
    5c5e:	d6dff0ef          	jal	59ca <putc>
    5c62:	8ba6                	mv	s7,s1
      state = 0;
    5c64:	4981                	li	s3,0
    5c66:	b595                	j	5aca <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
    5c68:	008b8993          	addi	s3,s7,8
    5c6c:	000bb483          	ld	s1,0(s7)
    5c70:	cc91                	beqz	s1,5c8c <vprintf+0x206>
        for (; *s; s++)
    5c72:	0004c583          	lbu	a1,0(s1)
    5c76:	c985                	beqz	a1,5ca6 <vprintf+0x220>
          putc(fd, *s);
    5c78:	855a                	mv	a0,s6
    5c7a:	d51ff0ef          	jal	59ca <putc>
        for (; *s; s++)
    5c7e:	0485                	addi	s1,s1,1
    5c80:	0004c583          	lbu	a1,0(s1)
    5c84:	f9f5                	bnez	a1,5c78 <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
    5c86:	8bce                	mv	s7,s3
      state = 0;
    5c88:	4981                	li	s3,0
    5c8a:	b581                	j	5aca <vprintf+0x44>
          s = "(null)";
    5c8c:	00003497          	auipc	s1,0x3
    5c90:	c7c48493          	addi	s1,s1,-900 # 8908 <malloc+0x2ae0>
        for (; *s; s++)
    5c94:	02800593          	li	a1,40
    5c98:	b7c5                	j	5c78 <vprintf+0x1f2>
        putc(fd, '%');
    5c9a:	85be                	mv	a1,a5
    5c9c:	855a                	mv	a0,s6
    5c9e:	d2dff0ef          	jal	59ca <putc>
      state = 0;
    5ca2:	4981                	li	s3,0
    5ca4:	b51d                	j	5aca <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
    5ca6:	8bce                	mv	s7,s3
      state = 0;
    5ca8:	4981                	li	s3,0
    5caa:	b505                	j	5aca <vprintf+0x44>
    5cac:	6906                	ld	s2,64(sp)
    5cae:	79e2                	ld	s3,56(sp)
    5cb0:	7a42                	ld	s4,48(sp)
    5cb2:	7aa2                	ld	s5,40(sp)
    5cb4:	7b02                	ld	s6,32(sp)
    5cb6:	6be2                	ld	s7,24(sp)
    5cb8:	6c42                	ld	s8,16(sp)
    }
  }
}
    5cba:	60e6                	ld	ra,88(sp)
    5cbc:	6446                	ld	s0,80(sp)
    5cbe:	64a6                	ld	s1,72(sp)
    5cc0:	6125                	addi	sp,sp,96
    5cc2:	8082                	ret
      if (c0 == 'd') {
    5cc4:	06400713          	li	a4,100
    5cc8:	e4e78fe3          	beq	a5,a4,5b26 <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
    5ccc:	f9478693          	addi	a3,a5,-108
    5cd0:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
    5cd4:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    5cd6:	4701                	li	a4,0
      } else if (c0 == 'u') {
    5cd8:	07500513          	li	a0,117
    5cdc:	e8a78ce3          	beq	a5,a0,5b74 <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
    5ce0:	f8b60513          	addi	a0,a2,-117
    5ce4:	e119                	bnez	a0,5cea <vprintf+0x264>
    5ce6:	ea0693e3          	bnez	a3,5b8c <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
    5cea:	f8b58513          	addi	a0,a1,-117
    5cee:	e119                	bnez	a0,5cf4 <vprintf+0x26e>
    5cf0:	ea071be3          	bnez	a4,5ba6 <vprintf+0x120>
      } else if (c0 == 'x') {
    5cf4:	07800513          	li	a0,120
    5cf8:	eca784e3          	beq	a5,a0,5bc0 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
    5cfc:	f8860613          	addi	a2,a2,-120
    5d00:	e219                	bnez	a2,5d06 <vprintf+0x280>
    5d02:	ec069be3          	bnez	a3,5bd8 <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
    5d06:	f8858593          	addi	a1,a1,-120
    5d0a:	e199                	bnez	a1,5d10 <vprintf+0x28a>
    5d0c:	ee0713e3          	bnez	a4,5bf2 <vprintf+0x16c>
      } else if (c0 == 'p') {
    5d10:	07000713          	li	a4,112
    5d14:	eee78ce3          	beq	a5,a4,5c0c <vprintf+0x186>
      } else if (c0 == 'c') {
    5d18:	06300713          	li	a4,99
    5d1c:	f2e78ce3          	beq	a5,a4,5c54 <vprintf+0x1ce>
      } else if (c0 == 's') {
    5d20:	07300713          	li	a4,115
    5d24:	f4e782e3          	beq	a5,a4,5c68 <vprintf+0x1e2>
      } else if (c0 == '%') {
    5d28:	02500713          	li	a4,37
    5d2c:	f6e787e3          	beq	a5,a4,5c9a <vprintf+0x214>
        putc(fd, '%');
    5d30:	02500593          	li	a1,37
    5d34:	855a                	mv	a0,s6
    5d36:	c95ff0ef          	jal	59ca <putc>
        putc(fd, c0);
    5d3a:	85a6                	mv	a1,s1
    5d3c:	855a                	mv	a0,s6
    5d3e:	c8dff0ef          	jal	59ca <putc>
      state = 0;
    5d42:	4981                	li	s3,0
    5d44:	b359                	j	5aca <vprintf+0x44>

0000000000005d46 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    5d46:	715d                	addi	sp,sp,-80
    5d48:	ec06                	sd	ra,24(sp)
    5d4a:	e822                	sd	s0,16(sp)
    5d4c:	1000                	addi	s0,sp,32
    5d4e:	e010                	sd	a2,0(s0)
    5d50:	e414                	sd	a3,8(s0)
    5d52:	e818                	sd	a4,16(s0)
    5d54:	ec1c                	sd	a5,24(s0)
    5d56:	03043023          	sd	a6,32(s0)
    5d5a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5d5e:	8622                	mv	a2,s0
    5d60:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5d64:	d23ff0ef          	jal	5a86 <vprintf>
}
    5d68:	60e2                	ld	ra,24(sp)
    5d6a:	6442                	ld	s0,16(sp)
    5d6c:	6161                	addi	sp,sp,80
    5d6e:	8082                	ret

0000000000005d70 <printf>:

void
printf(const char *fmt, ...)
{
    5d70:	711d                	addi	sp,sp,-96
    5d72:	ec06                	sd	ra,24(sp)
    5d74:	e822                	sd	s0,16(sp)
    5d76:	1000                	addi	s0,sp,32
    5d78:	e40c                	sd	a1,8(s0)
    5d7a:	e810                	sd	a2,16(s0)
    5d7c:	ec14                	sd	a3,24(s0)
    5d7e:	f018                	sd	a4,32(s0)
    5d80:	f41c                	sd	a5,40(s0)
    5d82:	03043823          	sd	a6,48(s0)
    5d86:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5d8a:	00840613          	addi	a2,s0,8
    5d8e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5d92:	85aa                	mv	a1,a0
    5d94:	4505                	li	a0,1
    5d96:	cf1ff0ef          	jal	5a86 <vprintf>
}
    5d9a:	60e2                	ld	ra,24(sp)
    5d9c:	6442                	ld	s0,16(sp)
    5d9e:	6125                	addi	sp,sp,96
    5da0:	8082                	ret

0000000000005da2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    5da2:	1141                	addi	sp,sp,-16
    5da4:	e406                	sd	ra,8(sp)
    5da6:	e022                	sd	s0,0(sp)
    5da8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
    5daa:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5dae:	00005797          	auipc	a5,0x5
    5db2:	7327b783          	ld	a5,1842(a5) # b4e0 <freep>
    5db6:	a039                	j	5dc4 <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5db8:	6398                	ld	a4,0(a5)
    5dba:	00e7e463          	bltu	a5,a4,5dc2 <free+0x20>
    5dbe:	00e6ea63          	bltu	a3,a4,5dd2 <free+0x30>
{
    5dc2:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5dc4:	fed7fae3          	bgeu	a5,a3,5db8 <free+0x16>
    5dc8:	6398                	ld	a4,0(a5)
    5dca:	00e6e463          	bltu	a3,a4,5dd2 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5dce:	fee7eae3          	bltu	a5,a4,5dc2 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
    5dd2:	ff852583          	lw	a1,-8(a0)
    5dd6:	6390                	ld	a2,0(a5)
    5dd8:	02059813          	slli	a6,a1,0x20
    5ddc:	01c85713          	srli	a4,a6,0x1c
    5de0:	9736                	add	a4,a4,a3
    5de2:	02e60563          	beq	a2,a4,5e0c <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
    5de6:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
    5dea:	4790                	lw	a2,8(a5)
    5dec:	02061593          	slli	a1,a2,0x20
    5df0:	01c5d713          	srli	a4,a1,0x1c
    5df4:	973e                	add	a4,a4,a5
    5df6:	02e68263          	beq	a3,a4,5e1a <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
    5dfa:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    5dfc:	00005717          	auipc	a4,0x5
    5e00:	6ef73223          	sd	a5,1764(a4) # b4e0 <freep>
}
    5e04:	60a2                	ld	ra,8(sp)
    5e06:	6402                	ld	s0,0(sp)
    5e08:	0141                	addi	sp,sp,16
    5e0a:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
    5e0c:	4618                	lw	a4,8(a2)
    5e0e:	9f2d                	addw	a4,a4,a1
    5e10:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5e14:	6398                	ld	a4,0(a5)
    5e16:	6310                	ld	a2,0(a4)
    5e18:	b7f9                	j	5de6 <free+0x44>
    p->s.size += bp->s.size;
    5e1a:	ff852703          	lw	a4,-8(a0)
    5e1e:	9f31                	addw	a4,a4,a2
    5e20:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    5e22:	ff053683          	ld	a3,-16(a0)
    5e26:	bfd1                	j	5dfa <free+0x58>

0000000000005e28 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
    5e28:	7139                	addi	sp,sp,-64
    5e2a:	fc06                	sd	ra,56(sp)
    5e2c:	f822                	sd	s0,48(sp)
    5e2e:	f04a                	sd	s2,32(sp)
    5e30:	ec4e                	sd	s3,24(sp)
    5e32:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
    5e34:	02051993          	slli	s3,a0,0x20
    5e38:	0209d993          	srli	s3,s3,0x20
    5e3c:	09bd                	addi	s3,s3,15
    5e3e:	0049d993          	srli	s3,s3,0x4
    5e42:	2985                	addiw	s3,s3,1
    5e44:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
    5e46:	00005517          	auipc	a0,0x5
    5e4a:	69a53503          	ld	a0,1690(a0) # b4e0 <freep>
    5e4e:	c905                	beqz	a0,5e7e <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
    5e50:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
    5e52:	4798                	lw	a4,8(a5)
    5e54:	09377663          	bgeu	a4,s3,5ee0 <malloc+0xb8>
    5e58:	f426                	sd	s1,40(sp)
    5e5a:	e852                	sd	s4,16(sp)
    5e5c:	e456                	sd	s5,8(sp)
    5e5e:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
    5e60:	8a4e                	mv	s4,s3
    5e62:	6705                	lui	a4,0x1
    5e64:	00e9f363          	bgeu	s3,a4,5e6a <malloc+0x42>
    5e68:	6a05                	lui	s4,0x1
    5e6a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5e6e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
    5e72:	00005497          	auipc	s1,0x5
    5e76:	66e48493          	addi	s1,s1,1646 # b4e0 <freep>
  if (p == SBRK_ERROR)
    5e7a:	5afd                	li	s5,-1
    5e7c:	a83d                	j	5eba <malloc+0x92>
    5e7e:	f426                	sd	s1,40(sp)
    5e80:	e852                	sd	s4,16(sp)
    5e82:	e456                	sd	s5,8(sp)
    5e84:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    5e86:	0000c797          	auipc	a5,0xc
    5e8a:	e8278793          	addi	a5,a5,-382 # 11d08 <base>
    5e8e:	00005717          	auipc	a4,0x5
    5e92:	64f73923          	sd	a5,1618(a4) # b4e0 <freep>
    5e96:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5e98:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
    5e9c:	b7d1                	j	5e60 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
    5e9e:	6398                	ld	a4,0(a5)
    5ea0:	e118                	sd	a4,0(a0)
    5ea2:	a899                	j	5ef8 <malloc+0xd0>
  hp->s.size = nu;
    5ea4:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
    5ea8:	0541                	addi	a0,a0,16
    5eaa:	ef9ff0ef          	jal	5da2 <free>
  return freep;
    5eae:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
    5eb0:	c125                	beqz	a0,5f10 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
    5eb2:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
    5eb4:	4798                	lw	a4,8(a5)
    5eb6:	03277163          	bgeu	a4,s2,5ed8 <malloc+0xb0>
    if (p == freep)
    5eba:	6098                	ld	a4,0(s1)
    5ebc:	853e                	mv	a0,a5
    5ebe:	fef71ae3          	bne	a4,a5,5eb2 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
    5ec2:	8552                	mv	a0,s4
    5ec4:	a23ff0ef          	jal	58e6 <sbrk>
  if (p == SBRK_ERROR)
    5ec8:	fd551ee3          	bne	a0,s5,5ea4 <malloc+0x7c>
        return 0;
    5ecc:	4501                	li	a0,0
    5ece:	74a2                	ld	s1,40(sp)
    5ed0:	6a42                	ld	s4,16(sp)
    5ed2:	6aa2                	ld	s5,8(sp)
    5ed4:	6b02                	ld	s6,0(sp)
    5ed6:	a03d                	j	5f04 <malloc+0xdc>
    5ed8:	74a2                	ld	s1,40(sp)
    5eda:	6a42                	ld	s4,16(sp)
    5edc:	6aa2                	ld	s5,8(sp)
    5ede:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
    5ee0:	fae90fe3          	beq	s2,a4,5e9e <malloc+0x76>
        p->s.size -= nunits;
    5ee4:	4137073b          	subw	a4,a4,s3
    5ee8:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5eea:	02071693          	slli	a3,a4,0x20
    5eee:	01c6d713          	srli	a4,a3,0x1c
    5ef2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5ef4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5ef8:	00005717          	auipc	a4,0x5
    5efc:	5ea73423          	sd	a0,1512(a4) # b4e0 <freep>
      return (void *)(p + 1);
    5f00:	01078513          	addi	a0,a5,16
  }
}
    5f04:	70e2                	ld	ra,56(sp)
    5f06:	7442                	ld	s0,48(sp)
    5f08:	7902                	ld	s2,32(sp)
    5f0a:	69e2                	ld	s3,24(sp)
    5f0c:	6121                	addi	sp,sp,64
    5f0e:	8082                	ret
    5f10:	74a2                	ld	s1,40(sp)
    5f12:	6a42                	ld	s4,16(sp)
    5f14:	6aa2                	ld	s5,8(sp)
    5f16:	6b02                	ld	s6,0(sp)
    5f18:	b7f5                	j	5f04 <malloc+0xdc>
