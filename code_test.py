#!/usr/bin/python

import math
import sqlite3
import time

# Day of run + domain makes a unique entry
day = math.floor(time.time() / 60 / 60 / 24)

connection = sqlite3.connect('code_test.db')
cursor = connection.cursor()

domain_counts = dict()

for address in cursor.execute('SELECT addr FROM mailing'):

	# Chop off username and '@' leaving domain only
	domain = address[0].split('@')[1]

	# Count occurences of each domain
	if (domain in domain_counts):
		domain_counts[domain] += 1
	else:
		domain_counts[domain] = 1

# Insert today's count for each domain into daily_domain_counts
for domain, count in domain_counts.items():
	# Overwrite if the count is already there for today's run
	cursor.execute("""
		INSERT OR REPLACE INTO daily_domain_counts (
			domain, day, count
		) VALUES (
			:domain, :day, :count
		)""", {"domain" : domain, "day" : day, "count" : count})

connection.commit()

print "Domain\t\t| Count\t| % Increase"

# Get the top 50 domains by today's count
cursor.execute("""
	SELECT domain, count
	FROM daily_domain_counts
	WHERE day = :day
	ORDER BY count DESC
	LIMIT 50""", {"day" : day})
top_fifty_domains = cursor.fetchall()

# Domain ranking counter
index = 0

for domain_count in top_fifty_domains:
	index += 1
	domain = domain_count[0]
	count = domain_count[1]
	thirty_days_ago = day - 30

	cursor.execute("""
		SELECT count FROM daily_domain_counts
		WHERE day=:thirty_days_ago AND domain = :domain LIMIT 1""", \
		{"thirty_days_ago" : thirty_days_ago, "domain" : domain})
	count_thirty_days_ago = cursor.fetchone()

	percent_increase = "N/A"

	if (count_thirty_days_ago is not None):
		percent_increase = str(100 * \
			(count - count_thirty_days_ago[0]) / count_thirty_days_ago[0]) + "%"

	# TODO: Sort by percent_increase
	print str(index) + ". " + domain + "\t| " + str(count) + "\t| " + percent_increase

connection.close()

