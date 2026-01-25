# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## System Overview

This is a **Home Assistant configuration repository** running on Unraid (version 2025.8.0) with:
- Dune-themed naming throughout (House Dodson Command, Sietch analytics, etc.)
- Blueprint-based automation consolidation (85% of automations use blueprints)
- Comprehensive template sensor analytics for system monitoring
- Multiple dashboards optimized for different devices
- Self-hosted GitHub Actions runner for automated deployment

## Commands

### Configuration Validation
```bash
# Validate entire configuration
ha core check

# Validate configuration files
ha config validate

# YAML syntax check
yamllint .

# Blueprint validation (if supported by your HA version)
ha automation test --blueprint motion_lighting
```

### Deployment
```bash
# Automatic deployment (GitHub Actions)
git push origin main  # Triggers validation and deployment on push

# Manual deployment with container restart
gh workflow run deploy.yaml -f force_restart=true

# Quick local sync to Unraid (manual alternative)
./sync-to-unraid.sh
```

### Maintenance Workflows
```bash
# Run maintenance tasks via GitHub Actions
gh workflow run maintenance.yaml -f task=config-check
gh workflow run maintenance.yaml -f task=entity-cleanup
gh workflow run maintenance.yaml -f task=backup-create
gh workflow run maintenance.yaml -f task=performance-report
```

## Architecture

### Configuration Loading System

Home Assistant loads configuration through a **package-based architecture**:

1. **configuration.yaml** - Minimal root config that loads everything via packages
   ```yaml
   homeassistant:
     packages: !include_dir_named integrations
   ```

2. **integrations/** - Each integration defines what to load
   - `automation.yaml` → loads all `/automations/**/*.yaml` files
   - `template.yaml` → loads template sensors
   - `input_*.yaml` → loads helper entities from `/entities/input_*/`
   - Uses include directives: `!include_dir_merge_list`, `!include_dir_named`, etc.

3. **Entity Organization** - Entities organized by type in `/entities/`:
   - `binary_sensor/` - System status sensors
   - `counter/` - Motion and activity counters
   - `input_boolean/` - Toggle controls
   - `input_datetime/` - Date/time tracking
   - `input_number/` - Numeric thresholds
   - `input_select/` - Dropdown selections
   - `template/` - Calculated template sensors
   - `timer/` - Automation timing controls

### Blueprint System

Blueprints eliminate duplicate automation patterns. Current blueprints:

1. **motion_lighting.yaml** - Motion-activated room lighting (8 automations → 1 blueprint)
   - Configurable timeout, scenes/lights/areas, brightness levels
   - Time-based behavior (day/evening/night modes)

2. **appliance_cycle.yaml** - Appliance monitoring (washer, dryer, etc.)
   - Configurable power thresholds and notification timing

3. **pet_care.yaml** - Medication reminders and feeding schedules
   - Multi-pet support with individual tracking

4. **daily_routine.yaml** - Morning and evening routines
   - Conditional execution based on presence

5. **person_presence.yaml** - Arrival and departure automations
   - Contextual scene activation

6. **emergency_alert.yaml** - Critical system alerts
   - Multi-channel notification support

7. **simple_time_based_control.yaml** - Time/sun triggered automations
   - Sunrise/sunset offsets, fixed schedules

### Dashboard Structure

Multiple dashboards optimized for different use cases:

- **responsive-dashboard.yaml** - Desktop-optimized ("House Dodson Command")
  - Wide layouts, detailed entity displays, full analytics
  - Primary control interface

- **dashboards/mobile_command.yaml** - Touch-optimized for phones/tablets
  - Simplified layouts, essential controls only
  - URL: `/lovelace-mobile-command`

- **dashboards/sietch_command.yaml** - Advanced analytics dashboard
  - System health metrics, automation success rates

- **dashboards/performance_monitoring.yaml** - System diagnostics

All dashboards include cross-navigation cards for easy switching.

### Automation Organization

Automations are organized in `/automations/` by:
- **Room** (e.g., `/automations/backyard/`)
- **Function** (e.g., top-level convenience automations)

Most automations (85%) use blueprints via `use_blueprint`. Only specialized automations have individual YAML files.

### Custom Components

Located in `/custom_components/`:
- **alexa_media** - Alexa device integration
- **browser_mod** - Browser-based controls
- **govee** - Govee device integration
- **kwikset** - Smart lock integration
- **mail_and_packages** - Mail/package tracking
- **powercalc** - Power consumption calculation
- **remote_homeassistant** - Remote HA instance integration
- **shopping_list_with_grocy** - Grocery management
- **spook** - Debugging/development utilities
- **spotcast** - Spotify casting

### Deployment Flow

1. Push to `main` branch
2. GitHub Actions runner (self-hosted on Unraid) validates config
3. On success, rsync copies files to `/mnt/user/appdata/Home-Assistant-Container/`
4. Excludes: `.git`, `__pycache__`, `.storage`, `home-assistant.log*`, secrets
5. Optional: Container restart via workflow dispatch

## Naming Conventions

- **Entity Names**: Practical, searchable names for UI (e.g., "Kitchen Light")
- **Descriptions**: Dune-themed flavor text in comments (e.g., "Atreides Command Center")
- **Files**: Descriptive, organized by room/function
- **Blueprints**: Action-based naming (e.g., `motion_lighting`, `appliance_cycle`)

## Common Development Tasks

### Adding a New Automation

1. **Check for patterns**: If 3+ similar automations exist, create/use a blueprint
2. **Blueprint approach**: Add to `/blueprints/automation/[name].yaml`, create instances in `/automations/`
3. **Individual approach**: Create in `/automations/[room|function]/[name].yaml`
4. No need to update configuration.yaml - automations auto-load via `!include_dir_merge_list`

### Adding a New Entity

1. Determine entity type (sensor, input_boolean, template, etc.)
2. Add to `/entities/[type]/[category].yaml`
3. Ensure integration file exists in `/integrations/[type].yaml` with proper include directive
4. Update dashboards if UI control needed

### Creating a New Blueprint

1. Identify duplicate pattern (3+ similar automations)
2. Extract common parameters as blueprint inputs
3. Create in `/blueprints/automation/[name].yaml`
4. Convert existing automations to `use_blueprint` references
5. Test all instances thoroughly with `ha core check`

### Dashboard Modifications

1. Remove broken entity references immediately
2. Use template sensors for calculated values
3. Target <600 lines per dashboard file
4. Test on both desktop and mobile views

## Performance Targets

- Dashboard files: <600 lines each
- Template sensors: <50ms render time
- Blueprint adoption: >80% of automations
- System health score: >85%
- Automation success rate: >90%

## Session System

This repository uses a structured session system for managing Claude Code workflows:

### Session Files
- **CLAUDE.sessions.md** - Collaboration philosophy and session management
- **sessions/protocols/** - Workflow protocols:
  - `task-creation.md` - Creating new tasks
  - `task-startup.md` - Beginning work on tasks
  - `task-completion.md` - Completing tasks
  - `context-compaction.md` - Managing context limits
- **.claude/state/current_task.json** - Tracks current active task

### Specialized Agents
Located in `.claude/agents/`:
- **context-gathering** - Creates comprehensive context manifests
- **code-review** - Reviews code quality and security
- **context-refinement** - Updates context with discoveries
- **logging** - Maintains chronological logs
- **service-documentation** - Updates service documentation

### Custom Commands
Located in `.claude/commands/`:
- **add-trigger** - Add triggers to automations
- **api-mode** - API interaction mode

### Quick State Check
```bash
cat .claude/state/current_task.json  # Shows current task
git branch --show-current            # Current branch
```

## Testing Strategy

- Batch testing at project milestones (not incremental)
- Full validation before commits: `ha core check`
- User preference: Complete features first, test at the end

## Backup Strategy

- **Git repository**: All configuration files (excludes secrets, database)
- **Home Assistant backups**: Full system via Nabu Casa cloud
- **Automated backups**: Via maintenance GitHub workflow
- **Manual backups**: Stored in `/backups/` directory

---

*This Home Assistant configuration emphasizes blueprint-based automation patterns, organized entity management, and automated deployment workflows.*

## Sessions System Behaviors

@CLAUDE.sessions.md
