
user/_deadlock:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print_state>:
static int finish[MAX_PROC];

// Print Available, Allocation, Request/Need matrices
void print_state(int n, int m, int alloc[MAX_PROC][MAX_RES],
                 int second_matrix[MAX_PROC][MAX_RES], char *second_name,
                 int avail[MAX_RES]) {
       0:	7119                	addi	sp,sp,-128
       2:	fc86                	sd	ra,120(sp)
       4:	f8a2                	sd	s0,112(sp)
       6:	f4a6                	sd	s1,104(sp)
       8:	f0ca                	sd	s2,96(sp)
       a:	ecce                	sd	s3,88(sp)
       c:	e8d2                	sd	s4,80(sp)
       e:	e4d6                	sd	s5,72(sp)
      10:	e0da                	sd	s6,64(sp)
      12:	fc5e                	sd	s7,56(sp)
      14:	f862                	sd	s8,48(sp)
      16:	0100                	addi	s0,sp,128
      18:	8c2a                	mv	s8,a0
      1a:	8b2e                	mv	s6,a1
      1c:	89b2                	mv	s3,a2
      1e:	8a36                	mv	s4,a3
      20:	84ba                	mv	s1,a4
      22:	f8f43423          	sd	a5,-120(s0)
  printf("\n--- System Resource State ---\n");
      26:	00001517          	auipc	a0,0x1
      2a:	47a50513          	addi	a0,a0,1146 # 14a0 <malloc+0xf4>
      2e:	2c6010ef          	jal	12f4 <printf>
  printf("Proc | Allocation | %s\n", second_name);
      32:	85a6                	mv	a1,s1
      34:	00001517          	auipc	a0,0x1
      38:	48c50513          	addi	a0,a0,1164 # 14c0 <malloc+0x114>
      3c:	2b8010ef          	jal	12f4 <printf>
  printf("     | ");
      40:	00001517          	auipc	a0,0x1
      44:	49850513          	addi	a0,a0,1176 # 14d8 <malloc+0x12c>
      48:	2ac010ef          	jal	12f4 <printf>
  for (int j = 0; j < m; j++) printf("R%d ", j);
      4c:	19605663          	blez	s6,1d8 <print_state+0x1d8>
      50:	4481                	li	s1,0
      52:	00001a97          	auipc	s5,0x1
      56:	48ea8a93          	addi	s5,s5,1166 # 14e0 <malloc+0x134>
      5a:	85a6                	mv	a1,s1
      5c:	8556                	mv	a0,s5
      5e:	296010ef          	jal	12f4 <printf>
      62:	8926                	mv	s2,s1
      64:	2485                	addiw	s1,s1,1
      66:	fe9b1ae3          	bne	s6,s1,5a <print_state+0x5a>
  printf("| ");
      6a:	00001517          	auipc	a0,0x1
      6e:	48650513          	addi	a0,a0,1158 # 14f0 <malloc+0x144>
      72:	282010ef          	jal	12f4 <printf>
  for (int j = 0; j < m; j++) printf("R%d ", j);
      76:	4481                	li	s1,0
      78:	00001b97          	auipc	s7,0x1
      7c:	468b8b93          	addi	s7,s7,1128 # 14e0 <malloc+0x134>
      80:	00190a9b          	addiw	s5,s2,1
      84:	85a6                	mv	a1,s1
      86:	855e                	mv	a0,s7
      88:	26c010ef          	jal	12f4 <printf>
      8c:	2485                	addiw	s1,s1,1
      8e:	fe9a9be3          	bne	s5,s1,84 <print_state+0x84>
  printf("\n-----+");
      92:	00001517          	auipc	a0,0x1
      96:	46650513          	addi	a0,a0,1126 # 14f8 <malloc+0x14c>
      9a:	25a010ef          	jal	12f4 <printf>
  for (int j = 0; j < m; j++) printf("---");
      9e:	4481                	li	s1,0
      a0:	00001b97          	auipc	s7,0x1
      a4:	460b8b93          	addi	s7,s7,1120 # 1500 <malloc+0x154>
      a8:	00190a9b          	addiw	s5,s2,1
      ac:	855e                	mv	a0,s7
      ae:	246010ef          	jal	12f4 <printf>
      b2:	2485                	addiw	s1,s1,1
      b4:	fe9a9ce3          	bne	s5,s1,ac <print_state+0xac>
  printf("-+-");
      b8:	00001517          	auipc	a0,0x1
      bc:	45050513          	addi	a0,a0,1104 # 1508 <malloc+0x15c>
      c0:	234010ef          	jal	12f4 <printf>
  for (int j = 0; j < m; j++) printf("---");
      c4:	4481                	li	s1,0
      c6:	00001a97          	auipc	s5,0x1
      ca:	43aa8a93          	addi	s5,s5,1082 # 1500 <malloc+0x154>
      ce:	2905                	addiw	s2,s2,1
      d0:	8556                	mv	a0,s5
      d2:	222010ef          	jal	12f4 <printf>
      d6:	2485                	addiw	s1,s1,1
      d8:	fe991ce3          	bne	s2,s1,d0 <print_state+0xd0>
  printf("\n");
      dc:	00001517          	auipc	a0,0x1
      e0:	43450513          	addi	a0,a0,1076 # 1510 <malloc+0x164>
      e4:	210010ef          	jal	12f4 <printf>

  for (int i = 0; i < n; i++) {
      e8:	13805963          	blez	s8,21a <print_state+0x21a>
      ec:	f466                	sd	s9,40(sp)
      ee:	f06a                	sd	s10,32(sp)
      f0:	ec6e                	sd	s11,24(sp)
      f2:	002b1793          	slli	a5,s6,0x2
      f6:	99be                	add	s3,s3,a5
      f8:	9a3e                	add	s4,s4,a5
      fa:	41600bb3          	neg	s7,s6
      fe:	0b8a                	slli	s7,s7,0x2
     100:	4a81                	li	s5,0
    printf(" P%d  | ", i);
     102:	00001d17          	auipc	s10,0x1
     106:	416d0d13          	addi	s10,s10,1046 # 1518 <malloc+0x16c>
    for (int j = 0; j < m; j++) printf(" %d ", alloc[i][j]);
    printf("| ");
     10a:	00001d97          	auipc	s11,0x1
     10e:	3e6d8d93          	addi	s11,s11,998 # 14f0 <malloc+0x144>
    for (int j = 0; j < m; j++) printf(" %d ", alloc[i][j]);
     112:	00001917          	auipc	s2,0x1
     116:	41690913          	addi	s2,s2,1046 # 1528 <malloc+0x17c>
    for (int j = 0; j < m; j++) printf(" %d ", second_matrix[i][j]);
    printf("\n");
     11a:	00001c97          	auipc	s9,0x1
     11e:	3f6c8c93          	addi	s9,s9,1014 # 1510 <malloc+0x164>
    printf(" P%d  | ", i);
     122:	85d6                	mv	a1,s5
     124:	856a                	mv	a0,s10
     126:	1ce010ef          	jal	12f4 <printf>
    for (int j = 0; j < m; j++) printf(" %d ", alloc[i][j]);
     12a:	0b605363          	blez	s6,1d0 <print_state+0x1d0>
     12e:	017984b3          	add	s1,s3,s7
     132:	408c                	lw	a1,0(s1)
     134:	854a                	mv	a0,s2
     136:	1be010ef          	jal	12f4 <printf>
     13a:	0491                	addi	s1,s1,4
     13c:	ff349be3          	bne	s1,s3,132 <print_state+0x132>
    printf("| ");
     140:	856e                	mv	a0,s11
     142:	1b2010ef          	jal	12f4 <printf>
    for (int j = 0; j < m; j++) printf(" %d ", second_matrix[i][j]);
     146:	017a04b3          	add	s1,s4,s7
     14a:	408c                	lw	a1,0(s1)
     14c:	854a                	mv	a0,s2
     14e:	1a6010ef          	jal	12f4 <printf>
     152:	0491                	addi	s1,s1,4
     154:	ff449be3          	bne	s1,s4,14a <print_state+0x14a>
    printf("\n");
     158:	8566                	mv	a0,s9
     15a:	19a010ef          	jal	12f4 <printf>
  for (int i = 0; i < n; i++) {
     15e:	2a85                	addiw	s5,s5,1
     160:	02898993          	addi	s3,s3,40
     164:	028a0a13          	addi	s4,s4,40
     168:	fb8acde3          	blt	s5,s8,122 <print_state+0x122>
  }

  printf("Available: ");
     16c:	00001517          	auipc	a0,0x1
     170:	3c450513          	addi	a0,a0,964 # 1530 <malloc+0x184>
     174:	180010ef          	jal	12f4 <printf>
  for (int j = 0; j < m; j++) printf("R%d=%d ", j, avail[j]);
     178:	05605863          	blez	s6,1c8 <print_state+0x1c8>
     17c:	7ca2                	ld	s9,40(sp)
     17e:	7d02                	ld	s10,32(sp)
     180:	6de2                	ld	s11,24(sp)
     182:	f8843903          	ld	s2,-120(s0)
     186:	4481                	li	s1,0
     188:	00001997          	auipc	s3,0x1
     18c:	3b898993          	addi	s3,s3,952 # 1540 <malloc+0x194>
     190:	00092603          	lw	a2,0(s2)
     194:	85a6                	mv	a1,s1
     196:	854e                	mv	a0,s3
     198:	15c010ef          	jal	12f4 <printf>
     19c:	2485                	addiw	s1,s1,1
     19e:	0911                	addi	s2,s2,4
     1a0:	fe9b18e3          	bne	s6,s1,190 <print_state+0x190>
  printf("\n\n");
     1a4:	00001517          	auipc	a0,0x1
     1a8:	3a450513          	addi	a0,a0,932 # 1548 <malloc+0x19c>
     1ac:	148010ef          	jal	12f4 <printf>
}
     1b0:	70e6                	ld	ra,120(sp)
     1b2:	7446                	ld	s0,112(sp)
     1b4:	74a6                	ld	s1,104(sp)
     1b6:	7906                	ld	s2,96(sp)
     1b8:	69e6                	ld	s3,88(sp)
     1ba:	6a46                	ld	s4,80(sp)
     1bc:	6aa6                	ld	s5,72(sp)
     1be:	6b06                	ld	s6,64(sp)
     1c0:	7be2                	ld	s7,56(sp)
     1c2:	7c42                	ld	s8,48(sp)
     1c4:	6109                	addi	sp,sp,128
     1c6:	8082                	ret
     1c8:	7ca2                	ld	s9,40(sp)
     1ca:	7d02                	ld	s10,32(sp)
     1cc:	6de2                	ld	s11,24(sp)
     1ce:	bfd9                	j	1a4 <print_state+0x1a4>
    printf("| ");
     1d0:	856e                	mv	a0,s11
     1d2:	122010ef          	jal	12f4 <printf>
    for (int j = 0; j < m; j++) printf(" %d ", second_matrix[i][j]);
     1d6:	b749                	j	158 <print_state+0x158>
  printf("| ");
     1d8:	00001517          	auipc	a0,0x1
     1dc:	31850513          	addi	a0,a0,792 # 14f0 <malloc+0x144>
     1e0:	114010ef          	jal	12f4 <printf>
  printf("\n-----+");
     1e4:	00001517          	auipc	a0,0x1
     1e8:	31450513          	addi	a0,a0,788 # 14f8 <malloc+0x14c>
     1ec:	108010ef          	jal	12f4 <printf>
  printf("-+-");
     1f0:	00001517          	auipc	a0,0x1
     1f4:	31850513          	addi	a0,a0,792 # 1508 <malloc+0x15c>
     1f8:	0fc010ef          	jal	12f4 <printf>
  printf("\n");
     1fc:	00001517          	auipc	a0,0x1
     200:	31450513          	addi	a0,a0,788 # 1510 <malloc+0x164>
     204:	0f0010ef          	jal	12f4 <printf>
  for (int i = 0; i < n; i++) {
     208:	ef8042e3          	bgtz	s8,ec <print_state+0xec>
  printf("Available: ");
     20c:	00001517          	auipc	a0,0x1
     210:	32450513          	addi	a0,a0,804 # 1530 <malloc+0x184>
     214:	0e0010ef          	jal	12f4 <printf>
  for (int j = 0; j < m; j++) printf("R%d=%d ", j, avail[j]);
     218:	b771                	j	1a4 <print_state+0x1a4>
  printf("Available: ");
     21a:	00001517          	auipc	a0,0x1
     21e:	31650513          	addi	a0,a0,790 # 1530 <malloc+0x184>
     222:	0d2010ef          	jal	12f4 <printf>
  for (int j = 0; j < m; j++) printf("R%d=%d ", j, avail[j]);
     226:	bfb1                	j	182 <print_state+0x182>

0000000000000228 <detect_deadlock>:

// Deadlock Detection Algorithm
int detect_deadlock(int n, int m, int alloc[MAX_PROC][MAX_RES],
                    int req[MAX_PROC][MAX_RES], int avail[MAX_RES],
                    int deadlocked_list[MAX_PROC]) {
     228:	7139                	addi	sp,sp,-64
     22a:	fc06                	sd	ra,56(sp)
     22c:	f822                	sd	s0,48(sp)
     22e:	f426                	sd	s1,40(sp)
     230:	f04a                	sd	s2,32(sp)
     232:	ec4e                	sd	s3,24(sp)
     234:	e852                	sd	s4,16(sp)
     236:	e456                	sd	s5,8(sp)
     238:	0080                	addi	s0,sp,64
     23a:	83aa                	mv	t2,a0
     23c:	84be                	mv	s1,a5
  for (int j = 0; j < m; j++)
     23e:	02b05063          	blez	a1,25e <detect_deadlock+0x36>
     242:	87ba                	mv	a5,a4
     244:	00004517          	auipc	a0,0x4
     248:	8ec50513          	addi	a0,a0,-1812 # 3b30 <work>
     24c:	00259813          	slli	a6,a1,0x2
     250:	983a                	add	a6,a6,a4
    work[j] = avail[j];
     252:	4398                	lw	a4,0(a5)
     254:	c118                	sw	a4,0(a0)
  for (int j = 0; j < m; j++)
     256:	0791                	addi	a5,a5,4
     258:	0511                	addi	a0,a0,4
     25a:	ff079ce3          	bne	a5,a6,252 <detect_deadlock+0x2a>

  for (int i = 0; i < n; i++) {
     25e:	04705963          	blez	t2,2b0 <detect_deadlock+0x88>
     262:	00004797          	auipc	a5,0x4
     266:	8f678793          	addi	a5,a5,-1802 # 3b58 <finish>
     26a:	00259893          	slli	a7,a1,0x2
     26e:	98b2                	add	a7,a7,a2
     270:	00239313          	slli	t1,t2,0x2
     274:	933e                	add	t1,t1,a5
     276:	40b00533          	neg	a0,a1
     27a:	050a                	slli	a0,a0,0x2
    // If process has no allocations, it cannot be part of a deadlock
    int has_alloc = 0;
    for (int j = 0; j < m; j++) {
      if (alloc[i][j] > 0) {
        has_alloc = 1;
     27c:	4e05                	li	t3,1
     27e:	a811                	j	292 <detect_deadlock+0x6a>
     280:	8772                	mv	a4,t3
        break;
      }
    }
    finish[i] = (has_alloc == 0) ? 1 : 0;
     282:	00174713          	xori	a4,a4,1
     286:	c398                	sw	a4,0(a5)
  for (int i = 0; i < n; i++) {
     288:	0791                	addi	a5,a5,4
     28a:	02888893          	addi	a7,a7,40
     28e:	02678163          	beq	a5,t1,2b0 <detect_deadlock+0x88>
    for (int j = 0; j < m; j++) {
     292:	00a88733          	add	a4,a7,a0
     296:	00b05b63          	blez	a1,2ac <detect_deadlock+0x84>
      if (alloc[i][j] > 0) {
     29a:	00072803          	lw	a6,0(a4)
     29e:	ff0041e3          	bgtz	a6,280 <detect_deadlock+0x58>
    for (int j = 0; j < m; j++) {
     2a2:	0711                	addi	a4,a4,4
     2a4:	ff171be3          	bne	a4,a7,29a <detect_deadlock+0x72>
    int has_alloc = 0;
     2a8:	4701                	li	a4,0
     2aa:	bfe1                	j	282 <detect_deadlock+0x5a>
     2ac:	4701                	li	a4,0
     2ae:	bfd1                	j	282 <detect_deadlock+0x5a>
     2b0:	00259a13          	slli	s4,a1,0x2
     2b4:	014689b3          	add	s3,a3,s4
     2b8:	00004797          	auipc	a5,0x4
     2bc:	8a078793          	addi	a5,a5,-1888 # 3b58 <finish>
     2c0:	00239293          	slli	t0,t2,0x2
     2c4:	92be                	add	t0,t0,a5
     2c6:	40b00933          	neg	s2,a1
     2ca:	090a                	slli	s2,s2,0x2
        }
        if (can_satisfy) {
          for (int j = 0; j < m; j++) {
            work[j] += alloc[i][j];
          }
          finish[i] = 1;
     2cc:	4a85                	li	s5,1
     2ce:	a09d                	j	334 <detect_deadlock+0x10c>
     2d0:	015fa023          	sw	s5,0(t6)
          found = 1;
     2d4:	8556                	mv	a0,s5
    for (int i = 0; i < n; i++) {
     2d6:	0811                	addi	a6,a6,4
     2d8:	028e0e13          	addi	t3,t3,40
     2dc:	028f0f13          	addi	t5,t5,40
     2e0:	04580963          	beq	a6,t0,332 <detect_deadlock+0x10a>
      if (finish[i] == 0) {
     2e4:	8fc2                	mv	t6,a6
     2e6:	00082703          	lw	a4,0(a6)
     2ea:	f775                	bnez	a4,2d6 <detect_deadlock+0xae>
        for (int j = 0; j < m; j++) {
     2ec:	feb052e3          	blez	a1,2d0 <detect_deadlock+0xa8>
     2f0:	012e0733          	add	a4,t3,s2
     2f4:	00004e97          	auipc	t4,0x4
     2f8:	83ce8e93          	addi	t4,t4,-1988 # 3b30 <work>
     2fc:	86f6                	mv	a3,t4
          if (req[i][j] > work[j]) {
     2fe:	00072303          	lw	t1,0(a4)
     302:	0006a883          	lw	a7,0(a3)
     306:	fc68c8e3          	blt	a7,t1,2d6 <detect_deadlock+0xae>
        for (int j = 0; j < m; j++) {
     30a:	0711                	addi	a4,a4,4
     30c:	0691                	addi	a3,a3,4
     30e:	ffc718e3          	bne	a4,t3,2fe <detect_deadlock+0xd6>
          for (int j = 0; j < m; j++) {
     312:	01ea0333          	add	t1,s4,t5
        for (int j = 0; j < m; j++) {
     316:	877a                	mv	a4,t5
            work[j] += alloc[i][j];
     318:	000ea883          	lw	a7,0(t4)
     31c:	4314                	lw	a3,0(a4)
     31e:	011686bb          	addw	a3,a3,a7
     322:	00dea023          	sw	a3,0(t4)
          for (int j = 0; j < m; j++) {
     326:	0e91                	addi	t4,t4,4
     328:	0711                	addi	a4,a4,4
     32a:	fe6717e3          	bne	a4,t1,318 <detect_deadlock+0xf0>
     32e:	b74d                	j	2d0 <detect_deadlock+0xa8>
    int found = 0;
     330:	4501                	li	a0,0
        }
      }
    }
    if (!found)
     332:	c901                	beqz	a0,342 <detect_deadlock+0x11a>
    for (int i = 0; i < n; i++) {
     334:	fe705ee3          	blez	t2,330 <detect_deadlock+0x108>
     338:	8f32                	mv	t5,a2
     33a:	8e4e                	mv	t3,s3
     33c:	883e                	mv	a6,a5
    int found = 0;
     33e:	4501                	li	a0,0
     340:	b755                	j	2e4 <detect_deadlock+0xbc>
      break;
  }

  int deadlocked_count = 0;
  for (int i = 0; i < n; i++) {
     342:	02705063          	blez	t2,362 <detect_deadlock+0x13a>
     346:	872a                	mv	a4,a0
     348:	a029                	j	352 <detect_deadlock+0x12a>
     34a:	2705                	addiw	a4,a4,1
     34c:	0791                	addi	a5,a5,4
     34e:	00e38a63          	beq	t2,a4,362 <detect_deadlock+0x13a>
    if (finish[i] == 0) {
     352:	4394                	lw	a3,0(a5)
     354:	fafd                	bnez	a3,34a <detect_deadlock+0x122>
      deadlocked_list[deadlocked_count++] = i;
     356:	00251693          	slli	a3,a0,0x2
     35a:	96a6                	add	a3,a3,s1
     35c:	c298                	sw	a4,0(a3)
     35e:	2505                	addiw	a0,a0,1
     360:	b7ed                	j	34a <detect_deadlock+0x122>
    }
  }

  return deadlocked_count;
}
     362:	70e2                	ld	ra,56(sp)
     364:	7442                	ld	s0,48(sp)
     366:	74a2                	ld	s1,40(sp)
     368:	7902                	ld	s2,32(sp)
     36a:	69e2                	ld	s3,24(sp)
     36c:	6a42                	ld	s4,16(sp)
     36e:	6aa2                	ld	s5,8(sp)
     370:	6121                	addi	sp,sp,64
     372:	8082                	ret

0000000000000374 <is_safe_state>:

// Banker's Algorithm Safety Check
int is_safe_state(int n, int m, int alloc[MAX_PROC][MAX_RES],
                  int need[MAX_PROC][MAX_RES], int avail[MAX_RES],
                  int safe_seq[MAX_PROC]) {
     374:	7139                	addi	sp,sp,-64
     376:	fc06                	sd	ra,56(sp)
     378:	f822                	sd	s0,48(sp)
     37a:	f426                	sd	s1,40(sp)
     37c:	f04a                	sd	s2,32(sp)
     37e:	ec4e                	sd	s3,24(sp)
     380:	e852                	sd	s4,16(sp)
     382:	e456                	sd	s5,8(sp)
     384:	0080                	addi	s0,sp,64
     386:	82aa                	mv	t0,a0
     388:	893e                	mv	s2,a5
  for (int j = 0; j < m; j++)
     38a:	02b05163          	blez	a1,3ac <is_safe_state+0x38>
     38e:	853a                	mv	a0,a4
     390:	00003817          	auipc	a6,0x3
     394:	7a080813          	addi	a6,a6,1952 # 3b30 <work>
     398:	00259793          	slli	a5,a1,0x2
     39c:	973e                	add	a4,a4,a5
    work[j] = avail[j];
     39e:	411c                	lw	a5,0(a0)
     3a0:	00f82023          	sw	a5,0(a6)
  for (int j = 0; j < m; j++)
     3a4:	0511                	addi	a0,a0,4
     3a6:	0811                	addi	a6,a6,4
     3a8:	fee51be3          	bne	a0,a4,39e <is_safe_state+0x2a>

  for (int i = 0; i < n; i++)
     3ac:	00505e63          	blez	t0,3c8 <is_safe_state+0x54>
     3b0:	00003717          	auipc	a4,0x3
     3b4:	7a870713          	addi	a4,a4,1960 # 3b58 <finish>
     3b8:	00229793          	slli	a5,t0,0x2
     3bc:	97ba                	add	a5,a5,a4
    finish[i] = 0;
     3be:	00072023          	sw	zero,0(a4)
  for (int i = 0; i < n; i++)
     3c2:	0711                	addi	a4,a4,4
     3c4:	fef71de3          	bne	a4,a5,3be <is_safe_state+0x4a>
     3c8:	00259a93          	slli	s5,a1,0x2
     3cc:	015689b3          	add	s3,a3,s5
     3d0:	40b004b3          	neg	s1,a1
     3d4:	048a                	slli	s1,s1,0x2

  int count = 0;
     3d6:	4781                	li	a5,0
        if (can_allocate) {
          for (int j = 0; j < m; j++) {
            work[j] += alloc[i][j];
          }
          safe_seq[count++] = i;
          finish[i] = 1;
     3d8:	4a05                	li	s4,1
     3da:	a885                	j	44a <is_safe_state+0xd6>
          safe_seq[count++] = i;
     3dc:	00279713          	slli	a4,a5,0x2
     3e0:	974a                	add	a4,a4,s2
     3e2:	01d72023          	sw	t4,0(a4)
          finish[i] = 1;
     3e6:	0143a023          	sw	s4,0(t2)
          safe_seq[count++] = i;
     3ea:	2785                	addiw	a5,a5,1
          found = 1;
     3ec:	8552                	mv	a0,s4
    for (int i = 0; i < n; i++) {
     3ee:	2e85                	addiw	t4,t4,1
     3f0:	0e11                	addi	t3,t3,4
     3f2:	02830313          	addi	t1,t1,40
     3f6:	028f8f93          	addi	t6,t6,40
     3fa:	05d28763          	beq	t0,t4,448 <is_safe_state+0xd4>
      if (finish[i] == 0) {
     3fe:	83f2                	mv	t2,t3
     400:	000e2703          	lw	a4,0(t3)
     404:	f76d                	bnez	a4,3ee <is_safe_state+0x7a>
        for (int j = 0; j < m; j++) {
     406:	fcb05be3          	blez	a1,3dc <is_safe_state+0x68>
     40a:	00930733          	add	a4,t1,s1
     40e:	00003f17          	auipc	t5,0x3
     412:	722f0f13          	addi	t5,t5,1826 # 3b30 <work>
     416:	86fa                	mv	a3,t5
          if (need[i][j] > work[j]) {
     418:	00072883          	lw	a7,0(a4)
     41c:	0006a803          	lw	a6,0(a3)
     420:	fd1847e3          	blt	a6,a7,3ee <is_safe_state+0x7a>
        for (int j = 0; j < m; j++) {
     424:	0711                	addi	a4,a4,4
     426:	0691                	addi	a3,a3,4
     428:	fe6718e3          	bne	a4,t1,418 <is_safe_state+0xa4>
          for (int j = 0; j < m; j++) {
     42c:	01fa8833          	add	a6,s5,t6
        for (int j = 0; j < m; j++) {
     430:	877e                	mv	a4,t6
            work[j] += alloc[i][j];
     432:	000f2503          	lw	a0,0(t5)
     436:	4314                	lw	a3,0(a4)
     438:	9ea9                	addw	a3,a3,a0
     43a:	00df2023          	sw	a3,0(t5)
          for (int j = 0; j < m; j++) {
     43e:	0f11                	addi	t5,t5,4
     440:	0711                	addi	a4,a4,4
     442:	ff0718e3          	bne	a4,a6,432 <is_safe_state+0xbe>
     446:	bf59                	j	3dc <is_safe_state+0x68>
        }
      }
    }
    if (!found)
     448:	cd19                	beqz	a0,466 <is_safe_state+0xf2>
  while (count < n) {
     44a:	0257d763          	bge	a5,t0,478 <is_safe_state+0x104>
    for (int i = 0; i < n; i++) {
     44e:	00505b63          	blez	t0,464 <is_safe_state+0xf0>
     452:	00003e17          	auipc	t3,0x3
     456:	706e0e13          	addi	t3,t3,1798 # 3b58 <finish>
     45a:	8fb2                	mv	t6,a2
     45c:	834e                	mv	t1,s3
     45e:	4e81                	li	t4,0
    int found = 0;
     460:	4501                	li	a0,0
     462:	bf71                	j	3fe <is_safe_state+0x8a>
      return 0; // Unsafe
     464:	4501                	li	a0,0
  }
  return 1; // Safe
}
     466:	70e2                	ld	ra,56(sp)
     468:	7442                	ld	s0,48(sp)
     46a:	74a2                	ld	s1,40(sp)
     46c:	7902                	ld	s2,32(sp)
     46e:	69e2                	ld	s3,24(sp)
     470:	6a42                	ld	s4,16(sp)
     472:	6aa2                	ld	s5,8(sp)
     474:	6121                	addi	sp,sp,64
     476:	8082                	ret
  return 1; // Safe
     478:	4505                	li	a0,1
     47a:	b7f5                	j	466 <is_safe_state+0xf2>

000000000000047c <simulate_pipe_deadlock>:
  {1, 0}  // Process B requests Pipe 1
};
static int avail_pipe[MAX_RES] = {0, 0};
static int deadlocked_pipe[MAX_PROC];

void simulate_pipe_deadlock(void) {
     47c:	7139                	addi	sp,sp,-64
     47e:	fc06                	sd	ra,56(sp)
     480:	f822                	sd	s0,48(sp)
     482:	0080                	addi	s0,sp,64
  printf("============================================================\n");
     484:	00001517          	auipc	a0,0x1
     488:	0d450513          	addi	a0,a0,212 # 1558 <malloc+0x1ac>
     48c:	669000ef          	jal	12f4 <printf>
  printf(" Task (c): Real Process Pipe Deadlock Simulation & Detection\n");
     490:	00001517          	auipc	a0,0x1
     494:	10850513          	addi	a0,a0,264 # 1598 <malloc+0x1ec>
     498:	65d000ef          	jal	12f4 <printf>
  printf(" Process A holds Pipe1 (write) and waits to read Pipe2\n");
     49c:	00001517          	auipc	a0,0x1
     4a0:	13c50513          	addi	a0,a0,316 # 15d8 <malloc+0x22c>
     4a4:	651000ef          	jal	12f4 <printf>
  printf(" Process B holds Pipe2 (write) and waits to read Pipe1\n");
     4a8:	00001517          	auipc	a0,0x1
     4ac:	16850513          	addi	a0,a0,360 # 1610 <malloc+0x264>
     4b0:	645000ef          	jal	12f4 <printf>
  printf("============================================================\n");
     4b4:	00001517          	auipc	a0,0x1
     4b8:	0a450513          	addi	a0,a0,164 # 1558 <malloc+0x1ac>
     4bc:	639000ef          	jal	12f4 <printf>

  int n = 2, m = 2;
  print_state(n, m, alloc_pipe, req_pipe, "Request   ", avail_pipe);
     4c0:	00003797          	auipc	a5,0x3
     4c4:	6c078793          	addi	a5,a5,1728 # 3b80 <avail_pipe>
     4c8:	00001717          	auipc	a4,0x1
     4cc:	18070713          	addi	a4,a4,384 # 1648 <malloc+0x29c>
     4d0:	00003697          	auipc	a3,0x3
     4d4:	b3068693          	addi	a3,a3,-1232 # 3000 <req_pipe>
     4d8:	00003617          	auipc	a2,0x3
     4dc:	cb860613          	addi	a2,a2,-840 # 3190 <alloc_pipe>
     4e0:	4589                	li	a1,2
     4e2:	852e                	mv	a0,a1
     4e4:	b1dff0ef          	jal	0 <print_state>

  int count = detect_deadlock(n, m, alloc_pipe, req_pipe, avail_pipe, deadlocked_pipe);
     4e8:	00003797          	auipc	a5,0x3
     4ec:	6c078793          	addi	a5,a5,1728 # 3ba8 <deadlocked_pipe>
     4f0:	00003717          	auipc	a4,0x3
     4f4:	69070713          	addi	a4,a4,1680 # 3b80 <avail_pipe>
     4f8:	00003697          	auipc	a3,0x3
     4fc:	b0868693          	addi	a3,a3,-1272 # 3000 <req_pipe>
     500:	00003617          	auipc	a2,0x3
     504:	c9060613          	addi	a2,a2,-880 # 3190 <alloc_pipe>
     508:	4589                	li	a1,2
     50a:	852e                	mv	a0,a1
     50c:	d1dff0ef          	jal	228 <detect_deadlock>
  if (count > 0) {
     510:	08a05e63          	blez	a0,5ac <simulate_pipe_deadlock+0x130>
     514:	f426                	sd	s1,40(sp)
     516:	f04a                	sd	s2,32(sp)
     518:	ec4e                	sd	s3,24(sp)
     51a:	e852                	sd	s4,16(sp)
     51c:	e456                	sd	s5,8(sp)
     51e:	89aa                	mv	s3,a0
    printf("ALGORITHM RESULT: DEADLOCK DETECTED among %d processes!\n", count);
     520:	85aa                	mv	a1,a0
     522:	00001517          	auipc	a0,0x1
     526:	13650513          	addi	a0,a0,310 # 1658 <malloc+0x2ac>
     52a:	5cb000ef          	jal	12f4 <printf>
    printf("Deadlocked processes: ");
     52e:	00001517          	auipc	a0,0x1
     532:	16a50513          	addi	a0,a0,362 # 1698 <malloc+0x2ec>
     536:	5bf000ef          	jal	12f4 <printf>
    for (int i = 0; i < count; i++) {
     53a:	00003917          	auipc	s2,0x3
     53e:	66e90913          	addi	s2,s2,1646 # 3ba8 <deadlocked_pipe>
     542:	4481                	li	s1,0
      printf("Process %c (P%d)%s",
     544:	fff98a9b          	addiw	s5,s3,-1
     548:	00001a17          	auipc	s4,0x1
     54c:	168a0a13          	addi	s4,s4,360 # 16b0 <malloc+0x304>
     550:	a801                	j	560 <simulate_pipe_deadlock+0xe4>
     552:	8552                	mv	a0,s4
     554:	5a1000ef          	jal	12f4 <printf>
    for (int i = 0; i < count; i++) {
     558:	2485                	addiw	s1,s1,1
     55a:	0911                	addi	s2,s2,4
     55c:	02998363          	beq	s3,s1,582 <simulate_pipe_deadlock+0x106>
             (deadlocked_pipe[i] == 0 ? 'A' : 'B'),
     560:	00092603          	lw	a2,0(s2)
      printf("Process %c (P%d)%s",
     564:	00c035b3          	snez	a1,a2
     568:	04158593          	addi	a1,a1,65
     56c:	00001697          	auipc	a3,0x1
     570:	fe468693          	addi	a3,a3,-28 # 1550 <malloc+0x1a4>
     574:	fc9a9fe3          	bne	s5,s1,552 <simulate_pipe_deadlock+0xd6>
     578:	00001697          	auipc	a3,0x1
     57c:	f9868693          	addi	a3,a3,-104 # 1510 <malloc+0x164>
     580:	bfc9                	j	552 <simulate_pipe_deadlock+0xd6>
             deadlocked_pipe[i],
             (i == count - 1) ? "\n" : ", ");
    }
    printf("Explanation: Process A holds Pipe 1 waiting for Pipe 2;\n");
     582:	00001517          	auipc	a0,0x1
     586:	14650513          	addi	a0,a0,326 # 16c8 <malloc+0x31c>
     58a:	56b000ef          	jal	12f4 <printf>
    printf("             Process B holds Pipe 2 waiting for Pipe 1 (Circular Wait).\n");
     58e:	00001517          	auipc	a0,0x1
     592:	17a50513          	addi	a0,a0,378 # 1708 <malloc+0x35c>
     596:	55f000ef          	jal	12f4 <printf>
     59a:	74a2                	ld	s1,40(sp)
     59c:	7902                	ld	s2,32(sp)
     59e:	69e2                	ld	s3,24(sp)
     5a0:	6a42                	ld	s4,16(sp)
     5a2:	6aa2                	ld	s5,8(sp)
  } else {
    printf("ALGORITHM RESULT: No deadlock.\n");
  }
}
     5a4:	70e2                	ld	ra,56(sp)
     5a6:	7442                	ld	s0,48(sp)
     5a8:	6121                	addi	sp,sp,64
     5aa:	8082                	ret
    printf("ALGORITHM RESULT: No deadlock.\n");
     5ac:	00001517          	auipc	a0,0x1
     5b0:	1ac50513          	addi	a0,a0,428 # 1758 <malloc+0x3ac>
     5b4:	541000ef          	jal	12f4 <printf>
}
     5b8:	b7f5                	j	5a4 <simulate_pipe_deadlock+0x128>

00000000000005ba <main>:

int main(int argc, char *argv[]) {
     5ba:	7119                	addi	sp,sp,-128
     5bc:	fc86                	sd	ra,120(sp)
     5be:	f8a2                	sd	s0,112(sp)
     5c0:	f4a6                	sd	s1,104(sp)
     5c2:	f0ca                	sd	s2,96(sp)
     5c4:	ecce                	sd	s3,88(sp)
     5c6:	e8d2                	sd	s4,80(sp)
     5c8:	e4d6                	sd	s5,72(sp)
     5ca:	e0da                	sd	s6,64(sp)
     5cc:	fc5e                	sd	s7,56(sp)
     5ce:	f862                	sd	s8,48(sp)
     5d0:	0100                	addi	s0,sp,128
  printf("============================================================\n");
     5d2:	00001517          	auipc	a0,0x1
     5d6:	f8650513          	addi	a0,a0,-122 # 1558 <malloc+0x1ac>
     5da:	51b000ef          	jal	12f4 <printf>
  printf("       Deadlock Detection & Avoidance Algorithms in xv6     \n");
     5de:	00001517          	auipc	a0,0x1
     5e2:	19a50513          	addi	a0,a0,410 # 1778 <malloc+0x3cc>
     5e6:	50f000ef          	jal	12f4 <printf>
  printf("============================================================\n");
     5ea:	00001517          	auipc	a0,0x1
     5ee:	f6e50513          	addi	a0,a0,-146 # 1558 <malloc+0x1ac>
     5f2:	503000ef          	jal	12f4 <printf>

  // -------------------------------------------------------------------------
  // Matrix 1: Deadlock Detection (Safe / No Deadlock Scenario)
  // -------------------------------------------------------------------------
  printf("\n============================================================\n");
     5f6:	00001517          	auipc	a0,0x1
     5fa:	1c250513          	addi	a0,a0,450 # 17b8 <malloc+0x40c>
     5fe:	4f7000ef          	jal	12f4 <printf>
  printf(" TEST MATRIX 1: Deadlock Detection Algorithm (Acyclic / Safe)\n");
     602:	00001517          	auipc	a0,0x1
     606:	1f650513          	addi	a0,a0,502 # 17f8 <malloc+0x44c>
     60a:	4eb000ef          	jal	12f4 <printf>
  printf(" 5 Processes (P0..P4), 3 Resource Types (R0..R2)\n");
     60e:	00001517          	auipc	a0,0x1
     612:	22a50513          	addi	a0,a0,554 # 1838 <malloc+0x48c>
     616:	4df000ef          	jal	12f4 <printf>
  printf("============================================================\n");
     61a:	00001517          	auipc	a0,0x1
     61e:	f3e50513          	addi	a0,a0,-194 # 1558 <malloc+0x1ac>
     622:	4d3000ef          	jal	12f4 <printf>
  int n1 = 5, m1 = 3;

  print_state(n1, m1, alloc1, req1, "Request   ", avail1);
     626:	00003797          	auipc	a5,0x3
     62a:	5aa78793          	addi	a5,a5,1450 # 3bd0 <avail1>
     62e:	00001717          	auipc	a4,0x1
     632:	01a70713          	addi	a4,a4,26 # 1648 <malloc+0x29c>
     636:	00003697          	auipc	a3,0x3
     63a:	cea68693          	addi	a3,a3,-790 # 3320 <req1>
     63e:	00003617          	auipc	a2,0x3
     642:	e7260613          	addi	a2,a2,-398 # 34b0 <alloc1>
     646:	458d                	li	a1,3
     648:	4515                	li	a0,5
     64a:	9b7ff0ef          	jal	0 <print_state>

  int count1 = detect_deadlock(n1, m1, alloc1, req1, avail1, deadlocked1);
     64e:	00003797          	auipc	a5,0x3
     652:	5aa78793          	addi	a5,a5,1450 # 3bf8 <deadlocked1>
     656:	00003717          	auipc	a4,0x3
     65a:	57a70713          	addi	a4,a4,1402 # 3bd0 <avail1>
     65e:	00003697          	auipc	a3,0x3
     662:	cc268693          	addi	a3,a3,-830 # 3320 <req1>
     666:	00003617          	auipc	a2,0x3
     66a:	e4a60613          	addi	a2,a2,-438 # 34b0 <alloc1>
     66e:	458d                	li	a1,3
     670:	4515                	li	a0,5
     672:	bb7ff0ef          	jal	228 <detect_deadlock>
  if (count1 == 0) {
     676:	40051c63          	bnez	a0,a8e <main+0x4d4>
    printf("RESULT: NO DEADLOCK DETECTED.\n");
     67a:	00001517          	auipc	a0,0x1
     67e:	1f650513          	addi	a0,a0,502 # 1870 <malloc+0x4c4>
     682:	473000ef          	jal	12f4 <printf>
    printf("All processes can eventually terminate and release resources.\n");
     686:	00001517          	auipc	a0,0x1
     68a:	20a50513          	addi	a0,a0,522 # 1890 <malloc+0x4e4>
     68e:	467000ef          	jal	12f4 <printf>
  }

  // -------------------------------------------------------------------------
  // Matrix 2: Deadlock Detection (Deadlock Exists Scenario)
  // -------------------------------------------------------------------------
  printf("\n============================================================\n");
     692:	00001517          	auipc	a0,0x1
     696:	12650513          	addi	a0,a0,294 # 17b8 <malloc+0x40c>
     69a:	45b000ef          	jal	12f4 <printf>
  printf(" TEST MATRIX 2: Deadlock Detection Algorithm (Deadlocked State)\n");
     69e:	00001517          	auipc	a0,0x1
     6a2:	26a50513          	addi	a0,a0,618 # 1908 <malloc+0x55c>
     6a6:	44f000ef          	jal	12f4 <printf>
  printf(" P2 requests [0, 0, 1] creating circular wait\n");
     6aa:	00001517          	auipc	a0,0x1
     6ae:	2a650513          	addi	a0,a0,678 # 1950 <malloc+0x5a4>
     6b2:	443000ef          	jal	12f4 <printf>
  printf("============================================================\n");
     6b6:	00001517          	auipc	a0,0x1
     6ba:	ea250513          	addi	a0,a0,-350 # 1558 <malloc+0x1ac>
     6be:	437000ef          	jal	12f4 <printf>

  print_state(n1, m1, alloc2, req2, "Request   ", avail2);
     6c2:	00003797          	auipc	a5,0x3
     6c6:	55e78793          	addi	a5,a5,1374 # 3c20 <avail2>
     6ca:	00001717          	auipc	a4,0x1
     6ce:	f7e70713          	addi	a4,a4,-130 # 1648 <malloc+0x29c>
     6d2:	00003697          	auipc	a3,0x3
     6d6:	f6e68693          	addi	a3,a3,-146 # 3640 <req2>
     6da:	00003617          	auipc	a2,0x3
     6de:	0f660613          	addi	a2,a2,246 # 37d0 <alloc2>
     6e2:	458d                	li	a1,3
     6e4:	4515                	li	a0,5
     6e6:	91bff0ef          	jal	0 <print_state>

  int count2 = detect_deadlock(n1, m1, alloc2, req2, avail2, deadlocked2);
     6ea:	00003797          	auipc	a5,0x3
     6ee:	55e78793          	addi	a5,a5,1374 # 3c48 <deadlocked2>
     6f2:	00003717          	auipc	a4,0x3
     6f6:	52e70713          	addi	a4,a4,1326 # 3c20 <avail2>
     6fa:	00003697          	auipc	a3,0x3
     6fe:	f4668693          	addi	a3,a3,-186 # 3640 <req2>
     702:	00003617          	auipc	a2,0x3
     706:	0ce60613          	addi	a2,a2,206 # 37d0 <alloc2>
     70a:	458d                	li	a1,3
     70c:	4515                	li	a0,5
     70e:	b1bff0ef          	jal	228 <detect_deadlock>
     712:	892a                	mv	s2,a0
  if (count2 > 0) {
     714:	38a05563          	blez	a0,a9e <main+0x4e4>
    printf("RESULT: DEADLOCK DETECTED!\n");
     718:	00001517          	auipc	a0,0x1
     71c:	26850513          	addi	a0,a0,616 # 1980 <malloc+0x5d4>
     720:	3d5000ef          	jal	12f4 <printf>
    printf("Deadlocked processes (%d): [ ", count2);
     724:	85ca                	mv	a1,s2
     726:	00001517          	auipc	a0,0x1
     72a:	27a50513          	addi	a0,a0,634 # 19a0 <malloc+0x5f4>
     72e:	3c7000ef          	jal	12f4 <printf>
    for (int i = 0; i < count2; i++) {
     732:	00003497          	auipc	s1,0x3
     736:	51648493          	addi	s1,s1,1302 # 3c48 <deadlocked2>
     73a:	090a                	slli	s2,s2,0x2
     73c:	9926                	add	s2,s2,s1
      printf("P%d ", deadlocked2[i]);
     73e:	00001997          	auipc	s3,0x1
     742:	28298993          	addi	s3,s3,642 # 19c0 <malloc+0x614>
     746:	408c                	lw	a1,0(s1)
     748:	854e                	mv	a0,s3
     74a:	3ab000ef          	jal	12f4 <printf>
    for (int i = 0; i < count2; i++) {
     74e:	0491                	addi	s1,s1,4
     750:	ff249be3          	bne	s1,s2,746 <main+0x18c>
    }
    printf("]\n");
     754:	00001517          	auipc	a0,0x1
     758:	27450513          	addi	a0,a0,628 # 19c8 <malloc+0x61c>
     75c:	399000ef          	jal	12f4 <printf>
    printf("Processes cannot proceed due to circular resource dependencies.\n");
     760:	00001517          	auipc	a0,0x1
     764:	27050513          	addi	a0,a0,624 # 19d0 <malloc+0x624>
     768:	38d000ef          	jal	12f4 <printf>
  }

  // -------------------------------------------------------------------------
  // Matrix 3: Banker's Algorithm (Avoidance: Becomes Unsafe After Request)
  // -------------------------------------------------------------------------
  printf("\n============================================================\n");
     76c:	00001517          	auipc	a0,0x1
     770:	04c50513          	addi	a0,a0,76 # 17b8 <malloc+0x40c>
     774:	381000ef          	jal	12f4 <printf>
  printf(" TEST MATRIX 3: Banker's Algorithm Deadlock Avoidance\n");
     778:	00001517          	auipc	a0,0x1
     77c:	2b850513          	addi	a0,a0,696 # 1a30 <malloc+0x684>
     780:	375000ef          	jal	12f4 <printf>
  printf(" Testing initial safety & hypothetical request leading to UNSAFE\n");
     784:	00001517          	auipc	a0,0x1
     788:	2e450513          	addi	a0,a0,740 # 1a68 <malloc+0x6bc>
     78c:	369000ef          	jal	12f4 <printf>
  printf("============================================================\n");
     790:	00001517          	auipc	a0,0x1
     794:	dc850513          	addi	a0,a0,-568 # 1558 <malloc+0x1ac>
     798:	35d000ef          	jal	12f4 <printf>
  int n3 = 5, m3 = 3;
  for (int i = 0; i < n3; i++)
     79c:	00001797          	auipc	a5,0x1
     7a0:	6d478793          	addi	a5,a5,1748 # 1e70 <max3>
     7a4:	00003917          	auipc	s2,0x3
     7a8:	1bc90913          	addi	s2,s2,444 # 3960 <alloc3>
     7ac:	00003497          	auipc	s1,0x3
     7b0:	4c448493          	addi	s1,s1,1220 # 3c70 <need3>
     7b4:	00001517          	auipc	a0,0x1
     7b8:	78450513          	addi	a0,a0,1924 # 1f38 <max3+0xc8>
  printf("============================================================\n");
     7bc:	86a6                	mv	a3,s1
     7be:	874a                	mv	a4,s2
    for (int j = 0; j < m3; j++)
      need3[i][j] = max3[i][j] - alloc3[i][j];
     7c0:	4390                	lw	a2,0(a5)
     7c2:	430c                	lw	a1,0(a4)
     7c4:	9e0d                	subw	a2,a2,a1
     7c6:	c290                	sw	a2,0(a3)
     7c8:	43d0                	lw	a2,4(a5)
     7ca:	434c                	lw	a1,4(a4)
     7cc:	9e0d                	subw	a2,a2,a1
     7ce:	c2d0                	sw	a2,4(a3)
     7d0:	4790                	lw	a2,8(a5)
     7d2:	470c                	lw	a1,8(a4)
     7d4:	9e0d                	subw	a2,a2,a1
     7d6:	c690                	sw	a2,8(a3)
  for (int i = 0; i < n3; i++)
     7d8:	02878793          	addi	a5,a5,40
     7dc:	02870713          	addi	a4,a4,40
     7e0:	02868693          	addi	a3,a3,40
     7e4:	fca79ee3          	bne	a5,a0,7c0 <main+0x206>

  print_state(n3, m3, alloc3, need3, "Need      ", avail3);
     7e8:	00003797          	auipc	a5,0x3
     7ec:	30878793          	addi	a5,a5,776 # 3af0 <avail3>
     7f0:	00001717          	auipc	a4,0x1
     7f4:	2c070713          	addi	a4,a4,704 # 1ab0 <malloc+0x704>
     7f8:	00003697          	auipc	a3,0x3
     7fc:	47868693          	addi	a3,a3,1144 # 3c70 <need3>
     800:	00003617          	auipc	a2,0x3
     804:	16060613          	addi	a2,a2,352 # 3960 <alloc3>
     808:	458d                	li	a1,3
     80a:	4515                	li	a0,5
     80c:	ff4ff0ef          	jal	0 <print_state>

  if (is_safe_state(n3, m3, alloc3, need3, avail3, safe_seq)) {
     810:	00003797          	auipc	a5,0x3
     814:	5f078793          	addi	a5,a5,1520 # 3e00 <safe_seq>
     818:	00003717          	auipc	a4,0x3
     81c:	2d870713          	addi	a4,a4,728 # 3af0 <avail3>
     820:	00003697          	auipc	a3,0x3
     824:	45068693          	addi	a3,a3,1104 # 3c70 <need3>
     828:	00003617          	auipc	a2,0x3
     82c:	13860613          	addi	a2,a2,312 # 3960 <alloc3>
     830:	458d                	li	a1,3
     832:	4515                	li	a0,5
     834:	b41ff0ef          	jal	374 <is_safe_state>
     838:	26051a63          	bnez	a0,aac <main+0x4f2>
    for (int i = 0; i < n3; i++)
      printf("P%d%s", safe_seq[i], (i == n3 - 1) ? ">\n" : ", ");
  }

  // Scenario 3a: Hypothetical Safe Request from P1: [1, 0, 2]
  printf("\n--- Request Scenario A ---\n");
     83c:	00001517          	auipc	a0,0x1
     840:	2d450513          	addi	a0,a0,724 # 1b10 <malloc+0x764>
     844:	2b1000ef          	jal	12f4 <printf>
  printf("Hypothetical Request: Process P1 requests [R0=1, R1=0, R2=2]...\n");
     848:	00001517          	auipc	a0,0x1
     84c:	2e850513          	addi	a0,a0,744 # 1b30 <malloc+0x784>
     850:	2a5000ef          	jal	12f4 <printf>
  int req_p1[3] = {1, 0, 2};
     854:	4785                	li	a5,1
     856:	faf42023          	sw	a5,-96(s0)
     85a:	fa042223          	sw	zero,-92(s0)
     85e:	4789                	li	a5,2
     860:	faf42423          	sw	a5,-88(s0)
  int can_grant = 1;
  for (int j = 0; j < m3; j++) {
     864:	fa040a13          	addi	s4,s0,-96
     868:	00003997          	auipc	s3,0x3
     86c:	28898993          	addi	s3,s3,648 # 3af0 <avail3>
     870:	fac40513          	addi	a0,s0,-84
  int req_p1[3] = {1, 0, 2};
     874:	86ce                	mv	a3,s3
     876:	00003717          	auipc	a4,0x3
     87a:	3fa70713          	addi	a4,a4,1018 # 3c70 <need3>
     87e:	87d2                	mv	a5,s4
    if (req_p1[j] > need3[1][j] || req_p1[j] > avail3[j]) {
     880:	4390                	lw	a2,0(a5)
     882:	570c                	lw	a1,40(a4)
     884:	0ac5ce63          	blt	a1,a2,940 <main+0x386>
     888:	428c                	lw	a1,0(a3)
     88a:	0ac5cb63          	blt	a1,a2,940 <main+0x386>
  for (int j = 0; j < m3; j++) {
     88e:	0791                	addi	a5,a5,4
     890:	0711                	addi	a4,a4,4
     892:	0691                	addi	a3,a3,4
     894:	fea796e3          	bne	a5,a0,880 <main+0x2c6>
      can_grant = 0;
      break;
    }
  }
  if (can_grant) {
     898:	00003a97          	auipc	s5,0x3
     89c:	264a8a93          	addi	s5,s5,612 # 3afc <avail3+0xc>
  for (int j = 0; j < m3; j++) {
     8a0:	00003697          	auipc	a3,0x3
     8a4:	3d068693          	addi	a3,a3,976 # 3c70 <need3>
     8a8:	00003717          	auipc	a4,0x3
     8ac:	0b870713          	addi	a4,a4,184 # 3960 <alloc3>
     8b0:	8552                	mv	a0,s4
     8b2:	00003797          	auipc	a5,0x3
     8b6:	23e78793          	addi	a5,a5,574 # 3af0 <avail3>
    for (int j = 0; j < m3; j++) {
      avail3[j] -= req_p1[j];
     8ba:	410c                	lw	a1,0(a0)
     8bc:	4390                	lw	a2,0(a5)
     8be:	9e0d                	subw	a2,a2,a1
     8c0:	c390                	sw	a2,0(a5)
      alloc3[1][j] += req_p1[j];
     8c2:	5710                	lw	a2,40(a4)
     8c4:	9e2d                	addw	a2,a2,a1
     8c6:	d710                	sw	a2,40(a4)
      need3[1][j] -= req_p1[j];
     8c8:	5690                	lw	a2,40(a3)
     8ca:	9e0d                	subw	a2,a2,a1
     8cc:	d690                	sw	a2,40(a3)
    for (int j = 0; j < m3; j++) {
     8ce:	0791                	addi	a5,a5,4
     8d0:	0511                	addi	a0,a0,4
     8d2:	0711                	addi	a4,a4,4
     8d4:	0691                	addi	a3,a3,4
     8d6:	ff5792e3          	bne	a5,s5,8ba <main+0x300>
    }
    if (is_safe_state(n3, m3, alloc3, need3, avail3, safe_seq)) {
     8da:	00003797          	auipc	a5,0x3
     8de:	52678793          	addi	a5,a5,1318 # 3e00 <safe_seq>
     8e2:	00003717          	auipc	a4,0x3
     8e6:	20e70713          	addi	a4,a4,526 # 3af0 <avail3>
     8ea:	00003697          	auipc	a3,0x3
     8ee:	38668693          	addi	a3,a3,902 # 3c70 <need3>
     8f2:	00003617          	auipc	a2,0x3
     8f6:	06e60613          	addi	a2,a2,110 # 3960 <alloc3>
     8fa:	458d                	li	a1,3
     8fc:	4515                	li	a0,5
     8fe:	a77ff0ef          	jal	374 <is_safe_state>
     902:	20051663          	bnez	a0,b0e <main+0x554>
  for (int j = 0; j < m3; j++) {
     906:	00003697          	auipc	a3,0x3
     90a:	36a68693          	addi	a3,a3,874 # 3c70 <need3>
     90e:	00003717          	auipc	a4,0x3
     912:	05270713          	addi	a4,a4,82 # 3960 <alloc3>
     916:	00003797          	auipc	a5,0x3
     91a:	1da78793          	addi	a5,a5,474 # 3af0 <avail3>
      for (int i = 0; i < n3; i++)
        printf("P%d%s", safe_seq[i], (i == n3 - 1) ? ">\n" : ", ");
    }
    // Rollback for next test
    for (int j = 0; j < m3; j++) {
      avail3[j] += req_p1[j];
     91e:	000a2583          	lw	a1,0(s4)
     922:	4390                	lw	a2,0(a5)
     924:	9e2d                	addw	a2,a2,a1
     926:	c390                	sw	a2,0(a5)
      alloc3[1][j] -= req_p1[j];
     928:	5710                	lw	a2,40(a4)
     92a:	9e0d                	subw	a2,a2,a1
     92c:	d710                	sw	a2,40(a4)
      need3[1][j] += req_p1[j];
     92e:	5690                	lw	a2,40(a3)
     930:	9e2d                	addw	a2,a2,a1
     932:	d690                	sw	a2,40(a3)
    for (int j = 0; j < m3; j++) {
     934:	0791                	addi	a5,a5,4
     936:	0a11                	addi	s4,s4,4
     938:	0711                	addi	a4,a4,4
     93a:	0691                	addi	a3,a3,4
     93c:	ff5791e3          	bne	a5,s5,91e <main+0x364>
    }
  }

  // Scenario 3b: Hypothetical Unsafe Request from P0: [0, 3, 0]
  printf("\n--- Request Scenario B (Unsafe Request) ---\n");
     940:	00001517          	auipc	a0,0x1
     944:	29050513          	addi	a0,a0,656 # 1bd0 <malloc+0x824>
     948:	1ad000ef          	jal	12f4 <printf>
  printf("Hypothetical Request: Process P0 requests [R0=0, R1=3, R2=0]...\n");
     94c:	00001517          	auipc	a0,0x1
     950:	2b450513          	addi	a0,a0,692 # 1c00 <malloc+0x854>
     954:	1a1000ef          	jal	12f4 <printf>
  int req_p0[3] = {0, 3, 0};
     958:	f8042823          	sw	zero,-112(s0)
     95c:	478d                	li	a5,3
     95e:	f8f42a23          	sw	a5,-108(s0)
     962:	f8042c23          	sw	zero,-104(s0)
  for (int j = 0; j < m3; j++) {
     966:	f9040a13          	addi	s4,s0,-112
     96a:	00003a97          	auipc	s5,0x3
     96e:	192a8a93          	addi	s5,s5,402 # 3afc <avail3+0xc>
  int req_p0[3] = {0, 3, 0};
     972:	00003697          	auipc	a3,0x3
     976:	2fe68693          	addi	a3,a3,766 # 3c70 <need3>
     97a:	00003717          	auipc	a4,0x3
     97e:	fe670713          	addi	a4,a4,-26 # 3960 <alloc3>
     982:	8552                	mv	a0,s4
     984:	00003797          	auipc	a5,0x3
     988:	16c78793          	addi	a5,a5,364 # 3af0 <avail3>
    avail3[j] -= req_p0[j];
     98c:	410c                	lw	a1,0(a0)
     98e:	4390                	lw	a2,0(a5)
     990:	9e0d                	subw	a2,a2,a1
     992:	c390                	sw	a2,0(a5)
    alloc3[0][j] += req_p0[j];
     994:	4310                	lw	a2,0(a4)
     996:	9e2d                	addw	a2,a2,a1
     998:	c310                	sw	a2,0(a4)
    need3[0][j] -= req_p0[j];
     99a:	4290                	lw	a2,0(a3)
     99c:	9e0d                	subw	a2,a2,a1
     99e:	c290                	sw	a2,0(a3)
  for (int j = 0; j < m3; j++) {
     9a0:	0791                	addi	a5,a5,4
     9a2:	0511                	addi	a0,a0,4
     9a4:	0711                	addi	a4,a4,4
     9a6:	0691                	addi	a3,a3,4
     9a8:	ff5792e3          	bne	a5,s5,98c <main+0x3d2>
  }

  print_state(n3, m3, alloc3, need3, "Need      ", avail3);
     9ac:	00003797          	auipc	a5,0x3
     9b0:	14478793          	addi	a5,a5,324 # 3af0 <avail3>
     9b4:	00001717          	auipc	a4,0x1
     9b8:	0fc70713          	addi	a4,a4,252 # 1ab0 <malloc+0x704>
     9bc:	00003697          	auipc	a3,0x3
     9c0:	2b468693          	addi	a3,a3,692 # 3c70 <need3>
     9c4:	00003617          	auipc	a2,0x3
     9c8:	f9c60613          	addi	a2,a2,-100 # 3960 <alloc3>
     9cc:	458d                	li	a1,3
     9ce:	4515                	li	a0,5
     9d0:	e30ff0ef          	jal	0 <print_state>

  if (is_safe_state(n3, m3, alloc3, need3, avail3, safe_seq)) {
     9d4:	00003797          	auipc	a5,0x3
     9d8:	42c78793          	addi	a5,a5,1068 # 3e00 <safe_seq>
     9dc:	00003717          	auipc	a4,0x3
     9e0:	11470713          	addi	a4,a4,276 # 3af0 <avail3>
     9e4:	00003697          	auipc	a3,0x3
     9e8:	28c68693          	addi	a3,a3,652 # 3c70 <need3>
     9ec:	00003617          	auipc	a2,0x3
     9f0:	f7460613          	addi	a2,a2,-140 # 3960 <alloc3>
     9f4:	458d                	li	a1,3
     9f6:	4515                	li	a0,5
     9f8:	97dff0ef          	jal	374 <is_safe_state>
     9fc:	16050e63          	beqz	a0,b78 <main+0x5be>
    printf("Request Evaluation: GRANTED (System remains in safe state).\n");
     a00:	00001517          	auipc	a0,0x1
     a04:	17850513          	addi	a0,a0,376 # 1b78 <malloc+0x7cc>
     a08:	0ed000ef          	jal	12f4 <printf>
    }
    printf("State successfully rolled back to safe configuration.\n");
  }

  // Scenario 3c: Request Exceeding Available: P0 requests [4, 0, 0] (Avail is [3, 3, 2])
  printf("\n--- Request Scenario C (Exceeds Available Resources) ---\n");
     a0c:	00001517          	auipc	a0,0x1
     a10:	2b450513          	addi	a0,a0,692 # 1cc0 <malloc+0x914>
     a14:	0e1000ef          	jal	12f4 <printf>
  printf("Hypothetical Request: Process P0 requests [R0=4, R1=0, R2=0]...\n");
     a18:	00001517          	auipc	a0,0x1
     a1c:	2e850513          	addi	a0,a0,744 # 1d00 <malloc+0x954>
     a20:	0d5000ef          	jal	12f4 <printf>
  int req_p0_exceed[3] = {4, 0, 0};
     a24:	4791                	li	a5,4
     a26:	f8f42023          	sw	a5,-128(s0)
     a2a:	f8042223          	sw	zero,-124(s0)
     a2e:	f8042423          	sw	zero,-120(s0)
  int valid = 1;
  for (int j = 0; j < m3; j++) {
     a32:	f8040793          	addi	a5,s0,-128
     a36:	f8c40693          	addi	a3,s0,-116
    if (req_p0_exceed[j] > need3[0][j]) {
     a3a:	438c                	lw	a1,0(a5)
     a3c:	4098                	lw	a4,0(s1)
     a3e:	18b74563          	blt	a4,a1,bc8 <main+0x60e>
      printf("Error: Process has exceeded its maximum claim!\n");
      valid = 0;
      break;
    }
    if (req_p0_exceed[j] > avail3[j]) {
     a42:	0009a603          	lw	a2,0(s3)
     a46:	18b64e63          	blt	a2,a1,be2 <main+0x628>
  for (int j = 0; j < m3; j++) {
     a4a:	0791                	addi	a5,a5,4
     a4c:	0491                	addi	s1,s1,4
     a4e:	0991                	addi	s3,s3,4
     a50:	fef695e3          	bne	a3,a5,a3a <main+0x480>
  }

  // -------------------------------------------------------------------------
  // Pipe Deadlock Simulation
  // -------------------------------------------------------------------------
  printf("\n");
     a54:	00001517          	auipc	a0,0x1
     a58:	abc50513          	addi	a0,a0,-1348 # 1510 <malloc+0x164>
     a5c:	099000ef          	jal	12f4 <printf>
  simulate_pipe_deadlock();
     a60:	a1dff0ef          	jal	47c <simulate_pipe_deadlock>

  printf("\n============================================================\n");
     a64:	00001517          	auipc	a0,0x1
     a68:	d5450513          	addi	a0,a0,-684 # 17b8 <malloc+0x40c>
     a6c:	089000ef          	jal	12f4 <printf>
  printf("All Deadlock Detection and Avoidance tests completed.\n");
     a70:	00001517          	auipc	a0,0x1
     a74:	3b850513          	addi	a0,a0,952 # 1e28 <malloc+0xa7c>
     a78:	07d000ef          	jal	12f4 <printf>
  printf("============================================================\n");
     a7c:	00001517          	auipc	a0,0x1
     a80:	adc50513          	addi	a0,a0,-1316 # 1558 <malloc+0x1ac>
     a84:	071000ef          	jal	12f4 <printf>

  exit(0);
     a88:	4501                	li	a0,0
     a8a:	41c000ef          	jal	ea6 <exit>
     a8e:	85aa                	mv	a1,a0
    printf("RESULT: DEADLOCK DETECTED (%d processes deadlocked).\n", count1);
     a90:	00001517          	auipc	a0,0x1
     a94:	e4050513          	addi	a0,a0,-448 # 18d0 <malloc+0x524>
     a98:	05d000ef          	jal	12f4 <printf>
     a9c:	bedd                	j	692 <main+0xd8>
    printf("RESULT: NO DEADLOCK.\n");
     a9e:	00001517          	auipc	a0,0x1
     aa2:	f7a50513          	addi	a0,a0,-134 # 1a18 <malloc+0x66c>
     aa6:	04f000ef          	jal	12f4 <printf>
     aaa:	b1c9                	j	76c <main+0x1b2>
    printf("Initial State Check: System is in a SAFE state.\nSafe sequence: <");
     aac:	00001517          	auipc	a0,0x1
     ab0:	01450513          	addi	a0,a0,20 # 1ac0 <malloc+0x714>
     ab4:	041000ef          	jal	12f4 <printf>
    for (int i = 0; i < n3; i++)
     ab8:	00003997          	auipc	s3,0x3
     abc:	34898993          	addi	s3,s3,840 # 3e00 <safe_seq>
     ac0:	00003a17          	auipc	s4,0x3
     ac4:	350a0a13          	addi	s4,s4,848 # 3e10 <safe_seq+0x10>
     ac8:	00003b97          	auipc	s7,0x3
     acc:	34cb8b93          	addi	s7,s7,844 # 3e14 <safe_seq+0x14>
      printf("P%d%s", safe_seq[i], (i == n3 - 1) ? ">\n" : ", ");
     ad0:	00001b17          	auipc	s6,0x1
     ad4:	a80b0b13          	addi	s6,s6,-1408 # 1550 <malloc+0x1a4>
     ad8:	00001a97          	auipc	s5,0x1
     adc:	030a8a93          	addi	s5,s5,48 # 1b08 <malloc+0x75c>
     ae0:	a801                	j	af0 <main+0x536>
     ae2:	865a                	mv	a2,s6
     ae4:	8556                	mv	a0,s5
     ae6:	00f000ef          	jal	12f4 <printf>
    for (int i = 0; i < n3; i++)
     aea:	0991                	addi	s3,s3,4
     aec:	d57988e3          	beq	s3,s7,83c <main+0x282>
      printf("P%d%s", safe_seq[i], (i == n3 - 1) ? ">\n" : ", ");
     af0:	0009a583          	lw	a1,0(s3)
     af4:	ff4997e3          	bne	s3,s4,ae2 <main+0x528>
     af8:	00001617          	auipc	a2,0x1
     afc:	36860613          	addi	a2,a2,872 # 1e60 <malloc+0xab4>
     b00:	00001517          	auipc	a0,0x1
     b04:	00850513          	addi	a0,a0,8 # 1b08 <malloc+0x75c>
     b08:	7ec000ef          	jal	12f4 <printf>
    for (int i = 0; i < n3; i++)
     b0c:	bb05                	j	83c <main+0x282>
      printf("Request Evaluation: GRANTED (System remains in safe state).\n");
     b0e:	00001517          	auipc	a0,0x1
     b12:	06a50513          	addi	a0,a0,106 # 1b78 <malloc+0x7cc>
     b16:	7de000ef          	jal	12f4 <printf>
      printf("New Safe Sequence: <");
     b1a:	00001517          	auipc	a0,0x1
     b1e:	09e50513          	addi	a0,a0,158 # 1bb8 <malloc+0x80c>
     b22:	7d2000ef          	jal	12f4 <printf>
      for (int i = 0; i < n3; i++)
     b26:	00003b17          	auipc	s6,0x3
     b2a:	2dab0b13          	addi	s6,s6,730 # 3e00 <safe_seq>
     b2e:	00003b97          	auipc	s7,0x3
     b32:	2e2b8b93          	addi	s7,s7,738 # 3e10 <safe_seq+0x10>
     b36:	00003c17          	auipc	s8,0x3
     b3a:	2dec0c13          	addi	s8,s8,734 # 3e14 <safe_seq+0x14>
     b3e:	a831                	j	b5a <main+0x5a0>
        printf("P%d%s", safe_seq[i], (i == n3 - 1) ? ">\n" : ", ");
     b40:	00001617          	auipc	a2,0x1
     b44:	a1060613          	addi	a2,a2,-1520 # 1550 <malloc+0x1a4>
     b48:	00001517          	auipc	a0,0x1
     b4c:	fc050513          	addi	a0,a0,-64 # 1b08 <malloc+0x75c>
     b50:	7a4000ef          	jal	12f4 <printf>
      for (int i = 0; i < n3; i++)
     b54:	0b11                	addi	s6,s6,4
     b56:	db8b08e3          	beq	s6,s8,906 <main+0x34c>
        printf("P%d%s", safe_seq[i], (i == n3 - 1) ? ">\n" : ", ");
     b5a:	000b2583          	lw	a1,0(s6)
     b5e:	ff7b11e3          	bne	s6,s7,b40 <main+0x586>
     b62:	00001617          	auipc	a2,0x1
     b66:	2fe60613          	addi	a2,a2,766 # 1e60 <malloc+0xab4>
     b6a:	00001517          	auipc	a0,0x1
     b6e:	f9e50513          	addi	a0,a0,-98 # 1b08 <malloc+0x75c>
     b72:	782000ef          	jal	12f4 <printf>
      for (int i = 0; i < n3; i++)
     b76:	bb41                	j	906 <main+0x34c>
    printf("Request Evaluation: DENIED! Would lead to an UNSAFE state.\n");
     b78:	00001517          	auipc	a0,0x1
     b7c:	0d050513          	addi	a0,a0,208 # 1c48 <malloc+0x89c>
     b80:	774000ef          	jal	12f4 <printf>
     b84:	00003717          	auipc	a4,0x3
     b88:	0ec70713          	addi	a4,a4,236 # 3c70 <need3>
     b8c:	00003797          	auipc	a5,0x3
     b90:	f6478793          	addi	a5,a5,-156 # 3af0 <avail3>
      avail3[j] += req_p0[j];
     b94:	000a2603          	lw	a2,0(s4)
     b98:	4394                	lw	a3,0(a5)
     b9a:	9eb1                	addw	a3,a3,a2
     b9c:	c394                	sw	a3,0(a5)
      alloc3[0][j] -= req_p0[j];
     b9e:	00092683          	lw	a3,0(s2)
     ba2:	9e91                	subw	a3,a3,a2
     ba4:	00d92023          	sw	a3,0(s2)
      need3[0][j] += req_p0[j];
     ba8:	4314                	lw	a3,0(a4)
     baa:	9eb1                	addw	a3,a3,a2
     bac:	c314                	sw	a3,0(a4)
    for (int j = 0; j < m3; j++) {
     bae:	0791                	addi	a5,a5,4
     bb0:	0a11                	addi	s4,s4,4
     bb2:	0911                	addi	s2,s2,4
     bb4:	0711                	addi	a4,a4,4
     bb6:	fd579fe3          	bne	a5,s5,b94 <main+0x5da>
    printf("State successfully rolled back to safe configuration.\n");
     bba:	00001517          	auipc	a0,0x1
     bbe:	0ce50513          	addi	a0,a0,206 # 1c88 <malloc+0x8dc>
     bc2:	732000ef          	jal	12f4 <printf>
     bc6:	b599                	j	a0c <main+0x452>
      printf("Error: Process has exceeded its maximum claim!\n");
     bc8:	00001517          	auipc	a0,0x1
     bcc:	18050513          	addi	a0,a0,384 # 1d48 <malloc+0x99c>
     bd0:	724000ef          	jal	12f4 <printf>
    printf("Request Evaluation: REJECTED immediately (insufficient available resources).\n");
     bd4:	00001517          	auipc	a0,0x1
     bd8:	20450513          	addi	a0,a0,516 # 1dd8 <malloc+0xa2c>
     bdc:	718000ef          	jal	12f4 <printf>
     be0:	bd95                	j	a54 <main+0x49a>
      printf("Error: Process must wait, since resources are not available (Requested %d > Available %d)!\n",
     be2:	00001517          	auipc	a0,0x1
     be6:	19650513          	addi	a0,a0,406 # 1d78 <malloc+0x9cc>
     bea:	70a000ef          	jal	12f4 <printf>
  if (!valid) {
     bee:	b7dd                	j	bd4 <main+0x61a>

0000000000000bf0 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
     bf0:	1141                	addi	sp,sp,-16
     bf2:	e406                	sd	ra,8(sp)
     bf4:	e022                	sd	s0,0(sp)
     bf6:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
     bf8:	9c3ff0ef          	jal	5ba <main>
  exit(r);
     bfc:	2aa000ef          	jal	ea6 <exit>

0000000000000c00 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
     c00:	1141                	addi	sp,sp,-16
     c02:	e406                	sd	ra,8(sp)
     c04:	e022                	sd	s0,0(sp)
     c06:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
     c08:	87aa                	mv	a5,a0
     c0a:	0585                	addi	a1,a1,1
     c0c:	0785                	addi	a5,a5,1
     c0e:	fff5c703          	lbu	a4,-1(a1)
     c12:	fee78fa3          	sb	a4,-1(a5)
     c16:	fb75                	bnez	a4,c0a <strcpy+0xa>
    ;
  return os;
}
     c18:	60a2                	ld	ra,8(sp)
     c1a:	6402                	ld	s0,0(sp)
     c1c:	0141                	addi	sp,sp,16
     c1e:	8082                	ret

0000000000000c20 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c20:	1141                	addi	sp,sp,-16
     c22:	e406                	sd	ra,8(sp)
     c24:	e022                	sd	s0,0(sp)
     c26:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
     c28:	00054783          	lbu	a5,0(a0)
     c2c:	cb91                	beqz	a5,c40 <strcmp+0x20>
     c2e:	0005c703          	lbu	a4,0(a1)
     c32:	00f71763          	bne	a4,a5,c40 <strcmp+0x20>
    p++, q++;
     c36:	0505                	addi	a0,a0,1
     c38:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
     c3a:	00054783          	lbu	a5,0(a0)
     c3e:	fbe5                	bnez	a5,c2e <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
     c40:	0005c503          	lbu	a0,0(a1)
}
     c44:	40a7853b          	subw	a0,a5,a0
     c48:	60a2                	ld	ra,8(sp)
     c4a:	6402                	ld	s0,0(sp)
     c4c:	0141                	addi	sp,sp,16
     c4e:	8082                	ret

0000000000000c50 <strlen>:

uint
strlen(const char *s)
{
     c50:	1141                	addi	sp,sp,-16
     c52:	e406                	sd	ra,8(sp)
     c54:	e022                	sd	s0,0(sp)
     c56:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
     c58:	00054783          	lbu	a5,0(a0)
     c5c:	cf91                	beqz	a5,c78 <strlen+0x28>
     c5e:	00150793          	addi	a5,a0,1
     c62:	86be                	mv	a3,a5
     c64:	0785                	addi	a5,a5,1
     c66:	fff7c703          	lbu	a4,-1(a5)
     c6a:	ff65                	bnez	a4,c62 <strlen+0x12>
     c6c:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
     c70:	60a2                	ld	ra,8(sp)
     c72:	6402                	ld	s0,0(sp)
     c74:	0141                	addi	sp,sp,16
     c76:	8082                	ret
  for (n = 0; s[n]; n++)
     c78:	4501                	li	a0,0
     c7a:	bfdd                	j	c70 <strlen+0x20>

0000000000000c7c <memset>:

void *
memset(void *dst, int c, uint n)
{
     c7c:	1141                	addi	sp,sp,-16
     c7e:	e406                	sd	ra,8(sp)
     c80:	e022                	sd	s0,0(sp)
     c82:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
     c84:	ca19                	beqz	a2,c9a <memset+0x1e>
     c86:	87aa                	mv	a5,a0
     c88:	1602                	slli	a2,a2,0x20
     c8a:	9201                	srli	a2,a2,0x20
     c8c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     c90:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
     c94:	0785                	addi	a5,a5,1
     c96:	fee79de3          	bne	a5,a4,c90 <memset+0x14>
  }
  return dst;
}
     c9a:	60a2                	ld	ra,8(sp)
     c9c:	6402                	ld	s0,0(sp)
     c9e:	0141                	addi	sp,sp,16
     ca0:	8082                	ret

0000000000000ca2 <strchr>:

char *
strchr(const char *s, char c)
{
     ca2:	1141                	addi	sp,sp,-16
     ca4:	e406                	sd	ra,8(sp)
     ca6:	e022                	sd	s0,0(sp)
     ca8:	0800                	addi	s0,sp,16
  for (; *s; s++)
     caa:	00054783          	lbu	a5,0(a0)
     cae:	cf81                	beqz	a5,cc6 <strchr+0x24>
    if (*s == c)
     cb0:	00f58763          	beq	a1,a5,cbe <strchr+0x1c>
  for (; *s; s++)
     cb4:	0505                	addi	a0,a0,1
     cb6:	00054783          	lbu	a5,0(a0)
     cba:	fbfd                	bnez	a5,cb0 <strchr+0xe>
      return (char *)s;
  return 0;
     cbc:	4501                	li	a0,0
}
     cbe:	60a2                	ld	ra,8(sp)
     cc0:	6402                	ld	s0,0(sp)
     cc2:	0141                	addi	sp,sp,16
     cc4:	8082                	ret
  return 0;
     cc6:	4501                	li	a0,0
     cc8:	bfdd                	j	cbe <strchr+0x1c>

0000000000000cca <gets>:

char *
gets(char *buf, int max)
{
     cca:	711d                	addi	sp,sp,-96
     ccc:	ec86                	sd	ra,88(sp)
     cce:	e8a2                	sd	s0,80(sp)
     cd0:	e4a6                	sd	s1,72(sp)
     cd2:	e0ca                	sd	s2,64(sp)
     cd4:	fc4e                	sd	s3,56(sp)
     cd6:	f852                	sd	s4,48(sp)
     cd8:	f456                	sd	s5,40(sp)
     cda:	f05a                	sd	s6,32(sp)
     cdc:	ec5e                	sd	s7,24(sp)
     cde:	e862                	sd	s8,16(sp)
     ce0:	1080                	addi	s0,sp,96
     ce2:	8baa                	mv	s7,a0
     ce4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
     ce6:	892a                	mv	s2,a0
     ce8:	4481                	li	s1,0
    cc = read(0, &c, 1);
     cea:	faf40b13          	addi	s6,s0,-81
     cee:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
     cf0:	8c26                	mv	s8,s1
     cf2:	0014899b          	addiw	s3,s1,1
     cf6:	84ce                	mv	s1,s3
     cf8:	0349d463          	bge	s3,s4,d20 <gets+0x56>
    cc = read(0, &c, 1);
     cfc:	8656                	mv	a2,s5
     cfe:	85da                	mv	a1,s6
     d00:	4501                	li	a0,0
     d02:	1bc000ef          	jal	ebe <read>
    if (cc < 1)
     d06:	00a05d63          	blez	a0,d20 <gets+0x56>
      break;
    buf[i++] = c;
     d0a:	faf44783          	lbu	a5,-81(s0)
     d0e:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
     d12:	0905                	addi	s2,s2,1
     d14:	ff678713          	addi	a4,a5,-10
     d18:	c319                	beqz	a4,d1e <gets+0x54>
     d1a:	17cd                	addi	a5,a5,-13
     d1c:	fbf1                	bnez	a5,cf0 <gets+0x26>
    buf[i++] = c;
     d1e:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
     d20:	9c5e                	add	s8,s8,s7
     d22:	000c0023          	sb	zero,0(s8)
  return buf;
}
     d26:	855e                	mv	a0,s7
     d28:	60e6                	ld	ra,88(sp)
     d2a:	6446                	ld	s0,80(sp)
     d2c:	64a6                	ld	s1,72(sp)
     d2e:	6906                	ld	s2,64(sp)
     d30:	79e2                	ld	s3,56(sp)
     d32:	7a42                	ld	s4,48(sp)
     d34:	7aa2                	ld	s5,40(sp)
     d36:	7b02                	ld	s6,32(sp)
     d38:	6be2                	ld	s7,24(sp)
     d3a:	6c42                	ld	s8,16(sp)
     d3c:	6125                	addi	sp,sp,96
     d3e:	8082                	ret

0000000000000d40 <stat>:

int
stat(const char *n, struct stat *st)
{
     d40:	1101                	addi	sp,sp,-32
     d42:	ec06                	sd	ra,24(sp)
     d44:	e822                	sd	s0,16(sp)
     d46:	e04a                	sd	s2,0(sp)
     d48:	1000                	addi	s0,sp,32
     d4a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d4c:	4581                	li	a1,0
     d4e:	198000ef          	jal	ee6 <open>
  if (fd < 0)
     d52:	02054263          	bltz	a0,d76 <stat+0x36>
     d56:	e426                	sd	s1,8(sp)
     d58:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d5a:	85ca                	mv	a1,s2
     d5c:	1a2000ef          	jal	efe <fstat>
     d60:	892a                	mv	s2,a0
  close(fd);
     d62:	8526                	mv	a0,s1
     d64:	16a000ef          	jal	ece <close>
  return r;
     d68:	64a2                	ld	s1,8(sp)
}
     d6a:	854a                	mv	a0,s2
     d6c:	60e2                	ld	ra,24(sp)
     d6e:	6442                	ld	s0,16(sp)
     d70:	6902                	ld	s2,0(sp)
     d72:	6105                	addi	sp,sp,32
     d74:	8082                	ret
    return -1;
     d76:	57fd                	li	a5,-1
     d78:	893e                	mv	s2,a5
     d7a:	bfc5                	j	d6a <stat+0x2a>

0000000000000d7c <atoi>:

int
atoi(const char *s)
{
     d7c:	1141                	addi	sp,sp,-16
     d7e:	e406                	sd	ra,8(sp)
     d80:	e022                	sd	s0,0(sp)
     d82:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
     d84:	00054683          	lbu	a3,0(a0)
     d88:	fd06879b          	addiw	a5,a3,-48
     d8c:	0ff7f793          	zext.b	a5,a5
     d90:	4625                	li	a2,9
     d92:	02f66963          	bltu	a2,a5,dc4 <atoi+0x48>
     d96:	872a                	mv	a4,a0
  n = 0;
     d98:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
     d9a:	0705                	addi	a4,a4,1
     d9c:	0025179b          	slliw	a5,a0,0x2
     da0:	9fa9                	addw	a5,a5,a0
     da2:	0017979b          	slliw	a5,a5,0x1
     da6:	9fb5                	addw	a5,a5,a3
     da8:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
     dac:	00074683          	lbu	a3,0(a4)
     db0:	fd06879b          	addiw	a5,a3,-48
     db4:	0ff7f793          	zext.b	a5,a5
     db8:	fef671e3          	bgeu	a2,a5,d9a <atoi+0x1e>
  return n;
}
     dbc:	60a2                	ld	ra,8(sp)
     dbe:	6402                	ld	s0,0(sp)
     dc0:	0141                	addi	sp,sp,16
     dc2:	8082                	ret
  n = 0;
     dc4:	4501                	li	a0,0
     dc6:	bfdd                	j	dbc <atoi+0x40>

0000000000000dc8 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
     dc8:	1141                	addi	sp,sp,-16
     dca:	e406                	sd	ra,8(sp)
     dcc:	e022                	sd	s0,0(sp)
     dce:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     dd0:	02b57563          	bgeu	a0,a1,dfa <memmove+0x32>
    while (n-- > 0)
     dd4:	00c05f63          	blez	a2,df2 <memmove+0x2a>
     dd8:	1602                	slli	a2,a2,0x20
     dda:	9201                	srli	a2,a2,0x20
     ddc:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     de0:	872a                	mv	a4,a0
      *dst++ = *src++;
     de2:	0585                	addi	a1,a1,1
     de4:	0705                	addi	a4,a4,1
     de6:	fff5c683          	lbu	a3,-1(a1)
     dea:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
     dee:	fee79ae3          	bne	a5,a4,de2 <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     df2:	60a2                	ld	ra,8(sp)
     df4:	6402                	ld	s0,0(sp)
     df6:	0141                	addi	sp,sp,16
     df8:	8082                	ret
    while (n-- > 0)
     dfa:	fec05ce3          	blez	a2,df2 <memmove+0x2a>
    dst += n;
     dfe:	00c50733          	add	a4,a0,a2
    src += n;
     e02:	95b2                	add	a1,a1,a2
     e04:	fff6079b          	addiw	a5,a2,-1
     e08:	1782                	slli	a5,a5,0x20
     e0a:	9381                	srli	a5,a5,0x20
     e0c:	fff7c793          	not	a5,a5
     e10:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     e12:	15fd                	addi	a1,a1,-1
     e14:	177d                	addi	a4,a4,-1
     e16:	0005c683          	lbu	a3,0(a1)
     e1a:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
     e1e:	fef71ae3          	bne	a4,a5,e12 <memmove+0x4a>
     e22:	bfc1                	j	df2 <memmove+0x2a>

0000000000000e24 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     e24:	1141                	addi	sp,sp,-16
     e26:	e406                	sd	ra,8(sp)
     e28:	e022                	sd	s0,0(sp)
     e2a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     e2c:	c61d                	beqz	a2,e5a <memcmp+0x36>
     e2e:	1602                	slli	a2,a2,0x20
     e30:	9201                	srli	a2,a2,0x20
     e32:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
     e36:	00054783          	lbu	a5,0(a0)
     e3a:	0005c703          	lbu	a4,0(a1)
     e3e:	00e79863          	bne	a5,a4,e4e <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
     e42:	0505                	addi	a0,a0,1
    p2++;
     e44:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     e46:	fed518e3          	bne	a0,a3,e36 <memcmp+0x12>
  }
  return 0;
     e4a:	4501                	li	a0,0
     e4c:	a019                	j	e52 <memcmp+0x2e>
      return *p1 - *p2;
     e4e:	40e7853b          	subw	a0,a5,a4
}
     e52:	60a2                	ld	ra,8(sp)
     e54:	6402                	ld	s0,0(sp)
     e56:	0141                	addi	sp,sp,16
     e58:	8082                	ret
  return 0;
     e5a:	4501                	li	a0,0
     e5c:	bfdd                	j	e52 <memcmp+0x2e>

0000000000000e5e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e5e:	1141                	addi	sp,sp,-16
     e60:	e406                	sd	ra,8(sp)
     e62:	e022                	sd	s0,0(sp)
     e64:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e66:	f63ff0ef          	jal	dc8 <memmove>
}
     e6a:	60a2                	ld	ra,8(sp)
     e6c:	6402                	ld	s0,0(sp)
     e6e:	0141                	addi	sp,sp,16
     e70:	8082                	ret

0000000000000e72 <sbrk>:

char *
sbrk(int n)
{
     e72:	1141                	addi	sp,sp,-16
     e74:	e406                	sd	ra,8(sp)
     e76:	e022                	sd	s0,0(sp)
     e78:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
     e7a:	4585                	li	a1,1
     e7c:	0b2000ef          	jal	f2e <sys_sbrk>
}
     e80:	60a2                	ld	ra,8(sp)
     e82:	6402                	ld	s0,0(sp)
     e84:	0141                	addi	sp,sp,16
     e86:	8082                	ret

0000000000000e88 <sbrklazy>:

char *
sbrklazy(int n)
{
     e88:	1141                	addi	sp,sp,-16
     e8a:	e406                	sd	ra,8(sp)
     e8c:	e022                	sd	s0,0(sp)
     e8e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
     e90:	4589                	li	a1,2
     e92:	09c000ef          	jal	f2e <sys_sbrk>
}
     e96:	60a2                	ld	ra,8(sp)
     e98:	6402                	ld	s0,0(sp)
     e9a:	0141                	addi	sp,sp,16
     e9c:	8082                	ret

0000000000000e9e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e9e:	4885                	li	a7,1
 ecall
     ea0:	00000073          	ecall
 ret
     ea4:	8082                	ret

0000000000000ea6 <exit>:
.global exit
exit:
 li a7, SYS_exit
     ea6:	4889                	li	a7,2
 ecall
     ea8:	00000073          	ecall
 ret
     eac:	8082                	ret

0000000000000eae <wait>:
.global wait
wait:
 li a7, SYS_wait
     eae:	488d                	li	a7,3
 ecall
     eb0:	00000073          	ecall
 ret
     eb4:	8082                	ret

0000000000000eb6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     eb6:	4891                	li	a7,4
 ecall
     eb8:	00000073          	ecall
 ret
     ebc:	8082                	ret

0000000000000ebe <read>:
.global read
read:
 li a7, SYS_read
     ebe:	4895                	li	a7,5
 ecall
     ec0:	00000073          	ecall
 ret
     ec4:	8082                	ret

0000000000000ec6 <write>:
.global write
write:
 li a7, SYS_write
     ec6:	48c1                	li	a7,16
 ecall
     ec8:	00000073          	ecall
 ret
     ecc:	8082                	ret

0000000000000ece <close>:
.global close
close:
 li a7, SYS_close
     ece:	48d5                	li	a7,21
 ecall
     ed0:	00000073          	ecall
 ret
     ed4:	8082                	ret

0000000000000ed6 <kill>:
.global kill
kill:
 li a7, SYS_kill
     ed6:	4899                	li	a7,6
 ecall
     ed8:	00000073          	ecall
 ret
     edc:	8082                	ret

0000000000000ede <exec>:
.global exec
exec:
 li a7, SYS_exec
     ede:	489d                	li	a7,7
 ecall
     ee0:	00000073          	ecall
 ret
     ee4:	8082                	ret

0000000000000ee6 <open>:
.global open
open:
 li a7, SYS_open
     ee6:	48bd                	li	a7,15
 ecall
     ee8:	00000073          	ecall
 ret
     eec:	8082                	ret

0000000000000eee <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     eee:	48c5                	li	a7,17
 ecall
     ef0:	00000073          	ecall
 ret
     ef4:	8082                	ret

0000000000000ef6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     ef6:	48c9                	li	a7,18
 ecall
     ef8:	00000073          	ecall
 ret
     efc:	8082                	ret

0000000000000efe <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     efe:	48a1                	li	a7,8
 ecall
     f00:	00000073          	ecall
 ret
     f04:	8082                	ret

0000000000000f06 <link>:
.global link
link:
 li a7, SYS_link
     f06:	48cd                	li	a7,19
 ecall
     f08:	00000073          	ecall
 ret
     f0c:	8082                	ret

0000000000000f0e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     f0e:	48d1                	li	a7,20
 ecall
     f10:	00000073          	ecall
 ret
     f14:	8082                	ret

0000000000000f16 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     f16:	48a5                	li	a7,9
 ecall
     f18:	00000073          	ecall
 ret
     f1c:	8082                	ret

0000000000000f1e <dup>:
.global dup
dup:
 li a7, SYS_dup
     f1e:	48a9                	li	a7,10
 ecall
     f20:	00000073          	ecall
 ret
     f24:	8082                	ret

0000000000000f26 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     f26:	48ad                	li	a7,11
 ecall
     f28:	00000073          	ecall
 ret
     f2c:	8082                	ret

0000000000000f2e <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
     f2e:	48b1                	li	a7,12
 ecall
     f30:	00000073          	ecall
 ret
     f34:	8082                	ret

0000000000000f36 <pause>:
.global pause
pause:
 li a7, SYS_pause
     f36:	48b5                	li	a7,13
 ecall
     f38:	00000073          	ecall
 ret
     f3c:	8082                	ret

0000000000000f3e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     f3e:	48b9                	li	a7,14
 ecall
     f40:	00000073          	ecall
 ret
     f44:	8082                	ret

0000000000000f46 <sync>:
.global sync
sync:
 li a7, SYS_sync
     f46:	48d9                	li	a7,22
 ecall
     f48:	00000073          	ecall
 ret
     f4c:	8082                	ret

0000000000000f4e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f4e:	1101                	addi	sp,sp,-32
     f50:	ec06                	sd	ra,24(sp)
     f52:	e822                	sd	s0,16(sp)
     f54:	1000                	addi	s0,sp,32
     f56:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f5a:	4605                	li	a2,1
     f5c:	fef40593          	addi	a1,s0,-17
     f60:	f67ff0ef          	jal	ec6 <write>
}
     f64:	60e2                	ld	ra,24(sp)
     f66:	6442                	ld	s0,16(sp)
     f68:	6105                	addi	sp,sp,32
     f6a:	8082                	ret

0000000000000f6c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
     f6c:	715d                	addi	sp,sp,-80
     f6e:	e486                	sd	ra,72(sp)
     f70:	e0a2                	sd	s0,64(sp)
     f72:	f84a                	sd	s2,48(sp)
     f74:	f44e                	sd	s3,40(sp)
     f76:	0880                	addi	s0,sp,80
     f78:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
     f7a:	c6d1                	beqz	a3,1006 <printint+0x9a>
     f7c:	0805d563          	bgez	a1,1006 <printint+0x9a>
    neg = 1;
    x = -xx;
     f80:	40b005b3          	neg	a1,a1
    neg = 1;
     f84:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
     f86:	fb840993          	addi	s3,s0,-72
  neg = 0;
     f8a:	86ce                	mv	a3,s3
  i = 0;
     f8c:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
     f8e:	00001817          	auipc	a6,0x1
     f92:	07280813          	addi	a6,a6,114 # 2000 <digits>
     f96:	88ba                	mv	a7,a4
     f98:	0017051b          	addiw	a0,a4,1
     f9c:	872a                	mv	a4,a0
     f9e:	02c5f7b3          	remu	a5,a1,a2
     fa2:	97c2                	add	a5,a5,a6
     fa4:	0007c783          	lbu	a5,0(a5)
     fa8:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
     fac:	87ae                	mv	a5,a1
     fae:	02c5d5b3          	divu	a1,a1,a2
     fb2:	0685                	addi	a3,a3,1
     fb4:	fec7f1e3          	bgeu	a5,a2,f96 <printint+0x2a>
  if (neg)
     fb8:	00030c63          	beqz	t1,fd0 <printint+0x64>
    buf[i++] = '-';
     fbc:	fd050793          	addi	a5,a0,-48
     fc0:	00878533          	add	a0,a5,s0
     fc4:	02d00793          	li	a5,45
     fc8:	fef50423          	sb	a5,-24(a0)
     fcc:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
     fd0:	02e05563          	blez	a4,ffa <printint+0x8e>
     fd4:	fc26                	sd	s1,56(sp)
     fd6:	377d                	addiw	a4,a4,-1
     fd8:	00e984b3          	add	s1,s3,a4
     fdc:	19fd                	addi	s3,s3,-1
     fde:	99ba                	add	s3,s3,a4
     fe0:	1702                	slli	a4,a4,0x20
     fe2:	9301                	srli	a4,a4,0x20
     fe4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     fe8:	0004c583          	lbu	a1,0(s1)
     fec:	854a                	mv	a0,s2
     fee:	f61ff0ef          	jal	f4e <putc>
  while (--i >= 0)
     ff2:	14fd                	addi	s1,s1,-1
     ff4:	ff349ae3          	bne	s1,s3,fe8 <printint+0x7c>
     ff8:	74e2                	ld	s1,56(sp)
}
     ffa:	60a6                	ld	ra,72(sp)
     ffc:	6406                	ld	s0,64(sp)
     ffe:	7942                	ld	s2,48(sp)
    1000:	79a2                	ld	s3,40(sp)
    1002:	6161                	addi	sp,sp,80
    1004:	8082                	ret
  neg = 0;
    1006:	4301                	li	t1,0
    1008:	bfbd                	j	f86 <printint+0x1a>

000000000000100a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    100a:	711d                	addi	sp,sp,-96
    100c:	ec86                	sd	ra,88(sp)
    100e:	e8a2                	sd	s0,80(sp)
    1010:	e4a6                	sd	s1,72(sp)
    1012:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
    1014:	0005c483          	lbu	s1,0(a1)
    1018:	22048363          	beqz	s1,123e <vprintf+0x234>
    101c:	e0ca                	sd	s2,64(sp)
    101e:	fc4e                	sd	s3,56(sp)
    1020:	f852                	sd	s4,48(sp)
    1022:	f456                	sd	s5,40(sp)
    1024:	f05a                	sd	s6,32(sp)
    1026:	ec5e                	sd	s7,24(sp)
    1028:	e862                	sd	s8,16(sp)
    102a:	8b2a                	mv	s6,a0
    102c:	8a2e                	mv	s4,a1
    102e:	8bb2                	mv	s7,a2
  state = 0;
    1030:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
    1032:	4901                	li	s2,0
    1034:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
    1036:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
    103a:	06400c13          	li	s8,100
    103e:	a00d                	j	1060 <vprintf+0x56>
        putc(fd, c0);
    1040:	85a6                	mv	a1,s1
    1042:	855a                	mv	a0,s6
    1044:	f0bff0ef          	jal	f4e <putc>
    1048:	a019                	j	104e <vprintf+0x44>
    } else if (state == '%') {
    104a:	03598363          	beq	s3,s5,1070 <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
    104e:	0019079b          	addiw	a5,s2,1
    1052:	893e                	mv	s2,a5
    1054:	873e                	mv	a4,a5
    1056:	97d2                	add	a5,a5,s4
    1058:	0007c483          	lbu	s1,0(a5)
    105c:	1c048a63          	beqz	s1,1230 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
    1060:	0004879b          	sext.w	a5,s1
    if (state == 0) {
    1064:	fe0993e3          	bnez	s3,104a <vprintf+0x40>
      if (c0 == '%') {
    1068:	fd579ce3          	bne	a5,s5,1040 <vprintf+0x36>
        state = '%';
    106c:	89be                	mv	s3,a5
    106e:	b7c5                	j	104e <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
    1070:	00ea06b3          	add	a3,s4,a4
    1074:	0016c603          	lbu	a2,1(a3)
      if (c1)
    1078:	1c060863          	beqz	a2,1248 <vprintf+0x23e>
      if (c0 == 'd') {
    107c:	03878763          	beq	a5,s8,10aa <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
    1080:	f9478693          	addi	a3,a5,-108
    1084:	0016b693          	seqz	a3,a3
    1088:	f9c60593          	addi	a1,a2,-100
    108c:	e99d                	bnez	a1,10c2 <vprintf+0xb8>
    108e:	ca95                	beqz	a3,10c2 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
    1090:	008b8493          	addi	s1,s7,8
    1094:	4685                	li	a3,1
    1096:	4629                	li	a2,10
    1098:	000bb583          	ld	a1,0(s7)
    109c:	855a                	mv	a0,s6
    109e:	ecfff0ef          	jal	f6c <printint>
        i += 1;
    10a2:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
    10a4:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
    10a6:	4981                	li	s3,0
    10a8:	b75d                	j	104e <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
    10aa:	008b8493          	addi	s1,s7,8
    10ae:	4685                	li	a3,1
    10b0:	4629                	li	a2,10
    10b2:	000ba583          	lw	a1,0(s7)
    10b6:	855a                	mv	a0,s6
    10b8:	eb5ff0ef          	jal	f6c <printint>
    10bc:	8ba6                	mv	s7,s1
      state = 0;
    10be:	4981                	li	s3,0
    10c0:	b779                	j	104e <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
    10c2:	9752                	add	a4,a4,s4
    10c4:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    10c8:	f9460713          	addi	a4,a2,-108
    10cc:	00173713          	seqz	a4,a4
    10d0:	8f75                	and	a4,a4,a3
    10d2:	f9c58513          	addi	a0,a1,-100
    10d6:	18051363          	bnez	a0,125c <vprintf+0x252>
    10da:	18070163          	beqz	a4,125c <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
    10de:	008b8493          	addi	s1,s7,8
    10e2:	4685                	li	a3,1
    10e4:	4629                	li	a2,10
    10e6:	000bb583          	ld	a1,0(s7)
    10ea:	855a                	mv	a0,s6
    10ec:	e81ff0ef          	jal	f6c <printint>
        i += 2;
    10f0:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
    10f2:	8ba6                	mv	s7,s1
      state = 0;
    10f4:	4981                	li	s3,0
        i += 2;
    10f6:	bfa1                	j	104e <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
    10f8:	008b8493          	addi	s1,s7,8
    10fc:	4681                	li	a3,0
    10fe:	4629                	li	a2,10
    1100:	000be583          	lwu	a1,0(s7)
    1104:	855a                	mv	a0,s6
    1106:	e67ff0ef          	jal	f6c <printint>
    110a:	8ba6                	mv	s7,s1
      state = 0;
    110c:	4981                	li	s3,0
    110e:	b781                	j	104e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1110:	008b8493          	addi	s1,s7,8
    1114:	4681                	li	a3,0
    1116:	4629                	li	a2,10
    1118:	000bb583          	ld	a1,0(s7)
    111c:	855a                	mv	a0,s6
    111e:	e4fff0ef          	jal	f6c <printint>
        i += 1;
    1122:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
    1124:	8ba6                	mv	s7,s1
      state = 0;
    1126:	4981                	li	s3,0
    1128:	b71d                	j	104e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
    112a:	008b8493          	addi	s1,s7,8
    112e:	4681                	li	a3,0
    1130:	4629                	li	a2,10
    1132:	000bb583          	ld	a1,0(s7)
    1136:	855a                	mv	a0,s6
    1138:	e35ff0ef          	jal	f6c <printint>
        i += 2;
    113c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
    113e:	8ba6                	mv	s7,s1
      state = 0;
    1140:	4981                	li	s3,0
        i += 2;
    1142:	b731                	j	104e <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
    1144:	008b8493          	addi	s1,s7,8
    1148:	4681                	li	a3,0
    114a:	4641                	li	a2,16
    114c:	000be583          	lwu	a1,0(s7)
    1150:	855a                	mv	a0,s6
    1152:	e1bff0ef          	jal	f6c <printint>
    1156:	8ba6                	mv	s7,s1
      state = 0;
    1158:	4981                	li	s3,0
    115a:	bdd5                	j	104e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
    115c:	008b8493          	addi	s1,s7,8
    1160:	4681                	li	a3,0
    1162:	4641                	li	a2,16
    1164:	000bb583          	ld	a1,0(s7)
    1168:	855a                	mv	a0,s6
    116a:	e03ff0ef          	jal	f6c <printint>
        i += 1;
    116e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
    1170:	8ba6                	mv	s7,s1
      state = 0;
    1172:	4981                	li	s3,0
    1174:	bde9                	j	104e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
    1176:	008b8493          	addi	s1,s7,8
    117a:	4681                	li	a3,0
    117c:	4641                	li	a2,16
    117e:	000bb583          	ld	a1,0(s7)
    1182:	855a                	mv	a0,s6
    1184:	de9ff0ef          	jal	f6c <printint>
        i += 2;
    1188:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
    118a:	8ba6                	mv	s7,s1
      state = 0;
    118c:	4981                	li	s3,0
        i += 2;
    118e:	b5c1                	j	104e <vprintf+0x44>
    1190:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
    1192:	008b8793          	addi	a5,s7,8
    1196:	8cbe                	mv	s9,a5
    1198:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    119c:	03000593          	li	a1,48
    11a0:	855a                	mv	a0,s6
    11a2:	dadff0ef          	jal	f4e <putc>
  putc(fd, 'x');
    11a6:	07800593          	li	a1,120
    11aa:	855a                	mv	a0,s6
    11ac:	da3ff0ef          	jal	f4e <putc>
    11b0:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    11b2:	00001b97          	auipc	s7,0x1
    11b6:	e4eb8b93          	addi	s7,s7,-434 # 2000 <digits>
    11ba:	03c9d793          	srli	a5,s3,0x3c
    11be:	97de                	add	a5,a5,s7
    11c0:	0007c583          	lbu	a1,0(a5)
    11c4:	855a                	mv	a0,s6
    11c6:	d89ff0ef          	jal	f4e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    11ca:	0992                	slli	s3,s3,0x4
    11cc:	34fd                	addiw	s1,s1,-1
    11ce:	f4f5                	bnez	s1,11ba <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
    11d0:	8be6                	mv	s7,s9
      state = 0;
    11d2:	4981                	li	s3,0
    11d4:	6ca2                	ld	s9,8(sp)
    11d6:	bda5                	j	104e <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
    11d8:	008b8493          	addi	s1,s7,8
    11dc:	000bc583          	lbu	a1,0(s7)
    11e0:	855a                	mv	a0,s6
    11e2:	d6dff0ef          	jal	f4e <putc>
    11e6:	8ba6                	mv	s7,s1
      state = 0;
    11e8:	4981                	li	s3,0
    11ea:	b595                	j	104e <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
    11ec:	008b8993          	addi	s3,s7,8
    11f0:	000bb483          	ld	s1,0(s7)
    11f4:	cc91                	beqz	s1,1210 <vprintf+0x206>
        for (; *s; s++)
    11f6:	0004c583          	lbu	a1,0(s1)
    11fa:	c985                	beqz	a1,122a <vprintf+0x220>
          putc(fd, *s);
    11fc:	855a                	mv	a0,s6
    11fe:	d51ff0ef          	jal	f4e <putc>
        for (; *s; s++)
    1202:	0485                	addi	s1,s1,1
    1204:	0004c583          	lbu	a1,0(s1)
    1208:	f9f5                	bnez	a1,11fc <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
    120a:	8bce                	mv	s7,s3
      state = 0;
    120c:	4981                	li	s3,0
    120e:	b581                	j	104e <vprintf+0x44>
          s = "(null)";
    1210:	00001497          	auipc	s1,0x1
    1214:	c5848493          	addi	s1,s1,-936 # 1e68 <malloc+0xabc>
        for (; *s; s++)
    1218:	02800593          	li	a1,40
    121c:	b7c5                	j	11fc <vprintf+0x1f2>
        putc(fd, '%');
    121e:	85be                	mv	a1,a5
    1220:	855a                	mv	a0,s6
    1222:	d2dff0ef          	jal	f4e <putc>
      state = 0;
    1226:	4981                	li	s3,0
    1228:	b51d                	j	104e <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
    122a:	8bce                	mv	s7,s3
      state = 0;
    122c:	4981                	li	s3,0
    122e:	b505                	j	104e <vprintf+0x44>
    1230:	6906                	ld	s2,64(sp)
    1232:	79e2                	ld	s3,56(sp)
    1234:	7a42                	ld	s4,48(sp)
    1236:	7aa2                	ld	s5,40(sp)
    1238:	7b02                	ld	s6,32(sp)
    123a:	6be2                	ld	s7,24(sp)
    123c:	6c42                	ld	s8,16(sp)
    }
  }
}
    123e:	60e6                	ld	ra,88(sp)
    1240:	6446                	ld	s0,80(sp)
    1242:	64a6                	ld	s1,72(sp)
    1244:	6125                	addi	sp,sp,96
    1246:	8082                	ret
      if (c0 == 'd') {
    1248:	06400713          	li	a4,100
    124c:	e4e78fe3          	beq	a5,a4,10aa <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
    1250:	f9478693          	addi	a3,a5,-108
    1254:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
    1258:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    125a:	4701                	li	a4,0
      } else if (c0 == 'u') {
    125c:	07500513          	li	a0,117
    1260:	e8a78ce3          	beq	a5,a0,10f8 <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
    1264:	f8b60513          	addi	a0,a2,-117
    1268:	e119                	bnez	a0,126e <vprintf+0x264>
    126a:	ea0693e3          	bnez	a3,1110 <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
    126e:	f8b58513          	addi	a0,a1,-117
    1272:	e119                	bnez	a0,1278 <vprintf+0x26e>
    1274:	ea071be3          	bnez	a4,112a <vprintf+0x120>
      } else if (c0 == 'x') {
    1278:	07800513          	li	a0,120
    127c:	eca784e3          	beq	a5,a0,1144 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
    1280:	f8860613          	addi	a2,a2,-120
    1284:	e219                	bnez	a2,128a <vprintf+0x280>
    1286:	ec069be3          	bnez	a3,115c <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
    128a:	f8858593          	addi	a1,a1,-120
    128e:	e199                	bnez	a1,1294 <vprintf+0x28a>
    1290:	ee0713e3          	bnez	a4,1176 <vprintf+0x16c>
      } else if (c0 == 'p') {
    1294:	07000713          	li	a4,112
    1298:	eee78ce3          	beq	a5,a4,1190 <vprintf+0x186>
      } else if (c0 == 'c') {
    129c:	06300713          	li	a4,99
    12a0:	f2e78ce3          	beq	a5,a4,11d8 <vprintf+0x1ce>
      } else if (c0 == 's') {
    12a4:	07300713          	li	a4,115
    12a8:	f4e782e3          	beq	a5,a4,11ec <vprintf+0x1e2>
      } else if (c0 == '%') {
    12ac:	02500713          	li	a4,37
    12b0:	f6e787e3          	beq	a5,a4,121e <vprintf+0x214>
        putc(fd, '%');
    12b4:	02500593          	li	a1,37
    12b8:	855a                	mv	a0,s6
    12ba:	c95ff0ef          	jal	f4e <putc>
        putc(fd, c0);
    12be:	85a6                	mv	a1,s1
    12c0:	855a                	mv	a0,s6
    12c2:	c8dff0ef          	jal	f4e <putc>
      state = 0;
    12c6:	4981                	li	s3,0
    12c8:	b359                	j	104e <vprintf+0x44>

00000000000012ca <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    12ca:	715d                	addi	sp,sp,-80
    12cc:	ec06                	sd	ra,24(sp)
    12ce:	e822                	sd	s0,16(sp)
    12d0:	1000                	addi	s0,sp,32
    12d2:	e010                	sd	a2,0(s0)
    12d4:	e414                	sd	a3,8(s0)
    12d6:	e818                	sd	a4,16(s0)
    12d8:	ec1c                	sd	a5,24(s0)
    12da:	03043023          	sd	a6,32(s0)
    12de:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    12e2:	8622                	mv	a2,s0
    12e4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    12e8:	d23ff0ef          	jal	100a <vprintf>
}
    12ec:	60e2                	ld	ra,24(sp)
    12ee:	6442                	ld	s0,16(sp)
    12f0:	6161                	addi	sp,sp,80
    12f2:	8082                	ret

00000000000012f4 <printf>:

void
printf(const char *fmt, ...)
{
    12f4:	711d                	addi	sp,sp,-96
    12f6:	ec06                	sd	ra,24(sp)
    12f8:	e822                	sd	s0,16(sp)
    12fa:	1000                	addi	s0,sp,32
    12fc:	e40c                	sd	a1,8(s0)
    12fe:	e810                	sd	a2,16(s0)
    1300:	ec14                	sd	a3,24(s0)
    1302:	f018                	sd	a4,32(s0)
    1304:	f41c                	sd	a5,40(s0)
    1306:	03043823          	sd	a6,48(s0)
    130a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    130e:	00840613          	addi	a2,s0,8
    1312:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1316:	85aa                	mv	a1,a0
    1318:	4505                	li	a0,1
    131a:	cf1ff0ef          	jal	100a <vprintf>
}
    131e:	60e2                	ld	ra,24(sp)
    1320:	6442                	ld	s0,16(sp)
    1322:	6125                	addi	sp,sp,96
    1324:	8082                	ret

0000000000001326 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1326:	1141                	addi	sp,sp,-16
    1328:	e406                	sd	ra,8(sp)
    132a:	e022                	sd	s0,0(sp)
    132c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
    132e:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1332:	00002797          	auipc	a5,0x2
    1336:	7ee7b783          	ld	a5,2030(a5) # 3b20 <freep>
    133a:	a039                	j	1348 <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    133c:	6398                	ld	a4,0(a5)
    133e:	00e7e463          	bltu	a5,a4,1346 <free+0x20>
    1342:	00e6ea63          	bltu	a3,a4,1356 <free+0x30>
{
    1346:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1348:	fed7fae3          	bgeu	a5,a3,133c <free+0x16>
    134c:	6398                	ld	a4,0(a5)
    134e:	00e6e463          	bltu	a3,a4,1356 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1352:	fee7eae3          	bltu	a5,a4,1346 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
    1356:	ff852583          	lw	a1,-8(a0)
    135a:	6390                	ld	a2,0(a5)
    135c:	02059813          	slli	a6,a1,0x20
    1360:	01c85713          	srli	a4,a6,0x1c
    1364:	9736                	add	a4,a4,a3
    1366:	02e60563          	beq	a2,a4,1390 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
    136a:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
    136e:	4790                	lw	a2,8(a5)
    1370:	02061593          	slli	a1,a2,0x20
    1374:	01c5d713          	srli	a4,a1,0x1c
    1378:	973e                	add	a4,a4,a5
    137a:	02e68263          	beq	a3,a4,139e <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
    137e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    1380:	00002717          	auipc	a4,0x2
    1384:	7af73023          	sd	a5,1952(a4) # 3b20 <freep>
}
    1388:	60a2                	ld	ra,8(sp)
    138a:	6402                	ld	s0,0(sp)
    138c:	0141                	addi	sp,sp,16
    138e:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
    1390:	4618                	lw	a4,8(a2)
    1392:	9f2d                	addw	a4,a4,a1
    1394:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1398:	6398                	ld	a4,0(a5)
    139a:	6310                	ld	a2,0(a4)
    139c:	b7f9                	j	136a <free+0x44>
    p->s.size += bp->s.size;
    139e:	ff852703          	lw	a4,-8(a0)
    13a2:	9f31                	addw	a4,a4,a2
    13a4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    13a6:	ff053683          	ld	a3,-16(a0)
    13aa:	bfd1                	j	137e <free+0x58>

00000000000013ac <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
    13ac:	7139                	addi	sp,sp,-64
    13ae:	fc06                	sd	ra,56(sp)
    13b0:	f822                	sd	s0,48(sp)
    13b2:	f04a                	sd	s2,32(sp)
    13b4:	ec4e                	sd	s3,24(sp)
    13b6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
    13b8:	02051993          	slli	s3,a0,0x20
    13bc:	0209d993          	srli	s3,s3,0x20
    13c0:	09bd                	addi	s3,s3,15
    13c2:	0049d993          	srli	s3,s3,0x4
    13c6:	2985                	addiw	s3,s3,1
    13c8:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
    13ca:	00002517          	auipc	a0,0x2
    13ce:	75653503          	ld	a0,1878(a0) # 3b20 <freep>
    13d2:	c905                	beqz	a0,1402 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
    13d4:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
    13d6:	4798                	lw	a4,8(a5)
    13d8:	09377663          	bgeu	a4,s3,1464 <malloc+0xb8>
    13dc:	f426                	sd	s1,40(sp)
    13de:	e852                	sd	s4,16(sp)
    13e0:	e456                	sd	s5,8(sp)
    13e2:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
    13e4:	8a4e                	mv	s4,s3
    13e6:	6705                	lui	a4,0x1
    13e8:	00e9f363          	bgeu	s3,a4,13ee <malloc+0x42>
    13ec:	6a05                	lui	s4,0x1
    13ee:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    13f2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
    13f6:	00002497          	auipc	s1,0x2
    13fa:	72a48493          	addi	s1,s1,1834 # 3b20 <freep>
  if (p == SBRK_ERROR)
    13fe:	5afd                	li	s5,-1
    1400:	a83d                	j	143e <malloc+0x92>
    1402:	f426                	sd	s1,40(sp)
    1404:	e852                	sd	s4,16(sp)
    1406:	e456                	sd	s5,8(sp)
    1408:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    140a:	00003797          	auipc	a5,0x3
    140e:	a1e78793          	addi	a5,a5,-1506 # 3e28 <base>
    1412:	00002717          	auipc	a4,0x2
    1416:	70f73723          	sd	a5,1806(a4) # 3b20 <freep>
    141a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    141c:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
    1420:	b7d1                	j	13e4 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
    1422:	6398                	ld	a4,0(a5)
    1424:	e118                	sd	a4,0(a0)
    1426:	a899                	j	147c <malloc+0xd0>
  hp->s.size = nu;
    1428:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
    142c:	0541                	addi	a0,a0,16
    142e:	ef9ff0ef          	jal	1326 <free>
  return freep;
    1432:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
    1434:	c125                	beqz	a0,1494 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
    1436:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
    1438:	4798                	lw	a4,8(a5)
    143a:	03277163          	bgeu	a4,s2,145c <malloc+0xb0>
    if (p == freep)
    143e:	6098                	ld	a4,0(s1)
    1440:	853e                	mv	a0,a5
    1442:	fef71ae3          	bne	a4,a5,1436 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
    1446:	8552                	mv	a0,s4
    1448:	a2bff0ef          	jal	e72 <sbrk>
  if (p == SBRK_ERROR)
    144c:	fd551ee3          	bne	a0,s5,1428 <malloc+0x7c>
        return 0;
    1450:	4501                	li	a0,0
    1452:	74a2                	ld	s1,40(sp)
    1454:	6a42                	ld	s4,16(sp)
    1456:	6aa2                	ld	s5,8(sp)
    1458:	6b02                	ld	s6,0(sp)
    145a:	a03d                	j	1488 <malloc+0xdc>
    145c:	74a2                	ld	s1,40(sp)
    145e:	6a42                	ld	s4,16(sp)
    1460:	6aa2                	ld	s5,8(sp)
    1462:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
    1464:	fae90fe3          	beq	s2,a4,1422 <malloc+0x76>
        p->s.size -= nunits;
    1468:	4137073b          	subw	a4,a4,s3
    146c:	c798                	sw	a4,8(a5)
        p += p->s.size;
    146e:	02071693          	slli	a3,a4,0x20
    1472:	01c6d713          	srli	a4,a3,0x1c
    1476:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1478:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    147c:	00002717          	auipc	a4,0x2
    1480:	6aa73223          	sd	a0,1700(a4) # 3b20 <freep>
      return (void *)(p + 1);
    1484:	01078513          	addi	a0,a5,16
  }
}
    1488:	70e2                	ld	ra,56(sp)
    148a:	7442                	ld	s0,48(sp)
    148c:	7902                	ld	s2,32(sp)
    148e:	69e2                	ld	s3,24(sp)
    1490:	6121                	addi	sp,sp,64
    1492:	8082                	ret
    1494:	74a2                	ld	s1,40(sp)
    1496:	6a42                	ld	s4,16(sp)
    1498:	6aa2                	ld	s5,8(sp)
    149a:	6b02                	ld	s6,0(sp)
    149c:	b7f5                	j	1488 <malloc+0xdc>
