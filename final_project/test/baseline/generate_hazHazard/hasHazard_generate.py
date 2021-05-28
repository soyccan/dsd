def fib(n):
    assert(n >= 3)
    output = [0, 1]
    for i in range(2,n):
        a = output[i-2]
        b = output[i-1]
        output = output + [a+b]
    return output

# Modify number of sequence here
# Note: nb >= 3 && nb <= 47 (if nb >= 48, there will be overflow)
nb = 16

fib_list  = fib(nb)
sort_list = sorted(fib_list, reverse=True)
write_list = fib_list + sort_list
print(fib_list)

TestBed_hasHazard_file = open("TestBed_hasHazard.v","w")
with open("TestBed_hasHazard_ref.v", "r") as f:
    for line in f:
        if "`define CheckNum" in line:
            line = line.replace("7'd7", "7'd{:d}".format(nb*2+1))
        TestBed_hasHazard_file.write(line)
        if "case( curaddr )" in line:
            break

for i, ans in enumerate(write_list):
    TestBed_hasHazard_file.write("\t\t7'd{:<3} : answer = 32'd{:<6};\n".format(i,ans))

TestBed_hasHazard_file.write("\t\t7'd{:<3} : answer = {};\n".format(nb*2,"`EndSymbol"))
TestBed_hasHazard_file.write("\t\tendcase\n\tend\nendmodule")
TestBed_hasHazard_file.close()

I_mem_hasHazard_file = open('I_mem_hasHazard','w')
with open("I_mem_hasHazard_ref", "r") as f:
    for line in f:
        if "//0x10//" in line:
            line = line.replace("0000000000000011", "{:b}".format(nb).zfill(16))
            line = line.replace("0x0003", "0x"+"{:x}".format(nb).zfill(4).upper())
        if "//0x64//" in line:
            line = line.replace("0000000000001000", "{:b}".format(nb*4-4).zfill(16))
            line = line.replace("0x0008", "0x"+"{:x}".format(nb*4-4).zfill(4).upper())
        if "//0x9C//" in line:
            line = line.replace("0000000000001100", "{:b}".format(nb*4).zfill(16))
            line = line.replace("0x000C", "0x"+"{:x}".format(nb*4).zfill(4).upper())
        if "//    0x10     //" in line:
            line = line.replace("0x0003", "0x"+"{:x}".format(nb).zfill(4).upper())
            line = line.replace("number = 3", "number = {:d}".format(nb))
        if "//    0x64     //" in line:
            line = line.replace("0x0008", "0x"+"{:x}".format(nb*4-4).zfill(4).upper())
        if "//    0x9C     //" in line:
            line = line.replace("0x000C", "0x"+"{:x}".format(nb*4).zfill(4).upper())
        I_mem_hasHazard_file.write(line)
I_mem_hasHazard_file.close()
