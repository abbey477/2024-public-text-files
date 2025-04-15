#!/bin/bash
# SQL*Loader Database Connection Test Scripts with CSV Parsing Validation
# These scripts test database connectivity and output parsed CSV data to log files

# Example 1: Basic connection test with CSV parsing
test_basic_connection() {
    echo "Testing basic SQL*Loader connection..."
    
    # Create a sample CSV file (this would be your input file in a real scenario)
    cat > sample_data.csv << EOF
id,name,department,hire_date
1,John Smith,IT,2023-01-15
2,Jane Doe,HR,2022-05-20
3,Mike Johnson,Finance,2024-02-10
EOF

    # Create control file with LOAD DATA INFILE but set ROWS=0 to prevent loading
    cat > test.ctl << EOF
LOAD DATA
INFILE 'sample_data.csv'
INTO TABLE employees
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(id, name, department, hire_date)
EOF

    # Define log files
    PARSE_LOG="csv_parse_log.txt"
    CONN_LOG="connection_log.txt"
    
    # Create parse log header
    echo "--------------- CSV PARSE VALIDATION ---------------" > $PARSE_LOG
    echo "Timestamp: $(date)" >> $PARSE_LOG
    echo "CSV File: sample_data.csv" >> $PARSE_LOG
    echo "" >> $PARSE_LOG
    
    # Parse CSV and append to log file (without using database)
    echo "Parsed CSV contents:" >> $PARSE_LOG
    echo "-------------------" >> $PARSE_LOG
    # Read the CSV header
    header=$(head -1 sample_data.csv)
    echo "Header: $header" >> $PARSE_LOG
    echo "" >> $PARSE_LOG
    echo "Data rows:" >> $PARSE_LOG
    
    # Skip header and process each line of the CSV
    tail -n +2 sample_data.csv | while IFS= read -r line; do
        echo "Row: $line" >> $PARSE_LOG
        
        # Generate the SQL that would be executed (but won't be)
        IFS=',' read -r id name department hire_date <<< "$line"
        echo "  Would execute: INSERT INTO employees (id, name, department, hire_date) VALUES ($id, '$name', '$department', TO_DATE('$hire_date', 'YYYY-MM-DD'));" >> $PARSE_LOG
    done
    
    # Run SQL*Loader with options to prevent actual loading
    echo "Running connection test..." > $CONN_LOG
    echo "Using control file:" >> $CONN_LOG
    cat test.ctl >> $CONN_LOG
    echo "" >> $CONN_LOG
    
    # Execute sqlldr but with ROWS=0 to prevent loading
    sqlldr userid=username/password@database control=test.ctl log=sqlldr.log skip_index_maintenance=true rows=0
    RESULT=$?
    
    # Record connection status
    echo "Connection results:" >> $CONN_LOG
    if [ $RESULT -eq 0 ]; then
        echo "SUCCESS: SQL*Loader connection test successful" | tee -a $CONN_LOG
        grep -i "connected to" sqlldr.log >> $CONN_LOG
    else
        echo "FAILED: SQL*Loader connection test failed" | tee -a $CONN_LOG
        grep -i "error" sqlldr.log >> $CONN_LOG
    fi
    
    echo "Parse validation log saved to $PARSE_LOG"
    echo "Connection log saved to $CONN_LOG"
    
    # Clean up temporary files but keep the logs
    rm -f sqlldr.log test.ctl
}

# Example 2: Connection test with more complex CSV format
test_complex_csv() {
    echo "Testing connection with complex CSV parsing..."
    
    # Create a more complex sample CSV file
    cat > complex_data.csv << EOF
"Transaction ID","Customer Name","Product Code","Quantity","Unit Price","Total","Purchase Date","Notes"
"TRX-10001","ACME Corp","PROD-A1","5","29.99","149.95","2025-03-15","Initial order"
"TRX-10002","XYZ Industries","PROD-B2","10","15.75","157.50","2025-03-17","Recurring monthly"
"TRX-10003","Global Services Inc","PROD-C3","2","199.99","399.98","2025-03-18","Express delivery requested"
"TRX-10004","Local Shop","PROD-A1","1","29.99","29.99","2025-03-20","Phone order"
EOF
    
    # Create a more complex control file
    cat > complex.ctl << EOF
LOAD DATA
INFILE 'complex_data.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
SKIP 1
(transaction_id, customer_name, product_code, quantity, unit_price, total, 
 purchase_date DATE "YYYY-MM-DD", notes)
EOF
    
    # Create parse log
    PARSE_LOG="complex_csv_parse_log.txt"
    echo "--------------- COMPLEX CSV PARSE VALIDATION ---------------" > $PARSE_LOG
    echo "Timestamp: $(date)" >> $PARSE_LOG
    echo "CSV File: complex_data.csv" >> $PARSE_LOG
    echo "Control File: complex.ctl" >> $PARSE_LOG
    echo "" >> $PARSE_LOG
    
    # Extract header from the first line
    header=$(head -1 complex_data.csv)
    echo "CSV Header: $header" >> $PARSE_LOG
    echo "" >> $PARSE_LOG
    
    # Explain the parsing rules
    echo "SQL*Loader Parsing Rules:" >> $PARSE_LOG
    echo "- Fields terminated by: comma (,)" >> $PARSE_LOG
    echo "- Fields optionally enclosed by: double quotes (\")" >> $PARSE_LOG
    echo "- First row (header) will be skipped" >> $PARSE_LOG
    echo "- Purchase date will be converted to DATE using format YYYY-MM-DD" >> $PARSE_LOG
    echo "" >> $PARSE_LOG
    
    # Process the data rows
    echo "Parsed Data (with corresponding SQL):" >> $PARSE_LOG
    echo "------------------------------------" >> $PARSE_LOG
    
    # Skip header and process each data row
    tail -n +2 complex_data.csv | while IFS= read -r line; do
        # Remove quotes for display
        clean_line=$(echo "$line" | sed 's/"//g')
        echo "Row: $clean_line" >> $PARSE_LOG
        
        # Parse the CSV line into variables
        IFS=',' read -r txn_id customer prod_code qty price total date notes <<< "$(echo "$line" | sed 's/"//g')"
        
        # Generate the SQL that would be executed (but won't be)
        echo "  SQL: INSERT INTO transactions VALUES ('$txn_id', '$customer', '$prod_code', $qty, $price, $total, TO_DATE('$date', 'YYYY-MM-DD'), '$notes');" >> $PARSE_LOG
        echo "" >> $PARSE_LOG
    done
    
    # Run the connection test only
    sqlldr userid=username/password@database control=complex.ctl log=complex.log rows=0
    RESULT=$?
    
    # Add connection results to the log
    echo "Database Connection Test Results:" >> $PARSE_LOG
    if [ $RESULT -eq 0 ]; then
        echo "SUCCESS: Connected to database successfully" >> $PARSE_LOG
        grep -i "connected to" complex.log >> $PARSE_LOG
    else
        echo "FAILED: Database connection failed (Error code: $RESULT)" >> $PARSE_LOG
        grep -i "error" complex.log >> $PARSE_LOG
    fi
    
    echo "Complex CSV parse validation log saved to $PARSE_LOG"
    
    # Clean up temporary files but keep logs
    rm -f complex.ctl complex.log
}

# Example 3: Multiple database connection test with CSV validation
test_multiple_connections() {
    echo "Testing connections to multiple databases with CSV validation..."
    
    # Create a sample CSV with database test cases
    cat > db_tests.csv << EOF
database_name,username,password,sid,test_query
production,prod_user,prod_pass,PROD,"SELECT COUNT(*) FROM users"
development,dev_user,dev_pass,DEV,"SELECT COUNT(*) FROM users"
testing,test_user,test_pass,TEST,"SELECT COUNT(*) FROM users"
EOF
    
    # Define log files
    PARSE_LOG="multi_db_parse_log.txt"
    CONN_LOG="multi_db_connection_log.txt"
    
    # Create header for parse log
    echo "--------------- MULTIPLE DB TEST CONFIGURATION ---------------" > $PARSE_LOG
    echo "Timestamp: $(date)" >> $PARSE_LOG
    echo "Test Configuration File: db_tests.csv" >> $PARSE_LOG
    echo "" >> $PARSE_LOG
    
    # Parse the CSV and generate connection strings
    echo "Parsed Database Connections:" >> $PARSE_LOG
    echo "-------------------------" >> $PARSE_LOG
    
    # Create connection log header
    echo "SQL*Loader Multi-Database Connection Test Results - $(date)" > $CONN_LOG
    echo "------------------------------------------------" >> $CONN_LOG
    
    # Skip header and process each database connection
    tail -n +2 db_tests.csv | while IFS=, read -r db_name username password sid test_query; do
        echo "Database: $db_name" >> $PARSE_LOG
        echo "  Connection string: $username/$password@$sid" >> $PARSE_LOG
        echo "  Test query: $test_query" >> $PARSE_LOG
        echo "" >> $PARSE_LOG
        
        # Create empty data file for this test
        touch empty.dat
        
        # Create control file for this connection
        cat > test_${db_name}.ctl << EOF
LOAD DATA
INFILE 'empty.dat'
INTO TABLE dual
ROWS=0
(dummy CHAR)
EOF
        
        # Run SQL*Loader for this connection
        echo "Testing connection to: $db_name ($username/$password@$sid)" >> $CONN_LOG
        sqlldr userid=$username/$password@$sid control=test_${db_name}.ctl log=test_${db_name}.log rows=0 silent=header,feedback
        RESULT=$?
        
        # Add result to connection log
        if [ $RESULT -eq 0 ]; then
            echo "  Status: SUCCESS" >> $CONN_LOG
            grep -i "connected to" test_${db_name}.log >> $CONN_LOG
        else
            echo "  Status: FAILED (Error code: $RESULT)" >> $CONN_LOG
            grep -i "ora-" test_${db_name}.log >> $CONN_LOG 2>/dev/null
        fi
        echo "" >> $CONN_LOG
        
        # Clean up files for this connection
        rm -f test_${db_name}.ctl test_${db_name}.log
    done
    
    echo "Parsed CSV configuration saved to $PARSE_LOG"
    echo "Connection test results saved to $CONN_LOG"
    
    # Clean up
    rm -f empty.dat
}

# Example 4: CSV format detection and validation
test_csv_format() {
    echo "Testing CSV format detection and validation..."
    
    # Create several CSV files with different formats
    # Standard CSV
    cat > standard.csv << EOF
id,name,email,phone
1,John Doe,john@example.com,555-1234
2,Jane Smith,jane@example.com,555-5678
3,Bob Johnson,bob@example.com,555-9012
EOF

    # Tab-delimited
    cat > tabbed.csv << EOF
id	name	email	phone
1	John Doe	john@example.com	555-1234
2	Jane Smith	jane@example.com	555-5678
3	Bob Johnson	bob@example.com	555-9012
EOF

    # Semicolon-delimited (European format)
    cat > semicolon.csv << EOF
id;name;email;phone
1;John Doe;john@example.com;555-1234
2;Jane Smith;jane@example.com;555-5678
3;Bob Johnson;bob@example.com;555-9012
EOF
    
    # Create log file
    FORMAT_LOG="csv_format_validation.txt"
    echo "--------------- CSV FORMAT VALIDATION ---------------" > $FORMAT_LOG
    echo "Timestamp: $(date)" >> $FORMAT_LOG
    echo "" >> $FORMAT_LOG
    
    # Function to detect delimiter and validate CSV files
    validate_csv() {
        local file=$1
        local filename=$(basename "$file")
        
        echo "Validating file: $filename" >> $FORMAT_LOG
        echo "------------------------" >> $FORMAT_LOG
        
        # Get first line to detect header
        header=$(head -1 "$file")
        echo "Header line: $header" >> $FORMAT_LOG
        
        # Try to detect delimiter
        if [[ $header == *";"* ]]; then
            delimiter=";"
            echo "Detected delimiter: semicolon (;)" >> $FORMAT_LOG
        elif [[ $header == *"	"* ]]; then
            delimiter="	"
            echo "Detected delimiter: tab" >> $FORMAT_LOG
        elif [[ $header == *","* ]]; then
            delimiter=","
            echo "Detected delimiter: comma (,)" >> $FORMAT_LOG
        else
            echo "Could not detect delimiter" >> $FORMAT_LOG
            return
        fi
        
        # Count fields in header
        if [ "$delimiter" = "	" ]; then
            field_count=$(echo "$header" | awk -F'\t' '{print NF}')
        else
            field_count=$(echo "$header" | awk -F"$delimiter" '{print NF}')
        fi
        echo "Number of fields: $field_count" >> $FORMAT_LOG
        
        # Create appropriate control file for this format
        cat > ${filename%.csv}.ctl << EOF
LOAD DATA
INFILE '$file'
INTO TABLE test_table
FIELDS TERMINATED BY '$delimiter'
TRAILING NULLCOLS
SKIP 1
EOF

        # Add field list based on header
        echo "(" >> ${filename%.csv}.ctl
        
        # Extract field names
        IFS="$delimiter" read -r -a fields <<< "$header"
        for ((i=0; i<${#fields[@]}; i++)); do
            field="${fields[$i]}"
            # Remove any quotes from field name
            field=$(echo "$field" | sed 's/"//g')
            
            if [ $i -eq $((${#fields[@]}-1)) ]; then
                echo "    $field" >> ${filename%.csv}.ctl
            else
                echo "    $field," >> ${filename%.csv}.ctl
            fi
        done
        echo ")" >> ${filename%.csv}.ctl
        
        # Add control file to log
        echo "" >> $FORMAT_LOG
        echo "Generated control file:" >> $FORMAT_LOG
        cat ${filename%.csv}.ctl >> $FORMAT_LOG
        echo "" >> $FORMAT_LOG
        
        # Parse and log each data row
        echo "Parsed data rows:" >> $FORMAT_LOG
        row_num=0
        
        # Skip header and read data rows
        tail -n +2 "$file" | while IFS= read -r line; do
            row_num=$((row_num+1))
            echo "Row $row_num: $line" >> $FORMAT_LOG
            
            # Generate INSERT statement that would be executed
            if [ "$delimiter" = "	" ]; then
                # Handle tab delimiter specially
                values=$(echo "$line" | sed 's/	/,/g')
            else
                # Replace delimiter with comma for the SQL statement
                values=$(echo "$line" | sed "s/$delimiter/,/g")
            fi
            
            echo "  Would execute: INSERT INTO test_table VALUES ($values);" >> $FORMAT_LOG
        done
        
        echo "" >> $FORMAT_LOG
        
        # Test connection only without loading data
        echo "Testing database connection only..." >> $FORMAT_LOG
        sqlldr userid=username/password@database control=${filename%.csv}.ctl log=${filename%.csv}.log rows=0 skip_unused_columns=true silent=header,feedback
        RESULT=$?
        
        if [ $RESULT -eq 0 ]; then
            echo "CONNECTION SUCCESSFUL: Database connection test passed" >> $FORMAT_LOG
            grep -i "connected to" ${filename%.csv}.log >> $FORMAT_LOG
        else
            echo "CONNECTION FAILED: Database connection test failed (Error code: $RESULT)" >> $FORMAT_LOG
            grep -i "ora-" ${filename%.csv}.log >> $FORMAT_LOG 2>/dev/null
        fi
        
        echo "" >> $FORMAT_LOG
        echo "----------------------------------------" >> $FORMAT_LOG
        echo "" >> $FORMAT_LOG
        
        # Cleanup temporary files
        rm -f ${filename%.csv}.ctl ${filename%.csv}.log
    }
    
    # Validate each CSV format
    validate_csv "standard.csv"
    validate_csv "tabbed.csv"
    validate_csv "semicolon.csv"
    
    echo "CSV format validation results saved to $FORMAT_LOG"
}

# Example 5: SQL*Loader version check
check_sqlldr_version() {
    echo "Checking SQL*Loader version..."
    
    # Create log file
    VERSION_LOG="sqlldr_version_log.txt"
    echo "--------------- SQL*LOADER VERSION CHECK ---------------" > $VERSION_LOG
    echo "Timestamp: $(date)" >> $VERSION_LOG
    echo "" >> $VERSION_LOG
    
    # Run SQL*Loader with help option to get version
    sqlldr help=y | grep -i "Release" > tmp_version.txt
    
    if [ $? -eq 0 ]; then
        echo "SQL*Loader client is available:" | tee -a $VERSION_LOG
        cat tmp_version.txt | tee -a $VERSION_LOG
    else
        echo "Failed to get SQL*Loader version information" | tee -a $VERSION_LOG
    fi
    
    echo "" >> $VERSION_LOG
    echo "SQL*Loader version check complete" >> $VERSION_LOG
    
    # Clean up
    rm -f tmp_version.txt
}

# Main script - uncomment the test you want to run
# test_basic_connection
# test_complex_csv
# test_multiple_connections
# test_csv_format
# check_sqlldr_version

# To run all tests:
test_basic_connection
test_complex_csv
test_multiple_connections
test_csv_format
check_sqlldr_version

echo "All SQL*Loader tests completed with CSV parsing validation."
