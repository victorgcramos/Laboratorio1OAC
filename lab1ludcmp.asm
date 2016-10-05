.text
	# Matriz carregada anteriormente
	# $a0 = numero de linhas e colunas
	# $a1 = endereço de inicio da matriz
	# $f8 = 0 em double
	# $f12 = big
	#$f10 =a[i][j]
	#$f16 = 1
	#$f14 = vv[i]
	#$f0 = sum
	# $t9 = imax
DecomposicaoLU:
	li $t0,0 # valor incial do vetor de modificaçoes
	la $t1,vetor # endereço do vetor de modificaçoes
	la $t5,constDouble
	li $t2,0 # contador do loop1 (linhas) i
	li $t3,0 # contador loop 2 (colunas) j
	li $t4,0x0008
	sw $t4, 0($t5)
	ldc1 $f16, 0($t5) # $f16 = 1.0
	

loop1:
	mov.d $f12,$f8 # big = 0
	li $t3, 0
	
loop2:
	sll $t5,$t3,3
	add $t5,$t5,$a1
	ldc1 $f10,($t5) # carrega o valor da matriz para o registrador $f10
	abs.d $f10,$f10 # pega o valor absoluto da matriz
	c.le.d 0,$f12,$f10 # if (elem => big)
	bc1f 0,cond
	mov.d $f12,$f10 # big = elem
cond:
	addi $t3,$t3,1
ex2:	ble $t3,$a0,loop2
		
	c.eq.d 1,$f10,$f8 # if (big == 0) then erro
	bc1t 1,erro0
	div.d $f14,$f16,$f12
	sll $t5,$t2,3
	add $t5,$t5,$t1
	sdc1 $f14,0($t5)
	addi $t2,$t2,1
	
ex1:	ble $t2, $a0, loop1
		
	li $t3, 0
	
loop3:
	li $t2, 0
loop4:
	sll $t5,$t3,3
	add $t5,$t5,$a1
	ldc1 $f18,($t5) # sum = a[i][j]
	li $t4, 0
loop5:
	sll $t6, $t4, 3
	add $t6, $t6, $a1
	ldc1 $f20, ($t6) # a[i][k]
	
	mul $t6, $t4, $a0
	add $t6, $t3, $t6
	sll $t6, $t6, 3
	add $t6, $t6, $a1
	ldc1 $f22, ($t6) #a[k][j]
	
	mul.d $f20, $f20, $f22 #a[i][k]*a[k][j]
	sub.d $f18, $f18, $f20 #sum -= a[i][k]*a[k][j]
	
	addi $t4, $t4, 1 #k++
	
ex5: blt $t4, $t2, loop5 #k<i
	
	sdc1 $f18, ($t5)
	
	addi $t2, $t2, 1 #i++
ex4:	blt $t2, $t3, loop4 #i<j
	
	mov.d $f12,$f8 # big = 0
	
	move $t2, $t3 #i = j
loop6:
	sll $t5,$t3,3
	add $t5,$t5,$a1
	ldc1 $f18,($t5) # sum = a[i][j]
	li $t4, 0
loop7:
	sll $t6, $t4, 3
	add $t6, $t6, $a1
	ldc1 $f20, ($t6) # a[i][k]
	
	mul $t6, $t4, $a0
	add $t6, $t3, $t6
	sll $t6, $t6, 3
	add $t6, $t6, $a1
	ldc1 $f22, ($t6) #a[k][j]
	
	mul.d $f20, $f20, $f22 #a[i][k]*a[k][j]
	sub.d $f18, $f18, $f20 #sum -= a[i][k]*a[k][j]
	
	addi $t4, $t4, 1 #k++
	
ex7: blt $t4, $t3, loop7 #k<j
	
	sdc1 $f18, ($t5) #a[i][j] = sum
	
	abs.d $f10, $f10
	
	sll $t8, $t2, 3
	add $t8, $t8, $t1 
	ldc1 $f24, ($t8) #vv[i]
	
	mul.d $f10, $f10, $f24 #dum = fabs(sum) * vv[i]
	
	c.lt.d 2, $f10,  $f12
	bc1f 2, cond2
	
	mov.d $f12, $f10 #big = dum
	move $t9, $t2 #imax = i
							
cond2: 
	addi $t2, $t2, 1 #i++
ex6: ble $t2, $a1, loop6 #i <=n

	beq $t2, $t9, cond3
	
	li $t4, 1
loop8:
	mul $t6, $t9, $a0
	add $t6, $t4, $t6
	sll $t6, $t6, 3
	add $t6, $t6, $a1 #a[imax][k]
	
	mul $t7, $t3, $a0
	add $t7, $t4, $t6
	sll $t7, $t7, 3
	add $t7, $t7, $a1#a[j][k]
	
	ldc1 $f10, ($t6) #dum = a[imax][k]
	ldc1 $f20, ($t7)
	sdc1 $f20, ($t6)#a[imax][k] = a[j][k]
	sdc1 $f10, ($t7)#a[j][k] = dum
	
	addi $t4, $t4, 1
ex8: ble $t4, $a1, loop8
	
	sll $t8, $t9, 3
	add $t8, $t8, $t1#vv[imax] 
	sll $t6, $t3, 3
	add $t6, $t8, $t1#vv[j]
	ldc1 $f24, ($t6)
	sdc1 $f24, ($t8) #vv[imax] = vv[j]
		
cond3:
		

	

erro0:	

#checar < / <=