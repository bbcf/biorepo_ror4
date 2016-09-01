class User < ActiveRecord::Base
#attr_accessible :firstname, :name, :email, :key, :unit, :allunits
has_many :projects
has_many :measurements

has_and_belongs_to_many :groups
has_and_belongs_to_many :labs

  def run_download_job h_files, s_name, lab_id
    logger.debug('FU: run_download_job')
    job = Delayed::Job.enqueue DownloadFileJob.new(self.id, h_files, s_name, lab_id), :queue => 'download'
  end

  def download h_files, s_name, lab_id
    logger.debug('FU: download')

  end
end
