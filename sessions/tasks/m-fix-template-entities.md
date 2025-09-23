---
task: m-fix-template-entities
branch: fix/template-entities
status: pending
created: 2025-09-22
modules: [entities/template]
---

# Clean Up Unavailable Entities from Templates

## Problem/Goal
The 717-line dune_analytics.yaml template file contains references to many unavailable entities (463 total unavailable entities found), causing template calculation errors and system performance issues.

## Success Criteria
- [ ] Audit dune_analytics.yaml for unavailable entity references
- [ ] Remove or replace references to unavailable entities
- [ ] Simplify overly complex template calculations
- [ ] Keep only functional analytics that add value
- [ ] Verify all template sensors render without errors
- [ ] Document any intentional unavailable references with fallbacks

## Context Files
- @entities/template/dune_analytics.yaml
- @entities/template/advanced_analytics.yaml
- @entities/template/energy_monitoring.yaml

## User Notes
717 lines in a single template file is very complex. Focus on keeping only useful, working analytics. Remove anything that references missing entities.

## Work Log
- [2025-09-22] Task created from template entity validation analysis