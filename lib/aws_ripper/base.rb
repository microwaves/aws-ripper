module AwsRipper
  class Base
    attr_reader :config, :aws_conn, :log_path

    def initialize
      @config = Config.new

      @aws_conn = AwsConn.new(
        regions: @config.regions,
        instance_type: @config.instance_type,
      )
    end

    def prepare_environment
      bootstrap_environment
      sleep 100
      generate_and_upload_configuration
    end

    def destroy_environment!
      @aws_conn.destroy_ec2_instances
    end

    def stress_it
      execute_tsung
    end

    def generate_reports
      convert_logs
      transfer_logs_and_generate_pdfs
    end

    private

    def bootstrap_environment
      @aws_conn.create_and_distribute_ec2_instances
    end

    def generate_and_upload_configuration
      generate_configuration
      upload_configuration
    end

    def generate_configuration
      renderer = ERB.new(File.read(File.join(
        File.dirname(File.expand_path(__FILE__)), '..', '..',
        'templates', 'aws-ripper_http.xml.erb')))

      File.open('/tmp/aws-ripper_http.xml', 'w') do |f|
        f.write(renderer.result(binding()))
      end
    end

    def upload_configuration
      @aws_conn.instances.each do |i|
        Net::SCP.upload!(i[:public_ip_address],
          'admin', '/tmp/aws-ripper_http.xml', 'aws-ripper_http.xml')
      end
    end

    def execute_tsung
      Net::SSH::Multi.start do |session|
        @aws_conn.instances.each do |i|
          session.use "admin@#{i[:public_ip_address]}"
        end

        session.exec 'tsung -f ~/aws-ripper_http.xml start'

        @log_path = Time.now.utc.strftime(
          '/home/admin/.tsung/log/%Y%m%d-%H%M')
      end
    end

    def convert_logs
      Net::SSH::Multi.start do |session|
        @aws_conn.instances.each do |i|
          session.use "admin@#{i[:public_ip_address]}"
        end

        session.exec "cd #{@log_path}; /usr/lib/tsung/bin/tsung_stats.pl"
      end
    end

    def transfer_logs_and_generate_pdfs
      @aws_conn.instances.each do |i|
        local_path = "/tmp/aws_ripper_logs_#{i[:id]}"
        `mkdir -p #{local_path}`
        `scp -r admin@#{i[:public_ip_address]}:#{@log_path} #{local_path}`
        `wkhtmltopdf #{local_path}/#{@log_path.split('/').last}/graph.html /tmp/graph_node-#{i[:id]}.pdf`
      end
    end
  end
end
