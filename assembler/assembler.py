import sys

def GenerateOutputFileName(raw_file_name):
    splitted_name = raw_file_name.split('.')
    return f'{splitted_name[0]}.bin'

def GenerateROMLine(instruction, index):
    return f'tmp({index}) := {instruction}; \n'

opcodes = {
    "ADD": "0001",
    "SUB": "0010",
    "LEA": "0011",
    "MOVMR": "0100",
    "MOVRM": "0101",
    "MOVRR": "0110",
    "CMP": "0111",
    "JE": "1000",
    "JMP": "1001"
}

regs = {
    "R1": "000",
    "R2": "001",
    "R3": "010",
    "R4": "011",
    "R5": "100",
    "R6": "101",
    "R7": "110",
    "R8": "111"
}

labels = {}

file_name = str(sys.argv[1])

f = open(file_name, "r")
output_file = open(f'{GenerateOutputFileName(file_name)}', 'w')

line_number = 0

for line in f:
    args = line.replace(",", "").replace("\n", "").replace(":", "").replace("$", "").split(" ")
    opcode = opcodes.get(args[0], False)
    if not opcode:
        labels[args[0]] = line_number
        continue
    RA = "000"
    RB = "000"
    RC = "000"
    endereco_bin = "000000000"
    if opcode == opcodes["ADD"] or opcode == opcodes["SUB"]:
        RA = regs[args[1]]
        RB = regs[args[2]]
        RC = regs[args[3]]

    elif opcode == opcodes["LEA"] or opcode == opcodes["MOVRM"]:
        RC = regs[args[1]]
        value = bin(int(args[2]))[2:]
        endereco_bin = endereco_bin[:(len(endereco_bin) - len(value))] + value

    elif opcode == opcodes["MOVMR"]:
        RC = regs[args[2]]
        endereco_int = bin(int(args[1]))[2:]
        endereco_bin = endereco_bin[:(len(endereco_bin) - len(endereco_int))] + endereco_int

    elif opcode == opcodes["MOVRR"]:
        RA = regs[args[1]]
        RC = regs[args[2]]

    elif opcode == opcodes["CMP"]:  
        RA = regs[args[1]]
        RB = regs[args[2]]

    elif opcode == opcodes["JMP"] or opcode == opcodes["JMP"]: 
        endereco_int = bin(int(labels[args[1]]))[2:]
        endereco_bin = endereco_bin[:(len(endereco_bin) - len(endereco_int))] + endereco_int

    instruction = f'{opcode}{RA}{RB}{RC}{endereco_bin}'

    output_file.write(GenerateROMLine(instruction, line_number))
    line_number += 1


    
#tmp(linha):
f.close()
output_file.close()
