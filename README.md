# With adding some FPGA demos, I am planning to sunset this project. The technical debt of the project accumulated so much, I might be better off reimplementing a core. Current avaible demos can be found here.

A RISCV IM(soon to be F) core.

 Vanilla I set implementation of the core can be found under my VLSI II respitory. That implementation lacks the elactic interface between execute and the memory stages.

 At the current state of the core, it fully supports (as far as I have tested with my C codes) M set. The M set itself is around 800 LUTS in my BASYS3 board. This is because of my questionable choices in the multiply and division algorithms. Current problems that swells the size of M set are:
 - Multiply logic is a state machine which can easily be implemented as an accumulator architecture but I have implemented it as a pipelined logic.
 - Division logic is needlessly performance-oriented. It can divide in as many fewer cycles as possible without being the critical path of the core. The required preprocessing and extra logic puts many extra LUTS on the circuit.

At the time of writing the standalone core supports 100MHZ operation in my BASYS3 board in default synthesis settings.

An FPGA wrapper that involves an AXI lite interface for communication is included. 
# I have resorted to the following solution Because the Brams need 2 cycles for write and read operations.
A clock with twice the frequency of the core is connected to the BRAM. This eliminated the need for handshakes in the fetch stage. Also since two frequencies are divisible by a whole number, there is no need for synchronizers to handle the clock domain crossings. 

F set only lacks the division part. I am planning to implement a radix 4 division algorithm for the division in the future. Until then you view find my [floating point unit respitory](https://github.com/Erincutku007/Floating-Point-Unit) for the current state of my F set implementation. 

PS: the core is named after my dog.
