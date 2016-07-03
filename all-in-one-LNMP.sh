#!/bin/bash


# commmon functions
check() {
if [ $? != 0 ]
then
    echo "This a error, shell script exits now"
    exit 1
fi
} 

