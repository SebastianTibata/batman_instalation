import socket
import threading

PORT = 5005
DESTINOS = ["192.168.100.4"]
BUFFER_SIZE = 1024

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(("0.0.0.0", PORT))  # Escucha en todas las interfaces (incluida bat0)

def recibir():
    while True:
        try:
            data, addr = sock.recvfrom(BUFFER_SIZE)
            print(f"\n De {addr[0]}: {data.decode()}\n> ", end="")
        except Exception as e:
            print(f"\n Error al recibir: {e}")

threading.Thread(target=recibir, daemon=True).start()

print(f"Chat BATMAN activo. Enviando a: {', '.join(DESTINOS)}")
print("Escribe tu mensaje. Escribe 'salir' para terminar.")

while True:
    try:
        mensaje = input("> ")
        if mensaje.lower() == "salir":
            break
        for ip in DESTINOS:
            try:
                sock.sendto(mensaje.encode(), (ip, PORT))
                print(f" Enviado a {ip}")
            except Exception as e:
                print(f"Error al enviar a {ip}: {e}")
    except KeyboardInterrupt:
        break
