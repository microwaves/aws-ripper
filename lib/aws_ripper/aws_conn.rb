module AwsRipper
  class AwsConn
    attr_accessor :ec2_resource, :regions, :instance_type, :instances

    def initialize(options = {})
      @regions = options[:regions]
      @instance_type = options[:instance_type]
      @instances = []
    end

    def create_and_distribute_ec2_instances
      @regions.each do |k, v|
        create_ec2_instance(k, v)
      end

      @instances
    end

    def destroy_ec2_instances
      @instances.each do |i|
        destroy_ec2_instance(i[:region], i[:id])
      end

      @instances = []
    end

    private

    def create_ec2_instance(region, options = {})
      ec2 = Aws::EC2::Resource.new(region: region)

      options['instances_amount'].times do
        instance = ec2.create_instances({
          image_id: options['image_id'],
          min_count: 1,
          max_count: 1,
          key_name: options['key_name'],
          security_group_ids: [options['security_group_id']],
          subnet_id: options['subnet_id'],
          instance_type: @instance_type
        })

        ec2.client.wait_until(:instance_running, instance_ids:[instance[0].id])

        instance.batch_create_tags({ tags: [{ key: 'Name',
          value: "aws-ripper-#{SecureRandom.hex[1..8]}"}]})

        instance_id = instance[0].id
        @instances << {
          region: region,
          id: instance_id,
          public_ip_address: retrieve_public_ip(region, instance_id)
        }
      end
    end

    def retrieve_public_ip(region, instance_id)
      client = Aws::EC2::Client.new(region: region)
      client.describe_instances(instance_ids: [instance_id])
        .reservations.first.instances.first.public_ip_address
    end

    def destroy_ec2_instance(region, instance_id)
      ec2 = Aws::EC2::Resource.new(region: region)
      instance = ec2.instance(instance_id)
      instance.terminate
    end
  end
end
