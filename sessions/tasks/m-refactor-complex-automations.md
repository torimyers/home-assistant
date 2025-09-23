---
task: m-refactor-complex-automations
branch: refactor/complex-automations
status: pending
created: 2025-09-22
modules: [automations/climate, automations/notifications]
---

# Refactor Overly Complex Automations

## Problem/Goal
Several active automations are extremely complex (300+ lines) making them hard to maintain and debug:
- Climate optimization: 373 lines with 25+ entity dependencies
- Spice production achievements: 334 lines
- Alexa timer responses: 325 lines
- Harvester efficiency warnings: 307 lines
- Advanced threat detection: 296 lines

## Success Criteria
- [ ] Split climate automation into focused, single-purpose automations
- [ ] Break down notification automations into specific alert types
- [ ] Reduce individual automation files to <50 lines each
- [ ] Maintain functionality while improving reliability
- [ ] Remove template triggers where simple triggers work
- [ ] Document simplified automation structure

## Context Files
- @automations/climate/intelligent_climate_optimization.yaml
- @automations/notifications/spice_production_achievements.yaml
- @automations/voice_control/alexa_timer_responses.yaml
- @automations/notifications/harvester_efficiency_warnings.yaml
- @automations/security/advanced_threat_detection.yaml

## User Notes
Focus on reliability over intelligence. Simple automations are more maintainable and less prone to breaking.

## Work Log
- [2025-09-22] Task created from complexity analysis