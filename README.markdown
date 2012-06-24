# Useful BASH Scripts

## Table of Contents

* <a href="#introduction">Introduction</a>
* <a href="#backup-pinboard">backup-pinboard</a>
* <a href="#produce-wp">produce-wp</a>
* <a href="#document-history">Document History</a>

## Introduction

This Git repository contains bash scripts that I found useful on my OS X system.

Each sub-directory contains one or more scripts and supporting files focus on a
certain task or set of related tasks.

<p class="toclink">^<a href="#table-of-contents" title="Back to Table of Contents">TOC</a>
</p>

## backup-pinboard

This script makes a copy of my [Pinboard](http://pinboard.in) bookmarks. It is
intended to scheduled daily or weekly, and maintains a rolling list of older
backups.

There is an installer that inserts the Pinboard username and password, and sets
file permissions to make sure that only your account can read the file.

<p class="toclink">^<a href="#table-of-contents" title="Back to Table of Contents">TOC</a>
</p>

## produce-wp

This script, `produce-wp.sh`, takes [Markdown][] or [MultiMarkdown][] files and
produces HTML suitable for pasting into WordPress posts and pages. It requires a
little assist from a Perl script, `munge-wp.pl`, to cleanup some of the
formatting and internal references.

[Markdown]: http://daringfireball.net/projects/markdown/
[MultiMarkdown]: https://github.com/fletcher/peg-multimarkdown/blob/master/README.markdown

This script makes the HTML output WordPress friendly by removing extraneous
line breaks within and between paragraphs, removing extraneous line breaks
at the end of code blocks, and by making a valiant attempt to produce unique
footnote references.

The two scripts can be copied anywhere, as long as both are in the same
directory. They expect the Markdown to be files that have the extension `.md` or
`.mmd`.

Suppose you put the scripts in a directory called `WP-Content` and had a
subdirectory called `2012-Posts`; suppose there is a file `bestpostever.mmd` in
`2012-Posts`. If the current directory was `WP-Content/2012-Posts` then this
command command would produce an HTML document called `bestpostever.html`:

	../produce-wp.sh bestpostever

Notice that the file extension is not provided.

The HTML file that is produced would have to be edited and the HTML inside the
<body> would need to be copied to the clipboard and then pasted into the
WordPress editor (in HTML mode).

You can shortcut that last step by using this command:

	../produce-wp.sh -pb bestpostever

which does not produce any output file; instead, the inner HTML of the <body>
element is stored in the clipboard (pasteboard) so you can just paste it
immediately into WordPress.

### Dependencies

The scripts use:

* Perl 5
* HTML Tidy for HTML5 (I used https://github.com/w3c/tidy-html5/tree/8025154)
* sed
* grep
* pbcopy

<p class="toclink">^<a href="#table-of-contents" title="Back to Table of Contents">TOC</a>
</p>

## Document History

* 2012.05.13 - Created

	Initially just has the backup-pinboard scripts.

* 2012.06.24 - Added produce-wp scripts.
	
<p class="toclink">^<a href="#table-of-contents" title="Back to Table of Contents">TOC</a>
</p>
