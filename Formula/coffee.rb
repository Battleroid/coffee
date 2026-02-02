class Coffee < Formula
  desc "macOS menu bar app to toggle caffeinate on/off"
  homepage "https://github.com/Battleroid/coffee"
  url "https://github.com/Battleroid/coffee/archive/refs/tags/v1.0.tar.gz"
  sha256 "5b0a33588ef2c21386c54e669c3602694fa4b9764fe398d0c752942da128f3f3"
  license "MIT"

  depends_on :macos
  depends_on xcode: ["14.0", :build]

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/Coffee"
  end

  def caveats
    <<~EOS
      To start Coffee as a service (runs at login):
        brew services start coffee

      To stop the service:
        brew services stop coffee

      To run manually (one-time):
        coffee
    EOS
  end

  # This creates a LaunchAgent plist for `brew services`
  service do
    run opt_bin/"Coffee"
    keep_alive false
    process_type :interactive
  end

  test do
    assert_predicate bin/"Coffee", :exist?
  end
end
