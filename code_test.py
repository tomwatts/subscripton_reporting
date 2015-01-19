#!/usr/bin/python

import math
import sqlite3
import time

day = math.floor(time.time() / 60 / 60 / 24)
print(str(day) + " days since epoch.")

connection = sqlite3.connect('code_test.db')
cursor = connection.cursor()

domain_counts = dict()

#for row in cursor.execute('SELECT addr FROM mailing LIMIT 50'):
for row in cursor.execute('SELECT addr FROM mailing'):
	# Chop off username and '@'
	domain = row[0].split('@')[1]

	# Count occurences of each domain
	if (domain in domain_counts):
		domain_counts[domain] += 1
	else:
		domain_counts[domain] = 1
	
sum = 0
# Insert each domain into daily_domain_counts
for domain, count in domain_counts.items():
	#print domain + " " + str(count)
	cursor.execute('INSERT INTO daily_domain_counts (domain, day, count) VALUES ( ?, ?, ?)', \
		(domain, day, count))
	sum += count

connection.commit()

print "Finished adding daily domain counts."

# TODO: Query for top 50 domains, summing count for each day
# TODO: Sort and calculate increase vs. count 30 days ago

connection.close()

