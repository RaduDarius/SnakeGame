.586
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Exemplu proiect desenare",0
area_width EQU 640
area_height EQU 480
area DD 0

counter DD 0 ; numara evenimentele de tip timer
counterStart DD 0 ; numara evenimentele dupa ce s-a apasat start
counterFood DD 0 ; numara evenimentele dupa ce s-a afisat mancarea
counterObst DD 0 ; numara evenimentele dupa ce s-a afisat un obstacol

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

lung_chenar EQU 606
latime_chenar EQU 343
color_chenar EQU 008000h

x_start EQU	20
y_start EQU 50
color_button EQU 008000h
x_pause EQU 90
y_pause EQU 50

const_mancare_x DD 30
const_mancare_y DD 17
score DD 0

snake_size EQU 20
snake_on DB 0
snake_paused DB 0

obst_on DD 0
obst_score DD 0
x_obstacol DD 0
y_obstacol DD 0

x_vect_obstacole DD 1000 DUP(0)
y_vect_obstacole DD 1000 DUP(0)
num_obst DD 0

x_mancare DD 0
y_mancare DD 0

x_snake dd 20
y_snake dd 160

x_vect_snake DD 1000 DUP(0)
y_vect_snake DD 1000 DUP(0)
index DD 0
num_snake DD 0

contor DD 0
y_Store DD 0
x_Store DD 0

direction DD 'D'

format db "%d ", 0

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

.code

determ_pozition macro x, y

	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	
endm

draw_point macro x, y, color

	determ_pozition x, y
	mov dword ptr[eax], color
	mov dword ptr[eax + 4], color
	mov dword ptr[eax + 8], color
	mov dword ptr[eax - 4], color
	mov dword ptr[eax - 8], color
	mov dword ptr[eax + 12], color
	mov dword ptr[eax - 12], color
	mov dword ptr[eax + area_width * 8], color
	mov dword ptr[eax + area_width * 4], color
	mov dword ptr[eax - area_width * 8], color
	mov dword ptr[eax - area_width * 4], color
	mov dword ptr[eax + area_width * 12], color
	mov dword ptr[eax - area_width * 12], color
	
	mov dword ptr[eax + area_width * 4 + 4], color
	mov dword ptr[eax + area_width * 4 - 4], color
	mov dword ptr[eax - area_width * 4 + 4], color
	mov dword ptr[eax - area_width * 4 - 4], color
	
endm

draw_line_horizontal macro x, y, len, color
local bucla_line
	determ_pozition x, y
	
	mov ecx, len
bucla_line:
	
	mov dword ptr[eax], color
	add eax, 4

	loop bucla_line

endm

draw_line_vertical macro x, y, len, color
local bucla_line
	determ_pozition x, y
	
	mov ecx, len
bucla_line:
	
	mov dword ptr[eax], color
	add eax, area_width * 4

	loop bucla_line

endm

draw_obstacol macro x, y, color
local for1

	mov eax, y
	mov y_Store, eax
	mov ecx, 20
for1:
	mov contor, ecx
	draw_line_horizontal x, y, 20, color
	mov ecx, contor
	inc y
	loop for1
	
	mov eax, y_Store
	mov y, eax
	
endm

draw_chenar macro
	draw_line_horizontal 17, 117, lung_chenar, color_chenar
	draw_line_horizontal 17, 118, lung_chenar, color_chenar
	draw_line_horizontal 17, 119, lung_chenar, color_chenar
	
	draw_line_vertical 17, 119, latime_chenar, color_chenar
	draw_line_vertical 18, 119, latime_chenar, color_chenar
	draw_line_vertical 19, 119, latime_chenar, color_chenar
	
	draw_line_vertical 620, 119, latime_chenar, color_chenar
	draw_line_vertical 621, 119, latime_chenar, color_chenar
	draw_line_vertical 622, 119, latime_chenar, color_chenar
	
	draw_line_horizontal 17, 460, lung_chenar, color_chenar
	draw_line_horizontal 17, 461, lung_chenar, color_chenar
	draw_line_horizontal 17, 462, lung_chenar, color_chenar
endm

draw_button_start macro

	draw_line_horizontal x_start, y_start, 60, color_button
	draw_line_vertical x_start, y_start, 30, color_button
	
	draw_line_horizontal x_start, y_start+30, 60, color_button
	draw_line_vertical x_start+60, y_start, 30, color_button
	
	make_text_macro 'S', area, x_start+5, y_start+5
	make_text_macro 'T', area, x_start+15, y_start+5
	make_text_macro 'A', area, x_start+25, y_start+5
	make_text_macro 'R', area, x_start+35, y_start+5
	make_text_macro 'T', area, x_start+45, y_start+5

endm

draw_button_pause macro

	draw_line_horizontal x_pause, y_pause, 60, color_button
	draw_line_vertical x_pause, y_pause, 30, color_button
	
	draw_line_horizontal x_pause, y_pause+30, 60, color_button
	draw_line_vertical x_pause+60, y_pause, 30, color_button
	
	make_text_macro 'P', area, x_pause+5, y_pause+5
	make_text_macro 'A', area, x_pause+15, y_pause+5
	make_text_macro 'U', area, x_pause+25, y_pause+5
	make_text_macro 'S', area, x_pause+35, y_pause+5
	make_text_macro 'E', area, x_pause+45, y_pause+5

endm

draw_snake macro x, y, color
local bucla
	
	mov eax, y
	mov y_Store, eax
	mov ecx, snake_size
bucla:
	mov contor, ecx
	draw_line_horizontal x, y, snake_size, color
	mov ecx, contor
	inc y
	loop bucla

	mov eax, y_Store
	mov y, eax
endm

shiftare_snake macro
local for1, salt
	mov ecx, num_snake
	dec ecx
	mov esi, index
	sub esi, 4
	cmp ecx, 0
	je salt
for1:
	mov eax, x_vect_snake[esi-4]
	mov x_vect_snake[esi], eax
	mov eax, y_vect_snake[esi-4]
	mov y_vect_snake[esi], eax
	sub esi, 4
	cmp esi, 0
	je salt
	loop for1
salt:
	mov eax, x_snake
	mov x_vect_snake[0], eax
	mov eax, y_snake
	mov y_vect_snake[0], eax
endm

kill_snake macro x, y
local for1, for2, salt, out_stergere
	mov snake_on, 0
	draw_snake x, y, 0FFFFFFh
	mov direction, 'D'
	mov x_snake, 20
	mov y_snake, 160
	mov ecx, num_snake
	mov esi, 0
for1:
	mov x_vect_snake[esi], 0
	mov y_vect_snake[esi], 0
	add esi, 4
	loop for1
	mov index, 0
	mov num_snake, 0
	mov score, 0
	
	draw_point x_mancare, y_mancare, 0FFFFFFh
	mov x_mancare, 0
	mov y_mancare, 0
	mov counterFood, 0
	
	cmp num_obst, 0
	je out_stergere
	
	mov ecx, num_obst
	dec ecx
	xor edx, edx
	mov eax, 4
	mul ecx
	mov esi, eax
	cmp ecx, 0
	je salt
	
for2: 	
	draw_obstacol x_vect_obstacole[esi], y_vect_obstacole[esi], 0FFFFFFh
	sub esi, 4
	cmp esi, 0
	je salt
	loop for2
	
salt:
	draw_obstacol x_vect_obstacole[0], y_vect_obstacole[0], 0FFFFFFh

out_stergere:
	
	mov num_obst, 0
	mov x_obstacol, 0
	mov y_obstacol, 0
	mov obst_on, 0
	mov counterObst, 0
	
	make_text_macro 'G', area, 200, 50
	make_text_macro 'A', area, 210, 50
	make_text_macro 'M', area, 220, 50
	make_text_macro 'E', area, 230, 50
	
	make_text_macro 'O', area, 250, 50
	make_text_macro 'V', area, 260, 50
	make_text_macro 'E', area, 270, 50
	make_text_macro 'R', area, 280, 50
	
endm

genereaza_mancare macro
local generare
generare:
	rdtsc
	xor edx, edx
	div const_mancare_x
	; mul edx, 20
	mov eax, edx
	xor edx, edx
	mov ebx, 20
	mul ebx
	add eax, 20
	add eax, 10
	mov x_mancare, eax
	
	rdtsc
	xor edx, edx
	div const_mancare_y
	mov eax, edx
	xor edx, edx
	mov ebx, 20
	mul ebx
	add eax, 120
	add eax, 10
	mov y_mancare, eax
	
	determ_pozition x_mancare, y_mancare
	cmp dword ptr[eax], 0FFFFFFFFh
	jne generare
	
	draw_point x_mancare, y_mancare, 0FFh
	mov counterFood, 0

endm

genereaza_obstacole macro
local generare
generare:
	rdtsc
	xor edx, edx
	div const_mancare_x
	; mul edx, 20
	mov eax, edx
	xor edx, edx
	mov ebx, 20
	mul ebx
	add eax, 20
	mov x_obstacol, eax
	
	rdtsc
	xor edx, edx
	div const_mancare_y
	mov eax, edx
	xor edx, edx
	mov ebx, 20
	mul ebx
	add eax, 120
	mov y_obstacol, eax
	
	determ_pozition x_obstacol, y_obstacol
	cmp dword ptr[eax], 0FFFFFFFFh
	jne generare
	
	add x_obstacol, 10
	add y_obstacol, 10
	determ_pozition x_obstacol, y_obstacol
	cmp dword ptr[eax], 0FFFFFFFFh
	jne generare
	
	sub x_obstacol, 10
	sub y_obstacol, 10
	
	draw_obstacol x_obstacol, y_obstacol, 008000h
	mov esi, num_obst
	mov eax, x_obstacol
	mov x_vect_obstacole[4*esi], eax
	mov eax, y_obstacol
	mov y_vect_obstacole[4*esi], eax
	inc num_obst
	
	mov counterObst, 0
	mov obst_on, 1

endm

verif_snake_position macro x, y, color
local bucla1, bucla2, salt, end_verif
	;determ_pozition x, y
	; in eax e pozitia unui colt al capului sarpelui
	; trebuie sa mergem in directia data de direction 
	; si sa verificam fiecare pixel daca e verde

	mov eax, y
	mov y_Store, eax

	mov eax, x
	mov x_Store, eax
	
	mov ecx, snake_size
bucla1:
	mov eax, x_Store
	mov x, eax
	mov contor, ecx
	mov ecx, snake_size
	bucla2:
		
		determ_pozition x, y
		cmp dword ptr [eax], color
		jne salt
		mov ebx, 1
		jmp end_verif
	salt:
		inc x
		loop bucla2
		
	mov ecx, contor
	inc y
	loop bucla1
	
	mov ebx, 0
end_verif:

	mov eax, x_Store
	mov x, eax
	
	mov eax, y_Store
	mov y, eax

endm

verif_snake_bite macro x, y
local for1, salt, endverif
	
	mov eax, x
	mov edx, y
	mov ecx, num_snake
	mov esi, 0
	mov ebx, 0
for1:
	cmp x_vect_snake[esi], eax
	jne salt
	cmp y_vect_snake[esi], edx
	jne salt
	mov ebx, 1
	jmp endverif
salt:
	add esi, 4
	loop for1
endverif:
endm

verif_start macro x, y
	
	mov eax, x
	mov ebx, y
	
	cmp eax, x_start
	jl button_fail
	
	cmp eax, x_start+60
	jg button_fail
	
	cmp ebx, y_start
	jl button_fail
	
	cmp ebx, y_start+30
	jg button_fail

endm

verif_pause macro x, y
local endverif
	mov eax, x
	mov ebx, y

	cmp eax, x_pause
	jl button_fail
	
	cmp eax, x_pause+60
	jg button_fail
	
	cmp ebx, y_pause
	jl button_fail
	
	cmp ebx, y_pause+30
	jg button_fail

endm

verif_tasta macro x
local tasta, not_a, not_d, not_w, not_s
	
	mov eax, x
	
	cmp eax, 'D'
	jne not_d
	mov direction, 'D'
	jmp tasta

	not_d:
	cmp eax, 'A'
	jne not_a
	mov direction, 'A'
	jmp tasta

	not_a:
	cmp eax, 'W'
	jne not_w
	mov direction, 'W'
	jmp tasta
	
	not_w:
	cmp eax, 'S'
	jne tasta
	mov direction, 'S'

tasta:
endm

; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click, 3 - s-a apasat o tasta)
; arg2 - x (in cazul apasarii unei taste, x contine codul ascii al tastei care a fost apasata)
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	cmp eax, 3
	jz evt_tasta
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:

	; [ebp+arg2] - x
	; [ebp+arg3] - y
	
	cmp snake_on, 1
	je after_start
	
	verif_start [ebp+arg2], [ebp+arg3]
	
	make_text_macro ' ', area, 200, 50
	make_text_macro ' ', area, 210, 50
	make_text_macro ' ', area, 220, 50
	make_text_macro ' ', area, 230, 50
	
	make_text_macro ' ', area, 250, 50
	make_text_macro ' ', area, 260, 50
	make_text_macro ' ', area, 270, 50
	make_text_macro ' ', area, 280, 50
	
	mov esi, index
	mov eax, x_snake
	mov x_vect_snake[ESI], eax
	mov eax, y_snake
	mov y_vect_snake[ESI], eax
	add index, 4
	inc num_snake
	
	draw_snake x_vect_snake[0], y_vect_snake[0], 0FF0000h
	cmp x_mancare, 0
	jne salt
	genereaza_mancare
salt:
	mov counterStart, 0
	mov snake_on, 1
after_start:
	verif_pause [ebp+arg2], [ebp+arg3]
	cmp snake_on, 1
	je paused
	jmp afisare_litere
paused:
	mov snake_on, 0
	jmp afisare_litere
	
evt_tasta:
	verif_tasta [ebp+arg2]
	jmp afisare_litere
	
button_fail:
	cmp snake_on, 1
	jne afisare_litere
	
evt_timer:
	inc counter
	inc counterStart
	inc counterFood
	cmp snake_on, 1
	jne afisare_litere
		
	cmp counterStart, 1
	jne afisare_litere
	
	cmp counterFood, 35
	jne food_ok 

	draw_point x_mancare, y_mancare, 0FFFFFFFFh
	genereaza_mancare
	
food_ok:
	; daca scorul e multiplu de 10, 
	; vom genera un obstacol random
	; acesta va ramane afisat pentru 50 u.t.
	
	cmp obst_on, 1
	jne obstacol
	cmp score, 5
	jl obstacol_fail
	mov eax, obst_score
	cmp score, eax
	je obstacol_fail
	mov eax, score
	xor edx, edx
	mov ebx, 5
	div ebx
	cmp edx, 0
	jne obstacol
	mov eax, score
	mov obst_score, eax
	mov obst_on, 0
obstacol:	
	cmp obst_on, 1
	je obstacol_fail
	cmp score, 5
	jl obstacol_fail
	mov eax, score
	xor edx, edx
	mov ebx, 5
	div ebx
	cmp edx, 0
	jne obstacol_fail
	mov eax, score
	mov obst_score, eax
	genereaza_obstacole
obstacol_fail:
	
	mov ecx, num_snake
	dec ecx
	mov esi, index
	sub esi, 4
	cmp ecx, 0
	je delete_just_head
	
delete_for1: 	
	draw_snake x_vect_snake[esi], y_vect_snake[esi], 0FFFFFFh
	sub esi, 4
	cmp esi, 0
	je delete_just_head
	loop delete_for1
	
delete_just_head:
	draw_snake x_vect_snake[0], y_vect_snake[0], 0FFFFFFh
	
	cmp direction, 'D'
	jne not_d
	add x_snake, snake_size
	jmp moving_snake
	not_d:
	cmp direction, 'A'
	jne not_a
	sub x_snake, snake_size
	jmp moving_snake
	not_a:
	cmp direction, 'W'
	jne not_w
	sub y_snake, snake_size
	jmp moving_snake
	not_w:
	add y_snake, snake_size
moving_snake:
	
	;verificam daca a calcat peste un camp interzis
	verif_snake_position x_snake, y_snake, 008000h
	cmp ebx, 1
	jne true_mov
	kill_snake x_snake, y_snake
	jmp afisare_litere
true_mov:
	verif_snake_bite x_snake, y_snake
	cmp ebx, 1
	jne true_mov2
	kill_snake x_snake, y_snake
	jmp afisare_litere
true_mov2:

	;verificam daca a mancat mancarea
	verif_snake_position x_snake, y_snake, 0FFh
	cmp ebx, 1
	jne true_food
	inc score
	inc num_snake
	add index, 4
	genereaza_mancare
true_food:

	;crestem snake ul
	shiftare_snake
	
	mov ecx, num_snake
	dec ecx
	mov esi, index
	sub esi, 4
	cmp ecx, 0
	je just_head
	
for1: 
	draw_snake x_vect_snake[esi], y_vect_snake[esi], 0FF0000h
	sub esi, 4
	cmp esi, 0
	je just_head
	loop for1
	
just_head:
	draw_snake x_vect_snake[0], y_vect_snake[0], 0FF0000h
	mov counterStart, 0
	
afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	
	; afisam valoarea score-ului curent (sute, zeci si unitati)	
	make_text_macro 'S', area, 480, 10
	make_text_macro 'C', area, 490, 10
	make_text_macro 'O', area, 500, 10
	make_text_macro 'R', area, 510, 10
	make_text_macro 'E', area, 520, 10
	
	mov ebx, 10
	mov eax, score
	; cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 560, 10
	; cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 550, 10
	; cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 540, 10
	
	;scriem un mesaj
	make_text_macro 'P', area, 60, 10
	make_text_macro 'R', area, 70, 10
	make_text_macro 'O', area, 80, 10
	make_text_macro 'I', area, 90, 10
	make_text_macro 'E', area, 100, 10
	make_text_macro 'C', area, 110, 10
	make_text_macro 'T', area, 120, 10
	
	make_text_macro 'L', area, 140, 10
	make_text_macro 'A', area, 150, 10
	
	make_text_macro 'A', area, 170, 10
	make_text_macro 'S', area, 180, 10
	make_text_macro 'A', area, 190, 10
	make_text_macro 'M', area, 200, 10
	make_text_macro 'B', area, 210, 10
	make_text_macro 'L', area, 220, 10
	make_text_macro 'A', area, 230, 10
	make_text_macro 'R', area, 240, 10
	make_text_macro 'E', area, 250, 10

	draw_chenar
	draw_button_start
	draw_button_pause

final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
