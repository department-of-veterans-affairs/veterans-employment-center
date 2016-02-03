require Rails.root.join("lib/custom_public_exceptions")
Rails.application.config.exceptions_app = CustomPublicExceptions.new(Rails.public_path)
