# mdpp

<!-- This comment will be untouched -->

## csv files

the following comment will be replaced with a markdown table containing the
csv file. Functions can be called on the csv file such as `.columns()` which
will show only the spcified columns in the table. The function `.rows()` limits
the markdown table to only the spcified number of rows *this excludes the header row*

<!-- 
    #csv "file.csv"
        .columns("Index", "First Name", "Last Name")
        .rows(5)
-->

This can also be done on one line

<!-- #csv "file.csv".rows(5).columns("Index", "First Name", "Last Name") -->


## importing files

the following comment will be replaced with the raw contents of the spcified file

<!-- #import "file.md" -->


## importing markdown

the following comment will be replaced with the contents of the spcified file. However,
this allows for the contents od the file to be pre-processed first

<!-- #markdown "markdownpp_file.md" -->
