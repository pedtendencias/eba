module Eba
  # For documentation purposes:
  # VERSION = mm.ff.hh
  # mm - major change
  # ff - commits on feature
  # hh - commits on hotfix

  VERSION = "1.11.0"

  #Version 1.0.1
  #
  # Updater gemspec.
  # Added classes Encoder and DataBCB for user.

  #Version 1.1.1
  # List operations now returns a string instead of printing the methods of the webservice.
  # get_last_value in BCB will return nil if the supplied code is invalid.
  # get_all_data_for_array will now return data for an invalid code, but will still prompt an error mesage.
  # added rspec tests, guarantying consistency
  # spec/valid_certificate contains a certificate which is valid at this moment (2016-11-22)

  #Version 1.1.2
  # Now get_all_data_for_array also expects a valid date in the format dd/MM/YYYY.


  #Version 1.1.3
  # Removed the removal of '.' character from value, it was actually losing data.
  # Changed DataBCB class name to Data_bcb, to keep with the standard snake case.
  # updated spec tests accordingly.  

  #Version 1.2.3
  # Added HTTP compression to Savon requests.

  #Version 1.3.3
  # get_all_data_for_array extracts data now as bulk, in order to make better use of the compression.

  #Version 1.4.3
  # get_all_data_for_array now handles different periodicities for any ammount of codes.

  #Version 1.5.3
  # adds flag in data to mark seasonally adjusted data
  # adds detection for seasonally adjusted data

  #Version 1.5.4
  # removed encoding vor day, month and year, as they can be integers and, therefore, haven't encoding

  #Version 1.5.5
  # promoted small change in order to handle a weird date style which BCB uses (i.e 01.2010.1900)

	#Version 1.5.6
	# fixes identification and handling of seazonaly adjusted data points.

	#Version 1.6.7
	# Treats exception caused by the character '&' on Nokogiri conversion.
	# Correctly identifies and classifies seasonally adjusted data.
	#
	# Adds verifications of validity for data-type.
	# Changes tests in order to incorporate validity detection.

	#Version 1.7.7
	# Adds support for max and minimun data for queries.

	#Version 1.8.7
	# Improves the way the gem deals with no data in interval result. Returning an empty array, 
	#		instead of an error.

	#Version 1.8.8
	# Forces conversion of error to string.

	#Version 1.9.8
	# Improves logging by adding trace.

	#Version 1.10.0
	# Agressively handles connection errors with BCB webservice, due to detecting a huge
	# 	ammount of hangups and such and such erros whilst using the gem.

	#Version 1.10.1
	# Rolling back on trying to retry every miss on the webservice and just handling errors apropriatelly.
	
	#Version 1.10.2
	# Adds "Socket closed" error to last value expcetion handling.

	#Versuib 1.11.0
	# Refactors and simplifies interactions with target webservice. Methods no longer return nil,
	#		but an invalid Data_bcb object.
end
