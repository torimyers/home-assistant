---
task: m-fix-dashboard-entities
branch: fix/dashboard-entities
status: pending
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