# Accident Detection System (ADS)

An automated accident detection and alert system that uses AI-powered video analysis to detect accidents from video feeds and instantly send alerts with the accident location and video evidence via **SMS** and **WhatsApp** using **Twilio API**.

---

## Project Overview

The **Accident Detection System (ADS)** is a prototype that:
- Continuously monitors incoming video files.
- Uses an **AI model (via Roboflow API)** to detect accidents in the video frames.
- If an accident is detected:
  - Uploads the video to a local HTTP server (shared via **Ngrok**).
  - Sends real-time alerts via SMS and WhatsApp, including:
    - Accident **location**
    - **Google Maps link**
    - **Video evidence** link.

---

## Features
 Real-time accident detection using AI  
 Automatic alert messages via Twilio (SMS + WhatsApp)  
 Dynamic location tracking using IP geolocation  
 Secure video sharing through Ngrok tunnel  
 Fully automated video monitoring and processing  

---

## Tech Stack

| Component | Technology |
|------------|-------------|
| **Scripting** | Bash |
| **AI Detection** | Roboflow API |
| **Alert Service** | Twilio API |
| **Server** | Python HTTP Server + Ngrok |
| **Location** | ip-api.com |
| **Video Processing** | FFmpeg |

---

## How It Works

1. **Startup**
   - The script clears the console and displays an ASCII banner.
   - Initializes the Twilio and Ngrok services.
   
2. **Video Monitoring**
   - Continuously checks for new video files (`.mp4`, `.mkv`, `.avi`) in the working directory.

3. **Accident Detection**
   - Extracts frames from videos using FFmpeg.
   - Sends frames to the **Roboflow AI** endpoint for detection.
   - If an "accident" label is found, the system triggers an alert.

4. **Alert Generation**
   - Fetches approximate geolocation using IP.
   - Uploads the video to a local HTTP server shared via **Ngrok**.
   - Sends the alert via **Twilio SMS/WhatsApp**, including:
     - Accident Location (Google Maps)
     - Ngrok video link

---

## 🔧 Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/accident-detection-system.git
cd accident-detection-system
````

### 2. Install Required Tools

Make sure the following are installed:

* `bash`
* `python3`
* `ffmpeg`
* `curl`
* `ngrok`

### 3. Set Up Twilio

* Create a [Twilio](https://www.twilio.com/) account.
* Get your **Account SID**, **Auth Token**, and verified phone numbers.
* Edit the `start.sh` file:

  ```bash
  ACCOUNT_SID="your_twilio_account_sid"
  AUTH_TOKEN="your_twilio_auth_token"
  TWILIO_SMS_NUMBER="+1234567890"
  TWILIO_WHATSAPP_NUMBER="whatsapp:+1234567890"
  RECEIVER_SMS_NUMBERS=("recipient_number")
  RECEIVER_WHATSAPP_NUMBERS=("whatsapp:recipient_number")
  ```

### 4. Run the System

```bash
chmod +x start.sh
./start.sh
```

### 5. Add a Video

Place a `.mp4`, `.mkv`, or `.avi` file in the project folder.
The system will automatically:

* Analyze it,
* Detect accidents,
* Send alerts.

---

## Output Example

**Terminal Output:**

```
Accident Detection System - Prototype
Starting ADS...
Looking for Video Files...
Found video file(s), Proceeding...
Running ADS AI Detection...
Accident Detected
Message sent to +91XXXXXXXXXX
```

**Message Example (WhatsApp/SMS):**

```
ALERT: Accident Detected!
Location: https://www.google.com/maps?q=19.0760,72.8777
Video: https://abc123.ngrok-free.app/video.mp4
```

---

## Team Members

* Kavya
* Tirth
* Jindal
* Yash

---

## License

This project is for educational and research purposes only.
All rights reserved © 2025 — ADS Prototype Team.

---

## Future Enhancements

* Integrate with real-time CCTV/live streams
* Use GPS-based hardware sensors for location
* Deploy AI detection locally for faster response
* Add a dashboard for accident history and analytics

---
