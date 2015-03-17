#!/usr/bin/perl

use strict;
use DBI;

sub create_db {
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

	print ("done!\n");
}
	
sub populate_db {
	print("Populating database..");
	my $dbh = shift;
	my @domains;

	#foreach (0..100000) {
	foreach (0..10) {
		# Generate a domain and add it to the list of domains
		push(@domains, $_ . '.com');
	}

	#print @domains;

	my $sth = $dbh->prepare("INSERT INTO mailing (addr) VALUES (?)");

	#foreach (0..10000000) {
	foreach (0..1000) {
		# Choose a random domain and for email address
		my $address = $_ . '@' . $domains[rand($#domains)];
		if ($_ % 1000000 == 0) {
			print '.';
		}
		
		# Insert into DB
		$sth->execute($address);
		$sth->finish();
	}
	
	print ("done!\n");
}

my $dbh = DBI->connect('dbi:SQLite:subscriptions.db');

create_db($dbh);
populate_db($dbh);

$dbh->disconnect();

