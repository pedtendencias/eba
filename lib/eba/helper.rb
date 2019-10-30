require_relative "data"
require_relative "encoder"

class Helper < Encoder
	def initialize()
	end

	def build_bcb_data(name, code, periodicity, unit, day, month, year, value, is_unseasoned)
		if name[" - com ajuste sazonal"] != nil then
			is_unseasoned = true

			if is_unseasoned then
				name.slice!(" - com ajuste sazonal")
			end		
		end

		encoded_name = encode(name)
		encoded_periodicity = encode(periodicity)
		encoded_unit = encode(unit)
		encoded_day = day
		encoded_month = month
		encoded_year = year
		encoded_value = encode(value)
		
		return Data_bcb.new(encoded_name, code, encoded_periodicity,
				    						encoded_unit, encoded_day, encoded_month,
				    						encoded_year, encoded_value, is_unseasoned)
	end

	# Removes all invalid series from an array.
	#
	# An invalid series has last value.
	def purge_invalid_series(array_of_codes, hash_last_values)
		result = []

		array_of_codes.each do |code|
			if hash_last_values[code] != nil then
				result << code
			end
		end

		return result 
	end

	def extract_an_item(serie, code_x_data_hash, collection)
		# recover identifying data from the getLastValue method,
		# as the get_valores_series_xml desn't have identifying data
		# as series name, periodicity, etc. 	 
		if serie.to_s.inspect["SERIE ID"] != nil then
			code = serie.to_s.match(/SERIE ID=\"([0-9]+)\"/)[1].to_i
			base_data = code_x_data_hash[code]

			if base_data != nil then
				serie.css("ITEM").each do |item|
					dia = "01"
					mes = "1"
					ano = "1"
					data = item.css("DATA").text.split("/")

					if base_data.periodicity == 'D' then
						dia = data[0]
						mes = data[1]
						ano = data[2]
					else
						mes = data[0]
						ano = data[1]
					end 

					collection <<  build_bcb_data(base_data.name, code, 
																   		  base_data.periodicity, 
															 					base_data.unit, 
															 					dia, mes, ano, 
															 					item.css("VALOR").text,
															 					base_data.seasonally_adjusted)
				end	
			else
				puts "ERROR BCB: Failure do locate #{code} in the data collection #{code_x_data_hash.keys}"
			end
		end
	end
end
