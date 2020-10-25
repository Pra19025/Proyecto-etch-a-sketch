import serial
import time
import sys

pic = serial.Serial(port='COM3', baudrate=9600, parity = serial.PARITY_NONE,stopbits=serial.STOPBITS_ONE,bytesize= serial.EIGHTBITS,timeout = 0)
pic.flushInput()
pic.flushOutput()
    
while True:
    pic.flushInput()
        
    time.sleep(0.4)
    pic.readline()
    read = pic.readline().decode('ascii')
    print(read)
        










