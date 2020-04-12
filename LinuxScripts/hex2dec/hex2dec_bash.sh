#!/bin/bash
# https://stackoverflow.com/questions/52485538/hex-to-dec-conversion-fail-for-more-than-16-results

obase=1000000000
ibase=$((1 << 7*4)) # only 7 hex digits, because 0xFFFFFFFF > 1000000000

inp="000000${1#0x}"                 # input value in $1 with optional 0x
inp=${inp:$((${#inp} % 7)):${#inp}}
# # echo inp len = ${#inp}

carry=0
MSDindex=0                  # index of the most significant digit in the result
result0=0    # the output value's digits will be stored in resultX variables, since sh and don't support arrays

print_result()
{
    # # echo "MSDindex = $MSDindex"
    eval echo -n \$result$MSDindex
    for i in $(seq $((MSDindex - 1)) -1 0)
    do
        eval printf "%09d" \$result$i
    done
    echo
}

# Add/multiply/whatever... a digit with the result
# $1 contains the operator
# $1 contains the digit to multiply with the array
mul()
{
    # echo mul $1
    carry=0
    for i in $(seq 0 $MSDindex)
    do
        eval res=$(( ($1 "*" result$i) + carry ))
        # eval # echo "op = \$1 '*' result$i" = $(($1 "*" result$i))
        eval result$i=$((res % obase))
        # echo res=\($1 "*" result$i\) + $carry
        carry=$((res / obase))
        # eval # echo res = $res, carry = $carry, i = $i, result$i = \$result$i
    done
    
    while [ $carry -ne 0 ]
    do
        MSDindex=$((MSDindex + 1))
        eval result$MSDindex=$((carry % obase))
        carry=$((carry / obase))
        # echo == carry = $carry
    done
    
    # print_result
}

# Add/multiply/whatever... a digit with the result
# $1 contains the operator
# $1 contains the digit to multiply with the array
add()
{
    # echo add $1
    eval res=$(($1 + result0))
    # eval # echo "op = $1 + result0" = $(($1 + result0))
    eval result0=$((res % obase))
    carry=$((res / obase))
    # eval # echo res = $res, carry = $carry, i = 0, result0 = \$result0
    
    i=1
    while [ $carry -ne 0 ]
    do
        eval res=$((carry + result$i))
        eval result$i=$((res % obase))
        carry=$((res / obase))
        # echo ==== carry = $carry
        if [ $i -gt $MSDindex ]; then MSDindex=$i; fi
        i=$((i + 1))
    done
    
    # print_result
}

# main conversion loop
while [ -n "$inp" ]   # iterate through the hex digits
do
    # echo "----------------- inp = $inp, len = ${#inp}, hexdigit = ${inp:0:7}"
    hexdigit=${inp:0:7} # $(printf "%d" "$((0x${inp: -7}))") # or better $((0x${inp: -7}))
    # result = result*input_base + hexdigit
    mul $ibase
    add 0x$hexdigit
    
    if [ ${#inp} -gt 7 ]; then
        inp=${inp: $((7 - ${#inp}))}
    else
        unset inp
    fi
done

# # echo final result
print_result


