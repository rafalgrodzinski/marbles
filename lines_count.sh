#!/bin/bash

find ./Marbles/ -name "*.swift" -print0 | xargs -0 wc -l
