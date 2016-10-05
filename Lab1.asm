.data
	tituloPrograma: .asciiz "*** DECOMPOSICAO LU DE MATRIZES QUADRADAS ***"
	pulaLinha: .asciiz "\n"
	msgErro0: .asciiz "Erro! ocorreu uma divisao por 0. Tente novamente."
	leNMatriz: .asciiz "Qual o um N para uma matriz NxN? <ENTER> "
	leCoef: .asciiz "Informe o coeficiente M("
	virgula: .asciiz ","
	const: .double 0.0
	vetor: .space 24
	indx: .space 40
	const1Double: .double 1.0
	fechaParenteses: .asciiz "): "
	matriz: .double 0.0 # criando endereco para armazenar a matriz dos coeficientes
	
.text
# Tabela para registradores:
#	$s0 = Tamanho da matriz NxN
#	$s6 = Inicio da Matriz 1
#	$s1 = Inicio da Matriz 2
begin:	
	li $s0,0 # $s0 vai ser o numero de linhas e colunas NxN
	la $s6,matriz
	li $t0,1 # contador de linhas
	li $t1,1 # contador de colunas

menu:	la $a0, tituloPrograma # imprime na tela o t�tulo do programa
	li $v0, 4
	syscall
	
	la $a0, pulaLinha # salta uma linha
	li $v0, 4
	syscall
	
	la $a0, leNMatriz # le o numero de linhas e colunas da matriz quadrada NxN
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	move $s0,$v0 # N fica armazenado em $s0
	

leMtx: 	la $a0, leCoef # printa mensagem para usuario informar o elemento da matriz
	li $v0, 4
	syscall
	
	addi $a0,$t0,0 # printa o indice de linha da matriz
	li $v0,1
	syscall
	
	la $a0, virgula # printa a virgula para fins esteticos
	li $v0, 4
	syscall
	
	addi $a0,$t1,0 # Printa o indice de coluna da matriz
	li $v0,1
	syscall
	
	la $a0, fechaParenteses # printa o "): " para fins esteticos
	li $v0, 4
	syscall
	
	li $v0,7
	syscall
	
	sdc1 $f0,0($s6) # Armazena os valores na matriz
	addi $s6,$s6,8 # Incrementa o endereco para caber mais valores dentro da matriz
	addi $t1,$t1,1 # incrementa o valor do indice de colunas
	
	ble $t1,$s0,leMtx
	
	addi $t1,$zero,1 #zera o contador de colunas $t1
	addi $t0,$t0,1 # incrementa o valor do indice de linhas
	
	ble $t0,$s0,leMtx 
	
	move $a0,$s0
	la $a1,matriz
	la $t0, const
	ldc1 $f8,0($t0)

	jal DecomposicaoLU
	
fim:	la $v0, 10
	syscall	
	
	

# Parametros:
# $a0 = numero de linhas e colunas
# $a1 = endere�o de inicio da matriz
# $f8 = 0 em double

# $f12 = big
# $f10 =a[i][j]
# $f16 = 1
# $f14 = vv[i]
# $f0 = sum
# $t9 = imax
# $t0 = indx
DecomposicaoLU:
	move $t0,$a1 # contador de elementos das diagonais
	la $t1,vetor # endere�o do vetor de modifica�oes
	la $t5,const1Double
	li $t2,0 # contador do loop1 (linhas) i
	li $t3,0 # contador loop 2 (colunas) j
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
ex2:	blt $t3,$a0,loop2
		
	c.eq.d 1,$f10,$f8 # if (big == 0) then erro
	bc1t 1,erro0
	div.d $f14,$f16,$f12
	sll $t5,$t2,3
	add $t5,$t5,$t1
	sdc1 $f14,0($t5)
	addi $t2,$t2,1
	
ex1:	blt $t2, $a0, loop1
		
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
	
ex5: 	blt $t4, $t2, loop5 #k<i
	
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
	
ex7: 	blt $t4, $t3, loop7 #k<j
	
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
		
cond3:	la $s1,indx
	ldc1 $f26,0($t0) # a[j][j]
	
	c.eq.d 3,$f26,$f8 # if (a[j][j] == 0)
	bc1t 3,erro0 # salta para a label de erro
	
	beq $t3,$a0,cond4 # if (j != n) {
	div.d $f10,$f16,$f26 # dum=1.0/(a[j][j]);
	
	# t4 = j + 1
	addi $t4,$t3,1 # for (i=j+1;i<=n;i++)
loop9:	add $t8,$t4,$a0
	sll $t8,$t8,3
	
	ldc1 $f30,($t8)
	mul.d $f30,$f30,$f10
	sdc1 $f30,($t8)
	# } if
cond4:		
	addi $t0,$a0,1 # pega sempre os elementos das diagonais, pois sempre eles possuem a diferenca
	sll $t0,$t0,3 # do numero de linhas + 1
	add $t0,$t0,$a1 # acrescenta no endere�o de come�o da matriz
	
	ble $t3,$a0,loop3
	
	jr $ra
erro0:	
	la $a0, msgErro0
	syscall
	j begin

#checar < / <=
																							
			



#TODO: entender a decomposicao LU, e fazer os algoritmos
