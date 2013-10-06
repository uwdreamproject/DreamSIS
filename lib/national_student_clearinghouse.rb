require 'net/sftp'

=begin
Coordinates the automated submission, retrieval and processing of data with the National Student Clearinghouse (NSC). The NSC contains enrollment and graduation records for nearly every college in the country. Outreach programs and schools can submit batch queries to the clearinghouse via SFTP to monitor the postsecondary outcomes of their students.
=end
class NationalStudentClearinghouse

  NSC_FTP_HOST = "ftps.nslc.org"
  
  def initialize(clearinghouse_request)
    @request = clearinghouse_request
    @customer = @request.customer
    @participants = @request.participants || []
    
    raise Exception.new("Empty participant set") if @participants.empty?
    @customer.validate_clearinghouse_configuration = true
    raise Exception.new("Invalid customer record") unless @customer.valid?
    
    self
  end
  
  # Returns the filename that will be, or was, used for this submission/retrieval.
  def send_filename
    f = []
    f << @customer.clearinghouse_customer_number.to_s
    f << "send"
    f << @request.created_at.to_date.to_s(:number)
    f << "TEST" if RAILS_ENV == 'development'
    f.join("_") + ".txt"
  end
  
  def record_count
    @record_count
  end
  
  def request
    @request
  end
  
  # Generates the file for submitting.
  def generate_file!
    begin
      @record_count = 0
      file = File.open(local_send_file_path, "w")
      file.write header_row + "\n"
      file.write dreamsis_control_row + "\n"
      request.participants.each do |p| 
        row = participant_row(p); 
        unless row.nil?
          file.write row + "\n"
          @record_count += 1
        end
      end
      file.write footer_row + "\n"
      request.update_attribute(:number_of_records_submitted, @record_count)
    rescue IOError => e
      #some error occur, dir not writable etc.
    ensure
      file.close unless file == nil
    end
    local_send_file_path
  end
  
  # Submits the file to the home directory on the SFTP server
  def submit_file!
    generate_file!
    return false if record_count < 1
    
    Net::SFTP.start(NSC_FTP_HOST, @customer.clearinghouse_customer_number, :password => @request.decrypted_ftp_password) do |sftp|
      sftp.upload!(local_send_file_path, remote_send_file_path, :progress => NSCUploadHandler.new(self))
    end
  end
  
  # When a results report is returned in the /receive folder on the NSC server, there is no way to tell
  # what request file it is related to until you download it. This method retrieves all the files that 
  # exist in the /recieve folder and then processes them.
  def retrieve_files!(process_after_retrieving = true)
    Rails.logger.info { "NSC retrieve request starting" }
    Rails.logger.info { " -- #{process_after_retrieving ? "will" : "will not"} process files after retrieving" }
    Net::SFTP.start(NSC_FTP_HOST, @customer.clearinghouse_customer_number, :password => @request.decrypted_ftp_password) do |sftp|
      
      Rails.logger.info { "Connected to server, getting dir list" }
      sftp.dir.foreach(remote_receive_file_path) do |entry|
        Rails.logger.info { "Found #{entry.name} - downloading..." }
        sftp.download!("#{remote_receive_file_path}/#{entry.name}", File.join("#{local_receive_file_path}", entry.name))
      end
    end
    
    Rails.logger.info { "Got files, requesting they be processed." }
    process_files!(local_receive_file_path) if process_after_retrieving
  end
  
  # Deletes the requested files from the /receive directory on the SFTP server.
  def delete_retrieved_files!(file_names)
    files_names = [file_names] unless file_names.is_a?(Array)
    Net::SFTP.start(NSC_FTP_HOST, @customer.clearinghouse_customer_number, :password => @request.decrypted_ftp_password) do |sftp|
      for file_name in file_names
        sftp.remove("#{remote_receive_file_path}/#{file_name}")
      end
    end
  end
  
  # Based on the name of the detail file in the file path provided, this method will determine the
  # names of the other two files (the control report and the aggregate report) that are related.
  # 
  # If the detail report is 600209_T112660.201305130930_DA.csv, then:
  # * the aggregate report is 600209_T112660aggrrpt.201305130930_DA.csv
  # * the control report is 600209_T112660cntlrpt.201305130930_DA.htm
  def interpolate_file_names_from_detail_file_path(detail_file_path)
    detail_file_name = File.basename(detail_file_path)
    match = detail_file_name.match(/(\d+)_([A-Z]\d+).(\d+)_DA/)
    aggrrpt_file_name = "#{match[1]}_#{match[2]}aggrrpt.#{match[3]}_DA.csv"
    cntlrpt_file_name = "#{match[1]}_#{match[2]}cntlrpt.#{match[3]}_DA.htm"
    [detail_file_name, aggrrpt_file_name, cntlrpt_file_name]
  end
  
  
  protected
  
  def local_send_file_path
    path = "tmp/nsc/#{@request.id.to_s}/#{send_filename}"
    FileUtils.mkdir_p(File.dirname(path)) unless File.exists?(File.dirname(path))
    path
  end
  
  def remote_send_file_path
    "/Home/#{@customer.clearinghouse_customer_number.to_s}/#{send_filename}"
  end

  def local_receive_file_path
    path = "tmp/nsc/#{object_id.to_s}/receive"
    FileUtils.mkdir_p(File.dirname("#{path}/touch.txt")) unless File.exists?(File.dirname("#{path}/touch.txt"))
    path
  end
  
  def remote_receive_file_path
    "/Home/#{@customer.clearinghouse_customer_number.to_s}/receive"
  end
  
  def header_row
    elements = [
      "H1",
      @customer.clearinghouse_customer_number.to_s.rjust(6),
      "00",
      @customer.name.to_s[0..39],
      Time.now.to_date.to_s(:number),
      "DA",
      "S",
      "", "", "", "", ""
    ]
    strip_illegal_characters(elements.join("\t"))
  end
  
  # Because there's no way to know which /receive file relates to what sent file, DreamSIS adds a
  # data row to the request with a special return identifier that can be used to link the results
  # report back to the request that generated it.
  def dreamsis_control_row
    elements = [
      "D1",
      "",
      "DreamSISControl",
      "",
      "Aaa",
      "",
      "19950101",
      "20120901",
      "",
      "",
      "00",
      "DreamSIS-ClearinghouseRequest#{request.id.to_s}"
    ]
    strip_illegal_characters(elements.join("\t"))
    
  end
  
  def footer_row
    elements = [
      "T1",
      record_count.to_s,
      "", "", "", "", "", "", "", "", "", ""
    ]
    strip_illegal_characters(elements.join("\t"))
  end
  
  # Constructs a "D1" data row for the participant. Returns nil if there is no date of birth or 
  # grad_year defined (without these values, the search will fail).
  def participant_row(p)
    return nil if p.birthdate.nil? || p.grad_year.nil?
    elements = [
      "D1",
      "",
      p.firstname.to_s[0..19],
      p.middlename.to_s[0..0],
      p.lastname.to_s[0..19],
      p.suffix.to_s[0..4],
      p.birthdate.to_s(:number),
      "#{p.grad_year}0901",
      "",
      "",
      "00",
      p.id.to_s
    ]
    strip_illegal_characters(elements.join("\t"))
  end
  
  # Processes the files that were downloaded from the /recive subdiretory on the server.
  def process_files!(local_path)
    Rails.logger.info { "Processing files from #{local_path}" }
    Dir.glob(File.join(local_path, "*")).each do |file_path|
      process_detail_file(file_path) if file_path.ends_with?("_DA.csv") && !file_path.include?("aggrrpt")
    end
  end
  
  # Looks in the provided detail file for a DreamSIS control record to identify which
  # ClearinghouseRequest this result is for. Then calls #process_detail_file on that
  # record and passes in this file path.
  def process_detail_file(file_path)
    Rails.logger.info { "Processing detail file #{file_path}" }
    if match = File.read(file_path).match(/DreamSIS-ClearinghouseRequest(\d+)/i)
      Rails.logger.info { "Matched DreamSIS indicator in file contents - request ID is #{match[1].to_i}" }
      cr = ClearinghouseRequest.find(match[1].to_i)
      cr.process_detail_file(file_path)
    else 
      Rails.logger.info { "Did not match DreamSIS indicator in file contents! Quitting." }
    end
  end
  
  # NSC does not allow quotes, commas, or periods in any fields.
  def strip_illegal_characters(str)
    str.gsub(/[,'".]/, "")
  end
  
end

# Handles custom events for the uploader used above.
class NSCUploadHandler
  def initialize(nsc)
    @nsc = nsc
  end
  
  def on_open(uploader, file)
    Rails.logger.info { "starting upload: #{file.local} -> #{file.remote} (#{file.size} bytes)" }
  end

  def on_finish(uploader)
    Rails.logger.info { "finished." }
    @nsc.request.update_attributes(
      :submitted_at => Time.now, 
      :submitted_filename => @nsc.send_filename, 
      :number_of_records_submitted => @nsc.record_count
    )
  end
end

# Handles custom events for the downloader used above.
class NSCDownloadHandler
  def initialize(nsc)
    @nsc = nsc
  end
    
  def on_open(downloader, file)
    Rails.logger.info { "starting download: #{file.remote} -> #{file.local} (#{file.size} bytes)" }
  end

  def on_finish(downloader)
    Rails.logger.info { "finished." }
    # @nsc.request.update_attributes(
    #   :retrieved_at => Time.now
    # )
  end
end
