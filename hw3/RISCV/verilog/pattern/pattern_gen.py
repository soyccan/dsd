import random

class write_pattern(object):
    def __init__(self):
        self.counter = 0
        
    def write_line(self, str_in):
        assert(len(str_in) == 8)
        substr_0 = str_in[0:2]
        substr_1 = str_in[2:4]
        substr_2 = str_in[4:6]
        substr_3 = str_in[6:8]
        counter_str = '{:x}'.format(self.counter).zfill(2).upper()
        str_out = '{}_{}_{}_{} // '.format(substr_3, substr_2, substr_1, substr_0) + \
                  '{}_{}_{}_{} //'.format(substr_0, substr_1, substr_2, substr_3) + \
                  '0x{}//'.format(counter_str)
        self.counter = self.counter + 4
        return str_out

def add_underline(str_in):
    substr_0 = str_in[0:2]
    substr_1 = str_in[2:4]
    substr_2 = str_in[4:6]
    substr_3 = str_in[6:8]
    return '{}_{}_{}_{} (hex)'.format(substr_0, substr_1, substr_2, substr_3)

if __name__ == '__main__':
    # Modify your test pattern here
    x = random.randint(1,100)
    y = random.randint(1,100)

    data1 = '{:x}'.format(x).zfill(8).upper()
    data2 = '{:x}'.format(y).zfill(8).upper()
    and_result = '{:x}'.format(x & y).zfill(8).upper()
    or_result = '{:x}'.format(x | y).zfill(8).upper()
    slt_result = '{:x}'.format(x < y).zfill(8).upper()
    add_result = '{:x}'.format(x + x).zfill(8).upper()
    sub_result = '{:x}'.format(2*x - x).zfill(8).upper()
    
    with open('data.txt', 'w') as f_data:
        data = write_pattern()
        f_data.write(data.write_line(data1) + '\n')
        f_data.write(data.write_line(data2))

    with open('ans.txt', 'w') as f_ans:
        ans = write_pattern()
        f_ans.write(ans.write_line(data1) + '\n')
        f_ans.write(ans.write_line(data2) + '\n')
        f_ans.write(ans.write_line(and_result) + '\n')
        f_ans.write(ans.write_line(or_result) + '\n')
        f_ans.write(ans.write_line(slt_result) + '\n')
        f_ans.write(ans.write_line(add_result) + '\n')
        f_ans.write(ans.write_line(sub_result))

    print('x      : ' + add_underline(data1))
    print('y      : ' + add_underline(data2))
    print('x & y  : ' + add_underline(and_result))
    print('x | y  : ' + add_underline(or_result))
    print('x < y  : ' + add_underline(slt_result))
    print('x + x  : ' + add_underline(add_result))
    print('2x - x : ' + add_underline(sub_result))