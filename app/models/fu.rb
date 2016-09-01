class Fu < ActiveRecord::Base

#  has_and_belongs_to_many :measurements
  has_many :measurements

  def run_upload_job url, lab_id, raw
    logger.debug('FU: run_upload_job')
    job = Delayed::Job.enqueue SaveFileJob.new(self.id, url, lab_id, raw), :queue => 'upload'
    # job = Delayed::Job.enqueue SaveFileJob.new(self.id)
    self.update_attributes(:delayed_job_id => job.id, :status => 'enqueued')
    # flash[:notice] = "File is put to queue for upload."
    # redirect_to project_path
  end

def upload url, lab_id, raw
    # save file
    lab = Lab.find(lab_id)
    folder = raw ? "/raw" : "/processed"
    lab_upload_dir = APP_CONFIG[:upload_dir] + '/' + lab.name
    upload_dir = APP_CONFIG[:upload_dir] + '/' + lab.name + folder
    logger.debug('UPLOAD: ' + upload_dir.to_s)
    # upload file to tmp folder, copy to archive with sha2 name
    # and delete from tmp folder
    tmp_upload_dir = APP_CONFIG[:tmp_upload_dir] + '/' + lab.name
    Dir.mkdir(tmp_upload_dir) if !Dir.exists?(tmp_upload_dir)

    if !Dir.exists?(lab_upload_dir)
      Dir.mkdir(lab_upload_dir)
      Dir.mkdir(lab_upload_dir + '/raw')
      Dir.mkdir(lab_upload_dir + '/processed')
    end
    # filename is in the parameters
    # original_filename = url.gsub('&', '_').gsub(':', '_').gsub('/', '_').gsub('?', '').gsub('\\', '')
    tmp_upload_path = tmp_upload_dir + '/' + self.filename
    download_cmd = "wget -O #{tmp_upload_path} '#{url}'"
    `#{download_cmd}`

    sha2 = Digest::SHA2.file(tmp_upload_path).hexdigest
    FileUtils.move tmp_upload_path, (upload_dir + '/'+ sha2)
    self.update(:sha1 => sha2, :path => upload_dir)
    # File.symlink (upload_dir + sha2), (file_path)
  end


end
