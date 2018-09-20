#!/bin/sh

#echo "List of Databases and Size"
#set -x
PGHOST=web-master-rds.cwbpdp5vvep9.ap-south-1.rds.amazonaws.com PGUSER=treeboadmin PGPASSWORD=caTwimEx3 psql postgres -c "SELECT datname as DB_Name FROM pg_database;" > /tmp/db_name.txt

cat /tmp/db_name.txt|grep -Ev 'rdsadmin|template1|postgres|rows|db_name|------------|template0'|grep -v '^$' > /tmp/dabase_list.txt

while read line
do
echo "======================================"
echo "DB Name: $line"
echo "Size of the DataBase"

PGHOST=web-master-rds.cwbpdp5vvep9.ap-south-1.rds.amazonaws.com PGUSER=treeboadmin PGPASSWORD=caTwimEx3 psql postgres -c "SELECT pg_size_pretty(pg_database_size('${line}'));"
#echo "Top 10 tables bsaed on size"


#PGHOST=web-master-rds.cwbpdp5vvep9.ap-south-1.rds.amazonaws.com PGUSER=treeboadmin PGPASSWORD=caTwimEx3 PGDATABASE=${line} psql postgres -c "SELECT nspname || '.' || relname AS "relation",
#   pg_size_pretty(pg_total_relation_size(C.oid)) AS "total_size"
# FROM pg_class C
# LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
# WHERE nspname NOT IN ('pg_catalog', 'information_schema')
#   AND C.relkind <> 'i'
#   AND nspname !~ '^pg_toast'
# ORDER BY pg_total_relation_size(C.oid) DESC limit 10 ;"


done < /tmp/dabase_list.txt



