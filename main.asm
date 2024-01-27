section .text
	global main
	; stdio
	extern malloc
	extern snprintf

	; raylib
	extern BeginDrawing
	extern ClearBackground
	extern CloseWindow
	extern DrawRectangle
	extern DrawText
	extern EndDrawing
	extern InitWindow
	extern IsKeyDown
	extern MeasureText
	extern SetTargetFPS
	extern WindowShouldClose

main:
	push	rbp		; preserve old frame
	mov	rbp,	rsp	; create new frame
	sub	rsp,	80	; allocate bytes

	mov	QWORD [rbp-8],	250	; player 1 pos
	mov	QWORD [rbp-16], 250	; player 2 pos
	mov	QWORD [rbp-24],	390	; pong x
	mov	QWORD [rbp-32],	290	; pong y
	mov	QWORD [rbp-40],	10	; pong vx
	mov	QWORD [rbp-48],	8	; pong vy
	mov	BYTE  [rbp-49],	1	; paused
	mov	BYTE  [rbp-50],	0	; player 1 score
	mov	BYTE  [rbp-51],	0	; player 2 score
	mov	QWORD [rbp-72],	400	; text x pos

	mov	rdi,		64	; malloc for score buffer
	call	malloc
	mov	QWORD [rbp-64],	rax
	test	rax,	rax
	jnz	.windowinit

	mov	rdi,	60	; sys_exit
	mov	rsi,	-1	; exit code
	syscall

.windowinit:
	mov	rdi,	800	; width
	mov	rsi,	600	; height
	mov	rdx,	sTitle	; title
	call	InitWindow

	mov	rdi,	60	; fps
	call	SetTargetFPS

.mainloop:
	call	WindowShouldClose
	test	rax,	rax
	jnz	.close

	mov	rdi,	32	; key=KEY_SPACE
	call	IsKeyDown
	test	rax,	rax
	jz	.player1up
	mov	BYTE [rbp-49],	0

.player1up:
	cmp	QWORD [rbp-8], 10
	jl	.player1upN

	mov	rdi,	87	; key=KEY_W
	call	IsKeyDown
	test	rax,	rax
	jz	.player1upN
	sub	QWORD [rbp-8],	10

.player1upN:
	cmp	QWORD [rbp-8],	490
	jg	.player1downN

	mov	rdi,	83	; key=KEY_S
	call	IsKeyDown
	test	rax,	rax
	jz	.player1downN
	add	QWORD [rbp-8],	10

.player1downN:
	cmp	QWORD [rbp-16],	10
	jl	.player2upN

	mov	rdi,	73	; key=KEY_I
	call	IsKeyDown
	test	rax,	rax
	jz	.player2upN
	sub	QWORD [rbp-16],	10

.player2upN:
	cmp	QWORD [rbp-16],	490
	jg	.player2downN

	mov	rdi,	75	; key=KEY_K
	call	IsKeyDown
	test	rax,	rax
	jz	.player2downN
	add	QWORD [rbp-16],	10

.player2downN:
	; pong-top frame
	cmp	QWORD [rbp-32], 0
	jle	.invertpongvel0

	;pong-bottom frame
	cmp	QWORD [rbp-32],	580
	jge	.invertpongvel0

	jmp	.invertpongvel1

.invertpongvel0:
	mov	rax,	-1
	mul	QWORD [rbp-48]
	mov	[rbp-48],	rax

.invertpongvel1:
	;pong-left frame
	cmp	QWORD [rbp-24],	0
	jg	.pongrightcol
	inc	BYTE [rbp-51]
	jmp	.resetpongpos

.pongrightcol:
	;pong-right frame
	cmp	QWORD [rbp-24],	780
	jl	.checkpaddlecollision1
	inc	BYTE [rbp-50]
	jmp	.resetpongpos

.resetpongpos:
	mov	QWORD [rbp-24],	390	; pong x
	mov	QWORD [rbp-32],	290	; pong y
	mov	BYTE  [rbp-49], 1	; paused

.checkpaddlecollision1:
	cmp	QWORD [rbp-24],	40	; pong x
	jg	.checkpaddlecollision2

	mov	rax,	[rbp-32]	; pong y
	add	rax,	20
	cmp	rax,	[rbp-8]		; player 1 pos
	jl	.checkpaddlecollision2

	mov	rax,	[rbp-32]	; pong y
	sub	rax,	80
	cmp	rax,	[rbp-8]	; player 1 pos
	jg	.checkpaddlecollision2

	mov	QWORD [rbp-40],	15

.checkpaddlecollision2:
	cmp	QWORD [rbp-24],	740	; pong x
	jl	.movepong

	mov	rax,	[rbp-32]	; pong y
	add	rax,	20
	cmp	rax,	[rbp-16]	; player 2 pos
	jl	.movepong

	mov	rax,	[rbp-32]	; pong y
	sub	rax,	80
	cmp	rax,	[rbp-16]	; player 2 pos
	jg	.movepong

	mov	QWORD [rbp-40],	-15

.movepong:
	cmp	BYTE [rbp-49],	0
	jnz	.draw

	mov	rax,		[rbp-40]
	add	[rbp-24],	rax

	mov	rax,		[rbp-48]
	add	[rbp-32],	rax

.draw:
	mov	rdi,	[rbp-64]	; buffer ptr
	mov	rsi,	64		; max size
	mov	rdx,	sScoreText	; format
	movzx	rcx,	BYTE [rbp-50]		; player 1 score
	movzx	r8,	BYTE [rbp-51]		; player 2 score
	call snprintf

	mov	rdi,	[rbp-64]	; text
	mov	rsi,	40		; fontSize
	call	MeasureText

	shr	rax,	1
	mov	QWORD [rbp-72],	400
	sub	[rbp-72],	rax

call	BeginDrawing

	mov	rdi,	0xFFF5F5F5	; A8B8G8R8
	call	ClearBackground

	mov	rdi,	[rbp-64]	; text
	mov	rsi,	[rbp-72]	; posX
	mov	rdx,	0		; posY
	mov	rcx,	40		; fontSize
	mov	r8,	0xFF000000	; color
	call	DrawText

	; Player 1
	mov	rdi,	20		; posX
	mov	rsi,	[rbp-8]		; posY
	mov	rdx,	20		; width
	mov	rcx,	100		; height
	mov	r8,	0xFF000000	; Color
	call	DrawRectangle
	
	; Player 2
	mov	rdi,	760		; posX
	mov	rsi,	[rbp-16]	; posY
	mov	rdx,	20		; width
	mov	rcx,	100		; height
	mov	r8,	0xFF000000	; Color
	call	DrawRectangle

	; Pong
	mov	rdi,	[rbp-24]	; posX
	mov	rsi,	[rbp-32]	; posY
	mov	rdx,	20		; width
	mov	rcx,	20		; height
	mov	r8,	0xFF000000	; Color
	call	DrawRectangle

call	EndDrawing
	
	jmp	.mainloop

.close:
	call	CloseWindow

	mov	rax,	60	; sys_exit
	mov	rbx,	0	; exit code
	syscall			;

section .rodata
	sScoreText:	db '%d-%d', 0
	sTitle:		db 'Raylib Assembly Pong', 0