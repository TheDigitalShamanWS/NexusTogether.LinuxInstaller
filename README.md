# NexusForever Linux Installer
============================

QUICK START
-----------

1. First-time setup (requires sudo):
   sudo ./start.sh

2. Normal usage (as nexusforever user):
   nexusforever

INSTALLATION
------------

Complete Installation (recommended):
   nexusforever install all

Manual Installation:
   nexusforever install server      # Install server core (includes patcher)
   nexusforever install mariadb     # Install MariaDB server
   nexusforever install database    # Setup database
   nexusforever install broker      # Install message broker
   nexusforever install configs     # Install configuration files
   nexusforever install services    # Setup services (systemd/screen)
   nexusforever install firewall    # Configure firewall

SERVICE MANAGEMENT
-----------------

Start all services:
   nexusforever service start all

Stop all services:
   nexusforever service stop all

Restart all services:
   nexusforever service restart all

Check service status:
   nexusforever service status

Manage individual services (auth, world, chat, group, api, patcher, sts):
   nexusforever service start <service>
   nexusforever service stop <service>
   nexusforever service restart <service>
   nexusforever service attach <service>

CONFIGURATION
-------------

Show all configuration:
   nexusforever config show

Update configuration:
   nexusforever config set <parameter> <value>

Backup configuration:
   nexusforever config backup

Restore configuration:
   nexusforever config restore

LOGS
-----

View service logs:
   nexusforever service logs <service>

View all logs:
   nexusforever service logs

TROUBLESHOOTING
---------------

Installation fails:
   - Check system requirements: nexusforever install requirements
   - Verify .NET 10 SDK is installed
   - Ensure sufficient disk space and permissions

Services won't start:
   - Check service status: nexusforever service status
   - View service logs: nexusforever service logs <service>
   - Verify configuration: nexusforever config show

Database issues:
   - Reinstall database: nexusforever install database
   - Check MariaDB service: systemctl status mariadb

UNINSTALLATION
--------------

Complete uninstall:
   nexusforever uninstall all

CONFIGURATION FILES
------------------

Main configuration directory: configs/
- general.conf       - General settings
- network.conf       - Network and port configuration
- database.conf      - Database connection settings
- services.conf      - Service definitions
- broker.conf        - Message broker settings

SERVICE MODES
--------------

Systemd mode (default):
   - Services run as system services
   - Auto-start on boot
   - Better for production

Screen mode:
   - Services run in screen sessions
   - Manual start/stop
   - Better for development

Set service mode in configs/general.conf

FOR MORE INFORMATION
-------------------

Check the full documentation in README.md for detailed setup instructions,
troubleshooting guides, and advanced configuration options.
