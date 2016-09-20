require 'rubygems'
require 'zip'
class Download < ActiveRecord::Base

  def run_download_job h_files, zipfile_name
    logger.debug('D: run_download_job')
    job = Delayed::Job.enqueue DownloadFileJob.new(self.id, h_files, zipfile_name), :queue => 'download'
    self.update_attributes(:delayed_job_id => job.id, :status => 'queued')
  end

  def download h_files, zipfile_name
    logger.debug('FU: download')
    # from where take files
    logger.debug ('H_FILES:' + h_files.to_s)

    zipfile_path = APP_CONFIG[:data_path] + APP_CONFIG[:download_dir] + '/'
    logger.debug('zipfile = ' + zipfile_path + zipfile_name)

    # incase this zip already exists
    i = 0
    new_zipfile_name = zipfile_name
    while (File.exists?(zipfile_path + new_zipfile_name))
        i = i + 1
        new_zipfile_name = zipfile_name.split('.zip').first + '_' + i.to_s + '.zip'
    end
    zipfile_name = new_zipfile_name
    self.update_attributes(:name => zipfile_name)

    zipfile = zipfile_path + zipfile_name
    Zip::File.open(zipfile, Zip::File::CREATE) do |zip|
        # h_files = Hash[*fus.map {|f| [f.path + '/' + f.sha1, f.filename]}.flatten]
        h_files.keys.each do |fpath|
            # get the real file name. Now it is sha2, 
            # but it should be changed to original filename
            filename = h_files[fpath]
        # Two arguments:
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
            input_folder =  APP_CONFIG[:data_path] + APP_CONFIG[:upload_dir] 
            zip.add(filename, input_folder + '/' + fpath)
        end
        zip.get_output_stream("myFile") { |os| os.write "myFile contains just this" }
    end

  end
end
