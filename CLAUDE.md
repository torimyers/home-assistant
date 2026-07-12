# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## System Overview

This is a **Home Assistant configuration repository** running on Unraid (Home Assistant 2026.5.4) with:
- All automations are standalone YAML files (blueprints were audited and removed as unused — see Automation Organization)
- Multiple dashboards optimized for different devices (desktop, mobile)
- Manual deployment to Unraid via `deploy.sh` / `sync-to-unraid.sh` (the self-hosted GitHub Actions runner is currently dead)

## Commands

### Configuration Validation
```bash
# Validate entire configuration
ha core check

# Validate configuration files
ha config validate

# YAML syntax check
yamllint .
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

3. **Entity Organization** - Placeholder directories exist in `/entities/` for future entity definitions by type (binary_sensor, counter, input_boolean, input_datetime, input_number, input_select, template, timer). Currently all entities are managed directly through the HA UI or integrations.

### Blueprint System

**No automation blueprints are in use.** The `/blueprints/automation/` tree previously held
10 unused blueprint files (0 adoption — no automation ever referenced them via `use_blueprint`,
and every one defaulted to a dead notify service). They were pruned during the automations audit.
Only Home Assistant's built-in `blueprints/script/` and `blueprints/template/` defaults remain
(HA regenerates those on startup). The hand-written automations intentionally carry their own
per-room logic (time-of-day tiers, lux gating, mode suppression) rather than a shared blueprint.

### Dashboard Structure

Two active dashboards with Bubble Card pop-up navigation:

- **ui-lovelace.yaml** - Primary desktop/tablet dashboard ("House Dodson Command")
  - Single-view Bubble Card layout with bottom nav + pop-ups
  - Pop-ups: Weather, Lights, Kitchen, Living Room, Office, Bedroom, Dining Room, Security, Routines, System, Batteries
  - URL: `/lovelace`

- **dashboards/mobile_command.yaml** - Touch-optimized for phones
  - Simplified Bubble Card layout with bottom nav + pop-ups
  - Pop-ups: Weather, Lights, Security, System
  - URL: `/lovelace-mobile-command`

- **dashboards/performance_monitoring.yaml** - System diagnostics
  - URL: `/lovelace-performance`

No retired dashboards — old dashboards (overview, analytics, controls, sietch_command) have been deleted.

### Automation Organization

Automations are organized in `/automations/` by:
- **Room** (e.g., `/automations/backyard/`)
- **Function** (e.g., top-level convenience automations)

All repo automations are individual, standalone YAML files. There are **no automation blueprints** — the 10 previously-unused blueprint files were pruned during the automations audit (see Blueprint System). New automations should be written as individual files unless a genuinely duplicated pattern later justifies a blueprint. (Note: the live instance also has many UI-created automations stored in `.storage` that are not in this repo.)

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
4. Excludes: `.git`, `*.pyc`, `__pycache__`, `.storage`, `home-assistant.log*`, `custom_components`, `zigbee.db`, `zigbee.db-shm`, `zigbee.db-wal`
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

*This Home Assistant configuration emphasizes standalone per-room automations, organized entity management, and automated deployment workflows.*

## Sessions System Behaviors

@CLAUDE.sessions.md
