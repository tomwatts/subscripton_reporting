#!/usr/bin/perl

use DBI;
#import random

sub create_db {
	print("Creating database...");
	my $connection = shift;
	my $statement = $connection->prepare('CREATE TABLE IF NOT EXISTS mailing (
		addr VARCHAR(255) NOT NULL )');
	$statement->execute();
	$statement->finish();

	$statement = $connection->prepare(
		'CREATE TABLE IF NOT EXISTS daily_domain_counts (
			domain VARCHAR(255) NOT NULL,
			day UNSIGNED INT NOT NULL,
			count UNSIGNED BIG INT NOT NULL DEFAULT 0,
			CONSTRAINT daily_domain_counts PRIMARY KEY ( domain, day ))');
	$statement->execute();
	$statement->finish();

	print ("done!\n");
}
	
sub populate_db {
	print("Populating database...");
	my $connection = shift;
	my @domains = ();

	foreach (0..100000) {
		# Generate a domain and add it to the list of domains
#		$domains.append(str(x) + ".com")
	}

	foreach (0..10000000) {
		# Choose a random domain and for email address
#		address = str(x) + '@' + random.choice(domains)
		#if (x % 1000000 == 0):
			#print address
		
		# Insert into DB
#		my $statement = $connection->prepare(
#			'INSERT INTO mailing (addr) VALUES (?)', (address,));
	}
	
#	connection.commit()
	print ("done!\n");
}

my $connection = DBI->connect('dbi:SQLite:subscriptions.db');

create_db($connection);
populate_db($connection);

$connection->disconnect();

