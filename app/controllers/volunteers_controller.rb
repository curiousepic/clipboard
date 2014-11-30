class VolunteersController < ApplicationController
  before_action :client

  def new
    @volunteer = Volunteer.new
  end

  def sfcreate
    #needs to look at form to obtain params
    @firstname = sfcreate_params[:name_first]
    @lastname = sfcreate_params[:name_last]
    @email = sfcreate_params[:email]
    @existing_records = []
    @matching_names = []
    @existing = @client.query("select Id from contact where email = '#{@email}'")
    @existing.current_page.each do |o|
      @existing_records << o.Id
    end

    @existing_records.each do |o|
      @matching_names << client.find('Contact', "#{o}")
    end
    if @matching_names.empty?
      sf_id = @client.create!('Contact', FirstName: sfcreate_params[:name_first], LastName: sfcreate_params[:name_last], Email: sfcreate_params[:email] )
      Volunteer.find_or_create_by!(email: sfcreate_params[:email]) do |volunteer|
        volunteer.name_first = sfcreate_params[:name_first]
        volunteer.name_last = sfcreate_params[:name_last]
        volunteer.sf_contact_id = sf_id
      end

    else
      sf_id = @matching_names[0][:Id]
      puts 'We already have someone in the database with that email'
    end

    sf_shift_id = @client.create!('SEEDS_Volunteer_Shifts__c', Volunteer_Name__c: sf_id, Year__c: Time.now.year, Shift_Status__c: "Confirmed" )
    sf_shift_detail_id = @client.create!('SEEDS_Vol_Shift_Detail__c', Shift__c: sf_shift_id, Shift_Hours__c: 3.00, Date_Text__c: Date.today.strftime("%A %B %d"))
    new_shift = Shift.find_or_create_by!(sf_shift_detail_id: sf_shift_detail_id ) do |shift|
      shift.sf_contact_id = sf_id
      shift.date = Date.today.to_s
      shift.hours = 3.00
      shift.status = "Confirmed"
      shift.year = Time.now.year
      shift.sf_volunteer_shift_id = sf_shift_id
      shift.sf_shift_detail_id = sf_shift_detail_id
      shift.volunteer = Volunteer.find_by(sf_contact_id: sf_id)

    end

    redirect_to shifts_index_path
  end

  private

  def sfcreate_params
    params.require(:volunteer).permit(:name_first, :name_last, :email)
  end
end




