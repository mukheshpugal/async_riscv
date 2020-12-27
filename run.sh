#!/bin/sh
#
# Compile and run the test bench

[ -x "$(command -v iverilog)" ] || { echo "Install iverilog"; exit 1; }

# Clear out existing log file
rm -f cpu_tb.log 

file='tb_files.txt'

while read line; do
    #Reading each line.
    echo "\nUsing program : $line"
    echo "Compiling sources"

    iverilog -DTESTDIR=\"test/t$line\" -o cpu_tb -c program_file.txt
    if [ $? != 0 ]; then
        echo "*** Compilation error! Please fix."
        exit 1;
    fi
    ./cpu_tb 
done < $file

retval=$(grep -c FAIL cpu_tb.log)
if [ $retval -eq 0 ];
then
    echo "Passed"
else
    echo "Failed $retval cases"
fi

cat << EOF

You should see a PASS message and all tests pass.
If any test reports as a FAIL, fix it before submitting.
Once all tests pass, commit the changes into your code,
and push the commit back to the server for evaluation.
EOF

return $retval 
