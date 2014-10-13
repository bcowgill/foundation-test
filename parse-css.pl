#!/usr/bin/env perl
# Parse the Foundation library CSS and make dark background
# ./parse-css.pl custom-default/css/foundation.css  2> out.err > css/foundation.css; vdiff custom-default/css/foundation.css css/foundation.css; less out.err

use strict;
use warnings;
use English -no_match_vars;
use Data::Dumper;

my %FoundCounter = ();
my @CSSPath = ();
my $css_path = '';
my $state = 'scan';
my $found = '';

my $Background_Color = 'black';
my $Primary_Color = '#44AA99';
my $Secondary_Color = '#88CCEE';
my $Alert_Color = '#CC6677';
my $Success_Color = '#117733';
my $Body_Font_Color = '#DDCC77';
my $Header_Font_Color = '#999933';
my $Body_Font_Color_rgba75 = 'rgba(221, 204, 119, 0.75)';
my $Body_Font_Color_rgba25 = 'rgba(221, 204, 119, 0.25)'; # for placeholders in input

my $Add_Rules = << "EOCSS";
/*
   Foundation is missing style for input placeholders
   http://stackoverflow.com/questions/2610497/change-an-inputs-html5-placeholder-color-with-css
*/

/* WebKit browsers */
::-webkit-input-placeholder {
    color:    $Body_Font_Color_rgba25; }
/* Mozilla Firefox 4 to 18 */
:-moz-placeholder {
   color:    $Body_Font_Color_rgba25;
   opacity:  1; }
/* Mozilla Firefox 19+ */
::-moz-placeholder {
   color:    $Body_Font_Color_rgba25;
   opacity:  1; }
/* Internet Explorer 10+ */
:-ms-input-placeholder {
   color:    $Body_Font_Color_rgba25; }
EOCSS

my %Replacements = (
	qr{ \A (\s* background(?:-color)? \s* : \s* ) white ( \s* ; \s* ) \z }xms => sub {
		my ($num, $full, $pre, $post) = @ARG;
		debug("FOUND #$num $full within rule path $css_path");
		my $replace = $pre . $Background_Color . $post;
		$replace .= "\n  color: $Body_Font_Color; " if ($css_path =~ m{fieldset \s+ legend}xms);
		debug("REPLACE $replace");
		return $replace;
	},
	# fafafa select/textarea background color
	# f3f3f3 select hover background color
	qr{ \A (\s* background(?:-color)? \s* : \s* ) (?:\#fafafa|\#f3f3f3) ( \s* ; \s* ) \z }xmsi => $Background_Color,

	# 222222 general body color
	# 4d4d4d label text color
	# 676767 small label text color
	qr{ \A (\s* color \s* : \s* ) (?:\#222222|\#4d4d4d|\#676767) ( \s* ; \s* ) \z }xmsi => $Body_Font_Color_rgba75,
	# rgba 0 0.75 input text color
	qr{ \A (\s* color \s* : \s* ) (?:rgba\(0, \s* 0, \s* 0, \s* 0.75\)) ( \s* ; \s* ) \z }xmsi => $Success_Color,
	qr{ \A (\s* (?:background(?:-color)?|color) \s* : \s* ) (\#[0-9a-f]+) ( \s* ; \s* ) \z }xmsi => sub {
		my ($num, $full, $pre, $color, $post) = @ARG;
		debug("FOUND #$num $full within rule path $css_path");
		return $full;
	},
);

sub found
{
	# strip out excess spacing and count each matching item
	my ($found) = @ARG;
	$found =~ s{\A \s*}{}xms;
	$found =~ s{\s* \z}{}xms;
	$found =~ s{\s* : \s*}{:}xmsg;
	$found =~ s{\s* ; \s*}{;}xmsg;
	$FoundCounter{$found}++;
	return $FoundCounter{$found};
}

sub replace_property
{
	my ($property) = @ARG;

	foreach my $regex (keys(%Replacements))
	{
		if ($property =~ m{ $regex }xms)
		{
			my @Params = ($1, $2, $3, $4, $5, $6, $7, $8, $9);
			debug("$regex Params: " . Dumper(\@Params));
			my $num = found($property);
			eval
			{
				# try to invoke replacement function
				$property = $Replacements{$regex}->($num, $property, @Params);
			};
			if ($EVAL_ERROR)
			{
				# else use replacement value
				my $new = $Params[0] . $Replacements{$regex} . $Params[1];
				debug("REPLACE #$num $property within rule path $css_path with $new");
				$property = $new;
			}
			last;
		}
	}
	return $property;
}

sub debug
{
	my ($message) = @ARG;
	print STDERR "$message\n";
}

sub comment
{
	my ($comment) = @ARG;
	debug(qq{comment [$comment]});
	print "$comment\n";
}

sub open_rule
{
	my ($rules) = @ARG;
	debug(qq{open-rule in $css_path [$rules]});
	push(@CSSPath, $rules);
	$css_path = join(' / ', @CSSPath);
	$css_path =~ s{\n}{ }xmsg;
	print "$rules\{\n";
}

sub property
{
	my ($property) = @ARG;
	debug(qq{property [$property]});
	$property = replace_property($property);
	print "$property\n";
}

sub close_rule
{
	debug(qq{close-rule});
	pop(@CSSPath);
	print "}\n";
}

while (my $line = <>)
{
	chomp($line);
	#print "$state $line\n";
	if ($state eq 'comment')
	{
		# we handle simple multi-line comments in this file
		if ($line =~ m{\A \s* \*\/ \s* \z}xms)
		{
			$found .= "$line\n";
			$state = 'scan';
			comment($found);
			$found = '';
		}
		else
		{
			$found .= "$line\n";
		}
	}
	else
	{
		if ($line =~ m{\A (\s*) ([^\{\}]+?) (\s*) ([\{\}]) (\s* \} \s*)? \z}xms) {
			my ($pre_spaces, $rules, $gap_spaces, $token, $another_close) = ($1, $2, $3, $4, $5);
			my $rule = "$pre_spaces$rules$gap_spaces";
			if ($state eq 'part-rule')
			{
				$rule = "$found$rule";
				$state = 'scan';
				$found = '';
			}
			if ($token eq '{')
			{
				open_rule($rule);
			}
			else
			{
				property($rule);
				close_rule();
			}
			if ($another_close)
			{
				close_rule();
			}
		}
		elsif ($line =~ m{\A \s* \{ \s* \z}xms)
		{
			open_rule($found);
			$found = '';
		}
		elsif ($line =~ m{\A \s* \} \s* \z}xms)
		{
			close_rule();
		}
		elsif ($line =~ m{\A ( \s* [^:]* : \s* [^;]+ \s*; \s*) \z}xms)
		{
			property($1);
		}
		elsif ($line =~ m{\A ( \s* [^:]+ : \s* \w+ \s* \( [^\)]+ \) \s* ; \s*) \z}xms)
		{
			property($1);
		}
		elsif ($line =~ m{\A ( \s* /\* .+? \*/ \s*) \z}xms)
		{
			comment($1);
		}
		elsif ($line =~ m{\A /\* .* \z}xms)
		{
			# we handle simple multi-line comments in this file
			$state = 'comment';
			$found = "$line\n";
		}
		elsif ($line =~ m{\A ( .+ , .* \s* ) \z}xms)
		{
			$found .= "$1\n";
			$state = 'part-rule';
		}
		elsif ($line !~ m{\A \s* \z}xms)
		{
			warn qq{What? [$line] -- assume ruleset\n};
			$found .= "$line ";
			$state = 'part-rule';
		}
	}
}
print $Add_Rules;

debug(Dumper(\%FoundCounter));