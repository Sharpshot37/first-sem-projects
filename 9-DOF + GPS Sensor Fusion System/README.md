# 9-DOF Real-Time Sensor Fusion System

Hardware implementation of IMU + GPS sensor fusion on Arduino, streaming orientation and position data at 100Hz for real-time visualization and analysis.

## Quick Links
- [Demo Video](https://youtube.com/shorts/lhxERcgtU0A?feature=share) - Dashboard in action
- [Hardware Photos](https://drive.google.com/file/d/1cbT3uiKRwMIP1I9MayDR_OYPFMwVgQx0/view?usp=sharing) - Build and wiring

---

## Overview

Built this to understand how autonomous systems estimate their state (position + orientation) by fusing data from multiple sensors that update at different rates. The IMU runs at 100Hz while GPS updates sporadically at 1-5Hz - keeping everything synchronized while streaming to a computer was the main challenge.

**Why stream instead of log?** 
- See what's happening in real-time (critical for debugging sensor issues)
- No SD card needed (simpler hardware, one less thing to break)
- Computer can log to CSV if I need historical data
- Way easier to catch problems during development

## System Architecture
```
┌─────────────┐     ┌─────────────┐     ┌──────────────┐
│  MPU9250    │────▶│             │     │              │
│  9-DOF IMU  │     │   Arduino   │────▶│  Serial USB  │──┐
│  100 Hz     │     │             │     │   115200     │  │
└─────────────┘     │             │     └──────────────┘  │
                    │             │                        │
┌─────────────┐     │             │                        │
│  ATGM336H   │────▶│             │                        │
│  GPS        │     │             │                        │
│  1-5 Hz     │     └─────────────┘                        │
└─────────────┘                                            │
                                                           ▼
                                                   ┌──────────────┐
                                                   │   Computer   │
                                                   │   Python     │
                                                   │  Dashboard   │
                                                   └──────────────┘
```

**Data flow:**
1. Arduino samples IMU every 10ms (100Hz)
2. GPS updates whenever it feels like it (usually 1-5Hz)
3. Complementary filter fuses gyro + accel for stable orientation
4. Everything gets packed into serial packets
5. Python unpacks and visualizes in real-time

---

## Hardware

**MPU9250 - 9-Axis IMU**
- 3-axis accelerometer, gyroscope, magnetometer
- I2C interface
- ~$8 on Amazon

**ATGM336H - GPS Module**
- GPS + GLONASS + Beidou
- Position accuracy: 2-5m outdoors
- UART interface (NMEA protocol)
- ~$15

**Arduino Uno**
- ATmega328P @ 16MHz
- USB serial for computer connection
- ~$25 (or use clone)

**Total cost:** ~$30-50 depending on where you buy

---

## The Sensor Fusion Part

### Complementary Filter

The core algorithm that fuses gyroscope and accelerometer:

```cpp
// Gyroscope gives rotation rates (deg/s) - integrate to get angles
float gx_angle = roll + gx * dt;   // Predicted roll from gyro

// Accelerometer measures gravity direction - calculate tilt
float ax_angle = atan2(ay, az) * 180 / PI;

// Combine: trust gyro short-term (fast, smooth), accel long-term (prevents drift)
roll = 0.98 * gx_angle + 0.02 * ax_angle;
```

**Why this works:**
- Gyroscope: Super responsive but drifts over time (integration error adds up)
- Accelerometer: Noisy from vibrations but stable average (measures gravity)
- 98/2 blend: Get gyro's speed without its drift, accel's stability without its noise

**Why 98/2 specifically?** Tested a bunch of ratios:
- 99/1: Too drifty, sensor would slowly rotate by itself
- 95/5: Too much accel influence, orientation jittered from vibration
- 98/2: Sweet spot - responsive but stable

### Magnetometer Heading

Raw magnetometer readings rotate with the sensor tilt, so I compensate using the roll/pitch from the complementary filter:

```cpp
// Apply tilt compensation matrix
float MX = mx * cos(pitch) + mz * sin(pitch);
float MY = mx * sin(roll) * sin(pitch) + my * cos(roll) - mz * sin(roll) * cos(pitch);
float heading = atan2(MY, MX) * 180 / PI;
```

This gives true heading regardless of how the sensor is tilted. Without this, tilting the sensor would change the heading reading even if you didn't rotate.

### Magnetometer Calibration

Biggest pain point of the whole project. Every magnetic field near the sensor (USB cable, laptop, desk, motors) creates a constant offset. Solution: rotate the sensor through all orientations and find min/max on each axis:

```cpp
// During 10-second calibration
if (mx > maxX) maxX = mx;
if (mx < minX) minX = mx;
// ... same for Y and Z

// Offset is midpoint between min and max
offsetX = (maxX + minX) / 2;
```

Had to recalibrate every time I moved to a different desk or changed the setup. Learned to just accept this - magnetometers are finicky.

---

## Serial Protocol

Data packets stream at 100Hz (every 10ms):
```
Format: $,timestamp,lat,lon,alt,sats,hdop,speed,
        roll,pitch,yaw,mag_heading,gps_heading,
        ax,ay,az,gx,gy,gz,mx,my,mz,gps_flag,checksum\n

Example:
$,12345,29.7604,-95.3698,12.3,8,1.2,0.5,
  2.1,-1.3,45.2,44.8,0.0,
  0.02,-0.01,1.00,0.1,-0.2,0.05,23.4,-12.1,45.2,1,C7\n
```

Checksum is XOR of all bytes - catches corrupted packets. GPS flag indicates if GPS data is fresh (just updated) or stale (using last known position).

---

## Test Results

### Walking Figure-8 Test

Walked a ~50m diameter figure-8 pattern outdoors. GPS tracked the path accurately (you can see it on the map visualization), orientation stayed stable throughout. Position accuracy was around 3m average - good enough to see the path shape clearly.

### Orientation Accuracy

Tested against a physical level and protractor:

| True Angle | Measured | Error |
|------------|----------|-------|
| 0° (level) | 0.3°     | 0.3°  |
| 45° tilt   | 46.8°    | 1.8°  |
| 90° tilt   | 92.1°    | 2.1°  |

Rapid tilting showed no oscillation - the 98/2 filter ratio keeps it stable.

### Magnetometer Heading

Compared to smartphone compass (both devices in same orientation):

| Smartphone | This System | Error |
|------------|-------------|-------|
| 0° (North) | 2°          | 2°    |
| 90° (East) | 87°         | 3°    |
| 180° (South)| 183°       | 3°    |
| 270° (West) | 274°       | 4°    |

Good enough for navigation, but the ±5° error shows how much local magnetic interference matters.

---

## Technical Challenges

### Challenge 1: Keeping 100Hz Timing with Non-Blocking GPS

**The problem:** IMU needs to sample every 10ms exactly. GPS updates randomly (sometimes 200ms, sometimes 1000ms). Can't wait for GPS or IMU timing gets messed up.

**Solution:** Check for GPS data without blocking:
```cpp
while (gpsSerial.available()) {
  gps.encode(gpsSerial.read());  // Parse whatever's there
}
// Don't wait, just continue to IMU sampling
```

GPS data gets marked with a "fresh" flag when it updates. Python dashboard shows the age of GPS data so you know if it's current or stale.

**Result:** IMU maintained solid 100Hz regardless of GPS behavior.

### Challenge 2: Serial Bandwidth

Sending 20+ values at 100Hz = massive data rate. At 115200 baud, each packet can be ~80 bytes max.

Considered binary encoding (would be ~40 bytes/packet) but rejected it because:
- Way harder to debug (can't just look at Serial Monitor)
- Python parsing gets more complex
- Comma-separated is fast enough if I'm careful

Optimized by:
- Keeping precision reasonable (2-3 decimal places)
- No JSON/XML overhead
- Compact field names

**Result:** ~90% bandwidth utilization at 100Hz with <0.1% packet loss.

### Challenge 3: Magnetometer is a Drama Queen

First attempt: mounted sensor right next to Arduino → readings were garbage. USB cable created huge magnetic field that swamped the sensor.

Learned the hard way:
- Keep magnetometer away from Arduino board
- Calibrate with sensor in final position (moving it invalidates calibration)
- USB cable position matters
- Metal desk vs wooden table makes a difference
- Recalibrate before each session or accept bad heading

Final setup: sensor mounted on a stick ~20cm from Arduino. Still not perfect but workable.

### Challenge 4: GPS Cold Start Waiting

GPS takes 30-60 seconds to get first fix after power-on. Originally had the code wait, but that meant nothing worked for the first minute.

Fixed: System starts immediately with IMU data, GPS marked invalid until it locks. Dashboard shows "GPS: No Fix" clearly. Once satellites lock, position data appears. Way better user experience.

---

## What I Actually Learned

**Sensor fusion isn't magic** - it's just combining slow-but-accurate data with fast-but-drifty data. The complementary filter is surprisingly simple but works well. More complex algorithms like Kalman filters exist but this was good enough for understanding the fundamentals.

**Real-time constraints are hard** - When you promise 100Hz, you deliver 100Hz every single time or things break. No "mostly 100Hz" or "average 100Hz." Every. Single. Time. This mindset is critical for any real-time system.

**Magnetometers are annoying** - They work great in theory (measure Earth's magnetic field for absolute heading), terrible in practice (everything creates magnetic fields). Learned to work around this instead of fighting it.

**Serial debugging is your friend** - Being able to see raw sensor values streaming in real-time caught so many bugs. Watched orientation values while tilting the sensor to verify the math was right.

**GPS accuracy is... variable** - 2-5m accuracy sounds good until you realize that's the radius of a circle you're somewhere inside. Good enough for walking paths, not good enough for precise positioning. Also learned about HDOP (dilution of precision) - lower is better, and satellite geometry matters as much as satellite count.

**Embedded development is different** - 2KB of RAM means you think hard about every variable. No malloc, careful with arrays, reuse buffers. Coming from writing Python where you just throw memory at problems, this was a mindset shift.

---

## Applications

**Drones:**
Same 9-DOF fusion used in flight controllers - this project gave me hands-on experience with the sensor pipeline, preparing me to deal with flight dynamics.

**Vehicle Telemetry:**
Vehicles stream telemetry to pit crew during testing. Similar architecture - sensors on car, real-time wireless link, dashboard on laptop. This project proved I can build that pipeline.

**General Robotics:**
Any mobile robot needs to know where it is and which way it's pointing. This is the foundation - add encoders and you get dead reckoning, add cameras and you get SLAM.

---

## Future Work

**Near-term:**
- [ ] Add SD card for standalone logging (so it's not tethered to laptop)
- [ ] Kalman filter instead of complementary filter
- [ ] Bluetooth serial (cut the USB cable)
- [ ] Better gyro bias estimation

**If I rebuild this:**
- Use ESP32 (faster, built-in Bluetooth, more memory)
- Add barometer for altitude fusion
- Dual GPS antennas for heading (no magnetometer headaches)
- More sophisticated outlier rejection

---

## Code Structure
```
├── arduino/
│   └── sensor_fusion.ino      # Main code (all in one file for simplicity)
│
├── python/
│   ├── realtime_dashboard.py  # Live 8-plot visualization
│   ├── gps_map.py              # GPS track on folium map
│   └── data_logger.py          # Save serial to CSV
│
└── README.md
```

---

## Getting Started

### Wiring
```
MPU9250 → Arduino:
  VCC → 5V, GND → GND
  SDA → A4, SCL → A5

ATGM336H → Arduino:
  VCC → 5V, GND → GND
  TX → Pin 10, RX → Pin 11
```

### Arduino Setup
```bash
1. Install Arduino IDE
2. Install libraries: MPU9250, TinyGPSPlus
3. Upload sensor_fusion.ino
4. Open Serial Monitor (115200 baud) - should see data streaming
```

### Python Setup
```bash
pip install pyserial matplotlib folium pandas numpy
python realtime_dashboard.py
```

### Calibration
1. Upload code, wait for "Begin calibration" message
2. Slowly rotate sensor in figure-8 pattern through all orientations
3. After 10 seconds, offsets are calculated
4. Go outdoors, wait for GPS fix (watch for satellite count >4)
5. Ready to use

---

## Common Issues

**Magnetometer jumps around:** Recalibrate away from metal/electronics

**GPS won't lock:** Go outside, wait longer (cold start can take 60+ seconds)

**Orientation drifts slowly:** Adjust complementary filter ratio (try 0.97/0.03)

**Serial data choppy:** Reduce update rate or check USB cable connection

---

## Libraries Used

**Arduino:**
- MPU9250 by hideakitai
- TinyGPSPlus by Mikal Hart
- SoftwareSerial (built-in)

**Python:**
- pyserial, matplotlib, folium, pandas

---

## Project Context

Built during my first semester at UT Austin. Wanted hands-on experience with sensors and real-time systems before diving into advanced projects.

This demonstrates I can:
- Integrate multiple sensors with different interfaces and update rates
- Implement real-time algorithms with hard timing constraints
- Design communication protocols for streaming data
- Build complete hardware-software systems
- Debug sensor issues systematically

---

## Resources

**Sensor Fusion:**
- "Fundamentals of Sensor Fusion" - Sebastian Madgwick
- Complementary Filter Tutorial - Pieter-Jan Van de Maele
- "Probabilistic Robotics" - Thrun, Burgard, Fox
- Pieter-Jan Van de Maele's complementary filter tutorial
- "Keeping a Good Attitude" by William Premerlani (DCM algorithm)

**IMU/GPS:**
- MPU9250 datasheet and register map
- NMEA 0183 protocol spec
- TinyGPS++ documentation
- Real-time embedded systems principles

---

**Built December 2024 | Arduino + Python | 9-DOF Sensor Fusion**

**Next:** Porting to STM32 for higher performance + wireless telemetry
