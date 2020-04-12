#!/bin/ash

obase=1000000000    # 1e9, the largest power of 10 that fits in int32_t
ibase=$((1 << 7*4)) # only 7 hex digits, because 0xFFFFFFFF > 1e9

inp="000000${1#0x}"                 # input value in $1 with optional 0x
inp=${inp:$((${#inp}%7)):${#inp}}   # pad the string length to a multiple of 7

carry=0
# workaround, since sh and ash don't support arrays
result0=0       # the output value's digits will be stored in resultX variables in little endian
MSDindex=0      # index of the most significant digit in the result

print_result()
{
    eval echo -n \$result$MSDindex  # print MSD
    if [ $MSDindex -gt 0 ]; then    # print remaining digits
        for i in $(seq $((MSDindex-1)) -1 0); do eval printf "%09d" \$result$i; done
    fi
    echo
}

# Multiply a digit with the result
# $1 contains the value to multiply with the result array
mul()
{
    carry=0
    for i in $(seq 0 $MSDindex); do
        eval let res="$1\\*result$i+carry"
        eval let result$i=res%obase
        let carry=res/obase
    done
    
    while [ $carry -ne 0 ]; do
        let MSDindex=MSDindex+1
        eval let result$MSDindex=carry%obase
        let carry=carry/obase
    done
}

# Add a digit with the result
# $1 contains the digit to add with the array
add()
{
    eval let res=$1+result0
    eval let result0=res%obase
    let carry=res/obase
    
    i=1
    while [ $carry -ne 0 ]
    do
        eval let res=carry+result$i
        eval let result$i=res%obase
        let carry=res/obase
        if [ $i -gt $MSDindex ]; then MSDindex=$i; fi
        let i=i+1
    done
}

# main conversion loop
while [ -n "$inp" ]     # iterate through the hex digits, 7 at a time
do
    hexdigit=${inp:0:7}
    mul $ibase          # result = result*input_base+hexdigit
    add 0x$hexdigit
    
    if [ ${#inp} -gt 7 ]; then
        inp=${inp: $((7-${#inp}))}
    else
        unset inp
    fi
done

print_result
