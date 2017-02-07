# This class intends to organize the series data in a easy to use way,
# making it easier to group lots of data in a coese way, without lost of
# information.
class Data_bcb
	@name = ""
	@periodicity = 0
	@unit = ""
	@date = ""
	@value = 0.0	
	@pk = 0
	@seasonally_adjusted = false

	# Initialization is expected to express the state of a single row of 
	# data inside the BCB's Database.
	def initialize(series_name, series_code, series_periodicity, series_unit, 
		       series_day, series_month, series_year, series_value, seasonally_adjusted)

		@name = series_name
		@pk = series_code
		@periodicity = series_periodicity
		@unit = series_unit
		@date = standardizes_date(series_day, series_month, series_year)
		@value = series_value.to_f
		@seasonally_adjusted = seasonally_adjusted
	end	
	
	# Return an "identification key" with data which should 
	# be unique to a series (grouped).
	def key()
		return @name + @periodicity.to_s + @unit
	end

	def is_valid?
		return @name != nil and @name != '' and 
					 @periodicity != nil and @periodicity >= 0 and
					 @unit != nil and @unit != '' and 
					 @date != nil and @date != '' and
					 @value != nil and @pk != nil
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

	def seasonally_adjusted
		return @seasonally_adjusted
	end

	# The Webservice will always supply the date in three separate fields,
	# this methods aim to convert it to a standard dd.mm.YYYY string.
	def standardizes_date(day, month, year)
		if day == '' or day == nil then
			day = "01"
		end

		if month == '' or month == nil then
			month = "01"
		end

		if year == '' or year == nil then
			year = "1900"
		end

		if month.to_i > 1900 then
			year = month
			month = "01"
		end

		return "#{standardizes_number(day.to_i)}.#{standardizes_number(month.to_i)}.#{year}"
	end

	# As we are building a dd.mm.yyyy string, we want to 
	# standardize the size of the fields.
	def standardizes_number(number)
		if (number < 10)
			return "0#{number}"
		else
			return "#{number}"
		end
	end
	
	def print()
		return "Name: #{@name}\n" + 
		       "BCB Code: #{@pk}\n" + 
		       "Periodicity: #{@periodicity}\n" + 
		       "Unit: #{@unit}   Seasonally Adjusted? #{@seasonally_adjusted ? 'YES' : 'NO'}\n" + 
		       "Date: #{@date}   Value: #{@value}\n"
	end

	# Simple comparission between two DataBCB objects.
	def compare_to(data_bcb)
		return (@name == data_bcb.name and @pk == data_bcb.pk \
		    and @periodicity == data_bcb.periodicity \
		    and @unit == data_bcb.unit and @date == data_bcb.date \
		    and @value = data_bcb.value and @seasonally_adjusted == data_bcb.seasonally_adjusted)
	end
end
