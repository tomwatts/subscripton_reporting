#!/usr/bin/python

import sqlite3
import random

def create_db(connection):
	cursor = connection.cursor()
	cursor.execute('DROP TABLE mailing')
	cursor.execute('CREATE TABLE mailing ( addr VARCHAR(255) NOT NULL )')
	cursor.execute('CREATE TABLE daily_domain_counts ( '
		' domain VARCHAR(255) NOT NULL, '
		' date DATETIME NOT NULL, '
		' count UNSIGNED BIG INT NOT NULL DEFAULT 0 )')
	connection.commit()
	
def populate_db(connection):
	cursor = connection.cursor()
	domains = []

	for x in range(0, 100000):
		# Generate a domain and add it to the list of domains
		domains.append(str(x) + ".com")

	for x in range(0, 10000000):
		# Choose a random domain and for email address
		address = str(x) + '@' + random.choice(domains)
		if (x % 1000000 == 0):
			print address
		
		# Insert into DB
		cursor.execute('INSERT INTO mailing VALUES (?)', (address,))
	
	connection.commit()


connection = sqlite3.connect('code_test.db')

create_db(connection)
populate_db(connection)

connection.close()

