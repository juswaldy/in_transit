#!/usr/bin/ruby
# Salesforce wget/helper methods:
# 1. backupAndRestore: grab backup file and load it into the backup DB
# 2. checkMessagingStatus: check Outbound Messaging status
# 3. to18: convert 15 digit Id to 18 digit
#
# Usage:
# First, make a main script that requires this file and also a config file. e.g.
# /home/tomcat/CloverDX/sandboxes/ERxSync_Test/script/ERx.rb
# > require "ERx_config.rb"
# > require "Salesforce.rb"
# >
# > erx = SALESFORCE.new
# > erx.send(ARGV[0], *ARGV[1..-1])
#
# Second, call the script like this:
# > ruby <scriptName> <methodName> <parameters>
# > ruby ERx.rb to18 0031500001myweS
# > 0031500001myweS => 0031500001myweSAAQ
#
# WARNING: Salesforce might change the strings/patterns we are watching for, in
# order to get the backup or check the status. When they do, then we must change
# ours accordingly. See @backupActionString and @stuckMessagePattern.
#

class SFFIELD
	attr_accessor :name, :sqlType, :cloverType, :nillable
	def initialize(name, sqlType, cloverType, nillable)
		@name = name
		@sqlType = sqlType
		@cloverType = cloverType
		@nillable = nillable
		@db = nil
	end
end

class SALESFORCE

	def initialize
		# Email.
		@stmpHost = "es1-cas.twu.ca"
		@emailFrom = "dev@twu.ca"
		@topic = ""
		@robotname = ""
		@signature = ""
	end
	def to18(input)
		# From https://astadiaemea.wordpress.com/2010/06/21/15-or-18-character-ids-in-salesforce-com-–-do-you-know-how-useful-unique-ids-are-to-your-development-effort/
		def convert(part)
			intValue = part.to_i(2)
			if intValue > 25
				(intValue - 26).to_s
			else
				(intValue + 65).chr
			end
		end
		if input.size == 15
			# Split, Reverse, Reduce.
			first = input[0..4].reverse.gsub(/[^A-Z]/, '0').gsub(/[^0]/, '1')
			second = input[5..9].reverse.gsub(/[^A-Z]/, '0').gsub(/[^0]/, '1')
			third = input[10..14].reverse.gsub(/[^A-Z]/, '0').gsub(/[^0]/, '1')

			# Lookup.
			puts "#{input} => #{input}#{convert(first)}#{convert(second)}#{convert(third)}"
		else
			puts "Sorry, input must be 15 chars long!"
		end
	end
end

if ARGV.empty?
    puts "Usage: sf.rb <app> [params]"
    puts "       sf.rb list"
else
    sf = SALESFORCE.new
    sf.send(ARGV[0], *ARGV[1..-1])
end

