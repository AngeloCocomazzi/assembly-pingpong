title pingpong;

acapo macro

mov dl,0dh
mov ah,02
int 21h

endm

stampa macro msg

lea dx,msg
mov ah,09
int 21h

endm


riga_colonna macro ;stampa pedina ad una determinata riga/colonna

	mov dh,riga
	mov dl,colonna
	
	mov ah,02
	int 10h
	
	;mov bh,02h
	mov bl,111b
	mov al,down
	
	mov cx,1
	mov ah,09h
	int 10h
	
endm

riga_colonna_pc macro ;stampa pedina ad una determinata riga/colonna

	mov dh,riga_pc
	mov dl,colonna_pc
	
	mov ah,02
	int 10h
	
	;mov bh,02h
	mov bl,111b
	mov al,178d
	
	mov cx,1
	mov ah,09h
	int 10h
	
endm

data segment

tocco DB 0

horz DB 0
vert DB 0

riga DB 12
colonna DB 40

riga_pc DB 12
colonna_pc DB 65

down DB 51

movimento DB 3

moltip DB 8

passaggio DB 0

unita DB 0
decine DB 0
centinaia DB 0


goal_pc DB 0
goal_utente DB 0


; ora DB 0

; minuti DB 0

; secondi DB 0
	
millis DB 0

ritardo DB 0

reset DB 0

goal_var DB "   $"

msg_intro DB "Il risultato finale e' : $"

msg_spazio DB "  -  $"

msg_mouse DB "Installare il mouse per giocare ! $"
msg_mouse1 DB "Mouse correttamente installato ! $"

continuare DB "Premere un tasto per continutare... $"

msg1  DB "   ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  $ "															
msg2  DB "|                                                                              | $ "
msg3  DB "|                                                                              | $ "
msg4  DB "|                                                                              | $ "
msg5  DB "|                                                                              | $ "
msg6  DB "|                                                                              | $ "
msg7  DB "|                                                                              | $ "
msg8  DB "|                                                                              | $ "
msg9  DB "|                                                                              | $ "
msg10 DB "|                                                                              | $ "
msg11 DB "|                                                                              | $ "
msg12 DB "|                                                                              | $ "
msg13 DB "|                                                                              | $ "
msg14 DB "|                                                                              | $ "
msg15 DB "|                                                                              | $ "
msg16 DB "|                                                                              | $ "
msg17 DB "|                                                                              | $ "
msg18 DB "|                                                                              | $ "
msg19 DB "|                                                                              | $ "
msg20 DB "|                                                                              | $ "
msg21 DB "|                                                                              | $ "
msg22 DB "|                                                                              | $ "
msg23 DB "|                                                                              | $ "
msg24 DB " ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||    $ "

data ends

assume cs:code, ds:data
code segment

inizio: mov ax,data
        mov ds,ax
		
		;;set resolution	
		mov al,03;00,01 risoluzione bassa - 02,03 attuale - 04,05 bassa grassettata - 06 quasi media grassettata -
		mov ah,00
		int 10h
		
		;call check_mouse
		
		call set_bound
		
		call stampa_mask ;stampa il campo da gioco
		
		call refresh_risultato ;stampa il risultato 0 a 0
		
		
menu:

	jmp importa_cx
	
rinizio_partita:
		;call refresh_risultato
		call reset_variabili
		jmp inizio
		

importa_cx:
	
	mov cx,3
	
	;count down inizio gioco
	
countdown:
		
		push cx

		riga_colonna
		
		dec down

		call delay1sec

		pop cx
		
		
loop countdown
	
	;inizio gioco
	
	mov down,111d ;posizionamento pallina "o"

	riga_colonna  ;posizione pallina centrale 12 riga x 40 colonna
	
	mov cx,9999h
	
	

ciclo:
		push cx

		call delay

		call pos_mouse
	
		call gestione_bot
		
		call pallina

		pop cx
				
				
		cmp reset,1
		jae rinizio_partita
		
	loop ciclo

fineif1:
		mov ah,04ch
        int 21h
		

check_mouse proc	;non implementata

push ax bx

mov ax,00h
int 33h

cmp ax,0
je non_installato

mov bx,1
neg bx

cmp ax,bx
je installato

jmp fine_proced


installato:
			stampa msg_mouse1
			
			stampa continuare
			
			mov ah,01
			int 21h
			
			mov al,03;00,01 risoluzione bassa - 02,03 attuale - 04,05 bassa grassettata - 06 quasi media grassettata -
			mov ah,00
			int 10h
			
			jmp fine_proced
			
non_installato:

			stampa msg_mouse
			
			mov ah,04ch
			int 21h


fine_proced:

pop bx ax

ret
endp
		



stampa_mask proc

	stampa msg1

	acapo
	stampa msg2

	acapo
	stampa msg3

	acapo
	stampa msg4

	acapo
	stampa msg5

	acapo
	stampa msg6

	acapo
	stampa msg7

	acapo
	stampa msg8

	acapo
	stampa msg9

	acapo
	stampa msg10

	acapo
	stampa msg11

	acapo
	stampa msg12

	acapo
	stampa msg13

	acapo
	stampa msg14

	acapo
	stampa msg15

	acapo
	stampa msg16

	acapo
	stampa msg17

	acapo
	stampa msg18

	acapo
	stampa msg19

	acapo
	stampa msg20

	acapo
	stampa msg21

	acapo
	stampa msg22

	acapo
	stampa msg23

	acapo
    stampa msg24
	
	riga_colonna_pc
ret
endp


refresh_risultato proc
	
	;stampa n goal utente
	
	mov al,goal_utente
	mov passaggio,al
	call dividi_mosse
	
	push ax bx cx dx
			
	mov dh,0			;posizione puntatore
	mov dl,0			;in alto a destra
	
	;mov bh,03			;set puntatore
	mov ah,02h
	int 10h
	
			
	lea dx,goal_var   ;stampa stringa
	mov ah,9
	int 21h
	
	pop dx cx bx ax
	
	;stampa n goal pc
	
	mov al,goal_pc
	mov passaggio,al
	call dividi_mosse
	
	push ax bx cx dx
	
	
	mov dh,23			;posizione puntatore ;riga
	mov dl,77			;in alto a destra    ;colonna
	
	;mov bh,03			;set puntatore
	mov ah,02h
	int 10h
	
			
	lea dx,goal_var   ;stampa stringa
	mov ah,9
	int 21h
	
	pop dx cx bx ax
	
			
	cmp goal_pc,9
	jae finegioco
	
	cmp goal_utente,9
	jae finegioco
	; cmp goal_utente,9
	; ja vinto
	jmp fine_pro
	
finegioco:
		mov ah,04ch
		int 21h
		
	; cmp goal_pc,9
	; ja vinto
	
	; jmp fine_pro
	
; vinto:
	
	; mov al,02
	; mov ah,00h
	; int 10h				;clear schermo
	
	; stampa msg_intro
	
	; mov dl,goal_utente
	; mov ah,02
	; int 21h
	
	; stampa msg_spazio
	
	; mov dl,goal_pc
	; mov ah,02
	; int 21h
	
	
	; mov ah,04ch
	; int 21h
	
fine_pro:
ret
endp

get_ora proc

	push ax bx cx dx
	
	mov ah,2Ch
	int 21h ;get system time;CH = ora (0-23)CL = minuti (0-59) DH = secondi (0-59) DL = 1/100 di secondo (0-99)

	; mov ora,ch

	; mov minuti,cl

	; mov secondi,dh
	
	mov millis,dl
	
	pop dx cx bx ax
	
	
ret
endp




reset_variabili proc

	mov horz,0
	mov vert,0

	mov riga,12
	mov colonna,40

	mov down,51
	
	cmp movimento,1
	je palla_pc1
	
	cmp movimento,3
	je palla_pc
	
	cmp movimento,0
	je palla_player1
	
	cmp movimento,2
	je palla_player
	
	jmp continua_p
	
	
	palla_pc1:
	
		mov movimento,0
		jmp continua_p
	
	palla_pc:
	
		mov movimento,2
		jmp continua_p
			
	palla_player1:
	
		mov movimento,1
		jmp continua_p
		
	palla_player:
	
		mov movimento,3
		
		
continua_p:

		mov passaggio,0

		mov unita,0
		mov decine,0
		mov centinaia,0

		mov reset,0
		
		mov tocco,0
		
		mov riga_pc,12
		mov colonna_pc,65

ret
endp
		

set_bound proc	
	;;set cursor shape 
	
	mov ch,00 ;CH = Scan Row Start
	mov cl,00;CL = Scan Row End
	mov cx,2607h;set invisible cursor
	;mov cx,0607h;set normal cursor
	mov ah,01
	int 10h
	
	mov ax,01h  ;show mouse cursor
	int 33h
	
	mov ax,07h  ;Set Mouse Horizontal Min/Max Position
	mov cx,0015
	mov dx,0315
	int 33h
	
	mov ax,08h ; Set Mouse Vertical Min/Max Position
	mov cx,0015
	mov dx,0180
	int 33h

ret
endp		

		  
pos_mouse proc

	mov ax,03h
	int 33h
	
	mov horz,cl
	mov vert,dl;80 x 30
	
	
	mov al,vert;divisione per griglia mouse
	mov ah,0
	div moltip
	mov vert,al
	
	
	mov al,horz;divisione per griglia mouse
	mov ah,0
	div moltip
	mov horz,al

	cmp tocco,1 ;vedo se ho gia' toccato la pallina in precedenza
	je continua	
	
	;confronto per restituire la pallina indietro
	mov al,riga
	cmp vert,al
	je confonta_horz
	
	mov al,riga
	sub al,1
	cmp vert,al
	je confonta_horz
	
	mov al,riga
	add al,1
	cmp vert,al
	je confonta_horz
	
	jmp fine_p
	
confonta_horz:
	
	mov al,colonna
	sub al,1
	cmp horz,al
	je inverti
	
	mov al,colonna
	add al,1
	cmp horz,al
	je inverti
	
	mov al,colonna
	cmp horz,al
	je inverti
	
continua:
	jmp fine_p
	
inverti:			

	cmp movimento,0
	je m0
	
	cmp movimento,1
	je m1
	
	cmp movimento,2
	je m2
	
	cmp movimento,3
	je m3
	
	jmp fine_p
	
	m0:
		mov movimento,1
		mov tocco,1
		jmp fine_p

	m1:
		mov movimento,0
		mov tocco,1
		jmp fine_p

	m2:
		mov movimento,3
		mov tocco,1
		jmp fine_p

	m3:
		mov movimento,2
		mov tocco,1
		jmp fine_p

fine_p:

ret
endp


canc_car proc;cancella pallina

push ax cx dx
	
	mov dh,riga
	mov dl,colonna
	;mov bh,02
	mov ah,02h
	int 10h
		
	mov al,' '
       
    mov cx,1   
    mov ah,09h
    int 10h

pop dx cx ax

ret
endp

canc_car_pc proc ;cancella pedina pc

push ax cx dx
	
	mov dh,riga_pc
	mov dl,colonna_pc
	;mov bh,02
	mov ah,02h
	int 10h
		
	mov al,' '
       
    mov cx,1   
    mov ah,09h
    int 10h

pop dx cx ax

ret
endp



gestione_bot proc


	call canc_car_pc
	
	mov al,colonna
	cmp colonna_pc,al ;salta il movimento se la pallina e' dietro il cursore del pc
	jb prosegui
	
	cmp movimento,0 ;alto_dx
	je sottrai_riga
	
	cmp movimento,1 ;alto_sx
	je sottrai_riga
	
	cmp movimento,2 ;basso_dx
	je aggiungi_riga
	
	cmp movimento,3 ;basso_sx
	je aggiungi_riga
	
	jmp prosegui
	
sottrai_riga:
	; mov al,riga
	; sub al,1
	; mov riga_pc,al
	call get_ora
	cmp millis,87;tolleranza per i movimenti altimenti sarebbe imbattibile
	ja prosegui
	
	dec riga_pc

	cmp riga_pc,0
	jbe minore_0

	jmp prosegui
	
minore_0:

	mov riga_pc,1
	
	jmp prosegui
	
aggiungi_riga:
	; mov al,riga
	; add al,1
	; mov riga_pc,al
	call get_ora
	cmp millis,87;tolleranza per i movimenti altimenti sarebbe imbattibile
	ja prosegui
	
	inc riga_pc

	cmp riga_pc,23
	jae maggiore_80

	jmp prosegui

maggiore_80:

	mov riga_pc,22

prosegui:

	riga_colonna_pc
	
	
	mov al,riga
	cmp riga_pc,al
	je confronta_col
	
	mov al,riga
	add al,1
	cmp riga_pc,al
	je confronta_col
	
	mov al,riga
	sub al,1
	cmp riga_pc,al
	je confronta_col
	
	jmp fine_proc
	
confronta_col:
		
		mov al,colonna
		add al,1
		cmp colonna_pc,al
		je inverti1

		mov al,colonna
		cmp colonna_pc,al
		je inverti1
		
		jmp fine_proc
		
inverti1:

	cmp movimento,0;alto_dx
	je mov0
	
	; cmp movimento,1;alto_sx
	; je mov1
	
	cmp movimento,2;basso_dx
	je mov2
	
	; cmp movimento,3;basso_sx
	; je mov3
	
	jmp fine_proc
	
	mov0:
		mov movimento,1
		mov tocco,0
		jmp fine_proc

	; mov1:
		; mov movimento,0
		; mov tocco,0
		; jmp fine_proc

	mov2:
		mov movimento,3
		mov tocco,0
		jmp fine_proc

	; mov3:
		; mov movimento,2
		; mov tocco,0
		; jmp fine_proc

fine_proc:
ret
endp



	  
pallina proc			;cmp movimento,0
						;je alto_dx
	
						; cmp movimento,1
						; je alto_sx
						
						; cmp movimento,2
						; je basso_dx
						
						; cmp movimento,3
						; je basso_sx

	cmp movimento,0
	je alto_dx
	
	cmp movimento,1
	je alto_sx
	
	cmp movimento,2
	je basso_dx
	
	cmp movimento,3
	je basso_sx


alto_dx:
		
		call canc_car
		
		inc colonna
		
		dec riga
		
		call set_movimento
		
		riga_colonna

		jmp fine_pallina
		
alto_sx:

		call canc_car
		
		dec colonna
		
		dec riga
		
		call set_movimento
		
		riga_colonna
		
		jmp fine_pallina

basso_dx:

		call canc_car

		inc riga
		
		inc colonna
		
		call set_movimento
		
		riga_colonna
		
		jmp fine_pallina

basso_sx:

		call canc_car
		
		inc riga
		
		dec colonna
		
		call set_movimento
		
		riga_colonna
		
		jmp fine_pallina
		

fine_pallina:

ret
endp


set_movimento proc      ;cmp movimento,0
						;je alto_dx
	
						; cmp movimento,1
						; je alto_sx
						
						; cmp movimento,2
						; je basso_dx
						
						; cmp movimento,3
						; je basso_sx

	cmp colonna,0
	je colonna_negativa ;controlla la colonna e attribuisce il goal
	
	cmp colonna,80
	je colonna_positiva
	
	cmp riga,23; controlla i marigini esterni e da rimbalzare la pallina
	je riga_negativa
	
	cmp riga,0; controlla i marigini esterni e da rimbalzare la pallina
	je riga_positiva
	
	jmp fine
	
	colonna_negativa:
		
		inc goal_pc
		
		inc reset
	
		jmp fine
		
		
	colonna_positiva:
		
		inc goal_utente
		
		inc reset
	
		jmp fine
	
	riga_negativa:
			
		cmp movimento,2;basso_dx
		je altodx
		
		cmp movimento,3;basso_sx
		je altosx
		
		jmp fine
		
		altosx:

			mov movimento,1
			
			dec riga
			inc colonna
			
			jmp fine
			
		altodx:
			
			mov movimento,0
			
			dec riga
			dec colonna

			jmp fine
		
	riga_positiva:
		
		cmp movimento,0;alto_dx
		je bassodx
		
		cmp movimento,1;alto_sx
		je bassosx
		
		jmp fine

		bassosx:
			
			mov movimento,3
			
			inc colonna
		
			inc riga
			
			jmp fine
			
		bassodx:
			
			mov movimento,2
			
			dec colonna
			inc riga
			
			jmp fine


fine:

ret
endp


delay proc

mov al,goal_pc

cmp goal_utente,al
jb delay_pc

delay_utente:

	mov ah,0
	mov al,60
	mov dh,0
	mov dl,goal_utente
	inc dl
	div dl
	
	mov ritardo,al
	
	jmp ritardo_p
	
delay_pc:

	mov ah,0
	mov al,60
	mov dh,0
	mov dl,goal_pc
	inc dl
	div dl
	
	mov ritardo,al

ritardo_p:
	
push cx dx

mov cx,1000h
ciclolv22: 
		push cx
		mov ch,0
		mov cl,ritardo
	ciclolv12:
		nop ;250 nano secondi di delay
		loop ciclolv12
	pop cx
loop ciclolv22

pop dx cx

	
finedelay:
ret 
endp


delay1sec proc

	push cx dx
	
	mov cx,2000h
	ciclo1sec: 
			push cx
			mov cx,90h
		ciclo1sec2:
			nop ;250 nano secondi di delay
			loop ciclo1sec2
		pop cx
	loop ciclo1sec
	
	pop dx cx
	
ret
endp


dividi_mosse proc
	
	push ax bx cx dx di bp 
	
	mov di,0
	
	cmp passaggio,9
	ja maggiore_di_9
	
	lea bx,goal_var
	
	mov al,30h
	mov[bx+di],al
	inc di
	mov[bx+di],al
	inc di
	mov al,passaggio
	add al,30h
	mov[bx+di],al

	jmp fine_macro
	
	
maggiore_di_9:
	mov ah,0
	mov al,passaggio
	mov dh,0
	mov dl,10
	div dl
	mov decine,al
	mov unita,ah
	
	cmp decine,9
	ja maggiore_di_99
	
	lea bx,goal_var
	
	mov al,30h
	mov[bx+di],al
	inc di
	
	mov al,decine
	add al,30h
	mov[bx+di],al
	inc di
	
	mov al,unita
	add al,30h
	mov[bx+di],al

	
	jmp fine_macro
	
maggiore_di_99:
	
	;mov bl,decine
	
	;mov secondi,bl
	mov ah,0
	mov al,decine
	mov dh,0
	mov dl,10
	div dl 

	mov centinaia,al
	mov decine,ah
	
	cmp centinaia,9
	ja maggiore_di_999
	
	lea bx,goal_var
	
	mov al,centinaia
	add al,30h
	mov[bx+di],al
	inc di
	
	mov al,decine
	add al,30h
	mov[bx+di],al
	inc di
	
	mov al,unita
	add al,30h
	mov[bx+di],al
	inc di
	
	jmp fine_macro


maggiore_di_999:

	lea bx,goal_var
	
	mov al,39h
	mov[bx+di],al
	inc di
	mov[bx+di],al
	inc di
	mov[bx+di],al
	inc di
	;stampa fisso 999

fine_macro:
pop bp di dx cx bx ax
ret
endp


code ends
end inizio