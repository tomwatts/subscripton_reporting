Aside from this README, this solution contains the following two files:

db_create.pl:
	This script will create a table called 'mailing' with one column called
	'addr' and other table called 'daily_domain_counts' with three columns:
	'domain', 'day', and 'count'.  It will then populate the mailing table with
	10,000 email addresses using 100 different domains.

subscription_report.pl:
	The actual solution to the code test.  Queries the 'mailing' table and
	updates the 'daily_comain_counts' table with the current day (days since
	Epoch), domain, and number of entries in 'mailing' with this domain.
	Finally, this table is queried for the top 50 domains by today's count and
	their respective counts 30 days ago.  These domains are reported ordered by
	the percent increase in count over the last 30 days in descending order.
	The '-d' or '--day' flag can be used to override the day used for the
	current run to simulate a run in the past.  This is provided to produce
	data for 30 days ago, which makes the percent increase calculations
	relevant.
