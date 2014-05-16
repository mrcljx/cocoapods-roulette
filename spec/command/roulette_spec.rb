require File.expand_path('../../spec_helper', __FILE__)

describe 'Roulette' do
  describe 'humanize_pod_name' do
    before do
      @command = Pod::Command.parse(['roulette'])
    end

    it "strips prefix" do
      expect(@command.humanize_pod_name('CJInfinityScroll')).to eq 'InfinityScroll'
      expect(@command.humanize_pod_name('AInfinityScroll')).to eq 'InfinityScroll'
    end

    it "removes non-chars and capitalizes groups" do
      expect(@command.humanize_pod_name('Brightcove-Video-Cloud-App-SDK-Player-and-Sharing-Kit')).to eq 'BrightcoveVideoCloudAppSDKPlayerAndSharingKit'
      expect(@command.humanize_pod_name('Ad._-bc')).to eq 'AdBc'
    end

    it "keeps all-caps names" do
      expect(@command.humanize_pod_name('ABC')).to eq 'ABC'
    end

    it "capitalizes first char" do
      expect(@command.humanize_pod_name('aBC')).to eq 'ABC'
    end
  end
end
