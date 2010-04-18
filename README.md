io-docs
=======

Docstring extractor for [Io](http://iolanguage.com) source code, made as a replacement
for the default DocExtractor & co, which are (*in author's opinion*) very nice 
examples of hardcore spagetti-code, done the Io-way.

The extractor consist of several objects you need to to know about, to be able
to modify the internals the way you need (however, this knowledge is not required 
to actually use the tool :]):

### `Meta` ###
Metadata container object, all documentation system statements are parsed and aggregated 
in this object. The name of the metadata origin is stored in the `Meta object` slot; the 
rest of the meta tags are accessible in the same way (*see example*). By default, all of 
the availible tags are initialized with an empty string (`""`), except for `Meta category`, 
which defaults for `Uncategorized`. 

Example:

    Io> meta := Meta with("UnitTest description Yet, another test framework.")
    ==> Meta for `UnitTest`
    Io> meta object
    ==> UnitTest
    Io> meta description
    ==> Yet, another test framework.
    Io> meta license
    ==>
    Io> meta category
    ==> Uncategorized


### `MetaCache` ###
The name of this object is pretty self explanatory. `MetaCache` is a container for `Meta`
objects, providing to ways of accessing them:

__by object name__
    
    Io> MetaCache["UnitTest"]
    ==> Meta for `UnitTest`

    Io> MetaCache["SomeObject"]    
    ==> Meta for `SomeObject`
    
*Note*: if the `Meta` with a given name isn't contained in the `MetaCache` it will be 
created and put into the cache.

__by category__

    Io> MetaCache{"Testing"}
    ==> list(Meta for `UnitTest`)
    
    Io> MetaCache{"SomeCategory"}
    ==> list(Meta for `SomeObject`, Meta for `SomeOtherObject`, ...)


### `DocExtractor` ###
Given a `path`, this object recursively walks all the underlying subdirectories, extracting 
metadata from Io source files (`*.c`, `*.h`, `*.io`) and putting it into the `MetaCache` 
object, described above. The object can do the extraction in two modes: if you want the
overall progress to be displayed, during the extraction use `DocExtractor run` method, else
use `DocExtractor runQuiet`, which will do the job without a single line printed :]. 

Example:

    Io> DocExtractor with("./io/libs/iovm/") run
    Extracting docs starting from `../io/libs/iovm`:
    ................................................................................
    .....................
    --------------------------------------------------------------------------------
    Processed 101 files, 40 objects, 983 slots in 1.161008s

### `DocFormatter` ###
This object works with data contained inside the `MetaCache`, renders it and dumps the result
to the `DocFormatter path` directory. By default, two formatters are availible, `HTMLDocFormatter`
and `JSONDocFormatter`, both support the same running scheme as `DocExtractor` (i.e. `run` and
`runQuiet`).

Example:
  
    Io> JSONDocFormatter with("reference/") run
    Generating documentation files in `reference/` using JSONDocFormatter:
    .
    --------------------------------------------------------------------------------

*Note*: the path passed to `DocFormatter with` method __should__ have a trailing slash, due
to a bug in the `Directory` object. The same is true for `DocExtractor with`.

TODO
--------
The project is still very experimental and even though most of the functionality is covered
with unittests, there's lots of bugs around, so don't expect much, really. Here's a list of
stuff that needs to be implemented:

  * module support for `Meta` object
  * clean-up method for `DocFormatter`
  * filename and line numbers for each method, f.ex.:
    `reduce(accumulator, element, start)          [A3_List.io:70]`
  * an option for generating relative paths instead of absolute ones
  * make js-search work with the new internals
