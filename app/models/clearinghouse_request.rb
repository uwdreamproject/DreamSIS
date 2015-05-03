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
  validate :overlimit_protection
  
  belongs_to :customer
  belongs_to :user, :class_name => "User", :foreign_key => "created_by"
  
  serialize :participant_ids

  serialize :filenames
  
  scope :awaiting_retrieval, :conditions => "submitted_at IS NOT NULL AND retrieved_at IS NULL"
  
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
    @participants ||= Participant.find(:all, :conditions => ["`id` IN (?)", participant_ids])
  end
  
  def plain_ftp_password=(pwd)
    return false if pwd.blank?
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
  
  # Returns true if there is a valid FTP password stored and the file hasn't yet been submitted.
  def submittable?
    !ftp_password.blank? && !submitted?
  end
  
  # Returns true if there is a valid FTP password and the file hasn't yet been retreived.
  def retrievable?
    !ftp_password.blank? && !retrieved?
  end
  
  def nsc
    @nsc ||= NationalStudentClearinghouse.new(self)
  end
  
  # Use a custom logger for logging the relevant activities for this request.
  def logger
    return @local_logger if @local_logger
    FileUtils.mkdir_p(File.dirname(log_path)) unless File.exists?(File.dirname(log_path))

    if API_KEYS["logentries"]
      token = API_KEYS["logentries"][Rails.env]["nsc"]
      @local_logger = Le.new(token, :debug => false, :local => log_path, :ssl => true, :tag => true)
    else
      @local_logger = Logger.new(log_path)
    end
    @local_logger
  end

  # Returns the path to the local log file.
  def log_path
    "#{Rails.root}/tmp/nsc/#{id.to_s}/processing_log.log"    
  end
  
  # Creates a token to prefix all log entries with, for easy retrieval in comingled logs.
  def log_prefix
    "[nsc/#{Customer.url_shortcut}/#{id.to_s}] "
  end
  
  # Returns the full contents of the log for this request.
  def log_contents
    if API_KEYS["logentries"]
      account_key = API_KEYS["logentries"][Rails.env]["account_key"]
      log_set = API_KEYS["logentries"][Rails.env]["log_set"]
      log_name = "nsc"
      url = "https://pull.logentries.com/#{account_key}/hosts/#{log_set}/#{log_name}/?filter=#{log_prefix}"
      Rails.logger.debug { "Fetching log from #{url}" }
      open(url).read
    else
      File.read(log_path)
    end
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
      logger.info { log_prefix + "process_detail_file(#{file_path})" }
      participant_ids = []
      CSV.foreach(file_path, :headers => true) do |row|
        attrs = row.to_hash
        logger.info { log_prefix + " " }
        logger.info { log_prefix + "Processing row: " + attrs.inspect }
        if attrs["Record Found Y/N"] == "Y"
          participant_id = attrs["Requester Return Field"]
          participant_ids << participant_id
          participant = Participant.find(participant_id) rescue nil
          if participant
            logger.info { log_prefix + "  -> MATCHED to participant id #{participant.id}" }
            participant.update_attribute(:clearinghouse_record_found, true)
          else
            logger.info { log_prefix + "  -> PARTICIPANT NOT FOUND" }
            next
          end
          if attrs["Graduated?"] == "Y"
            create_college_degree_from(attrs, participant_id)
          else
            create_college_enrollment_from(attrs, participant_id)
          end
        else
          logger.info { log_prefix + "  -> NO NSC RESULT RETURNED" }
        end
      end
      logger.info { log_prefix + "Done - updating request metadata" }
      update_attributes(
        :retrieved_at => Time.now,
        :number_of_records_returned => participant_ids.uniq.size
      )
    end
    store_files(file_path)
    store_log_file_permanently!
  end
  
  # Performs cleanup and "closes" this request.
  # 
  # 1. Delete the files from the server if needed.
  # 2. Delete FTP password
  def close
    logger.info { log_prefix + "Closing this request" }
    delete_sftp_files
    update_attribute(:ftp_password, nil)
  end

  # Returns an array of the files stored for this request.
  def files
    filenames || []
  end
  
  def file_url(file_id)
    if file_id == :submission
      filename = nsc.send_filename
      nsc.generate_file! unless files.include?(filename)
    else
      filename = files[file_id.to_i]
      raise KeyError.new("File index is not in the list of stored files") unless filename
    end
    uploader.retrieve_from_store!(filename)
    uploader.url
  end
  
  # Returns the instance of ClearinghouseRequestUploader to use for storing files on S3.
  def uploader
    @uploader ||= ClearinghouseRequestUploader.new(id)
  end
  
  # Takes a local file, stores it in S3 using CarrierWave, and stores the filename in the "filenames" array.
  def store_permanently!(local_path)
    uploader.store!(File.open(local_path))
    self.filenames ||= []
    self.filenames << File.basename(local_path)
    self.save!
  end
  
  # Quickly downloads the latest log contents and uploads them for permanent storage
  def store_log_file_permanently!
    f = Tempfile.new("processing_log")
    f.write(log_contents)
    f.close
    store_permanently!(f.path)
  end

  protected
  
  # Creates a CollegeDegree record from the attributes provided. 
  def create_college_degree_from(attrs, participant_id)
    logger.info { log_prefix + "  -> Creating CollegeDegree record" }
    cd = CollegeDegree.create(
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
    logger.info { log_prefix + "     #{cd.inspect}" }
    logger.info { log_prefix + "     Errors: #{cd.errors.messages.inspect}" } unless cd.valid?
    cd
  end
  
  # Creates a CollegeEnrollment record from the attributes provided. 
  def create_college_enrollment_from(attrs, participant_id)
    logger.info { log_prefix + "  -> Creating CollegeEnrollment record" }
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
    logger.info { log_prefix + "     #{ce.inspect}" }
    logger.info { log_prefix + "     Errors: #{ce.errors.messages.inspect}" } unless ce.valid?
    ce
  end

  # Moves the detail file and its two related files to permanent storage in 
  # files/clearinghouse_request/:id/request. Returns a list of the files that
  # were copied. If the related files don't exist alongside the detail file
  # (e.g., if the detail file was provided manually and not automatically fetched),
  # it won't return those in the list.
  def store_files(detail_file_path)
    destination_dir = File.join("files", "clearinghouse_request", id.to_s, "receive")
    logger.info { log_prefix + "Storing files for later use(#{detail_file_path}) to #{destination_dir}" }
    source_dir = File.dirname(detail_file_path)
    update_attribute(:detail_report_filename, File.basename(detail_file_path))
    FileUtils.mkdir_p(destination_dir)
    all_files = nsc.interpolate_file_names_from_detail_file_path(detail_file_path)
    copied_files = []
    for file_name in all_files
      source_path = File.join(source_dir, file_name)
      if File.exists?(source_path)
        store_permanently!(source_path)
      end
    end
    logger.info { log_prefix + "done" }
    files
  end
  
  # Tells the nsc object to delete the files related to this request.
  def delete_sftp_files
    logger.info { log_prefix + "Deleting related sftp files" }
    return false if detail_report_filename.blank? || ftp_password.blank?
    all_files = nsc.interpolate_file_names_from_detail_file_path(detail_report_filename)
    nsc.delete_retrieved_files!(all_files)
  end

  private
  
  def aes_key
    key = API_KEYS["omniauth"]["twitter"]["secret"]
  end

end
