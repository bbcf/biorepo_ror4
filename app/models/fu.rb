class Fu < ActiveRecord::Base

#  has_and_belongs_to_many :measurements
  has_many :measurements

  def run_upload_job
    logger.debug('FU: run_upload_job')
    job = Delayed::Job.enqueue SaveFileJob.new(self.id), :queue => 'upload'
    # job = Delayed::Job.enqueue SaveFileJob.new(self.id)
    self.update_attributes(:delayed_job_id => job.id, :status => 'enqueued')
    # flash[:notice] = "File is put to queue for upload."
    # redirect_to project_path
  end
end
