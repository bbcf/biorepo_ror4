  class DownloadFileJob < Struct.new(:download_id, :h_files,  :zipfile_name)

    def success(job)
      # send email notification
      update_status('success')
    end

    def error(job, exception)
      # send email notification
      # lines = job.last_error.split("\n")
      # lines = lines.join("\\n")
      # file = Fu.find fu_id
      # file.update_attributes(:error => lines, :status_id => 'failure')
      update_status('error')
    end
    
    def failure(job)
      update_status('failure')
      line = job.last_error.split("\n").first
      @dl.update_attributes(:error => line)

    end

    def perform
     @dl = Download.find download_id
     update_status('running')
     @dl.download h_files, zipfile_name
#     raise StandardError.new("Failed to save file #{file.name} for measurement with id: #{file.measurement.id} ") unless file.upload(url)
    end

   private

    def update_status(status)
      # download = Download.find downlad_id
      @dl.status = status
      @dl.save!
    end
  end
