#!/usr/bin/python

import math
import sqlite3
import time

#day = math.floor(time.time() / 60 / 60 / 24)
day = 16476

print(str(day) + " days since epoch.")

connection = sqlite3.connect('code_test.db')
cursor = connection.cursor()

domain_counts = dict()

#for address in cursor.execute('SELECT addr FROM mailing LIMIT 50'):
for address in cursor.execute('SELECT addr FROM mailing'):

	# Chop off username and '@' leaving domain only
	domain = address[0].split('@')[1]

	# Count occurences of each domain
	if (domain in domain_counts):
		domain_counts[domain] += 1
	else:
		domain_counts[domain] = 1

# Insert each domain into daily_domain_counts
for domain, count in domain_counts.items():
	#print domain + " " + str(count)
	# Overwrite if the count is already there for today's run
	cursor.execute('INSERT OR REPLACE INTO daily_domain_counts (domain, day, count) VALUES (:domain, :day, :count)', \
		{"domain" : domain, "day" : day, "count" : count})
	
print "Domain\t\t| Count\t| % Increase"

for row in cursor.execute('SELECT domain, count FROM daily_domain_counts WHERE day = :day', {"day" : day}):
	domain = row[0]
	count = row[1]
	thirty_days_ago = day - 30
	cursor.execute('SELECT count FROM daily_domain_counts WHERE day=:thirty_days_ago AND domain = :domain LIMIT 1', {"thirty_days_ago" : thirty_days_ago, "domain" : domain})
	count_thirty_days_ago = cursor.fetchone()[0]
	print domain + "\t| " + str(count) + "\t| " + str(count_thirty_days_ago)

connection.commit()

print "Finished adding daily domain counts."


# TODO: Calculate increase vs. count 30 days ago

connection.close()

