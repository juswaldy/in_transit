#!/usr/bin/ruby

DEBUG = false
class JUSRUBY
	def list # List instance methods.
		puts JUSRUBY.instance_methods.take_while {|m| m != :nil?}
	end

	# sweetmarias.
	def sm_read(folder) # Grab coffee html notes from given folder.
		require 'nokogiri'
		@datafields = {}
		@specfields = []
		@cuppingfields = []
		@flavorfields = []
		Dir.entries(folder).select{|x| x =~ /html$/}.sort.each do |f|
			puts '-'*80, f if DEBUG
			filepath = "#{folder}/#{f}"
			filebase = f.split('.')[0]
			if File.file?(filepath)
				h = Nokogiri::HTML(File.new(filepath))
				attributes = {}

				########################################
				# Short specs. Farm notes. Cupping notes.
				x = h.css("div.column-right")

				# Farm notes.
				fieldnum = 1
				farmnotes = x[fieldnum].text.strip if x[fieldnum]

				# Cupping notes.
				fieldnum = 2
				cuppingnotes = x[fieldnum].text.strip if x[fieldnum]

				########################################
				# Short blurb.
				x = h.css("p")

				fieldnum = 10
				shortblurb = x[fieldnum].text.strip if x[fieldnum]
				shortblurb = nil if shortblurb =~ /Toll Free/ or shortblurb.size > 400

				x = h.css("div.value")
				fieldnum = 0
				shortblurb = x[fieldnum].text.strip if !shortblurb and x[fieldnum]["itemprop"] == "description"

				########################################
				# Short specs.
				x = h.css("ul.list-info")
				fieldnum = 0
				if x[fieldnum]
					x[fieldnum].css("li").each do |li|
						field = li.css("strong").text.strip
						value = li.css("span").text.strip
						attributes[field] = value
					end
				end

				########################################
				# Detail specs.
				x = h.css("table.additional-attributes-table")
				fieldnum = 0
				if x[fieldnum]
					x[fieldnum].css("tr").each do |tr|
						field = tr.css("th").text.strip
						value = tr.css("td").text.strip
						if attributes.keys.include?(field)
							if attributes[field].size == 0
								attributes[field] = value
							else
								attributes[field] += ";#{value}" if value.size > 0 and attributes[field] != value
							end
						else
							attributes[field] = value
						end
					end
				end

				@specfields.push(attributes.keys)
				@specfields.flatten!.uniq!

				########################################
				# Label, Score, Correction. Cupping specs. Flavor specs.
				x = h.css("div.forix-chartjs")

				# Label, Score, Correction.
				label = score = correction = nil
				0.upto(2) do |n|
					label = x[fieldnum]["data-chart-label"] if !label and x[fieldnum]
					score = x[fieldnum]["data-chart-score"] if !score and x[fieldnum]
					correction = x[fieldnum]["data-cupper-correction"] if !correction and x[fieldnum]
				end

				# Cupping and flavor specs.
				cupping = {}
				flavor = {}
				x.each do |chart|
					a = chart["data-chart-value"].split(',')
					a.map{|s| s.strip.sub(' ', '').sub("Fragrence", "Fragrance").sub("Finsh", "Finish")}.each do |kv|
						key, value = kv.split(':')
						if chart["data-chart-id"] == "cupping-chart"
							cupping[key] = value
						elsif chart["data-chart-id"] == "flavor-chart"
							flavor[key] = value
						end
					end
				end

				@cuppingfields.push(cupping.keys)
				@cuppingfields.flatten!.uniq!
				@flavorfields.push(flavor.keys)
				@flavorfields.flatten!.uniq!

				@datafields[label] = [ score, correction, shortblurb, farmnotes, cuppingnotes, attributes, cupping, flavor, filebase ] if label and label.size > 0

			end
		end
	end
	def sm_list(folder)
		sm_read(folder)
		puts "Label|Score|Correction|Shortblurb|Farmnotes|Cuppingnotes|#{@specfields.join('|')}|#{@cuppingfields.join('|')}|#{@flavorfields.join('|')}"
		@datafields.each do |k, v|
			print "#{k.strip}|#{v[0..4].map{|f| f.strip.sub(' ', '') if f}.join('|')}|"
			specs = v[5]
			cupping = v[6]
			flavor = v[7]
			print @specfields.map{|s| specs[s]}.join('|')
			print @cuppingfields.map{|s| cupping[s]}.join('|')
			print @flavorfields.map{|s| flavor[s]}.join('|')
			print "\n"
		end
	end
	def sm_tex(folder)
		sm_read(folder)
		preamble = File.new("tex/preamble.tex").readlines
		template = File.new("tex/template.tex").readlines
		outfile = File.new("tex/batch3.tex", 'w')

		outfile.puts preamble
		@datafields.each do |k, v|
			score, correction, shortblurb, farmnotes, cuppingnotes, attributes, cupping, flavor, filebase = v

			table = ""
			@specfields.each do |s|
				if attributes[s]
					table += "  #{s.gsub('%', '\%')} & #{attributes[s].gsub('%', '\%')} \\\\\\\n"
					table += "  \\arrayrulecolor{lightgray}\\hline\n"
				end
			end

			infosheet = template.map{|s|
				s.gsub('@@label@@', k.upcase())
					.gsub('@@shortblurb@@', shortblurb.gsub('%', '\%'))
					.gsub('@@filebase@@', filebase)
					.gsub('@@table@@', table)
					.gsub('@@farmnotes@@', farmnotes.gsub('%', '\%'))
					.gsub('@@cuppingnotes@@', cuppingnotes.gsub('%', '\%'))
			}

			if score
				outfile.puts infosheet.map{|s| s.gsub('@@score@@', score) }
			else
				outfile.puts infosheet
			end
		end

		outfile.puts "%-------------------------------------------------------------------------------"
		outfile.puts "\\end{document}"
		outfile.close
	end
	def sm_glossary(filepath)
		require 'nokogiri'
		puts '-'*80, f if DEBUG
		if File.file?(filepath)
			h = Nokogiri::HTML(File.new(filepath))
			h.css("ul.glossary-glossary-items").each do |x|
				x.css("li").each do |li|
					term = li.css("span").text.strip
					defn = li.css("div.glossary-detail").text.strip
					puts "{\\myfont #{term}}"
					puts "#{defn.gsub("\n", "\\\\\\\n")}\\\\"
					puts
				end
			end
		end
	end

	# buycoffeecanada.
	def bcc_csv(filepath) # Convert buycoffeecanada page to csv.
		require 'nokogiri'
		h = Nokogiri::HTML(File.new(filepath))
		x = h.css("div.product-details")
		x.each do |y|
			a = y.css("a")
			p = y.css("div.prod-price")
			puts "#{a.text.strip},#{p.text.strip}" if p.text.strip.size > 0
		end

	end

	# schema.org SoftwareApplication.
	def schema_org(filepath)
		require 'nokogiri'
		if File.file?(filepath)
			h = Nokogiri::HTML(File.new(filepath))
			puts "Property|Expected Type|Description"
			h.css('table')[0].css('tr')[1..-1].each do |tr|
				property = type = description = ''
				if tr.css('td').size == 0
					property = tr.css('th').text.strip
					type = ''
					description = ''
				else
					property = tr.css('code/a')[0].text.strip
					type = tr.css('td')[0].text.encode(Encoding::ASCII, {:undef => :replace, :replace => ''}).gsub(/  /, ' ').strip
					description = tr.css('td')[1].text.gsub(/\n/, ' ').strip
				end
				puts "#{property}|#{type}|#{description}"
			end
		else
			puts "Invalid file #{filepath}"
		end
	end

	# Strip Hebrew accents.
	def heb_strip(infilepath, outfilepath)
		x = File.open(infilepath).readlines
		y = x.collect{|s| s.gsub(/[\u0591-\u05C7]/, '')}
		outfile = File.open(outfilepath, "wb")
		outfile.puts y
		outfile.close
	end
end

if ARGV.empty?
    puts "Usage: z.rb <app> [params]"
    puts "       z.rb list"
else
    j = JUSRUBY.new
    j.send(ARGV[0], *ARGV[1..-1])
end

