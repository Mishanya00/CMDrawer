include main.inc
include MainMenu.asm

.code
start:
	
	invoke SetConsoleTitle, offset szProgramVersion
	
	invoke SetWindowSize, MAX_WIDTH, MAX_HEIGHT
	
	invoke Main
	
	invoke ExitProcess, 0
	
Main proc	uses ebx ecx esi edi
	
	LOCAL hIn: DWORD
	LOCAL hOut: DWORD
	LOCAL nRead: DWORD
	LOCAL lpMode: DWORD
	
	mov byte ptr[szToDraw], 35
	
	invoke GetStdHandle, STD_INPUT_HANDLE
	mov hIn, eax
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov hOut, eax
	
	invoke GetConsoleWindow
	invoke ShowScrollBar, eax, SB_BOTH, FALSE
	invoke HideCursor
	
	invoke MenuCreate
	
	invoke SetConsoleMode, hIn, ENABLE_MOUSE_INPUT or ENABLE_EXTENDED_FLAGS or ENABLE_LINE_INPUT or ENABLE_ECHO_INPUT or ENABLE_PROCESSED_INPUT
	
	_DOLOOP:
	
		invoke ReadConsoleInput, hIn, offset ConsoleRecord, 1, addr nRead
		invoke KeyController, hIn, hOut
		
		jmp _DOLOOP
		
	Ret
Main endp

PutCursorToPos proc uses ebx esi edi xCor: DWORD, yCor: DWORD	
	
	mov ebx, yCor
	shl ebx, 16
	or ebx, xCor
	;-------------------------------
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	invoke SetConsoleCursorPosition, eax, ebx
	;------------------------------
	
	ret
PutCursorToPos endp

HideCursor proc uses ebx esi edi
	
	LOCAL ci: CONSOLE_CURSOR_INFO
	LOCAL hOut: DWORD
	
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov hOut, eax
	
	lea ebx, ci
	invoke GetConsoleCursorInfo, hOut, ebx
	
	mov ci.bVisible, 0
	
	invoke SetConsoleCursorInfo, hOut, ebx

	Ret
HideCursor endp

PlaySoundOnClick proc uses ecx esi edi lpFile:DWORD

	invoke PlaySound, lpFile, 0, SND_FILENAME or SND_ASYNC
	Ret
PlaySoundOnClick endp


ImportActionProc proc uses ecx esi edi



	Ret
ImportActionProc endp

ExportActionProc proc uses ecx esi edi



	Ret
ExportActionProc endp

SetWindowSize proc uses ebx esi edi wd:DWORD, ht:DWORD
	
	LOCAL hOut: DWORD
	
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov hOut, eax
	
	mov ebx, ht
	shl ebx, 16
	or ebx, wd
	
	invoke GetConsoleWindow
	invoke ShowWindow, eax,SW_MAXIMIZE
	
	invoke SetConsoleScreenBufferSize, hOut, ebx
	invoke SetConsoleWindowInfo, hOut, 1, offset srect
	
	Ret
SetWindowSize endp

DrawCell proc uses ebx ecx esi edi hOut: DWORD, dwCoord: DWORD
	
	lea esi, szBrushBuffer
	mov ebx, 0
	
	mov cx, word ptr[dwCoord]
	
	.while ebx < drawSize && cx <= WORKING_AREA_WIDTH
	
		mov al, byte ptr[szToDraw]
		mov byte ptr[esi], al
		inc ebx
		inc esi
		inc cx
		
	.endw
	
	mov byte ptr[esi], 0
	mov ebx, 0
	mov cx, word ptr[dwCoord+2]
	
	.while ebx < drawSize && cx <= WORKING_AREA_HEIGHT
		
		push ecx
		invoke SetConsoleCursorPosition, hOut, dwCoord
		invoke crt_printf, offset szBrushBuffer
		pop ecx
		
		inc ebx
		inc cx
		add dwCoord, 65536
	
	.endw

	Ret
DrawCell endp


KeyController proc uses ebx ecx esi edi hIn: DWORD, hOut: DWORD

	movzx eax, word ptr[ConsoleRecord.EventType]
				
	.if eax == 0
		
		fn crt_puts, "error"
		
	.endif
	
	.if eax == KEY_EVENT
		
	.elseif eax == MOUSE_EVENT
	
		.if ConsoleRecord.MouseEvent.dwButtonState == FROM_LEFT_1ST_BUTTON_PRESSED
		
			mov eax, ConsoleRecord.MouseEvent.dwMousePosition
			mov ebx, eax
			shr ebx, 16		; Y coord
			cwde			; X coord in ax

			.if ax > 0 && ax <= WORKING_AREA_WIDTH && bx > 2 && bx <= WORKING_AREA_HEIGHT
				
				invoke DrawCell, hOut, dword ptr[ConsoleRecord.MouseEvent.dwMousePosition]
			
			; FIRST ROW OF BRUSHES
				
			.elseif ax >= WORKING_AREA_WIDTH+3 && ax <= WORKING_AREA_WIDTH+6 && bx > 3 && bx < 6
			
				invoke PlaySoundOnClick, offset szPlayOnClick			
				mov byte ptr[szToDraw], exclBrush
				
			.elseif ax >= WORKING_AREA_WIDTH+8 && ax <= WORKING_AREA_WIDTH+11 && bx > 3 && bx < 6
			
				invoke PlaySoundOnClick, offset szPlayOnClick
				mov byte ptr[szToDraw], quoteBrush
				
			.elseif ax >= WORKING_AREA_WIDTH+13 && ax <= WORKING_AREA_WIDTH+16 && bx > 3 && bx < 6
			
				invoke PlaySoundOnClick, offset szPlayOnClick
				mov byte ptr[szToDraw], sharpBrush
				
			.elseif ax >= WORKING_AREA_WIDTH+18 && ax <= WORKING_AREA_WIDTH+21 && bx > 3 && bx < 6
			
				invoke PlaySoundOnClick, offset szPlayOnClick
				mov byte ptr[szToDraw], dollarBrush
				
			.elseif ax >= WORKING_AREA_WIDTH+23 && ax <= WORKING_AREA_WIDTH+26 && bx > 3 && bx < 6
			
				invoke PlaySoundOnClick, offset szPlayOnClick
				mov byte ptr[szToDraw], comAndBrush	
				
			.elseif ax >= WORKING_AREA_WIDTH+28 && ax <= WORKING_AREA_WIDTH+31 && bx > 3 && bx < 6
			
				invoke PlaySoundOnClick, offset szPlayOnClick
				mov byte ptr[szToDraw], zeroQuoteBrush	
			
			; SECOND ROW OF BRUSHES
				
			.elseif ax >= WORKING_AREA_WIDTH+3 && ax <= WORKING_AREA_WIDTH+6 && bx > 6 && bx < 9
			
				invoke PlaySoundOnClick, offset szPlayOnClick
				mov byte ptr[szToDraw], parenthOBrush
				
			.elseif ax >= WORKING_AREA_WIDTH+8 && ax <= WORKING_AREA_WIDTH+11 && bx > 6 && bx < 9
			
				invoke PlaySoundOnClick, offset szPlayOnClick
				mov byte ptr[szToDraw], parenthCBrush
				
			.elseif ax >= WORKING_AREA_WIDTH+13 && ax <= WORKING_AREA_WIDTH+16 && bx > 6 && bx < 9
			
				invoke PlaySoundOnClick, offset szPlayOnClick
				mov byte ptr[szToDraw], multiplBrush
				
			.elseif ax >= WORKING_AREA_WIDTH+18 && ax <= WORKING_AREA_WIDTH+21 && bx > 6 && bx < 9
			
				invoke PlaySoundOnClick, offset szPlayOnClick
				mov byte ptr[szToDraw], plusBrush
				
			.elseif ax >= WORKING_AREA_WIDTH+23 && ax <= WORKING_AREA_WIDTH+26 && bx > 6 && bx < 9
			
				mov byte ptr[szToDraw], commaBrush	
				invoke PlaySoundOnClick, offset szPlayOnClick
				
			.elseif ax >= WORKING_AREA_WIDTH+28 && ax <= WORKING_AREA_WIDTH+31 && bx > 6 && bx < 9
			
				mov byte ptr[szToDraw], minusBrush
				invoke PlaySoundOnClick, offset szPlayOnClick	
				
				
			; THIRD ROW OF BRUSHES
			
			.elseif ax >= WORKING_AREA_WIDTH+3 && ax <= WORKING_AREA_WIDTH+6 && bx > 9 && bx < 12
			
				mov byte ptr[szToDraw], dotBrush
				invoke PlaySoundOnClick, offset szPlayOnClick
				
			.elseif ax >= WORKING_AREA_WIDTH+8 && ax <= WORKING_AREA_WIDTH+11 && bx > 9 && bx < 12
			
				mov byte ptr[szToDraw], slashBrush
				invoke PlaySoundOnClick, offset szPlayOnClick
				
			.elseif ax >= WORKING_AREA_WIDTH+13 && ax <= WORKING_AREA_WIDTH+16 && bx > 9 && bx < 12
			
				mov byte ptr[szToDraw], colonBrush
				invoke PlaySoundOnClick, offset szPlayOnClick
				
			.elseif ax >= WORKING_AREA_WIDTH+18 && ax <= WORKING_AREA_WIDTH+21 && bx > 9 && bx < 12
			
				mov byte ptr[szToDraw], semicolonBrush
				invoke PlaySoundOnClick, offset szPlayOnClick
				
			.elseif ax >= WORKING_AREA_WIDTH+23 && ax <= WORKING_AREA_WIDTH+26 && bx > 9 && bx < 12
			
				mov byte ptr[szToDraw], lessBrush
				invoke PlaySoundOnClick, offset szPlayOnClick	
				
			.elseif ax >= WORKING_AREA_WIDTH+28 && ax <= WORKING_AREA_WIDTH+31 && bx > 9 && bx < 12
			
				mov byte ptr[szToDraw], equalBrush	
				invoke PlaySoundOnClick, offset szPlayOnClick			
			
			
			; FOURTH ROW OF BRUSHES
		
			.elseif ax >= WORKING_AREA_WIDTH+3 && ax <= WORKING_AREA_WIDTH+6 && bx > 12 && bx < 15
			
				mov byte ptr[szToDraw], moreBrush
				invoke PlaySoundOnClick, offset szPlayOnClick
				
			.elseif ax >= WORKING_AREA_WIDTH+8 && ax <= WORKING_AREA_WIDTH+11 && bx > 12 && bx < 15
			
				mov byte ptr[szToDraw], questionBrush
				invoke PlaySoundOnClick, offset szPlayOnClick
				
			.elseif ax >= WORKING_AREA_WIDTH+13 && ax <= WORKING_AREA_WIDTH+16 && bx > 12 && bx < 15
			
				mov byte ptr[szToDraw], atBrush
				invoke PlaySoundOnClick, offset szPlayOnClick
				
			.elseif ax >= WORKING_AREA_WIDTH+18 && ax <= WORKING_AREA_WIDTH+21 && bx > 12 && bx < 15
			
				mov byte ptr[szToDraw], squareOBrush
				invoke PlaySoundOnClick, offset szPlayOnClick
				
			.elseif ax >= WORKING_AREA_WIDTH+23 && ax <= WORKING_AREA_WIDTH+26 && bx > 12 && bx < 15
			
				mov byte ptr[szToDraw], backSlashBrush
				invoke PlaySoundOnClick, offset szPlayOnClick	
				
			.elseif ax >= WORKING_AREA_WIDTH+28 && ax <= WORKING_AREA_WIDTH+31 && bx > 12 && bx < 15
			
				mov byte ptr[szToDraw], squareCBrush
				invoke PlaySoundOnClick, offset szPlayOnClick	
		
			
			; FIFTH ROW OF BRUSHES
		
			.elseif ax >= WORKING_AREA_WIDTH+3 && ax <= WORKING_AREA_WIDTH+6 && bx > 15 && bx < 18
			
				mov byte ptr[szToDraw], birdBrush
				invoke PlaySoundOnClick, offset szPlayOnClick
				
			.elseif ax >= WORKING_AREA_WIDTH+8 && ax <= WORKING_AREA_WIDTH+11 && bx > 15 && bx < 18
			
				mov byte ptr[szToDraw], traitBrush
				invoke PlaySoundOnClick, offset szPlayOnClick
				
			.elseif ax >= WORKING_AREA_WIDTH+13 && ax <= WORKING_AREA_WIDTH+16 && bx > 15 && bx < 18
			
				mov byte ptr[szToDraw], braceOBrush
				invoke PlaySoundOnClick, offset szPlayOnClick
				
			.elseif ax >= WORKING_AREA_WIDTH+18 && ax <= WORKING_AREA_WIDTH+21 && bx > 15 && bx < 18
			
				mov byte ptr[szToDraw], directBrush
				invoke PlaySoundOnClick, offset szPlayOnClick
				
			.elseif ax >= WORKING_AREA_WIDTH+23 && ax <= WORKING_AREA_WIDTH+26 && bx > 15 && bx < 18
			
				mov byte ptr[szToDraw], braceCBrush
				invoke PlaySoundOnClick, offset szPlayOnClick	
				
			.elseif ax >= WORKING_AREA_WIDTH+28 && ax <= WORKING_AREA_WIDTH+31 && bx > 15 && bx < 18
			
				mov byte ptr[szToDraw], tildaBrush
				invoke PlaySoundOnClick, offset szPlayOnClick	
			
			
			; SIZE BUTTONS CHECKS
			
			.elseif ax >= WORKING_AREA_WIDTH+18 && ax <= WORKING_AREA_WIDTH+21 && bx > 20 && bx < 23
			
				mov byte ptr[drawSize], 1
				
			.elseif ax >= WORKING_AREA_WIDTH+23 && ax <= WORKING_AREA_WIDTH+26 && bx > 20 && bx < 23
			
				mov byte ptr[drawSize], 2	
				
			.elseif ax >= WORKING_AREA_WIDTH+28 && ax <= WORKING_AREA_WIDTH+31 && bx > 20 && bx < 23
			
				mov byte ptr[drawSize], 3
				
			.elseif ax >= WORKING_AREA_WIDTH+18 && ax <= WORKING_AREA_WIDTH+21 && bx > 23 && bx < 26
			
				mov byte ptr[drawSize], 4
				
			.elseif ax >= WORKING_AREA_WIDTH+23 && ax <= WORKING_AREA_WIDTH+26 && bx > 23 && bx < 26
			
				mov byte ptr[drawSize], 5	
				
			.elseif ax >= WORKING_AREA_WIDTH+28 && ax <= WORKING_AREA_WIDTH+31 && bx > 23 && bx < 26
			
				mov byte ptr[drawSize], 6
				
			.elseif ax >= WORKING_AREA_WIDTH+18 && ax <= WORKING_AREA_WIDTH+21 && bx > 26 && bx < 29
			
				mov byte ptr[drawSize], 7
								
			.elseif ax >= WORKING_AREA_WIDTH+23 && ax <= WORKING_AREA_WIDTH+26 && bx > 26 && bx < 29
			
				mov byte ptr[drawSize], 8
								
			.elseif ax >= WORKING_AREA_WIDTH+28 && ax <= WORKING_AREA_WIDTH+31 && bx > 26 && bx < 29
			
				mov byte ptr[drawSize], 8
			
											
			; SPECIAL BUTTONS CHECKS
			
			; CLEAR	
			.elseif ax >= WORKING_AREA_WIDTH+3 && ax <= WORKING_AREA_WIDTH+16 && bx > WORKING_AREA_HEIGHT-3 && bx < WORKING_AREA_HEIGHT+1
			
				invoke PlaySoundOnClick, offset szPlayOnClick
				invoke MenuCreate
				invoke SetConsoleMode, hIn, ENABLE_MOUSE_INPUT or ENABLE_EXTENDED_FLAGS or ENABLE_LINE_INPUT or ENABLE_ECHO_INPUT or ENABLE_PROCESSED_INPUT
				
			; EXPORT
			.elseif ax >= WORKING_AREA_WIDTH+18 && ax <= WORKING_AREA_WIDTH+31 && bx > WORKING_AREA_HEIGHT-3 && bx < WORKING_AREA_HEIGHT+1
			
				invoke PlaySoundOnClick, offset szPlayOnClick
			
			; IMPORT	
			.elseif ax >= WORKING_AREA_WIDTH+18 && ax <= WORKING_AREA_WIDTH+31 && bx > WORKING_AREA_HEIGHT-6 && bx < WORKING_AREA_HEIGHT-3
			
				invoke PlaySoundOnClick, offset szPlayOnClick
			
			; ERASER	
			.elseif ax >= WORKING_AREA_WIDTH+3 && ax <= WORKING_AREA_WIDTH+9 && bx >= WORKING_AREA_HEIGHT-6 && bx < WORKING_AREA_HEIGHT-3
				
				mov byte ptr[szToDraw], eraseBrush
				invoke PlaySoundOnClick, offset szPlayOnClick
					
			.endif
			
			
			;		invoke Sleep, densityBrush  Idea for regulation of brushes' density
			
		.endif
		
	.endif

	Ret
KeyController endp

end start