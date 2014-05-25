require File.expand_path('../../spec_helper', __FILE__)

describe Pod::Command::Roulette do
  describe Pod::Command::Roulette::Configuration do
    before :each do
      @clazz = Pod::Command::Roulette::Configuration
    end
    
    describe 'humanize_pod_name' do
      it "strips prefix" do
        expect(@clazz.humanize_pod_name('CJInfinityScroll')).to eq 'InfinityScroll'
        expect(@clazz.humanize_pod_name('AInfinityScroll')).to eq 'InfinityScroll'
      end

      it "removes non-chars and capitalizes groups" do
        expect(@clazz.humanize_pod_name('Brightcove-Video-Cloud-App-SDK-Player-and-Sharing-Kit')).to eq 'BrightcoveVideoCloudAppSDKPlayerAndSharingKit'
        expect(@clazz.humanize_pod_name('Ad._-bc')).to eq 'AdBc'
      end

      it "keeps all-caps names" do
        expect(@clazz.humanize_pod_name('ABC')).to eq 'ABC'
      end

      it "capitalizes first char" do
        expect(@clazz.humanize_pod_name('aBC')).to eq 'ABC'
      end
    end
  end
end