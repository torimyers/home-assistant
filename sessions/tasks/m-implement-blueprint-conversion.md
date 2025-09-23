---
task: m-implement-blueprint-conversion
branch: feature/blueprint-conversion
status: pending
created: 2025-09-22
modules: [automations/bathroom, blueprints/automation]
---

# Convert Remaining Motion Automations to Blueprints

## Problem/Goal
Increase blueprint adoption from current 35% to 80%+ by converting remaining manual automations to use existing blueprints:
- Convert bathroom automations to motion_lighting blueprint (when hardware ready)
- Convert remaining time-based automations to simple_time_based_control blueprint
- Convert pet care automations to pet_care blueprint
- Identify patterns that need new blueprints

## Success Criteria
- [ ] Audit all non-blueprint automations for conversion opportunities
- [ ] Convert bathroom motion to motion_lighting blueprint template
- [ ] Convert time-based controls to appropriate blueprints
- [ ] Create new blueprints for common patterns (3+ similar automations)
- [ ] Achieve 80%+ blueprint adoption rate
- [ ] Document blueprint usage patterns

## Context Files
- @blueprints/automation/motion_lighting.yaml
- @blueprints/automation/simple_time_based_control.yaml
- @blueprints/automation/pet_care.yaml
- @automations/bathroom/ (for future conversion)

## User Notes
Blueprints reduce duplication and make the system more maintainable. Focus on converting existing patterns rather than creating complex new blueprints.

## Work Log
- [2025-09-22] Task created from blueprint adoption analysis