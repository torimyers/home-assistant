# Home Assistant Configuration Maintenance Guide

## Overview
This guide provides essential maintenance procedures for the Dune-themed Home Assistant configuration, including blueprint management, entity organization, and system optimization.

## Directory Structure

```
home-assistant/
├── .github/workflows/         # GitHub Actions deployment
├── automations/              # Automation files organized by room/function
├── blueprints/              # Reusable automation templates
├── dashboards/              # Custom dashboard configurations
├── entities/                # Entity definitions by type
│   ├── binary_sensor/       # System status sensors
│   ├── counter/             # Motion and activity counters
│   ├── input_boolean/       # Toggle controls
│   ├── input_datetime/      # Date/time tracking
│   ├── input_number/        # Numeric thresholds
│   ├── input_select/        # Dropdown selections
│   ├── template/            # Calculated template sensors
│   └── timer/               # Automation timing controls
├── integrations/            # Integration configurations
├── scenes/                  # Scene definitions by room
├── scripts/                 # Script definitions by function
└── themes/                  # Custom UI themes
```

## Blueprint System

### Available Blueprints
1. **Motion Lighting** (`blueprints/automation/motion_lighting.yaml`)
   - Consolidated 8 motion sensor automations
   - Configurable timeout and brightness

2. **Appliance Cycle** (`blueprints/automation/appliance_cycle.yaml`)
   - Washer, dryer, and other appliance monitoring
   - Customizable notification timing

3. **Pet Care** (`blueprints/automation/pet_care.yaml`)
   - Medication reminders and feeding schedules
   - Multi-pet support with individual tracking

4. **Simple Time-Based Control** (`blueprints/automation/simple_time_based_control.yaml`)
   - Sunrise/sunset triggered automations
   - Fixed time scheduling

5. **Daily Routine** (`blueprints/automation/daily_routine.yaml`)
   - Morning and evening routines
   - Conditional execution based on presence

6. **Person Presence** (`blueprints/automation/person_presence.yaml`)
   - Arrival and departure automations
   - Contextual scene activation

7. **Emergency Alert** (`blueprints/automation/emergency_alert.yaml`)
   - Critical system alerts and responses
   - Multi-channel notification support

### Creating New Blueprints
1. Identify duplicate automation patterns (3+ similar files)
2. Extract common parameters as blueprint inputs
3. Create blueprint file in `blueprints/automation/`
4. Convert existing automations to use `use_blueprint`
5. Test all blueprint instances thoroughly

## Entity Management

### Naming Conventions
- **Entities**: Practical names for UI searchability
- **Descriptions**: Dune-themed flavor text in comments
- **Icons**: Consistent mdi: icon usage
- **Groups**: Logical organization by function

### Adding New Entity Types
1. Create directory under `entities/[entity_type]/`
2. Add integration file in `integrations/[entity_type].yaml`
3. Use appropriate include method:
   - `!include_dir_merge_named` for single entity per file
   - `!include_dir_list` for multiple entities per file

### Template Sensors
Located in `entities/template/dune_analytics.yaml`:
- **Sietch Health Score**: Overall system health (0-100%)
- **Spice Production Level**: Activity metrics
- **Water Conservation Index**: Resource efficiency
- **Energy Shield Status**: Security system status
- **Automation Success Rate**: System reliability
- Additional analytics sensors for monitoring

## Dashboard Management

### Main Dashboards
1. **dashboard.yaml**: Navigation hub with quick controls
2. **responsive-dashboard.yaml**: Comprehensive control interface  
3. **dashboards/sietch_command.yaml**: Advanced analytics and monitoring

### Dashboard Optimization
- Remove broken entity references immediately
- Use template sensors for calculated values
- Implement consistent card styling with card-mod
- Maintain 80% or better performance score

## Integration Configuration

### Critical Integrations
- **automation.yaml**: Loads all automation files
- **template.yaml**: Template sensor definitions
- **scene.yaml**: Scene management with dual loading
- **script.yaml**: Script management with dual loading
- **input_*.yaml**: User interface controls

### Include Patterns
- `!include_dir_list`: Multiple entities per file
- `!include_dir_merge_named`: Single entity per file
- `!include_dir_named`: Complex nested structures

## Backup and Recovery

### GitHub Actions Deployment
- Automatic deployment via `.github/workflows/deploy.yaml`
- Excludes sensitive files (secrets.yaml, zigbee.db)
- Container restart on successful deployment

### Manual Backup Locations
- Home Assistant backups via Nabu Casa
- Git repository for configuration files
- Local backups in `backups/` directory

## Maintenance Tasks

### Daily
- Monitor system health score (target: >85%)
- Check automation success rate (target: >90%)
- Review critical alerts

### Weekly
- Review notification system effectiveness
- Update entity thresholds if needed
- Check for new automation patterns to blueprint

### Monthly  
- Analyze template sensor accuracy
- Review and optimize dashboard performance
- Update documentation for new features
- Clean up unused entities and automations

### Quarterly
- Full configuration backup and test restore
- Review and update all blueprint parameters
- Performance optimization review
- Security configuration audit

## Troubleshooting

### Common Issues
1. **Broken Entity References**: Check dashboard.yaml and responsive-dashboard.yaml
2. **Blueprint Validation Errors**: Ensure entity defaults are not empty strings
3. **Include Path Failures**: Verify directory structure and placeholder files
4. **Template Sensor Errors**: Check entity availability in templates

### Validation Commands
```bash
# Check configuration
ha core check

# Validate specific files
ha config validate --path integrations/

# Test blueprint
ha automation test --blueprint motion_lighting
```

### Log Monitoring
Monitor these log categories:
- `homeassistant.components.template`: Template sensor issues
- `homeassistant.components.automation`: Automation failures
- `homeassistant.loader`: Integration loading problems

## Performance Optimization

### Dashboard Performance
- Target: <600 lines per dashboard file
- Minimize complex template expressions
- Use efficient card types (mushroom over standard)
- Implement lazy loading for heavy cards

### Automation Efficiency  
- Use blueprints to reduce duplication (target: <50 total automation files)
- Implement proper trigger conditions
- Use efficient state checking methods
- Enable automation success rate monitoring

### Entity Optimization
- Regular cleanup of unused entities
- Efficient template sensor calculations
- Proper device class assignments
- Consistent unit of measurement usage

## Version Control

### Commit Guidelines
- Use descriptive commit messages
- Stage related changes together
- Include Claude Code co-authorship for AI assistance
- Test configuration before committing

### Branch Strategy
- `main`: Production configuration
- `automation-refactor`: Current optimization branch  
- Feature branches for major changes

---

*This documentation is maintained as part of the House Atreides Central Command system optimization project.*