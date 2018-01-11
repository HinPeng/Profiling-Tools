for file in ${1}*.txt
do
    python sum.py $file
done
