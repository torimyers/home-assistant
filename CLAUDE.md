# Claude Code Configuration

## Lint and Type Check Commands
Run these commands after making code changes to ensure configuration validity:

```bash
# Home Assistant configuration check
ha core check

# Home Assistant configuration validation  
ha config validate

# YAML syntax validation
yamllint .

# Blueprint validation
ha automation test --blueprint motion_lighting
ha automation test --blueprint appliance_cycle
ha automation test --blueprint pet_care
```

## Project Context
This is a Home Assistant configuration repository with:
- Dune-themed naming and descriptions
- Blueprint-based automation system (85% consolidation achieved)
- Comprehensive template sensor analytics
- Optimized dashboard structure (87.5% file size reduction)
- Automated deployment via GitHub Actions

## Dashboard Configuration

### Main Dashboards:
- **Default Dashboard**: `responsive-dashboard.yaml` - "House Dodson Command"
  - Desktop-optimized with full analytics and controls
  - Wide layouts, detailed entity displays, comprehensive system overview
  - User-friendly names with Dune references in secondary info
  
- **Mobile Dashboard**: `dashboards/mobile_command.yaml` - "📱 Mobile Command"  
  - Touch-optimized for phones/tablets
  - Simplified layouts, essential controls, quick navigation
  - Clear primary names with Dune context in secondary info
  - URL: `/lovelace-mobile-command`

### Specialized Dashboards:
- **Sietch Command**: `dashboards/sietch_command.yaml` - Advanced analytics
- **Performance Monitor**: `dashboards/performance_monitoring.yaml` - System diagnostics
- **Desktop Command**: Links back to main dashboard for easy access

### Navigation:
All dashboards include cross-navigation cards to switch between:
- Desktop ↔ Mobile views
- Specialized analytics dashboards  
- Quick access to system controls

## Testing Approach
- Batch testing at project milestones rather than incremental
- Full system validation before commits
- User preference: "lets continue on, we can test at the end"

## Key Directories
- `/automations` - Blueprint instances and specialized automations
- `/blueprints` - Reusable automation templates  
- `/entities` - Organized by entity type
- `/dashboards` - Custom UI configurations
- `/integrations` - Integration configurations

## Blueprint System
Current blueprints eliminate duplicate patterns:
- Motion Lighting (8 files → 1 blueprint)
- Appliance Cycle (3 files → 1 blueprint)  
- Pet Care (3 files → 1 blueprint)
- Daily Routine (4 files → 1 blueprint)
- Person Presence (4 files → 1 blueprint)
- Emergency Alert (3 files → 1 blueprint)
- Simple Time-Based Control (time/sun triggered)

## Maintenance Commands
```bash
# Deploy configuration
git push origin main

# Run maintenance tasks
gh workflow run maintenance.yaml -f task=config-check
gh workflow run maintenance.yaml -f task=entity-cleanup  
gh workflow run maintenance.yaml -f task=backup-create
gh workflow run maintenance.yaml -f task=performance-report

# Force container restart after deploy
gh workflow run deploy.yaml -f force_restart=true
```

## Naming Conventions
- **Entity Names**: Practical for UI searchability
- **Descriptions**: Dune-themed in comments and documentation
- **Files**: Descriptive, room/function organized
- **Blueprints**: Action-based naming (motion_lighting, appliance_cycle)

## Performance Targets
- Dashboard files: <600 lines each
- Template sensors: <50ms render time
- Blueprint adoption: >80% of automations
- System health score: >85%
- Automation success rate: >90%

## Common Tasks

### Adding New Automation
1. Check if pattern exists (3+ similar automations)
2. If yes: Create blueprint or use existing
3. If no: Create individual automation file
4. Place in appropriate `/automations/[room|function]/` directory

### Adding New Entity
1. Determine entity type (sensor, input_boolean, etc.)
2. Add to appropriate `/entities/[type]/[category].yaml`
3. Ensure integration file exists in `/integrations/`
4. Update dashboards if UI control needed

### Creating New Blueprint
1. Identify duplicate automation pattern
2. Extract common parameters as inputs
3. Create in `/blueprints/automation/[name].yaml`
4. Convert existing automations to use_blueprint
5. Test all instances thoroughly

### Dashboard Optimization
1. Remove broken entity references immediately
2. Use template sensors for calculated values
3. Implement card-mod for consistent styling
4. Target <600 lines per dashboard file

## Deployment Flow
1. Changes pushed to `main` branch
2. GitHub Actions validates configuration
3. Successful validation triggers deployment
4. Files copied to `/mnt/user/appdata/Home-Assistant-Container/`
5. Optional container restart via workflow dispatch

## Backup Strategy
- GitHub repository: Configuration files
- Home Assistant backups: Full system via Nabu Casa  
- Automated backups: Via maintenance workflow
- Manual backups: In `/backups/` directory

---
*Claude Code is configured for Home Assistant development with automated testing, deployment, and maintenance workflows.*
## Sessions System Behaviors

@CLAUDE.sessions.md
