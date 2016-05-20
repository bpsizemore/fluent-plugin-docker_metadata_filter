#
# Fluentd Docker Metadata Filter Plugin - Enrich Fluentd events with Docker
# metadata
#
# Copyright 2015 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require_relative '../helper'
require 'fluent/plugin/filter_docker_metadata'

require 'webmock/test_unit'
WebMock.disable_net_connect!

class DockerMetadataFilterTest < Test::Unit::TestCase
  include Fluent

  setup do
    Fluent::Test.setup
    @time = Fluent::Engine.now
  end

  def create_driver(conf = '')
    Test::FilterTestDriver.new(DockerMetadataFilter).configure(conf, true)
  end

  sub_test_case 'configure' do
    test 'check default' do
      d = create_driver
      assert_equal(d.instance.docker_url, 'unix:///var/run/docker.sock')
      assert_equal(100, d.instance.cache_size)
    end

    test 'docker url' do
      d = create_driver(%[docker_url http://docker-url])
      assert_equal('http://docker-url', d.instance.docker_url)
      assert_equal(100, d.instance.cache_size)
    end

    test 'cache size' do
      d = create_driver(%[cache_size 1])
      assert_equal('unix:///var/run/docker.sock', d.instance.docker_url)
      assert_equal(1, d.instance.cache_size)
    end
  end

  sub_test_case 'filter_stream' do
    def messages
      [
        "2013/01/13T07:02:11.124202 INFO GET /ping",
        "2013/01/13T07:02:13.232645 WARN POST /auth",
        "2013/01/13T07:02:21.542145 WARN GET /favicon.ico",
        "2013/01/13T07:02:43.632145 WARN POST /login",
      ]
    end

    def emit(config, msgs, tag='df14e0d5ae4c07284fa636d739c8fc2e6b52bc344658de7d3f08c36a2e804115')
      d = create_driver(config)
      d.run {
        msgs.each { |msg|
          d.emit_with_tag(tag, {'foo' => 'bar', 'message' => msg}, @time)
        }
      }.filtered
    end

    test 'docker metadata' do
      VCR.use_cassette('docker_metadata') do
        es = emit('', messages)
        assert_equal(4, es.instance_variable_get(:@record_array).size)
        assert_equal('df14e0d5ae4c07284fa636d739c8fc2e6b52bc344658de7d3f08c36a2e804115', es.instance_variable_get(:@record_array)[0]['docker']['id'])
        assert_equal('k8s_fabric8-console-container.efbd6e64_fabric8-console-controller-9knhj_default_8ae2f621-f360-11e4-8d12-54ee7527188d_7ec9aa3e', es.instance_variable_get(:@record_array)[0]['docker']['name'])
        assert_equal('fabric8-console-controller-9knhj', es.instance_variable_get(:@record_array)[0]['docker']['container_hostname'])
        assert_equal('b2bd1a24a68356b2f30128e6e28e672c1ef92df0d9ec01ec0c7faea5d77d2303', es.instance_variable_get(:@record_array)[0]['docker']['image_id'])
        assert_equal('fabric8/hawtio-kubernetes:latest', es.instance_variable_get(:@record_array)[0]['docker']['image'])
      end
    end

    test 'nonexistent docker metadata' do
      VCR.use_cassette('nonexistent_docker_metadata') do
        es = emit('', messages, '1111111111111111111111111111111111111111111111111111111111111111')
        assert_equal(4, es.instance_variable_get(:@record_array).size)
        assert_nil(es.instance_variable_get(:@record_array)[0]['docker'])
      end
    end
  end
end
