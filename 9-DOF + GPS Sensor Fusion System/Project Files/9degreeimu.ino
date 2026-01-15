#include "MPU9250.h"
#include <TinyGPSPlus.h>
MPU9250 mpu;
TinyGPSPlus gps;

float roll = 0;
float pitch = 0;
float yaw=0;
float starttime = 0;
float lasttime = 0;

float magoffX = 0.0;
float magoffY = 0.0;
float magoffZ = 0.0;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  Serial1.begin(9600);
  Wire.begin();
  delay(2000);
  mpu.setup(0x68);
  lasttime = millis();
  
  mpu.calibrateAccelGyro();
  calibMag();
}

void loop() {
  delay(10);
  while(Serial1.available()>0){
    gps.encode(Serial1.read());
  }
  double lat=gps.location.lat();
  double lng=gps.location.lng();
  double speed=gps.speed.kmph();
  double hdop=gps.hdop.hdop();
  double sats=gps.satellites.value();
  double alt=gps.altitude.meters();
  double gpshead=gps.course.deg();

  starttime = millis();
  float dt = (starttime - lasttime) / 1000;
  lasttime = starttime;
  mpu.update();

  float gx = mpu.getGyroX();
  float gy = mpu.getGyroY();
  float gz = mpu.getGyroZ();
  float ax = mpu.getAccX();
  float ay = mpu.getAccY();
  float az = mpu.getAccZ();
  float mx = mpu.getMagX();
  float my = mpu.getMagY();
  float mz = mpu.getMagZ();

  float gcompR = roll + gx * dt;
  float acompR = (atan2(ay,az) * 180) / PI;
  roll = gcompR * 0.98 + acompR * 0.02;

  float gcompP = pitch + gy * dt;
  float acompP = (atan2(-ax,sqrt(pow(ay, 2) + pow(az, 2))) * 180) / PI;
  pitch = gcompP * 0.98 + acompP * 0.02;

  float cmx = mx - magoffX;
  float cmy = my - magoffY;
  float cmz = mz - magoffZ;

  float MX=cmx*cos(acompP)+cmz*sin(acompP);
  float MY=cmx*sin(acompR)*sin(acompP)+cmy*cos(acompR)-cmz*sin(acompR)*cos(acompP);
  yaw=atan2(MY,MX);
  float mhead=yaw*180/PI;
  //Serial.println(roll);
  //Serial.println(pitch);
  Serial.print(lat);
  Serial.print(",");
  Serial.print(lng);
  Serial.print(",");
  Serial.print(alt);
  Serial.print(",");
  Serial.print(sats);
  Serial.print(",");
  Serial.print(hdop);
  Serial.print(",");
  Serial.print(speed);
  Serial.print(",");
  Serial.print(roll);
  Serial.print(",");
  Serial.print(pitch);
  Serial.print(",");
  Serial.print(yaw);
  Serial.print(",");
  Serial.print(mhead);
  Serial.print(",");
  Serial.print(gpshead);
  Serial.print(",");
  Serial.print(ax);
  Serial.print(",");
  Serial.print(ay);
  Serial.print(",");
  Serial.print(az);
  Serial.print(",");
  Serial.print(gx);
  Serial.print(",");
  Serial.print(gy);
  Serial.print(",");
  Serial.print(gz);
  Serial.print(",");
  Serial.print(mx);
  Serial.print(",");
  Serial.print(my);
  Serial.print(",");
  Serial.println(mz);
}

void calibMag() {
  float magXmin = 0;
  float magXmax = 0;
  float magYmin = 0;
  float magYmax = 0;
  float magZmin = 0;
  float magZmax = 0;

  unsigned long time = millis();

  Serial.println("Beginning calibration");

  while (millis()-time < 10000) {
    mpu.update();

    if (mpu.getMagX() > magXmax) {
      magXmax = mpu.getMagX();
    } else if (mpu.getMagX() < magXmin) {
      magXmin = mpu.getMagX();
    }

    if (mpu.getMagY() > magYmax) {
      magYmax = mpu.getMagY();
    } else if (mpu.getMagY() < magYmin) {
      magYmin = mpu.getMagY();
    }

    if (mpu.getMagZ() > magZmax) {
      magZmax = mpu.getMagZ();
    } else if (mpu.getMagZ() < magZmin) {
      magZmin = mpu.getMagZ();
    }
  }
  Serial.println("Ending calibration");

  magoffX = (magXmin + magXmax) / 2;
  magoffY = (magYmin + magYmax) / 2;
  magoffZ = (magZmin + magZmax) / 2;
} 
