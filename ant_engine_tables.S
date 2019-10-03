#include <regdef.h>

.data
rotation_rules: .word 3,2,2,3,0,1,1,0 

#declaro matriz rotation_rules[4][2]

.data
relevant_bound: .word 0,0,0,0


.text
.align 2
.globl new_orientation
.ent new_orientation

new_orientation:
.frame fp,8,ra
.set noreorder
.cpload t9
.set reorder

addiu sp,sp,-8
.cprestore 0
sw fp,4(sp)
move fp,sp

sw a0,8(sp) 	#a0(orientation) -> Mem[8]
sw a1,12(sp) 	#a1(rule) -> Mem[12]

la v0, rotation_rules 		#v0 <- rotation_rules[][]
lw v1,8(sp) 	# v1 <- orientation
sll t0,v1,1		# t0 <- v1 (orientation) * 2
lw v1,12(sp) 	# v1 <- v1 (rule)
addu v1,t0,v1 	# v1 <- t0(orientation * 2) + v1 (rule)
				# v1 es el indice de la matriz
sll v1,v1,2 	# v1 <- indice * 4 - word addresses

addu v0,v1,v0	# v0 <- rotation_rules[][]+v1
lw v0,0(v0) 	# v0 <- rotation_rules[v1] 

lw gp,0(sp)
lw fp,4(sp)
addiu sp,sp,8
jr ra

.end new_orientation


.text
.align 2
.globl move_forward
.ent move_forward

move_forward:
.frame sp,40,ra
.set noreorder
.cpload t9
.set reorder

addiu sp,sp,-40
sw gp,24(sp)
sw fp,28(sp)
sw ra,32(sp)
move fp,sp

sw a0,40(sp) 	#a0(ant*) -> Mem[40]
sw a1,44(sp)
sw a2,48(sp)

lw t1,44(sp) 	#t1 <- width
lw t2,48(sp) 	#t1 <- height


la v0, relevant_bound	#v0 <- relevant_bound[]
sw t1,0(v0) 			#t1 -> relevant_bound[0]
sw t1,4(v0)
sw t2,8(v0) 			#t2 -> relevant_bound[8]
sw t2,12(v0) 			#lo cargo con los parametros

lw a0,40(sp) 	#a0 <- ant*(&x)
lw t1,8(a0) 	#t1 <- ant(8)= o
sll t1,t1,2 	#t1 <- o * 4 - memory address
addu v1,v0,t1 	#v1 <- relevant_bound[] + t1
lw v1,0(v1) 	#v1(bound) <- relevant_bound[v0] 

move a1,v1 	 	#a1 <- v1 (bound)

lw t1,8(a0) 	#t1 <- ant(8)= o
beqz t1,north

li t0,1
beq t1,t0,south

li t0,2
beq t1,t0,east

li t0,3
beq t1,t0,west

north: 
jal step_north
j end

south: 
jal step_south
j end

east: 
jal step_east
j end

west: 
jal step_west
j end

end:
lw gp,24(sp)
lw fp,28(sp)
lw ra,32(sp)
addiu sp,sp,40
jr ra

.end move_forward



.text
.align 2 
.ent step_north

step_north:
.frame sp,32,ra
.set noreorder
.cpload t9
.set reorder

addiu sp,sp,-32
.cprestore 16
sw fp,20(sp)
sw ra,24(sp)
move fp,sp

sw a0,32(sp)
sw a1,36(sp)

lw v0,32(sp) 		#v0 <- ant(x*)
lw a1,4(v0)			#a1 <- y
addiu a1,a1,-1 		#a1 <- a1(y)-1

addiu v0,v0,4 		#v0 <- ant(y*)
move a0,v0 			#a0 <- v0

lw a2,36(sp) 		#a2 <- height

jal doAdjust
lw v0,32(sp) 		#v0 <- ant(x*)

lw gp,16(sp)
lw fp,20(sp)
lw ra,24(sp)
addiu sp,sp,32
jr ra
.end step_north



.text
.align 2 
.ent step_south

step_south:
.frame sp,32,ra
.set noreorder
.cpload t9
.set reorder

addiu sp,sp,-32
.cprestore 16
sw fp,20(sp)
sw ra,24(sp)
move fp,sp

sw a0,32(sp)
sw a1,36(sp)

lw v0,32(sp) 		#v0 <- ant(x*)
lw a1,4(v0)			#a1 <- y
addiu a1,a1,1 		#a1 <- a1(y)+1

addiu v0,v0,4 		#v0 <- ant(y*)
move a0,v0 			#a0 <- v0

lw a2,36(sp) 		#a2 <- height

jal doAdjust
lw v0,32(sp) 		#v0 <- ant(x*)
					#en los casos que muevo V0 tengo que volver a cargarlo para devolver el puntero al array, si no devuelvo *y.

lw gp,16(sp)
lw fp,20(sp)
lw ra,24(sp)
addiu sp,sp,32
jr ra
.end step_south


.text
.align 2 
.ent step_east

step_east:
.frame sp,32,ra
.set noreorder
.cpload t9
.set reorder

addiu sp,sp,-32
.cprestore 16
sw fp,20(sp)
sw ra,24(sp)
move fp,sp

sw a0,32(sp)
sw a1,36(sp)

lw v0,32(sp) 		#v0 <- ant(x*)
lw a1,0(v0)			#a1 <- x
addiu a1,a1,1 		#a1 <- a1(x)+1

move a0,v0 			#a0 <- v0(x*)

lw a2,36(sp) 		#a2 <- width

jal doAdjust

lw gp,16(sp)
lw fp,20(sp)
lw ra,24(sp)
addiu sp,sp,32
jr ra
.end step_east



.text
.align 2 
.ent step_west

step_west:
.frame sp,32,ra
.set noreorder
.cpload t9
.set reorder

addiu sp,sp,-32
.cprestore 16
sw fp,20(sp)
sw ra,24(sp)
move fp,sp

sw a0,32(sp)
sw a1,36(sp)

lw v0,32(sp) 		#v0 <- ant(x*)
lw a1,0(v0)			#a1 <- x
addiu a1,a1,-1 		#a1 <- a1(x)-1

move a0,v0 			#a0 <- v0(x*)

lw a2,36(sp) 		#a2 <- width
jal doAdjust

lw gp,16(sp)
lw fp,20(sp)
lw ra,24(sp)
addiu sp,sp,32
jr ra
.end step_west













