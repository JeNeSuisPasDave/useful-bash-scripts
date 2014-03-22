# Useful BASH Scripts

## Table of Contents

* <a href="#introduction">Introduction</a>
* <a href="#backup-pinboard">backup-pinboard</a>
* <a href="#detect-mitm">detect-mitm</a>
* <a href="#githelpers">githelpers</a>
* <a href="#produce-wp">produce-wp</a>
* <a href="#documenthistory">Document History</a>

## Introduction

This Git repository contains bash scripts that I found useful on my OS X system.

Each sub-directory contains one or more scripts and supporting files focus on a certain task or set of related tasks.

<p class="toclink">^<a href="#tableofcontents" title="Back to Table of Contents">TOC</a>
</p>

## backup-pinboard

This script makes a copy of my [Pinboard](http://pinboard.in) bookmarks. It is intended to scheduled daily or weekly, and maintains a rolling list of backups.

There is an installer that inserts the Pinboard username and password, and sets file permissions to make sure that only your account can read the file.

<p class="toclink">^<a href="#tableofcontents" title="Back to Table of Contents">TOC</a>
</p>

## detect-mitm

A script to detect whether there is an https proxy between your system and a variety of well-known web sites. Useful if you are at work, a hotel, a public wifi hotspot, or any other location where your connection to the internet might be intercepted and monitored.

See Steve Gibson's [excellent information page](https://www.grc.com/fingerprints.htm) on this issue and the techniques to detect https MITM (man in the middle) attacks.

__Note__: this script requires __openssl__.

<p class="toclink">^<a href="#tableofcontents" title="Back to Table of Contents">TOC</a>
</p>

## githelpers

This is a collection of scripts used to help interact with git and manage repositories.

### fetchall.sh

**Note:** If you prefer doing your archival with mirror repositories, see the `updateall.sh` script.

This script is used to maintain local clones of GitHub repositories. The idea is that you have a directory of all the GitHub repositories that you are interested in tracking or keeping around for reference, or in case GitHub implodes, or for whatever reason. The repositories in this directory are not ones you are actively developing; rather you might consider them readonly copies of the GitHub repositories.

All the directories should have been created with a normal clone command:

~~~bash
$ git clone https://github.com/JeNeSuisPasDave/MarkdownTools
~~~

The repositories must be normal repositories, not bare or mirror repositories.

The script should be copied to the parent directory (the one containing all the cloned repositories) and is executed from the command line with that parent directory as the working directory. It will enter each subdirectory (i.e., each repository) and do a `git fetch --all`, a `git prune origin`, and a `git pull --ff-only`. This will keep the remote branches up to date as well as the default local branch.

### updateall.sh

**Note:** If you prefer doing your archival with normal repositories, see the `fetchall.sh` script.

This script is used to maintain local clones of GitHub repositories. The idea is that you have a directory of all the GitHub repository that you are interested in tracking or keeping around for reference, or in case GitHub implodes, or for whatever reason. The repositories in this directory are not ones you are actively developing; rather you might consider them readonly copies of the GitHub repositories.

All the directories were created as mirrors, with the command:

~~~bash
$ git clone https://github.com/JeNeSuisPasDave/MarkdownTools
~~~

All the repositories must be bare, mirror repositories.

The script should be copied to the parent directory (the one containing all the cloned repositories) and is executed from the command line with that parent directory as the working directory. It will enter each subdirectory (i.e., each repository) and do a `git remote update --prune`. This will keep each repository update to date with the remote repository.

## produce-wp

This script, `produce-wp.sh`, takes [Markdown][] or [MultiMarkdown][] files and produces HTML suitable for pasting into WordPress posts and pages. It requires a little assist from a Perl script, `munge-wp.pl`, to cleanup some of the formatting and internal references.

[Markdown]: http://daringfireball.net/projects/markdown/
[MultiMarkdown]: https://github.com/fletcher/peg-multimarkdown/blob/master/README.markdown

This script makes the HTML output WordPress friendly by removing extraneous line breaks within and between paragraphs, removing extraneous line breaks at the end of code blocks, and by making a valiant attempt to produce unique footnote references.

The two scripts can be copied anywhere, as long as both are in the same directory. They expect the Markdown to be files that have the extension `.md` or `.mmd`.

Suppose you put the scripts in a directory called `WP-Content` and had a subdirectory called `2012-Posts`; suppose there is a file `bestpostever.mmd` in `2012-Posts`. If the current directory was `WP-Content/2012-Posts` then this command command would produce an HTML document called `bestpostever.html`:

	../produce-wp.sh bestpostever

Notice that the file extension is not provided.

The HTML file that is produced would have to be edited and the HTML inside the `<body>` would need to be copied to the clipboard and then pasted into the WordPress editor (in HTML mode).

You can shortcut that last step by using this command:

	../produce-wp.sh -pb bestpostever

which does not produce any output file; instead, the inner HTML of the `<body>` element is stored in the clipboard (pasteboard) so you can just paste it immediately into WordPress.

### Dependencies

The scripts use:

* MultiMarkdown
* Perl 5
* HTML Tidy for HTML5 (I used https://github.com/w3c/tidy-html5/tree/8025154)
* sed
* grep
* pbcopy

<p class="toclink">^<a href="#tableofcontents" title="Back to Table of Contents">TOC</a>
</p>

## Document History

* 2012.05.13 - Created

	Initially just has the backup-pinboard scripts.

* 2012.06.24 - Added produce-wp scripts.

* 2014.03.22 -- Added githelpers script collection. Initially includes `fetchall.sh` and `updateall.sh`
	
<p class="toclink">^<a href="#tableofcontents" title="Back to Table of Contents">TOC</a>
</p>
