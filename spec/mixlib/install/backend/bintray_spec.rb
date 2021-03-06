#
# Author:: Patrick Wright (<patrick@chef.io>)
# Copyright:: Copyright (c) 2016 Chef, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "spec_helper"
require "mixlib/install/options"
require "mixlib/install/backend/bintray"

context "Mixlib::Install::Backend::Bintray" do
  let(:channel) { nil }

  let(:product_name) { nil }

  let(:product_version) { nil }

  let(:platform) { nil }

  let(:platform_version) { nil }

  let(:architecture) { nil }

  let(:options) do
    {}.tap do |opt|
      opt[:product_name] = product_name
      opt[:product_version] = product_version
      opt[:channel] = channel
      if platform
        opt[:platform] = platform
        opt[:platform_version] = platform_version
        opt[:architecture] = architecture
      end
    end
  end

  let(:mixlib_options) { Mixlib::Install::Options.new(options) }

  let(:bintray) { Mixlib::Install::Backend::Bintray.new(mixlib_options) }

  let(:artifact_info) { bintray.info }

  context "with stable channel" do
    let(:channel) { :stable }

    context "with chef product" do
      let(:product_name) { "chef" }

      context "with latest version" do
        let(:product_version) { :latest }

        it "returns all artifacts" do
          expect(artifact_info.size).to be > 1
        end

        context "with ubuntu platform" do
          let(:platform) { "ubuntu" }

          context "with 14.04 platform version" do
            let(:platform_version) { "14.04" }

            context "with x86_64 architecture" do
              let(:architecture) { "x86_64" }

              it "returns a single artifact with correct info" do
                expect(artifact_info).to be_a Mixlib::Install::ArtifactInfo
                expect(artifact_info.version).to eq "12.8.1"
                expect(artifact_info.platform).to eq "ubuntu"
                expect(artifact_info.platform_version).to eq "14.04"
                expect(artifact_info.architecture).to eq "x86_64"
                expect(artifact_info.sha256).to eq "92b7f3eba0a62b20eced2eae03ec2a5e382da4b044c38c20d2902393683c77f7"
                expect(artifact_info.url).to eq "https://packages.chef.io/stable/ubuntu/14.04/chef_12.8.1-1_amd64.deb"
              end
            end
          end
        end
      end
    end
  end

  context "architecture extraction" do
    let(:channel) { :stable }
    let(:product_name) { "chef" }

    it "extracts the architecture from file name correctly" do
      {
        "x86_64" => [
          "chef_12.8.1-1_amd64.deb",
          "chef_12.8.1-1_x64.deb",
          "chef_12.8.1-1_x86_64.deb",
          "chef_12.8.1-1.dmg",
          "chef_12.8.1-1.sh",
        ],
        "i386" => [
          "chef_12.8.1-1_i386.deb",
          "chef_12.8.1-1_i686.deb",
          "chef_12.8.1-1_x86.deb",
          "chef_12.8.1-1_i86pc.deb",
          "chef_12.8.1-1.msi",
          "chef-11.8.2-1.solaris2.5.10.solaris",
        ],
        "powerpc" => [
          "chef-12.8.1-1.powerpc.bff",
        ],
        "sparc" => [
          "chef-12.8.1-1.sparc.solaris",
          "chef-12.8.1-1.sun4u.solaris",
          "chef-12.8.1-1.sun4v.solaris",
          "chef-11.8.2-1.solaris2.5.9.solaris",
        ],
        "ppc64" => [
          "chef-12.8.1-1.ppc64.bff",
        ],
        "ppc64le" => [
          "chef-12.8.1-1.ppc64le.bff",
        ],
      }.each do |arch, filenames|
        filenames.each do |filename|
          expect(bintray.parse_architecture_from_file_name(filename)).to eq(arch)
        end
      end
    end
  end

end
