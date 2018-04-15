.data

Prompt: 		.asciiz "----------Ban hay chon mot trong cac thao tac duoi day-----------\n"
Choice01: 	.asciiz "1. Xuat chuoi TIME theo dinh dang DD/MM/YYYY \n"
Choice02: 	.asciiz "2. Chuyen chuoi TIME thanh mot dinh dang khac \n"
Choice03: 	.asciiz "3. Cho biet ngay vua nhap la thu may trong tuan \n"
Choice04: 	.asciiz "4. Kiem tra nam trong chuoi TIME co phai la nam nhuan khong \n"
Choice05: 	.asciiz "5. Cho biet khoang thoi gian giua chuoi TIME_1 va TIME_2 \n"
Choice06: 	.asciiz "6. Cho biet 2 nam nhuan gan nhat voi nam trong chuoi TIME \n"
EndPrompt:	.asciiz "----------------------------------------------------------------\n"
PrintOrder:	.word	Prompt, Choice01, Choice02, Choice03, Choice04, Choice05, Choice06, EndPrompt

AskChoice: 		.asciiz "Lua chon: "
AskType: 			.asciiz " A - MM/DD/YY;\n B - Month DD, YYYY\n C - DD Month, YYYY.\nLua chon: "
Result:				.asciiz "Ket qua: "

promptDay: 		.asciiz "Nhap ngay Day: " 
promptMonth: 	.asciiz "Nhap thang Month: "
promptYear: 	.asciiz "Nhap nam Year: "

InputNumberError:	.asciiz "Loi nhap so. Xin nhap lai.\n"
InputDateError:		.asciiz "Ngay khong hop le. Xin nhap lai.\n"
InputTypeError:		.asciiz "Kieu dinh dang khong hop le. Xin nhap lai.\n"

MonthDayCount: .word 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
Jan:	.asciiz "January"
Feb:	.asciiz "February"
Mar:	.asciiz "March"
Apr:	.asciiz "April"
May:	.asciiz "May"
Jun:	.asciiz "June"
Jul:	.asciiz "July"
Aug:	.asciiz "August"
Sep:	.asciiz "September"
Oct:	.asciiz "October"
Nov:	.asciiz "November"
Dec:	.asciiz "December"
MonthName:	.word Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec

AnchorDate: .asciiz "02/04/2018"

Monday: 		.asciiz "Mon"
Tuesday: 		.asciiz "Tues"
Wednesday:	.asciiz "Wed"
Thursday:		.asciiz "Thurs"
Friday:			.asciiz "Fri"
Saturday:		.asciiz "Sat"
Sunday:			.asciiz "Sun"
WeekDayName: .word Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday

TempDate: 		.space 11
BufferDay: 		.space 2
BufferYear:		.space 4
BufferInput:	.space 50
BufferChoice:	.space 50

TIME_1: .space 20	# TIME string: DD/MM/YYYY
TIME_2:	.space 20

newline: .byte '\n'

.text

#------------------------------------------------------------

main:
	addi		$sp, $sp, -12
	sw			$ra, 8($sp)
	sw			$s0, 4($sp)
	sw			$s4, 0($sp)
	
	# ---- Ask for TIME_1
	la	$a0, TIME_1
	jal	GetDateInput
	
	# ---- Print menu
	la		$t0, PrintOrder
	addi	$t1, $0, 0
	addi	$t2, $0, 8
	Main.Loop:
		beq		$t1, $t2, Main.LoopEnd
		add		$t3, $t1, $0
		sll		$t3, $t3, 2
		add		$t3, $t0, $t3
		lw		$a0, 0($t3)
		li		$v0, 4
		syscall
		addi	$t1, $t1, 1
		j Main.Loop
	Main.LoopEnd:
	
	# ---- Ask for choice
	AskChoiceInput:
	la		$a0, AskChoice
	li		$v0, 4
	syscall
	
	# Check number input error
	jal		GetNum
	addi	$t0, $0, -1
	beq		$v0, $t0,	AskChoiceInput
	
	# Check if choice is 1 to 6
	addi	$t0, $0, 1
	slt		$t0, $v0, $t0
	bne		$t0, $0, AskChoiceInput
	
	addi	$t0, $0, 6
	slt		$t0, $t0, $v0
	bne		$t0, $0, AskChoiceInput
	
	# Save choice
	addi	$s0, $v0, 0
	
	# ---- Process
	addi	$s4, $0, 1
	beq		$s0, $s4, ProcessChoice01
	addi	$s4, $s4, 1
	beq		$s0, $s4, ProcessChoice02
	addi	$s4, $s4, 1
	beq		$s0, $s4, ProcessChoice03
	addi	$s4, $s4, 1
	beq		$s0, $s4, ProcessChoice04
	addi	$s4, $s4, 1
	beq		$s0, $s4, ProcessChoice05
	addi	$s4, $s4, 1
	beq		$s0, $s4, ProcessChoice06
	
	# ---- Choice 1
	ProcessChoice01:
	la		$a0, Result
	li		$v0, 4
	syscall
	
	la		$a0, TIME_1
	li		$v0, 4
	syscall
	
	j			Exit
	
	# ---- Choice 2
	ProcessChoice02:
	GetConvertType:
	la		$a0, AskType
	li		$v0, 4
	syscall
	
	la		$a0, BufferChoice
	li		$a1, 50
	li		$v0, 8
	syscall
	
	la		$t0, BufferChoice
	lb		$t0, 0($t0)
	
	addi	$t1, $0, 65
	slt		$t1, $t0, $t1
	beq		$t1, $0, Check67
	# Error message
	la 		$a0, InputTypeError
	li 		$v0, 4
	syscall
	j			GetConvertType
	
	Check67:
	addi	$t1, $0, 67
	slt		$t1, $t1, $t0
	beq		$t1, $0, CheckOnlyChar
	# Error message
	la 		$a0, InputTypeError
	li 		$v0, 4
	syscall
	j			GetConvertType
	
	CheckOnlyChar:
	la		$t0, BufferChoice
	lb		$t0, 1($t0)
	addi	$t1, $t1, 10
	beq		$t0, $t1, DoneCheck
	# Error message
	la 		$a0, InputTypeError
	li 		$v0, 4
	syscall
	j			GetConvertType
	
	DoneCheck:
	la		$t0, BufferChoice
	la		$a0, TIME_1
	lb		$a1, 0($t0)
	jal		Convert
	
	la		$a0, Result
	li		$v0, 4
	syscall
	
	la		$a0, TIME_1
	li		$v0, 4
	syscall
	
	j			Exit
	
	# ---- Choice 3
	ProcessChoice03:
	la		$a0, Result
	li		$v0, 4
	syscall
	
	la		$a0, TIME_1
	jal		Weekday
	
	la		$a0, 0($v0)
	li		$v0, 4
	syscall
	
	j 		Exit
	
	# ---- Choice 4
	ProcessChoice04:
	la		$a0, Result
	li		$v0, 4
	syscall
	
	la		$a0, TIME_1
	jal		LeapYear
	
	add 	$a0, $v0, $0
	li 		$v0, 1
	syscall
	
	j 		Exit
	
	# ---- Choice 5
	ProcessChoice05:
	la		$a0, TIME_2
	jal		GetDateInput
	
	la		$a0, Result
	li		$v0, 4
	syscall
	
	la		$a0, TIME_1
	la		$a1, TIME_2
	jal 	GetTime
	
	add		$a0, $v0, $0
	li		$v0, 1
	syscall
	
	j 		Exit
	
	# ---- Choice 6
	ProcessChoice06:
	la		$a0, Result
	li		$v0, 4
	syscall
	
	la		$a0, TIME_1
	jal		NearestLeapYears
	
	add		$a0, $v0, $0
	li		$v0, 1
	syscall
	
	li		$a0, ' '
	li		$v0, 11
	syscall
	
	add		$a0, $v1, $0
	li		$v0, 1
	syscall
	
	j Exit
	
#------------------------------------------------------------

# int GetNum()
# Input: none
# Output: input number from user
GetNum:
	# Get string input from user
	la 		$a0, BufferInput	
	li 		$a1, 49
	li 		$v0, 8
	syscall
	
	la 		$t1, BufferInput 	# store the address of BufferInput into $t1
	add 	$t2, $0, $0				# sum
	lb		$t3, newline			# character '\n' indicating stop
	addi	$t5, $0, 0				# to check ascii < '0'
	addi	$t6, $0, 10				# to check ascii > '9'
	GetNum.Loop:
		lb 		$t0, 0($t1)
		beq 	$t0, $t3, GetNum.End 		# Done with character '\n'
		addi 	$t0, $t0, -48
		addi 	$t4, $0, 1000000000
		slt 	$t7, $t2, $t4	
		beq 	$t7, $0, GetNum.Error		# If sum > 1e9, raise Error
		slt 	$t7, $t0, $t5		
		bne 	$t7, $0, GetNum.Error		# If char < '0', raise Error
		slt 	$t7, $t0, $t6
		beq 	$t7, $0, GetNum.Error		# If char > '9', raise Error
		mult 	$t2, $t6								# Multiple by 10
		mflo	$t4
		add 	$t2, $t4, $t0						# Add to sum
		addi 	$t1, $t1, 1							# Next character
		j GetNum.Loop
	GetNum.Error:
	addi	$t2, $0, -1
	GetNum.End:
	add		$v0, $t2, $0
	jr 		$ra
	
#------------------------------------------------------------

# char* GetDateInput(char* TIME)
# Input: address to space to store result string
# Output: same address as input
GetDateInput:
	# Prepare and store registers to stack
	addi	$sp, $sp, -20
	sw		$ra, 16($sp)
	sw		$a0, 12($sp)
	sw		$s1, 8($sp)
	sw		$s2, 4($sp)
	sw		$s3, 0($sp)
	
	# Get day input
	GetDate.GetDayInput:
	la $a0, promptDay		# load promptDay message into $a0 for syscall
	li $v0, 4						# load syscall to print string
	syscall							# cout << promptDay
	
	jal		GetNum
	addi	$s1, $v0, 0
	addi	$t0, $0, -1
	bne		$v0, $t0,	GetDate.GetMonthInput
	# Error message
	la $a0, InputNumberError
	li $v0, 4
	syscall
	j GetDate.GetDayInput
	
	# Get month input
	GetDate.GetMonthInput:
	la $a0, promptMonth		# load promptMonth message into $a0 for syscall
	li $v0, 4							# load syscall to print string
	syscall								# cout << promptMonth
	
	jal		GetNum
	addi	$s2, $v0, 0
	
	addi	$t0, $0, -1
	bne		$v0, $t0,	GetDate.GetYearInput
	# Error message
	la $a0, InputNumberError
	li $v0, 4
	syscall
	j GetDate.GetMonthInput
	
	# Get year input
	GetDate.GetYearInput:
	la $a0, promptYear	# load promptMonth message into $a0 for syscall
	li $v0, 4						# load syscall to print string
	syscall							# cout << promptMonth
	
	jal		GetNum
	addi	$s3, $v0, 0
	
	addi	$t0, $0, -1
	bne		$v0, $t0,	GetDate.CheckDate
	# Error message
	la $a0, InputNumberError
	li $v0, 4
	syscall
	j GetDate.GetYearInput
	
	# Check legal date
	GetDate.CheckDate:
	addi	$a0, $s1, 0
	addi	$a1, $s2, 0
	addi	$a2, $s3, 0
	jal		CheckDate
	
	bne		$v0, $0, GetDate.Convert
	# Error message
	la $a0, InputDateError
	li $v0, 4
	syscall
	j GetDate.GetDayInput
	
	# Convert to string
	GetDate.Convert:
	addi	$a0, $s1, 0
	addi	$a1, $s2, 0
	addi	$a2, $s3, 0
	lw		$a3, 12($sp)
	jal		Date
	
	# Return value
	addi	$v0, $v0, 0
	
	# Restore stack
	lw		$s3, 0($sp)
	lw		$s2, 4($sp)
	lw		$s1, 8($sp)
	lw		$a0, 12($sp)
	lw		$ra, 16($sp)
	addi	$sp, $sp, 20 
	
	# Return
	jr		$ra
	
#------------------------------------------------------------

# char* Date(int day, int month, int year, char* TIME)
# Input: three number day, month, year and address to space to store result string
# Output: string of date from input day, month, year
Date:
	addi 	$t7, $a3, 0		# index: 0
	addi 	$t0, $0, 10		# used to /10 for number
	la 		$t3, '/'
	
	# convert int Day to char
	div 	$a0, $t0
	mflo 	$t1						# Quotient
	mfhi 	$t2						# Remainder 
	addi 	$t1, $t1, 48	# $t1 = $t1 + '0'
	addi 	$t2, $t2, 48	# $t2 = $t2 + '0'
	sb 		$t1, 0($t7)
	addi 	$t7, $t7, 1		# index: 1
	sb 		$t2, 0($t7)
	addi 	$t7, $t7, 1		# index: 2
	
	# Insert /
	sb 		$t3, 0($t7)
	addi 	$t7, $t7, 1		# index: 3

	# convert int Month to char
	div 	$a1, $t0
	mflo 	$t1						# Quotient
	mfhi 	$t2						# Remainder 
	addi 	$t1, $t1, 48	# $t1 = $t1 + '0'
	addi 	$t2, $t2, 48	# $t2 = $t2 + '0'
	sb 		$t1, 0($t7)
	addi 	$t7, $t7, 1		# index: 4
	sb 		$t2, 0($t7)
	addi 	$t7, $t7, 1		# index: 5
	
	# Insert /
	sb 		$t3, 0($t7)
	addi 	$t7, $t7, 5		# index: 10
	
	# Set NULL char
	sb		$0, 0($t7)
	addi	$t7, $t7, -1
	
	# convert int Year to char
	add		$t1, $a2, $0
	addi	$t4, $a3, 5
	Date.LoopYear:
		beq		$t7, $t4, Date.LoopYearEnd		# From index 9 to 6
		div		$t1, $t0
		mflo	$t1
		mfhi	$t2
		addi	$t2, $t2, 48
		sb		$t2, 0($t7)
		addi	$t7, $t7, -1
		j Date.LoopYear
	Date.LoopYearEnd:
	
	# return
	addi	$v0, $a3, 0
	jr		$ra
	
#------------------------------------------------------------

# CheckDate(int day, int month, int year)
# Input: three numbers day, month, year representing time
# Output: 1 if legal date, 0 otherwise
CheckDate:
	# Push to stack
	addi	$sp, $sp, -16 
	sw		$ra, 12($sp)
	sw		$a0, 8($sp)
	sw		$a1, 4($sp)
	sw		$a2, 0($sp)
	
	# ---- Check year
	# Check year < 1900
	lw		$t0, 0($sp)
	addi	$t1, $0, 1900
	slt		$t1, $t0, $t1
	bne		$t1, $0, CheckDate.Error
	# Check year > 9999
	addi	$t1, $0, 9999
	slt		$t1, $t1, $t0
	bne		$t1, $0, CheckDate.Error
	
	# ---- Check month
	# Check month < 1
	lw		$t0, 4($sp)
	addi	$t1, $0, 1
	slt		$t1, $t0, $t1
	bne		$t1, $0, CheckDate.Error
	# Check month > 12
	addi	$t1, $0, 12
	slt		$t1, $t1, $t0
	bne		$t1, $0, CheckDate.Error
	
	# ---- Check day
	# Check day < 1
	lw		$t0, 8($sp)
	addi	$t1, $0, 1
	slt		$t1, $t0, $t1
	bne		$t1, $0, CheckDate.Error
	
	# Check leap year
	lw		$a0, 0($sp)
	jal		LeapYearUtil
	lw		$t2, 8($sp)
	beq		$v0, $0, CheckDate.EndCheckLeapYear
	# If leap year, check Feb
	lw		$t3, 4($sp)
	addi	$t3, $t3, -2
	bne		$t3, $0, CheckDate.EndCheckLeapYear
	# If Feb, decrease day count (check d <= 29 <=> d - 1 <= 28 = MonthDayCount[2])
	addi	$t2, $t2, -1
	CheckDate.EndCheckLeapYear:
	# Get month's day count
	la		$t0, MonthDayCount
	lw		$t1, 4($sp)
	sll		$t1, $t1, 2
	add		$t1, $t0, $t1
	lw		$t1, 0($t1)
	# Check if d < MonthDayCount[m]
	slt		$t1, $t1, $t2
	bne		$t1, $0, CheckDate.Error
	
	# If all okay, return 1 (TRUE)
	addi	$v0, $0, 1
	j			CheckDate.End
	
	CheckDate.Error:
	# If error, return 0 (FALSE)
	addi	$v0, $0, 0
	
	CheckDate.End:
	# Restore stack and return
	lw		$a2, 0($sp)
	lw		$a1, 4($sp)
	lw		$a0, 8($sp)
	lw		$ra, 12($sp)
	addi	$sp, $sp, 16
	
	jr		$ra
	
#------------------------------------------------------------

# Convert(char* TIME, char type)
# Input: string of date to convert and conversion type
# Output: string of date after conversion
Convert:
	# Prepare stack and store registers
	addi	$sp, $sp, -12
	sw		$ra, 8($sp)
	sw		$a0, 4($sp)
	sw		$a1, 0($sp)
	
	# Get conversion type
	lw		$a0, 4($sp)
	# Convert based on type
	addi	$t0, $0, 65
	beq		$a1, $t0, Convert.ChoiceA
	addi	$t0, $0, 66
	beq		$a1, $t0, Convert.ChoiceB
	addi	$t0, $0, 67
	beq		$a1, $t0, Convert.ChoiceC

	Convert.ChoiceA:
	jal		ConvertA
	j			Convert.End
	
	Convert.ChoiceB:
	jal		ConvertB
	j			Convert.End
	
	Convert.ChoiceC:
	jal		ConvertC

	Convert.End:
	# Return value
	addi	$v0, $v0, 0
	# Restore stack
	lw		$a1, 0($sp)
	lw		$a0, 4($sp)
	lw		$ra, 8($sp)
	addi	$sp, $sp, 12
	# Return
	jr		$ra

# ConvertA(char* TIME)
# Input: string of date to convert to type A
# Output: string of date after conversion
ConvertA:
	add $t1, $0, $a0	# the address of TIME array ---- Index: 0

	lb 	$t2, 0($t1)		# t2 saves the first value of day
	lb 	$t3, 1($t1)		# t3 saves the second value of day
	lb 	$t4, 3($t1)		# t4 saves the first value of month
	lb 	$t5, 4($t1)		# t5 saves the second value of month

	sb 	$t2, 3($a0)	
	sb 	$t3, 4($a0)		
	sb 	$t4, 0($a0)		
	sb 	$t5, 1($a0)

	add $v0, $a1, $0
	jr $ra

# ConvertB(char* TIME)
# Input: string of date to convert to type B
# Output: string of date after conversion
ConvertB:
	addi	$sp, $sp, -8
	sw		$ra, 4($sp)
	sw		$a0, 0($sp)
	
	# Get Month
	lw		$a0, 0($sp)
	jal		Month
	add		$t1, $v0, $0
	
	lw		$t0, 0($sp)
	# Save day
	la		$t5, BufferDay
	lb		$t6, 0($t0)
	sb		$t6, 0($t5)
	lb		$t6, 1($t0)
	sb		$t6, 1($t5)
	
	# Save year
	la		$t5, BufferYear
	lb		$t6, 6($t0)
	sb		$t6, 0($t5)
	lb		$t6, 7($t0)
	sb		$t6, 1($t5)
	lb		$t6, 8($t0)
	sb		$t6, 2($t5)
	lb		$t6, 9($t0)
	sb		$t6, 3($t5)
	
	# Month name
	la		$t2, MonthName
	addi	$t1, $t1, -1
	sll		$t1, $t1, 2
	add		$t1, $t2, $t1
	lw		$t1, ($t1)
	
	add		$t3, $0, $0
	ConvertB.Loop:
		add		$t4, $t1, $t3
		add		$t2, $t0, $t3
		lb		$t4, ($t4)
		beq		$t4, $0, ConvertB.LoopEnd
		sb		$t4, ($t2)
		addi	$t3, $t3, 1
		j ConvertB.Loop
	ConvertB.LoopEnd:
	
	# Add Spacebar
	add		$t2, $t0, $t3
	addi	$t4, $0, 32
	sb		$t4, ($t2)
	addi	$t3, $t3, 1
	
	# Add day
	la		$t1, BufferDay
	
	add		$t2, $t0, $t3
	lb		$t4, ($t1)
	sb		$t4, ($t2)
	addi	$t3, $t3, 1
	
	add		$t2, $t0, $t3
	lb		$t4, 1($t1)
	sb		$t4, ($t2)
	addi	$t3, $t3, 1
	
	# Add ,
	add		$t2, $t0, $t3
	addi	$t4, $0, 44
	sb		$t4, ($t2)
	addi	$t3, $t3, 1
	
	# Add Spacebar
	add		$t2, $t0, $t3
	addi	$t4, $0, 32
	sb		$t4, ($t2)
	addi	$t3, $t3, 1
	
	# Add year
	la		$t1, BufferYear
	addi	$t5, $0, 0
	addi	$t6, $0, 4
	ConvertB.LoopYear:
		beq		$t5, $t6, ConvertB.LoopYearEnd
		add		$t2, $t0, $t3
		add		$t4, $t1, $t5
		lb		$t4, ($t4)
		sb		$t4, ($t2)
		addi	$t3, $t3, 1
		addi	$t5, $t5, 1
		j ConvertB.LoopYear
	ConvertB.LoopYearEnd:
	
	add		$v0, $t0, $0
	
	lw		$a0, 0($sp)
	lw		$ra, 4($sp)
	addi	$sp, $sp, 8
	
	jr 	$ra

# ConvertC(char* TIME)
# Input: string of date to convert to type C
# Output: string of date after conversion
ConvertC:
	addi	$sp, $sp, -8
	sw		$ra, 4($sp)
	sw		$a0, 0($sp)
	
	# Get Month
	lw		$a0, 0($sp)
	jal		Month
	add		$t1, $v0, $0
	
	lw		$t0, 0($sp)
		
	# Save year
	la		$t5, BufferYear
	lb		$t6, 6($t0)
	sb		$t6, 0($t5)
	lb		$t6, 7($t0)
	sb		$t6, 1($t5)
	lb		$t6, 8($t0)
	sb		$t6, 2($t5)
	lb		$t6, 9($t0)
	sb		$t6, 3($t5)
	
	addi		$t3, $0, 2
	# Add Spacebar
	add		$t2, $t0, $t3
	addi	$t4, $0, 32
	sb		$t4, ($t2)
	addi	$t3, $t3, 1
	
	# Month name
	la		$t2, MonthName
	addi	$t1, $t1, -1
	sll		$t1, $t1, 2
	add		$t1, $t2, $t1
	lw		$t1, ($t1)
	
	addi	$t5, $0, 0
	ConvertC.Loop:
		add		$t4, $t1, $t5
		add		$t2, $t0, $t3
		lb		$t4, ($t4)
		beq		$t4, $0, ConvertC.LoopEnd
		sb		$t4, ($t2)
		addi	$t3, $t3, 1
		addi	$t5, $t5, 1
		j ConvertC.Loop
	ConvertC.LoopEnd:
	
	# Add ,
	add		$t2, $t0, $t3
	addi	$t4, $0, 44
	sb		$t4, ($t2)
	addi	$t3, $t3, 1
	
	# Add Spacebar
	add		$t2, $t0, $t3
	addi	$t4, $0, 32
	sb		$t4, ($t2)
	addi	$t3, $t3, 1
	
	# Add year
	la		$t1, BufferYear
	addi	$t5, $0, 0
	addi	$t6, $0, 4
	ConvertC.LoopYear:
		beq		$t5, $t6, ConvertC.LoopYearEnd
		add		$t2, $t0, $t3
		add		$t4, $t1, $t5
		lb		$t4, ($t4)
		sb		$t4, ($t2)
		addi	$t3, $t3, 1
		addi	$t5, $t5, 1
		j ConvertC.LoopYear
	ConvertC.LoopYearEnd:
	
	add		$v0, $t0, $0
	
	lw		$a0, 0($sp)
	lw		$ra, 4($sp)
	addi	$sp, $sp, 8
	
	jr 	$ra

#------------------------------------------------------------

# int DaysFromYearStart(char* TIME);
# Input: String DD/MM/YYYY representing a date
# Output: Number of days from the start of the year (ex: 01/01/1998 -> 0)
DaysFromYearStart:
	# ---- Push to stack
	addi	$sp, $sp, -28
	sw		$ra, 24($sp)			# Push $ra to stack
	sw		$a0, 20($sp)			# Push $a0 (TIME) to stack
	# Store saved registers
	sw		$s0, 16($sp)
	sw		$s1, 12($sp)
	sw		$s2, 8($sp)
	sw		$s3, 4($sp)
	sw		$s4, 0($sp)
	
	# ---- Prepare
	# Create array of day count months, store address in $s0
	la		$s0, MonthDayCount
	# Get year
	lw		$a0, 20($sp)	# Load TIME to $a0
	jal		Year					# Year(TIME)
	add		$s1, $0, $v0	# $s1 = Year(TIME)
	# Get month
	lw		$a0, 20($sp)	# Load TIME to $a0
	jal		Month					# Month(TIME)
	add		$s2, $0, $v0	# $t1 = Month(TIME)
	# Get day
	lw		$a0, 20($sp)		# Load TIME to $a0
	jal		Day							# Day(TIME)
	add		$s3, $0, $v0		# $t1 = Day(TIME)
	# Return value
	add		$s4, $0, $0
	
	# ---- Consider LeapYear case
	# Check leap year
	add		$a0, $0, $s1		# Load year to $a0
	jal		LeapYearUtil		# LeapYear(year)
	# If not leap year, do nothing
	beq		$v0, $0, DaysFromYearStart.EndCheckLeapYear
	# If leap year,
	addi	$t0, $t0, 2
	slt		$t0, $t0, $s2
	# If month <= 2, do nothing
	beq		$t0, $0, DaysFromYearStart.EndCheckLeapYear
	# If month > 2, add 1 to return
	addi	$s4, $s4, 1
	DaysFromYearStart.EndCheckLeapYear:
	
	# ----- Month
	# Iterate month, increasing day count, from previous month
	DaysFromYearStart.LoopMonth:
		addi 	$s2, $s2, -1		# From previous month
		beq		$s2, $0, DaysFromYearStart.EndLoopMonth	# If month == 0, break
		# Get day count of that month
		sll 	$t0, $s2, 2			# $t0 = $t0 * 4
		add		$t0, $s0, $t0		# $t0 = &MonthDayCount[$t0]
		lw		$t0, 0($t0)			# $t0 = *$t0
		# Add to return value
		add		$s4, $s4, $t0		# $s4 = $s4 + $t2
		j			DaysFromYearStart.LoopMonth
	DaysFromYearStart.EndLoopMonth:
	
	# ----- Day
	addi	$s3, $s3, -1		# $t1-- (previous day)
	add		$s4, $s4, $s3		# $s4 = $s4 + $s3
	
	# ----- Return
	add		$v0, $0, $s4
	
	# ----- Restore stack
	lw		$s4, 0($sp)
	lw		$s3, 4($sp)
	lw		$s2, 8($sp)
	lw		$s1, 12($sp)
	lw		$s0, 16($sp)
	lw		$a0, 20($sp)
	lw		$ra, 24($sp)
	addi	$sp, $sp, 28
	
	jr 		$ra
	
#------------------------------------------------------------

# int DaysBetweenYearStart(int year1, int year2)
# Input: two years year1 < year2
# Output: Number of days between two years
DaysBetweenYearStarts:
	# ---- Push to stack
	addi	$sp, $sp, -24
	sw		$ra, 20($sp)			# Push $ra to stack
	sw		$a0, 16($sp)			# Push $a0 (year1) to stack
	sw		$a1, 12($sp)			# Push $a1 (year2) to stack
	# Store saved registers
	sw		$s0, 8($sp)
	sw		$s1, 4($sp)
	sw		$s2, 0($sp)
	
	# Return value
	add		$s0, $0, $0
	
	# ---- Iterate year
	lw		$s1, 16($sp)
	lw		$s2, 12($sp)
	DaysBetweenYearStarts.LoopYear:
		beq		$s1, $s2, DaysBetweenYearStarts.EndLoopYear
		addi	$s2, $s2, -1
		# Check leap year
		add		$a0, $0, $s2	# Load $t1 (year) to $a0
		jal		LeapYearUtil	# LeapYear(year)
		# If not leap year, do nothing
		beq		$v0, $0, DaysBetweenYearStarts.EndCheckLeapYear
		# If leap year, add 1 to return value
		addi	$s0, $s0, 1
		DaysBetweenYearStarts.EndCheckLeapYear:
		addi	$s0, $s0, 365
		j DaysBetweenYearStarts.LoopYear
	DaysBetweenYearStarts.EndLoopYear:
	
	# ----- Return
	add		$v0, $0, $s0
	
	# ----- Restore stack
	lw		$s2, 0($sp)
	lw		$s1, 4($sp)
	lw		$s0, 8($sp)
	lw		$a1, 12($sp)			
	lw		$a0, 16($sp)		
	lw		$ra, 20($sp)		
	addi	$sp, $sp, 24
	
	jr $ra
	
#------------------------------------------------------------

# int IsBefore(int days1, int year1, int days2, int year2);
# Input: two number from each date, the first is the number of days from the
# 			start of that year, the latter is the year
# Output: 1 if TIME1 < TIME2, 0 otherwise
IsBefore:
	# If year1 < year2 return true
	addi	$v0, $0, 1
	slt		$t0, $a1, $a3
	bne		$t0, $0, IsBefore.End
	
	# Else, if year1 > year2 return false
	addi	$v0, $0, 0
	slt		$t0, $a3, $a1
	bne		$t0, $0, IsBefore.End
	
	# Else (year1 == year2), if days1 < days2 return true
	addi	$v0, $0, 1
	slt		$t0, $a0, $a2
	bne		$t0, $0, IsBefore.End
	
	# Else (year1 == year2, days1 >= days2) return false
	addi	$v0, $0, 0
	
	IsBefore.End:
	
	jr $ra
	

#------------------------------------------------------------

# int GetTime(char* TIME1, char* TIME2);
# Input: two strings DD/MM/YYYY representing two dates
# Output: number of days between two dates

GetTime:
	# ---- Push to stack
	addi	$sp, $sp, -12
	sw		$ra, 8($sp)
	sw		$a0, 4($sp)
	sw		$a1, 0($sp)
	
	# ---- Call util
	lw		$a0, 4($sp)
	lw		$a1, 0($sp)
	jal		GetTimeUtil
	
	# ---- Get only the difference
	add		$v0, $v0, $0
	
	# ----- Restore stack
	lw		$a1, 0($sp)
	lw		$a0, 4($sp)
	lw		$ra, 8($sp)
	addi	$sp, $sp, 12
	
	jr		$ra

# GetTimeUtil return time between but with sign
# $v0 -> number of days between
# $v1 -> TIME_1 is before (0) or after (1) TIME_2

GetTimeUtil:
	# ---- Push to stack
	addi	$sp, $sp, -36
	sw		$ra, 32($sp)			# Push $ra to stack
	sw		$a0, 28($sp)			# Push $a0 (TIME1) to stack
	sw		$a1, 24($sp)			# Push $a1 (TIME2) to stack
	# Store saved registers
	sw		$s0, 20($sp)
	sw		$s1, 16($sp)
	sw		$s2, 12($sp)
	sw		$s3, 8($sp)
	sw		$s4, 4($sp)
	sw		$s5, 0($sp)
	
	# ---- Prepare data
	# Year 1
	# Get day from year start
	lw		$a0, 28($sp)
	jal		DaysFromYearStart
	add		$s1, $0, $v0
	# Get year
	lw		$a0, 28($sp)
	jal Year
	add		$s2, $0, $v0
	# Year 2
	# Get day from year start
	lw		$a0, 24($sp)
	jal		DaysFromYearStart
	add		$s3, $0, $v0
	# Get year
	lw		$a0, 24($sp)
	jal 	Year
	add		$s4, $0, $v0
	# Return value
	add		$s0, $0, $0
	add		$s5, $0, $0
	
	# ---- Normalize
	# Make sure date1 is before date2
	add 	$a0, $0, $s1
	add 	$a1, $0, $s2
	add 	$a2, $0, $s3
	add 	$a3, $0, $s4
	jal 	IsBefore
	bne		$v0, $0, GetTime.IsNormalized
	# If not data1 < date2, swap
	add		$t0, $0, $s1
	add		$s1, $0, $s3
	add		$s3, $0, $t0
	add		$t0, $0, $s2
	add		$s2, $0, $s4
	add		$s4, $0, $t0
	addi	$s5, $0, 1
	GetTime.IsNormalized:
	
	# ---- Calculate time between
	# ---- SoY1 (1/1/y1) ---- date1 ---- SOY2 (1/1/y2) ---- date2----> (Timeline)
	# GetTime(date1, date2) = GetTime(SoY1, SoY2) + GetTime(SoY2, date2) - GetTime(SoY1, date1)
	
	# Add GetTime(SoY1, SoY2)
	add		$a0, $0, $s2
	add		$a1, $0, $s4
	jal		DaysBetweenYearStarts
	add		$s0, $s0, $v0
	# Add GetTime(SoY2, date2)
	add 	$s0, $s0, $s3
	# Sub GetTime(SoY1, date1)
	sub		$s0, $s0, $s1
	
	# ----- Return
	add		$v0, $0, $s0
	add		$v1, $0, $s5
	
	# ----- Restore stack
	# Restore saved register
	lw		$s5, 0($sp)
	lw		$s4, 4($sp)
	lw		$s3, 8($sp)
	lw		$s2, 12($sp)
	lw		$s1, 16($sp)
	lw		$s0, 20($sp)
	# Restore params and $ra
	lw		$a1, 24($sp)
	lw		$a0, 28($sp)
	lw		$ra, 32($sp)
	# Restore stack
	addi	$sp, $sp, 36
	
	jr $ra
	
#------------------------------------------------------------

# int DaysFromYearStart(char* TIME);
# Input: String DD/MM/YYYY representing a date
# Output: Number of days from the start of the year (ex: 01/01/1998 -> 0)
Weekday:
	# ---- Push to stack
	addi	$sp, $sp, -8
	sw		$ra, 4($sp)
	sw		$a0, 0($sp)
	
	# Get time between two dates
	la		$a0, AnchorDate
	lw		$a1, 0($sp)
	jal		GetTimeUtil
	
	# Get day of the week
	addi	$t0, $0, 7
	div		$v0, $t0
	mfhi	$t0
	beq		$v1, $0, Weekday.GetName
	addi	$t1, $0, 7
	sub		$t0, $t1, $t0
	div		$t0, $t1
	mfhi	$t0
	
	Weekday.GetName:
	# Get name string
	la		$t1, WeekDayName
	sll		$t0, $t0, 2
	add		$t0, $t0, $t1
	lw		$v0, ($t0) 
	
	# ---- Restore stack
	lw		$a0, 0($sp)
	lw		$ra, 4($sp)
	addi	$sp, $sp, 8
	
	jr		$ra
	
#------------------------------------------------------------

# int Day(char* TIME);
# Input: string DD/MM/YYYY representating a date
# Output: the day of the date
Day:
	# $a0: char* TIME
	addi 	$t1, $0, 10			#	t1 = 10
	
	lb 		$t0, 0($a0)			# t0 = TIME[0]
	addi 	$t0, $t0, -48		# t0 = t0 - '0'
	mult 	$t0, $t1				
	mflo 	$t0							# t0 = 10*t0
	
	lb 		$t2, 1($a0)			#	t2 = TIME[1]
	addi 	$t2, $t2, -48		# t2 = t2 - '0'
	add 	$t0, $t0, $t2		# t0 = t0 + t2
	
	add 	$v0, $t0, $0		# return t0
	jr 		$ra
	
#------------------------------------------------------------
	
# int Month(char* TIME);
# Input: string DD/MM/YYYY representating a date
# Output: the month of the date
Month:
	# $a0: char* TIME
	addi 	$t1, $0, 10			#	t1 = 10
	
	lb 		$t0, 3($a0)			# t0 = TIME[0]
	addi 	$t0, $t0, -48		# t0 = t0 - '0'
	mult 	$t0, $t1				
	mflo 	$t0							# t0 = 10*t0
	
	lb 		$t2, 4($a0)			#	t2 = TIME[1]
	addi 	$t2, $t2, -48		# t2 = t2 - '0'
	add 	$t0, $t0, $t2		# t0 = t0 + t2
	
	add 	$v0, $t0, $0		# return t0
	jr 		$ra

#------------------------------------------------------------
	
# int Year(char* TIME);
# Input: string DD/MM/YYYY representating a date
# Output: the year of the date
Year:
	# $a0: char* TIME
	addi 	$t1, $0, 10			#	t1 = 10
	addi	$t0, $0, 0			# t0 = 0
	addi	$t2, $0, 6			# t2 = 6
	addi	$t3, $0, 10			#	t3 = 10
	Year.Loop:
		beq		$t2, $t3, Year.LoopEnd	# From index 6 to 9
		add		$t4, $a0, $t2						#	t4 = a0 + t2 (address of TIME[t2])
		lb		$t4, ($t4)							# t4 = *t4
		addi	$t4, $t4, -48						# t4 = t4 - '0'
		mult	$t0, $t1								# t0 = 10*t0
		mflo	$t0
		add		$t0, $t0, $t4						# t0 = t0 + t4
		addi	$t2, $t2, 1							# t2++
		j Year.Loop
	Year.LoopEnd:
	add 	$v0, $t0, $0		# return t0
	jr 		$ra

#------------------------------------------------------------

# int LeapYear(char* TIME);
# Input: string DD/MM/YYYY representating a date
# Output: if the year is a leap year (1) or not (0)
LeapYear:
	# Push to stack
	addi	$sp, $sp, -8
	sw		$ra, 4($sp)
	sw		$a0, 0($sp)
	
	# Get year
	lw		$a0, 0($sp)
	jal		Year
	
	# Check year
	add		$a0, $0, $v0
	jal		LeapYearUtil
	
	# Return
	addi	$v0, $v0, 0
	
	# Restore stack
	lw		$a0, 0($sp)
	lw		$ra, 4($sp)
	addi	$sp, $sp, 8
	
	jr $ra

# LeapYearUtil takes in a number (year)
LeapYearUtil:
	addi 	$t0, $0, 100
	div 	$a0, $t0
	mfhi 	$t0
	# If y mod 100 = 0 -> check mod 400
	beq 	$t0, $0, Mod400
	# Else, if y mod 100 != 0 -> check mod 4
	addi 	$t0, $0, 4
	div 	$a0, $t0
	mfhi 	$t0
	# If y mod 4 = 0 -> leap year
	beq 	$t0, $0, IsLeapYear
	# Else -> not leap year
	j IsNotLeapYear

	Mod400:
		addi	$t0, $0, 400
		div 	$a0, $t0
		mfhi	$t0
		# If y mod 400 = 0 -> leap year
		beq 	$t0, $0, IsLeapYear
		# Else -> not leap year
		j IsNotLeapYear
		
	IsLeapYear:
	addi 	$t0, $0, 1
	j LeapYear.End
	
	IsNotLeapYear:
	addi 	$t0, $0, 0
	
	LeapYear.End:
	add		$v0, $t0, $0
	
	jr 		$ra

#------------------------------------------------------------

# pair<int, int> NearestLeapYears(char* TIME);
# Input: string DD/MM/YYYY representating a date
# Output: pair of int, next two leap years
NearestLeapYears:
	# Prepare stack
	addi	$sp, $sp, -20
	# Save return point and arguments
	sw		$ra, 16($sp)
	sw		$a0, 12($sp)
	# Save saved registers
	sw		$s0, 8($sp)
	sw		$s1, 4($sp)
	sw		$s2, 0($sp)
	
	# Get year from TIME
	lw		$a0, 12($sp)
	jal 	Year
	add 	$s0, $v0, $0
	
	# Get nearest year that divides 4 (y' = y - y % 4)
	addi 	$t1, $0, 4
	div 	$s0, $t1
	mfhi 	$t1
	sub 	$s0, $s0, $t1
	
	# Three potential year: y' + 4, y' + 8, y' + 12
	# Two of them will be leap year
	
	# --- Consider y' + 4 ---
	# Convert to string
	addi	$a0, $0, 1
	addi	$a1, $0, 1
	addi	$a2, $s0, 4
	la		$a3, TempDate
	jal		Date
	
	# Check leap year
	la		$a0, TempDate
	jal		LeapYear
	add 	$t1, $v0, $0
	
	# If not leap year, the result is y' + 8, y' + 12
	beq 	$t1, $0, NearestLeapYears.Return812
	
	# --- Consider y' + 8 ----
	# Convert to string
	addi	$a0, $0, 1
	addi	$a1, $0, 1
	addi	$a2, $s0, 8
	la		$a3, TempDate
	jal		Date
	
	# Check leap year
	la		$a0, TempDate
	jal		LeapYear
	add		$t1, $v0, $0
	# If not leap year, return y' + 4, y' + 12
	beq		$t1, $0, NearestLeapYears.Return412
	# Else, return y' + 4, y' + 8
	j 		NearestLeapYears.Return48
	
	NearestLeapYears.Return812:
	addi	$s1, $s0, 8
	addi	$s2, $s0, 12
	j			NearestLeapYears.End
	
	NearestLeapYears.Return412:
	addi	$s1, $s0, 4
	addi	$s2, $s0, 12
	j			NearestLeapYears.End
	
	NearestLeapYears.Return48:
	addi	$s1, $s0, 4
	addi	$s2, $s0, 8
	
	NearestLeapYears.End:
	add		$v0, $s1, $0
	add		$v1, $s2, $0
	
	# Restore stack
	lw		$s2, 0($sp)
	lw		$s1, 4($sp)
	lw		$s0, 8($sp)
	lw		$a0, 12($sp)
	lw		$ra, 16($sp)
	addi	$sp, $sp, 20
	# Return
	jr		$ra

#------------------------------------------------------------

Exit:
	lw			$s4, 0($sp)
	lw			$s0, 4($sp)
	lw			$ra, 8($sp)
	addi		$sp, $sp, 12
