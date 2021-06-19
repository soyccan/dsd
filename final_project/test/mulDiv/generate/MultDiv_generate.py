def factorial(n):
    output = 1
    for i in range(1,n+1):
        output = output * i
    return output

# Modify number of factorial here
# Note: nb >= 1 and nb <= 12
nb = 8

#assertion
assert(nb >= 1)
assert(nb <= 12)

product = factorial(nb)
print("{:d}! = {:d}".format(nb,product))

TestBed_MultDiv_file = open("TestBed_MultDiv.v","w")
with open("TestBed_MultDiv_ref.v", "r") as f:
    for line in f:
        if "2'd0  : answer = 32'd1;" in line:
            line = line.replace("32'd1", "32'd{:d}".format(product))
        TestBed_MultDiv_file.write(line)
TestBed_MultDiv_file.close()

I_mem_MultDiv_file = open('I_mem_MultDiv','w')
with open("I_mem_MultDiv_ref", "r") as f:
    for line in f:
        if "//0x68//" in line:
            line = line.replace("0000000000000001", "{:b}".format(nb).zfill(16))
            line = line.replace("0x0001", "0x"+"{:x}".format(nb).zfill(4).upper())
        I_mem_MultDiv_file.write(line)
I_mem_MultDiv_file.close()
