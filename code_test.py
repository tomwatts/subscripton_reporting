#!/usr/bin/python

import sqlite3
import time

run_time = time.strftime('%Y-%m-%d %H:%M:%S')
print("Invoked at " + run_time)

connection = sqlite3.connect('code_test.db')
cursor = connection.cursor()

domains = dict()

for row in cursor.execute('SELECT addr FROM mailing LIMIT 10'):
	# Chop off username and '@'
	domain = row[0].split('@')[1]

	# Count occurences of each domain
	if (domain in domains):
		domains[domain] += 1
	else:
		domains[domain] = 1
	
print domains

# Insert each domain into daily_domain_counts
for domain in domains:
	print domain + count

	#cursor.execute('INSERT INTO daily_domain_counts (domain, date, count) VALUES ( ?, ?, ?)', \
		#domain.key, date, domain.value)

# TODO: Query for top 50 domains, summing count for each day
# TODO: Sort and calculate increase vs. count 30 days ago

connection.close()

