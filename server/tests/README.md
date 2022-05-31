### Test: filling system with records
1. Clear database: `docker exec hogweed-server python3 /app/manage.py db clear`
2. Create admin: `docker exec hogweed-server python3 /app/manage.py admin -e [ADMIN_EMAIL] -p [ADMIN_PASSWORD]`
3. Add test data: `python3 ./generate_reports.py [SERVER_PORT_NUMBER] [REPORTS_NUMBER] -u [HOW_MANY_REPORTS_PER_USER]`