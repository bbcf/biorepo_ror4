  class SaveFileJob < Struct.new(:fu_id, :url, :lab_id)
#    def enqueue(job)
#      job.delayed_reference_id = fu_id
#      job.delayed_reference_type = 'BiorepoiRor4::File' #??????
#      job.save!
#    end

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
      update_status('failure')
    end
    
    def failure(job)

    end

    def perform
     # measurement = BiorepoRor4::Measurement.find measurement_id
     file = Fu.find fu_id
     update_status('uploading')
     file.upload url, lab_id
#     raise StandardError.new("Failed to save file #{file.name} for measurement with id: #{file.measurement.id} ") unless file.upload(url)
    end


   private

    def update_status(status)
      file = Fu.find fu_id
      file.status = status
      file.save!
    end
  end
