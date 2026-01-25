# Grocy Setup Guide for Unraid

## Docker Container Setup

### Option 1: Using Unraid Community Applications (Recommended)

1. **Open Unraid Web UI**
2. Go to **Apps** tab
3. Search for "**Grocy**"
4. Install the **linuxserver/grocy** container

### Option 2: Manual Docker Setup

Use these settings when adding the container manually:

**Container Name:** `Grocy`

**Repository:** `lscr.io/linuxserver/grocy:latest`

**Network Type:** `bridge`

**Ports:**
- Container Port: `80` → Host Port: `9283` (or any available port)

**Paths (Volume Mappings):**
- Container Path: `/config` → Host Path: `/mnt/user/appdata/grocy`

**Environment Variables:**
- `PUID=99` (Unraid user ID - typically 99)
- `PGID=100` (Unraid users group - typically 100)
- `TZ=America/New_York` (your timezone)

### Docker Compose (Alternative)

If you prefer docker-compose, create this file:

```yaml
version: "3"
services:
  grocy:
    image: lscr.io/linuxserver/grocy:latest
    container_name: Grocy
    environment:
      - PUID=99
      - PGID=100
      - TZ=America/New_York
    volumes:
      - /mnt/user/appdata/grocy:/config
    ports:
      - 9283:80
    restart: unless-stopped
```

## Initial Grocy Configuration

1. **Access Grocy:**
   - Open browser to: `http://YOUR-UNRAID-IP:9283`
   - Default login: **admin** / **admin**

2. **Change Default Password:**
   - Click on user icon (top right)
   - Go to **Manage users**
   - Edit admin user
   - Change password immediately

3. **Configure Settings:**
   - Click on user icon → **Manage master data**
   - Set up:
     - **Locations** (e.g., Pantry, Fridge, Freezer)
     - **Product groups** (e.g., Produce, Dairy, Meat)
     - **Quantity units** (e.g., pieces, kg, bottles)

4. **Get API Key:**
   - Click on user icon → **Manage API keys**
   - Click **Add**
   - Give it a name: "Home Assistant"
   - Copy the generated API key (you'll need this!)

## Home Assistant Integration

1. **In Home Assistant UI:**
   - Go to **Settings → Devices & Services**
   - Click **+ Add Integration**
   - Search for "Shopping List with Grocy"

2. **Enter Configuration:**
   - **Grocy URL:** `http://YOUR-UNRAID-IP:9283`
   - **API Key:** Paste the key from step 4 above
   - **Grocy User ID:** `1` (admin user)
   - **Language:** `en`

3. **Verify Connection:**
   - Integration should show as "Connected"
   - Entities will be created for each product

## Recommended Grocy Settings

### Enable Helpful Features:
- **Shopping List:** Enable in settings
- **Stock Management:** Configure for pantry tracking
- **Recipes:** Optional, for meal planning

### Configure Products:
1. Go to **Manage master data → Products**
2. Add common grocery items
3. Set barcodes (optional, for mobile scanning)
4. Set default locations and min stock amounts

## Network Considerations

Since both Home Assistant and Grocy are on the same Unraid server:
- Use internal IP: `http://192.168.x.x:9283` (replace with your Unraid IP)
- Or use Unraid hostname: `http://unraid:9283` (if DNS is configured)

## Next Steps After Setup

Once configured, you can:
1. **Create dashboard cards** for the shopping list
2. **Add automations** to add items via voice commands
3. **Set up notifications** for low stock items
4. **Use mobile apps** to scan barcodes and manage inventory

## Troubleshooting

**Can't connect to Grocy:**
- Verify container is running: `docker ps | grep grocy`
- Check port isn't in use: `netstat -tulpn | grep 9283`
- Ensure firewall allows port 9283

**API connection fails:**
- Verify API key is correct
- Check Grocy URL includes `http://` prefix
- Ensure no trailing slash in URL

**Products not syncing:**
- Use service: `shopping_list_with_grocy.refresh_products`
- Check HA logs for errors: **Settings → System → Logs**

---

Ready to proceed? Let me know when you have:
1. ✅ Grocy container running
2. ✅ API key generated
3. ✅ Integration configured in HA

Then we can add it to your dashboard and create automations!
