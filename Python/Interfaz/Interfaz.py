from tkinter import *
from serial import *
import time


if __name__ == "__main__":
    name = input("Introduce el nombre del puerto:")
    rate = 10417

    pic = Serial(port=name, baudrate=rate)
    while True:
        time.sleep(0.5)
        lectura = pic.read(1)
        print(lectura)
        


def Direccion(self)
    self.recibir()
    
    

def recibir(self):
        self.dataRead = self.puerto.readline()
    



raiz = Tk()
raiz.title("Etch a sketch")
#raiz.geometry("1500x1000")

raiz.config(bg ="grey")

canv = Canvas(raiz, width = 300, height = 200, bg = "white")
canv.pack(fill = "both", expand="True")


#canv.create_line(x1, y1, x2, y2, fill = "color")
canv.create_line(0,10,100,120)

def borrar():
    canv.delete("all")

B = Button(raiz, text = "Borrar dibujo", command = borrar)
B.pack()


raiz.mainloop()