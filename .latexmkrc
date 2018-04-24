#!/usr/bin/env perl
$latex = 'platex -synctex=1 -halt-on-error';
$latex_silent = 'platex -synctex=1 -halt-on-error -interaction=batchmode';
$bibtex = 'pbibtex';
#$latex = 'uplatex -synctex=1 -halt-on-error';
#$latex_silent = 'uplatex -synctex=1 -halt-on-error -interaction=batchmode';
#$bibtex = 'upbibtex';
$biber = 'biber --bblencoding=utf8 -u -U --output_safechars';
$dvipdf = 'dvipdfmx %O -o %D %S';
$makeindex = 'mendex -s myindex.ist %O -o %D %S';
$max_repeat = 5;
$pdf_mode = 3;

$pdf_update_command = "open -ga Preview %S";

