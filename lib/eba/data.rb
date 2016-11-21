# This class intends to organize the series data in a easy to use way,
# making it easier to group lots of data in a coese way, without lost of
# information.
class DataBCB
	@name = ""
	@periodicity = 0
	@unit = ""
	@date = ""
	@value = 0.0	
	@pk = 0

	# Initialization is expected to express the state of a single row of 
	# data inside the BCB's Database.
	def initialize(series_name, series_code, series_periodicity, series_unit, 
		       series_day, series_month, series_year, series_value)

		@name = series_name
		@pk = series_code
		@periodicity = series_periodicity
		@unit = series_unit
		@data = standardizes_date(series_day, series_month, series_year)

		# Removes the . which separate every three numbers.
		# This might be supperfluous, haven't tested it though.
		@valor = valor.tr(".", "").to_f
	end	
	
	# Return an "identification key" with data which should 
	# be unique to a series (grouped).
	def key()
		return @name + @periodicity.to_s + @unity
	end
	
	# Note that there are no set methods in this class,
	# I built it in such a way that you are only intended
	# to access data in the rawest form as possible as it comes
	# from the BCB Webservice.
	def pk
		return @pk
	end

	def name
		return @name
	end

	def periodicity
		return @periodicity
	end

	def unit
		return @unit
	end

	def date
		return @date
	end

	def value
		return @value
	end

	# The Webservice will always supply the date in three separate fields,
	# this methods aim to convert it to a standard dd.mm.YYYY string.
	def standardizes_date(day, month, year)
		return "#{standardizes_number(day.to_i)}." 
		     + "#{standardizes_number(mmonth.to_i)}." 
		     + "#{year}"
	end

	# As we are building a dd.mm.yyyy string, we want to 
	# standardize the size of the fields.
	def standardizes_number(number)
		if (number < 10)
			return "0" + number.to_s
		else
			return number.to_s
		end
	end
	
	def print()
		return "Name: #{@name}\n" 
		     + "BCB Code: #{pk}\n" 
		     + "Periodicity: #{periodicity}\n" 
		     + "Unit: #{unit}\n" 
		     + "Date: #{date}   Value: #{value}\n"
	end

	# Simple comparission between two DataBCB objects.
	def compare_to(data_bcb)
		return (@name == data_bcb.name and @pk == data_bcb.pk \
		    and @periodicity == data_bcb.periodicity \
		    and @unit == data_bcb.unit and @date == data_bcb.date \
		    and @value = data_bcb.value)
	end
end
