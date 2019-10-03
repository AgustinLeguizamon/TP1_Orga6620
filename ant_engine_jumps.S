#include <regdef.h>

.data
panicmsg: .asciiz "unknow orientation \n"

.text
.align 2
.ent decide

decide:
.frame fp,8,ra
.set noreorder
.cpload t9
.set reorder

addiu sp,sp,-8
sw gp,0(sp)
sw fp,4(sp)
move fp,sp

sw a0,8(sp)			#a0(d) -> Mem[8]
sw a1,12(sp)		#a1(go_left) -> Mem[12]
sw a2,16(sp) 		#a2(go_right) -> Mem[16]

lw v0,8(sp) 		#v0 <- d
li v1,1 			#v1 <- 1

beq v0,1,go_right 	#v0 == 1 ? go_right
lw v0,12(sp) 		#v0 <- Mem[12]=go_left
j end

go_right:
lw v0,16(sp) 		#v0 <- go_right

end:
lw gp,0(sp)
lw fp,4(sp)
addiu sp,sp,8
jr ra

.end decide




.text
.align 2
.globl new_orientation
.ent new_orientation

new_orientation:
.frame fp,40,ra
.set noreorder
.cpload t9
.set reorder

addiu sp,sp,-40
sw gp,24(sp)
sw fp,28(sp)
sw ra,32(sp)
move fp,sp

sw a0,40(sp) 		#ao(orientation) -> Mem[40]
sw a1,44(sp) 		#a1(rule) -> Mem[44]

lw v0,40(sp) 		#v0 <- orientation
lw a0,44(sp) 		#a0 <- rule

case_north:
beqz v0,north 		#v0 == 0 ? north

case_south:
li v1,1 			
beq v0,v1, south 	#v0 == v1(1) ? south

case_east:
li v1,2
beq v0,v1, east 	#v0 == v1(2) ? east

case_west:
li v1,3
beq v0,v1, west 	#v0 == v1(3) ? west

default:
la a0, panicmsg 	#load address ao <- panicmsg*
jal doPanic

north:
li a1,3 			
li a2,2
j bdecide

south:
li a1,2
li a2,3
j bdecide

east:
move a1,zero
li a2,1
j bdecide

west:
li a1,1
move a2,zero
j bdecide

bdecide:
jal decide
sw v0,16(sp) 		# v0 -> Mem[16]=updated_orientation

lw gp,24(sp)
lw fp,28(sp)
lw ra,32(sp)
addiu sp,sp,40
jr ra

.end new_orientation



.text
.align 2
.globl move_forward
.ent move_forward

move_forward:
.frame fp,32,ra
.set noreorder
.cpload t9
.set reorder

addiu sp,sp,-32
sw gp,16(sp)
sw fp,20(sp)
sw ra,24(sp)
move fp,sp

sw a0,32(sp)		#a0(ant*) -> Mem[32]
sw a1,36(sp) 		#a1(width) -> Mem[36]
sw a2,40(sp)		#a2(height) -> Mem[40]

lw v0,32(sp) 		#v0 <- ant*
lw v0,8(v0) 		#v0 <- ant[8] = o

mf_case_north:
beqz v0, mf_north 	#v0 == 0 ? mf_north	

mf_case_south:
li v1,1 			#v1 <- 1
beq v0,v1,mf_south 	#v0 == v1 ? mf_south

mf_case_east:
li v1,2 			
beq v0,v1,mf_east 	#v0 == v1 ? mf_east 	

mf_case_west:
li v1,3 			#v1 <- 3
beq v0,v1,mf_west 	#v0 == v1 ? mf_west

mf_default:
la a0, panicmsg		#load address a0 <- panicmsg
jal doPanic 		

mf_north:
lw v0,32(sp) 		#v0 <- ant(x*)
lw a1,4(v0)			#a1 <- y
addiu a1,a1,-1 		#a1 <- a1(y)-1

addiu v0,v0,4		#v0 <- ant+4(y*)
move a0,v0 			#a0 <- v0

lw a2,40(sp) 		#a2 <- height
j adjust

mf_south:
lw v0,32(sp) 		#v0 <- ant(x*)
lw a1,4(v0)			#a1 <- y
addiu a1,a1,1 		#a1 <- a1(y)+1

addiu v0,v0,4		#v0 <- ant+4(y*)
move a0,v0 			#a0 <- v0(y*)

lw a2,40(sp) 		#a2 <- height
j adjust

mf_east:
lw v0,32(sp) 		#v0 <- ant(x*)
lw a1,0(v0)			#a1 <- x
addiu a1,a1,1 		#a1 <- a1(x)+1

move a0,v0 			#a0 <- ant(x*)

lw a2,36(sp) 		#a2 <- width
j adjust


mf_west:
lw v0,32(sp) 		#v0 <- ant(x*)
lw a1,0(v0)			#a1 <- x
addiu a1,a1,-1 		#a1 <- a1(x)-1

move a0,v0 			#a0 <- ant(x*)

lw a2,36(sp) 		#a2 <- width
j adjust

adjust:
jal doAdjust
lw v0,32(sp) 		#v0 <- ant

mf_end:
lw gp,16(sp)
lw fp,20(sp)
lw ra,24(sp)
addiu sp,sp,32 		
jr ra

.end move_forward
