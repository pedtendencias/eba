require "spec_helper"
require 'date'

describe Eba do
  it "has a version number" do
    expect(Eba::VERSION).not_to be nil
  end

  context "when you receive a certificate" do
    before :all do
      @eba = BCB.new('/valid_certificate/pubkey.pem')
    end

    it "it has a list of operations" do
      operations = @eba.list_operations
      expect(operations != nil).to eq(true)
    end

    context "and requests the last value for an series" do
      # As of 2016-11-22 98526 was an invalid series.
      before :all do
				@valid_series = 7900  
				@seasonally_adjusted = 24364 	
        @invalid_series = 98526 
      end
      
      context "but the requested series is invalid" do
				before :all do
				  @data_object = @eba.get_last_value(@invalid_series)
				end

        it "is nil" do
				  expect(@data_object == nil).to eq(true)
        end
      end

      context "and the requested series is valid and seazonaly adjusted" do
				before :all do
				  @data_object = @eba.get_last_value(@seasonally_adjusted)
				end

        it "is identified as seasonally adjusted" do
				  expect(@data_object.seasonally_adjusted).to eq(true)
				end
	
				it "has not ' - com ajuste sazonal' in its name" do
					expect(@data_object.name.include? " - com ajuste sazonal").to eq(false)
				end

				it "is not nil" do
          expect(@data_object != nil).to eq(true)
        end

        it "is valid" do
				  expect(@data_object.is_valid?).to eq(true)
        end
      end

      context "and the requested series is a valid one" do 
				before :all do
				  @data_object = @eba.get_last_value(@valid_series)
				end
	
				it "is identified as non seazonally adjusted" do
				  expect(@data_object.seasonally_adjusted).to eq(false)
				end

				it "is not nil" do
          expect(@data_object != nil).to eq(true)
        end

        it "is valid" do
					expect(@data_object.is_valid?).to eq(true)
				end
      end
    end

    context "and requests blocks of data" do
      before :all do
        @valid_series = 7824 
        @valid_unseasoned_series = 24364
        @invalid_series = 98526 
				@starting_date = "01/10/2016"
      end

      context "using two valid series" do
        before :all do
				  array = [@valid_series, @valid_unseasoned_series] 
          @data_result = @eba.get_all_data_for_array(array, @starting_date)
					@data_object = @data_result[0]
        end

				context "its result" do
					it "has no nils" do
						expect(@data_result.include? nil).to eq(false)
					end	
			
					it "is valid" do
						expect(@data_object.is_valid?).to eq(true)
					end
				end
      end

			context "using a single valid serie which is seasonally adjusted" do
				before :all do
					array = [@valid_unseasoned_series]
					@data_result = @eba.get_all_data_for_array(array, @starting_date)	
					@data_point = @data_result[0]
				end
		
				it "has no nils" do
					expect(@data_result.include? nil).to eq(false)
				end			
		
				context "its data points" do
					it "are valid" do
						expect(@data_point.is_valid?).to eq(true)
					end
	
					it "are identified as seasonally adjusted" do
						expect(@data_point.seasonally_adjusted).to eq(true)
					end					
				end
			end

      context "one of the requested series is invalid" do
        before :all do
          @data_result = @eba.get_all_data_for_array([@valid_series1, @invalid_series], @starting_date)
        end

        it "has no nils" do
          expect(@data_result.include? nil).to eq(false)
        end
      end
    end
  end
end
