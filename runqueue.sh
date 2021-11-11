#!/bin/bash

for i in $(exim -bp | awk '{print $3}'); do exim -M $i; done
