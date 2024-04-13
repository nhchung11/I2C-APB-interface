## I2C FSM
![FSM Image](https://github.com/nhchung11/verilog-code/blob/master/Images/FSM.PNG)

## APB interface block diagram
![APB interface](https://github.com/nhchung11/verilog-code/blob/master/Images/Block_diagram.png)

## User guide
### Write
1. Config register map in order
2. Enable in commands register connect to I2C master enable
3. W_enable connects to FIFO TX write enable
4. I2C master enables FIFO TX read enable based on FSM
### Read
1. Config register map in order
2. Enable in command register connect to I2C master enable
3. I2C_master enalbes FIFO RX write enable based on FSM
4. R_enable in command register connect to FIFO RX read enable
