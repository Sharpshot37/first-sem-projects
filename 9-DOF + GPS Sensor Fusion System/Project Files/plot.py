import serial
import csv
import time
import folium
import matplotlib.pyplot as plt
from datetime import datetime


# Add this at the top to simulate data for testing
SIMULATE = False  # Set to True for testing

if SIMULATE:
    import random
    # Fake serial class for testing
    class FakeSerial:
        def __init__(self, *args, **kwargs):
            pass
        def in_waiting(self):
            return 1
        def readline(self):
            time.sleep(0.01)  # Simulate 100Hz
            fake_data = [
                random.uniform(29.7, 29.8),  # lat
                random.uniform(-95.4, -95.3),  # lon
                random.uniform(10, 100),  # alt
                random.randint(4, 12),  # sats
                random.uniform(0.8, 2.0),  # hdop
                random.uniform(0, 50),  # speed
                random.uniform(-45, 45),  # roll
                random.uniform(-45, 45),  # pitch
                random.uniform(0, 360),  # yaw
                random.uniform(0, 360),  # hmag
                random.uniform(0, 360),  # hgps
                random.uniform(-1, 1),  # ax
                random.uniform(-1, 1),  # ay
                random.uniform(-1, 1),  # az
                random.uniform(-100, 100),  # gx
                random.uniform(-100, 100),  # gy
                random.uniform(-100, 100),  # gz
                random.uniform(-50, 50),  # mx
                random.uniform(-50, 50),  # my
                random.uniform(-50, 50),  # mz
            ]
            return (','.join(map(str, fake_data)) + '\n').encode()
        def close(self):
            pass
    
    ser = FakeSerial()
else:
    ser = serial.Serial('COM4', 115200, timeout=1)



time.sleep(2)
timestampL=time.time()
csvfile=f"sensor_data_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
count=0

with open(csvfile, 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['timestamp', 'lat', 'lon', 'alt', 'sats', 'hdop', 'speed',
                     'roll', 'pitch', 'yaw', 'hmag', 'hgps',
                     'accel_x', 'accel_y', 'accel_z',
                     'gyro_x', 'gyro_y', 'gyro_z',
                     'mag_x', 'mag_y', 'mag_z'])

timestamp=[]
lat=[]
lon=[]
alt=[]
sats=[]
hdop=[]
speed=[]
roll=[]
pitch=[]
yaw=[]
hmag=[]
hgps=[]
accelx=[]
accely=[]
accelz=[]
gx=[]
gy=[]
gz=[]
mx=[]
my=[]
mz=[]



def appendit(reader):
    lat.append(float(reader[0]))
    lon.append(float(reader[1]))
    alt.append(float(reader[2]))
    sats.append(float(reader[3]))
    hdop.append(float(reader[4]))
    speed.append(float(reader[5]))
    roll.append(float(reader[6]))
    pitch.append(float(reader[7]))
    yaw.append(float(reader[8]))
    hmag.append(float(reader[9]))
    hgps.append(float(reader[10]))
    accelx.append(float(reader[11]))
    accely.append(float(reader[12]))
    accelz.append(float(reader[13]))
    gx.append(float(reader[14]))
    gy.append(float(reader[15]))
    gz.append(float(reader[16]))
    mx.append(float(reader[17]))
    my.append(float(reader[18]))
    mz.append(float(reader[19]))


plt.ion()
fig,axs=plt.subplots(4,2,figsize=(12,10))
fig.suptitle('9-DOF Sensor Data', fontsize=16)

def plots():
    for ax in axs.flatten():
        ax.clear()
    axs[0,0].plot(timestamp, roll, label='Roll')  
    axs[0,0].plot(timestamp, pitch, label='Pitch')  
    axs[0,0].plot(timestamp, yaw, label='Yaw')  
    axs[0,0].set_xlabel('Time')  
    axs[0,0].set_ylabel('Degrees')  
    axs[0,0].set_title("Roll, Pitch, Yaw Plot")  
    axs[0,0].legend()
    
    axs[1,0].plot(timestamp, accelx, label='X')  
    axs[1,0].plot(timestamp, accely, label='Y')  
    axs[1,0].plot(timestamp, accelz, label='Z')  
    axs[1,0].set_xlabel('Time')  
    axs[1,0].set_ylabel('Degrees')  
    axs[1,0].set_title("Accelerometer Raw Plot")  
    axs[1,0].legend()

    axs[2,0].plot(timestamp, gx, label='X')  
    axs[2,0].plot(timestamp, gy, label='Y')  
    axs[2,0].plot(timestamp, gz, label='Z')  
    axs[2,0].set_xlabel('Time')  
    axs[2,0].set_ylabel('Gyroscope')  
    axs[2,0].set_title("Gyroscope Raw Plot")  
    axs[2,0].legend()

    axs[3,0].plot(timestamp, mx, label='X')  
    axs[3,0].plot(timestamp, my, label='Y')  
    axs[3,0].plot(timestamp, mz, label='Z')  
    axs[3,0].set_xlabel('Time')  
    axs[3,0].set_ylabel('Magnetometer')  
    axs[3,0].set_title("Magnetometer Raw Plot")  
    axs[3,0].legend()

    axs[0,1].plot(hmag, hgps)    
    axs[0,1].set_xlabel('Magnetometer Heading')  
    axs[0,1].set_ylabel('GPS Heading')  
    axs[0,1].set_title("Heading Comparison Plot") 

    fig.colorbar(axs[1,1].scatter(lat,lon),ax=axs[0,1],extend='both') 

    axs[2,1].plot(timestamp, alt)    
    axs[2,1].set_xlabel('Time')  
    axs[2,1].set_ylabel('Altitude')  
    axs[2,1].set_title("Altitude Plot") 

    axs[3,1].plot(timestamp, speed)    
    axs[3,1].set_xlabel('Time')  
    axs[3,1].set_ylabel('Speed')  
    axs[3,1].set_title("Speed Plot") 

    plt.pause(0.01)


one=0
while True:
    value =ser.readline().decode('utf-8', errors='ignore').strip()
    reader1=value.split(',')
    with open(csvfile,'a',newline='') as file:
        csv.writer(file).writerow(reader1)
    if len(reader1) == 20:
        appendit(reader1)
        timestamp.append(time.time()-timestampL)
    else:
        continue
    '''
    if one>0:
        folium.PolyLine(locations=[lat,lon]).add_to(map)
    if one==0:
        map=folium.Map(location=(lat[0],lon[0]))
        folium.Marker(location=[lat[0],lon[0]],popup="Start",icon=folium.Icon(color="red")).add_to(map)
        one=1 
    '''
    if count %50==0:
        plots()
    count+=1
    if ser.in_waiting==0:
        time.sleep(0.01)

