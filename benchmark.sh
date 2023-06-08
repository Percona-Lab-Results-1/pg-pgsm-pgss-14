#!/bin/bash

# Configuration variables
PG_HOST="localhost"
PG_PORT=5432
PG_USER="username"
PG_PASSWORD="password"
DATABASE="mydatabase"
THREADS=(1 4 8)
SYSBENCH_INSTALL_DIR="/path/to/sysbench"
ITERATIONS=10

# Function to run benchmark with different configurations
run_benchmark() {
    config=$1
    query=$2

    for threads in "${THREADS[@]}"; do
        echo "Running benchmark for $config configuration with $threads threads..."

        # Start PostgreSQL server with the specified configuration
        pg_ctl -D /path/to/postgresql/data -o "-c config_file=/path/to/postgresql.conf" start

        # Execute Sysbench OLTP read-only test
        sysbench $SYSBENCH_INSTALL_DIR/sysbench/tests/db/oltp.lua \
            --db-driver=pgsql \
            --threads=$threads \
            --pgsql-host=$PG_HOST \
            --pgsql-port=$PG_PORT \
            --pgsql-user=$PG_USER \
            --pgsql-password=$PG_PASSWORD \
            --pgsql-db=$DATABASE \
            --time=60 \
            --oltp-read-only=on \
            --oltp-table-size=1000000 \
            --oltp-tables-count=10 \
            --report-interval=1 \
            run

        # Stop PostgreSQL server
        pg_ctl -D /path/to/postgresql/data stop

        echo
    done
}

# Run benchmarks for different configurations
run_benchmark "Vanilla PostgreSQL" "SELECT * FROM mytable"
run_benchmark "PostgreSQL with pg_stat_monitor" "SELECT * FROM mytable"
run_benchmark "PostgreSQL with pg_stat_statements" "SELECT * FROM mytable"

