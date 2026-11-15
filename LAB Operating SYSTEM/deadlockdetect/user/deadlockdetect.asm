
user/_deadlockdetect:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print_matrices>:
int color[MAX_PROC];
int parent_node[MAX_PROC];
int cycle_start = -1;
int cycle_end = -1;

void print_matrices(int n, int m, int alloc[MAX_PROC][MAX_RES], int req[MAX_PROC][MAX_RES]) {
       0:	711d                	addi	sp,sp,-96
       2:	ec86                	sd	ra,88(sp)
       4:	e8a2                	sd	s0,80(sp)
       6:	e4a6                	sd	s1,72(sp)
       8:	e0ca                	sd	s2,64(sp)
       a:	fc4e                	sd	s3,56(sp)
       c:	f852                	sd	s4,48(sp)
       e:	f456                	sd	s5,40(sp)
      10:	f05a                	sd	s6,32(sp)
      12:	ec5e                	sd	s7,24(sp)
      14:	e862                	sd	s8,16(sp)
      16:	e466                	sd	s9,8(sp)
      18:	e06a                	sd	s10,0(sp)
      1a:	1080                	addi	s0,sp,96
      1c:	8aaa                	mv	s5,a0
      1e:	8a2e                	mv	s4,a1
      20:	8b32                	mv	s6,a2
      22:	8d36                	mv	s10,a3
  printf("Resource Allocation Matrix:\n");
      24:	00001517          	auipc	a0,0x1
      28:	01c50513          	addi	a0,a0,28 # 1040 <malloc+0xf4>
      2c:	669000ef          	jal	e94 <printf>
  printf("Proc | ");
      30:	00001517          	auipc	a0,0x1
      34:	03850513          	addi	a0,a0,56 # 1068 <malloc+0x11c>
      38:	65d000ef          	jal	e94 <printf>
  for (int j = 0; j < m; j++) printf("R%d ", j);
      3c:	19405063          	blez	s4,1bc <print_matrices+0x1bc>
      40:	4481                	li	s1,0
      42:	00001917          	auipc	s2,0x1
      46:	02e90913          	addi	s2,s2,46 # 1070 <malloc+0x124>
      4a:	85a6                	mv	a1,s1
      4c:	854a                	mv	a0,s2
      4e:	647000ef          	jal	e94 <printf>
      52:	2485                	addiw	s1,s1,1
      54:	fe9a1be3          	bne	s4,s1,4a <print_matrices+0x4a>
  printf("\n-----+");
      58:	00001517          	auipc	a0,0x1
      5c:	02050513          	addi	a0,a0,32 # 1078 <malloc+0x12c>
      60:	635000ef          	jal	e94 <printf>
  for (int j = 0; j < m; j++) printf("---");
      64:	4901                	li	s2,0
      66:	00001997          	auipc	s3,0x1
      6a:	01a98993          	addi	s3,s3,26 # 1080 <malloc+0x134>
      6e:	854e                	mv	a0,s3
      70:	625000ef          	jal	e94 <printf>
      74:	0019079b          	addiw	a5,s2,1
      78:	2905                	addiw	s2,s2,1
      7a:	fe979ae3          	bne	a5,s1,6e <print_matrices+0x6e>
  printf("\n");
      7e:	00001517          	auipc	a0,0x1
      82:	02250513          	addi	a0,a0,34 # 10a0 <malloc+0x154>
      86:	60f000ef          	jal	e94 <printf>
  for (int i = 0; i < n; i++) {
      8a:	17505a63          	blez	s5,1fe <print_matrices+0x1fe>
      8e:	002a1913          	slli	s2,s4,0x2
      92:	995a                	add	s2,s2,s6
      94:	41400bb3          	neg	s7,s4
      98:	0b8a                	slli	s7,s7,0x2
      9a:	4b01                	li	s6,0
    printf(" P%d  | ", i);
      9c:	00001c97          	auipc	s9,0x1
      a0:	fecc8c93          	addi	s9,s9,-20 # 1088 <malloc+0x13c>
    for (int j = 0; j < m; j++) {
      printf(" %d ", alloc[i][j]);
      a4:	00001997          	auipc	s3,0x1
      a8:	ff498993          	addi	s3,s3,-12 # 1098 <malloc+0x14c>
    }
    printf("\n");
      ac:	00001c17          	auipc	s8,0x1
      b0:	ff4c0c13          	addi	s8,s8,-12 # 10a0 <malloc+0x154>
    printf(" P%d  | ", i);
      b4:	85da                	mv	a1,s6
      b6:	8566                	mv	a0,s9
      b8:	5dd000ef          	jal	e94 <printf>
    for (int j = 0; j < m; j++) {
      bc:	01405b63          	blez	s4,d2 <print_matrices+0xd2>
      c0:	017904b3          	add	s1,s2,s7
      printf(" %d ", alloc[i][j]);
      c4:	408c                	lw	a1,0(s1)
      c6:	854e                	mv	a0,s3
      c8:	5cd000ef          	jal	e94 <printf>
    for (int j = 0; j < m; j++) {
      cc:	0491                	addi	s1,s1,4
      ce:	ff249be3          	bne	s1,s2,c4 <print_matrices+0xc4>
    printf("\n");
      d2:	8562                	mv	a0,s8
      d4:	5c1000ef          	jal	e94 <printf>
  for (int i = 0; i < n; i++) {
      d8:	2b05                	addiw	s6,s6,1
      da:	02890913          	addi	s2,s2,40
      de:	fd6a9be3          	bne	s5,s6,b4 <print_matrices+0xb4>
  }

  printf("\nResource Request Matrix:\n");
      e2:	00001517          	auipc	a0,0x1
      e6:	fc650513          	addi	a0,a0,-58 # 10a8 <malloc+0x15c>
      ea:	5ab000ef          	jal	e94 <printf>
  printf("Proc | ");
      ee:	00001517          	auipc	a0,0x1
      f2:	f7a50513          	addi	a0,a0,-134 # 1068 <malloc+0x11c>
      f6:	59f000ef          	jal	e94 <printf>
  for (int j = 0; j < m; j++) printf("R%d ", j);
      fa:	0f405b63          	blez	s4,1f0 <print_matrices+0x1f0>
  for (int i = 0; i < n; i++) {
      fe:	4481                	li	s1,0
  for (int j = 0; j < m; j++) printf("R%d ", j);
     100:	00001917          	auipc	s2,0x1
     104:	f7090913          	addi	s2,s2,-144 # 1070 <malloc+0x124>
     108:	85a6                	mv	a1,s1
     10a:	854a                	mv	a0,s2
     10c:	589000ef          	jal	e94 <printf>
     110:	2485                	addiw	s1,s1,1
     112:	fe9a1be3          	bne	s4,s1,108 <print_matrices+0x108>
  printf("\n-----+");
     116:	00001517          	auipc	a0,0x1
     11a:	f6250513          	addi	a0,a0,-158 # 1078 <malloc+0x12c>
     11e:	577000ef          	jal	e94 <printf>
  for (int j = 0; j < m; j++) printf("---");
     122:	4901                	li	s2,0
     124:	00001997          	auipc	s3,0x1
     128:	f5c98993          	addi	s3,s3,-164 # 1080 <malloc+0x134>
     12c:	854e                	mv	a0,s3
     12e:	567000ef          	jal	e94 <printf>
     132:	0019079b          	addiw	a5,s2,1
     136:	2905                	addiw	s2,s2,1
     138:	fe979ae3          	bne	a5,s1,12c <print_matrices+0x12c>
  printf("\n");
     13c:	00001517          	auipc	a0,0x1
     140:	f6450513          	addi	a0,a0,-156 # 10a0 <malloc+0x154>
     144:	551000ef          	jal	e94 <printf>
  for (int i = 0; i < n; i++) {
     148:	05505c63          	blez	s5,1a0 <print_matrices+0x1a0>
     14c:	002a1913          	slli	s2,s4,0x2
     150:	996a                	add	s2,s2,s10
     152:	41400bb3          	neg	s7,s4
     156:	0b8a                	slli	s7,s7,0x2
     158:	4b01                	li	s6,0
    printf(" P%d  | ", i);
     15a:	00001c97          	auipc	s9,0x1
     15e:	f2ec8c93          	addi	s9,s9,-210 # 1088 <malloc+0x13c>
    for (int j = 0; j < m; j++) {
      printf(" %d ", req[i][j]);
     162:	00001997          	auipc	s3,0x1
     166:	f3698993          	addi	s3,s3,-202 # 1098 <malloc+0x14c>
    }
    printf("\n");
     16a:	00001c17          	auipc	s8,0x1
     16e:	f36c0c13          	addi	s8,s8,-202 # 10a0 <malloc+0x154>
    printf(" P%d  | ", i);
     172:	85da                	mv	a1,s6
     174:	8566                	mv	a0,s9
     176:	51f000ef          	jal	e94 <printf>
    for (int j = 0; j < m; j++) {
     17a:	01405b63          	blez	s4,190 <print_matrices+0x190>
     17e:	017904b3          	add	s1,s2,s7
      printf(" %d ", req[i][j]);
     182:	408c                	lw	a1,0(s1)
     184:	854e                	mv	a0,s3
     186:	50f000ef          	jal	e94 <printf>
    for (int j = 0; j < m; j++) {
     18a:	0491                	addi	s1,s1,4
     18c:	ff249be3          	bne	s1,s2,182 <print_matrices+0x182>
    printf("\n");
     190:	8562                	mv	a0,s8
     192:	503000ef          	jal	e94 <printf>
  for (int i = 0; i < n; i++) {
     196:	2b05                	addiw	s6,s6,1
     198:	02890913          	addi	s2,s2,40
     19c:	fd6a9be3          	bne	s5,s6,172 <print_matrices+0x172>
  }
}
     1a0:	60e6                	ld	ra,88(sp)
     1a2:	6446                	ld	s0,80(sp)
     1a4:	64a6                	ld	s1,72(sp)
     1a6:	6906                	ld	s2,64(sp)
     1a8:	79e2                	ld	s3,56(sp)
     1aa:	7a42                	ld	s4,48(sp)
     1ac:	7aa2                	ld	s5,40(sp)
     1ae:	7b02                	ld	s6,32(sp)
     1b0:	6be2                	ld	s7,24(sp)
     1b2:	6c42                	ld	s8,16(sp)
     1b4:	6ca2                	ld	s9,8(sp)
     1b6:	6d02                	ld	s10,0(sp)
     1b8:	6125                	addi	sp,sp,96
     1ba:	8082                	ret
  printf("\n-----+");
     1bc:	00001517          	auipc	a0,0x1
     1c0:	ebc50513          	addi	a0,a0,-324 # 1078 <malloc+0x12c>
     1c4:	4d1000ef          	jal	e94 <printf>
  printf("\n");
     1c8:	00001517          	auipc	a0,0x1
     1cc:	ed850513          	addi	a0,a0,-296 # 10a0 <malloc+0x154>
     1d0:	4c5000ef          	jal	e94 <printf>
  for (int i = 0; i < n; i++) {
     1d4:	eb504de3          	bgtz	s5,8e <print_matrices+0x8e>
  printf("\nResource Request Matrix:\n");
     1d8:	00001517          	auipc	a0,0x1
     1dc:	ed050513          	addi	a0,a0,-304 # 10a8 <malloc+0x15c>
     1e0:	4b5000ef          	jal	e94 <printf>
  printf("Proc | ");
     1e4:	00001517          	auipc	a0,0x1
     1e8:	e8450513          	addi	a0,a0,-380 # 1068 <malloc+0x11c>
     1ec:	4a9000ef          	jal	e94 <printf>
  printf("\n-----+");
     1f0:	00001517          	auipc	a0,0x1
     1f4:	e8850513          	addi	a0,a0,-376 # 1078 <malloc+0x12c>
     1f8:	49d000ef          	jal	e94 <printf>
  for (int j = 0; j < m; j++) printf("---");
     1fc:	b781                	j	13c <print_matrices+0x13c>
  printf("\nResource Request Matrix:\n");
     1fe:	00001517          	auipc	a0,0x1
     202:	eaa50513          	addi	a0,a0,-342 # 10a8 <malloc+0x15c>
     206:	48f000ef          	jal	e94 <printf>
  printf("Proc | ");
     20a:	00001517          	auipc	a0,0x1
     20e:	e5e50513          	addi	a0,a0,-418 # 1068 <malloc+0x11c>
     212:	483000ef          	jal	e94 <printf>
  for (int j = 0; j < m; j++) printf("R%d ", j);
     216:	b5e5                	j	fe <print_matrices+0xfe>

0000000000000218 <build_wait_for_graph>:

void build_wait_for_graph(int n, int m, int alloc[MAX_PROC][MAX_RES],
                          int req[MAX_PROC][MAX_RES], int wfg[MAX_PROC][MAX_PROC]) {
     218:	715d                	addi	sp,sp,-80
     21a:	e486                	sd	ra,72(sp)
     21c:	e0a2                	sd	s0,64(sp)
     21e:	0880                	addi	s0,sp,80
  for (int i = 0; i < n; i++) {
     220:	12a05963          	blez	a0,352 <build_wait_for_graph+0x13a>
     224:	fc26                	sd	s1,56(sp)
     226:	f84a                	sd	s2,48(sp)
     228:	f44e                	sd	s3,40(sp)
     22a:	f052                	sd	s4,32(sp)
     22c:	ec56                	sd	s5,24(sp)
     22e:	e85a                	sd	s6,16(sp)
     230:	e45e                	sd	s7,8(sp)
     232:	8f3a                	mv	t5,a4
     234:	8a3a                	mv	s4,a4
     236:	00251813          	slli	a6,a0,0x2
     23a:	983a                	add	a6,a6,a4
     23c:	02c00713          	li	a4,44
     240:	02e50733          	mul	a4,a0,a4
     244:	977a                	add	a4,a4,t5
     246:	40a008b3          	neg	a7,a0
     24a:	088a                	slli	a7,a7,0x2
    for (int j = 0; j < n; j++) {
     24c:	011807b3          	add	a5,a6,a7
      wfg[i][j] = 0;
     250:	0007a023          	sw	zero,0(a5)
    for (int j = 0; j < n; j++) {
     254:	0791                	addi	a5,a5,4
     256:	ff079de3          	bne	a5,a6,250 <build_wait_for_graph+0x38>
  for (int i = 0; i < n; i++) {
     25a:	02880813          	addi	a6,a6,40
     25e:	fee817e3          	bne	a6,a4,24c <build_wait_for_graph+0x34>
    }
  }

  // An edge Pi -> Pj exists if Pi is waiting for a resource held by Pj
  for (int i = 0; i < n; i++) {
     262:	00259793          	slli	a5,a1,0x2
     266:	00f68e33          	add	t3,a3,a5
     26a:	40b00fb3          	neg	t6,a1
     26e:	0f8a                	slli	t6,t6,0x2
     270:	4481                	li	s1,0
    for (int k = 0; k < m; k++) {
      if (req[i][k] > 0) {
        for (int j = 0; j < n; j++) {
          if (i != j && alloc[j][k] > 0) {
            wfg[i][j] = 1;
     272:	4e85                	li	t4,1
     274:	a0a9                	j	2be <build_wait_for_graph+0xa6>
        for (int j = 0; j < n; j++) {
     276:	2785                	addiw	a5,a5,1
     278:	0691                	addi	a3,a3,4
     27a:	02870713          	addi	a4,a4,40
     27e:	00f50b63          	beq	a0,a5,294 <build_wait_for_graph+0x7c>
          if (i != j && alloc[j][k] > 0) {
     282:	fef48ae3          	beq	s1,a5,276 <build_wait_for_graph+0x5e>
     286:	00072803          	lw	a6,0(a4)
     28a:	ff0056e3          	blez	a6,276 <build_wait_for_graph+0x5e>
            wfg[i][j] = 1;
     28e:	01d6a023          	sw	t4,0(a3)
     292:	b7d5                	j	276 <build_wait_for_graph+0x5e>
    for (int k = 0; k < m; k++) {
     294:	0891                	addi	a7,a7,4
     296:	0311                	addi	t1,t1,4
     298:	01c88a63          	beq	a7,t3,2ac <build_wait_for_graph+0x94>
      if (req[i][k] > 0) {
     29c:	0008a783          	lw	a5,0(a7)
     2a0:	fef05ae3          	blez	a5,294 <build_wait_for_graph+0x7c>
     2a4:	871a                	mv	a4,t1
     2a6:	86fa                	mv	a3,t5
        for (int j = 0; j < n; j++) {
     2a8:	4781                	li	a5,0
     2aa:	bfe1                	j	282 <build_wait_for_graph+0x6a>
  for (int i = 0; i < n; i++) {
     2ac:	0014879b          	addiw	a5,s1,1
     2b0:	028e0e13          	addi	t3,t3,40
     2b4:	028f0f13          	addi	t5,t5,40
     2b8:	00f50963          	beq	a0,a5,2ca <build_wait_for_graph+0xb2>
     2bc:	84be                	mv	s1,a5
    for (int k = 0; k < m; k++) {
     2be:	01fe08b3          	add	a7,t3,t6
     2c2:	8332                	mv	t1,a2
     2c4:	fcb04ce3          	bgtz	a1,29c <build_wait_for_graph+0x84>
     2c8:	b7d5                	j	2ac <build_wait_for_graph+0x94>
        }
      }
    }
  }

  printf("\nConstructed Wait-For Graph (WFG):\n");
     2ca:	00001517          	auipc	a0,0x1
     2ce:	dfe50513          	addi	a0,a0,-514 # 10c8 <malloc+0x17c>
     2d2:	3c3000ef          	jal	e94 <printf>
  int edge_count = 0;
  for (int i = 0; i < n; i++) {
     2d6:	4a81                	li	s5,0
  int edge_count = 0;
     2d8:	4b01                	li	s6,0
    for (int j = 0; j < n; j++) {
      if (wfg[i][j]) {
        printf("  Edge: P%d -> P%d (P%d waits for resource held by P%d)\n",
     2da:	00001b97          	auipc	s7,0x1
     2de:	e16b8b93          	addi	s7,s7,-490 # 10f0 <malloc+0x1a4>
     2e2:	a815                	j	316 <build_wait_for_graph+0xfe>
    for (int j = 0; j < n; j++) {
     2e4:	0019079b          	addiw	a5,s2,1
     2e8:	0991                	addi	s3,s3,4
     2ea:	01248f63          	beq	s1,s2,308 <build_wait_for_graph+0xf0>
     2ee:	893e                	mv	s2,a5
      if (wfg[i][j]) {
     2f0:	0009a783          	lw	a5,0(s3)
     2f4:	dbe5                	beqz	a5,2e4 <build_wait_for_graph+0xcc>
        printf("  Edge: P%d -> P%d (P%d waits for resource held by P%d)\n",
     2f6:	874a                	mv	a4,s2
     2f8:	86d6                	mv	a3,s5
     2fa:	864a                	mv	a2,s2
     2fc:	85d6                	mv	a1,s5
     2fe:	855e                	mv	a0,s7
     300:	395000ef          	jal	e94 <printf>
               i, j, i, j);
        edge_count++;
     304:	2b05                	addiw	s6,s6,1
     306:	bff9                	j	2e4 <build_wait_for_graph+0xcc>
  for (int i = 0; i < n; i++) {
     308:	001a879b          	addiw	a5,s5,1
     30c:	028a0a13          	addi	s4,s4,40
     310:	01548663          	beq	s1,s5,31c <build_wait_for_graph+0x104>
     314:	8abe                	mv	s5,a5
    for (int j = 0; j < n; j++) {
     316:	89d2                	mv	s3,s4
     318:	4901                	li	s2,0
     31a:	bfd9                	j	2f0 <build_wait_for_graph+0xd8>
      }
    }
  }
  if (edge_count == 0) {
     31c:	000b0d63          	beqz	s6,336 <build_wait_for_graph+0x11e>
     320:	74e2                	ld	s1,56(sp)
     322:	7942                	ld	s2,48(sp)
     324:	79a2                	ld	s3,40(sp)
     326:	7a02                	ld	s4,32(sp)
     328:	6ae2                	ld	s5,24(sp)
     32a:	6b42                	ld	s6,16(sp)
     32c:	6ba2                	ld	s7,8(sp)
    printf("  (No dependency edges in graph)\n");
  }
}
     32e:	60a6                	ld	ra,72(sp)
     330:	6406                	ld	s0,64(sp)
     332:	6161                	addi	sp,sp,80
     334:	8082                	ret
     336:	74e2                	ld	s1,56(sp)
     338:	7942                	ld	s2,48(sp)
     33a:	79a2                	ld	s3,40(sp)
     33c:	7a02                	ld	s4,32(sp)
     33e:	6ae2                	ld	s5,24(sp)
     340:	6b42                	ld	s6,16(sp)
     342:	6ba2                	ld	s7,8(sp)
    printf("  (No dependency edges in graph)\n");
     344:	00001517          	auipc	a0,0x1
     348:	dec50513          	addi	a0,a0,-532 # 1130 <malloc+0x1e4>
     34c:	349000ef          	jal	e94 <printf>
}
     350:	bff9                	j	32e <build_wait_for_graph+0x116>
  printf("\nConstructed Wait-For Graph (WFG):\n");
     352:	00001517          	auipc	a0,0x1
     356:	d7650513          	addi	a0,a0,-650 # 10c8 <malloc+0x17c>
     35a:	33b000ef          	jal	e94 <printf>
  if (edge_count == 0) {
     35e:	b7dd                	j	344 <build_wait_for_graph+0x12c>

0000000000000360 <dfs>:

int dfs(int u, int n, int wfg[MAX_PROC][MAX_PROC]) {
     360:	715d                	addi	sp,sp,-80
     362:	e486                	sd	ra,72(sp)
     364:	e0a2                	sd	s0,64(sp)
     366:	e85a                	sd	s6,16(sp)
     368:	0880                	addi	s0,sp,80
     36a:	8b2a                	mv	s6,a0
  color[u] = COLOR_GRAY;
     36c:	00251713          	slli	a4,a0,0x2
     370:	00002797          	auipc	a5,0x2
     374:	cb078793          	addi	a5,a5,-848 # 2020 <color>
     378:	97ba                	add	a5,a5,a4
     37a:	4705                	li	a4,1
     37c:	c398                	sw	a4,0(a5)

  for (int v = 0; v < n; v++) {
     37e:	0ab05063          	blez	a1,41e <dfs+0xbe>
     382:	fc26                	sd	s1,56(sp)
     384:	f84a                	sd	s2,48(sp)
     386:	f44e                	sd	s3,40(sp)
     388:	f052                	sd	s4,32(sp)
     38a:	ec56                	sd	s5,24(sp)
     38c:	e45e                	sd	s7,8(sp)
     38e:	e062                	sd	s8,0(sp)
     390:	8aae                	mv	s5,a1
     392:	8c32                	mv	s8,a2
    if (wfg[u][v]) {
     394:	00251493          	slli	s1,a0,0x2
     398:	94aa                	add	s1,s1,a0
     39a:	048e                	slli	s1,s1,0x3
     39c:	94b2                	add	s1,s1,a2
     39e:	00002a17          	auipc	s4,0x2
     3a2:	caaa0a13          	addi	s4,s4,-854 # 2048 <parent_node>
     3a6:	00002997          	auipc	s3,0x2
     3aa:	c7a98993          	addi	s3,s3,-902 # 2020 <color>
  for (int v = 0; v < n; v++) {
     3ae:	4901                	li	s2,0
      if (color[v] == COLOR_GRAY) {
     3b0:	8bba                	mv	s7,a4
     3b2:	a03d                	j	3e0 <dfs+0x80>
        // Back edge detected: cycle found!
        cycle_start = v;
     3b4:	00002797          	auipc	a5,0x2
     3b8:	c527a823          	sw	s2,-944(a5) # 2004 <cycle_start>
        cycle_end = u;
     3bc:	00002797          	auipc	a5,0x2
     3c0:	c567a223          	sw	s6,-956(a5) # 2000 <cycle_end>
        return 1;
     3c4:	74e2                	ld	s1,56(sp)
     3c6:	7942                	ld	s2,48(sp)
     3c8:	79a2                	ld	s3,40(sp)
     3ca:	7a02                	ld	s4,32(sp)
     3cc:	6ae2                	ld	s5,24(sp)
     3ce:	6ba2                	ld	s7,8(sp)
     3d0:	6c02                	ld	s8,0(sp)
     3d2:	a8b9                	j	430 <dfs+0xd0>
  for (int v = 0; v < n; v++) {
     3d4:	2905                	addiw	s2,s2,1
     3d6:	0491                	addi	s1,s1,4
     3d8:	0a11                	addi	s4,s4,4
     3da:	0991                	addi	s3,s3,4
     3dc:	032a8a63          	beq	s5,s2,410 <dfs+0xb0>
    if (wfg[u][v]) {
     3e0:	409c                	lw	a5,0(s1)
     3e2:	dbed                	beqz	a5,3d4 <dfs+0x74>
      if (color[v] == COLOR_GRAY) {
     3e4:	0009a503          	lw	a0,0(s3)
     3e8:	fd7506e3          	beq	a0,s7,3b4 <dfs+0x54>
      }
      if (color[v] == COLOR_WHITE) {
     3ec:	f565                	bnez	a0,3d4 <dfs+0x74>
        parent_node[v] = u;
     3ee:	016a2023          	sw	s6,0(s4)
        if (dfs(v, n, wfg))
     3f2:	8662                	mv	a2,s8
     3f4:	85d6                	mv	a1,s5
     3f6:	854a                	mv	a0,s2
     3f8:	f69ff0ef          	jal	360 <dfs>
     3fc:	dd61                	beqz	a0,3d4 <dfs+0x74>
          return 1;
     3fe:	4505                	li	a0,1
     400:	74e2                	ld	s1,56(sp)
     402:	7942                	ld	s2,48(sp)
     404:	79a2                	ld	s3,40(sp)
     406:	7a02                	ld	s4,32(sp)
     408:	6ae2                	ld	s5,24(sp)
     40a:	6ba2                	ld	s7,8(sp)
     40c:	6c02                	ld	s8,0(sp)
     40e:	a00d                	j	430 <dfs+0xd0>
     410:	74e2                	ld	s1,56(sp)
     412:	7942                	ld	s2,48(sp)
     414:	79a2                	ld	s3,40(sp)
     416:	7a02                	ld	s4,32(sp)
     418:	6ae2                	ld	s5,24(sp)
     41a:	6ba2                	ld	s7,8(sp)
     41c:	6c02                	ld	s8,0(sp)
      }
    }
  }

  color[u] = COLOR_BLACK;
     41e:	0b0a                	slli	s6,s6,0x2
     420:	00002797          	auipc	a5,0x2
     424:	c0078793          	addi	a5,a5,-1024 # 2020 <color>
     428:	97da                	add	a5,a5,s6
     42a:	4709                	li	a4,2
     42c:	c398                	sw	a4,0(a5)
  return 0;
     42e:	4501                	li	a0,0
}
     430:	60a6                	ld	ra,72(sp)
     432:	6406                	ld	s0,64(sp)
     434:	6b42                	ld	s6,16(sp)
     436:	6161                	addi	sp,sp,80
     438:	8082                	ret

000000000000043a <detect_deadlock>:

void detect_deadlock(int n, int wfg[MAX_PROC][MAX_PROC]) {
     43a:	711d                	addi	sp,sp,-96
     43c:	ec86                	sd	ra,88(sp)
     43e:	e8a2                	sd	s0,80(sp)
     440:	1080                	addi	s0,sp,96
  for (int i = 0; i < n; i++) {
     442:	14a05163          	blez	a0,584 <detect_deadlock+0x14a>
     446:	e4a6                	sd	s1,72(sp)
     448:	e0ca                	sd	s2,64(sp)
     44a:	fc4e                	sd	s3,56(sp)
     44c:	f852                	sd	s4,48(sp)
     44e:	89aa                	mv	s3,a0
     450:	8a2e                	mv	s4,a1
     452:	00002917          	auipc	s2,0x2
     456:	bce90913          	addi	s2,s2,-1074 # 2020 <color>
     45a:	00002717          	auipc	a4,0x2
     45e:	bee70713          	addi	a4,a4,-1042 # 2048 <parent_node>
     462:	00251693          	slli	a3,a0,0x2
     466:	96ca                	add	a3,a3,s2
     468:	87ca                	mv	a5,s2
    color[i] = COLOR_WHITE;
    parent_node[i] = -1;
     46a:	557d                	li	a0,-1
    color[i] = COLOR_WHITE;
     46c:	0007a023          	sw	zero,0(a5)
    parent_node[i] = -1;
     470:	c308                	sw	a0,0(a4)
  for (int i = 0; i < n; i++) {
     472:	0791                	addi	a5,a5,4
     474:	0711                	addi	a4,a4,4
     476:	fed79be3          	bne	a5,a3,46c <detect_deadlock+0x32>
  }
  cycle_start = -1;
     47a:	57fd                	li	a5,-1
     47c:	00002717          	auipc	a4,0x2
     480:	b8f72423          	sw	a5,-1144(a4) # 2004 <cycle_start>
  cycle_end = -1;
     484:	00002717          	auipc	a4,0x2
     488:	b6f72e23          	sw	a5,-1156(a4) # 2000 <cycle_end>

  int has_cycle = 0;
  for (int i = 0; i < n; i++) {
     48c:	4481                	li	s1,0
     48e:	a029                	j	498 <detect_deadlock+0x5e>
     490:	2485                	addiw	s1,s1,1
     492:	0911                	addi	s2,s2,4
     494:	0c998463          	beq	s3,s1,55c <detect_deadlock+0x122>
    if (color[i] == COLOR_WHITE) {
     498:	00092783          	lw	a5,0(s2)
     49c:	fbf5                	bnez	a5,490 <detect_deadlock+0x56>
      if (dfs(i, n, wfg)) {
     49e:	8652                	mv	a2,s4
     4a0:	85ce                	mv	a1,s3
     4a2:	8526                	mv	a0,s1
     4a4:	ebdff0ef          	jal	360 <dfs>
     4a8:	d565                	beqz	a0,490 <detect_deadlock+0x56>

  if (!has_cycle) {
    printf("RESULT: NO DEADLOCK DETECTED.\n");
    printf("The Wait-For Graph is acyclic. All processes can complete.\n");
  } else {
    printf("RESULT: DEADLOCK DETECTED!\n");
     4aa:	00001517          	auipc	a0,0x1
     4ae:	d1e50513          	addi	a0,a0,-738 # 11c8 <malloc+0x27c>
     4b2:	1e3000ef          	jal	e94 <printf>
    printf("Cycle of deadlocked processes: ");
     4b6:	00001517          	auipc	a0,0x1
     4ba:	d3250513          	addi	a0,a0,-718 # 11e8 <malloc+0x29c>
     4be:	1d7000ef          	jal	e94 <printf>

    // Reconstruct cycle: path from cycle_end back to cycle_start
    int cycle_nodes[MAX_PROC];
    int count = 0;
    int curr = cycle_end;
     4c2:	00002797          	auipc	a5,0x2
     4c6:	b3e7a783          	lw	a5,-1218(a5) # 2000 <cycle_end>
    cycle_nodes[count++] = curr;
     4ca:	faf42423          	sw	a5,-88(s0)
    while (curr != cycle_start && curr != -1) {
     4ce:	00002597          	auipc	a1,0x2
     4d2:	b365a583          	lw	a1,-1226(a1) # 2004 <cycle_start>
     4d6:	00178713          	addi	a4,a5,1
     4da:	cf5d                	beqz	a4,598 <detect_deadlock+0x15e>
     4dc:	fa840693          	addi	a3,s0,-88
    cycle_nodes[count++] = curr;
     4e0:	4705                	li	a4,1
      curr = parent_node[curr];
     4e2:	00002517          	auipc	a0,0x2
     4e6:	b3e50513          	addi	a0,a0,-1218 # 2020 <color>
    while (curr != cycle_start && curr != -1) {
     4ea:	0ab78763          	beq	a5,a1,598 <detect_deadlock+0x15e>
      curr = parent_node[curr];
     4ee:	078a                	slli	a5,a5,0x2
     4f0:	97aa                	add	a5,a5,a0
     4f2:	579c                	lw	a5,40(a5)
      cycle_nodes[count++] = curr;
     4f4:	883a                	mv	a6,a4
     4f6:	2705                	addiw	a4,a4,1
     4f8:	c2dc                	sw	a5,4(a3)
    while (curr != cycle_start && curr != -1) {
     4fa:	0691                	addi	a3,a3,4
     4fc:	00178613          	addi	a2,a5,1
     500:	c219                	beqz	a2,506 <detect_deadlock+0xcc>
     502:	feb796e3          	bne	a5,a1,4ee <detect_deadlock+0xb4>
    }

    // Print in forward order
    for (int i = count - 1; i >= 0; i--) {
     506:	02084c63          	bltz	a6,53e <detect_deadlock+0x104>
     50a:	377d                	addiw	a4,a4,-1
     50c:	00271793          	slli	a5,a4,0x2
     510:	fa840493          	addi	s1,s0,-88
     514:	94be                	add	s1,s1,a5
     516:	fa440913          	addi	s2,s0,-92
     51a:	993e                	add	s2,s2,a5
     51c:	02071793          	slli	a5,a4,0x20
     520:	01e7d713          	srli	a4,a5,0x1e
     524:	40e90933          	sub	s2,s2,a4
      printf("P%d -> ", cycle_nodes[i]);
     528:	00001997          	auipc	s3,0x1
     52c:	c9098993          	addi	s3,s3,-880 # 11b8 <malloc+0x26c>
     530:	408c                	lw	a1,0(s1)
     532:	854e                	mv	a0,s3
     534:	161000ef          	jal	e94 <printf>
    for (int i = count - 1; i >= 0; i--) {
     538:	14f1                	addi	s1,s1,-4
     53a:	ff249be3          	bne	s1,s2,530 <detect_deadlock+0xf6>
    }
    printf("P%d\n", cycle_start);
     53e:	00002597          	auipc	a1,0x2
     542:	ac65a583          	lw	a1,-1338(a1) # 2004 <cycle_start>
     546:	00001517          	auipc	a0,0x1
     54a:	c7a50513          	addi	a0,a0,-902 # 11c0 <malloc+0x274>
     54e:	147000ef          	jal	e94 <printf>
  }
}
     552:	64a6                	ld	s1,72(sp)
     554:	6906                	ld	s2,64(sp)
     556:	79e2                	ld	s3,56(sp)
     558:	7a42                	ld	s4,48(sp)
     55a:	a00d                	j	57c <detect_deadlock+0x142>
     55c:	64a6                	ld	s1,72(sp)
     55e:	6906                	ld	s2,64(sp)
     560:	79e2                	ld	s3,56(sp)
     562:	7a42                	ld	s4,48(sp)
    printf("RESULT: NO DEADLOCK DETECTED.\n");
     564:	00001517          	auipc	a0,0x1
     568:	bf450513          	addi	a0,a0,-1036 # 1158 <malloc+0x20c>
     56c:	129000ef          	jal	e94 <printf>
    printf("The Wait-For Graph is acyclic. All processes can complete.\n");
     570:	00001517          	auipc	a0,0x1
     574:	c0850513          	addi	a0,a0,-1016 # 1178 <malloc+0x22c>
     578:	11d000ef          	jal	e94 <printf>
}
     57c:	60e6                	ld	ra,88(sp)
     57e:	6446                	ld	s0,80(sp)
     580:	6125                	addi	sp,sp,96
     582:	8082                	ret
  cycle_start = -1;
     584:	57fd                	li	a5,-1
     586:	00002717          	auipc	a4,0x2
     58a:	a6f72f23          	sw	a5,-1410(a4) # 2004 <cycle_start>
  cycle_end = -1;
     58e:	00002717          	auipc	a4,0x2
     592:	a6f72923          	sw	a5,-1422(a4) # 2000 <cycle_end>
  if (!has_cycle) {
     596:	b7f9                	j	564 <detect_deadlock+0x12a>
    cycle_nodes[count++] = curr;
     598:	4705                	li	a4,1
     59a:	bf85                	j	50a <detect_deadlock+0xd0>

000000000000059c <main>:

int main(int argc, char *argv[]) {
     59c:	7125                	addi	sp,sp,-416
     59e:	ef06                	sd	ra,408(sp)
     5a0:	eb22                	sd	s0,400(sp)
     5a2:	e726                	sd	s1,392(sp)
     5a4:	e34a                	sd	s2,384(sp)
     5a6:	fece                	sd	s3,376(sp)
     5a8:	fad2                	sd	s4,368(sp)
     5aa:	1300                	addi	s0,sp,416
     5ac:	81010113          	addi	sp,sp,-2032
  printf("============================================================\n");
     5b0:	00001517          	auipc	a0,0x1
     5b4:	c5850513          	addi	a0,a0,-936 # 1208 <malloc+0x2bc>
     5b8:	0dd000ef          	jal	e94 <printf>
  printf("   Deadlock Detection using Resource Allocation Graph (RAG) \n");
     5bc:	00001517          	auipc	a0,0x1
     5c0:	c8c50513          	addi	a0,a0,-884 # 1248 <malloc+0x2fc>
     5c4:	0d1000ef          	jal	e94 <printf>
  printf("============================================================\n");
     5c8:	00001517          	auipc	a0,0x1
     5cc:	c4050513          	addi	a0,a0,-960 # 1208 <malloc+0x2bc>
     5d0:	0c5000ef          	jal	e94 <printf>

  // -------------------------------------------------------------------------
  // Scenario 1: Acyclic graph - NO DEADLOCK
  // -------------------------------------------------------------------------
  printf("\n============================================================\n");
     5d4:	00001517          	auipc	a0,0x1
     5d8:	cb450513          	addi	a0,a0,-844 # 1288 <malloc+0x33c>
     5dc:	0b9000ef          	jal	e94 <printf>
  printf("[Scenario 1] Acyclic Wait-For Graph (No Deadlock)\n");
     5e0:	00001517          	auipc	a0,0x1
     5e4:	ce850513          	addi	a0,a0,-792 # 12c8 <malloc+0x37c>
     5e8:	0ad000ef          	jal	e94 <printf>
  printf("4 Processes (P0..P3), 4 Resources (R0..R3)\n");
     5ec:	00001517          	auipc	a0,0x1
     5f0:	d1450513          	addi	a0,a0,-748 # 1300 <malloc+0x3b4>
     5f4:	0a1000ef          	jal	e94 <printf>
  printf("P0 holds R0, requests R1\n");
     5f8:	00001517          	auipc	a0,0x1
     5fc:	d3850513          	addi	a0,a0,-712 # 1330 <malloc+0x3e4>
     600:	095000ef          	jal	e94 <printf>
  printf("P1 holds R1, requests R2\n");
     604:	00001517          	auipc	a0,0x1
     608:	d4c50513          	addi	a0,a0,-692 # 1350 <malloc+0x404>
     60c:	089000ef          	jal	e94 <printf>
  printf("P2 holds R2 (no requests)\n");
     610:	00001517          	auipc	a0,0x1
     614:	d6050513          	addi	a0,a0,-672 # 1370 <malloc+0x424>
     618:	07d000ef          	jal	e94 <printf>
  printf("P3 holds R3, requests R2\n");
     61c:	00001517          	auipc	a0,0x1
     620:	d7450513          	addi	a0,a0,-652 # 1390 <malloc+0x444>
     624:	071000ef          	jal	e94 <printf>
  printf("============================================================\n");
     628:	00001517          	auipc	a0,0x1
     62c:	be050513          	addi	a0,a0,-1056 # 1208 <malloc+0x2bc>
     630:	065000ef          	jal	e94 <printf>

  int n1 = 4, m1 = 4;
  int alloc1[MAX_PROC][MAX_RES] = {
     634:	e4040913          	addi	s2,s0,-448
     638:	19000613          	li	a2,400
     63c:	4581                	li	a1,0
     63e:	854a                	mv	a0,s2
     640:	1dc000ef          	jal	81c <memset>
     644:	4485                	li	s1,1
     646:	e4942023          	sw	s1,-448(s0)
     64a:	e6942623          	sw	s1,-404(s0)
     64e:	e8942c23          	sw	s1,-360(s0)
     652:	ec942223          	sw	s1,-316(s0)
    {1, 0, 0, 0}, // P0 holds R0
    {0, 1, 0, 0}, // P1 holds R1
    {0, 0, 1, 0}, // P2 holds R2
    {0, 0, 0, 1}  // P3 holds R3
  };
  int req1[MAX_PROC][MAX_RES] = {
     656:	cb040993          	addi	s3,s0,-848
     65a:	19000613          	li	a2,400
     65e:	4581                	li	a1,0
     660:	854e                	mv	a0,s3
     662:	1ba000ef          	jal	81c <memset>
     666:	ca942a23          	sw	s1,-844(s0)
     66a:	ce942023          	sw	s1,-800(s0)
     66e:	d2942823          	sw	s1,-720(s0)
    {0, 0, 0, 0}, // P2 wants nothing
    {0, 0, 1, 0}  // P3 wants R2
  };
  int wfg1[MAX_PROC][MAX_PROC];

  print_matrices(n1, m1, alloc1, req1);
     672:	86ce                	mv	a3,s3
     674:	864a                	mv	a2,s2
     676:	4591                	li	a1,4
     678:	852e                	mv	a0,a1
     67a:	987ff0ef          	jal	0 <print_matrices>
  build_wait_for_graph(n1, m1, alloc1, req1, wfg1);
     67e:	b2040a13          	addi	s4,s0,-1248
     682:	8752                	mv	a4,s4
     684:	86ce                	mv	a3,s3
     686:	864a                	mv	a2,s2
     688:	4591                	li	a1,4
     68a:	852e                	mv	a0,a1
     68c:	b8dff0ef          	jal	218 <build_wait_for_graph>
  detect_deadlock(n1, wfg1);
     690:	85d2                	mv	a1,s4
     692:	4511                	li	a0,4
     694:	da7ff0ef          	jal	43a <detect_deadlock>

  // -------------------------------------------------------------------------
  // Scenario 2: Circular wait involving 4 processes - DEADLOCK DETECTED
  // -------------------------------------------------------------------------
  printf("\n============================================================\n");
     698:	00001517          	auipc	a0,0x1
     69c:	bf050513          	addi	a0,a0,-1040 # 1288 <malloc+0x33c>
     6a0:	7f4000ef          	jal	e94 <printf>
  printf("[Scenario 2] Circular Wait among 4 processes (Deadlock Detected)\n");
     6a4:	00001517          	auipc	a0,0x1
     6a8:	d0c50513          	addi	a0,a0,-756 # 13b0 <malloc+0x464>
     6ac:	7e8000ef          	jal	e94 <printf>
  printf("4 Processes (P0..P3), 4 Resources (R0..R3)\n");
     6b0:	00001517          	auipc	a0,0x1
     6b4:	c5050513          	addi	a0,a0,-944 # 1300 <malloc+0x3b4>
     6b8:	7dc000ef          	jal	e94 <printf>
  printf("P0 holds R0, requests R1\n");
     6bc:	00001517          	auipc	a0,0x1
     6c0:	c7450513          	addi	a0,a0,-908 # 1330 <malloc+0x3e4>
     6c4:	7d0000ef          	jal	e94 <printf>
  printf("P1 holds R1, requests R2\n");
     6c8:	00001517          	auipc	a0,0x1
     6cc:	c8850513          	addi	a0,a0,-888 # 1350 <malloc+0x404>
     6d0:	7c4000ef          	jal	e94 <printf>
  printf("P2 holds R2, requests R3\n");
     6d4:	00001517          	auipc	a0,0x1
     6d8:	d2450513          	addi	a0,a0,-732 # 13f8 <malloc+0x4ac>
     6dc:	7b8000ef          	jal	e94 <printf>
  printf("P3 holds R3, requests R0\n");
     6e0:	00001517          	auipc	a0,0x1
     6e4:	d3850513          	addi	a0,a0,-712 # 1418 <malloc+0x4cc>
     6e8:	7ac000ef          	jal	e94 <printf>
  printf("============================================================\n");
     6ec:	00001517          	auipc	a0,0x1
     6f0:	b1c50513          	addi	a0,a0,-1252 # 1208 <malloc+0x2bc>
     6f4:	7a0000ef          	jal	e94 <printf>

  int n2 = 4, m2 = 4;
  int alloc2[MAX_PROC][MAX_RES] = {
     6f8:	99040913          	addi	s2,s0,-1648
     6fc:	19000613          	li	a2,400
     700:	4581                	li	a1,0
     702:	854a                	mv	a0,s2
     704:	118000ef          	jal	81c <memset>
     708:	98942823          	sw	s1,-1648(s0)
     70c:	9a942e23          	sw	s1,-1604(s0)
     710:	9e942423          	sw	s1,-1560(s0)
     714:	a0942a23          	sw	s1,-1516(s0)
    {1, 0, 0, 0}, // P0 holds R0
    {0, 1, 0, 0}, // P1 holds R1
    {0, 0, 1, 0}, // P2 holds R2
    {0, 0, 0, 1}  // P3 holds R3
  };
  int req2[MAX_PROC][MAX_RES] = {
     718:	80040993          	addi	s3,s0,-2048
     71c:	19000613          	li	a2,400
     720:	4581                	li	a1,0
     722:	854e                	mv	a0,s3
     724:	0f8000ef          	jal	81c <memset>
     728:	80942223          	sw	s1,-2044(s0)
     72c:	82942823          	sw	s1,-2000(s0)
     730:	84942e23          	sw	s1,-1956(s0)
     734:	86942c23          	sw	s1,-1928(s0)
    {0, 0, 0, 1}, // P2 wants R3
    {1, 0, 0, 0}  // P3 wants R0 (completes circular wait!)
  };
  int wfg2[MAX_PROC][MAX_PROC];

  print_matrices(n2, m2, alloc2, req2);
     738:	86ce                	mv	a3,s3
     73a:	864a                	mv	a2,s2
     73c:	4591                	li	a1,4
     73e:	852e                	mv	a0,a1
     740:	8c1ff0ef          	jal	0 <print_matrices>
  build_wait_for_graph(n2, m2, alloc2, req2, wfg2);
     744:	80040493          	addi	s1,s0,-2048
     748:	fd048493          	addi	s1,s1,-48
     74c:	ea048493          	addi	s1,s1,-352
     750:	8726                	mv	a4,s1
     752:	86ce                	mv	a3,s3
     754:	864a                	mv	a2,s2
     756:	4591                	li	a1,4
     758:	852e                	mv	a0,a1
     75a:	abfff0ef          	jal	218 <build_wait_for_graph>
  detect_deadlock(n2, wfg2);
     75e:	85a6                	mv	a1,s1
     760:	4511                	li	a0,4
     762:	cd9ff0ef          	jal	43a <detect_deadlock>

  printf("\n============================================================\n");
     766:	00001517          	auipc	a0,0x1
     76a:	b2250513          	addi	a0,a0,-1246 # 1288 <malloc+0x33c>
     76e:	726000ef          	jal	e94 <printf>
  printf("Deadlock detection analysis finished.\n");
     772:	00001517          	auipc	a0,0x1
     776:	cc650513          	addi	a0,a0,-826 # 1438 <malloc+0x4ec>
     77a:	71a000ef          	jal	e94 <printf>
  printf("============================================================\n");
     77e:	00001517          	auipc	a0,0x1
     782:	a8a50513          	addi	a0,a0,-1398 # 1208 <malloc+0x2bc>
     786:	70e000ef          	jal	e94 <printf>

  exit(0);
     78a:	4501                	li	a0,0
     78c:	2ba000ef          	jal	a46 <exit>

0000000000000790 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
     790:	1141                	addi	sp,sp,-16
     792:	e406                	sd	ra,8(sp)
     794:	e022                	sd	s0,0(sp)
     796:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
     798:	e05ff0ef          	jal	59c <main>
  exit(r);
     79c:	2aa000ef          	jal	a46 <exit>

00000000000007a0 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
     7a0:	1141                	addi	sp,sp,-16
     7a2:	e406                	sd	ra,8(sp)
     7a4:	e022                	sd	s0,0(sp)
     7a6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
     7a8:	87aa                	mv	a5,a0
     7aa:	0585                	addi	a1,a1,1
     7ac:	0785                	addi	a5,a5,1
     7ae:	fff5c703          	lbu	a4,-1(a1)
     7b2:	fee78fa3          	sb	a4,-1(a5)
     7b6:	fb75                	bnez	a4,7aa <strcpy+0xa>
    ;
  return os;
}
     7b8:	60a2                	ld	ra,8(sp)
     7ba:	6402                	ld	s0,0(sp)
     7bc:	0141                	addi	sp,sp,16
     7be:	8082                	ret

00000000000007c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     7c0:	1141                	addi	sp,sp,-16
     7c2:	e406                	sd	ra,8(sp)
     7c4:	e022                	sd	s0,0(sp)
     7c6:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
     7c8:	00054783          	lbu	a5,0(a0)
     7cc:	cb91                	beqz	a5,7e0 <strcmp+0x20>
     7ce:	0005c703          	lbu	a4,0(a1)
     7d2:	00f71763          	bne	a4,a5,7e0 <strcmp+0x20>
    p++, q++;
     7d6:	0505                	addi	a0,a0,1
     7d8:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
     7da:	00054783          	lbu	a5,0(a0)
     7de:	fbe5                	bnez	a5,7ce <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
     7e0:	0005c503          	lbu	a0,0(a1)
}
     7e4:	40a7853b          	subw	a0,a5,a0
     7e8:	60a2                	ld	ra,8(sp)
     7ea:	6402                	ld	s0,0(sp)
     7ec:	0141                	addi	sp,sp,16
     7ee:	8082                	ret

00000000000007f0 <strlen>:

uint
strlen(const char *s)
{
     7f0:	1141                	addi	sp,sp,-16
     7f2:	e406                	sd	ra,8(sp)
     7f4:	e022                	sd	s0,0(sp)
     7f6:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
     7f8:	00054783          	lbu	a5,0(a0)
     7fc:	cf91                	beqz	a5,818 <strlen+0x28>
     7fe:	00150793          	addi	a5,a0,1
     802:	86be                	mv	a3,a5
     804:	0785                	addi	a5,a5,1
     806:	fff7c703          	lbu	a4,-1(a5)
     80a:	ff65                	bnez	a4,802 <strlen+0x12>
     80c:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
     810:	60a2                	ld	ra,8(sp)
     812:	6402                	ld	s0,0(sp)
     814:	0141                	addi	sp,sp,16
     816:	8082                	ret
  for (n = 0; s[n]; n++)
     818:	4501                	li	a0,0
     81a:	bfdd                	j	810 <strlen+0x20>

000000000000081c <memset>:

void *
memset(void *dst, int c, uint n)
{
     81c:	1141                	addi	sp,sp,-16
     81e:	e406                	sd	ra,8(sp)
     820:	e022                	sd	s0,0(sp)
     822:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
     824:	ca19                	beqz	a2,83a <memset+0x1e>
     826:	87aa                	mv	a5,a0
     828:	1602                	slli	a2,a2,0x20
     82a:	9201                	srli	a2,a2,0x20
     82c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     830:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
     834:	0785                	addi	a5,a5,1
     836:	fee79de3          	bne	a5,a4,830 <memset+0x14>
  }
  return dst;
}
     83a:	60a2                	ld	ra,8(sp)
     83c:	6402                	ld	s0,0(sp)
     83e:	0141                	addi	sp,sp,16
     840:	8082                	ret

0000000000000842 <strchr>:

char *
strchr(const char *s, char c)
{
     842:	1141                	addi	sp,sp,-16
     844:	e406                	sd	ra,8(sp)
     846:	e022                	sd	s0,0(sp)
     848:	0800                	addi	s0,sp,16
  for (; *s; s++)
     84a:	00054783          	lbu	a5,0(a0)
     84e:	cf81                	beqz	a5,866 <strchr+0x24>
    if (*s == c)
     850:	00f58763          	beq	a1,a5,85e <strchr+0x1c>
  for (; *s; s++)
     854:	0505                	addi	a0,a0,1
     856:	00054783          	lbu	a5,0(a0)
     85a:	fbfd                	bnez	a5,850 <strchr+0xe>
      return (char *)s;
  return 0;
     85c:	4501                	li	a0,0
}
     85e:	60a2                	ld	ra,8(sp)
     860:	6402                	ld	s0,0(sp)
     862:	0141                	addi	sp,sp,16
     864:	8082                	ret
  return 0;
     866:	4501                	li	a0,0
     868:	bfdd                	j	85e <strchr+0x1c>

000000000000086a <gets>:

char *
gets(char *buf, int max)
{
     86a:	711d                	addi	sp,sp,-96
     86c:	ec86                	sd	ra,88(sp)
     86e:	e8a2                	sd	s0,80(sp)
     870:	e4a6                	sd	s1,72(sp)
     872:	e0ca                	sd	s2,64(sp)
     874:	fc4e                	sd	s3,56(sp)
     876:	f852                	sd	s4,48(sp)
     878:	f456                	sd	s5,40(sp)
     87a:	f05a                	sd	s6,32(sp)
     87c:	ec5e                	sd	s7,24(sp)
     87e:	e862                	sd	s8,16(sp)
     880:	1080                	addi	s0,sp,96
     882:	8baa                	mv	s7,a0
     884:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
     886:	892a                	mv	s2,a0
     888:	4481                	li	s1,0
    cc = read(0, &c, 1);
     88a:	faf40b13          	addi	s6,s0,-81
     88e:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
     890:	8c26                	mv	s8,s1
     892:	0014899b          	addiw	s3,s1,1
     896:	84ce                	mv	s1,s3
     898:	0349d463          	bge	s3,s4,8c0 <gets+0x56>
    cc = read(0, &c, 1);
     89c:	8656                	mv	a2,s5
     89e:	85da                	mv	a1,s6
     8a0:	4501                	li	a0,0
     8a2:	1bc000ef          	jal	a5e <read>
    if (cc < 1)
     8a6:	00a05d63          	blez	a0,8c0 <gets+0x56>
      break;
    buf[i++] = c;
     8aa:	faf44783          	lbu	a5,-81(s0)
     8ae:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
     8b2:	0905                	addi	s2,s2,1
     8b4:	ff678713          	addi	a4,a5,-10
     8b8:	c319                	beqz	a4,8be <gets+0x54>
     8ba:	17cd                	addi	a5,a5,-13
     8bc:	fbf1                	bnez	a5,890 <gets+0x26>
    buf[i++] = c;
     8be:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
     8c0:	9c5e                	add	s8,s8,s7
     8c2:	000c0023          	sb	zero,0(s8)
  return buf;
}
     8c6:	855e                	mv	a0,s7
     8c8:	60e6                	ld	ra,88(sp)
     8ca:	6446                	ld	s0,80(sp)
     8cc:	64a6                	ld	s1,72(sp)
     8ce:	6906                	ld	s2,64(sp)
     8d0:	79e2                	ld	s3,56(sp)
     8d2:	7a42                	ld	s4,48(sp)
     8d4:	7aa2                	ld	s5,40(sp)
     8d6:	7b02                	ld	s6,32(sp)
     8d8:	6be2                	ld	s7,24(sp)
     8da:	6c42                	ld	s8,16(sp)
     8dc:	6125                	addi	sp,sp,96
     8de:	8082                	ret

00000000000008e0 <stat>:

int
stat(const char *n, struct stat *st)
{
     8e0:	1101                	addi	sp,sp,-32
     8e2:	ec06                	sd	ra,24(sp)
     8e4:	e822                	sd	s0,16(sp)
     8e6:	e04a                	sd	s2,0(sp)
     8e8:	1000                	addi	s0,sp,32
     8ea:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     8ec:	4581                	li	a1,0
     8ee:	198000ef          	jal	a86 <open>
  if (fd < 0)
     8f2:	02054263          	bltz	a0,916 <stat+0x36>
     8f6:	e426                	sd	s1,8(sp)
     8f8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     8fa:	85ca                	mv	a1,s2
     8fc:	1a2000ef          	jal	a9e <fstat>
     900:	892a                	mv	s2,a0
  close(fd);
     902:	8526                	mv	a0,s1
     904:	16a000ef          	jal	a6e <close>
  return r;
     908:	64a2                	ld	s1,8(sp)
}
     90a:	854a                	mv	a0,s2
     90c:	60e2                	ld	ra,24(sp)
     90e:	6442                	ld	s0,16(sp)
     910:	6902                	ld	s2,0(sp)
     912:	6105                	addi	sp,sp,32
     914:	8082                	ret
    return -1;
     916:	57fd                	li	a5,-1
     918:	893e                	mv	s2,a5
     91a:	bfc5                	j	90a <stat+0x2a>

000000000000091c <atoi>:

int
atoi(const char *s)
{
     91c:	1141                	addi	sp,sp,-16
     91e:	e406                	sd	ra,8(sp)
     920:	e022                	sd	s0,0(sp)
     922:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
     924:	00054683          	lbu	a3,0(a0)
     928:	fd06879b          	addiw	a5,a3,-48
     92c:	0ff7f793          	zext.b	a5,a5
     930:	4625                	li	a2,9
     932:	02f66963          	bltu	a2,a5,964 <atoi+0x48>
     936:	872a                	mv	a4,a0
  n = 0;
     938:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
     93a:	0705                	addi	a4,a4,1
     93c:	0025179b          	slliw	a5,a0,0x2
     940:	9fa9                	addw	a5,a5,a0
     942:	0017979b          	slliw	a5,a5,0x1
     946:	9fb5                	addw	a5,a5,a3
     948:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
     94c:	00074683          	lbu	a3,0(a4)
     950:	fd06879b          	addiw	a5,a3,-48
     954:	0ff7f793          	zext.b	a5,a5
     958:	fef671e3          	bgeu	a2,a5,93a <atoi+0x1e>
  return n;
}
     95c:	60a2                	ld	ra,8(sp)
     95e:	6402                	ld	s0,0(sp)
     960:	0141                	addi	sp,sp,16
     962:	8082                	ret
  n = 0;
     964:	4501                	li	a0,0
     966:	bfdd                	j	95c <atoi+0x40>

0000000000000968 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
     968:	1141                	addi	sp,sp,-16
     96a:	e406                	sd	ra,8(sp)
     96c:	e022                	sd	s0,0(sp)
     96e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     970:	02b57563          	bgeu	a0,a1,99a <memmove+0x32>
    while (n-- > 0)
     974:	00c05f63          	blez	a2,992 <memmove+0x2a>
     978:	1602                	slli	a2,a2,0x20
     97a:	9201                	srli	a2,a2,0x20
     97c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     980:	872a                	mv	a4,a0
      *dst++ = *src++;
     982:	0585                	addi	a1,a1,1
     984:	0705                	addi	a4,a4,1
     986:	fff5c683          	lbu	a3,-1(a1)
     98a:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
     98e:	fee79ae3          	bne	a5,a4,982 <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     992:	60a2                	ld	ra,8(sp)
     994:	6402                	ld	s0,0(sp)
     996:	0141                	addi	sp,sp,16
     998:	8082                	ret
    while (n-- > 0)
     99a:	fec05ce3          	blez	a2,992 <memmove+0x2a>
    dst += n;
     99e:	00c50733          	add	a4,a0,a2
    src += n;
     9a2:	95b2                	add	a1,a1,a2
     9a4:	fff6079b          	addiw	a5,a2,-1
     9a8:	1782                	slli	a5,a5,0x20
     9aa:	9381                	srli	a5,a5,0x20
     9ac:	fff7c793          	not	a5,a5
     9b0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     9b2:	15fd                	addi	a1,a1,-1
     9b4:	177d                	addi	a4,a4,-1
     9b6:	0005c683          	lbu	a3,0(a1)
     9ba:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
     9be:	fef71ae3          	bne	a4,a5,9b2 <memmove+0x4a>
     9c2:	bfc1                	j	992 <memmove+0x2a>

00000000000009c4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     9c4:	1141                	addi	sp,sp,-16
     9c6:	e406                	sd	ra,8(sp)
     9c8:	e022                	sd	s0,0(sp)
     9ca:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     9cc:	c61d                	beqz	a2,9fa <memcmp+0x36>
     9ce:	1602                	slli	a2,a2,0x20
     9d0:	9201                	srli	a2,a2,0x20
     9d2:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
     9d6:	00054783          	lbu	a5,0(a0)
     9da:	0005c703          	lbu	a4,0(a1)
     9de:	00e79863          	bne	a5,a4,9ee <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
     9e2:	0505                	addi	a0,a0,1
    p2++;
     9e4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     9e6:	fed518e3          	bne	a0,a3,9d6 <memcmp+0x12>
  }
  return 0;
     9ea:	4501                	li	a0,0
     9ec:	a019                	j	9f2 <memcmp+0x2e>
      return *p1 - *p2;
     9ee:	40e7853b          	subw	a0,a5,a4
}
     9f2:	60a2                	ld	ra,8(sp)
     9f4:	6402                	ld	s0,0(sp)
     9f6:	0141                	addi	sp,sp,16
     9f8:	8082                	ret
  return 0;
     9fa:	4501                	li	a0,0
     9fc:	bfdd                	j	9f2 <memcmp+0x2e>

00000000000009fe <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     9fe:	1141                	addi	sp,sp,-16
     a00:	e406                	sd	ra,8(sp)
     a02:	e022                	sd	s0,0(sp)
     a04:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     a06:	f63ff0ef          	jal	968 <memmove>
}
     a0a:	60a2                	ld	ra,8(sp)
     a0c:	6402                	ld	s0,0(sp)
     a0e:	0141                	addi	sp,sp,16
     a10:	8082                	ret

0000000000000a12 <sbrk>:

char *
sbrk(int n)
{
     a12:	1141                	addi	sp,sp,-16
     a14:	e406                	sd	ra,8(sp)
     a16:	e022                	sd	s0,0(sp)
     a18:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
     a1a:	4585                	li	a1,1
     a1c:	0b2000ef          	jal	ace <sys_sbrk>
}
     a20:	60a2                	ld	ra,8(sp)
     a22:	6402                	ld	s0,0(sp)
     a24:	0141                	addi	sp,sp,16
     a26:	8082                	ret

0000000000000a28 <sbrklazy>:

char *
sbrklazy(int n)
{
     a28:	1141                	addi	sp,sp,-16
     a2a:	e406                	sd	ra,8(sp)
     a2c:	e022                	sd	s0,0(sp)
     a2e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
     a30:	4589                	li	a1,2
     a32:	09c000ef          	jal	ace <sys_sbrk>
}
     a36:	60a2                	ld	ra,8(sp)
     a38:	6402                	ld	s0,0(sp)
     a3a:	0141                	addi	sp,sp,16
     a3c:	8082                	ret

0000000000000a3e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     a3e:	4885                	li	a7,1
 ecall
     a40:	00000073          	ecall
 ret
     a44:	8082                	ret

0000000000000a46 <exit>:
.global exit
exit:
 li a7, SYS_exit
     a46:	4889                	li	a7,2
 ecall
     a48:	00000073          	ecall
 ret
     a4c:	8082                	ret

0000000000000a4e <wait>:
.global wait
wait:
 li a7, SYS_wait
     a4e:	488d                	li	a7,3
 ecall
     a50:	00000073          	ecall
 ret
     a54:	8082                	ret

0000000000000a56 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     a56:	4891                	li	a7,4
 ecall
     a58:	00000073          	ecall
 ret
     a5c:	8082                	ret

0000000000000a5e <read>:
.global read
read:
 li a7, SYS_read
     a5e:	4895                	li	a7,5
 ecall
     a60:	00000073          	ecall
 ret
     a64:	8082                	ret

0000000000000a66 <write>:
.global write
write:
 li a7, SYS_write
     a66:	48c1                	li	a7,16
 ecall
     a68:	00000073          	ecall
 ret
     a6c:	8082                	ret

0000000000000a6e <close>:
.global close
close:
 li a7, SYS_close
     a6e:	48d5                	li	a7,21
 ecall
     a70:	00000073          	ecall
 ret
     a74:	8082                	ret

0000000000000a76 <kill>:
.global kill
kill:
 li a7, SYS_kill
     a76:	4899                	li	a7,6
 ecall
     a78:	00000073          	ecall
 ret
     a7c:	8082                	ret

0000000000000a7e <exec>:
.global exec
exec:
 li a7, SYS_exec
     a7e:	489d                	li	a7,7
 ecall
     a80:	00000073          	ecall
 ret
     a84:	8082                	ret

0000000000000a86 <open>:
.global open
open:
 li a7, SYS_open
     a86:	48bd                	li	a7,15
 ecall
     a88:	00000073          	ecall
 ret
     a8c:	8082                	ret

0000000000000a8e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     a8e:	48c5                	li	a7,17
 ecall
     a90:	00000073          	ecall
 ret
     a94:	8082                	ret

0000000000000a96 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     a96:	48c9                	li	a7,18
 ecall
     a98:	00000073          	ecall
 ret
     a9c:	8082                	ret

0000000000000a9e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     a9e:	48a1                	li	a7,8
 ecall
     aa0:	00000073          	ecall
 ret
     aa4:	8082                	ret

0000000000000aa6 <link>:
.global link
link:
 li a7, SYS_link
     aa6:	48cd                	li	a7,19
 ecall
     aa8:	00000073          	ecall
 ret
     aac:	8082                	ret

0000000000000aae <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     aae:	48d1                	li	a7,20
 ecall
     ab0:	00000073          	ecall
 ret
     ab4:	8082                	ret

0000000000000ab6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     ab6:	48a5                	li	a7,9
 ecall
     ab8:	00000073          	ecall
 ret
     abc:	8082                	ret

0000000000000abe <dup>:
.global dup
dup:
 li a7, SYS_dup
     abe:	48a9                	li	a7,10
 ecall
     ac0:	00000073          	ecall
 ret
     ac4:	8082                	ret

0000000000000ac6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     ac6:	48ad                	li	a7,11
 ecall
     ac8:	00000073          	ecall
 ret
     acc:	8082                	ret

0000000000000ace <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
     ace:	48b1                	li	a7,12
 ecall
     ad0:	00000073          	ecall
 ret
     ad4:	8082                	ret

0000000000000ad6 <pause>:
.global pause
pause:
 li a7, SYS_pause
     ad6:	48b5                	li	a7,13
 ecall
     ad8:	00000073          	ecall
 ret
     adc:	8082                	ret

0000000000000ade <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     ade:	48b9                	li	a7,14
 ecall
     ae0:	00000073          	ecall
 ret
     ae4:	8082                	ret

0000000000000ae6 <sync>:
.global sync
sync:
 li a7, SYS_sync
     ae6:	48d9                	li	a7,22
 ecall
     ae8:	00000073          	ecall
 ret
     aec:	8082                	ret

0000000000000aee <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     aee:	1101                	addi	sp,sp,-32
     af0:	ec06                	sd	ra,24(sp)
     af2:	e822                	sd	s0,16(sp)
     af4:	1000                	addi	s0,sp,32
     af6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     afa:	4605                	li	a2,1
     afc:	fef40593          	addi	a1,s0,-17
     b00:	f67ff0ef          	jal	a66 <write>
}
     b04:	60e2                	ld	ra,24(sp)
     b06:	6442                	ld	s0,16(sp)
     b08:	6105                	addi	sp,sp,32
     b0a:	8082                	ret

0000000000000b0c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
     b0c:	715d                	addi	sp,sp,-80
     b0e:	e486                	sd	ra,72(sp)
     b10:	e0a2                	sd	s0,64(sp)
     b12:	f84a                	sd	s2,48(sp)
     b14:	f44e                	sd	s3,40(sp)
     b16:	0880                	addi	s0,sp,80
     b18:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
     b1a:	c6d1                	beqz	a3,ba6 <printint+0x9a>
     b1c:	0805d563          	bgez	a1,ba6 <printint+0x9a>
    neg = 1;
    x = -xx;
     b20:	40b005b3          	neg	a1,a1
    neg = 1;
     b24:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
     b26:	fb840993          	addi	s3,s0,-72
  neg = 0;
     b2a:	86ce                	mv	a3,s3
  i = 0;
     b2c:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
     b2e:	00001817          	auipc	a6,0x1
     b32:	93a80813          	addi	a6,a6,-1734 # 1468 <digits>
     b36:	88ba                	mv	a7,a4
     b38:	0017051b          	addiw	a0,a4,1
     b3c:	872a                	mv	a4,a0
     b3e:	02c5f7b3          	remu	a5,a1,a2
     b42:	97c2                	add	a5,a5,a6
     b44:	0007c783          	lbu	a5,0(a5)
     b48:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
     b4c:	87ae                	mv	a5,a1
     b4e:	02c5d5b3          	divu	a1,a1,a2
     b52:	0685                	addi	a3,a3,1
     b54:	fec7f1e3          	bgeu	a5,a2,b36 <printint+0x2a>
  if (neg)
     b58:	00030c63          	beqz	t1,b70 <printint+0x64>
    buf[i++] = '-';
     b5c:	fd050793          	addi	a5,a0,-48
     b60:	00878533          	add	a0,a5,s0
     b64:	02d00793          	li	a5,45
     b68:	fef50423          	sb	a5,-24(a0)
     b6c:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
     b70:	02e05563          	blez	a4,b9a <printint+0x8e>
     b74:	fc26                	sd	s1,56(sp)
     b76:	377d                	addiw	a4,a4,-1
     b78:	00e984b3          	add	s1,s3,a4
     b7c:	19fd                	addi	s3,s3,-1
     b7e:	99ba                	add	s3,s3,a4
     b80:	1702                	slli	a4,a4,0x20
     b82:	9301                	srli	a4,a4,0x20
     b84:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     b88:	0004c583          	lbu	a1,0(s1)
     b8c:	854a                	mv	a0,s2
     b8e:	f61ff0ef          	jal	aee <putc>
  while (--i >= 0)
     b92:	14fd                	addi	s1,s1,-1
     b94:	ff349ae3          	bne	s1,s3,b88 <printint+0x7c>
     b98:	74e2                	ld	s1,56(sp)
}
     b9a:	60a6                	ld	ra,72(sp)
     b9c:	6406                	ld	s0,64(sp)
     b9e:	7942                	ld	s2,48(sp)
     ba0:	79a2                	ld	s3,40(sp)
     ba2:	6161                	addi	sp,sp,80
     ba4:	8082                	ret
  neg = 0;
     ba6:	4301                	li	t1,0
     ba8:	bfbd                	j	b26 <printint+0x1a>

0000000000000baa <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     baa:	711d                	addi	sp,sp,-96
     bac:	ec86                	sd	ra,88(sp)
     bae:	e8a2                	sd	s0,80(sp)
     bb0:	e4a6                	sd	s1,72(sp)
     bb2:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
     bb4:	0005c483          	lbu	s1,0(a1)
     bb8:	22048363          	beqz	s1,dde <vprintf+0x234>
     bbc:	e0ca                	sd	s2,64(sp)
     bbe:	fc4e                	sd	s3,56(sp)
     bc0:	f852                	sd	s4,48(sp)
     bc2:	f456                	sd	s5,40(sp)
     bc4:	f05a                	sd	s6,32(sp)
     bc6:	ec5e                	sd	s7,24(sp)
     bc8:	e862                	sd	s8,16(sp)
     bca:	8b2a                	mv	s6,a0
     bcc:	8a2e                	mv	s4,a1
     bce:	8bb2                	mv	s7,a2
  state = 0;
     bd0:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
     bd2:	4901                	li	s2,0
     bd4:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
     bd6:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
     bda:	06400c13          	li	s8,100
     bde:	a00d                	j	c00 <vprintf+0x56>
        putc(fd, c0);
     be0:	85a6                	mv	a1,s1
     be2:	855a                	mv	a0,s6
     be4:	f0bff0ef          	jal	aee <putc>
     be8:	a019                	j	bee <vprintf+0x44>
    } else if (state == '%') {
     bea:	03598363          	beq	s3,s5,c10 <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
     bee:	0019079b          	addiw	a5,s2,1
     bf2:	893e                	mv	s2,a5
     bf4:	873e                	mv	a4,a5
     bf6:	97d2                	add	a5,a5,s4
     bf8:	0007c483          	lbu	s1,0(a5)
     bfc:	1c048a63          	beqz	s1,dd0 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
     c00:	0004879b          	sext.w	a5,s1
    if (state == 0) {
     c04:	fe0993e3          	bnez	s3,bea <vprintf+0x40>
      if (c0 == '%') {
     c08:	fd579ce3          	bne	a5,s5,be0 <vprintf+0x36>
        state = '%';
     c0c:	89be                	mv	s3,a5
     c0e:	b7c5                	j	bee <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
     c10:	00ea06b3          	add	a3,s4,a4
     c14:	0016c603          	lbu	a2,1(a3)
      if (c1)
     c18:	1c060863          	beqz	a2,de8 <vprintf+0x23e>
      if (c0 == 'd') {
     c1c:	03878763          	beq	a5,s8,c4a <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
     c20:	f9478693          	addi	a3,a5,-108
     c24:	0016b693          	seqz	a3,a3
     c28:	f9c60593          	addi	a1,a2,-100
     c2c:	e99d                	bnez	a1,c62 <vprintf+0xb8>
     c2e:	ca95                	beqz	a3,c62 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
     c30:	008b8493          	addi	s1,s7,8
     c34:	4685                	li	a3,1
     c36:	4629                	li	a2,10
     c38:	000bb583          	ld	a1,0(s7)
     c3c:	855a                	mv	a0,s6
     c3e:	ecfff0ef          	jal	b0c <printint>
        i += 1;
     c42:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
     c44:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
     c46:	4981                	li	s3,0
     c48:	b75d                	j	bee <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
     c4a:	008b8493          	addi	s1,s7,8
     c4e:	4685                	li	a3,1
     c50:	4629                	li	a2,10
     c52:	000ba583          	lw	a1,0(s7)
     c56:	855a                	mv	a0,s6
     c58:	eb5ff0ef          	jal	b0c <printint>
     c5c:	8ba6                	mv	s7,s1
      state = 0;
     c5e:	4981                	li	s3,0
     c60:	b779                	j	bee <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
     c62:	9752                	add	a4,a4,s4
     c64:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
     c68:	f9460713          	addi	a4,a2,-108
     c6c:	00173713          	seqz	a4,a4
     c70:	8f75                	and	a4,a4,a3
     c72:	f9c58513          	addi	a0,a1,-100
     c76:	18051363          	bnez	a0,dfc <vprintf+0x252>
     c7a:	18070163          	beqz	a4,dfc <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
     c7e:	008b8493          	addi	s1,s7,8
     c82:	4685                	li	a3,1
     c84:	4629                	li	a2,10
     c86:	000bb583          	ld	a1,0(s7)
     c8a:	855a                	mv	a0,s6
     c8c:	e81ff0ef          	jal	b0c <printint>
        i += 2;
     c90:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
     c92:	8ba6                	mv	s7,s1
      state = 0;
     c94:	4981                	li	s3,0
        i += 2;
     c96:	bfa1                	j	bee <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
     c98:	008b8493          	addi	s1,s7,8
     c9c:	4681                	li	a3,0
     c9e:	4629                	li	a2,10
     ca0:	000be583          	lwu	a1,0(s7)
     ca4:	855a                	mv	a0,s6
     ca6:	e67ff0ef          	jal	b0c <printint>
     caa:	8ba6                	mv	s7,s1
      state = 0;
     cac:	4981                	li	s3,0
     cae:	b781                	j	bee <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
     cb0:	008b8493          	addi	s1,s7,8
     cb4:	4681                	li	a3,0
     cb6:	4629                	li	a2,10
     cb8:	000bb583          	ld	a1,0(s7)
     cbc:	855a                	mv	a0,s6
     cbe:	e4fff0ef          	jal	b0c <printint>
        i += 1;
     cc2:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
     cc4:	8ba6                	mv	s7,s1
      state = 0;
     cc6:	4981                	li	s3,0
     cc8:	b71d                	j	bee <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
     cca:	008b8493          	addi	s1,s7,8
     cce:	4681                	li	a3,0
     cd0:	4629                	li	a2,10
     cd2:	000bb583          	ld	a1,0(s7)
     cd6:	855a                	mv	a0,s6
     cd8:	e35ff0ef          	jal	b0c <printint>
        i += 2;
     cdc:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
     cde:	8ba6                	mv	s7,s1
      state = 0;
     ce0:	4981                	li	s3,0
        i += 2;
     ce2:	b731                	j	bee <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
     ce4:	008b8493          	addi	s1,s7,8
     ce8:	4681                	li	a3,0
     cea:	4641                	li	a2,16
     cec:	000be583          	lwu	a1,0(s7)
     cf0:	855a                	mv	a0,s6
     cf2:	e1bff0ef          	jal	b0c <printint>
     cf6:	8ba6                	mv	s7,s1
      state = 0;
     cf8:	4981                	li	s3,0
     cfa:	bdd5                	j	bee <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
     cfc:	008b8493          	addi	s1,s7,8
     d00:	4681                	li	a3,0
     d02:	4641                	li	a2,16
     d04:	000bb583          	ld	a1,0(s7)
     d08:	855a                	mv	a0,s6
     d0a:	e03ff0ef          	jal	b0c <printint>
        i += 1;
     d0e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
     d10:	8ba6                	mv	s7,s1
      state = 0;
     d12:	4981                	li	s3,0
     d14:	bde9                	j	bee <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
     d16:	008b8493          	addi	s1,s7,8
     d1a:	4681                	li	a3,0
     d1c:	4641                	li	a2,16
     d1e:	000bb583          	ld	a1,0(s7)
     d22:	855a                	mv	a0,s6
     d24:	de9ff0ef          	jal	b0c <printint>
        i += 2;
     d28:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
     d2a:	8ba6                	mv	s7,s1
      state = 0;
     d2c:	4981                	li	s3,0
        i += 2;
     d2e:	b5c1                	j	bee <vprintf+0x44>
     d30:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
     d32:	008b8793          	addi	a5,s7,8
     d36:	8cbe                	mv	s9,a5
     d38:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
     d3c:	03000593          	li	a1,48
     d40:	855a                	mv	a0,s6
     d42:	dadff0ef          	jal	aee <putc>
  putc(fd, 'x');
     d46:	07800593          	li	a1,120
     d4a:	855a                	mv	a0,s6
     d4c:	da3ff0ef          	jal	aee <putc>
     d50:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     d52:	00000b97          	auipc	s7,0x0
     d56:	716b8b93          	addi	s7,s7,1814 # 1468 <digits>
     d5a:	03c9d793          	srli	a5,s3,0x3c
     d5e:	97de                	add	a5,a5,s7
     d60:	0007c583          	lbu	a1,0(a5)
     d64:	855a                	mv	a0,s6
     d66:	d89ff0ef          	jal	aee <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     d6a:	0992                	slli	s3,s3,0x4
     d6c:	34fd                	addiw	s1,s1,-1
     d6e:	f4f5                	bnez	s1,d5a <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
     d70:	8be6                	mv	s7,s9
      state = 0;
     d72:	4981                	li	s3,0
     d74:	6ca2                	ld	s9,8(sp)
     d76:	bda5                	j	bee <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
     d78:	008b8493          	addi	s1,s7,8
     d7c:	000bc583          	lbu	a1,0(s7)
     d80:	855a                	mv	a0,s6
     d82:	d6dff0ef          	jal	aee <putc>
     d86:	8ba6                	mv	s7,s1
      state = 0;
     d88:	4981                	li	s3,0
     d8a:	b595                	j	bee <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
     d8c:	008b8993          	addi	s3,s7,8
     d90:	000bb483          	ld	s1,0(s7)
     d94:	cc91                	beqz	s1,db0 <vprintf+0x206>
        for (; *s; s++)
     d96:	0004c583          	lbu	a1,0(s1)
     d9a:	c985                	beqz	a1,dca <vprintf+0x220>
          putc(fd, *s);
     d9c:	855a                	mv	a0,s6
     d9e:	d51ff0ef          	jal	aee <putc>
        for (; *s; s++)
     da2:	0485                	addi	s1,s1,1
     da4:	0004c583          	lbu	a1,0(s1)
     da8:	f9f5                	bnez	a1,d9c <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
     daa:	8bce                	mv	s7,s3
      state = 0;
     dac:	4981                	li	s3,0
     dae:	b581                	j	bee <vprintf+0x44>
          s = "(null)";
     db0:	00000497          	auipc	s1,0x0
     db4:	6b048493          	addi	s1,s1,1712 # 1460 <malloc+0x514>
        for (; *s; s++)
     db8:	02800593          	li	a1,40
     dbc:	b7c5                	j	d9c <vprintf+0x1f2>
        putc(fd, '%');
     dbe:	85be                	mv	a1,a5
     dc0:	855a                	mv	a0,s6
     dc2:	d2dff0ef          	jal	aee <putc>
      state = 0;
     dc6:	4981                	li	s3,0
     dc8:	b51d                	j	bee <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
     dca:	8bce                	mv	s7,s3
      state = 0;
     dcc:	4981                	li	s3,0
     dce:	b505                	j	bee <vprintf+0x44>
     dd0:	6906                	ld	s2,64(sp)
     dd2:	79e2                	ld	s3,56(sp)
     dd4:	7a42                	ld	s4,48(sp)
     dd6:	7aa2                	ld	s5,40(sp)
     dd8:	7b02                	ld	s6,32(sp)
     dda:	6be2                	ld	s7,24(sp)
     ddc:	6c42                	ld	s8,16(sp)
    }
  }
}
     dde:	60e6                	ld	ra,88(sp)
     de0:	6446                	ld	s0,80(sp)
     de2:	64a6                	ld	s1,72(sp)
     de4:	6125                	addi	sp,sp,96
     de6:	8082                	ret
      if (c0 == 'd') {
     de8:	06400713          	li	a4,100
     dec:	e4e78fe3          	beq	a5,a4,c4a <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
     df0:	f9478693          	addi	a3,a5,-108
     df4:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
     df8:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
     dfa:	4701                	li	a4,0
      } else if (c0 == 'u') {
     dfc:	07500513          	li	a0,117
     e00:	e8a78ce3          	beq	a5,a0,c98 <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
     e04:	f8b60513          	addi	a0,a2,-117
     e08:	e119                	bnez	a0,e0e <vprintf+0x264>
     e0a:	ea0693e3          	bnez	a3,cb0 <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
     e0e:	f8b58513          	addi	a0,a1,-117
     e12:	e119                	bnez	a0,e18 <vprintf+0x26e>
     e14:	ea071be3          	bnez	a4,cca <vprintf+0x120>
      } else if (c0 == 'x') {
     e18:	07800513          	li	a0,120
     e1c:	eca784e3          	beq	a5,a0,ce4 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
     e20:	f8860613          	addi	a2,a2,-120
     e24:	e219                	bnez	a2,e2a <vprintf+0x280>
     e26:	ec069be3          	bnez	a3,cfc <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
     e2a:	f8858593          	addi	a1,a1,-120
     e2e:	e199                	bnez	a1,e34 <vprintf+0x28a>
     e30:	ee0713e3          	bnez	a4,d16 <vprintf+0x16c>
      } else if (c0 == 'p') {
     e34:	07000713          	li	a4,112
     e38:	eee78ce3          	beq	a5,a4,d30 <vprintf+0x186>
      } else if (c0 == 'c') {
     e3c:	06300713          	li	a4,99
     e40:	f2e78ce3          	beq	a5,a4,d78 <vprintf+0x1ce>
      } else if (c0 == 's') {
     e44:	07300713          	li	a4,115
     e48:	f4e782e3          	beq	a5,a4,d8c <vprintf+0x1e2>
      } else if (c0 == '%') {
     e4c:	02500713          	li	a4,37
     e50:	f6e787e3          	beq	a5,a4,dbe <vprintf+0x214>
        putc(fd, '%');
     e54:	02500593          	li	a1,37
     e58:	855a                	mv	a0,s6
     e5a:	c95ff0ef          	jal	aee <putc>
        putc(fd, c0);
     e5e:	85a6                	mv	a1,s1
     e60:	855a                	mv	a0,s6
     e62:	c8dff0ef          	jal	aee <putc>
      state = 0;
     e66:	4981                	li	s3,0
     e68:	b359                	j	bee <vprintf+0x44>

0000000000000e6a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
     e6a:	715d                	addi	sp,sp,-80
     e6c:	ec06                	sd	ra,24(sp)
     e6e:	e822                	sd	s0,16(sp)
     e70:	1000                	addi	s0,sp,32
     e72:	e010                	sd	a2,0(s0)
     e74:	e414                	sd	a3,8(s0)
     e76:	e818                	sd	a4,16(s0)
     e78:	ec1c                	sd	a5,24(s0)
     e7a:	03043023          	sd	a6,32(s0)
     e7e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
     e82:	8622                	mv	a2,s0
     e84:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
     e88:	d23ff0ef          	jal	baa <vprintf>
}
     e8c:	60e2                	ld	ra,24(sp)
     e8e:	6442                	ld	s0,16(sp)
     e90:	6161                	addi	sp,sp,80
     e92:	8082                	ret

0000000000000e94 <printf>:

void
printf(const char *fmt, ...)
{
     e94:	711d                	addi	sp,sp,-96
     e96:	ec06                	sd	ra,24(sp)
     e98:	e822                	sd	s0,16(sp)
     e9a:	1000                	addi	s0,sp,32
     e9c:	e40c                	sd	a1,8(s0)
     e9e:	e810                	sd	a2,16(s0)
     ea0:	ec14                	sd	a3,24(s0)
     ea2:	f018                	sd	a4,32(s0)
     ea4:	f41c                	sd	a5,40(s0)
     ea6:	03043823          	sd	a6,48(s0)
     eaa:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
     eae:	00840613          	addi	a2,s0,8
     eb2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
     eb6:	85aa                	mv	a1,a0
     eb8:	4505                	li	a0,1
     eba:	cf1ff0ef          	jal	baa <vprintf>
}
     ebe:	60e2                	ld	ra,24(sp)
     ec0:	6442                	ld	s0,16(sp)
     ec2:	6125                	addi	sp,sp,96
     ec4:	8082                	ret

0000000000000ec6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
     ec6:	1141                	addi	sp,sp,-16
     ec8:	e406                	sd	ra,8(sp)
     eca:	e022                	sd	s0,0(sp)
     ecc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
     ece:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     ed2:	00001797          	auipc	a5,0x1
     ed6:	13e7b783          	ld	a5,318(a5) # 2010 <freep>
     eda:	a039                	j	ee8 <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     edc:	6398                	ld	a4,0(a5)
     ede:	00e7e463          	bltu	a5,a4,ee6 <free+0x20>
     ee2:	00e6ea63          	bltu	a3,a4,ef6 <free+0x30>
{
     ee6:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     ee8:	fed7fae3          	bgeu	a5,a3,edc <free+0x16>
     eec:	6398                	ld	a4,0(a5)
     eee:	00e6e463          	bltu	a3,a4,ef6 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     ef2:	fee7eae3          	bltu	a5,a4,ee6 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
     ef6:	ff852583          	lw	a1,-8(a0)
     efa:	6390                	ld	a2,0(a5)
     efc:	02059813          	slli	a6,a1,0x20
     f00:	01c85713          	srli	a4,a6,0x1c
     f04:	9736                	add	a4,a4,a3
     f06:	02e60563          	beq	a2,a4,f30 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
     f0a:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
     f0e:	4790                	lw	a2,8(a5)
     f10:	02061593          	slli	a1,a2,0x20
     f14:	01c5d713          	srli	a4,a1,0x1c
     f18:	973e                	add	a4,a4,a5
     f1a:	02e68263          	beq	a3,a4,f3e <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
     f1e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
     f20:	00001717          	auipc	a4,0x1
     f24:	0ef73823          	sd	a5,240(a4) # 2010 <freep>
}
     f28:	60a2                	ld	ra,8(sp)
     f2a:	6402                	ld	s0,0(sp)
     f2c:	0141                	addi	sp,sp,16
     f2e:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
     f30:	4618                	lw	a4,8(a2)
     f32:	9f2d                	addw	a4,a4,a1
     f34:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
     f38:	6398                	ld	a4,0(a5)
     f3a:	6310                	ld	a2,0(a4)
     f3c:	b7f9                	j	f0a <free+0x44>
    p->s.size += bp->s.size;
     f3e:	ff852703          	lw	a4,-8(a0)
     f42:	9f31                	addw	a4,a4,a2
     f44:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
     f46:	ff053683          	ld	a3,-16(a0)
     f4a:	bfd1                	j	f1e <free+0x58>

0000000000000f4c <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
     f4c:	7139                	addi	sp,sp,-64
     f4e:	fc06                	sd	ra,56(sp)
     f50:	f822                	sd	s0,48(sp)
     f52:	f04a                	sd	s2,32(sp)
     f54:	ec4e                	sd	s3,24(sp)
     f56:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
     f58:	02051993          	slli	s3,a0,0x20
     f5c:	0209d993          	srli	s3,s3,0x20
     f60:	09bd                	addi	s3,s3,15
     f62:	0049d993          	srli	s3,s3,0x4
     f66:	2985                	addiw	s3,s3,1
     f68:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
     f6a:	00001517          	auipc	a0,0x1
     f6e:	0a653503          	ld	a0,166(a0) # 2010 <freep>
     f72:	c905                	beqz	a0,fa2 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
     f74:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
     f76:	4798                	lw	a4,8(a5)
     f78:	09377663          	bgeu	a4,s3,1004 <malloc+0xb8>
     f7c:	f426                	sd	s1,40(sp)
     f7e:	e852                	sd	s4,16(sp)
     f80:	e456                	sd	s5,8(sp)
     f82:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
     f84:	8a4e                	mv	s4,s3
     f86:	6705                	lui	a4,0x1
     f88:	00e9f363          	bgeu	s3,a4,f8e <malloc+0x42>
     f8c:	6a05                	lui	s4,0x1
     f8e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
     f92:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
     f96:	00001497          	auipc	s1,0x1
     f9a:	07a48493          	addi	s1,s1,122 # 2010 <freep>
  if (p == SBRK_ERROR)
     f9e:	5afd                	li	s5,-1
     fa0:	a83d                	j	fde <malloc+0x92>
     fa2:	f426                	sd	s1,40(sp)
     fa4:	e852                	sd	s4,16(sp)
     fa6:	e456                	sd	s5,8(sp)
     fa8:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
     faa:	00001797          	auipc	a5,0x1
     fae:	0c678793          	addi	a5,a5,198 # 2070 <base>
     fb2:	00001717          	auipc	a4,0x1
     fb6:	04f73f23          	sd	a5,94(a4) # 2010 <freep>
     fba:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
     fbc:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
     fc0:	b7d1                	j	f84 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
     fc2:	6398                	ld	a4,0(a5)
     fc4:	e118                	sd	a4,0(a0)
     fc6:	a899                	j	101c <malloc+0xd0>
  hp->s.size = nu;
     fc8:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
     fcc:	0541                	addi	a0,a0,16
     fce:	ef9ff0ef          	jal	ec6 <free>
  return freep;
     fd2:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
     fd4:	c125                	beqz	a0,1034 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
     fd6:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
     fd8:	4798                	lw	a4,8(a5)
     fda:	03277163          	bgeu	a4,s2,ffc <malloc+0xb0>
    if (p == freep)
     fde:	6098                	ld	a4,0(s1)
     fe0:	853e                	mv	a0,a5
     fe2:	fef71ae3          	bne	a4,a5,fd6 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
     fe6:	8552                	mv	a0,s4
     fe8:	a2bff0ef          	jal	a12 <sbrk>
  if (p == SBRK_ERROR)
     fec:	fd551ee3          	bne	a0,s5,fc8 <malloc+0x7c>
        return 0;
     ff0:	4501                	li	a0,0
     ff2:	74a2                	ld	s1,40(sp)
     ff4:	6a42                	ld	s4,16(sp)
     ff6:	6aa2                	ld	s5,8(sp)
     ff8:	6b02                	ld	s6,0(sp)
     ffa:	a03d                	j	1028 <malloc+0xdc>
     ffc:	74a2                	ld	s1,40(sp)
     ffe:	6a42                	ld	s4,16(sp)
    1000:	6aa2                	ld	s5,8(sp)
    1002:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
    1004:	fae90fe3          	beq	s2,a4,fc2 <malloc+0x76>
        p->s.size -= nunits;
    1008:	4137073b          	subw	a4,a4,s3
    100c:	c798                	sw	a4,8(a5)
        p += p->s.size;
    100e:	02071693          	slli	a3,a4,0x20
    1012:	01c6d713          	srli	a4,a3,0x1c
    1016:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1018:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    101c:	00001717          	auipc	a4,0x1
    1020:	fea73a23          	sd	a0,-12(a4) # 2010 <freep>
      return (void *)(p + 1);
    1024:	01078513          	addi	a0,a5,16
  }
}
    1028:	70e2                	ld	ra,56(sp)
    102a:	7442                	ld	s0,48(sp)
    102c:	7902                	ld	s2,32(sp)
    102e:	69e2                	ld	s3,24(sp)
    1030:	6121                	addi	sp,sp,64
    1032:	8082                	ret
    1034:	74a2                	ld	s1,40(sp)
    1036:	6a42                	ld	s4,16(sp)
    1038:	6aa2                	ld	s5,8(sp)
    103a:	6b02                	ld	s6,0(sp)
    103c:	b7f5                	j	1028 <malloc+0xdc>
