#include <iostream>
#include <iomanip>
#include <vector>
#include <cstdint>
#include <cstdlib>
#include <limits>

#ifdef __SIZEOF_INT128__
using limb_type         = uint64_t;
using limb2_type        = __uint128_t;
const limb_type base    = 10ULL*1000*1000*1000*1000*1000*1000;  // base 10¹⁹ for 64-bit computers
const auto numDigits    = 19;
#else
using limb_type         = uint32_t;
using limb2_type        = uint64_t;
const limb_type base    = 1ULL*1000*1000*1000;                  // base 10⁹ for 32-bit computers
const auto numDigits    = 9;
#endif


// Multiply bigInt by num
void mul(std::vector<limb_type> &bigInt, uint32_t num)
{
    limb_type carry = 0;
    for (auto &digit: bigInt)
    {
        limb2_type prod = (limb2_type)digit*num + carry;
        digit = prod % base;
        carry = prod / base;
    }
    if (carry)
        bigInt.push_back(carry);
}

void print(const std::vector<limb_type> &bigInt)
{
    int i = (int)bigInt.size() - 1;
    std::string msd = std::to_string(bigInt[i]);
    std::cout << msd;
    i--;
    for (; i >= 0; i--)
    {
        std::cout << std::setfill('0') << std::setw(numDigits) << bigInt[i];
    }
    std::cout << '\n' << (msd.size() + (bigInt.size() - 1)*numDigits) << " digits\n";
}

void longFactorials(uint32_t n) {
    std::vector<limb_type> result;
    result.reserve(20);
    result.push_back(1);
    for (uint32_t i = 2; i <= n; i++)
    {
        mul(result, i);
    }
    print(result);
}

int main(int argc, char* argv[])
{
    uint32_t n;
    if (argc != 2)
    {
        std::cout << "n = ";
        std::cin >> n;
        std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    }
    else
    {
        n = std::strtoul(argv[1], nullptr, 10);
    }
    
    std::cout << "\nn! = ";
    longFactorials(n);

    return 0;
}

