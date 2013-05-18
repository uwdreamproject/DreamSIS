require 'lib/national_student_clearinghouse'
require 'csv'

=begin
Coordinates the automated submission, retrieval and processing of data with the National Student Clearinghouse (NSC). The NSC contains enrollment and graduation records for nearly every college in the country. Outreach programs and schools can submit batch queries to the clearinghouse via SFTP to monitor the postsecondary outcomes of their students.

Relevant attributes on Customer:
* clearinghouse_customer_number
* clearinghouse_contract_start_date
* clearinghouse_number_of_submissions_per_year

==Customer account setup==
1. Customer inputs NSC customer ID number and SFTP password in Customer#edit.
2. Encrypt the customer ID and password using private key stored outside of version control. Do not store in ChangeLog.
3. Track the number of submissions per year allowed, as well as the annual start date for the contract.
=end
class ClearinghouseRequest < ActiveRecord::Base
  validates_presence_of :customer_id, :participant_ids
  validates_presence_of :ftp_password, :on => :create
  validate :overlimit_protection
  
  belongs_to :customer
  belongs_to :user, :class_name => "User", :foreign_key => "created_by"
  
  serialize :participant_ids
  
  named_scope :awaiting_retrieval, :conditions => "submitted_at IS NOT NULL AND retrieved_at IS NULL"
  
  attr_accessor :plain_ftp_password
  
  attr_protected :customer_id, :ftp_password
  
  # Returns the current "status" of this request.
  # 
  # new::       Not submitted yet
  # submitted:: Submitted but not retrieved
  # retrieved:: Retrieved results
  def status
    if submitted?
      return retrieved? ? "retrieved" : "submitted"
    else
      "new"
    end
  end
  
  # Store the participants ID's for these participants in the +participant_ids+ attribute.
  # This also populates the +@participants+ instance variable.
  def participants=(new_participants)
    @participants = new_participants
    self.participant_ids = new_participants.collect(&:id)
  end
  
  # If +@participants+ instance variable is assigned, return that. Otherwise, find all of the participants
  # identified by the collection in the +participant_ids+ attribute.
  def participants
    @participants ||= Participant.find(participant_ids)
  end
  
  def plain_ftp_password=(pwd)
    iv = AES.iv(:base_64)
    enc64 = AES.encrypt(pwd, aes_key, {:iv => iv})
    self.ftp_password = enc64
  end
  
  def decrypted_ftp_password
    AES.decrypt(ftp_password, aes_key)
  end
  
  # Returns true if the request has been submitted to the clearinghouse.
  def submitted?
    submitted_at.try(:past?)
  end
  
  # Returns true if the request has been retrieved and processed from the clearinghouse.
  def retrieved?
    return false unless submitted?
    retrieved_at.try(:past?)
  end
  
  def nsc
    @nsc ||= NationalStudentClearinghouse.new(self)
  end
  
  # Checks to see if this Customer is over the "limit" of submissions for the year and adds a validation
  # error to this record if so.
  def overlimit_protection
    reqs = customer.current_contract_clearinghouse_requests
    message = "has passed the allowed limit for clearinghouse submissions for current contract"
    errors.add(:customer_id, message) if reqs.size >= customer.clearinghouse_number_of_submissions_allowed
  end
  
  # Submit file to NSC.
  def submit!
    return false if participants.empty?
    return false unless valid?
    nsc.submit_file! if valid?
  end
  
  # Fetch returned file from +/receive+ directory and store in +tmp+ directory. Because the clearinghouse
  # has no way to link received files to sent files, this method simply pulls everything out of the
  # /receive directory and tries to process it.
  def retrieve!
    return false unless submitted?
    nsc.retrieve_files! # This will trigger these files for processing as well.
  end
  
  # Process a file that has been retrieved from the Clearinghouse.
  # 
  # 1. Open the file from the file system.
  # 2. For each row in the returned dataset, create a new CollegeEnrollment record (without importing 
  #    duplicates). Note the ClearinghouseRequest ID and that the source is "clearinghouse" (instead 
  #    of a manual entry by a user).
  # 3. Update +retrieved_at+.
  # 4. Count number of unique returned DreamSIS ID numbers in file and update number_of_records_returned.
  def process_detail_file(file_path)
    errors.add(:retrieved_at, "can only be retrieved once") and return false if retrieved?
    begin
      participant_ids = []
      FasterCSV.foreach(file_path, :headers => true) do |row|
        attrs = row.to_hash
        if attrs["Record Found Y/N"] == "Y"
          participant_id = attrs["Requester Return Field"]
          participant_ids << participant_id
          participant = Participant.find(participant_id)
          if attrs["Graduated?"] == "Y"
            create_college_degree_from(attrs, participant_id)
          else
            create_college_enrollment_from(attrs, participant_id)
          end
        end
      end
      update_attributes(
        :retrieved_at => Time.now,
        :number_of_records_returned => participant_ids.uniq.size
      )
    end
    store_files(file_path)
  end
  
  # Performs cleanup and "closes" this request.
  # 
  # 1. Delete the files from the server if needed.
  # 2. Delete FTP password
  def close
    delete_sftp_files
    update_attribute(:ftp_password, nil)
  end

  protected
  
  # Creates a CollegeDegree record from the attributes provided. 
  def create_college_degree_from(attrs, participant_id)
    CollegeDegree.create(
      :participant_id => participant_id,
      :institution_id => Institution.find_by_opeid(attrs["College Code/Branch"]).try(:id),
      :graduated_on => Date.parse(attrs["Graduation Date"]),
      :degree_title => attrs["Degree Title"],
      :major_1 => attrs["Degree Major 1"],
      :major_1_cip => attrs["Degree CIP 1"],
      :major_2 => attrs["Degree Major 2"],
      :major_2_cip => attrs["Degree CIP 2"],
      :major_3 => attrs["Degree Major 3"],
      :major_3_cip => attrs["Degree CIP 3"],
      :major_4 => attrs["Degree Major 4"],
      :major_4_cip => attrs["Degree CIP 4"],
      :source => "clearinghouse",
      :clearinghouse_request_id => self.id
    )    
  end
  
  # Creates a CollegeEnrollment record from the attributes provided. 
  def create_college_enrollment_from(attrs, participant_id)
    ce = CollegeEnrollment.create(
      :participant_id => participant_id,
      :institution_id => Institution.find_by_opeid(attrs["College Code/Branch"]).try(:id),
      :began_on => Date.parse(attrs["Enrollment Begin"]),
      :ended_on => Date.parse(attrs["Enrollment End"]),
      :enrollment_status => attrs["Enrollment Status"],
      :class_level => attrs["Class Level"],
      :major_1 => attrs["Enrollment Major 1"],
      :major_1_cip => attrs["Enrollment CIP 1"],
      :major_2 => attrs["Enrollment Major 2"],
      :major_2_cip => attrs["Enrollment CIP 2"],
      :source => "clearinghouse",
      :clearinghouse_request_id => self.id
    )
  end

  # Moves the detail file and its two related files to permanent storage in 
  # files/clearinghouse_request/:id/request. Returns a list of the files that
  # were copied. If the related files don't exist alongside the detail file
  # (e.g., if the detail file was provided manually and not automatically fetched),
  # it won't return those in the list.
  def store_files(detail_file_path)
    destination_dir = File.join("files", "clearinghouse_request", id.to_s, "receive")
    source_dir = File.dirname(detail_file_path)
    update_attribute(:detail_report_filename, File.basename(detail_file_path))
    FileUtils.mkdir_p(destination_dir)
    all_files = nsc.interpolate_file_names_from_detail_file_path(detail_file_path)
    copied_files = []
    for file_name in all_files
      source_path = File.join(source_dir, file_name)
      if File.exists?(source_path)
        FileUtils.cp_r(source_path, File.join(destination_dir, file_name))
        copied_files << file_name
      end
    end
    copied_files
  end

  # Tells the nsc object to delete the files related to this request.
  def delete_sftp_files
    return false if detail_report_filename.blank? || ftp_password.blank?
    all_files = nsc.interpolate_file_names_from_detail_file_path(detail_report_filename)
    nsc.delete_retrieved_files!(all_files)
  end

  private
  
  def aes_key
    config_file_path = File.join(ENV['SHARED_CONFIG_ROOT'] || "#{RAILS_ROOT}/config", "omniauth_keys.yml")
    omniauth_keys = YAML::load(ERB.new((IO.read(config_file_path))).result)
    key = omniauth_keys["twitter"]["secret"]
  end

end
