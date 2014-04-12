import random, sys

def make_a_instruction(fmt, opcode, dest, src1, src2, mask):
	return ((6 << 29) | (fmt << 26) | (opcode << 20) | (src2 << 15) 
		| (mask << 10) | (dest << 5) | src1)

def make_b_instruction(fmt, opcode, dest, src1, imm, mask):
	return ((fmt << 28) | (opcode << 23) | ((imm & 0xff) << 15) 
		| (mask << 10) | (dest << 5) | src1)

def make_bprime_instruction(fmt, opcode, dest, src1, imm):
	return ((fmt << 28) | (opcode << 23) | ((imm & 0x1fff) << 10) 
		| (dest << 5) | src1)

def make_c_instruction(isLoad, op, srcDest, ptr, offs, mask):
	return ((1 << 31) | (isLoad << 29) | (op << 25) | (offs << 15) 
		| (mask << 10) | (srcDest << 5) | ptr)

def make_cprime_instruction(isLoad, op, srcDest, ptr, offs):
	return ((1 << 31) | (isLoad << 29) | (op << 25) | (offs << 10) 
		| (srcDest << 5) | ptr)

def make_d_instruction(op, reg):
	return 0xe0000000 | (op << 25) | reg

def make_text_encoding(x, sep):
	str = ''
	for y in range(4):
		if y != 0:
			str += sep
			
		str += '0x%02x' % (x & 0xff)
		x >>= 8

	return str

def make_test_case(string, encoding):
	global disasm_fp
	global asm_fp

	asm_fp.write(string + '  # CHECK: [' + make_text_encoding(encoding, ',') + ']\n')
	disasm_fp.write(make_text_encoding(encoding, ' ') + '  # CHECK: ' + string + '\n')

# Setup
disasm_fp = open('disassembler-tests.s', 'w')
asm_fp = open('assembler-tests.s', 'w')

asm_fp.write('# This file auto-generated by ' + sys.argv[0] + '. Do not edit.\n')
asm_fp.write('# RUN: llvm-mc -arch=vectorproc -show-encoding %s | FileCheck %s\n')

disasm_fp.write('# This file auto-generated by ' + sys.argv[0] + '. Do not edit.\n')
disasm_fp.write('# RUN: llvm-mc -arch=vectorproc -disassemble %s | FileCheck %s\n')

##############################################################
# Test cases
##############################################################

binaryOps = [
	(0, 'or'),
	(1, 'and'),
	(3, 'xor'),
	(5, 'add_i'),
	(6, 'sub_i'),
	(7, 'mul_i'),
	(9, 'ashr'),
	(10, 'shr'),
	(11, 'shl'),
	(0x20, 'add_f'),
	(0x21, 'sub_f'),
	(0x22, 'mul_f'),
]

for opcode, mnemonic in binaryOps:
	rega = random.randint(0, 27)
	regb = random.randint(0, 27)
	regc = random.randint(0, 27)
	regm = random.randint(0, 27)
	
	# scalar/scalar/scalar
	make_test_case(mnemonic + ' s' + str(rega) + ', s' + str(regb) 
		+ ', s' + str(regc),
		make_a_instruction(0, opcode, rega, regb, regc, 0))

	# vector/vector/scalar
	make_test_case(mnemonic + ' v' + str(rega) + ', v' + str(regb) 
		+ ', s' + str(regc),
		make_a_instruction(1, opcode, rega, regb, regc, 0))

	# vector/vector/scalar masked
	make_test_case(mnemonic + '_mask v' + str(rega) + ', s' + str(regm) 
		+ ', v' + str(regb) + ', s' + str(regc),
		make_a_instruction(2, opcode, rega, regb, regc, regm))

	# vector/vector/scalar invert mask
	make_test_case(mnemonic + '_invmask v' + str(rega) + ', s' + str(regm) 
		+ ', v' + str(regb) + ', s' + str(regc),
		make_a_instruction(3, opcode, rega, regb, regc, regm))

	# vector/vector/vector		
	make_test_case(mnemonic + ' v' + str(rega) + ', v' + str(regb) 
		+ ', v' + str(regc),
		make_a_instruction(4, opcode, rega, regb, regc, 0))

	# vector/vector/vector masked
	make_test_case(mnemonic + '_mask v' + str(rega) + ', s' + str(regm) 
		+ ', v' + str(regb) + ', v' + str(regc),
		make_a_instruction(5, opcode, rega, regb, regc, regm))

	# vector/vector/vector invert mask
	make_test_case(mnemonic + '_invmask v' + str(rega) + ', s' + str(regm) 
		+ ', v' + str(regb) + ', v' + str(regc),
		make_a_instruction(6, opcode, rega, regb, regc, regm))

	if mnemonic[-2:] == '_f':
		continue	# Can't do immediate for FP instructions

	imm = random.randint(-128, 127)

	# scalar/scalar
	make_test_case(mnemonic + ' s' + str(rega) + ', s' + str(regb) 
		+ ', ' + str(imm),
		make_bprime_instruction(0, opcode, rega, regb, imm))

	# vector/vector
	make_test_case(mnemonic + ' v' + str(rega) + ', v' + str(regb) + ', ' + str(imm),
		make_bprime_instruction(1, opcode, rega, regb, imm))

	# vector/vector masked
	make_test_case(mnemonic + '_mask v' + str(rega) + ', s' + str(regm) + ', v' + str(regb) + ', ' + str(imm),
		make_b_instruction(2, opcode, rega, regb, imm, regm))

	# vector/vector invert mask
	make_test_case(mnemonic + '_invmask v' + str(rega) + ', s' + str(regm) + ', v' + str(regb) + ', ' + str(imm),
		make_b_instruction(3, opcode, rega, regb, imm, regm))

	# vector/scalar
	make_test_case(mnemonic + ' v' + str(rega) + ', s' + str(regb) + ', ' + str(imm),
		make_bprime_instruction(4, opcode, rega, regb, imm))

	# vector/scalar masked
	make_test_case(mnemonic + '_mask v' + str(rega) + ', s' + str(regm) + ', s' + str(regb) + ', ' + str(imm),
		make_b_instruction(5, opcode, rega, regb, imm, regm))

	# vector/scalar invert mask
	make_test_case(mnemonic + '_invmask v' + str(rega) + ', s' + str(regm) + ', s' + str(regb) + ', ' + str(imm),
		make_b_instruction(6, opcode, rega, regb, imm, regm))

unaryOps = [
	(12, 'clz'),
	(14, 'ctz'),
	(0xf, 'move'),
	(0x1c, 'reciprocal')
]

# These unary ops do not support all forms
#	(0x1b, 'ftoi'),
#	(0x1d, 'sext_8'),
#	(0x1e, 'sext_16'),
#	(0x2a, 'itof')

for opcode, mnemonic in unaryOps:
	rega = random.randint(0, 27)
	regb = random.randint(0, 27)
	regm = random.randint(0, 27)

	# Scalar/Scalar
	make_test_case(mnemonic + ' s' + str(rega) + ', s' + str(regb),
		make_a_instruction(0, opcode, rega, 0, regb, 0))

	# Vector/Scalar
	make_test_case(mnemonic + ' v' + str(rega) + ', s' + str(regb),
		make_a_instruction(1, opcode, rega, 0, regb, 0))

	# Vector/Scalar Masked
	make_test_case(mnemonic + '_mask v' + str(rega) + ', s' + str(regm) + ', s' + str(regb),
		make_a_instruction(2, opcode, rega, 0, regb, regm))

	# Vector/Scalar Invert Mask
	make_test_case(mnemonic + '_invmask v' + str(rega) + ', s' + str(regm) + ', s' + str(regb),
		make_a_instruction(3, opcode, rega, 0, regb, regm))

	# Vector/Vector
	make_test_case(mnemonic + ' v' + str(rega) + ', v' + str(regb),
		make_a_instruction(4, opcode, rega, 0, regb, 0))

	# Vector/Vector masked	
	make_test_case(mnemonic + '_mask v' + str(rega) + ', s' + str(regm) + ', v'
		+ str(regb), make_a_instruction(5, opcode, rega, 0, regb, regm))

	# Vector/Vector invert mask	
	make_test_case(mnemonic + '_invmask v' + str(rega) + ', s' + str(regm) + ', v'
		+ str(regb), make_a_instruction(6, opcode, rega, 0, regb, regm))

# XXX why is the source register set to 1 in this case?
make_test_case('move s1, 72', make_bprime_instruction(0, 0xf, 1, 1, 72))
make_test_case('move v1, 72', make_bprime_instruction(4, 0xf, 1, 1, 72))
make_test_case('move_mask v1, s3, 72', make_b_instruction(5, 0xf, 1, 1, 72, 3))

make_test_case('shuffle v1, v2, v3', make_a_instruction(4, 0xd, 1, 2, 3, 0))
make_test_case('shuffle_mask v1, s4, v2, v3', make_a_instruction(5, 0xd, 1, 2, 3, 4))
make_test_case('shuffle_invmask v1, s4, v2, v3', make_a_instruction(6, 0xd, 1, 2, 3, 4))

make_test_case('getlane s4, v5, s6', make_a_instruction(1, 0x1a, 4, 5, 6, 0))
make_test_case('getlane s4, v5, 7', make_bprime_instruction(1, 0x1a, 4, 5, 7))

# XXX HACK: These instructions should support all forms, but this is here in the interim
make_test_case('sext_8 s8, s9', make_a_instruction(0, 0x1d, 8, 0, 9, 0))
make_test_case('sext_16 s8, s9', make_a_instruction(0, 0x1e, 8, 0, 9, 0))
make_test_case('itof s8, s9', make_a_instruction(0, 0x2a, 8, 0, 9, 0))
make_test_case('ftoi s8, s9', make_a_instruction(0, 0x1b, 8, 0, 9, 0))
make_test_case('itof v8, v9', make_a_instruction(4, 0x2a, 8, 0, 9, 0))
make_test_case('ftoi v8, v9', make_a_instruction(4, 0x1b, 8, 0, 9, 0))
make_test_case('itof v8, s9', make_a_instruction(1, 0x2a, 8, 0, 9, 0))
make_test_case('ftoi v8, s9', make_a_instruction(1, 0x1b, 8, 0, 9, 0))

make_test_case('nop', make_b_instruction(0, 0, 0, 0, 0, 0))

#
# Comparisons
#

cmpOps = [
	(0x10, 'eq_i'),
	(0x11, 'ne_i'),
	(0x12, 'gt_i'),
	(0x13, 'ge_i'),
	(0x14, 'lt_i'),
	(0x15, 'le_i'),
	(0x16, 'gt_u'),
	(0x17, 'ge_u'),
	(0x18, 'lt_u'),
	(0x19, 'le_u'),
	(0x2c, 'gt_f'),
	(0x2d, 'ge_f'),
	(0x2e, 'lt_f'),
	(0x2f, 'le_f')
]

for opcode, mnemonic in cmpOps:
	rega = random.randint(0, 27)
	regb = random.randint(0, 27)
	regc = random.randint(0, 27)

	make_test_case('set' + mnemonic +  ' s' + str(rega) + ', s' + str(regb) + ', s' + str(regc),
		make_a_instruction(0, opcode, rega, regb, regc, 0))

	make_test_case('set' + mnemonic + ' s' + str(rega) + ', v' + str(regb) + ', s' + str(regc),
		make_a_instruction(1, opcode, rega, regb, regc, 0))

	make_test_case('set' + mnemonic + ' s' + str(rega) + ', v' + str(regb) + ', v' + str(regc),
		make_a_instruction(4, opcode, rega, regb, regc, 0))

	if mnemonic[-2:] == '_f':
		continue	# Can't do immediate for FP instructions
			
	imm = random.randint(0, 255)
	make_test_case('set' + mnemonic +  ' s' + str(rega) + ', s' + str(regb) + ', ' + str(imm),
		make_bprime_instruction(0, opcode, rega, regb, imm))

	make_test_case('set' + mnemonic + ' s' + str(rega) + ', v' + str(regb) + ', ' + str(imm),
		make_bprime_instruction(1, opcode, rega, regb, imm))
	

#
# Scalar load/stores
#

scalarMemFormats = [
	( 'load_u8', 0, 1 ), 
	( 'load_s8', 1, 1 ), 
	( 'load_u16', 2, 1 ), 
	( 'load_s16', 3 ,1 ), 
	( 'load_32', 4, 1 ),
	( 'load_sync', 5, 1 ),
	( 'store_8', 1, 0 ),
	( 'store_16', 3, 0 ),
	( 'store_32', 4, 0),
	( 'store_sync', 5, 0)
]

for stem, fmt, isLoad in scalarMemFormats:
	rega = random.randint(0, 27)
	regb = random.randint(0, 27)
	offs = random.randint(0, 255)
	make_test_case(stem + ' s' + str(rega) + ', (s' + str(regb) + ')',
		 make_cprime_instruction(isLoad, fmt, rega, regb, 0))	# No offset
	make_test_case(stem + ' s' + str(rega) + ', ' + str(offs) + '(s' + str(regb) + ')', 
		make_cprime_instruction(isLoad, fmt, rega, regb, offs))	# offset

#
# Vector load/stores
#

vectorMemFormats = [
	( 'v', 'v', 's', 7 ),
	( 'gath', 'scat', 'v', 0xd),
	( 'strd', 'strd', 's', 10)
]

for loadSuffix, storeSuffix, ptrType, op in vectorMemFormats:
	rega = random.randint(0, 27)
	regb = random.randint(0, 27)
	mask = random.randint(0, 27)
	offs = random.randint(0, 128) * 4

	loadStem = 'load_' + loadSuffix
	
	# Offset
	make_test_case(loadStem + ' v' + str(rega) + ', ' + str(offs) + '(' + ptrType + str(regb) + ')', 
		make_cprime_instruction(1, op, rega, regb, offs))
	make_test_case(loadStem + '_mask v' + str(rega) + ', s' + str(mask) + ', ' + str(offs) + '(' + ptrType + str(regb) + ')', 
		make_c_instruction(1, op + 1, rega, regb, offs, mask))
	make_test_case(loadStem + '_invmask v' + str(rega) + ', s' + str(mask) + ', ' + str(offs) + '(' + ptrType + str(regb) + ')', 
		make_c_instruction(1, op + 2, rega, regb, offs, mask))

	# No offset
	make_test_case(loadStem + ' v' + str(rega) + ', (' + ptrType + str(regb) + ')', 
		make_cprime_instruction(1, op, rega, regb, 0))
	make_test_case(loadStem + '_mask v' + str(rega) + ', s' + str(mask) + ', (' + ptrType + str(regb) + ')', 
		make_c_instruction(1, op + 1, rega, regb, 0, mask))
	make_test_case(loadStem + '_invmask v' + str(rega) + ', s' + str(mask)  + ', (' + ptrType + str(regb) + ')', 
		make_c_instruction(1, op + 2, rega, regb, 0, mask))

	storeStem = 'store_' + storeSuffix

	# Offset
	make_test_case(storeStem + ' v' + str(rega) + ', ' + str(offs) + '(' + ptrType + str(regb) + ')', 
		make_cprime_instruction(0, op, rega, regb, offs))
	make_test_case(storeStem + '_mask v' + str(rega) + ', s' + str(mask) + ', ' + str(offs) + '(' + ptrType + str(regb) + ')', 
		make_c_instruction(0, op + 1, rega, regb, offs, mask))
	make_test_case(storeStem + '_invmask v' + str(rega) + ', s' + str(mask) + ', ' + str(offs) + '(' + ptrType + str(regb) + ')', 
		make_c_instruction(0, op + 2, rega, regb, offs, mask))

	# No offset
	make_test_case(storeStem + ' v' + str(rega) + ', (' + ptrType + str(regb) + ')', 
		make_cprime_instruction(0, op, rega, regb, 0))
	make_test_case(storeStem + '_mask v' + str(rega) + ', s' + str(mask) + ', (' + ptrType + str(regb) + ')', 
		make_c_instruction(0, op + 1, rega, regb, 0, mask))
	make_test_case(storeStem + '_invmask v' + str(rega) + ', s' + str(mask) + ', (' + ptrType + str(regb) + ')', 
		make_c_instruction(0, op + 2, rega, regb, 0, mask))

# Control register
make_test_case('getcr s7, 9', make_cprime_instruction(1, 6, 7, 9, 0))
make_test_case('setcr s11, 13', make_cprime_instruction(0, 6, 11, 13, 0))

# Cache control
make_test_case('dflush s7', make_d_instruction(2, 7))
make_test_case('membar', make_d_instruction(4, 0))
make_test_case('dinvalidate s9', make_d_instruction(1, 9))
make_test_case('iinvalidate s11', make_d_instruction(3, 11))

# Cleanup
disasm_fp.close()
asm_fp.close()
