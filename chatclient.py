import socket
import threading
import re

class ChatClient:
    def __init__(self, host, port, name):
        self.h = host
        self.p = port
        self.name = name
        self.room = None
        self.socket = None
        self.t = None
    def enter_room(self, room):
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((self.h, self.p))
        s.sendall('\x00\x01' + self.protocol_len(room) + room + self.protocol_len(self.name) + self.name + '\xff')
        data = ""
        while True:
            buf = s.recv(4096)
            if not buf: break
            data += buf
            m = re.match("\x00(%s has entered this room.)\xff" % (self.name), data)
            if m is not None:
                self.room = room
                self.socket = s
                self.t = RecvThread(s)
                self.t.start()
                print m.group(1)
                return
            m = re.match(r"\x00(.*)\xff.*", data)
            if m is not None:
                print m.group(1)
                return
    def leave_room(self):
        if self.t is None:
            print "You're not in any room."
            return
        if self.t.isAlive():
            self.socket.shutdown(socket.SHUT_WR)
            self.socket = None
            self.room = None
            self.t = None
        else:
            self.t = None
    def speak(self, msg):
        if self.t is None:
            print "You're not in any room."
            return
        if self.t.isAlive():
            self.socket.sendall('\x00\x03' + self.protocol_len("") + self.protocol_len(self.name) + self.name + msg + '\xff')
            #self.socket.sendall('\x00\x03' + self.protocol_len(self.room) + self.room + self.protocol_len(self.name) + self.name + msg + '\xff')
        else:
            self.t = None
            
    def protocol_len(self, instr):
        ls = str(len(instr))
        l = len(ls)
        if l == 4:
            return ls
        elif l == 3:
            return "0" + ls
        elif l == 2:
            return "00" + ls
        elif l == 1:
            return "000" + ls
        else:
            raise ProtocolError("Cannot pack length for string \"%s\"" % (instr))

class RecvThread(threading.Thread):
    def __init__(self, socket):
        threading.Thread.__init__(self)
        self.socket = socket
    def run(self):
        data = ""
        while True:
            buf = self.socket.recv(4096)
            if not buf: break
            data = self.handle_data(data + buf)
    def handle_data(self, data):
        m = re.match(r"\x00(.*)\xff(.*)", data)
        if m is not None:
            self.logic(m.group(1))
            return m.group(2)
        else:
            return data
    def logic(self, data):
        print data
