# MarkdownPreProcessor

A small easy to use pre-processor written to automate some markdown for report writing


All the pre-processing is done within comments for compatibility, mdpp will then convert this into generic markdown.
This is designed to be used with other tools such as pandoc. The main goal is to fill in the gaps within these tools. 

For example, pandoc allows you to generate a table of contents and footnotes etc. However, there seemed to be a lack of easy ways to include files particularly csv files.


## Usage

Print the generated markdown to the cli
```bash
mdpp input.md
```

Write the genreated mark to a new file
```bash
mdpp output.md --output out.md
```

## Features

* import csv files and convert them to markdown tables
* import and process other markdown files
* import the file contents from almost any other files


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
<!-- #import "text_file.txt" -->


## importing markdown

the following comment will be replaced with the contents of the spcified file. However,
this allows for the contents od the file to be pre-processed first

<!-- #markdown "markdownpp_file.md" -->

