module Eba
  # For documentation purposes:
  # VERSION = mm.dd.ff.hh
  # mm - commits on master
  # dd - commits on development
  # ff - commits on feature
  # hh - commits on hotfix

  VERSION = "1.0.1.2"

  #Version 1.0.0.1
  #
  # Updater gemspec.
  # Added classes Encoder and DataBCB for user.

  #Version 1.0.1.1
  # List operations now returns a string instead of printing the methods of the webservice.
  # get_last_value in BCB will return nil if the supplied code is invalid.
  # get_all_data_for_array will now return data for an invalid code, but will still prompt an error mesage.
  # added rspec tests, guarantying consistency
  # spec/valid_certificate contains a certificate which is valid at this moment (2016-11-22)

  #Version 1.0.1.2
  # Now get_all_data_for_array also expects a valid date in the format dd/MM/YYYY.


  #Version 1.0.1.3
  # Removed the removal of '.' character from value, it was actually losing data.
  # Changed DataBCB class name to Data_bcb, to keep with the standard snake case.
  # updated spec tests accordingly.  
end
