#!/usr/bin/python

import math
import sqlite3
import time
import sys
import getopt

# Day of run + domain makes a unique entry
day = math.floor(time.time() / 60 / 60 / 24)

# Command line option to override the default day of today
opts, args = getopt.getopt(sys.argv[1:], ":d:", ["day="])

for opt, arg in opts:
	if (opt in ['-d', '--day']):
		day = int(arg)

connection = sqlite3.connect('subscriptions.db')

sorted_top_fifty = list()

with connection:
	cursor = connection.cursor()

	domain_counts = dict()

	print("Getting subscriptions...")
	
	for address in cursor.execute('SELECT addr FROM mailing'):

		# Chop off username and '@' leaving domain only
		domain = address[0].split('@')[1]

		# Count occurences of each domain
		if (domain in domain_counts):
			domain_counts[domain] += 1
		else:
			domain_counts[domain] = 1

	print("done!")

	sys.stdout.write("Updating the daily domain counts...")
	# Insert today's count for each domain into daily_domain_counts
	for domain, count in domain_counts.items():
		# Overwrite if the count is already there for today's run
		cursor.execute('''
			INSERT OR REPLACE INTO daily_domain_counts (
				domain, day, count
			) VALUES (
				:domain, :day, :count
			)''', {"domain" : domain, "day" : day, "count" : count})

	connection.commit()
	
	print("done!")

	# Get the top 50 domains by today's count
	cursor.execute('''
		SELECT domain, count
		FROM daily_domain_counts
		WHERE day = :day
		ORDER BY count DESC
		LIMIT 50''', {"day" : day})
	top_fifty_domains = cursor.fetchall()

	for domain_count in top_fifty_domains:
		domain = domain_count[0]
		count = domain_count[1]
		thirty_days_ago = day - 30

		# Get the count from 30 days ago
		cursor.execute('''
			SELECT count FROM daily_domain_counts
			WHERE day=:thirty_days_ago AND domain = :domain LIMIT 1''', \
			{"thirty_days_ago" : thirty_days_ago, "domain" : domain})
		count_thirty_days_ago = cursor.fetchone()

		sorted_top_fifty_len = len(sorted_top_fifty)

		if (count_thirty_days_ago is None):
			percent_increase = float("inf")
		else:
			count_thirty_days_ago = count_thirty_days_ago[0]
			percent_increase = int(round(100 * float(count - count_thirty_days_ago)
				/ count_thirty_days_ago))
		
		domain_dict = dict(domain=domain, count=count,\
			percent_increase=percent_increase)

		# Put this domain before the first count smaller than the current
		if (sorted_top_fifty_len <= 0):
			sorted_top_fifty.append(domain_dict)
		else:
			i = 0
			while (i < sorted_top_fifty_len and \
				sorted_top_fifty[i]["percent_increase"] > percent_increase):
				i += 1
			sorted_top_fifty.insert(i, domain_dict)

print "Domain\t\t| Count\t| % Increase"

i = 0
for domain in sorted_top_fifty:
	i += 1
	print str(i) + ". " + domain["domain"] + "\t| " + str(domain["count"]) \
		+ "\t| " + str(domain["percent_increase"]) + "%"

