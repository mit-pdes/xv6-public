
user/_pagerepl:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print_row>:
}

// Print row of frames and status
static void
print_row(int step, int page, int frames[], int num_frames, const char *status)
{
       0:	7139                	addi	sp,sp,-64
       2:	fc06                	sd	ra,56(sp)
       4:	f822                	sd	s0,48(sp)
       6:	f04a                	sd	s2,32(sp)
       8:	ec4e                	sd	s3,24(sp)
       a:	e05a                	sd	s6,0(sp)
       c:	0080                	addi	s0,sp,64
       e:	8932                	mv	s2,a2
      10:	89b6                	mv	s3,a3
      12:	8b3a                	mv	s6,a4
  printf("  %d\t|   %d\t| [", step + 1, page);
      14:	862e                	mv	a2,a1
      16:	0015059b          	addiw	a1,a0,1
      1a:	00001517          	auipc	a0,0x1
      1e:	10650513          	addi	a0,a0,262 # 1120 <malloc+0xf6>
      22:	751000ef          	jal	f72 <printf>
  for (int i = 0; i < num_frames; i++) {
      26:	05305263          	blez	s3,6a <print_row+0x6a>
      2a:	f426                	sd	s1,40(sp)
      2c:	e852                	sd	s4,16(sp)
      2e:	e456                	sd	s5,8(sp)
      30:	84ca                	mv	s1,s2
      32:	098a                	slli	s3,s3,0x2
      34:	994e                	add	s2,s2,s3
    if (frames[i] == -1)
      36:	59fd                	li	s3,-1
      printf(" - ");
    else
      printf(" %d ", frames[i]);
      38:	00001a17          	auipc	s4,0x1
      3c:	100a0a13          	addi	s4,s4,256 # 1138 <malloc+0x10e>
      printf(" - ");
      40:	00001a97          	auipc	s5,0x1
      44:	0f0a8a93          	addi	s5,s5,240 # 1130 <malloc+0x106>
      48:	a039                	j	56 <print_row+0x56>
      4a:	8556                	mv	a0,s5
      4c:	727000ef          	jal	f72 <printf>
  for (int i = 0; i < num_frames; i++) {
      50:	0491                	addi	s1,s1,4
      52:	01248963          	beq	s1,s2,64 <print_row+0x64>
    if (frames[i] == -1)
      56:	408c                	lw	a1,0(s1)
      58:	ff3589e3          	beq	a1,s3,4a <print_row+0x4a>
      printf(" %d ", frames[i]);
      5c:	8552                	mv	a0,s4
      5e:	715000ef          	jal	f72 <printf>
      62:	b7fd                	j	50 <print_row+0x50>
      64:	74a2                	ld	s1,40(sp)
      66:	6a42                	ld	s4,16(sp)
      68:	6aa2                	ld	s5,8(sp)
  }
  printf("]\t| %s\n", status);
      6a:	85da                	mv	a1,s6
      6c:	00001517          	auipc	a0,0x1
      70:	0d450513          	addi	a0,a0,212 # 1140 <malloc+0x116>
      74:	6ff000ef          	jal	f72 <printf>
}
      78:	70e2                	ld	ra,56(sp)
      7a:	7442                	ld	s0,48(sp)
      7c:	7902                	ld	s2,32(sp)
      7e:	69e2                	ld	s3,24(sp)
      80:	6b02                	ld	s6,0(sp)
      82:	6121                	addi	sp,sp,64
      84:	8082                	ret

0000000000000086 <print_percentage>:
{
      86:	1141                	addi	sp,sp,-16
      88:	e406                	sd	ra,8(sp)
      8a:	e022                	sd	s0,0(sp)
      8c:	0800                	addi	s0,sp,16
      8e:	87ae                	mv	a5,a1
  int whole = (num * 100) / total;
      90:	06400713          	li	a4,100
      94:	02e505bb          	mulw	a1,a0,a4
      98:	02f5c5bb          	divw	a1,a1,a5
  int frac = ((num * 10000) / total) % 100;
      9c:	6689                	lui	a3,0x2
      9e:	7106869b          	addiw	a3,a3,1808 # 2710 <base+0x700>
      a2:	02d5063b          	mulw	a2,a0,a3
      a6:	02f6463b          	divw	a2,a2,a5
      aa:	51eb87b7          	lui	a5,0x51eb8
      ae:	51f78793          	addi	a5,a5,1311 # 51eb851f <base+0x51eb650f>
      b2:	02f607b3          	mul	a5,a2,a5
      b6:	9795                	srai	a5,a5,0x25
      b8:	41f6569b          	sraiw	a3,a2,0x1f
      bc:	9f95                	subw	a5,a5,a3
      be:	02f7073b          	mulw	a4,a4,a5
      c2:	9e19                	subw	a2,a2,a4
  if (frac < 10)
      c4:	47a5                	li	a5,9
      c6:	00c7cc63          	blt	a5,a2,de <print_percentage+0x58>
    printf("%d.0%d%%", whole, frac);
      ca:	00001517          	auipc	a0,0x1
      ce:	07e50513          	addi	a0,a0,126 # 1148 <malloc+0x11e>
      d2:	6a1000ef          	jal	f72 <printf>
}
      d6:	60a2                	ld	ra,8(sp)
      d8:	6402                	ld	s0,0(sp)
      da:	0141                	addi	sp,sp,16
      dc:	8082                	ret
    printf("%d.%d%%", whole, frac);
      de:	00001517          	auipc	a0,0x1
      e2:	07a50513          	addi	a0,a0,122 # 1158 <malloc+0x12e>
      e6:	68d000ef          	jal	f72 <printf>
}
      ea:	b7f5                	j	d6 <print_percentage+0x50>

00000000000000ec <run_fifo>:

// Simulate FIFO
static void
run_fifo(const int refs[], int nrefs, int nframes, int verbose, int *out_faults, int *out_hits)
{
      ec:	716d                	addi	sp,sp,-272
      ee:	e606                	sd	ra,264(sp)
      f0:	e222                	sd	s0,256(sp)
      f2:	f9ca                	sd	s2,240(sp)
      f4:	f5ce                	sd	s3,232(sp)
      f6:	e5de                	sd	s7,200(sp)
      f8:	e1e2                	sd	s8,192(sp)
      fa:	fd66                	sd	s9,184(sp)
      fc:	f96a                	sd	s10,176(sp)
      fe:	0a00                	addi	s0,sp,272
     100:	89aa                	mv	s3,a0
     102:	8cae                	mv	s9,a1
     104:	8932                	mv	s2,a2
     106:	8c36                	mv	s8,a3
     108:	eee43c23          	sd	a4,-264(s0)
     10c:	eef43823          	sd	a5,-272(s0)
  int frames[MAX_FRAMES];
  int fifo_queue[MAX_FRAMES];
  int head = 0, tail = 0;
  int faults = 0, hits = 0;

  for (int i = 0; i < nframes; i++) {
     110:	00c05f63          	blez	a2,12e <run_fifo+0x42>
     114:	f5040793          	addi	a5,s0,-176
     118:	f1040713          	addi	a4,s0,-240
     11c:	060a                	slli	a2,a2,0x2
     11e:	963e                	add	a2,a2,a5
    frames[i] = -1;
     120:	56fd                	li	a3,-1
     122:	c394                	sw	a3,0(a5)
    fifo_queue[i] = -1;
     124:	c314                	sw	a3,0(a4)
  for (int i = 0; i < nframes; i++) {
     126:	0791                	addi	a5,a5,4
     128:	0711                	addi	a4,a4,4
     12a:	fec79ce3          	bne	a5,a2,122 <run_fifo+0x36>
  }

  if (verbose) {
     12e:	020c1963          	bnez	s8,160 <run_fifo+0x74>
    printf("------------------------------------------------------------\n");
    printf("  Step\t|  Page\t|  Frame Contents\t| Status\n");
    printf("------------------------------------------------------------\n");
  }

  for (int i = 0; i < nrefs; i++) {
     132:	8be2                	mv	s7,s8
     134:	8d62                	mv	s10,s8
     136:	0d905d63          	blez	s9,210 <run_fifo+0x124>
     13a:	fda6                	sd	s1,248(sp)
     13c:	f1d2                	sd	s4,224(sp)
     13e:	edd6                	sd	s5,216(sp)
     140:	e9da                	sd	s6,208(sp)
     142:	f56e                	sd	s11,168(sp)
     144:	00291493          	slli	s1,s2,0x2
     148:	f5040793          	addi	a5,s0,-176
     14c:	94be                	add	s1,s1,a5
{
     14e:	4a01                	li	s4,0
     150:	4b81                	li	s7,0
     152:	4d01                	li	s10,0
     154:	4b01                	li	s6,0
     156:	f0043023          	sd	zero,-256(s0)
    }

    if (hit) {
      hits++;
      if (verbose)
        print_row(i, p, frames, nframes, "HIT ");
     15a:	8dbe                	mv	s11,a5
    } else {
      faults++;
      int empty_idx = -1;
      for (int j = 0; j < nframes; j++) {
        if (frames[j] == -1) {
     15c:	5afd                	li	s5,-1
     15e:	a21d                	j	284 <run_fifo+0x198>
    printf("------------------------------------------------------------\n");
     160:	00001517          	auipc	a0,0x1
     164:	00050513          	mv	a0,a0
     168:	60b000ef          	jal	f72 <printf>
    printf(" FIFO Simulation (Frames: %d)\n", nframes);
     16c:	85ca                	mv	a1,s2
     16e:	00001517          	auipc	a0,0x1
     172:	03250513          	addi	a0,a0,50 # 11a0 <malloc+0x176>
     176:	5fd000ef          	jal	f72 <printf>
    printf("------------------------------------------------------------\n");
     17a:	00001517          	auipc	a0,0x1
     17e:	fe650513          	addi	a0,a0,-26 # 1160 <malloc+0x136>
     182:	5f1000ef          	jal	f72 <printf>
    printf("  Step\t|  Page\t|  Frame Contents\t| Status\n");
     186:	00001517          	auipc	a0,0x1
     18a:	03a50513          	addi	a0,a0,58 # 11c0 <malloc+0x196>
     18e:	5e5000ef          	jal	f72 <printf>
    printf("------------------------------------------------------------\n");
     192:	00001517          	auipc	a0,0x1
     196:	fce50513          	addi	a0,a0,-50 # 1160 <malloc+0x136>
     19a:	5d9000ef          	jal	f72 <printf>
  for (int i = 0; i < nrefs; i++) {
     19e:	f9904ee3          	bgtz	s9,13a <run_fifo+0x4e>
     1a2:	4b81                	li	s7,0
     1a4:	4d01                	li	s10,0
     1a6:	a861                	j	23e <run_fifo+0x152>
        print_row(i, p, frames, nframes, "HIT ");
     1a8:	00001717          	auipc	a4,0x1
     1ac:	04870713          	addi	a4,a4,72 # 11f0 <malloc+0x1c6>
     1b0:	86ca                	mv	a3,s2
     1b2:	866e                	mv	a2,s11
     1b4:	8552                	mv	a0,s4
     1b6:	e4bff0ef          	jal	0 <print_row>
     1ba:	a0c9                	j	27c <run_fifo+0x190>
          empty_idx = j;
          break;
        }
      }

      if (empty_idx != -1) {
     1bc:	0f578b63          	beq	a5,s5,2b2 <run_fifo+0x1c6>
        frames[empty_idx] = p;
     1c0:	00279713          	slli	a4,a5,0x2
     1c4:	976e                	add	a4,a4,s11
     1c6:	c30c                	sw	a1,0(a4)
        fifo_queue[tail] = empty_idx;
        tail = (tail + 1) % nframes;
     1c8:	001b071b          	addiw	a4,s6,1
     1cc:	0327673b          	remw	a4,a4,s2
     1d0:	f0e43423          	sd	a4,-248(s0)
        fifo_queue[tail] = empty_idx;
     1d4:	0b0a                	slli	s6,s6,0x2
     1d6:	f1040713          	addi	a4,s0,-240
     1da:	9b3a                	add	s6,s6,a4
     1dc:	00fb2023          	sw	a5,0(s6)
        frames[victim_slot] = p;
        fifo_queue[tail] = victim_slot;
        tail = (tail + 1) % nframes;
      }

      if (verbose)
     1e0:	f0843b03          	ld	s6,-248(s0)
     1e4:	080c0c63          	beqz	s8,27c <run_fifo+0x190>
        print_row(i, p, frames, nframes, "FAULT");
     1e8:	00001717          	auipc	a4,0x1
     1ec:	01070713          	addi	a4,a4,16 # 11f8 <malloc+0x1ce>
     1f0:	86ca                	mv	a3,s2
     1f2:	f5040613          	addi	a2,s0,-176
     1f6:	8552                	mv	a0,s4
     1f8:	e09ff0ef          	jal	0 <print_row>
     1fc:	f0843b03          	ld	s6,-248(s0)
     200:	a8b5                	j	27c <run_fifo+0x190>
    }
  }

  if (verbose) {
     202:	020c1963          	bnez	s8,234 <run_fifo+0x148>
     206:	74ee                	ld	s1,248(sp)
     208:	7a0e                	ld	s4,224(sp)
     20a:	6aee                	ld	s5,216(sp)
     20c:	6b4e                	ld	s6,208(sp)
     20e:	7daa                	ld	s11,168(sp)
           nframes, faults, hits);
    print_percentage(hits, nrefs);
    printf("\n\n");
  }

  *out_faults = faults;
     210:	ef843783          	ld	a5,-264(s0)
     214:	01a7a023          	sw	s10,0(a5)
  *out_hits = hits;
     218:	ef043783          	ld	a5,-272(s0)
     21c:	0177a023          	sw	s7,0(a5)
}
     220:	60b2                	ld	ra,264(sp)
     222:	6412                	ld	s0,256(sp)
     224:	794e                	ld	s2,240(sp)
     226:	79ae                	ld	s3,232(sp)
     228:	6bae                	ld	s7,200(sp)
     22a:	6c0e                	ld	s8,192(sp)
     22c:	7cea                	ld	s9,184(sp)
     22e:	7d4a                	ld	s10,176(sp)
     230:	6151                	addi	sp,sp,272
     232:	8082                	ret
     234:	74ee                	ld	s1,248(sp)
     236:	7a0e                	ld	s4,224(sp)
     238:	6aee                	ld	s5,216(sp)
     23a:	6b4e                	ld	s6,208(sp)
     23c:	7daa                	ld	s11,168(sp)
    printf("------------------------------------------------------------\n");
     23e:	00001517          	auipc	a0,0x1
     242:	f2250513          	addi	a0,a0,-222 # 1160 <malloc+0x136>
     246:	52d000ef          	jal	f72 <printf>
    printf("FIFO Result (%d frames): Faults = %d, Hits = %d, Hit Ratio = ",
     24a:	86de                	mv	a3,s7
     24c:	866a                	mv	a2,s10
     24e:	85ca                	mv	a1,s2
     250:	00001517          	auipc	a0,0x1
     254:	fb050513          	addi	a0,a0,-80 # 1200 <malloc+0x1d6>
     258:	51b000ef          	jal	f72 <printf>
    print_percentage(hits, nrefs);
     25c:	85e6                	mv	a1,s9
     25e:	855e                	mv	a0,s7
     260:	e27ff0ef          	jal	86 <print_percentage>
    printf("\n\n");
     264:	00001517          	auipc	a0,0x1
     268:	fdc50513          	addi	a0,a0,-36 # 1240 <malloc+0x216>
     26c:	507000ef          	jal	f72 <printf>
     270:	b745                	j	210 <run_fifo+0x124>
      faults++;
     272:	2d05                	addiw	s10,s10,1
      for (int j = 0; j < nframes; j++) {
     274:	a83d                	j	2b2 <run_fifo+0x1c6>
      hits++;
     276:	2b85                	addiw	s7,s7,1
      if (verbose)
     278:	f20c18e3          	bnez	s8,1a8 <run_fifo+0xbc>
  for (int i = 0; i < nrefs; i++) {
     27c:	2a05                	addiw	s4,s4,1
     27e:	0991                	addi	s3,s3,4
     280:	f94c81e3          	beq	s9,s4,202 <run_fifo+0x116>
    int p = refs[i];
     284:	0009a583          	lw	a1,0(s3)
    for (int j = 0; j < nframes; j++) {
     288:	ff2055e3          	blez	s2,272 <run_fifo+0x186>
     28c:	f5040793          	addi	a5,s0,-176
      if (frames[j] == p) {
     290:	4398                	lw	a4,0(a5)
     292:	feb702e3          	beq	a4,a1,276 <run_fifo+0x18a>
    for (int j = 0; j < nframes; j++) {
     296:	0791                	addi	a5,a5,4
     298:	fe979ce3          	bne	a5,s1,290 <run_fifo+0x1a4>
      faults++;
     29c:	2d05                	addiw	s10,s10,1
     29e:	f5040713          	addi	a4,s0,-176
      for (int j = 0; j < nframes; j++) {
     2a2:	4781                	li	a5,0
        if (frames[j] == -1) {
     2a4:	4314                	lw	a3,0(a4)
     2a6:	f1568be3          	beq	a3,s5,1bc <run_fifo+0xd0>
      for (int j = 0; j < nframes; j++) {
     2aa:	2785                	addiw	a5,a5,1
     2ac:	0711                	addi	a4,a4,4
     2ae:	fef91be3          	bne	s2,a5,2a4 <run_fifo+0x1b8>
        int victim_slot = fifo_queue[head];
     2b2:	f0043703          	ld	a4,-256(s0)
     2b6:	00271793          	slli	a5,a4,0x2
     2ba:	f9078793          	addi	a5,a5,-112
     2be:	97a2                	add	a5,a5,s0
     2c0:	f807a783          	lw	a5,-128(a5)
        head = (head + 1) % nframes;
     2c4:	2705                	addiw	a4,a4,1
     2c6:	0327673b          	remw	a4,a4,s2
     2ca:	f0e43023          	sd	a4,-256(s0)
        frames[victim_slot] = p;
     2ce:	00279713          	slli	a4,a5,0x2
     2d2:	f9070713          	addi	a4,a4,-112
     2d6:	9722                	add	a4,a4,s0
     2d8:	fcb72023          	sw	a1,-64(a4)
        tail = (tail + 1) % nframes;
     2dc:	001b071b          	addiw	a4,s6,1
     2e0:	0327673b          	remw	a4,a4,s2
     2e4:	f0e43423          	sd	a4,-248(s0)
     2e8:	b5f5                	j	1d4 <run_fifo+0xe8>

00000000000002ea <run_lru>:

// Simulate LRU
static void
run_lru(const int refs[], int nrefs, int nframes, int verbose, int *out_faults, int *out_hits)
{
     2ea:	7111                	addi	sp,sp,-256
     2ec:	fd86                	sd	ra,248(sp)
     2ee:	f9a2                	sd	s0,240(sp)
     2f0:	f5a6                	sd	s1,232(sp)
     2f2:	edce                	sd	s3,216(sp)
     2f4:	e5d6                	sd	s5,200(sp)
     2f6:	e1da                	sd	s6,192(sp)
     2f8:	fd5e                	sd	s7,184(sp)
     2fa:	f566                	sd	s9,168(sp)
     2fc:	0200                	addi	s0,sp,256
     2fe:	89aa                	mv	s3,a0
     300:	8bae                	mv	s7,a1
     302:	84b2                	mv	s1,a2
     304:	8b36                	mv	s6,a3
     306:	f0e43423          	sd	a4,-248(s0)
     30a:	f0f43023          	sd	a5,-256(s0)
  int frames[MAX_FRAMES];
  int last_access[MAX_FRAMES];
  int faults = 0, hits = 0;

  for (int i = 0; i < nframes; i++) {
     30e:	00c05f63          	blez	a2,32c <run_lru+0x42>
     312:	f5040793          	addi	a5,s0,-176
     316:	f1040713          	addi	a4,s0,-240
     31a:	060a                	slli	a2,a2,0x2
     31c:	963e                	add	a2,a2,a5
    frames[i] = -1;
     31e:	56fd                	li	a3,-1
     320:	c394                	sw	a3,0(a5)
    last_access[i] = -1;
     322:	c314                	sw	a3,0(a4)
  for (int i = 0; i < nframes; i++) {
     324:	0791                	addi	a5,a5,4
     326:	0711                	addi	a4,a4,4
     328:	fec79ce3          	bne	a5,a2,320 <run_lru+0x36>
  }

  if (verbose) {
     32c:	020b1863          	bnez	s6,35c <run_lru+0x72>
    printf("------------------------------------------------------------\n");
    printf("  Step\t|  Page\t|  Frame Contents\t| Status\n");
    printf("------------------------------------------------------------\n");
  }

  for (int i = 0; i < nrefs; i++) {
     330:	8ada                	mv	s5,s6
     332:	8cda                	mv	s9,s6
     334:	15705363          	blez	s7,47a <run_lru+0x190>
     338:	f1ca                	sd	s2,224(sp)
     33a:	e9d2                	sd	s4,208(sp)
     33c:	f962                	sd	s8,176(sp)
     33e:	f16a                	sd	s10,160(sp)
     340:	ed6e                	sd	s11,152(sp)
{
     342:	4901                	li	s2,0
     344:	4a81                	li	s5,0
     346:	4c81                	li	s9,0
        print_row(i, p, frames, nframes, "HIT ");
    } else {
      faults++;
      int empty_idx = -1;
      for (int j = 0; j < nframes; j++) {
        if (frames[j] == -1) {
     348:	5a7d                	li	s4,-1
          break;
        }
      }

      if (empty_idx != -1) {
        frames[empty_idx] = p;
     34a:	f5040d13          	addi	s10,s0,-176
        last_access[empty_idx] = i;
     34e:	f1040c13          	addi	s8,s0,-240
        print_row(i, p, frames, nframes, "HIT ");
     352:	00001d97          	auipc	s11,0x1
     356:	e9ed8d93          	addi	s11,s11,-354 # 11f0 <malloc+0x1c6>
     35a:	a095                	j	3be <run_lru+0xd4>
    printf("------------------------------------------------------------\n");
     35c:	00001517          	auipc	a0,0x1
     360:	e0450513          	addi	a0,a0,-508 # 1160 <malloc+0x136>
     364:	40f000ef          	jal	f72 <printf>
    printf(" LRU Simulation (Frames: %d)\n", nframes);
     368:	85a6                	mv	a1,s1
     36a:	00001517          	auipc	a0,0x1
     36e:	ede50513          	addi	a0,a0,-290 # 1248 <malloc+0x21e>
     372:	401000ef          	jal	f72 <printf>
    printf("------------------------------------------------------------\n");
     376:	00001517          	auipc	a0,0x1
     37a:	dea50513          	addi	a0,a0,-534 # 1160 <malloc+0x136>
     37e:	3f5000ef          	jal	f72 <printf>
    printf("  Step\t|  Page\t|  Frame Contents\t| Status\n");
     382:	00001517          	auipc	a0,0x1
     386:	e3e50513          	addi	a0,a0,-450 # 11c0 <malloc+0x196>
     38a:	3e9000ef          	jal	f72 <printf>
    printf("------------------------------------------------------------\n");
     38e:	00001517          	auipc	a0,0x1
     392:	dd250513          	addi	a0,a0,-558 # 1160 <malloc+0x136>
     396:	3dd000ef          	jal	f72 <printf>
  for (int i = 0; i < nrefs; i++) {
     39a:	f9704fe3          	bgtz	s7,338 <run_lru+0x4e>
     39e:	4a81                	li	s5,0
     3a0:	4c81                	li	s9,0
     3a2:	a219                	j	4a8 <run_lru+0x1be>
    if (hit_idx != -1) {
     3a4:	03478b63          	beq	a5,s4,3da <run_lru+0xf0>
      hits++;
     3a8:	2a85                	addiw	s5,s5,1
      last_access[hit_idx] = i;
     3aa:	078a                	slli	a5,a5,0x2
     3ac:	97e2                	add	a5,a5,s8
     3ae:	0127a023          	sw	s2,0(a5)
      if (verbose)
     3b2:	040b1863          	bnez	s6,402 <run_lru+0x118>
  for (int i = 0; i < nrefs; i++) {
     3b6:	2905                	addiw	s2,s2,1
     3b8:	0991                	addi	s3,s3,4
     3ba:	0b795963          	bge	s2,s7,46c <run_lru+0x182>
    int p = refs[i];
     3be:	0009a583          	lw	a1,0(s3)
    for (int j = 0; j < nframes; j++) {
     3c2:	10905d63          	blez	s1,4dc <run_lru+0x1f2>
     3c6:	f5040713          	addi	a4,s0,-176
     3ca:	4781                	li	a5,0
      if (frames[j] == p) {
     3cc:	4314                	lw	a3,0(a4)
     3ce:	fcb68be3          	beq	a3,a1,3a4 <run_lru+0xba>
    for (int j = 0; j < nframes; j++) {
     3d2:	2785                	addiw	a5,a5,1
     3d4:	0711                	addi	a4,a4,4
     3d6:	fef49be3          	bne	s1,a5,3cc <run_lru+0xe2>
      faults++;
     3da:	2c85                	addiw	s9,s9,1
      for (int j = 0; j < nframes; j++) {
     3dc:	f5040713          	addi	a4,s0,-176
     3e0:	4781                	li	a5,0
        if (frames[j] == -1) {
     3e2:	4314                	lw	a3,0(a4)
     3e4:	03468663          	beq	a3,s4,410 <run_lru+0x126>
      for (int j = 0; j < nframes; j++) {
     3e8:	2785                	addiw	a5,a5,1
     3ea:	0711                	addi	a4,a4,4
     3ec:	fef49be3          	bne	s1,a5,3e2 <run_lru+0xf8>
      } else {
        int lru_slot = 0;
        int min_time = last_access[0];
        for (int j = 1; j < nframes; j++) {
     3f0:	4785                	li	a5,1
     3f2:	0497df63          	bge	a5,s1,450 <run_lru+0x166>
        int min_time = last_access[0];
     3f6:	f1042603          	lw	a2,-240(s0)
     3fa:	f1440713          	addi	a4,s0,-236
        int lru_slot = 0;
     3fe:	4501                	li	a0,0
     400:	a091                	j	444 <run_lru+0x15a>
        print_row(i, p, frames, nframes, "HIT ");
     402:	876e                	mv	a4,s11
     404:	86a6                	mv	a3,s1
     406:	866a                	mv	a2,s10
     408:	854a                	mv	a0,s2
     40a:	bf7ff0ef          	jal	0 <print_row>
     40e:	b765                	j	3b6 <run_lru+0xcc>
      if (empty_idx != -1) {
     410:	ff4780e3          	beq	a5,s4,3f0 <run_lru+0x106>
        frames[empty_idx] = p;
     414:	078a                	slli	a5,a5,0x2
     416:	01a78733          	add	a4,a5,s10
     41a:	c30c                	sw	a1,0(a4)
        last_access[empty_idx] = i;
     41c:	97e2                	add	a5,a5,s8
     41e:	0127a023          	sw	s2,0(a5)
        }
        frames[lru_slot] = p;
        last_access[lru_slot] = i;
      }

      if (verbose)
     422:	f80b0ae3          	beqz	s6,3b6 <run_lru+0xcc>
        print_row(i, p, frames, nframes, "FAULT");
     426:	00001717          	auipc	a4,0x1
     42a:	dd270713          	addi	a4,a4,-558 # 11f8 <malloc+0x1ce>
     42e:	86a6                	mv	a3,s1
     430:	f5040613          	addi	a2,s0,-176
     434:	854a                	mv	a0,s2
     436:	bcbff0ef          	jal	0 <print_row>
     43a:	bfb5                	j	3b6 <run_lru+0xcc>
        for (int j = 1; j < nframes; j++) {
     43c:	2785                	addiw	a5,a5,1
     43e:	0711                	addi	a4,a4,4
     440:	00f48963          	beq	s1,a5,452 <run_lru+0x168>
          if (last_access[j] < min_time) {
     444:	4314                	lw	a3,0(a4)
     446:	fec6dbe3          	bge	a3,a2,43c <run_lru+0x152>
            min_time = last_access[j];
     44a:	8636                	mv	a2,a3
            lru_slot = j;
     44c:	853e                	mv	a0,a5
     44e:	b7fd                	j	43c <run_lru+0x152>
        int lru_slot = 0;
     450:	4501                	li	a0,0
        frames[lru_slot] = p;
     452:	050a                	slli	a0,a0,0x2
     454:	f9050793          	addi	a5,a0,-112
     458:	97a2                	add	a5,a5,s0
     45a:	fcb7a023          	sw	a1,-64(a5)
        last_access[lru_slot] = i;
     45e:	f9050793          	addi	a5,a0,-112
     462:	00878533          	add	a0,a5,s0
     466:	f9252023          	sw	s2,-128(a0)
     46a:	bf65                	j	422 <run_lru+0x138>
    }
  }

  if (verbose) {
     46c:	020b1963          	bnez	s6,49e <run_lru+0x1b4>
     470:	790e                	ld	s2,224(sp)
     472:	6a4e                	ld	s4,208(sp)
     474:	7c4a                	ld	s8,176(sp)
     476:	7d0a                	ld	s10,160(sp)
     478:	6dea                	ld	s11,152(sp)
           nframes, faults, hits);
    print_percentage(hits, nrefs);
    printf("\n\n");
  }

  *out_faults = faults;
     47a:	f0843783          	ld	a5,-248(s0)
     47e:	0197a023          	sw	s9,0(a5)
  *out_hits = hits;
     482:	f0043783          	ld	a5,-256(s0)
     486:	0157a023          	sw	s5,0(a5)
}
     48a:	70ee                	ld	ra,248(sp)
     48c:	744e                	ld	s0,240(sp)
     48e:	74ae                	ld	s1,232(sp)
     490:	69ee                	ld	s3,216(sp)
     492:	6aae                	ld	s5,200(sp)
     494:	6b0e                	ld	s6,192(sp)
     496:	7bea                	ld	s7,184(sp)
     498:	7caa                	ld	s9,168(sp)
     49a:	6111                	addi	sp,sp,256
     49c:	8082                	ret
     49e:	790e                	ld	s2,224(sp)
     4a0:	6a4e                	ld	s4,208(sp)
     4a2:	7c4a                	ld	s8,176(sp)
     4a4:	7d0a                	ld	s10,160(sp)
     4a6:	6dea                	ld	s11,152(sp)
    printf("------------------------------------------------------------\n");
     4a8:	00001517          	auipc	a0,0x1
     4ac:	cb850513          	addi	a0,a0,-840 # 1160 <malloc+0x136>
     4b0:	2c3000ef          	jal	f72 <printf>
    printf("LRU Result (%d frames): Faults = %d, Hits = %d, Hit Ratio = ",
     4b4:	86d6                	mv	a3,s5
     4b6:	8666                	mv	a2,s9
     4b8:	85a6                	mv	a1,s1
     4ba:	00001517          	auipc	a0,0x1
     4be:	dae50513          	addi	a0,a0,-594 # 1268 <malloc+0x23e>
     4c2:	2b1000ef          	jal	f72 <printf>
    print_percentage(hits, nrefs);
     4c6:	85de                	mv	a1,s7
     4c8:	8556                	mv	a0,s5
     4ca:	bbdff0ef          	jal	86 <print_percentage>
    printf("\n\n");
     4ce:	00001517          	auipc	a0,0x1
     4d2:	d7250513          	addi	a0,a0,-654 # 1240 <malloc+0x216>
     4d6:	29d000ef          	jal	f72 <printf>
     4da:	b745                	j	47a <run_lru+0x190>
      faults++;
     4dc:	2c85                	addiw	s9,s9,1
        int lru_slot = 0;
     4de:	4501                	li	a0,0
     4e0:	bf8d                	j	452 <run_lru+0x168>

00000000000004e2 <main>:

int
main(int argc, char *argv[])
{
     4e2:	7125                	addi	sp,sp,-416
     4e4:	ef06                	sd	ra,408(sp)
     4e6:	eb22                	sd	s0,400(sp)
     4e8:	e726                	sd	s1,392(sp)
     4ea:	e34a                	sd	s2,384(sp)
     4ec:	fece                	sd	s3,376(sp)
     4ee:	fad2                	sd	s4,368(sp)
     4f0:	f6d6                	sd	s5,360(sp)
     4f2:	f2da                	sd	s6,352(sp)
     4f4:	1300                	addi	s0,sp,416
  int custom_refs[MAX_REFS];
  const int *refs = default_ref_string;
  int nrefs = DEFAULT_REF_LEN;
  int target_frames = 3;

  if (argc > 1) {
     4f6:	4785                	li	a5,1
     4f8:	18a7d063          	bge	a5,a0,678 <main+0x196>
     4fc:	84aa                	mv	s1,a0
     4fe:	89ae                	mv	s3,a1
    target_frames = atoi(argv[1]);
     500:	6588                	ld	a0,8(a1)
     502:	4f8000ef          	jal	9fa <atoi>
     506:	8b2a                	mv	s6,a0
    if (target_frames <= 0 || target_frames > MAX_FRAMES) {
     508:	fff5071b          	addiw	a4,a0,-1
     50c:	47bd                	li	a5,15
     50e:	00e7ee63          	bltu	a5,a4,52a <main+0x48>
      printf("Usage: pagerepl [num_frames] [page1 page2 ...]\n");
      exit(1);
    }
    if (argc == 3 && strchr(argv[2], ' ')) {
     512:	478d                	li	a5,3
     514:	02f48963          	beq	s1,a5,546 <main+0x64>
        if (!*s) break;
        custom_refs[nrefs++] = atoi(s);
        while (*s && *s != ' ') s++;
      }
      refs = custom_refs;
    } else if (argc > 2) {
     518:	4789                	li	a5,2
     51a:	0c97c363          	blt	a5,s1,5e0 <main+0xfe>
  int nrefs = DEFAULT_REF_LEN;
     51e:	44d1                	li	s1,20
  const int *refs = default_ref_string;
     520:	00001a17          	auipc	s4,0x1
     524:	138a0a13          	addi	s4,s4,312 # 1658 <default_ref_string>
     528:	aab1                	j	684 <main+0x1a2>
     52a:	eede                	sd	s7,344(sp)
     52c:	eae2                	sd	s8,336(sp)
     52e:	e6e6                	sd	s9,328(sp)
     530:	e2ea                	sd	s10,320(sp)
     532:	fe6e                	sd	s11,312(sp)
      printf("Usage: pagerepl [num_frames] [page1 page2 ...]\n");
     534:	00001517          	auipc	a0,0x1
     538:	d8c50513          	addi	a0,a0,-628 # 12c0 <malloc+0x296>
     53c:	237000ef          	jal	f72 <printf>
      exit(1);
     540:	4505                	li	a0,1
     542:	5e2000ef          	jal	b24 <exit>
    if (argc == 3 && strchr(argv[2], ' ')) {
     546:	02000593          	li	a1,32
     54a:	0109b503          	ld	a0,16(s3)
     54e:	3d2000ef          	jal	920 <strchr>
     552:	c559                	beqz	a0,5e0 <main+0xfe>
      char *s = argv[2];
     554:	0109b903          	ld	s2,16(s3)
      while (*s && nrefs < MAX_REFS) {
     558:	e9040a13          	addi	s4,s0,-368
      nrefs = 0;
     55c:	4481                	li	s1,0
        while (*s == ' ') s++;
     55e:	02000993          	li	s3,32
      while (*s && nrefs < MAX_REFS) {
     562:	a01d                	j	588 <main+0xa6>
        custom_refs[nrefs++] = atoi(s);
     564:	2485                	addiw	s1,s1,1
     566:	854a                	mv	a0,s2
     568:	492000ef          	jal	9fa <atoi>
     56c:	00aa2023          	sw	a0,0(s4)
        while (*s && *s != ' ') s++;
     570:	00094783          	lbu	a5,0(s2)
     574:	0df7f793          	andi	a5,a5,223
     578:	c799                	beqz	a5,586 <main+0xa4>
     57a:	0905                	addi	s2,s2,1
     57c:	00094783          	lbu	a5,0(s2)
     580:	0df7f793          	andi	a5,a5,223
     584:	fbfd                	bnez	a5,57a <main+0x98>
     586:	0a11                	addi	s4,s4,4
      while (*s && nrefs < MAX_REFS) {
     588:	00094783          	lbu	a5,0(s2)
     58c:	0404a713          	slti	a4,s1,64
     590:	cb11                	beqz	a4,5a4 <main+0xc2>
     592:	cb89                	beqz	a5,5a4 <main+0xc2>
        while (*s == ' ') s++;
     594:	fd3798e3          	bne	a5,s3,564 <main+0x82>
     598:	0905                	addi	s2,s2,1
     59a:	00094783          	lbu	a5,0(s2)
     59e:	ff378de3          	beq	a5,s3,598 <main+0xb6>
        if (!*s) break;
     5a2:	f3e9                	bnez	a5,564 <main+0x82>
      refs = custom_refs;
    }
  }


  printf("============================================================\n");
     5a4:	00001517          	auipc	a0,0x1
     5a8:	d4c50513          	addi	a0,a0,-692 # 12f0 <malloc+0x2c6>
     5ac:	1c7000ef          	jal	f72 <printf>
  printf("     Page Replacement Algorithms Simulation (FIFO vs LRU)  \n");
     5b0:	00001517          	auipc	a0,0x1
     5b4:	d8050513          	addi	a0,a0,-640 # 1330 <malloc+0x306>
     5b8:	1bb000ef          	jal	f72 <printf>
  printf("============================================================\n\n");
     5bc:	00001517          	auipc	a0,0x1
     5c0:	db450513          	addi	a0,a0,-588 # 1370 <malloc+0x346>
     5c4:	1af000ef          	jal	f72 <printf>

  printf("Reference String (%d references):\n  ", nrefs);
     5c8:	85a6                	mv	a1,s1
     5ca:	00001517          	auipc	a0,0x1
     5ce:	de650513          	addi	a0,a0,-538 # 13b0 <malloc+0x386>
     5d2:	1a1000ef          	jal	f72 <printf>
  for (int i = 0; i < nrefs; i++) {
     5d6:	e9040a13          	addi	s4,s0,-368
     5da:	0e905e63          	blez	s1,6d6 <main+0x1f4>
     5de:	a8e1                	j	6b6 <main+0x1d4>
      nrefs = argc - 2;
     5e0:	ffe4851b          	addiw	a0,s1,-2
     5e4:	84aa                	mv	s1,a0
      if (nrefs > MAX_REFS)
     5e6:	04000793          	li	a5,64
     5ea:	00a7d463          	bge	a5,a0,5f2 <main+0x110>
     5ee:	04000493          	li	s1,64
     5f2:	2481                	sext.w	s1,s1
      for (int i = 0; i < nrefs; i++) {
     5f4:	894e                	mv	s2,s3
     5f6:	e9040a13          	addi	s4,s0,-368
     5fa:	00349793          	slli	a5,s1,0x3
     5fe:	99be                	add	s3,s3,a5
        custom_refs[i] = atoi(argv[i + 2]);
     600:	01093503          	ld	a0,16(s2)
     604:	3f6000ef          	jal	9fa <atoi>
     608:	00aa2023          	sw	a0,0(s4)
      for (int i = 0; i < nrefs; i++) {
     60c:	0921                	addi	s2,s2,8
     60e:	0a11                	addi	s4,s4,4
     610:	ff3918e3          	bne	s2,s3,600 <main+0x11e>
      refs = custom_refs;
     614:	e9040a13          	addi	s4,s0,-368
     618:	a0b5                	j	684 <main+0x1a2>

  run_fifo(refs, nrefs, target_frames, 1, &fifo_faults, &fifo_hits);
  run_lru(refs, nrefs, target_frames, 1, &lru_faults, &lru_hits);

  if (target_frames == 3 && refs == default_ref_string) {
    printf("--- Verification Against Expected Results (3 Frames) ---\n");
     61a:	00001517          	auipc	a0,0x1
     61e:	dfe50513          	addi	a0,a0,-514 # 1418 <malloc+0x3ee>
     622:	151000ef          	jal	f72 <printf>
    printf("FIFO Faults: %d (Expected: 15) -> %s\n",
     626:	e8c42583          	lw	a1,-372(s0)
     62a:	47bd                	li	a5,15
     62c:	00001617          	auipc	a2,0x1
     630:	c8c60613          	addi	a2,a2,-884 # 12b8 <malloc+0x28e>
     634:	02f58863          	beq	a1,a5,664 <main+0x182>
     638:	00001517          	auipc	a0,0x1
     63c:	e2050513          	addi	a0,a0,-480 # 1458 <malloc+0x42e>
     640:	133000ef          	jal	f72 <printf>
           fifo_faults, (fifo_faults == 15) ? "VERIFIED" : "FAILED");
    printf("LRU  Faults: %d (Expected: 12) -> %s\n\n",
     644:	e8442583          	lw	a1,-380(s0)
     648:	47b1                	li	a5,12
     64a:	00001617          	auipc	a2,0x1
     64e:	c6e60613          	addi	a2,a2,-914 # 12b8 <malloc+0x28e>
     652:	00f58e63          	beq	a1,a5,66e <main+0x18c>
     656:	00001517          	auipc	a0,0x1
     65a:	e2a50513          	addi	a0,a0,-470 # 1480 <malloc+0x456>
     65e:	115000ef          	jal	f72 <printf>
     662:	a0ed                	j	74c <main+0x26a>
    printf("FIFO Faults: %d (Expected: 15) -> %s\n",
     664:	00001617          	auipc	a2,0x1
     668:	c4460613          	addi	a2,a2,-956 # 12a8 <malloc+0x27e>
     66c:	b7f1                	j	638 <main+0x156>
    printf("LRU  Faults: %d (Expected: 12) -> %s\n\n",
     66e:	00001617          	auipc	a2,0x1
     672:	c3a60613          	addi	a2,a2,-966 # 12a8 <malloc+0x27e>
     676:	b7c5                	j	656 <main+0x174>
  int target_frames = 3;
     678:	4b0d                	li	s6,3
  int nrefs = DEFAULT_REF_LEN;
     67a:	44d1                	li	s1,20
  const int *refs = default_ref_string;
     67c:	00001a17          	auipc	s4,0x1
     680:	fdca0a13          	addi	s4,s4,-36 # 1658 <default_ref_string>
  printf("============================================================\n");
     684:	00001517          	auipc	a0,0x1
     688:	c6c50513          	addi	a0,a0,-916 # 12f0 <malloc+0x2c6>
     68c:	0e7000ef          	jal	f72 <printf>
  printf("     Page Replacement Algorithms Simulation (FIFO vs LRU)  \n");
     690:	00001517          	auipc	a0,0x1
     694:	ca050513          	addi	a0,a0,-864 # 1330 <malloc+0x306>
     698:	0db000ef          	jal	f72 <printf>
  printf("============================================================\n\n");
     69c:	00001517          	auipc	a0,0x1
     6a0:	cd450513          	addi	a0,a0,-812 # 1370 <malloc+0x346>
     6a4:	0cf000ef          	jal	f72 <printf>
  printf("Reference String (%d references):\n  ", nrefs);
     6a8:	85a6                	mv	a1,s1
     6aa:	00001517          	auipc	a0,0x1
     6ae:	d0650513          	addi	a0,a0,-762 # 13b0 <malloc+0x386>
     6b2:	0c1000ef          	jal	f72 <printf>
  for (int i = 0; i < nrefs; i++) {
     6b6:	8952                	mv	s2,s4
     6b8:	00249993          	slli	s3,s1,0x2
     6bc:	99d2                	add	s3,s3,s4
    printf("%d ", refs[i]);
     6be:	00001a97          	auipc	s5,0x1
     6c2:	d1aa8a93          	addi	s5,s5,-742 # 13d8 <malloc+0x3ae>
     6c6:	00092583          	lw	a1,0(s2)
     6ca:	8556                	mv	a0,s5
     6cc:	0a7000ef          	jal	f72 <printf>
  for (int i = 0; i < nrefs; i++) {
     6d0:	0911                	addi	s2,s2,4
     6d2:	ff391ae3          	bne	s2,s3,6c6 <main+0x1e4>
     6d6:	eede                	sd	s7,344(sp)
     6d8:	eae2                	sd	s8,336(sp)
     6da:	e6e6                	sd	s9,328(sp)
     6dc:	e2ea                	sd	s10,320(sp)
     6de:	fe6e                	sd	s11,312(sp)
  printf("\n\n");
     6e0:	00001517          	auipc	a0,0x1
     6e4:	b6050513          	addi	a0,a0,-1184 # 1240 <malloc+0x216>
     6e8:	08b000ef          	jal	f72 <printf>
  printf("============================================================\n");
     6ec:	00001517          	auipc	a0,0x1
     6f0:	c0450513          	addi	a0,a0,-1020 # 12f0 <malloc+0x2c6>
     6f4:	07f000ef          	jal	f72 <printf>
  printf("TASK B: Testing with %d Frames (Step-by-Step Trace)\n", target_frames);
     6f8:	85da                	mv	a1,s6
     6fa:	00001517          	auipc	a0,0x1
     6fe:	ce650513          	addi	a0,a0,-794 # 13e0 <malloc+0x3b6>
     702:	071000ef          	jal	f72 <printf>
  printf("============================================================\n\n");
     706:	00001517          	auipc	a0,0x1
     70a:	c6a50513          	addi	a0,a0,-918 # 1370 <malloc+0x346>
     70e:	065000ef          	jal	f72 <printf>
  run_fifo(refs, nrefs, target_frames, 1, &fifo_faults, &fifo_hits);
     712:	e8840793          	addi	a5,s0,-376
     716:	e8c40713          	addi	a4,s0,-372
     71a:	4685                	li	a3,1
     71c:	865a                	mv	a2,s6
     71e:	85a6                	mv	a1,s1
     720:	8552                	mv	a0,s4
     722:	9cbff0ef          	jal	ec <run_fifo>
  run_lru(refs, nrefs, target_frames, 1, &lru_faults, &lru_hits);
     726:	e8040793          	addi	a5,s0,-384
     72a:	e8440713          	addi	a4,s0,-380
     72e:	4685                	li	a3,1
     730:	865a                	mv	a2,s6
     732:	85a6                	mv	a1,s1
     734:	8552                	mv	a0,s4
     736:	bb5ff0ef          	jal	2ea <run_lru>
  if (target_frames == 3 && refs == default_ref_string) {
     73a:	00001797          	auipc	a5,0x1
     73e:	f1e78793          	addi	a5,a5,-226 # 1658 <default_ref_string>
     742:	00fa1563          	bne	s4,a5,74c <main+0x26a>
     746:	1b75                	addi	s6,s6,-3
     748:	ec0b09e3          	beqz	s6,61a <main+0x138>
           lru_faults, (lru_faults == 12) ? "VERIFIED" : "FAILED");
  }

  printf("============================================================\n");
     74c:	00001517          	auipc	a0,0x1
     750:	ba450513          	addi	a0,a0,-1116 # 12f0 <malloc+0x2c6>
     754:	01f000ef          	jal	f72 <printf>
  printf("TASK C: Performance Comparison Across 3, 4, and 5 Frames\n");
     758:	00001517          	auipc	a0,0x1
     75c:	d5050513          	addi	a0,a0,-688 # 14a8 <malloc+0x47e>
     760:	013000ef          	jal	f72 <printf>
  printf("============================================================\n\n");
     764:	00001517          	auipc	a0,0x1
     768:	c0c50513          	addi	a0,a0,-1012 # 1370 <malloc+0x346>
     76c:	007000ef          	jal	f72 <printf>

  printf("+-----------+--------+-------------+-----------+-----------+\n");
     770:	00001517          	auipc	a0,0x1
     774:	d7850513          	addi	a0,a0,-648 # 14e8 <malloc+0x4be>
     778:	7fa000ef          	jal	f72 <printf>
  printf("| Algorithm | Frames | Page Faults | Page Hits | Hit Ratio |\n");
     77c:	00001517          	auipc	a0,0x1
     780:	dac50513          	addi	a0,a0,-596 # 1528 <malloc+0x4fe>
     784:	7ee000ef          	jal	f72 <printf>
  printf("+-----------+--------+-------------+-----------+-----------+\n");
     788:	00001517          	auipc	a0,0x1
     78c:	d6050513          	addi	a0,a0,-672 # 14e8 <malloc+0x4be>
     790:	7e2000ef          	jal	f72 <printf>

  int frame_tests[] = {3, 4, 5};
     794:	478d                	li	a5,3
     796:	e6f42823          	sw	a5,-400(s0)
     79a:	4791                	li	a5,4
     79c:	e6f42a23          	sw	a5,-396(s0)
     7a0:	4795                	li	a5,5
     7a2:	e6f42c23          	sw	a5,-392(s0)
  for (int idx = 0; idx < 3; idx++) {
     7a6:	e7040993          	addi	s3,s0,-400
     7aa:	e7c40d93          	addi	s11,s0,-388
    int f = frame_tests[idx];
    int f_faults, f_hits;

    run_fifo(refs, nrefs, f, 0, &f_faults, &f_hits);
     7ae:	e6c40c13          	addi	s8,s0,-404
     7b2:	e6840b93          	addi	s7,s0,-408
    printf("| FIFO      |   %d    |     %d      |    %d     |   ", f, f_faults, f_hits);
     7b6:	00001d17          	auipc	s10,0x1
     7ba:	db2d0d13          	addi	s10,s10,-590 # 1568 <malloc+0x53e>
    print_percentage(f_hits, nrefs);
    printf("   |\n");
     7be:	00001b17          	auipc	s6,0x1
     7c2:	de2b0b13          	addi	s6,s6,-542 # 15a0 <malloc+0x576>

    run_lru(refs, nrefs, f, 0, &f_faults, &f_hits);
    printf("| LRU       |   %d    |     %d      |    %d     |   ", f, f_faults, f_hits);
     7c6:	00001c97          	auipc	s9,0x1
     7ca:	de2c8c93          	addi	s9,s9,-542 # 15a8 <malloc+0x57e>
    int f = frame_tests[idx];
     7ce:	0009a903          	lw	s2,0(s3)
    run_fifo(refs, nrefs, f, 0, &f_faults, &f_hits);
     7d2:	87e2                	mv	a5,s8
     7d4:	875e                	mv	a4,s7
     7d6:	4681                	li	a3,0
     7d8:	864a                	mv	a2,s2
     7da:	85a6                	mv	a1,s1
     7dc:	8552                	mv	a0,s4
     7de:	90fff0ef          	jal	ec <run_fifo>
    printf("| FIFO      |   %d    |     %d      |    %d     |   ", f, f_faults, f_hits);
     7e2:	e6c42a83          	lw	s5,-404(s0)
     7e6:	86d6                	mv	a3,s5
     7e8:	e6842603          	lw	a2,-408(s0)
     7ec:	85ca                	mv	a1,s2
     7ee:	856a                	mv	a0,s10
     7f0:	782000ef          	jal	f72 <printf>
    print_percentage(f_hits, nrefs);
     7f4:	85a6                	mv	a1,s1
     7f6:	8556                	mv	a0,s5
     7f8:	88fff0ef          	jal	86 <print_percentage>
    printf("   |\n");
     7fc:	855a                	mv	a0,s6
     7fe:	774000ef          	jal	f72 <printf>
    run_lru(refs, nrefs, f, 0, &f_faults, &f_hits);
     802:	87e2                	mv	a5,s8
     804:	875e                	mv	a4,s7
     806:	4681                	li	a3,0
     808:	864a                	mv	a2,s2
     80a:	85a6                	mv	a1,s1
     80c:	8552                	mv	a0,s4
     80e:	addff0ef          	jal	2ea <run_lru>
    printf("| LRU       |   %d    |     %d      |    %d     |   ", f, f_faults, f_hits);
     812:	e6c42a83          	lw	s5,-404(s0)
     816:	86d6                	mv	a3,s5
     818:	e6842603          	lw	a2,-408(s0)
     81c:	85ca                	mv	a1,s2
     81e:	8566                	mv	a0,s9
     820:	752000ef          	jal	f72 <printf>
    print_percentage(f_hits, nrefs);
     824:	85a6                	mv	a1,s1
     826:	8556                	mv	a0,s5
     828:	85fff0ef          	jal	86 <print_percentage>
    printf("   |\n");
     82c:	855a                	mv	a0,s6
     82e:	744000ef          	jal	f72 <printf>

    printf("+-----------+--------+-------------+-----------+-----------+\n");
     832:	00001517          	auipc	a0,0x1
     836:	cb650513          	addi	a0,a0,-842 # 14e8 <malloc+0x4be>
     83a:	738000ef          	jal	f72 <printf>
  for (int idx = 0; idx < 3; idx++) {
     83e:	0991                	addi	s3,s3,4
     840:	f93d97e3          	bne	s11,s3,7ce <main+0x2ec>
  }

  printf("\n============================================================\n");
     844:	00001517          	auipc	a0,0x1
     848:	d9c50513          	addi	a0,a0,-612 # 15e0 <malloc+0x5b6>
     84c:	726000ef          	jal	f72 <printf>
  printf("pagerepl: Simulation finished successfully!\n");
     850:	00001517          	auipc	a0,0x1
     854:	dd050513          	addi	a0,a0,-560 # 1620 <malloc+0x5f6>
     858:	71a000ef          	jal	f72 <printf>
  printf("============================================================\n");
     85c:	00001517          	auipc	a0,0x1
     860:	a9450513          	addi	a0,a0,-1388 # 12f0 <malloc+0x2c6>
     864:	70e000ef          	jal	f72 <printf>

  exit(0);
     868:	4501                	li	a0,0
     86a:	2ba000ef          	jal	b24 <exit>

000000000000086e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
     86e:	1141                	addi	sp,sp,-16
     870:	e406                	sd	ra,8(sp)
     872:	e022                	sd	s0,0(sp)
     874:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
     876:	c6dff0ef          	jal	4e2 <main>
  exit(r);
     87a:	2aa000ef          	jal	b24 <exit>

000000000000087e <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
     87e:	1141                	addi	sp,sp,-16
     880:	e406                	sd	ra,8(sp)
     882:	e022                	sd	s0,0(sp)
     884:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
     886:	87aa                	mv	a5,a0
     888:	0585                	addi	a1,a1,1
     88a:	0785                	addi	a5,a5,1
     88c:	fff5c703          	lbu	a4,-1(a1)
     890:	fee78fa3          	sb	a4,-1(a5)
     894:	fb75                	bnez	a4,888 <strcpy+0xa>
    ;
  return os;
}
     896:	60a2                	ld	ra,8(sp)
     898:	6402                	ld	s0,0(sp)
     89a:	0141                	addi	sp,sp,16
     89c:	8082                	ret

000000000000089e <strcmp>:

int
strcmp(const char *p, const char *q)
{
     89e:	1141                	addi	sp,sp,-16
     8a0:	e406                	sd	ra,8(sp)
     8a2:	e022                	sd	s0,0(sp)
     8a4:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
     8a6:	00054783          	lbu	a5,0(a0)
     8aa:	cb91                	beqz	a5,8be <strcmp+0x20>
     8ac:	0005c703          	lbu	a4,0(a1)
     8b0:	00f71763          	bne	a4,a5,8be <strcmp+0x20>
    p++, q++;
     8b4:	0505                	addi	a0,a0,1
     8b6:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
     8b8:	00054783          	lbu	a5,0(a0)
     8bc:	fbe5                	bnez	a5,8ac <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
     8be:	0005c503          	lbu	a0,0(a1)
}
     8c2:	40a7853b          	subw	a0,a5,a0
     8c6:	60a2                	ld	ra,8(sp)
     8c8:	6402                	ld	s0,0(sp)
     8ca:	0141                	addi	sp,sp,16
     8cc:	8082                	ret

00000000000008ce <strlen>:

uint
strlen(const char *s)
{
     8ce:	1141                	addi	sp,sp,-16
     8d0:	e406                	sd	ra,8(sp)
     8d2:	e022                	sd	s0,0(sp)
     8d4:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
     8d6:	00054783          	lbu	a5,0(a0)
     8da:	cf91                	beqz	a5,8f6 <strlen+0x28>
     8dc:	00150793          	addi	a5,a0,1
     8e0:	86be                	mv	a3,a5
     8e2:	0785                	addi	a5,a5,1
     8e4:	fff7c703          	lbu	a4,-1(a5)
     8e8:	ff65                	bnez	a4,8e0 <strlen+0x12>
     8ea:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
     8ee:	60a2                	ld	ra,8(sp)
     8f0:	6402                	ld	s0,0(sp)
     8f2:	0141                	addi	sp,sp,16
     8f4:	8082                	ret
  for (n = 0; s[n]; n++)
     8f6:	4501                	li	a0,0
     8f8:	bfdd                	j	8ee <strlen+0x20>

00000000000008fa <memset>:

void *
memset(void *dst, int c, uint n)
{
     8fa:	1141                	addi	sp,sp,-16
     8fc:	e406                	sd	ra,8(sp)
     8fe:	e022                	sd	s0,0(sp)
     900:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
     902:	ca19                	beqz	a2,918 <memset+0x1e>
     904:	87aa                	mv	a5,a0
     906:	1602                	slli	a2,a2,0x20
     908:	9201                	srli	a2,a2,0x20
     90a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     90e:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
     912:	0785                	addi	a5,a5,1
     914:	fee79de3          	bne	a5,a4,90e <memset+0x14>
  }
  return dst;
}
     918:	60a2                	ld	ra,8(sp)
     91a:	6402                	ld	s0,0(sp)
     91c:	0141                	addi	sp,sp,16
     91e:	8082                	ret

0000000000000920 <strchr>:

char *
strchr(const char *s, char c)
{
     920:	1141                	addi	sp,sp,-16
     922:	e406                	sd	ra,8(sp)
     924:	e022                	sd	s0,0(sp)
     926:	0800                	addi	s0,sp,16
  for (; *s; s++)
     928:	00054783          	lbu	a5,0(a0)
     92c:	cf81                	beqz	a5,944 <strchr+0x24>
    if (*s == c)
     92e:	00f58763          	beq	a1,a5,93c <strchr+0x1c>
  for (; *s; s++)
     932:	0505                	addi	a0,a0,1
     934:	00054783          	lbu	a5,0(a0)
     938:	fbfd                	bnez	a5,92e <strchr+0xe>
      return (char *)s;
  return 0;
     93a:	4501                	li	a0,0
}
     93c:	60a2                	ld	ra,8(sp)
     93e:	6402                	ld	s0,0(sp)
     940:	0141                	addi	sp,sp,16
     942:	8082                	ret
  return 0;
     944:	4501                	li	a0,0
     946:	bfdd                	j	93c <strchr+0x1c>

0000000000000948 <gets>:

char *
gets(char *buf, int max)
{
     948:	711d                	addi	sp,sp,-96
     94a:	ec86                	sd	ra,88(sp)
     94c:	e8a2                	sd	s0,80(sp)
     94e:	e4a6                	sd	s1,72(sp)
     950:	e0ca                	sd	s2,64(sp)
     952:	fc4e                	sd	s3,56(sp)
     954:	f852                	sd	s4,48(sp)
     956:	f456                	sd	s5,40(sp)
     958:	f05a                	sd	s6,32(sp)
     95a:	ec5e                	sd	s7,24(sp)
     95c:	e862                	sd	s8,16(sp)
     95e:	1080                	addi	s0,sp,96
     960:	8baa                	mv	s7,a0
     962:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
     964:	892a                	mv	s2,a0
     966:	4481                	li	s1,0
    cc = read(0, &c, 1);
     968:	faf40b13          	addi	s6,s0,-81
     96c:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
     96e:	8c26                	mv	s8,s1
     970:	0014899b          	addiw	s3,s1,1
     974:	84ce                	mv	s1,s3
     976:	0349d463          	bge	s3,s4,99e <gets+0x56>
    cc = read(0, &c, 1);
     97a:	8656                	mv	a2,s5
     97c:	85da                	mv	a1,s6
     97e:	4501                	li	a0,0
     980:	1bc000ef          	jal	b3c <read>
    if (cc < 1)
     984:	00a05d63          	blez	a0,99e <gets+0x56>
      break;
    buf[i++] = c;
     988:	faf44783          	lbu	a5,-81(s0)
     98c:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
     990:	0905                	addi	s2,s2,1
     992:	ff678713          	addi	a4,a5,-10
     996:	c319                	beqz	a4,99c <gets+0x54>
     998:	17cd                	addi	a5,a5,-13
     99a:	fbf1                	bnez	a5,96e <gets+0x26>
    buf[i++] = c;
     99c:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
     99e:	9c5e                	add	s8,s8,s7
     9a0:	000c0023          	sb	zero,0(s8)
  return buf;
}
     9a4:	855e                	mv	a0,s7
     9a6:	60e6                	ld	ra,88(sp)
     9a8:	6446                	ld	s0,80(sp)
     9aa:	64a6                	ld	s1,72(sp)
     9ac:	6906                	ld	s2,64(sp)
     9ae:	79e2                	ld	s3,56(sp)
     9b0:	7a42                	ld	s4,48(sp)
     9b2:	7aa2                	ld	s5,40(sp)
     9b4:	7b02                	ld	s6,32(sp)
     9b6:	6be2                	ld	s7,24(sp)
     9b8:	6c42                	ld	s8,16(sp)
     9ba:	6125                	addi	sp,sp,96
     9bc:	8082                	ret

00000000000009be <stat>:

int
stat(const char *n, struct stat *st)
{
     9be:	1101                	addi	sp,sp,-32
     9c0:	ec06                	sd	ra,24(sp)
     9c2:	e822                	sd	s0,16(sp)
     9c4:	e04a                	sd	s2,0(sp)
     9c6:	1000                	addi	s0,sp,32
     9c8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     9ca:	4581                	li	a1,0
     9cc:	198000ef          	jal	b64 <open>
  if (fd < 0)
     9d0:	02054263          	bltz	a0,9f4 <stat+0x36>
     9d4:	e426                	sd	s1,8(sp)
     9d6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     9d8:	85ca                	mv	a1,s2
     9da:	1a2000ef          	jal	b7c <fstat>
     9de:	892a                	mv	s2,a0
  close(fd);
     9e0:	8526                	mv	a0,s1
     9e2:	16a000ef          	jal	b4c <close>
  return r;
     9e6:	64a2                	ld	s1,8(sp)
}
     9e8:	854a                	mv	a0,s2
     9ea:	60e2                	ld	ra,24(sp)
     9ec:	6442                	ld	s0,16(sp)
     9ee:	6902                	ld	s2,0(sp)
     9f0:	6105                	addi	sp,sp,32
     9f2:	8082                	ret
    return -1;
     9f4:	57fd                	li	a5,-1
     9f6:	893e                	mv	s2,a5
     9f8:	bfc5                	j	9e8 <stat+0x2a>

00000000000009fa <atoi>:

int
atoi(const char *s)
{
     9fa:	1141                	addi	sp,sp,-16
     9fc:	e406                	sd	ra,8(sp)
     9fe:	e022                	sd	s0,0(sp)
     a00:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
     a02:	00054683          	lbu	a3,0(a0)
     a06:	fd06879b          	addiw	a5,a3,-48
     a0a:	0ff7f793          	zext.b	a5,a5
     a0e:	4625                	li	a2,9
     a10:	02f66963          	bltu	a2,a5,a42 <atoi+0x48>
     a14:	872a                	mv	a4,a0
  n = 0;
     a16:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
     a18:	0705                	addi	a4,a4,1
     a1a:	0025179b          	slliw	a5,a0,0x2
     a1e:	9fa9                	addw	a5,a5,a0
     a20:	0017979b          	slliw	a5,a5,0x1
     a24:	9fb5                	addw	a5,a5,a3
     a26:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
     a2a:	00074683          	lbu	a3,0(a4)
     a2e:	fd06879b          	addiw	a5,a3,-48
     a32:	0ff7f793          	zext.b	a5,a5
     a36:	fef671e3          	bgeu	a2,a5,a18 <atoi+0x1e>
  return n;
}
     a3a:	60a2                	ld	ra,8(sp)
     a3c:	6402                	ld	s0,0(sp)
     a3e:	0141                	addi	sp,sp,16
     a40:	8082                	ret
  n = 0;
     a42:	4501                	li	a0,0
     a44:	bfdd                	j	a3a <atoi+0x40>

0000000000000a46 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
     a46:	1141                	addi	sp,sp,-16
     a48:	e406                	sd	ra,8(sp)
     a4a:	e022                	sd	s0,0(sp)
     a4c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     a4e:	02b57563          	bgeu	a0,a1,a78 <memmove+0x32>
    while (n-- > 0)
     a52:	00c05f63          	blez	a2,a70 <memmove+0x2a>
     a56:	1602                	slli	a2,a2,0x20
     a58:	9201                	srli	a2,a2,0x20
     a5a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     a5e:	872a                	mv	a4,a0
      *dst++ = *src++;
     a60:	0585                	addi	a1,a1,1
     a62:	0705                	addi	a4,a4,1
     a64:	fff5c683          	lbu	a3,-1(a1)
     a68:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
     a6c:	fee79ae3          	bne	a5,a4,a60 <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     a70:	60a2                	ld	ra,8(sp)
     a72:	6402                	ld	s0,0(sp)
     a74:	0141                	addi	sp,sp,16
     a76:	8082                	ret
    while (n-- > 0)
     a78:	fec05ce3          	blez	a2,a70 <memmove+0x2a>
    dst += n;
     a7c:	00c50733          	add	a4,a0,a2
    src += n;
     a80:	95b2                	add	a1,a1,a2
     a82:	fff6079b          	addiw	a5,a2,-1
     a86:	1782                	slli	a5,a5,0x20
     a88:	9381                	srli	a5,a5,0x20
     a8a:	fff7c793          	not	a5,a5
     a8e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     a90:	15fd                	addi	a1,a1,-1
     a92:	177d                	addi	a4,a4,-1
     a94:	0005c683          	lbu	a3,0(a1)
     a98:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
     a9c:	fef71ae3          	bne	a4,a5,a90 <memmove+0x4a>
     aa0:	bfc1                	j	a70 <memmove+0x2a>

0000000000000aa2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     aa2:	1141                	addi	sp,sp,-16
     aa4:	e406                	sd	ra,8(sp)
     aa6:	e022                	sd	s0,0(sp)
     aa8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     aaa:	c61d                	beqz	a2,ad8 <memcmp+0x36>
     aac:	1602                	slli	a2,a2,0x20
     aae:	9201                	srli	a2,a2,0x20
     ab0:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
     ab4:	00054783          	lbu	a5,0(a0)
     ab8:	0005c703          	lbu	a4,0(a1)
     abc:	00e79863          	bne	a5,a4,acc <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
     ac0:	0505                	addi	a0,a0,1
    p2++;
     ac2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     ac4:	fed518e3          	bne	a0,a3,ab4 <memcmp+0x12>
  }
  return 0;
     ac8:	4501                	li	a0,0
     aca:	a019                	j	ad0 <memcmp+0x2e>
      return *p1 - *p2;
     acc:	40e7853b          	subw	a0,a5,a4
}
     ad0:	60a2                	ld	ra,8(sp)
     ad2:	6402                	ld	s0,0(sp)
     ad4:	0141                	addi	sp,sp,16
     ad6:	8082                	ret
  return 0;
     ad8:	4501                	li	a0,0
     ada:	bfdd                	j	ad0 <memcmp+0x2e>

0000000000000adc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     adc:	1141                	addi	sp,sp,-16
     ade:	e406                	sd	ra,8(sp)
     ae0:	e022                	sd	s0,0(sp)
     ae2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     ae4:	f63ff0ef          	jal	a46 <memmove>
}
     ae8:	60a2                	ld	ra,8(sp)
     aea:	6402                	ld	s0,0(sp)
     aec:	0141                	addi	sp,sp,16
     aee:	8082                	ret

0000000000000af0 <sbrk>:

char *
sbrk(int n)
{
     af0:	1141                	addi	sp,sp,-16
     af2:	e406                	sd	ra,8(sp)
     af4:	e022                	sd	s0,0(sp)
     af6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
     af8:	4585                	li	a1,1
     afa:	0b2000ef          	jal	bac <sys_sbrk>
}
     afe:	60a2                	ld	ra,8(sp)
     b00:	6402                	ld	s0,0(sp)
     b02:	0141                	addi	sp,sp,16
     b04:	8082                	ret

0000000000000b06 <sbrklazy>:

char *
sbrklazy(int n)
{
     b06:	1141                	addi	sp,sp,-16
     b08:	e406                	sd	ra,8(sp)
     b0a:	e022                	sd	s0,0(sp)
     b0c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
     b0e:	4589                	li	a1,2
     b10:	09c000ef          	jal	bac <sys_sbrk>
}
     b14:	60a2                	ld	ra,8(sp)
     b16:	6402                	ld	s0,0(sp)
     b18:	0141                	addi	sp,sp,16
     b1a:	8082                	ret

0000000000000b1c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     b1c:	4885                	li	a7,1
 ecall
     b1e:	00000073          	ecall
 ret
     b22:	8082                	ret

0000000000000b24 <exit>:
.global exit
exit:
 li a7, SYS_exit
     b24:	4889                	li	a7,2
 ecall
     b26:	00000073          	ecall
 ret
     b2a:	8082                	ret

0000000000000b2c <wait>:
.global wait
wait:
 li a7, SYS_wait
     b2c:	488d                	li	a7,3
 ecall
     b2e:	00000073          	ecall
 ret
     b32:	8082                	ret

0000000000000b34 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     b34:	4891                	li	a7,4
 ecall
     b36:	00000073          	ecall
 ret
     b3a:	8082                	ret

0000000000000b3c <read>:
.global read
read:
 li a7, SYS_read
     b3c:	4895                	li	a7,5
 ecall
     b3e:	00000073          	ecall
 ret
     b42:	8082                	ret

0000000000000b44 <write>:
.global write
write:
 li a7, SYS_write
     b44:	48c1                	li	a7,16
 ecall
     b46:	00000073          	ecall
 ret
     b4a:	8082                	ret

0000000000000b4c <close>:
.global close
close:
 li a7, SYS_close
     b4c:	48d5                	li	a7,21
 ecall
     b4e:	00000073          	ecall
 ret
     b52:	8082                	ret

0000000000000b54 <kill>:
.global kill
kill:
 li a7, SYS_kill
     b54:	4899                	li	a7,6
 ecall
     b56:	00000073          	ecall
 ret
     b5a:	8082                	ret

0000000000000b5c <exec>:
.global exec
exec:
 li a7, SYS_exec
     b5c:	489d                	li	a7,7
 ecall
     b5e:	00000073          	ecall
 ret
     b62:	8082                	ret

0000000000000b64 <open>:
.global open
open:
 li a7, SYS_open
     b64:	48bd                	li	a7,15
 ecall
     b66:	00000073          	ecall
 ret
     b6a:	8082                	ret

0000000000000b6c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     b6c:	48c5                	li	a7,17
 ecall
     b6e:	00000073          	ecall
 ret
     b72:	8082                	ret

0000000000000b74 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     b74:	48c9                	li	a7,18
 ecall
     b76:	00000073          	ecall
 ret
     b7a:	8082                	ret

0000000000000b7c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     b7c:	48a1                	li	a7,8
 ecall
     b7e:	00000073          	ecall
 ret
     b82:	8082                	ret

0000000000000b84 <link>:
.global link
link:
 li a7, SYS_link
     b84:	48cd                	li	a7,19
 ecall
     b86:	00000073          	ecall
 ret
     b8a:	8082                	ret

0000000000000b8c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     b8c:	48d1                	li	a7,20
 ecall
     b8e:	00000073          	ecall
 ret
     b92:	8082                	ret

0000000000000b94 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     b94:	48a5                	li	a7,9
 ecall
     b96:	00000073          	ecall
 ret
     b9a:	8082                	ret

0000000000000b9c <dup>:
.global dup
dup:
 li a7, SYS_dup
     b9c:	48a9                	li	a7,10
 ecall
     b9e:	00000073          	ecall
 ret
     ba2:	8082                	ret

0000000000000ba4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     ba4:	48ad                	li	a7,11
 ecall
     ba6:	00000073          	ecall
 ret
     baa:	8082                	ret

0000000000000bac <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
     bac:	48b1                	li	a7,12
 ecall
     bae:	00000073          	ecall
 ret
     bb2:	8082                	ret

0000000000000bb4 <pause>:
.global pause
pause:
 li a7, SYS_pause
     bb4:	48b5                	li	a7,13
 ecall
     bb6:	00000073          	ecall
 ret
     bba:	8082                	ret

0000000000000bbc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     bbc:	48b9                	li	a7,14
 ecall
     bbe:	00000073          	ecall
 ret
     bc2:	8082                	ret

0000000000000bc4 <sync>:
.global sync
sync:
 li a7, SYS_sync
     bc4:	48d9                	li	a7,22
 ecall
     bc6:	00000073          	ecall
 ret
     bca:	8082                	ret

0000000000000bcc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     bcc:	1101                	addi	sp,sp,-32
     bce:	ec06                	sd	ra,24(sp)
     bd0:	e822                	sd	s0,16(sp)
     bd2:	1000                	addi	s0,sp,32
     bd4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     bd8:	4605                	li	a2,1
     bda:	fef40593          	addi	a1,s0,-17
     bde:	f67ff0ef          	jal	b44 <write>
}
     be2:	60e2                	ld	ra,24(sp)
     be4:	6442                	ld	s0,16(sp)
     be6:	6105                	addi	sp,sp,32
     be8:	8082                	ret

0000000000000bea <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
     bea:	715d                	addi	sp,sp,-80
     bec:	e486                	sd	ra,72(sp)
     bee:	e0a2                	sd	s0,64(sp)
     bf0:	f84a                	sd	s2,48(sp)
     bf2:	f44e                	sd	s3,40(sp)
     bf4:	0880                	addi	s0,sp,80
     bf6:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
     bf8:	c6d1                	beqz	a3,c84 <printint+0x9a>
     bfa:	0805d563          	bgez	a1,c84 <printint+0x9a>
    neg = 1;
    x = -xx;
     bfe:	40b005b3          	neg	a1,a1
    neg = 1;
     c02:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
     c04:	fb840993          	addi	s3,s0,-72
  neg = 0;
     c08:	86ce                	mv	a3,s3
  i = 0;
     c0a:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
     c0c:	00001817          	auipc	a6,0x1
     c10:	a9c80813          	addi	a6,a6,-1380 # 16a8 <digits>
     c14:	88ba                	mv	a7,a4
     c16:	0017051b          	addiw	a0,a4,1
     c1a:	872a                	mv	a4,a0
     c1c:	02c5f7b3          	remu	a5,a1,a2
     c20:	97c2                	add	a5,a5,a6
     c22:	0007c783          	lbu	a5,0(a5)
     c26:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
     c2a:	87ae                	mv	a5,a1
     c2c:	02c5d5b3          	divu	a1,a1,a2
     c30:	0685                	addi	a3,a3,1
     c32:	fec7f1e3          	bgeu	a5,a2,c14 <printint+0x2a>
  if (neg)
     c36:	00030c63          	beqz	t1,c4e <printint+0x64>
    buf[i++] = '-';
     c3a:	fd050793          	addi	a5,a0,-48
     c3e:	00878533          	add	a0,a5,s0
     c42:	02d00793          	li	a5,45
     c46:	fef50423          	sb	a5,-24(a0)
     c4a:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
     c4e:	02e05563          	blez	a4,c78 <printint+0x8e>
     c52:	fc26                	sd	s1,56(sp)
     c54:	377d                	addiw	a4,a4,-1
     c56:	00e984b3          	add	s1,s3,a4
     c5a:	19fd                	addi	s3,s3,-1
     c5c:	99ba                	add	s3,s3,a4
     c5e:	1702                	slli	a4,a4,0x20
     c60:	9301                	srli	a4,a4,0x20
     c62:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     c66:	0004c583          	lbu	a1,0(s1)
     c6a:	854a                	mv	a0,s2
     c6c:	f61ff0ef          	jal	bcc <putc>
  while (--i >= 0)
     c70:	14fd                	addi	s1,s1,-1
     c72:	ff349ae3          	bne	s1,s3,c66 <printint+0x7c>
     c76:	74e2                	ld	s1,56(sp)
}
     c78:	60a6                	ld	ra,72(sp)
     c7a:	6406                	ld	s0,64(sp)
     c7c:	7942                	ld	s2,48(sp)
     c7e:	79a2                	ld	s3,40(sp)
     c80:	6161                	addi	sp,sp,80
     c82:	8082                	ret
  neg = 0;
     c84:	4301                	li	t1,0
     c86:	bfbd                	j	c04 <printint+0x1a>

0000000000000c88 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     c88:	711d                	addi	sp,sp,-96
     c8a:	ec86                	sd	ra,88(sp)
     c8c:	e8a2                	sd	s0,80(sp)
     c8e:	e4a6                	sd	s1,72(sp)
     c90:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
     c92:	0005c483          	lbu	s1,0(a1)
     c96:	22048363          	beqz	s1,ebc <vprintf+0x234>
     c9a:	e0ca                	sd	s2,64(sp)
     c9c:	fc4e                	sd	s3,56(sp)
     c9e:	f852                	sd	s4,48(sp)
     ca0:	f456                	sd	s5,40(sp)
     ca2:	f05a                	sd	s6,32(sp)
     ca4:	ec5e                	sd	s7,24(sp)
     ca6:	e862                	sd	s8,16(sp)
     ca8:	8b2a                	mv	s6,a0
     caa:	8a2e                	mv	s4,a1
     cac:	8bb2                	mv	s7,a2
  state = 0;
     cae:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
     cb0:	4901                	li	s2,0
     cb2:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
     cb4:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
     cb8:	06400c13          	li	s8,100
     cbc:	a00d                	j	cde <vprintf+0x56>
        putc(fd, c0);
     cbe:	85a6                	mv	a1,s1
     cc0:	855a                	mv	a0,s6
     cc2:	f0bff0ef          	jal	bcc <putc>
     cc6:	a019                	j	ccc <vprintf+0x44>
    } else if (state == '%') {
     cc8:	03598363          	beq	s3,s5,cee <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
     ccc:	0019079b          	addiw	a5,s2,1
     cd0:	893e                	mv	s2,a5
     cd2:	873e                	mv	a4,a5
     cd4:	97d2                	add	a5,a5,s4
     cd6:	0007c483          	lbu	s1,0(a5)
     cda:	1c048a63          	beqz	s1,eae <vprintf+0x226>
    c0 = fmt[i] & 0xff;
     cde:	0004879b          	sext.w	a5,s1
    if (state == 0) {
     ce2:	fe0993e3          	bnez	s3,cc8 <vprintf+0x40>
      if (c0 == '%') {
     ce6:	fd579ce3          	bne	a5,s5,cbe <vprintf+0x36>
        state = '%';
     cea:	89be                	mv	s3,a5
     cec:	b7c5                	j	ccc <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
     cee:	00ea06b3          	add	a3,s4,a4
     cf2:	0016c603          	lbu	a2,1(a3)
      if (c1)
     cf6:	1c060863          	beqz	a2,ec6 <vprintf+0x23e>
      if (c0 == 'd') {
     cfa:	03878763          	beq	a5,s8,d28 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
     cfe:	f9478693          	addi	a3,a5,-108
     d02:	0016b693          	seqz	a3,a3
     d06:	f9c60593          	addi	a1,a2,-100
     d0a:	e99d                	bnez	a1,d40 <vprintf+0xb8>
     d0c:	ca95                	beqz	a3,d40 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
     d0e:	008b8493          	addi	s1,s7,8
     d12:	4685                	li	a3,1
     d14:	4629                	li	a2,10
     d16:	000bb583          	ld	a1,0(s7)
     d1a:	855a                	mv	a0,s6
     d1c:	ecfff0ef          	jal	bea <printint>
        i += 1;
     d20:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
     d22:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
     d24:	4981                	li	s3,0
     d26:	b75d                	j	ccc <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
     d28:	008b8493          	addi	s1,s7,8
     d2c:	4685                	li	a3,1
     d2e:	4629                	li	a2,10
     d30:	000ba583          	lw	a1,0(s7)
     d34:	855a                	mv	a0,s6
     d36:	eb5ff0ef          	jal	bea <printint>
     d3a:	8ba6                	mv	s7,s1
      state = 0;
     d3c:	4981                	li	s3,0
     d3e:	b779                	j	ccc <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
     d40:	9752                	add	a4,a4,s4
     d42:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
     d46:	f9460713          	addi	a4,a2,-108
     d4a:	00173713          	seqz	a4,a4
     d4e:	8f75                	and	a4,a4,a3
     d50:	f9c58513          	addi	a0,a1,-100
     d54:	18051363          	bnez	a0,eda <vprintf+0x252>
     d58:	18070163          	beqz	a4,eda <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
     d5c:	008b8493          	addi	s1,s7,8
     d60:	4685                	li	a3,1
     d62:	4629                	li	a2,10
     d64:	000bb583          	ld	a1,0(s7)
     d68:	855a                	mv	a0,s6
     d6a:	e81ff0ef          	jal	bea <printint>
        i += 2;
     d6e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
     d70:	8ba6                	mv	s7,s1
      state = 0;
     d72:	4981                	li	s3,0
        i += 2;
     d74:	bfa1                	j	ccc <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
     d76:	008b8493          	addi	s1,s7,8
     d7a:	4681                	li	a3,0
     d7c:	4629                	li	a2,10
     d7e:	000be583          	lwu	a1,0(s7)
     d82:	855a                	mv	a0,s6
     d84:	e67ff0ef          	jal	bea <printint>
     d88:	8ba6                	mv	s7,s1
      state = 0;
     d8a:	4981                	li	s3,0
     d8c:	b781                	j	ccc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
     d8e:	008b8493          	addi	s1,s7,8
     d92:	4681                	li	a3,0
     d94:	4629                	li	a2,10
     d96:	000bb583          	ld	a1,0(s7)
     d9a:	855a                	mv	a0,s6
     d9c:	e4fff0ef          	jal	bea <printint>
        i += 1;
     da0:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
     da2:	8ba6                	mv	s7,s1
      state = 0;
     da4:	4981                	li	s3,0
     da6:	b71d                	j	ccc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
     da8:	008b8493          	addi	s1,s7,8
     dac:	4681                	li	a3,0
     dae:	4629                	li	a2,10
     db0:	000bb583          	ld	a1,0(s7)
     db4:	855a                	mv	a0,s6
     db6:	e35ff0ef          	jal	bea <printint>
        i += 2;
     dba:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
     dbc:	8ba6                	mv	s7,s1
      state = 0;
     dbe:	4981                	li	s3,0
        i += 2;
     dc0:	b731                	j	ccc <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
     dc2:	008b8493          	addi	s1,s7,8
     dc6:	4681                	li	a3,0
     dc8:	4641                	li	a2,16
     dca:	000be583          	lwu	a1,0(s7)
     dce:	855a                	mv	a0,s6
     dd0:	e1bff0ef          	jal	bea <printint>
     dd4:	8ba6                	mv	s7,s1
      state = 0;
     dd6:	4981                	li	s3,0
     dd8:	bdd5                	j	ccc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
     dda:	008b8493          	addi	s1,s7,8
     dde:	4681                	li	a3,0
     de0:	4641                	li	a2,16
     de2:	000bb583          	ld	a1,0(s7)
     de6:	855a                	mv	a0,s6
     de8:	e03ff0ef          	jal	bea <printint>
        i += 1;
     dec:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
     dee:	8ba6                	mv	s7,s1
      state = 0;
     df0:	4981                	li	s3,0
     df2:	bde9                	j	ccc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
     df4:	008b8493          	addi	s1,s7,8
     df8:	4681                	li	a3,0
     dfa:	4641                	li	a2,16
     dfc:	000bb583          	ld	a1,0(s7)
     e00:	855a                	mv	a0,s6
     e02:	de9ff0ef          	jal	bea <printint>
        i += 2;
     e06:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
     e08:	8ba6                	mv	s7,s1
      state = 0;
     e0a:	4981                	li	s3,0
        i += 2;
     e0c:	b5c1                	j	ccc <vprintf+0x44>
     e0e:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
     e10:	008b8793          	addi	a5,s7,8
     e14:	8cbe                	mv	s9,a5
     e16:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
     e1a:	03000593          	li	a1,48
     e1e:	855a                	mv	a0,s6
     e20:	dadff0ef          	jal	bcc <putc>
  putc(fd, 'x');
     e24:	07800593          	li	a1,120
     e28:	855a                	mv	a0,s6
     e2a:	da3ff0ef          	jal	bcc <putc>
     e2e:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     e30:	00001b97          	auipc	s7,0x1
     e34:	878b8b93          	addi	s7,s7,-1928 # 16a8 <digits>
     e38:	03c9d793          	srli	a5,s3,0x3c
     e3c:	97de                	add	a5,a5,s7
     e3e:	0007c583          	lbu	a1,0(a5)
     e42:	855a                	mv	a0,s6
     e44:	d89ff0ef          	jal	bcc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     e48:	0992                	slli	s3,s3,0x4
     e4a:	34fd                	addiw	s1,s1,-1
     e4c:	f4f5                	bnez	s1,e38 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
     e4e:	8be6                	mv	s7,s9
      state = 0;
     e50:	4981                	li	s3,0
     e52:	6ca2                	ld	s9,8(sp)
     e54:	bda5                	j	ccc <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
     e56:	008b8493          	addi	s1,s7,8
     e5a:	000bc583          	lbu	a1,0(s7)
     e5e:	855a                	mv	a0,s6
     e60:	d6dff0ef          	jal	bcc <putc>
     e64:	8ba6                	mv	s7,s1
      state = 0;
     e66:	4981                	li	s3,0
     e68:	b595                	j	ccc <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
     e6a:	008b8993          	addi	s3,s7,8
     e6e:	000bb483          	ld	s1,0(s7)
     e72:	cc91                	beqz	s1,e8e <vprintf+0x206>
        for (; *s; s++)
     e74:	0004c583          	lbu	a1,0(s1)
     e78:	c985                	beqz	a1,ea8 <vprintf+0x220>
          putc(fd, *s);
     e7a:	855a                	mv	a0,s6
     e7c:	d51ff0ef          	jal	bcc <putc>
        for (; *s; s++)
     e80:	0485                	addi	s1,s1,1
     e82:	0004c583          	lbu	a1,0(s1)
     e86:	f9f5                	bnez	a1,e7a <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
     e88:	8bce                	mv	s7,s3
      state = 0;
     e8a:	4981                	li	s3,0
     e8c:	b581                	j	ccc <vprintf+0x44>
          s = "(null)";
     e8e:	00000497          	auipc	s1,0x0
     e92:	7c248493          	addi	s1,s1,1986 # 1650 <malloc+0x626>
        for (; *s; s++)
     e96:	02800593          	li	a1,40
     e9a:	b7c5                	j	e7a <vprintf+0x1f2>
        putc(fd, '%');
     e9c:	85be                	mv	a1,a5
     e9e:	855a                	mv	a0,s6
     ea0:	d2dff0ef          	jal	bcc <putc>
      state = 0;
     ea4:	4981                	li	s3,0
     ea6:	b51d                	j	ccc <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
     ea8:	8bce                	mv	s7,s3
      state = 0;
     eaa:	4981                	li	s3,0
     eac:	b505                	j	ccc <vprintf+0x44>
     eae:	6906                	ld	s2,64(sp)
     eb0:	79e2                	ld	s3,56(sp)
     eb2:	7a42                	ld	s4,48(sp)
     eb4:	7aa2                	ld	s5,40(sp)
     eb6:	7b02                	ld	s6,32(sp)
     eb8:	6be2                	ld	s7,24(sp)
     eba:	6c42                	ld	s8,16(sp)
    }
  }
}
     ebc:	60e6                	ld	ra,88(sp)
     ebe:	6446                	ld	s0,80(sp)
     ec0:	64a6                	ld	s1,72(sp)
     ec2:	6125                	addi	sp,sp,96
     ec4:	8082                	ret
      if (c0 == 'd') {
     ec6:	06400713          	li	a4,100
     eca:	e4e78fe3          	beq	a5,a4,d28 <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
     ece:	f9478693          	addi	a3,a5,-108
     ed2:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
     ed6:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
     ed8:	4701                	li	a4,0
      } else if (c0 == 'u') {
     eda:	07500513          	li	a0,117
     ede:	e8a78ce3          	beq	a5,a0,d76 <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
     ee2:	f8b60513          	addi	a0,a2,-117
     ee6:	e119                	bnez	a0,eec <vprintf+0x264>
     ee8:	ea0693e3          	bnez	a3,d8e <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
     eec:	f8b58513          	addi	a0,a1,-117
     ef0:	e119                	bnez	a0,ef6 <vprintf+0x26e>
     ef2:	ea071be3          	bnez	a4,da8 <vprintf+0x120>
      } else if (c0 == 'x') {
     ef6:	07800513          	li	a0,120
     efa:	eca784e3          	beq	a5,a0,dc2 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
     efe:	f8860613          	addi	a2,a2,-120
     f02:	e219                	bnez	a2,f08 <vprintf+0x280>
     f04:	ec069be3          	bnez	a3,dda <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
     f08:	f8858593          	addi	a1,a1,-120
     f0c:	e199                	bnez	a1,f12 <vprintf+0x28a>
     f0e:	ee0713e3          	bnez	a4,df4 <vprintf+0x16c>
      } else if (c0 == 'p') {
     f12:	07000713          	li	a4,112
     f16:	eee78ce3          	beq	a5,a4,e0e <vprintf+0x186>
      } else if (c0 == 'c') {
     f1a:	06300713          	li	a4,99
     f1e:	f2e78ce3          	beq	a5,a4,e56 <vprintf+0x1ce>
      } else if (c0 == 's') {
     f22:	07300713          	li	a4,115
     f26:	f4e782e3          	beq	a5,a4,e6a <vprintf+0x1e2>
      } else if (c0 == '%') {
     f2a:	02500713          	li	a4,37
     f2e:	f6e787e3          	beq	a5,a4,e9c <vprintf+0x214>
        putc(fd, '%');
     f32:	02500593          	li	a1,37
     f36:	855a                	mv	a0,s6
     f38:	c95ff0ef          	jal	bcc <putc>
        putc(fd, c0);
     f3c:	85a6                	mv	a1,s1
     f3e:	855a                	mv	a0,s6
     f40:	c8dff0ef          	jal	bcc <putc>
      state = 0;
     f44:	4981                	li	s3,0
     f46:	b359                	j	ccc <vprintf+0x44>

0000000000000f48 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
     f48:	715d                	addi	sp,sp,-80
     f4a:	ec06                	sd	ra,24(sp)
     f4c:	e822                	sd	s0,16(sp)
     f4e:	1000                	addi	s0,sp,32
     f50:	e010                	sd	a2,0(s0)
     f52:	e414                	sd	a3,8(s0)
     f54:	e818                	sd	a4,16(s0)
     f56:	ec1c                	sd	a5,24(s0)
     f58:	03043023          	sd	a6,32(s0)
     f5c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
     f60:	8622                	mv	a2,s0
     f62:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
     f66:	d23ff0ef          	jal	c88 <vprintf>
}
     f6a:	60e2                	ld	ra,24(sp)
     f6c:	6442                	ld	s0,16(sp)
     f6e:	6161                	addi	sp,sp,80
     f70:	8082                	ret

0000000000000f72 <printf>:

void
printf(const char *fmt, ...)
{
     f72:	711d                	addi	sp,sp,-96
     f74:	ec06                	sd	ra,24(sp)
     f76:	e822                	sd	s0,16(sp)
     f78:	1000                	addi	s0,sp,32
     f7a:	e40c                	sd	a1,8(s0)
     f7c:	e810                	sd	a2,16(s0)
     f7e:	ec14                	sd	a3,24(s0)
     f80:	f018                	sd	a4,32(s0)
     f82:	f41c                	sd	a5,40(s0)
     f84:	03043823          	sd	a6,48(s0)
     f88:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
     f8c:	00840613          	addi	a2,s0,8
     f90:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
     f94:	85aa                	mv	a1,a0
     f96:	4505                	li	a0,1
     f98:	cf1ff0ef          	jal	c88 <vprintf>
}
     f9c:	60e2                	ld	ra,24(sp)
     f9e:	6442                	ld	s0,16(sp)
     fa0:	6125                	addi	sp,sp,96
     fa2:	8082                	ret

0000000000000fa4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
     fa4:	1141                	addi	sp,sp,-16
     fa6:	e406                	sd	ra,8(sp)
     fa8:	e022                	sd	s0,0(sp)
     faa:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
     fac:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     fb0:	00001797          	auipc	a5,0x1
     fb4:	0507b783          	ld	a5,80(a5) # 2000 <freep>
     fb8:	a039                	j	fc6 <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     fba:	6398                	ld	a4,0(a5)
     fbc:	00e7e463          	bltu	a5,a4,fc4 <free+0x20>
     fc0:	00e6ea63          	bltu	a3,a4,fd4 <free+0x30>
{
     fc4:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     fc6:	fed7fae3          	bgeu	a5,a3,fba <free+0x16>
     fca:	6398                	ld	a4,0(a5)
     fcc:	00e6e463          	bltu	a3,a4,fd4 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     fd0:	fee7eae3          	bltu	a5,a4,fc4 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
     fd4:	ff852583          	lw	a1,-8(a0)
     fd8:	6390                	ld	a2,0(a5)
     fda:	02059813          	slli	a6,a1,0x20
     fde:	01c85713          	srli	a4,a6,0x1c
     fe2:	9736                	add	a4,a4,a3
     fe4:	02e60563          	beq	a2,a4,100e <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
     fe8:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
     fec:	4790                	lw	a2,8(a5)
     fee:	02061593          	slli	a1,a2,0x20
     ff2:	01c5d713          	srli	a4,a1,0x1c
     ff6:	973e                	add	a4,a4,a5
     ff8:	02e68263          	beq	a3,a4,101c <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
     ffc:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
     ffe:	00001717          	auipc	a4,0x1
    1002:	00f73123          	sd	a5,2(a4) # 2000 <freep>
}
    1006:	60a2                	ld	ra,8(sp)
    1008:	6402                	ld	s0,0(sp)
    100a:	0141                	addi	sp,sp,16
    100c:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
    100e:	4618                	lw	a4,8(a2)
    1010:	9f2d                	addw	a4,a4,a1
    1012:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1016:	6398                	ld	a4,0(a5)
    1018:	6310                	ld	a2,0(a4)
    101a:	b7f9                	j	fe8 <free+0x44>
    p->s.size += bp->s.size;
    101c:	ff852703          	lw	a4,-8(a0)
    1020:	9f31                	addw	a4,a4,a2
    1022:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    1024:	ff053683          	ld	a3,-16(a0)
    1028:	bfd1                	j	ffc <free+0x58>

000000000000102a <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
    102a:	7139                	addi	sp,sp,-64
    102c:	fc06                	sd	ra,56(sp)
    102e:	f822                	sd	s0,48(sp)
    1030:	f04a                	sd	s2,32(sp)
    1032:	ec4e                	sd	s3,24(sp)
    1034:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
    1036:	02051993          	slli	s3,a0,0x20
    103a:	0209d993          	srli	s3,s3,0x20
    103e:	09bd                	addi	s3,s3,15
    1040:	0049d993          	srli	s3,s3,0x4
    1044:	2985                	addiw	s3,s3,1
    1046:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
    1048:	00001517          	auipc	a0,0x1
    104c:	fb853503          	ld	a0,-72(a0) # 2000 <freep>
    1050:	c905                	beqz	a0,1080 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
    1052:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
    1054:	4798                	lw	a4,8(a5)
    1056:	09377663          	bgeu	a4,s3,10e2 <malloc+0xb8>
    105a:	f426                	sd	s1,40(sp)
    105c:	e852                	sd	s4,16(sp)
    105e:	e456                	sd	s5,8(sp)
    1060:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
    1062:	8a4e                	mv	s4,s3
    1064:	6705                	lui	a4,0x1
    1066:	00e9f363          	bgeu	s3,a4,106c <malloc+0x42>
    106a:	6a05                	lui	s4,0x1
    106c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1070:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
    1074:	00001497          	auipc	s1,0x1
    1078:	f8c48493          	addi	s1,s1,-116 # 2000 <freep>
  if (p == SBRK_ERROR)
    107c:	5afd                	li	s5,-1
    107e:	a83d                	j	10bc <malloc+0x92>
    1080:	f426                	sd	s1,40(sp)
    1082:	e852                	sd	s4,16(sp)
    1084:	e456                	sd	s5,8(sp)
    1086:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    1088:	00001797          	auipc	a5,0x1
    108c:	f8878793          	addi	a5,a5,-120 # 2010 <base>
    1090:	00001717          	auipc	a4,0x1
    1094:	f6f73823          	sd	a5,-144(a4) # 2000 <freep>
    1098:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    109a:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
    109e:	b7d1                	j	1062 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
    10a0:	6398                	ld	a4,0(a5)
    10a2:	e118                	sd	a4,0(a0)
    10a4:	a899                	j	10fa <malloc+0xd0>
  hp->s.size = nu;
    10a6:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
    10aa:	0541                	addi	a0,a0,16
    10ac:	ef9ff0ef          	jal	fa4 <free>
  return freep;
    10b0:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
    10b2:	c125                	beqz	a0,1112 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
    10b4:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
    10b6:	4798                	lw	a4,8(a5)
    10b8:	03277163          	bgeu	a4,s2,10da <malloc+0xb0>
    if (p == freep)
    10bc:	6098                	ld	a4,0(s1)
    10be:	853e                	mv	a0,a5
    10c0:	fef71ae3          	bne	a4,a5,10b4 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
    10c4:	8552                	mv	a0,s4
    10c6:	a2bff0ef          	jal	af0 <sbrk>
  if (p == SBRK_ERROR)
    10ca:	fd551ee3          	bne	a0,s5,10a6 <malloc+0x7c>
        return 0;
    10ce:	4501                	li	a0,0
    10d0:	74a2                	ld	s1,40(sp)
    10d2:	6a42                	ld	s4,16(sp)
    10d4:	6aa2                	ld	s5,8(sp)
    10d6:	6b02                	ld	s6,0(sp)
    10d8:	a03d                	j	1106 <malloc+0xdc>
    10da:	74a2                	ld	s1,40(sp)
    10dc:	6a42                	ld	s4,16(sp)
    10de:	6aa2                	ld	s5,8(sp)
    10e0:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
    10e2:	fae90fe3          	beq	s2,a4,10a0 <malloc+0x76>
        p->s.size -= nunits;
    10e6:	4137073b          	subw	a4,a4,s3
    10ea:	c798                	sw	a4,8(a5)
        p += p->s.size;
    10ec:	02071693          	slli	a3,a4,0x20
    10f0:	01c6d713          	srli	a4,a3,0x1c
    10f4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    10f6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    10fa:	00001717          	auipc	a4,0x1
    10fe:	f0a73323          	sd	a0,-250(a4) # 2000 <freep>
      return (void *)(p + 1);
    1102:	01078513          	addi	a0,a5,16
  }
}
    1106:	70e2                	ld	ra,56(sp)
    1108:	7442                	ld	s0,48(sp)
    110a:	7902                	ld	s2,32(sp)
    110c:	69e2                	ld	s3,24(sp)
    110e:	6121                	addi	sp,sp,64
    1110:	8082                	ret
    1112:	74a2                	ld	s1,40(sp)
    1114:	6a42                	ld	s4,16(sp)
    1116:	6aa2                	ld	s5,8(sp)
    1118:	6b02                	ld	s6,0(sp)
    111a:	b7f5                	j	1106 <malloc+0xdc>
