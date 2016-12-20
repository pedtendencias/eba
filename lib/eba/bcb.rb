require "savon"
require "net/https"
require "nokogiri"
require "date"
require_relative "encoder"
require_relative "data"

class BCB < Encoder

	################################################################################################
	# 											       #
	# You MUST supply a valid certificate in order for the connection to work!		       #
	# The certificate you are looking for is located in this webpage:			       #
	# 	http://www.bcb.gov.br/?CERTDIG							       #
	#											       #
	# It will the most recent one which looks something like:				       #
	#	Cadeia de CAs de *.bcb.gov.br (yyyy)						       #
	#											       #
	# You then have to generate a public key from this crt file,				       #
	# you can do so by following this StackOverflow post:					       #
	#	http://stackoverflow.com/questions/5244129/use-rsa-private-key-to-generate-public-key  #
	#											       #
	# With all this done, you will be able to access freely this 				       #
	# service, without much hassle.	Don't forget to upvote such an useful answer.                  #
	#											       #
	################################################################################################

	def initialize(path_to_certificate)
		@pub_key = path_to_certificate
		connect_to_service()
	end

	def connect_to_service()


		@service = Savon.client({wsdl: "https://www3.bcb.gov.br/sgspub/JSP/sgsgeral/FachadaWSSGS.wsdl",
					ssl_cert_file: @pub_key,
					headers: {'Accept-Encoding' => 'gzip, deflate'}})
	end

	# List of all operations available for the webservice,
	# useful for expanding the gem.
	def list_operations()
		return @service.operations
	end

	# Removes all invalid series from an array.
	#
	# An invalid series has last value.
	def purge_invalid_series(array_of_codes)
		result = []

		array_of_codes.each do |code|
			if get_last_value(code) != nil
				result << code
			end
		end

		return result 
	end

	def hash_by_periodicity(array_of_codes)
		purged_array_of_codes = purge_invalid_series(array_of_codes)
		result = {}

		purged_array_of_codes.each do |code|
			dado = get_last_value(code)
	
			if not result.key? dado.periodicity then
				result[dado.periodicity] = []
			end

			result[dado.periodicity] << dado
		end

		return result
	end

	def build_bcb_data(name, code, periodicity, unit, day, month, year, value)
		encoded_name = encode(name)
		encoded_periodicity = encode(periodicity)
		encoded_unit = encode(unit)
		encoded_day = day
		encoded_month = month
		encoded_year = year
		encoded_value = encode(value)

		is_unseasoned = name.include? " - com ajuste sazonal"

		if is_unseasoned then
			name.slice! " - com ajuste sazonal"
		end
		
		return Data_bcb.new(encoded_name, code, encoded_periodicity,
				    encoded_unit, encoded_day, encoded_month,
				    encoded_year, encoded_value, is_unseasoned)
	end

	def get_last_value(series_code)
		begin
			response = @service.call(:get_ultimo_valor_xml, message: {in0: "#{series_code}"})
		rescue
			return nil
		end
		xmlResult = Nokogiri::XML(response.to_hash[:get_ultimo_valor_xml_response][:get_ultimo_valor_xml_return], nil, 'UTF-8')

		# As it's a brazillian database it's column identifications are in portuguese,
		# the translation for the fields, in order, are:
		# NOME = NAME
		# PERIODICIDADE = PERIODICITY
		# UNIDADE = UNIT
		# DIA = DAY
		# MES = MONTH
		# ANO = YEAR
		# VALOR = VALUE
		return build_bcb_data(xmlResult.search("NOME").text, 
				      series_code, 
				      xmlResult.search("PERIODICIDADE").text, 
				      xmlResult.search("UNIDADE").text, 
				      xmlResult.search("DIA").text, 
				      xmlResult.search("MES").text, 
				      xmlResult.search("ANO").text, 
				      xmlResult.search("VALOR").text) 
	end

	# Ensure that date is in the format dd/MM/YYY
	def get_all_data_for_array(array_of_codes, date)
		result = nil
		data_collection = Array.new()

		# This request has a limit of series he can get at a time, thus
		# it's way simpler to break a composite requests in various smaller
		# requests. The Data_bcb class serves as a way to organize such data
		# and allow the developer to easily identify which series each data
		# object pertains.		
		array_of_codes.each_slice(50).to_a.each do |array|
			hash = hash_by_periodicity(array)

			hash.each do |periodicity, array|
				codes = []
				data_array = []

				array.each do |data|
					data_array <<  data	
					codes << data.pk
				end

				# Build the  message from the start of the historical series
				message = { in0: {long: codes}, 
					    in1: date, 
					    in2: Time.now.strftime('%d/%m/%Y').to_s}

				# try and catch, as some series can be discontinued or a code may be broken
				begin
					response = @service.call(:get_valores_series_xml, message: message)	
					result = Nokogiri::XML(response.to_hash[:get_valores_series_xml_response][:get_valores_series_xml_return])
				rescue Exception => erro
					puts "\n\nError requesting! #{erro}\n\n"
				end

				i = 0	

				result.css("SERIE").each do |serie|
					# recover identifying data from the getLastValue method,
					# as the get_valores_series_xml desn't have identifying data
					# as series name, periodicity, etc. 
					base_data = data_array[i]
					comp = 'name="ID" value="' + codes[i].to_s + '"'
 
					if serie.inspect.include? comp
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

							data_collection << build_bcb_data(base_data.name, 
						   			     	          array[i], 
		 			  				   	          base_data.periodicity, 
	   							   	                  base_data.unit, 
						        	     	                  dia, mes, ano, 
				   		    	        	 		  item.css("VALOR").text)
						end
					end

					i = i + 1
				end
			end
		end

		return data_collection 
	end
end
