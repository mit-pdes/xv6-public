
user/_pagereplace:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print_frame_state>:
}

// Print contents of frames in aligned format
static void
print_frame_state(int step, int page, int frames[], int num_frames, const char *status)
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
  printf(" %d\t| %d\t| ", step + 1, page);
      14:	862e                	mv	a2,a1
      16:	0015059b          	addiw	a1,a0,1
      1a:	00001517          	auipc	a0,0x1
      1e:	2d650513          	addi	a0,a0,726 # 12f0 <malloc+0xf2>
      22:	124010ef          	jal	1146 <printf>
  for (int i = 0; i < num_frames; i++) {
      26:	05305263          	blez	s3,6a <print_frame_state+0x6a>
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
      3c:	2d0a0a13          	addi	s4,s4,720 # 1308 <malloc+0x10a>
      printf(" - ");
      40:	00001a97          	auipc	s5,0x1
      44:	2c0a8a93          	addi	s5,s5,704 # 1300 <malloc+0x102>
      48:	a039                	j	56 <print_frame_state+0x56>
      4a:	8556                	mv	a0,s5
      4c:	0fa010ef          	jal	1146 <printf>
  for (int i = 0; i < num_frames; i++) {
      50:	0491                	addi	s1,s1,4
      52:	01248963          	beq	s1,s2,64 <print_frame_state+0x64>
    if (frames[i] == -1)
      56:	408c                	lw	a1,0(s1)
      58:	ff3589e3          	beq	a1,s3,4a <print_frame_state+0x4a>
      printf(" %d ", frames[i]);
      5c:	8552                	mv	a0,s4
      5e:	0e8010ef          	jal	1146 <printf>
      62:	b7fd                	j	50 <print_frame_state+0x50>
      64:	74a2                	ld	s1,40(sp)
      66:	6a42                	ld	s4,16(sp)
      68:	6aa2                	ld	s5,8(sp)
  }
  printf("\t| %s\n", status);
      6a:	85da                	mv	a1,s6
      6c:	00001517          	auipc	a0,0x1
      70:	2a450513          	addi	a0,a0,676 # 1310 <malloc+0x112>
      74:	0d2010ef          	jal	1146 <printf>
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
      9e:	7106869b          	addiw	a3,a3,1808 # 2710 <digits+0x9b0>
      a2:	02d5063b          	mulw	a2,a0,a3
      a6:	02f6463b          	divw	a2,a2,a5
      aa:	51eb87b7          	lui	a5,0x51eb8
      ae:	51f78793          	addi	a5,a5,1311 # 51eb851f <base+0x51eb550f>
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
      ce:	24e50513          	addi	a0,a0,590 # 1318 <malloc+0x11a>
      d2:	074010ef          	jal	1146 <printf>
}
      d6:	60a2                	ld	ra,8(sp)
      d8:	6402                	ld	s0,0(sp)
      da:	0141                	addi	sp,sp,16
      dc:	8082                	ret
    printf("%d.%d%%", whole, frac);
      de:	00001517          	auipc	a0,0x1
      e2:	24a50513          	addi	a0,a0,586 # 1328 <malloc+0x12a>
      e6:	060010ef          	jal	1146 <printf>
}
      ea:	b7f5                	j	d6 <print_percentage+0x50>

00000000000000ec <sim_fifo>:
// ============================================================================
// 1. First-In, First-Out (FIFO) Simulation
// ============================================================================
static void
sim_fifo(int num_frames, int verbose, int *out_faults, int *out_hits)
{
      ec:	7115                	addi	sp,sp,-224
      ee:	ed86                	sd	ra,216(sp)
      f0:	e9a2                	sd	s0,208(sp)
      f2:	e5a6                	sd	s1,200(sp)
      f4:	e1ca                	sd	s2,192(sp)
      f6:	fd4e                	sd	s3,184(sp)
      f8:	f952                	sd	s4,176(sp)
      fa:	f556                	sd	s5,168(sp)
      fc:	f15a                	sd	s6,160(sp)
      fe:	ed5e                	sd	s7,152(sp)
     100:	e962                	sd	s8,144(sp)
     102:	e566                	sd	s9,136(sp)
     104:	e16a                	sd	s10,128(sp)
     106:	fcee                	sd	s11,120(sp)
     108:	1180                	addi	s0,sp,224
     10a:	892a                	mv	s2,a0
     10c:	8c2e                	mv	s8,a1
     10e:	f2c43423          	sd	a2,-216(s0)
     112:	f2d43023          	sd	a3,-224(s0)
  int frames[MAX_FRAMES];
  int fifo_queue[MAX_FRAMES];
  int queue_head = 0, queue_tail = 0;
  int faults = 0, hits = 0;

  for (int i = 0; i < num_frames; i++) {
     116:	02a05063          	blez	a0,136 <sim_fifo+0x4a>
     11a:	f6840793          	addi	a5,s0,-152
     11e:	f4040713          	addi	a4,s0,-192
     122:	00251613          	slli	a2,a0,0x2
     126:	963e                	add	a2,a2,a5
    frames[i] = -1;
     128:	56fd                	li	a3,-1
     12a:	c394                	sw	a3,0(a5)
    fifo_queue[i] = -1;
     12c:	c314                	sw	a3,0(a4)
  for (int i = 0; i < num_frames; i++) {
     12e:	0791                	addi	a5,a5,4
     130:	0711                	addi	a4,a4,4
     132:	fec79ce3          	bne	a5,a2,12a <sim_fifo+0x3e>
  }

  if (verbose) {
     136:	020c1563          	bnez	s8,160 <sim_fifo+0x74>
    printf("------------------------------------------------------------\n");
    printf(" Step\t| Ref\t| Frame State\t| Status\n");
    printf("------------------------------------------------------------\n");
  }

  for (int i = 0; i < REF_LEN; i++) {
     13a:	00002a17          	auipc	s4,0x2
     13e:	bd6a0a13          	addi	s4,s4,-1066 # 1d10 <ref_string>
     142:	00291493          	slli	s1,s2,0x2
     146:	f6840793          	addi	a5,s0,-152
     14a:	94be                	add	s1,s1,a5
{
     14c:	4981                	li	s3,0
     14e:	4b81                	li	s7,0
     150:	4d01                	li	s10,0
     152:	4b01                	li	s6,0
     154:	f2043823          	sd	zero,-208(s0)
        fifo_queue[queue_tail] = victim_frame;
        queue_tail = (queue_tail + 1) % num_frames;
      }

      if (verbose)
        print_frame_state(i, p, frames, num_frames, "FAULT");
     158:	8dbe                	mv	s11,a5
        if (frames[j] == -1) {
     15a:	5afd                	li	s5,-1
  for (int i = 0; i < REF_LEN; i++) {
     15c:	4cd1                	li	s9,20
     15e:	aa0d                	j	290 <sim_fifo+0x1a4>
    printf("------------------------------------------------------------\n");
     160:	00001517          	auipc	a0,0x1
     164:	1d050513          	addi	a0,a0,464 # 1330 <malloc+0x132>
     168:	7df000ef          	jal	1146 <printf>
    printf(" FIFO Simulation (Frames: %d)\n", num_frames);
     16c:	85ca                	mv	a1,s2
     16e:	00001517          	auipc	a0,0x1
     172:	20250513          	addi	a0,a0,514 # 1370 <malloc+0x172>
     176:	7d1000ef          	jal	1146 <printf>
    printf("------------------------------------------------------------\n");
     17a:	00001517          	auipc	a0,0x1
     17e:	1b650513          	addi	a0,a0,438 # 1330 <malloc+0x132>
     182:	7c5000ef          	jal	1146 <printf>
    printf(" Step\t| Ref\t| Frame State\t| Status\n");
     186:	00001517          	auipc	a0,0x1
     18a:	20a50513          	addi	a0,a0,522 # 1390 <malloc+0x192>
     18e:	7b9000ef          	jal	1146 <printf>
    printf("------------------------------------------------------------\n");
     192:	00001517          	auipc	a0,0x1
     196:	19e50513          	addi	a0,a0,414 # 1330 <malloc+0x132>
     19a:	7ad000ef          	jal	1146 <printf>
     19e:	bf71                	j	13a <sim_fifo+0x4e>
        print_frame_state(i, p, frames, num_frames, "HIT ");
     1a0:	00001717          	auipc	a4,0x1
     1a4:	21870713          	addi	a4,a4,536 # 13b8 <malloc+0x1ba>
     1a8:	86ca                	mv	a3,s2
     1aa:	866e                	mv	a2,s11
     1ac:	854e                	mv	a0,s3
     1ae:	e53ff0ef          	jal	0 <print_frame_state>
     1b2:	a8d9                	j	288 <sim_fifo+0x19c>
      if (empty_idx != -1) {
     1b4:	11578563          	beq	a5,s5,2be <sim_fifo+0x1d2>
        frames[empty_idx] = p;
     1b8:	00279713          	slli	a4,a5,0x2
     1bc:	976e                	add	a4,a4,s11
     1be:	c30c                	sw	a1,0(a4)
        queue_tail = (queue_tail + 1) % num_frames;
     1c0:	001b071b          	addiw	a4,s6,1
     1c4:	0327673b          	remw	a4,a4,s2
     1c8:	f2e43c23          	sd	a4,-200(s0)
        fifo_queue[queue_tail] = empty_idx;
     1cc:	0b0a                	slli	s6,s6,0x2
     1ce:	f4040713          	addi	a4,s0,-192
     1d2:	9b3a                	add	s6,s6,a4
     1d4:	00fb2023          	sw	a5,0(s6)
      if (verbose)
     1d8:	f3843b03          	ld	s6,-200(s0)
     1dc:	0a0c0663          	beqz	s8,288 <sim_fifo+0x19c>
        print_frame_state(i, p, frames, num_frames, "FAULT");
     1e0:	00001717          	auipc	a4,0x1
     1e4:	1e070713          	addi	a4,a4,480 # 13c0 <malloc+0x1c2>
     1e8:	86ca                	mv	a3,s2
     1ea:	866e                	mv	a2,s11
     1ec:	854e                	mv	a0,s3
     1ee:	e13ff0ef          	jal	0 <print_frame_state>
     1f2:	f3843b03          	ld	s6,-200(s0)
     1f6:	a849                	j	288 <sim_fifo+0x19c>
    }
  }

  if (verbose) {
     1f8:	020c1963          	bnez	s8,22a <sim_fifo+0x13e>
    printf(" | Fault Ratio: ");
    print_percentage(faults, REF_LEN);
    printf("\n\n");
  }

  *out_faults = faults;
     1fc:	f2843783          	ld	a5,-216(s0)
     200:	01a7a023          	sw	s10,0(a5)
  *out_hits = hits;
     204:	f2043783          	ld	a5,-224(s0)
     208:	0177a023          	sw	s7,0(a5)
}
     20c:	60ee                	ld	ra,216(sp)
     20e:	644e                	ld	s0,208(sp)
     210:	64ae                	ld	s1,200(sp)
     212:	690e                	ld	s2,192(sp)
     214:	79ea                	ld	s3,184(sp)
     216:	7a4a                	ld	s4,176(sp)
     218:	7aaa                	ld	s5,168(sp)
     21a:	7b0a                	ld	s6,160(sp)
     21c:	6bea                	ld	s7,152(sp)
     21e:	6c4a                	ld	s8,144(sp)
     220:	6caa                	ld	s9,136(sp)
     222:	6d0a                	ld	s10,128(sp)
     224:	7de6                	ld	s11,120(sp)
     226:	612d                	addi	sp,sp,224
     228:	8082                	ret
    printf("------------------------------------------------------------\n");
     22a:	00001517          	auipc	a0,0x1
     22e:	10650513          	addi	a0,a0,262 # 1330 <malloc+0x132>
     232:	715000ef          	jal	1146 <printf>
    printf("FIFO Summary (%d frames): Page Faults = %d, Page Hits = %d\n", num_frames, faults, hits);
     236:	86de                	mv	a3,s7
     238:	866a                	mv	a2,s10
     23a:	85ca                	mv	a1,s2
     23c:	00001517          	auipc	a0,0x1
     240:	18c50513          	addi	a0,a0,396 # 13c8 <malloc+0x1ca>
     244:	703000ef          	jal	1146 <printf>
    printf("Hit Ratio: ");
     248:	00001517          	auipc	a0,0x1
     24c:	1c050513          	addi	a0,a0,448 # 1408 <malloc+0x20a>
     250:	6f7000ef          	jal	1146 <printf>
    print_percentage(hits, REF_LEN);
     254:	45d1                	li	a1,20
     256:	855e                	mv	a0,s7
     258:	e2fff0ef          	jal	86 <print_percentage>
    printf(" | Fault Ratio: ");
     25c:	00001517          	auipc	a0,0x1
     260:	1bc50513          	addi	a0,a0,444 # 1418 <malloc+0x21a>
     264:	6e3000ef          	jal	1146 <printf>
    print_percentage(faults, REF_LEN);
     268:	45d1                	li	a1,20
     26a:	856a                	mv	a0,s10
     26c:	e1bff0ef          	jal	86 <print_percentage>
    printf("\n\n");
     270:	00001517          	auipc	a0,0x1
     274:	1c050513          	addi	a0,a0,448 # 1430 <malloc+0x232>
     278:	6cf000ef          	jal	1146 <printf>
     27c:	b741                	j	1fc <sim_fifo+0x110>
      faults++;
     27e:	2d05                	addiw	s10,s10,1
      for (int j = 0; j < num_frames; j++) {
     280:	a83d                	j	2be <sim_fifo+0x1d2>
      hits++;
     282:	2b85                	addiw	s7,s7,1
      if (verbose)
     284:	f00c1ee3          	bnez	s8,1a0 <sim_fifo+0xb4>
  for (int i = 0; i < REF_LEN; i++) {
     288:	2985                	addiw	s3,s3,1
     28a:	0a11                	addi	s4,s4,4
     28c:	f79986e3          	beq	s3,s9,1f8 <sim_fifo+0x10c>
    int p = ref_string[i];
     290:	000a2583          	lw	a1,0(s4)
    for (int j = 0; j < num_frames; j++) {
     294:	ff2055e3          	blez	s2,27e <sim_fifo+0x192>
     298:	f6840793          	addi	a5,s0,-152
      if (frames[j] == p) {
     29c:	4398                	lw	a4,0(a5)
     29e:	feb702e3          	beq	a4,a1,282 <sim_fifo+0x196>
    for (int j = 0; j < num_frames; j++) {
     2a2:	0791                	addi	a5,a5,4
     2a4:	fe979ce3          	bne	a5,s1,29c <sim_fifo+0x1b0>
      faults++;
     2a8:	2d05                	addiw	s10,s10,1
     2aa:	f6840713          	addi	a4,s0,-152
      for (int j = 0; j < num_frames; j++) {
     2ae:	4781                	li	a5,0
        if (frames[j] == -1) {
     2b0:	4314                	lw	a3,0(a4)
     2b2:	f15681e3          	beq	a3,s5,1b4 <sim_fifo+0xc8>
      for (int j = 0; j < num_frames; j++) {
     2b6:	2785                	addiw	a5,a5,1
     2b8:	0711                	addi	a4,a4,4
     2ba:	fef91be3          	bne	s2,a5,2b0 <sim_fifo+0x1c4>
        int victim_frame = fifo_queue[queue_head];
     2be:	f3043703          	ld	a4,-208(s0)
     2c2:	00271793          	slli	a5,a4,0x2
     2c6:	f4040693          	addi	a3,s0,-192
     2ca:	97b6                	add	a5,a5,a3
     2cc:	439c                	lw	a5,0(a5)
        queue_head = (queue_head + 1) % num_frames;
     2ce:	2705                	addiw	a4,a4,1
     2d0:	0327673b          	remw	a4,a4,s2
     2d4:	f2e43823          	sd	a4,-208(s0)
        frames[victim_frame] = p;
     2d8:	00279713          	slli	a4,a5,0x2
     2dc:	976e                	add	a4,a4,s11
     2de:	c30c                	sw	a1,0(a4)
        queue_tail = (queue_tail + 1) % num_frames;
     2e0:	001b071b          	addiw	a4,s6,1
     2e4:	0327673b          	remw	a4,a4,s2
     2e8:	f2e43c23          	sd	a4,-200(s0)
     2ec:	b5c5                	j	1cc <sim_fifo+0xe0>

00000000000002ee <sim_lru>:
// ============================================================================
// 2. Least Recently Used (LRU) Simulation
// ============================================================================
static void
sim_lru(int num_frames, int verbose, int *out_faults, int *out_hits)
{
     2ee:	7155                	addi	sp,sp,-208
     2f0:	e586                	sd	ra,200(sp)
     2f2:	e1a2                	sd	s0,192(sp)
     2f4:	fd26                	sd	s1,184(sp)
     2f6:	f94a                	sd	s2,176(sp)
     2f8:	f54e                	sd	s3,168(sp)
     2fa:	f152                	sd	s4,160(sp)
     2fc:	ed56                	sd	s5,152(sp)
     2fe:	e95a                	sd	s6,144(sp)
     300:	e55e                	sd	s7,136(sp)
     302:	e162                	sd	s8,128(sp)
     304:	fce6                	sd	s9,120(sp)
     306:	f8ea                	sd	s10,112(sp)
     308:	f4ee                	sd	s11,104(sp)
     30a:	0980                	addi	s0,sp,208
     30c:	84aa                	mv	s1,a0
     30e:	8b2e                	mv	s6,a1
     310:	f2c43c23          	sd	a2,-200(s0)
     314:	f2d43823          	sd	a3,-208(s0)
  int frames[MAX_FRAMES];
  int last_used[MAX_FRAMES];
  int faults = 0, hits = 0;

  for (int i = 0; i < num_frames; i++) {
     318:	02a05063          	blez	a0,338 <sim_lru+0x4a>
     31c:	f6840793          	addi	a5,s0,-152
     320:	f4040713          	addi	a4,s0,-192
     324:	00251613          	slli	a2,a0,0x2
     328:	963e                	add	a2,a2,a5
    frames[i] = -1;
     32a:	56fd                	li	a3,-1
     32c:	c394                	sw	a3,0(a5)
    last_used[i] = -1;
     32e:	c314                	sw	a3,0(a4)
  for (int i = 0; i < num_frames; i++) {
     330:	0791                	addi	a5,a5,4
     332:	0711                	addi	a4,a4,4
     334:	fec79ce3          	bne	a5,a2,32c <sim_lru+0x3e>
  }

  if (verbose) {
     338:	020b1463          	bnez	s6,360 <sim_lru+0x72>
    printf("------------------------------------------------------------\n");
    printf(" Step\t| Ref\t| Frame State\t| Status\n");
    printf("------------------------------------------------------------\n");
  }

  for (int i = 0; i < REF_LEN; i++) {
     33c:	00002997          	auipc	s3,0x2
     340:	9d498993          	addi	s3,s3,-1580 # 1d10 <ref_string>
{
     344:	4901                	li	s2,0
     346:	4a81                	li	s5,0
     348:	4d01                	li	s10,0
        frames[lru_idx] = p;
        last_used[lru_idx] = i;
      }

      if (verbose)
        print_frame_state(i, p, frames, num_frames, "FAULT");
     34a:	f6840c93          	addi	s9,s0,-152
        if (frames[j] == -1) {
     34e:	5a7d                	li	s4,-1
        last_used[empty_idx] = i;
     350:	f4040c13          	addi	s8,s0,-192
        print_frame_state(i, p, frames, num_frames, "HIT ");
     354:	00001d97          	auipc	s11,0x1
     358:	064d8d93          	addi	s11,s11,100 # 13b8 <malloc+0x1ba>
  for (int i = 0; i < REF_LEN; i++) {
     35c:	4bd1                	li	s7,20
     35e:	a8b1                	j	3ba <sim_lru+0xcc>
    printf("------------------------------------------------------------\n");
     360:	00001517          	auipc	a0,0x1
     364:	fd050513          	addi	a0,a0,-48 # 1330 <malloc+0x132>
     368:	5df000ef          	jal	1146 <printf>
    printf(" LRU Simulation (Frames: %d)\n", num_frames);
     36c:	85a6                	mv	a1,s1
     36e:	00001517          	auipc	a0,0x1
     372:	0ca50513          	addi	a0,a0,202 # 1438 <malloc+0x23a>
     376:	5d1000ef          	jal	1146 <printf>
    printf("------------------------------------------------------------\n");
     37a:	00001517          	auipc	a0,0x1
     37e:	fb650513          	addi	a0,a0,-74 # 1330 <malloc+0x132>
     382:	5c5000ef          	jal	1146 <printf>
    printf(" Step\t| Ref\t| Frame State\t| Status\n");
     386:	00001517          	auipc	a0,0x1
     38a:	00a50513          	addi	a0,a0,10 # 1390 <malloc+0x192>
     38e:	5b9000ef          	jal	1146 <printf>
    printf("------------------------------------------------------------\n");
     392:	00001517          	auipc	a0,0x1
     396:	f9e50513          	addi	a0,a0,-98 # 1330 <malloc+0x132>
     39a:	5ad000ef          	jal	1146 <printf>
     39e:	bf79                	j	33c <sim_lru+0x4e>
    if (found_idx != -1) {
     3a0:	03478b63          	beq	a5,s4,3d6 <sim_lru+0xe8>
      hits++;
     3a4:	2a85                	addiw	s5,s5,1
      last_used[found_idx] = i; // Update recency
     3a6:	078a                	slli	a5,a5,0x2
     3a8:	97e2                	add	a5,a5,s8
     3aa:	0127a023          	sw	s2,0(a5)
      if (verbose)
     3ae:	040b1863          	bnez	s6,3fe <sim_lru+0x110>
  for (int i = 0; i < REF_LEN; i++) {
     3b2:	2905                	addiw	s2,s2,1
     3b4:	0991                	addi	s3,s3,4
     3b6:	0b790863          	beq	s2,s7,466 <sim_lru+0x178>
    int p = ref_string[i];
     3ba:	0009a583          	lw	a1,0(s3)
    for (int j = 0; j < num_frames; j++) {
     3be:	12905763          	blez	s1,4ec <sim_lru+0x1fe>
     3c2:	f6840713          	addi	a4,s0,-152
     3c6:	4781                	li	a5,0
      if (frames[j] == p) {
     3c8:	4314                	lw	a3,0(a4)
     3ca:	fcb68be3          	beq	a3,a1,3a0 <sim_lru+0xb2>
    for (int j = 0; j < num_frames; j++) {
     3ce:	2785                	addiw	a5,a5,1
     3d0:	0711                	addi	a4,a4,4
     3d2:	fef49be3          	bne	s1,a5,3c8 <sim_lru+0xda>
      faults++;
     3d6:	2d05                	addiw	s10,s10,1
      for (int j = 0; j < num_frames; j++) {
     3d8:	f6840713          	addi	a4,s0,-152
     3dc:	4781                	li	a5,0
        if (frames[j] == -1) {
     3de:	4314                	lw	a3,0(a4)
     3e0:	03468663          	beq	a3,s4,40c <sim_lru+0x11e>
      for (int j = 0; j < num_frames; j++) {
     3e4:	2785                	addiw	a5,a5,1
     3e6:	0711                	addi	a4,a4,4
     3e8:	fef49be3          	bne	s1,a5,3de <sim_lru+0xf0>
        for (int j = 1; j < num_frames; j++) {
     3ec:	4785                	li	a5,1
     3ee:	0497de63          	bge	a5,s1,44a <sim_lru+0x15c>
        int min_time = last_used[0];
     3f2:	f4042603          	lw	a2,-192(s0)
     3f6:	f4040713          	addi	a4,s0,-192
        int lru_idx = 0;
     3fa:	4501                	li	a0,0
     3fc:	a089                	j	43e <sim_lru+0x150>
        print_frame_state(i, p, frames, num_frames, "HIT ");
     3fe:	876e                	mv	a4,s11
     400:	86a6                	mv	a3,s1
     402:	8666                	mv	a2,s9
     404:	854a                	mv	a0,s2
     406:	bfbff0ef          	jal	0 <print_frame_state>
     40a:	b765                	j	3b2 <sim_lru+0xc4>
      if (empty_idx != -1) {
     40c:	ff4780e3          	beq	a5,s4,3ec <sim_lru+0xfe>
        frames[empty_idx] = p;
     410:	078a                	slli	a5,a5,0x2
     412:	01978733          	add	a4,a5,s9
     416:	c30c                	sw	a1,0(a4)
        last_used[empty_idx] = i;
     418:	97e2                	add	a5,a5,s8
     41a:	0127a023          	sw	s2,0(a5)
      if (verbose)
     41e:	f80b0ae3          	beqz	s6,3b2 <sim_lru+0xc4>
        print_frame_state(i, p, frames, num_frames, "FAULT");
     422:	00001717          	auipc	a4,0x1
     426:	f9e70713          	addi	a4,a4,-98 # 13c0 <malloc+0x1c2>
     42a:	86a6                	mv	a3,s1
     42c:	8666                	mv	a2,s9
     42e:	854a                	mv	a0,s2
     430:	bd1ff0ef          	jal	0 <print_frame_state>
     434:	bfbd                	j	3b2 <sim_lru+0xc4>
        for (int j = 1; j < num_frames; j++) {
     436:	2785                	addiw	a5,a5,1
     438:	0711                	addi	a4,a4,4
     43a:	00f48963          	beq	s1,a5,44c <sim_lru+0x15e>
          if (last_used[j] < min_time) {
     43e:	4354                	lw	a3,4(a4)
     440:	fec6dbe3          	bge	a3,a2,436 <sim_lru+0x148>
            min_time = last_used[j];
     444:	8636                	mv	a2,a3
            lru_idx = j;
     446:	853e                	mv	a0,a5
     448:	b7fd                	j	436 <sim_lru+0x148>
        int lru_idx = 0;
     44a:	4501                	li	a0,0
        frames[lru_idx] = p;
     44c:	050a                	slli	a0,a0,0x2
     44e:	f9050793          	addi	a5,a0,-112
     452:	97a2                	add	a5,a5,s0
     454:	fcb7ac23          	sw	a1,-40(a5)
        last_used[lru_idx] = i;
     458:	f9050793          	addi	a5,a0,-112
     45c:	00878533          	add	a0,a5,s0
     460:	fb252823          	sw	s2,-80(a0)
     464:	bf6d                	j	41e <sim_lru+0x130>
    }
  }

  if (verbose) {
     466:	020b1963          	bnez	s6,498 <sim_lru+0x1aa>
    printf(" | Fault Ratio: ");
    print_percentage(faults, REF_LEN);
    printf("\n\n");
  }

  *out_faults = faults;
     46a:	f3843783          	ld	a5,-200(s0)
     46e:	01a7a023          	sw	s10,0(a5)
  *out_hits = hits;
     472:	f3043783          	ld	a5,-208(s0)
     476:	0157a023          	sw	s5,0(a5)
}
     47a:	60ae                	ld	ra,200(sp)
     47c:	640e                	ld	s0,192(sp)
     47e:	74ea                	ld	s1,184(sp)
     480:	794a                	ld	s2,176(sp)
     482:	79aa                	ld	s3,168(sp)
     484:	7a0a                	ld	s4,160(sp)
     486:	6aea                	ld	s5,152(sp)
     488:	6b4a                	ld	s6,144(sp)
     48a:	6baa                	ld	s7,136(sp)
     48c:	6c0a                	ld	s8,128(sp)
     48e:	7ce6                	ld	s9,120(sp)
     490:	7d46                	ld	s10,112(sp)
     492:	7da6                	ld	s11,104(sp)
     494:	6169                	addi	sp,sp,208
     496:	8082                	ret
    printf("------------------------------------------------------------\n");
     498:	00001517          	auipc	a0,0x1
     49c:	e9850513          	addi	a0,a0,-360 # 1330 <malloc+0x132>
     4a0:	4a7000ef          	jal	1146 <printf>
    printf("LRU Summary (%d frames): Page Faults = %d, Page Hits = %d\n", num_frames, faults, hits);
     4a4:	86d6                	mv	a3,s5
     4a6:	866a                	mv	a2,s10
     4a8:	85a6                	mv	a1,s1
     4aa:	00001517          	auipc	a0,0x1
     4ae:	fae50513          	addi	a0,a0,-82 # 1458 <malloc+0x25a>
     4b2:	495000ef          	jal	1146 <printf>
    printf("Hit Ratio: ");
     4b6:	00001517          	auipc	a0,0x1
     4ba:	f5250513          	addi	a0,a0,-174 # 1408 <malloc+0x20a>
     4be:	489000ef          	jal	1146 <printf>
    print_percentage(hits, REF_LEN);
     4c2:	45d1                	li	a1,20
     4c4:	8556                	mv	a0,s5
     4c6:	bc1ff0ef          	jal	86 <print_percentage>
    printf(" | Fault Ratio: ");
     4ca:	00001517          	auipc	a0,0x1
     4ce:	f4e50513          	addi	a0,a0,-178 # 1418 <malloc+0x21a>
     4d2:	475000ef          	jal	1146 <printf>
    print_percentage(faults, REF_LEN);
     4d6:	45d1                	li	a1,20
     4d8:	856a                	mv	a0,s10
     4da:	badff0ef          	jal	86 <print_percentage>
    printf("\n\n");
     4de:	00001517          	auipc	a0,0x1
     4e2:	f5250513          	addi	a0,a0,-174 # 1430 <malloc+0x232>
     4e6:	461000ef          	jal	1146 <printf>
     4ea:	b741                	j	46a <sim_lru+0x17c>
      faults++;
     4ec:	2d05                	addiw	s10,s10,1
        int lru_idx = 0;
     4ee:	4501                	li	a0,0
     4f0:	bfb1                	j	44c <sim_lru+0x15e>

00000000000004f2 <sim_opt>:
// ============================================================================
// 3. Optimal Page Replacement (OPT) Simulation
// ============================================================================
static void
sim_opt(int num_frames, int verbose, int *out_faults, int *out_hits)
{
     4f2:	7171                	addi	sp,sp,-176
     4f4:	f506                	sd	ra,168(sp)
     4f6:	f122                	sd	s0,160(sp)
     4f8:	ed26                	sd	s1,152(sp)
     4fa:	e94a                	sd	s2,144(sp)
     4fc:	e54e                	sd	s3,136(sp)
     4fe:	e152                	sd	s4,128(sp)
     500:	fcd6                	sd	s5,120(sp)
     502:	f8da                	sd	s6,112(sp)
     504:	f4de                	sd	s7,104(sp)
     506:	f0e2                	sd	s8,96(sp)
     508:	ece6                	sd	s9,88(sp)
     50a:	e8ea                	sd	s10,80(sp)
     50c:	e4ee                	sd	s11,72(sp)
     50e:	1900                	addi	s0,sp,176
     510:	892a                	mv	s2,a0
     512:	8c2e                	mv	s8,a1
     514:	f4c43c23          	sd	a2,-168(s0)
     518:	f4d43823          	sd	a3,-176(s0)
  int frames[MAX_FRAMES];
  int faults = 0, hits = 0;

  for (int i = 0; i < num_frames; i++) {
     51c:	00a05c63          	blez	a0,534 <sim_opt+0x42>
     520:	f6840793          	addi	a5,s0,-152
     524:	00251713          	slli	a4,a0,0x2
     528:	973e                	add	a4,a4,a5
    frames[i] = -1;
     52a:	56fd                	li	a3,-1
     52c:	c394                	sw	a3,0(a5)
  for (int i = 0; i < num_frames; i++) {
     52e:	0791                	addi	a5,a5,4
     530:	fee79ee3          	bne	a5,a4,52c <sim_opt+0x3a>
  }

  if (verbose) {
     534:	020c1263          	bnez	s8,558 <sim_opt+0x66>
    printf("------------------------------------------------------------\n");
    printf(" Step\t| Ref\t| Frame State\t| Status\n");
    printf("------------------------------------------------------------\n");
  }

  for (int i = 0; i < REF_LEN; i++) {
     538:	00001a17          	auipc	s4,0x1
     53c:	7dca0a13          	addi	s4,s4,2012 # 1d14 <ref_string+0x4>
     540:	f6840b93          	addi	s7,s0,-152
     544:	00291493          	slli	s1,s2,0x2
     548:	94de                	add	s1,s1,s7
{
     54a:	4985                	li	s3,1
     54c:	4b01                	li	s6,0
     54e:	4d01                	li	s10,0

        frames[victim_frame] = p;
      }

      if (verbose)
        print_frame_state(i, p, frames, num_frames, "FAULT");
     550:	8dde                	mv	s11,s7
        if (frames[j] == -1) {
     552:	5afd                	li	s5,-1
  for (int i = 0; i < REF_LEN; i++) {
     554:	4cd5                	li	s9,21
     556:	a289                	j	698 <sim_opt+0x1a6>
    printf("------------------------------------------------------------\n");
     558:	00001517          	auipc	a0,0x1
     55c:	dd850513          	addi	a0,a0,-552 # 1330 <malloc+0x132>
     560:	3e7000ef          	jal	1146 <printf>
    printf(" Optimal (OPT) Simulation (Frames: %d)\n", num_frames);
     564:	85ca                	mv	a1,s2
     566:	00001517          	auipc	a0,0x1
     56a:	f3250513          	addi	a0,a0,-206 # 1498 <malloc+0x29a>
     56e:	3d9000ef          	jal	1146 <printf>
    printf("------------------------------------------------------------\n");
     572:	00001517          	auipc	a0,0x1
     576:	dbe50513          	addi	a0,a0,-578 # 1330 <malloc+0x132>
     57a:	3cd000ef          	jal	1146 <printf>
    printf(" Step\t| Ref\t| Frame State\t| Status\n");
     57e:	00001517          	auipc	a0,0x1
     582:	e1250513          	addi	a0,a0,-494 # 1390 <malloc+0x192>
     586:	3c1000ef          	jal	1146 <printf>
    printf("------------------------------------------------------------\n");
     58a:	00001517          	auipc	a0,0x1
     58e:	da650513          	addi	a0,a0,-602 # 1330 <malloc+0x132>
     592:	3b5000ef          	jal	1146 <printf>
     596:	b74d                	j	538 <sim_opt+0x46>
        print_frame_state(i, p, frames, num_frames, "HIT ");
     598:	00001717          	auipc	a4,0x1
     59c:	e2070713          	addi	a4,a4,-480 # 13b8 <malloc+0x1ba>
     5a0:	86ca                	mv	a3,s2
     5a2:	866e                	mv	a2,s11
     5a4:	a5dff0ef          	jal	0 <print_frame_state>
     5a8:	a0e5                	j	690 <sim_opt+0x19e>
     5aa:	8e5e                	mv	t3,s7
        for (int j = 0; j < num_frames; j++) {
     5ac:	4301                	li	t1,0
        int victim_frame = 0;
     5ae:	4281                	li	t0,0
          for (int k = i + 1; k < REF_LEN; k++) {
     5b0:	00098e9b          	sext.w	t4,s3
     5b4:	4f4d                	li	t5,19
     5b6:	48d1                	li	a7,20
          if (next_use == -1) {
     5b8:	5ffd                	li	t6,-1
     5ba:	a819                	j	5d0 <sim_opt+0xde>
     5bc:	03f78763          	beq	a5,t6,5ea <sim_opt+0xf8>
          if (next_use > farthest_use) {
     5c0:	00f6d463          	bge	a3,a5,5c8 <sim_opt+0xd6>
            victim_frame = j;
     5c4:	829a                	mv	t0,t1
            farthest_use = next_use;
     5c6:	86be                	mv	a3,a5
        for (int j = 0; j < num_frames; j++) {
     5c8:	2305                	addiw	t1,t1,1
     5ca:	0e11                	addi	t3,t3,4
     5cc:	02690763          	beq	s2,t1,5fa <sim_opt+0x108>
          for (int k = i + 1; k < REF_LEN; k++) {
     5d0:	01df4d63          	blt	t5,t4,5ea <sim_opt+0xf8>
     5d4:	87f6                	mv	a5,t4
          int page_in_frame = frames[j];
     5d6:	000e2803          	lw	a6,0(t3)
     5da:	8752                	mv	a4,s4
            if (ref_string[k] == page_in_frame) {
     5dc:	4310                	lw	a2,0(a4)
     5de:	fd060fe3          	beq	a2,a6,5bc <sim_opt+0xca>
          for (int k = i + 1; k < REF_LEN; k++) {
     5e2:	2785                	addiw	a5,a5,1
     5e4:	0711                	addi	a4,a4,4
     5e6:	ff179be3          	bne	a5,a7,5dc <sim_opt+0xea>
        frames[victim_frame] = p;
     5ea:	00231793          	slli	a5,t1,0x2
     5ee:	f9078793          	addi	a5,a5,-112
     5f2:	97a2                	add	a5,a5,s0
     5f4:	fcb7ac23          	sw	a1,-40(a5)
     5f8:	a8e9                	j	6d2 <sim_opt+0x1e0>
     5fa:	8316                	mv	t1,t0
     5fc:	b7fd                	j	5ea <sim_opt+0xf8>
    }
  }

  if (verbose) {
     5fe:	020c1963          	bnez	s8,630 <sim_opt+0x13e>
    printf(" | Fault Ratio: ");
    print_percentage(faults, REF_LEN);
    printf("\n\n");
  }

  *out_faults = faults;
     602:	f5843783          	ld	a5,-168(s0)
     606:	01a7a023          	sw	s10,0(a5)
  *out_hits = hits;
     60a:	f5043783          	ld	a5,-176(s0)
     60e:	0167a023          	sw	s6,0(a5)
}
     612:	70aa                	ld	ra,168(sp)
     614:	740a                	ld	s0,160(sp)
     616:	64ea                	ld	s1,152(sp)
     618:	694a                	ld	s2,144(sp)
     61a:	69aa                	ld	s3,136(sp)
     61c:	6a0a                	ld	s4,128(sp)
     61e:	7ae6                	ld	s5,120(sp)
     620:	7b46                	ld	s6,112(sp)
     622:	7ba6                	ld	s7,104(sp)
     624:	7c06                	ld	s8,96(sp)
     626:	6ce6                	ld	s9,88(sp)
     628:	6d46                	ld	s10,80(sp)
     62a:	6da6                	ld	s11,72(sp)
     62c:	614d                	addi	sp,sp,176
     62e:	8082                	ret
    printf("------------------------------------------------------------\n");
     630:	00001517          	auipc	a0,0x1
     634:	d0050513          	addi	a0,a0,-768 # 1330 <malloc+0x132>
     638:	30f000ef          	jal	1146 <printf>
    printf("OPT Summary (%d frames): Page Faults = %d, Page Hits = %d\n", num_frames, faults, hits);
     63c:	86da                	mv	a3,s6
     63e:	866a                	mv	a2,s10
     640:	85ca                	mv	a1,s2
     642:	00001517          	auipc	a0,0x1
     646:	e7e50513          	addi	a0,a0,-386 # 14c0 <malloc+0x2c2>
     64a:	2fd000ef          	jal	1146 <printf>
    printf("Hit Ratio: ");
     64e:	00001517          	auipc	a0,0x1
     652:	dba50513          	addi	a0,a0,-582 # 1408 <malloc+0x20a>
     656:	2f1000ef          	jal	1146 <printf>
    print_percentage(hits, REF_LEN);
     65a:	45d1                	li	a1,20
     65c:	855a                	mv	a0,s6
     65e:	a29ff0ef          	jal	86 <print_percentage>
    printf(" | Fault Ratio: ");
     662:	00001517          	auipc	a0,0x1
     666:	db650513          	addi	a0,a0,-586 # 1418 <malloc+0x21a>
     66a:	2dd000ef          	jal	1146 <printf>
    print_percentage(faults, REF_LEN);
     66e:	45d1                	li	a1,20
     670:	856a                	mv	a0,s10
     672:	a15ff0ef          	jal	86 <print_percentage>
    printf("\n\n");
     676:	00001517          	auipc	a0,0x1
     67a:	dba50513          	addi	a0,a0,-582 # 1430 <malloc+0x232>
     67e:	2c9000ef          	jal	1146 <printf>
     682:	b741                	j	602 <sim_opt+0x110>
      faults++;
     684:	2d05                	addiw	s10,s10,1
        int victim_frame = 0;
     686:	4301                	li	t1,0
     688:	b78d                	j	5ea <sim_opt+0xf8>
      hits++;
     68a:	2b05                	addiw	s6,s6,1
      if (verbose)
     68c:	f00c16e3          	bnez	s8,598 <sim_opt+0xa6>
  for (int i = 0; i < REF_LEN; i++) {
     690:	0985                	addi	s3,s3,1
     692:	0a11                	addi	s4,s4,4
     694:	f79985e3          	beq	s3,s9,5fe <sim_opt+0x10c>
     698:	fff9851b          	addiw	a0,s3,-1
    int p = ref_string[i];
     69c:	ffca2583          	lw	a1,-4(s4)
    for (int j = 0; j < num_frames; j++) {
     6a0:	ff2052e3          	blez	s2,684 <sim_opt+0x192>
     6a4:	87de                	mv	a5,s7
      if (frames[j] == p) {
     6a6:	4398                	lw	a4,0(a5)
     6a8:	feb701e3          	beq	a4,a1,68a <sim_opt+0x198>
    for (int j = 0; j < num_frames; j++) {
     6ac:	0791                	addi	a5,a5,4
     6ae:	fe979ce3          	bne	a5,s1,6a6 <sim_opt+0x1b4>
      faults++;
     6b2:	2d05                	addiw	s10,s10,1
     6b4:	87de                	mv	a5,s7
      for (int j = 0; j < num_frames; j++) {
     6b6:	4681                	li	a3,0
        if (frames[j] == -1) {
     6b8:	4398                	lw	a4,0(a5)
     6ba:	01570763          	beq	a4,s5,6c8 <sim_opt+0x1d6>
      for (int j = 0; j < num_frames; j++) {
     6be:	2685                	addiw	a3,a3,1
     6c0:	0791                	addi	a5,a5,4
     6c2:	fed91be3          	bne	s2,a3,6b8 <sim_opt+0x1c6>
      int empty_idx = -1;
     6c6:	86d6                	mv	a3,s5
      if (empty_idx != -1) {
     6c8:	ef5681e3          	beq	a3,s5,5aa <sim_opt+0xb8>
        frames[empty_idx] = p;
     6cc:	068a                	slli	a3,a3,0x2
     6ce:	96ee                	add	a3,a3,s11
     6d0:	c28c                	sw	a1,0(a3)
      if (verbose)
     6d2:	fa0c0fe3          	beqz	s8,690 <sim_opt+0x19e>
        print_frame_state(i, p, frames, num_frames, "FAULT");
     6d6:	00001717          	auipc	a4,0x1
     6da:	cea70713          	addi	a4,a4,-790 # 13c0 <malloc+0x1c2>
     6de:	86ca                	mv	a3,s2
     6e0:	866e                	mv	a2,s11
     6e2:	91fff0ef          	jal	0 <print_frame_state>
     6e6:	b76d                	j	690 <sim_opt+0x19e>

00000000000006e8 <main>:
// ============================================================================
// MAIN ENTRY POINT
// ============================================================================
int
main(int argc, char *argv[])
{
     6e8:	7175                	addi	sp,sp,-144
     6ea:	e506                	sd	ra,136(sp)
     6ec:	e122                	sd	s0,128(sp)
     6ee:	fca6                	sd	s1,120(sp)
     6f0:	f8ca                	sd	s2,112(sp)
     6f2:	f4ce                	sd	s3,104(sp)
     6f4:	f0d2                	sd	s4,96(sp)
     6f6:	ecd6                	sd	s5,88(sp)
     6f8:	e8da                	sd	s6,80(sp)
     6fa:	e4de                	sd	s7,72(sp)
     6fc:	e0e2                	sd	s8,64(sp)
     6fe:	fc66                	sd	s9,56(sp)
     700:	f86a                	sd	s10,48(sp)
     702:	f46e                	sd	s11,40(sp)
     704:	0900                	addi	s0,sp,144
  int faults, hits;

  printf("======================================================================\n");
     706:	00001517          	auipc	a0,0x1
     70a:	dfa50513          	addi	a0,a0,-518 # 1500 <malloc+0x302>
     70e:	239000ef          	jal	1146 <printf>
  printf("     Page Replacement Algorithms Simulation (FIFO, LRU, Optimal)      \n");
     712:	00001517          	auipc	a0,0x1
     716:	e3650513          	addi	a0,a0,-458 # 1548 <malloc+0x34a>
     71a:	22d000ef          	jal	1146 <printf>
  printf("======================================================================\n\n");
     71e:	00001517          	auipc	a0,0x1
     722:	e7250513          	addi	a0,a0,-398 # 1590 <malloc+0x392>
     726:	221000ef          	jal	1146 <printf>

  printf("Reference String (%d page requests):\n ", REF_LEN);
     72a:	45d1                	li	a1,20
     72c:	00001517          	auipc	a0,0x1
     730:	eb450513          	addi	a0,a0,-332 # 15e0 <malloc+0x3e2>
     734:	213000ef          	jal	1146 <printf>
  for (int i = 0; i < REF_LEN; i++) {
     738:	00001497          	auipc	s1,0x1
     73c:	5d848493          	addi	s1,s1,1496 # 1d10 <ref_string>
     740:	00001997          	auipc	s3,0x1
     744:	62098993          	addi	s3,s3,1568 # 1d60 <digits>
    printf("%d ", ref_string[i]);
     748:	00001917          	auipc	s2,0x1
     74c:	ec090913          	addi	s2,s2,-320 # 1608 <malloc+0x40a>
     750:	408c                	lw	a1,0(s1)
     752:	854a                	mv	a0,s2
     754:	1f3000ef          	jal	1146 <printf>
  for (int i = 0; i < REF_LEN; i++) {
     758:	0491                	addi	s1,s1,4
     75a:	ff349be3          	bne	s1,s3,750 <main+0x68>
  }
  printf("\n\n");
     75e:	00001517          	auipc	a0,0x1
     762:	cd250513          	addi	a0,a0,-814 # 1430 <malloc+0x232>
     766:	1e1000ef          	jal	1146 <printf>

  printf("======================================================================\n");
     76a:	00001517          	auipc	a0,0x1
     76e:	d9650513          	addi	a0,a0,-618 # 1500 <malloc+0x302>
     772:	1d5000ef          	jal	1146 <printf>
  printf("PART 1: Step-by-Step Simulation with 3 Physical Frames\n");
     776:	00001517          	auipc	a0,0x1
     77a:	e9a50513          	addi	a0,a0,-358 # 1610 <malloc+0x412>
     77e:	1c9000ef          	jal	1146 <printf>
  printf("======================================================================\n\n");
     782:	00001517          	auipc	a0,0x1
     786:	e0e50513          	addi	a0,a0,-498 # 1590 <malloc+0x392>
     78a:	1bd000ef          	jal	1146 <printf>

  sim_fifo(3, 1, &faults, &hits);
     78e:	f8840913          	addi	s2,s0,-120
     792:	f8c40493          	addi	s1,s0,-116
     796:	86ca                	mv	a3,s2
     798:	8626                	mv	a2,s1
     79a:	4585                	li	a1,1
     79c:	450d                	li	a0,3
     79e:	94fff0ef          	jal	ec <sim_fifo>
  sim_lru(3, 1, &faults, &hits);
     7a2:	86ca                	mv	a3,s2
     7a4:	8626                	mv	a2,s1
     7a6:	4585                	li	a1,1
     7a8:	450d                	li	a0,3
     7aa:	b45ff0ef          	jal	2ee <sim_lru>
  sim_opt(3, 1, &faults, &hits);
     7ae:	86ca                	mv	a3,s2
     7b0:	8626                	mv	a2,s1
     7b2:	4585                	li	a1,1
     7b4:	450d                	li	a0,3
     7b6:	d3dff0ef          	jal	4f2 <sim_opt>

  printf("======================================================================\n");
     7ba:	00001517          	auipc	a0,0x1
     7be:	d4650513          	addi	a0,a0,-698 # 1500 <malloc+0x302>
     7c2:	185000ef          	jal	1146 <printf>
  printf("PART 2: Multi-Frame Performance Comparison (3, 4, and 5 Frames)\n");
     7c6:	00001517          	auipc	a0,0x1
     7ca:	e8250513          	addi	a0,a0,-382 # 1648 <malloc+0x44a>
     7ce:	179000ef          	jal	1146 <printf>
  printf("======================================================================\n\n");
     7d2:	00001517          	auipc	a0,0x1
     7d6:	dbe50513          	addi	a0,a0,-578 # 1590 <malloc+0x392>
     7da:	16d000ef          	jal	1146 <printf>

  printf("+-----------+--------+-------------+-----------+-----------+------------+\n");
     7de:	00001517          	auipc	a0,0x1
     7e2:	eb250513          	addi	a0,a0,-334 # 1690 <malloc+0x492>
     7e6:	161000ef          	jal	1146 <printf>
  printf("| Algorithm | Frames | Page Faults | Page Hits | Hit Ratio | Fault Ratio|\n");
     7ea:	00001517          	auipc	a0,0x1
     7ee:	ef650513          	addi	a0,a0,-266 # 16e0 <malloc+0x4e2>
     7f2:	155000ef          	jal	1146 <printf>
  printf("+-----------+--------+-------------+-----------+-----------+------------+\n");
     7f6:	00001517          	auipc	a0,0x1
     7fa:	e9a50513          	addi	a0,a0,-358 # 1690 <malloc+0x492>
     7fe:	149000ef          	jal	1146 <printf>

  int frame_counts[] = {3, 4, 5};
     802:	478d                	li	a5,3
     804:	f6f42c23          	sw	a5,-136(s0)
     808:	4791                	li	a5,4
     80a:	f6f42e23          	sw	a5,-132(s0)
     80e:	4795                	li	a5,5
     810:	f8f42023          	sw	a5,-128(s0)
  for (int f = 0; f < 3; f++) {
     814:	f7840993          	addi	s3,s0,-136
     818:	f8440d93          	addi	s11,s0,-124
    int fc = frame_counts[f];

    // FIFO
    sim_fifo(fc, 0, &faults, &hits);
     81c:	8bca                	mv	s7,s2
     81e:	8b26                	mv	s6,s1
    printf("| FIFO      |   %d    |     %d      |    %d     |  ", fc, faults, hits);
     820:	00001d17          	auipc	s10,0x1
     824:	f10d0d13          	addi	s10,s10,-240 # 1730 <malloc+0x532>
    print_percentage(hits, REF_LEN);
     828:	4951                	li	s2,20
    printf("   |   ");
     82a:	00001a97          	auipc	s5,0x1
     82e:	f3ea8a93          	addi	s5,s5,-194 # 1768 <malloc+0x56a>
    print_percentage(faults, REF_LEN);
    printf("  |\n");
     832:	00001a17          	auipc	s4,0x1
     836:	f3ea0a13          	addi	s4,s4,-194 # 1770 <malloc+0x572>
    int fc = frame_counts[f];
     83a:	0009a483          	lw	s1,0(s3)
    sim_fifo(fc, 0, &faults, &hits);
     83e:	86de                	mv	a3,s7
     840:	865a                	mv	a2,s6
     842:	4581                	li	a1,0
     844:	8526                	mv	a0,s1
     846:	8a7ff0ef          	jal	ec <sim_fifo>
    printf("| FIFO      |   %d    |     %d      |    %d     |  ", fc, faults, hits);
     84a:	f8c42c03          	lw	s8,-116(s0)
     84e:	f8842c83          	lw	s9,-120(s0)
     852:	86e6                	mv	a3,s9
     854:	8662                	mv	a2,s8
     856:	85a6                	mv	a1,s1
     858:	856a                	mv	a0,s10
     85a:	0ed000ef          	jal	1146 <printf>
    print_percentage(hits, REF_LEN);
     85e:	85ca                	mv	a1,s2
     860:	8566                	mv	a0,s9
     862:	825ff0ef          	jal	86 <print_percentage>
    printf("   |   ");
     866:	8556                	mv	a0,s5
     868:	0df000ef          	jal	1146 <printf>
    print_percentage(faults, REF_LEN);
     86c:	85ca                	mv	a1,s2
     86e:	8562                	mv	a0,s8
     870:	817ff0ef          	jal	86 <print_percentage>
    printf("  |\n");
     874:	8552                	mv	a0,s4
     876:	0d1000ef          	jal	1146 <printf>

    // LRU
    sim_lru(fc, 0, &faults, &hits);
     87a:	86de                	mv	a3,s7
     87c:	865a                	mv	a2,s6
     87e:	4581                	li	a1,0
     880:	8526                	mv	a0,s1
     882:	a6dff0ef          	jal	2ee <sim_lru>
    printf("| LRU       |   %d    |     %d      |    %d     |  ", fc, faults, hits);
     886:	f8c42c03          	lw	s8,-116(s0)
     88a:	f8842c83          	lw	s9,-120(s0)
     88e:	86e6                	mv	a3,s9
     890:	8662                	mv	a2,s8
     892:	85a6                	mv	a1,s1
     894:	00001517          	auipc	a0,0x1
     898:	ee450513          	addi	a0,a0,-284 # 1778 <malloc+0x57a>
     89c:	0ab000ef          	jal	1146 <printf>
    print_percentage(hits, REF_LEN);
     8a0:	85ca                	mv	a1,s2
     8a2:	8566                	mv	a0,s9
     8a4:	fe2ff0ef          	jal	86 <print_percentage>
    printf("   |   ");
     8a8:	8556                	mv	a0,s5
     8aa:	09d000ef          	jal	1146 <printf>
    print_percentage(faults, REF_LEN);
     8ae:	85ca                	mv	a1,s2
     8b0:	8562                	mv	a0,s8
     8b2:	fd4ff0ef          	jal	86 <print_percentage>
    printf("  |\n");
     8b6:	8552                	mv	a0,s4
     8b8:	08f000ef          	jal	1146 <printf>

    // OPT
    sim_opt(fc, 0, &faults, &hits);
     8bc:	86de                	mv	a3,s7
     8be:	865a                	mv	a2,s6
     8c0:	4581                	li	a1,0
     8c2:	8526                	mv	a0,s1
     8c4:	c2fff0ef          	jal	4f2 <sim_opt>
    printf("| OPT       |   %d    |     %d      |    %d     |  ", fc, faults, hits);
     8c8:	f8c42c03          	lw	s8,-116(s0)
     8cc:	f8842c83          	lw	s9,-120(s0)
     8d0:	86e6                	mv	a3,s9
     8d2:	8662                	mv	a2,s8
     8d4:	85a6                	mv	a1,s1
     8d6:	00001517          	auipc	a0,0x1
     8da:	eda50513          	addi	a0,a0,-294 # 17b0 <malloc+0x5b2>
     8de:	069000ef          	jal	1146 <printf>
    print_percentage(hits, REF_LEN);
     8e2:	85ca                	mv	a1,s2
     8e4:	8566                	mv	a0,s9
     8e6:	fa0ff0ef          	jal	86 <print_percentage>
    printf("   |   ");
     8ea:	8556                	mv	a0,s5
     8ec:	05b000ef          	jal	1146 <printf>
    print_percentage(faults, REF_LEN);
     8f0:	85ca                	mv	a1,s2
     8f2:	8562                	mv	a0,s8
     8f4:	f92ff0ef          	jal	86 <print_percentage>
    printf("  |\n");
     8f8:	8552                	mv	a0,s4
     8fa:	04d000ef          	jal	1146 <printf>

    printf("+-----------+--------+-------------+-----------+-----------+------------+\n");
     8fe:	00001517          	auipc	a0,0x1
     902:	d9250513          	addi	a0,a0,-622 # 1690 <malloc+0x492>
     906:	041000ef          	jal	1146 <printf>
  for (int f = 0; f < 3; f++) {
     90a:	0991                	addi	s3,s3,4
     90c:	f3b997e3          	bne	s3,s11,83a <main+0x152>
  }

  printf("\n");
     910:	00001517          	auipc	a0,0x1
     914:	ed850513          	addi	a0,a0,-296 # 17e8 <malloc+0x5ea>
     918:	02f000ef          	jal	1146 <printf>
  printf("======================================================================\n");
     91c:	00001517          	auipc	a0,0x1
     920:	be450513          	addi	a0,a0,-1052 # 1500 <malloc+0x302>
     924:	023000ef          	jal	1146 <printf>
  printf("PART 3: Algorithm Performance Analysis and Conclusion\n");
     928:	00001517          	auipc	a0,0x1
     92c:	ec850513          	addi	a0,a0,-312 # 17f0 <malloc+0x5f2>
     930:	017000ef          	jal	1146 <printf>
  printf("======================================================================\n");
     934:	00001517          	auipc	a0,0x1
     938:	bcc50513          	addi	a0,a0,-1076 # 1500 <malloc+0x302>
     93c:	00b000ef          	jal	1146 <printf>
  printf("1. Optimal (OPT):\n");
     940:	00001517          	auipc	a0,0x1
     944:	ee850513          	addi	a0,a0,-280 # 1828 <malloc+0x62a>
     948:	7fe000ef          	jal	1146 <printf>
  printf("   - Achieved the lowest page faults across all frame sizes:\n");
     94c:	00001517          	auipc	a0,0x1
     950:	ef450513          	addi	a0,a0,-268 # 1840 <malloc+0x642>
     954:	7f2000ef          	jal	1146 <printf>
  printf("     9 faults (3 frames), 8 faults (4 frames), and 7 faults (5 frames).\n");
     958:	00001517          	auipc	a0,0x1
     95c:	f2850513          	addi	a0,a0,-216 # 1880 <malloc+0x682>
     960:	7e6000ef          	jal	1146 <printf>
  printf("   - Why: OPT looks ahead and replaces the page that will not be used\n");
     964:	00001517          	auipc	a0,0x1
     968:	f6c50513          	addi	a0,a0,-148 # 18d0 <malloc+0x6d2>
     96c:	7da000ef          	jal	1146 <printf>
  printf("     for the longest duration in the future. It is provably optimal and\n");
     970:	00001517          	auipc	a0,0x1
     974:	fa850513          	addi	a0,a0,-88 # 1918 <malloc+0x71a>
     978:	7ce000ef          	jal	1146 <printf>
  printf("     serves as the theoretical upper bound for hit ratio.\n\n");
     97c:	00001517          	auipc	a0,0x1
     980:	fec50513          	addi	a0,a0,-20 # 1968 <malloc+0x76a>
     984:	7c2000ef          	jal	1146 <printf>

  printf("2. Least Recently Used (LRU):\n");
     988:	00001517          	auipc	a0,0x1
     98c:	02050513          	addi	a0,a0,32 # 19a8 <malloc+0x7aa>
     990:	7b6000ef          	jal	1146 <printf>
  printf("   - Achieved 12 faults (3 frames), 8 faults (4 frames), and 7 faults (5 frames).\n");
     994:	00001517          	auipc	a0,0x1
     998:	03450513          	addi	a0,a0,52 # 19c8 <malloc+0x7ca>
     99c:	7aa000ef          	jal	1146 <printf>
  printf("   - Why: LRU leverages the Principle of Locality (specifically Temporal\n");
     9a0:	00001517          	auipc	a0,0x1
     9a4:	08050513          	addi	a0,a0,128 # 1a20 <malloc+0x822>
     9a8:	79e000ef          	jal	1146 <printf>
  printf("     Locality) by approximating future behavior with past recency.\n");
     9ac:	00001517          	auipc	a0,0x1
     9b0:	0c450513          	addi	a0,a0,196 # 1a70 <malloc+0x872>
     9b4:	792000ef          	jal	1146 <printf>
  printf("     At 4 and 5 frames, LRU matched the performance of OPT exactly!\n\n");
     9b8:	00001517          	auipc	a0,0x1
     9bc:	10050513          	addi	a0,a0,256 # 1ab8 <malloc+0x8ba>
     9c0:	786000ef          	jal	1146 <printf>

  printf("3. First-In, First-Out (FIFO):\n");
     9c4:	00001517          	auipc	a0,0x1
     9c8:	13c50513          	addi	a0,a0,316 # 1b00 <malloc+0x902>
     9cc:	77a000ef          	jal	1146 <printf>
  printf("   - Suffered the highest page faults:\n");
     9d0:	00001517          	auipc	a0,0x1
     9d4:	15050513          	addi	a0,a0,336 # 1b20 <malloc+0x922>
     9d8:	76e000ef          	jal	1146 <printf>
  printf("     15 faults (3 frames), 10 faults (4 frames), and 9 faults (5 frames).\n");
     9dc:	00001517          	auipc	a0,0x1
     9e0:	16c50513          	addi	a0,a0,364 # 1b48 <malloc+0x94a>
     9e4:	762000ef          	jal	1146 <printf>
  printf("   - Why: FIFO only considers the arrival order without accounting for\n");
     9e8:	00001517          	auipc	a0,0x1
     9ec:	1b050513          	addi	a0,a0,432 # 1b98 <malloc+0x99a>
     9f0:	756000ef          	jal	1146 <printf>
  printf("     frequency or recency of page accesses, evicting heavily used pages.\n\n");
     9f4:	00001517          	auipc	a0,0x1
     9f8:	1ec50513          	addi	a0,a0,492 # 1be0 <malloc+0x9e2>
     9fc:	74a000ef          	jal	1146 <printf>

  printf("Conclusion:\n");
     a00:	00001517          	auipc	a0,0x1
     a04:	23050513          	addi	a0,a0,560 # 1c30 <malloc+0xa32>
     a08:	73e000ef          	jal	1146 <printf>
  printf("  -> Optimal (OPT) performed best overall in minimizing page faults.\n");
     a0c:	00001517          	auipc	a0,0x1
     a10:	23450513          	addi	a0,a0,564 # 1c40 <malloc+0xa42>
     a14:	732000ef          	jal	1146 <printf>
  printf("  -> Among implementable online algorithms, LRU significantly outperformed\n");
     a18:	00001517          	auipc	a0,0x1
     a1c:	27050513          	addi	a0,a0,624 # 1c88 <malloc+0xa8a>
     a20:	726000ef          	jal	1146 <printf>
  printf("     FIFO, achieving up to 65.00%% hit ratio.\n");
     a24:	00001517          	auipc	a0,0x1
     a28:	2b450513          	addi	a0,a0,692 # 1cd8 <malloc+0xada>
     a2c:	71a000ef          	jal	1146 <printf>
  printf("======================================================================\n");
     a30:	00001517          	auipc	a0,0x1
     a34:	ad050513          	addi	a0,a0,-1328 # 1500 <malloc+0x302>
     a38:	70e000ef          	jal	1146 <printf>

  exit(0);
     a3c:	4501                	li	a0,0
     a3e:	2ba000ef          	jal	cf8 <exit>

0000000000000a42 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
     a42:	1141                	addi	sp,sp,-16
     a44:	e406                	sd	ra,8(sp)
     a46:	e022                	sd	s0,0(sp)
     a48:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
     a4a:	c9fff0ef          	jal	6e8 <main>
  exit(r);
     a4e:	2aa000ef          	jal	cf8 <exit>

0000000000000a52 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
     a52:	1141                	addi	sp,sp,-16
     a54:	e406                	sd	ra,8(sp)
     a56:	e022                	sd	s0,0(sp)
     a58:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
     a5a:	87aa                	mv	a5,a0
     a5c:	0585                	addi	a1,a1,1
     a5e:	0785                	addi	a5,a5,1
     a60:	fff5c703          	lbu	a4,-1(a1)
     a64:	fee78fa3          	sb	a4,-1(a5)
     a68:	fb75                	bnez	a4,a5c <strcpy+0xa>
    ;
  return os;
}
     a6a:	60a2                	ld	ra,8(sp)
     a6c:	6402                	ld	s0,0(sp)
     a6e:	0141                	addi	sp,sp,16
     a70:	8082                	ret

0000000000000a72 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     a72:	1141                	addi	sp,sp,-16
     a74:	e406                	sd	ra,8(sp)
     a76:	e022                	sd	s0,0(sp)
     a78:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
     a7a:	00054783          	lbu	a5,0(a0)
     a7e:	cb91                	beqz	a5,a92 <strcmp+0x20>
     a80:	0005c703          	lbu	a4,0(a1)
     a84:	00f71763          	bne	a4,a5,a92 <strcmp+0x20>
    p++, q++;
     a88:	0505                	addi	a0,a0,1
     a8a:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
     a8c:	00054783          	lbu	a5,0(a0)
     a90:	fbe5                	bnez	a5,a80 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
     a92:	0005c503          	lbu	a0,0(a1)
}
     a96:	40a7853b          	subw	a0,a5,a0
     a9a:	60a2                	ld	ra,8(sp)
     a9c:	6402                	ld	s0,0(sp)
     a9e:	0141                	addi	sp,sp,16
     aa0:	8082                	ret

0000000000000aa2 <strlen>:

uint
strlen(const char *s)
{
     aa2:	1141                	addi	sp,sp,-16
     aa4:	e406                	sd	ra,8(sp)
     aa6:	e022                	sd	s0,0(sp)
     aa8:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
     aaa:	00054783          	lbu	a5,0(a0)
     aae:	cf91                	beqz	a5,aca <strlen+0x28>
     ab0:	00150793          	addi	a5,a0,1
     ab4:	86be                	mv	a3,a5
     ab6:	0785                	addi	a5,a5,1
     ab8:	fff7c703          	lbu	a4,-1(a5)
     abc:	ff65                	bnez	a4,ab4 <strlen+0x12>
     abe:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
     ac2:	60a2                	ld	ra,8(sp)
     ac4:	6402                	ld	s0,0(sp)
     ac6:	0141                	addi	sp,sp,16
     ac8:	8082                	ret
  for (n = 0; s[n]; n++)
     aca:	4501                	li	a0,0
     acc:	bfdd                	j	ac2 <strlen+0x20>

0000000000000ace <memset>:

void *
memset(void *dst, int c, uint n)
{
     ace:	1141                	addi	sp,sp,-16
     ad0:	e406                	sd	ra,8(sp)
     ad2:	e022                	sd	s0,0(sp)
     ad4:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
     ad6:	ca19                	beqz	a2,aec <memset+0x1e>
     ad8:	87aa                	mv	a5,a0
     ada:	1602                	slli	a2,a2,0x20
     adc:	9201                	srli	a2,a2,0x20
     ade:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     ae2:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
     ae6:	0785                	addi	a5,a5,1
     ae8:	fee79de3          	bne	a5,a4,ae2 <memset+0x14>
  }
  return dst;
}
     aec:	60a2                	ld	ra,8(sp)
     aee:	6402                	ld	s0,0(sp)
     af0:	0141                	addi	sp,sp,16
     af2:	8082                	ret

0000000000000af4 <strchr>:

char *
strchr(const char *s, char c)
{
     af4:	1141                	addi	sp,sp,-16
     af6:	e406                	sd	ra,8(sp)
     af8:	e022                	sd	s0,0(sp)
     afa:	0800                	addi	s0,sp,16
  for (; *s; s++)
     afc:	00054783          	lbu	a5,0(a0)
     b00:	cf81                	beqz	a5,b18 <strchr+0x24>
    if (*s == c)
     b02:	00f58763          	beq	a1,a5,b10 <strchr+0x1c>
  for (; *s; s++)
     b06:	0505                	addi	a0,a0,1
     b08:	00054783          	lbu	a5,0(a0)
     b0c:	fbfd                	bnez	a5,b02 <strchr+0xe>
      return (char *)s;
  return 0;
     b0e:	4501                	li	a0,0
}
     b10:	60a2                	ld	ra,8(sp)
     b12:	6402                	ld	s0,0(sp)
     b14:	0141                	addi	sp,sp,16
     b16:	8082                	ret
  return 0;
     b18:	4501                	li	a0,0
     b1a:	bfdd                	j	b10 <strchr+0x1c>

0000000000000b1c <gets>:

char *
gets(char *buf, int max)
{
     b1c:	711d                	addi	sp,sp,-96
     b1e:	ec86                	sd	ra,88(sp)
     b20:	e8a2                	sd	s0,80(sp)
     b22:	e4a6                	sd	s1,72(sp)
     b24:	e0ca                	sd	s2,64(sp)
     b26:	fc4e                	sd	s3,56(sp)
     b28:	f852                	sd	s4,48(sp)
     b2a:	f456                	sd	s5,40(sp)
     b2c:	f05a                	sd	s6,32(sp)
     b2e:	ec5e                	sd	s7,24(sp)
     b30:	e862                	sd	s8,16(sp)
     b32:	1080                	addi	s0,sp,96
     b34:	8baa                	mv	s7,a0
     b36:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
     b38:	892a                	mv	s2,a0
     b3a:	4481                	li	s1,0
    cc = read(0, &c, 1);
     b3c:	faf40b13          	addi	s6,s0,-81
     b40:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
     b42:	8c26                	mv	s8,s1
     b44:	0014899b          	addiw	s3,s1,1
     b48:	84ce                	mv	s1,s3
     b4a:	0349d463          	bge	s3,s4,b72 <gets+0x56>
    cc = read(0, &c, 1);
     b4e:	8656                	mv	a2,s5
     b50:	85da                	mv	a1,s6
     b52:	4501                	li	a0,0
     b54:	1bc000ef          	jal	d10 <read>
    if (cc < 1)
     b58:	00a05d63          	blez	a0,b72 <gets+0x56>
      break;
    buf[i++] = c;
     b5c:	faf44783          	lbu	a5,-81(s0)
     b60:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
     b64:	0905                	addi	s2,s2,1
     b66:	ff678713          	addi	a4,a5,-10
     b6a:	c319                	beqz	a4,b70 <gets+0x54>
     b6c:	17cd                	addi	a5,a5,-13
     b6e:	fbf1                	bnez	a5,b42 <gets+0x26>
    buf[i++] = c;
     b70:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
     b72:	9c5e                	add	s8,s8,s7
     b74:	000c0023          	sb	zero,0(s8)
  return buf;
}
     b78:	855e                	mv	a0,s7
     b7a:	60e6                	ld	ra,88(sp)
     b7c:	6446                	ld	s0,80(sp)
     b7e:	64a6                	ld	s1,72(sp)
     b80:	6906                	ld	s2,64(sp)
     b82:	79e2                	ld	s3,56(sp)
     b84:	7a42                	ld	s4,48(sp)
     b86:	7aa2                	ld	s5,40(sp)
     b88:	7b02                	ld	s6,32(sp)
     b8a:	6be2                	ld	s7,24(sp)
     b8c:	6c42                	ld	s8,16(sp)
     b8e:	6125                	addi	sp,sp,96
     b90:	8082                	ret

0000000000000b92 <stat>:

int
stat(const char *n, struct stat *st)
{
     b92:	1101                	addi	sp,sp,-32
     b94:	ec06                	sd	ra,24(sp)
     b96:	e822                	sd	s0,16(sp)
     b98:	e04a                	sd	s2,0(sp)
     b9a:	1000                	addi	s0,sp,32
     b9c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     b9e:	4581                	li	a1,0
     ba0:	198000ef          	jal	d38 <open>
  if (fd < 0)
     ba4:	02054263          	bltz	a0,bc8 <stat+0x36>
     ba8:	e426                	sd	s1,8(sp)
     baa:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     bac:	85ca                	mv	a1,s2
     bae:	1a2000ef          	jal	d50 <fstat>
     bb2:	892a                	mv	s2,a0
  close(fd);
     bb4:	8526                	mv	a0,s1
     bb6:	16a000ef          	jal	d20 <close>
  return r;
     bba:	64a2                	ld	s1,8(sp)
}
     bbc:	854a                	mv	a0,s2
     bbe:	60e2                	ld	ra,24(sp)
     bc0:	6442                	ld	s0,16(sp)
     bc2:	6902                	ld	s2,0(sp)
     bc4:	6105                	addi	sp,sp,32
     bc6:	8082                	ret
    return -1;
     bc8:	57fd                	li	a5,-1
     bca:	893e                	mv	s2,a5
     bcc:	bfc5                	j	bbc <stat+0x2a>

0000000000000bce <atoi>:

int
atoi(const char *s)
{
     bce:	1141                	addi	sp,sp,-16
     bd0:	e406                	sd	ra,8(sp)
     bd2:	e022                	sd	s0,0(sp)
     bd4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
     bd6:	00054683          	lbu	a3,0(a0)
     bda:	fd06879b          	addiw	a5,a3,-48
     bde:	0ff7f793          	zext.b	a5,a5
     be2:	4625                	li	a2,9
     be4:	02f66963          	bltu	a2,a5,c16 <atoi+0x48>
     be8:	872a                	mv	a4,a0
  n = 0;
     bea:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
     bec:	0705                	addi	a4,a4,1
     bee:	0025179b          	slliw	a5,a0,0x2
     bf2:	9fa9                	addw	a5,a5,a0
     bf4:	0017979b          	slliw	a5,a5,0x1
     bf8:	9fb5                	addw	a5,a5,a3
     bfa:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
     bfe:	00074683          	lbu	a3,0(a4)
     c02:	fd06879b          	addiw	a5,a3,-48
     c06:	0ff7f793          	zext.b	a5,a5
     c0a:	fef671e3          	bgeu	a2,a5,bec <atoi+0x1e>
  return n;
}
     c0e:	60a2                	ld	ra,8(sp)
     c10:	6402                	ld	s0,0(sp)
     c12:	0141                	addi	sp,sp,16
     c14:	8082                	ret
  n = 0;
     c16:	4501                	li	a0,0
     c18:	bfdd                	j	c0e <atoi+0x40>

0000000000000c1a <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
     c1a:	1141                	addi	sp,sp,-16
     c1c:	e406                	sd	ra,8(sp)
     c1e:	e022                	sd	s0,0(sp)
     c20:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     c22:	02b57563          	bgeu	a0,a1,c4c <memmove+0x32>
    while (n-- > 0)
     c26:	00c05f63          	blez	a2,c44 <memmove+0x2a>
     c2a:	1602                	slli	a2,a2,0x20
     c2c:	9201                	srli	a2,a2,0x20
     c2e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     c32:	872a                	mv	a4,a0
      *dst++ = *src++;
     c34:	0585                	addi	a1,a1,1
     c36:	0705                	addi	a4,a4,1
     c38:	fff5c683          	lbu	a3,-1(a1)
     c3c:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
     c40:	fee79ae3          	bne	a5,a4,c34 <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     c44:	60a2                	ld	ra,8(sp)
     c46:	6402                	ld	s0,0(sp)
     c48:	0141                	addi	sp,sp,16
     c4a:	8082                	ret
    while (n-- > 0)
     c4c:	fec05ce3          	blez	a2,c44 <memmove+0x2a>
    dst += n;
     c50:	00c50733          	add	a4,a0,a2
    src += n;
     c54:	95b2                	add	a1,a1,a2
     c56:	fff6079b          	addiw	a5,a2,-1
     c5a:	1782                	slli	a5,a5,0x20
     c5c:	9381                	srli	a5,a5,0x20
     c5e:	fff7c793          	not	a5,a5
     c62:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     c64:	15fd                	addi	a1,a1,-1
     c66:	177d                	addi	a4,a4,-1
     c68:	0005c683          	lbu	a3,0(a1)
     c6c:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
     c70:	fef71ae3          	bne	a4,a5,c64 <memmove+0x4a>
     c74:	bfc1                	j	c44 <memmove+0x2a>

0000000000000c76 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     c76:	1141                	addi	sp,sp,-16
     c78:	e406                	sd	ra,8(sp)
     c7a:	e022                	sd	s0,0(sp)
     c7c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     c7e:	c61d                	beqz	a2,cac <memcmp+0x36>
     c80:	1602                	slli	a2,a2,0x20
     c82:	9201                	srli	a2,a2,0x20
     c84:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
     c88:	00054783          	lbu	a5,0(a0)
     c8c:	0005c703          	lbu	a4,0(a1)
     c90:	00e79863          	bne	a5,a4,ca0 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
     c94:	0505                	addi	a0,a0,1
    p2++;
     c96:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     c98:	fed518e3          	bne	a0,a3,c88 <memcmp+0x12>
  }
  return 0;
     c9c:	4501                	li	a0,0
     c9e:	a019                	j	ca4 <memcmp+0x2e>
      return *p1 - *p2;
     ca0:	40e7853b          	subw	a0,a5,a4
}
     ca4:	60a2                	ld	ra,8(sp)
     ca6:	6402                	ld	s0,0(sp)
     ca8:	0141                	addi	sp,sp,16
     caa:	8082                	ret
  return 0;
     cac:	4501                	li	a0,0
     cae:	bfdd                	j	ca4 <memcmp+0x2e>

0000000000000cb0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     cb0:	1141                	addi	sp,sp,-16
     cb2:	e406                	sd	ra,8(sp)
     cb4:	e022                	sd	s0,0(sp)
     cb6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     cb8:	f63ff0ef          	jal	c1a <memmove>
}
     cbc:	60a2                	ld	ra,8(sp)
     cbe:	6402                	ld	s0,0(sp)
     cc0:	0141                	addi	sp,sp,16
     cc2:	8082                	ret

0000000000000cc4 <sbrk>:

char *
sbrk(int n)
{
     cc4:	1141                	addi	sp,sp,-16
     cc6:	e406                	sd	ra,8(sp)
     cc8:	e022                	sd	s0,0(sp)
     cca:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
     ccc:	4585                	li	a1,1
     cce:	0b2000ef          	jal	d80 <sys_sbrk>
}
     cd2:	60a2                	ld	ra,8(sp)
     cd4:	6402                	ld	s0,0(sp)
     cd6:	0141                	addi	sp,sp,16
     cd8:	8082                	ret

0000000000000cda <sbrklazy>:

char *
sbrklazy(int n)
{
     cda:	1141                	addi	sp,sp,-16
     cdc:	e406                	sd	ra,8(sp)
     cde:	e022                	sd	s0,0(sp)
     ce0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
     ce2:	4589                	li	a1,2
     ce4:	09c000ef          	jal	d80 <sys_sbrk>
}
     ce8:	60a2                	ld	ra,8(sp)
     cea:	6402                	ld	s0,0(sp)
     cec:	0141                	addi	sp,sp,16
     cee:	8082                	ret

0000000000000cf0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     cf0:	4885                	li	a7,1
 ecall
     cf2:	00000073          	ecall
 ret
     cf6:	8082                	ret

0000000000000cf8 <exit>:
.global exit
exit:
 li a7, SYS_exit
     cf8:	4889                	li	a7,2
 ecall
     cfa:	00000073          	ecall
 ret
     cfe:	8082                	ret

0000000000000d00 <wait>:
.global wait
wait:
 li a7, SYS_wait
     d00:	488d                	li	a7,3
 ecall
     d02:	00000073          	ecall
 ret
     d06:	8082                	ret

0000000000000d08 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     d08:	4891                	li	a7,4
 ecall
     d0a:	00000073          	ecall
 ret
     d0e:	8082                	ret

0000000000000d10 <read>:
.global read
read:
 li a7, SYS_read
     d10:	4895                	li	a7,5
 ecall
     d12:	00000073          	ecall
 ret
     d16:	8082                	ret

0000000000000d18 <write>:
.global write
write:
 li a7, SYS_write
     d18:	48c1                	li	a7,16
 ecall
     d1a:	00000073          	ecall
 ret
     d1e:	8082                	ret

0000000000000d20 <close>:
.global close
close:
 li a7, SYS_close
     d20:	48d5                	li	a7,21
 ecall
     d22:	00000073          	ecall
 ret
     d26:	8082                	ret

0000000000000d28 <kill>:
.global kill
kill:
 li a7, SYS_kill
     d28:	4899                	li	a7,6
 ecall
     d2a:	00000073          	ecall
 ret
     d2e:	8082                	ret

0000000000000d30 <exec>:
.global exec
exec:
 li a7, SYS_exec
     d30:	489d                	li	a7,7
 ecall
     d32:	00000073          	ecall
 ret
     d36:	8082                	ret

0000000000000d38 <open>:
.global open
open:
 li a7, SYS_open
     d38:	48bd                	li	a7,15
 ecall
     d3a:	00000073          	ecall
 ret
     d3e:	8082                	ret

0000000000000d40 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     d40:	48c5                	li	a7,17
 ecall
     d42:	00000073          	ecall
 ret
     d46:	8082                	ret

0000000000000d48 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     d48:	48c9                	li	a7,18
 ecall
     d4a:	00000073          	ecall
 ret
     d4e:	8082                	ret

0000000000000d50 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     d50:	48a1                	li	a7,8
 ecall
     d52:	00000073          	ecall
 ret
     d56:	8082                	ret

0000000000000d58 <link>:
.global link
link:
 li a7, SYS_link
     d58:	48cd                	li	a7,19
 ecall
     d5a:	00000073          	ecall
 ret
     d5e:	8082                	ret

0000000000000d60 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     d60:	48d1                	li	a7,20
 ecall
     d62:	00000073          	ecall
 ret
     d66:	8082                	ret

0000000000000d68 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     d68:	48a5                	li	a7,9
 ecall
     d6a:	00000073          	ecall
 ret
     d6e:	8082                	ret

0000000000000d70 <dup>:
.global dup
dup:
 li a7, SYS_dup
     d70:	48a9                	li	a7,10
 ecall
     d72:	00000073          	ecall
 ret
     d76:	8082                	ret

0000000000000d78 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     d78:	48ad                	li	a7,11
 ecall
     d7a:	00000073          	ecall
 ret
     d7e:	8082                	ret

0000000000000d80 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
     d80:	48b1                	li	a7,12
 ecall
     d82:	00000073          	ecall
 ret
     d86:	8082                	ret

0000000000000d88 <pause>:
.global pause
pause:
 li a7, SYS_pause
     d88:	48b5                	li	a7,13
 ecall
     d8a:	00000073          	ecall
 ret
     d8e:	8082                	ret

0000000000000d90 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     d90:	48b9                	li	a7,14
 ecall
     d92:	00000073          	ecall
 ret
     d96:	8082                	ret

0000000000000d98 <sync>:
.global sync
sync:
 li a7, SYS_sync
     d98:	48d9                	li	a7,22
 ecall
     d9a:	00000073          	ecall
 ret
     d9e:	8082                	ret

0000000000000da0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     da0:	1101                	addi	sp,sp,-32
     da2:	ec06                	sd	ra,24(sp)
     da4:	e822                	sd	s0,16(sp)
     da6:	1000                	addi	s0,sp,32
     da8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     dac:	4605                	li	a2,1
     dae:	fef40593          	addi	a1,s0,-17
     db2:	f67ff0ef          	jal	d18 <write>
}
     db6:	60e2                	ld	ra,24(sp)
     db8:	6442                	ld	s0,16(sp)
     dba:	6105                	addi	sp,sp,32
     dbc:	8082                	ret

0000000000000dbe <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
     dbe:	715d                	addi	sp,sp,-80
     dc0:	e486                	sd	ra,72(sp)
     dc2:	e0a2                	sd	s0,64(sp)
     dc4:	f84a                	sd	s2,48(sp)
     dc6:	f44e                	sd	s3,40(sp)
     dc8:	0880                	addi	s0,sp,80
     dca:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
     dcc:	c6d1                	beqz	a3,e58 <printint+0x9a>
     dce:	0805d563          	bgez	a1,e58 <printint+0x9a>
    neg = 1;
    x = -xx;
     dd2:	40b005b3          	neg	a1,a1
    neg = 1;
     dd6:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
     dd8:	fb840993          	addi	s3,s0,-72
  neg = 0;
     ddc:	86ce                	mv	a3,s3
  i = 0;
     dde:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
     de0:	00001817          	auipc	a6,0x1
     de4:	f8080813          	addi	a6,a6,-128 # 1d60 <digits>
     de8:	88ba                	mv	a7,a4
     dea:	0017051b          	addiw	a0,a4,1
     dee:	872a                	mv	a4,a0
     df0:	02c5f7b3          	remu	a5,a1,a2
     df4:	97c2                	add	a5,a5,a6
     df6:	0007c783          	lbu	a5,0(a5)
     dfa:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
     dfe:	87ae                	mv	a5,a1
     e00:	02c5d5b3          	divu	a1,a1,a2
     e04:	0685                	addi	a3,a3,1
     e06:	fec7f1e3          	bgeu	a5,a2,de8 <printint+0x2a>
  if (neg)
     e0a:	00030c63          	beqz	t1,e22 <printint+0x64>
    buf[i++] = '-';
     e0e:	fd050793          	addi	a5,a0,-48
     e12:	00878533          	add	a0,a5,s0
     e16:	02d00793          	li	a5,45
     e1a:	fef50423          	sb	a5,-24(a0)
     e1e:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
     e22:	02e05563          	blez	a4,e4c <printint+0x8e>
     e26:	fc26                	sd	s1,56(sp)
     e28:	377d                	addiw	a4,a4,-1
     e2a:	00e984b3          	add	s1,s3,a4
     e2e:	19fd                	addi	s3,s3,-1
     e30:	99ba                	add	s3,s3,a4
     e32:	1702                	slli	a4,a4,0x20
     e34:	9301                	srli	a4,a4,0x20
     e36:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     e3a:	0004c583          	lbu	a1,0(s1)
     e3e:	854a                	mv	a0,s2
     e40:	f61ff0ef          	jal	da0 <putc>
  while (--i >= 0)
     e44:	14fd                	addi	s1,s1,-1
     e46:	ff349ae3          	bne	s1,s3,e3a <printint+0x7c>
     e4a:	74e2                	ld	s1,56(sp)
}
     e4c:	60a6                	ld	ra,72(sp)
     e4e:	6406                	ld	s0,64(sp)
     e50:	7942                	ld	s2,48(sp)
     e52:	79a2                	ld	s3,40(sp)
     e54:	6161                	addi	sp,sp,80
     e56:	8082                	ret
  neg = 0;
     e58:	4301                	li	t1,0
     e5a:	bfbd                	j	dd8 <printint+0x1a>

0000000000000e5c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     e5c:	711d                	addi	sp,sp,-96
     e5e:	ec86                	sd	ra,88(sp)
     e60:	e8a2                	sd	s0,80(sp)
     e62:	e4a6                	sd	s1,72(sp)
     e64:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
     e66:	0005c483          	lbu	s1,0(a1)
     e6a:	22048363          	beqz	s1,1090 <vprintf+0x234>
     e6e:	e0ca                	sd	s2,64(sp)
     e70:	fc4e                	sd	s3,56(sp)
     e72:	f852                	sd	s4,48(sp)
     e74:	f456                	sd	s5,40(sp)
     e76:	f05a                	sd	s6,32(sp)
     e78:	ec5e                	sd	s7,24(sp)
     e7a:	e862                	sd	s8,16(sp)
     e7c:	8b2a                	mv	s6,a0
     e7e:	8a2e                	mv	s4,a1
     e80:	8bb2                	mv	s7,a2
  state = 0;
     e82:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
     e84:	4901                	li	s2,0
     e86:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
     e88:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
     e8c:	06400c13          	li	s8,100
     e90:	a00d                	j	eb2 <vprintf+0x56>
        putc(fd, c0);
     e92:	85a6                	mv	a1,s1
     e94:	855a                	mv	a0,s6
     e96:	f0bff0ef          	jal	da0 <putc>
     e9a:	a019                	j	ea0 <vprintf+0x44>
    } else if (state == '%') {
     e9c:	03598363          	beq	s3,s5,ec2 <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
     ea0:	0019079b          	addiw	a5,s2,1
     ea4:	893e                	mv	s2,a5
     ea6:	873e                	mv	a4,a5
     ea8:	97d2                	add	a5,a5,s4
     eaa:	0007c483          	lbu	s1,0(a5)
     eae:	1c048a63          	beqz	s1,1082 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
     eb2:	0004879b          	sext.w	a5,s1
    if (state == 0) {
     eb6:	fe0993e3          	bnez	s3,e9c <vprintf+0x40>
      if (c0 == '%') {
     eba:	fd579ce3          	bne	a5,s5,e92 <vprintf+0x36>
        state = '%';
     ebe:	89be                	mv	s3,a5
     ec0:	b7c5                	j	ea0 <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
     ec2:	00ea06b3          	add	a3,s4,a4
     ec6:	0016c603          	lbu	a2,1(a3)
      if (c1)
     eca:	1c060863          	beqz	a2,109a <vprintf+0x23e>
      if (c0 == 'd') {
     ece:	03878763          	beq	a5,s8,efc <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
     ed2:	f9478693          	addi	a3,a5,-108
     ed6:	0016b693          	seqz	a3,a3
     eda:	f9c60593          	addi	a1,a2,-100
     ede:	e99d                	bnez	a1,f14 <vprintf+0xb8>
     ee0:	ca95                	beqz	a3,f14 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
     ee2:	008b8493          	addi	s1,s7,8
     ee6:	4685                	li	a3,1
     ee8:	4629                	li	a2,10
     eea:	000bb583          	ld	a1,0(s7)
     eee:	855a                	mv	a0,s6
     ef0:	ecfff0ef          	jal	dbe <printint>
        i += 1;
     ef4:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
     ef6:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
     ef8:	4981                	li	s3,0
     efa:	b75d                	j	ea0 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
     efc:	008b8493          	addi	s1,s7,8
     f00:	4685                	li	a3,1
     f02:	4629                	li	a2,10
     f04:	000ba583          	lw	a1,0(s7)
     f08:	855a                	mv	a0,s6
     f0a:	eb5ff0ef          	jal	dbe <printint>
     f0e:	8ba6                	mv	s7,s1
      state = 0;
     f10:	4981                	li	s3,0
     f12:	b779                	j	ea0 <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
     f14:	9752                	add	a4,a4,s4
     f16:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
     f1a:	f9460713          	addi	a4,a2,-108
     f1e:	00173713          	seqz	a4,a4
     f22:	8f75                	and	a4,a4,a3
     f24:	f9c58513          	addi	a0,a1,-100
     f28:	18051363          	bnez	a0,10ae <vprintf+0x252>
     f2c:	18070163          	beqz	a4,10ae <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
     f30:	008b8493          	addi	s1,s7,8
     f34:	4685                	li	a3,1
     f36:	4629                	li	a2,10
     f38:	000bb583          	ld	a1,0(s7)
     f3c:	855a                	mv	a0,s6
     f3e:	e81ff0ef          	jal	dbe <printint>
        i += 2;
     f42:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
     f44:	8ba6                	mv	s7,s1
      state = 0;
     f46:	4981                	li	s3,0
        i += 2;
     f48:	bfa1                	j	ea0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
     f4a:	008b8493          	addi	s1,s7,8
     f4e:	4681                	li	a3,0
     f50:	4629                	li	a2,10
     f52:	000be583          	lwu	a1,0(s7)
     f56:	855a                	mv	a0,s6
     f58:	e67ff0ef          	jal	dbe <printint>
     f5c:	8ba6                	mv	s7,s1
      state = 0;
     f5e:	4981                	li	s3,0
     f60:	b781                	j	ea0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
     f62:	008b8493          	addi	s1,s7,8
     f66:	4681                	li	a3,0
     f68:	4629                	li	a2,10
     f6a:	000bb583          	ld	a1,0(s7)
     f6e:	855a                	mv	a0,s6
     f70:	e4fff0ef          	jal	dbe <printint>
        i += 1;
     f74:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
     f76:	8ba6                	mv	s7,s1
      state = 0;
     f78:	4981                	li	s3,0
     f7a:	b71d                	j	ea0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
     f7c:	008b8493          	addi	s1,s7,8
     f80:	4681                	li	a3,0
     f82:	4629                	li	a2,10
     f84:	000bb583          	ld	a1,0(s7)
     f88:	855a                	mv	a0,s6
     f8a:	e35ff0ef          	jal	dbe <printint>
        i += 2;
     f8e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
     f90:	8ba6                	mv	s7,s1
      state = 0;
     f92:	4981                	li	s3,0
        i += 2;
     f94:	b731                	j	ea0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
     f96:	008b8493          	addi	s1,s7,8
     f9a:	4681                	li	a3,0
     f9c:	4641                	li	a2,16
     f9e:	000be583          	lwu	a1,0(s7)
     fa2:	855a                	mv	a0,s6
     fa4:	e1bff0ef          	jal	dbe <printint>
     fa8:	8ba6                	mv	s7,s1
      state = 0;
     faa:	4981                	li	s3,0
     fac:	bdd5                	j	ea0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
     fae:	008b8493          	addi	s1,s7,8
     fb2:	4681                	li	a3,0
     fb4:	4641                	li	a2,16
     fb6:	000bb583          	ld	a1,0(s7)
     fba:	855a                	mv	a0,s6
     fbc:	e03ff0ef          	jal	dbe <printint>
        i += 1;
     fc0:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
     fc2:	8ba6                	mv	s7,s1
      state = 0;
     fc4:	4981                	li	s3,0
     fc6:	bde9                	j	ea0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
     fc8:	008b8493          	addi	s1,s7,8
     fcc:	4681                	li	a3,0
     fce:	4641                	li	a2,16
     fd0:	000bb583          	ld	a1,0(s7)
     fd4:	855a                	mv	a0,s6
     fd6:	de9ff0ef          	jal	dbe <printint>
        i += 2;
     fda:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
     fdc:	8ba6                	mv	s7,s1
      state = 0;
     fde:	4981                	li	s3,0
        i += 2;
     fe0:	b5c1                	j	ea0 <vprintf+0x44>
     fe2:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
     fe4:	008b8793          	addi	a5,s7,8
     fe8:	8cbe                	mv	s9,a5
     fea:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
     fee:	03000593          	li	a1,48
     ff2:	855a                	mv	a0,s6
     ff4:	dadff0ef          	jal	da0 <putc>
  putc(fd, 'x');
     ff8:	07800593          	li	a1,120
     ffc:	855a                	mv	a0,s6
     ffe:	da3ff0ef          	jal	da0 <putc>
    1002:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1004:	00001b97          	auipc	s7,0x1
    1008:	d5cb8b93          	addi	s7,s7,-676 # 1d60 <digits>
    100c:	03c9d793          	srli	a5,s3,0x3c
    1010:	97de                	add	a5,a5,s7
    1012:	0007c583          	lbu	a1,0(a5)
    1016:	855a                	mv	a0,s6
    1018:	d89ff0ef          	jal	da0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    101c:	0992                	slli	s3,s3,0x4
    101e:	34fd                	addiw	s1,s1,-1
    1020:	f4f5                	bnez	s1,100c <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
    1022:	8be6                	mv	s7,s9
      state = 0;
    1024:	4981                	li	s3,0
    1026:	6ca2                	ld	s9,8(sp)
    1028:	bda5                	j	ea0 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
    102a:	008b8493          	addi	s1,s7,8
    102e:	000bc583          	lbu	a1,0(s7)
    1032:	855a                	mv	a0,s6
    1034:	d6dff0ef          	jal	da0 <putc>
    1038:	8ba6                	mv	s7,s1
      state = 0;
    103a:	4981                	li	s3,0
    103c:	b595                	j	ea0 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
    103e:	008b8993          	addi	s3,s7,8
    1042:	000bb483          	ld	s1,0(s7)
    1046:	cc91                	beqz	s1,1062 <vprintf+0x206>
        for (; *s; s++)
    1048:	0004c583          	lbu	a1,0(s1)
    104c:	c985                	beqz	a1,107c <vprintf+0x220>
          putc(fd, *s);
    104e:	855a                	mv	a0,s6
    1050:	d51ff0ef          	jal	da0 <putc>
        for (; *s; s++)
    1054:	0485                	addi	s1,s1,1
    1056:	0004c583          	lbu	a1,0(s1)
    105a:	f9f5                	bnez	a1,104e <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
    105c:	8bce                	mv	s7,s3
      state = 0;
    105e:	4981                	li	s3,0
    1060:	b581                	j	ea0 <vprintf+0x44>
          s = "(null)";
    1062:	00001497          	auipc	s1,0x1
    1066:	ca648493          	addi	s1,s1,-858 # 1d08 <malloc+0xb0a>
        for (; *s; s++)
    106a:	02800593          	li	a1,40
    106e:	b7c5                	j	104e <vprintf+0x1f2>
        putc(fd, '%');
    1070:	85be                	mv	a1,a5
    1072:	855a                	mv	a0,s6
    1074:	d2dff0ef          	jal	da0 <putc>
      state = 0;
    1078:	4981                	li	s3,0
    107a:	b51d                	j	ea0 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
    107c:	8bce                	mv	s7,s3
      state = 0;
    107e:	4981                	li	s3,0
    1080:	b505                	j	ea0 <vprintf+0x44>
    1082:	6906                	ld	s2,64(sp)
    1084:	79e2                	ld	s3,56(sp)
    1086:	7a42                	ld	s4,48(sp)
    1088:	7aa2                	ld	s5,40(sp)
    108a:	7b02                	ld	s6,32(sp)
    108c:	6be2                	ld	s7,24(sp)
    108e:	6c42                	ld	s8,16(sp)
    }
  }
}
    1090:	60e6                	ld	ra,88(sp)
    1092:	6446                	ld	s0,80(sp)
    1094:	64a6                	ld	s1,72(sp)
    1096:	6125                	addi	sp,sp,96
    1098:	8082                	ret
      if (c0 == 'd') {
    109a:	06400713          	li	a4,100
    109e:	e4e78fe3          	beq	a5,a4,efc <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
    10a2:	f9478693          	addi	a3,a5,-108
    10a6:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
    10aa:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    10ac:	4701                	li	a4,0
      } else if (c0 == 'u') {
    10ae:	07500513          	li	a0,117
    10b2:	e8a78ce3          	beq	a5,a0,f4a <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
    10b6:	f8b60513          	addi	a0,a2,-117
    10ba:	e119                	bnez	a0,10c0 <vprintf+0x264>
    10bc:	ea0693e3          	bnez	a3,f62 <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
    10c0:	f8b58513          	addi	a0,a1,-117
    10c4:	e119                	bnez	a0,10ca <vprintf+0x26e>
    10c6:	ea071be3          	bnez	a4,f7c <vprintf+0x120>
      } else if (c0 == 'x') {
    10ca:	07800513          	li	a0,120
    10ce:	eca784e3          	beq	a5,a0,f96 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
    10d2:	f8860613          	addi	a2,a2,-120
    10d6:	e219                	bnez	a2,10dc <vprintf+0x280>
    10d8:	ec069be3          	bnez	a3,fae <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
    10dc:	f8858593          	addi	a1,a1,-120
    10e0:	e199                	bnez	a1,10e6 <vprintf+0x28a>
    10e2:	ee0713e3          	bnez	a4,fc8 <vprintf+0x16c>
      } else if (c0 == 'p') {
    10e6:	07000713          	li	a4,112
    10ea:	eee78ce3          	beq	a5,a4,fe2 <vprintf+0x186>
      } else if (c0 == 'c') {
    10ee:	06300713          	li	a4,99
    10f2:	f2e78ce3          	beq	a5,a4,102a <vprintf+0x1ce>
      } else if (c0 == 's') {
    10f6:	07300713          	li	a4,115
    10fa:	f4e782e3          	beq	a5,a4,103e <vprintf+0x1e2>
      } else if (c0 == '%') {
    10fe:	02500713          	li	a4,37
    1102:	f6e787e3          	beq	a5,a4,1070 <vprintf+0x214>
        putc(fd, '%');
    1106:	02500593          	li	a1,37
    110a:	855a                	mv	a0,s6
    110c:	c95ff0ef          	jal	da0 <putc>
        putc(fd, c0);
    1110:	85a6                	mv	a1,s1
    1112:	855a                	mv	a0,s6
    1114:	c8dff0ef          	jal	da0 <putc>
      state = 0;
    1118:	4981                	li	s3,0
    111a:	b359                	j	ea0 <vprintf+0x44>

000000000000111c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    111c:	715d                	addi	sp,sp,-80
    111e:	ec06                	sd	ra,24(sp)
    1120:	e822                	sd	s0,16(sp)
    1122:	1000                	addi	s0,sp,32
    1124:	e010                	sd	a2,0(s0)
    1126:	e414                	sd	a3,8(s0)
    1128:	e818                	sd	a4,16(s0)
    112a:	ec1c                	sd	a5,24(s0)
    112c:	03043023          	sd	a6,32(s0)
    1130:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1134:	8622                	mv	a2,s0
    1136:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    113a:	d23ff0ef          	jal	e5c <vprintf>
}
    113e:	60e2                	ld	ra,24(sp)
    1140:	6442                	ld	s0,16(sp)
    1142:	6161                	addi	sp,sp,80
    1144:	8082                	ret

0000000000001146 <printf>:

void
printf(const char *fmt, ...)
{
    1146:	711d                	addi	sp,sp,-96
    1148:	ec06                	sd	ra,24(sp)
    114a:	e822                	sd	s0,16(sp)
    114c:	1000                	addi	s0,sp,32
    114e:	e40c                	sd	a1,8(s0)
    1150:	e810                	sd	a2,16(s0)
    1152:	ec14                	sd	a3,24(s0)
    1154:	f018                	sd	a4,32(s0)
    1156:	f41c                	sd	a5,40(s0)
    1158:	03043823          	sd	a6,48(s0)
    115c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1160:	00840613          	addi	a2,s0,8
    1164:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1168:	85aa                	mv	a1,a0
    116a:	4505                	li	a0,1
    116c:	cf1ff0ef          	jal	e5c <vprintf>
}
    1170:	60e2                	ld	ra,24(sp)
    1172:	6442                	ld	s0,16(sp)
    1174:	6125                	addi	sp,sp,96
    1176:	8082                	ret

0000000000001178 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1178:	1141                	addi	sp,sp,-16
    117a:	e406                	sd	ra,8(sp)
    117c:	e022                	sd	s0,0(sp)
    117e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
    1180:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1184:	00002797          	auipc	a5,0x2
    1188:	e7c7b783          	ld	a5,-388(a5) # 3000 <freep>
    118c:	a039                	j	119a <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    118e:	6398                	ld	a4,0(a5)
    1190:	00e7e463          	bltu	a5,a4,1198 <free+0x20>
    1194:	00e6ea63          	bltu	a3,a4,11a8 <free+0x30>
{
    1198:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    119a:	fed7fae3          	bgeu	a5,a3,118e <free+0x16>
    119e:	6398                	ld	a4,0(a5)
    11a0:	00e6e463          	bltu	a3,a4,11a8 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    11a4:	fee7eae3          	bltu	a5,a4,1198 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
    11a8:	ff852583          	lw	a1,-8(a0)
    11ac:	6390                	ld	a2,0(a5)
    11ae:	02059813          	slli	a6,a1,0x20
    11b2:	01c85713          	srli	a4,a6,0x1c
    11b6:	9736                	add	a4,a4,a3
    11b8:	02e60563          	beq	a2,a4,11e2 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
    11bc:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
    11c0:	4790                	lw	a2,8(a5)
    11c2:	02061593          	slli	a1,a2,0x20
    11c6:	01c5d713          	srli	a4,a1,0x1c
    11ca:	973e                	add	a4,a4,a5
    11cc:	02e68263          	beq	a3,a4,11f0 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
    11d0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    11d2:	00002717          	auipc	a4,0x2
    11d6:	e2f73723          	sd	a5,-466(a4) # 3000 <freep>
}
    11da:	60a2                	ld	ra,8(sp)
    11dc:	6402                	ld	s0,0(sp)
    11de:	0141                	addi	sp,sp,16
    11e0:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
    11e2:	4618                	lw	a4,8(a2)
    11e4:	9f2d                	addw	a4,a4,a1
    11e6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    11ea:	6398                	ld	a4,0(a5)
    11ec:	6310                	ld	a2,0(a4)
    11ee:	b7f9                	j	11bc <free+0x44>
    p->s.size += bp->s.size;
    11f0:	ff852703          	lw	a4,-8(a0)
    11f4:	9f31                	addw	a4,a4,a2
    11f6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    11f8:	ff053683          	ld	a3,-16(a0)
    11fc:	bfd1                	j	11d0 <free+0x58>

00000000000011fe <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
    11fe:	7139                	addi	sp,sp,-64
    1200:	fc06                	sd	ra,56(sp)
    1202:	f822                	sd	s0,48(sp)
    1204:	f04a                	sd	s2,32(sp)
    1206:	ec4e                	sd	s3,24(sp)
    1208:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
    120a:	02051993          	slli	s3,a0,0x20
    120e:	0209d993          	srli	s3,s3,0x20
    1212:	09bd                	addi	s3,s3,15
    1214:	0049d993          	srli	s3,s3,0x4
    1218:	2985                	addiw	s3,s3,1
    121a:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
    121c:	00002517          	auipc	a0,0x2
    1220:	de453503          	ld	a0,-540(a0) # 3000 <freep>
    1224:	c905                	beqz	a0,1254 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
    1226:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
    1228:	4798                	lw	a4,8(a5)
    122a:	09377663          	bgeu	a4,s3,12b6 <malloc+0xb8>
    122e:	f426                	sd	s1,40(sp)
    1230:	e852                	sd	s4,16(sp)
    1232:	e456                	sd	s5,8(sp)
    1234:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
    1236:	8a4e                	mv	s4,s3
    1238:	6705                	lui	a4,0x1
    123a:	00e9f363          	bgeu	s3,a4,1240 <malloc+0x42>
    123e:	6a05                	lui	s4,0x1
    1240:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1244:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
    1248:	00002497          	auipc	s1,0x2
    124c:	db848493          	addi	s1,s1,-584 # 3000 <freep>
  if (p == SBRK_ERROR)
    1250:	5afd                	li	s5,-1
    1252:	a83d                	j	1290 <malloc+0x92>
    1254:	f426                	sd	s1,40(sp)
    1256:	e852                	sd	s4,16(sp)
    1258:	e456                	sd	s5,8(sp)
    125a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    125c:	00002797          	auipc	a5,0x2
    1260:	db478793          	addi	a5,a5,-588 # 3010 <base>
    1264:	00002717          	auipc	a4,0x2
    1268:	d8f73e23          	sd	a5,-612(a4) # 3000 <freep>
    126c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    126e:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
    1272:	b7d1                	j	1236 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
    1274:	6398                	ld	a4,0(a5)
    1276:	e118                	sd	a4,0(a0)
    1278:	a899                	j	12ce <malloc+0xd0>
  hp->s.size = nu;
    127a:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
    127e:	0541                	addi	a0,a0,16
    1280:	ef9ff0ef          	jal	1178 <free>
  return freep;
    1284:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
    1286:	c125                	beqz	a0,12e6 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
    1288:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
    128a:	4798                	lw	a4,8(a5)
    128c:	03277163          	bgeu	a4,s2,12ae <malloc+0xb0>
    if (p == freep)
    1290:	6098                	ld	a4,0(s1)
    1292:	853e                	mv	a0,a5
    1294:	fef71ae3          	bne	a4,a5,1288 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
    1298:	8552                	mv	a0,s4
    129a:	a2bff0ef          	jal	cc4 <sbrk>
  if (p == SBRK_ERROR)
    129e:	fd551ee3          	bne	a0,s5,127a <malloc+0x7c>
        return 0;
    12a2:	4501                	li	a0,0
    12a4:	74a2                	ld	s1,40(sp)
    12a6:	6a42                	ld	s4,16(sp)
    12a8:	6aa2                	ld	s5,8(sp)
    12aa:	6b02                	ld	s6,0(sp)
    12ac:	a03d                	j	12da <malloc+0xdc>
    12ae:	74a2                	ld	s1,40(sp)
    12b0:	6a42                	ld	s4,16(sp)
    12b2:	6aa2                	ld	s5,8(sp)
    12b4:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
    12b6:	fae90fe3          	beq	s2,a4,1274 <malloc+0x76>
        p->s.size -= nunits;
    12ba:	4137073b          	subw	a4,a4,s3
    12be:	c798                	sw	a4,8(a5)
        p += p->s.size;
    12c0:	02071693          	slli	a3,a4,0x20
    12c4:	01c6d713          	srli	a4,a3,0x1c
    12c8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    12ca:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    12ce:	00002717          	auipc	a4,0x2
    12d2:	d2a73923          	sd	a0,-718(a4) # 3000 <freep>
      return (void *)(p + 1);
    12d6:	01078513          	addi	a0,a5,16
  }
}
    12da:	70e2                	ld	ra,56(sp)
    12dc:	7442                	ld	s0,48(sp)
    12de:	7902                	ld	s2,32(sp)
    12e0:	69e2                	ld	s3,24(sp)
    12e2:	6121                	addi	sp,sp,64
    12e4:	8082                	ret
    12e6:	74a2                	ld	s1,40(sp)
    12e8:	6a42                	ld	s4,16(sp)
    12ea:	6aa2                	ld	s5,8(sp)
    12ec:	6b02                	ld	s6,0(sp)
    12ee:	b7f5                	j	12da <malloc+0xdc>
