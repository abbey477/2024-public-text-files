#!/bin/bash
# Simple SQL*Loader Database Connection Test Script
# Tests database connection and logs CSV parsing results

# CSV file and control file passed as arguments
CSV_FILE=$1
CTL_FILE=$2
DB_CONN=$3

# Default values if not provided
if [ -z "$CSV_FILE" ]; then
  CSV_FILE="data.csv"
  echo "No CSV file specified, using default: $CSV_FILE"
fi

if [ -z "$CTL_FILE" ]; then
  CTL_FILE="data.ctl"
  echo "No control file specified, using default: $CTL_FILE"
fi

if [ -z "$DB_CONN" ]; then
  DB_CONN="username/password@database"
  echo "No database connection specified, using default: $DB_CONN"
  echo "IMPORTANT: Update the script with your actual database credentials"
fi

# Log file for parsed CSV and connection results
LOG_FILE="sqlldr_test_$(date +%Y%m%d_%H%M%S).log"

# Create log header
echo "=== SQL*Loader Connection Test ===" > $LOG_FILE
echo "Date: $(date)" >> $LOG_FILE
echo "CSV File: $CSV_FILE" >> $LOG_FILE
echo "Control File: $CTL_FILE" >> $LOG_FILE
echo "Database Connection: $DB_CONN" >> $LOG_FILE
echo "" >> $LOG_FILE

# Check if files exist
if [ ! -f "$CSV_FILE" ]; then
  echo "Error: CSV file '$CSV_FILE' not found" | tee -a $LOG_FILE
  exit 1
fi

if [ ! -f "$CTL_FILE" ]; then
  echo "Error: Control file '$CTL_FILE' not found" | tee -a $LOG_FILE
  exit 1
fi

# Log control file contents
echo "=== Control File Contents ===" >> $LOG_FILE
cat "$CTL_FILE" >> $LOG_FILE
echo "" >> $LOG_FILE

# Parse and log CSV data (first 5 rows maximum)
echo "=== CSV Data Sample ===" >> $LOG_FILE
head -5 "$CSV_FILE" >> $LOG_FILE
echo "" >> $LOG_FILE

# Run SQL*Loader for connection test only (ROWS=0)
echo "Testing database connection..." | tee -a $LOG_FILE
sqlldr userid="$DB_CONN" control="$CTL_FILE" log="sqlldr.log" rows=0 skip_index_maintenance=true
RESULT=$?

# Check connection result
echo "" >> $LOG_FILE
echo "=== Connection Test Results ===" >> $LOG_FILE

if [ $RESULT -eq 0 ]; then
  echo "SUCCESS: Database connection successful" | tee -a $LOG_FILE
elif [ $RESULT -eq 1 ]; then
  echo "WARNING: Connection succeeded with warnings" | tee -a $LOG_FILE
elif [ $RESULT -eq 2 ]; then
  echo "ERROR: Connection succeeded but data errors occurred" | tee -a $LOG_FILE
elif [ $RESULT -eq 3 ]; then
  echo "FATAL: Database connection failed" | tee -a $LOG_FILE
else
  echo "UNKNOWN: Test returned code $RESULT" | tee -a $LOG_FILE
fi

# Include SQL*Loader log output in our log
echo "" >> $LOG_FILE
echo "=== SQL*Loader Log ===" >> $LOG_FILE
cat sqlldr.log >> $LOG_FILE

# Clean up temporary SQL*Loader log
rm -f sqlldr.log

echo "Test completed. Results saved to $LOG_FILE"
