#!/bin/bash

echo "Testing hex2dec conversion"
echo "-----"
echo "BC will be used as the reference tool. If any tools produce different output \
an 'x' will be output in that line"
echo "Comment out the tools that are not available on your system"
echo "GAWK has a bug related to reading big hex numbers, especially without the '--bignum' flag \
so it often produce wrong output in the last digits"

valuelist="15ABC12345AFDA325
1AAAAAAAF12233445566778DFEF
1AAFDDAEBCAAAAAF12233445566778DFEF
1AF12233445566778DFEF
1DAF5ABC12345AFDA325
1F12233445566778DFEF
2111111111111111DDDAFC
2111137875433111111DDDAFC
23513A123111111111111111DDDAFC
2A11ADECDAD242164D5C11DDDAFC
2A1841444BDC1DDDAFC
2A111111111111111DDDAFC
2A123111111111111111DDDAFC
361037073401E5313436BA5C23513A123111111111111111DDDAFC
361037073401E5313436BA5C23513A12311BDEF111DDDAFC
445313436BA5C23513A123111111111111111DDDAFC
445313436BA5C23513A1231111187644211111DDDAFC
44FE5313436BA5C23513A123111111111111111DDDAFC
44FE5313436BA5C23513A12311123466311111DDDAFC
46BA5C23513A12311154234845111DDDAFC
46BA5C23513A123111111111111111DDDAFC
46BA5C23513A12311413143111111DDDAFC
DEA52E67636C1037F0734013644FE5313436BA5C23513A1235445454CC26A26C4BD264D9DAFC24FDC5EB5A6C
6763610370734013644FE5313436BA5C23513A123111111111111111DDDAFC
676361037073401E5313436BA5C23513A123111111111111111DDDAFC
70734013644FE5313436BA5C23513A123111111111111111DDDAFC
AEF1DADFEBCA32FD32DA325
AEF1DAF5ABC12345AFDA325
BA5C23513A123116541314111111DDDAFC
BA5C23513A123111111111111111DDDAFC
BC23513A123111111111111111DDDAFC"

while read -r v; do
    bc_res=$(echo "ibase=16; $v" | bc | tr -d '\\' | tr -d "\n")
    hex2dec_ash_res=$(bash ./hex2dec_ash.sh $v)
    hex2dec_bash_res=$(./hex2dec_bash.sh $v)
    perl_res=$(perl -Mbignum -le "print hex '$v'")
    python_res=$(python -c "print int('$v', 16)")
    powershell_res=$(powershell -Command "[Numerics.BigInteger]::Parse('$v', 'AllowHexSpecifier')")
    gawkbignum_res=$(gawk --bignum -v n=0x$v 'BEGIN {print strtonum(n)}')
    gawk_res=$(gawk -v n=0x$v 'BEGIN {print strtonum(n)}')
    
    echo -ne "\n--------------- 0x$v:"
    echo -ne "\n            bc: $bc_res"
    echo -ne "\n   hex2dec_ash: $hex2dec_ash_res $(if [[ $hex2dec_ash_res != $bc_res ]]; then echo -n "x"; fi)"
    echo -ne "\n  hex2dec_bash: $hex2dec_bash_res $(if [[ $hex2dec_bash_res != $bc_res ]]; then echo -n "x"; fi)"
    echo -ne "\n          perl: $perl_res $(if [[ $perl_res != $bc_res ]]; then echo -n "x"; fi)"
    echo -ne "\n        python: $python_res $(if [[ $python_res != $bc_res ]]; then echo -n "x"; fi)"
    echo -ne "\n    powershell: $powershell_res $(if [[ $powershell_res != $bc_res ]]; then echo -n "x"; fi)"
    echo -ne "\n    gawkbignum: $gawkbignum_res $(if [[ $gawkbignum_res != $bc_res ]]; then echo -n "x"; fi)"
    echo -ne "\n          gawk: $gawk_res $(if [[ $gawk_res != $bc_res ]]; then echo -n "x"; fi)"
    echo
done <<< "$valuelist"

