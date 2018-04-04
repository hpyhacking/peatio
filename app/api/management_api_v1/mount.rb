module ManagementAPIv1
  class Mount < Grape::API
    PREFIX = '/management_api'

    version 'v1', using: :path

    cascade false

    format         :json
    content_type   :json, 'application/json'
    default_format :json

    do_not_route_options!

    helpers ManagementAPIv1::Helpers

    rescue_from(ManagementAPIv1::Exceptions::Base) { |e| error!(e.message, e.status, e.headers) }
    rescue_from(Grape::Exceptions::ValidationErrors) { |e| error!(e.message, 422) }
    rescue_from(ActiveRecord::RecordNotFound) { |e| error!('Couldn\'t find record.', 404) }

    use ManagementAPIv1::JWTAuthenticationMiddleware

    mount ManagementAPIv1::Deposits
    mount ManagementAPIv1::Withdraws
    mount ManagementAPIv1::Tools

    # The documentation is accessible at http://localhost:3000/swagger?url=/management_api/v1/swagger
    add_swagger_documentation base_path:   PREFIX,
                              mount_path:  '/swagger',
                              api_version: 'v1',
                              doc_version: Peatio::VERSION,
                              info: {
                                title:       'Management API v1',
                                description: 'Management API is server-to-server API with high privileges.',
                                licence:     'MIT',
                                license_url: 'https://github.com/rubykube/peatio/blob/master/LICENSE.md' }
  end
end
