require "savon"
require "net/https"
require "nokogiri"
require "date"
require "./encoder"
require "./data"

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
		@pub_key = path_to_certificates
		connect_to_service()
	end

	def connect_to_service()
		@service = Savon.client(wsdl: "https://www3.bcb.gov.br/sgspub/JSP/sgsgeral/FachadaWSSGS.wsdl", 
					ssl_cert_file: @pub_key)
	end

	# List of all operations available for the webservice,
	# useful for expanding the gem
	def list_operations()
		puts @service.operations
	end

	def get_last_value(series_code)
		response = @service.call(:get_ultimo_valor_xml, message: {in0: cod_serie.to_s})
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
		return DadoBCB.new(encode(xmlResult.search("NOME").text), 
				   series_code, 
				   encode(xmlResult.search("PERIODICIDADE").text), 
				   encode(xmlResult.search("UNIDADE").text), 
				   encode(xmlResult.search("DIA").text), 
				   encode(xmlResult.search("MES").text), 
				   encode(xmlResult.search("ANO").text), 
				   encode(xmlResult.search("VALOR").text)) 
	end

	def get_all_data_for_array(array_of_codes)
		results = {}
		codes = Array.new()
		data_collection = Array.new()

		array_of_codes.each do |code|
			codes << code.to_s

			# Build the  message from the start of the historical series
			message = { in0: {long: codigos}, 
				    in1: '01/02/2004', 
				    in2: Time.now.strftime('%d/%m/%Y').to_s}
			
			# try and catch, as some series can be discontinued or a code may be broken
			begin
				# This request has a limit of series he can get at a time, thus
				# it's way simpler to break a composite requests in various smaller
				# requests. The DataBCB class serves as a way to organize such data
				# and allow the developer to easily identify which series each data
				# object pertains.
				response = @service.call(:get_valores_series_xml, message: message)
				results[code] = Nokogiri::XML(response.to_hash[:get_valores_series_xml_response] \
										   [:get_valores_series_xml_return])
			rescue	
				puts "Failure trying to update " + code
			end

			codes.clear	
		end

		results.each do |code, result|
			# recover identifying data from the getLastValue method,
			# as the get_valores_series_xml desn't have identifying data
			# as series name, periodicity, etc. 
			base_data = get_last_value(code)				
	

			# Encode enforces data data is being read as UTF-8, as 
			# portuguese uses a huge ammount of special characters and
			# accentuations.
			result.css("ITEM").each do |item|
				data_collection << DadoBCB.new(encode(base_data.name), 
				   		     	       code, 
	 	  				   	       base_data.periodicity, 
	   					   	       encode(base_data.unit), 
					             	       "1", 
					       		       item.css("DATA").text.split("/")[0], 
					  	       	       item.css("DATA").text.split("/")[1], 
				   		    	       item.css("VALOR").text)
			end
		end

		return dados
	end
end
