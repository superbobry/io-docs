#!/usr/bin/env io

# Docstring extractor for Io language (http://iolanguage.com), made as a replacement
# for the default DocExtractor & co, which are (in author's opinion) very nice examples
# of hardcore spagetti-code, done the Io-way.
#
# TODO:
#   * abstract base DocFormatter and HTMLDocFormatter objects
#   * make metacache a category - meta list mapping
#   * add filename and line numbers for each method, f.ex.:
#     `reduce(accumulator, element, start)          [A3_List.io:70]`
#   * add cleanup method to DocFormatter
#   * add option for generating relative paths instead of absolute ones
#   * make js-search work with the new internals

DocFormatter

if(isLaunchScript,
    DocExtractor with("../io/libs/iovm") run
    "\n" print # Silly :(
    JSONDocFormatter with("reference/") run
)