.data
	tituloPrograma: .asciiz "*** DECOMPOSICAO LU DE MATRIZES QUADRADAS ***"
	pulaLinha: .asciiz "\n"
	tab: .asciiz "	"
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
	jal PrintMatriz
	
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
	
	move $t5, $a1 #$t5 = a[0][0]
	bge $t2, $a0, exit1 #Nao entra no for se nao passar na condicao
loop1:
	mov.d $f12,$f8 # big = 0
	li $t3, 0
	
	bge $t3, $a0, exit2 #Nao entra no for se nao passar na condicao
loop2:
	ldc1 $f10,($t5) # carrega o valor da matriz para o registrador $f10
	abs.d $f10,$f10 # pega o valor absoluto da matriz
	c.le.d 0,$f12,$f10 # if (elem => big)
	bc1f 0,cond
	mov.d $f12,$f10 # big = elem
cond:
	addi $t3,$t3,1
	addi $t5,$t5,8 #proximo elemento
	blt $t3,$a0,loop2
exit2:		
	c.eq.d 1,$f10,$f8 # if (big == 0) then erro
	bc1t 1,erro0
	div.d $f14,$f16,$f12
	sll $t6,$t2,3
	add $t6,$t6,$t1
	sdc1 $f14,0($t6)
	addi $t2,$t2,1
	
	blt $t2, $a0, loop1
exit1:		
	li $t3, 0 #j = 0
	
	bge $t3,$a0,exit3
loop3:
	li $t2, 0 #i = 0
	
	bge $t2, $t3, exit4 #Nao entra no for se nao passar na condicao
loop4:	
	mul $t5, $t2, $a0 #i*n
	add $t5, $t5, $t3 #j+(i*n)
	sll $t5, $t5, 3 #de 8 bits em 8 bits
	add $t5, $t5, $a1
	ldc1 $f18,($t5) # sum = a[i][j]
	li $t4, 0 #i = 1
	
	bge $t4, $t2, exit5 #Nao entra no for se nao passar na condicao
loop5:
	mul $t5, $t2, $a0 #i*n
	add $t5, $t5, $t4 #k+(i*n)
	sll $t5, $t5, 3 #de 8 bits em 8 bits
	add $t5, $t5, $a1
	ldc1 $f20,($t5) # a[i][k]
	
	mul $t5, $t4, $a0 #k*n
	add $t5, $t3, $t5 #j + (k*n)
	sll $t5, $t5, 3 #de 8 bits em 8 bits
	add $t5, $t5, $a1
	ldc1 $f22, ($t5) #a[k][j]
	
	mul.d $f20, $f20, $f22 #a[i][k]*a[k][j]
	sub.d $f18, $f18, $f20 #sum -= a[i][k]*a[k][j]
	
	addi $t4, $t4, 1 #k++
	
 	blt $t4, $t2, loop5 #k<i
exit5:	
	sdc1 $f18, ($t5) #a[i][j] = sum
	
	addi $t2, $t2, 1 #i++
	blt $t2, $t3, loop4 #i<j
exit4:	
	mov.d $f12,$f8 # big = 0
	
	move $t2, $t3 #i = j
	
	bge $t2, $a0, exit6 #Nao entra no for se nao passar na condicao
loop6:
	mul $t5, $t2, $a0 #i*n
	add $t5, $t5, $t3 #j+(i*n)
	sll $t5, $t5, 3 #de 8 bits em 8 bits
	add $t5, $t5, $a1
	ldc1 $f18,($t5) # sum = a[i][j]
	li $t4, 0
	
	bge $t4, $t3, exit7  #Nao entra no for se nao passar na condicao
loop7:
	mul $t5, $t2, $a0 #i*n
	add $t5, $t5, $t4 #k+(i*n)
	sll $t5, $t5, 3 #de 8 bits em 8 bits
	add $t5, $t5, $a1
	ldc1 $f20,($t5) # a[i][k]
	
	mul $t5, $t4, $a0 #k*n
	add $t5, $t3, $t6 #j + (k*n)
	sll $t5, $t5, 3 #de 8 bits em 8 bits
	add $t5, $t5, $a1
	ldc1 $f22, ($t5) #a[k][j]
	
	mul.d $f20, $f20, $f22 #a[i][k]*a[k][j]
	sub.d $f18, $f18, $f20 #sum -= a[i][k]*a[k][j]
	
	addi $t4, $t4, 1 #k++
	blt $t4, $t3, loop7 #k<j
exit7: 	
	
	sdc1 $f18, ($t5) #a[i][j] = sum
	
	abs.d $f10, $f10
	
	sll $t8, $t2, 3
	add $t8, $t8, $t1 
	ldc1 $f24, ($t8) #vv[i]
	
	mul.d $f10, $f10, $f24 #dum = fabs(sum) * vv[i]
	
	c.lt.d 2, $f10,  $f12
	bc1t 2, cond2

	mov.d $f12, $f10 #big = dum
	move $t9, $t2 #imax = i
							
cond2: 
	addi $t2, $t2, 1 #i++
	blt $t2, $a0, loop6 #i<n
exit6: 
	beq $t2, $t9, cond3
	
	li $t4, 1
	
	bge $t4, $a0, exit8
loop8:
	mul $t5, $t9, $a0 #imax * n
	add $t5, $t4, $t6 #k + (imax*n)
	sll $t5, $t5, 3 #de 8 em 8 bits
	add $t5, $t5, $a1 #a[imax][k]
	
	mul $t6, $t3, $a0 #j * n
	add $t6, $t4, $t6 #k + (j*n)
	sll $t6, $t6, 3 #de 8 em 8 bits
	add $t6, $t6, $a1#a[j][k]
	
	ldc1 $f10, ($t5) #dum = a[imax][k]
	ldc1 $f20, ($t6)
	sdc1 $f20, ($t5)#a[imax][k] = a[j][k]
	sdc1 $f10, ($t6)#a[j][k] = dum
	
	addi $t4, $t4, 1
	blt $t4, $a0, loop8
	
exit8: 			
	sll $t8, $t9, 3
	add $t8, $t8, $t1#vv[imax] 
	sll $t6, $t3, 3
	add $t6, $t6, $t1#vv[j]
	ldc1 $f24, ($t6)
	sdc1 $f24, ($t8) #vv[imax] = vv[j]
		
cond3:	la $s1,indx
	
	ldc1 $f26,0($t0) # a[j][j]
	
	c.eq.d 3,$f26,$f8 # if (a[j][j] == 0)
	bc1t 3,erro0 # salta para a label de erro
	
	beq $t3,$a0,cond4 # if (j != n) {
	div.d $f10,$f16,$f26 # dum=1.0/(a[j][j]);
	
	# t4 = j + 1
	addi $t2,$t3,1 # for (i=j+1;i<=n;i++)
	bge $t2, $a0, exit9

loop9:		
	mul $t5, $t2, $a0 #i * n
	add $t5, $t3, $t5 #j + (i*n)
	sll $t5, $t5, 3 #de 8 em 8 bits
	add $t5, $t5, $a1 #a[i][j]
	
	ldc1 $f30,($t5)
	mul.d $f30,$f30,$f10
	sdc1 $f30,($t5)
	
	addi $t2, $t2, 1
	blt $t2, $a0, loop9
exit9:
	# } if
	
cond4:		
	addi $t0,$a0,1 # pega sempre os elementos das diagonais, pois sempre eles possuem a diferenca
	sll $t0,$t0,3 # do numero de linhas + 1
	add $t0,$t0,$a1 # acrescenta no endere�o de come�o da matriz
	
	addi $t3, $t3, 1		
	blt $t3,$a0,loop3
exit3:	
	jr $ra
erro0:	
	la $a0, msgErro0
	li $v0, 4
	syscall
	j begin

PrintMatriz:
	li $t0,0

	move $t2,$a1
	
	
printLoop:
	li $t1,0
pl:	ldc1 $f12,($t2)
	
	li $v0,3 # printa o elemento da matriz
	syscall
	
	la $a0, tab
	li $v0,4 # printa o tab
	syscall
	
	addi $t2,$t2,8
	addi $t1,$t1,1
	blt $t1,$s0,pl
	
	la $a0, pulaLinha
	li $v0,4 # printa o enter
	syscall
	
	addi $t0,$t0,1
	blt $t0,$s0,printLoop
	

#checar < / <=
																							
			



#TODO: entender a decomposicao LU, e fazer os algoritmos