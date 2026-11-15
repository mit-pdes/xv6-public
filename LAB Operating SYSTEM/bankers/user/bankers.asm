
user/_bankers:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <compute_need>:
};

int Available[M] = {3, 3, 2}; // Available instances of A, B, C
int Need[N][M];

void compute_need(void) {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  for (int i = 0; i < N; i++) {
   8:	00002797          	auipc	a5,0x2
   c:	ff878793          	addi	a5,a5,-8 # 2000 <Max>
  10:	00002697          	auipc	a3,0x2
  14:	03068693          	addi	a3,a3,48 # 2040 <Allocation>
  18:	00002717          	auipc	a4,0x2
  1c:	08870713          	addi	a4,a4,136 # 20a0 <Need>
  20:	00002517          	auipc	a0,0x2
  24:	01c50513          	addi	a0,a0,28 # 203c <Max+0x3c>
    for (int j = 0; j < M; j++) {
      Need[i][j] = Max[i][j] - Allocation[i][j];
  28:	4390                	lw	a2,0(a5)
  2a:	428c                	lw	a1,0(a3)
  2c:	9e0d                	subw	a2,a2,a1
  2e:	c310                	sw	a2,0(a4)
  30:	43d0                	lw	a2,4(a5)
  32:	42cc                	lw	a1,4(a3)
  34:	9e0d                	subw	a2,a2,a1
  36:	c350                	sw	a2,4(a4)
  38:	4790                	lw	a2,8(a5)
  3a:	468c                	lw	a1,8(a3)
  3c:	9e0d                	subw	a2,a2,a1
  3e:	c710                	sw	a2,8(a4)
  for (int i = 0; i < N; i++) {
  40:	07b1                	addi	a5,a5,12
  42:	06b1                	addi	a3,a3,12
  44:	0731                	addi	a4,a4,12
  46:	fea791e3          	bne	a5,a0,28 <compute_need+0x28>
    }
  }
}
  4a:	60a2                	ld	ra,8(sp)
  4c:	6402                	ld	s0,0(sp)
  4e:	0141                	addi	sp,sp,16
  50:	8082                	ret

0000000000000052 <print_system_state>:

void print_system_state(void) {
  52:	711d                	addi	sp,sp,-96
  54:	ec86                	sd	ra,88(sp)
  56:	e8a2                	sd	s0,80(sp)
  58:	e4a6                	sd	s1,72(sp)
  5a:	e0ca                	sd	s2,64(sp)
  5c:	fc4e                	sd	s3,56(sp)
  5e:	f852                	sd	s4,48(sp)
  60:	f456                	sd	s5,40(sp)
  62:	f05a                	sd	s6,32(sp)
  64:	1080                	addi	s0,sp,96
  printf("\n--- Current System State ---\n");
  66:	00001517          	auipc	a0,0x1
  6a:	d5a50513          	addi	a0,a0,-678 # dc0 <malloc+0xfa>
  6e:	3a1000ef          	jal	c0e <printf>
  printf("Process | Allocation |   Max      |   Need     \n");
  72:	00001517          	auipc	a0,0x1
  76:	d7650513          	addi	a0,a0,-650 # de8 <malloc+0x122>
  7a:	395000ef          	jal	c0e <printf>
  printf("        | A   B   C  | A   B   C  | A   B   C  \n");
  7e:	00001517          	auipc	a0,0x1
  82:	da250513          	addi	a0,a0,-606 # e20 <malloc+0x15a>
  86:	389000ef          	jal	c0e <printf>
  printf("-----------------------------------------------\n");
  8a:	00001517          	auipc	a0,0x1
  8e:	dce50513          	addi	a0,a0,-562 # e58 <malloc+0x192>
  92:	37d000ef          	jal	c0e <printf>
  for (int i = 0; i < N; i++) {
  96:	00002997          	auipc	s3,0x2
  9a:	faa98993          	addi	s3,s3,-86 # 2040 <Allocation>
  9e:	00002917          	auipc	s2,0x2
  a2:	f6290913          	addi	s2,s2,-158 # 2000 <Max>
  a6:	00002497          	auipc	s1,0x2
  aa:	ffa48493          	addi	s1,s1,-6 # 20a0 <Need>
  ae:	4a01                	li	s4,0
    printf("  P%d    | %d   %d   %d  | %d   %d   %d  | %d   %d   %d\n",
  b0:	00001b17          	auipc	s6,0x1
  b4:	de0b0b13          	addi	s6,s6,-544 # e90 <malloc+0x1ca>
  for (int i = 0; i < N; i++) {
  b8:	4a95                	li	s5,5
    printf("  P%d    | %d   %d   %d  | %d   %d   %d  | %d   %d   %d\n",
  ba:	449c                	lw	a5,8(s1)
  bc:	e83e                	sd	a5,16(sp)
  be:	40dc                	lw	a5,4(s1)
  c0:	e43e                	sd	a5,8(sp)
  c2:	409c                	lw	a5,0(s1)
  c4:	e03e                	sd	a5,0(sp)
  c6:	00892883          	lw	a7,8(s2)
  ca:	00492803          	lw	a6,4(s2)
  ce:	00092783          	lw	a5,0(s2)
  d2:	0089a703          	lw	a4,8(s3)
  d6:	0049a683          	lw	a3,4(s3)
  da:	0009a603          	lw	a2,0(s3)
  de:	85d2                	mv	a1,s4
  e0:	855a                	mv	a0,s6
  e2:	32d000ef          	jal	c0e <printf>
  for (int i = 0; i < N; i++) {
  e6:	2a05                	addiw	s4,s4,1
  e8:	09b1                	addi	s3,s3,12
  ea:	0931                	addi	s2,s2,12
  ec:	04b1                	addi	s1,s1,12
  ee:	fd5a16e3          	bne	s4,s5,ba <print_system_state+0x68>
           i,
           Allocation[i][0], Allocation[i][1], Allocation[i][2],
           Max[i][0], Max[i][1], Max[i][2],
           Need[i][0], Need[i][1], Need[i][2]);
  }
  printf("Available: A = %d, B = %d, C = %d\n\n",
  f2:	00002797          	auipc	a5,0x2
  f6:	f0e78793          	addi	a5,a5,-242 # 2000 <Max>
  fa:	0887a683          	lw	a3,136(a5)
  fe:	0847a603          	lw	a2,132(a5)
 102:	0807a583          	lw	a1,128(a5)
 106:	00001517          	auipc	a0,0x1
 10a:	dca50513          	addi	a0,a0,-566 # ed0 <malloc+0x20a>
 10e:	301000ef          	jal	c0e <printf>
         Available[0], Available[1], Available[2]);
}
 112:	60e6                	ld	ra,88(sp)
 114:	6446                	ld	s0,80(sp)
 116:	64a6                	ld	s1,72(sp)
 118:	6906                	ld	s2,64(sp)
 11a:	79e2                	ld	s3,56(sp)
 11c:	7a42                	ld	s4,48(sp)
 11e:	7aa2                	ld	s5,40(sp)
 120:	7b02                	ld	s6,32(sp)
 122:	6125                	addi	sp,sp,96
 124:	8082                	ret

0000000000000126 <is_safe>:

// Safety Algorithm
int is_safe(int safe_seq[N]) {
 126:	7179                	addi	sp,sp,-48
 128:	f406                	sd	ra,40(sp)
 12a:	f022                	sd	s0,32(sp)
 12c:	1800                	addi	s0,sp,48
 12e:	82aa                	mv	t0,a0
  int Work[M];
  int Finish[N];

  for (int j = 0; j < M; j++) {
    Work[j] = Available[j];
 130:	00002797          	auipc	a5,0x2
 134:	ed078793          	addi	a5,a5,-304 # 2000 <Max>
 138:	0807a883          	lw	a7,128(a5)
 13c:	0847ae03          	lw	t3,132(a5)
 140:	0887ae83          	lw	t4,136(a5)
  }
  for (int i = 0; i < N; i++) {
    Finish[i] = 0;
 144:	fc042c23          	sw	zero,-40(s0)
 148:	fc042e23          	sw	zero,-36(s0)
 14c:	fe042023          	sw	zero,-32(s0)
 150:	fe042223          	sw	zero,-28(s0)
 154:	fe042423          	sw	zero,-24(s0)
  }

  int count = 0;
 158:	4301                	li	t1,0
  while (count < N) {
    int found = 0;
    for (int i = 0; i < N; i++) {
 15a:	4815                	li	a6,5
        if (can_allocate) {
          for (int j = 0; j < M; j++) {
            Work[j] += Allocation[i][j];
          }
          safe_seq[count++] = i;
          Finish[i] = 1;
 15c:	4f85                	li	t6,1
  while (count < N) {
 15e:	4f11                	li	t5,4
 160:	a0b9                	j	1ae <is_safe+0x88>
    for (int i = 0; i < N; i++) {
 162:	2785                	addiw	a5,a5,1
 164:	0711                	addi	a4,a4,4
 166:	0631                	addi	a2,a2,12
 168:	06b1                	addi	a3,a3,12
 16a:	03078f63          	beq	a5,a6,1a8 <is_safe+0x82>
      if (Finish[i] == 0) {
 16e:	430c                	lw	a1,0(a4)
 170:	f9ed                	bnez	a1,162 <is_safe+0x3c>
          if (Need[i][j] > Work[j]) {
 172:	428c                	lw	a1,0(a3)
 174:	feb8c7e3          	blt	a7,a1,162 <is_safe+0x3c>
 178:	42cc                	lw	a1,4(a3)
 17a:	febe44e3          	blt	t3,a1,162 <is_safe+0x3c>
 17e:	468c                	lw	a1,8(a3)
 180:	febec1e3          	blt	t4,a1,162 <is_safe+0x3c>
            Work[j] += Allocation[i][j];
 184:	420c                	lw	a1,0(a2)
 186:	011588bb          	addw	a7,a1,a7
 18a:	424c                	lw	a1,4(a2)
 18c:	01c58e3b          	addw	t3,a1,t3
 190:	460c                	lw	a1,8(a2)
 192:	01d58ebb          	addw	t4,a1,t4
          safe_seq[count++] = i;
 196:	00231593          	slli	a1,t1,0x2
 19a:	9596                	add	a1,a1,t0
 19c:	c19c                	sw	a5,0(a1)
          Finish[i] = 1;
 19e:	01f72023          	sw	t6,0(a4)
          safe_seq[count++] = i;
 1a2:	2305                	addiw	t1,t1,1
          found = 1;
 1a4:	857e                	mv	a0,t6
 1a6:	bf75                	j	162 <is_safe+0x3c>
        }
      }
    }
    if (!found) {
 1a8:	c105                	beqz	a0,1c8 <is_safe+0xa2>
  while (count < N) {
 1aa:	006f4f63          	blt	t5,t1,1c8 <is_safe+0xa2>
    for (int i = 0; i < N; i++) {
 1ae:	fd840713          	addi	a4,s0,-40
 1b2:	00002617          	auipc	a2,0x2
 1b6:	e8e60613          	addi	a2,a2,-370 # 2040 <Allocation>
 1ba:	00002697          	auipc	a3,0x2
 1be:	ee668693          	addi	a3,a3,-282 # 20a0 <Need>
 1c2:	4781                	li	a5,0
    int found = 0;
 1c4:	4501                	li	a0,0
 1c6:	b765                	j	16e <is_safe+0x48>
      // No process could be safely satisfied
      return 0; // Unsafe state
    }
  }
  return 1; // Safe state
}
 1c8:	70a2                	ld	ra,40(sp)
 1ca:	7402                	ld	s0,32(sp)
 1cc:	6145                	addi	sp,sp,48
 1ce:	8082                	ret

00000000000001d0 <request_resources>:

// Resource Request Algorithm
int request_resources(int pid, int req[M]) {
 1d0:	711d                	addi	sp,sp,-96
 1d2:	ec86                	sd	ra,88(sp)
 1d4:	e8a2                	sd	s0,80(sp)
 1d6:	e4a6                	sd	s1,72(sp)
 1d8:	e0ca                	sd	s2,64(sp)
 1da:	1080                	addi	s0,sp,96
 1dc:	892a                	mv	s2,a0
 1de:	84ae                	mv	s1,a1
  printf(">>> Process P%d requests resources: [A=%d, B=%d, C=%d]\n",
 1e0:	4598                	lw	a4,8(a1)
 1e2:	41d4                	lw	a3,4(a1)
 1e4:	4190                	lw	a2,0(a1)
 1e6:	85aa                	mv	a1,a0
 1e8:	00001517          	auipc	a0,0x1
 1ec:	d1050513          	addi	a0,a0,-752 # ef8 <malloc+0x232>
 1f0:	21f000ef          	jal	c0e <printf>
         pid, req[0], req[1], req[2]);

  // Step 1: Check if Request <= Need
  for (int j = 0; j < M; j++) {
    if (req[j] > Need[pid][j]) {
 1f4:	4094                	lw	a3,0(s1)
 1f6:	00191793          	slli	a5,s2,0x1
 1fa:	97ca                	add	a5,a5,s2
 1fc:	078a                	slli	a5,a5,0x2
 1fe:	00002717          	auipc	a4,0x2
 202:	ea270713          	addi	a4,a4,-350 # 20a0 <Need>
 206:	97ba                	add	a5,a5,a4
 208:	439c                	lw	a5,0(a5)
 20a:	0ed7c663          	blt	a5,a3,2f6 <request_resources+0x126>
 20e:	40d0                	lw	a2,4(s1)
 210:	00191793          	slli	a5,s2,0x1
 214:	97ca                	add	a5,a5,s2
 216:	078a                	slli	a5,a5,0x2
 218:	97ba                	add	a5,a5,a4
 21a:	43dc                	lw	a5,4(a5)
 21c:	0cc7cd63          	blt	a5,a2,2f6 <request_resources+0x126>
 220:	448c                	lw	a1,8(s1)
 222:	00191793          	slli	a5,s2,0x1
 226:	97ca                	add	a5,a5,s2
 228:	078a                	slli	a5,a5,0x2
 22a:	97ba                	add	a5,a5,a4
 22c:	479c                	lw	a5,8(a5)
 22e:	0cb7c463          	blt	a5,a1,2f6 <request_resources+0x126>
    }
  }

  // Step 2: Check if Request <= Available
  for (int j = 0; j < M; j++) {
    if (req[j] > Available[j]) {
 232:	00002797          	auipc	a5,0x2
 236:	e4e7a783          	lw	a5,-434(a5) # 2080 <Available>
 23a:	0cd7c763          	blt	a5,a3,308 <request_resources+0x138>
 23e:	00002797          	auipc	a5,0x2
 242:	e467a783          	lw	a5,-442(a5) # 2084 <Available+0x4>
 246:	0cc7c163          	blt	a5,a2,308 <request_resources+0x138>
 24a:	00002797          	auipc	a5,0x2
 24e:	e3e7a783          	lw	a5,-450(a5) # 2088 <Available+0x8>
 252:	0ab7cb63          	blt	a5,a1,308 <request_resources+0x138>
 256:	fc4e                	sd	s3,56(sp)
 258:	f852                	sd	s4,48(sp)
 25a:	f456                	sd	s5,40(sp)
 25c:	f05a                	sd	s6,32(sp)
  for (int j = 0; j < M; j++) {
 25e:	00002a17          	auipc	s4,0x2
 262:	e22a0a13          	addi	s4,s4,-478 # 2080 <Available>
 266:	8b26                	mv	s6,s1
 268:	00191793          	slli	a5,s2,0x1
 26c:	97ca                	add	a5,a5,s2
 26e:	078a                	slli	a5,a5,0x2
 270:	00002917          	auipc	s2,0x2
 274:	dd090913          	addi	s2,s2,-560 # 2040 <Allocation>
 278:	993e                	add	s2,s2,a5
 27a:	00002717          	auipc	a4,0x2
 27e:	e2670713          	addi	a4,a4,-474 # 20a0 <Need>
 282:	00f70ab3          	add	s5,a4,a5
 286:	00c48993          	addi	s3,s1,12
    if (req[j] > Available[j]) {
 28a:	86d6                	mv	a3,s5
 28c:	874a                	mv	a4,s2
 28e:	85a6                	mv	a1,s1
 290:	87d2                	mv	a5,s4
    }
  }

  // Step 3: Simulate granting request
  for (int j = 0; j < M; j++) {
    Available[j] -= req[j];
 292:	4390                	lw	a2,0(a5)
 294:	4188                	lw	a0,0(a1)
 296:	9e09                	subw	a2,a2,a0
 298:	c390                	sw	a2,0(a5)
    Allocation[pid][j] += req[j];
 29a:	4308                	lw	a0,0(a4)
 29c:	4190                	lw	a2,0(a1)
 29e:	9e29                	addw	a2,a2,a0
 2a0:	c310                	sw	a2,0(a4)
    Need[pid][j] -= req[j];
 2a2:	4290                	lw	a2,0(a3)
 2a4:	4188                	lw	a0,0(a1)
 2a6:	9e09                	subw	a2,a2,a0
 2a8:	c290                	sw	a2,0(a3)
  for (int j = 0; j < M; j++) {
 2aa:	0791                	addi	a5,a5,4
 2ac:	0591                	addi	a1,a1,4
 2ae:	0711                	addi	a4,a4,4
 2b0:	0691                	addi	a3,a3,4
 2b2:	ff3590e3          	bne	a1,s3,292 <request_resources+0xc2>
  }

  // Step 4: Check if system remains safe
  int safe_seq[N];
  if (is_safe(safe_seq)) {
 2b6:	fa840513          	addi	a0,s0,-88
 2ba:	e6dff0ef          	jal	126 <is_safe>
 2be:	c15d                	beqz	a0,364 <request_resources+0x194>
    printf("SUCCESS: Request granted safely!\n");
 2c0:	00001517          	auipc	a0,0x1
 2c4:	d1050513          	addi	a0,a0,-752 # fd0 <malloc+0x30a>
 2c8:	147000ef          	jal	c0e <printf>
    printf("Safe sequence: <");
 2cc:	00001517          	auipc	a0,0x1
 2d0:	d2c50513          	addi	a0,a0,-724 # ff8 <malloc+0x332>
 2d4:	13b000ef          	jal	c0e <printf>
    for (int i = 0; i < N; i++) {
 2d8:	fa840493          	addi	s1,s0,-88
 2dc:	fb840913          	addi	s2,s0,-72
 2e0:	fbc40a93          	addi	s5,s0,-68
      printf("P%d%s", safe_seq[i], (i == N - 1) ? ">\n" : ", ");
 2e4:	00001a17          	auipc	s4,0x1
 2e8:	d2ca0a13          	addi	s4,s4,-724 # 1010 <malloc+0x34a>
 2ec:	00001997          	auipc	s3,0x1
 2f0:	d2c98993          	addi	s3,s3,-724 # 1018 <malloc+0x352>
 2f4:	a815                	j	328 <request_resources+0x158>
      printf("ERROR: Process P%d has exceeded its maximum claim (Request > Need)!\n", pid);
 2f6:	85ca                	mv	a1,s2
 2f8:	00001517          	auipc	a0,0x1
 2fc:	c3850513          	addi	a0,a0,-968 # f30 <malloc+0x26a>
 300:	10f000ef          	jal	c0e <printf>
      return -1;
 304:	557d                	li	a0,-1
 306:	a099                	j	34c <request_resources+0x17c>
      printf("Notice: Process P%d must wait. Not enough resources available (Request > Available).\n", pid);
 308:	85ca                	mv	a1,s2
 30a:	00001517          	auipc	a0,0x1
 30e:	c6e50513          	addi	a0,a0,-914 # f78 <malloc+0x2b2>
 312:	0fd000ef          	jal	c0e <printf>
      return -2;
 316:	5579                	li	a0,-2
 318:	a815                	j	34c <request_resources+0x17c>
      printf("P%d%s", safe_seq[i], (i == N - 1) ? ">\n" : ", ");
 31a:	8652                	mv	a2,s4
 31c:	854e                	mv	a0,s3
 31e:	0f1000ef          	jal	c0e <printf>
    for (int i = 0; i < N; i++) {
 322:	0491                	addi	s1,s1,4
 324:	03548a63          	beq	s1,s5,358 <request_resources+0x188>
      printf("P%d%s", safe_seq[i], (i == N - 1) ? ">\n" : ", ");
 328:	408c                	lw	a1,0(s1)
 32a:	ff2498e3          	bne	s1,s2,31a <request_resources+0x14a>
 32e:	00001617          	auipc	a2,0x1
 332:	d3a60613          	addi	a2,a2,-710 # 1068 <malloc+0x3a2>
 336:	00001517          	auipc	a0,0x1
 33a:	ce250513          	addi	a0,a0,-798 # 1018 <malloc+0x352>
 33e:	0d1000ef          	jal	c0e <printf>
    }
    return 0; // Committed
 342:	4501                	li	a0,0
 344:	79e2                	ld	s3,56(sp)
 346:	7a42                	ld	s4,48(sp)
 348:	7aa2                	ld	s5,40(sp)
 34a:	7b02                	ld	s6,32(sp)
      Need[pid][j] += req[j];
    }
    printf("DENIED: Request denied — would lead to unsafe state! Rolled back.\n");
    return -3;
  }
}
 34c:	60e6                	ld	ra,88(sp)
 34e:	6446                	ld	s0,80(sp)
 350:	64a6                	ld	s1,72(sp)
 352:	6906                	ld	s2,64(sp)
 354:	6125                	addi	sp,sp,96
 356:	8082                	ret
    return 0; // Committed
 358:	4501                	li	a0,0
 35a:	79e2                	ld	s3,56(sp)
 35c:	7a42                	ld	s4,48(sp)
 35e:	7aa2                	ld	s5,40(sp)
 360:	7b02                	ld	s6,32(sp)
 362:	b7ed                	j	34c <request_resources+0x17c>
      Available[j] += req[j];
 364:	000a2703          	lw	a4,0(s4)
 368:	000b2783          	lw	a5,0(s6)
 36c:	9fb9                	addw	a5,a5,a4
 36e:	00fa2023          	sw	a5,0(s4)
      Allocation[pid][j] -= req[j];
 372:	00092783          	lw	a5,0(s2)
 376:	000b2703          	lw	a4,0(s6)
 37a:	9f99                	subw	a5,a5,a4
 37c:	00f92023          	sw	a5,0(s2)
      Need[pid][j] += req[j];
 380:	000aa703          	lw	a4,0(s5)
 384:	000b2783          	lw	a5,0(s6)
 388:	9fb9                	addw	a5,a5,a4
 38a:	00faa023          	sw	a5,0(s5)
    for (int j = 0; j < M; j++) {
 38e:	0a11                	addi	s4,s4,4
 390:	004b0793          	addi	a5,s6,4
 394:	8b3e                	mv	s6,a5
 396:	0911                	addi	s2,s2,4
 398:	0a91                	addi	s5,s5,4
 39a:	fd3795e3          	bne	a5,s3,364 <request_resources+0x194>
    printf("DENIED: Request denied — would lead to unsafe state! Rolled back.\n");
 39e:	00001517          	auipc	a0,0x1
 3a2:	c8250513          	addi	a0,a0,-894 # 1020 <malloc+0x35a>
 3a6:	069000ef          	jal	c0e <printf>
    return -3;
 3aa:	5575                	li	a0,-3
 3ac:	79e2                	ld	s3,56(sp)
 3ae:	7a42                	ld	s4,48(sp)
 3b0:	7aa2                	ld	s5,40(sp)
 3b2:	7b02                	ld	s6,32(sp)
 3b4:	bf61                	j	34c <request_resources+0x17c>

00000000000003b6 <main>:

int main(int argc, char *argv[]) {
 3b6:	7175                	addi	sp,sp,-144
 3b8:	e506                	sd	ra,136(sp)
 3ba:	e122                	sd	s0,128(sp)
 3bc:	fca6                	sd	s1,120(sp)
 3be:	f8ca                	sd	s2,112(sp)
 3c0:	f4ce                	sd	s3,104(sp)
 3c2:	f0d2                	sd	s4,96(sp)
 3c4:	ecd6                	sd	s5,88(sp)
 3c6:	0900                	addi	s0,sp,144
  printf("============================================================\n");
 3c8:	00001517          	auipc	a0,0x1
 3cc:	ca850513          	addi	a0,a0,-856 # 1070 <malloc+0x3aa>
 3d0:	03f000ef          	jal	c0e <printf>
  printf("      Banker's Algorithm Simulation for Deadlock Avoidance  \n");
 3d4:	00001517          	auipc	a0,0x1
 3d8:	cdc50513          	addi	a0,a0,-804 # 10b0 <malloc+0x3ea>
 3dc:	033000ef          	jal	c0e <printf>
  printf("============================================================\n");
 3e0:	00001517          	auipc	a0,0x1
 3e4:	c9050513          	addi	a0,a0,-880 # 1070 <malloc+0x3aa>
 3e8:	027000ef          	jal	c0e <printf>

  compute_need();
 3ec:	c15ff0ef          	jal	0 <compute_need>
  print_system_state();
 3f0:	c63ff0ef          	jal	52 <print_system_state>

  // Test Case 1: Initial Safety Check
  printf("[Test Case 1] Checking initial system safety...\n");
 3f4:	00001517          	auipc	a0,0x1
 3f8:	cfc50513          	addi	a0,a0,-772 # 10f0 <malloc+0x42a>
 3fc:	013000ef          	jal	c0e <printf>
  int safe_seq[N];
  if (is_safe(safe_seq)) {
 400:	fa840513          	addi	a0,s0,-88
 404:	d23ff0ef          	jal	126 <is_safe>
 408:	0e050a63          	beqz	a0,4fc <main+0x146>
    printf("System is in a SAFE state.\nSafe execution sequence: <");
 40c:	00001517          	auipc	a0,0x1
 410:	d1c50513          	addi	a0,a0,-740 # 1128 <malloc+0x462>
 414:	7fa000ef          	jal	c0e <printf>
    for (int i = 0; i < N; i++) {
 418:	fa840493          	addi	s1,s0,-88
 41c:	fb840913          	addi	s2,s0,-72
 420:	fbc40a93          	addi	s5,s0,-68
      printf("P%d%s", safe_seq[i], (i == N - 1) ? ">\n" : ", ");
 424:	00001a17          	auipc	s4,0x1
 428:	beca0a13          	addi	s4,s4,-1044 # 1010 <malloc+0x34a>
 42c:	00001997          	auipc	s3,0x1
 430:	bec98993          	addi	s3,s3,-1044 # 1018 <malloc+0x352>
 434:	a801                	j	444 <main+0x8e>
 436:	8652                	mv	a2,s4
 438:	854e                	mv	a0,s3
 43a:	7d4000ef          	jal	c0e <printf>
    for (int i = 0; i < N; i++) {
 43e:	0491                	addi	s1,s1,4
 440:	01548f63          	beq	s1,s5,45e <main+0xa8>
      printf("P%d%s", safe_seq[i], (i == N - 1) ? ">\n" : ", ");
 444:	408c                	lw	a1,0(s1)
 446:	ff2498e3          	bne	s1,s2,436 <main+0x80>
 44a:	00001617          	auipc	a2,0x1
 44e:	c1e60613          	addi	a2,a2,-994 # 1068 <malloc+0x3a2>
 452:	00001517          	auipc	a0,0x1
 456:	bc650513          	addi	a0,a0,-1082 # 1018 <malloc+0x352>
 45a:	7b4000ef          	jal	c0e <printf>
  } else {
    printf("System is in an UNSAFE state!\n");
  }

  // Test Case 2: Process 1 requests [1, 0, 2] (Should be GRANTED)
  printf("\n[Test Case 2] Process P1 requesting [1, 0, 2]...\n");
 45e:	00001517          	auipc	a0,0x1
 462:	d2250513          	addi	a0,a0,-734 # 1180 <malloc+0x4ba>
 466:	7a8000ef          	jal	c0e <printf>
  int req1[M] = {1, 0, 2};
 46a:	4785                	li	a5,1
 46c:	f8f42c23          	sw	a5,-104(s0)
 470:	f8042e23          	sw	zero,-100(s0)
 474:	4489                	li	s1,2
 476:	fa942023          	sw	s1,-96(s0)
  request_resources(1, req1);
 47a:	f9840593          	addi	a1,s0,-104
 47e:	853e                	mv	a0,a5
 480:	d51ff0ef          	jal	1d0 <request_resources>
  print_system_state();
 484:	bcfff0ef          	jal	52 <print_system_state>

  // Test Case 3: Process 4 requests [3, 3, 0] (Exceeds Available)
  printf("\n[Test Case 3] Process P4 requesting [3, 3, 0]...\n");
 488:	00001517          	auipc	a0,0x1
 48c:	d3050513          	addi	a0,a0,-720 # 11b8 <malloc+0x4f2>
 490:	77e000ef          	jal	c0e <printf>
  int req2[M] = {3, 3, 0};
 494:	478d                	li	a5,3
 496:	f8f42423          	sw	a5,-120(s0)
 49a:	f8f42623          	sw	a5,-116(s0)
 49e:	f8042823          	sw	zero,-112(s0)
  request_resources(4, req2);
 4a2:	f8840593          	addi	a1,s0,-120
 4a6:	4511                	li	a0,4
 4a8:	d29ff0ef          	jal	1d0 <request_resources>

  // Test Case 4: Process P0 requests [0, 2, 0] (Unsafe state -> DENIED)
  printf("\n[Test Case 4] Process P0 requesting [0, 2, 0]...\n");
 4ac:	00001517          	auipc	a0,0x1
 4b0:	d4450513          	addi	a0,a0,-700 # 11f0 <malloc+0x52a>
 4b4:	75a000ef          	jal	c0e <printf>
  int req3[M] = {0, 2, 0};
 4b8:	f6042c23          	sw	zero,-136(s0)
 4bc:	f6942e23          	sw	s1,-132(s0)
 4c0:	f8042023          	sw	zero,-128(s0)
  request_resources(0, req3);
 4c4:	f7840593          	addi	a1,s0,-136
 4c8:	4501                	li	a0,0
 4ca:	d07ff0ef          	jal	1d0 <request_resources>
  print_system_state();
 4ce:	b85ff0ef          	jal	52 <print_system_state>

  printf("============================================================\n");
 4d2:	00001517          	auipc	a0,0x1
 4d6:	b9e50513          	addi	a0,a0,-1122 # 1070 <malloc+0x3aa>
 4da:	734000ef          	jal	c0e <printf>
  printf("Banker's Algorithm simulation completed successfully.\n");
 4de:	00001517          	auipc	a0,0x1
 4e2:	d4a50513          	addi	a0,a0,-694 # 1228 <malloc+0x562>
 4e6:	728000ef          	jal	c0e <printf>
  printf("============================================================\n");
 4ea:	00001517          	auipc	a0,0x1
 4ee:	b8650513          	addi	a0,a0,-1146 # 1070 <malloc+0x3aa>
 4f2:	71c000ef          	jal	c0e <printf>

  exit(0);
 4f6:	4501                	li	a0,0
 4f8:	2c8000ef          	jal	7c0 <exit>
    printf("System is in an UNSAFE state!\n");
 4fc:	00001517          	auipc	a0,0x1
 500:	c6450513          	addi	a0,a0,-924 # 1160 <malloc+0x49a>
 504:	70a000ef          	jal	c0e <printf>
 508:	bf99                	j	45e <main+0xa8>

000000000000050a <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 50a:	1141                	addi	sp,sp,-16
 50c:	e406                	sd	ra,8(sp)
 50e:	e022                	sd	s0,0(sp)
 510:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 512:	ea5ff0ef          	jal	3b6 <main>
  exit(r);
 516:	2aa000ef          	jal	7c0 <exit>

000000000000051a <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 51a:	1141                	addi	sp,sp,-16
 51c:	e406                	sd	ra,8(sp)
 51e:	e022                	sd	s0,0(sp)
 520:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 522:	87aa                	mv	a5,a0
 524:	0585                	addi	a1,a1,1
 526:	0785                	addi	a5,a5,1
 528:	fff5c703          	lbu	a4,-1(a1)
 52c:	fee78fa3          	sb	a4,-1(a5)
 530:	fb75                	bnez	a4,524 <strcpy+0xa>
    ;
  return os;
}
 532:	60a2                	ld	ra,8(sp)
 534:	6402                	ld	s0,0(sp)
 536:	0141                	addi	sp,sp,16
 538:	8082                	ret

000000000000053a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 53a:	1141                	addi	sp,sp,-16
 53c:	e406                	sd	ra,8(sp)
 53e:	e022                	sd	s0,0(sp)
 540:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 542:	00054783          	lbu	a5,0(a0)
 546:	cb91                	beqz	a5,55a <strcmp+0x20>
 548:	0005c703          	lbu	a4,0(a1)
 54c:	00f71763          	bne	a4,a5,55a <strcmp+0x20>
    p++, q++;
 550:	0505                	addi	a0,a0,1
 552:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 554:	00054783          	lbu	a5,0(a0)
 558:	fbe5                	bnez	a5,548 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 55a:	0005c503          	lbu	a0,0(a1)
}
 55e:	40a7853b          	subw	a0,a5,a0
 562:	60a2                	ld	ra,8(sp)
 564:	6402                	ld	s0,0(sp)
 566:	0141                	addi	sp,sp,16
 568:	8082                	ret

000000000000056a <strlen>:

uint
strlen(const char *s)
{
 56a:	1141                	addi	sp,sp,-16
 56c:	e406                	sd	ra,8(sp)
 56e:	e022                	sd	s0,0(sp)
 570:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 572:	00054783          	lbu	a5,0(a0)
 576:	cf91                	beqz	a5,592 <strlen+0x28>
 578:	00150793          	addi	a5,a0,1
 57c:	86be                	mv	a3,a5
 57e:	0785                	addi	a5,a5,1
 580:	fff7c703          	lbu	a4,-1(a5)
 584:	ff65                	bnez	a4,57c <strlen+0x12>
 586:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 58a:	60a2                	ld	ra,8(sp)
 58c:	6402                	ld	s0,0(sp)
 58e:	0141                	addi	sp,sp,16
 590:	8082                	ret
  for (n = 0; s[n]; n++)
 592:	4501                	li	a0,0
 594:	bfdd                	j	58a <strlen+0x20>

0000000000000596 <memset>:

void *
memset(void *dst, int c, uint n)
{
 596:	1141                	addi	sp,sp,-16
 598:	e406                	sd	ra,8(sp)
 59a:	e022                	sd	s0,0(sp)
 59c:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 59e:	ca19                	beqz	a2,5b4 <memset+0x1e>
 5a0:	87aa                	mv	a5,a0
 5a2:	1602                	slli	a2,a2,0x20
 5a4:	9201                	srli	a2,a2,0x20
 5a6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 5aa:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 5ae:	0785                	addi	a5,a5,1
 5b0:	fee79de3          	bne	a5,a4,5aa <memset+0x14>
  }
  return dst;
}
 5b4:	60a2                	ld	ra,8(sp)
 5b6:	6402                	ld	s0,0(sp)
 5b8:	0141                	addi	sp,sp,16
 5ba:	8082                	ret

00000000000005bc <strchr>:

char *
strchr(const char *s, char c)
{
 5bc:	1141                	addi	sp,sp,-16
 5be:	e406                	sd	ra,8(sp)
 5c0:	e022                	sd	s0,0(sp)
 5c2:	0800                	addi	s0,sp,16
  for (; *s; s++)
 5c4:	00054783          	lbu	a5,0(a0)
 5c8:	cf81                	beqz	a5,5e0 <strchr+0x24>
    if (*s == c)
 5ca:	00f58763          	beq	a1,a5,5d8 <strchr+0x1c>
  for (; *s; s++)
 5ce:	0505                	addi	a0,a0,1
 5d0:	00054783          	lbu	a5,0(a0)
 5d4:	fbfd                	bnez	a5,5ca <strchr+0xe>
      return (char *)s;
  return 0;
 5d6:	4501                	li	a0,0
}
 5d8:	60a2                	ld	ra,8(sp)
 5da:	6402                	ld	s0,0(sp)
 5dc:	0141                	addi	sp,sp,16
 5de:	8082                	ret
  return 0;
 5e0:	4501                	li	a0,0
 5e2:	bfdd                	j	5d8 <strchr+0x1c>

00000000000005e4 <gets>:

char *
gets(char *buf, int max)
{
 5e4:	711d                	addi	sp,sp,-96
 5e6:	ec86                	sd	ra,88(sp)
 5e8:	e8a2                	sd	s0,80(sp)
 5ea:	e4a6                	sd	s1,72(sp)
 5ec:	e0ca                	sd	s2,64(sp)
 5ee:	fc4e                	sd	s3,56(sp)
 5f0:	f852                	sd	s4,48(sp)
 5f2:	f456                	sd	s5,40(sp)
 5f4:	f05a                	sd	s6,32(sp)
 5f6:	ec5e                	sd	s7,24(sp)
 5f8:	e862                	sd	s8,16(sp)
 5fa:	1080                	addi	s0,sp,96
 5fc:	8baa                	mv	s7,a0
 5fe:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 600:	892a                	mv	s2,a0
 602:	4481                	li	s1,0
    cc = read(0, &c, 1);
 604:	faf40b13          	addi	s6,s0,-81
 608:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 60a:	8c26                	mv	s8,s1
 60c:	0014899b          	addiw	s3,s1,1
 610:	84ce                	mv	s1,s3
 612:	0349d463          	bge	s3,s4,63a <gets+0x56>
    cc = read(0, &c, 1);
 616:	8656                	mv	a2,s5
 618:	85da                	mv	a1,s6
 61a:	4501                	li	a0,0
 61c:	1bc000ef          	jal	7d8 <read>
    if (cc < 1)
 620:	00a05d63          	blez	a0,63a <gets+0x56>
      break;
    buf[i++] = c;
 624:	faf44783          	lbu	a5,-81(s0)
 628:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 62c:	0905                	addi	s2,s2,1
 62e:	ff678713          	addi	a4,a5,-10
 632:	c319                	beqz	a4,638 <gets+0x54>
 634:	17cd                	addi	a5,a5,-13
 636:	fbf1                	bnez	a5,60a <gets+0x26>
    buf[i++] = c;
 638:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 63a:	9c5e                	add	s8,s8,s7
 63c:	000c0023          	sb	zero,0(s8)
  return buf;
}
 640:	855e                	mv	a0,s7
 642:	60e6                	ld	ra,88(sp)
 644:	6446                	ld	s0,80(sp)
 646:	64a6                	ld	s1,72(sp)
 648:	6906                	ld	s2,64(sp)
 64a:	79e2                	ld	s3,56(sp)
 64c:	7a42                	ld	s4,48(sp)
 64e:	7aa2                	ld	s5,40(sp)
 650:	7b02                	ld	s6,32(sp)
 652:	6be2                	ld	s7,24(sp)
 654:	6c42                	ld	s8,16(sp)
 656:	6125                	addi	sp,sp,96
 658:	8082                	ret

000000000000065a <stat>:

int
stat(const char *n, struct stat *st)
{
 65a:	1101                	addi	sp,sp,-32
 65c:	ec06                	sd	ra,24(sp)
 65e:	e822                	sd	s0,16(sp)
 660:	e04a                	sd	s2,0(sp)
 662:	1000                	addi	s0,sp,32
 664:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 666:	4581                	li	a1,0
 668:	198000ef          	jal	800 <open>
  if (fd < 0)
 66c:	02054263          	bltz	a0,690 <stat+0x36>
 670:	e426                	sd	s1,8(sp)
 672:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 674:	85ca                	mv	a1,s2
 676:	1a2000ef          	jal	818 <fstat>
 67a:	892a                	mv	s2,a0
  close(fd);
 67c:	8526                	mv	a0,s1
 67e:	16a000ef          	jal	7e8 <close>
  return r;
 682:	64a2                	ld	s1,8(sp)
}
 684:	854a                	mv	a0,s2
 686:	60e2                	ld	ra,24(sp)
 688:	6442                	ld	s0,16(sp)
 68a:	6902                	ld	s2,0(sp)
 68c:	6105                	addi	sp,sp,32
 68e:	8082                	ret
    return -1;
 690:	57fd                	li	a5,-1
 692:	893e                	mv	s2,a5
 694:	bfc5                	j	684 <stat+0x2a>

0000000000000696 <atoi>:

int
atoi(const char *s)
{
 696:	1141                	addi	sp,sp,-16
 698:	e406                	sd	ra,8(sp)
 69a:	e022                	sd	s0,0(sp)
 69c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 69e:	00054683          	lbu	a3,0(a0)
 6a2:	fd06879b          	addiw	a5,a3,-48
 6a6:	0ff7f793          	zext.b	a5,a5
 6aa:	4625                	li	a2,9
 6ac:	02f66963          	bltu	a2,a5,6de <atoi+0x48>
 6b0:	872a                	mv	a4,a0
  n = 0;
 6b2:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 6b4:	0705                	addi	a4,a4,1
 6b6:	0025179b          	slliw	a5,a0,0x2
 6ba:	9fa9                	addw	a5,a5,a0
 6bc:	0017979b          	slliw	a5,a5,0x1
 6c0:	9fb5                	addw	a5,a5,a3
 6c2:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 6c6:	00074683          	lbu	a3,0(a4)
 6ca:	fd06879b          	addiw	a5,a3,-48
 6ce:	0ff7f793          	zext.b	a5,a5
 6d2:	fef671e3          	bgeu	a2,a5,6b4 <atoi+0x1e>
  return n;
}
 6d6:	60a2                	ld	ra,8(sp)
 6d8:	6402                	ld	s0,0(sp)
 6da:	0141                	addi	sp,sp,16
 6dc:	8082                	ret
  n = 0;
 6de:	4501                	li	a0,0
 6e0:	bfdd                	j	6d6 <atoi+0x40>

00000000000006e2 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 6e2:	1141                	addi	sp,sp,-16
 6e4:	e406                	sd	ra,8(sp)
 6e6:	e022                	sd	s0,0(sp)
 6e8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 6ea:	02b57563          	bgeu	a0,a1,714 <memmove+0x32>
    while (n-- > 0)
 6ee:	00c05f63          	blez	a2,70c <memmove+0x2a>
 6f2:	1602                	slli	a2,a2,0x20
 6f4:	9201                	srli	a2,a2,0x20
 6f6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 6fa:	872a                	mv	a4,a0
      *dst++ = *src++;
 6fc:	0585                	addi	a1,a1,1
 6fe:	0705                	addi	a4,a4,1
 700:	fff5c683          	lbu	a3,-1(a1)
 704:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 708:	fee79ae3          	bne	a5,a4,6fc <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 70c:	60a2                	ld	ra,8(sp)
 70e:	6402                	ld	s0,0(sp)
 710:	0141                	addi	sp,sp,16
 712:	8082                	ret
    while (n-- > 0)
 714:	fec05ce3          	blez	a2,70c <memmove+0x2a>
    dst += n;
 718:	00c50733          	add	a4,a0,a2
    src += n;
 71c:	95b2                	add	a1,a1,a2
 71e:	fff6079b          	addiw	a5,a2,-1
 722:	1782                	slli	a5,a5,0x20
 724:	9381                	srli	a5,a5,0x20
 726:	fff7c793          	not	a5,a5
 72a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 72c:	15fd                	addi	a1,a1,-1
 72e:	177d                	addi	a4,a4,-1
 730:	0005c683          	lbu	a3,0(a1)
 734:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 738:	fef71ae3          	bne	a4,a5,72c <memmove+0x4a>
 73c:	bfc1                	j	70c <memmove+0x2a>

000000000000073e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 73e:	1141                	addi	sp,sp,-16
 740:	e406                	sd	ra,8(sp)
 742:	e022                	sd	s0,0(sp)
 744:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 746:	c61d                	beqz	a2,774 <memcmp+0x36>
 748:	1602                	slli	a2,a2,0x20
 74a:	9201                	srli	a2,a2,0x20
 74c:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 750:	00054783          	lbu	a5,0(a0)
 754:	0005c703          	lbu	a4,0(a1)
 758:	00e79863          	bne	a5,a4,768 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 75c:	0505                	addi	a0,a0,1
    p2++;
 75e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 760:	fed518e3          	bne	a0,a3,750 <memcmp+0x12>
  }
  return 0;
 764:	4501                	li	a0,0
 766:	a019                	j	76c <memcmp+0x2e>
      return *p1 - *p2;
 768:	40e7853b          	subw	a0,a5,a4
}
 76c:	60a2                	ld	ra,8(sp)
 76e:	6402                	ld	s0,0(sp)
 770:	0141                	addi	sp,sp,16
 772:	8082                	ret
  return 0;
 774:	4501                	li	a0,0
 776:	bfdd                	j	76c <memcmp+0x2e>

0000000000000778 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 778:	1141                	addi	sp,sp,-16
 77a:	e406                	sd	ra,8(sp)
 77c:	e022                	sd	s0,0(sp)
 77e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 780:	f63ff0ef          	jal	6e2 <memmove>
}
 784:	60a2                	ld	ra,8(sp)
 786:	6402                	ld	s0,0(sp)
 788:	0141                	addi	sp,sp,16
 78a:	8082                	ret

000000000000078c <sbrk>:

char *
sbrk(int n)
{
 78c:	1141                	addi	sp,sp,-16
 78e:	e406                	sd	ra,8(sp)
 790:	e022                	sd	s0,0(sp)
 792:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 794:	4585                	li	a1,1
 796:	0b2000ef          	jal	848 <sys_sbrk>
}
 79a:	60a2                	ld	ra,8(sp)
 79c:	6402                	ld	s0,0(sp)
 79e:	0141                	addi	sp,sp,16
 7a0:	8082                	ret

00000000000007a2 <sbrklazy>:

char *
sbrklazy(int n)
{
 7a2:	1141                	addi	sp,sp,-16
 7a4:	e406                	sd	ra,8(sp)
 7a6:	e022                	sd	s0,0(sp)
 7a8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 7aa:	4589                	li	a1,2
 7ac:	09c000ef          	jal	848 <sys_sbrk>
}
 7b0:	60a2                	ld	ra,8(sp)
 7b2:	6402                	ld	s0,0(sp)
 7b4:	0141                	addi	sp,sp,16
 7b6:	8082                	ret

00000000000007b8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 7b8:	4885                	li	a7,1
 ecall
 7ba:	00000073          	ecall
 ret
 7be:	8082                	ret

00000000000007c0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 7c0:	4889                	li	a7,2
 ecall
 7c2:	00000073          	ecall
 ret
 7c6:	8082                	ret

00000000000007c8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 7c8:	488d                	li	a7,3
 ecall
 7ca:	00000073          	ecall
 ret
 7ce:	8082                	ret

00000000000007d0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 7d0:	4891                	li	a7,4
 ecall
 7d2:	00000073          	ecall
 ret
 7d6:	8082                	ret

00000000000007d8 <read>:
.global read
read:
 li a7, SYS_read
 7d8:	4895                	li	a7,5
 ecall
 7da:	00000073          	ecall
 ret
 7de:	8082                	ret

00000000000007e0 <write>:
.global write
write:
 li a7, SYS_write
 7e0:	48c1                	li	a7,16
 ecall
 7e2:	00000073          	ecall
 ret
 7e6:	8082                	ret

00000000000007e8 <close>:
.global close
close:
 li a7, SYS_close
 7e8:	48d5                	li	a7,21
 ecall
 7ea:	00000073          	ecall
 ret
 7ee:	8082                	ret

00000000000007f0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 7f0:	4899                	li	a7,6
 ecall
 7f2:	00000073          	ecall
 ret
 7f6:	8082                	ret

00000000000007f8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 7f8:	489d                	li	a7,7
 ecall
 7fa:	00000073          	ecall
 ret
 7fe:	8082                	ret

0000000000000800 <open>:
.global open
open:
 li a7, SYS_open
 800:	48bd                	li	a7,15
 ecall
 802:	00000073          	ecall
 ret
 806:	8082                	ret

0000000000000808 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 808:	48c5                	li	a7,17
 ecall
 80a:	00000073          	ecall
 ret
 80e:	8082                	ret

0000000000000810 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 810:	48c9                	li	a7,18
 ecall
 812:	00000073          	ecall
 ret
 816:	8082                	ret

0000000000000818 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 818:	48a1                	li	a7,8
 ecall
 81a:	00000073          	ecall
 ret
 81e:	8082                	ret

0000000000000820 <link>:
.global link
link:
 li a7, SYS_link
 820:	48cd                	li	a7,19
 ecall
 822:	00000073          	ecall
 ret
 826:	8082                	ret

0000000000000828 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 828:	48d1                	li	a7,20
 ecall
 82a:	00000073          	ecall
 ret
 82e:	8082                	ret

0000000000000830 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 830:	48a5                	li	a7,9
 ecall
 832:	00000073          	ecall
 ret
 836:	8082                	ret

0000000000000838 <dup>:
.global dup
dup:
 li a7, SYS_dup
 838:	48a9                	li	a7,10
 ecall
 83a:	00000073          	ecall
 ret
 83e:	8082                	ret

0000000000000840 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 840:	48ad                	li	a7,11
 ecall
 842:	00000073          	ecall
 ret
 846:	8082                	ret

0000000000000848 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 848:	48b1                	li	a7,12
 ecall
 84a:	00000073          	ecall
 ret
 84e:	8082                	ret

0000000000000850 <pause>:
.global pause
pause:
 li a7, SYS_pause
 850:	48b5                	li	a7,13
 ecall
 852:	00000073          	ecall
 ret
 856:	8082                	ret

0000000000000858 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 858:	48b9                	li	a7,14
 ecall
 85a:	00000073          	ecall
 ret
 85e:	8082                	ret

0000000000000860 <sync>:
.global sync
sync:
 li a7, SYS_sync
 860:	48d9                	li	a7,22
 ecall
 862:	00000073          	ecall
 ret
 866:	8082                	ret

0000000000000868 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 868:	1101                	addi	sp,sp,-32
 86a:	ec06                	sd	ra,24(sp)
 86c:	e822                	sd	s0,16(sp)
 86e:	1000                	addi	s0,sp,32
 870:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 874:	4605                	li	a2,1
 876:	fef40593          	addi	a1,s0,-17
 87a:	f67ff0ef          	jal	7e0 <write>
}
 87e:	60e2                	ld	ra,24(sp)
 880:	6442                	ld	s0,16(sp)
 882:	6105                	addi	sp,sp,32
 884:	8082                	ret

0000000000000886 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 886:	715d                	addi	sp,sp,-80
 888:	e486                	sd	ra,72(sp)
 88a:	e0a2                	sd	s0,64(sp)
 88c:	f84a                	sd	s2,48(sp)
 88e:	f44e                	sd	s3,40(sp)
 890:	0880                	addi	s0,sp,80
 892:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 894:	c6d1                	beqz	a3,920 <printint+0x9a>
 896:	0805d563          	bgez	a1,920 <printint+0x9a>
    neg = 1;
    x = -xx;
 89a:	40b005b3          	neg	a1,a1
    neg = 1;
 89e:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 8a0:	fb840993          	addi	s3,s0,-72
  neg = 0;
 8a4:	86ce                	mv	a3,s3
  i = 0;
 8a6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 8a8:	00001817          	auipc	a6,0x1
 8ac:	9c080813          	addi	a6,a6,-1600 # 1268 <digits>
 8b0:	88ba                	mv	a7,a4
 8b2:	0017051b          	addiw	a0,a4,1
 8b6:	872a                	mv	a4,a0
 8b8:	02c5f7b3          	remu	a5,a1,a2
 8bc:	97c2                	add	a5,a5,a6
 8be:	0007c783          	lbu	a5,0(a5)
 8c2:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 8c6:	87ae                	mv	a5,a1
 8c8:	02c5d5b3          	divu	a1,a1,a2
 8cc:	0685                	addi	a3,a3,1
 8ce:	fec7f1e3          	bgeu	a5,a2,8b0 <printint+0x2a>
  if (neg)
 8d2:	00030c63          	beqz	t1,8ea <printint+0x64>
    buf[i++] = '-';
 8d6:	fd050793          	addi	a5,a0,-48
 8da:	00878533          	add	a0,a5,s0
 8de:	02d00793          	li	a5,45
 8e2:	fef50423          	sb	a5,-24(a0)
 8e6:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 8ea:	02e05563          	blez	a4,914 <printint+0x8e>
 8ee:	fc26                	sd	s1,56(sp)
 8f0:	377d                	addiw	a4,a4,-1
 8f2:	00e984b3          	add	s1,s3,a4
 8f6:	19fd                	addi	s3,s3,-1
 8f8:	99ba                	add	s3,s3,a4
 8fa:	1702                	slli	a4,a4,0x20
 8fc:	9301                	srli	a4,a4,0x20
 8fe:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 902:	0004c583          	lbu	a1,0(s1)
 906:	854a                	mv	a0,s2
 908:	f61ff0ef          	jal	868 <putc>
  while (--i >= 0)
 90c:	14fd                	addi	s1,s1,-1
 90e:	ff349ae3          	bne	s1,s3,902 <printint+0x7c>
 912:	74e2                	ld	s1,56(sp)
}
 914:	60a6                	ld	ra,72(sp)
 916:	6406                	ld	s0,64(sp)
 918:	7942                	ld	s2,48(sp)
 91a:	79a2                	ld	s3,40(sp)
 91c:	6161                	addi	sp,sp,80
 91e:	8082                	ret
  neg = 0;
 920:	4301                	li	t1,0
 922:	bfbd                	j	8a0 <printint+0x1a>

0000000000000924 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 924:	711d                	addi	sp,sp,-96
 926:	ec86                	sd	ra,88(sp)
 928:	e8a2                	sd	s0,80(sp)
 92a:	e4a6                	sd	s1,72(sp)
 92c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 92e:	0005c483          	lbu	s1,0(a1)
 932:	22048363          	beqz	s1,b58 <vprintf+0x234>
 936:	e0ca                	sd	s2,64(sp)
 938:	fc4e                	sd	s3,56(sp)
 93a:	f852                	sd	s4,48(sp)
 93c:	f456                	sd	s5,40(sp)
 93e:	f05a                	sd	s6,32(sp)
 940:	ec5e                	sd	s7,24(sp)
 942:	e862                	sd	s8,16(sp)
 944:	8b2a                	mv	s6,a0
 946:	8a2e                	mv	s4,a1
 948:	8bb2                	mv	s7,a2
  state = 0;
 94a:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 94c:	4901                	li	s2,0
 94e:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 950:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 954:	06400c13          	li	s8,100
 958:	a00d                	j	97a <vprintf+0x56>
        putc(fd, c0);
 95a:	85a6                	mv	a1,s1
 95c:	855a                	mv	a0,s6
 95e:	f0bff0ef          	jal	868 <putc>
 962:	a019                	j	968 <vprintf+0x44>
    } else if (state == '%') {
 964:	03598363          	beq	s3,s5,98a <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 968:	0019079b          	addiw	a5,s2,1
 96c:	893e                	mv	s2,a5
 96e:	873e                	mv	a4,a5
 970:	97d2                	add	a5,a5,s4
 972:	0007c483          	lbu	s1,0(a5)
 976:	1c048a63          	beqz	s1,b4a <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 97a:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 97e:	fe0993e3          	bnez	s3,964 <vprintf+0x40>
      if (c0 == '%') {
 982:	fd579ce3          	bne	a5,s5,95a <vprintf+0x36>
        state = '%';
 986:	89be                	mv	s3,a5
 988:	b7c5                	j	968 <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 98a:	00ea06b3          	add	a3,s4,a4
 98e:	0016c603          	lbu	a2,1(a3)
      if (c1)
 992:	1c060863          	beqz	a2,b62 <vprintf+0x23e>
      if (c0 == 'd') {
 996:	03878763          	beq	a5,s8,9c4 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 99a:	f9478693          	addi	a3,a5,-108
 99e:	0016b693          	seqz	a3,a3
 9a2:	f9c60593          	addi	a1,a2,-100
 9a6:	e99d                	bnez	a1,9dc <vprintf+0xb8>
 9a8:	ca95                	beqz	a3,9dc <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 9aa:	008b8493          	addi	s1,s7,8
 9ae:	4685                	li	a3,1
 9b0:	4629                	li	a2,10
 9b2:	000bb583          	ld	a1,0(s7)
 9b6:	855a                	mv	a0,s6
 9b8:	ecfff0ef          	jal	886 <printint>
        i += 1;
 9bc:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 9be:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 9c0:	4981                	li	s3,0
 9c2:	b75d                	j	968 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 9c4:	008b8493          	addi	s1,s7,8
 9c8:	4685                	li	a3,1
 9ca:	4629                	li	a2,10
 9cc:	000ba583          	lw	a1,0(s7)
 9d0:	855a                	mv	a0,s6
 9d2:	eb5ff0ef          	jal	886 <printint>
 9d6:	8ba6                	mv	s7,s1
      state = 0;
 9d8:	4981                	li	s3,0
 9da:	b779                	j	968 <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 9dc:	9752                	add	a4,a4,s4
 9de:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 9e2:	f9460713          	addi	a4,a2,-108
 9e6:	00173713          	seqz	a4,a4
 9ea:	8f75                	and	a4,a4,a3
 9ec:	f9c58513          	addi	a0,a1,-100
 9f0:	18051363          	bnez	a0,b76 <vprintf+0x252>
 9f4:	18070163          	beqz	a4,b76 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 9f8:	008b8493          	addi	s1,s7,8
 9fc:	4685                	li	a3,1
 9fe:	4629                	li	a2,10
 a00:	000bb583          	ld	a1,0(s7)
 a04:	855a                	mv	a0,s6
 a06:	e81ff0ef          	jal	886 <printint>
        i += 2;
 a0a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 a0c:	8ba6                	mv	s7,s1
      state = 0;
 a0e:	4981                	li	s3,0
        i += 2;
 a10:	bfa1                	j	968 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 a12:	008b8493          	addi	s1,s7,8
 a16:	4681                	li	a3,0
 a18:	4629                	li	a2,10
 a1a:	000be583          	lwu	a1,0(s7)
 a1e:	855a                	mv	a0,s6
 a20:	e67ff0ef          	jal	886 <printint>
 a24:	8ba6                	mv	s7,s1
      state = 0;
 a26:	4981                	li	s3,0
 a28:	b781                	j	968 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 a2a:	008b8493          	addi	s1,s7,8
 a2e:	4681                	li	a3,0
 a30:	4629                	li	a2,10
 a32:	000bb583          	ld	a1,0(s7)
 a36:	855a                	mv	a0,s6
 a38:	e4fff0ef          	jal	886 <printint>
        i += 1;
 a3c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 a3e:	8ba6                	mv	s7,s1
      state = 0;
 a40:	4981                	li	s3,0
 a42:	b71d                	j	968 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 a44:	008b8493          	addi	s1,s7,8
 a48:	4681                	li	a3,0
 a4a:	4629                	li	a2,10
 a4c:	000bb583          	ld	a1,0(s7)
 a50:	855a                	mv	a0,s6
 a52:	e35ff0ef          	jal	886 <printint>
        i += 2;
 a56:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 a58:	8ba6                	mv	s7,s1
      state = 0;
 a5a:	4981                	li	s3,0
        i += 2;
 a5c:	b731                	j	968 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 a5e:	008b8493          	addi	s1,s7,8
 a62:	4681                	li	a3,0
 a64:	4641                	li	a2,16
 a66:	000be583          	lwu	a1,0(s7)
 a6a:	855a                	mv	a0,s6
 a6c:	e1bff0ef          	jal	886 <printint>
 a70:	8ba6                	mv	s7,s1
      state = 0;
 a72:	4981                	li	s3,0
 a74:	bdd5                	j	968 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 a76:	008b8493          	addi	s1,s7,8
 a7a:	4681                	li	a3,0
 a7c:	4641                	li	a2,16
 a7e:	000bb583          	ld	a1,0(s7)
 a82:	855a                	mv	a0,s6
 a84:	e03ff0ef          	jal	886 <printint>
        i += 1;
 a88:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 a8a:	8ba6                	mv	s7,s1
      state = 0;
 a8c:	4981                	li	s3,0
 a8e:	bde9                	j	968 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 a90:	008b8493          	addi	s1,s7,8
 a94:	4681                	li	a3,0
 a96:	4641                	li	a2,16
 a98:	000bb583          	ld	a1,0(s7)
 a9c:	855a                	mv	a0,s6
 a9e:	de9ff0ef          	jal	886 <printint>
        i += 2;
 aa2:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 aa4:	8ba6                	mv	s7,s1
      state = 0;
 aa6:	4981                	li	s3,0
        i += 2;
 aa8:	b5c1                	j	968 <vprintf+0x44>
 aaa:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 aac:	008b8793          	addi	a5,s7,8
 ab0:	8cbe                	mv	s9,a5
 ab2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 ab6:	03000593          	li	a1,48
 aba:	855a                	mv	a0,s6
 abc:	dadff0ef          	jal	868 <putc>
  putc(fd, 'x');
 ac0:	07800593          	li	a1,120
 ac4:	855a                	mv	a0,s6
 ac6:	da3ff0ef          	jal	868 <putc>
 aca:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 acc:	00000b97          	auipc	s7,0x0
 ad0:	79cb8b93          	addi	s7,s7,1948 # 1268 <digits>
 ad4:	03c9d793          	srli	a5,s3,0x3c
 ad8:	97de                	add	a5,a5,s7
 ada:	0007c583          	lbu	a1,0(a5)
 ade:	855a                	mv	a0,s6
 ae0:	d89ff0ef          	jal	868 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 ae4:	0992                	slli	s3,s3,0x4
 ae6:	34fd                	addiw	s1,s1,-1
 ae8:	f4f5                	bnez	s1,ad4 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 aea:	8be6                	mv	s7,s9
      state = 0;
 aec:	4981                	li	s3,0
 aee:	6ca2                	ld	s9,8(sp)
 af0:	bda5                	j	968 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 af2:	008b8493          	addi	s1,s7,8
 af6:	000bc583          	lbu	a1,0(s7)
 afa:	855a                	mv	a0,s6
 afc:	d6dff0ef          	jal	868 <putc>
 b00:	8ba6                	mv	s7,s1
      state = 0;
 b02:	4981                	li	s3,0
 b04:	b595                	j	968 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 b06:	008b8993          	addi	s3,s7,8
 b0a:	000bb483          	ld	s1,0(s7)
 b0e:	cc91                	beqz	s1,b2a <vprintf+0x206>
        for (; *s; s++)
 b10:	0004c583          	lbu	a1,0(s1)
 b14:	c985                	beqz	a1,b44 <vprintf+0x220>
          putc(fd, *s);
 b16:	855a                	mv	a0,s6
 b18:	d51ff0ef          	jal	868 <putc>
        for (; *s; s++)
 b1c:	0485                	addi	s1,s1,1
 b1e:	0004c583          	lbu	a1,0(s1)
 b22:	f9f5                	bnez	a1,b16 <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 b24:	8bce                	mv	s7,s3
      state = 0;
 b26:	4981                	li	s3,0
 b28:	b581                	j	968 <vprintf+0x44>
          s = "(null)";
 b2a:	00000497          	auipc	s1,0x0
 b2e:	73648493          	addi	s1,s1,1846 # 1260 <malloc+0x59a>
        for (; *s; s++)
 b32:	02800593          	li	a1,40
 b36:	b7c5                	j	b16 <vprintf+0x1f2>
        putc(fd, '%');
 b38:	85be                	mv	a1,a5
 b3a:	855a                	mv	a0,s6
 b3c:	d2dff0ef          	jal	868 <putc>
      state = 0;
 b40:	4981                	li	s3,0
 b42:	b51d                	j	968 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 b44:	8bce                	mv	s7,s3
      state = 0;
 b46:	4981                	li	s3,0
 b48:	b505                	j	968 <vprintf+0x44>
 b4a:	6906                	ld	s2,64(sp)
 b4c:	79e2                	ld	s3,56(sp)
 b4e:	7a42                	ld	s4,48(sp)
 b50:	7aa2                	ld	s5,40(sp)
 b52:	7b02                	ld	s6,32(sp)
 b54:	6be2                	ld	s7,24(sp)
 b56:	6c42                	ld	s8,16(sp)
    }
  }
}
 b58:	60e6                	ld	ra,88(sp)
 b5a:	6446                	ld	s0,80(sp)
 b5c:	64a6                	ld	s1,72(sp)
 b5e:	6125                	addi	sp,sp,96
 b60:	8082                	ret
      if (c0 == 'd') {
 b62:	06400713          	li	a4,100
 b66:	e4e78fe3          	beq	a5,a4,9c4 <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 b6a:	f9478693          	addi	a3,a5,-108
 b6e:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 b72:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 b74:	4701                	li	a4,0
      } else if (c0 == 'u') {
 b76:	07500513          	li	a0,117
 b7a:	e8a78ce3          	beq	a5,a0,a12 <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 b7e:	f8b60513          	addi	a0,a2,-117
 b82:	e119                	bnez	a0,b88 <vprintf+0x264>
 b84:	ea0693e3          	bnez	a3,a2a <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 b88:	f8b58513          	addi	a0,a1,-117
 b8c:	e119                	bnez	a0,b92 <vprintf+0x26e>
 b8e:	ea071be3          	bnez	a4,a44 <vprintf+0x120>
      } else if (c0 == 'x') {
 b92:	07800513          	li	a0,120
 b96:	eca784e3          	beq	a5,a0,a5e <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 b9a:	f8860613          	addi	a2,a2,-120
 b9e:	e219                	bnez	a2,ba4 <vprintf+0x280>
 ba0:	ec069be3          	bnez	a3,a76 <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 ba4:	f8858593          	addi	a1,a1,-120
 ba8:	e199                	bnez	a1,bae <vprintf+0x28a>
 baa:	ee0713e3          	bnez	a4,a90 <vprintf+0x16c>
      } else if (c0 == 'p') {
 bae:	07000713          	li	a4,112
 bb2:	eee78ce3          	beq	a5,a4,aaa <vprintf+0x186>
      } else if (c0 == 'c') {
 bb6:	06300713          	li	a4,99
 bba:	f2e78ce3          	beq	a5,a4,af2 <vprintf+0x1ce>
      } else if (c0 == 's') {
 bbe:	07300713          	li	a4,115
 bc2:	f4e782e3          	beq	a5,a4,b06 <vprintf+0x1e2>
      } else if (c0 == '%') {
 bc6:	02500713          	li	a4,37
 bca:	f6e787e3          	beq	a5,a4,b38 <vprintf+0x214>
        putc(fd, '%');
 bce:	02500593          	li	a1,37
 bd2:	855a                	mv	a0,s6
 bd4:	c95ff0ef          	jal	868 <putc>
        putc(fd, c0);
 bd8:	85a6                	mv	a1,s1
 bda:	855a                	mv	a0,s6
 bdc:	c8dff0ef          	jal	868 <putc>
      state = 0;
 be0:	4981                	li	s3,0
 be2:	b359                	j	968 <vprintf+0x44>

0000000000000be4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 be4:	715d                	addi	sp,sp,-80
 be6:	ec06                	sd	ra,24(sp)
 be8:	e822                	sd	s0,16(sp)
 bea:	1000                	addi	s0,sp,32
 bec:	e010                	sd	a2,0(s0)
 bee:	e414                	sd	a3,8(s0)
 bf0:	e818                	sd	a4,16(s0)
 bf2:	ec1c                	sd	a5,24(s0)
 bf4:	03043023          	sd	a6,32(s0)
 bf8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 bfc:	8622                	mv	a2,s0
 bfe:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 c02:	d23ff0ef          	jal	924 <vprintf>
}
 c06:	60e2                	ld	ra,24(sp)
 c08:	6442                	ld	s0,16(sp)
 c0a:	6161                	addi	sp,sp,80
 c0c:	8082                	ret

0000000000000c0e <printf>:

void
printf(const char *fmt, ...)
{
 c0e:	711d                	addi	sp,sp,-96
 c10:	ec06                	sd	ra,24(sp)
 c12:	e822                	sd	s0,16(sp)
 c14:	1000                	addi	s0,sp,32
 c16:	e40c                	sd	a1,8(s0)
 c18:	e810                	sd	a2,16(s0)
 c1a:	ec14                	sd	a3,24(s0)
 c1c:	f018                	sd	a4,32(s0)
 c1e:	f41c                	sd	a5,40(s0)
 c20:	03043823          	sd	a6,48(s0)
 c24:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 c28:	00840613          	addi	a2,s0,8
 c2c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 c30:	85aa                	mv	a1,a0
 c32:	4505                	li	a0,1
 c34:	cf1ff0ef          	jal	924 <vprintf>
}
 c38:	60e2                	ld	ra,24(sp)
 c3a:	6442                	ld	s0,16(sp)
 c3c:	6125                	addi	sp,sp,96
 c3e:	8082                	ret

0000000000000c40 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 c40:	1141                	addi	sp,sp,-16
 c42:	e406                	sd	ra,8(sp)
 c44:	e022                	sd	s0,0(sp)
 c46:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 c48:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c4c:	00001797          	auipc	a5,0x1
 c50:	4447b783          	ld	a5,1092(a5) # 2090 <freep>
 c54:	a039                	j	c62 <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 c56:	6398                	ld	a4,0(a5)
 c58:	00e7e463          	bltu	a5,a4,c60 <free+0x20>
 c5c:	00e6ea63          	bltu	a3,a4,c70 <free+0x30>
{
 c60:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c62:	fed7fae3          	bgeu	a5,a3,c56 <free+0x16>
 c66:	6398                	ld	a4,0(a5)
 c68:	00e6e463          	bltu	a3,a4,c70 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 c6c:	fee7eae3          	bltu	a5,a4,c60 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 c70:	ff852583          	lw	a1,-8(a0)
 c74:	6390                	ld	a2,0(a5)
 c76:	02059813          	slli	a6,a1,0x20
 c7a:	01c85713          	srli	a4,a6,0x1c
 c7e:	9736                	add	a4,a4,a3
 c80:	02e60563          	beq	a2,a4,caa <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 c84:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 c88:	4790                	lw	a2,8(a5)
 c8a:	02061593          	slli	a1,a2,0x20
 c8e:	01c5d713          	srli	a4,a1,0x1c
 c92:	973e                	add	a4,a4,a5
 c94:	02e68263          	beq	a3,a4,cb8 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 c98:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 c9a:	00001717          	auipc	a4,0x1
 c9e:	3ef73b23          	sd	a5,1014(a4) # 2090 <freep>
}
 ca2:	60a2                	ld	ra,8(sp)
 ca4:	6402                	ld	s0,0(sp)
 ca6:	0141                	addi	sp,sp,16
 ca8:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 caa:	4618                	lw	a4,8(a2)
 cac:	9f2d                	addw	a4,a4,a1
 cae:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 cb2:	6398                	ld	a4,0(a5)
 cb4:	6310                	ld	a2,0(a4)
 cb6:	b7f9                	j	c84 <free+0x44>
    p->s.size += bp->s.size;
 cb8:	ff852703          	lw	a4,-8(a0)
 cbc:	9f31                	addw	a4,a4,a2
 cbe:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 cc0:	ff053683          	ld	a3,-16(a0)
 cc4:	bfd1                	j	c98 <free+0x58>

0000000000000cc6 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 cc6:	7139                	addi	sp,sp,-64
 cc8:	fc06                	sd	ra,56(sp)
 cca:	f822                	sd	s0,48(sp)
 ccc:	f04a                	sd	s2,32(sp)
 cce:	ec4e                	sd	s3,24(sp)
 cd0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 cd2:	02051993          	slli	s3,a0,0x20
 cd6:	0209d993          	srli	s3,s3,0x20
 cda:	09bd                	addi	s3,s3,15
 cdc:	0049d993          	srli	s3,s3,0x4
 ce0:	2985                	addiw	s3,s3,1
 ce2:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 ce4:	00001517          	auipc	a0,0x1
 ce8:	3ac53503          	ld	a0,940(a0) # 2090 <freep>
 cec:	c905                	beqz	a0,d1c <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 cee:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 cf0:	4798                	lw	a4,8(a5)
 cf2:	09377663          	bgeu	a4,s3,d7e <malloc+0xb8>
 cf6:	f426                	sd	s1,40(sp)
 cf8:	e852                	sd	s4,16(sp)
 cfa:	e456                	sd	s5,8(sp)
 cfc:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 cfe:	8a4e                	mv	s4,s3
 d00:	6705                	lui	a4,0x1
 d02:	00e9f363          	bgeu	s3,a4,d08 <malloc+0x42>
 d06:	6a05                	lui	s4,0x1
 d08:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 d0c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 d10:	00001497          	auipc	s1,0x1
 d14:	38048493          	addi	s1,s1,896 # 2090 <freep>
  if (p == SBRK_ERROR)
 d18:	5afd                	li	s5,-1
 d1a:	a83d                	j	d58 <malloc+0x92>
 d1c:	f426                	sd	s1,40(sp)
 d1e:	e852                	sd	s4,16(sp)
 d20:	e456                	sd	s5,8(sp)
 d22:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 d24:	00001797          	auipc	a5,0x1
 d28:	3bc78793          	addi	a5,a5,956 # 20e0 <base>
 d2c:	00001717          	auipc	a4,0x1
 d30:	36f73223          	sd	a5,868(a4) # 2090 <freep>
 d34:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 d36:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 d3a:	b7d1                	j	cfe <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 d3c:	6398                	ld	a4,0(a5)
 d3e:	e118                	sd	a4,0(a0)
 d40:	a899                	j	d96 <malloc+0xd0>
  hp->s.size = nu;
 d42:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 d46:	0541                	addi	a0,a0,16
 d48:	ef9ff0ef          	jal	c40 <free>
  return freep;
 d4c:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 d4e:	c125                	beqz	a0,dae <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 d50:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 d52:	4798                	lw	a4,8(a5)
 d54:	03277163          	bgeu	a4,s2,d76 <malloc+0xb0>
    if (p == freep)
 d58:	6098                	ld	a4,0(s1)
 d5a:	853e                	mv	a0,a5
 d5c:	fef71ae3          	bne	a4,a5,d50 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 d60:	8552                	mv	a0,s4
 d62:	a2bff0ef          	jal	78c <sbrk>
  if (p == SBRK_ERROR)
 d66:	fd551ee3          	bne	a0,s5,d42 <malloc+0x7c>
        return 0;
 d6a:	4501                	li	a0,0
 d6c:	74a2                	ld	s1,40(sp)
 d6e:	6a42                	ld	s4,16(sp)
 d70:	6aa2                	ld	s5,8(sp)
 d72:	6b02                	ld	s6,0(sp)
 d74:	a03d                	j	da2 <malloc+0xdc>
 d76:	74a2                	ld	s1,40(sp)
 d78:	6a42                	ld	s4,16(sp)
 d7a:	6aa2                	ld	s5,8(sp)
 d7c:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 d7e:	fae90fe3          	beq	s2,a4,d3c <malloc+0x76>
        p->s.size -= nunits;
 d82:	4137073b          	subw	a4,a4,s3
 d86:	c798                	sw	a4,8(a5)
        p += p->s.size;
 d88:	02071693          	slli	a3,a4,0x20
 d8c:	01c6d713          	srli	a4,a3,0x1c
 d90:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 d92:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 d96:	00001717          	auipc	a4,0x1
 d9a:	2ea73d23          	sd	a0,762(a4) # 2090 <freep>
      return (void *)(p + 1);
 d9e:	01078513          	addi	a0,a5,16
  }
}
 da2:	70e2                	ld	ra,56(sp)
 da4:	7442                	ld	s0,48(sp)
 da6:	7902                	ld	s2,32(sp)
 da8:	69e2                	ld	s3,24(sp)
 daa:	6121                	addi	sp,sp,64
 dac:	8082                	ret
 dae:	74a2                	ld	s1,40(sp)
 db0:	6a42                	ld	s4,16(sp)
 db2:	6aa2                	ld	s5,8(sp)
 db4:	6b02                	ld	s6,0(sp)
 db6:	b7f5                	j	da2 <malloc+0xdc>
