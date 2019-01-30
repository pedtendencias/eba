require "spec_helper"
require 'date'

describe Eba do
  it "has a version number" do
    expect(Eba::VERSION).not_to be nil
  end

  context "when you receive a certificate" do
    before :all do
      @eba = BCB.new('./spec/valid_certificate/cert.crt', 
										 './spec/valid_certificate/ca.crt')
    end

    it "it has a list of operations" do
      operations = @eba.list_operations
      expect(operations != nil).to eq(true)
    end

    context "and requests the last value for an series" do
      # As of 2016-11-22 98526 was an invalid series.
      before :all do
				@valid_series = 22815 
				@seasonally_adjusted = 24364 	
        @invalid_series = 98526 
      end
      
      context "but the requested series is invalid" do
				before :all do
				  @data_object = @eba.get_last_value(@invalid_series)
				end

        it "is a Data_bcb object" do
				  expect(@data_object.class.to_s).to eq('Data_bcb')
        end

				it "is not valid" do
					expect(@data_object.is_valid?).to eq(false)
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
					expect(@data_object.date.match('[0-9]+\/[0-9]+\/[0-9]+'))
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
					expect(@data_object.date.match('[0-9]+\/[0-9]+\/[0-9]+'))
				end
      end
    end

    context "and requests blocks of data" do
      before :all do
        @valid_series = 22815
        @valid_unseasoned_series = 24364
        @invalid_series = 98526 
				@starting_date = "01/10/2016"
				@ending_date = "02/11/2017"
      end

			context "using a valid series with an empty interval" do
				it "returns an empty array" do
					array = [@valid_series, @valid_unseasoned_series] 
          @data_result = @eba.get_all_data_for_array(array, "01/01/1900", "01/01/1901")

					expect(@data_result.length).to eq(0)
				end
			end

      context "using two valid series" do
        before :all do
				  array = [@valid_series, @valid_unseasoned_series] 

          @data_result = @eba.get_all_data_for_array(array, @starting_date, @ending_date)
					@data_object = @data_result[0]
        end

				context "its result" do
					it "has no nils" do
						expect(@data_result.include? nil).to eq(false)
						expect(@data_result.size > 1). to eq(true)
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
				end
		
				it "has no nils" do
					expect(@data_result.include? nil).to eq(false)
				end			

				it "has more than one result" do
					expect(@data_result.size > 1).to eq(true)
				end
		
				context "its data points" do
					before :all do
						@data_point = @data_result[Random.rand(@data_result.size)]
					end

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

			context "the requested range is out of bounds" do
				it "can properly handle the situation" do
					begin
						data_result = @eba.get_all_data_for_array([@valid_series1], @starting_date, '01/01/2300')
					rescue => e
						data_result = nil
					end
					
					expect(data_result != nil).to eq(true)
					expect(data_result.class.to_s.downcase).to eq('array')
					expect(data_result.size).to eq(0)
				end
			end
    end
  end
end
