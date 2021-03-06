# Useful BASH Scripts

## Table of Contents

* [Introduction](#introduction)
* [backup-pinboard](#backup-pinboard)
* [detect-mitm](#detect-mitm)
* [dos2unix](#dos2unix)
* [githelpers](#githelpers)
* [produce-wp](#produce-wp)
* [URL Helpers](#url-helpers)
* [Document History](#document-history)

## Introduction

This Git repository contains bash scripts that I found useful on my OS X system.

Each sub-directory contains one or more scripts and supporting files focus on a certain task or set of related tasks.

## backup-pinboard

This script makes a copy of my [Pinboard](http://pinboard.in) bookmarks. It is intended to scheduled daily or weekly, and maintains a rolling list of backups.

There is an installer that inserts the Pinboard username and password, and sets file permissions to make sure that only your account can read the file.

### Dependencies

The script uses:

* curl

## detect-mitm

A script to detect whether there is an https proxy between your system and a variety of well-known web sites. Useful if you are at work, a hotel, a public wifi hotspot, or any other location where your connection to the internet might be intercepted and monitored.

See Steve Gibson's [excellent information page](https://www.grc.com/fingerprints.htm) on this issue and the techniques to detect https MITM (man in the middle) attacks.

### Dependencies

The script uses:

* openssl
* cut

## dos2unix

`dos2unix` and `unix2dos` are scripts that will convert the line endings in a text file from CRLF form to LF form or vice versa. Another way of saying that is they switch line endings between `\r\n` and `\n`.

* **`dos2unix`** converts CRLF line endings to just LF.
* **`unix2dos`** converts LF endings to CRLF.

To install it, copy both scripts to a directory in your path (typically ~/bin).

You can operate on a entire directory (and all its subdirectories) of text files with this command:

~~~bash
$ find . -type f -exec dos2unix {} +
~~~

Of course, that command assumes that every file it finds is a text file and should be converted. So if you have data files or binary files that shouldn't be touched, you'll have to use a more selected command or mechanism.

### Dependencies

The scripts use:

* perl

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

### Dependencies

The scripts use:

* Git
* find
* grep

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

## URL helpers

### longurl.sh

This script is URL lengthener. It takes a URL and follows all the redirects to discover the ultimate URL. For example, `http://bit.ly/pdp8kit` resolves to `http://obsolescence.wix.com/obsolescence#!pidp-8-get-one/ctny`.

The script does this by using `curl` to make HEAD requests to the server and asking `curl` to automatically follow redirects.

As long as no error status codes were encountered, the last `Location:` header encountered will be the resolved URL that is returned. If no redirection occurs, then the URL supplied on the command line will be the one that gets returned.

You can see the headers received by `curl` if you use the `--headers` option in the script command line.

### longurl.src

This is essentially the same as `longurl.sh` except encapsulated as a bash function `longurl()` that could be added to your bash profile.

### Dependencies

Requires `curl`.

## Document History

* 2012.05.13 - Created

	Initially just has the backup-pinboard scripts.

* 2012.06.24 - Added produce-wp scripts.

* 2014.03.22 -- Added githelpers script collection. Initially includes `fetchall.sh` and `updateall.sh`

* 2014.03.21 -- Added dos2unix collection. Include `dos2unix` and `unix2dos` scripts.
	