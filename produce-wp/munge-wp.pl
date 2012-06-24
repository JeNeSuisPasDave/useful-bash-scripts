use strict;
use warnings;

# Cleans up tidy-ed HTML to make it more compatible with
# WordPress. Also strips out HTML document wrapper elements
# if "-pb" option is used, so that output can be placed in the
# clipboard (pasteboard) for pasting into a WordPress edit field.
#

# Check and capture arguments
#
# Valid args:
#   -pb       Include on the inner HTML of the <body>; suitable for
#             inserting into the clipboard/pasteboard for later pasting
#             into WordPress.
#
#   -fn AA    Include the supplied two character code (e.g. 'AA')
#             in footnote references. Helpful to distinguish footnotes
#             where multiple WordPress posts shown on same page.
#
my $prevLine = undef;
my $lineNumber = 0;
my $argCount = (scalar @ARGV);
my $pbCopy = undef;
my $fnHex = undef;
foreach my $arg ( @ARGV ) {
	if ("-pb" eq $arg) {
		$pbCopy = 1;
		next;
	}
	if ("-fn" eq $arg) {
		$fnHex = $arg;
		next;
	}
	if ((defined $fnHex) && ("-fn" eq $fnHex)) {
		$fnHex = $arg;
		next;
	}
	print STDERR "Bad argument '$arg'.\n";
	exit 4;
}
if ((defined $fnHex) && ("-fn" eq $fnHex)) {
	print STDERR "Bad argument '$fnHex'.\n";
	exit 2;
}

if ($pbCopy) {
  # Remove lines up through <body>
  #
	while(my $line = <STDIN>) {
		$lineNumber += 1;
		if ($line =~ m|<body>\n|) {
			last;
		}
	}
}

# Remove newlines preceding </code> so that WordPress doesn't
# insert an extra line in the displayed code block
#
while(my $line = <STDIN>) {
	$lineNumber += 1; # capture the input line number

	# Skip the preamble if requested
	#
	if ($pbCopy) {
		# Only read up until </body>
		#
		if ($line =~ m|</body>\n|) {
			last;
		}
	}

	# set the footnote references, if requested
	#
	if (defined $fnHex) {
		$line =~ s|href=\"#fn:|href=\"#fn:$fnHex:|g;
		$line =~ s|href=\"#fnref:|href=\"#fnref:$fnHex:|g;
		$line =~ s|id=\"fn:|id=\"fn:$fnHex:|g;
		$line =~ s|id=\"fnref:|id=\"fnref:$fnHex:|g;
	}

	# just buffer the first line
	#
	if (! defined $prevLine) {
	  $prevLine = $line;
	  next;
  }

  # remove the newline preceding </code>, if any
  #
	my $bothLines = $prevLine . $line;
	my $newLines = $bothLines;
	$newLines =~ s|\n</code>|</code>|;
	if ($newLines eq $bothLines) {
		# no newline, so just output the previous line and buffer the
		# current line
		#
		print STDOUT $prevLine;
		$prevLine = $line;
	} else {
		$prevLine = $newLines;
	}
}

# make sure the last line is output, stripping trailing newlines
#
if (defined $prevLine) {
  chomp $prevLine;
	print STDOUT $prevLine;
}