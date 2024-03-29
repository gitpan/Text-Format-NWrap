package Text::Format;

=head1 NAME

B<Text::Format> - Various subroutines to manipulate text.

=head1 SYNOPSIS

    use Text::Format;

    $text = Text::Format->new( 
        {
            columns        => 72, # format, paragraphs, center
            tabstop        =>  8, # expand, unexpand, center
            firstIndent    =>  4, # format, paragraphs
            bodyIndent     =>  0, # format, paragraphs
            rightFill      =>  0, # format, paragraphs
            rightAlign     =>  0, # format, paragraphs
            leftMargin     =>  0, # format, paragraphs, center
            rightMargin    =>  0, # format, paragraphs, center
            extraSpace     =>  0, # format, paragraphs
            abbrevs        => {}, # format, paragraphs
            text           => [], # all
            hangingIndent  =>  0, # format, paragraphs
            hangingText    => [], # format, paragraphs
            noBreak        =>  0, # format, paragraphs
            noBreakRegex   => {}, # format, paragraphs
        }
    ); # these are the default values

    %abbr = (foo => 1, bar => 1);
    $text->abbrevs(\%abbr);
    $text->abbrevs();
    $text->abbrevs({foo => 1,bar => 1});
    $text->abbrevs(qw/foo bar/);
    $text->text(\@text);

    $text->columns(132);
    $text->tabstop(4);
    $text->extraSpace(1);
    $text->firstIndent(8);
    $text->bodyIndent(4);
    $text->config({tabstop => 4,firstIndent => 0});
    $text->rightFill(0);
    $text->rightAlign(0);

=head1 DESCRIPTION

The B<format> routine will format under all circumstances even if the
width isn't enough to contain the longest words.  Text::Wrap will die
under these circumstances, although I am told this is fixed.  If columns
is set to a small number and words are longer than that and the leading
'whitespace' than there will be a single word on each line.  This will
let you make a simple word list which could be indented or right
aligned.  There is a chance for croaking if you try to subvert the
module.
B<Text::Format> is meant for more powerful text formatting than
B<Text::Wrap> allows.

General setup should be explained with the below graph.

                           columns
<------------------------------------------------------------>
<----------><------><---------------------------><----------->
 leftMargin  indent  text is formatted into here  rightMargin

indent is firstIndent or bodyIndent depending on where we are in the
paragraph

=over 4

=item B<format> @ARRAY || \@ARRAY || [<FILEHANDLE>] || NOTHING

Allows to do basic formatting of text into a paragraph, with indent for
first line and body set separately.  Can specify width of total text,
right fill with spaces and right align, right margin and left margin.
Strips all leading and trailing whitespace before proceeding.  Text is
first split into words and then reassembled.

=item B<paragraphs> @ARRAY || \@ARRAY || [<FILEHANDLE>] || NOTHING

Considers each element of text as a paragraph and if the indents are the
same for first line and the body then the paragraphs are separated by a
single empty line otherwise they follow one under the other.  If hanging
indent is set then a single empty line will separate each paragraph as
well.  Calls B<format> to do the actual formatting.

=item B<center> @ARRAY || NOTHING

Centers a list of strings in @ARRAY or internal text.  Empty lines
appear as, you guessed it, empty lines.  Center strips all leading and
trailing whitespace before proceeding.  Left margin and right margin can
be set.

=item B<expand> @ARRAY || NOTHING

Expand tabs in the list of text to tabstop number of spaces in @ARRAY or
internal text.  Doesn't modify the internal text just passes back the
modified text.

=item B<unexpand> @ARRAY || NOTHING

Tabstop number of spaces are turned into tabs in @ARRAY or internal
text.  Doesn't modify the internal text just passes back the modified
text.

=item B<new> \%HASH || NOTHING

Instantiates the object.  If you pass a reference to a hash, or an
anonymous hash then it's used in setting attributes.

=item B<config> \%HASH

Allows the configuration of all object attributes at once.  Returns the
object prior to configuration.  You can use it to make a clone of your
object before you change attributes.

=item B<columns> NUMBER || NOTHING

Set width of text or retrieve width.  This is total width and includes
indentation and the right and left margins.

=item B<tabstop> NUMBER || NOTHING

Set tabstop size or retrieve tabstop size, only used by expand and
unexpand and center.

=item B<firstIndent> NUMBER || NOTHING

Set or get indent for the first line of paragraph.

=item B<bodyIndent> NUMBER || NOTHING

Set or get indent for the body of paragraph.

=item B<leftMargin> NUMBER || NOTHING

Set or get width of left margin.

=item B<rightMargin> NUMBER || NOTHING

Set or get width of right margin.

=item B<rightFill> 0 || 1 || NOTHING

Set right fill to true or retrieve its value.

=item B<rightAlign> 0 || 1 || NOTHING

Set right align to true or retrieve its value.

=item B<text> \@ARRAY || NOTHING

Pass in a reference to your text that you want the routines to
manipulate.  Returns the text held in the object.

=item B<hangingIndent> 0 || 1 || NOTHING

Use hanging indents in front of a paragraph, returns current value of
attribute.

=item B<hangingText> \@ARRAY || NOTHING

The text that will be displayed in front of each paragraph, if you call
B<format> than only the first element is used, if you call B<paragraphs>
then B<paragraphs> cycles through all of them.  If you have more
paragraphs than elements in your array than the first one will get
reused.  Pass a reference to your array.

=item B<noBreak> 0 || 1 || NOTHING

Set whether you want to use the non-breaking space feature.

=item B<noBreakRegex> \%HASH || NOTHING

Pass in a reference to your hash that would hold the regexes on which not
to break.  Returns the hash.
eg.

    {'^Mrs?\.$' => '^\S+$','^\S+$' => '^(?:S|J)r\.$'}

don't break names such as 
Mr. Jones, Mrs. Jones
Jones Jr.

The breaking algorithm is simple.  If there should not be a break at the
current end of sentence, then a backtrack is done till there are two
words on which breaking is allowed.  If no two such words are found then
the end of sentence is broken anyhow.  If there is a single word on
current line then no backtrack is done and the word is stuck on the end.

=item B<extraSpace> 0 || 1 || NOTHING

Add extra space after end of sentence, normally B<format> would add 1
space after end of sentence, if this is set to 1 then 2 spaces are used.
Abbreviations are not followed by two spaces.  There are a few internal
abbreviations and you can add your own to the object with B<abbrevs>

=item B<abbrevs> \%HASH || @ARRAY || NOTHING

Add to the current abbreviations, takes a reference to your hash or an
array of abbreviations, if called a second time the original reference
is removed.  Returns the current INTERNAL abbreviations.

=back

=head1 EXAMPLE

    use Text::Format;

    $text = new Text::Format;
    $text->rightFill(1);
    $text->columns(65);
    $text->tabstop(4);
    print $text->format("a line to format to an indented regular
            paragraph using 65 character wide display");
    print $text->paragraphs("paragraph one","paragraph two");
    print $text->center("hello world","nifty line 2");
    print $text->expand("\t\thello world\n","hmm,\twell\n");
    print $text->unexpand("    hello world\n","    hmm");
    $text->config({columns => 132, tabstop => 4});

    $text = Text::Format->new();
    print $text->format(@text);
    print $text->paragraphs(@text);
    print $text->center(@text);
    print $text->format([<FILEHANDLE>]);
    print $text->format([$fh->getlines()]);
    print $text->paragraphs([<FILEHANDLE>]);
    print $text->expand(@text);
    print $text->unexpand(@text);

    $text = Text::Format->new
        ({tabstop => 4,bodyIndent => 4,text => \@text});
    print $text->format();
    print $text->paragraphs();
    print $text->center();
    print $text->expand();
    print $text->unexpand();

    print Text::Format->new({columns => 95})->format(@text);

=head1 BUGS

Line length can exceed columns specified if columns is set to a small
number and long words plus leading whitespace exceed column length
specified.  Actually I see this as a feature since it can be used to
make up a nice word list.

=head1 AUTHOR

Gabor Egressy B<gabor@vmunix.com>

Copyright (c) 1998 Gabor Egressy.  All rights reserved.  All wrongs
reversed.  This program is free software; you can redistribute and/or
modify it under the same terms as Perl itself.

=head1 ACKNOWLEDGMENTS

B<Tom Phoenix>
found bug with code for two spaces at end of sentence and provided code
fragment for a better solution, some preliminary suggestions on design

B<Brad Appleton>
suggesting and explanation of hanging indents, suggestion for
non-breaking whitespace, general suggestions with regard to interface
design

B<Byron Brummer>
suggestion for better interface design and object design, code for
better implementation of getting abbreviations

=head1 TODO

=cut

use Carp;
use strict;
use vars qw($VERSION);

$VERSION = '0.43';

my (%abbrev);

# local abbreviations, you can add your own with add_abbrevs()
%abbrev = (Mr  => 1,
           Mrs => 1,
           Ms  => 1,
           Jr  => 1,
           Sr  => 1,
);

# Formats text into a nice paragraph format.  Can set a variety of
# attributes such as first line indent body indent left and right
# margin, right align, right fill with spaces
sub format(\$@)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;
    my @wrap = @_
        if @_ > 0;

    @wrap = @{$_[0]}
        if ref $_[0] eq 'ARRAY';
    @wrap =  @{$this->{_text}}
        if @wrap < 1;

    my $findent = ' ' x $this->{_findent};
    my $bindent = ' ' x $this->{_bindent};

    my @words = split /\s+/,join ' ',@wrap;
    shift @words
        if $words[0] eq '';

    @wrap = ();
    my ($line,$width,$abbrev);
    $abbrev = 0;
    $width = $this->{_cols} - $this->{_findent}
        - $this->{_lmargin} - $this->{_rmargin};
    $line = shift @words;
    $abbrev = $this->__is_abbrev($line)
        if defined $line;
    local ($^W) = 0; # I need some variables to be undefined on occasion :-)
    while ($_ = shift @words) {
        if(length($_) + length($line) < $width - 1
                || ($line !~ /[.?!]['"]?$/ || $abbrev)
                && length($_) + length($line) < $width) {
            $line .= ' '
                if $line =~ /[.?!]['"]?$/ && ! $abbrev;
            $line .= ' ' . $_;
        }
        else { last; }
        $abbrev = $this->__is_abbrev($_);
    }
    ($line,$_) = $this->__do_break($line,$_)
        if $this->{_nobreak} && defined $line;
    push @wrap,$this->__make_line($line,$findent,$width)
        if defined $line;
    $_ = shift @words
        unless defined $_;
    $line = $_;
    $width = $this->{_cols} - $this->{_bindent}
        - $this->{_lmargin} - $this->{_rmargin};
    $abbrev = 0;
    $abbrev = $this->__is_abbrev($line)
        if defined $line;
    for (@words) {
        if(length($_) + length($line) < $width - 1
                || ($line !~ /[.?!]['"]?$/ || $abbrev)
                && length($_) + length($line) < $width) {
            $line .= ' '
                if $line =~ /[.?!]['"]?$/ && ! $abbrev;
            $line .= ' ' . $_;
        }
        else {
            ($line,$_) = $this->__do_break($line,$_)
                if $this->{_nobreak};
            push @wrap,$this->__make_line($line,$bindent,$width)
                if defined $line;
            $line = $_;
        }
        $abbrev = $this->__is_abbrev($_);
    }
    push @wrap,$this->__make_line($line,$bindent,$width)
        if defined $line;

    if($this->{_hindent} && @wrap > 0) {
        $this->{_hindcurr} = $this->{_hindtext}->[0]
            if length($this->{_hindcurr}) < 1;
        my ($fchar) = $wrap[0] =~ /(\S)/;
        my $white = index $wrap[0],$fchar;
        if($white  - $this->{_lmargin} - 1 > length($this->{_hindcurr})) {
            $white = length($this->{_hindcurr}) + $this->{_lmargin};
            $wrap[0] =~
                s/^ {$white}/' ' x $this->{_lmargin} . $this->{_hindcurr}/e;
        }
        else {
            unshift @wrap,' ' x $this->{_lmargin} . $this->{_hindcurr} . "\n";
        }
    }

    wantarray ? @wrap : join '', @wrap;
}

# format lines in text into paragraphs with each element of @wrap a
# paragraph uses Text::Format->format for the formatting
sub paragraphs(\$@)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;
    my @wrap = @_
        if @_ > 0;

    @wrap = @{$_[0]}
        if ref $_[0] eq 'ARRAY';
    @wrap =  @{$this->{_text}}
        if @wrap < 1;

    my (@ret,$end,$cnt,$line);

    # if indents are same, use newline between paragraphs
    if($this->{_findent} eq $this->{_bindent} ||
            $this->{_hindent}) { $end = "\n"; }
    else { $end = ''; }

    for (@wrap) {
        $this->{_hindcurr} = $this->{_hindtext}->[$cnt]
            if $this->{_hindent};
        $line = $this->format($_);
        push @ret,$line . $end
            if defined $line && length $line > 0;
        ++$cnt;
    }
    chop $ret[$#ret]
        if $ret[$#ret] =~ /\n\n$/;

    wantarray ? @ret : join '',@ret;
}

# center text using spaces on left side to pad it out
# empty lines are preserved
sub center(\$@)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;
    my @center = @_
        if @_ > 0;
    @center =  @{$this->{_text}}
        if @center < 1;
    my $tabs;
    my $width = $this->{_cols} - $this->{_lmargin} - $this->{_rmargin};

    for (@center) {
        s/(?:^\s+|\s+$)|\n//g;
        $tabs = tr/\t//; # count tabs
        substr($_,0,0) =
                ' ' x int(($width - length($_)
                - $tabs * $this->{_tabs} + $tabs) / 2)
            if length > 0;
        substr($_,0,0) = ' ' x $this->{_lmargin}
            if length > 0;
        substr($_,length) = "\n";
    }

    wantarray ? @center : join '',@center;
}

# expand tabs to spaces
# should be similar to Text::Tabs::expand
sub expand(\$@)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;
    my @lines = @_
        if @_ > 0;
    @lines =  @{$this->{_text}}
        if @lines < 1;

    for (@lines) {
        s/\t/' ' x $this->{_tabs}/eg;
    }

    wantarray ? @lines : $lines[0];
}

# turn tabstop number of spaces into tabs
# should be similar to Text::Tabs::unexpand
sub unexpand(\$@)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;
    my @lines = $this->expand(@_);

    for (@lines) {
        s/ {$this->{_tabs}}/\t/g;
    }

    wantarray ? @lines : $lines[0];
}

# return a reference to the object, call as $text = Text::Format->new()
# can be used to clone the current reference $ntext = $text->new()
sub new(\$;$)
{
    my $this = shift;
    my $ref = shift;
    my ($conf,%clone);
    %clone = %{$this}
        if ref $this;

    $conf = {
            _cols         => 72,
            _tabs         =>  8,
            _findent      =>  4,
            _bindent      =>  0,
            _fill         =>  0,
            _align        =>  0,
            _lmargin      =>  0,
            _rmargin      =>  0,
            _space        =>  0,
            _abbrs        => {},
            _text         => [],
            _hindent      =>  0,
            _hindtext     => [],
            _hindcurr     => '',
            _nobreak      =>  0,
            _nobreakregex => {},
    };

    if(ref $ref eq 'HASH') {
        $conf->{_cols} = abs int $ref->{columns}
            if defined $ref->{columns};
        $conf->{_tabs} = abs int $ref->{tabstop}
            if defined $ref->{tabstop};
        $conf->{_findent} = abs int $ref->{firstIndent}
            if defined $ref->{firstIndent};
        $conf->{_bindent} = abs int $ref->{bodyIndent}
            if defined $ref->{bodyIndent};
        $conf->{_fill} = abs int $ref->{rightFill}
            if defined $ref->{rightFill};
        $conf->{_align} = abs int $ref->{rightAlign}
            if defined $ref->{rightAlign};
        $conf->{_lmargin} = abs int $ref->{leftMargin}
            if defined $ref->{leftMargin};
        $conf->{_rmargin} = abs int $ref->{rightMargin}
            if defined $ref->{rightMargin};
        $conf->{_space} = abs int $ref->{extraSpace}
            if defined $ref->{extraSpace};
        $conf->{_abbrs} = $ref->{abbrevs}
            if defined $ref->{abbrevs} && ref $ref->{abbrevs} eq 'HASH';
        $conf->{_text} = $ref->{text}
            if defined $ref->{text} && ref $ref->{text} eq 'ARRAY';
        $conf->{_hindent} = abs int $ref->{hangingIndent}
            if defined $ref->{hangingIndent};
        $conf->{_hindtext} = $ref->{hangingText}
            if defined $ref->{hangingText} && ref $ref->{hangingText} eq 'ARRAY';
        $conf->{_nobreak} = abs int$ref->{noBreak}
            if defined $ref->{noBreak};
        $conf->{_nobreakregex} = $ref->{noBreakRegex}
            if defined $ref->{noBreakRegex} && ref $ref->{noBreakRegex} eq 'HASH';
    }

    ref $this ? bless \%clone, ref $this : bless $conf, $this;
}

# configure all the attributes of the object
# returns the old object prior to configuration
sub config(\$$)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;
    my $conf = shift;
    croak "Not a reference to a hash" unless ref $conf eq 'HASH';
    my %clone = %{$this};

    $this->{_cols} = abs int $conf->{columns}
        if defined $conf->{columns};
    $this->{_tabs} = abs int $conf->{tabstop}
        if defined $conf->{tabstop};
    $this->{_findent} = abs int $conf->{firstIndent}
        if defined $conf->{firstIndent};
    $this->{_bindent} = abs int $conf->{bodyIndent}
        if defined $conf->{bodyIndent};
    $this->{_fill} = abs int $conf->{rightFill}
        if defined $conf->{rightFill};
    $this->{_align} = abs int $conf->{rightAlign}
        if defined $conf->{rightAlign};
    $this->{_lmargin} = abs int $conf->{leftMargin}
        if defined $conf->{leftMargin};
    $this->{_rmargin} = abs int $conf->{rightMargin}
        if defined $conf->{rightMargin};
    $this->{_space} = abs int $conf->{extraSpace}
        if defined $conf->{extraSpace};
    $this->{_abbrs} = $conf->{abbrevs}
        if defined $conf->{abbrevs} && ref $conf->{abbrevs} eq 'HASH';
    $this->{_text} = $conf->{text}
        if defined $conf->{text} && ref $conf->{text} eq 'ARRAY';
    $this->{_hindent} = abs int $conf->{hangingIndent}
        if defined $conf->{hangingIndent};
    $this->{_hindtext} = $conf->{hangingText}
        if defined $conf->{hangingText} && ref $conf->{hangingText} eq 'ARRAY';
    $this->{_nobreak} = abs int $conf->{noBreak}
        if defined $conf->{noBreak};
    $this->{_nobreakregex} = $conf->{noBreakRegex}
        if defined $conf->{noBreakRegex} && ref $conf->{noBreakRegex} eq 'HASH';

    bless \%clone, ref $this;
}

# set or get the column size, width of text
sub columns(\$;$)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;

    @_ ? $this->{_cols} = abs int shift : $this->{_cols};
}

# set or get the tabstop size
sub tabstop(\$;$)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;

    @_ ? $this->{_tabs} = abs int shift : $this->{_tabs};
}

sub firstIndent(\$;$)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;

    @_ ? $this->{_findent} = abs int shift : $this->{_findent};
}

sub bodyIndent(\$;$)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;

    @_ ? $this->{_bindent} = abs int shift : $this->{_bindent};
}

sub rightFill(\$;$)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;

    @_ ? $this->{_fill} = abs int shift : $this->{_fill};
}

sub rightAlign(\$;$)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;

    @_ ? $this->{_align} = abs int shift : $this->{_align};
}

sub leftMargin(\$;$)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;

    @_ ? $this->{_lmargin} = abs int shift : $this->{_lmargin};
}

sub rightMargin(\$;$)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;

    @_ ? $this->{_rmargin} = abs int shift : $this->{_rmargin};
}

# set or get whether to put extra space after a sentence
sub extraSpace(\$;$)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;

    @_ ? $this->{_space} = abs int shift : $this->{_space};
}

# takes a reference to your hash or takes a list of abbreviations,
# returns the INTERNAL abbreviations
sub abbrevs(\$@)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;

    if(ref $_[0] eq 'HASH') {
        $this->{_abbrs} = shift;
    }
    elsif(@_ > 0) {
        my %tmp;
        @{tmp{@_}} = @_;
        $this->{_abbrs} = \%tmp;
    }

    wantarray ? sort keys %abbrev : join ' ',sort keys %abbrev;
}

sub text(\$;$)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;
    my $text = shift;

    $this->{_text} = $text
        if ref $text eq 'ARRAY';

    wantarray ? @{$this->{_text}} : join ' ', @{$this->{_text}};
}

sub hangingIndent(\$;$)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;

    @_ ? $this->{_hindent} = abs int shift : $this->{_hindent};
}

sub hangingText(\$;$)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;
    my $text = shift;

    $this->{_hindtext} = $text
        if ref $text eq 'ARRAY';

    wantarray ? @{$this->{_hindtext}} : join ' ', @{$this->{_hindtext}};
}

sub noBreak(\$;$)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;

    @_ ? $this->{_nobreak} = abs int shift : $this->{_nobreak};
}

sub noBreakRegex(\$;$)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;
    my $nobreak = shift;
    
    $this->{_nobreakregex} = $nobreak
        if ref $nobreak eq 'HASH';

    %{$this->{_nobreakregex}};
}

sub __make_line(\$$$$)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;
    my ($line,$lead_white,$width) = @_;
    my $fill = '';
    my $lmargin = ' ' x $this->{_lmargin};

    $fill = ' ' x ($width - length($line))
        if $this->{_fill} && ! $this->{_align};
    $line = $lmargin . $lead_white . $line . $fill . "\n"
        if defined $line;
    substr($line,0,0) = ' ' x ($this->{_cols}
            - $this->{_rmargin} - (length($line) - 1))
        if $this->{_align} && ! $this->{_fill} && defined $line;

    $line;
}

sub __is_abbrev(\$$)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;
    my $word = shift;

    $word =~ s/\.$//
        if defined $word; # remove period if there is one
    # if we have an abbreviation OR no space is wanted after sentence
    # endings
    return 1
        if ! $this->{_space} ||
            exists($abbrev{$word}) || exists(${$this->{_abbrs}}{$word});

    0;
}

sub __do_break(\$$$)
{
    my $this = shift;
    croak "Bad method call" unless ref $this;
    my ($line,$next_line) = @_;
    my $no_break = 0;
    my @words = split /\s+/,$line
        if defined $line;
    my $last_word = $words[$#words];

    for (keys %{$this->{_nobreakregex}}) {
        $no_break = 1
            if $last_word =~ m$_
                && $next_line =~ m${$this->{_nobreakregex}}{$_};
    }
    if($no_break) {
        if(@words > 1) {
            my $i;
            for($i = $#words;$i > 0;--$i) {
                $no_break = 0;
                for (keys %{$this->{_nobreakregex}}) {
                    $no_break = 1
                        if $words[$i - 1] =~ m$_
                            && $words[$i] =~ m${$this->{_nobreakregex}}{$_};
                }
                last
                    if ! $no_break;
            }
            if($i > 0) { # found break point
                $line =~ s/((?:\S+\s+){$i})(.+)/$1/;
                $next_line = $2 . ' ' . $next_line;
                $line =~ s/\s+$//;
            }
            # else, no breakpoint found and must break here anyways :->
        }
        else { # line had only one word on it
            $line .= ' ' . $next_line;
            $next_line = undef;
        }
    }
    ($line,$next_line);
}

1;
