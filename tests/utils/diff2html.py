#!/usr/bin/python2

# diff2html
#
# Copyright (C) 2001 Yves Bailly <diff2html@tuxfamily.org>
#           (C) 2001 MandrakeSoft S.A.
#
# This script is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Library General Public License for more details.
#
# You should have received a copy of the GNU Library General Public
# License along with this library; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA, or look at the website
# http://www.gnu.org/copyleft/gpl.html

import sys, os, string, re, time, stat

default_css = \
"""
TABLE { border-collapse: collapse; border-spacing: 0px; }
TD.linenum { color: #909090;
             text-align: right;
             vertical-align: top;
             font-weight: bold;
             border-right: 1px solid black; }
TD.added { background-color: #BBFFBB;
             border-right: 1px solid black; }
TD.mismatch { color:#ff4444; }
TD.modified { background-color: #FFDDAA;
             border-right: 1px solid black; }
TD.removed { background-color: #FFCCCC;
             border-right: 1px solid black; }
TD.normal { background-color: #FFFFE1;
             border-right: 1px solid black; }
"""

def print_usage() :
    print """
diff2html - Formats diff(1) output to an HTML page on stdout
http://diff2html.tuxfamily.org

Usage: diff2html [--help] [--only-changes] [--style-sheet file.css]
                 [diff options] file1 file2

--help                  This message
--only-changes          Do not display lines that have not changed
--style-sheet file.css  Use an alternate style sheet, linked to the given file
diff options            All other options are passed to diff(1)

Example:
# Basic use
diff2html file1.txt file2.txt > differences.html
# Treat all files as text and compare  them  line-by-line, even if they do
# not seem to be text.
diff2html -a file1 file2 > differences.html
# The same, but use the alternate style sheet contained in diff_style.css
diff2html --style-sheet diff_style.css -a file1 file2 > differences.html

The default, hard-coded style sheet is the following:%s
Note 1: if you give invalid additionnal options to diff(1), diff2html will
        silently ignore this, but the resulting HTML page will be incorrect;
Note 2: for now, diff2html can't be used with standard input, so the diff(1)
        '-' option can't be used.

diff2html is released under the GNU GPL.
Feel free to submit bugs or ideas to <diff2html@tuxfamily.org>.
""" % default_css

def str2html(s) :
    s1 = string.replace(string.rstrip(s), "&", "&amp;")
    if ( len(s1) == 0 ) : return ( s1 ) ;
    s1 = string.replace(s1, "<", "&lt;")
    s1 = string.replace(s1, ">", "&gt;")
    i = 0
    s2 = ""
    while ( s1[i] == " " ) :
        s2 += "&nbsp;"
        i += 1
    s2 += s1[i:]
    return ( s2 )

if ( __name__ == "__main__" ) :

    # Processes command-line options
    cmd_line = string.join(sys.argv)

    # First, look for "--help"
    if ( len(sys.argv) < 3 ) :
        print_usage()
        sys.exit(1)
    for ind_opt in range(len(sys.argv)) :
        if ( sys.argv[ind_opt] == "--help" ) :
            print_usage()
            sys.exit(0)

    external_css = ""
    ind_css = -1
    ind_chg = -1
    only_changes = 0
    argv = tuple(sys.argv)
    for ind_opt in range(len(argv)) :
        if ( argv[ind_opt] == "--style-sheet" ) :
            ind_css = ind_opt
            external_css = argv[ind_css+1]
        if ( argv[ind_opt] == "--only-changes" ) :
            ind_chg = ind_opt
            only_changes = 1

    argv = list(argv)
    if ( ind_css >= 0 ) :
        del argv[ind_css:ind_css+2]
    if ( ind_chg >= 0 ) :
        del argv[ind_chg:ind_chg+1]

    # Check if both files exists
    file1 = argv[-2]
    file2 = argv[-1]
    if not os.access(file1, os.F_OK) :
        print "File %s does not exist or is not readable, aborting." % file1
        sys.exit(1)
    if not os.access(file2, os.F_OK) :
        print "File %s does not exist or is not readable, aborting." % file2
        sys.exit(1)

    # Invokes "diff"
    diff_stdout = os.popen("diff %s" % string.join(argv[1:]), "r")
    diff_output = diff_stdout.readlines()
    diff_stdout.close()
    # Maps to store the reported differences
    changed = {}
    deleted = {}
    added = {}
    # Magic regular expression
    diff_re = re.compile(
        r"^(?P<f1_start>\d+)(,(?P<f1_end>\d+))?"+ \
         "(?P<diff>[acd])"+ \
         "(?P<f2_start>\d+)(,(?P<f2_end>\d+))?")
    # Now parse the output from "diff"
    for diff_line in diff_output:
        diffs = diff_re.match(string.strip(diff_line))
        # If the line doesn't match, it's useless for us
        if not ( diffs  == None ) :
            # Retrieving informations about the differences :
            # starting and ending lines (may be the same)
            f1_start = int(diffs.group("f1_start"))
            if ( diffs.group("f1_end") == None ) :
                f1_end = f1_start
            else :
                f1_end = int(diffs.group("f1_end"))
            f2_start = int(diffs.group("f2_start"))
            if ( diffs.group("f2_end") == None ) :
                f2_end = f2_start
            else :
                f2_end = int(diffs.group("f2_end"))
            f1_nb = (f1_end - f1_start) + 1
            f2_nb = (f2_end - f2_start) + 1
            # Is it a changed (modified) line ?
            if ( diffs.group("diff") == "c" ) :
                # We have to handle the way "diff" reports lines merged
                # or splitted
                if ( f2_nb < f1_nb ) :
                    # Lines merged : missing lines are marqued "deleted"
                    for lf1 in range(f1_start, f1_start+f2_nb) :
                        changed[lf1] = 0
                    for lf1 in range(f1_start+f2_nb, f1_end+1) :
                        deleted[lf1] = 0
                elif ( f1_nb < f2_nb ) :
                    # Lines splitted : extra lines are marqued "added"
                    for lf1 in range(f1_start, f1_end+1) :
                        changed[lf1] = 0
                    for lf2 in range(f2_start+f1_nb, f2_end+1) :
                        added[lf2] = 0
                else :
                    # Lines simply modified !
                    for lf1 in range(f1_start, f1_end+1) :
                        changed[lf1] = 0
            # Is it an added line ?
            elif ( diffs.group("diff") == "a" ) :
                for lf2 in range(f2_start, f2_end+1):
                    added[lf2] = 0
            else :
            # OK, so it's a deleted line
                for lf1 in range(f1_start, f1_end+1) :
                    deleted[lf1] = 0

    # Storing the two compared files, to produce the HTML output
    f1 = open(file1, "r")
    f1_lines = f1.readlines()
    f1.close()
    f2 = open(file2, "r")
    f2_lines = f2.readlines()
    f2.close()

    # Finding some infos about the files
    f1_stat = os.stat(file1)
    f2_stat = os.stat(file2)

    # Printing the HTML header, and various known informations

    # Preparing the links to changes
    if ( len(changed) == 0 ) :
        changed_lnks = "None"
    else :
        changed_lnks = ""
        keys = changed.keys()
        keys.sort()
        for key in keys :
            changed_lnks += "<a href=\"#F1_%d\">%d</a>, " % (key, key)
        changed_lnks = changed_lnks[:-2]

    if ( len(added) == 0 ) :
        added_lnks = "None"
    else :
        added_lnks = ""
        keys = added.keys()
        keys.sort()
        for key in keys :
            added_lnks += "<a href=\"#F2_%d\">%d</a>, " % (key, key)
        added_lnks = added_lnks[:-2]

    if ( len(deleted) == 0 ) :
        deleted_lnks = "None"
    else :
        deleted_lnks = ""
        keys = deleted.keys()
        keys.sort()
        for key in keys :
            deleted_lnks += "<a href=\"#F1_%d\">%d</a>, " % (key, key)
        deleted_lnks = deleted_lnks[:-2]

    print """
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"
 "http://www.w3.org/TR/REC-html40/loose.dtd">
<html>
<head>
    <title>Differences between %s and %s</title>""" % (file1, file2)
    if ( external_css == "" ) :
        print "    <style>%s</style>" % default_css
    else :
        print "    <link rel=\"stylesheet\" href=\"%s\" type=\"text/css\">" % \
        external_css

    print """
</head>
<body>
<table>
<tr><td width="50%%">
<table>
    <tr>
        <td class="modified">Modified lines:&nbsp;</td>
        <td class="modified">%s</td>
    </tr>
    <tr>
        <td class="added">Added line:&nbsp;</td>
        <td class="added">%s</td>
    </tr>
    <tr>
        <td class="removed">Removed line:&nbsp;</td>
        <td class="removed">%s</td>
    </tr>
</table>
</td>
<td width="50%%">
<i>Generated by <a href="http://diff2html.tuxfamily.org"><b>diff2html</b></a><br/>
&copy; Yves Bailly, MandrakeSoft S.A. 2001<br/>
<b>diff2html</b> is licensed under the <a
href="http://www.gnu.org/copyleft/gpl.html">GNU GPL</a>.</i>
</td></tr>
</table>
<hr/>
<table>
    <tr>
        <th>&nbsp;</th>
        <th width="45%%"><strong><big>%s</big></strong></th>
        <th>&nbsp;</th>
        <th>&nbsp;</th>
        <th>&nbsp;</th>
        <th width="45%%"><strong><big>%s</big></strong></th>
    </tr>
    <tr>
        <td width="16">&nbsp;</td>
        <td>
        %d lines<br/>
        %d bytes<br/>
        Last modified : %s<br/>
        <hr/>
        </td>
        <td width="16">&nbsp;</td>
        <td width="16">&nbsp;</td>
        <td width="16">&nbsp;</td>
        <td>
        %d lines<br/>
        %d bytes<br/>
        Last modified : %s<br/>
        <hr/>
        </td>
    </tr>
""" % (changed_lnks, added_lnks, deleted_lnks,
       file1, file2,
       len(f1_lines), f1_stat[stat.ST_SIZE],
       time.asctime(time.gmtime(f1_stat[stat.ST_MTIME])),
       len(f2_lines), f2_stat[stat.ST_SIZE],
       time.asctime(time.gmtime(f2_stat[stat.ST_MTIME])))

    # Running through the differences...
    nl1 = nl2 = 0
    while not ( (nl1 >= len(f1_lines)) and (nl2 >= len(f2_lines)) ) :
        if ( added.has_key(nl2+1) ) :
            f2_lines[nl2]
      # This is an added line
            print """
    <tr>
        <td class="linenum">&nbsp;</td>
        <td class="added">&nbsp;</td>
        <td width="16">&nbsp;</td>
        <td class="mismatch">&nbsp;</td>
        <td class="linenum"><a name="F2_%d">%d</a></td>
        <td class="added">%s</td>
    </tr>
""" % (nl2+1, nl2+1, str2html(f2_lines[nl2]))
            nl2 += 1
        elif ( deleted.has_key(nl1+1) ) :
      # This is a deleted line
            print """
    <tr>
        <td class="linenum"><a name="F1_%d">%d</a></td>
        <td class="removed">%s</td>
        <td width="16">&nbsp;</td>
        <td class="mismatch">&nbsp;</td>
        <td class="linenum">&nbsp;</td>
        <td class="removed">&nbsp;</td>
    </tr>
""" % (nl1+1, nl1+1, str2html(f1_lines[nl1]))
            nl1 += 1
        elif ( changed.has_key(nl1+1) ) :
      # This is a changed (modified) line
            print """
    <tr>
        <td class="linenum"><a name="F1_%d">%d</a></td>
        <td class="modified">%s</td>
        <td width="16">&nbsp;</td>
        <td class="mismatch">&nbsp;</td>
        <td class="linenum">%d</td>
        <td class="modified">%s</td>
    </tr>
""" % (nl1+1, nl1+1, str2html(f1_lines[nl1]),
       nl2+1, str2html(f2_lines[nl2]))
            nl1 += 1
            nl2 += 1
        else :
      # These lines have nothing special
            if ( not only_changes ) :
                print """
    <tr>
        <td class="linenum">%d</td>
        <td class="normal">%s</td>
        <td width="16">&nbsp;</td>
        <td class="mismatch">&nbsp;</td>
        <td class="linenum">%d</td>
        <td class="normal">%s</td>
    </tr>
""" % (nl1+1, str2html(f1_lines[nl1]),
       nl2+1, str2html(f2_lines[nl2]))
            nl1 += 1
            nl2 += 1

    # And finally, the end of the HTML
    print """
</table>
<hr/>
<i>Generated by <b>diff2html</b> on %s<br/>
Command-line:</i> <tt>%s</tt>

</body>
</html>
""" % (time.asctime(time.gmtime(time.time())), cmd_line)
