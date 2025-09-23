---
task: h-fix-missing-scenes
branch: fix/missing-scenes
status: pending
created: 2025-09-22
modules: [automations/living_room, automations/system, scenes]
---

# Fix Missing Scenes or Convert to Area-Based

## Problem/Goal
Multiple automations reference scenes that don't exist, causing automation failures:
- `scene.living_room_gathering` (living room motion blueprint)
- `scene.morning_awakening` (sunrise routine blueprint)
- `scene.evening_routine` (sunset routine blueprint)
- `scene.sacred_water_ritual` (bathroom automation)

## Success Criteria
- [ ] Convert living room automation from scene to area-based activation
- [ ] Fix or convert sunrise/sunset routine scene dependencies
- [ ] Create missing scenes OR convert all to area/light-based control
- [ ] Verify all scene references in active automations exist
- [ ] Test converted automations work with area-based control

## Context Files
- @automations/living_room/motion_lighting_living_room.yaml
- @automations/system/morning_sunrise_routine.yaml
- @automations/system/evening_sunset_routine.yaml
- @blueprints/automation/motion_lighting.yaml
- @blueprints/automation/daily_routine.yaml

## User Notes
Area-based activation is more reliable than scene-based since it doesn't depend on scene entities existing. Prioritize conversion over scene creation.

## Context Manifest

### How Scene Dependencies Currently Work: Motion Lighting & Daily Routines

The Home Assistant configuration uses a sophisticated blueprint-based automation system that supports both scene-based and area-based lighting control. Understanding this dual approach is critical because the failing automations are trying to use scene entities that don't exist, while the blueprint system already provides area-based alternatives.

**Scene-Based Activation Pattern:**
When a motion sensor like `binary_sensor.living_room_motion` triggers the motion lighting blueprint, it can activate lighting through three different methods: scene activation (`activation_type: scene`), direct light control (`activation_type: light`), or area-based control (`activation_type: area`). The current failing automation `motion_lighting_living_room.yaml` is configured to use `scene.living_room_gathering` as its activation method, but this creates a hard dependency on that specific scene entity existing.

The scene activation flow works by calling `scene.turn_on` with the target `scene_entity` parameter, which then applies all the predefined entity states (lights, switches, media players) defined in that scene. This approach is powerful because scenes can control multiple devices with precise brightness, color temperature, and state settings in a single atomic operation.

**Daily Routine Scene Integration:**
The sunrise and sunset routines (`morning_sunrise_routine.yaml` and `evening_sunset_routine.yaml`) use the daily routine blueprint with `enable_scenes: true` and a list of scenes to activate. The morning routine attempts to activate `scene.morning_awakening` while the evening routine tries to activate `scene.evening_routine`. These routines use the blueprint's scene activation logic which iterates through the `scenes_to_activate` list and calls `scene.turn_on` for each entity.

**Scene vs Area Architecture Decision:**
The blueprint system was designed to provide flexibility between scene-based control (which offers precise multi-device coordination) and area-based control (which is more resilient to entity changes). Area-based control uses `light.turn_on` with `area_id` targeting, which automatically discovers and controls all light entities assigned to that area in Home Assistant's area registry. This eliminates the need for explicit entity lists and makes automations more maintainable.

**Current Scene Entity Status:**
Analysis reveals that some referenced scenes exist while others are missing:
- ✅ `scene.living_room_gathering` - EXISTS in `scenes/living_room/living_room_gathering.yaml`
- ✅ `scene.morning_awakening` - EXISTS in `scenes/bedroom/morning_awakening.yaml`
- ✅ `scene.evening_routine` - EXISTS in `scenes/system/evening_routine.yaml`
- ❌ `scene.sacred_water_ritual` - MISSING (referenced by bathroom automation)

**The Bathroom Scene Problem:**
The `bathroom_lights_on_motion.yaml` automation references `scene.sacred_water_ritual` which doesn't exist. However, there are existing bathroom scenes: `scenes/bathroom/bathroom_bright_lights.yaml` and `scenes/bathroom/bathroom_shower_mode.yaml`. The automation could be updated to use `scene.bathroom_bright_lights` or converted to area-based control targeting the bathroom area.

### For Area-Based Conversion Implementation: What Needs to Connect

Since the user preference is "Area-based activation is more reliable than scene-based since it doesn't depend on scene entities existing. Prioritize conversion over scene creation," we need to convert the scene-dependent automations to use area-based control instead.

**Living Room Motion Automation Conversion:**
The `motion_lighting_living_room.yaml` automation currently uses `activation_type: scene` with `scene_entity: scene.living_room_gathering`. This needs to be changed to `activation_type: area` with `area_id: living_room`. The motion lighting blueprint already supports this through its area-based logic (lines 189-195 in the blueprint) which calls `light.turn_on` targeting `area_id: !input area_id`.

**Daily Routine Scene Dependencies:**
The sunrise and sunset routines use the daily routine blueprint's scene activation feature. To convert these to area-based control, we have two options:
1. Change them to use `enable_light_control: true` with `lights_switches` targeting specific light entities
2. Replace scene activation with script execution that performs area-based lighting control

**Area Registry Integration:**
The Home Assistant area system requires that entities be properly assigned to areas through the area registry. The automation references suggest these areas should exist: `living_room`, `bathroom`, `bedroom`, `kitchen`, `office`. The area-based control will only work if light entities are properly assigned to these areas.

**Blueprint Capability Analysis:**
The motion lighting blueprint (lines 58-63, 189-195, 223-231) fully supports area-based control with proper activation and deactivation logic. The daily routine blueprint supports light control but through individual entity targeting rather than area-based control, so it may need enhancement or the automations need to use alternative approaches.

### Technical Reference Details

#### Component Interfaces & Signatures

**Motion Lighting Blueprint Parameters:**
```yaml
activation_type: "area"  # Instead of "scene"
area_id: "living_room"   # Instead of scene_entity
motion_entity: binary_sensor.living_room_motion
room_name: "living_room"
timeout_minutes: 10
```

**Daily Routine Blueprint Parameters:**
```yaml
# Scene-based (current):
enable_scenes: true
scenes_to_activate:
  - scene.morning_awakening

# Light-based (conversion option):
enable_light_control: true
light_action: "turn_on"
lights_switches:
  - light.bedroom_ceiling_light
  - light.bedside_lamp_left
```

#### Data Structures

**Existing Scene Definitions:**
- `scene.living_room_gathering`: Controls ceiling light (brightness: 160, color_temp: 370), couch lamp, accent lights, floor lamp
- `scene.morning_awakening`: Controls bedroom ceiling light (brightness: 80, color_temp: 450), bedside lamps, air purifier
- `scene.evening_routine`: Controls living room and kitchen lights with warm color temperatures, bedroom setup

**Motion Sensor Entities:**
- `binary_sensor.living_room_motion`: Active motion sensor for living room automation
- `binary_sensor.master_bathroom_motion`: Referenced but potentially missing bathroom motion sensor

**Light Entity Patterns:**
- Living room: `light.living_room_ceiling_light`, `light.living_room_accent_lights`
- Bathroom: `light.master_bathroom_lights`, `light.bathroom_mirror_lights`
- Bedroom: `light.bedroom_ceiling_light`, `light.bedside_lamp_left`, `light.bedside_lamp_right`

#### Configuration Requirements

**Area Assignments:**
Each area-based automation requires that the target area exists in Home Assistant's area registry and has appropriate light entities assigned to it.

**Blueprint Input Validation:**
The motion lighting blueprint includes template conditions to validate activation type and ensure required parameters are provided for each activation method.

#### File Locations

**Primary Implementation Files:**
- Motion automation: `C:\Users\torib\OneDrive\Documents\GitHub\home-assistant\automations\living_room\motion_lighting_living_room.yaml`
- Morning routine: `C:\Users\torib\OneDrive\Documents\GitHub\home-assistant\automations\system\morning_sunrise_routine.yaml`
- Evening routine: `C:\Users\torib\OneDrive\Documents\GitHub\home-assistant\automations\system\evening_sunset_routine.yaml`
- Bathroom automation: `C:\Users\torib\OneDrive\Documents\GitHub\home-assistant\automations\bathroom\bathroom_lights_on_motion.yaml`

**Blueprint Reference Files:**
- Motion lighting blueprint: `C:\Users\torib\OneDrive\Documents\GitHub\home-assistant\blueprints\automation\motion_lighting.yaml`
- Daily routine blueprint: `C:\Users\torib\OneDrive\Documents\GitHub\home-assistant\blueprints\automation\daily_routine.yaml`

**Existing Scene Files (for reference):**
- `C:\Users\torib\OneDrive\Documents\GitHub\home-assistant\scenes\living_room\living_room_gathering.yaml`
- `C:\Users\torib\OneDrive\Documents\GitHub\home-assistant\scenes\bedroom\morning_awakening.yaml`
- `C:\Users\torib\OneDrive\Documents\GitHub\home-assistant\scenes\system\evening_routine.yaml`
- `C:\Users\torib\OneDrive\Documents\GitHub\home-assistant\scenes\bathroom\bathroom_bright_lights.yaml`

## Work Log
- [2025-09-22] Task created from scene validation analysis