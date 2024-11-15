Currently, there are two available demos. The demo codes can are run on  a BASYS3 card by myself. Unfortunately the ANN demo does not fit to the BASYS3 card. I am currently trying to find a solution to it.

 - UART demo
 - MNIST dataset ANN demo.
 
 The toolchain I used to generate ROM and RAM data can be found [here](https://github.com/yavuz650/RISC-V/tree/main/test).
 
 The referances for the MNIST demo are:
 [MNIST ANN demo from scratch](https://medium.com/@ombaval/building-a-simple-neural-network-from-scratch-for-mnist-digit-recognition-without-using-7005a7733418) I used this source to train an ANN. I have modified the end of the code to include scripts to export the model weights so they can be added to C script easily.
There are two C scripts. For some reason my decently written script does not work on the processor but when I spoonfeed the data into the processor as implemented in the test_alt.c file it works.  
