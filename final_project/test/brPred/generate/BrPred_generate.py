# modify # of the pattern here
nb_notBr   = 1
nb_interBr = 1
nb_Br      = 1

assert(nb_notBr>0)
assert(nb_interBr>0)
assert(nb_Br>0)

print("a = {:d}, b = {:d}, c = {:d}".format(nb_notBr, nb_interBr, nb_Br))

I_mem_BrPred_file = open("I_mem_BrPred","w")
with open("I_mem_BrPred_ref", "r") as f:
    for line in f:
        if "//0x04//" in line:
            line = line.replace("a = 10", "a = {:d}".format(nb_notBr))
            line = line.replace("0000000000001010", "{:b}".format(nb_notBr).zfill(16))
            line = line.replace("0x000A", "0x"+"{:x}".format(nb_notBr).zfill(4).upper())
        if "//0x08//" in line:
            line = line.replace("b = 20", "b = {:d}".format(nb_interBr))
            line = line.replace("0000000000010100", "{:b}".format(nb_interBr).zfill(16))
            line = line.replace("0x0014", "0x"+"{:x}".format(nb_interBr).zfill(4).upper())
        if "//0x0C//" in line:
            line = line.replace("c = 30", "c = {:d}".format(nb_Br))
            line = line.replace("0000000000011110", "{:b}".format(nb_Br).zfill(16))
            line = line.replace("0x001E", "0x"+"{:x}".format(nb_Br).zfill(4).upper())
        I_mem_BrPred_file.write(line)        
I_mem_BrPred_file.close()

import shutil
shutil.copyfile("TestBed_BrPred_ref.v", "TestBed_BrPred.v")
