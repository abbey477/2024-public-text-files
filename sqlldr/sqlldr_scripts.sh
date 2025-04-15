#!/bin/bash
# SQL*Loader Database Connection Test Scripts
# These scripts test database connectivity only without writing to tables

# Example 1: Basic connection test
# This script tests a simple connection to the database using SQL*Loader
# without actually loading any data

test_basic_connection() {
    echo "Testing basic SQL*Loader connection..."
    
    # Create empty data file
    touch empty_data.dat
    
    # Create control file with LOAD DATA INFILE but set ROWS=0 to prevent loading
    cat > test.ctl << EOF
LOAD DATA
INFILE 'empty_data.dat'
INTO TABLE dummy_table
ROWS=0
(dummy_col CHAR)
EOF

    # Run SQL*Loader with options to prevent actual loading
    echo "Running connection test..."
    sqlldr userid=username/password@database control=test.ctl log=test.log skip_index_maintenance=true rows=0
    
    # Check return code
    if [ $? -eq 0 ]; then
        echo "SUCCESS: SQL*Loader connection test successful"
        grep -i "connected to" test.log
    else
        echo "FAILED: SQL*Loader connection test failed"
        grep -i "error" test.log
    fi
    
    # Clean up
    rm -f empty_data.dat test.ctl test.log
}

# Example 2: Connection test with error handling and timeout
# This script uses a timeout to prevent hanging and provides better error messages

test_connection_with_timeout() {
    echo "Testing SQL*Loader connection with timeout..."
    
    # Connection parameters
    DB_USER="username"
    DB_PASS="password"
    DB_HOST="hostname"
    DB_SID="sid"
    TIMEOUT=30
    
    # Create empty files
    touch empty.dat
    
    cat > conn_test.ctl << EOF
LOAD DATA
INFILE 'empty.dat'
INTO TABLE dual
ROWS=0
(dummy CHAR)
EOF

    # Run SQL*Loader with timeout and options to prevent loading
    echo "Attempting connection with $TIMEOUT second timeout..."
    timeout $TIMEOUT sqlldr $DB_USER/$DB_PASS@$DB_HOST:1521/$DB_SID control=conn_test.ctl log=conn_test.log silent=header,feedback rows=0 skip_unused_columns=true
    RESULT=$?
    
    # Check return codes
    if [ $RESULT -eq 0 ]; then
        echo "SUCCESS: SQL*Loader connected successfully to database"
        grep -i "connected to" conn_test.log
    elif [ $RESULT -eq 124 ]; then
        echo "ERROR: SQL*Loader connection timed out after $TIMEOUT seconds"
    else
        echo "ERROR: SQL*Loader connection failed with return code $RESULT"
        grep -i "ora-" conn_test.log
    fi
    
    # Clean up
    rm -f empty.dat conn_test.ctl conn_test.log
}

# Example 3: Connection test with multiple databases
# This script tests connections to multiple databases and generates a report

test_multiple_connections() {
    echo "Testing SQL*Loader connections to multiple databases..."
    
    # Define database connections to test
    DATABASES=(
        "user1/pass1@db1"
        "user2/pass2@db2"
        "user3/pass3@db3"
    )
    
    # Create output report file
    REPORT="sqlldr_connection_report.txt"
    echo "SQL*Loader Connection Test Report - $(date)" > $REPORT
    echo "----------------------------------------" >> $REPORT
    
    # Create empty data file
    touch empty.dat
    
    # Create basic control file that doesn't load anything
    cat > conn_test.ctl << EOF
LOAD DATA
INFILE 'empty.dat'
INTO TABLE dual
ROWS=0
(dummy CHAR)
EOF
    
    # Test each database connection
    for DB in "${DATABASES[@]}"; do
        echo "Testing connection to $DB"
        echo -e "\nTesting: $DB" >> $REPORT
        
        # Run with minimal output, rows=0 to prevent loading any data
        sqlldr userid=$DB control=conn_test.ctl log=conn_test.log rows=0 silent=header,feedback skip_unused_columns=true
        RESULT=$?
        
        # Add result to report
        if [ $RESULT -eq 0 ]; then
            echo "  Connection SUCCESS" >> $REPORT
            grep -i "connected to" conn_test.log >> $REPORT
        else
            echo "  Connection FAILED (Error code: $RESULT)" >> $REPORT
            grep -i "ora-" conn_test.log >> $REPORT 2>/dev/null
        fi
    done
    
    echo "Connection testing complete. Results saved to $REPORT"
    cat $REPORT
    
    # Clean up
    rm -f empty.dat conn_test.ctl conn_test.log
}

# Example 4: Testing connection using TNS entry
# This script tests connection using TNS entry without loading data

test_tns_connection() {
    echo "Testing SQL*Loader connection using TNS entry..."
    
    # Connection parameters
    DB_USER="username"
    DB_PASS="password"
    TNS_NAME="my_tns_entry"
    
    # Check if tnsnames.ora is accessible
    if [ -n "$TNS_ADMIN" ] && [ -f "$TNS_ADMIN/tnsnames.ora" ]; then
        echo "Using TNS configuration from $TNS_ADMIN/tnsnames.ora"
    elif [ -n "$ORACLE_HOME" ] && [ -f "$ORACLE_HOME/network/admin/tnsnames.ora" ]; then
        echo "Using TNS configuration from $ORACLE_HOME/network/admin/tnsnames.ora"
    else
        echo "WARNING: Cannot locate tnsnames.ora file"
        echo "Connection will only succeed if $TNS_NAME is defined in your local naming method"
    fi
    
    # Create empty test file and simple control file
    touch empty.dat
    
    cat > tns_test.ctl << EOF
LOAD DATA
INFILE 'empty.dat'
INTO TABLE dual
ROWS=0
(dummy CHAR)
EOF

    # Run SQL*Loader with options to prevent data loading
    echo "Testing connection to $TNS_NAME..."
    sqlldr $DB_USER/$DB_PASS@$TNS_NAME control=tns_test.ctl log=tns_test.log rows=0 skip_index_maintenance=true
    RESULT=$?
    
    # Process results
    echo "SQL*Loader Connection Test Results:" > tns_report.txt
    echo "-----------------------------" >> tns_report.txt
    
    case $RESULT in
        0)
            echo "SUCCESS: Connected successfully to $TNS_NAME" >> tns_report.txt
            grep -i "connected to" tns_test.log >> tns_report.txt
            ;;
        1)
            echo "WARNING: Connection test completed with warnings" >> tns_report.txt
            ;;
        2)
            echo "ERROR: Connection test failed" >> tns_report.txt
            ;;
        3)
            echo "FATAL: Connection failed - could not connect to database" >> tns_report.txt
            ;;
        *)
            echo "UNKNOWN: Test returned unexpected code: $RESULT" >> tns_report.txt
            ;;
    esac
    
    # Include error details if any
    grep -i "ora-" tns_test.log >> tns_report.txt 2>/dev/null
    
    # Display report
    cat tns_report.txt
    
    # Clean up
    rm -f empty.dat tns_test.ctl tns_test.log tns_report.txt
}

# Example 5: Simple SQL*Loader version check
# Just checks that SQL*Loader is working and prints version info

check_sqlldr_version() {
    echo "Checking SQL*Loader version..."
    
    # Create minimal files needed for sqlldr to run
    touch empty.dat
    
    cat > version.ctl << EOF
LOAD DATA
INFILE 'empty.dat'
INTO TABLE dual
ROWS=0
(dummy CHAR)
EOF

    # Run SQL*Loader with help option to get version
    sqlldr help=y | grep -i "Release" > version.txt
    
    if [ $? -eq 0 ]; then
        echo "SQL*Loader is available:"
        cat version.txt
    else
        echo "Failed to get SQL*Loader version information"
    fi
    
    # Clean up
    rm -f empty.dat version.ctl version.txt
}

# Main script - uncomment the test you want to run
# test_basic_connection
# test_connection_with_timeout
# test_multiple_connections
# test_tns_connection
# check_sqlldr_version

# To run all tests:
test_basic_connection
test_connection_with_timeout
test_multiple_connections
test_tns_connection
check_sqlldr_version

echo "All SQL*Loader connection tests completed."
