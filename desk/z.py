#!/usr/bin/python

import csv

# Adjust the value of the given key in a numeric-valued dictionary.
def adjust_memo(memo, key, value=1):
	if key in memo.keys():
		memo[key] += value # Adjust value.
	else:
		memo[key] = value # Start recording.

# Count entities specified in the given column.
def split_and_count(column, counter, self_counter):
	X = r[column].split(', ')
	for x in X:
		adjust_memo(counter, x, 1)
		if len(X) == 1: # If only one is specified, count it twice and mark it in the self counter.
			counter[x] += 1
			adjust_memo(self_counter, x, 1)


# Print the given counter.
def print_counter(column, counter, reverse=True):
	print '#'*80, "\n", column
	for x in sorted(counter.items(), key=lambda x: x[1], reverse=reverse):
		print x[1], '-', x[0]
	print

# Set up counters.
object_counter = {}
program_counter = {}
machine_counter = {}
user_counter = {}
object_counter_self = {}
program_counter_self = {}
machine_counter_self = {}
user_counter_self = {}
#counters = {
#	'Objects': object_counter,
#	'Program': program_counter,
#	'Machines': machine_counter,
#	'Users': user_counter
#}
counters = {
	'Objects': [object_counter, object_counter_self],
	'Program': [program_counter, program_counter_self],
	'Machines': [machine_counter, machine_counter_self],
	'Users': [user_counter, user_counter_self]
}

# Process file.
with open('2020-09-15.Deadlocks.csv') as f:
	reader = csv.DictReader(f)
	for r in reader:
		for i, (k,v) in enumerate(counters.items()):
			split_and_count(k, v[0], v[1])
#		split_and_count('Objects', count_objects)
#		split_and_count('Program', count_programs)
#		split_and_count('Machines', count_machines)
#		split_and_count('Users', count_users)

for i, (k,v) in enumerate(sorted(counters.items())):
	print_counter(k, v[0])
for i, (k,v) in enumerate(sorted(counters.items())):
	print_counter(k, v[1])
