require 'rubygems'
require 'zip'

class User < ActiveRecord::Base
#attr_accessible :firstname, :name, :email, :key, :unit, :allunits
has_many :projects
has_many :measurements

has_and_belongs_to_many :groups
has_and_belongs_to_many :labs

  def run_download_job h_files, sample_name, lab_id
    logger.debug('FU: run_download_job')
    job = Delayed::Job.enqueue DownloadFileJob.new(self.id, h_files, sample_name, lab_id), :queue => 'download'
  end

  def download h_files, sample_name, lab_id
    logger.debug('FU: download')
    # from where take files
    input_folder =  APP_CONFIG[:data_path] + APP_CONFIG[:upload_dir] 

    time = Time.now
    # date = time.year + time.month + time.day
    date = time.strftime("%Y%m%d")
    zipfile_name = date + '_' + self.name + '_' + sample_name + '.zip'
    zipfile_path = APP_CONFIG[:data_path] + APP_CONFIG[:download_dir] + '/'
    zipfile = zipfile_path + zipfile_name
    logger.debug('zipfile = ' + zipfile)

    Zip::File.open(zipfile, Zip::File::CREATE) do |zip|
        h_files.keys.each do |fid|
            # get the real file name. Now it is sha2, 
            # but it should be changed to original filename
            filename = h_files[fid].split('/').last
        # Two arguments:
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
            zip.add(filename, input_folder + h_files[fid])
        end
        zip.get_output_stream("myFile") { |os| os.write "myFile contains just this" }
    end

  end
end
