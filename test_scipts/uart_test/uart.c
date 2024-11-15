#define AXIUARTADDRRESS 0xC0000000
#define FPGAIOADDRRESS 0x80000000

int main() 
{
    volatile int *uart_ptr = AXIUARTADDRRESS;
    volatile int *io_ptr = FPGAIOADDRRESS;
    volatile int *test_adr = 2000;
    volatile int i,j;
    volatile int status,rx_fifo_status;
    volatile int uart_rx_data;

    *io_ptr = 15;
    i = 0;

    while (1) {
    rx_fifo_status = 0;
    while (rx_fifo_status == 0) {
        status = *(uart_ptr+2);
        rx_fifo_status = status & 1;
        *io_ptr = ((status << 8) | rx_fifo_status);
    }
    
    for (i = 0; i < 1000000; i++)
    {
    }

    uart_rx_data = *(uart_ptr);
    *io_ptr = uart_rx_data;

    for (i = 0; i < 5000000; i++)
    {
    }

    }

    *io_ptr = 0;

    return 0;
}




