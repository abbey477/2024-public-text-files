#!/bin/bash

# Set variables
USERNAME="username"
PASSWORD="password"
DATABASE="database"  # Optional, if connecting to a specific database/service
TABLE_NAME="sample_table"
CSV_FILE="sample_data.csv"
CONTROL_FILE="load_data.ctl"
LOG_FILE="load_data.log"
BAD_FILE="load_data.bad"

# Create sample table (uncomment if needed)
# sqlplus $USERNAME/$PASSWORD <<EOF
# CREATE TABLE $TABLE_NAME (
#   id NUMBER,
#   name VARCHAR2(50),
#   value NUMBER
# );
# EXIT;
# EOF

# Create sample CSV file
echo "Creating sample CSV file..."
cat > $CSV_FILE << EOF
1,John Doe,100
2,Jane Smith,200
3,Bob Johnson,300
EOF
echo "CSV file created."

# Create control file
echo "Creating control file..."
cat > $CONTROL_FILE << EOF
LOAD DATA
INFILE '$CSV_FILE'
INTO TABLE $TABLE_NAME
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  id,
  name,
  value
)
EOF
echo "Control file created."

# Run SQL*Loader
echo "Running SQL*Loader..."
sqlldr $USERNAME/$PASSWORD@$DATABASE control=$CONTROL_FILE log=$LOG_FILE bad=$BAD_FILE

# Check return code
RESULT=$?
if [ $RESULT -eq 0 ]; then
  echo "SQL*Loader completed successfully."
elif [ $RESULT -eq 1 ]; then
  echo "SQL*Loader completed with warnings. Check the log file: $LOG_FILE"
elif [ $RESULT -eq 2 ]; then
  echo "SQL*Loader failed. Check the log file: $LOG_FILE"
else
  echo "SQL*Loader encountered an unexpected error (code: $RESULT)."
fi

# Display log file
echo "Contents of log file:"
cat $LOG_FILE

# Optional: cleanup
# echo "Cleaning up files..."
# rm $CSV_FILE $CONTROL_FILE $LOG_FILE $BAD_FILE
