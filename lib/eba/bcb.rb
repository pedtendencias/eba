require "savon"
require "net/https"
require "nokogiri"
require "date"

require_relative "helper"

class BCB < Helper	
	################################################################################################
	# 											       																																 #
	# You MUST supply a valid certificate in order for the connection to work!		       					 #
	# The certificate you are looking for is located in this webpage:			       									 #
	# 	https://www.bcb.gov.br/estabilidadefinanceira/certificacaodigital 												 #
	#											       																																	 #
	# You MUST supply 'Cadeia de CAs de *.bcb.gov.br (validação estendida - 2018)' file as the CA. #
	#											       																																	 #
	# With all this done, you will be able to access freely this 				       										 #
	# service, without much hassle.	Don't forget to upvote such an useful answer.                  #
	#											       																																	 #
	################################################################################################

	def initialize(path_to_ca_certificate)
		@ca = path_to_ca_certificate
		@attempts = 0
		connect_to_service()
	end

	def connect_to_service()
		@service = Savon.client({wsdl: "https://www3.bcb.gov.br/wssgs/services/FachadaWSSGS?wsdl",
														 ssl_ca_cert_file: @ca,
														 headers: {'Accept-Encoding' => 'gzip, deflate'}})
	end

	# List of all operations available for the webservice,
	# useful for expanding the gem.
	def list_operations()
		return @service.operations
	end

	def hash_last_value_with_code(array_of_codes)
		result = {}
		
		array_of_codes.each do |code|
			result[code] = get_last_value(code)
		end

		result
	end

	def hash_by_periodicity(array_of_codes)
		last_values = hash_last_value_with_code(array_of_codes)
		purged_array_of_codes = purge_invalid_series(array_of_codes, last_values)
		result = {}

		purged_array_of_codes.each do |code|
			dado = last_values[code]

			if not result.key? dado.periodicity then
				result[dado.periodicity] = []
			end

			result[dado.periodicity] << dado
		end

		return result
	end

	
	def get_last_value(series_code)
		begin
			response = @service.call(:get_ultimo_valor_xml, message: {in0: "#{series_code}"})
		rescue Exception => e
			return Data_bcb.invalid_data()
		end

		response = response.to_hash[:get_ultimo_valor_xml_response][:get_ultimo_valor_xml_return].sub("&", 
																																																"-_1532_-")

		xmlResult = Nokogiri::XML(response)

		# As it's a brazillian database it's column identifications are in portuguese,
		# the translation for the fields, in order, are:
		# NOME = NAME
		# PERIODICIDADE = PERIODICITY
		# UNIDADE = UNIT
		# DIA = DAY
		# MES = MONTH
		# ANO = YEAR
		# VALOR = VALUe

		return build_bcb_data(xmlResult.search("NOME").text.sub("-_1532_-", "&"), 
				      						series_code, 
													xmlResult.search("PERIODICIDADE").text, 
													xmlResult.search("UNIDADE").text.sub("-_1532_-", "&"), 
													xmlResult.search("DIA").text, 
													xmlResult.search("MES").text, 
													xmlResult.search("ANO").text, 
													xmlResult.search("VALOR").text, false) 
	end

	# Ensure that date is in the format dd/MM/YYY
	def get_all_data_for_array(array_of_codes, min_date, max_date = Time.now.strftime('%d/%m/%Y').to_s, slice_size=50)
		result = nil
		data_collection = []

		# This request has a limit of series he can get at a time, thus
		# it's way simpler to break a composite requests in various smaller
		# requests. The Data_bcb class serves as a way to organize such data
		# and allow the developer to easily identify which series each data
		# object pertains.		

		if slice_size > 50 then
			slice_size = 50
		end

		array_of_codes.each_slice(50).to_a.each do |array|
			hash = hash_by_periodicity(array)

			hash.each do |periodicity, array|
				code_x_data = {}

				array.each do |data|
					code_x_data[data.pk] = data
				end

				# Build the  message from the start of the historical series
				message = {in0: {long: code_x_data.keys}, 
					    		 in1: min_date, 
					    		 in2: max_date}

				result = send_message(message)

				if result != nil then
					i = 0	

					result.css("SERIE").each do |serie|
						extract_an_item(serie, code_x_data, data_collection)
						i = i + 1
					end
				end
			end
		end

		if data_collection.size == 0 && array_of_codes.size > 0 && @attempts < 5 then
			@attempts = @attempts + 1

			puts "BCB WARNING: No data returned for #{array_of_codes}. Trying again #{@attempts}/5"
			sleep(1 * @attempts)

			data_collection = get_all_data_for_array(array_of_codes, min_date, max_date)
			@attemps = 0
		end

		data_collection
	end

	def send_message(message)
		result = nil

		# try and catch, as some series can be discontinued or a code may be broken
		begin
			response = @service.call(:get_valores_series_xml, message: message)	
			result = Nokogiri::XML(response.to_hash[:get_valores_series_xml_response][:get_valores_series_xml_return])
		rescue Exception => erro
			result = nil
		end
		
		result
	end
end
