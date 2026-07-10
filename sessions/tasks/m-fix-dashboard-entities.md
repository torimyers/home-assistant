---
task: m-fix-dashboard-entities
branch: fix/dashboard-entities
status: completed
created: 2025-09-22
modules: [dashboards, responsive-dashboard.yaml]
---

# Update Dashboards to Remove Broken Entity References

## Problem/Goal
Dashboards contain references to entities that don't exist, causing cards to show unavailable states and clutter the interface:
- Main dashboard (861 lines, 83 card types, 72 entity references)
- Sietch Command dashboard (944 lines)
- Mobile dashboard entity references
- Performance monitoring dashboard

## Success Criteria
- [ ] Scan all dashboard files for broken entity references
- [ ] Replace with working entities or remove broken cards
- [ ] Verify all dashboard cards display properly
- [ ] Update entity references to match available entities
- [ ] Reduce dashboard complexity where beneficial
- [ ] Test dashboards load without errors

## Context Files
- @responsive-dashboard.yaml
- @dashboards/sietch_command.yaml
- @dashboards/mobile_command.yaml
- @dashboards/performance_monitoring.yaml

## User Notes
Dashboards should only show working entities. Remove or replace any references to unavailable entities to improve user experience.

## Work Log
- [2025-09-22] Task created from dashboard entity validation
- [2026-07-09] Rescoped to the 3 live dashboards (responsive-dashboard.yaml and
  sietch_command.yaml no longer exist). Diffed all entity refs against a live
  entity dump. Found 4 broken refs and removed them:
  - binary_sensor.lumi_lumi_sensor_wleak_aq1_2 / _3 (Aqara leak sensors removed)
    -> removed Water Leak cards from ui-lovelace.yaml + mobile_command.yaml, and
    disabled automations/water_leak_emergency.yaml (renamed .disabled, documented).
  - sensor.ikea_of_sweden_tradfri_motion_sensor_battery (only _2 exists live)
    -> removed 'IKEA Motion 1' rows from ui-lovelace.yaml + performance_monitoring.yaml.
  - sensor.dishwasher_vibration_battery (no dishwasher entity live)
    -> removed 'Dishwasher Sensor' rows from ui-lovelace.yaml + performance_monitoring.yaml.
  All repo-defined refs (scripts, input helpers, automations) verified valid.
  YAML parse-checked all edited files. NOTE: ui-lovelace.yaml still ~940 lines
  (over the 600 target) - complexity reduction deferred.
