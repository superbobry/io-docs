#!/usr/bin/env io

DocFormatter

if(isLaunchScript,
    DocExtractor with("../io/libs/iovm") run
    "\n" print # Silly :(
    JSONDocFormatter with("reference/") run
)