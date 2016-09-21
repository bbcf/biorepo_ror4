class Fu < ActiveRecord::Base

#  has_and_belongs_to_many :measurements
  has_many :measurements

  def run_upload_job url, lab_id
    logger.debug('FU: run_upload_job')
    job = Delayed::Job.enqueue SaveFileJob.new(self.id, url, lab_id), :queue => 'upload'
    self.update_attributes(:delayed_job_id => job.id, :status => 'enqueued')
    # redirect_to project_path
  end

def upload url, lab_id
    # upload file to tmp folder, move to archive with sha2 name
    lab = Lab.find(lab_id)
    tmp_upload_dir = APP_CONFIG[:data_path] + APP_CONFIG[:tmp_upload_dir] + '/' + lab.name
    Dir.mkdir(tmp_upload_dir) if !Dir.exists?(tmp_upload_dir)
    tmp_upload_path = tmp_upload_dir + '/' + self.filename
    download_cmd = "wget -O #{tmp_upload_path} '#{url}'"
    `#{download_cmd}`
    sha2 = Digest::SHA2.file(tmp_upload_path).hexdigest

    folder = sha2[0..1]
    upload_dir = APP_CONFIG[:data_path] + APP_CONFIG[:upload_dir] + '/'
    # data/upload/c3 where c3 is :path - 2 first letter of sha2
    full_upload_dir = upload_dir + folder
    logger.debug('UPLOAD: ' + full_upload_dir.to_s)

    # create directory if it is not existing
    if !Dir.exists?(full_upload_dir)
      Dir.mkdir(full_upload_dir)
    end
    # filename is in the parameters
    # original_filename = url.gsub('&', '_').gsub(':', '_').gsub('/', '_').gsub('?', '').gsub('\\', '')

    FileUtils.move tmp_upload_path, (full_upload_dir + '/'+ sha2)
    path = '/' + folder
    old_file = Fu.where(:sha1 => sha2).first
    if old_file
        self.measurements.first.update(:fu_id => old_file.id)
        self.destroy
    else
        self.update(:sha1 => sha2, :path => path)
    end
    # File.symlink (upload_dir + sha2), (file_path)
  end


end
