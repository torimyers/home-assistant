---
task: h-fix-broken-bathroom-automations
branch: fix/broken-bathroom-automations
status: pending
created: 2025-09-22
modules: [automations/bathroom]
---

# Fix Broken Bathroom Automations

## Problem/Goal
Multiple active bathroom automations are using non-existent entities, causing system errors:
- `bathroom_lights_on_motion.yaml` uses missing `binary_sensor.master_bathroom_motion`
- `bathroom_lights_off_after_motion.yaml` uses missing `light.master_bathroom_lights`
- `scene.sacred_water_ritual` is unavailable

## Success Criteria
- [ ] Disable bathroom_lights_on_motion.yaml by renaming to .disabled
- [ ] Disable bathroom_lights_off_after_motion.yaml by renaming to .disabled
- [ ] Document missing entities needed for future bathroom setup
- [ ] Verify no active automations reference missing bathroom entities
- [ ] Run `ha core check` to confirm no validation errors from bathroom entities

## Context Files
- @automations/bathroom/bathroom_lights_on_motion.yaml
- @automations/bathroom/bathroom_lights_off_after_motion.yaml
- @automations/bathroom/motion_lighting_bathroom.yaml.disabled

## User Notes
This is critical - these automations are actively failing and causing system errors. Once bathroom hardware is properly set up, we can re-enable with correct entity references.

## Context Manifest

### How Bathroom Automations Currently Work: Motion-Activated Lighting System

The current bathroom automation system was designed as part of the larger Home Assistant motion lighting infrastructure with Dune-themed naming and notifications. The system has three automation files in the bathroom directory, but only two are currently active and causing system errors.

**Active Broken Automations:**

The `bathroom_lights_on_motion.yaml` automation attempts to implement a sacred water ritual theme where bathroom entry triggers lighting activation. When the `binary_sensor.master_bathroom_motion` sensor transitions to 'on', it first checks if `light.master_bathroom_lights` is currently off (line 9-11), then activates `scene.sacred_water_ritual` (lines 13-15) and sends a Dune-themed notification to the mobile device (lines 16-18): "Sacred water ritual begins. Each drop is precious as life itself."

The companion `bathroom_lights_off_after_motion.yaml` automation handles the deactivation sequence. It monitors the same motion sensor for the 'off' state with a 10-minute delay (lines 5-8), then turns off all lights in the `master_bathroom` area using area-based control (lines 10-12) and sends a completion notification (lines 13-16): "Sacred ceremony complete. Water discipline observed in the temple."

**Critical Missing Dependencies:**

The system has three fundamental missing entities that prevent these automations from functioning:

1. **Motion Sensor**: `binary_sensor.master_bathroom_motion` - This is the primary trigger entity that both automations depend on. Without this sensor, the automations cannot detect occupancy changes.

2. **Light Entity**: `light.master_bathroom_lights` - Used as a condition check in the activation automation to prevent turning on lights that are already on. This entity is also referenced in the scene definitions.

3. **Scene Entity**: `scene.sacred_water_ritual` - The activation automation specifically calls this scene rather than using area-based lighting control.

**Existing Scene Infrastructure:**

Interestingly, the scenes directory contains two bathroom scene definitions that reference the missing light entities:

- `scenes/bathroom/bathroom_bright_lights.yaml` defines a "Sacred Water Ritual" scene that controls `light.master_bathroom_lights`, `light.bathroom_mirror_lights`, and `fan.bathroom_exhaust_fan` with specific brightness and color temperature settings.
- `scenes/bathroom/bathroom_shower_mode.yaml` provides a "Temple Cleansing" scene for maximum illumination and ventilation.

However, the active automation references `scene.sacred_water_ritual` which doesn't match either of these existing scene names, creating an additional layer of broken references.

**Blueprint Integration Pattern:**

The codebase has evolved toward a blueprint-based automation system for motion lighting, evidenced by the disabled `motion_lighting_bathroom.yaml.disabled` file. This file shows the intended pattern using the `motion_lighting.yaml` blueprint with comprehensive configuration:

- Motion entity: `binary_sensor.master_bathroom_motion`
- Scene activation: `scene.bathroom_bright_lights`
- Area control: `master_bathroom`
- 10-minute timeout with notifications
- Dune-themed messaging identical to the active broken automations

The motion lighting blueprint supports three activation types (scene, light entity, or area-based), optional light state checking, configurable timeouts, and notification integration. This blueprint pattern has successfully consolidated 8 motion lighting automations into a single reusable template.

**Area-Based Control Architecture:**

The system architecture assumes the existence of a `master_bathroom` area for light control. The automation files use `area_id: master_bathroom` for turning off lights, which suggests Home Assistant areas are configured but the individual entities within those areas don't exist yet.

**Error Impact and System Health:**

These broken entity references cause several system-wide issues:

1. **Validation Failures**: Home Assistant's configuration check fails when encountering non-existent entities
2. **Log Pollution**: Continuous error messages about missing entities
3. **Automation State Confusion**: Automations appear enabled but cannot execute
4. **Scene System Impact**: Missing scene references break the scene activation chain

The related task `h-fix-missing-scenes.md` indicates this is part of a larger pattern where scene-based automations are being converted to area-based control for better reliability.

### For Implementation: Immediate Fixes and Future Setup

**Immediate Disabling Strategy:**

The critical immediate fix is to disable the two active broken automations by renaming them with `.disabled` extensions. This follows the existing pattern seen with `motion_lighting_bathroom.yaml.disabled` and eliminates the system validation errors.

The disabled file already contains comprehensive documentation of the missing entities and setup requirements, serving as a template for future implementation.

**Future Hardware Integration Path:**

When bathroom hardware is properly integrated, the implementation should follow the blueprint pattern rather than individual automation files:

1. **Entity Setup**: Configure `binary_sensor.master_bathroom_motion` and `light.master_bathroom_lights` through the appropriate integrations
2. **Area Configuration**: Ensure `master_bathroom` area exists and contains the relevant entities
3. **Scene Resolution**: Either create `scene.sacred_water_ritual` or modify references to use existing `scene.bathroom_bright_lights`
4. **Blueprint Activation**: Use the disabled blueprint configuration as a template, which already contains all the correct entity references and Dune-themed messaging

**Integration with Motion Lighting Blueprint:**

The `motion_lighting.yaml` blueprint provides a comprehensive solution that eliminates the need for separate on/off automation files. It handles:

- Motion detection and state changes
- Configurable activation types (scene, light, or area)
- Automatic timeout and deactivation
- Notification integration with custom messaging
- Additional action support for complex workflows

This blueprint approach aligns with the project's 85% automation consolidation goal and follows the established pattern of reducing duplicate automation logic.

### Technical Reference Details

#### Current File Structure
```
automations/bathroom/
├── bathroom_lights_on_motion.yaml          # ACTIVE - BROKEN
├── bathroom_lights_off_after_motion.yaml   # ACTIVE - BROKEN
└── motion_lighting_bathroom.yaml.disabled  # TEMPLATE for future use

scenes/bathroom/
├── bathroom_bright_lights.yaml             # EXISTS - References missing lights
└── bathroom_shower_mode.yaml               # EXISTS - References missing lights
```

#### Missing Entity Dependencies
```yaml
# Required for automation function:
binary_sensor.master_bathroom_motion    # Motion detection trigger
light.master_bathroom_lights           # Primary bathroom lighting
light.bathroom_mirror_lights           # Secondary lighting (scenes only)
fan.bathroom_exhaust_fan               # Ventilation control (scenes only)
switch.bathroom_towel_warmer           # Comfort feature (shower scene only)

# Scene naming mismatch:
scene.sacred_water_ritual              # Referenced but doesn't exist
scene.bathroom_bright_lights           # Exists but not referenced by active automations
```

#### Blueprint Configuration Pattern
```yaml
use_blueprint:
  path: motion_lighting.yaml
  input:
    motion_entity: binary_sensor.master_bathroom_motion
    activation_type: scene
    scene_entity: scene.bathroom_bright_lights
    area_id: master_bathroom
    timeout_minutes: 10
    enable_notifications: true
    activation_message: "Sacred water ritual begins. Each drop is precious as life itself."
    deactivation_message: "Sacred ceremony complete. Water discipline observed in the temple."
```

#### Disabling Actions Required
1. Rename `bathroom_lights_on_motion.yaml` → `bathroom_lights_on_motion.yaml.disabled`
2. Rename `bathroom_lights_off_after_motion.yaml` → `bathroom_lights_off_after_motion.yaml.disabled`
3. Verify no other automations reference the missing bathroom entities
4. Run system validation to confirm error resolution

## Work Log
- [2025-09-22] Task created from comprehensive entity validation analysis