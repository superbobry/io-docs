#!/usr/bin/env io

DocFormatter

if(isLaunchScript,
    DocExtractor with("../io/libs/iovm/io") run
    "\n" print # Silly :(
    DocFormatter as("json") with("reference/") run
)