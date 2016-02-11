mysqld_safe & mysqladmin --wait=5 ping
mysql < /mysql.ddl
cd /zabbix*/database/mysql
mysql -uzabbix zabbix < schema.sql 
mysql -uzabbix zabbix < images.sql
mysql -uzabbix zabbix < data.sql
mysqladmin shutdown
