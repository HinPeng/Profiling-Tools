mode=$1
if [ -z $mode ]
then
    dir1="log/"
    dir2="prof_data/"

else
    dir1="log_${mode}/"
    dir2="prof_data_${mode}/"

fi

rm -f $dir1*
rm -f $dir2*
