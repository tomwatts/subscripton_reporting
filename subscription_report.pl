#!/usr/bin/perl

use strict;
use POSIX;
use DBI;

# Day of run + domain makes a unique entry
my $day = floor(time() / 60 / 60 / 24);

# Command line option to override the default day of today
#opts, args = getopt.getopt(sys.argv[1:], ":d:", ["day="])

#for opt, arg in opts:
#	if (opt in ['-d', '--day']):
#		day = int(arg)

my $dbh = DBI->connect('dbi:SQLite:subscriptions.db');

my @sorted_top_fifty;
my %domain_counts;

print("Getting subscriptions...");

my $sth = $dbh->prepare('SELECT addr FROM mailing');
$sth->execute();
my $rows = $sth->fetchall_arrayref();
foreach (@$rows)
{
	#print("@$_\n");
	# Chop off username and '@' leaving domain only
	my $domain = split(/@/, @$_);
	#print("$domain\n");

	# Count occurences of each domain
	if (exists($domain_counts{$domain}))
	{
		$domain_counts{$domain} += 1;
	}
	else
	{
		$domain_counts{$domain} = 1
	}
}

print("done!\n");

print("Updating the daily domain counts...");

$sth = $dbh->prepare("INSERT OR REPLACE INTO daily_domain_counts (domain, day, count)
	VALUES (?, ?, ?)");
# Insert today's count for each domain into daily_domain_counts
#foreach domain, count in %domain_counts
#{
	# Overwrite if the count is already there for today's run
#	$sth->execute($domain, $day, $count);
	$sth->finish();
#}

print("done!\n");

# Get the top 50 domains by today's count
$sth = $dbh->prepare("SELECT domain, count FROM daily_domain_counts WHERE day = ?
	ORDER BY count DESC LIMIT 50");
$sth->execute($day);
$sth->finish();
#top_fifty_domains = cursor.fetchall()

#for domain_count in top_fifty_domains:
#	domain = domain_count[0]
#	count = domain_count[1]
#	thirty_days_ago = day - 30

	# Get the count from 30 days ago
#	cursor.execute('''
#		SELECT count FROM daily_domain_counts
#		WHERE day=:thirty_days_ago AND domain = :domain LIMIT 1''', \
#		{"thirty_days_ago" : thirty_days_ago, "domain" : domain})
#	count_thirty_days_ago = cursor.fetchone()

#	sorted_top_fifty_len = len(sorted_top_fifty)

#	if (count_thirty_days_ago is None):
#		percent_increase = float("inf")
#	else:
#		count_thirty_days_ago = count_thirty_days_ago[0]
#		percent_increase = 100 * \
#			(count - count_thirty_days_ago) / count_thirty_days_ago
	
#	domain_dict = dict(domain=domain, count=count,\
#		percent_increase=percent_increase)

	# Put this domain before the first count smaller than the current
	if ($#sorted_top_fifty <= 0)
	{
#		sorted_top_fifty.append(domain_dict)
	}
	else
	{
		my $i = 0;
#		while (i < $#sorted_top_fifty and \
#			sorted_top_fifty[i]["percent_increase"] > percent_increase):
#			i += 1
#		sorted_top_fifty.insert(i, domain_dict)
	}

print("Domain\t\t| Count\t| % Increase\n");

my $i = 0;
my @sorted_top_fifty;
my %domain_count;
$domain_count{'domain'} = "TestDomain.com";
$domain_count{'count'} = 15;
$domain_count{'percent_increase'} = 115;
push(@sorted_top_fifty, %domain_count);

foreach (@sorted_top_fifty)
{
	$i += 1;
	print "$i. $_{'domain'}\t| $_{'count'}\t| $_{'percent_increase'}%\n";
}

$dbh->disconnect();

print("Done!\n");

