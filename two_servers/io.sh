#!/bin/sh
if [ $# != 1 ]; then
    echo -e 'io parameter number wrong!\n'
    exit 1
fi

prefix=$1

iostat -x -d sda 1 >> ${prefix}_io.txt
