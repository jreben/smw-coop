OWEdgeCase:
LDA $141A
BNE ContinUpload
LDA $71
CMP #$0A
BEQ ContinUpload
OWUploadJmp:
JMP OWUpload

BEGINDMA:
SEP #$20
LDA $0100
CMP #$0E
BEQ OWUploadJmp
CMP #$0D
BEQ OWUploadJmp
CMP #$0F
BEQ OWEdgeCase
CMP #$14
BEQ ContinUpload
CMP #$07
BEQ ContinUpload
CMP #$13
BEQ ContinUpload
ReStop:
JMP DoNone
ContinUpload:

LDA $010A
BRA +
-
SEC
SBC #$03
+
CMP #$03
BCS -
STA $010A
REP #$20
LDX #$04				; All DMA is on channel 2 - STX $420B sets off

;;  Set up DMA settings for palette writes

LDY #$00				;from bank 0
STY $4324
LDA #$2200				;DMA to $2122 - CGRAM write data - 1 reg write once
STA $4320				;DMA channel #2 - $432x

;;
;Mario's Palette
;;

LDY #$8A				;CGRAM write address  - start writing at palette 8 color 6 (mario's stuff)
STY $2121
JSR GetPaletteP1
STA $4322				;DMA read address
LDA #$000C				;14 bytes of data
STA $4325
STX $420B				; Execute DMA

;;
;Luigi's Palette
;;

LDY #$9A				;CGRAM write address  - start writing at palette 8 color 6 (mario's stuff)
STY $2121
JSR GetPaletteP2
STA $4322				;DMA read address
LDA #$000C				;14 bytes of data
STA $4325
STX $420B				; Execute DMA

LDY #$80
STY $2115                ; Set DMA to handle 16-bit values
LDA #$1801
STA $4320

;;
;Mario's 8x8 tiles
;;

LDA #$60A0
STA $2116                ; VRAM address
LDA $0F3A
STA $4322                ; RAM address to DMA from
PHK
PLY
STY $4324                ; Bank to DMA from - current code bank
LDA #$0040
STA $4325                ; Some flag, idk
STX $420B        ; Execute DMA

;;
;Luigi's 8x8 tiles
;;

LDA #$61A0                ; VRAM address
STA $2116

SEP #$30
LDA #$01
JSR GetCharacter
REP #$20
AND #$0003
ASL #10
STA $0E
LDA $0F43
AND #$00FF
ASL #6
CLC
ADC $0E
CLC
ADC.w #ExGraphics
STA $4322
PHK
PLY
STY $4324
LDA #$0040
STA $4325
LDY #$04
STY $420B
REP #$20

;;
;Upper halves of Mario's tiles
;;

LDA #$6000
STA $2116
LDX #$00
.loop
LDA $0F3C,x
STA $4322
LDY #$7E
STY $4324
LDA #$0040
STA $4325
LDY #$04
STY $420B
INX #2
CPX $0D84
BCC .loop

;;
;Lower halves of Mario's tiles
;;

LDA #$6100
STA $2116
LDX #$00
.loop2
LDA $0F3C,x
CLC
ADC #$0200
STA $4322
LDY #$7E
STY $4324
LDA #$0040
STA $4325
LDY #$04
STY $420B
INX #2
CPX $0D84
BCC .loop2

;;
;Upper halves of Luigi's tiles
;;

LDA #$6200
STA $2116
LDX #$00
.loop3
LDA $0F44,x
STA $4322
LDY #$7E
STY $4324
LDA #$0040
STA $4325
LDY #$04
STY $420B
INX #2
CPX #$04
BCC .loop3

;;
;Lower halves of Luigi's tiles
;;

LDA #$6300
STA $2116
LDX #$00
.loop4
LDA $0F44,x
CLC
ADC #$0200
STA $4322
LDY #$7E
STY $4324
LDA #$0040
STA $4325
LDY #$04
STY $420B
INX #2
CPX #$04
BCC .loop4

SEP #$20
LDA $19
CMP #$02
BNE .nocapemario
REP #$20
LDA #$6040
STA $2116
LDA $13DF
AND #$000F
ASL #6
CLC
ADC #$7400
LDY $13DF
CPY #$08
BCC +
CLC
ADC #$0200
+
STA $4322
PHA
LDY #$7E
STY $4324
LDA #$0040
STA $4325
LDY #$04
STY $420B
LDA #$6140
STA $2116
PLA
CLC
ADC #$0200
STA $4322
LDY #$7E
STY $4324
LDA #$0040
STA $4325
LDY #$04
STY $420B
SEP #$20
.nocapemario

LDA $0DB9
AND #$18
CMP #$10
BNE .nocapeluigi
LDX $0F65
REP #$20
LDA #$6060
STA $2116
LDA $1534,x
AND #$000F
ASL #6
CLC
ADC #$7400
LDY $1534,x
CPY #$08
BCC +
CLC
ADC #$0200
+
STA $4322
PHA
LDY #$7E
STY $4324
LDA #$0040
STA $4325
LDY #$04
STY $420B

LDA #$6160
STA $2116
PLA
CLC
ADC #$0200
STA $4322
LDY #$7E
STY $4324
LDA #$0040
STA $4325
LDY #$04
STY $420B
SEP #$20
.nocapeluigi

DoNone:
SEP #$30
JML $80A38F

OWPindex:
db $00,$0A,$14

OWPalettes:
dw $3739,$4FDE,$20BA,$2D1E,$459E
dw $217A,$32DE,$3414,$4997,$0000
dw $6AD6,$77BD,$456F,$5A35,$66FD

OWDynams:
db $02,$03,$00,$01,$04,$05,$04,$05
db $02,$03,$00,$01,$04,$05,$04,$05
db $06,$06,$06,$06,$07,$07,$07,$07

OWUpload:
LDY #$B8
STY $2121
LDY #$3B
STY $2122
LDY #$57
STY $2122

LDA #$00
JSR GetCharacter
TAX
LDA.l OWPindex,x
REP #$20
AND #$00FF
CLC
ADC #OWPalettes
STA $4322
LDA #$2200				;DMA to $2122 - CGRAM write data - 1 reg write once
STA $4320				;DMA channel #2 - $432x
LDY #$A3				;CGRAM write address  - start writing at palette 8 color 6 (mario's stuff)
STY $2121
PHK
PLY
STY $4324
LDA #$000A				;14 bytes of data
STA $4325
LDY #$04
STY $420B

SEP #$20
LDA #$01
JSR GetCharacter
TAX
LDA.l OWPindex,x
REP #$20
AND #$00FF
CLC
ADC #OWPalettes
STA $4322
LDA #$2200				;DMA to $2122 - CGRAM write data - 1 reg write once
STA $4320				;DMA channel #2 - $432x
LDY #$B3				;CGRAM write address  - start writing at palette 8 color 6 (mario's stuff)
STY $2121
PHK
PLY
STY $4324
LDA #$000A				;14 bytes of data
STA $4325
LDY #$04
STY $420B

SEP #$20
LDA $14
AND #$08
LSR #3
ORA $1F13
PHX
TAX
LDA.l OWDynams,x
PLX
STA $00
REP #$20


LDY #$80
STY $2115
LDA #$6000
STA $2116
LDA #$1801				;$2118 - 2 regs 1 write
STA $4320
SEP #$20
LDA #$00
JSR GetCharacter
ASL #3
CLC
ADC $00
CLC
ADC #$90
STA $0F5F
JSR TileToAddr
STA $4322
LDY #$7E
STY $4324
LDA #$0040
STA $4325
LDY #$04
STY $420B

LDA #$0040
STA $4325
SEP #$20
LDA #$01
JSR GetCharacter
ASL #3
CLC
ADC $00
CLC
ADC #$90
JSR TileToAddr
STA $4322
LDY #$04
STY $420B

STZ $01
SEP #$20
LDA $1F13
SEC
SBC #$08
CMP #$08
BCC +
SEC
SBC #$0A
CMP #$02			;Setup water bottoms src addr
BCS ++
+
LDA $00
REP #$20
AND #$0001
BEQ +
LDA #$0200
+
CLC
ADC #$78C0
STA $01

++
REP #$20
LDY #$80
STY $2115
LDA #$6100
STA $2116
LDA #$1801				;$2118 - 2 regs 1 write
STA $4320
LDA $01
BNE +
SEP #$20
LDA #$00
JSR GetCharacter
ASL #8
CLC
ADC $00
JSR TileToAddr
CLC
ADC #$4A00
+
STA $4322
LDY #$7E
STY $4324
LDA #$0040
STA $4325
LDY #$04
STY $420B

LDA #$0040
STA $4325
LDA $01
BNE +
SEP #$20
LDA #$01
JSR GetCharacter
ASL #8
CLC
ADC $00
JSR TileToAddr
CLC
ADC #$4A00
+
STA $4322
LDY #$04
STY $420B

JMP DoNone

ExGraphics:
incbin ../graphics/ExtendGFX.bin
