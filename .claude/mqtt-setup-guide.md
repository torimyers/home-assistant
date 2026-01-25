# MQTT Broker Setup Guide for Unraid

## Step-by-Step Installation

### Step 1: Install Mosquitto MQTT Broker on Unraid

**Option A: Via Community Applications (Easiest)**

1. Open Unraid Web UI
2. Go to **Apps** tab
3. Search for "**eclipse-mosquitto**"
4. Click **Install**
5. Configure with these settings:
   - **Container Port 1883:** Host Port `1883`
   - **Container Port 9001:** Host Port `9001` (WebSocket, optional)
   - **Config Path:** `/mnt/user/appdata/mosquitto/config`
   - **Data Path:** `/mnt/user/appdata/mosquitto/data`
   - **Log Path:** `/mnt/user/appdata/mosquitto/log`
   - **Network Type:** `bridge`
6. Click **Apply**

**Option B: Docker Command Line**

SSH into your Unraid server and run:

```bash
# Create directories
mkdir -p /mnt/user/appdata/mosquitto/config
mkdir -p /mnt/user/appdata/mosquitto/data
mkdir -p /mnt/user/appdata/mosquitto/log

# Create basic config file
cat > /mnt/user/appdata/mosquitto/config/mosquitto.conf << 'EOF'
# Mosquitto MQTT Broker Configuration

# Listen on default MQTT port
listener 1883

# Allow connections from any host
allow_anonymous true

# Persistence for messages
persistence true
persistence_location /mosquitto/data/

# Logging
log_dest file /mosquitto/log/mosquitto.log
log_dest stdout
log_type error
log_type warning
log_type notice
log_type information

# Connection settings
max_keepalive 60
EOF

# Run Mosquitto container
docker run -d \
  --name=mosquitto \
  --hostname=mosquitto \
  --restart=unless-stopped \
  -p 1883:1883 \
  -p 9001:9001 \
  -v /mnt/user/appdata/mosquitto/config:/mosquitto/config \
  -v /mnt/user/appdata/mosquitto/data:/mosquitto/data \
  -v /mnt/user/appdata/mosquitto/log:/mosquitto/log \
  eclipse-mosquitto:latest
```

### Step 2: Verify Mosquitto is Running

```bash
# Check container status
docker ps | grep mosquitto

# Check logs
docker logs mosquitto

# You should see: "mosquitto version X.X.X running"
```

### Step 3: Configure Home Assistant MQTT Integration

The MQTT integration file has already been created at:
`integrations/mqtt.yaml`

It contains:
```yaml
mqtt:
  broker: 127.0.0.1
  port: 1883
```

### Step 4: Restart Home Assistant

**Option A: Via Home Assistant UI**
1. Go to **Settings → System**
2. Click **Restart** (top right)
3. Wait for HA to come back online

**Option B: Via Unraid (if container restart needed)**
```bash
docker restart Home-Assistant
```

### Step 5: Verify MQTT Connection in Home Assistant

1. Go to **Settings → Devices & Services**
2. Look for **MQTT** integration
3. It should show as "Connected"
4. Click on it to see MQTT broker info

**Test MQTT:**
1. Go to **Developer Tools → MQTT**
2. In "Listen to a topic", enter: `test/topic`
3. Click **Start Listening**
4. In "Publish a packet", enter:
   - **Topic:** `test/topic`
   - **Payload:** `Hello MQTT!`
5. Click **Publish**
6. You should see the message appear in the listening section

## Step 6: Add Authentication (Optional but Recommended)

For better security, add username/password authentication:

```bash
# SSH into Unraid and run:
docker exec -it mosquitto mosquitto_passwd -c /mosquitto/config/passwd homeassistant

# Enter a password when prompted (save this!)

# Update mosquitto.conf
docker exec -it mosquitto sh -c "cat >> /mosquitto/config/mosquitto.conf << 'EOF'

# Authentication
allow_anonymous false
password_file /mosquitto/config/passwd
EOF"

# Restart Mosquitto
docker restart mosquitto
```

Then update `secrets.yaml`:
```yaml
mqtt_username: homeassistant
mqtt_password: YOUR_PASSWORD_HERE
```

And update `integrations/mqtt.yaml`:
```yaml
mqtt:
  broker: 127.0.0.1
  port: 1883
  username: !secret mqtt_username
  password: !secret mqtt_password
```

## Step 7: Configure Grocy Integration with MQTT

Now that MQTT is running, configure Shopping List with Grocy:

1. In Home Assistant: **Settings → Devices & Services → + Add Integration**
2. Search: "**Shopping List with Grocy**"
3. Enter:
   - **Grocy API URL:** `http://YOUR-UNRAID-IP:9283`
   - **Verify SSL:** Uncheck (for local connection)
   - **API Key:** (from Grocy)
   - **MQTT Server:** `127.0.0.1`
   - **MQTT Port:** `1883`
   - **MQTT Username:** `homeassistant` (or blank if no auth)
   - **MQTT Password:** (your password or blank)
   - **Image Download Size:** `100`
   - **Adding products in sensor:** Uncheck (for now)

## Troubleshooting

### MQTT Not Connecting
```bash
# Check if Mosquitto is running
docker ps | grep mosquitto

# Check logs for errors
docker logs mosquitto --tail 50

# Check if port is open
netstat -tulpn | grep 1883
```

### Home Assistant Can't Find MQTT
- Verify `integrations/mqtt.yaml` exists
- Check Home Assistant logs: **Settings → System → Logs**
- Look for MQTT-related errors
- Restart HA to reload configuration

### Grocy Can't Connect to MQTT
- Verify MQTT broker is accessible from HA
- Test with Developer Tools → MQTT
- Check credentials match between HA and Grocy config
- Ensure MQTT port is 1883, not 1 (which disables MQTT)

## What MQTT Enables

Once set up, MQTT provides:
- **Real-time sync** between Grocy and Home Assistant
- **Faster updates** when items are added/removed
- **Support for future integrations** (Zigbee2MQTT, ESPHome, etc.)
- **IoT device communication** hub

## Next Steps

After MQTT and Grocy are configured:
1. ✅ Create dashboard cards for shopping list
2. ✅ Add voice command automations
3. ✅ Set up low stock notifications
4. ✅ Add other MQTT-based devices

---

**Current Status:**
- [x] MQTT integration file created (`integrations/mqtt.yaml`)
- [ ] Mosquitto container installed on Unraid
- [ ] Home Assistant restarted
- [ ] MQTT connection verified
- [ ] Grocy configured with MQTT
