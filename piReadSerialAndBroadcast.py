import serial
import time

UDP_IP = "000.000.000"
UDP_PORT = "80"


def getTimeStamp(initTime):
    elapsedSecs = initTime - time.time();
    days = int(elapsedSecs/86400);
    hours = int((elapsedSecs-days)/3600);
    minutes= int((elapsedSecs-days-hours)/60);
    seconds = elapsedSecs-days-hours-minutes;

    timeStamp = ""
    timestamp = timestamp + days + ":" + hours + ":" + minutes + ":" + seconds

    return timestamp


##must have dataLog.txt file in currdir
def main():
    dataFile = open("dataLog.txt", 'w')
    initTime = time.time();

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
    sock.bind((UDP_IP, UDP_PORT))

    while True:
        try:
            dataFile = open("dataLog.txt", 'w')
            ser = serial.Serial('/dev/cu.SLAB_USBtoUART', 115200)
            serialData = ser.readLine()
            if serialData != "":
                dataFile.write(getTimeStamp(initTime) + "," + serialData)
            dataFile.close();

            ## here it should update a file being hosted/and broadcast on a local wifi
            ## that other machines can access???



if __name__ == '__main__':
    main()
