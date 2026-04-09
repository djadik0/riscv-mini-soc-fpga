#include "platform.h"  

volatile uint32_t result = 0;
volatile uint32_t a = 5;  


extern "C" void int_handler()
{
    uint32_t sw_val = sw_ptr->value;

    // Если sw[15] == 1, обновляем a значением из sw[14:0]
    if(sw_val & (1 << 15)) {
        a = sw_val & 0x7FFF;  
    }


    uint32_t loop_count = (sw_val & (1 << 15)) ? (sw_val & 0x7FFF) : (sw_val & 0x7FFF);
    uint32_t out = 0;


    uint32_t val = a;

    for(uint32_t i = 0; i < loop_count; ++i)
        out += val;

    result = out;
    led_ptr->value = result;   
}


int main()
{
    while(1) {}
    return 0;
}
