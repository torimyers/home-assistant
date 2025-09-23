---
task: m-fix-sunrise-sunset-routines
branch: fix/sunrise-sunset-routines
status: pending
created: 2025-09-22
modules: [automations/system, blueprints/automation]
---

# Fix Sunrise/Sunset Routine Dependencies

## Problem/Goal
Daily sunrise and sunset routines use the daily_routine blueprint but reference missing entities:
- Morning routine references missing `scene.morning_awakening` and `script.morning_systems_check`
- Evening routine references missing `scene.evening_routine`
- Blueprint functionality needs validation

## Success Criteria
- [ ] Validate daily_routine.yaml blueprint works correctly
- [ ] Create missing scenes or convert to direct light/area control
- [ ] Test sunrise trigger with offset calculations
- [ ] Test sunset trigger with offset calculations
- [ ] Verify notifications work correctly
- [ ] Document any missing scripts referenced

## Context Files
- @automations/system/morning_sunrise_routine.yaml
- @automations/system/evening_sunset_routine.yaml
- @blueprints/automation/daily_routine.yaml

## User Notes
These time-based routines are important for daily automation. Focus on making them work reliably rather than complex scene orchestration.

## Work Log
- [2025-09-22] Task created from sunrise/sunset automation analysis