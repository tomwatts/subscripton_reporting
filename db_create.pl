#!/usr/bin/perl

use strict;
use DBI;

sub create_db
{
	print('Creating database...');
	my $dbh = shift;
	my $sth = $dbh->prepare('CREATE TABLE IF NOT EXISTS mailing (
		addr VARCHAR(255) NOT NULL )');
	$sth->execute();
	$sth->finish();

	$sth = $dbh->prepare(
		'CREATE TABLE IF NOT EXISTS daily_domain_counts (
			domain VARCHAR(255) NOT NULL,
			day UNSIGNED INT NOT NULL,
			count UNSIGNED BIG INT NOT NULL DEFAULT 0,
			CONSTRAINT daily_domain_counts PRIMARY KEY ( domain, day ))');
	$sth->execute();
	$sth->finish();

	print("done!\n");
}
	
sub populate_db
{
	print("Populating database...");
	my $dbh = shift;
	my @domains;

	foreach(0..99)
	{
		# Generate a domain and add it to the list of domains
		push(@domains, $_ . '.com');
	}

	my $addresses = [];
	my $sth = $dbh->prepare("INSERT INTO mailing (addr) VALUES (?)");

	foreach(0..9999)
	{
		# Choose a random domain and for email address
		push(@$addresses, $_ . '@' . $domains[rand(@domains)]);
	}

	# Insert into DB
	$sth->bind_param_array(1, $addresses);
	$sth->execute_array({});	# Ignore status
	$sth->finish();

	print("done!\n");
}

my $start_time = time();

my $dbh = DBI->connect('dbi:SQLite:subscriptions.db');

create_db($dbh);
populate_db($dbh);

$dbh->disconnect();

my $run_time = time() - $start_time;
print("Elapsed time: $run_time s\n");

