from tkinter import *
import serial
import threading
import time
import sys


def ventana():
    
    #codigo para convertir los strings en entradas
    global potx
    global poty
    potx = 120
    poty = 120
    global x
    global y
    global xanterior
    global yanterior
    
    x = 0
    y = 0
    xanterior = x
    yanterior = y
    
    raiz = Tk()
    raiz.title("Etch a sketch")
    raiz.geometry("900x900")

    raiz.config(bg ="grey")
    canv = Canvas(raiz, width = 800, height = 800, bg = "white")
    canv.pack(fill = "both", expand="True")
    
    while True:
        xanterior = x
        yanterior = y
        if (potx <= 100):
            x = x -1  
            
            if x == -1:
                x = 1500
            delay = (9/10000)*potx+0.01
            time.sleep(delay)
            canv.create_line(xanterior,yanterior,x,y, fill = "red")        
        if 155 <= potx:
            x = x+1
            if x == 1500:
                x = 0
            delay = (-9/10000)*(potx-155)+0.1
            time.sleep(delay)
            canv.create_line(xanterior,yanterior,x,y, fill = "red")
            
        if poty <= 100:
                y = y + 1
                if y == 751:
                    y = 0
                delay = (9/12400) * poty +0.01
                time.sleep(delay)
                canv.create_line(xanterior,yanterior,x,y, fill = "red")
        if 155 <= poty:
                y = y - 1
                if y == -1:
                    y = 750
                delay = (-9/10000) * (poty - 155) + 0.1
                time.sleep(delay)
                canv.create_line(xanterior,yanterior,x,y, fill = "red")
              

        #canv.create_line(x1, y1, x2, y2, fill = "color")
        
        print("potenciometro eje x",potx)
        print("potenciometro eje y",poty)
        print("xanterior", xanterior)
        print("x", x)
        print("yanterior", yanterior)
        print("y", y)
        
        time.sleep(0.4)
        raiz.update_idletasks()
        raiz.update()
        
#         def borrar():
#             canv.delete("all") 
#         return
#                
#         B = Button(raiz, text = "Borrar dibujo", command = borrar)
#         B.pack()
#         
       

        
        
        


def Comunicacion():
    pic = serial.Serial(port='COM3', baudrate=9600, parity = serial.PARITY_NONE,stopbits=serial.STOPBITS_ONE,bytesize= serial.EIGHTBITS,timeout = 0)
    pic.flushInput()
    pic.flushOutput()
        
    while True:
        pic.flushInput()
            
        time.sleep(0.4)
        pic.readline()
        read = pic.readline().decode('ascii')
        
        valoresxy = read.split(",")
        global potx
        global poty
        potx = int(valoresxy[0])
        poty = int(valoresxy[1])
        
        print(read)
    return





t1 = threading.Thread(target = ventana)
t2 = threading.Thread(target = Comunicacion)

t1.start()
t2.start()

t1.join()
t2.join()







